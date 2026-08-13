// Exponential function implementation for MiniMoonBit
// Ported from math.mbt library

///|
// Helper functions

fn __hi(x: Double) -> UInt {
  (x.reinterpret_as_uint64() >> 32).to_uint()
}

fn __low(x: Double) -> UInt {
  x.reinterpret_as_uint64().to_uint()
}

fn __combine(hi: UInt64, low: UInt64) -> Double {
  ((hi << 32) | low).reinterpret_as_double()
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
// Main exp function for Double
// Returns e^x (exponent of x)
// Accuracy: 1 ulp (unit in the last place)
// Special cases:
//   exp(INF) = INF, exp(NaN) = NaN
//   exp(-INF) = 0
//   for finite argument, only exp(0)=1 is exact

fn exp(input: Double) -> Double {
  let mut x = input;
  let one = 1.0;
  let halF0 = 0.5;
  let halF1 = -0.5;
  let o_threshold = 7.09782712893383973096e+02;
  let u_threshold = -7.45133219101941108420e+02;
  let ln2HI0 = 6.93147180369123816490e-01;
  let ln2HI1 = -6.93147180369123816490e-01;
  let ln2LO0 = 1.90821492927058770002e-10;
  let ln2LO1 = -1.90821492927058770002e-10;
  let invln2 = 1.44269504088896338700e+00;
  let p1 = 1.66666666666666019037e-01;
  let p2 = -2.77777777770155933842e-03;
  let p3 = 6.61375632143793436117e-05;
  let p4 = -1.65339022054652515390e-06;
  let p5 = 4.13813679705723846039e-08;
  let e = 2.718281828459045;
  let mut hi = 0.0;
  let mut lo = 0.0;
  let huge = 1.0e+300;
  let twom1000 = 9.33263618503218878990e-302;
  let two1023 = 8.988465674311579539e307;
  let mut k: Int = 0;
  let mut hx: UInt = __hi(input);
  let xsb: Int = ((hx >> 31) & 1U).reinterpret_as_int();
  hx = hx & 0x7FFFFFFFU;
  
  if hx >= 0x40862E42U {
    if hx >= 0x7FF00000U {
      let lx: UInt = __low(input);
      if ((hx & 0xFFFFFU) | lx) != 0U {
        return input + input;
      } else if xsb == 0 {
        return input;
      } else {
        return 0.0;
      }
    };
    if input > o_threshold {
      return huge * huge;
    };
    if input < u_threshold {
      return twom1000 * twom1000;
    }
  };
  
  if hx > 0x3FD62E42U {
    if hx < 0x3FF0A2B2U {
      if input == 1.0 {
        return e;
      };
      hi = input - ln2HI0;
      lo = ln2LO0;
      k = 1 - xsb - xsb;
      if xsb != 0 {
        hi = input - ln2HI1;
        lo = ln2LO1;
      }
    } else {
      let halF_val = if xsb == 0 { halF0 } else { halF1 };
      k = (invln2 * input + halF_val).to_int();
      let t = k.to_double();
      hi = input - t * ln2HI0;
      lo = t * ln2LO0;
    };
    x = hi - lo;
  } else if hx < 0x3E300000U {
    if huge + x > one {
      return one + x;
    }
  } else {
    k = 0;
  };
  
  let t = x * x;
  let twopk = if k >= -1021 {
    let k_uint = k.reinterpret_as_uint();
    let hi_part = (0x3FF00000 + (k_uint << 20).reinterpret_as_int()).to_int64().reinterpret_as_uint64();
    __combine(hi_part, 0UL)
  } else {
    let k_plus_1000 = k + 1000;
    let hi_part = 0x3FF00000UL + (k_plus_1000.reinterpret_as_uint() << 20).to_uint64();
    __combine(hi_part, 0UL)
  };
  
  let c = x - t * (p1 + t * (p2 + t * (p3 + t * (p4 + t * p5))));
  
  if k == 0 {
    return one - (x * c / (c - 2.0) - x);
  };
  
  let y = one - (lo - x * c / (2.0 - c) - hi);
  
  if k >= -1021 {
    if k == 1024 {
      return y * 2.0 * two1023;
    } else {
      return y * twopk;
    }
  } else {
    return y * twopk * twom1000;
  }
}

///|
// Main function with tests

fn main {
  println("Testing exp function:");
  
  // exp(0) = 1
  println(exp(0.0).to_string());
  
  // exp(1) = e ≈ 2.718281828459045
  println(exp(1.0).to_string());
  
  // exp(-1) ≈ 0.36787944117144233
  println(exp(-1.0).to_string());
  
  // exp(2) ≈ 7.38905609893065
  println(exp(2.0).to_string());
  
  // exp(-2) ≈ 0.1353352832366127
  println(exp(-2.0).to_string());
  
  // exp(3) ≈ 20.085536923187668
  println(exp(3.0).to_string());
  
  // exp(-3) ≈ 0.049787068367863944
  println(exp(-3.0).to_string());
  
  // exp(5) ≈ 148.4131591025766
  println(exp(5.0).to_string());
  
  // exp(10) ≈ 22026.465794806718
  println(exp(10.0).to_string());
  
  // exp(0.1) ≈ 1.1051709180756477
  println(exp(0.1).to_string());
  
  // exp(-0.1) ≈ 0.9048374180359595
  println(exp(-0.1).to_string());
  
  // exp(100) - very large number
  println(exp(100.0).to_string());
  
  // exp(-infinity) = 0
  let neg_inf_bits: UInt64 = 0xfff0000000000000UL;
  let neg_inf = neg_inf_bits.reinterpret_as_double();
  println(exp(neg_inf).to_string());
}

