// 基础测试7：数组操作
fn array_sum(arr: Array[Int], n: Int) -> Int {
  let mut sum = 0;
  let mut i = 0;
  while i < n {
    sum = sum + arr[i];
    i = i + 1;
  }
  sum
}

fn array_max(arr: Array[Int], n: Int) -> Int {
  let mut max_val = arr[0];
  let mut i = 1;
  while i < n {
    if arr[i] > max_val {
      max_val = arr[i];
    };
    i = i + 1;
  }
  max_val
}

fn array_reverse(arr: Array[Int], n: Int) -> Unit {
  let mut i = 0;
  while i < n / 2 {
    let temp = arr[i];
    arr[i] = arr[n - 1 - i];
    arr[n - 1 - i] = temp;
    i = i + 1;
  }
}

fn main {
  let arr = [1, 5, 3, 9, 2, 7, 4];
  let n = 7;
  
  println(array_sum(arr, n));
  println(array_max(arr, n));
  
  array_reverse(arr, n);
  let mut i = 0;
  while i < n {
    println(arr[i]);
    i = i + 1;
  }
}

