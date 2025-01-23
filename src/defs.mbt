// extern types
type CStr
type LLVMBool Int derive(Eq)
type LLVMAttributeIndex UInt derive(Eq)

// type LLVMMemoryBufferRef
type LLVMContextRef
type LLVMModuleRef
type LLVMBasicBlockRef
// type LLVMMetadataRef
// type LLVMNamedMDNodeRef
// type LLVMValueMetadataEntry
type LLVMBuilderRef
// type LLVMDIBuilderRef
// type LLVMModuleProviderRef
// type LLVMPassManagerRef
type LLVMUseRef
type LLVMValueRef
type LLVMTypeRef
type LLVMOperandBundleRef
type LLVMAttributeRef
// type LLVMDiagnosticInfoRef
// type LLVMComdatRef
// type LLVMModuleFlagEntry
// type LLVMJITEventListenerRef
// type LLVMBinaryRef
// type LLVMDbgRecordRef


// pub enum LLVMOpcode {
//   LLVMRet
//   LLVMBr
//   LLVMSwitch
//   LLVMIndirectBr
//   LLVMInvoke
//   LLVMUnreachable
//   LLVMCallBr
//   LLVMFNeg
//   LLVMAdd
//   LLVMFAdd
//   LLVMSub
//   LLVMFSub
//   LLVMMul
//   LLVMFMul
//   LLVMUDiv
//   LLVMSDiv
//   LLVMFDiv
//   LLVMURem
//   LLVMSRem
//   LLVMFRem
//   LLVMShl
//   LLVMLShr
//   LLVMAShr
//   LLVMAnd
//   LLVMOr
//   LLVMXor
//   LLVMAlloca
//   LLVMLoad
//   LLVMStore
//   LLVMGetElementPtr
//   LLVMTrunc
//   LLVMZExt
//   LLVMSExt
//   LLVMFPToUI
//   LLVMFPToSI
//   LLVMUIToFP
//   LLVMSIToFP
//   LLVMFPTrunc
//   LLVMFPExt
//   LLVMPtrToInt
//   LLVMIntToPtr
//   LLVMBitCast
//   LLVMAddrSpaceCast
//   LLVMICmp
//   LLVMFCmp
//   LLVMPHI
//   LLVMCall
//   LLVMSelect
//   LLVMUserOp1
//   LLVMUserOp2
//   LLVMVAArg
//   LLVMExtractElement
//   LLVMInsertElement
//   LLVMShuffleVector
//   LLVMExtractValue
//   LLVMInsertValue
//   LLVMFreeze
//   LLVMFence
//   LLVMAtomicCmpXchg
//   LLVMAtomicRMW
//   LLVMResume
//   LLVMLandingPad
//   LLVMCleanupRet
//   LLVMCatchRet
//   LLVMCatchPad
//   LLVMCleanupPad
//   LLVMCatchSwitch
// }

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

// pub enum LLVMLinkage {
//   LLVMExternalLinkage
//   LLVMAvailableExternallyLinkage
//   LLVMLinkOnceAnyLinkage
//   LLVMLinkOnceODRLinkage
//   LLVMLinkOnceODRAutoHideLinkage
//   LLVMWeakAnyLinkage
//   LLVMWeakODRLinkage
//   LLVMAppendingLinkage
//   LLVMInternalLinkage
//   LLVMPrivateLinkage
//   LLVMDLLImportLinkage
//   LLVMDLLExportLinkage
//   LLVMExternalWeakLinkage
//   LLVMGhostLinkage
//   LLVMCommonLinkage
//   LLVMLinkerPrivateLinkage
//   LLVMLinkerPrivateWeakLinkage
// }

// pub enum LLVMVisibility {
//   LLVMDefaultVisibility
//   LLVMHiddenVisibility
//   LLVMProtectedVisibility
// }

// pub enum LLVMUnnamedAddr {
//   LLVMNoUnnamedAddr
//   LLVMLocalUnnamedAddr
//   LLVMGlobalUnnamedAddr
// }

