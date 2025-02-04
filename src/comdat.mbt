///| A `Comdat` determines how to resolve duplicate sections when linking.
pub struct Comdat{
  comdat_ref : LLVMComdatRef
}

///| Creates a new `Comdat` type from a raw pointer.
pub fn Comdat::new(comdat: LLVMComdatRef) -> Comdat {
  // assert_not(comdat_ref.is_null())

  Comdat::{
    comdat_ref: comdat
  }
}

///| Returns `LLVMComdatRef` from `Comdat` wrapped.
pub fn as_comdat_ref(self: Comdat) -> LLVMComdatRef {
  self.comdat_ref
}

///| Gets what kind of `Comdat` this is.
pub fn get_selection_kind(self: Comdat) -> ComdatSelectionKind {
  llvm_get_comdat_selection_kind(self.comdat_ref).into()
}

///| Sets what kind of `Comdat` this should be.
pub fn set_selection_kind(self: Comdat, kind: ComdatSelectionKind) -> Unit {
  llvm_set_comdat_selection_kind(self.comdat_ref, kind.into())
}
