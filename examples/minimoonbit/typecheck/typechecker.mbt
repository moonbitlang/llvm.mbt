///|
/// Runs the MiniMoonBit type-checker operation `typecheck`.
pub fn typecheck(program : @parser.Program) -> Program raise TypeCheckError {
  let ctx = Context::new()
  let checked_program = ctx.check_program(program)
  if ctx.has_error_happened() {
    raise TypeCheckError("Type checking failed.")
  }
  ctx.substitute_type_var(checked_program)
}

///|
/// Performs the `substitute_type_var` type-checker context operation.
pub fn Context::substitute_type_var(
  self : Context,
  program : Program,
) -> Program raise TypeCheckError {
  for name, top_let in program.top_lets {
    let new_top_let = self.substitute_top_let_type_var(top_let)
    program.top_lets.set(name, new_top_let)
  }
  for name, top_function in program.top_functions {
    let new_top_function = self.substitute_top_function_type_var(top_function)
    program.top_functions.set(name, new_top_function)
  }
  program
}

///|
/// Performs the `substitute_top_let_type_var` type-checker context operation.
pub fn Context::substitute_top_let_type_var(
  self : Context,
  top_let : TopLet,
) -> TopLet raise TypeCheckError {
  let new_ty_kind = self.ensure_type(top_let.ty.kind)
  let new_ty = Type::{ kind: new_ty_kind, mutable: top_let.ty.mutable, }
  let new_expr = self.substitute_expr_type_var(top_let.expr)
  TopLet::{ name: top_let.name, ty: new_ty, expr: new_expr, }
}

///|
/// Performs the `substitute_expr_type_var` type-checker context operation.
pub fn Context::substitute_expr_type_var(
  self : Context,
  expr : Expr,
) -> Expr raise TypeCheckError {
  let new_ty_kind = self.ensure_type(expr.ty)
  let new_expr_kind = match expr.kind {
    ExprKind::ApplyExpr(apply_expr) => {
      let new_apply_expr = self.substitute_apply_expr_type_var(apply_expr)
      ExprKind::ApplyExpr(new_apply_expr)
    }
    ExprKind::NotExpr(inner_expr) => {
      let new_inner_expr = self.substitute_expr_type_var(inner_expr)
      ExprKind::NotExpr(new_inner_expr)
    }
    ExprKind::NegExpr(inner_expr) => {
      let new_inner_expr = self.substitute_expr_type_var(inner_expr)
      ExprKind::NegExpr(new_inner_expr)
    }
    ExprKind::BinaryExpr(op, left_expr, right_expr) => {
      let new_left_expr = self.substitute_expr_type_var(left_expr)
      let new_right_expr = self.substitute_expr_type_var(right_expr)
      ExprKind::BinaryExpr(op, new_left_expr, new_right_expr)
    }
    ExprKind::IfExpr(if_expr) => {
      let new_if_expr = self.substitute_if_expr_type_var(if_expr)
      ExprKind::IfExpr(new_if_expr)
    }
    ExprKind::BlockExpr(block_expr) => {
      let new_block_expr = self.substitute_block_expr_type_var(block_expr)
      ExprKind::BlockExpr(new_block_expr)
    }
    MatchExpr(match_expr) => {
      let new_match_expr = self.substitute_match_expr_type_var(match_expr)
      MatchExpr(new_match_expr)
    }
  }
  Expr::{ kind: new_expr_kind, ty: new_ty_kind, toks: expr.toks, }
}

