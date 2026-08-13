// 闭包测试2：闭包作为数组元素
fn make_counter(start: Int, step: Int) -> (Int) -> Int {
  fn counter(n: Int) -> Int {
    start + step * n
  }
  counter
}

fn main {
  let counters = [make_counter(0, 1), make_counter(10, 2), make_counter(100, 5)];
  
  let mut i = 0;
  while i < 3 {
    let mut j = 0;
    while j < 5 {
      println(counters[i](j));
      j = j + 1;
    }
    i = i + 1;
  }
}

