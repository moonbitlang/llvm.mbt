///| A `VoidType` is a special type with no possible direct instances.
/// It's only useful as a function return type.
pub struct VoidType {
  ty : Type
}

///| Create `VoidType` from `LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not void type.
pub fn VoidType::new(type_ref: LLVMTypeRef) -> VoidType {
  assert_type_ref(type_ref)

  VoidType::{
    ty: Type::new(type_ref)
  }
}

///| Return `LLVMTypeRef` of `VoidType`
pub fn VoidType::as_type_ref(self: VoidType) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

///| Return whether this `VoidType` is sized. **Always returns `false`.**
pub fn VoidType::is_sized(self: VoidType) -> Bool {
  self.ty.is_sized()
}

///| Gets a reference to the `Context` this `VoidType` was created in.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let void_type = context.void_type();
/// let void_ctx = void_type.get_context();
/// assert_eq!(context, void_ctx);
/// ```
pub fn VoidType::get_context(self: VoidType) -> Context {
  self.ty.get_context()
}

///| Creates a `FunctionType` with this `VoidType` for its return type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let void_type = context.void_type();
/// let i32_type = context.i32_type();
/// let fn_type = void_type.fn_type([i32_type]);
/// inspect!(fn_type, "void (i32)")
/// ```
pub fn VoidType::fn_type(self: VoidType, param_types: Array[&BasicMetadataType], is_var_arg~: Bool = false) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg=is_var_arg)
}

///| Creates a `FunctionType` with this `VoidType` for its return type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let void_type = context.void_type();
/// let i32_type = context.i32_type();
/// let fn_type = void_type.fn_type_unsafe([i32_type.as_type_ref()]);
/// inspect!(fn_type, "void (i32)")
/// ```
pub fn VoidType::fn_type_unsafe(self: VoidType, param_types: Array[LLVMTypeRef], is_var_arg~: Bool = false) -> FunctionType {
  self.ty.fn_type_unsafe(param_types, is_var_arg=is_var_arg)
}

///| Gets the alignment of this `VoidType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let void_type = context.void_type();
/// let void_align = void_type.get_alignment();
/// let expect = "i64 ptrtoint (ptr getelementptr ({ i1, void }, ptr null, i64 0, i32 1) to i64)"
/// inspect!(void_align, content=expect)
/// ```
pub fn VoidType::get_alignment(self: VoidType) -> IntValue {
  self.ty.get_alignment()
}

///| Dumps the `VoidType` to stderr.
///
/// It's equivalent to `VoidType::dump()`.
pub fn VoidType::print_to_stderr(self: VoidType) -> Unit {
  self.ty.print_to_stderr()
}

///| Prints the `VoidType` to a string.
///
/// It's equivalent to `VoidType::to_string()`.
pub fn VoidType::print_to_string(self: VoidType) -> String {
  self.ty.print_to_string()
}

///| Prints the `VoidType` to a string.
pub fn VoidType::to_string(self: VoidType) -> String {
  self.ty.to_string()
}

///| Dumps the `VoidType` to stderr.
pub fn VoidType::dump(self: VoidType) -> Unit {
  self.ty.dump()
}

pub impl Show for VoidType with output(self: VoidType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for VoidType with to_string(self: VoidType) -> String {
  self.to_string()
}
