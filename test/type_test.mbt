///|
using @IR {
  type AddressSpace,
  type PointerType,
  type SetBodyForNonOpaqueStruct,
  type TypeEnum,
  trait FPType,
  trait IntegerType,
  trait Type,
}

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
test "Type predicates distinguish scalar aggregate and abstract types" {
  let context = Context::new()
  let i32_type = context.getInt32Ty()
  let float_type = context.getFloatTy()
  let pointer_type = context.getPtrTy()
  let fixed_vector_type = context.getFixedVectorType(i32_type, 4)
  let scalable_vector_type = context.getScalableVectorType(i32_type, 4)
  let array_type = context.getArrayType(i32_type, 2)
  let struct_type = context.getStructType([i32_type])
  let empty_struct_type = context.getStructType([], name="EmptyPredicate")
  let function_type = context.getFunctionType(context.getVoidTy(), [])
  let void_type = context.getVoidTy()
  let types : Array[&Type] = [
    i32_type, float_type, pointer_type, fixed_vector_type, scalable_vector_type,
    array_type, struct_type, empty_struct_type, function_type, void_type,
  ]
  let expected_first_class = [
    true, true, true, true, true, true, true, true, false, false,
  ]
  let expected_aggregate = [
    false, false, false, false, false, true, true, true, false, false,
  ]
  let expected_sized = [
    true, true, true, true, true, true, true, true, false, false,
  ]
  let expected_empty = [
    false, false, false, false, false, false, false, true, false, false,
  ]
  let expected_valid_gep = [
    true, true, true, true, true, true, true, true, false, false,
  ]
  for index, ty in types {
    assert_eq(ty.isFirstClassType(), expected_first_class[index])
    assert_eq(ty.isAggregateType(), expected_aggregate[index])
    assert_eq(ty.isSized(), expected_sized[index])
    assert_eq(ty.isEmptyTy(), expected_empty[index])
    assert_eq(ty.isValidGEPType(), expected_valid_gep[index])
  }
  let single_value_types : Array[&Type] = [
    i32_type, float_type, pointer_type, fixed_vector_type, scalable_vector_type,
  ]
  for ty in single_value_types {
    assert_true(ty.isSingleValueType())
  }
  assert_false(array_type.isSingleValueType())
  assert_false(struct_type.isSingleValueType())
  assert_false(function_type.isSingleValueType())
  assert_false(void_type.isSingleValueType())
  assert_true(context.getHalfTy().is16bitFPTy())
  assert_true(context.getBFloatTy().is16bitFPTy())
  assert_false(float_type.is16bitFPTy())
  assert_true(float_type.isIEEELikeFPTy())
  assert_true(float_type.isFloatingPointTy())
  assert_true(context.getFixedVectorType(float_type, 2).isFPOrFPVectorTy())
  assert_true(context.getScalableVectorType(float_type, 2).isFPOrFPVectorTy())
  assert_true(fixed_vector_type.isIntOrIntVectorTy())
  assert_true(scalable_vector_type.isIntOrIntVectorTy())
  assert_true(i32_type.isIntOrPtrTy())
  assert_true(pointer_type.isIntOrPtrTy())
  assert_true(context.getFixedVectorType(pointer_type, 2).isPtrOrPtrVectorTy())
  assert_true(
    context.getScalableVectorType(pointer_type, 2).isPtrOrPtrVectorTy(),
  )
  assert_eq(fixed_vector_type.getScalarType().to_string(), "i32")
  assert_eq(scalable_vector_type.getScalarType().to_string(), "i32")
  assert_eq(i32_type.getScalarType().to_string(), "i32")
}

///|
test "Type sizeOf distinguishes sized and unsized types" {
  let context = Context::new()
  let i32_type = context.getInt32Ty()
  guard i32_type.sizeOf() is Some(size_expression) else {
    fail("expected sized type to produce size expression")
  }
  assert_true(size_expression.asValueEnum() is ConstantExpr(_))
  inspect(
    size_expression,
    content="i64 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i64)",
  )
  assert_true(context.getArrayType(i32_type, 4).sizeOf() is Some(_))
  assert_true(context.getStructType([i32_type]).sizeOf() is Some(_))
  assert_true(context.getVoidTy().sizeOf() is None)
  assert_true(context.getFunctionType(context.getVoidTy(), []).sizeOf() is None)
}

