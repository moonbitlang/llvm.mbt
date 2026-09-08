///|
/// Performs the `let_mut_stmt_to_knf` KNF lowering operation.
pub fn Context::let_mut_stmt_to_knf(
  self : Context,
  let_mut_stmt : @typecheck.LetMutStmt,
) -> Array[KnfStmt] raise KnfTransformError {
  let stmts = Array::Array(capacity=0)
  let (expr_stmts, init_expr) = self.expr_to_knf(let_mut_stmt.expr)
  stmts.append(expr_stmts)
  let ty = self.typekind_to_knf(let_mut_stmt.ty)
  let name = self.add_new_name(let_mut_stmt.name, ty, mutable=true)
  let knf_let_mut = KnfStmt::LetMut(name, ty, init_expr)
  stmts.push(knf_let_mut)
  stmts
}
