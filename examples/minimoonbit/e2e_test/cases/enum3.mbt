// ADT测试3：递归枚举（链表）
enum List {
  Nil;
  Cons(Int, List);
}

fn list_sum(lst: List) -> Int {
  match lst {
    Nil => 0;
    Cons(head, tail) => head + list_sum(tail);
  }
}

fn list_length(lst: List) -> Int {
  match lst {
    Nil => 0;
    Cons(_, tail) => 1 + list_length(tail);
  }
}

fn list_product(lst: List) -> Int {
  match lst {
    Nil => 1;
    Cons(head, tail) => head * list_product(tail);
  }
}

fn main {
  let lst = Cons(1, Cons(2, Cons(3, Cons(4, Cons(5, Nil)))));
  
  println(list_sum(lst));
  println(list_length(lst));
  println(list_product(lst));
}

