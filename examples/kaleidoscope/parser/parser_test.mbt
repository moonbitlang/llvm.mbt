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
test "if expressions may nest in either branch" {
  debug_inspect(
    parse("if 1 then if 0 then 2 else 3 else 4"),
    content=(
      #|Expression(If(Number(1), If(Number(0), Number(2), Number(3)), Number(4)))
    ),
  )
}

///|
test "for expressions accept default and explicit steps" {
  debug_inspect(
    parse("for i = 1, i < 4 in i"),
    content=(
      #|Expression(
      #|  For(
      #|    "i",
      #|    Number(1),
      #|    Binary('<', Variable("i"), Number(4)),
      #|    None,
      #|    Variable("i"),
      #|  ),
      #|)
    ),
  )
  debug_inspect(
    parse("for i = 1, i < 4, 0.5 in if i then i else 0"),
    content=(
      #|Expression(
      #|  For(
      #|    "i",
      #|    Number(1),
      #|    Binary('<', Variable("i"), Number(4)),
      #|    Some(Number(0.5)),
      #|    If(Variable("i"), Variable("i"), Number(0)),
      #|  ),
      #|)
    ),
  )
}

///|
test "var bindings and assignment preserve low right-associative precedence" {
  debug_inspect(
    parse("var x = 1, y in x = y = 2 + 3 * 4"),
    content=(
      #|Expression(
      #|  Var(
      #|    [
      #|      { name: "x", initializer: Some(Number(1)) },
      #|      { name: "y", initializer: None },
      #|    ],
      #|    Assign(
      #|      "x",
      #|      Assign("y", Binary('+', Number(2), Binary('*', Number(3), Number(4)))),
      #|    ),
      #|  ),
      #|)
    ),
  )
}

