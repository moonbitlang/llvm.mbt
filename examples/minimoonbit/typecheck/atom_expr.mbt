///|
/// Represents the MiniMoonBit typed AST node or context `AtomExpr`.
pub(all) struct AtomExpr {
  /// Stores the `kind` component of this typed AST value.
  kind : AtomExprKind
  /// Stores the `ty` component of this typed AST value.
  ty : TypeKind
  /// Stores the `toks` component of this typed AST value.
  toks : ArrayView[Token]
}

///|
/// Formats `AtomExpr` using MiniMoonBit typed AST notation.
pub impl Show for AtomExpr with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `AtomExpr` value with optional ANSI coloring.
pub fn AtomExpr::to_string(self : Self, color? : Bool = true) -> String {
  let base_str = match self.kind {
    Int(v) => {
      let prefix = "int literal"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      "\{prefix} \{v}"
    }
    Int64(v) => {
      let prefix = "int64 literal"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      "\{prefix} \{v}L"
    }
    UInt(v) => {
      let prefix = "uint literal"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      "\{prefix} \{v}U"
    }
    UInt64(v) => {
      let prefix = "uint64 literal"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      "\{prefix} \{v}UL"
    }
    Double(v) => {
      let prefix = "double literal"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      "\{prefix} \{v}"
    }
    Float(v) => {
      let prefix = "float literal"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      "\{prefix} \{v}F"
    }
    Char(c) => {
      let prefix = "char literal"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      "\{prefix} '\{c}'"
    }
    Bool(b) => {
      let prefix = "bool literal"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      "\{prefix} \{b}"
    }
    String(s) => {
      let prefix = "string literal"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      "\{prefix} \"\{s}\""
    }
    Ident(name) => {
      let prefix = "variable"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      "\{prefix} \{name}"
    }
    Unit => {
      let prefix = "unit"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      "\{prefix} ()"
    }
    Paren(expr) => expr.to_string(color~)
    Tuple(exprs) => {
      let prefix = "tuple"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      if exprs.is_empty() {
        "\{prefix} ()"
      } else {
        let mut result = "\{prefix}\n"
        for i = 0; i < exprs.length(); i = i + 1 {
          let expr_str = exprs[i].to_string(color~)
          let lines = expr_str.split("\n").map(sv => sv.to_owned()).to_array()
          let is_last = i == exprs.length() - 1
          let formatted = if is_last {
            @parser.format_lines(lines, head_with="└-", continue_with="  ")
          } else {
            @parser.format_lines(lines, head_with="├-", continue_with="│ ")
          }
          result = result + formatted
          if i < exprs.length() - 1 {
            result = result + "\n"
          }
        }
        result
      }
    }
    Array(exprs) => {
      let prefix = "array"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      if exprs.is_empty() {
        "\{prefix} []"
      } else {
        let mut result = "\{prefix}\n"
        for i = 0; i < exprs.length(); i = i + 1 {
          let expr_str = exprs[i].to_string(color~)
          let lines = expr_str.split("\n").map(sv => sv.to_owned()).to_array()
          let is_last = i == exprs.length() - 1
          let formatted = if is_last {
            @parser.format_lines(lines, head_with="└-", continue_with="  ")
          } else {
            @parser.format_lines(lines, head_with="├-", continue_with="│ ")
          }
          result = result + formatted
          if i < exprs.length() - 1 {
            result = result + "\n"
          }
        }
        result
      }
    }
    ArrayMake(size_expr, init_expr) => {
      let prefix = "array make"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      let size_str = size_expr.to_string(color~)
      let init_str = init_expr.to_string(color~)
      let size_lines = size_str.split("\n").map(sv => sv.to_owned()).to_array()
      let init_lines = init_str.split("\n").map(sv => sv.to_owned()).to_array()
      let size_formatted = @parser.format_lines(
        size_lines,
        head_with="├-size: ",
        continue_with="│       ",
      )
      let init_formatted = @parser.format_lines(
        init_lines,
        head_with="└-init: ",
        continue_with="        ",
      )
      "\{prefix}\n\{size_formatted}\n\{init_formatted}"
    }
    StructConstruct(struct_construct) => struct_construct.to_string(color~)
    EnumConstruct(tag, variant, exprs) => {
      let tag_prefix = "\{tag}::"
      let prefix = "enum construct"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      if exprs.is_empty() {
        "\{prefix} \{tag_prefix}\{variant}"
      } else {
        let mut result = "\{prefix} \{tag_prefix}\{variant}\n"
        for i = 0; i < exprs.length(); i = i + 1 {
          let expr_str = exprs[i].to_string(color~)
          let lines = expr_str.split("\n").map(sv => sv.to_owned()).to_array()
          let is_last = i == exprs.length() - 1
          let formatted = if is_last {
            @parser.format_lines(lines, head_with="└-", continue_with="  ")
          } else {
            @parser.format_lines(lines, head_with="├-", continue_with="│ ")
          }
          result = result + formatted
          if i < exprs.length() - 1 {
            result = result + "\n"
          }
        }
        result
      }
    }
    Cast(ty, expr) => {
      let prefix = "cast"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      let ty_str = ty.to_string()
      let expr_str = expr.to_string(color~)
      let lines = expr_str.split("\n").map(sv => sv.to_owned()).to_array()
      let formatted = @parser.format_lines(lines)
      "\{prefix} to \{ty_str}\n\{formatted}"
    }
    BitCast(ty, expr) => {
      let prefix = "bitcast"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      let ty_str = ty.to_string()
      let expr_str = expr.to_string(color~)
      let lines = expr_str.split("\n").map(sv => sv.to_owned()).to_array()
      let formatted = @parser.format_lines(lines)
      "\{prefix} to \{ty_str}\n\{formatted}"
    }
  }
  // Add type annotation in parentheses
  let ty_str = self.ty.to_string()
  let ty_str = if color { @color.taint(ty_str, Green) } else { ty_str }
  "\{base_str} (\{ty_str})"
}

