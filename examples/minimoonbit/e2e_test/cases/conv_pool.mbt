
extern "C" fn print_int(x : Int) = "print_int";
extern "C" fn truncate(x : Double) -> Int = "truncate";

fn relu(x: Double) -> Double {
  if x >= 0.0 {
    x
  } else {
    0.0
  }
}

fn leaky_relu(x: Double, alpha: Double) -> Double {
  if x >= 0.0 {
    x
  } else {
    alpha * x
  }
}

fn conv(mat: Array[Array[Double]], w: Int, h: Int, kernel: Array[Array[Double]], kw: Int, kh: Int, stride: Int, activation: (Double) -> Double) -> Array[Array[Double]] {
  let output_w = (w - kw) / stride + 1;
  let output_h = (h - kh) / stride + 1;
  let output_mat = Array::make(output_h, [0.0]);
  let mut i = 0;
  while i < output_h {
    output_mat[i] = Array::make(output_w, 0.0);
    i = i + 1;
  }

  let mut row = 0;
  let mut col = 0;
  let mut kr = 0;
  let mut kc = 0;

  while col < output_h {
    row = 0;
    while row < output_w {
      kc = 0;
      while kc < kw {
        kr = 0;
        while kr < kh {
          output_mat[col][row] = output_mat[col][row] + mat[col * stride + kr][row * stride + kc] * kernel[kr][kc];
          kr = kr + 1;
        }
        kc = kc + 1;
      }
      output_mat[col][row] = activation(output_mat[col][row]);
      row = row + 1;
    }
    col = col + 1;
  }
  output_mat
}


fn max_pooling(mat: Array[Array[Double]], w: Int, h: Int, kw: Int, kh: Int, stride: Int) -> Array[Array[Double]] {
  let output_w = (w - kw) / stride + 1;
  let output_h = (h - kh) / stride + 1;
  let output_mat = Array::make(output_h, [0.0]);
  let mut i = 0;
  while i < output_h {
    output_mat[i] = Array::make(output_w, 0.0);
    i = i + 1;
  }

  let mut row = 0;
  let mut col = 0;
  let mut kr = 0;
  let mut kc = 0;

  while row < output_h {
    col = 0;
    while col < output_w {
      let mut max_val = -10000000000.0;
      kr = 0;
      while kr < kh {
        kc = 0;
        while kc < kw {
          let row_idx = row * stride + kr;
          let col_idx = col * stride + kc;
          let mut value = 0.0;
          if row_idx < h && col_idx < w {
            value = mat[row * stride + kr][col * stride + kc];
          };
          if value > max_val {
            max_val = value;
          };
          kc = kc + 1;
        }
        kr = kr + 1;
      }
      output_mat[row][col] = max_val;
      col = col + 1;
    }
    row = row + 1;
  }
  output_mat
}

fn print_mat(mat: Array[Array[Double]], w: Int, h: Int) -> Unit {
  let mut i = 0;
  let mut j = 0;
  while i < h {
    j = 0;
    while j < w {
      print_int(truncate(mat[i][j]));
      j = j + 1;
    }
    i = i + 1;
  }
}

fn main {
  let data = [
    [ 8.88, 28.91,  6.71, 57.30, 88.56, 52.66, 48.26, 82.37, 17.93, 69.81, 80.24, 36.89, 10.50, 88.13, 71.27,  7.47, 54.59, 10.02, 99.29, 63.67],
    [52.39, 12.23, 49.99,  3.24, 75.79, 52.98, 55.06, 12.13, 40.98, 80.31, 10.53, 43.88, 70.05, 51.53, 32.55, 93.08, 32.14, 24.89, 90.24,  9.88],
    [36.44, 50.91,  2.37, 69.39, 93.20, 15.55, 27.35, 29.85, 10.93, 77.51, 79.74, 74.76, 62.74, 94.64, 70.07, 41.68, 10.11, 91.71, 29.53, 42.55],
    [73.16, 53.46, 49.55, 25.89, 15.72, 99.61, 57.70, 23.88, 21.25, 58.79, 42.45, 84.89, 18.20, 39.23, 82.68, 67.71, 21.40, 89.91, 57.87, 86.95],
    [98.35, 17.32, 40.67, 81.55, 67.52, 51.52, 38.14, 17.97, 85.37, 62.82, 29.32,  7.65, 64.89, 60.34, 36.68, 35.68, 68.18, 29.42, 21.92, 40.06],
    [39.82, 14.08, 43.62,  3.43, 86.12, 60.74,  7.90, 93.43, 33.24, 80.63, 13.77, 84.52, 45.92, 54.58, 55.26, 14.58, 22.93, 56.49, 96.19, 79.94],
    [87.74, 65.17, 64.89, 22.55, 50.79,  5.79, 83.72, 27.37, 16.63, 56.80, 51.34, 93.80,  3.54, 64.30, 26.48,  6.89, 82.57, 48.48, 18.09, 68.94],
    [11.34, 72.28, 66.69, 12.06, 28.10, 68.07, 93.01, 33.77, 85.30, 94.50, 31.52, 50.30,  1.52, 64.37, 78.58,  6.71, 48.97, 76.01, 82.99,  1.60],
    [69.66, 98.90,  2.90, 74.46,  8.23, 75.48, 13.64, 69.46, 84.66, 62.84, 28.82, 68.25, 97.94, 29.70,  7.38, 78.81, 66.81, 93.61, 22.10, 18.84]
  ];

  let data_w = 20;
  let data_h = 9;
  
  let conv_kernel = [
    [0.5, 0.25, -0.15],
    [0.7, -0.1, 0.2],
    [-0.2, 0.6, 0.2]
  ];
  let (conv_kw, conv_kh, conv_stride) = (3, 3, 1);

  let conv_out1 = conv(data, data_w, data_h, conv_kernel, conv_kw, conv_kh, conv_stride, relu);
  let conv_out1_w = (data_w - conv_kw) + 1;
  let conv_out1_h = (data_h - conv_kh) + 1;

  let pool_kw = 2;
  let pool_kh = 2;
  let pool_stride = 2;
  let pool_out1 = max_pooling(conv_out1, conv_out1_w, conv_out1_h, pool_kw, pool_kh, pool_stride);
  let pool_out1_w = (conv_out1_w - pool_kw) / pool_stride + 1;
  let pool_out1_h = (conv_out1_h - pool_kh) / pool_stride + 1;

  fn inner_leaky_relu(x) {
    leaky_relu(x, 0.01)
  }

  let conv_kernel2 = [
    [0.5, 0.25, 0.15],
    [0.1, 0.2, 0.4],
    [0.2, 0.3, 0.4]
  ];

  let (conv2_kw, conv2_kh, conv2_stride) = (3, 3, 1);
  let conv_out2 = conv(pool_out1, pool_out1_w, pool_out1_h, conv_kernel2, conv2_kw, conv2_kh, conv2_stride, inner_leaky_relu);
  let conv_out2_w = (pool_out1_w - conv2_kw) + 1;
  let conv_out2_h = (pool_out1_h - conv2_kh) + 1;

  print_mat(conv_out2, conv_out2_w, conv_out2_h);
}
