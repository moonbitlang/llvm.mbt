# 第3章：分支与循环的构建

在前两章中，我们掌握了LLVM中基本数据类型的运算操作以及变量的管理。然而，到目前为止我们构建的所有程序都是线性执行的——从函数入口开始，逐步执行每一条指令，最终到达函数出口。这种线性执行模式虽然简单，但远远不能满足实际编程的需求。真正的程序需要根据条件做出决策，需要重复执行某些操作，这就是控制流的核心概念。

本章将深入探讨LLVM中控制流的构建，包括条件分支、多路分支（Switch）以及循环结构。通过本章的学习，您将能够构建具有复杂逻辑结构的LLVM程序。

## 条件分支：决策的艺术

条件分支是程序控制流中最基础也是最重要的概念之一。它允许程序根据运行时的条件来选择不同的执行路径。在LLVM中，条件分支的实现依赖于比较指令和分支指令的协作。

### 整数比较与分支

让我们从一个经典的例子开始——实现求两个整数最大值的函数：

```c
int max(int a, int b) {
  if (a > b) {
    return a;
  } else {
    return b;
  }
}
```

这个简单的函数包含了条件分支的所有核心要素：条件判断、真分支和假分支。让我们看看如何用llvm.mbt来实现它：

```moonbit
///|
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("conditional_demo")
  let builder = ctx.createBuilder()

  // 定义函数类型：int max(int a, int b)
  let i32_ty = ctx.getInt32Ty()
  let func_ty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
  let max_func = mod.addFunction(func_ty, "max")
  let arg_a = max_func.getArg(0).unwrap()
  let arg_b = max_func.getArg(1).unwrap()

  // 创建基本块
  let entry_bb = max_func.addBasicBlock(name="entry")
  let then_bb = max_func.addBasicBlock(name="then")
  let else_bb = max_func.addBasicBlock(name="else")
  let merge_bb = max_func.addBasicBlock(name="merge")

  // 入口块：进行比较并条件分支
  builder.setInsertPoint(entry_bb)
  let cond = builder.createICmpSGT(arg_a, arg_b, name="cmp_result")
  let _ = builder.createCondBr(cond, then_bb, else_bb)

  // then块：a > b时的处理
  builder.setInsertPoint(then_bb)
  let _ = builder.createBr(merge_bb)

  // else块：a <= b时的处理  
  builder.setInsertPoint(else_bb)
  let _ = builder.createBr(merge_bb)

  // merge块：合并两个分支的结果
  builder.setInsertPoint(merge_bb)
  let result_phi = builder.createPHI(i32_ty, name="result")
  result_phi.addIncoming(arg_a, then_bb)
  result_phi.addIncoming(arg_b, else_bb)
  let _ = builder.createRet(result_phi)
  let expect =
    #|define i32 @max(i32 %0, i32 %1) {
    #|entry:
    #|  %cmp_result = icmp sgt i32 %0, %1
    #|  br i1 %cmp_result, label %then, label %else
    #|
    #|then:                                             ; preds = %entry
    #|  br label %merge
    #|
    #|else:                                             ; preds = %entry
    #|  br label %merge
    #|
    #|merge:                                            ; preds = %else, %then
    #|  %result = phi i32 [ %0, %then ], [ %1, %else ]
    #|  ret i32 %result
    #|}
    #|
  inspect(max_func, content=expect)
}
```

这个例子展示了LLVM条件分支的完整结构。让我们逐一分析关键组件：

#### 整数比较指令族

`createICmpSGT`是整数比较指令族中的一员，用于进行有符号的大于比较。llvm.mbt提供了完整的整数比较指令系列：

- **相等性比较**：
  - `createICmpEQ` - 等于 (==)
  - `createICmpNE` - 不等于 (!=)

- **有符号比较**：
  - `createICmpSGT` - 有符号大于 (>)
  - `createICmpSGE` - 有符号大于等于 (>=)
  - `createICmpSLT` - 有符号小于 (<)
  - `createICmpSLE` - 有符号小于等于 (<=)

