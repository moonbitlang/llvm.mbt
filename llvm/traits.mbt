// ====------------------------------------=====
// Types
// ====------------------------------------=====

pub trait Type {
  base(Self) -> TypeRef;
  as_type_enum(Self) -> TypeEnum;
  try_as_basic_type_enum(Self) -> BasicTypeEnum? = _;
  inner(Self) -> @unsafe.LLVMTypeRef = _
  dump(Self) -> Unit = _;
  is_sized(Self) -> Bool = _;
}

impl Type with try_as_basic_type_enum(self) {
  match self.as_type_enum() {
    VoidType(_) => None
    IntType(v) => Some(BasicTypeEnum::IntType(v))
    FloatType(v) => Some(BasicTypeEnum::FloatType(v))
    PointerType(v) => Some(BasicTypeEnum::PointerType(v))
    StructType(v) => Some(BasicTypeEnum::StructType(v))
    FunctionType(_) => None // Function types are not basic types
    ArrayType(v) => Some(BasicTypeEnum::ArrayType(v))
    VectorType(v) => Some(BasicTypeEnum::VectorType(v))
    ScalableVectorType(v) => Some(BasicTypeEnum::ScalableVectorType(v))
    MetadataType(_) => None // Metadata types are not basic types
  }
}

impl Type with inner(self) {
  self.base().inner()
}

impl Type with dump(self) {
  self.base().dump()
}

impl Type with is_sized(self) {
  self.base().is_sized()
}

pub impl Show for &Type with output(self, logger) {
  let s = match self.as_type_enum() {
    VoidType(v) => v.to_string()
    IntType(v) => v.to_string()
    FloatType(v) => v.to_string()
    PointerType(v) => v.to_string()
    StructType(v) => v.to_string()
    FunctionType(v) => v.to_string()
    ArrayType(v) => v.to_string()
    VectorType(v) => v.to_string()
    ScalableVectorType(v) => v.to_string()
    MetadataType(v) => v.to_string()
  }
  logger.write_string(s)
}

pub impl Eq for &Type with op_equal(self, other) {
  self.inner() == other.inner()
}

pub enum TypeEnum {
  VoidType(VoidType)
  IntType(IntType)
  FloatType(FloatType)
  PointerType(PointerType)
  StructType(StructType)
  FunctionType(FunctionType)
  ArrayType(ArrayType)
  VectorType(VectorType)
  ScalableVectorType(ScalableVectorType)
  MetadataType(MetadataType)
}

pub fn TypeEnum::as_type_class(self: Self) -> &Type {
  match self {
    VoidType(v) => v as &Type
    IntType(v) => v
    FloatType(v) => v
    PointerType(v) => v
    StructType(v) => v
    FunctionType(v) => v
    ArrayType(v) => v
    VectorType(v) => v
    ScalableVectorType(v) => v
    MetadataType(v) => v
  }
}

