///|
/// Represents the MiniMoonBit parser AST node `AtomExpr`.
pub(all) struct AtomExpr {
  /// Stores the `kind` component of this parser AST node.
  kind : AtomExprKind
  /// Stores the `toks` component of this parser AST node.
  toks : ArrayView[Token]
} derive(Eq)

///|
/// Formats `AtomExpr` using MiniMoonBit source notation.
pub impl Show for AtomExpr with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `AtomExpr` value with optional ANSI coloring.
pub fn AtomExpr::to_string(self : Self, color? : Bool = true) -> String {
  match self.kind {
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
            format_lines(lines, head_with="└-", continue_with="  ")
          } else {
            format_lines(lines, head_with="├-", continue_with="│ ")
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
            format_lines(lines, head_with="└-", continue_with="  ")
          } else {
            format_lines(lines, head_with="├-", continue_with="│ ")
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
      let size_formatted = format_lines(
        size_lines,
        head_with="├-size: ",
        continue_with="│       ",
      )
      let init_formatted = format_lines(
        init_lines,
        head_with="└-init: ",
        continue_with="        ",
      )
      "\{prefix}\n\{size_formatted}\n\{init_formatted}"
    }
    EnumConstruct(tag, variant, exprs) => {
      let tag_prefix = match tag {
        Some(t) => "\{t}::"
        None => ""
      }
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
            format_lines(lines, head_with="└-", continue_with="  ")
          } else {
            format_lines(lines, head_with="├-", continue_with="│ ")
          }
          result = result + formatted
          if i < exprs.length() - 1 {
            result = result + "\n"
          }
        }
        result
      }
    }
    StructConstruct(struct_construct) => struct_construct.to_string(color~)
    _ => {
      let (prefix, value) = match self.kind {
        Int(v) => ("int literal", "\{v}")
        Int64(v) => ("int64 literal", "\{v}L")
        UInt(v) => ("uint literal", "\{v}U")
        UInt64(v) => ("uint64 literal", "\{v}UL")
        Double(v) => ("double literal", "\{v}")
        Float(v) => ("float literal", "\{v}F")
        Char(c) => ("char literal", "'\{c}'")
        Bool(b) => ("bool literal", "\{b}")
        String(s) => ("string literal", "\"\{s}\"")
        Ident(name) => ("variable", "\{name}")
        IdentWithTag(tag, ident) => ("tagged variable", "\{tag}::\{ident}")
        Unit => ("unit", "()")
        Paren(_)
        | Tuple(_)
        | Array(_)
        | ArrayMake(_, _)
        | EnumConstruct(_, _, _)
        | StructConstruct(_) => ("", "")
      }
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      "\{prefix} \{value}"
    }
  }
}

///|
/// Enumerates the parser AST forms represented by `AtomExprKind`.
pub(all) enum AtomExprKind {
  /// Represents the `Int` parser AST form.
  Int(Int) // 1, 42, etc
  /// Represents the `Int64` parser AST form.
  Int64(Int64) // 1L, 42L, etc
  /// Represents the `UInt` parser AST form.
  UInt(UInt) // 1U, 42U, etc
  /// Represents the `UInt64` parser AST form.
  UInt64(UInt64) // 1UL, 42UL, etc
  /// Represents the `Double` parser AST form.
  Double(Double) // 1.0, 3.14, etc
  /// Represents the `Float` parser AST form.
  Float(Double) // 1.0F, 3.14F (stored as Double)
  /// Represents the `Char` parser AST form.
  Char(Char) // 'a', '\n', etc
  /// Represents the `Bool` parser AST form.
  Bool(Bool) // true | false
  /// Represents the `String` parser AST form.
  String(String) // "hello", etc
  /// Represents the `Ident` parser AST form.
  Ident(String) // var
  /// Represents the `IdentWithTag` parser AST form.
  IdentWithTag(String, String) // Point::x
  /// Represents the `Unit` parser AST form.
  Unit // ()
  /// Represents the `Paren` parser AST form.
  Paren(Expr) // (expr)
  /// Represents the `Tuple` parser AST form.
  Tuple(Array[Expr]) // (expr, expr, ...)
  /// Represents the `Array` parser AST form.
  Array(Array[Expr]) // [expr, expr, ...]
  /// Represents the `ArrayMake` parser AST form.
  ArrayMake(Expr, Expr) // Array::make(size, init)
  /// Represents the `EnumConstruct` parser AST form.
  EnumConstruct(String?, String, Array[Expr]) // EnumTag::Variant(expr, ...)
  /// Represents the `StructConstruct` parser AST form.
  StructConstruct(StructConstructExpr) // StructName::{ field: expr, ... }
} derive(Eq)

