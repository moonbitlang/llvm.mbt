fn repeat_string(s: String, n: Int) -> String {
  let mut result = ""
  for i = 0; i < n; i = i + 1 {
    result = result + s
  }
  result
}

fn main {
  let base = "AB"
  let repeated = repeat_string(base, 3)
  println(repeated.length())
  
  let joined = repeated + "XY"
  println(joined.length())
  
  for i = 0; i < joined.length(); i = i + 1 {
    println(joined[i])
  }
  
  // Test string comparison
  if repeated == "ABABAB" {
    println("repeated is ABABAB")
  }
  if joined == "ABABABXY" {
    println("joined is ABABABXY")
  }
  if base == "AB" {
    println("base is AB")
  }
}

