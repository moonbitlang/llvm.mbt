pub struct Module {
  module_ref : LLVMModuleRef
}

pub fn Module::new(module_ref: LLVMModuleRef) -> Module {
  Module::{
    module_ref: module_ref
  }
}

pub fn Module::as_mod_ref(self: Module) -> LLVMModuleRef {
  self.module_ref
}

pub fn Module::add_function(
  self: Module, 
  name: String, 
  function_ty: FunctionType, 
) -> FunctionValue {
  let val_ref = self.module_ref.add_function(name, function_ty.as_type_ref())
  guard let Some(fn_val) = FunctionValue::new(val_ref) else {
    None => abort("Failed to create FunctionValue, Something went wrong, loc: module.mbt: add_function")
  }

  fn_val
}

pub fn Module::get_context(self: Module) -> Context {
  let ctx_ref = llvm_get_module_context(self.as_mod_ref())

  Context::new(ctx_ref)
}

pub fn Module::get_first_function(self: Module) -> FunctionValue? {
  let val_ref = llvm_get_first_function(self.as_mod_ref())
  FunctionValue::new(val_ref)
}

pub fn Module::get_last_function(self: Module) -> FunctionValue? {
  let val_ref = llvm_get_last_function(self.as_mod_ref())
  FunctionValue::new(val_ref)
}

pub fn Module::get_function(self: Module, name: String) -> FunctionValue? {
  let val_ref = llvm_get_named_function(self.as_mod_ref(), name)

  FunctionValue::new(val_ref)
}

pub fn Module::get_functions(self: Module) -> Array[FunctionValue] {
  let funcs: Array[FunctionValue] = Array::new()
  let func = self.get_first_function()
  loop func {
    Some(f) => {
      funcs.push(f)
      continue f.get_next_function()
    }
    None => break funcs
  }
}

pub fn Module::get_struct_type(self: Module, name:String) -> StructType? {
  self.get_context().get_struct_type(name)
}

// pub fn Module::set_triple(self: Module, triple: TargetTriple) -> Unit {
//   llvm_set_target(self.as_mod_ref(), triple.as_string())
// }

// More about target triple, engine

pub fn Module::add_global(
  self: Module, ty: &BasicType, addr_space: AddressSpace?, name: String
) -> GlobalValue {
  let val = match addr_space {
    Some(addr_space) => {
      llvm_add_global_in_address_space(self.as_mod_ref(), ty.as_type_ref(), name, addr_space)
    }
    None => {
      llvm_add_global(self.as_mod_ref(), ty.as_type_ref(), name)
    }
  }

  GlobalValue::new(val)
}

// TODO: enable it when `llvm_write_bitcode_to_path` is available
// pub fn Module::write_bitecode_to_path(self: Module, path: String) -> Unit {
//   llvm_write_bitcode_to_path(self.as_mod_ref(), path)
// }

// pub fn Module::write_bitcode_to_file(self: Module, file: File, should_close: Bool, unbuffered: Bool) -> Unit {
//   llvm_write_bitcode_to_fd(self.as_mod_ref(), file.as_file_ref())
// }

// pub fn Module::write_bitcode_to_memory(self: Module) -> MemoryBuffer {
//   let mem_buf = llvm_write_bitcode_to_memory(self.as_mod_ref())
//   MemoryBuffer::new(mem_buf)
// }

// pub fn Module::verify(self: Module) -> Bool {
//
// }

// pub fn Module::get_data_layout
// pub fn Module::set_data_layout

pub fn Module::print_to_stderr(self: Module) -> Unit {
  llvm_dump_module(self.module_ref)
}

pub fn Module::print_to_string(self: Module) -> String {
  llvm_print_module_to_string(self.module_ref)
}

// pub fn Module::print_to_file(self: Module, file: File) -> Unit {
//   llvm_print_module_to_file(self.module_ref, file.as_file_ref())
// }

pub fn Module::set_inline_assembly(self: Module, asm: String) -> Unit {
  llvm_set_module_inline_asm(self.module_ref, asm)
}

