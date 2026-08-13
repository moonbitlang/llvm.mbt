///|
/// Reports a failure while creating, using, unloading, or closing an ORC JIT
/// session.
#warnings("-unused_constructor")
pub suberror JITError {
  /// LLJIT initialization or construction failed; contains its diagnostic.
  CreationFailed(String)
  /// An IR module could not be serialized or parsed into an independent JIT
  /// snapshot; contains its diagnostic.
  SnapshotFailed(String)
  /// ORC rejected or failed to materialize a submitted module; contains its
  /// diagnostic.
  SubmissionFailed(String)
  /// ORC could not resolve or materialize a requested symbol; contains its
  /// diagnostic.
  LookupFailed(String)
  /// A resource tracker could not remove its associated code; contains its
  /// diagnostic.
  ResourceRemovalFailed(String)
  /// LLJIT session shutdown failed; contains its diagnostic.
  CloseFailed(String)
  /// The operation requires a JIT session that has not been closed.
  Closed
  /// The operation requires a resource tracker that has not been removed.
  ResourceTrackerRemoved
  /// The supplied resource tracker belongs to another LLJIT session.
  ResourceTrackerOwnerMismatch
}
