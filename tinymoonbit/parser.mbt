///|
priv suberror ParserError String derive(Show)

///|
priv enum Type {
  Unit
  Bool
  Int
  Int64
  UInt
  UInt64
  Float
  Double
  Ptr(Type)
  Array(Type)
  Struct(String)
} derive(Show, Eq, ToJson)

///|
fn Type::parse(master : String, sub~ : String? = None) -> Type raise {
  match (master, sub) {
    ("Unit", None) => Unit
    ("Bool", None) => Bool
    ("Int", None) => Int
    ("Int64", None) => Int64
    ("UInt", None) => UInt
    ("UInt64", None) => UInt64
    ("Float", None) => Float
    ("Double", None) => Double
    ("Ptr", Some(sub)) => Ptr(Type::parse(sub))
    ("Array", Some(sub)) => Array(Type::parse(sub))
    (struct_name, None) => Struct(struct_name)
    _ => raise ParserError("Unknown type name: \{master} with sub-type: \{sub}")
  }
}

///|
priv enum AtomExpr {
  Bool(Bool)
  Int(Int)
  Int64(Int64)
  UInt(UInt)
  UInt64(UInt64)
  Float(Float)
  Double(Double)
  Var(String, mut ty~ : Type?) // e.g. x
  Ref(String, mut ty~ : Type?) // e.g. ref x
  TypeSizeof(Type) // e.g. sizeof(Int)
  ExprSizeof(Expr) // e.g. sizeof(1 + 2)
  Array(Array[Expr], mut ty~ : Type?) // e.g. [1, 2, 3]
  Paren(Expr, mut ty~ : Type?) // e.g. (1 + 2)
  Call(String, Array[Expr], mut ty~ : Type?) // e.g. func(arg1, arg2)
} derive(Show, Eq, ToJson)

///|
fn AtomExpr::parse(
  tokens : ArrayView[Token]
) -> (AtomExpr, ArrayView[Token]) raise {
  match tokens {
    [Bool(b), .. rest_toks] => (AtomExpr::Bool(b), rest_toks)
    [Int(i), .. rest_toks] => (Int(i), rest_toks)
    [Int64(i64), .. rest_toks] => (Int64(i64), rest_toks)
    [UInt(u), .. rest_toks] => (UInt(u), rest_toks)
    [UInt64(u64), .. rest_toks] => (UInt64(u64), rest_toks)
    [Float(f), .. rest_toks] => (Float(f), rest_toks)
    [Double(d), .. rest_toks] => (Double(d), rest_toks)
    [Keyword(Ref), Lower(var_name), .. rest_toks] =>
      (Ref(var_name, ty=None), rest_toks)
    [
      Keyword(SizeOf),
      Bracket('('),
      Upper(type_name),
      Bracket(')'),
      .. rest_toks,
    ] => (TypeSizeof(Type::parse(type_name)), rest_toks)
    [Keyword(SizeOf), Bracket('('), .. rest_toks] => {
      let (expr, rest_toks) = Expr::parse(rest_toks)
      guard rest_toks is [Bracket(')'), .. rest_toks] else {
        raise ParserError(
          "Parse AtomExpr Error: Expected ')' after sizeof expression",
        )
      }
      (ExprSizeof(expr), rest_toks)
    }
    [Lower(func_name), Bracket('('), .. rest_toks] => {
      let args : Array[Expr] = Array::new()
      let rest_toks = loop rest_toks {
        [Bracket(')'), .. rest_toks] => break rest_toks
        _ as rest_toks => {
          let (arg_expr, rest_toks) = Expr::parse(rest_toks)
          args.push(arg_expr)
          match rest_toks {
            [Symbol(","), .. rest_toks] => continue rest_toks // continue if there is a comma
            [Bracket(')'), .. rest_toks] => break rest_toks // break if we reach the end of the arguments
            _ =>
              raise ParserError(
                "Parse AtomExpr Error: Unexpected token in function call: \{rest_toks}",
              )
          }
        }
      }
      (Call(func_name, args, ty=None), rest_toks)
    }
    [Lower(var_name), .. rest_toks] => (Var(var_name, ty=None), rest_toks)
    [Bracket('['), Bracket(']'), ..] =>
      raise ParserError(
        "Parse AtomExpr Error: Empty array literal is not allowed",
      )
    [Bracket('['), .. rest_toks] => {
      let elements : Array[Expr] = Array::new()
      let rest_toks = loop rest_toks {
        [Bracket(']'), .. rest_toks] => break rest_toks
        _ as rest_toks => {
          let (expr, rest_toks) = Expr::parse(rest_toks)
          elements.push(expr)
          match rest_toks {
            [Symbol(","), .. rest_toks] => continue rest_toks // continue if there is a comma
            [Bracket(']'), .. rest_toks] => break rest_toks // break if we reach the end of the array
            _ =>
              raise ParserError(
                "Parse AtomExpr Error: Unexpected token in array literal: \{rest_toks}",
              )
          }
        }
      }
      (Array(elements, ty=None), rest_toks)
    }
    [Bracket('('), .. rest_toks] => {
      let (expr, rest_toks) = Expr::parse(rest_toks)
      guard rest_toks is [Bracket(')'), .. rest_toks] else {
        raise ParserError(
          "Parse AtomExpr Error: Expected ')' after parenthesis",
        )
      }
      (Paren(expr, ty=None), rest_toks)
    }
    _ =>
      raise ParserError(
        "Parse AtomExpr Error: Unexpected token in atomic expression: \{tokens}",
      )
  }
}

