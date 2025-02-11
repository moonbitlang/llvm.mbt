///| A `MetadataType` is the type of a metadata.
pub struct MetadataType {
  ty: Type
}

///| Create `MetadataType` from `@unsafe.LLVMTypeRef`
pub fn MetadataType::new(type_ref: @unsafe.LLVMTypeRef) -> MetadataType {
  assert_type_ref(type_ref)

  MetadataType::{
    ty: Type::new(type_ref)
  }
}

///| Returns the `@unsafe.LLVMTypeRef` of this `MetadataType`.
pub fn MetadataType::as_type_ref(self: MetadataType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

///| Creates a `FunctionType` with this `MetadataType` for its return type.
pub fn MetadataType::fn_type(self: MetadataType, param_types: Array[&BasicMetadataType], is_var_arg~: Bool = false) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg=is_var_arg)
}

/// Gets a reference to the `Context` this `MetadataType` was created in.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let md_type = context.metadata_type();
/// let md_context = md_type.get_context();
/// assert_eq!(md_context, context)
/// ```
pub fn MetadataType::get_context(self: MetadataType) -> Context {
  self.ty.get_context()
}

///| Gets the size of this `MetadataType`. Value may vary depending on the target architecture.
///
/// It's equivalent to `MetadataType::dump`.
pub fn MetadataType::print_to_stderr(self: MetadataType) -> Unit {
  self.ty.print_to_stderr()
}

///| Gets the size of this `MetadataType`. Value may vary depending on the target architecture.
///
/// It's equivalent to `MetadataType::to_string`.
pub fn MetadataType::print_to_string(self: MetadataType) -> String {
  self.ty.print_to_string()
}

///| Converts this `MetadataType` to a string.
pub fn MetadataType::to_string(self: MetadataType) -> String {
  self.ty.to_string()
}

///| Prints this `MetadataType` to stderr.
///
/// It's equivalent to `MetadataType::dump`.
pub fn MetadataType::dump(self: MetadataType) -> Unit {
  self.ty.dump()
}

pub impl Show for MetadataType with output(self: MetadataType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for MetadataType with to_string(self: MetadataType) -> String {
  self.to_string()
}
