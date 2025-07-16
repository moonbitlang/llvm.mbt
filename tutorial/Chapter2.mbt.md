# 第2章：变量和指针

在前一章中，我们掌握了LLVM中基本数据类型的运算操作。然而，您可能已经注意到，我们的所有示例都是直接对函数参数和常量进行操作，没有涉及变量的概念。这引出了一个重要的问题：在LLVM中如何处理变量？本章将深入探讨这个核心概念，揭示LLVM独特的设计哲学以及变量操作的实现机制。

## SSA形式：LLVM的设计精髓

在深入变量操作之前，我们必须理解LLVM的一个根本性设计特征：**SSA形式**（Static Single Assignment，静态单赋值形式）。这个概念对于理解LLVM的工作方式至关重要。

### 什么是SSA形式？

SSA形式是一种中间表示的设计原则，它要求**每个变量在整个程序中只能被赋值一次**。换句话说，一旦一个值被创建并命名，它就变成了不可变的。这种设计带来了许多优势：

1. **优化友好**：编译器可以更容易地进行数据流分析和优化
2. **并行化支持**：不可变值天然支持并行处理
3. **简化分析**：减少了变量生命周期分析的复杂性

让我们通过一个简单的例子来理解这个概念：

```moonbit
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("ssa_demo")
  let builder = ctx.createBuilder()

  let i32_ty = ctx.getInt32Ty()
  let func_ty = ctx.getFunctionType(i32_ty, [i32_ty])
  
  let func = mod.addFunction(func_ty, "ssa_example")
  let entry_bb = func.addBasicBlock(name="entry")
  
  builder.setInsertPoint(entry_bb)
  
  let arg = func.getArg(0).unwrap()
  let val1 = builder.createAdd(arg, ctx.getConstInt32(10), name="val1")
  let val2 = builder.createMul(val1, ctx.getConstInt32(2), name="val2")
  let _ = builder.createRet(val2)

  // 注意：val1和val2都只被赋值一次，符合SSA形式
  let expect = 
    #|define i32 @ssa_example(i32 %0) {
    #|entry:
    #|  %val1 = add i32 %0, 10
    #|  %val2 = mul i32 %val1, 2
    #|  ret i32 %val2
    #|}
    #|

  inspect(func, content=expect)
}
```

在这个例子中，`%val1`和`%val2`都只被赋值一次，这就是SSA形式的体现。

### 高级语言变量的挑战

然而，大多数高级编程语言都支持变量的重复赋值。考虑以下C代码：

```c
int x = 10;
x = x + 5;
x = x * 2;
return x;
```

这种代码模式在传统编程中非常常见，但它与SSA形式产生了直接冲突。变量`x`被多次赋值，这在纯SSA形式中是不被允许的。

## 解决方案：内存操作三重奏

LLVM通过一个巧妙的方案解决了这个矛盾：**将变量概念转换为内存操作**。具体来说，LLVM使用三个核心指令来模拟传统变量的行为：

1. **`alloca`** - 在栈上分配内存空间
2. **`store`** - 将值存储到内存地址
3. **`load`** - 从内存地址读取值

这种方法的核心思想是：变量不再是直接的值，而是内存中的一个位置。我们通过读写这个位置来实现变量的效果。

### alloca指令：内存分配的艺术

`alloca`指令负责在当前函数的栈帧中分配内存。它的返回值是一个**指针**，指向新分配的内存区域。这个细节非常重要：`alloca`返回的不是变量本身，而是变量的地址。

让我们通过一个简单的例子来理解：

```moonbit
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("alloca_demo")
  let builder = ctx.createBuilder()

  let i32_ty = ctx.getInt32Ty()
  let func_ty = ctx.getFunctionType(i32_ty, [])
  
  let func = mod.addFunction(func_ty, "alloca_example")
  let entry_bb = func.addBasicBlock(name="entry")
  
  builder.setInsertPoint(entry_bb)
  
  // 分配一个i32大小的内存空间
  let var_ptr = builder.createAlloca(i32_ty, name="var")
  
  // var_ptr的类型是ptr（指针类型），不是i32
  inspect(var_ptr, content="  %var = alloca i32, align 4")
}
```

注意`alloca`指令的几个重要特点：

