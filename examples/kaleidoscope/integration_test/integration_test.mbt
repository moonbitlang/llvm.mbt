///|
fn evaluate_value(session : @session.Session, source : String) -> Double raise {
  guard session.evaluate(source) is @session.Value(value) else {
    fail("expected expression value for `\{source}`")
  }
  value
}

///|
test "complete language features compose across submitted modules" {
  let session = @session.Session::new()
  debug_inspect(
    session.evaluate("extern sin(value)"),
    content="Extern(\"sin\")",
  )
  debug_inspect(
    session.evaluate("def unary!(value) if value then 0 else 1"),
    content="Defined(\"unary!\")",
  )
  debug_inspect(
    session.evaluate("def binary% 50 (left right) left * right"),
    content="Defined(\"binary%\")",
  )
  debug_inspect(
    session.evaluate(
      "def accumulate(limit) var total = 0 in " +
      "(for i = 1, i < limit in total = total + i) + total",
    ),
    content="Defined(\"accumulate\")",
  )
  inspect(evaluate_value(session, "accumulate(5)"), content="10")
  inspect(evaluate_value(session, "!0 + 2 % 3 + sin(0)"), content="7")
  session.close()
}

///|
test "anonymous modules unload repeatedly without disturbing definitions" {
  let session = @session.Session::new()
  session.evaluate("def stable(value) value + 1") |> ignore
  for value in 0..<128 {
    assert_eq(
      evaluate_value(session, "stable(\{value})"),
      value.to_double() + 1.0,
    )
  }
  inspect(evaluate_value(session, "stable(41)"), content="42")
  session.close()
}

///|
test "recoverable front-end, codegen, and materialization failures do not commit state" {
  let session = @session.Session::new()
  let lex_failed = try {
    session.evaluate("1abc") |> ignore
    false
  } catch {
    @session.SessionError::LexerFailure(_) => true
    _ => false
  }
  let parse_failed = try {
    session.evaluate("if 1 then") |> ignore
    false
  } catch {
    @session.SessionError::ParserFailure(_) => true
    _ => false
  }
  let codegen_failed = try {
    session.evaluate("def pending() missing") |> ignore
    false
  } catch {
    @session.SessionError::CodegenFailure(_) => true
    _ => false
  }
  session.evaluate("extern __llvm_mbt_missing_integration_symbol__()") |> ignore
  let materialization_failed = try {
    session.evaluate("__llvm_mbt_missing_integration_symbol__()") |> ignore
    false
  } catch {
    @session.SessionError::JITFailure(_) => true
    _ => false
  }
  inspect(
    lex_failed && parse_failed && codegen_failed && materialization_failed,
    content="true",
  )
  debug_inspect(
    session.evaluate("def pending() 42"),
    content="Defined(\"pending\")",
  )
  inspect(evaluate_value(session, "pending()"), content="42")
  session.close()
}

///|
test "session shutdown is deterministic at the public boundary" {
  let session = @session.Session::new()
  inspect(evaluate_value(session, "6 * 7"), content="42")
  session.close()
  let evaluate_closed = try {
    session.evaluate("1") |> ignore
    false
  } catch {
    @session.SessionError::Closed => true
    _ => false
  }
  let close_closed = try {
    session.close()
    false
  } catch {
    @session.SessionError::Closed => true
    _ => false
  }
  inspect(evaluate_closed && close_closed, content="true")
}
