//=========================================================
// AggregateValue
//=========================================================

/////|
//pub trait AggregateValue: AnyValue {
//  as_aggregate_value_enum(Self) -> AggregateValueEnum
//}
//
/////|
//pub impl AggregateValue for ArrayValue with as_aggregate_value_enum(
//  self : ArrayValue
//) -> AggregateValueEnum {
//  AggregateValueEnum::ArrayValue(self)
//}
//
/////|
//pub impl AggregateValue for StructValue with as_aggregate_value_enum(
//  self : StructValue
//) -> AggregateValueEnum {
//  AggregateValueEnum::StructValue(self)
//}

//=========================================================
// AnyValue
//=========================================================

/////|
//pub trait AnyValue: AsValue + Show {
//  as_any_value_enum(Self) -> AnyValueEnum
//  get_type(Self) -> AnyTypeEnum = _
//}
//
/////|
//impl AnyValue with get_type(self) -> AnyTypeEnum {
//  self.as_any_value_enum().get_type()
//}
//
/////|
//pub impl AnyValue for IntValue with as_any_value_enum(self : IntValue) -> AnyValueEnum {
//  AnyValueEnum::IntValue(self)
//}
//
/////|
//pub impl AnyValue for FloatValue with as_any_value_enum(self : FloatValue) -> AnyValueEnum {
//  AnyValueEnum::FloatValue(self)
//}
//
/////|
//pub impl AnyValue for PointerValue with as_any_value_enum(self : PointerValue) -> AnyValueEnum {
//  AnyValueEnum::PointerValue(self)
//}
//
/////|
//pub impl AnyValue for InstructionValue with as_any_value_enum(
//  self : InstructionValue
//) -> AnyValueEnum {
//  AnyValueEnum::InstructionValue(self)
//}
//
/////|
//pub impl AnyValue for StructValue with as_any_value_enum(self : StructValue) -> AnyValueEnum {
//  AnyValueEnum::StructValue(self)
//}
//
/////|
//pub impl AnyValue for ArrayValue with as_any_value_enum(self : ArrayValue) -> AnyValueEnum {
//  AnyValueEnum::ArrayValue(self)
//}
//
/////|
//pub impl AnyValue for VectorValue with as_any_value_enum(self : VectorValue) -> AnyValueEnum {
//  AnyValueEnum::VectorValue(self)
//}
//
/////|
//pub impl AnyValue for PhiValue with as_any_value_enum(self : PhiValue) -> AnyValueEnum {
//  AnyValueEnum::PhiValue(self)
//}
//
/////|
//pub impl AnyValue for ScalableVectorValue with as_any_value_enum(
//  self : ScalableVectorValue
//) -> AnyValueEnum {
//  AnyValueEnum::ScalableVectorValue(self)
//}
//
/////|
//pub impl AnyValue for MetadataValue with as_any_value_enum(self : MetadataValue) -> AnyValueEnum {
//  AnyValueEnum::MetadataValue(self)
//}

//=========================================================
// BasicValue
//=========================================================

/////|
//pub trait BasicValue: AnyValue {
//  as_basic_value_enum(Self) -> BasicValueEnum
//  get_type(Self) -> BasicTypeEnum = _
//}
//
/////|
//impl BasicValue with get_type(self) -> BasicTypeEnum {
//  self.as_basic_value_enum().get_type()
//}
//
/////|
//pub impl BasicValue for IntValue with as_basic_value_enum(self : IntValue) -> BasicValueEnum {
//  BasicValueEnum::IntValue(self)
//}
//
/////|
//pub impl BasicValue for FloatValue with as_basic_value_enum(self : FloatValue) -> BasicValueEnum {
//  BasicValueEnum::FloatValue(self)
//}
//
/////|
//pub impl BasicValue for PointerValue with as_basic_value_enum(
//  self : PointerValue
//) -> BasicValueEnum {
//  BasicValueEnum::PointerValue(self)
//}
//
/////|
//pub impl BasicValue for StructValue with as_basic_value_enum(self : StructValue) -> BasicValueEnum {
//  BasicValueEnum::StructValue(self)
//}
//
/////|
//pub impl BasicValue for ArrayValue with as_basic_value_enum(self : ArrayValue) -> BasicValueEnum {
//  BasicValueEnum::ArrayValue(self)
//}
//
/////|
//pub impl BasicValue for VectorValue with as_basic_value_enum(self : VectorValue) -> BasicValueEnum {
//  BasicValueEnum::VectorValue(self)
//}
//
/////|
//pub impl BasicValue for ScalableVectorValue with as_basic_value_enum(
//  self : ScalableVectorValue
//) -> BasicValueEnum {
//  BasicValueEnum::ScalableVectorValue(self)
//}
//=========================================================
// BasicMetadataValue
//=========================================================

