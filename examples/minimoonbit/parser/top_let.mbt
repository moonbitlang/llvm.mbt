///|
/// Represents the MiniMoonBit parser AST node `TopLet`.
pub struct TopLet {
  name : String
  ty : Type?
  expr : Expr
} derive(Eq)

///|
/// Formats `TopLet` using MiniMoonBit source notation.
pub impl Show for TopLet with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `TopLet` value with optional ANSI coloring.
pub fn TopLet::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "top let: \{self.name}"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }

  // Format type if present
  let type_str = match self.ty {
    Some(ty) => {
      let ty_text = "type: \{ty.to_string(color~)}"
      "\n" + format_lines([ty_text], head_with="├-", continue_with="│ ")
    }
    None => ""
  }

  // Format expression
  let expr_str = self.expr.to_string(color~)
  let expr_lines = expr_str.split("\n").map(sv => sv.to_owned()).to_array()
  let expr_formatted = format_lines(
    expr_lines,
    head_with="└-expr: ",
    continue_with="        ",
  )
  "\{prefix}\{type_str}\n\{expr_formatted}"
}

///|
/// Parses the `parse_top_let` syntax form and returns the unconsumed token suffix.
pub fn parse_top_let(
  tokens : ArrayView[Token],
) -> (TopLet, ArrayView[Token]) raise ParseError {
  guard tokens is [{ kind: Keyword(Let), .. }, .. tokens] else {
    println("Compiler ICE: Misuse parse_top_let")
    panic()
  }
  guard tokens is [{ kind: Lower(name), .. }, .. tokens] else {
    @lexer.throw_(
      tokens[0],
      "Parse Error: Expect a lower ident after 'let'",
      Error,
    )
    raise ParseError("Expect a lower ident")
  }
  let (ty, tokens) = if tokens is [{ kind: Symbol(":"), .. }, .. tokens] {
    let (ty, rest) = parse_type(tokens)
    (Some(ty), rest)
  } else {
    (None, tokens)
  }
  guard tokens is [{ kind: AssignOp(Assign), .. }, .. tokens] else {
    @lexer.throw_(tokens[0], "Parse Error: Expect '=' after top let", Error)
    let line = tokens[0].line
    let rest = for current = tokens {
      match current {
        [{ kind: Symbol(";"), .. }, .. tokens] => break tokens
        [tok, ..] as tokens if tok.line != line => break tokens
        [{ kind: Bracket('}'), .. }, ..] as tokens => break tokens
        [] as tokens => break tokens
        [_, .. tokens] => continue tokens
      }
    }
    let expr = Expr::unit()
    let top_let = TopLet::{ name, ty, expr, }
    return (top_let, rest)
  }
  let (expr, tokens) = parse_expr(tokens)
  let tokens = if tokens is [{ kind: Symbol(";"), .. }, .. tokens] {
    tokens
  } else if tokens is [tok, ..] &&
    tok.line != expr.toks[expr.toks.length() - 1].line {
    tokens
  } else {
    @lexer.throw_(
      tokens[0],
      "Parse Error: Expect ';' or newline after top let",
      Error,
    )
    tokens
  }
  let top_let = TopLet::{ name, ty, expr, }
  (top_let, tokens)
}

///|
test "TopLet to_string Test - Simple" {
  let color = false
  let code =
    #|let pi = 3.14 ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse simple top let
  let (top_let, _) = parse_top_let(tokens)
  inspect(
    top_let.to_string(color~),
    content=(
      #|top let: pi
      #|└-expr: double literal 3.14
    ),
  )
}

///|
test "TopLet to_string Test - With Type" {
  let color = false
  let code =
    #|let count : Int = 42 ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse top let with type annotation
  let (top_let, _) = parse_top_let(tokens)
  inspect(
    top_let.to_string(color~),
    content=(
      #|top let: count
      #|├-type: Int
      #|└-expr: int literal 42
    ),
  )
}

///|
test "TopLet to_string Test - Complex Expression" {
  let color = false
  let code =
    #|let result = add(1, 2) ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse top let with function call
  let (top_let, _) = parse_top_let(tokens)
  inspect(
    top_let.to_string(color~),
    content=(
      #|top let: result
      #|└-expr: function call
      #|        ├-variable add
      #|        ├-int literal 1
      #|        └-int literal 2
    ),
  )
}
