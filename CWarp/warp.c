#include <llvm-c/Analysis.h>
#include <llvm-c/BitWriter.h>
#include <llvm-c/Core.h>
#include <llvm-c/ExecutionEngine.h>
#include <llvm-c/Target.h>
#include <llvm-c/Types.h>

#include "utils.h"

void panic(const char *msg) {
  printf("%s\n", msg);
  exit(1);
}

int32_t llvm_type_kind_to_int(LLVMTypeKind k) {
  switch (k) {
  case LLVMVoidTypeKind:
    return 0;
  case LLVMHalfTypeKind:
    return 1;
  case LLVMFloatTypeKind:
    return 2;
  case LLVMDoubleTypeKind:
    return 3;
  case LLVMX86_FP80TypeKind:
    return 4;
  case LLVMFP128TypeKind:
    return 5;
  case LLVMPPC_FP128TypeKind:
    return 6;
  case LLVMLabelTypeKind:
    return 7;
  case LLVMIntegerTypeKind:
    return 8;
  case LLVMFunctionTypeKind:
    return 9;
  case LLVMStructTypeKind:
    return 10;
  case LLVMArrayTypeKind:
    return 11;
  case LLVMPointerTypeKind:
    return 12;
  case LLVMVectorTypeKind:
    return 13;
  case LLVMMetadataTypeKind:
    return 14;
  case LLVMX86_MMXTypeKind:
    return 15;
  case LLVMTokenTypeKind:
    return 16;
  case LLVMScalableVectorTypeKind:
    return 17;
  case LLVMBFloatTypeKind:
    return 18;
  case LLVMX86_AMXTypeKind:
    return 19;
  case LLVMTargetExtTypeKind:
    return 20;
  default:
    panic("Error during LLVMTypeKind Convert to Moonbit");
  }
}

LLVMTypeKind llvm_type_kind_from_int(int32_t k) {
  switch (k) {
  case 0:
    return LLVMVoidTypeKind;
  case 1:
    return LLVMHalfTypeKind;
  case 2:
    return LLVMFloatTypeKind;
  case 3:
    return LLVMDoubleTypeKind;
  case 4:
    return LLVMX86_FP80TypeKind;
  case 5:
    return LLVMFP128TypeKind;
  case 6:
    return LLVMPPC_FP128TypeKind;
  case 7:
    return LLVMLabelTypeKind;
  case 8:
    return LLVMIntegerTypeKind;
  case 9:
    return LLVMFunctionTypeKind;
  case 10:
    return LLVMStructTypeKind;
  case 11:
    return LLVMArrayTypeKind;
  case 12:
    return LLVMPointerTypeKind;
  case 13:
    return LLVMVectorTypeKind;
  case 14:
    return LLVMMetadataTypeKind;
  case 15:
    return LLVMX86_MMXTypeKind;
  case 16:
    return LLVMTokenTypeKind;
  case 17:
    return LLVMScalableVectorTypeKind;
  case 18:
    return LLVMBFloatTypeKind;
  case 19:
    return LLVMX86_AMXTypeKind;
  case 20:
    return LLVMTargetExtTypeKind;
  default:
    panic("Error during Moonbit Convert to LLVMTypeKind");
    return LLVMVoidTypeKind;
  }
}

// typedef enum {
//   LLVMTailCallKindNone = 0,
//   LLVMTailCallKindTail = 1,
//   LLVMTailCallKindMustTail = 2,
//   LLVMTailCallKindNoTail = 3,
// } LLVMTailCallKind;
int llvm_tail_call_kind_to_int(LLVMTailCallKind k) {
  switch (k) {
  case LLVMTailCallKindNone:
    return 0;
  case LLVMTailCallKindTail:
    return 1;
  case LLVMTailCallKindMustTail:
    return 2;
  case LLVMTailCallKindNoTail:
    return 3;
  }
}

LLVMTailCallKind llvm_tail_call_kind_from_int(int i) {
  switch (i) {
  case 0:
    return LLVMTailCallKindNone;
  case 1:
    return LLVMTailCallKindTail;
  case 2:
    return LLVMTailCallKindMustTail;
  case 3:
    return LLVMTailCallKindNoTail;
  default:
    panic("Error during Moonbit Convert to LLVMTailCallKind");
  }
  return LLVMTailCallKindNone;
}

int llvm_opcode_to_int(LLVMOpcode self) {
  switch (self) {
  case LLVMRet:
    return 0;
  case LLVMBr:
    return 1;
  case LLVMSwitch:
    return 2;
  case LLVMIndirectBr:
    return 3;
  case LLVMInvoke:
    return 4;
  case LLVMUnreachable:
    return 5;
  case LLVMCallBr:
    return 6;
  case LLVMFNeg:
    return 7;
  case LLVMAdd:
    return 8;
  case LLVMFAdd:
    return 9;
  case LLVMSub:
    return 10;
  case LLVMFSub:
    return 11;
  case LLVMMul:
    return 12;
  case LLVMFMul:
    return 13;
  case LLVMUDiv:
    return 14;
  case LLVMSDiv:
    return 15;
  case LLVMFDiv:
    return 16;
  case LLVMURem:
    return 17;
  case LLVMSRem:
    return 18;
  case LLVMFRem:
    return 19;
  case LLVMShl:
    return 20;
  case LLVMLShr:
    return 21;
  case LLVMAShr:
    return 22;
  case LLVMAnd:
    return 23;
  case LLVMOr:
    return 24;
  case LLVMXor:
    return 25;
  case LLVMAlloca:
    return 26;
  case LLVMLoad:
    return 27;
  case LLVMStore:
    return 28;
  case LLVMGetElementPtr:
    return 29;
  case LLVMTrunc:
    return 30;
  case LLVMZExt:
    return 31;
  case LLVMSExt:
    return 32;
  case LLVMFPToUI:
    return 33;
  case LLVMFPToSI:
    return 34;
  case LLVMUIToFP:
    return 35;
  case LLVMSIToFP:
    return 36;
  case LLVMFPTrunc:
    return 37;
  case LLVMFPExt:
    return 38;
  case LLVMPtrToInt:
    return 39;
  case LLVMIntToPtr:
    return 40;
  case LLVMBitCast:
    return 41;
  case LLVMAddrSpaceCast:
    return 42;
  case LLVMICmp:
    return 43;
  case LLVMFCmp:
    return 44;
  case LLVMPHI:
    return 45;
  case LLVMCall:
    return 46;
  case LLVMSelect:
    return 47;
  case LLVMUserOp1:
    return 48;
  case LLVMUserOp2:
    return 49;
  case LLVMVAArg:
    return 50;
  case LLVMExtractElement:
    return 51;
  case LLVMInsertElement:
    return 52;
  case LLVMShuffleVector:
    return 53;
  case LLVMExtractValue:
    return 54;
  case LLVMInsertValue:
    return 55;
  case LLVMFreeze:
    return 56;
  case LLVMFence:
    return 57;
  case LLVMAtomicCmpXchg:
    return 58;
  case LLVMAtomicRMW:
    return 59;
  case LLVMResume:
    return 60;
  case LLVMLandingPad:
    return 61;
  case LLVMCleanupRet:
    return 62;
  case LLVMCatchRet:
    return 63;
  case LLVMCatchPad:
    return 64;
  case LLVMCleanupPad:
    return 65;
  case LLVMCatchSwitch:
    return 66;
  default:
    panic("Unknown Error happened, loc: llvm_opcode_to_int");
    return -1;
  }
}

LLVMOpcode llvm_opcode_from_int(int idx) {
  switch (idx) {
  case 0:
    return LLVMRet;
  case 1:
    return LLVMBr;
  case 2:
    return LLVMSwitch;
  case 3:
    return LLVMIndirectBr;
  case 4:
    return LLVMInvoke;
  case 5:
    return LLVMUnreachable;
  case 6:
    return LLVMCallBr;
  case 7:
    return LLVMFNeg;
  case 8:
    return LLVMAdd;
  case 9:
    return LLVMFAdd;
  case 10:
    return LLVMSub;
  case 11:
    return LLVMFSub;
  case 12:
    return LLVMMul;
  case 13:
    return LLVMFMul;
  case 14:
    return LLVMUDiv;
  case 15:
    return LLVMSDiv;
  case 16:
    return LLVMFDiv;
  case 17:
    return LLVMURem;
  case 18:
    return LLVMSRem;
  case 19:
    return LLVMFRem;
  case 20:
    return LLVMShl;
  case 21:
    return LLVMLShr;
  case 22:
    return LLVMAShr;
  case 23:
    return LLVMAnd;
  case 24:
    return LLVMOr;
  case 25:
    return LLVMXor;
  case 26:
    return LLVMAlloca;
  case 27:
    return LLVMLoad;
  case 28:
    return LLVMStore;
  case 29:
    return LLVMGetElementPtr;
  case 30:
    return LLVMTrunc;
  case 31:
    return LLVMZExt;
  case 32:
    return LLVMSExt;
  case 33:
    return LLVMFPToUI;
  case 34:
    return LLVMFPToSI;
  case 35:
    return LLVMUIToFP;
  case 36:
    return LLVMSIToFP;
  case 37:
    return LLVMFPTrunc;
  case 38:
    return LLVMFPExt;
  case 39:
    return LLVMPtrToInt;
  case 40:
    return LLVMIntToPtr;
  case 41:
    return LLVMBitCast;
  case 42:
    return LLVMAddrSpaceCast;
  case 43:
    return LLVMICmp;
  case 44:
    return LLVMFCmp;
  case 45:
    return LLVMPHI;
  case 46:
    return LLVMCall;
  case 47:
    return LLVMSelect;
  case 48:
    return LLVMUserOp1;
  case 49:
    return LLVMUserOp2;
  case 50:
    return LLVMVAArg;
  case 51:
    return LLVMExtractElement;
  case 52:
    return LLVMInsertElement;
  case 53:
    return LLVMShuffleVector;
  case 54:
    return LLVMExtractValue;
  case 55:
    return LLVMInsertValue;
  case 56:
    return LLVMFreeze;
  case 57:
    return LLVMFence;
  case 58:
    return LLVMAtomicCmpXchg;
  case 59:
    return LLVMAtomicRMW;
  case 60:
    return LLVMResume;
  case 61:
    return LLVMLandingPad;
  case 62:
    return LLVMCleanupRet;
  case 63:
    return LLVMCatchRet;
  case 64:
    return LLVMCatchPad;
  case 65:
    return LLVMCleanupPad;
  case 66:
    return LLVMCatchSwitch;
  default:
    panic("Unknown Error happened, loc: llvm_opcode_from_int");
    return LLVMRet;
  }
}

