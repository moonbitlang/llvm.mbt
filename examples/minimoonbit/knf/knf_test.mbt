///|
test "Apply Expr Knf Transformation Test" {
  // Prelude Parts
  // set a, b, x, arr, point, max type in typecheck and knf context
  let typecheck_ctx = @typecheck.Context::new()
  typecheck_ctx.type_env.set("a", { kind: Int, mutable: false })
  typecheck_ctx.type_env.set("b", { kind: Int, mutable: false })
  typecheck_ctx.type_env.set("x", { kind: Int, mutable: false })
  let point_struct_def : @typecheck.StructDef = {
    name: "Point",
    fields: [
      { name: "x", ty: { kind: Int, mutable: false } },
      { name: "y", ty: { kind: Int, mutable: false } },
    ],
    methods: Map::new(),
  }
  typecheck_ctx.struct_defs.set("Point", point_struct_def)
  typecheck_ctx.type_env.set("arr", { kind: Array(Int), mutable: false })
  typecheck_ctx.type_env.set("point", { kind: Struct("Point"), mutable: false })
  typecheck_ctx.type_env.set("max", {
    kind: Function([Int, Int], Int),
    mutable: false,
  })
  let knf_ctx = Context::new()
  knf_ctx.globals.set("max", Function([Int, Int], Int))
  let _ = knf_ctx.add_new_name("a", Int)
  let _ = knf_ctx.add_new_name("b", Int)
  let _ = knf_ctx.add_new_name("x", Int)
  let _ = knf_ctx.add_new_name("arr", Array(Int))
  let _ = knf_ctx.add_new_name("point", Struct("Point"))

  // Test Parts
  let code =
    #|arr[3]
    #|arr[x]
    #|point.x
    #|max(a + b, a - b)
  // Code parse, typecheck, knf transform
  let tokens = @lexer.tokenize(code)
  // Parse and transform `arr[3]`.
  let (e, tok_view) = @parser.parse_apply_expr(tokens)
  let e = typecheck_ctx.check_apply_expr(e)
  let (stmts, knf_expr) = knf_ctx.apply_expr_to_knf(e)
  assert_true(
    stmts is [s1] &&
    s1 is Let(n1, Int, Int(3)) &&
    knf_expr is ArrayAccess(arr_name, index_name) &&
    arr_name is { id: "arr", .. } &&
    index_name == n1,
  )
  // Parse and transform `arr[x]`.
  let (e, tok_view) = @parser.parse_apply_expr(tok_view)
  let e = typecheck_ctx.check_apply_expr(e)
  let (stmts, knf_expr) = knf_ctx.apply_expr_to_knf(e)
  assert_true(
    stmts is [] &&
    knf_expr is ArrayAccess(arr_name, index_name) &&
    arr_name is { id: "arr", .. } &&
    index_name is { id: "x", .. },
  )
  // Parse and transform `point.x`.
  let (e, tok_view) = @parser.parse_apply_expr(tok_view)
  let e = typecheck_ctx.check_apply_expr(e)
  let (stmts, knf_expr) = knf_ctx.apply_expr_to_knf(e)
  assert_true(
    stmts is [] &&
    knf_expr is FieldAccess(struct_name, field_name) &&
    struct_name is { id: "point", .. } &&
    field_name is "x",
  )
  // Parse and transform `max(a + b, a - b)`.
  let (e, _) = @parser.parse_apply_expr(tok_view)
  let e = typecheck_ctx.check_apply_expr(e)
  let (stmts, knf_expr) = knf_ctx.apply_expr_to_knf(e)
  assert_true(
    stmts is [s1, s2] &&
    s1 is Let(n1, Int, Binary(Add, l1, r1)) &&
    l1.id is "a" &&
    r1.id is "b" &&
    s2 is Let(n2, Int, Binary(Sub, l2, r2)) &&
    l2.id is "a" &&
    r2.id is "b" &&
    knf_expr is Call(callee_name, arg_names) &&
    callee_name.id is "max" &&
    arg_names == [n1, n2],
  )
}

///|
test "Assign Stmt Knf Transformation Test" {
  // Prelude Parts
  // set x, y type in typecheck and knf context
  let typecheck_ctx = @typecheck.Context::new()
  let point_struct_def : @typecheck.StructDef = {
    name: "Point",
    fields: [{ name: "x", ty: { kind: Int, mutable: true } }],
    methods: Map::new(),
  }
  typecheck_ctx.struct_defs.set("Point", point_struct_def)
  typecheck_ctx.type_env.set("x", { kind: Int, mutable: true })
  typecheck_ctx.type_env.set("y", { kind: Double, mutable: true })
  typecheck_ctx.type_env.set("mat", { kind: Array(Array(Int)), mutable: true })
  typecheck_ctx.type_env.set("point", { kind: Struct("Point"), mutable: false })
  let knf_ctx = Context::new()
  let _ = knf_ctx.add_new_name("x", Int)
  let _ = knf_ctx.add_new_name("y", Double)
  let _ = knf_ctx.add_new_name("arr", Array(Int))
  let _ = knf_ctx.add_new_name("point", Struct("Point"))
  let _ = knf_ctx.add_new_name("mat", Array(Array(Int)))

  // Test Parts
  let code =
    #|x = 10;
    #|y = 3.14;
    #|x += 5;
    #|y -= 1.0;
    #|mat[0][0] = 42;
    #|point.x = 100;
  // Code parse, typecheck, knf transform
  let tokens = @lexer.tokenize(code)

  // Parse and transform `x = 10;`
  let (stmt, tok_view) = @parser.parse_assign_stmt(tokens)
  let stmt = typecheck_ctx.check_assign_stmt(stmt)
  let knf_stmts = knf_ctx.assign_stmt_to_knf(stmt)
  assert_true(
    knf_stmts is [s] &&
    s is Assign(name, expr) &&
    name is { id: "x", .. } &&
    expr is Int(10),
  )

  // Parse and transform `y = 3.14;`
  let (stmt, tok_view) = @parser.parse_assign_stmt(tok_view)
  let stmt = typecheck_ctx.check_assign_stmt(stmt)
  let knf_stmts = knf_ctx.assign_stmt_to_knf(stmt)
  assert_true(
    knf_stmts is [s] &&
    s is Assign(name, expr) &&
    name is { id: "y", .. } &&
    expr is Double(3.14),
  )

  // Parse and transform `x += 5;`
  let (stmt, tok_view) = @parser.parse_assign_stmt(tok_view)
  let stmt = typecheck_ctx.check_assign_stmt(stmt)
  let knf_stmts = knf_ctx.assign_stmt_to_knf(stmt)
  assert_true(
    knf_stmts is [s1, s2, s3] &&
    s1 is Let(_, Int, Int(5)) &&
    s2 is Let(_, Int, Binary(Add, _, _)) &&
    s3 is Assign(name, Ident(_)) &&
    name is { id: "x", .. },
  )

  // Parse and transform `y -= 1.0;`
  let (stmt, tok_view) = @parser.parse_assign_stmt(tok_view)
  let stmt = typecheck_ctx.check_assign_stmt(stmt)
  let knf_stmts = knf_ctx.assign_stmt_to_knf(stmt)
  assert_true(
    knf_stmts is [s1, s2, s3] &&
    s1 is Let(_, Double, Double(1.0)) &&
    s2 is Let(_, Double, Binary(Sub, _, _)) &&
    s3 is Assign(name, Ident(_)) &&
    name is { id: "y", .. },
  )
  // Parse and transform `max[0][0] = 42;`
  let (stmt, tok_view) = @parser.parse_assign_stmt(tok_view)
  let stmt = typecheck_ctx.check_assign_stmt(stmt)
  let knf_stmts = knf_ctx.assign_stmt_to_knf(stmt)
  assert_true(
    knf_stmts is [s1, s2, s3, s4] &&
    s1 is Let(n1, Int, Int(0)) &&
    s2 is Let(n2, Array(Int), ArrayAccess(_, mat_idx_name)) &&
    s3 is Let(n3, Int, Int(0)) &&
    s4 is ArrayPut(array_name, idx_name, Int(42)) &&
    n1 == mat_idx_name &&
    array_name == n2 &&
    idx_name == n3,
  )
  // Parse and transform `point.x = 100;`
  let (stmt, _) = @parser.parse_assign_stmt(tok_view)
  let stmt = typecheck_ctx.check_assign_stmt(stmt)
  let knf_stmts = knf_ctx.assign_stmt_to_knf(stmt)
  assert_true(
    knf_stmts is [s1, s2] &&
    s1 is Let(n1, Int, Int(100)) &&
    s2 is StructFieldSet(_, "x", value_name) &&
    n1 == value_name,
  )
}