// typedef enum {
//   LLVMDefaultStorageClass   = 0,
//   LLVMDLLImportStorageClass = 1, /**< Function to be imported from DLL. */
//   LLVMDLLExportStorageClass = 2  /**< Function to be accessible from DLL. */
// } LLVMDLLStorageClass;

// pub enum LLVMDLLStorageClass {
//   LLVMDefaultStorageClass
//   LLVMDLLImportStorageClass
//   LLVMDLLExportStorageClass
// }

// pub enum LLVMCallConv {
//   LLVMCCallConv
//   LLVMFastCallConv
//   LLVMColdCallConv
//   LLVMGHCCallConv
//   LLVMHiPECallConv
//   LLVMAnyRegCallConv
//   LLVMPreserveMostCallConv
//   LLVMPreserveAllCallConv
//   LLVMSwiftCallConv
//   LLVMCXXFASTTLSCallConv
//   LLVMX86StdcallCallConv
//   LLVMX86FastcallCallConv
//   LLVMARMAPCSCallConv
//   LLVMARMAAPCSCallConv
//   LLVMARMAAPCSVFPCallConv
//   LLVMMSP430INTRCallConv
//   LLVMX86ThisCallCallConv
//   LLVMPTXKernelCallConv
//   LLVMPTXDeviceCallConv
//   LLVMSPIRFUNCCallConv
//   LLVMSPIRKERNELCallConv
//   LLVMIntelOCLBICallConv
//   LLVMX8664SysVCallConv
//   LLVMWin64CallConv
//   LLVMX86VectorCallCallConv
//   LLVMHHVMCallConv
//   LLVMHHVMCCallConv
//   LLVMX86INTRCallConv
//   LLVMAVRINTRCallConv
//   LLVMAVRSIGNALCallConv
//   LLVMAVRBUILTINCallConv
//   LLVMAMDGPUVSCallConv
//   LLVMAMDGPUGSCallConv
//   LLVMAMDGPUPSCallConv
//   LLVMAMDGPUCSCallConv
//   LLVMAMDGPUKERNELCallConv
//   LLVMX86RegCallCallConv
//   LLVMAMDGPUHSCallConv
//   LLVMMSP430BUILTINCallConv
//   LLVMAMDGPULSCallConv
//   LLVMAMDGPUESCallConv
// }

// pub enum LLVMValueKind {
//   LLVMArgumentValueKind,
//   LLVMBasicBlockValueKind
//   LLVMMemoryUseValueKind
//   LLVMMemoryDefValueKind
//   LLVMMemoryPhiValueKind
//   LLVMFunctionValueKind
//   LLVMGlobalAliasValueKind
//   LLVMGlobalIFuncValueKind
//   LLVMGlobalVariableValueKind
//   LLVMBlockAddressValueKind
//   LLVMConstantExprValueKind
//   LLVMConstantArrayValueKind
//   LLVMConstantStructValueKind
//   LLVMConstantVectorValueKind
//   LLVMUndefValueValueKind
//   LLVMConstantAggregateZeroValueKind
//   LLVMConstantDataArrayValueKind
//   LLVMConstantDataVectorValueKind
//   LLVMConstantIntValueKind
//   LLVMConstantFPValueKind
//   LLVMConstantPointerNullValueKind
//   LLVMConstantTokenNoneValueKind
//   LLVMMetadataAsValueValueKind
//   LLVMInlineAsmValueKind
//   LLVMInstructionValueKind
//   LLVMPoisonValueValueKind
//   LLVMConstantTargetNoneValueKind
// }

// pub enum LLVMIntPredicate {
//   LLVMIntEQ
//   LLVMIntNE
//   LLVMIntUGT
//   LLVMIntUGE
//   LLVMIntULT
//   LLVMIntULE
//   LLVMIntSGT
//   LLVMIntSGE
//   LLVMIntSLT
//   LLVMIntSLE
// }


// pub enum LLVMRealPredicate {
//   LLVMRealPredicateFalse
//   LLVMRealOEQ
//   LLVMRealOGT
//   LLVMRealOGE
//   LLVMRealOLT
//   LLVMRealOLE
//   LLVMRealONE
//   LLVMRealORD
//   LLVMRealUNO
//   LLVMRealUEQ
//   LLVMRealUGT
//   LLVMRealUGE
//   LLVMRealULT
//   LLVMRealULE
//   LLVMRealUNE
//   LLVMRealPredicateTrue
// }

