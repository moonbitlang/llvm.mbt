// extern types
type CStr
type LLVMBool Int derive(Eq)
pub type LLVMAttributeIndex UInt derive(Eq)
pub type LLVMFastMathFlags UInt derive(Eq)

pub type AddressSpace UInt derive(Eq)
pub type FastMathFlags UInt derive(Eq)

// Dummpy function, only for eliminate warning
// FIXME: Remove this function
pub fn LLVMAttributeIndex::new(idx: UInt) -> LLVMAttributeIndex {
  LLVMAttributeIndex(idx)
}

pub fn LLVMFastMathFlags::into(self: LLVMFastMathFlags) -> FastMathFlags {
  guard let LLVMFastMathFlags(f) = self
  FastMathFlags(f)
}

pub fn FastMathFlags::to_llvm(self: FastMathFlags) -> LLVMFastMathFlags {
  guard let FastMathFlags(f) = self
  LLVMFastMathFlags(f)
}

///| llvm memory buffer
pub type LLVMMemoryBufferRef

///| llvm context
pub type LLVMContextRef

///| llvm module
pub type LLVMModuleRef

///| llvm BasicBlock
pub type LLVMBasicBlockRef

///| llvm metadata
pub type LLVMMetadataRef

///| llvm md node
pub type LLVMNamedMDNodeRef
// pub type LLVMValueMetadataEntry

///| llvm builder
pub type LLVMBuilderRef
// pub type LLVMDIBuilderRef

///| llvm module provider
pub type LLVMModuleProviderRef

///| llvm pass manager
pub type LLVMPassManagerRef

///| llvm use
pub type LLVMUseRef

///| llvm values
pub type LLVMValueRef

///| llvm types
pub type LLVMTypeRef

///| llvm operand bundles
pub type LLVMOperandBundleRef

///| llvm attributes
pub type LLVMAttributeRef

///| llvm diagnostic info
pub type LLVMDiagnosticInfoRef
// pub type LLVMComdatRef
// pub type LLVMModuleFlagEntry
// pub type LLVMJITEventListenerRef
// pub type LLVMBinaryRef

///| llvm debug record refs
pub type LLVMDbgRecordRef

