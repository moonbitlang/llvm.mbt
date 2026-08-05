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
