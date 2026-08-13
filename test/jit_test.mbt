///|
test "JIT submission keeps the source module unchanged" {
  let context = @IR.Context::new()
  let mod = context.addModule("public_snapshot")
  let function_type = context.getFunctionType(context.getInt32Ty(), [])
  let function = mod.addFunction(function_type, "answer")
  let entry = function.addBasicBlock(name="entry")
  let builder = context.createBuilder()
  builder.setInsertPoint(entry)
  builder.createRet(context.getConstInt32(42)) |> ignore
  mod.verify()
  let before = "\{mod}"
  let before_triple = mod.getTargetTriple()
  let before_layout = mod.getDataLayoutStr()
  let jit = @JIT.LLJIT::host()

  jit.addModule(mod)

  inspect(mod.getFunction("answer") is Some(_), content="true")
  inspect("\{mod}" == before, content="true")
  inspect(mod.getTargetTriple() == before_triple, content="true")
  inspect(mod.getDataLayoutStr() == before_layout, content="true")
  jit.close()
}

///|
test "JIT rejects removed and foreign resource trackers" {
  let context = @IR.Context::new()
  let mod = context.addModule("tracker_errors")
  let first = @JIT.LLJIT::host()
  let second = @JIT.LLJIT::host()
  let removed_tracker = first.createResourceTracker()
  removed_tracker.remove()
  let removed = try {
    first.addModule(mod, tracker=removed_tracker)
    false
  } catch {
    @JIT.ResourceTrackerRemoved => true
    _ => false
  }
  inspect(removed, content="true")
  let foreign_tracker = second.createResourceTracker()
  let foreign = try {
    first.addModule(mod, tracker=foreign_tracker)
    false
  } catch {
    @JIT.ResourceTrackerOwnerMismatch => true
    _ => false
  }
  inspect(foreign, content="true")
  first.close()
  second.close()
}

///|
test "JIT executes a looked-up double function" {
  let context = @IR.Context::new()
  let mod = context.addModule("execute_answer")
  let function_type = context.getFunctionType(context.getDoubleTy(), [])
  let function = mod.addFunction(function_type, "answer_double")
  let entry = function.addBasicBlock(name="entry")
  let builder = context.createBuilder()
  builder.setInsertPoint(entry)
  builder.createRet(context.getConstDouble(42.0)) |> ignore
  mod.verify()
  let jit = @JIT.LLJIT::host()
  jit.addModule(mod)

  let address = jit.lookup("answer_double")
  let answer : FuncRef[() -> Double] = address.unsafeToFuncRef()
  inspect(answer(), content="42")

  jit.close()
}

///|
test "JIT lookup preserves symbol diagnostics and string errors" {
  let jit = @JIT.LLJIT::host()
  let missing = try {
    jit.lookup("__llvm_mbt_missing_public_symbol__") |> ignore
    false
  } catch {
    @JIT.LookupFailed(message) => message.length() > 0
    _ => false
  }
  inspect(missing, content="true")
  let embedded_nul = try {
    jit.lookup("bad\u0000symbol") |> ignore
    false
  } catch {
    @IR.ContainsNul => true
    _ => false
  }
  inspect(embedded_nul, content="true")
  jit.close()
}
