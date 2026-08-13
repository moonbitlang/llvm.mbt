///|
pub extern "C" fn llvm_orc_create_new_thread_safe_context() -> LLVMOrcThreadSafeContextRef = "LLVMOrcCreateNewThreadSafeContext"

///|
pub extern "C" fn llvm_orc_dispose_thread_safe_context(
  context : LLVMOrcThreadSafeContextRef,
) -> Unit = "LLVMOrcDisposeThreadSafeContext"

///|
pub extern "C" fn llvm_orc_dispose_thread_safe_module(
  thread_safe_module : LLVMOrcThreadSafeModuleRef,
) -> Unit = "LLVMOrcDisposeThreadSafeModule"

///|
pub extern "C" fn llvm_orc_jit_dylib_create_resource_tracker(
  jit_dylib : LLVMOrcJITDylibRef,
) -> LLVMOrcResourceTrackerRef = "LLVMOrcJITDylibCreateResourceTracker"

///|
pub extern "C" fn llvm_orc_jit_dylib_get_default_resource_tracker(
  jit_dylib : LLVMOrcJITDylibRef,
) -> LLVMOrcResourceTrackerRef = "LLVMOrcJITDylibGetDefaultResourceTracker"

///|
pub extern "C" fn llvm_orc_release_resource_tracker(
  tracker : LLVMOrcResourceTrackerRef,
) -> Unit = "LLVMOrcReleaseResourceTracker"

///|
pub extern "C" fn llvm_orc_resource_tracker_transfer_to(
  source : LLVMOrcResourceTrackerRef,
  destination : LLVMOrcResourceTrackerRef,
) -> Unit = "LLVMOrcResourceTrackerTransferTo"

///|
#borrow(out_failed)
extern "C" fn __llvm_orc_resource_tracker_remove(
  tracker : LLVMOrcResourceTrackerRef,
  out_failed : Ref[LLVMBool],
) -> Bytes = "llvm_mbt_orc_resource_tracker_remove"

///|
pub fn llvm_orc_resource_tracker_remove(
  tracker : LLVMOrcResourceTrackerRef,
) -> (String, Bool) {
  let out_failed = Ref(to_llvm_bool(false))
  let message = __llvm_orc_resource_tracker_remove(tracker, out_failed)
  (@utf8.decode_lossy(message), out_failed.val.to_moonbit_bool())
}

///|
#borrow(bitcode, out_module, out_failed)
extern "C" fn __llvm_orc_create_thread_safe_module_from_bitcode(
  bitcode : Bytes,
  out_module : Ref[LLVMOrcThreadSafeModuleRef],
  out_failed : Ref[LLVMBool],
) -> Bytes = "llvm_mbt_orc_create_thread_safe_module_from_bitcode"

///|
pub fn llvm_orc_create_thread_safe_module_from_bitcode(
  bitcode : Bytes,
) -> (LLVMOrcThreadSafeModuleRef, String, Bool) {
  let out_module = Ref(LLVMOrcThreadSafeModuleRef::null())
  let out_failed = Ref(to_llvm_bool(false))
  let message = __llvm_orc_create_thread_safe_module_from_bitcode(
    bitcode, out_module, out_failed,
  )
  (
    out_module.val,
    @utf8.decode_lossy(message),
    out_failed.val.to_moonbit_bool(),
  )
}
