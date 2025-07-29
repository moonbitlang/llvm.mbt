
///|
fn test_code(code : String) -> Unit raise {
  let prog = Program::parse(lex(code))
  let _ = TypeCheck::check_prog(prog)
  let codegen = CodeGen::init(prog)
  codegen.emitProg()
}

///|
test "tinymoonbit : fib" {
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

test "tinymoonbit : valarray" {
  let code = 
    #|extern fn malloc(sz : Int) -> Ptr[Void];
    #|
    #|struct ValArray {
    #|  ptr: Ptr[Int],
    #|  sz: Int
    #|}
    #|
    #|fn new_valarray(sz : Int) -> ValArray {
    #|  let v : ValArray;
    #|  v.ptr = malloc(sz * sizeof(Int)) as Ptr[Int];
    #|  v.sz = sz;
    #|  return v;
    #|}
    #|

  test_code(code)
}
