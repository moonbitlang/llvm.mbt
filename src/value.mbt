// ===================================
// Values
// ===================================
pub struct Value {
  value_ref: LLVMValueRef
}

trait ValueRef {
  as_value_ref(Self) -> LLVMValueRef;
}

pub fn Value::new(value_ref: LLVMValueRef) -> Value {
  if llvm_is_null(value_ref) == 1 {
    println("Value is null")
    panic()
  }

  Value::{
    value_ref
  }
}

impl ValueRef for Value with as_value_ref(self: Value) -> LLVMValueRef {
  self.value_ref
}

// pub fn Value::is_instruction(self: Value) -> Bool;
// pub fn Value::as_instruction(self: Value) -> InstructionValue;

pub fn Value::is_null(self: Value) -> Bool {
  llvm_is_null(self.as_value_ref()) == 1
}

pub fn Value::is_const(self: Value) -> Bool {
  llvm_is_const(self.as_value_ref()) == 1
}

pub fn Value::set_name(self: Value, name: String) -> Unit {
  let cname = moonbit_str_to_c_str(name)
  let value_ref = self.as_value_ref()
  let name_len = name.length().reinterpret_as_uint()
  llvm_set_value_name(value_ref, cname, name_len)
}

// TODO: This API use `LLVMGetValueName2` possibly problematic
pub fn Value::get_name(self: Value) -> String {
  let c_str = llvm_get_value_name(self.as_value_ref())
  c_str_to_moonbit_str(c_str)
}

fn Value::is_undef(self: Value) -> Bool {
  llvm_is_undef(self.as_value_ref()) == 1
}

fn Value::get_type(self: Value) -> Type {
  let type_ref = llvm_type_of(self.as_value_ref())
  Type::new(type_ref)
}

fn Value::replace_all_uses_with(self: Value, new_value: Value) -> Unit {
  llvm_replace_all_uses_with(self.as_value_ref(), new_value.as_value_ref())
}

// pub fn Value::get_first_use(self: Value) -> BasicValueUse? {
//   let use_ = llvm_get_first_use(self.as_value_ref())
//
//   if use_.is_null() {
//     None
//   }
//
//   Some(BasicValueUse::new(use_))
// }

// pub fn get_section(self: Value) -> String?
// pub fn set_section(self: Value) -> String?

pub fn Value::to_string(self: Value) -> String {
  let c_str = llvm_print_value_to_string(self.as_value_ref())
  c_str_to_moonbit_str(c_str)
}

pub fn Value::dump(self: Value) -> Unit {
  llvm_dump_value(self.as_value_ref())
}

// =========================================
// IntValue
// =========================================
pub struct IntValue {
  value: Value
}

pub fn IntValue::new(value_ref: LLVMValueRef) -> IntValue {
  assert_not(value_ref.is_null().to_moonbit_bool())

  IntValue::{
    value: Value::new(value_ref)
  }
}

