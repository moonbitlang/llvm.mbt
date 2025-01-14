// Utils
type CStr

fn to_moonbit_bool(self: LLVMBool) -> Bool {
  if self == 0 {
    false
  } else {
    true
  }
}

fn to_llvm_bool(b: Bool) -> LLVMBool {
  if b {
    1
  } else {
    0
  }
}

// fn assert(cond: Bool) -> Unit {
//   if cond == false {
//     panic()
//   }
// }

fn assert_not(cond: Bool) -> Unit {
  if cond == true {
    panic()
  }
}

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

// Types
pub struct Type {
  ty: LLVMTypeRef
}

pub fn Type::new(type_ref: LLVMTypeRef) -> Type {
  if type_ref.is_null().to_moonbit_bool() {
    println("Type is null")
    panic()
  }

  Type::{
    ty: type_ref
  }
}

pub fn to_string(self: Type) -> String {
  let c_str = llvm_print_type_to_string(self.ty)
  c_str_to_moonbit_str(c_str)
}

pub fn dump(self: Type) -> Unit {
  llvm_dump_type(self.ty)
}

// IntType
pub struct IntType {
  int_type: Type
}

pub fn as_type_ref(self: IntType) -> LLVMTypeRef {
  self.int_type.ty
}

pub fn IntType::new(type_ref: LLVMTypeRef) -> IntType {
  assert_not(type_ref.is_null().to_moonbit_bool())

  IntType::{
    int_type: Type::new(type_ref)
  }
}

// TODO: Maybe better explain signextension
pub fn const_int(self: IntType, val: UInt64, sign_extend: Bool) -> IntValue {
  let llvm_val_ref = llvm_const_int(self.as_type_ref(), val, to_llvm_bool(sign_extend))
  IntValue::new(llvm_val_ref)
}

// Context
struct Context {
  context: LLVMContextRef
}

pub fn Context::create() -> Context {
  Context :: {
    context: llvm_context_create()
  }
}

pub fn i32_type(self: Context) -> IntType {
  let type_ref = llvm_int32_type_in_context(self.context)
  IntType::new(type_ref)
}
