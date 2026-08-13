/*
 * ORC LLJIT adapters for internal/raw/LLJIT.mbt and Error.mbt.
 * These entry points normalize LLVMErrorRef consumption, copy borrowed strings
 * before their LLJIT owner can change, and expose out-parameters safely to
 * MoonBit's native backend.
 */

#include <llvm-c/Error.h>
#include <llvm-c/BitReader.h>
#include <llvm-c/Core.h>
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
  moonbit_bytes_t create_message =
      llvm_mbt_orc_take_error(error, out_failed);
  if (*out_failed) {
    return create_message;
  }

  /*
   * The packaged LLVM 22.1 C LLJIT builder does not expose process symbols in
   * the main JITDylib by default. Install exactly one unfiltered generator so
   * this host-only constructor implements its CurrentProcess contract.
   */
  LLVMOrcDefinitionGeneratorRef generator = NULL;
  error = LLVMOrcCreateDynamicLibrarySearchGeneratorForProcess(
      &generator, LLVMOrcLLJITGetGlobalPrefix(*out_jit), NULL, NULL);
  moonbit_bytes_t generator_message =
      llvm_mbt_orc_take_error(error, out_failed);
  if (*out_failed) {
    LLVMBool dispose_failed = 0;
    llvm_mbt_orc_take_error(LLVMOrcDisposeLLJIT(*out_jit), &dispose_failed);
    *out_jit = NULL;
    return generator_message;
  }
  LLVMOrcJITDylibAddGenerator(LLVMOrcLLJITGetMainJITDylib(*out_jit),
                              generator);
  return generator_message;
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

/*
 * MoonBit extern: __llvm_orc_create_thread_safe_module_from_bitcode
 * (internal/raw/Orc.mbt). The MoonBit bytes are borrowed. This function builds
 * a fresh LLVMContext/Module graph, transfers the context to a
 * ThreadSafeContext and the module to a ThreadSafeModule, then releases its
 * direct ThreadSafeContext reference. On failure all resources created so far
 * are disposed before returning.
 */
moonbit_bytes_t llvm_mbt_orc_create_thread_safe_module_from_bitcode(
    moonbit_bytes_t bitcode, LLVMOrcThreadSafeModuleRef *out_module,
    LLVMBool *out_failed) {
  *out_module = NULL;
  size_t length = (size_t)Moonbit_array_length(bitcode);
  LLVMContextRef context = LLVMContextCreate();
  if (context == NULL) {
    *out_failed = 1;
    return llvm_mbt_orc_copy_z("LLVMContextCreate returned NULL");
  }

  LLVMMemoryBufferRef buffer = LLVMCreateMemoryBufferWithMemoryRangeCopy(
      (const char *)bitcode, length, "llvm.mbt JIT snapshot");
  if (buffer == NULL) {
    LLVMContextDispose(context);
    *out_failed = 1;
    return llvm_mbt_orc_copy_z(
        "LLVMCreateMemoryBufferWithMemoryRangeCopy returned NULL");
  }

  LLVMModuleRef module = NULL;
  LLVMBool parse_failed =
      LLVMParseBitcodeInContext2(context, buffer, &module);
  LLVMDisposeMemoryBuffer(buffer);
  if (parse_failed || module == NULL) {
    if (module != NULL) {
      LLVMDisposeModule(module);
    }
    LLVMContextDispose(context);
    *out_failed = 1;
    return llvm_mbt_orc_copy_z("LLVM could not parse the bitcode snapshot");
  }

  LLVMOrcThreadSafeContextRef thread_safe_context =
      LLVMOrcCreateNewThreadSafeContextFromLLVMContext(context);
  if (thread_safe_context == NULL) {
    LLVMDisposeModule(module);
    LLVMContextDispose(context);
    *out_failed = 1;
    return llvm_mbt_orc_copy_z(
        "LLVMOrcCreateNewThreadSafeContextFromLLVMContext returned NULL");
  }

  *out_module = LLVMOrcCreateNewThreadSafeModule(module, thread_safe_context);
  LLVMOrcDisposeThreadSafeContext(thread_safe_context);
  if (*out_module == NULL) {
    /* LLVMOrcCreateNewThreadSafeModule takes module ownership on entry. */
    *out_failed = 1;
    return llvm_mbt_orc_copy_z(
        "LLVMOrcCreateNewThreadSafeModule returned NULL");
  }

  *out_failed = 0;
  return moonbit_make_bytes(0, 0);
}

/*
 * MoonBit extern: __llvm_orc_lljit_add_llvm_ir_module
 * (internal/raw/LLJIT.mbt). LLVM consumes `module` once this call is entered,
 * on both success and failure. The caller must never dispose it afterward.
 */
moonbit_bytes_t llvm_mbt_orc_lljit_add_llvm_ir_module(
    LLVMOrcLLJITRef jit, LLVMOrcThreadSafeModuleRef module,
    LLVMBool *out_failed) {
  LLVMOrcJITDylibRef jit_dylib = LLVMOrcLLJITGetMainJITDylib(jit);
  return llvm_mbt_orc_take_error(
      LLVMOrcLLJITAddLLVMIRModule(jit, jit_dylib, module), out_failed);
}

/*
 * MoonBit extern: __llvm_orc_lljit_add_llvm_ir_module_with_rt
 * (internal/raw/LLJIT.mbt). `tracker` is borrowed and must belong to `jit`;
 * `module` is consumed by LLVM once this call is entered on every outcome.
 */
moonbit_bytes_t llvm_mbt_orc_lljit_add_llvm_ir_module_with_rt(
    LLVMOrcLLJITRef jit, LLVMOrcResourceTrackerRef tracker,
    LLVMOrcThreadSafeModuleRef module, LLVMBool *out_failed) {
  return llvm_mbt_orc_take_error(
      LLVMOrcLLJITAddLLVMIRModuleWithRT(jit, tracker, module), out_failed);
}

/*
 * MoonBit extern: __llvm_orc_resource_tracker_remove
 * (internal/raw/Orc.mbt). `tracker` remains a client-owned reference after the
 * resources are removed and still requires LLVMOrcReleaseResourceTracker.
 */
moonbit_bytes_t llvm_mbt_orc_resource_tracker_remove(
    LLVMOrcResourceTrackerRef tracker, LLVMBool *out_failed) {
  return llvm_mbt_orc_take_error(LLVMOrcResourceTrackerRemove(tracker),
                                 out_failed);
}
