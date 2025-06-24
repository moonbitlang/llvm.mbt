//=========================================================
// AggregateValueEnum
//=========================================================

///|
pub(all) enum AggregateValueEnum {
  ArrayValue(ArrayValue)
  StructValue(StructValue)
}

///|
pub fn AggregateValueEnum::new(
  val_ref : @unsafe.LLVMValueRef
) -> AggregateValueEnum {
  let ty = val_ref.get_type()
  let kind = @unsafe.llvm_get_type_kind(ty)
  match kind {
    @unsafe.LLVMTypeKind::LLVMArrayTypeKind =>
      AggregateValueEnum::ArrayValue(ArrayValue::new(val_ref))
    @unsafe.LLVMTypeKind::LLVMStructTypeKind =>
      AggregateValueEnum::StructValue(StructValue::new(val_ref))
    _ => abort("Unsupported aggregate value kind")
  }
}

///|
pub fn AggregateValueEnum::is_array_value(self : AggregateValueEnum) -> Bool {
  self is AggregateValueEnum::ArrayValue(_)
}

///|
pub fn AggregateValueEnum::is_struct_value(self : AggregateValueEnum) -> Bool {
  self is AggregateValueEnum::StructValue(_)
}

///|
pub fn AggregateValueEnum::into_array_value(
  self : AggregateValueEnum
) -> ArrayValue {
  guard self is AggregateValueEnum::ArrayValue(v) else {
    abort("Found \{self} but expected the ArrayValue variant")
  }
  v
}

///|
pub fn AggregateValueEnum::into_struct_value(
  self : AggregateValueEnum
) -> StructValue {
  match self {
    AggregateValueEnum::StructValue(v) => v
    _ => abort("Found \{self} but expected the StructValue variant")
  }
}

///|
pub fn AggregateValueEnum::as_value_ref(
  self : AggregateValueEnum
) -> @unsafe.LLVMValueRef {
  match self {
    AggregateValueEnum::ArrayValue(v) => v.as_value_ref()
    AggregateValueEnum::StructValue(v) => v.as_value_ref()
  }
}

///|
pub impl Show for AggregateValueEnum with to_string(self : AggregateValueEnum) -> String {
  match self {
    AggregateValueEnum::ArrayValue(v) => v.to_string()
    AggregateValueEnum::StructValue(v) => v.to_string()
  }
}

///|
pub impl Show for AggregateValueEnum with output(
  self : AggregateValueEnum,
  logger : &Logger
) -> Unit {
  logger.write_string(self.to_string())
}

//=========================================================
// AnyValueEnum
//=========================================================

///|
pub(all) enum AnyValueEnum {
  ArrayValue(ArrayValue)
  IntValue(IntValue)
  FloatValue(FloatValue)
  PhiValue(PhiValue)
  FunctionValue(FunctionValue)
  PointerValue(PointerValue)
  StructValue(StructValue)
  VectorValue(VectorValue)
  ScalableVectorValue(ScalableVectorValue)
  InstructionValue(InstructionValue)
  MetadataValue(MetadataValue)
}

///|
pub fn AnyValueEnum::new(val_ref : @unsafe.LLVMValueRef) -> AnyValueEnum {
  let ty = val_ref.get_type()
  let kind = @unsafe.llvm_get_type_kind(ty)
  match kind {
    @unsafe.LLVMFloatTypeKind
    | @unsafe.LLVMFP128TypeKind
    | @unsafe.LLVMDoubleTypeKind
    | @unsafe.LLVMHalfTypeKind
    | @unsafe.LLVMX86_FP80TypeKind
    | @unsafe.LLVMPPC_FP128TypeKind => FloatValue(FloatValue::new(val_ref))
    @unsafe.LLVMIntegerTypeKind => IntValue(IntValue::new(val_ref))
    @unsafe.LLVMStructTypeKind =>
      AnyValueEnum::StructValue(StructValue::new(val_ref))
    @unsafe.LLVMPointerTypeKind =>
      match @unsafe.llvm_get_value_kind(val_ref) {
        @unsafe.LLVMFunctionValueKind =>
          FunctionValue(FunctionValue::new(val_ref).unwrap())
        _ => PointerValue(PointerValue::new(val_ref))
      }
    @unsafe.LLVMArrayTypeKind =>
      AnyValueEnum::ArrayValue(ArrayValue::new(val_ref))
    @unsafe.LLVMVectorTypeKind =>
      AnyValueEnum::VectorValue(VectorValue::new(val_ref))
    @unsafe.LLVMFunctionTypeKind =>
      FunctionValue(FunctionValue::new(val_ref).unwrap())
    @unsafe.LLVMVoidTypeKind => {
      if val_ref.isa_instruction().is_null() {
        abort("Void value must be an instruction")
      }
      InstructionValue(InstructionValue::new(val_ref))
    }
    @unsafe.LLVMMetadataTypeKind => MetadataValue(MetadataValue::new(val_ref))
    _ => abort("Unsupported value kind")
  }
}

