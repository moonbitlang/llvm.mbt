// LLVMTypes
///|
type LLVMBool Int derive(Eq)

///|
pub(all) type LLVMAttributeIndex UInt derive(Eq)

///|
pub(all) type LLVMFastMathFlags UInt derive(Eq)

///|
pub(all) type LLVMDWARFTypeEncoding UInt derive(Eq)

///|
pub(all) type LLVMMetadataKind UInt derive(Eq)

// Dummy function just for eliminating the warning

///|
pub fn LLVMAttributeIndex::new(idx : UInt) -> LLVMAttributeIndex {
  LLVMAttributeIndex(idx)
}
// Dummy function just for eliminating the warning

///|
pub fn LLVMFastMathFlags::new(idx : UInt) -> LLVMFastMathFlags {
  LLVMFastMathFlags(idx)
}

// Dummy function just for eliminating the warning

///|
pub fn LLVMDWARFTypeEncoding::new(idx : UInt) -> LLVMDWARFTypeEncoding {
  LLVMDWARFTypeEncoding(idx)
}

// Dummy function just for eliminating the warning

///|
pub fn LLVMMetadataKind::new(idx : UInt) -> LLVMMetadataKind {
  LLVMMetadataKind(idx)
}

///| llvm memory buffer
#external
pub type LLVMMemoryBufferRef

///| llvm context
#external
pub type LLVMContextRef

///| llvm module
#external
pub type LLVMModuleRef

///| llvm BasicBlock
#external
pub type LLVMBasicBlockRef

///| llvm metadata
#external
pub type LLVMMetadataRef

///| llvm md node
#external
pub type LLVMNamedMDNodeRef

///|
#external
pub type LLVMValueMetadataEntry

///| llvm builder
#external
pub type LLVMBuilderRef

///|
#external
pub type LLVMDIBuilderRef

///| llvm module provider
#external
pub type LLVMModuleProviderRef

///| llvm pass manager
#external
pub type LLVMPassManagerRef

///|
#external
pub type LLVMPassRegistryRef

///| A set of options passed which are attached to the Pass Manager upon run.
/// 
/// This corresponds to an llvm::LLVMPassBuilderOptions instance
/// 
/// The details for how the different properties of this structure are used can
/// be found in the source for LLVMRunPasses
/// 
#external
pub type LLVMPassBuilderOptionsRef

///|
#external
pub type LLVMPassManagerBuilderRef

///| llvm use
#external
pub type LLVMUseRef

///| llvm values
#external
pub type LLVMValueRef

///| llvm types
#external
pub type LLVMTypeRef

///| llvm operand bundles
#external
pub type LLVMOperandBundleRef

///| llvm attributes
#external
pub type LLVMAttributeRef

///| llvm diagnostic info
#external
pub type LLVMDiagnosticInfoRef

///|
#external
pub type LLVMComdatRef

///|
#external
pub type LLVMModuleFlagEntry

///|
#external
pub type LLVMJITEventListenerRef

///|
#external
pub type LLVMBinaryRef

///|
#external
pub type LLVMTargetRef

///|
#external
pub type LLVMTargetMachineOptionsRef

///|
#external
pub type LLVMTargetMachineRef

///| llvm debug record refs
#external
pub type LLVMDbgRecordRef

///|
#external
pub type LLVMGenericValueRef

///|
#external
pub type LVMExecutionEngineRef

///|
#external
pub type LVMMCJITMemoryManagerRef

///|
#external
pub type LLVMRemarkStringRef

///| Opaque reference to an error instance. Null serves as the 'success' value.
#external
pub type LLVMErrorRef

///| Represents an address in the executor process.
pub(all) type LLVMOrcJITTargetAddress UInt64 derive(Show, Eq)

///| Represents an address in the executor process.
pub(all) type LLVMOrcExecutorAddress UInt64 derive(Show, Eq)

// NOTE: It different with real, the real LLVMJITSymbolTargetFlags is uint8

///|
pub(all) type LLVMJITSymbolTargetFlags UInt derive(Show, Eq)

///| A reference to an orc::ExecutionSession instance.
#external
pub type LLVMOrcExecutionSessionRef

///| A reference to an orc::SymbolStringPool.
#external
pub type LLVMOrcSymbolStringPoolRef

///| A reference to an orc::SymbolStringPool table entry.
#external
pub type LLVMOrcSymbolStringPoolEntryRef

///|
pub impl Eq for LLVMTypeRef with op_equal(
  self : LLVMTypeRef,
  other : LLVMTypeRef
) -> Bool {
  self.is_equal(other)
}

///|
pub impl Eq for LLVMValueRef with op_equal(
  self : LLVMValueRef,
  other : LLVMValueRef
) -> Bool {
  self.is_equal(other)
}

///|
pub impl Eq for LLVMContextRef with op_equal(
  self : LLVMContextRef,
  other : LLVMContextRef
) -> Bool {
  self.is_equal(other)
}

///|
pub impl Eq for LLVMAttributeRef with op_equal(
  self : LLVMAttributeRef,
  other : LLVMAttributeRef
) -> Bool {
  self.is_equal(other)
}

///|
pub impl Eq for LLVMBasicBlockRef with op_equal(
  self : LLVMBasicBlockRef,
  other : LLVMBasicBlockRef
) -> Bool {
  self.is_equal(other)
}

///|
pub fn LLVMDWARFTypeEncoding::into(self : LLVMDWARFTypeEncoding) -> UInt {
  guard self is LLVMDWARFTypeEncoding(val)
  val
}

///|
pub fn LLVMMetadataKind::into(self : LLVMMetadataKind) -> UInt {
  guard self is LLVMMetadataKind(val)
  val
}

// enums

///| Instruction opcodes
pub(all) enum LLVMOpcode {
  LLVMRet
  LLVMBr
  LLVMSwitch
  LLVMIndirectBr
  LLVMInvoke
  LLVMUnreachable
  LLVMCallBr
  LLVMFNeg
  LLVMAdd
  LLVMFAdd
  LLVMSub
  LLVMFSub
  LLVMMul
  LLVMFMul
  LLVMUDiv
  LLVMSDiv
  LLVMFDiv
  LLVMURem
  LLVMSRem
  LLVMFRem
  LLVMShl
  LLVMLShr
  LLVMAShr
  LLVMAnd
  LLVMOr
  LLVMXor
  LLVMAlloca
  LLVMLoad
  LLVMStore
  LLVMGetElementPtr
  LLVMTrunc
  LLVMZExt
  LLVMSExt
  LLVMFPToUI
  LLVMFPToSI
  LLVMUIToFP
  LLVMSIToFP
  LLVMFPTrunc
  LLVMFPExt
  LLVMPtrToInt
  LLVMIntToPtr
  LLVMBitCast
  LLVMAddrSpaceCast
  LLVMICmp
  LLVMFCmp
  LLVMPHI
  LLVMCall
  LLVMSelect
  LLVMUserOp1
  LLVMUserOp2
  LLVMVAArg
  LLVMExtractElement
  LLVMInsertElement
  LLVMShuffleVector
  LLVMExtractValue
  LLVMInsertValue
  LLVMFreeze
  LLVMFence
  LLVMAtomicCmpXchg
  LLVMAtomicRMW
  LLVMResume
  LLVMLandingPad
  LLVMCleanupRet
  LLVMCatchRet
  LLVMCatchPad
  LLVMCleanupPad
  LLVMCatchSwitch
}

///|
pub fn LLVMOpcode::to_int(self : LLVMOpcode) -> Int {
  match self {
    LLVMRet => 0
    LLVMBr => 1
    LLVMSwitch => 2
    LLVMIndirectBr => 3
    LLVMInvoke => 4
    LLVMUnreachable => 5
    LLVMCallBr => 6
    LLVMFNeg => 7
    LLVMAdd => 8
    LLVMFAdd => 9
    LLVMSub => 10
    LLVMFSub => 11
    LLVMMul => 12
    LLVMFMul => 13
    LLVMUDiv => 14
    LLVMSDiv => 15
    LLVMFDiv => 16
    LLVMURem => 17
    LLVMSRem => 18
    LLVMFRem => 19
    LLVMShl => 20
    LLVMLShr => 21
    LLVMAShr => 22
    LLVMAnd => 23
    LLVMOr => 24
    LLVMXor => 25
    LLVMAlloca => 26
    LLVMLoad => 27
    LLVMStore => 28
    LLVMGetElementPtr => 29
    LLVMTrunc => 30
    LLVMZExt => 31
    LLVMSExt => 32
    LLVMFPToUI => 33
    LLVMFPToSI => 34
    LLVMUIToFP => 35
    LLVMSIToFP => 36
    LLVMFPTrunc => 37
    LLVMFPExt => 38
    LLVMPtrToInt => 39
    LLVMIntToPtr => 40
    LLVMBitCast => 41
    LLVMAddrSpaceCast => 42
    LLVMICmp => 43
    LLVMFCmp => 44
    LLVMPHI => 45
    LLVMCall => 46
    LLVMSelect => 47
    LLVMUserOp1 => 48
    LLVMUserOp2 => 49
    LLVMVAArg => 50
    LLVMExtractElement => 51
    LLVMInsertElement => 52
    LLVMShuffleVector => 53
    LLVMExtractValue => 54
    LLVMInsertValue => 55
    LLVMFreeze => 56
    LLVMFence => 57
    LLVMAtomicCmpXchg => 58
    LLVMAtomicRMW => 59
    LLVMResume => 60
    LLVMLandingPad => 61
    LLVMCleanupRet => 62
    LLVMCatchRet => 63
    LLVMCatchPad => 64
    LLVMCleanupPad => 65
    LLVMCatchSwitch => 66
  }
}

