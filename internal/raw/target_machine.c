/*
 * Native target and code-generation adapters for the internal raw package's
 * native stub boundary. This file exports LLVM-C static-inline initialization
 * helpers as linkable symbols and will host the operation adapters whose error
 * and temporary-resource contracts cannot be expressed directly by MoonBit FFI.
 */

#include <llvm-c/Analysis.h>
#include <llvm-c/Core.h>
#include <llvm-c/Target.h>
#include <llvm-c/TargetMachine.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#ifdef memcpy
#undef memcpy
#endif
#include "moonbit.h"

/* Copy and release an optional diagnostic allocated by LLVM. */
static moonbit_bytes_t llvm_mbt_copy_and_dispose_message(char *message) {
  if (message == NULL) {
    return moonbit_make_bytes(0, 0);
  }
  size_t length = strlen(message);
  if (length > (size_t)INT32_MAX) {
    fputs("LLVM diagnostic is too large for MoonBit Bytes\n", stderr);
    abort();
  }
  moonbit_bytes_t bytes = moonbit_make_bytes((int32_t)length, 0);
  if (length != 0) {
    memcpy(bytes, message, length);
  }
  LLVMDisposeMessage(message);
  return bytes;
}

/*
 * MoonBit extern: llvm_initialize_native_target (internal/raw/Target.mbt).
 * Mutates LLVM's process-global target registry. LLVM defines repeated native
 * initialization as safe; false means success and true means unavailable.
 */
LLVMBool llvm_mbt_initialize_native_target(void) {
  return LLVMInitializeNativeTarget();
}

/*
 * MoonBit extern: llvm_initialize_native_asm_printer (internal/raw/Target.mbt).
 * Mutates LLVM's process-global target registry. LLVM defines repeated native
 * initialization as safe; false means success and true means unavailable.
 */
LLVMBool llvm_mbt_initialize_native_asm_printer(void) {
  return LLVMInitializeNativeAsmPrinter();
}

/*
 * MoonBit extern: llvm_target_machine_set_module_data_layout
 * (internal/raw/TargetMachine.mbt).
 * The temporary TargetData is valid only for this call. LLVM copies its
 * DataLayout into the module before the adapter disposes the handle.
 */
void llvm_mbt_target_machine_set_module_data_layout(
    LLVMTargetMachineRef machine, LLVMModuleRef module) {
  LLVMTargetDataRef data_layout = LLVMCreateTargetDataLayout(machine);
  LLVMSetModuleDataLayout(module, data_layout);
  LLVMDisposeTargetData(data_layout);
}

/*
 * MoonBit extern: __llvm_verify_module (internal/raw/Analysis.mbt).
 * Always uses LLVMReturnStatusAction. Any optional LLVM-owned diagnostic is
 * copied into MoonBit Bytes and released before this call returns.
 */
moonbit_bytes_t llvm_mbt_verify_module(
    LLVMModuleRef module, LLVMBool *out_failed) {
  char *message = NULL;
  *out_failed =
      LLVMVerifyModule(module, LLVMReturnStatusAction, &message);
  return llvm_mbt_copy_and_dispose_message(message);
}

/*
 * MoonBit extern: __llvm_target_machine_emit_object_to_file
 * (internal/raw/TargetMachine.mbt).
 * The filename is borrowed for this call, output is fixed to LLVMObjectFile,
 * and any LLVM-owned diagnostic is copied and released before returning.
 */
moonbit_bytes_t llvm_mbt_target_machine_emit_object_to_file(
    LLVMTargetMachineRef machine, LLVMModuleRef module,
    const char *filename, LLVMBool *out_failed) {
  char *message = NULL;
  *out_failed = LLVMTargetMachineEmitToFile(
      machine, module, filename, LLVMObjectFile, &message);
  return llvm_mbt_copy_and_dispose_message(message);
}

/*
 * MoonBit wbtest extern: __target_machine_test_temp_path
 * (internal/raw/target_machine_wbtest.mbt).
 * Creates a process-unique path, removes the placeholder immediately, and
 * returns an independent byte copy for an emission test.
 */
moonbit_bytes_t llvm_mbt_target_machine_test_temp_path(void) {
  char path[] = "/tmp/llvm-mbt-object-XXXXXX";
  int fd = mkstemp(path);
  if (fd == -1) {
    return moonbit_make_bytes(0, 0);
  }
  close(fd);
  unlink(path);
  size_t length = strlen(path);
  moonbit_bytes_t bytes = moonbit_make_bytes((int32_t)length, 0);
  memcpy(bytes, path, length);
  return bytes;
}

/*
 * MoonBit wbtest extern: __target_machine_test_remove_file
 * (internal/raw/target_machine_wbtest.mbt). The path is borrowed for this call.
 */
LLVMBool llvm_mbt_target_machine_test_remove_file(const char *path) {
  return unlink(path) == 0;
}
