// =============================================
// BasicValueUse
// =============================================
pub struct BasicValueUse {
  use_ref: LLVMUseRef
}

pub fn BasicValueUse::new(use_ref: LLVMUseRef) -> BasicValueUse {
  BasicValueUse::{
    use_ref: use_ref
  }
}

pub fn BasicValueUse::as_use_ref(self: BasicValueUse) -> LLVMUseRef {
  self.use_ref
}

pub fn BasicValueUse::get_next_use(self: BasicValueUse) -> BasicValueUse? {
  let next_use_ref = llvm_get_next_use(self.as_use_ref());

  if next_use_ref.is_null() {
    None
  } else {
    Some(BasicValueUse::new(next_use_ref))
  }
}

// pub fn BasicValueUse::get_user(self: BasicValueUse) -> AnyValueEnum {
//   AnyValueEnum::new(llvm_get_user(self.as_use_ref()))
// }

// pub fn get_used_value
