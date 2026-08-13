///|
/// A target triple used for target lookup and code generation.
///
/// The string is not normalized or validated against the registry until lookup.
pub struct TargetTriple {
  priv value : String
} derive(Eq, Debug)

///|
/// Creates a target triple from an explicit LLVM triple string.
///
/// **Errors:** Raises `StringError::ContainsNul` for an embedded NUL byte.
pub fn TargetTriple::new(value : String) -> TargetTriple raise StringError {
  guard !value.contains_code_unit(0) else { raise ContainsNul }
  TargetTriple::{ value, }
}

///|
/// Returns LLVM's default triple for the current host process.
///
/// **Errors:** Raises `StringError::MalformedUtf8` if LLVM returns invalid
/// UTF-8.
pub fn TargetTriple::host() -> TargetTriple raise StringError {
  let value = @raw.llvm_get_default_target_triple() catch {
    @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
  }
  TargetTriple::{ value, }
}

///|
/// Returns the stored LLVM triple string without normalization.
pub fn TargetTriple::toString(self : TargetTriple) -> String {
  self.value
}

///|
/// Writes the stored target triple.
pub impl Show for TargetTriple with fn output(self, logger) {
  logger.write_string(self.value)
}

///|
/// Failure while initializing or querying LLVM's process-global registry.
pub suberror TargetRegistryError {
  /// LLVM could not initialize the backend for the current host target.
  NativeTargetUnavailable
  /// LLVM could not initialize the current host's assembly printer.
  NativeAsmPrinterUnavailable
  /// No initialized target matched the triple; contains LLVM's diagnostic.
  TargetNotFound(String)
}

///|
/// Namespace for LLVM's process-global target registry.
///
/// The registry is not a disposable object. Initialization mutates process-wide
/// LLVM state and affects later target lookup from all threads.
pub type TargetRegistry

///|
/// Idempotently initializes host target code generation and its assembly
/// printer.
///
/// **Errors:** Raises `NativeTargetUnavailable` or
/// `NativeAsmPrinterUnavailable` when LLVM reports an initialization failure.
///
/// **Side Effects:** Mutates LLVM's process-global registry. Repeated successful
/// calls, including calls made by `TargetMachine::host`, are supported.
///
/// **Thread Safety:** LLVM owns the global registry synchronization and
/// lifetime. Call this during process setup when deterministic initialization
/// order matters.
///
/// **Notes:** This initializes only the native backend required for object
/// emission, not every cross-target backend, assembly parser, or disassembler.
pub fn TargetRegistry::initializeNativeCodegen() -> Unit raise TargetRegistryError {
  guard !@raw.llvm_initialize_native_target() else {
    raise NativeTargetUnavailable
  }
  guard !@raw.llvm_initialize_native_asm_printer() else {
    raise NativeAsmPrinterUnavailable
  }
}

///|
/// Looks up a registry-owned target. The returned descriptor is borrowed for
/// the process lifetime and has no disposer.
///
/// **Preconditions:** A backend supporting `triple` must already be initialized.
/// `initializeNativeCodegen` establishes this only for the host backend.
///
/// **Errors:** Raises `TargetNotFound` with LLVM's diagnostic when lookup fails.
pub fn TargetRegistry::lookupTarget(
  triple : TargetTriple,
) -> Target raise TargetRegistryError {
  let (raw, message, failed) = @raw.llvm_get_target_from_triple(
    triple.toString(),
  )
  guard !failed && !raw.is_null() else { raise TargetNotFound(message) }
  Target::{ raw, }
}

///|
/// A borrowed target descriptor owned by LLVM's global target registry.
///
/// **Lifecycle:** The descriptor remains valid for the process lifetime and has
/// no disposer. A `TargetMachine` created from it has independent managed
/// ownership.
pub struct Target {
  priv raw : @raw.LLVMTargetRef
}

///|
/// Returns the target backend's short registry name.
///
/// **Errors:** Raises `StringError::MalformedUtf8` for invalid UTF-8.
pub fn Target::getName(self : Target) -> String raise StringError {
  @raw.llvm_get_target_name(self.raw) catch {
    @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
  }
}

///|
/// Returns the target backend's human-readable description.
///
/// **Errors:** Raises `StringError::MalformedUtf8` for invalid UTF-8.
pub fn Target::getDescription(self : Target) -> String raise StringError {
  @raw.llvm_get_target_description(self.raw) catch {
    @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
  }
}

