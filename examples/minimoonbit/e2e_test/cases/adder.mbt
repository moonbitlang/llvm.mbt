extern "C" fn print_int(x : Int) = "print_int"

fn make_adder(x: Int) -> (Int) -> Int {
  fn adder(y: Int) -> Int {
    x + y
  }
  adder
}

fn main {
  print_int((make_adder(3))(7))
}
