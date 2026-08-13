
extern "C" fn print_int(x : Int) = "print_int";

struct Point {
  x: Int
  y: Int
}

fn point_add(a: Point, b: Point) -> Point {
  Point::{ x: a.x + b.x, y: a.y + b.y }
}

fn main {
  let p1 = Point::{ x: 3, y: 4 };
  let p2 = Point::{ x: 1, y: 2 };
  let p3 = point_add(p1, p2);
  print_int(p3.x);
  print_int(p3.y);
}
