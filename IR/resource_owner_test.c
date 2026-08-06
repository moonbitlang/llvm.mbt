#include <stddef.h>
#include <stdint.h>

struct llvm_mbt_owner_test_trace {
  void *context;
  void *module;
  void *builder;
  uint64_t events;
};

static struct llvm_mbt_owner_test_trace llvm_mbt_test_trace;

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

void llvm_mbt_ir_owner_test_watch(void *context, void *module, void *builder) {
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
