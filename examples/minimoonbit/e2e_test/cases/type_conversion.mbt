// Test type conversions between Int, Int64, Float, and Double

fn test_int_conversions() -> Unit {
  let n = 42;
  
  // Int to other types
  let n64: Int64 = n.to_int64();
  let nf: Float = n.to_float();
  let nd: Double = n.to_double();
  
  println(n);
  println(n64);
  println(nf);
  println(nd);
}

fn test_int64_conversions() -> Unit {
  let n64: Int64 = 100L;
  
  // Int64 to other types
  let n: Int = n64.to_int();
  let nf: Float = n64.to_float();
  let nd: Double = n64.to_double();
  
  println(n64);
  println(n);
  println(nf);
  println(nd);
}

fn test_float_conversions() -> Unit {
  let f: Float = 3.14F;
  
  // Float to other types
  let n: Int = f.to_int();
  let n64: Int64 = f.to_int64();
  let d: Double = f.to_double();
  
  println(f);
  println(n);
  println(n64);
  println(d);
}

fn test_double_conversions() -> Unit {
  let d: Double = 2.718;
  
  // Double to other types
  let n: Int = d.to_int();
  let n64: Int64 = d.to_int64();
  
  println(d);
  println(n);
  println(n64);
  
  // NOTE: Double.to_float() is commented out due to MoonLLVM issue
  // The generated LLVM IR produces float constants with 64-bit hex format
  // which is invalid (should be 32-bit for float type)
  let f: Float = d.to_float();
  println(f);
}

fn compute_fibonacci_with_conversions(n: Int) -> Double {
  if n <= 1 {
    n.to_double()
  } else {
    let mut a: Double = 0.0;
    let mut b: Double = 1.0;
    let mut i = 2;
    while i <= n {
      let tmp: Double = a + b;
      a = b;
      b = tmp;
      i = i + 1;
    }
    b
  }
}

fn test_complex_conversions() -> Unit {
  // Test conversions in a more complex scenario
  let nums: Array[Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  let mut sum_float: Float = 0.0F;
  let mut sum_double: Double = 0.0;
  
  for i = 0; i < nums.length(); i = i + 1 {
    let val = nums[i];
    sum_float = sum_float + val.to_float();
    sum_double = sum_double + val.to_double();
  }
  
  println(sum_float);
  println(sum_double);
  
  // Convert back
  let sum_int: Int = sum_double.to_int();
  let sum_int64: Int64 = sum_double.to_int64();
  println(sum_int);
  println(sum_int64);
  
  // Fibonacci test
  let fib10: Double = compute_fibonacci_with_conversions(10);
  println(fib10);
  let fib10_int: Int = fib10.to_int();
  println(fib10_int);
}

fn test_uint_conversions() -> Unit {
  let u: UInt = 50U;
  
  // UInt to other types
  let n: Int = u.to_int();
  let n64: Int64 = u.to_int64();
  let u64: UInt64 = u.to_uint64();
  let d: Double = u.to_double();
  
  println(u);
  println(n);
  println(n64);
  println(u64);
  println(d);
}

fn test_uint64_conversions() -> Unit {
  let u64: UInt64 = 200UL;
  
  // UInt64 to other types
  let n: Int = u64.to_int();
  let n64: Int64 = u64.to_int64();
  let u: UInt = u64.to_uint();
  let d: Double = u64.to_double();
  
  println(u64);
  println(n);
  println(n64);
  println(u);
  println(d);
}

fn main {
  test_int_conversions();
  test_int64_conversions();
  test_float_conversions();
  test_double_conversions();
  test_complex_conversions();
  test_uint_conversions();
  test_uint64_conversions();
}

