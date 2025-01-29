
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
  positioned: PositionState
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

pub fn position_at_end(self: Builder, bb: BasicBlock) -> Unit {
  let builder_ref = self.builder_ref
  let bb_ref = bb.bb_ref
  llvm_position_builder_at_end(builder_ref, bb_ref)
}

