///|
fn token_kinds(source : String) -> Array[TokenKind] raise LexError {
  tokenize(source).map(token => token.kind)
}

///|
test "keywords and identifiers" {
  debug_inspect(
    token_kinds(
      "def extern if then else for in binary unary var ordinary _under x2",
    ),
    content=(
      #|[
      #|  Def,
      #|  Extern,
      #|  If,
      #|  Then,
      #|  Else,
      #|  For,
      #|  In,
      #|  Binary,
      #|  Unary,
      #|  Var,
      #|  Identifier("ordinary"),
      #|  Identifier("_under"),
      #|  Identifier("x2"),
      #|  Eof,
      #|]
    ),
  )
}

///|
test "decimal and exponent numbers" {
  debug_inspect(
    token_kinds("0 42 3.14 .5 1. 6.02e23 1e-2"),
    content=(
      #|[
      #|  Number(0),
      #|  Number(42),
      #|  Number(3.14),
      #|  Number(0.5),
      #|  Number(1),
      #|  Number(6.02e+23),
      #|  Number(0.01),
      #|  Eof,
      #|]
    ),
  )
}

///|
test "punctuation and operators" {
  debug_inspect(
    token_kinds("(x, y); + - * / < = ! % & | ^ ~ ? : . $ @"),
    content=(
      #|[
      #|  LeftParen,
      #|  Identifier("x"),
      #|  Comma,
      #|  Identifier("y"),
      #|  RightParen,
      #|  Semicolon,
      #|  Operator('+'),
      #|  Operator('-'),
      #|  Operator('*'),
      #|  Operator('/'),
      #|  Operator('<'),
      #|  Operator('='),
      #|  Operator('!'),
      #|  Operator('%'),
      #|  Operator('&'),
      #|  Operator('|'),
      #|  Operator('^'),
      #|  Operator('~'),
      #|  Operator('?'),
      #|  Operator(':'),
      #|  Operator('.'),
      #|  Operator('$'),
      #|  Operator('@'),
      #|  Eof,
      #|]
    ),
  )
}

///|
test "comments, newlines, and source positions" {
  debug_inspect(
    tokenize("# lead\r\ndef foo\n  x"),
    content=(
      #|[
      #|  {
      #|    kind: Def,
      #|    start: { offset: 8, line: 2, column: 1 },
      #|    end: { offset: 11, line: 2, column: 4 },
      #|  },
      #|  {
      #|    kind: Identifier("foo"),
      #|    start: { offset: 12, line: 2, column: 5 },
      #|    end: { offset: 15, line: 2, column: 8 },
      #|  },
      #|  {
      #|    kind: Identifier("x"),
      #|    start: { offset: 18, line: 3, column: 3 },
      #|    end: { offset: 19, line: 3, column: 4 },
      #|  },
      #|  {
      #|    kind: Eof,
      #|    start: { offset: 19, line: 3, column: 4 },
      #|    end: { offset: 19, line: 3, column: 4 },
      #|  },
      #|]
    ),
  )
}

///|
test "empty source contains only EOF" {
  debug_inspect(
    tokenize(""),
    content=(
      #|[
      #|  {
      #|    kind: Eof,
      #|    start: { offset: 0, line: 1, column: 1 },
      #|    end: { offset: 0, line: 1, column: 1 },
      #|  },
      #|]
    ),
  )
}

///|
test "token Show uses its half-open source range" {
  inspect(tokenize("def")[0].to_string(), content="Def@1:1..1:4")
}

///|
test "positions count UTF-16 width in skipped comments" {
  debug_inspect(
    tokenize("# 🐰\nx")[0].start,
    content=(
      #|{ offset: 5, line: 2, column: 1 }
    ),
  )
}

///|
test "malformed numbers are rejected" {
  let malformed = ["1.2.3", "1abc", ".5tail", "1e+"]
  for source in malformed {
    try tokenize(source) |> ignore catch {
      MalformedNumber(_, { offset: 0, line: 1, column: 1 }) => ()
      _ => fail("unexpected lexer error for \{source}")
    } noraise {
      _ => fail("expected malformed number for \{source}")
    }
  }
}

///|
test "invalid characters preserve their position" {
  try tokenize("def f [") |> ignore catch {
    InvalidCharacter('[', position) =>
      debug_inspect(
        position,
        content=(
          #|{ offset: 6, line: 1, column: 7 }
        ),
      )
    _ => fail("unexpected lexer error")
  } noraise {
    _ => fail("expected invalid character")
  }
}

///|
test "embedded NUL is rejected" {
  try tokenize("x\u{0}y") |> ignore catch {
    InvalidCharacter('\u{0}', position) =>
      debug_inspect(
        position,
        content=(
          #|{ offset: 1, line: 1, column: 2 }
        ),
      )
    _ => fail("unexpected lexer error")
  } noraise {
    _ => fail("expected invalid character")
  }
}

///|
test "unsupported Unicode line separators are rejected" {
  try tokenize("\u{2028}") |> ignore catch {
    InvalidCharacter('\u{2028}', position) =>
      debug_inspect(
        position,
        content=(
          #|{ offset: 0, line: 1, column: 1 }
        ),
      )
    _ => fail("unexpected lexer error")
  } noraise {
    _ => fail("expected invalid character")
  }
}