///|
test "FunctionType exposes parameters varargs and bounds" {
  let context = Context::new()
  let i8_type = context.getInt8Ty()
  let i32_type = context.getInt32Ty()
  let pointer_type = context.getPtrTy()
  let function_type = context.getFunctionType(
    i32_type,
    [i8_type, pointer_type],
    isVarArg=true,
  )
  assert_true(function_type.isVarArg())
  assert_true(
    function_type.getReturnType().asTypeEnum() == i32_type.asTypeEnum(),
  )
  assert_eq(function_type.numOfParams(), 2)
  assert_eq(function_type.getNumParams(), 2)
  debug_inspect(
    function_type.params().map(ty => ty.to_string()),
    content=(
      #|["i8", "ptr"]
    ),
  )
  assert_true(function_type.getParamType(-1) is None)
  assert_eq(function_type.getParamType(0).map(ty => ty.to_string()), Some("i8"))
  assert_eq(
    function_type.getParamType(1).map(ty => ty.to_string()),
    Some("ptr"),
  )
  assert_true(function_type.getParamType(2) is None)
  let fixed_type = context.getFunctionType(context.getVoidTy(), [])
  assert_false(fixed_type.isVarArg())
}

///|
test "StructType exposes shape lookup and setBody errors" {
  let context = Context::new()
  let i8_type = context.getInt8Ty()
  let i32_type = context.getInt32Ty()
  let literal = context.getStructType([i8_type, i32_type])
  let packed = context.getStructType([i8_type, i32_type], isPacked=true)
  let named = context.getStructType([i32_type], name="NamedShape")
  let empty_named = context.getStructType([], name="EmptyShape")
  assert_true(literal.isLiteral())
  assert_false(literal.isOpaque())
  assert_false(literal.isPacked())
  assert_true(packed.isLiteral())
  assert_true(packed.isPacked())
  assert_false(named.isLiteral())
  assert_false(named.isOpaque())
  assert_false(empty_named.isOpaque())
  assert_true(empty_named.isEmptyTy())
  assert_eq(literal.numOfElements(), 2)
  assert_true(literal.getElementType(-1) is None)
  assert_eq(literal.getElementType(0).map(ty => ty.to_string()), Some("i8"))
  assert_eq(literal.getElementType(1).map(ty => ty.to_string()), Some("i32"))
  assert_true(literal.getElementType(2) is None)
  debug_inspect(
    literal.elements().map(ty => ty.to_string()),
    content=(
      #|["i8", "i32"]
    ),
  )
  guard context.getStructTypeByName("NamedShape") is Some(found) else {
    fail("expected named struct lookup")
  }
  assert_true(found == named)
  assert_true(context.getStructTypeByName("MissingShape") is None)
  inspect(literal, content="{ i8, i32 }")
  inspect(packed, content="<{ i8, i32 }>")
  inspect(named, content="%NamedShape = type { i32 }")
  try literal.setBody([i32_type]) catch {
    SetBodyForNonOpaqueStruct::SetBodyForNonOpaqueStruct(message) =>
      assert_eq(message, "Cannot set body for non-opaque struct")
    _ => fail("expected SetBodyForNonOpaqueStruct")
  } noraise {
    _ => fail("expected non-opaque setBody to fail")
  }
}

///|
test "opaque StructType completes its body once" {
  let context = Context::new()
  let i8_type = context.getInt8Ty()
  let i32_type = context.getInt32Ty()
  let opaque_type = context.getOpaqueStructType("OpaqueShape")
  assert_false(opaque_type.isLiteral())
  assert_true(opaque_type.isOpaque())
  assert_false(opaque_type.isSized())
  assert_true(opaque_type.sizeOf() is None)
  inspect(opaque_type, content="%OpaqueShape = type opaque")
  guard context.getStructTypeByName("OpaqueShape") is Some(found) else {
    fail("expected opaque named struct lookup")
  }
  assert_true(found == opaque_type)
  opaque_type.setBody([i8_type, i32_type], isPacked=true)
  assert_false(opaque_type.isOpaque())
  assert_true(opaque_type.isPacked())
  assert_true(opaque_type.isSized())
  assert_eq(opaque_type.numOfElements(), 2)
  inspect(opaque_type, content="%OpaqueShape = type <{ i8, i32 }>")
  try opaque_type.setBody([i32_type]) catch {
    SetBodyForNonOpaqueStruct::SetBodyForNonOpaqueStruct(message) =>
      assert_eq(message, "Cannot set body for non-opaque struct")
    _ => fail("expected SetBodyForNonOpaqueStruct")
  } noraise {
    _ => fail("expected a second setBody to fail")
  }
  assert_contains_nul(() => context.getOpaqueStructType("invalid\u{0000}name"))
}

