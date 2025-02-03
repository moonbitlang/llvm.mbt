///| A `BasicBlock` is a container of instructions.
///
/// `BasicBlock`s are values because they can be referenced by instructions (ie branching and switches).
///
/// A well formed `BasicBlock` is a list of non terminating instructions followed by a single terminating
/// instruction. `BasicBlock`s are allowed to be malformed prior to running validation because it may be useful
/// when constructing or modifying a program.
pub struct BasicBlock {
  bb_ref : LLVMBasicBlockRef
}

///| Return `LLVMBasicBlockRef` of this `BasicBlock` wrapped.
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

///| Obtains the `FunctionValue` that this `BasicBlock` belongs to, if any.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let function = module.add_function("do_nothing", fn_type, None);
///
/// let basic_block = context.append_basic_block(function, "entry");
///
/// assert_eq!(basic_block.get_parent().unwrap(), function);
///
/// basic_block.remove_from_function();
///
/// assert!(basic_block.get_parent().is_none());
/// ```
pub fn BasicBlock::get_parent(self: BasicBlock) -> FunctionValue? {
  FunctionValue::new(llvm_get_basic_block_parent(self.as_bb_ref()))
}

///| Gets the `BasicBlock` preceding the current one, in its own scope, if any.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let function1 = module.add_function("do_nothing", fn_type, None);
///
/// let basic_block1 = context.append_basic_block(function1, "entry");
///
/// assert!(basic_block1.get_previous_basic_block().is_none());
///
/// let function2 = module.add_function("do_nothing", fn_type, None);
///
/// let basic_block2 = context.append_basic_block(function2, "entry");
/// let basic_block3 = context.append_basic_block(function2, "next");
///
/// assert!(basic_block2.get_previous_basic_block().is_none());
/// assert_eq!(basic_block3.get_previous_basic_block().unwrap(), basic_block2);
/// ```
pub fn BasicBlock::get_previous_basic_block(self: BasicBlock) -> BasicBlock? {

  match self.get_parent() {
    None => return None
    _ => ()
  }

  BasicBlock::new(llvm_get_previous_basic_block(self.as_bb_ref()))
}


///| Gets the `BasicBlock` succeeding the current one, in its own scope, if any.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let function1 = module.add_function("do_nothing", fn_type, None);
///
/// let basic_block1 = context.append_basic_block(function1, "entry");
///
/// assert!(basic_block1.get_next_basic_block().is_none());
///
/// let function2 = module.add_function("do_nothing", fn_type, None);
///
/// let basic_block2 = context.append_basic_block(function2, "entry");
/// let basic_block3 = context.append_basic_block(function2, "next");
///
/// assert!(basic_block1.get_next_basic_block().is_none());
/// assert_eq!(basic_block2.get_next_basic_block().unwrap(), basic_block3);
/// assert!(basic_block3.get_next_basic_block().is_none());
/// ```
pub fn BasicBlock::get_next_basic_block(self: BasicBlock) -> BasicBlock? {

  match self.get_parent() {
    None => return None
    _ => ()
  }

  BasicBlock::new(llvm_get_next_basic_block(self.as_bb_ref()))
}


///| Prepends one `BasicBlock` before another.
/// It returns `Err(())` when either `BasicBlock` has no parent, as LLVM assumes they both have parents.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let function = module.add_function("do_nothing", fn_type, None);
///
/// let basic_block1 = context.append_basic_block(function, "entry");
/// let basic_block2 = context.append_basic_block(function, "next");
///
/// basic_block2.move_before(basic_block1);
///
/// assert!(basic_block1.get_next_basic_block().is_none());
/// assert_eq!(basic_block2.get_next_basic_block().unwrap(), basic_block1);
/// ```
pub fn BasicBlock::move_before(self: BasicBlock, other: BasicBlock) -> Result[Unit, Unit] {
  match (self.get_parent(), other.get_parent()) {
    (None, _) => return Err(())
    (_, None) => return Err(())
    _ => ()
  }

  llvm_move_basic_block_before(self.as_bb_ref(), other.as_bb_ref())
  Ok(())
}

