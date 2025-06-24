// ============================================
// InstructionValue
// ============================================

///| An `InstructionValue` is a value that represents an instruction.
pub struct InstructionValue {
  value : Value
}

///| Get a value from an `@unsafe.LLVMValueRef`.
pub fn InstructionValue::new(
  value_ref : @unsafe.LLVMValueRef
) -> InstructionValue {
  guard value_ref.is_not_null()
  InstructionValue::{ value: Value::new(value_ref) }
}

///| Returns the `Value` that this `InstructionValue` wraps.
pub fn InstructionValue::as_value(self : InstructionValue) -> Value {
  self.value
}

///| Returns the `@unsafe.LLVMValueRef` that this `InstructionValue` wraps.
pub fn InstructionValue::as_value_ref(
  self : InstructionValue
) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

///| Returns whether or not the `InstructionValue` is a load instruction.
pub fn InstructionValue::is_a_load_inst(self : InstructionValue) -> Bool {
  @unsafe.llvm_isa_load_inst(self.as_value_ref()).is_not_null()
}

///| Returns whether or not the `InstructionValue` is a store instruction.
pub fn InstructionValue::is_a_store_inst(self : InstructionValue) -> Bool {
  @unsafe.llvm_isa_store_inst(self.as_value_ref()).is_not_null()
}

///| Returns whether or not the `InstructionValue` is an alloca instruction.
pub fn InstructionValue::is_a_alloca_inst(self : InstructionValue) -> Bool {
  @unsafe.llvm_isa_alloca_inst(self.as_value_ref()).is_not_null()
}

///| Returns whether or not the `InstructionValue` is a getelementptr instruction.
pub fn InstructionValue::is_a_getelementptr_inst(
  self : InstructionValue
) -> Bool {
  @unsafe.llvm_isa_get_element_ptr_inst(self.as_value_ref()).is_not_null()
}

///| Returns whether or not the `InstructionValue` is a call instruction.
pub fn InstructionValue::is_a_atomicrmw_inst(self : InstructionValue) -> Bool {
  @unsafe.llvm_isa_atomic_rmw_inst(self.as_value_ref()).is_not_null()
}

///| Returns whether or not the `InstructionValue` is a cmpxchg instruction.
pub fn InstructionValue::is_a_cmpxchg_inst(self : InstructionValue) -> Bool {
  @unsafe.llvm_isa_atomic_cmp_xchg_inst(self.as_value_ref()).is_not_null()
}

///| Creates a clone of this `InstructionValue`, and returns it.
/// The clone will have no parent, and no name.
pub fn InstructionValue::explicit_clone(
  self : InstructionValue
) -> InstructionValue {
  InstructionValue::new(@unsafe.llvm_instruction_clone(self.as_value_ref()))
}

///| Gets the name of an `InstructionValue`.
pub fn InstructionValue::get_name(self : InstructionValue) -> String? {
  @option.unless(self.get_type().is_void_type(), fn() { self.value.get_name() })
}

///| Set name of the `InstructionValue`.
pub fn InstructionValue::set_name(
  self : InstructionValue,
  name : String
) -> Unit {
  self.value.set_name(name)
}

///| Get a instruction with it's name.
/// Compares against all instructions after self, and self.
pub fn InstructionValue::get_instruction_with_name(
  self : InstructionValue,
  name : String
) -> InstructionValue? {
  if self.get_name() is Some(n) && n == name {
    return Some(self)
  }
  if self.get_next_instruction() is Some(next_inst) {
    return next_inst.get_instruction_with_name(name)
  }
  None
}

///| Get type of the `InstructionValue`.
pub fn InstructionValue::get_type(self : InstructionValue) -> AnyTypeEnum {
  AnyTypeEnum::new(self.value.get_type().as_type_ref())
}

///| Get the opcode of the `InstructionValue`.
pub fn InstructionValue::get_opcode(
  self : InstructionValue
) -> InstructionOpcode {
  let opcode = @unsafe.llvm_get_instruction_opcode(self.as_value_ref())
  InstructionOpcode::from(opcode)
}

