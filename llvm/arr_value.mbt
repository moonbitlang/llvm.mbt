// ============================================
// ArrayValue
// ============================================

///| An `ArrayValue` is a value that represents an array.
pub struct ArrayValue {
  value : ValueRef
}

///| Creates a new `ArrayValue` from an `@unsafe.LLVMValueRef`.
pub fn ArrayValue::new(value_ref : @unsafe.LLVMValueRef) -> ArrayValue {
  guard value_ref.is_not_null()
  ArrayValue::{ value: ValueRef::new(value_ref) }
}

pub impl Value for ArrayValue with base(self) {
  self.value
}

pub impl Value for ArrayValue with as_value_enum(self) {
  ArrayValue(self)
}

pub impl BasicValue for ArrayValue with as_basic_value_enum(self) {
  ArrayValue(self)
}

pub impl AggregateValue for ArrayValue with as_aggregate_value_enum(self) {
  ArrayValue(self)
}

///| Creates a new constant `ArrayValue` with the given type and values.
pub fn ArrayValue::new_const_array(
  ty : &Type,
  values : Array[&Value]
) -> ArrayValue {
  let value_refs = values.map(v => v.inner() )
  let value_ref = @unsafe.llvm_const_array(ty.inner(), value_refs)
  ArrayValue::new(value_ref)
}

///| Get the name of the `ArrayValue`.
pub fn ArrayValue::get_name(self : ArrayValue) -> String {
  self.value.get_name()
}

///| Set name of the `ArrayValue`.
pub fn ArrayValue::set_name(self : ArrayValue, name : String) -> Unit {
  self.value.set_name(name)
}

///| Get the type of the `ArrayValue`.
pub fn ArrayValue::get_type(self : ArrayValue) -> ArrayType {
  ArrayType::new(self.value.get_type().inner())
}

///| Determines whether or not this `ArrayValue` is null.
pub fn ArrayValue::is_null(self : ArrayValue) -> Bool {
  self.value.is_null()
}

///| Determines whether or not this `ArrayValue` is undefined.
pub fn ArrayValue::is_undef(self : ArrayValue) -> Bool {
  self.value.is_undef()
}

///| Attempt to convert this `ArrayValue` to an `InstructionValue`, if possible.
pub fn ArrayValue::as_instruction(self : ArrayValue) -> InstructionValue? {
  self.value.as_instruction()
}

///| Replaces all uses of this value with another value of the same type.
/// If used incorrectly this may result in invalid IR.
pub fn ArrayValue::replace_all_uses_with(
  self : ArrayValue,
  new_value : ArrayValue
) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///| Determines whether or not an `ArrayValue` is a constant.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i64_type = context.i64_type();
/// let i64_val = i64_type.const_int(23);
/// let array_val = i64_type.const_array([i64_val]);
/// assert_true(array_val.is_const());
/// ```
pub fn ArrayValue::is_const(self : ArrayValue) -> Bool {
  self.value.is_const()
}

///| Determines whether or not an `ArrayValue` represents a constant array of `i8`s.
///
/// # Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let s = context.const_string("my_string", false);
///
/// assert_true(s.is_const_string());
/// ```
pub fn ArrayValue::is_const_string(self : ArrayValue) -> Bool {
  // @unsafe.llvm_is_constant_string(self.inner())
  self.inner().is_constant_string()
}

///| Obtain the string from the ArrayValue
/// if the value points to a constant string.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let string = context.const_string("hello!", true);
///
/// assert_true(string.get_string_constant() is Some(_));
/// ```
pub fn ArrayValue::get_string_constant(self : ArrayValue) -> String? {
  let s = @unsafe.llvm_get_as_string(self.inner())
  match s.is_empty() {
    true => None
    false => Some(s)
  }
}

///|
pub impl Show for ArrayValue with output(self : ArrayValue, logger : &Logger) -> Unit {
  logger.write_string(self.value.to_string())
}
