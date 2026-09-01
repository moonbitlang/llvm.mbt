///|
/// Represents the MiniMoonBit typed AST node or context `ForStmt`.
pub(all) struct ForStmt {
  /// Stores the `inits` component of this typed AST value.
  inits : Array[(String, Expr)]
  /// Stores the `cond` component of this typed AST value.
  cond : Expr // if parser cond is None, this is Bool::true
  /// Stores the `steps` component of this typed AST value.
  steps : Array[(String, AssignOp, Expr)]
  /// Stores the `body` component of this typed AST value.
  body : BlockExpr
}

///|
/// Formats `ForStmt` using MiniMoonBit typed AST notation.
pub impl Show for ForStmt with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `ForStmt` value with optional ANSI coloring.
pub fn ForStmt::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "for statement"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
  let mut result = prefix

  // Format inits
  if self.inits.length() > 0 {
    let inits_prefix = "inits:"
    let inits_prefix = if color {
      @color.taint(inits_prefix, Blue)
    } else {
      inits_prefix
    }
    result = "\{result}\n├-\{inits_prefix}"
    for i = 0; i < self.inits.length(); i = i + 1 {
      let (name, expr) = self.inits[i]
      let expr_str = expr.to_string(color~)
      let expr_lines = expr_str.split("\n").map(sv => sv.to_owned()).to_array()
      let is_last_init = i == self.inits.length() - 1
      let expr_formatted = if is_last_init {
        @parser.format_lines(
          expr_lines,
          head_with="└-\{name} = ",
          continue_with="  ",
        )
      } else {
        @parser.format_lines(
          expr_lines,
          head_with="├-\{name} = ",
          continue_with="│ ",
        )
      }
      result = "\{result}\n│ \{expr_formatted}"
    }
  }

  // Format condition
  let cond_str = self.cond.to_string(color~)
  let cond_lines = cond_str.split("\n").map(sv => sv.to_owned()).to_array()
  let cond_formatted = @parser.format_lines(
    cond_lines,
    head_with="├-cond: ",
    continue_with="│       ",
  )
  result = "\{result}\n\{cond_formatted}"

  // Format steps
  if self.steps.length() > 0 {
    let steps_prefix = "steps:"
    let steps_prefix = if color {
      @color.taint(steps_prefix, Blue)
    } else {
      steps_prefix
    }
    result = "\{result}\n├-\{steps_prefix}"
    for i = 0; i < self.steps.length(); i = i + 1 {
      let (name, op, expr) = self.steps[i]
      let op_str = match op {
        Assign => "="
        PlusAssign => "+="
        MinusAssign => "-="
        MultAssign => "*="
        DivAssign => "/="
        ModAssign => "%="
      }
      let expr_str = expr.to_string(color~)
      let expr_lines = expr_str.split("\n").map(sv => sv.to_owned()).to_array()
      let is_last_step = i == self.steps.length() - 1
      let expr_formatted = if is_last_step {
        @parser.format_lines(
          expr_lines,
          head_with="└-\{name} \{op_str} ",
          continue_with="  ",
        )
      } else {
        @parser.format_lines(
          expr_lines,
          head_with="├-\{name} \{op_str} ",
          continue_with="│ ",
        )
      }
      result = "\{result}\n│ \{expr_formatted}"
    }
  }

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
/// Type-checks the corresponding parser AST form through `check_for_stmt`.
pub fn Context::check_for_stmt(
  self : Context,
  for_stmt : @parser.ForStmt,
) -> ForStmt raise TypeCheckError {
  // Enter a new scope for the for loop
  self.enter_scope()

  // Check and bind init variables (they are mutable)
  let checked_inits : Array[(String, Expr)] = Array::new()
  for init in for_stmt.inits {
    let (name, init_expr) = init
    let checked_expr = self.check_expr(init_expr)
    let type_kind = self.ensure_type(checked_expr.ty)
    let ty = Type::{ kind: type_kind, mutable: true, }
    self.type_env.set(name, ty)
    checked_inits.push((name, checked_expr))
  }

  // Check condition expression (if exists, must be Bool)
  let checked_cond = if for_stmt.cond is Some(cond_expr) {
    let checked = self.check_expr(cond_expr)
    if !(checked.ty is Bool) {
      raise TypeCheckError("For loop condition must be of boolean type")
    }
    checked
  } else {
    // If no condition, use Bool::true
    Expr::{
      kind: ExprKind::ApplyExpr(ApplyExpr::{
        kind: ApplyExprKind::AtomExpr(AtomExpr::{
          kind: AtomExprKind::Bool(true),
          ty: Bool,
          toks: [],
        }),
        ty: Bool,
        toks: [],
      }),
      ty: Bool,
      toks: [],
    }
  }

  // Check step statements
  let checked_steps : Array[(String, AssignOp, Expr)] = Array::new()
  for step in for_stmt.steps {
    let (name, op, step_expr) = step
    // Verify the variable exists in the current scope
    guard self.type_env.get(name) is Some(var_ty) else {
      raise TypeCheckError("Undefined variable in for loop step: \{name}")
    }
    guard var_ty.mutable is true else {
      raise TypeCheckError(
        "Cannot assign to immutable variable in for loop step: \{name}",
      )
    }
    let checked_expr = self.check_expr(step_expr)
    guard self.is_type_compatible(var_ty.kind, checked_expr.ty) else {
      raise TypeCheckError(
        "Type mismatch in for loop step assignment, variable type: \{var_ty.kind}, expression type: \{checked_expr.ty}",
      )
    }
    let typed_op = AssignOp::from_parser_assign_op(op)
    let ty = self.ensure_type(var_ty.kind)
    if !(typed_op is Assign) && !(ty is (Int | Double)) {
      raise TypeCheckError(
        "Compound assignment operators in for loop can only be used with Int or Double types",
      )
    }
    checked_steps.push((name, typed_op, checked_expr))
  }

  // Check body block
  let checked_body = self.check_block_expr(for_stmt.body)

  // Exit the scope
  self.exit_scope()
  ForStmt::{
    inits: checked_inits,
    cond: checked_cond,
    steps: checked_steps,
    body: checked_body,
  }
}

