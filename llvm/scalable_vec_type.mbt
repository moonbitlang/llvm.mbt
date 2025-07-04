///| A `ScalableVectorType` is the type of a scalable multiple value SIMD constant or variable.
pub struct ScalableVectorType {
  ty : TypeRef
}

///| Create `ScalableVectorType` from `@unsafe.LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not scalable vector type.
pub fn ScalableVectorType::new(
  type_ref : @unsafe.LLVMTypeRef
) -> ScalableVectorType {
  guard type_ref.is_not_null()
  ScalableVectorType::{ ty: TypeRef::new(type_ref) }
}


pub impl Type for ScalableVectorType with base(self) {
  self.ty
}

pub impl Type for ScalableVectorType with as_type_enum(self) {
  ScalableVectorType(self)
}

pub impl BasicType for ScalableVectorType with as_basic_type_enum(self) {
  ScalableVectorType(self)
}

///| Gets the size of this `ScalableVectorType`. Value may vary depending on the target architecture.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip (scalable_vector_type not implemented)
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let scalable_vector_type = i32_type.scalable_vector_type(8);
/// let scalable_vector_sz = scalable_vector_type.size_of().unwrap();
/// let expect = ""
/// inspect(scalable_vector_sz, content=expect)
/// ```
pub fn ScalableVectorType::size_of(self : ScalableVectorType) -> IntValue? {
  self.ty.size_of()
}

///| Returns whether this `ScalableVectorType` is sized. **Always returns `true`.**
///
/// ## Example
///
/// ```moonbit skip skip
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let scalable_vector_type = i32_type.scalable_vector_type(8);
/// assert_true(scalable_vector_type.is_sized())
/// ```
pub fn ScalableVectorType::is_sized(self : ScalableVectorType) -> Bool {
  self.ty.is_sized()
}

///| Gets the alignment of this `ScalableVectorType`. Value may vary depending on the target architecture.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let scalable_vector_type = i32_type.scalable_vector_type(8);
/// let scalable_vector_align = scalable_vector_type.get_alignment();
/// let expect = ""
/// inspect(scalable_vector_align, content=expect)
/// ```
pub fn ScalableVectorType::get_alignment(self : ScalableVectorType) -> IntValue {
  self.ty.get_alignment()
}

///| Gets the size of this `ScalableVectorType`.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let scalable_vector_type = i32_type.scalable_vector_type(8);
/// let scalable_vector_sz = scalable_vector_type.get_size();
/// assert_eq!(scalable_vector_sz, 8);
/// ```
pub fn ScalableVectorType::get_size(self : ScalableVectorType) -> UInt {
  @unsafe.llvm_get_vector_size(self.inner())
}

///| Creates a constant zero value of this `ScalableVectorType`.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let scalable_vector_type = i32_type.scalable_vector_type(8);
/// let scalable_vector_zero = scalable_vector_type.const_zero();
/// ```
pub fn ScalableVectorType::const_zero(
  self : ScalableVectorType
) -> ScalableVectorValue {
  ScalableVectorValue::new(self.ty.const_zero())
}

///| Creates an undefined instance of a `ScalableVectorType`.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let scalable_vector_type = i32_type.scalable_vector_type(8);
/// let scalable_vector_undef = scalable_vector_type.get_undef();
/// inspect(scalable_vector_undef, content="<8 x i32> undef")
/// ```
pub fn ScalableVectorType::get_undef(
  self : ScalableVectorType
) -> ScalableVectorValue {
  ScalableVectorValue::new(self.ty.get_undef())
}

///| Creates a poison instance of a `ScalableVectorType`.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let scalable_vector_type = i32_type.scalable_vector_type(8);
/// let scalable_vector_poison = scalable_vector_type.get_poison();
/// inspect(scalable_vector_poison, content="<8 x i32> poison")
/// ```
pub fn ScalableVectorType::get_poison(
  self : ScalableVectorType
) -> ScalableVectorValue {
  ScalableVectorValue::new(self.ty.get_poison())
}

///| Gets the element type of this `ScalableVectorType`.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let scalable_vector_type = i32_type.scalable_vector_type(8);
/// let ele_type = scalable_vector_type.get_element_type();
/// inspect(ele_type, content="i32")
/// ```
pub fn ScalableVectorType::get_element_type(
  self : ScalableVectorType
) -> BasicTypeEnum {
  let ty_ref = self.ty.get_element_type().inner()
  BasicTypeEnum::init(ty_ref)
}

///| Creates a `PointerType` with this `ScalableVectorType` for its element type.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip (scalable_vector_type not implemented)
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let scalable_vector_type = i32_type.scalable_vector_type(8);
/// let ptr_type = scalable_vector_type.ptr_type(AddressSpace::default());
/// inspect(ptr_type, content="ptr")
/// ```
pub fn ScalableVectorType::ptr_type(
  self : ScalableVectorType,
  address_space : AddressSpace
) -> PointerType {
  self.ty.ptr_type(address_space)
}

///| Creates a `FunctionType` with this `ScalableVectorType` for its return type.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let scalable_vector_type = i32_type.scalable_vector_type(8);
/// let fn_type = scalable_vector_type.fn_type([i32_type]);
/// inspect(fn_type, content="<8 x i32> (i32)")
/// ```
pub fn ScalableVectorType::fn_type(
  self : ScalableVectorType,
  param_types : Array[&BasicType],
  is_var_arg~ : Bool = false
) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg~)
}

///| Creates an `ArrayType` with this `ScalableVectorType` for its element type.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let scalable_vector_type = i32_type.scalable_vector_type(8);
/// let array_type = scalable_vector_type.array_type(8);
/// inspect(array_type, content="[8 x <8 x i32>]")
/// ```
pub fn ScalableVectorType::array_type(
  self : ScalableVectorType,
  size : UInt
) -> ArrayType {
  self.array_type(size)
}

///| Creates a constant `ArrayValue`.
pub fn ScalableVectorType::const_array(
  self : ScalableVectorType,
  values : Array[ScalableVectorValue]
) -> ArrayValue {
  let values = values.map(v => v as &Value)
  ArrayValue::new_const_array(self, values)
}

///| Gets a reference to the `Context` this `ScalableVectorType` was created in.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let scalable_vector_type = i32_type.scalable_vector_type(8);
/// let scalable_vector_ctx = scalable_vector_type.get_context();
/// assert_true(context == scalable_vector_ctx);
/// ```
pub fn ScalableVectorType::get_context(self : ScalableVectorType) -> Context {
  self.ty.get_context()
}

///|
pub impl Show for ScalableVectorType with output(
  self : ScalableVectorType,
  logger : &Logger
) -> Unit {
  logger.write_string(self.ty.to_string())
}
