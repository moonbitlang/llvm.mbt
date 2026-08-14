///|
/// Parses source with one explicit binary-operator table.
///
/// A parser is reusable and has no cursor or process-global mutable state.
/// Each `parseTopLevel` call tokenizes and parses a fresh source buffer.
///
/// **Construction:** Use `Parser::new` with the operator table owned by the
/// surrounding language session.
pub struct Parser {
  operators : OperatorTable
}

///|
/// Creates a reusable parser backed by an explicit operator table.
///
/// **Parameters:**
///
/// - `operators`: Precedence configuration used for every binary expression.
pub fn Parser::new(operators~ : OperatorTable) -> Parser {
  Parser::{ operators, }
}

///|
fn unexpected_token(token : @lexer.Token, expected : String) -> ParseError {
  match token.kind {
    @lexer.Eof => UnexpectedEndOfInput(token.start, expected)
    _ => UnexpectedToken(token, expected)
  }
}

///|
fn parse_prototype(
  tokens : ArrayView[@lexer.Token],
) -> (@ast.Prototype, ArrayView[@lexer.Token]) raise ParseError {
  let (name, kind, name_token, tokens) = match tokens {
    [{ kind: @lexer.Identifier(name), .. } as token, .. rest] =>
      (name, @ast.Normal, token, rest)
    [{ kind: @lexer.Unary, .. } as keyword, .. rest] =>
      match rest {
        [{ kind: @lexer.Operator(operator), .. } as token, .. rest] => {
          guard operator != '=' else {
            raise InvalidOperatorPrototype(
              token.start,
              "`=` is reserved for assignment",
            )
          }
          ("unary\{operator}", @ast.Unary(operator), token, rest)
        }
        [token, ..] => raise unexpected_token(token, "operator after `unary`")
        [] => raise UnexpectedEndOfInput(keyword.end, "operator after `unary`")
      }
    [{ kind: @lexer.Binary, .. } as keyword, .. rest] => {
      let (operator, operator_token, rest) = match rest {
        [{ kind: @lexer.Operator(operator), .. } as token, .. rest] =>
          (operator, token, rest)
        [token, ..] => raise unexpected_token(token, "operator after `binary`")
        [] => raise UnexpectedEndOfInput(keyword.end, "operator after `binary`")
      }
      guard operator != '=' else {
        raise InvalidOperatorPrototype(
          operator_token.start,
          "`=` is reserved for assignment",
        )
      }
      guard !['<', '+', '-', '*'].contains(operator) else {
        raise InvalidOperatorPrototype(
          operator_token.start,
          "built-in binary operator `\{operator}` cannot be redefined",
        )
      }
      let (precedence, rest) = match rest {
        [{ kind: @lexer.Number(value), .. } as token, .. rest] => {
          guard value >= 1.0 && value <= 100.0 else {
            raise InvalidOperatorPrototype(
              token.start,
              "binary precedence must be between 1 and 100",
            )
          }
          let precedence = value.to_int()
          guard precedence.to_double() == value else {
            raise InvalidOperatorPrototype(
              token.start,
              "binary precedence must be an integer",
            )
          }
          (precedence, rest)
        }
        _ => (30, rest)
      }
      (
        "binary\{operator}",
        @ast.Binary(operator, precedence),
        operator_token,
        rest,
      )
    }
    [token, ..] => raise unexpected_token(token, "function name or operator")
    [] =>
      raise UnexpectedEndOfInput(
        { offset: 0, line: 1, column: 1 },
        "function name or operator",
      )
  }
  guard tokens is [{ kind: @lexer.LeftParen, .. }, .. tokens] else {
    match tokens {
      [token, ..] => raise unexpected_token(token, "`(` after function name")
      [] =>
        raise UnexpectedEndOfInput(name_token.end, "`(` after function name")
    }
  }
  let parameters : Array[String] = []
  let tokens = for tokens = tokens {
    match tokens {
      [{ kind: @lexer.RightParen, .. }, .. rest] => break rest
      [{ kind: @lexer.Identifier(parameter), start, .. }, .. rest] => {
        guard !parameters.contains(parameter) else {
          raise DuplicateParameter(parameter, start)
        }
        parameters.push(parameter)
        continue rest
      }
      [token, ..] => raise unexpected_token(token, "parameter name or `)`")
      [] => raise UnexpectedEndOfInput(name_token.end, "`)` after parameters")
    }
  }
  match kind {
    @ast.Normal => ()
    @ast.Unary(_) if parameters.length() != 1 =>
      raise InvalidOperatorPrototype(
        name_token.start,
        "unary operator must have exactly one parameter",
      )
    @ast.Binary(_, _) if parameters.length() != 2 =>
      raise InvalidOperatorPrototype(
        name_token.start,
        "binary operator must have exactly two parameters",
      )
    _ => ()
  }
  (@ast.Prototype::{ name, parameters, kind }, tokens)
}

