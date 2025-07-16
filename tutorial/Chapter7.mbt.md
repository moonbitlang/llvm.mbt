# 第7章：结构体

结构体是现代编程语言中组织相关数据的基本机制。它允许我们将不同类型的数据项组合成一个逻辑单元，从而构建更复杂、更有意义的数据抽象。在LLVM中，结构体提供了实现面向对象编程、数据封装和复杂算法的基础。

本章将详细介绍如何在llvm.mbt中定义和使用结构体，包括类型定义、内存分配、成员访问以及实际应用示例。

## 结构体的基本概念

结构体是一种复合数据类型，它将多个不同类型的成员组合在一起。与数组不同，结构体的成员可以是不同的类型，每个成员都有自己的名称（在高级语言中）和固定的内存偏移量。

在LLVM中，结构体的特点包括：

- **异构性**：成员可以是不同的数据类型
- **顺序布局**：成员按声明顺序在内存中连续存储
- **固定偏移**：每个成员在结构体中的位置是固定的
- **内存对齐**：LLVM会自动处理内存对齐以优化访问性能

## 结构体类型的定义

在llvm.mbt中，我们使用`getStructType`方法来定义结构体类型。让我们从一个简单的例子开始——有理数（Rational）结构体：

在C语言中，我们这样定义Rational：

```c
typedef struct {
  int p;
  int q;
} Rational;
```

```moonbit
test {
  let ctx = @IR.Context::new()
  let i32_ty = ctx.getInt32Ty()

  // 定义 Rational 结构体：包含两个 i32 成员 p 和 q
  let rational_ty = ctx.getStructType([i32_ty, i32_ty], name="Rational")

  inspect(rational_ty, content="%Rational = type { i32, i32 }")
}
```

`getStructType`方法接受以下参数：
- **成员类型列表**：按顺序指定结构体成员的类型
- **isPacked**（可选）：是否紧密打包，不进行内存对齐
- **name**（可选）：结构体的名称，用于调试和可读性

## 结构体的内存分配

与数组类似，结构体也可以分配在栈上或堆上：

### 栈上结构体

栈上结构体使用`createAlloca`分配：

```moonbit
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("stack_struct_demo")
  let builder = ctx.createBuilder()

  let i32_ty = ctx.getInt32Ty()
  let rational_ty = ctx.getStructType([i32_ty, i32_ty], name="Rational")

  // 定义函数来演示栈上结构体
  let demo_ty = ctx.getFunctionType(ctx.getVoidTy(), [])
  let demo_func = mod.addFunction(demo_ty, "demo_stack_struct")
  let bb = demo_func.addBasicBlock(name="entry")

  builder.setInsertPoint(bb)

  // 在栈上分配 Rational 结构体
  let _ = builder.createAlloca(rational_ty, name="r1")

  let _ = builder.createRetVoid()

  let expect = 
    #|%Rational = type { i32, i32 }
    #|
    #|define void @demo_stack_struct() {
    #|entry:
    #|  %r1 = alloca %Rational, align 8
    #|  ret void
    #|}

  inspect(mod, content=expect)
}
```

### 堆上结构体

堆上结构体使用`createMalloc`分配：

```moonbit
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("heap_struct_demo")
  let builder = ctx.createBuilder()

  let i32_ty = ctx.getInt32Ty()
  let ptr_ty = ctx.getPtrTy()
  let rational_ty = ctx.getStructType([i32_ty, i32_ty], name="Rational")

  // 定义构造函数：Rational* new_rational(int p, int q)
  let new_rational_ty = ctx.getFunctionType(ptr_ty, [i32_ty, i32_ty])
  let new_rational_func = mod.addFunction(new_rational_ty, "new_rational")
  let _ = new_rational_func.getArg(0).unwrap()
  let _ = new_rational_func.getArg(1).unwrap()

  let bb = new_rational_func.addBasicBlock(name="entry")
  builder.setInsertPoint(bb)

  // 在堆上分配 Rational 结构体
  let rational_ptr = builder.createMalloc(rational_ty, name="r")

  let _ = builder.createRet(rational_ptr)

  let expect = 
    #|%Rational = type { i32, i32 }
    #|
    #|define ptr @new_rational(i32 %0, i32 %1) {
    #|entry:
    #|  %r = tail call ptr @malloc(i32 ptrtoint (ptr getelementptr (%Rational, ptr null, i32 1) to i32))
    #|  ret ptr %r
    #|}

  inspect(new_rational_func, content=expect)
}
```

