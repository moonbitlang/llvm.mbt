// 线段树（Segment Tree）实现 - 支持区间求和和单点更新

struct SegmentTree {
  tree: Array[Int];
  size: Int;
}

fn build_tree(arr: Array[Int], tree: Array[Int], node: Int, start: Int, end: Int) -> Unit {
  if start == end {
    tree[node] = arr[start];
  } else {
    let mid = start + (end - start) / 2;
    let left_child = 2 * node + 1;
    let right_child = 2 * node + 2;
    
    build_tree(arr, tree, left_child, start, mid);
    build_tree(arr, tree, right_child, mid + 1, end);
    
    tree[node] = tree[left_child] + tree[right_child];
  }
}

fn make_segment_tree(arr: Array[Int], n: Int) -> SegmentTree {
  let tree_size = 4 * n;
  let tree = Array::make(tree_size, 0);
  
  if n > 0 {
    build_tree(arr, tree, 0, 0, n - 1);
  };
  
  SegmentTree::{ tree: tree, size: n }
}

fn query_helper(tree: Array[Int], node: Int, start: Int, end: Int, left: Int, right: Int) -> Int {
  if right < start || left > end {
    0
  } else if left <= start && end <= right {
    tree[node]
  } else {
    let mid = start + (end - start) / 2;
    let left_child = 2 * node + 1;
    let right_child = 2 * node + 2;
    
    let left_sum = query_helper(tree, left_child, start, mid, left, right);
    let right_sum = query_helper(tree, right_child, mid + 1, end, left, right);
    
    left_sum + right_sum
  }
}

fn query_range(st: SegmentTree, left: Int, right: Int) -> Int {
  if st.size == 0 {
    0
  } else {
    query_helper(st.tree, 0, 0, st.size - 1, left, right)
  }
}

fn update_helper(tree: Array[Int], node: Int, start: Int, end: Int, idx: Int, value: Int) -> Unit {
  if start == end {
    tree[node] = value;
  } else {
    let mid = start + (end - start) / 2;
    let left_child = 2 * node + 1;
    let right_child = 2 * node + 2;
    
    if idx <= mid {
      update_helper(tree, left_child, start, mid, idx, value);
    } else {
      update_helper(tree, right_child, mid + 1, end, idx, value);
    };
    
    tree[node] = tree[left_child] + tree[right_child];
  }
}

fn update_point(st: SegmentTree, idx: Int, value: Int) -> Unit {
  if st.size > 0 {
    update_helper(st.tree, 0, 0, st.size - 1, idx, value);
  }
}

fn test_basic_query() -> Unit {
  let arr = [1, 3, 5, 7, 9, 11];
  let st = make_segment_tree(arr, 6);
  
  println(query_range(st, 0, 5));
  println(query_range(st, 0, 2));
  println(query_range(st, 3, 5));
  println(query_range(st, 1, 4));
}

fn test_single_element_query() -> Unit {
  let arr = [1, 3, 5, 7, 9];
  let st = make_segment_tree(arr, 5);
  
  println(query_range(st, 0, 0));
  println(query_range(st, 2, 2));
  println(query_range(st, 4, 4));
}

fn test_update() -> Unit {
  let arr = [1, 2, 3, 4, 5];
  let st = make_segment_tree(arr, 5);
  
  println(query_range(st, 0, 4));
  
  update_point(st, 2, 10);
  
  println(query_range(st, 0, 4));
  println(query_range(st, 2, 2));
}

fn test_multiple_updates() -> Unit {
  let arr = [1, 1, 1, 1, 1];
  let st = make_segment_tree(arr, 5);
  
  println(query_range(st, 0, 4));
  
  update_point(st, 0, 5);
  update_point(st, 2, 5);
  update_point(st, 4, 5);
  
  println(query_range(st, 0, 4));
  println(query_range(st, 0, 2));
  println(query_range(st, 2, 4));
}

fn test_range_queries() -> Unit {
  let arr = [2, 4, 6, 8, 10, 12, 14, 16];
  let st = make_segment_tree(arr, 8);
  
  println(query_range(st, 0, 3));
  println(query_range(st, 4, 7));
  println(query_range(st, 2, 5));
  println(query_range(st, 1, 6));
}

fn test_single_element_tree() -> Unit {
  let arr = [42];
  let st = make_segment_tree(arr, 1);
  
  println(query_range(st, 0, 0));
  
  update_point(st, 0, 100);
  
  println(query_range(st, 0, 0));
}

fn test_two_element_tree() -> Unit {
  let arr = [3, 7];
  let st = make_segment_tree(arr, 2);
  
  println(query_range(st, 0, 1));
  println(query_range(st, 0, 0));
  println(query_range(st, 1, 1));
  
  update_point(st, 0, 5);
  
  println(query_range(st, 0, 1));
}

fn test_large_tree() -> Unit {
  let arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  let st = make_segment_tree(arr, 10);
  
  println(query_range(st, 0, 9));
  println(query_range(st, 0, 4));
  println(query_range(st, 5, 9));
  
  update_point(st, 5, 0);
  
  println(query_range(st, 0, 9));
  println(query_range(st, 5, 9));
}

fn test_alternating_ops() -> Unit {
  let arr = [10, 20, 30, 40, 50];
  let st = make_segment_tree(arr, 5);
  
  println(query_range(st, 0, 4));
  update_point(st, 1, 25);
  println(query_range(st, 0, 4));
  update_point(st, 3, 35);
  println(query_range(st, 0, 4));
  println(query_range(st, 1, 3));
}

fn test_zero_values() -> Unit {
  let arr = [0, 0, 0, 0, 0];
  let st = make_segment_tree(arr, 5);
  
  println(query_range(st, 0, 4));
  
  update_point(st, 2, 10);
  
  println(query_range(st, 0, 4));
  println(query_range(st, 0, 2));
}

fn main {
  test_basic_query();
  test_single_element_query();
  test_update();
  test_multiple_updates();
  test_range_queries();
  test_single_element_tree();
  test_two_element_tree();
  test_large_tree();
  test_alternating_ops();
  test_zero_values();
}