///|
test "Atom Expr Knf Transformation Test" {
  // set a, b, x, y, z type in typecheck and knf context
  let typecheck_ctx = @typecheck.Context::new()
  typecheck_ctx.type_env.set("a", { kind: Int, mutable: false })
  typecheck_ctx.type_env.set("b", { kind: Int, mutable: false })
  typecheck_ctx.type_env.set("x", { kind: Double, mutable: false })
  typecheck_ctx.type_env.set("y", { kind: String, mutable: false })
  typecheck_ctx.type_env.set("z", { kind: Bool, mutable: false })
  let point_struct_def : @typecheck.StructDef = {
    name: "Point",
    fields: [
      { name: "x", ty: { kind: Int, mutable: false } },
      { name: "y", ty: { kind: Int, mutable: false } },
    ],
    methods: Map::new(),
  }
  typecheck_ctx.struct_defs.set("Point", point_struct_def)
  let knf_ctx = Context::new()
  knf_ctx.globals.set("x", Double)
  let _ = knf_ctx.add_new_name("y", String)
  knf_ctx.enter_scope()
  let _ = knf_ctx.add_new_name("z", Bool)
  let _ = knf_ctx.add_new_name("a", Int)
  let _ = knf_ctx.add_new_name("b", Int)

  // Code parse, typecheck, knf transform
  let code =
    #|(a + b)
    #|[1, 2, 3]
    #|(x, y, z)
    #|Array::make(5, 0)
    #|Point::{ x: 10, y: 20 }
  let tokens = @lexer.tokenize(code)
  // Parse and transform `(a + b)`.
  let (e, tok_view) = @parser.parse_atom_expr(tokens)
  let e = typecheck_ctx.check_atom_expr(e)
  let (stmts, knf_expr) = knf_ctx.atom_expr_to_knf(e)
  assert_true(
    stmts is [] &&
    knf_expr is Binary(Add, l, r) &&
    l is { id: "a", .. } &&
    r is { id: "b", .. },
  )
  // Parse and transform `[1, 2, 3]`.
  let (e, tok_view) = @parser.parse_atom_expr(tok_view)
  let e = typecheck_ctx.check_atom_expr(e)
  let (stmts, knf_expr) = knf_ctx.atom_expr_to_knf(e)
  assert_true(
    stmts is [s1, s2, s3] &&
    s1 is Let(n1, Int, Int(1)) &&
    s2 is Let(n2, Int, Int(2)) &&
    s3 is Let(n3, Int, Int(3)) &&
    knf_expr is ArrayLiteral(_, [a1, a2, a3]) &&
    n1 == a1 &&
    n2 == a2 &&
    n3 == a3,
  )
  // Parse and transform `(x, y, z)`.
  let (e, tok_view) = @parser.parse_atom_expr(tok_view)
  let e = typecheck_ctx.check_atom_expr(e)
  let (stmts, knf_expr) = knf_ctx.atom_expr_to_knf(e)
  assert_true(
    stmts is [] &&
    knf_expr is TupleLiteral([t1, t2, t3]) &&
    t1 is { id: "x", .. } &&
    t2 is { id: "y", .. } &&
    t3 is { id: "z", .. },
  )
  // Parse and transform `Array::make(5, 0)`.
  let (e, tok_view) = @parser.parse_atom_expr(tok_view)
  let e = typecheck_ctx.check_atom_expr(e)
  let (stmts, knf_expr) = knf_ctx.atom_expr_to_knf(e)
  assert_true(
    stmts is [s1, s2] &&
    s1 is Let(n1, Int, Int(5)) &&
    s2 is Let(n2, Int, Int(0)) &&
    knf_expr is ArrayMake(size_name, init_name) &&
    size_name == n1 &&
    init_name == n2,
  )
  // Parse and transform `Point::{ x: 10, y: 20 }`.
  let (e, _) = @parser.parse_atom_expr(tok_view)
  let e = typecheck_ctx.check_atom_expr(e)
  let (stmts, knf_expr) = knf_ctx.atom_expr_to_knf(e)
  assert_true(
    stmts is [s1, s2] &&
    s1 is Let(n1, Int, Int(10)) &&
    s2 is Let(n2, Int, Int(20)) &&
    knf_expr is CreateStruct("Point", [("x", f1), ("y", f2)]) &&
    n1 == f1 &&
    n2 == f2,
  )
}

///|
test "Block Expr Knf Transformation Test" {
  // Prelude Parts
  let typecheck_ctx = @typecheck.Context::new()
  let knf_ctx = @knf.Context::new()

  // Setup type environment for testing
  typecheck_ctx.type_env.set("print_int", {
    kind: Function([Int], Unit),
    mutable: false,
  })

  // For return statement
  typecheck_ctx.current_func_ret_ty = Some(Int)

  // Setup knf context
  knf_ctx.globals.set("print_int", Function([Int], Unit))

  // Test Parts
  let code =
    #|{
    #|  let x: Int = 10;
    #|  let mut y: Double = 3.14;
    #|  let mut z : Int = 0;
    #|  z = 42;
    #|  print_int(z);
    #|  return z;
    #|}

  // Code parse, typecheck, knf transform
  let tokens = @lexer.tokenize(code)
  let (stmt, _) = @parser.parse_block_expr(tokens)
  let checked_block = typecheck_ctx.check_block_expr(stmt)
  let knf_block = knf_ctx.block_expr_to_knf(checked_block)
  assert_true(knf_block.stmts.length() is 6)

  // Test 1: Parse and transform `let x: Int = 10;`
  assert_true(
    knf_block.stmts[0] is Let(name1, Int, init_expr) &&
    name1 is { id: "x", .. } &&
    init_expr is Int(10),
  )

  // Test 2: Parse and transform `let mut y: Double = 3.14;`
  assert_true(
    knf_block.stmts[1] is LetMut(name2, Double, init_expr2) &&
    name2 is { id: "y", .. } &&
    init_expr2 is Double(3.14),
  )

  // Test 3: Parse and transform `let mut z : Int = 0;`
  assert_true(
    knf_block.stmts[2] is LetMut(name3, Int, init_expr3) &&
    name3 is { id: "z", .. } &&
    init_expr3 is Int(0),
  )

  // Test 4: Parse and transform `z = 42;`
  assert_true(
    knf_block.stmts[3] is Assign(name3, expr3) &&
    name3 is { id: "z", .. } &&
    expr3 is Int(42),
  )

  // Test 4: Parse and transform `print_int(z);` (ExprStmt)
  assert_true(
    knf_block.stmts[4] is ExprStmt(call_expr) &&
    call_expr is Call(func, args) &&
    func is { id: "print_int", .. } &&
    args is [arg] &&
    arg is { id: "z", .. },
  )

  // Test 5: Parse and transform `return z;` (ReturnStmt)
  assert_true(
    knf_block.stmts[5] is Return(return_expr) &&
    return_expr is Ident({ id: "z", .. }),
  )
}

///|
test "Expr Knf Transformation Test" {
  // Prelucde Parts
  // set a, b, arr, sum, point, mat, sqrt type in typecheck and knf context
  let typecheck_ctx = @typecheck.Context::new()
  let point_struct_def : @typecheck.StructDef = {
    name: "Point",
    fields: [
      { name: "x", ty: { kind: Int, mutable: false } },
      { name: "y", ty: { kind: Int, mutable: false } },
    ],
    methods: Map::new(),
  }
  typecheck_ctx.struct_defs.set("Point", point_struct_def)
  typecheck_ctx.type_env.set("a", { kind: Double, mutable: false })
  typecheck_ctx.type_env.set("b", { kind: Double, mutable: false })
  typecheck_ctx.type_env.set("arr", { kind: Array(Int), mutable: false })
  typecheck_ctx.type_env.set("point", { kind: Struct("Point"), mutable: false })
  typecheck_ctx.type_env.set("sum", {
    kind: Function([Array(Int)], Int),
    mutable: false,
  })
  typecheck_ctx.type_env.set("max", {
    kind: Function([Double, Double], Double),
    mutable: false,
  })
  typecheck_ctx.type_env.set("min", {
    kind: Function([Double, Double], Double),
    mutable: false,
  })
  let knf_ctx = @knf.Context::new()
  knf_ctx.globals.set("max", Function([Double, Double], Double))
  knf_ctx.globals.set("min", Function([Double, Double], Double))
  knf_ctx.globals.set("sum", Function([Array(Int)], Int))
  let _ = knf_ctx.add_new_name("a", Double)
  let _ = knf_ctx.add_new_name("b", Double)
  let _ = knf_ctx.add_new_name("arr", Array(Int))

  // Test Parts
  let code =
    #|max(a, b) + min(a, b) ;
    #|sum(arr) / arr.length() ;
  // Code parse, typecheck, knf transform
  let tokens = @lexer.tokenize(code)
  // Parse and transform `max(a, b) + min(a, b)`
  let (e, _) = @parser.parse_expr(tokens)
  let e = typecheck_ctx.check_expr(e)
  let (stmts, knf_expr) = knf_ctx.expr_to_knf(e)
  assert_true(
    stmts is [s1, s2] &&
    s1 is Let(n1, Double, Call({ id: "max", .. }, [a1, a2])) &&
    s2 is Let(n2, Double, Call({ id: "min", .. }, [a3, a4])) &&
    a1 is { id: "a", .. } &&
    a2 is { id: "b", .. } &&
    a3 is { id: "a", .. } &&
    a4 is { id: "b", .. } &&
    knf_expr is Binary(Add, l, r) &&
    n1 == l &&
    n2 == r,
  )
}

