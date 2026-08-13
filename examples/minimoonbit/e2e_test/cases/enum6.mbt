
enum Color {
  Red
  Green
  Blue
  RGB(Int, Int, Int)
}

fn rgb(color: Color) -> (Int, Int, Int) {
  match color {
    Red => (255, 0, 0)
    Green => (0, 255, 0)
    Blue => (0, 0, 255)
    RGB(r, g, b) => (r, g, b)
  }
}

fn main {
  let red = Red
  let green = Green
  let blue = Blue
  let black = RGB(0, 0, 0)

  let (r, _, _) = rgb(red)
  let (_, g, _) = rgb(green)
  let (_, _, b) = rgb(blue)
  let (r1, g1, b1) = rgb(black)

  println(r)
  println(g)
  println(b)
  println(r1)
  println(g1)
  println(b1)
}
