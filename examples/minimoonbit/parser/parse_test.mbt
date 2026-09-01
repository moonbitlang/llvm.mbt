/// ================================================================================
/// # 方括号的集结：解析数组字面量
///
/// 我们已经成功处理了圆括号 `()` 的多种情况。现在，让我们来挑战另一种常见的括号：
/// 方括号 `[]`，它在 MiniMoonBit 中用于定义**数组字面量（Array Literals）**。
///
/// ## 数组字面量
///
/// 数组字面量允许我们直接在代码中定义一个包含多个元素的数组，例如：
/// `[1, 2, 3]` 或 `["hello", "world"]`。
///
/// 它的结构与我们之前解析的元组（Tuple）非常相似：由一对括号包裹，内部是逗号分隔的表达式列表。
///
/// ## 🎯 你的任务：在 `parse_atom_expr` 中处理 `[]`
///
/// 我们的目标是在 `atom_expr.mbt` 中，通过一个新的辅助函数 `parse_array_expr`
/// 来实现对数组字面量的解析。`parse_atom_expr` 将在遇到 `[` 时调用这个新函数。
///
/// **实现思路：**
///
/// 好消息是，这部分逻辑与我们之前实现的 `parse_paren_expr` 高度相似！
///
/// 1.  **入口：** 当 `parse_atom_expr` 遇到 `[` 时，它应该将解析工作委托给 `parse_array_expr`。
///
/// 2.  **`parse_array_expr` 的逻辑：**
///     *   首先，跳过开头的 `[`。
///     *   进入一个循环，用 `parse_expr` 解析由逗号分隔的表达式列表。
///     *   循环直到遇到结尾的 `]`。
///     *   将所有解析出的 `Expr` 收集到一个 `Array` 中。
///     *   使用这个 `Array[Expr]` 来构造一个 `AtomExprKind::Array` 节点。
///
/// ## 🤔 深入思考：逗号的艺术
///
/// 既然数组和元组的解析如此相似，那么关于逗号的边界情况也值得我们再次思考。
/// 对于一个健壮且用户友好的语言来说，以下情况是否应该被接受？
///
/// *   **尾随逗号：** `[1, 2, 3,]`
/// *   **开头逗号：** `[, 1, 2, 3]`
/// *   **连续逗号：** `[1, , 2, 3]`
/// *   **多个尾随逗号：** `[1, 2, 3, ,]`
///
/// 你的 `parse_paren_expr` 的实现可能已经处理了其中一部分情况。
/// 在实现 `parse_array_expr` 时，你可以考虑是否需要一个更通用的、可以被两者复用的列表解析函数，
/// 以确保语言在不同语法结构中行为的一致性。
///
/// **阶段性测试：**
///
/// 完成后，运行以下命令来检验你的实现：
///
/// ```bash
/// moon test -p parser -f parse_array_expr_test.mbt
/// ```
///
/// **祝你顺利！通过代码复用，我们可以让编译器变得更加优雅和健壮。**
/// ================================================================================

///|
test "Array Expr Parsing Test" {
  let code =
    #|[42, 3.14, true]
    #|[foo, bar, baz]
    #|[ 1 + 3]
  let tokens = @lexer.tokenize(code)
  let (a, tok_view) = parse_atom_expr(tokens[:])
  assert_true(
    a.kind is AtomExprKind::Array(exprs) &&
    exprs is [e1, e2, e3] &&
    e1.kind is ApplyExpr(app1) &&
    app1.kind is AtomExpr(atom1) &&
    atom1.kind is Int(42) &&
    e2.kind is ApplyExpr(app2) &&
    app2.kind is AtomExpr(atom2) &&
    atom2.kind is Double(3.14) &&
    e3.kind is ApplyExpr(app3) &&
    app3.kind is AtomExpr(atom3) &&
    atom3.kind is Bool(true),
  )
  let (a, tok_view) = parse_atom_expr(tok_view)
  assert_true(
    a.kind is AtomExprKind::Array(exprs) &&
    exprs is [e1, e2, e3] &&
    e1.kind is ApplyExpr(app1) &&
    app1.kind is AtomExpr(atom1) &&
    atom1.kind is Ident("foo") &&
    e2.kind is ApplyExpr(app2) &&
    app2.kind is AtomExpr(atom2) &&
    atom2.kind is Ident("bar") &&
    e3.kind is ApplyExpr(app3) &&
    app3.kind is AtomExpr(atom3) &&
    atom3.kind is Ident("baz"),
  )
  let (a, _) = parse_atom_expr(tok_view)
  assert_true(
    a.kind is AtomExprKind::Array(exprs) &&
    exprs is [e1] &&
    e1.kind is BinaryExpr(Add, left, right) &&
    left.kind is ApplyExpr(app1) &&
    app1.kind is AtomExpr(atom1) &&
    atom1.kind is Int(1) &&
    right.kind is ApplyExpr(app2) &&
    app2.kind is AtomExpr(atom2) &&
    atom2.kind is Int(3),
  )
}
/// ================================================================================
/// # 编译器“开洞”：解析特殊的 `Array::make` 语法
///
/// 在设计一门语言时，有时我们会遇到一些无法通过通用语法规则优雅表达的结构。
/// 这时，编译器开发者会选择“开一个洞”，为这种特殊情况编写专门的解析逻辑。
///
/// `Array::make(size, init)` 就是 MiniMoonBit 中的一个典型例子。
/// 它看起来像一个函数调用，但实际上是一种特殊的、内置于语言核心的数组创建语法。
/// 你可以把它类比于 C 语言中的 `int arr[n];`，这同样不是一个普通的函数调用，
/// 而是需要编译器特殊处理的语法结构。
///
/// ## 🎯 你的任务：在 `parse_atom_expr` 中处理 `Array::make`
///
/// 我们的目标是在 `atom_expr.mbt` 中，通过一个新的辅助函数 `parse_array_make_expr`
/// 来实现对这个特殊语法的解析。`parse_atom_expr` 将在遇到 `Array` 关键字时调用这个新函数。
///
/// **实现思路：**
///
/// 1.  **入口：** 当 `parse_atom_expr` 遇到 `Array` 这个 `Upper` 类型的 Token 时，
///     它应该将解析工作委托给 `parse_array_make_expr`。
///
/// 2.  **`parse_array_make_expr` 的逻辑：**
///     *   这个函数需要进行一次精确的“模式匹配”，确保接下来的 Token 序列是 `::`，`make`，和 `(`。
///       如果不是，那么这可能是一个普通的以 `Array` 开头的类型名，应该立即报错或交由其他逻辑处理（在我们的例子中，直接报错）。
///     *   跳过 `Array::make(` 这一固定序列。
///     *   调用 `parse_expr` 来解析数组的**大小（size）**。
///     *   确保下一个 Token 是一个逗号 `,`，并跳过它。
///     *   再次调用 `parse_expr` 来解析数组的**初始值（init）**。
///     *   确保最后一个 Token 是一个右括号 `)`，并跳过它。
///     *   最后，将解析出的 `size` 和 `init` 两个表达式组装成一个 `ArrayMake` 节点。
///
/// 这种为特定语法“开洞”的做法，在真实的编译器中非常常见，它体现了语言设计在一致性与实用性之间的权衡。
///
/// **阶段性测试：**
///
/// 完成后，运行以下命令来检验你的实现：
///
/// ```bash
/// moon test -p parser -f parse_array_make_test.mbt
/// ```
///
/// **祝你顺利！你正在学习编译器开发中非常实用的一个技巧！**
/// ================================================================================

///|
test "Array Make Expr Parsing Test" {
  let code =
    #|Array::make(10, 0)
    #|Array::make(5, true)
  let tokens = @lexer.tokenize(code)
  let (a, tok_view) = parse_atom_expr(tokens[:])
  assert_true(
    a.kind is AtomExprKind::ArrayMake(size_expr, init_expr) &&
    size_expr.kind is ApplyExpr(app1) &&
    app1.kind is AtomExpr(atom1) &&
    atom1.kind is Int(10) &&
    init_expr.kind is ApplyExpr(app2) &&
    app2.kind is AtomExpr(atom2) &&
    atom2.kind is Int(0),
  )
  let (a, _) = parse_atom_expr(tok_view)
  assert_true(
    a.kind is AtomExprKind::ArrayMake(size_expr, init_expr) &&
    size_expr.kind is ApplyExpr(app1) &&
    app1.kind is AtomExpr(atom1) &&
    atom1.kind is Int(5) &&
    init_expr.kind is ApplyExpr(app2) &&
    app2.kind is AtomExpr(atom2) &&
    atom2.kind is Bool(true),
  )
}
/// ================================================================================
/// # 组装！解析赋值语句
///
/// 万事俱备！我们已经分别实现了 `left_value` 和 `expr` 的解析器。
/// 现在，是时候将它们组装起来，完成**赋值语句（Assignment Statement）**的解析了。
///
/// ## 赋值语句的 EBNF 范式
///
/// 让我们再次回顾一下赋值语句的结构：
///
/// ```
/// assign_stmt ::= left_value assign_op expr ";"
/// ```
///
/// ## 🎯 你的任务：实现 `parse_assign_stmt`
///
/// 你的任务是在 `parser/assign_stmt.mbt` 中实现 `parse_assign_stmt` 函数。
///
/// 这个任务非常直接，它完美地体现了递归下降解析器的“组合”思想：
///
/// 1.  **解析左值：** 首先，调用你刚刚完成的 `parse_left_value` 函数来解析赋值符号左边的部分。
/// 2.  **解析赋值符号：** 接着，匹配一个赋值操作符（`=`、`+=` 等）。
/// 3.  **解析右值：** 然后，调用我们强大的 `parse_expr` 函数来解析赋值符号右边的表达式。
/// 4.  **结尾：** 最后，确保语句以分号 `;` 结尾。
///
/// 你看，我们之前所有的努力，都是为了在这一刻能够轻松地将各个部分组合在一起。
///
/// 加油，解析器的语句部分即将完成！
///
/// **阶段性测试：**
///
/// ```bash
/// moon test -p parser -f parse_assign_stmt_test.mbt
/// ```
/// ================================================================================

///|
test "Assign Stmt Parsing Test" {
  let code =
    #|obj.field1 = 42 ;
    #|matrix[1][2] += 3.14 ;
    #|arr[3][5].field -= arr[0][0] ;
    #|x *= 10 ;
    #|y /= 2 ;
    #|z %= 5 ;
  let tokens = @lexer.tokenize(code)
  let (a, tok_view) = parse_assign_stmt(tokens[:])
  assert_true(
    a.left_value.kind is FieldAccess(field_access, field_name) &&
    field_name is "field1" &&
    field_access.kind is Ident("obj") &&
    a.op is Assign &&
    a.expr.kind is ApplyExpr(expr_app) &&
    expr_app.kind is AtomExpr(expr_atom) &&
    expr_atom.kind is Int(42),
  )
  let (a, tok_view) = parse_assign_stmt(tok_view)
  assert_true(
    a.left_value.kind is ArrayAccess(array_access2, index_expr2) &&
    index_expr2.kind is ApplyExpr(index_app2) &&
    index_app2.kind is AtomExpr(index_atom2) &&
    index_atom2.kind is Int(2) &&
    array_access2.kind is ArrayAccess(array_access1, index_expr1) &&
    index_expr1.kind is ApplyExpr(index_app1) &&
    index_app1.kind is AtomExpr(index_atom1) &&
    index_atom1.kind is Int(1) &&
    array_access1.kind is Ident("matrix") &&
    a.op is PlusAssign &&
    a.expr.kind is ApplyExpr(expr_app2) &&
    expr_app2.kind is AtomExpr(expr_atom2) &&
    expr_atom2.kind is Double(3.14),
  )
  let (a, tok_view) = parse_assign_stmt(tok_view)
  assert_true(
    a.left_value.kind is FieldAccess(field_access2, field_name2) &&
    field_name2 is "field" &&
    field_access2.kind is ArrayAccess(array_access3, index_expr3) &&
    index_expr3.kind is ApplyExpr(index_app3) &&
    index_app3.kind is AtomExpr(index_atom3) &&
    index_atom3.kind is Int(5) &&
    array_access3.kind is ArrayAccess(array_access4, index_expr4) &&
    index_expr4.kind is ApplyExpr(index_app4) &&
    index_app4.kind is AtomExpr(index_atom4) &&
    index_atom4.kind is Int(3) &&
    array_access4.kind is Ident("arr") &&
    a.op is MinusAssign &&
    a.expr.kind is ApplyExpr(expr_app3) &&
    expr_app3.kind is ArrayAccess(expr_array_access, expr_index_expr) &&
    expr_index_expr.kind is ApplyExpr(expr_index_app) &&
    expr_index_app.kind is AtomExpr(expr_index_atom) &&
    expr_index_atom.kind is Int(0) &&
    expr_array_access.kind is ArrayAccess(expr_array_access2, expr_index_expr2) &&
    expr_index_expr2.kind is ApplyExpr(expr_index_app2) &&
    expr_index_app2.kind is AtomExpr(expr_index_atom2) &&
    expr_index_atom2.kind is Int(0) &&
    expr_array_access2.kind is AtomExpr(expr_array_atom) &&
    expr_array_atom.kind is Ident("arr"),
  )
  let (a, _) = parse_assign_stmt(tok_view)
  assert_true(
    a.left_value.kind is Ident("x") &&
    a.op is MultAssign &&
    a.expr.kind is ApplyExpr(expr_app4) &&
    expr_app4.kind is AtomExpr(expr_atom4) &&
    expr_atom4.kind is Int(10),
  )
}
/// ================================================================================
/// # 代码块的力量：解析 BlockExpr
///
/// 我们已经可以解析独立的语句了。现在，我们要将它们组织到一个非常重要的结构中：
/// **代码块表达式（Block Expression）**。
///
/// 在 MiniMoonBit 中，代码块由 `{}` 包裹，它本身也是一个表达式，其值是块内最后一条表达式的值。
///
/// ## BlockExpr 的 EBNF 范式
///
/// ```
/// block_expr ::= "{" stmt* expr? "}"
/// ```
///
/// 这段范式告诉我们，一个代码块包含：
/// 1.  一个起始的 `{"{"`。
/// 2.  零条或多条（`*`）以分号结尾的语句（`stmt`）。
/// 3.  可选地（`?`），最后可以有一条不带分号的表达式（`expr`），它的值就是整个块的值。
/// 4.  一个终结的 `"}"`。
///
/// ## 🎯 你的任务：实现 `parse_block_expr`
///
/// 你的任务是在 `parser/block_expr.mbt` 中实现 `parse_block_expr` 函数。
///
/// **实现思路：**
///
/// 1.  匹配并跳过开头的 `{"{"`。
/// 2.  进入一个循环，反复调用 `parse_stmt` 来解析块内的每一条语句。
/// 3.  循环直到遇到 `"}"` 为止。
/// 4.  匹配并跳过结尾的 `"}"`。
///
/// ### 🤔 一个棘手的问题：如何处理最后一条“不带分号”的表达式？
///
/// EBNF 中的 `expr?` 是整个解析过程中的一个难点。
/// `let x = { let y = 1; y + 1 }` 是合法的，最后的 `y + 1` 没有分号。
///
/// 这意味着，当我们的 `parse_stmt` 在解析一个可能是 `expr_stmt` 的语句时，
/// 它不能再固执地要求结尾必须是 `;` 了。
///
/// **💡 提示：**
///
/// 解决这个问题的关键在于**修改 `parse_stmt` 函数**。
///
/// 当 `parse_stmt` 解析完一个 `expr_stmt` 后，它需要检查下一个 Token：
/// *   如果 Token 是 `;`，那么消耗它，语句结束。
/// *   如果 Token 是 `}`，那么说明这已经是块的结尾了，**不消耗它**，直接将 `expr_stmt` 返回。
/// *   如果是其他 Token，则应该报错。
///
/// 通过在 `parse_stmt` 中增加对 `}` 的“宽容”，`parse_block_expr` 的实现就可以保持非常简单。
///
/// **阶段性测试：**
///
/// ```bash
/// moon test -p parser -f parse_block_expr_test.mbt
/// ```
/// ================================================================================

