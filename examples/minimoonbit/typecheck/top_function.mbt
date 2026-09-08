///|
/// Represents the MiniMoonBit typed AST node or context `Param`.
pub(all) struct Param {
  /// Stores the `name` component of this typed AST value.
  name : String
  /// Stores the `ty` component of this typed AST value.
  ty : TypeKind
}

///|
/// Formats `Param` using MiniMoonBit typed AST notation.
pub impl Show for Param with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `Param` value with optional ANSI coloring.
pub fn Param::to_string(self : Self, color? : Bool = true) -> String {
  let ty_str = self.ty.to_string()
  let ty_str = if color { @color.taint(ty_str, Green) } else { ty_str }
  "\{self.name}: \{ty_str}"
}

///|
/// Represents the MiniMoonBit typed AST node or context `TopFunction`.
pub(all) struct TopFunction {
  /// Stores the `fname` component of this typed AST value.
  fname : String
  /// Stores the `param_list` component of this typed AST value.
  param_list : Array[Param]
  /// Stores the `ret_ty` component of this typed AST value.
  ret_ty : TypeKind
  /// Stores the `body` component of this typed AST value.
  body : BlockExpr
}

///|
/// Formats `TopFunction` using MiniMoonBit typed AST notation.
pub impl Show for TopFunction with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `TopFunction` value with optional ANSI coloring.
pub fn TopFunction::to_string(self : Self, color? : Bool = true) -> String {
  let full_name = "Top function: \{self.fname}"
  let prefix = if color { @color.taint(full_name, Magenta) } else { full_name }
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

  // Format body
  let body_str = self.body.to_string(color~)
  let body_lines = body_str.split("\n").map(sv => sv.to_owned()).to_array()
  let body_formatted = @parser.format_lines(body_lines)
  result = "\{result}\n\{body_formatted}\n"
  result
}

///|
/// Type-checks the corresponding parser AST form through `check_top_function`.
pub fn Context::check_top_function(
  self : Context,
  func : @parser.TopFunction,
) -> TopFunction raise TypeCheckError {
  let func_whole_name = func.whole_name()
  guard self.func_types.get(func_whole_name)
    is Some(Function(param_types, ret_ty)) else {
    raise TypeCheckError("Function not found in environment: \{func.fname}")
  }
  self.enter_scope()
  let param_list = Array::Array(capacity=0)
  for i, param in func.param_list {
    let { name, .. } = param
    let param_ty = { kind: param_types[i], mutable: false, }
    self.type_env.set(name, param_ty)
    param_list.push(Param::{ name, ty: param_ty.kind, })
  }
  if !(func.typeTag is "") {
    guard self.struct_defs.get(func.typeTag) is Some(struct_def) else {
      raise TypeCheckError(
        "Struct type not found for method: \{func.typeTag}::\{func.fname}",
      )
    }
    if param_list.get(0) is Some(p) && p.ty is Struct(s) && s == func.typeTag {
      struct_def.methods.set(func.fname, Function(param_types, ret_ty))
    }
  }
  self.set_current_func_ret_ty(ret_ty)
  let checked_block = self.check_block_expr(func.body)
  if !self.is_type_compatible(checked_block.ty, ret_ty) {
    raise TypeCheckError(
      "Body and Return Type: Type mismatch in top-level function \{func.fname}",
    )
  }
  self.exit_scope()
  self.current_func_ret_ty = None
  TopFunction::{
    fname: func_whole_name,
    param_list,
    ret_ty,
    body: checked_block,
  }
}

///|
test "TopFunction to_string Test - Simple" {
  let color = false
  let ctx = Context::new()
  ctx.func_types.set("add", Function([Int, Int], Int))
  ctx.type_env.set("add", Type::{
    kind: Function([Int, Int], Int),
    mutable: false,
  })
  let code =
    #|fn add(x: Int, y: Int) -> Int { return x + y ; }
  let tokens = @lexer.tokenize(code)

  // Parse and check simple top function
  let (parsed, _) = @parser.parse_top_function(tokens)
  let checked = ctx.check_top_function(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|Top function: add
      #|├-params:
      #|│ ├-x: Int
      #|│ └-y: Int
      #|├-return: Int
      #|└-block (Any)
      #|  └-return statement
      #|    └-binary expr: + (Int)
      #|      ├-variable x (Int)
      #|      └-variable y (Int)
      #|  
      #|
    ),
  )
}

///|
test "TopFunction to_string Test - Main" {
  let color = false
  let ctx = Context::new()
  ctx.func_types.set("main", Function([], Unit))
  ctx.type_env.set("main", Type::{ kind: Function([], Unit), mutable: false, })
  let code =
    #|fn main { let x = 42 ; }
  let tokens = @lexer.tokenize(code)

  // Parse and check main function
  let (parsed, _) = @parser.parse_top_function(tokens)
  let checked = ctx.check_top_function(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|Top function: main
      #|├-return: Unit
      #|└-block (Unit)
      #|  └-let statement
      #|    ├-pattern: ident pattern x
      #|    ├-type: : Int
      #|    └-expr: int literal 42 (Int)
      #|  
      #|
    ),
  )
}
