///|
/// Represents the MiniMoonBit parser AST node `Type`.
pub struct Type {
  kind : TypeKind
  toks : ArrayView[Token]
} derive(Eq)

///|
/// Renders this `Type` value with optional ANSI coloring.
pub fn Type::to_string(self : Self, color? : Bool = true) -> String {
  let tk = self.kind.to_string()
  if color {
    @color.taint(tk, @color.Green)
  } else {
    tk
  }
}

///|
/// Formats `Type` using MiniMoonBit source notation.
pub impl Show for Type with fn output(self, logger) {
  logger.write_string(self.to_string(color=true))
}

///|
/// Enumerates the parser AST forms represented by `TypeKind`.
pub(all) enum TypeKind {
  /// Represents the `Unit` parser AST form.
  Unit
  /// Represents the `Bool` parser AST form.
  Bool
  /// Represents the `Int` parser AST form.
  Int
  /// Represents the `Int64` parser AST form.
  Int64
  /// Represents the `UInt` parser AST form.
  UInt
  /// Represents the `UInt64` parser AST form.
  UInt64
  /// Represents the `Double` parser AST form.
  Double
  /// Represents the `Float` parser AST form.
  Float
  /// Represents the `Char` parser AST form.
  Char
  /// Represents the `String` parser AST form.
  String
  /// Represents the `Tuple` parser AST form.
  Tuple(Array[TypeKind])
  /// Represents the `Array` parser AST form.
  Array(TypeKind)
  /// Represents the `Function` parser AST form.
  Function(Array[TypeKind], TypeKind)
  /// Represents the `Defined` parser AST form.
  Defined(String)
} derive(Hash, Eq) // Show defined manually in `parser_aux.mbt`

///|
/// Parses the `parse_type` syntax form and returns the unconsumed token suffix.
pub fn parse_type(
  tokens : ArrayView[Token],
) -> (Type, ArrayView[Token]) raise ParseError {
  match tokens {
    [{ kind: Upper("Unit"), .. }, .. rest] =>
      (Type::{ kind: Unit, toks: tokens[0:1], }, rest)
    [{ kind: Upper("Bool"), .. }, .. rest] =>
      (Type::{ kind: Bool, toks: tokens[0:1], }, rest)
    [{ kind: Upper("Int"), .. }, .. rest] =>
      (Type::{ kind: Int, toks: tokens[0:1], }, rest)
    [{ kind: Upper("Int64"), .. }, .. rest] =>
      (Type::{ kind: Int64, toks: tokens[0:1], }, rest)
    [{ kind: Upper("UInt"), .. }, .. rest] =>
      (Type::{ kind: UInt, toks: tokens[0:1], }, rest)
    [{ kind: Upper("UInt64"), .. }, .. rest] =>
      (Type::{ kind: UInt64, toks: tokens[0:1], }, rest)
    [{ kind: Upper("Double"), .. }, .. rest] =>
      (Type::{ kind: Double, toks: tokens[0:1], }, rest)
    [{ kind: Upper("Float"), .. }, .. rest] =>
      (Type::{ kind: Float, toks: tokens[0:1], }, rest)
    [{ kind: Upper("Char"), .. }, .. rest] =>
      (Type::{ kind: Char, toks: tokens[0:1], }, rest)
    [{ kind: Upper("String"), .. }, .. rest] =>
      (Type::{ kind: String, toks: tokens[0:1], }, rest)
    [{ kind: Bracket('('), .. }, ..] as tokens =>
      parse_tuple_or_function_type(tokens)
    [{ kind: Upper("Array"), .. }, ..] as tokens => parse_array_type(tokens)
    [{ kind: Upper(def), .. }, .. rest] =>
      (Type::{ kind: Defined(def), toks: tokens[0:1], }, rest)
    [] => {
      println("Compiler ICE: Empty Token ArrayView")
      panic()
    }
    tok => raise ParseError("InValid Type Parsing: \{tok[0]}")
  }
}

///|
fn parse_tuple_or_function_type(
  tokens : ArrayView[Token],
) -> (Type, ArrayView[Token]) raise ParseError {
  let init_tokens = tokens
  guard tokens is [{ kind: Bracket('('), .. }, .. tokens] else {
    println("Compiler ICE: Misuse parse_tuple_or_function_type")
    panic()
  }
  let tys : Array[TypeKind] = Array::Array(capacity=0)
  let tokens = for current = tokens {
    match current {
      [{ kind: Upper(_) | Bracket('('), .. }, ..] as tokens => {
        let (ty, rest) = parse_type(tokens)
        tys.push(ty.kind)
        continue rest
      }
      [{ kind: Symbol(","), .. }, { kind: Upper(_) | Bracket('('), .. }, ..] as tokens => {
        let (ty, rest) = parse_type(tokens[1:])
        tys.push(ty.kind)
        continue rest
      }
      [{ kind: Bracket(')'), .. }, .. rest] => break rest
      [] => {
        println("Compiler ICE: Empty Token ArrayView")
        panic()
      }
      tok => raise ParseError("InValid Type Parsing, first token: \{tok[0]}")
    }
  }
  if tokens is [{ kind: Symbol("->"), .. }, .. tokens] {
    let (ret_ty, rest) = parse_type(tokens)
    let len = rest.start_offset() - init_tokens.start_offset()
    let toks = init_tokens[0:len]
    (Type::{ kind: Function(tys, ret_ty.kind), toks, }, rest)
  } else {
    let len = tokens.start_offset() - init_tokens.start_offset()
    let toks = init_tokens[0:len]
    (Type::{ kind: Tuple(tys), toks, }, tokens)
  }
}

///|
fn parse_array_type(
  tokens : ArrayView[Token],
) -> (Type, ArrayView[Token]) raise ParseError {
  let init_tokens = tokens
  guard tokens is [{ kind: Upper("Array"), .. }, .. tokens] else {
    println("Compiler ICE: Misuse parse_array_type")
    panic()
  }
  guard tokens is [{ kind: Bracket('['), .. }, .. tokens] else {
    raise ParseError("InValid Array Type Parsing, missing '['")
  }
  let (elem_ty, rest) = parse_type(tokens)
  guard rest is [{ kind: Bracket(']'), .. }, .. rest] else {
    raise ParseError("InValid Array Type Parsing, missing ']'")
  }
  let len = rest.start_offset() - init_tokens.start_offset()
  let toks = init_tokens[0:len]
  (Type::{ kind: Array(elem_ty.kind), toks, }, rest)
}
