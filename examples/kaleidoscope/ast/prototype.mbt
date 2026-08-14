///|
/// Classifies a Kaleidoscope function prototype.
pub(all) enum PrototypeKind {
  /// Declares a normally named function.
  Normal
  /// Declares a one-argument operator implemented by `unaryX`.
  Unary(Char)
  /// Declares a two-argument operator implemented by `binaryX`, together with
  /// its parser precedence.
  Binary(Char, Int)
} derive(Debug, Eq)

///|
/// Describes the symbol, parameters, and source-level role of a function.
pub(all) struct Prototype {
  /// Stores the symbol name used by generated LLVM IR and JIT lookup.
  name : String
  /// Stores parameter names in source and ABI order.
  parameters : Array[String]
  /// Stores whether this is a normal function or an operator definition.
  kind : PrototypeKind
} derive(Debug, Eq)
