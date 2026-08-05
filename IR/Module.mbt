///|
pub struct Module {
  priv owner : ModuleOwner
}

///|
fn Module::from_raw(raw : @unsafe.LLVMModuleRef, context : Context) -> Module {
  Module::{ owner: ModuleOwner::new(raw, context.owner()) }
}

///|
#warnings("-unused_value")
fn Module::owner(self : Module) -> ModuleOwner {
  self.owner
}

///|
fn Module::inner(self : Module) -> @unsafe.LLVMModuleRef {
  self.owner.raw()
}

///|
pub fn Module::addFunction(
  self : Self,
  fty : FunctionType,
  name : String,
  linkage? : Linkage,
) -> Function raise StringError {
  let valueref = @unsafe.llvm_add_function(self.inner(), name, fty.0) catch {
    @unsafe.EmbeddedNul => raise ContainsNul
  }
  let fval = Function::Function(valueref)
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
  @unsafe.llvm_get_module_identifier(self.inner()) catch {
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
  @unsafe.llvm_set_module_identifier(self.inner(), name)
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
  @unsafe.llvm_get_source_file_name(self.inner()) catch {
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
  @unsafe.llvm_set_source_file_name(self.inner(), name)
}

///|
pub fn Module::setDefaultDataLayout(self : Module) -> Unit {
  let layout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
  @unsafe.llvm_set_data_layout(self.inner(), layout) catch {
    @unsafe.EmbeddedNul => ()
  }
}

///|
pub fn Module::setDataLayout(
  self : Module,
  layout : String,
) -> Unit raise StringError {
  @unsafe.llvm_set_data_layout(self.inner(), layout) catch {
    @unsafe.EmbeddedNul => raise ContainsNul
  }
}

///|
pub fn Module::getDataLayout(self : Module) -> DataLayout {
  let target_data_ref = @unsafe.llvm_get_module_data_layout(self.inner())
  DataLayout(target_data_ref)
}

///|
pub fn Module::addGlobalVariable(
  self : Self,
  ty : &Type,
  name : String,
  initializer? : &Constant,
  linkage? : Linkage,
) -> GlobalVariable raise StringError {
  let gv_ref = @unsafe.llvm_add_global(self.inner(), ty.getTypeRef(), name) catch {
    @unsafe.EmbeddedNul => raise ContainsNul
  }
  if initializer is Some(init) {
    @unsafe.llvm_set_initializer(gv_ref, init.getValueRef())
  }
  if linkage is Some(link) {
    @unsafe.llvm_set_linkage(gv_ref, link.to_llvm_linkage())
  }
  GlobalVariable(gv_ref)
}

///|
pub fn Module::addGlobalConstant(
  self : Self,
  ty : &Type,
  name : String,
  value : &Constant,
  linkage? : Linkage,
) -> GlobalConstant raise StringError {
  let gv_ref = @unsafe.llvm_add_global(self.inner(), ty.getTypeRef(), name) catch {
    @unsafe.EmbeddedNul => raise ContainsNul
  }
  @unsafe.llvm_set_global_constant(gv_ref, true)
  @unsafe.llvm_set_initializer(gv_ref, value.getValueRef())
  if linkage is Some(link) {
    @unsafe.llvm_set_linkage(gv_ref, link.to_llvm_linkage())
  }
  GlobalConstant(gv_ref)
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
  if 0 != @unsafe.llvm_write_bitcode_to_file(self.inner(), filename) {
    raise WriteBitCodeToFileFailed(filename)
  }
}

///|
pub fn Module::createInterpreter(self : Module) -> Interpreter raise {
  let (engref, err) = @unsafe.llvm_create_interpreter_for_module(self.inner())
  let engref = match engref {
    Some(e) => e
    None => raise CreateInterpreterFailed(err)
  }
  let ctx = self.getContext()
  Interpreter::construct(engref, self, ctx)
}

///|
pub fn Module::dump(self : Module) -> Unit {
  @unsafe.llvm_dump_module(self.inner())
}

///|
pub impl Show for Module with fn output(self, logger) {
  let s = @unsafe.llvm_print_module_to_string(self.inner()) catch {
    error => "<LLVM module text unavailable: \{error}>"
  }
  logger.write_string(s)
}