pub impl ValueRef for IntValue with as_value_ref(self: IntValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub fn IntValue::get_name(self: IntValue) -> String {
  self.value.get_name()
}

pub fn IntValue::set_name(self: IntValue, name: String) -> Unit {
  self.value.set_name(name)
}

// TODO: inconsistant with `inkwell`
// pub fn IntValue::get_type(self: IntValue) -> Type {
//   self.value.get_type()
// }

pub fn IntValue::is_null(self: IntValue) -> Bool {
  self.value.is_null()
}

pub fn IntValue::is_undef(self: IntValue) -> Bool {
  self.value.is_undef()
}

// pub fn as_instruction(self: IntValue) -> InstructionValue?

pub fn IntValue::const_not(self: IntValue) -> IntValue {
  let value_ref = llvm_const_not(self.as_value_ref())
  IntValue::new(value_ref)
}

pub fn IntValue::const_neg(self: IntValue) -> IntValue {
  let value_ref = llvm_const_neg(self.as_value_ref())
  IntValue::new(value_ref)
}

pub fn IntValue::const_nsw_neg(self: IntValue) -> IntValue {
  let value_ref = llvm_const_nsw_neg(self.as_value_ref())
  IntValue::new(value_ref)
}

// NOTE: use LLVMConstNull
// pub fn IntValue::const_nuw_neg(self: IntValue) -> IntValue {
//   let value_ref = llvm_const_nuw_neg(self.as_value_ref())
//   IntValue::new(value_ref)
// }

pub fn IntValue::const_add(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_add(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

pub fn IntValue::const_nsw_add(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_nsw_add(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

pub fn IntValue::const_nuw_add(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_nuw_add(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

pub fn IntValue::const_sub(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_sub(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

pub fn IntValue::const_nsw_sub(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_nsw_sub(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

pub fn IntValue::const_nuw_sub(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_nuw_sub(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

pub fn IntValue::const_mul(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_mul(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

pub fn IntValue::const_nsw_mul(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_nsw_mul(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

pub fn IntValue::const_nuw_mul(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_nuw_mul(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

// pub fn IntValue::const_and(self: IntValue, rhs: IntValue) -> IntValue {
//   let value_ref = llvm_const_and(self.as_value_ref(), rhs.as_value_ref())
//   IntValue::new(value_ref)
// }
//
// pub fn IntValue::const_or(self: IntValue, rhs: IntValue) -> IntValue {
//   let value_ref = llvm_const_or(self.as_value_ref(), rhs.as_value_ref())
//   IntValue::new(value_ref)
// }

pub fn IntValue::const_xor(self: IntValue, rhs: IntValue) -> IntValue {
  let value_ref = llvm_const_xor(self.as_value_ref(), rhs.as_value_ref())
  IntValue::new(value_ref)
}

// const_cast
// const_shl
// const_rshr
// const_ashr
// const_unsigned_to_float
// const_signed_to_float
pub fn IntValue::const_to_pointer(self: IntValue, ptr_type: PointerType) -> PointerValue {
  PointerValue::new(llvm_const_int_to_ptr(self.as_value_ref(), ptr_type.as_type_ref()))
}

pub fn IntValue::const_truncate(self: IntValue, int_type: IntType) -> IntValue {
  IntValue::new(llvm_const_trunc(self.as_value_ref(), int_type.as_type_ref()))
}
pub fn IntValue::const_truncate_or_bit_cast(self: IntValue, int_type: IntType) -> IntValue {
  IntValue::new(llvm_const_trunc_or_bit_cast(self.as_value_ref(), int_type.as_type_ref()))
}
pub fn IntValue::const_bit_cast(self: IntValue, int_tyep: IntType) -> IntValue {
  IntValue::new(llvm_const_bit_cast(self.as_value_ref(), int_tyep.as_type_ref()))
}
// const_int_compare

pub fn IntValue::is_const(self: IntValue) -> Bool {
  self.value.is_const()
}

pub fn IntValue::is_constant_int(self: IntValue) -> Bool {
  llvm_isa_constant_int(self.as_value_ref()).is_null().to_moonbit_bool()
}

pub fn replace_all_uses_with(self: IntValue, new_value: IntValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

pub fn IntValue::to_string(self: IntValue) -> String {
  self.value.to_string()
}

pub fn IntValue::dump(self: IntValue) -> Unit {
  self.value.dump()
}

// ============================================
// FloatValue
// ============================================
pub struct FloatValue {
  value: Value
}

pub fn FloatValue::new(value_ref: LLVMValueRef) -> FloatValue {
  assert_not(value_ref.is_null().to_moonbit_bool())

  FloatValue::{
    value: Value::new(value_ref)
  }
}

pub fn FloatValue::get_name(self: FloatValue) -> String {
  self.value.get_name()
}

pub fn FloatValue::set_name(self: FloatValue, name: String) -> Unit {
  self.value.set_name(name)
}

// pub fn get_type(self: FloatValue) -> Type {
//   self.value.get_type()
// }

pub fn FloatValue::is_null(self: FloatValue) -> Bool {
  self.value.is_null()
}

pub fn FloatValue::is_undef(self: FloatValue) -> Bool {
  self.value.is_undef()
}

// -----------------------
// TODO: const ops: add, sub, mul ...
// -----------------------

// pub fn FloatValue::const_compare(self: FloatValue, op: FloatPredicate, rhs: FloatValue) -> IntValue {
//   IntValue::new(llvm_const_fcmp(op.into(). self.as_value_ref(), rhs.as_value_ref())
// }

pub fn FloatValue::is_const(self: FloatValue) -> Bool {
  self.value.is_const()
}

pub fn FloatValue::replace_all_uses_with(self: FloatValue, new_value: FloatValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

pub fn FloatValue::to_string(self: FloatValue) -> String {
  self.value.to_string()
}

pub fn FloatValue::dump(self: FloatValue) -> Unit {
  self.value.dump()
}

// ============================================
// PointerValue
// ============================================
pub struct PointerValue {
  value: Value
}

pub fn PointerValue::new(value_ref: LLVMValueRef) -> PointerValue {
  assert_not(value_ref.is_null().to_moonbit_bool())

  PointerValue::{
    value: Value::new(value_ref)
  }
}

pub impl ValueRef for PointerValue with as_value_ref(self: PointerValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub fn PointerValue::get_name(self: PointerValue) -> String {
  self.value.get_name()
}

pub fn PointerValue::set_name(self: PointerValue, name: String) -> Unit {
  self.value.set_name(name)
}

// pub fn get_type(self: PointerValue) -> Type {
//   self.value.get_type()
// }

pub fn PointerValue::is_null(self: PointerValue) -> Bool {
  self.value.is_null()
}

pub fn PointerValue::is_undef(self: PointerValue) -> Bool {
  self.value.is_undef()
}

pub fn PointerValue::is_const(self: PointerValue) -> Bool {
  self.value.is_const()
}

// pub fn as_instruction(self: PointerValue) -> InstructionValue?
// pub fn const_gep
// pub fn const_in_bounds_gep

pub fn PointerValue::const_to_int(self: PointerValue, int_type: IntType) -> IntValue {
  IntValue::new(llvm_const_ptr_to_int(self.as_value_ref(), int_type.as_type_ref()))
}

pub fn PointerValue::const_cast(self: PointerValue, ptr_type: PointerType) -> PointerValue {
  PointerValue::new(llvm_const_pointer_cast(self.as_value_ref(), ptr_type.as_type_ref()))
}

pub fn const_address_space_cast(self: PointerValue, ptr_type: PointerType) -> PointerValue {
  PointerValue::new(llvm_const_addr_space_cast(self.as_value_ref(), ptr_type.as_type_ref()))
}

pub fn PointerValue::replace_all_uses_with(self: PointerValue, new_value: PointerValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

pub fn PointerValue::dump(self: PointerValue) -> Unit {
  self.value.dump()
}

// ============================================
// FunctionValue
// ============================================
pub struct FunctionValue {
  value: Value
}

pub fn FunctionValue::new(value_ref: LLVMValueRef) -> FunctionValue {
  assert_not(value_ref.is_null().to_moonbit_bool())

  FunctionValue::{
    value: Value::new(value_ref)
  }
}

impl ValueRef for FunctionValue with as_value_ref(
  self: FunctionValue
) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub fn FunctionValue::set_name(self: FunctionValue, name: String) -> Unit {
  self.value.set_name(name)
}

pub fn FunctionValue::to_string(self: FunctionValue) -> String {
  self.value.to_string()
}

pub fn FunctionValue::dump(self: FunctionValue) -> Unit {
  self.value.dump()
}
