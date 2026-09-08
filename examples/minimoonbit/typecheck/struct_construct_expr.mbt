///|
/// Represents the MiniMoonBit typed AST node or context `StructConstructExpr`.
pub(all) struct StructConstructExpr {
  /// Stores the `name` component of this typed AST value.
  name : String
  /// Stores the `fields` component of this typed AST value.
  fields : Array[(String, Expr)]
  /// Stores the `toks` component of this typed AST value.
  toks : ArrayView[Token]
}

///|
/// Formats `StructConstructExpr` using MiniMoonBit typed AST notation.
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
/// Type-checks the corresponding parser AST form through `check_struct_construct_expr`.
pub fn Context::check_struct_construct_expr(
  self : Self,
  sc_expr : @parser.StructConstructExpr,
) -> (AtomExprKind, TypeKind) {
  let struct_def = match self.struct_defs.get(sc_expr.name) {
    Some(def) => def
    None => {
      self.throw_(sc_expr.toks[0], "Undefined struct: \{sc_expr.name}", Error)
      return (AtomExprKind::Unit, TypeKind::Unit)
    }
  }
  if sc_expr.fields.length() != struct_def.fields.length() {
    let msg = "Struct \{sc_expr.name} requires \{struct_def.fields.length()} fields," +
      " but \{sc_expr.fields.length()} were provided"
    self.throw_(sc_expr.toks[0], msg, Error)
  }
  let len = min(sc_expr.fields.length(), struct_def.fields.length())
  let checked_fields : Array[(String, Expr)] = []
  for i in 0..<len {
    let (field_name, field_expr) = sc_expr.fields[i]
    let field_type = match struct_def.get_field_type(field_name) {
      Some(ty) => ty
      None => {
        self.throw_(
          sc_expr.toks[0],
          "Field \{field_name} does not exist in struct \{sc_expr.name}",
          Error,
        )
        return (AtomExprKind::Unit, TypeKind::Unit)
      }
    }
    let checked_expr = self.check_expr(field_expr)
    if self.is_type_compatible(checked_expr.ty, field_type.kind) is false {
      let msg = "Field \{field_name} expects type \{field_type.kind.to_string()}, " +
        "but got \{checked_expr.ty.to_string()}"
      self.throw_(sc_expr.toks[0], msg, Error)
    }
    checked_fields.push((field_name, checked_expr))
  }
  let struct_construct_expr = StructConstructExpr::{
    name: sc_expr.name,
    fields: checked_fields,
    toks: sc_expr.toks,
  }
  let atom_expr_kind = AtomExprKind::StructConstruct(struct_construct_expr)
  let type_kind = TypeKind::Struct(sc_expr.name)
  (atom_expr_kind, type_kind)
}

///|
test "StructConstructExpr to_string Test - Simple" {
  let color = false
  let ctx = Context::new()
  ctx.struct_defs.set("Point", {
    name: "Point",
    fields: [
      { name: "x", ty: { kind: TypeKind::Int, mutable: false, }, },
      { name: "y", ty: { kind: TypeKind::Int, mutable: false, }, },
    ],
    methods: Map([]),
  })
  let code =
    #|Point::{ x: 1, y: 2 }
  let tokens = @lexer.tokenize(code)

  // Parse and check simple struct construct
  let (parsed, _) = @parser.parse_atom_expr(tokens[:])
  let checked = ctx.check_atom_expr(parsed)
  match checked.kind {
    StructConstruct(struct_construct) =>
      inspect(
        struct_construct.to_string(color~),
        content=(
          #|struct construct: Point
          #|├-x: int literal 1 (Int)
          #|└-y: int literal 2 (Int)
        ),
      )
    _ => panic()
  }
}

///|
test "StructConstructExpr to_string Test - Empty" {
  let color = false
  let ctx = Context::new()
  ctx.struct_defs.set("Point", { name: "Point", fields: [], methods: Map([]), })
  let code =
    #|Point::{}
  let tokens = @lexer.tokenize(code)

  // Parse and check empty struct construct
  let (parsed, _) = @parser.parse_atom_expr(tokens[:])
  let checked = ctx.check_atom_expr(parsed)
  match checked.kind {
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
  let ctx = Context::new()
  ctx.type_env.set("x", { kind: TypeKind::Int, mutable: false, })
  ctx.type_env.set("get_next", {
    kind: TypeKind::Function([], TypeKind::Int),
    mutable: false,
  })
  ctx.struct_defs.set("Node", {
    name: "Node",
    fields: [
      { name: "data", ty: { kind: TypeKind::Int, mutable: false, }, },
      { name: "next", ty: { kind: TypeKind::Int, mutable: false, }, },
      { name: "is_valid", ty: { kind: TypeKind::Bool, mutable: false, }, },
    ],
    methods: Map([]),
  })
  let code =
    #|Node::{ data: x + 1, next: get_next(), is_valid: true }
  let tokens = @lexer.tokenize(code)

  // Parse and check struct construct with complex fields
  let (parsed, _) = @parser.parse_atom_expr(tokens[:])
  let checked = ctx.check_atom_expr(parsed)
  match checked.kind {
    StructConstruct(struct_construct) =>
      inspect(
        struct_construct.to_string(color~),
        content=(
          #|struct construct: Node
          #|├-data: binary expr: + (Int)
          #|│ ├-variable x (Int)
          #|│ └-int literal 1 (Int)
          #|├-next: function call (Int)
          #|│ └-variable get_next (() -> Int)
          #|└-is_valid: bool literal true (Bool)
        ),
      )
    _ => panic()
  }
}
