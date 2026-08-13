extern "C" fn print_int(x : Int) = "print_int";
extern "C" fn int_of_float(x : Double) -> Int = "int_of_float";
extern "C" fn float_of_int(x : Int) -> Double = "float_of_int";

let next : Array[Int] = [1];

fn simple_rand() -> Int {
  next[0] = next[0] * 1103515245 + 12345;
  let temp = next[0] / 65536 % 32768;
  temp
}

///|
fn simple_srand(seed : Int) -> Unit {
  next[0] = seed;
}

///|
struct Matrix {
  data : Array[Array[Double]];
  rows : Int;
  cols : Int;
}

///|
fn new_mat(rows : Int, cols : Int) -> Matrix {
  let data = Array::make(rows, Array::make(cols, 0.0));
  let mut i = 0;
  while i < rows {
    data[i] = Array::make(cols, 0.0);
    i = i + 1;
  }
  Matrix::{ data: data, rows: rows, cols: cols }
}

///|
fn mat_get(m : Matrix, i : Int, j : Int) -> Double {
  m.data[i][j]
}

///|
fn set_mat(m : Matrix, i : Int, j : Int, value : Double) -> Unit {
  m.data[i][j] = value;
}

// 用随机值填充矩阵

///|
fn rand_mat(mat : Matrix, n : Int) -> Unit {
  let mut i = 0;
  while i < n {
    let mut j = 0;
    while j < n {
      set_mat(mat, i, j, float_of_int(simple_rand() % 10));
      j = j + 1;
    }
    i = i + 1;
  }
}

fn sum_all_mat(mat : Matrix, n : Int) -> Double {
  let mut sum = 0.0;
  let mut i = 0;
  while i < n {
    let mut j = 0;
    while j < n {
      sum = sum + mat_get(mat, i, j);
      j = j + 1;
    }
    i = i + 1;
  }
  sum
}

// 交换矩阵的两行

///|
fn swap_rows(mat : Matrix, row1 : Int, row2 : Int) -> Unit {
  if row1 != row2 {
    let temp = mat.data[row1];
    mat.data[row1] = mat.data[row2];
    mat.data[row2] = temp;
  }
}

// 矩阵求逆函数

///|
fn inv_mat(mat : Matrix, inv : Matrix, n : Int) -> Int {
  // 创建增广矩阵 [mat | I]
  let temp = new_mat(n, n * 2);

  // 初始化增广矩阵
  let mut i = 0;
  while i < n {
    let mut j = 0;
    while j < n {
      set_mat(temp, i, j, mat_get(mat, i, j));
      j = j + 1;
    }
    j = n;
    while j < n * 2 {
      if i == j - n {
        set_mat(temp, i, j, 1.0);
      } else {
        set_mat(temp, i, j, 0.0);
      };
      j = j + 1;
    }
    i = i + 1;
  }

  fn abs(x) {
    if x < 0.0 {
      -x
    } else {
      x
    }
  }

  // 高斯-若尔丹消元法
  let mut i = 0;
  while i < n {
    let mut pivot_row = i;
    let mut k = i + 1;
    while k < n {
      if abs(mat_get(temp, k, i)) > abs(mat_get(temp, pivot_row, i)) {
        pivot_row = k;
      };
      k = k + 1;
    }

    if pivot_row != i {
      swap_rows(temp, i, pivot_row);
    };

    let pivot_val = mat_get(temp, i, i);
    if abs(pivot_val) < 0.0000000001 {
      return -1;
    };

    let mut j = i;
    while j < n * 2 {
      set_mat(temp, i, j, mat_get(temp, i, j) / pivot_val);
      j = j + 1;
    }

    let mut k = 0;
    while k < n {
      if k != i {
        let factor = mat_get(temp, k, i);
        let mut j = i;
        while j < n * 2 {
          set_mat(temp, k, j, mat_get(temp, k, j) - factor * mat_get(temp, i, j));
          j = j + 1;
        }
      };
      k = k + 1;
    }
    i = i + 1;
  }

  let mut i = 0;
  while i < n {
    let mut j = 0;
    while j < n {
      set_mat(inv, i, j, mat_get(temp, i, j + n));
      j = j + 1;
    }
    i = i + 1;
  }
  0
}

fn print_double(x : Double) -> Unit {
  print_int(int_of_float(x));
}

fn main {
  let n = 8;
  let mat = new_mat(n, n);
  let inv = new_mat(n, n);
  simple_srand(42);
  rand_mat(mat, n);
  let sum_before = sum_all_mat(mat, n);
  let status = inv_mat(mat, inv, n);
  let mut sum_after = 0.0;
  if status == 0 {
    sum_after = sum_all_mat(inv, n);
  };
  print_double(sum_before);
  print_double(sum_after);
}