///|
test "AtomExpr::parse" {
  let (a, _) = AtomExpr::parse(lex("true"))
  inspect(a, content="Bool(true)")
  let (a, _) = AtomExpr::parse(lex("123"))
  inspect(a, content="Int(123)")
  let (a, _) = AtomExpr::parse(lex("123L"))
  inspect(a, content="Int64(123)")
  let (a, _) = AtomExpr::parse(lex("123.0"))
  inspect(a, content="Double(123)")
  let (a, _) = AtomExpr::parse(lex("123.0f"))
  inspect(a, content="Float(123)")
  let (a, _) = AtomExpr::parse(lex("sizeof(Int)"))
  inspect(a, content="TypeSizeof(Int)")
  let (a, _) = AtomExpr::parse(lex("sizeof(1)"))
  inspect(a, content="ExprSizeof(Apply(Atom(Int(1), ty=None), ty=None))")
  let (a, _) = AtomExpr::parse(lex("ref x"))
  inspect(a, content="Ref(\"x\", ty=None)")
  let (a, _) = AtomExpr::parse(lex("x"))
  inspect(a, content="Var(\"x\", ty=None)")
  let (a, _) = AtomExpr::parse(lex("[1, 2]"))
  inspect(
    a,
    content="Array([Apply(Atom(Int(1), ty=None), ty=None), Apply(Atom(Int(2), ty=None), ty=None)], ty=None)",
  )
}

///|
priv enum ApplyExpr {
  Atom(AtomExpr, mut ty~ : Type?) // e.g. 1, x, ref x, sizeof(Int), [1, 2, 3], (1 + 2), ref x
  ArrayGet(ApplyExpr, Expr, mut ty~ : Type?) // e.g. arr[i]
  StructAccess(ApplyExpr, String, mut ty~ : Type?) // e.g. struct.field
  Cast(ApplyExpr, Type) // e.g. 1 as Float
} derive(Show, Eq, ToJson)

///|
fn ApplyExpr::parse(
  tokens : ArrayView[Token]
) -> (ApplyExpr, ArrayView[Token]) raise {
  let (atom_expr, rest_toks) = AtomExpr::parse(tokens)
  let mut apply_expr = ApplyExpr::Atom(atom_expr, ty=None)
  loop rest_toks {
    [Bracket('['), .. rest_toks] => {
      let (index_expr, rest_toks) = Expr::parse(rest_toks)
      guard rest_toks is [Bracket(']'), .. rest_toks] else {
        raise ParserError(
          "Parse ApplyExpr Error: Expected ']' after array index",
        )
      }
      apply_expr = ApplyExpr::ArrayGet(apply_expr, index_expr, ty=None)
      continue rest_toks
    }
    [Symbol("."), Lower(field_name), .. rest_toks] => {
      apply_expr = ApplyExpr::StructAccess(apply_expr, field_name, ty=None)
      continue rest_toks
    }
    [
      Keyword(As),
      Upper(type_name),
      Bracket('['),
      Upper(sub),
      Bracket(']'),
      .. rest_toks,
    ] => {
      let type_name = Type::parse(type_name, sub=Some(sub))
      apply_expr = ApplyExpr::Cast(apply_expr, type_name)
      continue rest_toks
    }
    [Keyword(As), Upper(type_name), .. rest_toks] => {
      let type_name = Type::parse(type_name)
      apply_expr = ApplyExpr::Cast(apply_expr, type_name)
      continue rest_toks
    }
    _ as tokens => return (apply_expr, tokens) // no more applies or accesses
  }
}

///|
test "ApplyExpr::parse" {
  let (a, _) = ApplyExpr::parse(lex("true"))
  inspect(a, content="Atom(Bool(true), ty=None)")
  let (a, _) = ApplyExpr::parse(lex("arr[1]"))
  inspect(
    a,
    content="ArrayGet(Atom(Var(\"arr\", ty=None), ty=None), Apply(Atom(Int(1), ty=None), ty=None), ty=None)",
  )
  let (a, _) = ApplyExpr::parse(lex("p.x"))
  inspect(
    a,
    content="StructAccess(Atom(Var(\"p\", ty=None), ty=None), \"x\", ty=None)",
  )
  let (a, _) = ApplyExpr::parse(lex("1 as Double"))
  inspect(a, content="Cast(Atom(Int(1), ty=None), Double)")
}

///|
priv enum Expr {
  Apply(ApplyExpr, mut ty~ : Type?) // e.g. func(arg1, arg2)
  Neg(Expr, mut ty~ : Type?) // e.g. -1, -x
  Add(Expr, Expr, mut ty~ : Type?) // e.g. 1 + 2
  Sub(Expr, Expr, mut ty~ : Type?) // e.g. 1 - 2
  Mul(Expr, Expr, mut ty~ : Type?) // e.g. 1 * 2
  Div(Expr, Expr, mut ty~ : Type?) // e.g. 1 / 2
  Rem(Expr, Expr, mut ty~ : Type?) // e.g. 1 % 2
  Eq(Expr, Expr) // e.g. 1 == 2, ty must be Bool
  Ne(Expr, Expr)
  Le(Expr, Expr)
  Ge(Expr, Expr)
  Lt(Expr, Expr)
  Gt(Expr, Expr)
  And(Expr, Expr)
  Or(Expr, Expr)
  Shl(Expr, Expr, mut ty~ : Type?) // e.g. 1 << 2
  Shr(Expr, Expr, mut ty~ : Type?) // e.g. 1 >> 2
} derive(Show, Eq, ToJson)

