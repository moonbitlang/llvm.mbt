///|
/// Performs the `while_stmt_to_knf` KNF lowering operation.
pub fn Context::while_stmt_to_knf(
  self : Context,
  while_stmt : @typecheck.WhileStmt,
) -> Array[KnfStmt] raise KnfTransformError {
  // Transform condition expression
  let (cond_stmts, cond_knf_expr) = self.expr_to_knf(while_stmt.cond)
  cond_stmts.push(KnfStmt::ExprStmt(cond_knf_expr))
  let cond_ty = self.typekind_to_knf(while_stmt.cond.ty)
  let cond_block = KnfBlock::{ stmts: cond_stmts, ty: cond_ty }

  // Transform body block
  let body_block = self.block_expr_to_knf(while_stmt.body)
  [KnfStmt::While(cond_block, body_block)]
}

///|
/// Performs the `for_stmt_to_knf` KNF lowering operation.
pub fn Context::for_stmt_to_knf(
  self : Context,
  for_stmt : @typecheck.ForStmt,
) -> Array[KnfStmt] raise KnfTransformError {
  // Transform for loop to while loop:
  // for (init1, init2; cond; step1, step2) { body }
  // =>
  // {
  //   init1;
  //   init2;
  //   while (cond) {
  //     body;
  //     step1;
  //     step2;
  //   }
  // }

  let stmts = Array::new()

  // 1. Transform init statements
  for init in for_stmt.inits {
    let (name, init_expr) = init
    let (init_stmts, knf_init_expr) = self.expr_to_knf(init_expr)
    stmts.append(init_stmts)

    // Register the variable with KNF context
    let ty = self.typekind_to_knf(init_expr.ty)
    let knf_name = self.add_new_name(name, ty)

    // Create let mut statement for initialization (variables are mutable in for loops)
    stmts.push(KnfStmt::LetMut(knf_name, ty, knf_init_expr))
  }

  // 2. Transform condition expression
  let (cond_stmts, cond_knf_expr) = self.expr_to_knf(for_stmt.cond)
  cond_stmts.push(KnfStmt::ExprStmt(cond_knf_expr))
  let cond_ty = self.typekind_to_knf(for_stmt.cond.ty)
  let cond_block = KnfBlock::{ stmts: cond_stmts, ty: cond_ty }

  // 3. Transform body block
  let body_stmts = Array::new()
  // Add original body statements
  for stmt in for_stmt.body.stmts {
    let knf_stmts = self.stmt_to_knf(stmt)
    body_stmts.append(knf_stmts)
  }

  // 4. Add step statements at the end of body
  for step in for_stmt.steps {
    let (name, op, step_expr) = step
    // Look up the variable
    guard self.lookup_name(name) is Some((knf_name, var_ty)) else {
      raise KnfTransformError("Undefined variable in for loop step: \{name}")
    }
    let (step_stmts, knf_step_expr) = self.expr_to_knf(step_expr)
    body_stmts.append(step_stmts)

    // Handle different assignment operators
    let final_expr = match op {
      Assign => knf_step_expr
      PlusAssign => {
        let left_name = knf_name
        let right_name = self.expr_to_knf_name(
          knf_step_expr, var_ty, body_stmts,
        )
        let result_name = self.add_temp(var_ty)
        let result_let = KnfStmt::Let(
          result_name,
          var_ty,
          KnfExpr::Binary(BinaryOp::Add, left_name, right_name),
        )
        body_stmts.push(result_let)
        KnfExpr::Ident(result_name)
      }
      MinusAssign => {
        let left_name = knf_name
        let right_name = self.expr_to_knf_name(
          knf_step_expr, var_ty, body_stmts,
        )
        let result_name = self.add_temp(var_ty)
        let result_let = KnfStmt::Let(
          result_name,
          var_ty,
          KnfExpr::Binary(BinaryOp::Sub, left_name, right_name),
        )
        body_stmts.push(result_let)
        KnfExpr::Ident(result_name)
      }
      MultAssign => {
        let left_name = knf_name
        let right_name = self.expr_to_knf_name(
          knf_step_expr, var_ty, body_stmts,
        )
        let result_name = self.add_temp(var_ty)
        let result_let = KnfStmt::Let(
          result_name,
          var_ty,
          KnfExpr::Binary(BinaryOp::Mul, left_name, right_name),
        )
        body_stmts.push(result_let)
        KnfExpr::Ident(result_name)
      }
      DivAssign => {
        let left_name = knf_name
        let right_name = self.expr_to_knf_name(
          knf_step_expr, var_ty, body_stmts,
        )
        let result_name = self.add_temp(var_ty)
        let result_let = KnfStmt::Let(
          result_name,
          var_ty,
          KnfExpr::Binary(BinaryOp::Div, left_name, right_name),
        )
        body_stmts.push(result_let)
        KnfExpr::Ident(result_name)
      }
      ModAssign => {
        let left_name = knf_name
        let right_name = self.expr_to_knf_name(
          knf_step_expr, var_ty, body_stmts,
        )
        let result_name = self.add_temp(var_ty)
        let result_let = KnfStmt::Let(
          result_name,
          var_ty,
          KnfExpr::Binary(BinaryOp::Mod, left_name, right_name),
        )
        body_stmts.push(result_let)
        KnfExpr::Ident(result_name)
      }
    }
    body_stmts.push(KnfStmt::Assign(knf_name, final_expr))
  }
  let body_ty = self.typekind_to_knf(for_stmt.body.ty)
  let body_block = KnfBlock::{ stmts: body_stmts, ty: body_ty }

  // 5. Create while statement
  stmts.push(KnfStmt::While(cond_block, body_block))
  stmts
}