///| Get the previous instruction of the current instruction.
pub fn InstructionValue::get_previous_instruction(
  self : InstructionValue
) -> InstructionValue? {
  let value_ref = @unsafe.llvm_get_previous_instruction(self.as_value_ref())
  @option.unless(value_ref.is_null(), fn() { InstructionValue::new(value_ref) })
}

///| Get the next instruction of the current instruction.
pub fn InstructionValue::get_next_instruction(
  self : InstructionValue
) -> InstructionValue? {
  let value_ref = @unsafe.llvm_get_next_instruction(self.as_value_ref())
  @option.unless(value_ref.is_null(), fn() { InstructionValue::new(value_ref) })
}

// REVIEW: need review, possibly unsafe
// REVIEW: what's different with `remove_from_basic_block`?

///| Erase the instruction from the basic block.
pub fn InstructionValue::erase_from_basic_block(
  self : InstructionValue
) -> Unit {
  @unsafe.llvm_instruction_erase_from_parent(self.as_value_ref())
}

///| Remove the instruction from the basic block.
pub fn InstructionValue::remove_from_basic_block(
  self : InstructionValue
) -> Unit {
  @unsafe.llvm_instruction_remove_from_parent(self.as_value_ref())
}

///| Get the parent of the instruction.
// REVIEW: what happen if the parent been deleted?
pub fn InstructionValue::get_parent(self : InstructionValue) -> BasicBlock? {
  let p = @unsafe.llvm_get_instruction_parent(self.as_value_ref())
  @option.unless(p.is_null(), fn() { BasicBlock::new(p) })
}

///| Returns if the instruction is a terminator
pub fn InstructionValue::is_terminator(self : InstructionValue) -> Bool {
  @unsafe.llvm_isa_terminator_inst(self.as_value_ref()).is_null()
}

///| Returns if a **terminator** is conditional or not
pub fn InstructionValue::is_conditional(self : InstructionValue) -> Bool {
  if self.is_terminator() {
    @unsafe.llvm_is_conditional(self.as_value_ref())
  } else {
    false
  }
}

///| Returns if the instruction is tail call or not.
pub fn InstructionValue::is_tail_call(self : InstructionValue) -> Bool {
  if self.get_opcode() is InstructionOpcode::Call {
    @unsafe.llvm_is_tail_call(self.as_value_ref())
  } else {
    false
  }
}

///| Returns the tail call kind on call instructions.
///
/// Other instructions return `None`.
pub fn InstructionValue::get_tail_call_kind(
  self : InstructionValue
) -> @unsafe.LLVMTailCallKind? {
  if self.get_opcode() is InstructionOpcode::Call {
    Some(@unsafe.llvm_get_tail_call_kind(self.as_value_ref()))
  } else {
    None
  }
}

///| Check whether this instructions supports `fast math flags`.
///
/// Reference: https://llvm.org/docs/LangRef.html#fast-math-flags
pub fn InstructionValue::can_use_fast_math_flags(
  self : InstructionValue
) -> Bool {
  @unsafe.llvm_can_value_use_fast_math_flags(self.as_value_ref())
}

///| Get `fast math flags` of supported instructions.
///
/// Calling this on unsupported instructions is safe and returns `None`.
///
/// Reference: https://llvm.org/docs/LangRef.html#fast-math-flags
pub fn InstructionValue::get_fast_math_flags(
  self : InstructionValue
) -> FastMathFlags? {
  if self.can_use_fast_math_flags() {
    let f = @unsafe.llvm_get_fast_math_flags(self.as_value_ref())
    Some(FastMathFlags::from(f))
  } else {
    None
  }
}

///| Set `fast math flags` of supported instructions.
///
/// Calling this on unsupported instructions is safe and returns `None`.
///
/// Reference: https://llvm.org/docs/LangRef.html#fast-math-flags
pub fn InstructionValue::set_fast_math_flags(
  self : InstructionValue,
  flags : FastMathFlags
) -> Unit {
  if self.can_use_fast_math_flags() {
    @unsafe.llvm_set_fast_math_flags(self.as_value_ref(), flags.into())
  }
}

