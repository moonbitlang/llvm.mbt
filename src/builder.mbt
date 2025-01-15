
pub struct Builder {
  builder_ref: LLVMBuilderRef
}

pub fn Builder::new(builder_ref: LLVMBuilderRef) -> Builder {
  Builder::{
    builder_ref: builder_ref
  }
}

fn as_builder_ref(self: Builder) -> LLVMBuilderRef {
  self.builder_ref
}

pub fn build_return[T: ValueRef](self: Builder, val~:T?=None) -> Unit {
  let builder_ref = self.as_builder_ref()
  match val {
    Some(val) => {
      let val_ref = val.as_value_ref()
      llvm_build_ret(builder_ref, val_ref)
    }
    None => {
      llvm_build_ret_void(builder_ref)
    }
  }
}

pub fn position_at_end(self: Builder, bb: BasicBlock) -> Unit {
  let builder_ref = self.builder_ref
  let bb_ref = bb.bb_ref
  llvm_position_builder_at_end(builder_ref, bb_ref)
}

