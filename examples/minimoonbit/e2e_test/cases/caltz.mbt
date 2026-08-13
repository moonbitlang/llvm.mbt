
extern "C" fn print_int(x : Int) = "print_int"

fn callatz(input : Int) -> Int {
  let mut cnt = 0
  let mut n = input
  while n > 1 {
    if n % 2 == 0 {
      n = n / 2
      cnt = cnt + 1
    } else {
      n = (3 * n + 1) / 2
      cnt = cnt + 1
    }
  }
  cnt
}

fn main {
  let input = 7
  let result = callatz(input)
  print_int(result);
}
