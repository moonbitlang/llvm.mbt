struct Point {
  x: Double
  y: Double
}

fn Point::new(x: Double, y: Double) -> Point {
  Point::{ x: x, y: y }
}

struct Rectangle {
  x: Double
  y: Double
  width: Double
  height: Double
}

fn Rectangle::new(x: Double, y: Double, width: Double, height: Double) -> Rectangle {
  Rectangle::{ x: x, y: y, width: width, height: height }
}

fn Rectangle::area(self: Rectangle) -> Double {
  self.width * self.height
}

fn Rectangle::perimeter(self: Rectangle) -> Double {
  2.0 * (self.width + self.height)
}

fn Rectangle::contains(self: Rectangle, p: Point) -> Bool {
  p.x >= self.x && p.x <= self.x + self.width &&
  p.y >= self.y && p.y <= self.y + self.height
}

fn Rectangle::intersects(self: Rectangle, other: Rectangle) -> Bool {
  let no_overlap = 
    self.x + self.width < other.x ||
    other.x + other.width < self.x ||
    self.y + self.height < other.y ||
    other.y + other.height < self.y;
  
  if no_overlap {
    false
  } else {
    true
  }
}

fn Rectangle::center(self: Rectangle) -> Point {
  let cx = self.x + self.width / 2.0;
  let cy = self.y + self.height / 2.0;
  Point::new(cx, cy)
}

fn Rectangle::expand(self: Rectangle, amount: Double) -> Rectangle {
  Rectangle::new(
    self.x - amount,
    self.y - amount,
    self.width + 2.0 * amount,
    self.height + 2.0 * amount
  )
}

fn main {
  let rect1 = Rectangle::new(0.0, 0.0, 10.0, 5.0);
  let rect2 = Rectangle::new(8.0, 3.0, 6.0, 4.0);
  let rect3 = Rectangle::new(20.0, 20.0, 5.0, 5.0);
  
  println("Rectangle 1: x=" + rect1.x.to_string() + ", y=" + rect1.y.to_string() +
           ", width=" + rect1.width.to_string() + ", height=" + rect1.height.to_string());
  
  let area1 = rect1.area();
  println("Area of rect1: " + area1.to_string());
  
  let perim1 = rect1.perimeter();
  println("Perimeter of rect1: " + perim1.to_string());
  
  let center1 = rect1.center();
  println("Center of rect1: (" + center1.x.to_string() + ", " + center1.y.to_string() + ")");
  
  let point1 = Point::new(5.0, 2.5);
  let contains1 = rect1.contains(point1);
  if contains1 {
    println("rect1 contains point (5, 2.5)");
  } else {
    println("rect1 does not contain point (5, 2.5)");
  }
  
  let point2 = Point::new(15.0, 10.0);
  let contains2 = rect1.contains(point2);
  if contains2 {
    println("rect1 contains point (15, 10)");
  } else {
    println("rect1 does not contain point (15, 10)");
  }
  
  let intersects12 = rect1.intersects(rect2);
  if intersects12 {
    println("rect1 and rect2 intersect");
  } else {
    println("rect1 and rect2 do not intersect");
  }
  
  let intersects13 = rect1.intersects(rect3);
  if intersects13 {
    println("rect1 and rect3 intersect");
  } else {
    println("rect1 and rect3 do not intersect");
  }
  
  let expanded = rect1.expand(2.0);
  println("Expanded rect1: x=" + expanded.x.to_string() + ", y=" + expanded.y.to_string() +
           ", width=" + expanded.width.to_string() + ", height=" + expanded.height.to_string());
}

