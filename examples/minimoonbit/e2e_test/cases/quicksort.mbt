// 快速排序算法实现

fn swap(arr: Array[Int], i: Int, j: Int) -> Unit {
  let temp = arr[i];
  arr[i] = arr[j];
  arr[j] = temp;
}

fn partition(arr: Array[Int], low: Int, high: Int) -> Int {
  let pivot = arr[high];
  let mut i = low - 1;
  let mut j = low;
  
  while j < high {
    if arr[j] < pivot {
      i = i + 1;
      swap(arr, i, j);
    };
    j = j + 1;
  }
  
  swap(arr, i + 1, high);
  i + 1
}

fn quicksort_helper(arr: Array[Int], low: Int, high: Int) -> Unit {
  if low < high {
    let pi = partition(arr, low, high);
    quicksort_helper(arr, low, pi - 1);
    quicksort_helper(arr, pi + 1, high);
  }
}

fn quicksort(arr: Array[Int], n: Int) -> Unit {
  if n > 1 {
    quicksort_helper(arr, 0, n - 1);
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

fn array_copy(src: Array[Int], dst: Array[Int], n: Int) -> Unit {
  let mut i = 0;
  while i < n {
    dst[i] = src[i];
    i = i + 1;
  }
}

fn test_case_1() -> Unit {
  let arr = [5, 2, 8, 1, 9, 3, 7, 4, 6];
  let n = 9;
  
  quicksort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn test_case_2() -> Unit {
  let arr = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
  let n = 10;
  
  quicksort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn test_case_3() -> Unit {
  let arr = [1, 2, 3, 4, 5];
  let n = 5;
  
  quicksort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn test_case_4() -> Unit {
  let arr = [5, 5, 5, 5, 5];
  let n = 5;
  
  quicksort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn test_case_5() -> Unit {
  let arr = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5, 8, 9, 7, 9, 3, 2, 3, 8, 4];
  let n = 20;
  
  quicksort(arr, n);
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
  
  quicksort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn test_two_elements_sorted() -> Unit {
  let arr = [1, 2];
  let n = 2;
  
  quicksort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn test_two_elements_unsorted() -> Unit {
  let arr = [2, 1];
  let n = 2;
  
  quicksort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn test_large_range() -> Unit {
  let arr = [100, 50, 25, 75, 10, 90, 5, 95, 1, 99];
  let n = 10;
  
  quicksort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn test_negative_numbers() -> Unit {
  let arr = [5, 0 - 2, 8, 0 - 1, 3, 0 - 5, 7];
  let n = 7;
  
  quicksort(arr, n);
  print_array(arr, n);
  
  if is_sorted(arr, n) {
    println(1);
  } else {
    println(0);
  }
}

fn benchmark_small() -> Unit {
  let arr = [9, 3, 7, 1, 5, 2, 8, 4, 6];
  let n = 9;
  
  quicksort(arr, n);
  
  let sum = {
    let mut total = 0;
    let mut i = 0;
    while i < n {
      total = total + arr[i];
      i = i + 1;
    }
    total
  };
  
  println(sum);
}

fn main {
  test_case_1();
  test_case_2();
  test_case_3();
  test_case_4();
  test_case_5();
  test_single_element();
  test_two_elements_sorted();
  test_two_elements_unsorted();
  test_large_range();
  test_negative_numbers();
  benchmark_small();
}