///|
test "Block Expr Parsing" {
  let code =
    #|{
    #|  let x = 10;
    #|  let mut y = 20;
    #|  y = y + x;
    #|  let t = Array::make(5, 0);
    #|  t[0] = y;
    #|}
  let tokens = @lexer.tokenize(code)
  let (block, _) = parse_block_expr(tokens)
  assert_true(block.stmts.length() is 5)
  assert_true(block.stmts[0].kind is LetStmt(_))
  assert_true(block.stmts[1].kind is LetMutStmt(_))
  assert_true(block.stmts[2].kind is AssignStmt(_))
  assert_true(block.stmts[3].kind is LetStmt(_))
  assert_true(block.stmts[4].kind is AssignStmt(_))
}

///|
test "Complex Apply Expr Parsing Test" {
  let code =
    #|obj.field1[0].method(a1, b2) ;
    #|matrix[1][2].to_string() ;
    #|arr[3](5)[7]
  let tokens = @lexer.tokenize(code)
  let (a, tok_view) = parse_apply_expr(tokens[:])
  assert_true(
    a.kind is Call(call_expr, [a1, a2]) &&
    a1.kind is ApplyExpr(arg1) &&
    arg1.kind is AtomExpr(atom_a1) &&
    atom_a1.kind is Ident("a1") &&
    a2.kind is ApplyExpr(arg2) &&
    arg2.kind is AtomExpr(atom_b2) &&
    atom_b2.kind is Ident("b2") &&
    call_expr.kind is FieldAccess(field_access2, field_name2) &&
    field_name2 is "method" &&
    field_access2.kind is ArrayAccess(array_access, index_expr) &&
    index_expr.kind is ApplyExpr(index_apply) &&
    index_apply.kind is AtomExpr(index_atom) &&
    index_atom.kind is Int(0) &&
    array_access.kind is FieldAccess(field_access, field_name) &&
    field_name is "field1" &&
    field_access.kind is AtomExpr(atom_obj) &&
    atom_obj.kind is Ident("obj"),
  )
  let (a, tok_view) = parse_apply_expr(tok_view[1:])
  assert_true(
    a.kind is Call(call_expr2, []) &&
    call_expr2.kind is FieldAccess(field_access4, field_name4) &&
    field_name4 is "to_string" &&
    field_access4.kind is ArrayAccess(array_access2, index_expr2) &&
    index_expr2.kind is ApplyExpr(index_apply2) &&
    index_apply2.kind is AtomExpr(index_atom2) &&
    index_atom2.kind is Int(2) &&
    array_access2.kind is ArrayAccess(array_access1, index_expr1) &&
    index_expr1.kind is ApplyExpr(index_apply1) &&
    index_apply1.kind is AtomExpr(index_atom1) &&
    index_atom1.kind is Int(1) &&
    array_access1.kind is AtomExpr(atom_matrix) &&
    atom_matrix.kind is Ident("matrix"),
  )
  let (a, _) = parse_apply_expr(tok_view[1:])
  assert_true(
    a.kind is ArrayAccess(array_access3, index_expr3) &&
    index_expr3.kind is ApplyExpr(index_apply3) &&
    index_apply3.kind is AtomExpr(index_atom3) &&
    index_atom3.kind is Int(7) &&
    array_access3.kind is Call(call_expr3, [arg_expr]) &&
    arg_expr.kind is ApplyExpr(arg_apply) &&
    arg_apply.kind is AtomExpr(arg_atom) &&
    arg_atom.kind is Int(5) &&
    call_expr3.kind is ArrayAccess(array_access4, index_expr4) &&
    index_expr4.kind is ApplyExpr(index_apply4) &&
    index_apply4.kind is AtomExpr(index_atom4) &&
    index_atom4.kind is Int(3) &&
    array_access4.kind is AtomExpr(atom_arr) &&
    atom_arr.kind is Ident("arr"),
  )
}
/// ================================================================================
/// # 表达式解析的最终章：组合一切
///
/// 恭喜你！你已经分别构建了 `ApplyExpr`、`IfExpr`、`BlockExpr` 以及处理一元和二元操作的各种逻辑。
/// 现在，我们来到了表达式解析的最后一站：将所有这些部分在 `parse_expr` 函数中完美地组合起来。
///
/// ## 表达式的“分诊台”
///
/// `parse_expr` 函数就像一个急诊室的分诊台。当一串 Token 到来时，它需要快速判断这属于哪种“病例”，
/// 然后将其分发给对应的“专科医生”（也就是我们之前写的各个子解析器）。
///
/// ## 🎯 你的任务：完善 `parse_expr`
///
/// 你的任务是最后一次修改 `parser/expr.mbt` 中的 `parse_expr` 函数，使其能够处理所有类型的表达式。
///
/// **实现思路：**
///
/// 1.  **特殊情况优先：**
///     *   首先，检查开头的 Token 是否是 `if` 或 `{`。如果是，那么整个表达式就是一个 `IfExpr` 或 `BlockExpr`，
///       直接调用对应的 `parse_if_expr` 或 `parse_block_expr` 函数，然后返回结果。
///     *   接着，检查开头是否是一元操作符（`!` 或 `-`）。如果是，按照我们之前实现的一元操作逻辑进行解析。
///
/// 2.  **默认情况：**
///     *   如果以上情况都不匹配，那么它必然是一个以 `ApplyExpr` 开头的表达式，
///       后面可能跟着一系列的二元操作符（例如 `a + b * c`）。
///     *   在这种情况下，执行我们为二元操作符实现的、包含优先级处理的“调度场”算法。
///
/// 通过这种“特殊情况优先，一般情况置后”的策略，你就可以将所有独立的解析逻辑优雅地整合在一起。
///
/// **阶段性测试：**
///
/// 这个测试文件包含了一些将不同表达式（如 `if` 和二元操作）组合在一起的复杂场景，
/// 是对你最终 `parse_expr` 函数的终极考验。
///
/// ```bash
/// moon test -p parser -f parse_complex_expr_test.mbt
/// ```
///
/// **祝贺你！完成这一步，你的表达式解析器就真正大功告成了！** 🏆
/// ================================================================================

///|
test "Complex Expr Parsing Test" {
  let code =
    #|(if a > b { a; } else { b; }) + (if c < d { c; } else { d; }) ;
  let tokens = @lexer.tokenize(code)
  let (e, _) = parse_expr(tokens)
  assert_true(
    e.kind is BinaryExpr(Add, l, r) &&
    l.kind is ApplyExpr(a1) &&
    a1.kind is AtomExpr(a1) &&
    a1.kind is Paren(a1) &&
    a1.kind is IfExpr(_) &&
    r.kind is ApplyExpr(a2) &&
    a2.kind is AtomExpr(a2) &&
    a2.kind is Paren(a2) &&
    a2.kind is IfExpr(_),
  )
}
/// ================================================================================
/// # 控制流：解析 if-else 表达式
///
/// 我们已经可以解析线性的语句流了。现在，让我们来为语言引入第一个真正的**控制流**结构：
/// **if-else 表达式**。
///
/// 在 MiniMoonBit 中，`if-else` 和代码块一样，也是一个表达式，它可以有返回值。
///
/// ## if-else 的 EBNF 范式
///
/// ```
/// if_expr ::= "if" expr block_expr ("else" (if_expr | block_expr))?
/// ```
///
/// 这段范式揭示了一个 `if-else` 结构最有趣的部分：
/// 1.  以 `if` 关键字开头，后跟一个条件 `expr` 和一个 `then` 分支的 `block_expr`。
/// 2.  `else` 部分是可选的。
/// 3.  如果存在 `else`，它后面可以跟着另一个 `if_expr`（这就构成了 `else if` 链），或者一个最终的 `block_expr`。
///
/// ## 🎯 你的任务：实现 `parse_if_expr`
///
/// 你的任务是在 `parser/if_expr.mbt` 中实现 `parse_if_expr` 函数。
///
/// **实现思路：**
///
/// 1.  解析 `if`、条件表达式和 `then` 代码块。这部分非常直接。
/// 2.  检查 `then` 块后面是否有 `else` 关键字。
/// 3.  如果有 `else`，你需要再次向后看一个 Token：
///     *   如果 `else` 后面跟着 `if`，那么这是一个 `else if`，你应该**递归地调用 `parse_if_expr`** 来解析这个链式结构。
///     *   如果 `else` 后面跟着 `{`，那么这是一个最终的 `else` 分支，你应该调用 `parse_block_expr` 来解析它。
///
/// ### 💡 数据结构提示：`Either`
///
/// `else` 分支既可能是 `if_expr`，也可能是 `block_expr`。如何在一个字段里表示这两种可能性呢？
///
/// MoonBit 标准库中的 `Either[A, B]` 类型是为此场景量身定做的。
/// 它可以存放两种类型的值之一：`Left(A)` 或 `Right(B)`。
///
/// 在 `if_expr.mbt` 中，`else_block` 字段的类型 `Either[IfExpr, BlockExpr]?` 就运用了这个思想，
/// 你可以利用它来优雅地存储 `else` 分支的两种可能性。
///
/// 相信这个挑战对你来说已经不难了。加油！
///
/// **阶段性测试：**
///
/// ```bash
/// moon test -p parser -f parse_if_expr_test.mbt
/// ```
/// ================================================================================

///|
test "Parse If Expr Test" {
  let code =
    #|if a < b { return a; }
    #|if a < b { return a; } else { return b; }
    #|if a > b { a; } else if a == b { 0; } else { b; }
  let tokens = @lexer.tokenize(code)
  let (if_expr1, tok_view) = parse_if_expr(tokens[:])
  assert_true(if_expr1.then_block.stmts.length() is 1)
  assert_true(if_expr1.else_block is None)
  let (if_expr2, tok_view) = parse_if_expr(tok_view)
  assert_true(if_expr2.then_block.stmts.length() is 1)
  assert_true(if_expr2.else_block is Some(else_block) && else_block is Right(_))
  let (if_expr3, _) = parse_if_expr(tok_view)
  assert_true(if_expr3.then_block.stmts.length() is 1)
  assert_true(
    if_expr3.else_block is Some(else_block) &&
    else_block is Left(else_if) &&
    else_if.then_block.stmts.length() is 1 &&
    else_if.else_block is Some(else_block2) &&
    else_block2 is Right(_),
  )
}
/// ================================================================================
/// # 赋值的左侧：解析 LeftValue
///
/// 我们即将开始解析赋值语句（Assignment Statement），这是命令式编程的核心之一。
/// 在 `let` 语句中，我们是“声明并绑定”；而在赋值语句中，我们是“修改一个已存在的值”。
///
/// ## 赋值语句与 LeftValue
///
/// 赋值语句的结构如下：
///
/// ```
/// assign_stmt ::= left_value assign_op expr ";"
/// ```
///
/// 这里的 `assign_op` 包括 `=`、`+=` 等。
///
/// 关键在于 `left_value`（左值）。什么是左值？简单来说，就是**可以被放在赋值符号左边的东西**。
/// 并不是所有的表达式都可以是左值。例如，你可以写 `x = 1`，但不能写 `x + 1 = 2`。
///
/// 在 MiniMoonBit 中，合法的左值包括：
/// 1.  **变量：** `x`
/// 2.  **数组元素：** `arr[i]`
/// 3.  **结构体字段：** `obj.field`
/// 4.  **以及它们的组合：** `obj.arr[i].field`
///
/// ## 🎯 你的任务：实现 `parse_left_value`
///
/// 在解析完整的赋值语句之前，我们需要先在 `parser/left_value.mbt` 中实现 `parse_left_value` 函数，
/// 专门用于解析赋值符号左边的部分。
///
/// **实现思路：**
///
/// 仔细观察左值的构成，你会发现它和我们之前实现的 `ApplyExpr` 非常相似！
///
/// `ApplyExpr` 是 `atom_expr` 后面跟着一系列的 `(...)`、`[...]` 或 `.ident`。
/// 而 `LeftValue` 是一个 `ident` 后面跟着一系列的 `[...]` 或 `.ident`。
///
/// 它就像一个简化版的 `ApplyExpr` 解析器：
/// 1.  **起点：** `LeftValue` 必须以一个标识符（`ident`）开始。
/// 2.  **循环：** 在解析出标识符后，进入一个循环，向后检查是否存在 `[` 或 `.`。
/// 3.  **组合：** 如果存在，就解析对应的数组索引或字段访问，并用它**包裹**住之前解析出的 `LeftValue`，形成一个新的 `LeftValue`。
/// 4.  **结束：** 循环直到后面再也没有 `[` 或 `.` 为止。
///
/// 相信这个过程对你来说已经非常熟悉了。加油！
///
/// **阶段性测试：**
///
/// ```bash
/// moon test -p parser -f parse_left_value_test.mbt
/// ```
/// ================================================================================