///|
test "If Expr Knf Transformation Test" {
  // Prelude Parts
  let typecheck_ctx = @typecheck.Context::new()
  let knf_ctx = @knf.Context::new()

  // Setup type environment for testing
  typecheck_ctx.type_env.set("x", { kind: Int, mutable: true })
  typecheck_ctx.type_env.set("y", { kind: Int, mutable: false })
  typecheck_ctx.type_env.set("print_int", {
    kind: Function([Int], Unit),
    mutable: false,
  })

  // Setup knf context
  let _ = knf_ctx.add_new_name("x", Int)
  let _ = knf_ctx.add_new_name("y", Int)
  knf_ctx.globals.set("print_int", Function([Int], Unit))

  // Test 1: Simple if-else expression: if (y > 0) { x = 10; } else { x = 20; }
  let code1 =
    #|if (y > 0) {
    #|  x = 10;
    #|} else {
    #|  x = 20;
    #|}
  let tokens1 = @lexer.tokenize(code1)
  let (if_expr1, _) = @parser.parse_if_expr(tokens1)
  let checked_if_expr1 = typecheck_ctx.check_if_expr(if_expr1)
  let (stmts1, knf_if_expr1) = knf_ctx.if_expr_to_knf(checked_if_expr1)

  // Test 1: Check that condition generates a statement for the literal 0
  assert_true(stmts1.length() is 1)
  assert_true(
    stmts1[0] is Let(tmp_name, Int, Int(0)) && tmp_name is { id: "tmp", .. },
  )

  // Test 1: Check the if expression structure
  assert_true(
    knf_if_expr1 is If(cond, then_block, else_block) &&
    cond is Binary(GT, y_name, tmp_cond) &&
    y_name is { id: "y", .. } &&
    tmp_cond is { id: "tmp", .. } &&
    then_block.stmts.length() is 1 &&
    then_block.stmts[0] is Assign(x_name1, Int(10)) &&
    x_name1 is { id: "x", .. } &&
    else_block.stmts.length() is 1 &&
    else_block.stmts[0] is Assign(x_name2, Int(20)) &&
    x_name2 is { id: "x", .. },
  )

  // Test 2: If without else: if (x < 5) { print_int(x); }
  let code2 =
    #|if (x < 5) {
    #|  print_int(x);
    #|}
  let tokens2 = @lexer.tokenize(code2)
  let (if_expr2, _) = @parser.parse_if_expr(tokens2)
  let checked_if_expr2 = typecheck_ctx.check_if_expr(if_expr2)
  let (stmts2, knf_if_expr2) = knf_ctx.if_expr_to_knf(checked_if_expr2)

  // Test 2: Check that condition generates a statement for the literal 5
  assert_true(stmts2.length() is 1)
  assert_true(
    stmts2[0] is Let(tmp_name2, Int, Int(5)) &&
    tmp_name2 is { id: "tmp", slot: 1 },
  )

  // Test 2: Check the if expression structure (no else block)
  assert_true(
    knf_if_expr2 is If(cond2, then_block2, else_block2) &&
    cond2 is Binary(LT, x_name3, tmp_cond2) &&
    x_name3 is { id: "x", .. } &&
    tmp_cond2 is { id: "tmp", slot: 1 } &&
    then_block2.stmts.length() is 1 &&
    then_block2.stmts[0] is ExprStmt(Call(print_func, [x_arg])) &&
    print_func is { id: "print_int", .. } &&
    x_arg is { id: "x", .. } &&
    else_block2.stmts.is_empty(),
  )

  // Test 3: If-else if-else chain
  let code3 =
    #|if x > 10 {
    #|  y
    #|} else if x > 5 {
    #|  y + 1
    #|} else {
    #|  y + 2
    #|}
  let tokens3 = @lexer.tokenize(code3)
  let (if_expr3, _) = @parser.parse_if_expr(tokens3)
  let checked_if_expr3 = typecheck_ctx.check_if_expr(if_expr3)
  let (stmts3, knf_if_expr3) = knf_ctx.if_expr_to_knf(checked_if_expr3)

  // Test 3: Check that condition generates a statement for the literal 10
  assert_true(stmts3.length() is 2)
  assert_true(
    stmts3 is [s1, s2] &&
    s1 is Let(_, Int, Int(10)) &&
    s2 is Let(_, Int, Int(5)),
  )
  assert_true(
    knf_if_expr3 is If(cond3, then_block3, else_block3) &&
    cond3 is Binary(GT, _, _) &&
    then_block3.stmts is [_] &&
    else_block3.stmts is [ExprStmt(e1)] &&
    e1 is If(nested_cond, _, _) &&
    nested_cond is Binary(GT, _, _),
  )
}

///|
test "Let Mut Knf Transformation Test" {
  // Prelucde Parts
  let typecheck_ctx = @typecheck.Context::new()
  let knf_ctx = @knf.Context::new()
  // Test Parts
  let code =
    #|let mut x: Int = 10;
    #|let mut a = 42.0;
    #|let mut b = 33.0;
    #|let mut y: Double = a + b;
  // Code parse, typecheck, knf transform
  let tokens = @lexer.tokenize(code)
  // Parse and transform `let mut x: Int = 10;`
  let (stmt, tok_view) = @parser.parse_let_mut_stmt(tokens)
  let stmt = typecheck_ctx.check_let_mut_stmt(stmt)
  let knf_stmts = knf_ctx.let_mut_stmt_to_knf(stmt)
  assert_true(
    knf_stmts is [s] &&
    s is LetMut(name1, Int, init_expr) &&
    name1 is { id: "x", .. } &&
    init_expr is Int(10),
  )
  // Parse and transform `let mut a = 42.0;`
  let (stmt1, tok_view) = @parser.parse_let_mut_stmt(tok_view)
  let stmt1 = typecheck_ctx.check_let_mut_stmt(stmt1)
  let knf_stmts1 = knf_ctx.let_mut_stmt_to_knf(stmt1)
  assert_true(
    knf_stmts1 is [s1] &&
    s1 is LetMut(name_a, Double, init_expr1) &&
    name_a is { id: "a", .. } &&
    init_expr1 is Double(42.0),
  )
  // Parse and transform `let mut b = 33.0;`
  let (stmt_b, tok_view) = @parser.parse_let_mut_stmt(tok_view)
  let stmt_b = typecheck_ctx.check_let_mut_stmt(stmt_b)
  let knf_stmts_b = knf_ctx.let_mut_stmt_to_knf(stmt_b)
  assert_true(
    knf_stmts_b is [s_b] &&
    s_b is LetMut(name_b, Double, init_expr_b) &&
    name_b is { id: "b", .. } &&
    init_expr_b is Double(33.0),
  )
  // Parse and transform `let mut y: Double = a + b;`
  let (stmt2, _) = @parser.parse_let_mut_stmt(tok_view)
  let stmt2 = typecheck_ctx.check_let_mut_stmt(stmt2)
  let knf_stmts2 = knf_ctx.let_mut_stmt_to_knf(stmt2)
  assert_true(
    knf_stmts2 is [s2] &&
    s2 is LetMut(name2, Double, init_expr2) &&
    name2 is { id: "y", .. } &&
    init_expr2 is Binary(Add, left, right) &&
    left is { id: "a", .. } &&
    right is { id: "b", .. },
  )
}

