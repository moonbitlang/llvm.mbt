// Natural logarithm implementation for MiniMoonBit
// Ported from math.mbt library

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

fn fabs(x: Double) -> Double {
  (x.reinterpret_as_uint64() & 0x7fffffffffffffffUL).reinterpret_as_double()
}

fn isnan(x: Double) -> Bool {
  (x.reinterpret_as_uint64() & 0x7fffffffffffffffUL) > 0x7ff0000000000000UL
}

fn isinf(x: Double) -> Bool {
  (x.reinterpret_as_uint64() & 0x7fffffffffffffffUL) == 0x7ff0000000000000UL
}

///|
// Constants

let sqrt2: Double = 1.41421356237309504880
let double_min_positive: Double = 2.2250738585072014E-308

///|
// frexp function - Extract mantissa and exponent of a floating-point value

fn normalize(f: Double) -> (Double, Int) {
  if fabs(f) < double_min_positive {
    let normalized = f * 4503599627370496.0; // 2^52
    (normalized, -52)
  } else {
    (f, 0)
  }
}

fn frexp(f: Double) -> (Double, Int) {
  if f == 0.0 || isinf(f) || isnan(f) {
    (f, 0)
  } else {
    let (norm_f, exp_offset) = normalize(f);
    let u = norm_f.reinterpret_as_uint64();
    let exp_part = ((u >> 52) & 0x7FFUL).to_int();
    let exp = exp_offset + exp_part - 1022;
    let frac_bits = (u & 0xFFFFFFFFFFFFFUL) | 0x3FE0000000000000UL; // (1022UL << 52)
    let frac = frac_bits.reinterpret_as_double();
    (frac, exp)
  }
}

///|
// Main log function for Double

fn log(x: Double) -> Double {
  // Coefficients
  let l1 = 6.666666666666735130e-01; // 3FE55555 55555593
  let l2 = 3.999999999940941908e-01; // 3FD99999 9997FA04
  let l3 = 2.857142874366239149e-01; // 3FD24924 94229359
  let l4 = 2.222219843214978396e-01; // 3FCC71C5 1D8E78AF
  let l5 = 1.818357216161805012e-01; // 3FC74664 96CB03DE
  let l6 = 1.531383769920937332e-01; // 3FC39A09 D078C69F
  let l7 = 1.479819860511658591e-01; // 3FC2F112 DF3E5244
  let ln2_hi = 6.93147180369123816490e-01; // 3fe62e42 fee00000
  let ln2_lo = 1.90821492927058770002e-10; // 3dea39ef 35793c76
  
  if x < 0.0 {
    // NaN for negative values
    let nan_bits: UInt64 = 0x7ff8000000000000UL;
    nan_bits.reinterpret_as_double()
  } else if isnan(x) || isinf(x) {
    x
  } else if x == 0.0 {
    // -infinity for zero
    let neg_inf_bits: UInt64 = 0xfff0000000000000UL;
    neg_inf_bits.reinterpret_as_double()
  } else {
    let (f1, ki) = frexp(x);
    
    let sqrt2_over_2 = sqrt2 / 2.0;
    let f: Double = if f1 < sqrt2_over_2 {
      f1 * 2.0 - 1.0
    } else {
      f1 - 1.0
    };
    let k: Double = if f1 < sqrt2_over_2 {
      (ki - 1).to_double()
    } else {
      ki.to_double()
    };
    
    let s = f / (2.0 + f);
    let s2 = s * s;
    let s4 = s2 * s2;
    let t1 = s2 * (l1 + s4 * (l3 + s4 * (l5 + s4 * l7)));
    let t2 = s4 * (l2 + s4 * (l4 + s4 * l6));
    let r = t1 + t2;
    let hfsq = 0.5 * f * f;
    k * ln2_hi - (hfsq - (s * (hfsq + r) + k * ln2_lo) - f)
  }
}

///|
// Test helper functions

fn test_log(input: Double, expected: Double) -> Unit {
  let result = log(input);
  println("log(" + input.to_string() + ") = " + result.to_string() + " (expected: " + expected.to_string() + ")");
}

