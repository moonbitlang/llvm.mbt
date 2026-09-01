// ==================================================
// BasicBlock
// ==================================================

///|
/// Module-anchored LLVM basic block.
///
/// A block may be attached to a function or temporarily detached. Its
/// instructions and CFG edges remain native LLVM objects whose validity is not
/// fully tracked by the safe type system.
///
/// **Lifecycle:** The wrapper retains its module. `eraseFromParent` destroys the
/// native block and invalidates this wrapper plus aliases to its instructions.
pub struct BasicBlock {
  priv block_ref : @raw.LLVMBasicBlockRef
  priv owner_module : Module
}

///|
fn BasicBlock::from_raw(
  block_ref : @raw.LLVMBasicBlockRef,
  owner_module : Module,
) -> BasicBlock {
  BasicBlock::{ block_ref, owner_module, }
}

///|
fn BasicBlock::get_raw_ref(self : BasicBlock) -> @raw.LLVMBasicBlockRef {
  self.block_ref
}

///|
fn BasicBlock::get_module(self : BasicBlock) -> Module {
  self.owner_module
}

///|
/// Exposes the block as a borrowed LLVM value handle.
fn BasicBlock::get_raw_value_ref(self : BasicBlock) -> ValueRef {
  @raw.llvm_basic_block_as_value(self.get_raw_ref())
}

///|
/// Classifies this wrapper as `ValueEnum::BasicBlock`.
pub impl Value for BasicBlock with fn asValueEnum(self) -> ValueEnum {
  BasicBlock(self)
}

///|
/// Returns the function currently containing this block.
///
/// **Returns:** `None` when the block has been detached.
///
/// **Lifecycle:** A returned function retains the same module.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///
///   let void_ty = ctx.getVoidTy()
///   let fty = ctx.getFunctionType(void_ty, [])
///
///   let fval = mod.addFunction(fty, "foo")
///
///   let bb = fval.addBasicBlock(name="entry")
///
///   let parent = bb.getParent().unwrap()
///
///   assert_eq(parent.getName(), Some("foo"))
/// }
/// ```
pub fn BasicBlock::getParent(self : Self) -> Function? {
  let valueref = @raw.llvm_get_basic_block_parent(self.get_raw_ref())
  unless(@raw.llvm_value_ref_is_null(valueref), () => {
    Function::from_raw(valueref, self.get_module())
  })
}

///|
/// Returns the previous block in the parent function's current order.
///
/// **Returns:** `None` for the first block or a detached block.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///
///   let void_ty = ctx.getVoidTy()
///   let fty = ctx.getFunctionType(void_ty, [])
///
///   let fval = mod.addFunction(fty, "foo")
///
///   let _ = fval.addBasicBlock(name="entry")
///   let block1 = fval.addBasicBlock(name="block1")
///
///   let prev_block = block1.getPreviousBasicBlock().unwrap()
///
///   assert_eq(prev_block.getName(), Some("entry"))
/// }
/// ```
pub fn BasicBlock::getPreviousBasicBlock(self : Self) -> BasicBlock? {
  let valueref = @raw.llvm_get_previous_basic_block(self.get_raw_ref())
  unless(@raw.llvm_bb_is_null(valueref), () => {
    BasicBlock::from_raw(valueref, self.get_module())
  })
}

///|
/// Returns the next block in the parent function's current order.
///
/// **Returns:** `None` for the last block or a detached block.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///
///   let void_ty = ctx.getVoidTy()
///   let fty = ctx.getFunctionType(void_ty, [])
///
///   let fval = mod.addFunction(fty, "foo")
///
///   let entry = fval.addBasicBlock(name="entry")
///   let _ = fval.addBasicBlock(name="block1")
///
///   let next_block = entry.getNextBasicBlock().unwrap()
///
///   assert_eq(next_block.getName(), Some("block1"))
/// }
/// ```
pub fn BasicBlock::getNextBasicBlock(self : Self) -> BasicBlock? {
  let valueref = @raw.llvm_get_next_basic_block(self.get_raw_ref())
  unless(@raw.llvm_bb_is_null(valueref), () => {
    BasicBlock::from_raw(valueref, self.get_module())
  })
}