///|
pub fn AnyValueEnum::get_type(self : AnyValueEnum) -> AnyTypeEnum {
  AnyTypeEnum::new(self.as_value_ref().get_type())
}

///|
pub fn AnyValueEnum::try_as_basic_value_enum(
  self : AnyValueEnum
) -> BasicValueEnum? {
  match self {
    ArrayValue(v) => Some(BasicValueEnum::ArrayValue(v))
    IntValue(v) => Some(BasicValueEnum::IntValue(v))
    FloatValue(v) => Some(BasicValueEnum::FloatValue(v))
    PointerValue(v) => Some(BasicValueEnum::PointerValue(v))
    StructValue(v) => Some(BasicValueEnum::StructValue(v))
    VectorValue(v) => Some(BasicValueEnum::VectorValue(v))
    ScalableVectorValue(v) => Some(BasicValueEnum::ScalableVectorValue(v))
    PhiValue(_) => None
    FunctionValue(_) => None
    InstructionValue(_) => None
    MetadataValue(_) => None
  }
}

///|
pub impl Show for AnyValueEnum with to_string(self : AnyValueEnum) -> String {
  match self {
    ArrayValue(v) => v.to_string()
    IntValue(v) => v.to_string()
    FloatValue(v) => v.to_string()
    PhiValue(v) => v.to_string()
    FunctionValue(v) => v.to_string()
    PointerValue(v) => v.to_string()
    StructValue(v) => v.to_string()
    VectorValue(v) => v.to_string()
    ScalableVectorValue(v) => v.to_string()
    InstructionValue(v) => v.to_string()
    MetadataValue(v) => v.to_string()
  }
}

///|
pub impl Show for AnyValueEnum with output(
  self : AnyValueEnum,
  logger : &Logger
) -> Unit {
  logger.write_string(self.to_string())
}

//=========================================================
// BasicValue
//=========================================================

///|
pub(all) enum BasicValueEnum {
  ArrayValue(ArrayValue)
  IntValue(IntValue)
  FloatValue(FloatValue)
  PointerValue(PointerValue)
  StructValue(StructValue)
  VectorValue(VectorValue)
  ScalableVectorValue(ScalableVectorValue)
}

///|
pub fn BasicValueEnum::new(val_ref : @unsafe.LLVMValueRef) -> BasicValueEnum {
  let ty = val_ref.get_type()
  let kind = @unsafe.llvm_get_type_kind(ty)
  match kind {
    @unsafe.LLVMFloatTypeKind
    | @unsafe.LLVMFP128TypeKind
    | @unsafe.LLVMDoubleTypeKind
    | @unsafe.LLVMHalfTypeKind
    | @unsafe.LLVMX86_FP80TypeKind
    | @unsafe.LLVMPPC_FP128TypeKind =>
      BasicValueEnum::FloatValue(FloatValue::new(val_ref))
    @unsafe.LLVMIntegerTypeKind =>
      BasicValueEnum::IntValue(IntValue::new(val_ref))
    @unsafe.LLVMStructTypeKind =>
      BasicValueEnum::StructValue(StructValue::new(val_ref))
    @unsafe.LLVMPointerTypeKind =>
      BasicValueEnum::PointerValue(PointerValue::new(val_ref))
    @unsafe.LLVMArrayTypeKind =>
      BasicValueEnum::ArrayValue(ArrayValue::new(val_ref))
    @unsafe.LLVMVectorTypeKind =>
      BasicValueEnum::VectorValue(VectorValue::new(val_ref))
    // @unsafe.LLVMScalableVectorTypeKind => BasicValueEnum::ScalableVectorValue(ScalableVectorValue::new(val_ref)) // Check if it ok in llvm-19 above
    _ => abort("Unsupported value kind")
  }
}

