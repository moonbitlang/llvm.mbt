// =======================================================
// Linker.h
// =======================================================

///| Links the source module into the destination module.
/// 
/// Links the source module into the destination module. The source 
/// module is destroyed.
/// The return value is true if an error occurred, false otherwise.
/// Use the diagnostic handler to get any diagnostic message.
pub fn llvm_link_modules(dest : LLVMModuleRef, src : LLVMModuleRef) -> Bool {
  __llvm_link_modules2(dest, src).to_moonbit_bool()
}

///|
extern "C" fn __llvm_link_modules2(
  dest : LLVMModuleRef,
  src : LLVMModuleRef
) -> LLVMBool = "LLVMLinkModules2"