///|
test "LeftValue Parsing Test" {
  let code =
    #|obj.field1[0] ;
    #|matrix[1][2] ;
    #|arr[3][5].field
  let tokens = @lexer.tokenize(code)
  let (a, tok_view) = parse_left_value(tokens[:])
  assert_true(
    a.kind is ArrayAccess(array_access, index_expr) &&
    index_expr.kind is ApplyExpr(index_app) &&
    index_app.kind is AtomExpr(index_atom) &&
    index_atom.kind is Int(0) &&
    array_access.kind is FieldAccess(field_access, field_name) &&
    field_name is "field1" &&
    field_access.kind is Ident("obj"),
  )
  let (a, tok_view) = parse_left_value(tok_view[1:])
  assert_true(
    a.kind is ArrayAccess(array_access2, index_expr2) &&
    index_expr2.kind is ApplyExpr(index_app2) &&
    index_app2.kind is AtomExpr(index_atom2) &&
    index_atom2.kind is Int(2) &&
    array_access2.kind is ArrayAccess(array_access1, index_expr1) &&
    index_expr1.kind is ApplyExpr(index_app1) &&
    index_app1.kind is AtomExpr(index_atom1) &&
    index_atom1.kind is Int(1) &&
    array_access1.kind is Ident("matrix"),
  )
  let (a, _) = parse_left_value(tok_view[1:])
  assert_true(
    a.kind is FieldAccess(field_access2, field_name2) &&
    field_name2 is "field" &&
    field_access2.kind is ArrayAccess(array_access3, index_expr3) &&
    index_expr3.kind is ApplyExpr(index_app3) &&
    index_app3.kind is AtomExpr(index_atom3) &&
    index_atom3.kind is Int(5) &&
    array_access3.kind is ArrayAccess(array_access4, index_expr4) &&
    index_expr4.kind is ApplyExpr(index_app4) &&
    index_app4.kind is AtomExpr(index_atom4) &&
    index_atom4.kind is Int(3) &&
    array_access4.kind is Ident("arr"),
  )
}
/// ================================================================================
/// # 可变变量：解析 let mut 语句
///
/// 我们已经可以解析不可变的 `let` 绑定了。现在，我们来处理它的“兄弟”：
/// `let mut` 语句，它用于声明一个**可变变量**。
///
/// ## `let mut` 语句的 EBNF 范式
///
/// `let mut` 语句的结构与 `let` 非常相似，但有一个关键区别：
///
/// ```
/// let_mut_stmt ::= "let" "mut" ident (":" type)? "=" expr ";"
/// ```
///
/// **⚠️ 请务必注意：**
/// `let mut` 的左边只能是一个**单一的标识符（`ident`）**，而**不是**像 `let` 那样可以是复杂的模式（`pattern`）。
/// 这是 MiniMoonBit 的一个设计选择，意味着你不能写 `let mut (a, b) = ...` 这样的代码。
///
/// ## 🎯 你的任务：实现 `parse_let_mut_stmt`
///
/// 你的任务是在 `parser/let_mut_stmt.mbt` 中实现 `parse_let_mut_stmt` 函数。
///
/// 这个任务的流程与 `parse_let_stmt` 高度一致，你只需要：
/// 1.  匹配 `let mut` 这两个连续的关键字。
/// 2.  确保后面跟着的是一个 `Lower` 类型的 Token 作为标识符。
/// 3.  其余部分（可选的类型、`=`、表达式和 `;`）的解析与 `let` 语句完全相同。
///
/// 相信这对你来说已经非常简单了。加油！
///
/// **阶段性测试：**
///
/// ```bash
/// moon test -p parser -f parse_let_mut_stmt_test.mbt
/// ```
/// ================================================================================

///|
test "Let Mut Stmt Parsing Test" {
  let code =
    #|let mut x : Int = 42;
    #|let mut y = 100;
    #|let mut z : (Int, Double) = (1, 2.0);
  let tokens = @lexer.tokenize(code)
  let (s, tok_view) = parse_let_mut_stmt(tokens)
  assert_true(
    s.name is "x" &&
    s.ty is Some(ty) &&
    ty.kind is Int &&
    s.expr.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Int(42),
  )
  let (s, tok_view) = parse_let_mut_stmt(tok_view)
  assert_true(
    s.name is "y" &&
    s.ty is None &&
    s.expr.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Int(100),
  )
  let (s, _) = parse_let_mut_stmt(tok_view)
  assert_true(
    s.name is "z" &&
    s.ty is Some(ty) &&
    ty.kind is Tuple(tys) &&
    tys is [ty1, ty2] &&
    ty1 is Int &&
    ty2 is Double &&
    s.expr.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Tuple(es) &&
    es is [e1, e2] &&
    e1.kind is ApplyExpr(a1) &&
    a1.kind is AtomExpr(atom1) &&
    atom1.kind is Int(1) &&
    e2.kind is ApplyExpr(a2) &&
    a2.kind is AtomExpr(atom2) &&
    atom2.kind is Double(2.0),
  )
}
/// ================================================================================
/// # 语句的基石：解析 let 语句
///
/// 我们已经掌握了 MiniMoonBit 中所有表达式、类型和模式的解析方法。
/// 现在，是时候将它们组合起来，开始解析**语句（Statements）**了！
///
/// `let` 语句是 MiniMoonBit 中最核心的语句，用于将一个表达式的值绑定到一个模式上。
///
/// ## `let` 语句的 EBNF 范式
///
/// `let` 语句的结构可以用 EBNF（扩展巴科斯-瑙尔范式）清晰地描述：
///
/// ```
/// let_stmt ::= "let" pattern (":" type)? "=" expr ";"
/// ```
///
/// 这段范式告诉我们：
/// 1.  一个 `let` 语句以 `let` 关键字开头。
/// 2.  后面跟着一个我们已经会解析的 `pattern`。
/// 3.  可选地（`?` 表示 0 次或 1 次），可以有一个冒号 `:` 和一个 `type`。
/// 4.  接着是一个必须有的等号 `=` 和一个 `expr`。
/// 5.  最后必须以分号 `;` 结尾。
///
/// ## 🎯 你的任务：实现 `parse_let_stmt`
///
/// 你的任务是在 `parser/let_stmt.mbt` 中实现 `parse_let_stmt` 函数。
///
/// 相信对于已经身经百战的你来说，这个任务已经没有什么难度了。
/// 你只需要严格按照 EBNF 范式描述的顺序，依次调用我们已经写好的
/// `parse_pattern`, `parse_type`, 和 `parse_expr` 函数，并正确处理分隔符（`:`、`=`、`;`）即可。
///
/// 加油，这是我们通向完整程序解析的倒数第二步！🎉
///
/// **阶段性测试：**
///
/// ```bash
/// moon test -p parser -f parse_let_stmt_test.mbt
/// ```
/// ================================================================================

///|
test "Let Stmt Parsing Test" {
  let code =
    #|let x : Int = 42;
    #|let (a, b) = (1, 2);
    #|let _ = println();
    #|let (_, (p, q)) = (r, s);
  let tokens = @lexer.tokenize(code)
  let (s, tok_view) = parse_let_stmt(tokens)
  assert_true(
    s.pattern.kind is Ident("x") &&
    s.ty is Some(ty) &&
    ty.kind is Int &&
    s.expr.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Int(42),
  )
  let (s, tok_view) = parse_let_stmt(tok_view)
  assert_true(
    s.pattern.kind is Tuple(ps) &&
    ps is [p1, p2] &&
    p1.kind is Ident("a") &&
    p2.kind is Ident("b") &&
    s.ty is None &&
    s.expr.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Tuple(es) &&
    es is [e1, e2] &&
    e1.kind is ApplyExpr(a1) &&
    a1.kind is AtomExpr(atom1) &&
    atom1.kind is Int(1) &&
    e2.kind is ApplyExpr(a2) &&
    a2.kind is AtomExpr(atom2) &&
    atom2.kind is Int(2),
  )
  let (s, tok_view) = parse_let_stmt(tok_view)
  assert_true(
    s.pattern.kind is Wildcard &&
    s.ty is None &&
    s.expr.kind is ApplyExpr(a) &&
    a.kind is Call(callee, []) &&
    callee.kind is AtomExpr(atom) &&
    atom.kind is Ident("println"),
  )
  let (s, _) = parse_let_stmt(tok_view)
  assert_true(
    s.pattern.kind is Tuple(ps) &&
    ps is [p1, p2] &&
    p1.kind is Wildcard &&
    p2.kind is Tuple(ps2) &&
    ps2 is [p21, p22] &&
    p21.kind is Ident("p") &&
    p22.kind is Ident("q") &&
    s.ty is None &&
    s.expr.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Tuple(es) &&
    es is [e1, e2] &&
    e1.kind is ApplyExpr(a1) &&
    a1.kind is AtomExpr(atom1) &&
    atom1.kind is Ident("r") &&
    e2.kind is ApplyExpr(a2) &&
    a2.kind is AtomExpr(atom2) &&
    atom2.kind is Ident("s"),
  )
}
/// ================================================================================
/// # 函数作为一等公民：解析局部函数与闭包
///
/// 在现代编程语言中，函数不仅仅是顶层的代码组织单元，它们还可以被定义在其他函数内部，
/// 甚至可以作为值被传递和返回。这种可以“捕获”其定义时所在环境（即访问外部变量）的内部函数，
/// 就是我们常说的**闭包（Closure）**。
///
/// MiniMoonBit 支持在代码块中定义**局部函数（Local Function）**，这是实现闭包的第一步。
///
/// ## 局部函数的 EBNF 范式
///
/// ```
/// fn_decl ::= "fn" ident "(" (param ("," param)*)? ")" ("->" type)? block_expr
/// param   ::= ident (":" type)?
/// ```
///
/// 这段范式描述了函数声明的各个部分：
/// 1.  `fn` 关键字和函数名 `ident`。
/// 2.  `()` 包裹的参数列表，参数之间用 `,` 分隔。
/// 3.  每个参数 `param` 包含一个名字 `ident` 和一个可选的类型注解。
/// 4.  一个可选的 `->` 和返回类型 `type`。
/// 5.  一个函数体 `block_expr`。
///
/// ## 🎯 你的任务：实现 `parse_local_function`
///
/// 你的任务是在 `parser/local_function.mbt` 中实现 `parse_local_function` 函数。
///
/// **实现思路：**
///
/// 解析函数的结构非常清晰，你可以严格按照 EBNF 的顺序进行：
/// 1.  解析 `fn` 关键字和函数名。
/// 2.  解析 `()` 包裹的参数列表。这部分是一个循环，你需要解析逗号分隔的 `ident` 和可选的类型。
/// 3.  解析可选的返回类型。
/// 4.  调用 `parse_block_expr` 解析函数体。
///
/// 经过了前面一系列的训练，这个任务对你来说应该已经驾轻就熟了。
///
/// 加油，这是我们向着一个功能更完备的语言迈出的重要一步！
///
/// **阶段性测试：**
///
/// ```bash
/// moon test -p parser -f parse_local_function_test.mbt
/// ```
/// ================================================================================

///|
test "Local Function Parsing Test - 1" {
  let code =
    #|fn add(x, y) -> Int {
    #|  x + y;
    #|}
  let tokens = @lexer.tokenize(code)
  let (func, _) = parse_local_function(tokens)
  assert_true(func.fname is "add")
  assert_true(func.param_list.length() is 2)
  assert_true(func.param_list[0] is ("x", None))
  assert_true(func.param_list[1] is ("y", None))
  assert_true(func.ret_ty is Some({ kind: Int, .. }))
  assert_true(func.body.stmts.length() is 1)
  assert_true(func.body.stmts[0].kind is ExprStmt(_))
}

