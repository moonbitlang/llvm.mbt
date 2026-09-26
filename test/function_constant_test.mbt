///|
test "function addresses form static callable descriptors and folded constants" {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("callable_descriptors")
  let signature = ctx.getFunctionType(ctx.getVoidTy(), [ctx.getPtrTy()])
  let entry = mod.addFunction(signature, "entry")
  let drop = mod.addFunction(signature, "drop")
  let descriptor = ctx.getConstStruct([entry, drop])
  mod.addGlobalConstant(
    descriptor.getType(),
    "descriptor",
    descriptor,
    linkage=PrivateLinkage,
  )
  |> ignore
  let ordinary = ctx.getConstStruct([
    entry,
    ctx.getConstPointerNull(ctx.getPtrTy()),
  ])
  mod.addGlobalConstant(
    ordinary.getType(),
    "ordinary",
    ordinary,
    linkage=PrivateLinkage,
  )
  |> ignore
  let builder = ctx.createBuilder()
  let reader = mod.addFunction(
    ctx.getFunctionType(ctx.getPtrTy(), []),
    "reader",
  )
  builder.setInsertPoint(reader.addBasicBlock(name="entry"))
  let address = builder.createExtractValue(descriptor, 0)
  inspect(address.tryAsConstantEnum() is Some(Function(_)), content="true")
  inspect(address.getType().to_string(), content="ptr")
  inspect(entry.getType().to_string(), content="void (ptr)")
  builder.createRet(address) |> ignore
  mod.verify()
  inspect(
    mod,
    content=(
      #|; ModuleID = 'callable_descriptors'
      #|source_filename = "callable_descriptors"
      #|
      #|@descriptor = private constant { ptr, ptr } { ptr @entry, ptr @drop }
      #|@ordinary = private constant { ptr, ptr } { ptr @entry, ptr null }
      #|
      #|declare void @entry(ptr)
      #|
      #|declare void @drop(ptr)
      #|
      #|define ptr @reader() {
      #|entry:
      #|  ret ptr @entry
      #|}
      #|
    ),
  )
}

///|
test "function address aggregates reject foreign modules and contexts" {
  let ctx = @IR.Context::new()
  let other = @IR.Context::new()
  let a = ctx.addModule("a")
  let b = ctx.addModule("b")
  let signature = ctx.getFunctionType(ctx.getVoidTy(), [])
  let entry = a.addFunction(signature, "entry")
  let foreign = b.addFunction(signature, "foreign")
  let nested = ctx.getConstStruct([ctx.getConstArray(ctx.getPtrTy(), [entry])])
  assert_builder_error(() => ctx.getConstStruct([entry, foreign]), e => {
    e is @IR.ValueOwnerError::ModuleMismatch
  })
  assert_builder_error(
    () => ctx.getConstArray(ctx.getPtrTy(), [entry, foreign]),
    e => e is @IR.ValueOwnerError::ModuleMismatch,
  )
  assert_builder_error(() => ctx.getConstVector([entry, foreign]), e => {
    e is @IR.ValueOwnerError::ModuleMismatch
  })
  assert_builder_error(() => other.getConstStruct([entry]), e => {
    e is @IR.ValueOwnerError::ContextMismatch
  })
  assert_builder_error(
    () => b.addGlobalConstant(nested.getType(), "bad", nested),
    e => e is @IR.ValueOwnerError::ModuleMismatch,
  )
  a.addGlobalConstant(nested.getType(), "valid", nested) |> ignore
  a.verify()
  b.verify()
}
