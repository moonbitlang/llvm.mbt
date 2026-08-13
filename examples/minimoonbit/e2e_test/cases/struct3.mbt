// 结构体测试3：嵌套结构体
struct Inner {
  value: Int;
}

struct Middle {
  inner: Inner;
  scale: Int;
}

struct Outer {
  middle: Middle;
  offset: Int;
}

fn get_value(outer: Outer) -> Int {
  outer.middle.inner.value * outer.middle.scale + outer.offset
}

fn main {
  let inner = Inner::{ value: 5 };
  let middle = Middle::{ inner: inner, scale: 3 };
  let outer = Outer::{ middle: middle, offset: 10 };
  
  println(get_value(outer));
  
  let outer2 = Outer::{
    middle: Middle::{
      inner: Inner::{ value: 7 },
      scale: 2
    },
    offset: 5
  };
  
  println(get_value(outer2));
}

