///|
/// Represents the MiniMoonBit parser AST node `Expr`.
pub(all) struct Expr {
  /// Stores the `kind` component of this parser AST node.
  kind : ExprKind
  /// Stores the `toks` component of this parser AST node.
  toks : ArrayView[Token]
} derive(Eq)

///|
/// Formats `Expr` using MiniMoonBit source notation.
pub impl Show for Expr with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `Expr` value with optional ANSI coloring.
pub fn Expr::to_string(self : Self, color? : Bool = true) -> String {
  match self.kind {
    ApplyExpr(apply_expr) => apply_expr.to_string(color~)
    NotExpr(expr) => {
      let prefix = "unary operator !"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      let inner_str = expr.to_string(color~)
      let lines = inner_str.split("\n").map(sv => sv.to_owned()).to_array()
      let formatted = format_lines(lines)
      "\{prefix}\n\{formatted}"
    }
    NegExpr(expr) => {
      let prefix = "unary operator -"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      let inner_str = expr.to_string(color~)
      let lines = inner_str.split("\n").map(sv => sv.to_owned()).to_array()
      let formatted = format_lines(lines)
      "\{prefix}\n\{formatted}"
    }
    BinaryExpr(op, left, right) => {
      let op_str = match op {
        Add => "+"
        Sub => "-"
        Mul => "*"
        Div => "/"
        Mod => "%"
        ShiftLeft => "<<"
        ShiftRight => ">>"
        Eq => "=="
        NE => "!="
        LT => "<"
        GT => ">"
        LE => "<="
        GE => ">="
        And => "&&"
        Or => "||"
        BitAnd => "&"
        BitOr => "|"
      }
      let prefix = "binary expr: \{op_str}"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      let left_str = left.to_string(color~)
      let right_str = right.to_string(color~)
      let left_lines = left_str.split("\n").map(sv => sv.to_owned()).to_array()
      let right_lines = right_str
        .split("\n")
        .map(sv => sv.to_owned())
        .to_array()
      let left_formatted = format_lines(
        left_lines,
        head_with="├-",
        continue_with="│ ",
      )
      let right_formatted = format_lines(
        right_lines,
        head_with="└-",
        continue_with="  ",
      )
      "\{prefix}\n\{left_formatted}\n\{right_formatted}"
    }
    BlockExpr(block_expr) => block_expr.to_string(color~)
    IfExpr(if_expr) => if_expr.to_string(color~)
    MatchExpr(match_expr) => match_expr.to_string(color~)
  }
}

///|
/// Enumerates the parser AST forms represented by `ExprKind`.
pub(all) enum ExprKind {
  /// Represents the `ApplyExpr` parser AST form.
  ApplyExpr(ApplyExpr)
  /// Represents the `BlockExpr` parser AST form.
  BlockExpr(BlockExpr)
  /// Represents the `NotExpr` parser AST form.
  NotExpr(Expr)
  /// Represents the `NegExpr` parser AST form.
  NegExpr(Expr)
  /// Represents the `BinaryExpr` parser AST form.
  BinaryExpr(BinaryOp, Expr, Expr)
  /// Represents the `IfExpr` parser AST form.
  IfExpr(IfExpr)
  /// Represents the `MatchExpr` parser AST form.
  MatchExpr(MatchExpr)
} derive(Eq)

///|
/// Formats `ExprKind` using MiniMoonBit source notation.
pub impl Show for ExprKind with fn output(self, logger) {
  let s = match self {
    ApplyExpr(apply_expr) => apply_expr.to_string()
    NotExpr(expr) => "!\{expr}"
    NegExpr(expr) => "-\{expr}"
    BinaryExpr(op, left, right) => "\{left} \{op} \{right}"
    BlockExpr(_) => "<block>"
    IfExpr(_) => "<if>"
    MatchExpr(_) => "<match>"
  }
  logger.write_string(s)
}

///|
fn Expr::unit() -> Expr {
  let apply_unit = ApplyExpr::unit()
  Expr::{ kind: ApplyExpr(apply_unit), toks: apply_unit.toks, }
}

///|
/// Creates a `Expr` parser AST node.
pub fn Expr::new(
  kind : ExprKind,
  init_tokens : ArrayView[Token],
  rest_tokens : ArrayView[Token],
) -> Expr {
  let len = rest_tokens.start_offset() - init_tokens.start_offset()
  let toks = init_tokens[0:len]
  Expr::{ kind, toks, }
}

