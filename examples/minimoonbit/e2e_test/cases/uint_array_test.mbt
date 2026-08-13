// Test for UInt and UInt64 array operations

fn test_uint_array() -> Unit {
  let arr: Array[UInt] = [1U, 2U, 3U, 4U, 5U];
  let mut sum: UInt = 0U;
  for i = 0; i < arr.length(); i = i + 1 {
    sum = sum + arr[i];
  }
  println(sum);
  
  // Test array access and modification
  arr[0] = 10U;
  arr[1] = 20U;
  println(arr[0]);
  println(arr[1]);
}

fn test_uint64_array() -> Unit {
  let arr64: Array[UInt64] = [10UL, 20UL, 30UL, 40UL, 50UL];
  let mut sum64: UInt64 = 0UL;
  for i = 0; i < arr64.length(); i = i + 1 {
    sum64 = sum64 + arr64[i];
  }
  println(sum64);
  
  // Test array access
  println(arr64[2]);
  println(arr64[4]);
}

fn test_uint_array_make() -> Unit {
  let arr_make: Array[UInt] = Array::make(5, 7U);
  for i = 0; i < arr_make.length(); i = i + 1 {
    println(arr_make[i]);
  }
}

fn main {
  test_uint_array();
  test_uint64_array();
  test_uint_array_make();
}

