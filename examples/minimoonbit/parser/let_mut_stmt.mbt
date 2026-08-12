///|
/// Represents the MiniMoonBit parser AST node `LetMutStmt`.
pub(all) struct LetMutStmt {
  /// Stores the `name` component of this parser AST node.
  name : String
  /// Stores the `ty` component of this parser AST node.
  ty : Type?
  /// Stores the `expr` component of this parser AST node.
  expr : Expr
} derive(Eq)

///|
/// Formats `LetMutStmt` using MiniMoonBit source notation.
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
  let name_formatted = format_lines(
    [name_text],
    head_with="├-",
    continue_with="│ ",
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
    "\{prefix}\n\{name_formatted}\n\{expr_formatted}"
  } else {
    "\{prefix}\n\{name_formatted}\n\{type_str}\n\{expr_formatted}"
  }
}

///|
/// Parses the `parse_let_mut_stmt` syntax form and returns the unconsumed token suffix.
pub fn parse_let_mut_stmt(
  tokens : ArrayView[Token],
) -> (LetMutStmt, ArrayView[Token]) raise ParseError {
  guard tokens
    is [{ kind: Keyword(Let), .. }, { kind: Keyword(Mut), .. }, .. tokens] else {
    println("Compiler ICE: Misuse parse_let_mut_stmt")
    panic()
  }
  guard tokens is [{ kind: Lower(name), .. }, .. tokens] else {
    @lexer.throw_(tokens[0], "Parse Error: Expect a lower ident", Error)
    raise ParseError("Expect a lower ident")
  }
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
    let let_mut_stmt = LetMutStmt::{ name, ty, expr }
    return (let_mut_stmt, rest)
  }
  let (expr, tokens) = parse_expr(tokens)
  let let_mut_stmt = LetMutStmt::{ name, ty, expr }
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
      "Parse Error: Expect ';' or '}' or newline after let mut statement",
      Error,
    )
    tokens
  }
  (let_mut_stmt, tokens)
}

///|
test "LetMutStmt to_string Test - Basic" {
  let color = false
  let code =
    #|let mut x = 42 ; let mut y = x + 1 ; let mut z = foo() ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `let mut x = 42`
  let (let_mut_stmt, rest) = parse_let_mut_stmt(tokens)
  inspect(
    let_mut_stmt.to_string(color~),
    content=(
      #|let mut statement
      #|├-name: x
      #|└-expr: int literal 42
    ),
  )

  // Skip semicolon and parse `let mut y = x + 1`
  let rest = skip_semicolon(rest)
  let (let_mut_stmt, rest) = parse_let_mut_stmt(rest)
  inspect(
    let_mut_stmt.to_string(color~),
    content=(
      #|let mut statement
      #|├-name: y
      #|└-expr: binary expr: +
      #|        ├-variable x
      #|        └-int literal 1
    ),
  )

  // Skip semicolon and parse `let mut z = foo()`
  let rest = skip_semicolon(rest)
  let (let_mut_stmt, _) = parse_let_mut_stmt(rest)
  inspect(
    let_mut_stmt.to_string(color~),
    content=(
      #|let mut statement
      #|├-name: z
      #|└-expr: function call
      #|        └-variable foo
    ),
  )
}

///|
test "LetMutStmt to_string Test - With Type" {
  let color = false
  let code =
    #|let mut x : Int = 42 ; let mut y : Double = 3.14 ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `let mut x : Int = 42`
  let (let_mut_stmt, rest) = parse_let_mut_stmt(tokens)
  let output = let_mut_stmt.to_string(color~)
  // Check basic structure, since Type display format may vary
  assert_true(output.contains("let mut statement"))
  assert_true(output.contains("name: x"))
  assert_true(output.contains("type"))
  assert_true(output.contains("int literal 42"))

  // Skip semicolon and parse `let mut y : Double = 3.14`
  let rest = skip_semicolon(rest)
  let (let_mut_stmt, _) = parse_let_mut_stmt(rest)
  let output = let_mut_stmt.to_string(color~)
  assert_true(output.contains("let mut statement"))
  assert_true(output.contains("name: y"))
  assert_true(output.contains("type"))
  assert_true(output.contains("double literal 3.14"))
}

///|
test "LetMutStmt to_string Test - Complex" {
  let color = false
  let code =
    #|let mut arr = [1, 2, 3] ; let mut sum = a + b * c ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `let mut arr = [1, 2, 3]`
  let (let_mut_stmt, rest) = parse_let_mut_stmt(tokens)
  inspect(
    let_mut_stmt.to_string(color~),
    content=(
      #|let mut statement
      #|├-name: arr
      #|└-expr: array
      #|        ├-int literal 1
      #|        ├-int literal 2
      #|        └-int literal 3
    ),
  )

  // Skip semicolon and parse `let mut sum = a + b * c`
  let rest = skip_semicolon(rest)
  let (let_mut_stmt, _) = parse_let_mut_stmt(rest)
  inspect(
    let_mut_stmt.to_string(color~),
    content=(
      #|let mut statement
      #|├-name: sum
      #|└-expr: binary expr: +
      #|        ├-variable a
      #|        └-binary expr: *
      #|          ├-variable b
      #|          └-variable c
    ),
  )
}
