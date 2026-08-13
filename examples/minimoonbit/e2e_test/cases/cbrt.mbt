// Cube root implementation for MiniMoonBit
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
// Main cbrt function for Double

fn cbrt(x: Double) -> Double {
  if isinf(x) || isnan(x) || x == 0.0 {
    x
  } else {
    let b1: UInt = 715094163U; // B1 = (682-0.03306235651)*2**20
    let b2: UInt = 696219795U; // B2 = (664-0.03306235651)*2**20
    let c = 5.42857142857142815906e-01; // 19/35
    let d = -7.05306122448979611050e-01; // -864/1225
    let e = 1.41428571428571436819e+00; // 99/70
    let f = 1.60714285714285720630e+00; // 45/28
    let g = 3.57142857142857150787e-01; // 5/14
    let hx_uint = __hi(x);
    let hx = hx_uint.to_int();
    let sign = if x < 0.0 { true } else { false };
    let x_abs = fabs(x);
    
    // rough cbrt to 5 bits
    let t = if hx < 0x00100000 {
      // subnormal number
      let _t: UInt64 = 0x4350000000000000UL;
      let _t: Double = _t.reinterpret_as_double();
      let _t = _t * x_abs;
      __combineW(__hi(_t) / 3U + b2, 0U)
    } else {
      __combineW(hx_uint / 3U + b1, 0U)
    };
    
    let r = t * t / x_abs;
    let s = c + r * t;
    let t = t * (g + f / (s + e + d / s));
    
    // chopped to 20 bits and make it larger than cbrt(x)
    let t = __combineW(__hi(t) + 0x00000001U, 0U);
    
    // one step newton iteration to 53 bits with error less than 0.667 ulps
    let s = t * t;
    let r = x_abs / s;
    let w = t + t;
    let r = (r - t) / (w + r);
    let t = t + t * r;
    
    // restore the sign bit
    if sign {
      -t
    } else {
      t
    }
  }
}

///|
// cbrtf function for Float

fn cbrtf(x: Float) -> Float {
  let b1: UInt = 709958130U; // B1 = (127-127.0/3-0.03306235651)*2**23
  let b2: UInt = 642849266U; // B2 = (127-127.0/3-24/3-0.03306235651)*2**23
  let mut ui: UInt = x.reinterpret_as_uint();
  let mut hx: UInt = ui & 0x7fffffffU;
  
  if hx >= 0x7f800000U {
    // cbrt(NaN,INF) is itself
    x + x
  } else {
    // rough cbrt to 5 bits
    if hx < 0x00800000U {
      // zero or subnormal?
      if hx == 0U {
        x
      } else {
        ui = (x * 16777216.0F).reinterpret_as_uint();
        hx = ui & 0x7fffffffU;
        hx = hx / 3U + b2;
        ui = (ui & 0x80000000U) | hx;
        
        // First step Newton iteration
        let dx = x.to_double();
        let t = ui.reinterpret_as_float().to_double();
        let r = t * t * t;
        let t = t * (dx + dx + r) / (dx + r + r);
        
        // Second step Newton iteration
        let r = t * t * t;
        let t = t * (dx + dx + r) / (dx + r + r);
        
        t.to_float()
      }
    } else {
      hx = hx / 3U + b1;
      ui = (ui & 0x80000000U) | hx;
      
      // First step Newton iteration
      let dx = x.to_double();
      let t = ui.reinterpret_as_float().to_double();
      let r = t * t * t;
      let t = t * (dx + dx + r) / (dx + r + r);
      
      // Second step Newton iteration
      let r = t * t * t;
      let t = t * (dx + dx + r) / (dx + r + r);
      
      t.to_float()
    }
  }
}

///|
// Test helper functions

fn test_cbrt_double(input: Double, expected: Double) -> Unit {
  let result = cbrt(input);
  println("cbrt(" + input.to_string() + ") = " + result.to_string() + " (expected: " + expected.to_string() + ")");
}

fn test_cbrt_float(input: Float, expected: Float) -> Unit {
  let result = cbrtf(input);
  println("cbrtf(" + input.to_string() + ") = " + result.to_string() + " (expected: " + expected.to_string() + ")");
}

///|
// Main function with tests

fn main {
  println("=== Testing cbrt (Double) ===");
  
  // Positive values
  test_cbrt_double(1.0, 1.0);
  test_cbrt_double(8.0, 2.0);
  test_cbrt_double(27.0, 3.0);
  test_cbrt_double(1000.0, 10.0);
  test_cbrt_double(2.0, 1.2599210498948732);
  test_cbrt_double(3.0, 1.4422495703074083);
  test_cbrt_double(4.0, 1.5874010519681996);
  test_cbrt_double(10.0, 2.154434690031884);
  test_cbrt_double(100.0, 4.641588833612779);
  
  // Negative values
  test_cbrt_double(-1.0, -1.0);
  test_cbrt_double(-8.0, -2.0);
  test_cbrt_double(-27.0, -3.0);
  test_cbrt_double(-2.0, -1.2599210498948732);
  test_cbrt_double(-3.0, -1.4422495703074083);
  
  // Special values
  test_cbrt_double(0.0, 0.0);
  test_cbrt_double(-0.0, -0.0);
  
  // Fractional values
  test_cbrt_double(2.5, 1.3572088082974532);
  test_cbrt_double(3.4, 1.5036945962049748);
  test_cbrt_double(5.3, 1.7435134012651283);
  
  println("");
  println("=== Testing cbrtf (Float) ===");
  
  // Positive values
  test_cbrt_float(1.0F, 1.0F);
  test_cbrt_float(8.0F, 2.0F);
  test_cbrt_float(27.0F, 3.0F);
  test_cbrt_float(1000.0F, 10.0F);
  test_cbrt_float(2.0F, 1.2599210739135742F);
  test_cbrt_float(3.0F, 1.4422495365142822F);
  test_cbrt_float(64.0F, 4.0F);
  test_cbrt_float(512.0F, 8.0F);
  test_cbrt_float(729.0F, 9.0F);
  
  // Negative values
  test_cbrt_float(-1.0F, -1.0F);
  test_cbrt_float(-8.0F, -2.0F);
  test_cbrt_float(-27.0F, -3.0F);
  test_cbrt_float(-2.0F, -1.2599210739135742F);
  test_cbrt_float(-3.0F, -1.4422495365142822F);
  
  // Special values
  test_cbrt_float(0.0F, 0.0F);
  test_cbrt_float(-0.0F, -0.0F);
  
  // Fractional values
  test_cbrt_float(0.5F, 0.7937005162239075F);
  test_cbrt_float(1.5F, 1.1447142362594604F);
  test_cbrt_float(0.125F, 0.5F);
  
  println("");
  println("=== Testing edge cases ===");
  
  // Test very large values
  test_cbrt_double(1000000.0, 100.0);
  test_cbrt_double(8000000.0, 200.0);
  
  // Test very small values
  test_cbrt_double(0.001, 0.1);
  test_cbrt_double(0.000001, 0.01);
  
  // Test negative small values
  test_cbrt_double(-0.001, -0.1);
  test_cbrt_double(-0.000001, -0.01);
  
  // More complex values
  test_cbrt_double(7.881, 1.9900337527839058);
  test_cbrt_double(15.25, 2.4798387867684393);
  test_cbrt_double(101.6, 4.666213107846951);
  
  // Float edge cases
  test_cbrt_float(3511808.0F, 152.0F);
  test_cbrt_float(6859.0F, 19.0F);
  test_cbrt_float(68.25F, 4.086650848388672F);
  
  println("");
  println("=== All tests completed ===");
}
