// =======================================================
// BitWriter.h
// =======================================================

// /** Writes a module to the specified path. Returns 0 on success. */
// int LLVMWriteBitcodeToFile(LLVMModuleRef M, const char *Path);
// TODO: Implement C function

///|
#borrow(path)
extern "C" fn __llvm_write_bitcode_to_file(
  mod_ref : LLVMModuleRef,
  path : Utf8Z,
) -> Int = "LLVMWriteBitcodeToFile"

///|
pub fn llvm_write_bitcode_to_file(
  mod_ref : LLVMModuleRef,
  path : String,
) -> Int {
  let path = Utf8Z::from_string(path) catch { EmbeddedNul => return 1 }
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
  unbuffered : Int,
) -> Int = "__llvm_write_bitcode_to_fd"
//
// /** Deprecated for LLVMWriteBitcodeToFD. Writes a module to an open file
//     descriptor. Returns 0 on success. Closes the Handle. */
// int LLVMWriteBitcodeToFileHandle(LLVMModuleRef M, int Handle);
// TODO: Implement C function

///|
pub extern "C" fn llvm_write_bitcode_to_file_handle(
  mod_ref : LLVMModuleRef,
  handle : Int,
) -> Int = "__llvm_write_bitcode_to_file_handle"
//

///|
/// Serializes a module to an independent byte array.
///
/// The C adapter copies the complete binary memory buffer, including embedded
/// NUL bytes, then disposes the LLVM-owned buffer before returning.
pub extern "C" fn llvm_write_bitcode_to_bytes(mod_ref : LLVMModuleRef) -> Bytes = "llvm_mbt_write_bitcode_to_bytes"
