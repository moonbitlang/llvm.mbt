///|
/// Exposes the selected `Default` methods as regular methods on `AddressSpace`.
pub extend AddressSpace with Default::{default}

///|
/// Exposes the selected `Eq` methods as regular methods on `AddressSpace`.
pub extend AddressSpace with Eq::{not_equal, equal}

///|
/// Exposes the selected `Hash` methods as regular methods on `AddressSpace`.
pub extend AddressSpace with Hash::{hash, hash_combine}

///|
/// Exposes the selected `Eq` methods as regular methods on `AggregateTypeEnum`.
pub extend AggregateTypeEnum with Eq::{not_equal, equal}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `AllocaInst`.
pub extend AllocaInst with InsertPoint::{asInsertPtEnum}

///|
/// Exposes the selected `Instruction` methods as regular methods on `AllocaInst`.
pub extend AllocaInst with Instruction::{
  getNextInst,
  getParentBasicBlock,
  getPrevInst,
  removeFromParent,
  getNumArgOperands,
  asInstEnum,
  eraseFromParent,
}

///|
/// Exposes the selected `Show` methods as regular methods on `AllocaInst`.
pub extend AllocaInst with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `AllocaInst`.
pub extend AllocaInst with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Show` methods as regular methods on `Argument`.
pub extend Argument with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `Argument`.
pub extend Argument with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `ArrayType`.
pub extend ArrayType with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `ArrayType`.
pub extend ArrayType with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `ArrayType`.
pub extend ArrayType with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `BFloatType`.
pub extend BFloatType with Eq::{not_equal, equal}

///|
/// Exposes the selected `FPType` methods as regular methods on `BFloatType`.
pub extend BFloatType with FPType::{getFPMantissaWidth}

///|
/// Exposes the selected `PrimitiveType` methods as regular methods on `BFloatType`.
pub extend BFloatType with PrimitiveType::{getBitWidth}

///|
/// Exposes the selected `Show` methods as regular methods on `BFloatType`.
pub extend BFloatType with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `BFloatType`.
pub extend BFloatType with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Show` methods as regular methods on `BasicBlock`.
pub extend BasicBlock with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `BasicBlock`.
pub extend BasicBlock with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Instruction` methods as regular methods on `BinaryInst`.
pub extend BinaryInst with Instruction::{
  getNextInst,
  getParentBasicBlock,
  getPrevInst,
  removeFromParent,
  getNumArgOperands,
  asInstEnum,
  eraseFromParent,
}

///|
/// Exposes the selected `Show` methods as regular methods on `BinaryInst`.
pub extend BinaryInst with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `BinaryInst`.
pub extend BinaryInst with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Instruction` methods as regular methods on `BranchInst`.
pub extend BranchInst with Instruction::{
  getNextInst,
  getParentBasicBlock,
  getPrevInst,
  removeFromParent,
  getNumArgOperands,
  asInstEnum,
  eraseFromParent,
}

///|
/// Exposes the selected `Show` methods as regular methods on `BranchInst`.
pub extend BranchInst with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `BranchInst`.
pub extend BranchInst with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Instruction` methods as regular methods on `CallInst`.
pub extend CallInst with Instruction::{
  getNextInst,
  getParentBasicBlock,
  getPrevInst,
  removeFromParent,
  getNumArgOperands,
  asInstEnum,
  eraseFromParent,
}

///|
/// Exposes the selected `Show` methods as regular methods on `CallInst`.
pub extend CallInst with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `CallInst`.
pub extend CallInst with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Instruction` methods as regular methods on `CastInst`.
pub extend CastInst with Instruction::{
  getNextInst,
  getParentBasicBlock,
  getPrevInst,
  removeFromParent,
  getNumArgOperands,
  asInstEnum,
  eraseFromParent,
}

///|
/// Exposes the selected `Show` methods as regular methods on `CastInst`.
pub extend CastInst with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `CastInst`.
pub extend CastInst with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Constant` methods as regular methods on `ConstantArray`.
pub extend ConstantArray with Constant::{asConstantEnum}

///|
/// Exposes the selected `Show` methods as regular methods on `ConstantArray`.
pub extend ConstantArray with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `ConstantArray`.
pub extend ConstantArray with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Constant` methods as regular methods on `ConstantExpr`.
pub extend ConstantExpr with Constant::{asConstantEnum}

