// ===================================
// Values
// ===================================
pub struct Value {
  value_ref: LLVMValueRef
}

pub fn Value::new(value_ref: LLVMValueRef) -> Value {
  if llvm_is_null(value_ref) == 1 {
    println("Value is null")
    panic()
  }

  Value::{
    value_ref
  }
}

pub fn Value::as_value_ref(self: Value) -> LLVMValueRef {
  self.value_ref
}

pub fn Value::is_instruction(self: Value) -> Bool {
  llvm_isa_instruction(self.as_value_ref()).is_null()
}

pub fn Value::as_instruction(self: Value) -> InstructionValue? {
  if not(self.is_instruction()) {
    return None
  }

  Some(InstructionValue::new(self.as_value_ref()))
}

pub fn Value::is_null(self: Value) -> Bool {
  llvm_is_null(self.as_value_ref()) == 1
}

pub fn Value::is_const(self: Value) -> Bool {
  llvm_is_constant(self.as_value_ref())
}

pub fn Value::set_name(self: Value, name: String) -> Unit {
  let value_ref = self.as_value_ref()
  llvm_set_value_name(value_ref, name)
}

// TODO: This API use `LLVMGetValueName2` possibly problematic
pub fn Value::get_name(self: Value) -> String {
  self.as_value_ref().get_name()

}

fn Value::is_undef(self: Value) -> Bool {
  self.as_value_ref().is_undef()
}

fn Value::get_type(self: Value) -> Type {
  let type_ref = llvm_type_of(self.as_value_ref())
  Type::new(type_ref)
}

fn Value::replace_all_uses_with(self: Value, new_value: Value) -> Unit {
  llvm_replace_all_uses_with(self.as_value_ref(), new_value.as_value_ref())
}

pub fn Value::get_first_use(self: Value) -> BasicValueUse? {
  let use_ = llvm_get_first_use(self.as_value_ref())

  if use_.is_null() {
    None
  } else {
    Some(BasicValueUse::new(use_))
  }
}

// pub fn get_section(self: Value) -> String?
// pub fn set_section(self: Value) -> String?

pub fn Value::print_to_stderr(self: Value) -> Unit {
  llvm_dump_value(self.as_value_ref())
}

pub fn Value::print_to_string(self: Value) -> String {
  llvm_print_value_to_string(self.as_value_ref())
}

pub fn Value::to_string(self: Value) -> String {
  llvm_print_value_to_string(self.as_value_ref())
}

pub fn Value::dump(self: Value) -> Unit {
  llvm_dump_value(self.as_value_ref())
}

