///|
/// A type handle whose lifetime is bounded by its LLVM Context.
priv struct ContextAnchoredType {
  type_ref : @raw.LLVMTypeRef
  context : Context
}

///|
fn ContextAnchoredType::new(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> ContextAnchoredType {
  ContextAnchoredType::{ type_ref, context }
}

///|
fn ContextAnchoredType::get_raw_ref(
  self : ContextAnchoredType,
) -> @raw.LLVMTypeRef {
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
