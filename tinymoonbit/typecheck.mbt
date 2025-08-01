///|
priv suberror TypeCheckError String derive(Show)

///|
priv struct TypeEnv[K, V] {
  parent : TypeEnv[K, V]?
  data : Map[K, V]
}

///|
fn[K, V] TypeEnv::new(parent~ : TypeEnv[K, V]? = None) -> TypeEnv[K, V] {
  TypeEnv::{ parent, data: Map::new() }
}

///|
fn[K : Eq + Hash, V] TypeEnv::get(self : Self[K, V], key : K) -> V? {
  match self.data.get(key) {
    Some(value) => Some(value)
    None =>
      match self.parent {
        Some(parent_env) => parent_env.get(key)
        None => None
      }
  }
}

///|
fn[K : Eq + Hash + Show, V] TypeEnv::get_or_err(
  self : Self[K, V],
  key : K,
) -> V raise {
  match self.data.get(key) {
    Some(value) => value
    None =>
      match self.parent {
        Some(parent_env) => parent_env.get_or_err(key)
        None => raise TypeCheckError("Error: Key not found: \{key}")
      }
  }
}

///|
fn[K : Eq + Hash + Show, V] TypeEnv::set(
  self : Self[K, V],
  key : K,
  value : V,
) -> Unit raise {
  if self.data.contains(key) {
    raise TypeCheckError("Error: Duplicate key: \{key}")
  }
  self.data.set(key, value)
}

///|
priv struct TypeCheck {
  local_env : TypeEnv[String, Type]
  func : Function
  prog : Program
}

///|
fn TypeCheck::sub_env(self : Self) -> TypeCheck {
  TypeCheck::{
    local_env: TypeEnv::new(parent=Some(self.local_env)),
    func: self.func,
    prog: self.prog,
  }
}

///|
fn TypeCheck::check_prog(prog : Program) -> Unit raise {
  for func_entry in prog.functions {
    let (_, func) = func_entry
    TypeCheck::{ local_env: TypeEnv::new(), func, prog }.check_function(func)
  }
}

///|
fn TypeCheck::check_function(self : Self, func : Function) -> Unit raise {
  for param in func.params {
    let (name, ty) = param
    self.local_env.set(name, ty)
  }
  func.body.each(stmt => self.check_stmt(stmt))
}

///|
fn TypeCheck::check_stmt(self : Self, stmt : Stmt) -> Unit raise {
  match stmt {
    Let(var_name, ty, None) => {
      // let arr: Array[Int]; is not allowed
      guard not(ty is Array(_)) else {
        raise TypeCheckError(
          "Error: Array type must be initialized with values",
        )
      }
      self.local_env.set(var_name, ty)
    }
    Let(var_name, ty, Some(expr)) => {
      let expr_ty = self.check_expr(expr)
      guard expr_ty == ty else {
        raise TypeCheckError(
          "Let Statement Type Mismatch: Expected \{ty}, got \{expr_ty}",
        )
      }
      self.local_env.set(var_name, ty)
    }
    Assign(left_value, expr) => {
      let left_ty = self.check_left_value(left_value)
      let expr_ty = self.check_expr(expr)
      guard left_ty == expr_ty else {
        raise TypeCheckError(
          "Assignment Type Mismatch: Expected \{left_ty}, got \{expr_ty}",
        )
      }
    }
    If(cond, then_block, else_block) => {
      let cond_ty = self.check_expr(cond)
      guard cond_ty is Bool else {
        raise TypeCheckError(
          "If Condition Type Mismatch: Expected Bool, got \{cond_ty}",
        )
      }
      then_block.each(stmt => self.sub_env().check_stmt(stmt))
      else_block.each(stmt => self.sub_env().check_stmt(stmt))
    }
    While(cond, body) => {
      let cond_ty = self.check_expr(cond)
      guard cond_ty is Bool else {
        raise TypeCheckError(
          "While Condition Type Mismatch: Expected Bool, got \{cond_ty}",
        )
      }
      body.each(stmt => self.sub_env().check_stmt(stmt))
    }
    Return(Some(expr)) => {
      let expr_ty = self.check_expr(expr)
      guard expr_ty == self.func.ret_ty else {
        raise TypeCheckError(
          "Return Type Mismatch: Expected \{self.func.ret_ty}, got \{expr_ty}",
        )
      }
    }
    Return(None) => {
      guard self.func.ret_ty is Unit else {
        raise TypeCheckError(
          "Return Type Mismatch: Expected Void, got \{self.func.ret_ty}",
        )
      }
    }
    Expr(expr) => {
      let _ = self.check_expr(expr)

    }
  }
}

