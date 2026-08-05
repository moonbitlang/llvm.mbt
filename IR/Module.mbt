///|
pub struct Module {
  priv owner : ModuleOwner
}

///|
fn Module::from_raw(raw : @unsafe.LLVMModuleRef, context : Context) -> Module {
  Module::{ owner: ModuleOwner::new(raw, context.get_owner()) }
}

///|
#warnings("-unused_value")
fn Module::get_owner(self : Module) -> ModuleOwner {
  self.owner
}

///|
fn Module::get_unsafe_ref(self : Module) -> @unsafe.LLVMModuleRef {
  self.owner.raw()
}

///|
pub fn Module::addFunction(
  self : Self,
  fty : FunctionType,
  name : String,
  linkage? : Linkage,
) -> Function raise StringError {
  let valueref = @unsafe.llvm_add_function(
    self.get_unsafe_ref(),
    name,
    fty.getTypeRef(),
  ) catch {
    @unsafe.EmbeddedNul => raise ContainsNul
  }
  let fval = Function::from_raw(valueref, self)
  match linkage {
    Some(l) => @unsafe.llvm_set_linkage(valueref, l.to_llvm_linkage())
    None => ()
  }
  fval
}

///|
pub fn Module::getContext(self : Self) -> Context {
  Context::from_owner(self.owner.context())
}

///|
pub fn Module::getFirstFunction(self : Self) -> Function? {
  let valueref = @unsafe.llvm_get_first_function(self.get_unsafe_ref())
  unless(@unsafe.llvm_value_ref_is_null(valueref), () => {
    Function::from_raw(valueref, self)
  })
}

///|
pub fn Module::getLastFunction(self : Self) -> Function? {
  let valueref = @unsafe.llvm_get_last_function(self.get_unsafe_ref())
  unless(@unsafe.llvm_value_ref_is_null(valueref), () => {
    Function::from_raw(valueref, self)
  })
}

///|
pub fn Module::getFunction(self : Self, name : String) -> Function? {
  let valueref = @unsafe.llvm_get_named_function(self.get_unsafe_ref(), name)
  unless(@unsafe.llvm_value_ref_is_null(valueref), () => {
    Function::from_raw(valueref, self)
  })
}

///|
pub fn Module::getFunctions(self : Self) -> Array[Function] {
  let funcs : Array[Function] = Array::new()
  for func = self.getFirstFunction() {
    match func {
      Some(f) => {
        funcs.push(f)
        continue f.getNextFunction()
      }
      None => break funcs
    }
  }
}

///|
/// Gets the name of this `llvm_module`.
///
/// ## Example
///
/// ```mbt check
/// test {
///   let context = Context::new()
///   let program = context.addModule("my_module")
///
///   inspect(program.getName(), content="my_module")
/// }
/// ```
pub fn Module::getName(self : Self) -> String raise StringError {
  @unsafe.llvm_get_module_identifier(self.get_unsafe_ref()) catch {
    @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
  }
}

///|
/// Assigns the name of this `llvm_module`.
///
/// ## Example (Not Tested)
///
/// ```mbt check
/// test {
///   let context = Context::new()
///   let program = context.addModule("demo1")
///
///   program.setName("demo2")
///
///   inspect(program.getName(), content="demo2")
/// }
/// ```
pub fn Module::setName(self : Self, name : String) -> Unit {
  @unsafe.llvm_set_module_identifier(self.get_unsafe_ref(), name)
}

///|
/// Gets the source file name. It defaults to the llvm_module identifier but is separate from it.
///
/// ## Example
///
/// ```mbt check
/// test {
///   let context = Context::new()
///   let program = context.addModule("my_mod")
///
///   inspect(program.getSourceFileName(), content="my_mod")
///
///   program.setSourceFileName("my_mod.mbt")
///
///   inspect(program.getName(), content="my_mod")
///   inspect(program.getSourceFileName(), content="my_mod.mbt")
/// }
/// ```
pub fn Module::getSourceFileName(self : Self) -> String raise StringError {
  @unsafe.llvm_get_source_file_name(self.get_unsafe_ref()) catch {
    @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
  }
}

