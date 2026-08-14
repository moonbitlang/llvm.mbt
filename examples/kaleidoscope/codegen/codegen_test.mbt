///|
test "core binary operators produce floating-point IR" {
  let catalog = PrototypeCatalog::new()
  let prototype : @ast.Prototype = {
    name: "operators",
    parameters: ["left", "right"],
  }
  let mod = compileDefinition(
    catalog,
    prototype,
    @ast.Binary(
      '<',
      @ast.Binary('-', @ast.Variable("left"), @ast.Variable("right")),
      @ast.Binary(
        '*',
        @ast.Binary('+', @ast.Variable("left"), @ast.Variable("right")),
        @ast.Variable("right"),
      ),
    ),
    module_name="arithmetic",
  )
  inspect(
    "\{mod}",
    content=(
      #|; ModuleID = 'arithmetic'
      #|source_filename = "arithmetic"
      #|
      #|define double @operators(double %left1, double %right2) {
      #|entry:
      #|  %left = alloca double, align 8
      #|  %right = alloca double, align 8
      #|  store double %left1, ptr %left, align 8
      #|  store double %right2, ptr %right, align 8
      #|  %left3 = load double, ptr %left, align 8
      #|  %right4 = load double, ptr %right, align 8
      #|  %subtmp = fsub double %left3, %right4
      #|  %left5 = load double, ptr %left, align 8
      #|  %right6 = load double, ptr %right, align 8
      #|  %addtmp = fadd double %left5, %right6
      #|  %right7 = load double, ptr %right, align 8
      #|  %multmp = fmul double %addtmp, %right7
      #|  %cmptmp = fcmp olt double %subtmp, %multmp
      #|  %booltmp = uitofp i1 %cmptmp to double
      #|  ret double %booltmp
      #|}
      #|
    ),
  )
}

///|
test "function parameters use entry allocas and loads" {
  let catalog = PrototypeCatalog::new()
  let prototype : @ast.Prototype = {
    name: "add",
    parameters: ["left", "right"],
  }
  let mod = compileDefinition(
    catalog,
    prototype,
    @ast.Binary('+', @ast.Variable("left"), @ast.Variable("right")),
    module_name="definition",
  )
  inspect(
    "\{mod}",
    content=(
      #|; ModuleID = 'definition'
      #|source_filename = "definition"
      #|
      #|define double @add(double %left1, double %right2) {
      #|entry:
      #|  %left = alloca double, align 8
      #|  %right = alloca double, align 8
      #|  store double %left1, ptr %left, align 8
      #|  store double %right2, ptr %right, align 8
      #|  %left3 = load double, ptr %left, align 8
      #|  %right4 = load double, ptr %right, align 8
      #|  %addtmp = fadd double %left3, %right4
      #|  ret double %addtmp
      #|}
      #|
    ),
  )
}

///|
test "catalog prototypes become local declarations" {
  let catalog = PrototypeCatalog::new()
  catalog.commitExtern({ name: "sin", parameters: ["value"] })
  let mod = compileExpression(
    catalog,
    @ast.Call("sin", [@ast.Number(0.0)]),
    module_name="extern_call",
    symbol_name="call_sin",
  )
  inspect(
    "\{mod}",
    content=(
      #|; ModuleID = 'extern_call'
      #|source_filename = "extern_call"
      #|
      #|define double @call_sin() {
      #|entry:
      #|  %calltmp = call double @sin(double 0.000000e+00)
      #|  ret double %calltmp
      #|}
      #|
      #|declare double @sin(double)
      #|
    ),
  )
}

///|
test "submitted definition state supports later module calls" {
  let catalog = PrototypeCatalog::new()
  let prototype : @ast.Prototype = { name: "twice", parameters: ["value"] }
  compileDefinition(
    catalog,
    prototype,
    @ast.Binary('+', @ast.Variable("value"), @ast.Variable("value")),
    module_name="twice_definition",
  )
  |> ignore
  catalog.commitDefinition(prototype)
  let caller = compileExpression(
    catalog,
    @ast.Call("twice", [@ast.Number(21.0)]),
    module_name="twice_caller",
    symbol_name="call_twice",
  )
  inspect(
    "\{caller}",
    content=(
      #|; ModuleID = 'twice_caller'
      #|source_filename = "twice_caller"
      #|
      #|define double @call_twice() {
      #|entry:
      #|  %calltmp = call double @twice(double 2.100000e+01)
      #|  ret double %calltmp
      #|}
      #|
      #|declare double @twice(double)
      #|
    ),
  )
}

