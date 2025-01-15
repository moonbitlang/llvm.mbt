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

