// Base 10 logarithm implementation for MiniMoonBit
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
// Constants for log function

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
// Natural logarithm function (log)

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
// Base 10 logarithm function (log10)

fn log10(x: Double) -> Double {
  if x == 0.0 {
    // -infinity for zero
    let neg_inf_bits: UInt64 = 0xfff0000000000000UL;
    neg_inf_bits.reinterpret_as_double()
  } else if x < 0.0 || isnan(x) {
    // NaN for negative values or NaN input
    let nan_bits: UInt64 = 0x7ff8000000000000UL;
    nan_bits.reinterpret_as_double()
  } else if isinf(x) {
    // +infinity for positive infinity
    let pos_inf_bits: UInt64 = 0x7ff0000000000000UL;
    pos_inf_bits.reinterpret_as_double()
  } else {
    let two54 = 1.80143985094819840000e+16; // 0x43500000, 0x00000000
    let ivln10 = 4.34294481903251816668e-01; // 0x3FDBCB7B, 0x1526E50E = 1/ln(10)
    let log10_2hi = 3.01029995663611771306e-01; // 0x3FD34413, 0x509F6000
    let log10_2lo = 3.69423907715893078616e-13; // 0x3D59FEF3, 0x11F12B36
    
    let mut x = x;
    let mut hx: Int = __hi(x).reinterpret_as_int();
    let lx: Int = __low(x).reinterpret_as_int();
    let mut k = 0;
    
    if hx < 0x00100000 {
      // subnormal number, scale up x
      k = k - 54;
      x = x * two54;
      hx = __hi(x).reinterpret_as_int(); // high word of x
    };
    
    k = k + ((hx >> 20) - 1023);
    let i = ((k.reinterpret_as_uint() & 0x80000000U) >> 31).reinterpret_as_int();
    hx = (hx & 0x000fffff) | ((0x3ff - i) << 20);
    let y = (k + i).to_double();
    x = __combineW(hx.reinterpret_as_uint(), lx.reinterpret_as_uint());
    let z = y * log10_2lo + ivln10 * log(x);
    z + y * log10_2hi
  }
}

///|
// Test helper functions

fn test_log10(input: Double, expected: Double) -> Unit {
  let result = log10(input);
  println("log10(" + input.to_string() + ") = " + result.to_string() + " (expected: " + expected.to_string() + ")");
}

fn test_log10_nan(input: Double) -> Unit {
  let result = log10(input);
  let is_nan = isnan(result);
  let is_nan_str = if is_nan { "true" } else { "false" };
  println("log10(" + input.to_string() + ") = NaN (is_nan: " + is_nan_str + ")");
}

fn test_log10_inf(input: Double, expected_sign: Bool) -> Unit {
  let result = log10(input);
  let is_inf_result = isinf(result);
  let is_inf_str = if is_inf_result { "true" } else { "false" };
  let sign = if expected_sign { "positive" } else { "negative" };
  println("log10(" + input.to_string() + ") = " + sign + " infinity (is_inf: " + is_inf_str + ")");
}

///|
// Main function with tests

