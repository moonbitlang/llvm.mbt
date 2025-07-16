（标题：第七章：结构体）

通过`getStructType`构造结构体类型

通过`createAlloca`申请栈上的内存，`createMalloc`申请堆上的内存

通过`createGEP`定位到子元素的指针

通过`createStore`存放元素，`createLoad`加载元素。

llvm硬编码：

```c
typedef struct {
  int p;
  int q;
} Rational;

Rational* new_rational(int p, int q) {
  Rational* r = (Rational*)malloc(sizeof(Rational));
  r->p = p;
  r->q = q;
}

double rational_to_double(Rational* r) {
  double p = (double)r->p;
  double q = (double)r->q;
  double res = p / q;
  return res;
}

void print_double(double);

int main() {
  Rational r1 = {2, 1};
  double d1 = rational_to_double(&r1);
  print_double(d1);

  Rational* r2 = new_rational(1, 2);
  double d2 = rational_to_double(r2);
  print_double(d2);
  return 0;
}
```

上述代码经过llvm硬编码，llc汇编，与下面的C进行链接：

```c
#include <stdio.h>

void print_double(double d) {
  printf("%ld\n", d);
} 
```
