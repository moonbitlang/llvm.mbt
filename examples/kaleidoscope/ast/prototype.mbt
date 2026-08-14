///|
/// Describes the name and parameter names of a normal Kaleidoscope function.
pub(all) struct Prototype {
  /// Stores the symbol name used by generated LLVM IR and JIT lookup.
  name : String
  /// Stores parameter names in source and ABI order.
  parameters : Array[String]
} derive(Debug, Eq)
