///|
test "O2 forms memory intrinsic in the module context" {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("zero_memory")
  let machine = @IR.TargetMachine::host(@IR.TargetMachineOptions::default())
  machine.configureModule(mod)
  let pointer = ctx.getPtrTy()
  let function = mod.addFunction(
    ctx.getFunctionType(ctx.getVoidTy(), [pointer, ctx.getInt1Ty()]),
    "clear",
  )
  guard function.getArg(0) is Some(destination) else {
    fail("missing destination")
  }
  guard function.getArg(1) is Some(condition) else { fail("missing condition") }
  let builder = ctx.createBuilder()
  let entry = function.addBasicBlock(name="entry")
  let body = function.addBasicBlock(name="body")
  let exit = function.addBasicBlock(name="exit")
  builder.setInsertPoint(entry)
  builder.createCondBr(condition, body, exit) |> ignore
  builder.setInsertPoint(body)
  for index in 0..<16 {
    let address = builder.createGEP(destination, ctx.getInt64Ty(), [
      ctx.getConstInt32(index),
    ])
    builder.createStore(ctx.getConstInt64(0), address) |> ignore
  }
  builder.createBr(exit) |> ignore
  builder.setInsertPoint(exit)
  builder.createRetVoid() |> ignore
  mod.verify()
  let optimized = mod.runPasses("default<O2>", targetMachine=machine) catch {
    @IR.VerificationError(message) => fail(message)
    error => raise error
  }
  optimized.verify()
  assert_true(optimized.to_string().contains("llvm.memset"))
}