///|
/// Enumerates the typed forms represented by `AtomExprKind`.
pub(all) enum AtomExprKind {
  /// Represents the `Int` typed AST form.
  Int(Int) // 1, 42, etc
  /// Represents the `Int64` typed AST form.
  Int64(Int64) // 1L, 42L, etc
  /// Represents the `UInt` typed AST form.
  UInt(UInt) // 1U, 42U, etc
  /// Represents the `UInt64` typed AST form.
  UInt64(UInt64) // 1UL, 42UL, etc
  /// Represents the `Double` typed AST form.
  Double(Double) // 1.0, 3.14, etc
  /// Represents the `Float` typed AST form.
  Float(Double) // 1.0F, 3.14F (stored as Double)
  /// Represents the `Char` typed AST form.
  Char(Char) // 'a', '\n', etc
  /// Represents the `Bool` typed AST form.
  Bool(Bool) // true | false
  /// Represents the `String` typed AST form.
  String(String) // "hello", etc
  /// Represents the `Ident` typed AST form.
  Ident(String) // var
  /// Represents the `Unit` typed AST form.
  Unit // ()
  /// Represents the `Paren` typed AST form.
  Paren(Expr) // (expr)
  /// Represents the `Tuple` typed AST form.
  Tuple(Array[Expr]) // (expr, expr, ...)
  /// Represents the `Array` typed AST form.
  Array(Array[Expr]) // [expr, expr, ...]
  /// Represents the `ArrayMake` typed AST form.
  ArrayMake(Expr, Expr) // Array::make(size, init)
  /// Represents the `StructConstruct` typed AST form.
  StructConstruct(StructConstructExpr) // StructName::{ field: expr, ... }
  /// Represents the `EnumConstruct` typed AST form.
  EnumConstruct(String, String, Array[Expr]) // [Tag::]Variant(expr, ...)
  /// Represents the `Cast` typed AST form.
  Cast(TypeKind, Expr) // Type cast: e.g., n.to_int()
  /// Represents the `BitCast` typed AST form.
  BitCast(TypeKind, Expr) // Bitcast: e.g., n.reinterpret_as_float()
}

