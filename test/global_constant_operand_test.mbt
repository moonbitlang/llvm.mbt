///|
test "global addresses build GC descriptors and root tables" {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("gc_tables")
  let ptr_ty = ctx.getPtrTy()
  let offsets = ctx.getConstArray(ctx.getInt64Ty(), [ctx.getConstInt64(8)])
  let references = mod.addGlobalConstant(
    offsets.getType(),
    "references",
    offsets,
    linkage=PrivateLinkage,
  )
  let descriptor = ctx.getConstStruct([
    ctx.getConstInt64(16),
    ctx.getConstInt64(8),
    ctx.getConstInt64(1),
    references,
  ])
  mod.addGlobalConstant(
    descriptor.getType(),
    "descriptor",
    descriptor,
    linkage=PrivateLinkage,
  )
  |> ignore
  let root = mod.addGlobalVariable(
    ptr_ty,
    "root",
    initializer=ctx.getConstPointerNull(ptr_ty),
    linkage=InternalLinkage,
  )
  let addresses = ctx.getConstArray(ptr_ty, [root])
  mod.addGlobalConstant(
    addresses.getType(),
    "root_addresses",
    addresses,
    linkage=PrivateLinkage,
  )
  |> ignore
  inspect(root.asConstantEnum() is GlobalVariable(_), content="true")
  inspect(references.asConstantEnum() is GlobalConstant(_), content="true")
  inspect(root.tryAsConstant() is Some(_), content="true")
  inspect(references.tryAsConstant() is Some(_), content="true")
  inspect(root.tryAsConstantEnum() is Some(GlobalVariable(_)), content="true")
  inspect(
    references.tryAsConstantEnum() is Some(GlobalConstant(_)),
    content="true",
  )
  mod.verify()
  inspect(
    mod,
    content=(
      #|; ModuleID = 'gc_tables'
      #|source_filename = "gc_tables"
      #|
      #|@references = private constant [1 x i64] [i64 8]
      #|@descriptor = private constant { i64, i64, i64, ptr } { i64 16, i64 8, i64 1, ptr @references }
      #|@root = internal global ptr null
      #|@root_addresses = private constant [1 x ptr] [ptr @root]
      #|
    ),
  )
}

///|
test "nested address aggregates outlive original context and module bindings" {
  let aggregate = {
    let ctx = @IR.Context::new()
    let mod = ctx.addModule("scoped_constants")
    let variable = mod.addGlobalVariable(
      ctx.getInt32Ty(),
      "variable",
      initializer=ctx.getConstInt32(42),
    )
    let constant = mod.addGlobalConstant(
      ctx.getInt32Ty(),
      "constant",
      ctx.getConstInt32(7),
    )
    let array = ctx.getConstArray(ctx.getPtrTy(), [variable, constant])
    let vector = ctx.getConstVector([variable, constant])
    ctx.getConstStruct([array, vector])
  }
  inspect(
    aggregate,
    content=(
      #|{ [2 x ptr], <2 x ptr> } { [2 x ptr] [ptr @variable, ptr @constant], <2 x ptr> <ptr @variable, ptr @constant> }
    ),
  )
  inspect(aggregate.getType().to_string(), content="{ [2 x ptr], <2 x ptr> }")
}

///|
test "constant aggregates reject mixed contexts modules and element types" {
  let ctx = @IR.Context::new()
  let other_ctx = @IR.Context::new()
  let a = ctx.addModule("a")
  let b = ctx.addModule("b")
  let x = a.addGlobalVariable(ctx.getInt32Ty(), "x")
  let y = b.addGlobalConstant(ctx.getInt32Ty(), "y", ctx.getConstInt32(0))
  let nested_x = ctx.getConstStruct([x])
  let nested_y = ctx.getConstStruct([y])
  assert_builder_error(() => ctx.getConstArray(ctx.getPtrTy(), [x, y]), e => {
    e is @IR.ValueOwnerError::ModuleMismatch
  })
  assert_builder_error(() => ctx.getConstStruct([nested_x, nested_y]), e => {
    e is @IR.ValueOwnerError::ModuleMismatch
  })
  assert_builder_error(() => ctx.getConstVector([x, y]), e => {
    e is @IR.ValueOwnerError::ModuleMismatch
  })
  assert_builder_error(() => other_ctx.getConstStruct([nested_x]), e => {
    e is @IR.ValueOwnerError::ContextMismatch
  })
  assert_builder_error(() => ctx.getConstArray(other_ctx.getInt32Ty(), []), e => {
    e is @IR.ValueOwnerError::ContextMismatch
  })
  assert_builder_error(
    () => ctx.getConstArray(ctx.getInt32Ty(), [other_ctx.getConstInt32(0)]),
    e => e is @IR.ValueOwnerError::ContextMismatch,
  )
  assert_builder_error(() => ctx.getConstArray(ctx.getInt32Ty(), [x]), e => {
    e is @IR.InValidTypeError(_)
  })
  assert_builder_error(() => ctx.getConstArray(ctx.getVoidTy(), []), e => {
    e is @IR.InValidTypeError(_)
  })
  assert_builder_error(() => ctx.getConstVector([]), e => {
    e is @IR.InValidTypeError(_)
  })
  assert_builder_error(
    () => ctx.getConstVector([ctx.getConstInt32(0), ctx.getConstInt64(0)]),
    e => e is @IR.InValidTypeError(_),
  )
  assert_builder_error(() => ctx.getConstVector([nested_x]), e => {
    e is @IR.InValidTypeError(_)
  })
  a.verify()
  b.verify()
}