///|
pub fn BasicValueEnum::get_name(self : BasicValueEnum) -> String {
  match self {
    ArrayValue(v) => v.get_name()
    IntValue(v) => v.get_name()
    FloatValue(v) => v.get_name()
    PointerValue(v) => v.get_name()
    StructValue(v) => v.get_name()
    VectorValue(v) => v.get_name()
    ScalableVectorValue(v) => v.get_name()
  }
}

///|
pub fn BasicValueEnum::set_name(self : BasicValueEnum, name : String) -> Unit {
  match self {
    ArrayValue(v) => v.set_name(name)
    IntValue(v) => v.set_name(name)
    FloatValue(v) => v.set_name(name)
    PointerValue(v) => v.set_name(name)
    StructValue(v) => v.set_name(name)
    VectorValue(v) => v.set_name(name)
    ScalableVectorValue(v) => v.set_name(name)
  }
}

///|
pub fn BasicValueEnum::get_type(self : BasicValueEnum) -> BasicTypeEnum {
  match self {
    ArrayValue(v) => BasicTypeEnum::ArrayType(v.get_type())
    IntValue(v) => BasicTypeEnum::IntType(v.get_type())
    FloatValue(v) => BasicTypeEnum::FloatType(v.get_type())
    PointerValue(v) => BasicTypeEnum::PointerType(v.get_type())
    StructValue(v) => BasicTypeEnum::StructType(v.get_type())
    VectorValue(v) => BasicTypeEnum::VectorType(v.get_type())
    ScalableVectorValue(v) => BasicTypeEnum::ScalableVectorType(v.get_type())
  }
}

///|
pub fn BasicValueEnum::into_array_value(self : BasicValueEnum) -> ArrayValue {
  match self {
    BasicValueEnum::ArrayValue(v) => v
    _ => abort("Found \{self} but expected the ArrayValue variant")
  }
}

///|
pub fn BasicValueEnum::into_int_value(self : BasicValueEnum) -> IntValue {
  match self {
    BasicValueEnum::IntValue(v) => v
    _ => abort("Found \{self} but expected the IntValue variant")
  }
}

///|
pub fn BasicValueEnum::into_float_value(self : BasicValueEnum) -> FloatValue {
  match self {
    BasicValueEnum::FloatValue(v) => v
    _ => abort("Found \{self} but expected the FloatValue variant")
  }
}

///|
pub fn BasicValueEnum::into_pointer_value(
  self : BasicValueEnum
) -> PointerValue {
  match self {
    BasicValueEnum::PointerValue(v) => v
    _ => abort("Found \{self} but expected the PointerValue variant")
  }
}

///|
pub fn BasicValueEnum::into_struct_value(self : BasicValueEnum) -> StructValue {
  match self {
    BasicValueEnum::StructValue(v) => v
    _ => abort("Found \{self} but expected the StructValue variant")
  }
}

///|
pub fn BasicValueEnum::into_vector_value(self : BasicValueEnum) -> VectorValue {
  match self {
    BasicValueEnum::VectorValue(v) => v
    _ => abort("Found \{self} but expected the VectorValue variant")
  }
}

///|
pub fn BasicValueEnum::into_scalable_vector_value(
  self : BasicValueEnum
) -> ScalableVectorValue {
  match self {
    BasicValueEnum::ScalableVectorValue(v) => v
    _ => abort("Found \{self} but expected the ScalableVectorValue variant")
  }
}

///|
pub impl Show for BasicValueEnum with to_string(self : BasicValueEnum) -> String {
  match self {
    ArrayValue(v) => v.to_string()
    IntValue(v) => v.to_string()
    FloatValue(v) => v.to_string()
    PointerValue(v) => v.to_string()
    StructValue(v) => v.to_string()
    VectorValue(v) => v.to_string()
    ScalableVectorValue(v) => v.to_string()
  }
}

///|
pub impl Show for BasicValueEnum with output(
  self : BasicValueEnum,
  logger : &Logger
) -> Unit {
  logger.write_string(self.to_string())
}

///|
pub impl AnyValue for BasicValueEnum with as_any_value_enum(
  self : BasicValueEnum
) -> AnyValueEnum {
  match self {
    ArrayValue(v) => AnyValueEnum::ArrayValue(v)
    IntValue(v) => AnyValueEnum::IntValue(v)
    FloatValue(v) => AnyValueEnum::FloatValue(v)
    PointerValue(v) => AnyValueEnum::PointerValue(v)
    StructValue(v) => AnyValueEnum::StructValue(v)
    VectorValue(v) => AnyValueEnum::VectorValue(v)
    ScalableVectorValue(v) => AnyValueEnum::ScalableVectorValue(v)
  }
}