///|
test "Let Stmt Knf Transformation Test" {
  // Prelucde Parts
  let typecheck_ctx = @typecheck.Context::new()
  typecheck_ctx.type_env.set("print_int", {
    kind: Function([Int], Unit),
    mutable: false,
  })
  let knf_ctx = @knf.Context::new()
  knf_ctx.globals.set("print_int", Function([Int], Unit))
  // Test Parts
  let code =
    #|let x: Int = 10;
    #|let (a, b) = (42.0, 33.0);
    #|let y: Double = a + b;
    #|let _ = print_int(x);
  // Code parse, typecheck, knf transform
  let tokens = @lexer.tokenize(code)
  // Parse and transform `let x: Int = 10;`
  let (stmt, tok_view) = @parser.parse_let_stmt(tokens)
  let stmt = typecheck_ctx.check_let_stmt(stmt)
  let knf_stmts = knf_ctx.let_stmt_to_knf(stmt)
  assert_true(
    knf_stmts is [s] &&
    s is Let(name1, Int, init_expr) &&
    name1 is { id: "x", .. } &&
    init_expr is Int(10),
  )
  // Parse and transform `let (a, b) = (42.0, 33.0);`
  // It Should be transformed into 4 let statements in knf
  // 1. let tmp1: Double = 42.0;
  // 2. let tmp2: Double = 33.0;
  // 3. let a = tmp1;
  // 4. let b = tmp2;
  // Not: let tmp3 = (tmp1, tmp2); then let a = tmp1.0; let b = tmp1.1
  // Although it's correct, it's not efficient way, be cause we need
  // to create a tuple object in memory.
  //
  // Ask: Does `let a = 42.0; let b = 33.0;` better?
  // Well, you can try it. But it may not easy in knf transformation phase.
  let (stmt1, tok_view) = @parser.parse_let_stmt(tok_view)
  let stmt1 = typecheck_ctx.check_let_stmt(stmt1)
  let knf_stmts1 = knf_ctx.let_stmt_to_knf(stmt1)
  assert_true(
    knf_stmts1 is [s1, s2, s3, s4] &&
    s1 is Let(n1, Double, Double(42.0)) &&
    s2 is Let(n2, Double, Double(33.0)) &&
    s3 is Let(a, _, Ident(n1_)) &&
    s4 is Let(b, _, Ident(n2_)) &&
    n1 == n1_ &&
    n2 == n2_ &&
    a is { id: "a", .. } &&
    b is { id: "b", .. },
  )
  // Parse and transform `let y: Double = a + b;`
  let (stmt2, tok_view) = @parser.parse_let_stmt(tok_view)
  let stmt2 = typecheck_ctx.check_let_stmt(stmt2)
  let knf_stmts2 = knf_ctx.let_stmt_to_knf(stmt2)
  assert_true(
    knf_stmts2 is [s2] &&
    s2 is Let(name2, Double, init_expr2) &&
    name2 is { id: "y", .. } &&
    init_expr2 is Binary(Add, left, right) &&
    left is { id: "a", .. } &&
    right is { id: "b", .. },
  )
  // Parse and transform `let _ = print_int(y);`
  let (stmt3, _) = @parser.parse_let_stmt(tok_view)
  let stmt3 = typecheck_ctx.check_let_stmt(stmt3)
  let knf_stmts3 = knf_ctx.let_stmt_to_knf(stmt3)
  assert_true(
    knf_stmts3 is [s3] &&
    s3 is Let(_, Unit, call_expr) &&
    call_expr is Call(func, args) &&
    func is { id: "print_int", .. } &&
    args is [arg] &&
    arg is { id: "x", .. },
  )
}

///|
test "Local Function Knf Transformation Test" {
  // Prelude Parts
  let typecheck_ctx = @typecheck.Context::new()
  let knf_ctx = @knf.Context::new()

  // Setup builtin functions
  typecheck_ctx.func_types.set("print_int", Function([Int], Unit))
  typecheck_ctx.type_env.set("print_int", {
    kind: Function([Int], Unit),
    mutable: false,
  })
  // Typecheck ctx need to know about 'foo' ahead of time.
  // So that we can call `check_top_function` directly.
  typecheck_ctx.func_types.set("foo", Function([], Unit))
  knf_ctx.globals.set("print_int", Function([Int], Unit))
  let code =
    #|fn foo() -> Unit {
    #|  let x = 1;
    #|  fn bar() -> Unit {
    #|    fn baz() -> Unit {
    #|      print_int(x);
    #|    }
    #|    baz();
    #|  }
    #|  bar();
    #|}
  let tokens = @lexer.tokenize(code)
  let (top_func, _) = @parser.parse_top_function(tokens)
  let typechecked_func = typecheck_ctx.check_top_function(top_func)
  let knf_func = knf_ctx.top_function_to_knf(typechecked_func)
  assert_true(knf_func.body.stmts.length() is 3)
  // Second statement is local function 'bar'
  assert_true(
    knf_func.body.stmts[1] is ClosureDef(closure) && // closure 'bar'
    closure.captured_vars.length() is 1 && // bar captures 'x'
    closure.body.stmts is [s1, _] &&
    s1 is ClosureDef(inner_closure) && // inner closure 'baz'
    inner_closure.captured_vars.length() is 1, // baz captures 'x' from bar
  )
}

///|
test "Top Function Knf Transformation Test" {
  let code =
    #|extern "C" fn print_int(n: Int) = "print_int";
    #|let a = 3;
    #|let b = 4;
    #|fn fold(arr: Array[Int], f: (Int, Int) -> Int, initv: Int) -> Int { 
    #|  let mut result = initv;
    #|  let mut i = 0; 
    #|  while i < arr.length() {
    #|    result = f(result, arr[i]);
    #|  }
    #|  result
    #|}
    #|
    #|fn main {
    #|  fn max(a, b) { if a > b { a } else { b } }
    #|  fn min(a, b) { if a < b { a } else { b } }
    #|  let numbers = [a, 1, b, 1, 5, 9, 2, 6, 5];
    #|  let maximum = fold(numbers, max, -1000);
    #|  let minimum = fold(numbers, min, 1000);
    #|  let max_min_diff = maximum - minimum;
    #|  print_int(max_min_diff);
    #|}
  let tokens = @lexer.tokenize(code)
  let program = @parser.parse(tokens)
  let program = @typecheck.typecheck(program)
  let knf = knf_transform(program)
  assert_true(knf.top_lets.contains("a"))
  assert_true(knf.top_lets.contains("b"))
  assert_true(knf.functions.contains("fold"))
  assert_true(knf.functions.contains("main"))
  // if you call println(knf), you should see
  // the knf program like follows: 
  // ```
  // let a : Int = 3;
  // let b : Int = 4;
  // fn fold(arr: Array[Int], f: (Int, Int) -> Int, initv: Int) -> Int {
  //   let mut result : Int = initv;
  //   let mut i : Int = 0;
  //   while {let tmp : () -> Int = arr.length; let tmp$1 : Int = tmp(); i < tmp$1; } {
  //     let tmp$2 : Int = arr[i];
  //     result = f(result, tmp$2);
  //   }
  //   result;
  // }
  // fn main {
  //   fn max(a$1 : Int, b$1 : Int) -> Int {
  //     if a$1 > b$1 {
  //       a$1;
  //     } else {
  //       b$1;
  //     };
  //   }
  //   fn min(a$1 : Int, b$1 : Int) -> Int {
  //     if a$1 < b$1 {
  //       a$1;
  //     } else {
  //       b$1;
  //     };
  //   }
  //   let tmp : Int = 1;
  //   let tmp$1 : Int = 1;
  //   let tmp$2 : Int = 5;
  //   let tmp$3 : Int = 9;
  //   let tmp$4 : Int = 2;
  //   let tmp$5 : Int = 6;
  //   let tmp$6 : Int = 5;
  //   let numbers : Array[Int] = [a, tmp, b, tmp$1, tmp$2, tmp$3, tmp$4, tmp$5, tmp$6];
  //   let tmp$7 : Int = 1000;
  //   let tmp$8 : Int = -tmp$7;
  //   let maximum : Int = fold(numbers, max, tmp$8);
  //   let tmp$9 : Int = 1000;
  //   let minimum : Int = fold(numbers, min, tmp$9);
  //   let max_min_diff : Int = maximum - minimum;
  //   print_int(max_min_diff);
  // }
  // ```
}

///|
test "Simple Apply Expr Knf Transformation Test" {
  // set x, y, z type in typecheck and knf context
  let typecheck_ctx = @typecheck.Context::new()
  typecheck_ctx.type_env.set("x", { kind: Int, mutable: false })
  typecheck_ctx.type_env.set("y", { kind: Double, mutable: false })
  typecheck_ctx.type_env.set("z", { kind: Bool, mutable: false })
  let knf_ctx = Context::new()
  knf_ctx.globals.set("x", Int)
  let _ = knf_ctx.add_new_name("y", Double)
  knf_ctx.enter_scope()
  let _ = knf_ctx.add_new_name("z", Bool)

  // Code parse, typecheck, knf transform
  let code =
    #|42 3.14 true "hello"
    #|x y z
  let tokens = @lexer.tokenize(code)
  let (e, tok_view) = @parser.parse_apply_expr(tokens)
  let e = typecheck_ctx.check_apply_expr(e)
  let (_, e) = knf_ctx.apply_expr_to_knf(e)
  assert_true(e is Int(42))
  let (e, tok_view) = @parser.parse_apply_expr(tok_view)
  let e = typecheck_ctx.check_apply_expr(e)
  let (_, e) = knf_ctx.apply_expr_to_knf(e)
  assert_true(e is Double(3.14))
  let (e, tok_view) = @parser.parse_apply_expr(tok_view)
  let e = typecheck_ctx.check_apply_expr(e)
  let (_, e) = knf_ctx.apply_expr_to_knf(e)
  assert_true(e is Bool(true))
  let (e, tok_view) = @parser.parse_apply_expr(tok_view)
  let e = typecheck_ctx.check_apply_expr(e)
  let (_, e) = knf_ctx.apply_expr_to_knf(e)
  assert_true(e is String("hello"))
  // find Global Ident `x`
  let (e, tok_view) = @parser.parse_apply_expr(tok_view)
  let e = typecheck_ctx.check_apply_expr(e)
  let (_, e) = knf_ctx.apply_expr_to_knf(e)
  assert_true(e is Ident({ id: "x", slot: 0 }))
  // find Parent Ident `y`
  let (e, tok_view) = @parser.parse_apply_expr(tok_view)
  let e = typecheck_ctx.check_apply_expr(e)
  let (_, e) = knf_ctx.apply_expr_to_knf(e)
  assert_true(e is Ident({ id: "y", slot: 0 }))
  // find Local Ident `z`
  let (e, _) = @parser.parse_apply_expr(tok_view)
  let e = typecheck_ctx.check_apply_expr(e)
  let (_, e) = knf_ctx.apply_expr_to_knf(e)
  assert_true(e is Ident({ id: "z", slot: 0 }))
}