///| Get the non-negative flag on `zext` instructions.
///
/// Calling this function on other instructions is safe and results in a no-op.
pub fn InstructionValue::get_non_negative_flag(
  self : InstructionValue
) -> Bool? {
  @option.when(self.get_opcode() is InstructionOpcode::ZExt, fn() {
    @unsafe.llvm_get_n_neg(self.as_value_ref())
  })
}

///| Set the non-negative flag on `zext` instructions.
///
/// Calling this function on other instructions is safe and results in a no-op.
pub fn InstructionValue::set_non_negative_flag(
  self : InstructionValue,
  flag : Bool
) -> Unit {
  if self.get_opcode() is InstructionOpcode::ZExt {
    @unsafe.llvm_set_n_neg(self.as_value_ref(), flag)
  }
}

///| Checks if an `or` instruction has the `disjoint` flag set.
///
/// Calling this function on other instructions is safe and returns `None`.
pub fn InstructionValue::get_disjoint_flag(self : InstructionValue) -> Bool? {
  if self.get_opcode() is InstructionOpcode::Or {
    Some(self.as_value_ref().get_is_disjoint())
  } else {
    None
  }
}

///| Set the `disjoint` flag on `or` instructions.
///
/// Calling this function on other instructions is safe and results in a no-op.
pub fn InstructionValue::set_disjoint_flag(
  self : InstructionValue,
  flag : Bool
) -> Unit {
  if self.get_opcode() is InstructionOpcode::Or {
    self.as_value_ref().set_is_disjoint(flag)
  }
}

///| Replace all uses of an `InstructionValue` with another `InstructionValue`.
pub fn InstructionValue::replace_all_uses_with(
  self : InstructionValue,
  new_value : InstructionValue
) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///| Returns whether or not a memory access instruction is volatile.
/// SubTypes: Only apply to memory access instructions
pub fn InstructionValue::get_volatile(
  self : InstructionValue
) -> Result[Bool, String] {
  if not(self.is_a_load_inst()) &&
    not(self.is_a_store_inst()) &&
    not(self.is_a_atomicrmw_inst()) &&
    not(self.is_a_cmpxchg_inst()) {
    return Err("Value is not a load, store, atomicrmw or cmpxchg instruction")
  }
  Ok(@unsafe.llvm_get_volatile(self.as_value_ref()))
}

///| Sets whether or not a memory access instruction is volatile.
/// SubTypes: Only apply to memory access instructions
pub fn InstructionValue::set_volatile(
  self : InstructionValue,
  flag : Bool
) -> Result[Unit, String] {
  if not(self.is_a_load_inst()) &&
    not(self.is_a_store_inst()) &&
    not(self.is_a_atomicrmw_inst()) &&
    not(self.is_a_cmpxchg_inst()) {
    return Err("Value is not a load, store, atomicrmw or cmpxchg instruction")
  }
  self.as_value_ref().set_volatile(flag)
  Ok(())
}

///| Returns the type that is allocated by the alloca instruction.
/// SubTypes: Only apply to alloca instruction
pub fn InstructionValue::get_allocated_type(
  self : InstructionValue
) -> Result[BasicTypeEnum, String] {
  if not(self.is_a_alloca_inst()) {
    return Err("Value is not an alloca instruction")
  }
  Ok(BasicTypeEnum::new(@unsafe.llvm_get_allocated_type(self.as_value_ref())))
}

///| Returns the source element type of the given GEP.
/// SubTypes: Only apply to GetElementPtr instruction
pub fn InstructionValue::get_gep_source_element_type(
  self : InstructionValue
) -> Result[BasicTypeEnum, String] {
  if not(self.is_a_getelementptr_inst()) {
    return Err("Value is not a getelementptr instruction")
  }
  Ok(
    BasicTypeEnum::new(
      @unsafe.llvm_get_gep_source_element_type(self.as_value_ref()),
    ),
  )
}