## 结构体成员访问

访问结构体成员需要使用GEP指令来计算成员的地址。GEP指令对于结构体的语法略有不同，需要提供结构体类型和成员索引。

### 基本成员访问

```moonbit
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("struct_access_demo")
  let builder = ctx.createBuilder()

  let i32_ty = ctx.getInt32Ty()
  let ptr_ty = ctx.getPtrTy()
  let rational_ty = ctx.getStructType([i32_ty, i32_ty], name="Rational")

  // 定义函数来演示成员访问
  let set_rational_ty = ctx.getFunctionType(ctx.getVoidTy(), [ptr_ty, i32_ty, i32_ty])
  let set_rational_func = mod.addFunction(set_rational_ty, "set_rational")
  let r_param = set_rational_func.getArg(0).unwrap()
  let p_param = set_rational_func.getArg(1).unwrap()
  let q_param = set_rational_func.getArg(2).unwrap()

  let bb = set_rational_func.addBasicBlock(name="entry")
  builder.setInsertPoint(bb)

  // 访问第一个成员 (p)：r->p = p_param
  let p_ptr = builder.createGEP(r_param, rational_ty, [ctx.getConstInt32(0), ctx.getConstInt32(0)], name="p_ptr")
  let _ = builder.createStore(p_param, p_ptr)

  // 访问第二个成员 (q)：r->q = q_param
  let q_ptr = builder.createGEP(r_param, rational_ty, [ctx.getConstInt32(0), ctx.getConstInt32(1)], name="q_ptr")
  let _ = builder.createStore(q_param, q_ptr)

  let _ = builder.createRetVoid()

  let expect = 
    #|%Rational = type { i32, i32 }
    #|
    #|define void @set_rational(ptr %0, i32 %1, i32 %2) {
    #|entry:
    #|  %p_ptr = getelementptr %Rational, ptr %0, i32 0, i32 0
    #|  store i32 %1, ptr %p_ptr, align 4
    #|  %q_ptr = getelementptr %Rational, ptr %0, i32 0, i32 1
    #|  store i32 %2, ptr %q_ptr, align 4
    #|  ret void
    #|}

  inspect(set_rational_func, content=expect)
}
```

### 结构体GEP指令详解

对于结构体，GEP指令的索引数组包含两个元素：

```moonbit skip
let member_ptr = builder.createGEP(struct_ptr, struct_type, [0, member_index], name="member_ptr")
```

- **第一个索引（0）**：表示这是一个指针解引用操作
- **第二个索引（member_index）**：指定要访问的成员在结构体中的位置

这种索引方式使得LLVM能够精确计算成员的内存地址，考虑到结构体的内存布局和对齐要求。

## 完整的结构体应用示例

现在让我们实现一个完整的有理数处理程序，包括构造函数、成员设置和类型转换：

