// 归并排序算法实现

fn merge(arr: Array[Int], left: Int, mid: Int, right: Int, temp: Array[Int]) -> Unit {
  let mut i = left;
  let mut j = mid + 1;
  let mut k = left;
  
  while i <= mid && j <= right {
    if arr[i] <= arr[j] {
      temp[k] = arr[i];
      i = i + 1;
    } else {
      temp[k] = arr[j];
      j = j + 1;
    };
    k = k + 1;
  }
  
  while i <= mid {
    temp[k] = arr[i];
    i = i + 1;
    k = k + 1;
  }
  
  while j <= right {
    temp[k] = arr[j];
    j = j + 1;
    k = k + 1;
  }
  
  let mut idx = left;
  while idx <= right {
    arr[idx] = temp[idx];
    idx = idx + 1;
  }
}

fn mergesort_helper(arr: Array[Int], left: Int, right: Int, temp: Array[Int]) -> Unit {
  if left < right {
    let mid = left + (right - left) / 2;
    mergesort_helper(arr, left, mid, temp);
    mergesort_helper(arr, mid + 1, right, temp);
    merge(arr, left, mid, right, temp);
  }
}

fn mergesort(arr: Array[Int], n: Int) -> Unit {
  if n > 1 {
    let temp = Array::make(n, 0);
    mergesort_helper(arr, 0, n - 1, temp);
  }
}

fn print_array(arr: Array[Int], n: Int) -> Unit {
  let mut i = 0;
  while i < n {
    println(arr[i]);
    i = i + 1;
  }
}

fn is_sorted(arr: Array[Int], n: Int) -> Bool {
  let mut i = 1;
  while i < n {
    if arr[i] < arr[i - 1] {
      return false;
    };
    i = i + 1;
  }
  true
}

fn array_sum(arr: Array[Int], n: Int) -> Int {
  let mut sum = 0;
  let mut i = 0;
  while i < n {
    sum = sum + arr[i];
    i = i + 1;
  }
  sum
}

fn test_basic_sort() -> Unit {
  let arr = [5, 2, 8, 1, 9, 3, 7, 4, 6];
  let n = 9;
  
  mergesort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn test_reverse_sorted() -> Unit {
  let arr = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
  let n = 10;
  
  mergesort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn test_already_sorted() -> Unit {
  let arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  let n = 10;
  
  mergesort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn test_duplicates() -> Unit {
  let arr = [5, 2, 8, 2, 9, 5, 7, 8, 5];
  let n = 9;
  
  mergesort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn test_all_same() -> Unit {
  let arr = [7, 7, 7, 7, 7, 7, 7];
  let n = 7;
  
  mergesort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn test_two_elements() -> Unit {
  let arr = [5, 3];
  let n = 2;
  
  mergesort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn test_single_element() -> Unit {
  let arr = [42];
  let n = 1;
  
  mergesort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn test_large_numbers() -> Unit {
  let arr = [1000, 500, 750, 250, 875, 125, 625, 375];
  let n = 8;
  
  mergesort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn test_negative_numbers() -> Unit {
  let arr = [5, 0 - 2, 0, 3, 0 - 5, 8, 0 - 1];
  let n = 7;
  
  mergesort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn test_mixed_numbers() -> Unit {
  let arr = [0 - 10, 15, 0 - 5, 20, 0, 10, 0 - 15, 5];
  let n = 8;
  
  mergesort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  };
  
  println(array_sum(arr, n));
}

fn test_alternating() -> Unit {
  let arr = [1, 10, 2, 9, 3, 8, 4, 7, 5, 6];
  let n = 10;
  
  mergesort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn main {
  test_basic_sort();
  test_reverse_sorted();
  test_already_sorted();
  test_duplicates();
  test_all_same();
  test_two_elements();
  test_single_element();
  test_large_numbers();
  test_negative_numbers();
  test_mixed_numbers();
  test_alternating();
}