///| Returns alignment on a memory access instruction or alloca.
/// SubTypes: Only apply to memory access and alloca instructions
pub fn InstructionValue::get_alignment(
  self : InstructionValue
) -> Result[UInt, String] {
  if not(self.is_a_alloca_inst()) &&
    not(self.is_a_load_inst()) &&
    not(self.is_a_store_inst()) {
    return Err("Value is not a load, store or alloca instruction")
  }
  Ok(@unsafe.llvm_get_alignment(self.as_value_ref()))
}

///| Returns alignment on a memory access instruction or alloca.
/// SubTypes: Only apply to memory access and alloca instructions
pub fn InstructionValue::set_alignment(
  self : InstructionValue,
  alignment : UInt
) -> Result[Unit, String] {
  if not(is_power_of_two(alignment)) && alignment != 0 {
    return Err("Alignment must be a power of two")
  }
  if not(self.is_a_alloca_inst()) &&
    not(self.is_a_load_inst()) &&
    not(self.is_a_store_inst()) {
    return Err("Value is not a load, store or alloca instruction")
  }
  @unsafe.llvm_set_alignment(self.as_value_ref(), alignment)
  Ok(())
}

///| Returns atomic ordering on a memory access instruction.
/// SubTypes: Only apply to memory access instructions
pub fn InstructionValue::get_atomic_ordering(
  self : InstructionValue
) -> Result[AtomicOrdering, String] {
  if not(self.is_a_load_inst()) && not(self.is_a_store_inst()) {
    return Err("Value is not a load or store instruction")
  }
  let ord = @unsafe.llvm_get_ordering(self.as_value_ref())
  Ok(AtomicOrdering::from(ord))
}

///| Sets atomic ordering on a memory access instruction.
/// SubTypes: Only apply to memory access instructions
pub fn InstructionValue::set_atomic_ordering(
  self : InstructionValue,
  ordering : AtomicOrdering
) -> Result[Unit, String] {
  if not(self.is_a_load_inst()) && not(self.is_a_store_inst()) {
    return Err("Value is not a load or store instruction")
  }
  match ordering {
    AtomicOrdering::Release =>
      if self.is_a_load_inst() {
        return Err("The release ordering is not valid on load instructions")
      }
    AtomicOrdering::AcquireRelease =>
      return Err(
        "The acq_rel ordering is not valid on load or store instructions",
      )
    AtomicOrdering::Acquire =>
      if self.is_a_store_inst() {
        return Err("The acquire ordering is not valid on store instructions")
      }
    _ => ()
  }
  @unsafe.llvm_set_ordering(self.as_value_ref(), ordering.into())
  Ok(())
}

///| Obtains the number of operands an `InstructionValue` has.
/// An operand is a `BasicValue` used in an IR instruction.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let f32_type = context.f32_type();
/// let f32_ptr_type = f32_type.ptr_type(AddressSpace::default());
/// let fn_type = void_type.fn_type([f32_ptr_type]);
///
/// let function = llvm_module.add_function("take_f32_ptr", fn_type);
/// let basic_block = context.append_basic_block(function, name="entry");
///
/// builder.position_at_end(basic_block);
///
/// let arg1 = function.get_first_param().unwrap().into_pointer_value();
/// let f32_val = f32_type.const_float(@math.PI);
/// let store_instruction = builder.build_store(arg1, f32_val).unwrap();
/// let free_instruction = builder.build_free(arg1);
/// let return_instruction = builder.build_return_void();
///
/// assert_eq(store_instruction.get_num_operands(), 2);
/// assert_eq(free_instruction.get_num_operands(), 2);
/// assert_eq(return_instruction.get_num_operands(), 0);
/// ```
///
/// will generate @unsafe.LLVM IR roughly like (varying slightly across @unsafe.LLVM versions):
///
/// ```llvm
/// ; ModuleID = 'ivs'
/// source_filename = "ivs"
///
/// define void @take_f32_ptr(float* %0) {
/// entry:
///   store float 0x400921FB60000000, float* %0
///   %1 = bitcast float* %0 to i8*
///   tail call void @free(i8* %1)
///   ret void
/// }
///
/// declare void @free(i8*)
/// ```
///
/// which makes the number of instruction operands clear:
/// 1) Store has two: a const float and a variable float pointer %0
/// 2) Bitcast has one: a variable float pointer %0
/// 3) Function call has two: i8 pointer %1 argument, and the free function itself
/// 4) Void return has zero: void is not a value and does not count as an operand
/// even though the return instruction can take values.
pub fn InstructionValue::get_num_operands(self : InstructionValue) -> UInt {
  @unsafe.llvm_get_num_operands(self.as_value_ref()).reinterpret_as_uint()
}

