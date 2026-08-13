///|
#borrow(out_jit, out_failed)
extern "C" fn __llvm_orc_create_lljit(
  out_jit : Ref[LLVMOrcLLJITRef],
  out_failed : Ref[LLVMBool],
) -> Bytes = "llvm_mbt_orc_create_lljit"

///|
pub fn llvm_orc_create_lljit() -> (LLVMOrcLLJITRef, String, Bool) {
  let out_jit = Ref(LLVMOrcLLJITRef::null())
  let out_failed = Ref(to_llvm_bool(false))
  let message = __llvm_orc_create_lljit(out_jit, out_failed)
  (out_jit.val, @utf8.decode_lossy(message), out_failed.val.to_moonbit_bool())
}

///|
#borrow(out_failed)
extern "C" fn __llvm_orc_dispose_lljit(
  jit : LLVMOrcLLJITRef,
  out_failed : Ref[LLVMBool],
) -> Bytes = "llvm_mbt_orc_dispose_lljit"

///|
pub fn llvm_orc_dispose_lljit(jit : LLVMOrcLLJITRef) -> (String, Bool) {
  let out_failed = Ref(to_llvm_bool(false))
  let message = __llvm_orc_dispose_lljit(jit, out_failed)
  (@utf8.decode_lossy(message), out_failed.val.to_moonbit_bool())
}

///|
pub extern "C" fn llvm_orc_lljit_get_main_jit_dylib(
  jit : LLVMOrcLLJITRef,
) -> LLVMOrcJITDylibRef = "LLVMOrcLLJITGetMainJITDylib"

///|
extern "C" fn __llvm_orc_lljit_get_triple_string(
  jit : LLVMOrcLLJITRef,
) -> Bytes = "llvm_mbt_orc_lljit_get_triple_string"

///|
pub fn llvm_orc_lljit_get_triple_string(jit : LLVMOrcLLJITRef) -> String {
  __llvm_orc_lljit_get_triple_string(jit) |> @utf8.decode_lossy
}

///|
extern "C" fn __llvm_orc_lljit_get_data_layout_str(
  jit : LLVMOrcLLJITRef,
) -> Bytes = "llvm_mbt_orc_lljit_get_data_layout_str"

///|
pub fn llvm_orc_lljit_get_data_layout_str(jit : LLVMOrcLLJITRef) -> String {
  __llvm_orc_lljit_get_data_layout_str(jit) |> @utf8.decode_lossy
}

///|
pub extern "C" fn llvm_orc_lljit_get_global_prefix(
  jit : LLVMOrcLLJITRef,
) -> Int = "llvm_mbt_orc_lljit_get_global_prefix"

///|
#borrow(name, out_address, out_failed)
extern "C" fn __llvm_orc_lljit_lookup(
  jit : LLVMOrcLLJITRef,
  name : Utf8Z,
  out_address : Ref[LLVMOrcExecutorAddress],
  out_failed : Ref[LLVMBool],
) -> Bytes = "llvm_mbt_orc_lljit_lookup"

///|
pub fn llvm_orc_lljit_lookup(
  jit : LLVMOrcLLJITRef,
  name : String,
) -> (LLVMOrcExecutorAddress, String, Bool) raise CStringError {
  let name = Utf8Z::from_string(name)
  let out_address = Ref(LLVMOrcExecutorAddress::default())
  let out_failed = Ref(to_llvm_bool(false))
  let message = __llvm_orc_lljit_lookup(jit, name, out_address, out_failed)
  (
    out_address.val,
    @utf8.decode_lossy(message),
    out_failed.val.to_moonbit_bool(),
  )
}
