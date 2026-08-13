// 基础测试4：while循环和可变变量
fn sum_to_n(n: Int) -> Int {
  let mut sum = 0;
  let mut i = 1;
  while i <= n {
    sum = sum + i;
    i = i + 1;
  }
  sum
}

fn factorial(n: Int) -> Int {
  let mut result = 1;
  let mut i = 1;
  while i <= n {
    result = result * i;
    i = i + 1;
  }
  result
}

fn power(base: Int, exp: Int) -> Int {
  let mut result = 1;
  let mut i = 0;
  while i < exp {
    result = result * base;
    i = i + 1;
  }
  result
}

fn main {
  println(sum_to_n(10));
  println(factorial(5));
  println(power(2, 8));
}

