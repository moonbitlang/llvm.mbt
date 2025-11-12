// ==================================================
// BasicBlock
// ==================================================

///|
pub struct BasicBlock(@unsafe.LLVMBasicBlockRef)

///|
pub impl Value for BasicBlock with getValueRef(self) -> ValueRef {
  @unsafe.llvm_basic_block_as_value(self.0)
}

///|
pub impl Value for BasicBlock with asValueEnum(self) -> ValueEnum {
  BasicBlock(self)
}

///|
/// Get the Function that this BasicBlock belongs to.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
///
/// let void_ty = ctx.getVoidTy()
/// let fty = ctx.getFunctionType(void_ty, [])
///
/// let fval = mod.addFunction(fty, "foo")
///
/// let bb = fval.addBasicBlock(name="entry")
///
/// let parent = bb.getParent().unwrap()
///
/// assert_eq(parent.getName(), "foo")
/// ```
pub fn BasicBlock::getParent(self : Self) -> Function? {
  let valueref = @unsafe.llvm_get_basic_block_parent(self.0)
  unless(@unsafe.llvm_value_ref_is_null(valueref), () => Function(valueref))
}

///|
/// Get the previous BasicBlock in the Function.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
///
/// let void_ty = ctx.getVoidTy()
/// let fty = ctx.getFunctionType(void_ty, [])
///
/// let fval = mod.addFunction(fty, "foo")
///
/// let _ = fval.addBasicBlock(name="entry")
/// let block1 = fval.addBasicBlock(name="block1")
///
/// let prev_block = block1.getPreviousBasicBlock().unwrap()
///
/// assert_eq(prev_block.getName(), "entry")
/// ```
pub fn BasicBlock::getPreviousBasicBlock(self : Self) -> BasicBlock? {
  let valueref = @unsafe.llvm_get_previous_basic_block(self.0)
  unless(@unsafe.llvm_bb_is_null(valueref), () => BasicBlock(valueref))
}

///|
/// Get the next BasicBlock in the Function.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
///
/// let void_ty = ctx.getVoidTy()
/// let fty = ctx.getFunctionType(void_ty, [])
///
/// let fval = mod.addFunction(fty, "foo")
///
/// let entry = fval.addBasicBlock(name="entry")
/// let _ = fval.addBasicBlock(name="block1")
///
/// let next_block = entry.getNextBasicBlock().unwrap()
///
/// assert_eq(next_block.getName(), "block1")
/// ```
pub fn BasicBlock::getNextBasicBlock(self : Self) -> BasicBlock? {
  let valueref = @unsafe.llvm_get_next_basic_block(self.0)
  unless(@unsafe.llvm_bb_is_null(valueref), () => BasicBlock(valueref))
}

///|
pub suberror BasicBlockHasNoParentError String derive(Show)

// REVIEW: Should we check basic block must have parent?

///|
/// Move the BasicBlock before another BasicBlock.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
/// let fval = mod.addFunction(fty, "move_bb_demo")
///
/// let const_42 = ctx.getConstInt32(42)
/// let const_33 = ctx.getConstInt32(33)
///
/// let arg0 = fval.getArg(0).unwrap()
/// let arg1 = fval.getArg(1).unwrap()
///
/// let entry = fval.addBasicBlock(name="entry")
/// let bb1 = fval.addBasicBlock(name="bb1")
/// let bb2 = fval.addBasicBlock(name="bb2")
/// builder.setInsertPoint(entry)
///
/// let cond = builder.createICmp(SGT, arg0, arg1)
/// let _ = builder.createCondBr(cond, bb1, bb2)
///
/// builder.setInsertPoint(bb1)
/// let _ = builder.createRet(const_42)
///
/// builder.setInsertPoint(bb2)
/// let _ = builder.createRet(const_33)
///
/// let expect =
///   #|define i32 @move_bb_demo(i32 %0, i32 %1) {
///   #|entry:
///   #|  %2 = icmp sgt i32 %0, %1
///   #|  br i1 %2, label %bb1, label %bb2
///   #|
///   #|bb1:                                              ; preds = %entry
///   #|  ret i32 42
///   #|
///   #|bb2:                                              ; preds = %entry
///   #|  ret i32 33
///   #|}
///   #|
///
/// inspect(fval, content=expect)
///
/// bb2.moveBefore(bb1)
///
/// let expect_after_move =
///   #|define i32 @move_bb_demo(i32 %0, i32 %1) {
///   #|entry:
///   #|  %2 = icmp sgt i32 %0, %1
///   #|  br i1 %2, label %bb1, label %bb2
///   #|
///   #|bb2:                                              ; preds = %entry
///   #|  ret i32 33
///   #|
///   #|bb1:                                              ; preds = %entry
///   #|  ret i32 42
///   #|}
///   #|
///
/// inspect(fval, content=expect_after_move)
/// ```
pub fn BasicBlock::moveBefore(self : Self, other : BasicBlock) -> Unit raise {
  guard self.getParent() is Some(_) && other.getParent() is Some(_) else {
    raise BasicBlockHasNoParentError(
      "Misuse BasicBlock::moveBefore, two Basic Blocks must have a parent Function",
    )
  }
  @unsafe.llvm_move_basic_block_before(self.0, other.0)
}

