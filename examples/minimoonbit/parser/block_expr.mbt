///|
/// Represents the MiniMoonBit parser AST node `BlockExpr`.
pub(all) struct BlockExpr {
  /// Stores the `stmts` component of this parser AST node.
  stmts : Array[Stmt]
  /// Stores the `toks` component of this parser AST node.
  toks : ArrayView[Token]
} derive(Eq)

///|
/// Formats `BlockExpr` using MiniMoonBit source notation.
pub impl Show for BlockExpr with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `BlockExpr` value with optional ANSI coloring.
pub fn BlockExpr::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "block"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
  if self.stmts.length() == 0 {
    return "\{prefix} (empty)"
  }
  let mut result = prefix
  for i = 0; i < self.stmts.length(); i = i + 1 {
    let stmt = self.stmts[i]
    let stmt_str = stmt.to_string(color~)
    let stmt_lines = stmt_str
      .split("\n")
      .map(fn(sv) { sv.to_string() })
      .to_array()
    let is_last = i == self.stmts.length() - 1
    let stmt_formatted = if is_last {
      format_lines(stmt_lines, head_with="└-", continue_with="  ")
    } else {
      format_lines(stmt_lines, head_with="├-", continue_with="│ ")
    }
    result = "\{result}\n\{stmt_formatted}"
  }
  result + "\n"
}

///|
/// Parses the `parse_block_expr` syntax form and returns the unconsumed token suffix.
pub fn parse_block_expr(
  tokens : ArrayView[Token],
) -> (BlockExpr, ArrayView[Token]) {
  let init_tokens = tokens
  guard tokens is [{ kind: Bracket('{'), .. }, .. tokens] else {
    println("Compiler ICE: Misuse parse_block_expr")
    panic()
  }
  let stmts : Array[Stmt] = Array::new()
  let tokens = loop tokens {
    [{ kind: Bracket('}'), .. }, .. rest] => break rest
    [] => {
      println("Compiler ICE: Failed Parsing BlockExpr, Empty Token ArrayView")
      panic()
    }
    tokens => {
      let (stmt, tokens) = parse_stmt(tokens)
      stmts.push(stmt)
      continue tokens
    }
  }
  let len = tokens.start_offset() - init_tokens.start_offset()
  let toks = init_tokens[0:len]
  let block_expr = BlockExpr::{ stmts, toks }
  (block_expr, tokens)
}

///|
test "BlockExpr to_string Test - Empty" {
  let color = false
  let code =
    #|{}
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse empty block
  let (block_expr, _) = parse_block_expr(tokens)
  inspect(block_expr.to_string(color~), content="block (empty)")
}

///|
test "BlockExpr to_string Test - Single Statement" {
  let color = false
  let code =
    #|{ let x = 42 }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse block with single statement
  let (block_expr, _) = parse_block_expr(tokens)
  inspect(
    block_expr.to_string(color~),
    content=(
      #|block
      #|└-let statement
      #|  ├-pattern: ident pattern x
      #|  └-expr: int literal 42
      #|
    ),
  )
}

///|
test "BlockExpr to_string Test - Multiple Statements" {
  let color = false
  let code =
    #|{ let x = 42 ; let mut y = 10 ; x = y + 1 }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse block with multiple statements
  let (block_expr, _) = parse_block_expr(tokens)
  inspect(
    block_expr.to_string(color~),
    content=(
      #|block
      #|├-let statement
      #|│ ├-pattern: ident pattern x
      #|│ └-expr: int literal 42
      #|├-let mut statement
      #|│ ├-name: y
      #|│ └-expr: int literal 10
      #|└-assign statement: =
      #|  ├-lvalue: lvalue x
      #|  └-expr: binary expr: +
      #|          ├-variable y
      #|          └-int literal 1
      #|
    ),
  )
}

///|
test "BlockExpr to_string Test - With Return" {
  let color = false
  let code =
    #|{ let sum = a + b ; return sum ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse block with return statement
  let (block_expr, _) = parse_block_expr(tokens)
  inspect(
    block_expr.to_string(color~),
    content=(
      #|block
      #|├-let statement
      #|│ ├-pattern: ident pattern sum
      #|│ └-expr: binary expr: +
      #|│         ├-variable a
      #|│         └-variable b
      #|└-return statement
      #|  └-variable sum
      #|
    ),
  )
}

///|
test "BlockExpr to_string Test - Complex" {
  let color = false
  let code =
    #|{ let x = 42 ; foo(x) ; return x * 2 ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse block with mixed statement types
  let (block_expr, _) = parse_block_expr(tokens)
  inspect(
    block_expr.to_string(color~),
    content=(
      #|block
      #|├-let statement
      #|│ ├-pattern: ident pattern x
      #|│ └-expr: int literal 42
      #|├-function call
      #|│ ├-variable foo
      #|│ └-variable x
      #|└-return statement
      #|  └-binary expr: *
      #|    ├-variable x
      #|    └-int literal 2
      #|
    ),
  )
}
