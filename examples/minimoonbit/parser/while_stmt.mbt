///|
/// Represents the MiniMoonBit parser AST node `WhileStmt`.
pub(all) struct WhileStmt {
  /// Stores the `cond` component of this parser AST node.
  cond : Expr
  /// Stores the `body` component of this parser AST node.
  body : BlockExpr
} derive(Eq)

///|
/// Formats `WhileStmt` using MiniMoonBit source notation.
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
  let cond_formatted = format_lines(
    cond_lines,
    head_with="├-cond: ",
    continue_with="│       ",
  )

  // Format body
  let body_str = self.body.to_string(color~)
  let body_lines = body_str.split("\n").map(sv => sv.to_owned()).to_array()
  let body_formatted = format_lines(
    body_lines,
    head_with="└-body: ",
    continue_with="        ",
  )
  "\{prefix}\n\{cond_formatted}\n\{body_formatted}"
}

///|
/// Parses the `parse_while_stmt` syntax form and returns the unconsumed token suffix.
pub fn parse_while_stmt(
  tokens : ArrayView[Token],
) -> (WhileStmt, ArrayView[Token]) raise ParseError {
  guard tokens is [{ kind: Keyword(While), .. }, .. tokens] else {
    println("Compiler ICE: Misuse parse_while_stmt")
    panic()
  }
  let (cond, tokens) = parse_expr(tokens)
  let (body, tokens) = parse_block_expr(tokens)
  let while_stmt = WhileStmt::{ cond, body, }
  (while_stmt, tokens)
}

///|
test "WhileStmt to_string Test - Simple" {
  let color = false
  let code =
    #|while x { let y = 1 ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse simple while
  let (while_stmt, _) = parse_while_stmt(tokens)
  inspect(
    while_stmt.to_string(color~),
    content=(
      #|while statement
      #|├-cond: variable x
      #|└-body: block
      #|        └-let statement
      #|          ├-pattern: ident pattern y
      #|          └-expr: int literal 1
      #|        
    ),
  )
}

///|
test "WhileStmt to_string Test - Complex Condition" {
  let color = false
  let code =
    #|while i < 10 { i += 1 ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse while with complex condition
  let (while_stmt, _) = parse_while_stmt(tokens)
  inspect(
    while_stmt.to_string(color~),
    content=(
      #|while statement
      #|├-cond: binary expr: <
      #|│       ├-variable i
      #|│       └-int literal 10
      #|└-body: block
      #|        └-assign statement: +=
      #|          ├-lvalue: lvalue i
      #|          └-expr: int literal 1
      #|        
    ),
  )
}

///|
test "WhileStmt to_string Test - Multiple Statements" {
  let color = false
  let code =
    #|while x > 0 { let a = x ; x = x - 1 ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse while with multiple statements in body
  let (while_stmt, _) = parse_while_stmt(tokens)
  inspect(
    while_stmt.to_string(color~),
    content=(
      #|while statement
      #|├-cond: binary expr: >
      #|│       ├-variable x
      #|│       └-int literal 0
      #|└-body: block
      #|        ├-let statement
      #|        │ ├-pattern: ident pattern a
      #|        │ └-expr: variable x
      #|        └-assign statement: =
      #|          ├-lvalue: lvalue x
      #|          └-expr: binary expr: -
      #|                  ├-variable x
      #|                  └-int literal 1
      #|        
    ),
  )
}
