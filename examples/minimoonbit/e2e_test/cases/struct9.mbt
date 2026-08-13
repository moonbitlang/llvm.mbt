
extern "C" fn print_int(x : Int) = "print_int";

struct ValArray {
  vals: Array[Array[Int]];
  len: Array[Int];
  cap: Array[Int];
  push: (ValArray, Int) -> Unit;
  each: (ValArray, (Int) -> Unit) -> Unit;
  map: (ValArray, (Int) -> Int) -> ValArray;
  fold: (ValArray, (Int, Int) -> Int, Int) -> Int;
}

fn new_valarray(cap: Int) -> ValArray {
  fn push(self: ValArray, val: Int) -> Unit {
    if self.len[0] < self.cap[0] {
      self.vals[0][self.len[0]] = val;
      self.len[0] = self.len[0] + 1;
    } else {
      self.cap[0] = self.cap[0] * 2;
      let new_vals = Array::make(self.cap[0], 0);
      let mut i = 0;
      while i < self.len[0] {
        new_vals[i] = self.vals[0][i];
        i = i + 1;
      }
      new_vals[self.len[0]] = val;
      self.vals[0] = new_vals;
      self.len[0] = self.len[0] + 1;
    }
  }

  fn each(self: ValArray, f: (Int) -> Unit) -> Unit {
    let mut i = 0;
    while i < self.len[0] {
      f(self.vals[0][i]);
      i = i + 1;
    }
  }

  fn fold(self: ValArray, f: (Int, Int) -> Int, init: Int) -> Int {
    let mut acc = init;
    let mut i = 0;
    while i < self.len[0] {
      acc = f(acc, self.vals[0][i]);
      i = i + 1;
    }
    acc
  }

  fn map(self: ValArray, f: (Int) -> Int) -> ValArray {
    let new_vals = Array::make(self.len[0], 0);
    let mut i = 0;
    while i < self.len[0] {
      new_vals[i] = f(self.vals[0][i]);
      i = i + 1;
    }
    ValArray::{
      vals: Array::make(1, new_vals),
      len: Array::make(1, self.len[0]),
      cap: Array::make(1, self.cap[0]),
      push: push,
      each: each,
      map: map,
      fold: fold
    }
  }

  let vals = Array::make(1, Array::make(cap, 0));
  let len = Array::make(1, 0);
  let cap = Array::make(1, cap);
  ValArray::{
    vals: vals,
    len: len,
    cap: cap,
    push: push,
    each: each,
    map: map,
    fold: fold
  }
}

fn main {
  let vals = new_valarray(3);
  (vals.push)(vals, 1);
  (vals.push)(vals, 2);
  (vals.push)(vals, 3);
  (vals.push)(vals, 4);
  (vals.push)(vals, 5);

  fn double(x: Int) -> Int {
    x * 2
  }

  let doubled_vals = (vals.map)(vals, double);

  fn sum(acc: Int, x: Int) -> Int {
    acc + x
  }

  let total = (doubled_vals.fold)(doubled_vals, sum, 0);
  (doubled_vals.each)(doubled_vals, print_int);
  print_int(total)
}
