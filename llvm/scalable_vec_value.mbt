// ============================================
// ScalableVectorValue
// ============================================

///| A `ScalableVectorValue` is a value that represents a scalable vector.
pub struct ScalableVectorValue {
  value : ValueRef
}

///| Creates a new `ScalableVectorValue` from an `@unsafe.LLVMValueRef`.
pub fn ScalableVectorValue::new(
  value_ref : @unsafe.LLVMValueRef
) -> ScalableVectorValue {
  guard value_ref.is_not_null()
  ScalableVectorValue::{ value: ValueRef::new(value_ref) }
}

///|
pub impl Value for ScalableVectorValue with base(self) {
  self.value
}

///|
pub impl Value for ScalableVectorValue with as_value_enum(self) {
  ScalableVectorValue(self)
}

///|
pub impl BasicValue for ScalableVectorValue with as_basic_value_enum(self) {
  ScalableVectorValue(self)
}

///|
pub impl AggregateValue for ScalableVectorValue with as_aggregate_value_enum(
  self
) {
  ScalableVectorValue(self)
}

///| Determines whether or not a `ScalableVectorValue` is a constant.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i8_type = context.i8_type();
/// let i8_scalable_vec_type = i8_type.scalable_vec_type(3);
/// let i8_scalable_vec_zero = i8_scalable_vec_type.const_zero();
///
/// assert_true(i8_scalable_vec_zero.is_const());
/// ```
pub fn ScalableVectorValue::is_const(self : ScalableVectorValue) -> Bool {
  self.value.is_const()
}

///| Get the name of the `ScalableVectorValue`.
/// If the value is a constant, this will return an empty string.
pub fn ScalableVectorValue::get_name(self : ScalableVectorValue) -> String {
  self.value.get_name()
}

///| Set name of the `ScalableVectorValue`.
pub fn ScalableVectorValue::set_name(
  self : ScalableVectorValue,
  name : String
) -> Unit {
  self.value.set_name(name)
}

///| Get the type of the `ScalableVectorValue`.
pub fn ScalableVectorValue::get_type(
  self : ScalableVectorValue
) -> ScalableVectorType {
  ScalableVectorType::new(self.value.get_type().inner())
}

///| Determines whether or not this `ScalableVectorValue` is null.
pub fn ScalableVectorValue::is_null(self : ScalableVectorValue) -> Bool {
  self.value.is_null()
}

///| Determines whether or not this `ScalableVectorValue` is undefined.
pub fn ScalableVectorValue::is_undef(self : ScalableVectorValue) -> Bool {
  self.value.is_undef()
}

///| Attempt to convert this `ScalableVectorValue` to an `InstructionValue`, if possible.
pub fn ScalableVectorValue::as_instruction(
  self : ScalableVectorValue
) -> InstructionValue? {
  self.value.as_instruction()
}

///|
pub fn ScalableVectorValue::const_extract_element(
  self : ScalableVectorValue,
  index : IntValue
) -> BasicValueEnum {
  BasicValueEnum::init(
    @unsafe.llvm_const_extract_element(self.inner(), index.inner()),
  )
}

///|
pub fn ScalableVectorValue::const_insert_element(
  self : ScalableVectorValue,
  element : &BasicValue,
  index : IntValue
) -> BasicValueEnum {
  BasicValueEnum::init(
    @unsafe.llvm_const_insert_element(
      self.inner(),
      element.inner(),
      index.inner(),
    ),
  )
}

///|
pub fn ScalableVectorValue::replace_all_uses_with(
  self : ScalableVectorValue,
  new_value : ScalableVectorValue
) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///|
pub fn ScalableVectorValue::const_shuffle_vector(
  self : ScalableVectorValue,
  right : ScalableVectorValue,
  mask : ScalableVectorValue
) -> ScalableVectorValue {
  ScalableVectorValue::new(
    @unsafe.llvm_const_shuffle_vector(self.inner(), right.inner(), mask.inner()),
  )
}

///|
pub impl Show for ScalableVectorValue with output(
  self : ScalableVectorValue,
  logger : &Logger
) -> Unit {
  logger.write_string(self.value.to_string())
}