///|
test "Simple Atom Expr Knf Transformation Test" {
  // set x, y, z type in typecheck and knf context
  let typecheck_ctx = @typecheck.Context::new()
  typecheck_ctx.type_env.set("x", { kind: Int, mutable: false })
  typecheck_ctx.type_env.set("y", { kind: Double, mutable: false })
  typecheck_ctx.type_env.set("z", { kind: Bool, mutable: false })
  let knf_ctx = Context::new()
  knf_ctx.globals.set("x", Int)
  let _ = knf_ctx.add_new_name("y", Double)
  knf_ctx.enter_scope()
  let _ = knf_ctx.add_new_name("z", Bool)

  // Code parse, typecheck, knf transform
  let code =
    #|42 3.14 true "hello"
    #|x y z
  // Parse
  let tokens = @lexer.tokenize(code)
  let (e, tok_view) = @parser.parse_atom_expr(tokens)
  let e = typecheck_ctx.check_atom_expr(e)
  let (_, e) = knf_ctx.atom_expr_to_knf(e)
  assert_true(e is Int(42))
  let (e, tok_view) = @parser.parse_atom_expr(tok_view)
  let e = typecheck_ctx.check_atom_expr(e)
  let (_, e) = knf_ctx.atom_expr_to_knf(e)
  assert_true(e is Double(3.14))
  let (e, tok_view) = @parser.parse_atom_expr(tok_view)
  let e = typecheck_ctx.check_atom_expr(e)
  let (_, e) = knf_ctx.atom_expr_to_knf(e)
  assert_true(e is Bool(true))
  let (e, tok_view) = @parser.parse_atom_expr(tok_view)
  let e = typecheck_ctx.check_atom_expr(e)
  let (_, e) = knf_ctx.atom_expr_to_knf(e)
  assert_true(e is String("hello"))
  // find Global Ident `x`
  let (e, tok_view) = @parser.parse_atom_expr(tok_view)
  let e = typecheck_ctx.check_atom_expr(e)
  let (_, e) = knf_ctx.atom_expr_to_knf(e)
  assert_true(e is Ident({ id: "x", slot: 0 }))
  // find Parent Ident `y`
  let (e, tok_view) = @parser.parse_atom_expr(tok_view)
  let e = typecheck_ctx.check_atom_expr(e)
  let (_, e) = knf_ctx.atom_expr_to_knf(e)
  assert_true(e is Ident({ id: "y", slot: 0 }))
  // find Local Ident `z`
  let (e, _) = @parser.parse_atom_expr(tok_view)
  let e = typecheck_ctx.check_atom_expr(e)
  let (_, e) = knf_ctx.atom_expr_to_knf(e)
  assert_true(e is Ident({ id: "z", slot: 0 }))
}

///|
test "Simple Expr Knf Transformation Test" {
  // set x, y, z type in typecheck and knf context
  let typecheck_ctx = @typecheck.Context::new()
  typecheck_ctx.type_env.set("x", { kind: Int, mutable: false })
  typecheck_ctx.type_env.set("y", { kind: Int, mutable: false })
  typecheck_ctx.type_env.set("z", { kind: Int, mutable: false })
  typecheck_ctx.type_env.set("w", { kind: Bool, mutable: false })
  let knf_ctx = Context::new()
  knf_ctx.globals.set("x", Int)
  let _ = knf_ctx.add_new_name("y", Int)
  let _ = knf_ctx.add_new_name("w", Int)
  knf_ctx.enter_scope()
  let _ = knf_ctx.add_new_name("z", Bool)

  // Code parse, typecheck, knf transform
  let code =
    #|42;
    #|-33;
    #|!w;
    #|x + y;
    #|2.0 * 3.14;
    #|x + y * z ;
  let tokens = @lexer.tokenize(code)
  // Parse and transform `42` 
  let (e, tok_view) = @parser.parse_expr(tokens)
  let e = typecheck_ctx.check_expr(e)
  let (_, e) = knf_ctx.expr_to_knf(e)
  assert_true(e is Int(42))
  // Parse and transform `-33`
  let (e, tok_view) = @parser.parse_expr(tok_view[1:])
  let e = typecheck_ctx.check_expr(e)
  let (stmts, e) = knf_ctx.expr_to_knf(e)
  assert_true(
    stmts is [s] && s is Let(n1, Int, Int(33)) && e is Neg(n2) && n1 == n2,
  )
  // Parse and transform `!z`
  let (e, tok_view) = @parser.parse_expr(tok_view[1:])
  let e = typecheck_ctx.check_expr(e)
  let (stmts, e) = knf_ctx.expr_to_knf(e)
  assert_true(
    stmts is [s] &&
    s is Let(n1, Bool, Ident(i)) &&
    i is { id: "w", .. } &&
    e is Not(n2) &&
    n1 == n2,
  )
  // Parse and transform `x + 10`
  let (e, tok_view) = @parser.parse_expr(tok_view[1:])
  let e = typecheck_ctx.check_expr(e)
  let (stmts, e) = knf_ctx.expr_to_knf(e)
  assert_true(
    stmts is [] &&
    e is Binary(Add, n1, n2) &&
    n1 is { id: "x", .. } &&
    n2 is { id: "y", .. },
  )
  // Parse and transform `2.0 * 3.14`
  let (e, tok_view) = @parser.parse_expr(tok_view[1:])
  let e = typecheck_ctx.check_expr(e)
  let (stmts, e) = knf_ctx.expr_to_knf(e)
  assert_true(
    stmts is [s1, s2] &&
    s1 is Let(n1, Double, Double(2.0)) &&
    s2 is Let(n2, Double, Double(3.14)) &&
    e is Binary(Mul, n3, n4) &&
    n1 == n3 &&
    n2 == n4,
  )
  // Parse and transform `x + y * z`
  let (e, _) = @parser.parse_expr(tok_view[1:])
  let e = typecheck_ctx.check_expr(e)
  let (stmts, e) = knf_ctx.expr_to_knf(e)
  assert_true(
    stmts is [s] &&
    s is Let(n1, Int, Binary(Mul, n2, n3)) &&
    e is Binary(Add, n4, n5) &&
    n1 is { id: "tmp", .. } &&
    n2 is { id: "y", .. } &&
    n3 is { id: "z", .. } &&
    n4 is { id: "x", .. } &&
    n5 == n1,
  )
}

