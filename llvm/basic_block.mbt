///| A `BasicBlock` is a container of instructions.
///
/// `BasicBlock`s are values because they can be referenced by instructions (ie branching and switches).
///
/// A well formed `BasicBlock` is a list of non terminating instructions followed by a single terminating
/// instruction. `BasicBlock`s are allowed to be malformed prior to running validation because it may be useful
/// when constructing or modifying a program.
pub struct BasicBlock {
  bb_ref : @unsafe.LLVMBasicBlockRef
}

///| Return `@unsafe.LLVMBasicBlockRef` of this `BasicBlock` wrapped.
pub fn BasicBlock::as_bb_ref(self : BasicBlock) -> @unsafe.LLVMBasicBlockRef {
  self.bb_ref
}

///|
pub fn BasicBlock::new(
  basic_block_ref : @unsafe.LLVMBasicBlockRef
) -> BasicBlock {
  guard basic_block_ref.is_not_null() else {
    println("basic block ref is null")
    panic()
  }
  BasicBlock::{ bb_ref: basic_block_ref }
}

///| Obtains the `FunctionValue` that this `BasicBlock` belongs to, if any.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let prog = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let function = prog.add_function("do_nothing", fn_type);
///
/// let basic_block = context.append_basic_block(function, "entry");
///
/// assert_eq(basic_block.get_parent().unwrap(), function);
///
/// basic_block.remove_from_function();
///
/// assert_true(basic_block.get_parent() is None);
/// ```
pub fn BasicBlock::get_parent(self : BasicBlock) -> FunctionValue? {
  FunctionValue::new(@unsafe.llvm_get_basic_block_parent(self.as_bb_ref()))
}

///| Gets the `BasicBlock` preceding the current one, in its own scope, if any.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let function1 = llvm_module.add_function("do_nothing", fn_type);
///
/// let basic_block1 = context.append_basic_block(function1, name="entry");
///
/// assert_true(basic_block1.get_previous_basic_block().is None);
///
/// let function2 = llvm_module.add_function("do_nothing", fn_type);
///
/// let basic_block2 = context.append_basic_block(function2, name="entry");
/// let basic_block3 = context.append_basic_block(function2, name="next");
///
/// assert_true(basic_block2.get_previous_basic_block() is None);
/// assert_true(basic_block3.get_previous_basic_block().unwrap() == basic_block2);
/// ```
pub fn BasicBlock::get_previous_basic_block(self : BasicBlock) -> BasicBlock? {
  let prev_bb_ref = @unsafe.llvm_get_previous_basic_block(self.as_bb_ref())
  @option.when(prev_bb_ref.is_not_null(), fn() { BasicBlock::new(prev_bb_ref) })
}

///| Gets the `BasicBlock` succeeding the current one, in its own scope, if any.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let function1 = llvm_module.add_function("do_nothing", fn_type);
///
/// let basic_block1 = context.append_basic_block(function1, name="entry");
///
/// assert_true(basic_block1.get_next_basic_block().is None);
///
/// let function2 = llvm_module.add_function("do_nothing", fn_type);
///
/// let basic_block2 = context.append_basic_block(function2, name="entry");
/// let basic_block3 = context.append_basic_block(function2, name="next");
///
/// assert_true(basic_block1.get_next_basic_block() is None);
/// assert_true(basic_block2.get_next_basic_block().unwrap() == basic_block3);
/// assert_true(basic_block3.get_next_basic_block() is None);
/// ```
pub fn BasicBlock::get_next_basic_block(self : BasicBlock) -> BasicBlock? {
  let next_bb_ref = @unsafe.llvm_get_next_basic_block(self.as_bb_ref())
  @option.when(next_bb_ref.is_not_null(), fn() {
    BasicBlock::new(@unsafe.llvm_get_next_basic_block(self.as_bb_ref()))
  })
}

///| Prepends one `BasicBlock` before another.
/// It returns `Err(())` when either `BasicBlock` has no parent, as @unsafe.LLVM assumes they both have parents.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let function = llvm_module.add_function("do_nothing", fn_type);
///
/// let basic_block1 = context.append_basic_block(function, name="entry");
/// let basic_block2 = context.append_basic_block(function, name="next");
///
/// basic_block2.move_before(basic_block1);
///
/// assert_true(basic_block1.get_next_basic_block() is None);
/// assert_true(basic_block2.get_next_basic_block().unwrap() == basic_block1);
/// ```
pub fn BasicBlock::move_before(
  self : BasicBlock,
  other : BasicBlock
) -> Unit raise MoonllvmError {
  guard self.get_parent() is Some(_) && other.get_parent() is Some(_) else {
    raise MoonllvmError::BasicBlockHasNoParent
  }
  @unsafe.llvm_move_basic_block_before(self.as_bb_ref(), other.as_bb_ref())
}

