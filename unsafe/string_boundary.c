#include <llvm-c/Core.h>
#include <llvm-c/DebugInfo.h>
#include <llvm-c/Error.h>
#include <llvm-c/ExecutionEngine.h>
#include <llvm-c/IRReader.h>
#include <llvm-c/Remarks.h>
#include <llvm-c/Target.h>
#include <llvm-c/TargetMachine.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef memcpy
#undef memcpy
#endif
#include "moonbit.h"

static moonbit_bytes_t llvm_mbt_copy_bytes(const char *ptr, size_t length) {
  if (length > (size_t)INT32_MAX) {
    fputs("LLVM string is too large for MoonBit Bytes\n", stderr);
    abort();
  }
  moonbit_bytes_t bytes = moonbit_make_bytes((int32_t)length, 0);
  if (length != 0) {
    memcpy(bytes, ptr, length);
  }
  return bytes;
}

static moonbit_bytes_t llvm_mbt_copy_z(const char *ptr) {
  return llvm_mbt_copy_bytes(ptr, strlen(ptr));
}

LLVMErrorRef llvm_mbt_create_embedded_nul_error(void) {
  return LLVMCreateStringError("MoonBit string contains an embedded NUL");
}

/* Managed strings owned by LLVM or libc. */

struct llvm_mbt_owned_cstring {
  char *ptr;
};

static void llvm_mbt_finalize_llvm_message(void *payload) {
  struct llvm_mbt_owned_cstring *message = payload;
  if (message->ptr != NULL) {
    LLVMDisposeMessage(message->ptr);
    message->ptr = NULL;
  }
}

static void llvm_mbt_finalize_llvm_error_message(void *payload) {
  struct llvm_mbt_owned_cstring *message = payload;
  if (message->ptr != NULL) {
    LLVMDisposeErrorMessage(message->ptr);
    message->ptr = NULL;
  }
}

static void llvm_mbt_finalize_libc_cstring(void *payload) {
  struct llvm_mbt_owned_cstring *message = payload;
  if (message->ptr != NULL) {
    free(message->ptr);
    message->ptr = NULL;
  }
}

static void *llvm_mbt_make_owned_cstring(
    char *ptr, void (*finalize)(void *)) {
  struct llvm_mbt_owned_cstring *message = moonbit_make_external_object(
      finalize, (uint32_t)sizeof(struct llvm_mbt_owned_cstring));
  message->ptr = ptr;
  return message;
}

static void *llvm_mbt_make_llvm_message(char *ptr) {
  return llvm_mbt_make_owned_cstring(ptr, llvm_mbt_finalize_llvm_message);
}

static void *llvm_mbt_make_llvm_error_message(char *ptr) {
  return llvm_mbt_make_owned_cstring(ptr,
                                     llvm_mbt_finalize_llvm_error_message);
}

static void *llvm_mbt_make_libc_cstring(char *ptr) {
  return llvm_mbt_make_owned_cstring(ptr, llvm_mbt_finalize_libc_cstring);
}

moonbit_bytes_t llvm_mbt_llvm_message_copy_bytes(
    struct llvm_mbt_owned_cstring *message) {
  return llvm_mbt_copy_z(message->ptr);
}

moonbit_bytes_t llvm_mbt_llvm_error_message_copy_bytes(
    struct llvm_mbt_owned_cstring *message) {
  return llvm_mbt_copy_z(message->ptr);
}

moonbit_bytes_t llvm_mbt_libc_cstring_copy_bytes(
    struct llvm_mbt_owned_cstring *message) {
  return llvm_mbt_copy_z(message->ptr);
}

void *llvm_mbt_print_module_to_string(LLVMModuleRef module) {
  return llvm_mbt_make_llvm_message(LLVMPrintModuleToString(module));
}

void *llvm_mbt_get_error_message(LLVMErrorRef error) {
  return llvm_mbt_make_llvm_error_message(LLVMGetErrorMessage(error));
}

void *llvm_mbt_get_diag_info_description(LLVMDiagnosticInfoRef diagnostic) {
  return llvm_mbt_make_llvm_message(LLVMGetDiagInfoDescription(diagnostic));
}

void *llvm_mbt_print_type_to_string(LLVMTypeRef type) {
  return llvm_mbt_make_llvm_message(LLVMPrintTypeToString(type));
}

void *llvm_mbt_print_value_to_string(LLVMValueRef value) {
  return llvm_mbt_make_llvm_message(LLVMPrintValueToString(value));
}

void *llvm_mbt_print_dbg_record_to_string(LLVMDbgRecordRef record) {
  return llvm_mbt_make_llvm_message(LLVMPrintDbgRecordToString(record));
}

