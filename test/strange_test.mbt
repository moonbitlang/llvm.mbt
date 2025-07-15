
//test {
//  let ctx = Context::new()
//  let mod = ctx.addModule("demo")
//  let builder = ctx.createBuilder()
//
//  let i32_ty = ctx.getInt32Ty()
//  let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
//
//  let fval = mod.addFunction(fty, "add_demo")
//  let bb = fval.appendBasicBlock(name="entry")
//  let arg1 = fval.getArg(0).unwrap()
//  let arg2 = fval.getArg(1).unwrap()
//
//  builder.setInsertPoint(bb)
//  let add = builder.createAdd(arg1, arg2, name="sum")
//  inspect(add, content = "  %sum = add i32 %0, %1")
//  assert_true(add.asValueEnum() is BinaryInst(_))
//
//  let one = ctx.getConstInt32(1)
//  let two = ctx.getConstInt32(2)
//  let three = builder.createAdd(one, two)
//  inspect(three, content = "i32 3")
//  assert_true(three.asValueEnum() is ConstantInt(_))
//}
