///|
test "published package supports IR, object emission, and JIT" {
  let context = @llvm.Context::new()
  let mod = context.addModule("published_package_smoke")
  let function_type = context.getFunctionType(context.getDoubleTy(), [])
  let function = mod.addFunction(function_type, "answer")
  let entry = function.addBasicBlock(name="entry")
  let builder = context.createBuilder()
  builder.setInsertPoint(entry)
  builder.createRet(context.getConstDouble(42.0)) |> ignore
  let machine = @llvm.TargetMachine::host(@llvm.TargetMachineOptions::default())
  machine.configureModule(mod)
  mod.verify()
  machine.emitObjectToFile(mod, "published-package-smoke.o")
  let jit = @jit.LLJIT::host()
  jit.addModule(mod)
  let address = jit.lookup("answer")
  let answer : FuncRef[() -> Double] = address.unsafeToFuncRef()
  inspect(answer(), content="42")
  jit.close()
}
