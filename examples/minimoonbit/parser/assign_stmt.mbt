///|
/// Represents the MiniMoonBit parser AST node `AssignStmt`.
pub(all) struct AssignStmt {
  /// Stores the `left_value` component of this parser AST node.
  left_value : LeftValue
  /// Stores the `op` component of this parser AST node.
  op : AssignOp
  /// Stores the `expr` component of this parser AST node.
  expr : Expr
} derive(Eq)

///|
/// Formats `AssignStmt` using MiniMoonBit source notation.
pub impl Show for AssignStmt with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `AssignStmt` value with optional ANSI coloring.
pub fn AssignStmt::to_string(self : Self, color? : Bool = true) -> String {
  let op_str = match self.op {
    Assign => "="
    PlusAssign => "+="
    MinusAssign => "-="
    MultAssign => "*="
    DivAssign => "/="
    ModAssign => "%="
  }
  let prefix = "assign statement: \{op_str}"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }

  // Format left value
  let lvalue_str = self.left_value.to_string(color~)
  let lvalue_lines = lvalue_str
    .split("\n")
    .map(fn(sv) { sv.to_string() })
    .to_array()
  let lvalue_formatted = format_lines(
    lvalue_lines,
    head_with="├-lvalue: ",
    continue_with="│         ",
  )

  // Format expression
  let expr_str = self.expr.to_string(color~)
  let expr_lines = expr_str
    .split("\n")
    .map(fn(sv) { sv.to_string() })
    .to_array()
  let expr_formatted = format_lines(
    expr_lines,
    head_with="└-expr: ",
    continue_with="        ",
  )
  "\{prefix}\n\{lvalue_formatted}\n\{expr_formatted}"
}

///|
/// Enumerates the parser AST forms represented by `AssignOp`.
pub(all) enum AssignOp {
  /// Represents the `Assign` parser AST form.
  Assign // =
  /// Represents the `PlusAssign` parser AST form.
  PlusAssign // +=
  /// Represents the `MinusAssign` parser AST form.
  MinusAssign // -=
  /// Represents the `MultAssign` parser AST form.
  MultAssign // *=
  /// Represents the `DivAssign` parser AST form.
  DivAssign // /=
  /// Represents the `ModAssign` parser AST form.
  ModAssign // %=
} derive(Eq)

///|
/// Formats `AssignOp` using MiniMoonBit source notation.
pub impl Show for AssignOp with fn output(self, logger) {
  let s = match self {
    Assign => "="
    PlusAssign => "+="
    MinusAssign => "-="
    MultAssign => "*="
    DivAssign => "/="
    ModAssign => "%="
  }
  logger.write_string(s)
}

///|
fn AssignOp::from_tok_assign_op(op : @lexer.AssignOp) -> AssignOp {
  match op {
    Assign => Assign
    PlusAssign => PlusAssign
    MinusAssign => MinusAssign
    MultAssign => MultAssign
    DivAssign => DivAssign
    ModAssign => ModAssign
  }
}

///|
/// Parses the `parse_assign_stmt` syntax form and returns the unconsumed token suffix.
pub fn parse_assign_stmt(
  tokens : ArrayView[Token],
) -> (AssignStmt, ArrayView[Token]) raise ParseError {
  let (left_value, tokens) = parse_left_value(tokens)
  guard tokens is [{ kind: AssignOp(op), .. }, .. tokens] else {
    @lexer.throw_(tokens[0], "Parse Error: Expect an assign operator", Error)
    raise ParseError("Expect an assign operator")
  }
  let op = AssignOp::from_tok_assign_op(op)
  let (expr, tokens) = parse_expr(tokens)
  let assign_stmt = AssignStmt::{ left_value, op, expr }
  let tokens = if tokens is [{ kind: Symbol(";"), .. }, .. tokens] {
    tokens
  } else if tokens is [tok, ..] &&
    tok.line != expr.toks[expr.toks.length() - 1].line {
    tokens
  } else if tokens is [{ kind: Bracket('}'), .. }, ..] {
    tokens
  } else {
    @lexer.throw_(
      tokens[0],
      "Parse Error: Expect ';' or '} or newline after assign statement",
      Error,
    )
    raise ParseError("Expect ';' or '}' or newline after assign statement")
  }
  (assign_stmt, tokens)
}

