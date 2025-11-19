# 第6章：数组

数组是编程中最基础也是最重要的数据结构之一。它允许我们在内存中连续存储多个相同类型的元素，并通过索引快速访问任意元素。在LLVM中，数组的处理涉及类型定义、内存分配和索引访问等多个层面。

本章将详细介绍如何在llvm.mbt中处理数组，包括栈上数组和堆上数组的分配，以及如何使用GEP（GetElementPtr）指令进行数组元素的访问。

## 数组的两种分配方式

与单个变量类似，数组也可以分配在栈上或堆上，每种方式都有其特定的使用场景：

### 栈上数组
- **固定大小**：数组大小在编译时确定
- **自动管理**：随函数调用自动分配和释放
- **访问速度快**：由于内存局部性好，访问速度通常较快
- **大小限制**：受栈空间限制，不适合大型数组

### 堆上数组
- **动态大小**：数组大小可以在运行时确定
- **手动管理**：需要显式分配和释放内存
- **灵活性高**：可以分配任意大小的数组
- **生命周期长**：可以跨越函数调用边界

## 栈上数组的实现

让我们从一个简单的栈上数组例子开始：

```c
void fill_array(int*, int, int);
void print_array(int*, int);

int main() {
  int arr[5];
  fill_array(arr, 42, 5);
  print_array(arr, 5);
  return 0;
}
```

在llvm.mbt中实现这个程序：

```moonbit
///|
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("stack_array_demo")
  let builder = ctx.createBuilder()
  let i32_ty = ctx.getInt32Ty()
  let ptr_ty = ctx.getPtrTy()
  let void_ty = ctx.getVoidTy()

  // 声明外部函数
  let fill_array_ty = ctx.getFunctionType(void_ty, [ptr_ty, i32_ty, i32_ty])
  let fill_array_func = mod.addFunction(fill_array_ty, "fill_array")
  let print_array_ty = ctx.getFunctionType(void_ty, [ptr_ty, i32_ty])
  let print_array_func = mod.addFunction(print_array_ty, "print_array")

  // 定义main函数
  let main_ty = ctx.getFunctionType(i32_ty, [])
  let main_func = mod.addFunction(main_ty, "main")
  let main_bb = main_func.addBasicBlock(name="entry")
  builder.setInsertPoint(main_bb)

  // 在栈上分配数组：int arr[5]
  let array_ty = ctx.getArrayType(i32_ty, 5)
  let arr = builder.createAlloca(array_ty, name="arr")

  // 创建常量
  let const_42 = ctx.getConstInt32(42)
  let const_5 = ctx.getConstInt32(5)
  let const_0 = ctx.getConstInt32(0)

  // 调用 fill_array(arr, 42, 5)
  let _ = builder.createCall(fill_array_func, [arr, const_42, const_5])

  // 调用 print_array(arr, 5)
  let _ = builder.createCall(print_array_func, [arr, const_5])
  let _ = builder.createRet(const_0)
  let expect =
    #|; ModuleID = 'stack_array_demo'
    #|source_filename = "stack_array_demo"
    #|target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
    #|
    #|declare void @fill_array(ptr, i32, i32)
    #|
    #|declare void @print_array(ptr, i32)
    #|
    #|define i32 @main() {
    #|entry:
    #|  %arr = alloca [5 x i32], align 4
    #|  call void @fill_array(ptr %arr, i32 42, i32 5)
    #|  call void @print_array(ptr %arr, i32 5)
    #|  ret i32 0
    #|}
    #|
  inspect(mod, content=expect)
}
```

### 栈上数组的关键要点

#### 1. 数组类型定义

使用`getArrayType`创建数组类型：

```moonbit skip
let array_ty = ctx.getArrayType(element_type, element_count)
```

这创建了一个包含`element_count`个`element_type`类型元素的数组类型。

#### 2. 数组分配

栈上数组使用`createAlloca`分配：

```moonbit skip
let arr = builder.createAlloca(array_ty, name="arr")
```

这在栈上分配了整个数组的空间，返回指向数组首元素的指针。

#### 3. 数组退化为指针

在C语言中，数组名在大多数上下文中会"退化"为指向首元素的指针。LLVM遵循相同的语义，因此我们可以直接将数组指针传递给接受指针参数的函数。

## 堆上数组的实现

对于需要动态分配大小或跨函数共享的数组，我们使用堆分配：

```c
int* make_array(int len) {
  int* arr = (int*)malloc(sizeof(int) * len);
  return arr;
}

int main() {
  int* arr = make_array(0, 5);
  fill_array(arr, 42, 5);
  print_array(arr, 5);
  return 0;
}
```