///|
fn Expr::parse(tokens : ArrayView[Token]) -> (Expr, ArrayView[Token]) raise {
  if tokens is [Operator("-"), .. rest_tokens] {
    let (expr, rest_tokens) = Expr::parse(rest_tokens)
    return (Expr::Neg(expr, ty=None), rest_tokens)
  }
  fn construct_bin_expr(
    left : Expr,
    right : Expr,
    oper : String
  ) -> Expr raise {
    match oper {
      "+" => Expr::Add(left, right, ty=None)
      "-" => Expr::Sub(left, right, ty=None)
      "*" => Expr::Mul(left, right, ty=None)
      "/" => Expr::Div(left, right, ty=None)
      "%" => Expr::Rem(left, right, ty=None)
      "==" => Expr::Eq(left, right)
      "!=" => Expr::Ne(left, right)
      "<=" => Expr::Le(left, right)
      ">=" => Expr::Ge(left, right)
      "<" => Expr::Lt(left, right)
      ">" => Expr::Gt(left, right)
      "&&" => Expr::And(left, right)
      "||" => Expr::Or(left, right)
      "<<" => Expr::Shl(left, right, ty=None) // left shift
      ">>" => Expr::Shr(left, right, ty=None) // logical right shift
      _ => raise ParserError("Unknown operator: \{oper}")
    }
  }

  fn preced(op : String) -> Int raise {
    match op {
      "*" | "/" | "%" => 9
      "+" | "-" => 8
      "<<" | ">>" => 7 // left and logical right shift
      "==" | "!=" | "<=" | ">=" | "<" | ">" => 6
      "&&" => 3
      "||" => 2
      _ => raise ParserError("Unknown operator precedence for: \{op}")
    }
  }

  let exprs : Array[Expr] = Array::new()
  let opers : Array[String] = Array::new()
  let (head_apply, rest_toks) = ApplyExpr::parse(tokens)
  exprs.push(Expr::Apply(head_apply, ty=None))
  loop rest_toks {
    [Operator(op), .. rest_toks] if opers.is_empty() => {
      let (next_apply, rest_toks) = ApplyExpr::parse(rest_toks)
      exprs.push(Expr::Apply(next_apply, ty=None))
      opers.push(op)
      continue rest_toks
    }
    [Operator(op), .. rest_toks] if preced(op) >= preced(opers.last().unwrap()) => {
      let (next_apply, rest_toks) = ApplyExpr::parse(rest_toks)
      exprs.push(Expr::Apply(next_apply, ty=None))
      opers.push(op)
      continue rest_toks
    }
    [Operator(op), .. rest_toks] => {
      let new_exprs = Array::new()
      let new_opers = Array::new()
      while opers.last() is Some(last_op) && preced(op) < preced(last_op) {
        new_exprs.push(exprs.pop().unwrap()) // right_expr
        new_opers.push(opers.pop().unwrap())
      } else {
        new_exprs.push(exprs.pop().unwrap()) // left_expr
      }
      while not(new_opers.is_empty()) {
        let left_expr = new_exprs.pop().unwrap()
        let right_expr = new_exprs.pop().unwrap()
        let oper = new_opers.pop().unwrap()
        let new_expr = construct_bin_expr(left_expr, right_expr, oper)
        new_exprs.push(new_expr)
      }
      guard new_exprs.length() == 1 else {
        raise ParserError(
          "Parse Expression Error: Mismatched expression and operators",
        )
      }
      exprs.push(new_exprs.pop().unwrap())
      let (next_apply, rest_toks) = ApplyExpr::parse(rest_toks)
      exprs.push(Expr::Apply(next_apply, ty=None))
      opers.push(op)
      continue rest_toks
    }
    _ as rest_toks => {
      // clear opers and exprs
      while not(opers.is_empty()) {
        let right_expr = exprs.pop().unwrap()
        let left_expr = exprs.pop().unwrap()
        let oper = opers.pop().unwrap()
        let new_expr = construct_bin_expr(left_expr, right_expr, oper)
        exprs.push(new_expr)
      }
      guard exprs.length() == 1 else {
        raise ParserError(
          "Parse Expression Error: Mismatched expression and operators",
        )
      }
      (exprs[0], rest_toks)
    }
  }
}