int llvm_linkage_to_int(LLVMLinkage self) {
  switch (self) {
  case LLVMExternalLinkage:
    return 0;
  case LLVMAvailableExternallyLinkage:
    return 1;
  case LLVMLinkOnceAnyLinkage:
    return 2;
  case LLVMLinkOnceODRLinkage:
    return 3;
  case LLVMLinkOnceODRAutoHideLinkage:
    return 4;
  case LLVMWeakAnyLinkage:
    return 5;
  case LLVMWeakODRLinkage:
    return 6;
  case LLVMAppendingLinkage:
    return 7;
  case LLVMInternalLinkage:
    return 8;
  case LLVMPrivateLinkage:
    return 9;
  case LLVMDLLImportLinkage:
    return 10;
  case LLVMDLLExportLinkage:
    return 11;
  case LLVMExternalWeakLinkage:
    return 12;
  case LLVMGhostLinkage:
    return 13;
  case LLVMCommonLinkage:
    return 14;
  case LLVMLinkerPrivateLinkage:
    return 15;
  case LLVMLinkerPrivateWeakLinkage:
    return 16;
  default:
    panic("Unknown Error happened, loc: llvm_linkage_to_int");
    return -1;
  }
}

LLVMLinkage llvm_linkage_from_int(int idx) {
  switch (idx) {
  case 0:
    return LLVMExternalLinkage;
  case 1:
    return LLVMAvailableExternallyLinkage;
  case 2:
    return LLVMLinkOnceAnyLinkage;
  case 3:
    return LLVMLinkOnceODRLinkage;
  case 4:
    return LLVMLinkOnceODRAutoHideLinkage;
  case 5:
    return LLVMWeakAnyLinkage;
  case 6:
    return LLVMWeakODRLinkage;
  case 7:
    return LLVMAppendingLinkage;
  case 8:
    return LLVMInternalLinkage;
  case 9:
    return LLVMPrivateLinkage;
  case 10:
    return LLVMDLLImportLinkage;
  case 11:
    return LLVMDLLExportLinkage;
  case 12:
    return LLVMExternalWeakLinkage;
  case 13:
    return LLVMGhostLinkage;
  case 14:
    return LLVMCommonLinkage;
  case 15:
    return LLVMLinkerPrivateLinkage;
  case 16:
    return LLVMLinkerPrivateWeakLinkage;
  default:
    panic("Unknown Error happened, loc: llvm_linkage_from_int");
    return LLVMExternalLinkage;
  }
}

int llvm_visibility_to_int(LLVMVisibility self) {
  switch (self) {
  case LLVMDefaultVisibility:
    return 0;
  case LLVMHiddenVisibility:
    return 1;
  case LLVMProtectedVisibility:
    return 2;
  default:
    panic("Unknown Error happened, loc: llvm_visibility_to_int");
    return -1;
  }
}

LLVMVisibility llvm_visibility_from_int(int idx) {
  switch (idx) {
  case 0:
    return LLVMDefaultVisibility;
  case 1:
    return LLVMHiddenVisibility;
  case 2:
    return LLVMProtectedVisibility;
  default:
    panic("Unknown Error happened, loc: llvm_visibility_from_int");
    return LLVMDefaultVisibility;
  }
}

int llvm_unnamed_addr_to_int(LLVMUnnamedAddr self) {
  switch (self) {
  case LLVMNoUnnamedAddr:
    return 0;
  case LLVMLocalUnnamedAddr:
    return 1;
  case LLVMGlobalUnnamedAddr:
    return 2;
  default:
    panic("Unknown Error happened, loc: llvm_unnamed_addr_to_int");
    return -1;
  }
}

LLVMUnnamedAddr llvm_unnamed_addr_from_int(int idx) {
  switch (idx) {
  case 0:
    return LLVMNoUnnamedAddr;
  case 1:
    return LLVMLocalUnnamedAddr;
  case 2:
    return LLVMGlobalUnnamedAddr;
  default:
    panic("Unknown Error happened, loc: llvm_unnamed_addr_from_int");
    return LLVMNoUnnamedAddr;
  }
}

int llvm_dll_storage_class_to_int(LLVMDLLStorageClass self) {
  switch (self) {
  case LLVMDefaultStorageClass:
    return 0;
  case LLVMDLLImportStorageClass:
    return 1;
  case LLVMDLLExportStorageClass:
    return 2;
  default:
    panic("Unknown Error happened, loc: llvm_dll_storage_class_to_int");
    return -1;
  }
}

LLVMDLLStorageClass llvm_dll_storage_class_from_int(int idx) {
  switch (idx) {
  case 0:
    return LLVMDefaultStorageClass;
  case 1:
    return LLVMDLLImportStorageClass;
  case 2:
    return LLVMDLLExportStorageClass;
  default:
    panic("Unknown Error happened, loc: llvm_dll_storage_class_from_int");
    return LLVMDefaultStorageClass;
  }
}

int llvm_call_conv_to_int(LLVMCallConv self) {
  switch (self) {
  case LLVMCCallConv:
    return 0;
  case LLVMFastCallConv:
    return 1;
  case LLVMColdCallConv:
    return 2;
  case LLVMGHCCallConv:
    return 3;
  case LLVMHiPECallConv:
    return 4;
  case LLVMAnyRegCallConv:
    return 5;
  case LLVMPreserveMostCallConv:
    return 6;
  case LLVMPreserveAllCallConv:
    return 7;
  case LLVMSwiftCallConv:
    return 8;
  case LLVMCXXFASTTLSCallConv:
    return 9;
  case LLVMX86StdcallCallConv:
    return 10;
  case LLVMX86FastcallCallConv:
    return 11;
  case LLVMARMAPCSCallConv:
    return 12;
  case LLVMARMAAPCSCallConv:
    return 13;
  case LLVMARMAAPCSVFPCallConv:
    return 14;
  case LLVMMSP430INTRCallConv:
    return 15;
  case LLVMX86ThisCallCallConv:
    return 16;
  case LLVMPTXKernelCallConv:
    return 17;
  case LLVMPTXDeviceCallConv:
    return 18;
  case LLVMSPIRFUNCCallConv:
    return 19;
  case LLVMSPIRKERNELCallConv:
    return 20;
  case LLVMIntelOCLBICallConv:
    return 21;
  case LLVMX8664SysVCallConv:
    return 22;
  case LLVMWin64CallConv:
    return 23;
  case LLVMX86VectorCallCallConv:
    return 24;
  case LLVMHHVMCallConv:
    return 25;
  case LLVMHHVMCCallConv:
    return 26;
  case LLVMX86INTRCallConv:
    return 27;
  case LLVMAVRINTRCallConv:
    return 28;
  case LLVMAVRSIGNALCallConv:
    return 29;
  case LLVMAVRBUILTINCallConv:
    return 30;
  case LLVMAMDGPUVSCallConv:
    return 31;
  case LLVMAMDGPUGSCallConv:
    return 32;
  case LLVMAMDGPUPSCallConv:
    return 33;
  case LLVMAMDGPUCSCallConv:
    return 34;
  case LLVMAMDGPUKERNELCallConv:
    return 35;
  case LLVMX86RegCallCallConv:
    return 36;
  case LLVMAMDGPUHSCallConv:
    return 37;
  case LLVMMSP430BUILTINCallConv:
    return 38;
  case LLVMAMDGPULSCallConv:
    return 39;
  case LLVMAMDGPUESCallConv:
    return 40;
  default:
    panic("Unknown Error happened, loc: llvm_call_conv_to_int");
    return -1;
  }
}

