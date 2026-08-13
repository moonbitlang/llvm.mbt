// Test to_string() conversions for all types

fn test_int_to_string() -> Unit {
  let n1 = 42;
  let n2 = 17;
  let n3 = 0;
  
  let s1: String = n1.to_string();
  let s2: String = n2.to_string();
  let s3: String = n3.to_string();
  
  println(s1);
  println(s2);
  println(s3);
}

fn test_int64_to_string() -> Unit {
  let n1: Int64 = 123456789L;
  let n2: Int64 = 987654321L;
  let n3: Int64 = 0L;
  
  let s1: String = n1.to_string();
  let s2: String = n2.to_string();
  let s3: String = n3.to_string();
  
  println(s1);
  println(s2);
  println(s3);
}

fn test_float_to_string() -> Unit {
  let f1: Float = 3.14F;
  let f2: Float = 2.5F;
  let f3: Float = 0.0F;
  
  let s1: String = f1.to_string();
  let s2: String = f2.to_string();
  let s3: String = f3.to_string();
  
  println(s1);
  println(s2);
  println(s3);
}

fn test_double_to_string() -> Unit {
  let d1: Double = 2.718;
  let d2: Double = 1.414;
  let d3: Double = 0.0;
  
  let s1: String = d1.to_string();
  let s2: String = d2.to_string();
  let s3: String = d3.to_string();
  
  println(s1);
  println(s2);
  println(s3);
}

fn test_char_to_string() -> Unit {
  let c1 = 'A';
  let c2: Char = 'z';
  let c3 = '0';
  
  let s1: String = c1.to_string();
  let s2: String = c2.to_string();
  let s3: String = c3.to_string();
  
  println(s1);
  println(s2);
  println(s3);
}

fn compute_sum_and_format() -> Unit {
  let nums: Array[Int] = [12, 34, 56, 78, 90];
  let mut sum = 0;
  
  for i = 0; i < nums.length(); i = i + 1 {
    sum = sum + nums[i];
  }
  
  let result_str: String = "Sum: " + sum.to_string();
  println(result_str);
}

fn factorial_to_string(n: Int) -> String {
  let mut result: Int64 = 1L;
  let mut i = 1;
  
  while i <= n {
    result = result * i.to_int64();
    i = i + 1;
  }
  
  result.to_string()
}

fn test_complex_string_building() -> Unit {
  compute_sum_and_format();
  
  // Calculate factorials and format them
  let mut i = 1;
  while i <= 10 {
    let fact_str: String = "Factorial " + i.to_string() + ": " + factorial_to_string(i);
    println(fact_str);
    i = i + 1;
  }
}

fn main {
  test_int_to_string();
  test_int64_to_string();
  test_float_to_string();
  test_double_to_string();
  test_char_to_string();
  test_complex_string_building();
}