在llvm.mbt中实现：

```moonbit skip
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("heap_array_demo")
  let builder = ctx.createBuilder()

  let i32_ty = ctx.getInt32Ty()
  let ptr_ty = ctx.getPtrTy()
  let void_ty = ctx.getVoidTy()

  // 声明外部函数
  let fill_array_ty = ctx.getFunctionType(void_ty, [ptr_ty, i32_ty, i32_ty])
  let fill_array_func = mod.addFunction(fill_array_ty, "fill_array")

  let print_array_ty = ctx.getFunctionType(void_ty, [ptr_ty, i32_ty])
  let print_array_func = mod.addFunction(print_array_ty, "print_array")

  // 定义 make_array 函数
  let make_array_ty = ctx.getFunctionType(ptr_ty, [i32_ty])
  let make_array_func = mod.addFunction(make_array_ty, "make_array")
  let make_bb = make_array_func.addBasicBlock(name="entry")
  let make_len = make_array_func.getArg(0).unwrap()

  builder.setInsertPoint(make_bb)

  // 分配堆上数组：int* arr = malloc(sizeof(int) * len)
  // 这里我们需要计算数组的总大小
  let i32_size = ctx.getConstInt32(4)  // sizeof(int) = 4 bytes
  let total_size = builder.createMul(make_len, i32_size, name="total_size")
  
  // 使用原始malloc调用，因为我们需要分配可变大小的内存
  let malloc_ty = ctx.getFunctionType(ptr_ty, [i32_ty])
  let malloc_func = mod.addFunction(malloc_ty, "malloc")
  let arr = builder.createCall(malloc_func, [total_size], name="arr")

  let _ = builder.createRet(arr)

  // 定义 main 函数
  let main_ty = ctx.getFunctionType(i32_ty, [])
  let main_func = mod.addFunction(main_ty, "main")
  let main_bb = main_func.addBasicBlock(name="entry")

  builder.setInsertPoint(main_bb)

  let const_0 = ctx.getConstInt32(0)
  let const_5 = ctx.getConstInt32(5)
  let const_42 = ctx.getConstInt32(42)

  // 调用 make_array(0, 5)
  let heap_arr = builder.createCall(make_array_func, [const_5], name="heap_arr")

  // 调用 fill_array(arr, 42, 5)
  let _ = builder.createCall(fill_array_func, [heap_arr, const_42, const_5])

  // 调用 print_array(arr, 5)
  let _ = builder.createCall(print_array_func, [heap_arr, const_5])

  let _ = builder.createRet(const_0)

  let expect = 
    #|declare void @fill_array(ptr, i32, i32)
    #|
    #|declare void @print_array(ptr, i32)
    #|
    #|declare ptr @malloc(i32)
    #|
    #|define ptr @make_array(i32 %0) {
    #|entry:
    #|  %total_size = mul i32 %0, 4
    #|  %arr = call ptr @malloc(i32 %total_size)
    #|  ret ptr %arr
    #|}
    #|
    #|define i32 @main() {
    #|entry:
    #|  %heap_arr = call ptr @make_array(i32 0, i32 5)
    #|  call void @fill_array(ptr %heap_arr, i32 42, i32 5)
    #|  call void @print_array(ptr %heap_arr, i32 5)
    #|  ret i32 0
    #|}

  inspect(mod, content=expect)
}
```

## GEP指令：数组索引的核心

GEP（GetElementPtr）指令是LLVM中进行地址计算的核心指令。它不执行内存访问，而是计算指定元素的地址。现在让我们自己实现`fill_array`函数来深入理解GEP的使用：

```c
void fill_array(int* arr, int num, int len) {
  int i = 0;
  while (i < len) {
    arr[i] = num;
    i = i + 1;
  }
  return;
}
```

在llvm.mbt中实现：

