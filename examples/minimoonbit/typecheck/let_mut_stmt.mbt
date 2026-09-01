///|
/// Represents the MiniMoonBit typed AST node or context `LetMutStmt`.
pub(all) struct LetMutStmt {
  /// Stores the `name` component of this typed AST value.
  name : String
  /// Stores the `ty` component of this typed AST value.
  ty : TypeKind
  /// Stores the `expr` component of this typed AST value.
  expr : Expr
}

///|
/// Formats `LetMutStmt` using MiniMoonBit typed AST notation.
pub impl Show for LetMutStmt with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `LetMutStmt` value with optional ANSI coloring.
pub fn LetMutStmt::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "let mut statement"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }

  // Format name
  let name_text = "name: \{self.name}"
  let name_formatted = @parser.format_lines(
    [name_text],
    head_with="├-",
    continue_with="│ ",
  )

  // Format type
  let ty_str = ": \{self.ty}"
  let type_formatted = @parser.format_lines(
    [ty_str],
    head_with="├-type: ",
    continue_with="│       ",
  )

  // Format expression
  let expr_str = self.expr.to_string(color~)
  let expr_lines = expr_str.split("\n").map(sv => sv.to_owned()).to_array()
  let expr_formatted = @parser.format_lines(
    expr_lines,
    head_with="└-expr: ",
    continue_with="        ",
  )
  "\{prefix}\n\{name_formatted}\n\{type_formatted}\n\{expr_formatted}"
}

///|
/// Type-checks the corresponding parser AST form through `check_let_mut_stmt`.
pub fn Context::check_let_mut_stmt(
  self : Context,
  stmt : @parser.LetMutStmt,
) -> LetMutStmt raise TypeCheckError {
  let checked_expr = self.check_expr(stmt.expr)
  let type_kind = checked_expr.ty
  if stmt.ty is Some(type_annotation) {
    let annotated_type = self.check_parser_typekind(type_annotation.kind)
    if !self.is_type_compatible(annotated_type, checked_expr.ty) {
      raise TypeCheckError(
        "Type annotation does not match the expression type, annotated: \{annotated_type}, expr: \{checked_expr.ty}",
      )
    }
  }
  let type_kind = self.ensure_type(type_kind)
  let ty = Type::{ kind: type_kind, mutable: true, }
  let checked_stmt = LetMutStmt::{
    name: stmt.name,
    ty: type_kind,
    expr: checked_expr,
  }
  self.type_env.set(stmt.name, ty)
  checked_stmt
}

///|
test "LetMutStmt to_string Test - Basic" {
  let color = false
  let ctx = Context::new()
  let code =
    #|let mut x = 42 ;
  let tokens = @lexer.tokenize(code)

  // Test simple let mut: let mut x = 42
  let (stmt, _) = @parser.parse_stmt(tokens[:])
  let checked = ctx.check_stmt(stmt)
  inspect(
    checked.to_string(color~),
    content=(
      #|let mut statement
      #|├-name: x
      #|├-type: : Int
      #|└-expr: int literal 42 (Int)
    ),
  )
}

///|
test "LetMutStmt to_string Test - Complex" {
  let color = false
  let ctx = Context::new()
  ctx.type_env.set("a", { kind: TypeKind::Int, mutable: false, })
  let code =
    #|let mut sum = a + 1 ;
  let tokens = @lexer.tokenize(code)

  // Test with binary expression: let mut sum = a + 1
  let (stmt, _) = @parser.parse_stmt(tokens[:])
  let checked = ctx.check_stmt(stmt)
  inspect(
    checked.to_string(color~),
    content=(
      #|let mut statement
      #|├-name: sum
      #|├-type: : Int
      #|└-expr: binary expr: + (Int)
      #|        ├-variable a (Int)
      #|        └-int literal 1 (Int)
    ),
  )
}
