# 第5章：堆上的变量

在前面的章节中，我们主要使用alloca指令在栈上分配内存。栈内存有一个重要的特点：它的生命周期与函数调用密切相关，当函数返回时，栈上分配的内存会自动释放。然而，在许多实际应用中，我们需要分配生命周期更长的内存，这些内存需要在函数调用结束后仍然存在，甚至在不同函数之间共享。这就需要使用堆内存。

本章将介绍堆内存的概念、使用场景，以及如何在llvm.mbt中进行堆内存的分配和管理。

## 栈与堆：两种内存管理方式

在深入堆内存操作之前，让我们先理解栈和堆这两种不同的内存管理方式：

### 栈内存（Stack Memory）

栈内存具有以下特点：

- **自动管理**：内存的分配和释放由系统自动处理
- **生命周期短**：与函数调用周期绑定，函数返回时自动释放
- **访问速度快**：由于局部性好，访问速度通常较快
- **大小有限**：栈空间通常有限制，不适合大量数据

在LLVM中，我们使用`createAlloca`指令在栈上分配内存：

```moonbit skip
///|
let local_var = builder.createAlloca(i32_ty, name="local")
```

### 堆内存（Heap Memory）

堆内存具有以下特点：

- **手动管理**：需要程序员显式分配和释放
- **生命周期长**：可以跨越函数调用边界
- **访问速度较慢**：由于内存布局的不确定性，访问速度相对较慢
- **大小灵活**：可以分配大量内存，受系统内存限制

在LLVM中，我们使用`createMalloc`指令在堆上分配内存。

## 为什么需要堆内存？

考虑以下场景：

1. **跨函数数据共享**：多个函数需要访问同一块数据
2. **动态数据结构**：链表、树等需要动态增长的数据结构
3. **大量数据**：超出栈空间限制的大型数组或对象
4. **生命周期管理**：数据的生命周期与特定的业务逻辑相关，而非函数调用

让我们通过一个实际例子来理解堆内存的使用。

## 堆内存分配实例

下面的例子展示了如何在堆上分配整数变量，并在函数间传递指针：

```c
void print_int(int);

void add(int* a, int* b, int* c) {
  *c = *a + *b;
  return;
}

int main() {
  int *a = (int*)malloc(sizeof(int));
  int *b = (int*)malloc(sizeof(int));
  int *c = (int*)malloc(sizeof(int));
  
  *a = 10;
  *b = 20;
  
  add(a, b, c);
  print_int(*c);
  return 0;
}
```

让我们用llvm.mbt来实现这个程序：

```moonbit
///|
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("heap_memory_demo")
  let builder = ctx.createBuilder()
  let i32_ty = ctx.getInt32Ty()
  let ptr_ty = ctx.getPtrTy()
  let void_ty = ctx.getVoidTy()

  // 声明外部函数 print_int
  let print_int_ty = ctx.getFunctionType(void_ty, [i32_ty])
  let print_int_func = mod.addFunction(print_int_ty, "print_int")

  // 定义 add 函数：void add(int* a, int* b, int* c)
  let add_ty = ctx.getFunctionType(void_ty, [ptr_ty, ptr_ty, ptr_ty])
  let add_func = mod.addFunction(add_ty, "add")
  let add_bb = add_func.addBasicBlock(name="entry")
  let ptr_a = add_func.getArg(0).unwrap()
  let ptr_b = add_func.getArg(1).unwrap()
  let ptr_c = add_func.getArg(2).unwrap()
  builder.setInsertPoint(add_bb)

  // 从指针加载值：*a 和 *b
  let val_a = builder.createLoad(i32_ty, ptr_a, name="val_a")
  let val_b = builder.createLoad(i32_ty, ptr_b, name="val_b")

  // 计算加法：*a + *b
  let sum = builder.createAdd(val_a, val_b, name="sum")

  // 存储结果到 *c
  let _ = builder.createStore(sum, ptr_c)
  let _ = builder.createRetVoid()

  // 定义 main 函数
  let main_ty = ctx.getFunctionType(i32_ty, [])
  let main_func = mod.addFunction(main_ty, "main")
  let main_bb = main_func.addBasicBlock(name="entry")
  builder.setInsertPoint(main_bb)

  // 在堆上分配三个整数
  let heap_a = builder.createMalloc(i32_ty, name="heap_a")
  let heap_b = builder.createMalloc(i32_ty, name="heap_b")
  let heap_c = builder.createMalloc(i32_ty, name="heap_c")

  // 初始化堆上的值
  let const_10 = ctx.getConstInt32(10)
  let const_20 = ctx.getConstInt32(20)
  let _ = builder.createStore(const_10, heap_a)
  let _ = builder.createStore(const_20, heap_b)

  // 调用 add 函数
  let _ = builder.createCall(add_func, [heap_a, heap_b, heap_c])

  // 加载结果并打印
  let result = builder.createLoad(i32_ty, heap_c, name="result")
  let _ = builder.createCall(print_int_func, [result])
  let _ = builder.createRet(ctx.getConstInt32(0))
  let expect =
    #|; ModuleID = 'heap_memory_demo'
    #|source_filename = "heap_memory_demo"
    #|target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
    #|
    #|declare void @print_int(i32)
    #|
    #|define void @add(ptr %0, ptr %1, ptr %2) {
    #|entry:
    #|  %val_a = load i32, ptr %0, align 4
    #|  %val_b = load i32, ptr %1, align 4
    #|  %sum = add i32 %val_a, %val_b
    #|  store i32 %sum, ptr %2, align 4
    #|  ret void
    #|}
    #|
    #|define i32 @main() {
    #|entry:
    #|  %heap_a = tail call ptr @malloc(i32 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i32))
    #|  %heap_b = tail call ptr @malloc(i32 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i32))
    #|  %heap_c = tail call ptr @malloc(i32 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i32))
    #|  store i32 10, ptr %heap_a, align 4
    #|  store i32 20, ptr %heap_b, align 4
    #|  call void @add(ptr %heap_a, ptr %heap_b, ptr %heap_c)
    #|  %result = load i32, ptr %heap_c, align 4
    #|  call void @print_int(i32 %result)
    #|  ret i32 0
    #|}
    #|
    #|declare noalias ptr @malloc(i32)
    #|
  inspect(mod, content=expect)
}
```