///|
/// Sets the source file name. It defaults to the llvm_module identifier but is separate from it.
///
/// ## Example
///
/// ```mbt check
/// test {
///   let context = Context::new()
///   let program = context.addModule("my_mod")
///
///   inspect(program.getSourceFileName(), content="my_mod")
///
///   program.setSourceFileName("my_mod.mbt")
///
///   inspect(program.getName(), content="my_mod")
///   inspect(program.getSourceFileName(), content="my_mod.mbt")
/// }
/// ```
pub fn Module::setSourceFileName(self : Module, name : String) -> Unit {
  @unsafe.llvm_set_source_file_name(self.get_unsafe_ref(), name)
}

///|
pub fn Module::setDefaultDataLayout(self : Module) -> Unit {
  let layout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
  @unsafe.llvm_set_data_layout(self.get_unsafe_ref(), layout) catch {
    @unsafe.EmbeddedNul => ()
  }
}

///|
pub fn Module::setDataLayout(
  self : Module,
  layout : String,
) -> Unit raise StringError {
  @unsafe.llvm_set_data_layout(self.get_unsafe_ref(), layout) catch {
    @unsafe.EmbeddedNul => raise ContainsNul
  }
}

///|
pub fn Module::getDataLayout(self : Module) -> DataLayout {
  let target_data_ref = @unsafe.llvm_get_module_data_layout(
    self.get_unsafe_ref(),
  )
  DataLayout::from_raw(target_data_ref, self)
}

///|
pub fn Module::addGlobalVariable(
  self : Self,
  ty : &Type,
  name : String,
  initializer? : &Constant,
  linkage? : Linkage,
) -> GlobalVariable raise StringError {
  let gv_ref = @unsafe.llvm_add_global(
    self.get_unsafe_ref(),
    ty.getTypeRef(),
    name,
  ) catch {
    @unsafe.EmbeddedNul => raise ContainsNul
  }
  if initializer is Some(init) {
    @unsafe.llvm_set_initializer(gv_ref, init.getValueRef())
  }
  if linkage is Some(link) {
    @unsafe.llvm_set_linkage(gv_ref, link.to_llvm_linkage())
  }
  GlobalVariable::from_raw(gv_ref, self)
}

///|
pub fn Module::addGlobalConstant(
  self : Self,
  ty : &Type,
  name : String,
  value : &Constant,
  linkage? : Linkage,
) -> GlobalConstant raise StringError {
  let gv_ref = @unsafe.llvm_add_global(
    self.get_unsafe_ref(),
    ty.getTypeRef(),
    name,
  ) catch {
    @unsafe.EmbeddedNul => raise ContainsNul
  }
  @unsafe.llvm_set_global_constant(gv_ref, true)
  @unsafe.llvm_set_initializer(gv_ref, value.getValueRef())
  if linkage is Some(link) {
    @unsafe.llvm_set_linkage(gv_ref, link.to_llvm_linkage())
  }
  GlobalConstant::from_raw(gv_ref, self)
}

///|
pub suberror WriteBitCodeToFileFailed {
  WriteBitCodeToFileFailed(String)
}

///|
pub fn Module::writeBitCodeToFile(
  self : Module,
  filename : String,
) -> Unit raise {
  if 0 != @unsafe.llvm_write_bitcode_to_file(self.get_unsafe_ref(), filename) {
    raise WriteBitCodeToFileFailed(filename)
  }
}

///|
pub fn Module::dump(self : Module) -> Unit {
  @unsafe.llvm_dump_module(self.get_unsafe_ref())
}

///|
pub impl Show for Module with fn output(self, logger) {
  let s = @unsafe.llvm_print_module_to_string(self.get_unsafe_ref()) catch {
    error => "<LLVM module text unavailable: \{error}>"
  }
  logger.write_string(s)
}
