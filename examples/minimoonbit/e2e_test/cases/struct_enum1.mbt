// 结构体与枚举共存测试1：基本组合
enum Option {
  None;
  Some(Int);
}

struct Container {
  value: Option;
  default: Int;
}

fn get_value(c: Container) -> Int {
  match c.value {
    None => c.default;
    Some(v) => v;
  }
}

fn main {
  let c1 = Container::{ value: Some(42), default: 0 };
  let c2 = Container::{ value: None, default: 10 };
  
  println(get_value(c1));
  println(get_value(c2));
}