///|
/// Performs the `substitute_apply_expr_type_var` type-checker context operation.
pub fn Context::substitute_apply_expr_type_var(
  self : Context,
  apply_expr : ApplyExpr,
) -> ApplyExpr raise TypeCheckError {
  let new_ty_kind = self.ensure_type(apply_expr.ty)
  let new_apply_expr_kind = match apply_expr.kind {
    ApplyExprKind::AtomExpr(atom_expr) => {
      let new_atom_expr = self.substitute_atom_expr_type_var(atom_expr)
      ApplyExprKind::AtomExpr(new_atom_expr)
    }
    ApplyExprKind::ArrayAccess(array_expr, index_expr) => {
      let new_array_expr = self.substitute_apply_expr_type_var(array_expr)
      let new_index_expr = self.substitute_expr_type_var(index_expr)
      ApplyExprKind::ArrayAccess(new_array_expr, new_index_expr)
    }
    ApplyExprKind::FieldAccess(struct_expr, field_name) => {
      let new_struct_expr = self.substitute_apply_expr_type_var(struct_expr)
      ApplyExprKind::FieldAccess(new_struct_expr, field_name)
    }
    ApplyExprKind::Call(callee_expr, arg_exprs) => {
      let new_arg_exprs = Array::new()
      for arg in arg_exprs {
        let new_arg = self.substitute_expr_type_var(arg)
        new_arg_exprs.push(new_arg)
      }
      let new_callee_expr = self.substitute_apply_expr_type_var(callee_expr)
      let new_callee_expr = if new_callee_expr.kind is AtomExpr(a) {
        if a.kind is Ident("println") {
          let arg_ty = new_arg_exprs[0].ty
          let (new_callee_name, new_callee_arg_ty) = match arg_ty {
            Int => ("__builtin_println_int", TypeKind::Int)
            Int64 => ("__builtin_println_int64", Int64)
            UInt => ("__builtin_println_uint", UInt)
            UInt64 => ("__builtin_println_uint64", UInt64)
            Double => ("__builtin_println_double", Double)
            Float => ("__builtin_println_float", Float)
            Char => ("__builtin_println_char", Char)
            Bool => ("__builtin_println_bool", Bool)
            String => ("__builtin_println_string", String)
            ty =>
              raise TypeCheckError("println does not support this type: \{ty}")
          }
          let callee_atom_kind = AtomExprKind::Ident(new_callee_name)
          let callee_type_kind = Function([new_callee_arg_ty], Unit)
          let callee_atom_expr = AtomExpr::{
            kind: callee_atom_kind,
            ty: callee_type_kind,
            toks: a.toks,
          }
          ApplyExpr::{
            kind: AtomExpr(callee_atom_expr),
            ty: callee_type_kind,
            toks: callee_atom_expr.toks,
          }
        } else if a.kind is Ident("print") {
          let arg_ty = new_arg_exprs[0].ty
          let (new_callee_name, new_callee_arg_ty) = match arg_ty {
            Int => ("__builtin_print_int", TypeKind::Int)
            Int64 => ("__builtin_print_int64", Int64)
            UInt => ("__builtin_print_uint", UInt)
            UInt64 => ("__builtin_print_uint64", UInt64)
            Double => ("__builtin_print_double", Double)
            Float => ("__builtin_print_float", Float)
            Char => ("__builtin_print_char", Char)
            Bool => ("__builtin_print_bool", Bool)
            String => ("__builtin_print_string", String)
            ty =>
              raise TypeCheckError("print does not support this type: \{ty}")
          }
          let callee_atom_kind = AtomExprKind::Ident(new_callee_name)
          let callee_type_kind = Function([new_callee_arg_ty], Unit)
          let callee_atom_expr = AtomExpr::{
            kind: callee_atom_kind,
            ty: callee_type_kind,
            toks: a.toks,
          }
          ApplyExpr::{
            kind: AtomExpr(callee_atom_expr),
            ty: callee_type_kind,
            toks: callee_atom_expr.toks,
          }
        } else {
          new_callee_expr
        }
      } else {
        new_callee_expr
      }
      ApplyExprKind::Call(new_callee_expr, new_arg_exprs)
    }
  }
  ApplyExpr::{
    kind: new_apply_expr_kind,
    ty: new_ty_kind,
    toks: apply_expr.toks,
  }
}

