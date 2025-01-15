// Values
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

pub fn is_null(self: Value) -> Bool {
  llvm_is_null(self.as_value_ref()) == 1
}

pub fn is_const(self: Value) -> Bool {
  llvm_is_const(self.as_value_ref()) == 1
}

pub fn set_name(self: Value, name: String) -> Unit {
  let cname = moonbit_str_to_c_str(name)
  let value_ref = self.as_value_ref()
  let name_len = name.length().reinterpret_as_uint()
  llvm_set_value_name(value_ref, cname, name_len)
}

pub fn to_string(self: Value) -> String {
  let c_str = llvm_print_value_to_string(self.as_value_ref())
  c_str_to_moonbit_str(c_str)
}

pub fn dump(self: Value) -> Unit {
  llvm_dump_value(self.as_value_ref())
}

// IntValue
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

pub fn set_name(self: IntValue, name: String) -> Unit {
  self.value.set_name(name)
}

pub fn to_string(self: IntValue) -> String {
  self.value.to_string()
}

pub fn dump(self: IntValue) -> Unit {
  self.value.dump()
}

// FunctionValue
pub struct FunctionValue {
  value: Value
}

pub fn FunctionValue::new(value_ref: LLVMValueRef) -> FunctionValue {
  assert_not(value_ref.is_null().to_moonbit_bool())

  FunctionValue::{
    value: Value::new(value_ref)
  }
}

impl ValueRef for FunctionValue with as_value_ref(self: FunctionValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub fn set_name(self: FunctionValue, name: String) -> Unit {
  self.value.set_name(name)
}

pub fn to_string(self: FunctionValue) -> String {
  self.value.to_string()
}

pub fn dump(self: FunctionValue) -> Unit {
  self.value.dump()
}
