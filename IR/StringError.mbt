///|
/// A string cannot be represented by the target LLVM API.
pub suberror StringError {
  ContainsNul
  MalformedUtf8(Bytes)
}