// pub enum LLVMLandingPadClauseTy {
//   LLVMLandingPadCatch
//   LLVMLandingPadFilter
// }

// pub enum LLVMThreadLocalMode {
//   LLVMNotThreadLocal
//   LLVMGeneralDynamicTLSModel
//   LLVMLocalDynamicTLSModel
//   LLVMInitialExecTLSModel
//   LLVMLocalExecTLSModel
// }

// pub enum LLVMAtomicOrderding {
//   LLVMAtomicOrderingNotAtomic
//   LLVMAtomicOrderingUnordered
//   LLVMAtomicOrderingMonotonic
//   LLVMAtomicOrderingAcquire
//   LLVMAtomicOrderingRelease
//   LLVMAtomicOrderingAcquireRelease
//   LLVMAtomicOrderingSequentiallyConsistent
// }

// pub enum LLVMAtomicRMWBinOp {
//   LLVMAtomicRMWBinOpXchg
//   LLVMAtomicRMWBinOpAdd
//   LLVMAtomicRMWBinOpSub
//   LLVMAtomicRMWBinOpAnd
//   LLVMAtomicRMWBinOpNand
//   LLVMAtomicRMWBinOpOr
//   LLVMAtomicRMWBinOpXor
//   LLVMAtomicRMWBinOpMax
//   LLVMAtomicRMWBinOpMin
//   LLVMAtomicRMWBinOpUMax
//   LLVMAtomicRMWBinOpUMin
//   LLVMAtomicRMWBinOpFAdd
//   LLVMAtomicRMWBinOpFSub
//   LLVMAtomicRMWBinOpFMax
//   LLVMAtomicRMWBinOpFMin
//   LLVMAtomicRMWBinOpUIncWrap
//   LLVMAtomicRMWBinOpUDecWrap
// }

// pub enum LLVMDiagnosticSeverity {
//     LLVMDSError
//     LLVMDSWarning
//     LLVMDSRemark
//     LLVMDSNote
// }

// pub enum {
//   LLVMInlineAsmDialectATT
//   LLVMInlineAsmDialectIntel
// }

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



// pub enum LLVMTailCallKind {
//   LLVMTailCallKindNone
//   LLVMTailCallKindTail
//   LLVMTailCallKindMustTail
//   LLVMTailCallKindNoTail
// }

// pub enum IntPredicate {
//   // Equal
//   EQ
//
//   // Not equal
//   NE
//
//   // Unsigned greater than
//   UGT
//
//   // Unsigned greater than or equal
//   UGE
//
//   // Unsigned less than
//   ULT
//
//   // Unsigned greater than or equal
//   ULE
//
//   // Signed greater than
//   SGT
//
//   // Signed greater than or equal
//   SGE
//
//   // Signed less than
//   SLT
//
//   // Signed less than or equal
//   SLE
// } derive(Eq, Show, Hash)
//
// pub enum FloatPredicate {
//   /// Returns true if `left` == `right` and neither are NaN
//   OEQ
//
//   /// Returns true if `left` >= `right` and neither are NaN
//
//   OGE
//
//   /// Returns true if `left` > `right` and neither are NaN
//   OGT
//
//   /// Returns true if `left` <= `right` and neither are NaN
//   OLE
//
//   /// Returns true if `left` < `right` and neither are NaN
//   OLT
//
//   /// Returns true if `left` != `right` and neither are NaN
//   ONE
//
//   /// Returns true if neither value is NaN
//   ORD
//
//   /// Always returns false
//   PredicateFalse
//
//   /// Always returns true
//   PredicateTrue
//
//   /// Returns true if `left` == `right` or either is NaN
//   UEQ
//
//   /// Returns true if `left` >= `right` or either is NaN
//   UGE
//
//   /// Returns true if `left` > `right` or either is NaN
//   UGT
//
//   /// Returns true if `left` <= `right` or either is NaN
//   ULE
//
//   /// Returns true if `left` < `right` or either is NaN
//   ULT
//
//   /// Returns true if `left` != `right` or either is NaN
//   UNE
//
//   /// Returns true if either value is NaN
//   UNO
// } derive(Eq, Show, Hash)
//

