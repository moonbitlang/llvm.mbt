///| A wrapper around @unsafe.LLVM intrinsic id
///
/// To call it you would need to create a declaration inside a module using [`Self::get_declaration()`].
pub struct Intrinsic {
  id : UInt
}

///| Create an Intrinsic object from raw @unsafe.LLVM intrinsic id
pub fn Intrinsic::new(id : UInt) -> Intrinsic {
  Intrinsic::{ id, }
}

///| Find llvm intrinsic id from name
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let trap_intrinsic = Intrinsic::find("llvm.trap").unwrap();
///
/// let context = Context::create();
/// let module = context.create_module("trap");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = module.add_function("trap", fn_type);
/// let entry = context.append_basic_block(fn_value, "entry");
///
/// let trap_function = trap_intrinsic.get_declaration(module, []).unwrap();
///
/// builder.position_at_end(entry);
/// builder.build_call(trap_function, [], "trap_call");
/// ```
pub fn Intrinsic::find(name : String) -> Intrinsic? {
  let id = @unsafe.llvm_lookup_intrinsic_id(name)
  if id == 0 {
    return None
  }
  Some(Intrinsic::new(id))
}

///| Check if specified intrinsic is overloaded
///
/// Overloaded intrinsics need some argument types to be specified to declare them
pub fn Intrinsic::is_overloaded(self : Intrinsic) -> Bool {
  @unsafe.llvm_intrinsic_is_overloaded(self.id)
}

///| Create or insert the declaration of an intrinsic.
///
/// For overloaded intrinsics, parameter types must be provided to uniquely identify an overload.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let trap_intrinsic = Intrinsic::find("llvm.trap").unwrap();
///
/// let context = Context::create();
/// let module = context.create_module("trap");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = module.add_function("trap", fn_type);
/// let entry = context.append_basic_block(fn_value, "entry");
///
/// let trap_function = trap_intrinsic.get_declaration(module, []).unwrap();
///
/// builder.position_at_end(entry);
/// builder.build_call(trap_function, [], "trap_call");
/// ```
pub fn Intrinsic::get_declaration(
  self : Intrinsic,
  mod : Module,
  param_types : Array[BasicTypeEnum]
) -> FunctionValue? {
  let param_types = param_types.map(fn(t) { t.as_type_ref() })
  if self.is_overloaded() && param_types.is_empty() {
    return None
  }
  let r = @unsafe.llvm_get_intrinsic_declaration(
    mod.as_mod_ref(),
    self.id,
    param_types,
  )
  FunctionValue::new(r)
}
