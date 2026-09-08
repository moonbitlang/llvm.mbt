///|
///
/// Ast - For Statement
///
/// ```mbt nocheck
/// let code =
///   #|for i = 0; i < 10; i += 1 {
///   #|  println(i);
///   #|}
///
/// let toks = @lexer.tokenize(code)
///
/// let (for_stmt, _) = parse_for_stmt(toks)
/// assert_true(for_stmt.inits.length() is 1)
/// assert_true(
///   for_stmt.inits[0] is ("i", {kind: ApplyExpr(a), ..}) &&
///   a is {kind: AtomExpr(a), ..} &&
///   a is {kind: Int(0), ..}
/// )
/// assert_true(
///   for_stmt.cond is Some({kind: BinaryExpr(LT, left, right), ..}) &&
///   left is {kind: ApplyExpr(a1), ..} &&
///   right is {kind: ApplyExpr(a2), ..} &&
///   a1 is {kind: AtomExpr(a1), ..} &&
///   a1 is {kind: Ident("i"), ..} &&
///   a2 is {kind: AtomExpr(a2), ..} &&
///   a2 is {kind: Int(10), ..}
/// )
/// assert_true(for_stmt.steps.length() is 1)
/// assert_true(
///   for_stmt.steps[0] is ("i", PlusAssign, {kind: ApplyExpr(a), ..}) &&
///   a is {kind: AtomExpr(a), ..} &&
///   a is {kind: Int(1), ..}
/// )
/// ```
pub struct ForStmt {
  inits : Array[(String, Expr)]
  cond : Expr?
  steps : Array[(String, AssignOp, Expr)]
  body : BlockExpr
} derive(Eq)

///|
/// Formats `ForStmt` using MiniMoonBit source notation.
pub impl Show for ForStmt with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `ForStmt` value with optional ANSI coloring.
pub fn ForStmt::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "for statement"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
  let mut result = prefix

  // Format inits
  if self.inits.length() > 0 {
    let inits_prefix = "inits:"
    let inits_prefix = if color {
      @color.taint(inits_prefix, Blue)
    } else {
      inits_prefix
    }
    result = "\{result}\n├-\{inits_prefix}"
    for i = 0; i < self.inits.length(); i = i + 1 {
      let (name, expr) = self.inits[i]
      let expr_str = expr.to_string(color~)
      let expr_lines = expr_str.split("\n").map(sv => sv.to_owned()).to_array()
      let is_last_init = i == self.inits.length() - 1
      let expr_formatted = if is_last_init {
        format_lines(expr_lines, head_with="└-\{name} = ", continue_with="  ")
      } else {
        format_lines(
          expr_lines,
          head_with="├-\{name} = ",
          continue_with="│ ",
        )
      }
      result = "\{result}\n│ \{expr_formatted}"
    }
  }

  // Format condition
  match self.cond {
    Some(cond_expr) => {
      let cond_str = cond_expr.to_string(color~)
      let cond_lines = cond_str.split("\n").map(sv => sv.to_owned()).to_array()
      let cond_formatted = format_lines(
        cond_lines,
        head_with="├-cond: ",
        continue_with="│       ",
      )
      result = "\{result}\n\{cond_formatted}"
    }
    None => ()
  }

  // Format steps
  if self.steps.length() > 0 {
    let steps_prefix = "steps:"
    let steps_prefix = if color {
      @color.taint(steps_prefix, Blue)
    } else {
      steps_prefix
    }
    result = "\{result}\n├-\{steps_prefix}"
    for i = 0; i < self.steps.length(); i = i + 1 {
      let (name, op, expr) = self.steps[i]
      let op_str = match op {
        Assign => "="
        PlusAssign => "+="
        MinusAssign => "-="
        MultAssign => "*="
        DivAssign => "/="
        ModAssign => "%="
      }
      let expr_str = expr.to_string(color~)
      let expr_lines = expr_str.split("\n").map(sv => sv.to_owned()).to_array()
      let is_last_step = i == self.steps.length() - 1
      let expr_formatted = if is_last_step {
        format_lines(
          expr_lines,
          head_with="└-\{name} \{op_str} ",
          continue_with="  ",
        )
      } else {
        format_lines(
          expr_lines,
          head_with="├-\{name} \{op_str} ",
          continue_with="│ ",
        )
      }
      result = "\{result}\n│ \{expr_formatted}"
    }
  }

  // Format body
  let body_str = self.body.to_string(color~)
  let body_lines = body_str.split("\n").map(sv => sv.to_owned()).to_array()
  let body_formatted = format_lines(
    body_lines,
    head_with="└-body: ",
    continue_with="        ",
  )
  result = "\{result}\n\{body_formatted}"
  result
}

