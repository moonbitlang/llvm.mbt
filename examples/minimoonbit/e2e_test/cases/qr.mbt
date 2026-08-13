extern "C" fn print_int(x : Int) = "print_int";
extern "C" fn int_of_float(x : Double) -> Int = "int_of_float";
extern "C" fn float_of_int(x : Int) -> Double = "float_of_int";
extern "C" fn sqrt(x : Double) -> Double = "sqrt";

let n : Int = 8;

let next : Array[Int] = [1];

fn simple_rand() -> Int {
  next[0] = next[0] * 1103515245 + 12345;
  let temp = next[0] / 65536 % 32768;
  temp
}

fn simple_srand(seed : Int) -> Unit {
  next[0] = seed;
}

fn new_mat(rows : Int, cols : Int) -> Array[Array[Double]] {
  let data = Array::make(rows, Array::make(cols, 0.0));
  let mut i = 0;
  while i < rows {
    data[i] = Array::make(cols, 0.0);
    i = i + 1;
  }
  data
}

fn mat_get(m : Array[Array[Double]], i : Int, j : Int) -> Double {
  m[i][j]
}

fn set_mat(m : Array[Array[Double]], i : Int, j : Int, value : Double) -> Unit {
  m[i][j] = value;
}

fn rand_mat(mat : Array[Array[Double]], n : Int) -> Unit {
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

fn sum_of_mat(mat : Array[Array[Double]], n : Int) -> Double {
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

fn copy_mat(dest : Array[Array[Double]], src : Array[Array[Double]], n : Int) -> Unit {
  let mut i = 0;
  while i < n {
    let mut j = 0;
    while j < n {
      set_mat(dest, i, j, mat_get(src, i, j));
      j = j + 1;
    }
    i = i + 1;
  }
}

fn qr_decomp(a : Array[Array[Double]], q : Array[Array[Double]], r : Array[Array[Double]], n : Int) -> Int {
  let a_copy = new_mat(n, n);
  copy_mat(a_copy, a, n);

  let mut i = 0;
  while i < n {
    let mut j = 0;
    while j < n {
      set_mat(r, i, j, 0.0);
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
    set_mat(r, i, i, sqrt(norm));

    let rii = mat_get(r, i, i);
    if rii < 0.0000000001 {
      let mut k = 0;
      while k < n {
        set_mat(q, k, i, 0.0);
        k = k + 1;
      }
    } else {
      let mut k = 0;
      while k < n {
        set_mat(q, k, i, mat_get(a_copy, k, i) / rii);
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
      set_mat(r, i, j, dot_product);
      let mut k = 0;
      while k < n {
        let old_val = mat_get(a_copy, k, j);
        let new_val = old_val - mat_get(r, i, j) * mat_get(q, k, i);
        set_mat(a_copy, k, j, new_val);
        k = k + 1;
      }
      j = j + 1;
    }
    i = i + 1;
  }
  1
}

fn matrix_multiply(a : Array[Array[Double]], b : Array[Array[Double]], result : Array[Array[Double]], n : Int) -> Unit {
  let mut i = 0;
  while i < n {
    let mut j = 0;
    while j < n {
      set_mat(result, i, j, 0.0);
      let mut k = 0;
      while k < n {
        let old_val = mat_get(result, i, j);
        let new_val = old_val + mat_get(a, i, k) * mat_get(b, k, j);
        set_mat(result, i, j, new_val);
        k = k + 1;
      }
      j = j + 1;
    }
    i = i + 1;
  }
}

fn print_double(x : Double) -> Unit {
  print_int(int_of_float(x));
}


fn main {
  let matrix_n = n;
  let a = new_mat(matrix_n, matrix_n);
  let q = new_mat(matrix_n, matrix_n);
  let r = new_mat(matrix_n, matrix_n);
  simple_srand(1234);
  rand_mat(a, matrix_n);
  let sum_a = sum_of_mat(a, matrix_n);
  print_double(sum_a);
  let status = qr_decomp(a, q, r, matrix_n);
  if status == 1 {
    let sum_q = sum_of_mat(q, matrix_n);
    let sum_r = sum_of_mat(r, matrix_n);
    print_double(sum_q);
    print_double(sum_r);

    let qr = new_mat(matrix_n, matrix_n);
    matrix_multiply(q, r, qr, matrix_n);
    let sum_qr = sum_of_mat(qr, matrix_n);
    print_double(sum_qr);
  } else {
    print_int(0);
  }
}
