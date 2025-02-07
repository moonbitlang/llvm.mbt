pub trait AsValueRef {
  as_value_ref(Self) -> @unsafe.LLVMValueRef;
}

impl AsValueRef for Value with as_value_ref(self: Value) -> @unsafe.LLVMValueRef {
  self.value_ref
}

pub impl AsValueRef for IntValue with as_value_ref(self: IntValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValueRef for FloatValue with as_value_ref(self: FloatValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValueRef for PointerValue with as_value_ref(self: PointerValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValueRef for InstructionValue with as_value_ref(self: InstructionValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValueRef for StructValue with as_value_ref(self: StructValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValueRef for FunctionValue with as_value_ref(
  self: FunctionValue
) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValueRef for ArrayValue with as_value_ref(self: ArrayValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValueRef for VectorValue with as_value_ref(self: VectorValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValueRef for PhiValue with as_value_ref(self: PhiValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValueRef for ScalableVectorValue with as_value_ref(self: ScalableVectorValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValueRef for GlobalValue with as_value_ref(self: GlobalValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValueRef for MetadataValue with as_value_ref(self: MetadataValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AsValueRef for CallSiteValue with as_value_ref(self: CallSiteValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
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
pub trait AnyValue : AsValueRef + Show {
  as_any_value_enum(Self) -> AnyValueEnum;
  is_poison(Self) -> Bool;
}

pub impl AnyValue for IntValue with as_any_value_enum(self: IntValue) -> AnyValueEnum {
  AnyValueEnum::IntValue(self)
}

pub impl AnyValue for IntValue with is_poison(self: IntValue) -> Bool {
  self.is_poison()
}

pub impl AnyValue for FloatValue with as_any_value_enum(self: FloatValue) -> AnyValueEnum {
  AnyValueEnum::FloatValue(self)
}

pub impl AnyValue for FloatValue with is_poison(self: FloatValue) -> Bool {
  self.is_poison()
}

pub impl AnyValue for PointerValue with as_any_value_enum(self: PointerValue) -> AnyValueEnum {
  AnyValueEnum::PointerValue(self)
}

pub impl AnyValue for PointerValue with is_poison(self: PointerValue) -> Bool {
  self.is_poison()
}

pub impl AnyValue for InstructionValue with as_any_value_enum(self: InstructionValue) -> AnyValueEnum {
  AnyValueEnum::InstructionValue(self)
}

pub impl AnyValue for InstructionValue with is_poison(self: InstructionValue) -> Bool {
  self.is_poison()
}

pub impl AnyValue for StructValue with as_any_value_enum(self: StructValue) -> AnyValueEnum {
  AnyValueEnum::StructValue(self)
}

pub impl AnyValue for StructValue with is_poison(self: StructValue) -> Bool {
  self.is_poison()
}

pub impl AnyValue for ArrayValue with as_any_value_enum(self: ArrayValue) -> AnyValueEnum {
  AnyValueEnum::ArrayValue(self)
}

pub impl AnyValue for ArrayValue with is_poison(self: ArrayValue) -> Bool {
  self.is_poison()
}

pub impl AnyValue for VectorValue with as_any_value_enum(self: VectorValue) -> AnyValueEnum {
  AnyValueEnum::VectorValue(self)
}

pub impl AnyValue for VectorValue with is_poison(self: VectorValue) -> Bool {
  self.is_poison()
}

pub impl AnyValue for PhiValue with as_any_value_enum(self: PhiValue) -> AnyValueEnum {
  AnyValueEnum::PhiValue(self)
}

pub impl AnyValue for PhiValue with is_poison(self: PhiValue) -> Bool {
  self.is_poison()
}

pub impl AnyValue for ScalableVectorValue with as_any_value_enum(self: ScalableVectorValue) -> AnyValueEnum {
  AnyValueEnum::ScalableVectorValue(self)
}

pub impl AnyValue for ScalableVectorValue with is_poison(self: ScalableVectorValue) -> Bool {
  self.is_poison()
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
// AsTypeRef
//=========================================================
pub trait AsTypeRef {
  as_type_ref(Self) -> @unsafe.LLVMTypeRef
}

pub impl AsTypeRef for Type with as_type_ref(self: Type) -> @unsafe.LLVMTypeRef {
  self.type_ref
}

pub impl AsTypeRef for IntType with as_type_ref(self: IntType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

pub impl AsTypeRef for FloatType with as_type_ref(self: FloatType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

pub impl AsTypeRef for VoidType with as_type_ref(self: VoidType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

pub impl AsTypeRef for PointerType with as_type_ref(self: PointerType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

pub impl AsTypeRef for StructType with as_type_ref(self: StructType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

pub impl AsTypeRef for FunctionType with as_type_ref(self: FunctionType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

pub impl AsTypeRef for ArrayType with as_type_ref(self: ArrayType) -> @unsafe.LLVMTypeRef {
  self.as_type_ref()
}

pub impl AsTypeRef for VectorType with as_type_ref(self: VectorType) -> @unsafe.LLVMTypeRef {
  self.as_type_ref()
}

pub impl AsTypeRef for ScalableVectorType with as_type_ref(
  self: ScalableVectorType
) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

pub impl AsTypeRef for MetadataType with as_type_ref(self: MetadataType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}
//=========================================================
// AnyType
//=========================================================
pub trait AnyType : AsTypeRef + Show {
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
  fn_type(Self, Array[&BasicMetadataType], Bool) -> FunctionType;
  fn_type_unsafe(Self, Array[@unsafe.LLVMTypeRef], Bool) -> FunctionType;
  array_type(Self, UInt) -> ArrayType;
  ptr_type(Self, AddressSpace) -> PointerType;
  is_sized(Self) -> Bool;
  size_of(Self) -> IntValue?;
}

pub impl BasicType for IntType with as_basic_type_enum(self: IntType) -> BasicTypeEnum {
  BasicTypeEnum::IntType(self)
}

pub impl BasicType for IntType with fn_type(
  self: IntType, param_types: Array[&BasicMetadataType], is_var_arg: Bool
) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg=is_var_arg)
}

pub impl BasicType for IntType with fn_type_unsafe(
  self: IntType, param_types: Array[@unsafe.LLVMTypeRef], is_var_arg: Bool
) -> FunctionType {
  self.ty.fn_type_unsafe(param_types, is_var_arg=is_var_arg)
}

pub impl BasicType for IntType with array_type(
  self: IntType, size: UInt
) -> ArrayType {
  self.ty.array_type(size)
}

pub impl BasicType for IntType with ptr_type(self: IntType, address_space: AddressSpace) -> PointerType {
  self.ptr_type(address_space)
}

pub impl BasicType for IntType with size_of(self: IntType) -> IntValue? {
  Some(self.size_of())
}

pub impl BasicType for IntType with is_sized(self: IntType) -> Bool {
  self.is_sized()
}

pub impl BasicType for FloatType with as_basic_type_enum(self: FloatType) -> BasicTypeEnum {
  BasicTypeEnum::FloatType(self)
}

pub impl BasicType for FloatType with fn_type(
  self: FloatType, param_types: Array[&BasicMetadataType], is_var_arg: Bool
) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg=is_var_arg)
}

pub impl BasicType for FloatType with fn_type_unsafe(
  self: FloatType, param_types: Array[@unsafe.LLVMTypeRef], is_var_arg: Bool
) -> FunctionType {
  self.ty.fn_type_unsafe(param_types, is_var_arg=is_var_arg)
}

pub impl BasicType for FloatType with array_type(self: FloatType, size: UInt) -> ArrayType {
  self.array_type(size)
}

pub impl BasicType for FloatType with size_of(self: FloatType) -> IntValue? {
  Some(self.size_of())
}

pub impl BasicType for FloatType with is_sized(self: FloatType) -> Bool {
  self.is_sized()
}

pub impl BasicType for FloatType with ptr_type(self: FloatType, address_space: AddressSpace) -> PointerType {
  self.ptr_type(address_space)
}

pub impl BasicType for PointerType with as_basic_type_enum(self: PointerType) -> BasicTypeEnum {
  BasicTypeEnum::PointerType(self)
}

pub impl BasicType for PointerType with fn_type(
  self: PointerType, param_types: Array[&BasicMetadataType], is_var_arg: Bool
) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg=is_var_arg)
}

pub impl BasicType for PointerType with fn_type_unsafe(
  self: PointerType, param_types: Array[@unsafe.LLVMTypeRef], is_var_arg: Bool
) -> FunctionType {
  self.ty.fn_type_unsafe(param_types, is_var_arg=is_var_arg)
}


pub impl BasicType for PointerType with size_of(self: PointerType) -> IntValue? {
  Some(self.size_of())
}

pub impl BasicType for PointerType with is_sized(self: PointerType) -> Bool {
  self.is_sized()
}

pub impl BasicType for PointerType with ptr_type(self: PointerType, address_space: AddressSpace) -> PointerType {
  self.ptr_type(address_space)
}

pub impl BasicType for PointerType with array_type(self: PointerType, size: UInt) -> ArrayType {
  self.ty.array_type(size)
}

pub impl BasicType for StructType with as_basic_type_enum(self: StructType) -> BasicTypeEnum {
  BasicTypeEnum::StructType(self)
}

pub impl BasicType for StructType with fn_type(
  self: StructType, param_types: Array[&BasicMetadataType], is_var_arg: Bool
) -> FunctionType {
  self.fn_type(param_types, is_var_arg=is_var_arg)
}

pub impl BasicType for StructType with fn_type_unsafe(
  self: StructType, param_types: Array[@unsafe.LLVMTypeRef], is_var_arg: Bool
) -> FunctionType {
  self.ty.fn_type_unsafe(param_types, is_var_arg=is_var_arg)
}

pub impl BasicType for StructType with size_of(self: StructType) -> IntValue? {
  self.size_of()
}

pub impl BasicType for StructType with is_sized(self: StructType) -> Bool {
  self.is_sized()
}


pub impl BasicType for StructType with array_type(
  self: StructType, size: UInt
) -> ArrayType {
  self.ty.array_type(size)
}

pub impl BasicType for StructType with ptr_type(
  self: StructType, address_space: AddressSpace
) -> PointerType {
  self.ptr_type(address_space)
}

pub impl BasicType for ArrayType with as_basic_type_enum(self: ArrayType) -> BasicTypeEnum {
  BasicTypeEnum::ArrayType(self)
}

pub impl BasicType for ArrayType with fn_type(
  self: ArrayType, param_types: Array[&BasicMetadataType], is_var_arg: Bool
) -> FunctionType {
  self.fn_type(param_types, is_var_arg=is_var_arg)
}

pub impl BasicType for ArrayType with fn_type_unsafe(
  self: ArrayType, param_types: Array[@unsafe.LLVMTypeRef], is_var_arg: Bool
) -> FunctionType {
  self.ty.fn_type_unsafe(param_types, is_var_arg=is_var_arg)
}

pub impl BasicType for ArrayType with size_of(self: ArrayType) -> IntValue? {
  self.size_of()
}

pub impl BasicType for ArrayType with is_sized(self: ArrayType) -> Bool {
  self.is_sized()
}

pub impl BasicType for ArrayType with array_type(self: ArrayType, size: UInt) -> ArrayType {
  self.array_type(size)
}

pub impl BasicType for ArrayType with ptr_type(self: ArrayType, address_space: AddressSpace) -> PointerType {
  self.ptr_type(address_space)
}

pub impl BasicType for VectorType with as_basic_type_enum(self: VectorType) -> BasicTypeEnum {
  BasicTypeEnum::VectorType(self)
}

pub impl BasicType for ScalableVectorType with as_basic_type_enum(self: ScalableVectorType) -> BasicTypeEnum {
  BasicTypeEnum::ScalableVectorType(self)
}

pub impl BasicType for VectorType with size_of(self: VectorType) -> IntValue? {
  self.size_of()
}

pub impl BasicType for VectorType with is_sized(self: VectorType) -> Bool {
  self.is_sized()
}

pub impl BasicType for VectorType with fn_type(
  self: VectorType, param_types: Array[&BasicMetadataType], is_var_arg: Bool
) -> FunctionType {
  self.fn_type(param_types, is_var_arg=is_var_arg)
}

pub impl BasicType for VectorType with fn_type_unsafe(
  self: VectorType, param_types: Array[@unsafe.LLVMTypeRef], is_var_arg: Bool
) -> FunctionType {
  self.ty.fn_type_unsafe(param_types, is_var_arg=is_var_arg)
}

pub impl BasicType for VectorType with array_type(
  self: VectorType, size: UInt
) -> ArrayType {
  self.ty.array_type(size)
}

pub impl BasicType for VectorType with ptr_type(self: VectorType, address_space: AddressSpace) -> PointerType {
  PointerType::new(@unsafe.llvm_pointer_type(self.as_type_ref(), address_space.into()))
}

pub impl BasicType for ScalableVectorType with size_of(self: ScalableVectorType) -> IntValue? {
  self.ty.size_of()
}

pub impl BasicType for ScalableVectorType with is_sized(self: ScalableVectorType) -> Bool {
  self.ty.is_sized()
}

pub impl BasicType for ScalableVectorType with fn_type(
  self: ScalableVectorType, param_types: Array[&BasicMetadataType], is_var_arg: Bool
) -> FunctionType {
  self.fn_type(param_types, is_var_arg=is_var_arg)
}

pub impl BasicType for ScalableVectorType with fn_type_unsafe(
  self: ScalableVectorType, param_types: Array[@unsafe.LLVMTypeRef], is_var_arg: Bool
) -> FunctionType {
  self.ty.fn_type_unsafe(param_types, is_var_arg=is_var_arg)
}

pub impl BasicType for ScalableVectorType with array_type(
  self: ScalableVectorType, size: UInt
) -> ArrayType {
  self.ty.array_type(size)
}

pub impl BasicType for ScalableVectorType with ptr_type(
  self: ScalableVectorType, address_space: AddressSpace
) -> PointerType {
  self.ty.ptr_type(address_space)
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