///|
test "ForStmt to_string Test - Simple" {
  let color = false
  let ctx = Context::new()
  let code =
    #|for i = 0; i < 10; i += 1 { let x = i ; }
  let tokens = @lexer.tokenize(code)

  // Parse and check simple for loop
  let (parsed, _) = @parser.parse_for_stmt(tokens)
  let checked = ctx.check_for_stmt(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|for statement
      #|├-inits:
      #|│ └-i = int literal 0 (Int)
      #|├-cond: binary expr: < (Bool)
      #|│       ├-variable i (Int)
      #|│       └-int literal 10 (Int)
      #|├-steps:
      #|│ └-i += int literal 1 (Int)
      #|└-body: block (Unit)
      #|        └-let statement
      #|          ├-pattern: ident pattern x
      #|          ├-type: : Int
      #|          └-expr: variable i (Int)
      #|        
    ),
  )
}

///|
test "ForStmt to_string Test - Multiple Inits and Steps" {
  let color = false
  let ctx = Context::new()
  let code =
    #|for i = 0, j = 10; i < j; i += 1, j -= 1 { let sum = i + j ; }
  let tokens = @lexer.tokenize(code)

  // Parse and check for loop with multiple inits and steps
  let (parsed, _) = @parser.parse_for_stmt(tokens)
  let checked = ctx.check_for_stmt(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|for statement
      #|├-inits:
      #|│ ├-i = int literal 0 (Int)
      #|│ └-j = int literal 10 (Int)
      #|├-cond: binary expr: < (Bool)
      #|│       ├-variable i (Int)
      #|│       └-variable j (Int)
      #|├-steps:
      #|│ ├-i += int literal 1 (Int)
      #|│ └-j -= int literal 1 (Int)
      #|└-body: block (Unit)
      #|        └-let statement
      #|          ├-pattern: ident pattern sum
      #|          ├-type: : Int
      #|          └-expr: binary expr: + (Int)
      #|                  ├-variable i (Int)
      #|                  └-variable j (Int)
      #|        
    ),
  )
}