///|
test "each compilation owns a fresh LLVM context" {
  let catalog = PrototypeCatalog::new()
  let first = compileExpression(
    catalog,
    @ast.Number(1.0),
    module_name="first",
    symbol_name="first_expression",
  )
  let second = compileExpression(
    catalog,
    @ast.Number(2.0),
    module_name="second",
    symbol_name="second_expression",
  )
  inspect(first.getContext() == second.getContext(), content="false")
}

///|
test "catalog stores only independent prototype data" {
  let catalog = PrototypeCatalog::new()
  let prototype : @ast.Prototype = { name: "stable", parameters: ["value"] }
  catalog.commitExtern(prototype)
  prototype.parameters.push("later")
  guard catalog.get("stable") is Some(stored) else {
    fail("expected stored prototype")
  }
  inspect(stored.parameters.length(), content="1")
  stored.parameters.push("also_later")
  guard catalog.get("stable") is Some(stored_again) else {
    fail("expected stored prototype")
  }
  inspect(stored_again.parameters.length(), content="1")
}

///|
test "unknown variables and functions are stable errors" {
  let catalog = PrototypeCatalog::new()
  try
    compileExpression(
      catalog,
      @ast.Variable("missing"),
      module_name="unknown_variable",
      symbol_name="unknown_variable_expression",
    )
    |> ignore
  catch {
    CodegenError::UnknownVariable("missing") => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected unknown variable")
  }
  try
    compileExpression(
      catalog,
      @ast.Call("missing", []),
      module_name="unknown_function",
      symbol_name="unknown_function_expression",
    )
    |> ignore
  catch {
    CodegenError::UnknownFunction("missing") => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected unknown function")
  }
}

///|
test "catalog rejects duplicate and conflicting definitions" {
  let catalog = PrototypeCatalog::new()
  let prototype : @ast.Prototype = { name: "f", parameters: ["x"] }
  catalog.commitDefinition(prototype)
  try catalog.validateDefinition(prototype) catch {
    CodegenError::DuplicateDefinition("f") => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected duplicate definition")
  }
  try catalog.commitExtern({ name: "f", parameters: [] }) catch {
    CodegenError::ConflictingPrototype("f", 1, 0) => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected conflicting prototype")
  }
}

///|
test "calls validate arity before lowering arguments" {
  let catalog = PrototypeCatalog::new()
  catalog.commitExtern({ name: "one", parameters: ["x"] })
  try
    compileExpression(
      catalog,
      @ast.Call("one", []),
      module_name="bad_call",
      symbol_name="bad_call_expression",
    )
    |> ignore
  catch {
    CodegenError::ArgumentCountMismatch("one", 1, 0) => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected argument count mismatch")
  }
}

///|
test "unsupported operators and malformed prototypes are rejected" {
  let catalog = PrototypeCatalog::new()
  try
    compileExpression(
      catalog,
      @ast.Binary('/', @ast.Number(4.0), @ast.Number(2.0)),
      module_name="unsupported_operator",
      symbol_name="unsupported_operator_expression",
    )
    |> ignore
  catch {
    CodegenError::UnsupportedBinaryOperator('/') => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected unsupported operator")
  }
  try catalog.commitExtern({ name: "bad", parameters: ["x", "x"] }) catch {
    CodegenError::InvalidPrototype(_) => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected malformed prototype")
  }
}

///|
test "LLVM construction failures are mapped without catalog mutation" {
  let catalog = PrototypeCatalog::new()
  let prototype : @ast.Prototype = { name: "pending", parameters: [] }
  try
    compileDefinition(
      catalog,
      prototype,
      @ast.Number(1.0),
      module_name="bad\u{0}module",
    )
    |> ignore
  catch {
    CodegenError::BackendFailure(_) => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected backend failure")
  }
  inspect(catalog.isDefined("pending"), content="false")
  inspect(catalog.get("pending") is None, content="true")
}
