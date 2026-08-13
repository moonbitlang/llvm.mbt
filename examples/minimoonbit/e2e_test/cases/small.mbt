extern "C" fn print_int(x : Int) = "print_int";

fn add(a: Int, b: Int) -> Int {
  a + b
}

fn main {
  let x = -3 + add(5, 2);
  print_int(x);
}
