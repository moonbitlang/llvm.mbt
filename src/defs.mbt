// extern types
type CStr

pub type AddressSpace UInt derive(Eq, Show)
pub type FastMathFlags UInt derive(Eq)

pub fn AddressSpace::default() -> AddressSpace {
  AddressSpace(0)
}

// Dummpy function, only for eliminate warning
// FIXME: Remove this function
pub fn LLVMAttributeIndex::new(idx: UInt) -> LLVMAttributeIndex {
  LLVMAttributeIndex(idx)
}

pub fn LLVMFastMathFlags::into(self: LLVMFastMathFlags) -> FastMathFlags {
  guard let LLVMFastMathFlags(f) = self
  FastMathFlags(f)
}

pub fn FastMathFlags::into(self: FastMathFlags) -> LLVMFastMathFlags {
  guard let FastMathFlags(f) = self
  LLVMFastMathFlags(f)
}

pub enum IntPredicate {
  // Equal
  EQ

  // Not equal
  NE

  // Unsigned greater than
  UGT

  // Unsigned greater than or equal
  UGE

  // Unsigned less than
  ULT

  // Unsigned greater than or equal
  ULE

  // Signed greater than
  SGT

  // Signed greater than or equal
  SGE

  // Signed less than
  SLT

  // Signed less than or equal
  SLE
} derive(Eq, Show, Hash)

pub fn LLVMIntPredicate::into(self: LLVMIntPredicate) -> IntPredicate {
  match self {
    LLVMIntEQ => EQ
    LLVMIntNE => NE
    LLVMIntUGT => UGT
    LLVMIntUGE => UGE
    LLVMIntULT => ULT
    LLVMIntULE => ULE
    LLVMIntSGT => SGT
    LLVMIntSGE => SGE
    LLVMIntSLT => SLT
    LLVMIntSLE => SLE
  }
}

pub fn IntPredicate::into(self: IntPredicate) -> LLVMIntPredicate {
  match self {
    EQ => LLVMIntEQ
    NE => LLVMIntNE
    UGT => LLVMIntUGT
    UGE => LLVMIntUGE
    ULT => LLVMIntULT
    ULE => LLVMIntULE
    SGT => LLVMIntSGT
    SGE => LLVMIntSGE
    SLT => LLVMIntSLT
    SLE => LLVMIntSLE
  }
}

pub enum FloatPredicate {
  /// Returns true if `left` == `right` and neither are NaN
  OEQ

  /// Returns true if `left` >= `right` and neither are NaN

  OGE

  /// Returns true if `left` > `right` and neither are NaN
  OGT

  /// Returns true if `left` <= `right` and neither are NaN
  OLE

  /// Returns true if `left` < `right` and neither are NaN
  OLT

  /// Returns true if `left` != `right` and neither are NaN
  ONE

  /// Returns true if neither value is NaN
  ORD

  /// Always returns false
  PredicateFalse

  /// Always returns true
  PredicateTrue

  /// Returns true if `left` == `right` or either is NaN
  UEQ

  /// Returns true if `left` >= `right` or either is NaN
  UGE

  /// Returns true if `left` > `right` or either is NaN
  UGT

  /// Returns true if `left` <= `right` or either is NaN
  ULE

  /// Returns true if `left` < `right` or either is NaN
  ULT

  /// Returns true if `left` != `right` or either is NaN
  UNE

  /// Returns true if either value is NaN
  UNO
} derive(Eq, Show, Hash)

fn LLVMRealPredicate::into(self: LLVMRealPredicate) -> FloatPredicate {
  match self {
    LLVMRealPredicateFalse => FloatPredicate::PredicateFalse
    LLVMRealOEQ => OEQ
    LLVMRealOGT => OGT
    LLVMRealOGE => OGE
    LLVMRealOLT => OLT
    LLVMRealOLE => OLE
    LLVMRealONE => ONE
    LLVMRealORD => ORD
    LLVMRealUNO => UNO
    LLVMRealUEQ => UEQ
    LLVMRealUGT => UGT
    LLVMRealUGE => UGE
    LLVMRealULT => ULT
    LLVMRealULE => ULE
    LLVMRealUNE => UNE
    LLVMRealPredicateTrue => FloatPredicate::PredicateTrue
  }
}