///|
/// Exposes the selected `Show` methods as regular methods on `ConstantExpr`.
pub extend ConstantExpr with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `ConstantExpr`.
pub extend ConstantExpr with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Constant` methods as regular methods on `ConstantFP`.
pub extend ConstantFP with Constant::{asConstantEnum}

///|
/// Exposes the selected `Show` methods as regular methods on `ConstantFP`.
pub extend ConstantFP with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `ConstantFP`.
pub extend ConstantFP with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Constant` methods as regular methods on `ConstantInt`.
pub extend ConstantInt with Constant::{asConstantEnum}

///|
/// Exposes the selected `Show` methods as regular methods on `ConstantInt`.
pub extend ConstantInt with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `ConstantInt`.
pub extend ConstantInt with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Constant` methods as regular methods on `ConstantPointerNull`.
pub extend ConstantPointerNull with Constant::{asConstantEnum}

///|
/// Exposes the selected `Show` methods as regular methods on `ConstantPointerNull`.
pub extend ConstantPointerNull with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `ConstantPointerNull`.
pub extend ConstantPointerNull with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Constant` methods as regular methods on `ConstantStruct`.
pub extend ConstantStruct with Constant::{asConstantEnum}

///|
/// Exposes the selected `Show` methods as regular methods on `ConstantStruct`.
pub extend ConstantStruct with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `ConstantStruct`.
pub extend ConstantStruct with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Constant` methods as regular methods on `ConstantVector`.
pub extend ConstantVector with Constant::{asConstantEnum}

///|
/// Exposes the selected `Show` methods as regular methods on `ConstantVector`.
pub extend ConstantVector with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `ConstantVector`.
pub extend ConstantVector with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `Context`.
pub extend Context with Eq::{not_equal, equal}

///|
/// Exposes the selected `Eq` methods as regular methods on `DoubleType`.
pub extend DoubleType with Eq::{not_equal, equal}

///|
/// Exposes the selected `FPType` methods as regular methods on `DoubleType`.
pub extend DoubleType with FPType::{getFPMantissaWidth}

///|
/// Exposes the selected `PrimitiveType` methods as regular methods on `DoubleType`.
pub extend DoubleType with PrimitiveType::{getBitWidth}

///|
/// Exposes the selected `Show` methods as regular methods on `DoubleType`.
pub extend DoubleType with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `DoubleType`.
pub extend DoubleType with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Instruction` methods as regular methods on `ExtractValueInst`.
pub extend ExtractValueInst with Instruction::{
  getNextInst,
  getParentBasicBlock,
  getPrevInst,
  removeFromParent,
  getNumArgOperands,
  asInstEnum,
  eraseFromParent,
}