///|
/// Creates a binary `Expr` parser AST node.
pub fn Expr::new_binary(
  bop : BinaryOp,
  init_tokens : ArrayView[Token],
  left : Expr,
  right : Expr,
) -> Expr {
  let init_offset = init_tokens.start_offset()
  let lhs_offset = left.toks.start_offset()
  let total_len = left.toks.length() + right.toks.length()
  let lhs_init_offset = lhs_offset - init_offset
  let toks = init_tokens[lhs_init_offset:lhs_init_offset + total_len]
  Expr::{ kind: ExprKind::BinaryExpr(bop, left, right), toks, }
}

///|
/// Enumerates the parser AST forms represented by `BinaryOp`.
pub(all) enum BinaryOp {
  /// Represents the `Add` parser AST form.
  Add // +
  /// Represents the `Sub` parser AST form.
  Sub // -
  /// Represents the `Mul` parser AST form.
  Mul // *
  /// Represents the `Div` parser AST form.
  Div // /
  /// Represents the `Mod` parser AST form.
  Mod // %
  /// Represents the `ShiftLeft` parser AST form.
  ShiftLeft // <<
  /// Represents the `ShiftRight` parser AST form.
  ShiftRight // >>
  /// Represents the `Eq` parser AST form.
  Eq // ==
  /// Represents the `NE` parser AST form.
  NE // !=
  /// Represents the `LT` parser AST form.
  LT // <
  /// Represents the `GT` parser AST form.
  GT // >
  /// Represents the `LE` parser AST form.
  LE // <=
  /// Represents the `GE` parser AST form.
  GE // >=
  /// Represents the `And` parser AST form.
  And // &&
  /// Represents the `Or` parser AST form.
  Or // ||
  /// Represents the `BitAnd` parser AST form.
  BitAnd // &
  /// Represents the `BitOr` parser AST form.
  BitOr // |
} derive(Eq)

///|
/// Formats `BinaryOp` using MiniMoonBit source notation.
pub impl Show for BinaryOp with fn output(self, logger) {
  let s = match self {
    Add => "+"
    Sub => "-"
    Mul => "*"
    Div => "/"
    Mod => "%"
    ShiftLeft => "<<"
    ShiftRight => ">>"
    Eq => "=="
    NE => "!="
    LT => "<"
    GT => ">"
    LE => "<="
    GE => ">="
    And => "&&"
    Or => "||"
    BitAnd => "&"
    BitOr => "|"
  }
  logger.write_string(s)
}

///|
/// Converts a lexer operator to the corresponding parser `BinaryOp`.
pub fn BinaryOp::from_tok_binary_op(tok_bin_op : @lexer.BinaryOp) -> BinaryOp {
  match tok_bin_op {
    Add => Add
    Sub => Sub
    Mul => Mul
    Div => Div
    Mod => Mod
    ShiftLeft => ShiftLeft
    ShiftRight => ShiftRight
    Eq => Eq
    NE => NE
    LT => LT
    GT => GT
    LE => LE
    GE => GE
    And => And
    Or => Or
    BitAnd => BitAnd
    BitOr => BitOr
  }
}

