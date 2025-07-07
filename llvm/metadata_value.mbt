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

///|
pub impl Value for MetadataValue with base(self) {
  self.value
}

///|
pub impl Value for MetadataValue with as_value_enum(self) {
  MetadataValue(self)
}

///| Returns the `@unsafe.LLVMMetadataRef` that this `MetadataValue` wraps.
pub fn MetadataValue::as_metadata_ref(
  self : MetadataValue
) -> @unsafe.LLVMMetadataRef {
  @unsafe.llvm_value_as_metadata(self.inner())
}

///| Get the name of the `MetadataValue`.
pub fn MetadataValue::get_name(self : MetadataValue) -> String {
  self.value.get_name()
}

// Need more

///|
pub fn MetadataValue::is_node(self : MetadataValue) -> Bool {
  @unsafe.llvm_isa_md_node(self.inner()) == self.inner()
}

///|
pub fn MetadataValue::is_string(self : MetadataValue) -> Bool {
  @unsafe.llvm_isa_md_string(self.inner()) == self.inner()
}

///|
pub fn MetadataValue::get_string_value(self : MetadataValue) -> String? {
  if self.is_node() {
    None
  } else {
    Some(@unsafe.llvm_get_md_string(self.inner()))
  }
}

///|
pub fn MetadataValue::get_node_size(self : MetadataValue) -> UInt {
  if self.is_string() {
    0
  } else {
    @unsafe.llvm_get_md_node_num_operands(self.inner())
  }
}

// pub fn MetadataValue::get_node_values(
//   self: MetadataValue
// ) -> Array[BasicMetadataValueEnum] {
//   if self.is_string() {
//     return Array::new()
//   }
//
//   let operands = @unsafe.llvm_get_md_node_operands(self.inner())
//   operands.map(fn (op) {BasicMetadataValueEnum::new(op)})
// }

///| Replaces all uses of this value with another value of the same type.
pub fn MetadataValue::replace_all_uses_with(
  self : MetadataValue,
  new_value : MetadataValue
) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///|
pub impl Show for MetadataValue with output(
  self : MetadataValue,
  logger : &Logger
) -> Unit {
  logger.write_string(self.value.to_string())
}
