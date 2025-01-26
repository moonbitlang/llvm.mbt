// pub enum AggregateValue {
//   // ArrayValue(ArrayValue);
//   StructValue(StructValue);
// }

pub trait AnyValue : AsValueRef {
  as_any_value_enum(Self) -> AnyValueEnum;
}

pub enum AnyValueEnum {
  // ArrayValue(ArrayValue);
  IntValue(IntValue);
  FloatValue(FloatValue);
  // PhiValue(PhiValue);
  FunctionValue(FunctionValue);
  PointerValue(PointerValue);
  StructValue(StructValue);
  // VectorValue(VectorValue);
  // ScalableVectorValue(ScalableVectorValue);
  InstructionValue(InstructionValue);
  // MetadataValue(MetadataValue);
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
  LLVMTypeKind::LLVMStructTypeKind => AnyValueEnum::StructValue(StructValue::new(val_ref))
  LLVMPointerTypeKind => match llvm_get_value_kind(val_ref) {
    LLVMFunctionValueKind => FunctionValue(FunctionValue::new(val_ref).unwrap())
    _ => PointerValue(PointerValue::new(val_ref))
  }
  // LLVMTypeKind::LLVMArrayTypeKind => AnyValueEnum::ArrayValue(ArrayValue::new(val_ref))
  // LLVMTypeKind::LLVMVectorTypeKind => AnyValueEnum::VectorValue(VectorValue::new(val_ref))
  LLVMFunctionTypeKind => FunctionValue(FunctionValue::new(val_ref).unwrap())
  LLVMVoidTypeKind => {
    if val_ref.isa_instruction().is_null() {
      abort("Void value must be an instruction");
    }
    InstructionValue(InstructionValue::new(val_ref))
  }
  LLVMMetadataTypeKind => abort("Metadata value is not supported")
  _ => abort("Unsupported value kind")
  }
}

pub fn AnyValueEnum::as_value_ref(self: AnyValueEnum) -> LLVMValueRef {
  match self {
    // AnyValueEnum::ArrayValue(v) => v.as_value_ref(,
    AnyValueEnum::IntValue(v) => v.as_value_ref()
    AnyValueEnum::FloatValue(v) => v.as_value_ref()
    // AnyValueEnum::PhiValue(v) => v.as_value_ref()
    AnyValueEnum::FunctionValue(v) => v.as_value_ref()
    AnyValueEnum::PointerValue(v) => v.as_value_ref()
    AnyValueEnum::StructValue(v) => v.as_value_ref()
    // AnyValueEnum::VectorValue(v) => v.as_value_ref()
    // AnyValueEnum::ScalableVectorValue(v) => v.as_value_ref()
    AnyValueEnum::InstructionValue(v) => v.as_value_ref()
    // AnyValueEnum::MetadataValue(v) => v.as_value_ref()
  }
}

pub fn AnyValueEnum::get_type(self: AnyValueEnum) -> AnyTypeEnum {
  AnyTypeEnum::new(self.as_value_ref().get_type())
}

pub fn AnyValueEnum::is_array_value(self: AnyValueEnum) -> Bool {
  match self {
    // AnyValueEnum::ArrayValue(_) => true
    _ => false
  }
}

pub trait BasicValue : AnyValue {
  as_basic_value_enum(Self) -> BasicValueEnum;
}

pub enum BasicValueEnum {
  // ArrayValue(ArrayValue);
  IntValue(IntValue);
  FloatValue(FloatValue);
  PointerValue(PointerValue);
  StructValue(StructValue);
  // VectorValue(VectorValue);
  // ScalableVectorValue(ScalableVectorValue);
}

pub fn BasicValueEnum::as_value_ref(self: BasicValueEnum) -> LLVMValueRef {
  match self {
    // BasicValueEnum::ArrayValue(v) => v.as_value_ref(),
    BasicValueEnum::IntValue(v) => v.as_value_ref()
    BasicValueEnum::FloatValue(v) => v.as_value_ref()
    BasicValueEnum::PointerValue(v) => v.as_value_ref()
    BasicValueEnum::StructValue(v) => v.as_value_ref()
    // BasicValueEnum::VectorValue(v) => v.as_value_ref(),
    // BasicValueEnum::ScalableVectorValue(v) => v.as_value_ref(),
  }
}

pub trait BasicMetadataValue : AnyValue {
  as_basic_metadata_value_enum(Self) -> BasicMetadataValueEnum;
}

pub enum BasicMetadataValueEnum {
  // ArrayValue(ArrayValue);
  IntValue(IntValue);
  FloatValue(FloatValue);
  PointerValue(PointerValue);
  StructValue(StructValue);
  // VectorValue(VectorValue);
  // ScalableVectorValue(ScalableVectorValue);
  // MetadataValue(MetadataValue);
}

