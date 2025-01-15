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
 * @}
 */

/**
 * @defgroup LLVMCCoreTypeFloat Floating Point Types
 *
 * @{
 */

/**
 * Obtain a 16-bit floating point type from a context.
 */
void *__llvm_half_type_in_context(void *context) {
  return LLVMHalfTypeInContext((LLVMContextRef)context);
}

/**
 * Obtain a 16-bit brain floating point type from a context.
 */
void *__llvm_bfloat_type_in_context(void *context) {
  return LLVMBFloatTypeInContext((LLVMContextRef)context);
}

/**
 * Obtain a 32-bit floating point type from a context.
 */
void *__llvm_float_type_in_context(void *context) {
  return LLVMFloatTypeInContext((LLVMContextRef)context);
}

/**
 * Obtain a 64-bit floating point type from a context.
 */
void *__llvm_double_type_in_context(void *context) {
  return LLVMDoubleTypeInContext((LLVMContextRef)context);
}

/**
 * Obtain a 80-bit floating point type (X87) from a context.
 */
void *__llvm_x86fp80_type_in_context(void *context) {
  return LLVMX86FP80TypeInContext((LLVMContextRef)context);
}

/**
 * Obtain a 128-bit floating point type (112-bit mantissa) from a
 * context.
 */
void *__llvm_fp128_type_in_context(void *context) {
  return LLVMFP128TypeInContext((LLVMContextRef)context);
}

/**
 * Obtain a 128-bit floating point type (two 64-bits) from a context.
 */
void *__llvm_ppcfp128_type_in_context(void *context) {
  return LLVMPPCFP128TypeInContext((LLVMContextRef)context);
}

/**
 * Obtain a floating point type from the global context.
 *
 * These map to the functions in this group of the same name.
 */
void *__llvm_half_type() { return LLVMHalfType(); }
void *__llvm_bfloat_type() { return LLVMBFloatType(); }
void *__llvm_float_type() { return LLVMFloatType(); }
void *__llvm_double_type() { return LLVMDoubleType(); }
void *__llvm_x86fp80_type() { return LLVMX86FP80Type(); }
void *__llvm_fp128_type() { return LLVMFP128Type(); }
void *__llvm_ppcfp128_type() { return LLVMPPCFP128Type(); }

/**
 * @}
 */

/**
 * @defgroup LLVMCCoreTypeFunction Function Types
 *
 * @{
 */

/**
 * Obtain a function type consisting of a specified signature.
 *
 * The function is defined as a tuple of a return Type, a list of
 * parameter types, and whether the function is variadic.
 */
// void* __llvm_function_type()

/**
 * Returns whether a function type is variadic.
 */
LLVMBool __llvm_is_function_var_arg(void *function_ty) {
  return LLVMIsFunctionVarArg((LLVMTypeRef)function_ty);
}

/**
 * Obtain the Type this function Type returns.
 */
void *__llvm_get_return_type(void *function_ty) {
  return LLVMGetReturnType((LLVMTypeRef)function_ty);
}

/**
 * Obtain the number of parameters this function accepts.
 */
unsigned __llvm_count_param_types(void *function_ty) {
  return LLVMCountParamTypes((LLVMTypeRef)function_ty);
}

/**
 * Obtain the types of a function's parameters.
 *
 * The Dest parameter should point to a pre-allocated array of
 * LLVMTypeRef at least LLVMCountParamTypes() large. On return, the
 * first LLVMCountParamTypes() entries in the array will be populated
 * with LLVMTypeRef instances.
 *
 * @param FunctionTy The function type to operate on.
 * @param Dest Memory address of an array to be filled with result.
 */
// void __llvm_get_param_types(void* function_ty, void* param_types);

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

// ============================
// Struct Type and Array Type and Vector Type
// ============================

/**
 * Create a void type in a context.
 */
void *__llvm_void_type_in_context(void *context) {
  return LLVMVoidTypeInContext((LLVMContextRef)context);
}

