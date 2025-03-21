
///| Functions, function parameters, and return types can have `Attribute`s to indicate
/// how they should be treated by optimizations and code generation.
pub struct Attribute {
  attribute: @unsafe.LLVMAttributeRef
}

pub fn Attribute::new(attribute: @unsafe.LLVMAttributeRef) -> Attribute {
  // TODO: need to check if attribute is null
  Attribute::{
    attribute: attribute
  }
}

pub fn Attribute::as_attr_ref(self: Attribute) -> @unsafe.LLVMAttributeRef {
  self.attribute
}

///| Determines whether or not an `Attribute` is an enum.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let enum_attribute = context.create_enum_attribute(0, 10);
///
/// assert_true!(enum_attribute.is_enum());
/// ```
pub fn Attribute::is_enum(self: Attribute) -> Bool {
  self.as_attr_ref().is_enum_attribute()
}

///| Determines whether or not an `Attribute` is a string.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let string_attribute = context.create_string_attribute("my_key_123", "my_val");
///
/// assert_true!(string_attribute.is_string());
/// ```
pub fn Attribute::is_string(self: Attribute) -> Bool {
  self.as_attr_ref().is_string_attribute()
}

///| Determines whether or not an `Attribute` is a type attribute. 
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let kind_id = Attribute::get_named_enum_kind_id("sret");
/// let type_attribute = context.create_type_attribute(
///     kind_id,
///     context.i32_type().into(),
/// );
///
/// assert_true!(type_attribute.is_type());
/// ```
pub fn Attribute::is_type(self: Attribute) -> Bool {
  self.as_attr_ref().is_type_attribute()
}

///| Gets the enum kind id associated with a builtin name.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// // This kind id doesn't exist:
/// assert_eq!(Attribute::get_named_enum_kind_id("foobar"), 0);
///
/// // These are real kind ids:
/// assert_eq!(Attribute::get_named_enum_kind_id("align"), 1);
/// assert_eq!(Attribute::get_named_enum_kind_id("builtin"), 5);
/// ```
pub fn Attribute::get_named_enum_kind_id(name: String) -> UInt {
  @unsafe.llvm_get_enum_attribute_kind_for_name(name)
}

///| Gets the kind id associated with an enum `Attribute`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let enum_attribute = context.create_enum_attribute(0, 10);
///
/// assert_eq!(enum_attribute.get_enum_kind_id(), 0);
/// ```
///
/// This function also works for type `Attribute`s.
///
/// ```moonbit
/// let context = Context::create();
/// let kind_id = Attribute::get_named_enum_kind_id("sret");
/// let any_type = context.i32_type().as_any_type_enum();
/// let type_attribute = context.create_type_attribute(
///     kind_id,
///     any_type,
/// );
///
/// assert_eq!(type_attribute.get_enum_kind_id(), kind_id);
/// ```
pub fn Attribute::get_enum_kind_id(self: Attribute) -> UInt {
  // assert_true!(self.get_enum_kind_id_is_valid());
  if not(self.get_enum_kind_id_is_valid()) {
    abort("Invalid enum kind id");
  }

  @unsafe.llvm_get_enum_attribute_kind(self.as_attr_ref())
}

pub fn Attribute::get_enum_kind_id_is_valid(self: Attribute) -> Bool {
  self.is_enum() || self.is_type()
}

///| Gets the last enum kind id associated with builtin names.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// assert_eq!(Attribute::get_last_enum_kind_id(), 56);
/// ```
pub fn Attribute::get_last_enum_kind_id() -> UInt {
  @unsafe.llvm_get_last_enum_attribute_kind()
}

///| Gets the value associated with an enum `Attribute`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let enum_attribute = context.create_enum_attribute(0, 10);
///
/// assert_eq!(enum_attribute.get_enum_value(), 10);
/// ```
pub fn Attribute::get_enum_value(self: Attribute) -> UInt64 {
  // FIXME: need to check if it is right
  if not(self.is_enum()) {
    abort("Attribute is not an enum");
  }

  @unsafe.llvm_get_enum_attribute_value(self.as_attr_ref())
}

///| Gets the string kind id associated with a string attribute.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
///
/// assert_eq!(string_attribute.get_string_kind_id().to_str(), Ok("my_key"));
/// ```
pub fn Attribute::get_string_kind_id(self: Attribute) -> String {
  if not(self.is_string()) {
    abort("Attribute is not a string");
  }

  @unsafe.llvm_get_string_attribute_kind(self.as_attr_ref())
}

///| Gets the string value associated with a string attribute.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
///
/// assert_eq!(string_attribute.get_string_value(), "my_val");
/// ```
pub fn Attribute::get_string_value(self: Attribute) -> String {
  if not(self.is_string()) {
    abort("Attribute is not a string");
  }

  @unsafe.llvm_get_string_attribute_value(self.as_attr_ref())
}

///| Gets the type associated with a type attribute.
///
/// # Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let kind_id = Attribute::get_named_enum_kind_id("sret");
/// let any_type = context.i32_type().as_any_type_enum();
/// let type_attribute = context.create_type_attribute(
///     kind_id,
///     any_type,
/// );
///
/// assert_true!(type_attribute.is_type());
/// assert_eq!(type_attribute.get_type_value(), any_type);
/// assert_ne!(type_attribute.get_type_value(), context.i64_type().as_any_type_enum());
/// ```
pub fn Attribute::get_type_value(self: Attribute) -> AnyTypeEnum {
  if not(self.is_type()) {
    abort("Attribute is not a type");
  }

  AnyTypeEnum::new(@unsafe.llvm_get_type_attribute_value(self.as_attr_ref()))
}

pub fn Attribute::to_string(self: Attribute) -> String {
  if self.is_string() {
    "string_attribute (\{self.get_string_value()})"
  } else if self.is_enum() {
    "enum_attribute (\{self.get_enum_value()})"
  } else if self.is_type() {
    "type_attribute (\{self.get_type_value()})"
  } else {
    "Unknown attribute (Maybe error)"
  }
}

pub impl Show for Attribute with to_string(self: Attribute) {
  self.to_string()
}

pub impl Show for Attribute with output(self: Attribute, logger: &Logger) {
  logger.write_string(self.to_string())
}

///| An `AttributeLoc` determines where on a function an attribute is assigned to.
pub(all) enum AttributeLoc {
  /// Assign to the `FunctionValue`'s return type.
  Return

  /// Assign to one of the `FunctionValue`'s params (0-indexed).
  Param(UInt)

  /// Assign to the `FunctionValue` itself.
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

pub fn op_equal(self: Attribute, other: Attribute) -> Bool {
  if self.is_enum() && other.is_enum () {
    return self.get_enum_kind_id() == other.get_enum_kind_id() &&
           self.get_enum_value() == other.get_enum_value();
  }

  if self.is_string() && other.is_string() {
    return self.get_string_kind_id() == other.get_string_kind_id() &&
           self.get_string_value() == other.get_string_value();
  }
  
  // TODO: need to implement op_equal for AnyTypeEnum
  if self.is_type() && other.is_type() {
    return self.get_enum_kind_id() == other.get_enum_kind_id() &&
        self.get_type_value() == other.get_type_value();
  }

  // TODO: need to implement op_equal for attributeref
  self.attribute == other.attribute
}

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

