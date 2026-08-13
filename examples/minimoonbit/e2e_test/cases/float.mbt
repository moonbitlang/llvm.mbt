extern "C" fn print_int(x : Int) = "print_int";
extern "C" fn sin(x : Double) -> Double = "sin";
extern "C" fn cos(x : Double) -> Double = "cos";
extern "C" fn sqrt(x : Double) -> Double = "sqrt";
extern "C" fn int_of_float(x : Double) -> Int = "int_of_float";
extern "C" fn float_of_int(x : Int) -> Double = "float_of_int";
extern "C" fn abs_float(x : Double) -> Double = "abs_float";



fn main {
  print_int(
    int_of_float(
      (sin(cos(sqrt(abs_float(-12.3)))) + 4.5 - 6.7 * 8.9 / 1.23456789) * float_of_int(1000000)
    )
  )
}
