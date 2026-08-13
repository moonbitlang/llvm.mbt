
extern "C" fn print_int(x : Int) = "print_int"

fn f(x: Int) -> Int {
  x + 123
}

fn g(y: Int) -> (Int) -> Int {
  f
}

fn main {
  print_int((g(456))(789))
}
