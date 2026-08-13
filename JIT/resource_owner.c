/*
 * Managed owner control blocks for the public JIT package.
 * This first layer owns one LLVMOrcLLJITRef, centralizes open/closed state, and
 * makes explicit close and finalizer fallback share a take-once path.
 */

#include <llvm-c/Error.h>
#include <llvm-c/LLJIT.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef memcpy
#undef memcpy
#endif
#include "moonbit.h"

struct llvm_mbt_jit_owner {
  LLVMOrcLLJITRef raw;
};

/* Test observer implemented by resource_owner_test.c; it retains nothing. */
void llvm_mbt_jit_owner_test_record(void *owner, uint64_t event);

static moonbit_bytes_t llvm_mbt_jit_copy_z(const char *text) {
  size_t length = text == NULL ? 0 : strlen(text);
  if (length > (size_t)INT32_MAX) {
    fputs("LLVM JIT diagnostic is too large for MoonBit Bytes\n", stderr);
    abort();
  }
  moonbit_bytes_t result = moonbit_make_bytes((int32_t)length, 0);
  if (length != 0) {
    memcpy(result, text, length);
  }
  return result;
}

static LLVMOrcLLJITRef llvm_mbt_jit_owner_take_raw(
    struct llvm_mbt_jit_owner *owner) {
  LLVMOrcLLJITRef raw = owner->raw;
  owner->raw = NULL;
  return raw;
}

static moonbit_bytes_t llvm_mbt_jit_owner_dispose(
    struct llvm_mbt_jit_owner *owner, int32_t *out_failed) {
  LLVMOrcLLJITRef raw = llvm_mbt_jit_owner_take_raw(owner);
  if (raw == NULL) {
    *out_failed = 1;
    return llvm_mbt_jit_copy_z("LLJIT session is already closed");
  }
  LLVMErrorRef error = LLVMOrcDisposeLLJIT(raw);
  llvm_mbt_jit_owner_test_record(owner, 1);
  if (error == LLVMErrorSuccess) {
    *out_failed = 0;
    return moonbit_make_bytes(0, 0);
  }
  char *message = LLVMGetErrorMessage(error);
  moonbit_bytes_t result = llvm_mbt_jit_copy_z(message);
  LLVMDisposeErrorMessage(message);
  *out_failed = 1;
  return result;
}

/* Finalizer fallback consumes shutdown errors because it cannot raise them. */
static void llvm_mbt_finalize_jit_owner(void *payload) {
  struct llvm_mbt_jit_owner *owner = payload;
  if (owner->raw != NULL) {
    int32_t failed = 0;
    llvm_mbt_jit_owner_dispose(owner, &failed);
  }
}

/*
 * MoonBit extern: LLJITOwner::new (JIT/resource_owner.mbt).
 * Takes unique ownership of a non-null LLJIT handle.
 */
void *llvm_mbt_jit_owner_new(LLVMOrcLLJITRef raw) {
  struct llvm_mbt_jit_owner *owner = moonbit_make_external_object(
      llvm_mbt_finalize_jit_owner,
      (uint32_t)sizeof(struct llvm_mbt_jit_owner));
  owner->raw = raw;
  return owner;
}

/* MoonBit extern: LLJITOwner::isOpen (JIT/resource_owner.mbt). */
int32_t llvm_mbt_jit_owner_is_open(struct llvm_mbt_jit_owner *owner) {
  return owner->raw != NULL;
}

/*
 * MoonBit extern: LLJITOwner::raw (JIT/resource_owner.mbt).
 * Returns a borrowed handle; callers must first check that the owner is open
 * and keep the owner alive for the complete synchronous LLVM call.
 */
LLVMOrcLLJITRef llvm_mbt_jit_owner_raw(struct llvm_mbt_jit_owner *owner) {
  return owner->raw;
}

/*
 * MoonBit extern: LLJITOwner::closeRaw (JIT/resource_owner.mbt).
 * Takes the raw handle before disposal. Success and failure both permanently
 * close every alias; the returned Bytes owns a copied diagnostic.
 */
moonbit_bytes_t llvm_mbt_jit_owner_close(struct llvm_mbt_jit_owner *owner,
                                         int32_t *out_failed) {
  return llvm_mbt_jit_owner_dispose(owner, out_failed);
}
