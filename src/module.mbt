pub struct Module {
  module_ref : LLVMModuleRef
}

pub fn Module::new(module_ref: LLVMModuleRef) -> Module {
  Module::{
    module_ref: module_ref
  }
}

pub fn add_function(
  self: Module, 
  name: String, 
  function_ty: FunctionType, 
) -> FunctionValue {
  let cname = moonbit_str_to_c_str(name)
  let val_ref = llvm_add_function(self.module_ref, cname, function_ty.as_type_ref())
  guard let Some(fn_val) = FunctionValue::new(val_ref) else {
    None => abort("Failed to create FunctionValue, Something went wrong, loc: module.mbt: add_function")
  }

  fn_val
}

pub fn Module::to_string(self: Module) -> String {
  llvm_print_module_to_string(self.module_ref)
}

pub fn Module::dump(self: Module) -> Unit {
  llvm_dump_module(self.module_ref)
}
