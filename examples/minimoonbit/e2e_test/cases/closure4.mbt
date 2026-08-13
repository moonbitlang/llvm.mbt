// 闭包测试4：闭包作为函数参数和返回值
fn apply(f: (Int) -> Int, x: Int) -> Int {
  f(x)
}

fn compose(f: (Int) -> Int, g: (Int) -> Int) -> (Int) -> Int {
  fn composed(x: Int) -> Int {
    f(g(x))
  }
  composed
}

fn main {
  fn make_add(n: Int) -> (Int) -> Int {
    fn add(x: Int) -> Int {
      x + n
    }
    add
  }
  
  fn make_mul(n: Int) -> (Int) -> Int {
    fn mul(x: Int) -> Int {
      x * n
    }
    mul
  }
  
  let add3 = make_add(3);
  let mul2 = make_mul(2);
  
  println(apply(add3, 5));
  println(apply(mul2, 5));
  
  let f = compose(add3, mul2);
  println(f(5));
  
  let g = compose(mul2, add3);
  println(g(5));
}

