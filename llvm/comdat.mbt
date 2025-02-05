///| A `Comdat` determines how to resolve duplicate sections when linking.
pub struct Comdat{
  comdat_ref : @unsafe.LLVMComdatRef
}

///| Creates a new `Comdat` type from a raw pointer.
pub fn Comdat::new(comdat: @unsafe.LLVMComdatRef) -> Comdat {
  // assert_not(comdat_ref.is_null())

  Comdat::{
    comdat_ref: comdat
  }
}

///| Returns `@unsafe.LLVMComdatRef` from `Comdat` wrapped.
pub fn as_comdat_ref(self: Comdat) -> @unsafe.LLVMComdatRef {
  self.comdat_ref
}

///| Gets what kind of `Comdat` this is.
pub fn get_selection_kind(self: Comdat) -> ComdatSelectionKind {
  let csk = @unsafe.llvm_get_comdat_selection_kind(self.comdat_ref)
  ComdatSelectionKind::from(csk)
}

///| Sets what kind of `Comdat` this should be.
pub fn set_selection_kind(self: Comdat, kind: ComdatSelectionKind) -> Unit {
  @unsafe.llvm_set_comdat_selection_kind(self.comdat_ref, kind.into())
}
