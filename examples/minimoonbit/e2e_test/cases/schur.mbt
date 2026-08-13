extern "C" fn print_int(x : Int) = "print_int";
extern "C" fn sqrt(x : Double) -> Double = "sqrt";
extern "C" fn int_of_float(x : Double) -> Int = "int_of_float";
extern "C" fn float_of_int(x : Int) -> Double = "float_of_int";

let rng_next : Array[Int] = [1];

fn simple_rand() -> Int {
  rng_next[0] = rng_next[0] * 1103515245 + 12345;
  let temp = rng_next[0] / 65536 % 32768;
  if temp < 0 { -temp } else { temp }
}

fn simple_srand(seed : Int) -> Unit {
  rng_next[0] = seed;
}

struct Matrix {
  data : Array[Array[Double]];
  rows : Int;
  cols : Int;
}

fn new_matrix(rows : Int, cols : Int) -> Matrix {
  let data = Array::make(rows, Array::make(cols, 0.0));
  let mut i = 0;
  while i < rows {
    data[i] = Array::make(cols, 0.0);
    i = i + 1;
  }
  Matrix::{ data: data, rows: rows, cols: cols }
}

fn mat_get(m : Matrix, i : Int, j : Int) -> Double {
  m.data[i][j]
}

fn mat_set(m : Matrix, i : Int, j : Int, value : Double) -> Unit {
  m.data[i][j] = value;
}

fn rand_fill_matrix(mat : Matrix, rows : Int, cols : Int) -> Unit {
  let mut i = 0;
  while i < rows {
    let mut j = 0;
    while j < cols {
      mat_set(mat, i, j, float_of_int(simple_rand() % 10));
      j = j + 1;
    }
    i = i + 1;
  }
}

fn sum_matrix(mat : Matrix, rows : Int, cols : Int) -> Double {
  let mut sum = 0.0;
  let mut i = 0;
  while i < rows {
    let mut j = 0;
    while j < cols {
      sum = sum + mat_get(mat, i, j);
      j = j + 1;
    }
    i = i + 1;
  }
  sum
}

fn copy_matrix(dest : Matrix, src : Matrix, rows : Int, cols : Int) -> Unit {
  let mut i = 0;
  while i < rows {
    let mut j = 0;
    while j < cols {
      mat_set(dest, i, j, mat_get(src, i, j));
      j = j + 1;
    }
    i = i + 1;
  }
}

fn identity_matrix(mat : Matrix, n : Int) -> Unit {
  let mut i = 0;
  while i < n {
    let mut j = 0;
    while j < n {
      mat_set(mat, i, j, if i == j { 1.0 } else { 0.0 });
      j = j + 1;
    }
    i = i + 1;
  }
}

fn multiply_matrices(a : Matrix, b : Matrix, result : Matrix, rows : Int, inner : Int, cols : Int) -> Unit {
  let temp = new_matrix(rows, cols);
  let mut i = 0;
  while i < rows {
    let mut j = 0;
    while j < cols {
      let mut sum = 0.0;
      let mut k = 0;
      while k < inner {
        sum = sum + mat_get(a, i, k) * mat_get(b, k, j);
        k = k + 1;
      }
      mat_set(temp, i, j, sum);
      j = j + 1;
    }
    i = i + 1;
  }
  copy_matrix(result, temp, rows, cols);
}

fn transpose_matrix(source : Matrix, target : Matrix, rows : Int, cols : Int) -> Unit {
  let mut i = 0;
  while i < rows {
    let mut j = 0;
    while j < cols {
      mat_set(target, j, i, mat_get(source, i, j));
      j = j + 1;
    }
    i = i + 1;
  }
}

fn qr_decomp_helper(a : Matrix, q : Matrix, r : Matrix, n : Int) -> Bool {
  let a_copy = new_matrix(n, n);
  copy_matrix(a_copy, a, n, n);

  let mut i = 0;
  while i < n {
    let mut j = 0;
    while j < n {
      mat_set(r, i, j, 0.0);
      j = j + 1;
    }
    i = i + 1;
  }

  let mut i = 0;
  while i < n {
    let mut norm = 0.0;
    let mut k = 0;
    while k < n {
      let val = mat_get(a_copy, k, i);
      norm = norm + val * val;
      k = k + 1;
    }
    mat_set(r, i, i, sqrt(norm));

    let rii = mat_get(r, i, i);
    if rii > 0.0000000001 {
      let mut k = 0;
      while k < n {
        mat_set(q, k, i, mat_get(a_copy, k, i) / rii);
        k = k + 1;
      }
    } else {
      let mut k = 0;
      while k < n {
        mat_set(q, k, i, 0.0);
        k = k + 1;
      }
    };

    let mut j = i + 1;
    while j < n {
      let mut dot_product = 0.0;
      let mut k = 0;
      while k < n {
        dot_product = dot_product + mat_get(q, k, i) * mat_get(a_copy, k, j);
        k = k + 1;
      }
      mat_set(r, i, j, dot_product);
      let mut k = 0;
      while k < n {
        let old_val = mat_get(a_copy, k, j);
        mat_set(a_copy, k, j, old_val - mat_get(r, i, j) * mat_get(q, k, i));
        k = k + 1;
      }
      j = j + 1;
    }
    i = i + 1;
  }
  true
}

fn schur_decomp(a : Matrix, q : Matrix, t : Matrix, n : Int) -> Bool {
  copy_matrix(t, a, n, n);
  identity_matrix(q, n);
  let q_k = new_matrix(n, n);
  let r_k = new_matrix(n, n);
  let t_shifted = new_matrix(n, n);
  let max_iter = 100;
  let mut k = 0;
  while k < max_iter {
    let shift = mat_get(t, n - 1, n - 1);

    copy_matrix(t_shifted, t, n, n);
    let mut i = 0;
    while i < n {
      let old_val = mat_get(t_shifted, i, i);
      mat_set(t_shifted, i, i, old_val - shift);
      i = i + 1;
    }

    if qr_decomp_helper(t_shifted, q_k, r_k, n) {
      multiply_matrices(r_k, q_k, t, n, n, n);
      let mut i = 0;
      while i < n {
        let old_val = mat_get(t, i, i);
        mat_set(t, i, i, old_val + shift);
        i = i + 1;
      }

      multiply_matrices(q, q_k, q, n, n, n);
    };
    k = k + 1;
  }
  true
}

fn print_double(x : Double) -> Unit {
  print_int(int_of_float(x));
}


fn main {
  let n = 8;
  let a = new_matrix(n, n);
  let q = new_matrix(n, n);
  let t = new_matrix(n, n);
  simple_srand(2024);
  rand_fill_matrix(a, n, n);
  let original_sum = sum_matrix(a, n, n);
  print_double(original_sum);
  if schur_decomp(a, q, t, n) {
    let q_sum = sum_matrix(q, n, n);
    let t_sum = sum_matrix(t, n, n);
    print_double(q_sum);
    print_double(t_sum);

    let qt = new_matrix(n, n);
    let temp = new_matrix(n, n);
    let a_recon = new_matrix(n, n);
    transpose_matrix(q, qt, n, n);
    multiply_matrices(q, t, temp, n, n, n);
    multiply_matrices(temp, qt, a_recon, n, n, n);
    let recon_sum = sum_matrix(a_recon, n, n);
    print_double(recon_sum);
  } else {
    print_int(0);
  }
}
