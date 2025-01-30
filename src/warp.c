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

LLVMBool __llvm_value_is_null(void *val) {
  return LLVMIsNull((LLVMValueRef)val);
}

LLVMBool __llvm_type_is_null(void *type_ref) {
  return type_ref == NULL ? 1 : 0;
}

LLVMBool __llvm_use_is_null(void *use_ref) { return use_ref == NULL ? 1 : 0; }

LLVMBool __llvm_bb_is_null(void *bb_ref) { return bb_ref == NULL ? 1 : 0; }

void __llvm_shutdown() { LLVMShutdown(); }

void __llvm_get_version(unsigned *major, unsigned *minor, unsigned *patch) {
  LLVMGetVersion(major, minor, patch);
}

void *__llvm_create_message(void *message) {
  return (char *)LLVMCreateMessage((const char *)message);
}

void __llvm_dispose_message(void *message) {
  LLVMDisposeMessage((char *)message);
}

void *__llvm_context_create() { return (LLVMContextRef)LLVMContextCreate(); }

void *__llvm_get_global_context() {
  return (LLVMContextRef)LLVMGetGlobalContext();
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

void *__llvm_context_get_diagnostic_context(void *context) {
  return LLVMContextGetDiagnosticContext((LLVMContextRef)context);
}

void __llvm_context_set_yield_callback(void *context, void *callback,
                                       void *opaque_handle) {
  LLVMContextSetYieldCallback((LLVMContextRef)context,
                              (LLVMYieldCallback)callback, opaque_handle);
}

LLVMBool __llvm_context_should_discard_value_names(void *context) {
  return LLVMContextShouldDiscardValueNames((LLVMContextRef)context);
}

void __llvm_context_set_discard_value_names(void *context, LLVMBool discard) {
  LLVMContextSetDiscardValueNames((LLVMContextRef)context, discard);
}

void __llvm_context_dispose(void *context) {
  LLVMContextDispose((LLVMContextRef)context);
}

void *__llvm_get_diag_info_description(void *di) {
  return (char *)LLVMGetDiagInfoDescription((LLVMDiagnosticInfoRef)di);
}

LLVMDiagnosticSeverity __llvm_get_diag_info_severity(void *di) {
  return LLVMGetDiagInfoSeverity((LLVMDiagnosticInfoRef)di);
}

unsigned __llvm_get_md_kind_id_in_context(void *context, void *name,
                                          unsigned s_len) {
  return LLVMGetMDKindIDInContext((LLVMContextRef)context, (const char *)name,
                                  s_len);
}

unsigned __llvm_get_md_kind_id(void *name, unsigned s_len) {
  return LLVMGetMDKindID((const char *)name, s_len);
}

unsigned __llvm_get_enum_attribute_kind_for_name(void *name, size_t s_len) {
  return LLVMGetEnumAttributeKindForName((const char *)name, s_len);
}

unsigned __llvm_get_last_enum_attribute_kind() {
  return LLVMGetLastEnumAttributeKind();
}

void *__llvm_create_enum_attribute(void *context, unsigned kind_id,
                                   uint64_t val) {
  return (LLVMAttributeRef)LLVMCreateEnumAttribute((LLVMContextRef)context,
                                                   kind_id, val);
}

unsigned __llvm_get_enum_attribute_kind(void *a) {
  return LLVMGetEnumAttributeKind((LLVMAttributeRef)a);
}

uint64_t __llvm_get_enum_attribute_value(void *a) {
  return LLVMGetEnumAttributeValue((LLVMAttributeRef)a);
}

void *__llvm_create_type_attribute(void *context, unsigned kind_id,
                                   void *type_ref) {
  return (LLVMAttributeRef)LLVMCreateTypeAttribute(
      (LLVMContextRef)context, kind_id, (LLVMTypeRef)type_ref);
}

void *__llvm_get_type_attribute_value(void *a) {
  return (LLVMTypeRef)LLVMGetTypeAttributeValue((LLVMAttributeRef)a);
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

// void *__llvm_create_string_attribute(void *context, void *k, unsigned
// k_length,
//                                      void *v, unsigned v_length) {
//   return (LLVMAttributeRef)LLVMCreateStringAttribute((LLVMContextRef)context,
//                                                      (const char *)k,
//                                                      k_length, (const char
//                                                      *)v, v_length);
// }

void *__llvm_get_string_attribute_kind(void *a, unsigned *length) {
  return (char *)LLVMGetStringAttributeKind((LLVMAttributeRef)a, length);
}

void *__llvm_get_string_attribute_value(void *a, unsigned *length) {
  return (char *)LLVMGetStringAttributeValue((LLVMAttributeRef)a, length);
}

LLVMBool __llvm_is_enum_attribute(void *a) {
  return LLVMIsEnumAttribute((LLVMAttributeRef)a);
}

LLVMBool __llvm_is_string_attribute(void *a) {
  return LLVMIsStringAttribute((LLVMAttributeRef)a);
}

LLVMBool __llvm_is_type_attribute(void *a) {
  return LLVMIsTypeAttribute((LLVMAttributeRef)a);
}

void *__llvm_get_type_by_name(void *context, void *name) {
  return (LLVMTypeRef)LLVMGetTypeByName2((LLVMContextRef)context,
                                         (const char *)name);
}

void *__llvm_module_create_with_name(void *module_id) {
  return (LLVMModuleRef)LLVMModuleCreateWithName((const char *)module_id);
}

void *__llvm_module_create_with_name_in_context(void *module_id,
                                                void *context) {
  return (LLVMModuleRef)LLVMModuleCreateWithNameInContext(
      (const char *)module_id, (LLVMContextRef)context);
}

void *__llvm_clone_module(void *m) {
  return (LLVMModuleRef)LLVMCloneModule((LLVMModuleRef)m);
}

void __llvm_dispose_module(void *m) { LLVMDisposeModule((LLVMModuleRef)m); }

LLVMBool __llvm_is_new_dbg_info_format(void *m) {
  return LLVMIsNewDbgInfoFormat((LLVMModuleRef)m);
}

void __llvm_set_is_new_dbg_info_format(void *m, LLVMBool use_new_format) {
  LLVMSetIsNewDbgInfoFormat((LLVMModuleRef)m, use_new_format);
}

void *__llvm_get_module_identifier(void *m, size_t *len) {
  return (char *)LLVMGetModuleIdentifier((LLVMModuleRef)m, len);
}

void __llvm_set_module_identifier(void *m, void *ident, size_t len) {
  LLVMSetModuleIdentifier((LLVMModuleRef)m, (const char *)ident, len);
}

void *__llvm_get_source_file_name(void *m, size_t *len) {
  return (char *)LLVMGetSourceFileName((LLVMModuleRef)m, len);
}

void __llvm_set_source_file_name(void *m, void *name, size_t len) {
  LLVMSetSourceFileName((LLVMModuleRef)m, (const char *)name, len);
}

void *__llvm_get_data_layout_str(void *m) {
  return (char *)LLVMGetDataLayoutStr((LLVMModuleRef)m);
}

void *__llvm_get_data_layout(void *m) {
  return (char *)LLVMGetDataLayout((LLVMModuleRef)m);
}

void __llvm_set_data_layout(void *m, void *data_layout_str) {
  LLVMSetDataLayout((LLVMModuleRef)m, (const char *)data_layout_str);
}

void *__llvm_get_target(void *m) {
  return (char *)LLVMGetTarget((LLVMModuleRef)m);
}

void __llvm_set_target(void *m, void *triple) {
  LLVMSetTarget((LLVMModuleRef)m, (const char *)triple);
}

void *__llvm_copy_module_flags_metadata(void *m, size_t *len) {
  return (LLVMModuleFlagEntry *)LLVMCopyModuleFlagsMetadata((LLVMModuleRef)m,
                                                            len);
}

void __llvm_dispose_module_flags_metadata(void *entries) {
  LLVMDisposeModuleFlagsMetadata((LLVMModuleFlagEntry *)entries);
}

LLVMModuleFlagBehavior
__llvm_module_flag_entries_get_flag_behavior(void *entries, unsigned index) {
  return LLVMModuleFlagEntriesGetFlagBehavior((LLVMModuleFlagEntry *)entries,
                                              index);
}

void *__llvm_module_flag_entries_get_key(void *entries, unsigned index,
                                         size_t *len) {
  return (char *)LLVMModuleFlagEntriesGetKey((LLVMModuleFlagEntry *)entries,
                                             index, len);
}

void *__llvm_module_flag_entries_get_metadata(void *entries, unsigned index) {
  return (LLVMMetadataRef)LLVMModuleFlagEntriesGetMetadata(
      (LLVMModuleFlagEntry *)entries, index);
}

void *__llvm_get_module_flag(void *m, void *key, size_t key_len) {
  return (LLVMMetadataRef)LLVMGetModuleFlag((LLVMModuleRef)m, (const char *)key,
                                            key_len);
}

void __llvm_add_module_flag(void *m, LLVMModuleFlagBehavior behavior, void *key,
                            size_t key_len, void *val) {
  LLVMAddModuleFlag((LLVMModuleRef)m, behavior, (const char *)key, key_len,
                    (LLVMMetadataRef)val);
}

void __llvm_dump_module(void *m) { LLVMDumpModule((LLVMModuleRef)m); }

LLVMBool __llvm_print_module_to_file(void *m, void *filename,
                                     void **error_message) {
  return LLVMPrintModuleToFile((LLVMModuleRef)m, (const char *)filename,
                               (char **)error_message);
}

void *__llvm_print_module_to_string(void *m) {
  return (char *)LLVMPrintModuleToString((LLVMModuleRef)m);
}

void *__llvm_get_module_inline_asm(void *m, size_t *len) {
  return (char *)LLVMGetModuleInlineAsm((LLVMModuleRef)m, len);
}

void __llvm_set_module_inline_asm2(void *m, void *_asm, size_t len) {
  LLVMSetModuleInlineAsm2((LLVMModuleRef)m, (char *)_asm, len);
}

void __llvm_append_module_inline_asm(void *m, void *_asm, size_t len) {
  LLVMAppendModuleInlineAsm((LLVMModuleRef)m, (char *)_asm, len);
}

void *__llvm_get_inline_asm(void *ty, void *asm_string, size_t asm_string_size,
                            void *constraints, size_t constraints_size,
                            LLVMBool has_side_effects, LLVMBool is_align_stack,
                            LLVMInlineAsmDialect dialect, LLVMBool can_throw) {
  return (LLVMValueRef)LLVMGetInlineAsm(
      (LLVMTypeRef)ty, (const char *)asm_string, asm_string_size,
      (const char *)constraints, constraints_size, has_side_effects,
      is_align_stack, dialect, can_throw);
}

void *__llvm_get_inline_asm_asm_string(void *inline_asm_val, size_t *len) {
  return (char *)LLVMGetInlineAsmAsmString((LLVMValueRef)inline_asm_val, len);
}

void *__llvm_get_inline_asm_constraint_string(void *inline_asm_val,
                                              size_t *len) {
  return (char *)LLVMGetInlineAsmConstraintString((LLVMValueRef)inline_asm_val,
                                                  len);
}

LLVMInlineAsmDialect __llvm_get_inline_asm_dialect(void *inline_asm_val) {
  return LLVMGetInlineAsmDialect((LLVMValueRef)inline_asm_val);
}

void *__llvm_get_inline_asm_function_type(void *inline_asm_val) {
  return (LLVMTypeRef)LLVMGetInlineAsmFunctionType(
      (LLVMValueRef)inline_asm_val);
}

LLVMBool __llvm_get_inline_asm_has_side_effects(void *inline_asm_val) {
  return LLVMGetInlineAsmHasSideEffects((LLVMValueRef)inline_asm_val);
}

LLVMBool __llvm_get_inline_asm_needs_aligned_stack(void *inline_asm_val) {
  return LLVMGetInlineAsmNeedsAlignedStack((LLVMValueRef)inline_asm_val);
}

LLVMBool __llvm_get_inline_asm_can_unwind(void *inline_asm_val) {
  return LLVMGetInlineAsmCanUnwind((LLVMValueRef)inline_asm_val);
}

void *__llvm_get_module_context(void *m) {
  return (LLVMContextRef)LLVMGetModuleContext((LLVMModuleRef)m);
}

void *__llvm_get_type_by_name_in_module(void *m, void *name) {
  return (LLVMTypeRef)LLVMGetTypeByName((LLVMModuleRef)m, (const char *)name);
}

void *__llvm_get_first_named_metadata(void *m) {
  return (LLVMNamedMDNodeRef)LLVMGetFirstNamedMetadata((LLVMModuleRef)m);
}

void *__llvm_get_last_named_metadata(void *m) {
  return (LLVMNamedMDNodeRef)LLVMGetLastNamedMetadata((LLVMModuleRef)m);
}

void *__llvm_get_next_named_metadata(void *named_md_node) {
  return (LLVMNamedMDNodeRef)LLVMGetNextNamedMetadata(
      (LLVMNamedMDNodeRef)named_md_node);
}

void *__llvm_get_previous_named_metadata(void *named_md_node) {
  return (LLVMNamedMDNodeRef)LLVMGetPreviousNamedMetadata(
      (LLVMNamedMDNodeRef)named_md_node);
}

void *__llvm_get_named_metadata(void *m, void *name, size_t name_len) {
  return (LLVMNamedMDNodeRef)LLVMGetNamedMetadata((LLVMModuleRef)m,
                                                  (const char *)name, name_len);
}

void *__llvm_get_or_insert_named_metadata(void *m, void *name,
                                          size_t name_len) {
  return (LLVMNamedMDNodeRef)LLVMGetOrInsertNamedMetadata(
      (LLVMModuleRef)m, (const char *)name, name_len);
}

void *__llvm_get_named_metadata_name(void *named_md, size_t *name_len) {
  return (char *)LLVMGetNamedMetadataName((LLVMNamedMDNodeRef)named_md,
                                          name_len);
}

unsigned __llvm_get_named_metadata_num_operands(void *m, void *name) {
  return LLVMGetNamedMetadataNumOperands((LLVMModuleRef)m, (const char *)name);
}

void __llvm_get_named_metadata_operands(void *m, void *name, void *dest) {
  LLVMGetNamedMetadataOperands((LLVMModuleRef)m, (const char *)name,
                               (LLVMValueRef *)dest);
}

void __llvm_add_named_metadata_operand(void *m, void *name, void *val) {
  LLVMAddNamedMetadataOperand((LLVMModuleRef)m, (const char *)name,
                              (LLVMValueRef)val);
}

void *__llvm_get_debug_loc_directory(void *val, unsigned *length) {
  return (char *)LLVMGetDebugLocDirectory((LLVMValueRef)val, length);
}

void *__llvm_get_debug_loc_filename(void *val, unsigned *length) {
  return (char *)LLVMGetDebugLocFilename((LLVMValueRef)val, length);
}

unsigned __llvm_get_debug_loc_line(void *val) {
  return LLVMGetDebugLocLine((LLVMValueRef)val);
}

unsigned __llvm_get_debug_loc_column(void *val) {
  return LLVMGetDebugLocColumn((LLVMValueRef)val);
}

void *__llvm_add_function(void *m, void *name, void *function_ty) {
  return (LLVMValueRef)LLVMAddFunction((LLVMModuleRef)m, (const char *)name,
                                       (LLVMTypeRef)function_ty);
}

void *__llvm_get_named_function(void *m, void *name) {
  return (LLVMValueRef)LLVMGetNamedFunction((LLVMModuleRef)m,
                                            (const char *)name);
}

void *__llvm_get_first_function(void *m) {
  return (LLVMValueRef)LLVMGetFirstFunction((LLVMModuleRef)m);
}

void *__llvm_get_last_function(void *m) {
  return (LLVMValueRef)LLVMGetLastFunction((LLVMModuleRef)m);
}

void *__llvm_get_next_function(void *fn) {
  return (LLVMValueRef)LLVMGetNextFunction((LLVMValueRef)fn);
}

void *__llvm_get_previous_function(void *fn) {
  return (LLVMValueRef)LLVMGetPreviousFunction((LLVMValueRef)fn);
}

void __llvm_set_module_inline_asm(void *m, void *_asm) {
  LLVMSetModuleInlineAsm((LLVMModuleRef)m, (char *)_asm);
}

int32_t __llvm_get_type_kind(void *ty) {
  LLVMTypeKind k = LLVMGetTypeKind((LLVMTypeRef)ty);
  return llvm_type_kind_to_int(k);
}

LLVMBool __llvm_type_is_sized(void *ty) {
  return LLVMTypeIsSized((LLVMTypeRef)ty);
}

void *__llvm_get_type_context(void *ty) {
  return (LLVMContextRef)LLVMGetTypeContext((LLVMTypeRef)ty);
}

void __llvm_dump_type(void *val) { LLVMDumpType((LLVMTypeRef)val); }

void *__llvm_print_type_to_string(void *val) {
  return (char *)LLVMPrintTypeToString((LLVMTypeRef)val);
}

void *__llvm_int1_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMInt1TypeInContext((LLVMContextRef)context);
}

void *__llvm_int8_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMInt8TypeInContext((LLVMContextRef)context);
}

