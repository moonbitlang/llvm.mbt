///|
/// Performs the `let_stmt_to_knf` KNF lowering operation.
pub fn Context::let_stmt_to_knf(
  self : Context,
  let_stmt : @typecheck.LetStmt,
) -> Array[KnfStmt] raise KnfTransformError {
  let stmts = Array::Array(capacity=0)
  let (expr_stmts, init_expr) = self.expr_to_knf(let_stmt.expr)
  stmts.append(expr_stmts)
  let ty = self.typekind_to_knf(let_stmt.ty)
  let ss = self.bind_pattern_to_expr(let_stmt.pattern, ty, init_expr)
  stmts.append(ss)
  stmts
}

///|
fn Context::bind_pattern_to_expr(
  self : Context,
  pattern : @typecheck.Pattern,
  ty : Type,
  expr : KnfExpr,
) -> Array[KnfStmt] raise KnfTransformError {
  let stmts = Array::Array(capacity=0)
  match (pattern.kind, ty, expr) {
    (Ident(name), ty, expr) => {
      let new_name = self.add_new_name(name, ty)
      let knf_let = KnfStmt::Let(new_name, ty, expr)
      stmts.push(knf_let)
    }
    (Wildcard, ty, expr) => {
      let wild_card = Name::wildcard()
      let knf_let = KnfStmt::Let(wild_card, ty, expr)
      stmts.push(knf_let)
    }
    (Tuple(sub_patterns), Tuple(sub_types), TupleLiteral(names)) => {
      let len = sub_patterns.length()
      guard len == sub_types.length() && len == names.length() else {
        raise KnfTransformError(
          "Pattern, type, and expression tuple length mismatch",
        )
      }
      for i in 0..<len {
        let inner_stmts = self.bind_pattern_to_expr(
          sub_patterns[i],
          sub_types[i],
          KnfExpr::Ident(names[i]),
        )
        stmts.append(inner_stmts)
      }
    }
    (Tuple(sub_patterns), Tuple(sub_types), expr) => {
      let len = sub_patterns.length()
      guard len == sub_types.length() else {
        raise KnfTransformError("Pattern and type tuple length mismatch")
      }
      let expr_name = self.add_temp(ty)
      let let_expr = KnfStmt::Let(expr_name, ty, expr)
      stmts.push(let_expr)
      for i in 0..<len {
        let tuple_acc = KnfExpr::TupleAccess(expr_name, i)
        let inner_stmts = self.bind_pattern_to_expr(
          sub_patterns[i],
          sub_types[i],
          tuple_acc,
        )
        stmts.append(inner_stmts)
      }
    }
    _ => raise KnfTransformError("TypeError in pattern binding")
  }
  stmts
}