///|
/// Formats `AtomExprKind` using MiniMoonBit source notation.
pub impl Show for AtomExprKind with fn output(self, logger) {
  let s = match self {
    Int(v) => "\{v}"
    Int64(v) => "\{v}L"
    UInt(v) => "\{v}U"
    UInt64(v) => "\{v}UL"
    Double(v) => "\{v}"
    Float(v) => "\{v}F"
    Char(c) => "'\{c}'"
    Bool(b) => "\{b}"
    String(s) => "\"\{s}\""
    Ident(name) => "\{name}"
    IdentWithTag(tag, ident) => "\{tag}::\{ident}"
    Unit => "()"
    Paren(expr) => "(\{expr})"
    Tuple(exprs) => {
      let items = exprs.map(fn(e) { e.to_string() }).join(", ")
      "(\{items})"
    }
    Array(exprs) => {
      let items = exprs.map(fn(e) { e.to_string() }).join(", ")
      "[\{items}]"
    }
    ArrayMake(size, init) => "Array::make(\{size}, \{init})"
    EnumConstruct(tag, variant, exprs) => {
      let tag_prefix = match tag {
        Some(t) => "\{t}::"
        None => ""
      }
      if exprs.is_empty() {
        "\{tag_prefix}\{variant}"
      } else {
        let items = exprs.map(fn(e) { e.to_string() }).join(", ")
        "\{tag_prefix}\{variant}(\{items})"
      }
    }
    StructConstruct(_) => {
      println("Unimplemented: AtomExprKind::Show for StructConstruct")
      panic()
    }
  }
  logger.write_string(s)
}

///|
fn AtomExpr::unit() -> AtomExpr {
  let kind = AtomExprKind::Unit
  AtomExpr::{ kind, toks: [], }
}

///|
/// Creates a `AtomExpr` parser AST node.
pub fn AtomExpr::new(
  kind : AtomExprKind,
  init_tokens : ArrayView[Token],
  rest_tokens : ArrayView[Token],
) -> AtomExpr {
  let len = rest_tokens.start_offset() - init_tokens.start_offset()
  let toks = init_tokens[0:len]
  AtomExpr::{ kind, toks, }
}

///|
/// Parses the `parse_atom_expr` syntax form and returns the unconsumed token suffix.
pub fn parse_atom_expr(
  tokens : ArrayView[Token],
) -> (AtomExpr, ArrayView[Token]) raise ParseError {
  let init_tokens = tokens
  match tokens {
    [{ kind: Int(v), .. }, .. tokens] => {
      let expr = AtomExpr::new(Int(v), init_tokens, tokens)
      (expr, tokens)
    }
    [{ kind: Int64(v), .. }, .. tokens] => {
      let expr = AtomExpr::new(Int64(v), init_tokens, tokens)
      (expr, tokens)
    }
    [{ kind: UInt(v), .. }, .. tokens] => {
      let expr = AtomExpr::new(UInt(v), init_tokens, tokens)
      (expr, tokens)
    }
    [{ kind: UInt64(v), .. }, .. tokens] => {
      let expr = AtomExpr::new(UInt64(v), init_tokens, tokens)
      (expr, tokens)
    }
    [{ kind: Double(v), .. }, .. tokens] => {
      let expr = AtomExpr::new(Double(v), init_tokens, tokens)
      (expr, tokens)
    }
    [{ kind: Float(v), .. }, .. tokens] => {
      let expr = AtomExpr::new(Float(v), init_tokens, tokens)
      (expr, tokens)
    }
    [{ kind: Char(c), .. }, .. tokens] => {
      let expr = AtomExpr::new(Char(c), init_tokens, tokens)
      (expr, tokens)
    }
    [{ kind: Bool(v), .. }, .. tokens] => {
      let expr = AtomExpr::new(Bool(v), init_tokens, tokens)
      (expr, tokens)
    }
    [{ kind: String(s), .. }, .. tokens] => {
      let expr = AtomExpr::new(String(s), init_tokens, tokens)
      (expr, tokens)
    }
    [{ kind: Lower(ident), .. }, .. tokens] => {
      let expr = AtomExpr::new(Ident(ident), init_tokens, tokens)
      (expr, tokens)
    }
    [{ kind: Upper("Array"), .. }, ..] as tokens =>
      parse_array_make_expr(tokens)
    [
      { kind: Upper(tag), .. },
      { kind: Symbol("::"), .. },
      { kind: Lower(ident), .. },
      .. tokens,
    ] => {
      let expr = AtomExpr::new(IdentWithTag(tag, ident), init_tokens, tokens)
      (expr, tokens)
    }
    [
      { kind: Upper(_), .. },
      { kind: Symbol("::"), .. },
      { kind: Bracket('{'), .. },
      ..,
    ] as tokens => parse_struct_construct(tokens)
    [{ kind: Upper(_), .. }, ..] as tokens => parse_enum_construct(tokens)
    [{ kind: Bracket('('), .. }, ..] as tokens => parse_paren_expr(tokens)
    [{ kind: Bracket('['), .. }, ..] as tokens => parse_array_expr(tokens)
    [] => {
      println("Compiler ICE: Empty Token ArrayView")
      panic()
    }
    [tok, ..] => {
      let msg = "Parse Error: InValid Atom Expression" +
        " Expect Int, Float, Char, Bool, String, Ident, '(', '[' or Struct Construct"
      @lexer.throw_(tok, msg, Error)
      raise ParseError("InValid Atom Expression")
    }
  }
}

