extern "C" fn print_int(x: Int) -> Unit = "print_int";
extern "C" fn print_endline() -> Unit = "print_endline";
extern "C" fn int_of_float(x: Double) -> Int = "int_of_float";

enum List {
  Nil;
  Cons(Matrix2D, List);
}

fn new_list() -> List {
  List::Nil
}

fn push(list: List, item: Matrix2D) -> List {
  match list {
    Nil => Cons(item, Nil);
    Cons(head, tail) => Cons(head, push(tail, item));
  }
}

fn fold(list: List, init: Matrix2D) -> Matrix2D {
  match list {
    Nil => init;
    Cons(head, tail) => fold(tail, mat_mul(init, head));
  }
}

struct Matrix2D {
  a: Double;
  b: Double;
  c: Double;
  d: Double;
}

fn new_mat(a: Double, b: Double, c: Double, d: Double) -> Matrix2D {
  Matrix2D::{ a:a, b:b, c:c, d:d }
}

fn mat_mul(x: Matrix2D, y: Matrix2D) -> Matrix2D {
  Matrix2D::{
    a: x.a * y.a + x.b * y.c,
    b: x.a * y.b + x.b * y.d,
    c: x.c * y.a + x.d * y.c,
    d: x.c * y.b + x.d * y.d
  }
}

fn main {
  let mut list = new_list();
  let mat = new_mat(2.0, 0.0, 0.0, 4.0);

  let mut i = 0;
  let len = 10;
  while i < len {
    list = push(list, mat);
    i = i + 1;
  }

  let result = fold(list, new_mat(1.0, 0.0, 0.0, 1.0));

  print_int(int_of_float(result.a));
  print_endline();
  print_int(int_of_float(result.b));
  print_endline();
  print_int(int_of_float(result.c));
  print_endline();
  print_int(int_of_float(result.d));
  print_endline();
}
