///|
/// Represents the MiniMoonBit parser AST node `Stmt`.
pub(all) struct Stmt {
  /// Stores the `kind` component of this parser AST node.
  kind : StmtKind
  /// Stores the `toks` component of this parser AST node.
  toks : ArrayView[Token]
} derive(Eq)

///|
/// Formats `Stmt` using MiniMoonBit source notation.
pub impl Show for Stmt with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `Stmt` value with optional ANSI coloring.
pub fn Stmt::to_string(self : Self, color? : Bool = true) -> String {
  match self.kind {
    LetStmt(let_stmt) => let_stmt.to_string(color~)
    LetMutStmt(let_mut_stmt) => let_mut_stmt.to_string(color~)
    AssignStmt(assign_stmt) => assign_stmt.to_string(color~)
    ExprStmt(expr) => expr.to_string(color~)
    ReturnStmt(expr_opt) => {
      let prefix = "return statement"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      match expr_opt {
        Some(expr) => {
          let expr_str = expr.to_string(color~)
          let expr_lines = expr_str
            .split("\n")
            .map(sv => sv.to_owned())
            .to_array()
          let expr_formatted = format_lines(expr_lines)
          "\{prefix}\n\{expr_formatted}"
        }
        None => prefix
      }
    }
    NoopStmt => {
      let text = "noop statement"
      if color {
        @color.taint(text, Magenta)
      } else {
        text
      }
    }
    WhileStmt(while_stmt) => while_stmt.to_string(color~)
    ForStmt(for_stmt) => for_stmt.to_string(color~)
    LocalFunction(local_fn) => local_fn.to_string(color~)
  }
}

///|
/// Enumerates the parser AST forms represented by `StmtKind`.
pub(all) enum StmtKind {
  /// Represents the `LetStmt` parser AST form.
  LetStmt(LetStmt)
  /// Represents the `LetMutStmt` parser AST form.
  LetMutStmt(LetMutStmt)
  /// Represents the `AssignStmt` parser AST form.
  AssignStmt(AssignStmt)
  /// Represents the `WhileStmt` parser AST form.
  WhileStmt(WhileStmt)
  /// Represents the `ForStmt` parser AST form.
  ForStmt(ForStmt)
  /// Represents the `ExprStmt` parser AST form.
  ExprStmt(Expr)
  /// Represents the `ReturnStmt` parser AST form.
  ReturnStmt(Expr?)
  /// Represents the `LocalFunction` parser AST form.
  LocalFunction(LocalFunction)
  /// Represents the `NoopStmt` parser AST form.
  NoopStmt // For Error Recovery
} derive(Eq)

///|
/// Formats `StmtKind` using MiniMoonBit source notation.
pub impl Show for StmtKind with fn output(self, logger) {
  let s = match self {
    LetStmt(let_stmt) => let_stmt.to_string()
    LetMutStmt(let_mut_stmt) => let_mut_stmt.to_string()
    AssignStmt(assign_stmt) => assign_stmt.to_string()
    ExprStmt(expr) => "expr: \{expr}"
    ReturnStmt(Some(expr)) => "return \{expr}"
    ReturnStmt(None) => "return"
    NoopStmt => "noop"
    WhileStmt(_) => "while (...) { ... }"
    ForStmt(_) => "for (...) { ... }"
    LocalFunction(_) => "fn (...) { ... }"
  }
  logger.write_string(s)
}

///|
/// Creates a `Stmt` parser AST node.
pub fn Stmt::new(
  kind : StmtKind,
  init_tokens : ArrayView[Token],
  rest_tokens : ArrayView[Token],
) -> Stmt {
  let len = rest_tokens.start_offset() - init_tokens.start_offset()
  let toks = init_tokens[0:len]
  Stmt::{ kind, toks, }
}

