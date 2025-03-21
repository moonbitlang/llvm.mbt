// extern types

pub type AddressSpace UInt derive(Eq, Show, Default)
pub type FastMathFlags UInt derive(Eq)

pub fn AddressSpace::into(self: AddressSpace) -> UInt {
  guard self is AddressSpace(val);
  val
}

pub fn FastMathFlags::into(self: FastMathFlags) -> @unsafe.LLVMFastMathFlags {
  guard self is FastMathFlags(f)
  @unsafe.LLVMFastMathFlags(f)
}

pub fn FastMathFlags::from(f: @unsafe.LLVMFastMathFlags) -> FastMathFlags {
  guard f is @unsafe.LLVMFastMathFlags(u)
  FastMathFlags(u)
}

///| IntPredicate is used for integer comparisons.
///
/// # Items
///
/// - EQ : Equal.
/// - NE : Not equal.
/// - UGT : Unsigned greater than.
/// - UGE : Unsigned greater than or equal.
/// - ULT : Unsigned less than.
/// - ULE : Unsigned less than or equal.
/// - SGT : Signed greater than.
/// - SGE : Signed greater than or equal.
/// - SLT : Signed less than.
/// - SLE : Signed less than or equal.
pub(all) enum IntPredicate {
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

///| Convert From `@unsafe.LLVMIntPredicate` to `IntPredicate`
pub fn IntPredicate::from(p: @unsafe.LLVMIntPredicate) -> IntPredicate {
  match p {
    @unsafe.LLVMIntEQ => EQ
    @unsafe.LLVMIntNE => NE
    @unsafe.LLVMIntUGT => UGT
    @unsafe.LLVMIntUGE => UGE
    @unsafe.LLVMIntULT => ULT
    @unsafe.LLVMIntULE => ULE
    @unsafe.LLVMIntSGT => SGT
    @unsafe.LLVMIntSGE => SGE
    @unsafe.LLVMIntSLT => SLT
    @unsafe.LLVMIntSLE => SLE
  }
}

///| Convert From `IntPredicate` to `@unsafe.LLVMIntPredicate`
pub fn IntPredicate::into(self: IntPredicate) -> @unsafe.LLVMIntPredicate {
  match self {
    EQ => @unsafe.LLVMIntEQ
    NE => @unsafe.LLVMIntNE
    UGT => @unsafe.LLVMIntUGT
    UGE => @unsafe.LLVMIntUGE
    ULT => @unsafe.LLVMIntULT
    ULE => @unsafe.LLVMIntULE
    SGT => @unsafe.LLVMIntSGT
    SGE => @unsafe.LLVMIntSGE
    SLT => @unsafe.LLVMIntSLT
    SLE => @unsafe.LLVMIntSLE
  }
}

///| FloatPredicate is used for floating point comparisons.
///
/// # Items
///
/// - OEQ : Ordered and equal, returns true if `left` == `right` and neither are NaN.
/// - OGT : Ordered and greater than, returns true if `left` > `right` and neither are NaN.
/// - OGE : Ordered and greater than or equal, returns true if `left` >= `right` and neither are NaN.
/// - OLT : Ordered and less than, returns true if `left` < `right` and neither are NaN.
/// - OLE : Ordered and less than or equal, returns true if `left` <= `right` and neither are NaN.
/// - ONE : Ordered and not equal, returns true if `left` != `right` and neither are NaN.
/// - ORD : Ordered , returns true if neither value is NaN.
/// - PredicateFalse : Always returns false.
/// - PredicateTrue : Always returns true.
/// - UEQ: Unordered or equal, returns true if `left` == `right` or either is NaN.
/// - UGE: Unordered or greater than or equal, returns true if `left` >= `right` or either is NaN.
/// - UGT: Unordered or greater than, returns true if `left` > `right` or either is NaN.
/// - ULT: Unordered or less than, returns true if `left` < `right` or either is NaN.
/// - ULE: Unordered or less than or equal, returns true if `left` <= `right` or either is NaN.
/// - UNE: Unordered or not equal, returns true if `left` != `right` or either is NaN.
pub(all) enum FloatPredicate {
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

///| Convert From `@unsafe.LLVMRealPredicate` to `FloatPredicate`
fn FloatPredicate::from(p: @unsafe.LLVMRealPredicate) -> FloatPredicate {
  match p {
    @unsafe.LLVMRealPredicateFalse => FloatPredicate::PredicateFalse
    @unsafe.LLVMRealOEQ => OEQ
    @unsafe.LLVMRealOGT => OGT
    @unsafe.LLVMRealOGE => OGE
    @unsafe.LLVMRealOLT => OLT
    @unsafe.LLVMRealOLE => OLE
    @unsafe.LLVMRealONE => ONE
    @unsafe.LLVMRealORD => ORD
    @unsafe.LLVMRealUNO => UNO
    @unsafe.LLVMRealUEQ => UEQ
    @unsafe.LLVMRealUGT => UGT
    @unsafe.LLVMRealUGE => UGE
    @unsafe.LLVMRealULT => ULT
    @unsafe.LLVMRealULE => ULE
    @unsafe.LLVMRealUNE => UNE
    @unsafe.LLVMRealPredicateTrue => FloatPredicate::PredicateTrue
  }
}

///| Convert From `FloatPredicate` to `@unsafe.LLVMRealPredicate`
fn FloatPredicate::into(self: FloatPredicate) -> @unsafe.LLVMRealPredicate {
  match self {
    FloatPredicate::PredicateFalse => @unsafe.LLVMRealPredicateFalse
    OEQ => @unsafe.LLVMRealOEQ
    OGT => @unsafe.LLVMRealOGT
    OGE => @unsafe.LLVMRealOGE
    OLT => @unsafe.LLVMRealOLT
    OLE => @unsafe.LLVMRealOLE
    ONE => @unsafe.LLVMRealONE
    ORD => @unsafe.LLVMRealORD
    UNO => @unsafe.LLVMRealUNO
    UEQ => @unsafe.LLVMRealUEQ
    UGT => @unsafe.LLVMRealUGT
    UGE => @unsafe.LLVMRealUGE
    ULT => @unsafe.LLVMRealULT
    ULE => @unsafe.LLVMRealULE
    UNE => @unsafe.LLVMRealUNE
    FloatPredicate::PredicateTrue => @unsafe.LLVMRealPredicateTrue
  }
}


pub(all) enum InstructionOpcode {
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

pub fn InstructionOpcode::from(code: @unsafe.LLVMOpcode) -> InstructionOpcode {
  match code {
    @unsafe.LLVMRet => Return
    @unsafe.LLVMBr => Br
    @unsafe.LLVMSwitch => Switch
    @unsafe.LLVMIndirectBr => IndirectBr
    @unsafe.LLVMInvoke => Invoke
    @unsafe.LLVMResume => Resume
    @unsafe.LLVMLandingPad => LandingPad
    @unsafe.LLVMCatchPad => CatchPad
    @unsafe.LLVMCleanupPad => CleanupPad
    @unsafe.LLVMCatchRet => CatchRet
    @unsafe.LLVMCleanupRet => CleanupRet
    @unsafe.LLVMCatchSwitch => CatchSwitch
    @unsafe.LLVMAdd => Add
    @unsafe.LLVMFAdd => FAdd
    @unsafe.LLVMSub => Sub
    @unsafe.LLVMFSub => FSub
    @unsafe.LLVMMul => Mul
    @unsafe.LLVMFMul => FMul
    @unsafe.LLVMUDiv => UDiv
    @unsafe.LLVMSDiv => SDiv
    @unsafe.LLVMFDiv => FDiv
    @unsafe.LLVMURem => URem
    @unsafe.LLVMSRem => SRem
    @unsafe.LLVMFRem => FRem
    @unsafe.LLVMShl => Shl
    @unsafe.LLVMLShr => LShr
    @unsafe.LLVMAShr => AShr
    @unsafe.LLVMAnd => And
    @unsafe.LLVMOr => Or
    @unsafe.LLVMXor => Xor
    @unsafe.LLVMAlloca => Alloca
    @unsafe.LLVMLoad => Load
    @unsafe.LLVMStore => Store
    @unsafe.LLVMGetElementPtr => GetElementPtr
    @unsafe.LLVMFence => Fence
    @unsafe.LLVMAtomicCmpXchg => AtomicCmpXchg
    @unsafe.LLVMAtomicRMW => AtomicRMW
    @unsafe.LLVMTrunc => Trunc
    @unsafe.LLVMZExt => ZExt
    @unsafe.LLVMSExt => SExt
    @unsafe.LLVMFPToUI => FPToUI
    @unsafe.LLVMFPToSI => FPToSI
    @unsafe.LLVMUIToFP => UIToFP
    @unsafe.LLVMSIToFP => SIToFP
    @unsafe.LLVMFPTrunc => FPTrunc
    @unsafe.LLVMFPExt => FPExt
    @unsafe.LLVMPtrToInt => PtrToInt
    @unsafe.LLVMIntToPtr => IntToPtr
    @unsafe.LLVMBitCast => BitCast
    @unsafe.LLVMAddrSpaceCast => AddrSpaceCast
    @unsafe.LLVMICmp => ICmp
    @unsafe.LLVMFCmp => FCmp
    @unsafe.LLVMPHI => Phi
    @unsafe.LLVMCall => Call
    @unsafe.LLVMCallBr => CallBr
    @unsafe.LLVMFNeg => FNeg
    @unsafe.LLVMExtractElement => ExtractElement
    @unsafe.LLVMExtractValue => ExtractValue
    @unsafe.LLVMFreeze => Freeze
    @unsafe.LLVMInsertElement => InsertElement
    @unsafe.LLVMInsertValue => InsertValue
    @unsafe.LLVMSelect => Select
    @unsafe.LLVMShuffleVector => ShuffleVector
    @unsafe.LLVMUnreachable => Unreachable
    @unsafe.LLVMUserOp1 => UserOp1
    @unsafe.LLVMUserOp2 => UserOp2
    @unsafe.LLVMVAArg => VAArg
  }
}

pub fn InstructionOpcode::into(self: InstructionOpcode) -> @unsafe.LLVMOpcode {
  match self {
    Return => @unsafe.LLVMRet
    Br => @unsafe.LLVMBr
    Switch => @unsafe.LLVMSwitch
    IndirectBr => @unsafe.LLVMIndirectBr
    Invoke => @unsafe.LLVMInvoke
    Resume => @unsafe.LLVMResume
    LandingPad => @unsafe.LLVMLandingPad
    CatchPad => @unsafe.LLVMCatchPad
    CleanupPad => @unsafe.LLVMCleanupPad
    CatchRet => @unsafe.LLVMCatchRet
    CleanupRet => @unsafe.LLVMCleanupRet
    CatchSwitch => @unsafe.LLVMCatchSwitch
    Add => @unsafe.LLVMAdd
    FAdd => @unsafe.LLVMFAdd
    Sub => @unsafe.LLVMSub
    FSub => @unsafe.LLVMFSub
    Mul => @unsafe.LLVMMul
    FMul => @unsafe.LLVMFMul
    UDiv => @unsafe.LLVMUDiv
    SDiv => @unsafe.LLVMSDiv
    FDiv => @unsafe.LLVMFDiv
    URem => @unsafe.LLVMURem
    SRem => @unsafe.LLVMSRem
    FRem => @unsafe.LLVMFRem
    Shl => @unsafe.LLVMShl
    LShr => @unsafe.LLVMLShr
    AShr => @unsafe.LLVMAShr
    And => @unsafe.LLVMAnd
    Or => @unsafe.LLVMOr
    Xor => @unsafe.LLVMXor
    Alloca => @unsafe.LLVMAlloca
    Load => @unsafe.LLVMLoad
    Store => @unsafe.LLVMStore
    GetElementPtr => @unsafe.LLVMGetElementPtr
    Fence => @unsafe.LLVMFence
    AtomicCmpXchg => @unsafe.LLVMAtomicCmpXchg
    AtomicRMW => @unsafe.LLVMAtomicRMW
    Trunc => @unsafe.LLVMTrunc
    ZExt => @unsafe.LLVMZExt
    SExt => @unsafe.LLVMSExt
    FPToUI => @unsafe.LLVMFPToUI
    FPToSI => @unsafe.LLVMFPToSI
    UIToFP => @unsafe.LLVMUIToFP
    SIToFP => @unsafe.LLVMSIToFP
    FPTrunc => @unsafe.LLVMFPTrunc
    FPExt => @unsafe.LLVMFPExt
    PtrToInt => @unsafe.LLVMPtrToInt
    IntToPtr => @unsafe.LLVMIntToPtr
    BitCast => @unsafe.LLVMBitCast
    AddrSpaceCast => @unsafe.LLVMAddrSpaceCast
    ICmp => @unsafe.LLVMICmp
    FCmp => @unsafe.LLVMFCmp
    Phi => @unsafe.LLVMPHI
    Call => @unsafe.LLVMCall
    CallBr => @unsafe.LLVMCallBr
    FNeg => @unsafe.LLVMFNeg
    ExtractElement => @unsafe.LLVMExtractElement
    ExtractValue => @unsafe.LLVMExtractValue
    Freeze => @unsafe.LLVMFreeze
    InsertElement => @unsafe.LLVMInsertElement
    InsertValue => @unsafe.LLVMInsertValue
    Select => @unsafe.LLVMSelect
    ShuffleVector => @unsafe.LLVMShuffleVector
    Unreachable => @unsafe.LLVMUnreachable
    UserOp1 => @unsafe.LLVMUserOp1
    UserOp2 => @unsafe.LLVMUserOp2
    VAArg => @unsafe.LLVMVAArg
  }
}

pub(all) enum AtomicOrdering {
  NotAtomic