///|
test "Local Function Parsing Test - 2" {
  let code =
    #|fn sin_max(x: Double, y) {
    #|  let sinx = sin(x);
    #|  let siny = sin(y);
    #|  if sinx > siny {
    #|    sinx;
    #|  } else {
    #|    siny;
    #|  };
    #|}
  let tokens = @lexer.tokenize(code)
  let (func, _) = parse_local_function(tokens)
  assert_true(func.fname is "sin_max")
  assert_true(func.param_list.length() is 2)
  assert_true(func.param_list[0] is ("x", Some({ kind: Double, .. })))
  assert_true(func.param_list[1] is ("y", None))
  assert_true(func.ret_ty is None)
  assert_true(func.body.stmts.length() is 3)
  assert_true(func.body.stmts[0].kind is LetStmt(_))
  assert_true(func.body.stmts[1].kind is LetStmt(_))
  assert_true(func.body.stmts[2].kind is ExprStmt(_))
}
/// ================================================================================
/// # 括号的魔法：分组、元组和单元类型
///
/// 我们已经能够解析复杂的二元表达式了，但还有一个关键的语法结构没有处理：**括号 `()`**。
/// 在 MiniMoonBit（以及许多其他语言）中，括号扮演着多种角色，我们的解析器必须能够准确地识别它们。
///
/// ## 括号的三种身份
///
/// 1.  **分组（Grouping）：** `(1 + 2) * 3`
///     *   括号可以用来强制改变运算的优先级。在这种情况下，括号内只包含**一个**表达式。
///
/// 2.  **元组（Tuple）：** `(1, "hello", true)`
///     *   当括号内包含由逗号分隔的**多个**表达式时，它就构成了一个元组。
///
/// 3.  **单元类型（Unit）：** `()`
///     *   当括号内**没有任何内容**时，它代表一个特殊的值和类型：`Unit`。
///
/// ## 🎯 你的任务：在 `parse_atom_expr` 中处理括号
///
/// 我们的目标是在 `atom_expr.mbt` 中，通过一个新的辅助函数 `parse_paren_expr` 来实现对这三种情况的解析。
/// `parse_atom_expr` 将在遇到 `(` 时调用这个新函数。
///
/// **实现思路：**
///
/// 1.  **入口：** 当 `parse_atom_expr` 遇到 `(` 时，它应该将解析工作委托给 `parse_paren_expr`。
///
/// 2.  **`parse_paren_expr` 的逻辑：**
///     *   首先，跳过开头的 `(`。
///     *   然后，进入一个循环，开始解析内部的表达式。这里可以递归地调用 `parse_expr`。
///     *   每解析完一个表达式后，你需要检查下一个 Token：
///         *   如果是 `)`，那么括号内的内容解析完毕，可以结束循环了。
///         *   如果是 `,`，那么说明后面可能还有另一个表达式，你需要跳过这个逗号，继续下一次循环。
///
/// 3.  **区分三种情况：**
///     *   循环结束后，检查你解析出了多少个表达式：
///         *   **0 个：** 这是一个 `Unit`。
///         *   **1 个：** 这是一个分组表达式 `Paren(Expr)`。
///         *   **多个：** 这是一个 `Tuple(Array[Expr])`。
///
/// 4.  最后，别忘了跳过结尾的 `)`。
///
/// ## 🤔 深入思考：尾随逗号（Trailing Commas）
///
/// 在设计解析器时，我们需要考虑一些边界情况。许多现代语言允许在列表或元组的末尾有一个尾随的逗号。
///
/// *   `(1, 2, 3,)` 应该是合法的吗？
/// *   如果允许一个尾随逗号，那么 `(1, 2, 3,,)` 这种包含多个尾随逗号的情况又该如何处理呢？
///
/// 在你的实现中，可以思考一下如何优雅地处理这些情况。一个健壮的解析器通常会允许一个尾随逗号，但会拒绝多个。
///
/// **阶段性测试：**
///
/// 完成后，运行以下命令来检验你的实现：
///
/// ```bash
/// moon test -p parser -f parse_paren_expr_test.mbt
/// ```
///
/// **祝你顺利！解析器对语言的理解正在变得越来越精细！**
/// ================================================================================

///|
test "Tuple, Paren and Unit Expr Parisng Test " {
  let code =
    #|(42, 3.14, true)
    #|(foo)
    #|((3.15, false))
    #|()
    #|((), ())
  let tokens = @lexer.tokenize(code)
  let (a, tok_view) = parse_atom_expr(tokens[:])
  assert_true(
    a.kind is Tuple(tup) &&
    tup is [e1, e2, e3] &&
    e1.kind is ApplyExpr(app1) &&
    app1.kind is AtomExpr(atom1) &&
    atom1.kind is Int(42) &&
    e2.kind is ApplyExpr(app2) &&
    app2.kind is AtomExpr(atom2) &&
    atom2.kind is Double(3.14) &&
    e3.kind is ApplyExpr(app3) &&
    app3.kind is AtomExpr(atom3) &&
    atom3.kind is Bool(true),
  )
  let (a, tok_view) = parse_atom_expr(tok_view)
  assert_true(
    a.kind is Paren(expr) &&
    expr.kind is ApplyExpr(app) &&
    app.kind is AtomExpr(atom) &&
    atom.kind is Ident("foo"),
  )
  let (a, tok_view) = parse_atom_expr(tok_view)
  assert_true(
    a.kind is Paren(expr) &&
    expr.kind is ApplyExpr(app) &&
    app.kind is AtomExpr(atom) &&
    atom.kind is Tuple(tup) &&
    tup is [e1, e2] &&
    e1.kind is ApplyExpr(app1) &&
    app1.kind is AtomExpr(atom1) &&
    atom1.kind is Double(3.15) &&
    e2.kind is ApplyExpr(app2) &&
    app2.kind is AtomExpr(atom2) &&
    atom2.kind is Bool(false),
  )
  let (a, tok_view) = parse_atom_expr(tok_view)
  assert_true(a.kind is Unit)
  let (a, _) = parse_atom_expr(tok_view)
  assert_true(
    a.kind is Tuple(tup) &&
    tup is [e1, e2] &&
    e1.kind is ApplyExpr(app1) &&
    app1.kind is AtomExpr(atom1) &&
    atom1.kind is Unit &&
    e2.kind is ApplyExpr(app2) &&
    app2.kind is AtomExpr(atom2) &&
    atom2.kind is Unit,
  )
}
/// ================================================================================
/// # 解构的力量：解析模式
///
/// 我们已经可以解析类型和复杂的表达式了。现在，我们来处理一个与它们紧密相关，
/// 但又有所不同的概念：**模式（Pattern）**。
///
/// ## 什么是模式？
///
/// 模式是一种用于“解构”和“绑定”值的语法。你其实已经见过它最简单的形式了。
/// 在 `let x = ...` 中，`x` 就是一个最简单的标识符模式（Identifier Pattern），它将 `=` 右侧的值绑定到变量 `x` 上。
///
/// 在更完备的语言中（包括 MoonBit，但 MiniMoonBit 未实现），模式会大放异彩的地方是 `match` 表达式：
///
/// ```moonbit
/// match my_tuple {
///   (x, 0) => // 当元组第二个元素为 0 时，将第一个元素绑定到 x
///   (_, y) => // 忽略第一个元素，将第二个元素绑定到 y
/// }
/// ```
///
/// 在 MiniMoonBit 中，我们主要在 `let` 语句中使用模式，例如 `let (a, b) = (1, 2)` 来同时绑定多个变量。
///
/// ## 🎯 你的任务：实现 `parse_pattern`
///
/// 你的任务是在 `parser/pattern.mbt` 中实现 `parse_pattern` 函数。
///
/// MiniMoonBit 支持的模式非常简单：
/// 1.  **通配符：** `_`
/// 2.  **标识符：** `x`
/// 3.  **元组：** `(p1, p2, ...)`，其中 `p1`, `p2` 等本身也是模式。
///
/// 相信聪明的你已经发现，解析模式的逻辑与解析元组类型、元组表达式的逻辑非常相似，
/// 只是构成它的基本元素更少（只有 `_`, `ident` 和 `(...)`）。
///
/// 鉴于你已经是我们解析器开发的“老兵”了，这里的教程就不再赘述。放手去实现吧！
///
/// 加油！🚀
///
/// **阶段性测试：**
///
/// ```bash
/// moon test -p parser -f parse_pattern_test.mbt
/// ```
/// ================================================================================

///|
test "Pattern Parsing Test" {
  let code =
    #|_ 
    #|a
    #|(a, b, _)
    #|(a, (b, c), _)
    #|((a, b), (c, d))
  let tokens = @lexer.tokenize(code)
  let (p, tok_view) = parse_pattern(tokens[:])
  assert_true(p.kind is Wildcard)
  let (p, tok_view) = parse_pattern(tok_view)
  assert_true(p.kind is Ident("a"))
  let (p, tok_view) = parse_pattern(tok_view)
  assert_true(
    p.kind is Tuple(ps) &&
    ps is [p1, p2, p3] &&
    p1.kind is Ident("a") &&
    p2.kind is Ident("b") &&
    p3.kind is Wildcard,
  )
  let (p, tok_view) = parse_pattern(tok_view)
  assert_true(
    p.kind is Tuple(ps) &&
    ps is [p1, p2, p3] &&
    p1.kind is Ident("a") &&
    p2.kind is Tuple(ps2) &&
    ps2 is [p21, p22] &&
    p21.kind is Ident("b") &&
    p22.kind is Ident("c") &&
    p3.kind is Wildcard,
  )
  let (p, _) = parse_pattern(tok_view)
  assert_true(
    p.kind is Tuple(ps) &&
    ps is [p1, p2] &&
    p1.kind is Tuple(ps1) &&
    ps1 is [p11, p12] &&
    p11.kind is Ident("a") &&
    p12.kind is Ident("b") &&
    p2.kind is Tuple(ps2) &&
    ps2 is [p21, p22] &&
    p21.kind is Ident("c") &&
    p22.kind is Ident("d"),
  )
}
/// ================================================================================
/// # 语法分析的终点：解析整个程序
///
/// 🎉 **祝贺你！你已经来到了语法分析阶段的最后一关！** 🎉
///
/// 我们已经分别构建了用于解析表达式、语句、类型和各种顶层声明的解析器。
/// 现在，是时候将它们全部整合起来，构建一个能够解析完整 MiniMoonBit 程序的最终 `parse` 函数了。
///
/// ## 什么是程序？
///
/// 在 MiniMoonBit 中，一个程序（`Program`）就是一系列顶层声明的集合。这些声明可以是：
/// *   顶层函数 (`TopFunction`)
/// *   顶层 `let` 绑定 (`TopLet`)
/// *   结构体定义 (`StructDef`)
///
/// ## 🎯 你的任务：实现最终的 `parse` 函数
///
/// 你的任务是在 `parser/parser.mbt` 中实现 `parse` 函数。
///
/// **请注意：** 这个最终的 `parse` 函数的签名与我们之前写的辅助函数有所不同。
/// 它接收的是一个完整的 `Array[Token]`，而不是 `ArrayView[Token]`。
///
/// **实现思路：**
///
/// 1.  **初始化：** 创建用于存储 `TopFunction`、`TopLet` 和 `StructDef` 的 `Map`。
///
/// 2.  **循环解析：**
///     *   启动一个循环，持续处理 Token 视图。
///     *   在循环的每一步，检查当前的 Token 是什么：
///         *   如果是 `fn` 关键字，调用 `parse_top_function`。
///         *   如果是 `let` 关键字，调用 `parse_top_let`。
///         *   如果是 `struct` 关键字，调用 `parse_struct_def`。
///     *   将解析得到的结果存入相应的 `Map` 中。
///     *   用剩余的 Token 继续下一次循环。
///
/// 3.  **终止条件：** 当你遇到 `EOF` Token 时，意味着所有源代码都已处理完毕，循环结束。
///
/// 4.  **组装 `Program`：** 最后，用填充好的 `Map` 创建并返回最终的 `Program` 对象。
///
/// ## 🚀 见证你的成果！
///
/// 完成这个任务后，你就拥有了一个功能完备的 MiniMoonBit 语法分析器！
/// 你可以找一个 `examples/` 目录下的 `.mbt` 文件，然后运行以下命令，亲眼看看你的解析器的工作成果：
///
/// ```bash
/// moon run main -- --file examples/nbody.mbt -stop-after=parse
/// ```
///
/// 这个命令会运行你的编译器，但在语法分析阶段结束后就停止，并打印出生成的 AST。
///
/// **再次祝贺你完成了语法分析这一重要的里程碑！接下来，我们将进入更激动人心的语义分析阶段！**
/// ================================================================================

