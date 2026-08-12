///|
using @lexer {type Token}

///|
using @either {type Either}

///|
/// Reports a MiniMoonBit parsing failure through `ParseError`.
pub suberror ParseError {
  /// Represents the `ParseError` parser AST form.
  ParseError(String)
} derive(Debug)

///|
/// Formats `TypeKind` using MiniMoonBit source notation.
pub impl Show for TypeKind with fn output(self, logger) {
  let s = match self {
    Unit => "Unit"
    Bool => "Bool"
    Int => "Int"
    Int64 => "Int64"
    UInt => "UInt"
    UInt64 => "UInt64"
    Double => "Double"
    Float => "Float"
    Char => "Char"
    String => "String"
    Tuple(tys) => {
      let inner = tys.map(ty => ty.to_string()).join(", ")
      "(\{inner})"
    }
    Array(ty) => "Array[\{ty}]"
    Function(params, ret) => {
      let param_str = params.map(ty => ty.to_string()).join(", ")
      "(\{param_str}) -> \{ret}"
    }
    Defined(name) => name
  }
  logger.write_string(s)
}

///|
/// Format lines with tree structure
/// For AI: Modify this function is ok.
pub fn format_lines(
  lines : Array[String],
  head_with? : String = "└-",
  continue_with? : String = "  ",
) -> String {
  let sb = StringBuilder::new()
  let strs = []
  for i = 0; i < lines.length(); i = i + 1 {
    if i == 0 {
      sb.write_string(head_with)
    } else {
      sb.write_string(continue_with)
    }
    sb.write_string(lines[i])
    strs.push(sb.to_string())
    sb.reset()
  }
  strs.join("\n")
}

///|
/// Skips one optional semicolon at the beginning of a token view.
pub fn skip_semicolon(tokens : ArrayView[Token]) -> ArrayView[Token] {
  match tokens {
    [{ kind: Symbol(";"), .. }, .. rest] => rest
    _ => tokens
  }
}