///|
/// Error raised when a block operation requires an attached parent function.
pub suberror BasicBlockHasNoParentError {
  /// Contains a diagnostic naming the invalid block operation.
  BasicBlockHasNoParentError(String)
}

// REVIEW: Should we check basic block must have parent?

///|
/// Moves this block immediately before `other`.
///
/// **Preconditions:** Both blocks must be attached and must belong to compatible
/// functions/modules. Only attachment is checked by the safe layer.
///
/// **Errors:** Raises `BasicBlockHasNoParentError` if either block is detached.
///
/// **Side Effects:** Reorders the block list. Existing branch targets are not
/// rewritten; block layout and fall-through-sensitive code generation may
/// change.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///   let builder = ctx.createBuilder()
///
///   let i32_ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///   let fval = mod.addFunction(fty, "move_bb_demo")
///
///   let const_42 = ctx.getConstInt32(42)
///   let const_33 = ctx.getConstInt32(33)
///
///   let arg0 = fval.getArg(0).unwrap()
///   let arg1 = fval.getArg(1).unwrap()
///
///   let entry = fval.addBasicBlock(name="entry")
///   let bb1 = fval.addBasicBlock(name="bb1")
///   let bb2 = fval.addBasicBlock(name="bb2")
///   builder.setInsertPoint(entry)
///
///   let cond = builder.createICmp(SGT, arg0, arg1)
///   let _ = builder.createCondBr(cond, bb1, bb2)
///
///   builder.setInsertPoint(bb1)
///   let _ = builder.createRet(const_42)
///
///   builder.setInsertPoint(bb2)
///   let _ = builder.createRet(const_33)
///
///   let expect =
///     #|define i32 @move_bb_demo(i32 %0, i32 %1) {
///     #|entry:
///     #|  %2 = icmp sgt i32 %0, %1
///     #|  br i1 %2, label %bb1, label %bb2
///     #|
///     #|bb1:                                              ; preds = %entry
///     #|  ret i32 42
///     #|
///     #|bb2:                                              ; preds = %entry
///     #|  ret i32 33
///     #|}
///     #|
///
///   inspect(fval, content=expect)
///
///   bb2.moveBefore(bb1)
///
///   let expect_after_move =
///     #|define i32 @move_bb_demo(i32 %0, i32 %1) {
///     #|entry:
///     #|  %2 = icmp sgt i32 %0, %1
///     #|  br i1 %2, label %bb1, label %bb2
///     #|
///     #|bb2:                                              ; preds = %entry
///     #|  ret i32 33
///     #|
///     #|bb1:                                              ; preds = %entry
///     #|  ret i32 42
///     #|}
///     #|
///
///   inspect(fval, content=expect_after_move)
/// }
/// ```
pub fn BasicBlock::moveBefore(self : Self, other : BasicBlock) -> Unit raise {
  guard self.getParent() is Some(_) && other.getParent() is Some(_) else {
    raise BasicBlockHasNoParentError(
      "Misuse BasicBlock::moveBefore, two Basic Blocks must have a parent Function",
    )
  }
  @raw.llvm_move_basic_block_before(self.get_raw_ref(), other.get_raw_ref())
}

