
pub struct BasicBlock {
  bb_ref : LLVMBasicBlockRef
}

pub fn BasicBlock::as_bb_ref(self: BasicBlock) -> LLVMBasicBlockRef {
  self.bb_ref
}

pub fn BasicBlock::new(basic_block_ref : LLVMBasicBlockRef) -> BasicBlock? {

  if basic_block_ref.is_null() {
    return None
  }

  let bb = BasicBlock::{
    bb_ref : basic_block_ref
  }
  Some(bb)
}

pub fn BasicBlock::get_parent(self: BasicBlock) -> FunctionValue? {
  FunctionValue::new(llvm_get_basic_block_parent(self.as_bb_ref()))
}

pub fn BasicBlock::get_previous_basic_block(self: BasicBlock) -> BasicBlock? {

  match self.get_parent() {
    None => return None
    _ => ()
  }

  BasicBlock::new(llvm_get_previous_basic_block(self.as_bb_ref()))
}

pub fn BasicBlock::get_next_basic_block(self: BasicBlock) -> BasicBlock? {

  match self.get_parent() {
    None => return None
    _ => ()
  }

  BasicBlock::new(llvm_get_next_basic_block(self.as_bb_ref()))
}

pub fn BasicBlock::move_before(self: BasicBlock, other: BasicBlock) -> Result[Unit, Unit] {
  match (self.get_parent(), other.get_parent()) {
    (None, _) => return Err(())
    (_, None) => return Err(())
    _ => ()
  }

  llvm_move_basic_block_before(self.as_bb_ref(), other.as_bb_ref())
  Ok(())
}

pub fn BasicBlock::move_after(self: BasicBlock, other: BasicBlock) -> Result[Unit, Unit] {
  match (self.get_parent(), other.get_parent()) {
    (None, _) => return Err(())
    (_, None) => return Err(())
    _ => ()
  }

  llvm_move_basic_block_after(self.as_bb_ref(), other.as_bb_ref())
  Ok(())
}

pub fn BasicBlock::get_first_instruction(self: BasicBlock) -> InstructionValue? {
  let inst = llvm_get_first_instruction(self.as_bb_ref())

  if inst.is_null() {
    return None
  }

  Some(InstructionValue::new(inst))
}

pub fn BasicBlock::get_last_instruction(self: BasicBlock) -> InstructionValue? {
  let inst = llvm_get_last_instruction(self.as_bb_ref())

  if inst.is_null() {
    return None
  }

  Some(InstructionValue::new(inst))
}

// pub fn BasicBlock::get_instruction_with_name(self: BasicBlock, name: String) -> InstructionValue? {
//   let inst = self.get_first_instruction()
//   inst.get_instruction_with_name(name)
// }

pub fn BasicBlock::get_terminator(self: BasicBlock) -> InstructionValue? {
  let inst = llvm_get_basic_block_terminator(self.as_bb_ref())

  if inst.is_null() {
    return None
  }

  Some(InstructionValue::new(inst))
}

// pub fn BasicBlock::get_instructions(self) -> InstructionIter

pub fn remove_from_function(self: BasicBlock) -> Result[Unit, Unit] {
  match self.get_parent() {
    None => return Err(())
    _ => ()
  }

  llvm_remove_basic_block_from_parent(self.as_bb_ref())
  Ok(())
}

pub fn BasicBlock::delete(self: BasicBlock) -> Result[Unit, Unit] {
  match self.get_parent() {
    None => return Err(())
    _ => ()
  }

  llvm_delete_basic_block(self.as_bb_ref())

  Ok(())
}

pub fn BasicBlock::get_context(self: BasicBlock) -> Context {
  Context::new(llvm_get_type_context(llvm_type_of(self.as_bb_ref().as_value_ref())))
}

pub fn BasicBlock::get_name(self: BasicBlock) -> String {
  self.as_bb_ref().get_name()
}

pub fn BasicBlock::set_name(self: BasicBlock, name: String) -> Unit {
  self.as_bb_ref().as_value_ref().set_name(name)
}

// TODO: Inplement Eq
// pub fn BasicBlock::replace_all_uses_with(self: BasicBlock, other: BasicBlock) -> Unit {
//   let value = self.as_bb_ref().as_value_ref()
//   let other = other.as_bb_ref().as_value_ref()
//
//   if value != other {
//     value.replace_all_uses_with(other)
//   }
// }

pub fn BasicBlock::get_first_use(self: BasicBlock) -> BasicValueUse? {
  let use_ = self.as_bb_ref().as_value_ref().get_first_use()

  if use_.is_null() {
    return None
  }

  Some(BasicValueUse::new(use_))
}

pub fn BasicBlock::get_address(self: BasicBlock) -> PointerValue? {
  let parent = self.get_parent()
  match parent {
    None => return None
    _ => ()
  }
  guard let Some(parent) = parent

  let prev = self.get_previous_basic_block()
  match prev {
    None => return None
    _ => ()
  }

  let value = PointerValue::new(llvm_block_address(parent.as_value_ref(), self.as_bb_ref()))

  if value.is_null() {
    return None
  }

  Some(value)
}

// pub fn BasicBlock::to_string(self: BasicBlock) -> String {
//   self.as_bb_ref().to_string()
// }

// pub fn BasicBlock::dump(self: BasicBlock) -> Unit {
//   self.as_bb_ref().dump()
// }

// pub impl Show for BasicBlock with output(self: BasicBlock, logger: &Logger) -> Unit {
//   logger.log(self.to_string())
// }
