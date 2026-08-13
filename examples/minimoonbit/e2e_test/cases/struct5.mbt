// 结构体测试5：递归结构体（使用元组模拟）
struct TreeNode {
  value: Int;
  left: Int;
  right: Int;
}

fn sum_tree(nodes: Array[TreeNode], index: Int) -> Int {
  if index < 0 {
    0
  } else {
    let node = nodes[index];
    node.value + sum_tree(nodes, node.left) + sum_tree(nodes, node.right)
  }
}

fn count_nodes(nodes: Array[TreeNode], index: Int) -> Int {
  if index < 0 {
    0
  } else {
    let node = nodes[index];
    1 + count_nodes(nodes, node.left) + count_nodes(nodes, node.right)
  }
}

fn main {
  let n0 = TreeNode::{ value: 1, left: 0 - 1, right: 0 - 1 };
  let n1 = TreeNode::{ value: 2, left: 0 - 1, right: 0 - 1 };
  let n2 = TreeNode::{ value: 3, left: 0, right: 1 };
  let n3 = TreeNode::{ value: 4, left: 0 - 1, right: 0 - 1 };
  let n4 = TreeNode::{ value: 5, left: 2, right: 3 };
  
  let nodes = [n0, n1, n2, n3, n4];
  
  println(sum_tree(nodes, 4));
  println(count_nodes(nodes, 4));
}