///|
/// Moves this block immediately after `other`.
///
/// **Preconditions:** Both blocks must be attached and must belong to compatible
/// functions/modules. Only attachment is checked by the safe layer.
///
/// **Errors:** Raises `BasicBlockHasNoParentError` if either block is detached.
///
/// **Side Effects:** Reorders the block list without rewriting CFG edges.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///   let builder = ctx.createBuilder()
///
///   let i32_ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///   let fval = mod.addFunction(fty, "move_bb_demo")
///
///   let const_42 = ctx.getConstInt32(42)
///   let const_33 = ctx.getConstInt32(33)
///
///   let arg0 = fval.getArg(0).unwrap()
///   let arg1 = fval.getArg(1).unwrap()
///
///   let entry = fval.addBasicBlock(name="entry")
///   let bb1 = fval.addBasicBlock(name="bb1")
///   let bb2 = fval.addBasicBlock(name="bb2")
///   builder.setInsertPoint(entry)
///
///   let cond = builder.createICmp(SGT, arg0, arg1)
///   let _ = builder.createCondBr(cond, bb1, bb2)
///
///   builder.setInsertPoint(bb1)
///   let _ = builder.createRet(const_42)
///
///   builder.setInsertPoint(bb2)
///   let _ = builder.createRet(const_33)
///
///   let expect =
///     #|define i32 @move_bb_demo(i32 %0, i32 %1) {
///     #|entry:
///     #|  %2 = icmp sgt i32 %0, %1
///     #|  br i1 %2, label %bb1, label %bb2
///     #|
///     #|bb1:                                              ; preds = %entry
///     #|  ret i32 42
///     #|
///     #|bb2:                                              ; preds = %entry
///     #|  ret i32 33
///     #|}
///     #|
///
///   inspect(fval, content=expect)
///
///   bb1.moveAfter(bb2)
///
///   let expect_after_move =
///     #|define i32 @move_bb_demo(i32 %0, i32 %1) {
///     #|entry:
///     #|  %2 = icmp sgt i32 %0, %1
///     #|  br i1 %2, label %bb1, label %bb2
///     #|
///     #|bb2:                                              ; preds = %entry
///     #|  ret i32 33
///     #|
///     #|bb1:                                              ; preds = %entry
///     #|  ret i32 42
///     #|}
///     #|
///
///   inspect(fval, content=expect_after_move)
/// }
/// ```
pub fn BasicBlock::moveAfter(self : Self, other : BasicBlock) -> Unit raise {
  guard self.getParent() is Some(_) && other.getParent() is Some(_) else {
    raise BasicBlockHasNoParentError(
      "Misuse BasicBlock::moveAfter, two Basic Blocks must have a parent Function",
    )
  }
  @raw.llvm_move_basic_block_after(self.get_raw_ref(), other.get_raw_ref())
}

///|
/// Returns the first instruction, or `None` when the block is empty.
///
/// **Lifecycle:** The returned instruction retains the block's module but may be
/// invalidated by instruction or block erasure.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///   let builder = ctx.createBuilder()
///
///   let i32_ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
///   let fval = mod.addFunction(fty, "add_demo")
///   let bb = fval.addBasicBlock(name="entry")
///   let arg1 = fval.getArg(0).unwrap()
///   let arg2 = fval.getArg(1).unwrap()
///
///   builder.setInsertPoint(bb)
///   let add = builder.createAdd(arg1, arg2, name="sum")
///   let _ = builder.createRet(add)
///
///   let first_inst = bb.getFirstInst().unwrap()
///   inspect(first_inst, content="  %sum = add i32 %0, %1")
/// }
/// ```
pub fn BasicBlock::getFirstInst(self : Self) -> &Instruction? {
  let valueref = @raw.llvm_get_first_instruction(self.get_raw_ref())
  unless(@raw.llvm_value_ref_is_null(valueref), () => {
    initInstruction(valueref, self.get_module())
  })
}

///|
/// Returns the last instruction, or `None` when the block is empty.
///
/// **Lifecycle:** The returned instruction retains the block's module but may be
/// invalidated by instruction or block erasure.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///   let builder = ctx.createBuilder()
///
///   let i32_ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
///   let fval = mod.addFunction(fty, "add_demo")
///   let bb = fval.addBasicBlock(name="entry")
///   let arg1 = fval.getArg(0).unwrap()
///   let arg2 = fval.getArg(1).unwrap()
///
///   builder.setInsertPoint(bb)
///   let add = builder.createAdd(arg1, arg2, name="sum")
///   let _ = builder.createRet(add)
///
///   let last_inst = bb.getLastInst().unwrap()
///   inspect(last_inst, content="  ret i32 %sum")
/// }
/// ```
pub fn BasicBlock::getLastInst(self : Self) -> &Instruction? {
  let valueref = @raw.llvm_get_last_instruction(self.get_raw_ref())
  unless(@raw.llvm_value_ref_is_null(valueref), () => {
    initInstruction(valueref, self.get_module())
  })
}