///| Instruction opcodes
pub enum LLVMOpcode {
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

pub fn LLVMOpcode::to_int(self: LLVMOpcode) -> Int {
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

pub fn LLVMOpcode::from_int(idx: Int) -> LLVMOpcode {
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

pub enum LLVMTypeKind {
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
}

fn LLVMTypeKind::to_int(self: LLVMTypeKind) -> Int {
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

pub fn LLVMTypeKind::from_int(idx: Int) -> LLVMTypeKind {
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

pub enum LLVMLinkage {
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

fn LLVMLinkage::to_int(self: LLVMLinkage) -> Int {
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

fn LLVMLinkage::from_int(idx: Int) -> LLVMLinkage {
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

pub enum LLVMVisibility {
  LLVMDefaultVisibility
  LLVMHiddenVisibility
  LLVMProtectedVisibility
}

pub fn LLVMVisibility::to_int(self: LLVMVisibility) -> Int {
  match self {
    LLVMDefaultVisibility => 0
    LLVMHiddenVisibility => 1
    LLVMProtectedVisibility => 2
  }
}

pub fn LLVMVisibility::from_int(idx: Int) -> LLVMVisibility {
  match idx {
    0 => LLVMDefaultVisibility
    1 => LLVMHiddenVisibility
    2 => LLVMProtectedVisibility
    _ => abort("Invalid LLVMVisibility Number in `LLVMVisibility::from_int`")
  }
}

pub enum LLVMUnnamedAddr {
  LLVMNoUnnamedAddr
  LLVMLocalUnnamedAddr
  LLVMGlobalUnnamedAddr
}

pub fn LLVMUnnamedAddr::to_int(self: LLVMUnnamedAddr) -> Int {
  match self {
    LLVMNoUnnamedAddr => 0
    LLVMLocalUnnamedAddr => 1
    LLVMGlobalUnnamedAddr => 2
  }
}

pub fn LLVMUnnamedAddr::from_int(idx: Int) -> LLVMUnnamedAddr {
  match idx {
    0 => LLVMNoUnnamedAddr
    1 => LLVMLocalUnnamedAddr
    2 => LLVMGlobalUnnamedAddr
    _ => abort("Invalid LLVMUnnamedAddr Number in `LLVMUnnamedAddr::from_int`")
  }
}

pub enum LLVMDLLStorageClass {
  LLVMDefaultStorageClass
  LLVMDLLImportStorageClass
  LLVMDLLExportStorageClass
}

pub fn LLVMDLLStorageClass::to_int(self: LLVMDLLStorageClass) -> Int {
  match self {
    LLVMDefaultStorageClass => 0
    LLVMDLLImportStorageClass => 1
    LLVMDLLExportStorageClass => 2
  }
}

pub fn LLVMDLLStorageClass::from_int(idx: Int) -> LLVMDLLStorageClass {
  match idx {
    0 => LLVMDefaultStorageClass
    1 => LLVMDLLImportStorageClass
    2 => LLVMDLLExportStorageClass
    _ => abort("Invalid LLVMDLLStorageClass Number in `LLVMDLLStorageClass::from_int`")
  }
}

pub enum LLVMCallConv {
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

pub fn LLVMCallConv::to_int(self: LLVMCallConv) -> Int {
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

pub fn LLVMCallConv::from_int(i: Int) -> LLVMCallConv {
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
    10 =>LLVMX86StdcallCallConv
    11 =>LLVMX86FastcallCallConv
    12 =>LLVMARMAPCSCallConv
    13 =>LLVMARMAAPCSCallConv
    14 =>LLVMARMAAPCSVFPCallConv
    15 =>LLVMMSP430INTRCallConv
    16 =>LLVMX86ThisCallCallConv
    17 =>LLVMPTXKernelCallConv
    18 =>LLVMPTXDeviceCallConv
    19 =>LLVMSPIRFUNCCallConv
    20 =>LLVMSPIRKERNELCallConv
    21 =>LLVMIntelOCLBICallConv
    22 =>LLVMX8664SysVCallConv
    23 =>LLVMWin64CallConv
    24 =>LLVMX86VectorCallCallConv
    25 =>LLVMHHVMCallConv
    26 =>LLVMHHVMCCallConv
    27 =>LLVMX86INTRCallConv
    28 =>LLVMAVRINTRCallConv
    29 =>LLVMAVRSIGNALCallConv
    30 =>LLVMAVRBUILTINCallConv
    31 =>LLVMAMDGPUVSCallConv
    32 =>LLVMAMDGPUGSCallConv
    33 =>LLVMAMDGPUPSCallConv
    34 =>LLVMAMDGPUCSCallConv
    35 =>LLVMAMDGPUKERNELCallConv
    36 =>LLVMX86RegCallCallConv
    37 =>LLVMAMDGPUHSCallConv
    38 =>LLVMMSP430BUILTINCallConv
    39 =>LLVMAMDGPULSCallConv
    40 =>LLVMAMDGPUESCallConv
    _ => abort("Invalid LLVMCallConv Number in `LLVMCallConv::from_int`")
  }
}

pub enum LLVMValueKind {
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

pub fn LLVMValueKind::to_int(self: LLVMValueKind) -> Int {
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

pub fn LLVMValueKind::from_int(idx: Int) -> LLVMValueKind {
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

pub enum LLVMIntPredicate {
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

pub fn LLVMIntPredicate::to_int(self: LLVMIntPredicate) -> Int {
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

pub fn LLVMIntPredicate::from_int(idx: Int) -> LLVMIntPredicate {
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
    _ => abort("Invalid LLVMIntPredicate Number in `LLVMIntPredicate::from_int`")
  }
}


pub enum LLVMRealPredicate {
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

pub fn LLVMRealPredicate::to_int(self: LLVMRealPredicate) -> Int {
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

pub fn LLVMRealPredicate::from_int(idx: Int) -> LLVMRealPredicate {
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
    _ => abort("Invalid LLVMRealPredicate Number in `LLVMRealPredicate::from_int`")
  }
}

pub enum LLVMLandingPadClauseTy {
  LLVMLandingPadCatch
  LLVMLandingPadFilter
}

pub fn LLVMLandingPadClauseTy::to_int(self: LLVMLandingPadClauseTy) -> Int {
  match self {
    LLVMLandingPadCatch => 0
    LLVMLandingPadFilter => 1
  }
}

pub fn LLVMLandingPadClauseTy::from_int(idx: Int) -> LLVMLandingPadClauseTy {
  match idx {
    0 => LLVMLandingPadCatch
    1 => LLVMLandingPadFilter
    _ => abort("Invalid LLVMLandingPadClauseTy Number in `LLVMLandingPadClauseTy::from_int`")
  }
}

pub enum LLVMThreadLocalMode {
  LLVMNotThreadLocal
  LLVMGeneralDynamicTLSModel
  LLVMLocalDynamicTLSModel
  LLVMInitialExecTLSModel
  LLVMLocalExecTLSModel
}

pub fn LLVMThreadLocalMode::to_int(self: LLVMThreadLocalMode) -> Int {
  match self {
    LLVMNotThreadLocal => 0
    LLVMGeneralDynamicTLSModel => 1
    LLVMLocalDynamicTLSModel => 2
    LLVMInitialExecTLSModel => 3
    LLVMLocalExecTLSModel => 4
  }
}

pub fn LLVMThreadLocalMode::from_int(idx: Int) -> LLVMThreadLocalMode {
  match idx {
    0 => LLVMNotThreadLocal
    1 => LLVMGeneralDynamicTLSModel
    2 => LLVMLocalDynamicTLSModel
    3 => LLVMInitialExecTLSModel
    4 => LLVMLocalExecTLSModel
    _ => abort("Invalid LLVMThreadLocalMode Number in `LLVMThreadLocalMode::from_int`")
  }
}

pub enum LLVMAtomicOrdering {
  LLVMAtomicOrderingNotAtomic
  LLVMAtomicOrderingUnordered
  LLVMAtomicOrderingMonotonic
  LLVMAtomicOrderingAcquire
  LLVMAtomicOrderingRelease
  LLVMAtomicOrderingAcquireRelease
  LLVMAtomicOrderingSequentiallyConsistent
}

pub fn LLVMAtomicOrdering::to_int(self: LLVMAtomicOrdering) -> Int {
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

pub fn LLVMAtomicOrdering::from_int(idx: Int) -> LLVMAtomicOrdering {
  match idx {
    0 => LLVMAtomicOrderingNotAtomic
    1 => LLVMAtomicOrderingUnordered
    2 => LLVMAtomicOrderingMonotonic
    3 => LLVMAtomicOrderingAcquire
    4 => LLVMAtomicOrderingRelease
    5 => LLVMAtomicOrderingAcquireRelease
    6 => LLVMAtomicOrderingSequentiallyConsistent
    _ => abort("Invalid LLVMAtomicOrdering Number in `LLVMAtomicOrdering::from_int`")
  }
}

pub enum LLVMAtomicRMWBinOp {
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

pub fn LLVMAtomicRMWBinOp::to_int(self: LLVMAtomicRMWBinOp) -> Int {
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

pub fn LLVMAtomicRMWBinOp::from_int(idx: Int) -> LLVMAtomicRMWBinOp {
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
    _ => abort("Invalid LLVMAtomicRMWBinOp Number in `LLVMAtomicRMWBinOp::from_int`")
  }
}

pub enum LLVMDiagnosticSeverity {
    LLVMDSError
    LLVMDSWarning
    LLVMDSRemark
    LLVMDSNote
}

pub fn LLVMDiagnosticSeverity::to_int(self: LLVMDiagnosticSeverity) -> Int {
  match self {
    LLVMDSError => 0
    LLVMDSWarning => 1
    LLVMDSRemark => 2
    LLVMDSNote => 3
  }
}

pub fn LLVMDiagnosticSeverity::from_int(idx: Int) -> LLVMDiagnosticSeverity {
  match idx {
    0 => LLVMDSError
    1 => LLVMDSWarning
    2 => LLVMDSRemark
    3 => LLVMDSNote
    _ => abort("Invalid LLVMDiagnosticSeverity Number in `LLVMDiagnosticSeverity::from_int`")
  }
}

pub enum LLVMInlineAsmDialect {
  LLVMInlineAsmDialectATT
  LLVMInlineAsmDialectIntel
}

pub fn LLVMInlineAsmDialect::to_int(self: LLVMInlineAsmDialect) -> Int {
  match self {
    LLVMInlineAsmDialectATT => 0
    LLVMInlineAsmDialectIntel => 1
  }
}

pub fn LLVMInlineAsmDialect::from_int(idx: Int) -> LLVMInlineAsmDialect {
  match idx {
    0 => LLVMInlineAsmDialectATT
    1 => LLVMInlineAsmDialectIntel
    _ => abort("Invalid LLVMInlineAsmDialect Number in `LLVMInlineAsmDialect::from_int`")
  }
}

//
// typedef enum {
//   /**
//    * Emits an error if two values disagree, otherwise the resulting value is
//    * that of the operands.
//    *
//    * @see Module::ModFlagBehavior::Error
//    */
//   LLVMModuleFlagBehaviorError,
//   /**
//    * Emits a warning if two values disagree. The result value will be the
//    * operand for the flag from the first module being linked.
//    *
//    * @see Module::ModFlagBehavior::Warning
//    */
//   LLVMModuleFlagBehaviorWarning,
//   /**
//    * Adds a requirement that another module flag be present and have a
//    * specified value after linking is performed. The value must be a metadata
//    * pair, where the first element of the pair is the ID of the module flag
//    * to be restricted, and the second element of the pair is the value the
//    * module flag should be restricted to. This behavior can be used to
//    * restrict the allowable results (via triggering of an error) of linking
//    * IDs with the **Override** behavior.
//    *
//    * @see Module::ModFlagBehavior::Require
//    */
//   LLVMModuleFlagBehaviorRequire,
//   /**
//    * Uses the specified value, regardless of the behavior or value of the
//    * other module. If both modules specify **Override**, but the values
//    * differ, an error will be emitted.
//    *
//    * @see Module::ModFlagBehavior::Override
//    */
//   LLVMModuleFlagBehaviorOverride,
//   /**
//    * Appends the two values, which are required to be metadata nodes.
//    *
//    * @see Module::ModFlagBehavior::Append
//    */
//   LLVMModuleFlagBehaviorAppend,
//   /**
//    * Appends the two values, which are required to be metadata
//    * nodes. However, duplicate entries in the second list are dropped
//    * during the append operation.
//    *
//    * @see Module::ModFlagBehavior::AppendUnique
//    */
//   LLVMModuleFlagBehaviorAppendUnique,
// } LLVMModuleFlagBehavior;

pub enum LLVMModuleFlagBehavior {
  LLVMModuleFlagBehaviorError
  LLVMModuleFlagBehaviorWarning
  LLVMModuleFlagBehaviorRequire
  LLVMModuleFlagBehaviorOverride
  LLVMModuleFlagBehaviorAppend
  LLVMModuleFlagBehaviorAppendUnique
}

pub fn LLVMModuleFlagBehavior::to_int(self: LLVMModuleFlagBehavior) -> Int {
  match self {
    LLVMModuleFlagBehaviorError => 0
    LLVMModuleFlagBehaviorWarning => 1
    LLVMModuleFlagBehaviorRequire => 2
    LLVMModuleFlagBehaviorOverride => 3
    LLVMModuleFlagBehaviorAppend => 4
    LLVMModuleFlagBehaviorAppendUnique => 5
  }
}

pub fn LLVMModuleFlagBehavior::from_int(idx: Int) -> LLVMModuleFlagBehavior {
  match idx {
    0 => LLVMModuleFlagBehaviorError
    1 => LLVMModuleFlagBehaviorWarning
    2 => LLVMModuleFlagBehaviorRequire
    3 => LLVMModuleFlagBehaviorOverride
    4 => LLVMModuleFlagBehaviorAppend
    5 => LLVMModuleFlagBehaviorAppendUnique
    _ => abort("Invalid LLVMModuleFlagBehavior Number in `LLVMModuleFlagBehavior::from_int`")
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



pub enum LLVMTailCallKind {
  LLVMTailCallKindNone
  LLVMTailCallKindTail
  LLVMTailCallKindMustTail
  LLVMTailCallKindNoTail
}

pub fn LLVMTailCallKind::to_int(self: LLVMTailCallKind) -> Int {
  match self {
    LLVMTailCallKindNone => 0
    LLVMTailCallKindTail => 1
    LLVMTailCallKindMustTail => 2
    LLVMTailCallKindNoTail => 3
  }
}

pub fn LLVMTailCallKind::from_int(idx: Int) -> LLVMTailCallKind {
  match idx {
    0 => LLVMTailCallKindNone
    1 => LLVMTailCallKindTail
    2 => LLVMTailCallKindMustTail
    3 => LLVMTailCallKindNoTail
    _ => abort("Invalid LLVMTailCallKind Number in `LLVMTailCallKind::from_int`")
  }
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
