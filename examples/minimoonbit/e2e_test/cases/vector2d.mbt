extern "C" fn sqrt(x: Double) -> Double = "sqrt";

struct Vec2 {
  x: Double
  y: Double
}

fn Vec2::new(x: Double, y: Double) -> Vec2 {
  Vec2::{ x: x, y: y }
}

fn Vec2::add(self: Vec2, other: Vec2) -> Vec2 {
  Vec2::new(self.x + other.x, self.y + other.y)
}

fn Vec2::sub(self: Vec2, other: Vec2) -> Vec2 {
  Vec2::new(self.x - other.x, self.y - other.y)
}

fn Vec2::scale(self: Vec2, factor: Double) -> Vec2 {
  Vec2::new(self.x * factor, self.y * factor)
}

fn Vec2::length(self: Vec2) -> Double {
  sqrt(self.x * self.x + self.y * self.y)
}

fn Vec2::dot(self: Vec2, other: Vec2) -> Double {
  self.x * other.x + self.y * other.y
}

fn Vec2::cross(self: Vec2, other: Vec2) -> Double {
  self.x * other.y - self.y * other.x
}

fn Vec2::normalize(self: Vec2) -> Vec2 {
  let len = self.length();
  if len > 0.0 {
    self.scale(1.0 / len)
  } else {
    Vec2::new(0.0, 0.0)
  }
}

fn Vec2::distance(self: Vec2, other: Vec2) -> Double {
  let diff = self.sub(other);
  diff.length()
}

fn main {
  let v1 = Vec2::new(3.0, 4.0);
  let v2 = Vec2::new(1.0, 2.0);
  
  println("v1 = (" + v1.x.to_string() + ", " + v1.y.to_string() + ")");
  println("v2 = (" + v2.x.to_string() + ", " + v2.y.to_string() + ")");
  
  let sum = v1.add(v2);
  println("v1 + v2 = (" + sum.x.to_string() + ", " + sum.y.to_string() + ")");
  
  let diff = v1.sub(v2);
  println("v1 - v2 = (" + diff.x.to_string() + ", " + diff.y.to_string() + ")");
  
  let scaled = v1.scale(2.0);
  println("v1 * 2 = (" + scaled.x.to_string() + ", " + scaled.y.to_string() + ")");
  
  let len = v1.length();
  println("length of v1 = " + len.to_string());
  
  let dot_prod = v1.dot(v2);
  println("v1 . v2 = " + dot_prod.to_string());
  
  let cross_prod = v1.cross(v2);
  println("v1 x v2 = " + cross_prod.to_string());
  
  let normalized = v1.normalize();
  println("normalized v1 = (" + normalized.x.to_string() + ", " + normalized.y.to_string() + ")");
  
  let dist = v1.distance(v2);
  println("distance between v1 and v2 = " + dist.to_string());
}

