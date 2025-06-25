///| Equvilant to @unsafe.LLVM's `llvm_module` class
pub struct Module {
  module_ref : @unsafe.LLVMModuleRef
}

///| Get a llvm_module from an `@unsafe.LLVMModuleRef`.
pub fn Module::new(module_ref : @unsafe.LLVMModuleRef) -> Module {
  Module::{ module_ref, }
}

///| Return the `@unsafe.LLVMModuleRef` of the llvm_module wrapped.
pub fn Module::as_mod_ref(self : Module) -> @unsafe.LLVMModuleRef {
  self.module_ref
}

///| Creates a function given its `name` and `ty`, adds it to the `llvm_module` and returns it.
///
/// An optional `linkage` can be specified, without which the default value
/// `Linkage::ExternalLinkage` will be used.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip (GlobalValue equality not supported)
/// let context = Context::create();
/// let llvm_module = context.create_module("my_module");
///
/// let fn_type = context.f32_type().fn_type([]);
/// let fn_val = llvm_module.add_function("my_function", fn_type);
///
/// inspect(fn_val.get_name(), content="my_function");
/// ```
pub fn Module::add_function(
  self : Module,
  name : String,
  function_ty : FunctionType,
  linkage~ : Linkage? = None
) -> FunctionValue {
  let val_ref = self.module_ref.add_function(name, function_ty.as_type_ref())
  guard FunctionValue::new(val_ref) is Some(fn_val) else {
    abort(
      "Failed to create FunctionValue, Something went wrong, loc: llvm_module.mbt: add_function",
    )
  }
  if linkage is Some(linkage) {
    fn_val.set_linkage(linkage)
  }
  fn_val
}

///| Gets the `Context` from which this `llvm_module` originates.
///
/// # Example
///
/// ```moonbit skip skip (GlobalValue equality not supported)
/// let local_context = Context::create();
/// let local_module = local_context.create_module("my_module");
///
/// assert_true(local_module.get_context() == local_context);
/// ```
pub fn Module::get_context(self : Module) -> Context {
  let ctx_ref = @unsafe.llvm_get_module_context(self.as_mod_ref())
  Context::new(ctx_ref)
}

///| Gets the first `FunctionValue` defined in this `llvm_module`.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip (GlobalValue equality not supported)
/// let context = Context::create();
/// let llvm_module = context.create_module("my_mod");
///
/// assert_true(llvm_module.get_first_function() is None);
///
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
///
/// assert_true(fn_value == llvm_module.get_first_function().unwrap());
/// ```
pub fn Module::get_first_function(self : Module) -> FunctionValue? {
  let val_ref = @unsafe.llvm_get_first_function(self.as_mod_ref())
  FunctionValue::new(val_ref)
}

///| Gets the last `FunctionValue` defined in this `llvm_module`.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip (GlobalValue equality not supported)
/// let context = Context::create();
/// let llvm_module = context.create_module("my_mod");
///
/// assert_true(llvm_module.get_last_function() is None);
///
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
///
/// assert_eq(fn_value, llvm_module.get_last_function().unwrap());
/// ```
pub fn Module::get_last_function(self : Module) -> FunctionValue? {
  let val_ref = @unsafe.llvm_get_last_function(self.as_mod_ref())
  FunctionValue::new(val_ref)
}

///| Gets a `FunctionValue` defined in this `llvm_module` by its name.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_mod");
///
/// assert_true(llvm_module.get_function("my_fn") is None);
///
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
///
/// assert_eq(fn_value, llvm_module.get_function("my_fn").unwrap());
/// ```
pub fn Module::get_function(self : Module, name : String) -> FunctionValue? {
  let val_ref = @unsafe.llvm_get_named_function(self.as_mod_ref(), name)
  FunctionValue::new(val_ref)
}

///| Return functions in this `llvm_module`.
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_mod");
///
/// assert_true(llvm_module.get_function("my_fn") is None);
///
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let _ = llvm_module.add_function("my_fn", fn_type);
///
/// let names = llvm_module
///     .get_functions().map(fn (f) { f.get_name() });
///
/// inspect(names, content="[\"my_fn\"]");
/// ```
pub fn Module::get_functions(self : Module) -> Array[FunctionValue] {
  let funcs : Array[FunctionValue] = Array::new()
  let func = self.get_first_function()
  loop func {
    Some(f) => {
      funcs.push(f)
      continue f.get_next_function()
    }
    None => break funcs
  }
}