///|
pub fn LLVMOpcode::from_int(idx : Int) -> LLVMOpcode {
  match idx {
    0 => LLVMRet
    1 => LLVMBr
    2 => LLVMSwitch
    3 => LLVMIndirectBr
    4 => LLVMInvoke
    5 => LLVMUnreachable
    6 => LLVMCallBr
    7 => LLVMFNeg
    8 => LLVMAdd
    9 => LLVMFAdd
    10 => LLVMSub
    11 => LLVMFSub
    12 => LLVMMul
    13 => LLVMFMul
    14 => LLVMUDiv
    15 => LLVMSDiv
    16 => LLVMFDiv
    17 => LLVMURem
    18 => LLVMSRem
    19 => LLVMFRem
    20 => LLVMShl
    21 => LLVMLShr
    22 => LLVMAShr
    23 => LLVMAnd
    24 => LLVMOr
    25 => LLVMXor
    26 => LLVMAlloca
    27 => LLVMLoad
    28 => LLVMStore
    29 => LLVMGetElementPtr
    30 => LLVMTrunc
    31 => LLVMZExt
    32 => LLVMSExt
    33 => LLVMFPToUI
    34 => LLVMFPToSI
    35 => LLVMUIToFP
    36 => LLVMSIToFP
    37 => LLVMFPTrunc
    38 => LLVMFPExt
    39 => LLVMPtrToInt
    40 => LLVMIntToPtr
    41 => LLVMBitCast
    42 => LLVMAddrSpaceCast
    43 => LLVMICmp
    44 => LLVMFCmp
    45 => LLVMPHI
    46 => LLVMCall
    47 => LLVMSelect
    48 => LLVMUserOp1
    49 => LLVMUserOp2
    50 => LLVMVAArg
    51 => LLVMExtractElement
    52 => LLVMInsertElement
    53 => LLVMShuffleVector
    54 => LLVMExtractValue
    55 => LLVMInsertValue
    56 => LLVMFreeze
    57 => LLVMFence
    58 => LLVMAtomicCmpXchg
    59 => LLVMAtomicRMW
    60 => LLVMResume
    61 => LLVMLandingPad
    62 => LLVMCleanupRet
    63 => LLVMCatchRet
    64 => LLVMCatchPad
    65 => LLVMCleanupPad
    66 => LLVMCatchSwitch
    _ => abort("Invalid LLVMOpcode Number in `LLVMOpcode::from_int`")
  }
}

///|
pub(all) enum LLVMTypeKind {
  LLVMVoidTypeKind
  LLVMHalfTypeKind
  LLVMFloatTypeKind
  LLVMDoubleTypeKind
  LLVMX86_FP80TypeKind
  LLVMFP128TypeKind
  LLVMPPC_FP128TypeKind
  LLVMLabelTypeKind
  LLVMIntegerTypeKind
  LLVMFunctionTypeKind
  LLVMStructTypeKind
  LLVMArrayTypeKind
  LLVMPointerTypeKind
  LLVMVectorTypeKind
  LLVMMetadataTypeKind
  LLVMX86_MMXTypeKind
  LLVMTokenTypeKind
  LLVMScalableVectorTypeKind
  LLVMBFloatTypeKind
  LLVMX86_AMXTypeKind
  LLVMTargetExtTypeKind
} derive(Show, Eq)

///|
fn LLVMTypeKind::to_int(self : LLVMTypeKind) -> Int {
  match self {
    LLVMVoidTypeKind => 0
    LLVMHalfTypeKind => 1
    LLVMFloatTypeKind => 2
    LLVMDoubleTypeKind => 3
    LLVMX86_FP80TypeKind => 4
    LLVMFP128TypeKind => 5
    LLVMPPC_FP128TypeKind => 6
    LLVMLabelTypeKind => 7
    LLVMIntegerTypeKind => 8
    LLVMFunctionTypeKind => 9
    LLVMStructTypeKind => 10
    LLVMArrayTypeKind => 11
    LLVMPointerTypeKind => 12
    LLVMVectorTypeKind => 13
    LLVMMetadataTypeKind => 14
    LLVMX86_MMXTypeKind => 15
    LLVMTokenTypeKind => 16
    LLVMScalableVectorTypeKind => 17
    LLVMBFloatTypeKind => 18
    LLVMX86_AMXTypeKind => 19
    LLVMTargetExtTypeKind => 20
  }
}

///|
pub fn LLVMTypeKind::from_int(idx : Int) -> LLVMTypeKind {
  match idx {
    0 => LLVMVoidTypeKind
    1 => LLVMHalfTypeKind
    2 => LLVMFloatTypeKind
    3 => LLVMDoubleTypeKind
    4 => LLVMX86_FP80TypeKind
    5 => LLVMFP128TypeKind
    6 => LLVMPPC_FP128TypeKind
    7 => LLVMLabelTypeKind
    8 => LLVMIntegerTypeKind
    9 => LLVMFunctionTypeKind
    10 => LLVMStructTypeKind
    11 => LLVMArrayTypeKind
    12 => LLVMPointerTypeKind
    13 => LLVMVectorTypeKind
    14 => LLVMMetadataTypeKind
    15 => LLVMX86_MMXTypeKind
    16 => LLVMTokenTypeKind
    17 => LLVMScalableVectorTypeKind
    18 => LLVMBFloatTypeKind
    19 => LLVMX86_AMXTypeKind
    20 => LLVMTargetExtTypeKind
    _ => abort("Invalid LLVMTypeKind Number in `LLVMTypeKind::from_int`")
  }
}

///|
pub(all) enum LLVMLinkage {
  LLVMExternalLinkage
  LLVMAvailableExternallyLinkage
  LLVMLinkOnceAnyLinkage
  LLVMLinkOnceODRLinkage
  LLVMLinkOnceODRAutoHideLinkage
  LLVMWeakAnyLinkage
  LLVMWeakODRLinkage
  LLVMAppendingLinkage
  LLVMInternalLinkage
  LLVMPrivateLinkage
  LLVMDLLImportLinkage
  LLVMDLLExportLinkage
  LLVMExternalWeakLinkage
  LLVMGhostLinkage
  LLVMCommonLinkage
  LLVMLinkerPrivateLinkage
  LLVMLinkerPrivateWeakLinkage
}

///|
fn LLVMLinkage::to_int(self : LLVMLinkage) -> Int {
  match self {
    LLVMExternalLinkage => 0
    LLVMAvailableExternallyLinkage => 1
    LLVMLinkOnceAnyLinkage => 2
    LLVMLinkOnceODRLinkage => 3
    LLVMLinkOnceODRAutoHideLinkage => 4
    LLVMWeakAnyLinkage => 5
    LLVMWeakODRLinkage => 6
    LLVMAppendingLinkage => 7
    LLVMInternalLinkage => 8
    LLVMPrivateLinkage => 9
    LLVMDLLImportLinkage => 10
    LLVMDLLExportLinkage => 11
    LLVMExternalWeakLinkage => 12
    LLVMGhostLinkage => 13
    LLVMCommonLinkage => 14
    LLVMLinkerPrivateLinkage => 15
    LLVMLinkerPrivateWeakLinkage => 16
  }
}

///|
fn LLVMLinkage::from_int(idx : Int) -> LLVMLinkage {
  match idx {
    0 => LLVMExternalLinkage
    1 => LLVMAvailableExternallyLinkage
    2 => LLVMLinkOnceAnyLinkage
    3 => LLVMLinkOnceODRLinkage
    4 => LLVMLinkOnceODRAutoHideLinkage
    5 => LLVMWeakAnyLinkage
    6 => LLVMWeakODRLinkage
    7 => LLVMAppendingLinkage
    8 => LLVMInternalLinkage
    9 => LLVMPrivateLinkage
    10 => LLVMDLLImportLinkage
    11 => LLVMDLLExportLinkage
    12 => LLVMExternalWeakLinkage
    13 => LLVMGhostLinkage
    14 => LLVMCommonLinkage
    15 => LLVMLinkerPrivateLinkage
    16 => LLVMLinkerPrivateWeakLinkage
    _ => abort("Invalid LLVMLinkage Number in `LLVMLinkage::from_int`")
  }
}

///|
pub(all) enum LLVMVisibility {
  LLVMDefaultVisibility
  LLVMHiddenVisibility
  LLVMProtectedVisibility
}

///|
pub fn LLVMVisibility::to_int(self : LLVMVisibility) -> Int {
  match self {
    LLVMDefaultVisibility => 0
    LLVMHiddenVisibility => 1
    LLVMProtectedVisibility => 2
  }
}

///|
pub fn LLVMVisibility::from_int(idx : Int) -> LLVMVisibility {
  match idx {
    0 => LLVMDefaultVisibility
    1 => LLVMHiddenVisibility
    2 => LLVMProtectedVisibility
    _ => abort("Invalid LLVMVisibility Number in `LLVMVisibility::from_int`")
  }
}

///|
pub(all) enum LLVMUnnamedAddr {
  LLVMNoUnnamedAddr
  LLVMLocalUnnamedAddr
  LLVMGlobalUnnamedAddr
} derive(Show, Eq)

///|
pub fn LLVMUnnamedAddr::to_int(self : LLVMUnnamedAddr) -> Int {
  match self {
    LLVMNoUnnamedAddr => 0
    LLVMLocalUnnamedAddr => 1
    LLVMGlobalUnnamedAddr => 2
  }
}

///|
pub fn LLVMUnnamedAddr::from_int(idx : Int) -> LLVMUnnamedAddr {
  match idx {
    0 => LLVMNoUnnamedAddr
    1 => LLVMLocalUnnamedAddr
    2 => LLVMGlobalUnnamedAddr
    _ => abort("Invalid LLVMUnnamedAddr Number in `LLVMUnnamedAddr::from_int`")
  }
}

///|
pub(all) enum LLVMDLLStorageClass {
  LLVMDefaultStorageClass
  LLVMDLLImportStorageClass
  LLVMDLLExportStorageClass
}

///|
pub fn LLVMDLLStorageClass::to_int(self : LLVMDLLStorageClass) -> Int {
  match self {
    LLVMDefaultStorageClass => 0
    LLVMDLLImportStorageClass => 1
    LLVMDLLExportStorageClass => 2
  }
}

///|
pub fn LLVMDLLStorageClass::from_int(idx : Int) -> LLVMDLLStorageClass {
  match idx {
    0 => LLVMDefaultStorageClass
    1 => LLVMDLLImportStorageClass
    2 => LLVMDLLExportStorageClass
    _ =>
      abort(
        "Invalid LLVMDLLStorageClass Number in `LLVMDLLStorageClass::from_int`",
      )
  }
}

///|
pub(all) enum LLVMCallConv {
  LLVMCCallConv
  LLVMFastCallConv
  LLVMColdCallConv
  LLVMGHCCallConv
  LLVMHiPECallConv
  LLVMAnyRegCallConv
  LLVMPreserveMostCallConv
  LLVMPreserveAllCallConv
  LLVMSwiftCallConv
  LLVMCXXFASTTLSCallConv
  LLVMX86StdcallCallConv
  LLVMX86FastcallCallConv
  LLVMARMAPCSCallConv
  LLVMARMAAPCSCallConv
  LLVMARMAAPCSVFPCallConv
  LLVMMSP430INTRCallConv
  LLVMX86ThisCallCallConv
  LLVMPTXKernelCallConv
  LLVMPTXDeviceCallConv
  LLVMSPIRFUNCCallConv
  LLVMSPIRKERNELCallConv
  LLVMIntelOCLBICallConv
  LLVMX8664SysVCallConv
  LLVMWin64CallConv
  LLVMX86VectorCallCallConv
  LLVMHHVMCallConv
  LLVMHHVMCCallConv
  LLVMX86INTRCallConv
  LLVMAVRINTRCallConv
  LLVMAVRSIGNALCallConv
  LLVMAVRBUILTINCallConv
  LLVMAMDGPUVSCallConv
  LLVMAMDGPUGSCallConv
  LLVMAMDGPUPSCallConv
  LLVMAMDGPUCSCallConv
  LLVMAMDGPUKERNELCallConv
  LLVMX86RegCallCallConv
  LLVMAMDGPUHSCallConv
  LLVMMSP430BUILTINCallConv
  LLVMAMDGPULSCallConv
  LLVMAMDGPUESCallConv
}

