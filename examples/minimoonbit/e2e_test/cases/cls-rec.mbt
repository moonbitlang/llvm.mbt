extern "C" fn print_int(x : Int) = "print_int";


let x = 10;

fn f(y: Int) -> Int {
  if y == 0 {
    0
  } else {
    x + f(y - 1)
  }
}

fn main {
  print_int(f(12))
}
