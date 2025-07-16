///|
pub type Module @unsafe.LLVMModuleRef

///|
pub fn Module::addFunction(
  self : Self,
  fty : FunctionType,
  name : String
  //linkage~: Linkage
) -> Function {
  let valueref = @unsafe.llvm_add_function(self.inner(), name, fty.inner())
  let fval = Function::Function(valueref)
  //fval.setLinkage(linkage)
  fval
}

///|
pub fn Module::getContext(self : Self) -> Context {
  let ctxref = @unsafe.llvm_get_module_context(self.inner())
  Context(ctxref)
}

///|
pub fn Module::getFirstFunction(self : Self) -> Function? {
  let valueref = @unsafe.llvm_get_first_function(self.inner())
  unless(@unsafe.llvm_value_ref_is_null(valueref), () => Function(valueref))
}

///|
pub fn Module::getLastFunction(self : Self) -> Function? {
  let valueref = @unsafe.llvm_get_last_function(self.inner())
  unless(@unsafe.llvm_value_ref_is_null(valueref), () => Function(valueref))
}

///|
pub fn Module::getFunction(self : Self, name : String) -> Function? {
  let valueref = @unsafe.llvm_get_named_function(self.inner(), name)
  unless(@unsafe.llvm_value_ref_is_null(valueref), () => Function(valueref))
}

///|
pub fn Module::getFunctions(self : Self) -> Array[Function] {
  let funcs : Array[Function] = Array::new()
  let func = self.getFirstFunction()
  loop func {
    Some(f) => {
      funcs.push(f)
      continue f.getNextFunction()
    }
    None => break funcs
  }
}

///| Gets the name of this `llvm_module`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::new();
/// let program = context.addModule("my_module");
///
/// inspect(program.getName(), content="my_module");
/// ```
pub fn Module::getName(self : Self) -> String {
  @unsafe.llvm_get_module_identifier(self.inner())
}

///| Assigns the name of this `llvm_module`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::new();
/// let program = context.addModule("demo1");
///
/// program.setName("demo2");
///
/// inspect(program.getName(), content="demo2");
/// ```
pub fn Module::setName(self : Self, name : String) -> Unit {
  @unsafe.llvm_set_module_identifier(self.inner(), name)
}

///| Gets the source file name. It defaults to the llvm_module identifier but is separate from it.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::new();
/// let program = context.addModule("my_mod");
///
/// inspect(program.getSourceFileName(), content="my_mod");
///
/// program.setSourceFileName("my_mod.mbt");
///
/// inspect(program.getName(), content="my_mod");
/// inspect(program.getSourceFileName(), content="my_mod.mbt");
/// ```
pub fn Module::getSourceFileName(self : Self) -> String {
  @unsafe.llvm_get_source_file_name(self.inner())
}

///| Sets the source file name. It defaults to the llvm_module identifier but is separate from it.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::new();
/// let program = context.addModule("my_mod");
///
/// inspect(program.getSourceFileName(), content="my_mod");
///
/// program.setSourceFileName("my_mod.mbt");
///
/// inspect(program.getName(), content="my_mod");
/// inspect(program.getSourceFileName(), content="my_mod.mbt");
/// ```
pub fn Module::setSourceFileName(self : Module, name : String) -> Unit {
  @unsafe.llvm_set_source_file_name(self.inner(), name)
}

///|
pub fn Module::setDefaultDataLayout(self: Module) -> Unit {
  let layout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
  @unsafe.llvm_set_data_layout(self.inner(), layout)
}

///|
pub fn Module::setDataLayout(self : Module, layout : String) -> Unit {
  @unsafe.llvm_set_data_layout(self.inner(), layout)
}

///|
pub fn Module::getDataLayout(self : Module) -> DataLayout {
  let target_data_ref = @unsafe.llvm_get_module_data_layout(self.inner())
  DataLayout(target_data_ref)
}

///|
pub fn Module::dump(self : Module) -> Unit {
  @unsafe.llvm_dump_module(self.inner())
}

///|
pub impl Show for Module with output(self, logger) {
  let s = @unsafe.llvm_print_module_to_string(self.inner())
  logger.write_string(s)
}
