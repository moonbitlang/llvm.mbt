// pub enum ComdatSelectionkind {
//   Any
//   ExactMatch
//   Largest
//   NoDuplicates
//   SameSize
// }

pub struct Comdat{
  comdat_ref : LLVMComdatRef
}

pub fn Comdat::new(comdat: LLVMComdatRef) -> Comdat {
  // assert_not(comdat_ref.is_null())

  Comdat::{
    comdat_ref: comdat
  }
}
