///|
test "anonymous expressions execute native code" {
  let session = Session::new()
  debug_inspect(session.evaluate("1 + 2 * 3"), content="Value(7)")
  debug_inspect(session.evaluate("4 < 3"), content="Value(0)")
  session.close()
}

///|
test "definitions persist across submitted modules" {
  let session = Session::new()
  debug_inspect(
    session.evaluate("def add(left right) left + right;"),
    content="Defined(\"add\")",
  )
  debug_inspect(session.evaluate("add(20, 22)"), content="Value(42)")
  session.close()
}

///|
test "if expressions use zero and nonzero truth values" {
  let session = Session::new()
  debug_inspect(session.evaluate("if 0 then 1 else 2"), content="Value(2)")
  debug_inspect(session.evaluate("if 0 - 3 then 1 else 2"), content="Value(1)")
  debug_inspect(
    session.evaluate("if 1 then if 0 then 3 else 4 else 5"),
    content="Value(4)",
  )
  session.close()
}

///|
test "for expressions execute finite default and explicit-step loops" {
  let session = Session::new()
  debug_inspect(session.evaluate("for i = 1, i < 3 in i"), content="Value(0)")
  debug_inspect(
    session.evaluate("for i = 1, i < 3, 0.5 in if i then i else 0"),
    content="Value(0)",
  )
  debug_inspect(
    session.evaluate("def run(n) for i = 1, i < n in i"),
    content="Defined(\"run\")",
  )
  debug_inspect(session.evaluate("run(4)"), content="Value(0)")
  session.close()
}

///|
test "user-defined unary and binary operators execute with their precedence" {
  let session = Session::new()
  debug_inspect(
    session.evaluate("def unary!(value) if value then 0 else 1"),
    content="Defined(\"unary!\")",
  )
  debug_inspect(session.evaluate("!0 + !1"), content="Value(1)")
  debug_inspect(
    session.evaluate("def binary% 50 (left right) left * right"),
    content="Defined(\"binary%\")",
  )
  debug_inspect(session.evaluate("1 + 2 % 3"), content="Value(7)")
  session.close()
}

///|
test "failed operator definitions do not commit precedence" {
  let session = Session::new()
  try session.evaluate("def binary& 60 (left right) missing") |> ignore catch {
    SessionError::CodegenFailure(
      @codegen.CodegenError::UnknownVariable("missing")
    ) => ()
    error => fail("unexpected codegen error: \{Repr(error)}")
  } noraise {
    _ => fail("expected operator codegen to fail")
  }
  try session.evaluate("1 & 2") |> ignore catch {
    SessionError::ParserFailure(_) => ()
    error => fail("unexpected rollback error: \{Repr(error)}")
  } noraise {
    _ => fail("expected failed precedence to remain unavailable")
  }
  session.evaluate("def binary& 60 (left right) left + right") |> ignore
  debug_inspect(session.evaluate("20 & 22"), content="Value(42)")
  try
    session.evaluate("def binary& 10 (left right) left - right") |> ignore
  catch {
    SessionError::CodegenFailure(
      @codegen.CodegenError::DuplicateDefinition("binary&")
    ) => ()
    error => fail("unexpected duplicate error: \{Repr(error)}")
  } noraise {
    _ => fail("expected duplicate operator definition to fail")
  }
  debug_inspect(session.evaluate("1 & 2 * 3"), content="Value(9)")
  session.close()
}

///|
test "extern declarations resolve current-process symbols" {
  let session = Session::new()
  debug_inspect(
    session.evaluate("extern sin(value);"),
    content="Extern(\"sin\")",
  )
  debug_inspect(session.evaluate("sin(0)"), content="Value(0)")
  session.close()
}

///|
test "missing extern symbols unload their anonymous module" {
  let session = Session::new()
  session.evaluate("extern __llvm_mbt_missing_kaleidoscope_symbol__()")
  |> ignore
  try
    session.evaluate("__llvm_mbt_missing_kaleidoscope_symbol__()") |> ignore
  catch {
    SessionError::JITFailure(_) => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected missing symbol failure")
  }
  debug_inspect(session.evaluate("2 + 2"), content="Value(4)")
  session.close()
}

///|
test "duplicate definitions do not replace submitted code" {
  let session = Session::new()
  session.evaluate("def answer() 42") |> ignore
  try session.evaluate("def answer() 0") |> ignore catch {
    SessionError::CodegenFailure(
      @codegen.CodegenError::DuplicateDefinition("answer")
    ) => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected duplicate definition")
  }
  debug_inspect(session.evaluate("answer()"), content="Value(42)")
  session.close()
}

///|
test "parse and codegen failures leave the session usable" {
  let session = Session::new()
  try session.evaluate("def broken(") |> ignore catch {
    SessionError::ParserFailure(_) => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected parse failure")
  }
  try session.evaluate("missing") |> ignore catch {
    SessionError::CodegenFailure(
      @codegen.CodegenError::UnknownVariable("missing")
    ) => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected codegen failure")
  }
  debug_inspect(session.evaluate("6 * 7"), content="Value(42)")
  session.close()
}

///|
test "lexer failures retain their typed diagnostic" {
  let session = Session::new()
  try session.evaluate("1abc") |> ignore catch {
    SessionError::LexerFailure(
      @lexer.LexError::MalformedNumber(
        "1abc",
        { offset: 0, line: 1, column: 1 }
      )
    ) => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected lexer failure")
  }
  session.close()
}

///|
test "anonymous trackers can be created and removed repeatedly" {
  let session = Session::new()
  for value in 0..<32 {
    guard session.evaluate("\{value} + 1") is Value(result) else {
      fail("expected expression value")
    }
    assert_eq(result, value.to_double() + 1.0)
  }
  session.close()
}

///|
test "independent sessions may use the same definition names" {
  let first = Session::new()
  let second = Session::new()
  first.evaluate("def local() 10") |> ignore
  second.evaluate("def local() 20") |> ignore
  debug_inspect(first.evaluate("local()"), content="Value(10)")
  debug_inspect(second.evaluate("local()"), content="Value(20)")
  first.close()
  second.close()
}

///|
test "explicit close rejects later use and repeated close" {
  let session = Session::new()
  session.close()
  try session.evaluate("1") |> ignore catch {
    SessionError::Closed => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected evaluate after close to fail")
  }
  try session.close() catch {
    SessionError::Closed => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected repeated close to fail")
  }
}