///|
test "Expr::parse" {
  let (e, _) = Expr::parse(lex("1 + 2"))
  inspect(
    e,
    content="Add(Apply(Atom(Int(1), ty=None), ty=None), Apply(Atom(Int(2), ty=None), ty=None), ty=None)",
  )
  let (e, _) = Expr::parse(lex("x + y * z"))
  inspect(
    e,
    content="Add(Apply(Atom(Var(\"x\", ty=None), ty=None), ty=None), Mul(Apply(Atom(Var(\"y\", ty=None), ty=None), ty=None), Apply(Atom(Var(\"z\", ty=None), ty=None), ty=None), ty=None), ty=None)",
  )
  let (e, _) = Expr::parse(lex("x * y + z"))
  inspect(
    e,
    content="Add(Mul(Apply(Atom(Var(\"x\", ty=None), ty=None), ty=None), Apply(Atom(Var(\"y\", ty=None), ty=None), ty=None), ty=None), Apply(Atom(Var(\"z\", ty=None), ty=None), ty=None), ty=None)",
  )
}

///|
priv enum LeftValue {
  Var(String, mut ty~ : Type?) // e.g. x
  ArrayGet(LeftValue, Expr, mut ty~ : Type?) // e.g. arr[i]
  StructAccess(LeftValue, String, mut ty~ : Type?) // e.g. struct.field
} derive(Show, Eq, ToJson)

///|
fn LeftValue::parse(
  tokens : ArrayView[Token]
) -> (LeftValue, ArrayView[Token]) raise {
  guard tokens is [Lower(var_name), .. rest_toks] else {
    raise ParserError("Parse LeftValue Error: Not a valid left value")
  }
  let mut left_value = LeftValue::Var(var_name, ty=None)
  loop rest_toks {
    [Bracket('['), .. rest_toks] => {
      let (index_expr, rest_toks) = Expr::parse(rest_toks)
      guard rest_toks is [Bracket(']'), .. rest_toks] else {
        raise ParserError(
          "Parse LeftValue Error: Expected ']' after array index",
        )
      }
      left_value = LeftValue::ArrayGet(left_value, index_expr, ty=None)
      continue rest_toks
    }
    [Symbol("."), Lower(field_name), .. rest_toks] => {
      left_value = LeftValue::StructAccess(left_value, field_name, ty=None)
      continue rest_toks
    }
    _ as tokens => break (left_value, tokens)
  }
}

///|
test "LeftValue::parse" {
  let (lv, _) = LeftValue::parse(lex("x"))
  inspect(lv, content="Var(\"x\", ty=None)")
  let (lv, _) = LeftValue::parse(lex("arr[1]"))
  inspect(
    lv,
    content="ArrayGet(Var(\"arr\", ty=None), Apply(Atom(Int(1), ty=None), ty=None), ty=None)",
  )
  let (lv, _) = LeftValue::parse(lex("p.x"))
  inspect(lv, content="StructAccess(Var(\"p\", ty=None), \"x\", ty=None)")
  let (lv, _) = LeftValue::parse(lex("arr[i].x"))
  inspect(
    lv,
    content="StructAccess(ArrayGet(Var(\"arr\", ty=None), Apply(Atom(Var(\"i\", ty=None), ty=None), ty=None), ty=None), \"x\", ty=None)",
  )
}

///|
priv enum Stmt {
  Let(String, Type, Expr?) // e.g. let x: Int = 1 or let x: Int
  If(Expr, Array[Stmt], Array[Stmt]) // e.g. if (x > 0) { ... } else { ... }
  While(Expr, Array[Stmt]) // e.g. while (x < 10) { ... }
  Return(Expr?) // e.g. return 1 or return
  Assign(LeftValue, Expr) // e.g. x = 1 or arr[i] = 2 or arr[i].field = 3
  Expr(Expr) // single expression statement, e.g. print_int(1);
} derive(Show, Eq, ToJson)

///|
fn Stmt::parse(tokens : ArrayView[Token]) -> (Stmt, ArrayView[Token]) raise {
  match tokens {
    [Keyword(Let), ..] => Stmt::parse_let(tokens)
    [Keyword(If), ..] => Stmt::parse_if(tokens)
    [Keyword(While), ..] => Stmt::parse_while(tokens)
    [Keyword(Return), ..] => Stmt::parse_return(tokens)
    [Lower(_), ..] => {
      let (_, rest_toks) = ApplyExpr::parse(tokens)
      match rest_toks[0] {
        Operator("=") => Stmt::parse_assign(tokens)
        _ => Stmt::parse_expr(tokens)
      }
    }
    _ =>
      raise ParserError(
        "Parse Statement Error: Unexpected token in statement: \{tokens}",
      )
  }
}

