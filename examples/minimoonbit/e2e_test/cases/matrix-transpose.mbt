extern "C" fn print_int(x : Int) = "print_int";
extern "C" fn print_endline() = "print_endline";

// Complex matrix operations using for loops with array.length() method calls
fn transpose(src: Array[Array[Int]], dst: Array[Array[Int]]) -> Unit {
  // Use array.length() method in for loop conditions
  for i = 0; i < src.length(); i = i + 1 {
    for j = 0; j < src[0].length(); j = j + 1 {
      dst[j][i] = src[i][j];
    }
  }
}

fn multiply_scalar(mat: Array[Array[Int]], scalar: Int) -> Unit {
  let rows = mat.length();
  let cols = mat[0].length();
  for i = 0; i < rows; i = i + 1 {
    for j = 0; j < cols; j = j + 1 {
      mat[i][j] = mat[i][j] * scalar;
    }
  }
}

fn add_matrices(a: Array[Array[Int]], b: Array[Array[Int]], result: Array[Array[Int]]) -> Unit {
  for i = 0; i < a.length(); i = i + 1 {
    // Calculate cols inside outer loop using array.length()
    for j = 0; j < a[i].length(); j = j + 1 {
      result[i][j] = a[i][j] + b[i][j];
    }
  }
}

fn trace(mat: Array[Array[Int]]) -> Int {
  let mut sum = 0;
  let size = mat.length();
  for i = 0; i < size; i = i + 1 {
    sum = sum + mat[i][i];
  }
  sum
}

fn main {
  // Create 3x3 matrices
  let dummy = Array::make(0, 0);
  let mat1 = Array::make(3, dummy);
  let mat2 = Array::make(3, dummy);
  let mat_t = Array::make(3, dummy);
  let mat_result = Array::make(3, dummy);
  
  // Initialize matrices
  for i = 0; i < 3; i = i + 1 {
    mat1[i] = Array::make(3, 0);
    mat2[i] = Array::make(3, 0);
    mat_t[i] = Array::make(3, 0);
    mat_result[i] = Array::make(3, 0);
  }
  
  // Fill mat1 with values 1-9
  let mut val = 1;
  for i = 0; i < 3; i = i + 1 {
    for j = 0; j < 3; j = j + 1 {
      mat1[i][j] = val;
      val = val + 1;
    }
  }
  
  // Fill mat2 with values 9-1
  let mut val2 = 9;
  for i = 0; i < 3; i = i + 1 {
    for j = 0; j < 3; j = j + 1 {
      mat2[i][j] = val2;
      val2 = val2 - 1;
    }
  }
  
  // Perform operations
  transpose(mat1, mat_t);
  add_matrices(mat1, mat2, mat_result);
  multiply_scalar(mat_result, 2);
  
  // Print results
  let tr = trace(mat1);
  print_int(tr);  // Should be 15 (1+5+9)
  print_endline();
  
  let tr_result = trace(mat_result);
  print_int(tr_result);  // Should be 60 (2*(1+9) + 2*(5+5) + 2*(9+1))
  print_endline();
  
  // Print transposed element
  print_int(mat_t[1][0]);  // Should be 4 (mat1[0][1])
  print_endline();
  
  ()
}