void *__llvm_int16_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMInt16TypeInContext((LLVMContextRef)context);
}

void *__llvm_int32_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMInt32TypeInContext((LLVMContextRef)context);
}

void *__llvm_int64_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMInt64TypeInContext((LLVMContextRef)context);
}

void *__llvm_int128_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMInt128TypeInContext((LLVMContextRef)context);
}

void *__llvm_int_type_in_context(void *context, unsigned num_bits) {
  return (LLVMTypeRef)LLVMIntTypeInContext((LLVMContextRef)context, num_bits);
}

void *__llvm_int1_type() { return (LLVMTypeRef)LLVMInt1Type(); }

void *__llvm_int8_type() { return (LLVMTypeRef)LLVMInt8Type(); }

void *__llvm_int16_type() { return (LLVMTypeRef)LLVMInt16Type(); }

void *__llvm_int32_type() { return (LLVMTypeRef)LLVMInt32Type(); }

void *__llvm_int64_type() { return (LLVMTypeRef)LLVMInt64Type(); }

void *__llvm_int128_type() { return (LLVMTypeRef)LLVMInt128Type(); }

void *__llvm_int_type(unsigned num_bits) {
  return (LLVMTypeRef)LLVMIntType(num_bits);
}

unsigned __llvm_get_int_type_width(void *integer_ty) {
  return LLVMGetIntTypeWidth((LLVMTypeRef)integer_ty);
}

void *__llvm_half_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMHalfTypeInContext((LLVMContextRef)context);
}

void *__llvm_bfloat_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMBFloatTypeInContext((LLVMContextRef)context);
}

void *__llvm_float_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMFloatTypeInContext((LLVMContextRef)context);
}

void *__llvm_double_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMDoubleTypeInContext((LLVMContextRef)context);
}

void *__llvm_x86_fp80_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMX86FP80TypeInContext((LLVMContextRef)context);
}

void *__llvm_fp128_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMFP128TypeInContext((LLVMContextRef)context);
}

void *__llvm_ppc_fp128_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMPPCFP128TypeInContext((LLVMContextRef)context);
}

void *__llvm_half_type() { return (LLVMTypeRef)LLVMHalfType(); }

void *__llvm_bfloat_type() { return (LLVMTypeRef)LLVMBFloatType(); }

void *__llvm_float_type() { return (LLVMTypeRef)LLVMFloatType(); }

void *__llvm_double_type() { return (LLVMTypeRef)LLVMDoubleType(); }

void *__llvm_x86_fp80_type() { return (LLVMTypeRef)LLVMX86FP80Type(); }

void *__llvm_fp128_type() { return (LLVMTypeRef)LLVMFP128Type(); }

void *__llvm_ppc_fp128_type() { return (LLVMTypeRef)LLVMPPCFP128Type(); }

void *__llvm_function_type(void *return_type, ArrayLLVMTypeRef *param_types,
                           LLVMBool is_var_arg) {
  LLVMTypeRef *llvm_param_types = (LLVMTypeRef *)param_types->$0->data;
  unsigned param_count = param_types->$1;
  return (LLVMTypeRef)LLVMFunctionType(
      (LLVMTypeRef)return_type, llvm_param_types, param_count, is_var_arg);
}

LLVMBool __llvm_is_function_var_arg(void *function_ty) {
  return LLVMIsFunctionVarArg((LLVMTypeRef)function_ty);
}

void *__llvm_get_return_type(void *function_ty) {
  return (LLVMTypeRef)LLVMGetReturnType((LLVMTypeRef)function_ty);
}

unsigned __llvm_count_param_types(void *function_ty) {
  return LLVMCountParamTypes((LLVMTypeRef)function_ty);
}

void __llvm_get_param_types(void *function_ty, void *dest) {
  LLVMGetParamTypes((LLVMTypeRef)function_ty, (LLVMTypeRef *)dest);
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

void *__llvm_struct_create_named(void *context, void *name) {
  return (LLVMTypeRef)LLVMStructCreateNamed((LLVMContextRef)context,
                                            (const char *)name);
}

void *__llvm_get_struct_name(void *ty) {
  return (char *)LLVMGetStructName((LLVMTypeRef)ty);
}

void __llvm_struct_set_body(void *struct_ty, ArrayLLVMTypeRef *element_types,
                            LLVMBool packed) {
  LLVMTypeRef *llvm_element_types = (LLVMTypeRef *)element_types->$0->data;
  unsigned element_count = element_types->$1;
  LLVMStructSetBody((LLVMTypeRef)struct_ty, llvm_element_types, element_count,
                    packed);
}

unsigned __llvm_count_struct_element_types(void *struct_ty) {
  return LLVMCountStructElementTypes((LLVMTypeRef)struct_ty);
}

void __llvm_get_struct_element_types(void *struct_ty, void *dest) {
  LLVMGetStructElementTypes((LLVMTypeRef)struct_ty, (LLVMTypeRef *)dest);
}

void *__llvm_struct_get_type_at_index(void *struct_ty, unsigned i) {
  return (LLVMTypeRef)LLVMStructGetTypeAtIndex((LLVMTypeRef)struct_ty, i);
}

LLVMBool __llvm_is_packed_struct(void *struct_ty) {
  return LLVMIsPackedStruct((LLVMTypeRef)struct_ty);
}

LLVMBool __llvm_is_opaque_struct(void *struct_ty) {
  return LLVMIsOpaqueStruct((LLVMTypeRef)struct_ty);
}

LLVMBool __llvm_is_literal_struct(void *struct_ty) {
  return LLVMIsLiteralStruct((LLVMTypeRef)struct_ty);
}

void *__llvm_get_element_type(void *ty) {
  return (LLVMTypeRef)LLVMGetElementType((LLVMTypeRef)ty);
}

void __llvm_get_subtypes(void *tp, void *arr) {
  LLVMGetSubtypes((LLVMTypeRef)tp, (LLVMTypeRef *)arr);
}

unsigned __llvm_get_num_contained_types(void *tp) {
  return LLVMGetNumContainedTypes((LLVMTypeRef)tp);
}

void *__llvm_array_type(void *element_type, unsigned element_count) {
  return (LLVMTypeRef)LLVMArrayType((LLVMTypeRef)element_type, element_count);
}

void *__llvm_array_type2(void *element_type, uint64_t element_count) {
  return (LLVMTypeRef)LLVMArrayType2((LLVMTypeRef)element_type, element_count);
}

unsigned __llvm_get_array_length(void *array_ty) {
  return LLVMGetArrayLength((LLVMTypeRef)array_ty);
}

uint64_t __llvm_get_array_length2(void *array_ty) {
  return LLVMGetArrayLength2((LLVMTypeRef)array_ty);
}

void *__llvm_pointer_type(void *element_type, unsigned address_space) {
  return (LLVMTypeRef)LLVMPointerType((LLVMTypeRef)element_type, address_space);
}

LLVMBool __llvm_pointer_type_is_opaque(void *ty) {
  return LLVMPointerTypeIsOpaque((LLVMTypeRef)ty);
}

void *__llvm_pointer_type_in_context(void *context, unsigned address_space) {
  return (LLVMTypeRef)LLVMPointerTypeInContext((LLVMContextRef)context,
                                               address_space);
}

unsigned __llvm_get_pointer_address_space(void *pointer_ty) {
  return LLVMGetPointerAddressSpace((LLVMTypeRef)pointer_ty);
}

void *__llvm_vector_type(void *element_type, unsigned element_count) {
  return (LLVMTypeRef)LLVMVectorType((LLVMTypeRef)element_type, element_count);
}

void *__llvm_scalable_vector_type(void *element_type, unsigned element_count) {
  return (LLVMTypeRef)LLVMScalableVectorType((LLVMTypeRef)element_type,
                                             element_count);
}

unsigned __llvm_get_vector_size(void *vector_ty) {
  return LLVMGetVectorSize((LLVMTypeRef)vector_ty);
}

void *__llvm_void_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMVoidTypeInContext((LLVMContextRef)context);
}

void *__llvm_label_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMLabelTypeInContext((LLVMContextRef)context);
}

void *__llvm_x86_mmx_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMX86MMXTypeInContext((LLVMContextRef)context);
}

void *__llvm_x86_amx_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMX86AMXTypeInContext((LLVMContextRef)context);
}

void *__llvm_token_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMTokenTypeInContext((LLVMContextRef)context);
}

void *__llvm_metadata_type_in_context(void *context) {
  return (LLVMTypeRef)LLVMMetadataTypeInContext((LLVMContextRef)context);
}

void *__llvm_void_type() { return (LLVMTypeRef)LLVMVoidType(); }

void *__llvm_label_type() { return (LLVMTypeRef)LLVMLabelType(); }

void *__llvm_x86_mmx_type() { return (LLVMTypeRef)LLVMX86MMXType(); }

void *__llvm_x86_amx_type() { return (LLVMTypeRef)LLVMX86AMXType(); }

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

void *__llvm_get_target_ext_type_name(void *target_ext_ty) {
  return (char *)LLVMGetTargetExtTypeName((LLVMTypeRef)target_ext_ty);
}

unsigned __llvm_get_target_ext_type_num_type_params(void *target_ext_ty) {
  return LLVMGetTargetExtTypeNumTypeParams((LLVMTypeRef)target_ext_ty);
}

void *__llvm_get_target_ext_type_type_param(void *target_ext_ty, unsigned idx) {
  return (LLVMTypeRef)LLVMGetTargetExtTypeTypeParam((LLVMTypeRef)target_ext_ty,
                                                    idx);
}

unsigned __llvm_get_target_ext_type_num_int_params(void *target_ext_ty) {
  return LLVMGetTargetExtTypeNumIntParams((LLVMTypeRef)target_ext_ty);
}

unsigned __llvm_get_target_ext_type_int_param(void *target_ext_ty,
                                              unsigned idx) {
  return LLVMGetTargetExtTypeIntParam((LLVMTypeRef)target_ext_ty, idx);
}

void *__llvm_type_of(void *val) {
  return (LLVMTypeRef)LLVMTypeOf((LLVMValueRef)val);
}

LLVMValueKind __llvm_get_value_kind(void *val) {
  return LLVMGetValueKind((LLVMValueRef)val);
}

void *__llvm_get_value_name2(void *val, size_t *length) {
  return (char *)LLVMGetValueName2((LLVMValueRef)val, length);
}

void __llvm_set_value_name2(void *val, void *name, size_t name_len) {
  LLVMSetValueName2((LLVMValueRef)val, (const char *)name, name_len);
}

void __llvm_dump_value(void *val) { LLVMDumpValue((LLVMValueRef)val); }

void *__llvm_print_value_to_string(void *val) {
  return (char *)LLVMPrintValueToString((LLVMValueRef)val);
}

void *__llvm_print_dbg_record_to_string(void *record) {
  return (char *)LLVMPrintDbgRecordToString((LLVMDbgRecordRef)record);
}

void __llvm_replace_all_uses_with(void *old_val, void *new_val) {
  LLVMReplaceAllUsesWith((LLVMValueRef)old_val, (LLVMValueRef)new_val);
}

LLVMBool __llvm_is_constant(void *val) {
  return LLVMIsConstant((LLVMValueRef)val);
}

LLVMBool __llvm_is_undef(void *val) { return LLVMIsUndef((LLVMValueRef)val); }

LLVMBool __llvm_is_poison(void *val) { return LLVMIsPoison((LLVMValueRef)val); }

void *__llvm_isa_argument(void *val) {
  return (LLVMValueRef)LLVMIsAArgument((LLVMValueRef)val);
}

void *__llvm_isa_basic_block(void *val) {
  return (LLVMValueRef)LLVMIsABasicBlock((LLVMValueRef)val);
}

void *__llvm_isa_inline_asm(void *val) {
  return (LLVMValueRef)LLVMIsAInlineAsm((LLVMValueRef)val);
}

void *__llvm_isa_user(void *val) {
  return (LLVMValueRef)LLVMIsAUser((LLVMValueRef)val);
}

void *__llvm_isa_constant(void *val) {
  return (LLVMValueRef)LLVMIsAConstant((LLVMValueRef)val);
}

void *__llvm_isa_block_address(void *val) {
  return (LLVMValueRef)LLVMIsABlockAddress((LLVMValueRef)val);
}

void *__llvm_isa_constant_aggregate_zero(void *val) {
  return (LLVMValueRef)LLVMIsAConstantAggregateZero((LLVMValueRef)val);
}

void *__llvm_isa_constant_array(void *val) {
  return (LLVMValueRef)LLVMIsAConstantArray((LLVMValueRef)val);
}

void *__llvm_isa_constant_data_sequential(void *val) {
  return (LLVMValueRef)LLVMIsAConstantDataSequential((LLVMValueRef)val);
}

void *__llvm_isa_constant_data_array(void *val) {
  return (LLVMValueRef)LLVMIsAConstantDataArray((LLVMValueRef)val);
}

void *__llvm_isa_constant_data_vector(void *val) {
  return (LLVMValueRef)LLVMIsAConstantDataVector((LLVMValueRef)val);
}

void *__llvm_isa_constant_expr(void *val) {
  return (LLVMValueRef)LLVMIsAConstantExpr((LLVMValueRef)val);
}

void *__llvm_isa_constant_fp(void *val) {
  return (LLVMValueRef)LLVMIsAConstantFP((LLVMValueRef)val);
}

void *__llvm_isa_constant_int(void *val) {
  return (LLVMValueRef)LLVMIsAConstantInt((LLVMValueRef)val);
}

void *__llvm_isa_constant_pointer_null(void *val) {
  return (LLVMValueRef)LLVMIsAConstantPointerNull((LLVMValueRef)val);
}

void *__llvm_isa_constant_struct(void *val) {
  return (LLVMValueRef)LLVMIsAConstantStruct((LLVMValueRef)val);
}

void *__llvm_isa_constant_token_none(void *val) {
  return (LLVMValueRef)LLVMIsAConstantTokenNone((LLVMValueRef)val);
}

void *__llvm_isa_constant_vector(void *val) {
  return (LLVMValueRef)LLVMIsAConstantVector((LLVMValueRef)val);
}

void *__llvm_isa_global_value(void *val) {
  return (LLVMValueRef)LLVMIsAGlobalValue((LLVMValueRef)val);
}

void *__llvm_isa_global_alias(void *val) {
  return (LLVMValueRef)LLVMIsAGlobalAlias((LLVMValueRef)val);
}

void *__llvm_isa_global_object(void *val) {
  return (LLVMValueRef)LLVMIsAGlobalObject((LLVMValueRef)val);
}

