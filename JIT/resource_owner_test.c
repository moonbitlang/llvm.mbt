/*
 * Test-only observer for JIT/resource_owner.c and resource_owner_wbtest.mbt.
 * Watched owner pointers are unretained identities and never extend lifetime.
 */

#include <stddef.h>
#include <stdint.h>

static void *llvm_mbt_watched_jit_owner;
static void *llvm_mbt_watched_tracker_owner;
static uint64_t llvm_mbt_jit_owner_events;
static uint64_t llvm_mbt_injected_failure;

/* Called by production owner code after one native dispose/remove/release. */
void llvm_mbt_jit_owner_test_record(void *owner, uint64_t event) {
  if (owner == llvm_mbt_watched_jit_owner ||
      owner == llvm_mbt_watched_tracker_owner) {
    llvm_mbt_jit_owner_events = llvm_mbt_jit_owner_events * 10 + event;
  }
}

/*
 * MoonBit wbtest extern: jit_owner_test_watch
 * (JIT/resource_owner_wbtest.mbt). Does not retain the owner.
 */
void llvm_mbt_jit_owner_test_watch(void *owner) {
  llvm_mbt_watched_jit_owner = owner;
  llvm_mbt_watched_tracker_owner = NULL;
  llvm_mbt_jit_owner_events = 0;
}

/*
 * MoonBit wbtest extern: jit_tracker_owner_test_watch
 * (JIT/resource_owner_wbtest.mbt). Does not retain the tracker.
 */
void llvm_mbt_jit_tracker_owner_test_watch(void *tracker) {
  llvm_mbt_watched_jit_owner = NULL;
  llvm_mbt_watched_tracker_owner = tracker;
  llvm_mbt_jit_owner_events = 0;
}

/*
 * MoonBit wbtest extern: jit_owner_test_take_trace
 * (JIT/resource_owner_wbtest.mbt). Clears stale test state after reading.
 */
uint64_t llvm_mbt_jit_owner_test_take_trace(void) {
  uint64_t result = llvm_mbt_jit_owner_events;
  llvm_mbt_watched_jit_owner = NULL;
  llvm_mbt_watched_tracker_owner = NULL;
  llvm_mbt_jit_owner_events = 0;
  return result;
}

/*
 * MoonBit wbtest extern: jit_owner_test_inject_failure
 * (JIT/resource_owner_wbtest.mbt). The next matching owner operation consumes
 * this one-shot request. 1 means close; 2 means tracker removal.
 */
void llvm_mbt_jit_owner_test_inject_failure(uint64_t operation) {
  llvm_mbt_injected_failure = operation;
}

/* Called only by resource_owner.c at the corresponding operation boundary. */
int32_t llvm_mbt_jit_owner_test_take_failure(uint64_t operation) {
  if (llvm_mbt_injected_failure != operation) {
    return 0;
  }
  llvm_mbt_injected_failure = 0;
  return 1;
}
