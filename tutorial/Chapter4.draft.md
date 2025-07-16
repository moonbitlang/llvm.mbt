
（标题：第四章：函数调用）

llvm 硬编码：

```c

int print_int(int) ;

int add(int a, int b) {
  return a + b;
}

int main() {
  int a = 42;
  int b = 33;
  int res = add(a, b);
  print_int(res);
  return 0;
}
```

以上是llvm硬编码的，但是注意我们没有给print_int的实现。

上面的代码弄出llvm IR之后，用llc编译成汇编，再跟下面的c函数进行链接：

```c
#include <stdio.h>

int print_int(int n) {
  printf("%d\n", n)
}
```


要用到的函数：`buildCall`, `addFunction`
