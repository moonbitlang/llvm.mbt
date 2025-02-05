// ============================================
// VectorValue
// ============================================
///| A `VectorValue` is a value that represents a vector.
pub struct VectorValue {
  value: Value
}

///| Creates a new `VectorValue` from an `@unsafe.LLVMValueRef`.
pub fn VectorValue::new(value_ref: @unsafe.LLVMValueRef) -> VectorValue {
  assert_val_ref(value_ref)

  VectorValue::{
    value: Value::new(value_ref)
  }
}

///| Returns the `@unsafe.LLVMValueRef` that this `VectorValue` wraps.
pub fn VectorValue::as_value_ref(self: VectorValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

///| Determines whether or not a `VectorValue` is a constant.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i8_type = context.i8_type();
/// let i8_vec_type = i8_type.vec_type(3);
/// let i8_vec_zero = i8_vec_type.const_zero();
///
/// assert_true!(i8_vec_zero.is_const());
/// ```
pub fn VectorValue::is_const(self: VectorValue) -> Bool {
  self.value.is_const()
}

pub fn VectorValue::is_constant_vector(self: VectorValue) -> Bool {
  @unsafe.llvm_isa_constant_vector(self.as_value_ref()).is_null()
}

pub fn VectorValue::is_constant_data_vector(self: VectorValue) -> Bool {
  @unsafe.llvm_isa_constant_data_vector(self.as_value_ref()).is_null()
}

///| Gets the name of a `VectorValue`.
/// If the value is a constant, this will return an empty string.
pub fn VectorValue::get_name(self: VectorValue) -> String {
  self.value.get_name()
}

///| Set name of the `VectorValue`.
pub fn VectorValue::set_name(self: VectorValue, name: String) -> Unit {
  self.value.set_name(name)
}

pub fn VectorValue::get_type(self: VectorValue) -> VectorType {
  VectorType::new(self.value.get_type().as_type_ref())
}

pub fn VectorValue::is_null(self: VectorValue) -> Bool {
  self.value.is_null()
}

pub fn VectorValue::is_undef(self: VectorValue) -> Bool {
  self.value.is_undef()
}

pub fn VectorValue::as_instruction(self: VectorValue) -> InstructionValue? {
  self.value.as_instruction()
}

pub fn VectorValue::replace_all_uses_with(self: VectorValue, new_value: VectorValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

pub fn VectorValue::const_shuffle_vector(self: VectorValue, right: VectorValue, mask: VectorValue) -> VectorValue {
  VectorValue::new(@unsafe.llvm_const_shuffle_vector(self.as_value_ref(), right.as_value_ref(), mask.as_value_ref()))
}

pub fn VectorValue::print_to_stderr(self: VectorValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn VectorValue::print_to_string(self: VectorValue) -> String {
  self.value.print_to_string()
}

pub fn VectorValue::to_string(self: VectorValue) -> String {
  self.value.to_string()
}

pub fn VectorValue::dump(self: VectorValue) -> Unit {
  self.value.dump()
}

pub impl Show for VectorValue with output(self: VectorValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for VectorValue with to_string(self: VectorValue) -> String {
  self.to_string()
}