```moonbit
///|
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("fill_array_demo")
  let builder = ctx.createBuilder()
  let i32_ty = ctx.getInt32Ty()
  let ptr_ty = ctx.getPtrTy()
  let void_ty = ctx.getVoidTy()

  // 定义 fill_array 函数
  let fill_array_ty = ctx.getFunctionType(void_ty, [ptr_ty, i32_ty, i32_ty])
  let fill_array_func = mod.addFunction(fill_array_ty, "fill_array")
  let arr_param = fill_array_func.getArg(0).unwrap()
  let num_param = fill_array_func.getArg(1).unwrap()
  let len_param = fill_array_func.getArg(2).unwrap()

  // 创建基本块
  let entry_bb = fill_array_func.addBasicBlock(name="entry")
  let loop_cond_bb = fill_array_func.addBasicBlock(name="loop_cond")
  let loop_body_bb = fill_array_func.addBasicBlock(name="loop_body")
  let loop_exit_bb = fill_array_func.addBasicBlock(name="loop_exit")

  // 入口块：初始化
  builder.setInsertPoint(entry_bb)
  let _ = builder.createBr(loop_cond_bb)

  // 循环条件块
  builder.setInsertPoint(loop_cond_bb)
  let i_phi = builder.createPHI(i32_ty, name="i")
  i_phi.addIncoming(ctx.getConstInt32(0), entry_bb)

  // 检查循环条件：i < len
  let cond = builder.createICmpSLT(i_phi, len_param, name="cond")
  let _ = builder.createCondBr(cond, loop_body_bb, loop_exit_bb)

  // 循环体块
  builder.setInsertPoint(loop_body_bb)

  // 使用GEP计算 arr[i] 的地址
  let elem_ptr = builder.createGEP(arr_param, i32_ty, [i_phi], name="elem_ptr")

  // 存储值：arr[i] = num
  let _ = builder.createStore(num_param, elem_ptr)

  // 增加索引：i = i + 1
  let i_next = builder.createAdd(i_phi, ctx.getConstInt32(1), name="i_next")
  i_phi.addIncoming(i_next, loop_body_bb)
  let _ = builder.createBr(loop_cond_bb)

  // 循环退出块
  builder.setInsertPoint(loop_exit_bb)
  let _ = builder.createRetVoid()
  let expect =
    #|define void @fill_array(ptr %0, i32 %1, i32 %2) {
    #|entry:
    #|  br label %loop_cond
    #|
    #|loop_cond:                                        ; preds = %loop_body, %entry
    #|  %i = phi i32 [ 0, %entry ], [ %i_next, %loop_body ]
    #|  %cond = icmp slt i32 %i, %2
    #|  br i1 %cond, label %loop_body, label %loop_exit
    #|
    #|loop_body:                                        ; preds = %loop_cond
    #|  %elem_ptr = getelementptr i32, ptr %0, i32 %i
    #|  store i32 %1, ptr %elem_ptr, align 4
    #|  %i_next = add i32 %i, 1
    #|  br label %loop_cond
    #|
    #|loop_exit:                                        ; preds = %loop_cond
    #|  ret void
    #|}
    #|
  inspect(fill_array_func, content=expect)
}
```

### GEP指令详解

GEP指令的一般形式为：

```moonbit skip
let elem_ptr = builder.createGEP(base_ptr, pointee_type, indices, name="elem_ptr")
```

参数说明：
- `base_ptr`：基础指针（数组的起始地址）
- `pointee_type`：指针指向的类型
- `indices`：索引数组，用于计算偏移量
- `name`：结果指针的名称

对于一维数组访问，GEP指令计算公式为：
```
result_address = base_address + (index * sizeof(element_type))
```

## 完整的数组操作示例

现在让我们将所有部分组合起来，创建一个完整的数组操作程序：

