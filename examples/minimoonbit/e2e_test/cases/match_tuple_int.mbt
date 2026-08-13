fn match_tuple_int(x: Int, y: Int, z: Int) -> Unit {
  match (x, (y, z)) {
    (1, (2, 3)) => println("Matched (1, (2, 3))")
    (1, (2, _)) => println("Matched (1, (2, _))")
    (1, _) => println("Matched (1, _)")
    (4, (5, 6)) => ()
    _ => ()
  }
}

fn match_int(x: Int) -> Unit {
  match x {
    -1 => println("Negative one")
    0 => println("Zero")
    1 => println("One")
    2 => println("Two")
    _ => println("Other number")
  }
}

fn main {
  match_int(-1)
  match_int(0)
  match_int(1)
  match_int(2)
  match_int(42)

  match_tuple_int(1, 2, 3)
  match_tuple_int(1, 2, 4)
  match_tuple_int(1, 5, 6)
  match_tuple_int(4, 5, 6)
}