///|
/// Parses the `parse_for_stmt` syntax form and returns the unconsumed token suffix.
pub fn parse_for_stmt(
  tokens : ArrayView[Token],
) -> (ForStmt, ArrayView[Token]) raise ParseError {
  guard tokens is [{ kind: Keyword(For), .. }, .. tokens] else {
    println("Compiler ICE: Misuse parse_for_stmt")
    panic()
  }
  let inits : Array[(String, Expr)] = []
  let tokens = for current = tokens {
    match current {
      [{ kind: Lower(name), .. }, { kind: AssignOp(Assign), .. }, .. tokens] => {
        let (expr, rest) = parse_expr(tokens)
        inits.push((name, expr))
        continue rest
      }
      [
        { kind: Symbol(","), .. },
        { kind: Lower(name), .. },
        { kind: AssignOp(Assign), .. },
        .. tokens,
      ] => {
        let (expr, rest) = parse_expr(tokens)
        inits.push((name, expr))
        continue rest
      }
      [{ kind: Symbol(";"), .. }, .. tokens] => break tokens
      [] => {
        println("Compiler ICE: Incomplete for statement")
        panic()
      }
      [tok, ..] => {
        @lexer.throw_(
          tok,
          "Parse Error: Invalid init statement in for loop",
          Error,
        )
        raise ParseError("Invalid init statement in for loop")
      }
    }
  }
  let (cond, tokens) = if tokens is [{ kind: Symbol(";"), .. }, .. tokens] {
    (None, tokens[1:])
  } else {
    let (expr, tokens) = parse_expr(tokens)
    guard tokens is [{ kind: Symbol(";"), .. }, .. tokens] else {
      @lexer.throw_(
        tokens[0],
        "Parse Error: Failed Parsing For Stmt, Expect ';'",
        Error,
      )
      raise ParseError("Failed Parsing For Stmt, Expect ';'")
    }
    (Some(expr), tokens)
  }
  let steps : Array[(String, AssignOp, Expr)] = []
  let tokens = for current = tokens {
    match current {
      [{ kind: Lower(name), .. }, { kind: AssignOp(op), .. }, .. tokens] => {
        let (expr, rest) = parse_expr(tokens)
        let op = AssignOp::from_tok_assign_op(op)
        steps.push((name, op, expr))
        continue rest
      }
      [
        { kind: Symbol(","), .. },
        { kind: Lower(name), .. },
        { kind: AssignOp(op), .. },
        .. tokens,
      ] => {
        let (expr, rest) = parse_expr(tokens)
        let op = AssignOp::from_tok_assign_op(op)
        steps.push((name, op, expr))
        continue rest
      }
      [{ kind: Bracket('{'), .. }, ..] as tokens => break tokens
      [] => {
        println("Compiler ICE: Incomplete for statement")
        panic()
      }
      [tok, ..] => {
        @lexer.throw_(
          tok,
          "Parse Error: Invalid step statement in for loop",
          Error,
        )
        raise ParseError("Invalid step statement in for loop")
      }
    }
  }
  let (body, tokens) = parse_block_expr(tokens)
  let for_stmt = ForStmt::{ inits, cond, steps, body, }
  (for_stmt, tokens)
}

///|
test "ForStmt to_string Test - Simple" {
  let color = false
  let code =
    #|for i = 0; i < 10; i += 1 { let x = i ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse simple for loop
  let (for_stmt, _) = parse_for_stmt(tokens)
  inspect(
    for_stmt.to_string(color~),
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
test "ForStmt to_string Test - Multiple Inits and Steps" {
  let color = false
  let code =
    #|for i = 0, j = 10; i < j; i += 1, j -= 1 { let sum = i + j ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse for loop with multiple inits and steps
  let (for_stmt, _) = parse_for_stmt(tokens)
  inspect(
    for_stmt.to_string(color~),
    content=(
      #|for statement
      #|├-inits:
      #|│ ├-i = int literal 0
      #|│ └-j = int literal 10
      #|├-cond: binary expr: <
      #|│       ├-variable i
      #|│       └-variable j
      #|├-steps:
      #|│ ├-i += int literal 1
      #|│ └-j -= int literal 1
      #|└-body: block
      #|        └-let statement
      #|          ├-pattern: ident pattern sum
      #|          └-expr: binary expr: +
      #|                  ├-variable i
      #|                  └-variable j
      #|        
    ),
  )
}

///|
test "ForStmt to_string Test - Different Operators" {
  let color = false
  let code =
    #|for i = 10; i > 0; i -= 1 { let x = i ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse for loop with different operators
  let (for_stmt, _) = parse_for_stmt(tokens)
  inspect(
    for_stmt.to_string(color~),
    content=(
      #|for statement
      #|├-inits:
      #|│ └-i = int literal 10
      #|├-cond: binary expr: >
      #|│       ├-variable i
      #|│       └-int literal 0
      #|├-steps:
      #|│ └-i -= int literal 1
      #|└-body: block
      #|        └-let statement
      #|          ├-pattern: ident pattern x
      #|          └-expr: variable i
      #|        
    ),
  )
}

///|
test "ForStmt to_string Test - Complex Body" {
  let color = false
  let code =
    #|for i = 0; i < 5; i += 1 { let mut x = i ; x = x * 2 ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse for loop with complex body
  let (for_stmt, _) = parse_for_stmt(tokens)
  inspect(
    for_stmt.to_string(color~),
    content=(
      #|for statement
      #|├-inits:
      #|│ └-i = int literal 0
      #|├-cond: binary expr: <
      #|│       ├-variable i
      #|│       └-int literal 5
      #|├-steps:
      #|│ └-i += int literal 1
      #|└-body: block
      #|        ├-let mut statement
      #|        │ ├-name: x
      #|        │ └-expr: variable i
      #|        └-assign statement: =
      #|          ├-lvalue: lvalue x
      #|          └-expr: binary expr: *
      #|                  ├-variable x
      #|                  └-int literal 2
      #|        
    ),
  )
}