///|
fn Stmt::parse_let(tokens : ArrayView[Token]) -> (Stmt, ArrayView[Token]) raise {
  match tokens {
    // let x: Array[Int];
    [
      Keyword(Let),
      Lower(var_name),
      Symbol(":"),
      Upper(type_name),
      Bracket('['),
      Upper(sub),
      Bracket(']'),
      Terminator,
      .. rest_toks,
    ] => {
      let type_name = Type::parse(type_name, sub=Some(sub))
      let stmt = Stmt::Let(var_name, type_name, None)
      (stmt, rest_toks)
    }
    // let x: Array[Int] = [1, 2]
    [
      Keyword(Let),
      Lower(var_name),
      Symbol(":"),
      Upper(type_name),
      Bracket('['),
      Upper(sub),
      Bracket(']'),
      Operator("="),
      .. rest_toks,
    ] => {
      let type_name = Type::parse(type_name, sub=Some(sub))
      let (expr, rest_toks) = Expr::parse(rest_toks)
      let stmt = Stmt::Let(var_name, type_name, Some(expr))
      guard rest_toks is [Terminator, .. rest_toks] else {
        raise ParserError(
          "Parse Let Statement Error: Expected ';' after array initialization",
        )
      }
      (stmt, rest_toks)
    }
    // let x: Int;
    [
      Keyword(Let),
      Lower(var_name),
      Symbol(":"),
      Upper(type_name),
      Terminator,
      .. rest_toks,
    ] => {
      let type_name = Type::parse(type_name)
      let stmt = Stmt::Let(var_name, type_name, None)
      (stmt, rest_toks)
    }
    // let x: Int = 1 + 2
    [
      Keyword(Let),
      Lower(var_name),
      Symbol(":"),
      Upper(type_name),
      Operator("="),
      .. rest_toks,
    ] => {
      let type_name = Type::parse(type_name)
      let (expr, rest_toks) = Expr::parse(rest_toks)
      let stmt = Stmt::Let(var_name, type_name, Some(expr))
      guard rest_toks is [Terminator, .. rest_toks] else {
        raise ParserError(
          "Parse Let Statement Error: Expected ';' after array initialization",
        )
      }
      (stmt, rest_toks)
    }
    _ =>
      raise ParserError(
        "Parse Let Statement Error: Unexpected token in let statement: \{tokens}",
      )
  }
}

///|
test "Stmt::parse_let" {
  let (s, _) = Stmt::parse(lex("let x: Int = 1 + 2;"))
  inspect(
    s,
    content="Let(\"x\", Int, Some(Add(Apply(Atom(Int(1), ty=None), ty=None), Apply(Atom(Int(2), ty=None), ty=None), ty=None)))",
  )
  let (s, _) = Stmt::parse(lex("let arr: Array[Int] = [1, 2];"))
  inspect(
    s,
    content="Let(\"arr\", Array(Int), Some(Apply(Atom(Array([Apply(Atom(Int(1), ty=None), ty=None), Apply(Atom(Int(2), ty=None), ty=None)], ty=None), ty=None), ty=None)))",
  )
  let (s, _) = Stmt::parse(lex("let x: Int;"))
  inspect(s, content="Let(\"x\", Int, None)")
  let (s, _) = Stmt::parse(lex("let xptr: Ptr[Int] = ref x;"))
  inspect(
    s,
    content="Let(\"xptr\", Ptr(Int), Some(Apply(Atom(Ref(\"x\", ty=None), ty=None), ty=None)))",
  )
}

///|
fn Stmt::parse_assign(
  tokens : ArrayView[Token]
) -> (Stmt, ArrayView[Token]) raise {
  let (left_value, rest_toks) = LeftValue::parse(tokens)
  guard rest_toks is [Operator("="), .. rest_toks] else {
    raise ParserError(
      "Parse Assign Statement Error: Expected '=' after left value",
    )
  }
  let (expr, rest_toks) = Expr::parse(rest_toks)
  let stmt = Stmt::Assign(left_value, expr)
  guard rest_toks is [Terminator, .. rest_toks] else {
    raise ParserError(
      "Parse Assign Statement Error: Expected ';' after assignment expression",
    )
  }
  (stmt, rest_toks)
}

///|
test "Stmt::parse_assign" {
  let (s, _) = Stmt::parse(lex("x = 1 + 2;"))
  inspect(
    s,
    content="Assign(Var(\"x\", ty=None), Add(Apply(Atom(Int(1), ty=None), ty=None), Apply(Atom(Int(2), ty=None), ty=None), ty=None))",
  )
  let (s, _) = Stmt::parse(lex("arr[1] = 2;"))
  inspect(
    s,
    content="Assign(ArrayGet(Var(\"arr\", ty=None), Apply(Atom(Int(1), ty=None), ty=None), ty=None), Apply(Atom(Int(2), ty=None), ty=None))",
  )
  let (s, _) = Stmt::parse(lex("p.x = 3;"))
  inspect(
    s,
    content="Assign(StructAccess(Var(\"p\", ty=None), \"x\", ty=None), Apply(Atom(Int(3), ty=None), ty=None))",
  )
  let (s, _) = Stmt::parse(lex("arr[i].x = 4;"))
  inspect(
    s,
    content="Assign(StructAccess(ArrayGet(Var(\"arr\", ty=None), Apply(Atom(Var(\"i\", ty=None), ty=None), ty=None), ty=None), \"x\", ty=None), Apply(Atom(Int(4), ty=None), ty=None))",
  )
}

