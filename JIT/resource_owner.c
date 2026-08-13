/*
 * Managed owner control blocks for the public JIT package.
 * LLJIT aliases and ResourceTracker aliases share native state. Explicit
 * close/remove and finalizer fallback all use take-once release paths.
 */

#include <llvm-c/Error.h>
#include <llvm-c/LLJIT.h>
#include <llvm-c/Orc.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef memcpy
#undef memcpy
#endif
#include "moonbit.h"

struct llvm_mbt_jit_tracker_owner;

struct llvm_mbt_jit_owner {
  LLVMOrcLLJITRef raw;
  struct llvm_mbt_jit_tracker_owner *trackers;
};

struct llvm_mbt_jit_tracker_owner {
  LLVMOrcResourceTrackerRef raw;
  struct llvm_mbt_jit_owner *jit;
  struct llvm_mbt_jit_tracker_owner *previous;
  struct llvm_mbt_jit_tracker_owner *next;
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

static void llvm_mbt_jit_tracker_unlink(
    struct llvm_mbt_jit_tracker_owner *tracker) {
  struct llvm_mbt_jit_owner *jit = tracker->jit;
  if (jit == NULL) {
    return;
  }
  if (tracker->previous != NULL) {
    tracker->previous->next = tracker->next;
  } else if (jit->trackers == tracker) {
    jit->trackers = tracker->next;
  }
  if (tracker->next != NULL) {
    tracker->next->previous = tracker->previous;
  }
  tracker->previous = NULL;
  tracker->next = NULL;
}

static void llvm_mbt_jit_tracker_release_raw(
    struct llvm_mbt_jit_tracker_owner *tracker) {
  if (tracker->raw != NULL) {
    LLVMOrcReleaseResourceTracker(tracker->raw);
    tracker->raw = NULL;
    llvm_mbt_jit_owner_test_record(tracker, 2);
  }
  llvm_mbt_jit_tracker_unlink(tracker);
}

static void llvm_mbt_jit_owner_invalidate_trackers(
    struct llvm_mbt_jit_owner *owner) {
  while (owner->trackers != NULL) {
    llvm_mbt_jit_tracker_release_raw(owner->trackers);
  }
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
  llvm_mbt_jit_owner_invalidate_trackers(owner);
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

static void llvm_mbt_finalize_jit_owner(void *payload) {
  struct llvm_mbt_jit_owner *owner = payload;
  if (owner->raw != NULL) {
    int32_t failed = 0;
    llvm_mbt_jit_owner_dispose(owner, &failed);
  }
}

static void llvm_mbt_finalize_jit_tracker_owner(void *payload) {
  struct llvm_mbt_jit_tracker_owner *tracker = payload;
  struct llvm_mbt_jit_owner *jit = tracker->jit;
  llvm_mbt_jit_tracker_release_raw(tracker);
  tracker->jit = NULL;
  if (jit != NULL) {
    moonbit_decref(jit);
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
  owner->trackers = NULL;
  return owner;
}

/* MoonBit extern: LLJITOwner::isOpen (JIT/resource_owner.mbt). */
int32_t llvm_mbt_jit_owner_is_open(struct llvm_mbt_jit_owner *owner) {
  return owner->raw != NULL;
}

/*
 * MoonBit extern: LLJITOwner::raw (JIT/resource_owner.mbt).
 * Returns a borrowed handle while the owner remains open and reachable.
 */
LLVMOrcLLJITRef llvm_mbt_jit_owner_raw(struct llvm_mbt_jit_owner *owner) {
  return owner->raw;
}

/*
 * MoonBit extern: LLJITOwner::closeRaw (JIT/resource_owner.mbt).
 * Takes the raw handle before disposal. Every outcome permanently closes all
 * aliases and invalidates/releases every live client tracker reference.
 */
moonbit_bytes_t llvm_mbt_jit_owner_close(struct llvm_mbt_jit_owner *owner,
                                         int32_t *out_failed) {
  return llvm_mbt_jit_owner_dispose(owner, out_failed);
}

/*
 * MoonBit extern: LLJITOwner::newTracker (JIT/resource_owner.mbt).
 * Creates one client-owned tracker reference, retains its LLJIT owner, and
 * links the tracker control block for close-time invalidation.
 */
void *llvm_mbt_jit_tracker_owner_new(struct llvm_mbt_jit_owner *jit) {
  LLVMOrcJITDylibRef jit_dylib = LLVMOrcLLJITGetMainJITDylib(jit->raw);
  LLVMOrcResourceTrackerRef raw =
      LLVMOrcJITDylibCreateResourceTracker(jit_dylib);
  if (raw == NULL) {
    fputs("LLVMOrcJITDylibCreateResourceTracker returned NULL\n", stderr);
    abort();
  }
  struct llvm_mbt_jit_tracker_owner *tracker = moonbit_make_external_object(
      llvm_mbt_finalize_jit_tracker_owner,
      (uint32_t)sizeof(struct llvm_mbt_jit_tracker_owner));
  tracker->raw = raw;
  tracker->jit = jit;
  tracker->previous = NULL;
  tracker->next = jit->trackers;
  if (jit->trackers != NULL) {
    jit->trackers->previous = tracker;
  }
  jit->trackers = tracker;
  moonbit_incref(jit);
  return tracker;
}

/* MoonBit extern: ResourceTrackerOwner::isActive (JIT/resource_owner.mbt). */
int32_t llvm_mbt_jit_tracker_owner_is_active(
    struct llvm_mbt_jit_tracker_owner *tracker) {
  return tracker->raw != NULL;
}

/* MoonBit extern: ResourceTrackerOwner::belongsTo (JIT/resource_owner.mbt). */
int32_t llvm_mbt_jit_tracker_owner_belongs_to(
    struct llvm_mbt_jit_tracker_owner *tracker,
    struct llvm_mbt_jit_owner *jit) {
  return tracker->jit == jit;
}

/*
 * MoonBit extern: ResourceTrackerOwner::raw (JIT/resource_owner.mbt).
 * Returns a borrowed handle while both tracker and LLJIT are active.
 */
LLVMOrcResourceTrackerRef llvm_mbt_jit_tracker_owner_raw(
    struct llvm_mbt_jit_tracker_owner *tracker) {
  return tracker->raw;
}

/*
 * MoonBit extern: ResourceTrackerOwner::removeRaw
 * (JIT/resource_owner.mbt). Success invalidates aliases and releases the client
 * ref. Failure leaves the tracker active, but consumes and copies the error.
 */
moonbit_bytes_t llvm_mbt_jit_tracker_owner_remove(
    struct llvm_mbt_jit_tracker_owner *tracker, int32_t *out_failed) {
  LLVMErrorRef error = LLVMOrcResourceTrackerRemove(tracker->raw);
  if (error != LLVMErrorSuccess) {
    char *message = LLVMGetErrorMessage(error);
    moonbit_bytes_t result = llvm_mbt_jit_copy_z(message);
    LLVMDisposeErrorMessage(message);
    *out_failed = 1;
    return result;
  }
  llvm_mbt_jit_owner_test_record(tracker, 3);
  llvm_mbt_jit_tracker_release_raw(tracker);
  *out_failed = 0;
  return moonbit_make_bytes(0, 0);
}