/////|
//pub trait BasicMetadataValue: AnyValue {
//  as_basic_metadata_value_enum(Self) -> BasicMetadataValueEnum
//}
//
/////|
//pub impl BasicMetadataValue for IntValue with as_basic_metadata_value_enum(
//  self : IntValue
//) -> BasicMetadataValueEnum {
//  BasicMetadataValueEnum::IntValue(self)
//}
//
/////|
//pub impl BasicMetadataValue for FloatValue with as_basic_metadata_value_enum(
//  self : FloatValue
//) -> BasicMetadataValueEnum {
//  BasicMetadataValueEnum::FloatValue(self)
//}
//
/////|
//pub impl BasicMetadataValue for PointerValue with as_basic_metadata_value_enum(
//  self : PointerValue
//) -> BasicMetadataValueEnum {
//  BasicMetadataValueEnum::PointerValue(self)
//}
//
/////|
//pub impl BasicMetadataValue for StructValue with as_basic_metadata_value_enum(
//  self : StructValue
//) -> BasicMetadataValueEnum {
//  BasicMetadataValueEnum::StructValue(self)
//}
//
/////|
//pub impl BasicMetadataValue for ArrayValue with as_basic_metadata_value_enum(
//  self : ArrayValue
//) -> BasicMetadataValueEnum {
//  BasicMetadataValueEnum::ArrayValue(self)
//}
//
/////|
//pub impl BasicMetadataValue for VectorValue with as_basic_metadata_value_enum(
//  self : VectorValue
//) -> BasicMetadataValueEnum {
//  BasicMetadataValueEnum::VectorValue(self)
//}
//
/////|
//pub impl BasicMetadataValue for ScalableVectorValue with as_basic_metadata_value_enum(
//  self : ScalableVectorValue
//) -> BasicMetadataValueEnum {
//  BasicMetadataValueEnum::ScalableVectorValue(self)
//}
//
/////|
//pub impl BasicMetadataValue for MetadataValue with as_basic_metadata_value_enum(
//  self : MetadataValue
//) -> BasicMetadataValueEnum {
//  BasicMetadataValueEnum::MetadataValue(self)
//}


//=========================================================
// AsType
//=========================================================

