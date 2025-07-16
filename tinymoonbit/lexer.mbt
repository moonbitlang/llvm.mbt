///|
priv suberror LexerError String derive(Show)

///|
priv enum Keyword {
  Let
  If
  Else
  While
  Return
  Fn
  Struct
  As
  Ref
  SizeOf
  Extern
} derive(Show)

///|
priv enum Token {
  Bool(Bool)
  Int(Int)
  Int64(Int64)
  UInt(UInt)
  UInt64(UInt64)
  Float(Float)
  Double(Double)
  Keyword(Keyword)
  Upper(String)
  Lower(String)
  Operator(String) // +, -, *, /, %, =, ==, !=, <, >, <=, >=, &&, ||
  Bracket(Char) // (, ), [, ], {, }
  Symbol(String) // , : , . , @
  Terminator // ;
  LeftArrow // ->
  EOF
} derive(Show)

///|
fn lex(code : String) -> Array[Token] raise {
  let tokens = Array::new()
  loop code[:] {
    [] => {
      tokens.push(EOF)
      break tokens
    }
    [.. "//", .. rest] =>
      continue loop rest {
          ['\n' | '\r', .. rest_str] => break rest_str
          [_, .. rest_str] => continue rest_str
          [] as rest_str => break rest_str
        }
    [';', .. rest] => {
      tokens.push(Token::Terminator)
      continue rest
    }
    [.. "::", .. rest] => {
      tokens.push(Token::Symbol("::"))
      continue rest
    }
    [':' | '.' | ',' as c, .. rest] => {
      tokens.push(Token::Symbol(c.to_string()))
      continue rest
    }
    [' ' | '\n' | '\r' | '\t', .. rest] => continue rest
    ['+', .. rest] => {
      tokens.push(Token::Operator("+".to_string()))
      continue rest
    }
    [.. "->", .. rest] => {
      tokens.push(Token::LeftArrow)
      continue rest
    }
    ['-', .. rest] => {
      tokens.push(Token::Operator("-".to_string()))
      continue rest
    }
    ['*', .. rest] => {
      tokens.push(Token::Operator("*".to_string()))
      continue rest
    }
    ['/', .. rest] => {
      tokens.push(Token::Operator("/"))
      continue rest
    }
    ['%', .. rest] => {
      tokens.push(Token::Operator("%"))
      continue rest
    }
    [.. ">>", .. rest] => {
      tokens.push(Token::Operator(">>".to_string()))
      continue rest
    }
    [.. "<<", .. rest] => {
      tokens.push(Token::Operator("<<".to_string()))
      continue rest
    }
    [.. "==", .. rest] => {
      tokens.push(Token::Operator("==".to_string()))
      continue rest
    }
    [.. "!=", .. rest] => {
      tokens.push(Token::Operator("!=".to_string()))
      continue rest
    }
    [.. "<=", .. rest] => {
      tokens.push(Token::Operator("<=".to_string()))
      continue rest
    }
    [.. ">=", .. rest] => {
      tokens.push(Token::Operator(">=".to_string()))
      continue rest
    }
    [.. "&&", .. rest] => {
      tokens.push(Token::Operator("&&".to_string()))
      continue rest
    }
    [.. "&", .. rest] => {
      tokens.push(Token::Operator("&".to_string()))
      continue rest
    }
    [.. "||", .. rest] => {
      tokens.push(Token::Operator("||".to_string()))
      continue rest
    }
    [.. "|", .. rest] => {
      tokens.push(Token::Operator("|".to_string()))
      continue rest
    }
    ['<', .. rest] => {
      tokens.push(Token::Operator("<".to_string()))
      continue rest
    }
    ['>', .. rest] => {
      tokens.push(Token::Operator(">".to_string()))
      continue rest
    }
    ['=', .. rest] => {
      tokens.push(Token::Operator("=".to_string()))
      continue rest
    }
    ['(', .. rest] => {
      tokens.push(Token::Bracket('('))
      continue rest
    }
    [')', .. rest] => {
      tokens.push(Token::Bracket(')'))
      continue rest
    }
    ['[', .. rest] => {
      tokens.push(Token::Bracket('['))
      continue rest
    }
    [']', .. rest] => {
      tokens.push(Token::Bracket(']'))
      continue rest
    }
    ['{', .. rest] => {
      tokens.push(Token::Bracket('{'))
      continue rest
    }
    ['}', .. rest] => {
      tokens.push(Token::Bracket('}'))
      continue rest
    }
    ['A'..='Z' as c, .. rest] => {
      let ident = [c]
      let rest_str = loop rest {
        ['a'..='z' | 'A'..='Z' | '0'..='9' | '_' as c, .. rest_str] => {
          ident.push(c)
          continue rest_str
        }
        _ as rest_str => break rest_str
      }
      tokens.push(Token::Upper(String::from_array(ident)))
      continue rest_str
    }
    ['a'..='z', ..] as code => {
      let (tok, rest) = lex_lower_ident(code)
      tokens.push(tok)
      continue rest
    }
    ['0'..='9', ..] as code => {
      let (tok, rest) = lex_number(code)
      tokens.push(tok)
      continue rest
    }
    other_strs =>
      raise LexerError("Parse Error: Unexpected char: \{other_strs}")
  }
}

