///|
using @IR {type ConstantEnum, trait Value}

///|
fn assert_value_type_and_context(
  name : String,
  value : &Value,
  expected_type : &Type,
  expected_context : Context,
) -> Unit raise {
  assert_true(
    value.getType().asTypeEnum() == expected_type.asTypeEnum(),
    msg="\{name} type",
  )
  assert_true(value.getContext() == expected_context, msg="\{name} context")
}

///|
fn assert_constant_downcast(
  value : &Value,
  matches : (ConstantEnum) -> Bool,
) -> Unit raise {
  guard value.tryAsConstant() is Some(constant) else {
    fail("expected Value::tryAsConstant to succeed")
  }
  assert_true(matches(constant.asConstantEnum()))
  guard value.tryAsConstantEnum() is Some(constant_enum) else {
    fail("expected Value::tryAsConstantEnum to succeed")
  }
  assert_true(matches(constant_enum))
}

///|
test "Value type context and concrete classification" {
  let context = Context::new()
  let mod = context.addModule("value_classification")
  let i32_type = context.getInt32Ty()
  let function_type = context.getFunctionType(i32_type, [i32_type])
  let function = mod.addFunction(function_type, "classify")
  guard function.getArg(0) is Some(argument) else {
    fail("expected function argument")
  }
  let block = function.addBasicBlock(name="entry")
  let builder = context.createBuilder()
  builder.setInsertPoint(block)
  let sum = builder.createAdd(argument, context.getConstInt32(1), name="sum")
  let ret = builder.createRet(sum)
  let global_variable = mod.addGlobalVariable(i32_type, "variable")
  let global_constant = mod.addGlobalConstant(
    i32_type,
    "constant",
    context.getConstInt32(2),
  )
  assert_value_type_and_context(
    "function",
    function,
    context.getPtrTy(),
    context,
  )
  assert_value_type_and_context(
    "global variable",
    global_variable,
    context.getPtrTy(),
    context,
  )
  assert_value_type_and_context(
    "global constant",
    global_constant,
    context.getPtrTy(),
    context,
  )
  assert_value_type_and_context("argument", argument, i32_type, context)
  assert_true(block.getType().asTypeEnum() is LabelType(_))
  assert_true(block.getContext() == context)
  assert_value_type_and_context("sum", sum, i32_type, context)
  assert_value_type_and_context("return", ret, context.getVoidTy(), context)
  assert_true(function.asValueEnum() is Function(_))
  assert_true(global_variable.asValueEnum() is GlobalVariable(_))
  assert_true(global_constant.asValueEnum() is GlobalConstant(_))
  assert_true(argument.asValueEnum() is Argument(_))
  assert_true(block.asValueEnum() is BasicBlock(_))
  assert_true(sum.asValueEnum() is BinaryInst(_))
  assert_true(ret.asValueEnum() is ReturnInst(_))
}

///|
test "Value constant downcasts cover every ConstantEnum" {
  let context = Context::new()
  let i32_type = context.getInt32Ty()
  let integer = context.getConstInt32(1)
  let float = context.getConstFloat(1.5)
  let pointer_null = context.getConstPointerNull(context.getPtrTy())
  let array = context.getConstArray(i32_type, [integer])
  let vector = context.getConstVector([integer, context.getConstInt32(2)])
  let struct_constant = context.getConstStruct([integer, float])
  guard i32_type.sizeOf() is Some(expression) else {
    fail("expected sized integer type to produce ConstantExpr")
  }
  let undef = context.getUndef(i32_type)
  let poison = context.getPoision(i32_type)
  assert_constant_downcast(integer, value => value is ConstantInt(_))
  assert_constant_downcast(float, value => value is ConstantFP(_))
  assert_constant_downcast(pointer_null, value => {
    value is ConstantPointerNull(_)
  })
  assert_constant_downcast(array, value => value is ConstantArray(_))
  assert_constant_downcast(vector, value => value is ConstantVector(_))
  assert_constant_downcast(struct_constant, value => value is ConstantStruct(_))
  assert_constant_downcast(expression, value => value is ConstantExpr(_))
  assert_constant_downcast(undef, value => value is UndefValue(_))
  assert_constant_downcast(poison, value => value is PoisonValue(_))
  let mod = context.addModule("non_constant")
  let function_type = context.getFunctionType(context.getVoidTy(), [])
  let function = mod.addFunction(function_type, "function")
  assert_true(function.tryAsConstant() is None)
  assert_true(function.tryAsConstantEnum() is None)
}

///|
test "Value names support Unicode and reject embedded NUL" {
  let context = Context::new()
  let mod = context.addModule("value_names")
  let i32_type = context.getInt32Ty()
  let function_type = context.getFunctionType(i32_type, [i32_type])
  let function = mod.addFunction(function_type, "identity")
  guard function.getArg(0) is Some(argument) else {
    fail("expected function argument")
  }
  assert_true(argument.getValueName() is None)
  argument.setValueName("参数_λ")
  debug_inspect(
    argument.getValueName(),
    content=(
      #|Some("参数_λ")
    ),
  )
  assert_contains_nul(() => argument.setValueName("invalid\u{0000}name"))
}

///|
test "Value RAUW updates uses without invalidating arguments" {
  let context = Context::new()
  let mod = context.addModule("value_rauw")
  let i32_type = context.getInt32Ty()
  let function_type = context.getFunctionType(i32_type, [i32_type, i32_type])
  let function = mod.addFunction(function_type, "replace")
  guard function.getArg(0) is Some(source) else {
    fail("expected source argument")
  }
  guard function.getArg(1) is Some(replacement) else {
    fail("expected replacement argument")
  }
  let block = function.addBasicBlock(name="entry")
  let builder = context.createBuilder()
  builder.setInsertPoint(block)
  let sum = builder.createAdd(source, source, name="sum")
  builder.createRet(sum) |> ignore
  source.replaceAllUsesWith(replacement)
  inspect(
    function,
    content=(
      #|define i32 @replace(i32 %0, i32 %1) {
      #|entry:
      #|  %sum = add i32 %1, %1
      #|  ret i32 %sum
      #|}
      #|
    ),
  )
  assert_true(source.asValueEnum() is Argument(_))
  assert_true(source.getType().asTypeEnum() == i32_type.asTypeEnum())
}
