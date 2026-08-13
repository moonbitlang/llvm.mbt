// 结构体与枚举共存测试4：复杂嵌套
enum Node {
  Leaf(Int);
  Branch(Tree);
}

struct Tree {
  left: Node;
  right: Node;
}

fn sum_tree(n: Node) -> Int {
  match n {
    Leaf(v) => v;
    Branch(t) => sum_tree(t.left) + sum_tree(t.right);
  }
}

fn count_leaves(n: Node) -> Int {
  match n {
    Leaf(_) => 1;
    Branch(t) => count_leaves(t.left) + count_leaves(t.right);
  }
}

fn main {
  let t1 = Tree::{ left: Leaf(1), right: Leaf(2) };
  let t2 = Tree::{ left: Leaf(3), right: Leaf(4) };
  let t3 = Tree::{ left: Branch(t1), right: Branch(t2) };
  
  let n = Branch(t3);
  
  println(sum_tree(n));
  println(count_leaves(n));
}

