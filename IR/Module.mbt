///|
/// Managed owner of an LLVM module and its module-level IR objects.
///
/// Functions, globals, arguments, basic blocks, and instructions returned from
/// a module retain the same underlying module owner. Types and ordinary
/// constants remain owned by the module's `Context` instead.
///
/// **Lifecycle:** The native module is disposed when the last `Module` or
/// module-anchored wrapper is released. Do not independently dispose raw LLVM
/// handles obtained from these objects.
pub struct Module {
  priv owner : ModuleOwner
}

///|
fn Module::from_raw(raw : @raw.LLVMModuleRef, context : Context) -> Module {
  Module::{ owner: ModuleOwner::new(raw, context.get_owner()), }
}

///|
fn Module::get_owner(self : Module) -> ModuleOwner {
  self.owner
}

///|
fn Module::get_raw_ref(self : Module) -> @raw.LLVMModuleRef {
  self.owner.raw()
}

///|
/// Adds a function declaration with the given signature and name.
///
/// **Preconditions:** `fty` must belong to this module's context.
///
/// **Errors:** Raises `StringError::ContainsNul` when `name` contains an
/// embedded NUL byte.
///
/// **Side Effects:** Inserts a module-owned function and optionally sets its
/// linkage.
pub fn Module::addFunction(
  self : Self,
  fty : FunctionType,
  name : String,
  linkage? : Linkage,
) -> Function raise StringError {
  let valueref = @raw.llvm_add_function(
    self.get_raw_ref(),
    name,
    fty.get_raw_type_ref(),
  ) catch {
    @raw.EmbeddedNul => raise ContainsNul
  }
  let fval = Function::from_raw(valueref, self)
  match linkage {
    Some(l) => @raw.llvm_set_linkage(valueref, l.to_llvm_linkage())
    None => ()
  }
  fval
}

///|
/// Returns the context retained by this module.
pub fn Module::getContext(self : Self) -> Context {
  Context::from_owner(self.owner.context())
}

///|
/// Returns the first function in module order, or `None` when there are none.
pub fn Module::getFirstFunction(self : Self) -> Function? {
  let valueref = @raw.llvm_get_first_function(self.get_raw_ref())
  unless(@raw.llvm_value_ref_is_null(valueref), () => {
    Function::from_raw(valueref, self)
  })
}

///|
/// Returns the last function in module order, or `None` when there are none.
pub fn Module::getLastFunction(self : Self) -> Function? {
  let valueref = @raw.llvm_get_last_function(self.get_raw_ref())
  unless(@raw.llvm_value_ref_is_null(valueref), () => {
    Function::from_raw(valueref, self)
  })
}

///|
/// Finds a function by name, returning `None` when it is absent or the name
/// cannot be passed to LLVM.
pub fn Module::getFunction(self : Self, name : String) -> Function? {
  let valueref = @raw.llvm_get_named_function(self.get_raw_ref(), name)
  unless(@raw.llvm_value_ref_is_null(valueref), () => {
    Function::from_raw(valueref, self)
  })
}

///|
/// Returns all functions in their current module order.
pub fn Module::getFunctions(self : Self) -> Array[Function] {
  let funcs : Array[Function] = []
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
/// Returns the module identifier.
///
/// **Errors:** Raises `StringError::MalformedUtf8` if LLVM returns invalid
/// UTF-8.
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
  @raw.llvm_get_module_identifier(self.get_raw_ref()) catch {
    @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
  }
}

///|
/// Sets the module identifier.
///
/// **Side Effects:** Changes the identifier printed in LLVM IR; it does not
/// change the independent source filename.
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
  @raw.llvm_set_module_identifier(self.get_raw_ref(), name)
}

///|
/// Returns the source filename recorded in the module.
///
/// It initially defaults to the module identifier but is stored independently.
/// Raises `StringError::MalformedUtf8` if LLVM returns invalid UTF-8.
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
  @raw.llvm_get_source_file_name(self.get_raw_ref()) catch {
    @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
  }
}

///|
/// Sets the source filename independently of the module identifier.
///
/// **Side Effects:** Changes source metadata printed in the module.
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
  @raw.llvm_set_source_file_name(self.get_raw_ref(), name)
}

///|
/// Sets the module's target data-layout string.
///
/// **Errors:** Raises `StringError::ContainsNul` for an embedded NUL byte.
///
/// **Side Effects:** Replaces the layout used by later ABI size/alignment
/// queries and code generation. The caller is responsible for supplying a
/// layout compatible with the intended target.
pub fn Module::setDataLayout(
  self : Module,
  layout : String,
) -> Unit raise StringError {
  @raw.llvm_set_data_layout(self.get_raw_ref(), layout) catch {
    @raw.EmbeddedNul => raise ContainsNul
  }
}

///|
/// Returns the module's target data-layout string.
///
/// **Errors:** Raises `StringError::MalformedUtf8` if LLVM returns invalid
/// UTF-8.
pub fn Module::getDataLayoutStr(self : Module) -> String raise StringError {
  @raw.llvm_get_data_layout_str(self.get_raw_ref()) catch {
    @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
  }
}

///|
/// Returns a borrowed view of the module's current data layout.
///
/// **Lifecycle:** The view retains this module and must not be treated as an
/// independently owned `LLVMTargetDataRef`.
pub fn Module::getDataLayout(self : Module) -> DataLayout {
  let target_data_ref = @raw.llvm_get_module_data_layout(self.get_raw_ref())
  DataLayout::from_raw(target_data_ref, self)
}