  Unordered

  Monotonic

  Acquire

  Release

  AcquireRelease

  SequentiallyConsistent
} derive(Eq, Show, Hash)

pub fn AtomicOrdering::from(aord: @unsafe.LLVMAtomicOrdering) -> AtomicOrdering {
  match aord {
    @unsafe.LLVMAtomicOrderingNotAtomic => NotAtomic
    @unsafe.LLVMAtomicOrderingUnordered => Unordered
    @unsafe.LLVMAtomicOrderingMonotonic => Monotonic
    @unsafe.LLVMAtomicOrderingAcquire => Acquire
    @unsafe.LLVMAtomicOrderingRelease => Release
    @unsafe.LLVMAtomicOrderingAcquireRelease => AcquireRelease
    @unsafe.LLVMAtomicOrderingSequentiallyConsistent => SequentiallyConsistent
  }
}

pub fn AtomicOrdering::into(self: AtomicOrdering) -> @unsafe.LLVMAtomicOrdering {
  match self {
    NotAtomic => @unsafe.LLVMAtomicOrderingNotAtomic
    Unordered => @unsafe.LLVMAtomicOrderingUnordered
    Monotonic => @unsafe.LLVMAtomicOrderingMonotonic
    Acquire => @unsafe.LLVMAtomicOrderingAcquire
    Release => @unsafe.LLVMAtomicOrderingRelease
    AcquireRelease => @unsafe.LLVMAtomicOrderingAcquireRelease
    SequentiallyConsistent => @unsafe.LLVMAtomicOrderingSequentiallyConsistent
  }
}

pub(all) enum AtomicRMWBinOp {
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

pub fn AtomicRMWBinOp::from(op: @unsafe.LLVMAtomicRMWBinOp) -> AtomicRMWBinOp {
  match op {
    @unsafe.LLVMAtomicRMWBinOpXchg => Xchg
    @unsafe.LLVMAtomicRMWBinOpAdd => Add
    @unsafe.LLVMAtomicRMWBinOpSub => Sub
    @unsafe.LLVMAtomicRMWBinOpAnd => And
    @unsafe.LLVMAtomicRMWBinOpNand => Nand
    @unsafe.LLVMAtomicRMWBinOpOr => Or
    @unsafe.LLVMAtomicRMWBinOpXor => Xor
    @unsafe.LLVMAtomicRMWBinOpMax => Max
    @unsafe.LLVMAtomicRMWBinOpMin => Min
    @unsafe.LLVMAtomicRMWBinOpUMax => UMax
    @unsafe.LLVMAtomicRMWBinOpUMin => UMin
    @unsafe.LLVMAtomicRMWBinOpFAdd => FAdd
    @unsafe.LLVMAtomicRMWBinOpFSub => FSub
    @unsafe.LLVMAtomicRMWBinOpFMax => FMax
    @unsafe.LLVMAtomicRMWBinOpFMin => FMin
    @unsafe.LLVMAtomicRMWBinOpUIncWrap => UIncWrap
    @unsafe.LLVMAtomicRMWBinOpUDecWrap => UDecWrap
  }
}

pub fn AtomicRMWBinOp::into(self: AtomicRMWBinOp) -> @unsafe.LLVMAtomicRMWBinOp {
  match self {
    Xchg => @unsafe.LLVMAtomicRMWBinOpXchg
    Add => @unsafe.LLVMAtomicRMWBinOpAdd
    Sub => @unsafe.LLVMAtomicRMWBinOpSub
    And => @unsafe.LLVMAtomicRMWBinOpAnd
    Nand => @unsafe.LLVMAtomicRMWBinOpNand
    Or => @unsafe.LLVMAtomicRMWBinOpOr
    Xor => @unsafe.LLVMAtomicRMWBinOpXor
    Max => @unsafe.LLVMAtomicRMWBinOpMax
    Min => @unsafe.LLVMAtomicRMWBinOpMin
    UMax => @unsafe.LLVMAtomicRMWBinOpUMax
    UMin => @unsafe.LLVMAtomicRMWBinOpUMin
    FAdd => @unsafe.LLVMAtomicRMWBinOpFAdd
    FSub => @unsafe.LLVMAtomicRMWBinOpFSub
    FMax => @unsafe.LLVMAtomicRMWBinOpFMax
    FMin => @unsafe.LLVMAtomicRMWBinOpFMin
    UIncWrap => @unsafe.LLVMAtomicRMWBinOpUIncWrap
    UDecWrap => @unsafe.LLVMAtomicRMWBinOpUDecWrap
  }
}

pub(all) enum OptimizationLevel {
  None
  Less
  Default
  Aggressive
} derive(Eq, Show, Hash)

// Note: Check if we really need it
pub fn OptimizationLevel::from_int(i: Int) -> OptimizationLevel {
  match i {
    0 => OptimizationLevel::None
    1 => OptimizationLevel::Less
    2 => OptimizationLevel::Default
    3 => OptimizationLevel::Aggressive
    _ => abort("Invalid OptimizationLevel Number in `OptimizationLevel::from_int`")
  }
}

pub(all) enum Linkage {
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
} derive(Show)

pub fn Linkage::from(linkage: @unsafe.LLVMLinkage) -> Linkage {
  match linkage {
    @unsafe.LLVMExternalLinkage => External
    @unsafe.LLVMAvailableExternallyLinkage => AvailableExternally
    @unsafe.LLVMLinkOnceAnyLinkage => LinkOnceAny
    @unsafe.LLVMLinkOnceODRLinkage => LinkOnceODR
    @unsafe.LLVMLinkOnceODRAutoHideLinkage => LinkOnceODRAutoHide
    @unsafe.LLVMWeakAnyLinkage => WeakAny
    @unsafe.LLVMWeakODRLinkage => WeakODR
    @unsafe.LLVMAppendingLinkage => Appending
    @unsafe.LLVMInternalLinkage => Internal
    @unsafe.LLVMPrivateLinkage => Private
    @unsafe.LLVMDLLImportLinkage => DLLImport
    @unsafe.LLVMDLLExportLinkage => DLLExport
    @unsafe.LLVMExternalWeakLinkage => ExternalWeak
    @unsafe.LLVMGhostLinkage => Ghost
    @unsafe.LLVMCommonLinkage => Common
    @unsafe.LLVMLinkerPrivateLinkage => LinkerPrivate
    @unsafe.LLVMLinkerPrivateWeakLinkage => LinkerPrivateWeak
  }
}

pub fn Linkage::into(self: Linkage) -> @unsafe.LLVMLinkage {
  match self {
    External => @unsafe.LLVMExternalLinkage
    AvailableExternally => @unsafe.LLVMAvailableExternallyLinkage
    LinkOnceAny => @unsafe.LLVMLinkOnceAnyLinkage
    LinkOnceODR => @unsafe.LLVMLinkOnceODRLinkage
    LinkOnceODRAutoHide => @unsafe.LLVMLinkOnceODRAutoHideLinkage
    WeakAny => @unsafe.LLVMWeakAnyLinkage
    WeakODR => @unsafe.LLVMWeakODRLinkage
    Appending => @unsafe.LLVMAppendingLinkage
    Internal => @unsafe.LLVMInternalLinkage
    Private => @unsafe.LLVMPrivateLinkage
    DLLImport => @unsafe.LLVMDLLImportLinkage
    DLLExport => @unsafe.LLVMDLLExportLinkage
    ExternalWeak => @unsafe.LLVMExternalWeakLinkage
    Ghost => @unsafe.LLVMGhostLinkage
    Common => @unsafe.LLVMCommonLinkage
    LinkerPrivate => @unsafe.LLVMLinkerPrivateLinkage
    LinkerPrivateWeak => @unsafe.LLVMLinkerPrivateWeakLinkage
  }
}


pub(all) enum GlobalVisibility {
  Default

