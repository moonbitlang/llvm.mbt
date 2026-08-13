// 基础测试6：递归函数
fn fib(n: Int) -> Int {
  if n <= 1 {
    n
  } else {
    fib(n - 1) + fib(n - 2)
  }
}

fn gcd(a: Int, b: Int) -> Int {
  if b == 0 {
    a
  } else {
    gcd(b, a % b)
  }
}

fn sum_digits(n: Int) -> Int {
  if n < 10 {
    n
  } else {
    (n % 10) + sum_digits(n / 10)
  }
}

fn main {
  println(fib(10));
  println(gcd(48, 18));
  println(sum_digits(12345));
}

