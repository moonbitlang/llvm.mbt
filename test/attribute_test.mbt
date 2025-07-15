
test "Add and Remove Function Attributes" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()

  let i32_ty = ctx.getInt32Ty()
  let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])

  let fval = mod.addFunction(fty, "add_demo")
  let bb = fval.appendBasicBlock(name="entry")
  let arg1 = fval.getArg(0).unwrap()
  let arg2 = fval.getArg(1).unwrap()

  builder.setInsertPoint(bb)
  let add = builder.createAdd(arg1, arg2, name="sum")
  let _ = builder.createRet(add)

  fval.addFnAttr(NoInline)
  fval.addFnAttr(AlwaysInline)
  fval.addFnAttr(AllocSize(32))
  fval.addFnAttr(NoUnwind)
  fval.addFnAttr(NoAlias)

  assert_eq(fval.countFnAttrs(), 5)

  let expect = 
    #|; Function Attrs: alwaysinline noalias noinline nounwind allocsize(0,32)
    #|define i32 @add_demo(i32 %0, i32 %1) #0 {
    #|entry:
    #|  %sum = add i32 %0, %1
    #|  ret i32 %sum
    #|}
    #|
  inspect(fval, content=expect)

  fval.removeFnAttr(AlwaysInline)

  let expect = 
    #|; Function Attrs: noalias noinline nounwind allocsize(0,32)
    #|define i32 @add_demo(i32 %0, i32 %1) #0 {
    #|entry:
    #|  %sum = add i32 %0, %1
    #|  ret i32 %sum
    #|}
    #|
  inspect(fval, content=expect)
}

test "Add and Remove Function Parameter Attributes" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()

  let i32_ty = ctx.getInt32Ty()
  let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])

  let fval = mod.addFunction(fty, "add_demo")
  let bb = fval.appendBasicBlock(name="entry")
  let arg1 = fval.getArg(0).unwrap()
  let arg2 = fval.getArg(1).unwrap()

  builder.setInsertPoint(bb)
  let add = builder.createAdd(arg1, arg2, name="sum")
  let _ = builder.createRet(add)

  arg1.addAttr(NonNull)
  arg1.addAttr(InReg)
  arg2.addAttr(NoAlias)

  let expect =
    #|define i32 @add_demo(i32 inreg nonnull %0, i32 noalias %1) {
    #|entry:
    #|  %sum = add i32 %0, %1
    #|  ret i32 %sum
    #|}
    #|

  inspect(fval, content=expect)
}

test "Add and Remove Function Return Value Attributes" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()

  let i32_ty = ctx.getInt32Ty()
  let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])

  let fval = mod.addFunction(fty, "add_demo")
  let bb = fval.appendBasicBlock(name="entry")
  let arg1 = fval.getArg(0).unwrap()
  let arg2 = fval.getArg(1).unwrap()

  builder.setInsertPoint(bb)
  let add = builder.createAdd(arg1, arg2, name="sum")
  let _ = builder.createRet(add)

  fval.addRetAttr(NoAlias)
  fval.addRetAttr(NonNull)

  let expect =
    #|define noalias nonnull i32 @add_demo(i32 %0, i32 %1) {
    #|entry:
    #|  %sum = add i32 %0, %1
    #|  ret i32 %sum
    #|}
    #|

  inspect(fval, content=expect)

  fval.removeRetAttr(NoAlias)

  let expect =
    #|define nonnull i32 @add_demo(i32 %0, i32 %1) {
    #|entry:
    #|  %sum = add i32 %0, %1
    #|  ret i32 %sum
    #|}
    #|

  inspect(fval, content=expect)
}
