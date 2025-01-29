
enum PositionState {
    NotSet
    Set
} derive(Eq)

// pub enum BuilderError {
//     #[error("Builder position is not set")]
//     UnsetPosition
//     #[error("Alignment error")]
//     AlignmentError(&'static str)
//     #[error("Aggregate extract index out of range")]
//     ExtractOutOfRange
//     #[error("Bitwidth of a value is incorrect")]
//     BitwidthError(&'static str)
//     #[error("Pointee type does not match the value's type")]
//     PointeeTypeMismatch(&'static str)
//     #[error("Values do not have the same type")]
//     ValueTypeMismatch(&'static str)
//     #[error("Ordering error or mismatch")]
//     OrderingError(&'static str)
//     #[error("GEP pointee is not a struct")]
//     GEPPointee
//     #[error("GEP index out of range")]
//     GEPIndex
// }

pub type! BuilderError {
  // Builder position is not set
  UnsetPosition
  // Alignment error
  AlignmentError(String)
  // Aggregate extract index out of range
  ExtractOutOfRange
  // Bitwidth of a value is incorrect
  BitwidthError(String)
  // Pointee type does not match the value's type
  PointeeTypeMismatch(String)
  // Values do not have the same type
  ValueTypeMismatch(String)
  // Ordering error or mismatch
  OrderingError(String)
  // GEP pointee is not a struct
  GEPPointee
  // GEP index out of range
  GEPIndex
}

// FIXME: Dummy function, just for stopping warning eliminate when all done
pub fn raise_builder_error(i: Int) -> Int!BuilderError {
  match i {
    0 => raise UnsetPosition
    1 => raise AlignmentError("Alignment error")
    2 => raise ExtractOutOfRange
    3 => raise BitwidthError("Bitwidth of a value is incorrect")
    4 => raise PointeeTypeMismatch("Pointee type does not match the value's type")
    5 => raise ValueTypeMismatch("Values do not have the same type")
    6 => raise OrderingError("Ordering error or mismatch")
    7 => raise GEPPointee
    8 => raise GEPIndex
    _ => return i
  }
}


pub struct Builder {
  builder_ref: LLVMBuilderRef
  mut positioned: PositionState
}

pub fn Builder::new(builder_ref: LLVMBuilderRef) -> Builder {
  Builder::{
    builder_ref: builder_ref,
    positioned: NotSet
  }
}

fn Builder::as_builder_ref(self: Builder) -> LLVMBuilderRef {
  self.builder_ref
}

fn Builder::get_positioned(self: Builder) -> PositionState {
  self.positioned
}

pub fn Builder::build_return(
  self: Builder, val~:&BasicValue? = None
) -> InstructionValue!BuilderError {
  if self.get_positioned() == PositionState::NotSet {
    raise UnsetPosition
  }

  let builder_ref = self.as_builder_ref()
  let inst = match val {
    Some(val) => {
      let val_ref = val.as_value_ref()
      llvm_build_ret(builder_ref, val_ref)
    }
    None => {
      llvm_build_ret_void(builder_ref)
    }
  }
  InstructionValue::new(inst)
}

pub fn Builder::build_aggregate_return(
  self: Builder, values: Array[BasicValueEnum]
) -> InstructionValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
  // if self.get_positioned() == PositionState::NotSet {
    raise UnsetPosition
  }

  let builder_ref = self.as_builder_ref()
  let args = values.map(fn (v) {v.as_value_ref()})
  let ret_v = llvm_build_aggregate_ret(builder_ref, args)

  InstructionValue::new(ret_v)
}

pub fn Builder::build_call(
  self: Builder, 
  func: FunctionValue, 
  args: Array[BasicMetadataValueEnum],
  name: String
) -> CallSiteValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  self.build_direct_call!(func, args, name)
}

pub fn Builder::build_direct_call(
  self: Builder, 
  func: FunctionValue, 
  args: Array[BasicMetadataValueEnum],
  name: String
) -> CallSiteValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let fty = func.get_type()
  let fn_val = func.value
  self.build_call_help!(fty, fn_val, args, name)
}


pub fn Builder::build_direct_call_with_operand_bundles(
  self: Builder,
  func: FunctionValue,
  args: Array[BasicMetadataValueEnum],
  operand_bundles: Array[OperandBundle],
  name: String
) -> CallSiteValue!BuilderError {
  let fty = func.get_type()
  let fn_val = func.value
  self.build_call_with_operand_bundles_help!(fty, fn_val, args, operand_bundles, name)
}

