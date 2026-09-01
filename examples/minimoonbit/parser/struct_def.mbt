///|
/// Represents the MiniMoonBit parser AST node `StructDef`.
pub struct StructDef {
  name : String
  fields : Array[StructField]
} derive(Eq)

///|
/// Formats `StructDef` using MiniMoonBit source notation.
pub impl Show for StructDef with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `StructDef` value with optional ANSI coloring.
pub fn StructDef::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "struct: \{self.name}"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
  if self.fields.length() == 0 {
    return "\{prefix} (no fields)"
  }
  let mut result = prefix
  for i = 0; i < self.fields.length(); i = i + 1 {
    let field = self.fields[i]
    let field_str = field.to_string(color~)
    let field_lines = field_str.split("\n").map(sv => sv.to_owned()).to_array()
    let is_last = i == self.fields.length() - 1
    let field_formatted = if is_last {
      format_lines(field_lines, head_with="└-", continue_with="  ")
    } else {
      format_lines(field_lines, head_with="├-", continue_with="│ ")
    }
    result = "\{result}\n\{field_formatted}"
  }
  result
}

///|
/// Represents the MiniMoonBit parser AST node `StructField`.
pub struct StructField {
  name : String
  is_mut : Bool
  ty : Type
} derive(Eq)

///|
/// Formats `StructField` using MiniMoonBit source notation.
pub impl Show for StructField with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `StructField` value with optional ANSI coloring.
pub fn StructField::to_string(self : Self, color? : Bool = true) -> String {
  let mut_str = if self.is_mut { "mut " } else { "" }
  "\{mut_str}\{self.name}: \{self.ty.to_string(color~)}"
}

///|
/// Parses the `parse_struct_field` syntax form and returns the unconsumed token suffix.
pub fn parse_struct_field(
  tokens : ArrayView[Token],
) -> (StructField, ArrayView[Token]) raise ParseError {
  let (is_mut, tokens) = if tokens is [{ kind: Keyword(Mut), .. }, ..] {
    (true, tokens[1:])
  } else {
    (false, tokens)
  }
  guard tokens is [{ kind: Lower(name), .. }, .. tokens] else {
    raise ParseError("Expect struct field name")
  }
  guard tokens is [{ kind: Symbol(":"), .. }, .. tokens] else {
    raise ParseError("Expect ':' after struct field name")
  }
  let (ty, tokens) = parse_type(tokens)
  let struct_field = StructField::{ is_mut, name, ty, }
  //guard tokens is [{ kind: Symbol(";"), .. }, .. tokens] else {
  //  raise ParseError("Expect ';' after struct field")
  //}
  let tokens = if tokens is [{ kind: Symbol(";"), .. }, .. tokens] {
    tokens
  } else if tokens is [tok, ..] &&
    tok.line != ty.toks[ty.toks.length() - 1].line {
    tokens
  } else {
    tokens
  }
  (struct_field, tokens)
}

///|
/// Parses the `parse_struct_def` syntax form and returns the unconsumed token suffix.
pub fn parse_struct_def(
  tokens : ArrayView[Token],
) -> (StructDef, ArrayView[Token]) raise ParseError {
  guard tokens is [{ kind: Keyword(Struct), .. }, .. tokens] else {
    println("Compiler ICE: Misuse parse_struct_def")
    panic()
  }
  guard tokens is [{ kind: Upper(name), .. }, .. tokens] else {
    raise ParseError("Expect struct name")
  }
  guard tokens is [{ kind: Bracket('{'), .. }, .. tokens] else {
    raise ParseError("Failed Parsing StructDef: Expect '{'")
  }
  let fields : Array[StructField] = Array::new()
  let tokens = for current = tokens {
    match current {
      [{ kind: Bracket('}'), .. }, .. rest] => break rest
      [] => {
        println("Compiler ICE: Empty Token ArrayView")
        panic()
      }
      tokens => {
        let (field, rest) = parse_struct_field(tokens)
        fields.push(field)
        continue rest
      }
    }
  }
  let struct_def = StructDef::{ name, fields, }
  (struct_def, tokens)
}

///|
test "StructDef to_string Test - Simple" {
  let color = false
  let code =
    #|struct Point { x: Int; y: Int }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse simple struct
  let (struct_def, _) = parse_struct_def(tokens)
  inspect(
    struct_def.to_string(color~),
    content=(
      #|struct: Point
      #|├-x: Int
      #|└-y: Int
    ),
  )
}

///|
test "StructDef to_string Test - With Mut" {
  let color = false
  let code =
    #|struct Counter { mut count: Int; name: String }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse struct with mut field
  let (struct_def, _) = parse_struct_def(tokens)
  inspect(
    struct_def.to_string(color~),
    content=(
      #|struct: Counter
      #|├-mut count: Int
      #|└-name: String
    ),
  )
}

///|
test "StructDef to_string Test - Complex Types" {
  let color = false
  let code =
    #|struct Node { data: Int; mut next: Array[Int] }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse struct with complex types
  let (struct_def, _) = parse_struct_def(tokens)
  inspect(
    struct_def.to_string(color~),
    content=(
      #|struct: Node
      #|├-data: Int
      #|└-mut next: Array[Int]
    ),
  )
}
