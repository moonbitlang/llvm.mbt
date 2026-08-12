///|
/// Represents the MiniMoonBit typed AST node or context `WhileStmt`.
pub(all) struct WhileStmt {
  /// Stores the `cond` component of this typed AST value.
  cond : Expr
  /// Stores the `body` component of this typed AST value.
  body : BlockExpr
}

///|
/// Formats `WhileStmt` using MiniMoonBit typed AST notation.
pub impl Show for WhileStmt with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `WhileStmt` value with optional ANSI coloring.
pub fn WhileStmt::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "while statement"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }

  // Format condition
  let cond_str = self.cond.to_string(color~)
  let cond_lines = cond_str.split("\n").map(sv => sv.to_owned()).to_array()
  let cond_formatted = @parser.format_lines(
    cond_lines,
    head_with="├-cond: ",
    continue_with="│       ",
  )

  // Format body
  let body_str = self.body.to_string(color~)
  let body_lines = body_str.split("\n").map(sv => sv.to_owned()).to_array()
  let body_formatted = @parser.format_lines(
    body_lines,
    head_with="└-body: ",
    continue_with="        ",
  )
  "\{prefix}\n\{cond_formatted}\n\{body_formatted}"
}

///|
/// Type-checks the corresponding parser AST form through `check_while_stmt`.
pub fn Context::check_while_stmt(
  self : Context,
  while_stmt : @parser.WhileStmt,
) -> WhileStmt raise TypeCheckError {
  let checked_cond = self.check_expr(while_stmt.cond)
  // Ensure the condition is of boolean type
  if !(checked_cond.ty is Bool) {
    raise TypeCheckError("While condition must be of boolean type")
  }
  let checked_body = self.check_block_expr(while_stmt.body)
  WhileStmt::{ cond: checked_cond, body: checked_body }
}

///|
test "WhileStmt to_string Test - Simple" {
  let color = false
  let ctx = Context::new()
  ctx.type_env.set("x", { kind: TypeKind::Bool, mutable: false })
  let code =
    #|while x { let y = 1 ; }
  let tokens = @lexer.tokenize(code)

  // Parse and check simple while
  let (parsed, _) = @parser.parse_while_stmt(tokens)
  let checked = ctx.check_while_stmt(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|while statement
      #|├-cond: variable x (Bool)
      #|└-body: block (Unit)
      #|        └-let statement
      #|          ├-pattern: ident pattern y
      #|          ├-type: : Int
      #|          └-expr: int literal 1 (Int)
      #|        
    ),
  )
}

///|
test "WhileStmt to_string Test - Complex Condition" {
  let color = false
  let ctx = Context::new()
  ctx.type_env.set("i", { kind: TypeKind::Int, mutable: true })
  let code =
    #|while i < 10 { i += 1 ; }
  let tokens = @lexer.tokenize(code)

  // Parse and check while with complex condition
  let (parsed, _) = @parser.parse_while_stmt(tokens)
  let checked = ctx.check_while_stmt(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|while statement
      #|├-cond: binary expr: < (Bool)
      #|│       ├-variable i (Int)
      #|│       └-int literal 10 (Int)
      #|└-body: block (Unit)
      #|        └-assign statement: +=
      #|          ├-lvalue: lvalue i (Int)
      #|          └-expr: int literal 1 (Int)
      #|        
    ),
  )
}

///|
test "WhileStmt to_string Test - Multiple Statements" {
  let color = false
  let ctx = Context::new()
  ctx.type_env.set("x", { kind: TypeKind::Int, mutable: true })
  let code =
    #|while x > 0 { let a = x ; x = x - 1 ; }
  let tokens = @lexer.tokenize(code)

  // Parse and check while with multiple statements in body
  let (parsed, _) = @parser.parse_while_stmt(tokens)
  let checked = ctx.check_while_stmt(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|while statement
      #|├-cond: binary expr: > (Bool)
      #|│       ├-variable x (Int)
      #|│       └-int literal 0 (Int)
      #|└-body: block (Unit)
      #|        ├-let statement
      #|        │ ├-pattern: ident pattern a
      #|        │ ├-type: : Int
      #|        │ └-expr: variable x (Int)
      #|        └-assign statement: =
      #|          ├-lvalue: lvalue x (Int)
      #|          └-expr: binary expr: - (Int)
      #|                  ├-variable x (Int)
      #|                  └-int literal 1 (Int)
      #|        
    ),
  )
}