///|
/// Returns the target triple currently recorded on the module.
///
/// **Errors:** Raises `StringError::MalformedUtf8` if LLVM returns invalid
/// UTF-8.
///
/// **Notes:** A newly created module may have an empty triple. Configure it for
/// the intended target before target-dependent verification or emission.
pub fn Module::getTargetTriple(self : Module) -> String raise StringError {
  @raw.llvm_get_target(self.get_raw_ref()) catch {
    @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
  }
}

///|
/// LLVM verifier rejected a module and returned this diagnostic.
pub suberror VerificationError {
  /// Contains LLVM's verifier diagnostic.
  VerificationError(String)
}

///|
/// Verifies this module without printing diagnostics or aborting the process.
///
/// **Errors:** Raises `VerificationError` with LLVM's diagnostic when the IR is
/// invalid.
///
/// **Notes:** Target-dependent workflows should configure the module's target
/// triple and data layout before verification.
pub fn Module::verify(self : Module) -> Unit raise VerificationError {
  let (failed, message) = @raw.llvm_verify_module(self.get_raw_ref())
  guard !failed else { raise VerificationError(message) }
}

///|
/// Adds a mutable global variable.
///
/// **Preconditions:** `ty` and any `initializer` must belong to this module's
/// context, and the initializer must have type `ty`.
///
/// **Errors:** Raises `StringError::ContainsNul` for an embedded NUL in `name`.
///
/// **Side Effects:** Inserts a module-owned global and applies the optional
/// initializer and linkage.
pub fn Module::addGlobalVariable(
  self : Self,
  ty : &Type,
  name : String,
  initializer? : &Constant,
  linkage? : Linkage,
) -> GlobalVariable raise StringError {
  let gv_ref = @raw.llvm_add_global(
    self.get_raw_ref(),
    ty.get_raw_type_ref(),
    name,
  ) catch {
    @raw.EmbeddedNul => raise ContainsNul
  }
  if initializer is Some(init) {
    @raw.llvm_set_initializer(gv_ref, (init : &Value).get_raw_value_ref())
  }
  if linkage is Some(link) {
    @raw.llvm_set_linkage(gv_ref, link.to_llvm_linkage())
  }
  GlobalVariable::from_raw(gv_ref, self)
}

///|
/// Adds a constant global definition initialized by `value`.
///
/// **Preconditions:** `ty` and `value` must belong to this module's context, and
/// `value` must have type `ty`.
///
/// **Errors:** Raises `StringError::ContainsNul` for an embedded NUL in `name`.
///
/// **Side Effects:** Inserts a module-owned global marked constant.
pub fn Module::addGlobalConstant(
  self : Self,
  ty : &Type,
  name : String,
  value : &Constant,
  linkage? : Linkage,
) -> GlobalConstant raise StringError {
  let gv_ref = @raw.llvm_add_global(
    self.get_raw_ref(),
    ty.get_raw_type_ref(),
    name,
  ) catch {
    @raw.EmbeddedNul => raise ContainsNul
  }
  @raw.llvm_set_global_constant(gv_ref, true)
  @raw.llvm_set_initializer(gv_ref, (value : &Value).get_raw_value_ref())
  if linkage is Some(link) {
    @raw.llvm_set_linkage(gv_ref, link.to_llvm_linkage())
  }
  GlobalConstant::from_raw(gv_ref, self)
}

///|
/// Error raised when LLVM cannot write a module as bitcode.
pub suberror WriteBitCodeToFileFailed {
  /// Contains the requested output filename.
  WriteBitCodeToFileFailed(String)
}

///|
/// Serializes this module as LLVM bitcode at `filename`.
///
/// **Errors:** Raises `WriteBitCodeToFileFailed` when LLVM reports a write
/// failure.
///
/// **Side Effects:** Creates or overwrites the requested file. This emits LLVM
/// bitcode, not a native object file.
pub fn Module::writeBitCodeToFile(
  self : Module,
  filename : String,
) -> Unit raise {
  if 0 != @raw.llvm_write_bitcode_to_file(self.get_raw_ref(), filename) {
    raise WriteBitCodeToFileFailed(filename)
  }
}

///|
/// Serializes this module as an independent in-memory bitcode snapshot.
///
/// **Returns:** A new byte array containing the complete binary bitcode. The
/// result does not borrow this module or any native memory buffer.
///
/// **Lifecycle:** The returned bytes remain valid after this module and its
/// context are released.
///
/// **Side effects:** This does not mutate the module, its target configuration,
/// or any derived IR object.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let context = Context::new()
///   let mod = context.addModule("snapshot")
///   let bitcode = mod.writeBitCodeToBytes()
///   inspect(bitcode.length() > 0, content="true")
///   inspect(mod.getName(), content="snapshot")
/// }
/// ```
pub fn Module::writeBitCodeToBytes(self : Module) -> Bytes {
  @raw.llvm_write_bitcode_to_bytes(self.get_raw_ref())
}

///|
/// Prints the module through LLVM's diagnostic dump facility.
///
/// **Side Effects:** Writes to LLVM's diagnostic stream, normally standard
/// error. Use `Show` when the text should be captured instead.
pub fn Module::dump(self : Module) -> Unit {
  @raw.llvm_dump_module(self.get_raw_ref())
}

///|
/// Writes the complete LLVM textual IR for this module.
///
/// If LLVM cannot produce text, a diagnostic placeholder is written instead.
pub impl Show for Module with fn output(self, logger) {
  let s = @raw.llvm_print_module_to_string(self.get_raw_ref()) catch {
    error => "<LLVM module text unavailable: \{error}>"
  }
  logger.write_string(s)
}