///|
test "Parse Program Test" {
  let code =
    #|struct Circle {
    #|  radius: Double;
    #|}
    #|
    #|struct Rectangle {
    #|  a: Double;
    #|  b: Double;
    #|  c: Double;
    #|}
    #|
    #|let pi: Double = 3.14;
    #|
    #|fn area_circle(c: Circle) -> Double {
    #|  if c.radius < 0.0 {
    #|    return 0.0;
    #|  };
    #|  pi * c.radius * c.radius;
    #|}
    #|
    #|fn area_rectangle(r: Rectangle) -> Double {
    #|   let p = (r.a + r.b + r.c) / 2.0;
    #|   let x = p - r.a;
    #|   let y = p - r.b;
    #|   let z = p - r.c;
    #|   sqrt(p * x * y * z);
    #|}
    #|
    #|fn main {
    #|  let c = Circle::{ radius: 2.0 };
    #|  let r = Rectangle::{ a: 3.0, b: 4.0, c: 5.0 };
    #|  let ac = area_circle(c);
    #|  let ar = area_rectangle(r);
    #|  if ac > ar {
    #|    print_str("Circle area is larger");
    #|  } else {
    #|    print_str("Rectangle area is larger");
    #|  };
    #|}
  let tokens = @lexer.tokenize(code)
  let program = parse(tokens)
  assert_true(program.struct_defs.length() is 2)
  assert_true(program.top_lets.length() is 1)
  assert_true(program.top_functions.length() is 3)
  assert_true(program.struct_defs.get("Circle") is Some(_))
  assert_true(program.struct_defs.get("Rectangle") is Some(_))
  assert_true(program.top_lets.get("pi") is Some(_))
  assert_true(program.top_functions.get("area_circle") is Some(_))
  assert_true(program.top_functions.get("area_rectangle") is Some(_))
  assert_true(program.top_functions.get("main") is Some(_))
}
/// ================================================================================
/// # 表达式的组合：ApplyExpr
///
/// 恭喜你，我们已经可以解析最基础的原子表达式（AtomExpr）了。
/// 现在，让我们进入一个更广阔的世界：**ApplyExpr**。
///
/// ## 什么是 ApplyExpr？
///
/// 在我们的 MiniMoonBit 语言中，`ApplyExpr` 是一个复合概念，它代表了可以被“应用”或“访问”的表达式。
/// 它包括了以下几种情况：
///
/// 1.  **函数调用：** `my_function(arg1, arg2)`
/// 2.  **数组索引：** `my_array[index]`
/// 3.  **结构体字段访问：** `my_struct.field`
/// 4.  **以及最基础的原子表达式（AtomExpr）：** `42`, `my_variable` 等
///
/// 可以看到，`ApplyExpr` 的核心是一个基础表达式（AtomExpr），后面可以跟上一系列的调用、索引或字段访问。
///
/// ## 🎯 你的任务：实现最简单的 ApplyExpr
///
/// 在这一步，我们先不处理复杂的函数调用和字段访问。
/// 我们的目标是实现 `ApplyExpr` 的最简形式：**一个只包含 `AtomExpr` 的 `ApplyExpr`**。
///
/// 请修改 `parser/apply_expr.mbt` 文件中的 `parse_apply_expr` 函数。
///
/// **实现思路：**
///
/// 1.  在 `parse_apply_expr` 函数内部，首先调用我们已经完成的 `parse_atom_expr` 来解析一个原子表达式。
/// 2.  成功解析出 `AtomExpr` 后，直接用它来构造一个 `ApplyExpr` 节点。
///    （提示：`ApplyExpr` 的定义中有一个 `AtomExpr(AtomExpr)` 的构造器）。
/// 3.  暂时不需要处理 `(`, `[` 或 `.` 等 Token，我们会在后续的挑战中逐步完善它。
///
/// **阶段性测试：**
///
/// 完成后，运行以下命令来检验你的实现：
///
/// ```bash
/// moon test -p parser -f parse_simple_apply_expr_test.mbt
/// ```
///
/// 这个测试将验证你的 `parse_apply_expr` 是否能正确地将一个原子表达式包装成 `ApplyExpr`。
///
/// **祝你顺利！这是我们向更复杂的表达式解析迈出的重要一步！**
/// ================================================================================

///|
test "Parse Simple Apply Expr Test" {
  let code =
    #|42 3.14 true false
    #|foo bar
  let tokens = @lexer.tokenize(code)
  let (a, tok_view) = parse_apply_expr(tokens[:])
  assert_true(a.kind is AtomExpr(atom) && atom.kind is Int(42))
  let (a, tok_view) = parse_apply_expr(tok_view)
  assert_true(a.kind is AtomExpr(atom) && atom.kind is Double(3.14))
  let (a, tok_view) = parse_apply_expr(tok_view)
  assert_true(a.kind is AtomExpr(atom) && atom.kind is Bool(true))
  let (a, tok_view) = parse_apply_expr(tok_view)
  assert_true(a.kind is AtomExpr(atom) && atom.kind is Bool(false))
  let (a, tok_view) = parse_apply_expr(tok_view)
  assert_true(a.kind is AtomExpr(atom) && atom.kind is Ident("foo"))
  let (a, _) = parse_apply_expr(tok_view)
  assert_true(a.kind is AtomExpr(atom) && atom.kind is Ident("bar"))
}
/// ================================================================================
/// # ApplyExpr 的扩展：数组索引
///
/// 我们已经为 `ApplyExpr` 实现了一个最基础的功能：包装一个 `AtomExpr`。
/// 现在，是时候为它添加真正的“应用”能力了，我们从**数组索引（Array Access）**开始。
///
/// ## 数组索引语法
///
/// 数组索引的语法非常直观：`array_variable[index_expression]`。
/// 这里的 `array_variable` 是一个 `ApplyExpr`（在最简单的情况下，是一个 `AtomExpr`），
/// 而 `index_expression` 是一个完整的 `Expr`。
///
/// ## 🎯 你的任务：在 `parse_apply_expr` 中处理 `[...]`
///
/// 我们的目标是扩展 `parser/apply_expr.mbt` 中的 `parse_apply_expr` 函数，
/// 使其能够在解析完一个 `AtomExpr` 后，继续检查并解析紧随其后的数组索引操作。
///
/// **实现思路：**
///
/// 1.  **解析基础：** 函数首先像之前一样，调用 `parse_atom_expr` 解析出一个基础的 `AtomExpr`，并将其包装成一个 `ApplyExpr`。
///
/// 2.  **向后看：** 解析完基础表达式后，不要立即返回！你需要检查**下一个** Token。
///
/// 3.  **匹配 `[`：**
///     *   如果下一个 Token 是 `[`，那么说明一个数组索引操作开始了。
///     *   跳过 `[`。
///     *   调用我们强大的 `parse_expr` 函数来解析括号内的索引表达式。
///     *   确保索引表达式后面紧跟着一个 `]`，并跳过它。
///     *   现在，你拥有了“被索引的数组”（就是你第一步解析出的那个 `ApplyExpr`）和“索引值”（你刚刚解析出的 `Expr`）。
///       用它们来创建一个新的、类型为 `ArrayAccess` 的 `ApplyExpr`。这个新的 `ApplyExpr` 会将旧的 `ApplyExpr` 包裹在内。
///
/// 4.  **不匹配：** 如果下一个 Token 不是 `[`，那么说明没有数组索引操作，直接返回第一步解析出的 `ApplyExpr` 即可。
///
/// ## 🤔 深入思考：链式调用 `arr[1][2]`
///
/// 这个挑战的测试用例包含 `matrix[3][4]` 这样的链式索引。
/// 如果你的实现是正确的，它应该能自然地处理这种情况。
///
/// 思考一下，为什么一个循环结构（`loop` 或 `while`）会是处理这种链式调用的优雅方式？
/// 当你解析完 `arr[1]` 后，你应该如何处理下一个 `[2]`？
/// 新生成的 `ApplyExpr` 和上一轮的 `ApplyExpr` 之间是什么关系？
///
/// **阶段性测试：**
///
/// 完成后，运行以下命令来检验你的实现：
///
/// ```bash
/// moon test -p parser -f parse_simple_array_access_expr_test.mbt
/// ```
///
/// **祝你顺利！你正在构建一个能够理解表达式组合的解析器！**
/// ================================================================================

///|
test "Simple Array Access Parsing Test" {
  let code =
    #|arr[42]
    #|matrix[3][4]
  let tokens = @lexer.tokenize(code)
  let (a, tok_view) = parse_apply_expr(tokens[:])
  assert_true(
    a.kind is ApplyExprKind::ArrayAccess(arr_access, index_expr) &&
    index_expr.kind is ApplyExpr(app_index) &&
    app_index.kind is AtomExpr(atom_index) &&
    atom_index.kind is Int(42) &&
    arr_access.kind is ApplyExprKind::AtomExpr(atom_arr) &&
    atom_arr.kind is AtomExprKind::Ident("arr"),
  )
  let (a, _) = parse_apply_expr(tok_view)
  assert_true(
    a.kind is ApplyExprKind::ArrayAccess(arr_access2, index_expr2) &&
    index_expr2.kind is ApplyExpr(app_index2) &&
    app_index2.kind is AtomExpr(atom_index2) &&
    atom_index2.kind is Int(4) &&
    arr_access2.kind is ApplyExprKind::ArrayAccess(arr_access1, index_expr1) &&
    index_expr1.kind is ApplyExpr(app_index1) &&
    app_index1.kind is AtomExpr(atom_index1) &&
    atom_index1.kind is Int(3) &&
    arr_access1.kind is ApplyExprKind::AtomExpr(atom_arr) &&
    atom_arr.kind is AtomExprKind::Ident("matrix"),
  )
}
/// ================================================================================
/// # ⚔️ 第二挑战：语法分析器 (Parser) 的结构之力
///
/// 恭喜你完成了词法分析！你已经拥有了编译器冒险的第一把钥匙——Token 序列。
/// 现在，我们将使用这些 Token，来构建代码的“骨架”：**抽象语法树（AST）**。
///
/// ---
///
/// ## 🗺️ 语法分析（Parsing）：从序列到层次
///
/// 语法分析器是编译器的“建筑师”。它的使命是将线性的 Token 流，
/// 按照语言的**语法规则**，组织成具有层次结构的 **AST 节点**。
///
/// **例如，对于以下代码片段：**
///
/// ```
/// let total : Int = price * count + 10;
/// ```
///
/// Parser 不仅要看到 `*` 和 `+` 运算符，还要理解它们之间的**优先级**和**结合性**，
/// 最终生成如下结构（简化表示）：
///
/// ```
/// - LetStatement (变量声明)
///   - Name: "total"
///   - Type: Int
///   - Value:
///     - BinaryExpr (二元运算 '+')
///       - Left: BinaryExpr (二元运算 '*')
///         - Left: Identifier "price"
///         - Right: Identifier "count"
///       - Right: Integer 10
/// ```
///
/// **核心目标：** 将平铺的 `Array[Token]` 转换为嵌套的 `Program` 结构。
///
/// ```moonbit
/// parse(tokens: Array[Token]) -> Program
/// ```
///
/// ## 🏛️ 解析技术：递归下降（Recursive Descent）
///
/// 在本项目中，我们将采用最直观且强大的解析技术之一：**递归下降解析（Recursive Descent Parsing）**。
///
/// 这种技术的核心思想是：**每一个语法规则都对应一个解析函数。**
/// * 解析 `Expr` 的函数会调用解析 `BinaryExpr` 的函数。
/// * 解析 `BinaryExpr` 的函数会调用解析 `AtomExpr` 的函数。
///
/// 📌 **我们的策略：自底向上构建！**
/// 我们将从最底层、最简单的语法单元（例如单个数字）开始实现，逐步向上构建出能够解析整个程序的函数。
///
/// ---
///
/// ## 🎯 你的第一个任务：解析原子表达式（AtomExpr）
///
/// **原子表达式（AtomExpr）**是所有复杂表达式的基石。它们是不能再被分解的最小表达式单元。
///
/// 请在 `parser/atom_expr.mbt` 文件中实现 `parse_atom_expr` 函数。
///
/// **你的目标是让它能够成功解析以下基础元素：**
///
/// * **数字：** `42`, `3.14`
/// * **布尔值：** `true`, `false`
/// * **标识符：** `my_variable`
/// * **字符串：** `"hello world"`
///
/// **函数签名（关键！）:**
///
/// ```moonbit
/// parse_atom_expr: (ArrayView[Token]) -> (AtomExpr, ArrayView[Token])
/// ```
///
/// * **输入：** 接受当前的 `Token` 视图。
/// * **输出：** 返回一个 `Tuple`，包含：
///     1.  解析得到的 `AtomExpr` 节点。
///     2.  **剩余的 `Token` 视图（必须跳过已消耗的 Token！）**。
///
/// **实现思路：**
/// 检查当前 Token 的 `kind`。如果它匹配 `Int(_)`、`Double(_)`、`Bool(_)`、`Lower(_)` 或 `String(_)`，则：
/// 1.  构造对应的 `AtomExpr` 结构体。
/// 2.  返回结果，并将 `Token` 视图向前推进一位。
/// 3.  如果不匹配，则抛出错误（`raise ParseError`），表示语法解析失败。
///
/// **阶段性测试：**
///
/// 在完成实现后，你可以使用以下命令精确运行你的测试：
///
/// ```bash
/// moon test -p parser -f parse_simple_atom_expr_test.mbt
/// ```
///
/// ---
///
/// ## 💡 技术宝典：Token 解构与模式匹配
///
/// 在语法分析阶段，Token 的解构是你的主要工具。MoonBit 强大的模式匹配能让代码极其简洁：
///
/// 我们的 `Token` 结构：`struct Token { kind: TokenKind }`
///
/// **直接匹配 Token 数组和结构体：**
///
/// 要解析一个 `Int` 类型的原子表达式，你只需要一次模式匹配就能完成提取和推进 Token 视图的操作：
///
/// ```moonbit
/// let tokens : ArrayView[Token] = ...
///
/// match tokens {
///     // 模式匹配：如果 Token 视图以 { kind: Int(value), ... } 开头
///     [ { kind: Int(value) }, ..rest_tokens ] => {
///         // 成功匹配！ value 是整数的实际值
///         // rest_tokens 是视图中剩下的部分
///         // ... 构造 AtomExpr 并返回 (AtomExpr, rest_tokens)
///     }
///     // 其他 Token 类型...
///     _ => raise ParseError("期望 ...，但遇到意外的 Token ...")
/// }
/// ```
///
/// 这种强大的解构能力能够让你轻松处理各种 Token 类型，并且代码简洁易读。
///
/// **祝你成功！迈出构建 AST 的第一步！**
/// ================================================================================

