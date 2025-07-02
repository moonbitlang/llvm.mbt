///| A `MetadataType` is the type of a metadata.
pub struct MetadataType {
  ty : TypeRef
}

///| Create `MetadataType` from `@unsafe.LLVMTypeRef`
pub fn MetadataType::new(type_ref : @unsafe.LLVMTypeRef) -> MetadataType {
  guard type_ref.is_not_null()
  MetadataType::{ ty: TypeRef::new(type_ref) }
}

pub impl Type for MetadataType with base(self) {
  self.ty
}

pub impl Type for MetadataType with as_type_enum(self) {
  MetadataType(self)
}

///| Creates a `FunctionType` with this `MetadataType` for its return type.
pub fn MetadataType::fn_type(
  self : MetadataType,
  param_types : Array[&BasicType],
  is_var_arg~ : Bool = false
) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg~)
}

///| Gets a reference to the `Context` this `MetadataType` was created in.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let md_type = context.metadata_type();
/// let md_context = md_type.get_context();
/// assert_true(md_context == context)
/// ```
pub fn MetadataType::get_context(self : MetadataType) -> Context {
  self.ty.get_context()
}

///|
pub impl Show for MetadataType with output(
  self : MetadataType,
  logger : &Logger
) -> Unit {
  logger.write_string(self.ty.to_string())
}
