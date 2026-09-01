///|
/// Represents the MiniMoonBit typed AST node or context `ApplyExpr`.
pub(all) struct ApplyExpr {
  /// Stores the `kind` component of this typed AST value.
  kind : ApplyExprKind
  /// Stores the `ty` component of this typed AST value.
  ty : TypeKind
  /// Stores the `toks` component of this typed AST value.
  toks : ArrayView[Token]
}

///|
/// Formats `ApplyExpr` using MiniMoonBit typed AST notation.
pub impl Show for ApplyExpr with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `ApplyExpr` value with optional ANSI coloring.
pub fn ApplyExpr::to_string(self : Self, color? : Bool = true) -> String {
  match self.kind {
    // For AtomExpr case, directly return atom_expr's to_string without adding extra type
    AtomExpr(atom_expr) => atom_expr.to_string(color~)
    ArrayAccess(apply_expr, index_expr) => {
      let prefix = "array access"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      let ty_str = self.ty.to_string()
      let ty_str = if color { @color.taint(ty_str, Green) } else { ty_str }
      let prefix_with_type = "\{prefix} (\{ty_str})"
      let apply_str = apply_expr.to_string(color~)
      let apply_lines = apply_str
        .split("\n")
        .map(sv => sv.to_owned())
        .to_array()
      let apply_formatted = @parser.format_lines(
        apply_lines,
        head_with="├-",
        continue_with="│ ",
      )
      let index_str = index_expr.to_string(color~)
      let index_lines = index_str
        .split("\n")
        .map(sv => sv.to_owned())
        .to_array()
      let index_formatted = @parser.format_lines(
        index_lines,
        head_with="└-",
        continue_with="  ",
      )
      "\{prefix_with_type}\n\{apply_formatted}\n\{index_formatted}"
    }
    FieldAccess(apply_expr, field) => {
      let prefix = "field access"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      let ty_str = self.ty.to_string()
      let ty_str = if color { @color.taint(ty_str, Green) } else { ty_str }
      let prefix_with_type = "\{prefix} .\{field} (\{ty_str})"
      let inner_str = apply_expr.to_string(color~)
      let lines = inner_str.split("\n").map(sv => sv.to_owned()).to_array()
      let formatted = @parser.format_lines(lines)
      "\{prefix_with_type}\n\{formatted}"
    }
    Call(apply_expr, args) => {
      let prefix = "function call"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      let ty_str = self.ty.to_string()
      let ty_str = if color { @color.taint(ty_str, Green) } else { ty_str }
      let prefix_with_type = "\{prefix} (\{ty_str})"
      let apply_str = apply_expr.to_string(color~)
      let apply_lines = apply_str
        .split("\n")
        .map(sv => sv.to_owned())
        .to_array()
      let apply_formatted = if args.length() > 0 {
        @parser.format_lines(
          apply_lines,
          head_with="├-",
          continue_with="│ ",
        )
      } else {
        @parser.format_lines(apply_lines, head_with="└-", continue_with="  ")
      }
      let mut result = "\{prefix_with_type}\n\{apply_formatted}"
      for i = 0; i < args.length(); i = i + 1 {
        let arg = args[i]
        let arg_str = arg.to_string(color~)
        let arg_lines = arg_str.split("\n").map(sv => sv.to_owned()).to_array()
        let is_last = i == args.length() - 1
        let arg_formatted = if is_last {
          @parser.format_lines(arg_lines, head_with="└-", continue_with="  ")
        } else {
          @parser.format_lines(
            arg_lines,
            head_with="├-",
            continue_with="│ ",
          )
        }
        result = "\{result}\n\{arg_formatted}"
      }
      result
    }
  }
}

///|
/// Enumerates the typed forms represented by `ApplyExprKind`.
pub(all) enum ApplyExprKind {
  /// Represents the `AtomExpr` typed AST form.
  AtomExpr(AtomExpr)
  /// Represents the `ArrayAccess` typed AST form.
  ArrayAccess(ApplyExpr, Expr)
  /// Represents the `FieldAccess` typed AST form.
  FieldAccess(ApplyExpr, String)
  /// Represents the `Call` typed AST form.
  Call(ApplyExpr, Array[Expr])
}