LLVMCallConv llvm_call_conv_from_int(int idx) {
  switch (idx) {
  case 0:
    return LLVMCCallConv;
  case 1:
    return LLVMFastCallConv;
  case 2:
    return LLVMColdCallConv;
  case 3:
    return LLVMGHCCallConv;
  case 4:
    return LLVMHiPECallConv;
  case 5:
    return LLVMAnyRegCallConv;
  case 6:
    return LLVMPreserveMostCallConv;
  case 7:
    return LLVMPreserveAllCallConv;
  case 8:
    return LLVMSwiftCallConv;
  case 9:
    return LLVMCXXFASTTLSCallConv;
  case 10:
    return LLVMX86StdcallCallConv;
  case 11:
    return LLVMX86FastcallCallConv;
  case 12:
    return LLVMARMAPCSCallConv;
  case 13:
    return LLVMARMAAPCSCallConv;
  case 14:
    return LLVMARMAAPCSVFPCallConv;
  case 15:
    return LLVMMSP430INTRCallConv;
  case 16:
    return LLVMX86ThisCallCallConv;
  case 17:
    return LLVMPTXKernelCallConv;
  case 18:
    return LLVMPTXDeviceCallConv;
  case 19:
    return LLVMSPIRFUNCCallConv;
  case 20:
    return LLVMSPIRKERNELCallConv;
  case 21:
    return LLVMIntelOCLBICallConv;
  case 22:
    return LLVMX8664SysVCallConv;
  case 23:
    return LLVMWin64CallConv;
  case 24:
    return LLVMX86VectorCallCallConv;
  case 25:
    return LLVMHHVMCallConv;
  case 26:
    return LLVMHHVMCCallConv;
  case 27:
    return LLVMX86INTRCallConv;
  case 28:
    return LLVMAVRINTRCallConv;
  case 29:
    return LLVMAVRSIGNALCallConv;
  case 30:
    return LLVMAVRBUILTINCallConv;
  case 31:
    return LLVMAMDGPUVSCallConv;
  case 32:
    return LLVMAMDGPUGSCallConv;
  case 33:
    return LLVMAMDGPUPSCallConv;
  case 34:
    return LLVMAMDGPUCSCallConv;
  case 35:
    return LLVMAMDGPUKERNELCallConv;
  case 36:
    return LLVMX86RegCallCallConv;
  case 37:
    return LLVMAMDGPUHSCallConv;
  case 38:
    return LLVMMSP430BUILTINCallConv;
  case 39:
    return LLVMAMDGPULSCallConv;
  case 40:
    return LLVMAMDGPUESCallConv;
  default:
    panic("Unknown Error happened, loc: llvm_call_conv_from_int");
    return LLVMCCallConv;
  }
}

int llvm_value_kind_to_int(LLVMValueKind self) {
  switch (self) {
  case LLVMArgumentValueKind:
    return 0;
  case LLVMBasicBlockValueKind:
    return 1;
  case LLVMMemoryUseValueKind:
    return 2;
  case LLVMMemoryDefValueKind:
    return 3;
  case LLVMMemoryPhiValueKind:
    return 4;
  case LLVMFunctionValueKind:
    return 5;
  case LLVMGlobalAliasValueKind:
    return 6;
  case LLVMGlobalIFuncValueKind:
    return 7;
  case LLVMGlobalVariableValueKind:
    return 8;
  case LLVMBlockAddressValueKind:
    return 9;
  case LLVMConstantExprValueKind:
    return 10;
  case LLVMConstantArrayValueKind:
    return 11;
  case LLVMConstantStructValueKind:
    return 12;
  case LLVMConstantVectorValueKind:
    return 13;
  case LLVMUndefValueValueKind:
    return 14;
  case LLVMConstantAggregateZeroValueKind:
    return 15;
  case LLVMConstantDataArrayValueKind:
    return 16;
  case LLVMConstantDataVectorValueKind:
    return 17;
  case LLVMConstantIntValueKind:
    return 18;
  case LLVMConstantFPValueKind:
    return 19;
  case LLVMConstantPointerNullValueKind:
    return 20;
  case LLVMConstantTokenNoneValueKind:
    return 21;
  case LLVMMetadataAsValueValueKind:
    return 22;
  case LLVMInlineAsmValueKind:
    return 23;
  case LLVMInstructionValueKind:
    return 24;
  case LLVMPoisonValueValueKind:
    return 25;
  case LLVMConstantTargetNoneValueKind:
    return 26;
  default:
    panic("Unknown Error happened, loc: llvm_value_kind_to_int");
    return -1;
  }
}

LLVMValueKind llvm_value_kind_from_int(int idx) {
  switch (idx) {
  case 0:
    return LLVMArgumentValueKind;
  case 1:
    return LLVMBasicBlockValueKind;
  case 2:
    return LLVMMemoryUseValueKind;
  case 3:
    return LLVMMemoryDefValueKind;
  case 4:
    return LLVMMemoryPhiValueKind;
  case 5:
    return LLVMFunctionValueKind;
  case 6:
    return LLVMGlobalAliasValueKind;
  case 7:
    return LLVMGlobalIFuncValueKind;
  case 8:
    return LLVMGlobalVariableValueKind;
  case 9:
    return LLVMBlockAddressValueKind;
  case 10:
    return LLVMConstantExprValueKind;
  case 11:
    return LLVMConstantArrayValueKind;
  case 12:
    return LLVMConstantStructValueKind;
  case 13:
    return LLVMConstantVectorValueKind;
  case 14:
    return LLVMUndefValueValueKind;
  case 15:
    return LLVMConstantAggregateZeroValueKind;
  case 16:
    return LLVMConstantDataArrayValueKind;
  case 17:
    return LLVMConstantDataVectorValueKind;
  case 18:
    return LLVMConstantIntValueKind;
  case 19:
    return LLVMConstantFPValueKind;
  case 20:
    return LLVMConstantPointerNullValueKind;
  case 21:
    return LLVMConstantTokenNoneValueKind;
  case 22:
    return LLVMMetadataAsValueValueKind;
  case 23:
    return LLVMInlineAsmValueKind;
  case 24:
    return LLVMInstructionValueKind;
  case 25:
    return LLVMPoisonValueValueKind;
  case 26:
    return LLVMConstantTargetNoneValueKind;
  default:
    panic("Unknown Error happened, loc: llvm_value_kind_from_int");
    return LLVMArgumentValueKind;
  }
}

int llvm_int_predicate_to_int(LLVMIntPredicate self) {
  switch (self) {
  case LLVMIntEQ:
    return 0;
  case LLVMIntNE:
    return 1;
  case LLVMIntUGT:
    return 2;
  case LLVMIntUGE:
    return 3;
  case LLVMIntULT:
    return 4;
  case LLVMIntULE:
    return 5;
  case LLVMIntSGT:
    return 6;
  case LLVMIntSGE:
    return 7;
  case LLVMIntSLT:
    return 8;
  case LLVMIntSLE:
    return 9;
  default:
    panic("Unknown Error happened, loc: llvm_int_predicate_to_int");
    return -1;
  }
}

LLVMIntPredicate llvm_int_predicate_from_int(int idx) {
  switch (idx) {
  case 0:
    return LLVMIntEQ;
  case 1:
    return LLVMIntNE;
  case 2:
    return LLVMIntUGT;
  case 3:
    return LLVMIntUGE;
  case 4:
    return LLVMIntULT;
  case 5:
    return LLVMIntULE;
  case 6:
    return LLVMIntSGT;
  case 7:
    return LLVMIntSGE;
  case 8:
    return LLVMIntSLT;
  case 9:
    return LLVMIntSLE;
  default:
    panic("Unknown Error happened, loc: llvm_int_predicate_from_int");
    return LLVMIntEQ;
  }
}

int llvm_real_predicate_to_int(LLVMRealPredicate self) {
  switch (self) {
  case LLVMRealPredicateFalse:
    return 0;
  case LLVMRealOEQ:
    return 1;
  case LLVMRealOGT:
    return 2;
  case LLVMRealOGE:
    return 3;
  case LLVMRealOLT:
    return 4;
  case LLVMRealOLE:
    return 5;
  case LLVMRealONE:
    return 6;
  case LLVMRealORD:
    return 7;
  case LLVMRealUNO:
    return 8;
  case LLVMRealUEQ:
    return 9;
  case LLVMRealUGT:
    return 10;
  case LLVMRealUGE:
    return 11;
  case LLVMRealULT:
    return 12;
  case LLVMRealULE:
    return 13;
  case LLVMRealUNE:
    return 14;
  case LLVMRealPredicateTrue:
    return 15;
  default:
    panic("Unknown Error happened, loc: llvm_real_predicate_to_int");
    return -1;
  }
}

LLVMRealPredicate llvm_real_predicate_from_int(int idx) {
  switch (idx) {
  case 0:
    return LLVMRealPredicateFalse;
  case 1:
    return LLVMRealOEQ;
  case 2:
    return LLVMRealOGT;
  case 3:
    return LLVMRealOGE;
  case 4:
    return LLVMRealOLT;
  case 5:
    return LLVMRealOLE;
  case 6:
    return LLVMRealONE;
  case 7:
    return LLVMRealORD;
  case 8:
    return LLVMRealUNO;
  case 9:
    return LLVMRealUEQ;
  case 10:
    return LLVMRealUGT;
  case 11:
    return LLVMRealUGE;
  case 12:
    return LLVMRealULT;
  case 13:
    return LLVMRealULE;
  case 14:
    return LLVMRealUNE;
  case 15:
    return LLVMRealPredicateTrue;
  default:
    panic("Unknown Error happened, loc: llvm_real_predicate_from_int");
    return LLVMRealPredicateFalse;
  }
}

int llvm_diagnostic_severity_to_int(LLVMDiagnosticSeverity s) {
  switch (s) {
  case LLVMDSError:
    return 0;
  case LLVMDSWarning:
    return 1;
  case LLVMDSRemark:
    return 2;
  case LLVMDSNote:
    return 3;
  }
}

int llvm_inline_asm_dialect_to_int(LLVMInlineAsmDialect i) {
  switch (i) {
  case LLVMInlineAsmDialectATT:
    return 0;
  case LLVMInlineAsmDialectIntel:
    return 1;
  }
}

// typedef enum {
//   LLVMAtomicOrderingNotAtomic,
//   LLVMAtomicOrderingUnordered, /**< Lowest level of atomicity, guarantees
//   LLVMAtomicOrderingMonotonic, /**< guarantees that if you take all the
//   LLVMAtomicOrderingAcquire, /**< Acquire provides a barrier of the sort
//   LLVMAtomicOrderingRelease, /**< Release is similar to Acquire, but with
//   LLVMAtomicOrderingAcquireRelease, /**< provides both an Acquire and a
//   LLVMAtomicOrderingSequentiallyConsistent /**< provides Acquire semantics
// } LLVMAtomicOrdering;
int llvm_atomic_ordering_to_int(LLVMAtomicOrdering o) {
  switch (o) {
  case LLVMAtomicOrderingNotAtomic:
    return 0;
  case LLVMAtomicOrderingUnordered:
    return 1;
  case LLVMAtomicOrderingMonotonic:
    return 2;
  case LLVMAtomicOrderingAcquire:
    return 3;
  case LLVMAtomicOrderingRelease:
    return 4;
  case LLVMAtomicOrderingAcquireRelease:
    return 5;
  case LLVMAtomicOrderingSequentiallyConsistent:
    return 6;
  }
}

