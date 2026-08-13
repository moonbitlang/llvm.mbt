// 基础测试5：元组操作
fn make_pair(a: Int, b: Int) -> (Int, Int) {
  (a, b)
}

fn swap(pair: (Int, Int)) -> (Int, Int) {
  let (a, b) = pair;
  (b, a)
}

fn add_pairs(p1: (Int, Int), p2: (Int, Int)) -> (Int, Int) {
  let (a1, b1) = p1;
  let (a2, b2) = p2;
  (a1 + a2, b1 + b2)
}

fn triple_sum(t: (Int, Int, Int)) -> Int {
  let (a, b, c) = t;
  a + b + c
}

fn main {
  let p1 = make_pair(3, 4);
  let (x, y) = p1;
  println(x);
  println(y);
  
  let p2 = swap(p1);
  let (a, b) = p2;
  println(a);
  println(b);
  
  let p3 = add_pairs(p1, p2);
  let (c, d) = p3;
  println(c);
  println(d);
  
  let t = (1, 2, 3);
  println(triple_sum(t));
}