///|
/// Formats an `ApplyExprKind` using constructor notation.
pub impl Show for ApplyExprKind with fn output(self, logger) {
  match self {
    AtomExpr(expr) => {
      logger.write_string("AtomExpr(")
      logger.write_object(expr)
      logger.write_string(")")
    }
    ArrayAccess(expr, index) => {
      logger.write_string("ArrayAccess(")
      logger.write_object(expr)
      logger.write_string(", ")
      logger.write_object(index)
      logger.write_string(")")
    }
    FieldAccess(expr, field) => {
      logger.write_string("FieldAccess(")
      logger.write_object(expr)
      logger.write_string(", ")
      logger.write_object(field)
      logger.write_string(")")
    }
    Call(expr, args) => {
      logger.write_string("Call(")
      logger.write_object(expr)
      logger.write_string(", [")
      for index, arg in args {
        if index > 0 {
          logger.write_string(", ")
        }
        logger.write_object(arg)
      }
      logger.write_string("]")
      logger.write_string(")")
    }
  }
}

///|
/// Type-checks the corresponding parser AST form through `check_apply_expr`.
pub fn Context::check_apply_expr(
  self : Self,
  apply_expr : @parser.ApplyExpr,
) -> ApplyExpr {
  match apply_expr.kind {
    AtomExpr(atom_expr) => {
      let checked_atom_expr = self.check_atom_expr(atom_expr)
      ApplyExpr::{
        kind: ApplyExprKind::AtomExpr(checked_atom_expr),
        ty: checked_atom_expr.ty,
        toks: apply_expr.toks,
      }
    }
    ArrayAccess(array_expr, index_expr) => {
      let checked_array_expr = self.check_apply_expr(array_expr)
      let checked_index_expr = self.check_expr(index_expr)

      // Ensure the index expression is of integer type
      if !(checked_index_expr.ty is Int) {
        let msg = "Array/String index must be of type Int"
        self.throw_(checked_index_expr.toks[0], msg, Error)
      }

      // Handle String indexing (returns Char)
      if checked_array_expr.ty is String {
        ApplyExpr::{
          kind: ApplyExprKind::ArrayAccess(
            checked_array_expr, checked_index_expr,
          ),
          ty: Char,
          toks: apply_expr.toks,
        }
      } else {
        // Ensure the array expression is of array type
        match checked_array_expr.ty {
          Array(element_type) =>
            ApplyExpr::{
              kind: ApplyExprKind::ArrayAccess(
                checked_array_expr, checked_index_expr,
              ),
              ty: element_type,
              toks: apply_expr.toks,
            }
          _ => {
            let msg = "Attempted to index a non-array/non-string type"
            self.throw_(checked_array_expr.toks[0], msg, Error)
            ApplyExpr::{
              kind: ApplyExprKind::ArrayAccess(
                checked_array_expr, checked_index_expr,
              ),
              ty: Unit,
              toks: apply_expr.toks,
            }
          }
        }
      }
    }
    // 专门处理 method call 模式: obj.method(args)
    Call(callee, arg_exprs) if callee.kind
      is FieldAccess(base_expr, method_name) => {
      let checked_base_expr = self.check_apply_expr(base_expr)

      // Handle Array.length()
      if checked_base_expr.ty is Array(_) && method_name == "length" {
        if arg_exprs.length() != 0 {
          let msg = "Array.length() expects 0 arguments, got \{arg_exprs.length()}"
          self.throw_(apply_expr.toks[0], msg, Error)
        }
        // 直接转换为对 get_array_length 的调用
        let length_func = ApplyExpr::{
          kind: AtomExpr(AtomExpr::{
            kind: AtomExprKind::Ident("get_array_length"),
            ty: Function([checked_base_expr.ty], TypeKind::Int),
            toks: apply_expr.toks,
          }),
          ty: Function([checked_base_expr.ty], TypeKind::Int),
          toks: apply_expr.toks,
        }
        let base_as_expr = Expr::{
          kind: ExprKind::ApplyExpr(checked_base_expr),
          ty: checked_base_expr.ty,
          toks: checked_base_expr.toks,
        }
        return ApplyExpr::{
          kind: Call(length_func, [base_as_expr]),
          ty: TypeKind::Int,
          toks: apply_expr.toks,
        }
      }

      // Handle Array.push(value)
      if checked_base_expr.ty is Array(element_type) && method_name == "push" {
        if arg_exprs.length() != 1 {
          let msg = "Array.push() expects 1 argument, got \{arg_exprs.length()}"
          self.throw_(apply_expr.toks[0], msg, Error)
        }
        let checked_arg = self.check_expr(arg_exprs[0])
        if !self.is_type_compatible(checked_arg.ty, element_type) {
          let msg = "Array.push() argument type mismatch, expected \{element_type}, got \{checked_arg.ty}"
          self.throw_(checked_arg.toks[0], msg, Error)
        }
        // 根据元素类型确定对应的 push 函数名
        let push_func_name = match element_type {
          TypeKind::Int => "array_int_push"
          TypeKind::Int64 => "array_int64_push"
          TypeKind::Double => "array_double_push"
          TypeKind::Float => "array_float_push"
          TypeKind::Bool => "array_bool_push"
          TypeKind::Char => "array_char_push"
          _ => "array_ptr_push"
        }
        let push_func = ApplyExpr::{
          kind: AtomExpr(AtomExpr::{
            kind: AtomExprKind::Ident(push_func_name),
            ty: Function([checked_base_expr.ty, element_type], TypeKind::Unit),
            toks: apply_expr.toks,
          }),
          ty: Function([checked_base_expr.ty, element_type], TypeKind::Unit),
          toks: apply_expr.toks,
        }
        let base_as_expr = Expr::{
          kind: ExprKind::ApplyExpr(checked_base_expr),
          ty: checked_base_expr.ty,
          toks: checked_base_expr.toks,
        }
        return ApplyExpr::{
          kind: Call(push_func, [base_as_expr, checked_arg]),
          ty: TypeKind::Unit,
          toks: apply_expr.toks,
        }
      }

      // Handle String.length()
      if checked_base_expr.ty is String && method_name == "length" {
        if arg_exprs.length() != 0 {
          let msg = "String.length() expects 0 arguments, got \{arg_exprs.length()}"
          self.throw_(apply_expr.toks[0], msg, Error)
        }
        let length_func = ApplyExpr::{
          kind: AtomExpr(AtomExpr::{
            kind: AtomExprKind::Ident("__builtin_get_string_length"),
            ty: Function([TypeKind::String], TypeKind::Int),
            toks: apply_expr.toks,
          }),
          ty: Function([TypeKind::String], TypeKind::Int),
          toks: apply_expr.toks,
        }
        let base_as_expr = Expr::{
          kind: ExprKind::ApplyExpr(checked_base_expr),
          ty: checked_base_expr.ty,
          toks: checked_base_expr.toks,
        }
        return ApplyExpr::{
          kind: Call(length_func, [base_as_expr]),
          ty: TypeKind::Int,
          toks: apply_expr.toks,
        }
      }

      // Handle primitive type conversion methods
      match
        handle_primitive_method_call(
          self,
          checked_base_expr,
          method_name,
          arg_exprs,
          apply_expr.toks,
        ) {
        Some(result) => return result
        None => ()
      }

      // Handle struct method calls
      if checked_base_expr.ty is Struct(struct_name) {
        guard self.struct_defs.get(struct_name) is Some(struct_def) else {
          let msg = "Undefined struct type: \{struct_name}"
          self.throw_(apply_expr.toks[0], msg, Error)
          return ApplyExpr::{
            kind: Call(
              ApplyExpr::{
                kind: FieldAccess(checked_base_expr, method_name),
                ty: TypeKind::Unit,
                toks: apply_expr.toks,
              },
              arg_exprs.map(e => self.check_expr(e)),
            ),
            ty: TypeKind::Unit,
            toks: apply_expr.toks,
          }
        }
        guard struct_def.methods.get(method_name) is Some(method_ty) else {
          let msg = "Struct \{struct_name} does not have method: \{method_name}"
          self.throw_(apply_expr.toks[0], msg, Error)
          return ApplyExpr::{
            kind: Call(
              ApplyExpr::{
                kind: FieldAccess(checked_base_expr, method_name),
                ty: TypeKind::Unit,
                toks: apply_expr.toks,
              },
              arg_exprs.map(e => self.check_expr(e)),
            ),
            ty: TypeKind::Unit,
            toks: apply_expr.toks,
          }
        }

        // method_ty should be Function([Struct(...), ...], ret_ty)
        guard method_ty is Function(method_param_tys, method_ret_ty) else {
          let msg = "Invalid method type for \{struct_name}::\{method_name}"
          self.throw_(apply_expr.toks[0], msg, Error)
          return ApplyExpr::{
            kind: Call(
              ApplyExpr::{
                kind: FieldAccess(checked_base_expr, method_name),
                ty: TypeKind::Unit,
                toks: apply_expr.toks,
              },
              arg_exprs.map(e => self.check_expr(e)),
            ),
            ty: TypeKind::Unit,
            toks: apply_expr.toks,
          }
        }

        // Check argument count (excluding self parameter)
        if arg_exprs.length() + 1 != method_param_tys.length() {
          let msg = "Method \{struct_name}::\{method_name} expects \{method_param_tys.length() - 1} arguments, got \{arg_exprs.length()}"
          self.throw_(apply_expr.toks[0], msg, Error)
        }

        // Check and collect all arguments (self + user provided args)
        let all_args = Array::new()
        let base_as_expr = Expr::{
          kind: ExprKind::ApplyExpr(checked_base_expr),
          ty: checked_base_expr.ty,
          toks: checked_base_expr.toks,
        }
        all_args.push(base_as_expr)
        for i in 0..<arg_exprs.length() {
          let arg_expr = self.check_expr(arg_exprs[i])
          if i + 1 < method_param_tys.length() {
            let expected_ty = method_param_tys[i + 1]
            if !self.is_type_compatible(arg_expr.ty, expected_ty) {
              let msg = "Method argument type mismatch, expected \{expected_ty}, got \{arg_expr.ty}"
              self.throw_(arg_expr.toks[0], msg, Error)
            }
          }
          all_args.push(arg_expr)
        }

        // Create call to StructName$$method_name
        let mangled_name = "\{struct_name}$$\{method_name}"
        let method_func = ApplyExpr::{
          kind: AtomExpr(AtomExpr::{
            kind: AtomExprKind::Ident(mangled_name),
            ty: method_ty,
            toks: apply_expr.toks,
          }),
          ty: method_ty,
          toks: apply_expr.toks,
        }
        return ApplyExpr::{
          kind: Call(method_func, all_args),
          ty: method_ret_ty,
          toks: apply_expr.toks,
        }
      }

      // 如果不是已知的 method call，报错
      let msg = "Unknown method: \{method_name} for type: \{checked_base_expr.ty}"
      self.throw_(apply_expr.toks[0], msg, Error)
      return ApplyExpr::{
        kind: Call(
          ApplyExpr::{
            kind: FieldAccess(checked_base_expr, method_name),
            ty: TypeKind::Unit,
            toks: apply_expr.toks,
          },
          arg_exprs.map(e => self.check_expr(e)),
        ),
        ty: TypeKind::Unit,
        toks: apply_expr.toks,
      }
    }
    FieldAccess(struct_expr, field_name) => {
      let struct_expr = self.check_apply_expr(struct_expr)
      // FieldAccess 现在只处理普通的结构体字段访问
      // 不再处理 method，因为 method 会被 Call(FieldAccess(...)) 匹配
      guard struct_expr.ty is Struct(struct_type_name) else {
        let msg = "Attempted to access field of a non-struct type: \{struct_expr.ty}"
        self.throw_(struct_expr.toks[0], msg, Error)
        return ApplyExpr::{
          kind: FieldAccess(struct_expr, field_name),
          ty: Unit,
          toks: apply_expr.toks,
        }
      }
      guard self.struct_defs.get(struct_type_name) is Some(struct_def) else {
        let msg = "Undefined struct type: \{struct_type_name}"
        self.throw_(struct_expr.toks[0], msg, Error)
        return ApplyExpr::{
          kind: FieldAccess(struct_expr, field_name),
          ty: Unit,
          toks: apply_expr.toks,
        }
      }
      let ty = for field in struct_def.fields {
        if field.name == field_name {
          break field.ty.kind
        }
      } nobreak {
        let msg = "Struct type does not have field: \{field_name}"
        self.throw_(struct_expr.toks[0], msg, Error)
        TypeKind::Unit
      }
      ApplyExpr::{
        kind: FieldAccess(struct_expr, field_name),
        ty,
        toks: apply_expr.toks,
      }
    }
    Call(callee_expr, arg_exprs) => {
      let callee_expr = self.check_apply_expr(callee_expr)
      guard callee_expr.ty is Function(arg_tys, ret_ty) else {
        let msg = "Attempted to call a non-function type: \{callee_expr.ty}"
        self.throw_(callee_expr.toks[0], msg, Error)
        return ApplyExpr::{
          kind: Call(callee_expr, arg_exprs.map(e => self.check_expr(e))),
          ty: Unit,
          toks: apply_expr.toks,
        }
      }
      if arg_exprs.length() != arg_tys.length() {
        let msg = "Function call argument count mismatch, expected \{arg_tys.length()}, got \{arg_exprs.length()}"
        self.throw_(apply_expr.toks[0], msg, Error)
      }
      let arg_len = min(arg_exprs.length(), arg_tys.length())
      let new_arg_exprs = Array::new()
      for i in 0..<arg_len {
        let arg_expr = self.check_expr(arg_exprs[i])
        let expected_ty = arg_tys[i]
        if !self.is_type_compatible(arg_expr.ty, expected_ty) {
          let msg = "Function call argument type mismatch, expected \{expected_ty}, got \{arg_expr.ty}"
          self.throw_(arg_expr.toks[0], msg, Error)
        }
        new_arg_exprs.push(arg_expr)
      }
      let ret_ty = self.ensure_type(ret_ty)
      ApplyExpr::{
        kind: Call(callee_expr, new_arg_exprs),
        ty: ret_ty,
        toks: apply_expr.toks,
      }
    }
  }
}

