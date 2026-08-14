///|
/// Reports that valid Kaleidoscope tokens do not form one supported top-level
/// construct.
pub suberror ParseError {
  /// Reports a token that is invalid at its position; the string describes the
  /// expected grammar element.
  UnexpectedToken(@lexer.Token, String)
  /// Reports that EOF occurred before the expected grammar element.
  UnexpectedEndOfInput(@lexer.SourcePos, String)
  /// Reports a repeated function parameter name and the duplicate occurrence.
  DuplicateParameter(String, @lexer.SourcePos)
  /// Reports an invalid operator character, precedence, or parameter count.
  InvalidOperatorPrototype(@lexer.SourcePos, String)
} derive(Debug)