- **无符号比较**：
  - `createICmpUGT` - 无符号大于
  - `createICmpUGE` - 无符号大于等于
  - `createICmpULT` - 无符号小于
  - `createICmpULE` - 无符号小于等于

所有这些比较指令都返回`i1`类型（布尔型）的结果，可以直接用于条件分支。

#### 分支指令

LLVM提供了两种分支指令：

- `createBr(target)` - 无条件分支，直接跳转到目标基本块
- `createCondBr(condition, true_block, false_block)` - 条件分支，根据条件选择跳转目标

#### PHI节点：分支汇合的关键

PHI节点是LLVM中处理控制流汇合的核心机制。当多个基本块可能跳转到同一个基本块时，我们需要使用PHI节点来选择正确的值。在上面的例子中，PHI节点根据前驱基本块的不同来选择返回`arg_a`还是`arg_b`。

### 浮点数比较与分支

浮点数的比较比整数复杂得多，因为需要处理NaN（Not a Number）和无穷大等特殊值。让我们看看浮点数版本的最大值函数：

```moonbit
///|
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("float_conditional")
  let builder = ctx.createBuilder()

  // 定义函数类型：double max(double a, double b)
  let f64_ty = ctx.getDoubleTy()
  let func_ty = ctx.getFunctionType(f64_ty, [f64_ty, f64_ty])
  let max_func = mod.addFunction(func_ty, "max_double")
  let arg_a = max_func.getArg(0).unwrap()
  let arg_b = max_func.getArg(1).unwrap()

  // 创建基本块
  let entry_bb = max_func.addBasicBlock(name="entry")
  let then_bb = max_func.addBasicBlock(name="then")
  let else_bb = max_func.addBasicBlock(name="else")
  let merge_bb = max_func.addBasicBlock(name="merge")

  // 入口块：进行浮点数比较
  builder.setInsertPoint(entry_bb)
  let cond = builder.createFCmpOGT(arg_a, arg_b, name="fcmp_result")
  let _ = builder.createCondBr(cond, then_bb, else_bb)

  // then块和else块
  builder.setInsertPoint(then_bb)
  let _ = builder.createBr(merge_bb)
  builder.setInsertPoint(else_bb)
  let _ = builder.createBr(merge_bb)

  // merge块
  builder.setInsertPoint(merge_bb)
  let result_phi = builder.createPHI(f64_ty, name="result")
  result_phi.addIncoming(arg_a, then_bb)
  result_phi.addIncoming(arg_b, else_bb)
  let _ = builder.createRet(result_phi)
  let expect =
    #|define double @max_double(double %0, double %1) {
    #|entry:
    #|  %fcmp_result = fcmp ogt double %0, %1
    #|  br i1 %fcmp_result, label %then, label %else
    #|
    #|then:                                             ; preds = %entry
    #|  br label %merge
    #|
    #|else:                                             ; preds = %entry
    #|  br label %merge
    #|
    #|merge:                                            ; preds = %else, %then
    #|  %result = phi double [ %0, %then ], [ %1, %else ]
    #|  ret double %result
    #|}
    #|
  inspect(max_func, content=expect)
}
```

#### 浮点数比较指令族

浮点数比较指令分为两大类：有序比较（Ordered）和无序比较（Unordered）。有序比较在遇到NaN时返回false，而无序比较在遇到NaN时返回true。

**有序比较指令**：
- `createFCmpOEQ` - 有序等于
- `createFCmpOGT` - 有序大于
- `createFCmpOGE` - 有序大于等于
- `createFCmpOLT` - 有序小于
- `createFCmpOLE` - 有序小于等于
- `createFCmpONE` - 有序不等于
- `createFCmpORD` - 有序（两个操作数都不是NaN）

