///|
/// Represents the MiniMoonBit KNF value or lowering context `KnfClosure`.
pub(all) struct KnfClosure {
  /// Stores the `name` component of this KNF value.
  name : Name
  /// Stores the `params` component of this KNF value.
  params : Array[(Name, Type)]
  /// Stores the `ret_ty` component of this KNF value.
  ret_ty : Type
  /// Stores the `body` component of this KNF value.
  body : KnfBlock
  /// Stores the `captured_vars` component of this KNF value.
  captured_vars : Map[Name, (Type, Bool)] // Bool is mutable flag
}

///|
/// Renders this `KnfClosure` KNF value as text.
pub fn KnfClosure::to_string(self : KnfClosure, ident? : Int = 0) -> String {
  let sb = StringBuilder()
  let indent_str = " ".repeat(ident)
  if !self.captured_vars.is_empty() {
    sb.write_string("// Captured variables: \n")
    for name, ty_mut in self.captured_vars {
      sb.write_string(indent_str)
      let (ty, is_mut) = ty_mut
      let mut_str = if is_mut { "mut " } else { "" }
      sb.write_string("// - \{mut_str}\{name} : \{ty}\n")
    }
    sb.write_string(indent_str)
    sb.write_string("fn \{self.name}(")
  } else {
    sb.write_string("fn \{self.name}(")
  }
  let param_strs = self.params.map(name_ty => {
    let (name, ty) = name_ty
    "\{name} : \{ty}"
  })
  sb.write_string(param_strs.join(", "))
  sb.write_string(") -> \{self.ret_ty} ")
  sb.write_string(self.body.to_string(ident))
  sb.to_string()
}

///|
/// Performs the `local_function_to_knf` KNF lowering operation.
pub fn Context::local_function_to_knf(
  self : Context,
  local_function : @typecheck.LocalFunction,
) -> KnfClosure raise KnfTransformError {
  // add function type and name to name env
  let param_types : Array[Type] = []
  for param in local_function.param_list {
    let (_, param_ty) = param
    let param_type = self.typekind_to_knf(param_ty.kind)
    param_types.push(param_type)
  }
  let ret_ty = self.typekind_to_knf(local_function.ret_ty.kind)
  let closure_type = Function(param_types, ret_ty)
  let closure_name = self.add_new_name(local_function.fname, closure_type)
  // enter new scope for function body
  self.enter_scope()
  let knf_params = []
  for param in local_function.param_list {
    let (param_name, param_ty) = param
    let param_type = self.typekind_to_knf(param_ty.kind)
    let param = self.add_new_name(param_name, param_type)
    self.name_env.set(param_name, param, param_type, false)
    knf_params.push((param, param_type))
  }
  let new_body = self.block_expr_to_knf(local_function.body)
  let captured = self.name_env.capture
  self.exit_scope()
  KnfClosure::{
    name: closure_name,
    params: knf_params,
    ret_ty,
    body: new_body,
    captured_vars: captured,
  }
}
