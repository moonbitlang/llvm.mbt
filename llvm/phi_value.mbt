// ============================================
// PhiValue
// ============================================
///| A `PhiValue` is a value that represents a phi node.
pub struct PhiValue {
  value: Value
}

///| creates a new `PhiValue` from an `@unsafe.LLVMValueRef`.
pub fn PhiValue::new(value_ref: @unsafe.LLVMValueRef) -> PhiValue {
  assert_val_ref(value_ref)

  PhiValue::{
    value: Value::new(value_ref)
  }
}

///| Returns the `Value` that this `PhiValue` wraps.
pub fn PhiValue::as_value(self: PhiValue) -> Value {
  self.value
}

///| Returns the `@unsafe.LLVMValueRef` that this `PhiValue` wraps.
pub fn PhiValue::as_value_ref(self: PhiValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

// TODO: need check, in inkwell, BasicValueEnum is not implemented for PhiValue
// pub impl BasicValue for PhiValue with as_basic_value_enum(self: PhiValue) -> BasicValueEnum {
//   BasicValueEnum::PhiValue(self)
// }

///| Add incoming values to the phi node.
// TODO: Maybe `add_incoming` and `add_incomings` be better.
pub fn PhiValue::add_incoming(self: PhiValue, incoming: Array[(&BasicValue, BasicBlock)]) -> Unit {
  let values = incoming.iter().map(fn (pair) {pair.0.as_value_ref()}).collect()
  let bbs = incoming.iter().map(fn (pair) {pair.1.as_bb_ref()}).collect()

  @unsafe.llvm_add_incoming(self.as_value_ref(), values, bbs)
}

///| Get the number of incoming values of the phi node.
pub fn PhiValue::count_incoming(self: PhiValue) -> UInt {
  @unsafe.llvm_count_incoming(self.as_value_ref())
}

///| Get the incoming value and basic block of the phi node at the given index.
pub fn PhiValue::get_incoming(self: PhiValue, index: UInt) -> (BasicValueEnum, BasicBlock)? {
  if index >= self.count_incoming() {
    return None
  }

  let bb = BasicBlock::new(@unsafe.llvm_get_incoming_block(self.as_value_ref(), index))
  let bb = match bb {
    Some(bb) => bb
    None => {
      println("Invalid BasicBlock")
      panic()
    }
  }
  let value = BasicValueEnum::new(@unsafe.llvm_get_incoming_value(self.as_value_ref(), index))

  Some((value, bb))
}

///| Get the incoming value and basic block of the phi node at the given index.
///
/// The index must be smaller that `count_incoming`. If not, undefined behavior will occur.
pub fn PhiValue::get_incoming_unchecked(self: PhiValue, index: UInt) -> (BasicValueEnum, BasicBlock) {
  let bb = BasicBlock::new(@unsafe.llvm_get_incoming_block(self.as_value_ref(), index)).unwrap()
  let value = BasicValueEnum::new(@unsafe.llvm_get_incoming_value(self.as_value_ref(), index))

  (value, bb)
}

// pub fn PhiValue::get_incomings

///| Get the name of the `PhiValue`.
/// If the value is a constant, this will return an empty string.
pub fn PhiValue::get_name(self: PhiValue) -> String {
  self.value.get_name()
}

///| Set name of the `PhiValue`.
pub fn PhiValue::set_name(self: PhiValue, name: String) -> Unit {
  self.value.set_name(name)
}

///| Determines whether or not this `PhiValue` is null.
pub fn PhiValue::is_null(self: PhiValue) -> Bool {
  self.value.is_null()
}

///| Determines whether or not this `PhiValue` is undefined.
pub fn PhiValue::is_undef(self: PhiValue) -> Bool {
  self.value.is_undef()
}

///| Attempt to convert this `PhiValue` to an `InstructionValue`, if possible.
pub fn PhiValue::as_instruction(self: PhiValue) -> InstructionValue? {
  self.value.as_instruction()
}

///| Replaces all uses of this value with another value of the same type.
pub fn PhiValue::replace_all_uses_with(self: PhiValue, new_value: PhiValue) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///| Dumps the `PhiValue` to stderr.
///
/// It's equivalent to `PhiValue::dump`.
pub fn PhiValue::print_to_stderr(self: PhiValue) -> Unit {
  self.value.print_to_stderr()
}

///| Dumps the `PhiValue` to a string.
///
/// It's equivalent to `PhiValue::to_string`.
pub fn PhiValue::print_to_string(self: PhiValue) -> String {
  self.value.print_to_string()
}

///| Dumps the `PhiValue` to a string.
///
/// It's equivalent to `PhiValue::print_to_string`.
pub fn PhiValue::to_string(self: PhiValue) -> String {
  self.value.to_string()
}

///| Dumps the `PhiValue` to stderr.
///
/// It's equivalent to `PhiValue::print_to_stderr`.
pub fn PhiValue::dump(self: PhiValue) -> Unit {
  self.value.dump()
}

pub impl Show for PhiValue with output(self: PhiValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for PhiValue with to_string(self: PhiValue) -> String {
  self.to_string()
}

