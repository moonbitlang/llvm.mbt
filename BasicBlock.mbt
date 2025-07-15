// ==================================================
// BasicBlock
// ==================================================

///|
pub type BasicBlock @unsafe.LLVMBasicBlockRef

///|
pub impl Value for BasicBlock with getValueRef(self) -> ValueRef {
  @unsafe.llvm_basic_block_as_value(self.inner())
}

///|
pub impl Value for BasicBlock with asValueEnum(self) -> ValueEnum {
  BasicBlock(self)
}

///|
pub fn BasicBlock::getParent(self : Self) -> Function? {
  let valueref = @unsafe.llvm_get_basic_block_parent(self.inner())
  unless(@unsafe.llvm_value_ref_is_null(valueref), () => Function(valueref))
}

///|
pub fn BasicBlock::getPreviousBasicBlock(self : Self) -> BasicBlock? {
  let valueref = @unsafe.llvm_get_previous_basic_block(self.inner())
  unless(@unsafe.llvm_bb_is_null(valueref), () => BasicBlock(valueref))
}

///|
pub fn BasicBlock::getNextBasicBlock(self : Self) -> BasicBlock? {
  let valueref = @unsafe.llvm_get_next_basic_block(self.inner())
  unless(@unsafe.llvm_bb_is_null(valueref), () => BasicBlock(valueref))
}

///|
pub suberror BasicBlockHasNoParentError String derive(Show)

// REVIEW: Shoule we check basic block must have parent?

///|
pub fn BasicBlock::moveBefore(self : Self, other : BasicBlock) -> Unit raise {
  guard self.getParent() is Some(_) && other.getParent() is Some(_) else {
    raise BasicBlockHasNoParentError(
      "Misuse BasicBlock::moveBefore, two Basic Blocks must have a parent Function",
    )
  }
  @unsafe.llvm_move_basic_block_before(self.inner(), other.inner())
}

///|
pub fn BasicBlock::moveAfter(self : Self, other : BasicBlock) -> Unit raise {
  guard self.getParent() is Some(_) && other.getParent() is Some(_) else {
    raise BasicBlockHasNoParentError(
      "Misuse BasicBlock::moveAfter, two Basic Blocks must have a parent Function",
    )
  }
  @unsafe.llvm_move_basic_block_after(self.inner(), other.inner())
}

//pub fn BasicBlock::getFirstInst(self: Self) -> &Instruction? {
//  let valueref = @unsafe.llvm_get_first_instruction(self.inner())
//  unless(
//    @unsafe.llvm_value_ref_is_null(valueref),
//    () => initInstruction(valueref)
//  )
//}
//
//pub fn BasicBlock::getLastInst(self: Self) -> &Instruction? {
//  let valueref = @unsafe.llvm_get_last_instruction(self.inner())
//  unless(
//    @unsafe.llvm_value_ref_is_null(valueref),
//    () => initInstruction(valueref)
//  )
//}
//
//pub fn BasicBlock::getInstWithName(self: Self, name: String) -> &Instruction? {
//  let inst = self.get_first_instruction()
//  match inst {
//    Some(inst) => inst.get_instruction_with_name(name)
//    None => None
//  }
//}
//
//pub fn BasicBlock::getTerminator(self: Self) -> &Instruction? {
//  let valueref = @unsafe.llvm_get_terminator(self.inner())
//  unless(
//    @unsafe.llvm_value_ref_is_null(valueref),
//    () => initInstruction(valueref)
//  )
//}

///|
pub fn BasicBlock::removeFromParent(self : Self) -> Unit raise {
  guard self.getParent() is Some(_) else {
    raise BasicBlockHasNoParentError(
      "Misuse BasicBlock::removeFromParent, Basic Block must have a parent Function",
    )
  }
  @unsafe.llvm_remove_basic_block_from_parent(self.inner())
}

///|
pub fn BasicBlock::getContext(self : Self) -> Context {
  Context(
    @unsafe.llvm_get_type_context(
      @unsafe.llvm_type_of(@unsafe.llvm_basic_block_as_value(self.inner())),
    ),
  )
}

///|
pub fn BasicBlock::getName(self : Self) -> String {
  @unsafe.llvm_get_basic_block_name(self.inner())
}

///|
pub fn BasicBlock::setName(self : Self, name : String) -> Unit {
  @unsafe.llvm_set_value_name(
    @unsafe.llvm_basic_block_as_value(self.inner()),
    name,
  )
}

//pub fn BasicBlock::getFirstUser(self: Self) -> &User? {
//  let useref = @unsafe.llvm_get_first_use(@unsafe.llvm_basic_block_as_value(self.inner()))
//  unless(
//    @unsafe.llvm_value_ref_is_null(useref),
//    () => initUser(useref)
//  )
//}

//pub fn BaiscBlock::getAddress(self: Self) -> &Value {
//
//}

///|
pub impl Show for BasicBlock with output(self, logger) {
  let s = @unsafe.llvm_print_value_to_string(
    @unsafe.llvm_basic_block_as_value(self.inner()),
  )
  logger.write_string(s)
}