///|
fn TypeCheck::check_expr(self : Self, expr : Expr) -> Type raise {
  match expr {
    Apply(apply_expr, ..) as a => {
      let ty = self.check_apply(apply_expr)
      a.ty = Some(ty)
      ty
    }
    Neg(expr, ..) as neg_expr => {
      let expr_ty = self.check_expr(expr)
      neg_expr.ty = Some(expr_ty)
      expr_ty
    }
    Add(lhs, rhs, ..) as add_expr => {
      let lhs_ty = self.check_expr(lhs)
      let rhs_ty = self.check_expr(rhs)
      guard lhs_ty == rhs_ty else {
        raise TypeCheckError(
          "Add Type Mismatch: Expected \{lhs_ty}, got \{rhs_ty}",
        )
      }
      add_expr.ty = Some(lhs_ty)
      lhs_ty
    }
    Sub(lhs, rhs, ..) as sub_expr => {
      let lhs_ty = self.check_expr(lhs)
      let rhs_ty = self.check_expr(rhs)
      guard lhs_ty == rhs_ty else {
        raise TypeCheckError(
          "Sub Type Mismatch: Expected \{lhs_ty}, got \{rhs_ty}",
        )
      }
      sub_expr.ty = Some(lhs_ty)
      lhs_ty
    }
    Mul(lhs, rhs, ..) as mul_expr => {
      let lhs_ty = self.check_expr(lhs)
      let rhs_ty = self.check_expr(rhs)
      guard lhs_ty == rhs_ty else {
        raise TypeCheckError(
          "Mul Type Mismatch: Expected \{lhs_ty}, got \{rhs_ty}",
        )
      }
      mul_expr.ty = Some(lhs_ty)
      lhs_ty
    }
    Div(lhs, rhs, ..) as div_expr => {
      let lhs_ty = self.check_expr(lhs)
      let rhs_ty = self.check_expr(rhs)
      guard lhs_ty == rhs_ty else {
        raise TypeCheckError(
          "Div Type Mismatch: Expected \{lhs_ty}, got \{rhs_ty}",
        )
      }
      div_expr.ty = Some(lhs_ty)
      lhs_ty
    }
    Rem(lhs, rhs, ..) as rem_expr => {
      let lhs_ty = self.check_expr(lhs)
      let rhs_ty = self.check_expr(rhs)
      guard lhs_ty == rhs_ty else {
        raise TypeCheckError(
          "Rem Type Mismatch: Expected \{lhs_ty}, got \{rhs_ty}",
        )
      }
      rem_expr.ty = Some(lhs_ty)
      lhs_ty
    }
    Eq(lhs, rhs) => {
      let lhs_ty = self.check_expr(lhs)
      let rhs_ty = self.check_expr(rhs)
      guard lhs_ty == rhs_ty else {
        raise TypeCheckError(
          "Eq Type Mismatch: Expected \{lhs_ty}, got \{rhs_ty}",
        )
      }
      Bool
    }
    Ne(lhs, rhs) => {
      let lhs_ty = self.check_expr(lhs)
      let rhs_ty = self.check_expr(rhs)
      guard lhs_ty == rhs_ty else {
        raise TypeCheckError(
          "Neq Type Mismatch: Expected \{lhs_ty}, got \{rhs_ty}",
        )
      }
      Bool
    }
    Lt(lhs, rhs) => {
      let lhs_ty = self.check_expr(lhs)
      let rhs_ty = self.check_expr(rhs)
      guard lhs_ty == rhs_ty else {
        raise TypeCheckError(
          "Lt Type Mismatch: Expected \{lhs_ty}, got \{rhs_ty}",
        )
      }
      Bool
    }
    Le(lhs, rhs) => {
      let lhs_ty = self.check_expr(lhs)
      let rhs_ty = self.check_expr(rhs)
      guard lhs_ty == rhs_ty else {
        raise TypeCheckError(
          "Le Type Mismatch: Expected \{lhs_ty}, got \{rhs_ty}",
        )
      }
      Bool
    }
    Gt(lhs, rhs) => {
      let lhs_ty = self.check_expr(lhs)
      let rhs_ty = self.check_expr(rhs)
      guard lhs_ty == rhs_ty else {
        raise TypeCheckError(
          "Gt Type Mismatch: Expected \{lhs_ty}, got \{rhs_ty}",
        )
      }
      Bool
    }
    Ge(lhs, rhs) => {
      let lhs_ty = self.check_expr(lhs)
      let rhs_ty = self.check_expr(rhs)
      guard lhs_ty == rhs_ty else {
        raise TypeCheckError(
          "Ge Type Mismatch: Expected \{lhs_ty}, got \{rhs_ty}",
        )
      }
      Bool
    }
    And(lhs, rhs) => {
      let lhs_ty = self.check_expr(lhs)
      let rhs_ty = self.check_expr(rhs)
      guard lhs_ty == Bool && rhs_ty == Bool else {
        raise TypeCheckError(
          "And Type Mismatch: Expected Bool, got \{lhs_ty} and \{rhs_ty}",
        )
      }
      Bool
    }
    Or(lhs, rhs) => {
      let lhs_ty = self.check_expr(lhs)
      let rhs_ty = self.check_expr(rhs)
      guard lhs_ty == Bool && rhs_ty == Bool else {
        raise TypeCheckError(
          "Or Type Mismatch: Expected Bool, got \{lhs_ty} and \{rhs_ty}",
        )
      }
      Bool
    }
    Shl(lhs, rhs, ..) as shl_expr => {
      let lhs_ty = self.check_expr(lhs)
      let rhs_ty = self.check_expr(rhs)
      guard lhs_ty == rhs_ty else {
        raise TypeCheckError(
          "Shl Type Mismatch: Expected Int, got \{lhs_ty} and \{rhs_ty}",
        )
      }
      guard lhs_ty is (Int | UInt | Int64 | UInt64) else {
        raise TypeCheckError(
          "Shl Type Mismatch: Expected Int or UInt, got \{lhs_ty}",
        )
      }
      shl_expr.ty = Some(lhs_ty)
      Int
    }
    Shr(lhs, rhs, ..) as shr_expr => {
      let lhs_ty = self.check_expr(lhs)
      let rhs_ty = self.check_expr(rhs)
      guard lhs_ty == rhs_ty else {
        raise TypeCheckError(
          "Shr Type Mismatch: Expected Int, got \{lhs_ty} and \{rhs_ty}",
        )
      }
      guard lhs_ty is (Int | UInt | Int64 | UInt64) else {
        raise TypeCheckError(
          "Shr Type Mismatch: Expected Int or UInt, got \{lhs_ty}",
        )
      }
      shr_expr.ty = Some(lhs_ty)
      Int
    }
  }
}

