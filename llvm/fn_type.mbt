///| A `FunctionType` is the type of a function variable.
pub struct FunctionType {
  ty : TypeRef
}

///| Create `FunctionType` from `@unsafe.LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not function type.
pub fn FunctionType::new(type_ref : @unsafe.LLVMTypeRef) -> FunctionType {
  guard type_ref.is_not_null()
  FunctionType::{ ty: TypeRef::new(type_ref) }
}

pub impl Type for FunctionType with base(self) {
  self.ty
}

pub impl Type for FunctionType with as_type_enum(self) {
  FunctionType(self)
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
/// inspect(ptr_type, content="ptr")
/// ```
pub fn FunctionType::ptr_type(
  self : FunctionType,
  address_space : AddressSpace
) -> PointerType {
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
/// assert_true(fn_type.is_var_arg())
/// ```
pub fn FunctionType::is_var_arg(self : FunctionType) -> Bool {
  @unsafe.llvm_is_function_var_arg(self.inner())
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
/// inspect(param_types, content="[i32, double]")
/// ```
pub fn FunctionType::get_param_types(
  self : FunctionType
) -> Array[&BasicType] {
  let param_types = @unsafe.llvm_get_param_types(self.inner())
  param_types.map(t => BasicTypeEnum::init(t).as_basic_type_class())
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
/// assert_eq(param_count, 2)
/// ```
pub fn FunctionType::count_param_types(self : FunctionType) -> UInt {
  @unsafe.llvm_count_param_types(self.inner())
}

// REVIEW: Seems it always return false

///| Gets whether or not this `FunctionType` is sized or not.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let fn_type = i32_type.fn_type([i32_type]);
/// assert_false(fn_type.is_sized())
/// ```
pub fn FunctionType::is_sized(self : FunctionType) -> Bool {
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
/// assert_true(fn_context == context)
/// ```
pub fn FunctionType::get_context(self : FunctionType) -> Context {
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
/// inspect(ret_type.unwrap(), content="i32")
/// ```
pub fn FunctionType::get_return_type(self : FunctionType) -> &BasicType? {
  let ty = @unsafe.llvm_get_return_type(self.inner())
  let kind = @unsafe.llvm_get_type_kind(ty)
  match kind {
    @unsafe.LLVMVoidTypeKind => None
    _ => Some(BasicTypeEnum::init(ty).as_basic_type_class())
  }
}

///| Dumps the `FunctionType` to stderr.
///
/// It's equivalent to `FunctionType::dump()`.
pub impl Show for FunctionType with output(
  self : FunctionType,
  logger : &Logger
) -> Unit {
  logger.write_string(self.ty.to_string())
}