///|
/// Exposes the selected `Show` methods as regular methods on `ExtractValueInst`.
pub extend ExtractValueInst with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `ExtractValueInst`.
pub extend ExtractValueInst with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Instruction` methods as regular methods on `FCmpInst`.
pub extend FCmpInst with Instruction::{
  getNextInst,
  getParentBasicBlock,
  getPrevInst,
  removeFromParent,
  getNumArgOperands,
  asInstEnum,
  eraseFromParent,
}

///|
/// Exposes the selected `Show` methods as regular methods on `FCmpInst`.
pub extend FCmpInst with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `FCmpInst`.
pub extend FCmpInst with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `FP128Type`.
pub extend FP128Type with Eq::{not_equal, equal}

///|
/// Exposes the selected `FPType` methods as regular methods on `FP128Type`.
pub extend FP128Type with FPType::{getFPMantissaWidth}

///|
/// Exposes the selected `PrimitiveType` methods as regular methods on `FP128Type`.
pub extend FP128Type with PrimitiveType::{getBitWidth}

///|
/// Exposes the selected `Show` methods as regular methods on `FP128Type`.
pub extend FP128Type with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `FP128Type`.
pub extend FP128Type with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `FPTypeEnum`.
pub extend FPTypeEnum with Eq::{not_equal, equal}

///|
/// Exposes the selected `Eq` methods as regular methods on `FloatType`.
pub extend FloatType with Eq::{not_equal, equal}

///|
/// Exposes the selected `FPType` methods as regular methods on `FloatType`.
pub extend FloatType with FPType::{getFPMantissaWidth}

///|
/// Exposes the selected `PrimitiveType` methods as regular methods on `FloatType`.
pub extend FloatType with PrimitiveType::{getBitWidth}

///|
/// Exposes the selected `Show` methods as regular methods on `FloatType`.
pub extend FloatType with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `FloatType`.
pub extend FloatType with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `FnAttr`.
pub extend FnAttr with Eq::{not_equal, equal}

///|
/// Exposes the selected `GlobalValue` methods as regular methods on `Function`.
pub extend Function with GlobalValue::{
  setLinkage,
  setUnnamedAddr,
  asGlobalEnum,
  getLinkage,
  getUnnamedAddr,
  removeUnnamedAddr,
}

///|
/// Exposes the selected `Show` methods as regular methods on `Function`.
pub extend Function with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `Function`.
pub extend Function with Value::{
  tryAsConstantEnum,
  getValueName,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `FunctionType`.
pub extend FunctionType with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `FunctionType`.
pub extend FunctionType with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `FunctionType`.
pub extend FunctionType with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Instruction` methods as regular methods on `GetElementPtrInst`.
pub extend GetElementPtrInst with Instruction::{
  getNextInst,
  getParentBasicBlock,
  getPrevInst,
  removeFromParent,
  getNumArgOperands,
  asInstEnum,
  eraseFromParent,
}

///|
/// Exposes the selected `Show` methods as regular methods on `GetElementPtrInst`.
pub extend GetElementPtrInst with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `GetElementPtrInst`.
pub extend GetElementPtrInst with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `GlobalValue` methods as regular methods on `GlobalConstant`.
pub extend GlobalConstant with GlobalValue::{
  setLinkage,
  setUnnamedAddr,
  asGlobalEnum,
  getLinkage,
  getUnnamedAddr,
  removeUnnamedAddr,
}

///|
/// Exposes the selected `Show` methods as regular methods on `GlobalConstant`.
pub extend GlobalConstant with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `GlobalConstant`.
pub extend GlobalConstant with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `GlobalValue` methods as regular methods on `GlobalVariable`.
pub extend GlobalVariable with GlobalValue::{
  setLinkage,
  setUnnamedAddr,
  asGlobalEnum,
  getLinkage,
  getUnnamedAddr,
  removeUnnamedAddr,
}

///|
/// Exposes the selected `Show` methods as regular methods on `GlobalVariable`.
pub extend GlobalVariable with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `GlobalVariable`.
pub extend GlobalVariable with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `HalfType`.
pub extend HalfType with Eq::{not_equal, equal}

///|
/// Exposes the selected `FPType` methods as regular methods on `HalfType`.
pub extend HalfType with FPType::{getFPMantissaWidth}

///|
/// Exposes the selected `PrimitiveType` methods as regular methods on `HalfType`.
pub extend HalfType with PrimitiveType::{getBitWidth}

///|
/// Exposes the selected `Show` methods as regular methods on `HalfType`.
pub extend HalfType with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `HalfType`.
pub extend HalfType with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Instruction` methods as regular methods on `ICmpInst`.
pub extend ICmpInst with Instruction::{
  getNextInst,
  getParentBasicBlock,
  getPrevInst,
  removeFromParent,
  getNumArgOperands,
  asInstEnum,
  eraseFromParent,
}

///|
/// Exposes the selected `Show` methods as regular methods on `ICmpInst`.
pub extend ICmpInst with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `ICmpInst`.
pub extend ICmpInst with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Instruction` methods as regular methods on `InsertValueInst`.
pub extend InsertValueInst with Instruction::{
  getNextInst,
  getParentBasicBlock,
  getPrevInst,
  removeFromParent,
  getNumArgOperands,
  asInstEnum,
  eraseFromParent,
}

