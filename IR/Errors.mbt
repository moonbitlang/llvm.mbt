///|
/// Reports that an index is outside the range accepted by an IR operation.
pub suberror IndexOutOfBounds {
  /// Carries a human-readable description of the invalid index and operation.
  IndexOutOfBounds(String)
}