/**
 * Create a label type in a context.
 */
void *__llvm_lable_type_in_context(void *context) {
  return LLVMLabelTypeInContext((LLVMContextRef)context);
}

/**
 * Create a X86 MMX type in a context.
 */
void *__llvm_x86mmx_type_in_context(void *context) {
  return LLVMX86MMXTypeInContext((LLVMContextRef)context);
}

/**
 * Create a X86 AMX type in a context.
 */
void *__llvm_x86amx_type_in_context(void *context) {
  return LLVMX86AMXTypeInContext((LLVMContextRef)context);
}
/**
 * Create a token type in a context.
 */
void *__llvm_token_type_in_context(void *context) {
  return LLVMTokenTypeInContext((LLVMContextRef)context);
}
/**
 * Create a metadata type in a context.
 */
void *__llvm_metadata_type_in_context(void *context) {
  return LLVMMetadataTypeInContext((LLVMContextRef)context);
}

/**
 * These are similar to the above functions except they operate on the
 * global context.
 */
void *__llvm_void_type() { return LLVMVoidType(); }
void *__llvm_label_type() { return LLVMLabelType(); }
void *__llvm_x86mmx_type() { return LLVMX86MMXType(); }
void *__llvm_x86amx_type() { return LLVMX86AMXType(); }

// ========================
// Target Ext
// ========================

void *__llvm_type_of(void *val_ref) {
  return LLVMTypeOf((LLVMValueRef)val_ref);
}

/**
 * Set the string name of a value.
 *
 * @see llvm::Value::setName()
 */
void __llvm_set_value_name(void *val_ref, void *name, size_t name_len) {
  LLVMSetValueName2((LLVMValueRef)val_ref, (const char *)name, name_len);
}

// void* __llvm_get_value_name(void* )

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
 * Return a string representation of the DbgRecord. Use
 * LLVMDisposeMessage to free the string.
 *
 * @see llvm::DbgRecord::print()
 */
void *__llvm_print_dbg_record_to_string(void *record) {
  return (char *)LLVMPrintDbgRecordToString((LLVMDbgRecordRef)record);
}

/**
 * Replace all uses of a value with another one.
 *
 * @see llvm::Value::replaceAllUsesWith()
 */
void __llvm_replace_all_uses_with(void *old_val, void *new_val) {
  LLVMReplaceAllUsesWith((LLVMValueRef)old_val, (LLVMValueRef)new_val);
}

/**
 * Determine whether the specified value instance is constant.
 */
LLVMBool llvm_is_const(void *val_ref) {
  return LLVMIsConstant((LLVMValueRef)val_ref);
}

/**
 * Determine whether a value instance is undefined.
 */
LLVMBool __llvm_is_undef(void *val_ref) {
  return LLVMIsUndef((LLVMValueRef)val_ref);
}

/**
 * Determine whether a value instance is poisonous.
 */
LLVMBool __llvm_is_poison(void *val_ref) {
  return LLVMIsPoison((LLVMValueRef)val_ref);
}

/**
 * Convert value instances between types.
 *
 * Internally, an LLVMValueRef is "pinned" to a specific type. This
 * series of functions allows you to cast an instance to a specific
 * type.
 *
 * If the cast is not valid for the specified type, NULL is returned.
 *
 * @see llvm::dyn_cast_or_null<>
 */
void *__llvm_isa_argument(void *val) {
  return (LLVMValueRef)LLVMIsAArgument((LLVMValueRef)val);
}

void *__llvm_isa_basic_block(void *val) {
  return (LLVMValueRef)LLVMIsABasicBlock((LLVMValueRef)val);
}

void *__llvm_isa_inline_asm(void *val) {
  return (LLVMValueRef)LLVMIsAInlineAsm((LLVMValueRef)val);
}

void *__llvm_isa_user(void *val) {
  return (LLVMValueRef)LLVMIsAUser((LLVMValueRef)val);
}

