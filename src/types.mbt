// ==========================================
// Types
// ==========================================
pub struct Type {
  type_ref: LLVMTypeRef
}

trait AsTypeRef {
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

pub impl AsTypeRef for Type with as_type_ref(self: Type) -> LLVMTypeRef {
  self.type_ref
}

pub fn ptr_type(self: Type, address_space: AddressSpace) -> PointerType {
  PointerType::new(llvm_pointer_type(self.as_type_ref(), address_space))
}

// pub fn vec_type(self: Type, size: UInt) -> VectorType;

// pub fn scalable_vec_type(self: Type) -> ScalableVectorType;

// TODO: use `prarm_types: Array[&TyepRef]` after compiler bug fixed
pub fn Type::fn_type(
  self: Type,
  param_types: Array[LLVMTypeRef],
  is_var_arg: Bool
) -> FunctionType {
  let ret_ty = self.as_type_ref()
  // let type_refs = param_types.map(fn (t) {t.as_type_ref()})
  let type_refs = param_types
  let fty_ref = llvm_function_type(ret_ty, type_refs, is_var_arg)
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

fn Type::print_to_stderr(self: Type) -> Unit {
  llvm_dump_type(self.as_type_ref())
}

fn Type::print_to_string(self: Type) -> String {
  llvm_print_type_to_string(self.as_type_ref())
}

fn Type::to_string(self: Type) -> String {
  llvm_print_type_to_string(self.as_type_ref())
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

pub impl AsTypeRef for IntType with as_type_ref(self: IntType) -> LLVMTypeRef {
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
  let llvm_val_ref = llvm_const_int(self.as_type_ref(), val, sign_extend)
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

pub fn IntType::ptr_type(self: IntType, address_space: AddressSpace) -> PointerType {
  PointerType::new(llvm_pointer_type(self.as_type_ref(), address_space))
}

pub fn IntType::get_bit_width(self: IntType) -> UInt {
  llvm_get_int_type_width(self.as_type_ref())
}

pub fn IntType::get_undef(self: IntType) -> IntValue {
  IntValue::new(self.ty.get_undef())
}

pub fn IntType::get_poison(self: IntType) -> IntValue {
  IntValue::new(self.ty.get_poison())
}

pub fn IntType::print_to_stderr(self: IntType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn IntType::print_to_string(self: IntType) -> String {
  self.ty.print_to_string()
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

pub impl AsTypeRef for FloatType with as_type_ref(
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

pub fn FloatType::get_alignment(self: FloatType) -> IntValue {
  self.ty.get_alignment()
}

pub fn FloatType::get_context(self: FloatType) -> Context {
  self.ty.get_context()
}

pub fn FloatType::ptr_type(self: FloatType, address_space: AddressSpace) -> PointerType {
  PointerType::new(llvm_pointer_type(self.as_type_ref(), address_space))
}

pub fn get_undef(self: FloatType) -> FloatValue {
  FloatValue::new(self.ty.get_undef())
}

pub fn get_poison(self: FloatType) -> FloatValue {
  FloatValue::new(self.ty.get_poison())
}

pub fn FloatType::print_to_stderr(self: FloatType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn FloatType::print_to_string(self: FloatType) -> String {
  self.ty.print_to_string()
}

pub fn FloatType::to_string(self: FloatType) -> String {
  self.ty.to_string()
}

pub fn FloatType::dump(self: FloatType) -> Unit {
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

pub impl AsTypeRef for VoidType with as_type_ref(
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

pub fn VoidType::get_alignment(self: VoidType) -> IntValue {
  self.ty.get_alignment()
}

pub fn VoidType::print_to_stderr(self: VoidType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn VoidType::print_to_string(self: VoidType) -> String {
  self.ty.print_to_string()
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

pub impl AsTypeRef for PointerType with as_type_ref(
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

pub fn PointerType::ptr_type(self: PointerType, address_space: AddressSpace) -> PointerType {
  PointerType::new(llvm_pointer_type(self.as_type_ref(), address_space))
}

pub fn PointerType::get_context(self: PointerType) -> Context {
  self.ty.get_context()
}

pub fn fn_type(self: PointerType, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg)
}

// pub fn array_type(self: PointerType, size: UInt) -> ArrayType;
pub fn get_address_space(self: PointerType) -> AddressSpace {
  let addr_space = llvm_get_pointer_address_space(self.as_type_ref())

  AddressSpace(addr_space)
}


pub fn const_null(self: PointerType) -> PointerValue {
  PointerValue::new(llvm_const_null(self.as_type_ref()))
}

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

pub fn PointerType::print_to_stderr(self: PointerType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn PointerType::print_to_string(self: PointerType) -> String {
  self.ty.print_to_string()
}

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

pub impl AsTypeRef for StructType with as_type_ref(
  self: StructType
) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

pub fn StructType::is_opaque(self: StructType) -> Bool {
  llvm_is_opaque_struct(self.as_type_ref())
}

pub fn StructType::count_fields(self: StructType) -> UInt {
  llvm_count_struct_element_types(self.as_type_ref())
}

// pub fn StructType::get_field_types(self: StructType) -> Array[BaiscTypeEnum] {
//
// }

pub fn StructType::get_poison(self: StructType) -> StructValue {
  StructValue::new(llvm_get_poison(self.as_type_ref()))
}

pub fn StructType::print_to_stderr(self: StructType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn StructType::print_to_string(self: StructType) -> String {
  self.ty.print_to_string()
}

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

pub impl AsTypeRef for FunctionType with as_type_ref(
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

pub fn FunctionType::print_to_stderr(self: FunctionType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn FunctionType::print_to_string(self: FunctionType) -> String {
  self.ty.print_to_string()
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

// ===========================================
// ArrayType
// ===========================================
pub struct ArrayType {
  ty: Type
}

pub fn ArrayType::new(type_ref: LLVMTypeRef) -> ArrayType {
  assert_not(type_ref.is_null())

  ArrayType::{
    ty: Type::new(type_ref)
  }
}

pub impl AsTypeRef for ArrayType with as_type_ref(
  self: ArrayType
) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

pub fn ArrayType::size_of(self: ArrayType) -> IntValue? {
  self.ty.size_of()
}

pub fn ArrayType::get_alignment(self: ArrayType) -> IntValue {
  self.ty.get_alignment()
}

pub fn ArrayType::get_context(self: ArrayType) -> Context {
  self.ty.get_context()
}

pub fn ArrayType::print_to_stderr(self: ArrayType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn ArrayType::print_to_string(self: ArrayType) -> String {
  self.ty.print_to_string()
}

pub fn ArrayType::to_string(self: ArrayType) -> String {
  self.ty.to_string()
}

pub fn ArrayType::dump(self: ArrayType) -> Unit {
  self.ty.dump()
}

pub impl Show for ArrayType with output(self: ArrayType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ===========================================
// VectorType
// ===========================================
pub struct VectorType {
  ty: Type
}

pub fn VectorType::new(type_ref: LLVMTypeRef) -> VectorType {
  assert_not(type_ref.is_null())

  VectorType::{
    ty: Type::new(type_ref)
  }
}

pub impl AsTypeRef for VectorType with as_type_ref(
  self: VectorType
) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

pub fn VectorType::size_of(self: VectorType) -> IntValue? {
  self.ty.size_of()
}

pub fn VectorType::get_alignment(self: VectorType) -> IntValue {
  self.ty.get_alignment()
}

pub fn VectorType::get_size(self: VectorType) -> UInt {
  llvm_get_vector_size(self.as_type_ref())
}

// pub fn VectorType::const_vector

// pub fn VectorType::const_zero(self: VectorType) -> VectorValue {
//   VectorValue::new(llvm_const_zero(self.as_type_ref()))
// }

pub fn VectorType::get_context(self: VectorType) -> Context {
  self.ty.get_context()
}

pub fn VectorType::print_to_stderr(self: VectorType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn VectorType::print_to_string(self: VectorType) -> String {
  self.ty.print_to_string()
}

pub fn VectorType::to_string(self: VectorType) -> String {
  self.ty.to_string()
}

pub fn VectorType::dump(self: VectorType) -> Unit {
  self.ty.dump()
}

pub impl Show for VectorType with output(self: VectorType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ===========================================
// ScalableVectorType
// ===========================================
pub struct ScalableVectorType {
  ty: Type
}

pub fn ScalableVectorType::new(type_ref: LLVMTypeRef) -> ScalableVectorType {
  assert_not(type_ref.is_null())

  ScalableVectorType::{
    ty: Type::new(type_ref)
  }
}

pub impl AsTypeRef for ScalableVectorType with as_type_ref(
  self: ScalableVectorType
) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

pub fn ScalableVectorType::size_of(self: ScalableVectorType) -> IntValue? {
  self.ty.size_of()
}

pub fn ScalableVectorType::get_alignment(self: ScalableVectorType) -> IntValue {
  self.ty.get_alignment()
}

pub fn ScalableVectorType::get_size(self: ScalableVectorType) -> UInt {
  llvm_get_vector_size(self.as_type_ref())
}

// pub fn ScalableVectorType::const_zero(self: ScalableVectorType) -> ScalableVectorValue {
//  ScalableVectorValue::new(self.ty.const_zero())
// }

// pub fn ScalableVectorType::get_undef(self: ScalableVectorType) -> ScalableVectorValue {
//   ScalableVectorValue::new(self.ty.get_undef())
// }

// pub fn ScalableVectorType::get_poison(self: ScalableVectorType) -> ScalableVectorValue {
//   ScalableVectorValue::new(self.ty.get_poison())
// }

// pub fn ScalableVectorType::get_element_type(self: ScalableVectorType) -> BasicTypeEnum {
//   self.ty.get_element_type().as_basic_type_enum()
// }

// TODO: use `prarm_types: Array[&TyepRef]` after compiler bug fixed
pub fn ScalableVectorType::fn_type(self: ScalableVectorType, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg)
}

// pub fn ScalableVectorType::array_type(self: ScalableVectorType, size: UInt) -> ArrayType {
//   self.ty.array_type(size)
// }

// pub fn ScalableVectorType::const_array(self: ScalableVectorType, values: Array[ScalableVectorValue]) -> ArrayValue {
//   ArrayValue::new_const_array(self, values)
// }

pub fn ScalableVectorType::get_context(self: ScalableVectorType) -> Context {
  self.ty.get_context()
}

pub fn ScalableVectorType::print_to_stderr(self: ScalableVectorType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn ScalableVectorType::print_to_string(self: ScalableVectorType) -> String {
  self.ty.print_to_string()
}

pub fn ScalableVectorType::to_string(self: ScalableVectorType) -> String {
  self.ty.to_string()
}

pub fn ScalableVectorType::dump(self: ScalableVectorType) -> Unit {
  self.ty.dump()
}

pub impl Show for ScalableVectorType with output(self: ScalableVectorType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ===========================================
// MeteadataType
// ===========================================
pub struct MetadataType {
  ty: Type
}

pub fn MetadataType::new(type_ref: LLVMTypeRef) -> MetadataType {
  assert_not(type_ref.is_null())

  MetadataType::{
    ty: Type::new(type_ref)
  }
}

pub impl AsTypeRef for MetadataType with as_type_ref(
  self: MetadataType
) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

pub fn MetadataType::fn_type(self: MetadataType, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg)
}

pub fn MetadataType::get_context(self: MetadataType) -> Context {
  self.ty.get_context()
}

pub fn MetadataType::print_to_stderr(self: MetadataType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn MetadataType::print_to_string(self: MetadataType) -> String {
  self.ty.print_to_string()
}

pub fn MetadataType::to_string(self: MetadataType) -> String {
  self.ty.to_string()
}

pub fn MetadataType::dump(self: MetadataType) -> Unit {
  self.ty.dump()
}

pub impl Show for MetadataType with output(self: MetadataType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}