///|
/// Returns the block terminator, or `None` if the block is unterminated.
///
/// **Lifecycle:** The returned instruction retains the module but may be
/// invalidated by later IR mutation.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///   let builder = ctx.createBuilder()
///
///   let i32_ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
///   let fval = mod.addFunction(fty, "add_demo")
///   let bb = fval.addBasicBlock(name="entry")
///   let arg1 = fval.getArg(0).unwrap()
///   let arg2 = fval.getArg(1).unwrap()
///
///   builder.setInsertPoint(bb)
///   let add = builder.createAdd(arg1, arg2, name="sum")
///   let _ = builder.createRet(add)
///
///   let last_inst = bb.getTerminator().unwrap()
///   inspect(last_inst, content="  ret i32 %sum")
/// }
/// ```
pub fn BasicBlock::getTerminator(self : Self) -> &Instruction? {
  let valueref = @raw.llvm_get_basic_block_terminator(self.get_raw_ref())
  unless(@raw.llvm_value_ref_is_null(valueref), () => {
    initInstruction(valueref, self.get_module())
  })
}

///|
/// Detaches this block from its parent function without destroying it.
///
/// **Errors:** Raises `BasicBlockHasNoParentError` when already detached.
///
/// **Side Effects:** Removes the block from the function's block list. Existing
/// branches to it are not repaired, so the surrounding module may become
/// invalid until the caller updates the CFG.
///
/// **Lifecycle:** This block and its instructions still exist, but the safe
/// layer offers no ownership state that prevents invalid detached-block usage.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///   let builder = ctx.createBuilder()
///
///   let void_ty = ctx.getVoidTy()
///   let fty = ctx.getFunctionType(void_ty, [])
///
///   let fval = mod.addFunction(fty, "remove_bb_demo")
///   let entry = fval.addBasicBlock(name="entry")
///   let block1 = fval.addBasicBlock(name="block1")
///
///   builder.setInsertPoint(entry)
///
///   let _ = builder.createBr(block1)
///   builder.setInsertPoint(block1)
///   let _ = builder.createRetVoid()
///
///   let expect =
///     #|define void @remove_bb_demo() {
///     #|entry:
///     #|  br label %block1
///     #|
///     #|block1:                                           ; preds = %entry
///     #|  ret void
///     #|}
///     #|
///
///   inspect(fval, content=expect)
///
///   block1.removeFromParent()
///
///   let expect_after_remove =
///     #|define void @remove_bb_demo() {
///     #|entry:
///     #|  br label %block1
///     #|}
///     #|
///
///   inspect(fval, content=expect_after_remove)
/// }
/// ```
pub fn BasicBlock::removeFromParent(self : Self) -> Unit raise {
  guard self.getParent() is Some(_) else {
    raise BasicBlockHasNoParentError(
      "Misuse BasicBlock::removeFromParent, Basic Block must have a parent Function",
    )
  }
  @raw.llvm_remove_basic_block_from_parent(self.get_raw_ref())
}

