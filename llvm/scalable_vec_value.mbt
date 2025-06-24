// ============================================
// ScalableVectorValue
// ============================================

///| A `ScalableVectorValue` is a value that represents a scalable vector.
pub struct ScalableVectorValue {
  value : Value
}

///| Creates a new `ScalableVectorValue` from an `@unsafe.LLVMValueRef`.
pub fn ScalableVectorValue::new(
  value_ref : @unsafe.LLVMValueRef
) -> ScalableVectorValue {
  guard value_ref.is_not_null()
  ScalableVectorValue::{ value: Value::new(value_ref) }
}

///| Returns the `Value` that this `ScalableVectorValue` wraps.
pub fn ScalableVectorValue::as_value(self : ScalableVectorValue) -> Value {
  self.value
}

///| Returns the `@unsafe.LLVMValueRef` that this `ScalableVectorValue` wraps.
pub fn ScalableVectorValue::as_value_ref(
  self : ScalableVectorValue
) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

///| Determines whether or not a `ScalableVectorValue` is a constant.
///
/// ## Example
///
/// ```moonbit skip
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
  ScalableVectorType::new(self.value.get_type().as_type_ref())
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
  BasicValueEnum::new(
    @unsafe.llvm_const_extract_element(
      self.as_value_ref(),
      index.as_value_ref(),
    ),
  )
}

///|
pub fn ScalableVectorValue::const_insert_element(
  self : ScalableVectorValue,
  element : &BasicValue,
  index : IntValue
) -> BasicValueEnum {
  BasicValueEnum::new(
    @unsafe.llvm_const_insert_element(
      self.as_value_ref(),
      element.as_value_ref(),
      index.as_value_ref(),
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
    @unsafe.llvm_const_shuffle_vector(
      self.as_value_ref(),
      right.as_value_ref(),
      mask.as_value_ref(),
    ),
  )
}

///| Dumps the `ScalableVectorValue` to stderr.
///
/// It's equivalent to `ScalableVectorValue::dump`.
pub fn ScalableVectorValue::print_to_stderr(self : ScalableVectorValue) -> Unit {
  self.value.print_to_stderr()
}

///| Dumps the `ScalableVectorValue` to a string.
///
/// It's equivalent to `ScalableVectorValue::to_string`.
pub fn ScalableVectorValue::print_to_string(
  self : ScalableVectorValue
) -> String {
  self.value.print_to_string()
}

///| Dumps the `ScalableVectorValue` to a string.
///
/// It's equivalent to `ScalableVectorValue::print_to_string`.
pub fn ScalableVectorValue::to_string(self : ScalableVectorValue) -> String {
  self.value.to_string()
}

///| Dumps the `ScalableVectorValue` to stderr.
///
/// It's equivalent to `ScalableVectorValue::print_to_stderr`.
pub fn ScalableVectorValue::dump(self : ScalableVectorValue) -> Unit {
  self.value.dump()
}

///|
pub impl Show for ScalableVectorValue with output(
  self : ScalableVectorValue,
  logger : &Logger
) -> Unit {
  logger.write_string(self.to_string())
}

///|
pub impl Show for ScalableVectorValue with to_string(self : ScalableVectorValue) -> String {
  self.to_string()
}
