// =========================================
// IntValue
// =========================================

///| An `IntValue` is a value that represents an integer.
pub struct IntValue {
  value : ValueRef
}

///| Get a value from an `@unsafe.LLVMValueRef`.
///
/// **unsafe**: Undefined behavior if `value_ref` is not an `IntValue`.
pub fn IntValue::new(value_ref : @unsafe.LLVMValueRef) -> IntValue {
  guard value_ref.is_not_null()
  IntValue::{ value: ValueRef::new(value_ref) }
}

pub impl Value for IntValue with base(self) {
  self.value
}

pub impl Value for IntValue with as_value_enum(self) {
  IntValue(self)
}

pub impl BasicValue for IntValue with as_basic_value_enum(self) {
  IntValue(self)
}

///| Gets the name of an `IntValue`.
/// If the value is a constant, this will return an empty string.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let lmodule = context.create_module("demo")
/// let i32_ty = context.i32_type()
/// let fty = i32_ty.fn_type([i32_ty])
/// let fval = lmodule.add_function("foo", fty)
/// let one = i32_ty.const_int(1)
///
/// let bb = context.append_basic_block(fval, name="entry")
/// let builder = context.create_builder()
/// builder.position_at_end(bb)
///
/// guard fval.get_nth_param(0).unwrap().as_basic_value_enum() is IntValue(x)
/// let xp1 = builder.build_int_add(x, one, name="xp1")
///
/// inspect(xp1.get_name(), content="xp1")
/// ```
pub fn IntValue::get_name(self : IntValue) -> String {
  self.value.get_name()
}

///| Set name of the `IntValue`.
///
/// If the value is constant, `set_name` will not have any effect.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let lmodule = context.create_module("demo")
/// let i32_ty = context.i32_type()
/// let fty = i32_ty.fn_type([i32_ty])
/// let fval = lmodule.add_function("foo", fty)
/// let one = i32_ty.const_int(1)
///
/// let bb = context.append_basic_block(fval, name="entry")
/// let builder = context.create_builder()
/// builder.position_at_end(bb)
///
/// guard fval.get_nth_param(0).unwrap().as_basic_value_enum() is IntValue(x)
/// let xp1 = builder.build_int_add(x, one)
///
/// xp1.set_name("xp1")
/// inspect(xp1.get_name(), content="xp1")
/// ```
pub fn IntValue::set_name(self : IntValue, name : String) -> Unit {
  self.value.set_name(name)
}

///| Gets the type of an `IntValue`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i32_val = i32_type.const_int(42);
/// inspect(i32_val.get_type(), content="i32");
/// ```
pub fn IntValue::get_type(self : IntValue) -> IntType {
  IntType::new(self.value.get_type().inner())
}

///| Returns whether or not the `IntValue` is null.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i32_val = i32_type.const_int(42);
/// assert_false(i32_val.is_null());
/// ```
pub fn IntValue::is_null(self : IntValue) -> Bool {
  self.value.is_null()
}

///| Returns whether or not the `IntValue` is undefined.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i32_val = i32_type.const_int(42);
/// let undef_v = i32_type.get_undef();
/// let poison = i32_type.get_poison();
///
/// assert_false(i32_val.is_null());
/// assert_true(undef_v.is_undef());
/// assert_true(poison.is_undef());
/// ```
pub fn IntValue::is_undef(self : IntValue) -> Bool {
  self.value.is_undef()
}

///| Converts the `IntValue` into an `InstructionValue` if it is an instruction.
/// If it is not an instruction, `None` is returned.
pub fn IntValue::as_instruction(self : IntValue) -> InstructionValue? {
  self.value.as_instruction()
}

///| Returns the not of the constant `IntValue`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let forty_two = i32_type.const_int(42);
/// inspect(forty_two.const_not(), content="i32 -43");
/// ```
pub fn IntValue::const_not(self : IntValue) -> IntValue {
  @unsafe.llvm_const_not(self.inner()) |> IntValue::new
}

///| Returns the negation of the constant `IntValue`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let forty_two = i32_type.const_int(42);
/// inspect(forty_two.const_neg(), content="i32 -42");
/// ```
pub fn IntValue::const_neg(self : IntValue) -> IntValue {
  @unsafe.llvm_const_neg(self.inner()) |> IntValue::new
}

///| Returns the negation of the constant `IntValue` with NSW flag.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let forty_two = i32_type.const_int(42);
/// inspect(forty_two.const_nsw_neg(), content="i32 -42");
/// ```
pub fn IntValue::const_nsw_neg(self : IntValue) -> IntValue {
  @unsafe.llvm_const_nsw_neg(self.inner()) |> IntValue::new
}

