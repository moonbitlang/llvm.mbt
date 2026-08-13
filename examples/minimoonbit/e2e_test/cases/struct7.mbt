extern "C" fn print_int(x : Int) = "print_int";

struct Vector {
  data: Array[Int];
  size: Int;
}

fn vector_add(a: Vector, b: Vector) -> Vector {
  let new_data = Array::make(a.size, 0);
  let size = a.size;
  let mut idx = 0;
  while idx < a.size {
    new_data[idx] = a.data[idx] + b.data[idx];
    idx = idx + 1;
  }
  Vector::{ data: new_data, size: size }
}

fn main {
  let v1 = Vector::{ data: Array::make(3, 0), size: 3 };
  v1.data[0] = 1;
  v1.data[1] = 2;
  v1.data[2] = 3;

  let v2 = Vector::{ data: Array::make(3, 0), size: 3 };
  v2.data[0] = 4;
  v2.data[1] = 5;
  v2.data[2] = 6;

  let v3 = vector_add(v1, v2);
  
  print_int(v3.data[0]);
  print_int(v3.data[1]);
  print_int(v3.data[2]);
}
