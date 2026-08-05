///|
/// A type handle whose lifetime is bounded by its LLVM Context.
priv struct ContextOwnedType {
  type_ref : @unsafe.LLVMTypeRef
  context : Context
}

///|
fn ContextOwnedType::new(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> ContextOwnedType {
  ContextOwnedType::{ type_ref, context }
}

///|
fn ContextOwnedType::get_unsafe_ref(
  self : ContextOwnedType,
) -> @unsafe.LLVMTypeRef {
  self.type_ref
}

///|
fn ContextOwnedType::get_context(self : ContextOwnedType) -> Context {
  self.context
}

///|
impl Eq for ContextOwnedType with fn equal(self, other) {
  self.type_ref == other.type_ref
}
