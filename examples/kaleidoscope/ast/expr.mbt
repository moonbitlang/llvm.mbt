///|
/// Describes one mutable local introduced by a `var/in` expression.
pub(all) struct VarBinding {
  /// Stores the source-level variable name.
  name : String
  /// Stores the initializer, or `None` for the default value `0.0`.
  initializer : Expr?
} derive(Debug, Eq)

///|
/// Represents an expression in the implemented Kaleidoscope language.
pub(all) enum Expr {
  /// Stores a double-precision numeric literal.
  Number(Double)
  /// Refers to a function parameter or another value in lexical scope.
  Variable(String)
  /// Applies one binary operator to two operand expressions.
  Binary(Char, Expr, Expr)
  /// Applies a user-defined unary operator to one operand expression.
  Unary(Char, Expr)
  /// Calls a named function with zero or more argument expressions.
  Call(String, Array[Expr])
  /// Selects one of two expressions using a zero/nonzero condition.
  If(Expr, Expr, Expr)
  /// Iterates a lexical variable from its start while the end condition is
  /// nonzero, using an optional step expression, then returns `0.0`.
  For(String, Expr, Expr, Expr?, Expr)
  /// Introduces one or more mutable lexical bindings for a body expression.
  Var(Array[VarBinding], Expr)
  /// Stores a value in an existing lexical binding and returns that value.
  Assign(String, Expr)
} derive(Debug, Eq)
