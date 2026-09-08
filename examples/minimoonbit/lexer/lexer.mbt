///|
/// Reports that MiniMoonBit source cannot be tokenized.
pub suberror TokenizeError {
  /// Carries a diagnostic describing malformed source text.
  TokenizeError(String)
} derive(Debug)

///|
/// Identifies a reserved word in the MiniMoonBit language.
pub(all) enum Keyword {
  /// Introduces a function declaration.
  Fn
  /// Introduces a structure definition.
  Struct
  /// Introduces an immutable binding.
  Let
  /// Marks a binding as mutable.
  Mut
  /// Introduces a conditional expression.
  If
  /// Introduces the alternative branch of a conditional.
  Else
  /// Introduces a while loop.
  While
  /// Introduces a for loop.
  For
  /// Returns a value from a function.
  Return
  /// Declares an externally provided function.
  Extern
  /// Introduces an enumeration definition.
  Enum
  /// Introduces a pattern match.
  Match
} derive(Debug, Eq)

///|
/// Formats a keyword using its constructor name.
pub impl Show for Keyword with fn output(self, logger) {
  logger.write_string(repr(self))
}

///|
/// Identifies a binary operator recognized by the lexer.
pub(all) enum BinaryOp {
  /// Adds two operands.
  Add // +
  /// Subtracts the right operand from the left operand.
  Sub // -
  /// Multiplies two operands.
  Mul // *
  /// Divides the left operand by the right operand.
  Div // /
  /// Computes the remainder of division.
  Mod // %
  /// Shifts an integer left.
  ShiftLeft // <<
  /// Shifts an integer right.
  ShiftRight // >>
  /// Compares two values for equality.
  Eq // ==
  /// Compares two values for inequality.
  NE // !=
  /// Tests whether the left value is less than the right value.
  LT // <
  /// Tests whether the left value is greater than the right value.
  GT // >
  /// Tests whether the left value is at most the right value.
  LE // <=
  /// Tests whether the left value is at least the right value.
  GE // >=
  /// Computes short-circuit logical conjunction.
  And // &&
  /// Computes short-circuit logical disjunction.
  Or // ||
  /// Computes bitwise conjunction.
  BitAnd // &
  /// Computes bitwise disjunction.
  BitOr // |
} derive(Debug, Eq)

///|
/// Formats a binary operator using its source spelling.
pub impl Show for BinaryOp with fn output(self, logger) {
  let s = match self {
    Add => "+"
    Sub => "-"
    Mul => "*"
    Div => "/"
    Mod => "%"
    ShiftLeft => "<<"
    ShiftRight => ">>"
    Eq => "=="
    NE => "!="
    LT => "<"
    GT => ">"
    LE => "<="
    GE => ">="
    And => "&&"
    Or => "||"
    BitAnd => "&"
    BitOr => "|"
  }
  logger.write_string(s)
}

///|
/// Identifies an assignment operator recognized by the lexer.
pub(all) enum AssignOp {
  /// Replaces the left value with the right value.
  Assign // =
  /// Adds and assigns the right value.
  PlusAssign // +=
  /// Subtracts and assigns the right value.
  MinusAssign // -=
  /// Multiplies and assigns the right value.
  MultAssign // *=
  /// Divides and assigns the right value.
  DivAssign // /=
  /// Computes a remainder and assigns it.
  ModAssign // %=
} derive(Debug, Eq, ToJson)

///|
/// Formats an assignment operator using its constructor name.
pub impl Show for AssignOp with fn output(self, logger) {
  logger.write_string(repr(self))
}

///|
/// Stores a token together with its source location and source buffer.
pub struct Token {
  kind : TokenKind
  line : Int
  col : Int
  idx : Int
  code : String
  file : String
} derive(Eq)

///|
/// Formats a token as its token kind.
pub impl Show for Token with fn output(self, logger) {
  logger.write_string(repr(self.kind))
}

///|
/// Creates a token at a particular source location.
pub fn Token::new(
  kind : TokenKind,
  line : Int,
  col : Int,
  idx : Int,
  code : String,
  file : String,
) -> Token {
  Token::{ kind, line, col, idx, code, file, }
}

