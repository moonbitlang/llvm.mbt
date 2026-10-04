///|
test "constant declarations support cyclic tables and adapter addresses" {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("tables")
  let ptr = ctx.getPtrTy()
  let table_ty = ctx.getStructType([ptr, ptr])
  let left = mod.declareGlobalConstant(table_ty, "left", linkage=PrivateLinkage)
  let right = mod.declareGlobalConstant(
    table_ty,
    "right",
    linkage=PrivateLinkage,
  )
  let adapter = mod.addFunction(
    ctx.getFunctionType(ctx.getVoidTy(), [ptr]),
    "adapter",
  )
  let left_address = ctx.getConstArray(ptr, [left])
  left.setInitializer(ctx.getConstStruct([adapter, right]))
  right.setInitializer(ctx.getConstStruct([adapter, left]))
  mod.verify()
  inspect(
    left,
    content="@left = private constant { ptr, ptr } { ptr @adapter, ptr @right }",
  )
  inspect(
    right,
    content="@right = private constant { ptr, ptr } { ptr @adapter, ptr @left }",
  )
  inspect(left_address, content="[1 x ptr] [ptr @left]")
}

///|
test "constant declarations validate type and name before insertion" {
  let ctx = @IR.Context::new()
  let foreign = @IR.Context::new()
  let mod = ctx.addModule("declarations")
  let before = mod.to_string()
  assert_builder_error(
    () => mod.declareGlobalConstant(foreign.getInt32Ty(), "foreign"),
    e => e is @IR.ValueOwnerError::ContextMismatch,
  )
  assert_builder_error(
    () => mod.declareGlobalConstant(ctx.getVoidTy(), "void"),
    e => e is @IR.InValidTypeError(_),
  )
  assert_contains_nul(() => {
    mod.declareGlobalConstant(ctx.getInt32Ty(), "bad\u0000name")
  })
  inspect(mod.to_string() == before, content="true")
  let external = mod.declareGlobalConstant(ctx.getInt32Ty(), "external")
  inspect(external, content="@external = external constant i32")
  mod.verify()
}

///|
test "constant initializer replacement preserves state on validation failures" {
  let ctx = @IR.Context::new()
  let foreign = @IR.Context::new()
  let mod = ctx.addModule("updates")
  let other = ctx.addModule("other")
  let scalar = mod.declareGlobalConstant(ctx.getInt32Ty(), "scalar")
  assert_builder_error(() => scalar.setInitializer(ctx.getConstInt64(0)), e => {
    e is @IR.InValidTypeError(_)
  })
  inspect(scalar, content="@scalar = external constant i32")
  scalar.setInitializer(ctx.getConstInt32(1))
  assert_builder_error(() => scalar.setInitializer(foreign.getConstInt32(2)), e => {
    e is @IR.ValueOwnerError::ContextMismatch
  })
  assert_builder_error(() => scalar.setInitializer(ctx.getConstInt64(2)), e => {
    e is @IR.InValidTypeError(_)
  })
  inspect(scalar, content="@scalar = constant i32 1")
  scalar.setInitializer(ctx.getConstInt32(3))
  inspect(scalar, content="@scalar = constant i32 3")
  let foreign_global = other.declareGlobalConstant(ctx.getInt32Ty(), "foreign")
  let initial = ctx.getConstStruct([scalar])
  let table = mod.addGlobalConstant(initial.getType(), "table", initial)
  let foreign_initial = ctx.getConstStruct([foreign_global])
  let before = mod.to_string()
  assert_builder_error(() => table.setInitializer(foreign_initial), e => {
    e is @IR.ValueOwnerError::ModuleMismatch
  })
  inspect(mod.to_string() == before, content="true")
  mod.verify()
  other.verify()
}

///|
test "deferred constants retain owners after local bindings end" {
  let (left, right) = {
    let ctx = @IR.Context::new()
    let mod = ctx.addModule("retained")
    (
      mod.declareGlobalConstant(ctx.getPtrTy(), "left"),
      mod.declareGlobalConstant(ctx.getPtrTy(), "right"),
    )
  }
  left.setInitializer(right)
  right.setInitializer(left)
  inspect(left, content="@left = constant ptr @right")
  inspect(right, content="@right = constant ptr @left")
}
