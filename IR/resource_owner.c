#include <llvm-c/Core.h>
#include <stdint.h>

#include "moonbit.h"

struct llvm_mbt_context_owner {
  LLVMContextRef raw;
  uint8_t tracked_for_test;
};

struct llvm_mbt_module_owner {
  LLVMModuleRef raw;
  struct llvm_mbt_context_owner *context;
  uint8_t tracked_for_test;
};

struct llvm_mbt_builder_owner {
  LLVMBuilderRef raw;
  struct llvm_mbt_context_owner *context;
  uint8_t tracked_for_test;
};

static int32_t llvm_mbt_context_owner_finalize_count = 0;
static int32_t llvm_mbt_module_owner_finalize_count = 0;
static int32_t llvm_mbt_builder_owner_finalize_count = 0;

static void llvm_mbt_finalize_inactive_context_owner(void *payload) {
  struct llvm_mbt_context_owner *owner = payload;
  if (owner->tracked_for_test != 0) {
    llvm_mbt_context_owner_finalize_count += 1;
  }
  owner->raw = NULL;
}

static void llvm_mbt_finalize_inactive_module_owner(void *payload) {
  struct llvm_mbt_module_owner *owner = payload;
  struct llvm_mbt_context_owner *context = owner->context;
  if (owner->tracked_for_test != 0) {
    llvm_mbt_module_owner_finalize_count += 1;
  }
  owner->raw = NULL;
  owner->context = NULL;
  if (context != NULL) {
    moonbit_decref(context);
  }
}

static void llvm_mbt_finalize_inactive_builder_owner(void *payload) {
  struct llvm_mbt_builder_owner *owner = payload;
  struct llvm_mbt_context_owner *context = owner->context;
  if (owner->tracked_for_test != 0) {
    llvm_mbt_builder_owner_finalize_count += 1;
  }
  owner->raw = NULL;
  owner->context = NULL;
  if (context != NULL) {
    moonbit_decref(context);
  }
}

static struct llvm_mbt_context_owner *llvm_mbt_make_context_owner(
    LLVMContextRef raw, uint8_t tracked_for_test) {
  struct llvm_mbt_context_owner *owner = moonbit_make_external_object(
      llvm_mbt_finalize_inactive_context_owner,
      (uint32_t)sizeof(struct llvm_mbt_context_owner));
  owner->raw = raw;
  owner->tracked_for_test = tracked_for_test;
  return owner;
}

static struct llvm_mbt_module_owner *llvm_mbt_make_module_owner(
    LLVMModuleRef raw, struct llvm_mbt_context_owner *context,
    uint8_t tracked_for_test) {
  struct llvm_mbt_module_owner *owner = moonbit_make_external_object(
      llvm_mbt_finalize_inactive_module_owner,
      (uint32_t)sizeof(struct llvm_mbt_module_owner));
  owner->raw = raw;
  owner->context = context;
  owner->tracked_for_test = tracked_for_test;
  moonbit_incref(context);
  return owner;
}

static struct llvm_mbt_builder_owner *llvm_mbt_make_builder_owner(
    LLVMBuilderRef raw, struct llvm_mbt_context_owner *context,
    uint8_t tracked_for_test) {
  struct llvm_mbt_builder_owner *owner = moonbit_make_external_object(
      llvm_mbt_finalize_inactive_builder_owner,
      (uint32_t)sizeof(struct llvm_mbt_builder_owner));
  owner->raw = raw;
  owner->context = context;
  owner->tracked_for_test = tracked_for_test;
  moonbit_incref(context);
  return owner;
}

void *llvm_mbt_ir_context_owner_new(LLVMContextRef raw) {
  return llvm_mbt_make_context_owner(raw, 0);
}

LLVMContextRef llvm_mbt_ir_context_owner_raw(
    struct llvm_mbt_context_owner *owner) {
  return owner->raw;
}

int llvm_mbt_ir_context_owner_same(struct llvm_mbt_context_owner *lhs,
                                   struct llvm_mbt_context_owner *rhs) {
  return lhs == rhs;
}

void *llvm_mbt_ir_module_owner_new(
    LLVMModuleRef raw, struct llvm_mbt_context_owner *context) {
  return llvm_mbt_make_module_owner(raw, context, 0);
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

void *llvm_mbt_ir_builder_owner_new(
    LLVMBuilderRef raw, struct llvm_mbt_context_owner *context) {
  return llvm_mbt_make_builder_owner(raw, context, 0);
}

LLVMBuilderRef llvm_mbt_ir_builder_owner_raw(
    struct llvm_mbt_builder_owner *owner) {
  return owner->raw;
}

void *llvm_mbt_ir_builder_owner_context(
    struct llvm_mbt_builder_owner *owner) {
  moonbit_incref(owner->context);
  return owner->context;
}

void llvm_mbt_ir_owner_test_reset(void) {
  llvm_mbt_context_owner_finalize_count = 0;
  llvm_mbt_module_owner_finalize_count = 0;
  llvm_mbt_builder_owner_finalize_count = 0;
}

void *llvm_mbt_ir_owner_test_context_new(void) {
  return llvm_mbt_make_context_owner(NULL, 1);
}

void *llvm_mbt_ir_owner_test_module_new(
    struct llvm_mbt_context_owner *context) {
  return llvm_mbt_make_module_owner(NULL, context, 1);
}

int32_t llvm_mbt_ir_owner_test_context_finalize_count(void) {
  return llvm_mbt_context_owner_finalize_count;
}

int32_t llvm_mbt_ir_owner_test_module_finalize_count(void) {
  return llvm_mbt_module_owner_finalize_count;
}
