///|
/// Performs the `atom_expr_to_knf` KNF lowering operation.
pub fn Context::atom_expr_to_knf(
  self : Context,
  atom_expr : @typecheck.AtomExpr,
) -> (Array[KnfStmt], KnfExpr) raise KnfTransformError {
  match atom_expr.kind {
    Unit => ([], KnfExpr::Unit)
    Int(value) => ([], KnfExpr::Int(value))
    Int64(value) => ([], KnfExpr::Int64(value))
    UInt(value) => ([], KnfExpr::UInt(value))
    UInt64(value) => ([], KnfExpr::UInt64(value))
    Bool(value) => ([], KnfExpr::Bool(value))
    Double(value) => ([], KnfExpr::Double(value))
    Float(value) => ([], KnfExpr::Float(value))
    Char(value) => ([], KnfExpr::Char(value))
    String(value) => ([], KnfExpr::String(value))
    Ident(name) => {
      guard self.lookup_name(name) is Some((knf_name, _)) else {
        raise KnfTransformError("Undefined identifier: \{name}")
      }
      ([], KnfExpr::Ident(knf_name))
    }
    Paren(inner_expr) => self.expr_to_knf(inner_expr)
    Array(exprs) => {
      let stmts : Array[KnfStmt] = []
      let knf_names : Array[Name] = []
      for expr in exprs {
        let (expr_stmts, expr_knf_expr) = self.expr_to_knf(expr)
        stmts.append(expr_stmts)
        let expr_ty = self.typekind_to_knf(expr.ty)
        let expr_name = self.expr_to_knf_name(expr_knf_expr, expr_ty, stmts)
        knf_names.push(expr_name)
      }
      let ty = self.typekind_to_knf(atom_expr.ty)
      guard ty is Array(ty) else {
        raise KnfTransformError("Expected array type for array literal")
      }
      (stmts, ArrayLiteral(ty, knf_names))
    }
    ArrayMake(size_expr, init_expr) => {
      let stmts : Array[KnfStmt] = []
      let (size_stmts, size_knf_expr) = self.expr_to_knf(size_expr)
      stmts.append(size_stmts)
      let size_ty = self.typekind_to_knf(size_expr.ty)
      let size_name = self.expr_to_knf_name(size_knf_expr, size_ty, stmts)
      let (init_stmts, init_knf_expr) = self.expr_to_knf(init_expr)
      stmts.append(init_stmts)
      let init_ty = self.typekind_to_knf(init_expr.ty)
      let init_name = self.expr_to_knf_name(init_knf_expr, init_ty, stmts)
      (stmts, ArrayMake(size_name, init_name))
    }
    Tuple(exprs) => {
      let stmts : Array[KnfStmt] = []
      let knf_names : Array[Name] = []
      for expr in exprs {
        let (expr_stmts, expr_knf_expr) = self.expr_to_knf(expr)
        stmts.append(expr_stmts)
        let expr_ty = self.typekind_to_knf(expr.ty)
        let expr_name = self.expr_to_knf_name(expr_knf_expr, expr_ty, stmts)
        knf_names.push(expr_name)
      }
      (stmts, TupleLiteral(knf_names))
    }
    StructConstruct(sc_expr) => {
      let stmts : Array[KnfStmt] = []
      let { name, fields, .. } = sc_expr
      let knf_fields : Array[(String, Name)] = []
      for field in fields {
        let (field_name, field_expr) = field
        let (field_stmts, field_knf_expr) = self.expr_to_knf(field_expr)
        stmts.append(field_stmts)
        let field_ty = self.typekind_to_knf(field_expr.ty)
        let field_name_knf = self.expr_to_knf_name(
          field_knf_expr, field_ty, stmts,
        )
        knf_fields.push((field_name, field_name_knf))
      }
      (stmts, CreateStruct(name, knf_fields))
    }
    Cast(target_ty, expr) => {
      let stmts : Array[KnfStmt] = []
      let (expr_stmts, expr_knf_expr) = self.expr_to_knf(expr)
      stmts.append(expr_stmts)
      let expr_ty = self.typekind_to_knf(expr.ty)
      let expr_name = self.expr_to_knf_name(expr_knf_expr, expr_ty, stmts)
      let target_ty_knf = self.typekind_to_knf(target_ty)
      (stmts, KnfExpr::Cast(target_ty_knf, expr_name))
    }
    BitCast(target_ty, expr) => {
      let stmts : Array[KnfStmt] = []
      let (expr_stmts, expr_knf_expr) = self.expr_to_knf(expr)
      stmts.append(expr_stmts)
      let expr_ty = self.typekind_to_knf(expr.ty)
      let expr_name = self.expr_to_knf_name(expr_knf_expr, expr_ty, stmts)
      let target_ty_knf = self.typekind_to_knf(target_ty)
      (stmts, KnfExpr::BitCast(target_ty_knf, expr_name))
    }
    EnumConstruct(tag, variant, exprs) => {
      let struct_variant_name = "\{tag}$\{variant}"
      // 1. find union type
      guard self.unions.get(tag) is Some(variant_names) else {
        raise KnfTransformError("Undefined enum tag: \{tag}")
      }
      // 2. find variant struct name, get index
      guard variant_names.search_by(v => v == struct_variant_name) is Some(idx) else {
        raise KnfTransformError(
          "Undefined variant: \{variant} for enum tag: \{tag}",
        )
      }
      let stmts : Array[KnfStmt] = []
      let knf_names : Array[Name] = []
      // first field is tag
      let let_tag_name = self.add_temp(Int)
      stmts.push(Let(let_tag_name, Int, Int(idx)))
      for expr in exprs {
        let (expr_stmts, expr_knf_expr) = self.expr_to_knf(expr)
        stmts.append(expr_stmts)
        let expr_ty = self.typekind_to_knf(expr.ty)
        let expr_name = self.expr_to_knf_name(expr_knf_expr, expr_ty, stmts)
        knf_names.push(expr_name)
      }
      let knf_fields : Array[(String, Name)] = []
      knf_fields.push(("tag", let_tag_name))
      for i in 0..<knf_names.length() {
        knf_fields.push(("$\{i}", knf_names[i]))
      }
      // 3. build struct fields
      // enum_struct fields: int $tag, type $0, type $1, ...
      (stmts, CreateStruct(struct_variant_name, knf_fields))
    }
  }
}
