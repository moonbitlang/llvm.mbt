///|
test "verification failures map before session state is committed" {
  let session = Session::new()
  let operation = @codegen.CodegenContext::new(module_name="invalid_module")
  let mod = operation.getModule()
  let context = mod.getContext()
  let function_type = context.getFunctionType(context.getDoubleTy(), [])
  let function = mod.addFunction(function_type, "unterminated")
  function.addBasicBlock(name="entry") |> ignore
  try codegen_operation(() => operation.verify()) catch {
    SessionError::CodegenFailure(@codegen.CodegenError::VerificationFailed(_)) =>
      ()
    error => fail("unexpected verification error: \{Repr(error)}")
  } noraise {
    _ => fail("expected invalid module verification to fail")
  }
  debug_inspect(session.evaluate("40 + 2"), content="Value(42)")
  session.close()
}

///|
test "cleanup failures preserve both diagnostics" {
  inspect(
    SessionError::CleanupFailure("lookup failed", "remove failed").message(),
    content="lookup failed; cleanup also failed: remove failed",
  )
}
