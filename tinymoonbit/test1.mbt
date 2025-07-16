///|
fn test_code(code : String) -> Unit raise {
  let prog = Program::parse(lex(code))
  let _ = TypeCheck::check_prog(prog)
  let codegen = CodeGen::init(prog)
  codegen.emitProg()
}

///|
test {
  let code =
    #|extern fn print_int(x : Int) -> Unit;
    #|
    #|// Fibonacci function
    #|fn fib(n : Int) -> Int {
    #|  if n <= 1 {
    #|    return n;
    #|  }
    #|  return fib(n - 1) + fib(n - 2);
    #|}
    #|
    #|fn main {
    #|  print_int(fib(10));
    #|}
  test_code(code)
}