```moonbit
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("rational_demo")
  let builder = ctx.createBuilder()

  let i32_ty = ctx.getInt32Ty()
  let f64_ty = ctx.getDoubleTy()
  let ptr_ty = ctx.getPtrTy()
  let void_ty = ctx.getVoidTy()
  let rational_ty = ctx.getStructType([i32_ty, i32_ty], name="Rational")

  // 声明外部函数
  let print_double_ty = ctx.getFunctionType(void_ty, [f64_ty])
  let print_double_func = mod.addFunction(print_double_ty, "print_double")

  // 定义 new_rational 函数
  let new_rational_ty = ctx.getFunctionType(ptr_ty, [i32_ty, i32_ty])
  let new_rational_func = mod.addFunction(new_rational_ty, "new_rational")
  let new_p = new_rational_func.getArg(0).unwrap()
  let new_q = new_rational_func.getArg(1).unwrap()

  let new_bb = new_rational_func.addBasicBlock(name="entry")
  builder.setInsertPoint(new_bb)

  // 分配内存并初始化
  let r_ptr = builder.createMalloc(rational_ty, name="r")
  
  // 设置 r->p = p
  let p_ptr = builder.createGEP(r_ptr, rational_ty, [ctx.getConstInt32(0), ctx.getConstInt32(0)], name="p_ptr")
  let _ = builder.createStore(new_p, p_ptr)
  
  // 设置 r->q = q  
  let q_ptr = builder.createGEP(r_ptr, rational_ty, [ctx.getConstInt32(0), ctx.getConstInt32(1)], name="q_ptr")
  let _ = builder.createStore(new_q, q_ptr)

  let _ = builder.createRet(r_ptr)

  // 定义 rational_to_double 函数
  let to_double_ty = ctx.getFunctionType(f64_ty, [ptr_ty])
  let to_double_func = mod.addFunction(to_double_ty, "rational_to_double")
  let r_param = to_double_func.getArg(0).unwrap()

  let to_double_bb = to_double_func.addBasicBlock(name="entry")
  builder.setInsertPoint(to_double_bb)

  // 加载 r->p 和 r->q
  let p_addr = builder.createGEP(r_param, rational_ty, [ctx.getConstInt32(0), ctx.getConstInt32(0)], name="p_addr")
  let p_val = builder.createLoad(i32_ty, p_addr, name="p_val")
  
  let q_addr = builder.createGEP(r_param, rational_ty, [ctx.getConstInt32(0), ctx.getConstInt32(1)], name="q_addr")
  let q_val = builder.createLoad(i32_ty, q_addr, name="q_val")

  // 转换为double并计算除法
  let p_double = builder.createSIToFP(p_val, f64_ty, name="p_double")
  let q_double = builder.createSIToFP(q_val, f64_ty, name="q_double")
  let result = builder.createFDiv(p_double, q_double, name="result")

  let _ = builder.createRet(result)

  // 定义 main 函数
  let main_ty = ctx.getFunctionType(i32_ty, [])
  let main_func = mod.addFunction(main_ty, "main")
  let main_bb = main_func.addBasicBlock(name="entry")

  builder.setInsertPoint(main_bb)

  // 创建栈上的有理数：Rational r1 = {2, 1}
  let r1 = builder.createAlloca(rational_ty, name="r1")
  let r1_p_ptr = builder.createGEP(r1, rational_ty, [ctx.getConstInt32(0), ctx.getConstInt32(0)], name="r1_p_ptr")
  let r1_q_ptr = builder.createGEP(r1, rational_ty, [ctx.getConstInt32(0), ctx.getConstInt32(1)], name="r1_q_ptr")
  let _ = builder.createStore(ctx.getConstInt32(2), r1_p_ptr)
  let _ = builder.createStore(ctx.getConstInt32(1), r1_q_ptr)

  // 转换并打印
  let d1 = builder.createCall(to_double_func, [r1], name="d1")
  let _ = builder.createCall(print_double_func, [d1])

  // 创建堆上的有理数：Rational* r2 = new_rational(1, 2)
  let r2 = builder.createCall(new_rational_func, [ctx.getConstInt32(1), ctx.getConstInt32(2)], name="r2")
  let d2 = builder.createCall(to_double_func, [r2], name="d2")
  let _ = builder.createCall(print_double_func, [d2])

  let _ = builder.createRet(ctx.getConstInt32(0))

  let expect = 
    #|%Rational = type { i32, i32 }
    #|
    #|declare void @print_double(double)
    #|
    #|define ptr @new_rational(i32 %0, i32 %1) {
    #|entry:
    #|  %r = tail call ptr @malloc(i32 ptrtoint (ptr getelementptr (%Rational, ptr null, i32 1) to i32))
    #|  %p_ptr = getelementptr %Rational, ptr %r, i32 0, i32 0
    #|  store i32 %0, ptr %p_ptr, align 4
    #|  %q_ptr = getelementptr %Rational, ptr %r, i32 0, i32 1
    #|  store i32 %1, ptr %q_ptr, align 4
    #|  ret ptr %r
    #|}
    #|
    #|define double @rational_to_double(ptr %0) {
    #|entry:
    #|  %p_addr = getelementptr %Rational, ptr %0, i32 0, i32 0
    #|  %p_val = load i32, ptr %p_addr, align 4
    #|  %q_addr = getelementptr %Rational, ptr %0, i32 0, i32 1
    #|  %q_val = load i32, ptr %q_addr, align 4
    #|  %p_double = sitofp i32 %p_val to double
    #|  %q_double = sitofp i32 %q_val to double
    #|  %result = fdiv double %p_double, %q_double
    #|  ret double %result
    #|}
    #|
    #|define i32 @main() {
    #|entry:
    #|  %r1 = alloca %Rational, align 8
    #|  %r1_p_ptr = getelementptr %Rational, ptr %r1, i32 0, i32 0
    #|  %r1_q_ptr = getelementptr %Rational, ptr %r1, i32 0, i32 1
    #|  store i32 2, ptr %r1_p_ptr, align 4
    #|  store i32 1, ptr %r1_q_ptr, align 4
    #|  %d1 = call double @rational_to_double(ptr %r1)
    #|  call void @print_double(double %d1)
    #|  %r2 = call ptr @new_rational(i32 1, i32 2)
    #|  %d2 = call double @rational_to_double(ptr %r2)
    #|  call void @print_double(double %d2)
    #|  ret i32 0
    #|}

  inspect(mod, content=expect)
}
```

