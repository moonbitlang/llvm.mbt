// Utils
extern "C" fn moonbit_str_to_c_str(
  s: String
) -> CStr = "moonbit_str_to_c_str"
extern "C" fn c_str_to_moonbit_str(
  s: CStr
) -> String = "c_str_to_moonbit_str"

//
// Create a new context.
//
// Every call to this function should be paired with a call to
// LLVMContextDispose() or the context will leak memory.
//
extern "C" fn llvm_context_create() -> LLVMContextRef = "__llvm_context_create"

//
// Create a new, empty module in the global context.
//
// This is equivalent to calling LLVMModuleCreateWithNameInContext with
// LLVMGetGlobalContext() as the context parameter.
//
// Every invocation should be paired with LLVMDisposeModule() or memory
// will be leaked.
//
pub extern "C" fn llvm_module_create_with_name(name: CStr) -> LLVMModuleRef = "__llvm_module_create_with_name"

// 
// Create a new, empty module in a specific context.
// 
// Every invocation should be paired with LLVMDisposeModule() or memory
// will be leaked.
// 
extern "C" fn llvm_module_create_with_name_in_context(name: CStr, ctx: LLVMContextRef) -> LLVMModuleRef = "__llvm_module_create_with_name_in_context"

// 
// Destroy a module instance.
// 
// This must be called for every created module or memory will be
// leaked.
// 
pub extern "C" fn llvm_dispose_module(m: LLVMModuleRef) = "__llvm_dispose_module"

// 
// Dump a representation of a module to stderr.
// 
// @see Module::dump()
// 
extern "C" fn llvm_dump_module(m: LLVMModuleRef) = "__llvm_dump_module"

// 
// Return a string representation of the module. Use
// LLVMDisposeMessage to free the string.
// 
// @see Module::print()
// 
extern "C" fn llvm_print_module_to_string(m: LLVMModuleRef) -> CStr = "__llvm_print_module_to_string"

