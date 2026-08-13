// ADT测试5：复杂枚举模式匹配
enum Expr {
  Num(Int);
  Add(Expr, Expr);
  Sub(Expr, Expr);
  Mul(Expr, Expr);
  Div(Expr, Expr);
}

fn eval(e: Expr) -> Int {
  match e {
    Num(n) => n;
    Add(left, right) => eval(left) + eval(right);
    Sub(left, right) => eval(left) - eval(right);
    Mul(left, right) => eval(left) * eval(right);
    Div(left, right) => eval(left) / eval(right);
  }
}

fn count_ops(e: Expr) -> Int {
  match e {
    Num(_) => 0;
    Add(left, right) => 1 + count_ops(left) + count_ops(right);
    Sub(left, right) => 1 + count_ops(left) + count_ops(right);
    Mul(left, right) => 1 + count_ops(left) + count_ops(right);
    Div(left, right) => 1 + count_ops(left) + count_ops(right);
  }
}

fn main {
  let e1 = Add(Num(3), Num(4));
  let e2 = Mul(Num(5), Num(6));
  let e3 = Add(e1, e2);
  let e4 = Sub(e3, Num(10));
  let e5 = Div(Mul(Num(100), Num(2)), Num(4));
  
  println(eval(e1));
  println(eval(e2));
  println(eval(e3));
  println(eval(e4));
  println(eval(e5));
  
  println(count_ops(e3));
  println(count_ops(e5));
}

