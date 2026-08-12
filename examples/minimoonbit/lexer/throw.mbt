///|
/// Prints a colored source diagnostic for a token.
///
/// **Side effects:**
///
/// Writes the formatted diagnostic to standard output.
pub fn throw_(tok : Token, msg : String, level : ThrowLevel) -> Unit {
  let { line, col, code, file, .. } = tok
  let str_builder = StringBuilder::new()
  let color = match level {
    Error => @color.Color::Red
    Warning => @color.Color::Yellow
  }

  // 第一行：文件名、行号和列号
  let head_line = @color.taint("[\{file}:\{line}:\{col}] \{level}:", Magenta)
  str_builder.write_string("\{head_line}\n")

  // 第二行：空行
  str_builder.write_string("\{line-1}|")
  if line > 1 {
    let prev_line = get_code_line(code, line - 1)
    str_builder.write_string("\{prev_line}\n")
  } else {
    str_builder.write_string("\n")
  }

  // 第三行：找到包含当前token的代码行
  let code_line = get_code_line(code, line)
  str_builder.write_string("\{line}|\{code_line}\n")

  // 第四行：在column位置打印`^`，然后打印msg
  let mut indent = "" // 与代码行的缩进保持一致
  for _ in 1..<col {
    indent += " "
  }
  let msg = @color.taint("^ \{msg}", color)
  str_builder.write_string("\{line+1}|\{indent}\{msg}\n")
  let w = str_builder.to_string()
  println(w)
}

///|
/// Selects the severity used to format a MiniMoonBit source diagnostic.
pub(all) enum ThrowLevel {
  /// Formats an error diagnostic.
  Error
  /// Formats a warning diagnostic.
  Warning
} derive(Show)

///|
fn get_code_line(code : String, line : Int) -> String {
  let mut lineno = line
  let sb = StringBuilder::new()
  for c in code {
    if c == '\n' {
      lineno -= 1
      if lineno == 0 {
        return sb.to_string()
      }
    } else if lineno == 1 {
      sb.write_char(c)
    }
  }
  sb.to_string()
}
