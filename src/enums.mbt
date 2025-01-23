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

impl TypeRef for BasicTypeEnum with as_type_ref(self: BasicTypeEnum) -> LLVMTypeRef {
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
