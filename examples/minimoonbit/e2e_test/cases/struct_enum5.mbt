// 结构体与枚举共存测试5：带方法的结构体和枚举
enum Operation {
  Add;
  Sub;
  Mul;
  Div;
}

struct Calculator {
  execute: (Operation, Int, Int) -> Int;
}

fn make_calculator() -> Calculator {
  fn execute(op: Operation, a: Int, b: Int) -> Int {
    match op {
      Add => a + b;
      Sub => a - b;
      Mul => a * b;
      Div => a / b;
    }
  }
  
  Calculator::{ execute: execute }
}

fn main {
  let calc = make_calculator();
  
  println((calc.execute)(Add, 10, 5));
  println((calc.execute)(Sub, 10, 5));
  println((calc.execute)(Mul, 10, 5));
  println((calc.execute)(Div, 10, 5));
}