/////|
//pub trait AsType {
//  as_type(Self) -> TypeRef
//  as_type_ref(Self) -> @unsafe.LLVMTypeRef
//}
//
/////|
//pub impl AsType for TypeRef with as_type(self : TypeRef) -> TypeRef {
//  self
//}
//
/////|
//pub impl AsType for TypeRef with as_type_ref(self : TypeRef) -> @unsafe.LLVMTypeRef {
//  self.inner()
//}
//
/////|
//pub impl AsType for IntType with as_type(self : IntType) -> TypeRef {
//  self.ty
//}
//
/////|
//pub impl AsType for IntType with as_type_ref(self : IntType) -> @unsafe.LLVMTypeRef {
//  self.ty.as_type_ref()
//}
//
/////|
//pub impl AsType for FloatType with as_type(self : FloatType) -> TypeRef {
//  self.ty
//}
//
/////|
//pub impl AsType for FloatType with as_type_ref(self : FloatType) -> @unsafe.LLVMTypeRef {
//  self.ty.as_type_ref()
//}
//
/////|
//pub impl AsType for VoidType with as_type(self : VoidType) -> TypeRef {
//  self.ty
//}
//
/////|
//pub impl AsType for VoidType with as_type_ref(self : VoidType) -> @unsafe.LLVMTypeRef {
//  self.ty.as_type_ref()
//}
//
/////|
//pub impl AsType for PointerType with as_type(self : PointerType) -> TypeRef {
//  self.ty
//}
//
/////|
//pub impl AsType for PointerType with as_type_ref(self : PointerType) -> @unsafe.LLVMTypeRef {
//  self.ty.as_type_ref()
//}
//
/////|
//pub impl AsType for StructType with as_type(self : StructType) -> TypeRef {
//  self.ty
//}
//
/////|
//pub impl AsType for StructType with as_type_ref(self : StructType) -> @unsafe.LLVMTypeRef {
//  self.ty.as_type_ref()
//}
//
/////|
//pub impl AsType for FunctionType with as_type(self : FunctionType) -> TypeRef {
//  self.ty
//}
//
/////|
//pub impl AsType for FunctionType with as_type_ref(self : FunctionType) -> @unsafe.LLVMTypeRef {
//  self.ty.as_type_ref()
//}
//
/////|
//pub impl AsType for ArrayType with as_type(self : ArrayType) -> TypeRef {
//  self.ty
//}
//
/////|
//pub impl AsType for ArrayType with as_type_ref(self : ArrayType) -> @unsafe.LLVMTypeRef {
//  self.as_type_ref()
//}
//
/////|
//pub impl AsType for VectorType with as_type(self : VectorType) -> TypeRef {
//  self.ty
//}
//
/////|
//pub impl AsType for VectorType with as_type_ref(self : VectorType) -> @unsafe.LLVMTypeRef {
//  self.as_type_ref()
//}
//
/////|
//pub impl AsType for ScalableVectorType with as_type(self : ScalableVectorType) -> TypeRef {
//  self.ty
//}
//
/////|
//pub impl AsType for ScalableVectorType with as_type_ref(
//  self : ScalableVectorType
//) -> @unsafe.LLVMTypeRef {
//  self.ty.as_type_ref()
//}
//
/////|
//pub impl AsType for MetadataType with as_type(self : MetadataType) -> TypeRef {
//  self.ty
//}
//
/////|
//pub impl AsType for MetadataType with as_type_ref(self : MetadataType) -> @unsafe.LLVMTypeRef {
//  self.ty.as_type_ref()
//}
//
/////|
//pub impl AsType for AnyTypeEnum with as_type_ref(self) {
//  match self {
//    AnyTypeEnum::ArrayType(v) => v.as_type_ref()
//    AnyTypeEnum::FloatType(v) => v.as_type_ref()
//    AnyTypeEnum::FunctionType(v) => v.as_type_ref()
//    AnyTypeEnum::IntType(v) => v.as_type_ref()
//    AnyTypeEnum::PointerType(v) => v.as_type_ref()
//    AnyTypeEnum::StructType(v) => v.as_type_ref()
//    AnyTypeEnum::VectorType(v) => v.as_type_ref()
//    AnyTypeEnum::ScalableVectorType(v) => v.as_type_ref()
//    AnyTypeEnum::VoidType(v) => v.as_type_ref()
//  }
//}
//
/////|
//pub impl AsType for AnyTypeEnum with as_type(self : AnyTypeEnum) -> TypeRef {
//  match self {
//    AnyTypeEnum::ArrayType(v) => v.as_type()
//    AnyTypeEnum::FloatType(v) => v.as_type()
//    AnyTypeEnum::FunctionType(v) => v.as_type()
//    AnyTypeEnum::IntType(v) => v.as_type()
//    AnyTypeEnum::PointerType(v) => v.as_type()
//    AnyTypeEnum::StructType(v) => v.as_type()
//    AnyTypeEnum::VectorType(v) => v.as_type()
//    AnyTypeEnum::ScalableVectorType(v) => v.as_type()
//    AnyTypeEnum::VoidType(v) => v.as_type()
//  }
//}
//
/////|
//pub impl AsType for BasicTypeEnum with as_type_ref(self) {
//  match self {
//    ArrayType(t) => t.as_type_ref()
//    FloatType(t) => t.as_type_ref()
//    IntType(t) => t.as_type_ref()
//    PointerType(t) => t.as_type_ref()
//    StructType(t) => t.as_type_ref()
//    VectorType(t) => t.as_type_ref()
//    ScalableVectorType(t) => t.as_type_ref()
//  }
//}
//
/////|
//pub impl AsType for BasicTypeEnum with as_type(self : BasicTypeEnum) -> TypeRef {
//  match self {
//    ArrayType(t) => t.as_type()
//    FloatType(t) => t.as_type()
//    IntType(t) => t.as_type()
//    PointerType(t) => t.as_type()
//    StructType(t) => t.as_type()
//    VectorType(t) => t.as_type()
//    ScalableVectorType(t) => t.as_type()
//  }
//}
//
/////|
//pub impl AsType for BasicMetadataTypeEnum with as_type_ref(self) {
//  match self {
//    ArrayType(t) => t.as_type_ref()
//    FloatType(t) => t.as_type_ref()
//    IntType(t) => t.as_type_ref()
//    PointerType(t) => t.as_type_ref()
//    StructType(t) => t.as_type_ref()
//    VectorType(t) => t.as_type_ref()
//    ScalableVectorType(t) => t.as_type_ref()
//    MetadataType(t) => t.as_type_ref()
//  }
//}
//
/////|
//pub impl AsType for BasicMetadataTypeEnum with as_type(
//  self : BasicMetadataTypeEnum
//) -> TypeRef {
//  match self {
//    ArrayType(t) => t.as_type()
//    FloatType(t) => t.as_type()
//    IntType(t) => t.as_type()
//    PointerType(t) => t.as_type()
//    StructType(t) => t.as_type()
//    VectorType(t) => t.as_type()
//    ScalableVectorType(t) => t.as_type()
//    MetadataType(t) => t.as_type()
//  }
//}

