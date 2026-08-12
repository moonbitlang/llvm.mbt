///|
/// Represents the MiniMoonBit parser AST node `ApplyExpr`.
pub(all) struct ApplyExpr {
  /// Stores the `kind` component of this parser AST node.
  kind : ApplyExprKind
  /// Stores the `toks` component of this parser AST node.
  toks : ArrayView[Token]
} derive(Eq)

///|
/// Formats `ApplyExpr` using MiniMoonBit source notation.
pub impl Show for ApplyExpr with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `ApplyExpr` value with optional ANSI coloring.
pub fn ApplyExpr::to_string(self : Self, color? : Bool = true) -> String {
  match self.kind {
    AtomExpr(atom_expr) => atom_expr.to_string(color~)
    ArrayAccess(apply_expr, index_expr) => {
      let prefix = "array access"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }

      // Format apply_expr as first child
      let apply_str = apply_expr.to_string(color~)
      let apply_lines = apply_str
        .split("\n")
        .map(fn(sv) { sv.to_string() })
        .to_array()
      let apply_formatted = format_lines(
        apply_lines,
        head_with="├-",
        continue_with="│ ",
      )

      // Format index_expr as second child
      let index_str = index_expr.to_string(color~)
      let index_lines = index_str
        .split("\n")
        .map(fn(sv) { sv.to_string() })
        .to_array()
      let index_formatted = format_lines(
        index_lines,
        head_with="└-",
        continue_with="  ",
      )
      "\{prefix}\n\{apply_formatted}\n\{index_formatted}"
    }
    FieldAccess(apply_expr, field) => {
      let prefix = "field access"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      let inner_str = apply_expr.to_string(color~)
      let lines = inner_str
        .split("\n")
        .map(fn(sv) { sv.to_string() })
        .to_array()
      let formatted = format_lines(lines)
      "\{prefix} .\{field}\n\{formatted}"
    }
    Call(apply_expr, args) => {
      let prefix = "function call"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }

      // Format apply_expr as first child
      let apply_str = apply_expr.to_string(color~)
      let apply_lines = apply_str
        .split("\n")
        .map(fn(sv) { sv.to_string() })
        .to_array()
      let apply_formatted = if args.length() > 0 {
        format_lines(apply_lines, head_with="├-", continue_with="│ ")
      } else {
        format_lines(apply_lines, head_with="└-", continue_with="  ")
      }

      // Format arguments
      let mut result = "\{prefix}\n\{apply_formatted}"
      for i = 0; i < args.length(); i = i + 1 {
        let arg = args[i]
        let arg_str = arg.to_string(color~)
        let arg_lines = arg_str
          .split("\n")
          .map(fn(sv) { sv.to_string() })
          .to_array()
        let is_last = i == args.length() - 1
        let arg_formatted = if is_last {
          format_lines(arg_lines, head_with="└-", continue_with="  ")
        } else {
          format_lines(arg_lines, head_with="├-", continue_with="│ ")
        }
        result = "\{result}\n\{arg_formatted}"
      }
      result
    }
  }
}

///|
/// Enumerates the parser AST forms represented by `ApplyExprKind`.
pub(all) enum ApplyExprKind {
  /// Represents the `AtomExpr` parser AST form.
  AtomExpr(AtomExpr)
  /// Represents the `ArrayAccess` parser AST form.
  ArrayAccess(ApplyExpr, Expr)
  /// Represents the `FieldAccess` parser AST form.
  FieldAccess(ApplyExpr, String)
  /// Represents the `Call` parser AST form.
  Call(ApplyExpr, Array[Expr])
} derive(Eq)

///|
/// Formats `ApplyExprKind` using MiniMoonBit source notation.
pub impl Show for ApplyExprKind with fn output(self, logger) {
  let s = match self {
    AtomExpr(atom_expr) => atom_expr.to_string()
    ArrayAccess(apply_expr, index_expr) => {
      let apply_str = apply_expr.to_string()
      let index_str = index_expr.to_string()
      "\{apply_str}[\{index_str}]"
    }
    FieldAccess(apply_expr, field) => {
      let inner_str = apply_expr.to_string()
      "\{inner_str}.\{field}"
    }
    Call(apply_expr, args) => {
      let inner_str = apply_expr.to_string()
      let args_str = args.map(fn(arg) { arg.to_string() }).join(", ")
      "\{inner_str}(\{args_str})"
    }
  }
  logger.write_string(s)
}

///|
fn ApplyExpr::unit() -> ApplyExpr {
  let atom_unit = AtomExpr::unit()
  ApplyExpr::{ kind: AtomExpr(atom_unit), toks: atom_unit.toks }
}

///|
/// Creates a `ApplyExpr` parser AST node.
pub fn ApplyExpr::new(
  kind : ApplyExprKind,
  init_tokens : ArrayView[Token],
  rest_tokens : ArrayView[Token],
) -> ApplyExpr {
  let len = rest_tokens.start_offset() - init_tokens.start_offset()
  let toks = init_tokens[0:len]
  ApplyExpr::{ kind, toks }
}