///|
/// Move the BasicBlock after another BasicBlock.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
/// let fval = mod.addFunction(fty, "move_bb_demo")
///
/// let const_42 = ctx.getConstInt32(42)
/// let const_33 = ctx.getConstInt32(33)
///
/// let arg0 = fval.getArg(0).unwrap()
/// let arg1 = fval.getArg(1).unwrap()
///
/// let entry = fval.addBasicBlock(name="entry")
/// let bb1 = fval.addBasicBlock(name="bb1")
/// let bb2 = fval.addBasicBlock(name="bb2")
/// builder.setInsertPoint(entry)
///
/// let cond = builder.createICmp(SGT, arg0, arg1)
/// let _ = builder.createCondBr(cond, bb1, bb2)
///
/// builder.setInsertPoint(bb1)
/// let _ = builder.createRet(const_42)
///
/// builder.setInsertPoint(bb2)
/// let _ = builder.createRet(const_33)
///
/// let expect =
///   #|define i32 @move_bb_demo(i32 %0, i32 %1) {
///   #|entry:
///   #|  %2 = icmp sgt i32 %0, %1
///   #|  br i1 %2, label %bb1, label %bb2
///   #|
///   #|bb1:                                              ; preds = %entry
///   #|  ret i32 42
///   #|
///   #|bb2:                                              ; preds = %entry
///   #|  ret i32 33
///   #|}
///   #|
///
/// inspect(fval, content=expect)
///
/// bb1.moveAfter(bb2)
///
/// let expect_after_move =
///   #|define i32 @move_bb_demo(i32 %0, i32 %1) {
///   #|entry:
///   #|  %2 = icmp sgt i32 %0, %1
///   #|  br i1 %2, label %bb1, label %bb2
///   #|
///   #|bb2:                                              ; preds = %entry
///   #|  ret i32 33
///   #|
///   #|bb1:                                              ; preds = %entry
///   #|  ret i32 42
///   #|}
///   #|
///
/// inspect(fval, content=expect_after_move)
/// ```
pub fn BasicBlock::moveAfter(self : Self, other : BasicBlock) -> Unit raise {
  guard self.getParent() is Some(_) && other.getParent() is Some(_) else {
    raise BasicBlockHasNoParentError(
      "Misuse BasicBlock::moveAfter, two Basic Blocks must have a parent Function",
    )
  }
  @unsafe.llvm_move_basic_block_after(self.0, other.0)
}

///|
/// Get the first Instruction in this BasicBlock.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "add_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let add = builder.createAdd(arg1, arg2, name="sum")
/// let _ = builder.createRet(add)
///
/// let first_inst = bb.getFirstInst().unwrap()
/// inspect(first_inst, content="  %sum = add i32 %0, %1")
/// ```
pub fn BasicBlock::getFirstInst(self : Self) -> &Instruction? {
  let valueref = @unsafe.llvm_get_first_instruction(self.0)
  unless(@unsafe.llvm_value_ref_is_null(valueref), () => initInstruction(
    valueref,
  ))
}

///|
/// Get the last Instruction in this BasicBlock.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "add_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let add = builder.createAdd(arg1, arg2, name="sum")
/// let _ = builder.createRet(add)
///
/// let last_inst = bb.getLastInst().unwrap()
/// inspect(last_inst, content="  ret i32 %sum")
/// ```
pub fn BasicBlock::getLastInst(self : Self) -> &Instruction? {
  let valueref = @unsafe.llvm_get_last_instruction(self.0)
  unless(@unsafe.llvm_value_ref_is_null(valueref), () => initInstruction(
    valueref,
  ))
}

///|
/// Get the terminator Instruction of this BasicBlock.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "add_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let add = builder.createAdd(arg1, arg2, name="sum")
/// let _ = builder.createRet(add)
///
/// let last_inst = bb.getTerminator().unwrap()
/// inspect(last_inst, content="  ret i32 %sum")
/// ```
pub fn BasicBlock::getTerminator(self : Self) -> &Instruction? {
  let valueref = @unsafe.llvm_get_basic_block_terminator(self.0)
  unless(@unsafe.llvm_value_ref_is_null(valueref), () => initInstruction(
    valueref,
  ))
}

