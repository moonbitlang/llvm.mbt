///|
/// A target triple used for target lookup and code generation.
pub struct TargetTriple {
  priv value : String
} derive(Eq, Debug)

///|
pub fn TargetTriple::new(value : String) -> TargetTriple raise StringError {
  guard !value.contains_code_unit(0) else { raise ContainsNul }
  TargetTriple::{ value, }
}

///|
pub fn TargetTriple::host() -> TargetTriple raise StringError {
  let value = @unsafe.llvm_get_default_target_triple() catch {
    @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
  }
  TargetTriple::{ value, }
}

///|
pub fn TargetTriple::toString(self : TargetTriple) -> String {
  self.value
}

///|
pub impl Show for TargetTriple with fn output(self, logger) {
  logger.write_string(self.value)
}

///|
/// Failure while initializing or querying LLVM's process-global registry.
pub suberror TargetRegistryError {
  NativeTargetUnavailable
  NativeAsmPrinterUnavailable
  TargetNotFound(String)
}

///|
/// LLVM's process-global target registry namespace.
pub type TargetRegistry

///|
pub fn TargetRegistry::initializeNativeCodegen() -> Unit raise TargetRegistryError {
  guard !@unsafe.llvm_initialize_native_target() else {
    raise NativeTargetUnavailable
  }
  guard !@unsafe.llvm_initialize_native_asm_printer() else {
    raise NativeAsmPrinterUnavailable
  }
}

///|
/// Looks up a registry-owned target. The returned descriptor is borrowed for
/// the process lifetime and has no disposer.
pub fn TargetRegistry::lookupTarget(
  triple : TargetTriple,
) -> Target raise TargetRegistryError {
  let (raw, message, failed) = @unsafe.llvm_get_target_from_triple(
    triple.toString(),
  )
  guard !failed && !raw.is_null() else { raise TargetNotFound(message) }
  Target::{ raw, }
}

///|
/// A borrowed target descriptor owned by LLVM's global target registry.
pub struct Target {
  priv raw : @unsafe.LLVMTargetRef
}

///|
pub fn Target::getName(self : Target) -> String raise StringError {
  @unsafe.llvm_get_target_name(self.raw) catch {
    @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
  }
}

///|
pub fn Target::getDescription(self : Target) -> String raise StringError {
  @unsafe.llvm_get_target_description(self.raw) catch {
    @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
  }
}

///|
pub(all) enum CodeGenOptimizationLevel {
  None
  Less
  Default
  Aggressive
}

///|
fn CodeGenOptimizationLevel::to_unsafe(
  self : CodeGenOptimizationLevel,
) -> @unsafe.LLVMCodeGenOptLevel {
  match self {
    None => LLVMCodeGenLevelNone
    Less => LLVMCodeGenLevelLess
    Default => LLVMCodeGenLevelDefault
    Aggressive => LLVMCodeGenLevelAggressive
  }
}

///|
pub(all) enum RelocationMode {
  Default
  Static
  Pic
  DynamicNoPic
  Ropi
  Rwpi
  RopiRwpi
}

///|
fn RelocationMode::to_unsafe(self : RelocationMode) -> @unsafe.LLVMRelocMode {
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
pub(all) enum CodeModel {
  Default
  JitDefault
  Tiny
  Small
  Kernel
  Medium
  Large
}

///|
fn CodeModel::to_unsafe(self : CodeModel) -> @unsafe.LLVMCodeModel {
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
pub struct TargetMachineOptions {
  priv cpu : String?
  priv features : String?
  priv abi : String?
  priv optimizationLevel : CodeGenOptimizationLevel
  priv relocationMode : RelocationMode
  priv codeModel : CodeModel
}

///|
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
  CreationFailed
}

///|
/// The single managed owner of an LLVM target machine.
pub struct TargetMachine {
  priv owner : TargetMachineOwner
  priv triple : TargetTriple
  priv cpu : String
  priv features : String
  priv abi : String?
}

///|
fn TargetMachine::from_raw(
  raw : @unsafe.LLVMTargetMachineRef,
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
  let raw_options = @unsafe.llvm_create_target_machine_options()
  guard !raw_options.is_null() else { raise CreationFailed }
  @unsafe.llvm_target_machine_options_set_cpu(raw_options, cpu) catch {
    @unsafe.EmbeddedNul => {
      @unsafe.llvm_dispose_target_machine_options(raw_options)
      raise ContainsNul
    }
  }
  @unsafe.llvm_target_machine_options_set_features(raw_options, features) catch {
    @unsafe.EmbeddedNul => {
      @unsafe.llvm_dispose_target_machine_options(raw_options)
      raise ContainsNul
    }
  }
  match options.abi {
    Some(abi) =>
      @unsafe.llvm_target_machine_options_set_abi(raw_options, abi) catch {
        @unsafe.EmbeddedNul => {
          @unsafe.llvm_dispose_target_machine_options(raw_options)
          raise ContainsNul
        }
      }
    None => ()
  }
  @unsafe.llvm_target_machine_options_set_codegen_opt_level(
    raw_options,
    options.optimizationLevel.to_unsafe(),
  )
  @unsafe.llvm_target_machine_options_set_reloc_mode(
    raw_options,
    options.relocationMode.to_unsafe(),
  )
  @unsafe.llvm_target_machine_options_set_code_model(
    raw_options,
    options.codeModel.to_unsafe(),
  )
  let raw = @unsafe.llvm_create_target_machine_with_options(
    target.raw,
    triple.toString(),
    raw_options,
  ) catch {
    @unsafe.EmbeddedNul => {
      @unsafe.llvm_dispose_target_machine_options(raw_options)
      raise ContainsNul
    }
  }
  @unsafe.llvm_dispose_target_machine_options(raw_options)
  guard !raw.is_null() else { raise CreationFailed }
  TargetMachine::from_raw(raw, triple, cpu, features, options.abi)
}

///|
pub fn TargetMachine::host(
  options : TargetMachineOptions,
) -> TargetMachine raise {
  TargetRegistry::initializeNativeCodegen()
  let triple = TargetTriple::host()
  let target = TargetRegistry::lookupTarget(triple)
  let cpu = match options.cpu {
    Some(value) => value
    None =>
      @unsafe.llvm_get_host_cpu_name() catch {
        @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
      }
  }
  let features = match options.features {
    Some(value) => value
    None =>
      @unsafe.llvm_get_host_cpu_features() catch {
        @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
      }
  }
  create_target_machine(target, triple, options, cpu, features)
}

///|
pub fn TargetMachine::getTriple(self : TargetMachine) -> TargetTriple {
  ignore(self.owner)
  self.triple
}

///|
pub fn TargetMachine::getCPU(self : TargetMachine) -> String {
  self.cpu
}

///|
pub fn TargetMachine::getFeatures(self : TargetMachine) -> String {
  self.features
}

///|
pub fn TargetMachine::getABI(self : TargetMachine) -> String? {
  self.abi
}