///|
fn TypeCheck::check_left_value(
  self : Self,
  left_value : LeftValue,
) -> Type raise {
  match left_value {
    Var(name, ..) as var_left => {
      let ty = self.local_env.get_or_err(name)
      var_left.ty = Some(ty)
      ty
    }
    ArrayGet(left, index, ..) as array_get => {
      let left_ty = self.check_left_value(left)
      let index_ty = self.check_expr(index)
      guard index_ty is Int else {
        raise TypeCheckError(
          "ArrayGet Index Type Mismatch: Expected Int, got \{index_ty}",
        )
      }
      match left_ty {
        Array(ele_ty) => {
          array_get.ty = Some(ele_ty)
          ele_ty
        }
        Ptr(ele_ty) => {
          array_get.ty = Some(ele_ty)
          ele_ty
        }
        _ =>
          raise TypeCheckError(
            "ArrayGet Left Value Type Mismatch: Expected ArrayType or Pointer, got \{left_ty}",
          )
      }
    }
    StructAccess(left, field_name, ..) as struct_access => {
      let left_ty = self.check_left_value(left)
      guard left_ty is Struct(struct_ty) else {
        raise TypeCheckError(
          "StructAccess Left Value Type Mismatch: Expected StructType, got \{left_ty}",
        )
      }
      let struct_def = match self.prog.structs.get(struct_ty) {
        Some(def) => def
        None =>
          raise TypeCheckError(
            "Error: Struct \{struct_ty} not found in program",
          )
      }
      let ty = match struct_def.get_field_type(field_name) {
        Some(ty) => ty
        None =>
          raise TypeCheckError(
            "Error: Field \{field_name} not found in struct \{struct_ty}",
          )
      }
      struct_access.ty = Some(ty)
      ty
    }
  }
}

