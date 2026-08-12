/*
 * Native owner control blocks for the IR package's MoonBit FFI boundary.
 * Each payload owns one LLVM resource and retains the MoonBit owners required
 * to keep that resource's parents alive until its finalizer runs.
 */

#include <llvm-c/Core.h>
#include <llvm-c/TargetMachine.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "moonbit.h"

/* `raw` fields are owned; parent owner pointers are retained MoonBit refs. */
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

struct llvm_mbt_target_machine_owner {
  LLVMTargetMachineRef raw;
};

/* C test hook implemented by resource_owner_test.c; it never retains owners. */
void llvm_mbt_ir_owner_test_record(void *owner, uint64_t event);

/* Reaching this path means one control block attempted a second disposal. */
static void llvm_mbt_owner_disposal_error(const char *kind) {
  fprintf(stderr,
          "\033[1;31m[llvm.mbt] fatal: attempted to dispose %s owner more "
          "than once\033[0m\n",
          kind);
  fflush(stderr);
  abort();
}

/*
 * Move an owned raw handle out of its control block before disposal. Clearing
 * the field first makes any repeated disposal fail fast instead of reaching
 * LLVM with the same handle twice.
 */
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

static LLVMTargetMachineRef llvm_mbt_target_machine_owner_take_raw(
    struct llvm_mbt_target_machine_owner *owner) {
  LLVMTargetMachineRef raw = owner->raw;
  if (raw == NULL) {
    llvm_mbt_owner_disposal_error("TargetMachine");
  }
  owner->raw = NULL;
  return raw;
}

/* Dispose the native handle, then notify the non-owning test observer. */
static void llvm_mbt_context_owner_dispose_once(
  struct llvm_mbt_context_owner *owner) {
  LLVMContextDispose(llvm_mbt_context_owner_take_raw(owner));
  llvm_mbt_ir_owner_test_record(owner, 1);
}

static void llvm_mbt_module_owner_dispose_once(
  struct llvm_mbt_module_owner *owner) {
  LLVMDisposeModule(llvm_mbt_module_owner_take_raw(owner));
  llvm_mbt_ir_owner_test_record(owner, 2);
}

static void llvm_mbt_builder_owner_dispose_once(
  struct llvm_mbt_builder_owner *owner) {
  LLVMDisposeBuilder(llvm_mbt_builder_owner_take_raw(owner));
  llvm_mbt_ir_owner_test_record(owner, 3);
}

static void llvm_mbt_target_machine_owner_dispose_once(
    struct llvm_mbt_target_machine_owner *owner) {
  LLVMDisposeTargetMachine(llvm_mbt_target_machine_owner_take_raw(owner));
  llvm_mbt_ir_owner_test_record(owner, 4);
}

/* Finalize the only native resource owned by a ContextOwner. */
static void llvm_mbt_finalize_context_owner(void *payload) {
  llvm_mbt_context_owner_dispose_once(payload);
}

/* Dispose the module before releasing the ContextOwner it depends on. */
static void llvm_mbt_finalize_module_owner(void *payload) {
  struct llvm_mbt_module_owner *owner = payload;
  struct llvm_mbt_context_owner *context = owner->context;
  owner->context = NULL;
  llvm_mbt_module_owner_dispose_once(owner);
  if (context != NULL) {
    moonbit_decref(context);
  }
}

/*
 * Dispose the builder before releasing its insertion ModuleOwner and its
 * ContextOwner. This preserves every native parent through LLVM disposal.
 */
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

/* Finalize the only native resource owned by a TargetMachineOwner. */
static void llvm_mbt_finalize_target_machine_owner(void *payload) {
  llvm_mbt_target_machine_owner_dispose_once(payload);
}

/*
 * MoonBit extern: ContextOwner::new (IR/resource_owner.mbt).
 * Assumes ownership of `raw`; the returned external object disposes it.
 */
void *llvm_mbt_ir_context_owner_new(LLVMContextRef raw) {
  struct llvm_mbt_context_owner *owner = moonbit_make_external_object(
      llvm_mbt_finalize_context_owner,
      (uint32_t)sizeof(struct llvm_mbt_context_owner));
  owner->raw = raw;
  return owner;
}

/*
 * MoonBit extern: ModuleOwner::new (IR/resource_owner.mbt).
 * Assumes ownership of `raw` and retains `context` until module finalization.
 */
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

/*
 * MoonBit extern: BuilderOwner::new (IR/resource_owner.mbt).
 * Assumes ownership of `raw` and retains `context`; no module is retained until
 * BuilderOwner::set_module establishes an insertion-point dependency.
 */
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

/*
 * MoonBit extern: TargetMachineOwner::new (IR/resource_owner.mbt).
 * Assumes ownership of one non-NULL target machine; the returned external
 * object has no parent and disposes that handle exactly once.
 */
void *llvm_mbt_ir_target_machine_owner_new(LLVMTargetMachineRef raw) {
  struct llvm_mbt_target_machine_owner *owner = moonbit_make_external_object(
      llvm_mbt_finalize_target_machine_owner,
      (uint32_t)sizeof(struct llvm_mbt_target_machine_owner));
  owner->raw = raw;
  return owner;
}

/*
 * MoonBit extern: TargetMachineOwner::raw (IR/resource_owner.mbt).
 * Returns a borrowed handle valid only while `owner` remains alive.
 */
LLVMTargetMachineRef llvm_mbt_ir_target_machine_owner_raw(
    struct llvm_mbt_target_machine_owner *owner) {
  return owner->raw;
}

/*
 * MoonBit extern: ContextOwner::raw (IR/resource_owner.mbt).
 * Returns a borrowed handle valid only while `owner` remains alive.
 */
LLVMContextRef llvm_mbt_ir_context_owner_raw(
    struct llvm_mbt_context_owner *owner) {
  return owner->raw;
}

/*
 * MoonBit extern: ModuleOwner::raw (IR/resource_owner.mbt).
 * Returns a borrowed handle valid only while `owner` remains alive.
 */
LLVMModuleRef llvm_mbt_ir_module_owner_raw(
    struct llvm_mbt_module_owner *owner) {
  return owner->raw;
}

/*
 * MoonBit extern: ModuleOwner::context (IR/resource_owner.mbt).
 * Returns the retained ContextOwner as a new MoonBit reference.
 */
void *llvm_mbt_ir_module_owner_context(
    struct llvm_mbt_module_owner *owner) {
  moonbit_incref(owner->context);
  return owner->context;
}

/*
 * MoonBit extern: BuilderOwner::raw (IR/resource_owner.mbt).
 * Returns a borrowed handle valid only while `owner` remains alive.
 */
LLVMBuilderRef llvm_mbt_ir_builder_owner_raw(
    struct llvm_mbt_builder_owner *owner) {
  return owner->raw;
}

/*
 * MoonBit extern: BuilderOwner::set_module (IR/resource_owner.mbt).
 * Retains the new insertion ModuleOwner before releasing the previous one.
 */
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

/*
 * MoonBit extern: BuilderOwner::context (IR/resource_owner.mbt).
 * Returns the retained ContextOwner as a new MoonBit reference.
 */
void *llvm_mbt_ir_builder_owner_context(
    struct llvm_mbt_builder_owner *owner) {
  moonbit_incref(owner->context);
  return owner->context;
}
