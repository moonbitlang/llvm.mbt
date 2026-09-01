///|
/// Represents the MiniMoonBit typed AST node or context `Expr`.
pub(all) struct Expr {
  /// Stores the `kind` component of this typed AST value.
  kind : ExprKind
  /// Stores the `ty` component of this typed AST value.
  ty : TypeKind
  /// Stores the `toks` component of this typed AST value.
  toks : ArrayView[Token]
}

///|
/// Formats `Expr` using MiniMoonBit typed AST notation.
pub impl Show for Expr with fn output(self, logger) {
  let s = self.to_string(color=true)
  logger.write_string(s)
}

///|
/// Renders this `Expr` value with optional ANSI coloring.
pub fn Expr::to_string(self : Self, color? : Bool = true) -> String {
  match self.kind {
    // For ApplyExpr case, directly return apply_expr's to_string without adding extra type
    ApplyExpr(apply_expr) => apply_expr.to_string(color~)
    NotExpr(expr) => {
      let prefix = "unary operator !"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      let ty_str = self.ty.to_string()
      let ty_str = if color { @color.taint(ty_str, Green) } else { ty_str }
      let prefix_with_type = "\{prefix} (\{ty_str})"
      let inner_str = expr.to_string(color~)
      let lines = inner_str.split("\n").map(sv => sv.to_owned()).to_array()
      let formatted = @parser.format_lines(lines)
      "\{prefix_with_type}\n\{formatted}"
    }
    NegExpr(expr) => {
      let prefix = "unary operator -"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      let ty_str = self.ty.to_string()
      let ty_str = if color { @color.taint(ty_str, Green) } else { ty_str }
      let prefix_with_type = "\{prefix} (\{ty_str})"
      let inner_str = expr.to_string(color~)
      let lines = inner_str.split("\n").map(sv => sv.to_owned()).to_array()
      let formatted = @parser.format_lines(lines)
      "\{prefix_with_type}\n\{formatted}"
    }
    BinaryExpr(op, left, right) => {
      let op_str = match op {
        Add => "+"
        Sub => "-"
        Mul => "*"
        Div => "/"
        Mod => "%"
        ShiftLeft => "<<"
        ShiftRight => ">>"
        Eq => "=="
        NE => "!="
        LT => "<"
        GT => ">"
        LE => "<="
        GE => ">="
        And => "&&"
        Or => "||"
        BitAnd => "&"
        BitOr => "|"
      }
      let prefix = "binary expr: \{op_str}"
      let prefix = if color { @color.taint(prefix, Magenta) } else { prefix }
      let ty_str = self.ty.to_string()
      let ty_str = if color { @color.taint(ty_str, Green) } else { ty_str }
      let prefix_with_type = "\{prefix} (\{ty_str})"
      let left_str = left.to_string(color~)
      let right_str = right.to_string(color~)
      let left_lines = left_str.split("\n").map(sv => sv.to_owned()).to_array()
      let right_lines = right_str
        .split("\n")
        .map(sv => sv.to_owned())
        .to_array()
      let left_formatted = @parser.format_lines(
        left_lines,
        head_with="├-",
        continue_with="│ ",
      )
      let right_formatted = @parser.format_lines(
        right_lines,
        head_with="└-",
        continue_with="  ",
      )
      "\{prefix_with_type}\n\{left_formatted}\n\{right_formatted}"
    }
    BlockExpr(block_expr) => block_expr.to_string(color~)
    IfExpr(if_expr) => if_expr.to_string(color~)
    MatchExpr(match_expr) => match_expr.to_string(color~)
  }
}

///|
/// Enumerates the typed forms represented by `ExprKind`.
pub(all) enum ExprKind {
  /// Represents the `ApplyExpr` typed AST form.
  ApplyExpr(ApplyExpr)
  /// Represents the `BlockExpr` typed AST form.
  BlockExpr(BlockExpr)
  /// Represents the `NotExpr` typed AST form.
  NotExpr(Expr)
  /// Represents the `NegExpr` typed AST form.
  NegExpr(Expr)
  /// Represents the `BinaryExpr` typed AST form.
  BinaryExpr(BinaryOp, Expr, Expr)
  /// Represents the `IfExpr` typed AST form.
  IfExpr(IfExpr)
  /// Represents the `MatchExpr` typed AST form.
  MatchExpr(MatchExpr)
}

