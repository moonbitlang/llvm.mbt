///|
/// A value handle whose lifetime is bounded by its defining Module.
priv struct ModuleAnchoredValue {
  value_ref : ValueRef
  owner_module : Module
}

///|
fn ModuleAnchoredValue::new(
  value_ref : ValueRef,
  owner_module : Module,
) -> ModuleAnchoredValue {
  ModuleAnchoredValue::{ value_ref, owner_module }
}

///|
fn ModuleAnchoredValue::get_raw_ref(self : ModuleAnchoredValue) -> ValueRef {
  self.value_ref
}

///|
fn ModuleAnchoredValue::get_module(self : ModuleAnchoredValue) -> Module {
  self.owner_module
}

///|
/// A value handle whose lifetime is bounded by its LLVM Context.
priv struct ContextAnchoredValue {
  value_ref : ValueRef
  context : Context
}

///|
fn ContextAnchoredValue::new(
  value_ref : ValueRef,
  context : Context,
) -> ContextAnchoredValue {
  ContextAnchoredValue::{ value_ref, context }
}

///|
fn ContextAnchoredValue::get_raw_ref(self : ContextAnchoredValue) -> ValueRef {
  self.value_ref
}

///|
fn ContextAnchoredValue::get_context(self : ContextAnchoredValue) -> Context {
  self.context
}
