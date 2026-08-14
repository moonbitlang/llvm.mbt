///|
/// Reports that a supported Kaleidoscope AST cannot be lowered to valid LLVM
/// IR with the current prototype catalog.
pub suberror CodegenError {
  /// Reports a variable that is not bound in the current lexical scope.
  UnknownVariable(String)
  /// Reports a call to a function absent from the current module and catalog.
  UnknownFunction(String)
  /// Reports a second body for a function that is already defined.
  DuplicateDefinition(String)
  /// Reports incompatible arities for two prototypes with the same name.
  ConflictingPrototype(String, Int, Int)
  /// Reports a call whose actual arity differs from its prototype.
  ArgumentCountMismatch(String, Int, Int)
  /// Reports a malformed prototype constructed outside the parser.
  InvalidPrototype(String)
  /// Wraps a failure reported while constructing LLVM IR.
  BackendFailure(String)
  /// Wraps an LLVM verifier diagnostic for a completed module.
  VerificationFailed(String)
} derive(Debug)