///|
/// Removes and destroys this block and its contained instructions.
///
/// **Errors:** Raises `BasicBlockHasNoParentError` when already detached.
///
/// **Side Effects:** Mutates the function and destroys the native block. CFG
/// users are not automatically repaired and must be removed or redirected.
///
/// **Lifecycle:** This wrapper, all aliases to the block, and wrappers for its
/// instructions become dangling immediately. They must not be used again; the
/// type system cannot currently enforce this Q-09 restriction.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///   let builder = ctx.createBuilder()
///
///   let void_ty = ctx.getVoidTy()
///   let fty = ctx.getFunctionType(void_ty, [])
///
///   let fval = mod.addFunction(fty, "remove_bb_demo")
///   let entry = fval.addBasicBlock(name="entry")
///   let block1 = fval.addBasicBlock(name="block1")
///
///   builder.setInsertPoint(entry)
///
///   let br_inst = builder.createBr(block1)
///   builder.setInsertPoint(block1)
///   let _ = builder.createRetVoid()
///
///   let expect =
///     #|define void @remove_bb_demo() {
///     #|entry:
///     #|  br label %block1
///     #|
///     #|block1:                                           ; preds = %entry
///     #|  ret void
///     #|}
///     #|
///
///   inspect(fval, content=expect)
///
///   builder.setInsertPoint(br_inst)
///   let _ = builder.createRetVoid() // create a new instruction to replace the terminator
///
///   block1.eraseFromParent()
///   br_inst.eraseFromParent() // must also erase this instruction
///
///   let expect_after_remove =
///     #|define void @remove_bb_demo() {
///     #|entry:
///     #|  ret void
///     #|}
///     #|
///
///   inspect(fval, content=expect_after_remove)
/// }
/// ```
pub fn BasicBlock::eraseFromParent(self : Self) -> Unit raise {
  guard self.getParent() is Some(_) else {
    raise BasicBlockHasNoParentError(
      "Misuse BasicBlock::eraseFromParent, Basic Block must have a parent Function",
    )
  }
  @raw.llvm_delete_basic_block(self.get_raw_ref())
}

///|
/// Returns the context retained by the block's owning module.
pub fn BasicBlock::getContext(self : Self) -> Context {
  self.get_module().getContext()
}

///|
/// Returns the optional block name.
///
/// **Errors:** Raises `StringError::MalformedUtf8` if LLVM returns invalid
/// UTF-8.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///
///   let void_ty = ctx.getVoidTy()
///   let fty = ctx.getFunctionType(void_ty, [])
///
///   let fval = mod.addFunction(fty, "foo")
///
///   let entry = fval.addBasicBlock(name="entry")
///
///   assert_eq(entry.getName(), Some("entry"))
/// }
/// ```
pub fn BasicBlock::getName(self : Self) -> String? raise StringError {
  self.getValueName()
}

///|
/// Sets the block name.
///
/// **Errors:** Raises `StringError::ContainsNul` for an embedded NUL byte.
///
/// **Side Effects:** Changes the label printed in LLVM IR.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///
///   let void_ty = ctx.getVoidTy()
///   let fty = ctx.getFunctionType(void_ty, [])
///
///   let fval = mod.addFunction(fty, "foo")
///
///   let entry = fval.addBasicBlock(name="entry")
///   assert_eq(entry.getName(), Some("entry"))
///
///   entry.setName("new_entry")
///   assert_eq(entry.getName(), Some("new_entry"))
/// }
/// ```
pub fn BasicBlock::setName(
  self : Self,
  name : String,
) -> Unit raise StringError {
  self.setValueName(name)
}

//pub fn BasicBlock::getFirstUser(self: Self) -> &User? {
//  let useref = @raw.llvm_get_first_use(@raw.llvm_basic_block_as_value(self.0))
//  unless(
//    @raw.llvm_value_ref_is_null(useref),
//    () => initUser(useref)
//  )
//}

//pub fn BasicBlock::getAddress(self: Self) -> &Value {
//
//}

///|
/// Writes this block as LLVM textual IR.
pub impl Show for BasicBlock with fn output(self, logger) {
  let s = @raw.llvm_print_value_to_string(
    @raw.llvm_basic_block_as_value(self.get_raw_ref()),
  ) catch {
    error => "<LLVM basic block text unavailable: \{error}>"
  }
  logger.write_string(s)
}
