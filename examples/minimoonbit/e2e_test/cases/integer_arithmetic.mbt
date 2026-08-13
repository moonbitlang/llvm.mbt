// 基础测试1：整数运算和简单控制流
fn add(a: Int, b: Int) -> Int {
  a + b
}

fn sub(a: Int, b: Int) -> Int {
  a - b
}

fn mul(a: Int, b: Int) -> Int {
  a * b
}

fn div(a: Int, b: Int) -> Int {
  a / b
}

fn mod(a: Int, b: Int) -> Int {
  a % b
}

fn main {
  let x = 10;
  let y = 3;
  println(add(x, y));
  println(sub(x, y));
  println(mul(x, y));
  println(div(x, y));
  println(mod(x, y));
}


