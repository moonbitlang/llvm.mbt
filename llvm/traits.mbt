pub trait AsValue {
  as_value(Self) -> Value;
  as_value_ref(Self) -> @unsafe.LLVMValueRef;
}

impl AsValue for Value with as_value(self: Value) -> Value {
  self
}

impl AsValue for Value with as_value_ref(self: Value) -> @unsafe.LLVMValueRef {
  self.value_ref
}

pub impl AsValue for IntValue with as_value(self: IntValue) -> Value {
  self.value.as_value()
}

pub impl AsValue for IntValue with as_value_ref(self: IntValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}
pub impl AsValue for FloatValue with as_value(self: FloatValue) -> Value {
  self.value.as_value()
}

pub impl AsValue for FloatValue with as_value_ref(self: FloatValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValue for PointerValue with as_value(self: PointerValue) -> Value {
  self.value.as_value()
}

pub impl AsValue for PointerValue with as_value_ref(self: PointerValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValue for InstructionValue with as_value(self: InstructionValue) -> Value {
  self.value.as_value()
}

pub impl AsValue for InstructionValue with as_value_ref(self: InstructionValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValue for StructValue with as_value(self: StructValue) -> Value {
  self.value.as_value()
}

pub impl AsValue for StructValue with as_value_ref(self: StructValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValue for FunctionValue with as_value(self: FunctionValue) -> Value {
  self.value.as_value()
}

pub impl AsValue for FunctionValue with as_value_ref(
  self: FunctionValue
) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValue for ArrayValue with as_value(self: ArrayValue) -> Value {
  self.value.as_value()
}

pub impl AsValue for ArrayValue with as_value_ref(self: ArrayValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValue for VectorValue with as_value(self: VectorValue) -> Value {
  self.value.as_value()
}

pub impl AsValue for VectorValue with as_value_ref(self: VectorValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValue for PhiValue with as_value(self: PhiValue) -> Value {
  self.value.as_value()
}

pub impl AsValue for PhiValue with as_value_ref(self: PhiValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValue for ScalableVectorValue with as_value(self: ScalableVectorValue) -> Value {
  self.value.as_value()
}

pub impl AsValue for ScalableVectorValue with as_value_ref(self: ScalableVectorValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValue for GlobalValue with as_value(self: GlobalValue) -> Value {
  self.value.as_value()
}

pub impl AsValue for GlobalValue with as_value_ref(self: GlobalValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValue for MetadataValue with as_value(self: MetadataValue) -> Value {
  self.value.as_value()
}

pub impl AsValue for MetadataValue with as_value_ref(self: MetadataValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValue for CallSiteValue with as_value(self: CallSiteValue) -> Value {
  self.value.as_value()
}

pub impl AsValue for CallSiteValue with as_value_ref(self: CallSiteValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValue for CallableValue with as_value_ref(self: CallableValue) -> @unsafe.LLVMValueRef {
  self.as_value_ref()
}

pub impl AsValue for CallableValue with as_value(self: CallableValue) -> Value {
  match self.either_value {
    Left(f) => f.as_value()
    Right(p) => p.as_value()
  }
}

pub impl AsValue for AnyValueEnum with as_value_ref(self: AnyValueEnum) -> @unsafe.LLVMValueRef {
  match self {
    ArrayValue(v) => v.as_value_ref()
    IntValue(v) => v.as_value_ref()
    FloatValue(v) => v.as_value_ref()
    PhiValue(v) => v.as_value_ref()
    FunctionValue(v) => v.as_value_ref()
    PointerValue(v) => v.as_value_ref()
    StructValue(v) => v.as_value_ref()
    VectorValue(v) => v.as_value_ref()
    ScalableVectorValue(v) => v.as_value_ref()
    InstructionValue(v) => v.as_value_ref()
    MetadataValue(v) => v.as_value_ref()
  }
}

pub impl AsValue for AnyValueEnum with as_value(self: AnyValueEnum) -> Value {
  match self {
    ArrayValue(v) => v.as_value()
    IntValue(v) => v.as_value()
    FloatValue(v) => v.as_value()
    PhiValue(v) => v.as_value()
    FunctionValue(v) => v.as_value()
    PointerValue(v) => v.as_value()
    StructValue(v) => v.as_value()
    VectorValue(v) => v.as_value()
    ScalableVectorValue(v) => v.as_value()
    InstructionValue(v) => v.as_value()
    MetadataValue(v) => v.as_value()
  }
}

pub impl AsValue for BasicValueEnum with as_value_ref(self) {
  match self {
    ArrayValue(v) => v.as_value_ref()
    IntValue(v) => v.as_value_ref()
    FloatValue(v) => v.as_value_ref()
    PointerValue(v) => v.as_value_ref()
    StructValue(v) => v.as_value_ref()
    VectorValue(v) => v.as_value_ref()
    ScalableVectorValue(v) => v.as_value_ref()
  }
}

pub impl AsValue for BasicValueEnum with as_value(self: BasicValueEnum) -> Value {
  match self {
    ArrayValue(v) => v.as_value()
    IntValue(v) => v.as_value()
    FloatValue(v) => v.as_value()
    PointerValue(v) => v.as_value()
    StructValue(v) => v.as_value()
    VectorValue(v) => v.as_value()
    ScalableVectorValue(v) => v.as_value()
  }
}

pub impl AsValue for BasicMetadataValueEnum with as_value_ref(self) {
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

pub impl AsValue for BasicMetadataValueEnum with as_value(self: BasicMetadataValueEnum) -> Value {
  match self {
    ArrayValue(v) => v.as_value()
    IntValue(v) => v.as_value()
    FloatValue(v) => v.as_value()
    PointerValue(v) => v.as_value()
    StructValue(v) => v.as_value()
    VectorValue(v) => v.as_value()
    ScalableVectorValue(v) => v.as_value()
    MetadataValue(v) => v.as_value()
  }
}


//=========================================================
// AggregateValue
//=========================================================
pub trait AggregateValue : AnyValue {
  as_aggregate_value_enum(Self) -> AggregateValueEnum;
}

pub impl AggregateValue for ArrayValue with as_aggregate_value_enum(self: ArrayValue) -> AggregateValueEnum {
  AggregateValueEnum::ArrayValue(self)
}

pub impl AggregateValue for StructValue with as_aggregate_value_enum(self: StructValue) -> AggregateValueEnum {
  AggregateValueEnum::StructValue(self)
}


//=========================================================
// AnyValue
//=========================================================
pub trait AnyValue : AsValue + Show {
  as_any_value_enum(Self) -> AnyValueEnum;
  is_poison(Self) -> Bool;
}

pub impl AnyValue for IntValue with as_any_value_enum(self: IntValue) -> AnyValueEnum {
  AnyValueEnum::IntValue(self)
}

pub impl AnyValue for IntValue with is_poison(self: IntValue) -> Bool {
  self.as_value().is_poison()
}

pub impl AnyValue for FloatValue with as_any_value_enum(self: FloatValue) -> AnyValueEnum {
  AnyValueEnum::FloatValue(self)
}

pub impl AnyValue for FloatValue with is_poison(self: FloatValue) -> Bool {
  self.as_value().is_poison()
}

pub impl AnyValue for PointerValue with as_any_value_enum(self: PointerValue) -> AnyValueEnum {
  AnyValueEnum::PointerValue(self)
}

pub impl AnyValue for PointerValue with is_poison(self: PointerValue) -> Bool {
  self.as_value().is_poison()
}

pub impl AnyValue for InstructionValue with as_any_value_enum(self: InstructionValue) -> AnyValueEnum {
  AnyValueEnum::InstructionValue(self)
}

pub impl AnyValue for InstructionValue with is_poison(self: InstructionValue) -> Bool {
  self.as_value().is_poison()
}

pub impl AnyValue for StructValue with as_any_value_enum(self: StructValue) -> AnyValueEnum {
  AnyValueEnum::StructValue(self)
}

pub impl AnyValue for StructValue with is_poison(self: StructValue) -> Bool {
  self.as_value().is_poison()
}

pub impl AnyValue for ArrayValue with as_any_value_enum(self: ArrayValue) -> AnyValueEnum {
  AnyValueEnum::ArrayValue(self)
}

pub impl AnyValue for ArrayValue with is_poison(self: ArrayValue) -> Bool {
  self.as_value().is_poison()
}

pub impl AnyValue for VectorValue with as_any_value_enum(self: VectorValue) -> AnyValueEnum {
  AnyValueEnum::VectorValue(self)
}

pub impl AnyValue for VectorValue with is_poison(self: VectorValue) -> Bool {
  self.as_value().is_poison()
}

pub impl AnyValue for PhiValue with as_any_value_enum(self: PhiValue) -> AnyValueEnum {
  AnyValueEnum::PhiValue(self)
}

pub impl AnyValue for PhiValue with is_poison(self: PhiValue) -> Bool {
  self.as_value().is_poison()
}

pub impl AnyValue for ScalableVectorValue with as_any_value_enum(self: ScalableVectorValue) -> AnyValueEnum {
  AnyValueEnum::ScalableVectorValue(self)
}

pub impl AnyValue for ScalableVectorValue with is_poison(self: ScalableVectorValue) -> Bool {
  self.as_value().is_poison()
}

pub impl AnyValue for MetadataValue with as_any_value_enum(self: MetadataValue) -> AnyValueEnum {
  AnyValueEnum::MetadataValue(self)
}

pub impl AnyValue for MetadataValue with is_poison(self: MetadataValue) -> Bool {
  self.as_value().is_poison()
}

//=========================================================
// BasicValue
//=========================================================
pub trait BasicValue : AnyValue {
  as_basic_value_enum(Self) -> BasicValueEnum;
  // as_instruction_value(Self) -> InstructionValue;
  // get_first_use(Self) -> BasicValueUse/
  set_name(Self, String) -> Unit;
}

pub impl BasicValue for IntValue with as_basic_value_enum(self: IntValue) -> BasicValueEnum {
  BasicValueEnum::IntValue(self)
}

pub impl BasicValue for IntValue with set_name(self: IntValue, name: String) -> Unit {
  self.set_name(name)
}

pub impl BasicValue for FloatValue with as_basic_value_enum(self: FloatValue) -> BasicValueEnum {
  BasicValueEnum::FloatValue(self)
}

pub impl BasicValue for FloatValue with set_name(self: FloatValue, name: String) -> Unit {
  self.set_name(name)
}

pub impl BasicValue for PointerValue with as_basic_value_enum(self: PointerValue) -> BasicValueEnum {
  BasicValueEnum::PointerValue(self)
}

pub impl BasicValue for PointerValue with set_name(self: PointerValue, name: String) -> Unit {
  self.set_name(name)
}

pub impl BasicValue for StructValue with as_basic_value_enum(self: StructValue) -> BasicValueEnum {
  BasicValueEnum::StructValue(self)
}

pub impl BasicValue for StructValue with set_name(self: StructValue, name: String) -> Unit {
  self.set_name(name)
}

pub impl BasicValue for ArrayValue with as_basic_value_enum(self: ArrayValue) -> BasicValueEnum {
  BasicValueEnum::ArrayValue(self)
}

pub impl BasicValue for ArrayValue with set_name(self: ArrayValue, name: String) -> Unit {
  self.set_name(name)
}

pub impl BasicValue for VectorValue with as_basic_value_enum(self: VectorValue) -> BasicValueEnum {
  BasicValueEnum::VectorValue(self)
}

pub impl BasicValue for VectorValue with set_name(self: VectorValue, name: String) -> Unit {
  self.set_name(name)
}

pub impl BasicValue for ScalableVectorValue with as_basic_value_enum(self: ScalableVectorValue) -> BasicValueEnum {
  BasicValueEnum::ScalableVectorValue(self)
}

pub impl BasicValue for ScalableVectorValue with set_name(self: ScalableVectorValue, name: String) -> Unit {
  self.set_name(name)
}
//=========================================================
// BasicMetadataValue
//=========================================================
pub trait BasicMetadataValue : AnyValue {
  as_basic_metadata_value_enum(Self) -> BasicMetadataValueEnum;
}

pub impl BasicMetadataValue for IntValue with as_basic_metadata_value_enum(self: IntValue) -> BasicMetadataValueEnum {
  BasicMetadataValueEnum::IntValue(self)
}

pub impl BasicMetadataValue for FloatValue with as_basic_metadata_value_enum(self: FloatValue) -> BasicMetadataValueEnum {
  BasicMetadataValueEnum::FloatValue(self)
}

pub impl BasicMetadataValue for PointerValue with as_basic_metadata_value_enum(self: PointerValue) -> BasicMetadataValueEnum {
  BasicMetadataValueEnum::PointerValue(self)
}

pub impl BasicMetadataValue for StructValue with as_basic_metadata_value_enum(self: StructValue) -> BasicMetadataValueEnum {
  BasicMetadataValueEnum::StructValue(self)
}

pub impl BasicMetadataValue for ArrayValue with as_basic_metadata_value_enum(self: ArrayValue) -> BasicMetadataValueEnum {
  BasicMetadataValueEnum::ArrayValue(self)
}

pub impl BasicMetadataValue for VectorValue with as_basic_metadata_value_enum(self: VectorValue) -> BasicMetadataValueEnum {
  BasicMetadataValueEnum::VectorValue(self)
}

pub impl BasicMetadataValue for ScalableVectorValue with as_basic_metadata_value_enum(self: ScalableVectorValue) -> BasicMetadataValueEnum {
  BasicMetadataValueEnum::ScalableVectorValue(self)
}

pub impl BasicMetadataValue for MetadataValue with as_basic_metadata_value_enum(self: MetadataValue) -> BasicMetadataValueEnum {
  BasicMetadataValueEnum::MetadataValue(self)
}

//=========================================================
// IntMathValue
//=========================================================
pub trait IntMathValue : BasicValue {
  new(@unsafe.LLVMValueRef) -> Self;
}

pub impl IntMathValue for IntValue with new(val_ref: @unsafe.LLVMValueRef) -> IntValue {
  IntValue::new(val_ref)
}

// This is different with `inkwell`
// pub impl IntMathValue for PointerValue with new(val_ref: @unsafe.LLVMValueRef) -> PointerValue {
//   PointerValue::new(val_ref)
// }

pub impl IntMathValue for VectorValue with new(val_ref: @unsafe.LLVMValueRef) -> VectorValue {
  VectorValue::new(val_ref)
}

pub impl IntMathValue for ScalableVectorValue with new(
  val_ref: @unsafe.LLVMValueRef
) -> ScalableVectorValue {
  ScalableVectorValue::new(val_ref)
}

//=========================================================
// FloatMathValue
//=========================================================
pub trait FloatMathValue : BasicValue {
  new(@unsafe.LLVMValueRef) -> Self;
}

pub impl FloatMathValue for FloatValue with new(val_ref: @unsafe.LLVMValueRef) -> FloatValue {
  FloatValue::new(val_ref)
}

pub impl FloatMathValue for VectorValue with new(val_ref: @unsafe.LLVMValueRef) -> VectorValue {
  VectorValue::new(val_ref)
}

pub impl FloatMathValue for ScalableVectorValue with new(
  val_ref: @unsafe.LLVMValueRef
) -> ScalableVectorValue {
  ScalableVectorValue::new(val_ref)
}

//=========================================================
// PointerMathValue
//=========================================================
pub trait PointerMathValue : BasicValue {
  new(@unsafe.LLVMValueRef) -> Self;
}

pub impl PointerMathValue for PointerValue with new(val_ref: @unsafe.LLVMValueRef) -> PointerValue {
  PointerValue::new(val_ref)
}

pub impl PointerMathValue for VectorValue with new(val_ref: @unsafe.LLVMValueRef) -> VectorValue {
  VectorValue::new(val_ref)
}

pub impl PointerMathValue for ScalableVectorValue with new(
  val_ref: @unsafe.LLVMValueRef
) -> ScalableVectorValue {
  ScalableVectorValue::new(val_ref)
}

//=========================================================
// VectorBaseValue
//=========================================================
pub trait VectorBaseValue : BasicValue {
  new(@unsafe.LLVMValueRef) -> Self;
}

pub impl VectorBaseValue for VectorValue with new(val_ref: @unsafe.LLVMValueRef) -> VectorValue {
  VectorValue::new(val_ref)
}

pub impl VectorBaseValue for ScalableVectorValue with new(
  val_ref: @unsafe.LLVMValueRef
) -> ScalableVectorValue {
  ScalableVectorValue::new(val_ref)
}

//=========================================================
// AsType
//=========================================================
pub trait AsType {
  as_type(Self) -> Type;
  as_type_ref(Self) -> @unsafe.LLVMTypeRef
}

pub impl AsType for Type with as_type(self: Type) -> Type {
  self
}

pub impl AsType for Type with as_type_ref(self: Type) -> @unsafe.LLVMTypeRef {
  self.type_ref
}

pub impl AsType for IntType with as_type(self: IntType) -> Type {
  self.ty
}

pub impl AsType for IntType with as_type_ref(self: IntType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

pub impl AsType for FloatType with as_type(self: FloatType) -> Type {
  self.ty
}

pub impl AsType for FloatType with as_type_ref(self: FloatType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

pub impl AsType for VoidType with as_type(self: VoidType) -> Type {
  self.ty
}

pub impl AsType for VoidType with as_type_ref(self: VoidType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

pub impl AsType for PointerType with as_type(self: PointerType) -> Type {
  self.ty
}

pub impl AsType for PointerType with as_type_ref(self: PointerType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

pub impl AsType for StructType with as_type(self: StructType) -> Type {
  self.ty
}

pub impl AsType for StructType with as_type_ref(self: StructType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

pub impl AsType for FunctionType with as_type(self: FunctionType) -> Type {
  self.ty
}

pub impl AsType for FunctionType with as_type_ref(self: FunctionType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

pub impl AsType for ArrayType with as_type(self: ArrayType) -> Type {
  self.ty
}

pub impl AsType for ArrayType with as_type_ref(self: ArrayType) -> @unsafe.LLVMTypeRef {
  self.as_type_ref()
}

pub impl AsType for VectorType with as_type(self: VectorType) -> Type {
  self.ty
}

pub impl AsType for VectorType with as_type_ref(self: VectorType) -> @unsafe.LLVMTypeRef {
  self.as_type_ref()
}

pub impl AsType for ScalableVectorType with as_type(self: ScalableVectorType) -> Type {
  self.ty
}

pub impl AsType for ScalableVectorType with as_type_ref(
  self: ScalableVectorType
) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

pub impl AsType for MetadataType with as_type(self: MetadataType) -> Type {
  self.ty
}

pub impl AsType for MetadataType with as_type_ref(self: MetadataType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

pub impl AsType for AnyTypeEnum with as_type_ref(self) {
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

pub impl AsType for AnyTypeEnum with as_type(self: AnyTypeEnum) -> Type {
  match self {
    AnyTypeEnum::ArrayType(v) => v.as_type()
    AnyTypeEnum::FloatType(v) => v.as_type()
    AnyTypeEnum::FunctionType(v) => v.as_type()
    AnyTypeEnum::IntType(v) => v.as_type()
    AnyTypeEnum::PointerType(v) => v.as_type()
    AnyTypeEnum::StructType(v) => v.as_type()
    AnyTypeEnum::VectorType(v) => v.as_type()
    AnyTypeEnum::ScalableVectorType(v) => v.as_type()
    AnyTypeEnum::VoidType(v) => v.as_type()
  }
}

pub impl AsType for BasicTypeEnum with as_type_ref(self) {
  match self {
    ArrayType(t) => t.as_type_ref()
    FloatType(t) => t.as_type_ref()
    IntType(t) => t.as_type_ref()
    PointerType(t) => t.as_type_ref()
    StructType(t) => t.as_type_ref()
    VectorType(t) => t.as_type_ref()
    ScalableVectorType(t) => t.as_type_ref()
  }
}

pub impl AsType for BasicTypeEnum with as_type(self: BasicTypeEnum) -> Type {
  match self {
    ArrayType(t) => t.as_type()
    FloatType(t) => t.as_type()
    IntType(t) => t.as_type()
    PointerType(t) => t.as_type()
    StructType(t) => t.as_type()
    VectorType(t) => t.as_type()
    ScalableVectorType(t) => t.as_type()
  }
}

pub impl AsType for BasicMetadataTypeEnum with as_type_ref(self) {
  match self {
    ArrayType(t) => t.as_type_ref()
    FloatType(t) => t.as_type_ref()
    IntType(t) => t.as_type_ref()
    PointerType(t) => t.as_type_ref()
    StructType(t) => t.as_type_ref()
    VectorType(t) => t.as_type_ref()
    ScalableVectorType(t) => t.as_type_ref()
    MetadataType(t) => t.as_type_ref()
  }
}

pub impl AsType for BasicMetadataTypeEnum with as_type(self: BasicMetadataTypeEnum) -> Type {
  match self {
    ArrayType(t) => t.as_type()
    FloatType(t) => t.as_type()
    IntType(t) => t.as_type()
    PointerType(t) => t.as_type()
    StructType(t) => t.as_type()
    VectorType(t) => t.as_type()
    ScalableVectorType(t) => t.as_type()
    MetadataType(t) => t.as_type()
  }
}


//=========================================================
// AnyType
//=========================================================
pub trait AnyType : AsType + Show {
  as_any_type_enum(Self) -> AnyTypeEnum;
}

pub impl AnyType for IntType with as_any_type_enum(self: IntType) -> AnyTypeEnum {
  AnyTypeEnum::IntType(self)
}

pub impl AnyType for FloatType with as_any_type_enum(self: FloatType) -> AnyTypeEnum {
  AnyTypeEnum::FloatType(self)
}

pub impl AnyType for VoidType with as_any_type_enum(self: VoidType) -> AnyTypeEnum {
  AnyTypeEnum::VoidType(self)
}

pub impl AnyType for PointerType with as_any_type_enum(self: PointerType) -> AnyTypeEnum {
  AnyTypeEnum::PointerType(self)
}

pub impl AnyType for StructType with as_any_type_enum(self: StructType) -> AnyTypeEnum {
  AnyTypeEnum::StructType(self)
}

pub impl AnyType for FunctionType with as_any_type_enum(self: FunctionType) -> AnyTypeEnum {
  AnyTypeEnum::FunctionType(self)
}

pub impl AnyType for ArrayType with as_any_type_enum(self: ArrayType) -> AnyTypeEnum {
  AnyTypeEnum::ArrayType(self)
}

pub impl AnyType for VectorType with as_any_type_enum(self: VectorType) -> AnyTypeEnum {
  AnyTypeEnum::VectorType(self)
}

pub impl AnyType for ScalableVectorType with as_any_type_enum(self: ScalableVectorType) -> AnyTypeEnum {
  AnyTypeEnum::ScalableVectorType(self)
}

//=========================================================
// BasicType
//=========================================================
pub trait BasicType : AnyType {
  as_basic_type_enum(Self) -> BasicTypeEnum;
}

pub impl BasicType for IntType with as_basic_type_enum(self: IntType) -> BasicTypeEnum {
  BasicTypeEnum::IntType(self)
}

pub impl BasicType for FloatType with as_basic_type_enum(self: FloatType) -> BasicTypeEnum {
  BasicTypeEnum::FloatType(self)
}

pub impl BasicType for PointerType with as_basic_type_enum(self: PointerType) -> BasicTypeEnum {
  BasicTypeEnum::PointerType(self)
}

pub impl BasicType for StructType with as_basic_type_enum(self: StructType) -> BasicTypeEnum {
  BasicTypeEnum::StructType(self)
}
pub impl BasicType for ArrayType with as_basic_type_enum(self: ArrayType) -> BasicTypeEnum {
  BasicTypeEnum::ArrayType(self)
}
pub impl BasicType for VectorType with as_basic_type_enum(self: VectorType) -> BasicTypeEnum {
  BasicTypeEnum::VectorType(self)
}

pub impl BasicType for ScalableVectorType with as_basic_type_enum(self: ScalableVectorType) -> BasicTypeEnum {
  BasicTypeEnum::ScalableVectorType(self)
}

//=========================================================
// BasicMetadataType
//=========================================================
pub trait BasicMetadataType : AnyType {
  as_basic_metadata_type_enum(Self) -> BasicMetadataTypeEnum;
}

pub impl BasicMetadataType for IntType with as_basic_metadata_type_enum(self: IntType) -> BasicMetadataTypeEnum {
  BasicMetadataTypeEnum::IntType(self)
}

pub impl BasicMetadataType for FloatType with as_basic_metadata_type_enum(self: FloatType) -> BasicMetadataTypeEnum {
  BasicMetadataTypeEnum::FloatType(self)
}

pub impl BasicMetadataType for PointerType with as_basic_metadata_type_enum(self: PointerType) -> BasicMetadataTypeEnum {
  BasicMetadataTypeEnum::PointerType(self)
}

pub impl BasicMetadataType for StructType with as_basic_metadata_type_enum(self: StructType) -> BasicMetadataTypeEnum {
  BasicMetadataTypeEnum::StructType(self)
}

pub impl BasicMetadataType for ArrayType with as_basic_metadata_type_enum(self: ArrayType) -> BasicMetadataTypeEnum {
  BasicMetadataTypeEnum::ArrayType(self)
}

pub impl BasicMetadataType for VectorType with as_basic_metadata_type_enum(self: VectorType) -> BasicMetadataTypeEnum {
  BasicMetadataTypeEnum::VectorType(self)
}

pub impl BasicMetadataType for ScalableVectorType with as_basic_metadata_type_enum(self: ScalableVectorType) -> BasicMetadataTypeEnum {
  BasicMetadataTypeEnum::ScalableVectorType(self)
}