pub fn TypeEnum::init(type_ref : @unsafe.LLVMTypeRef) -> TypeEnum {
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

// ====------------------------------------=====
// Basic Types
// ====------------------------------------=====

pub trait BasicType: Type {
  as_basic_type_enum(Self) -> BasicTypeEnum;
}

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

pub fn BasicTypeEnum::as_basic_type_class(self: Self) -> &BasicType {
  match self {
    ArrayType(v) => v as &BasicType
    FloatType(v) => v
    IntType(v) => v
    PointerType(v) => v
    StructType(v) => v
    VectorType(v) => v
    ScalableVectorType(v) => v
  }
}

///|
pub fn BasicTypeEnum::init(type_ref : @unsafe.LLVMTypeRef) -> BasicTypeEnum {
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

pub impl Show for &BasicType with output(self, logger) {
  let s = match self.as_basic_type_enum() {
    IntType(v) => v.to_string()
    FloatType(v) => v.to_string()
    PointerType(v) => v.to_string()
    StructType(v) => v.to_string()
    ArrayType(v) => v.to_string()
    VectorType(v) => v.to_string()
    ScalableVectorType(v) => v.to_string()
  }
  logger.write_string(s)
}

pub impl Eq for &BasicType with op_equal(self, other) {
  self.inner() == other.inner()
}

// ====------------------------------------=====
// Values
// ====------------------------------------=====

pub trait Value {
  base(Self) -> ValueRef;
  as_value_enum(Self) -> ValueEnum;
  inner(Self) -> @unsafe.LLVMValueRef = _
  dump(Self) -> Unit = _;
  get_type(Self) -> &Type = _;
}

impl Value with inner(self) {
  self.base().inner()
}

impl Value with dump(self) {
  self.base().dump()
}

impl Value with get_type(self) {
  let type_ref = self.base().get_type()
  TypeEnum::init(type_ref.inner()).as_type_class()
}

pub impl Show for &Value with output(self, logger) {
  let s = match self.as_value_enum() {
    IntValue(v) => v.to_string()
    FloatValue(v) => v.to_string()
    PointerValue(v) => v.to_string()
    StructValue(v) => v.to_string()
    FunctionValue(v) => v.to_string()
    ArrayValue(v) => v.to_string()
    VectorValue(v) => v.to_string()
    PhiValue(v) => v.to_string()
    ScalableVectorValue(v) => v.to_string()
    MetadataValue(v) => v.to_string()
    CallSiteValue(v) => v.to_string()
    GlobalValue(v) => v.to_string()
    InstructionValue(v) => v.to_string()
  }
  logger.write_string(s)
}

pub impl Eq for &Value with op_equal(self, other) {
  self.inner() == other.inner()
}

pub enum ValueEnum {
  IntValue(IntValue)
  FloatValue(FloatValue)
  PointerValue(PointerValue)
  StructValue(StructValue)
  FunctionValue(FunctionValue)
  ArrayValue(ArrayValue)
  VectorValue(VectorValue)
  PhiValue(PhiValue)
  ScalableVectorValue(ScalableVectorValue)
  MetadataValue(MetadataValue)
  CallSiteValue(CallSiteValue)
  GlobalValue(GlobalValue)
  InstructionValue(InstructionValue)
}

pub fn ValueEnum::as_value_class(self: Self) -> &Value {
  match self {
    IntValue(v) => v as &Value
    FloatValue(v) => v
    PointerValue(v) => v
    StructValue(v) => v
    FunctionValue(v) => v
    ArrayValue(v) => v
    VectorValue(v) => v
    PhiValue(v) => v
    ScalableVectorValue(v) => v
    MetadataValue(v) => v
    CallSiteValue(v) => v
    GlobalValue(v) => v
    InstructionValue(v) => v
  }
}

pub fn ValueEnum::init(val_ref: @unsafe.LLVMValueRef) -> ValueEnum {
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
    @unsafe.LLVMStructTypeKind => StructValue(StructValue::new(val_ref))
    @unsafe.LLVMPointerTypeKind =>
      match @unsafe.llvm_get_value_kind(val_ref) {
        @unsafe.LLVMFunctionValueKind =>
          FunctionValue(FunctionValue::new(val_ref).unwrap())
        _ => PointerValue(PointerValue::new(val_ref))
      }
    @unsafe.LLVMArrayTypeKind => ArrayValue(ArrayValue::new(val_ref))
    @unsafe.LLVMVectorTypeKind => VectorValue(VectorValue::new(val_ref))
    @unsafe.LLVMFunctionTypeKind => FunctionValue(FunctionValue::new(val_ref).unwrap())
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

// ====------------------------------------=====
// Basic Values
// ====------------------------------------=====
pub trait BasicValue: Value {
  as_basic_value_enum(Self) -> BasicValueEnum;
}

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

pub fn BasicValueEnum::as_basic_value_class(self: Self) -> &BasicValue {
  match self {
    ArrayValue(v) => v as &BasicValue
    IntValue(v) => v
    FloatValue(v) => v
    PointerValue(v) => v
    StructValue(v) => v
    VectorValue(v) => v
    ScalableVectorValue(v) => v
  }
}

pub fn BasicValueEnum::init(val_ref: @unsafe.LLVMValueRef) -> BasicValueEnum {
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
    @unsafe.LLVMStructTypeKind => StructValue(StructValue::new(val_ref))
    @unsafe.LLVMPointerTypeKind => PointerValue(PointerValue::new(val_ref))
    @unsafe.LLVMArrayTypeKind => ArrayValue(ArrayValue::new(val_ref))
    @unsafe.LLVMVectorTypeKind => VectorValue(VectorValue::new(val_ref))
    _ => abort("Unsupported basic value kind")
  }
}

pub impl Show for &BasicValue with output(self, logger) {
  let s = match self.as_basic_value_enum() {
    IntValue(v) => v.to_string()
    FloatValue(v) => v.to_string()
    PointerValue(v) => v.to_string()
    StructValue(v) => v.to_string()
    ArrayValue(v) => v.to_string()
    VectorValue(v) => v.to_string()
    ScalableVectorValue(v) => v.to_string()
  }
  logger.write_string(s)
}

pub impl Eq for &BasicValue with op_equal(self, other) {
  self.inner() == other.inner()
}

// ====------------------------------------=====
// Aggregate Values
// ====------------------------------------=====

pub trait AggregateValue: Value {
  as_aggregate_value_enum(Self) -> AggregateValueEnum;
}

pub enum AggregateValueEnum {
  StructValue(StructValue)
  ArrayValue(ArrayValue)
  VectorValue(VectorValue)
  ScalableVectorValue(ScalableVectorValue)
}

pub fn AggregateValueEnum::as_aggregate_value_class(self: Self) -> &AggregateValue {
  match self {
    StructValue(v) => v as &AggregateValue
    ArrayValue(v) => v
    VectorValue(v) => v
    ScalableVectorValue(v) => v
  }
}

pub fn AggregateValueEnum::init(val_ref: @unsafe.LLVMValueRef) -> AggregateValueEnum {
  let ty = val_ref.get_type()
  let kind = @unsafe.llvm_get_type_kind(ty)
  match kind {
    @unsafe.LLVMStructTypeKind => StructValue(StructValue::new(val_ref))
    @unsafe.LLVMArrayTypeKind => ArrayValue(ArrayValue::new(val_ref))
    @unsafe.LLVMVectorTypeKind => VectorValue(VectorValue::new(val_ref))
    @unsafe.LLVMPointerTypeKind => ScalableVectorValue(ScalableVectorValue::new(val_ref))
    _ => abort("Unsupported aggregate value kind")
  }
}

// ====------------------------------------=====
// Basic Metadata Values
// ====------------------------------------=====



//=========================================================
// IntMathValue
//=========================================================

///|
pub trait IntMathValue: BasicValue {
  new(@unsafe.LLVMValueRef) -> Self
}

///|
pub impl IntMathValue for IntValue with new(val_ref : @unsafe.LLVMValueRef) -> IntValue {
  IntValue::new(val_ref)
}

// This is different with `inkwell`
// pub impl IntMathValue for PointerValue with new(val_ref: @unsafe.LLVMValueRef) -> PointerValue {
//   PointerValue::new(val_ref)
// }

///|
pub impl IntMathValue for VectorValue with new(val_ref : @unsafe.LLVMValueRef) -> VectorValue {
  VectorValue::new(val_ref)
}

///|
pub impl IntMathValue for ScalableVectorValue with new(
  val_ref : @unsafe.LLVMValueRef
) -> ScalableVectorValue {
  ScalableVectorValue::new(val_ref)
}

//=========================================================
// FloatMathValue
//=========================================================

///|
pub trait FloatMathValue: BasicValue {
  new(@unsafe.LLVMValueRef) -> Self
}

///|
pub impl FloatMathValue for FloatValue with new(val_ref : @unsafe.LLVMValueRef) -> FloatValue {
  FloatValue::new(val_ref)
}

///|
pub impl FloatMathValue for VectorValue with new(val_ref : @unsafe.LLVMValueRef) -> VectorValue {
  VectorValue::new(val_ref)
}

///|
pub impl FloatMathValue for ScalableVectorValue with new(
  val_ref : @unsafe.LLVMValueRef
) -> ScalableVectorValue {
  ScalableVectorValue::new(val_ref)
}

//=========================================================
// PointerMathValue
//=========================================================

///|
pub trait PointerMathValue: BasicValue {
  new(@unsafe.LLVMValueRef) -> Self
}

///|
pub impl PointerMathValue for PointerValue with new(
  val_ref : @unsafe.LLVMValueRef
) -> PointerValue {
  PointerValue::new(val_ref)
}

///|
pub impl PointerMathValue for VectorValue with new(
  val_ref : @unsafe.LLVMValueRef
) -> VectorValue {
  VectorValue::new(val_ref)
}

///|
pub impl PointerMathValue for ScalableVectorValue with new(
  val_ref : @unsafe.LLVMValueRef
) -> ScalableVectorValue {
  ScalableVectorValue::new(val_ref)
}

//=========================================================
// VectorBaseValue
//=========================================================

///|
pub trait VectorBaseValue: BasicValue {
  new(@unsafe.LLVMValueRef) -> Self
}

///|
pub impl VectorBaseValue for VectorValue with new(
  val_ref : @unsafe.LLVMValueRef
) -> VectorValue {
  VectorValue::new(val_ref)
}

///|
pub impl VectorBaseValue for ScalableVectorValue with new(
  val_ref : @unsafe.LLVMValueRef
) -> ScalableVectorValue {
  ScalableVectorValue::new(val_ref)
}