///|
test "global initializers validate owner and type before inserting a symbol" {
  let ctx = @IR.Context::new()
  let other_ctx = @IR.Context::new()
  let a = ctx.addModule("a")
  let b = ctx.addModule("b")
  let root = a.addGlobalVariable(ctx.getPtrTy(), "root")
  let addresses = ctx.getConstArray(ctx.getPtrTy(), [root])
  let before = b.to_string()
  assert_builder_error(
    () => b.addGlobalConstant(addresses.getType(), "bad_array", addresses),
    e => e is @IR.ValueOwnerError::ModuleMismatch,
  )
  assert_builder_error(
    () => b.addGlobalVariable(ctx.getPtrTy(), "bad_ptr", initializer=root),
    e => e is @IR.ValueOwnerError::ModuleMismatch,
  )
  assert_builder_error(
    () => b.addGlobalVariable(other_ctx.getInt32Ty(), "foreign_type"),
    e => e is @IR.ValueOwnerError::ContextMismatch,
  )
  assert_builder_error(
    () => {
      b.addGlobalConstant(
        ctx.getInt32Ty(),
        "foreign_value",
        other_ctx.getConstInt32(0),
      )
    },
    e => e is @IR.ValueOwnerError::ContextMismatch,
  )
  assert_builder_error(
    () => {
      b.addGlobalConstant(ctx.getInt64Ty(), "bad_type", ctx.getConstInt32(0))
    },
    e => e is @IR.InValidTypeError(_),
  )
  assert_builder_error(
    () => {
      b.addGlobalVariable(
        ctx.getInt64Ty(),
        "bad_init",
        initializer=ctx.getConstInt32(0),
      )
    },
    e => e is @IR.InValidTypeError(_),
  )
  inspect(b.to_string() == before, content="true")
  let plain = ctx.getConstStruct([ctx.getConstInt32(42)])
  a.addGlobalConstant(plain.getType(), "plain", plain) |> ignore
  b.addGlobalConstant(plain.getType(), "plain", plain) |> ignore
  a.addGlobalConstant(ctx.getPtrTy(), "direct_address", root) |> ignore
  a.verify()
  b.verify()
}

///|
test "builder folding classifies global addresses scalars and nested aggregates" {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("folds")
  let root = mod.addGlobalVariable(
    ctx.getInt32Ty(),
    "root",
    initializer=ctx.getConstInt32(42),
  )
  let immutable = mod.addGlobalConstant(
    ctx.getInt32Ty(),
    "immutable",
    ctx.getConstInt32(7),
  )
  let function = mod.addFunction(ctx.getFunctionType(ctx.getVoidTy(), []), "f")
  let builder = ctx.createBuilder()
  builder.setInsertPoint(function.addBasicBlock())
  let array_type = ctx.getArrayType(ctx.getPtrTy(), 1)
  let inserted = builder.createInsertValue(ctx.getUndef(array_type), root, 0)
  inspect(inserted.asValueEnum() is ConstantArray(_), content="true")
  let extracted = builder.createExtractValue(inserted, 0)
  inspect(extracted.asValueEnum() is GlobalVariable(_), content="true")
  let selected = builder.createSelect(ctx.getConstTrue(), immutable, root)
  inspect(selected.asValueEnum() is GlobalConstant(_), content="true")
  let bitcast = builder.createBitCast(root, ctx.getPtrTy())
  inspect(bitcast.asValueEnum() is GlobalVariable(_), content="true")
  let nested = ctx.getConstStruct([ctx.getConstArray(ctx.getPtrTy(), [root])])
  let inner = builder.createExtractValue(nested, 0)
  inspect(inner.asValueEnum() is ConstantArray(_), content="true")
  inspect(inner.getType().to_string(), content="[1 x ptr]")
  let scalar = builder.createExtractValue(
    ctx.getConstStruct([ctx.getConstInt32(42)]),
    0,
  )
  inspect(scalar.asValueEnum() is ConstantInt(_), content="true")
  inspect(scalar.getType().to_string(), content="i32")
  let selected_aggregate = builder.createSelect(
    ctx.getConstTrue(),
    nested,
    nested,
  )
  inspect(selected_aggregate.asValueEnum() is ConstantStruct(_), content="true")
  let vector = ctx.getConstVector([root])
  let selected_vector = builder.createSelect(ctx.getConstTrue(), vector, vector)
  inspect(selected_vector.asValueEnum() is ConstantVector(_), content="true")
  let pointer = builder.createExtractValue(
    ctx.getConstStruct([ctx.getConstPointerNull(ctx.getPtrTy())]),
    0,
  )
  inspect(pointer.asValueEnum() is ConstantPointerNull(_), content="true")
  builder.createRetVoid() |> ignore
  mod.verify()
}

