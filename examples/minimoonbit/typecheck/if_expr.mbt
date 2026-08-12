///|
/// Represents the MiniMoonBit typed AST node or context `IfExpr`.
pub(all) struct IfExpr {
  /// Stores the `cond` component of this typed AST value.
  cond : Expr
  /// Stores the `then_block` component of this typed AST value.
  then_block : BlockExpr
  /// Stores the `else_block` component of this typed AST value.
  else_block : Either[IfExpr, BlockExpr]?
  /// Stores the `ty` component of this typed AST value.
  ty : TypeKind
}

///|
/// Formats `IfExpr` using MiniMoonBit typed AST notation.
pub impl Show for IfExpr with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `IfExpr` value with optional ANSI coloring.
pub fn IfExpr::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "if expression"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
  let ty_str = self.ty.to_string()
  let ty_str = if color { @color.taint(ty_str, Green) } else { ty_str }
  let prefix_with_type = "\{prefix} (\{ty_str})"

  // Format condition
  let cond_str = self.cond.to_string(color~)
  let cond_lines = cond_str
    .split("\n")
    .map(fn(sv) { sv.to_string() })
    .to_array()
  let cond_formatted = @parser.format_lines(
    cond_lines,
    head_with="├-cond: ",
    continue_with="│       ",
  )

  // Format then block
  let then_str = self.then_block.to_string(color~)
  let then_lines = then_str
    .split("\n")
    .map(fn(sv) { sv.to_string() })
    .to_array()
  match self.else_block {
    None => {
      let then_formatted = @parser.format_lines(
        then_lines,
        head_with="└-then: ",
        continue_with="        ",
      )
      "\{prefix_with_type}\n\{cond_formatted}\n\{then_formatted}"
    }
    Some(Either::Left(else_if)) => {
      let then_formatted = @parser.format_lines(
        then_lines,
        head_with="├-then: ",
        continue_with="│       ",
      )
      let else_if_str = else_if.to_string(color~)
      let else_if_lines = else_if_str
        .split("\n")
        .map(fn(sv) { sv.to_string() })
        .to_array()
      let else_if_formatted = @parser.format_lines(
        else_if_lines,
        head_with="└-else: ",
        continue_with="        ",
      )
      "\{prefix_with_type}\n\{cond_formatted}\n\{then_formatted}\n\{else_if_formatted}"
    }
    Some(Either::Right(else_block)) => {
      let then_formatted = @parser.format_lines(
        then_lines,
        head_with="├-then: ",
        continue_with="│       ",
      )
      let else_str = else_block.to_string(color~)
      let else_lines = else_str
        .split("\n")
        .map(fn(sv) { sv.to_string() })
        .to_array()
      let else_formatted = @parser.format_lines(
        else_lines,
        head_with="└-else: ",
        continue_with="        ",
      )
      "\{prefix_with_type}\n\{cond_formatted}\n\{then_formatted}\n\{else_formatted}"
    }
  }
}

///|
/// Type-checks the corresponding parser AST form through `check_if_expr`.
pub fn Context::check_if_expr(
  self : Context,
  if_expr : @parser.IfExpr,
) -> IfExpr {
  let checked_cond = self.check_expr(if_expr.cond)
  // Ensure the condition is of boolean type
  if !(checked_cond.ty is Bool) {
    let msg = "If condition must be of boolean type"
    self.throw_(if_expr.toks[0], msg, Error)
  }
  let checked_then_block = self.check_block_expr(if_expr.then_block)
  let then_type = checked_then_block.ty
  let checked_else_block = match if_expr.else_block {
    Some(Left(else_if_expr)) => {
      let checked_else_if = self.check_if_expr(else_if_expr)
      if !self.is_type_compatible(then_type, checked_else_if.ty) {
        let msg = "Type mismatch between then block and else-if block"
        self.throw_(else_if_expr.toks[0], msg, Error)
      }
      Some(Either::Left(checked_else_if))
    }
    Some(Right(else_block)) => {
      let checked_else = self.check_block_expr(else_block)
      if !self.is_type_compatible(then_type, checked_else.ty) {
        let msg = "Type mismatch between then block and else block"
        self.throw_(else_block.toks[0], msg, Error)
      }
      Some(Right(checked_else))
    }
    None => None
  }
  let ty = self.ensure_type(then_type)
  IfExpr::{
    cond: checked_cond,
    then_block: checked_then_block,
    else_block: checked_else_block,
    ty,
  }
}

///|
test "IfExpr to_string Test - Simple" {
  let color = false
  let ctx = Context::new()
  ctx.type_env.set("x", { kind: TypeKind::Bool, mutable: false })
  let code =
    #|if x { 1 }
  let tokens = @lexer.tokenize(code)

  // Test simple if without else: if x { 1 }
  let (parsed, _) = @parser.parse_if_expr(tokens[:])
  let checked = ctx.check_if_expr(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|if expression (Int)
      #|├-cond: variable x (Bool)
      #|└-then: block (Int)
      #|        └-int literal 1 (Int)
      #|        
    ),
  )
}

///|
test "IfExpr to_string Test - With Else" {
  let color = false
  let ctx = Context::new()
  ctx.type_env.set("x", { kind: TypeKind::Int, mutable: false })
  let code =
    #|if x > 0 { 1 } else { 0 }
  let tokens = @lexer.tokenize(code)

  // Test if-else: if x > 0 { 1 } else { 0 }
  let (parsed, _) = @parser.parse_if_expr(tokens[:])
  let checked = ctx.check_if_expr(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|if expression (Int)
      #|├-cond: binary expr: > (Bool)
      #|│       ├-variable x (Int)
      #|│       └-int literal 0 (Int)
      #|├-then: block (Int)
      #|│       └-int literal 1 (Int)
      #|│       
      #|└-else: block (Int)
      #|        └-int literal 0 (Int)
      #|        
    ),
  )
}

///|
test "IfExpr to_string Test - Else If" {
  let color = false
  let ctx = Context::new()
  ctx.type_env.set("x", { kind: TypeKind::Int, mutable: false })
  let code =
    #|if x > 0 { 1 } else if x < 0 { 2 } else { 0 }
  let tokens = @lexer.tokenize(code)

  // Test else-if: if x > 0 { 1 } else if x < 0 { 2 } else { 0 }
  let (parsed, _) = @parser.parse_if_expr(tokens[:])
  let checked = ctx.check_if_expr(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|if expression (Int)
      #|├-cond: binary expr: > (Bool)
      #|│       ├-variable x (Int)
      #|│       └-int literal 0 (Int)
      #|├-then: block (Int)
      #|│       └-int literal 1 (Int)
      #|│       
      #|└-else: if expression (Int)
      #|        ├-cond: binary expr: < (Bool)
      #|        │       ├-variable x (Int)
      #|        │       └-int literal 0 (Int)
      #|        ├-then: block (Int)
      #|        │       └-int literal 2 (Int)
      #|        │       
      #|        └-else: block (Int)
      #|                └-int literal 0 (Int)
      #|                
    ),
  )
}