///| Gets a named `StructType` from this `llvm_module`'s `Context`.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip (structType not implement op_equal)
/// let context = Context::create();
/// let llvm_module = context.create_module("my_module");
///
/// assert_true(llvm_module.get_struct_type("foo") is None);
///
/// let opaque = context.opaque_struct_type("foo");
/// assert_true(llvm_module.get_struct_type("foo").unwrap() == opaque);
/// ```
pub fn Module::get_struct_type(self : Module, name : String) -> StructType? {
  self.get_context().get_struct_type(name)
}

// Assigns a `TargetTriple` to this `llvm_module`.
//
// # Example
//
// ```rust,no_run
// Target::initialize_x86(Default::default());
// let context = Context::create();
// let llvm_module = context.create_module("mod");
// let triple = TargetTriple::create("x86_64-pc-linux-gnu");
//
// assert_eq(llvm_module.get_triple(), TargetTriple::create(""));
//
// llvm_module.set_triple(&triple);
//
// assert_eq(llvm_module.get_triple(), triple);
// ```
// pub fn Module::set_triple(self: Module, triple: TargetTriple) -> Unit {
//   @unsafe.llvm_set_target(self.as_mod_ref(), triple.as_string())
// }

// Gets the `TargetTriple` assigned to this `llvm_module`. If none has been
// assigned, the triple will default to "".
//
// # Example
//
// ```rust,no_run
// Target::initialize_x86(Default::default());
// let context = Context::create();
// let llvm_module = context.create_module("mod");
// let triple = TargetTriple::create("x86_64-pc-linux-gnu");
//
// assert_eq(llvm_module.get_triple(), TargetTriple::create(""));
//
// llvm_module.set_triple(&triple);
//
// assert_eq(llvm_module.get_triple(), triple);
// ```
// pub fn get_triple(self) -> TargetTriple {
//   // REVIEW: This isn't an owned @unsafe.LLVMString, is it? If so, need to deallocate.
//   let target_str = @unsafe.LLVMGetTarget(self.llvm_module.get());
//
//   TargetTriple::new(CStr::from_ptr(target_str))
// }

// More about target triple, engine

///| Creates a `GlobalValue` based on a type in an address space.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip (GlobalValue equality not supported)
/// let context = Context::create();
/// let llvm_module = context.create_module("mod");
/// let i8_type = context.i8_type();
/// let global = llvm_module.add_global(i8_type, Some(AddressSpace(1)), "my_global");
///
/// assert_true(llvm_module.get_first_global() == global);
/// assert_true(llvm_module.get_last_global() == global);
/// ```
pub fn[T : BasicType] Module::add_global(
  self : Module,
  ty : T,
  addr_space : AddressSpace?,
  name : String
) -> GlobalValue {
  let val = match addr_space {
    Some(addr_space) =>
      @unsafe.llvm_add_global_in_address_space(
        self.as_mod_ref(),
        ty.as_type_ref(),
        name,
        addr_space.into(),
      )
    None => @unsafe.llvm_add_global(self.as_mod_ref(), ty.as_type_ref(), name)
  }
  GlobalValue::new(val)
}

// TODO: enable it when `@unsafe.llvm_write_bitcode_to_path` is available
// pub fn Module::write_bitecode_to_path(self: Module, path: String) -> Unit {
//   @unsafe.llvm_write_bitcode_to_path(self.as_mod_ref(), path)
// }

// pub fn Module::write_bitcode_to_file(self: Module, file: File, should_close: Bool, unbuffered: Bool) -> Unit {
//   @unsafe.llvm_write_bitcode_to_fd(self.as_mod_ref(), file.as_file_ref())
// }

// pub fn Module::write_bitcode_to_memory(self: Module) -> MemoryBuffer {
//   let mem_buf = @unsafe.llvm_write_bitcode_to_memory(self.as_mod_ref())
//   MemoryBuffer::new(mem_buf)
// }

