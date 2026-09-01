///|
/// Represents the MiniMoonBit parser AST node `LeftValue`.
pub(all) struct LeftValue {
  /// Stores the `kind` component of this parser AST node.
  kind : LeftValueKind
} derive(Eq)

///|
/// Formats `LeftValue` using MiniMoonBit source notation.
pub impl Show for LeftValue with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `LeftValue` value with optional ANSI coloring.
pub fn LeftValue::to_string(self : Self, color? : Bool = true) -> String {
  match self.kind {
    Ident(name) => {
      let prefix = "lvalue"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      "\{prefix} \{name}"
    }
    ArrayAccess(left_value, index_expr) => {
      let prefix = "lvalue array access"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      let lvalue_str = left_value.to_string(color~)
      let lvalue_lines = lvalue_str
        .split("\n")
        .map(sv => sv.to_owned())
        .to_array()
      let lvalue_formatted = format_lines(
        lvalue_lines,
        head_with="├-",
        continue_with="│ ",
      )
      let index_str = index_expr.to_string(color~)
      let index_lines = index_str
        .split("\n")
        .map(sv => sv.to_owned())
        .to_array()
      let index_formatted = format_lines(
        index_lines,
        head_with="└-",
        continue_with="  ",
      )
      "\{prefix}\n\{lvalue_formatted}\n\{index_formatted}"
    }
    FieldAccess(left_value, field) => {
      let prefix = "lvalue field access"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      let inner_str = left_value.to_string(color~)
      let lines = inner_str.split("\n").map(sv => sv.to_owned()).to_array()
      let formatted = format_lines(lines)
      "\{prefix} .\{field}\n\{formatted}"
    }
  }
}

///|
/// Enumerates the parser AST forms represented by `LeftValueKind`.
pub(all) enum LeftValueKind {
  /// Represents the `Ident` parser AST form.
  Ident(String)
  /// Represents the `ArrayAccess` parser AST form.
  ArrayAccess(LeftValue, Expr)
  /// Represents the `FieldAccess` parser AST form.
  FieldAccess(LeftValue, String)
} derive(Eq)

///|
/// Formats `LeftValueKind` using MiniMoonBit source notation.
pub impl Show for LeftValueKind with fn output(self, logger) {
  let s = match self {
    Ident(name) => "\{name}"
    ArrayAccess(left_value, _) => "\{left_value}[...]"
    FieldAccess(left_value, field) => "\{left_value}.\{field}"
  }
  logger.write_string(s)
}

///|
/// Parses the `parse_left_value` syntax form and returns the unconsumed token suffix.
pub fn parse_left_value(
  tokens : ArrayView[Token],
) -> (LeftValue, ArrayView[Token]) raise ParseError {
  guard tokens is [{ kind: Lower(ident), .. }, .. tokens] else {
    @lexer.throw_(tokens[0], "Expect a lower ident", Error)
    raise ParseError("Expect a lower ident")
  }
  let left_value = LeftValue::{ kind: LeftValueKind::Ident(ident), }
  if !(tokens is [{ kind: Bracket('[') | Symbol("."), .. }, ..]) {
    return (left_value, tokens)
  }
  let mut left_value = left_value
  for current = tokens {
    match current {
      [{ kind: Bracket('['), .. }, .. tokens] => {
        let (index_expr, tokens) = parse_expr(tokens)
        guard tokens is [{ kind: Bracket(']'), .. }, .. tokens] else {
          raise ParseError("Expect ']'")
        }
        left_value = LeftValue::{
          kind: LeftValueKind::ArrayAccess(left_value, index_expr),
        }
        continue tokens
      }
      [{ kind: Symbol("."), .. }, { kind: Lower(field), .. }, .. tokens] => {
        left_value = LeftValue::{
          kind: LeftValueKind::FieldAccess(left_value, field),
        }
        continue tokens
      }
      tokens => break (left_value, tokens)
    }
  }
}

///|
test "LeftValue to_string Test - Basic" {
  let color = false
  let code =
    #|x ; arr[0] ; point.x
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `x` (Ident)
  let (left_value, rest) = parse_left_value(tokens)
  inspect(left_value.to_string(color~), content="lvalue x")

  // Skip semicolon and parse `arr[0]` (ArrayAccess)
  let rest = skip_semicolon(rest)
  let (left_value, rest) = parse_left_value(rest)
  inspect(
    left_value.to_string(color~),
    content=(
      #|lvalue array access
      #|├-lvalue arr
      #|└-int literal 0
    ),
  )

  // Skip semicolon and parse `point.x` (FieldAccess)
  let rest = skip_semicolon(rest)
  let (left_value, _) = parse_left_value(rest)
  inspect(
    left_value.to_string(color~),
    content=(
      #|lvalue field access .x
      #|└-lvalue point
    ),
  )
}

///|
test "LeftValue to_string Test - Nested" {
  let color = false
  let code =
    #|arr[0][1] ; point.field.x ; matrix[i].data
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `arr[0][1]` (Nested ArrayAccess)
  let (left_value, rest) = parse_left_value(tokens)
  inspect(
    left_value.to_string(color~),
    content=(
      #|lvalue array access
      #|├-lvalue array access
      #|│ ├-lvalue arr
      #|│ └-int literal 0
      #|└-int literal 1
    ),
  )

  // Skip semicolon and parse `point.field.x` (Nested FieldAccess)
  let rest = skip_semicolon(rest)
  let (left_value, rest) = parse_left_value(rest)
  inspect(
    left_value.to_string(color~),
    content=(
      #|lvalue field access .x
      #|└-lvalue field access .field
      #|  └-lvalue point
    ),
  )

  // Skip semicolon and parse `matrix[i].data` (Mixed access)
  let rest = skip_semicolon(rest)
  let (left_value, _) = parse_left_value(rest)
  inspect(
    left_value.to_string(color~),
    content=(
      #|lvalue field access .data
      #|└-lvalue array access
      #|  ├-lvalue matrix
      #|  └-variable i
    ),
  )
}