///|
fn min(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Handle primitive type method calls (e.g., n.to_string(), n.to_double(), etc.)
/// 直接转换为对内置函数或cast操作的调用
fn handle_primitive_method_call(
  ctx : Context,
  base_expr : ApplyExpr,
  method_name : String,
  arg_exprs : Array[@parser.Expr],
  toks : ArrayView[Token],
) -> ApplyExpr? {
  // Check if this is a primitive type first; if not, return None
  // to let the caller handle struct methods
  let is_primitive = match base_expr.ty {
    TypeKind::Int
    | TypeKind::Int64
    | TypeKind::UInt
    | TypeKind::UInt64
    | TypeKind::Float
    | TypeKind::Double
    | TypeKind::Char => true
    _ => false
  }
  if !is_primitive {
    return None
  }

  // For primitive types, all conversion methods expect 0 arguments
  if arg_exprs.length() != 0 {
    let msg = "Conversion method \{method_name}() expects 0 arguments, got \{arg_exprs.length()}"
    ctx.throw_(toks[0], msg, Error)
    return None
  }
  let base_as_expr = Expr::{
    kind: ExprKind::ApplyExpr(base_expr),
    ty: base_expr.ty,
    toks: base_expr.toks,
  }
  match base_expr.ty {
    // Int methods
    TypeKind::Int =>
      match method_name {
        "to_int64"
        | "to_uint"
        | "to_uint64"
        | "to_float"
        | "to_double"
        | "reinterpret_as_uint" => {
          let target_ty = match method_name {
            "to_int64" => TypeKind::Int64
            "to_uint" => TypeKind::UInt
            "to_uint64" => TypeKind::UInt64
            "to_float" => TypeKind::Float
            "to_double" => TypeKind::Double
            "reinterpret_as_uint" => TypeKind::UInt
            _ => TypeKind::Int // unreachable
          }
          Some(ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::Cast(target_ty, base_as_expr),
              ty: target_ty,
              toks,
            }),
            ty: target_ty,
            toks,
          })
        }
        "reinterpret_as_float" =>
          Some(ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::BitCast(TypeKind::Float, base_as_expr),
              ty: TypeKind::Float,
              toks,
            }),
            ty: TypeKind::Float,
            toks,
          })
        "to_string" => {
          let to_string_func = ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::Ident("__builtin_int_to_string"),
              ty: Function([TypeKind::Int], TypeKind::String),
              toks,
            }),
            ty: Function([TypeKind::Int], TypeKind::String),
            toks,
          }
          Some(ApplyExpr::{
            kind: Call(to_string_func, [base_as_expr]),
            ty: TypeKind::String,
            toks,
          })
        }
        _ => None
      }
    // UInt methods
    TypeKind::UInt =>
      match method_name {
        "to_int"
        | "to_int64"
        | "to_uint64"
        | "to_float"
        | "to_double"
        | "reinterpret_as_int" => {
          let target_ty = match method_name {
            "to_int" => TypeKind::Int
            "to_int64" => TypeKind::Int64
            "to_uint64" => TypeKind::UInt64
            "to_float" => TypeKind::Float
            "to_double" => TypeKind::Double
            "reinterpret_as_int" => TypeKind::Int
            _ => TypeKind::UInt // unreachable
          }
          Some(ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::Cast(target_ty, base_as_expr),
              ty: target_ty,
              toks,
            }),
            ty: target_ty,
            toks,
          })
        }
        "reinterpret_as_float" =>
          Some(ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::BitCast(TypeKind::Float, base_as_expr),
              ty: TypeKind::Float,
              toks,
            }),
            ty: TypeKind::Float,
            toks,
          })
        "to_string" => {
          let to_string_func = ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::Ident("__builtin_uint_to_string"),
              ty: Function([TypeKind::UInt], TypeKind::String),
              toks,
            }),
            ty: Function([TypeKind::UInt], TypeKind::String),
            toks,
          }
          Some(ApplyExpr::{
            kind: Call(to_string_func, [base_as_expr]),
            ty: TypeKind::String,
            toks,
          })
        }
        _ => None
      }
    // Int64 methods
    TypeKind::Int64 =>
      match method_name {
        "to_int"
        | "to_uint"
        | "to_uint64"
        | "to_float"
        | "to_double"
        | "reinterpret_as_uint64" => {
          let target_ty = match method_name {
            "to_int" => TypeKind::Int
            "to_uint" => TypeKind::UInt
            "to_uint64" => TypeKind::UInt64
            "to_float" => TypeKind::Float
            "to_double" => TypeKind::Double
            "reinterpret_as_uint64" => TypeKind::UInt64
            _ => TypeKind::Int64 // unreachable
          }
          Some(ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::Cast(target_ty, base_as_expr),
              ty: target_ty,
              toks,
            }),
            ty: target_ty,
            toks,
          })
        }
        "reinterpret_as_double" =>
          Some(ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::BitCast(TypeKind::Double, base_as_expr),
              ty: TypeKind::Double,
              toks,
            }),
            ty: TypeKind::Double,
            toks,
          })
        "to_string" => {
          let to_string_func = ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::Ident("__builtin_int64_to_string"),
              ty: Function([TypeKind::Int64], TypeKind::String),
              toks,
            }),
            ty: Function([TypeKind::Int64], TypeKind::String),
            toks,
          }
          Some(ApplyExpr::{
            kind: Call(to_string_func, [base_as_expr]),
            ty: TypeKind::String,
            toks,
          })
        }
        _ => None
      }
    // UInt64 methods
    TypeKind::UInt64 =>
      match method_name {
        "to_int"
        | "to_int64"
        | "to_uint"
        | "to_float"
        | "to_double"
        | "reinterpret_as_int64" => {
          let target_ty = match method_name {
            "to_int" => TypeKind::Int
            "to_int64" => TypeKind::Int64
            "to_uint" => TypeKind::UInt
            "to_float" => TypeKind::Float
            "to_double" => TypeKind::Double
            "reinterpret_as_int64" => TypeKind::Int64
            _ => TypeKind::UInt64 // unreachable
          }
          Some(ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::Cast(target_ty, base_as_expr),
              ty: target_ty,
              toks,
            }),
            ty: target_ty,
            toks,
          })
        }
        "reinterpret_as_double" =>
          Some(ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::BitCast(TypeKind::Double, base_as_expr),
              ty: TypeKind::Double,
              toks,
            }),
            ty: TypeKind::Double,
            toks,
          })
        "to_string" => {
          let to_string_func = ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::Ident("__builtin_uint64_to_string"),
              ty: Function([TypeKind::UInt64], TypeKind::String),
              toks,
            }),
            ty: Function([TypeKind::UInt64], TypeKind::String),
            toks,
          }
          Some(ApplyExpr::{
            kind: Call(to_string_func, [base_as_expr]),
            ty: TypeKind::String,
            toks,
          })
        }
        _ => None
      }
    // Float methods
    TypeKind::Float =>
      match method_name {
        "to_int" | "to_int64" | "to_uint" | "to_uint64" | "to_double" => {
          let target_ty = match method_name {
            "to_int" => TypeKind::Int
            "to_int64" => TypeKind::Int64
            "to_uint" => TypeKind::UInt
            "to_uint64" => TypeKind::UInt64
            "to_double" => TypeKind::Double
            _ => TypeKind::Float // unreachable
          }
          Some(ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::Cast(target_ty, base_as_expr),
              ty: target_ty,
              toks,
            }),
            ty: target_ty,
            toks,
          })
        }
        "reinterpret_as_int" =>
          Some(ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::BitCast(TypeKind::Int, base_as_expr),
              ty: TypeKind::Int,
              toks,
            }),
            ty: TypeKind::Int,
            toks,
          })
        "reinterpret_as_uint" =>
          Some(ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::BitCast(TypeKind::UInt, base_as_expr),
              ty: TypeKind::UInt,
              toks,
            }),
            ty: TypeKind::UInt,
            toks,
          })
        "to_string" => {
          let to_string_func = ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::Ident("__builtin_float_to_string"),
              ty: Function([TypeKind::Float], TypeKind::String),
              toks,
            }),
            ty: Function([TypeKind::Float], TypeKind::String),
            toks,
          }
          Some(ApplyExpr::{
            kind: Call(to_string_func, [base_as_expr]),
            ty: TypeKind::String,
            toks,
          })
        }
        _ => None
      }
    // Double methods
    TypeKind::Double =>
      match method_name {
        "to_int" | "to_int64" | "to_uint" | "to_uint64" | "to_float" => {
          let target_ty = match method_name {
            "to_int" => TypeKind::Int
            "to_int64" => TypeKind::Int64
            "to_uint" => TypeKind::UInt
            "to_uint64" => TypeKind::UInt64
            "to_float" => TypeKind::Float
            _ => TypeKind::Double // unreachable
          }
          Some(ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::Cast(target_ty, base_as_expr),
              ty: target_ty,
              toks,
            }),
            ty: target_ty,
            toks,
          })
        }
        "reinterpret_as_int64" =>
          Some(ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::BitCast(TypeKind::Int64, base_as_expr),
              ty: TypeKind::Int64,
              toks,
            }),
            ty: TypeKind::Int64,
            toks,
          })
        "reinterpret_as_uint64" =>
          Some(ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::BitCast(TypeKind::UInt64, base_as_expr),
              ty: TypeKind::UInt64,
              toks,
            }),
            ty: TypeKind::UInt64,
            toks,
          })
        "to_string" => {
          let to_string_func = ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::Ident("__builtin_double_to_string"),
              ty: Function([TypeKind::Double], TypeKind::String),
              toks,
            }),
            ty: Function([TypeKind::Double], TypeKind::String),
            toks,
          }
          Some(ApplyExpr::{
            kind: Call(to_string_func, [base_as_expr]),
            ty: TypeKind::String,
            toks,
          })
        }
        _ => None
      }
    // Char methods
    TypeKind::Char =>
      match method_name {
        "to_string" => {
          let to_string_func = ApplyExpr::{
            kind: AtomExpr(AtomExpr::{
              kind: AtomExprKind::Ident("__builtin_char_to_string"),
              ty: Function([TypeKind::Char], TypeKind::String),
              toks,
            }),
            ty: Function([TypeKind::Char], TypeKind::String),
            toks,
          }
          Some(ApplyExpr::{
            kind: Call(to_string_func, [base_as_expr]),
            ty: TypeKind::String,
            toks,
          })
        }
        _ => None
      }
    _ => None
  }
}

