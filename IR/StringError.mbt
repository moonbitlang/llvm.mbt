///|
/// Reports that a MoonBit string cannot cross an LLVM string boundary safely.
pub(all) suberror StringError {
  /// The input contains a NUL byte that would terminate an LLVM C string early.
  ContainsNul
  /// LLVM returned bytes that are not valid UTF-8.
  ///
  /// The payload preserves the original bytes for diagnostics or lossless
  /// recovery.
  MalformedUtf8(Bytes)
}