///|
test "Array and vector types expose their element shape" {
  let context = Context::new()
  let i16_type = context.getInt16Ty()
  let array_type = context.getArrayType(i16_type, 3)
  let vector_type = context.getFixedVectorType(i16_type, 4)
  let scalable_type = context.getScalableVectorType(i16_type, 5)
  assert_eq(array_type.getElementCount(), 3)
  assert_true(array_type.getElementType().asTypeEnum() is Int16Type(_))
  assert_eq(vector_type.getElementCount(), 4)
  assert_true(vector_type.getElementType().asTypeEnum() is Int16Type(_))
  assert_eq(scalable_type.getElementCount(), 5)
  assert_true(scalable_type.getElementType().asTypeEnum() is Int16Type(_))
  guard array_type.tryAsAggregateType() is Some(aggregate_array) else {
    fail("expected ArrayType to implement AggregateType")
  }
  assert_eq(
    aggregate_array.getElementType(0).map(ty => ty.to_string()),
    Some("i16"),
  )
  assert_eq(
    aggregate_array.getElementType(2).map(ty => ty.to_string()),
    Some("i16"),
  )
  assert_true(aggregate_array.getElementType(-1) is None)
  assert_true(aggregate_array.getElementType(3) is None)
  let struct_type = context.getStructType([i16_type, vector_type])
  guard struct_type.tryAsAggregateType() is Some(aggregate_struct) else {
    fail("expected StructType to implement AggregateType")
  }
  assert_eq(
    aggregate_struct.getElementType(0).map(ty => ty.to_string()),
    Some("i16"),
  )
  assert_eq(
    aggregate_struct.getElementType(1).map(ty => ty.to_string()),
    Some("<4 x i16>"),
  )
  assert_true(aggregate_struct.getElementType(-1) is None)
  assert_true(aggregate_struct.getElementType(2) is None)
}

///|
test "PointerType exposes address spaces and loadable element rules" {
  let context = Context::new()
  let default_pointer = context.getPtrTy()
  let address_space = AddressSpace::new(3)
  let custom_pointer = context.getPtrTy(addressSpace=address_space)
  assert_true(default_pointer.getAddressSpace() == AddressSpace::default())
  assert_true(custom_pointer.getAddressSpace() == address_space)
  assert_true(PointerType::isLoadableOrStorableType(context.getInt32Ty()))
  assert_true(PointerType::isLoadableOrStorableType(default_pointer))
  assert_true(
    PointerType::isLoadableOrStorableType(
      context.getArrayType(context.getInt8Ty(), 2),
    ),
  )
  assert_false(
    PointerType::isLoadableOrStorableType(
      context.getFunctionType(context.getVoidTy(), []),
    ),
  )
  assert_false(PointerType::isLoadableOrStorableType(context.getVoidTy()))
  assert_false(PointerType::isLoadableOrStorableType(context.getLabelTy()))
  assert_false(PointerType::isLoadableOrStorableType(context.getMetadataTy()))
  assert_false(PointerType::isLoadableOrStorableType(context.getTokenTy()))
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

///|
test "insertvalue rejects Array aggregate bounds" {
  let context = Context::new()
  let mod = context.addModule("array_aggregate_bounds")
  let builder = context.createBuilder()
  let i32_type = context.getInt32Ty()
  let array_type = context.getArrayType(i32_type, 2)
  let function_type = context.getFunctionType(context.getVoidTy(), [
    array_type, i32_type,
  ])
  let function = mod.addFunction(function_type, "reject_array_bounds")
  let block = function.addBasicBlock(name="entry")
  guard function.getArg(0) is Some(array) else {
    fail("expected array argument")
  }
  guard function.getArg(1) is Some(element) else {
    fail("expected element argument")
  }
  builder.setInsertPoint(block)
  assert_builder_error(() => builder.createInsertValue(array, element, -1), error => {
    error is BuilderError::InValidArgument(_)
  })
  assert_builder_error(() => builder.createInsertValue(array, element, 2), error => {
    error is BuilderError::InValidArgument(_)
  })
}
