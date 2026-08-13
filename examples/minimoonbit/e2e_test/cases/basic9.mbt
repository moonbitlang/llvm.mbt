// 基础测试9：嵌套函数调用和复杂表达式
fn compose(f: (Int) -> Int, g: (Int) -> Int, x: Int) -> Int {
  f(g(x))
}

fn square(x: Int) -> Int {
  x * x
}

fn double(x: Int) -> Int {
  x * 2
}

fn inc(x: Int) -> Int {
  x + 1
}

fn apply_twice(f: (Int) -> Int, x: Int) -> Int {
  f(f(x))
}

fn main {
  println(compose(square, double, 3));
  println(compose(double, square, 3));
  println(apply_twice(inc, 5));
  println(apply_twice(double, 3));
  println(apply_twice(square, 2));
}

