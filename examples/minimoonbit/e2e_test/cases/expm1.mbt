// expm1 implementation for MiniMoonBit
// Ported from math.mbt library
// Computes e^x - 1

///|
// Helper functions

fn __hi(x: Double) -> UInt {
  (x.reinterpret_as_uint64() >> 32).to_uint()
}

fn __low(x: Double) -> UInt {
  x.reinterpret_as_uint64().to_uint()
}

fn __combineQ(hi: UInt64, low: UInt64) -> Double {
  ((hi << 32) | low).reinterpret_as_double()
}

fn __combineW(hi: UInt, low: UInt) -> Double {
  __combineQ(hi.to_uint64(), low.to_uint64())
}

fn isnan(x: Double) -> Bool {
  (x.reinterpret_as_uint64() & 0x7fffffffffffffffUL) > 0x7ff0000000000000UL
}

fn isinf(x: Double) -> Bool {
  (x.reinterpret_as_uint64() & 0x7fffffffffffffffUL) == 0x7ff0000000000000UL
}

///|
// Main expm1 function for Double
// Returns e^x - 1
// This is more accurate than exp(x) - 1 for small values of x
//
// Special cases:
//   expm1(INF) = INF
//   expm1(NaN) = NaN
//   expm1(-INF) = -1
//   for finite argument, only expm1(0) = 0 is exact
//   if x > 7.09782712893383973096e+02 then expm1(x) overflows

fn expm1(input: Double) -> Double {
  if isnan(input) {
    // Return NaN
    let nan_bits: UInt64 = 0x7ff8000000000000UL;
    return nan_bits.reinterpret_as_double();
  };
  
  let o_threshold = 7.09782712893383973096e+02;
  if input > o_threshold {
    // Return positive infinity
    let pos_inf_bits: UInt64 = 0x7ff0000000000000UL;
    return pos_inf_bits.reinterpret_as_double();
  };
  
  if isinf(input) {
    // For -INF, return -1
    return -1.0;
  };
  
  let one = 1.0;
  let huge = 1.0e+300;
  let tiny = 1.0e-300;
  let ln2_hi = 6.93147180369123816490e-01;
  let ln2_lo = 1.90821492927058770002e-10;
  let invln2 = 1.44269504088896338700e+00;
  let q1 = -3.33333333333331316428e-02;
  let q2 = 1.58730158725481460165e-03;
  let q3 = -7.93650757867487942473e-05;
  let q4 = 4.00821782732936239552e-06;
  let q5 = -2.01099218183624371326e-07;
  
  let mut x = input;
  let mut hx = __hi(x);
  let xsb: Int = (hx & 0x80000000U).reinterpret_as_int();
  let mut y: Double = if xsb == 0 { x } else { -x };
  hx = hx & 0x7fffffffU;
  
  if hx >= 0x4043687AU {
    if xsb != 0 {
      if x + tiny < 0.0 {
        return tiny - one;
      }
    }
  };
  
  let mut hi = 0.0;
  let mut lo = 0.0;
  let mut k = 0;
  let mut c = 0.0;
  let mut t = 0.0;
  
  if hx > 0x3fd62e42U {
    if hx < 0x3FF0A2B2U {
      hi = if xsb == 0 { x - ln2_hi } else { x + ln2_hi };
      lo = if xsb == 0 { ln2_lo } else { -ln2_lo };
      k = if xsb == 0 { 1 } else { -1 };
    } else {
      k = (invln2 * x + (if xsb == 0 { 0.5 } else { -0.5 })).to_int();
      t = k.to_double();
      hi = x - t * ln2_hi;
      lo = t * ln2_lo;
    };
    x = hi - lo;
    c = hi - x - lo;
  } else if hx < 0x3c900000U {
    t = huge + x;
    return x - (t - (huge + x));
  } else {
    k = 0;
  };
  
  let hfx: Double = 0.5 * x;
  let hxs: Double = x * hfx;
  let r1: Double = one + hxs * (q1 + hxs * (q2 + hxs * (q3 + hxs * (q4 + hxs * q5))));
  let t: Double = 3.0 - r1 * hfx;
  let e: Double = hxs * ((r1 - t) / (6.0 - x * t));
  
  if k == 0 {
    return x - (x * e - hxs);
  } else {
    let e: Double = x * (e - c) - c;
    let e: Double = e - hxs;
    if k == -1 {
      return 0.5 * (x - e) - 0.5;
    };
    if k == 1 {
      return if x < -0.25 {
        -2.0 * (e - (x + 0.5))
      } else {
        one + 2.0 * (x - e)
      };
    };
    if k <= -2 || k > 56 {
      y = one - (e - x);
      y = __combineW(__hi(y) + (k << 20).to_uint(), __low(y));
      return y - one;
    };
    let mut t: Double = one;
    if k < 20 {
      t = __combineW(0x3ff00000U - (0x200000U >> k), 0U);
      y = t - (e - x);
      y = __combineW(__hi(y) + (k << 20).to_uint(), __low(y));
    } else {
      t = __combineW((0x3ffU - k.to_uint()) << 20, 0U);
      y = x - (e + t) + one;
      y = __combineW(__hi(y) + (k << 20).to_uint(), __low(y));
    };
  };
  y
}

