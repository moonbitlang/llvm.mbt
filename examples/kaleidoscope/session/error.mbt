///|
/// Reports a recoverable failure while parsing, compiling, submitting, or
/// evaluating one Kaleidoscope input.
pub suberror SessionError {
  /// Preserves a lexer diagnostic from the submitted source.
  LexerFailure(@lexer.LexError)
  /// Preserves a parser diagnostic from the submitted source.
  ParserFailure(@parser.ParseError)
  /// Preserves a code-generation or catalog diagnostic.
  CodegenFailure(@codegen.CodegenError)
  /// Preserves an ORC JIT lifecycle or lookup diagnostic.
  JITFailure(String)
  /// Preserves an invalid or malformed symbol name reported by the IR layer.
  IRStringFailure(String)
  /// Reports use after the Session has been explicitly closed.
  Closed
  /// Reports that cleanup failed while another operation was already failing.
  CleanupFailure(String, String)
  /// Reports an unexpected open error escaping a lower-level API.
  UnexpectedFailure(String)
} derive(Debug)

///|
fn describe_jit_error(error : @JIT.JITError) -> String {
  match error {
    CreationFailed(message) => "JIT creation failed: \{message}"
    SnapshotFailed(message) => "module snapshot failed: \{message}"
    SubmissionFailed(message) => "module submission failed: \{message}"
    LookupFailed(message) => "symbol lookup failed: \{message}"
    ResourceRemovalFailed(message) => "resource removal failed: \{message}"
    CloseFailed(message) => "JIT close failed: \{message}"
    Closed => "JIT session is closed"
    ResourceTrackerRemoved => "resource tracker was already removed"
    ResourceTrackerOwnerMismatch => "resource tracker belongs to another JIT"
  }
}

///|
fn describe_ir_string_error(error : @IR.StringError) -> String {
  match error {
    ContainsNul => "string contains an embedded NUL byte"
    MalformedUtf8(_) => "LLVM returned malformed UTF-8"
  }
}

///|
/// Returns a concise diagnostic suitable for the interactive REPL.
pub fn SessionError::message(self : SessionError) -> String {
  match self {
    LexerFailure(error) =>
      match error {
        InvalidCharacter(character, position) =>
          "lex error at \{position}: invalid character `\{character}`"
        MalformedNumber(spelling, position) =>
          "lex error at \{position}: malformed number `\{spelling}`"
      }
    ParserFailure(error) =>
      match error {
        UnexpectedToken(token, expected) =>
          "parse error at \{token.start}: expected \{expected}, found \{token.kind}"
        UnexpectedEndOfInput(position, expected) =>
          "parse error at \{position}: expected \{expected}, found end of input"
        DuplicateParameter(name, position) =>
          "parse error at \{position}: duplicate parameter `\{name}`"
        InvalidOperatorPrototype(position, message) =>
          "parse error at \{position}: \{message}"
        DuplicateBinding(name, position) =>
          "parse error at \{position}: duplicate binding `\{name}`"
        InvalidAssignmentTarget(position) =>
          "parse error at \{position}: assignment target must be a variable"
      }
    CodegenFailure(error) =>
      match error {
        UnknownVariable(name) => "unknown variable `\{name}`"
        UnknownFunction(name) => "unknown function `\{name}`"
        DuplicateDefinition(name) => "function `\{name}` is already defined"
        ConflictingPrototype(name, expected, actual) =>
          "function `\{name}` has arity \{expected}, not \{actual}"
        ArgumentCountMismatch(name, expected, actual) =>
          "call to `\{name}` expects \{expected} arguments, received \{actual}"
        InvalidPrototype(message) => "invalid prototype: \{message}"
        InvalidVariableBinding(message) =>
          "invalid variable binding: \{message}"
        BackendFailure(message) => "LLVM construction failed: \{message}"
        VerificationFailed(message) => "LLVM verification failed: \{message}"
      }
    JITFailure(message)
    | IRStringFailure(message)
    | UnexpectedFailure(message) => message
    Closed => "Kaleidoscope session is closed"
    CleanupFailure(primary, cleanup) =>
      "\{primary}; cleanup also failed: \{cleanup}"
  }
}

///|
/// Formats this error using its REPL diagnostic.
pub impl Show for SessionError with fn output(self, logger) {
  logger.write_string(self.message())
}
