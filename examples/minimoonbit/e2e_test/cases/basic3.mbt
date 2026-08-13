// 基础测试3：if-else控制流
fn max(a: Int, b: Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

fn min(a: Int, b: Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

fn abs(x: Int) -> Int {
  if x < 0 {
    0 - x
  } else {
    x
  }
}

fn sign(x: Int) -> Int {
  if x > 0 {
    1
  } else if x < 0 {
    0 - 1
  } else {
    0
  }
}

fn main {
  println(max(5, 10));
  println(min(5, 10));
  println(abs(0 - 42));
  println(sign(0 - 5));
  println(sign(0));
  println(sign(5));
}