///|
fn parse_paren_expr(
  tokens : ArrayView[Token],
) -> (AtomExpr, ArrayView[Token]) raise ParseError {
  let init_tokens = tokens
  guard tokens is [{ kind: Bracket('('), .. }, .. tokens] else {
    println("Compiler ICE: Misuse parse_paren_or_tuple_expr")
    panic()
  }
  let exprs : Array[Expr] = Array::Array(capacity=0)
  let tokens = for current = tokens {
    match current {
      [{ kind: Bracket(')'), .. }, .. rest] => break rest
      [{ kind: Symbol(","), .. }, { kind: Bracket(')'), .. }, .. rest] =>
        break rest
      [{ kind: Symbol(","), .. }, .. tokens] => {
        let (expr, rest) = parse_expr(tokens)
        exprs.push(expr)
        continue rest
      }
      [] => {
        println("Compiler ICE: Empty Token ArrayView")
        panic()
      }
      tokens => {
        let (expr, rest) = parse_expr(tokens)
        exprs.push(expr)
        continue rest
      }
    }
  }
  let kind = match exprs.length() {
    0 => AtomExprKind::Unit
    1 => AtomExprKind::Paren(exprs[0])
    _ => AtomExprKind::Tuple(exprs)
  }
  let atom_expr = AtomExpr::new(kind, init_tokens, tokens)
  (atom_expr, tokens)
}

///|
fn parse_array_make_expr(
  tokens : ArrayView[Token],
) -> (AtomExpr, ArrayView[Token]) raise ParseError {
  let init_tokens = tokens
  guard tokens
    is [
      { kind: Upper("Array"), .. },
      { kind: Symbol("::"), .. },
      { kind: Lower("make"), .. },
      { kind: Bracket('('), .. },
      .. tokens,
    ] else {
    println(
      "Compiler ICE: Misuse parse_array_make_expr, first token: \{tokens[0]}",
    )
    panic()
  }
  let (size_expr, tokens) = parse_expr(tokens)
  guard tokens is [{ kind: Symbol(","), .. }, .. tokens] else {
    @lexer.throw_(
      tokens[0],
      "Parse Error: Expected ',' after size expression in Array::make",
      Error,
    )
    raise ParseError("Expected ',' after size expression in Array::make")
  }
  let (init_expr, tokens) = parse_expr(tokens)
  guard tokens is [{ kind: Bracket(')'), .. }, .. tokens] else {
    @lexer.throw_(
      tokens[0],
      "Parse Error: Expected ')' after init expression in Array::make",
      Error,
    )
    raise ParseError("Expected ')' after init expression in Array::make")
  }
  let atom_expr = AtomExpr::new(
    AtomExprKind::ArrayMake(size_expr, init_expr),
    init_tokens,
    tokens,
  )
  (atom_expr, tokens)
}

///|
fn parse_array_expr(
  tokens : ArrayView[Token],
) -> (AtomExpr, ArrayView[Token]) raise ParseError {
  let init_tokens = tokens
  guard tokens is [{ kind: Bracket('['), .. }, .. tokens] else {
    println("Compiler ICE: Misuse parse_array_expr")
    panic()
  }
  let exprs : Array[Expr] = Array::Array(capacity=0)
  let tokens = for current = tokens {
    match current {
      [{ kind: Bracket(']'), .. }, .. rest] => break rest
      [{ kind: Symbol(","), .. }, { kind: Bracket(']'), .. }, .. rest] =>
        break rest
      [{ kind: Symbol(","), .. }, .. tokens] => {
        let (expr, rest) = parse_expr(tokens)
        exprs.push(expr)
        continue rest
      }
      [] => {
        println("Compiler ICE: Empty Token ArrayView")
        panic()
      }
      tokens => {
        let (expr, rest) = parse_expr(tokens)
        exprs.push(expr)
        continue rest
      }
    }
  }
  let atom_expr = AtomExpr::new(AtomExprKind::Array(exprs), init_tokens, tokens)
  (atom_expr, tokens)
}