void *__llvm_isa_constant(void *val) {
  return (LLVMValueRef)LLVMIsAConstant((LLVMValueRef)val);
}

void *__llvm_isa_block_address(void *val) {
  return (LLVMValueRef)LLVMIsABlockAddress((LLVMValueRef)val);
}

void *__llvm_isa_constant_aggregate_zero(void *val) {
  return (LLVMValueRef)LLVMIsAConstantAggregateZero((LLVMValueRef)val);
}

void *__llvm_isa_constant_array(void *val) {
  return (LLVMValueRef)LLVMIsAConstantArray((LLVMValueRef)val);
}

void *__llvm_isa_constant_data_sequential(void *val) {
  return (LLVMValueRef)LLVMIsAConstantDataSequential((LLVMValueRef)val);
}

void *__llvm_isa_constant_data_array(void *val) {
  return (LLVMValueRef)LLVMIsAConstantDataArray((LLVMValueRef)val);
}

void *__llvm_isa_constant_data_vector(void *val) {
  return (LLVMValueRef)LLVMIsAConstantDataVector((LLVMValueRef)val);
}

void *__llvm_isa_constant_expr(void *val) {
  return (LLVMValueRef)LLVMIsAConstantExpr((LLVMValueRef)val);
}

void *__llvm_isa_constant_fp(void *val) {
  return (LLVMValueRef)LLVMIsAConstantFP((LLVMValueRef)val);
}

void *__llvm_isa_constant_int(void *val) {
  return (LLVMValueRef)LLVMIsAConstantInt((LLVMValueRef)val);
}

void *__llvm_isa_constant_pointer_null(void *val) {
  return (LLVMValueRef)LLVMIsAConstantPointerNull((LLVMValueRef)val);
}

void *__llvm_isa_constant_struct(void *val) {
  return (LLVMValueRef)LLVMIsAConstantStruct((LLVMValueRef)val);
}

void *__llvm_isa_constant_token_none(void *val) {
  return (LLVMValueRef)LLVMIsAConstantTokenNone((LLVMValueRef)val);
}

void *__llvm_isa_constant_vector(void *val) {
  return (LLVMValueRef)LLVMIsAConstantVector((LLVMValueRef)val);
}

void *__llvm_isa_global_value(void *val) {
  return (LLVMValueRef)LLVMIsAGlobalValue((LLVMValueRef)val);
}

void *__llvm_isa_global_alias(void *val) {
  return (LLVMValueRef)LLVMIsAGlobalAlias((LLVMValueRef)val);
}

void *__llvm_isa_global_object(void *val) {
  return (LLVMValueRef)LLVMIsAGlobalObject((LLVMValueRef)val);
}

void *__llvm_isa_function(void *val) {
  return (LLVMValueRef)LLVMIsAFunction((LLVMValueRef)val);
}

void *__llvm_isa_global_variable(void *val) {
  return (LLVMValueRef)LLVMIsAGlobalVariable((LLVMValueRef)val);
}

void *__llvm_isa_global_ifunc(void *val) {
  return (LLVMValueRef)LLVMIsAGlobalIFunc((LLVMValueRef)val);
}

void *__llvm_isa_undef_value(void *val) {
  return (LLVMValueRef)LLVMIsAUndefValue((LLVMValueRef)val);
}

void *__llvm_isa_poison_value(void *val) {
  return (LLVMValueRef)LLVMIsAPoisonValue((LLVMValueRef)val);
}

void *__llvm_isa_instruction(void *val) {
  return (LLVMValueRef)LLVMIsAInstruction((LLVMValueRef)val);
}

void *__llvm_isa_unary_operator(void *val) {
  return (LLVMValueRef)LLVMIsAUnaryOperator((LLVMValueRef)val);
}

void *__llvm_isa_binary_operator(void *val) {
  return (LLVMValueRef)LLVMIsABinaryOperator((LLVMValueRef)val);
}