1. **返回类型**：返回的是指针类型（`ptr`），不是我们分配的数据类型
2. **对齐**：LLVM自动处理内存对齐，确保最佳性能
3. **生命周期**：分配的内存在函数返回时自动释放

## 实战演练：变量操作的完整实现

现在让我们通过一个完整的例子来展示如何在LLVM中实现变量操作。我们将实现以下C函数：

```c
int square_sum(int a, int b) {
  int a_square = a * a;
  int b_square = b * b;
  int sum = a_square + b_square;
  return sum;
}
```

这个函数使用了三个局部变量，是演示变量操作的理想例子：

```moonbit
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("variable_demo")
  let builder = ctx.createBuilder()

  // 定义函数类型：接受两个i32参数，返回i32
  let i32_ty = ctx.getInt32Ty()
  let func_ty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])

  // 创建函数
  let square_sum_func = mod.addFunction(func_ty, "square_sum")
  let entry_bb = square_sum_func.addBasicBlock(name="entry")

  // 获取函数参数
  let arg_a = square_sum_func.getArg(0).unwrap()
  let arg_b = square_sum_func.getArg(1).unwrap()

  builder.setInsertPoint(entry_bb)
  
  // 第一步：为三个局部变量分配内存
  let a_square_ptr = builder.createAlloca(i32_ty, name="a_square")
  let b_square_ptr = builder.createAlloca(i32_ty, name="b_square") 
  let sum_ptr = builder.createAlloca(i32_ty, name="sum")

  // 第二步：计算 a * a 并存储到 a_square
  let a_squared_val = builder.createMul(arg_a, arg_a, name="a_squared_val")
  let _ = builder.createStore(a_squared_val, a_square_ptr)

  // 第三步：计算 b * b 并存储到 b_square
  let b_squared_val = builder.createMul(arg_b, arg_b, name="b_squared_val")
  let _ = builder.createStore(b_squared_val, b_square_ptr)

  // 第四步：从内存中读取两个平方值并计算和
  let a_square_loaded = builder.createLoad(i32_ty, a_square_ptr, name="a_square_loaded")
  let b_square_loaded = builder.createLoad(i32_ty, b_square_ptr, name="b_square_loaded")
  let sum_val = builder.createAdd(a_square_loaded, b_square_loaded, name="sum_val")
  
  // 第五步：将和存储到 sum 变量
  let _ = builder.createStore(sum_val, sum_ptr)

  // 第六步：读取最终结果并返回
  let final_result = builder.createLoad(i32_ty, sum_ptr, name="final_result")
  let _ = builder.createRet(final_result)

  // 验证生成的LLVM IR
  let expect = 
    #|define i32 @square_sum(i32 %0, i32 %1) {
    #|entry:
    #|  %a_square = alloca i32, align 4
    #|  %b_square = alloca i32, align 4
    #|  %sum = alloca i32, align 4
    #|  %a_squared_val = mul i32 %0, %0
    #|  store i32 %a_squared_val, ptr %a_square, align 4
    #|  %b_squared_val = mul i32 %1, %1
    #|  store i32 %b_squared_val, ptr %b_square, align 4
    #|  %a_square_loaded = load i32, ptr %a_square, align 4
    #|  %b_square_loaded = load i32, ptr %b_square, align 4
    #|  %sum_val = add i32 %a_square_loaded, %b_square_loaded
    #|  store i32 %sum_val, ptr %sum, align 4
    #|  %final_result = load i32, ptr %sum, align 4
    #|  ret i32 %final_result
    #|}
    #|

  inspect(square_sum_func, content=expect)
}
```

### 代码深度解析

这个例子完美展示了LLVM中变量操作的完整流程：

#### 1. 内存分配阶段
```moonbit skip
let a_square_ptr = builder.createAlloca(i32_ty, name="a_square")
let b_square_ptr = builder.createAlloca(i32_ty, name="b_square") 
let sum_ptr = builder.createAlloca(i32_ty, name="sum")
```

我们为三个局部变量分别分配了内存空间。每个`alloca`调用都返回一个指针，指向一个`i32`大小的内存区域。

#### 2. 计算与存储
```moonbit skip
let a_squared_val = builder.createMul(arg_a, arg_a, name="a_squared_val")
let _ = builder.createStore(a_squared_val, a_square_ptr)
```

