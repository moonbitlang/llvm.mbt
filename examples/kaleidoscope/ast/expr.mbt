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
} derive(Debug, Eq)