///|
// Test helper functions

fn test_expm1(input: Double, expected: Double) -> Unit {
  let result = expm1(input);
  println("expm1(" + input.to_string() + ") = " + result.to_string() + " (expected: " + expected.to_string() + ")");
}

fn test_expm1_simple(input: Double) -> Unit {
  let result = expm1(input);
  println(result.to_string());
}

///|
// Main function with tests

fn main {
  println("Testing expm1 function:");
  
  // Basic values
  test_expm1_simple(0.0);
  test_expm1_simple(1.0);
  test_expm1_simple(-1.0);
  test_expm1_simple(2.0);
  test_expm1_simple(-2.0);
  
  // Small values (important for expm1 accuracy)
  test_expm1_simple(0.0001);
  test_expm1_simple(-0.0001);
  test_expm1_simple(0.1);
  test_expm1_simple(-0.1);
  
  // Fractional values (testing different ranges)
  test_expm1_simple(-0.8);
  test_expm1_simple(-0.7);
  test_expm1_simple(-0.6);
  test_expm1_simple(-0.5);
  test_expm1_simple(-0.4);
  test_expm1_simple(-0.3);
  test_expm1_simple(-0.2);
  test_expm1_simple(0.2);
  test_expm1_simple(0.3);
  test_expm1_simple(0.4);
  test_expm1_simple(0.5);
  test_expm1_simple(0.6);
  test_expm1_simple(0.7);
  test_expm1_simple(0.8);
  test_expm1_simple(0.9);
  
  // Pi-related values (testing transcendental numbers)
  test_expm1_simple(3.141592653589793);
  test_expm1_simple(-3.141592653589793);
  test_expm1_simple(1.5707963267948966);
  test_expm1_simple(-1.5707963267948966);
  test_expm1_simple(0.7853981633974483);
  test_expm1_simple(-0.7853981633974483);
  
  // Integer values
  test_expm1_simple(3.0);
  test_expm1_simple(-3.0);
  test_expm1_simple(4.0);
  test_expm1_simple(-4.0);
  test_expm1_simple(5.0);
  test_expm1_simple(-5.0);
  test_expm1_simple(6.0);
  test_expm1_simple(-6.0);
  test_expm1_simple(7.0);
  test_expm1_simple(-7.0);
  test_expm1_simple(8.0);
  test_expm1_simple(-8.0);
  test_expm1_simple(9.0);
  test_expm1_simple(-9.0);
  test_expm1_simple(10.0);
  
  // Decimal values
  test_expm1_simple(2.5);
  test_expm1_simple(3.4);
  test_expm1_simple(5.3);
  test_expm1_simple(6.2);
  test_expm1_simple(7.1);
  test_expm1_simple(8.9);
  test_expm1_simple(9.8);
  test_expm1_simple(10.7);
  
  // More decimal values
  test_expm1_simple(1.542);
  test_expm1_simple(-1.542);
  test_expm1_simple(2.846);
  test_expm1_simple(-2.846);
  test_expm1_simple(7.881);
  test_expm1_simple(-7.881);
  test_expm1_simple(3.772);
  test_expm1_simple(-3.772);
  
  // Large values
  test_expm1_simple(100.0);
  test_expm1_simple(101.6);
  
  // Very large values (should overflow to infinity)
  test_expm1_simple(1000.0);
  test_expm1_simple(10000.0);
  
  // Special values
  // Positive infinity
  let pos_inf_bits: UInt64 = 0x7ff0000000000000UL;
  let pos_inf = pos_inf_bits.reinterpret_as_double();
  test_expm1_simple(pos_inf);
  
  // Negative infinity (should return -1)
  let neg_inf_bits: UInt64 = 0xfff0000000000000UL;
  let neg_inf = neg_inf_bits.reinterpret_as_double();
  test_expm1_simple(neg_inf);
  
  // NaN (should return NaN)
  let nan_bits: UInt64 = 0x7ff8000000000000UL;
  let nan_val = nan_bits.reinterpret_as_double();
  test_expm1_simple(nan_val);
  
  // Negative zero (testing sign handling)
  let neg_zero_bits: UInt64 = 0x8000000000000000UL;
  let neg_zero = neg_zero_bits.reinterpret_as_double();
  test_expm1_simple(neg_zero);
}

