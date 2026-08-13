// ADT测试2：多字段枚举
enum Shape {
  Circle(Int);
  Rectangle(Int, Int);
  Triangle(Int, Int, Int);
}

fn area(s: Shape) -> Int {
  match s {
    Circle(r) => 3 * r * r;
    Rectangle(w, h) => w * h;
    Triangle(a, b, c) => {
      let s = (a + b + c) / 2;
      s * (s - a) / 10
    };
  }
}

fn perimeter(s: Shape) -> Int {
  match s {
    Circle(r) => 6 * r;
    Rectangle(w, h) => 2 * (w + h);
    Triangle(a, b, c) => a + b + c;
  }
}

fn main {
  let circle = Circle(5);
  let rect = Rectangle(4, 6);
  let tri = Triangle(3, 4, 5);
  
  println(area(circle));
  println(area(rect));
  println(area(tri));
  
  println(perimeter(circle));
  println(perimeter(rect));
  println(perimeter(tri));
}