void *__llvm_isa_function(void *val) {
  return (LLVMValueRef)LLVMIsAFunction((LLVMValueRef)val);
}

void *__llvm_isa_global_variable(void *val) {
  return (LLVMValueRef)LLVMIsAGlobalVariable((LLVMValueRef)val);
}

void *__llvm_isa_global_ifunc(void *val) {
  return (LLVMValueRef)LLVMIsAGlobalIFunc((LLVMValueRef)val);
}

void *__llvm_isa_undef_value(void *val) {
  return (LLVMValueRef)LLVMIsAUndefValue((LLVMValueRef)val);
}

void *__llvm_isa_poison_value(void *val) {
  return (LLVMValueRef)LLVMIsAPoisonValue((LLVMValueRef)val);
}

void *__llvm_isa_instruction(void *val) {
  return (LLVMValueRef)LLVMIsAInstruction((LLVMValueRef)val);
}

void *__llvm_isa_unary_operator(void *val) {
  return (LLVMValueRef)LLVMIsAUnaryOperator((LLVMValueRef)val);
}

void *__llvm_isa_binary_operator(void *val) {
  return (LLVMValueRef)LLVMIsABinaryOperator((LLVMValueRef)val);
}

void *__llvm_isa_call_inst(void *val) {
  return (LLVMValueRef)LLVMIsACallInst((LLVMValueRef)val);
}

void *__llvm_isa_intrinsic_inst(void *val) {
  return (LLVMValueRef)LLVMIsAIntrinsicInst((LLVMValueRef)val);
}

void *__llvm_isa_dbg_info_intrinsic(void *val) {
  return (LLVMValueRef)LLVMIsADbgInfoIntrinsic((LLVMValueRef)val);
}

void *__llvm_isa_dbg_variable_intrinsic(void *val) {
  return (LLVMValueRef)LLVMIsADbgVariableIntrinsic((LLVMValueRef)val);
}

void *__llvm_isa_dbg_declare_inst(void *val) {
  return (LLVMValueRef)LLVMIsADbgDeclareInst((LLVMValueRef)val);
}

void *__llvm_isa_dbg_label_inst(void *val) {
  return (LLVMValueRef)LLVMIsADbgLabelInst((LLVMValueRef)val);
}

void *__llvm_isa_mem_intrinsic(void *val) {
  return (LLVMValueRef)LLVMIsAMemIntrinsic((LLVMValueRef)val);
}

void *__llvm_isa_mem_cpy_inst(void *val) {
  return (LLVMValueRef)LLVMIsAMemCpyInst((LLVMValueRef)val);
}

void *__llvm_isa_mem_move_inst(void *val) {
  return (LLVMValueRef)LLVMIsAMemMoveInst((LLVMValueRef)val);
}

void *__llvm_isa_mem_set_inst(void *val) {
  return (LLVMValueRef)LLVMIsAMemSetInst((LLVMValueRef)val);
}

void *__llvm_isa_cmp_inst(void *val) {
  return (LLVMValueRef)LLVMIsACmpInst((LLVMValueRef)val);
}

void *__llvm_isa_f_cmp_inst(void *val) {
  return (LLVMValueRef)LLVMIsAFCmpInst((LLVMValueRef)val);
}

void *__llvm_isa_i_cmp_inst(void *val) {
  return (LLVMValueRef)LLVMIsAICmpInst((LLVMValueRef)val);
}

void *__llvm_isa_extract_element_inst(void *val) {
  return (LLVMValueRef)LLVMIsAExtractElementInst((LLVMValueRef)val);
}

void *__llvm_isa_get_element_ptr_inst(void *val) {
  return (LLVMValueRef)LLVMIsAGetElementPtrInst((LLVMValueRef)val);
}

void *__llvm_isa_insert_element_inst(void *val) {
  return (LLVMValueRef)LLVMIsAInsertElementInst((LLVMValueRef)val);
}

void *__llvm_isa_insert_value_inst(void *val) {
  return (LLVMValueRef)LLVMIsAInsertValueInst((LLVMValueRef)val);
}

void *__llvm_isa_landing_pad_inst(void *val) {
  return (LLVMValueRef)LLVMIsALandingPadInst((LLVMValueRef)val);
}

void *__llvm_isa_phi_node(void *val) {
  return (LLVMValueRef)LLVMIsAPHINode((LLVMValueRef)val);
}

void *__llvm_isa_select_inst(void *val) {
  return (LLVMValueRef)LLVMIsASelectInst((LLVMValueRef)val);
}

void *__llvm_isa_shuffle_vector_inst(void *val) {
  return (LLVMValueRef)LLVMIsAShuffleVectorInst((LLVMValueRef)val);
}

void *__llvm_isa_store_inst(void *val) {
  return (LLVMValueRef)LLVMIsAStoreInst((LLVMValueRef)val);
}

void *__llvm_isa_branch_inst(void *val) {
  return (LLVMValueRef)LLVMIsABranchInst((LLVMValueRef)val);
}

void *__llvm_isa_indirect_br_inst(void *val) {
  return (LLVMValueRef)LLVMIsAIndirectBrInst((LLVMValueRef)val);
}

void *__llvm_isa_invoke_inst(void *val) {
  return (LLVMValueRef)LLVMIsAInvokeInst((LLVMValueRef)val);
}

void *__llvm_isa_return_inst(void *val) {
  return (LLVMValueRef)LLVMIsAReturnInst((LLVMValueRef)val);
}

void *__llvm_isa_switch_inst(void *val) {
  return (LLVMValueRef)LLVMIsASwitchInst((LLVMValueRef)val);
}

void *__llvm_isa_unreachable_inst(void *val) {
  return (LLVMValueRef)LLVMIsAUnreachableInst((LLVMValueRef)val);
}

void *__llvm_isa_resume_inst(void *val) {
  return (LLVMValueRef)LLVMIsAResumeInst((LLVMValueRef)val);
}

void *__llvm_isa_cleanup_return_inst(void *val) {
  return (LLVMValueRef)LLVMIsACleanupReturnInst((LLVMValueRef)val);
}

void *__llvm_isa_catch_return_inst(void *val) {
  return (LLVMValueRef)LLVMIsACatchReturnInst((LLVMValueRef)val);
}

void *__llvm_isa_catch_switch_inst(void *val) {
  return (LLVMValueRef)LLVMIsACatchSwitchInst((LLVMValueRef)val);
}

void *__llvm_isa_call_br_inst(void *val) {
  return (LLVMValueRef)LLVMIsACallBrInst((LLVMValueRef)val);
}

void *__llvm_isa_funclet_pad_inst(void *val) {
  return (LLVMValueRef)LLVMIsAFuncletPadInst((LLVMValueRef)val);
}

void *__llvm_isa_catch_pad_inst(void *val) {
  return (LLVMValueRef)LLVMIsACatchPadInst((LLVMValueRef)val);
}

void *__llvm_isa_cleanup_pad_inst(void *val) {
  return (LLVMValueRef)LLVMIsACleanupPadInst((LLVMValueRef)val);
}

void *__llvm_isa_unary_instruction(void *val) {
  return (LLVMValueRef)LLVMIsAUnaryInstruction((LLVMValueRef)val);
}

void *__llvm_isa_alloca_inst(void *val) {
  return (LLVMValueRef)LLVMIsAAllocaInst((LLVMValueRef)val);
}

void *__llvm_isa_cast_inst(void *val) {
  return (LLVMValueRef)LLVMIsACastInst((LLVMValueRef)val);
}

void *__llvm_isa_addr_space_cast_inst(void *val) {
  return (LLVMValueRef)LLVMIsAAddrSpaceCastInst((LLVMValueRef)val);
}

void *__llvm_isa_bit_cast_inst(void *val) {
  return (LLVMValueRef)LLVMIsABitCastInst((LLVMValueRef)val);
}

void *__llvm_isa_fp_ext_inst(void *val) {
  return (LLVMValueRef)LLVMIsAFPExtInst((LLVMValueRef)val);
}

void *__llvm_isa_fp_to_si_inst(void *val) {
  return (LLVMValueRef)LLVMIsAFPToSIInst((LLVMValueRef)val);
}

void *__llvm_isa_fp_to_ui_inst(void *val) {
  return (LLVMValueRef)LLVMIsAFPToUIInst((LLVMValueRef)val);
}

void *__llvm_isa_fp_trunc_inst(void *val) {
  return (LLVMValueRef)LLVMIsAFPTruncInst((LLVMValueRef)val);
}

void *__llvm_isa_int_to_ptr_inst(void *val) {
  return (LLVMValueRef)LLVMIsAIntToPtrInst((LLVMValueRef)val);
}

void *__llvm_isa_ptr_to_int_inst(void *val) {
  return (LLVMValueRef)LLVMIsAPtrToIntInst((LLVMValueRef)val);
}

void *__llvm_isa_sext_inst(void *val) {
  return (LLVMValueRef)LLVMIsASExtInst((LLVMValueRef)val);
}

void *__llvm_isa_si_to_fp_inst(void *val) {
  return (LLVMValueRef)LLVMIsASIToFPInst((LLVMValueRef)val);
}

void *__llvm_isa_trunc_inst(void *val) {
  return (LLVMValueRef)LLVMIsATruncInst((LLVMValueRef)val);
}

void *__llvm_isa_ui_to_fp_inst(void *val) {
  return (LLVMValueRef)LLVMIsAUIToFPInst((LLVMValueRef)val);
}

void *__llvm_isa_z_ext_inst(void *val) {
  return (LLVMValueRef)LLVMIsAZExtInst((LLVMValueRef)val);
}

void *__llvm_isa_extract_value_inst(void *val) {
  return (LLVMValueRef)LLVMIsAExtractValueInst((LLVMValueRef)val);
}

void *__llvm_isa_load_inst(void *val) {
  return (LLVMValueRef)LLVMIsALoadInst((LLVMValueRef)val);
}

void *__llvm_isa_va_arg_inst(void *val) {
  return (LLVMValueRef)LLVMIsAVAArgInst((LLVMValueRef)val);
}

void *__llvm_isa_freeze_inst(void *val) {
  return (LLVMValueRef)LLVMIsAFreezeInst((LLVMValueRef)val);
}

void *__llvm_isa_atomic_cmp_xchg_inst(void *val) {
  return (LLVMValueRef)LLVMIsAAtomicCmpXchgInst((LLVMValueRef)val);
}

void *__llvm_isa_atomic_rmw_inst(void *val) {
  return (LLVMValueRef)LLVMIsAAtomicRMWInst((LLVMValueRef)val);
}

void *__llvm_isa_fence_inst(void *val) {
  return (LLVMValueRef)LLVMIsAFenceInst((LLVMValueRef)val);
}

void *__llvm_isa_md_node(void *val) {
  return (LLVMValueRef)LLVMIsAMDNode((LLVMValueRef)val);
}

void *__llvm_isa_value_as_metadata(void *val) {
  return (LLVMValueRef)LLVMIsAValueAsMetadata((LLVMValueRef)val);
}

void *__llvm_isa_md_string(void *val) {
  return (LLVMValueRef)LLVMIsAMDString((LLVMValueRef)val);
}

void *__llvm_get_value_name(void *val) {
  return (char *)LLVMGetValueName((LLVMValueRef)val);
}

void __llvm_set_value_name(void *val, void *name) {
  LLVMSetValueName((LLVMValueRef)val, (const char *)name);
}

void *__llvm_get_first_use(void *val) {
  return (LLVMUseRef)LLVMGetFirstUse((LLVMValueRef)val);
}

void *__llvm_get_next_use(void *u) {
  return (LLVMUseRef)LLVMGetNextUse((LLVMUseRef)u);
}

void *__llvm_get_user(void *u) {
  return (LLVMValueRef)LLVMGetUser((LLVMUseRef)u);
}

void *__llvm_get_used_value(void *u) {
  return (LLVMValueRef)LLVMGetUsedValue((LLVMUseRef)u);
}

void *__llvm_get_operand(void *val, unsigned index) {
  return (LLVMValueRef)LLVMGetOperand((LLVMValueRef)val, index);
}

void *__llvm_get_operand_use(void *val, unsigned index) {
  return (LLVMUseRef)LLVMGetOperandUse((LLVMValueRef)val, index);
}

void __llvm_set_operand(void *user, unsigned index, void *val) {
  LLVMSetOperand((LLVMValueRef)user, index, (LLVMValueRef)val);
}

int __llvm_get_num_operands(void *val) {
  return LLVMGetNumOperands((LLVMValueRef)val);
}

void *__llvm_const_null(void *ty) {
  return (LLVMValueRef)LLVMConstNull((LLVMTypeRef)ty);
}

void *__llvm_const_all_ones(void *ty) {
  return (LLVMValueRef)LLVMConstAllOnes((LLVMTypeRef)ty);
}

void *__llvm_get_undef(void *ty) {
  return (LLVMValueRef)LLVMGetUndef((LLVMTypeRef)ty);
}

void *__llvm_get_poison(void *ty) {
  return (LLVMValueRef)LLVMGetPoison((LLVMTypeRef)ty);
}

LLVMBool __llvm_is_null(void *val) { return LLVMIsNull((LLVMValueRef)val); }

void *__llvm_const_pointer_null(void *ty) {
  return (LLVMValueRef)LLVMConstPointerNull((LLVMTypeRef)ty);
}

void *__llvm_const_int(void *int_ty, unsigned long long n,
                       LLVMBool sign_extend) {
  return (LLVMValueRef)LLVMConstInt((LLVMTypeRef)int_ty, n, sign_extend);
}

void *__llvm_const_int_of_arbitrary_precision(void *int_ty,
                                              ArrayUInt64_t *words) {
  const uint64_t *llvm_words = (const uint64_t *)words->$0->data;
  unsigned num_words = words->$1;
  return (LLVMValueRef)LLVMConstIntOfArbitraryPrecision((LLVMTypeRef)int_ty,
                                                        num_words, llvm_words);
}

void *__llvm_const_int_of_string(void *int_ty, void *text, uint8_t radix) {
  return (LLVMValueRef)LLVMConstIntOfString((LLVMTypeRef)int_ty,
                                            (const char *)text, radix);
}

void *__llvm_const_int_of_string_and_size(void *int_ty, void *text,
                                          unsigned s_len, uint8_t radix) {
  return (LLVMValueRef)LLVMConstIntOfStringAndSize(
      (LLVMTypeRef)int_ty, (const char *)text, s_len, radix);
}

void *__llvm_const_real(void *real_ty, double n) {
  return (LLVMValueRef)LLVMConstReal((LLVMTypeRef)real_ty, n);
}

void *__llvm_const_real_of_string(void *real_ty, void *text) {
  return (LLVMValueRef)LLVMConstRealOfString((LLVMTypeRef)real_ty,
                                             (const char *)text);
}

void *__llvm_const_real_of_string_and_size(void *real_ty, void *text,
                                           unsigned s_len) {
  return (LLVMValueRef)LLVMConstRealOfStringAndSize((LLVMTypeRef)real_ty,
                                                    (const char *)text, s_len);
}

unsigned long long __llvm_const_int_get_z_ext_value(void *constant_val) {
  return LLVMConstIntGetZExtValue((LLVMValueRef)constant_val);
}

long long __llvm_const_int_get_s_ext_value(void *constant_val) {
  return LLVMConstIntGetSExtValue((LLVMValueRef)constant_val);
}

double __llvm_const_real_get_double(void *constant_val, LLVMBool *loses_info) {
  return LLVMConstRealGetDouble((LLVMValueRef)constant_val, loses_info);
}

void *__llvm_const_string_in_context(void *context, void *str, unsigned length,
                                     LLVMBool dont_null_terminate) {
  return (LLVMValueRef)LLVMConstStringInContext(
      (LLVMContextRef)context, (const char *)str, length, dont_null_terminate);
}

