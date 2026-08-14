///|
fn parse(source : String) -> @ast.TopLevel raise {
  parseTopLevel(source, operators=OperatorTable::new())
}

///|
test "number, variable, and parentheses" {
  debug_inspect(parse("42"), content="Expression(Number(42))")
  debug_inspect(parse("value;"), content="Expression(Variable(\"value\"))")
  debug_inspect(
    parse("(1 + 2) * 3"),
    content=(
      #|Expression(Binary('*', Binary('+', Number(1), Number(2)), Number(3)))
    ),
  )
}

///|
test "built-in binary precedence" {
  debug_inspect(
    parse("1 + 2 * 3 < 10"),
    content=(
      #|Expression(
      #|  Binary(
      #|    '<',
      #|    Binary('+', Number(1), Binary('*', Number(2), Number(3))),
      #|    Number(10),
      #|  ),
      #|)
    ),
  )
}

///|
test "empty and nested calls" {
  debug_inspect(parse("foo()"), content="Expression(Call(\"foo\", []))")
  debug_inspect(
    parse("foo(1, bar(2, 3))"),
    content=(
      #|Expression(Call("foo", [Number(1), Call("bar", [Number(2), Number(3)])]))
    ),
  )
}

///|
test "definition and extern prototype" {
  debug_inspect(
    parse("def add(x y) x + y;"),
    content=(
      #|Definition(
      #|  { name: "add", parameters: ["x", "y"] },
      #|  Binary('+', Variable("x"), Variable("y")),
      #|)
    ),
  )
  debug_inspect(
    parse("extern sin(x)"),
    content="Extern({ name: \"sin\", parameters: [\"x\"] })",
  )
}

///|
test "operator table is explicit and parser is reusable" {
  let operators = OperatorTable::new()
  debug_inspect(operators.getPrecedence('<'), content="Some(10)")
  debug_inspect(operators.getPrecedence('+'), content="Some(20)")
  debug_inspect(operators.getPrecedence('-'), content="Some(20)")
  debug_inspect(operators.getPrecedence('*'), content="Some(40)")
  debug_inspect(operators.getPrecedence('/'), content="None")
  let parser = Parser::new(operators~)
  debug_inspect(
    parser.parseTopLevel("1 + 2 * 3"),
    content=(
      #|Expression(Binary('+', Number(1), Binary('*', Number(2), Number(3))))
    ),
  )
  debug_inspect(
    parser.parseTopLevel("4 < 5"),
    content=(
      #|Expression(Binary('<', Number(4), Number(5)))
    ),
  )
}

///|
test "trailing input is rejected at the first extra token" {
  try parse("1; 2") |> ignore catch {
    ParseError::UnexpectedToken(
      { kind: @lexer.Number(2.0), start: { offset: 3, line: 1, column: 4 }, .. },
      "end of input after `;`"
    ) => ()
    error => fail("unexpected error: \{error}")
  } noraise {
    _ => fail("expected trailing input to fail")
  }
  try parse("1;;") |> ignore catch {
    ParseError::UnexpectedToken(
      { kind: @lexer.Semicolon, start: { offset: 2, line: 1, column: 3 }, .. },
      "end of input after `;`"
    ) => ()
    error => fail("unexpected error: \{error}")
  } noraise {
    _ => fail("expected the second semicolon to fail")
  }
}

///|
test "duplicate parameters preserve their position" {
  try parse("def f(x x) x") |> ignore catch {
    ParseError::DuplicateParameter("x", { offset: 8, line: 1, column: 9 }) => ()
    error => fail("unexpected error: \{error}")
  } noraise {
    _ => fail("expected duplicate parameter to fail")
  }
}

///|
test "invalid prototypes are rejected" {
  let invalid = ["def 1(x) x", "extern f x)", "def f(x, y) x"]
  for source in invalid {
    try parse(source) |> ignore catch {
      ParseError::UnexpectedToken(_, _) => ()
      error => fail("unexpected error for \{source}: \{error}")
    } noraise {
      _ => fail("expected invalid prototype to fail: \{source}")
    }
  }
}

///|
test "missing delimiters report end-of-input positions" {
  try parse("(1 + 2") |> ignore catch {
    ParseError::UnexpectedEndOfInput(
      { offset: 6, line: 1, column: 7 },
      "`)` after expression"
    ) => ()
    error => fail("unexpected error: \{error}")
  } noraise {
    _ => fail("expected missing parenthesis to fail")
  }
  try parse("foo(1, 2") |> ignore catch {
    ParseError::UnexpectedEndOfInput(
      { offset: 8, line: 1, column: 9 },
      "`,` or `)` after argument"
    ) => ()
    error => fail("unexpected error: \{error}")
  } noraise {
    _ => fail("expected missing call delimiter to fail")
  }
}

///|
test "unsupported tokens are not parsed as core expressions" {
  try parse("if") |> ignore catch {
    ParseError::UnexpectedToken(
      { kind: @lexer.If, start: { offset: 0, line: 1, column: 1 }, .. },
      "expression"
    ) => ()
    error => fail("unexpected error: \{error}")
  } noraise {
    _ => fail("expected unsupported keyword to fail")
  }
  try parse("8 / 2") |> ignore catch {
    ParseError::UnexpectedToken(
      {
        kind: @lexer.Operator('/'),
        start: { offset: 2, line: 1, column: 3 },
        ..,
      },
      "`;` or end of input"
    ) => ()
    error => fail("unexpected error: \{error}")
  } noraise {
    _ => fail("expected unsupported operator to fail")
  }
}

///|
test "lexer errors propagate through the parser" {
  try parse("1abc") |> ignore catch {
    @lexer.LexError::MalformedNumber("1abc", { offset: 0, line: 1, column: 1 }) =>
      ()
    error => fail("unexpected error: \{error}")
  } noraise {
    _ => fail("expected malformed number to fail")
  }
}