// pub fn Module::verify(self: Module) -> Bool {
//
// }

// pub fn Module::get_data_layout
// pub fn Module::set_data_layout

// pub fn Module::print_to_file(self: Module, file: File) -> Unit {
//   @unsafe.llvm_print_module_to_file(self.module_ref, file.as_file_ref())
// }

///|
pub fn Module::set_inline_assembly(self : Module, asm_code : String) -> Unit {
  @unsafe.llvm_set_module_inline_asm(self.module_ref, asm_code)
}

///| Appends a `MetaDataValue` to a global list indexed by a particular key.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip (some func not implemented)
/// let context = Context::create();
/// let llvm_module = context.create_module("my_module");
/// let bool_type = context.bool_type();
/// let f32_type = context.f32_type();
/// let bool_val = bool_type.const_int(0, sign_extend=false);
/// let f32_val = f32_type.const_float(0.0);
///
/// assert_eq(llvm_module.get_global_metadata_size("my_md"), 0);
///
/// let md_string = context.metadata_string("lots of metadata here");
/// let md_node = context.metadata_node([bool_val, f32_val]);
///
/// llvm_module.add_global_metadata("my_md", md_string).unwrap();
/// llvm_module.add_global_metadata("my_md", md_node).unwrap();
///
/// assert_eq(llvm_module.get_global_metadata_size("my_md"), 2);
///
/// let global_md = llvm_module.get_global_metadata("my_md");
///
/// assert_eq(global_md.length(), 2);
///
/// let (md_0, md_1) = (global_md[0].get_node_values(), global_md[1].get_node_values());
///
/// assert_eq(md_0.len(), 1);
/// assert_eq(md_1.len(), 2);
/// assert_eq(md_0[0].into_metadata_value().get_string_value(), md_string.get_string_value());
/// assert_eq(md_1[0].into_int_value(), bool_val);
/// assert_eq(md_1[1].into_float_value(), f32_val);
/// ```
pub fn Module::add_global_metadata(
  self : Module,
  name : String,
  metadata : MetadataValue
) -> Result[Unit, String] {
  if not(metadata.is_node()) {
    return Err("MetadataValue is not a node".to_string())
  }
  @unsafe.llvm_add_named_metadata_operand(
    self.as_mod_ref(),
    name,
    metadata.as_value_ref(),
  )
  Ok(())
}

///| Obtains the number of `MetaDataValue`s indexed by a particular key.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip (some func not implemented)
/// let context = Context::create();
/// let llvm_module = context.create_module("my_module");
/// let bool_type = context.bool_type();
/// let f32_type = context.f32_type();
/// let bool_val = bool_type.const_int(0, sign_extend = false);
/// let f32_val = f32_type.const_float(0.0);
///
/// assert_eq(llvm_module.get_global_metadata_size("my_md"), 0);
///
/// let md_string = context.metadata_string("lots of metadata here");
/// let md_node = context.metadata_node([bool_val, f32_val.into()]);
///
/// llvm_module.add_global_metadata("my_md", md_string).unwrap();
/// llvm_module.add_global_metadata("my_md", md_node).unwrap();
///
/// assert_eq(llvm_module.get_global_metadata_size("my_md"), 2);
///
/// let global_md = llvm_module.get_global_metadata("my_md");
///
/// assert_eq(global_md.length(), 2);
///
/// let (md_0, md_1) = (global_md[0].get_node_values(), global_md[1].get_node_values());
///
/// assert_eq(md_0.length(), 1);
/// assert_eq(md_1.length(), 2);
/// assert_eq(md_0[0].into_metadata_value().get_string_value(), md_string.get_string_value());
/// assert_eq(md_1[0].into_int_value(), bool_val);
/// assert_eq(md_1[1].into_float_value(), f32_val);
/// ```
pub fn Module::get_global_metadata_size(self : Module, key : String) -> UInt {
  @unsafe.llvm_get_named_metadata_num_operands(self.as_mod_ref(), key)
}

