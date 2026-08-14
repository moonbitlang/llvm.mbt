///|
/// Describes the successful effect of evaluating one top-level input.
pub(all) enum EvalOutcome {
  /// Reports a function body submitted persistently to the JIT.
  Defined(String)
  /// Reports a prototype made available to later code generation.
  Extern(String)
  /// Carries the native result of an anonymous expression.
  Value(Double)
} derive(Debug, Eq)
