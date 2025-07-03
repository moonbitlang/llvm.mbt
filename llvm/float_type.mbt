// ==============================================
// FloatType
// ==============================================

///| A `FloatType` is the type of a floating point constant or variable.
pub struct FloatType {
  ty : TypeRef
}

///| Create `FloatType` from `@unsafe.LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not float type.
pub fn FloatType::new(type_ref : @unsafe.LLVMTypeRef) -> FloatType {
  guard type_ref.is_not_null()
  FloatType::{ ty: TypeRef::new(type_ref) }
}

pub impl Type for FloatType with base(self) {
  self.ty
}

pub impl Type for FloatType with as_type_enum(self) {
  FloatType(self)
}

pub impl BasicType for FloatType with as_basic_type_enum(self) {
  FloatType(self)
}

// use get_kind to check if it is float type
// pub fn FloatType::safe_new(type_ref: @unsafe.LLVMTypeRef) -> Option[FloatType];


///| Creates a constant `FloatValue` of this `FloatType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f32_type = context.f32_type();
/// let i32_type = context.i32_type();
/// let fn_val = f32_type.fn_type([i32_type]);
/// inspect(fn_val, content="float (i32)")
/// ```
pub fn FloatType::fn_type(
  self : FloatType,
  param_types : Array[&BasicType],
  is_var_arg~ : Bool = false
) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg~)
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
/// inspect(pi, content="double 0x400921FB4D12D84A")
/// ```
pub fn FloatType::const_float(self : FloatType, val : Double) -> FloatValue {
  let val_ref = @unsafe.llvm_const_real(self.inner(), val)
  FloatValue::new(val_ref)
}

// FIXME: untested

///|
pub fn FloatType::const_float_from_string(
  self : FloatType,
  slice : String
) -> FloatValue {
  if slice.is_empty() {
    abort("Float string is empty")
  }

  // TODO: use `@unsafe.llvm_const_real_of_string` instead
  let r = @unsafe.llvm_const_real_of_string_and_size(self.inner(), slice)
  FloatValue::new(r)
}

///| Creates a constant zero value of this `FloatType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let f64_zero = f64_type.const_zero();
/// inspect(f64_zero, content="double 0.000000e+00")
/// ```
pub fn FloatType::const_zero(self : FloatType) -> FloatValue {
  FloatValue::new(self.ty.const_zero())
}



///| Returns whether this `FloatType` is sized. **Always returns `true`.**
pub fn FloatType::is_sized(self : FloatType) -> Bool {
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
/// inspect(f64_align, content=expect)
/// ```
pub fn FloatType::get_alignment(self : FloatType) -> IntValue {
  self.ty.get_alignment()
}

///| Gets a reference to the `Context` this `FloatType` was created in.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let f64_ctx = f64_type.get_context();
/// assert_true(context == f64_ctx);
/// ```
pub fn FloatType::get_context(self : FloatType) -> Context {
  self.ty.get_context()
}

///| Creates an undefined instance of a `FloatType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let f64_undef = f64_type.get_undef();
/// inspect(f64_undef, content="double undef")
/// ```
pub fn get_undef(self : FloatType) -> FloatValue {
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
/// inspect(f64_poison, content="double poison")
/// ```
pub fn get_poison(self : FloatType) -> FloatValue {
  FloatValue::new(self.ty.get_poison())
}

// pub fn FloatType::create_generic_value(self: FloatType, value: Double) -> GenericValue {
//   let gv = @unsafe.llvm_create_generic_value_of_float(self.inner(), value)
//   GenericValue::new(gv)
// }

///|
pub fn FloatType::const_array(
  self : FloatType,
  values : Array[FloatValue]
) -> ArrayValue {
  let values = values.map(v => v as &Value)
  ArrayValue::new_const_array(self, values)
}

///|
pub impl Show for FloatType with output(self : FloatType, logger : &Logger) -> Unit {
  logger.write_string(self.ty.to_string())
}
