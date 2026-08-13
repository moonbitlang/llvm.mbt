// Test for Int64, Float and Char types support

fn test_int64() -> Unit {
  let a = 100L;
  let b = 200L;
  let c = a + b;
  println(c);
  
  let arr: Array[Int64] = [1L, 2L, 3L, 4L, 5L];
  let mut sum: Int64 = 0L;
  for i = 0; i < arr.length(); i = i + 1 {
    sum = sum + arr[i];
  }
  println(sum);
}

fn test_float() -> Unit {
  let x: Float = 1.5F;
  let y: Float = 2.5F;
  let z: Float = x + y;
  println(z);
  
  let farr: Array[Float] = [1.0F, 2.0F, 3.0F, 4.0F, 5.0F];
  let mut fsum: Float = 0.0F;
  for i = 0; i < farr.length(); i = i + 1 {
    fsum = fsum + farr[i];
  }
  println(fsum);
}

fn test_char() -> Unit {
  let c1 = 'A';
  let c2: Char = 'Z';
  println(c1)
  println(c2)
  
  let carr: Array[Char] = ['H', 'e', 'l', 'l', 'o'];
  for i = 0; i < carr.length(); i = i + 1 {
    println(carr[i]);
  }
}

fn test_string_char() -> Unit {
  let s: String = "Hello"
  for i = 0; i < s.length(); i = i + 1 {
    println(s[i])
  }
}

fn main {
  test_int64();
  test_float();
  test_char();
  test_string_char();
}

