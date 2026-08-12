///|
/// Represents the MiniMoonBit typed AST node or context `LetStmt`.
pub(all) struct LetStmt {
  /// Stores the `pattern` component of this typed AST value.
  pattern : Pattern
  /// Stores the `ty` component of this typed AST value.
  ty : TypeKind
  /// Stores the `expr` component of this typed AST value.
  expr : Expr
}

///|
/// Formats `LetStmt` using MiniMoonBit typed AST notation.
pub impl Show for LetStmt with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `LetStmt` value with optional ANSI coloring.
pub fn LetStmt::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "let statement"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }

  // Format pattern
  let pattern_str = self.pattern.to_string(color~)
  let pattern_lines = pattern_str
    .split("\n")
    .map(fn(sv) { sv.to_string() })
    .to_array()
  let pattern_formatted = @parser.format_lines(
    pattern_lines,
    head_with="├-pattern: ",
    continue_with="│         ",
  )

  // Format type
  let ty_str = ": \{self.ty}"
  let type_formatted = @parser.format_lines(
    [ty_str],
    head_with="├-type: ",
    continue_with="│       ",
  )

  // Format expression
  let expr_str = self.expr.to_string(color~)
  let expr_lines = expr_str
    .split("\n")
    .map(fn(sv) { sv.to_string() })
    .to_array()
  let expr_formatted = @parser.format_lines(
    expr_lines,
    head_with="└-expr: ",
    continue_with="        ",
  )
  "\{prefix}\n\{pattern_formatted}\n\{type_formatted}\n\{expr_formatted}"
}

///|
/// Represents the MiniMoonBit typed AST node or context `Pattern`.
pub(all) struct Pattern {
  /// Stores the `kind` component of this typed AST value.
  kind : PatternKind
} derive(Eq)

///|
/// Formats `Pattern` using MiniMoonBit typed AST notation.
pub impl Show for Pattern with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `Pattern` value with optional ANSI coloring.
pub fn Pattern::to_string(self : Self, color? : Bool = true) -> String {
  match self.kind {
    Wildcard => "_"
    Boolean(b) => {
      let prefix = "bool pattern"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      let b = if b { "true" } else { "false" }
      "\{prefix} \{b}"
    }
    Integer(i) => {
      let prefix = "int pattern"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      "\{prefix} \{i}"
    }
    Ident(name) => {
      let prefix = "ident pattern"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      "\{prefix} \{name}"
    }
    Tuple(patterns) => {
      let prefix = "tuple pattern"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      if patterns.is_empty() {
        "\{prefix} ()"
      } else {
        let mut result = "\{prefix}\n"
        for i = 0; i < patterns.length(); i = i + 1 {
          let pattern_str = patterns[i].to_string(color~)
          let lines = pattern_str
            .split("\n")
            .map(fn(sv) { sv.to_string() })
            .to_array()
          let is_last = i == patterns.length() - 1
          let formatted = if is_last {
            @parser.format_lines(lines, head_with="└-", continue_with="  ")
          } else {
            @parser.format_lines(lines, head_with="├-", continue_with="│ ")
          }
          result = result + formatted
          if i < patterns.length() - 1 {
            result = result + "\n"
          }
        }
        result
      }
    }
    EnumVariant(tag, variant, patterns) => {
      let tag_prefix = "\{tag}::"
      let prefix = "enum pattern"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      if patterns.is_empty() {
        "\{prefix} \{tag_prefix}\{variant}"
      } else {
        let mut result = "\{prefix} \{tag_prefix}\{variant}\n"
        for i = 0; i < patterns.length(); i = i + 1 {
          let pattern_str = patterns[i].to_string(color~)
          let lines = pattern_str
            .split("\n")
            .map(fn(sv) { sv.to_string() })
            .to_array()
          let is_last = i == patterns.length() - 1
          let formatted = if is_last {
            @parser.format_lines(lines, head_with="└-", continue_with="  ")
          } else {
            @parser.format_lines(lines, head_with="├-", continue_with="│ ")
          }
          result = result + formatted
          if i < patterns.length() - 1 {
            result = result + "\n"
          }
        }
        result
      }
    }
  }
}

///|
/// Enumerates the typed forms represented by `PatternKind`.
pub(all) enum PatternKind {
  /// Represents the `Wildcard` typed AST form.
  Wildcard
  /// Represents the `Boolean` typed AST form.
  Boolean(Bool)
  /// Represents the `Integer` typed AST form.
  Integer(Int)
  /// Represents the `Ident` typed AST form.
  Ident(String)
  /// Represents the `Tuple` typed AST form.
  Tuple(Array[Pattern])
  /// Represents the `EnumVariant` typed AST form.
  EnumVariant(String, String, Array[Pattern])
} derive(Eq)

///|
/// Formats `PatternKind` using MiniMoonBit typed AST notation.
pub impl Show for PatternKind with fn output(self, logger) {
  let s = match self {
    Wildcard => "_"
    Boolean(b) => b.to_string()
    Integer(i) => i.to_string()
    Ident(name) => name
    Tuple(patterns) => {
      let elems = patterns.map(p => p.to_string(color=true))
      let elem_str = elems.join(", ")
      "(\{elem_str})"
    }
    EnumVariant(tag, variant, patterns) => {
      let elems = patterns.map(p => p.to_string(color=true))
      let elem_str = elems.join(", ")
      "\{tag}::\{variant}(\{elem_str})"
    }
  }
  logger.write_string(s)
}