pub fn Builder::build_indirect_call(
  self: Builder,
  fn_type: FunctionType,
  fn_ptr: PointerValue,
  args: Array[BasicMetadataValueEnum],
  name: String
) -> CallSiteValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  self.build_call_help!(fn_type, fn_ptr.value, args, name)
}

pub fn Builder::build_indirect_call_with_operand_bundles(
  self: Builder,
  fn_type: FunctionType,
  fn_ptr: PointerValue,
  args: Array[BasicMetadataValueEnum],
  operand_bundles: Array[OperandBundle],
  name: String
) -> CallSiteValue!BuilderError {
  self.build_call_with_operand_bundles_help!(fn_type, fn_ptr.value, args, operand_bundles, name)
}

fn Builder::build_call_help(
  self: Builder,
  fn_ty: FunctionType,
  fn_val: Value, // FunctionValue Or PointerValue
  args: Array[BasicMetadataValueEnum],
  name: String
) -> CallSiteValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let builder_ref = self.as_builder_ref()
  let fty_ref = fn_ty.as_type_ref()
  let fval_ref = fn_val.as_value_ref()
  let args = args.map(fn (v) {v.as_value_ref()})

  let r = llvm_build_call2(builder_ref, fty_ref, fval_ref, args, name)
  CallSiteValue::new(r)
}

fn Builder::build_call_with_operand_bundles_help(
  self: Builder,
  fty: FunctionType,
  fn_val: Value, // FunctionValue Or PointerValue
  args: Array[BasicMetadataValueEnum],
  operand_bundles: Array[OperandBundle],
  name: String
) -> CallSiteValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let builder_ref = self.as_builder_ref()
  let fty_ref = fty.as_type_ref()
  let fval_ref = fn_val.as_value_ref()
  let args = args.map(fn (v) {v.as_value_ref()})
  let operand_bundles = operand_bundles.map(fn (ob) {ob.as_bundle_ref()})

  let r = llvm_build_call_with_operand_bundles(builder_ref, fty_ref, fval_ref, args, operand_bundles, name)
  CallSiteValue::new(r)
}

pub fn Builder::build_invoke(
  self: Builder,
  func: FunctionValue,
  args: Array[BasicValueEnum],
  then_block: BasicBlock,
  catch_block: BasicBlock,
  name: String
) -> CallSiteValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  self.build_direct_invoke!(func, args, then_block, catch_block, name)
}

pub fn Builder::build_direct_invoke(
  self: Builder,
  func: FunctionValue,
  args: Array[BasicValueEnum],
  then_block: BasicBlock,
  catch_block: BasicBlock,
  name: String
) -> CallSiteValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let fty = func.get_type()
  let fn_val = func.value
  self.build_invoke_help!(fty, fn_val, args, then_block, catch_block, name)
}

pub fn Builder::build_indirect_invoke(
  self: Builder,
  fn_ty: FunctionType,
  fn_ptr: PointerValue,
  args: Array[BasicValueEnum],
  then_block: BasicBlock,
  catch_block: BasicBlock,
  name: String
) -> CallSiteValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  self.build_invoke_help!(fn_ty, fn_ptr.value, args, then_block, catch_block, name)
}

pub fn Builder::build_invoke_help(
  self: Builder,
  fn_ty: FunctionType,
  fn_val: Value,
  args: Array[BasicValueEnum],
  then_block: BasicBlock,
  catch_block: BasicBlock,
  name: String
) -> CallSiteValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let fn_ty_ref = fn_ty.as_type_ref()
  let fn_val_ref = fn_val.as_value_ref()
  let name = match fn_ty.get_return_type() {
    None => ""
    Some(_) => name
  }
  let args = args.map(fn (val) {val.as_value_ref()})

  let value = llvm_build_invoke2(
    self.as_builder_ref(),
    fn_ty_ref,
    fn_val_ref,
    args,
    then_block.as_bb_ref(),
    catch_block.as_bb_ref(),
    name
  )

  CallSiteValue::new(value)
}


pub fn Builder::build_landing_pad(
  self: Builder,
  exception_type: &BasicType,
  personality_function: FunctionValue,
  clauses: Array[BasicValueEnum],
  is_cleanup: Bool,
  name: String
) -> BasicValueEnum!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let num_clauses = clauses.length().reinterpret_as_uint()

  let value = llvm_build_landing_pad(
    self.as_builder_ref(),
    exception_type.as_type_ref(),
    personality_function.as_value_ref(),
    num_clauses,
    name
  )

  for clause in clauses {
    llvm_add_clause(value, clause.as_value_ref())
  }

  llvm_set_cleanup(value, is_cleanup)

  BasicValueEnum::new(value)
}

