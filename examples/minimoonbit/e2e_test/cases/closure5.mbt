// 闭包测试5：递归闭包
fn make_factorial() -> (Int) -> Int {
  fn factorial(n: Int) -> Int {
    if n <= 1 {
      1
    } else {
      n * factorial(n - 1)
    }
  }
  factorial
}

fn make_sum_to_n() -> (Int) -> Int {
  fn sum_to_n(n: Int) -> Int {
    if n <= 0 {
      0
    } else {
      n + sum_to_n(n - 1)
    }
  }
  sum_to_n
}

fn make_power(base: Int) -> (Int) -> Int {
  fn power(exp: Int) -> Int {
    if exp == 0 {
      1
    } else {
      base * power(exp - 1)
    }
  }
  power
}

fn main {
  let fact = make_factorial();
  let sum = make_sum_to_n();
  let pow2 = make_power(2);
  let pow3 = make_power(3);
  
  println(fact(5));
  println(sum(10));
  println(pow2(8));
  println(pow3(5));
}