  Hidden

  Protected
} derive(Eq, Show, Hash)

pub fn GlobalVisibility::from(v: @unsafe.LLVMVisibility) -> GlobalVisibility {
  match v {
    @unsafe.LLVMDefaultVisibility => Default
    @unsafe.LLVMHiddenVisibility => Hidden
    @unsafe.LLVMProtectedVisibility => Protected
  }
}

pub fn GlobalVisibility::into(self: GlobalVisibility) -> @unsafe.LLVMVisibility {
  match self {
    Default => @unsafe.LLVMDefaultVisibility
    Hidden => @unsafe.LLVMHiddenVisibility
    Protected => @unsafe.LLVMProtectedVisibility
  }
}

pub(all) enum ThreadLocalMode {
  NotThreadLocal

  GeneralDynamic

  LocalDynamic

  InitialExec

  LocalExec
} derive(Eq, Show, Hash)

pub fn ThreadLocalMode::from(self: @unsafe.LLVMThreadLocalMode) -> ThreadLocalMode {
  match self {
    @unsafe.LLVMNotThreadLocal => NotThreadLocal
    @unsafe.LLVMGeneralDynamicTLSModel => GeneralDynamic
    @unsafe.LLVMLocalDynamicTLSModel => LocalDynamic
    @unsafe.LLVMInitialExecTLSModel => InitialExec
    @unsafe.LLVMLocalExecTLSModel => LocalExec
  }
}

pub fn ThreadLocalMode::into(self: ThreadLocalMode) -> @unsafe.LLVMThreadLocalMode {
  match self {
    NotThreadLocal => @unsafe.LLVMNotThreadLocal
    GeneralDynamic => @unsafe.LLVMGeneralDynamicTLSModel
    LocalDynamic => @unsafe.LLVMLocalDynamicTLSModel
    InitialExec => @unsafe.LLVMInitialExecTLSModel
    LocalExec => @unsafe.LLVMLocalExecTLSModel
  }
}

pub(all) enum UnnamedAddress {
  None
  Local
  Global
} derive(Show, Eq)

pub fn UnnamedAddress::from(uaddr: @unsafe.LLVMUnnamedAddr) -> UnnamedAddress {
  match uaddr {
    @unsafe.LLVMNoUnnamedAddr => None
    @unsafe.LLVMLocalUnnamedAddr => Local
    @unsafe.LLVMGlobalUnnamedAddr => Global
  }
}

pub fn UnnamedAddress::into(self: UnnamedAddress) -> @unsafe.LLVMUnnamedAddr {
  match self {
    None => @unsafe.LLVMNoUnnamedAddr
    Local => @unsafe.LLVMLocalUnnamedAddr
    Global => @unsafe.LLVMGlobalUnnamedAddr
  }
}


pub(all) enum DLLStorageClass {
  Default

