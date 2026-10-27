///|
test "constant GEP addresses string literal data from location records" {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("locations")
  let ptr_ty = ctx.getPtrTy()
  let i32_ty = ctx.getInt32Ty()
  let bytes = ctx.getConstArray(ctx.getInt8Ty(), [
    ctx.getConstInt8(97),
    ctx.getConstInt8(46),
    ctx.getConstInt8(114),
    ctx.getConstInt8(97),
    ctx.getConstInt8(0),
  ])
  let literal = ctx.getConstStruct([
    ctx.getConstInt64(4),
    ctx.getConstPointerNull(ptr_ty),
    bytes,
  ])
  let literal_ty = literal.getType()
  let str = mod.addGlobalConstant(
    literal_ty,
    "str",
    literal,
    linkage=PrivateLinkage,
  )
  str.setUnnamedAddr(Global)
  str.setAlignment(8)
  let zero = ctx.getConstInt32(0)
  let data = ctx.getConstGEP(
    str,
    literal_ty,
    [zero, ctx.getConstInt32(2)],
    inbounds=true,
  )
  inspect(data.asConstantEnum() is ConstantExpr(_), content="true")
  inspect(@IR.Value::getType(data).to_string(), content="ptr")
  let first_byte = ctx.getConstGEP(
    str,
    literal_ty,
    [zero, ctx.getConstInt32(2), ctx.getConstInt64(0)],
    inbounds=true,
  )
  let location = ctx.getConstStruct([
    data,
    ctx.getConstInt32(3),
    ctx.getConstInt32(14),
  ])
  inspect(location.getType().to_string(), content="{ ptr, i32, i32 }")
  let loc = mod.addGlobalConstant(
    location.getType(),
    "loc",
    location,
    linkage=PrivateLinkage,
  )
  loc.setAlignment(8)
  let byte_loc = mod.addGlobalVariable(
    ctx.getStructType([ptr_ty, i32_ty, i32_ty]),
    "byte_loc",
    initializer=ctx.getConstStruct([first_byte, zero, zero]),
    linkage=InternalLinkage,
  )
  inspect(byte_loc.getAlignment(), content="0")
  mod.verify()
  inspect(
    mod,
    content=(
      #|; ModuleID = 'locations'
      #|source_filename = "locations"
      #|
      #|@str = private unnamed_addr constant { i64, ptr, [5 x i8] } { i64 4, ptr null, [5 x i8] c"a.ra\00" }, align 8
      #|@loc = private constant { ptr, i32, i32 } { ptr getelementptr inbounds ({ i64, ptr, [5 x i8] }, ptr @str, i32 0, i32 2), i32 3, i32 14 }, align 8
      #|@byte_loc = internal global { ptr, i32, i32 } { ptr getelementptr inbounds ({ i64, ptr, [5 x i8] }, ptr @str, i32 0, i32 2, i64 0), i32 0, i32 0 }
      #|
    ),
  )
}

///|
test "constant GEP supports plain and folded addresses" {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("plain")
  let i32_ty = ctx.getInt32Ty()
  let table_ty = ctx.getArrayType(i32_ty, 4)
  let table = mod.addGlobalVariable(
    table_ty,
    "table",
    initializer=ctx.getConstArray(i32_ty, [
      ctx.getConstInt32(1),
      ctx.getConstInt32(2),
      ctx.getConstInt32(3),
      ctx.getConstInt32(4),
    ]),
  )
  let third = ctx.getConstGEP(table, table_ty, [
    ctx.getConstInt64(0),
    ctx.getConstInt64(2),
  ])
  inspect(
    third,
    content="ptr getelementptr ([4 x i32], ptr @table, i64 0, i64 2)",
  )
  // An index past the end is legal without `inbounds`.
  let past_end = ctx.getConstGEP(table, i32_ty, [ctx.getConstInt32(4)])
  inspect(past_end, content="ptr getelementptr (i32, ptr @table, i32 4)")
  let folded = ctx.getConstGEP(
    table,
    table_ty,
    [ctx.getConstInt32(0), ctx.getConstInt32(0)],
    inbounds=true,
  )
  // All-zero indices fold to the base global itself.
  inspect(folded.asConstantEnum() is GlobalVariable(_), content="true")
  inspect(
    @IR.Value::getValueName(folded) == @IR.Value::getValueName(table),
    content="true",
  )
  let no_indices = ctx.getConstGEP(table, table_ty, [])
  inspect(no_indices.asConstantEnum() is GlobalVariable(_), content="true")
  // A pure constant expression has no module dependency.
  let null_offset = ctx.getConstGEP(
    ctx.getConstPointerNull(ctx.getPtrTy()),
    i32_ty,
    [ctx.getConstInt64(3)],
  )
  let other = ctx.addModule("other")
  other.addGlobalConstant(ctx.getPtrTy(), "offset", null_offset) |> ignore
  mod.addGlobalConstant(ctx.getPtrTy(), "third", third) |> ignore
  mod.verify()
  other.verify()
  inspect(
    other,
    content=(
      #|; ModuleID = 'other'
      #|source_filename = "other"
      #|
      #|@offset = constant ptr getelementptr (i32, ptr null, i64 3)
      #|
    ),
  )
}

