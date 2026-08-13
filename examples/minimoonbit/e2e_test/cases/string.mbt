fn main {
  let a = "Hello"
  let b = "World"
  let c = a + " " + b
  let d = c + "!"
  println(d.length())
  for i = 0; i < d.length(); i = i + 1 {
    println(d[i])
  }
  
  // Test string comparison
  if a == "Hello" {
    println("a is Hello")
  }
  if b == "World" {
    println("b is World")
  }
  if d == "Hello World!" {
    println("d is Hello World!")
  }
  if a == b {
    println("a equals b")
  } else {
    println("a not equals b")
  }
}