///|
fn Stmt::parse_if(tokens : ArrayView[Token]) -> (Stmt, ArrayView[Token]) raise {
  match tokens {
    [Keyword(If), .. rest_toks] => {
      let (condition, rest_toks) = Expr::parse(rest_toks)
      guard rest_toks is [Bracket('{'), .. rest_toks] else {
        raise ParserError(
          "Parse If Statement Error: Expected '}' after condition",
        )
      }
      let then_body : Array[Stmt] = Array::new()
      let rest_toks = loop rest_toks {
        [Bracket('}'), .. rest_toks] => break rest_toks
        _ as rest_toks => {
          let (stmt, rest_toks) = Stmt::parse(rest_toks)
          then_body.push(stmt)
          continue rest_toks
        }
      }
      let else_body : Array[Stmt] = Array::new()
      let rest_toks = match rest_toks {
        [Keyword(Else), Bracket('{'), .. rest_toks] =>
          loop rest_toks {
            [Bracket('}'), .. rest_toks] => break rest_toks
            _ as rest_toks => {
              let (stmt, rest_toks) = Stmt::parse(rest_toks)
              else_body.push(stmt)
              continue rest_toks
            }
          }
        [Keyword(Else), .. rest_toks] if rest_toks is [Keyword(If), ..] => {
          let (else_if_stmt, rest_toks) = Stmt::parse_if(rest_toks)
          else_body.push(else_if_stmt)
          rest_toks
        }
        _ => rest_toks
      }
      let stmt = Stmt::If(condition, then_body, else_body)
      (stmt, rest_toks)
    }
    _ =>
      raise ParserError(
        "Parse If Statement Error: Unexpected token in if statement: \{tokens}",
      )
  }
}

///|
test "Stmt::parse if" {
  let code =
    #| if x > 0 {
    #|   b = true;
    #| }
  let (s, _) = code |> lex |> Stmt::parse_if
  inspect(
    s,
    content="If(Gt(Apply(Atom(Var(\"x\", ty=None), ty=None), ty=None), Apply(Atom(Int(0), ty=None), ty=None)), " +
      "[Assign(Var(\"b\", ty=None), Apply(Atom(Bool(true), ty=None), ty=None))], [])",
  )
  let code =
    #| if x > 0 {
    #|   b = true;
    #| } else {
    #|   b = false;
    #| }
  let (s, _) = code |> lex |> Stmt::parse_if
  inspect(
    s,
    content="If(Gt(Apply(Atom(Var(\"x\", ty=None), ty=None), ty=None), Apply(Atom(Int(0), ty=None), ty=None)), " +
      "[Assign(Var(\"b\", ty=None), Apply(Atom(Bool(true), ty=None), ty=None))], " +
      "[Assign(Var(\"b\", ty=None), Apply(Atom(Bool(false), ty=None), ty=None))])",
  )
  let code =
    #| if x > 0 {
    #|   b = 1;
    #| } else if x < 0 {
    #|   b = -1;
    #| } else {
    #|   b = 0;
    #| }
  let (s, _) = code |> lex |> Stmt::parse_if
  inspect(
    s,
    content="If(Gt(Apply(Atom(Var(\"x\", ty=None), ty=None), ty=None), Apply(Atom(Int(0), ty=None), ty=None)), " +
      "[Assign(Var(\"b\", ty=None), Apply(Atom(Int(1), ty=None), ty=None))], " +
      "[If(Lt(Apply(Atom(Var(\"x\", ty=None), ty=None), ty=None), Apply(Atom(Int(0), ty=None), ty=None)), " +
      "[Assign(Var(\"b\", ty=None), Neg(Apply(Atom(Int(1), ty=None), ty=None), ty=None))], " +
      "[Assign(Var(\"b\", ty=None), Apply(Atom(Int(0), ty=None), ty=None))])])",
  )
}

///|
fn Stmt::parse_while(
  tokens : ArrayView[Token]
) -> (Stmt, ArrayView[Token]) raise {
  match tokens {
    [Keyword(While), .. rest_toks] => {
      let (condition, rest_toks) = Expr::parse(rest_toks)
      guard rest_toks is [Bracket('{'), .. rest_toks] else {
        raise ParserError(
          "Parse While Statement Error: Expected '}' after condition",
        )
      }
      let body : Array[Stmt] = Array::new()
      let rest_toks = loop rest_toks {
        [Bracket('}'), .. rest_toks] => break rest_toks
        _ as rest_toks => {
          let (stmt, rest_toks) = Stmt::parse(rest_toks)
          body.push(stmt)
          continue rest_toks
        }
      }
      let stmt = Stmt::While(condition, body)
      (stmt, rest_toks)
    }
    _ =>
      raise ParserError(
        "Parse While Statement Error: Unexpected token in while statement: \{tokens}",
      )
  }
}

///|
test "Stmt::parse while" {
  let code =
    #| while x < 10 {
    #|   x = x + 1;
    #| }
  let (s, _) = code |> lex |> Stmt::parse_while
  inspect(
    s,
    content="While(Lt(Apply(Atom(Var(\"x\", ty=None), ty=None), ty=None), Apply(Atom(Int(10), ty=None), ty=None)), " +
      "[Assign(Var(\"x\", ty=None), Add(Apply(Atom(Var(\"x\", ty=None), ty=None), ty=None), Apply(Atom(Int(1), ty=None), ty=None), ty=None))])",
  )
}

///|
fn Stmt::parse_return(
  tokens : ArrayView[Token]
) -> (Stmt, ArrayView[Token]) raise {
  match tokens {
    [Keyword(Return), Terminator, .. rest_toks] =>
      (Stmt::Return(None), rest_toks)
    [Keyword(Return), .. rest_toks] => {
      let (expr, rest_toks) = Expr::parse(rest_toks)
      guard rest_toks is [Terminator, .. rest_toks] else {
        raise ParserError(
          "Parse Return Statement Error: Expected ';' after return expression",
        )
      }
      (Stmt::Return(Some(expr)), rest_toks)
    }
    _ =>
      raise ParserError(
        "Parse Return Statement Error: Unexpected token in return statement: \{tokens}",
      )
  }
}