///|
test "constant GEP rejects foreign contexts and modules" {
  let ctx = @IR.Context::new()
  let foreign = @IR.Context::new()
  let a = ctx.addModule("a")
  let b = ctx.addModule("b")
  let i32_ty = ctx.getInt32Ty()
  let x = a.addGlobalVariable(i32_ty, "x", initializer=ctx.getConstInt32(0))
  let y = b.addGlobalConstant(i32_ty, "y", ctx.getConstInt32(1))
  let foreign_global = foreign
    .addModule("foreign")
    .addGlobalVariable(foreign.getInt32Ty(), "z")
  let zero = ctx.getConstInt32(0)
  assert_builder_error(() => ctx.getConstGEP(x, foreign.getInt32Ty(), [zero]), e => {
    e is @IR.ValueOwnerError::ContextMismatch
  })
  assert_builder_error(() => ctx.getConstGEP(foreign_global, i32_ty, [zero]), e => {
    e is @IR.ValueOwnerError::ContextMismatch
  })
  assert_builder_error(
    () => ctx.getConstGEP(x, i32_ty, [foreign.getConstInt32(0)]),
    e => e is @IR.ValueOwnerError::ContextMismatch,
  )
  assert_builder_error(() => foreign.getConstGEP(x, i32_ty, [zero]), e => {
    e is @IR.ValueOwnerError::ContextMismatch
  })
  // An index whose constant expression refers to a global of module `b`.
  let builder = ctx.createBuilder()
  let f = b.addFunction(ctx.getFunctionType(ctx.getVoidTy(), []), "f")
  builder.setInsertPoint(f.addBasicBlock(name="entry"))
  let y_address = builder.createPtrToInt(y, ctx.getInt64Ty())
  guard y_address.tryAsConstant() is Some(y_index) else {
    fail("ptrtoint of a global should fold to a constant")
  }
  assert_builder_error(() => ctx.getConstGEP(x, i32_ty, [y_index]), e => {
    e is @IR.ValueOwnerError::ModuleMismatch
  })
  // The result retains module `a`, so it cannot initialize a global of `b`.
  let x_next = ctx.getConstGEP(x, i32_ty, [ctx.getConstInt32(1)])
  let before = b.to_string()
  assert_builder_error(
    () => b.addGlobalConstant(ctx.getPtrTy(), "bad", x_next),
    e => e is @IR.ValueOwnerError::ModuleMismatch,
  )
  assert_builder_error(() => ctx.getConstStruct([x_next, y]), e => {
    e is @IR.ValueOwnerError::ModuleMismatch
  })
  inspect(b.to_string() == before, content="true")
  a.verify()
}

