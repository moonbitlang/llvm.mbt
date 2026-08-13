// 基础测试10：混合运算和复杂控制流
fn collatz_length(n: Int) -> Int {
  let mut count = 0;
  let mut current = n;
  while current != 1 {
    if current % 2 == 0 {
      current = current / 2;
    } else {
      current = 3 * current + 1;
    };
    count = count + 1;
  }
  count
}

fn is_prime(n: Int) -> Bool {
  if n <= 1 {
    false
  } else if n <= 3 {
    true
  } else if n % 2 == 0 {
    false
  } else {
    let mut i = 3;
    let mut is_p = true;
    while i * i <= n {
      if n % i == 0 {
        is_p = false;
      };
      i = i + 2;
    }
    is_p
  }
}

fn count_primes(limit: Int) -> Int {
  let mut count = 0;
  let mut i = 2;
  while i <= limit {
    if is_prime(i) {
      count = count + 1;
    };
    i = i + 1;
  }
  count
}

fn main {
  println(collatz_length(27));
  
  if is_prime(17) {
    println(1);
  } else {
    println(0);
  }
  
  if is_prime(20) {
    println(1);
  } else {
    println(0);
  }
  
  println(count_primes(20));
}

