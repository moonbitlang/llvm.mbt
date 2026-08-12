///|
/// Enumerates the KNF forms represented by `KnfExpr`.
pub(all) enum KnfExpr {
  /// Represents the `Unit` KNF form.
  Unit
  /// Represents the `Int` KNF form.
  Int(Int)
  /// Represents the `Int64` KNF form.
  Int64(Int64)
  /// Represents the `UInt` KNF form.
  UInt(UInt)
  /// Represents the `UInt64` KNF form.
  UInt64(UInt64)
  /// Represents the `Bool` KNF form.
  Bool(Bool)
  /// Represents the `Double` KNF form.
  Double(Double)
  /// Represents the `Float` KNF form.
  Float(Double)
  /// Represents the `Char` KNF form.
  Char(Char)
  /// Represents the `String` KNF form.
  String(String)
  /// Represents the `Ident` KNF form.
  Ident(Name)
  /// Represents the `Not` KNF form.
  Not(Name)
  /// Represents the `Neg` KNF form.
  Neg(Name)
  /// Represents the `Binary` KNF form.
  Binary(BinaryOp, Name, Name)
  /// Represents the `If` KNF form.
  If(KnfExpr, KnfBlock, KnfBlock)
  /// Represents the `Block` KNF form.
  Block(KnfBlock)
  /// Represents the `Call` KNF form.
  Call(Name, Array[Name])
  /// Represents the `ArrayAccess` KNF form.
  ArrayAccess(Name, Name)
  /// Represents the `FieldAccess` KNF form.
  FieldAccess(Name, String)
  /// Represents the `TupleAccess` KNF form.
  TupleAccess(Name, Int)
  /// Represents the `CreateStruct` KNF form.
  CreateStruct(String, Array[(String, Name)])
  /// Represents the `ArrayLiteral` KNF form.
  ArrayLiteral(Type, Array[Name])
  /// Represents the `ArrayMake` KNF form.
  ArrayMake(Name, Name)
  /// Represents the `TupleLiteral` KNF form.
  TupleLiteral(Array[Name])
  /// Represents the `Cast` KNF form.
  Cast(Type, Name)
  /// Represents the `BitCast` KNF form.
  BitCast(Type, Name)
  /// Represents the `GetUnionTag` KNF form.
  GetUnionTag(Name)
  /// Represents the `ReInterpretUnion` KNF form.
  ReInterpretUnion(String, Name) // String is union variant name
  /// Represents the `Switch` KNF form.
  Switch(Name, Array[(Int, KnfBlock)], KnfBlock) // switch expr, cases, default
}