## createMalloc指令详解

`createMalloc`是llvm.mbt提供的堆内存分配指令，它相比直接调用malloc函数有以下优势：

### 1. 类型感知

`createMalloc`会根据指定的类型自动计算所需的内存大小：

```moonbit skip
///|
let ptr = builder.createMalloc(i32_ty, name="int_ptr")
```

这相当于C语言中的：
```c
int* ptr = (int*)malloc(sizeof(int));
```

### 2. 平台无关

`createMalloc`生成的代码是平台无关的，LLVM会根据目标平台自动处理内存分配的细节。

### 3. 优化友好

LLVM优化器能够更好地理解和优化`createMalloc`生成的代码，包括可能的内存分配优化。

## 指针操作的要点

在处理堆内存时，指针操作是核心技能：

### 1. 加载指针指向的值

使用`createLoad`从指针加载值：

```moonbit skip
let value = builder.createLoad(type, pointer, name="loaded_value")
```

### 2. 存储值到指针指向的内存

使用`createStore`将值存储到指针指向的内存：

```moonbit skip
let _ = builder.createStore(value, pointer)
```

### 3. 函数间指针传递

指针可以作为函数参数传递，实现跨函数的数据共享：

```moonbit skip
let _ = builder.createCall(function, [pointer1, pointer2, pointer3])
```

## 外部函数链接示例

为了运行上面的程序，我们需要提供`print_int`函数的实现。创建一个C文件：

```c
#include <stdio.h>

void print_int(int n) {
    printf("%d\n", n);
}
```

然后按照以下步骤编译和链接：

```bash
# 生成LLVM IR
moon run main --target native > heap_demo.ll

# 编译为目标文件
llc -filetype=obj heap_demo.ll -o heap_demo.o

# 编译C辅助函数
gcc -c print_helper.c -o print_helper.o

# 链接生成可执行文件（注意链接C标准库）
gcc heap_demo.o print_helper.o -o heap_demo

# 运行程序
./heap_demo  # 输出: 30
```

注意：由于使用了malloc，链接时会自动链接C标准库。

## 内存管理的责任

使用堆内存时，我们需要承担内存管理的责任：

### 1. 内存泄漏

在实际应用中，每次调用`createMalloc`分配的内存都应该对应一次`createFree`调用来释放内存，否则会导致内存泄漏。

### 2. 悬空指针

释放内存后，原来的指针就变成了悬空指针，继续使用会导致未定义行为。

### 3. 双重释放

同一块内存不能释放两次，这会导致程序崩溃或数据损坏。

虽然在这个简单示例中我们没有显式释放内存（程序结束时操作系统会回收所有内存），但在实际的长期运行程序中，适当的内存管理是必需的。

## 堆内存的使用场景

堆内存特别适用于以下场景：

### 1. 动态数据结构

链表、树、图等数据结构通常需要在运行时动态分配节点：

```moonbit skip
// 分配链表节点

///|
let node = builder.createMalloc(node_ty, name="list_node")
```

### 2. 可变大小的数组

当数组大小在编译时未知时，需要使用堆分配：

```moonbit skip
// 分配n个整数的数组

///|
let array = builder.createMalloc(array_ty, name="dynamic_array")
```

### 3. 对象间的共享数据

多个对象需要共享同一份数据时，堆内存提供了理想的解决方案。

## 最佳实践

在使用堆内存时，建议遵循以下最佳实践：

### 1. 配对分配和释放

每次malloc都应该有对应的free（虽然在示例中省略了）。

### 2. 初始化分配的内存

分配后立即初始化内存，避免使用未初始化的数据。

### 3. 检查分配是否成功

在实际应用中，应该检查malloc是否返回了有效指针。

### 4. 避免内存碎片

合理规划内存分配策略，减少内存碎片。

## 结语

堆内存管理是系统编程的重要技能。通过本章的学习，您已经掌握了：

- 栈内存和堆内存的区别和适用场景
- 如何使用`createMalloc`进行堆内存分配
- 指针操作的基本技巧
- 跨函数的数据共享机制

堆内存的灵活性为复杂数据结构的实现提供了基础，但同时也要求开发者承担更多的内存管理责任。在下一章中，我们将探讨数组和结构体等复合数据类型，这些都建立在本章所学的内存管理概念之上。

掌握堆内存操作是从简单程序向系统级编程过渡的重要一步，它为实现复杂的数据结构和算法奠定了基础。