///|
test "Simple AtomExpr Parsing Test" {
  let code =
    #|42 3.14 true false
    #|foo bar "hello minimoonbit"
  let tokens = @lexer.tokenize(code)
  let (a, tok_view) = parse_atom_expr(tokens[:])
  assert_true(a.kind is Int(42))
  let (a, tok_view) = parse_atom_expr(tok_view)
  assert_true(a.kind is Double(3.14))
  let (a, tok_view) = parse_atom_expr(tok_view)
  assert_true(a.kind is Bool(true))
  let (a, tok_view) = parse_atom_expr(tok_view)
  assert_true(a.kind is Bool(false))
  let (a, tok_view) = parse_atom_expr(tok_view)
  assert_true(a.kind is Ident("foo"))
  let (a, tok_view) = parse_atom_expr(tok_view)
  assert_true(a.kind is Ident("bar"))
  let (a, _) = parse_atom_expr(tok_view)
  assert_true(a.kind is String("hello minimoonbit"))
}
/// ================================================================================
/// # 终极挑战：解析二元表达式与运算符优先级
///
/// 欢迎来到 `Expr` 解析的终极挑战！我们即将要攻克的，是编译器中最经典、也最具挑战性的问题之一：
/// **带有优先级的二元表达式解析（Binary Expression Parsing with Precedence）**。
///
/// ⚠️ **高能预警：** 这部分内容的实现难度较高，其算法复杂度不亚于一道 LeetCode 的中等偏上难度的题目。
/// 请做好充分的心理准备，这将是一次绝佳的算法思维锻炼！
///
/// ## 🤔 挑战的核心：运算符优先级
///
/// 为什么这很难？思考一下表达式 `1 + 2 * 3`。
///
/// 我们人类知道应该先算 `2 * 3`，因为 `*` 的优先级高于 `+`。
/// 但我们的解析器是自左向右读取 Token 的。当它看到 `1 + 2` 时，它如何知道不能立刻将它们组合，
/// 而是要“等待”后面的 `*` 运算先完成呢？
///
/// 这就是我们需要解决的核心问题：实现一个能够理解并正确处理不同运算符优先级的解析算法。
///
/// ## 🎯 你的任务：在 `parse_expr` 中实现完整的二元表达式解析
///
/// 现在，请再次回到 `parser/expr.mbt`，准备对 `parse_expr` 函数进行一次“大手术”。
///
/// **💡 核心思路提示：双栈
///
/// 1.  **两个栈：** 你可以考虑使用两个栈：一个用于存放**待处理的运算符（Operator Stack）**，另一个用于存放**已经解析出的表达式（Expression Stack）**。
///
/// 2.  **处理流程：**
///     *   当你解析出一个 `ApplyExpr`（我们称之为一个操作数）时，将它压入表达式栈。
///     *   当你遇到一个运算符时，你需要将它与运算符栈顶的运算符进行**优先级比较**。
///         *   如果当前运算符的优先级**高于**栈顶运算符，说明它可以“抢先”执行，将它压入运算符栈。
///         *   如果当前运算符的优先级**低于或等于**栈顶运算符，说明栈顶的运算需要先进行。
///             此时，从运算符栈弹出一个运算符，从表达式栈弹出两个表达式，将它们组合成一个新的 `BinaryExpr`，
///             然后将结果压回表达式栈。重复此过程，直到当前运算符可以被压入栈中。
///
/// 3.  **收尾工作：** 当所有 Token 都处理完毕后，清空运算符栈中的所有剩余运算符，完成最后的组合。
///
/// 这只是一个高层次的思路概述。你需要仔细思考其中的细节，例如循环条件、栈的清空时机以及如何处理括号（尽管本测试暂不涉及）。
///
/// **precedence 函数：**
///
/// 为了帮助你，`parser/expr.mbt` 中已经为你提供了一个 `precedence(op: BinaryOp) -> Int` 的辅助函数，你可以直接使用它来获取运算符的优先级。
///
/// **阶段性测试：**
///
/// 完成这个艰巨的任务后，运行以下命令来检验你的成果：
///
/// ```bash
/// moon test -p parser -f parse_simple_binary_expr_test.mbt
/// ```
///
/// **祝你挑战成功！攻克了它，你对表达式解析的理解将达到一个新的高度！**
/// ================================================================================

///|
test "Binary Expr Parsing Test" {
  let code =
    #|1 + 2 * 3 ;
    #|4 * 5 - 6 / 2 ;
    #|a && b || c && d ;
    #|x << 2 + y >> 3 ;
    #|p > q != r < s
  let tokens = @lexer.tokenize(code)
  let (e, tok_view) = parse_expr(tokens[:])
  assert_true(
    e.kind is BinaryExpr(Add, left, right) &&
    left.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Int(1) &&
    right.kind is BinaryExpr(Mul, left, right) &&
    left.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Int(2) &&
    right.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Int(3),
  )
  let (e, tok_view) = parse_expr(tok_view[1:])
  assert_true(
    e.kind is BinaryExpr(Sub, left1, right1) &&
    left1.kind is BinaryExpr(Mul, left2, right2) &&
    left2.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Int(4) &&
    right2.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Int(5) &&
    right1.kind is BinaryExpr(Div, left3, right3) &&
    left3.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Int(6) &&
    right3.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Int(2),
  )
  let (e, tok_view) = parse_expr(tok_view[1:])
  assert_true(
    e.kind is BinaryExpr(Or, left1, right1) &&
    left1.kind is BinaryExpr(And, left2, right2) &&
    left2.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Ident("a") &&
    right2.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Ident("b") &&
    right1.kind is BinaryExpr(And, left3, right3) &&
    left3.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Ident("c") &&
    right3.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Ident("d"),
  )
  let (e, tok_view) = parse_expr(tok_view[1:])
  assert_true(
    e.kind is BinaryExpr(ShiftRight, left1, right1) &&
    left1.kind is BinaryExpr(ShiftLeft, left2, right2) &&
    left2.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Ident("x") &&
    right2.kind is BinaryExpr(Add, left3, right3) &&
    left3.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Int(2) &&
    right3.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Ident("y") &&
    right1.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Int(3),
  )
  let (e, _) = parse_expr(tok_view[1:])
  assert_true(
    e.kind is BinaryExpr(NE, left1, right1) &&
    left1.kind is BinaryExpr(GT, left2, right2) &&
    left2.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Ident("p") &&
    right2.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Ident("q") &&
    right1.kind is BinaryExpr(LT, left3, right3) &&
    left3.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Ident("r") &&
    right3.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Ident("s"),
  )
}
/// ================================================================================
/// # ApplyExpr 的再扩展：函数调用
///
/// 我们已经成功地为 `ApplyExpr` 添加了数组索引的功能。现在，让我们来完成它的最后一块拼图：
/// **函数调用（Function Calls）**。
///
/// ## 函数调用语法
///
/// 函数调用的语法是 `function_name(argument1, argument2, ...)`。
/// 这里的 `function_name` 是一个 `ApplyExpr`，而括号内的参数列表是一个由逗号分隔的 `Expr` 列表。
///
/// 你会发现，这个参数列表的结构与我们之前解析过的元组（Tuple）和数组字面量（Array Literal）几乎完全一样！
///
/// ## 🎯 你的任务：在 `parse_apply_expr` 中处理 `(...)`
///
/// 我们的目标是继续扩展 `parser/apply_expr.mbt` 中的 `parse_apply_expr` 函数，
/// 使其在解析完一个基础表达式后，能够继续检查并解析函数调用。
///
/// **实现思路：**
///
/// 这部分逻辑与解析数组索引非常相似，可以放在同一个循环中处理。
///
/// 1.  **解析基础：** 函数首先解析出一个基础的 `ApplyExpr`。
///
/// 2.  **循环向后看：** 进入一个循环，检查基础表达式后面的 Token。
///
/// 3.  **匹配 `(`：**
///     *   如果下一个 Token 是 `(`，那么说明一个函数调用开始了。
///     *   跳过 `(`。
///     *   接下来，你需要解析括号内的参数列表。这是一个由逗号分隔的 `Expr` 列表。
///       这个逻辑和解析元组/数组的内部非常相似，你可以考虑将这部分逻辑抽象成一个可复用的辅助函数，
///       例如 `parse_expr_list`，它接收 Token，返回一个 `Array[Expr]` 和剩余的 Token。
///     *   确保参数列表后面紧跟着一个 `)`，并跳过它。
///     *   现在，你拥有了“被调用的函数”（`callee`）和“参数列表”（`args`）。
///       用它们来创建一个新的、类型为 `Call` 的 `ApplyExpr`。
///
/// 4.  **结合与循环：**
///     *   这个新的 `Call` 表达式会包裹住旧的 `ApplyExpr`。在下一次循环中，这个新的 `ApplyExpr`
///       又可以作为更外层调用（例如 `foo(1)(2)`）或者数组索引（例如 `foo(1)[2]`）的基础。
///
/// **阶段性测试：**
///
/// 完成后，运行以下命令来检验你的实现：
///
/// ```bash
/// moon test -p parser -f parse_simple_call_expr_test.mbt
/// ```
///
/// **祝贺你！完成这一步后，你的 `ApplyExpr` 解析器就功能完备了，能够处理复杂的表达式组合！**
/// ================================================================================

///|
test "Simple Call Expr Parsing Test" {
  let code =
    #|foo()
    #|bar(42, true)
    #|qux(1 + 3)
  let tokens = @lexer.tokenize(code)
  let (a, tok_view) = parse_apply_expr(tokens[:])
  assert_true(
    a.kind is ApplyExprKind::Call(callee, args) &&
    args is [] &&
    callee.kind is AtomExpr(callee_atom) &&
    callee_atom.kind is AtomExprKind::Ident("foo"),
  )
  let (a, tok_view) = parse_apply_expr(tok_view)
  assert_true(
    a.kind is ApplyExprKind::Call(callee, args) &&
    args is [arg1, arg2] &&
    arg1.kind is ApplyExpr(arg1_app) &&
    arg1_app.kind is AtomExpr(arg1_atom) &&
    arg1_atom.kind is AtomExprKind::Int(42) &&
    arg2.kind is ApplyExpr(arg2_app) &&
    arg2_app.kind is AtomExpr(arg2_atom) &&
    arg2_atom.kind is AtomExprKind::Bool(true) &&
    callee.kind is AtomExpr(callee_atom) &&
    callee_atom.kind is AtomExprKind::Ident("bar"),
  )
  let (a, _) = parse_apply_expr(tok_view)
  assert_true(
    a.kind is ApplyExprKind::Call(callee, args) &&
    args is [arg1] &&
    arg1.kind is BinaryExpr(Add, left, right) &&
    left.kind is ApplyExpr(left_app) &&
    left_app.kind is AtomExpr(left_atom) &&
    left_atom.kind is AtomExprKind::Int(1) &&
    right.kind is ApplyExpr(right_app) &&
    right_app.kind is AtomExpr(right_atom) &&
    right_atom.kind is AtomExprKind::Int(3) &&
    callee.kind is AtomExpr(callee_atom) &&
    callee_atom.kind is AtomExprKind::Ident("qux"),
  )
}
/// ================================================================================
/// # 表达式的层级：Expr
///
/// 我们已经成功地将 `AtomExpr` 包装进了 `ApplyExpr`。现在，是时候引入我们语法树中
/// 最核心、最通用的节点之一：**`Expr`**。
///
/// ## 什么是 Expr？
///
/// `Expr`（表达式）是 MiniMoonBit 中能够产生一个值的几乎所有代码构造的统称。
/// 它是我们语法规则的“瑞士军刀”，涵盖了从最简单的数字到最复杂的逻辑块的所有内容。
///
/// `Expr` 主要包括以下几种形式：
///
/// 1.  **一元操作：** `-x` (取反), `!b` (逻辑非)
/// 2.  **二元操作：** `a + b`, `x > y`
/// 3.  **If 表达式：** `if condition { ... } else { ... }`
/// 4.  **Block 表达式：** `{ let a = 1; a + 1 }`
/// 5.  **以及我们刚刚实现的 `ApplyExpr`：** 它作为所有复杂表达式的基础。
///
/// ## 🎯 你的任务：实现最简单的 Expr
///
/// 在这个挑战中，我们将采用“由简入繁”的策略。我们首先要让 `parse_expr` 函数
/// 能够处理最基础的情况：一个单独的 `ApplyExpr`。
///
/// 请修改 `parser/expr.mbt` 文件中的 `parse_expr` 函数。
///
/// **实现思路：**
///
/// 1.  在 `parse_expr` 函数内部，直接调用我们已经完成的 `parse_apply_expr`。
/// 2.  成功解析出 `ApplyExpr` 后，用它来构造一个 `Expr` 节点。
///    （提示：`Expr` 的定义中有一个 `ApplyExpr(ApplyExpr)` 的构造器）。
/// 3.  暂时不需要考虑任何二元操作、一元操作或其他复杂情况。我们只处理一个 `ApplyExpr` 就直接返回。
///
/// **阶段性测试：**
///
/// 完成后，运行以下命令来检验你的实现：
///
/// ```bash
/// moon test -p parser -f parse_simple_expr_test.mbt
/// ```
///
/// 这个测试将确保你的 `parse_expr` 能够正确地将一个 `ApplyExpr` 包装成 `Expr`。
///
/// **祝你顺利！我们正在逐步构建起能够理解复杂代码逻辑的解析器！**
/// ================================================================================

