///| A `FunctionType` is the type of a function variable.
pub struct FunctionType {
  ty: Type
}

///| Create `FunctionType` from `@unsafe.LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not function type.
pub fn FunctionType::new(type_ref: @unsafe.LLVMTypeRef) -> FunctionType {
  guard type_ref.is_not_null()

  FunctionType::{
    ty: Type::new(type_ref)
  }
}

///| Returns the `Type` of this `FunctionType`.
pub fn FunctionType::as_type(self: FunctionType) -> Type {
  self.ty
}

///| Return `@unsafe.LLVMTypeRef` of `FunctionType`
pub fn FunctionType::as_type_ref(self: FunctionType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

///| Creates a `PointerType` with this `FunctionType` for its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let fn_type = i32_type.fn_type([i32_type]);
/// let ptr_type = fn_type.ptr_type(AddressSpace::default());
/// inspect!(ptr_type, "ptr")
/// ```
pub fn FunctionType::ptr_type(self: FunctionType, address_space: AddressSpace) -> PointerType {
  self.ty.ptr_type(address_space)
}

///| Determines whether or not a `FunctionType` is a variadic function.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let fn_type = i32_type.fn_type([i32_type], is_var_arg=true);
/// assert_true!(fn_type.is_var_arg())
/// ```
pub fn FunctionType::is_var_arg(self: FunctionType) -> Bool {
  @unsafe.llvm_is_function_var_arg(self.as_type_ref())
}

///| Gets param types this `FunctionType` has.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let f64_type = context.f64_type();
/// let fn_type = i32_type.fn_type([i32_type, f64_type]);
/// let param_types = fn_type.get_param_types();
/// inspect!(param_types, "[i32, double]")
/// ```
pub fn FunctionType::get_param_types(self: FunctionType) -> Array[BasicTypeEnum] {
  let param_types = @unsafe.llvm_get_param_types(self.as_type_ref())

  param_types.map(fn (t) {BasicTypeEnum::new(t)})
}

///| Counts the number of param types this `FunctionType` has.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let f64_type = context.f64_type();
/// let fn_type = i32_type.fn_type([i32_type, f64_type]);
/// let param_count = fn_type.count_param_types();
/// assert_eq!(param_count, 2)
/// ```
pub fn FunctionType::count_param_types(self: FunctionType) -> UInt {
  @unsafe.llvm_count_param_types(self.as_type_ref())
}

// REVIEW: Seems it always return false
/// Gets whether or not this `FunctionType` is sized or not.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let fn_type = i32_type.fn_type([i32_type]);
/// assert_false!(fn_type.is_sized())
/// ```
pub fn FunctionType::is_sized(self: FunctionType) -> Bool {
  self.ty.is_sized()
}

///| Gets a reference to the `Context` this `FunctionType` was created in.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let fn_type = i32_type.fn_type([i32_type]);
/// let fn_context = fn_type.get_context();
/// assert_true!(fn_context == context)
/// ```
pub fn FunctionType::get_context(self: FunctionType) -> Context {
  self.ty.get_context()
}

///| Gets the return type of this `FunctionType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let f64_type = context.f64_type();
/// let fn_type = i32_type.fn_type([i32_type, f64_type]);
/// let ret_type = fn_type.get_return_type();
/// inspect!(ret_type.unwrap(), "double")
/// ```
pub fn FunctionType::get_return_type(self: FunctionType) -> BasicTypeEnum? {
  let ty = @unsafe.llvm_get_return_type(self.as_type_ref())
  let kind = @unsafe.llvm_get_type_kind(ty)
  match kind {
    @unsafe.LLVMVoidTypeKind => None
    _ => Some(BasicTypeEnum::new(ty))
  }
}

///| Dumps the `FunctionType` to stderr.
///
/// It's equivalent to `FunctionType::dump()`.
pub fn FunctionType::print_to_stderr(self: FunctionType) -> Unit {
  self.ty.print_to_stderr()
}

///| Dumps the `FunctionType` to a string.
///
/// It's equivalent to `FunctionType::to_string()`.
pub fn FunctionType::print_to_string(self: FunctionType) -> String {
  self.ty.print_to_string()
}

///| Dumps the `FunctionType` to a string.
///
/// It's equivalent to `FunctionType::print_to_string()`.
pub fn FunctionType::to_string(self: FunctionType) -> String {
  self.ty.to_string()
}

///| Dumps the `FunctionType` to stderr.
///
/// It's equivalent to `FunctionType::print_to_stderr()`.
pub fn FunctionType::dump(self: FunctionType) -> Unit {
  self.ty.dump()
}

///| Dumps the `FunctionType` to stderr.
///
/// It's equivalent to `FunctionType::dump()`.
pub impl Show for FunctionType with output(self: FunctionType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

///| Dumps the `FunctionType` to a string.
///
/// It's equivalent to `FunctionType::to_string()`.
pub impl Show for FunctionType with to_string(self: FunctionType) -> String {
  self.to_string()
}