///|
pub fn LLVMCallConv::to_int(self : LLVMCallConv) -> Int {
  match self {
    LLVMCCallConv => 0
    LLVMFastCallConv => 1
    LLVMColdCallConv => 2
    LLVMGHCCallConv => 3
    LLVMHiPECallConv => 4
    LLVMAnyRegCallConv => 5
    LLVMPreserveMostCallConv => 6
    LLVMPreserveAllCallConv => 7
    LLVMSwiftCallConv => 8
    LLVMCXXFASTTLSCallConv => 9
    LLVMX86StdcallCallConv => 10
    LLVMX86FastcallCallConv => 11
    LLVMARMAPCSCallConv => 12
    LLVMARMAAPCSCallConv => 13
    LLVMARMAAPCSVFPCallConv => 14
    LLVMMSP430INTRCallConv => 15
    LLVMX86ThisCallCallConv => 16
    LLVMPTXKernelCallConv => 17
    LLVMPTXDeviceCallConv => 18
    LLVMSPIRFUNCCallConv => 19
    LLVMSPIRKERNELCallConv => 20
    LLVMIntelOCLBICallConv => 21
    LLVMX8664SysVCallConv => 22
    LLVMWin64CallConv => 23
    LLVMX86VectorCallCallConv => 24
    LLVMHHVMCallConv => 25
    LLVMHHVMCCallConv => 26
    LLVMX86INTRCallConv => 27
    LLVMAVRINTRCallConv => 28
    LLVMAVRSIGNALCallConv => 29
    LLVMAVRBUILTINCallConv => 30
    LLVMAMDGPUVSCallConv => 31
    LLVMAMDGPUGSCallConv => 32
    LLVMAMDGPUPSCallConv => 33
    LLVMAMDGPUCSCallConv => 34
    LLVMAMDGPUKERNELCallConv => 35
    LLVMX86RegCallCallConv => 36
    LLVMAMDGPUHSCallConv => 37
    LLVMMSP430BUILTINCallConv => 38
    LLVMAMDGPULSCallConv => 39
    LLVMAMDGPUESCallConv => 40
  }
}

///|
pub fn LLVMCallConv::from_int(i : Int) -> LLVMCallConv {
  match i {
    0 => LLVMCCallConv
    1 => LLVMFastCallConv
    2 => LLVMColdCallConv
    3 => LLVMGHCCallConv
    4 => LLVMHiPECallConv
    5 => LLVMAnyRegCallConv
    6 => LLVMPreserveMostCallConv
    7 => LLVMPreserveAllCallConv
    8 => LLVMSwiftCallConv
    9 => LLVMCXXFASTTLSCallConv
    10 => LLVMX86StdcallCallConv
    11 => LLVMX86FastcallCallConv
    12 => LLVMARMAPCSCallConv
    13 => LLVMARMAAPCSCallConv
    14 => LLVMARMAAPCSVFPCallConv
    15 => LLVMMSP430INTRCallConv
    16 => LLVMX86ThisCallCallConv
    17 => LLVMPTXKernelCallConv
    18 => LLVMPTXDeviceCallConv
    19 => LLVMSPIRFUNCCallConv
    20 => LLVMSPIRKERNELCallConv
    21 => LLVMIntelOCLBICallConv
    22 => LLVMX8664SysVCallConv
    23 => LLVMWin64CallConv
    24 => LLVMX86VectorCallCallConv
    25 => LLVMHHVMCallConv
    26 => LLVMHHVMCCallConv
    27 => LLVMX86INTRCallConv
    28 => LLVMAVRINTRCallConv
    29 => LLVMAVRSIGNALCallConv
    30 => LLVMAVRBUILTINCallConv
    31 => LLVMAMDGPUVSCallConv
    32 => LLVMAMDGPUGSCallConv
    33 => LLVMAMDGPUPSCallConv
    34 => LLVMAMDGPUCSCallConv
    35 => LLVMAMDGPUKERNELCallConv
    36 => LLVMX86RegCallCallConv
    37 => LLVMAMDGPUHSCallConv
    38 => LLVMMSP430BUILTINCallConv
    39 => LLVMAMDGPULSCallConv
    40 => LLVMAMDGPUESCallConv
    _ => abort("Invalid LLVMCallConv Number in `LLVMCallConv::from_int`")
  }
}

///|
pub(all) enum LLVMValueKind {
  LLVMArgumentValueKind
  LLVMBasicBlockValueKind
  LLVMMemoryUseValueKind
  LLVMMemoryDefValueKind
  LLVMMemoryPhiValueKind
  LLVMFunctionValueKind
  LLVMGlobalAliasValueKind
  LLVMGlobalIFuncValueKind
  LLVMGlobalVariableValueKind
  LLVMBlockAddressValueKind
  LLVMConstantExprValueKind
  LLVMConstantArrayValueKind
  LLVMConstantStructValueKind
  LLVMConstantVectorValueKind
  LLVMUndefValueValueKind
  LLVMConstantAggregateZeroValueKind
  LLVMConstantDataArrayValueKind
  LLVMConstantDataVectorValueKind
  LLVMConstantIntValueKind
  LLVMConstantFPValueKind
  LLVMConstantPointerNullValueKind
  LLVMConstantTokenNoneValueKind
  LLVMMetadataAsValueValueKind
  LLVMInlineAsmValueKind
  LLVMInstructionValueKind
  LLVMPoisonValueValueKind
  LLVMConstantTargetNoneValueKind
}

///|
pub fn LLVMValueKind::to_int(self : LLVMValueKind) -> Int {
  match self {
    LLVMArgumentValueKind => 0
    LLVMBasicBlockValueKind => 1
    LLVMMemoryUseValueKind => 2
    LLVMMemoryDefValueKind => 3
    LLVMMemoryPhiValueKind => 4
    LLVMFunctionValueKind => 5
    LLVMGlobalAliasValueKind => 6
    LLVMGlobalIFuncValueKind => 7
    LLVMGlobalVariableValueKind => 8
    LLVMBlockAddressValueKind => 9
    LLVMConstantExprValueKind => 10
    LLVMConstantArrayValueKind => 11
    LLVMConstantStructValueKind => 12
    LLVMConstantVectorValueKind => 13
    LLVMUndefValueValueKind => 14
    LLVMConstantAggregateZeroValueKind => 15
    LLVMConstantDataArrayValueKind => 16
    LLVMConstantDataVectorValueKind => 17
    LLVMConstantIntValueKind => 18
    LLVMConstantFPValueKind => 19
    LLVMConstantPointerNullValueKind => 20
    LLVMConstantTokenNoneValueKind => 21
    LLVMMetadataAsValueValueKind => 22
    LLVMInlineAsmValueKind => 23
    LLVMInstructionValueKind => 24
    LLVMPoisonValueValueKind => 25
    LLVMConstantTargetNoneValueKind => 26
  }
}

///|
pub fn LLVMValueKind::from_int(idx : Int) -> LLVMValueKind {
  match idx {
    0 => LLVMArgumentValueKind
    1 => LLVMBasicBlockValueKind
    2 => LLVMMemoryUseValueKind
    3 => LLVMMemoryDefValueKind
    4 => LLVMMemoryPhiValueKind
    5 => LLVMFunctionValueKind
    6 => LLVMGlobalAliasValueKind
    7 => LLVMGlobalIFuncValueKind
    8 => LLVMGlobalVariableValueKind
    9 => LLVMBlockAddressValueKind
    10 => LLVMConstantExprValueKind
    11 => LLVMConstantArrayValueKind
    12 => LLVMConstantStructValueKind
    13 => LLVMConstantVectorValueKind
    14 => LLVMUndefValueValueKind
    15 => LLVMConstantAggregateZeroValueKind
    16 => LLVMConstantDataArrayValueKind
    17 => LLVMConstantDataVectorValueKind
    18 => LLVMConstantIntValueKind
    19 => LLVMConstantFPValueKind
    20 => LLVMConstantPointerNullValueKind
    21 => LLVMConstantTokenNoneValueKind
    22 => LLVMMetadataAsValueValueKind
    23 => LLVMInlineAsmValueKind
    24 => LLVMInstructionValueKind
    25 => LLVMPoisonValueValueKind
    26 => LLVMConstantTargetNoneValueKind
    _ => abort("Invalid LLVMValueKind Number in `LLVMValueKind::from_int`")
  }
}

///|
pub(all) enum LLVMIntPredicate {
  LLVMIntEQ
  LLVMIntNE
  LLVMIntUGT
  LLVMIntUGE
  LLVMIntULT
  LLVMIntULE
  LLVMIntSGT
  LLVMIntSGE
  LLVMIntSLT
  LLVMIntSLE
}

///|
pub fn LLVMIntPredicate::to_int(self : LLVMIntPredicate) -> Int {
  match self {
    LLVMIntEQ => 0
    LLVMIntNE => 1
    LLVMIntUGT => 2
    LLVMIntUGE => 3
    LLVMIntULT => 4
    LLVMIntULE => 5
    LLVMIntSGT => 6
    LLVMIntSGE => 7
    LLVMIntSLT => 8
    LLVMIntSLE => 9
  }
}

///|
pub fn LLVMIntPredicate::from_int(idx : Int) -> LLVMIntPredicate {
  match idx {
    0 => LLVMIntEQ
    1 => LLVMIntNE
    2 => LLVMIntUGT
    3 => LLVMIntUGE
    4 => LLVMIntULT
    5 => LLVMIntULE
    6 => LLVMIntSGT
    7 => LLVMIntSGE
    8 => LLVMIntSLT
    9 => LLVMIntSLE
    _ =>
      abort("Invalid LLVMIntPredicate Number in `LLVMIntPredicate::from_int`")
  }
}

