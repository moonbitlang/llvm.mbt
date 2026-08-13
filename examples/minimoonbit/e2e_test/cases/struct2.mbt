// 结构体测试2：包含元组和函数的结构体
struct Calculator {
  add: (Int, Int) -> Int;
  sub: (Int, Int) -> Int;
  mul: (Int, Int) -> Int;
}

struct Pair {
  data: (Int, Int);
  sum: (Pair) -> Int;
  product: (Pair) -> Int;
}

fn make_calculator() -> Calculator {
  fn add(a: Int, b: Int) -> Int {
    a + b
  }
  
  fn sub(a: Int, b: Int) -> Int {
    a - b
  }
  
  fn mul(a: Int, b: Int) -> Int {
    a * b
  }
  
  Calculator::{ add: add, sub: sub, mul: mul }
}

fn make_pair(x: Int, y: Int) -> Pair {
  fn sum(p: Pair) -> Int {
    let (a, b) = p.data;
    a + b
  }
  
  fn product(p: Pair) -> Int {
    let (a, b) = p.data;
    a * b
  }
  
  Pair::{ data: (x, y), sum: sum, product: product }
}

fn main {
  let calc = make_calculator();
  println((calc.add)(3, 4));
  println((calc.sub)(10, 3));
  println((calc.mul)(5, 6));
  
  let p = make_pair(7, 8);
  let (x, y) = p.data;
  println(x);
  println(y);
  println((p.sum)(p));
  println((p.product)(p));
}