///|
fn parse_parenthesized(
  parser : Parser,
  open : @lexer.Token,
  tokens : ArrayView[@lexer.Token],
) -> (@ast.Expr, ArrayView[@lexer.Token]) raise ParseError {
  let (expression, tokens) = parse_expression(parser, tokens)
  match tokens {
    [{ kind: @lexer.RightParen, .. }, .. rest] => (expression, rest)
    [token, ..] => raise unexpected_token(token, "`)` after expression")
    [] => raise UnexpectedEndOfInput(open.end, "`)` after expression")
  }
}

///|
fn parse_call_arguments(
  parser : Parser,
  open : @lexer.Token,
  tokens : ArrayView[@lexer.Token],
) -> (Array[@ast.Expr], ArrayView[@lexer.Token]) raise ParseError {
  if tokens is [{ kind: @lexer.RightParen, .. }, .. rest] {
    return ([], rest)
  }
  let arguments : Array[@ast.Expr] = []
  for tokens = tokens {
    let (argument, tokens) = parse_expression(parser, tokens)
    arguments.push(argument)
    match tokens {
      [{ kind: @lexer.RightParen, .. }, .. rest] => break (arguments, rest)
      [{ kind: @lexer.Comma, .. }, { kind: @lexer.RightParen, .. } as close, ..] =>
        raise UnexpectedToken(close, "expression after `,`")
      [{ kind: @lexer.Comma, .. }, .. rest] => continue rest
      [token, ..] => raise unexpected_token(token, "`,` or `)` after argument")
      [] => raise UnexpectedEndOfInput(open.end, "`)` after arguments")
    }
  }
}

///|
fn parse_identifier(
  parser : Parser,
  name : String,
  tokens : ArrayView[@lexer.Token],
) -> (@ast.Expr, ArrayView[@lexer.Token]) raise ParseError {
  match tokens {
    [{ kind: @lexer.LeftParen, .. } as open, .. rest] => {
      let (arguments, rest) = parse_call_arguments(parser, open, rest)
      (@ast.Call(name, arguments), rest)
    }
    _ => (@ast.Variable(name), tokens)
  }
}

///|
fn parse_if(
  parser : Parser,
  keyword : @lexer.Token,
  tokens : ArrayView[@lexer.Token],
) -> (@ast.Expr, ArrayView[@lexer.Token]) raise ParseError {
  let (condition, tokens) = parse_expression(parser, tokens)
  let tokens = match tokens {
    [{ kind: @lexer.Then, .. }, .. rest] => rest
    [token, ..] => raise unexpected_token(token, "`then` after condition")
    [] => raise UnexpectedEndOfInput(keyword.end, "`then` after condition")
  }
  let (then_expression, tokens) = parse_expression(parser, tokens)
  let tokens = match tokens {
    [{ kind: @lexer.Else, .. }, .. rest] => rest
    [token, ..] => raise unexpected_token(token, "`else` after then expression")
    [] =>
      raise UnexpectedEndOfInput(keyword.end, "`else` after then expression")
  }
  let (else_expression, tokens) = parse_expression(parser, tokens)
  (@ast.If(condition, then_expression, else_expression), tokens)
}

///|
fn parse_for(
  parser : Parser,
  keyword : @lexer.Token,
  tokens : ArrayView[@lexer.Token],
) -> (@ast.Expr, ArrayView[@lexer.Token]) raise ParseError {
  guard tokens is [{ kind: @lexer.Identifier(variable), .. }, .. tokens] else {
    match tokens {
      [token, ..] => raise unexpected_token(token, "loop variable after `for`")
      [] => raise UnexpectedEndOfInput(keyword.end, "loop variable after `for`")
    }
  }
  guard tokens is [{ kind: @lexer.Operator('='), .. }, .. tokens] else {
    match tokens {
      [token, ..] => raise unexpected_token(token, "`=` after loop variable")
      [] => raise UnexpectedEndOfInput(keyword.end, "`=` after loop variable")
    }
  }
  let (start, tokens) = parse_expression(parser, tokens)
  guard tokens is [{ kind: @lexer.Comma, .. }, .. tokens] else {
    match tokens {
      [token, ..] => raise unexpected_token(token, "`,` after loop start")
      [] => raise UnexpectedEndOfInput(keyword.end, "`,` after loop start")
    }
  }
  let (end, tokens) = parse_expression(parser, tokens)
  let (step, tokens) = match tokens {
    [{ kind: @lexer.Comma, .. }, .. rest] => {
      let (step, rest) = parse_expression(parser, rest)
      (Some(step), rest)
    }
    _ => (None, tokens)
  }
  let tokens = match tokens {
    [{ kind: @lexer.In, .. }, .. rest] => rest
    [token, ..] => raise unexpected_token(token, "`in` before loop body")
    [] => raise UnexpectedEndOfInput(keyword.end, "`in` before loop body")
  }
  let (body, tokens) = parse_expression(parser, tokens)
  (@ast.For(variable, start, end, step, body), tokens)
}