**无序比较指令**：
- `createFCmpUEQ` - 无序等于
- `createFCmpUGT` - 无序大于
- `createFCmpUGE` - 无序大于等于
- `createFCmpULT` - 无序小于
- `createFCmpULE` - 无序小于等于
- `createFCmpUNE` - 无序不等于

在大多数情况下，我们使用有序比较指令，因为它们的行为更符合数学直觉。

## Switch语句：多路分支的优雅实现

当我们需要根据一个变量的不同值执行不同的代码时，使用嵌套的if-else语句会变得冗长而低效。Switch语句提供了一种更优雅的多路分支解决方案。

让我们实现一个"伪平方"函数，它对特定的输入值返回预定义的结果：

```c
int fake_square(int n) {
  int res;
  switch (n) {
    case 1: res = 1; break;
    case 2: res = 4; break;
    case 3: res = 9; break;
    case 4: res = 16; break;
    default: res = 0; break;
  }
  return res;
}
```

在llvm.mbt中实现这个函数：

```moonbit
///|
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("switch_demo")
  let builder = ctx.createBuilder()

  // 定义函数类型：int fake_square(int n)
  let i32_ty = ctx.getInt32Ty()
  let func_ty = ctx.getFunctionType(i32_ty, [i32_ty])
  let func = mod.addFunction(func_ty, "fake_square")
  let arg_n = func.getArg(0).unwrap()

  // 创建基本块
  let entry_bb = func.addBasicBlock(name="entry")
  let case1_bb = func.addBasicBlock(name="case1")
  let case2_bb = func.addBasicBlock(name="case2")
  let case3_bb = func.addBasicBlock(name="case3")
  let case4_bb = func.addBasicBlock(name="case4")
  let default_bb = func.addBasicBlock(name="default")
  let merge_bb = func.addBasicBlock(name="merge")

  // 创建常量
  let const_1 = ctx.getConstInt32(1)
  let const_2 = ctx.getConstInt32(2)
  let const_3 = ctx.getConstInt32(3)
  let const_4 = ctx.getConstInt32(4)
  let const_16 = ctx.getConstInt32(16)
  let const_0 = ctx.getConstInt32(0)

  // 入口块：创建switch指令
  builder.setInsertPoint(entry_bb)
  let switch_inst = builder.createSwitch(arg_n, default_bb)
  switch_inst.addCase(const_1, case1_bb)
  switch_inst.addCase(const_2, case2_bb)
  switch_inst.addCase(const_3, case3_bb)
  switch_inst.addCase(const_4, case4_bb)

  // 各个case块的实现
  builder.setInsertPoint(case1_bb)
  let _ = builder.createBr(merge_bb)
  builder.setInsertPoint(case2_bb)
  let _ = builder.createBr(merge_bb)
  builder.setInsertPoint(case3_bb)
  let _ = builder.createBr(merge_bb)
  builder.setInsertPoint(case4_bb)
  let _ = builder.createBr(merge_bb)
  builder.setInsertPoint(default_bb)
  let _ = builder.createBr(merge_bb)

  // merge块：使用PHI节点选择结果
  builder.setInsertPoint(merge_bb)
  let result_phi = builder.createPHI(i32_ty, name="result")
  result_phi.addIncoming(const_1, case1_bb) // case 1: return 1
  result_phi.addIncoming(const_4, case2_bb) // case 2: return 4
  result_phi.addIncoming(ctx.getConstInt32(9), case3_bb) // case 3: return 9
  result_phi.addIncoming(const_16, case4_bb) // case 4: return 16
  result_phi.addIncoming(const_0, default_bb) // default: return 0
  let _ = builder.createRet(result_phi)
  let expect =
    #|define i32 @fake_square(i32 %0) {
    #|entry:
    #|  switch i32 %0, label %default [
    #|    i32 1, label %case1
    #|    i32 2, label %case2
    #|    i32 3, label %case3
    #|    i32 4, label %case4
    #|  ]
    #|
    #|case1:                                            ; preds = %entry
    #|  br label %merge
    #|
    #|case2:                                            ; preds = %entry
    #|  br label %merge
    #|
    #|case3:                                            ; preds = %entry
    #|  br label %merge
    #|
    #|case4:                                            ; preds = %entry
    #|  br label %merge
    #|
    #|default:                                          ; preds = %entry
    #|  br label %merge
    #|
    #|merge:                                            ; preds = %default, %case4, %case3, %case2, %case1
    #|  %result = phi i32 [ 1, %case1 ], [ 4, %case2 ], [ 9, %case3 ], [ 16, %case4 ], [ 0, %default ]
    #|  ret i32 %result
    #|}
    #|
  inspect(func, content=expect)
}
```

