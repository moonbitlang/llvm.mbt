extern "C" fn print_int(i: Int) -> Unit = "print_int";
extern "C" fn int_of_float(f: Double) -> Int = "int_of_float";
extern "C" fn sqrt(f: Double) -> Double = "sqrt";

enum Shape {
  Point(Double, Double);
  Rect(Shape, Double, Double);
  Circle(Shape, Double);
  Line(Shape, Shape);
}

fn area(shape: Shape) -> Double {
  match shape {
    Circle(Point(_), r) => 3.14159 * r * r;
    Rect(Point(_), w, h) => w * h;
    _ => 0.0;
  }
}

fn length(shape: Shape) -> Double {
  match shape {
    Circle(_, r) => 2.0 * 3.14159 * r;
    Line(Point(x1, y1), Point(x2, y2)) => sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
    Rect(Point(_), w, h) => 2.0 * (w + h);
    _ => 0.0;
  }
}

fn main {
  let c = Circle(Point(0.0, 0.0), 5.0);
  let r = Rect(Point(0.0, 0.0), 4.0, 6.0);
  let l = Line(Point(0.0, 0.0), Point(3.0, 4.0));

  let area_c = area(c);
  let area_r = area(r);
  let length_l = length(l);
  print_int(int_of_float(area_c));
  print_int(int_of_float(area_r));
  print_int(int_of_float(length_l));
}
