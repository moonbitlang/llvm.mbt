// /**
//  * @defgroup LLVMCCoreIRReader IR Reader
//  * @ingroup LLVMCCore
//  *
//  * @{
//  */
//
// /**
//  * Read LLVM IR from a memory buffer and convert it into an in-memory Module
//  * object. Returns 0 on success.
//  * Optionally returns a human-readable description of any errors that
//  * occurred during parsing IR. OutMessage must be disposed with
//  * LLVMDisposeMessage.
//  *
//  * @see llvm::ParseIR()
//  */
// LLVMBool LLVMParseIRInContext(LLVMContextRef ContextRef,
//                               LLVMMemoryBufferRef MemBuf, LLVMModuleRef
//                               *OutM, char **OutMessage);
