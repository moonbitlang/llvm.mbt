///|
/// Stores the binary-operator precedence used by one parser configuration.
///
/// A new table contains only the currently implemented built-in operators:
/// `<`, `+`, `-`, and `*`. The table is owned by the caller rather than kept in
/// process-global parser state; later language stages can extend this boundary
/// transactionally for user-defined operators.
///
/// **Construction:** Use `OperatorTable::new` to obtain the core language
/// precedences.
pub struct OperatorTable {
  precedences : Map[Char, Int]
}

///|
/// Creates an independent table containing the core operator precedences.
///
/// **Returns:** A fresh table in which `<` has precedence 10, `+` and `-` have
/// precedence 20, and `*` has precedence 40.
pub fn OperatorTable::new() -> OperatorTable {
  OperatorTable::{
    precedences: Map::from_array([('<', 10), ('+', 20), ('-', 20), ('*', 40)]),
  }
}

///|
/// Returns the precedence assigned to an operator in this table.
///
/// **Returns:** `Some(precedence)` for a registered binary operator, otherwise
/// `None`.
pub fn OperatorTable::getPrecedence(
  self : OperatorTable,
  operator : Char,
) -> Int? {
  self.precedences.get(operator)
}
