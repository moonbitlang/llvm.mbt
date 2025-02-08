// /**
//  * @defgroup LLVMCAnalysis Analysis
//  * @ingroup LLVMC
//  *
//  * @{
//  */
//
// typedef enum {
//   LLVMAbortProcessAction, /* verifier will print to stderr and abort() */
//   LLVMPrintMessageAction, /* verifier will print to stderr and return 1 */
//   LLVMReturnStatusAction  /* verifier will just return 1 */
// } LLVMVerifierFailureAction;
//
//
// /* Verifies that a module is valid, taking the specified action if not.
//    Optionally returns a human-readable description of any invalid constructs.
//    OutMessage must be disposed with LLVMDisposeMessage. */
// LLVMBool LLVMVerifyModule(LLVMModuleRef M, LLVMVerifierFailureAction Action,
//                           char **OutMessage);
//
// /* Verifies that a single function is valid, taking the specified action.
// Useful
//    for debugging. */
// LLVMBool LLVMVerifyFunction(LLVMValueRef Fn, LLVMVerifierFailureAction
// Action);
//
// /* Open up a ghostview window that displays the CFG of the current function.
//    Useful for debugging. */
// void LLVMViewFunctionCFG(LLVMValueRef Fn);
// void LLVMViewFunctionCFGOnly(LLVMValueRef Fn);