计算结果后，我们使用`store`指令将值写入到相应的内存地址。`store`指令接受两个参数：要存储的值和目标内存地址。

#### 3. 加载与使用
```moonbit skip
let a_square_loaded = builder.createLoad(i32_ty, a_square_ptr, name="a_square_loaded")
```

当需要使用变量的值时，我们使用`load`指令从内存中读取。`load`指令需要两个参数：要加载的数据类型和源内存地址。

## 指针类型的重要性

在这个过程中，理解指针类型的概念至关重要。`alloca`指令返回的值具有指针类型，这意味着：

1. **类型区分**：指针类型（`ptr`）与其指向的数据类型（如`i32`）是完全不同的
2. **操作限制**：不能对指针直接进行算术运算
3. **内存语义**：指针代表内存地址，而不是存储在该地址的值

让我们通过一个对比例子来加深理解：

```moonbit
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("pointer_demo")
  let builder = ctx.createBuilder()

  let i32_ty = ctx.getInt32Ty()
  let func_ty = ctx.getFunctionType(i32_ty, [])
  
  let func = mod.addFunction(func_ty, "pointer_example")
  let entry_bb = func.addBasicBlock(name="entry")
  
  builder.setInsertPoint(entry_bb)
  
  // alloca返回指针类型
  let var_ptr = builder.createAlloca(i32_ty, name="var")
  
  // 常量是值类型
  let const_42 = ctx.getConstInt32(42)
  
  // store操作：将值类型存储到指针指向的内存
  let _ = builder.createStore(const_42, var_ptr)
  
  // load操作：从指针指向的内存读取值类型
  let loaded_val = builder.createLoad(i32_ty, var_ptr, name="loaded")
  
  let _ = builder.createRet(loaded_val)

  // 观察生成的IR，注意类型标注
  let expect = 
    #|define i32 @pointer_example() {
    #|entry:
    #|  %var = alloca i32, align 4
    #|  store i32 42, ptr %var, align 4
    #|  %loaded = load i32, ptr %var, align 4
    #|  ret i32 %loaded
    #|}
    #|

  inspect(func, content=expect)
}
```

在生成的IR中，注意以下关键点：

- `%var`的类型是`ptr`（虽然在IR中不显式标注，但它是指针类型）
- `store`指令的语法是`store <value_type> <value>, ptr <pointer>`
- `load`指令的语法是`load <value_type>, ptr <pointer>`

## 性能考虑与优化

您可能会担心这种通过内存操作来模拟变量的方法会影响性能。确实，频繁的内存读写操作在理论上比直接的寄存器操作要慢。然而，LLVM的优化器非常智能，它会在后续的优化过程中尽可能地将这些内存操作优化为寄存器操作。

这种优化被称为**内存到寄存器提升**（mem2reg），它是LLVM优化流水线中的一个重要环节。在实际应用中，大部分简单的局部变量操作最终都会被优化为纯SSA形式的寄存器操作。

## 变量操作的最佳实践

在使用llvm.mbt进行变量操作时，建议遵循以下最佳实践：

1. **合理分组**：将相关的alloca指令放在函数入口处，保持代码的清晰结构
2. **明确命名**：为指针和加载的值使用有意义的名称，区分指针和值
3. **类型一致**：确保load操作的类型与原始alloca的类型匹配
4. **避免过度优化**：相信LLVM的优化器，专注于生成正确的IR而不是手动优化

## 小结

本章我们深入探讨了LLVM中变量操作的核心机制：

1. **SSA形式**：理解了LLVM的静态单赋值设计原则
2. **内存操作三重奏**：掌握了alloca、store、load三个核心指令
3. **指针类型**：理解了指针与值的区别以及它们在类型系统中的角色
4. **完整实践**：通过square_sum函数展示了变量操作的完整流程

这些概念是理解更复杂LLVM程序的基础。变量操作不仅在简单的算术程序中有用，在实现复杂的控制流、数据结构和函数调用时都扮演着重要角色。

在下一章中，我们将探讨LLVM的控制流构造，学习如何实现条件分支和循环结构，进一步扩展我们构建复杂程序的能力。

要查看完整的LLVM IR输出，您可以将任何测试代码放入main函数中，调用`mod.dump()`，然后通过以下命令运行：

```bash
moon run main --target native
```