///|
/// LLVM code-generation optimization level.
///
/// This controls backend optimization during instruction selection and machine
/// code generation; it is separate from IR optimization passes.
pub(all) enum CodeGenOptimizationLevel {
  /// Disable optional code-generation optimization.
  None
  /// Request a reduced optimization level favoring compile time.
  Less
  /// Use LLVM's normal code-generation optimization level.
  Default
  /// Request the most aggressive code-generation optimization level.
  Aggressive
}

///|
fn CodeGenOptimizationLevel::to_raw(
  self : CodeGenOptimizationLevel,
) -> @raw.LLVMCodeGenOptLevel {
  match self {
    None => LLVMCodeGenLevelNone
    Less => LLVMCodeGenLevelLess
    Default => LLVMCodeGenLevelDefault
    Aggressive => LLVMCodeGenLevelAggressive
  }
}

///|
/// Relocation strategy used when emitting machine code.
///
/// Availability and exact ABI consequences depend on the selected target.
pub(all) enum RelocationMode {
  /// Let LLVM choose the target's default relocation model.
  Default
  /// Emit code assuming fixed load addresses rather than PIC relocation.
  Static
  /// Emit position-independent code suitable for shared objects where supported.
  Pic
  /// Use the target's dynamic-no-PIC model where available.
  DynamicNoPic
  /// Use read-only position independence where supported, primarily embedded
  /// targets.
  Ropi
  /// Use read-write position independence where supported.
  Rwpi
  /// Combine read-only and read-write position independence.
  RopiRwpi
}

///|
fn RelocationMode::to_raw(self : RelocationMode) -> @raw.LLVMRelocMode {
  match self {
    Default => LLVMRelocDefault
    Static => LLVMRelocStatic
    Pic => LLVMRelocPIC
    DynamicNoPic => LLVMRelocDynamicNoPic
    Ropi => LLVMRelocROPI
    Rwpi => LLVMRelocRWPI
    RopiRwpi => LLVMRelocROPI_RWPI
  }
}

///|
/// Target code model controlling address-size and placement assumptions.
///
/// Support and precise ranges are target-specific.
pub(all) enum CodeModel {
  /// Let LLVM choose the target's default code model.
  Default
  /// Use LLVM's default model intended for JIT-generated code.
  JitDefault
  /// Assume code and data fit the target's tiny model.
  Tiny
  /// Assume code and data fit the target's small model.
  Small
  /// Use kernel-oriented placement assumptions where supported.
  Kernel
  /// Permit a larger data-address range while retaining medium-model assumptions.
  Medium
  /// Use the least restrictive large-address model where supported.
  Large
}

///|
fn CodeModel::to_raw(self : CodeModel) -> @raw.LLVMCodeModel {
  match self {
    Default => LLVMCodeModelDefault
    JitDefault => LLVMCodeModelJITDefault
    Tiny => LLVMCodeModelTiny
    Small => LLVMCodeModelSmall
    Kernel => LLVMCodeModelKernel
    Medium => LLVMCodeModelMedium
    Large => LLVMCodeModelLarge
  }
}

///|
/// Pure MoonBit configuration for constructing a target machine.
///
/// It owns no LLVM-C options handle. Raw options are created temporarily during
/// target-machine construction and disposed before the constructor returns.
pub struct TargetMachineOptions {
  priv cpu : String?
  priv features : String?
  priv abi : String?
  priv optimizationLevel : CodeGenOptimizationLevel
  priv relocationMode : RelocationMode
  priv codeModel : CodeModel
}

///|
/// Creates target-machine configuration.
///
/// **Parameters:**
///
/// - `cpu`: Explicit LLVM CPU name. The generic constructor defaults to
///   `"generic"`; `TargetMachine::host` defaults to the host CPU.
/// - `features`: LLVM feature string. The generic constructor defaults to empty;
///   the host convenience defaults to detected host features.
/// - `abi`: Optional target ABI name.
/// - `optimizationLevel`: Backend code-generation optimization level.
/// - `relocationMode`: Target relocation strategy.
/// - `codeModel`: Target address/code model.
///
/// **Errors:** Raises `StringError::ContainsNul` if a supplied string contains an
/// embedded NUL byte.
pub fn TargetMachineOptions::new(
  cpu? : String,
  features? : String,
  abi? : String,
  optimizationLevel? : CodeGenOptimizationLevel = Default,
  relocationMode? : RelocationMode = Default,
  codeModel? : CodeModel = Default,
) -> TargetMachineOptions raise StringError {
  match cpu {
    Some(value) if value.contains_code_unit(0) => raise ContainsNul
    _ => ()
  }
  match features {
    Some(value) if value.contains_code_unit(0) => raise ContainsNul
    _ => ()
  }
  match abi {
    Some(value) if value.contains_code_unit(0) => raise ContainsNul
    _ => ()
  }
  { cpu, features, abi, optimizationLevel, relocationMode, codeModel }
}

