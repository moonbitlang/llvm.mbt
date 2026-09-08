///|
/// Represents the MiniMoonBit typed AST node or context `LocalFunction`.
pub(all) struct LocalFunction {
  /// Stores the `fname` component of this typed AST value.
  fname : String
  /// Stores the `param_list` component of this typed AST value.
  param_list : Array[(String, Type)]
  /// Stores the `ret_ty` component of this typed AST value.
  ret_ty : Type
  /// Stores the `body` component of this typed AST value.
  body : BlockExpr
}

///|
/// Formats `LocalFunction` using MiniMoonBit typed AST notation.
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
      let (name, ty) = self.param_list[i]
      let ty_str = ty.kind.to_string()
      let ty_str = if color { @color.taint(ty_str, Green) } else { ty_str }
      let param_text = "\{name}: \{ty_str}"
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
  let ret_ty_str = self.ret_ty.kind.to_string()
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

  // Format body
  let body_str = self.body.to_string(color~)
  let body_lines = body_str.split("\n").map(sv => sv.to_owned()).to_array()
  let body_formatted = @parser.format_lines(
    body_lines,
    head_with="└-body: ",
    continue_with="        ",
  )
  result = "\{result}\n\{body_formatted}"
  result
}

///|
/// Type-checks the corresponding parser AST form through `check_local_function`.
pub fn Context::check_local_function(
  self : Context,
  func : @parser.LocalFunction,
) -> LocalFunction raise TypeCheckError {
  let param_types = []
  for param in func.param_list {
    let (_, param_type) = param
    let param_ty = match param_type {
      Some(ty) => self.check_parser_typekind(ty.kind)
      None => self.add_type_var()
    }
    param_types.push(param_ty)
  }
  let ret_ty = match func.ret_ty {
    Some(ty) => {
      let ty = self.check_parser_type(ty)
      ty.kind
    }
    None => {
      let kind = self.add_type_var()
      kind
    }
  }
  let parent_func_ret_ty = self.current_func_ret_ty
  self.set_current_func_ret_ty(ret_ty)
  let fty = Function(param_types, ret_ty)
  let fty = Type::{ kind: fty, mutable: false, }
  self.type_env.set(func.fname, fty)
  self.enter_scope()
  let param_list = []
  for i, param in func.param_list {
    let (param_name, _) = param
    let param_ty = Type::{ kind: param_types[i], mutable: false, }
    self.type_env.set(param_name, param_ty)
    param_list.push((param_name, param_ty))
  }
  let checked_block = self.check_block_expr(func.body)
  if !self.is_type_compatible(checked_block.ty, ret_ty) {
    raise TypeCheckError(
      "Body and Return Type: Type mismatch in local function \{func.fname}",
    )
  }
  self.exit_scope()
  let ret_ty = self.ensure_type(ret_ty)
  let local_func = LocalFunction::{
    fname: func.fname,
    param_list,
    ret_ty: { kind: ret_ty, mutable: false, },
    body: checked_block,
  }
  self.current_func_ret_ty = parent_func_ret_ty
  local_func
}

///|
test "LocalFunction to_string Test - With Types" {
  let color = false
  let ctx = Context::new()
  let code =
    #|fn multiply(x: Int, y: Int) -> Int { return x * y ; }
  let tokens = @lexer.tokenize(code)

  // Parse and check local function with parameter and return types
  let (parsed, _) = @parser.parse_local_function(tokens)
  let checked = ctx.check_local_function(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|local function: multiply
      #|├-params:
      #|│ ├-x: Int
      #|│ └-y: Int
      #|├-return: Int
      #|└-body: block (Any)
      #|        └-return statement
      #|          └-binary expr: * (Int)
      #|            ├-variable x (Int)
      #|            └-variable y (Int)
      #|        
    ),
  )
}

///|
test "LocalFunction to_string Test - No Params" {
  let color = false
  let ctx = Context::new()
  let code =
    #|fn get_value() -> Int { return 42 ; }
  let tokens = @lexer.tokenize(code)

  // Parse and check local function without parameters
  let (parsed, _) = @parser.parse_local_function(tokens)
  let checked = ctx.check_local_function(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|local function: get_value
      #|├-return: Int
      #|└-body: block (Any)
      #|        └-return statement
      #|          └-int literal 42 (Int)
      #|        
    ),
  )
}

///|
test "LocalFunction to_string Test - Inferred Types" {
  let color = false
  let ctx = Context::new()
  let code =
    #|fn add(x, y) { return x + y ; }
  let tokens = @lexer.tokenize(code)

  // Parse and check local function with inferred types
  let (parsed, _) = @parser.parse_local_function(tokens)
  let checked = ctx.check_local_function(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|local function: add
      #|├-params:
      #|│ ├-x: TypeVar(0)
      #|│ └-y: TypeVar(1)
      #|├-return: TypeVar(1)
      #|└-body: block (Any)
      #|        └-return statement
      #|          └-binary expr: + (TypeVar(0))
      #|            ├-variable x (TypeVar(0))
      #|            └-variable y (TypeVar(1))
      #|        
    ),
  )
}