void *__llvm_isa_call_inst(void *val) {
  return (LLVMValueRef)LLVMIsACallInst((LLVMValueRef)val);
}

void *__llvm_isa_intrinsic_inst(void *val) {
  return (LLVMValueRef)LLVMIsAIntrinsicInst((LLVMValueRef)val);
}

void *__llvm_isa_dbg_info_intrinsic(void *val) {
  return (LLVMValueRef)LLVMIsADbgInfoIntrinsic((LLVMValueRef)val);
}

void *__llvm_isa_dbg_variable_intrinsic(void *val) {
  return (LLVMValueRef)LLVMIsADbgVariableIntrinsic((LLVMValueRef)val);
}

void *__llvm_isa_dbg_declare_inst(void *val) {
  return (LLVMValueRef)LLVMIsADbgDeclareInst((LLVMValueRef)val);
}

void *__llvm_dbg_label_inst(void *val) {
  return (LLVMValueRef)LLVMIsADbgLabelInst((LLVMValueRef)val);
}

void *__llvm_isa_mem_intrinsic(void *val) {
  return (LLVMValueRef)LLVMIsAMemIntrinsic((LLVMValueRef)val);
}

void *__llvm_isa_mem_cpy_inst(void *val) {
  return (LLVMValueRef)LLVMIsAMemCpyInst((LLVMValueRef)val);
}

void *__llvm_isa_mem_move_inst(void *val) {
  return (LLVMValueRef)LLVMIsAMemMoveInst((LLVMValueRef)val);
}

void *__llvm_isa_mem_set_inst(void *val) {
  return (LLVMValueRef)LLVMIsAMemSetInst((LLVMValueRef)val);
}

void *__llvm_isa_cmp_inst(void *val) {
  return (LLVMValueRef)LLVMIsACmpInst((LLVMValueRef)val);
}

void *__llvm_isa_fcmp_inst(void *val) {
  return (LLVMValueRef)LLVMIsAFCmpInst((LLVMValueRef)val);
}

void *__llvm_isa_icmp_inst(void *val) {
  return (LLVMValueRef)LLVMIsAICmpInst((LLVMValueRef)val);
}

void *__llvm_isa_extract_element_inst(void *val) {
  return (LLVMValueRef)LLVMIsAExtractElementInst((LLVMValueRef)val);
}

void *__llvm_isa_get_element_ptr_inst(void *val) {
  return (LLVMValueRef)LLVMIsAGetElementPtrInst((LLVMValueRef)val);
}

void *__llvm_insert_element_ptr_inst(void *val) {
  return (LLVMValueRef)LLVMIsAInsertElementInst((LLVMValueRef)val);
}

void *__llvm_isa_insert_value_inst(void *val) {
  return (LLVMValueRef)LLVMIsAInsertValueInst((LLVMValueRef)val);
}

void *__llvm_isa_landing_pad_inst(void *val) {
  return (LLVMValueRef)LLVMIsALandingPadInst((LLVMValueRef)val);
}

void *__llvm_isa_phi_node(void *val) {
  return (LLVMValueRef)LLVMIsAPHINode((LLVMValueRef)val);
}

void *__llvm_isa_select_inst(void *val) {
  return (LLVMValueRef)LLVMIsASelectInst((LLVMValueRef)val);
}

void *__llvm_isa_shuffle_vector_inst(void *val) {
  return (LLVMValueRef)LLVMIsAShuffleVectorInst((LLVMValueRef)val);
}

void *__llvm_isa_store_inst(void *val) {
  return (LLVMValueRef)LLVMIsAStoreInst((LLVMValueRef)val);
}

void *__llvm_isa_branch_inst(void *val) {
  return (LLVMValueRef)LLVMIsABranchInst((LLVMValueRef)val);
}

void *__llvm_isa_indirect_br_inst(void *val) {
  return (LLVMValueRef)LLVMIsAIndirectBrInst((LLVMValueRef)val);
}