///|
/// Exposes the selected `Show` methods as regular methods on `InsertValueInst`.
pub extend InsertValueInst with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `InsertValueInst`.
pub extend InsertValueInst with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `Int16Type`.
pub extend Int16Type with Eq::{not_equal, equal}

///|
/// Exposes the selected `IntegerType` methods as regular methods on `Int16Type`.
pub extend Int16Type with IntegerType::{getExtendedType}

///|
/// Exposes the selected `PrimitiveType` methods as regular methods on `Int16Type`.
pub extend Int16Type with PrimitiveType::{getBitWidth}

///|
/// Exposes the selected `Show` methods as regular methods on `Int16Type`.
pub extend Int16Type with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `Int16Type`.
pub extend Int16Type with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `Int1Type`.
pub extend Int1Type with Eq::{not_equal, equal}

///|
/// Exposes the selected `IntegerType` methods as regular methods on `Int1Type`.
pub extend Int1Type with IntegerType::{getExtendedType}

///|
/// Exposes the selected `PrimitiveType` methods as regular methods on `Int1Type`.
pub extend Int1Type with PrimitiveType::{getBitWidth}

///|
/// Exposes the selected `Show` methods as regular methods on `Int1Type`.
pub extend Int1Type with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `Int1Type`.
pub extend Int1Type with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `Int32Type`.
pub extend Int32Type with Eq::{not_equal, equal}

///|
/// Exposes the selected `IntegerType` methods as regular methods on `Int32Type`.
pub extend Int32Type with IntegerType::{getExtendedType}

///|
/// Exposes the selected `PrimitiveType` methods as regular methods on `Int32Type`.
pub extend Int32Type with PrimitiveType::{getBitWidth}

///|
/// Exposes the selected `Show` methods as regular methods on `Int32Type`.
pub extend Int32Type with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `Int32Type`.
pub extend Int32Type with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `Int64Type`.
pub extend Int64Type with Eq::{not_equal, equal}

///|
/// Exposes the selected `IntegerType` methods as regular methods on `Int64Type`.
pub extend Int64Type with IntegerType::{getExtendedType}

///|
/// Exposes the selected `PrimitiveType` methods as regular methods on `Int64Type`.
pub extend Int64Type with PrimitiveType::{getBitWidth}

///|
/// Exposes the selected `Show` methods as regular methods on `Int64Type`.
pub extend Int64Type with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `Int64Type`.
pub extend Int64Type with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `Int8Type`.
pub extend Int8Type with Eq::{not_equal, equal}

///|
/// Exposes the selected `IntegerType` methods as regular methods on `Int8Type`.
pub extend Int8Type with IntegerType::{getExtendedType}

///|
/// Exposes the selected `PrimitiveType` methods as regular methods on `Int8Type`.
pub extend Int8Type with PrimitiveType::{getBitWidth}

///|
/// Exposes the selected `Show` methods as regular methods on `Int8Type`.
pub extend Int8Type with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `Int8Type`.
pub extend Int8Type with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `IntegerTypeEnum`.
pub extend IntegerTypeEnum with Eq::{not_equal, equal}

///|
/// Exposes the selected `Eq` methods as regular methods on `LabelType`.
pub extend LabelType with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `LabelType`.
pub extend LabelType with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `LabelType`.
pub extend LabelType with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Instruction` methods as regular methods on `LoadInst`.
pub extend LoadInst with Instruction::{
  getNextInst,
  getParentBasicBlock,
  getPrevInst,
  removeFromParent,
  getNumArgOperands,
  asInstEnum,
  eraseFromParent,
}

///|
/// Exposes the selected `Show` methods as regular methods on `LoadInst`.
pub extend LoadInst with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `LoadInst`.
pub extend LoadInst with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `MetadataType`.
pub extend MetadataType with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `MetadataType`.
pub extend MetadataType with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `MetadataType`.
pub extend MetadataType with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Show` methods as regular methods on `Module`.
pub extend Module with Show::{to_string, output}

