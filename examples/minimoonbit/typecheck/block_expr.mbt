///|
/// Represents the MiniMoonBit typed AST node or context `BlockExpr`.
pub(all) struct BlockExpr {
  /// Stores the `stmts` component of this typed AST value.
  stmts : Array[Stmt]
  /// Stores the `ty` component of this typed AST value.
  ty : TypeKind
}

///|
/// Formats `BlockExpr` using MiniMoonBit typed AST notation.
pub impl Show for BlockExpr with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `BlockExpr` value with optional ANSI coloring.
pub fn BlockExpr::to_string(self : Self, color? : Bool = true) -> String {
  let prefix = "block"
  let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
  let ty_str = self.ty.to_string()
  let ty_str = if color { @color.taint(ty_str, Green) } else { ty_str }
  let prefix_with_type = "\{prefix} (\{ty_str})"
  if self.stmts.length() == 0 {
    return "\{prefix_with_type} (empty)"
  }
  let mut result = prefix_with_type
  for i = 0; i < self.stmts.length(); i = i + 1 {
    let stmt = self.stmts[i]
    let stmt_str = stmt.to_string(color~)
    let stmt_lines = stmt_str.split("\n").map(sv => sv.to_owned()).to_array()
    let is_last = i == self.stmts.length() - 1
    let stmt_formatted = if is_last {
      @parser.format_lines(stmt_lines, head_with="└-", continue_with="  ")
    } else {
      @parser.format_lines(stmt_lines, head_with="├-", continue_with="│ ")
    }
    result = "\{result}\n\{stmt_formatted}"
  }
  result + "\n"
}

///|
/// Type-checks the corresponding parser AST form through `check_block_expr`.
pub fn Context::check_block_expr(
  self : Context,
  block_expr : @parser.BlockExpr,
) -> BlockExpr {
  self.enter_scope()
  let checked_stmts = []
  for stmt in block_expr.stmts {
    let checked_stmt = try self.check_stmt(stmt) catch {
      TypeCheckError(msg) => {
        self.throw_(stmt.toks[0], msg, Error)
        continue
      }
    } noraise {
      s => s
    }
    checked_stmts.push(checked_stmt)
  }
  self.exit_scope()
  let tykind = if checked_stmts.length() > 0 {
    match checked_stmts[checked_stmts.length() - 1].kind {
      StmtKind::ExprStmt(expr) => expr.ty
      StmtKind::ReturnStmt(_) => Any
      _ => Unit
    }
  } else {
    Unit
  }
  BlockExpr::{ stmts: checked_stmts, ty: tykind, }
}

///|
test "BlockExpr to_string Test - Empty" {
  let color = false
  let block_expr = BlockExpr::{ stmts: [], ty: TypeKind::Unit, }
  inspect(block_expr.to_string(color~), content="block (Unit) (empty)")
}

///|
test "BlockExpr to_string Test - Single Statement" {
  let color = false
  let ctx = Context::new()
  let code =
    #|{ let x = 42 ; }
  let tokens = @lexer.tokenize(code)

  // Test single statement block: { let x = 42 }
  let (parsed, _) = @parser.parse_block_expr(tokens[:])
  let checked = ctx.check_block_expr(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|block (Unit)
      #|└-let statement
      #|  ├-pattern: ident pattern x
      #|  ├-type: : Int
      #|  └-expr: int literal 42 (Int)
      #|
    ),
  )
}

///|
test "BlockExpr to_string Test - Multiple Statements" {
  let color = false
  let ctx = Context::new()
  let code =
    #|{ let mut x = 42 ; let mut y = 10 ; x = y + 1 ; }
  let tokens = @lexer.tokenize(code)

  // Test multiple statements: { let mut x = 42 ; let mut y = 10 ; x = y + 1 }
  let (parsed, _) = @parser.parse_block_expr(tokens[:])
  let checked = ctx.check_block_expr(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|block (Unit)
      #|├-let mut statement
      #|│ ├-name: x
      #|│ ├-type: : Int
      #|│ └-expr: int literal 42 (Int)
      #|├-let mut statement
      #|│ ├-name: y
      #|│ ├-type: : Int
      #|│ └-expr: int literal 10 (Int)
      #|└-assign statement: =
      #|  ├-lvalue: lvalue x (Int)
      #|  └-expr: binary expr: + (Int)
      #|          ├-variable y (Int)
      #|          └-int literal 1 (Int)
      #|
    ),
  )
}

///|
test "BlockExpr to_string Test - With Return" {
  let color = false
  let ctx = Context::new()
  ctx.current_func_ret_ty = Some(TypeKind::Int)
  let code =
    #|{ let x = 42 ; return x ; }
  let tokens = @lexer.tokenize(code)

  // Test with return: { let x = 42 ; return x }
  let (parsed, _) = @parser.parse_block_expr(tokens[:])
  let checked = ctx.check_block_expr(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|block (Any)
      #|├-let statement
      #|│ ├-pattern: ident pattern x
      #|│ ├-type: : Int
      #|│ └-expr: int literal 42 (Int)
      #|└-return statement
      #|  └-variable x (Int)
      #|
    ),
  )
}
