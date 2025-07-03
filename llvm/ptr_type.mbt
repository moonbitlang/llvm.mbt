///| A `PointerType` is the type of a pointer constant or variable.
pub struct PointerType {
  ty : TypeRef
}

///| Create `PointerType` from `@unsafe.LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not pointer type.
pub fn PointerType::new(type_ref : @unsafe.LLVMTypeRef) -> PointerType {
  guard type_ref.is_not_null()
  PointerType::{ ty: TypeRef::new(type_ref) }
}

pub impl Type for PointerType with base(self) {
  self.ty
}

pub impl Type for PointerType with as_type_enum(self) {
  PointerType(self)
}

pub impl BasicType for PointerType with as_basic_type_enum(self) {
  PointerType(self)
}




///| Returns whether this `PointerType` is sized. **Always returns `true`.**
pub fn PointerType::is_sized(self : PointerType) -> Bool {
  self.ty.is_sized()
}

///| Gets the alignment of this `PointerType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let ptr_align = ptr_type.get_alignment();
/// let expect = "i64 ptrtoint (ptr getelementptr ({ i1, ptr }, ptr null, i64 0, i32 1) to i64)";
/// inspect(ptr_align, content=expect)
/// ```
pub fn PointerType::get_alignment(self : PointerType) -> IntValue {
  self.ty.get_alignment()
}

///| Gets a reference to the `Context` this `PointerType` was created in.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let ptr_ctx = ptr_type.get_context();
/// assert_true(context == ptr_ctx);
/// ```
pub fn PointerType::get_context(self : PointerType) -> Context {
  self.ty.get_context()
}

///| Creates a `FunctionType` with this `PointerType` for its return type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let fn_type = ptr_type.fn_type([i32_type]);
/// inspect(fn_type, content="ptr (i32)")
/// ```
pub fn PointerType::fn_type(
  self : PointerType,
  param_types : Array[&BasicType],
  is_var_arg~ : Bool = false
) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg~)
}



///| Gets the `AddressSpace` a `PointerType` was created with.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let addr_space = ptr_type.get_address_space();
/// inspect(addr_space, content="AddressSpace(0)")
/// ```
pub fn PointerType::get_address_space(self : PointerType) -> AddressSpace {
  let addr_space = @unsafe.llvm_get_pointer_address_space(self.inner())
  AddressSpace(addr_space)
}

///| Creates a null `PointerValue` of this `PointerType`.
/// It will be automatically assigned this `PointerType`'s `Context`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let null_ptr = ptr_type.const_null();
/// inspect(null_ptr, content="ptr null")
/// ```
pub fn PointerType::const_null(self : PointerType) -> PointerValue {
  PointerValue::new(@unsafe.llvm_const_null(self.inner()))
}

///| Creates a constant null value of this `PointerType`.
/// This is practically the same as calling `const_null` for this particular type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let null_ptr = ptr_type.const_zero();
/// inspect(null_ptr, content="ptr null")
/// ```
pub fn PointerType::const_zero(self : PointerType) -> PointerValue {
  PointerValue::new(self.ty.const_zero())
}

///| Creates an undefined instance of a `PointerType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let ptr_undef = ptr_type.get_undef();
/// inspect(ptr_undef, content="ptr undef")
/// ```
pub fn PointerType::get_undef(self : PointerType) -> PointerValue {
  PointerValue::new(@unsafe.llvm_get_undef(self.inner()))
}

///| Creates a poison instance of a `PointerType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let ptr_poison = ptr_type.get_poison();
/// inspect(ptr_poison, content="ptr poison")
/// ```
pub fn PointerType::get_poison(self : PointerType) -> PointerValue {
  PointerValue::new(@unsafe.llvm_get_poison(self.inner()))
}





// Note: `@unsafe.llvm_get_element_type` is unavailable in llvm-19

///|
pub fn PointerType::get_element_type(self : PointerType) -> &Type {
  self.ty.get_element_type()
}

// TODO: enable this after `new_const_array` is implemented

///|
pub fn PointerType::const_array(
  self : PointerType,
  values : Array[PointerValue]
) -> ArrayValue {
  let values = values.map(v => v as &Value)
  ArrayValue::new_const_array(self, values)
}

// NOTE: above llvm-15

///| Determine whether this pointer is opaque.
pub fn PointerType::is_opaque(self : PointerType) -> Bool {
  @unsafe.llvm_pointer_type_is_opaque(self.inner())
}

///|
pub impl Show for PointerType with output(self : PointerType, logger : &Logger) -> Unit {
  logger.write_string(self.ty.to_string())
}
