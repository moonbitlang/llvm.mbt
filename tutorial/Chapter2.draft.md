
（标题：第二章：变量和指针）

- 手动硬编码一些简单的llvm程序，利用llvm.mbt编写llvm程序，只需要展示llvm ir，不需要再链接了。

- 指出llvm是ssa形式，值不会改变，但程序语言有变量

解决方法：使用alloca指令开辟内存，然后store进值，用到变量时再load出来。

硬编码：

```c
int square_sum(int a, int b) {
  int a_square = a * a;
  int b_square = b * b;
  int sum = a_square + b_square;
  return sum;
}
```

（三次createAlloca)

指出createAlloca得到的值的类型是指针类型。
