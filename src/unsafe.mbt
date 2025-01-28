// LLVMTypes
type LLVMBool Int derive(Eq)
pub type LLVMAttributeIndex UInt derive(Eq)
pub type LLVMFastMathFlags UInt derive(Eq)
pub type LLVMDWARFTypeEncoding UInt derive(Eq)
pub type LLVMMetadataKind UInt derive(Eq)

// Dummy function just for eliminating the warning
pub fn LLVMDWARFTypeEncoding::new(idx: UInt) -> LLVMDWARFTypeEncoding {
  LLVMDWARFTypeEncoding(idx)
}

// Dummy function just for eliminating the warning
pub fn LLVMMetadataKind::new(idx: UInt) -> LLVMMetadataKind {
  LLVMMetadataKind(idx)
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
pub type LLVMValueMetadataEntry

///| llvm builder
pub type LLVMBuilderRef
pub type LLVMDIBuilderRef

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
pub type LLVMComdatRef
pub type LLVMModuleFlagEntry
pub type LLVMJITEventListenerRef
pub type LLVMBinaryRef
pub type LLVMTargetRef
pub type LLVMTargetMachineOptionsRef
pub type LLVMTargetMachineRef

///| llvm debug record refs
pub type LLVMDbgRecordRef

pub type LLVMGenericValueRef
pub type LVMExecutionEngineRef
pub type LVMMCJITMemoryManagerRef

pub fn LLVMDWARFTypeEncoding::into(self: LLVMDWARFTypeEncoding) -> UInt {
  guard let LLVMDWARFTypeEncoding(u) = self
  u
}

pub fn LLVMMetadataKind::into(self: LLVMMetadataKind) -> UInt {
  guard let LLVMMetadataKind(u) = self
  u
}


// Utils
extern "C" fn moonbit_str_to_c_str(
  s: String
) -> CStr = "moonbit_str_to_c_str"
extern "C" fn c_str_to_moonbit_str(
  s: CStr
) -> String = "c_str_to_moonbit_str"
extern "C" fn c_str_to_moonbit_str_with_length(
  s: CStr,
  len: UInt
) -> String = "c_str_to_moonbit_str_with_length"
extern "C" fn llvm_type_is_null(ty: LLVMTypeRef) -> LLVMBool = "__llvm_type_is_null"
fn LLVMTypeRef::is_null(self: LLVMTypeRef) -> Bool {
  llvm_type_is_null(self).to_moonbit_bool()
}

extern "C" fn llvm_value_is_null(ty: LLVMValueRef) -> LLVMBool = "__llvm_value_is_null"
fn LLVMValueRef::is_null(self: LLVMValueRef) -> Bool {
  llvm_value_is_null(self).to_moonbit_bool()
}

extern "C" fn llvm_use_is_null(u: LLVMUseRef) -> LLVMBool = "__llvm_use_is_null"
fn LLVMUseRef::is_null(self: LLVMUseRef) -> Bool {
  llvm_use_is_null(self).to_moonbit_bool()
}

extern "C" fn llvm_bb_is_null(bb: LLVMBasicBlockRef) -> LLVMBool = "__llvm_bb_is_null"
fn LLVMBasicBlockRef::is_null(self: LLVMBasicBlockRef) -> Bool {
  llvm_bb_is_null(self).to_moonbit_bool()
}

extern "C" fn llvm_attr_is_null(attr: LLVMAttributeRef) -> LLVMBool = "__llvm_attr_is_null"
fn LLVMAttributeRef::is_null(self: LLVMAttributeRef) -> Bool {
  llvm_attr_is_null(self).to_moonbit_bool()
}

// enums
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
} derive(Show, Eq)

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
} derive(Show, Eq)

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

pub enum LLVMModuleFlagBehavior {
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

