///| it's equivalent to @unsafe.LLVM's `Use` class
pub struct BasicValueUse {
  use_ref: @unsafe.LLVMUseRef
}

///| Get a value from an `@unsafe.LLVMUseRef`.
pub fn BasicValueUse::new(use_ref: @unsafe.LLVMUseRef) -> BasicValueUse {
  BasicValueUse::{
    use_ref
  }
}

///| Return the `@unsafe.LLVMUseRef` of the `BasicValueUse` wrapped.
pub fn BasicValueUse::as_use_ref(self: BasicValueUse) -> @unsafe.LLVMUseRef {
  self.use_ref
}

///| Gets the next use of a `BasicBlock`, `InstructionValue` or `BasicValue` if any.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let f32_type = context.f32_type();
/// let f32_ptr_type = f32_type.ptr_type(AddressSpace::default());
/// let fn_type = void_type.fn_type([f32_ptr_type]);
///
/// let function = module.add_function("take_f32_ptr", fn_type);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// builder.position_at_end(basic_block);
///
/// let arg1 = function.get_first_param().unwrap().into_pointer_value();
/// let f32_val = f32_type.const_float(@math.PI);
/// let store_instruction = builder.build_store(arg1, f32_val).unwrap();
/// let free_instruction = builder.build_free(arg1).unwrap();
/// let return_instruction = builder.build_return(None).unwrap();
///
/// let arg1_first_use = arg1.get_first_use().unwrap();
///
/// assert_true!(arg1_first_use.get_next_use().is_some());
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
/// which makes the arg1 (%0) uses clear:
/// 1) In the store instruction
/// 2) In the pointer bitcast
pub fn BasicValueUse::get_next_use(self: BasicValueUse) -> BasicValueUse? {
  let use_ref = @unsafe.llvm_get_next_use(self.as_use_ref());

  if use_ref.is_null() {
    None
  } else {
    Some(BasicValueUse::new(use_ref))
  }
}

///| Gets the user (an `AnyValueEnum`) of this use.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let f32_type = context.f32_type();
/// let f32_ptr_type = f32_type.ptr_type(AddressSpace::default());
/// let fn_type = void_type.fn_type([f32_ptr_type]);
///
/// let function = module.add_function("take_f32_ptr", fn_type);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// builder.position_at_end(basic_block);
///
/// let arg1 = function.get_first_param().unwrap().into_pointer_value();
/// let f32_val = f32_type.const_float(@math.PI);
/// let store_instruction = builder.build_store(arg1, f32_val).unwrap();
/// let free_instruction = builder.build_free(arg1).unwrap();
/// let return_instruction = builder.build_return(None).unwrap();
///
/// let store_operand_use0 = store_instruction.get_operand_use(0).unwrap();
/// let store_operand_use1 = store_instruction.get_operand_use(1).unwrap();
///
/// assert_eq!(store_operand_use0.get_user(), store_instruction);
/// assert_eq!(store_operand_use1.get_user(), store_instruction);
/// ```
pub fn BasicValueUse::get_user(self: BasicValueUse) -> AnyValueEnum {
  AnyValueEnum::new(@unsafe.llvm_get_user(self.as_use_ref()))
}

///| Gets the used value (a `BasicValueEnum` or `BasicBlock`) of this use.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ivs");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let f32_type = context.f32_type();
/// let f32_ptr_type = f32_type.ptr_type(AddressSpace::default());
/// let fn_type = void_type.fn_type([f32_ptr_type]);
///
/// let function = module.add_function("take_f32_ptr", fn_type);
/// let basic_block = context.append_basic_block(function, "entry");
///
/// builder.position_at_end(basic_block);
///
/// let arg1 = function.get_first_param().unwrap().into_pointer_value();
/// let f32_val = f32_type.const_float(@math.PI);
/// let store_instruction = builder.build_store(arg1, f32_val).unwrap();
/// let free_instruction = builder.build_free(arg1).unwrap();
/// let return_instruction = builder.build_return(None).unwrap();
///
/// let free_operand0 = free_instruction.get_operand(0).unwrap().left().unwrap();
/// let free_operand0_instruction = free_operand0.as_instruction_value().unwrap();
/// let bitcast_use_value = free_operand0_instruction
///     .get_first_use()
///     .unwrap()
///     .get_used_value()
///     .left()
///     .unwrap();
///
/// assert_eq!(bitcast_use_value, free_operand0);
/// ```
pub fn BasicValueUse::get_used_value(self: BasicValueUse) -> Either[BasicValueEnum, BasicBlock] {
  let used_value = @unsafe.llvm_get_used_value(self.as_use_ref())

  let is_basic_block = @unsafe.llvm_isa_basic_block(used_value).is_null() |> not

  if is_basic_block {
    let bb = BasicBlock::new(@unsafe.llvm_value_as_basic_block(used_value)).unwrap()
    Right(bb)
  } else {
    let value = BasicValueEnum::new(used_value)
    Left(value)
  }
}
