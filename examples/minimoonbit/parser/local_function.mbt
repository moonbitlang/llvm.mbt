///|
/// Represents the MiniMoonBit parser AST node `LocalFunction`.
pub(all) struct LocalFunction {
  /// Stores the `fname` component of this parser AST node.
  fname : String
  /// Stores the `param_list` component of this parser AST node.
  param_list : Array[(String, Type?)]
  /// Stores the `ret_ty` component of this parser AST node.
  ret_ty : Type?
  /// Stores the `body` component of this parser AST node.
  body : BlockExpr
} derive(Eq)

///|
/// Formats `LocalFunction` using MiniMoonBit source notation.
pub impl Show for LocalFunction with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `LocalFunction` value with optional ANSI coloring.
pub fn LocalFunction::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "local function: \{self.fname}"
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
      let (name, ty_opt) = self.param_list[i]
      let param_text = match ty_opt {
        Some(ty) => "\{name}: \{ty.to_string(color~)}"
        None => name
      }
      let is_last_param = i == self.param_list.length() - 1
      let param_formatted = if is_last_param {
        format_lines([param_text], head_with="└-", continue_with="  ")
      } else {
        format_lines([param_text], head_with="├-", continue_with="│ ")
      }
      result = "\{result}\n│ \{param_formatted}"
    }
  }

  // Format return type
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

  // Format body
  let body_str = self.body.to_string(color~)
  let body_lines = body_str.split("\n").map(sv => sv.to_owned()).to_array()
  let body_formatted = format_lines(
    body_lines,
    head_with="└-body: ",
    continue_with="        ",
  )
  result = "\{result}\n\{body_formatted}"
  result
}

///|
/// Parses the `parse_local_function` syntax form and returns the unconsumed token suffix.
pub fn parse_local_function(
  tokens : ArrayView[Token],
) -> (LocalFunction, ArrayView[Token]) raise ParseError {
  guard tokens is [{ kind: Keyword(Fn), .. }, .. tokens] else {
    println("Compiler ICE: Misuse parse_local_function")
    panic()
  }
  guard tokens is [{ kind: Lower(fname), .. }, .. tokens] else {
    @lexer.throw_(
      tokens[0],
      "Expect a lower ident as local function name",
      Error,
    )
    raise ParseError("Expect a lower ident")
  }
  guard tokens is [{ kind: Bracket('('), .. }, .. tokens] else {
    raise ParseError("Expect '('")
  }
  let params : Array[(String, Type?)] = []
  let tokens = for current = tokens {
    match current {
      [{ kind: Bracket(')'), .. }, .. tokens] => break tokens
      [{ kind: Lower(name), .. }, { kind: Symbol(":"), .. }, .. tokens] => {
        let (ty, tokens) = parse_type(tokens)
        params.push((name, Some(ty)))
        continue tokens
      }
      [
        { kind: Symbol(","), .. },
        { kind: Lower(name), .. },
        { kind: Symbol(":"), .. },
        .. tokens,
      ] => {
        let (ty, tokens) = parse_type(tokens)
        params.push((name, Some(ty)))
        continue tokens
      }
      [{ kind: Lower(name), .. }, .. tokens] => {
        params.push((name, None))
        continue tokens
      }
      [{ kind: Symbol(","), .. }, { kind: Lower(name), .. }, .. tokens] => {
        params.push((name, None))
        continue tokens
      }
      [] => {
        println("Compiler ICE: Empty Token ArrayView")
        panic()
      }
      tok => raise ParseError("InValid Param List Parsing: \{tok[0]}")
    }
  }
  let (ret_ty, tokens) = if tokens is [{ kind: Symbol("->"), .. }, .. tokens] {
    let (ty, tokens) = parse_type(tokens)
    (Some(ty), tokens)
  } else {
    (None, tokens)
  }
  let (body, tokens) = parse_block_expr(tokens)
  let local_function = LocalFunction::{
    fname,
    param_list: params,
    ret_ty,
    body,
  }
  (local_function, tokens)
}

///|
test "LocalFunction to_string Test - Simple" {
  let color = false
  let code =
    #|fn add(x, y) { return x + y ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse simple local function without types
  let (local_fn, _) = parse_local_function(tokens)
  inspect(
    local_fn.to_string(color~),
    content=(
      #|local function: add
      #|├-params:
      #|│ ├-x
      #|│ └-y
      #|└-body: block
      #|        └-return statement
      #|          └-binary expr: +
      #|            ├-variable x
      #|            └-variable y
      #|        
    ),
  )
}

///|
test "LocalFunction to_string Test - With Types" {
  let color = false
  let code =
    #|fn multiply(x: Int, y: Int) -> Int { return x * y ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse local function with parameter and return types
  let (local_fn, _) = parse_local_function(tokens)
  inspect(
    local_fn.to_string(color~),
    content=(
      #|local function: multiply
      #|├-params:
      #|│ ├-x: Int
      #|│ └-y: Int
      #|├-return: Int
      #|└-body: block
      #|        └-return statement
      #|          └-binary expr: *
      #|            ├-variable x
      #|            └-variable y
      #|        
    ),
  )
}

///|
test "LocalFunction to_string Test - No Params" {
  let color = false
  let code =
    #|fn get_value() -> Int { return 42 ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse local function without parameters
  let (local_fn, _) = parse_local_function(tokens)
  inspect(
    local_fn.to_string(color~),
    content=(
      #|local function: get_value
      #|├-return: Int
      #|└-body: block
      #|        └-return statement
      #|          └-int literal 42
      #|        
    ),
  )
}

///|
test "LocalFunction to_string Test - Complex Body" {
  let color = false
  let code =
    #|fn factorial(n) { let mut result = 1 ; let mut i = n ; return result ; }
  let tokens = @lexer.tokenize(code, source_file="test")

  // Parse local function with complex body
  let (local_fn, _) = parse_local_function(tokens)
  inspect(
    local_fn.to_string(color~),
    content=(
      #|local function: factorial
      #|├-params:
      #|│ └-n
      #|└-body: block
      #|        ├-let mut statement
      #|        │ ├-name: result
      #|        │ └-expr: int literal 1
      #|        ├-let mut statement
      #|        │ ├-name: i
      #|        │ └-expr: variable n
      #|        └-return statement
      #|          └-variable result
      #|        
    ),
  )
}
