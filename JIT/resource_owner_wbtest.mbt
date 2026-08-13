///|
#borrow(owner)
extern "C" fn jit_owner_test_watch(owner : LLJITOwner) -> Unit = "llvm_mbt_jit_owner_test_watch"

///|
extern "C" fn jit_owner_test_take_trace() -> UInt64 = "llvm_mbt_jit_owner_test_take_trace"

///|
#borrow(owner)
extern "C" fn jit_tracker_owner_test_watch(
  owner : ResourceTrackerOwner,
) -> Unit = "llvm_mbt_jit_tracker_owner_test_watch"

///|
test "LLJIT aliases share one explicit close" {
  let jit = LLJIT::host()
  let other = jit
  jit_owner_test_watch(jit.getOwnerForTest())
  jit.close()
  inspect(jit_owner_test_take_trace(), content="1")
  let closed = try {
    other.close()
    false
  } catch {
    Closed => true
    _ => false
  }
  inspect(closed, content="true")
}

///|
fn leave_open_jit(owner_slot : Ref[LLJITOwner?]) -> Unit raise JITError {
  let jit = LLJIT::host()
  owner_slot.val = Some(jit.getOwnerForTest())
  jit_owner_test_watch(jit.getOwnerForTest())
}

///|
test "LLJIT finalizer is a single close fallback" {
  let owner_slot : Ref[LLJITOwner?] = Ref(None)
  leave_open_jit(owner_slot)
  owner_slot.val = None
  inspect(jit_owner_test_take_trace(), content="1")
}

///|
test "resource tracker aliases share one explicit removal" {
  let jit = LLJIT::host()
  let tracker = jit.createResourceTracker()
  let other = tracker
  jit_tracker_owner_test_watch(tracker.getOwner())
  tracker.remove()
  inspect(jit_owner_test_take_trace(), content="32")
  let removed = try {
    other.remove()
    false
  } catch {
    ResourceTrackerRemoved => true
    _ => false
  }
  inspect(removed, content="true")
  jit.close()
}

///|
test "session close invalidates and releases live trackers" {
  let jit = LLJIT::host()
  let tracker = jit.createResourceTracker()
  jit_tracker_owner_test_watch(tracker.getOwner())
  jit.close()
  inspect(jit_owner_test_take_trace(), content="2")
  let closed = try {
    tracker.remove()
    false
  } catch {
    Closed => true
    _ => false
  }
  inspect(closed, content="true")
}