///|
test "Simple Expr Parsing Test" {
  let code =
    #|42 3.14 true false
    #|a
  let tokens = @lexer.tokenize(code)
  let (e, tok_view) = parse_expr(tokens[:])
  assert_true(
    e.kind is ApplyExpr(a) && a.kind is AtomExpr(atom) && atom.kind is Int(42),
  )
  let (e, tok_view) = parse_expr(tok_view)
  assert_true(
    e.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Double(3.14),
  )
  let (e, tok_view) = parse_expr(tok_view)
  assert_true(
    e.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Bool(true),
  )
  let (e, tok_view) = parse_expr(tok_view)
  assert_true(
    e.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Bool(false),
  )
  let (e, _) = parse_expr(tok_view)
  assert_true(
    e.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Ident("a"),
  )
}
/// ================================================================================
/// # ApplyExpr 的终章：结构体字段访问
///
/// 我们已经完成了 `ApplyExpr` 的大部分功能，现在只剩下最后一种，也是非常重要的一种：
/// **结构体字段访问（Struct Field Access）**。
///
/// ## 字段访问语法
///
/// 字段访问的语法是通过点号 `.` 来访问一个结构体实例的成员：`my_struct.field_name`。
/// 这里的 `my_struct` 是一个 `ApplyExpr`，而 `field_name` 是一个标识符（`Lower` Token）。
///
/// ## 🎯 你的任务：在 `parse_apply_expr` 中处理 `.`
///
/// 我们的目标是最终完善 `parser/apply_expr.mbt` 中的 `parse_apply_expr` 函数，
/// 使其能够处理字段访问，并能够与数组索引、函数调用等无缝衔接。
///
/// **实现思路：**
///
/// 这部分逻辑可以完美地融入我们为处理数组索引和函数调用而构建的循环中。
///
/// 1.  **解析基础：** 函数首先解析出一个基础的 `ApplyExpr`。
///
/// 2.  **循环向后看：** 在循环中，检查基础表达式后面的 Token。
///
/// 3.  **匹配 `.`：**
///     *   如果下一个 Token 是 `.`，那么说明一个字段访问开始了。
///     *   跳过 `.`。
///     *   **特别注意：** 字段名必须是一个小写字母开头的标识符。所以，你需要检查紧跟在 `.` 后面的 Token 是否为 `TokenKind::Lower`。
///     *   如果匹配成功，提取出字段名（一个 `String`）。
///     *   现在，你拥有了“被访问的对象”（`object`）和“字段名”（`field`）。
///       用它们来创建一个新的、类型为 `FieldAccess` 的 `ApplyExpr`。
///
/// 4.  **链式访问：**
///     *   这个新的 `FieldAccess` 表达式会包裹住旧的 `ApplyExpr`。在下一次循环中，它又可以作为
///       `obj.field1.field2` 或 `obj.field[0]` 或 `obj.method()` 等更复杂链式操作的基础。
///
/// **阶段性测试：**
///
/// 完成后，运行以下命令来检验你的实现：
///
/// ```bash
/// moon test -p parser -f parse_simple_field_access_expr_test.mbt
/// ```
///
/// **祝贺你！完成这一步后，你的 `parse_apply_expr` 函数就彻底完工了。你已经构建了一个能够解析 MiniMoonBit 中所有复杂表达式组合的强大解析器！**
/// ================================================================================

///|
test "Simple Field Access Parsing Test" {
  let code =
    #|obj.field
    #|obj.nested.field
  let tokens = @lexer.tokenize(code)
  let (a, tok_view) = parse_apply_expr(tokens[:])
  assert_true(
    a.kind is ApplyExprKind::FieldAccess(obj_access, field) &&
    field == "field" &&
    obj_access.kind is ApplyExprKind::AtomExpr(atom_obj) &&
    atom_obj.kind is AtomExprKind::Ident("obj"),
  )
  let (a, _) = parse_apply_expr(tok_view)
  assert_true(
    a.kind is ApplyExprKind::FieldAccess(nested_access, field2) &&
    field2 == "field" &&
    nested_access.kind is ApplyExprKind::FieldAccess(obj_access2, field1) &&
    field1 == "nested" &&
    obj_access2.kind is ApplyExprKind::AtomExpr(atom_obj2) &&
    atom_obj2.kind is AtomExprKind::Ident("obj"),
  )
}
/// ================================================================================
/// # 语句的“总指挥”：解析 Stmt
///
/// 我们已经集齐了 `let`、`let mut` 和 `assign` 等语句的解析器。
/// 现在，是时候创建一个“总指挥”——`parse_stmt` 函数，来统一调度它们了。
///
/// ## Stmt 的构成
///
/// 一个通用的语句（`Stmt`）可以是多种具体语句中的任何一种：
///
/// ```
/// stmt ::= let_stmt | let_mut_stmt | assign_stmt | expr_stmt
/// ```
///
/// `expr_stmt` 指的是一个表达式本身也可以作为一条语句，例如一个函数调用 `println("hello");`。
///
/// ## 🎯 你的任务：实现 `parse_stmt`
///
/// 你的任务是在 `parser/stmt.mbt` 中实现 `parse_stmt` 函数。
/// 这个函数需要根据开头的 Token 来判断应该调用哪个具体的语句解析器。
///
/// *   如果开头是 `let` 关键字，你需要进一步判断第二个 Token 是不是 `mut`，然后分别调用 `parse_let_stmt` 或 `parse_let_mut_stmt`。
///
/// ### 🤔 一个棘手的问题：`assign_stmt` vs `expr_stmt`
///
/// 最大的挑战在于区分 `assign_stmt` 和 `expr_stmt`。
///
/// *   `x = 1;` 是一个赋值语句。
/// *   `x(1);` 是一个表达式语句。
///
/// 它们都以一个标识符 `x` 开头！我们无法仅凭第一个 Token 就做出判断。
/// 这种“无法仅通过向前看一个 Token 来确定语法结构”的问题，在解析器中被称为 **LL(1) 冲突**。
///
/// **解决思路（预测与回溯）：**
///
/// 我们可以采用一种“试探-回溯”的策略：
///
/// 1.  **大胆预测：** 当语句以一个标识符开头时，我们**乐观地**假设它可能是一个赋值语句。因此，我们先尝试调用 `parse_left_value` 来解析一个左值。
///
/// 2.  **验证预测：** 解析完左值后，检查紧跟其后的 Token：
///     *   如果是一个**赋值操作符**（`=`、`+=` 等），那么我们的预测是正确的！这确实是一个 `assign_stmt`。此时，我们继续调用 `parse_assign_stmt` 来完成剩余部分的解析。
///     *   如果**不是**赋值操作符，那么我们的预测失败了。这意味着它不是一个赋值语句，而应该是一个 `expr_stmt`。
///
/// 3.  **回溯：** 预测失败后，我们需要“回溯”。这意味着我们要**丢弃**刚刚 `parse_left_value` 的解析结果，将 Token 视图**退回**到最初的位置，然后调用 `parse_expr` 将整条语句作为 `expr_stmt` 来重新解析。
///
/// 这种“预测-验证-回溯”的机制是手动编写递归下降解析器时处理语法歧义的常用技巧。
///
/// 加油，这是我们解析器部分的最后一个核心挑战！
///
/// **阶段性测试：**
///
/// ```bash
/// moon test -p parser -f parse_simple_stmt_test.mbt
/// ```
/// ================================================================================

///|
test "Stmt Parsing Test" {
  let code =
    #|let x = 5;
    #|let mut y = 10;
    #|y = y + x;
    #|y();
    #|println(123);
    #|print_int(foo(1, 2));
    #|foo.bar[3][4] = 42;
    #|return 0;
    #|return ;
  let tokens = @lexer.tokenize(code)
  let (s, tok_view) = parse_stmt(tokens[:])
  assert_true(s.kind is LetStmt(_))
  let (s, tok_view) = parse_stmt(tok_view)
  assert_true(s.kind is LetMutStmt(_))
  let (s, tok_view) = parse_stmt(tok_view)
  assert_true(s.kind is AssignStmt(_))
  let (s, tok_view) = parse_stmt(tok_view)
  assert_true(s.kind is ExprStmt(_))
  let (s, tok_view) = parse_stmt(tok_view)
  assert_true(s.kind is ExprStmt(_))
  let (s, tok_view) = parse_stmt(tok_view)
  assert_true(s.kind is ExprStmt(_))
  let (s, tok_view) = parse_stmt(tok_view)
  assert_true(s.kind is AssignStmt(_))
  let (s, tok_view) = parse_stmt(tok_view)
  assert_true(s.kind is ReturnStmt(_))
  let (s, _) = parse_stmt(tok_view)
  assert_true(s.kind is ReturnStmt(_))
}
/// ================================================================================
/// # 表达式的扩展：一元操作
///
/// 恭喜你！我们已经实现了 `parse_expr` 的基础版本，它现在能够处理最简单的表达式了。
/// 接下来，我们将为它添加新的能力：**解析一元操作（Unary Expressions）**。
///
/// ## 什么是一元操作？
///
/// 一元操作是指只作用于一个操作数的表达式。在 MiniMoonBit 中，我们支持两种一元操作：
///
/// 1.  **逻辑非：** `!true`
/// 2.  **取反：** `-42`
///
/// 这些操作符位于它们所作用的表达式之前，这为我们的递归下降解析器提供了一个清晰的信号。
///
/// ## 🎯 你的任务：在 `parse_expr` 中支持一元操作
///
/// 现在，请再次修改 `parser/expr.mbt` 文件中的 `parse_expr` 函数，为其增加解析一元操作的功能。
///
/// **实现思路：**
///
/// 在 `parse_expr` 函数的开头，我们需要“向前看”一个 Token：
///
/// 1.  **检查 Token 类型：**
///     *   如果当前的 Token 是 `!` (即 `TokenKind::Not`)，我们就知道这是一个逻辑非表达式。
///     *   如果当前的 Token 是 `-` (即 `TokenKind::BinaryOp(Sub)`)，我们就知道这是一个取反表达式。
///
/// 2.  **递归调用 `parse_expr`：**
///     *   如果匹配到一元操作符，我们需要**跳过这个操作符 Token**，然后**递归地调用 `parse_expr`** 来解析后面的表达式部分。
///
/// 3.  **构造 `Expr` 节点：**
///     *   在递归调用返回后，我们将得到的子表达式包装在一个新的一元表达式节点中（`NotExpr` 或 `NegExpr`）。
///
/// 4.  **默认情况：**
///     *   如果开头的 Token 不是一元操作符，那么就执行我们之前实现的逻辑——调用 `parse_apply_expr`。
///
/// **阶段性测试：**
///
/// 完成后，运行以下命令来检验你的实现：
///
/// ```bash
/// moon test -p parser -f parse_simple_unary_expr_test.mbt
/// ```
///
/// 这个测试将验证你的 `parse_expr` 是否能正确处理 `!` 和 `-` 操作。
///
/// **祝你顺利！通过递归，我们的解析器正在变得越来越强大！**
/// ================================================================================

///|
test "Unary Expr Parsing Test" {
  let code =
    #|-42 ;
    #|!true ;
    #|-res ;
    #|!cond ;
  let tokens = @lexer.tokenize(code)
  let (e, tok_view) = parse_expr(tokens[:])
  assert_true(
    e.kind is NegExpr(inner) &&
    inner.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Int(42),
  )
  let (e, tok_view) = parse_expr(tok_view[1:])
  assert_true(
    e.kind is NotExpr(inner) &&
    inner.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Bool(true),
  )
  let (e, tok_view) = parse_expr(tok_view[1:])
  assert_true(
    e.kind is NegExpr(inner) &&
    inner.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Ident("res"),
  )
  let (e, _) = parse_expr(tok_view[1:])
  assert_true(
    e.kind is NotExpr(inner) &&
    inner.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Ident("cond"),
  )
}
/// ================================================================================
/// # 创建实例：解析结构体构造表达式
///
/// 我们已经定义了结构体（Struct），现在我们需要一种方法来创建它的实例。
/// 这就是**结构体构造表达式（Struct Construction Expression）**的作用。
///
/// ## 结构体构造的 EBNF 范式
///
/// ```
/// struct_construct ::= Upper "::" "{" (field_init ("," field_init)* ","? )? "}"
/// field_init       ::= ident ":" expr
/// ```
///
/// 这段范式描述了如何创建一个结构体实例：
/// 1.  以结构体类型名（`Upper` Token）和 `::` 开始。
/// 2.  `{}` 内部是字段的初始化列表。
/// 3.  每个 `field_init` 包含一个字段名 `ident`、一个冒号 `:` 和一个初始化 `expr`。
/// 4.  字段之间用逗号 `,` 分隔，并且允许有一个尾随的逗号。
///
/// ## 🎯 你的任务：实现 `parse_struct_construct`
///
/// 你的任务是在 `parser/struct_construct_expr.mbt` 中实现 `parse_struct_construct` 函数。
///
/// **实现思路：**
///
/// 这个解析逻辑与我们之前解析元组、数组和函数参数列表的逻辑非常相似。
///
/// 1.  匹配结构体名称（`Upper`）和 `::{`。
/// 2.  进入一个循环，解析由逗号分隔的 `ident: expr` 键值对。
/// 3.  循环直到遇到 `}`。
/// 4.  将解析出的字段和值存入一个 `Array`，并创建一个 `StructConstructExpr` 节点。
///
/// ### ⚠️ 不要忘记！
///
/// 完成 `parse_struct_construct` 后，你还需要回到 `parser/atom_expr.mbt` 中的 `parse_atom_expr` 函数，
/// 将这个新的解析器整合进去。当 `parse_atom_expr` 遇到一个大写字母开头的标识符（`Upper` Token）时，
/// 它需要能够判断这究竟是一个 `Array::make` 还是一个结构体构造。
///
/// 相信这对你来说已经不难了。加油！
///
/// **阶段性测试：**
///
/// ```bash
/// moon test -p parser -f parse_struct_construct_test.mbt
/// ```
/// ================================================================================

