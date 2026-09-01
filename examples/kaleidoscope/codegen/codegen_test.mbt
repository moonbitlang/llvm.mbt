///|
test "core binary operators produce floating-point IR" {
  let catalog = PrototypeCatalog::new()
  let prototype : @ast.Prototype = {
    name: "operators",
    parameters: ["left", "right"],
    kind: @ast.Normal,
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
      #|  %right = alloca double, align 8
      #|  %left = alloca double, align 8
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
    kind: @ast.Normal,
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
      #|  %right = alloca double, align 8
      #|  %left = alloca double, align 8
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
  catalog.commitExtern({
    name: "sin",
    parameters: ["value"],
    kind: @ast.Normal,
  })
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
  let prototype : @ast.Prototype = {
    name: "twice",
    parameters: ["value"],
    kind: @ast.Normal,
  }
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
  let prototype : @ast.Prototype = {
    name: "stable",
    parameters: ["value"],
    kind: @ast.Normal,
  }
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
  let prototype : @ast.Prototype = {
    name: "f",
    parameters: ["x"],
    kind: @ast.Normal,
  }
  catalog.commitDefinition(prototype)
  try catalog.validateDefinition(prototype) catch {
    CodegenError::DuplicateDefinition("f") => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected duplicate definition")
  }
  try
    catalog.commitExtern({ name: "f", parameters: [], kind: @ast.Normal, })
  catch {
    CodegenError::ConflictingPrototype("f", 1, 0) => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected conflicting prototype")
  }
}

///|
test "calls validate arity before lowering arguments" {
  let catalog = PrototypeCatalog::new()
  catalog.commitExtern({ name: "one", parameters: ["x"], kind: @ast.Normal, })
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
test "custom operators lower to ordinary function calls" {
  let catalog = PrototypeCatalog::new()
  catalog.commitExtern({
    name: "unary!",
    parameters: ["value"],
    kind: @ast.Unary('!'),
  })
  catalog.commitExtern({
    name: "binary%",
    parameters: ["left", "right"],
    kind: @ast.Binary('%', 50),
  })
  let mod = compileExpression(
    catalog,
    @ast.Binary('%', @ast.Unary('!', @ast.Number(0.0)), @ast.Number(3.0)),
    module_name="custom_operators",
    symbol_name="custom_operator_expression",
  )
  inspect(
    "\{mod}",
    content=(
      #|; ModuleID = 'custom_operators'
      #|source_filename = "custom_operators"
      #|
      #|define double @custom_operator_expression() {
      #|entry:
      #|  %calltmp = call double @"unary!"(double 0.000000e+00)
      #|  %calltmp1 = call double @"binary%"(double %calltmp, double 3.000000e+00)
      #|  ret double %calltmp1
      #|}
      #|
      #|declare double @"binary%"(double, double)
      #|
      #|declare double @"unary!"(double)
      #|
    ),
  )
}

///|
test "operator prototype shape is validated outside the parser" {
  let catalog = PrototypeCatalog::new()
  let malformed : Array[@ast.Prototype] = [
    { name: "unary!", parameters: [], kind: @ast.Unary('!'), },
    { name: "unarya", parameters: ["x"], kind: @ast.Unary('a'), },
    { name: "binary%", parameters: ["x", "y"], kind: @ast.Binary('%', 0), },
    { name: "binary+", parameters: ["x", "y"], kind: @ast.Binary('+', 50), },
  ]
  for prototype in malformed {
    try catalog.commitExtern(prototype) catch {
      CodegenError::InvalidPrototype(_) => ()
      error => fail("unexpected error: \{Repr(error)}")
    } noraise {
      _ => fail("expected invalid operator prototype")
    }
  }
}

///|
test "if expressions merge values from nested control flow" {
  let catalog = PrototypeCatalog::new()
  let prototype : @ast.Prototype = {
    name: "choose",
    parameters: ["value"],
    kind: @ast.Normal,
  }
  let mod = compileDefinition(
    catalog,
    prototype,
    @ast.If(
      @ast.Variable("value"),
      @ast.If(@ast.Number(0.0), @ast.Number(1.0), @ast.Number(2.0)),
      @ast.Number(3.0),
    ),
    module_name="nested_if",
  )
  inspect(
    "\{mod}",
    content=(
      #|; ModuleID = 'nested_if'
      #|source_filename = "nested_if"
      #|
      #|define double @choose(double %value1) {
      #|entry:
      #|  %value = alloca double, align 8
      #|  store double %value1, ptr %value, align 8
      #|  %value2 = load double, ptr %value, align 8
      #|  %ifcond = fcmp one double %value2, 0.000000e+00
      #|  br i1 %ifcond, label %then, label %else
      #|
      #|then:                                             ; preds = %entry
      #|  br i1 false, label %then3, label %else4
      #|
      #|else:                                             ; preds = %entry
      #|  br label %ifcont
      #|
      #|ifcont:                                           ; preds = %else, %ifcont5
      #|  %iftmp6 = phi double [ %iftmp, %ifcont5 ], [ 3.000000e+00, %else ]
      #|  ret double %iftmp6
      #|
      #|then3:                                            ; preds = %then
      #|  br label %ifcont5
      #|
      #|else4:                                            ; preds = %then
      #|  br label %ifcont5
      #|
      #|ifcont5:                                          ; preds = %else4, %then3
      #|  %iftmp = phi double [ 1.000000e+00, %then3 ], [ 2.000000e+00, %else4 ]
      #|  br label %ifcont
      #|}
      #|
    ),
  )
}

///|
test "for expressions preserve their enclosing lexical binding" {
  let catalog = PrototypeCatalog::new()
  let prototype : @ast.Prototype = {
    name: "loop",
    parameters: ["i"],
    kind: @ast.Normal,
  }
  let mod = compileDefinition(
    catalog,
    prototype,
    @ast.Binary(
      '+',
      @ast.For(
        "i",
        @ast.Number(1.0),
        @ast.Binary('<', @ast.Variable("i"), @ast.Number(3.0)),
        None,
        @ast.Variable("i"),
      ),
      @ast.Variable("i"),
    ),
    module_name="for_scope",
  )
  inspect(
    "\{mod}",
    content=(
      #|; ModuleID = 'for_scope'
      #|source_filename = "for_scope"
      #|
      #|define double @loop(double %i1) {
      #|entry:
      #|  %i2 = alloca double, align 8
      #|  %i = alloca double, align 8
      #|  store double %i1, ptr %i, align 8
      #|  store double 1.000000e+00, ptr %i2, align 8
      #|  br label %loop
      #|
      #|loop:                                             ; preds = %loop, %entry
      #|  %i3 = load double, ptr %i2, align 8
      #|  %i.current = load double, ptr %i2, align 8
      #|  %i.next = fadd double %i.current, 1.000000e+00
      #|  store double %i.next, ptr %i2, align 8
      #|  %i4 = load double, ptr %i2, align 8
      #|  %cmptmp = fcmp olt double %i4, 3.000000e+00
      #|  %booltmp = uitofp i1 %cmptmp to double
      #|  %loopcond = fcmp one double %booltmp, 0.000000e+00
      #|  br i1 %loopcond, label %loop, label %afterloop
      #|
      #|afterloop:                                        ; preds = %loop
      #|  %i5 = load double, ptr %i, align 8
      #|  %addtmp = fadd double 0.000000e+00, %i5
      #|  ret double %addtmp
      #|}
      #|
    ),
  )
}

///|
test "mutable variables use entry allocas and restore shadowed bindings" {
  let catalog = PrototypeCatalog::new()
  let prototype : @ast.Prototype = {
    name: "mutable",
    parameters: ["x"],
    kind: @ast.Normal,
  }
  let mod = compileDefinition(
    catalog,
    prototype,
    @ast.Var(
      [
        {
          name: "x",
          initializer: Some(
            @ast.Binary('+', @ast.Variable("x"), @ast.Number(1.0)),
          ),
        },
        { name: "y", initializer: None, },
      ],
      @ast.Binary('+', @ast.Assign("y", @ast.Variable("x")), @ast.Variable("y")),
    ),
    module_name="mutable_variables",
  )
  inspect(
    "\{mod}",
    content=(
      #|; ModuleID = 'mutable_variables'
      #|source_filename = "mutable_variables"
      #|
      #|define double @mutable(double %x1) {
      #|entry:
      #|  %y = alloca double, align 8
      #|  %x3 = alloca double, align 8
      #|  %x = alloca double, align 8
      #|  store double %x1, ptr %x, align 8
      #|  %x2 = load double, ptr %x, align 8
      #|  %addtmp = fadd double %x2, 1.000000e+00
      #|  store double %addtmp, ptr %x3, align 8
      #|  store double 0.000000e+00, ptr %y, align 8
      #|  %x4 = load double, ptr %x3, align 8
      #|  store double %x4, ptr %y, align 8
      #|  %y5 = load double, ptr %y, align 8
      #|  %addtmp6 = fadd double %x4, %y5
      #|  ret double %addtmp6
      #|}
      #|
    ),
  )
}

///|
test "invalid mutable AST nodes fail before unsafe backend operations" {
  let catalog = PrototypeCatalog::new()
  let invalid_bindings : Array[@ast.Expr] = [
    @ast.Var([], @ast.Number(0.0)),
    @ast.Var([{ name: "", initializer: None, }], @ast.Number(0.0)),
    @ast.Var(
      [
        { name: "x", initializer: None, },
        { name: "x", initializer: Some(@ast.Number(1.0)), },
      ],
      @ast.Variable("x"),
    ),
  ]
  for index, expression in invalid_bindings {
    try
      compileExpression(
        catalog,
        expression,
        module_name="invalid_binding_\{index}",
        symbol_name="invalid_binding_expression_\{index}",
      )
      |> ignore
    catch {
      CodegenError::InvalidVariableBinding(_) => ()
      error => fail("unexpected binding error: \{Repr(error)}")
    } noraise {
      _ => fail("expected invalid variable binding")
    }
  }
  try
    compileExpression(
      catalog,
      @ast.Assign("missing", @ast.Number(1.0)),
      module_name="unknown_assignment",
      symbol_name="unknown_assignment_expression",
    )
    |> ignore
  catch {
    CodegenError::UnknownVariable("missing") => ()
    error => fail("unexpected assignment error: \{Repr(error)}")
  } noraise {
    _ => fail("expected assignment to unknown variable to fail")
  }
}

///|
test "unknown operators and malformed prototypes are rejected" {
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
    CodegenError::UnknownFunction("binary/") => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected unsupported operator")
  }
  try
    catalog.commitExtern({
      name: "bad",
      parameters: ["x", "x"],
      kind: @ast.Normal,
    })
  catch {
    CodegenError::InvalidPrototype(_) => ()
    error => fail("unexpected error: \{Repr(error)}")
  } noraise {
    _ => fail("expected malformed prototype")
  }
}

///|
test "LLVM construction failures are mapped without catalog mutation" {
  let catalog = PrototypeCatalog::new()
  let prototype : @ast.Prototype = {
    name: "pending",
    parameters: [],
    kind: @ast.Normal,
  }
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