LLVMAtomicOrdering llvm_atomic_ordering_from_int(int i) {
  switch (i) {
  case 0:
    return LLVMAtomicOrderingNotAtomic;
  case 1:
    return LLVMAtomicOrderingUnordered;
  case 2:
    return LLVMAtomicOrderingMonotonic;
  case 3:
    return LLVMAtomicOrderingAcquire;
  case 4:
    return LLVMAtomicOrderingRelease;
  case 5:
    return LLVMAtomicOrderingAcquireRelease;
  case 6:
    return LLVMAtomicOrderingSequentiallyConsistent;
  default:
    panic("Unknown Error happened, loc: llvm_atomic_ordering_from_int");
    return LLVMAtomicOrderingNotAtomic;
  }
}

// typedef enum {
//   LLVMAtomicRMWBinOpXchg, /**< Set the new value and return the one old */
//   LLVMAtomicRMWBinOpAdd,  /**< Add a value and return the old one */
//   LLVMAtomicRMWBinOpSub,  /**< Subtract a value and return the old one */
//   LLVMAtomicRMWBinOpAnd,  /**< And a value and return the old one */
//   LLVMAtomicRMWBinOpNand, /**< Not-And a value and return the old one */
//   LLVMAtomicRMWBinOpOr,   /**< OR a value and return the old one */
//   LLVMAtomicRMWBinOpXor,  /**< Xor a value and return the old one */
//   LLVMAtomicRMWBinOpMax,  /**< Sets the value if it's greater than the
//   LLVMAtomicRMWBinOpMin,  /**< Sets the value if it's Smaller than the
//   LLVMAtomicRMWBinOpUMax, /**< Sets the value if it's greater than the
//   LLVMAtomicRMWBinOpUMin, /**< Sets the value if it's greater than the
//   LLVMAtomicRMWBinOpFAdd, /**< Add a floating point value and return the
//   LLVMAtomicRMWBinOpFSub, /**< Subtract a floating point value and return the
//   LLVMAtomicRMWBinOpFMax, /**< Sets the value if it's greater than the
//   LLVMAtomicRMWBinOpFMin, /**< Sets the value if it's smaller than the
//   LLVMAtomicRMWBinOpUIncWrap, /**< Increments the value, wrapping back to
//   zero LLVMAtomicRMWBinOpUDecWrap, /**< Decrements the value, wrapping back
//   to
// } LLVMAtomicRMWBinOp;
int llvm_atomic_rmw_bin_op_to_int(LLVMAtomicRMWBinOp o) {
  switch (o) {
  case LLVMAtomicRMWBinOpXchg:
    return 0;
  case LLVMAtomicRMWBinOpAdd:
    return 1;
  case LLVMAtomicRMWBinOpSub:
    return 2;
  case LLVMAtomicRMWBinOpAnd:
    return 3;
  case LLVMAtomicRMWBinOpNand:
    return 4;
  case LLVMAtomicRMWBinOpOr:
    return 5;
  case LLVMAtomicRMWBinOpXor:
    return 6;
  case LLVMAtomicRMWBinOpMax:
    return 7;
  case LLVMAtomicRMWBinOpMin:
    return 8;
  case LLVMAtomicRMWBinOpUMax:
    return 9;
  case LLVMAtomicRMWBinOpUMin:
    return 10;
  case LLVMAtomicRMWBinOpFAdd:
    return 11;
  case LLVMAtomicRMWBinOpFSub:
    return 12;
  case LLVMAtomicRMWBinOpFMax:
    return 13;
  case LLVMAtomicRMWBinOpFMin:
    return 14;
  case LLVMAtomicRMWBinOpUIncWrap:
    return 15;
  case LLVMAtomicRMWBinOpUDecWrap:
    return 16;
  default:
    panic("Unknown Error happened, loc: llvm_atomic_rmw_bin_op_to_int");
    return -1;
  }
}

LLVMAtomicRMWBinOp llvm_atomic_rmw_bin_op_from_int(int i) {
  switch (i) {
  case 0:
    return LLVMAtomicRMWBinOpXchg;
  case 1:
    return LLVMAtomicRMWBinOpAdd;
  case 2:
    return LLVMAtomicRMWBinOpSub;
  case 3:
    return LLVMAtomicRMWBinOpAnd;
  case 4:
    return LLVMAtomicRMWBinOpNand;
  case 5:
    return LLVMAtomicRMWBinOpOr;
  case 6:
    return LLVMAtomicRMWBinOpXor;
  case 7:
    return LLVMAtomicRMWBinOpMax;
  case 8:
    return LLVMAtomicRMWBinOpMin;
  case 9:
    return LLVMAtomicRMWBinOpUMax;
  case 10:
    return LLVMAtomicRMWBinOpUMin;
  case 11:
    return LLVMAtomicRMWBinOpFAdd;
  case 12:
    return LLVMAtomicRMWBinOpFSub;
  case 13:
    return LLVMAtomicRMWBinOpFMax;
  case 14:
    return LLVMAtomicRMWBinOpFMin;
  case 15:
    return LLVMAtomicRMWBinOpUIncWrap;
  case 16:
    return LLVMAtomicRMWBinOpUDecWrap;
  default:
    panic("Unknown Error happened, loc: llvm_atomic_rmw_bin_op_from_int");
    return LLVMAtomicRMWBinOpXchg;
  }
}

int llvm_module_flag_behavior_to_int(LLVMModuleFlagBehavior b) {
  switch (b) {
  case LLVMModuleFlagBehaviorError:
    return 0;
  case LLVMModuleFlagBehaviorWarning:
    return 1;
  case LLVMModuleFlagBehaviorRequire:
    return 2;
  case LLVMModuleFlagBehaviorOverride:
    return 3;
  case LLVMModuleFlagBehaviorAppend:
    return 4;
  case LLVMModuleFlagBehaviorAppendUnique:
    return 5;
  default:
    panic("Unknown Error happened, loc: llvm_module_flag_behavior_to_int");
    return -1;
  }
}

LLVMModuleFlagBehavior llvm_module_flag_behavior_from_int(int i) {
  switch (i) {
  case 0:
    return LLVMModuleFlagBehaviorError;
  case 1:
    return LLVMModuleFlagBehaviorWarning;
  case 2:
    return LLVMModuleFlagBehaviorRequire;
  case 3:
    return LLVMModuleFlagBehaviorOverride;
  case 4:
    return LLVMModuleFlagBehaviorAppend;
  case 5:
    return LLVMModuleFlagBehaviorAppendUnique;
  default:
    panic("Unknown Error happened, loc: llvm_module_flag_behavior_from_int");
    return LLVMModuleFlagBehaviorError;
  }
}

typedef struct ArrayLLVMTypeRef {
  struct moonbit_object header;
  int32_t $1;
  struct UnsafedArrayLLVMTypeRef *$0;
} ArrayLLVMTypeRef;

struct UnsafedArrayLLVMTypeRef {
  struct moonbit_object header;
  void *data[0];
};

typedef struct ArrayLLVMValueRef {
  struct moonbit_object header;
  int32_t $1;
  struct UnsafedArrayLLVMValueRef *$0;
} ArrayLLVMValueRef;

struct UnsafedArrayLLVMValueRef {
  struct moonbit_object header;
  void *data[0];
};

typedef struct ArrayLLVMBasicBlockRef {
  struct moonbit_object header;
  int32_t $1;
  struct UnsafedArrayLLVMBasicBlockRef *$0;
} ArrayLLVMBasicBlockRef;

struct UnsafedArrayLLVMBasicBlockRef {
  struct moonbit_object header;
  void *data[0];
};

typedef struct ArrayLLVMMetadataRef {
  struct moonbit_object header;
  int32_t $1;
  struct UnsafedArrayLLVMMetadataRef *$0;
} ArrayLLVMMetadataRef;

struct UnsafedArrayLLVMMetadataRef {
  struct moonbit_object header;
  void *data[0];
};

typedef struct ArrayLLVMOperandBundleRef {
  struct moonbit_object header;
  int32_t $1;
  struct UnsafedArrayLLVMOperandBundleRef *$0;
} ArrayLLVMOperandBundleRef;

struct UnsafedArrayLLVMOperandBundleRef {
  struct moonbit_object header;
  void *data[0];
};

typedef struct ArrayUInt64_t {
  struct moonbit_object header;
  int32_t $1;
  struct UnsafedArrayUInt64_t *$0;
} ArrayUInt64_t;

struct UnsafedArrayUInt64_t {
  struct moonbit_object header;
  uint64_t data[0];
};

typedef struct RefLLVMBool {
  struct moonbit_object header;
  int32_t data;
} RefLLVMBool;

typedef struct TupleCStrUInt64 {
  struct moonbit_object header;
  void *$0;
  uint64_t $1;
} TupleCStrUInt64;

typedef struct TupleCStrUInt {
  struct moonbit_object header;
  void *$0;
  uint32_t $1;
} TupleCStrUInt;

void *new_null_cstr() { return (char *)NULL; }

void free_cstr(void *cstr) { free(cstr); }