///|
pub impl BasicValue for BasicValueEnum with as_basic_value_enum(
  self : BasicValueEnum
) -> BasicValueEnum {
  self
}

//=========================================================
// BasicMetadataValueEnum
//=========================================================

///|
pub(all) enum BasicMetadataValueEnum {
  ArrayValue(ArrayValue)
  IntValue(IntValue)
  FloatValue(FloatValue)
  PointerValue(PointerValue)
  StructValue(StructValue)
  VectorValue(VectorValue)
  ScalableVectorValue(ScalableVectorValue)
  MetadataValue(MetadataValue)
}

///|
pub fn BasicMetadataValueEnum::new(
  val_ref : @unsafe.LLVMValueRef
) -> BasicMetadataValueEnum {
  let ty = val_ref.get_type()
  let kind = @unsafe.llvm_get_type_kind(ty)
  match kind {
    @unsafe.LLVMFloatTypeKind
    | @unsafe.LLVMFP128TypeKind
    | @unsafe.LLVMDoubleTypeKind
    | @unsafe.LLVMHalfTypeKind
    | @unsafe.LLVMX86_FP80TypeKind
    | @unsafe.LLVMPPC_FP128TypeKind =>
      BasicMetadataValueEnum::FloatValue(FloatValue::new(val_ref))
    @unsafe.LLVMIntegerTypeKind =>
      BasicMetadataValueEnum::IntValue(IntValue::new(val_ref))
    @unsafe.LLVMStructTypeKind =>
      BasicMetadataValueEnum::StructValue(StructValue::new(val_ref))
    @unsafe.LLVMPointerTypeKind =>
      BasicMetadataValueEnum::PointerValue(PointerValue::new(val_ref))
    @unsafe.LLVMArrayTypeKind =>
      BasicMetadataValueEnum::ArrayValue(ArrayValue::new(val_ref))
    @unsafe.LLVMVectorTypeKind =>
      BasicMetadataValueEnum::VectorValue(VectorValue::new(val_ref))
    // @unsafe.LLVMScalableVectorTypeKind => BasicMetadataValueEnum::ScalableVectorValue(ScalableVectorValue::new(val_ref)) // check if it is ok in llvm19
    @unsafe.LLVMMetadataTypeKind =>
      BasicMetadataValueEnum::MetadataValue(MetadataValue::new(val_ref))
    _ => abort("Unsupported value kind")
  }
}

///|
pub fn BasicMetadataValueEnum::is_array_value(
  self : BasicMetadataValueEnum
) -> Bool {
  self is BasicMetadataValueEnum::ArrayValue(_)
}

///|
pub fn BasicMetadataValueEnum::is_int_value(
  self : BasicMetadataValueEnum
) -> Bool {
  self is BasicMetadataValueEnum::IntValue(_)
}

///|
pub fn BasicMetadataValueEnum::is_float_value(
  self : BasicMetadataValueEnum
) -> Bool {
  self is BasicMetadataValueEnum::FloatValue(_)
}

///|
pub fn BasicMetadataValueEnum::is_pointer_value(
  self : BasicMetadataValueEnum
) -> Bool {
  self is BasicMetadataValueEnum::PointerValue(_)
}

///|
pub fn BasicMetadataValueEnum::is_struct_value(
  self : BasicMetadataValueEnum
) -> Bool {
  self is BasicMetadataValueEnum::StructValue(_)
}

///|
pub fn BasicMetadataValueEnum::is_vector_value(
  self : BasicMetadataValueEnum
) -> Bool {
  self is BasicMetadataValueEnum::VectorValue(_)
}

///|
pub fn BasicMetadataValueEnum::is_scalable_vector_value(
  self : BasicMetadataValueEnum
) -> Bool {
  self is BasicMetadataValueEnum::ScalableVectorValue(_)
}

///|
pub fn BasicMetadataValueEnum::is_metadata_value(
  self : BasicMetadataValueEnum
) -> Bool {
  self is BasicMetadataValueEnum::MetadataValue(_)
}

///|
pub fn BasicMetadataValueEnum::into_array_value(
  self : BasicMetadataValueEnum
) -> ArrayValue {
  match self {
    BasicMetadataValueEnum::ArrayValue(v) => v
    _ => abort("Found \{self} but expected the ArrayValue variant")
  }
}

