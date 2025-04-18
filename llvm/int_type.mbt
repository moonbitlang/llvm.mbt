///| An `IntType` is the type of an integer constant or variable.
pub struct IntType {
  ty: Type
}

///| Create `IntType` from `@unsafe.LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not int type.
pub fn IntType::new(type_ref: @unsafe.LLVMTypeRef) -> IntType {
  guard type_ref.is_not_null()

  IntType::{
    ty: Type::new(type_ref)
  }
}

///|
pub fn IntType::as_type(self: IntType) -> Type {
  self.ty
}

///| Return `@unsafe.LLVMTypeRef` of `IntType`
pub fn IntType::as_type_ref(self: IntType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

///| Creates an `IntValue` representing a constant value of this `IntType`. It will be automatically assigned this `IntType`'s `Context`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let i32_type = IntType::i32_type(context)
/// let i32_val = i32_type.const_int(42, false)
/// inspect!(i32_val, "i32 42")
/// ```
// TODO: Maybe better explain signextension
pub fn IntType::const_int(self: IntType, val: UInt64, sign_extend~: Bool = true) -> IntValue {
  let val_ref = @unsafe.llvm_const_int(self.as_type_ref(), val, sign_extend)
  IntValue::new(val_ref)
}

// pub fn IntType::const_int_from_string(self: IntType, slice: String, radix: StringRaidx) -> IntValue? {
//
// }

///| Create a constant `IntValue` of arbitrary precision.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create()
/// let i64_type = context.i64_type();
/// let i64_val = i64_type.const_int_arbitrary_precision([1, 2]);
/// ```
pub fn IntType::const_int_arbitrary_precision(self: IntType, words: Array[UInt64]) -> IntValue {
  let val_ref = @unsafe.llvm_const_int_of_arbitrary_precision(self.as_type_ref(), words)
  IntValue::new(val_ref)
}

///| Creates an `IntValue` representing a constant value of all one bits of this `IntType`. It will be automatically assigned this `IntType`'s `Context`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let all_ones_val = i32_type.const_all_ones();
/// inspect!(all_ones_val, "i32 -1")
/// ```
pub fn IntType::const_all_ones(self: IntType) -> IntValue {
  let val_ref = @unsafe.llvm_const_all_ones(self.as_type_ref())
  IntValue::new(val_ref)
}

///| Creates a constant zero value of this `IntType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i8_type = context.i8_type();
/// let i8_zero = i8_type.const_zero();
/// inspect!(i8_zero, "i8 0")
/// ```
/// @alert bug "This function will cause `ValueRef is Null` error."
pub fn IntType::const_zero(self: IntType) -> IntValue {
  IntValue::new(self.ty.const_zero())
}

///| Creates a `FunctionType` with this `IntType` for its return type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let fn_type = i32_type.fn_type([i32_type]);
/// inspect!(fn_type, "i32 ()")
/// ```
pub fn IntType::fn_type(self: IntType, param_types: Array[&BasicType], is_var_arg~: Bool = false) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg=is_var_arg)
}

///| Creates an `ArrayType` with this `IntType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let array_type = i32_type.array_type(16);
/// inspect!(array_type, "[16 x i32]")
/// ```
pub fn IntType::array_type(self: IntType, size: UInt) -> ArrayType {
  self.ty.array_type(size)
}

///| Creates a `VectorType` with this `IntType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let vector_type = i32_type.vec_type(16);
/// inspect!(vector_type, "<16 x i32>")
/// ```
pub fn IntType::vec_type(self: IntType, size: UInt) -> VectorType {
  self.ty.vec_type(size)
}

///| Creates a `ScalableVectorType` with this `IntType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let vscale_type = i32_type.scalable_vec_type(16);
/// inspect!(vscale_type, "<vscale x 16 x i32>")
/// ```
pub fn IntType::scalable_vec_type(self: IntType, size: UInt) -> ScalableVectorType {
  self.ty.scalable_vec_type(size)
}


///| Gets a reference to the `Context` this `IntType` was created in.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i32_ctx = i32_type.get_context();
/// assert_true!(context == i32_ctx);
/// ```
pub fn IntType::get_context(self: IntType) -> Context {
  self.ty.get_context()
}

///| Gets the size of this `IntType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i32_sz = i32_type.size_of();
/// let expect = "i64 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i64)";
/// inspect!(i32_sz, content=expect)
/// ```
pub fn IntType::size_of(self: IntType) -> IntValue {
  self.ty.size_of().unwrap()
}

///| Returns whether this `IntType` is sized. **Always returns `true`.**
pub fn IntType::is_sized(self: IntType) -> Bool {
  self.ty.is_sized()
}

///| Gets the alignment of this `IntType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i32_align = i32_type.get_alignment();
/// let expect = "i64 ptrtoint (ptr getelementptr ({ i1, i32 }, ptr null, i64 0, i32 1) to i64)"
/// inspect!(i32_align, content=expect)
/// ```
pub fn IntType::get_alignment(self: IntType) -> IntValue {
  self.ty.get_alignment()
}

///| Creates a `PointerType` with this `IntType` for its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// inspect!(ptr_type, "ptr")
/// ```
pub fn IntType::ptr_type(self: IntType, address_space: AddressSpace) -> PointerType {
  PointerType::new(@unsafe.llvm_pointer_type(self.as_type_ref(), address_space.into()))
}

///| Gets the bit width of an `IntType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i32_width = i32_type.get_bit_width();
/// inspect!(i32_width, "32")
/// ```
pub fn IntType::get_bit_width(self: IntType) -> UInt {
  @unsafe.llvm_get_int_type_width(self.as_type_ref())
}

///| Creates an undefined instance of an `IntType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i32_undef = i32_type.get_undef();
/// inspect!(i32_undef, "i32 undef")
/// ```
pub fn IntType::get_undef(self: IntType) -> IntValue {
  IntValue::new(self.ty.get_undef())
}

///| Creates a poison instance of an `IntType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i32_poison = i32_type.get_poison();
/// inspect!(i32_poison, "i32 poison")
/// ```
pub fn IntType::get_poison(self: IntType) -> IntValue {
  IntValue::new(self.ty.get_poison())
}

// pub fn IntType::create_generic_value(self: IntType, value: UInt64, is_signed: Bool) -> GenericValue {
//   let gv = @unsafe.llvm_create_generic_value_of_int(self.as_type_ref(), value, is_signed)
//   GenericValue::new(gv)
// }

// TODO: enable this after `new_const_array` is implemented
pub fn IntType::const_array(self: IntType, values: Array[IntValue]) -> ArrayValue {
  ArrayValue::new_const_array(self, values)
}

///| Dumps the `IntType` to stderr.
///
/// It's equivalent to `IntType::print_to_stderr`.
pub fn IntType::print_to_stderr(self: IntType) -> Unit {
  self.ty.print_to_stderr()
}

///| Dumps the `IntType` to a string.
///
/// It's equivalent to `IntType::to_string`.
pub fn IntType::print_to_string(self: IntType) -> String {
  self.ty.print_to_string()
}

///| Dumps the `IntType` to stderr.
///
/// It's equivalent to `IntType::print_to_string`.
pub fn IntType::to_string(self: IntType) -> String {
  self.ty.to_string()
}

///| Dumps the `IntType` to stderr.
///
/// It's equivalent to `IntType::print_to_stderr`.
pub fn IntType::dump(self: IntType) -> Unit {
  self.ty.dump()
}

pub impl Show for IntType with output(self: IntType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for IntType with to_string(self: IntType) -> String {
  self.to_string()
}

