extern "C" fn print_int(x : Int) = "print_int";


fn f(x: Int) -> Int {
  x+1
}

fn main {
  print_int(f(1000))
}