///|
/// Parses the `parse_expr` syntax form and returns the unconsumed token suffix.
pub fn parse_expr(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise ParseError {
  let init_tokens = tokens
  guard tokens is [tok, ..] else {
    println("Compiler ICE: Empty Token ArrayView")
    panic()
  }
  match tok.kind {
    Keyword(If) => {
      let (if_expr, rest) = parse_if_expr(tokens)
      let expr = Expr::new(ExprKind::IfExpr(if_expr), init_tokens, rest)
      return (expr, rest)
    }
    Keyword(Match) => {
      let (match_expr, rest) = parse_match_expr(tokens)
      let expr = Expr::new(ExprKind::MatchExpr(match_expr), init_tokens, rest)
      return (expr, rest)
    }
    Bracket('{') => {
      let (block, rest) = parse_block_expr(tokens)
      let expr = Expr::new(ExprKind::BlockExpr(block), init_tokens, rest)
      return (expr, rest)
    }
    _ => ()
  }
  let op_stack : @deque.Deque[BinaryOp] = @deque.Deque([])
  let expr_stack : @deque.Deque[Expr] = @deque.Deque([])

  // Parse unary expression (Not or Neg) or apply expression
  let (head_expr, tokens) = match tokens {
    [{ kind: Not, .. }, .. rest] as tokens => {
      let init_tokens = rest
      let (apply_expr, rest) = parse_apply_expr(rest)
      let expr = Expr::new(ApplyExpr(apply_expr), init_tokens, rest)
      let not_expr = Expr::new(NotExpr(expr), tokens, rest)
      (not_expr, rest)
    }
    [{ kind: BinaryOp(Sub), .. }, .. rest] as tokens => {
      let init_tokens = rest
      let (apply_expr, rest) = parse_apply_expr(rest)
      let expr = Expr::new(ApplyExpr(apply_expr), init_tokens, rest)
      let neg_expr = Expr::new(ExprKind::NegExpr(expr), tokens, rest)
      (neg_expr, rest)
    }
    tokens => {
      let init_tokens = tokens
      let (apply_expr, tokens) = parse_apply_expr(tokens)
      let expr = Expr::new(ExprKind::ApplyExpr(apply_expr), init_tokens, tokens)
      (expr, tokens)
    }
  }
  expr_stack.push_back(head_expr)
  let mut tokens = tokens
  while tokens is [{ kind: BinaryOp(op), .. }, .. rest] {
    // Parse unary expression or apply expression after binary operator
    let (next_expr, rest) = match rest {
      [{ kind: Not, .. }, .. rest] as tokens => {
        let init_tokens = rest
        let (apply_expr, rest) = parse_apply_expr(rest)
        let expr = Expr::new(ExprKind::ApplyExpr(apply_expr), init_tokens, rest)
        let not_expr = Expr::new(ExprKind::NotExpr(expr), tokens, rest)
        (not_expr, rest)
      }
      [{ kind: BinaryOp(Sub), .. }, .. rest] as tokens => {
        let init_tokens = rest
        let (apply_expr, rest) = parse_apply_expr(rest)
        let expr = Expr::new(ExprKind::ApplyExpr(apply_expr), init_tokens, rest)
        let neg_expr = Expr::new(ExprKind::NegExpr(expr), tokens, rest)
        (neg_expr, rest)
      }
      tokens => {
        let init_tokens = tokens
        let (apply_expr, rest) = parse_apply_expr(rest)
        let expr = Expr::new(ExprKind::ApplyExpr(apply_expr), init_tokens, rest)
        (expr, rest)
      }
    }
    let op = BinaryOp::from_tok_binary_op(op)
    while !op_stack.is_empty() &&
          op.precedence() <= op_stack.back().unwrap().precedence() {
      let right = expr_stack.pop_back().unwrap()
      let left = expr_stack.pop_back().unwrap()
      let bop = op_stack.pop_back().unwrap()
      let new_expr = Expr::new_binary(bop, init_tokens, left, right)
      expr_stack.push_back(new_expr)
    }
    op_stack.push_back(op)
    expr_stack.push_back(next_expr)
    tokens = rest
  }
  while !op_stack.is_empty() {
    let right = expr_stack.pop_back().unwrap()
    let left = expr_stack.pop_back().unwrap()
    let bop = op_stack.pop_back().unwrap()
    let new_expr = Expr::new_binary(bop, init_tokens, left, right)
    expr_stack.push_back(new_expr)
  }
  let expr = expr_stack.pop_back().unwrap()
  (expr, tokens)
}

///|
fn BinaryOp::precedence(self : Self) -> Int {
  match self {
    Or => 1
    And => 2
    Eq | NE => 3
    LT | GT | LE | GE => 4
    BitOr => 5
    BitAnd => 7
    ShiftLeft | ShiftRight => 8
    Add | Sub => 9
    Mul | Div | Mod => 10
  }
}

///|
fn parse_expr_list(
  tokens : ArrayView[Token],
) -> (Array[Expr], ArrayView[Token]) raise ParseError {
  let exprs : Array[Expr] = []
  let tokens = for current = tokens {
    match current {
      [{ kind: Bracket(')'), .. }, ..] as tokens => break tokens
      [{ kind: Symbol(","), .. }, { kind: Bracket(')'), .. }, ..] as tokens =>
        break tokens[1:]
      [{ kind: Symbol(","), .. }, .. tokens] => {
        let (expr, rest) = parse_expr(tokens)
        exprs.push(expr)
        continue rest
      }
      [] => {
        println("Compiler ICE: Empty Token ArrayView")
        panic()
      }
      tokens => {
        let (expr, rest) = parse_expr(tokens)
        exprs.push(expr)
        continue rest
      }
    }
  }
  (exprs, tokens)
}

///|
test "Expr to_string Test - Basic" {
  let color = false
  let code =
    #|42 ; x ; !y ; -z
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `42` (ApplyExpr - Int literal)
  let (expr, rest) = parse_expr(tokens)
  inspect(expr.to_string(color~), content="int literal 42")

  // Skip semicolon and parse `x` (ApplyExpr - Ident)
  let rest = skip_semicolon(rest)
  let (expr, rest) = parse_expr(rest)
  inspect(expr.to_string(color~), content="variable x")

  // Skip semicolon and parse `!y` (NotExpr)
  let rest = skip_semicolon(rest)
  let (expr, rest) = parse_expr(rest)
  inspect(
    expr.to_string(color~),
    content=(
      #|unary operator !
      #|└-variable y
    ),
  )

  // Skip semicolon and parse `-z` (NegExpr)
  let rest = skip_semicolon(rest)
  let (expr, _) = parse_expr(rest)
  inspect(
    expr.to_string(color~),
    content=(
      #|unary operator -
      #|└-variable z
    ),
  )
}

///|
test "Expr to_string Test - Binary" {
  let color = false
  let code =
    #|1 + 2 ; a * b ; x - y ; p / q ; m % n
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `1 + 2` (BinaryExpr Add)
  let (expr, rest) = parse_expr(tokens)
  inspect(
    expr.to_string(color~),
    content=(
      #|binary expr: +
      #|├-int literal 1
      #|└-int literal 2
    ),
  )

  // Skip semicolon and parse `a * b` (BinaryExpr Mul)
  let rest = skip_semicolon(rest)
  let (expr, rest) = parse_expr(rest)
  inspect(
    expr.to_string(color~),
    content=(
      #|binary expr: *
      #|├-variable a
      #|└-variable b
    ),
  )

  // Skip semicolon and parse `x - y` (BinaryExpr Sub)
  let rest = skip_semicolon(rest)
  let (expr, rest) = parse_expr(rest)
  inspect(
    expr.to_string(color~),
    content=(
      #|binary expr: -
      #|├-variable x
      #|└-variable y
    ),
  )

  // Skip semicolon and parse `p / q` (BinaryExpr Div)
  let rest = skip_semicolon(rest)
  let (expr, rest) = parse_expr(rest)
  inspect(
    expr.to_string(color~),
    content=(
      #|binary expr: /
      #|├-variable p
      #|└-variable q
    ),
  )

  // Skip semicolon and parse `m % n` (BinaryExpr Mod)
  let rest = skip_semicolon(rest)
  let (expr, _) = parse_expr(rest)
  inspect(
    expr.to_string(color~),
    content=(
      #|binary expr: %
      #|├-variable m
      #|└-variable n
    ),
  )
}

///|
test "Expr to_string Test - Complex Binary" {
  let color = false
  let code =
    #|1 + 2 * 3 ; a && b || c ; x == y ; p < q ; m >= n
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `1 + 2 * 3` (nested binary expr with precedence)
  let (expr, rest) = parse_expr(tokens)
  inspect(
    expr.to_string(color~),
    content=(
      #|binary expr: +
      #|├-int literal 1
      #|└-binary expr: *
      #|  ├-int literal 2
      #|  └-int literal 3
    ),
  )

  // Skip semicolon and parse `a && b || c` (nested logical)
  let rest = skip_semicolon(rest)
  let (expr, rest) = parse_expr(rest)
  inspect(
    expr.to_string(color~),
    content=(
      #|binary expr: ||
      #|├-binary expr: &&
      #|│ ├-variable a
      #|│ └-variable b
      #|└-variable c
    ),
  )

  // Skip semicolon and parse `x == y` (comparison)
  let rest = skip_semicolon(rest)
  let (expr, rest) = parse_expr(rest)
  inspect(
    expr.to_string(color~),
    content=(
      #|binary expr: ==
      #|├-variable x
      #|└-variable y
    ),
  )

  // Skip semicolon and parse `p < q`
  let rest = skip_semicolon(rest)
  let (expr, rest) = parse_expr(rest)
  inspect(
    expr.to_string(color~),
    content=(
      #|binary expr: <
      #|├-variable p
      #|└-variable q
    ),
  )

  // Skip semicolon and parse `m >= n`
  let rest = skip_semicolon(rest)
  let (expr, _) = parse_expr(rest)
  inspect(
    expr.to_string(color~),
    content=(
      #|binary expr: >=
      #|├-variable m
      #|└-variable n
    ),
  )
}

///|
test "Expr to_string Test - Nested Unary" {
  let color = false
  let code =
    #|!x ; -y ; !(a + b) ; -(x * y)
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `!x` (not)
  let (expr, rest) = parse_expr(tokens)
  inspect(
    expr.to_string(color~),
    content=(
      #|unary operator !
      #|└-variable x
    ),
  )

  // Skip semicolon and parse `-y` (neg)
  let rest = skip_semicolon(rest)
  let (expr, rest) = parse_expr(rest)
  inspect(
    expr.to_string(color~),
    content=(
      #|unary operator -
      #|└-variable y
    ),
  )

  // Skip semicolon and parse `!(a + b)` (not with binary)
  let rest = skip_semicolon(rest)
  let (expr, rest) = parse_expr(rest)
  inspect(
    expr.to_string(color~),
    content=(
      #|unary operator !
      #|└-binary expr: +
      #|  ├-variable a
      #|  └-variable b
    ),
  )

  // Skip semicolon and parse `-(x * y)` (neg with binary)
  let rest = skip_semicolon(rest)
  let (expr, _) = parse_expr(rest)
  inspect(
    expr.to_string(color~),
    content=(
      #|unary operator -
      #|└-binary expr: *
      #|  ├-variable x
      #|  └-variable y
    ),
  )
}

///|
test "Expr to_string Test - Block" {
  let color = false
  let code =
    #|{ let x = 42 ; x + 1 } ; { return 10 ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `{ let x = 42 ; x + 1 }`
  let (expr, rest) = parse_expr(tokens)
  inspect(
    expr.to_string(color~),
    content=(
      #|block
      #|├-let statement
      #|│ ├-pattern: ident pattern x
      #|│ └-expr: int literal 42
      #|└-binary expr: +
      #|  ├-variable x
      #|  └-int literal 1
      #|
    ),
  )

  // Skip semicolon and parse `{ return 10 ; }`
  let rest = skip_semicolon(rest)
  let (expr, _) = parse_expr(rest)
  inspect(
    expr.to_string(color~),
    content=(
      #|block
      #|└-return statement
      #|  └-int literal 10
      #|
    ),
  )
}

///|
test "Expr to_string Test - If" {
  let color = false
  let code =
    #|if x { return 1 ; } ; if x > 0 { return 1 ; } else { return 0 ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `if x { return 1 ; }`
  let (expr, rest) = parse_expr(tokens)
  inspect(
    expr.to_string(color~),
    content=(
      #|if expression
      #|├-cond: variable x
      #|└-then: block
      #|        └-return statement
      #|          └-int literal 1
      #|        
    ),
  )

  // Skip semicolon and parse `if x > 0 { return 1 ; } else { return 0 ; }`
  let rest = skip_semicolon(rest)
  let (expr, _) = parse_expr(rest)
  inspect(
    expr.to_string(color~),
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
test "Expr to_string Test - Match" {
  let color = false
  let code =
    #|match x { 0 => 1 ; _ => 2 } ; match opt { Some(n) => n ; None => 0 }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `match x { 0 => 1 ; _ => 2 }`
  let (expr, rest) = parse_expr(tokens)
  inspect(
    expr.to_string(color~),
    content=(
      #|match expression
      #|├-cond: variable x
      #|├-match arm
      #|│ ├-pattern: int pattern 0
      #|│ └-body: int literal 1
      #|└-match arm
      #|  ├-pattern: _
      #|  └-body: int literal 2
    ),
  )

  // Skip semicolon and parse `match opt { Some(n) => n ; None => 0 }`
  let rest = skip_semicolon(rest)
  let (expr, _) = parse_expr(rest)
  inspect(
    expr.to_string(color~),
    content=(
      #|match expression
      #|├-cond: variable opt
      #|├-match arm
      #|│ ├-pattern: enum pattern Some
      #|│ │          └-ident pattern n
      #|│ └-body: variable n
      #|└-match arm
      #|  ├-pattern: enum pattern None
      #|  └-body: int literal 0
    ),
  )
}