///| Obtains the operand an `InstructionValue` has at a given index if any.
/// An operand is a `BasicValue` used in an IR instruction.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let f32_type = context.f32_type();
/// let f32_ptr_type = f32_type.ptr_type(AddressSpace::default());
/// let fn_type = void_type.fn_type([f32_ptr_type]);
///
/// let function = llvm_module.add_function("take_f32_ptr", fn_type);
/// let basic_block = context.append_basic_block(function, name="entry");
///
/// builder.position_at_end(basic_block);
///
/// let arg1 = function.get_first_param().unwrap().into_pointer_value();
/// let f32_val = f32_type.const_float(@math.PI);
/// let store_instruction = builder.build_store(arg1, f32_val).unwrap();
/// let free_instruction = builder.build_free(arg1).unwrap();
/// let return_instruction = builder.build_return_void().unwrap();
///
/// assert_true(store_instruction.get_operand(0) is Some(_));
/// assert_true(store_instruction.get_operand(1) is Some(_));
/// assert_true(store_instruction.get_operand(2) is None);
/// assert_true(free_instruction.get_operand(0) is Some(_));
/// assert_true(free_instruction.get_operand(1) is Some(_));
/// assert_true(free_instruction.get_operand(2) is None);
/// assert_true(return_instruction.get_operand(0) is None);
/// assert_true(return_instruction.get_operand(1) is None);
/// ```
///
/// will generate @unsafe.LLVM IR roughly like (varying slightly across @unsafe.LLVM versions):
///
/// ```ir
/// ; ModuleID = 'ivs'
/// source_filename = "ivs"
///
/// define void @take_f32_ptr(float* %0) {
/// entry:
///   store float 0x400921FB60000000, float* %0
///   %1 = bitcast float* %0 to i8*
///   tail call void @free(i8* %1)
///   ret void
/// }
///
/// declare void @free(i8*)
/// ```
///
/// which makes the instruction operands clear:
/// 1) Store has two: a const float and a variable float pointer %0
/// 2) Bitcast has one: a variable float pointer %0
/// 3) Function call has two: i8 pointer %1 argument, and the free function itself
/// 4) Void return has zero: void is not a value and does not count as an operand
/// even though the return instruction can take values.
pub fn InstructionValue::get_operand(
  self : InstructionValue,
  index : UInt
) -> Either[BasicValueEnum, BasicBlock]? {
  let num_operands = self.get_num_operands()
  if index >= num_operands {
    return None
  }
  self.get_operand_unchecked(index)
}

///|
fn InstructionValue::get_operand_unchecked(
  self : InstructionValue,
  index : UInt
) -> Either[BasicValueEnum, BasicBlock]? {
  let operand = @unsafe.llvm_get_operand(self.as_value_ref(), index)
  if operand.is_null() {
    return None
  }
  let is_basic_block = @unsafe.llvm_isa_basic_block(operand).is_null() |> not
  if is_basic_block {
    let bb_ref = @unsafe.llvm_value_as_basic_block(operand)
    let bb = BasicBlock::new(bb_ref)
    Some(Right(bb))
  } else {
    let value = BasicValueEnum::new(operand)
    Some(Left(value))
  }
}

// TODO: should return array or iter?
// pub fn InstructionValue::get_operands()

