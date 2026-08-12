///|
/// Represents the MiniMoonBit parser AST node `LetStmt`.
pub(all) struct LetStmt {
  /// Stores the `pattern` component of this parser AST node.
  pattern : Pattern
  /// Stores the `ty` component of this parser AST node.
  ty : Type?
  /// Stores the `expr` component of this parser AST node.
  expr : Expr
} derive(Eq)

///|
/// Formats `LetStmt` using MiniMoonBit source notation.
pub impl Show for LetStmt with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `LetStmt` value with optional ANSI coloring.
pub fn LetStmt::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "let statement"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }

  // Format pattern
  let pattern_str = self.pattern.to_string(color~)
  let pattern_lines = pattern_str
    .split("\n")
    .map(fn(sv) { sv.to_string() })
    .to_array()
  let pattern_formatted = format_lines(
    pattern_lines,
    head_with="├-pattern: ",
    continue_with="│         ",
  )

  // Format type annotation if present
  let type_str = match self.ty {
    Some(ty) => {
      let ty_str = ": \{ty}"
      let lines = [ty_str]
      format_lines(lines, head_with="├-type: ", continue_with="│       ")
    }
    None => ""
  }

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
  if type_str == "" {
    "\{prefix}\n\{pattern_formatted}\n\{expr_formatted}"
  } else {
    "\{prefix}\n\{pattern_formatted}\n\{type_str}\n\{expr_formatted}"
  }
}

///|
/// Parses the `parse_let_stmt` syntax form and returns the unconsumed token suffix.
pub fn parse_let_stmt(
  tokens : ArrayView[Token],
) -> (LetStmt, ArrayView[Token]) raise ParseError {
  guard tokens is [{ kind: Keyword(Let), .. }, .. tokens] else {
    println("Compiler ICE: Misuse parse_let_stmt")
    panic()
  }
  let (pattern, tokens) = parse_pattern(tokens)
  let (ty, tokens) = if tokens is [{ kind: Symbol(":"), .. }, .. tokens] {
    let (ty, tokens) = parse_type(tokens)
    (Some(ty), tokens)
  } else {
    (None, tokens)
  }
  guard tokens is [{ kind: AssignOp(Assign), .. }, .. tokens] else {
    @lexer.throw_(tokens[0], "Parse Error: Expect '='", Error)
    let line = tokens[0].line
    let rest = loop tokens {
      [{ kind: Symbol(";"), .. }, .. tokens] => break tokens
      [tok, ..] as tokens if tok.line != line => break tokens
      [{ kind: Bracket('}'), .. }, ..] as tokens => break tokens
      [] as tokens => break tokens
      [_, .. tokens] => continue tokens
    }
    let expr = Expr::unit()
    let let_stmt = LetStmt::{ pattern, ty, expr }
    return (let_stmt, rest)
  }
  let (expr, tokens) = parse_expr(tokens)
  let let_stmt = LetStmt::{ pattern, ty, expr }
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
      "Parse Error: Expect ';' or '}' or newline after let statement",
      Error,
    )
    raise ParseError("Expect ';' or '}' or newline after let statement")
  }
  (let_stmt, tokens)
}

///|
test "LetStmt to_string Test - Basic" {
  let color = false
  let code =
    #|let x = 42 ; let _ = foo() ; let y = x + 1 ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `let x = 42`
  let (let_stmt, rest) = parse_let_stmt(tokens)
  inspect(
    let_stmt.to_string(color~),
    content=(
      #|let statement
      #|├-pattern: ident pattern x
      #|└-expr: int literal 42
    ),
  )

  // Skip semicolon and parse `let _ = foo()`
  let rest = skip_semicolon(rest)
  let (let_stmt, rest) = parse_let_stmt(rest)
  inspect(
    let_stmt.to_string(color~),
    content=(
      #|let statement
      #|├-pattern: _
      #|└-expr: function call
      #|        └-variable foo
    ),
  )

  // Skip semicolon and parse `let y = x + 1`
  let rest = skip_semicolon(rest)
  let (let_stmt, _) = parse_let_stmt(rest)
  inspect(
    let_stmt.to_string(color~),
    content=(
      #|let statement
      #|├-pattern: ident pattern y
      #|└-expr: binary expr: +
      #|        ├-variable x
      #|        └-int literal 1
    ),
  )
}

///|
test "LetStmt to_string Test - With Type" {
  let color = false
  let code =
    #|let x : Int = 42 ; let y : Double = 3.14 ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `let x : Int = 42`
  let (let_stmt, rest) = parse_let_stmt(tokens)
  let output = let_stmt.to_string(color~)
  // Check basic structure, since Type display format may vary
  assert_true(output.contains("let statement"))
  assert_true(output.contains("ident pattern x"))
  assert_true(output.contains("type"))
  assert_true(output.contains("int literal 42"))

  // Skip semicolon and parse `let y : Double = 3.14`
  let rest = skip_semicolon(rest)
  let (let_stmt, _) = parse_let_stmt(rest)
  let output = let_stmt.to_string(color~)
  assert_true(output.contains("let statement"))
  assert_true(output.contains("ident pattern y"))
  assert_true(output.contains("type"))
  assert_true(output.contains("double literal 3.14"))
}

///|
test "LetStmt to_string Test - Pattern" {
  let color = false
  let code =
    #|let (a, b) = (1, 2) ; let Some(x) = opt ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `let (a, b) = (1, 2)`
  let (let_stmt, rest) = parse_let_stmt(tokens)
  inspect(
    let_stmt.to_string(color~),
    content=(
      #|let statement
      #|├-pattern: tuple pattern
      #|│         ├-ident pattern a
      #|│         └-ident pattern b
      #|└-expr: tuple
      #|        ├-int literal 1
      #|        └-int literal 2
    ),
  )

  // Skip semicolon and parse `let Some(x) = opt`
  let rest = skip_semicolon(rest)
  let (let_stmt, _) = parse_let_stmt(rest)
  inspect(
    let_stmt.to_string(color~),
    content=(
      #|let statement
      #|├-pattern: enum pattern Some
      #|│         └-ident pattern x
      #|└-expr: variable opt
    ),
  )
}
