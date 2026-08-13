
extern "C" fn print_int(x : Int) = "print_int";
extern "C" fn int_of_float(x : Double) -> Int = "int_of_float";
extern "C" fn float_of_int(x : Int) -> Double = "float_of_int";
extern "C" fn sqrt(x : Double) -> Double = "sqrt";

let n_const : Int = 8;

let next : Array[Int] = [1];

fn simple_rand() -> Int {
  next[0] = next[0] * 1103515245 + 12345;
  let temp = next[0] / 65536 % 32768;
  if temp < 0 { -temp } else { temp }
}

fn simple_srand(seed : Int) -> Unit {
  next[0] = seed;
}

fn abs_double(x : Double) -> Double {
  if x < 0.0 { -x } else { x }
}

fn sqrt_double(x : Double) -> Double {
  if x <= 0.0 { 0.0 } else { sqrt(x) }
}

struct Matrix {
  data : Array[Array[Double]];
  rows : Int;
  cols : Int;
}

fn alloc_mat(rows : Int, cols : Int) -> Matrix {
  let data = Array::make(rows, Array::make(cols, 0.0));
  let mut i = 0;
  while i < rows {
    data[i] = Array::make(cols, 0.0);
    i = i + 1;
  }
  Matrix::{ data: data, rows: rows, cols: cols }
}

fn alloc_vec(size : Int) -> Array[Double] {
  Array::make(size, 0.0)
}

fn mat_get(m : Matrix, i : Int, j : Int) -> Double {
  m.data[i][j]
}

fn mat_set(m : Matrix, i : Int, j : Int, value : Double) -> Unit {
  m.data[i][j] = value;
}

fn rand_mat(mat : Matrix, n : Int) -> Unit {
  let mut i = 0;
  while i < n {
    let mut j = 0;
    while j < n {
      mat_set(mat, i, j, float_of_int(simple_rand() % 10));
      j = j + 1;
    }
    i = i + 1;
  }
}