///|
/// Renders this `KnfExpr` KNF value as text.
pub fn KnfExpr::to_string(self : KnfExpr, ident? : Int = 0) -> String {
  match self {
    Unit => "()"
    Int(i) => i.to_string()
    Int64(i) => "\{i}L"
    UInt(i) => "\{i}U"
    UInt64(i) => "\{i}UL"
    Bool(b) => b.to_string()
    Double(d) => d.to_string()
    Float(f) => "\{f}F"
    Char(c) => "'\{c}'"
    String(s) => "\"\{s}\""
    Ident(name) => name.to_string()
    Not(name) => "!\{name}"
    Neg(name) => "-\{name}"
    Binary(op, lhs, rhs) => "\{lhs} \{op} \{rhs}"
    Call(func_name, args) => {
      let args_strs = args.map(arg => arg.to_string()).join(", ")
      "\{func_name}(\{args_strs})"
    }
    ArrayAccess(array_name, index_name) => "\{array_name}[\{index_name}]"
    FieldAccess(struct_name, field_name) => "\{struct_name}.\{field_name}"
    TupleAccess(tuple_name, index) => "\{tuple_name}.\{index}"
    CreateStruct(struct_name, init_arr) => {
      let init_strs = init_arr.map(field => "\{field.0}: \{field.1}").join(", ")
      "\{struct_name}::{\{init_strs}}"
    }
    ArrayLiteral(ty, elem_names) => {
      let elems_strs = elem_names.map(elem => elem.to_string()).join(", ")
      "[\{elems_strs}]::Array[\{ty}]"
    }
    ArrayMake(size_name, init_name) => "array_make(\{size_name}, \{init_name})"
    TupleLiteral(elem_names) => {
      let elems_strs = elem_names.map(elem => elem.to_string()).join(", ")
      "(\{elems_strs})"
    }
    Cast(ty, name) => "cast<\{ty}>(\{name})"
    BitCast(ty, name) => "bitcast<\{ty}>(\{name})"
    GetUnionTag(name) => "get_union_tag(\{name})"
    ReInterpretUnion(variant_name, name) =>
      "reinterpret_union<\{variant_name}>(\{name})"
    Block(block) => block.to_string(ident)
    If(cond, then_block, else_block) => {
      let cond_str = cond.to_string()
      let then_str : String = then_block.to_string(ident)
      if else_block.stmts.is_empty() {
        "if \{cond_str} \{then_str}"
      } else {
        let else_str : String = else_block.to_string(ident)
        "if \{cond_str} \{then_str} else \{else_str}"
      }
    }
    Switch(expr_name, cases, default_block) => {
      let indent_str = " ".repeat(ident + 2)
      let closing_indent = " ".repeat(ident)
      let mut result = "switch (\{expr_name}) {\n"

      // 生成每个 case
      for case in cases {
        let (case_value, case_block) = case
        result = "\{result}\{indent_str}case \{case_value}: {\n"
        for stmt in case_block.stmts {
          result = "\{result}\{stmt.to_string(ident=ident + 4)}\n"
        }
        result = "\{result}\{indent_str}}\n"
      }

      // 生成 default
      result = "\{result}\{indent_str}default: {\n"
      for stmt in default_block.stmts {
        result = "\{result}\{stmt.to_string(ident=ident + 4)}\n"
      }
      result = "\{result}\{indent_str}}\n"
      result = "\{result}\{closing_indent}}"
      result
    }
  }
}

///|
/// Formats `KnfExpr` using MiniMoonBit KNF notation.
pub impl Show for KnfExpr with fn output(self, logger) {
  logger.write_string(self.to_string(ident=0))
}

///|
/// Enumerates the KNF forms represented by `BinaryOp`.
pub(all) enum BinaryOp {
  /// Represents the `Add` KNF form.
  Add // +
  /// Represents the `Sub` KNF form.
  Sub // -
  /// Represents the `Mul` KNF form.
  Mul // *
  /// Represents the `Div` KNF form.
  Div // /
  /// Represents the `Mod` KNF form.
  Mod // %
  /// Represents the `ShiftLeft` KNF form.
  ShiftLeft // <<
  /// Represents the `ShiftRight` KNF form.
  ShiftRight // >>
  /// Represents the `Eq` KNF form.
  Eq // ==
  /// Represents the `NE` KNF form.
  NE // !=
  /// Represents the `LT` KNF form.
  LT // <
  /// Represents the `GT` KNF form.
  GT // >
  /// Represents the `LE` KNF form.
  LE // <=
  /// Represents the `GE` KNF form.
  GE // >=
  /// Represents the `And` KNF form.
  And // &&
  /// Represents the `Or` KNF form.
  Or // ||
  /// Represents the `BitAnd` KNF form.
  BitAnd // &
  /// Represents the `BitOr` KNF form.
  BitOr // |
} derive(Eq)

