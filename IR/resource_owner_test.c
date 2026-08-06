/*
 * Test-instrumentation companion for the IR package's native owner stub and
 * IR/resource_owner_wbtest.mbt.
 * Watched pointers are unretained identities, so observation never keeps an
 * owner alive. The single global trace is test-only and not thread-safe.
 */

#include <stddef.h>
#include <stdint.h>

struct llvm_mbt_owner_test_trace {
  void *context;
  void *module;
  void *builder;
  uint64_t events;
};

static struct llvm_mbt_owner_test_trace llvm_mbt_test_trace;

/*
 * C test hook called after a native disposer returns. Event values 1, 2, and 3
 * denote Context, Module, and Builder respectively.
 */
void llvm_mbt_ir_owner_test_record(void *owner, uint64_t event) {
  void **watched = NULL;
  switch (event) {
  case 1:
    watched = &llvm_mbt_test_trace.context;
    break;
  case 2:
    watched = &llvm_mbt_test_trace.module;
    break;
  case 3:
    watched = &llvm_mbt_test_trace.builder;
    break;
  default:
    return;
  }
  if (owner == *watched) {
    llvm_mbt_test_trace.events = llvm_mbt_test_trace.events * 10 + event;
    *watched = NULL;
  }
}

/*
 * MoonBit wbtest extern: owner_test_watch (IR/resource_owner_wbtest.mbt).
 * Starts one trace without retaining or dereferencing the watched owners.
 */
void llvm_mbt_ir_owner_test_watch(void *context, void *module, void *builder) {
  llvm_mbt_test_trace.context = context;
  llvm_mbt_test_trace.module = module;
  llvm_mbt_test_trace.builder = builder;
  llvm_mbt_test_trace.events = 0;
}

/*
 * MoonBit wbtest extern: owner_test_take_trace
 * (IR/resource_owner_wbtest.mbt). Returns the event digits and clears all test
 * state so stale identities cannot affect later finalizers.
 */
uint64_t llvm_mbt_ir_owner_test_take_trace(void) {
  uint64_t events = llvm_mbt_test_trace.events;
  llvm_mbt_test_trace.context = NULL;
  llvm_mbt_test_trace.module = NULL;
  llvm_mbt_test_trace.builder = NULL;
  llvm_mbt_test_trace.events = 0;
  return events;
}
