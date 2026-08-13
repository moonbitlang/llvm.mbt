// Test for UInt and UInt64 basic operations

fn test_uint_arithmetic() -> Unit {
  println("=== UInt Arithmetic ===");
  
  let a: UInt = 100U;
  let b: UInt = 200U;
  let c = a + b;
  println(c);  // 300
  
  let d: UInt = 50U;
  let e = c - d;
  println(e);  // 250
  
  let f: UInt = 10U;
  let g: UInt = 5U;
  let h = f * g;
  println(h);  // 50
  
  let i = b / f;
  println(i);  // 20
  
  let j = b % f;
  println(j);  // 0
  
  let k: UInt = 17U;
  let l = k % g;
  println(l);  // 2
}

fn test_uint64_arithmetic() -> Unit {
  println("=== UInt64 Arithmetic ===");
  
  let a: UInt64 = 1000UL;
  let b: UInt64 = 2000UL;
  let c = a + b;
  println(c);  // 3000
  
  let d: UInt64 = 500UL;
  let e = c - d;
  println(e);  // 2500
  
  let f: UInt64 = 100UL;
  let g: UInt64 = 50UL;
  let h = f * g;
  println(h);  // 5000
  
  let i = b / f;
  println(i);  // 20
  
  let j: UInt64 = 123UL;
  let k: UInt64 = 10UL;
  let m = j % k;
  println(m);  // 3
}

fn test_uint_comparison() -> Unit {
  println("=== UInt Comparison ===");
  
  let a: UInt = 100U;
  let b: UInt = 200U;
  let c: UInt = 100U;
  
  // Test less than
  if (a < b) {
    println("100 < 200: true");
  };
  
  // Test greater than
  if (b > a) {
    println("200 > 100: true");
  };
  
  // Test equal
  if (a == c) {
    println("100 == 100: true");
  };
  
  // Test not equal
  if (a != b) {
    println("100 != 200: true");
  };
  
  // Test less than or equal
  if (a <= c) {
    println("100 <= 100: true");
  };
  
  // Test greater than or equal
  if (b >= a) {
    println("200 >= 100: true");
  };
}

fn test_uint64_comparison() -> Unit {
  println("=== UInt64 Comparison ===");
  
  let a: UInt64 = 1000UL;
  let b: UInt64 = 2000UL;
  let c: UInt64 = 1000UL;
  
  // Test less than
  if (a < b) {
    println("1000 < 2000: true");
  };
  
  // Test greater than
  if (b > a) {
    println("2000 > 1000: true");
  };
  
  // Test equal
  if (a == c) {
    println("1000 == 1000: true");
  };
  
  // Test not equal
  if (a != b) {
    println("1000 != 2000: true");
  };
  
  // Test less than or equal
  if (a <= c) {
    println("1000 <= 1000: true");
  };
  
  // Test greater than or equal
  if (b >= a) {
    println("2000 >= 1000: true");
  };
}

fn test_uint_shift() -> Unit {
  println("=== UInt Shift Operations ===");
  
  let a: UInt = 8U;
  
  // Left shift
  let b = a << 1;
  println(b);  // 16
  
  let c = a << 2;
  println(c);  // 32
  
  let d: UInt = 64U;
  
  // Right shift
  let e = d >> 1;
  println(e);  // 32
  
  let f = d >> 2;
  println(f);  // 16
  
  // Combined operations
  let g: UInt = 1U;
  let h = g << 4;
  println(h);  // 16
  
  let i = h >> 3;
  println(i);  // 2
}

fn test_uint64_shift() -> Unit {
  println("=== UInt64 Shift Operations ===");
  
  let a: UInt64 = 16UL;
  
  // Left shift
  let b = a << 1;
  println(b);  // 32
  
  let c = a << 3;
  println(c);  // 128
  
  let d: UInt64 = 256UL;
  
  // Right shift
  let e = d >> 2;
  println(e);  // 64
  
  let f = d >> 4;
  println(f);  // 16
  
  // Large shift
  let g: UInt64 = 1UL;
  let h = g << 10;
  println(h);  // 1024
  
  let i = h >> 5;
  println(i);  // 32
}

fn test_uint_wraparound() -> Unit {
  println("=== UInt Wraparound Test ===");
  
  // Test maximum values
  let max_uint: UInt = 4294967295U;  // 2^32 - 1
  println(max_uint);
  
  // Addition wraparound
  let a: UInt = 4294967290U;
  let b = a + 10U;
  println(b);  // Should wrap around to 4
  
  // Subtraction wraparound
  let c: UInt = 5U;
  let d = c - 10U;
  println(d);  // Should wrap around to large number
}

fn test_uint64_large() -> Unit {
  println("=== UInt64 Large Numbers ===");
  
  // Test with large values
  let a: UInt64 = 1000000000UL;  // 1 billion
  let b: UInt64 = 2000000000UL;  // 2 billion
  let c = a + b;
  println(c);  // 3000000000
  
  let d = c * 2UL;
  println(d);  // 6000000000
  
  let e = d / 1000000UL;
  println(e);  // 6000
}

fn main {
  test_uint_arithmetic();
  test_uint64_arithmetic();
  test_uint_comparison();
  test_uint64_comparison();
  test_uint_shift();
  test_uint64_shift();
  test_uint_wraparound();
  test_uint64_large();
}