fn sum_of_mat(mat : Matrix, n : Int) -> Double {
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

fn mat_mul(a : Matrix, b : Matrix, c : Matrix, m : Int, p : Int, n : Int) -> Unit {
  let mut i = 0;
  while i < m {
    let mut j = 0;
    while j < n {
      mat_set(c, i, j, 0.0);
      let mut k = 0;
      while k < p {
        let old_val = mat_get(c, i, j);
        let new_val = old_val + mat_get(a, i, k) * mat_get(b, k, j);
        mat_set(c, i, j, new_val);
        k = k + 1;
      }
      j = j + 1;
    }
    i = i + 1;
  }
}

fn mat_transpose(a : Matrix, b : Matrix, m : Int, n : Int) -> Unit {
  let mut i = 0;
  while i < m {
    let mut j = 0;
    while j < n {
      mat_set(b, j, i, mat_get(a, i, j));
      j = j + 1;
    }
    i = i + 1;
  }
}

fn jacobi_rotation(a : Matrix, n : Int, d : Array[Double], v : Matrix) -> Unit {
  let a_copy = alloc_mat(n, n);
  let mut i = 0;
  while i < n {
    let mut j = 0;
    while j < n {
      mat_set(a_copy, i, j, mat_get(a, i, j));
      j = j + 1;
    }
    i = i + 1;
  }
  
  let mut i = 0;
  while i < n {
    let mut j = 0;
    while j < n {
      mat_set(v, i, j, if i == j { 1.0 } else { 0.0 });
      j = j + 1;
    }
    i = i + 1;
  }
  
  let max_iter = 10000;
  let mut iter = 0;
  while iter < max_iter {
    let mut max_off_diag = 0.0;
    let mut p = 0;
    let mut q = 1;
    
    let mut i = 0;
    while i < n {
      let mut j = i + 1;
      while j < n {
        let abs_val = abs_double(mat_get(a_copy, i, j));
        if abs_val > max_off_diag {
          max_off_diag = abs_val;
          p = i;
          q = j;
        };
        j = j + 1;
      }
      i = i + 1;
    }
    
    if max_off_diag < 0.000000000001 {
      iter = max_iter;
    } else {
      let apq = mat_get(a_copy, p, q);
      let tau = (mat_get(a_copy, q, q) - mat_get(a_copy, p, p)) / (2.0 * apq);
      let t = if tau >= 0.0 {
        1.0 / (tau + sqrt_double(1.0 + tau * tau))
      } else {
        -1.0 / (-tau + sqrt_double(1.0 + tau * tau))
      };
      let c = 1.0 / sqrt_double(1.0 + t * t);
      let s = t * c;
      
      let app = mat_get(a_copy, p, p);
      let aqq = mat_get(a_copy, q, q);
      mat_set(a_copy, p, p, c * c * app - 2.0 * c * s * apq + s * s * aqq);
      mat_set(a_copy, q, q, s * s * app + 2.0 * c * s * apq + c * c * aqq);
      mat_set(a_copy, p, q, 0.0);
      mat_set(a_copy, q, p, 0.0);
      
      let mut i = 0;
      while i < n {
        if i != p && i != q {
          let aip = mat_get(a_copy, i, p);
          let aiq = mat_get(a_copy, i, q);
          mat_set(a_copy, i, p, c * aip - s * aiq);
          mat_set(a_copy, p, i, mat_get(a_copy, i, p));
          mat_set(a_copy, i, q, s * aip + c * aiq);
          mat_set(a_copy, q, i, mat_get(a_copy, i, q));
        };
        i = i + 1;
      }
      
      let mut i = 0;
      while i < n {
        let vip = mat_get(v, i, p);
        let viq = mat_get(v, i, q);
        mat_set(v, i, p, c * vip - s * viq);
        mat_set(v, i, q, s * vip + c * viq);
        i = i + 1;
      }
      
      iter = iter + 1;
    };
  }
  
  let mut i = 0;
  while i < n {
    d[i] = mat_get(a_copy, i, i);
    i = i + 1;
  }
}

fn eigen_decomp(a : Matrix, v : Matrix, d : Array[Double], n : Int) -> Bool {
  jacobi_rotation(a, n, d, v);
  true
}

fn print_double(x : Double) -> Unit {
  print_int(int_of_float(x));
}

fn main {
  let n = n_const;
  let a = alloc_mat(n, n);
  let v = alloc_mat(n, n);
  let d = alloc_vec(n);
  simple_srand(5678);
  rand_mat(a, n);

  let mut i = 0;
  while i < n {
    let mut j = i;
    while j < n {
      mat_set(a, j, i, mat_get(a, i, j));
      j = j + 1;
    }
    i = i + 1;
  }
  
  let original_sum = sum_of_mat(a, n);
  print_double(original_sum);
  
  if eigen_decomp(a, v, d, n) {
    let mut sum_eigenvalues = 0.0;
    let mut i = 0;
    while i < n {
      sum_eigenvalues = sum_eigenvalues + d[i];
      i = i + 1;
    }
    print_double(sum_eigenvalues);
    
    let d_mat = alloc_mat(n, n);
    let vt = alloc_mat(n, n);
    let temp = alloc_mat(n, n);
    let a_recon = alloc_mat(n, n);
    
    let mut i = 0;
    while i < n {
      let mut j = 0;
      while j < n {
        mat_set(d_mat, i, j, if i == j { d[i] } else { 0.0 });
        j = j + 1;
      }
      i = i + 1;
    }
    
    mat_transpose(v, vt, n, n);
    mat_mul(v, d_mat, temp, n, n, n);
    mat_mul(temp, vt, a_recon, n, n, n);
    let recon_sum = sum_of_mat(a_recon, n);
    print_double(recon_sum);
  } else {
    print_int(0);
  }
}
