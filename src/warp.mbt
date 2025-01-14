

extern "C" fn moonbit_str_to_c_str(s: String) -> CStr = "moonbit_str_to_c_str"
extern "C" fn c_str_to_moonbit_str(s: CStr) -> String = "c_str_to_moonbit_str"

extern "C" fn llvm_context_create() -> LLVMContextRef = "__llvm_context_create"
extern "C" fn llvm_int32_type_in_context(ctx: LLVMContextRef) -> LLVMTypeRef = "__llvm_int32_type_in_context"

// extern "C" fn llvm_type_is_null(ty: LLVMTypeRef) -> LLVMBool = "__llvm_type_is_null"
extern "C" fn is_null(self: LLVMTypeRef) -> LLVMBool = "__llvm_type_is_null"
extern "C" fn llvm_print_type_to_string(val: LLVMTypeRef) -> CStr = "__llvm_print_type_to_string"
extern "C" fn llvm_dump_type(ty: LLVMTypeRef) = "__llvm_dump_type"

extern "C" fn llvm_dump_value(val: LLVMValueRef) = "__llvm_dump_value"
extern "C" fn llvm_print_value_to_string(val: LLVMValueRef) -> CStr = "__llvm_print_value_to_string"

extern "C" fn is_null(self: LLVMValueRef) -> LLVMBool = "__llvm_is_null"
extern "C" fn llvm_is_null(val: LLVMValueRef) -> LLVMBool = "__llvm_is_null"


extern "C" fn llvm_const_int(ty: LLVMTypeRef, n: UInt64, sign_extend: LLVMBool) -> LLVMValueRef = "__llvm_const_int"
extern "C" fn llvm_is_const(val: LLVMValueRef) -> LLVMBool = "__llvm_is_const"
extern "C" fn llvm_set_value_name(val: LLVMValueRef, name: CStr, name_len: UInt) = "__llvm_set_value_name"