### Switch指令的特点

Switch指令具有以下重要特性：

1. **条件变量类型限制**：Switch指令的条件变量只能是整数类型（包括i1、i8、i16、i32、i64等）
2. **高效实现**：LLVM会根据case的数量和分布选择最优的实现方式（跳转表、二分查找等）
3. **默认分支**：必须提供一个默认分支，当所有case都不匹配时执行
4. **动态添加**：可以在创建Switch指令后使用`addCase`方法动态添加case分支

## 循环结构：重复执行的艺术

循环是程序中另一个重要的控制流结构。在LLVM中，循环通常通过基本块的巧妙组织来实现。让我们通过一个计算简单对数的例子来理解循环的构建：

```c
int simple_log2(int n) {
  int exp = 0;
  int n2 = 1;
  while (n2 < n) {
    exp = exp + 1;
    n2 = n2 * 2;
  }
  return exp;
}
```

这个函数计算使得2的exp次方小于n的最大exp值。让我们用llvm.mbt实现它：

```moonbit
///|
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("loop_demo")
  let builder = ctx.createBuilder()

  // 定义函数类型：int simple_log2(int n)
  let i32_ty = ctx.getInt32Ty()
  let func_ty = ctx.getFunctionType(i32_ty, [i32_ty])
  let func = mod.addFunction(func_ty, "simple_log2")
  let arg_n = func.getArg(0).unwrap()

  // 创建基本块
  let entry_bb = func.addBasicBlock(name="entry")
  let loop_cond_bb = func.addBasicBlock(name="loop_cond")
  let loop_body_bb = func.addBasicBlock(name="loop_body")
  let loop_merge_bb = func.addBasicBlock(name="loop_merge")

  // 创建常量
  let const_0 = ctx.getConstInt32(0)
  let const_1 = ctx.getConstInt32(1)
  let const_2 = ctx.getConstInt32(2)

  // 入口块：初始化变量
  builder.setInsertPoint(entry_bb)
  let _ = builder.createBr(loop_cond_bb)

  // 循环条件块：检查循环条件
  builder.setInsertPoint(loop_cond_bb)
  let exp_phi = builder.createPHI(i32_ty, name="exp")
  let n2_phi = builder.createPHI(i32_ty, name="n2")

  // 设置PHI节点的incoming值
  exp_phi.addIncoming(const_0, entry_bb)
  n2_phi.addIncoming(const_1, entry_bb)

  // 检查循环条件：n2 < n
  let loop_cond = builder.createICmpSLT(n2_phi, arg_n, name="cond")
  let _ = builder.createCondBr(loop_cond, loop_body_bb, loop_merge_bb)

  // 循环体：更新变量
  builder.setInsertPoint(loop_body_bb)
  let exp_inc = builder.createAdd(exp_phi, const_1, name="exp_inc")
  let n2_mul = builder.createMul(n2_phi, const_2, name="n2_mul")

  // 添加循环体到PHI节点的incoming值
  exp_phi.addIncoming(exp_inc, loop_body_bb)
  n2_phi.addIncoming(n2_mul, loop_body_bb)
  let _ = builder.createBr(loop_cond_bb)

  // 循环退出块：返回结果
  builder.setInsertPoint(loop_merge_bb)
  let _ = builder.createRet(exp_phi)
  let expect =
    #|define i32 @simple_log2(i32 %0) {
    #|entry:
    #|  br label %loop_cond
    #|
    #|loop_cond:                                        ; preds = %loop_body, %entry
    #|  %exp = phi i32 [ 0, %entry ], [ %exp_inc, %loop_body ]
    #|  %n2 = phi i32 [ 1, %entry ], [ %n2_mul, %loop_body ]
    #|  %cond = icmp slt i32 %n2, %0
    #|  br i1 %cond, label %loop_body, label %loop_merge
    #|
    #|loop_body:                                        ; preds = %loop_cond
    #|  %exp_inc = add i32 %exp, 1
    #|  %n2_mul = mul i32 %n2, 2
    #|  br label %loop_cond
    #|
    #|loop_merge:                                       ; preds = %loop_cond
    #|  ret i32 %exp
    #|}
    #|
  inspect(func, content=expect)
}
```

