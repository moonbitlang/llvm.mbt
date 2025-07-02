// ============================================
// PointerValue
// ============================================

///| A `PointerValue` is a value that represents a pointer.
pub struct PointerValue {
  value : ValueRef
}

///| Get a value from an `@unsafe.LLVMValueRef`.
///
/// **unsafe**: Undefined behavior if `value_ref` is not a `PointerValue`.
pub fn PointerValue::new(value_ref : @unsafe.LLVMValueRef) -> PointerValue {
  guard value_ref.is_not_null()
  PointerValue::{ value: ValueRef::new(value_ref) }
}

pub impl Value for PointerValue with base(self) {
  self.value
}

pub impl Value for PointerValue with as_value_enum(self) {
  PointerValue(self)
}

pub impl BasicValue for PointerValue with as_basic_value_enum(self) {
  PointerValue(self)
}


///| Gets the name of a `PointerValue`.
/// If the value is a constant, this will return an empty string.
pub fn PointerValue::get_name(self : PointerValue) -> String {
  self.value.get_name()
}

///| Set name of the `PointerValue`.
pub fn PointerValue::set_name(self : PointerValue, name : String) -> Unit {
  self.value.set_name(name)
}

///| Gets the type of a `PointerValue`.
pub fn PointerValue::get_type(self : PointerValue) -> PointerType {
  PointerType::new(self.value.get_type().inner())
}

///| Returns whether or not the `PointerValue` is null.
pub fn PointerValue::is_null(self : PointerValue) -> Bool {
  self.value.is_null()
}

///| Returns whether or not the `PointerValue` is undefined.
pub fn PointerValue::is_undef(self : PointerValue) -> Bool {
  self.value.is_undef()
}

///| Returns whether or not the `PointerValue` is a constant.
pub fn PointerValue::is_const(self : PointerValue) -> Bool {
  self.value.is_const()
}

///| Converts the `PointerValue` into an `InstructionValue` if it is an instruction.
pub fn PointerValue::as_instruction(self : PointerValue) -> InstructionValue? {
  self.value.as_instruction()
}

///| Creates a `PointerValue` that applies a `getelementptr` operation to the `PointerValue`.
pub fn PointerValue::const_gep(
  self : PointerValue,
  ty : &BasicType,
  ordered_indices : Array[IntValue]
) -> PointerValue {
  let indices = ordered_indices.map(fn(index) { index.inner() })
  let value_ref = @unsafe.llvm_const_gep2(
    ty.inner(),
    self.inner(),
    indices,
  )
  PointerValue::new(value_ref)
}

///| Creates a `PointerValue` that applies a `getelementptr` operation to the `PointerValue`.
pub fn PointerValue::const_in_bounds_gep(
  self : PointerValue,
  ty : &BasicType,
  ordered_indices : Array[IntValue]
) -> PointerValue {
  let indices = ordered_indices.map(fn(index) { index.inner() })
  let value_ref = @unsafe.llvm_const_in_bounds_gep2(
    ty.inner(),
    self.inner(),
    indices,
  )
  PointerValue::new(value_ref)
}

///| Converts the `PointerValue` into an `IntValue`.
pub fn PointerValue::const_to_int(
  self : PointerValue,
  int_type : IntType
) -> IntValue {
  IntValue::new(
    @unsafe.llvm_const_ptr_to_int(self.inner(), int_type.inner()),
  )
}

///| Casts the `PointerValue` to a new `PointerType` with different data type.
pub fn PointerValue::const_cast(
  self : PointerValue,
  ptr_type : PointerType
) -> PointerValue {
  PointerValue::new(
    @unsafe.llvm_const_pointer_cast(self.inner(), ptr_type.inner()),
  )
}

///| Casts the `PointerValue` to a new `PointerType` with different address space.
pub fn const_address_space_cast(
  self : PointerValue,
  ptr_type : PointerType
) -> PointerValue {
  PointerValue::new(
    @unsafe.llvm_const_addr_space_cast(
      self.inner(),
      ptr_type.inner(),
    ),
  )
}

///| Replaces all uses of a `PointerValue` with another `PointerValue`.
pub fn PointerValue::replace_all_uses_with(
  self : PointerValue,
  new_value : PointerValue
) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///|
pub impl Show for PointerValue with output(
  self : PointerValue,
  logger : &Logger
) -> Unit {
  logger.write_string(self.value.to_string())
}
