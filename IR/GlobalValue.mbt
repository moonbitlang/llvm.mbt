///|
pub struct GlobalVariable {
  priv value : ModuleOwnedValue
}

///|
fn GlobalVariable::from_raw(
  value_ref : ValueRef,
  owner_module : Module,
) -> GlobalVariable {
  GlobalVariable::{ value: ModuleOwnedValue::new(value_ref, owner_module) }
}

///|
fn GlobalVariable::get_module(self : GlobalVariable) -> Module {
  self.value.get_module()
}

///|
pub impl Value for GlobalVariable with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
pub impl Value for GlobalVariable with fn asValueEnum(self) -> ValueEnum {
  GlobalVariable(self)
}

///|
pub impl GlobalValue for GlobalVariable with fn asGlobalEnum(self) -> GlobalEnum {
  GlobalVariable(self)
}

///|
pub impl Show for GlobalVariable with fn output(self, logger) {
  let s = @unsafe.llvm_print_value_to_string(self.getValueRef()) catch {
    error => "<LLVM global variable text unavailable: \{error}>"
  }
  logger.write_string(s)
}

///|
pub struct GlobalConstant {
  priv value : ModuleOwnedValue
}

///|
fn GlobalConstant::from_raw(
  value_ref : ValueRef,
  owner_module : Module,
) -> GlobalConstant {
  GlobalConstant::{ value: ModuleOwnedValue::new(value_ref, owner_module) }
}

///|
fn GlobalConstant::get_module(self : GlobalConstant) -> Module {
  self.value.get_module()
}

///|
pub impl Value for GlobalConstant with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
pub impl Value for GlobalConstant with fn asValueEnum(self) -> ValueEnum {
  GlobalConstant(self)
}

///|
pub impl GlobalValue for GlobalConstant with fn asGlobalEnum(self) -> GlobalEnum {
  GlobalConstant(self)
}

///|
pub impl Show for GlobalConstant with fn output(self, logger) {
  let s = @unsafe.llvm_print_value_to_string(self.getValueRef()) catch {
    error => "<LLVM global constant text unavailable: \{error}>"
  }
  logger.write_string(s)
}

///|
pub(all) enum Linkage {
  ExternalLinkage
  AvailableExternallyLinkage
  LinkOnceAnyLinkage
  LinkOnceODRLinkage
  LinkOnceODRAutoHideLinkage
  WeakAnyLinkage
  WeakODRLinkage
  AppendingLinkage
  InternalLinkage
  PrivateLinkage
  DLLImportLinkage
  DLLExportLinkage
  ExternalWeakLinkage
  GhostLinkage
  CommonLinkage
  LinkerPrivateLinkage
  LinkerPrivateWeakLinkage
}

///|
fn Linkage::from_llvm_linkage(linkage : @unsafe.LLVMLinkage) -> Linkage {
  match linkage {
    LLVMExternalLinkage => ExternalLinkage
    LLVMAvailableExternallyLinkage => AvailableExternallyLinkage
    LLVMLinkOnceAnyLinkage => LinkOnceAnyLinkage
    LLVMLinkOnceODRLinkage => LinkOnceODRLinkage
    LLVMLinkOnceODRAutoHideLinkage => LinkOnceODRAutoHideLinkage
    LLVMWeakAnyLinkage => WeakAnyLinkage
    LLVMWeakODRLinkage => WeakODRLinkage
    LLVMAppendingLinkage => AppendingLinkage
    LLVMInternalLinkage => InternalLinkage
    LLVMPrivateLinkage => PrivateLinkage
    LLVMDLLImportLinkage => DLLImportLinkage
    LLVMDLLExportLinkage => DLLExportLinkage
    LLVMExternalWeakLinkage => ExternalWeakLinkage
    LLVMGhostLinkage => GhostLinkage
    LLVMCommonLinkage => CommonLinkage
    LLVMLinkerPrivateLinkage => LinkerPrivateLinkage
    LLVMLinkerPrivateWeakLinkage => LinkerPrivateWeakLinkage
  }
}

///|
fn Linkage::to_llvm_linkage(self : Self) -> @unsafe.LLVMLinkage {
  match self {
    ExternalLinkage => LLVMExternalLinkage
    AvailableExternallyLinkage => LLVMAvailableExternallyLinkage
    LinkOnceAnyLinkage => LLVMLinkOnceAnyLinkage
    LinkOnceODRLinkage => LLVMLinkOnceODRLinkage
    LinkOnceODRAutoHideLinkage => LLVMLinkOnceODRAutoHideLinkage
    WeakAnyLinkage => LLVMWeakAnyLinkage
    WeakODRLinkage => LLVMWeakODRLinkage
    AppendingLinkage => LLVMAppendingLinkage
    InternalLinkage => LLVMInternalLinkage
    PrivateLinkage => LLVMPrivateLinkage
    DLLImportLinkage => LLVMDLLImportLinkage
    DLLExportLinkage => LLVMDLLExportLinkage
    ExternalWeakLinkage => LLVMExternalWeakLinkage
    GhostLinkage => LLVMGhostLinkage
    CommonLinkage => LLVMCommonLinkage
    LinkerPrivateLinkage => LLVMLinkerPrivateLinkage
    LinkerPrivateWeakLinkage => LLVMLinkerPrivateWeakLinkage
  }
}

///|
pub(all) enum UnnamedAddr {
  NoUnnamedAddr
  Local
  Global
}

///|
fn UnnamedAddr::from_llvm_unnamed_addr(
  ua : @unsafe.LLVMUnnamedAddr,
) -> UnnamedAddr {
  match ua {
    LLVMNoUnnamedAddr => NoUnnamedAddr
    LLVMLocalUnnamedAddr => Local
    LLVMGlobalUnnamedAddr => Global
  }
}

///|
fn UnnamedAddr::to_llvm_unnamed_addr(self : Self) -> @unsafe.LLVMUnnamedAddr {
  match self {
    NoUnnamedAddr => LLVMNoUnnamedAddr
    Local => LLVMLocalUnnamedAddr
    Global => LLVMGlobalUnnamedAddr
  }
}
