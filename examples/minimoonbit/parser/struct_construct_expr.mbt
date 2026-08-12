///|
/// Represents the MiniMoonBit parser AST node `StructConstructExpr`.
pub(all) struct StructConstructExpr {
  /// Stores the `name` component of this parser AST node.
  name : String
  /// Stores the `fields` component of this parser AST node.
  fields : Array[(String, Expr)]
  /// Stores the `toks` component of this parser AST node.
  toks : ArrayView[Token]
} derive(Eq)

///|
/// Formats `StructConstructExpr` using MiniMoonBit source notation.
pub impl Show for StructConstructExpr with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `StructConstructExpr` value with optional ANSI coloring.
pub fn StructConstructExpr::to_string(
  self : Self,
  color? : Bool = true,
) -> String {
  let prefix = "struct construct: \{self.name}"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
  if self.fields.is_empty() {
    return "\{prefix} {}"
  }
  let mut result = prefix
  for i = 0; i < self.fields.length(); i = i + 1 {
    let (field_name, expr) = self.fields[i]
    let field_prefix = "\{field_name}:"
    let field_prefix = if color {
      @color.taint(field_prefix, Blue)
    } else {
      field_prefix
    }
    let expr_str = expr.to_string(color~)
    let expr_lines = expr_str.split("\n").map(sv => sv.to_owned()).to_array()
    let is_last = i == self.fields.length() - 1

    // Format field name and expression
    let field_formatted = if is_last {
      let first_line = "└-\{field_prefix} " + expr_lines[0]
      let mut formatted = first_line
      for j = 1; j < expr_lines.length(); j = j + 1 {
        formatted = formatted + "\n  " + expr_lines[j]
      }
      formatted
    } else {
      let first_line = "├-\{field_prefix} " + expr_lines[0]
      let mut formatted = first_line
      for j = 1; j < expr_lines.length(); j = j + 1 {
        formatted = formatted + "\n│ " + expr_lines[j]
      }
      formatted
    }
    result = result + "\n" + field_formatted
  }
  result
}

///|
/// Parses the `parse_struct_construct` syntax form and returns the unconsumed token suffix.
pub fn parse_struct_construct(
  tokens : ArrayView[Token],
) -> (AtomExpr, ArrayView[Token]) raise ParseError {
  let init_tokens = tokens
  guard tokens is [{ kind: Upper(name), .. }, .. tokens] else {
    println(
      "Compiler ICE: Misuse parse_struct_or_enum_construct, expected struct/enum name",
    )
    panic()
  }
  guard tokens is [{ kind: Symbol("::"), .. }, .. tokens] else {
    println(
      "Compiler ICE: Misuse parse_struct_or_enum_construct, expected '::'",
    )
    panic()
  }
  guard tokens is [{ kind: Bracket('{'), .. }, .. tokens] else {
    println("Compiler ICE: Misuse parse_struct_or_enum_construct, expected '{'")
    panic()
  }
  let fields : Array[(String, Expr)] = Array::new()
  let tokens = for current = tokens {
    match current {
      [{ kind: Bracket('}'), .. }, .. rest] => break rest
      [{ kind: Symbol(","), .. }, { kind: Bracket('}'), .. }, .. rest] =>
        break rest
      [{ kind: Symbol(","), .. }, { kind: Lower(field), .. }, .. tokens] => {
        guard tokens is [{ kind: Symbol(":"), .. }, .. tokens] else {
          raise ParseError("Expect ':'")
        }
        let (expr, rest) = parse_expr(tokens)
        fields.push((field, expr))
        continue rest
      }
      [{ kind: Lower(field), .. }, .. tokens] => {
        guard tokens is [{ kind: Symbol(":"), .. }, ..] else {
          raise ParseError("Expect ':'")
        }
        let (expr, rest) = parse_expr(tokens[1:])
        fields.push((field, expr))
        continue rest
      }
      [] => {
        println("Compiler ICE: Empty Token ArrayView")
        panic()
      }
      tokens => raise ParseError("InValid Struct Construct: \{tokens[0]}")
    }
  }
  let len = tokens.start_offset() - init_tokens.start_offset()
  let toks = init_tokens[0:len]
  let struct_construct = StructConstructExpr::{ name, fields, toks }
  let atom_expr = AtomExpr::new(
    StructConstruct(struct_construct),
    init_tokens,
    tokens,
  )
  (atom_expr, tokens)
}

///|
test "StructConstructExpr to_string Test - Simple" {
  let color = false
  let code =
    #|Point::{ x: 1, y: 2 }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse simple struct construct
  let (atom_expr, _) = parse_struct_construct(tokens)
  match atom_expr.kind {
    StructConstruct(struct_construct) =>
      inspect(
        struct_construct.to_string(color~),
        content=(
          #|struct construct: Point
          #|├-x: int literal 1
          #|└-y: int literal 2
        ),
      )
    _ => panic()
  }
}

///|
test "StructConstructExpr to_string Test - Empty" {
  let color = false
  let code =
    #|Point::{}
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse empty struct construct
  let (atom_expr, _) = parse_struct_construct(tokens)
  match atom_expr.kind {
    StructConstruct(struct_construct) =>
      inspect(
        struct_construct.to_string(color~),
        content="struct construct: Point {}",
      )
    _ => panic()
  }
}

///|
test "StructConstructExpr to_string Test - Complex Fields" {
  let color = false
  let code =
    #|Node::{ data: x + 1, next: get_next(), is_valid: true }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse struct construct with complex fields
  let (atom_expr, _) = parse_struct_construct(tokens)
  match atom_expr.kind {
    StructConstruct(struct_construct) =>
      inspect(
        struct_construct.to_string(color~),
        content=(
          #|struct construct: Node
          #|├-data: binary expr: +
          #|│ ├-variable x
          #|│ └-int literal 1
          #|├-next: function call
          #|│ └-variable get_next
          #|└-is_valid: bool literal true
        ),
      )
    _ => panic()
  }
}
