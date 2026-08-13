// 并查集（Union-Find）数据结构实现

struct UnionFind {
  parent: Array[Int];
  rank: Array[Int];
  size: Int;
}

fn make_union_find(n: Int) -> UnionFind {
  let parent = Array::make(n, 0);
  let rank = Array::make(n, 0);
  
  let mut i = 0;
  while i < n {
    parent[i] = i;
    rank[i] = 0;
    i = i + 1;
  }
  
  UnionFind::{ parent: parent, rank: rank, size: n }
}

fn find(uf: UnionFind, x: Int) -> Int {
  if uf.parent[x] != x {
    uf.parent[x] = find(uf, uf.parent[x]);
  };
  uf.parent[x]
}

fn union(uf: UnionFind, x: Int, y: Int) -> Bool {
  let root_x = find(uf, x);
  let root_y = find(uf, y);
  
  if root_x == root_y {
    false
  } else {
    if uf.rank[root_x] < uf.rank[root_y] {
      uf.parent[root_x] = root_y;
    } else if uf.rank[root_x] > uf.rank[root_y] {
      uf.parent[root_y] = root_x;
    } else {
      uf.parent[root_y] = root_x;
      uf.rank[root_x] = uf.rank[root_x] + 1;
    };
    true
  }
}

fn connected(uf: UnionFind, x: Int, y: Int) -> Bool {
  find(uf, x) == find(uf, y)
}

fn count_components(uf: UnionFind) -> Int {
  let mut count = 0;
  let mut i = 0;
  while i < uf.size {
    if find(uf, i) == i {
      count = count + 1;
    };
    i = i + 1;
  }
  count
}

fn test_basic_operations() -> Unit {
  let uf = make_union_find(5);
  
  println(count_components(uf));
  
  let r1 = union(uf, 0, 1);
  if r1 {
    println(1);
  } else {
    println(0);
  };
  
  println(count_components(uf));
  
  let r2 = union(uf, 2, 3);
  if r2 {
    println(1);
  } else {
    println(0);
  };
  
  println(count_components(uf));
  
  if connected(uf, 0, 1) {
    println(1);
  } else {
    println(0);
  }
  
  if connected(uf, 0, 2) {
    println(1);
  } else {
    println(0);
  }
}

fn test_chain_union() -> Unit {
  let uf = make_union_find(6);
  
  let _ = union(uf, 0, 1);
  let _ = union(uf, 1, 2);
  let _ = union(uf, 2, 3);
  
  if connected(uf, 0, 3) {
    println(1);
  } else {
    println(0);
  }
  
  if connected(uf, 0, 4) {
    println(1);
  } else {
    println(0);
  }
  
  println(count_components(uf));
}

fn test_duplicate_union() -> Unit {
  let uf = make_union_find(4);
  
  let r1 = union(uf, 0, 1);
  if r1 {
    println(1);
  } else {
    println(0);
  };
  
  let r2 = union(uf, 0, 1);
  if r2 {
    println(1);
  } else {
    println(0);
  };
  
  println(count_components(uf));
}

fn test_complete_union() -> Unit {
  let uf = make_union_find(5);
  
  let _ = union(uf, 0, 1);
  let _ = union(uf, 1, 2);
  let _ = union(uf, 2, 3);
  let _ = union(uf, 3, 4);
  
  println(count_components(uf));
  
  let mut i = 0;
  while i < 5 {
    let mut j = i + 1;
    while j < 5 {
      if connected(uf, i, j) {
        println(1);
      } else {
        println(0);
      };
      j = j + 1;
    }
    i = i + 1;
  }
}

fn test_find_optimization() -> Unit {
  let uf = make_union_find(10);
  
  let _ = union(uf, 0, 1);
  let _ = union(uf, 1, 2);
  let _ = union(uf, 2, 3);
  let _ = union(uf, 3, 4);
  
  let root = find(uf, 4);
  println(root);
  
  let root2 = find(uf, 0);
  println(root2);
  
  if connected(uf, 0, 4) {
    println(1);
  } else {
    println(0);
  }
}

fn test_multiple_components() -> Unit {
  let uf = make_union_find(9);
  
  let _ = union(uf, 0, 1);
  let _ = union(uf, 1, 2);
  
  let _ = union(uf, 3, 4);
  let _ = union(uf, 4, 5);
  
  let _ = union(uf, 6, 7);
  
  println(count_components(uf));
  
  if connected(uf, 0, 2) {
    println(1);
  } else {
    println(0);
  }
  
  if connected(uf, 3, 5) {
    println(1);
  } else {
    println(0);
  }
  
  if connected(uf, 0, 3) {
    println(1);
  } else {
    println(0);
  }
}

fn test_merge_components() -> Unit {
  let uf = make_union_find(6);
  
  let _ = union(uf, 0, 1);
  let _ = union(uf, 2, 3);
  let _ = union(uf, 4, 5);
  
  println(count_components(uf));
  
  let _ = union(uf, 1, 2);
  
  println(count_components(uf));
  
  let _ = union(uf, 3, 4);
  
  println(count_components(uf));
}

fn main {
  test_basic_operations();
  test_chain_union();
  test_duplicate_union();
  test_complete_union();
  test_find_optimization();
  test_multiple_components();
  test_merge_components();
}