## 外部函数链接

为了运行上面的程序，我们需要提供`print_double`函数的C语言实现：

```c
#include <stdio.h>

void print_double(double d) {
    printf("%.6f\n", d);
}
```

编译和链接过程：

```bash
# 生成LLVM IR
moon run main --target native > struct_demo.ll

# 编译为目标文件
llc -filetype=obj struct_demo.ll -o struct_demo.o

# 编译C辅助函数
gcc -c print_helper.c -o print_helper.o

# 链接生成可执行文件
gcc struct_demo.o print_helper.o -o struct_demo

# 运行程序
./struct_demo  
# 输出:
# 2.000000
# 0.500000
```

## 结构体的高级特性

### 1. 嵌套结构体

结构体可以包含其他结构体作为成员：

```moonbit skip
let point_ty = ctx.getStructType([f64_ty, f64_ty], name="Point")
let rectangle_ty = ctx.getStructType([point_ty, point_ty], name="Rectangle")
```

### 2. 结构体数组

可以创建结构体的数组：

```moonbit skip
let rational_array_ty = ctx.getArrayType(rational_ty, 10)
let rational_array = builder.createAlloca(rational_array_ty, name="rationals")
```

### 3. 紧密打包的结构体

使用`isPacked=true`可以创建没有内存对齐的紧密打包结构体：

```moonbit skip
let packed_ty = ctx.getStructType([i8_ty, i32_ty], isPacked=true, name="Packed")
```

## 结构体操作的最佳实践

### 1. 合理的成员顺序

将经常一起访问的成员放在一起，考虑内存对齐以优化性能。

### 2. 类型安全

确保GEP指令中的成员索引与结构体定义匹配。

### 3. 内存管理

对于堆分配的结构体，记得在不需要时释放内存。

### 4. 构造函数模式

为复杂结构体提供专门的构造函数，确保正确的初始化。

## 结构体与面向对象编程

虽然LLVM本身不支持面向对象编程，但结构体为实现面向对象特性提供了基础：

### 1. 数据封装

结构体将相关数据组织在一起，形成逻辑单元。

### 2. 方法实现

通过将结构体指针作为第一个参数，可以模拟方法调用。

### 3. 继承模拟

通过在结构体开始处包含"基类"结构体，可以模拟继承。

## 结语

结构体是构建复杂程序的重要工具。通过本章的学习，您已经掌握了：

- 使用`getStructType`定义结构体类型
- 在栈和堆上分配结构体内存
- 使用GEP指令访问结构体成员
- 实现完整的结构体操作函数
- 构建面向对象编程的基础

结构体的掌握为您打开了数据抽象和复杂系统设计的大门。它不仅是实现算法和数据结构的基础，也是构建大型软件系统的重要工具。

在实际应用中，结构体常常与数组、指针和函数相结合，形成更复杂的数据结构如链表、树、图等。结构体的功能完善为更高级的编程概念和系统设计奠定了坚实的基础。
