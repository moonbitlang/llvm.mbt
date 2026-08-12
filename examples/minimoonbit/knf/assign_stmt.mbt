///|
/// Enumerates the KNF forms represented by `KnfLeftValue`.
pub(all) enum KnfLeftValue {
  /// Represents the `Ident` KNF form.
  Ident(Name)
  /// Represents the `ArrayAcc` KNF form.
  ArrayAcc(Name, Name)
  /// Represents the `FieldAcc` KNF form.
  FieldAcc(Name, String)
}

///|
/// Performs the `to_knf_expr` operation on `KnfLeftValue`.
pub fn KnfLeftValue::to_knf_expr(self : KnfLeftValue) -> KnfExpr {
  match self {
    Ident(name) => KnfExpr::Ident(name)
    ArrayAcc(array_name, index_name) =>
      KnfExpr::ArrayAccess(array_name, index_name)
    FieldAcc(struct_name, field_name) =>
      KnfExpr::FieldAccess(struct_name, field_name)
  }
}

///|
/// Performs the `assign_stmt_to_knf` KNF lowering operation.
pub fn Context::assign_stmt_to_knf(
  self : Context,
  assign_stmt : @typecheck.AssignStmt,
) -> Array[KnfStmt] raise KnfTransformError {
  let stmts = Array::new()
  let (lv_stmts, knf_left_value) = self.left_value_to_knf(
    assign_stmt.left_value,
  )
  stmts.append(lv_stmts)
  let (expr_stmts, knf_expr) = self.expr_to_knf(assign_stmt.expr)
  stmts.append(expr_stmts)

  // Handle compound assignment operators
  let final_expr = match assign_stmt.op {
    Assign => knf_expr
    PlusAssign => {
      let left_expr = knf_left_value.to_knf_expr()
      let ty = self.typekind_to_knf(assign_stmt.left_value.ty.kind)
      let left_name = self.expr_to_knf_name(left_expr, ty, stmts)
      let right_name = self.expr_to_knf_name(knf_expr, ty, stmts)
      let result_name = self.add_temp(ty)
      let result_let = KnfStmt::Let(
        result_name,
        ty,
        KnfExpr::Binary(BinaryOp::Add, left_name, right_name),
      )
      stmts.push(result_let)
      KnfExpr::Ident(result_name)
    }
    MinusAssign => {
      let left_expr = knf_left_value.to_knf_expr()
      let ty = self.typekind_to_knf(assign_stmt.left_value.ty.kind)
      let left_name = self.expr_to_knf_name(left_expr, ty, stmts)
      let right_name = self.expr_to_knf_name(knf_expr, ty, stmts)
      let result_name = self.add_temp(ty)
      let result_let = KnfStmt::Let(
        result_name,
        ty,
        KnfExpr::Binary(BinaryOp::Sub, left_name, right_name),
      )
      stmts.push(result_let)
      KnfExpr::Ident(result_name)
    }
    MultAssign => {
      let left_expr = knf_left_value.to_knf_expr()
      let ty = self.typekind_to_knf(assign_stmt.left_value.ty.kind)
      let left_name = self.expr_to_knf_name(left_expr, ty, stmts)
      let right_name = self.expr_to_knf_name(knf_expr, ty, stmts)
      let result_name = self.add_temp(ty)
      let result_let = KnfStmt::Let(
        result_name,
        ty,
        KnfExpr::Binary(BinaryOp::Mul, left_name, right_name),
      )
      stmts.push(result_let)
      KnfExpr::Ident(result_name)
    }
    DivAssign => {
      let left_expr = knf_left_value.to_knf_expr()
      let ty = self.typekind_to_knf(assign_stmt.left_value.ty.kind)
      let left_name = self.expr_to_knf_name(left_expr, ty, stmts)
      let right_name = self.expr_to_knf_name(knf_expr, ty, stmts)
      let result_name = self.add_temp(ty)
      let result_let = KnfStmt::Let(
        result_name,
        ty,
        KnfExpr::Binary(BinaryOp::Div, left_name, right_name),
      )
      stmts.push(result_let)
      KnfExpr::Ident(result_name)
    }
    ModAssign => {
      let left_expr = knf_left_value.to_knf_expr()
      let ty = self.typekind_to_knf(assign_stmt.left_value.ty.kind)
      let left_name = self.expr_to_knf_name(left_expr, ty, stmts)
      let right_name = self.expr_to_knf_name(knf_expr, ty, stmts)
      let result_name = self.add_temp(ty)
      let result_let = KnfStmt::Let(
        result_name,
        ty,
        KnfExpr::Binary(BinaryOp::Mod, left_name, right_name),
      )
      stmts.push(result_let)
      KnfExpr::Ident(result_name)
    }
  }
  match knf_left_value {
    Ident(name) => stmts.push(KnfStmt::Assign(name, final_expr))
    ArrayAcc(array_name, index_name) =>
      stmts.push(KnfStmt::ArrayPut(array_name, index_name, final_expr))
    FieldAcc(struct_name, field_name) => {
      let value_ty = self.typekind_to_knf(assign_stmt.expr.ty)
      let value_name = self.add_temp(value_ty)
      let value_let = KnfStmt::Let(value_name, value_ty, final_expr)
      stmts.push(value_let)
      stmts.push(KnfStmt::StructFieldSet(struct_name, field_name, value_name))
    }
  }
  stmts
}

///|
/// Performs the `left_value_to_knf` KNF lowering operation.
pub fn Context::left_value_to_knf(
  self : Context,
  left_value : @typecheck.LeftValue,
) -> (Array[KnfStmt], KnfLeftValue) raise KnfTransformError {
  match left_value.kind {
    Ident(name) => {
      guard self.lookup_name(name) is Some((name, _)) else {
        raise KnfTransformError("Undefined variable in left value: \{name}")
      }
      (Array::new(), KnfLeftValue::Ident(name))
    }
    ArrayAccess(array_lv, index_expr) => {
      let (stmts, knf_array_lv) = self.left_value_to_knf(array_lv)
      let (index_stmts, knf_index_expr) = self.expr_to_knf(index_expr)
      stmts.append(index_stmts)
      let lv_expr = knf_array_lv.to_knf_expr()
      let lv_type = self.typekind_to_knf(array_lv.ty.kind)
      let lv_name = self.expr_to_knf_name(lv_expr, lv_type, stmts)
      let index_type = self.typekind_to_knf(index_expr.ty)
      let index_name = self.expr_to_knf_name(knf_index_expr, index_type, stmts)
      (stmts, KnfLeftValue::ArrayAcc(lv_name, index_name))
    }
    FieldAccess(struct_lv, field_name) => {
      let (stmts, knf_struct_lv) = self.left_value_to_knf(struct_lv)
      let lv_expr = knf_struct_lv.to_knf_expr()
      let lv_type = self.typekind_to_knf(left_value.ty.kind)
      let lv_name = self.expr_to_knf_name(lv_expr, lv_type, stmts)
      (stmts, KnfLeftValue::FieldAcc(lv_name, field_name))
    }
  }
}
