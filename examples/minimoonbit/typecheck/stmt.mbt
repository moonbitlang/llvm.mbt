///|
/// Represents the MiniMoonBit typed AST node or context `Stmt`.
pub(all) struct Stmt {
  /// Stores the `kind` component of this typed AST value.
  kind : StmtKind
}

///|
/// Formats `Stmt` using MiniMoonBit typed AST notation.
pub impl Show for Stmt with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `Stmt` value with optional ANSI coloring.
pub fn Stmt::to_string(self : Self, color? : Bool = true) -> String {
  match self.kind {
    LetStmt(let_stmt) => let_stmt.to_string(color~)
    LetMutStmt(let_mut_stmt) => let_mut_stmt.to_string(color~)
    AssignStmt(assign_stmt) => assign_stmt.to_string(color~)
    ExprStmt(expr) => expr.to_string(color~)
    ReturnStmt(expr_opt) => {
      let prefix = "return statement"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      match expr_opt {
        Some(expr) => {
          let expr_str = expr.to_string(color~)
          let expr_lines = expr_str
            .split("\n")
            .map(sv => sv.to_owned())
            .to_array()
          let expr_formatted = @parser.format_lines(expr_lines)
          "\{prefix}\n\{expr_formatted}"
        }
        None => prefix
      }
    }
    WhileStmt(while_stmt) => while_stmt.to_string(color~)
    ForStmt(for_stmt) => for_stmt.to_string(color~)
    LocalFunction(local_fn) => local_fn.to_string(color~)
  }
}

///|
/// Enumerates the typed forms represented by `StmtKind`.
pub(all) enum StmtKind {
  /// Represents the `LetStmt` typed AST form.
  LetStmt(LetStmt)
  /// Represents the `LetMutStmt` typed AST form.
  LetMutStmt(LetMutStmt)
  /// Represents the `AssignStmt` typed AST form.
  AssignStmt(AssignStmt)
  /// Represents the `WhileStmt` typed AST form.
  WhileStmt(WhileStmt)
  /// Represents the `ForStmt` typed AST form.
  ForStmt(ForStmt)
  /// Represents the `ExprStmt` typed AST form.
  ExprStmt(Expr)
  /// Represents the `ReturnStmt` typed AST form.
  ReturnStmt(Expr?)
  /// Represents the `LocalFunction` typed AST form.
  LocalFunction(LocalFunction)
}

///|
/// Formats `StmtKind` using MiniMoonBit typed AST notation.
pub impl Show for StmtKind with fn output(self, logger) {
  let s = match self {
    LetStmt(let_stmt) => let_stmt.to_string()
    LetMutStmt(let_mut_stmt) => let_mut_stmt.to_string()
    AssignStmt(assign_stmt) => assign_stmt.to_string()
    ExprStmt(expr) => "expr: \{expr}"
    ReturnStmt(Some(expr)) => "return \{expr}"
    ReturnStmt(None) => "return"
    WhileStmt(_) => "while (...) { ... }"
    ForStmt(_) => "for (...) { ... }"
    LocalFunction(_) => "fn (...) { ... }"
  }
  logger.write_string(s)
}

///|
/// Type-checks the corresponding parser AST form through `check_stmt`.
pub fn Context::check_stmt(
  self : Context,
  stmt : @parser.Stmt,
) -> Stmt raise TypeCheckError {
  match stmt.kind {
    LetStmt(let_stmt) => {
      let checked_let = self.check_let_stmt(let_stmt)
      Stmt::{ kind: LetStmt(checked_let) }
    }
    LetMutStmt(let_mut_stmt) => {
      let checked_let_mut = self.check_let_mut_stmt(let_mut_stmt)
      Stmt::{ kind: LetMutStmt(checked_let_mut) }
    }
    AssignStmt(assign_stmt) => {
      let checked_assign = self.check_assign_stmt(assign_stmt)
      Stmt::{ kind: AssignStmt(checked_assign) }
    }
    ExprStmt(expr) => {
      let checked_expr = self.check_expr(expr)
      Stmt::{ kind: ExprStmt(checked_expr) }
    }
    ReturnStmt(None) => {
      guard self.current_func_ret_ty is Some(func_ret_ty) else {
        raise TypeCheckError("Return statement used outside of a function")
      }
      if !self.is_type_compatible(func_ret_ty, Unit) {
        raise TypeCheckError(
          "Return statement without value in function with non-unit return type",
        )
      }
      Stmt::{ kind: ReturnStmt(None) }
    }
    ReturnStmt(Some(expr)) => {
      let checked_expr = self.check_expr(expr)
      guard self.current_func_ret_ty is Some(func_ret_ty) else {
        raise TypeCheckError("Return statement used outside of a function")
      }
      if !self.is_type_compatible(func_ret_ty, checked_expr.ty) {
        raise TypeCheckError(
          "Return type mismatch, wanted: \{func_ret_ty}, got: \{checked_expr.ty}",
        )
      }
      Stmt::{ kind: ReturnStmt(Some(checked_expr)) }
    }
    WhileStmt(while_stmt) => {
      let checked_while = self.check_while_stmt(while_stmt)
      Stmt::{ kind: WhileStmt(checked_while) }
    }
    ForStmt(for_stmt) => {
      let checked_for = self.check_for_stmt(for_stmt)
      Stmt::{ kind: ForStmt(checked_for) }
    }
    LocalFunction(local_function) => {
      let checked_local_function = self.check_local_function(local_function)
      Stmt::{ kind: LocalFunction(checked_local_function) }
    }
    NoopStmt => raise TypeCheckError("Error happened in Parser Phase")
  }
}

