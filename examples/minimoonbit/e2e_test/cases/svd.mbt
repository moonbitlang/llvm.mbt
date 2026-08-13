extern "C" fn print_int(x : Int) = "print_int";
extern "C" fn int_of_float(x : Double) -> Int = "int_of_float";
extern "C" fn float_of_int(x : Int) -> Double = "float_of_int";
extern "C" fn sqrt(x : Double) -> Double = "sqrt";

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

fn alloc_mat(rows : Int, cols : Int) -> Array[Array[Double]] {
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

fn mat_set(m : Array[Array[Double]], i : Int, j : Int, value : Double) -> Unit {
  m[i][j] = value;
}

fn rand_mat_mn(mat : Array[Array[Double]], m_size : Int, n_size : Int) -> Unit {
  let mut i = 0;
  while i < m_size {
    let mut j = 0;
    while j < n_size {
      mat_set(mat, i, j, float_of_int(simple_rand() % 10));
      j = j + 1;
    }
    i = i + 1;
  }
}

fn mat_mul(a : Array[Array[Double]], b : Array[Array[Double]], c : Array[Array[Double]], m_size : Int, p_size : Int, n_size : Int) -> Unit {
  let mut i = 0;
  while i < m_size {
    let mut j = 0;
    while j < n_size {
      mat_set(c, i, j, 0.0);
      let mut k = 0;
      while k < p_size {
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

fn mat_transpose(at : Array[Array[Double]], bt : Array[Array[Double]], m_size : Int, n_size : Int) -> Unit {
  let mut i = 0;
  while i < m_size {
    let mut j = 0;
    while j < n_size {
      mat_set(bt, j, i, mat_get(at, i, j));
      j = j + 1;
    }
    i = i + 1;
  }
}

fn jacobi_eigen(at : Array[Array[Double]], n_size : Int, d : Array[Double], vt : Array[Array[Double]]) -> Unit {
  let a_copy = alloc_mat(n_size, n_size);
  let mut i = 0;
  while i < n_size {
    let mut j = 0;
    while j < n_size {
      mat_set(a_copy, i, j, mat_get(at, i, j));
      j = j + 1;
    }
    i = i + 1;
  }
  
  let mut i = 0;
  while i < n_size {
    let mut j = 0;
    while j < n_size {
      mat_set(vt, i, j, if i == j { 1.0 } else { 0.0 });
      j = j + 1;
    }
    i = i + 1;
  }
  
  let max_iter = 100;
  let mut iter = 0;
  while iter < max_iter {
    let mut max_off_diag = 0.0;
    let mut p = 0;
    let mut q = 1;
    let mut i = 0;
    while i < n_size {
      let mut j = i + 1;
      while j < n_size {
        if abs_double(mat_get(a_copy, i, j)) > max_off_diag {
          max_off_diag = abs_double(mat_get(a_copy, i, j));
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
      let app = mat_get(a_copy, p, p);
      let apq = mat_get(a_copy, p, q);
      let aqq = mat_get(a_copy, q, q);
      let tau = (aqq - app) / (2.0 * apq);
      let t = if tau >= 0.0 { 
        1.0 / (tau + sqrt(1.0 + tau * tau)) 
      } else { 
        -1.0 / (-tau + sqrt(1.0 + tau * tau)) 
      };
      let c = 1.0 / sqrt(1.0 + t * t);
      let s = t * c;
      
      let r = alloc_mat(n_size, n_size);
      let mut i = 0;
      while i < n_size {
        let mut j = 0;
        while j < n_size {
          mat_set(r, i, j, if i == j { 1.0 } else { 0.0 });
          j = j + 1;
        }
        i = i + 1;
      }
      mat_set(r, p, p, c);
      mat_set(r, p, q, s);
      mat_set(r, q, p, -s);
      mat_set(r, q, q, c);
      
      let v_new = alloc_mat(n_size, n_size);
      mat_mul(vt, r, v_new, n_size, n_size, n_size);
      let mut i = 0;
      while i < n_size {
        let mut j = 0;
        while j < n_size {
          mat_set(vt, i, j, mat_get(v_new, i, j));
          j = j + 1;
        }
        i = i + 1;
      }
      
      let rt = alloc_mat(n_size, n_size);
      mat_transpose(r, rt, n_size, n_size);
      let temp = alloc_mat(n_size, n_size);
      mat_mul(rt, a_copy, temp, n_size, n_size, n_size);
      mat_mul(temp, r, a_copy, n_size, n_size, n_size);
      
      iter = iter + 1;
    };
  }
  
  let mut i = 0;
  while i < n_size {
    d[i] = mat_get(a_copy, i, i);
    i = i + 1;
  }
}

fn svd_decomp(at : Array[Array[Double]], m_size : Int, n_size : Int, ut : Array[Array[Double]], st : Array[Array[Double]], vt : Array[Array[Double]]) -> Int {
  if m_size < n_size {
    return -1;
  };
  
  let a_transpose = alloc_mat(n_size, m_size);
  let ata = alloc_mat(n_size, n_size);
  mat_transpose(at, a_transpose, m_size, n_size);
  mat_mul(a_transpose, at, ata, n_size, m_size, n_size);
  
  let eigenvalues = Array::make(n_size, 0.0);
  jacobi_eigen(ata, n_size, eigenvalues, vt);
  
  let mut i = 0;
  while i < n_size {
    let mut max_idx = i;
    let mut j = i + 1;
    while j < n_size {
      if eigenvalues[j] > eigenvalues[max_idx] {
        max_idx = j;
      };
      j = j + 1;
    }
    if max_idx != i {
      let temp_eig = eigenvalues[i];
      eigenvalues[i] = eigenvalues[max_idx];
      eigenvalues[max_idx] = temp_eig;
      let mut k = 0;
      while k < n_size {
        let temp_vec = mat_get(vt, k, i);
        mat_set(vt, k, i, mat_get(vt, k, max_idx));
        mat_set(vt, k, max_idx, temp_vec);
        k = k + 1;
      }
    };
    i = i + 1;
  }
  
  let mut i = 0;
  while i < m_size {
    let mut j = 0;
    while j < n_size {
      mat_set(st, i, j, 0.0);
      j = j + 1;
    }
    i = i + 1;
  }
  let mut i = 0;
  while i < n_size {
    mat_set(st, i, i, if eigenvalues[i] > 0.0 { sqrt(eigenvalues[i]) } else { 0.0 });
    i = i + 1;
  }
  
  let temp = alloc_mat(m_size, n_size);
  mat_mul(at, vt, temp, m_size, n_size, n_size);
  let mut j = 0;
  while j < n_size {
    let s_val = mat_get(st, j, j);
    if s_val > 0.0000000001 {
      let mut i = 0;
      while i < m_size {
        mat_set(ut, i, j, mat_get(temp, i, j) / s_val);
        i = i + 1;
      }
    } else {
      let mut i = 0;
      while i < m_size {
        mat_set(ut, i, j, 0.0);
        i = i + 1;
      }
    };
    j = j + 1;
  }
  
  let mut i = 0;
  while i < m_size {
    let mut j = n_size;
    while j < m_size {
      mat_set(ut, i, j, 0.0);
      j = j + 1;
    }
    i = i + 1;
  }
  
  0
}

fn sum_of_mat(mat : Array[Array[Double]], m_size : Int, n_size : Int) -> Double {
  let mut sum = 0.0;
  let mut i = 0;
  while i < m_size {
    let mut j = 0;
    while j < n_size {
      sum = sum + mat_get(mat, i, j);
      j = j + 1;
    }
    i = i + 1;
  }
  sum
}

fn print_double(x : Double) -> Unit {
  print_int(int_of_float(x));
}


fn main {
  let m : Int = 8;
  let n : Int = 4;

  let a_matrix = alloc_mat(m, n);
  let u_matrix = alloc_mat(m, m);
  let s_matrix = alloc_mat(m, n);
  let v_matrix = alloc_mat(n, n);
  
  simple_srand(123);
  rand_mat_mn(a_matrix, m, n);
  let original_sum = sum_of_mat(a_matrix, m, n);
  print_double(original_sum);
  
  if svd_decomp(a_matrix, m, n, u_matrix, s_matrix, v_matrix) == 0 {
    let sum_u = sum_of_mat(u_matrix, m, m);
    let sum_s = sum_of_mat(s_matrix, m, n);
    let sum_v = sum_of_mat(v_matrix, n, n);
    print_double(sum_u);
    print_double(sum_s);
    print_double(sum_v);
  }
}