//=========================================================
// AnyType
//=========================================================

/////|
//pub trait AnyType: AsType + Show {
//  as_any_type_enum(Self) -> AnyTypeEnum
//}
//
/////|
//pub impl AnyType for IntType with as_any_type_enum(self : IntType) -> AnyTypeEnum {
//  AnyTypeEnum::IntType(self)
//}
//
/////|
//pub impl AnyType for FloatType with as_any_type_enum(self : FloatType) -> AnyTypeEnum {
//  AnyTypeEnum::FloatType(self)
//}
//
/////|
//pub impl AnyType for VoidType with as_any_type_enum(self : VoidType) -> AnyTypeEnum {
//  AnyTypeEnum::VoidType(self)
//}
//
/////|
//pub impl AnyType for PointerType with as_any_type_enum(self : PointerType) -> AnyTypeEnum {
//  AnyTypeEnum::PointerType(self)
//}
//
/////|
//pub impl AnyType for StructType with as_any_type_enum(self : StructType) -> AnyTypeEnum {
//  AnyTypeEnum::StructType(self)
//}
//
/////|
//pub impl AnyType for FunctionType with as_any_type_enum(self : FunctionType) -> AnyTypeEnum {
//  AnyTypeEnum::FunctionType(self)
//}
//
/////|
//pub impl AnyType for ArrayType with as_any_type_enum(self : ArrayType) -> AnyTypeEnum {
//  AnyTypeEnum::ArrayType(self)
//}
//
/////|
//pub impl AnyType for VectorType with as_any_type_enum(self : VectorType) -> AnyTypeEnum {
//  AnyTypeEnum::VectorType(self)
//}
//
/////|
//pub impl AnyType for ScalableVectorType with as_any_type_enum(
//  self : ScalableVectorType
//) -> AnyTypeEnum {
//  AnyTypeEnum::ScalableVectorType(self)
//}
//
/////|
//pub impl AnyType for AnyTypeEnum with as_any_type_enum(self : AnyTypeEnum) -> AnyTypeEnum {
//  self
//}
//
/////|
//pub impl AnyType for BasicTypeEnum with as_any_type_enum(self : BasicTypeEnum) -> AnyTypeEnum {
//  match self {
//    ArrayType(t) => t.as_any_type_enum()
//    FloatType(t) => t.as_any_type_enum()
//    IntType(t) => t.as_any_type_enum()
//    PointerType(t) => t.as_any_type_enum()
//    StructType(t) => t.as_any_type_enum()
//    VectorType(t) => t.as_any_type_enum()
//    ScalableVectorType(t) => t.as_any_type_enum()
//  }
//}

