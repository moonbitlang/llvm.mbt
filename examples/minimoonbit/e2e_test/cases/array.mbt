
// Test array.length() and array.push() methods
fn main {
  let arr = [1, 2, 3]
  
  // Test length method
  let len = arr.length()
  println(len)
  
  // Test push method
  arr.push(4)
  arr.push(5)
  
  let new_len = arr.length();
  println(new_len)
  
  // Print all elements
  for i = 0; i < arr.length(); i = i + 1 {
    println(arr[i])
  }
}


