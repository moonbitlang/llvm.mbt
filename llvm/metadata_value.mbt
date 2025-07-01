// ============================================
// MetadataValue
// ============================================

///| A `MetadataValue` is a value that represents a metadata node.
pub struct MetadataValue {
  value : ValueRef
}

///| Creates a new `MetadataValue` from an `@unsafe.LLVMValueRef`.
pub fn MetadataValue::new(value_ref : @unsafe.LLVMValueRef) -> MetadataValue {
  guard value_ref.is_not_null()
  guard @unsafe.llvm_isa_md_node(value_ref).is_not_null()
  guard @unsafe.llvm_isa_md_string(value_ref).is_not_null()
  MetadataValue::{ value: ValueRef::new(value_ref) }
}

///| Returns the `ValueRef` that this `MetadataValue` wraps.
pub fn MetadataValue::as_value(self : MetadataValue) -> ValueRef {
  self.value
}

///| Returns the `@unsafe.LLVMValueRef` that this `MetadataValue` wraps.
pub fn MetadataValue::as_value_ref(
  self : MetadataValue
) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

///| Returns the `@unsafe.LLVMMetadataRef` that this `MetadataValue` wraps.
pub fn MetadataValue::as_metadata_ref(
  self : MetadataValue
) -> @unsafe.LLVMMetadataRef {
  @unsafe.llvm_value_as_metadata(self.as_value_ref())
}

///| Get the name of the `MetadataValue`.
pub fn MetadataValue::get_name(self : MetadataValue) -> String {
  self.value.get_name()
}

// Need more

///|
pub fn MetadataValue::is_node(self : MetadataValue) -> Bool {
  @unsafe.llvm_isa_md_node(self.as_value_ref()) == self.as_value_ref()
}

///|
pub fn MetadataValue::is_string(self : MetadataValue) -> Bool {
  @unsafe.llvm_isa_md_string(self.as_value_ref()) == self.as_value_ref()
}

///|
pub fn MetadataValue::get_string_value(self : MetadataValue) -> String? {
  if self.is_node() {
    None
  } else {
    Some(@unsafe.llvm_get_md_string(self.as_value_ref()))
  }
}

///|
pub fn MetadataValue::get_node_size(self : MetadataValue) -> UInt {
  if self.is_string() {
    0
  } else {
    @unsafe.llvm_get_md_node_num_operands(self.as_value_ref())
  }
}

// pub fn MetadataValue::get_node_values(
//   self: MetadataValue
// ) -> Array[BasicMetadataValueEnum] {
//   if self.is_string() {
//     return Array::new()
//   }
//
//   let operands = @unsafe.llvm_get_md_node_operands(self.as_value_ref())
//   operands.map(fn (op) {BasicMetadataValueEnum::new(op)})
// }

///| Replaces all uses of this value with another value of the same type.
pub fn MetadataValue::replace_all_uses_with(
  self : MetadataValue,
  new_value : MetadataValue
) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///| Dumps the `MetadataValue` to stderr.
///
/// It's equivalent to `MetadataValue::dump`.
pub fn MetadataValue::print_to_stderr(self : MetadataValue) -> Unit {
  self.value.print_to_stderr()
}

///| Dumps the `MetadataValue` to a string.
///
/// It's equivalent to `MetadataValue::to_string`.
pub fn MetadataValue::print_to_string(self : MetadataValue) -> String {
  self.value.print_to_string()
}

///| Dumps the `MetadataValue` to a string.
///
/// It's equivalent to `MetadataValue::print_to_string`.
pub fn MetadataValue::to_string(self : MetadataValue) -> String {
  self.value.to_string()
}

///| Dumps the `MetadataValue` to stderr.
///
/// It's equivalent to `MetadataValue::print_to_stderr`.
pub fn MetadataValue::dump(self : MetadataValue) -> Unit {
  self.value.dump()
}

///|
pub impl Show for MetadataValue with output(
  self : MetadataValue,
  logger : &Logger
) -> Unit {
  logger.write_string(self.to_string())
}

///|
pub impl Show for MetadataValue with to_string(self : MetadataValue) -> String {
  self.to_string()
}