fn FloatPredicate::into(self: FloatPredicate) -> LLVMRealPredicate {
  match self {
    FloatPredicate::PredicateFalse => LLVMRealPredicateFalse
    OEQ => LLVMRealOEQ
    OGT => LLVMRealOGT
    OGE => LLVMRealOGE
    OLT => LLVMRealOLT
    OLE => LLVMRealOLE
    ONE => LLVMRealONE
    ORD => LLVMRealORD
    UNO => LLVMRealUNO
    UEQ => LLVMRealUEQ
    UGT => LLVMRealUGT
    UGE => LLVMRealUGE
    ULT => LLVMRealULT
    ULE => LLVMRealULE
    UNE => LLVMRealUNE
    FloatPredicate::PredicateTrue => LLVMRealPredicateTrue
  }
}


pub enum InstructionOpcode {
    Add
    AddrSpaceCast
    Alloca
    And
    AShr
    AtomicCmpXchg
    AtomicRMW
    BitCast
    Br
    Call
    CallBr
    CatchPad
    CatchRet
    CatchSwitch
    CleanupPad
    CleanupRet
    ExtractElement
    ExtractValue
    FNeg
    FAdd
    FCmp
    FDiv
    Fence
    FMul
    FPExt
    FPToSI
    FPToUI
    FPTrunc
    Freeze
    FRem
    FSub
    GetElementPtr
    ICmp
    IndirectBr
    InsertElement
    InsertValue
    IntToPtr
    Invoke
    LandingPad
    Load
    LShr
    Mul
    Or
    Phi
    PtrToInt
    Resume
    Return
    SDiv
    Select
    SExt
    Shl
    ShuffleVector
    SIToFP
    SRem
    Store
    Sub
    Switch
    Trunc
    UDiv
    UIToFP
    Unreachable
    URem
    UserOp1
    UserOp2
    VAArg
    Xor
    ZExt
} derive(Eq, Show, Hash)

pub fn LLVMOpcode::into(self: LLVMOpcode) -> InstructionOpcode {
  match self {
    LLVMRet => Return
    LLVMBr => Br
    LLVMSwitch => Switch
    LLVMIndirectBr => IndirectBr
    LLVMInvoke => Invoke
    LLVMResume => Resume
    LLVMLandingPad => LandingPad
    LLVMCatchPad => CatchPad
    LLVMCleanupPad => CleanupPad
    LLVMCatchRet => CatchRet
    LLVMCleanupRet => CleanupRet
    LLVMCatchSwitch => CatchSwitch
    LLVMAdd => Add
    LLVMFAdd => FAdd
    LLVMSub => Sub
    LLVMFSub => FSub
    LLVMMul => Mul
    LLVMFMul => FMul
    LLVMUDiv => UDiv
    LLVMSDiv => SDiv
    LLVMFDiv => FDiv
    LLVMURem => URem
    LLVMSRem => SRem
    LLVMFRem => FRem
    LLVMShl => Shl
    LLVMLShr => LShr
    LLVMAShr => AShr
    LLVMAnd => And
    LLVMOr => Or
    LLVMXor => Xor
    LLVMAlloca => Alloca
    LLVMLoad => Load
    LLVMStore => Store
    LLVMGetElementPtr => GetElementPtr
    LLVMFence => Fence
    LLVMAtomicCmpXchg => AtomicCmpXchg
    LLVMAtomicRMW => AtomicRMW
    LLVMTrunc => Trunc
    LLVMZExt => ZExt
    LLVMSExt => SExt
    LLVMFPToUI => FPToUI
    LLVMFPToSI => FPToSI
    LLVMUIToFP => UIToFP
    LLVMSIToFP => SIToFP
    LLVMFPTrunc => FPTrunc
    LLVMFPExt => FPExt
    LLVMPtrToInt => PtrToInt
    LLVMIntToPtr => IntToPtr
    LLVMBitCast => BitCast
    LLVMAddrSpaceCast => AddrSpaceCast
    LLVMICmp => ICmp
    LLVMFCmp => FCmp
    LLVMPHI => Phi
    LLVMCall => Call
    LLVMCallBr => CallBr
    LLVMFNeg => FNeg
    LLVMExtractElement => ExtractElement
    LLVMExtractValue => ExtractValue
    LLVMFreeze => Freeze
    LLVMInsertElement => InsertElement
    LLVMInsertValue => InsertValue
    LLVMSelect => Select
    LLVMShuffleVector => ShuffleVector
    LLVMUnreachable => Unreachable
    LLVMUserOp1 => UserOp1
    LLVMUserOp2 => UserOp2
    LLVMVAArg => VAArg
  }
}