pub fn Module::add_global_metadata(
  self: Module, name: String, metadata: MetadataValue
) -> Result[Unit, String] {
  // if not(metadata.is_node()) {
  //   return Err("MetadataValue is not a node".to_string())
  // }

  llvm_add_named_metadata_operand(self.as_mod_ref(), name, metadata.as_value_ref())

  Ok(())
}

pub fn Module::get_global_metadata_size(self: Module, key: String) -> UInt {
  llvm_get_named_metadata_num_operands(self.as_mod_ref(), key)
}

pub fn Module::get_global_metadata(self: Module, key: String) -> Array[MetadataValue] {
  let metadata_ref = llvm_get_named_metadata_operands(self.as_mod_ref(), key)

  metadata_ref.map(fn (r) { MetadataValue::new(r) })
}

pub fn Module::get_first_global(self: Module) -> GlobalValue? {
  let val_ref = llvm_get_first_global(self.as_mod_ref())

  if val_ref.is_null() {
    None
  } else {
    Some(GlobalValue::new(val_ref))
  }
}

pub fn Module::get_last_global(self: Module) -> GlobalValue? {
  let val_ref = llvm_get_last_global(self.as_mod_ref())

  if val_ref.is_null() {
    None
  } else {
    Some(GlobalValue::new(val_ref))
  }
}

pub fn Module::get_global(self: Module, name: String) -> GlobalValue? {
  let val_ref = llvm_get_named_global(self.as_mod_ref(), name)

  if val_ref.is_null() {
    None
  } else {
    Some(GlobalValue::new(val_ref))
  }
}

// pub fn Module::get_globals

// pub fn Module::parse_bitcode_from_buffer
// pub fn Module::parse_bitcode_from_path

pub fn Module::get_name(self: Module) -> String {
  llvm_get_module_identifier(self.module_ref)
}

pub fn Module::set_name(self: Module, name: String) -> Unit {
  llvm_set_module_identifier(self.module_ref, name)
}

pub fn Module::get_source_filename(self: Module) -> String {
  llvm_get_source_file_name(self.module_ref)
}

pub fn Module::set_source_filename(self: Module, name: String) -> Unit {
  llvm_set_source_file_name(self.module_ref, name)
}

// pub fn Module::link_in_module(self: Module, other: Module) -> Result[Unit, String] {
//   let res = llvm_link_modules(self.as_mod_ref(), other.as_mod_ref())
//
//   if res {
//     Ok(())
//   } else {
//     Err("Failed to link modules")
//   }
// }

// pub fn Module::get_or_insert_comdat(self: Module, name: String) -> Comdat {
//   let comdat_ref = llvm_get_or_insert_comdat(self.as_mod_ref(), name)
//
//   Comdat::new(comdat_ref)
// }

// FIXME: This is not working
// pub fn Module::get_flag(self: Module, key: String) -> MetadataValue? {
//   let flag = llvm_get_module_flag(self.as_mod_ref(), key)
//
//   if flag.is_null() {
//     None
//   } else {
//     let flag_value = llvm_get_module_context(self.as_mod_ref(), flag)
//     let flag_value = llvm_metadata_as_value(flag_value)
//     Some(MetadataValue::new(flag))
//   }
// }

// pub fn Module::add_metadata_flag
// pub fn Module::add_basic_value_flag

// pub fn Module::strip_debug_info(self: Module) -> Bool {
//   llvm_strip_module_debug_info(self.module_ref)
// }

// pub fn Module::get_debug_metadata_version(self: Module) -> UInt {
//   llvm_get_module_debug_metadata_version(self.module_ref)
// }

pub fn Module::to_string(self: Module) -> String {
  llvm_print_module_to_string(self.module_ref)
}

pub impl Show for Module with output(self: Module, logger: &Logger) {
  logger.write_string(self.to_string())
}

pub fn Module::dump(self: Module) -> Unit {
  llvm_dump_module(self.module_ref)
}
