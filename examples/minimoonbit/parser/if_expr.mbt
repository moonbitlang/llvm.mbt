///|
/// Represents the MiniMoonBit parser AST node `IfExpr`.
pub(all) struct IfExpr {
  /// Stores the `cond` component of this parser AST node.
  cond : Expr
  /// Stores the `then_block` component of this parser AST node.
  then_block : BlockExpr
  /// Stores the `else_block` component of this parser AST node.
  else_block : Either[IfExpr, BlockExpr]?
  /// Stores the `toks` component of this parser AST node.
  toks : ArrayView[Token]
} derive(Eq)

///|
/// Formats `IfExpr` using MiniMoonBit source notation.
pub impl Show for IfExpr with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `IfExpr` value with optional ANSI coloring.
pub fn IfExpr::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "if expression"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }

  // Format condition
  let cond_str = self.cond.to_string(color~)
  let cond_lines = cond_str.split("\n").map(sv => sv.to_owned()).to_array()
  let cond_formatted = format_lines(
    cond_lines,
    head_with="├-cond: ",
    continue_with="│       ",
  )

  // Format then block
  let then_str = self.then_block.to_string(color~)
  let then_lines = then_str.split("\n").map(sv => sv.to_owned()).to_array()
  match self.else_block {
    None => {
      let then_formatted = format_lines(
        then_lines,
        head_with="└-then: ",
        continue_with="        ",
      )
      "\{prefix}\n\{cond_formatted}\n\{then_formatted}"
    }
    Some(Either::Left(else_if)) => {
      let then_formatted = format_lines(
        then_lines,
        head_with="├-then: ",
        continue_with="│       ",
      )
      let else_if_str = else_if.to_string(color~)
      let else_if_lines = else_if_str
        .split("\n")
        .map(sv => sv.to_owned())
        .to_array()
      let else_if_formatted = format_lines(
        else_if_lines,
        head_with="└-else: ",
        continue_with="        ",
      )
      "\{prefix}\n\{cond_formatted}\n\{then_formatted}\n\{else_if_formatted}"
    }
    Some(Either::Right(else_block)) => {
      let then_formatted = format_lines(
        then_lines,
        head_with="├-then: ",
        continue_with="│       ",
      )
      let else_str = else_block.to_string(color~)
      let else_lines = else_str.split("\n").map(sv => sv.to_owned()).to_array()
      let else_formatted = format_lines(
        else_lines,
        head_with="└-else: ",
        continue_with="        ",
      )
      "\{prefix}\n\{cond_formatted}\n\{then_formatted}\n\{else_formatted}"
    }
  }
}

///|
/// Parses the `parse_if_expr` syntax form and returns the unconsumed token suffix.
pub fn parse_if_expr(
  tokens : ArrayView[Token],
) -> (IfExpr, ArrayView[Token]) raise ParseError {
  let init_tokens = tokens
  guard tokens is [{ kind: Keyword(If), .. }, .. tokens] else {
    println("Compiler ICE: Misuse parse_if_expr")
    panic()
  }
  let (cond, tokens) = parse_expr(tokens)
  let (then_block, tokens) = parse_block_expr(tokens)
  let (else_block, tokens) = if tokens
    is [{ kind: Keyword(Else), .. }, .. tokens] {
    if tokens is [{ kind: Keyword(If), .. }, ..] {
      let (else_if, tokens) = parse_if_expr(tokens)
      (Some(Either::Left(else_if)), tokens)
    } else {
      guard tokens is [{ kind: Bracket('{'), .. }, ..] else {
        @lexer.throw_(tokens[0], "Parse Error: Expect '{' after else", Error)
        raise ParseError("Expect '{' after else")
      }
      let (else_block, tokens) = parse_block_expr(tokens)
      (Some(Either::Right(else_block)), tokens)
    }
  } else {
    (None, tokens)
  }
  let len = tokens.start_offset() - init_tokens.start_offset()
  let toks = init_tokens[0:len]
  let if_expr = IfExpr::{ cond, then_block, else_block, toks, }
  (if_expr, tokens)
}

///|
test "IfExpr to_string Test - Simple" {
  let color = false
  let code =
    #|if x { return 1 ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse simple if without else
  let (if_expr, _) = parse_if_expr(tokens)
  inspect(
    if_expr.to_string(color~),
    content=(
      #|if expression
      #|├-cond: variable x
      #|└-then: block
      #|        └-return statement
      #|          └-int literal 1
      #|        
    ),
  )
}

///|
test "IfExpr to_string Test - With Else" {
  let color = false
  let code =
    #|if x > 0 { return 1 ; } else { return 0 ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse if-else
  let (if_expr, _) = parse_if_expr(tokens)
  inspect(
    if_expr.to_string(color~),
    content=(
      #|if expression
      #|├-cond: binary expr: >
      #|│       ├-variable x
      #|│       └-int literal 0
      #|├-then: block
      #|│       └-return statement
      #|│         └-int literal 1
      #|│       
      #|└-else: block
      #|        └-return statement
      #|          └-int literal 0
      #|        
    ),
  )
}

///|
test "IfExpr to_string Test - Else If" {
  let color = false
  let code =
    #|if x > 0 { return 1 ; } else if x < 0 { return 2 ; } else { return 0 ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse if-else-if-else
  let (if_expr, _) = parse_if_expr(tokens)
  inspect(
    if_expr.to_string(color~),
    content=(
      #|if expression
      #|├-cond: binary expr: >
      #|│       ├-variable x
      #|│       └-int literal 0
      #|├-then: block
      #|│       └-return statement
      #|│         └-int literal 1
      #|│       
      #|└-else: if expression
      #|        ├-cond: binary expr: <
      #|        │       ├-variable x
      #|        │       └-int literal 0
      #|        ├-then: block
      #|        │       └-return statement
      #|        │         └-int literal 2
      #|        │       
      #|        └-else: block
      #|                └-return statement
      #|                  └-int literal 0
      #|                
    ),
  )
}

///|
test "IfExpr to_string Test - Complex Condition" {
  let color = false
  let code =
    #|if a && b || c { let x = 42 ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse if with complex condition
  let (if_expr, _) = parse_if_expr(tokens)
  inspect(
    if_expr.to_string(color~),
    content=(
      #|if expression
      #|├-cond: binary expr: ||
      #|│       ├-binary expr: &&
      #|│       │ ├-variable a
      #|│       │ └-variable b
      #|│       └-variable c
      #|└-then: block
      #|        └-let statement
      #|          ├-pattern: ident pattern x
      #|          └-expr: int literal 42
      #|        
    ),
  )
}