pub fn BasicMetadataValueEnum::as_value_ref(self: BasicMetadataValueEnum) -> LLVMValueRef {
  match self {
    // BasicMetadataValueEnum::ArrayValue(v) => v.as_value_ref(),
    BasicMetadataValueEnum::IntValue(v) => v.as_value_ref()
    BasicMetadataValueEnum::FloatValue(v) => v.as_value_ref()
    BasicMetadataValueEnum::PointerValue(v) => v.as_value_ref()
    BasicMetadataValueEnum::StructValue(v) => v.as_value_ref()
    // BasicMetadataValueEnum::VectorValue(v) => v.as_value_ref(),
    // BasicMetadataValueEnum::ScalableVectorValue(v) => v.as_value_ref(),
    // BasicMetadataValueEnum::MetadataValue(v) => v.as_value_ref(),
  }
}


pub enum AnyTypeEnum {
  // ArrayType(ArrayType);
  FloatType(FloatType);
  FunctionType(FunctionType);
  IntType(IntType);
  PointerType(PointerType);
  StructType(StructType);
  // VectorType(VectorType);
  // ScalableVectorType(ScalableVectorType);
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
    // LLVMArrayTypeKind => AnyTypeEnum::ArrayType(ArrayType::new(type_ref))
    // LLVMVectorTypeKind => AnyTypeEnum::VectorType(VectorType::new(type_ref))
    LLVMPointerTypeKind => AnyTypeEnum::PointerType(PointerType::new(type_ref))
    _ => {
      abort("Unsupported type kind");
    }
  }
}

// pub fn AnyTypeEnum::size_of(self: AnyTypeEnum) -> IntValue? {
//   match self {
//     ArrayType(t) => t.size_of(),
//     FloatType(t) => t.size_of(),
//     FunctionType(t) => t.size_of(),
//     PointerType(t) => t.size_of(),
//     StructType(t) => t.size_of(),
//     VectorType(t) => t.size_of(),
//   }
// }

// pub fn AnyTypeEnum::to_string(self: AnyTypeEnum) -> String {
//   match 
// }


pub enum BasicTypeEnum {
  // ArrayType(ArrayType);
  FloatType(FloatType);
  IntType(IntType);
  PointerType(PointerType);
  StructType(StructType);
  // VectorType(VectorType);
  // ScalableVectorType(ScalableVectorType);
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
    // LLVMArrayTypeKind => BasicTypeEnum::ArrayType(ArrayType::new(type_ref))
    // LLVMVectorTypeKind => BasicTypeEnum::VectorType(VectorType::new(type_ref))
    LLVMPointerTypeKind => BasicTypeEnum::PointerType(PointerType::new(type_ref))
    LLVMStructTypeKind => BasicTypeEnum::StructType(StructType::new(type_ref))
    _ => {
      abort("Unsupported type kind");
    }
  }
}

impl AsTypeRef for BasicTypeEnum with as_type_ref(self: BasicTypeEnum) -> LLVMTypeRef {
  match self {
    // BasicTypeEnum::ArrayType(t) => t.as_type_ref(),
    BasicTypeEnum::FloatType(t) => t.as_type_ref()
    BasicTypeEnum::IntType(t) => t.as_type_ref()
    BasicTypeEnum::PointerType(t) => t.as_type_ref()
    BasicTypeEnum::StructType(t) => t.as_type_ref()
    // BasicTypeEnum::VectorType(t) => t.as_type_ref(),
    // BasicTypeEnum::ScalableVectorType(t) => t.as_type_ref(),
  }
}

pub enum BasicMetadataTypeEnum {
  // ArrayType(ArrayType);
  FloatType(FloatType);
  IntType(IntType);
  PointerType(PointerType);
  StructType(StructType);
  // VectorType(VectorType);
  // ScalableVectorType(ScalableVectorType);
  // MetadataType(MetadataType);
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
    // LLVMArrayTypeKind => BasicMetadataTypeEnum::ArrayType(ArrayType::new(type_ref))
    // LLVMVectorTypeKind => BasicMetadataTypeEnum::VectorType(VectorType::new(type_ref))
    LLVMPointerTypeKind => BasicMetadataTypeEnum::PointerType(PointerType::new(type_ref))
    LLVMStructTypeKind => BasicMetadataTypeEnum::StructType(StructType::new(type_ref))
    // LLVMScalableVectorTypeKind => BasicMetadataTypeEnum::ScalableVectorType(ScalableVectorType::new(type_ref))
    // LLVMMetadataTypeKind => BasicMetadataTypeEnum::MetadataType(MetadataType::new(type_ref))
    _ => {
      abort("Unsupported type kind");
    }
  }
}
