///|
test "GlobalVariable basic behavior" {
  let context = Context::new()
  let mod = context.addModule("global_variable")
  let i32_type = context.getInt32Ty()
  let initial_value = context.getConstInt32(42)
  let global = mod.addGlobalVariable(
    i32_type,
    "answer",
    initializer=initial_value,
  )
  inspect(
    global,
    content=(
      #|@answer = global i32 42
    ),
  )
  debug_inspect(global.getValueName(), content=(
    #|Some("answer")
  ))
  assert_true(global.asValueEnum() is GlobalVariable(_))
  assert_true(global.asGlobalEnum() is GlobalVariable(_))
  assert_true(global.getLinkage() is ExternalLinkage)
  assert_true(global.getUnnamedAddr() is NoUnnamedAddr)
}

///|
test "GlobalConstant basic behavior" {
  let context = Context::new()
  let mod = context.addModule("global_constant")
  let i32_type = context.getInt32Ty()
  let value = context.getConstInt32(7)
  let global = mod.addGlobalConstant(i32_type, "limit", value)
  inspect(
    global,
    content=(
      #|@limit = constant i32 7
    ),
  )
  debug_inspect(global.getValueName(), content=(
    #|Some("limit")
  ))
  assert_true(global.asValueEnum() is GlobalConstant(_))
  assert_true(global.asGlobalEnum() is GlobalConstant(_))
  assert_true(global.getLinkage() is ExternalLinkage)
  assert_true(global.getUnnamedAddr() is NoUnnamedAddr)
}