///|
test "invalid assignment and variable lists retain source positions" {
  try parse("(x + 1) = 2") |> ignore catch {
    ParseError::InvalidAssignmentTarget({ offset: 8, line: 1, column: 9, }) =>
      ()
    error => fail("unexpected assignment error: \{error}")
  } noraise {
    _ => fail("expected invalid assignment target")
  }
  try parse("var x = 1, x = 2 in x") |> ignore catch {
    ParseError::DuplicateBinding("x", { offset: 11, line: 1, column: 12, }) =>
      ()
    error => fail("unexpected duplicate error: \{error}")
  } noraise {
    _ => fail("expected duplicate variable binding")
  }
  let invalid = ["var in 1", "var x = 1 x", "var x = 1, in x"]
  for source in invalid {
    try parse(source) |> ignore catch {
      ParseError::UnexpectedToken(_, _) => ()
      ParseError::UnexpectedEndOfInput(_, _) => ()
      error => fail("unexpected error for \{source}: \{error}")
    } noraise {
      _ => fail("expected invalid variable list: \{source}")
    }
  }
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
      #|  { name: "add", parameters: ["x", "y"], kind: Normal },
      #|  Binary('+', Variable("x"), Variable("y")),
      #|)
    ),
  )
  debug_inspect(
    parse("extern sin(x)"),
    content=(
      #|Extern({ name: "sin", parameters: ["x"], kind: Normal })
    ),
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
test "operator definitions use temporary and committed precedence" {
  let parser = Parser::new(operators=OperatorTable::new())
  let definition = parser.parseTopLevel(
    "def binary% 50 (left right) left + right % left",
  )
  debug_inspect(
    definition,
    content=(
      #|Definition(
      #|  {
      #|    name: "binary%",
      #|    parameters: ["left", "right"],
      #|    kind: Binary('%', 50),
      #|  },
      #|  Binary(
      #|    '+',
      #|    Variable("left"),
      #|    Binary('%', Variable("right"), Variable("left")),
      #|  ),
      #|)
    ),
  )
  guard definition is @ast.Definition(prototype, _) else {
    fail("expected operator definition")
  }
  parser.commitPrototype(prototype)
  debug_inspect(
    parser.parseTopLevel("1 + 2 % 3 * 4"),
    content=(
      #|Expression(
      #|  Binary(
      #|    '+',
      #|    Number(1),
      #|    Binary('*', Binary('%', Number(2), Number(3)), Number(4)),
      #|  ),
      #|)
    ),
  )
}

///|
test "unary operators associate from right to left" {
  debug_inspect(
    parse("def unary!(value) !!value"),
    content=(
      #|Definition(
      #|  { name: "unary!", parameters: ["value"], kind: Unary('!') },
      #|  Unary('!', Unary('!', Variable("value"))),
      #|)
    ),
  )
}

///|
test "failed operator parsing restores the precedence table" {
  let parser = Parser::new(operators=OperatorTable::new())
  try parser.parseTopLevel("def binary% 50 (x y) x %") |> ignore catch {
    ParseError::UnexpectedEndOfInput(_, _) => ()
    error => fail("unexpected definition error: \{error}")
  } noraise {
    _ => fail("expected incomplete operator body to fail")
  }
  try parser.parseTopLevel("1 % 2") |> ignore catch {
    ParseError::UnexpectedToken(
      { kind: @lexer.Operator('%'), .. },
      "`;` or end of input"
    ) => ()
    error => fail("unexpected rollback error: \{error}")
  } noraise {
    _ => fail("expected uncommitted precedence to remain unavailable")
  }
}

///|
test "invalid operator prototypes are rejected" {
  let invalid = [
    "def binary+ 50 (x y) x", "def binary= 50 (x y) x", "def binary% 0 (x y) x",
    "def binary% 101 (x y) x", "def binary% 1.5 (x y) x", "def binary% 50 (x) x",
    "def unary!(x y) x", "def unary=(x) x",
  ]
  for source in invalid {
    try parse(source) |> ignore catch {
      ParseError::InvalidOperatorPrototype(_, _) => ()
      error => fail("unexpected error for \{source}: \{error}")
    } noraise {
      _ => fail("expected invalid operator prototype: \{source}")
    }
  }
}

///|
test "trailing input is rejected at the first extra token" {
  try parse("1; 2") |> ignore catch {
    ParseError::UnexpectedToken(
      {
        kind: @lexer.Number(2.0),
        start: { offset: 3, line: 1, column: 4, },
        ..
      },
      "end of input after `;`"
    ) => ()
    error => fail("unexpected error: \{error}")
  } noraise {
    _ => fail("expected trailing input to fail")
  }
  try parse("1;;") |> ignore catch {
    ParseError::UnexpectedToken(
      { kind: @lexer.Semicolon, start: { offset: 2, line: 1, column: 3, }, .. },
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
    ParseError::DuplicateParameter("x", { offset: 8, line: 1, column: 9, }) =>
      ()
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
      { offset: 6, line: 1, column: 7, },
      "`)` after expression"
    ) => ()
    error => fail("unexpected error: \{error}")
  } noraise {
    _ => fail("expected missing parenthesis to fail")
  }
  try parse("foo(1, 2") |> ignore catch {
    ParseError::UnexpectedEndOfInput(
      { offset: 8, line: 1, column: 9, },
      "`,` or `)` after argument"
    ) => ()
    error => fail("unexpected error: \{error}")
  } noraise {
    _ => fail("expected missing call delimiter to fail")
  }
}

///|
test "unsupported operators are not parsed as core expressions" {
  try parse("8 / 2") |> ignore catch {
    ParseError::UnexpectedToken(
      {
        kind: @lexer.Operator('/'),
        start: { offset: 2, line: 1, column: 3, },
        ..
      },
      "`;` or end of input"
    ) => ()
    error => fail("unexpected error: \{error}")
  } noraise {
    _ => fail("expected unsupported operator to fail")
  }
}

///|
test "control-flow delimiters are required" {
  let invalid = [
    "if 1 2 else 3", "if 1 then 2", "for = 1, 1 in 0", "for i 1, 1 in 0", "for i = 1 1 in 0",
    "for i = 1, 1 0",
  ]
  for source in invalid {
    try parse(source) |> ignore catch {
      ParseError::UnexpectedToken(_, _) => ()
      ParseError::UnexpectedEndOfInput(_, _) => ()
      error => fail("unexpected error for \{source}: \{error}")
    } noraise {
      _ => fail("expected invalid control flow to fail: \{source}")
    }
  }
}

///|
test "lexer errors propagate through the parser" {
  try parse("1abc") |> ignore catch {
    @lexer.LexError::MalformedNumber("1abc", { offset: 0, line: 1, column: 1, }) =>
      ()
    error => fail("unexpected error: \{error}")
  } noraise {
    _ => fail("expected malformed number to fail")
  }
}
