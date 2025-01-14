#include <llvm-c/Analysis.h>
#include <llvm-c/BitWriter.h>
#include <llvm-c/Core.h>
#include <llvm-c/ExecutionEngine.h>
#include <llvm-c/Target.h>

#include "moonbit.h"
#include <stdio.h>
#include <stdlib.h>

/**
 * Create a new context.
 *
 * Every call to this function should be paired with a call to
 * LLVMContextDispose() or the context will leak memory.
 */
void *__llvm_context_create() { return LLVMContextCreate(); }

/**
 * @defgroup LLVMCCoreTypeInt Integer Types
 *
 * Functions in this section operate on integer types.
 *
 * @{
 */

/**
 * Obtain an integer type from a context with specified bit width.
 */
void *__llvm_int1_type_in_context(void *context) {
  return LLVMInt1TypeInContext((LLVMContextRef)context);
}
void *__llvm_int8_type_in_context(void *context) {
  return LLVMInt8TypeInContext((LLVMContextRef)context);
}
void *__llvm_int16_type_in_context(void *context) {
  return LLVMInt16TypeInContext((LLVMContextRef)context);
}
void *__llvm_int32_type_in_context(void *context) {
  return LLVMInt32TypeInContext((LLVMContextRef)context);
}
void *__llvm_int64_type_in_context(void *context) {
  return LLVMInt64TypeInContext((LLVMContextRef)context);
}
void *__llvm_int128_type_in_context(void *context) {
  return LLVMInt128TypeInContext((LLVMContextRef)context);
}
void *__llvm_int_type_in_context(void *context, unsigned num_bits) {
  return LLVMIntTypeInContext((LLVMContextRef)context, num_bits);
}

/**
 * Obtain an integer type from the global context with a specified bit
 * width.
 */
void *__llvm_int1_type() { return LLVMInt1Type(); }
void *__llvm_int8_type() { return LLVMInt8Type(); }
void *__llvm_int16_type() { return LLVMInt16Type(); }
void *__llvm_int32_type() { return LLVMInt32Type(); }
void *__llvm_int64_type() { return LLVMInt64Type(); }
void *__llvm_int128_type() { return LLVMInt128Type(); }
void *__llvm_int_type(unsigned num_bits) { return LLVMIntType(num_bits); }
unsigned __llvm_get_int_type_width(void *integer_ty) {
  return LLVMGetIntTypeWidth((LLVMTypeRef)integer_ty);
}

/**
 * Determine whether a type instance is null.
 */
LLVMBool __llvm_type_is_null(void *type_ref) {
  return type_ref == NULL ? 1 : 0;
}

/**
 * Dump a representation of a type to stderr.
 *
 * @see llvm::Type::dump()
 */
void __llvm_dump_type(void *val) { LLVMDumpType((LLVMTypeRef)val); }

/**
 * Return a string representation of the type. Use
 * LLVMDisposeMessage to free the string.
 *
 * @see llvm::Type::print()
 */
void *__llvm_print_type_to_string(void *val) {
  return LLVMPrintTypeToString((LLVMTypeRef)val);
}

/**
 * Dump a representation of a value to stderr.
 *
 * @see llvm::Value::dump()
 */
void __llvm_dump_value(void *val_ref) { LLVMDumpValue((LLVMValueRef)val_ref); }

/**
 * Return a string representation of the value. Use
 * LLVMDisposeMessage to free the string.
 *
 * @see llvm::Value::print()
 */
void *__llvm_print_value_to_string(void *val_ref) {
  return LLVMPrintValueToString((LLVMValueRef)val_ref);
}

/**
 * Determine whether a value instance is null.
 *
 * @see llvm::Constant::isNullValue()
 */
LLVMBool __llvm_is_null(void *val_ref) {
  return LLVMIsNull((LLVMValueRef)val_ref);
}

/**
 * Determine whether the specified value instance is constant.
 */
LLVMBool llvm_is_const(void *val_ref) {
  return LLVMIsConstant((LLVMValueRef)val_ref);
}

/**
 * Obtain a constant value for an integer type.
 *
 * The returned value corresponds to a llvm::ConstantInt.
 *
 * @see llvm::ConstantInt::get()
 *
 * @param IntTy Integer type to obtain value of.
 * @param N The value the returned instance should refer to.
 * @param SignExtend Whether to sign extend the produced value.
 */
void *__llvm_const_int(void *IntTy, unsigned long long N, LLVMBool SignExtend) {
  return LLVMConstInt((LLVMTypeRef)IntTy, N, SignExtend);
}

/**
 * Set the string name of a value.
 *
 * @see llvm::Value::setName()
 */
void __llvm_set_value_name(void *val_ref, void *name, size_t name_len) {
  LLVMSetValueName2((LLVMValueRef)val_ref, (const char *)name, name_len);
}