///| Appends one `BasicBlock` after another.
/// It returns `Err(())` when either `BasicBlock` has no parent, as @unsafe.LLVM assumes they both have parents.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let function = llvm_module.add_function("do_nothing", fn_type);
///
/// let basic_block1 = context.append_basic_block(function, name="entry");
/// let basic_block2 = context.append_basic_block(function, name="next");
///
/// basic_block1.move_after(basic_block2);
///
/// assert_true(basic_block1.get_next_basic_block().is None());
/// assert_eq(basic_block2.get_next_basic_block().unwrap(), basic_block1);
/// ```
pub fn BasicBlock::move_after(
  self : BasicBlock,
  other : BasicBlock
) -> Unit raise MoonllvmError {
  guard self.get_parent() is Some(_) && other.get_parent() is Some(_) else {
    raise MoonllvmError::BasicBlockHasNoParent
  }
  @unsafe.llvm_move_basic_block_after(self.as_bb_ref(), other.as_bb_ref())
}

///| Obtains the first `InstructionValue` in this `BasicBlock`, if any.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let function = llvm_module.add_function("do_nothing", fn_type);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// builder.position_at_end(basic_block);
/// builder.build_return(None);
///
/// let opcode = basic_block.get_first_instruction().unwrap().get_opcode();
/// assert_eq(opcode, InstructionOpcode::Return);
/// ```
pub fn BasicBlock::get_first_instruction(
  self : BasicBlock
) -> InstructionValue? {
  let inst = @unsafe.llvm_get_first_instruction(self.as_bb_ref())
  @option.when(inst.is_not_null(), fn() { InstructionValue::new(inst) })
}

///| Obtains the last `InstructionValue` in this `BasicBlock`, if any. A `BasicBlock` must have a last instruction to be valid.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let function = llvm_module.add_function("do_nothing", fn_type);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// builder.position_at_end(basic_block);
/// let _ = builder.build_return(None);
///
/// let opcode = basic_block.get_last_instruction().unwrap().get_opcode();
/// assert_eq(opcode, InstructionOpcode::Return);
/// ```
pub fn BasicBlock::get_last_instruction(self : BasicBlock) -> InstructionValue? {
  let inst = @unsafe.llvm_get_last_instruction(self.as_bb_ref())
  @option.when(inst.is_not_null(), fn() { InstructionValue::new(inst) })
}

///| Performs a linear lookup to obtain a instruction based on the name
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("ret");
/// let builder = context.create_builder();
///
/// let void_type = context.void_type();
/// let i32_type = context.i32_type();
/// let i32_ptr_type = i32_type.ptr_type(AddressSpace::default());
///
/// let fn_type = void_type.fn_type([i32_ptr_type]);
/// let fn_value = llvm_module.add_function("ret", fn_type);
/// let entry = context.append_basic_block(fn_value, "entry");
/// builder.position_at_end(entry);
///
/// let var = builder.build_alloca(i32_type, "some_number").unwrap();
/// builder.build_store(var, i32_type.const_int(1, false)).unwrap();
/// builder.build_return(None).unwrap();
///
/// let block = fn_value.get_first_basic_block().unwrap();
/// let some_number = block.get_instruction_with_name("some_number");
///
/// assert_true(some_number.is_some());
/// inspect(some_number.unwrap().get_name().unwrap(), content="some_number")
/// ```
pub fn BasicBlock::get_instruction_with_name(
  self : BasicBlock,
  name : String
) -> InstructionValue? {
  let inst = self.get_first_instruction()
  match inst {
    Some(inst) => inst.get_instruction_with_name(name)
    None => None
  }
}

///| Obtains the terminating `InstructionValue` in this `BasicBlock`, if any. A `BasicBlock` must have a terminating instruction to be valid.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let function = llvm_module.add_function("do_nothing", fn_type);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// builder.position_at_end(basic_block);
/// builder.build_return(None);
///
/// let opcode = basic_block.get_terminator().unwrap().get_opcode()
/// assert_eq(opcode, InstructionOpcode::Return);
/// ```
pub fn BasicBlock::get_terminator(self : BasicBlock) -> InstructionValue? {
  let inst = @unsafe.llvm_get_basic_block_terminator(self.as_bb_ref())
  @option.when(inst.is_not_null(), fn() { InstructionValue::new(inst) })
}

// pub fn BasicBlock::get_instructions(self) -> InstructionIter

///| Removes this `BasicBlock` from its parent `FunctionValue`.
/// It returns `Err(())` when it has no parent to remove from.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let function = llvm_module.add_function("do_nothing", fn_type);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// assert_eq(basic_block.get_parent().unwrap(), function);
///
/// basic_block.remove_from_function();
///
/// assert_true(basic_block.get_parent().is None);
/// ```
pub fn remove_from_function(self : BasicBlock) -> Unit raise MoonllvmError {
  guard self.get_parent() is Some(_) else {
    raise MoonllvmError::BasicBlockHasNoParent
  }
  @unsafe.llvm_remove_basic_block_from_parent(self.as_bb_ref())
}

