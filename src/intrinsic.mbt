pub struct Intrinsic {
  id: UInt
}

pub fn Intrinsic::new(id: UInt) -> Intrinsic {
  Intrinsic::{ id }
}

pub fn Intrinsic::find(name: String) -> Intrinsic? {
  let id = llvm_lookup_intrinsic_id(name)

  if id == 0 {
    return None
  }

  Some(Intrinsic::new(id))
}

pub fn Intrinsic::is_overloaded(self: Intrinsic) -> Bool {
  llvm_intrinsic_is_overloaded(self.id)
}

pub fn Intrinsic::get_declaration(
  self: Intrinsic, mod: Module, param_types: Array[BasicTypeEnum]
) -> FunctionValue? {
  let param_types = param_types.map(fn (t) {t.as_type_ref()})

  if self.is_overloaded() && param_types.is_empty() {
    return None
  }

  let r = llvm_get_intrinsic_declaration(mod.as_mod_ref(), self.id, param_types)

  FunctionValue::new(r)
}