///| Obtains the global `MetaDataValue` node indexed by key, which may contain 1 string or multiple values as its `get_node_values()`
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip
/// let context = Context::create();
/// let llvm_module = context.create_module("my_module");
/// let bool_type = context.bool_type();
/// let f32_type = context.f32_type();
/// let bool_val = bool_type.const_int(0, sign_extend=false);
/// let f32_val = f32_type.const_float(0.0);
///
/// assert_eq(llvm_module.get_global_metadata_size("my_md"), 0);
///
/// let md_string = context.metadata_string("lots of metadata here");
/// let md_node = context.metadata_node([bool_val.into(), f32_val.into()]);
///
/// llvm_module.add_global_metadata("my_md", &md_string).unwrap();
/// llvm_module.add_global_metadata("my_md", &md_node).unwrap();
///
/// assert_eq(llvm_module.get_global_metadata_size("my_md"), 2);
///
/// let global_md = llvm_module.get_global_metadata("my_md");
///
/// assert_eq(global_md.len(), 2);
///
/// let (md_0, md_1) = (global_md[0].get_node_values(), global_md[1].get_node_values());
///
/// assert_eq(md_0.len(), 1);
/// assert_eq(md_1.len(), 2);
/// assert_eq(md_0[0].into_metadata_value().get_string_value(), md_string.get_string_value());
/// assert_eq(md_1[0].into_int_value(), bool_val);
/// assert_eq(md_1[1].into_float_value(), f32_val);
/// ```
pub fn Module::get_global_metadata(
  self : Module,
  key : String
) -> Array[MetadataValue] {
  let metadata_ref = @unsafe.llvm_get_named_metadata_operands(
    self.as_mod_ref(),
    key,
  )
  metadata_ref.map(fn(r) { MetadataValue::new(r) })
}

///| Gets the first `GlobalValue` in a llvm_module.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip (llvm_module not implement op_equal)
/// let context = Context::create();
/// let i8_type = context.i8_type();
/// let llvm_module = context.create_module("mod");
///
/// assert_true(llvm_module.get_first_global() is None);
///
/// let global = llvm_module.add_global(i8_type, Some(AddressSpace(4)), "my_global");
///
/// assert_true(llvm_module.get_first_global().unwrap() == global);
/// ```
pub fn Module::get_first_global(self : Module) -> GlobalValue? {
  let val_ref = @unsafe.llvm_get_first_global(self.as_mod_ref())
  if val_ref.is_null() {
    None
  } else {
    Some(GlobalValue::new(val_ref))
  }
}

///| Gets the last `GlobalValue` in a llvm_module.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("mod");
/// let i8_type = context.i8_type();
///
/// assert_true(llvm_module.get_last_global() is None);
///
/// let global = llvm_module.add_global(i8_type, Some(AddressSpace::from(4)), "my_global");
///
/// assert_true(llvm_module.get_last_global().unwrap() == global);
/// ```
pub fn Module::get_last_global(self : Module) -> GlobalValue? {
  let val_ref = @unsafe.llvm_get_last_global(self.as_mod_ref())
  if val_ref.is_null() {
    None
  } else {
    Some(GlobalValue::new(val_ref))
  }
}

///| Gets a named `GlobalValue` in a llvm_module.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip (llvm_module not implement op_equal)
/// let context = Context::create();
/// let llvm_module = context.create_module("mod");
/// let i8_type = context.i8_type();
///
/// assert_true(llvm_module.get_global("my_global") is None);
///
/// let global = llvm_module.add_global(i8_type, Some(AddressSpace(4u16)), "my_global");
///
/// assert_true(llvm_module.get_global("my_global").unwrap() == global);
/// ```
pub fn Module::get_global(self : Module, name : String) -> GlobalValue? {
  let val_ref = @unsafe.llvm_get_named_global(self.as_mod_ref(), name)
  if val_ref.is_null() {
    None
  } else {
    Some(GlobalValue::new(val_ref))
  }
}

// pub fn Module::get_globals

// pub fn Module::parse_bitcode_from_buffer
// pub fn Module::parse_bitcode_from_path

///| Gets the name of this `llvm_module`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_module");
///
/// inspect(llvm_module.get_name(), content="my_module");
/// ```
pub fn Module::get_name(self : Module) -> String {
  @unsafe.llvm_get_module_identifier(self.module_ref)
}