pub impl Show for Value with output(self: Value, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// =========================================
// IntValue
// =========================================
///| An `IntValue` is a value that represents an integer.
pub struct IntValue {
  value: Value
}

///| Get a value from an `LLVMValueRef`.
///
/// **unsafe**: Undefined behavior if `value_ref` is not an `IntValue`.
pub fn IntValue::new(value_ref: LLVMValueRef) -> IntValue {
  assert_val_ref(value_ref)

  IntValue::{
    value: Value::new(value_ref)
  }
}

///| Returns the `LLVMValueRef` that this `IntValue` wraps.
pub fn IntValue::as_value_ref(self: IntValue) -> LLVMValueRef {
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
  let value_ref = llvm_const_not(self.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the negation of the constant `IntValue`.
pub fn IntValue::const_neg(self: IntValue) -> IntValue {
  let value_ref = llvm_const_neg(self.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the negation of the constant `IntValue` with NSW flag.
pub fn IntValue::const_nsw_neg(self: IntValue) -> IntValue {
  let value_ref = llvm_const_nsw_neg(self.as_value_ref())
  IntValue::new(value_ref)
}

// NOTE: use LLVMConstNull
// pub fn IntValue::const_nuw_neg(self: IntValue) -> IntValue {
//   let value_ref = llvm_const_nuw_neg(self.as_value_ref())
//   IntValue::new(value_ref)
// }

///| Returns the addition of two constant `IntValue`s.
pub fn IntValue::const_add(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_add(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the addition of two constant `IntValue`s with NSW flag.
pub fn IntValue::const_nsw_add(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_nsw_add(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the addition of two constant `IntValue`s with NUW flag.
pub fn IntValue::const_nuw_add(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_nuw_add(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the subtraction of two constant `IntValue`s.
pub fn IntValue::const_sub(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_sub(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the subtraction of two constant `IntValue`s with NSW flag.
pub fn IntValue::const_nsw_sub(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_nsw_sub(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the subtraction of two constant `IntValue`s with NUW flag.
pub fn IntValue::const_nuw_sub(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_nuw_sub(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the multiplication of two constant `IntValue`s.
pub fn IntValue::const_mul(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_mul(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the multiplication of two constant `IntValue`s with NSW flag.
pub fn IntValue::const_nsw_mul(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_nsw_mul(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

///| Returns the multiplication of two constant `IntValue`s with NUW flag.
pub fn IntValue::const_nuw_mul(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_nuw_mul(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

// pub fn IntValue::const_and(self: IntValue, rhs: IntValue) -> IntValue {
//   let value_ref = llvm_const_and(self.as_value_ref(), rhs.as_value_ref())
//   IntValue::new(value_ref)
// }
//
// pub fn IntValue::const_or(self: IntValue, rhs: IntValue) -> IntValue {
//   let value_ref = llvm_const_or(self.as_value_ref(), rhs.as_value_ref())
//   IntValue::new(value_ref)
// }

///| Returns the XOR of two constant `IntValue`s.
pub fn IntValue::const_xor(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_xor(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

// const_cast
// const_shl
// const_rshr
// const_ashr
// const_unsigned_to_float
// const_signed_to_float
pub fn IntValue::const_to_pointer(self: IntValue, ptr_type: PointerType) -> PointerValue {
  PointerValue::new(llvm_const_int_to_ptr(self.as_value_ref(), ptr_type.as_type_ref()))
}

pub fn IntValue::const_truncate(self: IntValue, int_type: IntType) -> IntValue {
  IntValue::new(llvm_const_trunc(self.as_value_ref(), int_type.as_type_ref()))
}
pub fn IntValue::const_truncate_or_bit_cast(self: IntValue, int_type: IntType) -> IntValue {
  IntValue::new(llvm_const_trunc_or_bit_cast(self.as_value_ref(), int_type.as_type_ref()))
}
pub fn IntValue::const_bit_cast(self: IntValue, int_tyep: IntType) -> IntValue {
  IntValue::new(llvm_const_bit_cast(self.as_value_ref(), int_tyep.as_type_ref()))
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
  llvm_isa_constant_int(self.as_value_ref()).is_null()
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

  let v = llvm_const_int_get_z_ext_value(self.as_value_ref())
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

  let v = llvm_const_int_get_s_ext_value(self.as_value_ref())
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

// ============================================
// FloatValue
// ============================================
///| A `FloatValue` is a value that represents a floating point number.
pub struct FloatValue {
  value: Value
}

///| Get a value from an `LLVMValueRef`.
///
/// **unsafe**: Undefined behavior if `value_ref` is not a `FloatValue`.
pub fn FloatValue::new(value_ref: LLVMValueRef) -> FloatValue {
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
//   IntValue::new(llvm_const_fcmp(op.into(). self.as_value_ref(), rhs.as_value_ref())
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

  let (v, lossy) = llvm_const_real_get_double(self.as_value_ref())

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

// ============================================
// PointerValue
// ============================================
///| A `PointerValue` is a value that represents a pointer.
pub struct PointerValue {
  value: Value
}

///| Get a value from an `LLVMValueRef`.
///
/// **unsafe**: Undefined behavior if `value_ref` is not a `PointerValue`.
pub fn PointerValue::new(value_ref: LLVMValueRef) -> PointerValue {
  assert_val_ref(value_ref)

  PointerValue::{
    value: Value::new(value_ref)
  }
}

///| Returns the `LLVMValueRef` that this `PointerValue` wraps.
pub fn PointerValue::as_value_ref(self: PointerValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

///| Gets the name of a `PointerValue`.
/// If the value is a constant, this will return an empty string.
pub fn PointerValue::get_name(self: PointerValue) -> String {
  self.value.get_name()
}

///| Set name of the `PointerValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i64_type = context.i64_type();
/// let i64_val = i64_type.const_int(42);
/// let ptr_type = i64_type.ptr_type(AddressSpace::default());
/// ptr_type.set_name("forty_two");
/// inspect!(ptr_type.get_name(), "forty_two");
/// ```
pub fn PointerValue::set_name(self: PointerValue, name: String) -> Unit {
  self.value.set_name(name)
}

///| Gets the type of a `PointerValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i64_type = context.i64_type();
/// let i64_val = i64_type.const_int(42);
/// let ptr_type = i64_type.ptr_type(AddressSpace::default());
/// inspect!(ptr_type.get_type(), "ptr");
/// ```
pub fn PointerValue::get_type(self: PointerValue) -> PointerType {
  PointerType::new(self.value.get_type().as_type_ref())
}

///| Returns whether or not the `PointerValue` is null.
pub fn PointerValue::is_null(self: PointerValue) -> Bool {
  self.value.is_null()
}

///| Returns whether or not the `PointerValue` is undefined.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i64_type = context.i64_type();
/// let ptr_type = i64_type.ptr_type(AddressSpace::default());
/// let undef = ptr_type.get_undef();
/// assert_true!(undef.is_undef());
/// ```
pub fn PointerValue::is_undef(self: PointerValue) -> Bool {
  self.value.is_undef()
}

///| Returns whether or not the `PointerValue` is a constant.
pub fn PointerValue::is_const(self: PointerValue) -> Bool {
  self.value.is_const()
}

///| Converts the `PointerValue` into an `InstructionValue` if it is an instruction.
pub fn PointerValue::as_instruction(self: PointerValue) -> InstructionValue? {
  self.value.as_instruction()
}

///| Creates a `PointerValue` that applies a `getelementptr` operation to the `PointerValue`.
pub fn PointerValue::const_gep(
  self: PointerValue, ty: &BasicType, ordered_indices: Array[IntValue]
) -> PointerValue {
  let indices = ordered_indices.map(fn (index) { index.as_value_ref() })
  let value_ref = llvm_const_gep2(ty.as_type_ref(), self.as_value_ref(), indices)
  PointerValue::new(value_ref)
}

///| Creates a `PointerValue` that applies a `getelementptr` operation to the `PointerValue`.
pub fn PointerValue::const_in_bounds_gep(
  self: PointerValue, ty: &BasicType, ordered_indices: Array[IntValue]
) -> PointerValue {
  let indices = ordered_indices.map(fn (index) { index.as_value_ref() })
  let value_ref = llvm_const_in_bounds_gep2(ty.as_type_ref(), self.as_value_ref(), indices)
  PointerValue::new(value_ref)
}

///| Converts the `PointerValue` into an `IntValue`.
pub fn PointerValue::const_to_int(self: PointerValue, int_type: IntType) -> IntValue {
  IntValue::new(llvm_const_ptr_to_int(self.as_value_ref(), int_type.as_type_ref()))
}

///| Casts the `PointerValue` to a new `PointerType` with different data type.
pub fn PointerValue::const_cast(self: PointerValue, ptr_type: PointerType) -> PointerValue {
  PointerValue::new(llvm_const_pointer_cast(self.as_value_ref(), ptr_type.as_type_ref()))
}

///| Casts the `PointerValue` to a new `PointerType` with different address space.
pub fn const_address_space_cast(self: PointerValue, ptr_type: PointerType) -> PointerValue {
  PointerValue::new(llvm_const_addr_space_cast(self.as_value_ref(), ptr_type.as_type_ref()))
}

///| Replaces all uses of a `PointerValue` with another `PointerValue`.
pub fn PointerValue::replace_all_uses_with(self: PointerValue, new_value: PointerValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

pub fn PointerValue::print_to_stderr(self: PointerValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn PointerValue::print_to_string(self: PointerValue) -> String {
  self.value.print_to_string()
}

pub fn PointerValue::to_string(self: PointerValue) -> String {
  self.value.to_string()
}

pub fn PointerValue::dump(self: PointerValue) -> Unit {
  self.value.dump()
}

pub impl Show for PointerValue with output(self: PointerValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for PointerValue with to_string(self: PointerValue) -> String {
  self.to_string()
}

// ============================================
// InstructionValue
// ============================================
///| An `InstructionValue` is a value that represents an instruction.
pub struct InstructionValue {
  value: Value
}

///| Get a value from an `LLVMValueRef`.
pub fn InstructionValue::new(value_ref: LLVMValueRef) -> InstructionValue {
  assert_val_ref(value_ref)

  InstructionValue::{
    value: Value::new(value_ref)
  }
}

///| Returns the `LLVMValueRef` that this `InstructionValue` wraps.
pub fn InstructionValue::as_value_ref(self: InstructionValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

///| Returns whether or not the `InstructionValue` is a load instruction.
pub fn InstructionValue::is_a_load_inst(self: InstructionValue) -> Bool {
  llvm_isa_load_inst(self.as_value_ref()).is_null()
}

///| Returns whether or not the `InstructionValue` is a store instruction.
pub fn InstructionValue::is_a_store_inst(self: InstructionValue) -> Bool {
  llvm_isa_store_inst(self.as_value_ref()).is_null()
}

///| Returns whether or not the `InstructionValue` is an alloca instruction.
pub fn InstructionValue::is_a_alloca_inst(self: InstructionValue) -> Bool {
  llvm_isa_alloca_inst(self.as_value_ref()).is_null()
}

///| Returns whether or not the `InstructionValue` is a getelementptr instruction.
pub fn InstructionValue::is_a_getelementptr_inst(self: InstructionValue) -> Bool {
  llvm_isa_get_element_ptr_inst(self.as_value_ref()).is_null()
}

///| Returns whether or not the `InstructionValue` is a call instruction.
pub fn InstructionValue::is_a_atomicrmw_inst(self: InstructionValue) -> Bool {
  llvm_isa_atomic_rmw_inst(self.as_value_ref()).is_null()
}

///| Returns whether or not the `InstructionValue` is a cmpxchg instruction.
pub fn InstructionValue::is_a_cmpxchg_inst(self: InstructionValue) -> Bool {
  llvm_isa_atomic_cmp_xchg_inst(self.as_value_ref()).is_null()
}

///| Creates a clone of this `InstructionValue`, and returns it.
/// The clone will have no parent, and no name.
pub fn InstructionValue::explicit_clone(self: InstructionValue) -> InstructionValue {
  InstructionValue::new(llvm_instruction_clone(self.as_value_ref()))
}

///| Gets the name of an `InstructionValue`.
pub fn InstructionValue::get_name(self: InstructionValue) -> String? {
  // self.value.get_name()
  if self.get_type().is_void_type() {
    None
  } else {
    Some(self.value.get_name())
  }
}

///| Set name of the `InstructionValue`.
pub fn InstructionValue::set_name(self: InstructionValue, name: String) -> Unit {
  self.value.set_name(name)
}

///| Get a instruction with it's name.
/// Compares against all instructions after self, and self.
pub fn InstructionValue::get_instruction_with_name(
  self: InstructionValue, name: String
) -> String? {
  match self.get_name() {
    Some(this_name) => if this_name == name {
      return Some(this_name)
    }
    None => ()
  }
  match self.get_next_instruction() {
    Some(next_inst) => next_inst.get_instruction_with_name(name)
    None => None
  }
}

///| Get type of the `InstructionValue`.
pub fn InstructionValue::get_type(self: InstructionValue) -> AnyTypeEnum {
  AnyTypeEnum::new(self.value.get_type().as_type_ref())
}

///| Get the opcode of the `InstructionValue`.
pub fn InstructionValue::get_opcode(self: InstructionValue) -> InstructionOpcode {
  let opcode = llvm_get_instruction_opcode(self.as_value_ref())

  opcode.into()
}

///| Get the previous instruction of the current instruction.
pub fn InstructionValue::get_previous_instruction(self: InstructionValue) -> InstructionValue? {
  let value_ref = llvm_get_previous_instruction(self.as_value_ref())
  
  if value_ref.is_null() {
    None
  } else {
    Some(InstructionValue::new(value_ref))
  }
}

///| Get the next instruction of the current instruction.
pub fn InstructionValue::get_next_instruction(self: InstructionValue) -> InstructionValue? {
  let value_ref = llvm_get_next_instruction(self.as_value_ref())
  
  if value_ref.is_null() {
    None
  } else {
    Some(InstructionValue::new(value_ref))
  }
}

// REVIEW: need review, possibly unsafe
// REVIEW: what's different with `remove_from_basic_block`?
///| Erase the instruction from the basic block.
pub fn InstructionValue::erase_from_basic_block(self: InstructionValue) -> Unit {
  llvm_instruction_erase_from_parent(self.as_value_ref())
}

///| Remove the instruction from the basic block.
pub fn InstructionValue::remove_from_basic_block(self: InstructionValue) -> Unit {
  llvm_instruction_remove_from_parent(self.as_value_ref())
}

///| Get the parent of the instruction.
// REVIEW: what happen if the parent been deleted?
pub fn InstructionValue::get_parent(self: InstructionValue) -> BasicBlock? {
  BasicBlock::new(llvm_get_instruction_parent(self.as_value_ref()))
}

///| Returns if the instruction is a terminator
pub fn InstructionValue::is_terminator(self: InstructionValue) -> Bool {
  llvm_isa_terminator_inst(self.as_value_ref()).is_null()
}

///| Returns if a **terminator** is conditional or not
pub fn InstructionValue::is_conditional(self: InstructionValue) -> Bool {
  if self.is_terminator() {
    llvm_is_conditional(self.as_value_ref())
  } else {
    false
  }
}

///| Returns if the instruction is tail call or not.
pub fn InstructionValue::is_tail_call(self: InstructionValue) -> Bool {
  if self.get_opcode() == InstructionOpcode::Call {
    llvm_is_tail_call(self.as_value_ref())
  } else {
    false
  }
}

///| Returns the tail call kind on call instructions.
///
/// Other instructions return `None`.
pub fn InstructionValue::get_tail_call_kind(self: InstructionValue) -> LLVMTailCallKind? {
  if self.get_opcode() == InstructionOpcode::Call {
    Some(llvm_get_tail_call_kind(self.as_value_ref()))
  } else {
    None
  }
}

///| Check whether this instructions supports `fast math flags`.
///
/// Reference: https://llvm.org/docs/LangRef.html#fast-math-flags
pub fn InstructionValue::can_use_fast_math_flags(self: InstructionValue) -> Bool {
  llvm_can_value_use_fast_math_flags(self.as_value_ref())
}

///| Get `fast math flags` of supported instructions.
///
/// Calling this on unsupported instructions is safe and returns `None`.
///
/// Reference: https://llvm.org/docs/LangRef.html#fast-math-flags
pub fn InstructionValue::get_fast_math_flags(self: InstructionValue) -> FastMathFlags? {
  if self.can_use_fast_math_flags() {
    Some(llvm_get_fast_math_flags(self.as_value_ref()).into())
  } else {
    None
  }
}

///| Set `fast math flags` of supported instructions.
///
/// Calling this on unsupported instructions is safe and returns `None`.
///
/// Reference: https://llvm.org/docs/LangRef.html#fast-math-flags
pub fn InstructionValue::set_fast_math_flags(self: InstructionValue, flags: FastMathFlags) -> Unit {
  if self.can_use_fast_math_flags() {
    llvm_set_fast_math_flags(self.as_value_ref(), flags.into())
  }
}


///| Get the non-negative flag on `zext` instructions.
///
/// Calling this function on other instructions is safe and results in a no-op.
pub fn InstructionValue::get_non_negative_flag(self: InstructionValue) -> Bool? {
  match self.get_opcode() {
    InstructionOpcode::ZExt => Some(llvm_get_n_neg(self.as_value_ref()))
    _ => None
  }
}

///| Set the non-negative flag on `zext` instructions.
///
/// Calling this function on other instructions is safe and results in a no-op.
pub fn InstructionValue::set_non_negative_flag(self: InstructionValue, flag: Bool) -> Unit {
  match self.get_opcode() {
    InstructionOpcode::ZExt => llvm_set_n_neg(self.as_value_ref(), flag)
    _ => ()
  }
}


/// Checks if an `or` instruction has the `disjoint` flag set.
///
/// Calling this function on other instructions is safe and returns `None`.
pub fn InstructionValue::get_disjoint_flag(self: InstructionValue) -> Bool? {
  if self.get_opcode() == InstructionOpcode::Or {
    Some(self.as_value_ref().get_is_disjoint())
  } else {
    None
  }
}

///| Set the `disjoint` flag on `or` instructions.
///
/// Calling this function on other instructions is safe and results in a no-op.
pub fn InstructionValue::set_disjoint_flag(self: InstructionValue, flag: Bool) -> Unit {
  if self.get_opcode() == InstructionOpcode::Or {
    self.as_value_ref().set_is_disjoint(flag)
  }
}

///| Replace all uses of an `InstructionValue` with another `InstructionValue`.
pub fn InstructionValue::replace_all_uses_with(self: InstructionValue, new_value: InstructionValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///| Returns whether or not a memory access instruction is volatile.
/// SubTypes: Only apply to memory access instructions
pub fn InstructionValue::get_volatile(self:InstructionValue)-> Result[Bool,String] {
  if not(self.is_a_load_inst()) &&
     not(self.is_a_store_inst()) &&
     not(self.is_a_atomicrmw_inst()) &&
     not(self.is_a_cmpxchg_inst()) {
    return Err("Value is not a load, store, atomicrmw or cmpxchg instruction")
  }

  Ok(llvm_get_volatile(self.as_value_ref()))
}

///| Sets whether or not a memory access instruction is volatile.
/// SubTypes: Only apply to memory access instructions
pub fn InstructionValue::set_volatile(self:InstructionValue, flag: Bool) -> Result[Unit,String] {
  if not(self.is_a_load_inst()) &&
     not(self.is_a_store_inst()) &&
     not(self.is_a_atomicrmw_inst()) &&
     not(self.is_a_cmpxchg_inst()) {
    return Err("Value is not a load, store, atomicrmw or cmpxchg instruction")
  }

  self.as_value_ref().set_volatile(flag)
  Ok(())
}

///| Returns the type that is allocated by the alloca instruction.
/// SubTypes: Only apply to alloca instruction
pub fn InstructionValue::get_allocated_type(self: InstructionValue) -> Result[BasicTypeEnum, String] {
  if not(self.is_a_alloca_inst()) {
    return Err("Value is not an alloca instruction")
  }

  Ok(BasicTypeEnum::new(llvm_get_allocated_type(self.as_value_ref())))
}

///| Returns the source element type of the given GEP.
/// SubTypes: Only apply to GetElementPtr instruction
pub fn InstructionValue::get_gep_source_element_type(self: InstructionValue) -> Result[BasicTypeEnum, String] {
  if not(self.is_a_getelementptr_inst()) {
    return Err("Value is not a getelementptr instruction")
  }
  Ok(BasicTypeEnum::new(llvm_get_gep_source_element_type(self.as_value_ref())))
}

///| Returns alignment on a memory access instruction or alloca.
/// SubTypes: Only apply to memory access and alloca instructions
pub fn InstructionValue::get_alignment(self: InstructionValue) -> Result[UInt, String] {
  if not(self.is_a_alloca_inst()) && not(self.is_a_load_inst()) && not(self.is_a_store_inst()) {
    return Err("Value is not a load, store or alloca instruction")
  }

  Ok(llvm_get_alignment(self.as_value_ref()))
}

///| Returns alignment on a memory access instruction or alloca.
/// SubTypes: Only apply to memory access and alloca instructions
pub fn InstructionValue::set_alignment(self: InstructionValue, alignment: UInt) -> Result[Unit, String] {

  if not(is_power_of_two(alignment)) && alignment != 0 {
    return Err("Alignment must be a power of two")
  }

  if not(self.is_a_alloca_inst()) && not(self.is_a_load_inst()) && not(self.is_a_store_inst()) {
    return Err("Value is not a load, store or alloca instruction")
  }

  llvm_set_alignment(self.as_value_ref(), alignment)
  Ok(())
}

///| Returns atomic ordering on a memory access instruction.
/// SubTypes: Only apply to memory access instructions
pub fn InstructionValue::get_atomic_ordering(self: InstructionValue) -> Result[AtomicOrdering, String] {
  if not(self.is_a_load_inst()) && not(self.is_a_store_inst()) {
    return Err("Value is not a load or store instruction")
  }

  Ok(llvm_get_ordering(self.as_value_ref()).into())
}

///| Sets atomic ordering on a memory access instruction.
/// SubTypes: Only apply to memory access instructions
pub fn InstructionValue::set_atomic_ordering(self: InstructionValue, ordering: AtomicOrdering) -> Result[Unit, String] {
  if not(self.is_a_load_inst()) && not(self.is_a_store_inst()) {
    return Err("Value is not a load or store instruction")
  }

  match ordering {
    AtomicOrdering::Release  => {
      if self.is_a_load_inst() {
        return Err("The release ordering is not valid on load instructions")
      }
    }
    AtomicOrdering::AcquireRelease => {
      return Err("The acq_rel ordering is not valid on load or store instructions")
    }
    AtomicOrdering::Acquire  => {
      if self.is_a_store_inst() {
        return Err("The acquire ordering is not valid on store instructions")
      }
    }
    _ => ()
  }

  llvm_set_ordering(self.as_value_ref(), ordering.into())

  Ok(())
}

///| Obtains the number of operands an `InstructionValue` has.
/// An operand is a `BasicValue` used in an IR instruction.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let f32_type = context.f32_type();
/// let f32_ptr_type = f32_type.ptr_type(AddressSpace::default());
/// let fn_type = void_type.fn_type(&[f32_ptr_type.into()], false);
///
/// let function = module.add_function("take_f32_ptr", fn_type, None);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// builder.position_at_end(basic_block);
///
/// let arg1 = function.get_first_param().unwrap().into_pointer_value();
/// let f32_val = f32_type.const_float(@math.PI);
/// let store_instruction = builder.build_store(arg1, f32_val).unwrap();
/// let free_instruction = builder.build_free(arg1).unwrap();
/// let return_instruction = builder.build_return().unwrap();
///
/// assert_eq!(store_instruction.get_num_operands(), 2);
/// assert_eq!(free_instruction.get_num_operands(), 2);
/// assert_eq!(return_instruction.get_num_operands(), 0);
/// ```
///
/// will generate LLVM IR roughly like (varying slightly across LLVM versions):
///
/// ```llvm
/// ; ModuleID = 'ivs'
/// source_filename = "ivs"
///
/// define void @take_f32_ptr(float* %0) {
/// entry:
///   store float 0x400921FB60000000, float* %0
///   %1 = bitcast float* %0 to i8*
///   tail call void @free(i8* %1)
///   ret void
/// }
///
/// declare void @free(i8*)
/// ```
///
/// which makes the number of instruction operands clear:
/// 1) Store has two: a const float and a variable float pointer %0
/// 2) Bitcast has one: a variable float pointer %0
/// 3) Function call has two: i8 pointer %1 argument, and the free function itself
/// 4) Void return has zero: void is not a value and does not count as an operand
/// even though the return instruction can take values.
pub fn InstructionValue::get_num_operands(self: InstructionValue) -> UInt {
  llvm_get_num_operands(self.as_value_ref()).reinterpret_as_uint()
}

/// Obtains the operand an `InstructionValue` has at a given index if any.
/// An operand is a `BasicValue` used in an IR instruction.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let f32_type = context.f32_type();
/// let f32_ptr_type = f32_type.ptr_type(AddressSpace::default());
/// let fn_type = void_type.fn_type([f32_ptr_type]);
///
/// let function = module.add_function("take_f32_ptr", fn_type, None);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// builder.position_at_end(basic_block);
///
/// let arg1 = function.get_first_param().unwrap().into_pointer_value();
/// let f32_val = f32_type.const_float(@math.PI);
/// let store_instruction = builder.build_store(arg1, f32_val).unwrap();
/// let free_instruction = builder.build_free(arg1).unwrap();
/// let return_instruction = builder.build_return(None).unwrap();
///
/// assert_true!(store_instruction.get_operand(0).is_some());
/// assert_true!(store_instruction.get_operand(1).is_some());
/// assert_true!(store_instruction.get_operand(2).is_none());
/// assert_true!(free_instruction.get_operand(0).is_some());
/// assert_true!(free_instruction.get_operand(1).is_some());
/// assert_true!(free_instruction.get_operand(2).is_none());
/// assert_true!(return_instruction.get_operand(0).is_none());
/// assert_true!(return_instruction.get_operand(1).is_none());
/// ```
///
/// will generate LLVM IR roughly like (varying slightly across LLVM versions):
///
/// ```ir
/// ; ModuleID = 'ivs'
/// source_filename = "ivs"
///
/// define void @take_f32_ptr(float* %0) {
/// entry:
///   store float 0x400921FB60000000, float* %0
///   %1 = bitcast float* %0 to i8*
///   tail call void @free(i8* %1)
///   ret void
/// }
///
/// declare void @free(i8*)
/// ```
///
/// which makes the instruction operands clear:
/// 1) Store has two: a const float and a variable float pointer %0
/// 2) Bitcast has one: a variable float pointer %0
/// 3) Function call has two: i8 pointer %1 argument, and the free function itself
/// 4) Void return has zero: void is not a value and does not count as an operand
/// even though the return instruction can take values.
pub fn InstructionValue::get_operand(self: InstructionValue, index: UInt) -> Either[BasicValueEnum, BasicBlock]? {
  let num_operands = self.get_num_operands()

  if index >= num_operands {
    return None
  }

  self.get_operand_unchecked(index)
}

fn InstructionValue::get_operand_unchecked(
  self: InstructionValue, index: UInt
) -> Either[BasicValueEnum, BasicBlock]? {
  let operand = llvm_get_operand(self.as_value_ref(), index)

  if operand.is_null() {
    return None
  }

  let is_basic_block = llvm_isa_basic_block(operand).is_null() |> not

  if is_basic_block {
    let bb_ref = llvm_value_as_basic_block(operand)
    let bb = match BasicBlock::new(bb_ref) {
      Some(bb) => bb
      None => abort("BasicBlock should always be valid")
    }
    Some(Right(bb))
  } else {
    let value = BasicValueEnum::new(operand)
    Some(Left(value))
  }
}

// TODO: should return array or iter?
// pub fn InstructionValue::get_operands()

///| Sets the operand an `InstructionValue` has at a given index if possible.
/// An operand is a `BasicValue` used in an IR instruction.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let f32_type = context.f32_type();
/// let f32_ptr_type = f32_type.ptr_type(AddressSpace::default());
/// let fn_type = void_type.fn_type([f32_ptr_type]);
///
/// let function = module.add_function("take_f32_ptr", fn_type, None);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// builder.position_at_end(basic_block);
///
/// let arg1 = function.get_first_param().unwrap().into_pointer_value();
/// let f32_val = f32_type.const_float(@math.PI);
/// let store_instruction = builder.build_store(arg1, f32_val).unwrap();
/// let free_instruction = builder.build_free(arg1).unwrap();
/// let return_instruction = builder.build_return(None).unwrap();
///
/// // This will produce invalid IR:
/// free_instruction.set_operand(0, f32_val);
///
/// assert_eq!(free_instruction.get_operand(0).unwrap().left().unwrap(), f32_val);
/// ```
// REVIEW: here use `bool` as return type, maybe we need to use `Result`?
pub fn InstructionValue::set_operand(self: InstructionValue, index: UInt, val: &BasicValue) -> Bool {
  let num_operands = self.get_num_operands()

  if index >= num_operands {
    return false
  }

  llvm_set_operand(self.as_value_ref(), index, val.as_value_ref())

  true
}

///| Gets the use of an operand(`BasicValue`), if any.
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let f32_type = context.f32_type();
/// let f32_ptr_type = f32_type.ptr_type(AddressSpace::default());
/// let fn_type = void_type.fn_type([f32_ptr_type], false);
///
/// let function = module.add_function("take_f32_ptr", fn_type, None);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// builder.position_at_end(basic_block);
///
/// let arg1 = function.get_first_param().unwrap().into_pointer_value();
/// let f32_val = f32_type.const_float(@math.PI);
/// let store_instruction = builder.build_store(arg1, f32_val).unwrap();
/// let free_instruction = builder.build_free(arg1).unwrap();
/// let return_instruction = builder.build_return(None).unwrap();
///
/// assert_eq!(store_instruction.get_operand_use(1), arg1.get_first_use());
/// ```
pub fn InstructionValue::get_oprand_use(self: InstructionValue, index: UInt) -> BasicValueUse? {
  let num_operands = self.get_num_operands()

  if index >= num_operands {
    return None
  }

  self.get_oprand_use_unchecked(index)
}

fn InstructionValue::get_oprand_use_unchecked(
  self: InstructionValue, index: UInt
) -> BasicValueUse? {
  let use_ = llvm_get_operand_use(self.as_value_ref(), index)

  if use_.is_null() {
    return None
  }

  Some(BasicValueUse::new(use_))
}

// TODO: should return array or iter?
// pub fn InstructionValue::get_oprand_uses(self: InstructionValue) -> 


///| Gets the first use of an `InstructionValue` if any.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let f32_type = context.f32_type();
/// let f32_ptr_type = f32_type.ptr_type(AddressSpace::default());
/// let fn_type = void_type.fn_type([f32_ptr_type]);
///
/// let function = module.add_function("take_f32_ptr", fn_type, None);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// builder.position_at_end(basic_block);
///
/// let arg1 = function.get_first_param().unwrap().into_pointer_value();
/// let f32_val = f32_type.const_float(@math.PI);
/// let store_instruction = builder.build_store(arg1, f32_val).unwrap();
/// let free_instruction = builder.build_free(arg1).unwrap();
/// let return_instruction = builder.build_return(None).unwrap();
///
/// assert!(arg1.get_first_use().is_some());
/// ```
pub fn InstructionValue::get_first_use(self: InstructionValue) -> BasicValueUse? {
  self.value.get_first_use()
}

///| Gets the predicate of an `ICmp` `InstructionValue`.
/// If the instruction is not an `ICmp`, this returns None.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let i32_type = context.i32_type();
/// let fn_type = i32_type.fn_type([i32_type, i32_type], false);
///
/// let function = module.add_function("less", fn_type, None);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// builder.position_at_end(basic_block);
///
/// let arg1 = function.get_first_param().unwrap().into_int_value();
/// let arg2 = function.get_nth_param(1).unwrap().into_int_value();
/// let slt = builder.build_int_compare(IntPredicate::SLT, arg1, arg2, "less_than").unwrap();
///
/// inspect!(slt.get_icmp_predicate().unwrap(), "SLT");
/// ```
pub fn InstructionValue::get_icmp_predicate(self: InstructionValue) -> IntPredicate? {
  if self.get_opcode() == InstructionOpcode::ICmp {
    Some(llvm_get_icmp_predicate(self.as_value_ref()).into())
  } else {
    None
  }
}

///| Gets the predicate of an `ICmp` `InstructionValue`.
/// If the instruction is not an `ICmp`, this returns None.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let bool_type = context.bool_type();
/// let f32_type = context.i32_type();
/// let fn_type = bool_type.fn_type([f32_type, f32_type]);
///
/// let function = module.add_function("less", fn_type, None);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// builder.position_at_end(basic_block);
///
/// let arg1 = function.get_first_param().unwrap().into_float_value();
/// let arg2 = function.get_nth_param(1).unwrap().into_float_value();
/// let olt_pred = FloatPredicate::OLT;
/// let fcmp = builder.build_float_compare(olt_pred, arg1, arg2, "less_than").unwrap();
///
/// inspect!(fcmp.get_fcmp_predicate().unwrap(), "OLT");
/// ```
pub fn InstructionValue::get_fcmp_predicate(self: InstructionValue) -> FloatPredicate? {
  if self.get_opcode() == InstructionOpcode::FCmp {
    Some(llvm_get_fcmp_predicate(self.as_value_ref()).into())
  } else {
    None
  }
}

///| Determines whether or not this `Instruction` has any associated metadata.
pub fn InstructionValue::has_metadata(self: InstructionValue) -> Bool {
  llvm_has_metadata(self.as_value_ref())
}

///| Gets the `MetadataValue` associated with this `Instruction` at a specific `kind_id`.
pub fn InstructionValue::get_metadata(self: InstructionValue, kind_id: UInt) -> MetadataValue? {
  let metadata = llvm_get_metadata(self.as_value_ref(), kind_id)

  if metadata.is_null() {
    None
  } else {
    Some(MetadataValue::new(metadata))
  }
}

// pub fn InstructionValue::set_metadata(self: InstructionValue, metadata: MetadataValue, kind_id: UInt) -> Result[Unit, String] {
//   if not(metadata.is_node()) {
//     return Err("Metadata is expected to be a node.")
//   }
//
//   llvm_set_metadata(self.as_value_ref(), kind_id, metadata.as_metadata_ref())
//   Ok(())
// }

///| Dumps the `InstructionValue` to stderr.
///
/// It's equivalent to `InstructionValue::dump`.
pub fn InstructionValue::print_to_stderr(self: InstructionValue) -> Unit {
  self.value.print_to_stderr()
}

///| Dumps the `InstructionValue` to a string.
///
/// It's equivalent to `InstructionValue::to_string`.
pub fn InstructionValue::print_to_string(self: InstructionValue) -> String {
  self.value.print_to_string()
}

///| Dumps the `InstructionValue` to a string.
///
/// It's equivalent to `InstructionValue::print_to_string`.
pub fn InstructionValue::to_string(self: InstructionValue) -> String {
  self.value.to_string()
}

///| Dumps the `InstructionValue` to stderr.
///
/// It's equivalent to `InstructionValue::print_to_stderr`.
pub fn InstructionValue::dump(self: InstructionValue) -> Unit {
  self.value.dump()
}

pub impl Show for InstructionValue with output(self: InstructionValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for InstructionValue with to_string(self: InstructionValue) -> String {
  self.to_string()
}

// ============================================
// StructValue
// ============================================
///| A `StructValue` is a value that represents a struct.
pub struct StructValue {
  value: Value
}

///| Get a value from an `LLVMValueRef`.
///
/// **unsafe**: Undefined behavior if `value_ref` is not a struct.
pub fn StructValue::new(value_ref: LLVMValueRef) -> StructValue {
  assert_val_ref(value_ref)

  StructValue::{
    value: Value::new(value_ref)
  }
}

///| Returns the `LLVMValueRef` that this `StructValue` wraps.
pub fn StructValue::as_value_ref(self: StructValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

///| Gets the value of a field belonging to this `StructValue`.
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i8_type = context.i8_type();
/// let i8_val = i8_type.const_all_ones();
/// let i32_val = i32_type.const_all_ones();
/// let struct_type = context.struct_type([i8_type, i32_type], false);
/// let struct_val = struct_type.const_named_struct([i8_val, i32_val]);
///
/// assert!(struct_val.get_field_at_index(0).is_some());
/// assert!(struct_val.get_field_at_index(1).is_some());
/// assert!(struct_val.get_field_at_index(3).is_none());
/// assert!(struct_val.get_field_at_index(0).unwrap().is_int_value());
/// ```
pub fn StructValue::get_field_at_index(self: StructValue, index: UInt) -> BasicValueEnum? {
  if index >= self.count_fields() {
    return None
  }

  Some(self.get_field_at_index_unchecked(index))
}


fn StructValue::get_field_at_index_unchecked(
  self: StructValue, index: UInt
) -> BasicValueEnum {
  let v = llvm_get_operand(self.as_value_ref(), index)

  BasicValueEnum::new(v)
}

// pub fn StructValue::get_fields

///| Sets the value of a field belonging to this `StructValue`.
pub fn StructValue::set_field_at_index(
  self: StructValue,
  index: UInt,
  val: &BasicValue
) ->Bool {
  if self.get_type()
         .get_field_type_at_index(index)
         .map(fn (t) {t == val.as_basic_value_enum().get_type()}) != Some(true) {
    return false
  }

  llvm_set_operand(self.as_value_ref(), index, val.as_value_ref())
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
/// let struct_type = context.struct_type([i8_type, i32_type], false);
/// let struct_val = struct_type.const_named_struct([i8_val, i32_val]);
///
/// assert_eq!(struct_val.count_fields(), 2);
/// assert_eq!(struct_val.count_fields(), struct_type.count_fields());
/// ```
pub fn StructValue::count_fields(self: StructValue) -> UInt {
  llvm_get_num_operands(self.as_value_ref()).reinterpret_as_uint()
}

///| Gets the name of a `StructValue`.
/// If the value is a constant, this will return an empty string.
pub fn get_name(self: StructValue) -> String {
  self.value.get_name()
}

///| Set name of the `StructValue`.
pub fn set_name(self: StructValue, name: String) -> Unit {
  self.value.set_name(name)
}

///| Get the type of the `StructValue`.
pub fn get_type(self: StructValue) -> StructType {
  StructType::new(self.value.get_type().as_type_ref())
}

///| Determines whether or not this `StructValue` is null.
pub fn is_null(self: StructValue) -> Bool {
  self.value.is_null()
}

///| Determines whether or not this `StructValue` is undefined.
pub fn is_undef(self: StructValue) -> Bool {
  self.value.is_undef()
}

// REVIEW: Does this alwyas return `None`?
///| Converts a struct value to an instruction value.
pub fn as_instruction(self: StructValue) -> InstructionValue? {
  self.value.as_instruction()
}

///| Replace all uses of an `StructValue` with another `StructValue`.
pub fn StructValue::replace_all_uses_with(self: StructValue, new_value: StructValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///| Determines whether or not this `StructValue` is constant.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i64_type = context.i64_type();
/// let i64_val = i64_type.const_int(23, false).as_basic_value_enum();
/// let struct_val = context.const_struct([i64_val, i64_val], false);
/// assert!(struct_val.is_const());
/// ```
pub fn StructValue::is_const(self: StructValue) -> Bool {
  self.value.is_const()
}

///| Dump the `StructValue` to stderr.
///
/// It's equivalent to `StructValue::dump`.
pub fn StructValue::print_to_stderr(self: StructValue) -> Unit {
  self.value.print_to_stderr()
}

///| Dump the `StructValue` to a string.
///
/// It's equivalent to `StructValue::print_to_string`.
pub fn StructValue::print_to_string(self: StructValue) -> String {
  self.value.print_to_string()
}

///| Dump the `StructValue` to a string.
///
/// It's equivalent to `StructValue::print_to_string`.
pub fn StructValue::to_string(self: StructValue) -> String {
  self.value.to_string()
}

///| Dump the `StructValue` to stderr
///
/// It's equivalent to `StructValue::print_to_stderr`.
pub fn StructValue::dump(self: StructValue) -> Unit {
  self.value.dump()
}

pub impl Show for StructValue with output(self: StructValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ============================================
// FunctionValue
// ============================================
///| A `FunctionValue` is a value that represents a function.
pub struct FunctionValue {
  value: Value
}

///| Creates a new `FunctionValue` from an `LLVMValueRef`.
pub fn FunctionValue::new(value_ref: LLVMValueRef) -> FunctionValue? {
  if value_ref.is_null() {
    return None
  }

  let fv = FunctionValue::{
    value: Value::new(value_ref)
  }
  Some(fv)
}

///| Returns the `LLVMValueRef` that this `FunctionValue` wraps.
pub fn FunctionValue::as_value_ref(self: FunctionValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

///| Get the linkage of the function.
pub fn FunctionValue::get_linkage(self: FunctionValue) -> Linkage {
  llvm_get_linkage(self.as_value_ref()).into()
}

///| Set the linkage of the function.
pub fn FunctionValue::set_linkage(self: FunctionValue, linkage: Linkage) -> Unit {
  llvm_set_linkage(self.as_value_ref(), linkage.into())
}

///| Determines whether or not this `FunctionValue` is null.
pub fn FunctionValue::is_null(self: FunctionValue) -> Bool {
  self.value.is_null()
}

///| Determines whether or not this `FunctionValue` is undefined.
pub fn FunctionValue::is_undef(self: FunctionValue) -> Bool {
  self.value.is_undef()
}

// pub fn FunctionValue::verify(self: FunctionValue, print: Bool) -> Bool {
//   let action = if print {
//       LLVMVerifierFailureAction::LLVMPrintMessageAction
//   } else {
//       LLVMVerifierFailureAction::LLVMReturnStatusAction
//   }
//
//   let code = llvm_verify_function(self.as_value_ref(), action)
//
//   code != 1
// }

///| Get the next function in the module.
pub fn FunctionValue::get_next_function(self: FunctionValue) -> FunctionValue? {
  FunctionValue::new(llvm_get_next_function(self.as_value_ref()))
}

///| Get the previous function in the module.
pub fn FunctionValue::get_previous_function(self: FunctionValue) -> FunctionValue? {
  FunctionValue::new(llvm_get_previous_function(self.as_value_ref()))
}

///| Get the first parameter of the function.
pub fn FunctionValue::get_first_param(self: FunctionValue) -> BasicValueEnum?{
  let param = llvm_get_first_param(self.as_value_ref())

  if param.is_null() {
    None
  } else {
    Some(BasicValueEnum::new(param))
  }
}

///| Get the last parameter of the function.
pub fn FunctionValue::get_last_param(self: FunctionValue) -> BasicValueEnum? {
  let param = llvm_get_last_param(self.as_value_ref())

  if param.is_null() {
    None
  } else {
    Some(BasicValueEnum::new(param))
  }
}

///| Get the first basic block of the function.
pub fn FunctionValue::get_first_basic_block(self: FunctionValue) -> BasicBlock? {
  let bb = llvm_get_first_basic_block(self.as_value_ref())

  BasicBlock::new(bb)
}

///| Get the last basic block of the function.
pub fn FunctionValue::get_last_basic_block(self: FunctionValue) -> BasicBlock? {
  let bb = llvm_get_last_basic_block(self.as_value_ref())

  BasicBlock::new(bb)
}

///| Get the n-th parameter of the function.
pub fn FunctionValue::get_nth_param(self: FunctionValue, nth: UInt) -> BasicValueEnum? {
  let cnt = self.count_params()

  if nth >= cnt {
    None
  } else {
    Some(BasicValueEnum::new(llvm_get_param(self.as_value_ref(), nth)))
  }
}

///| Returns the number of parameters this `FunctionValue` has.
pub fn FunctionValue::count_params(self: FunctionValue) -> UInt {
  llvm_count_params(self.as_value_ref())
}

///| Get basic blocks of the function.
pub fn FunctionValue::get_basic_blocks(self: FunctionValue) -> Array[BasicBlock] {
  let bb_refs : Array[LLVMBasicBlockRef] = llvm_get_basic_blocks(self.as_value_ref())
  bb_refs.map(fn (bb_ref) { BasicBlock::new(bb_ref).unwrap() })
}

///| Get parameters of the function.
pub fn FunctionValue::get_params(self: FunctionValue) -> Array[BasicValueEnum] {
  let param_refs : Array[LLVMValueRef] = llvm_get_params(self.as_value_ref())
  param_refs.map(fn (param_ref) { BasicValueEnum::new(param_ref) })
}

///| Get the name of the function.
pub fn FunctionValue::get_name(self: FunctionValue) -> String {
  self.value.get_name()
}

// pub fn FunctionValue::view_function_cfg(self: FunctionValue) -> Unit {
//   llvm_view_function_cfg(self.as_value_ref())
// }
//
// pub fn FunctionValue::view_function_cfg_only(self: FunctionValue) -> Unit {
//   llvm_view_function_cfg_only(self.as_value_ref())
// }

///| Free the function.
pub fn FunctionValue::delete(self: FunctionValue) -> Unit {
  llvm_delete_function(self.as_value_ref())
}

// NOTE: `inkwell` does not provide this function
// pub fn FunctionValue::set_name(self: FunctionValue, name: String) -> Unit {
//   self.value.set_name(name)
// }

///| Get the type of the function.
pub fn FunctionValue::get_type(self: FunctionValue) -> FunctionType {
  FunctionType::new(self.value.get_type().as_type_ref())
}

pub fn FunctionValue::has_personality_function(self: FunctionValue) -> Bool {
  llvm_has_personality_fn(self.as_value_ref())
}

pub fn FunctionValue::get_personality_function(self: FunctionValue) -> FunctionValue? {
  if not(self.has_personality_function()) {
    return None
  }

  FunctionValue::new(llvm_get_personality_fn(self.as_value_ref()))
}

pub fn FunctionValue::set_personality_function(self: FunctionValue, personality_fn: FunctionValue) -> Unit {
  llvm_set_personality_fn(self.as_value_ref(), personality_fn.as_value_ref())
}

pub fn FunctionValue::get_intrinsic_id(self: FunctionValue) -> UInt {
  llvm_get_intrinsic_id(self.as_value_ref())
}

// REVIEW: Possibly we need to use `CallConv` enum, rather than `UInt`
pub fn FunctionValue::get_call_convention(self: FunctionValue) -> UInt {
  llvm_get_function_call_conv(self.as_value_ref())
}

// REVIEW: Possibly we need to use `CallConv` enum, rather than `UInt`
pub fn FunctionValue::set_call_convention(self: FunctionValue, call_conv: UInt) -> Unit {
  llvm_set_function_call_conv(self.as_value_ref(), call_conv)
}

pub fn FunctionValue::get_gc(self: FunctionValue) -> String {
  llvm_get_gc(self.as_value_ref())
}

///| Replace all uses of a `FunctionValue` with another `FunctionValue`.
pub fn FunctionValue::replace_all_uses_with(
  self: FunctionValue, new_value: FunctionValue
) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///| Adds an `Attribute` to a particular location in this `FunctionValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let fn_value = module.add_function("my_fn", fn_type, None);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
/// let enum_attribute = context.create_enum_attribute(1, 1);
///
/// fn_value.add_attribute(AttributeLoc::Return, string_attribute);
/// fn_value.add_attribute(AttributeLoc::Return, enum_attribute);
/// ```
pub fn FunctionValue::add_attribute(
  self: FunctionValue, loc: AttributeLoc, attribute: Attribute
) -> Unit {
  llvm_add_attribute_at_index(self.as_value_ref(), loc.get_index(), attribute.attribute)
}

///| Counts the number of `Attribute`s belonging to the specified location in this `FunctionValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let fn_value = module.add_function("my_fn", fn_type, None);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
/// let enum_attribute = context.create_enum_attribute(1, 1);
///
/// fn_value.add_attribute(AttributeLoc::Return, string_attribute);
/// fn_value.add_attribute(AttributeLoc::Return, enum_attribute);
///
/// assert_eq!(fn_value.count_attributes(AttributeLoc::Return), 2);
/// ```
pub fn FunctionValue::count_attributes(self: FunctionValue, loc: AttributeLoc) -> UInt {
  llvm_get_attribute_count_at_index(self.as_value_ref(), loc.get_index())
}

///| Get all `Attribute`s belonging to the specified location in this `FunctionValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let fn_value = module.add_function("my_fn", fn_type, None);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
/// let enum_attribute = context.create_enum_attribute(1, 1);
///
/// fn_value.add_attribute(AttributeLoc::Return, string_attribute);
/// fn_value.add_attribute(AttributeLoc::Return, enum_attribute);
///
/// assert_eq!(fn_value.attributes(AttributeLoc::Return), [string_attribute, enum_attribute]);
/// ```
pub fn FunctionValue::attributes(
  self: FunctionValue, loc: AttributeLoc
) -> Array[Attribute] {
  let attr_refs = llvm_get_attributes_at_index(self.as_value_ref(), loc.get_index())

  attr_refs.map(fn (attr_ref) { Attribute::new(attr_ref) })
}


///| Removes a string `Attribute` belonging to the specified location in this `FunctionValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let fn_value = module.add_function("my_fn", fn_type, None);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
///
/// fn_value.add_attribute(AttributeLoc::Return, string_attribute);
/// fn_value.remove_string_attribute(AttributeLoc::Return, "my_key");
/// ```
pub fn FunctionValue::remove_string_attribute(
  self: FunctionValue, loc: AttributeLoc, key: String
) -> Unit {
  llvm_remove_string_attribute_at_index(self.as_value_ref(), loc.get_index(), key)
}

///| Removes an enum `Attribute` belonging to the specified location in this `FunctionValue`.
///
/// # Example (Not Tested)
///
/// ```no_run
/// let context = Context::create();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let fn_value = module.add_function("my_fn", fn_type, None);
/// let enum_attribute = context.create_enum_attribute(1, 1);
///
/// fn_value.add_attribute(AttributeLoc::Return, enum_attribute);
/// fn_value.remove_enum_attribute(AttributeLoc::Return, 1);
/// ```
pub fn FunctionValue::remove_enum_attribute(
  self: FunctionValue, loc: AttributeLoc, kind_id: UInt
) -> Unit {
  llvm_remove_enum_attribute_at_index(self.as_value_ref(), loc.get_index(), kind_id)
}

///| Gets an enum `Attribute` belonging to the specified location in this `FunctionValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let fn_value = module.add_function("my_fn", fn_type, None);
/// let enum_attribute = context.create_enum_attribute(1, 1);
///
/// fn_value.add_attribute(AttributeLoc::Return, enum_attribute);
///
/// assert_eq!(fn_value.get_enum_attribute(AttributeLoc::Return, 1), Some(enum_attribute));
/// ```
pub fn FunctionValue::get_enum_attribute(self: FunctionValue, loc: AttributeLoc, kind_id: UInt) -> Attribute? {
  let attr_ref = llvm_get_enum_attribute_at_index(self.as_value_ref(), loc.get_index(), kind_id)

  if attr_ref.is_null() {
    None
  } else {
    Some(Attribute::new(attr_ref))
  }
}

///| Gets a string `Attribute` belonging to the specified location in this `FunctionValue`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let fn_value = module.add_function("my_fn", fn_type, None);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
///
/// fn_value.add_attribute(AttributeLoc::Return, string_attribute);
///
/// assert_eq!(fn_value.get_string_attribute(AttributeLoc::Return, "my_key"), Some(string_attribute));
/// ```
pub fn FunctionValue::get_string_attribute(self: FunctionValue, loc: AttributeLoc, key: String) -> Attribute? {
  let attr_ref = llvm_get_string_attribute_at_index(self.as_value_ref(), loc.get_index(), key)

  if attr_ref.is_null() {
    None
  } else {
    Some(Attribute::new(attr_ref))
  }
}

///| Sets the alignment of a parameter at a given index.
pub fn FunctionValue::set_param_alignment(
  self: FunctionValue, param_index: UInt, alignment: UInt
) -> Unit {
  match self.get_nth_param(param_index) {
    Some(param) => {
      llvm_set_param_alignment(param.as_value_ref(), alignment)
    }
    _ => ()
  }
}

///| Gets the `GlobalValue` version of this `FunctionValue`.
/// This allows you to further inspect its global properties or even
/// convert it to a `PointerValue`.
pub fn FunctionValue::as_global_value(self: FunctionValue) -> GlobalValue {
  GlobalValue::new(self.as_value_ref())
}

// pub fn FunctionValue::set_subprogram(self: FunctionValue, subprogram: DISubprogram) -> Unit {
//   llvm_set_subprogram(self.as_value_ref(), subprogram.as_metadata_ref())
// }

// pub fn FunctionValue::get_subprogram(self: FunctionValue) -> DISubprogram? {
//   let subprogram = llvm_get_subprogram(self.as_value_ref())
//
//   if subprogram.is_null() {
//     None
//   } else {
//     Some(DISubprogram::new(subprogram))
//   }
// }

// Get the section to which this function belongs
// pub fn FunctionValue::get_section(self: FunctionValue) -> String {
//   self.value.get_section()
// }
//
// Set the section to which this function should belong
// pub fn FunctionValue::set_section(self: FunctionValue, section: String) -> Unit {
//   self.value.set_section(section)
// }

///| Dumps the `FunctionValue` to stderr.
///
/// It's equivalent to `FunctionValue::dump`.
pub fn FunctionValue::print_to_stderr(self: FunctionValue) -> Unit {
  self.value.print_to_stderr()
}

///| Dumps the `FunctionValue` to a string.
///
/// It's equivalent to `FunctionValue::print_to_string`.
pub fn FunctionValue::print_to_string(self: FunctionValue) -> String {
  self.value.print_to_string()
}

///| Dumps the `FunctionValue` to a string.
///
/// It's equivalent to `FunctionValue::print_to_string`.
pub fn FunctionValue::to_string(self: FunctionValue) -> String {
  self.value.to_string()
}

///| Dumps the `FunctionValue` to stderr.
///
/// It's equivalent to `FunctionValue::print_to_stderr`.
pub fn FunctionValue::dump(self: FunctionValue) -> Unit {
  self.value.dump()
}

pub impl Show for FunctionValue with output(self: FunctionValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for FunctionValue with to_string(self: FunctionValue) -> String {
  self.to_string()
}

// ============================================
// ArrayValue
// ============================================
///| An `ArrayValue` is a value that represents an array.
pub struct ArrayValue {
  value: Value
}

///| Creates a new `ArrayValue` from an `LLVMValueRef`.
pub fn ArrayValue::new(value_ref: LLVMValueRef) -> ArrayValue {
  assert_val_ref(value_ref)

  ArrayValue::{
    value: Value::new(value_ref)
  }
}

///| Returns the `LLVMValueRef` that this `ArrayValue` wraps.
pub fn ArrayValue::as_value_ref(self: ArrayValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

///| Creates a new constant `ArrayValue` with the given type and values.
pub fn ArrayValue::new_const_array[T: AsTypeRef, V: AsValueRef](
  ty: T, values: Array[V]
) -> ArrayValue {
  let value_refs = values.map(fn (v) { v.as_value_ref() })
  let value_ref = llvm_const_array(ty.as_type_ref(), value_refs)
  ArrayValue::new(value_ref)
}

///| Get the name of the `ArrayValue`.
pub fn ArrayValue::get_name(self: ArrayValue) -> String {
  self.value.get_name()
}

///| Set name of the `ArrayValue`.
pub fn ArrayValue::set_name(self: ArrayValue, name: String) -> Unit {
  self.value.set_name(name)
}

///| Get the type of the `ArrayValue`.
pub fn ArrayValue::get_type(self: ArrayValue) -> ArrayType {
  ArrayType::new(self.value.get_type().as_type_ref())
}

///| Determines whether or not this `ArrayValue` is null.
pub fn ArrayValue::is_null(self: ArrayValue) -> Bool {
  self.value.is_null()
}

///| Determines whether or not this `ArrayValue` is undefined.
pub fn ArrayValue::is_undef(self: ArrayValue) -> Bool {
  self.value.is_undef()
}

///| Attempt to convert this `ArrayValue` to an `InstructionValue`, if possible.
pub fn ArrayValue::as_instruction(self: ArrayValue) -> InstructionValue? {
  self.value.as_instruction()
}

///| Replaces all uses of this value with another value of the same type.
/// If used incorrectly this may result in invalid IR.
pub fn ArrayValue::replace_all_uses_with(self: ArrayValue, new_value: ArrayValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///| Determines whether or not an `ArrayValue` is a constant.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let i64_type = context.i64_type();
/// let i64_val = i64_type.const_int(23, false);
/// let array_val = i64_type.const_array([i64_val]);
/// assert_true!(array_val.is_const());
/// ```
pub fn ArrayValue::is_const(self: ArrayValue) -> Bool {
  self.value.is_const()
}

///| Determines whether or not an `ArrayValue` represents a constant array of `i8`s.
///
/// # Example (Not Tested)
///
/// ```moonbit
/// use inkwell::context::Context;
///
/// let context = Context::create();
/// let string = context.const_string(b"my_string", false);
///
/// assert!(string.is_const_string());
/// ```
pub fn ArrayValue::is_const_string(self: ArrayValue) -> Bool {
  // llvm_is_constant_string(self.as_value_ref())
  self.as_value_ref().is_constant_string()
}

///| Obtain the string from the ArrayValue
/// if the value points to a constant string.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let string = context.const_string(b"hello!", true);
///
/// assert_eq!(string.get_string_constant(), Some(result));
/// ```
pub fn ArrayValue::get_string_constant(self: ArrayValue) -> String? {
  let s = llvm_get_as_string(self.as_value_ref())
  if s.is_empty() {
    None
  } else {
    Some(s)
  }
}

///| Dumps the `ArrayValue` to stderr.
///
/// It's equivalent to `ArrayValue::dump`.
pub fn ArrayValue::print_to_stderr(self: ArrayValue) -> Unit {
  self.value.print_to_stderr()
}

///| Dumps the `ArrayValue` to a string.
///
/// It's equivalent to `ArrayValue::print_to_string`.
pub fn ArrayValue::print_to_string(self: ArrayValue) -> String {
  self.value.print_to_string()
}

///| Dumps the `ArrayValue` to a string.
///
/// It's equivalent to `ArrayValue::print_to_string`.
pub fn ArrayValue::to_string(self: ArrayValue) -> String {
  self.value.to_string()
}

///| Dumps the `ArrayValue` to stderr.
///
/// It's equivalent to `ArrayValue::print_to_stderr`.
pub fn ArrayValue::dump(self: ArrayValue) -> Unit {
  self.value.dump()
}

pub impl Show for ArrayValue with output(self: ArrayValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for ArrayValue with to_string(self: ArrayValue) -> String {
  self.to_string()
}
// ============================================
// VectorValue
// ============================================
///| A `VectorValue` is a value that represents a vector.
pub struct VectorValue {
  value: Value
}

///| Creates a new `VectorValue` from an `LLVMValueRef`.
pub fn VectorValue::new(value_ref: LLVMValueRef) -> VectorValue {
  assert_val_ref(value_ref)

  VectorValue::{
    value: Value::new(value_ref)
  }
}

///| Returns the `LLVMValueRef` that this `VectorValue` wraps.
pub fn VectorValue::as_value_ref(self: VectorValue) -> LLVMValueRef {
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
  llvm_isa_constant_vector(self.as_value_ref()).is_null()
}

pub fn VectorValue::is_constant_data_vector(self: VectorValue) -> Bool {
  llvm_isa_constant_data_vector(self.as_value_ref()).is_null()
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
  VectorValue::new(llvm_const_shuffle_vector(self.as_value_ref(), right.as_value_ref(), mask.as_value_ref()))
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

// ============================================
// PhiValue
// ============================================
pub struct PhiValue {
  value: Value
}

pub fn PhiValue::new(value_ref: LLVMValueRef) -> PhiValue {
  assert_val_ref(value_ref)

  PhiValue::{
    value: Value::new(value_ref)
  }
}

pub fn PhiValue::as_value_ref(self: PhiValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

// TODO: need check, in inkwell, BasicValueEnum is not implemented for PhiValue
// pub impl BasicValue for PhiValue with as_basic_value_enum(self: PhiValue) -> BasicValueEnum {
//   BasicValueEnum::PhiValue(self)
// }

pub fn PhiValue::add_incoming(self: PhiValue, incoming: Array[(&BasicValue, BasicBlock)]) -> Unit {
  let values = incoming.iter().map(fn (pair) {pair.0.as_value_ref()}).collect()
  let bbs = incoming.iter().map(fn (pair) {pair.1.as_bb_ref()}).collect()
  let cnt = incoming.length()

  llvm_add_incoming(self.as_value_ref(), values, bbs, cnt.reinterpret_as_uint())
}

pub fn PhiValue::count_incoming(self: PhiValue) -> UInt {
  llvm_count_incoming(self.as_value_ref())
}

pub fn PhiValue::get_name(self: PhiValue) -> String {
  self.value.get_name()
}

pub fn PhiValue::set_name(self: PhiValue, name: String) -> Unit {
  self.value.set_name(name)
}

pub fn PhiValue::is_null(self: PhiValue) -> Bool {
  self.value.is_null()
}

pub fn PhiValue::is_undef(self: PhiValue) -> Bool {
  self.value.is_undef()
}

pub fn PhiValue::print_to_stderr(self: PhiValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn PhiValue::print_to_string(self: PhiValue) -> String {
  self.value.print_to_string()
}

pub fn PhiValue::to_string(self: PhiValue) -> String {
  self.value.to_string()
}

pub fn PhiValue::dump(self: PhiValue) -> Unit {
  self.value.dump()
}

pub impl Show for PhiValue with output(self: PhiValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for PhiValue with to_string(self: PhiValue) -> String {
  self.to_string()
}

// ============================================
// ScalableVectorValue
// ============================================
pub struct ScalableVectorValue {
  value: Value
}

pub fn ScalableVectorValue::new(value_ref: LLVMValueRef) -> ScalableVectorValue {
  assert_val_ref(value_ref)

  ScalableVectorValue::{
    value: Value::new(value_ref)
  }
}

pub fn ScalableVectorValue::as_value_ref(self: ScalableVectorValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub fn ScalableVectorValue::is_const(self: ScalableVectorValue) -> Bool {
  self.value.is_const()
}

pub fn ScalableVectorValue::get_name(self: ScalableVectorValue) -> String {
  self.value.get_name()
}

pub fn ScalableVectorValue::set_name(self: ScalableVectorValue, name: String) -> Unit {
  self.value.set_name(name)
}

pub fn ScalableVectorValue::get_type(self: ScalableVectorValue) -> ScalableVectorType {
  ScalableVectorType::new(self.value.get_type().as_type_ref())
}

pub fn ScalableVectorValue::is_null(self: ScalableVectorValue) -> Bool {
  self.value.is_null()
}

pub fn ScalableVectorValue::is_undef(self: ScalableVectorValue) -> Bool {
  self.value.is_undef()
}

pub fn ScalableVectorValue::as_instruction(self: ScalableVectorValue) -> InstructionValue? {
  self.value.as_instruction()
}

pub fn  ScalableVectorValue::const_extract_element(
  self: ScalableVectorValue, index: IntValue
) -> BasicValueEnum {
  BasicValueEnum::new(llvm_const_extract_element(self.as_value_ref(), index.as_value_ref()))
}

pub fn ScalableVectorValue::const_insert_element(self: ScalableVectorValue, element: &BasicValue, index: IntValue) -> BasicValueEnum {
  BasicValueEnum::new(llvm_const_insert_element(self.as_value_ref(), element.as_value_ref(), index.as_value_ref()))
}

pub fn ScalableVectorValue::replace_all_uses_with(self: ScalableVectorValue, new_value: ScalableVectorValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

pub fn ScalableVectorValue::const_shuffle_vector(self: ScalableVectorValue, right: ScalableVectorValue, mask: ScalableVectorValue) -> ScalableVectorValue {
  ScalableVectorValue::new(llvm_const_shuffle_vector(self.as_value_ref(), right.as_value_ref(), mask.as_value_ref()))
}

pub fn ScalableVectorValue::print_to_stderr(self: ScalableVectorValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn ScalableVectorValue::print_to_string(self: ScalableVectorValue) -> String {
  self.value.print_to_string()
}

pub fn ScalableVectorValue::to_string(self: ScalableVectorValue) -> String {
  self.value.to_string()
}

pub fn ScalableVectorValue::dump(self: ScalableVectorValue) -> Unit {
  self.value.dump()
}

pub impl Show for ScalableVectorValue with output(self: ScalableVectorValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for ScalableVectorValue with to_string(self: ScalableVectorValue) -> String {
  self.to_string()
}

// ============================================
// GlobalValue
// ============================================
pub struct GlobalValue {
  value: Value
}

pub fn GlobalValue::new(value_ref: LLVMValueRef) -> GlobalValue {
  assert_val_ref(value_ref)

  GlobalValue::{
    value: Value::new(value_ref)
  }
}

pub fn GlobalValue::get_name(self: GlobalValue) -> String {
  self.value.get_name()
}

pub fn GlobalValue::set_name(self: GlobalValue, name: String) -> Unit {
  self.value.set_name(name)
}

pub fn GlobalValue::get_previous_global(self: GlobalValue) -> GlobalValue? {
  let value_ref = llvm_get_previous_global(self.as_value_ref())
  
  if value_ref.is_null() {
    None
  } else {
    Some(GlobalValue::new(value_ref))
  }
}

pub fn GlobalValue::get_next_global(self: GlobalValue) -> GlobalValue? {
  let value_ref = llvm_get_next_global(self.as_value_ref())
  
  if value_ref.is_null() {
    None
  } else {
    Some(GlobalValue::new(value_ref))
  }
}

pub fn GlobalValue::get_dll_storge_class(self: GlobalValue) -> DLLStorageClass {
  llvm_get_dll_storage_class(self.as_value_ref()).into()
}

// TODO: enable it when `llvm_set_dll_storage_class` is available
// pub fn GlobalValue::set_dll_storage_class(self: GlobalValue, storage_class: DLLStorageClass) -> Unit {
//   llvm_set_dll_storage_class(self.as_value_ref(), storage_class)
// }

pub fn GlobalValue::get_initializer(self: GlobalValue) -> Option[BasicValueEnum] {
  let value_ref = llvm_get_initializer(self.as_value_ref())

  if value_ref.is_null() {
    None
  } else {
    Some(BasicValueEnum::new(value_ref))
  }
}

pub fn GlobalValue::set_initializer(self: GlobalValue, value: BasicValueEnum) -> Unit {
  llvm_set_initializer(self.as_value_ref(), value.as_value_ref())
}

pub fn GlobalValue::is_thread_local(self: GlobalValue) -> Bool {
  llvm_is_thread_local(self.as_value_ref())
}

pub fn GlobalValue::set_thread_local(self: GlobalValue, is_thread_local: Bool) -> Unit {
  llvm_set_thread_local(self.as_value_ref(), is_thread_local)
}

// pub fn GlobalValue::get_thread_local_mode(self: GlobalValue) -> ThreadLocalMode;
// pub fn GlobalValue::set_thread_local_mode(self: GlobalValue) -> ThreadLocalMode;

pub fn GlobalValue::is_declaration(self: GlobalValue) -> Bool {
  llvm_is_declaration(self.as_value_ref())
}

pub fn GlobalValue::has_unnamed_addr(self: GlobalValue) -> Bool {
  llvm_get_unnamed_address(self.as_value_ref()) == LLVMUnnamedAddr::LLVMGlobalUnnamedAddr
}

// REVIEW: Would use `UnnamedAddr` instead of `LLVMUnnamedAddr` be better?
pub fn GlobalValue::set_unnamed_addr(self: GlobalValue, has_unnamed_addr: Bool) -> Unit {
  // llvm_set_unnamed_addr(self.as_value_ref(), has_unnamed_addr)
  if has_unnamed_addr {
    llvm_set_unnamed_address(self.as_value_ref(), LLVMUnnamedAddr::LLVMGlobalUnnamedAddr)
  } else {
    llvm_set_unnamed_address(self.as_value_ref(), LLVMUnnamedAddr::LLVMNoUnnamedAddr)
  }
}

pub fn GlobalValue::is_constant(self: GlobalValue) -> Bool {
  llvm_is_global_constant(self.as_value_ref())
}

pub fn GlobalValue::set_constant(self: GlobalValue, is_constant: Bool) -> Unit {
  llvm_set_global_constant(self.as_value_ref(), is_constant)
}

pub fn GlobalValue::is_externally_initialized(self: GlobalValue) -> Bool {
  llvm_is_externally_initialized(self.as_value_ref())
}

pub fn GlobalValue::set_externally_initialized(self: GlobalValue, is_externally_initialized: Bool) -> Unit {
  llvm_set_externally_initialized(self.as_value_ref(), is_externally_initialized)
}

pub fn GlobalValue::set_visibility(self: GlobalValue, visibility: GlobalVisibility) -> Unit {
  llvm_set_visibility(self.as_value_ref(), visibility.into())
}

pub fn GlobalVisibility::get_visibility(self: GlobalValue) -> GlobalVisibility {
  llvm_get_visibility(self.as_value_ref()).into()
}

pub fn GlobalValue::get_section(self: GlobalValue) -> String {
  llvm_get_section(self.as_value_ref())
}

pub fn GlobalValue::set_section(self: GlobalValue, section: String) -> Unit {
  llvm_set_section(self.as_value_ref(), section)
}

pub fn GlobalValue::delete(self: GlobalValue) -> Unit {
  llvm_delete_global(self.as_value_ref())
}

pub fn GlobalValue::as_pointer_value(self: GlobalValue) -> PointerValue {
  PointerValue::new(self.as_value_ref())
}

pub fn GlobalValue::get_alignment(self: GlobalValue) -> UInt {
  llvm_get_alignment(self.as_value_ref())
}

pub fn GlobalValue::set_alignment(self: GlobalValue, alignment: UInt) -> Unit {
  llvm_set_alignment(self.as_value_ref(), alignment)
}

pub fn GlobalValue::set_metadata(
  self: GlobalValue, metadata: MetadataValue, kind_id: UInt
) -> Unit {
  llvm_global_set_metadata(self.as_value_ref(), kind_id, metadata.as_metadata_ref())
}

// TODO: enable it when `llvm_get_metadata` is available
// pub fn GlobalValue::get_comdat(self: GlobalValue) -> Comdat? {
//   let comdat_ref = llvm_get_comdat(self.as_value_ref())
//
//   if comdat_ref.is_null() {
//     None
//   } else {
//     Some(Comdat::new(comdat_ref))
//   }
// }

pub fn GlobalValue::set_unnamed_address(
  self: GlobalValue, unnamed_address: UnnamedAddress
) -> Unit {
  llvm_set_unnamed_address(self.as_value_ref(), unnamed_address.into())
}

// pub fn GlobalValue::get_linkage(self: GlobalValue) -> Linkage {
//   llvm_get_linkage(self.as_value_ref()).into()
// }
//
// pub fn GlobalValue::set_linkage(self: GlobalValue, linkage: Linkage) -> Unit {
//   llvm_set_linkage(self.as_value_ref(), linkage.into())
// }

pub fn GlobalValue::get_value_type(self: GlobalValue) -> AnyTypeEnum {
  let ty = llvm_global_get_value_type(self.as_value_ref())
  AnyTypeEnum::new(ty)
}

pub fn GlobalValue::print_to_stderr(self: GlobalValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn GlobalValue::print_to_string(self: GlobalValue) -> String {
  self.value.print_to_string()
}

pub fn GlobalValue::to_string(self: GlobalValue) -> String {
  self.value.to_string()
}

pub fn GlobalValue::dump(self: GlobalValue) -> Unit {
  self.value.dump()
}

pub impl Show for GlobalValue with output(self: GlobalValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for GlobalValue with to_string(self: GlobalValue) -> String {
  self.to_string()
}

// ============================================
// MetadataValue
// ============================================
pub struct MetadataValue {
  value: Value
}

pub fn MetadataValue::new(value_ref: LLVMValueRef) -> MetadataValue {
  assert_val_ref(value_ref)
  assert_val_ref(llvm_isa_md_node(value_ref))
  assert_val_ref(llvm_isa_md_string(value_ref))

  MetadataValue::{
    value: Value::new(value_ref)
  }
}

pub fn MetadataValue::as_value_ref(self: MetadataValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub fn MetadataValue::as_metadata_ref(self: MetadataValue) -> LLVMMetadataRef {
  llvm_value_as_metadata(self.as_value_ref())
}

pub fn MetadataValue::get_name(self: MetadataValue) -> String {
  self.value.get_name()
}

// Need more

pub fn MetadataValue::replace_all_uses_with(self: MetadataValue, new_value: MetadataValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

pub fn MetadataValue::print_to_stderr(self: MetadataValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn MetadataValue::print_to_string(self: MetadataValue) -> String {
  self.value.print_to_string()
}

pub fn MetadataValue::to_string(self: MetadataValue) -> String {
  self.value.to_string()
}

pub fn MetadataValue::dump(self: MetadataValue) -> Unit {
  self.value.dump()
}

pub impl Show for MetadataValue with output(self: MetadataValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for MetadataValue with to_string(self: MetadataValue) -> String {
  self.to_string()
}

// ============================================
// CallSiteValue
// ============================================
pub struct CallSiteValue {
  value: Value
}

pub fn CallSiteValue::new(value_ref: LLVMValueRef) -> CallSiteValue {
  assert_val_ref(value_ref)

  CallSiteValue::{
    value: Value::new(value_ref)
  }
}

pub fn CallSiteValue::as_value_ref(self: CallSiteValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub fn CallSiteValue::set_tail_call(self: CallSiteValue, tail_call: Bool) -> Unit {
  self.as_value_ref().set_tail_call(tail_call)
}

pub fn CallSiteValue::is_tail_call(self: CallSiteValue) -> Bool {
  self.as_value_ref().is_tail_call()
}


pub fn CallSiteValue::get_tail_call_kind(self: CallSiteValue) -> LLVMTailCallKind {
  self.as_value_ref().get_tail_call_kind()
}

pub fn CallSiteValue::set_tail_call_kind(self: CallSiteValue, kind: LLVMTailCallKind) -> Unit {
  self.as_value_ref().set_tail_call_kind(kind)
}

///| Try to convert this `CallSiteValue` to a `BasicValueEnum` if not a void return type.
pub fn CallSiteValue::try_as_basic_value(
  self: CallSiteValue
) -> Either[BasicValueEnum, InstructionValue] {
  let kind = llvm_get_type_kind(llvm_type_of(self.as_value_ref()))

  match kind {
    LLVMTypeKind::LLVMVoidTypeKind => Right(InstructionValue::new(self.as_value_ref()))
    _ => Left(BasicValueEnum::new(self.as_value_ref()))
  }
}

pub fn CallSiteValue::add_attribute(
  self: CallSiteValue, loc: AttributeLoc, attribute: Attribute
) -> Unit {
  llvm_add_call_site_attribute(self.as_value_ref(), loc.get_index(), attribute.attribute)
}

pub fn CallSiteValue::get_called_fn_value(self: CallSiteValue) -> FunctionValue {
  FunctionValue::new(llvm_get_called_value(self.as_value_ref())).unwrap()
}

pub fn CallSiteValue::count_attributes(self: CallSiteValue, loc: AttributeLoc) -> UInt {
  llvm_get_call_site_attribute_count(self.as_value_ref(), loc.get_index())
}

// REVIEW: Possibly need to check attr_refs is null or not
pub fn CallSiteValue::attributes(self: CallSiteValue, loc: AttributeLoc) -> Array[Attribute] {
  let attr_refs = llvm_get_call_site_attributes(self.as_value_ref(), loc.get_index())
  attr_refs.map(fn (r) {Attribute::new(r)})
}

// REVIEW: Possibly need to check attr_ref is null or not
pub fn CallSiteValue::get_enum_attribute(
  self: CallSiteValue, loc: AttributeLoc, kind_id: UInt
) -> Attribute? {
  let attr_ref = llvm_get_call_site_enum_attribute(self.as_value_ref(), loc.get_index(), kind_id)
  Some(Attribute::new(attr_ref))
}

// REVIEW: Possibly need to check attr_ref is null or not
pub fn CallSiteValue::get_string_attribute(
  self: CallSiteValue, loc: AttributeLoc, key: String
) -> Attribute? {
  let attr_ref = llvm_get_call_site_string_attribute(self.as_value_ref(), loc.get_index(), key)
  Some(Attribute::new(attr_ref))
}

pub fn CallSiteValue::remove_attribute(
  self: CallSiteValue, loc: AttributeLoc, kind_id: UInt
) ->  Unit {
  llvm_remove_call_site_enum_attribute(self.as_value_ref(), loc.get_index(), kind_id)
}

pub fn CallSiteValue::remove_string_attribute(
  self: CallSiteValue, loc: AttributeLoc, key: String
) -> Unit {
  llvm_remove_call_site_string_attribute(self.as_value_ref(), loc.get_index(), key)
}

pub fn CallSiteValue::count_arguments(self: CallSiteValue) -> UInt {
  llvm_get_num_arg_operands(self.as_value_ref())
}

pub fn CallSiteValue::get_call_convention(
  self: CallSiteValue
) -> UInt {
  llvm_get_instruction_call_conv(self.as_value_ref())
}

pub fn CallSiteValue::set_call_convention(
  self: CallSiteValue, call_conv: UInt
) -> Unit {
  llvm_set_instruction_call_conv(self.as_value_ref(), call_conv)
}

pub fn CallSiteValue::set_alignment_attribute(
  self: CallSiteValue, loc: AttributeLoc, alignment: UInt
) -> Unit {
  // assert alignment.count_ones()

  llvm_set_instr_param_alignment(self.as_value_ref(), loc.get_index(), alignment)
}

// pub fn CallSiteValue::get_operand_bundles(self: CallSiteValue) -> Array[OperandBundle] {
//   let bundle_refs = llvm_get_instruction_operand_bundles(self.as_value_ref())
//   bundle_refs.map(fn (r) {OperandBundle::new(r)})
// }


pub fn CallSiteValue::print_to_stderr(self: CallSiteValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn CallSiteValue::print_to_string(self: CallSiteValue) -> String {
  self.value.print_to_string()
}

pub fn CallSiteValue::to_string(self: CallSiteValue) -> String {
  self.value.to_string()
}

pub fn CallSiteValue::dump(self: CallSiteValue) -> Unit {
  self.value.dump()
}

pub impl Show for CallSiteValue with output(
  self: CallSiteValue, logger: &Logger
) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for CallSiteValue with to_string(self: CallSiteValue) -> String {
  self.to_string()
}

// ============================================
// CallableValue
// ============================================
// pub struct CallableValue {
//   either_value: Either[FunctionValue, PointerValue]
// }
//
// pub impl AsValueRef for CallableValue with as_value_ref(self: CallableValue) -> LLVMValueRef {
//   match self.either_value {
//     Left(f) => f.as_value_ref()
//     Right(p) => p.as_value_ref()
//   }
// }
