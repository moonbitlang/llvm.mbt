// =======================================================
// BitWriter.h
// =======================================================

// /** Writes a module to the specified path. Returns 0 on success. */
// int LLVMWriteBitcodeToFile(LLVMModuleRef M, const char *Path);
// TODO: Implement C function
///|
extern "C" fn __llvm_write_bitcode_to_file(
  mod_ref : LLVMModuleRef,
  path : CStr
) -> Int = "__llvm_write_bitcode_to_file"

///|
pub fn llvm_write_bitcode_to_file(
  mod_ref : LLVMModuleRef,
  path : String
) -> Int {
  let path = moonbit_str_to_c_str(path)
  __llvm_write_bitcode_to_file(mod_ref, path)
}
//
// /** Writes a module to an open file descriptor. Returns 0 on success. */
// int LLVMWriteBitcodeToFD(LLVMModuleRef M, int FD, int ShouldClose,
//                          int Unbuffered);
// TODO: Implement C function

///|
pub extern "C" fn llvm_write_bitcode_to_fd(
  mod_ref : LLVMModuleRef,
  fd : Int,
  should_close : Int,
  unbuffered : Int
) -> Int = "__llvm_write_bitcode_to_fd"
//
// /** Deprecated for LLVMWriteBitcodeToFD. Writes a module to an open file
//     descriptor. Returns 0 on success. Closes the Handle. */
// int LLVMWriteBitcodeToFileHandle(LLVMModuleRef M, int Handle);
// TODO: Implement C function

///|
pub extern "C" fn llvm_write_bitcode_to_file_handle(
  mod_ref : LLVMModuleRef,
  handle : Int
) -> Int = "__llvm_write_bitcode_to_file_handle"
//
// /** Writes a module to a new memory buffer and returns it. */
// LLVMMemoryBufferRef LLVMWriteBitcodeToMemoryBuffer(LLVMModuleRef M);
// TODO: Implement C function

///|
pub extern "C" fn llvm_write_bitcode_to_memory_buffer(
  mod_ref : LLVMModuleRef
) -> LLVMMemoryBufferRef = "__llvm_write_bitcode_to_memory_buffer"
