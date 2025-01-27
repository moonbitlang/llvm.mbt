//=========================================================
// AggregateValueEnum
//=========================================================
pub trait AggregateValue : AnyValue {
  as_aggregate_value_enum(Self) -> AggregateValueEnum;
}

pub enum AggregateValueEnum {
  ArrayValue(ArrayValue);
  StructValue(StructValue);
}

pub fn AggregateValueEnum::new(val_ref: LLVMValueRef) -> AggregateValueEnum {
  let ty = val_ref.get_type();
  let kind = llvm_get_type_kind(ty);
  match kind {
    LLVMTypeKind::LLVMArrayTypeKind => AggregateValueEnum::ArrayValue(ArrayValue::new(val_ref))
    LLVMTypeKind::LLVMStructTypeKind => AggregateValueEnum::StructValue(StructValue::new(val_ref))
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


pub fn AggregateValueEnum::as_value_ref(self: AggregateValueEnum) -> LLVMValueRef {
  match self {
    AggregateValueEnum::ArrayValue(v) => v.as_value_ref()
    AggregateValueEnum::StructValue(v) => v.as_value_ref()
  }
}

pub fn AggregateValueEnum::to_string(self: AggregateValueEnum) -> String {
  match self {
    AggregateValueEnum::ArrayValue(v) => v.to_string()
    AggregateValueEnum::StructValue(v) => v.to_string()
  }
}


//=========================================================
// AnyValue
//=========================================================
pub trait AnyValue : AsValueRef {
  as_any_value_enum(Self) -> AnyValueEnum;
}

pub enum AnyValueEnum {
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

pub fn AnyValueEnum::new(val_ref: LLVMValueRef) -> AnyValueEnum {
  let ty = val_ref.get_type();
  let kind = llvm_get_type_kind(ty);
  match kind {
  LLVMFloatTypeKind
  | LLVMFP128TypeKind
  | LLVMDoubleTypeKind
  | LLVMHalfTypeKind
  | LLVMX86_FP80TypeKind
  | LLVMPPC_FP128TypeKind => FloatValue(FloatValue::new(val_ref))
  LLVMIntegerTypeKind => IntValue(IntValue::new(val_ref))
  LLVMStructTypeKind => AnyValueEnum::StructValue(StructValue::new(val_ref))
  LLVMPointerTypeKind => match llvm_get_value_kind(val_ref) {
    LLVMFunctionValueKind => FunctionValue(FunctionValue::new(val_ref).unwrap())
    _ => PointerValue(PointerValue::new(val_ref))
  }
  LLVMArrayTypeKind => AnyValueEnum::ArrayValue(ArrayValue::new(val_ref))
  LLVMVectorTypeKind => AnyValueEnum::VectorValue(VectorValue::new(val_ref))
  LLVMFunctionTypeKind => FunctionValue(FunctionValue::new(val_ref).unwrap())
  LLVMVoidTypeKind => {
    if val_ref.isa_instruction().is_null() {
      abort("Void value must be an instruction");
    }
    InstructionValue(InstructionValue::new(val_ref))
  }
  LLVMMetadataTypeKind => MetadataValue(MetadataValue::new(val_ref))
  _ => abort("Unsupported value kind")
  }
}

pub fn AnyValueEnum::as_value_ref(self: AnyValueEnum) -> LLVMValueRef {
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
  match self {
    AnyValueEnum::ArrayValue(_) => true
    _ => false
  }
}

//=========================================================
// BasicValue
//=========================================================

pub trait BasicValue : AnyValue {
  as_basic_value_enum(Self) -> BasicValueEnum;
}

pub enum BasicValueEnum {
  ArrayValue(ArrayValue);
  IntValue(IntValue);
  FloatValue(FloatValue);
  PointerValue(PointerValue);
  StructValue(StructValue);
  VectorValue(VectorValue);
  ScalableVectorValue(ScalableVectorValue);
}

pub fn BasicValueEnum::new(val_ref: LLVMValueRef) -> BasicValueEnum {
  let ty = val_ref.get_type();
  let kind = llvm_get_type_kind(ty);
  match kind {
    LLVMFloatTypeKind
    | LLVMFP128TypeKind
    | LLVMDoubleTypeKind
    | LLVMHalfTypeKind
    | LLVMX86_FP80TypeKind
    | LLVMPPC_FP128TypeKind => BasicValueEnum::FloatValue(FloatValue::new(val_ref))
    LLVMIntegerTypeKind => BasicValueEnum::IntValue(IntValue::new(val_ref))
    LLVMStructTypeKind => BasicValueEnum::StructValue(StructValue::new(val_ref))
    LLVMPointerTypeKind => BasicValueEnum::PointerValue(PointerValue::new(val_ref))
    LLVMArrayTypeKind => BasicValueEnum::ArrayValue(ArrayValue::new(val_ref))
    LLVMVectorTypeKind => BasicValueEnum::VectorValue(VectorValue::new(val_ref))
    // LLVMScalableVectorTypeKind => BasicValueEnum::ScalableVectorValue(ScalableVectorValue::new(val_ref)) // Check if it ok in llvm-19 above
    _ => abort("Unsupported value kind")
  }
}

pub fn BasicValueEnum::as_value_ref(self: BasicValueEnum) -> LLVMValueRef {
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
  match self {
    BasicValueEnum::ArrayValue(_) => true
    _ => false
  }
}

pub fn BasicValueEnum::is_int_value(self: BasicValueEnum) -> Bool {
  match self {
    BasicValueEnum::IntValue(_) => true
    _ => false
  }
}

pub fn BasicValueEnum::is_float_value(self: BasicValueEnum) -> Bool {
  match self {
    BasicValueEnum::FloatValue(_) => true
    _ => false
  }
}

pub fn BasicValueEnum::is_pointer_value(self: BasicValueEnum) -> Bool {
  match self {
    BasicValueEnum::PointerValue(_) => true
    _ => false
  }
}

pub fn BasicValueEnum::is_struct_value(self: BasicValueEnum) -> Bool {
  match self {
    BasicValueEnum::StructValue(_) => true
    _ => false
  }
}

pub fn BasicValueEnum::is_vector_value(self: BasicValueEnum) -> Bool {
  match self {
    BasicValueEnum::VectorValue(_) => true
    _ => false
  }
}

pub fn BasicValueEnum::is_scalable_vector_value(self: BasicValueEnum) -> Bool {
  match self {
    BasicValueEnum::ScalableVectorValue(_) => true
    _ => false
  }
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


pub fn  BasicValueEnum :: to_string(self: BasicValueEnum) -> String {
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

//=========================================================
// BasicMetadataValue
//=========================================================

pub trait BasicMetadataValue : AnyValue {
  as_basic_metadata_value_enum(Self) -> BasicMetadataValueEnum;
}

pub enum BasicMetadataValueEnum {
  ArrayValue(ArrayValue);
  IntValue(IntValue);
  FloatValue(FloatValue);
  PointerValue(PointerValue);
  StructValue(StructValue);
  VectorValue(VectorValue);
  ScalableVectorValue(ScalableVectorValue);
  MetadataValue(MetadataValue);
}

pub fn BasicMetadataValueEnum::new(val_ref: LLVMValueRef) -> BasicMetadataValueEnum {
  let ty = val_ref.get_type();
  let kind = llvm_get_type_kind(ty);
  match kind {
    LLVMFloatTypeKind
    | LLVMFP128TypeKind
    | LLVMDoubleTypeKind
    | LLVMHalfTypeKind
    | LLVMX86_FP80TypeKind
    | LLVMPPC_FP128TypeKind => BasicMetadataValueEnum::FloatValue(FloatValue::new(val_ref))
    LLVMIntegerTypeKind => BasicMetadataValueEnum::IntValue(IntValue::new(val_ref))
    LLVMStructTypeKind => BasicMetadataValueEnum::StructValue(StructValue::new(val_ref))
    LLVMPointerTypeKind => BasicMetadataValueEnum::PointerValue(PointerValue::new(val_ref))
    LLVMArrayTypeKind => BasicMetadataValueEnum::ArrayValue(ArrayValue::new(val_ref))
    LLVMVectorTypeKind => BasicMetadataValueEnum::VectorValue(VectorValue::new(val_ref))
    // LLVMScalableVectorTypeKind => BasicMetadataValueEnum::ScalableVectorValue(ScalableVectorValue::new(val_ref)) // check if it is ok in llvm19
    LLVMMetadataTypeKind => BasicMetadataValueEnum::MetadataValue(MetadataValue::new(val_ref))
    _ => abort("Unsupported value kind")
  }
}

pub fn BasicMetadataValueEnum::as_value_ref(self: BasicMetadataValueEnum) -> LLVMValueRef {
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
  match self {
    BasicMetadataValueEnum::ArrayValue(_) => true
    _ => false
  }
}

pub fn BasicMetadataValueEnum::is_int_value(self: BasicMetadataValueEnum) -> Bool {
  match self {
    BasicMetadataValueEnum::IntValue(_) => true
    _ => false
  }
}

pub fn BasicMetadataValueEnum::is_float_value(self: BasicMetadataValueEnum) -> Bool {
  match self {
    BasicMetadataValueEnum::FloatValue(_) => true
    _ => false
  }
}

pub fn BasicMetadataValueEnum::is_pointer_value(self: BasicMetadataValueEnum) -> Bool {
  match self {
    BasicMetadataValueEnum::PointerValue(_) => true
    _ => false
  }
}

pub fn BasicMetadataValueEnum::is_struct_value(self: BasicMetadataValueEnum) -> Bool {
  match self {
    BasicMetadataValueEnum::StructValue(_) => true
    _ => false
  }
}

pub fn BasicMetadataValueEnum::is_vector_value(self: BasicMetadataValueEnum) -> Bool {
  match self {
    BasicMetadataValueEnum::VectorValue(_) => true
    _ => false
  }
}

pub fn BasicMetadataValueEnum::is_scalable_vector_value(self: BasicMetadataValueEnum) -> Bool {
  match self {
   BasicMetadataValueEnum::ScalableVectorValue(_) => true
   _ => false
  }
}

pub fn BasicMetadataValueEnum::is_metadata_value(self: BasicMetadataValueEnum) -> Bool {
  match self {
    BasicMetadataValueEnum::MetadataValue(_) => true
    _ => false
  }
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

pub fn BasicMetadataValueEnum::to_string(self: BasicMetadataValueEnum) -> String {
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

//=========================================================
// AnyType
//=========================================================

trait AnyType : AsTypeRef {
  as_any_type_enum(Self) -> AnyTypeEnum;
}

pub enum AnyTypeEnum {
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
pub fn AnyTypeEnum::new(type_ref: LLVMTypeRef) -> AnyTypeEnum {
  let kind : LLVMTypeKind = llvm_get_type_kind(type_ref);
  match kind {
    LLVMVoidTypeKind => AnyTypeEnum::VoidType(VoidType::new(type_ref))
    LLVMHalfTypeKind | 
    LLVMFloatTypeKind | 
    LLVMDoubleTypeKind | 
    LLVMX86_FP80TypeKind |
    LLVMFP128TypeKind |
    LLVMPPC_FP128TypeKind => AnyTypeEnum::FloatType(FloatType::new(type_ref))
    LLVMIntegerTypeKind => AnyTypeEnum::IntType(IntType::new(type_ref))
    LLVMFunctionTypeKind => AnyTypeEnum::FunctionType(FunctionType::new(type_ref))
    LLVMStructTypeKind => AnyTypeEnum::StructType(StructType::new(type_ref))
    LLVMArrayTypeKind => AnyTypeEnum::ArrayType(ArrayType::new(type_ref))
    LLVMVectorTypeKind => AnyTypeEnum::VectorType(VectorType::new(type_ref))
    LLVMPointerTypeKind => AnyTypeEnum::PointerType(PointerType::new(type_ref))
    _ => {
      abort("Unsupported type kind");
    }
  }
}

pub fn AnyTypeEnum::is_array_type(self: AnyTypeEnum) -> Bool {
  match self {
    AnyTypeEnum::ArrayType(_) => true
    _ => false
  }
}

pub fn AnyTypeEnum::is_float_type(self: AnyTypeEnum) -> Bool {
  match self {
    AnyTypeEnum::FloatType(_) => true
    _ => false
  }
}

pub fn AnyTypeEnum::is_function_type(self: AnyTypeEnum) -> Bool {
  match self {
    AnyTypeEnum::FunctionType(_) => true
    _ => false
  }
}

pub fn AnyTypeEnum::is_int_type(self: AnyTypeEnum) -> Bool {
  match self {
    AnyTypeEnum::IntType(_) => true
    _ => false
  }
}

pub fn AnyTypeEnum::is_pointer_type(self: AnyTypeEnum) -> Bool {
  match self {
    AnyTypeEnum::PointerType(_) => true
    _ => false
  }
}

pub fn AnyTypeEnum::is_struct_type(self: AnyTypeEnum) -> Bool {
  match self {
    AnyTypeEnum::StructType(_) => true
    _ => false
  }
}

pub fn AnyTypeEnum::is_vector_type(self: AnyTypeEnum) -> Bool {
  match self {
    AnyTypeEnum::VectorType(_) => true
    _ => false
  }
}

pub fn AnyTypeEnum::is_scalable_vector_type(self: AnyTypeEnum) -> Bool {
  match self {
    AnyTypeEnum::ScalableVectorType(_) => true
    _ => false
  }
}

pub fn AnyTypeEnum::is_void_type(self: AnyTypeEnum) -> Bool {
  match self {
    AnyTypeEnum::VoidType(_) => true
    _ => false
  }
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

pub fn AnyTypeEnum::to_string(self: AnyTypeEnum) -> String {
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

//=========================================================
// BasicType
//=========================================================

trait BasicType : AnyType {
  as_basic_type_enum(Self) -> BasicTypeEnum;
}

pub enum BasicTypeEnum {
  ArrayType(ArrayType);
  FloatType(FloatType);
  IntType(IntType);
  PointerType(PointerType);
  StructType(StructType);
  VectorType(VectorType);
  ScalableVectorType(ScalableVectorType);
}


pub fn BasicTypeEnum::new(type_ref: LLVMTypeRef) -> BasicTypeEnum {
  let kind : LLVMTypeKind = llvm_get_type_kind(type_ref);
  match kind {
    LLVMHalfTypeKind | 
    LLVMFloatTypeKind | 
    LLVMDoubleTypeKind | 
    LLVMX86_FP80TypeKind |
    LLVMFP128TypeKind |
    LLVMPPC_FP128TypeKind => BasicTypeEnum::FloatType(FloatType::new(type_ref))
    LLVMIntegerTypeKind => BasicTypeEnum::IntType(IntType::new(type_ref))
    LLVMArrayTypeKind => BasicTypeEnum::ArrayType(ArrayType::new(type_ref))
    LLVMVectorTypeKind => BasicTypeEnum::VectorType(VectorType::new(type_ref))
    LLVMPointerTypeKind => BasicTypeEnum::PointerType(PointerType::new(type_ref))
    LLVMStructTypeKind => BasicTypeEnum::StructType(StructType::new(type_ref))
    _ => {
      abort("Unsupported type kind");
    }
  }
}

impl AsTypeRef for BasicTypeEnum with as_type_ref(self: BasicTypeEnum) -> LLVMTypeRef {
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

//=========================================================
// BasicMetadataType
//=========================================================

pub enum BasicMetadataTypeEnum {
  ArrayType(ArrayType);
  FloatType(FloatType);
  IntType(IntType);
  PointerType(PointerType);
  StructType(StructType);
  VectorType(VectorType);
  ScalableVectorType(ScalableVectorType);
  MetadataType(MetadataType);
}

pub fn BasicMetadataTypeEnum::new(type_ref: LLVMTypeRef) -> BasicMetadataTypeEnum {
  let kind : LLVMTypeKind = llvm_get_type_kind(type_ref);
  match kind {
    LLVMHalfTypeKind | 
    LLVMFloatTypeKind | 
    LLVMDoubleTypeKind | 
    LLVMX86_FP80TypeKind |
    LLVMFP128TypeKind |
    LLVMPPC_FP128TypeKind => BasicMetadataTypeEnum::FloatType(FloatType::new(type_ref))
    LLVMIntegerTypeKind => BasicMetadataTypeEnum::IntType(IntType::new(type_ref))
    LLVMArrayTypeKind => BasicMetadataTypeEnum::ArrayType(ArrayType::new(type_ref))
    LLVMVectorTypeKind => BasicMetadataTypeEnum::VectorType(VectorType::new(type_ref))
    LLVMPointerTypeKind => BasicMetadataTypeEnum::PointerType(PointerType::new(type_ref))
    LLVMStructTypeKind => BasicMetadataTypeEnum::StructType(StructType::new(type_ref))
    LLVMScalableVectorTypeKind => BasicMetadataTypeEnum::ScalableVectorType(ScalableVectorType::new(type_ref))
    LLVMMetadataTypeKind => BasicMetadataTypeEnum::MetadataType(MetadataType::new(type_ref))
    _ => {
      abort("Unsupported type kind");
    }
  }
}
