///|
/// Represents the MiniMoonBit parser AST node `MatchExpr`.
pub struct MatchExpr {
  cond : Expr
  arms : Array[MatchArm]
} derive(Eq)

///|
/// Formats `MatchExpr` using MiniMoonBit source notation.
pub impl Show for MatchExpr with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `MatchExpr` value with optional ANSI coloring.
pub fn MatchExpr::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "match expression"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }

  // Format condition
  let cond_str = self.cond.to_string(color~)
  let cond_lines = cond_str.split("\n").map(sv => sv.to_owned()).to_array()
  let cond_formatted = format_lines(
    cond_lines,
    head_with="├-cond: ",
    continue_with="│       ",
  )
  let mut result = "\{prefix}\n\{cond_formatted}"

  // Format arms
  for i = 0; i < self.arms.length(); i = i + 1 {
    let arm = self.arms[i]
    let arm_str = arm.to_string(color~)
    let arm_lines = arm_str.split("\n").map(sv => sv.to_owned()).to_array()
    let is_last = i == self.arms.length() - 1
    let arm_formatted = if is_last {
      format_lines(arm_lines, head_with="└-", continue_with="  ")
    } else {
      format_lines(arm_lines, head_with="├-", continue_with="│ ")
    }
    result = "\{result}\n\{arm_formatted}"
  }
  result
}

///|
/// Represents the MiniMoonBit parser AST node `MatchArm`.
pub struct MatchArm {
  pattern : Pattern
  match_guard : Expr?
  body : Expr
  toks : ArrayView[Token]
} derive(Eq)

///|
/// Formats `MatchArm` using MiniMoonBit source notation.
pub impl Show for MatchArm with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `MatchArm` value with optional ANSI coloring.
pub fn MatchArm::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "match arm"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }

  // Format pattern
  let pattern_str = self.pattern.to_string(color~)
  let pattern_lines = pattern_str
    .split("\n")
    .map(sv => sv.to_owned())
    .to_array()
  match self.match_guard {
    None => {
      let pattern_formatted = format_lines(
        pattern_lines,
        head_with="├-pattern: ",
        continue_with="│          ",
      )
      let body_str = self.body.to_string(color~)
      let body_lines = body_str.split("\n").map(sv => sv.to_owned()).to_array()
      let body_formatted = format_lines(
        body_lines,
        head_with="└-body: ",
        continue_with="        ",
      )
      "\{prefix}\n\{pattern_formatted}\n\{body_formatted}"
    }
    Some(guard_expr) => {
      let pattern_formatted = format_lines(
        pattern_lines,
        head_with="├-pattern: ",
        continue_with="│          ",
      )
      let guard_str = guard_expr.to_string(color~)
      let guard_lines = guard_str
        .split("\n")
        .map(sv => sv.to_owned())
        .to_array()
      let guard_formatted = format_lines(
        guard_lines,
        head_with="├-guard: ",
        continue_with="│        ",
      )
      let body_str = self.body.to_string(color~)
      let body_lines = body_str.split("\n").map(sv => sv.to_owned()).to_array()
      let body_formatted = format_lines(
        body_lines,
        head_with="└-body: ",
        continue_with="        ",
      )
      "\{prefix}\n\{pattern_formatted}\n\{guard_formatted}\n\{body_formatted}"
    }
  }
}

///|
/// Parses the `parse_match_expr` syntax form and returns the unconsumed token suffix.
pub fn parse_match_expr(
  tokens : ArrayView[Token],
) -> (MatchExpr, ArrayView[Token]) raise ParseError {
  guard tokens is [{ kind: Keyword(Match), .. }, .. tokens] else {
    println(
      "Compiler ICE: Misuse `parse_match_expr`, start token is not `match` keyword",
    )
    panic()
  }
  let (expr, tokens) = parse_expr(tokens)
  guard tokens is [{ kind: Bracket('{'), .. } as tok, .. tokens] else {
    @lexer.throw_(
      tokens[0],
      "Parse Error: Expected `{` after match expression",
      Error,
    )
    raise ParseError("Expected `{` after match expression")
  }
  let match_arms : Array[MatchArm] = Array::new()
  let tokens = for current = tokens {
    match current {
      [{ kind: Bracket('}'), .. }, .. tokens] => break tokens
      [] => {
        @lexer.throw_(
          tok,
          "Parse Error: Expected `}` to close match expression",
          Error,
        )
        raise ParseError("Expected `}` to close match expression")
      }
      tokens => {
        let (arm, rest) = parse_match_arm(tokens)
        match_arms.push(arm)
        continue rest
      }
    }
  }
  let match_expr = MatchExpr::{ cond: expr, arms: match_arms }
  (match_expr, tokens)
}

