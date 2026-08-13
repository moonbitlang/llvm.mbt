/*
 * ORC LLJIT adapters for internal/raw/LLJIT.mbt and Error.mbt.
 * These entry points normalize LLVMErrorRef consumption, copy borrowed strings
 * before their LLJIT owner can change, and expose out-parameters safely to
 * MoonBit's native backend.
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

static moonbit_bytes_t llvm_mbt_orc_copy_bytes(const char *data,
                                                size_t length) {
  if (length > (size_t)INT32_MAX) {
    fputs("LLVM ORC diagnostic is too large for MoonBit Bytes\n", stderr);
    abort();
  }
  moonbit_bytes_t result = moonbit_make_bytes((int32_t)length, 0);
  if (length != 0) {
    memcpy(result, data, length);
  }
  return result;
}

static moonbit_bytes_t llvm_mbt_orc_copy_z(const char *text) {
  if (text == NULL) {
    return moonbit_make_bytes(0, 0);
  }
  return llvm_mbt_orc_copy_bytes(text, strlen(text));
}

static moonbit_bytes_t llvm_mbt_orc_take_error(LLVMErrorRef error,
                                                LLVMBool *out_failed) {
  if (error == LLVMErrorSuccess) {
    *out_failed = 0;
    return moonbit_make_bytes(0, 0);
  }
  *out_failed = 1;
  char *message = LLVMGetErrorMessage(error);
  moonbit_bytes_t result = llvm_mbt_orc_copy_z(message);
  LLVMDisposeErrorMessage(message);
  return result;
}

/*
 * MoonBit extern: __llvm_take_error_message (internal/raw/Error.mbt).
 * `error` must be non-null and uniquely owned by the caller. This function
 * consumes it with LLVMGetErrorMessage, copies the text, and disposes the
 * returned message before returning.
 */
moonbit_bytes_t llvm_mbt_take_error_message(LLVMErrorRef error) {
  LLVMBool failed = 0;
  moonbit_bytes_t result = llvm_mbt_orc_take_error(error, &failed);
  if (!failed) {
    fputs("attempted to consume LLVMErrorSuccess as an error\n", stderr);
    abort();
  }
  return result;
}

/*
 * MoonBit extern: __llvm_orc_create_lljit (internal/raw/LLJIT.mbt).
 * The builder is consumed by LLVMOrcCreateLLJIT on both success and failure.
 * `out_jit` is null on failure and uniquely owned by the caller on success.
 */
moonbit_bytes_t llvm_mbt_orc_create_lljit(LLVMOrcLLJITRef *out_jit,
                                           LLVMBool *out_failed) {
  *out_jit = NULL;
  LLVMOrcLLJITBuilderRef builder = LLVMOrcCreateLLJITBuilder();
  if (builder == NULL) {
    *out_failed = 1;
    return llvm_mbt_orc_copy_z("LLVMOrcCreateLLJITBuilder returned NULL");
  }
  LLVMErrorRef error = LLVMOrcCreateLLJIT(out_jit, builder);
  return llvm_mbt_orc_take_error(error, out_failed);
}

/*
 * MoonBit extern: __llvm_orc_dispose_lljit (internal/raw/LLJIT.mbt).
 * `jit` is consumed by LLVMOrcDisposeLLJIT even when session shutdown reports
 * an error. The error object and message are consumed before returning.
 */
moonbit_bytes_t llvm_mbt_orc_dispose_lljit(LLVMOrcLLJITRef jit,
                                            LLVMBool *out_failed) {
  return llvm_mbt_orc_take_error(LLVMOrcDisposeLLJIT(jit), out_failed);
}

/*
 * MoonBit extern: __llvm_orc_lljit_get_triple_string
 * (internal/raw/LLJIT.mbt). The LLVM string is borrowed from `jit`; this entry
 * returns an independent byte copy without extending the LLJIT lifetime.
 */
moonbit_bytes_t llvm_mbt_orc_lljit_get_triple_string(LLVMOrcLLJITRef jit) {
  return llvm_mbt_orc_copy_z(LLVMOrcLLJITGetTripleString(jit));
}

/*
 * MoonBit extern: __llvm_orc_lljit_get_data_layout_str
 * (internal/raw/LLJIT.mbt). The LLVM string is borrowed from `jit`; this entry
 * returns an independent byte copy.
 */
moonbit_bytes_t llvm_mbt_orc_lljit_get_data_layout_str(LLVMOrcLLJITRef jit) {
  return llvm_mbt_orc_copy_z(LLVMOrcLLJITGetDataLayoutStr(jit));
}

/* MoonBit extern: llvm_orc_lljit_get_global_prefix (internal/raw/LLJIT.mbt). */
int32_t llvm_mbt_orc_lljit_get_global_prefix(LLVMOrcLLJITRef jit) {
  return (unsigned char)LLVMOrcLLJITGetGlobalPrefix(jit);
}

/*
 * MoonBit extern: __llvm_orc_lljit_lookup (internal/raw/LLJIT.mbt).
 * `name` is borrowed for this synchronous call. The executor address is only
 * valid while its LLJIT session and defining resources remain alive.
 */
moonbit_bytes_t llvm_mbt_orc_lljit_lookup(
    LLVMOrcLLJITRef jit, const char *name, LLVMOrcExecutorAddress *out_address,
    LLVMBool *out_failed) {
  *out_address = 0;
  return llvm_mbt_orc_take_error(
      LLVMOrcLLJITLookup(jit, out_address, name), out_failed);
}