///|
/// Performs the `substitute_atom_expr_type_var` type-checker context operation.
pub fn Context::substitute_atom_expr_type_var(
  self : Context,
  atom_expr : AtomExpr,
) -> AtomExpr raise TypeCheckError {
  let new_ty_kind = self.ensure_type(atom_expr.ty)
  let new_atom_expr_kind = match atom_expr.kind {
    AtomExprKind::Unit => AtomExprKind::Unit
    AtomExprKind::Int(value) => AtomExprKind::Int(value)
    AtomExprKind::Int64(value) => AtomExprKind::Int64(value)
    AtomExprKind::UInt(value) => AtomExprKind::UInt(value)
    AtomExprKind::UInt64(value) => AtomExprKind::UInt64(value)
    AtomExprKind::Double(value) => AtomExprKind::Double(value)
    AtomExprKind::Float(value) => AtomExprKind::Float(value)
    AtomExprKind::Char(value) => AtomExprKind::Char(value)
    AtomExprKind::Bool(value) => AtomExprKind::Bool(value)
    AtomExprKind::Ident(name) => AtomExprKind::Ident(name)
    AtomExprKind::String(value) => AtomExprKind::String(value)
    AtomExprKind::Paren(inner_expr) => {
      let new_inner_expr = self.substitute_expr_type_var(inner_expr)
      AtomExprKind::Paren(new_inner_expr)
    }
    AtomExprKind::Array(exprs) => {
      let new_exprs = Array::new()
      for expr in exprs {
        let new_expr = self.substitute_expr_type_var(expr)
        new_exprs.push(new_expr)
      }
      AtomExprKind::Array(new_exprs)
    }
    AtomExprKind::ArrayMake(size_expr, init_expr) => {
      let new_size_expr = self.substitute_expr_type_var(size_expr)
      let new_init_expr = self.substitute_expr_type_var(init_expr)
      AtomExprKind::ArrayMake(new_size_expr, new_init_expr)
    }
    AtomExprKind::Tuple(exprs) => {
      let new_exprs = Array::new()
      for expr in exprs {
        let new_expr = self.substitute_expr_type_var(expr)
        new_exprs.push(new_expr)
      }
      AtomExprKind::Tuple(new_exprs)
    }
    AtomExprKind::StructConstruct(sc_expr) => {
      let new_sc_expr = self.substitute_struct_construct_expr_type_var(sc_expr)
      AtomExprKind::StructConstruct(new_sc_expr)
    }
    AtomExprKind::Cast(target_ty, expr) => {
      let new_target_ty = self.ensure_type(target_ty)
      let new_expr = self.substitute_expr_type_var(expr)
      AtomExprKind::Cast(new_target_ty, new_expr)
    }
    AtomExprKind::BitCast(target_ty, expr) => {
      let new_target_ty = self.ensure_type(target_ty)
      let new_expr = self.substitute_expr_type_var(expr)
      AtomExprKind::BitCast(new_target_ty, new_expr)
    }
    AtomExprKind::EnumConstruct(tag, name, exprs) => {
      let new_exprs = Array::new()
      for expr in exprs {
        let new_expr = self.substitute_expr_type_var(expr)
        new_exprs.push(new_expr)
      }
      AtomExprKind::EnumConstruct(tag, name, new_exprs)
    }
  }
  AtomExpr::{ kind: new_atom_expr_kind, ty: new_ty_kind, toks: atom_expr.toks, }
}

///|
/// Performs the `substitute_struct_construct_expr_type_var` type-checker context operation.
pub fn Context::substitute_struct_construct_expr_type_var(
  self : Context,
  sc_expr : StructConstructExpr,
) -> StructConstructExpr raise TypeCheckError {
  let new_fields = Array::new()
  for field in sc_expr.fields {
    let (field_name, field_expr) = field
    let new_field_expr = self.substitute_expr_type_var(field_expr)
    new_fields.push((field_name, new_field_expr))
  }
  StructConstructExpr::{
    name: sc_expr.name,
    fields: new_fields,
    toks: sc_expr.toks,
  }
}

///|
/// Performs the `substitute_stmt_type_var` type-checker context operation.
pub fn Context::substitute_stmt_type_var(
  self : Context,
  stmt : Stmt,
) -> Stmt raise TypeCheckError {
  let new_stmt_kind = match stmt.kind {
    StmtKind::LetStmt(let_stmt) => {
      let new_let_stmt = self.substitute_let_stmt_type_var(let_stmt)
      StmtKind::LetStmt(new_let_stmt)
    }
    StmtKind::LetMutStmt(let_mut_stmt) => {
      let new_let_mut_stmt = self.substitute_let_mut_stmt_type_var(let_mut_stmt)
      StmtKind::LetMutStmt(new_let_mut_stmt)
    }
    StmtKind::AssignStmt(assign_stmt) => {
      let new_assign_stmt = self.substitute_assign_stmt_type_var(assign_stmt)
      StmtKind::AssignStmt(new_assign_stmt)
    }
    StmtKind::WhileStmt(while_stmt) => {
      let new_while_stmt = self.substitute_while_stmt_type_var(while_stmt)
      StmtKind::WhileStmt(new_while_stmt)
    }
    StmtKind::ForStmt(for_stmt) => {
      let new_for_stmt = self.substitute_for_stmt_type_var(for_stmt)
      StmtKind::ForStmt(new_for_stmt)
    }
    StmtKind::ExprStmt(expr) => {
      let new_expr = self.substitute_expr_type_var(expr)
      StmtKind::ExprStmt(new_expr)
    }
    StmtKind::ReturnStmt(maybe_expr) => {
      let new_maybe_expr = match maybe_expr {
        Some(expr) => Some(self.substitute_expr_type_var(expr))
        None => None
      }
      StmtKind::ReturnStmt(new_maybe_expr)
    }
    StmtKind::LocalFunction(local_function) => {
      let new_local_function = self.substitute_local_function_type_var(
        local_function,
      )
      StmtKind::LocalFunction(new_local_function)
    }
  }
  Stmt::{ kind: new_stmt_kind, }
}

