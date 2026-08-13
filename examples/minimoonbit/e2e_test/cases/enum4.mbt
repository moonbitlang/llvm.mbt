// ADT测试4：递归枚举（二叉树）
enum Tree {
  Leaf;
  Node(Int, Tree, Tree);
}

fn tree_sum(t: Tree) -> Int {
  match t {
    Leaf => 0;
    Node(val, left, right) => val + tree_sum(left) + tree_sum(right);
  }
}

fn tree_height(t: Tree) -> Int {
  match t {
    Leaf => 0;
    Node(_, left, right) => {
      let hl = tree_height(left);
      let hr = tree_height(right);
      if hl > hr {
        1 + hl
      } else {
        1 + hr
      }
    };
  }
}

fn tree_count(t: Tree) -> Int {
  match t {
    Leaf => 0;
    Node(_, left, right) => 1 + tree_count(left) + tree_count(right);
  }
}

fn main {
  let t = Node(1,
    Node(2,
      Node(4, Leaf, Leaf),
      Node(5, Leaf, Leaf)
    ),
    Node(3,
      Node(6, Leaf, Leaf),
      Leaf
    )
  );
  
  println(tree_sum(t));
  println(tree_height(t));
  println(tree_count(t));
}

