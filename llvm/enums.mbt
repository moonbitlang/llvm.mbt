//=========================================================
// AggregateValueEnum
//=========================================================
pub(all) enum AggregateValueEnum {
  ArrayValue(ArrayValue);
  StructValue(StructValue);
}

pub fn AggregateValueEnum::new(val_ref: @unsafe.LLVMValueRef) -> AggregateValueEnum {
  let ty = val_ref.get_type();
  let kind = @unsafe.llvm_get_type_kind(ty);
  match kind {
    @unsafe.LLVMTypeKind::LLVMArrayTypeKind => AggregateValueEnum::ArrayValue(ArrayValue::new(val_ref))
    @unsafe.LLVMTypeKind::LLVMStructTypeKind => AggregateValueEnum::StructValue(StructValue::new(val_ref))
    _ => abort("Unsupported aggregate value kind")
  }
}

pub fn AggregateValueEnum::is_array_value(self: AggregateValueEnum) -> Bool {
  match self {
    AggregateValueEnum::ArrayValue(_) => true
    _ => false
  }
}

pub fn AggregateValueEnum::is_struct_value(self: AggregateValueEnum) -> Bool {
  match self {
    AggregateValueEnum::StructValue(_) => true
    _ => false
  }
}

pub fn AggregateValueEnum::into_array_value(self: AggregateValueEnum) -> ArrayValue {
  match self {
    AggregateValueEnum::ArrayValue(v) => v
    _ => abort("Found \{self} but expected the ArrayValue variant")
  }
}

pub fn AggregateValueEnum::into_struct_value(self: AggregateValueEnum) -> StructValue {
  match self {
    AggregateValueEnum::StructValue(v) => v
    _ => abort("Found \{self} but expected the StructValue variant")
  }
}


pub fn AggregateValueEnum::as_value_ref(self: AggregateValueEnum) -> @unsafe.LLVMValueRef {
  match self {
    AggregateValueEnum::ArrayValue(v) => v.as_value_ref()
    AggregateValueEnum::StructValue(v) => v.as_value_ref()
  }
}

pub impl Show for AggregateValueEnum with to_string(self: AggregateValueEnum) -> String {
  match self {
    AggregateValueEnum::ArrayValue(v) => v.to_string()
    AggregateValueEnum::StructValue(v) => v.to_string()
  }
}

pub impl Show for AggregateValueEnum with output(self: AggregateValueEnum, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}


//=========================================================
// AnyValueEnum
//=========================================================
pub(all) enum AnyValueEnum {
  ArrayValue(ArrayValue);
  IntValue(IntValue);
  FloatValue(FloatValue);
  PhiValue(PhiValue);
  FunctionValue(FunctionValue);
  PointerValue(PointerValue);
  StructValue(StructValue);
  VectorValue(VectorValue);
  ScalableVectorValue(ScalableVectorValue);
  InstructionValue(InstructionValue);
  MetadataValue(MetadataValue);
}

pub fn AnyValueEnum::new(val_ref: @unsafe.LLVMValueRef) -> AnyValueEnum {
  let ty = val_ref.get_type();
  let kind = @unsafe.llvm_get_type_kind(ty);
  match kind {
  @unsafe.LLVMFloatTypeKind
  | @unsafe.LLVMFP128TypeKind
  | @unsafe.LLVMDoubleTypeKind
  | @unsafe.LLVMHalfTypeKind
  | @unsafe.LLVMX86_FP80TypeKind
  | @unsafe.LLVMPPC_FP128TypeKind => FloatValue(FloatValue::new(val_ref))
  @unsafe.LLVMIntegerTypeKind => IntValue(IntValue::new(val_ref))
  @unsafe.LLVMStructTypeKind => AnyValueEnum::StructValue(StructValue::new(val_ref))
  @unsafe.LLVMPointerTypeKind => match @unsafe.llvm_get_value_kind(val_ref) {
    @unsafe.LLVMFunctionValueKind => FunctionValue(FunctionValue::new(val_ref).unwrap())
    _ => PointerValue(PointerValue::new(val_ref))
  }
  @unsafe.LLVMArrayTypeKind => AnyValueEnum::ArrayValue(ArrayValue::new(val_ref))
  @unsafe.LLVMVectorTypeKind => AnyValueEnum::VectorValue(VectorValue::new(val_ref))
  @unsafe.LLVMFunctionTypeKind => FunctionValue(FunctionValue::new(val_ref).unwrap())
  @unsafe.LLVMVoidTypeKind => {
    if val_ref.isa_instruction().is_null() {
      abort("Void value must be an instruction");
    }
    InstructionValue(InstructionValue::new(val_ref))
  }
  @unsafe.LLVMMetadataTypeKind => MetadataValue(MetadataValue::new(val_ref))
  _ => abort("Unsupported value kind")
  }
}

