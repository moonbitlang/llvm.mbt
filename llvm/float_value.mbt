// ============================================
// FloatValue
// ============================================
///| A `FloatValue` is a value that represents a floating point number.
pub struct FloatValue {
  value: Value
}

///| Get a value from an `@unsafe.LLVMValueRef`.
///
/// **unsafe**: Undefined behavior if `value_ref` is not a `FloatValue`.
pub fn FloatValue::new(value_ref: @unsafe.LLVMValueRef) -> FloatValue {
  assert_val_ref(value_ref)

  FloatValue::{
    value: Value::new(value_ref)
  }
}

///| Gets name of the `FloatValue`.
/// If the value is a constant, this will return an empty string.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let pi = f64_type.const_float(3.14);
/// inspect!(pi.get_name(), "");
/// pi.set_name("pi");
/// inspect!(pi.get_name(), "pi");
/// ```
pub fn FloatValue::get_name(self: FloatValue) -> String {
  self.value.get_name()
}

///| Set name of the `FloatValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let pi = f64_type.const_float(3.14);
/// pi.set_name("pi");
/// inspect!(pi.get_name(), "pi");
/// ```
pub fn FloatValue::set_name(self: FloatValue, name: String) -> Unit {
  self.value.set_name(name)
}

///| Gets the type of the `FloatValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let pi = f64_type.const_float(3.14);
/// inspect!(pi.get_type(), "float");
/// ```
pub fn FloatValue::get_type(self: FloatValue) -> FloatType {
  FloatType::new(self.value.get_type().as_type_ref())
}

///| Returns whether or not the `FloatValue` is null.
pub fn FloatValue::is_null(self: FloatValue) -> Bool {
  self.value.is_null()
}

///| Returns whether or not the `FloatValue` is undefined.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let undef = f64_type.get_undef();
/// assert_true!(undef.is_undef());
/// ```
pub fn FloatValue::is_undef(self: FloatValue) -> Bool {
  self.value.is_undef()
}

pub fn FloatValue::as_instruction(self: FloatValue) -> InstructionValue? {
  self.value.as_instruction()
}

// -----------------------
// TODO: const ops: add, sub, mul ...
// -----------------------
// pub fn FloatValue::const_compare(self: FloatValue, op: FloatPredicate, rhs: FloatValue) -> IntValue {
//   IntValue::new(@unsafe.llvm_const_fcmp(op.into(). self.as_value_ref(), rhs.as_value_ref())
// }

///| Determines whether or not a `FloatValue` is a constant.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let f64_val = f64_type.const_float(1.2);
/// assert_true!(f64_val.is_const());
/// ```
pub fn FloatValue::is_const(self: FloatValue) -> Bool {
  self.value.is_const()
}

///| Obtains a constant `FloatValue`'s value and whether or not it lost info.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let pi = f64_type.const_float(3.14);
///
/// inspect!(pi.get_constant(), "Some((3.14, false))");
/// ```
pub fn FloatValue::get_constant(self: FloatValue) -> (Double, Bool)? {
  if not(self.is_const()) {
    return None
  }

  let (v, lossy) = @unsafe.llvm_const_real_get_double(self.as_value_ref())

  Some((v, lossy))
}

///| Replaces all uses of a `FloatValue` with another `FloatValue`.
pub fn FloatValue::replace_all_uses_with(self: FloatValue, new_value: FloatValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///| Dumps the `FloatValue` to stderr.
///
/// It's equivalent to `FloatValue::dump`.
pub fn FloatValue::print_to_stderr(self: FloatValue) -> Unit {
  self.value.print_to_stderr()
}

///| Dumps the `FloatValue` to a string.
///
/// It's equivalent to `FloatValue::to_string`.
pub fn FloatValue::print_to_string(self: FloatValue) -> String {
  self.value.print_to_string()
}

///| Dumps the `FloatValue` to a string.
///
/// It's equivalent to `FloatValue::print_to_string`.
pub fn FloatValue::to_string(self: FloatValue) -> String {
  self.value.to_string()
}

///| Dump the `FloatValue` to stderr.
///
/// It's equivalent to `FloatValue::print_to_stderr`.
pub fn FloatValue::dump(self: FloatValue) -> Unit {
  self.value.dump()
}

pub impl Show for FloatValue with output(self: FloatValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for FloatValue with to_string(self: FloatValue) -> String {
  self.to_string()
}


