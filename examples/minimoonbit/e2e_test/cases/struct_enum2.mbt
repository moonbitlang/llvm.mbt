// 结构体与枚举共存测试2：结构体中的枚举数组
enum Color {
  Red;
  Green;
  Blue;
  RGB(Int, Int, Int);
}

struct Palette {
  colors: Array[Color];
  size: Int;
}

fn count_rgb(p: Palette) -> Int {
  let mut count = 0;
  let mut i = 0;
  while i < p.size {
    match p.colors[i] {
      RGB(_, _, _) => { count = count + 1; };
      _ => { () };
    };
    i = i + 1;
  }
  count
}

fn main {
  let colors = [Red, Green, Blue, RGB(100, 150, 200), RGB(50, 75, 100)];
  let palette = Palette::{ colors: colors, size: 5 };
  
  println(count_rgb(palette));
}