///|
pub(all) enum LLVMRealPredicate {
  LLVMRealPredicateFalse
  LLVMRealOEQ
  LLVMRealOGT
  LLVMRealOGE
  LLVMRealOLT
  LLVMRealOLE
  LLVMRealONE
  LLVMRealORD
  LLVMRealUNO
  LLVMRealUEQ
  LLVMRealUGT
  LLVMRealUGE
  LLVMRealULT
  LLVMRealULE
  LLVMRealUNE
  LLVMRealPredicateTrue
}

///|
pub fn LLVMRealPredicate::to_int(self : LLVMRealPredicate) -> Int {
  match self {
    LLVMRealPredicateFalse => 0
    LLVMRealOEQ => 1
    LLVMRealOGT => 2
    LLVMRealOGE => 3
    LLVMRealOLT => 4
    LLVMRealOLE => 5
    LLVMRealONE => 6
    LLVMRealORD => 7
    LLVMRealUNO => 8
    LLVMRealUEQ => 9
    LLVMRealUGT => 10
    LLVMRealUGE => 11
    LLVMRealULT => 12
    LLVMRealULE => 13
    LLVMRealUNE => 14
    LLVMRealPredicateTrue => 15
  }
}

///|
pub fn LLVMRealPredicate::from_int(idx : Int) -> LLVMRealPredicate {
  match idx {
    0 => LLVMRealPredicateFalse
    1 => LLVMRealOEQ
    2 => LLVMRealOGT
    3 => LLVMRealOGE
    4 => LLVMRealOLT
    5 => LLVMRealOLE
    6 => LLVMRealONE
    7 => LLVMRealORD
    8 => LLVMRealUNO
    9 => LLVMRealUEQ
    10 => LLVMRealUGT
    11 => LLVMRealUGE
    12 => LLVMRealULT
    13 => LLVMRealULE
    14 => LLVMRealUNE
    15 => LLVMRealPredicateTrue
    _ =>
      abort("Invalid LLVMRealPredicate Number in `LLVMRealPredicate::from_int`")
  }
}

///|
pub(all) enum LLVMLandingPadClauseTy {
  LLVMLandingPadCatch
  LLVMLandingPadFilter
}

///|
pub fn LLVMLandingPadClauseTy::to_int(self : LLVMLandingPadClauseTy) -> Int {
  match self {
    LLVMLandingPadCatch => 0
    LLVMLandingPadFilter => 1
  }
}

///|
pub fn LLVMLandingPadClauseTy::from_int(idx : Int) -> LLVMLandingPadClauseTy {
  match idx {
    0 => LLVMLandingPadCatch
    1 => LLVMLandingPadFilter
    _ =>
      abort(
        "Invalid LLVMLandingPadClauseTy Number in `LLVMLandingPadClauseTy::from_int`",
      )
  }
}

///|
pub(all) enum LLVMThreadLocalMode {
  LLVMNotThreadLocal
  LLVMGeneralDynamicTLSModel
  LLVMLocalDynamicTLSModel
  LLVMInitialExecTLSModel
  LLVMLocalExecTLSModel
}

///|
pub fn LLVMThreadLocalMode::to_int(self : LLVMThreadLocalMode) -> Int {
  match self {
    LLVMNotThreadLocal => 0
    LLVMGeneralDynamicTLSModel => 1
    LLVMLocalDynamicTLSModel => 2
    LLVMInitialExecTLSModel => 3
    LLVMLocalExecTLSModel => 4
  }
}

///|
pub fn LLVMThreadLocalMode::from_int(idx : Int) -> LLVMThreadLocalMode {
  match idx {
    0 => LLVMNotThreadLocal
    1 => LLVMGeneralDynamicTLSModel
    2 => LLVMLocalDynamicTLSModel
    3 => LLVMInitialExecTLSModel
    4 => LLVMLocalExecTLSModel
    _ =>
      abort(
        "Invalid LLVMThreadLocalMode Number in `LLVMThreadLocalMode::from_int`",
      )
  }
}

///|
pub(all) enum LLVMAtomicOrdering {
  LLVMAtomicOrderingNotAtomic
  LLVMAtomicOrderingUnordered
  LLVMAtomicOrderingMonotonic
  LLVMAtomicOrderingAcquire
  LLVMAtomicOrderingRelease
  LLVMAtomicOrderingAcquireRelease
  LLVMAtomicOrderingSequentiallyConsistent
}

///|
pub fn LLVMAtomicOrdering::to_int(self : LLVMAtomicOrdering) -> Int {
  match self {
    LLVMAtomicOrderingNotAtomic => 0
    LLVMAtomicOrderingUnordered => 1
    LLVMAtomicOrderingMonotonic => 2
    LLVMAtomicOrderingAcquire => 3
    LLVMAtomicOrderingRelease => 4
    LLVMAtomicOrderingAcquireRelease => 5
    LLVMAtomicOrderingSequentiallyConsistent => 6
  }
}

///|
pub fn LLVMAtomicOrdering::from_int(idx : Int) -> LLVMAtomicOrdering {
  match idx {
    0 => LLVMAtomicOrderingNotAtomic
    1 => LLVMAtomicOrderingUnordered
    2 => LLVMAtomicOrderingMonotonic
    3 => LLVMAtomicOrderingAcquire
    4 => LLVMAtomicOrderingRelease
    5 => LLVMAtomicOrderingAcquireRelease
    6 => LLVMAtomicOrderingSequentiallyConsistent
    _ =>
      abort(
        "Invalid LLVMAtomicOrdering Number in `LLVMAtomicOrdering::from_int`",
      )
  }
}

///|
pub(all) enum LLVMAtomicRMWBinOp {
  LLVMAtomicRMWBinOpXchg
  LLVMAtomicRMWBinOpAdd
  LLVMAtomicRMWBinOpSub
  LLVMAtomicRMWBinOpAnd
  LLVMAtomicRMWBinOpNand
  LLVMAtomicRMWBinOpOr
  LLVMAtomicRMWBinOpXor
  LLVMAtomicRMWBinOpMax
  LLVMAtomicRMWBinOpMin
  LLVMAtomicRMWBinOpUMax
  LLVMAtomicRMWBinOpUMin
  LLVMAtomicRMWBinOpFAdd
  LLVMAtomicRMWBinOpFSub
  LLVMAtomicRMWBinOpFMax
  LLVMAtomicRMWBinOpFMin
  LLVMAtomicRMWBinOpUIncWrap
  LLVMAtomicRMWBinOpUDecWrap
}

///|
pub fn LLVMAtomicRMWBinOp::to_int(self : LLVMAtomicRMWBinOp) -> Int {
  match self {
    LLVMAtomicRMWBinOpXchg => 0
    LLVMAtomicRMWBinOpAdd => 1
    LLVMAtomicRMWBinOpSub => 2
    LLVMAtomicRMWBinOpAnd => 3
    LLVMAtomicRMWBinOpNand => 4
    LLVMAtomicRMWBinOpOr => 5
    LLVMAtomicRMWBinOpXor => 6
    LLVMAtomicRMWBinOpMax => 7
    LLVMAtomicRMWBinOpMin => 8
    LLVMAtomicRMWBinOpUMax => 9
    LLVMAtomicRMWBinOpUMin => 10
    LLVMAtomicRMWBinOpFAdd => 11
    LLVMAtomicRMWBinOpFSub => 12
    LLVMAtomicRMWBinOpFMax => 13
    LLVMAtomicRMWBinOpFMin => 14
    LLVMAtomicRMWBinOpUIncWrap => 15
    LLVMAtomicRMWBinOpUDecWrap => 16
  }
}

///|
pub fn LLVMAtomicRMWBinOp::from_int(idx : Int) -> LLVMAtomicRMWBinOp {
  match idx {
    0 => LLVMAtomicRMWBinOpXchg
    1 => LLVMAtomicRMWBinOpAdd
    2 => LLVMAtomicRMWBinOpSub
    3 => LLVMAtomicRMWBinOpAnd
    4 => LLVMAtomicRMWBinOpNand
    5 => LLVMAtomicRMWBinOpOr
    6 => LLVMAtomicRMWBinOpXor
    7 => LLVMAtomicRMWBinOpMax
    8 => LLVMAtomicRMWBinOpMin
    9 => LLVMAtomicRMWBinOpUMax
    10 => LLVMAtomicRMWBinOpUMin
    11 => LLVMAtomicRMWBinOpFAdd
    12 => LLVMAtomicRMWBinOpFSub
    13 => LLVMAtomicRMWBinOpFMax
    14 => LLVMAtomicRMWBinOpFMin
    15 => LLVMAtomicRMWBinOpUIncWrap
    16 => LLVMAtomicRMWBinOpUDecWrap
    _ =>
      abort(
        "Invalid LLVMAtomicRMWBinOp Number in `LLVMAtomicRMWBinOp::from_int`",
      )
  }
}

///|
pub(all) enum LLVMDiagnosticSeverity {
  LLVMDSError
  LLVMDSWarning
  LLVMDSRemark
  LLVMDSNote
}

///|
pub fn LLVMDiagnosticSeverity::to_int(self : LLVMDiagnosticSeverity) -> Int {
  match self {
    LLVMDSError => 0
    LLVMDSWarning => 1
    LLVMDSRemark => 2
    LLVMDSNote => 3
  }
}

///|
pub fn LLVMDiagnosticSeverity::from_int(idx : Int) -> LLVMDiagnosticSeverity {
  match idx {
    0 => LLVMDSError
    1 => LLVMDSWarning
    2 => LLVMDSRemark
    3 => LLVMDSNote
    _ =>
      abort(
        "Invalid LLVMDiagnosticSeverity Number in `LLVMDiagnosticSeverity::from_int`",
      )
  }
}

///|
pub(all) enum LLVMInlineAsmDialect {
  LLVMInlineAsmDialectATT
  LLVMInlineAsmDialectIntel
}

///|
pub fn LLVMInlineAsmDialect::to_int(self : LLVMInlineAsmDialect) -> Int {
  match self {
    LLVMInlineAsmDialectATT => 0
    LLVMInlineAsmDialectIntel => 1
  }
}

///|
pub fn LLVMInlineAsmDialect::from_int(idx : Int) -> LLVMInlineAsmDialect {
  match idx {
    0 => LLVMInlineAsmDialectATT
    1 => LLVMInlineAsmDialectIntel
    _ =>
      abort(
        "Invalid LLVMInlineAsmDialect Number in `LLVMInlineAsmDialect::from_int`",
      )
  }
}

