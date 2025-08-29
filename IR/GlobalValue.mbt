
pub type GlobalVariable ValueRef

pub impl Value for GlobalVariable with getValueRef(self) -> ValueRef {
  self.inner()
}

pub impl Value for GlobalVariable with asValueEnum(self) -> ValueEnum {
  GlobalVariable(self)
}

pub impl GlobalValue for GlobalVariable with asGlobalEnum(self) -> GlobalEnum {
  GlobalVariable(self)
}

pub impl Show for GlobalVariable with output(self, logger) {
  let s = @unsafe.llvm_print_value_to_string(self.getValueRef())
  logger.write_string(s)
}

pub type GlobalConstant ValueRef

pub impl Value for GlobalConstant with getValueRef(self) -> ValueRef {
  self.inner()
}

pub impl Value for GlobalConstant with asValueEnum(self) -> ValueEnum {
  GlobalConstant(self)
}

pub impl GlobalValue for GlobalConstant with asGlobalEnum(self) -> GlobalEnum {
  GlobalConstant(self)
}

pub impl Show for GlobalConstant with output(self, logger) {
  let s = @unsafe.llvm_print_value_to_string(self.getValueRef())
  logger.write_string(s)
}

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

fn Linkage::from_llvm_linkage(linkage: @unsafe.LLVMLinkage) -> Linkage {
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

fn Linkage::to_llvm_linkage(self: Self) -> @unsafe.LLVMLinkage {
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

pub(all) enum UnnamedAddr {
  NoUnnamedAddr
  Local
  Global
}

fn UnnamedAddr::from_llvm_unnamed_addr(ua: @unsafe.LLVMUnnamedAddr) -> UnnamedAddr {
  match ua {
    LLVMNoUnnamedAddr => NoUnnamedAddr
    LLVMLocalUnnamedAddr => Local
    LLVMGlobalUnnamedAddr => Global
  }
}

fn UnnamedAddr::to_llvm_unnamed_addr(self: Self) -> @unsafe.LLVMUnnamedAddr {
  match self {
    NoUnnamedAddr => LLVMNoUnnamedAddr
    Local => LLVMLocalUnnamedAddr
    Global => LLVMGlobalUnnamedAddr
  }
}
