
extern "C" fn print_int(x : Int) = "print_int"

fn f(n: Int) -> Unit {
  if !(0 <= n) {
    ()
  } else {
    let t1 = print_int(n);
    let a = Array::make(1, f);
    let a0 = a[0]
    a0(n - 1)
  }
}

fn main{
  f(9)
}