///|
/// Returns generic target defaults: generic CPU, empty features, no explicit
/// ABI, and LLVM's default codegen/relocation/code-model settings.
pub impl Default for TargetMachineOptions with fn default() {
  TargetMachineOptions::{
    cpu: None,
    features: None,
    abi: None,
    optimizationLevel: Default,
    relocationMode: Default,
    codeModel: Default,
  }
}

///|
/// Failure while constructing an LLVM target machine.
pub suberror TargetMachineError {
  /// LLVM returned a null target-machine handle.
  CreationFailed
  /// LLVM failed to emit an object file; contains its diagnostic.
  ObjectEmissionFailed(String)
}

///|
/// The single managed owner of an LLVM target machine.
///
/// The wrapper also retains stable MoonBit copies of its triple, CPU, features,
/// and optional ABI for inspection and module configuration.
///
/// **Lifecycle:** The managed owner disposes the native target machine exactly
/// once. `configureModule` copies target state into a module; the module does not
/// retain this machine afterward.
pub struct TargetMachine {
  priv owner : TargetMachineOwner
  priv triple : TargetTriple
  priv cpu : String
  priv features : String
  priv abi : String?
}

///|
fn TargetMachine::from_raw(
  raw : @raw.LLVMTargetMachineRef,
  triple : TargetTriple,
  cpu : String,
  features : String,
  abi : String?,
) -> TargetMachine {
  TargetMachine::{
    owner: TargetMachineOwner::new(raw),
    triple,
    cpu,
    features,
    abi,
  }
}

///|
fn TargetMachine::get_raw_ref(
  self : TargetMachine,
) -> @raw.LLVMTargetMachineRef {
  self.owner.raw()
}

///|
/// Creates a managed target machine for this registry target and triple.
///
/// **Preconditions:** This descriptor must correspond to `triple`, and its
/// backend must already be initialized. Native initialization does not register
/// arbitrary cross-target backends.
///
/// **Defaults:** Missing CPU and features use `"generic"` and the empty feature
/// string, making this the generic/cross-target-oriented construction path.
///
/// **Errors:** Raises `TargetMachineError::CreationFailed` if LLVM cannot create
/// the machine, or `StringError::ContainsNul` for invalid option strings.
pub fn Target::createTargetMachine(
  self : Target,
  triple : TargetTriple,
  options : TargetMachineOptions,
) -> TargetMachine raise {
  let cpu = match options.cpu {
    Some(value) => value
    None => "generic"
  }
  let features = match options.features {
    Some(value) => value
    None => ""
  }
  create_target_machine(self, triple, options, cpu, features)
}

///|
fn create_target_machine(
  target : Target,
  triple : TargetTriple,
  options : TargetMachineOptions,
  cpu : String,
  features : String,
) -> TargetMachine raise {
  let raw_options = @raw.llvm_create_target_machine_options()
  guard !raw_options.is_null() else { raise CreationFailed }
  @raw.llvm_target_machine_options_set_cpu(raw_options, cpu) catch {
    @raw.EmbeddedNul => {
      @raw.llvm_dispose_target_machine_options(raw_options)
      raise ContainsNul
    }
  }
  @raw.llvm_target_machine_options_set_features(raw_options, features) catch {
    @raw.EmbeddedNul => {
      @raw.llvm_dispose_target_machine_options(raw_options)
      raise ContainsNul
    }
  }
  match options.abi {
    Some(abi) =>
      @raw.llvm_target_machine_options_set_abi(raw_options, abi) catch {
        @raw.EmbeddedNul => {
          @raw.llvm_dispose_target_machine_options(raw_options)
          raise ContainsNul
        }
      }
    None => ()
  }
  @raw.llvm_target_machine_options_set_codegen_opt_level(
    raw_options,
    options.optimizationLevel.to_raw(),
  )
  @raw.llvm_target_machine_options_set_reloc_mode(
    raw_options,
    options.relocationMode.to_raw(),
  )
  @raw.llvm_target_machine_options_set_code_model(
    raw_options,
    options.codeModel.to_raw(),
  )
  let raw = @raw.llvm_create_target_machine_with_options(
    target.raw,
    triple.toString(),
    raw_options,
  ) catch {
    @raw.EmbeddedNul => {
      @raw.llvm_dispose_target_machine_options(raw_options)
      raise ContainsNul
    }
  }
  @raw.llvm_dispose_target_machine_options(raw_options)
  guard !raw.is_null() else { raise CreationFailed }
  TargetMachine::from_raw(raw, triple, cpu, features, options.abi)
}

