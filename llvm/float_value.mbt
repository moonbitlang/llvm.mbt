// ============================================
// FloatValue
// ============================================

///| A `FloatValue` is a value that represents a floating point number.
pub struct FloatValue {
  value : ValueRef
}

///| Get a value from an `@unsafe.LLVMValueRef`.
///
/// **unsafe**: Undefined behavior if `value_ref` is not a `FloatValue`.
pub fn FloatValue::new(value_ref : @unsafe.LLVMValueRef) -> FloatValue {
  guard value_ref.is_not_null()
  FloatValue::{ value: ValueRef::new(value_ref) }
}

pub impl Value for FloatValue with base(self) {
  self.value
}

pub impl Value for FloatValue with as_value_enum(self) {
  FloatValue(self)
}

pub impl BasicValue for FloatValue with as_basic_value_enum(self) {
  FloatValue(self)
}

///| Gets name of the `FloatValue`.
/// If the value is a constant, this will return an empty string.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let lmodule = context.create_module("demo")
/// let f64_ty = context.f64_type()
/// let fty = f64_ty.fn_type([f64_ty])
/// let fval = lmodule.add_function("foo", fty)
/// let one = f64_ty.const_float(1.0)
///
/// let bb = context.append_basic_block(fval, name="entry")
/// let builder = context.create_builder()
/// builder.position_at_end(bb)
///
/// guard fval.get_nth_param(0).unwrap().as_basic_value_enum() is FloatValue(x)
/// let xp1 = builder.build_float_add(x, one, name="xp1")
///
/// inspect(xp1.get_name(), content="xp1")
/// ```
pub fn FloatValue::get_name(self : FloatValue) -> String {
  self.value.get_name()
}

///| Set name of the `FloatValue`.
///
/// If the value is constant, `set_name` will not have any effect.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let lmodule = context.create_module("demo")
/// let f64_ty = context.f64_type()
/// let fty = f64_ty.fn_type([f64_ty])
/// let fval = lmodule.add_function("foo", fty)
/// let one = f64_ty.const_float(1.0)
///
/// let bb = context.append_basic_block(fval, name="entry")
/// let builder = context.create_builder()
/// builder.position_at_end(bb)
///
/// guard fval.get_nth_param(0).unwrap().as_basic_value_enum() is FloatValue(x)
/// let xp1 = builder.build_float_add(x, one)
///
/// xp1.set_name("xp1")
/// inspect(xp1.get_name(), content="xp1")
/// ```
pub fn FloatValue::set_name(self : FloatValue, name : String) -> Unit {
  self.value.set_name(name)
}

///| Gets the type of the `FloatValue`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f32_type = context.f32_type();
/// let pi = f32_type.const_float(3.14);
/// inspect(pi.get_type(), content="float");
/// ```
pub fn FloatValue::get_type(self : FloatValue) -> FloatType {
  FloatType::new(self.value.get_type().inner())
}

///| Returns whether or not the `FloatValue` is null.
pub fn FloatValue::is_null(self : FloatValue) -> Bool {
  self.value.is_null()
}

///| Returns whether or not the `FloatValue` is undefined.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let undef = f64_type.get_undef();
/// assert_true(undef.is_undef());
/// ```
pub fn FloatValue::is_undef(self : FloatValue) -> Bool {
  self.value.is_undef()
}

///|
pub fn FloatValue::as_instruction(self : FloatValue) -> InstructionValue? {
  self.value.as_instruction()
}

// -----------------------
// TODO: const ops: add, sub, mul ...
// -----------------------
// pub fn FloatValue::const_compare(self: FloatValue, op: FloatPredicate, rhs: FloatValue) -> IntValue {
//   IntValue::new(@unsafe.llvm_const_fcmp(op.into(). self.inner(), rhs.inner())
// }

///| Determines whether or not a `FloatValue` is a constant.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let f64_val = f64_type.const_float(1.2);
/// assert_true(f64_val.is_const());
/// ```
pub fn FloatValue::is_const(self : FloatValue) -> Bool {
  self.value.is_const()
}

// TODO: need to check when lossy info is true

///| Obtains a constant `FloatValue`'s value and whether or not it lost info.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let pi = f64_type.const_float(3.14);
///
/// inspect(pi.get_constant(), content="Some((3.14, false))");
/// ```
pub fn FloatValue::get_constant(self : FloatValue) -> (Double, Bool)? {
  if not(self.is_const()) {
    return None
  }
  let (v, lossy) = @unsafe.llvm_const_real_get_double(self.inner())
  Some((v, lossy))
}

///| Replaces all uses of a `FloatValue` with another `FloatValue`.
pub fn FloatValue::replace_all_uses_with(
  self : FloatValue,
  new_value : FloatValue
) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///|
pub impl Show for FloatValue with output(self : FloatValue, logger : &Logger) -> Unit {
  logger.write_string(self.value.to_string())
}