///| Sets the operand an `InstructionValue` has at a given index if possible.
/// An operand is a `BasicValue` used in an IR instruction.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let f32_type = context.f32_type();
/// let f32_ptr_type = f32_type.ptr_type(AddressSpace::default());
/// let fn_type = void_type.fn_type([f32_ptr_type]);
///
/// let function = llvm_module.add_function("take_f32_ptr", fn_type);
/// let basic_block = context.append_basic_block(function, name="entry");
///
/// builder.position_at_end(basic_block);
///
/// let arg1 = function.get_first_param().unwrap().into_pointer_value();
/// let f32_val = f32_type.const_float(@math.PI);
/// let store_instruction = builder.build_store(arg1, f32_val);
/// let free_instruction = builder.build_free(arg1);
/// let return_instruction = builder.build_return_void();
///
/// // This will produce invalid IR:
/// free_instruction.set_operand(0, f32_val);
///
/// assert_eq(free_instruction.get_operand(0).unwrap().left().unwrap(), f32_val);
/// ```
// REVIEW: here use `bool` as return type, maybe we need to use `Result`?
pub fn InstructionValue::set_operand(
  self : InstructionValue,
  index : UInt,
  val : &BasicValue
) -> Bool {
  let num_operands = self.get_num_operands()
  if index >= num_operands {
    return false
  }
  @unsafe.llvm_set_operand(self.as_value_ref(), index, val.as_value_ref())
  true
}

///| Gets the use of an operand(`BasicValue`), if any.
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let f32_type = context.f32_type();
/// let f32_ptr_type = f32_type.ptr_type(AddressSpace::default());
/// let fn_type = void_type.fn_type([f32_ptr_type]);
///
/// let function = llvm_module.add_function("take_f32_ptr", fn_type);
/// let basic_block = context.append_basic_block(function, name="entry");
///
/// builder.position_at_end(basic_block);
///
/// let arg1 = function.get_first_param().unwrap().into_pointer_value();
/// let f32_val = f32_type.const_float(@math.PI);
/// let store_instruction = builder.build_store(arg1, f32_val).unwrap();
/// let free_instruction = builder.build_free(arg1).unwrap();
/// let return_instruction = builder.build_return_void();
///
/// assert_eq(store_instruction.get_operand_use(1), arg1.get_first_use());
/// ```
pub fn InstructionValue::get_operand_use(
  self : InstructionValue,
  index : UInt
) -> BasicValueUse? {
  let num_operands = self.get_num_operands()
  if index >= num_operands {
    return None
  }
  self.get_operand_use_unchecked(index)
}

///|
fn InstructionValue::get_operand_use_unchecked(
  self : InstructionValue,
  index : UInt
) -> BasicValueUse? {
  let use_ = @unsafe.llvm_get_operand_use(self.as_value_ref(), index)
  @option.unless(use_.is_null(), fn() { BasicValueUse::new(use_) })
}

// TODO: should return array or iter?
// pub fn InstructionValue::get_operand_uses(self: InstructionValue) ->

///| Gets the first use of an `InstructionValue` if any.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let f32_type = context.f32_type();
/// let f32_ptr_type = f32_type.ptr_type(AddressSpace::default());
/// let fn_type = void_type.fn_type([f32_ptr_type]);
///
/// let function = llvm_module.add_function("take_f32_ptr", fn_type);
/// let basic_block = context.append_basic_block(function, name="entry");
///
/// builder.position_at_end(basic_block);
///
/// let arg1 = function.get_first_param().unwrap().into_pointer_value();
/// let f32_val = f32_type.const_float(@math.PI);
/// let store_instruction = builder.build_store(arg1, f32_val);
/// let free_instruction = builder.build_free(arg1);
/// let return_instruction = builder.build_return_void();
///
/// assert_true(arg1.get_first_use() is Some(_));
/// ```
pub fn InstructionValue::get_first_use(
  self : InstructionValue
) -> BasicValueUse? {
  self.value.get_first_use()
}

