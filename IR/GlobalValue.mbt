///|
/// Module-owned mutable LLVM global variable.
///
/// It may be a declaration without an initializer or a definition with one.
/// The declared value type and initializer type must agree.
///
/// **Lifecycle:** The wrapper retains its module and must not be used after the
/// underlying global is erased through the raw layer.
pub struct GlobalVariable {
  priv value : ModuleAnchoredValue
}

///|
fn GlobalVariable::from_raw(
  value_ref : ValueRef,
  owner_module : Module,
) -> GlobalVariable {
  GlobalVariable::{ value: ModuleAnchoredValue::new(value_ref, owner_module), }
}

///|
fn GlobalVariable::get_module(self : GlobalVariable) -> Module {
  self.value.get_module()
}

///|
/// Returns the internal borrowed LLVM value handle.
fn GlobalVariable::get_raw_value_ref(self : GlobalVariable) -> ValueRef {
  self.value.get_raw_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::GlobalVariable`.
pub impl Value for GlobalVariable with fn asValueEnum(self) -> ValueEnum {
  GlobalVariable(self)
}

///|
/// Classifies this wrapper as `GlobalEnum::GlobalVariable`.
pub impl GlobalValue for GlobalVariable with fn asGlobalEnum(self) -> GlobalEnum {
  GlobalVariable(self)
}

///|
/// Writes the global declaration or definition using LLVM syntax.
pub impl Show for GlobalVariable with fn output(self, logger) {
  let s = @raw.llvm_print_value_to_string(self.get_raw_value_ref()) catch {
    error => "<LLVM global variable text unavailable: \{error}>"
  }
  logger.write_string(s)
}

///|
/// Module-owned LLVM global whose storage is marked constant.
///
/// **Construction:** Use `Module::addGlobalConstant` for an initialized definition,
/// or `Module::declareGlobalConstant` followed by `setInitializer`.
///
/// As a `Constant` operand this denotes the address of its storage, not the
/// initializer. Both mutable and immutable globals have constant addresses.
///
/// **Lifecycle:** The wrapper retains its module.
pub struct GlobalConstant {
  priv value : ModuleAnchoredValue
}

///|
fn GlobalConstant::from_raw(
  value_ref : ValueRef,
  owner_module : Module,
) -> GlobalConstant {
  GlobalConstant::{ value: ModuleAnchoredValue::new(value_ref, owner_module), }
}

///|
fn GlobalConstant::get_module(self : GlobalConstant) -> Module {
  self.value.get_module()
}

///|
/// Returns the internal borrowed LLVM value handle.
fn GlobalConstant::get_raw_value_ref(self : GlobalConstant) -> ValueRef {
  self.value.get_raw_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::GlobalConstant`.
pub impl Value for GlobalConstant with fn asValueEnum(self) -> ValueEnum {
  GlobalConstant(self)
}

///|
/// Classifies this wrapper as `GlobalEnum::GlobalConstant`.
pub impl GlobalValue for GlobalConstant with fn asGlobalEnum(self) -> GlobalEnum {
  GlobalConstant(self)
}

///|
/// Writes the constant global declaration or definition using LLVM syntax.
pub impl Show for GlobalConstant with fn output(self, logger) {
  let s = @raw.llvm_print_value_to_string(self.get_raw_value_ref()) catch {
    error => "<LLVM global constant text unavailable: \{error}>"
  }
  logger.write_string(s)
}

///|
/// Installs or replaces the initializer of a constant global.
///
/// This changes the compile-time definition, not the runtime mutability of its
/// storage. The initializer must have the declared storage type; the global's
/// address type is not its storage type.
///
/// **Errors:** Raises `ValueOwnerError::ContextMismatch` for a foreign context,
/// `ValueOwnerError::ModuleMismatch` for a dependency on another module, or
/// `InValidTypeError` for a mismatched initializer type. Validation completes
/// before mutation, leaving the previous declaration or initializer intact on error.
///
/// **Lifecycle:** The module owns the installed LLVM initializer. It does not
/// retain the MoonBit wrapper, so same-module cyclic address references do not
/// create MoonBit owner cycles. Existing global handles and addresses remain valid.
///
/// **Side effects:** Updates this global's definition, visible through all aliases.
///
/// **See also:** `Module::declareGlobalConstant` demonstrates deferred initialization.
pub fn GlobalConstant::setInitializer(
  self : Self,
  value : &Constant,
) -> Unit raise {
  let mod = self.get_module()
  merge_value_owners(mod.getContext(), Some(mod), [value]) |> ignore
  let storage_type = initAbstractType(
    @raw.llvm_global_get_value_type(self.get_raw_value_ref()),
    mod.getContext(),
  )
  guard (value : &Value).getType().asTypeEnum() == storage_type.asTypeEnum() else {
    raise InValidTypeError(
      "Global initializer type does not match its storage type",
    )
  }
  @raw.llvm_set_initializer(
    self.get_raw_value_ref(),
    (value : &Value).get_raw_value_ref(),
  )
}

///|
/// LLVM linkage controlling symbol visibility and linker resolution.
///
/// Some cases are target-specific or retained only for LLVM-C compatibility.
pub(all) enum Linkage {
  /// Externally visible definition or declaration with normal resolution.
  ExternalLinkage
  /// Definition available to optimizers but omitted from emitted code.
  AvailableExternallyLinkage
  /// Linker may keep any one definition with the same name.
  LinkOnceAnyLinkage
  /// Linker may merge definitions that satisfy the one-definition rule.
  LinkOnceODRLinkage
  /// Obsolete LLVM-C compatibility linkage; avoid in new code.
  LinkOnceODRAutoHideLinkage
  /// Weak definition where the linker may choose another definition.
  WeakAnyLinkage
  /// Weak definition whose alternatives must be ODR-equivalent.
  WeakODRLinkage
  /// Appends matching global arrays during linking; valid only for arrays.
  AppendingLinkage
  /// Module-local symbol, analogous to a source-level `static` definition.
  InternalLinkage
  /// Module-local definition omitted from the object symbol table when possible.
  PrivateLinkage
  /// PE/COFF symbol imported from a dynamic-link library.
  DLLImportLinkage
  /// PE/COFF symbol exported from a dynamic-link library.
  DLLExportLinkage
  /// Weak external declaration that resolves to null if no definition exists.
  ExternalWeakLinkage
  /// Obsolete LLVM-C compatibility linkage; avoid in new code.
  GhostLinkage
  /// Tentative global definition merged using common-symbol rules.
  CommonLinkage
  /// Obsolete LLVM-C compatibility linkage; avoid in new code.
  LinkerPrivateLinkage
  /// Obsolete LLVM-C compatibility linkage; avoid in new code.
  LinkerPrivateWeakLinkage
}

///|
fn Linkage::from_llvm_linkage(linkage : @raw.LLVMLinkage) -> Linkage {
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
fn Linkage::to_llvm_linkage(self : Self) -> @raw.LLVMLinkage {
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
/// Guarantee describing whether a global value's address is semantically
/// significant.
pub(all) enum UnnamedAddr {
  /// No address-insignificance guarantee.
  NoUnnamedAddr
  /// Address is insignificant only within this module.
  Local
  /// Address is globally insignificant and equivalent definitions may share an
  /// address.
  Global
}

///|
fn UnnamedAddr::from_llvm_unnamed_addr(
  ua : @raw.LLVMUnnamedAddr,
) -> UnnamedAddr {
  match ua {
    LLVMNoUnnamedAddr => NoUnnamedAddr
    LLVMLocalUnnamedAddr => Local
    LLVMGlobalUnnamedAddr => Global
  }
}

///|
fn UnnamedAddr::to_llvm_unnamed_addr(self : Self) -> @raw.LLVMUnnamedAddr {
  match self {
    NoUnnamedAddr => LLVMNoUnnamedAddr
    Local => LLVMLocalUnnamedAddr
    Global => LLVMGlobalUnnamedAddr
  }
}

///|
/// Views this global's address as a constant operand; does not read its storage.
///
/// **Lifecycle:** Preserves the global's existing module anchor.
pub impl Constant for GlobalVariable with fn asConstantEnum(self) {
  GlobalVariable(self)
}

///|
/// Views this global's address as a constant operand; does not read its storage.
///
/// **Lifecycle:** Preserves the global's existing module anchor.
pub impl Constant for GlobalConstant with fn asConstantEnum(self) {
  GlobalConstant(self)
}