///|
test "constant GEP rejects invalid bases types and paths" {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("invalid")
  let i32_ty = ctx.getInt32Ty()
  let pair_ty = ctx.getStructType([i32_ty, ctx.getInt64Ty()])
  let pair = mod.addGlobalConstant(
    pair_ty,
    "pair",
    ctx.getConstStruct([ctx.getConstInt32(1), ctx.getConstInt64(2)]),
  )
  let zero = ctx.getConstInt32(0)
  let before = mod.to_string()
  // Base must be a pointer.
  assert_builder_error(() => ctx.getConstGEP(zero, i32_ty, [zero]), e => {
    e is @IR.InValidTypeError(_)
  })
  // Source element type must be sized.
  assert_builder_error(() => ctx.getConstGEP(pair, ctx.getVoidTy(), [zero]), e => {
    e is @IR.InValidTypeError(_)
  })
  let opaque_ty = ctx.getOpaqueStructType("Opaque")
  assert_builder_error(() => ctx.getConstGEP(pair, opaque_ty, [zero]), e => {
    e is @IR.InValidTypeError(_)
  })
  // Indices must be scalar integers.
  assert_builder_error(
    () => ctx.getConstGEP(pair, pair_ty, [ctx.getConstFloat(0.0)]),
    e => e is @IR.InValidTypeError(_),
  )
  // A path cannot index into a scalar.
  assert_builder_error(() => ctx.getConstGEP(pair, i32_ty, [zero, zero]), e => {
    e is @IR.InValidTypeError(_)
  })
  assert_builder_error(
    () => ctx.getConstGEP(pair, pair_ty, [zero, zero, zero]),
    e => e is @IR.InValidTypeError(_),
  )
  // Struct field indices must be i32 ConstantInt values.
  assert_builder_error(
    () => ctx.getConstGEP(pair, pair_ty, [zero, ctx.getConstInt64(1)]),
    e => e is @IR.InValidTypeError(_),
  )
  assert_builder_error(
    () => ctx.getConstGEP(pair, pair_ty, [zero, ctx.getUndef(i32_ty)]),
    e => e is @IR.InValidTypeError(_),
  )
  // Struct field indices must be in range.
  assert_builder_error(
    () => ctx.getConstGEP(pair, pair_ty, [zero, ctx.getConstInt32(2)]),
    e => e is @IR.IndexOutOfBounds(_),
  )
  assert_builder_error(
    () => ctx.getConstGEP(pair, pair_ty, [zero, ctx.getConstInt32(-1)]),
    e => e is @IR.IndexOutOfBounds(_),
  )
  inspect(mod.to_string() == before, content="true")
  let second = ctx.getConstGEP(pair, pair_ty, [zero, ctx.getConstInt32(1)])
  inspect(
    second,
    content="ptr getelementptr ({ i32, i64 }, ptr @pair, i32 0, i32 1)",
  )
  mod.verify()
}

///|
test "global alignment can be set read and cleared" {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("alignment")
  let declared = mod.addGlobalVariable(ctx.getInt64Ty(), "declared")
  let constant = mod.addGlobalConstant(
    ctx.getInt32Ty(),
    "constant",
    ctx.getConstInt32(7),
  )
  inspect(declared.getAlignment(), content="0")
  inspect(constant.getAlignment(), content="0")
  declared.setAlignment(16)
  constant.setAlignment(1)
  inspect(declared.getAlignment(), content="16")
  inspect(constant.getAlignment(), content="1")
  mod.verify()
  inspect(
    mod,
    content=(
      #|; ModuleID = 'alignment'
      #|source_filename = "alignment"
      #|
      #|@declared = external global i64, align 16
      #|@constant = constant i32 7, align 1
      #|
    ),
  )
  constant.setAlignment(0)
  inspect(constant.getAlignment(), content="0")
  inspect(constant, content="@constant = constant i32 7")
}

///|
test "global alignment rejects values that are not powers of two" {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("bad_alignment")
  let variable = mod.addGlobalVariable(
    ctx.getInt32Ty(),
    "variable",
    initializer=ctx.getConstInt32(0),
  )
  let constant = mod.addGlobalConstant(
    ctx.getInt32Ty(),
    "constant",
    ctx.getConstInt32(0),
  )
  variable.setAlignment(4)
  constant.setAlignment(4)
  for bad in [3, 6, -1, -8] {
    assert_builder_error(() => variable.setAlignment(bad), e => {
      e is @IR.BuilderError::InValidArgument(_)
    })
    assert_builder_error(() => constant.setAlignment(bad), e => {
      e is @IR.BuilderError::InValidArgument(_)
    })
  }
  inspect(variable.getAlignment(), content="4")
  inspect(constant.getAlignment(), content="4")
  mod.verify()
}
