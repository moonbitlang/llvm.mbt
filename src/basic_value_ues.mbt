pub struct BasicValueUse {
  use_ref: LLVMUseRef
}

pub fn BasicValueUse::new(use_ref: LLVMUseRef) -> BasicValueUse {
  BasicValueUse::{
    use_ref
  }
}

pub fn BasicValueUse::as_use_ref(self: BasicValueUse) -> LLVMUseRef {
  self.use_ref
}

pub fn BasicValueUse::get_next_use(self: BasicValueUse) -> BasicValueUse? {
  let use_ref = llvm_get_next_use(self.as_use_ref());

  if use_ref.is_null() {
    None
  } else {
    Some(BasicValueUse::new(use_ref))
  }
}

pub fn BasicValueUse::get_user(self: BasicValueUse) -> AnyValueEnum {
  AnyValueEnum::new(llvm_get_user(self.as_use_ref()))
}

pub fn BasicValueUse::get_used_value(self: BasicValueUse) -> Either[BasicValueEnum, BasicBlock] {
  let used_value = llvm_get_used_value(self.as_use_ref())

  let is_basic_block = llvm_isa_basic_block(used_value).is_null() |> not

  if is_basic_block {
    let bb = BasicBlock::new(llvm_value_as_basic_block(used_value)).unwrap()
    Right(bb)
  } else {
    let value = BasicValueEnum::new(used_value)
    Left(value)
  }
}