///|
/// Performs the `substitute_let_stmt_type_var` type-checker context operation.
pub fn Context::substitute_let_stmt_type_var(
  self : Context,
  let_stmt : LetStmt,
) -> LetStmt raise TypeCheckError {
  let new_ty = self.ensure_type(let_stmt.ty)
  let new_expr = self.substitute_expr_type_var(let_stmt.expr)
  LetStmt::{ pattern: let_stmt.pattern, ty: new_ty, expr: new_expr, }
}

///|
/// Performs the `substitute_let_mut_stmt_type_var` type-checker context operation.
pub fn Context::substitute_let_mut_stmt_type_var(
  self : Context,
  let_mut_stmt : LetMutStmt,
) -> LetMutStmt raise TypeCheckError {
  let new_ty_kind = self.ensure_type(let_mut_stmt.ty)
  let new_expr = self.substitute_expr_type_var(let_mut_stmt.expr)
  LetMutStmt::{ name: let_mut_stmt.name, ty: new_ty_kind, expr: new_expr, }
}

///|
/// Performs the `substitute_assign_stmt_type_var` type-checker context operation.
pub fn Context::substitute_assign_stmt_type_var(
  self : Context,
  assign_stmt : AssignStmt,
) -> AssignStmt raise TypeCheckError {
  let new_left_value = self.substitute_left_value_type_var(
    assign_stmt.left_value,
  )
  let new_expr = self.substitute_expr_type_var(assign_stmt.expr)
  AssignStmt::{
    left_value: new_left_value,
    op: assign_stmt.op,
    expr: new_expr,
  }
}

///|
/// Performs the `substitute_left_value_type_var` type-checker context operation.
pub fn Context::substitute_left_value_type_var(
  self : Context,
  left_value : LeftValue,
) -> LeftValue raise TypeCheckError {
  let new_ty_kind = self.ensure_type(left_value.ty.kind)
  let new_left_value_kind = match left_value.kind {
    Ident(name) => LeftValueKind::Ident(name)
    ArrayAccess(array_lv, index_expr) => {
      let new_array_lv = self.substitute_left_value_type_var(array_lv)
      let new_index_expr = self.substitute_expr_type_var(index_expr)
      ArrayAccess(new_array_lv, new_index_expr)
    }
    LeftValueKind::FieldAccess(struct_lv, field_name) => {
      let new_struct_lv = self.substitute_left_value_type_var(struct_lv)
      FieldAccess(new_struct_lv, field_name)
    }
  }
  LeftValue::{
    kind: new_left_value_kind,
    ty: Type::{ kind: new_ty_kind, mutable: left_value.ty.mutable, },
  }
}

///|
/// Performs the `substitute_block_expr_type_var` type-checker context operation.
pub fn Context::substitute_block_expr_type_var(
  self : Context,
  block_expr : BlockExpr,
) -> BlockExpr raise TypeCheckError {
  let new_ty_kind = self.ensure_type(block_expr.ty)
  let new_stmts = Array::new()
  for stmt in block_expr.stmts {
    let new_stmt = self.substitute_stmt_type_var(stmt)
    new_stmts.push(new_stmt)
  }
  BlockExpr::{ stmts: new_stmts, ty: new_ty_kind, }
}

///|
/// Performs the `substitute_if_expr_type_var` type-checker context operation.
pub fn Context::substitute_if_expr_type_var(
  self : Context,
  if_expr : IfExpr,
) -> IfExpr raise TypeCheckError {
  let new_ty_kind = self.ensure_type(if_expr.ty)
  let new_condition = self.substitute_expr_type_var(if_expr.cond)
  let new_then_branch = self.substitute_block_expr_type_var(if_expr.then_block)
  let new_else_branch = match if_expr.else_block {
    Some(Left(else_if_expr)) => {
      let new_else_if = self.substitute_if_expr_type_var(else_if_expr)
      Some(Either::Left(new_else_if))
    }
    Some(Right(else_block)) => {
      let new_else_block = self.substitute_block_expr_type_var(else_block)
      Some(Either::Right(new_else_block))
    }
    None => None
  }
  IfExpr::{
    cond: new_condition,
    then_block: new_then_branch,
    else_block: new_else_branch,
    ty: new_ty_kind,
  }
}

