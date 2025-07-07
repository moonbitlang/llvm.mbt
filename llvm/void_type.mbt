///| A `VoidType` is a special type with no possible direct instances.
/// It's only useful as a function return type.
pub struct VoidType {
  ty : TypeRef
}

///| Create `VoidType` from `@unsafe.LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not void type.
pub fn VoidType::new(type_ref : @unsafe.LLVMTypeRef) -> VoidType {
  guard type_ref.is_not_null()
  VoidType::{ ty: TypeRef::new(type_ref) }
}

///|
pub impl Type for VoidType with base(self) {
  self.ty
}

///|
pub impl Type for VoidType with as_type_enum(self) {
  VoidType(self)
}

///| Return whether this `VoidType` is sized. **Always returns `false`.**
pub fn VoidType::is_sized(self : VoidType) -> Bool {
  self.ty.is_sized()
}

///| Gets a reference to the `Context` this `VoidType` was created in.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let void_type = context.void_type();
/// let void_ctx = void_type.get_context();
/// assert_true(context == void_ctx);
/// ```
pub fn VoidType::get_context(self : VoidType) -> Context {
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
/// inspect(fn_type, content="void (i32)")
/// ```
pub fn VoidType::fn_type(
  self : VoidType,
  param_types : Array[&BasicType],
  is_var_arg~ : Bool = false
) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg~)
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
/// inspect(void_align, content=expect)
/// ```
pub fn VoidType::get_alignment(self : VoidType) -> IntValue {
  self.ty.get_alignment()
}

///|
pub impl Show for VoidType with output(self : VoidType, logger : &Logger) -> Unit {
  logger.write_string(self.ty.to_string())
}
