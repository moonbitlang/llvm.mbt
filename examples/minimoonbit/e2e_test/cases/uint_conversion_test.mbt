// Test for UInt and UInt64 type conversions

fn test_uint_to_int() -> Unit {
  let u: UInt = 100U;
  let i: Int = u.to_int();
  println(i);
}

fn test_uint_to_int64() -> Unit {
  let u: UInt = 200U;
  let i64: Int64 = u.to_int64();
  println(i64);
}

fn test_uint_to_uint64() -> Unit {
  let u: UInt = 300U;
  let u64: UInt64 = u.to_uint64();
  println(u64);
}

fn test_uint64_to_int() -> Unit {
  let u64: UInt64 = 400UL;
  let i: Int = u64.to_int();
  println(i);
}

fn test_uint64_to_uint() -> Unit {
  let u64: UInt64 = 500UL;
  let u: UInt = u64.to_uint();
  println(u);
}

fn test_int_to_uint() -> Unit {
  let i: Int = 123;
  let u: UInt = i.to_uint();
  println(u);
}

fn test_uint_to_string() -> Unit {
  let u: UInt = 999U;
  let s: String = u.to_string();
  println(s);
}

fn test_uint64_to_string() -> Unit {
  let u64: UInt64 = 888UL;
  let s: String = u64.to_string();
  println(s);
}

fn test_uint_to_double() -> Unit {
  let u: UInt = 50U;
  let d: Double = u.to_double();
  println(d);
}

fn test_uint64_to_double() -> Unit {
  let u64: UInt64 = 75UL;
  let d: Double = u64.to_double();
  println(d);
}

fn main {
  test_uint_to_int();
  test_uint_to_int64();
  test_uint_to_uint64();
  test_uint64_to_int();
  test_uint64_to_uint();
  test_int_to_uint();
  test_uint_to_string();
  test_uint64_to_string();
  test_uint_to_double();
  test_uint64_to_double();
}