///|
/// Formats an `AtomExprKind` using constructor notation.
pub impl Show for AtomExprKind with fn output(self, logger) {
  match self {
    Int(value) => {
      logger.write_string("Int(")
      logger.write_object(value)
      logger.write_string(")")
    }
    Int64(value) => {
      logger.write_string("Int64(")
      logger.write_object(value)
      logger.write_string(")")
    }
    UInt(value) => {
      logger.write_string("UInt(")
      logger.write_object(value)
      logger.write_string(")")
    }
    UInt64(value) => {
      logger.write_string("UInt64(")
      logger.write_object(value)
      logger.write_string(")")
    }
    Double(value) => {
      logger.write_string("Double(")
      logger.write_object(value)
      logger.write_string(")")
    }
    Float(value) => {
      logger.write_string("Float(")
      logger.write_object(value)
      logger.write_string(")")
    }
    Char(value) => {
      logger.write_string("Char(")
      logger.write_object(value)
      logger.write_string(")")
    }
    Bool(value) => {
      logger.write_string("Bool(")
      logger.write_object(value)
      logger.write_string(")")
    }
    String(value) => {
      logger.write_string("String(")
      logger.write_object(value)
      logger.write_string(")")
    }
    Ident(name) => {
      logger.write_string("Ident(")
      logger.write_object(name)
      logger.write_string(")")
    }
    Unit => logger.write_string("Unit")
    Paren(expr) => {
      logger.write_string("Paren(")
      logger.write_object(expr)
      logger.write_string(")")
    }
    Tuple(exprs) => {
      logger.write_string("Tuple([")
      for index, expr in exprs {
        if index > 0 {
          logger.write_string(", ")
        }
        logger.write_object(expr)
      }
      logger.write_string("])")
    }
    Array(exprs) => {
      logger.write_string("Array([")
      for index, expr in exprs {
        if index > 0 {
          logger.write_string(", ")
        }
        logger.write_object(expr)
      }
      logger.write_string("])")
    }
    ArrayMake(size, initial) => {
      logger.write_string("ArrayMake(")
      logger.write_object(size)
      logger.write_string(", ")
      logger.write_object(initial)
      logger.write_string(")")
    }
    StructConstruct(expr) => {
      logger.write_string("StructConstruct(")
      logger.write_object(expr)
      logger.write_string(")")
    }
    EnumConstruct(tag, variant, exprs) => {
      logger.write_string("EnumConstruct(")
      logger.write_object(tag)
      logger.write_string(", ")
      logger.write_object(variant)
      logger.write_string(", [")
      for index, expr in exprs {
        if index > 0 {
          logger.write_string(", ")
        }
        logger.write_object(expr)
      }
      logger.write_string("])")
    }
    Cast(ty, expr) => {
      logger.write_string("Cast(")
      logger.write_object(ty)
      logger.write_string(", ")
      logger.write_object(expr)
      logger.write_string(")")
    }
    BitCast(ty, expr) => {
      logger.write_string("BitCast(")
      logger.write_object(ty)
      logger.write_string(", ")
      logger.write_object(expr)
      logger.write_string(")")
    }
  }
}

///|
/// Type-checks the corresponding parser AST form through `check_atom_expr`.
pub fn Context::check_atom_expr(
  self : Self,
  atom_expr : @parser.AtomExpr,
) -> AtomExpr {
  let (typed_atom_expr_kind, type_kind) = match atom_expr.kind {
    Int(v) => (AtomExprKind::Int(v), TypeKind::Int)
    Int64(v) => (AtomExprKind::Int64(v), TypeKind::Int64)
    UInt(v) => (AtomExprKind::UInt(v), TypeKind::UInt)
    UInt64(v) => (AtomExprKind::UInt64(v), TypeKind::UInt64)
    Double(v) => (Double(v), Double)
    Float(v) => (Float(v), Float)
    Char(c) => (Char(c), Char)
    Bool(v) => (Bool(v), Bool)
    String(s) => (String(s), String)
    Unit => (Unit, Unit)
    Ident(name) => {
      let ty = match self.lookup_type(name) {
        Some(ty) => ty
        None => {
          self.throw_(atom_expr.toks[0], "Undefined identifier: \{name}", Error)
          { kind: TypeKind::Unit, mutable: false, }
        }
      }
      (Ident(name), ty.kind)
    }
    IdentWithTag(tag, name) => {
      let whole_name = "\{tag}$$\{name}"
      let ty = match self.lookup_type(whole_name) {
        Some(ty) => ty
        None => {
          self.throw_(
            atom_expr.toks[0],
            "Undefined identifier: \{tag}::\{name}",
            Error,
          )
          { kind: TypeKind::Unit, mutable: false, }
        }
      }
      // Use the mangled name (whole_name) instead of just name
      (Ident(whole_name), ty.kind)
    }
    Paren(expr) => {
      let typed_expr = self.check_expr(expr)
      (Paren(typed_expr), typed_expr.ty)
    }
    Array(exprs) => self.check_array_expr(exprs)
    ArrayMake(size_expr, init_expr) =>
      self.check_array_make_expr(size_expr, init_expr)
    Tuple(exprs) => self.check_tuple_expr(exprs)
    EnumConstruct(tag, variant_name, exprs) =>
      self.check_enum_constuct_expr(tag, variant_name, exprs, atom_expr)
    StructConstruct(sc_expr) => self.check_struct_construct_expr(sc_expr)
  }
  AtomExpr::{ kind: typed_atom_expr_kind, ty: type_kind, toks: atom_expr.toks, }
}

///|
/// Type-checks the corresponding parser AST form through `check_array_expr`.
pub fn Context::check_array_expr(
  self : Self,
  exprs : Array[@parser.Expr],
) -> (AtomExprKind, TypeKind) {
  let exprs = exprs.map(e => self.check_expr(e))
  if exprs.length() == 0 {
    let atom_expr_kind = AtomExprKind::Array([])
    let type_kind = self.add_type_var()
    return (atom_expr_kind, Array(type_kind))
  }
  for expr in exprs {
    if self.is_type_compatible(expr.ty, exprs[0].ty) == false {
      self.throw_(
        expr.toks[0],
        "Array elements must have the same type, found \{exprs[0].ty} and \{expr.ty}",
        Error,
      )
    }
  }
  let atom_expr_kind : AtomExprKind = AtomExprKind::Array(exprs)
  let type_kind = self.ensure_type(exprs[0].ty)
  (atom_expr_kind, Array(type_kind))
}

