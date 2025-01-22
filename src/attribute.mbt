
pub struct Attribute {
  attr_ref: LLVMAttributeRef
}

pub fn Attribute::new(attr_ref: LLVMAttributeRef) -> Attribute {
  // assert is_null

  Attribute::{
    attr_ref: attr_ref
  }
}

pub fn Attribute::as_attr_ref(self: Attribute) -> LLVMAttributeRef {
  self.attr_ref
}

// pub fn Attribute::is_string(self: Attribute) -> bool {
//   llvm_is_string_attribute(self.attr_ref) == 1
// }

// pub fn Attribute::is_type(self: Attribute) -> bool {
//   llvm_is_type_attribute(self.attr_ref) == 1
// }

// pub fn Attribute::get_last_enum_kind_id(self: Attribute) -> UInt {
//   llvm_get_last_enum_attribute_kind_id(self.attr_ref)
// }

// pub fn Attribute::get_enum_value(self: Attribute) -> UInt {
//   llvm_get_enum_attribute_value(self.attr_ref)
// }
