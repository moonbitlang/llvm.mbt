///|
test "variable scope restores an outer binding after codegen failure" {
  let catalog = PrototypeCatalog::new()
  let operation = CodegenContext::new(module_name="scope_failure")
  let prototype : @ast.Prototype = {
    name: "scope_failure",
    parameters: ["x"],
    kind: @ast.Normal,
  }
  try
    operation.codegenDefinition(
      prototype,
      @ast.Var(
        [{ name: "x", initializer: Some(@ast.Number(1.0)), }],
        @ast.Variable("missing"),
      ),
      catalog,
    )
  catch {
    CodegenError::UnknownVariable("missing") => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected codegen failure")
  }
  inspect(operation.variables.get("x") is Some(_), content="true")
}
