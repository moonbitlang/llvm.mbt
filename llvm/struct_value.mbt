// ============================================
// StructValue
// ============================================

///| A `StructValue` is a value that represents a struct.
pub struct StructValue {
  value : ValueRef
}

///| Get a value from an `@unsafe.LLVMValueRef`.
///
/// **unsafe**: Undefined behavior if `value_ref` is not a struct.
pub fn StructValue::new(value_ref : @unsafe.LLVMValueRef) -> StructValue {
  guard value_ref.is_not_null()
  StructValue::{ value: ValueRef::new(value_ref) }
}

pub impl Value for StructValue with base(self) {
  self.value
}

pub impl Value for StructValue with as_value_enum(self) {
  StructValue(self)
}

pub impl BasicValue for StructValue with as_basic_value_enum(self) {
  StructValue(self)
}

pub impl AggregateValue for StructValue with as_aggregate_value_enum(self) {
  StructValue(self)
}

///| Gets the value of a field belonging to this `StructValue`.
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i8_type = context.i8_type();
/// let i8_val = i8_type.const_all_ones();
/// let i32_val = i32_type.const_all_ones();
/// let struct_type = context.struct_type([i8_type, i32_type]);
/// let struct_val = struct_type.const_named_struct([i8_val, i32_val]);
///
/// assert_true(struct_val.get_field_at_index(0) is Some(_));
/// assert_true(struct_val.get_field_at_index(1) is Some(_));
/// assert_true(struct_val.get_field_at_index(2) is None);
/// assert_true(struct_val.get_field_at_index(0).unwrap() is IntValue(_));
/// ```
pub fn StructValue::get_field_at_index(
  self : StructValue,
  index : UInt
) -> BasicValueEnum? {
  if index >= self.count_fields() {
    return None
  }
  Some(self.get_field_at_index_unchecked(index))
}

///|
fn StructValue::get_field_at_index_unchecked(
  self : StructValue,
  index : UInt
) -> BasicValueEnum {
  let v = @unsafe.llvm_get_operand(self.inner(), index)
  BasicValueEnum::init(v)
}

// pub fn StructValue::get_fields

// TODO: Should throw an error if
// 1. index is out of bounds
// 2. type of field is not the same as the type of value

///| Sets the value of a field belonging to this `StructValue`.
pub fn StructValue::set_field_at_index(
  self : StructValue,
  index : UInt,
  val : &BasicValue
) -> Bool {
  if self
    .get_type()
    .get_field_type_at_index(index)
    .map(fn(t) { (t as &Type) == val.get_type() }) !=
    Some(true) {
    return false
  }
  @unsafe.llvm_set_operand(self.inner(), index, val.inner())
  true
}

///| Counts the number of fields.
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i8_type = context.i8_type();
/// let i8_val = i8_type.const_all_ones();
/// let i32_val = i32_type.const_all_ones();
/// let struct_type = context.struct_type([i8_type, i32_type]);
/// let struct_val = struct_type.const_named_struct([i8_val, i32_val]);
///
/// assert_eq(struct_val.count_fields(), 2);
/// assert_eq(struct_val.count_fields(), struct_type.count_fields());
/// ```
pub fn StructValue::count_fields(self : StructValue) -> UInt {
  @unsafe.llvm_get_num_operands(self.inner()).reinterpret_as_uint()
}

///| Gets the name of a `StructValue`.
/// If the value is a constant, this will return an empty string.
pub fn get_name(self : StructValue) -> String {
  self.value.get_name()
}

///| Set name of the `StructValue`.
pub fn set_name(self : StructValue, name : String) -> Unit {
  self.value.set_name(name)
}

///| Get the type of the `StructValue`.
pub fn get_type(self : StructValue) -> StructType {
  StructType::new(self.value.get_type().inner())
}

///| Determines whether or not this `StructValue` is null.
pub fn is_null(self : StructValue) -> Bool {
  self.value.is_null()
}

///| Determines whether or not this `StructValue` is undefined.
pub fn is_undef(self : StructValue) -> Bool {
  self.value.is_undef()
}

// REVIEW: Does this always return `None`?

///| Converts a struct value to an instruction value.
pub fn as_instruction(self : StructValue) -> InstructionValue? {
  self.value.as_instruction()
}

///| Replace all uses of an `StructValue` with another `StructValue`.
pub fn StructValue::replace_all_uses_with(
  self : StructValue,
  new_value : StructValue
) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///| Determines whether or not this `StructValue` is constant.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i64_type = context.i64_type();
/// let i64_val = i64_type.const_int(23, sign_extend=false);
/// let struct_val = context.const_struct([i64_val, i64_val]);
/// assert_true(struct_val.is_const());
/// ```
pub fn StructValue::is_const(self : StructValue) -> Bool {
  self.value.is_const()
}

///|
pub impl Show for StructValue with output(self : StructValue, logger : &Logger) -> Unit {
  logger.write_string(self.value.to_string())
}