void *__llvm_isa_invoke_inst(void *val) {
  return (LLVMValueRef)LLVMIsAInvokeInst((LLVMValueRef)val);
}

void *__llvm_isa_return_inst(void *val) {
  return (LLVMValueRef)LLVMIsAReturnInst((LLVMValueRef)val);
}

void *__llvm_isa_switch_inst(void *val) {
  return (LLVMValueRef)LLVMIsASwitchInst((LLVMValueRef)val);
}

void *__llvm_isa_unreachable_inst(void *val) {
  return (LLVMValueRef)LLVMIsAUnreachableInst((LLVMValueRef)val);
}

void *__llvm_isa_resume_inst(void *val) {
  return (LLVMValueRef)LLVMIsAResumeInst((LLVMValueRef)val);
}

void *__llvm_isa_cleanup_return_inst(void *val) {
  return (LLVMValueRef)LLVMIsACleanupReturnInst((LLVMValueRef)val);
}

void *__llvm_isa_catch_return_inst(void *val) {
  return (LLVMValueRef)LLVMIsACatchReturnInst((LLVMValueRef)val);
}

void *__llvm_isa_catch_switch_inst(void *val) {
  return (LLVMValueRef)LLVMIsACatchSwitchInst((LLVMValueRef)val);
}

void *__llvm_isa_call_br_inst(void *val) {
  return (LLVMValueRef)LLVMIsACallBrInst((LLVMValueRef)val);
}

void *__llvm_isa_funclet_pad_inst(void *val) {
  return (LLVMValueRef)LLVMIsAFuncletPadInst((LLVMValueRef)val);
}

void *__llvm_isa_catch_pad_inst(void *val) {
  return (LLVMValueRef)LLVMIsACatchPadInst((LLVMValueRef)val);
}

void *__llvm_isa_cleanup_pad_inst(void *val) {
  return (LLVMValueRef)LLVMIsACleanupPadInst((LLVMValueRef)val);
}

void *__llvm_isa_unary_instruction(void *val) {
  return (LLVMValueRef)LLVMIsAUnaryInstruction((LLVMValueRef)val);
}

void *__llvm_isa_alloca_inst(void *val) {
  return (LLVMValueRef)LLVMIsAAllocaInst((LLVMValueRef)val);
}

void *__llvm_isa_cast_inst(void *val) {
  return (LLVMValueRef)LLVMIsACastInst((LLVMValueRef)val);
}

void *__llvm_isa_addr_space_cast_inst(void *val) {
  return (LLVMValueRef)LLVMIsAAddrSpaceCastInst((LLVMValueRef)val);
}

void *__llvm_isa_bit_cast_inst(void *val) {
  return (LLVMValueRef)LLVMIsABitCastInst((LLVMValueRef)val);
}

void *__llvm_isa_fp_ext_inst(void *val) {
  return (LLVMValueRef)LLVMIsAFPExtInst((LLVMValueRef)val);
}

void *__llvm_isa_fp_to_si_inst(void *val) {
  return (LLVMValueRef)LLVMIsAFPToSIInst((LLVMValueRef)val);
}

void *__llvm_isa_fp_ui_inst(void *val) {
  return (LLVMValueRef)LLVMIsAFPToUIInst((LLVMValueRef)val);
}

void *__llvm_isa_fp_trunc_inst(void *val) {
  return (LLVMValueRef)LLVMIsAFPTruncInst((LLVMValueRef)val);
}

void *__llvm_int_to_ptr_inst(void *val) {
  return (LLVMValueRef)LLVMIsAIntToPtrInst((LLVMValueRef)val);
}

void *__llvm_isa_ptr_to_int_inst(void *val) {
  return (LLVMValueRef)LLVMIsAPtrToIntInst((LLVMValueRef)val);
}

void *__llvm_isa_sext_inst(void *val) {
  return (LLVMValueRef)LLVMIsASExtInst((LLVMValueRef)val);
}

