
extern "C" fn print_int(x : Int) = "print_int";
extern "C" fn print_endline() = "print_endline";

struct Integer {
  v: Array[Int];
  plus: (Integer, Integer) -> Unit;
  less: (Integer, Integer) -> Bool;
  to_int: (Integer) -> Int;
}

fn new_integer(v: Int) -> Integer {
  fn plus(a: Integer, b: Integer) -> Unit {
    a.v[0] = a.v[0] + b.v[0];
  }
  fn to_int(a: Integer) -> Int {
    a.v[0]
  }
  fn less(a: Integer, b: Integer) -> Bool {
    a.v[0] < b.v[0]
  }
  Integer::{ v: Array::make(1, v), plus: plus, less: less, to_int: to_int }
}

fn main {
  let i = new_integer(0);
  let j = new_integer(10);
  let k = new_integer(1);
  while (i.less)(i, j) {
    (i.plus)(i, k);
  }

  print_int((i.to_int)(i));
  print_endline()
}