///|
/// Parses the `parse_stmt` syntax form and returns the unconsumed token suffix.
pub fn parse_stmt(tokens : ArrayView[Token]) -> (Stmt, ArrayView[Token]) {
  let init_tokens = tokens
  match tokens {
    [{ kind: Keyword(Let), .. }, { kind: Keyword(Mut), .. }, ..] as tokens => {
      let (let_mut_stmt, rest) = parse_let_mut_stmt(tokens) catch {
        _ => return next_stmt_check_point_with_noop(tokens)
      }
      let stmt = Stmt::new(LetMutStmt(let_mut_stmt), init_tokens, rest)
      (stmt, rest)
    }
    [{ kind: Keyword(Let), .. }, ..] as tokens => {
      let (let_stmt, rest) = parse_let_stmt(tokens) catch {
        _ => return next_stmt_check_point_with_noop(tokens)
      }
      let stmt = Stmt::new(LetStmt(let_stmt), init_tokens, rest)
      (stmt, rest)
    }
    [{ kind: Keyword(Return), line, .. }, .. tokens] => {
      let (expr, rest) = if tokens is [{ kind: Symbol(";"), .. }, .. tokens] {
        (None, tokens)
      } else if tokens is [{ kind: Bracket('}'), .. }, ..] {
        // Allow return at end of function without semicolon
        (None, tokens)
      } else if tokens is [tok, ..] && tok.line != line {
        // New line after return keyword means no expression
        (None, tokens)
      } else {
        let (expr, tokens) = parse_expr(tokens) catch {
          _ => return next_stmt_check_point_with_noop(tokens)
        }
        let tokens = if tokens is [{ kind: Symbol(";"), .. }, .. tokens] {
          tokens
        } else if tokens is [tok, ..] &&
          tok.line != expr.toks[expr.toks.length() - 1].line {
          tokens
        } else {
          @lexer.throw_(
            tokens[0],
            "Parse Error: Expected ';' or a newline after return statement",
            Error,
          )
          next_stmt_check_point(tokens)
        }
        (Some(expr), tokens)
      }
      let stmt = Stmt::new(StmtKind::ReturnStmt(expr), init_tokens, rest)
      (stmt, rest)
    }
    // Assignment must start with a lower ident
    // but starting with a lower ident does not
    // mean it's an assignment.
    //
    // Hence need to parse a left value first and
    // check if it's followed by an assignment operator.
    [{ kind: Lower(_), .. }, ..] as tokens => {
      let (_, rest) = parse_left_value(tokens) catch {
        _ => return next_stmt_check_point_with_noop(tokens)
      }
      if rest is [{ kind: AssignOp(_), .. }, ..] {
        let (assign_stmt, rest) = parse_assign_stmt(tokens) catch {
          _ => return next_stmt_check_point_with_noop(tokens)
        }
        let stmt = Stmt::new(
          StmtKind::AssignStmt(assign_stmt),
          init_tokens,
          rest,
        )
        (stmt, rest)
      } else {
        let (expr, rest) = parse_expr(tokens) catch {
          _ => return next_stmt_check_point_with_noop(tokens)
        }
        let stmt = Stmt::new(StmtKind::ExprStmt(expr), init_tokens, rest)
        let rest = if rest is [{ kind: Symbol(";"), .. }, .. rest] {
          rest
        } else if rest is [{ kind: Bracket('}'), .. }, ..] {
          rest
        } else if rest is [tok, ..] &&
          tok.line != expr.toks[expr.toks.length() - 1].line {
          // Allow newline after expression statement
          rest
        } else {
          @lexer.throw_(
            rest[0],
            "Parse Error: Expected ';' or a newline after expression statement",
            Error,
          )
          next_stmt_check_point(rest)
        }
        (stmt, rest)
      }
    }
    [{ kind: Keyword(While), .. }, ..] as tokens => {
      let (while_stmt, rest) = parse_while_stmt(tokens) catch {
        _ => return next_stmt_check_point_with_noop(tokens)
      }
      let stmt = Stmt::new(StmtKind::WhileStmt(while_stmt), init_tokens, rest)
      (stmt, rest)
    }
    [{ kind: Keyword(Fn), .. }, ..] as tokens => {
      let (local_function, rest) = parse_local_function(tokens) catch {
        _ => return next_stmt_check_point_with_noop(tokens)
      }
      let stmt = Stmt::new(
        StmtKind::LocalFunction(local_function),
        init_tokens,
        rest,
      )
      (stmt, rest)
    }
    [{ kind: Keyword(For), .. }, ..] as tokens => {
      let (for_stmt, rest) = parse_for_stmt(tokens) catch {
        _ => return next_stmt_check_point_with_noop(tokens)
      }
      let stmt = Stmt::new(StmtKind::ForStmt(for_stmt), init_tokens, rest)
      (stmt, rest)
    }
    [] => {
      println("Compiler ICE: Empty Token ArrayView")
      panic()
    }
    tokens => {
      let (expr, rest) = parse_expr(tokens) catch {
        _ => return next_stmt_check_point_with_noop(tokens)
      }
      let stmt = Stmt::new(StmtKind::ExprStmt(expr), init_tokens, rest)
      let rest = if rest is [{ kind: Symbol(";"), .. }, .. rest] {
        rest
      } else if rest is [{ kind: Bracket('}'), .. }, ..] {
        rest
      } else if rest is [tok, ..] &&
        tok.line != expr.toks[expr.toks.length() - 1].line {
        // Allow newline after expression statement
        rest
      } else {
        @lexer.throw_(
          rest[0],
          "Parse Error: Expected ';' or a newline after expression statement",
          Error,
        )
        next_stmt_check_point(rest)
      }
      (stmt, rest)
    }
  }
}

///|
fn next_stmt_check_point(tokens : ArrayView[Token]) -> ArrayView[Token] {
  let line = tokens[0].line
  for current = tokens {
    match current {
      [{ kind: Symbol(";"), .. }, .. tokens] => break tokens
      [tok, ..] as tokens if tok.line != line => break tokens
      [{ kind: Bracket('}'), .. }, ..] as tokens => break tokens
      [{ kind: Bracket('{'), .. }, ..] as tokens => break tokens
      [] as tokens => break tokens
      [_, .. tokens] => continue tokens
    }
  }
}