///|
/// Parses the `parse_apply_expr` syntax form and returns the unconsumed token suffix.
pub fn parse_apply_expr(
  tokens : ArrayView[Token],
) -> (ApplyExpr, ArrayView[Token]) raise ParseError {
  let init_tokens = tokens
  let (atom_expr, tokens) = parse_atom_expr(tokens)
  let apply_expr = ApplyExpr::new(AtomExpr(atom_expr), init_tokens, tokens)
  if !(tokens is [{ kind: Bracket('[') | Symbol(".") | Bracket('('), .. }, ..]) {
    return (apply_expr, tokens)
  }
  let mut last_apply_line = atom_expr.toks[atom_expr.toks.length() - 1].line
  let mut apply_expr = apply_expr
  loop tokens {
    [{ kind: Bracket('['), line, .. }, .. tokens] if line == last_apply_line => {
      let (index_expr, tokens) = parse_expr(tokens)
      guard tokens is [{ kind: Bracket(']'), .. }, .. tokens] else {
        @lexer.throw_(tokens[0], "ParseError: Expect ']'", Error)
        raise ParseError("Expect ']'")
      }
      apply_expr = ApplyExpr::new(
        ArrayAccess(apply_expr, index_expr),
        init_tokens,
        tokens,
      )
      last_apply_line = tokens[0].line
      continue tokens
    }
    [{ kind: Symbol("."), line, .. }, { kind: Lower(field), .. }, .. tokens] if line ==
      last_apply_line => {
      apply_expr = ApplyExpr::new(
        FieldAccess(apply_expr, field),
        init_tokens,
        tokens,
      )
      last_apply_line = tokens[0].line
      continue tokens
    }
    [{ kind: Bracket('('), line, .. }, .. tokens] if line == last_apply_line => {
      let (args, tokens) = parse_expr_list(tokens)
      guard tokens is [{ kind: Bracket(')'), .. }, .. tokens] else {
        @lexer.throw_(tokens[0], "ParseError: Expect ')'", Error)
        raise ParseError("Expect ')'")
      }
      apply_expr = ApplyExpr::new(Call(apply_expr, args), init_tokens, tokens)
      continue tokens
    }
    tokens => break (apply_expr, tokens)
  }
}

///|
test "ApplyExpr to_string Test" {
  let color = false
  let code =
    #|42 ; x ; point.x ; arr[0] ; func(10) ; 
    #|point.x.y ; arr[0][1] ; point.field.x
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `42` (AtomExpr - Int)
  let (apply_expr, rest) = parse_apply_expr(tokens)
  inspect(apply_expr.to_string(color~), content="int literal 42")

  // Skip semicolon and parse `x` (AtomExpr - Ident)
  let rest = skip_semicolon(rest)
  let (apply_expr, rest) = parse_apply_expr(rest)
  inspect(apply_expr.to_string(color~), content="variable x")

  // Skip semicolon and parse `point.x` (FieldAccess)
  let rest = skip_semicolon(rest)
  let (apply_expr, rest) = parse_apply_expr(rest)
  let output = apply_expr.to_string(color~)
  inspect(
    output,
    content=(
      #|field access .x
      #|└-variable point
    ),
  )

  // Skip semicolon and parse `arr[0]` (ArrayAccess)
  let rest = skip_semicolon(rest)
  let (apply_expr, rest) = parse_apply_expr(rest)
  let output = apply_expr.to_string(color~)
  inspect(
    output,
    content=(
      #|array access
      #|├-variable arr
      #|└-int literal 0
    ),
  )

  // Skip semicolon and parse `func(10)` (Call)
  let rest = skip_semicolon(rest)
  let (apply_expr, _) = parse_apply_expr(rest)
  let output = apply_expr.to_string(color~)
  inspect(
    output,
    content=(
      #|function call
      #|├-variable func
      #|└-int literal 10
    ),
  )
}

///|
test "ApplyExpr Nested Test" {
  let color = false
  let code =
    #|point.x.y ; arr[0][1] ; point.field.data
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `point.x.y` (Nested FieldAccess)
  let (apply_expr, rest) = parse_apply_expr(tokens)
  let output = apply_expr.to_string(color~)
  inspect(
    output,
    content=(
      #|field access .y
      #|└-field access .x
      #|  └-variable point
    ),
  )

  // Skip semicolon and parse `arr[0][1]` (Nested ArrayAccess)
  let rest = skip_semicolon(rest)
  let (apply_expr, rest) = parse_apply_expr(rest)
  let output = apply_expr.to_string(color~)
  inspect(
    output,
    content=(
      #|array access
      #|├-array access
      #|│ ├-variable arr
      #|│ └-int literal 0
      #|└-int literal 1
    ),
  )

  // Skip semicolon and parse `point.field.data` (Multiple FieldAccess)
  let rest = skip_semicolon(rest)
  let (apply_expr, _) = parse_apply_expr(rest)
  let output = apply_expr.to_string(color~)
  inspect(
    output,
    content=(
      #|field access .data
      #|└-field access .field
      #|  └-variable point
    ),
  )
}

///|
test "ApplyExpr Complex Test" {
  let color = false

  // Test function call with multiple arguments
  let code =
    #|add(1, 2, 3)
  let tokens = @lexer.tokenize(code, source_file="test")
  let (apply_expr, _) = parse_apply_expr(tokens)
  let output = apply_expr.to_string(color~)
  inspect(
    output,
    content=(
      #|function call
      #|├-variable add
      #|├-int literal 1
      #|├-int literal 2
      #|└-int literal 3
    ),
  )

  // Test array access with complex index expression
  let code =
    #|arr[x + 1]
  let tokens = @lexer.tokenize(code, source_file="test")
  let (apply_expr, _) = parse_apply_expr(tokens)
  let output = apply_expr.to_string(color~)
  inspect(
    output,
    content=(
      #|array access
      #|├-variable arr
      #|└-binary expr: +
      #|  ├-variable x
      #|  └-int literal 1
    ),
  )

  // Test function call with no arguments
  let code =
    #|func()
  let tokens = @lexer.tokenize(code, source_file="test")
  let (apply_expr, _) = parse_apply_expr(tokens)
  let output = apply_expr.to_string(color~)
  inspect(
    output,
    content=(
      #|function call
      #|└-variable func
    ),
  )
}