///| Appends one `BasicBlock` after another.
/// It returns `Err(())` when either `BasicBlock` has no parent, as LLVM assumes they both have parents.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let function = module.add_function("do_nothing", fn_type, None);
///
/// let basic_block1 = context.append_basic_block(function, "entry");
/// let basic_block2 = context.append_basic_block(function, "next");
///
/// basic_block1.move_after(basic_block2);
///
/// assert!(basic_block1.get_next_basic_block().is_none());
/// assert_eq!(basic_block2.get_next_basic_block().unwrap(), basic_block1);
/// ```
pub fn BasicBlock::move_after(self: BasicBlock, other: BasicBlock) -> Result[Unit, Unit] {
  match (self.get_parent(), other.get_parent()) {
    (None, _) => return Err(())
    (_, None) => return Err(())
    _ => ()
  }

  llvm_move_basic_block_after(self.as_bb_ref(), other.as_bb_ref())
  Ok(())
}


///| Obtains the first `InstructionValue` in this `BasicBlock`, if any.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let builder = context.create_builder();
/// let module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let function = module.add_function("do_nothing", fn_type, None);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// builder.position_at_end(basic_block);
/// builder.build_return(None);
///
/// let opcode = basic_block.get_first_instruction().unwrap().get_opcode();
/// assert_eq!(opcode, InstructionOpcode::Return);
/// ```
pub fn BasicBlock::get_first_instruction(self: BasicBlock) -> InstructionValue? {
  let inst = llvm_get_first_instruction(self.as_bb_ref())

  if inst.is_null() {
    return None
  }

  Some(InstructionValue::new(inst))
}

///| Obtains the last `InstructionValue` in this `BasicBlock`, if any. A `BasicBlock` must have a last instruction to be valid.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let builder = context.create_builder();
/// let module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let function = module.add_function("do_nothing", fn_type, None);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// builder.position_at_end(basic_block);
/// builder.build_return(None);
///
/// let opcode = basic_block.get_last_instruction().unwrap().get_opcode();
/// assert_eq!(opcode, InstructionOpcode::Return);
/// ```
pub fn BasicBlock::get_last_instruction(self: BasicBlock) -> InstructionValue? {
  let inst = llvm_get_last_instruction(self.as_bb_ref())

  if inst.is_null() {
    return None
  }

  Some(InstructionValue::new(inst))
}


///| Performs a linear lookup to obtain a instruction based on the name
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ret");
/// let builder = context.create_builder();
///
/// let void_type = context.void_type();
/// let i32_type = context.i32_type();
/// let i32_ptr_type = i32_type.ptr_type(AddressSpace::default());
///
/// let fn_type = void_type.fn_type([i32_ptr_type], false);
/// let fn_value = module.add_function("ret", fn_type, None);
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
/// assert_true!(some_number.is_some());
/// inspect!(some_number.unwrap().get_name().unwrap(), contend="some_number")
/// ```
pub fn BasicBlock::get_instruction_with_name(self: BasicBlock, name: String) -> InstructionValue? {
  let inst = self.get_first_instruction()
  match inst {
    Some(inst) => inst.get_instruction_with_name(name)
    None => None
  }
  
}

///| Obtains the terminating `InstructionValue` in this `BasicBlock`, if any. A `BasicBlock` must have a terminating instruction to be valid.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let builder = context.create_builder();
/// let module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type(&[], false);
/// let function = module.add_function("do_nothing", fn_type, None);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// builder.position_at_end(basic_block);
/// builder.build_return(None);
///
/// let opcode = basic_block.get_terminator().unwrap().get_opcode()
/// assert_eq!(opcode, InstructionOpcode::Return);
/// ```
pub fn BasicBlock::get_terminator(self: BasicBlock) -> InstructionValue? {
  let inst = llvm_get_basic_block_terminator(self.as_bb_ref())

  if inst.is_null() {
    return None
  }

  Some(InstructionValue::new(inst))
}

