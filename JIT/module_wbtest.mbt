///|
test "private snapshot submission leaves source module usable" {
  let context = @IR.Context::new()
  let mod = context.addModule("private_snapshot")
  let jit = LLJIT::host()
  jit.addModule(mod)
  inspect(mod.getName(), content="private_snapshot")
  jit.close()
}

///|
test "materialization failure remains a lookup diagnostic" {
  let context = @IR.Context::new()
  let mod = context.addModule("materialization_failure")
  let function_type = context.getFunctionType(context.getDoubleTy(), [])
  let missing = mod.addFunction(
    function_type, "__llvm_mbt_missing_materialization_dependency__",
  )
  let wrapper = mod.addFunction(function_type, "jit_materialization_failure")
  let entry = wrapper.addBasicBlock(name="entry")
  let builder = context.createBuilder()
  builder.setInsertPoint(entry)
  let result = builder.createCall(missing, [], name="result")
  builder.createRet(result) |> ignore
  mod.verify()
  let jit = LLJIT::host()
  jit.addModule(mod)
  let failed = try {
    jit.lookup("jit_materialization_failure") |> ignore
    false
  } catch {
    LookupFailed(message) => message.length() > 0
    _ => false
  }
  inspect(failed, content="true")
  jit.close()
}