///|
/// Remove this BasicBlock from its parent Function.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let void_ty = ctx.getVoidTy()
/// let fty = ctx.getFunctionType(void_ty, [])
///
/// let fval = mod.addFunction(fty, "remove_bb_demo")
/// let entry = fval.addBasicBlock(name="entry")
/// let block1 = fval.addBasicBlock(name="block1")
///
/// builder.setInsertPoint(entry)
///
/// let _ = builder.createBr(block1)
/// builder.setInsertPoint(block1)
/// let _ = builder.createRetVoid()
///
/// let expect = 
///   #|define void @remove_bb_demo() {
///   #|entry:
///   #|  br label %block1
///   #|
///   #|block1:                                           ; preds = %entry
///   #|  ret void
///   #|}
///   #|
///
/// inspect(fval, content=expect)
///
/// block1.removeFromParent()
///
/// let expect_after_remove =
///   #|define void @remove_bb_demo() {
///   #|entry:
///   #|  br label %block1
///   #|}
///   #|
///
/// inspect(fval, content=expect_after_remove)
/// ```
pub fn BasicBlock::removeFromParent(self : Self) -> Unit raise {
  guard self.getParent() is Some(_) else {
    raise BasicBlockHasNoParentError(
      "Misuse BasicBlock::removeFromParent, Basic Block must have a parent Function",
    )
  }
  @unsafe.llvm_remove_basic_block_from_parent(self.0)
}

///|
/// Erase this BasicBlock from its parent Function.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let void_ty = ctx.getVoidTy()
/// let fty = ctx.getFunctionType(void_ty, [])
///
/// let fval = mod.addFunction(fty, "remove_bb_demo")
/// let entry = fval.addBasicBlock(name="entry")
/// let block1 = fval.addBasicBlock(name="block1")
///
/// builder.setInsertPoint(entry)
///
/// let br_inst = builder.createBr(block1)
/// builder.setInsertPoint(block1)
/// let _ = builder.createRetVoid()
///
/// let expect = 
///   #|define void @remove_bb_demo() {
///   #|entry:
///   #|  br label %block1
///   #|
///   #|block1:                                           ; preds = %entry
///   #|  ret void
///   #|}
///   #|
///
/// inspect(fval, content=expect)
///
/// builder.setInsertPoint(br_inst)
/// let _ = builder.createRetVoid() // create a new instruction to replace the terminator
///
/// block1.eraseFromParent()
/// br_inst.eraseFromParent()  // must also erase this instruction
///
/// let expect_after_remove =
///   #|define void @remove_bb_demo() {
///   #|entry:
///   #|  ret void
///   #|}
///   #|
///
/// inspect(fval, content=expect_after_remove)
/// ```
pub fn BasicBlock::eraseFromParent(self : Self) -> Unit raise {
  guard self.getParent() is Some(_) else {
    raise BasicBlockHasNoParentError(
      "Misuse BasicBlock::eraseFromParent, Basic Block must have a parent Function",
    )
  }
  @unsafe.llvm_delete_basic_block(self.0)
}

///|
pub fn BasicBlock::getContext(self : Self) -> Context {
  Context(
    @unsafe.llvm_get_type_context(
      @unsafe.llvm_type_of(@unsafe.llvm_basic_block_as_value(self.0)),
    ),
  )
}

///|
/// Get the name of this BasicBlock.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
///
/// let void_ty = ctx.getVoidTy()
/// let fty = ctx.getFunctionType(void_ty, [])
///
/// let fval = mod.addFunction(fty, "foo")
///
/// let entry = fval.addBasicBlock(name="entry")
///
/// assert_eq(entry.getName(), "entry")
/// ```
pub fn BasicBlock::getName(self : Self) -> String {
  @unsafe.llvm_get_basic_block_name(self.0)
}

///|
/// Set the name of this BasicBlock.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
///
/// let void_ty = ctx.getVoidTy()
/// let fty = ctx.getFunctionType(void_ty, [])
///
/// let fval = mod.addFunction(fty, "foo")
///
/// let entry = fval.addBasicBlock(name="entry")
/// assert_eq(entry.getName(), "entry")
///
/// entry.setName("new_entry")
/// assert_eq(entry.getName(), "new_entry")
/// ```
pub fn BasicBlock::setName(self : Self, name : String) -> Unit {
  @unsafe.llvm_set_value_name(
    @unsafe.llvm_basic_block_as_value(self.0),
    name,
  )
}

//pub fn BasicBlock::getFirstUser(self: Self) -> &User? {
//  let useref = @unsafe.llvm_get_first_use(@unsafe.llvm_basic_block_as_value(self.0))
//  unless(
//    @unsafe.llvm_value_ref_is_null(useref),
//    () => initUser(useref)
//  )
//}

//pub fn BasicBlock::getAddress(self: Self) -> &Value {
//
//}

///|
pub impl Show for BasicBlock with output(self, logger) {
  let s = @unsafe.llvm_print_value_to_string(
    @unsafe.llvm_basic_block_as_value(self.0),
  )
  logger.write_string(s)
}