void *__llvm_const_string_in_context2(void *context, void *str, size_t length,
                                      LLVMBool dont_null_terminate) {
  return (LLVMValueRef)LLVMConstStringInContext2(
      (LLVMContextRef)context, (const char *)str, length, dont_null_terminate);
}

void *__llvm_const_string(void *str, unsigned length,
                          LLVMBool dont_null_terminate) {
  return (LLVMValueRef)LLVMConstString((const char *)str, length,
                                       dont_null_terminate);
}

LLVMBool __llvm_is_constant_string(void *c) {
  return LLVMIsConstantString((LLVMValueRef)c);
}

void *__llvm_get_as_string(void *c, size_t *length) {
  return (char *)LLVMGetAsString((LLVMValueRef)c, length);
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

void *__llvm_get_aggregate_element(void *c, unsigned idx) {
  return (LLVMValueRef)LLVMGetAggregateElement((LLVMValueRef)c, idx);
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

void *__llvm_align_of(void *ty) {
  return (LLVMValueRef)LLVMAlignOf((LLVMTypeRef)ty);
}

void *__llvm_size_of(void *ty) {
  return (LLVMValueRef)LLVMSizeOf((LLVMTypeRef)ty);
}

void *__llvm_const_neg(void *constant_val) {
  return (LLVMValueRef)LLVMConstNeg((LLVMValueRef)constant_val);
}

void *__llvm_const_nsw_neg(void *constant_val) {
  return (LLVMValueRef)LLVMConstNSWNeg((LLVMValueRef)constant_val);
}

// void *__llvm_const_nuw_neg(void *constant_val) {
//   return (LLVMValueRef)LLVMConstNUWNeg((LLVMValueRef)constant_val);
// }

void *__llvm_const_not(void *constant_val) {
  return (LLVMValueRef)LLVMConstNot((LLVMValueRef)constant_val);
}

void *__llvm_const_add(void *lhs_constant, void *rhs_constant) {
  return (LLVMValueRef)LLVMConstAdd((LLVMValueRef)lhs_constant,
                                    (LLVMValueRef)rhs_constant);
}

void *__llvm_const_nsw_add(void *lhs_constant, void *rhs_constant) {
  return (LLVMValueRef)LLVMConstNSWAdd((LLVMValueRef)lhs_constant,
                                       (LLVMValueRef)rhs_constant);
}

void *__llvm_const_nuw_add(void *lhs_constant, void *rhs_constant) {
  return (LLVMValueRef)LLVMConstNUWAdd((LLVMValueRef)lhs_constant,
                                       (LLVMValueRef)rhs_constant);
}

void *__llvm_const_sub(void *lhs_constant, void *rhs_constant) {
  return (LLVMValueRef)LLVMConstSub((LLVMValueRef)lhs_constant,
                                    (LLVMValueRef)rhs_constant);
}

void *__llvm_const_nsw_sub(void *lhs_constant, void *rhs_constant) {
  return (LLVMValueRef)LLVMConstNSWSub((LLVMValueRef)lhs_constant,
                                       (LLVMValueRef)rhs_constant);
}

void *__llvm_const_nuw_sub(void *lhs_constant, void *rhs_constant) {
  return (LLVMValueRef)LLVMConstNUWSub((LLVMValueRef)lhs_constant,
                                       (LLVMValueRef)rhs_constant);
}

void *__llvm_const_mul(void *lhs_constant, void *rhs_constant) {
  return (LLVMValueRef)LLVMConstMul((LLVMValueRef)lhs_constant,
                                    (LLVMValueRef)rhs_constant);
}

void *__llvm_const_nsw_mul(void *lhs_constant, void *rhs_constant) {
  return (LLVMValueRef)LLVMConstNSWMul((LLVMValueRef)lhs_constant,
                                       (LLVMValueRef)rhs_constant);
}

void *__llvm_const_nuw_mul(void *lhs_constant, void *rhs_constant) {
  return (LLVMValueRef)LLVMConstNUWMul((LLVMValueRef)lhs_constant,
                                       (LLVMValueRef)rhs_constant);
}

void *__llvm_const_xor(void *lhs_constant, void *rhs_constant) {
  return (LLVMValueRef)LLVMConstXor((LLVMValueRef)lhs_constant,
                                    (LLVMValueRef)rhs_constant);
}

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

void *__llvm_const_trunc(void *constant_val, void *to_type) {
  return (LLVMValueRef)LLVMConstTrunc((LLVMValueRef)constant_val,
                                      (LLVMTypeRef)to_type);
}

void *__llvm_const_ptr_to_int(void *constant_val, void *to_type) {
  return (LLVMValueRef)LLVMConstPtrToInt((LLVMValueRef)constant_val,
                                         (LLVMTypeRef)to_type);
}

void *__llvm_const_int_to_ptr(void *constant_val, void *to_type) {
  return (LLVMValueRef)LLVMConstIntToPtr((LLVMValueRef)constant_val,
                                         (LLVMTypeRef)to_type);
}

void *__llvm_const_bit_cast(void *constant_val, void *to_type) {
  return (LLVMValueRef)LLVMConstBitCast((LLVMValueRef)constant_val,
                                        (LLVMTypeRef)to_type);
}

void *__llvm_const_addr_space_cast(void *constant_val, void *to_type) {
  return (LLVMValueRef)LLVMConstAddrSpaceCast((LLVMValueRef)constant_val,
                                              (LLVMTypeRef)to_type);
}

void *__llvm_const_trunc_or_bit_cast(void *constant_val, void *to_type) {
  return (LLVMValueRef)LLVMConstTruncOrBitCast((LLVMValueRef)constant_val,
                                               (LLVMTypeRef)to_type);
}

void *__llvm_const_pointer_cast(void *constant_val, void *to_type) {
  return (LLVMValueRef)LLVMConstPointerCast((LLVMValueRef)constant_val,
                                            (LLVMTypeRef)to_type);
}

void *__llvm_const_extract_element(void *vector_constant,
                                   void *index_constant) {
  return (LLVMValueRef)LLVMConstExtractElement((LLVMValueRef)vector_constant,
                                               (LLVMValueRef)index_constant);
}

void *__llvm_const_insert_element(void *vector_constant,
                                  void *element_value_constant,
                                  void *index_constant) {
  return (LLVMValueRef)LLVMConstInsertElement(
      (LLVMValueRef)vector_constant, (LLVMValueRef)element_value_constant,
      (LLVMValueRef)index_constant);
}

void *__llvm_const_shuffle_vector(void *vector_a_constant,
                                  void *vector_b_constant,
                                  void *mask_constant) {
  return (LLVMValueRef)LLVMConstShuffleVector((LLVMValueRef)vector_a_constant,
                                              (LLVMValueRef)vector_b_constant,
                                              (LLVMValueRef)mask_constant);
}

void *__llvm_block_address(void *f, void *bb) {
  return (LLVMValueRef)LLVMBlockAddress((LLVMValueRef)f, (LLVMBasicBlockRef)bb);
}

void *__llvm_get_block_address_function(void *block_addr) {
  return (LLVMValueRef)LLVMGetBlockAddressFunction((LLVMValueRef)block_addr);
}

void *__llvm_get_block_address_basic_block(void *block_addr) {
  return (LLVMBasicBlockRef)LLVMGetBlockAddressBasicBlock(
      (LLVMValueRef)block_addr);
}

void *__llvm_const_inline_asm(void *ty, void *asm_string, void *constraints,
                              LLVMBool has_side_effects,
                              LLVMBool is_align_stack) {
  return (LLVMValueRef)LLVMConstInlineAsm(
      (LLVMTypeRef)ty, (const char *)asm_string, (const char *)constraints,
      has_side_effects, is_align_stack);
}

void *__llvm_get_global_parent(void *global) {
  return (LLVMModuleRef)LLVMGetGlobalParent((LLVMValueRef)global);
}

LLVMBool __llvm_is_declaration(void *global) {
  return LLVMIsDeclaration((LLVMValueRef)global);
}

LLVMLinkage __llvm_get_linkage(void *global) {
  return LLVMGetLinkage((LLVMValueRef)global);
}

void __llvm_set_linkage(void *global, LLVMLinkage linkage) {
  LLVMSetLinkage((LLVMValueRef)global, linkage);
}

void *__llvm_get_section(void *global) {
  return (char *)LLVMGetSection((LLVMValueRef)global);
}

void __llvm_set_section(void *global, void *section) {
  LLVMSetSection((LLVMValueRef)global, (const char *)section);
}

LLVMVisibility __llvm_get_visibility(void *global) {
  return LLVMGetVisibility((LLVMValueRef)global);
}

void __llvm_set_visibility(void *global, LLVMVisibility viz) {
  LLVMSetVisibility((LLVMValueRef)global, viz);
}

LLVMDLLStorageClass __llvm_get_dll_storage_class(void *global) {
  return LLVMGetDLLStorageClass((LLVMValueRef)global);
}

// void __llvm_set_dll_storage_class(void *global, LLVMDLLStorageClass class) {
//   LLVMSetDLLStorageClass((LLVMValueRef)global, class);
// }

LLVMUnnamedAddr __llvm_get_unnamed_address(void *global) {
  return LLVMGetUnnamedAddress((LLVMValueRef)global);
}

void __llvm_set_unnamed_address(void *global, LLVMUnnamedAddr unnamed_addr) {
  LLVMSetUnnamedAddress((LLVMValueRef)global, unnamed_addr);
}

void *__llvm_global_get_value_type(void *global) {
  return (LLVMTypeRef)LLVMGlobalGetValueType((LLVMValueRef)global);
}

LLVMBool __llvm_has_unnamed_addr(void *global) {
  return LLVMHasUnnamedAddr((LLVMValueRef)global);
}

void __llvm_set_unnamed_addr(void *global, LLVMBool has_unnamed_addr) {
  LLVMSetUnnamedAddr((LLVMValueRef)global, has_unnamed_addr);
}

unsigned __llvm_get_alignment(void *v) {
  return LLVMGetAlignment((LLVMValueRef)v);
}

void __llvm_set_alignment(void *v, unsigned bytes) {
  LLVMSetAlignment((LLVMValueRef)v, bytes);
}

void __llvm_global_set_metadata(void *global, unsigned kind, void *md) {
  LLVMGlobalSetMetadata((LLVMValueRef)global, kind, (LLVMMetadataRef)md);
}

void __llvm_global_erase_metadata(void *global, unsigned kind) {
  LLVMGlobalEraseMetadata((LLVMValueRef)global, kind);
}

void __llvm_global_clear_metadata(void *global) {
  LLVMGlobalClearMetadata((LLVMValueRef)global);
}

void *__llvm_global_copy_all_metadata(void *value, size_t *num_entries) {
  return (LLVMValueMetadataEntry *)LLVMGlobalCopyAllMetadata(
      (LLVMValueRef)value, num_entries);
}

void __llvm_dispose_value_metadata_entries(void *entries) {
  LLVMDisposeValueMetadataEntries((LLVMValueMetadataEntry *)entries);
}

unsigned __llvm_value_metadata_entries_get_kind(void *entries, unsigned index) {
  return LLVMValueMetadataEntriesGetKind((LLVMValueMetadataEntry *)entries,
                                         index);
}

void *__llvm_value_metadata_entries_get_metadata(void *entries,
                                                 unsigned index) {
  return (LLVMMetadataRef)LLVMValueMetadataEntriesGetMetadata(
      (LLVMValueMetadataEntry *)entries, index);
}

void *__llvm_add_global(void *m, void *ty, void *name) {
  return (LLVMValueRef)LLVMAddGlobal((LLVMModuleRef)m, (LLVMTypeRef)ty,
                                     (const char *)name);
}

void *__llvm_add_global_in_address_space(void *m, void *ty, void *name,
                                         unsigned address_space) {
  return (LLVMValueRef)LLVMAddGlobalInAddressSpace(
      (LLVMModuleRef)m, (LLVMTypeRef)ty, (const char *)name, address_space);
}

void *__llvm_get_named_global(void *m, void *name) {
  return (LLVMValueRef)LLVMGetNamedGlobal((LLVMModuleRef)m, (const char *)name);
}

void *__llvm_get_first_global(void *m) {
  return (LLVMValueRef)LLVMGetFirstGlobal((LLVMModuleRef)m);
}

void *__llvm_get_last_global(void *m) {
  return (LLVMValueRef)LLVMGetLastGlobal((LLVMModuleRef)m);
}

void *__llvm_get_next_global(void *global_var) {
  return (LLVMValueRef)LLVMGetNextGlobal((LLVMValueRef)global_var);
}

void *__llvm_get_previous_global(void *global_var) {
  return (LLVMValueRef)LLVMGetPreviousGlobal((LLVMValueRef)global_var);
}

void __llvm_delete_global(void *global_var) {
  LLVMDeleteGlobal((LLVMValueRef)global_var);
}

void *__llvm_get_initializer(void *global_var) {
  return (LLVMValueRef)LLVMGetInitializer((LLVMValueRef)global_var);
}

void __llvm_set_initializer(void *global_var, void *constant_val) {
  LLVMSetInitializer((LLVMValueRef)global_var, (LLVMValueRef)constant_val);
}

LLVMBool __llvm_is_thread_local(void *global_var) {
  return LLVMIsThreadLocal((LLVMValueRef)global_var);
}

void __llvm_set_thread_local(void *global_var, LLVMBool is_thread_local) {
  LLVMSetThreadLocal((LLVMValueRef)global_var, is_thread_local);
}

LLVMBool __llvm_is_global_constant(void *global_var) {
  return LLVMIsGlobalConstant((LLVMValueRef)global_var);
}

void __llvm_set_global_constant(void *global_var, LLVMBool is_constant) {
  LLVMSetGlobalConstant((LLVMValueRef)global_var, is_constant);
}

LLVMThreadLocalMode __llvm_get_thread_local_mode(void *global_var) {
  return LLVMGetThreadLocalMode((LLVMValueRef)global_var);
}

void __llvm_set_thread_local_mode(void *global_var, LLVMThreadLocalMode mode) {
  LLVMSetThreadLocalMode((LLVMValueRef)global_var, mode);
}

LLVMBool __llvm_is_externally_initialized(void *global_var) {
  return LLVMIsExternallyInitialized((LLVMValueRef)global_var);
}

void __llvm_set_externally_initialized(void *global_var, LLVMBool is_ext_init) {
  LLVMSetExternallyInitialized((LLVMValueRef)global_var, is_ext_init);
}

void *__llvm_add_alias2(void *m, void *value_ty, unsigned addr_space,
                        void *aliasee, void *name) {
  return (LLVMValueRef)LLVMAddAlias2((LLVMModuleRef)m, (LLVMTypeRef)value_ty,
                                     addr_space, (LLVMValueRef)aliasee,
                                     (const char *)name);
}

void *__llvm_get_named_global_alias(void *m, void *name, size_t name_len) {
  return (LLVMValueRef)LLVMGetNamedGlobalAlias((LLVMModuleRef)m,
                                               (const char *)name, name_len);
}

void *__llvm_get_first_global_alias(void *m) {
  return (LLVMValueRef)LLVMGetFirstGlobalAlias((LLVMModuleRef)m);
}

void *__llvm_get_last_global_alias(void *m) {
  return (LLVMValueRef)LLVMGetLastGlobalAlias((LLVMModuleRef)m);
}

void *__llvm_get_next_global_alias(void *ga) {
  return (LLVMValueRef)LLVMGetNextGlobalAlias((LLVMValueRef)ga);
}

void *__llvm_get_previous_global_alias(void *ga) {
  return (LLVMValueRef)LLVMGetPreviousGlobalAlias((LLVMValueRef)ga);
}

void *__llvm_alias_get_aliasee(void *alias) {
  return (LLVMValueRef)LLVMAliasGetAliasee((LLVMValueRef)alias);
}

void __llvm_alias_set_aliasee(void *alias, void *aliasee) {
  LLVMAliasSetAliasee((LLVMValueRef)alias, (LLVMValueRef)aliasee);
}

void __llvm_delete_function(void *fn) { LLVMDeleteFunction((LLVMValueRef)fn); }

LLVMBool __llvm_has_personality_fn(void *fn) {
  return LLVMHasPersonalityFn((LLVMValueRef)fn);
}

void *__llvm_get_personality_fn(void *fn) {
  return (LLVMValueRef)LLVMGetPersonalityFn((LLVMValueRef)fn);
}

void __llvm_set_personality_fn(void *fn, void *personality_fn) {
  LLVMSetPersonalityFn((LLVMValueRef)fn, (LLVMValueRef)personality_fn);
}

unsigned __llvm_lookup_intrinsic_id(void *name, size_t name_len) {
  return LLVMLookupIntrinsicID((const char *)name, name_len);
}

unsigned __llvm_get_intrinsic_id(void *fn) {
  return LLVMGetIntrinsicID((LLVMValueRef)fn);
}

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

void *__llvm_intrinsic_get_name(unsigned id, size_t *name_length) {
  return (char *)LLVMIntrinsicGetName(id, name_length);
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

LLVMBool __llvm_intrinsic_is_overloaded(unsigned id) {
  return LLVMIntrinsicIsOverloaded(id);
}

unsigned __llvm_get_function_call_conv(void *fn) {
  return LLVMGetFunctionCallConv((LLVMValueRef)fn);
}

void __llvm_set_function_call_conv(void *fn, unsigned cc) {
  LLVMSetFunctionCallConv((LLVMValueRef)fn, cc);
}

void *__llvm_get_gc(void *fn) { return (char *)LLVMGetGC((LLVMValueRef)fn); }

void __llvm_set_gc(void *fn, void *name) {
  LLVMSetGC((LLVMValueRef)fn, (const char *)name);
}

void *__llvm_get_prefix_data(void *fn) {
  return (LLVMValueRef)LLVMGetPrefixData((LLVMValueRef)fn);
}

LLVMBool __llvm_has_prefix_data(void *fn) {
  return LLVMHasPrefixData((LLVMValueRef)fn);
}

void __llvm_set_prefix_data(void *fn, void *prefix_data) {
  LLVMSetPrefixData((LLVMValueRef)fn, (LLVMValueRef)prefix_data);
}

void *__llvm_get_prologue_data(void *fn) {
  return (LLVMValueRef)LLVMGetPrologueData((LLVMValueRef)fn);
}

LLVMBool __llvm_has_prologue_data(void *fn) {
  return LLVMHasPrologueData((LLVMValueRef)fn);
}

void __llvm_set_prologue_data(void *fn, void *prologue_data) {
  LLVMSetPrologueData((LLVMValueRef)fn, (LLVMValueRef)prologue_data);
}

void __llvm_add_attribute_at_index(void *f, LLVMAttributeIndex idx, void *a) {
  LLVMAddAttributeAtIndex((LLVMValueRef)f, idx, (LLVMAttributeRef)a);
}

unsigned __llvm_get_attribute_count_at_index(void *f, LLVMAttributeIndex idx) {
  return LLVMGetAttributeCountAtIndex((LLVMValueRef)f, idx);
}

void __llvm_get_attributes_at_index(void *f, LLVMAttributeIndex idx,
                                    void *attrs) {
  LLVMGetAttributesAtIndex((LLVMValueRef)f, idx, (LLVMAttributeRef *)attrs);
}

void *__llvm_get_enum_attribute_at_index(void *f, LLVMAttributeIndex idx,
                                         unsigned kind_id) {
  return (LLVMAttributeRef)LLVMGetEnumAttributeAtIndex((LLVMValueRef)f, idx,
                                                       kind_id);
}

void *__llvm_get_string_attribute_at_index(void *f, LLVMAttributeIndex idx,
                                           void *k, unsigned k_len) {
  return (LLVMAttributeRef)LLVMGetStringAttributeAtIndex(
      (LLVMValueRef)f, idx, (const char *)k, k_len);
}

void __llvm_remove_enum_attribute_at_index(void *f, LLVMAttributeIndex idx,
                                           unsigned kind_id) {
  LLVMRemoveEnumAttributeAtIndex((LLVMValueRef)f, idx, kind_id);
}

void __llvm_remove_string_attribute_at_index(void *f, LLVMAttributeIndex idx,
                                             void *k, unsigned k_len) {
  LLVMRemoveStringAttributeAtIndex((LLVMValueRef)f, idx, (const char *)k,
                                   k_len);
}

void __llvm_add_target_dependent_function_attr(void *fn, void *a, void *v) {
  LLVMAddTargetDependentFunctionAttr((LLVMValueRef)fn, (const char *)a,
                                     (const char *)v);
}

unsigned __llvm_count_params(void *fn) {
  return LLVMCountParams((LLVMValueRef)fn);
}

void __llvm_get_params(void *fn, void *params) {
  LLVMGetParams((LLVMValueRef)fn, (LLVMValueRef *)params);
}

void *__llvm_get_param(void *fn, unsigned index) {
  return (LLVMValueRef)LLVMGetParam((LLVMValueRef)fn, index);
}

void *__llvm_get_param_parent(void *inst) {
  return (LLVMValueRef)LLVMGetParamParent((LLVMValueRef)inst);
}

void *__llvm_get_first_param(void *fn) {
  return (LLVMValueRef)LLVMGetFirstParam((LLVMValueRef)fn);
}

void *__llvm_get_last_param(void *fn) {
  return (LLVMValueRef)LLVMGetLastParam((LLVMValueRef)fn);
}

void *__llvm_get_next_param(void *arg) {
  return (LLVMValueRef)LLVMGetNextParam((LLVMValueRef)arg);
}

void *__llvm_get_previous_param(void *arg) {
  return (LLVMValueRef)LLVMGetPreviousParam((LLVMValueRef)arg);
}

void __llvm_set_param_alignment(void *arg, unsigned align) {
  LLVMSetParamAlignment((LLVMValueRef)arg, align);
}

void *__llvm_add_global_ifunc(void *m, void *name, size_t name_len, void *ty,
                              unsigned addr_space, void *resolver) {
  return (LLVMValueRef)LLVMAddGlobalIFunc((LLVMModuleRef)m, (const char *)name,
                                          name_len, (LLVMTypeRef)ty, addr_space,
                                          (LLVMValueRef)resolver);
}

void *__llvm_get_named_global_ifunc(void *m, void *name, size_t name_len) {
  return (LLVMValueRef)LLVMGetNamedGlobalIFunc((LLVMModuleRef)m,
                                               (const char *)name, name_len);
}

void *__llvm_get_first_global_ifunc(void *m) {
  return (LLVMValueRef)LLVMGetFirstGlobalIFunc((LLVMModuleRef)m);
}

void *__llvm_get_last_global_ifunc(void *m) {
  return (LLVMValueRef)LLVMGetLastGlobalIFunc((LLVMModuleRef)m);
}

void *__llvm_get_next_global_ifunc(void *ifunc) {
  return (LLVMValueRef)LLVMGetNextGlobalIFunc((LLVMValueRef)ifunc);
}

void *__llvm_get_previous_global_ifunc(void *ifunc) {
  return (LLVMValueRef)LLVMGetPreviousGlobalIFunc((LLVMValueRef)ifunc);
}

void *__llvm_get_global_ifunc_resolver(void *ifunc) {
  return (LLVMValueRef)LLVMGetGlobalIFuncResolver((LLVMValueRef)ifunc);
}

void __llvm_set_global_ifunc_resolver(void *ifunc, void *resolver) {
  LLVMSetGlobalIFuncResolver((LLVMValueRef)ifunc, (LLVMValueRef)resolver);
}

void __llvm_erase_global_ifunc(void *ifunc) {
  LLVMEraseGlobalIFunc((LLVMValueRef)ifunc);
}

void __llvm_remove_global_ifunc(void *ifunc) {
  LLVMRemoveGlobalIFunc((LLVMValueRef)ifunc);
}

void *__llvm_md_string_in_context2(void *context, void *str, size_t s_len) {
  return (LLVMMetadataRef)LLVMMDStringInContext2((LLVMContextRef)context,
                                                 (const char *)str, s_len);
}

void *__llvm_md_node_in_context2(void *context, ArrayLLVMMetadataRef *mds) {
  LLVMMetadataRef *llvm_mds = (LLVMMetadataRef *)mds->$0->data;
  unsigned count = mds->$1;
  return (LLVMMetadataRef)LLVMMDNodeInContext2((LLVMContextRef)context,
                                               llvm_mds, count);
}

void *__llvm_metadata_as_value(void *context, void *md) {
  return (LLVMValueRef)LLVMMetadataAsValue((LLVMContextRef)context,
                                           (LLVMMetadataRef)md);
}

void *__llvm_value_as_metadata(void *val) {
  return (LLVMMetadataRef)LLVMValueAsMetadata((LLVMValueRef)val);
}

void *__llvm_get_md_string(void *v, unsigned *length) {
  return (char *)LLVMGetMDString((LLVMValueRef)v, length);
}

unsigned __llvm_get_md_node_num_operands(void *v) {
  return LLVMGetMDNodeNumOperands((LLVMValueRef)v);
}

void __llvm_get_md_node_operands(void *v, void *dest) {
  LLVMGetMDNodeOperands((LLVMValueRef)v, (LLVMValueRef *)dest);
}

void __llvm_replace_md_node_operand_with(void *v, unsigned index,
                                         void *replacement) {
  LLVMReplaceMDNodeOperandWith((LLVMValueRef)v, index,
                               (LLVMMetadataRef)replacement);
}

void *__llvm_md_string_in_context(void *context, void *str, unsigned s_len) {
  return (LLVMValueRef)LLVMMDStringInContext((LLVMContextRef)context,
                                             (char *)str, s_len);
}

void *__llvm_md_string(void *str, unsigned s_len) {
  return (LLVMValueRef)LLVMMDString((const char *)str, s_len);
}

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

void __llvm_dispose_operand_bundle(void *bundle) {
  LLVMDisposeOperandBundle((LLVMOperandBundleRef)bundle);
}

void *__llvm_get_operand_bundle_tag(void *bundle, size_t *len) {
  return (char *)LLVMGetOperandBundleTag((LLVMOperandBundleRef)bundle, len);
}

unsigned __llvm_get_num_operand_bundle_args(void *bundle) {
  return LLVMGetNumOperandBundleArgs((LLVMOperandBundleRef)bundle);
}

void *__llvm_get_operand_bundle_arg_at_index(void *bundle, unsigned index) {
  return (LLVMValueRef)LLVMGetOperandBundleArgAtIndex(
      (LLVMOperandBundleRef)bundle, index);
}

void *__llvm_basic_block_as_value(void *bb) {
  return (LLVMValueRef)LLVMBasicBlockAsValue((LLVMBasicBlockRef)bb);
}

LLVMBool __llvm_value_is_basic_block(void *val) {
  return LLVMValueIsBasicBlock((LLVMValueRef)val);
}

void *__llvm_value_as_basic_block(void *val) {
  return (LLVMBasicBlockRef)LLVMValueAsBasicBlock((LLVMValueRef)val);
}

void *__llvm_get_basic_block_name(void *bb) {
  return (char *)LLVMGetBasicBlockName((LLVMBasicBlockRef)bb);
}

void *__llvm_get_basic_block_parent(void *bb) {
  return (LLVMValueRef)LLVMGetBasicBlockParent((LLVMBasicBlockRef)bb);
}

void *__llvm_get_basic_block_terminator(void *bb) {
  return (LLVMValueRef)LLVMGetBasicBlockTerminator((LLVMBasicBlockRef)bb);
}

unsigned __llvm_count_basic_blocks(void *fn) {
  return LLVMCountBasicBlocks((LLVMValueRef)fn);
}

void __llvm_get_basic_blocks(void *fn, void *basic_blocks) {
  LLVMGetBasicBlocks((LLVMValueRef)fn, (LLVMBasicBlockRef *)basic_blocks);
}

void *__llvm_get_first_basic_block(void *fn) {
  return (LLVMBasicBlockRef)LLVMGetFirstBasicBlock((LLVMValueRef)fn);
}

void *__llvm_get_last_basic_block(void *fn) {
  return (LLVMBasicBlockRef)LLVMGetLastBasicBlock((LLVMValueRef)fn);
}

void *__llvm_get_next_basic_block(void *bb) {
  return (LLVMBasicBlockRef)LLVMGetNextBasicBlock((LLVMBasicBlockRef)bb);
}

void *__llvm_get_previous_basic_block(void *bb) {
  return (LLVMBasicBlockRef)LLVMGetPreviousBasicBlock((LLVMBasicBlockRef)bb);
}

void *__llvm_get_entry_basic_block(void *fn) {
  return (LLVMBasicBlockRef)LLVMGetEntryBasicBlock((LLVMValueRef)fn);
}

void __llvm_insert_existing_basic_block_after_insert_block(void *builder,
                                                           void *bb) {
  LLVMInsertExistingBasicBlockAfterInsertBlock((LLVMBuilderRef)builder,
                                               (LLVMBasicBlockRef)bb);
}

void __llvm_append_existing_basic_block(void *fn, void *bb) {
  LLVMAppendExistingBasicBlock((LLVMValueRef)fn, (LLVMBasicBlockRef)bb);
}

void *__llvm_create_basic_block_in_context(void *context, void *name) {
  return (LLVMBasicBlockRef)LLVMCreateBasicBlockInContext(
      (LLVMContextRef)context, (const char *)name);
}

void *__llvm_append_basic_block_in_context(void *context, void *fn,
                                           void *name) {
  return (LLVMBasicBlockRef)LLVMAppendBasicBlockInContext(
      (LLVMContextRef)context, (LLVMValueRef)fn, (const char *)name);
}

void *__llvm_append_basic_block(void *fn, void *name) {
  return (LLVMBasicBlockRef)LLVMAppendBasicBlock((LLVMValueRef)fn,
                                                 (const char *)name);
}

void *__llvm_insert_basic_block_in_context(void *context, void *bb,
                                           void *name) {
  return (LLVMBasicBlockRef)LLVMInsertBasicBlockInContext(
      (LLVMContextRef)context, (LLVMBasicBlockRef)bb, (const char *)name);
}

void *__llvm_insert_basic_block(void *insert_before_bb, void *name) {
  return (LLVMBasicBlockRef)LLVMInsertBasicBlock(
      (LLVMBasicBlockRef)insert_before_bb, (const char *)name);
}

void __llvm_delete_basic_block(void *bb) {
  LLVMDeleteBasicBlock((LLVMBasicBlockRef)bb);
}

void __llvm_remove_basic_block_from_parent(void *bb) {
  LLVMRemoveBasicBlockFromParent((LLVMBasicBlockRef)bb);
}

void __llvm_move_basic_block_before(void *bb, void *move_pos) {
  LLVMMoveBasicBlockBefore((LLVMBasicBlockRef)bb, (LLVMBasicBlockRef)move_pos);
}

void __llvm_move_basic_block_after(void *bb, void *move_pos) {
  LLVMMoveBasicBlockAfter((LLVMBasicBlockRef)bb, (LLVMBasicBlockRef)move_pos);
}

void *__llvm_get_first_instruction(void *bb) {
  return (LLVMValueRef)LLVMGetFirstInstruction((LLVMBasicBlockRef)bb);
}

void *__llvm_get_last_instruction(void *bb) {
  return (LLVMValueRef)LLVMGetLastInstruction((LLVMBasicBlockRef)bb);
}

int __llvm_has_metadata(void *val) {
  return LLVMHasMetadata((LLVMValueRef)val);
}

void *__llvm_get_metadata(void *val, unsigned kind_id) {
  return (LLVMValueRef)LLVMGetMetadata((LLVMValueRef)val, kind_id);
}

void __llvm_set_metadata(void *val, unsigned kind_id, void *node) {
  LLVMSetMetadata((LLVMValueRef)val, kind_id, (LLVMValueRef)node);
}

void *
__llvm_instruction_get_all_metadata_other_than_debug_loc(void *instr,
                                                         size_t *num_entries) {
  return (LLVMValueMetadataEntry *)
      LLVMInstructionGetAllMetadataOtherThanDebugLoc((LLVMValueRef)instr,
                                                     num_entries);
}

void *__llvm_get_instruction_parent(void *inst) {
  return (LLVMBasicBlockRef)LLVMGetInstructionParent((LLVMValueRef)inst);
}

void *__llvm_get_next_instruction(void *inst) {
  return (LLVMValueRef)LLVMGetNextInstruction((LLVMValueRef)inst);
}

void *__llvm_get_previous_instruction(void *inst) {
  return (LLVMValueRef)LLVMGetPreviousInstruction((LLVMValueRef)inst);
}

void __llvm_instruction_remove_from_parent(void *inst) {
  LLVMInstructionRemoveFromParent((LLVMValueRef)inst);
}

void __llvm_instruction_erase_from_parent(void *inst) {
  LLVMInstructionEraseFromParent((LLVMValueRef)inst);
}

void __llvm_delete_instruction(void *inst) {
  LLVMDeleteInstruction((LLVMValueRef)inst);
}

int __llvm_get_instruction_opcode(void *inst) {
  LLVMOpcode opcode = LLVMGetInstructionOpcode((LLVMValueRef)inst);
  return llvm_opcode_to_int(opcode);
}

LLVMIntPredicate __llvm_get_icmp_predicate(void *inst) {
  return LLVMGetICmpPredicate((LLVMValueRef)inst);
}

LLVMRealPredicate __llvm_get_fcmp_predicate(void *inst) {
  return LLVMGetFCmpPredicate((LLVMValueRef)inst);
}

void *__llvm_instruction_clone(void *inst) {
  return (LLVMValueRef)LLVMInstructionClone((LLVMValueRef)inst);
}

void *__llvm_isa_terminator_inst(void *inst) {
  return (LLVMValueRef)LLVMIsATerminatorInst((LLVMValueRef)inst);
}

unsigned __llvm_get_num_arg_operands(void *instr) {
  return LLVMGetNumArgOperands((LLVMValueRef)instr);
}

void __llvm_set_instruction_call_conv(void *instr, unsigned cc) {
  LLVMSetInstructionCallConv((LLVMValueRef)instr, cc);
}

unsigned __llvm_get_instruction_call_conv(void *instr) {
  return LLVMGetInstructionCallConv((LLVMValueRef)instr);
}

void __llvm_set_instr_param_alignment(void *instr, LLVMAttributeIndex idx,
                                      unsigned align) {
  LLVMSetInstrParamAlignment((LLVMValueRef)instr, idx, align);
}

void __llvm_add_call_site_attribute(void *c, LLVMAttributeIndex idx, void *a) {
  LLVMAddCallSiteAttribute((LLVMValueRef)c, idx, (LLVMAttributeRef)a);
}

unsigned __llvm_get_call_site_attribute_count(void *c, LLVMAttributeIndex idx) {
  return LLVMGetCallSiteAttributeCount((LLVMValueRef)c, idx);
}

void __llvm_get_call_site_attributes(void *c, LLVMAttributeIndex idx,
                                     void *attrs) {
  LLVMGetCallSiteAttributes((LLVMValueRef)c, idx, (LLVMAttributeRef *)attrs);
}

void *__llvm_get_call_site_enum_attribute(void *c, LLVMAttributeIndex idx,
                                          unsigned kind_id) {
  return (LLVMAttributeRef)LLVMGetCallSiteEnumAttribute((LLVMValueRef)c, idx,
                                                        kind_id);
}

void *__llvm_get_call_site_string_attribute(void *c, LLVMAttributeIndex idx,
                                            void *k, unsigned k_len) {
  return (LLVMAttributeRef)LLVMGetCallSiteStringAttribute(
      (LLVMValueRef)c, idx, (const char *)k, k_len);
}

void __llvm_remove_call_site_enum_attribute(void *c, LLVMAttributeIndex idx,
                                            unsigned kind_id) {
  LLVMRemoveCallSiteEnumAttribute((LLVMValueRef)c, idx, kind_id);
}

void __llvm_remove_call_site_string_attribute(void *c, LLVMAttributeIndex idx,
                                              void *k, unsigned k_len) {
  LLVMRemoveCallSiteStringAttribute((LLVMValueRef)c, idx, (const char *)k,
                                    k_len);
}

void *__llvm_get_called_function_type(void *c) {
  return (LLVMTypeRef)LLVMGetCalledFunctionType((LLVMValueRef)c);
}

void *__llvm_get_called_value(void *instr) {
  return (LLVMValueRef)LLVMGetCalledValue((LLVMValueRef)instr);
}

unsigned __llvm_get_num_operand_bundles(void *c) {
  return LLVMGetNumOperandBundles((LLVMValueRef)c);
}

void *__llvm_get_operand_bundle_at_index(void *c, unsigned index) {
  return (LLVMOperandBundleRef)LLVMGetOperandBundleAtIndex((LLVMValueRef)c,
                                                           index);
}

LLVMBool __llvm_is_tail_call(void *call_inst) {
  return LLVMIsTailCall((LLVMValueRef)call_inst);
}

void __llvm_set_tail_call(void *call_inst, LLVMBool is_tail_call) {
  LLVMSetTailCall((LLVMValueRef)call_inst, is_tail_call);
}

LLVMTailCallKind __llvm_get_tail_call_kind(void *call_inst) {
  return LLVMGetTailCallKind((LLVMValueRef)call_inst);
}

void __llvm_set_tail_call_kind(void *call_inst, LLVMTailCallKind kind) {
  LLVMSetTailCallKind((LLVMValueRef)call_inst, kind);
}

void *__llvm_get_normal_dest(void *invoke_inst) {
  return (LLVMBasicBlockRef)LLVMGetNormalDest((LLVMValueRef)invoke_inst);
}

void *__llvm_get_unwind_dest(void *invoke_inst) {
  return (LLVMBasicBlockRef)LLVMGetUnwindDest((LLVMValueRef)invoke_inst);
}

void __llvm_set_normal_dest(void *invoke_inst, void *b) {
  LLVMSetNormalDest((LLVMValueRef)invoke_inst, (LLVMBasicBlockRef)b);
}

void __llvm_set_unwind_dest(void *invoke_inst, void *b) {
  LLVMSetUnwindDest((LLVMValueRef)invoke_inst, (LLVMBasicBlockRef)b);
}

void *__llvm_get_call_br_default_dest(void *call_br) {
  return (LLVMBasicBlockRef)LLVMGetCallBrDefaultDest((LLVMValueRef)call_br);
}

unsigned __llvm_get_call_br_num_indirect_dests(void *call_br) {
  return LLVMGetCallBrNumIndirectDests((LLVMValueRef)call_br);
}

void *__llvm_get_call_br_indirect_dest(void *call_br, unsigned idx) {
  return (LLVMBasicBlockRef)LLVMGetCallBrIndirectDest((LLVMValueRef)call_br,
                                                      idx);
}

unsigned __llvm_get_num_successors(void *term) {
  return LLVMGetNumSuccessors((LLVMValueRef)term);
}

void *__llvm_get_successor(void *term, unsigned i) {
  return (LLVMBasicBlockRef)LLVMGetSuccessor((LLVMValueRef)term, i);
}

void __llvm_set_successor(void *term, unsigned i, void *block) {
  LLVMSetSuccessor((LLVMValueRef)term, i, (LLVMBasicBlockRef)block);
}

LLVMBool __llvm_is_conditional(void *branch) {
  return LLVMIsConditional((LLVMValueRef)branch);
}

void *__llvm_get_condition(void *branch) {
  return (LLVMValueRef)LLVMGetCondition((LLVMValueRef)branch);
}

void __llvm_set_condition(void *branch, void *cond) {
  LLVMSetCondition((LLVMValueRef)branch, (LLVMValueRef)cond);
}

void *__llvm_get_switch_default_dest(void *switch_instr) {
  return (LLVMBasicBlockRef)LLVMGetSwitchDefaultDest(
      (LLVMValueRef)switch_instr);
}

void *__llvm_get_allocated_type(void *alloca) {
  return (LLVMTypeRef)LLVMGetAllocatedType((LLVMValueRef)alloca);
}

LLVMBool __llvm_is_in_bounds(void *gep) {
  return LLVMIsInBounds((LLVMValueRef)gep);
}

void __llvm_set_is_in_bounds(void *gep, LLVMBool in_bounds) {
  LLVMSetIsInBounds((LLVMValueRef)gep, in_bounds);
}

void *__llvm_get_gep_source_element_type(void *gep) {
  return (LLVMTypeRef)LLVMGetGEPSourceElementType((LLVMValueRef)gep);
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

unsigned __llvm_count_incoming(void *phi_node) {
  return LLVMCountIncoming((LLVMValueRef)phi_node);
}

void *__llvm_get_incoming_value(void *phi_node, unsigned index) {
  return (LLVMValueRef)LLVMGetIncomingValue((LLVMValueRef)phi_node, index);
}

void *__llvm_get_incoming_block(void *phi_node, unsigned index) {
  return (LLVMBasicBlockRef)LLVMGetIncomingBlock((LLVMValueRef)phi_node, index);
}

unsigned __llvm_get_num_indices(void *inst) {
  return LLVMGetNumIndices((LLVMValueRef)inst);
}

const unsigned *__llvm_get_indices(void *inst) {
  return LLVMGetIndices((LLVMValueRef)inst);
}

void *__llvm_create_builder_in_context(void *context) {
  return (LLVMBuilderRef)LLVMCreateBuilderInContext((LLVMContextRef)context);
}

void *__llvm_create_builder() { return (LLVMBuilderRef)LLVMCreateBuilder(); }

void __llvm_position_builder(void *builder, void *block, void *instr) {
  LLVMPositionBuilder((LLVMBuilderRef)builder, (LLVMBasicBlockRef)block,
                      (LLVMValueRef)instr);
}

void __llvm_position_builder_before_dbg_records(void *builder, void *block,
                                                void *inst) {
  LLVMPositionBuilderBeforeDbgRecords(
      (LLVMBuilderRef)builder, (LLVMBasicBlockRef)block, (LLVMValueRef)inst);
}

void __llvm_position_builder_before(void *builder, void *instr) {
  LLVMPositionBuilderBefore((LLVMBuilderRef)builder, (LLVMValueRef)instr);
}

void __llvm_position_builder_before_instr_and_dbg_records(void *builder,
                                                          void *instr) {
  LLVMPositionBuilderBeforeInstrAndDbgRecords((LLVMBuilderRef)builder,
                                              (LLVMValueRef)instr);
}

void __llvm_position_builder_at_end(void *builder, void *block) {
  LLVMPositionBuilderAtEnd((LLVMBuilderRef)builder, (LLVMBasicBlockRef)block);
}

void *__llvm_get_insert_block(void *builder) {
  return (LLVMBasicBlockRef)LLVMGetInsertBlock((LLVMBuilderRef)builder);
}

void __llvm_clear_insertion_position(void *builder) {
  LLVMClearInsertionPosition((LLVMBuilderRef)builder);
}

void __llvm_insert_into_builder(void *builder, void *instr) {
  LLVMInsertIntoBuilder((LLVMBuilderRef)builder, (LLVMValueRef)instr);
}

void __llvm_insert_into_builder_with_name(void *builder, void *instr,
                                          void *name) {
  LLVMInsertIntoBuilderWithName((LLVMBuilderRef)builder, (LLVMValueRef)instr,
                                (const char *)name);
}

void __llvm_dispose_builder(void *builder) {
  LLVMDisposeBuilder((LLVMBuilderRef)builder);
}

void *__llvm_get_current_debug_location2(void *builder) {
  return (LLVMMetadataRef)LLVMGetCurrentDebugLocation2((LLVMBuilderRef)builder);
}

void __llvm_set_current_debug_location2(void *builder, void *loc) {
  LLVMSetCurrentDebugLocation2((LLVMBuilderRef)builder, (LLVMMetadataRef)loc);
}

void __llvm_set_inst_debug_location(void *builder, void *inst) {
  LLVMSetInstDebugLocation((LLVMBuilderRef)builder, (LLVMValueRef)inst);
}

void __llvm_add_metadata_to_inst(void *builder, void *inst) {
  LLVMAddMetadataToInst((LLVMBuilderRef)builder, (LLVMValueRef)inst);
}

void *__llvm_builder_get_default_fp_math_tag(void *builder) {
  return (LLVMMetadataRef)LLVMBuilderGetDefaultFPMathTag(
      (LLVMBuilderRef)builder);
}

void __llvm_builder_set_default_fp_math_tag(void *builder, void *fp_math_tag) {
  LLVMBuilderSetDefaultFPMathTag((LLVMBuilderRef)builder,
                                 (LLVMMetadataRef)fp_math_tag);
}

void __llvm_set_current_debug_location(void *builder, void *l) {
  LLVMSetCurrentDebugLocation((LLVMBuilderRef)builder, (LLVMValueRef)l);
}

void *__llvm_get_current_debug_location(void *builder) {
  return (LLVMValueRef)LLVMGetCurrentDebugLocation((LLVMBuilderRef)builder);
}

void *__llvm_build_ret_void(void *builder) {
  return (LLVMValueRef)LLVMBuildRetVoid((LLVMBuilderRef)builder);
}

void *__llvm_build_ret(void *builder, void *v) {
  return (LLVMValueRef)LLVMBuildRet((LLVMBuilderRef)builder, (LLVMValueRef)v);
}

void *__llvm_build_aggregate_ret(void *builder, ArrayLLVMValueRef *ret_vals) {

  LLVMValueRef *llvm_ret_vals = (LLVMValueRef *)ret_vals->$0->data;
  unsigned n = ret_vals->$1;
  return (LLVMValueRef)LLVMBuildAggregateRet((LLVMBuilderRef)builder,
                                             llvm_ret_vals, n);
}

void *__llvm_build_br(void *builder, void *dest) {
  return (LLVMValueRef)LLVMBuildBr((LLVMBuilderRef)builder,
                                   (LLVMBasicBlockRef)dest);
}

void *__llvm_build_cond_br(void *builder, void *_if, void *then, void *_else) {
  return (LLVMValueRef)LLVMBuildCondBr(
      (LLVMBuilderRef)builder, (LLVMValueRef)_if, (LLVMBasicBlockRef)then,
      (LLVMBasicBlockRef)_else);
}

void *__llvm_build_switch(void *builder, void *v, void *_else,
                          unsigned num_cases) {
  return (LLVMValueRef)LLVMBuildSwitch((LLVMBuilderRef)builder, (LLVMValueRef)v,
                                       (LLVMBasicBlockRef)_else, num_cases);
}

void *__llvm_build_indirect_br(void *builder, void *addr, unsigned num_dests) {
  return (LLVMValueRef)LLVMBuildIndirectBr((LLVMBuilderRef)builder,
                                           (LLVMValueRef)addr, num_dests);
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

void *__llvm_build_unreachable(void *builder) {
  return (LLVMValueRef)LLVMBuildUnreachable((LLVMBuilderRef)builder);
}

void *__llvm_build_resume(void *builder, void *exn) {
  return (LLVMValueRef)LLVMBuildResume((LLVMBuilderRef)builder,
                                       (LLVMValueRef)exn);
}

void *__llvm_build_landing_pad(void *builder, void *ty, void *pers_fn,
                               unsigned num_clauses, void *name) {
  return (LLVMValueRef)LLVMBuildLandingPad(
      (LLVMBuilderRef)builder, (LLVMTypeRef)ty, (LLVMValueRef)pers_fn,
      num_clauses, (const char *)name);
}

void *__llvm_build_cleanup_ret(void *builder, void *catch_pad, void *bb) {
  return (LLVMValueRef)LLVMBuildCleanupRet(
      (LLVMBuilderRef)builder, (LLVMValueRef)catch_pad, (LLVMBasicBlockRef)bb);
}

void *__llvm_build_catch_ret(void *builder, void *catch_pad, void *bb) {
  return (LLVMValueRef)LLVMBuildCatchRet(
      (LLVMBuilderRef)builder, (LLVMValueRef)catch_pad, (LLVMBasicBlockRef)bb);
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

void *__llvm_build_catch_switch(void *builder, void *parent_pad,
                                void *unwind_bb, unsigned num_handlers,
                                void *name) {
  return (LLVMValueRef)LLVMBuildCatchSwitch(
      (LLVMBuilderRef)builder, (LLVMValueRef)parent_pad,
      (LLVMBasicBlockRef)unwind_bb, num_handlers, (const char *)name);
}

void __llvm_add_case(void *_switch, void *on_val, void *dest) {
  LLVMAddCase((LLVMValueRef)_switch, (LLVMValueRef)on_val,
              (LLVMBasicBlockRef)dest);
}

void __llvm_add_destination(void *indirect_br, void *dest) {
  LLVMAddDestination((LLVMValueRef)indirect_br, (LLVMBasicBlockRef)dest);
}

unsigned __llvm_get_num_clauses(void *landing_pad) {
  return LLVMGetNumClauses((LLVMValueRef)landing_pad);
}

void *__llvm_get_clause(void *landing_pad, unsigned idx) {
  return (LLVMValueRef)LLVMGetClause((LLVMValueRef)landing_pad, idx);
}

void __llvm_add_clause(void *landing_pad, void *clause_val) {
  LLVMAddClause((LLVMValueRef)landing_pad, (LLVMValueRef)clause_val);
}

LLVMBool __llvm_is_cleanup(void *landing_pad) {
  return LLVMIsCleanup((LLVMValueRef)landing_pad);
}

void __llvm_set_cleanup(void *landing_pad, LLVMBool val) {
  LLVMSetCleanup((LLVMValueRef)landing_pad, val);
}

void __llvm_add_handler(void *catch_switch, void *dest) {
  LLVMAddHandler((LLVMValueRef)catch_switch, (LLVMBasicBlockRef)dest);
}

unsigned __llvm_get_num_handlers(void *catch_switch) {
  return LLVMGetNumHandlers((LLVMValueRef)catch_switch);
}

void __llvm_get_handlers(void *catch_switch, void *handlers) {
  LLVMGetHandlers((LLVMValueRef)catch_switch, (LLVMBasicBlockRef *)handlers);
}

void *__llvm_get_arg_operand(void *funclet, unsigned i) {
  return (LLVMValueRef)LLVMGetArgOperand((LLVMValueRef)funclet, i);
}

void __llvm_set_arg_operand(void *funclet, unsigned i, void *value) {
  LLVMSetArgOperand((LLVMValueRef)funclet, i, (LLVMValueRef)value);
}

void *__llvm_get_parent_catch_switch(void *catch_pad) {
  return (LLVMValueRef)LLVMGetParentCatchSwitch((LLVMValueRef)catch_pad);
}

void __llvm_set_parent_catch_switch(void *catch_pad, void *catch_switch) {
  LLVMSetParentCatchSwitch((LLVMValueRef)catch_pad, (LLVMValueRef)catch_switch);
}

void *__llvm_build_add(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildAdd((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                    (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_nsw_add(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildNSWAdd((LLVMBuilderRef)builder,
                                       (LLVMValueRef)lhs, (LLVMValueRef)rhs,
                                       (const char *)name);
}

void *__llvm_build_nuw_add(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildNUWAdd((LLVMBuilderRef)builder,
                                       (LLVMValueRef)lhs, (LLVMValueRef)rhs,
                                       (const char *)name);
}

void *__llvm_build_f_add(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildFAdd((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                     (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_sub(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildSub((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                    (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_nsw_sub(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildNSWSub((LLVMBuilderRef)builder,
                                       (LLVMValueRef)lhs, (LLVMValueRef)rhs,
                                       (const char *)name);
}

void *__llvm_build_nuw_sub(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildNUWSub((LLVMBuilderRef)builder,
                                       (LLVMValueRef)lhs, (LLVMValueRef)rhs,
                                       (const char *)name);
}

void *__llvm_build_f_sub(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildFSub((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                     (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_mul(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildMul((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                    (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_nsw_mul(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildNSWMul((LLVMBuilderRef)builder,
                                       (LLVMValueRef)lhs, (LLVMValueRef)rhs,
                                       (const char *)name);
}

void *__llvm_build_nuw_mul(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildNUWMul((LLVMBuilderRef)builder,
                                       (LLVMValueRef)lhs, (LLVMValueRef)rhs,
                                       (const char *)name);
}

void *__llvm_build_f_mul(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildFMul((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                     (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_u_div(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildUDiv((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                     (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_exact_u_div(void *builder, void *lhs, void *rhs,
                               void *name) {
  return (LLVMValueRef)LLVMBuildExactUDiv((LLVMBuilderRef)builder,
                                          (LLVMValueRef)lhs, (LLVMValueRef)rhs,
                                          (const char *)name);
}

void *__llvm_build_s_div(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildSDiv((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                     (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_exact_s_div(void *builder, void *lhs, void *rhs,
                               void *name) {
  return (LLVMValueRef)LLVMBuildExactSDiv((LLVMBuilderRef)builder,
                                          (LLVMValueRef)lhs, (LLVMValueRef)rhs,
                                          (const char *)name);
}

void *__llvm_build_f_div(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildFDiv((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                     (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_u_rem(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildURem((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                     (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_s_rem(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildSRem((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                     (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_f_rem(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildFRem((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                     (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_shl(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildShl((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                    (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_l_shr(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildLShr((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                     (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_a_shr(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildAShr((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                     (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_and(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildAnd((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                    (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_or(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildOr((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                   (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_xor(void *builder, void *lhs, void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildXor((LLVMBuilderRef)builder, (LLVMValueRef)lhs,
                                    (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_bin_op(void *builder, int op_code, void *lhs, void *rhs,
                          void *name) {
  LLVMOpcode op = llvm_opcode_from_int(op_code);
  return (LLVMValueRef)LLVMBuildBinOp((LLVMBuilderRef)builder, op,
                                      (LLVMValueRef)lhs, (LLVMValueRef)rhs,
                                      (const char *)name);
}

void *__llvm_build_neg(void *builder, void *v, void *name) {
  return (LLVMValueRef)LLVMBuildNeg((LLVMBuilderRef)builder, (LLVMValueRef)v,
                                    (const char *)name);
}

void *__llvm_build_nsw_neg(void *builder, void *v, void *name) {
  return (LLVMValueRef)LLVMBuildNSWNeg((LLVMBuilderRef)builder, (LLVMValueRef)v,
                                       (const char *)name);
}

// void *__llvm_build_nuw_neg(void *builder, void *v, void *name) {
//   return (LLVMValueRef)LLVMBuildNUWNeg((LLVMBuilderRef)builder,
//   (LLVMValueRef)v,
//                                        (const char *)name);
// }

void *__llvm_build_f_neg(void *builder, void *v, void *name) {
  return (LLVMValueRef)LLVMBuildFNeg((LLVMBuilderRef)builder, (LLVMValueRef)v,
                                     (const char *)name);
}

void *__llvm_build_not(void *builder, void *v, void *name) {
  return (LLVMValueRef)LLVMBuildNot((LLVMBuilderRef)builder, (LLVMValueRef)v,
                                    (const char *)name);
}

LLVMBool __llvm_get_nuw(void *arith_inst) {
  return LLVMGetNUW((LLVMValueRef)arith_inst);
}

void __llvm_set_nuw(void *arith_inst, LLVMBool has_nuw) {
  LLVMSetNUW((LLVMValueRef)arith_inst, has_nuw);
}

LLVMBool __llvm_get_nsw(void *arith_inst) {
  return LLVMGetNSW((LLVMValueRef)arith_inst);
}

void __llvm_set_nsw(void *arith_inst, LLVMBool has_nsw) {
  LLVMSetNSW((LLVMValueRef)arith_inst, has_nsw);
}

LLVMBool __llvm_get_exact(void *div_or_shr_inst) {
  return LLVMGetExact((LLVMValueRef)div_or_shr_inst);
}

void __llvm_set_exact(void *div_or_shr_inst, LLVMBool is_exact) {
  LLVMSetExact((LLVMValueRef)div_or_shr_inst, is_exact);
}

LLVMBool __llvm_get_n_neg(void *non_neg_inst) {
  return LLVMGetNNeg((LLVMValueRef)non_neg_inst);
}

void __llvm_set_n_neg(void *non_neg_inst, LLVMBool is_non_neg) {
  LLVMSetNNeg((LLVMValueRef)non_neg_inst, is_non_neg);
}

LLVMFastMathFlags __llvm_get_fast_math_flags(void *fp_math_inst) {
  return LLVMGetFastMathFlags((LLVMValueRef)fp_math_inst);
}

void __llvm_set_fast_math_flags(void *fp_math_inst, LLVMFastMathFlags fmf) {
  LLVMSetFastMathFlags((LLVMValueRef)fp_math_inst, fmf);
}

LLVMBool __llvm_can_value_use_fast_math_flags(void *inst) {
  return LLVMCanValueUseFastMathFlags((LLVMValueRef)inst);
}

LLVMBool __llvm_get_is_disjoint(void *inst) {
  return LLVMGetIsDisjoint((LLVMValueRef)inst);
}

void __llvm_set_is_disjoint(void *inst, LLVMBool is_disjoint) {
  LLVMSetIsDisjoint((LLVMValueRef)inst, is_disjoint);
}

void *__llvm_build_malloc(void *builder, void *ty, void *name) {
  return (LLVMValueRef)LLVMBuildMalloc((LLVMBuilderRef)builder, (LLVMTypeRef)ty,
                                       (const char *)name);
}

void *__llvm_build_array_malloc(void *builder, void *ty, void *val,
                                void *name) {
  return (LLVMValueRef)LLVMBuildArrayMalloc((LLVMBuilderRef)builder,
                                            (LLVMTypeRef)ty, (LLVMValueRef)val,
                                            (const char *)name);
}

void *__llvm_build_mem_set(void *builder, void *ptr, void *val, void *len,
                           unsigned align) {
  return (LLVMValueRef)LLVMBuildMemSet((LLVMBuilderRef)builder,
                                       (LLVMValueRef)ptr, (LLVMValueRef)val,
                                       (LLVMValueRef)len, align);
}

void *__llvm_build_mem_cpy(void *builder, void *dst, unsigned dst_align,
                           void *src, unsigned src_align, void *size) {
  return (LLVMValueRef)LLVMBuildMemCpy(
      (LLVMBuilderRef)builder, (LLVMValueRef)dst, dst_align, (LLVMValueRef)src,
      src_align, (LLVMValueRef)size);
}

void *__llvm_build_mem_move(void *builder, void *dst, unsigned dst_align,
                            void *src, unsigned src_align, void *size) {
  return (LLVMValueRef)LLVMBuildMemMove(
      (LLVMBuilderRef)builder, (LLVMValueRef)dst, dst_align, (LLVMValueRef)src,
      src_align, (LLVMValueRef)size);
}

void *__llvm_build_alloca(void *builder, void *ty, void *name) {
  return (LLVMValueRef)LLVMBuildAlloca((LLVMBuilderRef)builder, (LLVMTypeRef)ty,
                                       (const char *)name);
}

void *__llvm_build_array_alloca(void *builder, void *ty, void *val,
                                void *name) {
  return (LLVMValueRef)LLVMBuildArrayAlloca((LLVMBuilderRef)builder,
                                            (LLVMTypeRef)ty, (LLVMValueRef)val,
                                            (const char *)name);
}

void *__llvm_build_free(void *builder, void *pointer_val) {
  return (LLVMValueRef)LLVMBuildFree((LLVMBuilderRef)builder,
                                     (LLVMValueRef)pointer_val);
}

void *__llvm_build_load2(void *builder, void *ty, void *pointer_val,
                         void *name) {
  return (LLVMValueRef)LLVMBuildLoad2((LLVMBuilderRef)builder, (LLVMTypeRef)ty,
                                      (LLVMValueRef)pointer_val,
                                      (const char *)name);
}

void *__llvm_build_store(void *builder, void *val, void *ptr) {
  return (LLVMValueRef)LLVMBuildStore((LLVMBuilderRef)builder,
                                      (LLVMValueRef)val, (LLVMValueRef)ptr);
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

void *__llvm_build_struct_gep2(void *builder, void *ty, void *pointer,
                               unsigned idx, void *name) {
  return (LLVMValueRef)LLVMBuildStructGEP2(
      (LLVMBuilderRef)builder, (LLVMTypeRef)ty, (LLVMValueRef)pointer, idx,
      (const char *)name);
}

void *__llvm_build_global_string(void *builder, void *str, void *name) {
  return (LLVMValueRef)LLVMBuildGlobalString(
      (LLVMBuilderRef)builder, (const char *)str, (const char *)name);
}

void *__llvm_build_global_string_ptr(void *builder, void *str, void *name) {
  return (LLVMValueRef)LLVMBuildGlobalStringPtr(
      (LLVMBuilderRef)builder, (const char *)str, (const char *)name);
}

LLVMBool __llvm_get_volatile(void *memory_access_inst) {
  return LLVMGetVolatile((LLVMValueRef)memory_access_inst);
}

void __llvm_set_volatile(void *memory_access_inst, LLVMBool is_volatile) {
  LLVMSetVolatile((LLVMValueRef)memory_access_inst, is_volatile);
}

LLVMBool __llvm_get_weak(void *cmp_xchg_inst) {
  return LLVMGetWeak((LLVMValueRef)cmp_xchg_inst);
}

void __llvm_set_weak(void *cmp_xchg_inst, LLVMBool is_weak) {
  LLVMSetWeak((LLVMValueRef)cmp_xchg_inst, is_weak);
}

LLVMAtomicOrdering __llvm_get_ordering(void *memory_access_inst) {
  return LLVMGetOrdering((LLVMValueRef)memory_access_inst);
}

void __llvm_set_ordering(void *memory_access_inst,
                         LLVMAtomicOrdering ordering) {
  LLVMSetOrdering((LLVMValueRef)memory_access_inst, ordering);
}

LLVMAtomicRMWBinOp __llvm_get_atomic_rmw_bin_op(void *atomic_rmw_inst) {
  return LLVMGetAtomicRMWBinOp((LLVMValueRef)atomic_rmw_inst);
}

void __llvm_set_atomic_rmw_bin_op(void *atomic_rmw_inst,
                                  LLVMAtomicRMWBinOp bin_op) {
  LLVMSetAtomicRMWBinOp((LLVMValueRef)atomic_rmw_inst, bin_op);
}

void *__llvm_build_trunc(void *builder, void *val, void *dest_ty, void *name) {
  return (LLVMValueRef)LLVMBuildTrunc((LLVMBuilderRef)builder,
                                      (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
                                      (const char *)name);
}

void *__llvm_build_z_ext(void *builder, void *val, void *dest_ty, void *name) {
  return (LLVMValueRef)LLVMBuildZExt((LLVMBuilderRef)builder, (LLVMValueRef)val,
                                     (LLVMTypeRef)dest_ty, (const char *)name);
}

void *__llvm_build_s_ext(void *builder, void *val, void *dest_ty, void *name) {
  return (LLVMValueRef)LLVMBuildSExt((LLVMBuilderRef)builder, (LLVMValueRef)val,
                                     (LLVMTypeRef)dest_ty, (const char *)name);
}

void *__llvm_build_fp_to_ui(void *builder, void *val, void *dest_ty,
                            void *name) {
  return (LLVMValueRef)LLVMBuildFPToUI((LLVMBuilderRef)builder,
                                       (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
                                       (const char *)name);
}

void *__llvm_build_fp_to_si(void *builder, void *val, void *dest_ty,
                            void *name) {
  return (LLVMValueRef)LLVMBuildFPToSI((LLVMBuilderRef)builder,
                                       (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
                                       (const char *)name);
}

void *__llvm_build_ui_to_fp(void *builder, void *val, void *dest_ty,
                            void *name) {
  return (LLVMValueRef)LLVMBuildUIToFP((LLVMBuilderRef)builder,
                                       (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
                                       (const char *)name);
}

void *__llvm_build_si_to_fp(void *builder, void *val, void *dest_ty,
                            void *name) {
  return (LLVMValueRef)LLVMBuildSIToFP((LLVMBuilderRef)builder,
                                       (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
                                       (const char *)name);
}

void *__llvm_build_fp_trunc(void *builder, void *val, void *dest_ty,
                            void *name) {
  return (LLVMValueRef)LLVMBuildFPTrunc((LLVMBuilderRef)builder,
                                        (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
                                        (const char *)name);
}

void *__llvm_build_fp_ext(void *builder, void *val, void *dest_ty, void *name) {
  return (LLVMValueRef)LLVMBuildFPExt((LLVMBuilderRef)builder,
                                      (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
                                      (const char *)name);
}

void *__llvm_build_ptr_to_int(void *builder, void *val, void *dest_ty,
                              void *name) {
  return (LLVMValueRef)LLVMBuildPtrToInt(
      (LLVMBuilderRef)builder, (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
      (const char *)name);
}

void *__llvm_build_int_to_ptr(void *builder, void *val, void *dest_ty,
                              void *name) {
  return (LLVMValueRef)LLVMBuildIntToPtr(
      (LLVMBuilderRef)builder, (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
      (const char *)name);
}

void *__llvm_build_bit_cast(void *builder, void *val, void *dest_ty,
                            void *name) {
  return (LLVMValueRef)LLVMBuildBitCast((LLVMBuilderRef)builder,
                                        (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
                                        (const char *)name);
}

void *__llvm_build_addr_space_cast(void *builder, void *val, void *dest_ty,
                                   void *name) {
  return (LLVMValueRef)LLVMBuildAddrSpaceCast(
      (LLVMBuilderRef)builder, (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
      (const char *)name);
}

void *__llvm_build_z_ext_or_bit_cast(void *builder, void *val, void *dest_ty,
                                     void *name) {
  return (LLVMValueRef)LLVMBuildZExtOrBitCast(
      (LLVMBuilderRef)builder, (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
      (const char *)name);
}

void *__llvm_build_s_ext_or_bit_cast(void *builder, void *val, void *dest_ty,
                                     void *name) {
  return (LLVMValueRef)LLVMBuildSExtOrBitCast(
      (LLVMBuilderRef)builder, (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
      (const char *)name);
}

void *__llvm_build_trunc_or_bit_cast(void *builder, void *val, void *dest_ty,
                                     void *name) {
  return (LLVMValueRef)LLVMBuildTruncOrBitCast(
      (LLVMBuilderRef)builder, (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
      (const char *)name);
}

void *__llvm_build_cast(void *builder, int op_code, void *val, void *dest_ty,
                        void *name) {
  LLVMOpcode op = llvm_opcode_from_int(op_code);
  return (LLVMValueRef)LLVMBuildCast((LLVMBuilderRef)builder, op,
                                     (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
                                     (const char *)name);
}

void *__llvm_build_pointer_cast(void *builder, void *val, void *dest_ty,
                                void *name) {
  return (LLVMValueRef)LLVMBuildPointerCast(
      (LLVMBuilderRef)builder, (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
      (const char *)name);
}

void *__llvm_build_int_cast2(void *builder, void *val, void *dest_ty,
                             LLVMBool is_signed, void *name) {
  return (LLVMValueRef)LLVMBuildIntCast2(
      (LLVMBuilderRef)builder, (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
      is_signed, (const char *)name);
}

void *__llvm_build_fp_cast(void *builder, void *val, void *dest_ty,
                           void *name) {
  return (LLVMValueRef)LLVMBuildFPCast((LLVMBuilderRef)builder,
                                       (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
                                       (const char *)name);
}

void *__llvm_build_int_cast(void *builder, void *val, void *dest_ty,
                            void *name) {
  return (LLVMValueRef)LLVMBuildIntCast((LLVMBuilderRef)builder,
                                        (LLVMValueRef)val, (LLVMTypeRef)dest_ty,
                                        (const char *)name);
}

int __llvm_get_cast_opcode(void *src, LLVMBool src_is_signed, void *dest_ty,
                           LLVMBool dest_is_signed) {
  LLVMOpcode code = LLVMGetCastOpcode((LLVMValueRef)src, src_is_signed,
                                      (LLVMTypeRef)dest_ty, dest_is_signed);
  return llvm_opcode_to_int(code);
}

void *__llvm_build_icmp(void *builder, LLVMIntPredicate op, void *lhs,
                        void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildICmp((LLVMBuilderRef)builder, op,
                                     (LLVMValueRef)lhs, (LLVMValueRef)rhs,
                                     (const char *)name);
}

void *__llvm_build_fcmp(void *builder, LLVMRealPredicate op, void *lhs,
                        void *rhs, void *name) {
  return (LLVMValueRef)LLVMBuildFCmp((LLVMBuilderRef)builder, op,
                                     (LLVMValueRef)lhs, (LLVMValueRef)rhs,
                                     (const char *)name);
}

void *__llvm_build_phi(void *builder, void *ty, void *name) {
  return (LLVMValueRef)LLVMBuildPhi((LLVMBuilderRef)builder, (LLVMTypeRef)ty,
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

void *__llvm_build_select(void *builder, void *_if, void *then, void *_else,
                          void *name) {
  return (LLVMValueRef)LLVMBuildSelect((LLVMBuilderRef)builder,
                                       (LLVMValueRef)_if, (LLVMValueRef)then,
                                       (LLVMValueRef)_else, (const char *)name);
}

void *__llvm_build_va_arg(void *builder, void *list, void *ty, void *name) {
  return (LLVMValueRef)LLVMBuildVAArg((LLVMBuilderRef)builder,
                                      (LLVMValueRef)list, (LLVMTypeRef)ty,
                                      (const char *)name);
}

void *__llvm_build_extract_element(void *builder, void *vec_val, void *index,
                                   void *name) {
  return (LLVMValueRef)LLVMBuildExtractElement(
      (LLVMBuilderRef)builder, (LLVMValueRef)vec_val, (LLVMValueRef)index,
      (const char *)name);
}

void *__llvm_build_insert_element(void *builder, void *vec_val, void *elt_val,
                                  void *index, void *name) {
  return (LLVMValueRef)LLVMBuildInsertElement(
      (LLVMBuilderRef)builder, (LLVMValueRef)vec_val, (LLVMValueRef)elt_val,
      (LLVMValueRef)index, (const char *)name);
}

void *__llvm_build_shuffle_vector(void *builder, void *v1, void *v2, void *mask,
                                  void *name) {
  return (LLVMValueRef)LLVMBuildShuffleVector(
      (LLVMBuilderRef)builder, (LLVMValueRef)v1, (LLVMValueRef)v2,
      (LLVMValueRef)mask, (const char *)name);
}

void *__llvm_build_extract_value(void *builder, void *agg_val, unsigned index,
                                 void *name) {
  return (LLVMValueRef)LLVMBuildExtractValue((LLVMBuilderRef)builder,
                                             (LLVMValueRef)agg_val, index,
                                             (const char *)name);
}

void *__llvm_build_insert_value(void *builder, void *agg_val, void *elt_val,
                                unsigned index, void *name) {
  return (LLVMValueRef)LLVMBuildInsertValue(
      (LLVMBuilderRef)builder, (LLVMValueRef)agg_val, (LLVMValueRef)elt_val,
      index, (const char *)name);
}

void *__llvm_build_freeze(void *builder, void *val, void *name) {
  return (LLVMValueRef)LLVMBuildFreeze((LLVMBuilderRef)builder,
                                       (LLVMValueRef)val, (const char *)name);
}

void *__llvm_build_is_null(void *builder, void *val, void *name) {
  return (LLVMValueRef)LLVMBuildIsNull((LLVMBuilderRef)builder,
                                       (LLVMValueRef)val, (const char *)name);
}

void *__llvm_build_is_not_null(void *builder, void *val, void *name) {
  return (LLVMValueRef)LLVMBuildIsNotNull(
      (LLVMBuilderRef)builder, (LLVMValueRef)val, (const char *)name);
}

void *__llvm_build_ptr_diff2(void *builder, void *elem_ty, void *lhs, void *rhs,
                             void *name) {
  return (LLVMValueRef)LLVMBuildPtrDiff2(
      (LLVMBuilderRef)builder, (LLVMTypeRef)elem_ty, (LLVMValueRef)lhs,
      (LLVMValueRef)rhs, (const char *)name);
}

void *__llvm_build_fence(void *builder, LLVMAtomicOrdering ordering,
                         LLVMBool single_thread, void *name) {
  return (LLVMValueRef)LLVMBuildFence((LLVMBuilderRef)builder, ordering,
                                      single_thread, (const char *)name);
}

void *__llvm_build_atomic_rmw(void *builder, LLVMAtomicRMWBinOp op, void *ptr,
                              void *val, LLVMAtomicOrdering ordering,
                              LLVMBool single_thread) {
  return (LLVMValueRef)LLVMBuildAtomicRMW((LLVMBuilderRef)builder, op,
                                          (LLVMValueRef)ptr, (LLVMValueRef)val,
                                          ordering, single_thread);
}

void *__llvm_build_atomic_cmp_xchg(void *builder, void *ptr, void *cmp,
                                   void *_new,
                                   LLVMAtomicOrdering success_ordering,
                                   LLVMAtomicOrdering failure_ordering,
                                   LLVMBool single_thread) {
  return (LLVMValueRef)LLVMBuildAtomicCmpXchg(
      (LLVMBuilderRef)builder, (LLVMValueRef)ptr, (LLVMValueRef)cmp,
      (LLVMValueRef)_new, success_ordering, failure_ordering, single_thread);
}

unsigned __llvm_get_num_mask_elements(void *shuffle_vector_inst) {
  return LLVMGetNumMaskElements((LLVMValueRef)shuffle_vector_inst);
}

int __llvm_get_undef_mask_elem() { return LLVMGetUndefMaskElem(); }

int __llvm_get_mask_value(void *shuffle_vector_inst, unsigned elt) {
  return LLVMGetMaskValue((LLVMValueRef)shuffle_vector_inst, elt);
}

LLVMBool __llvm_is_atomic_single_thread(void *atomic_inst) {
  return LLVMIsAtomicSingleThread((LLVMValueRef)atomic_inst);
}

void __llvm_set_atomic_single_thread(void *atomic_inst,
                                     LLVMBool single_thread) {
  LLVMSetAtomicSingleThread((LLVMValueRef)atomic_inst, single_thread);
}

LLVMAtomicOrdering __llvm_get_cmp_xchg_success_ordering(void *cmp_xchg_inst) {
  return LLVMGetCmpXchgSuccessOrdering((LLVMValueRef)cmp_xchg_inst);
}

void __llvm_set_cmp_xchg_success_ordering(void *cmp_xchg_inst,
                                          LLVMAtomicOrdering ordering) {
  LLVMSetCmpXchgSuccessOrdering((LLVMValueRef)cmp_xchg_inst, ordering);
}

LLVMAtomicOrdering __llvm_get_cmp_xchg_failure_ordering(void *cmp_xchg_inst) {
  return LLVMGetCmpXchgFailureOrdering((LLVMValueRef)cmp_xchg_inst);
}

void __llvm_set_cmp_xchg_failure_ordering(void *cmp_xchg_inst,
                                          LLVMAtomicOrdering ordering) {
  LLVMSetCmpXchgFailureOrdering((LLVMValueRef)cmp_xchg_inst, ordering);
}

void *__llvm_create_module_provider_for_existing_module(void *m) {
  return (LLVMModuleProviderRef)LLVMCreateModuleProviderForExistingModule(
      (LLVMModuleRef)m);
}

void __llvm_dispose_module_provider(void *m) {
  LLVMDisposeModuleProvider((LLVMModuleProviderRef)m);
}

LLVMBool __llvm_create_memory_buffer_with_contents_of_file(void *path,
                                                           void **out_mem_buf,
                                                           void **out_message) {
  return LLVMCreateMemoryBufferWithContentsOfFile(
      (const char *)path, (LLVMMemoryBufferRef *)out_mem_buf,
      (char **)out_message);
}

LLVMBool __llvm_create_memory_buffer_with_stdin(void **out_mem_buf,
                                                void **out_message) {
  return LLVMCreateMemoryBufferWithSTDIN((LLVMMemoryBufferRef *)out_mem_buf,
                                         (char **)out_message);
}

void *__llvm_create_memory_buffer_with_memory_range(
    void *input_data, size_t input_data_length, void *buffer_name,
    LLVMBool requires_null_terminator) {
  return (LLVMMemoryBufferRef)LLVMCreateMemoryBufferWithMemoryRange(
      (const char *)input_data, input_data_length, (const char *)buffer_name,
      requires_null_terminator);
}

void *__llvm_create_memory_buffer_with_memory_range_copy(
    void *input_data, size_t input_data_length, void *buffer_name) {
  return (LLVMMemoryBufferRef)LLVMCreateMemoryBufferWithMemoryRangeCopy(
      (const char *)input_data, input_data_length, (const char *)buffer_name);
}

void *__llvm_get_buffer_start(void *mem_buf) {
  return (char *)LLVMGetBufferStart((LLVMMemoryBufferRef)mem_buf);
}

size_t __llvm_get_buffer_size(void *mem_buf) {
  return LLVMGetBufferSize((LLVMMemoryBufferRef)mem_buf);
}

void __llvm_dispose_memory_buffer(void *mem_buf) {
  LLVMDisposeMemoryBuffer((LLVMMemoryBufferRef)mem_buf);
}

void *__llvm_create_pass_manager() {
  return (LLVMPassManagerRef)LLVMCreatePassManager();
}

void *__llvm_create_function_pass_manager_for_module(void *m) {
  return (LLVMPassManagerRef)LLVMCreateFunctionPassManagerForModule(
      (LLVMModuleRef)m);
}

void *__llvm_create_function_pass_manager(void *mp) {
  return (LLVMPassManagerRef)LLVMCreateFunctionPassManager(
      (LLVMModuleProviderRef)mp);
}

LLVMBool __llvm_run_pass_manager(void *pm, void *m) {
  return LLVMRunPassManager((LLVMPassManagerRef)pm, (LLVMModuleRef)m);
}

LLVMBool __llvm_initialize_function_pass_manager(void *fpm) {
  return LLVMInitializeFunctionPassManager((LLVMPassManagerRef)fpm);
}

LLVMBool __llvm_run_function_pass_manager(void *fpm, void *f) {
  return LLVMRunFunctionPassManager((LLVMPassManagerRef)fpm, (LLVMValueRef)f);
}

LLVMBool __llvm_finalize_function_pass_manager(void *fpm) {
  return LLVMFinalizeFunctionPassManager((LLVMPassManagerRef)fpm);
}

void __llvm_dispose_pass_manager(void *pm) {
  LLVMDisposePassManager((LLVMPassManagerRef)pm);
}

LLVMBool __llvm_start_multithreaded() { return LLVMStartMultithreaded(); }

void __llvm_stop_multithreaded() { LLVMStopMultithreaded(); }

LLVMBool __llvm_is_multithreaded() { return LLVMIsMultithreaded(); }
