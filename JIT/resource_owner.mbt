///|
/// Managed shared state for one native LLJIT session.
priv type LLJITOwner

///|
extern "C" fn LLJITOwner::new(raw : @raw.LLVMOrcLLJITRef) -> LLJITOwner = "llvm_mbt_jit_owner_new"

///|
#borrow(self)
extern "C" fn LLJITOwner::isOpen(self : LLJITOwner) -> Bool = "llvm_mbt_jit_owner_is_open"

///|
#borrow(self)
extern "C" fn LLJITOwner::raw(self : LLJITOwner) -> @raw.LLVMOrcLLJITRef = "llvm_mbt_jit_owner_raw"

///|
#borrow(self, out_failed)
extern "C" fn LLJITOwner::closeRaw(
  self : LLJITOwner,
  out_failed : Ref[Bool],
) -> Bytes = "llvm_mbt_jit_owner_close"

///|
fn LLJITOwner::close(self : LLJITOwner) -> (String, Bool) {
  let out_failed = Ref(false)
  let message = self.closeRaw(out_failed)
  (@utf8.decode_lossy(message), out_failed.val)
}