///|
test "constant expressions retain global dependencies through arithmetic" {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("expressions")
  let data = mod.addGlobalVariable(ctx.getArrayType(ctx.getInt8Ty(), 4), "data")
  let function = mod.addFunction(ctx.getFunctionType(ctx.getVoidTy(), []), "f")
  let builder = ctx.createBuilder()
  builder.setInsertPoint(function.addBasicBlock())
  let address = builder.createGEP(data, ctx.getArrayType(ctx.getInt8Ty(), 4), [
    ctx.getConstInt32(0),
    ctx.getConstInt32(1),
  ])
  inspect(address.asValueEnum() is ConstantExpr(_), content="true")
  let integer = builder.createPtrToInt(address, ctx.getInt64Ty())
  inspect(integer.asValueEnum() is ConstantExpr(_), content="true")
  let plus = builder.createAdd(integer, ctx.getConstInt64(1))
  inspect(plus.asValueEnum() is ConstantExpr(_), content="true")
  let restored = builder.createIntToPtr(plus)
  inspect(restored.asValueEnum() is ConstantExpr(_), content="true")
  guard restored.tryAsConstant() is Some(constant) else {
    fail("expected address constant")
  }
  mod.addGlobalConstant(ctx.getPtrTy(), "address", constant) |> ignore
  let other = ctx.addModule("other")
  assert_builder_error(
    () => other.addGlobalConstant(ctx.getPtrTy(), "invalid", constant),
    e => e is @IR.ValueOwnerError::ModuleMismatch,
  )
  builder.createRetVoid() |> ignore
  mod.verify()
  inspect(
    constant,
    content=(
      #|ptr inttoptr (i64 add (i64 ptrtoint (ptr getelementptr ([4 x i8], ptr @data, i32 0, i32 1) to i64), i64 1) to ptr)
    ),
  )
}

///|
test "builder rejects foreign owners before folding or insertion" {
  let ctx = @IR.Context::new()
  let a = ctx.addModule("a")
  let b = ctx.addModule("b")
  let x = a.addGlobalVariable(ctx.getInt32Ty(), "x")
  let y = b.addGlobalVariable(ctx.getInt32Ty(), "y")
  let nested = ctx.getConstStruct([y])
  let builder = ctx.createBuilder()
  let function = a.addFunction(ctx.getFunctionType(ctx.getVoidTy(), []), "f")
  let block = function.addBasicBlock()
  builder.setInsertPoint(block)
  assert_builder_error(() => builder.createSelect(ctx.getConstTrue(), x, y), e => {
    e is @IR.ValueOwnerError::ModuleMismatch
  })
  assert_builder_error(() => builder.createExtractValue(nested, 0), e => {
    e is @IR.ValueOwnerError::ModuleMismatch
  })
  assert_builder_error(
    () => builder.createInsertValue(ctx.getUndef(nested.getType()), y, 0),
    e => e is @IR.ValueOwnerError::ModuleMismatch,
  )
  assert_builder_error(() => builder.createPtrToInt(y, ctx.getInt64Ty()), e => {
    e is @IR.ValueOwnerError::ModuleMismatch
  })
  assert_builder_error(
    () => builder.createGEP(y, ctx.getInt32Ty(), [ctx.getConstInt32(0)]),
    e => e is @IR.ValueOwnerError::ModuleMismatch,
  )
  let other = @IR.Context::new()
  assert_builder_error(() => builder.createSelect(other.getConstTrue(), x, x), e => {
    e is @IR.ValueOwnerError::ContextMismatch
  })
  assert_builder_error(() => builder.createBitCast(x, other.getPtrTy()), e => {
    e is @IR.ValueOwnerError::ContextMismatch
  })
  inspect(block.getFirstInst() is None, content="true")
  builder.createRetVoid() |> ignore
  a.verify()
  b.verify()
}

///|
test "JIT follows a statically initialized root address table" {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("root_table_execution")
  let root = mod.addGlobalVariable(
    ctx.getInt32Ty(),
    "root",
    initializer=ctx.getConstInt32(42),
  )
  let initializer = ctx.getConstArray(ctx.getPtrTy(), [root])
  let table = mod.addGlobalConstant(initializer.getType(), "roots", initializer)
  let function = mod.addFunction(
    ctx.getFunctionType(ctx.getInt32Ty(), []),
    "read_root",
  )
  let builder = ctx.createBuilder()
  builder.setInsertPoint(function.addBasicBlock())
  let element = builder.createGEP(table, initializer.getType(), [
    ctx.getConstInt32(0),
    ctx.getConstInt32(0),
  ])
  let address = builder.createLoad(ctx.getPtrTy(), element)
  let value = builder.createLoad(ctx.getInt32Ty(), address)
  builder.createRet(value) |> ignore
  mod.verify()
  let jit = @JIT.LLJIT::host()
  jit.addModule(mod)
  let read : FuncRef[() -> Int] = jit.lookup("read_root").unsafeToFuncRef()
  inspect(read(), content="42")
  jit.close()
}
