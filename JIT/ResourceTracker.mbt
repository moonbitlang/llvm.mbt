///|
/// A managed ORC resource group belonging to one `LLJIT` session.
///
/// Modules submitted with the same tracker are unloaded together by `remove`.
///
/// **Construction:** Use `LLJIT::createResourceTracker`.
///
/// **Lifecycle:** The wrapper owns one client reference to the native tracker
/// and retains its LLJIT session. Its finalizer releases that reference but
/// does not remove code. Successful `remove` or session `close` invalidates all
/// aliases and releases the client reference exactly once.
pub struct ResourceTracker {
  priv owner : ResourceTrackerOwner
  priv jitOwner : LLJITOwner
}

///|
fn ResourceTracker::fromOwner(
  owner : ResourceTrackerOwner,
  jitOwner : LLJITOwner,
) -> ResourceTracker {
  ResourceTracker::{ owner, jitOwner, }
}

///|
#warnings("-unused_value")
fn ResourceTracker::getOwner(self : ResourceTracker) -> ResourceTrackerOwner {
  self.owner
}

///|
#warnings("-unused_value")
fn ResourceTracker::getJitOwner(self : ResourceTracker) -> LLJITOwner {
  self.jitOwner
}

///|
#warnings("-unused_value")
fn ResourceTracker::requireRaw(
  self : ResourceTracker,
) -> @raw.LLVMOrcResourceTrackerRef raise JITError {
  guard self.jitOwner.isOpen() else { raise Closed }
  guard self.owner.isActive() else { raise ResourceTrackerRemoved }
  self.owner.raw()
}

///|
/// Creates an independent resource group in this session's main JITDylib.
///
/// **Errors:** Raises `Closed` after the session has been closed.
///
/// **Lifecycle:** The returned tracker retains this session. Dropping the
/// tracker without calling `remove` releases only its client reference; code
/// remains managed by the JIT until session close.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let context = @IR.Context::new()
///   let mod = context.addModule("tracked")
///   mod.verify()
///   let jit = LLJIT::host()
///   let tracker = jit.createResourceTracker()
///   jit.addModule(mod, tracker~)
///   tracker.remove()
///   let removed = try {
///     tracker.remove()
///     false
///   } catch {
///     JITError::ResourceTrackerRemoved => true
///     _ => false
///   }
///   inspect(removed, content="true")
///   jit.close()
/// }
/// ```
pub fn LLJIT::createResourceTracker(
  self : LLJIT,
) -> ResourceTracker raise JITError {
  self.requireRaw() |> ignore
  ResourceTracker::fromOwner(self.owner.newTracker(), self.owner)
}

///|
/// Removes all JIT resources associated with this tracker.
///
/// **Errors:** Raises `Closed` if the parent session was closed,
/// `ResourceTrackerRemoved` after a successful prior removal, or
/// `ResourceRemovalFailed` with LLVM's diagnostic when removal fails.
///
/// **Lifecycle:** A successful call invalidates every alias of this tracker and
/// all addresses or function pointers into its removed code. This operation is
/// explicit and one-shot; the finalizer never performs it automatically.
///
/// **See also:** `LLJIT::createResourceTracker` provides a complete tracked
/// submission and removal example.
pub fn ResourceTracker::remove(self : ResourceTracker) -> Unit raise JITError {
  guard self.jitOwner.isOpen() else { raise Closed }
  guard self.owner.isActive() else { raise ResourceTrackerRemoved }
  let (message, failed) = self.owner.remove()
  guard !failed else { raise ResourceRemovalFailed(message) }
}
