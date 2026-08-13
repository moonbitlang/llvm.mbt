///|
test "private snapshot submission leaves source module usable" {
  let context = @IR.Context::new()
  let mod = context.addModule("private_snapshot")
  let jit = LLJIT::host()
  jit.addModule(mod)
  inspect(mod.getName(), content="private_snapshot")
  jit.close()
}
