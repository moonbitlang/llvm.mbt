///|
using @IR {trait Type}

///|
fn assert_integer_primitive(ty : &Type, expected_width : Int) -> Unit raise {
  guard ty.tryAsPrimitiveType() is Some(primitive) else {
    fail("expected integer type to implement PrimitiveType")
  }
  assert_eq(primitive.getBitWidth(), expected_width)
  guard ty.tryAsPrimitiveTypeEnum() is Some(primitive_enum) else {
    fail("expected integer PrimitiveTypeEnum")
  }
  let actual_width = match primitive_enum {
    Int1Type(_) => 1
    Int8Type(_) => 8
    Int16Type(_) => 16
    Int32Type(_) => 32
    Int64Type(_) => 64
    _ => fail("expected integer PrimitiveTypeEnum constructor")
  }
  assert_eq(actual_width, expected_width)
}

///|
fn assert_aggregate_classification(ty : &Type, expected : Bool) -> Unit raise {
  assert_eq(ty.isAggregateType(), expected)
  assert_eq(ty.tryAsAggregateType() is Some(_), expected)
  assert_eq(ty.tryAsAggregateTypeEnum() is Some(_), expected)
}

///|
test "integer Type downcasts to PrimitiveType" {
  let context = Context::new()
  assert_integer_primitive(context.getInt1Ty(), 1)
  assert_integer_primitive(context.getInt8Ty(), 8)
  assert_integer_primitive(context.getInt16Ty(), 16)
  assert_integer_primitive(context.getInt32Ty(), 32)
  assert_integer_primitive(context.getInt64Ty(), 64)
}

///|
test "LLVM aggregate types exclude vectors" {
  let context = Context::new()
  let i32_type = context.getInt32Ty()
  assert_aggregate_classification(context.getStructType([i32_type]), true)
  assert_aggregate_classification(context.getArrayType(i32_type, 4), true)
  assert_aggregate_classification(
    context.getFixedVectorType(i32_type, 4),
    false,
  )
  assert_aggregate_classification(
    context.getScalableVectorType(i32_type, 4),
    false,
  )
}

///|
test "insertvalue and extractvalue reject vector operands" {
  let context = Context::new()
  let mod = context.addModule("vector_is_not_aggregate")
  let builder = context.createBuilder()
  let i32_type = context.getInt32Ty()
  let vector_type = context.getFixedVectorType(i32_type, 4)
  let function_type = context.getFunctionType(context.getVoidTy(), [
    vector_type, i32_type,
  ])
  let function = mod.addFunction(function_type, "reject_vector")
  let block = function.addBasicBlock(name="entry")
  guard function.getArg(0) is Some(vector) else {
    fail("expected vector argument")
  }
  guard function.getArg(1) is Some(element) else {
    fail("expected element argument")
  }
  builder.setInsertPoint(block)
  assert_builder_error(() => builder.createExtractValue(vector, 0), error => {
    error is BuilderError::ValueTypeError(_)
  })
  assert_builder_error(() => builder.createInsertValue(vector, element, 0), error => {
    error is BuilderError::ValueTypeError(_)
  })
}