///|
pub(all) enum LLVMModuleFlagBehavior {
  /// 
  /// Emits an error if two values disagree, otherwise the resulting value is
  /// that of the operands.
  /// 
  /// - see Module::ModFlagBehavior::Error
  /// 
  LLVMModuleFlagBehaviorError
  /// Emits a warning if two values disagree. The result value will be the
  /// operand for the flag from the first module being linked.
  /// 
  /// - see Module::ModFlagBehavior::Warning
  /// 
  LLVMModuleFlagBehaviorWarning
  /// Adds a requirement that another module flag be present and have a
  /// specified value after linking is performed. The value must be a metadata
  /// pair, where the first element of the pair is the ID of the module flag
  /// to be restricted, and the second element of the pair is the value the
  /// module flag should be restricted to. This behavior can be used to
  /// restrict the allowable results (via triggering of an error) of linking
  /// IDs with the **Override** behavior.
  /// 
  /// - see Module::ModFlagBehavior::Require
  /// 
  LLVMModuleFlagBehaviorRequire
  /// 
  /// Uses the specified value, regardless of the behavior or value of the
  /// other module. If both modules specify **Override**, but the values
  /// differ, an error will be emitted.
  /// 
  /// - see Module::ModFlagBehavior::Override
  /// 
  LLVMModuleFlagBehaviorOverride
  /// 
  /// Appends the two values, which are required to be metadata nodes.
  /// 
  /// - see Module::ModFlagBehavior::Append
  /// 
  LLVMModuleFlagBehaviorAppend
  /// 
  /// Appends the two values, which are required to be metadata
  /// nodes. However, duplicate entries in the second list are dropped
  /// during the append operation.
  /// 
  /// - see Module::ModFlagBehavior::AppendUnique
  /// 
  LLVMModuleFlagBehaviorAppendUnique
}

///|
pub fn LLVMModuleFlagBehavior::to_int(self : LLVMModuleFlagBehavior) -> Int {
  match self {
    LLVMModuleFlagBehaviorError => 0
    LLVMModuleFlagBehaviorWarning => 1
    LLVMModuleFlagBehaviorRequire => 2
    LLVMModuleFlagBehaviorOverride => 3
    LLVMModuleFlagBehaviorAppend => 4
    LLVMModuleFlagBehaviorAppendUnique => 5
  }
}

///|
pub fn LLVMModuleFlagBehavior::from_int(idx : Int) -> LLVMModuleFlagBehavior {
  match idx {
    0 => LLVMModuleFlagBehaviorError
    1 => LLVMModuleFlagBehaviorWarning
    2 => LLVMModuleFlagBehaviorRequire
    3 => LLVMModuleFlagBehaviorOverride
    4 => LLVMModuleFlagBehaviorAppend
    5 => LLVMModuleFlagBehaviorAppendUnique
    _ =>
      abort(
        "Invalid LLVMModuleFlagBehavior Number in `LLVMModuleFlagBehavior::from_int`",
      )
  }
}

//
// /**
//  * Attribute index are either LLVMAttributeReturnIndex,
//  * LLVMAttributeFunctionIndex or a parameter number from 1 to N.
//  */
// enum {
//   LLVMAttributeReturnIndex = 0U,
//   // ISO C restricts enumerator values to range of 'int'
//   // (4294967295 is too large)
//   // LLVMAttributeFunctionIndex = ~0U,
//   LLVMAttributeFunctionIndex = -1,
// };

///|
pub(all) enum LLVMTailCallKind {
  LLVMTailCallKindNone
  LLVMTailCallKindTail
  LLVMTailCallKindMustTail
  LLVMTailCallKindNoTail
}

///|
pub fn LLVMTailCallKind::to_int(self : LLVMTailCallKind) -> Int {
  match self {
    LLVMTailCallKindNone => 0
    LLVMTailCallKindTail => 1
    LLVMTailCallKindMustTail => 2
    LLVMTailCallKindNoTail => 3
  }
}

///|
pub fn LLVMTailCallKind::from_int(idx : Int) -> LLVMTailCallKind {
  match idx {
    0 => LLVMTailCallKindNone
    1 => LLVMTailCallKindTail
    2 => LLVMTailCallKindMustTail
    3 => LLVMTailCallKindNoTail
    _ =>
      abort("Invalid LLVMTailCallKind Number in `LLVMTailCallKind::from_int`")
  }
}

///|
pub(all) enum LLVMComdatSelectionKind {
  LLVMAnyComdatSelectionKind
  LLVMExactMatchComdatSelectionKind
  LLVMLargestComdatSelectionKind
  LLVMNoDeduplicateComdatSelectionKind
  LLVMSameSizeComdatSelectionKind
}

///|
pub fn LLVMComdatSelectionKind::to_int(self : LLVMComdatSelectionKind) -> Int {
  match self {
    LLVMAnyComdatSelectionKind => 0
    LLVMExactMatchComdatSelectionKind => 1
    LLVMLargestComdatSelectionKind => 2
    LLVMNoDeduplicateComdatSelectionKind => 3
    LLVMSameSizeComdatSelectionKind => 4
  }
}

///|
pub fn LLVMComdatSelectionKind::from_int(idx : Int) -> LLVMComdatSelectionKind {
  match idx {
    0 => LLVMAnyComdatSelectionKind
    1 => LLVMExactMatchComdatSelectionKind
    2 => LLVMLargestComdatSelectionKind
    3 => LLVMNoDeduplicateComdatSelectionKind
    4 => LLVMSameSizeComdatSelectionKind
    _ =>
      abort(
        "Invalid LLVMComdatSelectionKind Number in `LLVMComdatSelectionKind::from_int`",
      )
  }
}

///|
pub(all) enum LLVMLinkerMode {
  LLVMLinkerDestroySource
  LLVMLinkerPreserveSource_Removed
}

///|
pub fn LLVMLinkerMode::to_int(self : LLVMLinkerMode) -> Int {
  match self {
    LLVMLinkerDestroySource => 0
    LLVMLinkerPreserveSource_Removed => 1
  }
}

///|
pub fn LLVMLinkerMode::from_int(idx : Int) -> LLVMLinkerMode {
  match idx {
    0 => LLVMLinkerDestroySource
    1 => LLVMLinkerPreserveSource_Removed
    _ => abort("Invalid LLVMLinkerMode Number in `LLVMLinkerMode::from_int`")
  }
}

///|
pub(all) enum LLVMCodeGenOptLevel {
  LLVMCodeGenLevelNone
  LLVMCodeGenLevelLess
  LLVMCodeGenLevelDefault
  LLVMCodeGenLevelAggressive
}

///|
pub fn LLVMCodeGenOptLevel::to_int(self : LLVMCodeGenOptLevel) -> Int {
  match self {
    LLVMCodeGenLevelNone => 0
    LLVMCodeGenLevelLess => 1
    LLVMCodeGenLevelDefault => 2
    LLVMCodeGenLevelAggressive => 3
  }
}

///|
pub fn LLVMCodeGenOptLevel::from_int(idx : Int) -> LLVMCodeGenOptLevel {
  match idx {
    0 => LLVMCodeGenLevelNone
    1 => LLVMCodeGenLevelLess
    2 => LLVMCodeGenLevelDefault
    3 => LLVMCodeGenLevelAggressive
    _ =>
      abort(
        "Invalid LLVMCodeGenOptLevel Number in `LLVMCodeGenOptLevel::from_int`",
      )
  }
}

///|
pub(all) enum LLVMRelocMode {
  LLVMRelocDefault
  LLVMRelocStatic
  LLVMRelocPIC
  LLVMRelocDynamicNoPic
  LLVMRelocROPI
  LLVMRelocRWPI
  LLVMRelocROPI_RWPI
}

///|
pub fn LLVMRelocMode::to_int(self : LLVMRelocMode) -> Int {
  match self {
    LLVMRelocDefault => 0
    LLVMRelocStatic => 1
    LLVMRelocPIC => 2
    LLVMRelocDynamicNoPic => 3
    LLVMRelocROPI => 4
    LLVMRelocRWPI => 5
    LLVMRelocROPI_RWPI => 6
  }
}

///|
pub fn LLVMRelocMode::from_int(idx : Int) -> LLVMRelocMode {
  match idx {
    0 => LLVMRelocDefault
    1 => LLVMRelocStatic
    2 => LLVMRelocPIC
    3 => LLVMRelocDynamicNoPic
    4 => LLVMRelocROPI
    5 => LLVMRelocRWPI
    6 => LLVMRelocROPI_RWPI
    _ => abort("Invalid LLVMRelocMode Number in `LLVMRelocMode::from_int`")
  }
}

///|
pub(all) enum LLVMCodeModel {
  LLVMCodeModelDefault
  LLVMCodeModelJITDefault
  LLVMCodeModelTiny
  LLVMCodeModelSmall
  LLVMCodeModelKernel
  LLVMCodeModelMedium
  LLVMCodeModelLarge
}

///|
pub fn LLVMCodeModel::to_int(self : LLVMCodeModel) -> Int {
  match self {
    LLVMCodeModelDefault => 0
    LLVMCodeModelJITDefault => 1
    LLVMCodeModelTiny => 2
    LLVMCodeModelSmall => 3
    LLVMCodeModelKernel => 4
    LLVMCodeModelMedium => 5
    LLVMCodeModelLarge => 6
  }
}

///|
pub fn LLVMCodeModel::from_int(idx : Int) -> LLVMCodeModel {
  match idx {
    0 => LLVMCodeModelDefault
    1 => LLVMCodeModelJITDefault
    2 => LLVMCodeModelTiny
    3 => LLVMCodeModelSmall
    4 => LLVMCodeModelKernel
    5 => LLVMCodeModelMedium
    6 => LLVMCodeModelLarge
    _ => abort("Invalid LLVMCodeModel Number in `LLVMCodeModel::from_int`")
  }
}

///|
pub(all) enum LLVMCodeGenFileType {
  LLVMAssemblyFile
  LLVMObjectFile
}

///|
pub fn LLVMCodeGenFileType::to_int(self : LLVMCodeGenFileType) -> Int {
  match self {
    LLVMAssemblyFile => 0
    LLVMObjectFile => 1
  }
}

///|
pub fn LLVMCodeGenFileType::from_int(idx : Int) -> LLVMCodeGenFileType {
  match idx {
    0 => LLVMAssemblyFile
    1 => LLVMObjectFile
    _ =>
      abort(
        "Invalid LLVMCodeGenFileType Number in `LLVMCodeGenFileType::from_int`",
      )
  }
}

///|
pub(all) enum LLVMGlobalISelAbortMode {
  LLVMGlobalISelAbortEnable
  LLVMGlobalISelAbortDisable
  LLVMGlobalISelAbortDisableWithDiag
}

///|
pub fn LLVMGlobalISelAbortMode::to_int(self : LLVMGlobalISelAbortMode) -> Int {
  match self {
    LLVMGlobalISelAbortEnable => 0
    LLVMGlobalISelAbortDisable => 1
    LLVMGlobalISelAbortDisableWithDiag => 2
  }
}