void *llvm_mbt_intrinsic_copy_overloaded_name(
    unsigned id, LLVMTypeRef *parameter_types, unsigned parameter_count) {
  size_t name_length = 0;
  char *name = LLVMIntrinsicCopyOverloadedName(
      id, parameter_types, (size_t)parameter_count, &name_length);
  return llvm_mbt_make_libc_cstring(name);
}

void *llvm_mbt_intrinsic_copy_overloaded_name2(
    LLVMModuleRef module, unsigned id, LLVMTypeRef *parameter_types,
    unsigned parameter_count) {
  size_t name_length = 0;
  char *name = LLVMIntrinsicCopyOverloadedName2(
      module, id, parameter_types, (size_t)parameter_count, &name_length);
  return llvm_mbt_make_libc_cstring(name);
}

/* Borrowed LLVM strings copied before their owners can change. */

moonbit_bytes_t llvm_mbt_get_string_attribute_kind(
    LLVMAttributeRef attribute) {
  unsigned length = 0;
  const char *data = LLVMGetStringAttributeKind(attribute, &length);
  return llvm_mbt_copy_bytes(data, (size_t)length);
}

moonbit_bytes_t llvm_mbt_get_string_attribute_value(
    LLVMAttributeRef attribute) {
  unsigned length = 0;
  const char *data = LLVMGetStringAttributeValue(attribute, &length);
  return llvm_mbt_copy_bytes(data, (size_t)length);
}

moonbit_bytes_t llvm_mbt_get_module_identifier(LLVMModuleRef module) {
  size_t length = 0;
  const char *data = LLVMGetModuleIdentifier(module, &length);
  return llvm_mbt_copy_bytes(data, length);
}

moonbit_bytes_t llvm_mbt_get_source_file_name(LLVMModuleRef module) {
  size_t length = 0;
  const char *data = LLVMGetSourceFileName(module, &length);
  return llvm_mbt_copy_bytes(data, length);
}

moonbit_bytes_t llvm_mbt_get_data_layout_str(LLVMModuleRef module) {
  return llvm_mbt_copy_z(LLVMGetDataLayoutStr(module));
}

moonbit_bytes_t llvm_mbt_get_module_target(LLVMModuleRef module) {
  return llvm_mbt_copy_z(LLVMGetTarget(module));
}

moonbit_bytes_t llvm_mbt_get_module_inline_asm(LLVMModuleRef module) {
  size_t length = 0;
  const char *data = LLVMGetModuleInlineAsm(module, &length);
  return llvm_mbt_copy_bytes(data, length);
}

moonbit_bytes_t llvm_mbt_get_inline_asm_asm_string(LLVMValueRef value) {
  size_t length = 0;
  const char *data = LLVMGetInlineAsmAsmString(value, &length);
  return llvm_mbt_copy_bytes(data, length);
}

moonbit_bytes_t llvm_mbt_get_inline_asm_constraint_string(
    LLVMValueRef value) {
  size_t length = 0;
  const char *data = LLVMGetInlineAsmConstraintString(value, &length);
  return llvm_mbt_copy_bytes(data, length);
}

moonbit_bytes_t llvm_mbt_get_named_metadata_name(
    LLVMNamedMDNodeRef metadata) {
  size_t length = 0;
  const char *data = LLVMGetNamedMetadataName(metadata, &length);
  return llvm_mbt_copy_bytes(data, length);
}

moonbit_bytes_t llvm_mbt_get_debug_loc_directory(LLVMValueRef value) {
  unsigned length = 0;
  const char *data = LLVMGetDebugLocDirectory(value, &length);
  return llvm_mbt_copy_bytes(data, (size_t)length);
}

moonbit_bytes_t llvm_mbt_get_debug_loc_filename(LLVMValueRef value) {
  unsigned length = 0;
  const char *data = LLVMGetDebugLocFilename(value, &length);
  return llvm_mbt_copy_bytes(data, (size_t)length);
}

moonbit_bytes_t llvm_mbt_get_value_name(LLVMValueRef value) {
  size_t length = 0;
  const char *data = LLVMGetValueName2(value, &length);
  return llvm_mbt_copy_bytes(data, length);
}

moonbit_bytes_t llvm_mbt_get_struct_name(LLVMTypeRef type) {
  const char *data = LLVMGetStructName(type);
  return data == NULL ? moonbit_make_bytes(0, 0) : llvm_mbt_copy_z(data);
}

moonbit_bytes_t llvm_mbt_get_target_ext_type_name(LLVMTypeRef type) {
  return llvm_mbt_copy_z(LLVMGetTargetExtTypeName(type));
}

moonbit_bytes_t llvm_mbt_get_section(LLVMValueRef global) {
  const char *data = LLVMGetSection(global);
  return data == NULL ? moonbit_make_bytes(0, 0) : llvm_mbt_copy_z(data);
}

moonbit_bytes_t llvm_mbt_intrinsic_get_name(unsigned id) {
  size_t length = 0;
  const char *data = LLVMIntrinsicGetName(id, &length);
  return llvm_mbt_copy_bytes(data, length);
}

