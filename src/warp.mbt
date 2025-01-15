// extern types
type CStr
type LLVMBool Int derive(Eq)

type LLVMContextRef
// type LLVMModuleRef
// type LLVMBasicBlockRef
// type LLVMBuilderRef
type LLVMValueRef
type LLVMTypeRef

// Utils
extern "C" fn moonbit_str_to_c_str(s: String) -> CStr = "moonbit_str_to_c_str"
extern "C" fn c_str_to_moonbit_str(s: CStr) -> String = "c_str_to_moonbit_str"

//
// Create a new context.
//
// Every call to this function should be paired with a call to
// LLVMContextDispose() or the context will leak memory.
//
extern "C" fn llvm_context_create() -> LLVMContextRef = "__llvm_context_create"


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
// extern "C" fn llvm_int1_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int1_type_in_context"
// extern "C" fn llvm_int8_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int8_type_in_context"
// extern "C" fn llvm_int16_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int16_type_in_context"
extern "C" fn llvm_int32_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int32_type_in_context"
// extern "C" fn llvm_int64_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int64_type_in_context"
// extern "C" fn llvm_int128_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int128_type_in_context"
// extern "C" fn llvm_int_type_in_context(ctx: LLVMContextRef, num_bits: UInt) -> LLVMTypeRef = "__llvm_int_type_in_context"

// 
// Obtain an integer type from the global context with a specified bit
// width.
// 
// extern "C" fn llvm_int1_type(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int1_type"
// extern "C" fn llvm_int8_type(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int8_type"
// extern "C" fn llvm_int16_type(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int16_type"
// extern "C" fn llvm_int32_type(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int32_type"
// extern "C" fn llvm_int64_type(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int64_type"
// extern "C" fn llvm_int128_type(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int128_type"
// extern "C" fn llvm_int_type(ctx: LLVMContextRef, num_bits: UInt) -> LLVMTypeRef = "__llvm_int_type"

//
// Create a new, empty module in the global context.
//
// This is equivalent to calling LLVMModuleCreateWithNameInContext with
// LLVMGetGlobalContext() as the context parameter.
//
// Every invocation should be paired with LLVMDisposeModule() or memory
// will be leaked.
//
// extern "C" fn llvm_module_create_with_name(name: CStr) -> LLVMModuleRef = "__llvm_module_create_with_name"

// 
// Create a new, empty module in a specific context.
// 
// Every invocation should be paired with LLVMDisposeModule() or memory
// will be leaked.
// 
// extern "C" fn llvm_module_create_with_name_in_context(name: CStr, ctx: LLVMContextRef) -> LLVMModuleRef = "__llvm_module_create_with_name_in_context"

// 
// Destroy a module instance.
// 
// This must be called for every created module or memory will be
// leaked.
// 
// extern "C" fn llvm_dispose_module(m: LLVMModuleRef) = "__llvm_dispose_module"

// 
// Dump a representation of a module to stderr.
// 
// @see Module::dump()
// 
// extern "C" fn llvm_dump_module(m: LLVMModuleRef) = "__llvm_dump_module"

// 
// Return a string representation of the module. Use
// LLVMDisposeMessage to free the string.
// 
// @see Module::print()
// 
// extern "C" fn llvm_print_module_to_string(m: LLVMModuleRef) -> CStr = "__llvm_print_module_to_string"

// ==================== Function ====================
// 
// Add a function to a module under a specified name.
// 
// @see llvm::Function::Create()
// 
// extern "C" fn llvm_add_function(m: LLVMModuleRef, name: CStr, function_ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_add_function"

// 
// Obtain a Function value from a Module by its name.
// 
// The returned value corresponds to a llvm::Function value.
// 
// @see llvm::Module::getFunction()
// 
// extern "C" fn llvm_get_named_function(m: LLVMModuleRef, name: CStr) -> LLVMValueRef = "__llvm_get_named_function"

// 
// Obtain an iterator to the first Function in a Module.
// 
// @see llvm::Module::begin()
// 
// extern "C" fn llvm_get_first_function(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_first_function"

// 
// Obtain an iterator to the last Function in a Module.
// 
// @see llvm::Module::end()
// 
// extern "C" fn llvm_get_last_function(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_last_function"


// ==================== Type

// 
// Print a representation of a module to a file. The ErrorMessage needs to be
// disposed with LLVMDisposeMessage. Returns 0 on success, 1 otherwise.
// 
// @see Module::print()
// 
// extern "C" fn llvm_print_module_to_file(module: LLVMModuleRef, filename: CStr, errmsg: CStr) -> LLVMBool = "__llvm_print_module_to_file"

//
// Determine whether a type instance is null.
//
// extern "C" fn llvm_type_is_null(ty: LLVMTypeRef) -> LLVMBool = "__llvm_type_is_null"
extern "C" fn is_null(self: LLVMTypeRef) -> LLVMBool = "__llvm_type_is_null"

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


// Determine whether a value instance is null.
//
// @see llvm::Constant::isNullValue()
extern "C" fn is_null(self: LLVMValueRef) -> LLVMBool = "__llvm_is_null"
extern "C" fn llvm_is_null(val: LLVMValueRef) -> LLVMBool = "__llvm_is_null"


// Determine whether the specified value instance is constant.
extern "C" fn llvm_const_int(ty: LLVMTypeRef, n: UInt64, sign_extend: LLVMBool) -> LLVMValueRef = "__llvm_const_int"
extern "C" fn llvm_is_const(val: LLVMValueRef) -> LLVMBool = "__llvm_is_const"
extern "C" fn llvm_set_value_name(val: LLVMValueRef, name: CStr, name_len: UInt) = "__llvm_set_value_name"