LLVMBool __llvm_value_ref_is_null(void *val) { return val == NULL ? 1 : 0; }

LLVMBool __llvm_type_is_null(void *type_ref) {
  return type_ref == NULL ? 1 : 0;
}

LLVMBool __llvm_use_is_null(void *use_ref) { return use_ref == NULL ? 1 : 0; }

LLVMBool __llvm_bb_is_null(void *bb_ref) { return bb_ref == NULL ? 1 : 0; }

LLVMBool __llvm_comdat_is_null(void *comdat) { return comdat == NULL ? 1 : 0; }

void *__llvm_new_null_type_ref() { return (LLVMTypeRef)NULL; }

void *__llvm_new_null_value_ref() { return (LLVMValueRef)NULL; }

// ty1: LLVMTypeRef, ty2: LLVMTypeRef
LLVMBool __llvm_same_type_ref(void *ty1, void *ty2) {
  return ty1 == ty2 ? 1 : 0;
}

// val1: LLVMValueRef, val2: LLVMValueRef
LLVMBool __llvm_same_value_ref(void *val1, void *val2) {
  return val1 == val2 ? 1 : 0;
}

// ctx1: LLVMContextRef, ctx2: LLVMContextRef
LLVMBool __llvm_same_ctx_ref(void *ctx1, void *ctx2) {
  return ctx1 == ctx2 ? 1 : 0;
}

// attr1: LLVMAttributeRef, attr2: LLVMAttributeRef
LLVMBool __llvm_same_attr_ref(void *attr1, void *attr2) {
  return attr1 == attr2 ? 1 : 0;
}

void __llvm_get_version(unsigned *major, unsigned *minor, unsigned *patch) {
  LLVMGetVersion(major, minor, patch);
}

void __llvm_context_set_diagnostic_handler(void *context, void *handler,
                                           void *diagnostic_context) {
  LLVMContextSetDiagnosticHandler((LLVMContextRef)context,
                                  (LLVMDiagnosticHandler)handler,
                                  diagnostic_context);
}

// void *__llvm_context_get_diagnostic_handler(void *context) {
//   return (LLVMDiagnosticHandler)LLVMContextGetDiagnosticHandler(
//       (LLVMContextRef)context);
// }

int __llvm_get_diag_info_severity(void *di) {
  LLVMDiagnosticSeverity s = LLVMGetDiagInfoSeverity((LLVMDiagnosticInfoRef)di);
  return llvm_diagnostic_severity_to_int(s);
}

// void *__llvm_create_constant_range_attribute(void *context, unsigned kind_id,
//                                              unsigned num_bits,
//                                              ArrayUint64_t *lower_words,
//                                              ArrayUint64_t *upper_words) {
//   const uint64_t *llvm_lower_words = (const uint64_t *)lower_words->$0->data;
//   const uint64_t *llvm_upper_words = (const uint64_t *)upper_words->$0->data;
//   return (LLVMAttributeRef)LLVMCreateConstantRangeAttribute(
//       (LLVMContextRef)context, kind_id, num_bits, llvm_lower_words,
//       llvm_upper_words);
// }

TupleCStrUInt *__llvm_get_string_attribute_kind(void *a, TupleCStrUInt *input) {

  const char *s =
      LLVMGetStringAttributeKind((LLVMAttributeRef)a, (unsigned *)&(input->$1));
  input->$0 = (void *)s;
  return input;
}

TupleCStrUInt *__llvm_get_string_attribute_value(void *a,
                                                 TupleCStrUInt *input) {
  const char *s = LLVMGetStringAttributeValue((LLVMAttributeRef)a,
                                              (unsigned *)&(input->$1));
  input->$0 = (void *)s;
  return input;
}

TupleCStrUInt64 *__llvm_get_module_identifier(void *m, TupleCStrUInt64 *input) {
  const char *s =
      LLVMGetModuleIdentifier((LLVMModuleRef)m, (size_t *)&(input->$1));
  input->$0 = (void *)s;
  return input;
}

TupleCStrUInt64 *__llvm_get_source_file_name(void *m, TupleCStrUInt64 *input) {
  const char *s =
      LLVMGetSourceFileName((LLVMModuleRef)m, (size_t *)&(input->$1));
  input->$0 = (void *)s;
  return input;
}

// TODO: Wrong Implementation
// void *__llvm_copy_module_flags_metadata(void *m, size_t *len) {
//   return (LLVMModuleFlagEntry *)LLVMCopyModuleFlagsMetadata((LLVMModuleRef)m,
//                                                             len);
// }
//
// void __llvm_dispose_module_flags_metadata(void *entries) {
//   LLVMDisposeModuleFlagsMetadata((LLVMModuleFlagEntry *)entries);
// }
//
// LLVMModuleFlagBehavior
// __llvm_module_flag_entries_get_flag_behavior(void *entries, unsigned index) {
//   return LLVMModuleFlagEntriesGetFlagBehavior((LLVMModuleFlagEntry *)entries,
//                                               index);
// }
//
// void *__llvm_module_flag_entries_get_key(void *entries, unsigned index,
//                                          size_t *len) {
//   return (char *)LLVMModuleFlagEntriesGetKey((LLVMModuleFlagEntry *)entries,
//                                              index, len);
// }
//
// void *__llvm_module_flag_entries_get_metadata(void *entries, unsigned index)
// {
//   return (LLVMMetadataRef)LLVMModuleFlagEntriesGetMetadata(
//       (LLVMModuleFlagEntry *)entries, index);
// }

void __llvm_add_module_flag(void *m, LLVMModuleFlagBehavior b, void *key,
                            size_t key_len, void *val) {
  LLVMModuleFlagBehavior behavior = llvm_module_flag_behavior_from_int(b);
  LLVMAddModuleFlag((LLVMModuleRef)m, behavior, (const char *)key, key_len,
                    (LLVMMetadataRef)val);
}

LLVMBool __llvm_print_module_to_file(void *m, void *filename,
                                     void **error_message) {
  return LLVMPrintModuleToFile((LLVMModuleRef)m, (const char *)filename,
                               (char **)error_message);
}

void *__llvm_get_module_inline_asm(void *m, size_t *len) {
  return (char *)LLVMGetModuleInlineAsm((LLVMModuleRef)m, len);
}

TupleCStrUInt64 *__llvm_get_inline_asm_asm_string(void *inline_asm_val,
                                                  TupleCStrUInt64 *input) {
  const char *s = LLVMGetInlineAsmAsmString((LLVMValueRef)inline_asm_val,
                                            (size_t *)&(input->$1));
  input->$0 = (void *)s;
  return input;
}

TupleCStrUInt64 *
__llvm_get_inline_asm_constraint_string(void *inline_asm_val,
                                        TupleCStrUInt64 *input) {
  const char *s = LLVMGetInlineAsmConstraintString((LLVMValueRef)inline_asm_val,
                                                   (size_t *)&(input->$1));
  input->$0 = (void *)s;
  return input;
}

int __llvm_get_inline_asm_dialect(void *inline_asm_val) {
  LLVMInlineAsmDialect i =
      LLVMGetInlineAsmDialect((LLVMValueRef)inline_asm_val);
  return llvm_inline_asm_dialect_to_int(i);
}

TupleCStrUInt64 *__llvm_get_named_metadata_name(void *named_md,
                                                TupleCStrUInt64 *input) {
  const char *s = LLVMGetNamedMetadataName((LLVMNamedMDNodeRef)named_md,
                                           (size_t *)&(input->$1));
  input->$0 = (void *)s;
  return input;
}

TupleCStrUInt *__llvm_get_debug_loc_directory(void *val, TupleCStrUInt *input) {
  const char *s =
      LLVMGetDebugLocDirectory((LLVMValueRef)val, (unsigned *)&(input->$1));
  input->$0 = (void *)s;
  return input;
}

TupleCStrUInt *__llvm_get_debug_loc_filename(void *val, TupleCStrUInt *input) {
  const char *s =
      LLVMGetDebugLocFilename((LLVMValueRef)val, (unsigned *)&(input->$1));
  input->$0 = (void *)s;
  return input;
}

int32_t __llvm_get_type_kind(void *ty) {
  LLVMTypeKind k = LLVMGetTypeKind((LLVMTypeRef)ty);
  return llvm_type_kind_to_int(k);
}

void *__llvm_function_type(void *return_type, ArrayLLVMTypeRef *param_types,
                           LLVMBool is_var_arg) {
  LLVMTypeRef *llvm_param_types = (LLVMTypeRef *)param_types->$0->data;
  unsigned param_count = param_types->$1;
  return (LLVMTypeRef)LLVMFunctionType(
      (LLVMTypeRef)return_type, llvm_param_types, param_count, is_var_arg);
}

ArrayLLVMTypeRef *__llvm_get_param_types(void *function_ty,
                                         ArrayLLVMTypeRef *dest) {
  LLVMTypeRef *e_dest = (LLVMTypeRef *)dest->$0->data;
  LLVMGetParamTypes((LLVMTypeRef)function_ty, (LLVMTypeRef *)e_dest);
  return dest;
}

void *__llvm_struct_type_in_context(void *context,
                                    ArrayLLVMTypeRef *element_types,
                                    LLVMBool packed) {
  LLVMTypeRef *llvm_element_types = (LLVMTypeRef *)element_types->$0->data;
  unsigned element_count = element_types->$1;
  return (LLVMTypeRef)LLVMStructTypeInContext(
      (LLVMContextRef)context, llvm_element_types, element_count, packed);
}

void *__llvm_struct_type(ArrayLLVMTypeRef *element_types, LLVMBool packed) {
  LLVMTypeRef *llvm_element_types = (LLVMTypeRef *)element_types->$0->data;
  unsigned element_count = element_types->$1;
  return (LLVMTypeRef)LLVMStructType(llvm_element_types, element_count, packed);
}