///|
/// Formats an `ExprKind` using constructor notation.
pub impl Show for ExprKind with fn output(self, logger) {
  match self {
    ApplyExpr(expr) => {
      logger.write_string("ApplyExpr(")
      logger.write_object(expr)
      logger.write_string(")")
    }
    BlockExpr(expr) => {
      logger.write_string("BlockExpr(")
      logger.write_object(expr)
      logger.write_string(")")
    }
    NotExpr(expr) => {
      logger.write_string("NotExpr(")
      logger.write_object(expr)
      logger.write_string(")")
    }
    NegExpr(expr) => {
      logger.write_string("NegExpr(")
      logger.write_object(expr)
      logger.write_string(")")
    }
    BinaryExpr(op, left, right) => {
      logger.write_string("BinaryExpr(")
      logger.write_object(op)
      logger.write_string(", ")
      logger.write_object(left)
      logger.write_string(", ")
      logger.write_object(right)
      logger.write_string(")")
    }
    IfExpr(expr) => {
      logger.write_string("IfExpr(")
      logger.write_object(expr)
      logger.write_string(")")
    }
    MatchExpr(expr) => {
      logger.write_string("MatchExpr(")
      logger.write_object(expr)
      logger.write_string(")")
    }
  }
}

///|
/// Enumerates the typed forms represented by `BinaryOp`.
pub(all) enum BinaryOp {
  /// Represents the `Add` typed AST form.
  Add // +
  /// Represents the `Sub` typed AST form.
  Sub // -
  /// Represents the `Mul` typed AST form.
  Mul // *
  /// Represents the `Div` typed AST form.
  Div // /
  /// Represents the `Mod` typed AST form.
  Mod // %
  /// Represents the `ShiftLeft` typed AST form.
  ShiftLeft // <<
  /// Represents the `ShiftRight` typed AST form.
  ShiftRight // >>
  /// Represents the `Eq` typed AST form.
  Eq // ==
  /// Represents the `NE` typed AST form.
  NE // !=
  /// Represents the `LT` typed AST form.
  LT // <
  /// Represents the `GT` typed AST form.
  GT // >
  /// Represents the `LE` typed AST form.
  LE // <=
  /// Represents the `GE` typed AST form.
  GE // >=
  /// Represents the `And` typed AST form.
  And // &&
  /// Represents the `Or` typed AST form.
  Or // ||
  /// Represents the `BitAnd` typed AST form.
  BitAnd // &
  /// Represents the `BitOr` typed AST form.
  BitOr // |
} derive(Eq)

///|
/// Formats a `BinaryOp` using its constructor name.
pub impl Show for BinaryOp with fn output(self, logger) {
  let name = match self {
    Add => "Add"
    Sub => "Sub"
    Mul => "Mul"
    Div => "Div"
    Mod => "Mod"
    ShiftLeft => "ShiftLeft"
    ShiftRight => "ShiftRight"
    Eq => "Eq"
    NE => "NE"
    LT => "LT"
    GT => "GT"
    LE => "LE"
    GE => "GE"
    And => "And"
    Or => "Or"
    BitAnd => "BitAnd"
    BitOr => "BitOr"
  }
  logger.write_string(name)
}

///|
fn binop_is_cmp(bin_op : BinaryOp) -> Bool {
  match bin_op {
    Eq => true
    NE => true
    LT => true
    GT => true
    LE => true
    GE => true
    _ => false
  }
}

///|
fn binop_is_shift(bin_op : BinaryOp) -> Bool {
  bin_op is (ShiftLeft | ShiftRight)
}

///|
fn binop_is_bitandor(bin_op : BinaryOp) -> Bool {
  bin_op is (BitAnd | BitOr)
}

///|
fn binop_is_logical(bin_op : BinaryOp) -> Bool {
  bin_op is (And | Or)
}

///|
fn binop_is_arithmetic(bin_op : BinaryOp) -> Bool {
  match bin_op {
    Add => true
    Sub => true
    Mul => true
    Div => true
    Mod => true
    _ => false
  }
}

///|
fn parser_binop_to_typecheck_binop(tok_bin_op : @parser.BinaryOp) -> BinaryOp {
  match tok_bin_op {
    Add => Add
    Sub => Sub
    Mul => Mul
    Div => Div
    Mod => Mod
    ShiftLeft => ShiftLeft
    ShiftRight => ShiftRight
    Eq => Eq
    NE => NE
    LT => LT
    GT => GT
    LE => LE
    GE => GE
    And => And
    Or => Or
    BitAnd => BitAnd
    BitOr => BitOr
  }
}

