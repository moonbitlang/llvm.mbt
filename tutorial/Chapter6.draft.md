
（标题：第六章：数组）

分别介绍堆和栈上的数组，栈上的数组使用getArrayType之后，再使用createAlloca，堆上的数组使用createMalloc，索引使用GetElementPtr.

# 栈上的数组

硬编码（栈上的数组）：

```c
void fill_array(int*, int, int);
void print_array(int*, int);

int main() {
  int arr[5];
  fill_array(arr, 42, 5);
  print_array(arr, 5)
  return 0;
}
```

上面的是硬编码，生成llvm ir再编译成汇编，跟下面的函数进行链接：

```c
#include <stdio.h>

void fill_array(int* arr, int num, int len) {
  for (int i=0; i < len; ++i) {
    arr[i] = num;
  }
}

void print_array(int *arr, int len) {
  for (int i=0; i < len; ++i) {
    printf("%d ", arr[i]);
  }
  printf("\n");
}
```

# 堆上的数组

```c
int* make_array(int num, int len) {
  int* arr = (int*)malloc(sizeof(int) * len);
  return arr;
}

int main() {
  int* arr = make_array(0, 5);
  fill_array(arr, 42, 5);
  print_array(arr, 5)
  return 0;
}
```

上面的代码仍然是硬编码，然后再跟前面的fill_array和print_array的C代码进行链接。

## 自己实现fill_array

硬编码写一下`fill_array`，改成用while循环的

```c
void fill_array(int* arr, int num, int len) {
  int i = 0;
  while (i < len) {
    arr[i] = num;
    i = i + 1;
  }
  return ;
}
```

这里需要用到GEP指令。

用新的fill_array替代掉原来的C函数，再链接生成可执行文件试试。
