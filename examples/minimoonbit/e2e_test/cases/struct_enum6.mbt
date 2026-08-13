extern "C" fn print_int(x: Int) -> Unit = "print_int";
extern "C" fn print_endline() -> Unit = "print_endline";

enum Node {
  Nil;
  Cons(Int, Node);
}

struct List {
  head: Node;
  push: (List, Int) -> List;
  each: (List, (Int) -> Unit) -> Unit;
  map: (List, (Int) -> Int) -> List;
  fold: (List, (Int, Int) -> Int, Int) -> Int;
}

fn new_list() -> List {
  fn push(self: List, val: Int) -> List {
    List::{
      head: Node::Cons(val, self.head),
      push: push,
      each: self.each,
      map: self.map,
      fold: self.fold
    }
  }

  fn each(self: List, f: (Int) -> Unit) -> Unit {
    let mut current = self.head;
    while true {
      match current {
        Node::Nil => { return (); };
        Node::Cons(value, next) => {
          f(value);
          current = next;
        };
      };
    }
    ()
  }

  fn fold(self: List, f: (Int, Int) -> Int, init: Int) -> Int {
    let mut acc = init;
    let mut current = self.head;
    while true {
      match current {
        Node::Nil => { return acc;};
        Node::Cons(value, next) => {
          acc = f(acc, value);
          current = next;
        }
      };
    }
    acc
  }

  fn map(self: List, f: (Int) -> Int) -> List {
    let mut new_head = Node::Nil;
    let mut current = self.head;
    fn loop_(){
      while true {
        match current {
          Node::Nil => { return current; };
          Node::Cons(value, next) => {
            new_head = Node::Cons(f(value), new_head);
            current = next;
          };
        };
      }
      current
    }
    current = loop_();
    List::{
      head: new_head,
      push: push,
      each: each,
      map: map,
      fold: fold
    }
  }


  List::{
    head: Node::Nil,
    push: push,
    each: each,
    map: map,
    fold: fold
  }
}

fn main {
  let list = new_list();
  let list = (list.push)(list, 1);
  let list = (list.push)(list, 2);
  let list = (list.push)(list, 3);
  let list = (list.push)(list, 4);
  let list = (list.push)(list, 5);

  fn double(x: Int) -> Int {
    x * 2
  }

  let doubled_list = (list.map)(list, double);

  fn sum(acc: Int, x: Int) -> Int {
    acc + x
  }

  let total = (doubled_list.fold)(doubled_list, sum, 0);
  
  (doubled_list.each)(doubled_list, print_int);
  
  print_int(total);
  print_endline();
}
