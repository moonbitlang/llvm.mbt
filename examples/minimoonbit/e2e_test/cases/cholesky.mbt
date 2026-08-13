
extern "C" fn print_int(x : Int) = "print_int";
extern "C" fn float_of_int(x : Int) -> Double = "float_of_int";
extern "C" fn int_of_float(x : Double) -> Int = "int_of_float";
extern "C" fn sqrt(x : Double) -> Double = "sqrt";

let next : Array[Int] = [1];

fn simple_rand() -> Int {
  next[0] = next[0] * 1103515245 + 12345;
  let temp = next[0] / 65536 % 32768;
  temp
}

fn simple_srand(seed : Int) -> Unit {
  next[0] = seed;
}

struct Matrix {
  data : Array[Array[Double]];
  rows : Int;
  cols : Int;
}

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

///|
/// 创建对称正定矩阵
fn create_spd_matrix(a : Matrix, n : Int) -> Unit {
  let m = new_mat(n, n);

  rand_mat(m, n);


  let mut i = 0;
  while i < n {
    let mut j = 0;
    while j < n {
      let mut sum = 0.0;
      let mut k = 0;
      while k < n {
        sum = sum + mat_get(m, i, k) * mat_get(m, j, k);
        k = k + 1;
      }
      set_mat(a, i, j, sum);
      j = j + 1;
    }
    i = i + 1;
  }

  let mut i = 0;
  while i < n {
    let current = mat_get(a, i, i);
    set_mat(a, i, i, current + 0.1);
    i = i + 1;
  }
}

fn cholesky_decomposition(a : Matrix, l : Matrix, n : Int) -> Bool {
  let mut i = 0;
  while i < n {
    let mut j = 0;
    while j <= i {
      let mut sum = 0.0;
      if j == i {
        let mut k = 0;
        while k < j {
          sum = sum + mat_get(l, j, k) * mat_get(l, j, k);
          k = k + 1;
        }
        let d = mat_get(a, j, j) - sum;
        if d <= 0.0 {
          // 矩阵不是正定的
          return false;
        };
        set_mat(l, j, j, sqrt(d))
      } else { // 非对角线元素
        let mut k = 0;
        while k < j {
          sum = sum + mat_get(l, i, k) * mat_get(l, j, k);
          k = k + 1;
        }
        let ljj = mat_get(l, j, j);
        if ljj == 0.0 {
          return false;
        };
        set_mat(l, i, j, (mat_get(a, i, j) - sum) / ljj);
      };
      j = j + 1;
    }
    i = i + 1;
  }
  true
}

fn main {
  let n = 8;
  simple_srand(42);

  let matrix_a = new_mat(n, n);
  let matrix_l = new_mat(n, n);

  create_spd_matrix(matrix_a, n);

  let mut checksum = 0.0;
  if cholesky_decomposition(matrix_a, matrix_l, n) {
    checksum = sum_all_mat(matrix_l, n);
  };
  print_int(int_of_float(checksum));
}