  //// 
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

pub enum LLVMComdatSelectionKind {
  LLVMAnyComdatSelectionKind
  LLVMExactMatchComdatSelectionKind
  LLVMLargestComdatSelectionKind
  LLVMNoDeduplicateComdatSelectionKind
  LLVMSameSizeComdatSelectionKind
}

pub fn LLVMComdatSelectionKind::to_int(self: LLVMComdatSelectionKind) -> Int {
  match self {
    LLVMAnyComdatSelectionKind => 0
    LLVMExactMatchComdatSelectionKind => 1
    LLVMLargestComdatSelectionKind => 2
    LLVMNoDeduplicateComdatSelectionKind => 3
    LLVMSameSizeComdatSelectionKind => 4
  }
}

pub fn LLVMComdatSelectionKind::from_int(idx: Int) -> LLVMComdatSelectionKind {
  match idx {
    0 => LLVMAnyComdatSelectionKind
    1 => LLVMExactMatchComdatSelectionKind
    2 => LLVMLargestComdatSelectionKind
    3 => LLVMNoDeduplicateComdatSelectionKind
    4 => LLVMSameSizeComdatSelectionKind
    _ => abort("Invalid LLVMComdatSelectionKind Number in `LLVMComdatSelectionKind::from_int`")
  }
}

pub enum LLVMLinkerMode {
  LLVMLinkerDestroySource
  LLVMLinkerPreserveSource_Removed
}

pub fn LLVMLinkerMode::to_int(self: LLVMLinkerMode) -> Int {
  match self {
    LLVMLinkerDestroySource => 0
    LLVMLinkerPreserveSource_Removed => 1
  }
}

pub fn LLVMLinkerMode::from_int(idx: Int) -> LLVMLinkerMode {
  match idx {
    0 => LLVMLinkerDestroySource
    1 => LLVMLinkerPreserveSource_Removed
    _ => abort("Invalid LLVMLinkerMode Number in `LLVMLinkerMode::from_int`")
  }
}

pub enum LLVMCodeGenOptLevel {
    LLVMCodeGenLevelNone
    LLVMCodeGenLevelLess
    LLVMCodeGenLevelDefault
    LLVMCodeGenLevelAggressive
}

pub fn LLVMCodeGenOptLevel::to_int(self: LLVMCodeGenOptLevel) -> Int {
  match self {
    LLVMCodeGenLevelNone => 0
    LLVMCodeGenLevelLess => 1
    LLVMCodeGenLevelDefault => 2
    LLVMCodeGenLevelAggressive => 3
  }
}

pub fn LLVMCodeGenOptLevel::from_int(idx: Int) -> LLVMCodeGenOptLevel {
  match idx {
    0 => LLVMCodeGenLevelNone
    1 => LLVMCodeGenLevelLess
    2 => LLVMCodeGenLevelDefault
    3 => LLVMCodeGenLevelAggressive
    _ => abort("Invalid LLVMCodeGenOptLevel Number in `LLVMCodeGenOptLevel::from_int`")
  }
}

pub enum LLVMRelocMode {
    LLVMRelocDefault
    LLVMRelocStatic
    LLVMRelocPIC
    LLVMRelocDynamicNoPic
    LLVMRelocROPI
    LLVMRelocRWPI
    LLVMRelocROPI_RWPI
}

pub fn LLVMRelocMode::to_int(self: LLVMRelocMode) -> Int {
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

pub fn LLVMRelocMode::from_int(idx: Int) -> LLVMRelocMode {
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

pub enum LLVMCodeModel {
    LLVMCodeModelDefault
    LLVMCodeModelJITDefault
    LLVMCodeModelTiny
    LLVMCodeModelSmall
    LLVMCodeModelKernel
    LLVMCodeModelMedium
    LLVMCodeModelLarge
}

pub fn LLVMCodeModel::to_int(self: LLVMCodeModel) -> Int {
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

pub fn LLVMCodeModel::from_int(idx: Int) -> LLVMCodeModel {
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

pub enum LLVMCodeGenFileType {
    LLVMAssemblyFile
    LLVMObjectFile
}

pub fn LLVMCodeGenFileType::to_int(self: LLVMCodeGenFileType) -> Int {
  match self {
    LLVMAssemblyFile => 0
    LLVMObjectFile => 1
  }
}

pub fn LLVMCodeGenFileType::from_int(idx: Int) -> LLVMCodeGenFileType {
  match idx {
    0 => LLVMAssemblyFile
    1 => LLVMObjectFile
    _ => abort("Invalid LLVMCodeGenFileType Number in `LLVMCodeGenFileType::from_int`")
  }
}

pub enum LLVMGlobalISelAbortMode {
  LLVMGlobalISelAbortEnable
  LLVMGlobalISelAbortDisable
  LLVMGlobalISelAbortDisableWithDiag
}

pub fn LLVMGlobalISelAbortMode::to_int(self: LLVMGlobalISelAbortMode) -> Int {
  match self {
    LLVMGlobalISelAbortEnable => 0
    LLVMGlobalISelAbortDisable => 1
    LLVMGlobalISelAbortDisableWithDiag => 2
  }
}

pub fn LLVMGlobalISelAbortMode::from_int(idx: Int) -> LLVMGlobalISelAbortMode {
  match idx {
    0 => LLVMGlobalISelAbortEnable
    1 => LLVMGlobalISelAbortDisable
    2 => LLVMGlobalISelAbortDisableWithDiag
    _ => abort("Invalid LLVMGlobalISelAbortMode Number in `LLVMGlobalISelAbortMode::from_int`")
  }
}

pub enum LLVMBinaryType {
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

pub fn LLVMBinaryType::to_int(self: LLVMBinaryType) -> Int {
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

pub fn LLVMBinaryType::from_int(idx: Int) -> LLVMBinaryType {
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

pub enum LLVMDIFlags {
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

pub fn LLVMDIFlags::to_int(self: LLVMDIFlags) -> Int {
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

pub fn LLVMDIFlags::from_int(idx: Int) -> LLVMDIFlags {
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

//| Source languages known by DWARF.
// pub enum LLVMDWARFSourceLanguage {
//   LLVMDWARFSourceLanguageC89
//   LLVMDWARFSourceLanguageC
//   LLVMDWARFSourceLanguageAda83
//   LLVMDWARFSourceLanguageC_plus_plus
//   LLVMDWARFSourceLanguageCobol74
//   LLVMDWARFSourceLanguageCobol85
//   LLVMDWARFSourceLanguageFortran77
//   LLVMDWARFSourceLanguageFortran90
//   LLVMDWARFSourceLanguagePascal83
//   LLVMDWARFSourceLanguageModula2
//   // New in DWARF v3:
//   LLVMDWARFSourceLanguageJava
//   LLVMDWARFSourceLanguageC99
//   LLVMDWARFSourceLanguageAda95
//   LLVMDWARFSourceLanguageFortran95
//   LLVMDWARFSourceLanguagePLI
//   LLVMDWARFSourceLanguageObjC
//   LLVMDWARFSourceLanguageObjC_plus_plus
//   LLVMDWARFSourceLanguageUPC
//   LLVMDWARFSourceLanguageD
//   // New in DWARF v4:
//   LLVMDWARFSourceLanguagePython
//   // New in DWARF v5:
//   LLVMDWARFSourceLanguageOpenCL
//   LLVMDWARFSourceLanguageGo
//   LLVMDWARFSourceLanguageModula3
//   LLVMDWARFSourceLanguageHaskell
//   LLVMDWARFSourceLanguageC_plus_plus_03
//   LLVMDWARFSourceLanguageC_plus_plus_11
//   LLVMDWARFSourceLanguageOCaml
//   LLVMDWARFSourceLanguageRust
//   LLVMDWARFSourceLanguageC11
//   LLVMDWARFSourceLanguageSwift
//   LLVMDWARFSourceLanguageJulia
//   LLVMDWARFSourceLanguageDylan
//   LLVMDWARFSourceLanguageC_plus_plus_14
//   LLVMDWARFSourceLanguageFortran03
//   LLVMDWARFSourceLanguageFortran08
//   LLVMDWARFSourceLanguageRenderScript
//   LLVMDWARFSourceLanguageBLISS
//   LLVMDWARFSourceLanguageKotlin
//   LLVMDWARFSourceLanguageZig
//   LLVMDWARFSourceLanguageCrystal
//   LLVMDWARFSourceLanguageC_plus_plus_17
//   LLVMDWARFSourceLanguageC_plus_plus_20
//   LLVMDWARFSourceLanguageC17
//   LLVMDWARFSourceLanguageFortran18
//   LLVMDWARFSourceLanguageAda2005
//   LLVMDWARFSourceLanguageAda2012
//   LLVMDWARFSourceLanguageHIP
//   LLVMDWARFSourceLanguageAssembly
//   LLVMDWARFSourceLanguageC_sharp
//   LLVMDWARFSourceLanguageMojo
//   LLVMDWARFSourceLanguageGLSL
//   LLVMDWARFSourceLanguageGLSL_ES
//   LLVMDWARFSourceLanguageHLSL
//   LLVMDWARFSourceLanguageOpenCL_CPP
//   LLVMDWARFSourceLanguageCPP_for_OpenCL
//   LLVMDWARFSourceLanguageSYCL
//   LLVMDWARFSourceLanguageRuby
//   LLVMDWARFSourceLanguageMove
//   LLVMDWARFSourceLanguageHylo
//   LLVMDWARFSourceLanguageMetal
//
//   // Vendor extensions:
//   LLVMDWARFSourceLanguageMips_Assembler
//   LLVMDWARFSourceLanguageGOOGLE_RenderScript
//   LLVMDWARFSourceLanguageBORLAND_Delphi
// };
//
// ///| The amount of debug information to emit.
// pub enum LLVMDWARFEmissionKind {
//     LLVMDWARFEmissionNone
//     LLVMDWARFEmissionFull
//     LLVMDWARFEmissionLineTablesOnly
// }
//
// ///| The kind of metadata nodes.
// pub enum LLVMMDNodeKind {
//   LLVMMDStringMetadataKind
//   LLVMConstantAsMetadataMetadataKind
//   LLVMLocalAsMetadataMetadataKind
//   LLVMDistinctMDOperandPlaceholderMetadataKind
//   LLVMMDTupleMetadataKind
//   LLVMDILocationMetadataKind
//   LLVMDIExpressionMetadataKind
//   LLVMDIGlobalVariableExpressionMetadataKind
//   LLVMGenericDINodeMetadataKind
//   LLVMDISubrangeMetadataKind
//   LLVMDIEnumeratorMetadataKind
//   LLVMDIBasicTypeMetadataKind
//   LLVMDIDerivedTypeMetadataKind
//   LLVMDICompositeTypeMetadataKind
//   LLVMDISubroutineTypeMetadataKind
//   LLVMDIFileMetadataKind
//   LLVMDICompileUnitMetadataKind
//   LLVMDISubprogramMetadataKind
//   LLVMDILexicalBlockMetadataKind
//   LLVMDILexicalBlockFileMetadataKind
//   LLVMDINamespaceMetadataKind
//   LLVMDIModuleMetadataKind
//   LLVMDITemplateTypeParameterMetadataKind
//   LLVMDITemplateValueParameterMetadataKind
//   LLVMDIGlobalVariableMetadataKind
//   LLVMDILocalVariableMetadataKind
//   LLVMDILabelMetadataKind
//   LLVMDIObjCPropertyMetadataKind
//   LLVMDIImportedEntityMetadataKind
//   LLVMDIMacroMetadataKind
//   LLVMDIMacroFileMetadataKind
//   LLVMDICommonBlockMetadataKind
//   LLVMDIStringTypeMetadataKind
//   LLVMDIGenericSubrangeMetadataKind
//   LLVMDIArgListMetadataKind
//   LLVMDIAssignIDMetadataKind
// };