pub fn Builder::build_resume(
  self: Builder, value: &BasicValue
) -> InstructionValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value_ref = value.as_value_ref()
  let inst = llvm_build_resume(self.as_builder_ref(), value_ref)
  InstructionValue::new(inst)
}

pub fn Builder::build_gep(
  self: Builder,
  pointee_ty: &BasicType,
  ptr: PointerValue,
  ordered_indices: Array[BasicValueEnum],
  name: String
) -> BasicValueEnum!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let ptr_ref = ptr.as_value_ref()
  let indices = ordered_indices.map(fn (v) {v.as_value_ref()})
  let value = llvm_build_gep2(
    self.as_builder_ref(),
    pointee_ty.as_type_ref(),
    ptr_ref,
    indices,
    name
  )
  BasicValueEnum::new(value)
}

pub fn Builder::build_in_bounds_gep(
  self: Builder,
  pointee_ty: &BasicType,
  ptr: PointerValue,
  ordered_indices: Array[IntValue],
  name: String
) -> PointerValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let ptr_ref = ptr.as_value_ref()
  let indices = ordered_indices.map(fn (v) {v.as_value_ref()})
  let value = llvm_build_in_bounds_gep2(
    self.as_builder_ref(),
    pointee_ty.as_type_ref(),
    ptr_ref,
    indices,
    name
  )
  PointerValue::new(value)
}

pub fn Builder::build_struct_gep(
  self: Builder,
  pointee_ty: &BasicType,
  ptr: PointerValue,
  index: UInt,
  name: String
) -> PointerValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let pointee_ty = pointee_ty.as_any_type_enum()

  if not(pointee_ty.is_struct_type()) {
    raise GEPPointee
  }

  let struct_ty = pointee_ty.into_struct_type()

  if index >= struct_ty.count_fields() {
    raise GEPIndex
  }

  let ptr_ref = ptr.as_value_ref()
  let value = llvm_build_struct_gep2(
    self.as_builder_ref(),
    pointee_ty.as_type_ref(),
    ptr_ref,
    index,
    name
  )
  PointerValue::new(value)
}

pub fn Builder::build_ptr_diff(
  self: Builder,
  pointee_ty: &BasicType,
  lhs_ptr: PointerValue,
  rhs_ptr: PointerValue,
  name: String
) -> IntValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ptr_ref = lhs_ptr.as_value_ref()
  let rhs_ptr_ref = rhs_ptr.as_value_ref()
  let value = llvm_build_ptr_diff2(
    self.as_builder_ref(),
    pointee_ty.as_type_ref(),
    lhs_ptr_ref,
    rhs_ptr_ref,
    name
  )
  IntValue::new(value)
}

pub fn Builder::build_phi(self: Builder, ty: &BasicType, name: String) -> PhiValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_phi(self.as_builder_ref(), ty.as_type_ref(), name)
  PhiValue::new(value)
}

pub fn Builder::build_store(self: Builder, ptr: PointerValue, val: &BasicValue) -> InstructionValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let val_ref = val.as_value_ref()
  let ptr_ref = ptr.as_value_ref()
  let inst = llvm_build_store(self.as_builder_ref(), val_ref, ptr_ref)
  InstructionValue::new(inst)
}

pub fn Builder::build_load(self: Builder, pointee_ty: &BasicType, ptr: PointerValue, name: String) -> BasicValueEnum!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let ptr_ref = ptr.as_value_ref()
  let value = llvm_build_load2(self.as_builder_ref(), pointee_ty.as_type_ref(), ptr_ref, name)
  BasicValueEnum::new(value)
}

pub fn Builder::build_alloca(
  self: Builder, ty: &BasicType, name: String
) -> PointerValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_alloca(self.as_builder_ref(), ty.as_type_ref(), name)
  PointerValue::new(value)
}

pub fn Builder::build_array_alloca(
  self: Builder,
  ty: &BasicType,
  size: &BasicValue,
  name: String
) -> PointerValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let size_ref = size.as_value_ref()
  let value = llvm_build_array_alloca(self.as_builder_ref(), ty.as_type_ref(), size_ref, name)
  PointerValue::new(value)
}

