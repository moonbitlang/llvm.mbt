///|
/// Represents the MiniMoonBit typed AST node or context `StructDef`.
pub(all) struct StructDef {
  /// Stores the `name` component of this typed AST value.
  name : String
  /// Stores the `fields` component of this typed AST value.
  fields : Array[StructField]
  /// Stores the `methods` component of this typed AST value.
  methods : Map[String, TypeKind]
}

///|
/// Formats `StructDef` using MiniMoonBit typed AST notation.
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
      @parser.format_lines(field_lines, head_with="└-", continue_with="  ")
    } else {
      @parser.format_lines(field_lines, head_with="├-", continue_with="│ ")
    }
    result = "\{result}\n\{field_formatted}"
  }
  result + "\n"
}

///|
/// Represents the MiniMoonBit typed AST node or context `StructField`.
pub(all) struct StructField {
  /// Stores the `name` component of this typed AST value.
  name : String
  /// Stores the `ty` component of this typed AST value.
  ty : Type
}

///|
/// Formats `StructField` using MiniMoonBit typed AST notation.
pub impl Show for StructField with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `StructField` value with optional ANSI coloring.
pub fn StructField::to_string(self : Self, color? : Bool = true) -> String {
  let mut_str = if self.ty.mutable { "mut " } else { "" }
  let ty_str = self.ty.kind.to_string()
  let ty_str = if color { @color.taint(ty_str, Green) } else { ty_str }
  "\{mut_str}\{self.name}: \{ty_str}"
}

///|
/// Performs the `get_field_type` operation on `StructDef`.
pub fn StructDef::get_field_type(self : Self, field_name : String) -> Type? {
  for field in self.fields {
    if field.name == field_name {
      return Some(field.ty)
    }
  }
  return None
}

///|
/// Type-checks the corresponding parser AST form through `check_struct_def`.
pub fn Context::check_struct_def(
  self : Self,
  struct_def : @parser.StructDef,
) -> StructDef raise TypeCheckError {
  let fields : Array[StructField] = Array::Array(capacity=0)
  for field in struct_def.fields {
    let { name, is_mut, ty, } = field
    let ty = self.check_parser_typekind(ty.kind)
    let ty = Type::{ kind: ty, mutable: is_mut, }
    let checked_field = StructField::{ name, ty, }
    fields.push(checked_field)
  }
  let struct_def = StructDef::{
    name: struct_def.name,
    fields,
    methods: Map([]),
  }
  self.struct_defs.set(struct_def.name, struct_def)
  struct_def
}

///|
test "StructDef to_string Test - Simple" {
  let color = false
  let ctx = Context::new()
  let code =
    #|struct Point { x: Int; y: Int }
  let tokens = @lexer.tokenize(code)

  // Parse and check simple struct
  let (parsed, _) = @parser.parse_struct_def(tokens)
  let checked = ctx.check_struct_def(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|struct: Point
      #|├-x: Int
      #|└-y: Int
      #|
    ),
  )
}

///|
test "StructDef to_string Test - With Mut" {
  let color = false
  let ctx = Context::new()
  let code =
    #|struct Counter { mut count: Int; name: String }
  let tokens = @lexer.tokenize(code)

  // Parse and check struct with mut field
  let (parsed, _) = @parser.parse_struct_def(tokens)
  let checked = ctx.check_struct_def(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|struct: Counter
      #|├-mut count: Int
      #|└-name: String
      #|
    ),
  )
}