///|
/// Creates a target machine specialized for the current host.
///
/// This convenience first idempotently initializes native code generation,
/// obtains and looks up the host triple, then fills missing CPU/features from
/// host detection. Explicit option values are preserved.
///
/// **Errors:** Propagates registry lookup/initialization, UTF-8, NUL, and target
/// machine creation errors.
///
/// **Side Effects:** May initialize LLVM's process-global native registry.
///
/// **Notes:** This is host-only convenience. Use the explicit registry/target
/// construction path for other triples after separately initializing a matching
/// backend.
pub fn TargetMachine::host(
  options : TargetMachineOptions,
) -> TargetMachine raise {
  TargetRegistry::initializeNativeCodegen()
  let triple = TargetTriple::host()
  let target = TargetRegistry::lookupTarget(triple)
  let cpu = match options.cpu {
    Some(value) => value
    None =>
      @raw.llvm_get_host_cpu_name() catch {
        @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
      }
  }
  let features = match options.features {
    Some(value) => value
    None =>
      @raw.llvm_get_host_cpu_features() catch {
        @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
      }
  }
  create_target_machine(target, triple, options, cpu, features)
}

///|
/// Returns the triple used to construct this target machine.
pub fn TargetMachine::getTriple(self : TargetMachine) -> TargetTriple {
  ignore(self.owner)
  self.triple
}

///|
/// Returns the effective CPU name used during construction.
pub fn TargetMachine::getCPU(self : TargetMachine) -> String {
  self.cpu
}

///|
/// Returns the effective LLVM target-feature string.
pub fn TargetMachine::getFeatures(self : TargetMachine) -> String {
  self.features
}

///|
/// Returns the explicitly selected ABI, or `None` when LLVM's default applies.
pub fn TargetMachine::getABI(self : TargetMachine) -> String? {
  self.abi
}

///|
/// Writes this machine's target triple and DataLayout into a module.
/// The module keeps copied target state and does not retain this machine.
///
/// **Preconditions:** The module's IR and context must be compatible with this
/// target. The method does not verify the module.
///
/// **Errors:** Raises `StringError::ContainsNul` if the stored triple cannot be
/// passed to LLVM.
///
/// **Side Effects:** Replaces the module's target triple and data layout. The
/// copied state remains after this target machine is released.
///
/// **Notes:** This is stage one of the recommended workflow:
/// `configureModule`, `Module::verify`, then `emitObjectToFile`.
pub fn TargetMachine::configureModule(
  self : TargetMachine,
  mod : Module,
) -> Unit raise StringError {
  @raw.llvm_set_target(mod.get_raw_ref(), self.triple.toString()) catch {
    @raw.EmbeddedNul => raise ContainsNul
  }
  @raw.llvm_target_machine_set_module_data_layout(
    self.get_raw_ref(),
    mod.get_raw_ref(),
  )
}

///|
/// Emits the module to a native object file without configuring or verifying
/// it. LLVM diagnostics are preserved in ObjectEmissionFailed.
///
/// **Preconditions:** The module must already be configured for this machine and
/// contain valid IR. Call `configureModule` and `Module::verify` explicitly.
///
/// **Errors:** Raises `StringError::ContainsNul` for an invalid filename or
/// `TargetMachineError::ObjectEmissionFailed` with LLVM's diagnostic.
///
/// **Side Effects:** Creates or overwrites `filename`. The method borrows the
/// module and machine; it does not mutate target configuration and does not run
/// the verifier.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("emission_stages")
///   let machine = TargetMachine::host(TargetMachineOptions::default())
///   machine.configureModule(mod)
///   mod.verify()
///   // Object output and link/run are exercised by native_emission_test, where
///   // a temporary path and the system toolchain are available.
/// }
/// ```
pub fn TargetMachine::emitObjectToFile(
  self : TargetMachine,
  mod : Module,
  filename : String,
) -> Unit raise {
  let (failed, message) = @raw.llvm_target_machine_emit_object_to_file(
    self.get_raw_ref(),
    mod.get_raw_ref(),
    filename,
  ) catch {
    @raw.EmbeddedNul => raise ContainsNul
  }
  guard !failed else { raise ObjectEmissionFailed(message) }
}