///|
pub fn BasicMetadataValueEnum::into_int_value(
  self : BasicMetadataValueEnum
) -> IntValue {
  match self {
    BasicMetadataValueEnum::IntValue(v) => v
    _ => abort("Found \{self} but expected the IntValue variant")
  }
}

///|
pub fn BasicMetadataValueEnum::into_float_value(
  self : BasicMetadataValueEnum
) -> FloatValue {
  match self {
    BasicMetadataValueEnum::FloatValue(v) => v
    _ => abort("Found \{self} but expected the FloatValue variant")
  }
}

///|
pub fn BasicMetadataValueEnum::into_pointer_value(
  self : BasicMetadataValueEnum
) -> PointerValue {
  match self {
    BasicMetadataValueEnum::PointerValue(v) => v
    _ => abort("Found \{self} but expected the PointerValue variant")
  }
}

///|
pub fn BasicMetadataValueEnum::into_struct_value(
  self : BasicMetadataValueEnum
) -> StructValue {
  match self {
    BasicMetadataValueEnum::StructValue(v) => v
    _ => abort("Found \{self} but expected the StructValue variant")
  }
}

///|
pub fn BasicMetadataValueEnum::into_vector_value(
  self : BasicMetadataValueEnum
) -> VectorValue {
  match self {
    BasicMetadataValueEnum::VectorValue(v) => v
    _ => abort("Found \{self} but expected the VectorValue variant")
  }
}

// into ScalableVectorValue, MetadataValue

///|
pub impl Show for BasicMetadataValueEnum with to_string(
  self : BasicMetadataValueEnum
) -> String {
  match self {
    ArrayValue(v) => v.to_string()
    IntValue(v) => v.to_string()
    FloatValue(v) => v.to_string()
    PointerValue(v) => v.to_string()
    StructValue(v) => v.to_string()
    VectorValue(v) => v.to_string()
    ScalableVectorValue(v) => v.to_string()
    MetadataValue(v) => v.to_string()
  }
}

///|
pub impl Show for BasicMetadataValueEnum with output(
  self : BasicMetadataValueEnum,
  logger : &Logger
) -> Unit {
  logger.write_string(self.to_string())
}

//=========================================================
// AnyTypeEnum
//=========================================================

///|
pub(all) enum AnyTypeEnum {
  ArrayType(ArrayType)
  FloatType(FloatType)
  FunctionType(FunctionType)
  IntType(IntType)
  PointerType(PointerType)
  StructType(StructType)
  VectorType(VectorType)
  ScalableVectorType(ScalableVectorType)
  VoidType(VoidType)
}

// TODO: Do not use `_` match

///|
pub fn AnyTypeEnum::new(type_ref : @unsafe.LLVMTypeRef) -> AnyTypeEnum {
  let kind : @unsafe.LLVMTypeKind = @unsafe.llvm_get_type_kind(type_ref)
  match kind {
    @unsafe.LLVMVoidTypeKind => VoidType(VoidType::new(type_ref))
    @unsafe.LLVMHalfTypeKind
    | @unsafe.LLVMFloatTypeKind
    | @unsafe.LLVMDoubleTypeKind
    | @unsafe.LLVMX86_FP80TypeKind
    | @unsafe.LLVMFP128TypeKind
    | @unsafe.LLVMPPC_FP128TypeKind => FloatType(FloatType::new(type_ref))
    @unsafe.LLVMIntegerTypeKind => IntType(IntType::new(type_ref))
    @unsafe.LLVMFunctionTypeKind => FunctionType(FunctionType::new(type_ref))
    @unsafe.LLVMStructTypeKind => StructType(StructType::new(type_ref))
    @unsafe.LLVMArrayTypeKind => ArrayType(ArrayType::new(type_ref))
    @unsafe.LLVMVectorTypeKind => VectorType(VectorType::new(type_ref))
    @unsafe.LLVMScalableVectorTypeKind =>
      ScalableVectorType(ScalableVectorType::new(type_ref))
    @unsafe.LLVMPointerTypeKind => PointerType(PointerType::new(type_ref))
    _ => abort("Unsupported type kind \{kind}")
  }
}