// 
// Add a function to a module under a specified name.
// 
// @see llvm::Function::Create()
// 
pub extern "C" fn llvm_add_function(m: LLVMModuleRef, name: CStr, function_ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_add_function"

// 
// Obtain a Function value from a Module by its name.
// 
// The returned value corresponds to a llvm::Function value.
// 
// @see llvm::Module::getFunction()
// 
pub extern "C" fn llvm_get_named_function(m: LLVMModuleRef, name: CStr) -> LLVMValueRef = "__llvm_get_named_function"

// 
// Obtain an iterator to the first Function in a Module.
// 
// @see llvm::Module::begin()
// 
pub extern "C" fn llvm_get_first_function(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_first_function"

// 
// Obtain an iterator to the last Function in a Module.
// 
// @see llvm::Module::end()
// 
pub extern "C" fn llvm_get_last_function(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_last_function"

// 
// Advance a Function iterator to the next Function.
// 
// Returns NULL if the iterator was already at the end and there are no more
// functions.
// 
pub extern "C" fn llvm_get_next_function(fn_val: LLVMValueRef) -> LLVMValueRef = "__llvm_get_next_function"

// 
// Decrement a Function iterator to the previous Function.
// 
// Returns NULL if the iterator was already at the beginning and there are
// no previous functions.
// 
pub extern "C" fn llvm_get_previous_function(fn_val: LLVMValueRef) -> LLVMValueRef = "__llvm_get_previous_function"

//
// Determine whether a type instance is null.
//
extern "C" fn llvm_type_is_null(ty: LLVMTypeRef) -> LLVMBool = "__llvm_type_is_null"
fn LLVMTypeRef::is_null(self: LLVMTypeRef) -> Bool {
  llvm_type_is_null(self).to_moonbit_bool()
}

// 
// Whether the type has a known size.
// 
// Things that don't have a size are abstract types, labels, and void.a
// 
// @see llvm::Type::isSized()
// 
extern "C" fn LLVMTypeRef::is_sized(self: LLVMTypeRef) -> LLVMBool = "__llvm_type_is_sized"

// 
// Obtain the context to which this type instance is associated.
// 
// @see llvm::Type::getContext()
// 
extern "C" fn LLVMTypeRef::get_context(self: LLVMTypeRef) -> LLVMContextRef = "__llvm_get_type_context"

//
// Return a string representation of the type. Use
// LLVMDisposeMessage to free the string.
//
// @see llvm::Type::print()
//
extern "C" fn llvm_print_type_to_string(val: LLVMTypeRef) -> CStr = "__llvm_print_type_to_string"

//
// Dump a representation of a type to stderr.
//
// @see llvm::Type::dump()
//
extern "C" fn llvm_dump_type(ty: LLVMTypeRef) = "__llvm_dump_type"

extern "C" fn llvm_void_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_void_type_in_context"



// 
// @defgroup LLVMCCoreTypeInt Integer Types
// 
// Functions in this section operate on integer types.
// 
// @{
// 
//
// 
// Obtain an integer type from a context with specified bit width.
// 
extern "C" fn llvm_int1_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int1_type_in_context"
extern "C" fn llvm_int8_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int8_type_in_context"
extern "C" fn llvm_int16_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int16_type_in_context"
extern "C" fn llvm_int32_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int32_type_in_context"
extern "C" fn llvm_int64_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int64_type_in_context"
extern "C" fn llvm_int128_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int128_type_in_context"
pub extern "C" fn llvm_int_type_in_context(ctx: LLVMContextRef, num_bits: UInt) -> LLVMTypeRef = "__llvm_int_type_in_context"

// 
// Obtain an integer type from the global context with a specified bit
// width.
// 
pub extern "C" fn llvm_int1_type(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int1_type"
pub extern "C" fn llvm_int8_type(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int8_type"
pub extern "C" fn llvm_int16_type(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int16_type"
pub extern "C" fn llvm_int32_type(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int32_type"
pub extern "C" fn llvm_int64_type(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int64_type"
pub extern "C" fn llvm_int128_type(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int128_type"
pub extern "C" fn llvm_int_type(ctx: LLVMContextRef, num_bits: UInt) -> LLVMTypeRef = "__llvm_int_type"
pub extern "C" fn llvm_get_int_type_width(ty: LLVMTypeRef) -> UInt = "__llvm_get_int_type_width"

pub extern "C" fn llvm_half_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_half_type_in_context"

pub extern "C" fn llvm_bfloat_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_bfloat_type_in_context"

pub extern "C" fn llvm_float_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_float_type_in_context"

pub extern "C" fn llvm_double_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_double_type_in_context"

pub extern "C" fn llvm_half_type() -> LLVMTypeRef = "__llvm_half_type"
pub extern "C" fn llvm_bfloat_type() -> LLVMTypeRef = "__llvm_bfloat_type"
pub extern "C" fn llvm_float_type() -> LLVMTypeRef = "__llvm_float_type"
pub extern "C" fn llvm_double_type() -> LLVMTypeRef = "__llvm_double_type"

extern "C" fn llvm_function_type(
  return_type: LLVMTypeRef,
  param_types: Array[LLVMTypeRef],
  param_count: UInt,
  is_var_arg: LLVMBool
) -> LLVMTypeRef = "__llvm_function_type"

pub extern "C" fn llvm_is_function_var_arg(ty: LLVMTypeRef) -> LLVMBool = "__llvm_is_function_var_arg"

pub extern "C" fn llvm_get_return_type(ty: LLVMTypeRef) -> LLVMTypeRef = "__llvm_get_return_type"

pub extern "C" fn llvm_count_param_types(ty: LLVMTypeRef) -> UInt = "__llvm_count_param_types"

// Struct Types

// ==================== Type

// 
// Print a representation of a module to a file. The ErrorMessage needs to be
// disposed with LLVMDisposeMessage. Returns 0 on success, 1 otherwise.
// 
// @see Module::print()
// 
pub extern "C" fn llvm_print_module_to_file(module_ref: LLVMModuleRef, filename: CStr, errmsg: CStr) -> LLVMBool = "__llvm_print_module_to_file"


// Dump a representation of a value to stderr.
//
// @see llvm::Value::dump()
//
extern "C" fn llvm_dump_value(val: LLVMValueRef) = "__llvm_dump_value"

// Return a string representation of the value. Use
// LLVMDisposeMessage to free the string.
//
// @see llvm::Value::print()
//
extern "C" fn llvm_print_value_to_string(val: LLVMValueRef) -> CStr = "__llvm_print_value_to_string"


extern "C" fn llvm_use_ref_is_null(self: LLVMUseRef) -> LLVMBool = "__llvm_use_ref_is_null"
fn LLVMUseRef::is_null(self: LLVMUseRef) -> Bool {
  llvm_use_ref_is_null(self).to_moonbit_bool()
}
// extern "C" fn llvm_get_first_use(val: LLVMValueRef) -> LLVMUseRef = "__llvm_get_first_use"

extern "C" fn llvm_get_next_use(use_ref: LLVMUseRef) -> LLVMUseRef = "__llvm_get_next_use"
pub extern "C" fn llvm_get_user(use_ref: LLVMUseRef) -> LLVMValueRef = "__llvm_get_user"
pub extern "C" fn llvm_get_used_value(use_ref: LLVMUseRef) -> LLVMValueRef = "__llvm_get_used_value"




// 
// Replace all uses of a value with another one.
// 
// @see llvm::Value::replaceAllUsesWith()
// 
extern "C" fn llvm_replace_all_uses_with(old_val: LLVMValueRef, new_val: LLVMValueRef) = "__llvm_replace_all_uses_with"

// 
// Obtain a constant value referring to the instance of a type
// consisting of all ones.
// 
// This is only valid for integer types.
// 
// @see llvm::Constant::getAllOnesValue()
// 
extern "C" fn llvm_const_all_ones(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_all_ones"

// 
// Obtain a constant value referring to an undefined value of a type.
// 
// @see llvm::UndefValue::get()
// 
extern "C" fn llvm_get_undef(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_get_undef"

// 
// Obtain a constant value referring to a poison value of a type.
// 
// @see llvm::PoisonValue::get()
// 
extern "C" fn llvm_get_poison(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_get_posion"

// Determine whether a value instance is null.
//
// @see llvm::Constant::isNullValue()
extern "C" fn llvm_is_null(val: LLVMValueRef) -> LLVMBool = "__llvm_is_null"
fn LLVMValueRef::is_null(self: LLVMValueRef) -> Bool {
  llvm_is_null(self).to_moonbit_bool()
}

// 
// Obtain a constant that is a constant pointer pointing to NULL for a
// specified type.
// 
// extern "C" fn llvm_const_pointer_null(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_pointer_null"



extern "C" fn llvm_const_int(ty: LLVMTypeRef, n: UInt64, sign_extend: LLVMBool) -> LLVMValueRef = "__llvm_const_int"

// 
// Obtain a constant value referring to a double floating point value.
// 
extern "C" fn llvm_const_real(ty: LLVMTypeRef, n: Double) -> LLVMValueRef = "__llvm_const_real"

extern "C" fn llvm_align_of(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_align_of"

extern "C" fn llvm_size_of(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_size_of"


extern "C" fn llvm_const_neg(val: LLVMValueRef) -> LLVMValueRef = "__llvm_const_neg"
extern "C" fn llvm_const_nsw_neg(val: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nsw_neg"
extern "C" fn llvm_const_not(val: LLVMValueRef) -> LLVMValueRef = "__llvm_const_not"
extern "C" fn llvm_const_add(lhs: LLVMValueRef, rhs: LLVMValueRef) -> LLVMValueRef = "__llvm_const_add"
extern "C" fn llvm_const_nsw_add(lhs: LLVMValueRef, rhs: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nsw_add"
extern "C" fn llvm_const_nuw_add(lhs: LLVMValueRef, rhs: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nuw_add"
extern "C" fn llvm_const_sub(lhs: LLVMValueRef, rhs: LLVMValueRef) -> LLVMValueRef = "__llvm_const_sub"
extern "C" fn llvm_const_nsw_sub(lhs: LLVMValueRef, rhs: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nsw_sub"
extern "C" fn llvm_const_nuw_sub(lhs: LLVMValueRef, rhs: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nuw_sub"
extern "C" fn llvm_const_mul(lhs: LLVMValueRef, rhs: LLVMValueRef) -> LLVMValueRef = "__llvm_const_mul"
extern "C" fn llvm_const_nsw_mul(lhs: LLVMValueRef, rhs: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nsw_mul"
extern "C" fn llvm_const_nuw_mul(lhs: LLVMValueRef, rhs: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nuw_mul"
extern "C" fn llvm_const_xor(lhs: LLVMValueRef, rhs: LLVMValueRef) -> LLVMValueRef = "__llvm_const_xor"

extern "C" fn llvm_const_trunc(const_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_trunc"

extern "C" fn llvm_const_ptr_to_int(const_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_ptr_to_int"

extern "C" fn llvm_const_int_to_ptr(const_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_int_to_ptr"

extern "C" fn llvm_const_bit_cast(const_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_bit_cast"

extern "C" fn llvm_const_addr_space_cast(const_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_addr_space_cast"
extern "C" fn llvm_const_trunc_or_bit_cast(const_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_trunc_or_bit_cast"
extern "C" fn llvm_const_pointer_cast(const_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_pointer_cast"

// 
// Determine whether the specified value instance is constant.
//
extern "C" fn llvm_is_const(val: LLVMValueRef) -> LLVMBool = "__llvm_is_const"

// 
// Determine whether a value instance is undefined.
// 
extern "C" fn llvm_is_undef(val: LLVMValueRef) -> LLVMBool = "__llvm_is_undef"

// 
// Determine whether a value instance is poisonous.
// 
// extern "C" fn llvm_is_poison(val: LLVMValueRef) -> LLVMBool = "__llvm_is_poison"


pub extern "C" fn llvm_isa_argument(val:LLVMValueRef) -> LLVMValueRef = "__llvm_isa_argument"
pub extern "C" fn llvm_isa_basic_block(val:LLVMValueRef) -> LLVMValueRef = "__llvm_isa_basic_block"
pub extern "C" fn llvm_isa_user(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_user"
pub extern "C" fn llvm_isa_constant(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant"
pub extern "C" fn llvm_isa_block_address(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_block_address"
pub extern "C" fn llvm_isa_constant_aggregate_zero(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_aggregate_zero"
pub extern "C" fn llvm_isa_constant_array(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_array"
pub extern "C" fn llvm_isa_constant_data_sequential(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_data_sequential"
pub extern "C" fn llvm_isa_constant_data_array(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_data_array"
pub extern "C" fn llvm_isa_constant_data_vector(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_data_vector"
pub extern "C" fn llvm_isa_constant_expr(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_expr"
pub extern "C" fn llvm_isa_constant_fp(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_fp"
pub extern "C" fn llvm_isa_constant_int(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_int"
pub extern "C" fn llvm_isa_constant_pointer_null(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_pointer_null"
pub extern "C" fn llvm_isa_constant_struct(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_struct"
pub extern "C" fn llvm_isa_constant_token_none(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_token_none"
pub extern "C" fn llvm_isa_constant_vector(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_vector"
pub extern "C" fn llvm_isa_global_value(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_value"
pub extern "C" fn llvm_isa_global_alias(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_alias"
pub extern "C" fn llvm_isa_global_object(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_object"
pub extern "C" fn llvm_isa_function(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_function"
pub extern "C" fn llvm_isa_global_variable(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_variable"
pub extern "C" fn llvm_isa_global_ifunc(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_ifunc"
pub extern "C" fn llvm_isa_undef_value(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_undef_value"
pub extern "C" fn llvm_isa_poison_value(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_poison_value"
pub extern "C" fn llvm_isa_instruction(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_instruction"
pub extern "C" fn llvm_isa_unary_operator(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_unary_operator"
pub extern "C" fn llvm_isa_binary_operator(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_binary_operator"
pub extern "C" fn llvm_isa_call_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_call_inst"
pub extern "C" fn llvm_isa_intrinsic_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_intrinsic_inst"
pub extern "C" fn llvm_isa_dbg_info_intrinsic(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_dbg_info_intrinsic"
pub extern "C" fn llvm_isa_dbg_variable_intrinsic(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_dbg_variable_intrinsic"
pub extern "C" fn llvm_isa_dbg_declare_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_dbg_declare_inst"
pub extern "C" fn llvm_dbg_label_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_dbg_label_inst"
pub extern "C" fn llvm_isa_mem_intrinsic(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_mem_intrinsic"
pub extern "C" fn llvm_isa_mem_cpy_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_mem_cpy_inst"
pub extern "C" fn llvm_isa_mem_move_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_mem_move_inst"
pub extern "C" fn llvm_isa_mem_set_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_mem_set_inst"
pub extern "C" fn llvm_isa_cmp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_cmp_inst"
pub extern "C" fn llvm_isa_fcmp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fcmp_inst"
pub extern "C" fn llvm_isa_icmp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_icmp_inst"
pub extern "C" fn llvm_isa_extract_element_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_extract_element_inst"
pub extern "C" fn llvm_isa_get_element_ptr_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_get_element_ptr_inst"
pub extern "C" fn llvm_insert_element_ptr_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_insert_element_ptr_inst"
pub extern "C" fn llvm_isa_insert_value_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_insert_value_inst"
pub extern "C" fn llvm_isa_landing_pad_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_landing_pad_inst"
pub extern "C" fn llvm_isa_phi_node(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_phi_node"
pub extern "C" fn llvm_isa_select_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_select_inst"
pub extern "C" fn llvm_isa_shuffle_vector_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_shuffle_vector_inst"
pub extern "C" fn llvm_isa_store_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_store_inst"
pub extern "C" fn llvm_isa_branch_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_branch_inst"
pub extern "C" fn llvm_isa_indirect_br_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_indirect_br_inst"
pub extern "C" fn llvm_isa_invoke_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_invoke_inst"
pub extern "C" fn llvm_isa_return_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_return_inst"
pub extern "C" fn llvm_isa_switch_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_switch_inst"
pub extern "C" fn llvm_isa_unreachable_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_unreachable_inst"
pub extern "C" fn llvm_isa_resume_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_resume_inst"
pub extern "C" fn llvm_isa_cleanup_return_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_cleanup_return_inst"
pub extern "C" fn llvm_isa_catch_return_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_catch_return_inst"
pub extern "C" fn llvm_isa_catch_switch_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_catch_switch_inst"
pub extern "C" fn llvm_isa_call_br_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_call_br_inst"
pub extern "C" fn llvm_isa_funclet_pad_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_funclet_pad_inst"
pub extern "C" fn llvm_isa_catch_pad_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_catch_pad_inst"
pub extern "C" fn llvm_isa_cleanup_pad_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_cleanup_pad_inst"
pub extern "C" fn llvm_isa_unary_instruction(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_unary_instruction"
pub extern "C" fn llvm_isa_alloca_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_alloca_inst"
pub extern "C" fn llvm_isa_cast_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_cast_inst"
pub extern "C" fn llvm_isa_addr_space_cast_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_addr_space_cast_inst"
pub extern "C" fn llvm_isa_bit_cast_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_bit_cast_inst"
pub extern "C" fn llvm_isa_fp_ext_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fp_ext_inst"
pub extern "C" fn llvm_isa_fp_to_si_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fp_to_si_inst"
pub extern "C" fn llvm_isa_fp_ui_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fp_ui_inst"
pub extern "C" fn llvm_isa_fp_trunc_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fp_trunc_inst"
pub extern "C" fn llvm_int_to_ptr_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_int_to_ptr_inst"
pub extern "C" fn llvm_isa_ptr_to_int_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_ptr_to_int_inst"
pub extern "C" fn llvm_isa_sext_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_sext_inst"
pub extern "C" fn llvm_isa_si_to_fp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_si_to_fp_inst"
pub extern "C" fn llvm_isa_trunc_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_trunc_inst"
pub extern "C" fn llvm_isa_ui_to_fp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_ui_to_fp_inst"
pub extern "C" fn llvm_isa_zext_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_zext_inst"
pub extern "C" fn llvm_isa_extract_value_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_extract_value_inst"
pub extern "C" fn llvm_isa_load_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_load_inst"
pub extern "C" fn llvm_isa_va_arg_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_va_arg_inst"
pub extern "C" fn llvm_isa_freeze_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_freeze_inst"
pub extern "C" fn llvm_isa_atomic_cmp_xchg_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_atomic_cmp_xchg_inst"
pub extern "C" fn llvm_isa_atomic_rmw_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_atomic_rmw_inst"
pub extern "C" fn llvm_isa_fence_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fence_inst"
pub extern "C" fn llvm_isa_md_node(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_md_node"
pub extern "C" fn llvm_isa_value_as_metadata(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_value_as_metadata"

// 
// Obtain the type of a value.
// 
// @see llvm::Value::getType()
// 
extern "C" fn llvm_type_of(val: LLVMValueRef) -> LLVMTypeRef = "__llvm_type_of"

// 
// Set the string name of a value.
// 
// @see llvm::Value::setName()
// 
extern "C" fn llvm_set_value_name(val: LLVMValueRef, name: CStr, name_len: UInt) = "__llvm_set_value_name"

//
// Obtain the string name of a value.
//
// @see llvm::Value::getName()
//
extern "C" fn llvm_get_value_name(val: LLVMValueRef) -> CStr = "__llvm_get_value_name"

// BasicBlock
extern "C" fn llvm_append_basic_block_in_context(ctx: LLVMContextRef, fn_val: LLVMValueRef, name: CStr) -> LLVMBasicBlockRef = "__llvm_append_basic_block_in_context"

pub extern "C" fn llvm_inster_basic_block_in_conext(ctx: LLVMContextRef, bb: LLVMBasicBlockRef, name: CStr) -> LLVMBasicBlockRef = "__llvm_insert_basic_block_in_context"

pub extern "C" fn llvm_inster_basic_block(bb: LLVMBasicBlockRef, name: CStr) -> LLVMBasicBlockRef = "__llvm_insert_basic_block"

pub extern "C" fn llvm_delete_basic_block(bb: LLVMBasicBlockRef) = "__llvm_delete_basic_block"

// 
// Remove a basic block from a function.
// 
// This deletes the basic block from its containing function but keep
// the basic block alive.
// 
// @see llvm::BasicBlock::removeFromParent()
pub extern "C" fn llvm_remove_basic_block_from_parent(bb: LLVMBasicBlockRef) = "__llvm_remove_basic_block_from_parent"
//
// 
// Move a basic block to before another one.
// 
// @see llvm::BasicBlock::moveBefore()
// 
pub extern "C" fn llvm_move_basic_block_before(bb: LLVMBasicBlockRef, move_pos: LLVMBasicBlockRef) = "__llvm_move_basic_block_before"
// 
// Move a basic block to after another one.
// 
// @see llvm::BasicBlock::moveAfter()
// 
pub extern "C" fn llvm_move_basic_block_after(bb: LLVMBasicBlockRef, move_pos: LLVMBasicBlockRef) = "__llvm_move_basic_block_after"
//
// 
// Obtain the first instruction in a basic block.
// 
// The returned LLVMValueRef corresponds to a llvm::Instruction
// instance.
// 
pub extern "C" fn llvm_get_first_instruction(bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_get_first_instruction"
//
// 
// Obtain the last instruction in a basic block.
// 
// The returned LLVMValueRef corresponds to an LLVM:Instruction.
// 
pub extern "C" fn llvm_get_last_instruction(bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_get_last_instruction"

// /**
//  * @defgroup LLVMCCoreValueInstruction Instructions
//  *
//  * Functions in this group relate to the inspection and manipulation of
//  * individual instructions.
//  *
//  * In the C++ API, an instruction is modeled by llvm::Instruction. This
//  * class has a large number of descendents. llvm::Instruction is a
//  * llvm::Value and in the C API, instructions are modeled by
//  * LLVMValueRef.
//  *
//  * This group also contains sub-groups which operate on specific
//  * llvm::Instruction types, e.g. llvm::CallInst.
//  *
//  * @{
//  */
//
// /**
//  * Determine whether an instruction has any metadata attached.
//  */
// int LLVMHasMetadata(LLVMValueRef Val);
pub extern "C" fn llvm_has_metadata(val: LLVMValueRef) -> Int = "__llvm_has_metadata"
//
// /**
//  * Return metadata associated with an instruction value.
//  */
pub extern "C" fn llvm_get_metadata(val: LLVMValueRef, kind_id: UInt) -> LLVMValueRef = "__llvm_get_metadata"
//
// /**
//  * Set metadata associated with an instruction value.
//  */
// void LLVMSetMetadata(LLVMValueRef Val, unsigned KindID, LLVMValueRef Node);
pub extern "C" fn llvm_set_metadata(val: LLVMValueRef, kind_id: UInt, node: LLVMValueRef) = "__llvm_set_metadata"

//
// Returns the metadata associated with an instruction value, but filters out
// all the debug locations.
//
// @see llvm::Instruction::getAllMetadataOtherThanDebugLoc()
//
// LLVMValueMetadataEntry *LLVMInstructionGetAllMetadataOtherThanDebugLoc(LLVMValueRef Instr, size_t *NumEntries);
// pub extern "C" fn llvm_instruction_get_all_metadata_other_than_debug_loc(instr: LLVMValueRef, num_entries: *mut Size) -> *mut LLVMValueMetadataEntry = "__llvm_instruction_get_all_metadata_other_than_debug_loc"

//
// Obtain the basic block to which an instruction belongs.
//
// @see llvm::Instruction::getParent()
//
// LLVMBasicBlockRef LLVMGetInstructionParent(LLVMValueRef Inst);
pub extern "C" fn llvm_get_instruction_parent(inst: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_instruction_parent"

//
// Obtain the instruction that occurs after the one specified.
//
// The next instruction will be from the same basic block.
//
// If this is the last instruction in a basic block, NULL will be
// returned.
//
// LLVMValueRef LLVMGetNextInstruction(LLVMValueRef Inst);
pub extern "C" fn llvm_get_next_instruction(inst: LLVMValueRef) -> LLVMValueRef = "__llvm_get_next_instruction"

//
// Obtain the instruction that occurred before this one.
//
// If the instruction is the first instruction in a basic block, NULL
// will be returned.
//
// LLVMValueRef LLVMGetPreviousInstruction(LLVMValueRef Inst);
pub extern "C" fn llvm_get_previous_instruction(inst: LLVMValueRef) -> LLVMValueRef = "__llvm_get_previous_instruction"

//
// Remove an instruction.
//
// The instruction specified is removed from its containing building
// block but is kept alive.
//
// @see llvm::Instruction::removeFromParent()
//
// void LLVMInstructionRemoveFromParent(LLVMValueRef Inst);
pub extern "C" fn llvm_instruction_remove_from_parent(inst: LLVMValueRef) = "__llvm_instruction_remove_from_parent"

//
// Remove and delete an instruction.
//
// The instruction specified is removed from its containing building
// block and then deleted.
//
// @see llvm::Instruction::eraseFromParent()
//
// void LLVMInstructionEraseFromParent(LLVMValueRef Inst);
pub extern "C" fn llvm_instruction_erase_from_parent(inst: LLVMValueRef) = "__llvm_instruction_erase_from_parent"

//
// Delete an instruction.
//
// The instruction specified is deleted. It must have previously been
// removed from its containing building block.
//
// @see llvm::Value::deleteValue()
//
// void LLVMDeleteInstruction(LLVMValueRef Inst);
pub extern "C" fn llvm_delete_instruction(inst: LLVMValueRef) = "__llvm_delete_instruction"

//
// Obtain the code opcode for an individual instruction.
//
// @see llvm::Instruction::getOpCode()
//
// LLVMOpcode LLVMGetInstructionOpcode(LLVMValueRef Inst);
// pub extern "C" fn llvm_get_instruction_opcode(inst: LLVMValueRef) -> LLVMOpcode = "__llvm_get_instruction_opcode"

//
// Obtain the predicate of an instruction.
//
// This is only valid for instructions that correspond to llvm::ICmpInst.
//
// @see llvm::ICmpInst::getPredicate()
//
// LLVMIntPredicate LLVMGetICmpPredicate(LLVMValueRef Inst);
// pub extern "C" fn llvm_get_icmp_predicate(inst: LLVMValueRef) -> LLVMIntPredicate = "__llvm_get_icmp_predicate"

//
// Obtain the float predicate of an instruction.
//
// This is only valid for instructions that correspond to llvm::FCmpInst.
//
// @see llvm::FCmpInst::getPredicate()
//
// LLVMRealPredicate LLVMGetFCmpPredicate(LLVMValueRef Inst);
// pub extern "C" fn llvm_get_fcmp_predicate(inst: LLVMValueRef) -> LLVMRealPredicate = "__llvm_get_fcmp_predicate"

//
// Create a copy of 'this' instruction that is identical in all ways
// except the following:
//   * The instruction has no parent
//   * The instruction has no name
//
// @see llvm::Instruction::clone()
//
// LLVMValueRef LLVMInstructionClone(LLVMValueRef Inst);
pub extern "C" fn llvm_instruction_clone(inst: LLVMValueRef) -> LLVMValueRef = "__llvm_instruction_clone"

//
// Determine whether an instruction is a terminator. This routine is named to
// be compatible with historical functions that did this by querying the
// underlying C++ type.
//
// @see llvm::Instruction::isTerminator()
//
// LLVMValueRef LLVMIsATerminatorInst(LLVMValueRef Inst);
pub extern "C" fn llvm_is_a_terminator_inst(inst: LLVMValueRef) -> LLVMValueRef = "__llvm_is_a_terminator_inst"

//
// Obtain the argument count for a call instruction.
//
// This expects an LLVMValueRef that corresponds to a llvm::CallInst,
// llvm::InvokeInst, or llvm:FuncletPadInst.
//
// @see llvm::CallInst::getNumArgOperands()
// @see llvm::InvokeInst::getNumArgOperands()
// @see llvm::FuncletPadInst::getNumArgOperands()
//
// unsigned LLVMGetNumArgOperands(LLVMValueRef Instr);
pub extern "C" fn llvm_get_num_arg_operands(instr: LLVMValueRef) -> UInt = "__llvm_get_num_arg_operands"

//
// Set the calling convention for a call instruction.
//
// This expects an LLVMValueRef that corresponds to a llvm::CallInst or
// llvm::InvokeInst.
//
// @see llvm::CallInst::setCallingConv()
// @see llvm::InvokeInst::setCallingConv()
//
// void LLVMSetInstructionCallConv(LLVMValueRef Instr, unsigned CC);
pub extern "C" fn llvm_set_instruction_call_conv(instr: LLVMValueRef, cc: UInt) = "__llvm_set_instruction_call_conv"

//
// Obtain the calling convention for a call instruction.
//
// This is the opposite of LLVMSetInstructionCallConv(). Reads its
// usage.
//
// @see LLVMSetInstructionCallConv()
//
// unsigned LLVMGetInstructionCallConv(LLVMValueRef Instr);
// pub extern "C" fn llvm_get_instruction_call_conv(instr: LLVMValueRef) -> UInt = "__llvm_get_instruction_call_conv"

//
// void LLVMSetInstrParamAlignment(LLVMValueRef Instr, LLVMAttributeIndex Idx, unsigned Align);
// pub extern "C" fn llvm_set_instr_param_alignment(instr: LLVMValueRef, idx: LLVMAttributeIndex, align: UInt) = "__llvm_set_instr_param_alignment"

//
// void LLVMAddCallSiteAttribute(LLVMValueRef C, LLVMAttributeIndex Idx, LLVMAttributeRef A);
// pub extern "C" fn llvm_add_call_site_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, a: LLVMAttributeRef) = "__llvm_add_call_site_attribute"

//
// unsigned LLVMGetCallSiteAttributeCount(LLVMValueRef C, LLVMAttributeIndex Idx);
// pub extern "C" fn llvm_get_call_site_attribute_count(c: LLVMValueRef, idx: LLVMAttributeIndex) -> UInt = "__llvm_get_call_site_attribute_count"

//
// void LLVMGetCallSiteAttributes(LLVMValueRef C, LLVMAttributeIndex Idx, LLVMAttributeRef *Attrs);
// pub extern "C" fn llvm_get_call_site_attributes(c: LLVMValueRef, idx: LLVMAttributeIndex, attrs: *mut LLVMAttributeRef) = "__llvm_get_call_site_attributes"

//
// LLVMAttributeRef LLVMGetCallSiteEnumAttribute(LLVMValueRef C, LLVMAttributeIndex Idx, unsigned KindID);
// pub extern "C" fn llvm_get_call_site_enum_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, kind_id: UInt) -> LLVMAttributeRef = "__llvm_get_call_site_enum_attribute"

//
// LLVMAttributeRef LLVMGetCallSiteStringAttribute(LLVMValueRef C, LLVMAttributeIndex Idx, const char *K, unsigned KLen);
// pub extern "C" fn llvm_get_call_site_string_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, k: *const Char, k_len: UInt) -> LLVMAttributeRef = "__llvm_get_call_site_string_attribute"

//
// void LLVMRemoveCallSiteEnumAttribute(LLVMValueRef C, LLVMAttributeIndex Idx, unsigned KindID);
pub extern "C" fn llvm_remove_call_site_enum_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, kind_id: UInt) = "__llvm_remove_call_site_enum_attribute"

//
// void LLVMRemoveCallSiteStringAttribute(LLVMValueRef C, LLVMAttributeIndex Idx, const char *K, unsigned KLen);
// pub extern "C" fn llvm_remove_call_site_string_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, k: *const Char, k_len: UInt) = "__llvm_remove_call_site_string_attribute"

//
// Obtain the function type called by this instruction.
//
// @see llvm::CallBase::getFunctionType()
//
// LLVMTypeRef LLVMGetCalledFunctionType(LLVMValueRef C);
pub extern "C" fn llvm_get_called_function_type(c: LLVMValueRef) -> LLVMTypeRef = "__llvm_get_called_function_type"

//
// Obtain the pointer to the function invoked by this instruction.
//
// This expects an LLVMValueRef that corresponds to a llvm::CallInst or
// llvm::InvokeInst.
//
// @see llvm::CallInst::getCalledOperand()
// @see llvm::InvokeInst::getCalledOperand()
//
// LLVMValueRef LLVMGetCalledValue(LLVMValueRef Instr);
pub extern "C" fn llvm_get_called_value(instr: LLVMValueRef) -> LLVMValueRef = "__llvm_get_called_value"

//
// Obtain the number of operand bundles attached to this instruction.
//
// This only works on llvm::CallInst and llvm::InvokeInst instructions.
//
// @see llvm::CallBase::getNumOperandBundles()
//
// unsigned LLVMGetNumOperandBundles(LLVMValueRef C);
pub extern "C" fn llvm_get_num_operand_bundles(c: LLVMValueRef) -> UInt = "__llvm_get_num_operand_bundles"

//
// Obtain the operand bundle attached to this instruction at the given index.
// Use LLVMDisposeOperandBundle to free the operand bundle.
//
// This only works on llvm::CallInst and llvm::InvokeInst instructions.
//
// LLVMOperandBundleRef LLVMGetOperandBundleAtIndex(LLVMValueRef C, unsigned Index);
pub extern "C" fn llvm_get_operand_bundle_at_index(c: LLVMValueRef, index: UInt) -> LLVMOperandBundleRef = "__llvm_get_operand_bundle_at_index"

//
// Obtain whether a call instruction is a tail call.
//
// This only works on llvm::CallInst instructions.
//
// @see llvm::CallInst::isTailCall()
//
// LLVMBool LLVMIsTailCall(LLVMValueRef CallInst);
pub extern "C" fn llvm_is_tail_call(call_inst: LLVMValueRef) -> LLVMBool = "__llvm_is_tail_call"

//
// Set whether a call instruction is a tail call.
//
// This only works on llvm::CallInst instructions.
//
// @see llvm::CallInst::setTailCall()
//
// void LLVMSetTailCall(LLVMValueRef CallInst, LLVMBool IsTailCall);
pub extern "C" fn llvm_set_tail_call(call_inst: LLVMValueRef, is_tail_call: LLVMBool) = "__llvm_set_tail_call"

//
// Obtain a tail call kind of the call instruction.
//
// @see llvm::CallInst::setTailCallKind()
//
// LLVMTailCallKind LLVMGetTailCallKind(LLVMValueRef CallInst);
// pub extern "C" fn llvm_get_tail_call_kind(call_inst: LLVMValueRef) -> LLVMTailCallKind = "__llvm_get_tail_call_kind"

//
// Set the call kind of the call instruction.
//
// @see llvm::CallInst::getTailCallKind()
//
// void LLVMSetTailCallKind(LLVMValueRef CallInst, LLVMTailCallKind kind);
// pub extern "C" fn llvm_set_tail_call_kind(call_inst: LLVMValueRef, kind: LLVMTailCallKind) = "__llvm_set_tail_call_kind"

//
// Return the normal destination basic block.
//
// This only works on llvm::InvokeInst instructions.
//
// @see llvm::InvokeInst::getNormalDest()
//
// LLVMBasicBlockRef LLVMGetNormalDest(LLVMValueRef InvokeInst);
pub extern "C" fn llvm_get_normal_dest(invoke_inst: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_normal_dest"

//
// Return the unwind destination basic block.
//
// Works on llvm::InvokeInst, llvm::CleanupReturnInst, and
// llvm::CatchSwitchInst instructions.
//
// @see llvm::InvokeInst::getUnwindDest()
// @see llvm::CleanupReturnInst::getUnwindDest()
// @see llvm::CatchSwitchInst::getUnwindDest()
//
// LLVMBasicBlockRef LLVMGetUnwindDest(LLVMValueRef InvokeInst);
pub extern "C" fn llvm_get_unwind_dest(invoke_inst: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_unwind_dest"

//
// Set the normal destination basic block.
//
// This only works on llvm::InvokeInst instructions.
//
// @see llvm::InvokeInst::setNormalDest()
//
// void LLVMSetNormalDest(LLVMValueRef InvokeInst, LLVMBasicBlockRef B);
pub extern "C" fn llvm_set_normal_dest(invoke_inst: LLVMValueRef, b: LLVMBasicBlockRef) = "__llvm_set_normal_dest"

//
// Set the unwind destination basic block.
//
// Works on llvm::InvokeInst, llvm::CleanupReturnInst, and
// llvm::CatchSwitchInst instructions.
//
// @see llvm::InvokeInst::setUnwindDest()
// @see llvm::CleanupReturnInst::setUnwindDest()
// @see llvm::CatchSwitchInst::setUnwindDest()
//
// void LLVMSetUnwindDest(LLVMValueRef InvokeInst, LLVMBasicBlockRef B);
pub extern "C" fn llvm_set_unwind_dest(invoke_inst: LLVMValueRef, b: LLVMBasicBlockRef) = "__llvm_set_unwind_dest"

//
// Get the default destination of a CallBr instruction.
//
// @see llvm::CallBrInst::getDefaultDest()
//
// LLVMBasicBlockRef LLVMGetCallBrDefaultDest(LLVMValueRef CallBr);
pub extern "C" fn llvm_get_call_br_default_dest(call_br: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_call_br_default_dest"

//
// Get the number of indirect destinations of a CallBr instruction.
//
// @see llvm::CallBrInst::getNumIndirectDests()
//
// unsigned LLVMGetCallBrNumIndirectDests(LLVMValueRef CallBr);
pub extern "C" fn llvm_get_call_br_num_indirect_dests(call_br: LLVMValueRef) -> UInt = "__llvm_get_call_br_num_indirect_dests"

//
// Get the indirect destination of a CallBr instruction at the given index.
//
// @see llvm::CallBrInst::getIndirectDest()
//
// LLVMBasicBlockRef LLVMGetCallBrIndirectDest(LLVMValueRef CallBr, unsigned Idx);
pub extern "C" fn llvm_get_call_br_indirect_dest(call_br: LLVMValueRef, idx: UInt) -> LLVMBasicBlockRef = "__llvm_get_call_br_indirect_dest"




// builder
extern "C" fn llvm_create_builder_in_context(ctx: LLVMContextRef) -> LLVMBuilderRef = "__llvm_create_builder_in_context"

extern "C" fn llvm_build_ret_void(builder: LLVMBuilderRef) = "__llvm_build_ret_void"

extern "C" fn llvm_build_ret(builder: LLVMBuilderRef, val: LLVMValueRef) = "__llvm_build_ret"

extern "C" fn llvm_position_builder_at_end(builder: LLVMBuilderRef, block: LLVMBasicBlockRef) = "__llvm_position_builder_at_end"