///|
/// Type-checks the corresponding parser AST form through `check_expr`.
pub fn Context::check_expr(self : Self, expr : @parser.Expr) -> Expr {
  match expr.kind {
    ApplyExpr(apply_expr) => {
      let apply_expr = self.check_apply_expr(apply_expr)
      Expr::{ kind: ApplyExpr(apply_expr), ty: apply_expr.ty, toks: expr.toks, }
    }
    NotExpr(inner_expr) => {
      let checked_inner = self.check_expr(inner_expr)
      // Type checking logic for NotExpr
      if self.is_type_compatible(checked_inner.ty, Bool) is false {
        let msg = "Operand of 'not' must be of type Bool" +
          " while got \{checked_inner.ty}"
        // self.throw_(expr.toks[0], msg, Error)
        println(msg)
        panic()
      }
      Expr::{ kind: NotExpr(checked_inner), ty: Bool, toks: expr.toks, }
    }
    NegExpr(inner_expr) => {
      let checked_inner = self.check_expr(inner_expr)
      // Type checking logic for NegExpr
      if !(checked_inner.ty is (Int | Int64 | Double | Float | TypeVar(_))) {
        let msg = "Operand of 'neg' must be of type Int, Int64, Double, or Float" +
          " while got \{checked_inner.ty}"
        self.throw_(expr.toks[0], msg, Error)
      }
      Expr::{
        kind: NegExpr(checked_inner),
        ty: checked_inner.ty,
        toks: expr.toks,
      }
    }
    BinaryExpr(op, left_expr, right_expr) => {
      let checked_left = self.check_expr(left_expr)
      let checked_right = self.check_expr(right_expr)
      let op = parser_binop_to_typecheck_binop(op)
      if binop_is_arithmetic(op) {
        let t = self.is_type_compatible(checked_left.ty, checked_right.ty)
        if t is false {
          let msg = "TypeMismatch: Binary Expression Must have same type for both side" +
            " while got \{checked_left.ty} and \{checked_right.ty}"
          self.throw_(expr.toks[0], msg, Error)
        }
        let ty = self.ensure_type(checked_left.ty)
        // Allow String + String for concatenation
        if op is Add && ty is String {
          let e = Expr::{
            kind: BinaryExpr(op, checked_left, checked_right),
            ty: String,
            toks: expr.toks,
          }
          return e
        }
        if !(ty is (Int | Int64 | UInt | UInt64 | Double | Float | TypeVar(_))) {
          let msg = if op is Add {
            "TypeMismatch: both side of + Must Be Int, Int64, UInt, UInt64, Double, Float, or String, while got \{ty}"
          } else {
            "TypeMismatch: both side of \{op} Must Be Int, Int64, UInt, UInt64, Double, or Float, while got \{ty}"
          }
          self.throw_(expr.toks[0], msg, Error)
        }
        let e = Expr::{
          kind: BinaryExpr(op, checked_left, checked_right),
          ty: checked_left.ty,
          toks: expr.toks,
        }
        return e
      }
      if binop_is_cmp(op) {
        let t = self.is_type_compatible(checked_left.ty, checked_right.ty)
        if t is false {
          let msg = "Operands of comparison binary operation must be of the same type" +
            " while got \{checked_left.ty} and \{checked_right.ty}"
          self.throw_(expr.toks[0], msg, Error)
        }
        let e = Expr::{
          kind: BinaryExpr(op, checked_left, checked_right),
          ty: Bool,
          toks: expr.toks,
        }
        return e
      }
      if binop_is_shift(op) {
        // Shift operations: left operand can be Int, Int64, UInt, or UInt64, right operand must be Int
        let left_ty = self.ensure_type(checked_left.ty)
        if !(left_ty is (Int | Int64 | UInt | UInt64 | TypeVar(_))) {
          let msg = "Left operand of shift operation must be of type Int, Int64, UInt, or UInt64" +
            " while got \{left_ty}"
          self.throw_(expr.toks[0], msg, Error)
        }
        let right_ty = self.ensure_type(checked_right.ty)
        if !(right_ty is (Int | TypeVar(_))) {
          let msg = "Right operand of shift operation must be of type Int" +
            " while got \{right_ty}"
          self.throw_(expr.toks[0], msg, Error)
        }
        let e = Expr::{
          kind: BinaryExpr(op, checked_left, checked_right),
          ty: checked_left.ty,
          toks: expr.toks,
        }
        return e
      }
      if binop_is_bitandor(op) {
        // Bitwise AND/OR: both operands must be of the same type
        let t = self.is_type_compatible(checked_left.ty, checked_right.ty)
        if t is false {
          let msg = "Operands of bitwise AND/OR operation must be of the same type" +
            " while got \{checked_left.ty} and \{checked_right.ty}"
          self.throw_(expr.toks[0], msg, Error)
        }
        let ty = self.ensure_type(checked_left.ty)
        if !(ty is (Int | Int64 | UInt | UInt64 | TypeVar(_))) {
          let msg = "Operands of bitwise AND/OR operation must be of type Int, UInt, Int64, UInt64" +
            " while got \{ty}"
          self.throw_(expr.toks[0], msg, Error)
        }
        let e = Expr::{
          kind: BinaryExpr(op, checked_left, checked_right),
          ty: checked_left.ty,
          toks: expr.toks,
        }
        return e
      }
      if binop_is_logical(op) {
        if !(self.is_type_compatible(checked_left.ty, Bool) &&
          self.is_type_compatible(checked_right.ty, Bool)) {
          let msg = "Operands of logical binary operation must be of type Bool" +
            " while got \{checked_left.ty} and \{checked_right.ty}"
          self.throw_(expr.toks[0], msg, Error)
        }
        let e = Expr::{
          kind: BinaryExpr(op, checked_left, checked_right),
          ty: Bool,
          toks: expr.toks,
        }
        return e
      }
      println(
        "Compile ICE: Unsupported binary operation, Should not reach here.",
      )
      panic()
    }
    BlockExpr(block_expr) => {
      let checked_block_expr = self.check_block_expr(block_expr)
      Expr::{
        kind: BlockExpr(checked_block_expr),
        ty: checked_block_expr.ty,
        toks: expr.toks,
      }
    }
    IfExpr(if_expr) => {
      let checked_if_expr = self.check_if_expr(if_expr)
      Expr::{
        kind: IfExpr(checked_if_expr),
        ty: checked_if_expr.ty,
        toks: expr.toks,
      }
    }
    MatchExpr(match_expr) => {
      let checked_match_expr = self.check_match_expr(match_expr)
      Expr::{
        kind: MatchExpr(checked_match_expr),
        ty: checked_match_expr.ty,
        toks: expr.toks,
      }
    }
  }
}

