// 闭包测试3：多层捕获
fn make_adder_maker(base: Int) -> (Int) -> (Int) -> Int {
  fn make_adder(x: Int) -> (Int) -> Int {
    fn adder(y: Int) -> Int {
      base + x + y
    }
    adder
  }
  make_adder
}

fn main {
  let maker = make_adder_maker(100);
  let add_110 = maker(10);
  let add_125 = maker(25);
  
  println(add_110(5));
  println(add_125(5));
  println(add_110(add_125(0)));
}

