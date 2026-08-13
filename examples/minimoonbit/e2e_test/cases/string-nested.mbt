fn concat_multiple(a: String, b: String, c: String) -> String {
  a + b + c
}

fn main {
  let s1 = "Foo"
  let s2 = "Bar"
  let s3 = "Baz"
  let result = concat_multiple(s1, s2, s3)
  println(result.length())
  
  let prefix = "Pre"
  let suffix = "Post"
  let middle = prefix + result + suffix
  println(middle.length())
  
  for i = 0; i < middle.length(); i = i + 1 {
    println(middle[i])
  }
  
  // Test string comparison
  if result == "FooBarBaz" {
    println("result is FooBarBaz")
  }
  if middle == "PreFooBarBazPost" {
    println("middle is PreFooBarBazPost")
  }
  if s1 == "Foo" {
    println("s1 is Foo")
  }
}

