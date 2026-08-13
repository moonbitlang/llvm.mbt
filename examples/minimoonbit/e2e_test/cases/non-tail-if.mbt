extern "C" fn print_int(x : Int) = "print_int";
extern "C" fn truncate(x : Double) -> Int = "truncate";

fn main {
  let x = truncate(1.23);
  let y = truncate(4.56);
  let z = truncate(-7.89);
  print_int(
    (if 0 <= z { x } else { y }) +
    (if x <= 0 { y } else { z }) +
    (if 0 <= y { z } else { x })
  )  
}