//=========================================================
// BasicType
//=========================================================

/////|
//pub impl BasicType for IntType with as_basic_type_enum(self : IntType) -> BasicTypeEnum {
//  BasicTypeEnum::IntType(self)
//}
//
/////|
//pub impl BasicType for FloatType with as_basic_type_enum(self : FloatType) -> BasicTypeEnum {
//  BasicTypeEnum::FloatType(self)
//}
//
/////|
//pub impl BasicType for PointerType with as_basic_type_enum(self : PointerType) -> BasicTypeEnum {
//  BasicTypeEnum::PointerType(self)
//}
//
/////|
//pub impl BasicType for StructType with as_basic_type_enum(self : StructType) -> BasicTypeEnum {
//  BasicTypeEnum::StructType(self)
//}
//
/////|
//pub impl BasicType for ArrayType with as_basic_type_enum(self : ArrayType) -> BasicTypeEnum {
//  BasicTypeEnum::ArrayType(self)
//}
//
/////|
//pub impl BasicType for VectorType with as_basic_type_enum(self : VectorType) -> BasicTypeEnum {
//  BasicTypeEnum::VectorType(self)
//}
//
/////|
//pub impl BasicType for ScalableVectorType with as_basic_type_enum(
//  self : ScalableVectorType
//) -> BasicTypeEnum {
//  BasicTypeEnum::ScalableVectorType(self)
//}
//
/////|
//pub impl BasicType for BasicTypeEnum with as_basic_type_enum(
//  self : BasicTypeEnum
//) -> BasicTypeEnum {
//  self
//}

//=========================================================
// BasicMetadataType
//=========================================================

///|
//pub trait BasicMetadataType: AsType {
//  as_basic_metadata_type_enum(Self) -> BasicMetadataTypeEnum
//}
//
/////|
//pub impl BasicMetadataType for IntType with as_basic_metadata_type_enum(
//  self : IntType
//) -> BasicMetadataTypeEnum {
//  BasicMetadataTypeEnum::IntType(self)
//}
//
/////|
//pub impl BasicMetadataType for FloatType with as_basic_metadata_type_enum(
//  self : FloatType
//) -> BasicMetadataTypeEnum {
//  BasicMetadataTypeEnum::FloatType(self)
//}
//
/////|
//pub impl BasicMetadataType for PointerType with as_basic_metadata_type_enum(
//  self : PointerType
//) -> BasicMetadataTypeEnum {
//  BasicMetadataTypeEnum::PointerType(self)
//}
//
/////|
//pub impl BasicMetadataType for StructType with as_basic_metadata_type_enum(
//  self : StructType
//) -> BasicMetadataTypeEnum {
//  BasicMetadataTypeEnum::StructType(self)
//}
//
/////|
//pub impl BasicMetadataType for ArrayType with as_basic_metadata_type_enum(
//  self : ArrayType
//) -> BasicMetadataTypeEnum {
//  BasicMetadataTypeEnum::ArrayType(self)
//}
//
/////|
//pub impl BasicMetadataType for VectorType with as_basic_metadata_type_enum(
//  self : VectorType
//) -> BasicMetadataTypeEnum {
//  BasicMetadataTypeEnum::VectorType(self)
//}
//
/////|
//pub impl BasicMetadataType for ScalableVectorType with as_basic_metadata_type_enum(
//  self : ScalableVectorType
//) -> BasicMetadataTypeEnum {
//  BasicMetadataTypeEnum::ScalableVectorType(self)
//}
//
/////|
//pub impl BasicMetadataType for BasicMetadataTypeEnum with as_basic_metadata_type_enum(
//  self : BasicMetadataTypeEnum
//) -> BasicMetadataTypeEnum {
//  self
//}