pub fn InstructionOpcode::into(self: InstructionOpcode) -> LLVMOpcode {
  match self {
    Return => LLVMRet
    Br => LLVMBr
    Switch => LLVMSwitch
    IndirectBr => LLVMIndirectBr
    Invoke => LLVMInvoke
    Resume => LLVMResume
    LandingPad => LLVMLandingPad
    CatchPad => LLVMCatchPad
    CleanupPad => LLVMCleanupPad
    CatchRet => LLVMCatchRet
    CleanupRet => LLVMCleanupRet
    CatchSwitch => LLVMCatchSwitch
    Add => LLVMAdd
    FAdd => LLVMFAdd
    Sub => LLVMSub
    FSub => LLVMFSub
    Mul => LLVMMul
    FMul => LLVMFMul
    UDiv => LLVMUDiv
    SDiv => LLVMSDiv
    FDiv => LLVMFDiv
    URem => LLVMURem
    SRem => LLVMSRem
    FRem => LLVMFRem
    Shl => LLVMShl
    LShr => LLVMLShr
    AShr => LLVMAShr
    And => LLVMAnd
    Or => LLVMOr
    Xor => LLVMXor
    Alloca => LLVMAlloca
    Load => LLVMLoad
    Store => LLVMStore
    GetElementPtr => LLVMGetElementPtr
    Fence => LLVMFence
    AtomicCmpXchg => LLVMAtomicCmpXchg
    AtomicRMW => LLVMAtomicRMW
    Trunc => LLVMTrunc
    ZExt => LLVMZExt
    SExt => LLVMSExt
    FPToUI => LLVMFPToUI
    FPToSI => LLVMFPToSI
    UIToFP => LLVMUIToFP
    SIToFP => LLVMSIToFP
    FPTrunc => LLVMFPTrunc
    FPExt => LLVMFPExt
    PtrToInt => LLVMPtrToInt
    IntToPtr => LLVMIntToPtr
    BitCast => LLVMBitCast
    AddrSpaceCast => LLVMAddrSpaceCast
    ICmp => LLVMICmp
    FCmp => LLVMFCmp
    Phi => LLVMPHI
    Call => LLVMCall
    CallBr => LLVMCallBr
    FNeg => LLVMFNeg
    ExtractElement => LLVMExtractElement
    ExtractValue => LLVMExtractValue
    Freeze => LLVMFreeze
    InsertElement => LLVMInsertElement
    InsertValue => LLVMInsertValue
    Select => LLVMSelect
    ShuffleVector => LLVMShuffleVector
    Unreachable => LLVMUnreachable
    UserOp1 => LLVMUserOp1
    UserOp2 => LLVMUserOp2
    VAArg => LLVMVAArg
  }
}

pub enum AtomicOrdering {
  NotAtomic

  Unordered

  Monotonic

  Acquire

  Release

  AcquireRelease

  SequentiallyConsistent
} derive(Eq, Show, Hash)

pub fn LLVMAtomicOrdering::into(self: LLVMAtomicOrdering) -> AtomicOrdering {
  match self {
    LLVMAtomicOrderingNotAtomic => NotAtomic
    LLVMAtomicOrderingUnordered => Unordered
    LLVMAtomicOrderingMonotonic => Monotonic
    LLVMAtomicOrderingAcquire => Acquire
    LLVMAtomicOrderingRelease => Release
    LLVMAtomicOrderingAcquireRelease => AcquireRelease
    LLVMAtomicOrderingSequentiallyConsistent => SequentiallyConsistent
  }
}