///|
test "Stmt::parse return" {
  let (s, _) = Stmt::parse(lex("return;"))
  inspect(s, content="Return(None)")
  let (s, _) = Stmt::parse(lex("return 1 + 2;"))
  inspect(
    s,
    content="Return(Some(Add(Apply(Atom(Int(1), ty=None), ty=None), Apply(Atom(Int(2), ty=None), ty=None), ty=None)))",
  )
}

///|
fn Stmt::parse_expr(
  tokens : ArrayView[Token]
) -> (Stmt, ArrayView[Token]) raise {
  let (expr, rest_toks) = Expr::parse(tokens)
  guard rest_toks is [Terminator, .. rest_toks] else {
    raise ParserError(
      "Parse Expression Statement Error: Expected ';' after expression",
    )
  }
  (Stmt::Expr(expr), rest_toks)
}

///|
priv struct Function {
  name : String
  params : Array[(String, Type)]
  ret_ty : Type
  body : Array[Stmt]
} derive(Show)

///|
fn Function::parse_extern(
  tokens : ArrayView[Token]
) -> (Function, ArrayView[Token]) raise {
  guard tokens
    is [Keyword(Extern), Keyword(Fn), Lower(fname), Bracket('('), .. tokens] else {
    raise ParserError(
      "Parse Function Error: Not a valid extern function declaration",
    )
  }
  // Extern function, just skip the body
  let params : Array[(String, Type)] = Array::new()
  let tokens = loop tokens {
    // Ptr or Array
    [
      Lower(param_name),
      Symbol(":"),
      Upper(master),
      Bracket('['),
      Upper(sub),
      Bracket(']'),
      .. rest_toks,
    ] => {
      let type_name = Type::parse(master, sub=Some(sub))
      params.push((param_name, type_name))
      continue rest_toks
    }
    [Lower(param_name), Symbol(":"), Upper(type_name), .. rest_toks] => {
      let type_name = Type::parse(type_name)
      params.push((param_name, type_name))
      continue rest_toks
    }
    [Symbol(","), .. rest_toks] => continue rest_toks
    // `) ->`, break 
    [Bracket(')'), LeftArrow, .. rest_toks] => break rest_toks
    _ as tokens =>
      raise ParserError(
        "Parse Function Error: Unexpected token in parameters: \{tokens}",
      )
  }
  let (
    ret_ty,
    // parse return type
    tokens,
  ) = match tokens {
    [
      Upper(master),
      Bracket('['),
      Upper(sub),
      Bracket(']'),
      Terminator,
      .. rest_toks,
    ] => {
      let return_type = Type::parse(master, sub=Some(sub))
      (return_type, rest_toks)
    }
    [Upper(ret_ty), Terminator, .. rest_toks] => {
      let return_type = Type::parse(ret_ty)
      (return_type, rest_toks)
    }
    _ => raise ParserError("Parse Function Error, during parsing return type")
  }
  let function = Function::{ name: fname, params, ret_ty, body: Array::new() }
  return (function, tokens)
}

///|
fn Function::parse(
  tokens : ArrayView[Token]
) -> (Function, ArrayView[Token]) raise {
  let (fname, params, ret_ty, tokens) = if tokens
    is [Keyword(Fn), Lower(fname), Bracket('('), .. tokens] {
    let params : Array[(String, Type)] = Array::new()
    let tokens = loop tokens {
      // Ptr or Array
      [
        Lower(param_name),
        Symbol(":"),
        Upper(master),
        Bracket('['),
        Upper(sub),
        Bracket(']'),
        .. rest_toks,
      ] => {
        let type_name = Type::parse(master, sub=Some(sub))
        params.push((param_name, type_name))
        continue rest_toks
      }
      [Lower(param_name), Symbol(":"), Upper(type_name), .. rest_toks] => {
        let type_name = Type::parse(type_name)
        params.push((param_name, type_name))
        continue rest_toks
      }
      [Symbol(","), .. rest_toks] => continue rest_toks
      // `) ->`, break 
      [Bracket(')'), LeftArrow, .. rest_toks] => break rest_toks
      _ as tokens =>
        raise ParserError(
          "Parse Function Error: Unexpected token in parameters: \{tokens}",
        )
    }
    let (
      ret_ty,

      // parse return type
      tokens,
    ) = match tokens {
      [
        Upper(master),
        Bracket('['),
        Upper(sub),
        Bracket(']'),
        Bracket('{'),
        .. rest_toks,
      ] => {
        let return_type = Type::parse(master, sub=Some(sub))
        (return_type, rest_toks)
      }
      [Upper(ret_ty), Bracket('{'), .. rest_toks] => {
        let return_type = Type::parse(ret_ty)
        (return_type, rest_toks)
      }
      _ => raise ParserError("Parse Function Error, during parsing return type")
    }
    (fname, params, ret_ty, tokens)
  } else if tokens is [Keyword(Fn), Lower("main"), Bracket('{'), .. tokens] {
    ("main", Array::new(), Type::Unit, tokens)
  } else {
    raise ParserError("Parse Function Error, Not a function definition")
  }
  let body : Array[Stmt] = Array::new()
  let tokens = loop tokens {
    [Bracket('}'), .. rest_toks] => break rest_toks
    _ as tokens => {
      let (stmt, rest_toks) = Stmt::parse(tokens)
      body.push(stmt)
      continue rest_toks
    }
  }
  let function = Function::{ name: fname, params, ret_ty, body }
  (function, tokens)
}

