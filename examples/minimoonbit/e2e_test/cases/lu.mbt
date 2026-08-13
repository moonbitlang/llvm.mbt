extern "C" fn print_int(x : Int) = "print_int";
extern "C" fn int_of_float(x : Double) -> Int = "int_of_float";
extern "C" fn float_of_int(x : Int) -> Double = "float_of_int";

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

fn lu_decomposition(a_mat : Array[Array[Double]], l_mat : Array[Array[Double]], u_mat : Array[Array[Double]], n : Int) -> Int {
  let mut i = 0;
  while i < n {
    let mut j = 0;
    while j < n {
      set_mat(l_mat, i, j, 0.0);
      set_mat(u_mat, i, j, 0.0);
      j = j + 1;
    }
    i = i + 1;
  }

  let mut k = 0;
  while k < n {
    let mut j = k;
    while j < n {
      let mut sum = 0.0;
      let mut p = 0;
      while p < k {
        sum = sum + mat_get(l_mat, k, p) * mat_get(u_mat, p, j);
        p = p + 1;
      }
      set_mat(u_mat, k, j, mat_get(a_mat, k, j) - sum);
      j = j + 1;
    }

    set_mat(l_mat, k, k, 1.0);
    let mut i = k + 1;
    while i < n {
      let ukk = mat_get(u_mat, k, k);
      if ukk == 0.0 {
        return 0;
      };
      let mut sum = 0.0;
      let mut p = 0;
      while p < k {
        sum = sum + mat_get(l_mat, i, p) * mat_get(u_mat, p, k);
        p = p + 1;
      }
      set_mat(l_mat, i, k, (mat_get(a_mat, i, k) - sum) / ukk);
      i = i + 1;
    }
    k = k + 1;
  }
  1
}

fn matrix_multiply(l_mat : Array[Array[Double]], u_mat : Array[Array[Double]], result : Array[Array[Double]], n : Int) -> Unit {
  let mut i = 0;
  while i < n {
    let mut j = 0;
    while j < n {
      set_mat(result, i, j, 0.0);
      let mut k = 0;
      while k < n {
        let old_val = mat_get(result, i, j);
        let new_val = old_val + mat_get(l_mat, i, k) * mat_get(u_mat, k, j);
        set_mat(result, i, j, new_val);
        k = k + 1;
      }
      j = j + 1;
    }
    i = i + 1;
  }
}

fn print_double(x: Double) -> Unit {
  print_int(int_of_float(x));
}

fn main {
  let a_mat = new_mat(n, n);
  let l_mat = new_mat(n, n);
  let u_mat = new_mat(n, n);

  simple_srand(42);
  rand_mat(a_mat, n);
  let sum_ori_mat = sum_of_mat(a_mat, n);
  print_double(sum_ori_mat);

  let success = lu_decomposition(a_mat, l_mat, u_mat, n);
  if success == 1 {
    let sum_l_mat = sum_of_mat(l_mat, n);
    let sum_u_mat = sum_of_mat(u_mat, n);
    print_double(sum_l_mat);
    print_double(sum_u_mat);

    let lu_mat = new_mat(n, n);
    matrix_multiply(l_mat, u_mat, lu_mat, n);
    let sum_lu_mat = sum_of_mat(lu_mat, n);
    print_double(sum_lu_mat);
  } else {
    print_int(0);
  }
}
