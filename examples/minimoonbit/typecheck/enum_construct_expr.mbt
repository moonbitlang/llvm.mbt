///|
/// Type-checks the corresponding parser AST form through `check_enum_constuct_expr`.
pub fn Context::check_enum_constuct_expr(
  self : Context,
  tag : String?,
  variant_name : String,
  exprs : Array[@parser.Expr],
  ori_atom_expr : @parser.AtomExpr,
) -> (AtomExprKind, TypeKind) {
  let checked_exprs = exprs.map(e => self.check_expr(e))
  let enum_def = if tag is Some(tag) {
    guard self.enum_defs.get(tag) is Some(enum_def) else {
      self.throw_(ori_atom_expr.toks[0], "Undefined enum: {tag}", Error)
      return (AtomExprKind::Unit, TypeKind::Unit)
    }
    enum_def
  } else {
    let possible_enum_defs = self.find_enum_def_by_variant_name(variant_name)
    guard possible_enum_defs.length() > 0 else {
      self.throw_(
        ori_atom_expr.toks[0],
        "Undefined variant: \{variant_name} in any enum",
        Error,
      )
      return (AtomExprKind::Unit, TypeKind::Unit)
    }
    guard possible_enum_defs.length() == 1 else {
      self.throw_(
        ori_atom_expr.toks[0],
        "Ambiguous variant: \{variant_name} found in multiple enums",
        Error,
      )
      return (AtomExprKind::Unit, TypeKind::Unit)
    }
    possible_enum_defs[0]
  }
  let enum_field = match enum_def.get_field(variant_name) {
    Some(field) => field
    None => {
      self.throw_(
        ori_atom_expr.toks[0],
        "Undefined variant: \{variant_name} in enum \{tag}",
        Error,
      )
      return (AtomExprKind::Unit, TypeKind::Unit)
    }
  }
  let enum_field_types = enum_field.types
  let checked_exprs_types = checked_exprs.map(e => e.ty)
  if enum_field_types.length() != checked_exprs_types.length() {
    let msg = "Variant \{variant_name} in enum \{tag} expects " +
      "\{enum_field_types.length()} fields, but \{checked_exprs_types.length()} were provided"
    self.throw_(ori_atom_expr.toks[0], msg, Error)
  } else {
    for i in 0..<min(enum_field_types.length(), checked_exprs_types.length()) {
      if self.is_type_compatible(checked_exprs_types[i], enum_field_types[i])
        is false {
        let msg = "Field \{i} of variant \{variant_name} in enum \{tag} expects type " +
          "\{enum_field_types[i].to_string()}, but got \{checked_exprs_types[i].to_string()}"
        self.throw_(ori_atom_expr.toks[0], msg, Error)
      }
    }
  }
  let enum_construct_expr = AtomExprKind::EnumConstruct(
    enum_def.name,
    variant_name,
    checked_exprs,
  )
  let type_kind = TypeKind::Enum(enum_def.name)
  (enum_construct_expr, type_kind)
}
