///|
/// Represents the MiniMoonBit parser AST node `EnumDef`.
pub struct EnumDef {
  name : String
  enum_fields : Array[EnumField]
} derive(Eq)

///|
/// Formats `EnumDef` using MiniMoonBit source notation.
pub impl Show for EnumDef with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `EnumDef` value with optional ANSI coloring.
pub fn EnumDef::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "enum: \{self.name}"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
  if self.enum_fields.length() == 0 {
    return "\{prefix} (no variants)"
  }
  let mut result = prefix
  for i = 0; i < self.enum_fields.length(); i = i + 1 {
    let field = self.enum_fields[i]
    let field_str = field.to_string(color~)
    let field_lines = field_str
      .split("\n")
      .map(fn(sv) { sv.to_string() })
      .to_array()
    let is_last = i == self.enum_fields.length() - 1
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
/// Represents the MiniMoonBit parser AST node `EnumField`.
pub struct EnumField {
  name : String
  types : Array[Type]
} derive(Eq)

///|
/// Formats `EnumField` using MiniMoonBit source notation.
pub impl Show for EnumField with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `EnumField` value with optional ANSI coloring.
pub fn EnumField::to_string(self : Self, color? : Bool = true) -> String {
  if self.types.length() == 0 {
    return self.name
  }
  let types_str = self.types.map(fn(ty) { ty.to_string(color~) }).join(", ")
  "\{self.name}(\{types_str})"
}

///|
/// Parses the `parse_enum_field` syntax form and returns the unconsumed token suffix.
pub fn parse_enum_field(
  tokens : ArrayView[Token],
) -> (EnumField, ArrayView[Token]) raise ParseError {
  guard tokens is [{ kind: Upper(name), .. } as name_tok, .. tokens] else {
    raise ParseError(
      "Expected enum field name, while got \{tokens[0].kind}, \{tokens[1].kind}...",
    )
  }
  let types : Array[Type] = Array::new()
  let mut last_tok = Some(name_tok)
  guard tokens is [{ kind: Bracket('('), .. }, .. rest] else {
    let tokens = if tokens is [{ kind: Symbol(";"), .. }, .. rest] {
      rest
    } else if tokens is [tok, ..] && tok.line != name_tok.line {
      tokens
    } else {
      tokens
    }
    return (EnumField::{ name, types }, tokens)
  }
  let rest = loop rest {
    [{ kind: Bracket(')'), .. } as rparen_tok, .. rest] => {
      last_tok = Some(rparen_tok)
      break rest
    }
    [{ kind: Upper(_) | Bracket('('), .. }, ..] as tokens => {
      let (ty, rest) = parse_type(tokens)
      types.push(ty)
      if rest is [{ kind: Symbol(","), .. }, .. rest] {
        continue rest
      }
      continue rest
    }
    [] => raise ParseError("Unclosed bracket in enum field types")
    [tok, ..] => {
      @lexer.throw_(tok, "Expected type in enum field types", Error)
      raise ParseError("Unexpected token in enum field types")
    }
  }
  let enum_field = EnumField::{ name, types }
  let rest = if rest is [{ kind: Symbol(";"), .. }, .. rest] {
    rest
  } else if rest is [tok, ..] && tok.line != last_tok.unwrap().line {
    rest
  } else {
    rest
  }
  (enum_field, rest)
}

///|
/// Parses the `parse_enum_def` syntax form and returns the unconsumed token suffix.
pub fn parse_enum_def(
  tokens : ArrayView[Token],
) -> (EnumDef, ArrayView[Token]) raise ParseError {
  guard tokens is [{ kind: Keyword(Enum), .. }, .. tokens] else {
    println("Compiler ICE: Misuse parse_enum_def")
    panic()
  }
  guard tokens is [{ kind: Upper(name), .. }, .. tokens] else {
    raise ParseError("Expected enum name")
  }
  guard tokens is [{ kind: Bracket('{'), .. }, .. rest] else {
    raise ParseError("Expected '{' after enum name")
  }
  let enum_fields : Array[EnumField] = Array::new()
  let rest = loop rest {
    [{ kind: Bracket('}'), .. }, .. rest] => break rest
    [] => raise ParseError("Unclosed enum definition")
    tokens => {
      let (enum_field, rest) = parse_enum_field(tokens)
      enum_fields.push(enum_field)
      continue rest
    }
  }
  let enum_def = EnumDef::{ name, enum_fields }
  (enum_def, rest)
}

///|
test "EnumDef to_string Test - Simple" {
  let color = false
  let code =
    #|enum Option { Some(Int); None }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse simple enum
  let (enum_def, _) = parse_enum_def(tokens)
  inspect(
    enum_def.to_string(color~),
    content=(
      #|enum: Option
      #|├-Some(Int)
      #|└-None
    ),
  )
}

///|
test "EnumDef to_string Test - Multiple Types" {
  let color = false
  let code =
    #|enum Result { Ok(Int, String); Err(String) }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse enum with multiple types
  let (enum_def, _) = parse_enum_def(tokens)
  inspect(
    enum_def.to_string(color~),
    content=(
      #|enum: Result
      #|├-Ok(Int, String)
      #|└-Err(String)
    ),
  )
}

///|
test "EnumDef to_string Test - Mixed" {
  let color = false
  let code =
    #|enum List { Cons(Int, List); Nil }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse enum with mixed variants
  let (enum_def, _) = parse_enum_def(tokens)
  inspect(
    enum_def.to_string(color~),
    content=(
      #|enum: List
      #|├-Cons(Int, List)
      #|└-Nil
    ),
  )
}
