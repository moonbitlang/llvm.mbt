///| A `PointerType` is the type of a pointer constant or variable.
pub struct PointerType {
  ty: Type
}

///| Create `PointerType` from `@unsafe.LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not pointer type.
pub fn PointerType::new(type_ref: @unsafe.LLVMTypeRef) -> PointerType {
  assert_type_ref(type_ref)

  PointerType::{
    ty: Type::new(type_ref)
  }
}

///| Returns the `Type` of this `PointerType`.
pub fn PointerType::as_type(self: PointerType) -> Type {
  self.ty
}

///| Return `@unsafe.LLVMTypeRef` of `PointerType`
pub fn PointerType::as_type_ref(self: PointerType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

///| Gets the size of this `PointerType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let ptr_sz = ptr_type.size_of();
/// let expect = "i64 ptrtoint (ptr getelementptr (ptr, ptr null, i32 1) to i64)";
/// inspect!(ptr_sz, content=expect)
/// ```
pub fn PointerType::size_of(self: PointerType) -> IntValue {
  self.ty.size_of().unwrap()
}

///| Returns whether this `PointerType` is sized. **Always returns `true`.**
pub fn PointerType::is_sized(self: PointerType) -> Bool {
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
/// inspect!(ptr_align, content=expect)
/// ```
pub fn PointerType::get_alignment(self: PointerType) -> IntValue {
  self.ty.get_alignment()
}

///| Creates a `PointerType` with this `PointerType` for its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let ptr_ptr_type = ptr_type.ptr_type(AddressSpace::default());
/// inspect!(ptr_ptr_type, "ptr")
/// ```
pub fn PointerType::ptr_type(self: PointerType, address_space: AddressSpace) -> PointerType {
  PointerType::new(@unsafe.llvm_pointer_type(self.as_type_ref(), address_space.into()))
}

///| Gets a reference to the `Context` this `PointerType` was created in.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let ptr_ctx = ptr_type.get_context();
/// assert_true!(context == ptr_ctx);
/// ```
pub fn PointerType::get_context(self: PointerType) -> Context {
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
/// inspect!(fn_type, "ptr (i32)")
/// ```
pub fn PointerType::fn_type(self: PointerType, param_types: Array[&BasicMetadataType], is_var_arg~: Bool = false) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg=is_var_arg)
}

///| Creates an `ArrayType` with this `PointerType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let array_type = ptr_type.array_type(16);
/// inspect!(array_type, "[16 x ptr]")
/// ```
pub fn PointerType::array_type(self: PointerType, size: UInt) -> ArrayType {
  self.ty.array_type(size)
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
/// inspect!(addr_space, "AddressSpace(0)")
/// ```
pub fn PointerType::get_address_space(self: PointerType) -> AddressSpace {
  let addr_space = @unsafe.llvm_get_pointer_address_space(self.as_type_ref())

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
/// inspect!(null_ptr, "ptr null")
/// ```
pub fn PointerType::const_null(self: PointerType) -> PointerValue {
  PointerValue::new(@unsafe.llvm_const_null(self.as_type_ref()))
}

///| Creates a constant null value of this `PointerType`.
/// This is practically the same as calling `const_null` for this particular type.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let null_ptr = ptr_type.const_zero();
/// inspect!(null_ptr, "ptr null")
/// ```
pub fn PointerType::const_zero(self: PointerType) -> PointerValue {
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
/// inspect!(ptr_undef, "ptr undef")
/// ```
pub fn PointerType::get_undef(self: PointerType) -> PointerValue {
  PointerValue::new(@unsafe.llvm_get_undef(self.as_type_ref()))
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
/// inspect!(ptr_poison, "ptr poison")
/// ```
pub fn PointerType::get_poison(self: PointerType) -> PointerValue {
  PointerValue::new(@unsafe.llvm_get_poison(self.as_type_ref()))
}

///| Creates a `VectorType` with this `PointerType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let vector_type = ptr_type.vec_type(16);
/// inspect!(vector_type, "<16 x ptr>")
/// ```
pub fn PointerType::vec_type(self: PointerType, size: UInt) -> VectorType {
  self.ty.vec_type(size)
}

///| Creates a `ScalableVectorType` with this `PointerType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let vscale_type = ptr_type.scalable_vec_type(16);
/// inspect!(vscale_type, "<vscale x 16 x ptr>")
/// ```
pub fn PointerType::scalable_vec_type(self: PointerType, size: UInt) -> ScalableVectorType {
  self.ty.scalable_vec_type(size)
}

// Note: Check if `@unsafe.llvm_get_element_type` is unavailable in llvm-19
// pub fn PointerType::get_element_type(self: PointerType) -> ...

// TODO: enable this after `new_const_array` is implemented
pub fn PointerType::const_array(self: PointerType, values: Array[PointerValue]) -> ArrayValue {
  ArrayValue::new_const_array(self, values)
}


// NOTE: above llvm-15
///| Determine whether this pointer is opaque.
pub fn PointerType::is_opaque(self: PointerType) -> Bool {
  @unsafe.llvm_pointer_type_is_opaque(self.as_type_ref())
}

///| Dump the `PointerType` to stderr.
///
/// It's equivalent to `PointerType::dump()`.
pub fn PointerType::print_to_stderr(self: PointerType) -> Unit {
  self.ty.print_to_stderr()
}

///| Dump the `PointerType` to a string.
///
/// It's equivalent to `PointerType::to_string()`.
pub fn PointerType::print_to_string(self: PointerType) -> String {
  self.ty.print_to_string()
}

///| Dump the `PointerType` to a string.
///
/// It's equivalent to `PointerType::print_to_string()`.
pub fn PointerType::to_string(self: PointerType) -> String {
  self.ty.to_string()
}

///| Dump the `PointerType` to stderr.
///
/// It's equivalent to `PointerType::print_to_stderr()`.
pub fn PointerType::dump(self: PointerType) -> Unit {
  self.ty.dump()
}

pub impl Show for PointerType with output(self: PointerType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for PointerType with to_string(self: PointerType) -> String {
  self.to_string()
}

