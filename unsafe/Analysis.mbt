//
// /* Verifies that a module is valid, taking the specified action if not.
//    Optionally returns a human-readable description of any invalid constructs.
//    OutMessage must be disposed with LLVMDisposeMessage. */
// LLVMBool LLVMVerifyModule(LLVMModuleRef M, LLVMVerifierFailureAction Action,
//                           char **OutMessage);

/// Verifies that a module is valid, taking the specified action if not.
/// Optionally returns a human-readable description of any invalid constructs.
/// OutMessage must be disposed with LLVMDisposeMessage. */
// TODO: Inplement C function
pub extern "C" fn llvm_verify_module(
  mod_ref: LLVMModuleRef, action: LLVMVerifierFailureAction
) -> (LLVMBool, String) =  "__llvm_verify_module"

//
// /* Verifies that a single function is valid, taking the specified action.
// Useful
//    for debugging. */
// LLVMBool LLVMVerifyFunction(LLVMValueRef Fn, LLVMVerifierFailureAction
// Action);

// TODO: Inplement C function
pub extern "C" fn llvm_verify_function(
  fn_ref: LLVMValueRef, action: LLVMVerifierFailureAction
) -> LLVMBool =  "__llvm_verify_function"

// /* Open up a ghostview window that displays the CFG of the current function.
//    Useful for debugging. */
// void LLVMViewFunctionCFG(LLVMValueRef Fn);
// void LLVMViewFunctionCFGOnly(LLVMValueRef Fn);

// TODO: Inplement C function
pub extern "C" fn llvm_view_function_cfg(fn_ref: LLVMValueRef) =  "__llvm_view_function_cfg"

// TODO: Inplement C function
pub extern "C" fn llvm_view_function_cfg_only(fn_ref: LLVMValueRef) =  "__llvm_view_function_cfg_only"