pub fn AnyValueEnum::as_value_ref(self: AnyValueEnum) -> @unsafe.LLVMValueRef {
  match self {
    AnyValueEnum::ArrayValue(v) => v.as_value_ref()
    AnyValueEnum::IntValue(v) => v.as_value_ref()
    AnyValueEnum::FloatValue(v) => v.as_value_ref()
    AnyValueEnum::PhiValue(v) => v.as_value_ref()
    AnyValueEnum::FunctionValue(v) => v.as_value_ref()
    AnyValueEnum::PointerValue(v) => v.as_value_ref()
    AnyValueEnum::StructValue(v) => v.as_value_ref()
    AnyValueEnum::VectorValue(v) => v.as_value_ref()
    AnyValueEnum::ScalableVectorValue(v) => v.as_value_ref()
    AnyValueEnum::InstructionValue(v) => v.as_value_ref()
    AnyValueEnum::MetadataValue(v) => v.as_value_ref()
  }
}

pub fn AnyValueEnum::get_type(self: AnyValueEnum) -> AnyTypeEnum {
  AnyTypeEnum::new(self.as_value_ref().get_type())
}

pub fn AnyValueEnum::is_array_value(self: AnyValueEnum) -> Bool {
  self is AnyValueEnum::ArrayValue(_)
}

pub impl Show for AnyValueEnum with to_string(self: AnyValueEnum) -> String {
  match self {
    AnyValueEnum::ArrayValue(v) => v.to_string()
    AnyValueEnum::IntValue(v) => v.to_string()
    AnyValueEnum::FloatValue(v) => v.to_string()
    AnyValueEnum::PhiValue(v) => v.to_string()
    AnyValueEnum::FunctionValue(v) => v.to_string()
    AnyValueEnum::PointerValue(v) => v.to_string()
    AnyValueEnum::StructValue(v) => v.to_string()
    AnyValueEnum::VectorValue(v) => v.to_string()
    AnyValueEnum::ScalableVectorValue(v) => v.to_string()
    AnyValueEnum::InstructionValue(v) => v.to_string()
    AnyValueEnum::MetadataValue(v) => v.to_string()
  }
}