// pub fn BasicBlock::get_instructions(self) -> InstructionIter

///| Removes this `BasicBlock` from its parent `FunctionValue`.
/// It returns `Err(())` when it has no parent to remove from.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let function = module.add_function("do_nothing", fn_type, None);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// assert_eq!(basic_block.get_parent().unwrap(), function);
///
/// basic_block.remove_from_function();
///
/// assert!(basic_block.get_parent().is_none());
/// ```
pub fn remove_from_function(self: BasicBlock) -> Result[Unit, Unit] {
  match self.get_parent() {
    None => return Err(())
    _ => ()
  }

  llvm_remove_basic_block_from_parent(self.as_bb_ref())
  Ok(())
}

/// Removes this `BasicBlock` completely from memory. This is unsafe because you could easily have other references to the same `BasicBlock`.
/// It returns `Err(())` when it has no parent to delete from, as LLVM assumes it has a parent.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let function = module.add_function("do_nothing", fn_type);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// basic_block.delete();
/// assert!(function.get_basic_blocks().is_empty());
/// ```
pub fn BasicBlock::delete(self: BasicBlock) -> Result[Unit, Unit] {
  match self.get_parent() {
    None => return Err(())
    _ => ()
  }

  llvm_delete_basic_block(self.as_bb_ref())

  Ok(())
}

///| Obtains the `ContextRef` this `BasicBlock` belongs to.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_module");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let function = module.add_function("do_nothing", fn_type);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// assert_true!(context == basic_block.get_context());
/// ```
pub fn BasicBlock::get_context(self: BasicBlock) -> Context {
  Context::new(llvm_get_type_context(llvm_type_of(self.as_bb_ref().as_value_ref())))
}

///| Gets the name of a `BasicBlock`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let builder = context.create_builder();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_val = module.add_function("my_fn", fn_type);
/// let bb = context.append_basic_block(fn_val, "entry");
///
/// inspect!(bb.get_name(), contend="entry");
/// ```
pub fn BasicBlock::get_name(self: BasicBlock) -> String {
  self.as_bb_ref().get_name()
}

pub fn BasicBlock::set_name(self: BasicBlock, name: String) -> Unit {
  self.as_bb_ref().as_value_ref().set_name(name)
}

///| Replaces all uses of this basic block with another.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let builder = context.create_builder();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_val = module.add_function("my_fn", fn_type, None);
/// let entry = context.append_basic_block(fn_val, "entry");
/// let bb1 = context.append_basic_block(fn_val, "bb1");
/// let bb2 = context.append_basic_block(fn_val, "bb2");
/// builder.position_at_end(entry);
/// let branch_inst = builder.build_unconditional_branch(bb1).unwrap();
///
/// bb1.replace_all_uses_with(bb2);
///
/// assert_eq!(branch_inst.get_operand(0).unwrap().right().unwrap(), bb2);
/// ```
pub fn BasicBlock::replace_all_uses_with(self: BasicBlock, other: BasicBlock) -> Unit {
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
/// let module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let fn_val = module.add_function("my_fn", fn_type);
/// let entry = context.append_basic_block(fn_val, "entry");
/// let bb1 = context.append_basic_block(fn_val, "bb1");
/// let bb2 = context.append_basic_block(fn_val, "bb2");
/// builder.position_at_end(entry);
/// let branch_inst = builder.build_unconditional_branch(bb1);
///
/// assert!(bb2.get_first_use().is_none());
/// assert!(bb1.get_first_use().is_some());
/// ```
pub fn BasicBlock::get_first_use(self: BasicBlock) -> BasicValueUse? {
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
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let fn_val = module.add_function("my_fn", fn_type, None);
/// let entry_bb = context.append_basic_block(fn_val, "entry");
/// let next_bb = context.append_basic_block(fn_val, "next");
///
/// assert_true!(unsafe { entry_bb.get_address() }.is_none());
/// assert_true!(unsafe { next_bb.get_address() }.is_some());
/// ```
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