///|
//test "Stmt Knf Transformation Test - 2" {
//  // Prelude Parts
//  let typecheck_ctx = @typecheck.Context::new()
//  let knf_ctx = @knf.Context::new()
//
//  // Setup struct definition for testing
//  let point_struct_def : @typecheck.StructDef = {
//    name: "Point",
//    fields: [
//      { name: "x", ty: { kind: Int, mutable: true } },
//      { name: "y", ty: { kind: Int, mutable: true } },
//    ],
//  }
//  typecheck_ctx.struct_defs.set("Point", point_struct_def)
//
//  // Setup type environment
//  typecheck_ctx.type_env.set("x", { kind: Int, mutable: true })
//  typecheck_ctx.type_env.set("arr", { kind: Array(Int), mutable: true })
//  typecheck_ctx.type_env.set("point", { kind: Struct("Point"), mutable: false })
//
//  // Set function context for return statement
//  typecheck_ctx.current_func_ret_ty = Some(Unit)
//
//  // Setup knf context
//  let _ = knf_ctx.add_new_name("x", Int)
//  let _ = knf_ctx.add_new_name("arr", Array(Int))
//  let _ = knf_ctx.add_new_name("point", Struct("Point"))
//
//  // Test Parts
//  let code =
//    #|let (a, b) = (10, 20);
//    #|x += 5;
//    #|arr[0] = 42;
//    #|point.x = 100;
//    #|return;
//
//  // Code parse, typecheck, knf transform
//  let tokens = @lexer.tokenize(code)
//
//  // Test 1: Parse and transform `let (a, b) = (10, 20);` (tuple pattern)
//  let (stmt, tok_view) = @parser.parse_stmt(tokens)
//  let stmt = typecheck_ctx.check_stmt(stmt)
//  let knf_stmts = knf_ctx.stmt_to_knf(stmt)
//  assert_true(
//    knf_stmts is [s1, s2, s3, s4] &&
//    s1 is Let(n1, Int, Int(10)) &&
//    s2 is Let(n2, Int, Int(20)) &&
//    s3 is Let(a, _, Ident(n1_)) &&
//    s4 is Let(b, _, Ident(n2_)) &&
//    n1 == n1_ &&
//    n2 == n2_ &&
//    a is { id: "a", .. } &&
//    b is { id: "b", .. },
//  )
//
//  // Test 2: Parse and transform `x += 5;` (compound assignment)
//  let (stmt, tok_view) = @parser.parse_stmt(tok_view)
//  let stmt = typecheck_ctx.check_stmt(stmt)
//  let knf_stmts = knf_ctx.stmt_to_knf(stmt)
//  assert_true(
//    knf_stmts is [s1, s2, s3] &&
//    s1 is Let(_, Int, Int(5)) &&
//    s2 is Let(_, Int, Binary(Add, _, _)) &&
//    s3 is Assign(name, Ident(_)) &&
//    name is { id: "x", .. },
//  )
//
//  // Test 3: Parse and transform `arr[0] = 42;` (array assignment)
//  let (stmt, tok_view) = @parser.parse_stmt(tok_view)
//  let stmt = typecheck_ctx.check_stmt(stmt)
//  let knf_stmts = knf_ctx.stmt_to_knf(stmt)
//  assert_true(
//    knf_stmts is [s1, s2] &&
//    s1 is Let(n1, Int, Int(0)) &&
//    s2 is ArrayPut(array_name, idx_name, Int(42)) &&
//    n1 == idx_name &&
//    array_name is { id: "arr", .. },
//  )
//
//  // Test 4: Parse and transform `point.x = 100;` (struct field assignment)
//  let (stmt, tok_view) = @parser.parse_stmt(tok_view)
//  let stmt = typecheck_ctx.check_stmt(stmt)
//  let knf_stmts = knf_ctx.stmt_to_knf(stmt)
//  assert_true(
//    knf_stmts is [s1, s2] &&
//    s1 is Let(n1, Int, Int(100)) &&
//    s2 is StructFieldSet(_, "x", value_name) &&
//    n1 == value_name,
//  )
//
//  // Test 5: Parse and transform `return;` (return without value)
//  let (stmt, _) = @parser.parse_stmt(tok_view)
//  let stmt = typecheck_ctx.check_stmt(stmt)
//  let knf_stmts = knf_ctx.stmt_to_knf(stmt)
//  assert_true(knf_stmts is [s] && s is ReturnUnit)
//}

test "Stmt Knf Transformation Test" {
  // Prelude Parts
  let typecheck_ctx = @typecheck.Context::new()
  let knf_ctx = @knf.Context::new()

  // Setup struct definition for testing
  let point_struct_def : @typecheck.StructDef = {
    name: "Point",
    fields: [
      { name: "x", ty: { kind: Int, mutable: true } },
      { name: "y", ty: { kind: Int, mutable: true } },
    ],
    methods: Map::new(),
  }
  typecheck_ctx.struct_defs.set("Point", point_struct_def)

  // Set function context for return statement
  typecheck_ctx.current_func_ret_ty = Some(Struct("Point"))
  let code =
    #|let mut p = Point::{ x: 0, y: 0 };
    #|let mut a = 100;
    #|let (b, c) = (200, 300);
    #|let arr = [a, b, c];
    #|a *= 50;
    #|p.x += b + c;
    #|arr[1] = a - 25;
    #|return p;

  // Code parse, typecheck, knf transform
  let tokens = @lexer.tokenize(code)

  // Test 1: Parse and transform `let mut p = Point::{ mut x: 0, y: 0 };`
  let (stmt, tok_view) = @parser.parse_stmt(tokens)
  let stmt = typecheck_ctx.check_stmt(stmt)
  let knf_stmts = knf_ctx.stmt_to_knf(stmt)
  assert_true(
    knf_stmts is [s1, s2, s3] &&
    s1 is Let(_, Int, Int(0)) &&
    s2 is Let(_, Int, Int(0)) &&
    s3 is LetMut(name, Struct("Point"), CreateStruct("Point", fields)) &&
    name is { id: "p", .. } &&
    fields is [field1, field2] &&
    field1 is ("x", _) &&
    field2 is ("y", _),
  )

  // Test 2: Parse and transform `let mut a = 100;`
  let (stmt, tok_view) = @parser.parse_stmt(tok_view)
  let stmt = typecheck_ctx.check_stmt(stmt)
  let knf_stmts = knf_ctx.stmt_to_knf(stmt)
  assert_true(
    knf_stmts is [s] &&
    s is LetMut(name, Int, Int(100)) &&
    name is { id: "a", .. },
  )

  // Test 3: Parse and transform `let (b, c) = (200, 300);`
  let (stmt, tok_view) = @parser.parse_stmt(tok_view)
  let stmt = typecheck_ctx.check_stmt(stmt)
  let knf_stmts = knf_ctx.stmt_to_knf(stmt)
  assert_true(
    knf_stmts is [s1, s2, s3, s4] &&
    s1 is Let(n1, Int, Int(200)) &&
    s2 is Let(n2, Int, Int(300)) &&
    s3 is Let(b, _, Ident(n1_)) &&
    s4 is Let(c, _, Ident(n2_)) &&
    n1 == n1_ &&
    n2 == n2_ &&
    b is { id: "b", .. } &&
    c is { id: "c", .. },
  )

  // Test 4: Parse and transform `let arr = [a, b, c];`
  let (stmt, tok_view) = @parser.parse_stmt(tok_view)
  let stmt = typecheck_ctx.check_stmt(stmt)
  let knf_stmts = knf_ctx.stmt_to_knf(stmt)
  assert_true(
    knf_stmts is [s] &&
    s is Let(name, Array(Int), ArrayLiteral(_, elements)) &&
    name is { id: "arr", .. } &&
    elements is [elem1, elem2, elem3] &&
    elem1 is { id: "a", .. } &&
    elem2 is { id: "b", .. } &&
    elem3 is { id: "c", .. },
  )

  // Test 5: Parse and transform `a *= 50;`
  let (stmt, tok_view) = @parser.parse_stmt(tok_view)
  let stmt = typecheck_ctx.check_stmt(stmt)
  let knf_stmts = knf_ctx.stmt_to_knf(stmt)
  assert_true(
    knf_stmts is [s1, s2, s3] &&
    s1 is Let(_, Int, Int(50)) &&
    s2 is Let(_, Int, Binary(Mul, _, _)) &&
    s3 is Assign(name, Ident(_)) &&
    name is { id: "a", .. },
  )

  // Test 6: Parse and transform `p.x += b + c;`
  let (stmt, tok_view) = @parser.parse_stmt(tok_view)
  let stmt = typecheck_ctx.check_stmt(stmt)
  let knf_stmts = knf_ctx.stmt_to_knf(stmt)
  assert_true(
    knf_stmts is [s1, s2, s3, s4, s5] &&
    s1 is Let(n1, Int, FieldAccess(_, "x")) &&
    s2 is Let(n2, Int, Binary(Add, { id: "b", .. }, { id: "c", .. })) &&
    s3 is Let(n3, Int, Binary(Add, n1_, n2_)) &&
    s4 is Let(n4, Int, Ident(n3_)) &&
    s5 is StructFieldSet(_, "x", n4_) &&
    n1 == n1_ &&
    n2 == n2_ &&
    n3 == n3_ &&
    n4 == n4_,
  )

  // Test 7: Parse and transform `arr[1] = a - 25;`
  let (stmt, tok_view) = @parser.parse_stmt(tok_view)
  let stmt = typecheck_ctx.check_stmt(stmt)
  let knf_stmts = knf_ctx.stmt_to_knf(stmt)
  assert_true(
    knf_stmts is [s1, s2, s3] &&
    s1 is Let(_, Int, Int(1)) &&
    s2 is Let(_, Int, Int(25)) &&
    s3 is ArrayPut(_),
  )

  // Test 8: Parse and transform `return p;`
  let (stmt, _) = @parser.parse_stmt(tok_view)
  let stmt = typecheck_ctx.check_stmt(stmt)
  let knf_stmts = knf_ctx.stmt_to_knf(stmt)
  assert_true(
    knf_stmts is [s] &&
    s is Return(return_expr) &&
    return_expr is Ident({ id: "p", .. }),
  )
}