///|
fn TypeCheck::check_apply(self : Self, apply_expr : ApplyExpr) -> Type raise {
  match apply_expr {
    Atom(atom_expr, ..) as a => {
      let ty = self.check_atom_expr(atom_expr)
      a.ty = Some(ty)
      ty
    }
    ArrayGet(left, index, ..) as array_get => {
      let left_ty = self.check_apply(left)
      let index_ty = self.check_expr(index)
      guard index_ty is Int else {
        raise TypeCheckError(
          "ArrayGet Index Type Mismatch: Expected Int, got \{index_ty}",
        )
      }
      match left_ty {
        Array(ele_ty) => {
          array_get.ty = Some(ele_ty)
          ele_ty
        }
        Ptr(ele_ty) => {
          array_get.ty = Some(ele_ty)
          ele_ty
        }
        _ =>
          raise TypeCheckError(
            "ArrayGet Left Value Type Mismatch: Expected ArrayType or Pointer, got \{left_ty}",
          )
      }
    }
    StructAccess(left, field_name, ..) as struct_access => {
      let left_ty = self.check_apply(left)
      guard left_ty is Struct(struct_ty) else {
        raise TypeCheckError(
          "StructAccess Left Value Type Mismatch: Expected StructType, got \{left_ty}",
        )
      }
      let struct_def = match self.prog.structs.get(struct_ty) {
        Some(def) => def
        None =>
          raise TypeCheckError(
            "Error: Struct \{struct_ty} not found in program",
          )
      }
      let ty = match struct_def.get_field_type(field_name) {
        Some(ty) => ty
        None =>
          raise TypeCheckError(
            "Error: Field \{field_name} not found in struct \{struct_ty}",
          )
      }
      struct_access.ty = Some(ty)
      ty
    }
    Cast(left, cast_ty) => {
      let _ = self.check_apply(left)
      cast_ty
    }
  }
}

///|
fn TypeCheck::check_atom_expr(self : Self, atom_expr : AtomExpr) -> Type raise {
  match atom_expr {
    Bool(_) => Bool
    Int(_) => Int
    Int64(_) => Int64
    UInt(_) => UInt
    UInt64(_) => UInt64
    Float(_) => Float
    Double(_) => Double
    Var(name, ..) as a => {
      let ty = self.local_env.get_or_err(name)
      a.ty = Some(ty)
      ty
    }
    Ref(name, ..) as a => {
      let ty = self.local_env.get_or_err(name) |> Ptr
      a.ty = Some(ty)
      ty
    }
    TypeSizeof(_) => Int
    ExprSizeof(_) => Int
    Array(exprs, ..) as array_expr => {
      let exprs_tys = exprs.map(self.check_expr(_))
      let last = match exprs_tys.last() {
        Some(ty) => ty
        None => raise TypeCheckError("Error: Empty array in AtomExpr")
      }
      guard exprs_tys.iter().all(ty => ty == last) else {
        raise TypeCheckError(
          "Error: Array element types do not match: \{exprs_tys}",
        )
      }
      let ty = Type::Array(last)
      array_expr.ty = Some(ty)
      ty
    }
    Paren(expr, ..) as paren_expr => {
      let expr_ty = self.check_expr(expr)
      paren_expr.ty = Some(expr_ty)
      expr_ty
    }
    Call(func_name, args, ..) as call_expr => {
      let func = match self.prog.functions.get(func_name) {
        Some(f) => f
        None =>
          match self.prog.externs.get(func_name) {
            Some(f) => f
            None =>
              raise TypeCheckError(
                "Error: Function \{func_name} not found in program",
              )
          }
      }
      let args_tys = args.map(self.check_expr(_))
      let param_tys = func.params.map(param => param.1)
      guard args_tys == param_tys else {
        raise TypeCheckError(
          "Error: Function \{func_name} argument types do not match. Expected \{param_tys}, got \{args_tys}",
        )
      }
      call_expr.ty = Some(func.ret_ty)
      func.ret_ty
    }
  }
}