///|
/// Performs the `substitute_match_expr_type_var` type-checker context operation.
pub fn Context::substitute_match_expr_type_var(
  self : Context,
  match_expr : MatchExpr,
) -> MatchExpr raise TypeCheckError {
  let new_ty_kind = self.ensure_type(match_expr.ty)
  let new_cond_expr = self.substitute_expr_type_var(match_expr.cond)
  let new_arms = Array::new()
  for arm in match_expr.arms {
    let { pattern, match_guard, body, toks, } = arm
    let match_body = match match_guard {
      Some(guard_expr) => {
        let new_guard_expr = self.substitute_expr_type_var(guard_expr)
        Some(new_guard_expr)
      }
      None => None
    }
    let body = self.substitute_expr_type_var(body)
    let new_arm = MatchArm::{ pattern, match_guard: match_body, body, toks, }
    new_arms.push(new_arm)
  }
  MatchExpr::{ cond: new_cond_expr, arms: new_arms, ty: new_ty_kind, }
}

///|
/// Performs the `substitute_while_stmt_type_var` type-checker context operation.
pub fn Context::substitute_while_stmt_type_var(
  self : Context,
  while_stmt : WhileStmt,
) -> WhileStmt raise TypeCheckError {
  let new_cond = self.substitute_expr_type_var(while_stmt.cond)
  let new_body = self.substitute_block_expr_type_var(while_stmt.body)
  WhileStmt::{ cond: new_cond, body: new_body, }
}

///|
/// Performs the `substitute_for_stmt_type_var` type-checker context operation.
pub fn Context::substitute_for_stmt_type_var(
  self : Context,
  for_stmt : ForStmt,
) -> ForStmt raise TypeCheckError {
  let new_inits = Array::new()
  for init in for_stmt.inits {
    let (name, expr) = init
    let new_expr = self.substitute_expr_type_var(expr)
    new_inits.push((name, new_expr))
  }
  let new_cond = self.substitute_expr_type_var(for_stmt.cond)
  let new_steps = Array::new()
  for step in for_stmt.steps {
    let (name, op, expr) = step
    let new_expr = self.substitute_expr_type_var(expr)
    new_steps.push((name, op, new_expr))
  }
  let new_body = self.substitute_block_expr_type_var(for_stmt.body)
  ForStmt::{
    inits: new_inits,
    cond: new_cond,
    steps: new_steps,
    body: new_body,
  }
}

///|
/// Performs the `substitute_local_function_type_var` type-checker context operation.
pub fn Context::substitute_local_function_type_var(
  self : Context,
  local_function : LocalFunction,
) -> LocalFunction raise TypeCheckError {
  let new_param_list = Array::new()
  for param in local_function.param_list {
    let (param_name, param_ty) = param
    let new_param_ty_kind = self.ensure_type(param_ty.kind)
    let new_param_ty = Type::{
      kind: new_param_ty_kind,
      mutable: param_ty.mutable,
    }
    new_param_list.push((param_name, new_param_ty))
  }
  let new_ret_ty_kind = self.ensure_type(local_function.ret_ty.kind)
  let new_ret_ty = Type::{
    kind: new_ret_ty_kind,
    mutable: local_function.ret_ty.mutable,
  }
  let new_body = self.substitute_block_expr_type_var(local_function.body)
  LocalFunction::{
    fname: local_function.fname,
    param_list: new_param_list,
    ret_ty: new_ret_ty,
    body: new_body,
  }
}

///|
/// Performs the `substitute_top_function_type_var` type-checker context operation.
pub fn Context::substitute_top_function_type_var(
  self : Context,
  top_function : TopFunction,
) -> TopFunction raise TypeCheckError {
  let new_param_list = Array::new()
  for param in top_function.param_list {
    let new_param_ty_kind = self.ensure_type(param.ty)
    new_param_list.push(Param::{ name: param.name, ty: new_param_ty_kind, })
  }
  let new_ret_ty_kind = self.ensure_type(top_function.ret_ty)
  let new_body = self.substitute_block_expr_type_var(top_function.body)
  TopFunction::{
    fname: top_function.fname,
    param_list: new_param_list,
    ret_ty: new_ret_ty_kind,
    body: new_body,
  }
}
