///| An `ArrayType` is the type of contiguous constants or variables.
pub struct ArrayType {
  ty : TypeRef
}

///| Create `ArrayType` from `@unsafe.LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not array type.
pub fn ArrayType::new(type_ref : @unsafe.LLVMTypeRef) -> ArrayType {
  guard type_ref.is_not_null()
  ArrayType::{ ty: TypeRef::new(type_ref) }
}

pub impl Type for ArrayType with base(self) {
  self.ty
}

pub impl Type for ArrayType with as_type_enum(self) {
  ArrayType(self)
}

pub impl BasicType for ArrayType with as_basic_type_enum(self) {
  ArrayType(self)
}

///| Gets the size of this `ArrayType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let array_type = i32_type.array_type(8);
/// let array_sz = array_type.size_of().unwrap();
/// let expect = "i64 ptrtoint (ptr getelementptr ([8 x i32], ptr null, i32 1) to i64)"
/// inspect(array_sz, content=expect)
/// ```
pub fn ArrayType::size_of(self : ArrayType) -> IntValue? {
  self.ty.size_of()
}

///| Gets the alignment of this `ArrayType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let array_type = i32_type.array_type(8);
/// let array_align = array_type.get_alignment();
/// let expect = "i64 ptrtoint (ptr getelementptr ({ i1, [8 x i32] }, ptr null, i64 0, i32 1) to i64)"
/// inspect(array_align, content=expect)
/// ```
pub fn ArrayType::get_alignment(self : ArrayType) -> IntValue {
  self.ty.get_alignment()
}

///| Returns whether this `ArrayType` is sized. **Always returns `true`.**
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let array_type = i32_type.array_type(8);
/// assert_true(array_type.is_sized())
/// ```
pub fn ArrayType::is_sized(self : ArrayType) -> Bool {
  self.ty.is_sized()
}

///| Creates a `PointerType` with this `ArrayType` for its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let array_type = i32_type.array_type(8);
/// let ptr_type = array_type.ptr_type(AddressSpace::default());
/// inspect(ptr_type, content="ptr")
/// ```
pub fn ArrayType::ptr_type(
  self : ArrayType,
  address_space : AddressSpace
) -> PointerType {
  self.ty.ptr_type(address_space)
}

///| Gets a reference to the `Context` this `ArrayType` was created in.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let array_type = i32_type.array_type(8);
/// let array_ctx = array_type.get_context();
/// assert_true(context == array_ctx);
/// ```
pub fn ArrayType::get_context(self : ArrayType) -> Context {
  self.ty.get_context()
}

///| Creates a `FunctionType` with this `ArrayType` for its return type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let array_type = i32_type.array_type(8);
/// let fn_type = array_type.fn_type([i32_type]);
/// inspect(fn_type, content="[8 x i32] (i32)")
/// ```
pub fn ArrayType::fn_type(
  self : ArrayType,
  param_types : Array[&BasicType],
  is_var_arg~ : Bool = false
) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg~)
}

///| Creates a `StructType` with this `ArrayType` for its return type.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip (test failed)
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let array_type = i32_type.array_type(8);
/// let array_array_type = array_type.array_type(8);
/// inspect(array_array_type, content="[8 x i32]")
/// inspect(array_array_type, content="[8 x [8 x i32]]")
/// ```
pub fn ArrayType::array_type(self : ArrayType, size : UInt) -> ArrayType {
  self.ty.array_type(size)
}

///| Creates a constant `ArrayValue` of `ArrayValue`s.
pub fn ArrayType::const_array(
  self : ArrayType,
  values : Array[&BasicValue]
) -> ArrayValue {
  let values = values.map(v => v as &Value)
  ArrayValue::new_const_array(self, values)
}

///| Creates a constant zero value of this `ArrayType`.
pub fn ArrayType::const_zero(self : ArrayType) -> ArrayValue {
  ArrayValue::new(self.ty.const_zero())
}

///| Gets the length of this `ArrayType`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let array_type = i32_type.array_type(8);
/// let array_len = array_type.length();
/// assert_eq(array_len, 8);
/// ```
pub fn ArrayType::length(self : ArrayType) -> UInt {
  @unsafe.llvm_get_array_length(self.inner())
}

///| Gets the length of this `ArrayType`.
/// It is equivalent to `ArrayType::length`.
pub fn ArrayType::len(self : ArrayType) -> UInt {
  @unsafe.llvm_get_array_length(self.inner())
}

///| Returns `true` if this `ArrayType` contains no elements.
pub fn ArrayType::is_empty(self : ArrayType) -> Bool {
  self.length() == 0
}

///| Creates an undefined instance of a `ArrayType`.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip (test failed)
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let array_type = i32_type.array_type(8);
/// let array_undef = array_type.get_undef();
/// inspect(array_undef, content="[8 x i32] undef")
/// ```
pub fn ArrayType::get_undef(self : ArrayType) -> ArrayValue {
  ArrayValue::new(self.ty.get_undef())
}

///| Creates a poison instance of a `ArrayType`.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip (test failed)
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let array_type = i32_type.array_type(8);
/// let array_poison = array_type.get_poison();
/// inspect(array_poison, content="[8 x i32] poison")
/// ```
pub fn ArrayType::get_poison(self : ArrayType) -> ArrayValue {
  ArrayValue::new(@unsafe.llvm_get_poison(self.inner()))
}

///| Gets the element type of this `ArrayType`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let array_type = i32_type.array_type(8);
/// let ele_type = array_type.get_element_type();
/// inspect(ele_type, content="i32")
/// ```
pub fn ArrayType::get_element_type(self : ArrayType) -> &BasicType {
  let ty_ref = self.ty.get_element_type().inner()
  BasicTypeEnum::init(ty_ref).as_basic_type_class()
}

///|
pub impl Show for ArrayType with output(self : ArrayType, logger : &Logger) -> Unit {
  logger.write_string(self.ty.to_string())
}