///|
pub fn LLVMGlobalISelAbortMode::from_int(idx : Int) -> LLVMGlobalISelAbortMode {
  match idx {
    0 => LLVMGlobalISelAbortEnable
    1 => LLVMGlobalISelAbortDisable
    2 => LLVMGlobalISelAbortDisableWithDiag
    _ =>
      abort(
        "Invalid LLVMGlobalISelAbortMode Number in `LLVMGlobalISelAbortMode::from_int`",
      )
  }
}

///|
pub(all) enum LLVMBinaryType {
  // Archive file.
  LLVMBinaryTypeArchive

  // Mach-O Universal Binary file.
  LLVMBinaryTypeMachOUniversalBinary

  // COFF Import file.
  LLVMBinaryTypeCOFFImportFile

  // LLVM IR.
  LLVMBinaryTypeIR

  // Windows resource (.res) file.
  LLVMBinaryTypeWinRes

  // COFF Object file.
  LLVMBinaryTypeCOFF

  // ELF 32-bit, little endian.
  LLVMBinaryTypeELF32L

  // ELF 32-bit, big endian.
  LLVMBinaryTypeELF32B

  // ELF 64-bit, little endian.
  LLVMBinaryTypeELF64L

  // ELF 64-bit, big endian.
  LLVMBinaryTypeELF64B

  // MachO 32-bit, little endian.
  LLVMBinaryTypeMachO32L

  // MachO 32-bit, big endian.
  LLVMBinaryTypeMachO32B

  // MachO 64-bit, little endian.
  LLVMBinaryTypeMachO64L

  // MachO 64-bit, big endian.
  LLVMBinaryTypeMachO64B

  // Web Assembly.
  LLVMBinaryTypeWasm

  // Offloading fatbinary.
  LLVMBinaryTypeOffload
}

///|
pub fn LLVMBinaryType::to_int(self : LLVMBinaryType) -> Int {
  match self {
    LLVMBinaryTypeArchive => 0
    LLVMBinaryTypeMachOUniversalBinary => 1
    LLVMBinaryTypeCOFFImportFile => 2
    LLVMBinaryTypeIR => 3
    LLVMBinaryTypeWinRes => 4
    LLVMBinaryTypeCOFF => 5
    LLVMBinaryTypeELF32L => 6
    LLVMBinaryTypeELF32B => 7
    LLVMBinaryTypeELF64L => 8
    LLVMBinaryTypeELF64B => 9
    LLVMBinaryTypeMachO32L => 10
    LLVMBinaryTypeMachO32B => 11
    LLVMBinaryTypeMachO64L => 12
    LLVMBinaryTypeMachO64B => 13
    LLVMBinaryTypeWasm => 14
    LLVMBinaryTypeOffload => 15
  }
}

///|
pub fn LLVMBinaryType::from_int(idx : Int) -> LLVMBinaryType {
  match idx {
    0 => LLVMBinaryTypeArchive
    1 => LLVMBinaryTypeMachOUniversalBinary
    2 => LLVMBinaryTypeCOFFImportFile
    3 => LLVMBinaryTypeIR
    4 => LLVMBinaryTypeWinRes
    5 => LLVMBinaryTypeCOFF
    6 => LLVMBinaryTypeELF32L
    7 => LLVMBinaryTypeELF32B
    8 => LLVMBinaryTypeELF64L
    9 => LLVMBinaryTypeELF64B
    10 => LLVMBinaryTypeMachO32L
    11 => LLVMBinaryTypeMachO32B
    12 => LLVMBinaryTypeMachO64L
    13 => LLVMBinaryTypeMachO64B
    14 => LLVMBinaryTypeWasm
    15 => LLVMBinaryTypeOffload
    _ => abort("Invalid LLVMBinaryType Number in `LLVMBinaryType::from_int`")
  }
}

///|
pub(all) enum LLVMDIFlags {
  LLVMDIFlagZero
  LLVMDIFlagPrivate
  LLVMDIFlagProtected
  LLVMDIFlagPublic
  LLVMDIFlagFwdDecl
  LLVMDIFlagAppleBlock
  LLVMDIFlagReservedBit4
  LLVMDIFlagVirtual
  LLVMDIFlagArtificial
  LLVMDIFlagExplicit
  LLVMDIFlagPrototyped
  LLVMDIFlagObjcClassComplete
  LLVMDIFlagObjectPointer
  LLVMDIFlagVector
  LLVMDIFlagStaticMember
  LLVMDIFlagLValueReference
  LLVMDIFlagRValueReference
  LLVMDIFlagReserved
  LLVMDIFlagSingleInheritance
  LLVMDIFlagMultipleInheritance
  LLVMDIFlagVirtualInheritance
  LLVMDIFlagIntroducedVirtual
  LLVMDIFlagBitField
  LLVMDIFlagNoReturn
  LLVMDIFlagTypePassByValue
  LLVMDIFlagTypePassByReference
  LLVMDIFlagEnumClass
  LLVMDIFlagFixedEnum
  LLVMDIFlagThunk
  LLVMDIFlagNonTrivial
  LLVMDIFlagBigEndian
  LLVMDIFlagLittleEndian
  LLVMDIFlagIndirectVirtualBase
  LLVMDIFlagAccessibility
  LLVMDIFlagPtrToMemberRep
}

///|
pub fn LLVMDIFlags::to_int(self : LLVMDIFlags) -> Int {
  match self {
    LLVMDIFlagZero => 0
    LLVMDIFlagPrivate => 1
    LLVMDIFlagProtected => 2
    LLVMDIFlagPublic => 3
    LLVMDIFlagFwdDecl => 4
    LLVMDIFlagAppleBlock => 5
    LLVMDIFlagReservedBit4 => 6
    LLVMDIFlagVirtual => 7
    LLVMDIFlagArtificial => 8
    LLVMDIFlagExplicit => 9
    LLVMDIFlagPrototyped => 10
    LLVMDIFlagObjcClassComplete => 11
    LLVMDIFlagObjectPointer => 12
    LLVMDIFlagVector => 13
    LLVMDIFlagStaticMember => 14
    LLVMDIFlagLValueReference => 15
    LLVMDIFlagRValueReference => 16
    LLVMDIFlagReserved => 17
    LLVMDIFlagSingleInheritance => 18
    LLVMDIFlagMultipleInheritance => 19
    LLVMDIFlagVirtualInheritance => 20
    LLVMDIFlagIntroducedVirtual => 21
    LLVMDIFlagBitField => 22
    LLVMDIFlagNoReturn => 23
    LLVMDIFlagTypePassByValue => 24
    LLVMDIFlagTypePassByReference => 25
    LLVMDIFlagEnumClass => 26
    LLVMDIFlagFixedEnum => 27
    LLVMDIFlagThunk => 28
    LLVMDIFlagNonTrivial => 29
    LLVMDIFlagBigEndian => 30
    LLVMDIFlagLittleEndian => 31
    LLVMDIFlagIndirectVirtualBase => 32
    LLVMDIFlagAccessibility => 33
    LLVMDIFlagPtrToMemberRep => 34
  }
}

///|
pub fn LLVMDIFlags::from_int(idx : Int) -> LLVMDIFlags {
  match idx {
    0 => LLVMDIFlagZero
    1 => LLVMDIFlagPrivate
    2 => LLVMDIFlagProtected
    3 => LLVMDIFlagPublic
    4 => LLVMDIFlagFwdDecl
    5 => LLVMDIFlagAppleBlock
    6 => LLVMDIFlagReservedBit4
    7 => LLVMDIFlagVirtual
    8 => LLVMDIFlagArtificial
    9 => LLVMDIFlagExplicit
    10 => LLVMDIFlagPrototyped
    11 => LLVMDIFlagObjcClassComplete
    12 => LLVMDIFlagObjectPointer
    13 => LLVMDIFlagVector
    14 => LLVMDIFlagStaticMember
    15 => LLVMDIFlagLValueReference
    16 => LLVMDIFlagRValueReference
    17 => LLVMDIFlagReserved
    18 => LLVMDIFlagSingleInheritance
    19 => LLVMDIFlagMultipleInheritance
    20 => LLVMDIFlagVirtualInheritance
    21 => LLVMDIFlagIntroducedVirtual
    22 => LLVMDIFlagBitField
    23 => LLVMDIFlagNoReturn
    24 => LLVMDIFlagTypePassByValue
    25 => LLVMDIFlagTypePassByReference
    26 => LLVMDIFlagEnumClass
    27 => LLVMDIFlagFixedEnum
    28 => LLVMDIFlagThunk
    29 => LLVMDIFlagNonTrivial
    30 => LLVMDIFlagBigEndian
    31 => LLVMDIFlagLittleEndian
    32 => LLVMDIFlagIndirectVirtualBase
    33 => LLVMDIFlagAccessibility
    34 => LLVMDIFlagPtrToMemberRep
    _ => abort("Invalid LLVMDIFlags Number in `LLVMDIFlags::from_int`")
  }
}