///|
test "Stmt to_string Test - Basic" {
  let color = false
  let ctx = Context::new()

  // Test LetStmt: let x = 42
  let code1 = "let x = 42 ;"
  let tokens1 = @lexer.tokenize(code1)
  let (stmt, _) = @parser.parse_stmt(tokens1[:])
  let checked = ctx.check_stmt(stmt)
  inspect(
    checked.to_string(color~),
    content=(
      #|let statement
      #|├-pattern: ident pattern x
      #|├-type: : Int
      #|└-expr: int literal 42 (Int)
    ),
  )

  // Test LetMutStmt: let mut y = 10
  let code2 = "let mut y = 10 ;"
  let tokens2 = @lexer.tokenize(code2)
  let (stmt, _) = @parser.parse_stmt(tokens2[:])
  let checked = ctx.check_stmt(stmt)
  inspect(
    checked.to_string(color~),
    content=(
      #|let mut statement
      #|├-name: y
      #|├-type: : Int
      #|└-expr: int literal 10 (Int)
    ),
  )

  // Test AssignStmt: x = 20
  ctx.type_env.set("x", { kind: TypeKind::Int, mutable: true })
  let code3 = "x = 20 ;"
  let tokens3 = @lexer.tokenize(code3)
  let (stmt, _) = @parser.parse_stmt(tokens3[:])
  let checked = ctx.check_stmt(stmt)
  inspect(
    checked.to_string(color~),
    content=(
      #|assign statement: =
      #|├-lvalue: lvalue x (Int)
      #|└-expr: int literal 20 (Int)
    ),
  )
}

///|
test "Stmt to_string Test - Expr and Return" {
  let color = false
  let ctx = Context::new()
  ctx.type_env.set("foo", {
    kind: TypeKind::Function([TypeKind::Int], TypeKind::Unit),
    mutable: false,
  })

  // Test ExprStmt: foo(42)
  let code1 = "foo(42) ;"
  let tokens1 = @lexer.tokenize(code1)
  let (stmt, _) = @parser.parse_stmt(tokens1[:])
  let checked = ctx.check_stmt(stmt)
  inspect(
    checked.to_string(color~),
    content=(
      #|function call (Unit)
      #|├-variable foo ((Int) -> Unit)
      #|└-int literal 42 (Int)
    ),
  )

  // Test ReturnStmt with no expr: return
  ctx.current_func_ret_ty = Some(TypeKind::Unit)
  let code2 = "return ;"
  let tokens2 = @lexer.tokenize(code2)
  let (stmt, _) = @parser.parse_stmt(tokens2[:])
  let checked = ctx.check_stmt(stmt)
  inspect(checked.to_string(color~), content="return statement")

  // Test ReturnStmt with expr: return 100
  ctx.current_func_ret_ty = Some(TypeKind::Int)
  let code3 = "return 100 ;"
  let tokens3 = @lexer.tokenize(code3)
  let (stmt, _) = @parser.parse_stmt(tokens3[:])
  let checked = ctx.check_stmt(stmt)
  inspect(
    checked.to_string(color~),
    content=(
      #|return statement
      #|└-int literal 100 (Int)
    ),
  )
}