///|
test "Parse Struct Construct Expr" {
  let code =
    #|Data::{ x: [1, 2, 3], y: (4, 5, 6) }
  let tokens = @lexer.tokenize(code)
  let (e, _) = parse_struct_construct(tokens[:])
  assert_true(
    e.kind is StructConstruct(s) &&
    s.name == "Data" &&
    s.fields is [f1, f2] &&
    f1 is ("x", expr1) &&
    f2 is ("y", expr2) &&
    expr1.kind is ApplyExpr(a1) &&
    a1.kind is AtomExpr(atom1) &&
    atom1.kind is Array([_, _, _]) &&
    expr2.kind is ApplyExpr(a2) &&
    a2.kind is AtomExpr(atom2) &&
    atom2.kind is Tuple([_, _, _]),
  )
}
/// ================================================================================
/// # 自定义类型：解析结构体定义
///
/// 我们已经能够解析 MiniMoonBit 的所有内置类型和语句了。现在，我们来添加一个强大的功能：
/// 允许用户**自定义类型**，即**结构体（Struct）**。
///
/// 结构体允许我们将多个不同类型的值组合成一个新的、有名字的类型。
///
/// ## 结构体定义的 EBNF 范式
///
/// ```
/// struct_def ::= "struct" ident "{" (field_def (";" field_def)* ";"? )? "}"
/// field_def  ::= ("mut")? ident ":" type
/// ```
///
/// 这段范式告诉我们：
/// 1.  以 `struct` 关键字和类型名（大写字母开头的 `ident`）开始。
/// 2.  `{}` 内部是字段列表。
/// 3.  每个字段 `field_def` 包含一个可选的 `mut` 关键字、一个字段名（小写字母开头的 `ident`）和一个类型。
/// 4.  字段之间必须用分号 `;` 分隔。
///
/// ## 🎯 你的任务：实现 `parse_struct_def`
///
/// 你的任务是在 `parser/struct_def.mbt` 中实现 `parse_struct_def` 函数。
///
/// **实现思路：**
///
/// 1.  解析 `struct` 关键字和结构体名称。
/// 2.  解析开头的 `{"{"`。
/// 3.  进入一个循环，解析 `{"{""}"}` 内部的字段列表。循环的终止条件是遇到 `"}"`。
/// 4.  在循环内部，你可以创建一个辅助函数 `parse_struct_field` 来解析单个字段。这个函数负责解析可选的 `mut`、字段名、冒号和类型，并要求后面必须跟一个分号。
/// 5.  解析结尾的 `"}"`。
///
/// 这个结构与解析代码块 `block_expr` 非常相似，相信你已经很熟悉了。
///
/// 加油！这是我们为语言添加复合数据类型的关键一步。
///
/// **阶段性测试：**
///
/// ```bash
/// moon test -p parser -f parse_struct_def_test.mbt
/// ```
/// ================================================================================

///|
test "Struct Def Parsing Test" {
  let code =
    #|struct Point {
    #|  x: Int;
    #|  mut y: Int;
    #|  z: Double;
    #|}
  let tokens = @lexer.tokenize(code)
  let (struct_def, _) = parse_struct_def(tokens)
  assert_true(struct_def.name is "Point")
  assert_true(struct_def.fields.length() is 3)
  assert_true(struct_def.fields[0] is { name: "x", is_mut: false, .. })
  assert_true(struct_def.fields[0].ty is { kind: Int, .. })
  assert_true(struct_def.fields[1] is { name: "y", is_mut: true, .. })
  assert_true(struct_def.fields[1].ty is { kind: Int, .. })
  assert_true(struct_def.fields[2] is { name: "z", is_mut: false, .. })
  assert_true(struct_def.fields[2].ty is { kind: Double, .. })
}
/// ================================================================================
/// # 程序的顶层结构：解析顶层函数
///
/// 我们已经能够解析语句和块内的局部函数了。现在，我们终于来到了构成一个完整程序的
/// 基本单元：**顶层函数（Top-level Function）**。
///
/// ## 顶层函数 vs. 局部函数
///
/// 顶层函数与我们之前解析的局部函数非常相似，但有几个关键的、更严格的约束：
///
/// 1.  **类型注解：** 顶层函数的所有参数都**必须**有明确的类型注解。
/// 2.  **返回类型：** 顶层函数**必须**有明确的返回类型注解。
/// 3.  **main 函数特例：** `fn main { ... }` 是一个特殊的顶层函数，它没有参数，返回类型默认为 `Unit`。
///
/// ## 顶层函数的 EBNF 范式
///
/// ```
/// top_fn ::= "fn" ident "(" (param ("," param)*)? ")" "->" type block_expr
/// param  ::= ident ":" type
/// ```
///
/// **注意：** 这个 EBNF 描述的是一般情况。你需要特殊处理 `fn main`。
///
/// ## 🎯 你的任务：实现 `parse_top_function`
///
/// 你的任务是在 `parser/top_function.mbt` 中实现 `parse_top_function` 函数。
///
/// **实现思路：**
///
/// 这个函数的解析逻辑与 `parse_local_function` 高度重合，你甚至可以复用一些辅助函数（例如解析参数列表）。
/// 主要的区别在于你需要更严格地检查类型注解是否存在。
///
/// 1.  解析 `fn` 关键字和函数名。
/// 2.  **检查是否为 `main` 函数**，如果是，则参数列表为空，返回类型为 `Unit`，然后直接解析函数体。
/// 3.  如果不是 `main`，则严格按照 EBNF 解析带类型注解的参数列表和返回类型。
/// 4.  调用 `parse_block_expr` 解析函数体。
///
/// 相信这对你来说只是小试牛刀。加油！
///
/// **阶段性测试：**
///
/// ```bash
/// moon test -p parser -f parse_top_function_test.mbt
/// ```
/// ================================================================================

///|
test "Top Function Parsing Test - 1" {
  let code =
    #|fn add(x: Int, y: Int) -> Int {
    #|  x + y;
    #|}
  let tokens = @lexer.tokenize(code)
  let (func, _) = parse_top_function(tokens)
  assert_true(func.fname is "add")
  assert_true(func.param_list.length() is 2)
  assert_true(func.param_list[0] is { name: "x", ty: { kind: Int, .. }, })
  assert_true(func.param_list[1] is { name: "y", ty: { kind: Int, .. }, })
  assert_true(func.ret_ty is { kind: Int, .. })
  assert_true(func.body.stmts.length() is 1)
  assert_true(func.body.stmts[0].kind is ExprStmt(_))
}

///|
test "Main Function Parsing Test - 2 (main)" {
  let code =
    #|fn main {
    #|  let x = 10;
    #|  let y = 20;
    #|  println(x + y);
    #|}
  let tokens = @lexer.tokenize(code)
  let (func, _) = parse_top_function(tokens)
  assert_true(func.fname is "main")
  assert_true(func.param_list.length() is 0)
  assert_true(func.ret_ty is { kind: Unit, .. })
  assert_true(func.body.stmts.length() is 3)
  assert_true(func.body.stmts[0].kind is LetStmt(_))
  assert_true(func.body.stmts[1].kind is LetStmt(_))
  assert_true(func.body.stmts[2].kind is ExprStmt(_))
}
/// ================================================================================
/// # 程序的顶层结构：解析顶层 let 绑定
///
/// 除了顶层函数，一个 MiniMoonBit 程序还可以包含顶层的 `let` 绑定，
/// 用于定义全局常量。
///
/// ## 顶层 `let` vs. 语句 `let`
///
/// 顶层 `let` 与我们在函数体内解析的 `let` 语句非常相似，但有一个核心区别：
///
/// **顶层 `let` 的左边只能是一个标识符，不能是复杂的模式。**
///
/// ## 顶层 `let` 的 EBNF 范式
///
/// ```
/// top_let ::= "let" ident (":" type)? "=" expr ";"
/// ```
///
/// ## 🎯 你的任务：实现 `parse_top_let`
///
/// 你的任务是在 `parser/top_let.mbt` 中实现 `parse_top_let` 函数。
///
/// 这个函数的逻辑与我们之前实现的 `parse_let_mut_stmt` 几乎一模一样，
/// 只是将 `let mut` 换成了 `let`。
///
/// 相信这个任务对你来说已经非常轻松了。
///
/// 加油！
///
/// **阶段性测试：**
///
/// ```bash
/// moon test -p parser -f parse_top_let_test.mbt
/// ```
/// ================================================================================

///|
test "Top Let Parsing Test" {
  let code =
    #|let x: Int = 42;
    #|let y: Bool = true;
    #|let z: Array[Int] = [1, 2, 3];
  let tokens = @lexer.tokenize(code)
  let (s, tok_view) = parse_top_let(tokens)
  assert_true(
    s.name is "x" &&
    s.ty is Some(ty) &&
    ty.kind is Int &&
    s.expr.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Int(42),
  )
  let (s, tok_view) = parse_top_let(tok_view)
  assert_true(
    s.name is "y" &&
    s.ty is Some(ty) &&
    ty.kind is Bool &&
    s.expr.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Bool(true),
  )
  let (s, _) = parse_top_let(tok_view)
  assert_true(
    s.name is "z" &&
    s.ty is Some(ty) &&
    ty.kind is Array(Int) &&
    s.expr.kind is ApplyExpr(a) &&
    a.kind is AtomExpr(atom) &&
    atom.kind is Array([e1, e2, e3]) &&
    e1.kind is ApplyExpr(a1) &&
    a1.kind is AtomExpr(atom1) &&
    atom1.kind is Int(1) &&
    e2.kind is ApplyExpr(a2) &&
    a2.kind is AtomExpr(atom2) &&
    atom2.kind is Int(2) &&
    e3.kind is ApplyExpr(a3) &&
    a3.kind is AtomExpr(atom3) &&
    atom3.kind is Int(3),
  )
}
/// ================================================================================
/// # 语法解析的另一分支：解析类型
///
/// 恭喜你！你已经征服了表达式解析中最艰难、最核心的部分。
/// 现在，让我们将目光从“值”的世界暂时移开，转向“类型”的世界。
///
/// 在 `parser/typedef.mbt` 中，你需要实现 `parse_type` 函数，
/// 它负责将 Token 序列解析为 MiniMoonBit 中的各种类型，例如 `Int`、`Array[Bool]`、`(Int, Double) -> Bool` 等。
///
/// 相信在经历了表达式解析的重重考验之后，类型的解析对你来说应该已经是小菜一碟了。
/// 它的逻辑与解析表达式有许多相似之处，但通常更简单，因为它不涉及运算符优先级等复杂问题。
///
/// 因此，这个挑战的教程就不再做过多展开了，请你尽情施展吧！
///
/// 加油！💪
///
/// **阶段性测试：**
///
/// ```bash
/// moon test -p parser -f parse_type_test.mbt
/// ```
/// ================================================================================

///|
test "Simple Type Parsing" {
  let code =
    #|Unit Int Bool Double
  let tokens = @lexer.tokenize(code)
  let (ty, tok_view) = parse_type(tokens[:])
  assert_true(ty.kind is Unit)
  let (ty, tok_view) = parse_type(tok_view)
  assert_true(ty.kind is Int)
  let (ty, tok_view) = parse_type(tok_view)
  assert_true(ty.kind is Bool)
  let (ty, _) = parse_type(tok_view)
  assert_true(ty.kind is Double)
}

///|
test "Complex Type Parsing" {
  let code =
    #|Array[Int]
    #|(Int, Double) 
    #|() -> Double
    #|((Int, Double), Unit)
    #|(Array[Bool], Unit) -> Double
    #|Array[(Int, Double)]
    #|Array[() -> Double]
    #|Array[((Int, Double), Unit)]
  let tokens = @lexer.tokenize(code)
  let (ty, tok_view) = parse_type(tokens[:])
  assert_true(ty.kind is Array(Int))
  let (ty, tok_view) = parse_type(tok_view)
  assert_true(ty.kind is Tuple([Int, Double]))
  let (ty, tok_view) = parse_type(tok_view)
  assert_true(ty.kind is Function([], Double))
  let (ty, tok_view) = parse_type(tok_view)
  assert_true(ty.kind is Tuple([Tuple([Int, Double]), Unit]))
  let (ty, tok_view) = parse_type(tok_view)
  assert_true(ty.kind is Function([Array(Bool), Unit], Double))
  let (ty, tok_view) = parse_type(tok_view)
  assert_true(ty.kind is Array(Tuple([Int, Double])))
  let (ty, tok_view) = parse_type(tok_view)
  assert_true(ty.kind is Array(Function([], Double)))
  let (ty, _) = parse_type(tok_view)
  assert_true(ty.kind is Array(Tuple([Tuple([Int, Double]), Unit])))
}
/// ================================================================================
/// # 循环的力量：解析 while 语句
///
/// 我们已经有了 `if-else` 作为分支结构，现在让我们来添加 MiniMoonBit 中唯一的循环结构：
/// **`while` 语句**。
///
/// `while` 语句允许我们根据一个条件重复地执行一个代码块。
///
/// ## `while` 语句的 EBNF 范式
///
/// `while` 语句的结构非常简单明了：
///
/// ```
/// while_stmt ::= "while" expr block_expr
/// ```
///
/// 它由 `while` 关键字、一个条件表达式和一个循环体代码块组成。
///
/// ## 🎯 你的任务：实现 `parse_while_stmt`
///
/// 你的任务是在 `parser/while_stmt.mbt` 中实现 `parse_while_stmt` 函数。
///
/// 这个解析任务非常直接：
/// 1.  匹配 `while` 关键字。
/// 2.  调用 `parse_expr` 解析条件表达式。
/// 3.  调用 `parse_block_expr` 解析循环体。
///
/// 相信这对你来说已经轻而易举了。加油！
///
/// **阶段性测试：**
///
/// ```bash
/// moon test -p parser -f parse_while_stmt_test.mbt
/// ```
/// ================================================================================

///|
test "Parse While Stmt Test" {
  let code =
    #|while a < b { a += 1; b -=2; }
    #|while a < b { println(a); a += b % 3; } 
  let tokens = @lexer.tokenize(code)
  let (while_stmt1, tok_view) = parse_while_stmt(tokens[:])
  assert_true(while_stmt1.body.stmts.length() is 2)
  let (while_stmt2, _) = parse_while_stmt(tok_view)
  assert_true(while_stmt2.body.stmts.length() is 2)
}