///|
pub impl Eq for AnyTypeEnum with op_equal(
  self : AnyTypeEnum,
  other : AnyTypeEnum
) -> Bool {
  match (self, other) {
    (ArrayType(_), ArrayType(_)) => true
    (FloatType(_), FloatType(_)) => true
    (FunctionType(_), FunctionType(_)) => true
    (IntType(_), IntType(_)) => true
    (PointerType(_), PointerType(_)) => true
    (StructType(_), StructType(_)) => true
    (VectorType(_), VectorType(_)) => true
    (ScalableVectorType(_), ScalableVectorType(_)) => true
    (VoidType(_), VoidType(_)) => true
    _ => false
  }
}

///|
pub fn AnyTypeEnum::try_as_basic_type_enum(
  self : AnyTypeEnum
) -> BasicTypeEnum? {
  match self {
    ArrayType(v) => Some(BasicTypeEnum::ArrayType(v))
    FloatType(v) => Some(BasicTypeEnum::FloatType(v))
    IntType(v) => Some(BasicTypeEnum::IntType(v))
    PointerType(v) => Some(BasicTypeEnum::PointerType(v))
    StructType(v) => Some(BasicTypeEnum::StructType(v))
    VectorType(v) => Some(BasicTypeEnum::VectorType(v))
    ScalableVectorType(v) => Some(BasicTypeEnum::ScalableVectorType(v))
    VoidType(_) => None
    FunctionType(_) => None
  }
}

///|
pub fn AnyTypeEnum::dump(self : AnyTypeEnum) -> Unit {
  match self {
    ArrayType(v) => v.dump()
    FloatType(v) => v.dump()
    FunctionType(v) => v.dump()
    IntType(v) => v.dump()
    PointerType(v) => v.dump()
    StructType(v) => v.dump()
    VectorType(v) => v.dump()
    ScalableVectorType(v) => v.dump()
    VoidType(v) => v.dump()
  }
}

///|
pub fn AnyTypeEnum::is_array_type(self : AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::ArrayType(_)
}

///|
pub fn AnyTypeEnum::is_float_type(self : AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::FloatType(_)
}

///|
pub fn AnyTypeEnum::is_function_type(self : AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::FunctionType(_)
}

///|
pub fn AnyTypeEnum::is_int_type(self : AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::IntType(_)
}

///|
pub fn AnyTypeEnum::is_pointer_type(self : AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::PointerType(_)
}

///|
pub fn AnyTypeEnum::is_struct_type(self : AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::StructType(_)
}

///|
pub fn AnyTypeEnum::is_vector_type(self : AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::VectorType(_)
}

///|
pub fn AnyTypeEnum::is_scalable_vector_type(self : AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::ScalableVectorType(_)
}

///|
pub fn AnyTypeEnum::is_void_type(self : AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::VoidType(_)
}

///|
pub fn AnyTypeEnum::into_array_type(self : AnyTypeEnum) -> ArrayType {
  match self {
    AnyTypeEnum::ArrayType(v) => v
    _ => abort("Found \{self} but expected the ArrayType variant")
  }
}

///|
pub fn AnyTypeEnum::into_float_type(self : AnyTypeEnum) -> FloatType {
  match self {
    AnyTypeEnum::FloatType(v) => v
    _ => abort("Found \{self} but expected the FloatType variant")
  }
}

///|
pub fn AnyTypeEnum::into_function_type(self : AnyTypeEnum) -> FunctionType {
  match self {
    AnyTypeEnum::FunctionType(v) => v
    _ => abort("Found \{self} but expected the FunctionType variant")
  }
}

///|
pub fn AnyTypeEnum::into_int_type(self : AnyTypeEnum) -> IntType {
  match self {
    AnyTypeEnum::IntType(v) => v
    _ => abort("Found \{self} but expected the IntType variant")
  }
}

///|
pub fn AnyTypeEnum::into_pointer_type(self : AnyTypeEnum) -> PointerType {
  match self {
    AnyTypeEnum::PointerType(v) => v
    _ => abort("Found \{self} but expected the PointerType variant")
  }
}

///|
pub fn AnyTypeEnum::into_struct_type(self : AnyTypeEnum) -> StructType {
  match self {
    AnyTypeEnum::StructType(v) => v
    _ => abort("Found \{self} but expected the StructType variant")
  }
}

///|
pub fn AnyTypeEnum::into_vector_type(self : AnyTypeEnum) -> VectorType {
  match self {
    AnyTypeEnum::VectorType(v) => v
    _ => abort("Found \{self} but expected the VectorType variant")
  }
}

