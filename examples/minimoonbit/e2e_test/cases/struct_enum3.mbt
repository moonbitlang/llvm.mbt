// 结构体与枚举共存测试3：枚举中的结构体
struct Point {
  x: Int;
  y: Int;
}

enum Shape {
  Circle(Point, Int);
  Rectangle(Point, Point);
}

fn area(s: Shape) -> Int {
  match s {
    Circle(_, r) => 3 * r * r;
    Rectangle(p1, p2) => {
      let w = if p2.x > p1.x { p2.x - p1.x } else { p1.x - p2.x };
      let h = if p2.y > p1.y { p2.y - p1.y } else { p1.y - p2.y };
      w * h
    };
  }
}

fn main {
  let center = Point::{ x: 0, y: 0 };
  let circle = Circle(center, 5);
  
  let p1 = Point::{ x: 1, y: 2 };
  let p2 = Point::{ x: 5, y: 7 };
  let rect = Rectangle(p1, p2);
  
  println(area(circle));
  println(area(rect));
}