  DLLImport

  DLLExport
} derive(Eq, Show, Hash)

pub fn DLLStorageClass::from(d: @unsafe.LLVMDLLStorageClass) -> DLLStorageClass {
  match d {
    @unsafe.LLVMDefaultStorageClass => Default
    @unsafe.LLVMDLLImportStorageClass => DLLImport
    @unsafe.LLVMDLLExportStorageClass => DLLExport
  }
}

pub fn DLLStorageClass::into(self: DLLStorageClass) -> @unsafe.LLVMDLLStorageClass {
  match self {
    Default => @unsafe.LLVMDefaultStorageClass
    DLLImport => @unsafe.LLVMDLLImportStorageClass
    DLLExport => @unsafe.LLVMDLLExportStorageClass
  }
}

pub(all) enum InlineAsmDialect {
  ATT
  Intel
} derive(Eq, Show, Hash)

pub fn InlineAsmDialect::from(d: @unsafe.LLVMInlineAsmDialect) -> InlineAsmDialect {
  match d {
    @unsafe.LLVMInlineAsmDialectATT => ATT
    @unsafe.LLVMInlineAsmDialectIntel => Intel
  }
}

pub fn InlineAsmDialect::into(self: InlineAsmDialect) -> @unsafe.LLVMInlineAsmDialect {
  match self {
    ATT => @unsafe.LLVMInlineAsmDialectATT
    Intel => @unsafe.LLVMInlineAsmDialectIntel
  }
}

pub(all) enum FlagBehavior {
  Error
  Warning
  Require
  Override
  Append
  AppendUnique
}

pub fn FlagBehavior::from(fb: @unsafe.LLVMModuleFlagBehavior) -> FlagBehavior {
  match fb {
    @unsafe.LLVMModuleFlagBehaviorError => Error
    @unsafe.LLVMModuleFlagBehaviorWarning => Warning
    @unsafe.LLVMModuleFlagBehaviorRequire => Require
    @unsafe.LLVMModuleFlagBehaviorOverride => Override
    @unsafe.LLVMModuleFlagBehaviorAppend => Append
    @unsafe.LLVMModuleFlagBehaviorAppendUnique => AppendUnique
  }
}

pub fn FlagBehavior::into(self: FlagBehavior) -> @unsafe.LLVMModuleFlagBehavior {
  match self {
    Error => @unsafe.LLVMModuleFlagBehaviorError
    Warning => @unsafe.LLVMModuleFlagBehaviorWarning
    Require => @unsafe.LLVMModuleFlagBehaviorRequire
    Override => @unsafe.LLVMModuleFlagBehaviorOverride
    Append => @unsafe.LLVMModuleFlagBehaviorAppend
    AppendUnique => @unsafe.LLVMModuleFlagBehaviorAppendUnique
  }
}

pub(all) enum ComdatSelectionKind {
  /// The linker may choose any COMDAT.
  Any

