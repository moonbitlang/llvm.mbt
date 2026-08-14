///|
/// Represents an expression in the currently implemented Kaleidoscope core.
pub(all) enum Expr {
  /// Stores a double-precision numeric literal.
  Number(Double)
  /// Refers to a function parameter or another value in lexical scope.
  Variable(String)
  /// Applies one binary operator to two operand expressions.
  Binary(Char, Expr, Expr)
  /// Calls a named function with zero or more argument expressions.
  Call(String, Array[Expr])
  /// Selects one of two expressions using a zero/nonzero condition.
  If(Expr, Expr, Expr)
  /// Iterates a lexical variable from its start while the end condition is
  /// nonzero, using an optional step expression, then returns `0.0`.
  For(String, Expr, Expr, Expr?, Expr)
} derive(Debug, Eq)