pub fn AtomicOrdering::into(self: AtomicOrdering) -> LLVMAtomicOrdering {
  match self {
    NotAtomic => LLVMAtomicOrderingNotAtomic
    Unordered => LLVMAtomicOrderingUnordered
    Monotonic => LLVMAtomicOrderingMonotonic
    Acquire => LLVMAtomicOrderingAcquire
    Release => LLVMAtomicOrderingRelease
    AcquireRelease => LLVMAtomicOrderingAcquireRelease
    SequentiallyConsistent => LLVMAtomicOrderingSequentiallyConsistent
  }
}

pub enum AtomicRMWBinOp {
  /// Stores to memory and returns the prior value.
  Xchg

  /// Adds to the value in memory and returns the prior value.
  Add

  /// Subtract a value off the value in memory and returns the prior value.
  Sub

  /// Bitwise and into memory and returns the prior value.
  And

  /// Bitwise nands into memory and returns the prior value.
  Nand

  /// Bitwise ors into memory and returns the prior value.
  Or

  /// Bitwise xors into memory and returns the prior value.
  Xor

  /// Sets memory to the signed-greater of the value provided and the value in memory. Returns the value that was in memory.
  Max

  /// Sets memory to the signed-lesser of the value provided and the value in memory. Returns the value that was in memory.
  Min

  /// Sets memory to the unsigned-greater of the value provided and the value in memory. Returns the value that was in memory.
  UMax

  /// Sets memory to the unsigned-lesser of the value provided and the value in memory. Returns the value that was in memory.
  UMin

  /// Adds to the float-typed value in memory and returns the prior value.
  FAdd

  /// Subtract a float-typed value off the value in memory and returns the prior value.
  FSub

  /// Sets memory to the greater of the two float-typed values, one provided and one from memory. Returns the value that was in memory.
  FMax

  /// Sets memory to the lesser of the two float-typed values, one provided and one from memory. Returns the value that was in memory.
  FMin

  // TODO: need notes
  UIncWrap

  UDecWrap
} derive(Eq, Show, Hash)

pub fn LLVMAtomicRMWBinOp::into(self: LLVMAtomicRMWBinOp) -> AtomicRMWBinOp {
  match self {
    LLVMAtomicRMWBinOpXchg => Xchg
    LLVMAtomicRMWBinOpAdd => Add
    LLVMAtomicRMWBinOpSub => Sub
    LLVMAtomicRMWBinOpAnd => And
    LLVMAtomicRMWBinOpNand => Nand
    LLVMAtomicRMWBinOpOr => Or
    LLVMAtomicRMWBinOpXor => Xor
    LLVMAtomicRMWBinOpMax => Max
    LLVMAtomicRMWBinOpMin => Min
    LLVMAtomicRMWBinOpUMax => UMax
    LLVMAtomicRMWBinOpUMin => UMin
    LLVMAtomicRMWBinOpFAdd => FAdd
    LLVMAtomicRMWBinOpFSub => FSub
    LLVMAtomicRMWBinOpFMax => FMax
    LLVMAtomicRMWBinOpFMin => FMin
    LLVMAtomicRMWBinOpUIncWrap => UIncWrap
    LLVMAtomicRMWBinOpUDecWrap => UDecWrap
  }
}

pub fn AtomicRMWBinOp::into(self: AtomicRMWBinOp) -> LLVMAtomicRMWBinOp {
  match self {
    Xchg => LLVMAtomicRMWBinOpXchg
    Add => LLVMAtomicRMWBinOpAdd
    Sub => LLVMAtomicRMWBinOpSub
    And => LLVMAtomicRMWBinOpAnd
    Nand => LLVMAtomicRMWBinOpNand
    Or => LLVMAtomicRMWBinOpOr
    Xor => LLVMAtomicRMWBinOpXor
    Max => LLVMAtomicRMWBinOpMax
    Min => LLVMAtomicRMWBinOpMin
    UMax => LLVMAtomicRMWBinOpUMax
    UMin => LLVMAtomicRMWBinOpUMin
    FAdd => LLVMAtomicRMWBinOpFAdd
    FSub => LLVMAtomicRMWBinOpFSub
    FMax => LLVMAtomicRMWBinOpFMax
    FMin => LLVMAtomicRMWBinOpFMin
    UIncWrap => LLVMAtomicRMWBinOpUIncWrap
    UDecWrap => LLVMAtomicRMWBinOpUDecWrap
  }
}

