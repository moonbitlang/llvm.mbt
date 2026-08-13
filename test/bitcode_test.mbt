///|
test "in-memory bitcode snapshot is independent and non-mutating" {
  let context = @IR.Context::new()
  let mod = context.addModule("bitcode_snapshot")
  let i32_type = context.getInt32Ty()
  let function_type = context.getFunctionType(i32_type, [])
  let function = mod.addFunction(function_type, "answer")
  let entry = function.addBasicBlock(name="entry")
  let builder = context.createBuilder()
  builder.setInsertPoint(entry)
  builder.createRet(context.getConstInt32(42)) |> ignore
  let before = "\{mod}"
  let triple = mod.getTargetTriple()
  let layout = mod.getDataLayoutStr()

  let first = mod.writeBitCodeToBytes()
  let second = mod.writeBitCodeToBytes()

  inspect(first.length() > 0, content="true")
  inspect(first == second, content="true")
  inspect("\{mod}" == before, content="true")
  inspect(mod.getTargetTriple() == triple, content="true")
  inspect(mod.getDataLayoutStr() == layout, content="true")
}
