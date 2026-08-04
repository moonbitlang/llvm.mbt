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

///|
#borrow(out_m, out_failed)
extern "C" fn __llvm_parse_ir_in_context(
  ctx_ref : LLVMContextRef,
  mem_buf : LLVMMemoryBufferRef,
  out_m : Ref[LLVMModuleRef],
  out_failed : Ref[LLVMBool],
) -> Bytes = "llvm_mbt_parse_ir_in_context"

///|
/// Read LLVM IR from a memory buffer and convert it into an in-memory Module object.
///
/// Read LLVM IR from a memory buffer and convert it into an in-memory Module
/// object. Returns 0 on success.
/// Optionally returns a human-readable description of any errors that
/// occurred during parsing IR. The C adapter disposes LLVM's message after
/// copying it into MoonBit bytes.
/// 
/// - see llvm::ParseIR()
/// 
pub fn llvm_parse_ir_in_context(
  ctx_ref : LLVMContextRef,
  mem_buf : LLVMMemoryBufferRef,
) -> (LLVMModuleRef, String, LLVMBool) {
  let out_m_ref : Ref[LLVMModuleRef] = Ref(LLVMModuleRef::null())
  let failed : Ref[LLVMBool] = Ref(0)
  let message = __llvm_parse_ir_in_context(ctx_ref, mem_buf, out_m_ref, failed)
  (out_m_ref.val, @utf8.decode_lossy(message), failed.val)
}

///|
/// Read LLVM IR from a memory buffer and convert it into an in-memory Module object.
///
/// Read LLVM IR from a memory buffer and convert it into an in-memory Module
/// object. Returns 0 on success.
/// Optionally returns a human-readable description of any errors that
/// occurred during parsing IR. The C adapter disposes LLVM's message after
/// copying it into MoonBit bytes.
/// 
/// - see llvm::ParseIR()
/// 
pub fn LLVMContextRef::parse_ir(
  self : LLVMContextRef,
  membuf : LLVMMemoryBufferRef,
) -> (LLVMModuleRef, String, Bool) {
  let (mod, err, failed) = llvm_parse_ir_in_context(self, membuf)
  (mod, err, failed.into())
}