///|
/// Formats `BinaryOp` using MiniMoonBit KNF notation.
pub impl Show for BinaryOp with fn output(self, logger) {
  let s = match self {
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
  logger.write_string(s)
}

///|
/// Runs the MiniMoonBit KNF operation `binop_to_knf`.
pub fn binop_to_knf(binop : @typecheck.BinaryOp) -> BinaryOp {
  match binop {
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
/// Performs the `expr_to_knf` KNF lowering operation.
pub fn Context::expr_to_knf(
  self : Context,
  expr : @typecheck.Expr,
) -> (Array[KnfStmt], KnfExpr) raise KnfTransformError {
  match expr.kind {
    ApplyExpr(apply_expr) => self.apply_expr_to_knf(apply_expr)
    BlockExpr(block_expr) => {
      let block = self.block_expr_to_knf(block_expr)
      ([], KnfExpr::Block(block))
    }
    IfExpr(if_expr) => self.if_expr_to_knf(if_expr)
    MatchExpr(match_expr) => self.match_expr_to_knf(match_expr)
    NotExpr(inner_expr) => {
      let (stmts, inner_knf_expr) = self.expr_to_knf(inner_expr)
      let ty = self.typekind_to_knf(inner_expr.ty)
      let tmp_name = self.add_temp(ty)
      let knf_let = KnfStmt::Let(tmp_name, ty, inner_knf_expr)
      stmts.push(knf_let)
      (stmts, Not(tmp_name))
    }
    NegExpr(inner_expr) => {
      let (stmts, inner_knf_expr) = self.expr_to_knf(inner_expr)
      let ty = self.typekind_to_knf(inner_expr.ty)
      let tmp_name = self.add_temp(ty)
      let knf_let = KnfStmt::Let(tmp_name, ty, inner_knf_expr)
      stmts.push(knf_let)
      (stmts, Neg(tmp_name))
    }
    BinaryExpr(bin_op, left_expr, right_expr) => {
      let stmts : Array[KnfStmt] = Array::new()
      let (left_stmts, left_knf_expr) = self.expr_to_knf(left_expr)
      let (right_stmts, right_knf_expr) = self.expr_to_knf(right_expr)
      stmts.append(left_stmts)
      stmts.append(right_stmts)
      let left_ty = self.typekind_to_knf(left_expr.ty)
      let right_ty = self.typekind_to_knf(right_expr.ty)
      let lhs_name = match left_knf_expr {
        Ident(name) => name
        _ => {
          let tmp_name = self.add_temp(left_ty)
          let knf_let = KnfStmt::Let(tmp_name, left_ty, left_knf_expr)
          stmts.push(knf_let)
          tmp_name
        }
      }
      let rhs_name = match right_knf_expr {
        Ident(name) => name
        _ => {
          let tmp_name = self.add_temp(right_ty)
          let knf_let = KnfStmt::Let(tmp_name, right_ty, right_knf_expr)
          stmts.push(knf_let)
          tmp_name
        }
      }

      // Handle String concatenation
      if bin_op is Add && left_expr.ty is String {
        let concat_func = Name::{ id: "__builtin_string_concat", slot: 0 }
        return (stmts, Call(concat_func, [lhs_name, rhs_name]))
      }

      // Handle String comparison
      if bin_op is Eq && left_expr.ty is String {
        let strcmp_func = Name::{ id: "moonbit_string_eq", slot: 0 }
        return (stmts, Call(strcmp_func, [lhs_name, rhs_name]))
      }
      let rhs_name_adjusted = if bin_op is (ShiftLeft | ShiftRight) {
        match (left_ty, right_ty) {
          (Type::Int, Type::Int)
          | (Type::Int64, Type::Int64)
          | (Type::UInt, Type::UInt)
          | (Type::UInt64, Type::UInt64) => rhs_name
          (Type::Int64, Type::Int) => {
            let cast_tmp = self.add_temp(Type::Int64)
            let cast_expr = Cast(Type::Int64, rhs_name)
            let knf_let = KnfStmt::Let(cast_tmp, Type::Int64, cast_expr)
            stmts.push(knf_let)
            cast_tmp
          }
          (Type::UInt, Type::Int) => rhs_name
          (Type::UInt64, Type::Int) => {
            let cast_tmp = self.add_temp(Type::Int64)
            let cast_expr = Cast(Type::Int64, rhs_name)
            let knf_let = KnfStmt::Let(cast_tmp, Type::Int64, cast_expr)
            stmts.push(knf_let)
            cast_tmp
          }
          _ => rhs_name
        }
      } else {
        rhs_name
      }
      let bin_op = binop_to_knf(bin_op)
      (stmts, Binary(bin_op, lhs_name, rhs_name_adjusted))
    }
  }
}

///|
fn Context::expr_to_knf_name(
  self : Context,
  expr : KnfExpr,
  ty : Type,
  stmts : Array[KnfStmt],
) -> Name {
  match expr {
    Ident(name) => name
    _ => {
      let tmp_name = self.add_temp(ty)
      let knf_let = KnfStmt::Let(tmp_name, ty, expr)
      stmts.push(knf_let)
      tmp_name
    }
  }
}