///|
test "ApplyExpr to_string Test" {
  let color = false
  let ctx = Context::new()
  ctx.type_env.set("x", { kind: TypeKind::Double, mutable: false, })
  ctx.type_env.set("point", { kind: TypeKind::Struct("Point"), mutable: false, })
  ctx.type_env.set("arr", {
    kind: TypeKind::Array(TypeKind::Int),
    mutable: false,
  })
  ctx.type_env.set("add", {
    kind: TypeKind::Function([TypeKind::Int, TypeKind::Int], TypeKind::Int),
    mutable: false,
  })
  ctx.struct_defs.set("Point", {
    name: "Point",
    fields: [
      { name: "x", ty: { kind: TypeKind::Int, mutable: false, }, },
      { name: "y", ty: { kind: TypeKind::Int, mutable: false, }, },
    ],
    methods: Map([]),
  })
  let code =
    #|42 ; x ; point.x ; arr[0] ; add(1, 2)
  let tokens = @lexer.tokenize(code)

  // Test AtomExpr - Int: 42
  let (parsed, rest) = @parser.parse_apply_expr(tokens[:])
  let checked = ctx.check_apply_expr(parsed)
  inspect(checked.to_string(color~), content="int literal 42 (Int)")

  // Test AtomExpr - Ident: x
  let (parsed, rest) = @parser.parse_apply_expr(rest[1:])
  let checked = ctx.check_apply_expr(parsed)
  inspect(checked.to_string(color~), content="variable x (Double)")

  // Test FieldAccess: point.x
  let (parsed, rest) = @parser.parse_apply_expr(rest[1:])
  let checked = ctx.check_apply_expr(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|field access .x (Int)
      #|└-variable point (Point)
    ),
  )

  // Test ArrayAccess: arr[0]
  let (parsed, rest) = @parser.parse_apply_expr(rest[1:])
  let checked = ctx.check_apply_expr(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|array access (Int)
      #|├-variable arr (Array[Int])
      #|└-int literal 0 (Int)
    ),
  )

  // Test Call with arguments: add(1, 2)
  let (parsed, _) = @parser.parse_apply_expr(rest[1:])
  let checked = ctx.check_apply_expr(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|function call (Int)
      #|├-variable add ((Int, Int) -> Int)
      #|├-int literal 1 (Int)
      #|└-int literal 2 (Int)
    ),
  )
}
