// =========================================
// IntValue
// =========================================
///| An `IntValue` is a value that represents an integer.
pub struct IntValue {
  value: Value
}

///| Get a value from an `@unsafe.LLVMValueRef`.
///
/// **unsafe**: Undefined behavior if `value_ref` is not an `IntValue`.
pub fn IntValue::new(value_ref: @unsafe.LLVMValueRef) -> IntValue {
  assert_val_ref(value_ref)

  IntValue::{
    value: Value::new(value_ref)
  }
}

///| Returns the `@unsafe.LLVMValueRef` that this `IntValue` wraps.
pub fn IntValue::as_value_ref(self: IntValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

/// Gets the name of an `IntValue`.
/// If the value is a constant, this will return an empty string.
pub fn IntValue::get_name(self: IntValue) -> String {
  self.value.get_name()
}

///| Set name of the `IntValue`.
pub fn IntValue::set_name(self: IntValue, name: String) -> Unit {
  self.value.set_name(name)
}

///| Gets the type of an `IntValue`.
pub fn IntValue::get_type(self: IntValue) -> IntType {
  IntType::new(self.value.get_type().as_type_ref())
}

///| Returns whether or not the `IntValue` is null.
pub fn IntValue::is_null(self: IntValue) -> Bool {
  self.value.is_null()
}

///| Returns whether or not the `IntValue` is undefined.
pub fn IntValue::is_undef(self: IntValue) -> Bool {
  self.value.is_undef()
}

///| Converts the `IntValue` into an `InstructionValue` if it is an instruction.
/// If it is not an instruction, `None` is returned.
pub fn IntValue::as_instruction(self: IntValue) -> InstructionValue? {
  self.value.as_instruction()
}

///| Returns the not of the constant `IntValue`.
pub fn IntValue::const_not(self: IntValue) -> IntValue {
  let value_ref = @unsafe.llvm_const_not(self.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the negation of the constant `IntValue`.
pub fn IntValue::const_neg(self: IntValue) -> IntValue {
  let value_ref = @unsafe.llvm_const_neg(self.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the negation of the constant `IntValue` with NSW flag.
pub fn IntValue::const_nsw_neg(self: IntValue) -> IntValue {
  let value_ref = @unsafe.llvm_const_nsw_neg(self.as_value_ref())
  IntValue::new(value_ref)
}

// NOTE: use @unsafe.LLVMConstNull
// pub fn IntValue::const_nuw_neg(self: IntValue) -> IntValue {
//   let value_ref = @unsafe.llvm_const_nuw_neg(self.as_value_ref())
//   IntValue::new(value_ref)
// }

///| Returns the addition of two constant `IntValue`s.
pub fn IntValue::const_add(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = @unsafe.llvm_const_add(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the addition of two constant `IntValue`s with NSW flag.
pub fn IntValue::const_nsw_add(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = @unsafe.llvm_const_nsw_add(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the addition of two constant `IntValue`s with NUW flag.
pub fn IntValue::const_nuw_add(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = @unsafe.llvm_const_nuw_add(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the subtraction of two constant `IntValue`s.
pub fn IntValue::const_sub(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = @unsafe.llvm_const_sub(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the subtraction of two constant `IntValue`s with NSW flag.
pub fn IntValue::const_nsw_sub(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = @unsafe.llvm_const_nsw_sub(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the subtraction of two constant `IntValue`s with NUW flag.
pub fn IntValue::const_nuw_sub(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = @unsafe.llvm_const_nuw_sub(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the multiplication of two constant `IntValue`s.
pub fn IntValue::const_mul(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = @unsafe.llvm_const_mul(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the multiplication of two constant `IntValue`s with NSW flag.
pub fn IntValue::const_nsw_mul(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = @unsafe.llvm_const_nsw_mul(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the multiplication of two constant `IntValue`s with NUW flag.
pub fn IntValue::const_nuw_mul(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = @unsafe.llvm_const_nuw_mul(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

// pub fn IntValue::const_and(self: IntValue, rhs: IntValue) -> IntValue {
//   let value_ref = @unsafe.llvm_const_and(self.as_value_ref(), rhs.as_value_ref())
//   IntValue::new(value_ref)
// }
//
// pub fn IntValue::const_or(self: IntValue, rhs: IntValue) -> IntValue {
//   let value_ref = @unsafe.llvm_const_or(self.as_value_ref(), rhs.as_value_ref())
//   IntValue::new(value_ref)
// }

///| Returns the XOR of two constant `IntValue`s.
pub fn IntValue::const_xor(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = @unsafe.llvm_const_xor(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

// const_cast
// const_shl
// const_rshr
// const_ashr
// const_unsigned_to_float
// const_signed_to_float
pub fn IntValue::const_to_pointer(self: IntValue, ptr_type: PointerType) -> PointerValue {
  PointerValue::new(@unsafe.llvm_const_int_to_ptr(self.as_value_ref(), ptr_type.as_type_ref()))
}

pub fn IntValue::const_truncate(self: IntValue, int_type: IntType) -> IntValue {
  IntValue::new(@unsafe.llvm_const_trunc(self.as_value_ref(), int_type.as_type_ref()))
}
pub fn IntValue::const_truncate_or_bit_cast(self: IntValue, int_type: IntType) -> IntValue {
  IntValue::new(@unsafe.llvm_const_trunc_or_bit_cast(self.as_value_ref(), int_type.as_type_ref()))
}
pub fn IntValue::const_bit_cast(self: IntValue, int_tyep: IntType) -> IntValue {
  IntValue::new(@unsafe.llvm_const_bit_cast(self.as_value_ref(), int_tyep.as_type_ref()))
}
// const_int_compare

///| Determines whether or not an `IntValue` is an `llvm::Constant`.
///
/// Constants includes values that are not known at compile time, for
/// example the address of a function casted to an integer.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i64_type = context.i64_type();
/// let i64_val = i64_type.const_int(42);
/// assert_true!(i64_val.is_const());
/// ```
pub fn IntValue::is_const(self: IntValue) -> Bool {
  self.value.is_const()
}

///| Determines whether or not an `IntValue` is an `llvm::ConstantInt`.
///
/// ConstantInt only includes values that are known at compile time.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i64_type = context.i64_type();
/// let i64_val = i64_type.const_int(42);
/// assert_true!(i64_val.is_constant_int());
/// ```
pub fn IntValue::is_constant_int(self: IntValue) -> Bool {
  @unsafe.llvm_isa_constant_int(self.as_value_ref()).is_null()
}

///| Obtains a constant `IntValue`'s zero extended value.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i8_type = context.i8_type();
/// let i8_all_ones = i8_type.const_all_ones();
///
/// inspect!(i8_all_ones.get_zero_extended_constant(), "Some(255)");
/// ```
pub fn IntValue::get_zero_extended_constant(self: IntValue) -> UInt64? {
  if not(self.is_constant_int()) {
    return None
  }

  if self.get_type().get_bit_width() > 64 {
    return None
  }

  let v = @unsafe.llvm_const_int_get_z_ext_value(self.as_value_ref())
  Some(v)
}

///| Obtains a constant `IntValue`'s zero extended value.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i8_type = context.i8_type();
/// let i8_all_ones = i8_type.const_all_ones();
///
/// inspect!(i8_all_ones.get_sign_extended_constant(), "Some(-1)");
/// ```
pub fn IntValue::get_sign_extended_constant(self: IntValue) -> Int64? {
  if not(self.is_constant_int()) {
    return None
  }

  if self.get_type().get_bit_width() > 64 {
    return None
  }

  let v = @unsafe.llvm_const_int_get_s_ext_value(self.as_value_ref())
  Some(v)
}

///| Replaces all uses of an `IntValue` with another `IntValue`.
pub fn IntValue::replace_all_uses_with(self: IntValue, new_value: IntValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///| Dumps the `IntValue` to stderr.
///
/// It's equivalent to `IntValue::dump`.
pub fn IntValue::print_to_stderr(self: IntValue) -> Unit {
  self.value.print_to_stderr()
}

///| Dumps the `IntValue` to a string.
///
/// It's equivalent to `IntValue::to_string`.
pub fn IntValue::print_to_string(self: IntValue) -> String {
  self.value.print_to_string()
}

///| Dumps the `IntValue` to a string.
///
/// It's equivalent to `IntValue::print_to_string`.
pub fn IntValue::to_string(self: IntValue) -> String {
  self.value.to_string()
}

///| Dump the `IntValue` to stderr.
///
/// It's equivalent to `IntValue::print_to_stderr`.
pub fn IntValue::dump(self: IntValue) -> Unit {
  self.value.dump()
}

pub impl Show for IntValue with output(self: IntValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for IntValue with to_string(self: IntValue) -> String {
  self.to_string()
}

