// ===================================
// Values
// ===================================
pub struct Value {
  value_ref: LLVMValueRef
}

trait AsValueRef {
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

impl AsValueRef for Value with as_value_ref(self: Value) -> LLVMValueRef {
  self.value_ref
}

pub fn Value::is_instruction(self: Value) -> Bool {
  llvm_isa_instruction(self.as_value_ref()).is_null()
}

pub fn Value::as_instruction(self: Value) -> InstructionValue? {
  if not(self.is_instruction()) {
    return None
  }

  Some(InstructionValue::new(self.as_value_ref()))
}

pub fn Value::is_null(self: Value) -> Bool {
  llvm_is_null(self.as_value_ref()) == 1
}

pub fn Value::is_const(self: Value) -> Bool {
  llvm_is_constant(self.as_value_ref())
}

pub fn Value::set_name(self: Value, name: String) -> Unit {
  let value_ref = self.as_value_ref()
  llvm_set_value_name(value_ref, name)
}

// TODO: This API use `LLVMGetValueName2` possibly problematic
pub fn Value::get_name(self: Value) -> String {
  self.as_value_ref().get_name()

}

fn Value::is_undef(self: Value) -> Bool {
  self.as_value_ref().is_undef()
}

fn Value::get_type(self: Value) -> Type {
  let type_ref = llvm_type_of(self.as_value_ref())
  Type::new(type_ref)
}

fn Value::replace_all_uses_with(self: Value, new_value: Value) -> Unit {
  llvm_replace_all_uses_with(self.as_value_ref(), new_value.as_value_ref())
}

pub fn Value::get_first_use(self: Value) -> BasicValueUse? {
  let use_ = llvm_get_first_use(self.as_value_ref())

  if use_.is_null() {
    None
  } else {
    Some(BasicValueUse::new(use_))
  }
}

// pub fn get_section(self: Value) -> String?
// pub fn set_section(self: Value) -> String?

pub fn Value::print_to_stderr(self: Value) -> Unit {
  llvm_dump_value(self.as_value_ref())
}

pub fn Value::print_to_string(self: Value) -> String {
  llvm_print_value_to_string(self.as_value_ref())
}

pub fn Value::to_string(self: Value) -> String {
  llvm_print_value_to_string(self.as_value_ref())
}

pub fn Value::dump(self: Value) -> Unit {
  llvm_dump_value(self.as_value_ref())
}

pub impl Show for Value with output(self: Value, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// =========================================
// IntValue
// =========================================
pub struct IntValue {
  value: Value
}

pub fn IntValue::new(value_ref: LLVMValueRef) -> IntValue {
  assert_not(value_ref.is_null())

  IntValue::{
    value: Value::new(value_ref)
  }
}

pub impl AsValueRef for IntValue with as_value_ref(self: IntValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AnyValue for IntValue with as_any_value_enum(self: IntValue) -> AnyValueEnum {
  AnyValueEnum::IntValue(self)
}

pub impl BasicValue for IntValue with as_basic_value_enum(self: IntValue) -> BasicValueEnum {
  BasicValueEnum::IntValue(self)
}

pub impl BasicMetadataValue for IntValue with as_basic_metadata_value_enum(self: IntValue) -> BasicMetadataValueEnum {
  BasicMetadataValueEnum::IntValue(self)
}

pub fn IntValue::get_name(self: IntValue) -> String {
  self.value.get_name()
}

pub fn IntValue::set_name(self: IntValue, name: String) -> Unit {
  self.value.set_name(name)
}

pub fn IntValue::get_type(self: IntValue) -> IntType {
  IntType::new(self.value.get_type().as_type_ref())
}

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
  llvm_isa_constant_int(self.as_value_ref()).is_null()
}

pub fn IntValue::replace_all_uses_with(self: IntValue, new_value: IntValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

pub fn IntValue::print_to_stderr(self: IntValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn IntValue::print_to_string(self: IntValue) -> String {
  self.value.print_to_string()
}

pub fn IntValue::to_string(self: IntValue) -> String {
  self.value.to_string()
}

pub fn IntValue::dump(self: IntValue) -> Unit {
  self.value.dump()
}

pub impl Show for IntValue with output(self: IntValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ============================================
// FloatValue
// ============================================
pub struct FloatValue {
  value: Value
}

pub fn FloatValue::new(value_ref: LLVMValueRef) -> FloatValue {
  assert_not(value_ref.is_null())

  FloatValue::{
    value: Value::new(value_ref)
  }
}

pub impl AsValueRef for FloatValue with as_value_ref(self: FloatValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AnyValue for FloatValue with as_any_value_enum(self: FloatValue) -> AnyValueEnum {
  AnyValueEnum::FloatValue(self)
}

pub impl BasicValue for FloatValue with as_basic_value_enum(self: FloatValue) -> BasicValueEnum {
  BasicValueEnum::FloatValue(self)
}

pub impl BasicMetadataValue for FloatValue with as_basic_metadata_value_enum(self: FloatValue) -> BasicMetadataValueEnum {
  BasicMetadataValueEnum::FloatValue(self)
}

pub fn FloatValue::get_name(self: FloatValue) -> String {
  self.value.get_name()
}

pub fn FloatValue::set_name(self: FloatValue, name: String) -> Unit {
  self.value.set_name(name)
}

pub fn FloatValue::get_type(self: FloatValue) -> FloatType {
  FloatType::new(self.value.get_type().as_type_ref())
}

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

pub fn FloatValue::print_to_stderr(self: FloatValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn FloatValue::print_to_string(self: FloatValue) -> String {
  self.value.print_to_string()
}

pub fn FloatValue::to_string(self: FloatValue) -> String {
  self.value.to_string()
}

pub fn FloatValue::dump(self: FloatValue) -> Unit {
  self.value.dump()
}

pub impl Show for FloatValue with output(self: FloatValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ============================================
// PointerValue
// ============================================
pub struct PointerValue {
  value: Value
}

pub fn PointerValue::new(value_ref: LLVMValueRef) -> PointerValue {
  assert_not(value_ref.is_null())

  PointerValue::{
    value: Value::new(value_ref)
  }
}

pub impl AsValueRef for PointerValue with as_value_ref(self: PointerValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AnyValue for PointerValue with as_any_value_enum(self: PointerValue) -> AnyValueEnum {
  AnyValueEnum::PointerValue(self)
}

pub impl BasicValue for PointerValue with as_basic_value_enum(self: PointerValue) -> BasicValueEnum {
  BasicValueEnum::PointerValue(self)
}

pub impl BasicMetadataValue for PointerValue with as_basic_metadata_value_enum(self: PointerValue) -> BasicMetadataValueEnum {
  BasicMetadataValueEnum::PointerValue(self)
}

pub fn PointerValue::get_name(self: PointerValue) -> String {
  self.value.get_name()
}

pub fn PointerValue::set_name(self: PointerValue, name: String) -> Unit {
  self.value.set_name(name)
}

pub fn PointerValue::get_type(self: PointerValue) -> PointerType {
  PointerType::new(self.value.get_type().as_type_ref())
}

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

pub fn PointerValue::print_to_stderr(self: PointerValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn PointerValue::print_to_string(self: PointerValue) -> String {
  self.value.print_to_string()
}

pub fn PointerValue::to_string(self: PointerValue) -> String {
  self.value.to_string()
}

pub fn PointerValue::dump(self: PointerValue) -> Unit {
  self.value.dump()
}

pub impl Show for PointerValue with output(self: PointerValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ============================================
// InstructionValue
// ============================================
pub struct InstructionValue {
  value: Value
}

pub fn InstructionValue::new(value_ref: LLVMValueRef) -> InstructionValue {
  assert_not(value_ref.is_null())

  InstructionValue::{
    value: Value::new(value_ref)
  }
}

pub impl AsValueRef for InstructionValue with as_value_ref(self: InstructionValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AnyValue for InstructionValue with as_any_value_enum(self: InstructionValue) -> AnyValueEnum {
  AnyValueEnum::InstructionValue(self)
}

pub fn InstructionValue::is_a_load_inst(self: InstructionValue) -> Bool {
  llvm_isa_load_inst(self.as_value_ref()).is_null()
}

pub fn InstructionValue::is_a_store_inst(self: InstructionValue) -> Bool {
  llvm_isa_store_inst(self.as_value_ref()).is_null()
}

pub fn InstructionValue::is_a_alloca_inst(self: InstructionValue) -> Bool {
  llvm_isa_alloca_inst(self.as_value_ref()).is_null()
}

pub fn InstructionValue::is_a_getelementptr_inst(self: InstructionValue) -> Bool {
  llvm_isa_get_element_ptr_inst(self.as_value_ref()).is_null()
}
//
pub fn InstructionValue::is_a_atomicrmw_inst(self: InstructionValue) -> Bool {
  llvm_isa_atomic_rmw_inst(self.as_value_ref()).is_null()
}

pub fn InstructionValue::is_a_cmpxchg_inst(self: InstructionValue) -> Bool {
  llvm_isa_atomic_cmp_xchg_inst(self.as_value_ref()).is_null()
}

pub fn InstructionValue::get_name(self: InstructionValue) -> String {
  self.value.get_name()
}

pub fn InstructionValue::set_name(self: InstructionValue, name: String) -> Unit {
  self.value.set_name(name)
}

// pub fn get_instruction_with_name(self: InstructionValue) -> String {
//   ""
// }

pub fn InstructionValue::get_type(self: InstructionValue) -> AnyTypeEnum {
  AnyTypeEnum::new(self.value.get_type().as_type_ref())
}

pub fn InstructionValue::get_opcode(self: InstructionValue) -> InstructionOpcode {
  let opcode = llvm_get_instruction_opcode(self.as_value_ref())

  opcode.into()
}

pub fn InstructionValue::get_previous_instruction(self: InstructionValue) -> InstructionValue? {
  let value_ref = llvm_get_previous_instruction(self.as_value_ref())
  
  if value_ref.is_null() {
    None
  } else {
    Some(InstructionValue::new(value_ref))
  }
}

pub fn InstructionValue::get_next_instruction(self: InstructionValue) -> InstructionValue? {
  let value_ref = llvm_get_next_instruction(self.as_value_ref())
  
  if value_ref.is_null() {
    None
  } else {
    Some(InstructionValue::new(value_ref))
  }
}

// TODO: need review, possibly unsafe
pub fn InstructionValue::erase_from_basic_block(self: InstructionValue) -> Unit {
  llvm_instruction_erase_from_parent(self.as_value_ref())
}

pub fn InstructionValue::remove_from_basic_block(self: InstructionValue) -> Unit {
  llvm_instruction_remove_from_parent(self.as_value_ref())
}

pub fn InstructionValue::is_terminator(self: InstructionValue) -> Bool {
  llvm_isa_terminator_inst(self.as_value_ref()).is_null()
}

// pub fn InstructionValue::is_conditional(self: InstructionValue) -> Bool {
//   // Only apply to terminators
//   if self.is_terminator() {
//     // it is `is` not `isa`
//     llvm_is_conditional(self.as_value_ref()) == 1
//   } else {
//     false
//   }
// }

pub fn InstructionValue::is_tail_call(self: InstructionValue) -> Bool {
  if self.get_opcode() == InstructionOpcode::Call {
    llvm_is_tail_call(self.as_value_ref())
  } else {
    false
  }
}

// Only llvm 18..
pub fn InstructionValue::get_tail_call_kind(self: InstructionValue) -> LLVMTailCallKind? {
  if self.get_opcode() == InstructionOpcode::Call {
    Some(llvm_get_tail_call_kind(self.as_value_ref()))
  } else {
    None
  }
}

pub fn InstructionValue::can_use_fast_math_flags(self: InstructionValue) -> Bool {
  llvm_can_value_use_fast_math_flags(self.as_value_ref())
}

// ..... Need More
pub fn InstructionValue::get_fast_math_flags(self: InstructionValue) -> FastMathFlags? {
  if self.can_use_fast_math_flags() {
    Some(llvm_get_fast_math_flags(self.as_value_ref()).into())
  } else {
    None
  }
}

// pub fn get_non_negative_flag(self: InstructionValue) -> Bool?
// pub fn set_non_negative_flag(self: InstructionValue, flag: Bool) -> Unit

pub fn InstructionValue::get_disjoint_flag(self: InstructionValue) -> Bool? {
  if self.get_opcode() == InstructionOpcode::Or {
    Some(self.as_value_ref().get_is_disjoint())
  } else {
    None
  }
}

pub fn InstructionValue::set_disjoint_flag(self: InstructionValue, flag: Bool) -> Unit {
  if self.get_opcode() == InstructionOpcode::Or {
    self.as_value_ref().set_is_disjoint(flag)
  }
}

pub fn InstructionValue::get_num_operands(self: InstructionValue) -> Int {
  llvm_get_num_operands(self.as_value_ref())
}

pub fn InstructionValue::replace_all_uses_with(self: InstructionValue, new_value: InstructionValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

pub fn InstructionValue::get_volatile(self:InstructionValue)-> Result[Bool,String] {
  if not(self.is_a_load_inst()) &&
     not(self.is_a_store_inst()) &&
     not(self.is_a_atomicrmw_inst()) &&
     not(self.is_a_cmpxchg_inst()) {
    return Err("Value is not a load, store, atomicrmw or cmpxchg instruction")
  }

  Ok(llvm_get_volatile(self.as_value_ref()))
}

pub fn InstructionValue::set_volatile(self:InstructionValue, flag: Bool) -> Result[Unit,String] {
  if not(self.is_a_load_inst()) &&
     not(self.is_a_store_inst()) &&
     not(self.is_a_atomicrmw_inst()) &&
     not(self.is_a_cmpxchg_inst()) {
    return Err("Value is not a load, store, atomicrmw or cmpxchg instruction")
  }

  self.as_value_ref().set_volatile(flag)
  Ok(())
}

pub fn InstructionValue::get_allocated_type(self: InstructionValue) -> Result[BasicTypeEnum, String] {
  if not(self.is_a_alloca_inst()) {
    return Err("Value is not an alloca instruction")
  }

  Ok(BasicTypeEnum::new(llvm_get_allocated_type(self.as_value_ref())))
}

pub fn InstructionValue::get_gep_source_element_type(self: InstructionValue) -> Result[BasicTypeEnum, String] {
  if not(self.is_a_getelementptr_inst()) {
    return Err("Value is not a getelementptr instruction")
  }
  Ok(BasicTypeEnum::new(llvm_get_gep_source_element_type(self.as_value_ref())))
}

pub fn InstructionValue::get_alignment(self: InstructionValue) -> Result[UInt, String] {
  if not(self.is_a_alloca_inst()) && not(self.is_a_load_inst()) && not(self.is_a_store_inst()) {
    return Err("Value is not a load, store or alloca instruction")
  }

  Ok(llvm_get_alignment(self.as_value_ref()))
}

pub fn InstructionValue::set_alignment(self: InstructionValue, alignment: UInt) -> Result[Unit, String] {
  fn is_power_of_two(value: UInt) -> Bool {
    (value & (value - 1)) == 0
  }

  if not(is_power_of_two(alignment)) && alignment != 0 {
    return Err("Alignment must be a power of two")
  }

  if not(self.is_a_alloca_inst()) && not(self.is_a_load_inst()) && not(self.is_a_store_inst()) {
    return Err("Value is not a load, store or alloca instruction")
  }

  llvm_set_alignment(self.as_value_ref(), alignment)
  Ok(())
}

pub fn InstructionValue::get_atomic_ordering(self: InstructionValue) -> Result[AtomicOrdering, String] {
  if not(self.is_a_load_inst()) && not(self.is_a_store_inst()) {
    return Err("Value is not a load or store instruction")
  }

  Ok(llvm_get_ordering(self.as_value_ref()).into())
}

// pub fn set_atomic_ordering()
// pub fn get_operand()

// ...


pub fn InstructionValue::get_first_use(self: InstructionValue) -> BasicValueUse? {
  self.value.get_first_use()
}

pub fn InstructionValue::get_icmp_predicate(self: InstructionValue) -> IntPredicate? {
  if self.get_opcode() == InstructionOpcode::ICmp {
    Some(llvm_get_icmp_predicate(self.as_value_ref()).into())
  } else {
    None
  }
}

pub fn InstructionValue::get_fcmp_predicate(self: InstructionValue) -> FloatPredicate? {
  if self.get_opcode() == InstructionOpcode::FCmp {
    Some(llvm_get_fcmp_predicate(self.as_value_ref()).into())
  } else {
    None
  }
}

// pub fn InstructionValue::get_metadata(self: InstructionValue, kind_id: UInt) -> MetadataValue? {
//   let metadata = llvm_get_metadata(self.as_value_ref(), kind_id)
//
//   if metadata.is_null() {
//     None
//   } else {
//     Some(MetadataValue::new(metadata))
//   }
// }
//
// pub fn InstructionValue::set_metadata(self: InstructionValue, metadata: MetadataValue, kind_id: UInt) -> Result[Unit, String] {
//   if not(metadata.is_node()) {
//     return Err("Metadata is expected to be a node.")
//   }
//
//   llvm_set_metadata(self.as_value_ref(), kind_id, metadata.as_metadata_ref())
//   Ok(())
// }

pub fn InstructionValue::is_const(self: InstructionValue) -> Bool {
  self.value.is_const()
}

pub fn InstructionValue::print_to_stderr(self: InstructionValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn InstructionValue::print_to_string(self: InstructionValue) -> String {
  self.value.print_to_string()
}

pub fn InstructionValue::to_string(self: InstructionValue) -> String {
  self.value.to_string()
}

pub fn InstructionValue::dump(self: InstructionValue) -> Unit {
  self.value.dump()
}

pub impl Show for InstructionValue with output(self: InstructionValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ============================================
// StructValue
// ============================================
pub struct StructValue {
  value: Value
}

pub fn StructValue::new(value_ref: LLVMValueRef) -> StructValue {
  assert_not(value_ref.is_null())

  StructValue::{
    value: Value::new(value_ref)
  }
}

pub impl AsValueRef for StructValue with as_value_ref(self: StructValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AnyValue for StructValue with as_any_value_enum(self: StructValue) -> AnyValueEnum {
  AnyValueEnum::StructValue(self)
}

pub impl BasicValue for StructValue with as_basic_value_enum(self: StructValue) -> BasicValueEnum {
  BasicValueEnum::StructValue(self)
}

pub impl BasicMetadataValue for StructValue with as_basic_metadata_value_enum(self: StructValue) -> BasicMetadataValueEnum {
  BasicMetadataValueEnum::StructValue(self)
}

// pub fn StructValue::get_field_at_index(self: StructValue, index: Int) -> BasicValueEnum? {
//   if index >= self.count_fields() {
//     return None
//   }
//
//   let v = llvm_get_operand(self.as_value_ref(), index)
//
//   Some(BasicValueEnum::new(v))
// }

pub fn get_name(self: StructValue) -> String {
  self.value.get_name()
}

pub fn set_name(self: StructValue, name: String) -> Unit {
  self.value.set_name(name)
}

pub fn get_type(self: StructValue) -> StructType {
  StructType::new(self.value.get_type().as_type_ref())
}

pub fn is_null(self: StructValue) -> Bool {
  self.value.is_null()
}

pub fn is_undef(self: StructValue) -> Bool {
  self.value.is_undef()
}

// pub fn as_instruction(self: StructValue) -> InstructionValue? {
//   self.value.as_instruction()
// }

pub fn StructValue::replace_all_uses_with(self: StructValue, new_value: StructValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

pub fn StructValue::is_const(self: StructValue) -> Bool {
  self.value.is_const()
}


pub fn StructValue::print_to_stderr(self: StructValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn StructValue::print_to_string(self: StructValue) -> String {
  self.value.print_to_string()
}

pub fn StructValue::to_string(self: StructValue) -> String {
  self.value.to_string()
}

pub fn StructValue::dump(self: StructValue) -> Unit {
  self.value.dump()
}

pub impl Show for StructValue with output(self: StructValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ============================================
// FunctionValue
// ============================================
pub struct FunctionValue {
  value: Value
}

pub fn FunctionValue::new(value_ref: LLVMValueRef) -> FunctionValue? {
  if value_ref.is_null() {
    return None
  }

  let fv = FunctionValue::{
    value: Value::new(value_ref)
  }
  Some(fv)
}

impl AsValueRef for FunctionValue with as_value_ref(
  self: FunctionValue
) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub fn FunctionValue::get_linkage(self: FunctionValue) -> Linkage {
  llvm_get_linkage(self.as_value_ref()).into()
}

pub fn FunctionValue::set_linkage(self: FunctionValue, linkage: Linkage) -> Unit {
  llvm_set_linkage(self.as_value_ref(), linkage.into())
}

pub fn FunctionValue::is_null(self: FunctionValue) -> Bool {
  self.value.is_null()
}

pub fn FunctionValue::is_undef(self: FunctionValue) -> Bool {
  self.value.is_undef()
}

// pub fn FunctionValue::verify

pub fn FunctionValue::get_next_function(self: FunctionValue) -> FunctionValue? {
  FunctionValue::new(llvm_get_next_function(self.as_value_ref()))
}

pub fn FunctionValue::get_previous_function(self: FunctionValue) -> FunctionValue? {
  FunctionValue::new(llvm_get_previous_function(self.as_value_ref()))
}

pub fn FunctionValue::get_first_param(self: FunctionValue) -> BasicValueEnum?{
  let param = llvm_get_first_param(self.as_value_ref())

  if param.is_null() {
    None
  } else {
    Some(BasicValueEnum::new(param))
  }
}

pub fn FunctionValue::get_last_param(self: FunctionValue) -> BasicValueEnum? {
  let param = llvm_get_last_param(self.as_value_ref())

  if param.is_null() {
    None
  } else {
    Some(BasicValueEnum::new(param))
  }
}

pub fn FunctionValue::get_first_basic_block(self: FunctionValue) -> BasicBlock? {
  let bb = llvm_get_first_basic_block(self.as_value_ref())

  BasicBlock::new(bb)
}

pub fn FunctionValue::get_last_basic_block(self: FunctionValue) -> BasicBlock? {
  let bb = llvm_get_last_basic_block(self.as_value_ref())

  BasicBlock::new(bb)
}

pub fn FunctionValue::get_nth_param(self: FunctionValue, nth: UInt) -> BasicValueEnum? {
  let cnt = self.count_params()

  if nth >= cnt {
    None
  } else {
    Some(BasicValueEnum::new(llvm_get_param(self.as_value_ref(), nth)))
  }
}

pub fn FunctionValue::count_params(self: FunctionValue) -> UInt {
  llvm_count_params(self.as_value_ref())
}

pub fn FunctionValue::get_basic_blocks(self: FunctionValue) -> Array[BasicBlock] {
  let bb_refs : Array[LLVMBasicBlockRef] = llvm_get_basic_blocks(self.as_value_ref())
  bb_refs.map(fn (bb_ref) { BasicBlock::new(bb_ref).unwrap() })
}

pub fn FunctionValue::get_params(self: FunctionValue) -> Array[BasicValueEnum] {
  let param_refs : Array[LLVMValueRef] = llvm_get_params(self.as_value_ref())
  param_refs.map(fn (param_ref) { BasicValueEnum::new(param_ref) })
}


pub fn FunctionValue::get_name(self: FunctionValue) -> String {
  self.value.get_name()
}

// pub fn FunctionValue::view_function_cfg(self: FunctionValue) -> Unit {
//   llvm_view_function_cfg(self.as_value_ref())
// }
//
// pub fn FunctionValue::view_function_cfg_only(self: FunctionValue) -> Unit {
//   llvm_view_function_cfg_only(self.as_value_ref())
// }

// NOTE: `inkwell` does not provide this function
// pub fn FunctionValue::set_name(self: FunctionValue, name: String) -> Unit {
//   self.value.set_name(name)
// }

pub fn FunctionValue::get_type(self: FunctionValue) -> FunctionType {
  FunctionType::new(self.value.get_type().as_type_ref())
}

pub fn FunctionValue::has_personality_function(self: FunctionValue) -> Bool {
  llvm_has_personality_fn(self.as_value_ref())
}

pub fn FunctionValue::get_personality_function(self: FunctionValue) -> FunctionValue? {
  if not(self.has_personality_function()) {
    return None
  }

  FunctionValue::new(llvm_get_personality_fn(self.as_value_ref()))
}

pub fn FunctionValue::set_personality_function(self: FunctionValue, personality_fn: FunctionValue) -> Unit {
  llvm_set_personality_fn(self.as_value_ref(), personality_fn.as_value_ref())
}

pub fn FunctionValue::get_intrinsic_id(self: FunctionValue) -> UInt {
  llvm_get_intrinsic_id(self.as_value_ref())
}

// REVIEW: Possibly we need to use `CallConv` enum, rather than `UInt`
pub fn FunctionValue::get_call_convention(self: FunctionValue) -> UInt {
  llvm_get_function_call_conv(self.as_value_ref())
}

// REVIEW: Possibly we need to use `CallConv` enum, rather than `UInt`
pub fn FunctionValue::set_call_convention(self: FunctionValue, call_conv: UInt) -> Unit {
  llvm_set_function_call_conv(self.as_value_ref(), call_conv)
}

pub fn FunctionValue::get_gc(self: FunctionValue) -> String {
  llvm_get_gc(self.as_value_ref())
}

pub fn FunctionValue::replace_all_uses_with(
  self: FunctionValue, new_value: FunctionValue
) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

pub fn FunctionValue::add_attribute(
  self: FunctionValue, loc: AttributeLoc, attribute: Attribute
) -> Unit {
  llvm_add_attribute_at_index(self.as_value_ref(), loc.get_index(), attribute.attribute)
}

pub fn FunctionValue::count_attributes(self: FunctionValue, loc: AttributeLoc) -> UInt {
  llvm_get_attribute_count_at_index(self.as_value_ref(), loc.get_index())
}

pub fn FunctionValue::attributes(
  self: FunctionValue, loc: AttributeLoc
) -> Array[Attribute] {
  let attr_refs = llvm_get_attributes_at_index(self.as_value_ref(), loc.get_index())

  attr_refs.map(fn (attr_ref) { Attribute::new(attr_ref) })
}

pub fn FunctionValue::remove_string_attribute(
  self: FunctionValue, loc: AttributeLoc, key: String
) -> Unit {
  llvm_remove_string_attribute_at_index(self.as_value_ref(), loc.get_index(), key)
}

pub fn FunctionValue::remove_enum_attribute(
  self: FunctionValue, loc: AttributeLoc, kind_id: UInt
) -> Unit {
  llvm_remove_enum_attribute_at_index(self.as_value_ref(), loc.get_index(), kind_id)
}

pub fn FunctionValue::get_enum_attribute(self: FunctionValue, loc: AttributeLoc, kind_id: UInt) -> Attribute? {
  let attr_ref = llvm_get_enum_attribute_at_index(self.as_value_ref(), loc.get_index(), kind_id)

  if attr_ref.is_null() {
    None
  } else {
    Some(Attribute::new(attr_ref))
  }
}

pub fn FunctionValue::get_string_attribute(self: FunctionValue, loc: AttributeLoc, key: String) -> Attribute? {
  let attr_ref = llvm_get_string_attribute_at_index(self.as_value_ref(), loc.get_index(), key)

  if attr_ref.is_null() {
    None
  } else {
    Some(Attribute::new(attr_ref))
  }
}

pub fn FunctionValue::set_param_alignment(
  self: FunctionValue, param_index: UInt, alignment: UInt
) -> Unit {
  match self.get_nth_param(param_index) {
    Some(param) => {
      llvm_set_param_alignment(param.as_value_ref(), alignment)
    }
    _ => ()
  }
}

pub fn FunctionValue::as_global_value(self: FunctionValue) -> GlobalValue {
  GlobalValue::new(self.as_value_ref())
}

// pub fn FunctionValue::set_subprogram(self: FunctionValue, subprogram: DISubprogram) -> Unit {
//   llvm_set_subprogram(self.as_value_ref(), subprogram.as_metadata_ref())
// }

// pub fn FunctionValue::get_subprogram(self: FunctionValue) -> DISubprogram? {
//   let subprogram = llvm_get_subprogram(self.as_value_ref())
//
//   if subprogram.is_null() {
//     None
//   } else {
//     Some(DISubprogram::new(subprogram))
//   }
// }

// pub fn FunctionValue::get_section(self: FunctionValue) -> String {
//   self.value.get_section()
// }
//
// pub fn FunctionValue::set_section(self: FunctionValue, section: String) -> Unit {
//   self.value.set_section(section)
// }

pub fn FunctionValue::delete(self: FunctionValue) -> Unit {
  llvm_delete_function(self.as_value_ref())
}

pub fn FunctionValue::print_to_stderr(self: FunctionValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn FunctionValue::print_to_string(self: FunctionValue) -> String {
  self.value.print_to_string()
}

pub fn FunctionValue::to_string(self: FunctionValue) -> String {
  self.value.to_string()
}

pub fn FunctionValue::dump(self: FunctionValue) -> Unit {
  self.value.dump()
}

pub impl Show for FunctionValue with output(self: FunctionValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}


// ============================================
// ArrayValue
// ============================================
pub struct ArrayValue {
  value: Value
}

pub fn ArrayValue::new(value_ref: LLVMValueRef) -> ArrayValue {
  assert_not(value_ref.is_null())

  ArrayValue::{
    value: Value::new(value_ref)
  }
}

pub impl AsValueRef for ArrayValue with as_value_ref(self: ArrayValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AnyValue for ArrayValue with as_any_value_enum(self: ArrayValue) -> AnyValueEnum {
  AnyValueEnum::ArrayValue(self)
}

pub impl BasicValue for ArrayValue with as_basic_value_enum(self: ArrayValue) -> BasicValueEnum {
  BasicValueEnum::ArrayValue(self)
}

pub impl BasicMetadataValue for ArrayValue with as_basic_metadata_value_enum(self: ArrayValue) -> BasicMetadataValueEnum {
  BasicMetadataValueEnum::ArrayValue(self)
}

pub fn ArrayValue::get_name(self: ArrayValue) -> String {
  self.value.get_name()
}

pub fn ArrayValue::set_name(self: ArrayValue, name: String) -> Unit {
  self.value.set_name(name)
}

pub fn ArrayValue::get_type(self: ArrayValue) -> ArrayType {
  ArrayType::new(self.value.get_type().as_type_ref())
}

pub fn ArrayValue::is_null(self: ArrayValue) -> Bool {
  self.value.is_null()
}

pub fn ArrayValue::is_undef(self: ArrayValue) -> Bool {
  self.value.is_undef()
}

// pub fn ArrayValue::as_instruction(self: ArrayValue) -> InstructionValue? {
//   self.as_value_ref().as_instruction()
// }

pub fn ArrayValue::replace_all_uses_with(self: ArrayValue, new_value: ArrayValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

pub fn ArrayValue::is_const(self: ArrayValue) -> Bool {
  self.value.is_const()
}

// TODO: Check if it is correct
pub fn ArrayValue::is_const_string(self: ArrayValue) -> Bool {
  // llvm_is_constant_string(self.as_value_ref())
  self.as_value_ref().is_constant_string()
}

pub fn ArrayValue::print_to_stderr(self: ArrayValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn ArrayValue::print_to_string(self: ArrayValue) -> String {
  self.value.print_to_string()
}

pub fn ArrayValue::to_string(self: ArrayValue) -> String {
  self.value.to_string()
}

pub fn ArrayValue::dump(self: ArrayValue) -> Unit {
  self.value.dump()
}

pub impl Show for ArrayValue with output(self: ArrayValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ============================================
// VectorValue
// ============================================
pub struct VectorValue {
  value: Value
}

pub fn VectorValue::new(value_ref: LLVMValueRef) -> VectorValue {
  assert_not(value_ref.is_null())

  VectorValue::{
    value: Value::new(value_ref)
  }
}

pub impl AsValueRef for VectorValue with as_value_ref(self: VectorValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AnyValue for VectorValue with as_any_value_enum(self: VectorValue) -> AnyValueEnum {
  AnyValueEnum::VectorValue(self)
}

pub impl BasicValue for VectorValue with as_basic_value_enum(self: VectorValue) -> BasicValueEnum {
  BasicValueEnum::VectorValue(self)
}

pub impl BasicMetadataValue for VectorValue with as_basic_metadata_value_enum(self: VectorValue) -> BasicMetadataValueEnum {
  BasicMetadataValueEnum::VectorValue(self)
}

pub fn VectorValue::is_const(self: VectorValue) -> Bool {
  self.value.is_const()
}

pub fn VectorValue::is_constant_vector(self: VectorValue) -> Bool {
  llvm_isa_constant_vector(self.as_value_ref()).is_null()
}

pub fn VectorValue::is_constant_data_vector(self: VectorValue) -> Bool {
  llvm_isa_constant_data_vector(self.as_value_ref()).is_null()
}

pub fn VectorValue::get_name(self: VectorValue) -> String {
  self.value.get_name()
}

pub fn VectorValue::set_name(self: VectorValue, name: String) -> Unit {
  self.value.set_name(name)
}

pub fn VectorValue::get_type(self: VectorValue) -> VectorType {
  VectorType::new(self.value.get_type().as_type_ref())
}

pub fn VectorValue::is_null(self: VectorValue) -> Bool {
  self.value.is_null()
}

pub fn VectorValue::is_undef(self: VectorValue) -> Bool {
  self.value.is_undef()
}

pub fn VectorValue::as_instruction(self: VectorValue) -> InstructionValue? {
  self.value.as_instruction()
}

pub fn VectorValue::replace_all_uses_with(self: VectorValue, new_value: VectorValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

pub fn VectorValue::const_shuffle_vector(self: VectorValue, right: VectorValue, mask: VectorValue) -> VectorValue {
  VectorValue::new(llvm_const_shuffle_vector(self.as_value_ref(), right.as_value_ref(), mask.as_value_ref()))
}

pub fn VectorValue::print_to_stderr(self: VectorValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn VectorValue::print_to_string(self: VectorValue) -> String {
  self.value.print_to_string()
}

pub fn VectorValue::to_string(self: VectorValue) -> String {
  self.value.to_string()
}

pub fn VectorValue::dump(self: VectorValue) -> Unit {
  self.value.dump()
}

pub impl Show for VectorValue with output(self: VectorValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ============================================
// PhiValue
// ============================================
pub struct PhiValue {
  value: Value
}

pub fn PhiValue::new(value_ref: LLVMValueRef) -> PhiValue {
  assert_not(value_ref.is_null())

  PhiValue::{
    value: Value::new(value_ref)
  }
}

pub impl AsValueRef for PhiValue with as_value_ref(self: PhiValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AnyValue for PhiValue with as_any_value_enum(self: PhiValue) -> AnyValueEnum {
  AnyValueEnum::PhiValue(self)
}

// TODO: need check, in inkwell, BasicValueEnum is not implemented for PhiValue
// pub impl BasicValue for PhiValue with as_basic_value_enum(self: PhiValue) -> BasicValueEnum {
//   BasicValueEnum::PhiValue(self)
// }

pub fn PhiValue::add_incoming(self: PhiValue, incoming: Array[(&BasicValue, BasicBlock)]) -> Unit {
  let values = incoming.iter().map(fn (pair) {pair.0.as_value_ref()}).collect()
  let bbs = incoming.iter().map(fn (pair) {pair.1.as_bb_ref()}).collect()
  let cnt = incoming.length()

  llvm_add_incoming(self.as_value_ref(), values, bbs, cnt.reinterpret_as_uint())
}

pub fn PhiValue::count_incoming(self: PhiValue) -> UInt {
  llvm_count_incoming(self.as_value_ref())
}

pub fn PhiValue::get_name(self: PhiValue) -> String {
  self.value.get_name()
}

pub fn PhiValue::set_name(self: PhiValue, name: String) -> Unit {
  self.value.set_name(name)
}

pub fn PhiValue::is_null(self: PhiValue) -> Bool {
  self.value.is_null()
}

pub fn PhiValue::is_undef(self: PhiValue) -> Bool {
  self.value.is_undef()
}

pub fn PhiValue::print_to_stderr(self: PhiValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn PhiValue::print_to_string(self: PhiValue) -> String {
  self.value.print_to_string()
}

pub fn PhiValue::to_string(self: PhiValue) -> String {
  self.value.to_string()
}

pub fn PhiValue::dump(self: PhiValue) -> Unit {
  self.value.dump()
}

pub impl Show for PhiValue with output(self: PhiValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ============================================
// ScalableVectorValue
// ============================================
pub struct ScalableVectorValue {
  value: Value
}

pub fn ScalableVectorValue::new(value_ref: LLVMValueRef) -> ScalableVectorValue {
  assert_not(value_ref.is_null())

  ScalableVectorValue::{
    value: Value::new(value_ref)
  }
}

pub impl AsValueRef for ScalableVectorValue with as_value_ref(self: ScalableVectorValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub impl AnyValue for ScalableVectorValue with as_any_value_enum(self: ScalableVectorValue) -> AnyValueEnum {
  AnyValueEnum::ScalableVectorValue(self)
}

pub impl BasicValue for ScalableVectorValue with as_basic_value_enum(self: ScalableVectorValue) -> BasicValueEnum {
  BasicValueEnum::ScalableVectorValue(self)
}

pub impl BasicMetadataValue for ScalableVectorValue with as_basic_metadata_value_enum(self: ScalableVectorValue) -> BasicMetadataValueEnum {
  BasicMetadataValueEnum::ScalableVectorValue(self)
}

pub fn ScalableVectorValue::is_const(self: ScalableVectorValue) -> Bool {
  self.value.is_const()
}

pub fn ScalableVectorValue::get_name(self: ScalableVectorValue) -> String {
  self.value.get_name()
}

pub fn ScalableVectorValue::set_name(self: ScalableVectorValue, name: String) -> Unit {
  self.value.set_name(name)
}

pub fn ScalableVectorValue::get_type(self: ScalableVectorValue) -> ScalableVectorType {
  ScalableVectorType::new(self.value.get_type().as_type_ref())
}

pub fn ScalableVectorValue::is_null(self: ScalableVectorValue) -> Bool {
  self.value.is_null()
}

pub fn ScalableVectorValue::is_undef(self: ScalableVectorValue) -> Bool {
  self.value.is_undef()
}

pub fn ScalableVectorValue::as_instruction(self: ScalableVectorValue) -> InstructionValue? {
  self.value.as_instruction()
}

pub fn  ScalableVectorValue::const_extract_element(
  self: ScalableVectorValue, index: IntValue
) -> BasicValueEnum {
  BasicValueEnum::new(llvm_const_extract_element(self.as_value_ref(), index.as_value_ref()))
}

pub fn ScalableVectorValue::const_insert_element(self: ScalableVectorValue, element: &BasicValue, index: IntValue) -> BasicValueEnum {
  BasicValueEnum::new(llvm_const_insert_element(self.as_value_ref(), element.as_value_ref(), index.as_value_ref()))
}

pub fn ScalableVectorValue::replace_all_uses_with(self: ScalableVectorValue, new_value: ScalableVectorValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

pub fn ScalableVectorValue::const_shuffle_vector(self: ScalableVectorValue, right: ScalableVectorValue, mask: ScalableVectorValue) -> ScalableVectorValue {
  ScalableVectorValue::new(llvm_const_shuffle_vector(self.as_value_ref(), right.as_value_ref(), mask.as_value_ref()))
}

pub fn ScalableVectorValue::print_to_stderr(self: ScalableVectorValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn ScalableVectorValue::print_to_string(self: ScalableVectorValue) -> String {
  self.value.print_to_string()
}

pub fn ScalableVectorValue::to_string(self: ScalableVectorValue) -> String {
  self.value.to_string()
}

pub fn ScalableVectorValue::dump(self: ScalableVectorValue) -> Unit {
  self.value.dump()
}

pub impl Show for ScalableVectorValue with output(self: ScalableVectorValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ============================================
// GlobalValue
// ============================================
pub struct GlobalValue {
  value: Value
}

pub fn GlobalValue::new(value_ref: LLVMValueRef) -> GlobalValue {
  assert_not(value_ref.is_null())

  GlobalValue::{
    value: Value::new(value_ref)
  }
}

pub impl AsValueRef for GlobalValue with as_value_ref(self: GlobalValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub fn GlobalValue::get_name(self: GlobalValue) -> String {
  self.value.get_name()
}

pub fn GlobalValue::set_name(self: GlobalValue, name: String) -> Unit {
  self.value.set_name(name)
}

pub fn GlobalValue::get_previous_global(self: GlobalValue) -> GlobalValue? {
  let value_ref = llvm_get_previous_global(self.as_value_ref())
  
  if value_ref.is_null() {
    None
  } else {
    Some(GlobalValue::new(value_ref))
  }
}

pub fn GlobalValue::get_next_global(self: GlobalValue) -> GlobalValue? {
  let value_ref = llvm_get_next_global(self.as_value_ref())
  
  if value_ref.is_null() {
    None
  } else {
    Some(GlobalValue::new(value_ref))
  }
}

pub fn GlobalValue::get_dll_storge_class(self: GlobalValue) -> DLLStorageClass {
  llvm_get_dll_storage_class(self.as_value_ref()).into()
}

// TODO: enable it when `llvm_set_dll_storage_class` is available
// pub fn GlobalValue::set_dll_storage_class(self: GlobalValue, storage_class: DLLStorageClass) -> Unit {
//   llvm_set_dll_storage_class(self.as_value_ref(), storage_class)
// }

pub fn GlobalValue::get_initializer(self: GlobalValue) -> Option[BasicValueEnum] {
  let value_ref = llvm_get_initializer(self.as_value_ref())

  if value_ref.is_null() {
    None
  } else {
    Some(BasicValueEnum::new(value_ref))
  }
}

pub fn GlobalValue::set_initializer(self: GlobalValue, value: BasicValueEnum) -> Unit {
  llvm_set_initializer(self.as_value_ref(), value.as_value_ref())
}

pub fn GlobalValue::is_thread_local(self: GlobalValue) -> Bool {
  llvm_is_thread_local(self.as_value_ref())
}

pub fn GlobalValue::set_thread_local(self: GlobalValue, is_thread_local: Bool) -> Unit {
  llvm_set_thread_local(self.as_value_ref(), is_thread_local)
}

// pub fn GlobalValue::get_thread_local_mode(self: GlobalValue) -> ThreadLocalMode;
// pub fn GlobalValue::set_thread_local_mode(self: GlobalValue) -> ThreadLocalMode;

pub fn GlobalValue::is_declaration(self: GlobalValue) -> Bool {
  llvm_is_declaration(self.as_value_ref())
}

pub fn GlobalValue::has_unnamed_addr(self: GlobalValue) -> Bool {
  llvm_get_unnamed_address(self.as_value_ref()) == LLVMUnnamedAddr::LLVMGlobalUnnamedAddr
}

// REVIEW: Would use `UnnamedAddr` instead of `LLVMUnnamedAddr` be better?
pub fn GlobalValue::set_unnamed_addr(self: GlobalValue, has_unnamed_addr: Bool) -> Unit {
  // llvm_set_unnamed_addr(self.as_value_ref(), has_unnamed_addr)
  if has_unnamed_addr {
    llvm_set_unnamed_address(self.as_value_ref(), LLVMUnnamedAddr::LLVMGlobalUnnamedAddr)
  } else {
    llvm_set_unnamed_address(self.as_value_ref(), LLVMUnnamedAddr::LLVMNoUnnamedAddr)
  }
}

pub fn GlobalValue::is_constant(self: GlobalValue) -> Bool {
  llvm_is_global_constant(self.as_value_ref())
}

pub fn GlobalValue::set_constant(self: GlobalValue, is_constant: Bool) -> Unit {
  llvm_set_global_constant(self.as_value_ref(), is_constant)
}

pub fn GlobalValue::is_externally_initialized(self: GlobalValue) -> Bool {
  llvm_is_externally_initialized(self.as_value_ref())
}

pub fn GlobalValue::set_externally_initialized(self: GlobalValue, is_externally_initialized: Bool) -> Unit {
  llvm_set_externally_initialized(self.as_value_ref(), is_externally_initialized)
}

pub fn GlobalValue::set_visibility(self: GlobalValue, visibility: GlobalVisibility) -> Unit {
  llvm_set_visibility(self.as_value_ref(), visibility.into())
}

pub fn GlobalVisibility::get_visibility(self: GlobalValue) -> GlobalVisibility {
  llvm_get_visibility(self.as_value_ref()).into()
}

pub fn GlobalValue::get_section(self: GlobalValue) -> String {
  llvm_get_section(self.as_value_ref())
}

pub fn GlobalValue::set_section(self: GlobalValue, section: String) -> Unit {
  llvm_set_section(self.as_value_ref(), section)
}

pub fn GlobalValue::delete(self: GlobalValue) -> Unit {
  llvm_delete_global(self.as_value_ref())
}

pub fn GlobalValue::as_pointer_value(self: GlobalValue) -> PointerValue {
  PointerValue::new(self.as_value_ref())
}

pub fn GlobalValue::get_alignment(self: GlobalValue) -> UInt {
  llvm_get_alignment(self.as_value_ref())
}

pub fn GlobalValue::set_alignment(self: GlobalValue, alignment: UInt) -> Unit {
  llvm_set_alignment(self.as_value_ref(), alignment)
}

pub fn GlobalValue::set_metadata(
  self: GlobalValue, metadata: MetadataValue, kind_id: UInt
) -> Unit {
  llvm_global_set_metadata(self.as_value_ref(), kind_id, metadata.as_metadata_ref())
}

// TODO: enable it when `llvm_get_metadata` is available
// pub fn GlobalValue::get_comdat(self: GlobalValue) -> Comdat? {
//   let comdat_ref = llvm_get_comdat(self.as_value_ref())
//
//   if comdat_ref.is_null() {
//     None
//   } else {
//     Some(Comdat::new(comdat_ref))
//   }
// }

pub fn GlobalValue::set_unnamed_address(
  self: GlobalValue, unnamed_address: UnnamedAddress
) -> Unit {
  llvm_set_unnamed_address(self.as_value_ref(), unnamed_address.into())
}

// pub fn GlobalValue::get_linkage(self: GlobalValue) -> Linkage {
//   llvm_get_linkage(self.as_value_ref()).into()
// }
//
// pub fn GlobalValue::set_linkage(self: GlobalValue, linkage: Linkage) -> Unit {
//   llvm_set_linkage(self.as_value_ref(), linkage.into())
// }

pub fn GlobalValue::get_value_type(self: GlobalValue) -> AnyTypeEnum {
  let ty = llvm_global_get_value_type(self.as_value_ref())
  AnyTypeEnum::new(ty)
}

pub fn GlobalValue::print_to_stderr(self: GlobalValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn GlobalValue::print_to_string(self: GlobalValue) -> String {
  self.value.print_to_string()
}

pub fn GlobalValue::to_string(self: GlobalValue) -> String {
  self.value.to_string()
}

pub fn GlobalValue::dump(self: GlobalValue) -> Unit {
  self.value.dump()
}

pub impl Show for GlobalValue with output(self: GlobalValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ============================================
// MetadataValue
// ============================================
pub struct MetadataValue {
  value: Value
}

pub impl AsValueRef for MetadataValue with as_value_ref(self: MetadataValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub impl BasicMetadataValue for MetadataValue with as_basic_metadata_value_enum(self: MetadataValue) -> BasicMetadataValueEnum {
  BasicMetadataValueEnum::MetadataValue(self)
}

pub fn MetadataValue::new(value_ref: LLVMValueRef) -> MetadataValue {
  assert_not(value_ref.is_null())
  assert_not(llvm_isa_md_node(value_ref).is_null())
  assert_not(llvm_isa_md_string(value_ref).is_null())

  MetadataValue::{
    value: Value::new(value_ref)
  }
}

pub fn MetadataValue::as_metadata_ref(self: MetadataValue) -> LLVMMetadataRef {
  llvm_value_as_metadata(self.as_value_ref())
}

pub fn MetadataValue::get_name(self: MetadataValue) -> String {
  self.value.get_name()
}

// Need more

pub fn MetadataValue::replace_all_uses_with(self: MetadataValue, new_value: MetadataValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

pub fn MetadataValue::print_to_stderr(self: MetadataValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn MetadataValue::print_to_string(self: MetadataValue) -> String {
  self.value.print_to_string()
}

pub fn MetadataValue::to_string(self: MetadataValue) -> String {
  self.value.to_string()
}

pub fn MetadataValue::dump(self: MetadataValue) -> Unit {
  self.value.dump()
}

pub impl Show for MetadataValue with output(self: MetadataValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

// ============================================
// CallSiteValue
// ============================================
pub struct CallSiteValue {
  value: Value
}

pub fn CallSiteValue::new(value_ref: LLVMValueRef) -> CallSiteValue {
  assert_not(value_ref.is_null())

  CallSiteValue::{
    value: Value::new(value_ref)
  }
}

pub impl AsValueRef for CallSiteValue with as_value_ref(self: CallSiteValue) -> LLVMValueRef {
  self.value.as_value_ref()
}

pub fn CallSiteValue::set_tail_call(self: CallSiteValue, tail_call: Bool) -> Unit {
  self.as_value_ref().set_tail_call(tail_call)
}

pub fn CallSiteValue::is_tail_call(self: CallSiteValue) -> Bool {
  self.as_value_ref().is_tail_call()
}


pub fn CallSiteValue::get_tail_call_kind(self: CallSiteValue) -> LLVMTailCallKind {
  self.as_value_ref().get_tail_call_kind()
}

pub fn CallSiteValue::set_tail_call_kind(self: CallSiteValue, kind: LLVMTailCallKind) -> Unit {
  self.as_value_ref().set_tail_call_kind(kind)
}

///| Try to convert this `CallSiteValue` to a `BasicValueEnum` if not a void return type.
pub fn CallSiteValue::try_as_basic_value(
  self: CallSiteValue
) -> Either[BasicValueEnum, InstructionValue] {
  let kind = llvm_get_type_kind(llvm_type_of(self.as_value_ref()))

  match kind {
    LLVMTypeKind::LLVMVoidTypeKind => Right(InstructionValue::new(self.as_value_ref()))
    _ => Left(BasicValueEnum::new(self.as_value_ref()))
  }
}

pub fn CallSiteValue::add_attribute(
  self: CallSiteValue, loc: AttributeLoc, attribute: Attribute
) -> Unit {
  llvm_add_call_site_attribute(self.as_value_ref(), loc.get_index(), attribute.attribute)
}

pub fn CallSiteValue::get_called_fn_value(self: CallSiteValue) -> FunctionValue {
  FunctionValue::new(llvm_get_called_value(self.as_value_ref())).unwrap()
}

pub fn CallSiteValue::count_attributes(self: CallSiteValue, loc: AttributeLoc) -> UInt {
  llvm_get_call_site_attribute_count(self.as_value_ref(), loc.get_index())
}

// REVIEW: Possibly need to check attr_refs is null or not
pub fn CallSiteValue::attributes(self: CallSiteValue, loc: AttributeLoc) -> Array[Attribute] {
  let attr_refs = llvm_get_call_site_attributes(self.as_value_ref(), loc.get_index())
  attr_refs.map(fn (r) {Attribute::new(r)})
}

// REVIEW: Possibly need to check attr_ref is null or not
pub fn CallSiteValue::get_enum_attribute(
  self: CallSiteValue, loc: AttributeLoc, kind_id: UInt
) -> Attribute? {
  let attr_ref = llvm_get_call_site_enum_attribute(self.as_value_ref(), loc.get_index(), kind_id)
  Some(Attribute::new(attr_ref))
}

// REVIEW: Possibly need to check attr_ref is null or not
pub fn CallSiteValue::get_string_attribute(
  self: CallSiteValue, loc: AttributeLoc, key: String
) -> Attribute? {
  let attr_ref = llvm_get_call_site_string_attribute(self.as_value_ref(), loc.get_index(), key)
  Some(Attribute::new(attr_ref))
}

pub fn CallSiteValue::remove_attribute(
  self: CallSiteValue, loc: AttributeLoc, kind_id: UInt
) ->  Unit {
  llvm_remove_call_site_enum_attribute(self.as_value_ref(), loc.get_index(), kind_id)
}

pub fn CallSiteValue::remove_string_attribute(
  self: CallSiteValue, loc: AttributeLoc, key: String
) -> Unit {
  llvm_remove_call_site_string_attribute(self.as_value_ref(), loc.get_index(), key)
}

pub fn CallSiteValue::count_arguments(self: CallSiteValue) -> UInt {
  llvm_get_num_arg_operands(self.as_value_ref())
}

pub fn CallSiteValue::get_call_convention(
  self: CallSiteValue
) -> UInt {
  llvm_get_instruction_call_conv(self.as_value_ref())
}

pub fn CallSiteValue::set_call_convention(
  self: CallSiteValue, call_conv: UInt
) -> Unit {
  llvm_set_instruction_call_conv(self.as_value_ref(), call_conv)
}

pub fn CallSiteValue::set_alignment_attribute(
  self: CallSiteValue, loc: AttributeLoc, alignment: UInt
) -> Unit {
  // assert alignment.count_ones()

  llvm_set_instr_param_alignment(self.as_value_ref(), loc.get_index(), alignment)
}

// pub fn CallSiteValue::get_operand_bundles(self: CallSiteValue) -> Array[OperandBundle] {
//   let bundle_refs = llvm_get_instruction_operand_bundles(self.as_value_ref())
//   bundle_refs.map(fn (r) {OperandBundle::new(r)})
// }


pub fn CallSiteValue::print_to_stderr(self: CallSiteValue) -> Unit {
  self.value.print_to_stderr()
}

pub fn CallSiteValue::print_to_string(self: CallSiteValue) -> String {
  self.value.print_to_string()
}

pub fn CallSiteValue::to_string(self: CallSiteValue) -> String {
  self.value.to_string()
}

pub fn CallSiteValue::dump(self: CallSiteValue) -> Unit {
  self.value.dump()
}

pub impl Show for CallSiteValue with output(
  self: CallSiteValue, logger: &Logger
) -> Unit {
  logger.write_string(self.to_string())
}

// ============================================
// CallableValue
// ============================================
// pub struct CallableValue {
//   either_value: Either[FunctionValue, PointerValue]
// }
//
// pub impl AsValueRef for CallableValue with as_value_ref(self: CallableValue) -> LLVMValueRef {
//   match self.either_value {
//     Left(f) => f.as_value_ref()
//     Right(p) => p.as_value_ref()
//   }
// }
