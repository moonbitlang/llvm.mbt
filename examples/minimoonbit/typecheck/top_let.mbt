///|
/// Represents the MiniMoonBit typed AST node or context `TopLet`.
pub struct TopLet {
  name : String
  ty : Type
  expr : Expr
}

///|
/// Formats `TopLet` using MiniMoonBit typed AST notation.
pub impl Show for TopLet with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `TopLet` value with optional ANSI coloring.
pub fn TopLet::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "top let: \{self.name}"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }

  // Format type
  let ty_str = self.ty.kind.to_string()
  let ty_str = if color { @color.taint(ty_str, Green) } else { ty_str }
  let type_text = "type: \{ty_str}"
  let type_formatted = @parser.format_lines(
    [type_text],
    head_with="├-",
    continue_with="│ ",
  )

  // Format expression
  let expr_str = self.expr.to_string(color~)
  let expr_lines = expr_str.split("\n").map(sv => sv.to_owned()).to_array()
  let expr_formatted = @parser.format_lines(
    expr_lines,
    head_with="└-expr: ",
    continue_with="        ",
  )
  "\{prefix}\n\{type_formatted}\n\{expr_formatted}\n"
}

///|
/// Type-checks the corresponding parser AST form through `check_top_let`.
pub fn Context::check_top_let(
  self : Context,
  top_let : @parser.TopLet,
) -> TopLet raise TypeCheckError {
  let checked_expr = self.check_expr(top_let.expr)
  let type_kind = checked_expr.ty
  if top_let.ty is Some(type_annotation) {
    let annotated_type = self.check_parser_typekind(type_annotation.kind)
    if !self.is_type_compatible(annotated_type, checked_expr.ty) {
      raise TypeCheckError(
        "Type annotation does not match the expression type, annotated: \{annotated_type}, expr: \{checked_expr.ty}",
      )
    }
  }
  let type_kind = self.ensure_type(type_kind)
  let ty = Type::{ kind: type_kind, mutable: false }
  let checked_top_let = TopLet::{ name: top_let.name, ty, expr: checked_expr }
  self.type_env.set(top_let.name, ty)
  checked_top_let
}

///|
test "TopLet to_string Test - Simple" {
  let color = false
  let ctx = Context::new()
  let code =
    #|let pi = 3.14 ;
  let tokens = @lexer.tokenize(code)

  // Parse and check simple top let
  let (parsed, _) = @parser.parse_top_let(tokens)
  let checked = ctx.check_top_let(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|top let: pi
      #|├-type: Double
      #|└-expr: double literal 3.14 (Double)
      #|
    ),
  )
}

///|
test "TopLet to_string Test - With Type" {
  let color = false
  let ctx = Context::new()
  let code =
    #|let count : Int = 42 ;
  let tokens = @lexer.tokenize(code)

  // Parse and check top let with type annotation
  let (parsed, _) = @parser.parse_top_let(tokens)
  let checked = ctx.check_top_let(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|top let: count
      #|├-type: Int
      #|└-expr: int literal 42 (Int)
      #|
    ),
  )
}
