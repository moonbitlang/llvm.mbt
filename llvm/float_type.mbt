// ==============================================
// FloatType
// ==============================================
///| A `FloatType` is the type of a floating point constant or variable.
pub struct FloatType {
  ty: Type
}

///| Create `FloatType` from `@unsafe.LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not float type.
pub fn FloatType::new(type_ref: @unsafe.LLVMTypeRef) -> FloatType {
  assert_type_ref(type_ref)

  FloatType::{
    ty: Type::new(type_ref)
  }
}

///| Return `Type` of `FloatType`.
pub fn FloatType::as_type(self: FloatType) -> Type {
  self.ty
}

// use get_kind to check if it is float type
// pub fn FloatType::safe_new(type_ref: @unsafe.LLVMTypeRef) -> Option[FloatType];

///| Return `@unsafe.LLVMTypeRef` of `FloatType`
pub fn FloatType::as_type_ref(self: FloatType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

///| Creates a constant `FloatValue` of this `FloatType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f32_type = context.f32_type();
/// let i32_type = context.i32_type();
/// let fn_val = f32_type.fn_type([i32_type]);
/// inspect!(fn_val, "float (i32)")
/// ```
pub fn FloatType::fn_type(
  self: FloatType, param_types: Array[&BasicMetadataType], is_var_arg~: Bool = false
) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg=is_var_arg)
}

///| Creates an `ArrayType` with this `FloatType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f32_type = context.f32_type();
/// let array_type = f32_type.array_type(16);
/// inspect!(array_type, "[16 x float]")
/// ```
pub fn FloatType::array_type(self: FloatType, size: UInt) -> ArrayType {
  self.ty.array_type(size)
}

///| Creates a `VectorType` with this `FloatType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f32_type = context.f32_type();
/// let vector_type = f32_type.vec_type(16);
/// inspect!(vector_type, "<16 x float>")
/// ```
pub fn FloatType::vec_type(self: FloatType, size: UInt) -> VectorType {
  self.ty.vec_type(size)
}

///| Creates a `ScalableVectorType` with this `FloatType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f32_type = context.f32_type();
/// let vscale_type = f32_type.scalable_vec_type(16);
/// inspect!(vscale_type, "<vscale x 16 x float>")
/// ```
pub fn FloatType::scalable_vec_type(self: FloatType, size: UInt) -> ScalableVectorType {
  self.ty.scalable_vec_type(size)
}

///| Creates a `FloatValue` representing a constant value of this `FloatType`.
/// It will be automatically assigned this `FloatType`'s `Context`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let pi = f64_type.const_float(3.1415926);
/// inspect!(pi, "double 0x400921FB4D12D84A")
/// ```
pub fn FloatType::const_float(self: FloatType, val: Double) -> FloatValue {
  let val_ref = @unsafe.llvm_const_real(self.as_type_ref(), val)
  FloatValue::new(val_ref)
}

// FIXME: untested
pub fn FloatType::const_float_from_string(self: FloatType, slice: String) -> FloatValue {
  if slice.is_empty() {
    abort("Float string is empty")
  }

  // TODO: use `@unsafe.llvm_const_real_of_string` instead
  let r = @unsafe.llvm_const_real_of_string_and_size(self.as_type_ref(), slice)
  FloatValue::new(r)
}

///| Creates a constant zero value of this `FloatType`.
///
/// **Note: This API is problematic**
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let f64_zero = f64_type.const_zero();
/// inspect!(f64_zero, "double 0.0")
/// ```
/// @alert bug "This function will cause `ValueRef is Null` error."
pub fn FloatType::const_zero(self: FloatType) -> FloatValue {
  FloatValue::new(self.ty.const_zero())
}

///| Gets the size of this `FloatType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let f64_sz = f64_type.size_of();
/// let expect = "i64 ptrtoint (ptr getelementptr (double, ptr null, i32 1) to i64)";
/// inspect!(f64_sz, content=expect)
/// ```
pub fn FloatType::size_of(self: FloatType) -> IntValue {
  self.ty.size_of().unwrap()
}

///| Returns whether this `FloatType` is sized. **Always returns `true`.**
pub fn FloatType::is_sized(self: FloatType) -> Bool {
  self.ty.is_sized()
}

///| Gets the alignment of this `FloatType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let f64_align = f64_type.get_alignment();
/// let expect = "i64 ptrtoint (ptr getelementptr ({ i1, double }, ptr null, i64 0, i32 1) to i64)"
/// inspect!(f64_align, content=expect)
/// ```
pub fn FloatType::get_alignment(self: FloatType) -> IntValue {
  self.ty.get_alignment()
}

///| Gets a reference to the `Context` this `FloatType` was created in.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let f64_ctx = f64_type.get_context();
/// assert_eq!(context, f64_ctx);
/// ```
pub fn FloatType::get_context(self: FloatType) -> Context {
  self.ty.get_context()
}

///| Creates a `PointerType` with this `FloatType` for its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let ptr_type = f64_type.ptr_type(AddressSpace::default());
/// inspect!(ptr_type, "ptr")
/// ```
pub fn FloatType::ptr_type(self: FloatType, address_space: AddressSpace) -> PointerType {
  PointerType::new(@unsafe.llvm_pointer_type(self.as_type_ref(), address_space.into()))
}

///| Creates an undefined instance of a `FloatType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let f64_undef = f64_type.get_undef();
/// inspect!(f64_undef, "double undef")
/// ```
pub fn get_undef(self: FloatType) -> FloatValue {
  FloatValue::new(self.ty.get_undef())
}

///| Creates a poison instance of a `FloatType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let f64_poison = f64_type.get_poison();
/// inspect!(f64_poison, "double poison")
/// ```
pub fn get_poison(self: FloatType) -> FloatValue {
  FloatValue::new(self.ty.get_poison())
}

// pub fn FloatType::create_generic_value(self: FloatType, value: Double) -> GenericValue {
//   let gv = @unsafe.llvm_create_generic_value_of_float(self.as_type_ref(), value)
//   GenericValue::new(gv)
// }

pub fn FloatType::const_array(self: FloatType, values: Array[FloatValue]) -> ArrayValue {
  ArrayValue::new_const_array(self, values)
}

///| Prints the `FloatType` to stderr.
///
/// It's equivalent to `FloatType::dump()`.
pub fn FloatType::print_to_stderr(self: FloatType) -> Unit {
  self.ty.print_to_stderr()
}

///| Prints the `FloatType` to a string.
///
/// It's equivalent to `FloatType::to_string()`.
pub fn FloatType::print_to_string(self: FloatType) -> String {
  self.ty.print_to_string()
}

///| Prints the `FloatType` to a string.
pub fn FloatType::to_string(self: FloatType) -> String {
  self.ty.to_string()
}

///| Dumps the `FloatType` to stderr.
///
/// It's equivalent to `FloatType::print_to_stderr()`.
pub fn FloatType::dump(self: FloatType) -> Unit {
  self.ty.dump()
}

pub impl Show for FloatType with output(self: FloatType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for FloatType with to_string(self: FloatType) -> String {
  self.to_string()
}
