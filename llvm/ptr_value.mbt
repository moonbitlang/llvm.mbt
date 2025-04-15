// ============================================
// PointerValue
// ============================================
///| A `PointerValue` is a value that represents a pointer.
pub struct PointerValue {
  value: Value
}

///| Get a value from an `@unsafe.LLVMValueRef`.
///
/// **unsafe**: Undefined behavior if `value_ref` is not a `PointerValue`.
pub fn PointerValue::new(value_ref: @unsafe.LLVMValueRef) -> PointerValue {
  guard value_ref.is_not_null()

  PointerValue::{
    value: Value::new(value_ref)
  }
}

///| Returns the `Value` that this `PointerValue` wraps.
pub fn PointerValue::as_value(self: PointerValue) -> Value {
  self.value
}

///| Returns the `@unsafe.LLVMValueRef` that this `PointerValue` wraps.
pub fn PointerValue::as_value_ref(self: PointerValue) -> @unsafe.LLVMValueRef {
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
  let value_ref = @unsafe.llvm_const_gep2(ty.as_type_ref(), self.as_value_ref(), indices)
  PointerValue::new(value_ref)
}

///| Creates a `PointerValue` that applies a `getelementptr` operation to the `PointerValue`.
pub fn PointerValue::const_in_bounds_gep(
  self: PointerValue, ty: &BasicType, ordered_indices: Array[IntValue]
) -> PointerValue {
  let indices = ordered_indices.map(fn (index) { index.as_value_ref() })
  let value_ref = @unsafe.llvm_const_in_bounds_gep2(ty.as_type_ref(), self.as_value_ref(), indices)
  PointerValue::new(value_ref)
}

///| Converts the `PointerValue` into an `IntValue`.
pub fn PointerValue::const_to_int(self: PointerValue, int_type: IntType) -> IntValue {
  IntValue::new(@unsafe.llvm_const_ptr_to_int(self.as_value_ref(), int_type.as_type_ref()))
}

///| Casts the `PointerValue` to a new `PointerType` with different data type.
pub fn PointerValue::const_cast(self: PointerValue, ptr_type: PointerType) -> PointerValue {
  PointerValue::new(@unsafe.llvm_const_pointer_cast(self.as_value_ref(), ptr_type.as_type_ref()))
}

///| Casts the `PointerValue` to a new `PointerType` with different address space.
pub fn const_address_space_cast(self: PointerValue, ptr_type: PointerType) -> PointerValue {
  PointerValue::new(@unsafe.llvm_const_addr_space_cast(self.as_value_ref(), ptr_type.as_type_ref()))
}

///| Replaces all uses of a `PointerValue` with another `PointerValue`.
pub fn PointerValue::replace_all_uses_with(self: PointerValue, new_value: PointerValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///| Dumps the `PointerValue` to stderr.
///
/// It's equivalent to `PointerValue::dump`.
pub fn PointerValue::print_to_stderr(self: PointerValue) -> Unit {
  self.value.print_to_stderr()
}

///| Dumps the `PointerValue` to a string.
///
/// It's equivalent to `PointerValue::to_string`.
pub fn PointerValue::print_to_string(self: PointerValue) -> String {
  self.value.print_to_string()
}

///| Dumps the `PointerValue` to stderr.
///
/// It's equivalent to `PointerValue::print_to_string`.
pub fn PointerValue::to_string(self: PointerValue) -> String {
  self.value.to_string()
}

///| Dumps the `PointerValue` to stderr.
///
/// It's equivalent to `PointerValue::print_to_stderr`.
pub fn PointerValue::dump(self: PointerValue) -> Unit {
  self.value.dump()
}

pub impl Show for PointerValue with output(self: PointerValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for PointerValue with to_string(self: PointerValue) -> String {
  self.to_string()
}


