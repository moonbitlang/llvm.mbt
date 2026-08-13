// Test reinterpret_as (bitcast) operations

fn test_int_reinterpret() -> Unit {
  // Reinterpret Int as Float
  let n1 = 1065353216;  // IEEE 754 representation of 1.0
  let f1: Float = n1.reinterpret_as_float();
  println(n1);
  println(f1);
  
  let n2 = 0;
  let f2: Float = n2.reinterpret_as_float();
  println(n2);
  println(f2);
}

fn test_float_reinterpret() -> Unit {
  // Reinterpret Float as Int
  let f1: Float = 1.0F;
  let n1: Int = f1.reinterpret_as_int();
  println(f1);
  println(n1);
  
  let f2: Float = 0.0F;
  let n2: Int = f2.reinterpret_as_int();
  println(f2);
  println(n2);
}

fn test_int64_reinterpret() -> Unit {
  // Reinterpret Int64 as Double
  let n1: Int64 = 4607182418800017408L;  // IEEE 754 representation of 1.0
  let d1: Double = n1.reinterpret_as_double();
  println(n1);
  println(d1);
  
  let n2: Int64 = 0L;
  let d2: Double = n2.reinterpret_as_double();
  println(n2);
  println(d2);
}

fn test_double_reinterpret() -> Unit {
  // Reinterpret Double as Int64
  let d1: Double = 1.0;
  let n1: Int64 = d1.reinterpret_as_int64();
  println(d1);
  println(n1);
  
  let d2: Double = 0.0;
  let n2: Int64 = d2.reinterpret_as_int64();
  println(d2);
  println(n2);
}

fn analyze_float_bits() -> Unit {
  // Analyze the bit pattern of a float
  let values: Array[Float] = [1.0F, 2.0F, 3.0F, -1.0F, 0.5F];
  
  for i = 0; i < values.length(); i = i + 1 {
    let f: Float = values[i];
    let bits: Int = f.reinterpret_as_int();
    println(f);
    println(bits);
  }
}

fn analyze_double_bits() -> Unit {
  // Analyze the bit pattern of a double
  let values: Array[Double] = [1.0, 2.0, 3.0, -1.0, 0.5];
  
  for i = 0; i < values.length(); i = i + 1 {
    let d: Double = values[i];
    let bits: Int64 = d.reinterpret_as_int64();
    println(d);
    println(bits);
  }
}

fn swap_and_reinterpret() -> Unit {
  // Test round-trip conversions
  let original_int = 42;
  let as_float: Float = original_int.reinterpret_as_float();
  let back_to_int: Int = as_float.reinterpret_as_int();
  
  println(original_int);
  println(as_float);
  println(back_to_int);
  
  // Verify round-trip works
  if original_int == back_to_int {
    println("Round-trip Int->Float->Int successful");
  } else {
    println("Round-trip Int->Float->Int failed");
  }
  
  let original_int64: Int64 = 123456789L;
  let as_double: Double = original_int64.reinterpret_as_double();
  let back_to_int64: Int64 = as_double.reinterpret_as_int64();
  
  println(original_int64);
  println(as_double);
  println(back_to_int64);
  
  if original_int64 == back_to_int64 {
    println("Round-trip Int64->Double->Int64 successful");
  } else {
    println("Round-trip Int64->Double->Int64 failed");
  }
}

fn main {
  test_int_reinterpret();
  test_float_reinterpret();
  test_int64_reinterpret();
  test_double_reinterpret();
  analyze_float_bits();
  analyze_double_bits();
  swap_and_reinterpret();
}