pub fn Builder::build_memcpy(
  self: Builder,
  dest: PointerValue,
  dst_align: UInt,
  src: PointerValue,
  src_align: UInt,
  size: IntValue,
) -> PointerValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  if not(is_alignment_ok(dst_align)) {
    raise AlignmentError("The dest_align_bytes argument to build_memcpy was not a power of 2.")
  }

  if not(is_alignment_ok(src_align)) {
    raise AlignmentError("The src_align_bytes argument to build_memcpy was not a power of 2.")
  }

  let dest_ref = dest.as_value_ref()
  let src_ref = src.as_value_ref()
  let value = llvm_build_mem_cpy(
    self.as_builder_ref(),
    dest_ref,
    dst_align,
    src_ref,
    src_align,
    size.as_value_ref()
  )
  PointerValue::new(value)
}

pub fn Builder::build_memove(
  self: Builder,
  dest: PointerValue,
  dst_align: UInt,
  src: PointerValue,
  src_align: UInt,
  size: IntValue
) -> PointerValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  if not(is_alignment_ok(dst_align)) {
    raise AlignmentError("The dest_align_bytes argument to build_memmove was not a power of 2.")
  }

  if not(is_alignment_ok(src_align)) {
    raise AlignmentError("The src_align_bytes argument to build_memmove was not a power of 2.")
  }

  let value = llvm_build_mem_move(
    self.as_builder_ref(),
    dest.as_value_ref(),
    dst_align,
    src.as_value_ref(),
    src_align,
    size.as_value_ref()
  )

  PointerValue::new(value)
}

pub fn Builder::build_memset(
  self: Builder,
  dest: PointerValue,
  dest_align: UInt,
  val: IntValue,
  size: IntValue
) -> PointerValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  if not(is_alignment_ok(dest_align)) {
    raise AlignmentError("The dest_align_bytes argument to build_memset was not a power of 2.")
  }

  let value = llvm_build_mem_set(
    self.as_builder_ref(),
    dest.as_value_ref(),
    val.as_value_ref(),
    size.as_value_ref(),
    dest_align
  )

  PointerValue::new(value)
}

pub fn Builder::build_malloc(
  self: Builder,
  ty: &BasicType,
  name: String
) -> PointerValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  if not(ty.is_sized()) {
    raise AlignmentError("Cannot build malloc call for an unsized type")
  }

  let value = llvm_build_malloc(self.as_builder_ref(), ty.as_type_ref(), name)
  PointerValue::new(value)
}

pub fn Builder::build_array_malloc(
  self: Builder,
  ty: &BasicType,
  size: IntValue,
  name: String
) -> PointerValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  if not(ty.is_sized()) {
    raise AlignmentError("Cannot build array malloc call for an unsized type")
  }

  let value = llvm_build_array_malloc(
    self.as_builder_ref(), ty.as_type_ref(), size.as_value_ref(), name
  )

  PointerValue::new(value)
}

pub fn Builder::build_free(
  self: Builder,
  ptr: PointerValue
) -> InstructionValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_free(self.as_builder_ref(), ptr.as_value_ref())
  InstructionValue::new(value)
}

pub fn Builder::insert_instruction(
  self: Builder, inst: InstructionValue, name: String?
) -> Unit {
  match name {
    Some(name) => {
      llvm_insert_into_builder_with_name(self.as_builder_ref(), inst.as_value_ref(), name)
    }
    None => {
      llvm_insert_into_builder(self.as_builder_ref(), inst.as_value_ref())
    }
  }
}