void __llvm_struct_set_body(void *struct_ty, ArrayLLVMTypeRef *element_types,
                            LLVMBool packed) {
  LLVMTypeRef *llvm_element_types = (LLVMTypeRef *)element_types->$0->data;
  unsigned element_count = element_types->$1;
  LLVMStructSetBody((LLVMTypeRef)struct_ty, llvm_element_types, element_count,
                    packed);
}

ArrayLLVMValueRef *__llvm_get_struct_element_types(void *struct_ty,
                                                   unsigned cnt,
                                                   ArrayLLVMValueRef *arr) {
  LLVMTypeRef *llvm_element_types = (LLVMTypeRef *)arr->$0->data;
  LLVMGetStructElementTypes((LLVMTypeRef)struct_ty, llvm_element_types);
  return arr;
}

ArrayLLVMTypeRef *__llvm_get_subtypes(void *tp, ArrayLLVMTypeRef *arr) {
  LLVMTypeRef *e_arr = (LLVMTypeRef *)arr->$0->data;
  LLVMGetSubtypes((LLVMTypeRef)tp, e_arr);
  return arr;
}

// void *__llvm_target_ext_type_in_context(void *context, void *name,
//                                         ArrayLLVMTypeRef *type_params,
//                                         ArrayUnsigned *int_params) {
//   LLVMTypeRef *llvm_type_params = (LLVMTypeRef *)type_params->$0->data;
//   unsigned type_param_count = type_params->$1;
//   unsigned *llvm_int_params = (unsigned *)int_params->$0->data;
//   unsigned int_param_count = int_params->$1;
//   return (LLVMTypeRef)LLVMTargetExtTypeInContext(
//       (LLVMContextRef)context, (const char *)name, llvm_type_params,
//       type_param_count, llvm_int_params, int_param_count);
// }

int __llvm_get_value_kind(void *val) {
  LLVMValueKind k = LLVMGetValueKind((LLVMValueRef)val);
  return llvm_value_kind_to_int(k);
}

// void *__llvm_get_value_name2(void *val, size_t *length) {
//   return (char *)LLVMGetValueName2((LLVMValueRef)val, length);
// }

TupleCStrUInt64 *__llvm_get_value_name2(void *val, TupleCStrUInt64 *input) {
  const char *s = LLVMGetValueName2((LLVMValueRef)val, (size_t *)&(input->$1));
  input->$0 = (void *)s;
  return input;
}

void *__llvm_const_int_of_arbitrary_precision(void *int_ty,
                                              ArrayUInt64_t *words) {
  const uint64_t *llvm_words = (const uint64_t *)words->$0->data;
  unsigned num_words = words->$1;
  return (LLVMValueRef)LLVMConstIntOfArbitraryPrecision((LLVMTypeRef)int_ty,
                                                        num_words, llvm_words);
}

void *__llvm_const_int_of_string(void *int_ty, void *text, int _radix) {
  uint8_t radix = (uint8_t)_radix;
  return (LLVMValueRef)LLVMConstIntOfString((LLVMTypeRef)int_ty,
                                            (const char *)text, radix);
}

void *__llvm_const_int_of_string_and_size(void *int_ty, void *text,
                                          unsigned s_len, int _radix) {
  uint8_t radix = (uint8_t)_radix;
  return (LLVMValueRef)LLVMConstIntOfStringAndSize(
      (LLVMTypeRef)int_ty, (const char *)text, s_len, radix);
}

double __llvm_const_real_get_double(void *constant_val,
                                    RefLLVMBool *loses_info) {
  return LLVMConstRealGetDouble((LLVMValueRef)constant_val,
                                &(loses_info->data));
}

TupleCStrUInt64 *__llvm_get_as_string(void *c, TupleCStrUInt64 *input) {
  const char *s = LLVMGetAsString((LLVMValueRef)c, (size_t *)&(input->$1));
  input->$0 = (void *)s;
  return input;
}

void *__llvm_const_struct_in_context(void *context,
                                     ArrayLLVMValueRef *constant_vals,
                                     LLVMBool packed) {
  LLVMValueRef *llvm_constant_vals = (LLVMValueRef *)constant_vals->$0->data;
  unsigned count = constant_vals->$1;
  return (LLVMValueRef)LLVMConstStructInContext(
      (LLVMContextRef)context, llvm_constant_vals, count, packed);
}

void *__llvm_const_struct(ArrayLLVMValueRef *constant_vals, LLVMBool packed) {
  LLVMValueRef *llvm_constant_vals = (LLVMValueRef *)constant_vals->$0->data;
  unsigned count = constant_vals->$1;
  return (LLVMValueRef)LLVMConstStruct(llvm_constant_vals, count, packed);
}

void *__llvm_const_array(void *element_ty, ArrayLLVMValueRef *constant_vals) {
  LLVMValueRef *llvm_constant_vals = (LLVMValueRef *)constant_vals->$0->data;
  unsigned length = constant_vals->$1;
  return (LLVMValueRef)LLVMConstArray((LLVMTypeRef)element_ty,
                                      llvm_constant_vals, length);
}

void *__llvm_const_array2(void *element_ty, ArrayLLVMValueRef *constant_vals) {
  LLVMValueRef *llvm_constant_vals = (LLVMValueRef *)constant_vals->$0->data;
  unsigned length = constant_vals->$1;
  return (LLVMValueRef)LLVMConstArray2((LLVMTypeRef)element_ty,
                                       llvm_constant_vals, length);
}

void *__llvm_const_named_struct(void *struct_ty,
                                ArrayLLVMValueRef *constant_vals) {
  LLVMValueRef *llvm_constant_vals = (LLVMValueRef *)constant_vals->$0->data;
  unsigned count = constant_vals->$1;
  return (LLVMValueRef)LLVMConstNamedStruct((LLVMTypeRef)struct_ty,
                                            llvm_constant_vals, count);
}

// void *__llvm_get_element_as_constant(void *c, unsigned idx) {
//   return (LLVMValueRef)LLVMGetElementAsConstant((LLVMValueRef)c, idx);
// }

void *__llvm_const_vector(ArrayLLVMValueRef *scalar_constant_vals) {
  LLVMValueRef *llvm_scalar_constant_vals =
      (LLVMValueRef *)scalar_constant_vals->$0->data;
  unsigned size = scalar_constant_vals->$1;
  return (LLVMValueRef)LLVMConstVector(llvm_scalar_constant_vals, size);
}

int __llvm_get_const_opcode(void *constant_val) {
  LLVMOpcode code = LLVMGetConstOpcode((LLVMValueRef)constant_val);
  return llvm_opcode_to_int(code);
}

// void *__llvm_const_nuw_neg(void *constant_val) {
//   return (LLVMValueRef)LLVMConstNUWNeg((LLVMValueRef)constant_val);
// }

void *__llvm_const_gep2(void *ty, void *constant_val,
                        ArrayLLVMValueRef *constant_indices) {
  LLVMValueRef *llvm_constant_indices =
      (LLVMValueRef *)constant_indices->$0->data;
  unsigned num_indices = constant_indices->$1;
  return (LLVMValueRef)LLVMConstGEP2((LLVMTypeRef)ty,
                                     (LLVMValueRef)constant_val,
                                     llvm_constant_indices, num_indices);
}

void *__llvm_const_in_bounds_gep2(void *ty, void *constant_val,
                                  ArrayLLVMValueRef *constant_indices) {
  LLVMValueRef *llvm_constant_indices =
      (LLVMValueRef *)constant_indices->$0->data;
  unsigned num_indices = constant_indices->$1;
  return (LLVMValueRef)LLVMConstInBoundsGEP2(
      (LLVMTypeRef)ty, (LLVMValueRef)constant_val, llvm_constant_indices,
      num_indices);
}

int __llvm_get_linkage(void *global) {
  LLVMLinkage linkage = LLVMGetLinkage((LLVMValueRef)global);
  return llvm_linkage_to_int(linkage);
}

void __llvm_set_linkage(void *global, int link) {
  LLVMLinkage linkage = llvm_linkage_from_int(link);
  LLVMSetLinkage((LLVMValueRef)global, linkage);
}

int __llvm_get_visibility(void *global) {
  LLVMVisibility v = LLVMGetVisibility((LLVMValueRef)global);
  return llvm_visibility_to_int(v);
}

void __llvm_set_visibility(void *global, int iviz) {
  LLVMVisibility viz = llvm_visibility_from_int(iviz);
  LLVMSetVisibility((LLVMValueRef)global, viz);
}

int __llvm_get_dll_storage_class(void *global) {
  LLVMDLLStorageClass d = LLVMGetDLLStorageClass((LLVMValueRef)global);
  return llvm_dll_storage_class_to_int(d);
}

// void __llvm_set_dll_storage_class(void *global, LLVMDLLStorageClass class)
// {
//   LLVMSetDLLStorageClass((LLVMValueRef)global, class);
// }

// Wrong Implementation
// void *__llvm_global_copy_all_metadata(void *value, size_t *num_entries) {
//   return (LLVMValueMetadataEntry *)LLVMGlobalCopyAllMetadata(
//       (LLVMValueRef)value, num_entries);
// }

// TODO: Wrong implementation
// void __llvm_dispose_value_metadata_entries(void *entries) {
//   LLVMDisposeValueMetadataEntries((LLVMValueMetadataEntry *)entries);
// }

// TODO: Wrong implementation
// unsigned __llvm_value_metadata_entries_get_kind(void *entries, unsigned
// index) {
//   return LLVMValueMetadataEntriesGetKind((LLVMValueMetadataEntry *)entries,
//                                          index);
// }

