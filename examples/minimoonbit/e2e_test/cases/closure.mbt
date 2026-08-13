// 闭包测试1：简单的闭包捕获
fn make_adder(x: Int) -> (Int) -> Int {
  fn adder(y: Int) -> Int {
    x + y
  }
  adder
}

fn make_multiplier(x: Int) -> (Int) -> Int {
  fn multiplier(y: Int) -> Int {
    x * y
  }
  multiplier
}

fn main {
  let add5 = make_adder(5);
  let add10 = make_adder(10);
  let mul3 = make_multiplier(3);
  
  println(add5(3));
  println(add10(3));
  println(mul3(4));
  println(add5(add10(2)));
}


