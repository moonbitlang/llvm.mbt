// Types
pub struct Type {
  type_ref: LLVMTypeRef
}

trait TypeRef {
  as_type_ref(Self) -> LLVMTypeRef
}

pub fn Type::new(type_ref: LLVMTypeRef) -> Type {
  if type_ref.is_null().to_moonbit_bool() {
    println("Type is null")
    panic()
  }

  Type::{
    type_ref
  }
}

pub impl TypeRef for Type with as_type_ref(self: Type) -> LLVMTypeRef {
  self.type_ref
}

// TODO: use `prarm_types: Array[&TyepRef]` after compiler bug fixed
pub fn fn_type(
  self: Type,
  param_types: Array[LLVMTypeRef],
  is_var_arg: Bool
) -> FunctionType {
  let ret_ty = self.as_type_ref()
  let param_len = param_types.length().reinterpret_as_uint()
  // let type_refs = param_types.map(fn (t) {t.as_type_ref()})
  let type_refs = param_types
  let is_var_arg = to_llvm_bool(is_var_arg)
  let fty_ref = llvm_function_type(ret_ty, type_refs, param_len, is_var_arg)
  FunctionType::new(fty_ref)
}

pub fn to_string(self: Type) -> String {
  let c_str = llvm_print_type_to_string(self.as_type_ref())
  c_str_to_moonbit_str(c_str)
}

pub fn dump(self: Type) -> Unit {
  llvm_dump_type(self.as_type_ref())
}

// IntType
pub struct IntType {
  ty: Type
}

pub impl TypeRef for IntType with as_type_ref(self: IntType) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

pub fn IntType::new(type_ref: LLVMTypeRef) -> IntType {
  assert_not(type_ref.is_null().to_moonbit_bool())

  IntType::{
    ty: Type::new(type_ref)
  }
}

// TODO: use `prarm_types: Array[&TyepRef]` after compiler bug fixed
pub fn IntType::fn_type(self: IntType, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg)
}

// TODO: Maybe better explain signextension
pub fn const_int(self: IntType, val: UInt64, sign_extend: Bool) -> IntValue {
  let llvm_val_ref = llvm_const_int(self.as_type_ref(), val, to_llvm_bool(sign_extend))
  IntValue::new(llvm_val_ref)
}

pub fn IntType::dump(self: IntType) -> Unit {
  self.ty.dump()
}

// VoidType
pub struct VoidType {
  ty : Type
}

pub fn VoidType::new(type_ref: LLVMTypeRef) -> VoidType {
  assert_not(type_ref.is_null().to_moonbit_bool())

  VoidType::{
    ty: Type::new(type_ref)
  }
}

pub impl TypeRef for VoidType with as_type_ref(self: VoidType) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

// TODO: use `prarm_types: Array[&TyepRef]` after compiler bug fixed
pub fn VoidType::fn_type(self: VoidType, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg)
}

pub fn VoidType::to_string(self: VoidType) -> String {
  self.ty.to_string()
}

pub fn VoidType::dump(self: VoidType) -> Unit {
  self.ty.dump()
}

// FunctionType
pub struct FunctionType {
  ty: Type
}

pub fn as_type_ref(self: FunctionType) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

pub fn FunctionType::new(type_ref: LLVMTypeRef) -> FunctionType {
  assert_not(type_ref.is_null().to_moonbit_bool())

  FunctionType::{
    ty: Type::new(type_ref)
  }
}

pub fn FunctionType::dump(self: FunctionType) -> Unit {
  self.ty.dump()
}