///|
/// Exposes the selected `Instruction` methods as regular methods on `PHINode`.
pub extend PHINode with Instruction::{
  getNextInst,
  getParentBasicBlock,
  getPrevInst,
  removeFromParent,
  getNumArgOperands,
  asInstEnum,
  eraseFromParent,
}

///|
/// Exposes the selected `Show` methods as regular methods on `PHINode`.
pub extend PHINode with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `PHINode`.
pub extend PHINode with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `ParamAttr`.
pub extend ParamAttr with Eq::{not_equal, equal}

///|
/// Exposes the selected `Eq` methods as regular methods on `PointerType`.
pub extend PointerType with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `PointerType`.
pub extend PointerType with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `PointerType`.
pub extend PointerType with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Constant` methods as regular methods on `PoisonValue`.
pub extend PoisonValue with Constant::{asConstantEnum}

///|
/// Exposes the selected `Show` methods as regular methods on `PoisonValue`.
pub extend PoisonValue with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `PoisonValue`.
pub extend PoisonValue with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `PrimitiveTypeEnum`.
pub extend PrimitiveTypeEnum with Eq::{not_equal, equal}

///|
/// Exposes the selected `Eq` methods as regular methods on `RetAttr`.
pub extend RetAttr with Eq::{not_equal, equal}

///|
/// Exposes the selected `Instruction` methods as regular methods on `ReturnInst`.
pub extend ReturnInst with Instruction::{
  getNextInst,
  getParentBasicBlock,
  getPrevInst,
  removeFromParent,
  getNumArgOperands,
  asInstEnum,
  eraseFromParent,
}

///|
/// Exposes the selected `Show` methods as regular methods on `ReturnInst`.
pub extend ReturnInst with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `ReturnInst`.
pub extend ReturnInst with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `ScalableVectorType`.
pub extend ScalableVectorType with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `ScalableVectorType`.
pub extend ScalableVectorType with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `ScalableVectorType`.
pub extend ScalableVectorType with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Instruction` methods as regular methods on `SelectInst`.
pub extend SelectInst with Instruction::{
  getNextInst,
  getParentBasicBlock,
  getPrevInst,
  removeFromParent,
  getNumArgOperands,
  asInstEnum,
  eraseFromParent,
}

///|
/// Exposes the selected `Show` methods as regular methods on `SelectInst`.
pub extend SelectInst with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `SelectInst`.
pub extend SelectInst with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Instruction` methods as regular methods on `StoreInst`.
pub extend StoreInst with Instruction::{
  getNextInst,
  getParentBasicBlock,
  getPrevInst,
  removeFromParent,
  getNumArgOperands,
  asInstEnum,
  eraseFromParent,
}

///|
/// Exposes the selected `Show` methods as regular methods on `StoreInst`.
pub extend StoreInst with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `StoreInst`.
pub extend StoreInst with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `StructType`.
pub extend StructType with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `StructType`.
pub extend StructType with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `StructType`.
pub extend StructType with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Instruction` methods as regular methods on `SwitchInst`.
pub extend SwitchInst with Instruction::{
  getNextInst,
  getParentBasicBlock,
  getPrevInst,
  removeFromParent,
  getNumArgOperands,
  asInstEnum,
  eraseFromParent,
}

///|
/// Exposes the selected `Show` methods as regular methods on `SwitchInst`.
pub extend SwitchInst with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `SwitchInst`.
pub extend SwitchInst with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Default` methods as regular methods on `TargetMachineOptions`.
pub extend TargetMachineOptions with Default::{default}

///|
/// Exposes the selected `Debug` methods as regular methods on `TargetTriple`.
pub extend TargetTriple with Debug::{to_repr}

///|
/// Exposes the selected `Eq` methods as regular methods on `TargetTriple`.
pub extend TargetTriple with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `TargetTriple`.
pub extend TargetTriple with Show::{to_string, output}

///|
/// Exposes the selected `Eq` methods as regular methods on `TokenType`.
pub extend TokenType with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `TokenType`.
pub extend TokenType with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `TokenType`.
pub extend TokenType with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `TypeEnum`.
pub extend TypeEnum with Eq::{not_equal, equal}

///|
/// Exposes the selected `Instruction` methods as regular methods on `UnaryInst`.
pub extend UnaryInst with Instruction::{
  getNextInst,
  getParentBasicBlock,
  getPrevInst,
  removeFromParent,
  getNumArgOperands,
  asInstEnum,
  eraseFromParent,
}

///|
/// Exposes the selected `Show` methods as regular methods on `UnaryInst`.
pub extend UnaryInst with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `UnaryInst`.
pub extend UnaryInst with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Constant` methods as regular methods on `UndefValue`.
pub extend UndefValue with Constant::{asConstantEnum}