```moonbit
///|
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("complete_array_demo")
  let builder = ctx.createBuilder()
  let i32_ty = ctx.getInt32Ty()
  let ptr_ty = ctx.getPtrTy()
  let void_ty = ctx.getVoidTy()

  // 声明外部函数
  let print_array_ty = ctx.getFunctionType(void_ty, [ptr_ty, i32_ty])
  let print_array_func = mod.addFunction(print_array_ty, "print_array")

  // 定义自己的 fill_array 函数（简化版）
  let fill_array_ty = ctx.getFunctionType(void_ty, [ptr_ty, i32_ty, i32_ty])
  let fill_array_func = mod.addFunction(fill_array_ty, "my_fill_array")
  let arr_param = fill_array_func.getArg(0).unwrap()
  let num_param = fill_array_func.getArg(1).unwrap()
  let fill_bb = fill_array_func.addBasicBlock(name="entry")
  builder.setInsertPoint(fill_bb)

  // 简化实现：只设置前三个元素作为示例
  let const_0 = ctx.getConstInt32(0)
  let const_1 = ctx.getConstInt32(1)
  let const_2 = ctx.getConstInt32(2)

  // arr[0] = num
  let ptr0 = builder.createGEP(arr_param, i32_ty, [const_0], name="ptr0")
  let _ = builder.createStore(num_param, ptr0)

  // arr[1] = num
  let ptr1 = builder.createGEP(arr_param, i32_ty, [const_1], name="ptr1")
  let _ = builder.createStore(num_param, ptr1)

  // arr[2] = num
  let ptr2 = builder.createGEP(arr_param, i32_ty, [const_2], name="ptr2")
  let _ = builder.createStore(num_param, ptr2)
  let _ = builder.createRetVoid()

  // 定义 main 函数
  let main_ty = ctx.getFunctionType(i32_ty, [])
  let main_func = mod.addFunction(main_ty, "main")
  let main_bb = main_func.addBasicBlock(name="entry")
  builder.setInsertPoint(main_bb)

  // 创建栈数组
  let array_ty = ctx.getArrayType(i32_ty, 5)
  let stack_arr = builder.createAlloca(array_ty, name="stack_arr")
  let const_42 = ctx.getConstInt32(42)
  let const_5 = ctx.getConstInt32(5)

  // 填充和打印栈数组
  let _ = builder.createCall(fill_array_func, [stack_arr, const_42, const_5])
  let _ = builder.createCall(print_array_func, [stack_arr, const_5])
  let _ = builder.createRet(const_0)
  let expect =
    #|; ModuleID = 'complete_array_demo'
    #|source_filename = "complete_array_demo"
    #|target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
    #|
    #|declare void @print_array(ptr, i32)
    #|
    #|define void @my_fill_array(ptr %0, i32 %1, i32 %2) {
    #|entry:
    #|  %ptr0 = getelementptr i32, ptr %0, i32 0
    #|  store i32 %1, ptr %ptr0, align 4
    #|  %ptr1 = getelementptr i32, ptr %0, i32 1
    #|  store i32 %1, ptr %ptr1, align 4
    #|  %ptr2 = getelementptr i32, ptr %0, i32 2
    #|  store i32 %1, ptr %ptr2, align 4
    #|  ret void
    #|}
    #|
    #|define i32 @main() {
    #|entry:
    #|  %stack_arr = alloca [5 x i32], align 4
    #|  call void @my_fill_array(ptr %stack_arr, i32 42, i32 5)
    #|  call void @print_array(ptr %stack_arr, i32 5)
    #|  ret i32 0
    #|}
    #|
  inspect(mod, content=expect)
}
```

## 外部函数链接

为了运行这些数组程序，我们需要提供外部函数的C语言实现：

```c
#include <stdio.h>
#include <stdlib.h>

void fill_array(int* arr, int num, int len) {
  for (int i = 0; i < len; ++i) {
    arr[i] = num;
  }
}

void print_array(int *arr, int len) {
  for (int i = 0; i < len; ++i) {
    printf("%d ", arr[i]);
  }
  printf("\n");
}
```

编译和链接过程：

```bash
# 生成LLVM IR
moon run main --target native > array_demo.ll

# 编译为目标文件
llc -filetype=obj array_demo.ll -o array_demo.o

# 编译C辅助函数
gcc -c array_helper.c -o array_helper.o

# 链接生成可执行文件
gcc array_demo.o array_helper.o -o array_demo

# 运行程序
./array_demo  # 输出: 42 42 42 42 42
```

## 数组操作的最佳实践

在使用数组时，建议遵循以下最佳实践：

### 1. 选择合适的分配方式

- 对于固定大小的小数组，优先使用栈分配
- 对于大数组或动态大小的数组，使用堆分配
- 考虑数组的生命周期需求

### 2. 边界检查

虽然LLVM不会自动进行边界检查，但在实际应用中应该添加适当的边界检查逻辑。

### 3. 内存对齐

LLVM会自动处理内存对齐，但了解对齐规则有助于优化内存使用。

### 4. GEP指令的高效使用

- GEP指令不执行内存访问，只计算地址
- 可以链式使用GEP指令进行复杂的地址计算
- 理解GEP的语义对于处理多维数组和结构体至关重要

## 结语

数组是构建复杂数据结构的基础。通过本章的学习，您已经掌握了：

- 栈上和堆上数组的分配方法
- 使用`getArrayType`定义数组类型
- 使用GEP指令进行数组索引操作
- 实现完整的数组操作函数

GEP指令是LLVM中最重要的指令之一，它不仅用于数组索引，也是处理结构体成员访问的基础。在下一章中，我们将学习结构体的使用，这将进一步扩展您处理复杂数据结构的能力。

数组操作的掌握标志着您已经具备了实现复杂算法和数据结构的基础能力，为后续的高级主题学习奠定了坚实的基础。
