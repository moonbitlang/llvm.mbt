#include <llvm-c/Core.h>
#include <stdint.h>

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

static void llvm_mbt_finalize_inactive_context_owner(void *payload) {
  struct llvm_mbt_context_owner *owner = payload;
  owner->raw = NULL;
}

static void llvm_mbt_finalize_inactive_module_owner(void *payload) {
  struct llvm_mbt_module_owner *owner = payload;
  struct llvm_mbt_context_owner *context = owner->context;
  owner->raw = NULL;
  owner->context = NULL;
  if (context != NULL) {
    moonbit_decref(context);
  }
}

static void llvm_mbt_finalize_inactive_builder_owner(void *payload) {
  struct llvm_mbt_builder_owner *owner = payload;
  struct llvm_mbt_context_owner *context = owner->context;
  struct llvm_mbt_module_owner *module = owner->module;
  owner->raw = NULL;
  owner->context = NULL;
  owner->module = NULL;
  if (module != NULL) {
    moonbit_decref(module);
  }
  if (context != NULL) {
    moonbit_decref(context);
  }
}

void *llvm_mbt_ir_context_owner_new(LLVMContextRef raw) {
  struct llvm_mbt_context_owner *owner = moonbit_make_external_object(
      llvm_mbt_finalize_inactive_context_owner,
      (uint32_t)sizeof(struct llvm_mbt_context_owner));
  owner->raw = raw;
  return owner;
}

void *llvm_mbt_ir_module_owner_new(
    LLVMModuleRef raw, struct llvm_mbt_context_owner *context) {
  struct llvm_mbt_module_owner *owner = moonbit_make_external_object(
      llvm_mbt_finalize_inactive_module_owner,
      (uint32_t)sizeof(struct llvm_mbt_module_owner));
  owner->raw = raw;
  owner->context = context;
  moonbit_incref(context);
  return owner;
}

void *llvm_mbt_ir_builder_owner_new(
    LLVMBuilderRef raw, struct llvm_mbt_context_owner *context) {
  struct llvm_mbt_builder_owner *owner = moonbit_make_external_object(
      llvm_mbt_finalize_inactive_builder_owner,
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