///| Source languages known by DWARF.
pub(all) enum LLVMDWARFSourceLanguage {
  LLVMDWARFSourceLanguageC89
  LLVMDWARFSourceLanguageC
  LLVMDWARFSourceLanguageAda83
  LLVMDWARFSourceLanguageC_plus_plus
  LLVMDWARFSourceLanguageCobol74
  LLVMDWARFSourceLanguageCobol85
  LLVMDWARFSourceLanguageFortran77
  LLVMDWARFSourceLanguageFortran90
  LLVMDWARFSourceLanguagePascal83
  LLVMDWARFSourceLanguageModula2
  // New in DWARF v3:
  LLVMDWARFSourceLanguageJava
  LLVMDWARFSourceLanguageC99
  LLVMDWARFSourceLanguageAda95
  LLVMDWARFSourceLanguageFortran95
  LLVMDWARFSourceLanguagePLI
  LLVMDWARFSourceLanguageObjC
  LLVMDWARFSourceLanguageObjC_plus_plus
  LLVMDWARFSourceLanguageUPC
  LLVMDWARFSourceLanguageD
  // New in DWARF v4:
  LLVMDWARFSourceLanguagePython
  // New in DWARF v5:
  LLVMDWARFSourceLanguageOpenCL
  LLVMDWARFSourceLanguageGo
  LLVMDWARFSourceLanguageModula3
  LLVMDWARFSourceLanguageHaskell
  LLVMDWARFSourceLanguageC_plus_plus_03
  LLVMDWARFSourceLanguageC_plus_plus_11
  LLVMDWARFSourceLanguageOCaml
  LLVMDWARFSourceLanguageRust
  LLVMDWARFSourceLanguageC11
  LLVMDWARFSourceLanguageSwift
  LLVMDWARFSourceLanguageJulia
  LLVMDWARFSourceLanguageDylan
  LLVMDWARFSourceLanguageC_plus_plus_14
  LLVMDWARFSourceLanguageFortran03
  LLVMDWARFSourceLanguageFortran08
  LLVMDWARFSourceLanguageRenderScript
  LLVMDWARFSourceLanguageBLISS
  LLVMDWARFSourceLanguageKotlin
  LLVMDWARFSourceLanguageZig
  LLVMDWARFSourceLanguageCrystal
  LLVMDWARFSourceLanguageC_plus_plus_17
  LLVMDWARFSourceLanguageC_plus_plus_20
  LLVMDWARFSourceLanguageC17
  LLVMDWARFSourceLanguageFortran18
  LLVMDWARFSourceLanguageAda2005
  LLVMDWARFSourceLanguageAda2012
  LLVMDWARFSourceLanguageHIP
  LLVMDWARFSourceLanguageAssembly
  LLVMDWARFSourceLanguageC_sharp
  LLVMDWARFSourceLanguageMojo
  LLVMDWARFSourceLanguageGLSL
  LLVMDWARFSourceLanguageGLSL_ES
  LLVMDWARFSourceLanguageHLSL
  LLVMDWARFSourceLanguageOpenCL_CPP
  LLVMDWARFSourceLanguageCPP_for_OpenCL
  LLVMDWARFSourceLanguageSYCL
  LLVMDWARFSourceLanguageRuby
  LLVMDWARFSourceLanguageMove
  LLVMDWARFSourceLanguageHylo
  LLVMDWARFSourceLanguageMetal

  // Vendor extensions:
  LLVMDWARFSourceLanguageMips_Assembler
  LLVMDWARFSourceLanguageGOOGLE_RenderScript
  LLVMDWARFSourceLanguageBORLAND_Delphi
}

///|
pub fn LLVMDWARFSourceLanguage::to_int(self : LLVMDWARFSourceLanguage) -> Int {
  match self {
    LLVMDWARFSourceLanguageC89 => 0
    LLVMDWARFSourceLanguageC => 1
    LLVMDWARFSourceLanguageAda83 => 2
    LLVMDWARFSourceLanguageC_plus_plus => 3
    LLVMDWARFSourceLanguageCobol74 => 4
    LLVMDWARFSourceLanguageCobol85 => 5
    LLVMDWARFSourceLanguageFortran77 => 6
    LLVMDWARFSourceLanguageFortran90 => 7
    LLVMDWARFSourceLanguagePascal83 => 8
    LLVMDWARFSourceLanguageModula2 => 9
    // New in DWARF v3:
    LLVMDWARFSourceLanguageJava => 10
    LLVMDWARFSourceLanguageC99 => 11
    LLVMDWARFSourceLanguageAda95 => 12
    LLVMDWARFSourceLanguageFortran95 => 13
    LLVMDWARFSourceLanguagePLI => 14
    LLVMDWARFSourceLanguageObjC => 15
    LLVMDWARFSourceLanguageObjC_plus_plus => 16
    LLVMDWARFSourceLanguageUPC => 17
    LLVMDWARFSourceLanguageD => 18
    // New in DWARF v4:
    LLVMDWARFSourceLanguagePython => 19
    // New in DWARF v5:
    LLVMDWARFSourceLanguageOpenCL => 20
    LLVMDWARFSourceLanguageGo => 21
    LLVMDWARFSourceLanguageModula3 => 22
    LLVMDWARFSourceLanguageHaskell => 23
    LLVMDWARFSourceLanguageC_plus_plus_03 => 24
    LLVMDWARFSourceLanguageC_plus_plus_11 => 25
    LLVMDWARFSourceLanguageOCaml => 26
    LLVMDWARFSourceLanguageRust => 27
    LLVMDWARFSourceLanguageC11 => 28
    LLVMDWARFSourceLanguageSwift => 29
    LLVMDWARFSourceLanguageJulia => 30
    LLVMDWARFSourceLanguageDylan => 31
    LLVMDWARFSourceLanguageC_plus_plus_14 => 32
    LLVMDWARFSourceLanguageFortran03 => 33
    LLVMDWARFSourceLanguageFortran08 => 34
    LLVMDWARFSourceLanguageRenderScript => 35
    LLVMDWARFSourceLanguageBLISS => 36
    LLVMDWARFSourceLanguageKotlin => 37
    LLVMDWARFSourceLanguageZig => 38
    LLVMDWARFSourceLanguageCrystal => 39
    LLVMDWARFSourceLanguageC_plus_plus_17 => 40
    LLVMDWARFSourceLanguageC_plus_plus_20 => 41
    LLVMDWARFSourceLanguageC17 => 42
    LLVMDWARFSourceLanguageFortran18 => 43
    LLVMDWARFSourceLanguageAda2005 => 44
    LLVMDWARFSourceLanguageAda2012 => 45
    LLVMDWARFSourceLanguageHIP => 46
    LLVMDWARFSourceLanguageAssembly => 47
    LLVMDWARFSourceLanguageC_sharp => 48
    LLVMDWARFSourceLanguageMojo => 49
    LLVMDWARFSourceLanguageGLSL => 50
    LLVMDWARFSourceLanguageGLSL_ES => 51
    LLVMDWARFSourceLanguageHLSL => 52
    LLVMDWARFSourceLanguageOpenCL_CPP => 53
    LLVMDWARFSourceLanguageCPP_for_OpenCL => 54
    LLVMDWARFSourceLanguageSYCL => 55
    LLVMDWARFSourceLanguageRuby => 56
    LLVMDWARFSourceLanguageMove => 57
    LLVMDWARFSourceLanguageHylo => 58
    LLVMDWARFSourceLanguageMetal => 59

    // Vendor extensions:
    LLVMDWARFSourceLanguageMips_Assembler => 60
    LLVMDWARFSourceLanguageGOOGLE_RenderScript => 61
    LLVMDWARFSourceLanguageBORLAND_Delphi => 62
  }
}

///|
pub fn LLVMDWARFSourceLanguage::from_int(i : Int) -> LLVMDWARFSourceLanguage {
  match i {
    0 => LLVMDWARFSourceLanguageC89
    1 => LLVMDWARFSourceLanguageC
    2 => LLVMDWARFSourceLanguageAda83
    3 => LLVMDWARFSourceLanguageC_plus_plus
    4 => LLVMDWARFSourceLanguageCobol74
    5 => LLVMDWARFSourceLanguageCobol85
    6 => LLVMDWARFSourceLanguageFortran77
    7 => LLVMDWARFSourceLanguageFortran90
    8 => LLVMDWARFSourceLanguagePascal83
    9 => LLVMDWARFSourceLanguageModula2
    10 => LLVMDWARFSourceLanguageJava
    11 => LLVMDWARFSourceLanguageC99
    12 => LLVMDWARFSourceLanguageAda95
    13 => LLVMDWARFSourceLanguageFortran95
    14 => LLVMDWARFSourceLanguagePLI
    15 => LLVMDWARFSourceLanguageObjC
    16 => LLVMDWARFSourceLanguageObjC_plus_plus
    17 => LLVMDWARFSourceLanguageUPC
    18 => LLVMDWARFSourceLanguageD
    19 => LLVMDWARFSourceLanguagePython
    20 => LLVMDWARFSourceLanguageOpenCL
    21 => LLVMDWARFSourceLanguageGo
    22 => LLVMDWARFSourceLanguageModula3
    23 => LLVMDWARFSourceLanguageHaskell
    24 => LLVMDWARFSourceLanguageC_plus_plus_03
    25 => LLVMDWARFSourceLanguageC_plus_plus_11
    26 => LLVMDWARFSourceLanguageOCaml
    27 => LLVMDWARFSourceLanguageRust
    28 => LLVMDWARFSourceLanguageC11
    29 => LLVMDWARFSourceLanguageSwift
    30 => LLVMDWARFSourceLanguageJulia
    31 => LLVMDWARFSourceLanguageDylan
    32 => LLVMDWARFSourceLanguageC_plus_plus_14
    33 => LLVMDWARFSourceLanguageFortran03
    34 => LLVMDWARFSourceLanguageFortran08
    35 => LLVMDWARFSourceLanguageRenderScript
    36 => LLVMDWARFSourceLanguageBLISS
    37 => LLVMDWARFSourceLanguageKotlin
    38 => LLVMDWARFSourceLanguageZig
    39 => LLVMDWARFSourceLanguageCrystal
    40 => LLVMDWARFSourceLanguageC_plus_plus_17
    41 => LLVMDWARFSourceLanguageC_plus_plus_20
    42 => LLVMDWARFSourceLanguageC17
    43 => LLVMDWARFSourceLanguageFortran18
    44 => LLVMDWARFSourceLanguageAda2005
    45 => LLVMDWARFSourceLanguageAda2012
    46 => LLVMDWARFSourceLanguageHIP
    47 => LLVMDWARFSourceLanguageAssembly
    48 => LLVMDWARFSourceLanguageC_sharp
    49 => LLVMDWARFSourceLanguageMojo
    50 => LLVMDWARFSourceLanguageGLSL
    51 => LLVMDWARFSourceLanguageGLSL_ES
    52 => LLVMDWARFSourceLanguageHLSL
    53 => LLVMDWARFSourceLanguageOpenCL_CPP
    54 => LLVMDWARFSourceLanguageCPP_for_OpenCL
    55 => LLVMDWARFSourceLanguageSYCL
    56 => LLVMDWARFSourceLanguageRuby
    57 => LLVMDWARFSourceLanguageMove
    58 => LLVMDWARFSourceLanguageHylo
    59 => LLVMDWARFSourceLanguageMetal
    60 => LLVMDWARFSourceLanguageMips_Assembler
    61 => LLVMDWARFSourceLanguageGOOGLE_RenderScript
    62 => LLVMDWARFSourceLanguageBORLAND_Delphi
    _ =>
      abort(
        "Invalid LLVMDWARFSourceLanguage Number in `LLVMDWARFSourceLanguage::from_int`",
      )
  }
}

///| The amount of debug information to emit.
pub(all) enum LLVMDWARFEmissionKind {
  LLVMDWARFEmissionNone
  LLVMDWARFEmissionFull
  LLVMDWARFEmissionLineTablesOnly
}

///|
pub fn LLVMDWARFEmissionKind::to_int(self : LLVMDWARFEmissionKind) -> Int {
  match self {
    LLVMDWARFEmissionNone => 0
    LLVMDWARFEmissionFull => 1
    LLVMDWARFEmissionLineTablesOnly => 2
  }
}