///|
fn Context::from_parser_pattern(
  self : Context,
  pattern : @parser.Pattern,
) -> Pattern raise TypeCheckError {
  match pattern.kind {
    Wildcard => Pattern::{ kind: PatternKind::Wildcard }
    Boolean(b) => Pattern::{ kind: PatternKind::Boolean(b) }
    Integer(i) => Pattern::{ kind: PatternKind::Integer(i) }
    Ident(name) => Pattern::{ kind: PatternKind::Ident(name) }
    Tuple(sub_patterns) => {
      let patterns = sub_patterns.map(p => self.from_parser_pattern(p))
      Pattern::{ kind: PatternKind::Tuple(patterns) }
    }
    EnumVariant(tag, variant_name, sub_patterns) => {
      let patterns = sub_patterns.map(p => self.from_parser_pattern(p))
      let tag = match tag {
        Some(t) => t
        None => {
          let enum_defs = self.find_enum_def_by_variant_name(variant_name)
          guard enum_defs.length() == 1 else {
            raise TypeCheckError(
              "Ambiguous enum variant name `\{variant_name}` found in multiple enum definitions",
            )
          }
          enum_defs[0].name
        }
      }
      Pattern::{ kind: PatternKind::EnumVariant(tag, variant_name, patterns) }
    }
  }
}

///|
/// Type-checks the corresponding parser AST form through `check_let_stmt`.
pub fn Context::check_let_stmt(
  self : Context,
  let_stmt : @parser.LetStmt,
) -> LetStmt raise TypeCheckError {
  let checked_expr = self.check_expr(let_stmt.expr)
  let type_kind = checked_expr.ty
  if let_stmt.ty is Some(type_annote) {
    let annoted_type = self.check_parser_typekind(type_annote.kind)
    if !self.is_type_compatible(annoted_type, checked_expr.ty) {
      raise TypeCheckError(
        "Type annotation does not match the expression type, annoted: \{annoted_type}, expr: \{checked_expr.ty}",
      )
    }
  }
  let type_kind = self.ensure_type(type_kind)
  let pattern = self.from_parser_pattern(let_stmt.pattern)
  self.bind_pattern_type(pattern, type_kind)
  LetStmt::{ pattern, ty: type_kind, expr: checked_expr }
}

///|
fn Context::bind_pattern_type(
  self : Context,
  pattern : Pattern,
  ty_kind : TypeKind,
) -> Unit raise TypeCheckError {
  match pattern.kind {
    Wildcard => ()
    Integer(_) => {
      guard ty_kind is Int else {
        raise TypeCheckError("Pattern is an integer but type is not an integer")
      }
    }
    Boolean(_) => {
      guard ty_kind is Bool else {
        raise TypeCheckError("Pattern is a boolean but type is not a boolean")
      }
    }
    EnumVariant(tag, variant_name, sub_pattern) => {
      guard ty_kind is Enum(enum_name) else {
        raise TypeCheckError(
          "Pattern is an enum variant but type is not an enum",
        )
      }
      guard enum_name == tag else {
        raise TypeCheckError(
          "Enum variant pattern tag `\{tag}` does not match enum type `\{enum_name}`",
        )
      }
      guard self.enum_defs.get(enum_name) is Some(enum_def) else {
        raise TypeCheckError(
          "Enum `\{enum_name}` not found in type environment",
        )
      }
      guard enum_def.get_field(variant_name) is Some(enum_fields) else {
        raise TypeCheckError(
          "Enum variant `\{variant_name}` not found in enum `\{enum_name}`",
        )
      }
      if enum_fields.types.length() != sub_pattern.length() {
        // for pattern like `Color(_)`, it's valid, even though Color has multiple fields
        if sub_pattern is [pat] &&
          pat.kind is Wildcard &&
          enum_fields.types.length() > 1 {
          return
        }
        raise TypeCheckError(
          "Enum variant pattern length does not match enum variant field length",
        )
      }
      for i in 0..<sub_pattern.length() {
        self.bind_pattern_type(sub_pattern[i], enum_fields.types[i])
      }
    }
    Ident(name) =>
      self.type_env.set(name, Type::{ kind: ty_kind, mutable: false })
    Tuple(sub_patterns) => {
      guard ty_kind is Tuple(element_types) else {
        raise TypeCheckError("Pattern is a tuple but type is not a tuple")
      }
      if sub_patterns.length() != element_types.length() {
        raise TypeCheckError(
          "Tuple pattern length does not match tuple type length",
        )
      }
      for i in 0..<sub_patterns.length() {
        self.bind_pattern_type(sub_patterns[i], element_types[i])
      }
    }
  }
}

///|
test "LetStmt to_string Test - Basic" {
  let color = false
  let ctx = Context::new()
  let code =
    #|let x = 42 ;
  let tokens = @lexer.tokenize(code)

  // Test simple let: let x = 42
  let (stmt, _) = @parser.parse_stmt(tokens[:])
  let checked = ctx.check_stmt(stmt)
  inspect(
    checked.to_string(color~),
    content=(
      #|let statement
      #|├-pattern: ident pattern x
      #|├-type: : Int
      #|└-expr: int literal 42 (Int)
    ),
  )
}

///|
test "LetStmt to_string Test - Pattern" {
  let color = false
  let ctx = Context::new()
  let code =
    #|let (a, b) = (1, 2) ;
  let tokens = @lexer.tokenize(code)

  // Test tuple pattern: let (a, b) = (1, 2)
  let (stmt, _) = @parser.parse_stmt(tokens[:])
  let checked = ctx.check_stmt(stmt)
  inspect(
    checked.to_string(color~),
    content=(
      #|let statement
      #|├-pattern: tuple pattern
      #|│         ├-ident pattern a
      #|│         └-ident pattern b
      #|├-type: : (Int, Int)
      #|└-expr: tuple
      #|        ├-int literal 1 (Int)
      #|        └-int literal 2 (Int) ((Int, Int))
    ),
  )
}
