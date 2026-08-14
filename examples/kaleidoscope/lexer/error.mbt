///|
/// Reports that a Kaleidoscope source buffer cannot be tokenized.
pub suberror LexError {
  /// Reports an unsupported source character and its location.
  InvalidCharacter(Char, SourcePos)
  /// Reports a numeric-looking spelling that is not a valid `Double` literal.
  MalformedNumber(String, SourcePos)
} derive(Debug)
