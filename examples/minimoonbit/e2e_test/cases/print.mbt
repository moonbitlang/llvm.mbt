
extern "C" fn print_int(x : Int) = "print_int";

fn main {
  let _ = print_int(123);
  let _ = print_int(-456);
  let _ = print_int(789 + 0);
  ()
}