///|
/// Describes the lexical value and category of a MiniMoonBit token.
pub(all) enum TokenKind {
  /// Stores a Boolean literal.
  Bool(Bool) // true, false
  /// Stores a machine-sized signed integer literal.
  Int(Int) // 1, 42, -100
  /// Stores a 64-bit signed integer literal.
  Int64(Int64) // 1L, 42L
  /// Stores a machine-sized unsigned integer literal.
  UInt(UInt) // 1U, 42U
  /// Stores a 64-bit unsigned integer literal.
  UInt64(UInt64) // 1UL, 42UL
  /// Stores a double-precision literal.
  Double(Double)
  /// Stores a single-precision source literal as a MoonBit `Double`.
  Float(Double) // 1.0F, 3.14F (stored as Double internally)
  /// Stores a character literal.
  Char(Char) // 'a', '\n'
  /// Stores a string literal.
  String(String) // "hello", "world"
  /// Stores a reserved language keyword.
  Keyword(Keyword)
  /// Stores an identifier beginning with an uppercase character.
  Upper(String)
  /// Stores an identifier beginning with a lowercase character.
  Lower(String)
  /// Stores a binary operator.
  BinaryOp(BinaryOp) // +, -, *, /, %, =, ==, !=, <, >, <=, >=, &&, ||
  /// Stores an assignment operator.
  AssignOp(AssignOp) // =, +=, -=, *=, /=, %=
  /// Represents logical negation.
  Not // !
  /// Stores a bracket delimiter.
  Bracket(Char) // (, ), [, ], {, }
  /// Stores punctuation or a multi-character symbol.
  Symbol(String) // . , ; : :: -> => 
  /// Represents the wildcard spelling `_`.
  Wildcard // _
  /// Marks the end of the source buffer.
  EOF
} derive(Debug, Eq)

///|
/// Formats a token kind using its constructor-oriented debug notation.
pub impl Show for TokenKind with fn output(self, logger) {
  logger.write_string(repr(self))
}