///|
/// Type-checks the corresponding parser AST form through `check_array_make_expr`.
pub fn Context::check_array_make_expr(
  self : Self,
  size_expr : @parser.Expr,
  init_expr : @parser.Expr,
) -> (AtomExprKind, TypeKind) {
  let typed_size_expr = self.check_expr(size_expr)
  if !(typed_size_expr.ty is Int) {
    let msg = "Array size must be of type Int, while got \{typed_size_expr.ty}"
    self.set_error_happened()
    self.throw_(typed_size_expr.toks[0], msg, Error)
  }
  let typed_init_expr = self.check_expr(init_expr)
  let atom_expr_kind = AtomExprKind::ArrayMake(typed_size_expr, typed_init_expr)
  let type_kind = TypeKind::Array(typed_init_expr.ty)
  (atom_expr_kind, type_kind)
}

///|
/// Type-checks the corresponding parser AST form through `check_tuple_expr`.
pub fn Context::check_tuple_expr(
  self : Self,
  exprs : Array[@parser.Expr],
) -> (AtomExprKind, TypeKind) {
  let typed_exprs = exprs.map(e => self.check_expr(e))
  let atom_expr_kind = AtomExprKind::Tuple(typed_exprs)
  let type_kind = TypeKind::Tuple(typed_exprs.map(e => e.ty))
  (atom_expr_kind, type_kind)
}

///|
test "AtomExpr to_string Test" {
  let color = false
  let ctx = Context::new()
  ctx.type_env.set("x", { kind: TypeKind::Int, mutable: false, })
  let code =
    #|42 ; 100L ; 200U ; 300UL ; 3.14 ; 2.5F ; 'c' ; true ; "hello" ; x ; ()
  let tokens = @lexer.tokenize(code)

  // Test Int: 42
  let (parsed, rest) = @parser.parse_atom_expr(tokens[:])
  let checked = ctx.check_atom_expr(parsed)
  inspect(checked.to_string(color~), content="int literal 42 (Int)")

  // Test Int64: 100L
  let (parsed, rest) = @parser.parse_atom_expr(rest[1:])
  let checked = ctx.check_atom_expr(parsed)
  inspect(checked.to_string(color~), content="int64 literal 100L (Int64)")

  // Test UInt: 200U
  let (parsed, rest) = @parser.parse_atom_expr(rest[1:])
  let checked = ctx.check_atom_expr(parsed)
  inspect(checked.to_string(color~), content="uint literal 200U (UInt)")

  // Test UInt64: 300UL
  let (parsed, rest) = @parser.parse_atom_expr(rest[1:])
  let checked = ctx.check_atom_expr(parsed)
  inspect(checked.to_string(color~), content="uint64 literal 300UL (UInt64)")

  // Test Double: 3.14
  let (parsed, rest) = @parser.parse_atom_expr(rest[1:])
  let checked = ctx.check_atom_expr(parsed)
  inspect(checked.to_string(color~), content="double literal 3.14 (Double)")

  // Test Float: 2.5F
  let (parsed, rest) = @parser.parse_atom_expr(rest[1:])
  let checked = ctx.check_atom_expr(parsed)
  inspect(checked.to_string(color~), content="float literal 2.5F (Float)")

  // Test Char: 'c'
  let (parsed, rest) = @parser.parse_atom_expr(rest[1:])
  let checked = ctx.check_atom_expr(parsed)
  inspect(checked.to_string(color~), content="char literal 'c' (Char)")

  // Test Bool: true
  let (parsed, rest) = @parser.parse_atom_expr(rest[1:])
  let checked = ctx.check_atom_expr(parsed)
  inspect(checked.to_string(color~), content="bool literal true (Bool)")

  // Test String: "hello"
  let (parsed, rest) = @parser.parse_atom_expr(rest[1:])
  let checked = ctx.check_atom_expr(parsed)
  inspect(
    checked.to_string(color~),
    content="string literal \"hello\" (String)",
  )

  // Test Ident: x
  let (parsed, rest) = @parser.parse_atom_expr(rest[1:])
  let checked = ctx.check_atom_expr(parsed)
  inspect(checked.to_string(color~), content="variable x (Int)")

  // Test Unit: ()
  let (parsed, _) = @parser.parse_atom_expr(rest[1:])
  let checked = ctx.check_atom_expr(parsed)
  inspect(checked.to_string(color~), content="unit () (Unit)")
}