///|
fn next_stmt_check_point_with_noop(
  tokens : ArrayView[Token],
) -> (Stmt, ArrayView[Token]) {
  let rest = next_stmt_check_point(tokens)
  let noop_stmt = StmtKind::NoopStmt
  let stmt = Stmt::new(noop_stmt, tokens, rest)
  (stmt, rest)
}

///|
test "Stmt to_string Test - Basic" {
  let color = false
  let code =
    #|let x = 42 ; let mut y = 10 ; x = y + 1 ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `let x = 42`
  let (stmt, rest) = parse_stmt(tokens)
  inspect(
    stmt.to_string(color~),
    content=(
      #|let statement
      #|├-pattern: ident pattern x
      #|└-expr: int literal 42
    ),
  )

  // Skip semicolon and parse `let mut y = 10`
  let rest = skip_semicolon(rest)
  let (stmt, rest) = parse_stmt(rest)
  inspect(
    stmt.to_string(color~),
    content=(
      #|let mut statement
      #|├-name: y
      #|└-expr: int literal 10
    ),
  )

  // Skip semicolon and parse `x = y + 1`
  let rest = skip_semicolon(rest)
  let (stmt, _) = parse_stmt(rest)
  inspect(
    stmt.to_string(color~),
    content=(
      #|assign statement: =
      #|├-lvalue: lvalue x
      #|└-expr: binary expr: +
      #|        ├-variable y
      #|        └-int literal 1
    ),
  )
}

///|
test "Stmt to_string Test - Expr and Return" {
  let color = false
  let code =
    #|foo(42) ; return ; return x + 1 ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `foo(42)` (ExprStmt)
  let (stmt, rest) = parse_stmt(tokens)
  let output = stmt.to_string(color~)
  inspect(
    output,
    content=(
      #|function call
      #|├-variable foo
      #|└-int literal 42
    ),
  )

  // Skip semicolon and parse `return` (ReturnStmt with no expr)
  let rest = skip_semicolon(rest)
  let (stmt, rest) = parse_stmt(rest)
  inspect(stmt.to_string(color~), content="return statement")

  // Skip semicolon and parse `return x + 1` (ReturnStmt with expr)
  let rest = skip_semicolon(rest)
  let (stmt, _) = parse_stmt(rest)
  inspect(
    stmt.to_string(color~),
    content=(
      #|return statement
      #|└-binary expr: +
      #|  ├-variable x
      #|  └-int literal 1
    ),
  )
}

///|
test "Stmt to_string Test - Complex Expr" {
  let color = false
  let code =
    #|arr[0] ; point.x.y ; add(1, 2, 3) ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `arr[0]` (ExprStmt with array access)
  let (stmt, rest) = parse_stmt(tokens)
  inspect(
    stmt.to_string(color~),
    content=(
      #|array access
      #|├-variable arr
      #|└-int literal 0
    ),
  )

  // Skip semicolon and parse `point.x.y` (ExprStmt with nested field access)
  let rest = skip_semicolon(rest)
  let (stmt, rest) = parse_stmt(rest)
  inspect(
    stmt.to_string(color~),
    content=(
      #|field access .y
      #|└-field access .x
      #|  └-variable point
    ),
  )

  // Skip semicolon and parse `add(1, 2, 3)` (ExprStmt with function call)
  let rest = skip_semicolon(rest)
  let (stmt, _) = parse_stmt(rest)
  inspect(
    stmt.to_string(color~),
    content=(
      #|function call
      #|├-variable add
      #|├-int literal 1
      #|├-int literal 2
      #|└-int literal 3
    ),
  )
}

///|
test "Stmt to_string Test - While" {
  let color = false
  let code =
    #|while i < 10 { i += 1 ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse while statement
  let (stmt, _) = parse_stmt(tokens)
  inspect(
    stmt.to_string(color~),
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
test "Stmt to_string Test - For" {
  let color = false
  let code =
    #|for i = 0; i < 10; i += 1 { let x = i ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse for statement
  let (stmt, _) = parse_stmt(tokens)
  inspect(
    stmt.to_string(color~),
    content=(
      #|for statement
      #|├-inits:
      #|│ └-i = int literal 0
      #|├-cond: binary expr: <
      #|│       ├-variable i
      #|│       └-int literal 10
      #|├-steps:
      #|│ └-i += int literal 1
      #|└-body: block
      #|        └-let statement
      #|          ├-pattern: ident pattern x
      #|          └-expr: variable i
      #|        
    ),
  )
}

///|
test "Stmt to_string Test - LocalFunction" {
  let color = false
  let code =
    #|fn helper(x, y) { return x + y ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse local function statement
  let (stmt, _) = parse_stmt(tokens)
  inspect(
    stmt.to_string(color~),
    content=(
      #|local function: helper
      #|├-params:
      #|│ ├-x
      #|│ └-y
      #|└-body: block
      #|        └-return statement
      #|          └-binary expr: +
      #|            ├-variable x
      #|            └-variable y
      #|        
    ),
  )
}