### 循环结构的组成

LLVM中的循环通常由三个基本块组成：

1. **条件块（loop_cond）**：检查循环条件，决定是继续循环还是退出
2. **循环体块（loop_body）**：执行循环体内的操作
3. **合并块（loop_merge）**：循环退出后的汇合点

### PHI节点在循环中的作用

在循环结构中，PHI节点扮演着至关重要的角色。它们用于表示在不同迭代中变化的变量。在我们的例子中：

- `exp_phi`表示循环变量`exp`，初始值为0，每次迭代增加1
- `n2_phi`表示循环变量`n2`，初始值为1，每次迭代乘以2

PHI节点的incoming值来自两个源：
- 从entry块来的初始值
- 从loop_body块来的更新值

这种设计完美地符合了SSA形式的要求，同时清晰地表达了循环中变量的演化过程。

## 控制流的组织原则

通过本章的学习，我们可以总结出LLVM中控制流组织的几个重要原则：

### 1. 基本块的单入口单出口特性

每个基本块只能有一个入口点（第一条指令）和一个出口点（终结指令）。这种设计简化了控制流分析和优化。

### 2. 终结指令的必要性

每个基本块都必须以终结指令结束，包括：
- `ret` - 函数返回
- `br` - 无条件分支
- `br` with condition - 条件分支
- `switch` - 多路分支

### 3. PHI节点的放置规则

PHI节点必须出现在基本块的开始处，在任何其他指令之前。它们用于处理来自不同前驱基本块的值合并。

### 4. 支配关系与SSA形式

在SSA形式中，每个值的定义必须支配其所有使用。这意味着在控制流图中，定义点必须在所有使用点的必经路径上。

## 最佳实践与性能考虑

在构建控制流时，有几个重要的最佳实践值得注意：

### 1. 合理组织基本块

- 为基本块选择有意义的名称，便于调试和理解
- 避免创建不必要的空基本块
- 合理安排基本块的顺序，有助于代码缓存的局部性

### 2. 高效使用PHI节点

- 只在必要时使用PHI节点
- 确保PHI节点的incoming值和前驱基本块一一对应
- 利用LLVM的mem2reg优化pass来简化变量管理

### 3. 选择合适的比较指令

- 对于整数，根据是否需要考虑符号选择有符号或无符号比较
- 对于浮点数，根据NaN处理需求选择有序或无序比较

## 结语

控制流是程序设计的核心要素，它赋予了程序做出决策和重复执行的能力。通过本章的学习，您已经掌握了在llvm.mbt中构建各种控制流结构的方法，包括条件分支、多路分支和循环。

这些控制流结构的组合使用可以构建出任意复杂的程序逻辑。在下一章中，我们将探讨更高级的LLVM特性，包括函数调用、内存管理和优化技术，这将进一步扩展您构建复杂LLVM程序的能力。

记住，优秀的控制流设计不仅要正确实现功能，还要考虑可读性、可维护性和性能。随着您对LLVM控制流机制理解的深入，您将能够设计出更加优雅和高效的程序结构。