///|
test "Expr to_string Test - Basic" {
  let color = false
  let ctx = Context::new()
  ctx.type_env.set("x", { kind: TypeKind::Bool, mutable: false, })
  ctx.type_env.set("y", { kind: TypeKind::Int, mutable: false, })
  ctx.type_env.set("z", { kind: TypeKind::Int, mutable: false, })
  let code =
    #|42 ; !x ; -y ; 1 + 2 ; y == z
  let tokens = @lexer.tokenize(code)

  // Test ApplyExpr - Int: 42
  let (parsed, rest) = @parser.parse_expr(tokens[:])
  let checked = ctx.check_expr(parsed)
  inspect(checked.to_string(color~), content="int literal 42 (Int)")

  // Test NotExpr: !x
  let (parsed, rest) = @parser.parse_expr(rest[1:])
  let checked = ctx.check_expr(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|unary operator ! (Bool)
      #|└-variable x (Bool)
    ),
  )

  // Test NegExpr: -y
  let (parsed, rest) = @parser.parse_expr(rest[1:])
  let checked = ctx.check_expr(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|unary operator - (Int)
      #|└-variable y (Int)
    ),
  )

  // Test BinaryExpr Add: 1 + 2
  let (parsed, rest) = @parser.parse_expr(rest[1:])
  let checked = ctx.check_expr(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|binary expr: + (Int)
      #|├-int literal 1 (Int)
      #|└-int literal 2 (Int)
    ),
  )

  // Test BinaryExpr Eq: y == z
  let (parsed, _) = @parser.parse_expr(rest[1:])
  let checked = ctx.check_expr(parsed)
  inspect(
    checked.to_string(color~),
    content=(
      #|binary expr: == (Bool)
      #|├-variable y (Int)
      #|└-variable z (Int)
    ),
  )
}

///|
test "Expr to_string Test - BlockExpr" {
  let color = false
  let ctx = Context::new()
  let code =
    #|{ let x = 42 }
  let tokens = @lexer.tokenize(code)

  // Test BlockExpr: { let x = 42 }
  let (parsed, _) = @parser.parse_expr(tokens[:])
  let checked = ctx.check_expr(parsed)
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
test "Expr to_string Test - IfExpr" {
  let color = false
  let ctx = Context::new()
  ctx.type_env.set("x", { kind: TypeKind::Int, mutable: false, })
  let code =
    #|if x > 0 { 1 } else { 0 }
  let tokens = @lexer.tokenize(code)

  // Test IfExpr: if x > 0 { 1 } else { 0 }
  let (parsed, _) = @parser.parse_expr(tokens[:])
  let checked = ctx.check_expr(parsed)
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