// pub enum InstructionOpcode {
//     Add
//     AddrSpaceCast
//     Alloca
//     And
//     AShr
//     AtomicCmpXchg
//     AtomicRMW
//     BitCast
//     Br
//     Call
//     CallBr
//     CatchPad
//     CatchRet
//     CatchSwitch
//     CleanupPad
//     CleanupRet
//     ExtractElement
//     ExtractValue
//     FNeg
//     FAdd
//     FCmp
//     FDiv
//     Fence
//     FMul
//     FPExt
//     FPToSI
//     FPToUI
//     FPTrunc
//     Freeze
//     FRem
//     FSub
//     GetElementPtr
//     ICmp
//     IndirectBr
//     InsertElement
//     InsertValue
//     IntToPtr
//     Invoke
//     LandingPad
//     Load
//     LShr
//     Mul
//     Or
//     Phi
//     PtrToInt
//     Resume
//     Return
//     SDiv
//     Select
//     SExt
//     Shl
//     ShuffleVector
//     SIToFP
//     SRem
//     Store
//     Sub
//     Switch
//     Trunc
//     UDiv
//     UIToFP
//     Unreachable
//     URem
//     UserOp1
//     UserOp2
//     VAArg
//     Xor
//     ZExt
// } derive(Eq, Show, Hash)


// pub enum AtomicOrdering {
//   NotAtomic
//
//   Unordered
//
//   Monotonic
//
//   Acquire
//
//   Release
//
//   AcquireRelease
//
//   SequentiallyConsistent
// } derive(Eq, Show, Hash)
//
// pub enum AtomicRMWBinOp {
//   /// Stores to memory and returns the prior value.
//   Xchg
//
//   /// Adds to the value in memory and returns the prior value.
//   Add
//
//   /// Subtract a value off the value in memory and returns the prior value.
//   Sub
//
//   /// Bitwise and into memory and returns the prior value.
//   And
//
//   /// Bitwise nands into memory and returns the prior value.
//   Nand
//
//   /// Bitwise ors into memory and returns the prior value.
//   Or
//
//   /// Bitwise xors into memory and returns the prior value.
//   Xor
//
//   /// Sets memory to the signed-greater of the value provided and the value in memory. Returns the value that was in memory.
//   Max
//
//   /// Sets memory to the signed-lesser of the value provided and the value in memory. Returns the value that was in memory.
//   Min
//
//   /// Sets memory to the unsigned-greater of the value provided and the value in memory. Returns the value that was in memory.
//   UMax
//
//   /// Sets memory to the unsigned-lesser of the value provided and the value in memory. Returns the value that was in memory.
//   UMin
//
//   /// Adds to the float-typed value in memory and returns the prior value.
//   FAdd
//
//   /// Subtract a float-typed value off the value in memory and returns the prior value.
//   FSub
//
//   /// Sets memory to the greater of the two float-typed values, one provided and one from memory. Returns the value that was in memory.
//   FMax
//
//   /// Sets memory to the lesser of the two float-typed values, one provided and one from memory. Returns the value that was in memory.
//   FMin
// } derive(Eq, Show, Hash)
//
// pub enum OptimizationLevel {
//   None
//
//   Less
//
//   Default
//
//   Aggressive
// } derive(Eq, Show, Hash)
//
// pub enum GlobalVisibility {
//   Default
//
//   Hidden
//
//   Protected
// } derive(Eq, Show, Hash)
//
// pub enum ThreadLocalMode {
//   NotThreadLocal
//
//   GeneralDynamic
//
//   LocalDynamic
//
//   InitialExec
//
//   LocalExec
// } derive(Eq, Show, Hash)
//
// pub enum DLLStorageClass {
//   Default
//
//   DLLImport
//
//   DLLExport
// } derive(Eq, Show, Hash)
//
// pub enum InlineAsmDialect {
//   ATT
//   Intel
// } derive(Eq, Show, Hash)
