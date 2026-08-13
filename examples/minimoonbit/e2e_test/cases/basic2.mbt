extern "C" fn truncate(x: Double) -> Int = "truncate"

// 基础测试2：浮点数运算
fn fadd(a: Double, b: Double) -> Double {
  a + b
}

fn fsub(a: Double, b: Double) -> Double {
  a - b
}

fn fmul(a: Double, b: Double) -> Double {
  a * b
}

fn fdiv(a: Double, b: Double) -> Double {
  a / b
}

fn main {
  let x = 10.5;
  let y = 3.2;
  let r1 = fadd(x, y);
  let r2 = fsub(x, y);
  let r3 = fmul(x, y);
  let r4 = fdiv(x, y);
  
  println(truncate(r1));
  println(truncate(r2));
  println(truncate(r3));
  println(truncate(r4));
}