///|
fn parse_enum_construct(
  tokens : ArrayView[Token],
) -> (AtomExpr, ArrayView[Token]) raise ParseError {
  let init_tokens = tokens
  guard tokens is [{ kind: Upper(name1), .. }, .. tokens] else {
    println("Compiler ICE: Misuse parse_enum_construct, expected enum name")
    panic()
  }
  let (tag, variant_name, tokens) = match tokens {
    [{ kind: Symbol("::"), .. }, { kind: Upper(variant), .. }, .. tokens] =>
      (Some(name1), variant, tokens)
    _ => (None, name1, tokens)
  }
  let exprs : Array[Expr] = Array::Array(capacity=0)
  guard tokens is [{ kind: Bracket('('), .. }, .. tokens] else {
    let kind = AtomExprKind::EnumConstruct(tag, variant_name, exprs)
    let atom_expr = AtomExpr::new(kind, tokens, tokens)
    return (atom_expr, tokens)
  }
  let tokens = for current = tokens {
    match current {
      [{ kind: Bracket(')'), .. }, .. rest] => break rest
      [{ kind: Symbol(","), .. }, { kind: Bracket(')'), .. }, .. rest] =>
        break rest
      [{ kind: Symbol(","), .. }, .. tokens] => {
        let (expr, rest) = parse_expr(tokens)
        exprs.push(expr)
        continue rest
      }
      [] => {
        println("Compiler ICE: Empty Token ArrayView")
        panic()
      }
      tokens => {
        let (expr, rest) = parse_expr(tokens)
        exprs.push(expr)
        continue rest
      }
    }
  }
  let kind = AtomExprKind::EnumConstruct(tag, variant_name, exprs)
  let atom_expr = AtomExpr::new(kind, init_tokens, tokens)
  (atom_expr, tokens)
}

///|
test "AtomExpr to_string Test" {
  let color = false
  let code =
    #|42 ; 100L ; 200U ; 300UL ; 3.14 ; 2.5F ; 'c' ; true ; false ; 
    #|"hello" ; x ; Point::x ; ()
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `42` (Int)
  let (atom_expr, rest) = parse_atom_expr(tokens)
  inspect(atom_expr.to_string(color~), content="int literal 42")

  // Skip semicolon and parse `100L` (Int64)
  let rest = skip_semicolon(rest)
  let (atom_expr, rest) = parse_atom_expr(rest)
  inspect(atom_expr.to_string(color~), content="int64 literal 100L")

  // Skip semicolon and parse `200U` (UInt)
  let rest = skip_semicolon(rest)
  let (atom_expr, rest) = parse_atom_expr(rest)
  inspect(atom_expr.to_string(color~), content="uint literal 200U")

  // Skip semicolon and parse `300UL` (UInt64)
  let rest = skip_semicolon(rest)
  let (atom_expr, rest) = parse_atom_expr(rest)
  inspect(atom_expr.to_string(color~), content="uint64 literal 300UL")

  // Skip semicolon and parse `3.14` (Double)
  let rest = skip_semicolon(rest)
  let (atom_expr, rest) = parse_atom_expr(rest)
  inspect(atom_expr.to_string(color~), content="double literal 3.14")

  // Skip semicolon and parse `2.5F` (Float)
  let rest = skip_semicolon(rest)
  let (atom_expr, rest) = parse_atom_expr(rest)
  inspect(atom_expr.to_string(color~), content="float literal 2.5F")

  // Skip semicolon and parse `'c'` (Char)
  let rest = skip_semicolon(rest)
  let (atom_expr, rest) = parse_atom_expr(rest)
  inspect(atom_expr.to_string(color~), content="char literal 'c'")

  // Skip semicolon and parse `true` (Bool)
  let rest = skip_semicolon(rest)
  let (atom_expr, rest) = parse_atom_expr(rest)
  inspect(atom_expr.to_string(color~), content="bool literal true")

  // Skip semicolon and parse `false` (Bool)
  let rest = skip_semicolon(rest)
  let (atom_expr, rest) = parse_atom_expr(rest)
  inspect(atom_expr.to_string(color~), content="bool literal false")

  // Skip semicolon and parse `"hello"` (String)
  let rest = skip_semicolon(rest)
  let (atom_expr, rest) = parse_atom_expr(rest)
  inspect(atom_expr.to_string(color~), content="string literal \"hello\"")

  // Skip semicolon and parse `x` (Ident)
  let rest = skip_semicolon(rest)
  let (atom_expr, rest) = parse_atom_expr(rest)
  inspect(atom_expr.to_string(color~), content="variable x")

  // Skip semicolon and parse `Point::x` (IdentWithTag)
  let rest = skip_semicolon(rest)
  let (atom_expr, rest) = parse_atom_expr(rest)
  inspect(atom_expr.to_string(color~), content="tagged variable Point::x")

  // Skip semicolon and parse `()` (Unit)
  let rest = skip_semicolon(rest)
  let (atom_expr, _) = parse_atom_expr(rest)
  inspect(atom_expr.to_string(color~), content="unit ()")
}

