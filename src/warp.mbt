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
// extern "C" fn llvm_type_is_null(ty: LLVMTypeRef) -> LLVMBool = "__llvm_type_is_null"
extern "C" fn LLVMTypeRef::is_null(self: LLVMTypeRef) -> LLVMBool = "__llvm_type_is_null"

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
extern "C" fn LLVMValueRef::is_null(self: LLVMValueRef) -> LLVMBool = "__llvm_is_null"
extern "C" fn llvm_is_null(val: LLVMValueRef) -> LLVMBool = "__llvm_is_null"

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

// builder
extern "C" fn llvm_create_builder_in_context(ctx: LLVMContextRef) -> LLVMBuilderRef = "__llvm_create_builder_in_context"

extern "C" fn llvm_build_ret_void(builder: LLVMBuilderRef) = "__llvm_build_ret_void"

extern "C" fn llvm_build_ret(builder: LLVMBuilderRef, val: LLVMValueRef) = "__llvm_build_ret"

extern "C" fn llvm_position_builder_at_end(builder: LLVMBuilderRef, block: LLVMBasicBlockRef) = "__llvm_position_builder_at_end"