///|
test "Function::parse" {
  let (f, _) = Function::parse(
    lex("fn add(x: Int, y: Int) -> Int { return x + y; }"),
  )
  inspect(
    f,
    content="{name: \"add\", " +
      "params: [(\"x\", Int), (\"y\", Int)], " +
      "ret_ty: Int, " +
      "body: [Return(Some(Add(Apply(Atom(Var(\"x\", ty=None), ty=None), ty=None), Apply(Atom(Var(\"y\", ty=None), ty=None), ty=None), ty=None)))]}",
  )
  let (f, _) = Function::parse(
    lex("fn get_size(arr: ValIntArray) -> Int { return arr.size; }"),
  )
  inspect(
    f,
    content="{name: \"get_size\", " +
      "params: [(\"arr\", Struct(\"ValIntArray\"))], " +
      "ret_ty: Int, " +
      "body: [Return(Some(Apply(StructAccess(Atom(Var(\"arr\", ty=None), ty=None), \"size\", ty=None), ty=None)))]}",
  )
}

///|
priv struct StructDef {
  name : String
  fields : Array[(String, Type)]
} derive(Show)

///|
fn StructDef::parse(
  tokens : ArrayView[Token]
) -> (StructDef, ArrayView[Token]) raise {
  guard tokens is [Keyword(Struct), Upper(name), Bracket('{'), .. tokens] else {
    raise ParserError("Parse Struct Error, Not a struct definition")
  }
  let fields : Array[(String, Type)] = Array::new()
  let tokens = loop tokens {
    [
      Lower(field_name),
      Symbol(":"),
      Upper(master),
      Bracket('['),
      Upper(sub),
      Bracket(']'),
      .. rest_toks,
    ] => {
      let type_name = Type::parse(master, sub=Some(sub))
      fields.push((field_name, type_name))
      continue rest_toks
    }
    [Lower(field_name), Symbol(":"), Upper(type_name), .. rest_toks] => {
      let type_name = Type::parse(type_name)
      fields.push((field_name, type_name))
      continue rest_toks
    }
    [Symbol(","), .. rest_toks] => continue rest_toks
    [Bracket('}'), .. rest_toks] => break rest_toks
    _ as tokens =>
      raise ParserError(
        "Parse Struct Error: Unexpected token in struct fields: \{tokens}",
      )
  }
  let struct_def = StructDef::{ name, fields }
  (struct_def, tokens)
}

///|
test "StructDef::parse" {
  let (s, _) = StructDef::parse(lex("struct Point { x: Int, y: Int };"))
  inspect(s, content="{name: \"Point\", fields: [(\"x\", Int), (\"y\", Int)]}")
  let (s, _) = StructDef::parse(
    lex("struct ValArray { data: Ptr[Int], size: Int };"),
  )
  inspect(
    s,
    content="{name: \"ValArray\", fields: [(\"data\", Ptr(Int)), (\"size\", Int)]}",
  )
}

///|
fn StructDef::get_field_type(self : Self, field_name : String) -> Type? {
  for field in self.fields {
    let (name, ty) = field
    if name == field_name {
      return Some(ty)
    }
  }
  None
}

///|
fn StructDef::get_field_index(self : Self, field_name : String) -> Int? {
  for i = 0; i < self.fields.length(); i = i + 1 {
    let (name, _) = self.fields[i]
    if name == field_name {
      return Some(i)
    }
  }
  None
}

///|
priv struct Program {
  functions : Map[String, Function]
  externs : Map[String, Function]
  structs : Map[String, StructDef]
}

///|
fn Program::parse(tokens : Array[Token]) -> Program raise {
  let functions = Map::new()
  let externs = Map::new()
  let structs = Map::new()
  loop tokens[:] {
    [EOF] => break
    [Keyword(Extern), ..] as toks => {
      let (f, rest_toks) = Function::parse_extern(toks)
      guard not(functions.contains(f.name)) else {
        raise ParserError(
          "Parse Program Error: Extern function \{f.name} already defined",
        )
      }
      externs.set(f.name, f)
      continue rest_toks
    }
    [Keyword(Fn), ..] as toks => {
      let (f, rest_toks) = Function::parse(toks)
      guard not(functions.contains(f.name)) else {
        raise ParserError(
          "Parse Program Error: Function \{f.name} already defined",
        )
      }
      functions.set(f.name, f)
      continue rest_toks
    }
    [Keyword(Struct), ..] as toks => {
      let (s, rest_toks) = StructDef::parse(toks)
      guard not(structs.contains(s.name)) else {
        raise ParserError(
          "Parse Program Error: Struct \{s.name} already defined",
        )
      }
      structs.set(s.name, s)
      continue rest_toks
    }
    _ =>
      raise ParserError(
        "Parse Program Error: Unexpected token in program: \{tokens}",
      )
  }
  Program::{ functions, externs, structs }
}
