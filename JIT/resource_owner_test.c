/*
 * Test-only observer for JIT/resource_owner.c and resource_owner_wbtest.mbt.
 * Watched owner pointers are unretained identities and never extend lifetime.
 */

#include <stddef.h>
#include <stdint.h>

static void *llvm_mbt_watched_jit_owner;
static uint64_t llvm_mbt_jit_owner_events;

/* Called by production owner code after one native LLJIT disposal. */
void llvm_mbt_jit_owner_test_record(void *owner, uint64_t event) {
  if (owner == llvm_mbt_watched_jit_owner) {
    llvm_mbt_jit_owner_events = llvm_mbt_jit_owner_events * 10 + event;
  }
}

/*
 * MoonBit wbtest extern: jit_owner_test_watch
 * (JIT/resource_owner_wbtest.mbt). Does not retain or dereference `owner`.
 */
void llvm_mbt_jit_owner_test_watch(void *owner) {
  llvm_mbt_watched_jit_owner = owner;
  llvm_mbt_jit_owner_events = 0;
}

/*
 * MoonBit wbtest extern: jit_owner_test_take_trace
 * (JIT/resource_owner_wbtest.mbt). Clears stale test state after reading.
 */
uint64_t llvm_mbt_jit_owner_test_take_trace(void) {
  uint64_t result = llvm_mbt_jit_owner_events;
  llvm_mbt_watched_jit_owner = NULL;
  llvm_mbt_jit_owner_events = 0;
  return result;
}