///| Assigns the name of this `llvm_module`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_module");
///
/// llvm_module.set_name("my_module2");
///
/// inspect(llvm_module.get_name(), content="my_module2");
/// ```
pub fn Module::set_name(self : Module, name : String) -> Unit {
  @unsafe.llvm_set_module_identifier(self.module_ref, name)
}

///| Gets the source file name. It defaults to the llvm_module identifier but is separate from it.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_mod");
///
/// inspect(llvm_module.get_source_filename(), content="my_mod");
///
/// llvm_module.set_source_filename("my_mod.mbt");
///
/// inspect(llvm_module.get_name(), content="my_mod");
/// inspect(llvm_module.get_source_filename(), content="my_mod.mbt");
/// ```
pub fn Module::get_source_filename(self : Module) -> String {
  @unsafe.llvm_get_source_file_name(self.module_ref)
}

///| Sets the source file name. It defaults to the llvm_module identifier but is separate from it.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_mod");
///
/// inspect(llvm_module.get_source_filename(), content="my_mod");
///
/// llvm_module.set_source_filename("my_mod.mbt");
///
/// inspect(llvm_module.get_name(), content="my_mod");
/// inspect(llvm_module.get_source_filename(), content="my_mod.mbt");
/// ```
pub fn Module::set_source_filename(self : Module, name : String) -> Unit {
  @unsafe.llvm_set_source_file_name(self.module_ref, name)
}

// Links one llvm_module into another. This will merge two `Module`s into one.
//
// ## Example (Not Tested)
//
// ```moonbit skip skip
// let context = Context::create();
// let llvm_module = context.create_module("mod");
// let module2 = context.create_module("mod2");
//
// assert_true(llvm_module.link_in_module(module2).is_ok());
// ```
// pub fn Module::link_in_module(self: Module, other: Module) -> Result[Unit, String] {
//   let res = @unsafe.llvm_link_modules(self.as_mod_ref(), other.as_mod_ref())
//
//   if res {
//     Ok(())
//   } else {
//     Err("Failed to link modules")
//   }
// }

// pub fn Module::get_or_insert_comdat(self: Module, name: String) -> Comdat {
//   let comdat_ref = @unsafe.llvm_get_or_insert_comdat(self.as_mod_ref(), name)
//
//   Comdat::new(comdat_ref)
// }

// FIXME: This is not working
// pub fn Module::get_flag(self: Module, key: String) -> MetadataValue? {
//   let flag = @unsafe.llvm_get_module_flag(self.as_mod_ref(), key)
//
//   if flag.is_null() {
//     None
//   } else {
//     let flag_value = @unsafe.llvm_get_module_context(self.as_mod_ref(), flag)
//     let flag_value = @unsafe.llvm_metadata_as_value(flag_value)
//     Some(MetadataValue::new(flag))
//   }
// }

// pub fn Module::add_metadata_flag
// pub fn Module::add_basic_value_flag

// pub fn Module::strip_debug_info(self: Module) -> Bool {
//   @unsafe.llvm_strip_module_debug_info(self.module_ref)
// }

// pub fn Module::get_debug_metadata_version(self: Module) -> UInt {
//   @unsafe.llvm_get_module_debug_metadata_version(self.module_ref)
// }

///|
pub fn Module::drop(self : Module) -> Unit {
  @unsafe.llvm_dispose_module(self.module_ref)
}

///| Dumps the `llvm_module` to stderr.
///
/// It's equivalent to `Module::dump`.
pub fn Module::print_to_stderr(self : Module) -> Unit {
  @unsafe.llvm_dump_module(self.module_ref)
}

///| Dumps the `llvm_module` to string.
///
/// It's equivalent to `Module::to_string`.
pub fn Module::print_to_string(self : Module) -> String {
  @unsafe.llvm_print_module_to_string(self.module_ref)
}

///| Dumps the `llvm_module` to stderr.
///
/// It's equivalent to `Module::print_to_stderr`.
pub fn Module::dump(self : Module) -> Unit {
  @unsafe.llvm_dump_module(self.module_ref)
}

///|
pub impl Show for Module with output(self : Module, logger : &Logger) {
  let s = @unsafe.llvm_print_module_to_string(self.module_ref)
  logger.write_string(s)
}
