///|
/// A type handle whose lifetime is bounded by its LLVM Context.
priv struct ContextAnchoredType {
  type_ref : @unsafe.LLVMTypeRef
  context : Context
}

///|
fn ContextAnchoredType::new(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> ContextAnchoredType {
  ContextAnchoredType::{ type_ref, context }
}

///|
fn ContextAnchoredType::get_unsafe_ref(
  self : ContextAnchoredType,
) -> @unsafe.LLVMTypeRef {
  self.type_ref
}

///|
fn ContextAnchoredType::get_context(self : ContextAnchoredType) -> Context {
  self.context
}

///|
impl Eq for ContextAnchoredType with fn equal(self, other) {
  self.type_ref == other.type_ref
}