///|
pub fn LLVMDWARFEmissionKind::from_int(idx : Int) -> LLVMDWARFEmissionKind {
  match idx {
    0 => LLVMDWARFEmissionNone
    1 => LLVMDWARFEmissionFull
    2 => LLVMDWARFEmissionLineTablesOnly
    _ =>
      abort(
        "Invalid LLVMDWARFEmissionKind Number in `LLVMDWARFEmissionKind::from_int`",
      )
  }
}

///| The kind of metadata nodes.
pub(all) enum LLVMMDNodeKind {
  LLVMMDStringMetadataKind
  LLVMConstantAsMetadataMetadataKind
  LLVMLocalAsMetadataMetadataKind
  LLVMDistinctMDOperandPlaceholderMetadataKind
  LLVMMDTupleMetadataKind
  LLVMDILocationMetadataKind
  LLVMDIExpressionMetadataKind
  LLVMDIGlobalVariableExpressionMetadataKind
  LLVMGenericDINodeMetadataKind
  LLVMDISubrangeMetadataKind
  LLVMDIEnumeratorMetadataKind
  LLVMDIBasicTypeMetadataKind
  LLVMDIDerivedTypeMetadataKind
  LLVMDICompositeTypeMetadataKind
  LLVMDISubroutineTypeMetadataKind
  LLVMDIFileMetadataKind
  LLVMDICompileUnitMetadataKind
  LLVMDISubprogramMetadataKind
  LLVMDILexicalBlockMetadataKind
  LLVMDILexicalBlockFileMetadataKind
  LLVMDINamespaceMetadataKind
  LLVMDIModuleMetadataKind
  LLVMDITemplateTypeParameterMetadataKind
  LLVMDITemplateValueParameterMetadataKind
  LLVMDIGlobalVariableMetadataKind
  LLVMDILocalVariableMetadataKind
  LLVMDILabelMetadataKind
  LLVMDIObjCPropertyMetadataKind
  LLVMDIImportedEntityMetadataKind
  LLVMDIMacroMetadataKind
  LLVMDIMacroFileMetadataKind
  LLVMDICommonBlockMetadataKind
  LLVMDIStringTypeMetadataKind
  LLVMDIGenericSubrangeMetadataKind
  LLVMDIArgListMetadataKind
  LLVMDIAssignIDMetadataKind
}

///|
pub fn LLVMMDNodeKind::to_int(self : LLVMMDNodeKind) -> Int {
  match self {
    LLVMMDStringMetadataKind => 0
    LLVMConstantAsMetadataMetadataKind => 1
    LLVMLocalAsMetadataMetadataKind => 2
    LLVMDistinctMDOperandPlaceholderMetadataKind => 3
    LLVMMDTupleMetadataKind => 4
    LLVMDILocationMetadataKind => 5
    LLVMDIExpressionMetadataKind => 6
    LLVMDIGlobalVariableExpressionMetadataKind => 7
    LLVMGenericDINodeMetadataKind => 8
    LLVMDISubrangeMetadataKind => 9
    LLVMDIEnumeratorMetadataKind => 10
    LLVMDIBasicTypeMetadataKind => 11
    LLVMDIDerivedTypeMetadataKind => 12
    LLVMDICompositeTypeMetadataKind => 13
    LLVMDISubroutineTypeMetadataKind => 14
    LLVMDIFileMetadataKind => 15
    LLVMDICompileUnitMetadataKind => 16
    LLVMDISubprogramMetadataKind => 17
    LLVMDILexicalBlockMetadataKind => 18
    LLVMDILexicalBlockFileMetadataKind => 19
    LLVMDINamespaceMetadataKind => 20
    LLVMDIModuleMetadataKind => 21
    LLVMDITemplateTypeParameterMetadataKind => 22
    LLVMDITemplateValueParameterMetadataKind => 23
    LLVMDIGlobalVariableMetadataKind => 24
    LLVMDILocalVariableMetadataKind => 25
    LLVMDILabelMetadataKind => 26
    LLVMDIObjCPropertyMetadataKind => 27
    LLVMDIImportedEntityMetadataKind => 28
    LLVMDIMacroMetadataKind => 29
    LLVMDIMacroFileMetadataKind => 30
    LLVMDICommonBlockMetadataKind => 31
    LLVMDIStringTypeMetadataKind => 32
    LLVMDIGenericSubrangeMetadataKind => 33
    LLVMDIArgListMetadataKind => 34
    LLVMDIAssignIDMetadataKind => 35
  }
}

///|
pub fn LLVMMDNodeKind::from_int(i : Int) -> LLVMMDNodeKind {
  match i {
    0 => LLVMMDStringMetadataKind
    1 => LLVMConstantAsMetadataMetadataKind
    2 => LLVMLocalAsMetadataMetadataKind
    3 => LLVMDistinctMDOperandPlaceholderMetadataKind
    4 => LLVMMDTupleMetadataKind
    5 => LLVMDILocationMetadataKind
    6 => LLVMDIExpressionMetadataKind
    7 => LLVMDIGlobalVariableExpressionMetadataKind
    8 => LLVMGenericDINodeMetadataKind
    9 => LLVMDISubrangeMetadataKind
    10 => LLVMDIEnumeratorMetadataKind
    11 => LLVMDIBasicTypeMetadataKind
    12 => LLVMDIDerivedTypeMetadataKind
    13 => LLVMDICompositeTypeMetadataKind
    14 => LLVMDISubroutineTypeMetadataKind
    15 => LLVMDIFileMetadataKind
    16 => LLVMDICompileUnitMetadataKind
    17 => LLVMDISubprogramMetadataKind
    18 => LLVMDILexicalBlockMetadataKind
    19 => LLVMDILexicalBlockFileMetadataKind
    20 => LLVMDINamespaceMetadataKind
    21 => LLVMDIModuleMetadataKind
    22 => LLVMDITemplateTypeParameterMetadataKind
    23 => LLVMDITemplateValueParameterMetadataKind
    24 => LLVMDIGlobalVariableMetadataKind
    25 => LLVMDILocalVariableMetadataKind
    26 => LLVMDILabelMetadataKind
    27 => LLVMDIObjCPropertyMetadataKind
    28 => LLVMDIImportedEntityMetadataKind
    29 => LLVMDIMacroMetadataKind
    30 => LLVMDIMacroFileMetadataKind
    31 => LLVMDICommonBlockMetadataKind
    32 => LLVMDIStringTypeMetadataKind
    33 => LLVMDIGenericSubrangeMetadataKind
    34 => LLVMDIArgListMetadataKind
    35 => LLVMDIAssignIDMetadataKind
    _ => abort("Invalid LLVMMDNodeKind Number in `LLVMMDNodeKind::from_int`")
  }
}

///|
pub(all) enum LLVMVerifierFailureAction {
  LLVMAbortProcessAction
  LLVMPrintMessageAction
  LLVMReturnStatusAction
}

///|
pub fn LLVMVerifierFailureAction::to_int(
  self : LLVMVerifierFailureAction
) -> Int {
  match self {
    LLVMAbortProcessAction => 0
    LLVMPrintMessageAction => 1
    LLVMReturnStatusAction => 2
  }
}

///|
pub fn LLVMVerifierFailureAction::from_int(
  idx : Int
) -> LLVMVerifierFailureAction {
  match idx {
    0 => LLVMAbortProcessAction
    1 => LLVMPrintMessageAction
    2 => LLVMReturnStatusAction
    _ =>
      abort(
        "Invalid LLVMVerifierFailureAction Number in `LLVMVerifierFailureAction::from_int`",
      )
  }
}

///|
pub(all) enum LLVMRemarkType {
  LLVMRemarkTypeUnknown
  LLVMRemarkTypePassed
  LLVMRemarkTypeMissed
  LLVMRemarkTypeAnalysis
  LLVMRemarkTypeAnalysisFPCommute
  LLVMRemarkTypeAnalysisAliasing
  LLVMRemarkTypeFailure
}

///|
pub fn LLVMRemarkType::to_int(self : LLVMRemarkType) -> Int {
  match self {
    LLVMRemarkTypeUnknown => 0
    LLVMRemarkTypePassed => 1
    LLVMRemarkTypeMissed => 2
    LLVMRemarkTypeAnalysis => 3
    LLVMRemarkTypeAnalysisFPCommute => 4
    LLVMRemarkTypeAnalysisAliasing => 5
    LLVMRemarkTypeFailure => 6
  }
}

///|
pub fn LLVMRemarkType::from_int(idx : Int) -> LLVMRemarkType {
  match idx {
    0 => LLVMRemarkTypeUnknown
    1 => LLVMRemarkTypePassed
    2 => LLVMRemarkTypeMissed
    3 => LLVMRemarkTypeAnalysis
    4 => LLVMRemarkTypeAnalysisFPCommute
    5 => LLVMRemarkTypeAnalysisAliasing
    6 => LLVMRemarkTypeFailure
    _ => abort("Invalid LLVMRemarkType Number in `LLVMRemarkType::from_int`")
  }
}

///|
pub(all) enum LLVMJITSymbolGenericFlags {
  LLVMJITSymbolGenericFlagsNone
  LLVMJITSymbolGenericFlagsExported
  LLVMJITSymbolGenericFlagsWeak
  LLVMJITSymbolGenericFlagsCallable
  LLVMJITSymbolGenericFlagsMaterializationSideEffectsOnly
}

///|
pub fn LLVMJITSymbolGenericFlags::to_int(
  self : LLVMJITSymbolGenericFlags
) -> Int {
  match self {
    LLVMJITSymbolGenericFlagsNone => 0
    LLVMJITSymbolGenericFlagsExported => 1
    LLVMJITSymbolGenericFlagsWeak => 2
    LLVMJITSymbolGenericFlagsCallable => 4
    LLVMJITSymbolGenericFlagsMaterializationSideEffectsOnly => 8
  }
}

///|
pub fn LLVMJITSymbolGenericFlags::from_int(
  idx : Int
) -> LLVMJITSymbolGenericFlags {
  match idx {
    0 => LLVMJITSymbolGenericFlagsNone
    1 => LLVMJITSymbolGenericFlagsExported
    2 => LLVMJITSymbolGenericFlagsWeak
    4 => LLVMJITSymbolGenericFlagsCallable
    8 => LLVMJITSymbolGenericFlagsMaterializationSideEffectsOnly
    _ =>
      abort(
        "Invalid LLVMJITSymbolGenericFlags Number in `LLVMJITSymbolGenericFlags::from_int`",
      )
  }
}