///| Gets the predicate of an `ICmp` `InstructionValue`.
/// If the instruction is not an `ICmp`, this returns None.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let i32_type = context.i32_type();
/// let fn_type = i32_type.fn_type([i32_type, i32_type]);
///
/// let function = llvm_module.add_function("less", fn_type);
/// let basic_block = context.append_basic_block(function, name="entry");
///
/// builder.position_at_end(basic_block);
///
/// let arg1 = function.get_first_param().unwrap().into_int_value();
/// let arg2 = function.get_nth_param(1).unwrap().into_int_value();
/// let slt = builder.build_int_compare(IntPredicate::SLT, arg1, arg2, name="less_than");
///
/// inspect(slt.as_instruction().unwrap().get_icmp_predicate().unwrap(), content="SLT");
/// ```
pub fn InstructionValue::get_icmp_predicate(
  self : InstructionValue
) -> IntPredicate? {
  @option.when(self.get_opcode() is InstructionOpcode::ICmp, fn() {
    let p = @unsafe.llvm_get_icmp_predicate(self.as_value_ref())
    IntPredicate::from(p)
  })
}

///| Gets the predicate of an `ICmp` `InstructionValue`.
/// If the instruction is not an `ICmp`, this returns None.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let bool_type = context.bool_type();
/// let f32_type = context.i32_type();
/// let fn_type = bool_type.fn_type([f32_type, f32_type]);
///
/// let function = llvm_module.add_function("less", fn_type);
/// let basic_block = context.append_basic_block(function, name="entry");
///
/// builder.position_at_end(basic_block);
///
/// let arg1 = function.get_first_param().unwrap().into_float_value();
/// let arg2 = function.get_nth_param(1).unwrap().into_float_value();
/// let olt_pred = FloatPredicate::OLT;
/// let fcmp = builder.build_float_compare(olt_pred, arg1, arg2, name="less_than");
///
/// inspect(fcmp.as_instruction().unwrap().get_fcmp_predicate().unwrap(), content="OLT");
/// ```
pub fn InstructionValue::get_fcmp_predicate(
  self : InstructionValue
) -> FloatPredicate? {
  @option.when(self.get_opcode() is InstructionOpcode::FCmp, fn() {
    let p = @unsafe.llvm_get_fcmp_predicate(self.as_value_ref())
    FloatPredicate::from(p)
  })
}

///| Determines whether or not this `Instruction` has any associated metadata.
pub fn InstructionValue::has_metadata(self : InstructionValue) -> Bool {
  @unsafe.llvm_has_metadata(self.as_value_ref())
}

///| Gets the `MetadataValue` associated with this `Instruction` at a specific `kind_id`.
pub fn InstructionValue::get_metadata(
  self : InstructionValue,
  kind_id : UInt
) -> MetadataValue? {
  let metadata = @unsafe.llvm_get_metadata(self.as_value_ref(), kind_id)
  @option.unless(metadata.is_null(), fn() { MetadataValue::new(metadata) })
}

///|
pub fn InstructionValue::set_metadata(
  self : InstructionValue,
  metadata : MetadataValue,
  kind_id : UInt
) -> Result[Unit, String] {
  if not(metadata.is_node()) {
    return Err("Metadata is expected to be a node.")
  }
  @unsafe.llvm_set_metadata(
    self.as_value_ref(),
    kind_id,
    metadata.as_value_ref(),
  )
  Ok(())
}

///| Dumps the `InstructionValue` to stderr.
///
/// It's equivalent to `InstructionValue::dump`.
pub fn InstructionValue::print_to_stderr(self : InstructionValue) -> Unit {
  self.value.print_to_stderr()
}

///| Dumps the `InstructionValue` to a string.
///
/// It's equivalent to `InstructionValue::to_string`.
pub fn InstructionValue::print_to_string(self : InstructionValue) -> String {
  self.value.print_to_string()
}

///| Dumps the `InstructionValue` to a string.
///
/// It's equivalent to `InstructionValue::print_to_string`.
pub fn InstructionValue::to_string(self : InstructionValue) -> String {
  self.value.to_string()
}

///| Dumps the `InstructionValue` to stderr.
///
/// It's equivalent to `InstructionValue::print_to_stderr`.
pub fn InstructionValue::dump(self : InstructionValue) -> Unit {
  self.value.dump()
}

///|
pub impl Show for InstructionValue with output(
  self : InstructionValue,
  logger : &Logger
) -> Unit {
  logger.write_string(self.to_string())
}

///|
pub impl Show for InstructionValue with to_string(self : InstructionValue) -> String {
  self.to_string()
}
