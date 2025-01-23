// ==========================================
// Types
// ==========================================
pub struct Type {
  type_ref: LLVMTypeRef
}

trait TypeRef {
  as_type_ref(Self) -> LLVMTypeRef
}

pub fn Type::new(type_ref: LLVMTypeRef) -> Type {
  if type_ref.is_null() {
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

// pub fn ptr_type(self: Type, address_space: AddressSpace) -> PointerType

// pub fn vec_type(self: Type, size: UInt) -> VectorType;

// pub fn scalable_vec_type(self: Type) -> ScalableVectorType;

// TODO: use `prarm_types: Array[&TyepRef]` after compiler bug fixed
pub fn Type::fn_type(
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

// pub fn array_type(self: Type, size: UInt) -> ArrayType;

fn Type::get_undef(self: Type) -> LLVMValueRef {
  llvm_get_undef(self.as_type_ref())
}

fn Type::get_poison(self: Type) -> LLVMValueRef {
  llvm_get_poison(self.as_type_ref())
}

fn Type::get_alignment(self: Type) -> IntValue {
  IntValue::new(llvm_align_of(self.as_type_ref()))
}

fn Type::get_context(self: Type) -> Context {
  let context_ref = self.as_type_ref().get_context()
  Context::new(context_ref)
}

fn Type::is_sized(self: Type) -> Bool {
  self.as_type_ref().is_sized().to_moonbit_bool()
}

fn Type::size_of(self: Type) -> IntValue? {
  if not(self.is_sized()) {
    return None
  }

  let v = IntValue::new(llvm_size_of(self.as_type_ref()))
  Some(v)
}

fn Type::to_string(self: Type) -> String {
  let c_str = llvm_print_type_to_string(self.as_type_ref())
  c_str_to_moonbit_str(c_str)
}

fn Type::dump(self: Type) -> Unit {
  llvm_dump_type(self.as_type_ref())
}

impl Show for Type with output(self: Type, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ===============================================
// IntType
// ===============================================
pub struct IntType {
  ty: Type
}

pub impl TypeRef for IntType with as_type_ref(self: IntType) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

pub fn IntType::new(type_ref: LLVMTypeRef) -> IntType {
  assert_not(type_ref.is_null())

  IntType::{
    ty: Type::new(type_ref)
  }
}

pub fn IntType::const_all_ones(self: IntType) -> IntValue {
  let llvm_val_ref = llvm_const_all_ones(self.as_type_ref())
  IntValue::new(llvm_val_ref)
}

// pub fn const_zero(self: IntType) -> IntValue {
//   let llvm_val_ref = llvm_const_zero(self.as_type_ref())
//   IntValue::new(llvm_val_ref)
// }

// TODO: Maybe better explain signextension
pub fn IntType::const_int(self: IntType, val: UInt64, sign_extend: Bool) -> IntValue {
  let llvm_val_ref = llvm_const_int(self.as_type_ref(), val, to_llvm_bool(sign_extend))
  IntValue::new(llvm_val_ref)
}

// TODO: use `prarm_types: Array[&TyepRef]` after compiler bug fixed
pub fn IntType::fn_type(self: IntType, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg)
}

// pub fn array_type(self: IntType, size: UInt) -> ArrayType;
// pub fn vec_type(self: IntType, size: UInt) -> VectorType;
// pub fn scalable_vec_type(self: IntType) -> ScalableVectorType;

pub fn IntType::get_context(self: IntType) -> Context {
  self.ty.get_context()
}

pub fn IntType::size_of(self: IntType) -> IntValue {
  self.ty.size_of().unwrap()
}

pub fn IntType::get_alignment(self: IntType) -> IntValue {
  self.ty.get_alignment()
}

// pub fn IntType::ptr_type(self: IntType, address_space: AddressSpace) -> PointerType

pub fn IntType::get_bit_width(self: IntType) -> UInt {
  llvm_get_int_type_width(self.as_type_ref())
}

pub fn IntType::get_undef(self: IntType) -> IntValue {
  IntValue::new(self.ty.get_undef())
}

pub fn IntType::get_poison(self: IntType) -> IntValue {
  IntValue::new(self.ty.get_poison())
}

pub fn IntType::to_string(self: IntType) -> String {
  self.ty.to_string()
}

pub fn IntType::dump(self: IntType) -> Unit {
  self.ty.dump()
}

pub impl Show for IntType with output(self: IntType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ==============================================
// FloatType
// ==============================================
pub struct FloatType {
  ty: Type
}

pub fn FloatType::new(type_ref: LLVMTypeRef) -> FloatType {
  assert_not(type_ref.is_null())

  FloatType::{
    ty: Type::new(type_ref)
  }
}

pub impl TypeRef for FloatType with as_type_ref(
  self: FloatType
) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

// TODO: use `prarm_types: Array[&TyepRef]` after compiler bug fixed
pub fn FloatType::fn_type(self: FloatType, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg)
}

// pub fn array_type(self: FloatType, size: UInt) -> ArrayType;
// pub fn vec_type(self: FloatType, size: UInt) -> VectorType;
// pub fn scalable_vec_type(self: FloatType) -> ScalableVectorType;

// use llvm_const_real
pub fn FloatType::const_float(self: FloatType, val: Double) -> FloatValue {
  let llvm_val_ref = llvm_const_real(self.as_type_ref(), val)
  FloatValue::new(llvm_val_ref)
}

// pub fn Float::const_zero(self: FloatType) -> FloatValue {
//   let llvm_val_ref = llvm_const_zero(self.as_type_ref())
//   FloatValue::new(llvm_val_ref)
// }

pub fn FloatType::size_of(self: FloatType) -> IntValue {
  self.ty.size_of().unwrap()
}

pub fn get_alignment(self: FloatType) -> IntValue {
  self.ty.get_alignment()
}

pub fn get_context(self: FloatType) -> Context {
  self.ty.get_context()
}

// pub fn ptr_type(self: FloatType, address_space: AddressSpace) -> PointerType {
//   PointerType::new(llvm_pointer_type(self.as_type_ref(), address_space))
// }

pub fn get_undef(self: FloatType) -> FloatValue {
  FloatValue::new(self.ty.get_undef())
}

pub fn get_poison(self: FloatType) -> FloatValue {
  FloatValue::new(self.ty.get_poison())
}

pub fn to_string(self: FloatType) -> String {
  self.ty.to_string()
}

pub fn dump(self: FloatType) -> Unit {
  self.ty.dump()
}

pub impl Show for FloatType with output(self: FloatType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}


// ==============================================
// VoidType
// ==============================================
pub struct VoidType {
  ty : Type
}

pub fn VoidType::new(type_ref: LLVMTypeRef) -> VoidType {
  assert_not(type_ref.is_null())

  VoidType::{
    ty: Type::new(type_ref)
  }
}

pub impl TypeRef for VoidType with as_type_ref(
  self: VoidType
) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

pub fn VoidType::is_sized(self: VoidType) -> Bool {
  self.ty.is_sized()
}

pub fn VoidType::get_context(self: VoidType) -> Context {
  self.ty.get_context()
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

pub impl Show for VoidType with output(self: VoidType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ===========================================
// PointerType
// ===========================================
pub struct PointerType {
  ty: Type
}

pub fn PointerType::new(type_ref: LLVMTypeRef) -> PointerType {
  assert_not(type_ref.is_null())

  PointerType::{
    ty: Type::new(type_ref)
  }
}

pub impl TypeRef for PointerType with as_type_ref(
  self: PointerType
) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

pub fn PointerType::size_of(self: PointerType) -> IntValue {
  self.ty.size_of().unwrap()
}

pub fn PointerType::get_alignment(self: PointerType) -> IntValue {
  self.ty.get_alignment()
}

// pub fn PointerType::ptr_type(aself: PointerType, address_space: AddressSpace) -> PointerType

pub fn PointerType::get_context(self: PointerType) -> Context {
  self.ty.get_context()
}

pub fn fn_type(self: PointerType, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg)
}

// pub fn array_type(self: PointerType, size: UInt) -> ArrayType;
// pub fn get_address_space(self: PointerType) -> AddressSpace;


// pub fn const_null(self: PointerType) -> PointerValue {
//   PointerValue::new(llvm_const_null(self.as_type_ref()))
// }

// pub fn const_zero(self: PointerType) -> PointerValue {
//   PointerValue::new(llvm_const_zero(self.as_type_ref()))
// }

pub fn PointerType::get_undef(self: PointerType) -> PointerValue {
  PointerValue::new(llvm_get_undef(self.as_type_ref()))
}

pub fn PointerType::get_poison(self: PointerType) -> PointerValue {
  PointerValue::new(llvm_get_poison(self.as_type_ref()))
}

// pub fn vec_type(self: PointerType, size: UInt) -> VectorType
// pub fn scalable_vec_type(self: PointerType) -> ScalableVectorType
// pub fn get_element_type(self: PointerType) -> ...

pub fn PointerType::to_string(self: PointerType) -> String {
  self.ty.to_string()
}

pub fn PointerType::dump(self: PointerType) -> Unit {
  self.ty.dump()
}

pub impl Show for PointerType with output(self: PointerType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ===========================================
// StructType
// ===========================================
pub struct StructType {
  ty: Type
}

pub fn StructType::new(type_ref: LLVMTypeRef) -> StructType {
  assert_not(type_ref.is_null())

  StructType::{
    ty: Type::new(type_ref)
  }
}

pub impl TypeRef for StructType with as_type_ref(
  self: StructType
) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

// pub fn StructType::is_opaque(self: StructType) -> Bool {
//   llvm_is_opaque_struct(self.as_type_ref()) == 1
// }

// pub fn StructType::count_fields(self: StructType) -> UInt {
//   llvm_count_struct_fields(self.as_type_ref())
// }

// pub fn StructType::get_field_types(self: StructType) -> Array[BaiscTypeEnum] {
//
// }

// pub fn StructType::get_poison(self: StructType) -> StructValue {
//   StructValue::new(llvm_get_poison(self.as_type_ref()))
// }

pub fn StructType::to_string(self: StructType) -> String {
  self.ty.to_string()
}

pub fn StructType::dump(self: StructType) -> Unit {
  self.ty.dump()
}

pub impl Show for StructType with output(self: StructType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}


// ===========================================
// FunctionType
// ===========================================
pub struct FunctionType {
  ty: Type
}

pub impl TypeRef for FunctionType with as_type_ref(
  self: FunctionType
) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

pub fn FunctionType::new(type_ref: LLVMTypeRef) -> FunctionType {
  assert_not(type_ref.is_null())

  FunctionType::{
    ty: Type::new(type_ref)
  }
}

pub fn FunctionType::to_string(self: FunctionType) -> String {
  self.ty.to_string()
}

pub fn FunctionType::dump(self: FunctionType) -> Unit {
  self.ty.dump()
}

pub impl Show for FunctionType with output(self: FunctionType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}