///|
/// Parses the `parse_match_arm` syntax form and returns the unconsumed token suffix.
pub fn parse_match_arm(
  tokens : ArrayView[Token],
) -> (MatchArm, ArrayView[Token]) raise ParseError {
  let init_tokens = tokens
  let (pattern, tokens) = parse_pattern(tokens)
  let (guard_, tokens) = match tokens {
    [{ kind: Keyword(If), .. }, .. rest] => {
      let (guard_expr, rest) = parse_expr(rest)
      (Some(guard_expr), rest)
    }
    tokens => (None, tokens)
  }
  guard tokens is [{ kind: Symbol("=>"), .. }, .. rest] else {
    @lexer.throw_(tokens[0], "Parse Error: Expected `=>` in match arm", Error)
    raise ParseError("Expected `=>` in match arm")
  }
  let (body_expr, tokens) = parse_expr(rest)
  let toks = init_tokens[0:tokens.start_offset() - init_tokens.start_offset()]
  let match_arm = MatchArm::{
    pattern,
    match_guard: guard_,
    body: body_expr,
    toks,
  }
  let tokens = if tokens is [{ kind: Symbol(";"), .. }, .. tokens] {
    tokens
  } else if tokens is [tok, ..] &&
    tok.line != body_expr.toks[body_expr.toks.length() - 1].line {
    tokens
  } else {
    tokens
  }
  (match_arm, tokens)
}

///|
test "MatchExpr to_string Test - Simple" {
  let color = false
  let code =
    #|match x { 0 => 1 ; 1 => 2 ; _ => 3 }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse simple match
  let (match_expr, _) = parse_match_expr(tokens)
  inspect(
    match_expr.to_string(color~),
    content=(
      #|match expression
      #|├-cond: variable x
      #|├-match arm
      #|│ ├-pattern: int pattern 0
      #|│ └-body: int literal 1
      #|├-match arm
      #|│ ├-pattern: int pattern 1
      #|│ └-body: int literal 2
      #|└-match arm
      #|  ├-pattern: _
      #|  └-body: int literal 3
    ),
  )
}

///|
test "MatchExpr to_string Test - With Guard" {
  let color = false
  let code =
    #|match x { n if n > 0 => 1 ; _ => 0 }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse match with guard
  let (match_expr, _) = parse_match_expr(tokens)
  inspect(
    match_expr.to_string(color~),
    content=(
      #|match expression
      #|├-cond: variable x
      #|├-match arm
      #|│ ├-pattern: ident pattern n
      #|│ ├-guard: binary expr: >
      #|│ │        ├-variable n
      #|│ │        └-int literal 0
      #|│ └-body: int literal 1
      #|└-match arm
      #|  ├-pattern: _
      #|  └-body: int literal 0
    ),
  )
}

///|
test "MatchExpr to_string Test - Tuple Pattern" {
  let color = false
  let code =
    #|match pair { (a, b) => a + b ; (x, y) => x + y }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse match with tuple pattern
  let (match_expr, _) = parse_match_expr(tokens)
  inspect(
    match_expr.to_string(color~),
    content=(
      #|match expression
      #|├-cond: variable pair
      #|├-match arm
      #|│ ├-pattern: tuple pattern
      #|│ │          ├-ident pattern a
      #|│ │          └-ident pattern b
      #|│ └-body: binary expr: +
      #|│         ├-variable a
      #|│         └-variable b
      #|└-match arm
      #|  ├-pattern: tuple pattern
      #|  │          ├-ident pattern x
      #|  │          └-ident pattern y
      #|  └-body: binary expr: +
      #|          ├-variable x
      #|          └-variable y
    ),
  )
}

///|
test "MatchExpr to_string Test - Enum Pattern" {
  let color = false
  let code =
    #|match opt { Some(x) => x ; None => 0 }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse match with enum pattern
  let (match_expr, _) = parse_match_expr(tokens)
  inspect(
    match_expr.to_string(color~),
    content=(
      #|match expression
      #|├-cond: variable opt
      #|├-match arm
      #|│ ├-pattern: enum pattern Some
      #|│ │          └-ident pattern x
      #|│ └-body: variable x
      #|└-match arm
      #|  ├-pattern: enum pattern None
      #|  └-body: int literal 0
    ),
  )
}