// NOTE: use @unsafe.LLVMConstNull
// pub fn IntValue::const_nuw_neg(self: IntValue) -> IntValue {
//   let value_ref = @unsafe.llvm_const_nuw_neg(self.inner())
//   IntValue::new(value_ref)
// }

///| Returns the addition of two constant `IntValue`s.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let forty_two = i32_type.const_int(42);
/// let thirty_tri = i32_type.const_int(33);
/// inspect(forty_two.const_add(thirty_tri), content="i32 75");
/// ```
pub fn IntValue::const_add(self : IntValue, rhs : IntValue) -> IntValue {
  @unsafe.llvm_const_add(self.inner(), rhs.inner())
  |> IntValue::new
}

///| Returns the addition of two constant `IntValue`s with NSW flag.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let forty_two = i32_type.const_int(42);
/// let thirty_tri = i32_type.const_int(33);
/// inspect(forty_two.const_nsw_add(thirty_tri), content="i32 75");
/// ```
pub fn IntValue::const_nsw_add(self : IntValue, rhs : IntValue) -> IntValue {
  @unsafe.llvm_const_nsw_add(self.inner(), rhs.inner())
  |> IntValue::new
}

///| Returns the addition of two constant `IntValue`s with NUW flag.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let forty_two = i32_type.const_int(42);
/// let thirty_tri = i32_type.const_int(33);
/// inspect(forty_two.const_nuw_add(thirty_tri), content="i32 75");
/// ```
pub fn IntValue::const_nuw_add(self : IntValue, rhs : IntValue) -> IntValue {
  @unsafe.llvm_const_nuw_add(self.inner(), rhs.inner())
  |> IntValue::new
}

///| Returns the subtraction of two constant `IntValue`s.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let forty_two = i32_type.const_int(42);
/// let thirty_tri = i32_type.const_int(33);
/// inspect(forty_two.const_sub(thirty_tri), content="i32 9");
/// ```
pub fn IntValue::const_sub(self : IntValue, rhs : IntValue) -> IntValue {
  @unsafe.llvm_const_sub(self.inner(), rhs.inner())
  |> IntValue::new
}

///| Returns the subtraction of two constant `IntValue`s with NSW flag.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let forty_two = i32_type.const_int(42);
/// let thirty_tri = i32_type.const_int(33);
/// inspect(forty_two.const_nsw_sub(thirty_tri), content="i32 9");
/// ```
pub fn IntValue::const_nsw_sub(self : IntValue, rhs : IntValue) -> IntValue {
  @unsafe.llvm_const_nsw_sub(self.inner(), rhs.inner())
  |> IntValue::new
}

///| Returns the subtraction of two constant `IntValue`s with NUW flag.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let forty_two = i32_type.const_int(42);
/// let thirty_tri = i32_type.const_int(33);
/// inspect(forty_two.const_nuw_sub(thirty_tri), content="i32 9");
/// ```
pub fn IntValue::const_nuw_sub(self : IntValue, rhs : IntValue) -> IntValue {
  @unsafe.llvm_const_nuw_sub(self.inner(), rhs.inner())
  |> IntValue::new
}

///| Returns the multiplication of two constant `IntValue`s.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let forty_two = i32_type.const_int(42);
/// let thirty_tri = i32_type.const_int(33);
/// inspect(forty_two.const_mul(thirty_tri), content="i32 1386");
/// ```
pub fn IntValue::const_mul(self : IntValue, rhs : IntValue) -> IntValue {
  @unsafe.llvm_const_mul(self.inner(), rhs.inner())
  |> IntValue::new
}

///| Returns the multiplication of two constant `IntValue`s with NSW flag.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let forty_two = i32_type.const_int(42);
/// let thirty_tri = i32_type.const_int(33);
/// inspect(forty_two.const_nsw_mul(thirty_tri), content="i32 1386");
/// ```
pub fn IntValue::const_nsw_mul(self : IntValue, rhs : IntValue) -> IntValue {
  @unsafe.llvm_const_nsw_mul(self.inner(), rhs.inner())
  |> IntValue::new
}

///| Returns the multiplication of two constant `IntValue`s with NUW flag.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let forty_two = i32_type.const_int(42);
/// let thirty_tri = i32_type.const_int(33);
/// inspect(forty_two.const_nuw_mul(thirty_tri), content="i32 1386");
/// ```
pub fn IntValue::const_nuw_mul(self : IntValue, rhs : IntValue) -> IntValue {
  @unsafe.llvm_const_nuw_mul(self.inner(), rhs.inner())
  |> IntValue::new
}

