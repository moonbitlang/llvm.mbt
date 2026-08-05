#include <llvm-c/Core.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "moonbit.h"

struct llvm_mbt_context_owner {
  LLVMContextRef raw;
};

struct llvm_mbt_module_owner {
  LLVMModuleRef raw;
  struct llvm_mbt_context_owner *context;
};

struct llvm_mbt_builder_owner {
  LLVMBuilderRef raw;
  struct llvm_mbt_context_owner *context;
  struct llvm_mbt_module_owner *module;
};

struct llvm_mbt_owner_test_trace {
  struct llvm_mbt_context_owner *context;
  struct llvm_mbt_module_owner *module;
  struct llvm_mbt_builder_owner *builder;
  uint64_t events;
};

static struct llvm_mbt_owner_test_trace llvm_mbt_test_trace;

static void llvm_mbt_owner_disposal_error(const char *kind) {
  fprintf(stderr,
          "\033[1;31m[llvm.mbt] fatal: attempted to dispose %s owner more "
          "than once\033[0m\n",
          kind);
  fflush(stderr);
  abort();
}

static LLVMContextRef llvm_mbt_context_owner_take_raw(
    struct llvm_mbt_context_owner *owner) {
  LLVMContextRef raw = owner->raw;
  if (raw == NULL) {
    llvm_mbt_owner_disposal_error("Context");
  }
  owner->raw = NULL;
  return raw;
}

static LLVMModuleRef llvm_mbt_module_owner_take_raw(
    struct llvm_mbt_module_owner *owner) {
  LLVMModuleRef raw = owner->raw;
  if (raw == NULL) {
    llvm_mbt_owner_disposal_error("Module");
  }
  owner->raw = NULL;
  return raw;
}

static LLVMBuilderRef llvm_mbt_builder_owner_take_raw(
    struct llvm_mbt_builder_owner *owner) {
  LLVMBuilderRef raw = owner->raw;
  if (raw == NULL) {
    llvm_mbt_owner_disposal_error("Builder");
  }
  owner->raw = NULL;
  return raw;
}

static void llvm_mbt_owner_test_record(uint64_t event) {
  llvm_mbt_test_trace.events = llvm_mbt_test_trace.events * 10 + event;
}

static void llvm_mbt_context_owner_dispose_once(
  struct llvm_mbt_context_owner *owner) {
  LLVMContextDispose(llvm_mbt_context_owner_take_raw(owner));
  if (owner == llvm_mbt_test_trace.context) {
    llvm_mbt_owner_test_record(1);
    llvm_mbt_test_trace.context = NULL;
  }
}

static void llvm_mbt_module_owner_dispose_once(
  struct llvm_mbt_module_owner *owner) {
  LLVMDisposeModule(llvm_mbt_module_owner_take_raw(owner));
  if (owner == llvm_mbt_test_trace.module) {
    llvm_mbt_owner_test_record(2);
    llvm_mbt_test_trace.module = NULL;
  }
}

static void llvm_mbt_builder_owner_dispose_once(
  struct llvm_mbt_builder_owner *owner) {
  LLVMDisposeBuilder(llvm_mbt_builder_owner_take_raw(owner));
  if (owner == llvm_mbt_test_trace.builder) {
    llvm_mbt_owner_test_record(3);
    llvm_mbt_test_trace.builder = NULL;
  }
}

static void llvm_mbt_finalize_context_owner(void *payload) {
  llvm_mbt_context_owner_dispose_once(payload);
}

static void llvm_mbt_finalize_module_owner(void *payload) {
  struct llvm_mbt_module_owner *owner = payload;
  struct llvm_mbt_context_owner *context = owner->context;
  owner->context = NULL;
  llvm_mbt_module_owner_dispose_once(owner);
  if (context != NULL) {
    moonbit_decref(context);
  }
}

static void llvm_mbt_finalize_builder_owner(void *payload) {
  struct llvm_mbt_builder_owner *owner = payload;
  struct llvm_mbt_context_owner *context = owner->context;
  struct llvm_mbt_module_owner *module = owner->module;
  owner->context = NULL;
  owner->module = NULL;
  llvm_mbt_builder_owner_dispose_once(owner);
  if (module != NULL) {
    moonbit_decref(module);
  }
  if (context != NULL) {
    moonbit_decref(context);
  }
}

void *llvm_mbt_ir_context_owner_new(LLVMContextRef raw) {
  struct llvm_mbt_context_owner *owner = moonbit_make_external_object(
      llvm_mbt_finalize_context_owner,
      (uint32_t)sizeof(struct llvm_mbt_context_owner));
  owner->raw = raw;
  return owner;
}

void *llvm_mbt_ir_module_owner_new(
    LLVMModuleRef raw, struct llvm_mbt_context_owner *context) {
  struct llvm_mbt_module_owner *owner = moonbit_make_external_object(
      llvm_mbt_finalize_module_owner,
      (uint32_t)sizeof(struct llvm_mbt_module_owner));
  owner->raw = raw;
  owner->context = context;
  moonbit_incref(context);
  return owner;
}

void *llvm_mbt_ir_builder_owner_new(
    LLVMBuilderRef raw, struct llvm_mbt_context_owner *context) {
  struct llvm_mbt_builder_owner *owner = moonbit_make_external_object(
      llvm_mbt_finalize_builder_owner,
      (uint32_t)sizeof(struct llvm_mbt_builder_owner));
  owner->raw = raw;
  owner->context = context;
  owner->module = NULL;
  moonbit_incref(context);
  return owner;
}

LLVMContextRef llvm_mbt_ir_context_owner_raw(
    struct llvm_mbt_context_owner *owner) {
  return owner->raw;
}

LLVMModuleRef llvm_mbt_ir_module_owner_raw(
    struct llvm_mbt_module_owner *owner) {
  return owner->raw;
}

void *llvm_mbt_ir_module_owner_context(
    struct llvm_mbt_module_owner *owner) {
  moonbit_incref(owner->context);
  return owner->context;
}

LLVMBuilderRef llvm_mbt_ir_builder_owner_raw(
    struct llvm_mbt_builder_owner *owner) {
  return owner->raw;
}

void llvm_mbt_ir_builder_owner_set_module(
    struct llvm_mbt_builder_owner *owner,
    struct llvm_mbt_module_owner *module) {
  struct llvm_mbt_module_owner *old_module = owner->module;
  moonbit_incref(module);
  owner->module = module;
  if (old_module != NULL) {
    moonbit_decref(old_module);
  }
}

void *llvm_mbt_ir_builder_owner_context(
    struct llvm_mbt_builder_owner *owner) {
  moonbit_incref(owner->context);
  return owner->context;
}

void llvm_mbt_ir_owner_test_watch(
    struct llvm_mbt_context_owner *context,
    struct llvm_mbt_module_owner *module,
    struct llvm_mbt_builder_owner *builder) {
  llvm_mbt_test_trace.context = context;
  llvm_mbt_test_trace.module = module;
  llvm_mbt_test_trace.builder = builder;
  llvm_mbt_test_trace.events = 0;
}

uint64_t llvm_mbt_ir_owner_test_take_trace(void) {
  uint64_t events = llvm_mbt_test_trace.events;
  llvm_mbt_test_trace.context = NULL;
  llvm_mbt_test_trace.module = NULL;
  llvm_mbt_test_trace.builder = NULL;
  llvm_mbt_test_trace.events = 0;
  return events;
}
