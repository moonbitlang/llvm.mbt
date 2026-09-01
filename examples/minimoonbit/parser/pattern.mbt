///|
/// Represents the MiniMoonBit parser AST node `Pattern`.
pub(all) struct Pattern {
  /// Stores the `kind` component of this parser AST node.
  kind : PatternKind
} derive(Eq)

///|
/// Formats `Pattern` using MiniMoonBit source notation.
pub impl Show for Pattern with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `Pattern` value with optional ANSI coloring.
pub fn Pattern::to_string(self : Self, color? : Bool = true) -> String {
  match self.kind {
    Wildcard => {
      let text = "_"
      if color {
        @color.taint(text, Magenta)
      } else {
        text
      }
    }
    Boolean(v) => {
      let prefix = "bool pattern"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      let v = if v { "true" } else { "false" }
      "\{prefix} \{v}"
    }
    Integer(v) => {
      let prefix = "int pattern"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      "\{prefix} \{v}"
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
          let pat_str = patterns[i].to_string(color~)
          let lines = pat_str.split("\n").map(sv => sv.to_owned()).to_array()
          let is_last = i == patterns.length() - 1
          let formatted = if is_last {
            format_lines(lines, head_with="└-", continue_with="  ")
          } else {
            format_lines(lines, head_with="├-", continue_with="│ ")
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
      let tag_prefix = match tag {
        Some(t) => "\{t}::"
        None => ""
      }
      let prefix = "enum pattern"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      if patterns.is_empty() {
        "\{prefix} \{tag_prefix}\{variant}"
      } else {
        let mut result = "\{prefix} \{tag_prefix}\{variant}\n"
        for i = 0; i < patterns.length(); i = i + 1 {
          let pat_str = patterns[i].to_string(color~)
          let lines = pat_str.split("\n").map(sv => sv.to_owned()).to_array()
          let is_last = i == patterns.length() - 1
          let formatted = if is_last {
            format_lines(lines, head_with="└-", continue_with="  ")
          } else {
            format_lines(lines, head_with="├-", continue_with="│ ")
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
/// Enumerates the parser AST forms represented by `PatternKind`.
pub(all) enum PatternKind {
  /// Represents the `Wildcard` parser AST form.
  Wildcard
  /// Represents the `Boolean` parser AST form.
  Boolean(Bool)
  /// Represents the `Integer` parser AST form.
  Integer(Int)
  /// Represents the `Ident` parser AST form.
  Ident(String)
  /// Represents the `Tuple` parser AST form.
  Tuple(Array[Pattern])
  /// Represents the `EnumVariant` parser AST form.
  EnumVariant(String?, String, Array[Pattern])
} derive(Eq)

///|
/// Formats `PatternKind` using MiniMoonBit source notation.
pub impl Show for PatternKind with fn output(self, logger) {
  let s = match self {
    Wildcard => "_"
    Boolean(v) => "\{v}"
    Integer(v) => "\{v}"
    Ident(name) => "\{name}"
    Tuple(patterns) => {
      let items = patterns.map(fn(p) { p.to_string() }).join(", ")
      "(\{items})"
    }
    EnumVariant(tag, variant, patterns) => {
      let tag_prefix = match tag {
        Some(t) => "\{t}::"
        None => ""
      }
      if patterns.is_empty() {
        "\{tag_prefix}\{variant}"
      } else {
        let items = patterns.map(fn(p) { p.to_string() }).join(", ")
        "\{tag_prefix}\{variant}(\{items})"
      }
    }
  }
  logger.write_string(s)
}

///|
/// Parses the `parse_pattern` syntax form and returns the unconsumed token suffix.
pub fn parse_pattern(
  tokens : ArrayView[Token],
) -> (Pattern, ArrayView[Token]) raise ParseError {
  match tokens {
    [{ kind: Wildcard, .. }, .. tokens] => {
      let pattern = Pattern::{ kind: Wildcard, }
      (pattern, tokens)
    }
    [{ kind: Lower(ident), .. }, .. tokens] => {
      let pattern = Pattern::{ kind: Ident(ident), }
      (pattern, tokens)
    }
    [{ kind: BinaryOp(Sub), .. }, { kind: Int(v), .. }, .. tokens] => {
      let pattern = Pattern::{ kind: Integer(-v), }
      (pattern, tokens)
    }
    [{ kind: Int(v), .. }, .. tokens] => {
      let pattern = Pattern::{ kind: Integer(v), }
      (pattern, tokens)
    }
    [{ kind: Bool(v), .. }, .. tokens] => {
      let pattern = Pattern::{ kind: Boolean(v), }
      (pattern, tokens)
    }
    [{ kind: Upper(name1), .. }, .. tokens] => {
      let (tag, enum_name, tokens) = if tokens
        is [{ kind: Symbol("::"), .. }, .. tokens] {
        guard tokens is [{ kind: Upper(name2), .. }, .. tokens] else {
          @lexer.throw_(tokens[0], "Parse Error: InValid Pattern", Error)
          raise ParseError("InValid Pattern")
        }
        (Some(name1), name2, tokens)
      } else {
        (None, name1, tokens)
      }
      let patterns : Array[Pattern] = Array::new()
      guard tokens is [{ kind: Bracket('('), .. } as tok, .. tokens] else {
        let patternkind = EnumVariant(tag, enum_name, patterns)
        let pattern = Pattern::{ kind: patternkind, }
        return (pattern, tokens)
      }
      let tokens = for current = tokens {
        match current {
          [{ kind: Bracket(')'), .. }, .. tokens] => break tokens
          [
            {
              kind: Int(_)
              | BinaryOp(Sub)
              | Lower(_)
              | Wildcard
              | Bracket('(')
              | Upper(_)
              | Bool(_),
              ..
            },
            ..,
          ] as tokens => {
            let (pat, rest) = parse_pattern(tokens)
            patterns.push(pat)
            continue rest
          }
          [
            { kind: Symbol(","), .. },
            {
              kind: Int(_)
              | BinaryOp(Sub)
              | Lower(_)
              | Wildcard
              | Bracket('(')
              | Bracket(')')
              | Upper(_)
              | Bool(_),
              ..
            },
            ..,
          ] as tokens => continue tokens[1:]
          [] => {
            println(
              "Compiler ICE: Failed Parsing Pattern Empty Token ArrayView",
            )
            panic()
          }
          tokens => raise ParseError("InValid Pattern: \{tokens[0]}")
        }
      }
      let kind = if patterns.length() == 0 {
        @lexer.throw_(tok, "Parse Error: InValid Pattern", Error)
        raise ParseError("InValid Pattern")
      } else {
        PatternKind::EnumVariant(tag, enum_name, patterns)
      }
      let pattern = Pattern::{ kind, }
      (pattern, tokens)
    }
    [{ kind: Bracket('('), .. } as tok, .. tokens] => {
      let patterns : Array[Pattern] = Array::new()
      let tokens = for current = tokens {
        match current {
          [{ kind: Bracket(')'), .. }, .. tokens] => break tokens
          [
            {
              kind: Lower(_)
              | Wildcard
              | Bracket('(')
              | Upper(_)
              | Int(_)
              | BinaryOp(Sub)
              | Bool(_),
              ..
            },
            ..,
          ] as tokens => {
            let (pat, rest) = parse_pattern(tokens)
            patterns.push(pat)
            continue rest
          }
          [
            { kind: Symbol(","), .. },
            {
              kind: Lower(_)
              | Wildcard
              | Bracket('(')
              | Bracket(')')
              | Upper(_)
              | Int(_)
              | BinaryOp(Sub)
              | Bool(_),
              ..
            },
            ..,
          ] as tokens => continue tokens[1:]
          [] => {
            println(
              "Compiler ICE: Failed Parsing Pattern Empty Token ArrayView",
            )
            panic()
          }
          tokens => raise ParseError("InValid Pattern: \{tokens[0]}")
        }
      }
      let kind = if patterns.length() == 0 {
        @lexer.throw_(tok, "Parse Error: InValid Pattern", Error)
        raise ParseError("InValid Pattern")
      } else if patterns.length() == 1 {
        @lexer.throw_(
          tok,
          "Warning: Should Not use tuple pattern for single pattern",
          Warning,
        )
        patterns[0].kind
      } else {
        PatternKind::Tuple(patterns)
      }
      let pattern = Pattern::{ kind, }
      (pattern, tokens)
    }
    [] => {
      println("Compiler ICE: Empty Token ArrayView")
      panic()
    }
    [tok, ..] => {
      @lexer.throw_(tok, "Parse Error: InValid Pattern", Error)
      raise ParseError("InValid Pattern")
    }
  }
}

///|
test "Pattern to_string Test - Basic" {
  let color = false
  let code =
    #|_ ; x ; 42 ; (a, b)
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `_` (Wildcard)
  let (pattern, rest) = parse_pattern(tokens)
  inspect(pattern.to_string(color~), content="_")

  // Skip semicolon and parse `x` (Ident)
  let rest = skip_semicolon(rest)
  let (pattern, rest) = parse_pattern(rest)
  inspect(pattern.to_string(color~), content="ident pattern x")

  // Skip semicolon and parse `42` (Integer)
  let rest = skip_semicolon(rest)
  let (pattern, rest) = parse_pattern(rest)
  inspect(pattern.to_string(color~), content="int pattern 42")

  // Skip semicolon and parse `(a, b)` (Tuple)
  let rest = skip_semicolon(rest)
  let (pattern, _) = parse_pattern(rest)
  inspect(
    pattern.to_string(color~),
    content=(
      #|tuple pattern
      #|├-ident pattern a
      #|└-ident pattern b
    ),
  )
}

///|
test "Pattern to_string Test - Enum" {
  let color = false
  let code =
    #|None ; Some(x) ; Option::Some(42) ; Result::Ok((a, b))
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `None` (EnumVariant without args)
  let (pattern, rest) = parse_pattern(tokens)
  inspect(pattern.to_string(color~), content="enum pattern None")

  // Skip semicolon and parse `Some(x)` (EnumVariant with one arg)
  let rest = skip_semicolon(rest)
  let (pattern, rest) = parse_pattern(rest)
  inspect(
    pattern.to_string(color~),
    content=(
      #|enum pattern Some
      #|└-ident pattern x
    ),
  )

  // Skip semicolon and parse `Option::Some(42)` (EnumVariant with tag)
  let rest = skip_semicolon(rest)
  let (pattern, rest) = parse_pattern(rest)
  inspect(
    pattern.to_string(color~),
    content=(
      #|enum pattern Option::Some
      #|└-int pattern 42
    ),
  )

  // Skip semicolon and parse `Result::Ok((a, b))` (EnumVariant with nested tuple)
  let rest = skip_semicolon(rest)
  let (pattern, _) = parse_pattern(rest)
  inspect(
    pattern.to_string(color~),
    content=(
      #|enum pattern Result::Ok
      #|└-tuple pattern
      #|  ├-ident pattern a
      #|  └-ident pattern b
    ),
  )
}

///|
test "Pattern to_string Test - Nested" {
  let color = false
  let code =
    #|(x, (y, z)) ; Some((a, b))
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse `(x, (y, z))` (Nested tuple)
  let (pattern, rest) = parse_pattern(tokens)
  inspect(
    pattern.to_string(color~),
    content=(
      #|tuple pattern
      #|├-ident pattern x
      #|└-tuple pattern
      #|  ├-ident pattern y
      #|  └-ident pattern z
    ),
  )

  // Skip semicolon and parse `Some((a, b))` (EnumVariant with tuple)
  let rest = skip_semicolon(rest)
  let (pattern, _) = parse_pattern(rest)
  inspect(
    pattern.to_string(color~),
    content=(
      #|enum pattern Some
      #|└-tuple pattern
      #|  ├-ident pattern a
      #|  └-ident pattern b
    ),
  )
}