void *__llvm_isa_si_to_fp_inst(void *val) {
  return (LLVMValueRef)LLVMIsASIToFPInst((LLVMValueRef)val);
}

void *__llvm_isa_trunc_inst(void *val) {
  return (LLVMValueRef)LLVMIsATruncInst((LLVMValueRef)val);
}

void *__llvm_isa_ui_to_fp_inst(void *val) {
  return (LLVMValueRef)LLVMIsAUIToFPInst((LLVMValueRef)val);
}

void *__llvm_isa_zext_inst(void *val) {
  return (LLVMValueRef)LLVMIsAZExtInst((LLVMValueRef)val);
}

void *__llvm_isa_extract_value_inst(void *val) {
  return (LLVMValueRef)LLVMIsAExtractValueInst((LLVMValueRef)val);
}

void *__llvm_isa_load_inst(void *val) {
  return (LLVMValueRef)LLVMIsALoadInst((LLVMValueRef)val);
}

void *__llvm_isa_va_arg_inst(void *val) {
  return (LLVMValueRef)LLVMIsAVAArgInst((LLVMValueRef)val);
}

void *__llvm_isa_freeze_inst(void *val) {
  return (LLVMValueRef)LLVMIsAFreezeInst((LLVMValueRef)val);
}

void *__llvm_isa_atomic_cmp_xchg_inst(void *val) {
  return (LLVMValueRef)LLVMIsAAtomicCmpXchgInst((LLVMValueRef)val);
}

void *__llvm_isa_atomic_rmw_inst(void *val) {
  return (LLVMValueRef)LLVMIsAAtomicRMWInst((LLVMValueRef)val);
}

void *__llvm_isa_fence_inst(void *val) {
  return (LLVMValueRef)LLVMIsAFenceInst((LLVMValueRef)val);
}

void *__llvm_isa_md_node(void *val) {
  return (LLVMValueRef)LLVMIsAMDNode((LLVMValueRef)val);
}

void *__llvm_isa_value_as_metadata(void *val) {
  return (LLVMValueRef)LLVMIsAValueAsMetadata((LLVMValueRef)val);
}

void *__llvm_isa_md_string(void *val) {
  return (LLVMValueRef)LLVMIsAMDString((LLVMValueRef)val);
}

/**
 * @defgroup LLVMCCoreValueUses Usage
 *
 * This module defines functions that allow you to inspect the uses of a
 * LLVMValueRef.
 *
 * It is possible to obtain an LLVMUseRef for any LLVMValueRef instance.
 * Each LLVMUseRef (which corresponds to a llvm::Use instance) holds a
 * llvm::User and llvm::Value.
 *
 * @{
 */

/**
 * Obtain the first use of a value.
 *
 * Uses are obtained in an iterator fashion. First, call this function
 * to obtain a reference to the first use. Then, call LLVMGetNextUse()
 * on that instance and all subsequently obtained instances until
 * LLVMGetNextUse() returns NULL.
 *
 * @see llvm::Value::use_begin()
 */
void *__llvm_get_first_use(void *val) {
  return (LLVMUseRef)LLVMGetFirstUse((LLVMValueRef)val);
}

/**
 * Obtain the next use of a value.
 *
 * This effectively advances the iterator. It returns NULL if you are on
 * the final use and no more are available.
 */
void *__llvm_get_next_use(void *use) {
  return (LLVMUseRef)LLVMGetNextUse((LLVMUseRef)use);
}
/**
 * Obtain the user value for a user.
 *
 * The returned value corresponds to a llvm::User type.
 *
 * @see llvm::Use::getUser()
 */
void *__llvm_get_user(void *use) {
  return (LLVMValueRef)LLVMGetUser((LLVMUseRef)use);
}
/**
 * Obtain the value this use corresponds to.
 *
 * @see llvm::Use::get().
 */
void *__llvm_get_used_value(void *use) {
  return (LLVMValueRef)LLVMGetUsedValue((LLVMUseRef)use);
}

/**
 * @}
 */

