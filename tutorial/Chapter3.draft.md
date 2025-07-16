
（标题：第三章：分支与循环的构建）

- 手动硬编码一些简单的llvm程序，利用llvm.mbt编写llvm程序，只需要展示llvm ir，不需要再链接了。

- 只展示基本操作，加减乘除，取余，位运算等等。


## 分支

硬编码：

```c
int max(int a, int b) {
  if (a > b) {
    return a;
  } else {
    return b;
  }
}
```

需要介绍`createICmp`, `createBr`, `createCondBr`

指出`createICmp`是一个系列函数，有`createICmpEQ`等等，列举即可。

硬编码：

```c
double max(double a, double b) {
  if (a > b) {
    return a;
  } else {
    return b;
  }
}
```

需要介绍`createFCmp`， 浮点数的比较有多种模式，列举即可。

## Switch

硬编码llvm：

C语言的switch在llvm里面有对应的IR:

```c
int fake_square(int n) {
  int res;
  switch (n) {
    case 1: res = 1; break;
    case 2: res = 4; break
    case 3: res = 9; break;
    case 4: res = 16; break;
    default: res = 0; break;
  }
  return res;
}
```

需要注意switch指令的cond只能是整数类型。

## 循环

硬编码：

```c
int simple_log2(int n) {
  int exp = 0;
  int n2 = 1;
  while n2 < n {
    exp = exp + 1;
    n2 = n2 * 2;
  }
  return n2;
} 
```

while的构建需要构造三个块，cond块，body块，和merge块。


