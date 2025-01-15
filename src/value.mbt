// Values
pub struct Value {
  value: LLVMValueRef
}

pub fn Value::new(value_ref: LLVMValueRef) -> Value {
  if llvm_is_null(value_ref) == 1 {
    println("Value is null")
    panic()
  }

  Value::{
    value: value_ref
  }
}

pub fn is_null(self: Value) -> Bool {
  llvm_is_null(self.value) == 1
}

pub fn is_const(self: Value) -> Bool {
  llvm_is_const(self.value) == 1
}

pub fn set_name(self: Value, name: String) -> Unit {
  let cname = moonbit_str_to_c_str(name)
  llvm_set_value_name(self.value, cname, name.length().reinterpret_as_uint())
}

pub fn to_string(self: Value) -> String {
  let c_str = llvm_print_value_to_string(self.value)
  c_str_to_moonbit_str(c_str)
}

pub fn dump(self: Value) -> Unit {
  llvm_dump_value(self.value)
}

pub struct IntValue {
  value: Value
}

pub fn IntValue::new(value_ref: LLVMValueRef) -> IntValue {
  assert_not(value_ref.is_null().to_moonbit_bool())

  IntValue::{
    value: Value::new(value_ref)
  }
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
