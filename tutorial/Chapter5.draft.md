
（标题：第五章：堆上的变量）

简单介绍一下什么是栈，什么是堆，为了能够让变量可以跨函数存在，我们通常会把变量放在堆上。

通过call malloc函数是可以的，但是可能会遇到平台问题，在llvm里面，我们可以使用`createMalloc`

硬编码llvm:

```c
void print_int(int);

void add(int* a, int*b, int*c) {
  *c =  *a + *b;
  return;
}

int main () {
  int *a = (int*)malloc(sizeof(int));
  int *b = (int*)malloc(sizeof(int));
  int *c = (int*)malloc(sizeof(int));
  add(a, b, c);
  print_int(*c);
  return 0;
}
```

编译出llvm ir之后，用llc生成汇编，再与下面的C函数链接，执行：

```c
#include <stdio.h>

void print_int(int n) {
  printf("%d\n", n);
}
```
