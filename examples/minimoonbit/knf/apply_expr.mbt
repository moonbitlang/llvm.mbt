///|
/// Handle primitive type conversion method calls
fn handle_primitive_conversion(
  method_name : String,
  base_name : Name,
  base_type : @typecheck.TypeKind,
) -> KnfExpr? {
  match base_type {
    // Int conversions
    Int =>
      match method_name {
        "to_int64" => Some(Cast(Int64, base_name))
        "to_uint" => Some(Cast(UInt, base_name))
        "to_uint64" => Some(Cast(UInt64, base_name))
        "to_float" => Some(Cast(Float, base_name))
        "to_double" => Some(Cast(Double, base_name))
        "to_string" =>
          Some(
            Call(Name::{ id: "__builtin_int_to_string", slot: 0, }, [base_name]),
          )
        "reinterpret_as_float" => Some(BitCast(Float, base_name))
        _ => None
      }
    // Int64 conversions
    Int64 =>
      match method_name {
        "to_int" => Some(Cast(Int, base_name))
        "to_uint" => Some(Cast(UInt, base_name))
        "to_uint64" => Some(Cast(UInt64, base_name))
        "to_float" => Some(Cast(Float, base_name))
        "to_double" => Some(Cast(Double, base_name))
        "to_string" =>
          Some(
            Call(Name::{ id: "__builtin_int64_to_string", slot: 0, }, [
              base_name,
            ]),
          )
        "reinterpret_as_double" => Some(BitCast(Double, base_name))
        _ => None
      }
    // UInt conversions
    UInt =>
      match method_name {
        "to_int" => Some(Cast(Int, base_name))
        "to_int64" => Some(Cast(Int64, base_name))
        "to_uint64" => Some(Cast(UInt64, base_name))
        "to_float" => Some(Cast(Float, base_name))
        "to_double" => Some(Cast(Double, base_name))
        "to_string" =>
          Some(
            Call(Name::{ id: "__builtin_uint_to_string", slot: 0, }, [base_name]),
          )
        "reinterpret_as_float" => Some(BitCast(Float, base_name))
        _ => None
      }
    // UInt64 conversions
    UInt64 =>
      match method_name {
        "to_int" => Some(Cast(Int, base_name))
        "to_int64" => Some(Cast(Int64, base_name))
        "to_uint" => Some(Cast(UInt, base_name))
        "to_float" => Some(Cast(Float, base_name))
        "to_double" => Some(Cast(Double, base_name))
        "to_string" =>
          Some(
            Call(Name::{ id: "__builtin_uint64_to_string", slot: 0, }, [
              base_name,
            ]),
          )
        "reinterpret_as_double" => Some(BitCast(Double, base_name))
        _ => None
      }
    // Float conversions
    Float =>
      match method_name {
        "to_int" => Some(Cast(Int, base_name))
        "to_int64" => Some(Cast(Int64, base_name))
        "to_uint" => Some(Cast(UInt, base_name))
        "to_uint64" => Some(Cast(UInt64, base_name))
        "to_double" => Some(Cast(Double, base_name))
        "to_string" =>
          Some(
            Call(Name::{ id: "__builtin_float_to_string", slot: 0, }, [
              base_name,
            ]),
          )
        "reinterpret_as_int" => Some(BitCast(Int, base_name))
        "reinterpret_as_uint" => Some(BitCast(UInt, base_name))
        _ => None
      }
    // Double conversions
    Double =>
      match method_name {
        "to_int" => Some(Cast(Int, base_name))
        "to_int64" => Some(Cast(Int64, base_name))
        "to_uint" => Some(Cast(UInt, base_name))
        "to_uint64" => Some(Cast(UInt64, base_name))
        "to_float" => Some(Cast(Float, base_name))
        "to_string" =>
          Some(
            Call(Name::{ id: "__builtin_double_to_string", slot: 0, }, [
              base_name,
            ]),
          )
        "reinterpret_as_int64" => Some(BitCast(Int64, base_name))
        "reinterpret_as_uint64" => Some(BitCast(UInt64, base_name))
        _ => None
      }
    // Char conversions
    Char =>
      match method_name {
        "to_string" =>
          Some(
            Call(Name::{ id: "__builtin_char_to_string", slot: 0, }, [base_name]),
          )
        _ => None
      }
    _ => None
  }
}

///|
/// Performs the `apply_expr_to_knf` KNF lowering operation.
pub fn Context::apply_expr_to_knf(
  self : Context,
  apply_expr : @typecheck.ApplyExpr,
) -> (Array[KnfStmt], KnfExpr) raise KnfTransformError {
  match apply_expr.kind {
    AtomExpr(atom_expr) => self.atom_expr_to_knf(atom_expr)
    ArrayAccess(array_expr, index_expr) => {
      let (stmts, array_knf_expr) = self.apply_expr_to_knf(array_expr)
      let (index_stmts, index_knf_expr) = self.expr_to_knf(index_expr)
      stmts.append(index_stmts)
      let array_type = self.typekind_to_knf(array_expr.ty)
      let array_name = self.expr_to_knf_name(array_knf_expr, array_type, stmts)
      let index_type = self.typekind_to_knf(index_expr.ty)
      let index_name = self.expr_to_knf_name(index_knf_expr, index_type, stmts)

      // Check if this is String indexing
      if array_expr.ty is String {
        let get_char_func = Name::{
          id: "__builtin_get_char_in_string",
          slot: 0,
        }
        return (stmts, Call(get_char_func, [array_name, index_name]))
      }
      (stmts, ArrayAccess(array_name, index_name))
    }
    FieldAccess(struct_expr, field_name) => {
      let (stmts, struct_knf_expr) = self.apply_expr_to_knf(struct_expr)
      let struct_type = self.typekind_to_knf(struct_expr.ty)
      let struct_name = self.expr_to_knf_name(
        struct_knf_expr, struct_type, stmts,
      )
      (stmts, FieldAccess(struct_name, field_name))
    }
    Call(callee_expr, exprs) => {
      let stmts : Array[KnfStmt] = []

      // Check if this is an Array or String method call (length or push)
      match callee_expr.kind {
        FieldAccess(array_expr, method_name) => {
          // Check if this is a primitive type conversion method
          let (base_stmts, base_knf_expr) = self.apply_expr_to_knf(array_expr)
          stmts.append(base_stmts)
          let base_type = self.typekind_to_knf(array_expr.ty)
          let base_name = self.expr_to_knf_name(base_knf_expr, base_type, stmts)
          match
            handle_primitive_conversion(method_name, base_name, array_expr.ty) {
            Some(knf_expr) => return (stmts, knf_expr)
            None => ()
          }
        }
        _ => ()
      }

      // Normal function call
      let (callee_stmts, callee_knf_expr) = self.apply_expr_to_knf(callee_expr)
      stmts.append(callee_stmts)
      let callee_type = self.typekind_to_knf(callee_expr.ty)
      let callee_name = self.expr_to_knf_name(
        callee_knf_expr, callee_type, stmts,
      )
      let arg_names : Array[Name] = []
      for expr in exprs {
        let (expr_stmts, expr_knf_expr) = self.expr_to_knf(expr)
        stmts.append(expr_stmts)
        let expr_type = self.typekind_to_knf(expr.ty)
        let expr_name = self.expr_to_knf_name(expr_knf_expr, expr_type, stmts)
        arg_names.push(expr_name)
      }
      (stmts, Call(callee_name, arg_names))
    }
  }
}
