// Test nested for loops
fn main {
  let mut result = 0
  for i = 0; i < 5; i = i + 1 {
    for j = 0; j < 3; j = j + 1 {
      result = result + 1
    }
  }
  println(result)
}