///|
fn lex_lower_ident(rest : @string.View) -> (Token, @string.View) {
  let ident = Array::new()
  let rest_str = loop rest {
    ['a'..='z' | 'A'..='Z' | '0'..='9' | '_' as c, .. rest_str] => {
      ident.push(c)
      continue rest_str
    }
    _ as rest_str => break rest_str
  }
  let ident = String::from_array(ident)
  let tok = match ident {
    "let" => Token::Keyword(Keyword::Let)
    "if" => Token::Keyword(Keyword::If)
    "else" => Token::Keyword(Keyword::Else)
    "while" => Token::Keyword(Keyword::While)
    "return" => Token::Keyword(Keyword::Return)
    "fn" => Token::Keyword(Keyword::Fn)
    "struct" => Token::Keyword(Keyword::Struct)
    "as" => Token::Keyword(Keyword::As)
    "ref" => Token::Keyword(Keyword::Ref)
    "sizeof" => Token::Keyword(Keyword::SizeOf)
    "extern" => Token::Keyword(Keyword::Extern)
    "true" => Token::Bool(true)
    "false" => Token::Bool(false)
    _ => Token::Lower(ident)
  }
  (tok, rest_str)
}

///|
fn lex_number(rest : @string.View) -> (Token, @string.View) raise {
  let mut has_dot = false
  let num_chars = Array::new()
  loop rest {
    ['0'..='9' as c, .. rest_str] => {
      num_chars.push(c)
      continue rest_str
    }
    ['.', .. rest_str] if not(has_dot) => {
      has_dot = true
      num_chars.push('.')
      continue rest_str
    }
    ['L' | 'l', .. rest_str] => {
      let num_str = String::from_array(num_chars)
      let num = match (try? @strconv.parse_int64(num_str)) {
        Ok(n) => n
        Err(_) => raise LexerError("Parse Int64 failed: \{num_str}")
      }
      break (Token::Int64(num), rest_str)
    }
    [.. "UL", .. rest_str] => {
      let num_str = String::from_array(num_chars)
      let num = match (try? @strconv.parse_uint64(num_str)) {
        Ok(n) => n
        Err(_) => raise LexerError("Parse UInt64 failed: \{num_str}")
      }
      break (Token::UInt64(num), rest_str)
    }
    ['U' | 'u', .. rest_str] => {
      let num_str = String::from_array(num_chars)
      let num = match (try? @strconv.parse_uint(num_str)) {
        Ok(n) => n
        Err(_) => raise LexerError("Parse UInt failed: \{num_str}")
      }
      break (Token::UInt(num), rest_str)
    }
    ['F' | 'f', .. rest_str] => {
      let num_str = String::from_array(num_chars)
      let num = match (try? @strconv.parse_double(num_str)) {
        Ok(n) => n
        Err(_) => {
          println("Parse Float failed: \{num_str}")
          panic()
        }
      }
      break (Token::Float(num.to_float()), rest_str)
    }
    _ as rest if has_dot => {
      let num_str = String::from_array(num_chars)
      let num = match (try? @strconv.parse_double(num_str)) {
        Ok(n) => n
        Err(_) => raise LexerError("Parse Double failed: \{num_str}")
      }
      break (Token::Double(num), rest)
    }
    _ as rest => {
      let num_str = String::from_array(num_chars)
      let num = match (try? @strconv.parse_int(num_str)) {
        Ok(n) => n
        Err(_) => raise LexerError("Parse Int failed: \{num_str}")
      }
      break (Token::Int(num), rest)
    }
  }
}

///|
test "lex" {
  let code =
    #|fn add(x: Int, y: Int) -> Int {
    #|  return x + y - 342UL
    #|}
  let toks = lex(code)
  inspect(
    toks,
    content="[Keyword(Fn), Lower(\"add\"), Bracket('('), " +
      "Lower(\"x\"), Symbol(\":\"), Upper(\"Int\"), " +
      "Symbol(\",\"), Lower(\"y\"), Symbol(\":\"), " +
      "Upper(\"Int\"), Bracket(')'), LeftArrow, " +
      "Upper(\"Int\"), Bracket('{'), Keyword(Return), " +
      "Lower(\"x\"), Operator(\"+\"), Lower(\"y\"), " +
      "Operator(\"-\"), UInt64(342), Bracket('}'), EOF]",
  )
}