pub impl Show for AnyValueEnum with output(self: AnyValueEnum, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

//=========================================================
// BasicValue
//=========================================================
pub(all) enum BasicValueEnum {
  ArrayValue(ArrayValue);
  IntValue(IntValue);
  FloatValue(FloatValue);
  PointerValue(PointerValue);
  StructValue(StructValue);
  VectorValue(VectorValue);
  ScalableVectorValue(ScalableVectorValue);
}

pub fn BasicValueEnum::new(val_ref: @unsafe.LLVMValueRef) -> BasicValueEnum {
  let ty = val_ref.get_type();
  let kind = @unsafe.llvm_get_type_kind(ty);
  match kind {
    @unsafe.LLVMFloatTypeKind
    | @unsafe.LLVMFP128TypeKind
    | @unsafe.LLVMDoubleTypeKind
    | @unsafe.LLVMHalfTypeKind
    | @unsafe.LLVMX86_FP80TypeKind
    | @unsafe.LLVMPPC_FP128TypeKind => BasicValueEnum::FloatValue(FloatValue::new(val_ref))
    @unsafe.LLVMIntegerTypeKind => BasicValueEnum::IntValue(IntValue::new(val_ref))
    @unsafe.LLVMStructTypeKind => BasicValueEnum::StructValue(StructValue::new(val_ref))
    @unsafe.LLVMPointerTypeKind => BasicValueEnum::PointerValue(PointerValue::new(val_ref))
    @unsafe.LLVMArrayTypeKind => BasicValueEnum::ArrayValue(ArrayValue::new(val_ref))
    @unsafe.LLVMVectorTypeKind => BasicValueEnum::VectorValue(VectorValue::new(val_ref))
    // @unsafe.LLVMScalableVectorTypeKind => BasicValueEnum::ScalableVectorValue(ScalableVectorValue::new(val_ref)) // Check if it ok in llvm-19 above
    _ => abort("Unsupported value kind")
  }
}

pub fn BasicValueEnum::as_value_ref(self: BasicValueEnum) -> @unsafe.LLVMValueRef {
  match self {
    BasicValueEnum::ArrayValue(v) => v.as_value_ref()
    BasicValueEnum::IntValue(v) => v.as_value_ref()
    BasicValueEnum::FloatValue(v) => v.as_value_ref()
    BasicValueEnum::PointerValue(v) => v.as_value_ref()
    BasicValueEnum::StructValue(v) => v.as_value_ref()
    BasicValueEnum::VectorValue(v) => v.as_value_ref()
    BasicValueEnum::ScalableVectorValue(v) => v.as_value_ref()
  }
}

pub fn BasicValueEnum::get_name(self: BasicValueEnum) -> String {
  match self {
    BasicValueEnum::ArrayValue(v) => v.get_name()
    BasicValueEnum::IntValue(v) => v.get_name()
    BasicValueEnum::FloatValue(v) => v.get_name()
    BasicValueEnum::PointerValue(v) => v.get_name()
    BasicValueEnum::StructValue(v) => v.get_name()
    BasicValueEnum::VectorValue(v) => v.get_name()
    BasicValueEnum::ScalableVectorValue(v) => v.get_name()
  }
}

pub fn BasicValueEnum::set_name(self: BasicValueEnum, name: String) -> Unit {
  match self {
    BasicValueEnum::ArrayValue(v) => v.set_name(name)
    BasicValueEnum::IntValue(v) => v.set_name(name)
    BasicValueEnum::FloatValue(v) => v.set_name(name)
    BasicValueEnum::PointerValue(v) => v.set_name(name)
    BasicValueEnum::StructValue(v) => v.set_name(name)
    BasicValueEnum::VectorValue(v) => v.set_name(name)
    BasicValueEnum::ScalableVectorValue(v) => v.set_name(name)
  }
}

pub fn BasicValueEnum::get_type(self: BasicValueEnum) -> BasicTypeEnum {
  match self {
    BasicValueEnum::ArrayValue(v) => BasicTypeEnum::ArrayType(v.get_type())
    BasicValueEnum::IntValue(v) => BasicTypeEnum::IntType(v.get_type())
    BasicValueEnum::FloatValue(v) => BasicTypeEnum::FloatType(v.get_type())
    BasicValueEnum::PointerValue(v) => BasicTypeEnum::PointerType(v.get_type())
    BasicValueEnum::StructValue(v) => BasicTypeEnum::StructType(v.get_type())
    BasicValueEnum::VectorValue(v) => BasicTypeEnum::VectorType(v.get_type())
    BasicValueEnum::ScalableVectorValue(v) => BasicTypeEnum::ScalableVectorType(v.get_type())
  }
}

pub fn BasicValueEnum::is_array_value(self: BasicValueEnum) -> Bool {
  self is BasicValueEnum::ArrayValue(_)
}

pub fn BasicValueEnum::is_int_value(self: BasicValueEnum) -> Bool {
  self is BasicValueEnum::IntValue(_)
}

pub fn BasicValueEnum::is_float_value(self: BasicValueEnum) -> Bool {
  self is BasicValueEnum::FloatValue(_)
}

pub fn BasicValueEnum::is_pointer_value(self: BasicValueEnum) -> Bool {
  self is BasicValueEnum::PointerValue(_)
}

pub fn BasicValueEnum::is_struct_value(self: BasicValueEnum) -> Bool {
  self is BasicValueEnum::StructValue(_)
}

pub fn BasicValueEnum::is_vector_value(self: BasicValueEnum) -> Bool {
  self is BasicValueEnum::VectorValue(_)
}

pub fn BasicValueEnum::is_scalable_vector_value(self: BasicValueEnum) -> Bool {
  self is BasicValueEnum::ScalableVectorValue(_)
}

pub fn BasicValueEnum::into_array_value(self: BasicValueEnum) -> ArrayValue {
  match self {
    BasicValueEnum::ArrayValue(v) => v
    _ => abort("Found \{self} but expected the ArrayValue variant")
  }
}

pub fn BasicValueEnum::into_int_value(self: BasicValueEnum) -> IntValue {
  match self {
    BasicValueEnum::IntValue(v) => v
    _ => abort("Found \{self} but expected the IntValue variant")
  }
}

pub fn BasicValueEnum::into_float_value(self: BasicValueEnum) -> FloatValue {
  match self {
    BasicValueEnum::FloatValue(v) => v
    _ => abort("Found \{self} but expected the FloatValue variant")
  }
}

pub fn BasicValueEnum::into_pointer_value(self: BasicValueEnum) -> PointerValue {
  match self {
    BasicValueEnum::PointerValue(v) => v
    _ => abort("Found \{self} but expected the PointerValue variant")
  }
}
pub fn BasicValueEnum::into_struct_value(self: BasicValueEnum) -> StructValue {
  match self {
    BasicValueEnum::StructValue(v) => v
    _ => abort("Found \{self} but expected the StructValue variant")
  }
}

pub fn BasicValueEnum::into_vector_value(self: BasicValueEnum) -> VectorValue {
  match self {
    BasicValueEnum::VectorValue(v) => v
    _ => abort("Found \{self} but expected the VectorValue variant")
  }
}

pub fn BasicValueEnum::into_scalable_vector_value(self: BasicValueEnum) -> ScalableVectorValue {
  match self {
    BasicValueEnum::ScalableVectorValue(v) => v
    _ => abort("Found \{self} but expected the ScalableVectorValue variant")
  }
}

pub impl Show for BasicValueEnum with to_string(self: BasicValueEnum) -> String {
  match self {
    BasicValueEnum::ArrayValue(v) => v.to_string()
    BasicValueEnum::IntValue(v) => v.to_string()
    BasicValueEnum::FloatValue(v) => v.to_string()
    BasicValueEnum::PointerValue(v) => v.to_string()
    BasicValueEnum::StructValue(v) => v.to_string()
    BasicValueEnum::VectorValue(v) => v.to_string()
    BasicValueEnum::ScalableVectorValue(v) => v.to_string()
  }
}

pub impl Show for BasicValueEnum with output(self: BasicValueEnum, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

//=========================================================
// BasicMetadataValueEnum
//=========================================================
pub(all) enum BasicMetadataValueEnum {
  ArrayValue(ArrayValue);
  IntValue(IntValue);
  FloatValue(FloatValue);
  PointerValue(PointerValue);
  StructValue(StructValue);
  VectorValue(VectorValue);
  ScalableVectorValue(ScalableVectorValue);
  MetadataValue(MetadataValue);
}

pub fn BasicMetadataValueEnum::new(val_ref: @unsafe.LLVMValueRef) -> BasicMetadataValueEnum {
  let ty = val_ref.get_type();
  let kind = @unsafe.llvm_get_type_kind(ty);
  match kind {
    @unsafe.LLVMFloatTypeKind
    | @unsafe.LLVMFP128TypeKind
    | @unsafe.LLVMDoubleTypeKind
    | @unsafe.LLVMHalfTypeKind
    | @unsafe.LLVMX86_FP80TypeKind
    | @unsafe.LLVMPPC_FP128TypeKind => BasicMetadataValueEnum::FloatValue(FloatValue::new(val_ref))
    @unsafe.LLVMIntegerTypeKind => BasicMetadataValueEnum::IntValue(IntValue::new(val_ref))
    @unsafe.LLVMStructTypeKind => BasicMetadataValueEnum::StructValue(StructValue::new(val_ref))
    @unsafe.LLVMPointerTypeKind => BasicMetadataValueEnum::PointerValue(PointerValue::new(val_ref))
    @unsafe.LLVMArrayTypeKind => BasicMetadataValueEnum::ArrayValue(ArrayValue::new(val_ref))
    @unsafe.LLVMVectorTypeKind => BasicMetadataValueEnum::VectorValue(VectorValue::new(val_ref))
    // @unsafe.LLVMScalableVectorTypeKind => BasicMetadataValueEnum::ScalableVectorValue(ScalableVectorValue::new(val_ref)) // check if it is ok in llvm19
    @unsafe.LLVMMetadataTypeKind => BasicMetadataValueEnum::MetadataValue(MetadataValue::new(val_ref))
    _ => abort("Unsupported value kind")
  }
}

pub fn BasicMetadataValueEnum::as_value_ref(self: BasicMetadataValueEnum) -> @unsafe.LLVMValueRef {
  match self {
    ArrayValue(v) => v.as_value_ref()
    IntValue(v) => v.as_value_ref()
    FloatValue(v) => v.as_value_ref()
    PointerValue(v) => v.as_value_ref()
    StructValue(v) => v.as_value_ref()
    VectorValue(v) => v.as_value_ref()
    ScalableVectorValue(v) => v.as_value_ref()
    MetadataValue(v) => v.as_value_ref()
  }
}

pub fn BasicMetadataValueEnum::is_array_value(self: BasicMetadataValueEnum) -> Bool {
  self is BasicMetadataValueEnum::ArrayValue(_)
}

pub fn BasicMetadataValueEnum::is_int_value(self: BasicMetadataValueEnum) -> Bool {
  self is BasicMetadataValueEnum::IntValue(_)
}

pub fn BasicMetadataValueEnum::is_float_value(self: BasicMetadataValueEnum) -> Bool {
  self is BasicMetadataValueEnum::FloatValue(_)
}

pub fn BasicMetadataValueEnum::is_pointer_value(self: BasicMetadataValueEnum) -> Bool {
  self is BasicMetadataValueEnum::PointerValue(_)
}

pub fn BasicMetadataValueEnum::is_struct_value(self: BasicMetadataValueEnum) -> Bool {
  self is BasicMetadataValueEnum::StructValue(_)
}

pub fn BasicMetadataValueEnum::is_vector_value(self: BasicMetadataValueEnum) -> Bool {
  self is BasicMetadataValueEnum::VectorValue(_)
}

pub fn BasicMetadataValueEnum::is_scalable_vector_value(self: BasicMetadataValueEnum) -> Bool {
  self is BasicMetadataValueEnum::ScalableVectorValue(_)
}

pub fn BasicMetadataValueEnum::is_metadata_value(self: BasicMetadataValueEnum) -> Bool {
  self is BasicMetadataValueEnum::MetadataValue(_)
}

pub fn BasicMetadataValueEnum::into_array_value(self: BasicMetadataValueEnum) -> ArrayValue {
  match self {
    BasicMetadataValueEnum::ArrayValue(v) => v
    _ => abort("Found \{self} but expected the ArrayValue variant")
  }
}

pub fn BasicMetadataValueEnum::into_int_value(self: BasicMetadataValueEnum) -> IntValue {
  match self {
    BasicMetadataValueEnum::IntValue(v) => v
    _ => abort("Found \{self} but expected the IntValue variant")
  }
}

pub fn BasicMetadataValueEnum::into_float_value(self: BasicMetadataValueEnum) -> FloatValue {
  match self {
    BasicMetadataValueEnum::FloatValue(v) => v
    _ => abort("Found \{self} but expected the FloatValue variant")
  }
}

pub fn BasicMetadataValueEnum::into_pointer_value(self: BasicMetadataValueEnum) -> PointerValue {
  match self {
    BasicMetadataValueEnum::PointerValue(v) => v
    _ => abort("Found \{self} but expected the PointerValue variant")
  }
}

pub fn BasicMetadataValueEnum::into_struct_value(self: BasicMetadataValueEnum) -> StructValue {
  match self {
    BasicMetadataValueEnum::StructValue(v) => v
    _ => abort("Found \{self} but expected the StructValue variant")
  }
}

pub fn BasicMetadataValueEnum::into_vector_value(self: BasicMetadataValueEnum) -> VectorValue {
  match self {
    BasicMetadataValueEnum::VectorValue(v) => v
    _ => abort("Found \{self} but expected the VectorValue variant")
  }
}

// into ScalableVectorValue, MetadataValue

pub impl Show for BasicMetadataValueEnum with to_string(self: BasicMetadataValueEnum) -> String {
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

pub impl Show for BasicMetadataValueEnum with output(self: BasicMetadataValueEnum, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

//=========================================================
// AnyTypeEnum
//=========================================================
pub(all) enum AnyTypeEnum {
  ArrayType(ArrayType);
  FloatType(FloatType);
  FunctionType(FunctionType);
  IntType(IntType);
  PointerType(PointerType);
  StructType(StructType);
  VectorType(VectorType);
  ScalableVectorType(ScalableVectorType);
  VoidType(VoidType);
}

// TODO: Do not use `_` match
pub fn AnyTypeEnum::new(type_ref: @unsafe.LLVMTypeRef) -> AnyTypeEnum {
  let kind : @unsafe.LLVMTypeKind = @unsafe.llvm_get_type_kind(type_ref);
  match kind {
    @unsafe.LLVMVoidTypeKind =>VoidType(VoidType::new(type_ref))
    @unsafe.LLVMHalfTypeKind | 
    @unsafe.LLVMFloatTypeKind | 
    @unsafe.LLVMDoubleTypeKind | 
    @unsafe.LLVMX86_FP80TypeKind |
    @unsafe.LLVMFP128TypeKind |
    @unsafe.LLVMPPC_FP128TypeKind => FloatType(FloatType::new(type_ref))
    @unsafe.LLVMIntegerTypeKind => IntType(IntType::new(type_ref))
    @unsafe.LLVMFunctionTypeKind => FunctionType(FunctionType::new(type_ref))
    @unsafe.LLVMStructTypeKind => StructType(StructType::new(type_ref))
    @unsafe.LLVMArrayTypeKind => ArrayType(ArrayType::new(type_ref))
    @unsafe.LLVMVectorTypeKind => VectorType(VectorType::new(type_ref))
    @unsafe.LLVMScalableVectorTypeKind => ScalableVectorType(ScalableVectorType::new(type_ref))
    @unsafe.LLVMPointerTypeKind => PointerType(PointerType::new(type_ref))
    _ => {
      abort("Unsupported type kind \{kind}");
    }
  }
}

pub fn AnyTypeEnum::as_type_ref(self: AnyTypeEnum) -> @unsafe.LLVMTypeRef {
  match self {
    AnyTypeEnum::ArrayType(v) => v.as_type_ref()
    AnyTypeEnum::FloatType(v) => v.as_type_ref()
    AnyTypeEnum::FunctionType(v) => v.as_type_ref()
    AnyTypeEnum::IntType(v) => v.as_type_ref()
    AnyTypeEnum::PointerType(v) => v.as_type_ref()
    AnyTypeEnum::StructType(v) => v.as_type_ref()
    AnyTypeEnum::VectorType(v) => v.as_type_ref()
    AnyTypeEnum::ScalableVectorType(v) => v.as_type_ref()
    AnyTypeEnum::VoidType(v) => v.as_type_ref()
  }
}

pub impl Eq for AnyTypeEnum with op_equal(self: AnyTypeEnum, other: AnyTypeEnum) -> Bool {
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

pub fn AnyTypeEnum::is_array_type(self: AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::ArrayType(_)
}

pub fn AnyTypeEnum::is_float_type(self: AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::FloatType(_)
}

pub fn AnyTypeEnum::is_function_type(self: AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::FunctionType(_)
}

pub fn AnyTypeEnum::is_int_type(self: AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::IntType(_)
}

pub fn AnyTypeEnum::is_pointer_type(self: AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::PointerType(_)
}

pub fn AnyTypeEnum::is_struct_type(self: AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::StructType(_)
}

pub fn AnyTypeEnum::is_vector_type(self: AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::VectorType(_)
}

pub fn AnyTypeEnum::is_scalable_vector_type(self: AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::ScalableVectorType(_)
}

pub fn AnyTypeEnum::is_void_type(self: AnyTypeEnum) -> Bool {
  self is AnyTypeEnum::VoidType(_)
}

pub fn AnyTypeEnum::into_array_type(self: AnyTypeEnum) -> ArrayType {
  match self {
    AnyTypeEnum::ArrayType(v) => v
    _ => abort("Found \{self} but expected the ArrayType variant")
  }
}

pub fn AnyTypeEnum::into_float_type(self: AnyTypeEnum) -> FloatType {
  match self {
    AnyTypeEnum::FloatType(v) => v
    _ => abort("Found \{self} but expected the FloatType variant")
  }
}

pub fn AnyTypeEnum::into_function_type(self: AnyTypeEnum) -> FunctionType {
  match self {
    AnyTypeEnum::FunctionType(v) => v
    _ => abort("Found \{self} but expected the FunctionType variant")
  }
}

pub fn AnyTypeEnum::into_int_type(self: AnyTypeEnum) -> IntType {
  match self {
    AnyTypeEnum::IntType(v) => v
    _ => abort("Found \{self} but expected the IntType variant")
  }
}

pub fn AnyTypeEnum::into_pointer_type(self: AnyTypeEnum) -> PointerType {
  match self {
    AnyTypeEnum::PointerType(v) => v
    _ => abort("Found \{self} but expected the PointerType variant")
  }
}

pub fn AnyTypeEnum::into_struct_type(self: AnyTypeEnum) -> StructType {
  match self {
    AnyTypeEnum::StructType(v) => v
    _ => abort("Found \{self} but expected the StructType variant")
  }
}

pub fn AnyTypeEnum::into_vector_type(self: AnyTypeEnum) -> VectorType {
  match self {
    AnyTypeEnum::VectorType(v) => v
    _ => abort("Found \{self} but expected the VectorType variant")
  }
}

pub fn AnyTypeEnum::into_scalable_vector_type(self: AnyTypeEnum) -> ScalableVectorType {
  match self {
    AnyTypeEnum::ScalableVectorType(v) => v
    _ => abort("Found \{self} but expected the ScalableVectorType variant")
  }
}

pub fn AnyTypeEnum::into_void_type(self: AnyTypeEnum) -> VoidType {
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

pub impl Show for AnyTypeEnum with to_string(self: AnyTypeEnum) -> String {
  match self {
    AnyTypeEnum::ArrayType(v) => v.to_string()
    AnyTypeEnum::FloatType(v) => v.to_string()
    AnyTypeEnum::FunctionType(v) => v.to_string()
    AnyTypeEnum::IntType(v) => v.to_string()
    AnyTypeEnum::PointerType(v) => v.to_string()
    AnyTypeEnum::StructType(v) => v.to_string()
    AnyTypeEnum::VectorType(v) => v.to_string()
    AnyTypeEnum::ScalableVectorType(v) => v.to_string()
    AnyTypeEnum::VoidType(v) => v.to_string()
  }
}

pub impl Show for AnyTypeEnum with output(self: AnyTypeEnum, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

//=========================================================
// BasicType
//=========================================================
pub(all) enum BasicTypeEnum {
  ArrayType(ArrayType);
  FloatType(FloatType);
  IntType(IntType);
  PointerType(PointerType);
  StructType(StructType);
  VectorType(VectorType);
  ScalableVectorType(ScalableVectorType);
}


pub fn BasicTypeEnum::new(type_ref: @unsafe.LLVMTypeRef) -> BasicTypeEnum {
  let kind : @unsafe.LLVMTypeKind = @unsafe.llvm_get_type_kind(type_ref);
  match kind {
    @unsafe.LLVMHalfTypeKind | 
    @unsafe.LLVMFloatTypeKind | 
    @unsafe.LLVMDoubleTypeKind | 
    @unsafe.LLVMX86_FP80TypeKind |
    @unsafe.LLVMFP128TypeKind |
    @unsafe.LLVMPPC_FP128TypeKind => BasicTypeEnum::FloatType(FloatType::new(type_ref))
    @unsafe.LLVMIntegerTypeKind => BasicTypeEnum::IntType(IntType::new(type_ref))
    @unsafe.LLVMArrayTypeKind => BasicTypeEnum::ArrayType(ArrayType::new(type_ref))
    @unsafe.LLVMVectorTypeKind => BasicTypeEnum::VectorType(VectorType::new(type_ref))
    @unsafe.LLVMPointerTypeKind => BasicTypeEnum::PointerType(PointerType::new(type_ref))
    @unsafe.LLVMStructTypeKind => BasicTypeEnum::StructType(StructType::new(type_ref))
    _ => {
      abort("Unsupported type kind");
    }
  }
}

impl AsTypeRef for BasicTypeEnum with as_type_ref(self: BasicTypeEnum) -> @unsafe.LLVMTypeRef {
  match self {
    BasicTypeEnum::ArrayType(t) => t.as_type_ref()
    BasicTypeEnum::FloatType(t) => t.as_type_ref()
    BasicTypeEnum::IntType(t) => t.as_type_ref()
    BasicTypeEnum::PointerType(t) => t.as_type_ref()
    BasicTypeEnum::StructType(t) => t.as_type_ref()
    BasicTypeEnum::VectorType(t) => t.as_type_ref()
    BasicTypeEnum::ScalableVectorType(t) => t.as_type_ref()
  }
}

// only check class type
pub impl Eq for BasicTypeEnum with op_equal(self: BasicTypeEnum, other: BasicTypeEnum) -> Bool {
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

pub impl Show for BasicTypeEnum with to_string(self: BasicTypeEnum) -> String {
  match self {
    BasicTypeEnum::ArrayType(t) => t.to_string()
    BasicTypeEnum::FloatType(t) => t.to_string()
    BasicTypeEnum::IntType(t) => t.to_string()
    BasicTypeEnum::PointerType(t) => t.to_string()
    BasicTypeEnum::StructType(t) => t.to_string()
    BasicTypeEnum::VectorType(t) => t.to_string()
    BasicTypeEnum::ScalableVectorType(t) => t.to_string()
  }
}

pub impl Show for BasicTypeEnum with output(self: BasicTypeEnum, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

//=========================================================
// BasicMetadataTypeEnum
//=========================================================
pub(all) enum BasicMetadataTypeEnum {
  ArrayType(ArrayType);
  FloatType(FloatType);
  IntType(IntType);
  PointerType(PointerType);
  StructType(StructType);
  VectorType(VectorType);
  ScalableVectorType(ScalableVectorType);
  MetadataType(MetadataType);
}

pub fn BasicMetadataTypeEnum::new(type_ref: @unsafe.LLVMTypeRef) -> BasicMetadataTypeEnum {
  let kind : @unsafe.LLVMTypeKind = @unsafe.llvm_get_type_kind(type_ref);
  match kind {
    @unsafe.LLVMHalfTypeKind | 
    @unsafe.LLVMFloatTypeKind | 
    @unsafe.LLVMDoubleTypeKind | 
    @unsafe.LLVMX86_FP80TypeKind |
    @unsafe.LLVMFP128TypeKind |
    @unsafe.LLVMPPC_FP128TypeKind => BasicMetadataTypeEnum::FloatType(FloatType::new(type_ref))
    @unsafe.LLVMIntegerTypeKind => BasicMetadataTypeEnum::IntType(IntType::new(type_ref))
    @unsafe.LLVMArrayTypeKind => BasicMetadataTypeEnum::ArrayType(ArrayType::new(type_ref))
    @unsafe.LLVMVectorTypeKind => BasicMetadataTypeEnum::VectorType(VectorType::new(type_ref))
    @unsafe.LLVMPointerTypeKind => BasicMetadataTypeEnum::PointerType(PointerType::new(type_ref))
    @unsafe.LLVMStructTypeKind => BasicMetadataTypeEnum::StructType(StructType::new(type_ref))
    @unsafe.LLVMScalableVectorTypeKind => BasicMetadataTypeEnum::ScalableVectorType(ScalableVectorType::new(type_ref))
    @unsafe.LLVMMetadataTypeKind => BasicMetadataTypeEnum::MetadataType(MetadataType::new(type_ref))
    _ => {
      abort("Unsupported type kind");
    }
  }
}

pub fn BasicMetadataTypeEnum::as_type_ref(self: BasicMetadataTypeEnum) -> @unsafe.LLVMTypeRef {
  match self {
    BasicMetadataTypeEnum::ArrayType(t) => t.as_type_ref()
    BasicMetadataTypeEnum::FloatType(t) => t.as_type_ref()
    BasicMetadataTypeEnum::IntType(t) => t.as_type_ref()
    BasicMetadataTypeEnum::PointerType(t) => t.as_type_ref()
    BasicMetadataTypeEnum::StructType(t) => t.as_type_ref()
    BasicMetadataTypeEnum::VectorType(t) => t.as_type_ref()
    BasicMetadataTypeEnum::ScalableVectorType(t) => t.as_type_ref()
    BasicMetadataTypeEnum::MetadataType(t) => t.as_type_ref()
  }
}

pub impl Show for BasicMetadataTypeEnum with to_string(self: BasicMetadataTypeEnum) -> String {
  match self {
    BasicMetadataTypeEnum::ArrayType(v) => v.to_string()
    BasicMetadataTypeEnum::FloatType(v) => v.to_string()
    BasicMetadataTypeEnum::IntType(v) => v.to_string()
    BasicMetadataTypeEnum::PointerType(v) => v.to_string()
    BasicMetadataTypeEnum::StructType(v) => v.to_string()
    BasicMetadataTypeEnum::VectorType(v) => v.to_string()
    BasicMetadataTypeEnum::ScalableVectorType(v) => v.to_string()
    BasicMetadataTypeEnum::MetadataType(v) => v.to_string()
  }
}

pub impl Show for BasicMetadataTypeEnum with output(self: BasicMetadataTypeEnum, logger: &Logger) -> Unit {
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

