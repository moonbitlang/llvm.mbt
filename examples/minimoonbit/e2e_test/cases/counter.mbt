
extern "C" fn print_int(x : Int) = "print_int";

fn counter(arr: Array[Int], arr_size: Int, cond: Array[(Int) -> Bool], cond_size: Int) -> Int {
  let mut cnt = 0;
  let mut i = 0;
  while i < arr_size {
    let mut j = 0;
    while j < cond_size {
      if cond[j](arr[i]) {
        cnt = cnt + 1;
      };
      j = j + 1
    }
    i = i + 1
  }
  cnt
}

fn main {
  fn f(x) { x > 0 }
  fn g(x) { x < 400 }

  let arr = [1, 4, 9, 1000, 2500, 3150, 4000, 748, 45, -275, -115, 33];
  let cond = [f, g]

  let arr_size = 12
  let cond_size = 2

  let result = counter(arr, arr_size, cond, cond_size);
  print_int(result);
}
