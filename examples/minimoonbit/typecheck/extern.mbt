///|
/// Represents the MiniMoonBit typed AST node or context `ExternFunction`.
pub(all) struct ExternFunction {
  /// Stores the `fname` component of this typed AST value.
  fname : String
  /// Stores the `param_list` component of this typed AST value.
  param_list : Array[Param]
  /// Stores the `ret_ty` component of this typed AST value.
  ret_ty : TypeKind
  /// Stores the `ffi_name` component of this typed AST value.
  ffi_name : String
}

///|
/// Formats `ExternFunction` using MiniMoonBit typed AST notation.
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
        @parser.format_lines([param_text], head_with="└-", continue_with="  ")
      } else {
        @parser.format_lines(
          [param_text],
          head_with="├-",
          continue_with="│ ",
        )
      }
      result = "\{result}\n│ \{param_formatted}"
    }
  }

  // Format return type
  let ret_ty_str = self.ret_ty.to_string()
  let ret_ty_str = if color {
    @color.taint(ret_ty_str, Green)
  } else {
    ret_ty_str
  }
  let ret_text = "return: \{ret_ty_str}"
  let ret_formatted = @parser.format_lines(
    [ret_text],
    head_with="├-",
    continue_with="│ ",
  )
  result = "\{result}\n\{ret_formatted}"

  // Format FFI name
  let ffi_text = "ffi: \"\{self.ffi_name}\"\n"
  let ffi_formatted = @parser.format_lines(
    [ffi_text],
    head_with="└-",
    continue_with="  ",
  )
  result = "\{result}\n\{ffi_formatted}\n"
  result
}

///|
/// Type-checks the corresponding parser AST form through `check_extern_function`.
pub fn Context::check_extern_function(
  self : Context,
  func : @parser.ExternFunction,
) -> ExternFunction raise TypeCheckError {
  guard self.func_types.get(func.fname) is Some(Function(param_types, ret_ty)) else {
    raise TypeCheckError("Function not found in environment: \{func.fname}")
  }
  let param_list = Array::new()
  for i, param in func.param_list {
    let { name, .. } = param
    let param_ty = { kind: param_types[i], mutable: false }
    self.type_env.set(name, param_ty)
    param_list.push(Param::{ name, ty: param_ty.kind })
  }
  ExternFunction::{
    fname: func.fname,
    param_list,
    ret_ty,
    ffi_name: func.ffi_name,
  }
}

///|
test "ExternFunction to_string Test - Simple" {
  let color = false
  let ctx = Context::new()
  ctx.func_types.set("sqrt", Function([Double], Double))
  let code =
    #|extern "c" fn sqrt(x: Double) -> Double = "sqrt" ;
  let tokens = @lexer.tokenize(code)

  // Parse and check simple extern function
  let (parsed, _) = @parser.parse_extern_function(tokens)
  let checked = ctx.check_extern_function(parsed)
  inspect(
    checked.to_string(color~),
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
  let ctx = Context::new()
  ctx.func_types.set("pow", Function([Double, Double], Double))
  let code =
    #|extern "c" fn pow(x: Double, y: Double) -> Double = "pow" ;
  let tokens = @lexer.tokenize(code)

  // Parse and check extern function with multiple parameters
  let (parsed, _) = @parser.parse_extern_function(tokens)
  let checked = ctx.check_extern_function(parsed)
  inspect(
    checked.to_string(color~),
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
