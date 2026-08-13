extern "C" fn print_int(x : Int) = "print_int";
extern "C" fn int_of_float(x : Double) -> Int = "int_of_float";
extern "C" fn sqrt(x : Double) -> Double = "sqrt";

struct Point {
  x: Double;
  y: Double;
  distanceTo: (Point) -> Double;
  isInCircle: (Circle) -> Bool;
}

fn new_point(x: Double, y: Double) -> Point {
  fn fake_distanceTo(p: Point) {
    0.0
  }
  fn fake_isInCircle(c: Circle) {
    false
  }
  let p : Point = Point::{
    x: x, y: y,
    distanceTo: fake_distanceTo,
    isInCircle: fake_isInCircle
  };
  fn real_distanceTo(other: Point) {
    sqrt((p.x - other.x)* (p.x - other.x) + (p.y - other.y)*(p.y - other.y))
  }
  fn real_isInCircle(c: Circle) {
    real_distanceTo(c.center) <= c.radius
  }
  let real_p : Point = Point::{
    x: x, y: y,
    distanceTo: real_distanceTo,
    isInCircle: real_isInCircle
  };
  real_p
}

struct Circle {
  center: Point;
  radius: Double;
  area: (Unit) -> Double;
}

fn new_circle(center: Point, radius: Double) -> Circle {
  fn fake_area(t: Unit) {
    0.0
  }
  let c : Circle = Circle::{
    center: center,
    radius: radius,
    area: fake_area
  };
  fn real_area(t: Unit) {
    3.14159 * c.radius * c.radius
  }
  let real_c : Circle = Circle::{
    center: center,
    radius: radius,
    area: real_area
  };
  real_c
}

fn main {
  let p1 = new_point(0.0, 0.0);
  let p2 = new_point(3.0, 4.0);
  let c = new_circle(new_point(1.0, 1.0), 5.0);
  
  let d = (p1.distanceTo)(p2);
  let a = (c.area)(());
  let inside = (p2.isInCircle)(c);

  print_int(int_of_float(d));
  print_int(int_of_float(a));
  print_int(if inside { 1 } else { 0 });
}