///|
fn parse_var(
  parser : Parser,
  keyword : @lexer.Token,
  tokens : ArrayView[@lexer.Token],
) -> (@ast.Expr, ArrayView[@lexer.Token]) raise ParseError {
  let bindings : Array[@ast.VarBinding] = []
  let names : Map[String, Bool] = Map([])
  for tokens = tokens {
    guard tokens is [{ kind: @lexer.Identifier(name), start, .. }, .. tokens] else {
      match tokens {
        [token, ..] =>
          raise unexpected_token(token, "variable name after `var`")
        [] =>
          raise UnexpectedEndOfInput(keyword.end, "variable name after `var`")
      }
    }
    guard names.get(name) is None else { raise DuplicateBinding(name, start) }
    names.set(name, true)
    let (initializer, tokens) = match tokens {
      [{ kind: @lexer.Operator('='), .. }, .. rest] => {
        let (initializer, rest) = parse_expression(parser, rest)
        (Some(initializer), rest)
      }
      _ => (None, tokens)
    }
    bindings.push({ name, initializer })
    match tokens {
      [{ kind: @lexer.Comma, .. }, .. rest] => continue rest
      [{ kind: @lexer.In, .. }, .. rest] => {
        let (body, rest) = parse_expression(parser, rest)
        break (@ast.Var(bindings, body), rest)
      }
      [token, ..] =>
        raise unexpected_token(token, "`,` or `in` after variable binding")
      [] =>
        raise UnexpectedEndOfInput(keyword.end, "`in` after variable bindings")
    }
  }
}

///|
fn parse_primary(
  parser : Parser,
  tokens : ArrayView[@lexer.Token],
) -> (@ast.Expr, ArrayView[@lexer.Token]) raise ParseError {
  match tokens {
    [{ kind: @lexer.Number(value), .. }, .. rest] => (@ast.Number(value), rest)
    [{ kind: @lexer.Identifier(name), .. }, .. rest] =>
      parse_identifier(parser, name, rest)
    [{ kind: @lexer.LeftParen, .. } as open, .. rest] =>
      parse_parenthesized(parser, open, rest)
    [{ kind: @lexer.If, .. } as keyword, .. rest] =>
      parse_if(parser, keyword, rest)
    [{ kind: @lexer.For, .. } as keyword, .. rest] =>
      parse_for(parser, keyword, rest)
    [{ kind: @lexer.Var, .. } as keyword, .. rest] =>
      parse_var(parser, keyword, rest)
    [token, ..] => raise unexpected_token(token, "expression")
    [] =>
      raise UnexpectedEndOfInput(
        { offset: 0, line: 1, column: 1 },
        "expression",
      )
  }
}

///|
fn parse_binary_rhs(
  parser : Parser,
  minimum_precedence : Int,
  initial_left : @ast.Expr,
  initial_tokens : ArrayView[@lexer.Token],
) -> (@ast.Expr, ArrayView[@lexer.Token]) raise ParseError {
  for left = initial_left, tokens = initial_tokens {
    match tokens {
      [{ kind: @lexer.Operator(operator), .. }, .. rest] => {
        guard parser.operators.getPrecedence(operator) is Some(precedence) &&
          precedence >= minimum_precedence else {
          break (left, tokens)
        }
        let (right, rest) = parse_unary(parser, rest)
        let next_precedence = match rest {
          [{ kind: @lexer.Operator(next_operator), .. }, ..] =>
            parser.operators.getPrecedence(next_operator)
          _ => None
        }
        let (right, rest) = if next_precedence is Some(next) &&
          next > precedence {
          parse_binary_rhs(parser, precedence + 1, right, rest)
        } else {
          (right, rest)
        }
        continue @ast.Binary(operator, left, right), rest
      }
      _ => break (left, tokens)
    }
  }
}

///|
fn parse_unary(
  parser : Parser,
  tokens : ArrayView[@lexer.Token],
) -> (@ast.Expr, ArrayView[@lexer.Token]) raise ParseError {
  match tokens {
    [{ kind: @lexer.Operator(operator), .. }, .. rest] => {
      let (operand, rest) = parse_unary(parser, rest)
      (@ast.Unary(operator, operand), rest)
    }
    _ => parse_primary(parser, tokens)
  }
}

