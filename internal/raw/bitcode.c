/*
 * In-memory bitcode adapter for internal/raw/BitWriter.mbt.
 * It turns LLVM's owned memory buffer into independent MoonBit Bytes while
 * preserving exact pointer-length contents and disposing the buffer once.
 */

#include <llvm-c/BitWriter.h>
#include <llvm-c/Core.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef memcpy
#undef memcpy
#endif
#include "moonbit.h"

/*
 * MoonBit extern: llvm_write_bitcode_to_bytes (internal/raw/BitWriter.mbt).
 * `module` is borrowed for this call. LLVMWriteBitcodeToMemoryBuffer returns an
 * owned buffer; this function copies its exact bytes and disposes it before
 * returning, so the MoonBit result has no native lifetime dependency.
 */
moonbit_bytes_t llvm_mbt_write_bitcode_to_bytes(LLVMModuleRef module) {
  LLVMMemoryBufferRef buffer = LLVMWriteBitcodeToMemoryBuffer(module);
  if (buffer == NULL) {
    fputs("LLVM returned a null bitcode memory buffer\n", stderr);
    abort();
  }

  size_t length = LLVMGetBufferSize(buffer);
  if (length > (size_t)INT32_MAX) {
    LLVMDisposeMemoryBuffer(buffer);
    fputs("LLVM bitcode is too large for MoonBit Bytes\n", stderr);
    abort();
  }

  moonbit_bytes_t result = moonbit_make_bytes((int32_t)length, 0);
  if (length != 0) {
    memcpy(result, LLVMGetBufferStart(buffer), length);
  }
  LLVMDisposeMemoryBuffer(buffer);
  return result;
}