///|
/// Tokenizes a complete MiniMoonBit source buffer and appends an EOF token.
///
/// **Errors:**
///
/// - `TokenizeError` when a literal or source character is malformed.
pub fn tokenize(
  code : String,
  source_file? : String = "demo",
) -> Array[Token] raise TokenizeError {
  let source_code = code
  let tokens = Array::Array(capacity=0)
  let mut line = 1
  let mut col = 1
  let mut idx = 0
  for current = code[:] {
    match current {
      [] => {
        let tok = Token::new(EOF, line, col, idx, source_code, source_file)
        tokens.push(tok)
        break
      }
      [' ' | '\t' | '\r', .. rest] => {
        col += 1
        idx += 1
        continue rest
      }
      ['\n', .. rest] => {
        line += 1
        col = 1
        idx += 1
        continue rest
      }
      [.. "//", .. rest] => {
        let rest = for current = rest {
          match current {
            ['\n', .. rest_str] => {
              line += 1
              col = 1
              idx += 1
              break rest_str
            }
            [_, .. rest_str] => continue rest_str
            [] as rest_str => break rest_str
          }
        }
        continue rest
      }
      [.. "::", .. rest] => {
        let tok = Token::new(
          Symbol("::"),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 2
        idx += 2
        continue rest
      }
      [.. "->", .. rest] => {
        let tok = Token::new(
          Symbol("->"),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 2
        idx += 2
        continue rest
      }
      [.. "=>", .. rest] => {
        let tok = Token::new(
          Symbol("=>"),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 2
        idx += 2
        continue rest
      }
      [.. "!=", .. rest] => {
        let tok = Token::new(
          BinaryOp(NE),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 2
        idx += 2
        continue rest
      }
      [.. "==", .. rest] => {
        let tok = Token::new(
          BinaryOp(Eq),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 2
        idx += 2
        continue rest
      }
      [.. "<=", .. rest] => {
        let tok = Token::new(
          BinaryOp(LE),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 2
        idx += 2
        continue rest
      }
      [.. ">=", .. rest] => {
        let tok = Token::new(
          BinaryOp(GE),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 2
        idx += 2
        continue rest
      }
      [.. "&&", .. rest] => {
        let tok = Token::new(
          BinaryOp(And),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 2
        idx += 2
        continue rest
      }
      [.. "||", .. rest] => {
        let tok = Token::new(
          BinaryOp(Or),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 2
        idx += 2
        continue rest
      }
      [.. "<<", .. rest] => {
        let tok = Token::new(
          BinaryOp(ShiftLeft),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 2
        idx += 2
        continue rest
      }
      [.. ">>", .. rest] => {
        let tok = Token::new(
          BinaryOp(ShiftRight),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 2
        idx += 2
        continue rest
      }
      [.. "+=", .. rest] => {
        let tok = Token::new(
          AssignOp(PlusAssign),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 2
        idx += 2
        continue rest
      }
      [.. "-=", .. rest] => {
        let tok = Token::new(
          AssignOp(MinusAssign),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 2
        idx += 2
        continue rest
      }
      [.. "*=", .. rest] => {
        let tok = Token::new(
          AssignOp(MultAssign),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 2
        idx += 2
        continue rest
      }
      [.. "/=", .. rest] => {
        let tok = Token::new(
          AssignOp(DivAssign),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 2
        idx += 2
        continue rest
      }
      [.. "%=", .. rest] => {
        let tok = Token::new(
          AssignOp(ModAssign),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 2
        idx += 2
        continue rest
      }
      ['+', .. rest] => {
        let tok = Token::new(
          BinaryOp(Add),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      ['-', .. rest] => {
        let tok = Token::new(
          BinaryOp(Sub),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      ['*', .. rest] => {
        let tok = Token::new(
          BinaryOp(Mul),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      ['/', .. rest] => {
        let tok = Token::new(
          BinaryOp(Div),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      ['%', .. rest] => {
        let tok = Token::new(
          BinaryOp(Mod),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      ['&', .. rest] => {
        let tok = Token::new(
          BinaryOp(BitAnd),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      ['|', .. rest] => {
        let tok = Token::new(
          BinaryOp(BitOr),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      ['<', .. rest] => {
        let tok = Token::new(
          BinaryOp(LT),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      ['>', .. rest] => {
        let tok = Token::new(
          BinaryOp(GT),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      ['=', .. rest] => {
        let tok = Token::new(
          AssignOp(Assign),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      ['!', .. rest] => {
        let tok = Token::new(Not, line, col, idx, source_code, source_file)
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      ['(', .. rest] => {
        let tok = Token::new(
          Bracket('('),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      [')', .. rest] => {
        let tok = Token::new(
          Bracket(')'),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      ['[', .. rest] => {
        let tok = Token::new(
          Bracket('['),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      [']', .. rest] => {
        let tok = Token::new(
          Bracket(']'),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      ['{', .. rest] => {
        let tok = Token::new(
          Bracket('{'),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      ['}', .. rest] => {
        let tok = Token::new(
          Bracket('}'),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      ['.', .. rest] => {
        let tok = Token::new(
          Symbol("."),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      [',', .. rest] => {
        let tok = Token::new(
          Symbol(","),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      [':', .. rest] => {
        let tok = Token::new(
          Symbol(":"),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      [';', .. rest] => {
        let tok = Token::new(
          Symbol(";"),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        col += 1
        idx += 1
        continue rest
      }
      ['\"', ..] as code => {
        let (tok_kind, len, rest) = tokenize_string(code)
        let tok = Token::new(tok_kind, line, col, idx, source_code, source_file)
        tokens.push(tok)
        col += len
        idx += len
        continue rest
      }
      ['\'', ..] as code => {
        let (tok_kind, len, rest) = tokenize_char(code)
        let tok = Token::new(tok_kind, line, col, idx, source_code, source_file)
        tokens.push(tok)
        col += len
        idx += len
        continue rest
      }
      ['A'..='Z', ..] as code => {
        let sb = StringBuilder()
        let rest = for current = code {
          match current {
            ['A'..='Z' | 'a'..='z' | '0'..='9' | '_' as c, .. rest] => {
              sb.write_char(c)
              col += 1
              idx += 1
              continue rest
            }
            rest => break rest
          }
        }
        let ident = sb.to_string()
        let tok = Token::new(
          Upper(ident),
          line,
          col,
          idx,
          source_code,
          source_file,
        )
        tokens.push(tok)
        continue rest
      }
      ['_' | 'a'..='z', ..] as code => {
        let (ident, len, rest) = tokenize_lower_ident(code)
        col += len
        idx += len
        let tok = Token::new(ident, line, col, idx, source_code, source_file)
        tokens.push(tok)
        continue rest
      }
      ['0'..='9', ..] as code => {
        let (tok_kind, len, rest) = tokenize_number(code)
        let tok = Token::new(tok_kind, line, col, idx, source_code, source_file)
        tokens.push(tok)
        col += len
        idx += len
        continue rest
      }
      other_strs =>
        raise TokenizeError("Tokenize Error: Unexpected char: \{other_strs}")
    }
  }
  tokens
}

///|
fn tokenize_lower_ident(code : StringView) -> (TokenKind, Int, StringView) {
  let sb = StringBuilder()
  let rest = for current = code {
    match current {
      ['a'..='z' | 'A'..='Z' | '0'..='9' | '_' as c, .. rest] => {
        sb.write_char(c)
        continue rest
      }
      rest => break rest
    }
  }
  let ident = sb.to_string()
  let kind = match ident {
    "fn" => Keyword(Fn)
    "struct" => Keyword(Struct)
    "let" => Keyword(Let)
    "mut" => Keyword(Mut)
    "if" => Keyword(If)
    "else" => Keyword(Else)
    "while" => Keyword(While)
    "for" => Keyword(For)
    "return" => Keyword(Return)
    "extern" => Keyword(Extern)
    "true" => Bool(true)
    "false" => Bool(false)
    "enum" => Keyword(Enum)
    "match" => Keyword(Match)
    "_" => Wildcard
    _ => Lower(ident)
  }
  (kind, ident.length(), rest)
}

///|
///
fn tokenize_number(
  code : StringView,
) -> (TokenKind, Int, StringView) raise TokenizeError {
  // Check for hexadecimal integer literal (0x or 0X)
  match code {
    ['0', 'x' | 'X', '0'..='9' | 'a'..='f' | 'A'..='F', ..] => {
      // Parse hexadecimal number
      let hex_sb = StringBuilder()
      let rest = match code {
        ['0', 'x' | 'X', .. rest] => rest
        _ => panic()
      }
      // Parse hex digits
      let rest = for current = rest {
        match current {
          ['0'..='9' | 'a'..='f' | 'A'..='F' as c, .. rest] => {
            hex_sb.write_char(c)
            continue rest
          }
          rest => break rest
        }
      }
      let hex_str = hex_sb.to_string()
      let total_len = 2 + hex_str.length() // "0x" + hex digits

      // Check for suffix: UL, U, or L
      match rest {
        ['U', 'L', .. rest] => {
          let value = @string.parse_uint64(hex_str, base=16) catch {
            _ =>
              raise TokenizeError(
                "Invalid hexadecimal UInt64 literal: 0x\{hex_str}",
              )
          }
          (TokenKind::UInt64(value), total_len + 2, rest)
        }
        ['U', .. rest] => {
          let value = @string.parse_uint(hex_str, base=16) catch {
            _ =>
              raise TokenizeError(
                "Invalid hexadecimal UInt literal: 0x\{hex_str}",
              )
          }
          (TokenKind::UInt(value), total_len + 1, rest)
        }
        ['L', .. rest] => {
          let value = @string.parse_uint64(hex_str, base=16) catch {
            _ =>
              raise TokenizeError(
                "Invalid hexadecimal Int64 literal: 0x\{hex_str}",
              )
          }
          let value = value.reinterpret_as_int64()
          (TokenKind::Int64(value), total_len + 1, rest)
        }
        _ => {
          let value = @string.parse_uint(hex_str, base=16) catch {
            _ =>
              raise TokenizeError(
                "Invalid hexadecimal Int literal: 0x\{hex_str}",
              )
          }
          let value = value.reinterpret_as_int()
          (TokenKind::Int(value), total_len, rest)
        }
      }
    }
    _ => {
      // Parse decimal number
      let sb = StringBuilder()
      let mut is_float = false

      // Parse the numeric part
      let rest = for current = code {
        match current {
          ['0'..='9' as c, .. rest] => {
            sb.write_char(c)
            continue rest
          }
          rest => break rest
        }
      }
      // Check for decimal point (float)
      let rest = match rest {
        ['.', '0'..='9', ..] as dot_rest => {
          is_float = true
          sb.write_char('.')
          let rest_after_dot = match dot_rest {
            ['.', .. rest] => rest
            _ => panic()
          }
          // Parse fractional part
          for current = rest_after_dot {
            match current {
              ['0'..='9' as c, .. rest] => {
                sb.write_char(c)
                continue rest
              }
              rest => break rest
            }
          }
        }
        _ => rest
      }

      // Check for exponent (e or E)
      let rest = match rest {
        ['e' | 'E' as e, ..] as exp_rest => {
          is_float = true
          sb.write_char(e)
          let rest_after_e = match exp_rest {
            ['e' | 'E', .. rest] => rest
            _ => panic()
          }
          // Check for optional sign
          let rest_after_sign = match rest_after_e {
            ['+' | '-' as sign, .. rest] => {
              sb.write_char(sign)
              rest
            }
            _ => rest_after_e
          }
          // Parse exponent digits
          let rest_after_exp = for current = rest_after_sign {
            match current {
              ['0'..='9' as c, .. rest] => {
                sb.write_char(c)
                continue rest
              }
              rest => break rest
            }
          }
          rest_after_exp
        }
        _ => rest
      }
      let num_str = sb.to_string()
      // Check for type suffix (F for Float, UL for UInt64, U for UInt, L for Int64)
      if is_float {
        match rest {
          ['F', .. rest] => {
            let value = @string.parse_double(num_str) catch {
              _ => raise TokenizeError("Invalid Float literal: \{num_str}")
            }
            (TokenKind::Float(value), num_str.length() + 1, rest)
          }
          _ => {
            let value = @string.parse_double(num_str) catch {
              _ => raise TokenizeError("Invalid Double literal: \{num_str}")
            }
            (TokenKind::Double(value), num_str.length(), rest)
          }
        }
      } else {
        match rest {
          ['U', 'L', .. rest] => {
            let value = @string.parse_uint64(num_str) catch {
              _ => raise TokenizeError("Invalid UInt64 literal: \{num_str}")
            }
            (TokenKind::UInt64(value), num_str.length() + 2, rest)
          }
          ['U', .. rest] => {
            let value = @string.parse_uint(num_str) catch {
              _ => raise TokenizeError("Invalid UInt literal: \{num_str}")
            }
            (TokenKind::UInt(value), num_str.length() + 1, rest)
          }
          ['L', .. rest] => {
            let value = @string.parse_int64(num_str) catch {
              _ => raise TokenizeError("Invalid Int64 literal: \{num_str}")
            }
            (TokenKind::Int64(value), num_str.length() + 1, rest)
          }
          _ => {
            let value = @string.parse_int(num_str) catch {
              _ => raise TokenizeError("Invalid Int literal: \{num_str}")
            }
            (TokenKind::Int(value), num_str.length(), rest)
          }
        }
      }
    }
  }
}

///|
fn tokenize_string(
  code : StringView,
) -> (TokenKind, Int, StringView) raise TokenizeError {
  guard code is ['\"', .. code] else {
    println("Compiler ICE: Tokenize String Error")
    panic()
  }
  let sb = StringBuilder()
  let rest = for current = code {
    match current {
      ['\"', .. rest] => break rest
      [c, .. rest] => {
        sb.write_char(c)
        continue rest
      }
      [] => raise TokenizeError("Tokenize Error: Unterminated string literal")
    }
  }
  let str_val = sb.to_string()
  // + 2 for the surrounding quotes
  (String(str_val), str_val.length() + 2, rest)
}

///|
fn parse_escape_char(c : Char) -> Char raise TokenizeError {
  match c {
    'n' => '\n'
    't' => '\t'
    'r' => '\r'
    '\\' => '\\'
    '\'' => '\''
    '\"' => '\"'
    _ => raise TokenizeError("Invalid escape sequence: \\\{c}")
  }
}

///|
fn tokenize_char(
  code : StringView,
) -> (TokenKind, Int, StringView) raise TokenizeError {
  guard code is ['\'', .. code] else {
    println("Compiler ICE: Tokenize Char Error")
    panic()
  }
  let (char_val, len, rest) = match code {
    ['\\', c, '\'', .. rest] => {
      // Escaped character
      let escaped_char = parse_escape_char(c)
      (escaped_char, 4, rest) // 4 = '\' + c + '\'' = 4 chars including opening quote
    }
    [c, '\'', .. rest] =>
      // Regular character
      (c, 3, rest) // 3 = '\'' + c + '\''
    [] => raise TokenizeError("Tokenize Error: Unterminated char literal")
    _ => raise TokenizeError("Tokenize Error: Invalid char literal")
  }
  (Char(char_val), len, rest)
}