///|
test "AssignStmt to_string Test - Basic" {
  let color = false
  let code =
    #|x = 42 ; y = x + 1 ; z = foo() ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `x = 42`
  let (assign_stmt, rest) = parse_assign_stmt(tokens)
  inspect(
    assign_stmt.to_string(color~),
    content=(
      #|assign statement: =
      #|├-lvalue: lvalue x
      #|└-expr: int literal 42
    ),
  )

  // Skip semicolon and parse `y = x + 1`
  let rest = skip_semicolon(rest)
  let (assign_stmt, rest) = parse_assign_stmt(rest)
  inspect(
    assign_stmt.to_string(color~),
    content=(
      #|assign statement: =
      #|├-lvalue: lvalue y
      #|└-expr: binary expr: +
      #|        ├-variable x
      #|        └-int literal 1
    ),
  )

  // Skip semicolon and parse `z = foo()`
  let rest = skip_semicolon(rest)
  let (assign_stmt, _) = parse_assign_stmt(rest)
  inspect(
    assign_stmt.to_string(color~),
    content=(
      #|assign statement: =
      #|├-lvalue: lvalue z
      #|└-expr: function call
      #|        └-variable foo
    ),
  )
}

///|
test "AssignStmt to_string Test - Operators" {
  let color = false
  let code =
    #|x += 1 ; y -= 2 ; z *= 3 ; a /= 4 ; b %= 5 ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `x += 1`
  let (assign_stmt, rest) = parse_assign_stmt(tokens)
  inspect(
    assign_stmt.to_string(color~),
    content=(
      #|assign statement: +=
      #|├-lvalue: lvalue x
      #|└-expr: int literal 1
    ),
  )

  // Skip semicolon and parse `y -= 2`
  let rest = skip_semicolon(rest)
  let (assign_stmt, rest) = parse_assign_stmt(rest)
  inspect(
    assign_stmt.to_string(color~),
    content=(
      #|assign statement: -=
      #|├-lvalue: lvalue y
      #|└-expr: int literal 2
    ),
  )

  // Skip semicolon and parse `z *= 3`
  let rest = skip_semicolon(rest)
  let (assign_stmt, rest) = parse_assign_stmt(rest)
  inspect(
    assign_stmt.to_string(color~),
    content=(
      #|assign statement: *=
      #|├-lvalue: lvalue z
      #|└-expr: int literal 3
    ),
  )

  // Skip semicolon and parse `a /= 4`
  let rest = skip_semicolon(rest)
  let (assign_stmt, rest) = parse_assign_stmt(rest)
  inspect(
    assign_stmt.to_string(color~),
    content=(
      #|assign statement: /=
      #|├-lvalue: lvalue a
      #|└-expr: int literal 4
    ),
  )

  // Skip semicolon and parse `b %= 5`
  let rest = skip_semicolon(rest)
  let (assign_stmt, _) = parse_assign_stmt(rest)
  inspect(
    assign_stmt.to_string(color~),
    content=(
      #|assign statement: %=
      #|├-lvalue: lvalue b
      #|└-expr: int literal 5
    ),
  )
}

///|
test "AssignStmt to_string Test - Complex" {
  let color = false
  let code =
    #|arr[0] = 10 ; point.x = 20 ; matrix[i].data = value ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `arr[0] = 10`
  let (assign_stmt, rest) = parse_assign_stmt(tokens)
  inspect(
    assign_stmt.to_string(color~),
    content=(
      #|assign statement: =
      #|├-lvalue: lvalue array access
      #|│         ├-lvalue arr
      #|│         └-int literal 0
      #|└-expr: int literal 10
    ),
  )

  // Skip semicolon and parse `point.x = 20`
  let rest = skip_semicolon(rest)
  let (assign_stmt, rest) = parse_assign_stmt(rest)
  inspect(
    assign_stmt.to_string(color~),
    content=(
      #|assign statement: =
      #|├-lvalue: lvalue field access .x
      #|│         └-lvalue point
      #|└-expr: int literal 20
    ),
  )

  // Skip semicolon and parse `matrix[i].data = value`
  let rest = skip_semicolon(rest)
  let (assign_stmt, _) = parse_assign_stmt(rest)
  inspect(
    assign_stmt.to_string(color~),
    content=(
      #|assign statement: =
      #|├-lvalue: lvalue field access .data
      #|│         └-lvalue array access
      #|│           ├-lvalue matrix
      #|│           └-variable i
      #|└-expr: variable value
    ),
  )
}
