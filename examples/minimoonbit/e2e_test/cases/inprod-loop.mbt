extern "C" fn print_int(x : Int) = "print_int"
extern "C" fn truncate(x : Double) -> Int = "truncate"

fn inprod(v1: Array[Double], v2: Array[Double], len: Int) -> Double {
  let mut res : Double = 0.0
  let mut idx = 0
  while idx < len {
    res = res + v1[idx] * v2[idx];
    idx = idx + 1
  }
  res
}

fn main {
  let v1 = Array::make(3, 1.23);
  let v2 = Array::make(3, 4.56)
  print_int(truncate(1000000.0 * inprod(v1, v2, 3)))
}