// TODO: Wrong implementation
// void *__llvm_value_metadata_entries_get_metadata(void *entries,
//                                                  unsigned index) {
//   return (LLVMMetadataRef)LLVMValueMetadataEntriesGetMetadata(
//       (LLVMValueMetadataEntry *)entries, index);
// }

void *__llvm_get_intrinsic_declaration(void *mod, unsigned id,
                                       ArrayLLVMTypeRef *param_types) {
  LLVMTypeRef *llvm_param_types = (LLVMTypeRef *)param_types->$0->data;
  unsigned param_count = param_types->$1;
  return (LLVMValueRef)LLVMGetIntrinsicDeclaration(
      (LLVMModuleRef)mod, id, llvm_param_types, param_count);
}

void *__llvm_intrinsic_get_type(void *ctx, unsigned id,
                                ArrayLLVMTypeRef *param_types) {
  LLVMTypeRef *llvm_param_types = (LLVMTypeRef *)param_types->$0->data;
  unsigned param_count = param_types->$1;
  return (LLVMTypeRef)LLVMIntrinsicGetType((LLVMContextRef)ctx, id,
                                           llvm_param_types, param_count);
}

TupleCStrUInt64 *__llvm_intrinsic_get_name(unsigned id,
                                           TupleCStrUInt64 *input) {
  const char *s = LLVMIntrinsicGetName(id, (size_t *)&(input->$1));
  input->$0 = (void *)s;
  return input;
}

void *__llvm_intrinsic_copy_overloaded_name(unsigned id,
                                            ArrayLLVMTypeRef *param_types) {
  LLVMTypeRef *llvm_param_types = (LLVMTypeRef *)param_types->$0->data;
  unsigned param_count = param_types->$1;
  size_t name_length = 0;
  return (char *)LLVMIntrinsicCopyOverloadedName(id, llvm_param_types,
                                                 param_count, &name_length);
}

void *__llvm_intrinsic_copy_overloaded_name2(void *mod, unsigned id,
                                             ArrayLLVMTypeRef *param_types) {
  LLVMTypeRef *llvm_param_types = (LLVMTypeRef *)param_types->$0->data;
  unsigned param_count = param_types->$1;
  size_t name_length = 0;
  return (char *)LLVMIntrinsicCopyOverloadedName2(
      (LLVMModuleRef)mod, id, llvm_param_types, param_count, &name_length);
}

ArrayLLVMValueRef *__llvm_get_params(void *fn, ArrayLLVMValueRef *param_arr) {
  LLVMValueRef *params = (LLVMValueRef *)param_arr->$0->data;
  LLVMGetParams((LLVMValueRef)fn, params);
  return param_arr;
}

void *__llvm_md_node_in_context2(void *context, ArrayLLVMMetadataRef *mds) {
  LLVMMetadataRef *llvm_mds = (LLVMMetadataRef *)mds->$0->data;
  unsigned count = mds->$1;
  return (LLVMMetadataRef)LLVMMDNodeInContext2((LLVMContextRef)context,
                                               llvm_mds, count);
}

TupleCStrUInt *__llvm_get_md_string(void *v, TupleCStrUInt *input) {
  const char *s = LLVMGetMDString((LLVMValueRef)v, (unsigned *)&(input->$1));
  input->$0 = (void *)s;
  return input;
}

// TODO: Wrong Implementation
// void __llvm_get_md_node_operands(void *v, void *dest) {
//   LLVMGetMDNodeOperands((LLVMValueRef)v, (LLVMValueRef *)dest);
// }

void *__llvm_md_node_in_context(void *context, ArrayLLVMValueRef *vals) {
  LLVMValueRef *llvm_vals = (LLVMValueRef *)vals->$0->data;
  unsigned count = vals->$1;
  return (LLVMValueRef)LLVMMDNodeInContext((LLVMContextRef)context, llvm_vals,
                                           count);
}

void *__llvm_md_node(ArrayLLVMValueRef *vals, unsigned count) {
  LLVMValueRef *llvm_vals = (LLVMValueRef *)vals->$0->data;
  return (LLVMValueRef)LLVMMDNode(llvm_vals, count);
}

void *__llvm_create_operand_bundle(void *tag, size_t tag_len,
                                   ArrayLLVMValueRef *args) {
  LLVMValueRef *llvm_args = (LLVMValueRef *)args->$0->data;
  unsigned num_args = args->$1;
  return (LLVMOperandBundleRef)LLVMCreateOperandBundle(
      (const char *)tag, tag_len, llvm_args, num_args);
}

TupleCStrUInt64 *__llvm_get_operand_bundle_tag(void *bundle,
                                               TupleCStrUInt64 *input) {
  const char *s = LLVMGetOperandBundleTag((LLVMOperandBundleRef)bundle,
                                          (size_t *)&(input->$1));
  input->$0 = (void *)s;
  return input;
}

// TODO: wrong implementation
// void __llvm_get_basic_blocks(void *fn, void *basic_blocks) {
//   LLVMGetBasicBlocks((LLVMValueRef)fn, (LLVMBasicBlockRef *)basic_blocks);
// }

// TODO: wrong implementation
// void *
// __llvm_instruction_get_all_metadata_other_than_debug_loc(void *instr,
//                                                          size_t *num_entries)
//                                                          {
//   return (LLVMValueMetadataEntry *)
//       LLVMInstructionGetAllMetadataOtherThanDebugLoc((LLVMValueRef)instr,
//                                                      num_entries);
// }

int __llvm_get_instruction_opcode(void *inst) {
  LLVMOpcode opcode = LLVMGetInstructionOpcode((LLVMValueRef)inst);
  return llvm_opcode_to_int(opcode);
}

int __llvm_get_icmp_predicate(void *inst) {
  LLVMIntPredicate p = LLVMGetICmpPredicate((LLVMValueRef)inst);
  return llvm_int_predicate_to_int(p);
}

int __llvm_get_fcmp_predicate(void *inst) {
  LLVMRealPredicate p = LLVMGetFCmpPredicate((LLVMValueRef)inst);
  return llvm_real_predicate_to_int(p);
}

// TODO: Wrong Implementation
// void __llvm_get_call_site_attributes(void *c, LLVMAttributeIndex idx,
//                                      void *attrs) {
//   LLVMGetCallSiteAttributes((LLVMValueRef)c, idx, (LLVMAttributeRef *)attrs);
// }

int __llvm_get_tail_call_kind(void *call_inst) {
  LLVMTailCallKind k = LLVMGetTailCallKind((LLVMValueRef)call_inst);
  return llvm_tail_call_kind_to_int(k);
}

void __llvm_set_tail_call_kind(void *call_inst, int ikind) {
  LLVMTailCallKind kind = llvm_tail_call_kind_from_int(ikind);
  LLVMSetTailCallKind((LLVMValueRef)call_inst, kind);
}

void __llvm_add_incoming(void *phi_node, ArrayLLVMValueRef *incoming_values,
                         ArrayLLVMBasicBlockRef *incoming_blocks,
                         unsigned count) {
  LLVMValueRef *llvm_incoming_values =
      (LLVMValueRef *)incoming_values->$0->data;
  LLVMBasicBlockRef *llvm_incoming_blocks =
      (LLVMBasicBlockRef *)incoming_blocks->$0->data;
  LLVMAddIncoming((LLVMValueRef)phi_node, llvm_incoming_values,
                  llvm_incoming_blocks, count);
}

// TODO: Wrong Implementation
// const unsigned *__llvm_get_indices(void *inst) {
//   return LLVMGetIndices((LLVMValueRef)inst);
// }

void *__llvm_build_aggregate_ret(void *builder, ArrayLLVMValueRef *ret_vals) {

  LLVMValueRef *llvm_ret_vals = (LLVMValueRef *)ret_vals->$0->data;
  unsigned n = ret_vals->$1;
  return (LLVMValueRef)LLVMBuildAggregateRet((LLVMBuilderRef)builder,
                                             llvm_ret_vals, n);
}

void *__llvm_build_call_br(void *builder, void *ty, void *fn,
                           void *default_dest,
                           ArrayLLVMBasicBlockRef *indirect_dests,
                           ArrayLLVMValueRef *args,
                           ArrayLLVMOperandBundleRef *bundles, void *name) {
  LLVMBasicBlockRef *llvm_indirect_dests =
      (LLVMBasicBlockRef *)indirect_dests->$0->data;
  unsigned num_indirect_dests = indirect_dests->$1;
  LLVMValueRef *llvm_args = (LLVMValueRef *)args->$0->data;
  unsigned num_args = args->$1;
  LLVMOperandBundleRef *llvm_bundles =
      (LLVMOperandBundleRef *)bundles->$0->data;
  unsigned num_bundles = bundles->$1;
  return (LLVMValueRef)LLVMBuildCallBr(
      (LLVMBuilderRef)builder, (LLVMTypeRef)ty, (LLVMValueRef)fn,
      (LLVMBasicBlockRef)default_dest, llvm_indirect_dests, num_indirect_dests,
      llvm_args, num_args, llvm_bundles, num_bundles, (const char *)name);
}

void *__llvm_build_invoke2(void *builder, void *ty, void *fn,
                           ArrayLLVMValueRef *args, void *then, void *_catch,
                           void *name) {
  LLVMValueRef *llvm_args = (LLVMValueRef *)args->$0->data;
  unsigned num_args = args->$1;
  return (LLVMValueRef)LLVMBuildInvoke2(
      (LLVMBuilderRef)builder, (LLVMTypeRef)ty, (LLVMValueRef)fn, llvm_args,
      num_args, (LLVMBasicBlockRef)then, (LLVMBasicBlockRef)_catch,
      (const char *)name);
}