// LLVM-19 didn't provide the following
// pub fn IntValue::const_and(self: IntValue, rhs: IntValue) -> IntValue {
//   let value_ref = @unsafe.llvm_const_and(self.inner(), rhs.inner())
//   IntValue::new(value_ref)
// }
//
// pub fn IntValue::const_or(self: IntValue, rhs: IntValue) -> IntValue {
//   let value_ref = @unsafe.llvm_const_or(self.inner(), rhs.inner())
//   IntValue::new(value_ref)
// }

///| Returns the XOR of two constant `IntValue`s.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let forty_two = i32_type.const_int(42);
/// let thirty_tri = i32_type.const_int(33);
/// inspect(forty_two.const_xor(thirty_tri), content="i32 11");
/// ```
pub fn IntValue::const_xor(self : IntValue, rhs : IntValue) -> IntValue {
  @unsafe.llvm_const_xor(self.inner(), rhs.inner())
  |> IntValue::new
}

// const_cast
// const_shl
// const_rshr
// const_ashr
// const_unsigned_to_float
// const_signed_to_float

///|
pub fn IntValue::const_to_pointer(
  self : IntValue,
  ptr_type : PointerType
) -> PointerValue {
  @unsafe.llvm_const_int_to_ptr(self.inner(), ptr_type.inner())
  |> PointerValue::new
}

///| Returns the truncation of a constant `IntValue` to another `IntType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i16_type = context.i16_type();
/// let max_u16p2 = i32_type.const_int(0x10001);
/// inspect(max_u16p2.const_truncate(i16_type), content="i16 1");
/// ```
pub fn IntValue::const_truncate(
  self : IntValue,
  int_type : IntType
) -> IntValue {
  @unsafe.llvm_const_trunc(self.inner(), int_type.inner())
  |> IntValue::new
}

///|
pub fn IntValue::const_truncate_or_bit_cast(
  self : IntValue,
  int_type : IntType
) -> IntValue {
  @unsafe.llvm_const_trunc_or_bit_cast(
    self.inner(),
    int_type.inner(),
  )
  |> IntValue::new
}

///|
pub fn IntValue::const_bit_cast(
  self : IntValue,
  int_type : IntType
) -> IntValue {
  @unsafe.llvm_const_bit_cast(self.inner(), int_type.inner())
  |> IntValue::new
}

// llvm-19 didn't provide LLVMConstICmp
// pub fn IntValue::const_int_compare

///| Determines whether or not an `IntValue` is an `llvm::Constant`.
///
/// Constants includes values that are not known at compile time, for
/// example the address of a function casted to an integer.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i64_type = context.i64_type();
/// let i64_val = i64_type.const_int(42);
/// assert_true(i64_val.is_const());
/// ```
pub fn IntValue::is_const(self : IntValue) -> Bool {
  self.value.is_const()
}

///| Determines whether or not an `IntValue` is an `llvm::ConstantInt`.
///
/// ConstantInt only includes values that are known at compile time.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i64_type = context.i64_type();
/// let i64_val = i64_type.const_int(42);
/// assert_true(i64_val.is_constant_int());
/// ```
pub fn IntValue::is_constant_int(self : IntValue) -> Bool {
  @unsafe.llvm_isa_constant_int(self.inner()).is_null() |> not
}

///| Obtains a constant `IntValue`'s zero extended value.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i8_type = context.i8_type();
/// let i8_all_ones = i8_type.const_all_ones();
///
/// inspect(i8_all_ones.get_zero_extended_constant(), content="Some(255)");
/// ```
pub fn IntValue::get_zero_extended_constant(self : IntValue) -> UInt64? {
  if not(self.is_constant_int()) {
    return None
  }
  if self.get_type().get_bit_width() > 64 {
    return None
  }
  @unsafe.llvm_const_int_get_z_ext_value(self.inner()) |> Some
}

///| Obtains a constant `IntValue`'s zero extended value.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i8_type = context.i8_type();
/// let i8_all_ones = i8_type.const_all_ones();
///
/// inspect(i8_all_ones.get_sign_extended_constant(), content="Some(-1)");
/// ```
///
// RIVEW: Would the following implementation better?
// @option.when(
//   self.is_constant_int() && self.get_type().get_bit_width() <= 64,
//   fn () {
//     @unsafe.llvm_const_int_get_s_ext_value(self.inner())
//   }
// )
pub fn IntValue::get_sign_extended_constant(self : IntValue) -> Int64? {
  if not(self.is_constant_int()) {
    return None
  }
  if self.get_type().get_bit_width() > 64 {
    return None
  }
  @unsafe.llvm_const_int_get_s_ext_value(self.inner()) |> Some
}

///| Replaces all uses of an `IntValue` with another `IntValue`.
pub fn IntValue::replace_all_uses_with(
  self : IntValue,
  new_value : IntValue
) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///|
pub impl Show for IntValue with output(self : IntValue, logger : &Logger) -> Unit {
  logger.write_string(self.value.to_string())
}