pub fn Builder::build_int_unsigned_div[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_u_div(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

pub fn Builder::build_int_signed_div[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_s_div(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

pub fn Builder::build_int_exact_signed_div[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_exact_s_div(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

pub fn Builder::build_int_unsigned_rem[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_u_rem(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

pub fn Builder::build_int_signed_rem[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_s_rem(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

// 2025.1.29, moonbit didn't not support type in trait, hence need to think
// how to implement this
// pub fn Builder::build_int_s_extend[T: IntMathValue] (
//   self: Builder,
//   int_value: T,
//   int_type: 
// )

pub fn Builder::build_address_space_cast(
  self: Builder,
  ptr_val: PointerValue,
  ptr_type: PointerType,
  name: String
) -> PointerValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let ptr_val_ref = ptr_val.as_value_ref()
  let ptr_type_ref = ptr_type.as_type_ref()
  let value = llvm_build_addr_space_cast(
    self.as_builder_ref(),
    ptr_val_ref,
    ptr_type_ref,
    name
  )

  PointerValue::new(value)
}

// pub fn build_int_s_extend_or_bit_cast<T: IntMathValue<'ctx>>(
// pub fn build_int_z_extend<T: IntMathValue<'ctx>>(
// pub fn build_int_z_extend_or_bit_cast<T: IntMathValue<'ctx>>(
// pub fn build_int_truncate<T: IntMathValue<'ctx>>(
// pub fn build_int_truncate_or_bit_cast<T: IntMathValue<'ctx>>(

pub fn Builder::build_float_rem[T: FloatMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_f_rem(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

// pub fn build_float_to_unsigned_int<T: FloatMathValue<'ctx>>(
// pub fn build_float_to_signed_int<T: FloatMathValue<'ctx>>(
// pub fn build_unsigned_int_to_float<T: IntMathValue<'ctx>>(
// pub fn build_signed_int_to_float<T: IntMathValue<'ctx>>(
// pub fn build_float_trunc<T: FloatMathValue<'ctx>>(
// pub fn build_float_ext<T: FloatMathValue<'ctx>>(
// pub fn build_float_cast<T: FloatMathValue<'ctx>>(
// pub fn build_int_cast<T: IntMathValue<'ctx>>(
// pub fn build_int_cast_sign_flag<T: IntMathValue<'ctx>>(

pub fn Builder::build_float_div(
  self: Builder, lhs: FloatValue, rhs: FloatValue, name: String
) -> FloatValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_f_div(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  FloatValue::new(value)
}

pub fn Builder::build_int_add[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_add(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

pub fn Builder::build_int_nsw_add[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_nsw_add(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

pub fn Builder::build_int_nuw_add[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_nuw_add(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

pub fn Builder::build_float_add[T: FloatMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_f_add(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

pub fn Builder::build_xor[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_xor(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

pub fn Builder::build_and[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_and(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

pub fn Builder::build_or[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_or(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

// left shift
pub fn Builder::build_left_shift[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_shl(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

// right shift
pub fn Builder::build_right_shift[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, sign_extend: Bool, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let val = if sign_extend {
    llvm_build_a_shr(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  } else {
    llvm_build_l_shr(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  }
  T::new(val)
}

pub fn Builder::build_int_sub[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_sub(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

pub fn Builder::build_int_nsw_sub[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_nsw_sub(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

pub fn Builder::build_int_nuw_sub[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_nuw_sub(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

pub fn Builder::build_float_sub[T: FloatMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_f_sub(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  T::new(value)
}

pub fn Builder::build_int_mul[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs = lhs.as_value_ref()
  let rhs = rhs.as_value_ref()
  let value = llvm_build_mul(self.as_builder_ref(), lhs, rhs, name)
  T::new(value)
}

pub fn Builder::build_int_nsw_mul[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs = lhs.as_value_ref()
  let rhs = rhs.as_value_ref()
  let value = llvm_build_nsw_mul(self.as_builder_ref(), lhs, rhs, name)
  T::new(value)
}

pub fn Builder::build_int_nuw_mul[T: IntMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs = lhs.as_value_ref()
  let rhs = rhs.as_value_ref()
  let value = llvm_build_nuw_mul(self.as_builder_ref(), lhs, rhs, name)
  T::new(value)
}

pub fn Builder::build_float_mul[T: FloatMathValue](
  self: Builder, lhs: T, rhs: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs = lhs.as_value_ref()
  let rhs = rhs.as_value_ref()
  let value = llvm_build_f_mul(self.as_builder_ref(), lhs, rhs, name)
  T::new(value)
}

pub fn Builder::build_binop[T: BasicValue] (
  self: Builder,
  op: InstructionOpcode,
  lhs: T,
  rhs: T,
  name: String
) -> BasicValueEnum!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = llvm_build_bin_op(self.as_builder_ref(), op.into(), lhs_ref, rhs_ref, name)
  BasicValueEnum::new(value)
}

pub fn Builder::build_cast[T: BasicType, V: BasicValue](
  self: Builder,
  op: InstructionOpcode,
  from_value: V,
  to_type: T,
  name: String
) -> BasicValueEnum!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let val = llvm_build_cast(
    self.as_builder_ref(),
    op.into(),
    from_value.as_value_ref(),
    to_type.as_type_ref(),
    name
  )

  BasicValueEnum::new(val)
}


// pub fn Builder::build_pointer_cast[T: PointerMathValue](
//   self: Builder, from: T, to:T::BaseType, name: String
// ) -> T!BuilderError {
//   if self.get_positioned() != PositionState::Set {
//     raise UnsetPosition
//   }
//
//   let from_ref = from.as_value_ref()
//   let to_ref = to.as_type_ref()
//   let value = llvm_build_pointer_cast(self.as_builder_ref(), from_ref, to_ref, name)
//   T::new(value)
// }

// pub fn build_int_compare<T: IntMathValue<'ctx>>(
//     &self,
//     op: IntPredicate,
//     lhs: T,
//     rhs: T,
//     name: &str,
// ) -> Result<<T::BaseType as IntMathType<'ctx>>::ValueType, BuilderError> {
//     if self.positioned.get() != PositionState::Set {
//         return Err(BuilderError::UnsetPosition);
//     }
//     let c_string = to_c_str(name);
//     let value = unsafe {
//         LLVMBuildICmp(
//             self.builder,
//             op.into(),
//             lhs.as_value_ref(),
//             rhs.as_value_ref(),
//             c_string.as_ptr(),
//         )
//     };
//
//     unsafe { Ok(<T::BaseType as IntMathType<'ctx>>::ValueType::new(value)) }
// }

// pub fn build_float_compare<T: FloatMathValue<'ctx>>(
//     &self,
//     op: FloatPredicate,
//     lhs: T,
//     rhs: T,
//     name: &str,
// ) -> Result<<<T::BaseType as FloatMathType<'ctx>>::MathConvType as IntMathType<'ctx>>::ValueType, BuilderError>
// {
//     if self.positioned.get() != PositionState::Set {
//         return Err(BuilderError::UnsetPosition);
//     }
//     let c_string = to_c_str(name);
//
//     let value = unsafe {
//         LLVMBuildFCmp(
//             self.builder,
//             op.into(),
//             lhs.as_value_ref(),
//             rhs.as_value_ref(),
//             c_string.as_ptr(),
//         )
//     };
//
//     unsafe { Ok(<<T::BaseType as FloatMathType>::MathConvType as IntMathType>::ValueType::new(value)) }
// }

pub fn Builder::build_unconditional_branch(
  self: Builder, destination_block: BasicBlock
) -> InstructionValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_br(self.as_builder_ref(), destination_block.bb_ref)
  InstructionValue::new(value)
}

pub fn Builder::build_conditional_branch(
  self: Builder,
  comparison: IntValue,
  then_block: BasicBlock,
  else_block: BasicBlock
) -> InstructionValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_cond_br(
    self.as_builder_ref(),
    comparison.as_value_ref(),
    then_block.bb_ref,
    else_block.bb_ref
  )

  InstructionValue::new(value)
}

pub fn Builder::build_indirect_branch(
  self: Builder,
  address: BasicValueEnum,
  destinations: Array[BasicBlock]
) -> InstructionValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_indirect_br(
    self.as_builder_ref(),
    address.as_value_ref(),
    destinations.length().reinterpret_as_uint()
  )

  for destination in destinations {
    llvm_add_destination(value, destination.as_bb_ref())
  }

  InstructionValue::new(value)
}

pub fn Builder::build_int_neg[T: IntMathValue](
  self: Builder, value: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_neg(self.as_builder_ref(), value.as_value_ref(), name)
  T::new(value)
}

pub fn Builder::build_int_nsw_neg[T: IntMathValue](
  self: Builder, value: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_nsw_neg(self.as_builder_ref(), value.as_value_ref(), name)
  T::new(value)
}

pub fn Builder::build_int_nuw_neg[T: IntMathValue](
  self: Builder, value: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_nuw_neg(self.as_builder_ref(), value.as_value_ref(), name)
  T::new(value)
}

pub fn Builder::build_float_neg[T: FloatMathValue](
  self: Builder, value: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_f_neg(self.as_builder_ref(), value.as_value_ref(), name)
  T::new(value)
}

pub fn Builder::build_not[T: IntMathValue](
  self: Builder, value: T, name: String
) -> T!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_not(self.as_builder_ref(), value.as_value_ref(), name)
  T::new(value)
}

pub fn Builder::position_at(
  self: Builder, basic_block: BasicBlock, instruction: InstructionValue
) -> Unit {
  let builder_ref = self.as_builder_ref()
  let bb_ref = basic_block.as_bb_ref()
  let inst_ref = instruction.as_value_ref()
  llvm_position_builder(builder_ref, bb_ref, inst_ref)
}

pub fn Builder::position_before(self: Builder, instruction: InstructionValue) -> Unit {
  let builder_ref = self.as_builder_ref()
  let inst_ref = instruction.as_value_ref()
  llvm_position_builder_before(builder_ref, inst_ref)
}


pub fn position_at_end(self: Builder, bb: BasicBlock) -> Unit {
  let builder_ref = self.builder_ref
  let bb_ref = bb.bb_ref
  llvm_position_builder_at_end(builder_ref, bb_ref)
}

pub fn Builder::build_extract_value[AV: AggregateValue](
  self: Builder, agg: AV, index: UInt, name: String
) -> BasicValueEnum!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let size = match agg.as_aggregate_value_enum() {
    AggregateValueEnum::ArrayValue(av) => av.get_type().length()
    AggregateValueEnum::StructValue(sv) => sv.get_type().count_fields()
  }

  if index >= size {
    raise ExtractOutOfRange
  }

  let value = llvm_build_extract_value(
    self.as_builder_ref(),
    agg.as_value_ref(),
    index,
    name
  )

  BasicValueEnum::new(value)
}

pub fn Builder::build_insert_value[AV: AggregateValue, BV: BasicValue](
  self: Builder, agg: AV, value: BV, index: UInt, name: String
) -> AggregateValueEnum!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let size = match agg.as_aggregate_value_enum() {
    AggregateValueEnum::ArrayValue(av) => av.get_type().length()
    AggregateValueEnum::StructValue(sv) => sv.get_type().count_fields()
  }

  if index >= size {
    raise ExtractOutOfRange
  }

  let value = llvm_build_insert_value(
    self.as_builder_ref(),
    agg.as_value_ref(),
    value.as_value_ref(),
    index,
    name
  )

  AggregateValueEnum::new(value)
}

pub fn Builder::build_extract_element(
  self: Builder, vector: VectorValue, index: IntValue, name: String
) -> BasicValueEnum!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_extract_element(
    self.as_builder_ref(),
    vector.as_value_ref(),
    index.as_value_ref(),
    name
  )

  BasicValueEnum::new(value)
}

pub fn Builder::build_insert_element[V: BasicValue, W: VectorBaseValue](
  self: Builder, vector: W, element: V, index: IntValue, name: String
) -> W!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_insert_element(
    self.as_builder_ref(),
    vector.as_value_ref(),
    element.as_value_ref(),
    index.as_value_ref(),
    name
  )

  W::new(value)
}


pub fn Builder::build_unreachable(self: Builder) -> InstructionValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_unreachable(self.as_builder_ref())
  InstructionValue::new(value)
}

pub fn Builder::build_fence(
  self: Builder, atomic_ordering: AtomicOrdering, single_thread:Bool, name: String
) -> InstructionValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_fence(
    self.as_builder_ref(),
    atomic_ordering.into(),
    single_thread,
    name
  )
  InstructionValue::new(value)
}

pub fn Builder::build_is_null[T: PointerMathValue](
  self: Builder, ptr: T, name: String
) -> IntValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_is_null(self.as_builder_ref(), ptr.as_value_ref(), name)
  IntValue::new(value)
}


// // SubType: <I, P>(&self, int: &IntValue<I>, ptr_type: &PointerType<P>, name) -> PointerValue<P> {
// pub fn build_int_to_ptr<T: IntMathValue<'ctx>>(
//     &self,
//     int: T,
//     ptr_type: <T::BaseType as IntMathType<'ctx>>::PtrConvType,
//     name: &str,
// ) -> Result<<<T::BaseType as IntMathType<'ctx>>::PtrConvType as PointerMathType<'ctx>>::ValueType, BuilderError>
// {
//     if self.positioned.get() != PositionState::Set {
//         return Err(BuilderError::UnsetPosition);
//     }
//     let c_string = to_c_str(name);
//
//     let value = unsafe {
//         LLVMBuildIntToPtr(
//             self.builder,
//             int.as_value_ref(),
//             ptr_type.as_type_ref(),
//             c_string.as_ptr(),
//         )
//     };
//
//     unsafe { Ok(<<T::BaseType as IntMathType>::PtrConvType as PointerMathType>::ValueType::new(value)) }
// }


// // SubType: <I, P>(&self, ptr: &PointerValue<P>, int_type: &IntType<I>, name) -> IntValue<I> {
// pub fn build_ptr_to_int<T: PointerMathValue<'ctx>>(
//     &self,
//     ptr: T,
//     int_type: <T::BaseType as PointerMathType<'ctx>>::PtrConvType,
//     name: &str,
// ) -> Result<<<T::BaseType as PointerMathType<'ctx>>::PtrConvType as IntMathType<'ctx>>::ValueType, BuilderError>
// {
//     if self.positioned.get() != PositionState::Set {
//         return Err(BuilderError::UnsetPosition);
//     }
//     let c_string = to_c_str(name);
//
//     let value = unsafe {
//         LLVMBuildPtrToInt(
//             self.builder,
//             ptr.as_value_ref(),
//             int_type.as_type_ref(),
//             c_string.as_ptr(),
//         )
//     };
//
//     unsafe { Ok(<<T::BaseType as PointerMathType>::PtrConvType as IntMathType>::ValueType::new(value)) }
// }

pub fn Builder::clear_insertion_position(self: Builder) -> Unit {
  self.positioned = PositionState::NotSet
  llvm_clear_insertion_position(self.builder_ref)
}

pub fn Builder::build_switch(
  self: Builder,
  value: IntValue,
  else_block: BasicBlock,
  cases: Array[(IntValue, BasicBlock)]
) -> InstructionValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_switch(
    self.as_builder_ref(),
    value.as_value_ref(),
    else_block.as_bb_ref(),
    cases.length().reinterpret_as_uint()
  )

  cases.each(fn (pair) {
    let (case_value, case_block) = pair
    llvm_add_case(value, case_value.as_value_ref(), case_block.as_bb_ref())
  })

  InstructionValue::new(value)
}

pub fn Builder::build_select[BV: BasicValue, IMV: IntMathValue](
  self: Builder, condition: IMV, then: BV, else_: BV, name: String
) -> BasicValueEnum!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_select(
    self.as_builder_ref(),
    condition.as_value_ref(),
    then.as_value_ref(),
    else_.as_value_ref(),
    name
  )

  BasicValueEnum::new(value)
}

pub fn Builder::build_global_string(
  self: Builder, value: String, name: String
) -> GlobalValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_global_string(
    self.as_builder_ref(),
    value,
    name
  )

  GlobalValue::new(value)
}

pub fn Builder::build_global_string_ptr(
  self: Builder, value: String, name: String
) -> GlobalValue!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_global_string_ptr(
    self.as_builder_ref(),
    value,
    name
  )

  GlobalValue::new(value)
}

pub fn Builder::build_shuffle_vector[V: VectorBaseValue](
  self: Builder, left: V, right: V, mask: V, name: String
) -> V!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_shuffle_vector(
    self.as_builder_ref(),
    left.as_value_ref(),
    right.as_value_ref(),
    mask.as_value_ref(),
    name
  )

  V::new(value)
}


pub fn Builder::build_va_arg[T: BasicType](
  self: Builder, list: PointerValue, type_: T, name: String
) -> BasicValueEnum!BuilderError {
  if self.get_positioned() != PositionState::Set {
    raise UnsetPosition
  }

  let value = llvm_build_va_arg(
    self.as_builder_ref(),
    list.as_value_ref(),
    type_.as_type_ref(),
    name
  )

  BasicValueEnum::new(value)
}


// pub fn build_atomicrmw(
// pub fn build_cmpxchg<V: BasicValue<'ctx>>(

// pub fn Builder::set_current_debug_location(self: Builder, location: DILocation) -> Unit {
//   llvm_set_current_debug_location2(self.builder_ref, location.metadata_ref)
// }


// pub fn Builder::get_current_debug_location(self: Builder) -> Option[DILocation] {
//   let metadata_ref = llvm_get_current_debug_location(self.builder_ref)
//   if metadata_ref.is_null() {
//     return None
//   }
//
//   Some(DILocation::new(metadata_ref))
// }

// pub fn unset_current_debug_location(&self) {
//     use llvm_sys::core::LLVMSetCurrentDebugLocation2;
//     unsafe {
//         LLVMSetCurrentDebugLocation2(self.builder, std::ptr::null_mut());
//     }
// }

// pub fn Builder::unset_current_debug_location(self: Builder) -> Unit {
//   llvm_unset_current_debug_location2(self.builder_ref)
// }