/**
 * @defgroup LLVMCCoreValueUser User value
 *
 * Function in this group pertain to LLVMValueRef instances that descent
 * from llvm::User. This includes constants, instructions, and
 * operators.
 *
 * @{
 */

/**
 * Obtain an operand at a specific index in a llvm::User value.
 *
 * @see llvm::User::getOperand()
 */
void *__llvm_get_operand(void *val, unsigned index) {
  return LLVMGetOperand((LLVMValueRef)val, index);
}
/**
 * Obtain the use of an operand at a specific index in a llvm::User value.
 *
 * @see llvm::User::getOperandUse()
 */
void *__llvm_get_operand_use(void *val, unsigned index) {
  return (LLVMUseRef)LLVMGetOperandUse((LLVMValueRef)val, index);
}
/**
 * Set an operand at a specific index in a llvm::User value.
 *
 * @see llvm::User::setOperand()
 */
void __llvm_set_operand(void *val, unsigned index, void *operand) {
  return LLVMSetOperand((LLVMValueRef)val, index, (LLVMValueRef)operand);
}
/**
 * Obtain the number of operands in a llvm::User value.
 *
 * @see llvm::User::getNumOperands()
 */
int __llvm_get_num_operands(void *val) {
  return LLVMGetNumOperands((LLVMValueRef)val);
}

/**
 * @}
 */

/**
 * @defgroup LLVMCCoreValueConstant Constants
 *
 * This section contains APIs for interacting with LLVMValueRef that
 * correspond to llvm::Constant instances.
 *
 * These functions will work for any LLVMValueRef in the llvm::Constant
 * class hierarchy.
 */

/**
 * Obtain a constant value referring to the null instance of a type.
 *
 * @see llvm::Constant::getNullValue()
 */
void *__llvm_const_null(void *ty) { return LLVMConstNull((LLVMTypeRef)ty); }

/**
 * Obtain a constant value referring to the instance of a type
 * consisting of all ones.
 *
 * This is only valid for integer types.
 *
 * @see llvm::Constant::getAllOnesValue()
 */
void *__llvm_const_all_ones(void *ty) {
  return LLVMConstAllOnes((LLVMTypeRef)ty);
}

/**
 * Obtain a constant value referring to an undefined value of a type.
 *
 * @see llvm::UndefValue::get()
 */
void *__llvm_get_undef(void *ty) { return LLVMGetUndef((LLVMTypeRef)ty); }

/**
 * Obtain a constant value referring to a poison value of a type.
 *
 * @see llvm::PoisonValue::get()
 */
void *__llvm_get_poison(void *ty) { return LLVMGetPoison((LLVMTypeRef)ty); }

/**
 * Determine whether a value instance is null.
 *
 * @see llvm::Constant::isNullValue()
 */
LLVMBool __llvm_is_null(void *val_ref) {
  return LLVMIsNull((LLVMValueRef)val_ref);
}

/**
 * Obtain a constant that is a constant pointer pointing to NULL for a
 * specified type.
 */
void *__llvm_const_pointer_null(void *ty) {
  return (LLVMValueRef)LLVMConstPointerNull((LLVMTypeRef)ty);
}

/**
 * @defgroup LLVMCCoreValueConstantScalar Scalar constants
 *
 * Functions in this group model LLVMValueRef instances that correspond
 * to constants referring to scalar types.
 *
 * For integer types, the LLVMTypeRef parameter should correspond to a
 * llvm::IntegerType instance and the returned LLVMValueRef will
 * correspond to a llvm::ConstantInt.
 *
 * For floating point types, the LLVMTypeRef returned corresponds to a
 * llvm::ConstantFP.
 *
 * @{
 */

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
 * Obtain a constant value referring to a double floating point value.
 */
void *__llvm_const_real(void *real_ty, double n) {
  return (LLVMValueRef)LLVMConstReal((LLVMTypeRef)real_ty, n);
}

/**
 * @}
 */
