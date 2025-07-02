///| A `VectorType` is the type of a multiple value SIMD constant or variable.
pub struct VectorType {
  ty : TypeRef
}

///| Create `VectorType` from `@unsafe.LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not vector type.
pub fn VectorType::new(type_ref : @unsafe.LLVMTypeRef) -> VectorType {
  guard type_ref.is_not_null()
  VectorType::{ ty: TypeRef::new(type_ref) }
}

pub impl Type for VectorType with base(self) {
  self.ty
}

pub impl Type for VectorType with as_type_enum(self) {
  VectorType(self)
}

pub impl BasicType for VectorType with as_basic_type_enum(self) {
  VectorType(self)
}

///| Gets the size of this `VectorType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let vector_type = i32_type.vec_type(8);
/// let vector_sz = vector_type.size_of().unwrap();
/// let expect = "i64 ptrtoint (ptr getelementptr (<8 x i32>, ptr null, i32 1) to i64)"
/// inspect(vector_sz, content=expect)
/// ```
pub fn VectorType::size_of(self : VectorType) -> IntValue? {
  self.ty.size_of()
}

///| Returns whether this `VectorType` is sized. **Always returns `true`.**
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let vector_type = i32_type.vec_type(8);
/// assert_true(vector_type.is_sized())
/// ```
pub fn VectorType::is_sized(self : VectorType) -> Bool {
  self.ty.is_sized()
}

///| Gets the alignment of this `VectorType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let vector_type = i32_type.vec_type(8);
/// let vector_align = vector_type.get_alignment();
/// let expect = "i64 ptrtoint (ptr getelementptr ({ i1, <8 x i32> }, ptr null, i64 0, i32 1) to i64)"
/// inspect(vector_align, content=expect)
/// ```
pub fn VectorType::get_alignment(self : VectorType) -> IntValue {
  self.ty.get_alignment()
}

///| Gets the size of this `VectorType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let vector_type = i32_type.vec_type(8);
/// let vector_sz = vector_type.get_size();
/// assert_eq(vector_sz, 8);
/// ```
pub fn VectorType::get_size(self : VectorType) -> UInt {
  @unsafe.llvm_get_vector_size(self.inner())
}

// pub fn VectorType::const_vector

// pub fn VectorType::const_zero(self: VectorType) -> VectorValue {
//   VectorValue::new(@unsafe.llvm_const_zero(self.inner()))
// }

///| Creates an undefined instance of a `VectorType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let vector_type = i32_type.vec_type(8);
/// let vector_undef = vector_type.get_undef();
/// inspect(vector_undef, content="<8 x i32> undef")
/// ```
pub fn VectorType::get_undef(self : VectorType) -> VectorValue {
  VectorValue::new(self.ty.get_undef())
}

///| Creates a poison instance of a `VectorType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let vector_type = i32_type.vec_type(8);
/// let vector_poison = vector_type.get_poison();
/// inspect(vector_poison, content="<8 x i32> poison")
/// ```
pub fn VectorType::get_poison(self : VectorType) -> VectorValue {
  VectorValue::new(self.ty.get_poison())
}

///| Gets the element type of this `VectorType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let vector_type = i32_type.vec_type(8);
/// let ele_type = vector_type.get_element_type();
/// inspect(ele_type, content="i32")
/// ```
pub fn VectorType::get_element_type(self : VectorType) -> &BasicType {
  let ty_ref = self.ty.get_element_type().inner()
  BasicTypeEnum::init(ty_ref).as_basic_type_class()
}

///| Creates a `PointerType` with this `VectorType` for its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let vector_type = i32_type.vec_type(8);
/// let ptr_type = vector_type.ptr_type(AddressSpace::default());
/// inspect(ptr_type, content="ptr")
/// ```
pub fn VectorType::ptr_type(
  self : VectorType,
  address_space : AddressSpace
) -> PointerType {
  PointerType::new(
    @unsafe.llvm_pointer_type(self.inner(), address_space.into()),
  )
}

///| Creates a `FunctionType` with this `VectorType` for its return type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let vector_type = i32_type.vec_type(8);
/// let fn_type = vector_type.fn_type([i32_type]);
/// inspect(fn_type, content="<8 x i32> (i32)")
/// ```
pub fn VectorType::fn_type(
  self : VectorType,
  param_types : Array[&BasicType],
  is_var_arg~ : Bool = false
) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg~)
}

///| Creates an `ArrayType` with this `VectorType` for its element type.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let vector_type = i32_type.vec_type(4);
/// let array_type = vector_type.array_type(8);
/// inspect(array_type, content="[8 x <4 x i32>]")
/// ```
pub fn VectorType::array_type(self : VectorType, size : UInt) -> ArrayType {
  self.ty.array_type(size)
}

///| Creates a constant `ArrayValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip (VectorType.const_vector not implemented)
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i32_val = i32_type.const_int(42, sign_extend=false);
/// let i32_vty = i32_type.vec_type(2);
/// let i32_const_vec = i32_vty.const_vector([i32_val, i32_val]);
/// assert_true(i32_const_vec.is_const())
/// ```
pub fn VectorType::const_array(
  self : VectorType,
  values : Array[VectorValue]
) -> ArrayValue {
  let values = values.map(v => v as &Value)
  ArrayValue::new_const_array(self, values)
}

///| Gets a reference to the `Context` this `VectorType` was created in.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let vector_type = i32_type.vec_type(8);
/// let vector_ctx = vector_type.get_context();
/// assert_true(context == vector_ctx);
/// ```
pub fn VectorType::get_context(self : VectorType) -> Context {
  self.ty.get_context()
}

///|
pub impl Show for VectorType with output(self : VectorType, logger : &Logger) -> Unit {
  logger.write_string(self.ty.to_string())
}
