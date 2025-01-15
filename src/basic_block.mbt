
pub struct BasicBlock {
  bb_ref : LLVMBasicBlockRef
}

pub fn BasicBlock::new(basic_block_ref : LLVMBasicBlockRef) -> BasicBlock {
  BasicBlock::{
    bb_ref : basic_block_ref
  }
}
