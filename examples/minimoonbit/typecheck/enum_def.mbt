///|
/// Represents the MiniMoonBit typed AST node or context `EnumDef`.
pub struct EnumDef {
  name : String
  enum_fields : Array[EnumField]
}

///|
/// Formats `EnumDef` using MiniMoonBit typed AST notation.
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
      @parser.format_lines(field_lines, head_with="└-", continue_with="  ")
    } else {
      @parser.format_lines(field_lines, head_with="├-", continue_with="│ ")
    }
    result = "\{result}\n\{field_formatted}\n"
  }
  result
}

///|
/// Performs the `get_field` operation on `EnumDef`.
pub fn EnumDef::get_field(self : Self, field_name : String) -> EnumField? {
  for field in self.enum_fields {
    if field.name == field_name {
      return Some(field)
    }
  }
  None
}

///|
/// Represents the MiniMoonBit typed AST node or context `EnumField`.
pub struct EnumField {
  name : String
  types : Array[TypeKind]
}

///|
/// Formats `EnumField` using MiniMoonBit typed AST notation.
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
  let types_str = self.types
    .map(fn(ty) {
      let s = ty.to_string()
      if color {
        @color.taint(s, Green)
      } else {
        s
      }
    })
    .join(", ")
  "\{self.name}(\{types_str})"
}

///|
/// Type-checks the corresponding parser AST form through `check_enum_def`.
pub fn Context::check_enum_def(
  self : Self,
  enum_def : @parser.EnumDef,
) -> EnumDef raise TypeCheckError {
  let fields : Array[EnumField] = Array::new()
  for field in enum_def.enum_fields {
    let { name, types } = field
    let checked_types : Array[TypeKind] = types.map(t => {
      self.check_parser_typekind(t.kind)
    })
    let checked_field = EnumField::{ name, types: checked_types }
    fields.push(checked_field)
  }
  let enum_def = EnumDef::{ name: enum_def.name, enum_fields: fields }
  self.enum_defs.set(enum_def.name, enum_def)
  enum_def
}

///|
test "EnumDef to_string Test - Simple" {
  let color = false
  let ctx = Context::new()
  let code =
    #|enum Option { Some(Int); None }
  let tokens = @lexer.tokenize(code)

  // Parse and check simple enum
  let (parsed, _) = @parser.parse_enum_def(tokens)
  let checked = ctx.check_enum_def(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|enum: Option
      #|├-Some(Int)
      #|
      #|└-None
      #|
    ),
  )
}

///|
test "EnumDef to_string Test - Multiple Types" {
  let color = false
  let ctx = Context::new()
  let code =
    #|enum Result { Ok(Int, String); Err(String) }
  let tokens = @lexer.tokenize(code)

  // Parse and check enum with multiple types
  let (parsed, _) = @parser.parse_enum_def(tokens)
  let checked = ctx.check_enum_def(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|enum: Result
      #|├-Ok(Int, String)
      #|
      #|└-Err(String)
      #|
    ),
  )
}
