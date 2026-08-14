///|
/// Represents one complete top-level form accepted by the parser.
pub(all) enum TopLevel {
  /// Defines a function from its prototype and body expression.
  Definition(Prototype, Expr)
  /// Declares a function whose implementation is supplied elsewhere.
  Extern(Prototype)
  /// Evaluates an anonymous top-level expression.
  Expression(Expr)
} derive(Debug, Eq)
