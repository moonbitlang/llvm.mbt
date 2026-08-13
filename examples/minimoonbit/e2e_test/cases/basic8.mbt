// 基础测试8：逻辑运算和布尔值
fn is_even(n: Int) -> Bool {
  n % 2 == 0
}

fn is_positive(n: Int) -> Bool {
  n > 0
}

fn in_range(n: Int, low: Int, high: Int) -> Bool {
  n >= low && n <= high
}

fn xor(a: Bool, b: Bool) -> Bool {
  (a || b) && !(a && b)
}

fn main {
  let n1 = 10;
  let n2 = 15;
  
  if is_even(n1) {
    println(1);
  } else {
    println(0);
  };
  
  if is_even(n2) {
    println(1);
  } else {
    println(0);
  };
  
  if in_range(5, 1, 10) {
    println(1);
  } else {
    println(0);
  };
  
  if in_range(15, 1, 10) {
    println(1);
  } else {
    println(0);
  };
  
  if xor(true, false) {
    println(1);
  } else {
    println(0);
  };
  
  if xor(true, true) {
    println(1);
  } else {
    println(0);
  };
}

