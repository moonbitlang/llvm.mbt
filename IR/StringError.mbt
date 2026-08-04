///|
/// A string cannot be represented by the target LLVM API.
pub suberror StringError {
  ContainsNul
  MalformedUtf8(Bytes)
}

///|
#warnings("-unused_value")
fn[T] translate_cstring_error(
  call : () -> T raise @unsafe.CStringError,
) -> T raise StringError {
  call() catch {
    @unsafe.EmbeddedNul => raise ContainsNul
  }
}

///|
#warnings("-unused_value")
fn[T] translate_utf8_error(
  call : () -> T raise @utf8.Malformed,
) -> T raise StringError {
  call() catch {
    @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
  }
}