///|
fn parse_expression(
  parser : Parser,
  tokens : ArrayView[@lexer.Token],
) -> (@ast.Expr, ArrayView[@lexer.Token]) raise ParseError {
  let (left, tokens) = parse_unary(parser, tokens)
  let (left, tokens) = parse_binary_rhs(parser, 0, left, tokens)
  match tokens {
    [{ kind: @lexer.Operator('='), start, .. }, .. rest] => {
      guard left is @ast.Variable(name) else {
        raise InvalidAssignmentTarget(start)
      }
      let (right, rest) = parse_expression(parser, rest)
      (@ast.Assign(name, right), rest)
    }
    _ => (left, tokens)
  }
}

///|
fn finish_top_level(
  item : @ast.TopLevel,
  tokens : ArrayView[@lexer.Token],
) -> @ast.TopLevel raise ParseError {
  match tokens {
    [{ kind: @lexer.Eof, .. }] => item
    [{ kind: @lexer.Semicolon, .. }, { kind: @lexer.Eof, .. }] => item
    [{ kind: @lexer.Semicolon, .. }, token, ..] =>
      raise unexpected_token(token, "end of input after `;`")
    [token, ..] => raise unexpected_token(token, "`;` or end of input")
    [] =>
      raise UnexpectedEndOfInput(
        { offset: 0, line: 1, column: 1 },
        "end-of-input token",
      )
  }
}

///|
fn Parser::parseTokens(
  self : Parser,
  tokens : ArrayView[@lexer.Token],
) -> @ast.TopLevel raise ParseError {
  match tokens {
    [{ kind: @lexer.Def, .. }, .. rest] => {
      let (prototype, rest) = parse_prototype(rest)
      let (body, rest) = match prototype.kind {
        @ast.Binary(operator, precedence) => {
          let previous = self.operators.replacePrecedence(operator, precedence)
          let parsed = parse_expression(self, rest) catch {
            error => {
              self.operators.restorePrecedence(operator, previous)
              raise error
            }
          }
          self.operators.restorePrecedence(operator, previous)
          parsed
        }
        _ => parse_expression(self, rest)
      }
      finish_top_level(@ast.Definition(prototype, body), rest)
    }
    [{ kind: @lexer.Extern, .. }, .. rest] => {
      let (prototype, rest) = parse_prototype(rest)
      finish_top_level(@ast.Extern(prototype), rest)
    }
    _ => {
      let (expression, rest) = parse_expression(self, tokens)
      finish_top_level(@ast.Expression(expression), rest)
    }
  }
}

///|
/// Commits the precedence declared by a successfully submitted operator
/// prototype.
///
/// Normal and unary prototypes do not modify the table. A binary prototype
/// produced by this parser becomes visible to later `parseTopLevel` calls.
/// Call this only after the definition or extern declaration has completed all
/// later code-generation and JIT submission steps.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let parser = @parser.Parser::new(operators=@parser.OperatorTable::new())
///   guard parser.parseTopLevel("def binary% 50 (x y) x % y")
///     is @ast.Definition(prototype, _) else {
///     fail("expected operator definition")
///   }
///   parser.commitPrototype(prototype)
///   parser.parseTopLevel("1 + 2 % 3") |> ignore
/// }
/// ```
pub fn Parser::commitPrototype(
  self : Parser,
  prototype : @ast.Prototype,
) -> Unit {
  match prototype.kind {
    @ast.Binary(operator, precedence) =>
      self.operators.replacePrecedence(operator, precedence) |> ignore
    _ => ()
  }
}

///|
/// Parses one complete top-level form with this parser's operator table.
///
/// **Parameters:**
///
/// - `source`: Source containing exactly one definition, extern declaration,
///   or anonymous expression, optionally followed by one semicolon.
///
/// **Returns:** The complete top-level AST.
///
/// **Errors:**
///
/// - `lexer.LexError` when source text cannot be tokenized.
/// - `ParseError` when tokens do not form one complete supported construct.
pub fn Parser::parseTopLevel(
  self : Parser,
  source : String,
) -> @ast.TopLevel raise {
  let tokens = @lexer.tokenize(source)
  self.parseTokens(tokens[:])
}

///|
/// Parses one complete Kaleidoscope top-level form with an explicit operator
/// table.
///
/// **Parameters:**
///
/// - `source`: Source containing exactly one supported top-level form.
/// - `operators`: Precedence table used for binary-expression parsing.
///
/// **Returns:** The complete definition, extern declaration, or expression.
///
/// **Errors:**
///
/// - `lexer.LexError` when source text cannot be tokenized.
/// - `ParseError` for invalid syntax, duplicate parameters, or trailing input.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let operators = @parser.OperatorTable::new()
///   let item = @parser.parseTopLevel("1 + 2 * 3", operators~)
///   debug_inspect(
///     item,
///     content="Expression(Binary('+', Number(1), Binary('*', Number(2), Number(3))))",
///   )
/// }
/// ```
pub fn parseTopLevel(
  source : String,
  operators~ : OperatorTable,
) -> @ast.TopLevel raise {
  Parser::new(operators~).parseTopLevel(source)
}
