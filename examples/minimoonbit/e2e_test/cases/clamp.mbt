extern "C" fn print_int(x : Int) = "print_int"

fn clamp(lower: Int, upper: Int, value: Int) -> Int {
  if value > lower && value < upper {
    value
  } else if value <= lower {
    lower
  } else {
    upper
  }
}

fn main {
  let lower = 10
  let upper = 20
  let value1 = 15
  let value2 = -1
  let value3 = 25

  let result1 = clamp(lower, upper, value1)
  let result2 = clamp(lower, upper, value2)
  let result3 = clamp(lower, upper, value3)

  let result_total = result1 + result2 + result3
  print_int(result_total)
}
