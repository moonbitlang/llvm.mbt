///|
fn SourcePos::advance_inline(self : SourcePos, width : Int) -> SourcePos {
  { offset: self.offset + width, line: self.line, column: self.column + width }
}

///|
fn SourcePos::advance_line(self : SourcePos, width : Int) -> SourcePos {
  { offset: self.offset + width, line: self.line + 1, column: 1 }
}

///|
fn push_token(
  tokens : Array[Token],
  kind : TokenKind,
  start : SourcePos,
  end : SourcePos,
) -> Unit {
  tokens.push({ kind, start, end })
}

///|
fn keyword_or_identifier(text : String) -> TokenKind {
  match text {
    "def" => Def
    "extern" => Extern
    "if" => If
    "then" => Then
    "else" => Else
    "for" => For
    "in" => In
    "binary" => Binary
    "unary" => Unary
    "var" => Var
    identifier => Identifier(identifier)
  }
}

///|
fn parse_number(raw : StringView, start : SourcePos) -> Double raise LexError {
  let text = raw.to_owned()
  @string.parse_double(text) catch {
    _ => raise MalformedNumber(text, start)
  }
}

///|
/// Tokenizes a complete Kaleidoscope source buffer and appends one EOF token.
///
/// Comments start with `#` and continue to the next line. Identifiers and
/// operators use the ASCII spellings accepted by the planned parser; source
/// positions still account for UTF-16 width in skipped comments and errors.
///
/// **Parameters:**
///
/// - `source`: Complete source text for one or more top-level forms.
///
/// **Returns:**
///
/// Tokens in source order, followed by exactly one `TokenKind::Eof`.
///
/// **Errors:**
///
/// - `LexError::MalformedNumber` for a numeric-looking invalid literal.
/// - `LexError::InvalidCharacter` for a character outside the language.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let tokens = @lexer.tokenize("def answer() 42;")
///   debug_inspect(tokens[0].kind, content="Def")
///   debug_inspect(tokens[tokens.length() - 1].kind, content="Eof")
/// }
/// ```
pub fn tokenize(source : String) -> Array[Token] raise LexError {
  let tokens : Array[Token] = []
  for input = source[:], position = SourcePos::{ offset: 0, line: 1, column: 1 } {
    lexmatch input with longest {
      re"^$" => {
        push_token(tokens, Eof, position, position)
        break tokens
      }
      (re"^[ \t]+" as raw, after=rest) =>
        continue rest, position.advance_inline(raw.length())
      (re"^(?:\r\n|\r|\n)" as raw, after=rest) =>
        continue rest, position.advance_line(raw.length())
      (re"^(?:#[^\r\n]*)" as raw, after=rest) =>
        continue rest, position.advance_inline(raw.length())
      (
        re"^(?:(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][+\-]?[0-9]+)?)" as raw,
        after=rest,
      ) => {
        let end = position.advance_inline(raw.length())
        push_token(tokens, Number(parse_number(raw, position)), position, end)
        continue rest, end
      }
      (re"^(?:[0-9][0-9A-Za-z_.]*|\.[0-9][0-9A-Za-z_.]*)" as raw, after=_) =>
        raise MalformedNumber(raw.to_owned(), position)
      (re"^(?:[A-Za-z_][A-Za-z0-9_]*)" as raw, after=rest) => {
        let end = position.advance_inline(raw.length())
        push_token(tokens, keyword_or_identifier(raw.to_owned()), position, end)
        continue rest, end
      }
      (re"^(?:[(),;])" as punctuation, after=rest) => {
        let kind = match punctuation {
          '(' => LeftParen
          ')' => RightParen
          ',' => Comma
          ';' => Semicolon
          _ => panic()
        }
        let end = position.advance_inline(1)
        push_token(tokens, kind, position, end)
        continue rest, end
      }
      (re"^(?:[!$%&*+./:<=>?@^|~\-])" as operator, after=rest) => {
        let end = position.advance_inline(1)
        push_token(tokens, Operator(operator), position, end)
        continue rest, end
      }
      _ => {
        guard input.get_char(0) is Some(character) else {
          push_token(tokens, Eof, position, position)
          break tokens
        }
        raise InvalidCharacter(character, position)
      }
    }
  }
}