fn test_log_nan(input: Double) -> Unit {
  let result = log(input);
  let is_nan = isnan(result);
  let is_nan_str = if is_nan { "true" } else { "false" };
  println("log(" + input.to_string() + ") = NaN (is_nan: " + is_nan_str + ")");
}

fn test_log_inf(input: Double) -> Unit {
  let result = log(input);
  let is_inf_result = isinf(result);
  let is_inf_str = if is_inf_result { "true" } else { "false" };
  let sign = if result < 0.0 { "negative" } else { "positive" };
  println("log(" + input.to_string() + ") = " + sign + " infinity (is_inf: " + is_inf_str + ")");
}

///|
// Main function with tests

fn main {
  println("=== Testing log (Natural Logarithm) ===");
  println("");
  
  // Special cases - NaN for negative values
  println("--- Negative values (should be NaN) ---");
  test_log_nan(-0.8);
  test_log_nan(-0.1);
  test_log_nan(-1.0);
  test_log_nan(-2.0);
  test_log_nan(-3.141592653589793);
  println("");
  
  // Special cases - negative infinity for zero
  println("--- Zero (should be -infinity) ---");
  test_log_inf(0.0);
  test_log_inf(-0.0);
  println("");
  
  // Special cases - positive infinity
  println("--- Positive infinity ---");
  let pos_inf: UInt64 = 0x7ff0000000000000UL;
  let pos_inf_val = pos_inf.reinterpret_as_double();
  test_log_inf(pos_inf_val);
  println("");
  
  // Basic values
  println("--- Basic values ---");
  test_log(1.0, 0.0);
  test_log(2.718281828459045, 1.0); // e
  test_log(2.0, 0.6931471805599453);
  test_log(10.0, 2.302585092994046);
  test_log(100.0, 4.605170185988092);
  test_log(1000.0, 6.907755278982137);
  println("");
  
  // Fractional values (less than 1)
  println("--- Fractional values ---");
  test_log(0.1, -2.3025850929940455);
  test_log(0.2, -1.6094379124341003);
  test_log(0.3, -1.2039728043259361);
  test_log(0.4, -0.916290731874155);
  test_log(0.5, -0.6931471805599453);
  test_log(0.6, -0.5108256237659907);
  test_log(0.7, -0.35667494393873245);
  test_log(0.8, -0.2231435513142097);
  test_log(0.9, -0.10536051565782628);
  println("");
  
  // Integer values
  println("--- Integer values ---");
  test_log(1.0, 0.0);
  test_log(2.0, 0.6931471805599453);
  test_log(3.0, 1.0986122886681096);
  test_log(4.0, 1.3862943611198906);
  test_log(5.0, 1.6094379124341003);
  test_log(6.0, 1.791759469228055);
  test_log(7.0, 1.9459101490553132);
  test_log(8.0, 2.0794415416798357);
  test_log(9.0, 2.1972245773362196);
  println("");
  
  // Decimal values
  println("--- Decimal values ---");
  test_log(2.5, 0.9162907318741551);
  test_log(3.4, 1.2237754316221157);
  test_log(5.3, 1.667706820558076);
  test_log(6.2, 1.8245492920510458);
  test_log(7.1, 1.9600947840472698);
  test_log(8.9, 2.186051276738094);
  test_log(9.8, 2.2823823856765264);
  test_log(10.7, 2.3702437414678603);
  test_log(101.6, 4.6210435351443815);
  println("");
  
  // More decimal values
  println("--- More decimal values ---");
  test_log(1.542, 0.4330802751411378);
  test_log(2.846, 1.0459144996676606);
  test_log(7.881, 2.0644547993715126);
  test_log(3.772, 1.327605364771211);
  println("");
  
  // Pi-related values
  println("--- Pi-related values ---");
  test_log(3.141592653589793, 1.1447298858494002);
  test_log(1.5707963267948966, 0.4515827052894548);
  test_log(0.7853981633974483, -0.2415644752704905);
  println("");
  
  // Large values
  println("--- Large values ---");
  test_log(10000.0, 9.210340371976184);
  test_log(1000000.0, 13.815510557964274);
  println("");
  
  println("=== All tests completed ===");
}