///|
pub fn AnyTypeEnum::into_scalable_vector_type(
  self : AnyTypeEnum
) -> ScalableVectorType {
  match self {
    AnyTypeEnum::ScalableVectorType(v) => v
    _ => abort("Found \{self} but expected the ScalableVectorType variant")
  }
}

///|
pub fn AnyTypeEnum::into_void_type(self : AnyTypeEnum) -> VoidType {
  match self {
    AnyTypeEnum::VoidType(v) => v
    _ => abort("Found \{self} but expected the VoidType variant")
  }
}

// pub fn AnyTypeEnum::size_of(self: AnyTypeEnum) -> IntValue? {
//   match self {
//     ArrayType(t) => t.size_of()
//     FloatType(t) => t.size_of()
//     FunctionType(_) => None
//     PointerType(t) => t.size_of()
//     StructType(t) => t.size_of()
//     VectorType(t) => t.size_of()
//     VoidType(_) => None
//   }
// }

///|
pub impl Show for AnyTypeEnum with to_string(self : AnyTypeEnum) -> String {
  match self {
    ArrayType(v) => v.to_string()
    FloatType(v) => v.to_string()
    FunctionType(v) => v.to_string()
    IntType(v) => v.to_string()
    PointerType(v) => v.to_string()
    StructType(v) => v.to_string()
    VectorType(v) => v.to_string()
    ScalableVectorType(v) => v.to_string()
    VoidType(v) => v.to_string()
  }
}

///|
pub impl Show for AnyTypeEnum with output(self : AnyTypeEnum, logger : &Logger) -> Unit {
  logger.write_string(self.to_string())
}

//=========================================================
// BasicType
//=========================================================

///|
pub(all) enum BasicTypeEnum {
  ArrayType(ArrayType)
  FloatType(FloatType)
  IntType(IntType)
  PointerType(PointerType)
  StructType(StructType)
  VectorType(VectorType)
  ScalableVectorType(ScalableVectorType)
}

///|
pub fn BasicTypeEnum::new(type_ref : @unsafe.LLVMTypeRef) -> BasicTypeEnum {
  let kind : @unsafe.LLVMTypeKind = @unsafe.llvm_get_type_kind(type_ref)
  match kind {
    @unsafe.LLVMHalfTypeKind
    | @unsafe.LLVMFloatTypeKind
    | @unsafe.LLVMDoubleTypeKind
    | @unsafe.LLVMX86_FP80TypeKind
    | @unsafe.LLVMFP128TypeKind
    | @unsafe.LLVMPPC_FP128TypeKind =>
      BasicTypeEnum::FloatType(FloatType::new(type_ref))
    @unsafe.LLVMIntegerTypeKind =>
      BasicTypeEnum::IntType(IntType::new(type_ref))
    @unsafe.LLVMArrayTypeKind =>
      BasicTypeEnum::ArrayType(ArrayType::new(type_ref))
    @unsafe.LLVMVectorTypeKind =>
      BasicTypeEnum::VectorType(VectorType::new(type_ref))
    @unsafe.LLVMPointerTypeKind =>
      BasicTypeEnum::PointerType(PointerType::new(type_ref))
    @unsafe.LLVMStructTypeKind =>
      BasicTypeEnum::StructType(StructType::new(type_ref))
    _ => abort("Unsupported type kind")
  }
}

///|
pub fn BasicTypeEnum::get_context(self : BasicTypeEnum) -> Context {
  match self {
    ArrayType(t) => t.get_context()
    FloatType(t) => t.get_context()
    IntType(t) => t.get_context()
    PointerType(t) => t.get_context()
    StructType(t) => t.get_context()
    VectorType(t) => t.get_context()
    ScalableVectorType(t) => t.get_context()
  }
}

///|
pub fn BasicTypeEnum::ptr_type(
  self : BasicTypeEnum,
  addr_sapce : AddressSpace
) -> PointerType {
  match self {
    ArrayType(t) => t.ptr_type(addr_sapce)
    FloatType(t) => t.ptr_type(addr_sapce)
    IntType(t) => t.ptr_type(addr_sapce)
    PointerType(t) => t.ptr_type(addr_sapce)
    StructType(t) => t.ptr_type(addr_sapce)
    VectorType(t) => t.ptr_type(addr_sapce)
    ScalableVectorType(t) => t.ptr_type(addr_sapce)
  }
}