void *__llvm_build_invoke_with_operand_bundles(
    void *builder, void *ty, void *fn, ArrayLLVMValueRef *args, void *then,
    void *_catch, ArrayLLVMOperandBundleRef *bundles, void *name) {
  LLVMValueRef *llvm_args = (LLVMValueRef *)args->$0->data;
  unsigned num_args = args->$1;
  LLVMOperandBundleRef *llvm_bundles =
      (LLVMOperandBundleRef *)bundles->$0->data;
  unsigned num_bundles = bundles->$1;
  return (LLVMValueRef)LLVMBuildInvokeWithOperandBundles(
      (LLVMBuilderRef)builder, (LLVMTypeRef)ty, (LLVMValueRef)fn, llvm_args,
      num_args, (LLVMBasicBlockRef)then, (LLVMBasicBlockRef)_catch,
      llvm_bundles, num_bundles, (const char *)name);
}

void *__llvm_build_catch_pad(void *builder, void *parent_pad,
                             ArrayLLVMValueRef *args, void *name) {
  LLVMValueRef *llvm_args = (LLVMValueRef *)args->$0->data;
  unsigned num_args = args->$1;
  return (LLVMValueRef)LLVMBuildCatchPad((LLVMBuilderRef)builder,
                                         (LLVMValueRef)parent_pad, llvm_args,
                                         num_args, (const char *)name);
}

void *__llvm_build_cleanup_pad(void *builder, void *parent_pad,
                               ArrayLLVMValueRef *args, void *name) {
  LLVMValueRef *llvm_args = (LLVMValueRef *)args->$0->data;
  unsigned num_args = args->$1;
  return (LLVMValueRef)LLVMBuildCleanupPad((LLVMBuilderRef)builder,
                                           (LLVMValueRef)parent_pad, llvm_args,
                                           num_args, (const char *)name);
}

void *__llvm_build_bin_op(void *builder, int op_code, void *lhs, void *rhs,
                          void *name) {
  LLVMOpcode op = llvm_opcode_from_int(op_code);
  return (LLVMValueRef)LLVMBuildBinOp((LLVMBuilderRef)builder, op,
                                      (LLVMValueRef)lhs, (LLVMValueRef)rhs,
                                      (const char *)name);
}

void *__llvm_build_gep2(void *builder, void *ty, void *pointer,
                        ArrayLLVMValueRef *indices, void *name) {
  LLVMValueRef *llvm_indices = (LLVMValueRef *)indices->$0->data;
  unsigned num_indices = indices->$1;
  return (LLVMValueRef)LLVMBuildGEP2((LLVMBuilderRef)builder, (LLVMTypeRef)ty,
                                     (LLVMValueRef)pointer, llvm_indices,
                                     num_indices, (const char *)name);
}

void *__llvm_build_in_bounds_gep2(void *builder, void *ty, void *pointer,
                                  ArrayLLVMValueRef *indices, void *name) {
  LLVMValueRef *llvm_indices = (LLVMValueRef *)indices->$0->data;
  unsigned num_indices = indices->$1;
  return (LLVMValueRef)LLVMBuildInBoundsGEP2(
      (LLVMBuilderRef)builder, (LLVMTypeRef)ty, (LLVMValueRef)pointer,
      llvm_indices, num_indices, (const char *)name);
}

int __llvm_get_ordering(void *memory_access_inst) {
  LLVMAtomicOrdering ordering =
      LLVMGetOrdering((LLVMValueRef)memory_access_inst);
  return llvm_atomic_ordering_to_int(ordering);
}

void __llvm_set_ordering(void *memory_access_inst, int ordering) {
  LLVMAtomicOrdering order = llvm_atomic_ordering_from_int(ordering);
  LLVMSetOrdering((LLVMValueRef)memory_access_inst, order);
}

int __llvm_get_atomic_rmw_bin_op(void *atomic_rmw_inst) {
  LLVMAtomicRMWBinOp bin_op =
      LLVMGetAtomicRMWBinOp((LLVMValueRef)atomic_rmw_inst);
  return llvm_atomic_rmw_bin_op_to_int(bin_op);
}

void __llvm_set_atomic_rmw_bin_op(void *atomic_rmw_inst, int bin_op) {
  LLVMAtomicRMWBinOp op = llvm_atomic_rmw_bin_op_from_int(bin_op);
  LLVMSetAtomicRMWBinOp((LLVMValueRef)atomic_rmw_inst, op);
}

void *__llvm_build_cast(void *builder, int op_code, void *val, void *dest_ty,
                        void *name) {
  LLVMOpcode op = llvm_opcode_from_int(op_code);
  return (LLVMValueRef)LLVMBuildCast((LLVMBuilderRef)builder, op,
                                     (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
                                     (const char *)name);
}

int __llvm_get_cast_opcode(void *src, LLVMBool src_is_signed, void *dest_ty,
                           LLVMBool dest_is_signed) {
  LLVMOpcode code = LLVMGetCastOpcode((LLVMValueRef)src, src_is_signed,
                                      (LLVMTypeRef)dest_ty, dest_is_signed);
  return llvm_opcode_to_int(code);
}

void *__llvm_build_icmp(void *builder, int op, void *lhs, void *rhs,
                        void *name) {
  LLVMIntPredicate real_op = llvm_int_predicate_from_int(op);
  return (LLVMValueRef)LLVMBuildICmp((LLVMBuilderRef)builder, real_op,
                                     (LLVMValueRef)lhs, (LLVMValueRef)rhs,
                                     (const char *)name);
}

void *__llvm_build_fcmp(void *builder, int op, void *lhs, void *rhs,
                        void *name) {
  LLVMRealPredicate real_op = llvm_real_predicate_from_int(op);
  return (LLVMValueRef)LLVMBuildFCmp((LLVMBuilderRef)builder, real_op,
                                     (LLVMValueRef)lhs, (LLVMValueRef)rhs,
                                     (const char *)name);
}

void *__llvm_build_call2(void *builder, void *ty, void *fn,
                         ArrayLLVMValueRef *args, void *name) {
  LLVMValueRef *llvm_args = (LLVMValueRef *)args->$0->data;
  unsigned num_args = args->$1;
  return (LLVMValueRef)LLVMBuildCall2((LLVMBuilderRef)builder, (LLVMTypeRef)ty,
                                      (LLVMValueRef)fn, llvm_args, num_args,
                                      (const char *)name);
}

void *__llvm_build_call_with_operand_bundles(void *builder, void *ty, void *fn,
                                             ArrayLLVMValueRef *args,
                                             ArrayLLVMOperandBundleRef *bundles,
                                             void *name) {
  LLVMValueRef *llvm_args = (LLVMValueRef *)args->$0->data;
  unsigned num_args = args->$1;
  LLVMOperandBundleRef *llvm_bundles =
      (LLVMOperandBundleRef *)bundles->$0->data;
  unsigned num_bundles = bundles->$1;
  return (LLVMValueRef)LLVMBuildCallWithOperandBundles(
      (LLVMBuilderRef)builder, (LLVMTypeRef)ty, (LLVMValueRef)fn, llvm_args,
      num_args, llvm_bundles, num_bundles, (const char *)name);
}

void *__llvm_build_atomic_cmp_xchg(void *builder, void *ptr, void *cmp,
                                   void *_new, int so, int fo,
                                   LLVMBool single_thread) {
  LLVMAtomicOrdering success_ordering = llvm_atomic_ordering_from_int(so);
  LLVMAtomicOrdering failure_ordering = llvm_atomic_ordering_from_int(fo);
  return (LLVMValueRef)LLVMBuildAtomicCmpXchg(
      (LLVMBuilderRef)builder, (LLVMValueRef)ptr, (LLVMValueRef)cmp,
      (LLVMValueRef)_new, success_ordering, failure_ordering, single_thread);
}

// TODO: Wrong Implementation
int __llvm_get_cmp_xchg_success_ordering(void *cmp_xchg_inst) {
  LLVMAtomicOrdering o =
      LLVMGetCmpXchgSuccessOrdering((LLVMValueRef)cmp_xchg_inst);
  return llvm_atomic_ordering_to_int(o);
}

void __llvm_set_cmp_xchg_success_ordering(void *cmp_xchg_inst, int o) {
  LLVMAtomicOrdering ordering = llvm_atomic_ordering_from_int(o);
  LLVMSetCmpXchgSuccessOrdering((LLVMValueRef)cmp_xchg_inst, ordering);
}

int __llvm_get_cmp_xchg_failure_ordering(void *cmp_xchg_inst) {
  LLVMAtomicOrdering o =
      LLVMGetCmpXchgFailureOrdering((LLVMValueRef)cmp_xchg_inst);
  return llvm_atomic_ordering_to_int(o);
}

void __llvm_set_cmp_xchg_failure_ordering(void *cmp_xchg_inst, int o) {
  LLVMAtomicOrdering ordering = llvm_atomic_ordering_from_int(o);
  LLVMSetCmpXchgFailureOrdering((LLVMValueRef)cmp_xchg_inst, ordering);
}

// TODO: Incorrect inplementation
// LLVMBool __llvm_create_memory_buffer_with_contents_of_file(void *path,
//                                                            void
//                                                            **out_mem_buf,
//                                                            void
//                                                            **out_message) {
//   return LLVMCreateMemoryBufferWithContentsOfFile(
//       (const char *)path, (LLVMMemoryBufferRef *)out_mem_buf,
//       (char **)out_message);
// }
//
// LLVMBool __llvm_create_memory_buffer_with_stdin(void **out_mem_buf,
//                                                 void **out_message) {
//   return LLVMCreateMemoryBufferWithSTDIN((LLVMMemoryBufferRef *)out_mem_buf,
//                                          (char **)out_message);
// }