fn main {
  println("=== Testing log10 (Base 10 Logarithm) ===");
  println("");
  
  // Special cases - NaN for negative values
  println("--- Negative values (should be NaN) ---");
  test_log10_nan(-0.8);
  test_log10_nan(-3.141592653589793);
  test_log10_nan(-1.5707963267948966);
  test_log10_nan(-0.7853981633974483);
  test_log10_nan(-1.0);
  test_log10_nan(-1.542);
  println("");
  
  // Special cases - negative infinity for zero
  println("--- Zero (should be -infinity) ---");
  test_log10_inf(0.0, false);
  test_log10_inf(-0.0, false);
  println("");
  
  // Special cases - positive infinity
  println("--- Positive infinity ---");
  let pos_inf: UInt64 = 0x7ff0000000000000UL;
  let pos_inf_val = pos_inf.reinterpret_as_double();
  test_log10_inf(pos_inf_val, true);
  println("");
  
  // Special cases - NaN input
  println("--- NaN input ---");
  let nan: UInt64 = 0x7ff8000000000000UL;
  let nan_val = nan.reinterpret_as_double();
  test_log10_nan(nan_val);
  println("");
  
  // Powers of 10 (exact results)
  println("--- Powers of 10 ---");
  test_log10(0.01, -2.0);
  test_log10(0.1, -1.0);
  test_log10(1.0, 0.0);
  test_log10(10.0, 1.0);
  test_log10(100.0, 2.0);
  test_log10(1000.0, 3.0);
  test_log10(10000.0, 4.0);
  test_log10(100000.0, 5.0);
  test_log10(1000000.0, 6.0);
  println("");
  
  // Fractional values (less than 1)
  println("--- Fractional values ---");
  test_log10(0.2, -0.6989700043360187);
  test_log10(0.3, -0.5228787452803376);
  test_log10(0.4, -0.3979400086720376);
  test_log10(0.5, -0.3010299956639812);
  test_log10(0.6, -0.22184874961635637);
  test_log10(0.7, -0.1549019599857432);
  test_log10(0.8, -0.09691001300805639);
  test_log10(0.9, -0.045757490560675115);
  println("");
  
  // Integer values
  println("--- Integer values ---");
  test_log10(1.0, 0.0);
  test_log10(2.0, 0.3010299956639812);
  test_log10(3.0, 0.47712125471966244);
  test_log10(4.0, 0.6020599913279624);
  test_log10(5.0, 0.6989700043360189);
  test_log10(6.0, 0.7781512503836436);
  test_log10(7.0, 0.8450980400142568);
  test_log10(8.0, 0.9030899869919435);
  test_log10(9.0, 0.9542425094393249);
  test_log10(11.0, 1.041392685158225);
  test_log10(12.0, 1.0791812460476249);
  test_log10(13.0, 1.1139433523068367);
  test_log10(14.0, 1.146128035678238);
  test_log10(15.0, 1.1760912590556813);
  test_log10(16.0, 1.2041199826559248);
  test_log10(17.0, 1.2304489213782739);
  test_log10(18.0, 1.255272505103306);
  test_log10(19.0, 1.2787536009528289);
  test_log10(20.0, 1.3010299956639813);
  test_log10(21.0, 1.3222192947339193);
  test_log10(22.0, 1.3424226808222062);
  test_log10(23.0, 1.3617278360175928);
  test_log10(24.0, 1.380211241711606);
  test_log10(25.0, 1.3979400086720377);
  println("");
  
  // Decimal values
  println("--- Decimal values ---");
  test_log10(2.5, 0.3979400086720376);
  test_log10(3.4, 0.5314789170422551);
  test_log10(5.3, 0.724275869600789);
  test_log10(6.2, 0.7923916894982539);
  test_log10(7.1, 0.8512583487190752);
  test_log10(8.9, 0.9493900066449128);
  test_log10(9.8, 0.9912260756924949);
  test_log10(10.7, 1.0293837776852097);
  test_log10(101.6, 2.0068937079479006);
  println("");
  
  // More decimal values
  println("--- More decimal values ---");
  test_log10(1.542, 0.1880843737149382);
  test_log10(2.846, 0.45423489574826553);
  test_log10(7.881, 0.8965813275057327);
  test_log10(3.772, 0.5765716840652907);
  println("");
  
  // Pi-related values
  println("--- Pi-related values ---");
  test_log10(3.141592653589793, 0.4971498726941338);
  test_log10(1.5707963267948966, 0.19611987703015263);
  test_log10(0.7853981633974483, -0.10491011863382856);
  println("");
  
  // More complex values
  println("--- More complex values ---");
  test_log10(242.58711268945123, 2.3848677254814152);
  test_log10(21456.774415889613, 4.331564435306097);
  test_log10(1123.5582229412541, 3.0505955825379125);
  println("");
  
  println("=== All tests completed ===");
}

