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
/// **Errors:** Raises `StringError::ContainsNul` for an embedded NUL in
/// `name`, `ValueOwnerError::ContextMismatch` for a foreign type or initializer,
/// `ValueOwnerError::ModuleMismatch` when the initializer depends on another
/// module, or `InValidTypeError` for an invalid storage type or mismatched
/// initializer type. Validation precedes insertion of the global.
///
/// **Lifecycle:** The returned global retains this Module. The module owns the
/// initialized storage; it does not retain MoonBit initializer wrappers, so
/// installing a constant anchored to this module does not create an owner cycle.
///
/// **Side Effects:** Inserts a module-owned global and applies the optional
/// initializer and linkage.
pub fn Module::addGlobalVariable(
  self : Self,
  ty : &Type,
  name : String,
  initializer? : &Constant,
  linkage? : Linkage,
) -> GlobalVariable raise {
  check_type_context(self.getContext(), ty)
  check_constant_element_type(ty)
  if initializer is Some(init) {
    merge_value_owners(self.getContext(), Some(self), [init]) |> ignore
    guard (init : &Value).getType().asTypeEnum() == ty.asTypeEnum() else {
      raise InValidTypeError(
        "Global initializer type does not match its storage type",
      )
    }
  }
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
/// Declares a constant global whose initializer can be installed later.
///
/// Use `GlobalConstant::setInitializer` after declaring all globals needed by
/// the initializer. This allows forward and cyclic references through addresses.
///
/// **Parameters:** `linkage` defaults to external linkage. An internal or private
/// declaration must receive an initializer before module verification or emission.
///
/// **Errors:** Raises `StringError::ContainsNul` for an embedded NUL in `name`,
/// `ValueOwnerError::ContextMismatch` for a foreign type, or `InValidTypeError`
/// for an invalid storage type. Validation precedes insertion of the global.
///
/// **Lifecycle:** The returned wrapper retains this module. Its address remains
/// valid when the initializer is installed or replaced; no manual release is
/// required. Erasing the global through the raw layer invalidates the wrapper.
///
/// **Side effects:** Inserts a module-owned global marked constant.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("deferred")
///   let left = mod.declareGlobalConstant(ctx.getPtrTy(), "left")
///   let right = mod.declareGlobalConstant(ctx.getPtrTy(), "right")
///   left.setInitializer(right)
///   right.setInitializer(left)
///   mod.verify()
///   inspect(left, content="@left = constant ptr @right")
/// }
/// ```
pub fn Module::declareGlobalConstant(
  self : Self,
  ty : &Type,
  name : String,
  linkage? : Linkage,
) -> GlobalConstant raise {
  check_type_context(self.getContext(), ty)
  check_constant_element_type(ty)
  let gv_ref = @raw.llvm_add_global(
    self.get_raw_ref(),
    ty.get_raw_type_ref(),
    name,
  ) catch {
    @raw.EmbeddedNul => raise ContainsNul
  }
  @raw.llvm_set_global_constant(gv_ref, true)
  if linkage is Some(link) {
    @raw.llvm_set_linkage(gv_ref, link.to_llvm_linkage())
  }
  GlobalConstant::from_raw(gv_ref, self)
}

///|
/// Adds a constant global definition initialized by `value`.
///
/// **Errors:** Raises `StringError::ContainsNul` for an embedded NUL in
/// `name`, `ValueOwnerError::ContextMismatch` for a foreign type or initializer,
/// `ValueOwnerError::ModuleMismatch` when the initializer depends on another
/// module, or `InValidTypeError` for an invalid storage type or mismatched
/// initializer type. Validation precedes insertion of the global.
///
/// **Lifecycle:** The returned global retains this Module. The module owns the
/// initialized storage; it does not retain MoonBit initializer wrappers, so
/// installing a constant anchored to this module does not create an owner cycle.
///
/// **Side Effects:** Inserts a module-owned global marked constant.
pub fn Module::addGlobalConstant(
  self : Self,
  ty : &Type,
  name : String,
  value : &Constant,
  linkage? : Linkage,
) -> GlobalConstant raise {
  check_type_context(self.getContext(), ty)
  check_constant_element_type(ty)
  merge_value_owners(self.getContext(), Some(self), [value]) |> ignore
  guard (value : &Value).getType().asTypeEnum() == ty.asTypeEnum() else {
    raise InValidTypeError(
      "Global initializer type does not match its storage type",
    )
  }
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

// =======================================================
// Module flags and debug information
// =======================================================

///|
/// How the linker merges two module flags with the same key
/// (`Module::ModFlagBehavior`).
pub(all) enum ModFlagBehavior {
  /// Emits an error if the two values differ.
  Error
  /// Emits a warning if the two values differ; the first module's value wins.
  ///
  /// LLVM uses this behavior for `"Debug Info Version"`.
  Warning
  /// Requires another flag to have a given value after linking; the value is a
  /// metadata pair of that flag's key and required value.
  Require
  /// Uses this value regardless of the other module's value; two differing
  /// overrides are an error.
  Override
  /// Appends the two values, which must be metadata nodes.
  Append
  /// Appends the two values, which must be metadata nodes, dropping
  /// duplicates.
  AppendUnique
  /// Takes the larger of two integer values.
  ///
  /// Clang uses this behavior for `"Dwarf Version"`.
  Max
  /// Takes the smaller of two integer values.
  Min
} derive(Eq, Debug)

///|
fn ModFlagBehavior::to_llvm(
  self : ModFlagBehavior,
) -> @raw.LLVMModuleFlagBehavior? {
  match self {
    Error => Some(LLVMModuleFlagBehaviorError)
    Warning => Some(LLVMModuleFlagBehaviorWarning)
    Require => Some(LLVMModuleFlagBehaviorRequire)
    Override => Some(LLVMModuleFlagBehaviorOverride)
    Append => Some(LLVMModuleFlagBehaviorAppend)
    AppendUnique => Some(LLVMModuleFlagBehaviorAppendUnique)
    Max | Min => None
  }
}

///|
/// Returns the `Module::ModFlagBehavior` numeric value stored in IR.
fn ModFlagBehavior::to_ir_value(self : ModFlagBehavior) -> UInt64 {
  match self {
    Error => 1
    Warning => 2
    Require => 3
    Override => 4
    Append => 5
    AppendUnique => 6
    Max => 7
    Min => 8
  }
}

///|
/// Appends a module flag to `!llvm.module.flags`.
///
/// **Parameters:**
///
/// - `behavior`: How linking merges this flag with the same key.
/// - `key`: The flag name, for example `"Debug Info Version"`.
/// - `value`: The flag value; `Max` and `Min` require an integer constant.
///
/// **Errors:** Raises `MetadataContextMismatch` when `value` belongs to
/// another context.
///
/// **Preconditions:** `key` must not already be present unless `behavior` is
/// `Require`; duplicate keys make the module fail verification.
///
/// **Side effects:** Adds an operand to the module's `!llvm.module.flags`.
///
/// **LLVM API:** `LLVMAddModuleFlag`. LLVM-C has no `Max`/`Min` behaviors, so
/// those flags are built as the same `!{i32 behavior, !"key", value}` node
/// that `llvm::Module::addModuleFlag` creates.
///
/// **See also:** `Module::addModuleFlagInt`.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let ctx = @IR.Context::new()
///   let mod = ctx.addModule("flags")
///   mod.addModuleFlag(Error, "runa.abi", ctx.getMDString("v1"))
///   guard mod.getModuleFlag("runa.abi") is Some(flag) else { fail("missing") }
///   inspect(flag, content="!\"v1\"")
///   mod.verify()
/// }
/// ```
pub fn Module::addModuleFlag(
  self : Module,
  behavior : ModFlagBehavior,
  key : String,
  value : Metadata,
) -> Unit raise DebugInfoError {
  let context = self.getContext()
  check_metadata_context(context, value.value.context)
  match behavior.to_llvm() {
    Some(llvm_behavior) =>
      @raw.llvm_add_module_flag(
        self.get_raw_ref(),
        llvm_behavior,
        key,
        value.value.md,
      )
    None => {
      let ctx_ref = context.get_raw_ref()
      let behavior_md = @raw.llvm_value_as_metadata(
        @raw.llvm_const_int(
          @raw.llvm_int32_type_in_context(ctx_ref),
          behavior.to_ir_value(),
          false,
        ),
      )
      let node = @raw.llvm_md_node_in_context2(ctx_ref, [
        behavior_md,
        @raw.llvm_md_string_in_context2(ctx_ref, key),
        value.value.md,
      ])
      // The named-metadata key is a constant without NUL bytes.
      @raw.llvm_add_named_metadata_operand(
        self.get_raw_ref(),
        "llvm.module.flags",
        @raw.llvm_metadata_as_value(ctx_ref, node),
      ) catch {
        _ => abort("llvm.module.flags is a valid metadata name")
      }
    }
  }
}

///|
/// Appends an integer-valued module flag stored as an `i32` constant.
///
/// This mirrors `llvm::Module::addModuleFlag(Behavior, Key, uint32_t)` and is
/// the usual way to record `"Debug Info Version"` and `"Dwarf Version"`.
///
/// **Preconditions:** `key` must not already be present unless `behavior` is
/// `Require`.
///
/// **Side effects:** Adds an operand to the module's `!llvm.module.flags`.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let mod = @IR.Context::new().addModule("flags")
///   mod.addModuleFlagInt(
///     Warning,
///     "Debug Info Version",
///     @IR.debugMetadataVersion(),
///   )
///   mod.addModuleFlagInt(Max, "Dwarf Version", 5)
///   guard mod.getModuleFlag("Dwarf Version") is Some(flag) else {
///     fail("missing")
///   }
///   inspect(flag, content="i32 5")
///   inspect(mod.getModuleFlag("missing") is None, content="true")
///   inspect(mod.getDebugMetadataVersion(), content="3")
/// }
/// ```
pub fn Module::addModuleFlagInt(
  self : Module,
  behavior : ModFlagBehavior,
  key : String,
  value : UInt,
) -> Unit {
  let context = self.getContext()
  let constant = @raw.llvm_const_int(
    @raw.llvm_int32_type_in_context(context.get_raw_ref()),
    value.to_uint64(),
    false,
  )
  let metadata = Metadata::from_raw(
    @raw.llvm_value_as_metadata(constant),
    context,
  )
  self.addModuleFlag(behavior, key, metadata) catch {
    _ => abort("module flag metadata was created in the module context")
  }
}

///|
/// Returns the value of the module flag named `key`, or `None` when absent.
///
/// **LLVM API:** `LLVMGetModuleFlag`.
pub fn Module::getModuleFlag(self : Module, key : String) -> Metadata? {
  let md = @raw.llvm_get_module_flag(self.get_raw_ref(), key)
  unless(md.is_null(), () => Metadata::from_raw(md, self.getContext()))
}

///|
/// Returns the module's `"Debug Info Version"` flag, or `0` when absent.
///
/// **LLVM API:** `LLVMGetModuleDebugMetadataVersion`.
pub fn Module::getDebugMetadataVersion(self : Module) -> UInt {
  @raw.llvm_get_module_debug_metadata_version(self.get_raw_ref())
}

///|
/// Removes all debug information from the module.
///
/// This drops debug-info intrinsics and records, debug-info named metadata
/// such as `!llvm.dbg.cu`, function subprograms, and instruction locations.
/// Module flags, including `"Debug Info Version"`, are kept.
///
/// **Returns:** `true` when the module was modified.
///
/// **Side effects:** Mutates the module. Existing `DIBuilder`s for the module
/// must not be used afterwards.
///
/// **LLVM API:** `LLVMStripModuleDebugInfo`.
pub fn Module::stripDebugInfo(self : Module) -> Bool {
  @raw.llvm_strip_module_debug_info(self.get_raw_ref())
}