pub enum OptimizationLevel {
  None
  Less
  Default
  Aggressive
} derive(Eq, Show, Hash)

// Note: Check if we realy need it
pub fn OptimizationLevel::from_int(i: Int) -> OptimizationLevel {
  match i {
    0 => OptimizationLevel::None
    1 => OptimizationLevel::Less
    2 => OptimizationLevel::Default
    3 => OptimizationLevel::Aggressive
    _ => abort("Invalid OptimizationLevel Number in `OptimizationLevel::from_int`")
  }
}

pub enum Linkage {
    Appending
    AvailableExternally
    Common
    DLLExport
    DLLImport
    External
    ExternalWeak
    Ghost
    Internal
    LinkerPrivate
    LinkerPrivateWeak
    LinkOnceAny
    LinkOnceODRAutoHide
    LinkOnceODR
    Private
    WeakAny
    WeakODR
}

pub fn LLVMLinkage::into(self: LLVMLinkage) -> Linkage {
  match self {
    LLVMExternalLinkage => External
    LLVMAvailableExternallyLinkage => AvailableExternally
    LLVMLinkOnceAnyLinkage => LinkOnceAny
    LLVMLinkOnceODRLinkage => LinkOnceODR
    LLVMLinkOnceODRAutoHideLinkage => LinkOnceODRAutoHide
    LLVMWeakAnyLinkage => WeakAny
    LLVMWeakODRLinkage => WeakODR
    LLVMAppendingLinkage => Appending
    LLVMInternalLinkage => Internal
    LLVMPrivateLinkage => Private
    LLVMDLLImportLinkage => DLLImport
    LLVMDLLExportLinkage => DLLExport
    LLVMExternalWeakLinkage => ExternalWeak
    LLVMGhostLinkage => Ghost
    LLVMCommonLinkage => Common
    LLVMLinkerPrivateLinkage => LinkerPrivate
    LLVMLinkerPrivateWeakLinkage => LinkerPrivateWeak
  }
}

pub fn Linkage::into(self: Linkage) -> LLVMLinkage {
  match self {
    External => LLVMExternalLinkage
    AvailableExternally => LLVMAvailableExternallyLinkage
    LinkOnceAny => LLVMLinkOnceAnyLinkage
    LinkOnceODR => LLVMLinkOnceODRLinkage
    LinkOnceODRAutoHide => LLVMLinkOnceODRAutoHideLinkage
    WeakAny => LLVMWeakAnyLinkage
    WeakODR => LLVMWeakODRLinkage
    Appending => LLVMAppendingLinkage
    Internal => LLVMInternalLinkage
    Private => LLVMPrivateLinkage
    DLLImport => LLVMDLLImportLinkage
    DLLExport => LLVMDLLExportLinkage
    ExternalWeak => LLVMExternalWeakLinkage
    Ghost => LLVMGhostLinkage
    Common => LLVMCommonLinkage
    LinkerPrivate => LLVMLinkerPrivateLinkage
    LinkerPrivateWeak => LLVMLinkerPrivateWeakLinkage
  }
}


pub enum GlobalVisibility {
  Default

  Hidden

  Protected
} derive(Eq, Show, Hash)

pub fn LLVMVisibility::into(self: LLVMVisibility) -> GlobalVisibility {
  match self {
    LLVMDefaultVisibility => Default
    LLVMHiddenVisibility => Hidden
    LLVMProtectedVisibility => Protected
  }
}

pub fn GlobalVisibility::into(self: GlobalVisibility) -> LLVMVisibility {
  match self {
    Default => LLVMDefaultVisibility
    Hidden => LLVMHiddenVisibility
    Protected => LLVMProtectedVisibility
  }
}

pub enum ThreadLocalMode {
  NotThreadLocal

