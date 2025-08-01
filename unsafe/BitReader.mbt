// =======================================================
// BitReader.h
// =======================================================

// /* Builds a module from the bitcode in the specified memory buffer, returning a
//    reference to the module via the OutModule parameter. Returns 0 on success.
//    Optionally returns a human-readable error message via OutMessage.
//
//    This is deprecated. Use LLVMParseBitcode2. */
// LLVMBool LLVMParseBitcode(LLVMMemoryBufferRef MemBuf, LLVMModuleRef *OutModule,
//                           char **OutMessage);
// TODO: Implement C function

///|
//pub extern "C" fn llvm_parse_bitcode(
//  mem_buf : LLVMMemoryBufferRef
//) -> (LLVMModuleRef, String, LLVMBool) = "__llvm_parse_bitcode"
//
// /* Builds a module from the bitcode in the specified memory buffer, returning a
//    reference to the module via the OutModule parameter. Returns 0 on success. */
// LLVMBool LLVMParseBitcode2(LLVMMemoryBufferRef MemBuf,
//                            LLVMModuleRef *OutModule);
// TODO: Implement C function

extern "C" fn __llvm_parse_bitcode2(membuf: LLVMMemoryBufferRef, out_mod : Ref[LLVMModuleRef]) -> Bool = "LLVMParseBitcode2";

///|
pub fn llvm_parse_bitcode2(
  mem_buf : LLVMMemoryBufferRef
) -> LLVMModuleRef?  {
  let out_mod : Ref[LLVMModuleRef] = Ref::new(LLVMModuleRef::null());
  let result = __llvm_parse_bitcode2(mem_buf, out_mod);
  match result {
    true => Some(out_mod.val)
    false => None
  }
}
//
// /* This is deprecated. Use LLVMParseBitcodeInContext2. */
// LLVMBool LLVMParseBitcodeInContext(LLVMContextRef ContextRef,
//                                    LLVMMemoryBufferRef MemBuf,
//                                    LLVMModuleRef *OutModule, char **OutMessage);

///|
/// @alert Deprecated "Use llvm_parse_bitcode_in_context2 instead"
// TODO: Implement C function
pub extern "C" fn llvm_parse_bitcode_in_context(
  context_ref : LLVMContextRef,
  mem_buf : LLVMMemoryBufferRef
) -> (LLVMModuleRef, String, LLVMBool) = "__llvm_parse_bitcode_in_context"
//
// LLVMBool LLVMParseBitcodeInContext2(LLVMContextRef ContextRef,
//                                     LLVMMemoryBufferRef MemBuf,
//                                     LLVMModuleRef *OutModule);
// TODO: Implement C function

///|
pub extern "C" fn llvm_parse_bitcode_in_context2(
  context_ref : LLVMContextRef,
  mem_buf : LLVMMemoryBufferRef
) -> (LLVMModuleRef, LLVMBool) = "__llvm_parse_bitcode_in_context2"
//
// /** Reads a module from the specified path, returning via the OutMP parameter
//     a module provider which performs lazy deserialization. Returns 0 on success.
//     Optionally returns a human-readable error message via OutMessage.
//     This is deprecated. Use LLVMGetBitcodeModuleInContext2. */
// LLVMBool LLVMGetBitcodeModuleInContext(LLVMContextRef ContextRef,
//                                        LLVMMemoryBufferRef MemBuf,
//                                        LLVMModuleRef *OutM, char **OutMessage);

///|
pub extern "C" fn llvm_get_bitcode_module_in_context(
  context_ref : LLVMContextRef,
  mem_buf : LLVMMemoryBufferRef
) -> (LLVMModuleRef, String, LLVMBool) = "__llvm_get_bitcode_module_in_context"
//
// /** Reads a module from the given memory buffer, returning via the OutMP
//  * parameter a module provider which performs lazy deserialization.
//  *
//  * Returns 0 on success.
//  *
//  * Takes ownership of \p MemBuf if (and only if) the module was read
//  * successfully. */
// LLVMBool LLVMGetBitcodeModuleInContext2(LLVMContextRef ContextRef,
//                                         LLVMMemoryBufferRef MemBuf,
//                                         LLVMModuleRef *OutM);
// TODO: Implement C function

///|
pub extern "C" fn llvm_get_bitcode_module_in_context2(
  context_ref : LLVMContextRef,
  mem_buf : LLVMMemoryBufferRef
) -> (LLVMModuleRef, LLVMBool) = "__llvm_get_bitcode_module_in_context2"
//
// /* This is deprecated. Use LLVMGetBitcodeModule2. */
// LLVMBool LLVMGetBitcodeModule(LLVMMemoryBufferRef MemBuf, LLVMModuleRef *OutM,
//                               char **OutMessage);
// TODO: Implement C function

///|
pub extern "C" fn llvm_get_bitcode_module(
  mem_buf : LLVMMemoryBufferRef
) -> (LLVMModuleRef, String, LLVMBool) = "__llvm_get_bitcode_module"
//
// LLVMBool LLVMGetBitcodeModule2(LLVMMemoryBufferRef MemBuf, LLVMModuleRef *OutM);
// TODO: Implement C function

///|
pub extern "C" fn llvm_get_bitcode_module2(
  mem_buf : LLVMMemoryBufferRef
) -> (LLVMModuleRef, String, LLVMBool) = "__llvm_get_bitcode_module"