///| Removes this `BasicBlock` completely from memory. This is unsafe because you could easily have other references to the same `BasicBlock`.
/// It returns `Err(())` when it has no parent to delete from, as @unsafe.LLVM assumes it has a parent.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let function = llvm_module.add_function("do_nothing", fn_type);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// basic_block.delete();
/// assert_true(function.get_basic_blocks().is_empty());
/// ```
pub fn BasicBlock::delete(self : BasicBlock) -> Unit raise MoonllvmError {
  guard self.get_parent() is Some(_) else {
    raise MoonllvmError::BasicBlockHasNoParent
  }
  @unsafe.llvm_delete_basic_block(self.as_bb_ref())
}

///| Obtains the `ContextRef` this `BasicBlock` belongs to.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let function = llvm_module.add_function("do_nothing", fn_type);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// assert_true(context == basic_block.get_context());
/// ```
pub fn BasicBlock::get_context(self : BasicBlock) -> Context {
  Context::new(
    @unsafe.llvm_get_type_context(
      @unsafe.llvm_type_of(self.as_bb_ref().as_value_ref()),
    ),
  )
}

///| Gets the name of a `BasicBlock`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_val = llvm_module.add_function("my_fn", fn_type);
/// let bb = context.append_basic_block(fn_val, "entry");
///
/// inspect(bb.get_name(), content="entry");
/// ```
pub fn BasicBlock::get_name(self : BasicBlock) -> String {
  self.as_bb_ref().get_name()
}

///| Sets the name of a `BasicBlock`.
///
/// ## Example
/// 
/// ```moonbit
/// let context = Context::create();
/// let lmodule = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_val = lmodule.add_function("my_fn", fn_type);
/// let bb = context.append_basic_block(fn_val, "entry");
///
/// bb.set_name("renamed_entry");
/// inspect(bb.get_name(), content="renamed_entry");
/// ```
pub fn BasicBlock::set_name(self : BasicBlock, name : String) -> Unit {
  self.as_bb_ref().as_value_ref().set_name(name)
}

///| Replaces all uses of this basic block with another.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_val = llvm_module.add_function("my_fn", fn_type);
/// let entry = context.append_basic_block(fn_val, content="entry");
/// let bb1 = context.append_basic_block(fn_val, content="bb1");
/// let bb2 = context.append_basic_block(fn_val, content="bb2");
/// builder.position_at_end(entry);
/// let branch_inst = builder.build_unconditional_branch(bb1).unwrap();
///
/// bb1.replace_all_uses_with(bb2);
///
/// assert_eq(branch_inst.get_operand(0).unwrap().right().unwrap(), bb2);
/// ```
pub fn BasicBlock::replace_all_uses_with(
  self : BasicBlock,
  other : BasicBlock
) -> Unit {
  let value = self.as_bb_ref().as_value_ref()
  let other = other.as_bb_ref().as_value_ref()
  if value != other {
    value.replace_all_uses_with(other)
  }
}

///| Gets the first use of this `BasicBlock` if any.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_val = llvm_module.add_function("my_fn", fn_type);
/// let entry = context.append_basic_block(fn_val, content="entry");
/// let bb1 = context.append_basic_block(fn_val, content="bb1");
/// let bb2 = context.append_basic_block(fn_val, content="bb2");
/// builder.position_at_end(entry);
/// let branch_inst = builder.build_unconditional_branch(bb1);
///
/// assert_true(bb2.get_first_use().is None);
/// assert_true(bb1.get_first_use().is_some());
/// ```
pub fn BasicBlock::get_first_use(self : BasicBlock) -> BasicValueUse? {
  let use_ = self.as_bb_ref().as_value_ref().get_first_use()
  if use_.is_null() {
    return None
  }
  Some(BasicValueUse::new(use_))
}

///| Gets the address of this `BasicBlock` if possible. Returns `None` if `self` is the entry block to a function.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_val = llvm_module.add_function("my_fn", fn_type);
/// let entry_bb = context.append_basic_block(fn_val, content="entry");
/// let next_bb = context.append_basic_block(fn_val, content="next");
///
/// assert_true(entry_bb.get_address() is None);
/// assert_true(next_bb.get_address() is Some(_));
/// ```
pub fn BasicBlock::get_address(self : BasicBlock) -> PointerValue? {
  guard self.get_parent() is Some(parent) else { return None }
  guard self.get_previous_basic_block() is Some(_) else { return None }
  let value = PointerValue::new(
    @unsafe.llvm_block_address(parent.as_value_ref(), self.as_bb_ref()),
  )
  @option.unless(value.is_null(), fn() { value })

}

// pub fn BasicBlock::to_string(self: BasicBlock) -> String {
//   self.as_bb_ref().to_string()
// }

// pub fn BasicBlock::dump(self: BasicBlock) -> Unit {
//   self.as_bb_ref().dump()
// }

 //pub impl Show for BasicBlock with output(self: BasicBlock, logger: &Logger) -> Unit {
 //  logger.write_string(self.as_bb_ref().to_string())
 //}

///|
pub impl Eq for BasicBlock with op_equal(self : BasicBlock, other : BasicBlock) -> Bool {
  self.as_bb_ref() == other.as_bb_ref()
}
