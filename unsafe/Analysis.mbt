//
// /* Verifies that a module is valid, taking the specified action if not.
//    Optionally returns a human-readable description of any invalid constructs.
//    OutMessage must be disposed with LLVMDisposeMessage. */
// LLVMBool LLVMVerifyModule(LLVMModuleRef M, LLVMVerifierFailureAction Action,
//                           char **OutMessage);

///|
/// Verifies that a module is valid without printing or aborting.
/// The C adapter copies and disposes LLVM's optional diagnostic message.
#borrow(out_failed)
extern "C" fn __llvm_verify_module(
  mod_ref : LLVMModuleRef,
  out_failed : Ref[LLVMBool],
) -> Bytes = "llvm_mbt_verify_module"

///|
/// Verifies that a module is valid without printing or aborting.
/// Returns whether verification failed and LLVM's diagnostic text.
pub fn llvm_verify_module(mod_ref : LLVMModuleRef) -> (Bool, String) {
  let failed : Ref[LLVMBool] = Ref(0)
  let message = __llvm_verify_module(mod_ref, failed)
  (failed.val.to_moonbit_bool(), @utf8.decode_lossy(message))
}

//
// /* Verifies that a single function is valid, taking the specified action.
// Useful
//    for debugging. */
// LLVMBool LLVMVerifyFunction(LLVMValueRef Fn, LLVMVerifierFailureAction
// Action);

// TODO: Inplement C function

///|
pub extern "C" fn llvm_verify_function(
  fn_ref : LLVMValueRef,
  action : LLVMVerifierFailureAction,
) -> LLVMBool = "__llvm_verify_function"

// /* Open up a ghostview window that displays the CFG of the current function.
//    Useful for debugging. */
// void LLVMViewFunctionCFG(LLVMValueRef Fn);
// void LLVMViewFunctionCFGOnly(LLVMValueRef Fn);

///|
pub extern "C" fn llvm_view_function_cfg(fn_ref : LLVMValueRef) = "LLVMViewFunctionCFG"

///|
pub extern "C" fn llvm_view_function_cfg_only(fn_ref : LLVMValueRef) = "LLVMViewFunctionCFGOnly"