  /// The data referenced by the COMDAT must be the same.
  ExactMatch

  /// The linker will choose the largest COMDAT.
  Largest

  /// No other Module may specify this COMDAT.
  NoDuplicates

  /// The data referenced by the COMDAT must be the same size.
  SameSize
}

pub fn ComdatSelectionKind::from(csk: @unsafe.LLVMComdatSelectionKind) -> ComdatSelectionKind {
  match csk {
    @unsafe.LLVMAnyComdatSelectionKind => Any
    @unsafe.LLVMExactMatchComdatSelectionKind => ExactMatch
    @unsafe.LLVMLargestComdatSelectionKind => Largest
    @unsafe.LLVMNoDeduplicateComdatSelectionKind => NoDuplicates
    @unsafe.LLVMSameSizeComdatSelectionKind => SameSize
  }
}

pub fn ComdatSelectionKind::into(self: ComdatSelectionKind) -> @unsafe.LLVMComdatSelectionKind {
  match self {
    Any => @unsafe.LLVMAnyComdatSelectionKind
    ExactMatch => @unsafe.LLVMExactMatchComdatSelectionKind
    Largest => @unsafe.LLVMLargestComdatSelectionKind
    NoDuplicates => @unsafe.LLVMNoDeduplicateComdatSelectionKind
    SameSize => @unsafe.LLVMSameSizeComdatSelectionKind
  }
}
