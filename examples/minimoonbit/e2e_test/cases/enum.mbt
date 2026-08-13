// ADT测试1：简单枚举和模式匹配
enum Status {
  Success;
  Failure;
  Pending;
}

enum Result {
  Ok(Int);
  Err(Int);
}

fn status_to_int(s: Status) -> Int {
  match s {
    Success => 1;
    Failure => 0;
    Pending => 0 - 1;
  }
}

fn result_value(r: Result) -> Int {
  match r {
    Ok(v) => v;
    Err(code) => 0 - code;
  }
}

fn main {
  let s1 = Success;
  let s2 = Failure;
  let s3 = Pending;
  
  println(status_to_int(s1));
  println(status_to_int(s2));
  println(status_to_int(s3));
  
  let r1 = Ok(42);
  let r2 = Err(404);
  
  println(result_value(r1));
  println(result_value(r2));
}


