/*
 * Native target and code-generation adapters for the unsafe package's native
 * stub boundary. This file exports LLVM-C static-inline initialization helpers
 * as linkable symbols and will host the operation adapters whose error and
 * temporary-resource contracts cannot be expressed directly by MoonBit FFI.
 */

#include <llvm-c/Target.h>
#include <llvm-c/TargetMachine.h>

/*
 * MoonBit extern: llvm_initialize_native_target (unsafe/Target.mbt).
 * Mutates LLVM's process-global target registry. LLVM defines repeated native
 * initialization as safe; false means success and true means unavailable.
 */
LLVMBool llvm_mbt_initialize_native_target(void) {
  return LLVMInitializeNativeTarget();
}

/*
 * MoonBit extern: llvm_initialize_native_asm_printer (unsafe/Target.mbt).
 * Mutates LLVM's process-global target registry. LLVM defines repeated native
 * initialization as safe; false means success and true means unavailable.
 */
LLVMBool llvm_mbt_initialize_native_asm_printer(void) {
  return LLVMInitializeNativeAsmPrinter();
}