  GeneralDynamic

  LocalDynamic

  InitialExec

  LocalExec
} derive(Eq, Show, Hash)

pub fn LLVMThreadLocalMode::into(self: LLVMThreadLocalMode) -> ThreadLocalMode {
  match self {
    LLVMNotThreadLocal => NotThreadLocal
    LLVMGeneralDynamicTLSModel => GeneralDynamic
    LLVMLocalDynamicTLSModel => LocalDynamic
    LLVMInitialExecTLSModel => InitialExec
    LLVMLocalExecTLSModel => LocalExec
  }
}

pub fn ThreadLocalMode::into(self: ThreadLocalMode) -> LLVMThreadLocalMode {
  match self {
    NotThreadLocal => LLVMNotThreadLocal
    GeneralDynamic => LLVMGeneralDynamicTLSModel
    LocalDynamic => LLVMLocalDynamicTLSModel
    InitialExec => LLVMInitialExecTLSModel
    LocalExec => LLVMLocalExecTLSModel
  }
}

pub enum UnnamedAddress {
  None
  Local
  Global
} derive(Show, Eq)

pub fn LLVMUnnamedAddr::into(self: LLVMUnnamedAddr) -> UnnamedAddress {
  match self {
    LLVMNoUnnamedAddr => None
    LLVMLocalUnnamedAddr => Local
    LLVMGlobalUnnamedAddr => Global
  }
}

pub fn UnnamedAddress::into(self: UnnamedAddress) -> LLVMUnnamedAddr {
  match self {
    None => LLVMNoUnnamedAddr
    Local => LLVMLocalUnnamedAddr
    Global => LLVMGlobalUnnamedAddr
  }
}


pub enum DLLStorageClass {
  Default

  DLLImport

  DLLExport
} derive(Eq, Show, Hash)

pub fn LLVMDLLStorageClass::into(self: LLVMDLLStorageClass) -> DLLStorageClass {
  match self {
    LLVMDefaultStorageClass => Default
    LLVMDLLImportStorageClass => DLLImport
    LLVMDLLExportStorageClass => DLLExport
  }
}

pub fn DLLStorageClass::into(self: DLLStorageClass) -> LLVMDLLStorageClass {
  match self {
    Default => LLVMDefaultStorageClass
    DLLImport => LLVMDLLImportStorageClass
    DLLExport => LLVMDLLExportStorageClass
  }
}

pub enum InlineAsmDialect {
  ATT
  Intel
} derive(Eq, Show, Hash)

pub fn LLVMInlineAsmDialect::into(self: LLVMInlineAsmDialect) -> InlineAsmDialect {
  match self {
    LLVMInlineAsmDialectATT => ATT
    LLVMInlineAsmDialectIntel => Intel
  }
}

pub fn InlineAsmDialect::into(self: InlineAsmDialect) -> LLVMInlineAsmDialect {
  match self {
    ATT => LLVMInlineAsmDialectATT
    Intel => LLVMInlineAsmDialectIntel
  }
}

pub enum FlagBehavior {
  Error
  Warning
  Require
  Override
  Append
  AppendUnique
}

pub fn LLVMModuleFlagBehavior::into(self: LLVMModuleFlagBehavior) -> FlagBehavior {
  match self {
    LLVMModuleFlagBehaviorError => Error
    LLVMModuleFlagBehaviorWarning => Warning
    LLVMModuleFlagBehaviorRequire => Require
    LLVMModuleFlagBehaviorOverride => Override
    LLVMModuleFlagBehaviorAppend => Append
    LLVMModuleFlagBehaviorAppendUnique => AppendUnique
  }
}

pub fn FlagBehavior::into(self: FlagBehavior) -> LLVMModuleFlagBehavior {
  match self {
    Error => LLVMModuleFlagBehaviorError
    Warning => LLVMModuleFlagBehaviorWarning
    Require => LLVMModuleFlagBehaviorRequire
    Override => LLVMModuleFlagBehaviorOverride
    Append => LLVMModuleFlagBehaviorAppend
    AppendUnique => LLVMModuleFlagBehaviorAppendUnique
  }
}
