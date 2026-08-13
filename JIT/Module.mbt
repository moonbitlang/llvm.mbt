///|
fn threadSafeModuleFromBytes(
  bitcode : Bytes,
) -> @raw.LLVMOrcThreadSafeModuleRef raise JITError {
  let (thread_safe_module, message, failed) = @raw.llvm_orc_create_thread_safe_module_from_bitcode(
    bitcode,
  )
  guard !failed else { raise SnapshotFailed(message) }
  thread_safe_module
}

///|
/// Submits an independent bitcode snapshot of `mod` to this JIT session.
///
/// When `tracker` is omitted, generated resources live until session close. A
/// supplied tracker can group one or more submissions for explicit removal.
///
/// **Parameters:**
///
/// - `mod`: The source module to snapshot; it is borrowed and remains usable.
/// - `tracker`: An optional active tracker created by this exact session.
///
/// **Errors:** Raises `Closed`, `ResourceTrackerRemoved`, or
/// `ResourceTrackerOwnerMismatch` for invalid lifecycle combinations;
/// `SnapshotFailed` if the independent bitcode copy cannot be parsed; or
/// `SubmissionFailed` with LLVM's diagnostic if ORC rejects the snapshot.
///
/// **Preconditions:** Call `Module::verify` explicitly when validated IR is
/// required. Submission intentionally does not run the verifier.
///
/// **Lifecycle:** ORC consumes only the independent ThreadSafeModule. The
/// source module, its context, and all derived wrappers retain their existing
/// owners and validity. A supplied tracker controls the generated copy only.
///
/// **Side effects:** Adds definitions to the main JITDylib. LLVM may fill a
/// default DataLayout on the private snapshot, but this method does not alter
/// the source module's triple, DataLayout, or IR.
pub fn LLJIT::addModule(
  self : LLJIT,
  mod : @IR.Module,
  tracker? : ResourceTracker,
) -> Unit raise JITError {
  let jit_raw = self.requireRaw()
  let tracker_raw = match tracker {
    None => None
    Some(resource_tracker) => {
      guard resource_tracker.owner.belongsTo(self.owner) else {
        raise ResourceTrackerOwnerMismatch
      }
      Some(resource_tracker.requireRaw())
    }
  }
  let thread_safe_module = threadSafeModuleFromBytes(mod.writeBitCodeToBytes())
  let (message, failed) = match tracker_raw {
    None => @raw.llvm_orc_lljit_add_llvm_ir_module(jit_raw, thread_safe_module)
    Some(raw) =>
      @raw.llvm_orc_lljit_add_llvm_ir_module_with_rt(
        jit_raw, raw, thread_safe_module,
      )
  }
  guard !failed else { raise SubmissionFailed(message) }
}
