// 结构体测试1：基本结构体
struct Point {
  x: Int;
  y: Int;
}

struct Point3D {
  x: Int;
  y: Int;
  z: Int;
}

fn distance_2d(p1: Point, p2: Point) -> Int {
  let dx = p1.x - p2.x;
  let dy = p1.y - p2.y;
  dx * dx + dy * dy
}

fn distance_3d(p1: Point3D, p2: Point3D) -> Int {
  let dx = p1.x - p2.x;
  let dy = p1.y - p2.y;
  let dz = p1.z - p2.z;
  dx * dx + dy * dy + dz * dz
}

fn main {
  let p1 = Point::{ x: 1, y: 2 };
  let p2 = Point::{ x: 4, y: 6 };
  
  println(p1.x);
  println(p1.y);
  println(distance_2d(p1, p2));
  
  let p3 = Point3D::{ x: 1, y: 2, z: 3 };
  let p4 = Point3D::{ x: 4, y: 5, z: 6 };
  
  println(distance_3d(p3, p4));
}