///|
test "Struct Def Knf Transformation Test" {
  // Prelude Parts
  let typecheck_ctx = @typecheck.Context::new()
  let knf_ctx = @knf.Context::new()

  // Put all code together
  let code =
    #|struct Point {
    #|  x: Int;
    #|  y: Int;
    #|}
    #|struct Person {
    #|  name: String;
    #|  age: Int;
    #|  mut score: Double;
    #|}
    #|struct Empty {}
  let tokens = @lexer.tokenize(code)

  // Test 1: Simple struct with two immutable fields
  let (struct_def1, tok_view) = @parser.parse_struct_def(tokens)
  let checked_struct_def1 = typecheck_ctx.check_struct_def(struct_def1)
  let knf_struct_def1 = knf_ctx.struct_def_to_knf(checked_struct_def1)
  assert_true(knf_struct_def1.name == "Point")
  assert_true(knf_struct_def1.fields.length() is 2)
  assert_true(
    knf_struct_def1.fields[0] is (field_name1, is_mut1, field_type1) &&
    field_name1 == "x" &&
    is_mut1 == false &&
    field_type1 is Int,
  )
  assert_true(
    knf_struct_def1.fields[1] is (field_name2, is_mut2, field_type2) &&
    field_name2 == "y" &&
    is_mut2 == false &&
    field_type2 is Int,
  )

  // Test 2: Struct with mutable field
  let (struct_def2, tok_view) = @parser.parse_struct_def(tok_view)
  let checked_struct_def2 = typecheck_ctx.check_struct_def(struct_def2)
  let knf_struct_def2 = knf_ctx.struct_def_to_knf(checked_struct_def2)
  assert_true(knf_struct_def2.name == "Person")
  assert_true(knf_struct_def2.fields.length() is 3)
  assert_true(
    knf_struct_def2.fields[0] is (field_name3, is_mut3, field_type3) &&
    field_name3 == "name" &&
    is_mut3 == false &&
    field_type3 is String,
  )
  assert_true(
    knf_struct_def2.fields[1] is (field_name4, is_mut4, field_type4) &&
    field_name4 == "age" &&
    is_mut4 == false &&
    field_type4 is Int,
  )
  assert_true(
    knf_struct_def2.fields[2] is (field_name5, is_mut5, field_type5) &&
    field_name5 == "score" &&
    is_mut5 == true &&
    field_type5 is Double,
  )

  // Test 3: Empty struct
  let (struct_def3, _) = @parser.parse_struct_def(tok_view)
  let checked_struct_def3 = typecheck_ctx.check_struct_def(struct_def3)
  let knf_struct_def3 = knf_ctx.struct_def_to_knf(checked_struct_def3)
  assert_true(knf_struct_def3.name == "Empty")
  assert_true(knf_struct_def3.fields.is_empty())
}

///|
test "Top Function Knf Transformation Test - 2" {
  // Prelude Parts
  let typecheck_ctx = @typecheck.Context::new()
  let knf_ctx = @knf.Context::new()

  // Setup builtin functions
  typecheck_ctx.func_types.set("print_int", Function([Int], Unit))
  typecheck_ctx.type_env.set("print_int", {
    kind: Function([Int], Unit),
    mutable: false,
  })
  knf_ctx.globals.set("print_int", Function([Int], Unit))
  let code =
    #|fn add(x: Int, y: Int) -> Int {
    #|  return x + y;
    #|}
    #|fn greet(name: String) -> Unit {
    #|  return ();
    #|}
    #|fn fib(n: Int) -> Int {
    #|  if n <= 1 {
    #|    return n;
    #|  } else {
    #|    return fib(n - 1) + fib(n - 2);
    #|  }
    #|}
    #|fn compute(a: Int, b: Int, c: Int) -> Int {
    #|  let sum = a + b;
    #|  let result = sum * c;
    #|  return result;
    #|}

  // Register function signatures first
  typecheck_ctx.func_types.set("add", Function([Int, Int], Int))
  typecheck_ctx.type_env.set("add", {
    kind: Function([Int, Int], Int),
    mutable: false,
  })
  typecheck_ctx.func_types.set("greet", Function([String], Unit))
  typecheck_ctx.type_env.set("greet", {
    kind: Function([String], Unit),
    mutable: false,
  })
  typecheck_ctx.func_types.set("fib", Function([Int], Int))
  typecheck_ctx.type_env.set("fib", {
    kind: Function([Int], Int),
    mutable: false,
  })
  typecheck_ctx.func_types.set("compute", Function([Int, Int, Int], Int))
  typecheck_ctx.type_env.set("compute", {
    kind: Function([Int, Int, Int], Int),
    mutable: false,
  })
  let tokens = @lexer.tokenize(code)

  // Test 1: Simple function with two parameters and return
  let (top_func1, tok_view) = @parser.parse_top_function(tokens)
  let checked_func1 = typecheck_ctx.check_top_function(top_func1)
  let knf_func1 = knf_ctx.top_function_to_knf(checked_func1)
  assert_true(knf_func1.name == "add")
  assert_true(knf_func1.ret_ty is Int)
  assert_true(knf_func1.params.length() is 2)
  assert_true(
    knf_func1.params[0] is (param_name1, param_type1) &&
    param_name1 is { id: "x", slot: 0 } &&
    param_type1 is Int,
  )
  assert_true(
    knf_func1.params[1] is (param_name2, param_type2) &&
    param_name2 is { id: "y", slot: 0 } &&
    param_type2 is Int,
  )
  // Body should have: return x + y;
  assert_true(knf_func1.body.stmts.length() is 1)
  assert_true(
    knf_func1.body.stmts is [s] &&
    s is Return(Binary(Add, x_name, y_name)) &&
    x_name is { id: "x", .. } &&
    y_name is { id: "y", .. },
  )

  // Test 2: Function with String parameter returning Unit
  let (top_func2, tok_view) = @parser.parse_top_function(tok_view)
  let checked_func2 = typecheck_ctx.check_top_function(top_func2)
  let knf_func2 = knf_ctx.top_function_to_knf(checked_func2)
  assert_true(knf_func2.name == "greet")
  assert_true(knf_func2.ret_ty is Unit)
  assert_true(knf_func2.params.length() is 1)
  assert_true(
    knf_func2.params is [(param_name3, param_type3)] &&
    param_name3 is { id: "name", slot: 0 } &&
    param_type3 is String,
  )
  // Body should have: return ();
  assert_true(knf_func2.body.stmts.length() is 1)
  assert_true(knf_func2.body.stmts[0] is ReturnUnit)

  // Test 3: Recursive function with if expression
  let (top_func3, tok_view) = @parser.parse_top_function(tok_view)
  let checked_func3 = typecheck_ctx.check_top_function(top_func3)
  let knf_func3 = knf_ctx.top_function_to_knf(checked_func3)
  assert_true(knf_func3.name == "fib")
  assert_true(knf_func3.ret_ty is Int)
  assert_true(knf_func3.params.length() is 1)
  assert_true(
    knf_func3.params[0] is (param_name4, param_type4) &&
    param_name4 is { id: "n", slot: 0 } &&
    param_type4 is Int,
  )
  // Body should contain if expression and recursive calls
  // We don't need to verify the exact structure, just that it's transformed
  assert_true(knf_func3.body.stmts.length() > 0)

  // Test 4: Function with multiple statements in body
  let (top_func4, _) = @parser.parse_top_function(tok_view)
  let checked_func4 = typecheck_ctx.check_top_function(top_func4)
  let knf_func4 = knf_ctx.top_function_to_knf(checked_func4)
  assert_true(knf_func4.name == "compute")
  assert_true(knf_func4.ret_ty is Int)
  assert_true(knf_func4.params.length() is 3)
  // Body should have: let sum = a + b; let result = sum * c; return result;
  assert_true(knf_func4.body.stmts.length() is 3)
  assert_true(
    knf_func4.body.stmts[0] is Let(sum_name, Int, Binary(Add, a_name, b_name)) &&
    sum_name is { id: "sum", .. } &&
    a_name is { id: "a", .. } &&
    b_name is { id: "b", .. },
  )
  assert_true(
    knf_func4.body.stmts[1]
    is Let(result_name, Int, Binary(Mul, sum_name2, c_name)) &&
    result_name is { id: "result", .. } &&
    sum_name2 is { id: "sum", .. } &&
    c_name is { id: "c", .. },
  )
  assert_true(
    knf_func4.body.stmts[2] is Return(Ident(result_name2)) &&
    result_name2 is { id: "result", .. },
  )
}

