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

// pub fn Value::is_instruction(self: Value) -> Bool;
// pub fn Value::as_instruction(self: Value) -> InstructionValue;

pub fn Value::is_null(self: Value) -> Bool {
  llvm_is_null(self.as_value_ref()) == 1
}

pub fn Value::is_const(self: Value) -> Bool {
  llvm_is_constant(self.as_value_ref()) == 1
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

pub fn PointerValue::dump(self: PointerValue) -> Unit {
  self.value.dump()
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

pub fn FunctionValue::set_name(self: FunctionValue, name: String) -> Unit {
  self.value.set_name(name)
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