///|
test "AtomExpr Array and Tuple Test" {
  let color = false
  let code =
    #|[1, 2, 3] ; (10, 20) ; Array::make(5, 0)
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `[1, 2, 3]` (Array)
  let (atom_expr, rest) = parse_atom_expr(tokens)
  inspect(
    atom_expr.to_string(color~),
    content=(
      #|array
      #|├-int literal 1
      #|├-int literal 2
      #|└-int literal 3
    ),
  )

  // Skip semicolon and parse `(10, 20)` (Tuple)
  let rest = skip_semicolon(rest)
  let (atom_expr, rest) = parse_atom_expr(rest)
  inspect(
    atom_expr.to_string(color~),
    content=(
      #|tuple
      #|├-int literal 10
      #|└-int literal 20
    ),
  )

  // Skip semicolon and parse `Array::make(5, 0)` (ArrayMake)
  let rest = skip_semicolon(rest)
  let (atom_expr, _) = parse_atom_expr(rest)
  inspect(
    atom_expr.to_string(color~),
    content=(
      #|array make
      #|├-size: int literal 5
      #|└-init: int literal 0
    ),
  )
}

///|
test "AtomExpr Enum Test" {
  let color = false
  let code =
    #|None ; Some(42) ; Option::Some(x)
  let tokens = @lexer.tokenize(code, source_file="test")

  // Test enum construct without tag and without args
  let (atom_expr, rest) = parse_atom_expr(tokens)
  inspect(atom_expr.to_string(color~), content="enum construct None")

  // Skip semicolon and parse `Some(42)` (EnumConstruct with arg)
  let rest = skip_semicolon(rest)
  let (atom_expr, rest) = parse_atom_expr(rest)
  inspect(
    atom_expr.to_string(color~),
    content=(
      #|enum construct Some
      #|└-int literal 42
    ),
  )

  // Skip semicolon and parse `Option::Some(x)` (EnumConstruct with tag)
  let rest = skip_semicolon(rest)
  let (atom_expr, _) = parse_atom_expr(rest)
  inspect(
    atom_expr.to_string(color~),
    content=(
      #|enum construct Option::Some
      #|└-variable x
    ),
  )
}

///|
test "AtomExpr Nested Test" {
  let color = false
  let code =
    #|[(1, 2), (3, 4)] ; (x, [a, b]) ; Array::make(n, (0, 0))
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `[(1, 2), (3, 4)]` (Array of tuples)
  let (atom_expr, rest) = parse_atom_expr(tokens)
  inspect(
    atom_expr.to_string(color~),
    content=(
      #|array
      #|├-tuple
      #|│ ├-int literal 1
      #|│ └-int literal 2
      #|└-tuple
      #|  ├-int literal 3
      #|  └-int literal 4
    ),
  )

  // Skip semicolon and parse `(x, [a, b])` (Tuple with array)
  let rest = skip_semicolon(rest)
  let (atom_expr, rest) = parse_atom_expr(rest)
  inspect(
    atom_expr.to_string(color~),
    content=(
      #|tuple
      #|├-variable x
      #|└-array
      #|  ├-variable a
      #|  └-variable b
    ),
  )

  // Skip semicolon and parse `Array::make(n, (0, 0))` (ArrayMake with tuple)
  let rest = skip_semicolon(rest)
  let (atom_expr, _) = parse_atom_expr(rest)
  inspect(
    atom_expr.to_string(color~),
    content=(
      #|array make
      #|├-size: variable n
      #|└-init: tuple
      #|        ├-int literal 0
      #|        └-int literal 0
    ),
  )
}