///|
test "Top Let Knf Transformation Test" {
  // Prelude Parts
  let typecheck_ctx = @typecheck.Context::new()
  let knf_ctx = @knf.Context::new()

  // Test 1: Simple top-level let with type annotation: let x: Int = 42;
  let code =
    #|let x: Int = 42;
    #|let y = 3.14;
    #|let s: String = "hello";
    #|let a = 1;
    #|let b = 2;
    #|let sum = a + b;
  let tokens1 = @lexer.tokenize(code)
  // Test 1: Check the structure
  let (top_let1, tok_view) = @parser.parse_top_let(tokens1)
  let checked_top_let1 = typecheck_ctx.check_top_let(top_let1)
  let knf_top_let1 = knf_ctx.top_let_to_knf(checked_top_let1)
  assert_true(
    knf_top_let1.name is { id: "x", slot: 0 } &&
    knf_top_let1.ty is Int &&
    knf_top_let1.expr is Int(42),
  )

  // Test 2: Check the structure
  let (top_let2, tok_view) = @parser.parse_top_let(tok_view)
  let checked_top_let2 = typecheck_ctx.check_top_let(top_let2)
  let knf_top_let2 = knf_ctx.top_let_to_knf(checked_top_let2)
  assert_true(
    knf_top_let2.name is { id: "y", slot: 0 } &&
    knf_top_let2.ty is Double &&
    knf_top_let2.expr is Double(3.14),
  )

  // Test 3: Top-level let with string: let s: String = "hello";
  let (top_let3, tok_view) = @parser.parse_top_let(tok_view)
  let checked_top_let3 = typecheck_ctx.check_top_let(top_let3)
  let knf_top_let3 = knf_ctx.top_let_to_knf(checked_top_let3)

  // Test 3: Check the structure
  assert_true(
    knf_top_let3.name is { id: "s", slot: 0 } &&
    knf_top_let3.ty is String &&
    knf_top_let3.expr is String("hello"),
  )

  // Test 4: Top-level let with computation: let sum = 10 + 20;
  let (top_let, tok_view) = @parser.parse_top_let(tok_view)
  let checked_top_let4 = typecheck_ctx.check_top_let(top_let)
  let _ = knf_ctx.top_let_to_knf(checked_top_let4)
  let (top_let, tok_view) = @parser.parse_top_let(tok_view)
  let checked_top_let4 = typecheck_ctx.check_top_let(top_let)
  let _ = knf_ctx.top_let_to_knf(checked_top_let4)
  let (top_let4, _) = @parser.parse_top_let(tok_view)
  let checked_top_let4 = typecheck_ctx.check_top_let(top_let4)
  let knf_top_let4 = knf_ctx.top_let_to_knf(checked_top_let4)
  assert_true(
    knf_top_let4.name is { id: "sum", slot: 0 } &&
    knf_top_let4.ty is Int &&
    knf_top_let4.expr is Binary(Add, l, r) &&
    l is { id: "a", .. } &&
    r is { id: "b", .. },
  )
}

///|
test "Type Knf Transformation Test" {
  let typecheck_ctx = @typecheck.Context::new()
  let knf_ctx = Context::new()
  let code =
    #|Int Unit Bool Double String Array[Int]
    #|(Int, Double, Bool)
    #|(Int, Int) -> Bool
    #|(Array[Double]) -> String
  // Parse
  let tokens = @lexer.tokenize(code)
  let (t, tok_view) = @parser.parse_type(tokens)
  let t = typecheck_ctx.check_parser_type(t)
  let t = knf_ctx.type_to_knf(t)
  assert_true(t is Int)
  let (t, tok_view) = @parser.parse_type(tok_view)
  let t = typecheck_ctx.check_parser_type(t)
  let t = knf_ctx.type_to_knf(t)
  assert_true(t is Unit)
  let (t, tok_view) = @parser.parse_type(tok_view)
  let t = typecheck_ctx.check_parser_type(t)
  let t = knf_ctx.type_to_knf(t)
  assert_true(t is Bool)
  let (t, tok_view) = @parser.parse_type(tok_view)
  let t = typecheck_ctx.check_parser_type(t)
  let t = knf_ctx.type_to_knf(t)
  assert_true(t is Double)
  let (t, tok_view) = @parser.parse_type(tok_view)
  let t = typecheck_ctx.check_parser_type(t)
  let t = knf_ctx.type_to_knf(t)
  assert_true(t is String)
  let (t, tok_view) = @parser.parse_type(tok_view)
  let t = typecheck_ctx.check_parser_type(t)
  let t = knf_ctx.type_to_knf(t)
  assert_true(t is Array(Int))
  let (t, tok_view) = @parser.parse_type(tok_view)
  let t = typecheck_ctx.check_parser_type(t)
  let t = knf_ctx.type_to_knf(t)
  assert_true(t is Tuple([Int, Double, Bool]))
  let (t, tok_view) = @parser.parse_type(tok_view)
  let t = typecheck_ctx.check_parser_type(t)
  let t = knf_ctx.type_to_knf(t)
  assert_true(t is Function([Int, Int], Bool))
  let (t, _) = @parser.parse_type(tok_view)
  let t = typecheck_ctx.check_parser_type(t)
  let t = knf_ctx.type_to_knf(t)
  assert_true(t is Function([Array(Double)], String))
}

///|
test "While Stmt Knf Transformation Test" {
  // Prelude Parts
  let typecheck_ctx = @typecheck.Context::new()
  let knf_ctx = @knf.Context::new()

  // Setup type environment for testing
  typecheck_ctx.type_env.set("i", { kind: Int, mutable: true })
  typecheck_ctx.type_env.set("sum", { kind: Int, mutable: true })
  typecheck_ctx.type_env.set("x", { kind: Int, mutable: true })
  typecheck_ctx.type_env.set("print_int", {
    kind: Function([Int], Unit),
    mutable: false,
  })

  // Setup knf context
  let _ = knf_ctx.add_new_name("i", Int)
  let _ = knf_ctx.add_new_name("sum", Int)
  let _ = knf_ctx.add_new_name("x", Int)
  knf_ctx.globals.set("print_int", Function([Int], Unit))

  // Test 1: Simple while loop: while (i < 10) { sum = sum + i; i = i + 1; }
  let code1 =
    #|while (i < 10) {
    #|  sum = sum + i;
    #|  i = i + 1;
    #|}
  let tokens1 = @lexer.tokenize(code1)
  let (while_stmt1, _) = @parser.parse_while_stmt(tokens1)
  let checked_while_stmt1 = typecheck_ctx.check_while_stmt(while_stmt1)
  let knf_while_stmts1 = knf_ctx.while_stmt_to_knf(checked_while_stmt1)

  // Test 1: Check that we get a While statement
  assert_true(knf_while_stmts1.length() is 1)
  assert_true(knf_while_stmts1[0] is While(_, _))
  guard knf_while_stmts1[0] is While(cond_block, body_block)

  // Test 1: Check condition block (should have let for 10 and the condition expression)
  // Condition block should have: let tmp = 10; and i < tmp;
  assert_true(cond_block.stmts.length() is 2)
  assert_true(
    cond_block.stmts[0] is Let(tmp_name, Int, Int(10)) &&
    tmp_name is { id: "tmp", slot: 0 },
  )
  assert_true(
    cond_block.stmts[1] is ExprStmt(Binary(LT, i_name, tmp_cond)) &&
    i_name is { id: "i", .. } &&
    tmp_cond is { id: "tmp", slot: 0 },
  )

  // Body block should have:
  // 1. sum = sum + i; (no expansion needed, operands are identifiers)
  // 2. let tmp$1 : Int = 1; (extract literal)
  // 3. i = i + tmp$1; (assignment)
  assert_true(body_block.stmts.length() is 3)
  assert_true(
    body_block.stmts[0] is Assign(sum_name, Binary(Add, sum_name2, i_name2)) &&
    sum_name is { id: "sum", .. } &&
    sum_name2 is { id: "sum", .. } &&
    i_name2 is { id: "i", .. },
  )
  assert_true(
    body_block.stmts[1] is Let(tmp_lit, Int, Int(1)) &&
    tmp_lit is { id: "tmp", slot: 1 },
  )
  assert_true(
    body_block.stmts[2] is Assign(i_name3, Binary(Add, i_name4, tmp_add)) &&
    i_name3 is { id: "i", .. } &&
    i_name4 is { id: "i", .. } &&
    tmp_add is { id: "tmp", slot: 1 },
  )

  // Test 2: While with function call: while (x > 0) { print_int(x); x = x - 1; }
  let code2 =
    #|while (x > 0) {
    #|  print_int(x);
    #|  x = x - 1;
    #|}
  let tokens2 = @lexer.tokenize(code2)
  let (while_stmt2, _) = @parser.parse_while_stmt(tokens2)
  let checked_while_stmt2 = typecheck_ctx.check_while_stmt(while_stmt2)
  let knf_while_stmts2 = knf_ctx.while_stmt_to_knf(checked_while_stmt2)
  assert_true(knf_while_stmts2.length() is 1)
  guard knf_while_stmts2[0] is While(cond_block, body_block)

  // Test 2: Check structure
  // Condition block: let tmp = 0; x > tmp;
  assert_true(cond_block.stmts.length() is 2)
  assert_true(
    cond_block.stmts[0] is Let(_, Int, Int(0)) &&
    cond_block.stmts[1] is ExprStmt(Binary(GT, _, _)),
  )

  // Body block: print_int(x); x = x - 1;
  // Similar to test 1: print_int(x); let tmp = 1; x = x - tmp;
  assert_true(body_block.stmts.length() is 3)
  assert_true(body_block.stmts[0] is ExprStmt(Call(_, _)))
  assert_true(body_block.stmts[1] is Let(_, Int, Int(1)))
  assert_true(body_block.stmts[2] is Assign(_, Binary(Sub, _, _)))
}
