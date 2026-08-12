///|
/// Represents the MiniMoonBit parser AST node `ExternFunction`.
pub(all) struct ExternFunction {
  /// Stores the `fname` component of this parser AST node.
  fname : String
  /// Stores the `param_list` component of this parser AST node.
  param_list : Array[Param]
  /// Stores the `ret_ty` component of this parser AST node.
  ret_ty : Type?
  /// Stores the `ffi_name` component of this parser AST node.
  ffi_name : String
} derive(Eq)

///|
/// Formats `ExternFunction` using MiniMoonBit source notation.
pub impl Show for ExternFunction with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `ExternFunction` value with optional ANSI coloring.
pub fn ExternFunction::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "extern function: \{self.fname}"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
  let mut result = prefix

  // Format parameters
  if self.param_list.length() > 0 {
    let params_prefix = "params:"
    let params_prefix = if color {
      @color.taint(params_prefix, Blue)
    } else {
      params_prefix
    }
    result = "\{result}\n├-\{params_prefix}"
    for i = 0; i < self.param_list.length(); i = i + 1 {
      let param = self.param_list[i]
      let param_text = param.to_string(color~)
      let is_last_param = i == self.param_list.length() - 1
      let param_formatted = if is_last_param {
        format_lines([param_text], head_with="└-", continue_with="  ")
      } else {
        format_lines([param_text], head_with="├-", continue_with="│ ")
      }
      result = "\{result}\n│ \{param_formatted}"
    }
  }

  // Format return type if present
  match self.ret_ty {
    Some(ret_ty) => {
      let ret_text = "return: \{ret_ty.to_string(color~)}"
      let ret_formatted = format_lines(
        [ret_text],
        head_with="├-",
        continue_with="│ ",
      )
      result = "\{result}\n\{ret_formatted}"
    }
    None => ()
  }

  // Format FFI name
  let ffi_text = "ffi: \"\{self.ffi_name}\"\n"
  let ffi_formatted = format_lines(
    [ffi_text],
    head_with="└-",
    continue_with="  ",
  )
  result = "\{result}\n\{ffi_formatted}\n"
  result
}

///|
///
///extern_func := "extern" str "fn" lower "(" param_list ")" "->" type "=" ffi_name
///
/// str can `"C"`, `"Js"` ect
/// but actually, we just parse it as a string literal here, don't care about its content.
///
/// just because the original moonbit support that, we keep it.
pub fn parse_extern_function(
  tokens : ArrayView[Token],
) -> (ExternFunction, ArrayView[Token]) raise ParseError {
  guard tokens is [{ kind: Keyword(Extern), .. }, .. tokens] else {
    println("Compiler ICE: Misuse parse_extern_function")
    panic()
  }
  guard tokens is [{ kind: String(_), .. }, .. tokens] else {
    @lexer.throw_(
      tokens[0],
      "Expect a language string, \"c\", \"ss\", \"wasm\" ect",
      Error,
    )
    raise ParseError("Expect a language string, \"c\", \"ss\", \"wasm\" ect")
  }
  guard tokens is [{ kind: Keyword(Fn), .. }, .. tokens] else {
    @lexer.throw_(tokens[0], "Expect 'fn'", Error)
    raise ParseError("Expect 'fn'")
  }
  guard tokens is [{ kind: Lower(fname), .. }, .. tokens] else {
    @lexer.throw_(tokens[0], "Expect a lower ident", Error)
    raise ParseError("Expect a lower ident")
  }
  guard tokens is [{ kind: Bracket('('), .. }, .. tokens] else {
    @lexer.throw_(tokens[0], "Expect '('", Error)
    raise ParseError("Expect '('")
  }
  let (param_list, tokens) = parse_param_list(tokens)
  guard tokens is [{ kind: Bracket(')'), .. }, .. tokens] else {
    @lexer.throw_(tokens[0], "Expect ')'", Error)
    raise ParseError("Expect ')'")
  }
  let (ret_ty, tokens) = if tokens
    is [{ kind: Symbol("->"), .. }, .. rest_tokens] {
    let (ret_ty, tokens) = parse_type(rest_tokens)
    (Some(ret_ty), tokens)
  } else {
    (None, tokens)
  }
  guard tokens is [{ kind: AssignOp(Assign), .. }, .. tokens] else {
    @lexer.throw_(tokens[0], "Expect '='", Error)
    raise ParseError("Expect '='")
  }
  guard tokens is [{ kind: String(ffi_name), line, .. }, .. tokens] else {
    @lexer.throw_(tokens[0], "Expect FFI name", Error)
    raise ParseError("Expect FFI name")
  }
  let tokens = if tokens is [{ kind: Symbol(";"), .. }, .. tokens] {
    tokens
  } else if tokens is [tok, ..] && tok.line != line {
    tokens
  } else if tokens is [{ kind: Bracket('}'), .. }, ..] {
    tokens
  } else {
    @lexer.throw_(
      tokens[0],
      "Parse Error: Expect ';' or '}' or newline after let statement",
      Error,
    )
    raise ParseError("Expect ';' or '}' or newline after let statement")
  }
  let extern_function = ExternFunction::{ fname, param_list, ret_ty, ffi_name }
  (extern_function, tokens)
}

///|
test "ExternFunction to_string Test - Simple" {
  let color = false
  let code =
    #|extern "c" fn sqrt(x: Double) -> Double = "sqrt" ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse simple extern function
  let (extern_fn, _) = parse_extern_function(tokens)
  inspect(
    extern_fn.to_string(color~),
    content=(
      #|extern function: sqrt
      #|├-params:
      #|│ └-x: Double
      #|├-return: Double
      #|└-ffi: "sqrt"
      #|
      #|

    ),
  )
}

///|
test "ExternFunction to_string Test - Multiple Params" {
  let color = false
  let code =
    #|extern "c" fn pow(x: Double, y: Double) -> Double = "pow" ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse extern function with multiple parameters
  let (extern_fn, _) = parse_extern_function(tokens)
  inspect(
    extern_fn.to_string(color~),
    content=(
      #|extern function: pow
      #|├-params:
      #|│ ├-x: Double
      #|│ └-y: Double
      #|├-return: Double
      #|└-ffi: "pow"
      #|
      #|

    ),
  )
}

///|
test "ExternFunction to_string Test - No Return" {
  let color = false
  let code =
    #|extern "c" fn print_int(x: Int) = "print_int" ;
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse extern function without return type
  let (extern_fn, _) = parse_extern_function(tokens)
  inspect(
    extern_fn.to_string(color~),
    content=(
      #|extern function: print_int
      #|├-params:
      #|│ └-x: Int
      #|└-ffi: "print_int"
      #|
      #|

    ),
  )
}
