///|
using @IR {type TypeEnum, trait FPType, trait IntegerType, trait Type}

///|
fn type_enum_index(ty : TypeEnum) -> Int {
  match ty {
    HalfType(_) => 0
    BFloatType(_) => 1
    FloatType(_) => 2
    DoubleType(_) => 3
    FP128Type(_) => 4
    Int1Type(_) => 5
    Int8Type(_) => 6
    Int16Type(_) => 7
    Int32Type(_) => 8
    Int64Type(_) => 9
    VoidType(_) => 10
    LabelType(_) => 11
    MetadataType(_) => 12
    TokenType(_) => 13
    FunctionType(_) => 14
    StructType(_) => 15
    ArrayType(_) => 16
    VectorType(_) => 17
    ScalableVectorType(_) => 18
    PointerType(_) => 19
  }
}

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
test "TypeEnum covers every public type class" {
  let context = Context::new()
  let i8_type = context.getInt8Ty()
  let i16_type = context.getInt16Ty()
  let i32_type = context.getInt32Ty()
  let i64_type = context.getInt64Ty()
  let float_type = context.getFloatTy()
  let pointer_type = context.getPtrTy()
  let types : Array[&Type] = [
    context.getHalfTy(),
    context.getBFloatTy(),
    float_type,
    context.getDoubleTy(),
    context.getFP128Ty(),
    context.getInt1Ty(),
    i8_type,
    i16_type,
    i32_type,
    i64_type,
    context.getVoidTy(),
    context.getLabelTy(),
    context.getMetadataTy(),
    context.getTokenTy(),
    context.getFunctionType(i32_type, [i8_type, pointer_type]),
    context.getStructType([i32_type, context.getDoubleTy()]),
    context.getArrayType(i16_type, 3),
    context.getFixedVectorType(float_type, 4),
    context.getScalableVectorType(i64_type, 2),
    pointer_type,
  ]
  for index, ty in types {
    let type_enum = ty.asTypeEnum()
    assert_eq(type_enum_index(type_enum), index)
    let recovered = type_enum.asTypeClass()
    assert_true(recovered.asTypeEnum() == type_enum)
    assert_true(recovered.getContext() == context)
  }
  debug_inspect(
    types.map(ty => ty.to_string()),
    content=(
      #|[
      #|  "half",
      #|  "bfloat",
      #|  "float",
      #|  "double",
      #|  "fp128",
      #|  "i1",
      #|  "i8",
      #|  "i16",
      #|  "i32",
      #|  "i64",
      #|  "void",
      #|  "label",
      #|  "metadata",
      #|  "token",
      #|  "i32 (i8, ptr)",
      #|  "{ i32, double }",
      #|  "[3 x i16]",
      #|  "<4 x float>",
      #|  "<vscale x 2 x i64>",
      #|  "ptr",
      #|]
    ),
  )
}

///|
test "IntegerType enums widths and extensions round trip" {
  let context = Context::new()
  let types : Array[&IntegerType] = [
    context.getInt1Ty(),
    context.getInt8Ty(),
    context.getInt16Ty(),
    context.getInt32Ty(),
    context.getInt64Ty(),
  ]
  let expected_widths = [1, 8, 16, 32, 64]
  let expected_extensions : Array[Int?] = [
    None,
    Some(16),
    Some(32),
    Some(64),
    None,
  ]
  for index, ty in types {
    let integer_enum = ty.asIntegerTypeEnum()
    assert_eq(ty.getBitWidth(), expected_widths[index])
    assert_eq(
      integer_enum.getBitWidth(),
      expected_widths[index].reinterpret_as_uint(),
    )
    assert_true(
      integer_enum.asTypeClass().tryAsIntTypeEnum() == Some(integer_enum),
    )
    let extended_width = match ty.getExtendedType() {
      Some(extended) => Some(extended.getBitWidth())
      None => None
    }
    assert_eq(extended_width, expected_extensions[index])
  }
}

///|
test "FPType enums widths and mantissas round trip" {
  let context = Context::new()
  let types : Array[&FPType] = [
    context.getHalfTy(),
    context.getBFloatTy(),
    context.getFloatTy(),
    context.getDoubleTy(),
    context.getFP128Ty(),
  ]
  let expected_widths = [16, 16, 32, 64, 128]
  let expected_mantissas = [11U, 8U, 24U, 53U, 113U]
  for index, ty in types {
    let fp_enum = ty.asFPTypeEnum()
    assert_eq(ty.getBitWidth(), expected_widths[index])
    assert_eq(ty.getFPMantissaWidth(), expected_mantissas[index])
    assert_eq(fp_enum.getFPMantissaWidth(), expected_mantissas[index])
    assert_true(fp_enum.asTypeClass().tryAsFPTypeEnum() == Some(fp_enum))
  }
}

///|
test "Type subclass downcasts cover positive and negative cases" {
  let context = Context::new()
  let primitive_types : Array[&Type] = [
    context.getHalfTy(),
    context.getBFloatTy(),
    context.getFloatTy(),
    context.getDoubleTy(),
    context.getFP128Ty(),
    context.getInt1Ty(),
    context.getInt8Ty(),
    context.getInt16Ty(),
    context.getInt32Ty(),
    context.getInt64Ty(),
  ]
  for ty in primitive_types {
    assert_true(ty.tryAsPrimitiveType() is Some(_))
    assert_true(ty.tryAsPrimitiveTypeEnum() is Some(_))
  }
  let i32_type = context.getInt32Ty()
  let aggregate_types : Array[&Type] = [
    context.getStructType([i32_type]),
    context.getArrayType(i32_type, 2),
  ]
  for ty in aggregate_types {
    assert_true(ty.tryAsAggregateType() is Some(_))
    assert_true(ty.tryAsAggregateTypeEnum() is Some(_))
  }
  let abstract_types : Array[&Type] = [
    context.getVoidTy(),
    context.getLabelTy(),
    context.getMetadataTy(),
    context.getTokenTy(),
    context.getFunctionType(context.getVoidTy(), []),
  ]
  for ty in abstract_types {
    assert_true(ty.tryAsAbstractType() is Some(_))
    assert_true(ty.tryAsAbstractTypeEnum() is Some(_))
  }
  let pointer_type : &Type = context.getPtrTy()
  assert_true(pointer_type.tryAsIntType() is None)
  assert_true(pointer_type.tryAsIntTypeEnum() is None)
  assert_true(pointer_type.tryAsFPType() is None)
  assert_true(pointer_type.tryAsFPTypeEnum() is None)
  assert_true(pointer_type.tryAsPrimitiveType() is None)
  assert_true(pointer_type.tryAsPrimitiveTypeEnum() is None)
  assert_true(pointer_type.tryAsAggregateType() is None)
  assert_true(pointer_type.tryAsAggregateTypeEnum() is None)
  assert_true(pointer_type.tryAsAbstractType() is None)
  assert_true(pointer_type.tryAsAbstractTypeEnum() is None)
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
