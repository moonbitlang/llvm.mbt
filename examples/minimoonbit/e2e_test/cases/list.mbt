enum List {
  Nil;
  Cons(Int, List);
}

enum OptionInt {
  None;
  Some(Int);
}

fn convert_optionint_to_int(opt: OptionInt) -> Int {
  match opt {
    None => 0;
    Some(value) => value;
  }
}

fn new_list() -> List {
  Nil
}

fn push(list: List, value: Int) -> List {
  match list {
    Nil => Cons(value, Nil);
    Cons(head, tail) => Cons(head, push(tail, value));
  }
}

fn append(list1: List, list2: List) -> List {
  match list1 {
    Nil => list2;
    Cons(head, tail) => Cons(head, append(tail, list2));
  }
}

fn max_element(list: List) -> OptionInt {
  match list {
    Nil => None;
    Cons(head, tail) => {
      match max_element(tail) {
        None => { Some(head) };
        Some(max_tail) => {
          if head > max_tail {
            Some(head)
          } else {
            Some(max_tail)
          }
        };
      }
    }
  }
}

fn min_element(list: List) -> OptionInt {
  match list {
    Nil => None;
    Cons(head, tail) => {
      match min_element(tail) {
        None => { Some(head) };
        Some(min_tail) => {
          if head < min_tail {
            Some(head)
          } else {
            Some(min_tail)
          }
        };
      }
    }
  }
}

fn first(list: List) -> OptionInt {
  match list {
    Nil => None;
    Cons(head, _) => Some(head);
  }
}

fn last(list: List) -> OptionInt {
  match list {
    Nil => None;
    Cons(head, Nil) => Some(head);
    Cons(_, tail) => last(tail);
  }
}

fn reverse(list: List) -> List {
  fn reverse_helper(list: List, acc: List) -> List {
    match list {
      Nil => acc;
      Cons(head, tail) => reverse_helper(tail, Cons(head, acc));
    }
  }
  reverse_helper(list, Nil)
}

fn length(list: List) -> Int {
  match list {
    Nil => 0;
    Cons(_, tail) => 1 + length(tail);
  }
}

fn is_empty(list: List) -> Bool {
  match list {
    Nil => true;
    _ => false;
  }
}

fn contains(list: List, value: Int) -> Bool {
  match list {
    Nil => false;
    Cons(head, tail) => {
      if head == value {
        true
      } else {
        contains(tail, value)
      }
    }
  }
}

fn index_of(list: List, value: Int) -> OptionInt {
  fn index_helper(list: List, value: Int, index: Int) -> OptionInt {
    match list {
      Nil => None;
      Cons(head, tail) => {
        if head == value {
          Some(index)
        } else {
          index_helper(tail, value, index + 1)
        }
      }
    }
  }
  index_helper(list, value, 0)
}

fn remove(list: List, value: Int) -> List {
  match list {
    Nil => Nil;
    Cons(head, tail) => {
      if head == value {
        tail
      } else {
        Cons(head, remove(tail, value))
      }
    }
  }
}

fn bool_to_int(b: Bool) -> Int {
  match b {
    true => 1;
    false => 0;
  }
}

fn main {
  let mut list = new_list();
  let mut list2 = new_list();
  let r1 = bool_to_int(is_empty(list));
  list = push(list, 10);
  list = push(list, 20);
  list = push(list, 30);
  list2 = push(list2, 40);
  list2 = push(list2, 50);
  list = append(list, list2);
  let r2 = bool_to_int(is_empty(list));
  let r3 = convert_optionint_to_int(first(list));
  let r4 = convert_optionint_to_int(last(list));
  let r5 = convert_optionint_to_int(max_element(list));
  let r6 = convert_optionint_to_int(min_element(list));
  let r7 = length(list);
  let r8 = bool_to_int(contains(list, 30));
  let r9 = bool_to_int(contains(list, 7));
  let r10 = convert_optionint_to_int(index_of(list, 20));
  list = reverse(list);
  let r11 = convert_optionint_to_int(index_of(list, 20));
  list = remove(list, 20);
  let r12 = bool_to_int(contains(list, 20));

  println(r1);
  println(r2);
  println(r3);
  println(r4);
  println(r5);
  println(r6);
  println(r7);
  println(r8);
  println(r9);
  println(r10);
  println(r11);
  println(r12);
}
