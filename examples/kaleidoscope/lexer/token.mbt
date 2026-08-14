///|
/// Identifies a location in a Kaleidoscope source buffer.
///
/// Offsets are zero-based UTF-16 code-unit offsets. Lines and columns are
/// one-based; columns also advance in UTF-16 code units.
pub(all) struct SourcePos {
  /// Stores the offset from the beginning of the complete source buffer.
  offset : Int
  /// Stores the one-based source line.
  line : Int
  /// Stores the one-based column within the current line.
  column : Int
} derive(Debug, Eq)

///|
/// Formats a source position as `line:column`.
pub impl Show for SourcePos with fn output(self, logger) {
  logger.write_object(self.line)
  logger.write_string(":")
  logger.write_object(self.column)
}

///|
/// Describes the lexical category and optional value of a Kaleidoscope token.
pub(all) enum TokenKind {
  /// Introduces a function definition.
  Def
  /// Declares a function supplied by another JIT module or the host process.
  Extern
  /// Introduces a conditional expression.
  If
  /// Separates a conditional expression from its true branch.
  Then
  /// Introduces the false branch of a conditional expression.
  Else
  /// Introduces a counting loop.
  For
  /// Separates loop bindings or local bindings from their body.
  In
  /// Introduces a user-defined binary operator prototype.
  Binary
  /// Introduces a user-defined unary operator prototype.
  Unary
  /// Introduces mutable local bindings.
  Var
  /// Stores an identifier spelling.
  Identifier(String)
  /// Stores a parsed double-precision numeric literal.
  Number(Double)
  /// Stores a single-character operator spelling.
  Operator(Char)
  /// Represents `(`.
  LeftParen
  /// Represents `)`.
  RightParen
  /// Represents `,`.
  Comma
  /// Represents `;`.
  Semicolon
  /// Marks the end of the complete source buffer.
  Eof
} derive(Debug, Eq)

///|
/// Formats a token kind using its constructor-oriented representation.
pub impl Show for TokenKind with fn output(self, logger) {
  logger.write_string(repr(self))
}

///|
/// Stores one token and the half-open source range that produced it.
pub(all) struct Token {
  /// Stores the lexical category and optional token value.
  kind : TokenKind
  /// Stores the inclusive start of the token.
  start : SourcePos
  /// Stores the exclusive end of the token.
  end : SourcePos
} derive(Debug, Eq)

///|
/// Formats a token as its kind followed by its half-open source range.
pub impl Show for Token with fn output(self, logger) {
  logger.write_object(self.kind)
  logger.write_string("@")
  logger.write_object(self.start)
  logger.write_string("..")
  logger.write_object(self.end)
}