moonbit_bytes_t llvm_mbt_get_gc(LLVMValueRef function) {
  const char *data = LLVMGetGC(function);
  return data == NULL ? moonbit_make_bytes(0, 0) : llvm_mbt_copy_z(data);
}

moonbit_bytes_t llvm_mbt_get_operand_bundle_tag(LLVMOperandBundleRef bundle) {
  size_t length = 0;
  const char *data = LLVMGetOperandBundleTag(bundle, &length);
  return llvm_mbt_copy_bytes(data, length);
}

moonbit_bytes_t llvm_mbt_get_basic_block_name(LLVMBasicBlockRef block) {
  return llvm_mbt_copy_z(LLVMGetBasicBlockName(block));
}

moonbit_bytes_t llvm_mbt_get_target_name(LLVMTargetRef target) {
  return llvm_mbt_copy_z(LLVMGetTargetName(target));
}

moonbit_bytes_t llvm_mbt_get_target_description(LLVMTargetRef target) {
  return llvm_mbt_copy_z(LLVMGetTargetDescription(target));
}

moonbit_bytes_t llvm_mbt_remark_string_get_data(LLVMRemarkStringRef string) {
  const char *data = LLVMRemarkStringGetData(string);
  return llvm_mbt_copy_bytes(data, (size_t)LLVMRemarkStringGetLen(string));
}

moonbit_bytes_t llvm_mbt_di_file_get_directory(LLVMMetadataRef file) {
  unsigned length = 0;
  const char *data = LLVMDIFileGetDirectory(file, &length);
  return llvm_mbt_copy_bytes(data, (size_t)length);
}

moonbit_bytes_t llvm_mbt_di_file_get_filename(LLVMMetadataRef file) {
  unsigned length = 0;
  const char *data = LLVMDIFileGetFilename(file, &length);
  return llvm_mbt_copy_bytes(data, (size_t)length);
}

moonbit_bytes_t llvm_mbt_di_file_get_source(LLVMMetadataRef file) {
  unsigned length = 0;
  const char *data = LLVMDIFileGetSource(file, &length);
  return llvm_mbt_copy_bytes(data, (size_t)length);
}

moonbit_bytes_t llvm_mbt_di_type_get_name(LLVMMetadataRef type) {
  size_t length = 0;
  const char *data = LLVMDITypeGetName(type, &length);
  return llvm_mbt_copy_bytes(data, length);
}

/* Operation-result messages copied and disposed in the same C call. */

moonbit_bytes_t llvm_mbt_get_target_from_triple(
    const char *triple, LLVMTargetRef *out_target, LLVMBool *out_failed) {
  char *message = NULL;
  *out_failed = LLVMGetTargetFromTriple(triple, out_target, &message);
  if (message == NULL) {
    return moonbit_make_bytes(0, 0);
  }
  moonbit_bytes_t result = llvm_mbt_copy_z(message);
  LLVMDisposeMessage(message);
  return result;
}

moonbit_bytes_t llvm_mbt_parse_ir_in_context(
    LLVMContextRef context, LLVMMemoryBufferRef buffer,
    LLVMModuleRef *out_module, LLVMBool *out_failed) {
  char *message = NULL;
  *out_failed = LLVMParseIRInContext(context, buffer, out_module, &message);
  if (message == NULL) {
    return moonbit_make_bytes(0, 0);
  }
  moonbit_bytes_t result = llvm_mbt_copy_z(message);
  LLVMDisposeMessage(message);
  return result;
}

static moonbit_bytes_t llvm_mbt_create_execution_engine_common(
    LLVMModuleRef module, LLVMExecutionEngineRef *out_engine,
    LLVMBool *out_failed, LLVMBool interpreter) {
  char *message = NULL;
  if (interpreter) {
    *out_failed =
        LLVMCreateInterpreterForModule(out_engine, module, &message);
  } else {
    *out_failed =
        LLVMCreateExecutionEngineForModule(out_engine, module, &message);
  }
  if (message == NULL) {
    return moonbit_make_bytes(0, 0);
  }
  moonbit_bytes_t result = llvm_mbt_copy_z(message);
  LLVMDisposeMessage(message);
  return result;
}

moonbit_bytes_t llvm_mbt_create_execution_engine_for_module(
    LLVMExecutionEngineRef *out_engine, LLVMModuleRef module,
    LLVMBool *out_failed) {
  return llvm_mbt_create_execution_engine_common(module, out_engine,
                                                  out_failed, 0);
}

moonbit_bytes_t llvm_mbt_create_interpreter_for_module(
    LLVMExecutionEngineRef *out_engine, LLVMModuleRef module,
    LLVMBool *out_failed) {
  return llvm_mbt_create_execution_engine_common(module, out_engine,
                                                  out_failed, 1);
}
