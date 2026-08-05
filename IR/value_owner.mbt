///|
/// A value handle whose lifetime is bounded by its defining Module.
priv struct ModuleOwnedValue {
  value_ref : ValueRef
  owner_module : Module
}

///|
fn ModuleOwnedValue::new(
  value_ref : ValueRef,
  owner_module : Module,
) -> ModuleOwnedValue {
  ModuleOwnedValue::{ value_ref, owner_module }
}

///|
fn ModuleOwnedValue::get_unsafe_ref(self : ModuleOwnedValue) -> ValueRef {
  self.value_ref
}

///|
fn ModuleOwnedValue::get_module(self : ModuleOwnedValue) -> Module {
  self.owner_module
}

///|
/// A value handle whose lifetime is bounded by its LLVM Context.
priv struct ContextOwnedValue {
  value_ref : ValueRef
  context : Context
}

///|
fn ContextOwnedValue::new(
  value_ref : ValueRef,
  context : Context,
) -> ContextOwnedValue {
  ContextOwnedValue::{ value_ref, context }
}

///|
fn ContextOwnedValue::get_unsafe_ref(self : ContextOwnedValue) -> ValueRef {
  self.value_ref
}

///|
fn ContextOwnedValue::get_context(self : ContextOwnedValue) -> Context {
  self.context
}
