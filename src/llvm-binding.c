#include <llvm-c/Analysis.h>
#include <llvm-c/BitWriter.h>
#include <llvm-c/Core.h>
#include <llvm-c/ExecutionEngine.h>
#include <llvm-c/Target.h>

#include "moonbit.h"
#include <stdio.h>
#include <stdlib.h>

struct $$moonbitlang$core$builtin$Array$3c$Type$3e$ {
  struct moonbit_object header;
  int32_t $1;
  struct $FixedArray$3c$UnsafeMaybeUninit$3c$Type$3e$$3e$ *$0;
};

struct $FixedArray$3c$UnsafeMaybeUninit$3c$Type$3e$$3e$ {
  struct moonbit_object header;
  void *data[0];
};

char *convert_moonbit_string_to_c_string(struct moonbit_string *ms) {
  uint16_t *data = ms->data;
  int32_t const len = Moonbit_array_length(ms);
  char *name = (char *)malloc(len + 1);
  for (int32_t i = 0; i < len; ++i) {
    name[i] = data[i];
    if (data[i] < 128) {
      name[i] = data[i];
    } else {
      name[i] = '?';
    }
  }
  return name;
}

void *__LLVMInt32Type(void *$0) {
  return LLVMInt32TypeInContext((LLVMContextRef)$0);
}

void *__LLVMContextCreate() { return LLVMContextCreate(); }

void *__LLVMModuleCreateWithNameInContext(void *$0, struct moonbit_string *$1) {
  char *name = convert_moonbit_string_to_c_string($1);
  LLVMContextRef context = (LLVMContextRef)$0;
  LLVMModuleRef module = LLVMModuleCreateWithNameInContext(name, context);
  return module;
}

void *__LLVMConstInt(void *$0, int32_t $1, int32_t $2) {
  return LLVMConstInt((LLVMTypeRef)$0, $1, $2);
}

void *
__LLVMFunctionType(void *$0,
                   struct $$moonbitlang$core$builtin$Array$3c$Type$3e$ *$1,
                   int32_t $2) {
  LLVMTypeRef *param_tys = (LLVMTypeRef *)$1->$0->data;
  int32_t param_cnt = $1->$1;
  return LLVMFunctionType((LLVMTypeRef)$0, param_tys, param_cnt, $2);
}

void __LLVMBuildRet(void *$0, void *$1) {
  LLVMBuildRet((LLVMBuilderRef)$0, (LLVMValueRef)$1);
}

void __LLVMPositionBuilderAtEnd(void *$0, void *$1) {
  LLVMPositionBuilderAtEnd((LLVMBuilderRef)$0, (LLVMBasicBlockRef)$1);
}

void *__LLVMCreateBuilder(void *$0) {
  return LLVMCreateBuilderInContext((LLVMContextRef)$0);
}

void *__LLVMAppendBasicBlock(void *$0, void *$1, struct moonbit_string *$2) {
  char *block_name = convert_moonbit_string_to_c_string($2);
  return LLVMAppendBasicBlockInContext((LLVMContextRef)$0, (LLVMValueRef)$1,
                                       block_name);
}

void __LLVMDumpModule(void *$0) { LLVMDumpModule((LLVMModuleRef)$0); }

void *__LLVMAddFunction(void *$0, struct moonbit_string *$1, void *$2) {
  char *func_name = convert_moonbit_string_to_c_string($1);
  return LLVMAddFunction((LLVMModuleRef)$0, func_name, (LLVMTypeRef)$2);
}
