pub struct Attribute {
  attribute: LLVMAttributeRef
}

pub fn Attribute::new(attribute: LLVMAttributeRef) -> Attribute {
  // TODO: need to check if attribute is null
  Attribute::{
    attribute: attribute
  }
}

pub fn Attribute::as_attr_ref(self: Attribute) -> LLVMAttributeRef {
  self.attribute
}

pub fn Attribute::is_enum(self: Attribute) -> Bool {
  self.as_attr_ref().is_enum_attribute()
}

pub fn Attribute::is_string(self: Attribute) -> Bool {
  self.as_attr_ref().is_string_attribute()
}

pub fn Attribute::is_type(self: Attribute) -> Bool {
  self.as_attr_ref().is_type_attribute()
}

pub fn Attribute::get_named_enum_kind_id(name: String) -> UInt {
  llvm_get_enum_attribute_kind_for_name(name)
}

pub fn Attribute::get_enum_kind_id(self: Attribute) -> UInt {
  // assert!(self.get_enum_kind_id_is_valid());
  if not(self.get_enum_kind_id_is_valid()) {
    abort("Invalid enum kind id");
  }

  llvm_get_enum_attribute_kind(self.as_attr_ref())
}

pub fn Attribute::get_enum_kind_id_is_valid(self: Attribute) -> Bool {
  self.is_enum() || self.is_type()
}

pub fn Attribute::get_last_enum_kind_id() -> UInt {
  llvm_get_last_enum_attribute_kind()
}

pub fn Attribute::get_enum_value(self: Attribute) -> UInt64 {
  // FIXME: need to check if it is right
  if not(self.is_enum()) {
    abort("Attribute is not an enum");
  }

  llvm_get_enum_attribute_value(self.as_attr_ref())
}

pub fn Attribute::get_string_kind_id(self: Attribute) -> String {
  if not(self.is_string()) {
    abort("Attribute is not a string");
  }

  llvm_get_string_attribute_kind(self.as_attr_ref())
}

pub fn Attribute::get_string_value(self: Attribute) -> String {
  if not(self.is_string()) {
    abort("Attribute is not a string");
  }

  llvm_get_string_attribute_value(self.as_attr_ref())
}

pub fn Attribute::get_type_value(self: Attribute) -> AnyTypeEnum {
  if not(self.is_type()) {
    abort("Attribute is not a type");
  }

  AnyTypeEnum::new(llvm_get_type_attribute_value(self.as_attr_ref()))
}

pub enum AttributeLoc {
  Return
  Param(UInt)
  Function
}

pub fn AttributeLoc::get_index(self: AttributeLoc) -> UInt {
  match self {
    Return => 0
    Param(i) => {
      if i <= @uint.max_value - 2 {
        i + 1
      } else {
        abort("Parameter index must be less than 2^64 - 2")
      }
    }
    AttributeLoc::Function => @uint.max_value
  }
}

// pub fn op_equal(self: Attribute, other: Attribute) -> Bool {
//   if self.is_enum() && other.is_enum () {
//     return self.get_enum_kind_id() == other.get_enum_kind_id() &&
//            self.get_enum_value() == other.get_enum_value();
//   }
//
//   if self.is_string() && other.is_string() {
//     return self.get_string_kind_id() == other.get_string_kind_id() &&
//            self.get_string_value() == other.get_string_value();
//   }
//   
//   // TODO: need to implement op_equal for AnyTypeEnum
//   if self.is_type() && other.is_type() {
//     return self.get_enum_kind_id() == other.get_enum_kind_id() &&
//         self.get_type_value() == other.get_type_value();
//   }
//
//   // TODO: need to implement op_equal for attributeref
//   self.attribute == other.attribute
// }

// TODO: Dummy function, eliminate it when all done.
pub fn AttributeLoc::new(i: Int) -> AttributeLoc {
  match i {
    0 => Return
    1 => Param(0)
    2 => Param(1)
    3 => Function
    _ => abort("Invalid attribute location")
  }
}
