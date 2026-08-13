
extern "C" fn print_int(x : Int) = "print_int";

fn fib(n : Int) -> Int {
  if n <= 1 {
    return n
  }
  fib(n - 1) + fib(n - 2)
}

fn main {
  let result = fib(10)
  print_int(result)
}