///|
pub fn BasicTypeEnum::fn_type(
  self : BasicTypeEnum,
  param_types : Array[&BasicType],
  is_var_arg~ : Bool = false
) -> FunctionType {
  self.as_type().fn_type(param_types, is_var_arg~)
}

// only check class type

///|
pub impl Eq for BasicTypeEnum with op_equal(
  self : BasicTypeEnum,
  other : BasicTypeEnum
) -> Bool {
  match (self, other) {
    (ArrayType(_), ArrayType(_)) => true
    (FloatType(_), FloatType(_)) => true
    (IntType(_), IntType(_)) => true
    (PointerType(_), PointerType(_)) => true
    (StructType(_), StructType(_)) => true
    (VectorType(_), VectorType(_)) => true
    (ScalableVectorType(_), ScalableVectorType(_)) => true
    _ => false
  }
}

///|
pub impl Show for BasicTypeEnum with to_string(self : BasicTypeEnum) -> String {
  match self {
    ArrayType(t) => t.to_string()
    FloatType(t) => t.to_string()
    IntType(t) => t.to_string()
    PointerType(t) => t.to_string()
    StructType(t) => t.to_string()
    VectorType(t) => t.to_string()
    ScalableVectorType(t) => t.to_string()
  }
}

///|
pub impl Show for BasicTypeEnum with output(
  self : BasicTypeEnum,
  logger : &Logger
) -> Unit {
  logger.write_string(self.to_string())
}

//=========================================================
// BasicMetadataTypeEnum
//=========================================================

///|
pub(all) enum BasicMetadataTypeEnum {
  ArrayType(ArrayType)
  FloatType(FloatType)
  IntType(IntType)
  PointerType(PointerType)
  StructType(StructType)
  VectorType(VectorType)
  ScalableVectorType(ScalableVectorType)
  MetadataType(MetadataType)
}

///|
pub fn BasicMetadataTypeEnum::new(
  type_ref : @unsafe.LLVMTypeRef
) -> BasicMetadataTypeEnum {
  let kind : @unsafe.LLVMTypeKind = @unsafe.llvm_get_type_kind(type_ref)
  match kind {
    @unsafe.LLVMHalfTypeKind
    | @unsafe.LLVMFloatTypeKind
    | @unsafe.LLVMDoubleTypeKind
    | @unsafe.LLVMX86_FP80TypeKind
    | @unsafe.LLVMFP128TypeKind
    | @unsafe.LLVMPPC_FP128TypeKind =>
      BasicMetadataTypeEnum::FloatType(FloatType::new(type_ref))
    @unsafe.LLVMIntegerTypeKind =>
      BasicMetadataTypeEnum::IntType(IntType::new(type_ref))
    @unsafe.LLVMArrayTypeKind =>
      BasicMetadataTypeEnum::ArrayType(ArrayType::new(type_ref))
    @unsafe.LLVMVectorTypeKind =>
      BasicMetadataTypeEnum::VectorType(VectorType::new(type_ref))
    @unsafe.LLVMPointerTypeKind =>
      BasicMetadataTypeEnum::PointerType(PointerType::new(type_ref))
    @unsafe.LLVMStructTypeKind =>
      BasicMetadataTypeEnum::StructType(StructType::new(type_ref))
    @unsafe.LLVMScalableVectorTypeKind =>
      BasicMetadataTypeEnum::ScalableVectorType(
        ScalableVectorType::new(type_ref),
      )
    @unsafe.LLVMMetadataTypeKind =>
      BasicMetadataTypeEnum::MetadataType(MetadataType::new(type_ref))
    _ => abort("Unsupported type kind")
  }
}

///|
pub impl Show for BasicMetadataTypeEnum with to_string(self) {
  match self {
    ArrayType(v) => v.to_string()
    FloatType(v) => v.to_string()
    IntType(v) => v.to_string()
    PointerType(v) => v.to_string()
    StructType(v) => v.to_string()
    VectorType(v) => v.to_string()
    ScalableVectorType(v) => v.to_string()
    MetadataType(v) => v.to_string()
  }
}

///|
pub impl Show for BasicMetadataTypeEnum with output(
  self : BasicMetadataTypeEnum,
  logger : &Logger
) -> Unit {
  logger.write_string(self.to_string())
}

// pub enum StringRadix {
//   Binary;
//   Octal;
//   Decimal;
//   Hexadecimal;
//   Alphabetic;
// }

//=========================================================
// IntMathType
//=========================================================
// pub trait IntMathType : BasicType {
// }