///|
/// Exposes the selected `Show` methods as regular methods on `UndefValue`.
pub extend UndefValue with Show::{to_string, output}

///|
/// Exposes the selected `Value` methods as regular methods on `UndefValue`.
pub extend UndefValue with Value::{
  tryAsConstantEnum,
  getValueName,
  getType,
  tryAsConstant,
  setValueName,
  asValueEnum,
  getContext,
  replaceAllUsesWith,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `VectorType`.
pub extend VectorType with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `VectorType`.
pub extend VectorType with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `VectorType`.
pub extend VectorType with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `Eq` methods as regular methods on `VoidType`.
pub extend VoidType with Eq::{not_equal, equal}

///|
/// Exposes the selected `Show` methods as regular methods on `VoidType`.
pub extend VoidType with Show::{to_string, output}

///|
/// Exposes the selected `Type` methods as regular methods on `VoidType`.
pub extend VoidType with Type::{
  tryAsIntTypeEnum,
  isIEEELikeFPTy,
  isIntOrPtrTy,
  isValidGEPType,
  tryAsIntType,
  tryAsAbstractType,
  tryAsAggregateTypeEnum,
  isAggregateType,
  getScalarType,
  tryAsFPType,
  tryAsAbstractTypeEnum,
  tryAsAggregateType,
  tryAsPrimitiveType,
  isIntOrIntVectorTy,
  isFirstClassType,
  isScalableTy,
  isSized,
  isScalableTargetExtTy,
  isEmptyTy,
  is16bitFPTy,
  isPtrOrPtrVectorTy,
  tryAsPrimitiveTypeEnum,
  tryAsFPTypeEnum,
  getContext,
  isSingleValueType,
  sizeOf,
  isFloatingPointTy,
  isFPOrFPVectorTy,
}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `BasicBlock`.
pub extend BasicBlock with InsertPoint::{asInsertPtEnum}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `BinaryInst`.
pub extend BinaryInst with InsertPoint::{asInsertPtEnum}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `BranchInst`.
pub extend BranchInst with InsertPoint::{asInsertPtEnum}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `CallInst`.
pub extend CallInst with InsertPoint::{asInsertPtEnum}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `CastInst`.
pub extend CastInst with InsertPoint::{asInsertPtEnum}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `ExtractValueInst`.
pub extend ExtractValueInst with InsertPoint::{asInsertPtEnum}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `FCmpInst`.
pub extend FCmpInst with InsertPoint::{asInsertPtEnum}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `GetElementPtrInst`.
pub extend GetElementPtrInst with InsertPoint::{asInsertPtEnum}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `ICmpInst`.
pub extend ICmpInst with InsertPoint::{asInsertPtEnum}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `InsertValueInst`.
pub extend InsertValueInst with InsertPoint::{asInsertPtEnum}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `LoadInst`.
pub extend LoadInst with InsertPoint::{asInsertPtEnum}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `PHINode`.
pub extend PHINode with InsertPoint::{asInsertPtEnum}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `ReturnInst`.
pub extend ReturnInst with InsertPoint::{asInsertPtEnum}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `SelectInst`.
pub extend SelectInst with InsertPoint::{asInsertPtEnum}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `StoreInst`.
pub extend StoreInst with InsertPoint::{asInsertPtEnum}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `SwitchInst`.
pub extend SwitchInst with InsertPoint::{asInsertPtEnum}

///|
/// Exposes the selected `InsertPoint` methods as regular methods on `UnaryInst`.
pub extend UnaryInst with InsertPoint::{asInsertPtEnum}
