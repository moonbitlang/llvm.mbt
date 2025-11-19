# 第1章：整数与浮点数的基础运算

在前一章中，我们初步接触了llvm.mbt的基本概念，并成功构建了第一个简单的LLVM程序。本章将深入探讨LLVM中两种最基础也是最重要的数据类型：整数和浮点数，以及它们的基础运算操作。通过本章的学习，您将掌握如何使用llvm.mbt构建包含各种算术运算的LLVM程序。

## 核心组件回顾

在开始具体的运算操作之前，让我们首先回顾并深入理解llvm.mbt中的三个核心组件，它们构成了所有LLVM程序构建的基础：

```moonbit skip
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()
}
```

### Context：全局状态管理器

`Context`是LLVM架构中的全局状态管理器，它承担着至关重要的职责。在编译过程中，Context维护着所有的类型信息、常量定义、以及其他全局性的编译状态。可以将Context理解为一个大型的注册表，所有的LLVM对象——无论是类型、常量还是指令——都必须与特定的Context相关联。

在实际应用中，不同的Context之间是完全隔离的，这种设计保证了多线程编译环境下的安全性，也使得同一程序中可以同时处理多个独立的编译单元而不会相互干扰。

### Module：编译单元的载体

`Module`代表了一个完整的编译单元，通常对应于一个源文件或一个独立的库。Module是函数、全局变量、类型定义以及其他顶级构造的容器。在LLVM的设计哲学中，Module是进行链接、优化和代码生成的基本单位。

每个Module都有自己的标识符、目标平台信息和数据布局描述。这种设计使得LLVM能够灵活地处理跨平台编译和模块化编程的需求。

### IRBuilder：指令生成工厂

`IRBuilder`是LLVM中负责生成中间表示（IR）指令的核心工具，可以将其比作一个智能的"指令工厂"。IRBuilder不仅能够创建各种类型的LLVM指令，还会自动处理许多底层细节，如指令的正确插入位置、类型检查等。

IRBuilder维护着一个"插入点"（insertion point）的概念，所有新创建的指令都会被插入到这个位置。通过`setInsertPoint`方法，我们可以精确控制指令在程序中的位置，从而构建出正确的程序逻辑。

## 整数运算：构建算术表达式

现在让我们通过一个具体的例子来探索整数运算。我们将创建一个等价于以下C函数的LLVM程序：

```c
int add42(int a, int b) {
  return a + b + 42;
}
```

这个函数接受两个整数参数，将它们相加，再加上常数42，最后返回结果。让我们看看如何使用llvm.mbt来实现这个功能：

```moonbit
///|
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("arithmetic_demo")
  let builder = ctx.createBuilder()

  // 定义函数类型：接受两个i32参数，返回i32
  let i32_ty = ctx.getInt32Ty()
  let func_ty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])

  // 创建函数
  let add42_func = mod.addFunction(func_ty, "add42")
  let entry_bb = add42_func.addBasicBlock(name="entry")

  // 获取函数参数
  let arg_a = add42_func.getArg(0).unwrap()
  let arg_b = add42_func.getArg(1).unwrap()

  // 开始构建函数体
  builder.setInsertPoint(entry_bb)

  // 执行 a + b
  let sum_ab = builder.createAdd(arg_a, arg_b, name="sum_ab")

  // 创建常数42
  let const_42 = ctx.getConstInt32(42)

  // 执行 (a + b) + 42
  let final_sum = builder.createAdd(sum_ab, const_42, name="final_sum")

  // 返回结果
  let _ = builder.createRet(final_sum)

  // 验证生成的LLVM IR
  let expect =
    #|define i32 @add42(i32 %0, i32 %1) {
    #|entry:
    #|  %sum_ab = add i32 %0, %1
    #|  %final_sum = add i32 %sum_ab, 42
    #|  ret i32 %final_sum
    #|}
    #|
  inspect(add42_func, content=expect)
}
```

### 代码解析

让我们逐步分析这个例子中的关键概念：

1. **类型定义**：`getInt32Ty()`获取32位有符号整数类型，这是最常用的整数类型之一。

2. **函数参数获取**：通过`getArg(index)`方法获取函数的参数值，这些参数可以像普通值一样参与运算。

3. **加法运算**：`createAdd()`方法创建整数加法指令，它要求两个操作数具有相同的整数类型。

4. **常量创建**：`getConstInt32(42)`创建一个32位整数常量，值为42。

5. **指令命名**：为了提高IR的可读性，我们为重要的中间结果指定了有意义的名称。

## 整数类型与运算操作概览

llvm.mbt支持多种整数类型和丰富的运算操作。以下是完整的整数运算能力概览：

### 支持的整数类型

llvm.mbt提供了四种标准整数类型，满足绝大多数编程语言的需求：

- **Int8Type** (8位)：对应C语言中的`char`或`int8_t`
- **Int16Type** (16位)：对应C语言中的`short`或`int16_t`  
- **Int32Type** (32位)：对应C语言中的`int`或`int32_t`
- **Int64Type** (64位)：对应C语言中的`long long`或`int64_t`

相应的类型获取方法为：
```moonbit skip
let i8_ty = ctx.getInt8Ty()
let i16_ty = ctx.getInt16Ty()
let i32_ty = ctx.getInt32Ty()
let i64_ty = ctx.getInt64Ty()
```

#### 设计说明：为什么不支持任意宽度整数？

值得注意的是，原生LLVM实际上支持任意宽度的整数类型，例如可以定义46位或127位的整数。然而，在llvm.mbt的设计中，我们有意地没有包含这个特性。这个决策基于以下考虑：

1. **实用性**：绝大多数前端编程语言只使用标准的8、16、32、64位整数类型
2. **简洁性**：避免API复杂化，专注于最常用的功能
3. **类型安全**：明确的类型定义减少了程序错误的可能性

当然，如果将来有明确的应用需求，我们会考虑添加对任意宽度整数的支持。

### 算术运算操作

llvm.mbt提供了完整的整数算术运算支持：

**基础算术运算：**
- `createAdd()` - 加法运算
- `createSub()` - 减法运算
- `createMul()` - 乘法运算
- `createSDiv()` - 有符号除法
- `createUDiv()` - 无符号除法
- `createSRem()` - 有符号取余
- `createURem()` - 无符号取余

**位运算操作：**
- `createAnd()` - 按位与
- `createOr()` - 按位或
- `createXor()` - 按位异或
- `createNot()` - 按位取反

**位移运算：**
- `createShl()` - 左移
- `createLShr()` - 逻辑右移
- `createAShr()` - 算术右移

## 特殊的布尔类型：Int1Type

在LLVM的类型系统中，存在一种特殊的整数类型——`Int1Type`，它专门用于表示布尔值。这种类型只能存储两个值：`true`（1）和`false`（0）。

```moonbit
///|
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("boolean_demo")
  let builder = ctx.createBuilder()

  // 获取布尔类型
  let i1_ty = ctx.getInt1Ty()

  // 创建布尔常量
  let const_true = ctx.getConstTrue()
  let const_false = ctx.getConstFalse()
  inspect(const_true, content="i1 true")
  inspect(const_false, content="i1 false")

  // 创建一个返回布尔值的函数
  let func_ty = ctx.getFunctionType(i1_ty, [])
  let bool_func = mod.addFunction(func_ty, "get_true")
  let entry_bb = bool_func.addBasicBlock(name="entry")
  builder.setInsertPoint(entry_bb)
  let _ = builder.createRet(const_true)

  // 验证生成的LLVM IR
  let expect =
    #|define i1 @get_true() {
    #|entry:
    #|  ret i1 true
    #|}
    #|
  inspect(bool_func, content=expect)
}
```

`Int1Type`在条件判断、逻辑运算和控制流构建中扮演着重要角色。它是LLVM中所有条件分支指令的基础，我们将在后续章节中详细探讨其应用。

## 浮点数运算：精密计算的艺术

接下来，让我们转向浮点数运算。浮点数在科学计算、图形处理和许多数值应用中都至关重要。我们将通过以下C函数的等价实现来探索浮点数运算：

```c
double add1(double a, double b) {
  return a + b + 1.0;
}
```

```moonbit
///|
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("float_demo")
  let builder = ctx.createBuilder()

  // 定义双精度浮点函数类型
  let f64_ty = ctx.getDoubleTy()
  let func_ty = ctx.getFunctionType(f64_ty, [f64_ty, f64_ty])

  // 创建函数
  let add1_func = mod.addFunction(func_ty, "add1")
  let entry_bb = add1_func.addBasicBlock(name="entry")

  // 获取函数参数
  let arg_a = add1_func.getArg(0).unwrap()
  let arg_b = add1_func.getArg(1).unwrap()

  // 构建函数体
  builder.setInsertPoint(entry_bb)

  // 执行 a + b（注意：使用createFAdd而不是createAdd）
  let sum_ab = builder.createFAdd(arg_a, arg_b, name="sum_ab")

  // 创建浮点常数1.0
  let const_1_0 = ctx.getConstDouble(1.0)

  // 执行 (a + b) + 1.0
  let final_sum = builder.createFAdd(sum_ab, const_1_0, name="final_sum")

  // 返回结果
  let _ = builder.createRet(final_sum)

  // 验证生成的LLVM IR
  let expect =
    #|define double @add1(double %0, double %1) {
    #|entry:
    #|  %sum_ab = fadd double %0, %1
    #|  %final_sum = fadd double %sum_ab, 1.000000e+00
    #|  ret double %final_sum
    #|}
    #|
  inspect(add1_func, content=expect)
}
```

### 关键注意事项：类型特定的运算指令

这里有一个至关重要的概念需要强调：**整数运算和浮点数运算使用完全不同的指令**。

- 整数加法使用`createAdd()`
- 浮点数加法使用`createFAdd()`

这种区分不仅仅是命名上的差异，而是反映了底层硬件处理这两种数据类型的根本性差异。整数运算遵循精确的算术规则，而浮点数运算则需要处理舍入误差、特殊值（如无穷大、NaN）等复杂情况。

错误地使用`createAdd()`来处理浮点数将导致运行时错误。

## 浮点数类型与运算操作

llvm.mbt支持多种精度的浮点数类型和相应的运算操作：

### 支持的浮点数类型

- **FloatType** (32位)：单精度浮点数，对应C语言的`float`
- **DoubleType** (64位)：双精度浮点数，对应C语言的`double`

相应的类型获取方法：
```moonbit skip
let float_ty = ctx.getFloatTy()
let double_ty = ctx.getDoubleTy()
```

### 浮点运算操作

**基础算术运算：**
- `createFAdd()` - 浮点加法
- `createFSub()` - 浮点减法
- `createFMul()` - 浮点乘法
- `createFDiv()` - 浮点除法
- `createFRem()` - 浮点取余
- `createFNeg()` - 浮点取负

**比较运算：**
- `createFCmpOEQ()` - 有序相等比较
- `createFCmpOLT()` - 有序小于比较
- `createFCmpOLE()` - 有序小于等于比较
- `createFCmpOGT()` - 有序大于比较
- `createFCmpOGE()` - 有序大于等于比较

浮点数比较运算相比整数更为复杂，需要处理NaN值的特殊情况，这就是为什么有"有序"（ordered）和"无序"（unordered）比较之分的原因。

## 实践建议

在使用llvm.mbt进行数值计算时，建议遵循以下最佳实践：

1. **明确类型选择**：根据数值范围和精度要求选择合适的类型
2. **注意指令区分**：确保使用正确的运算指令（整数vs浮点数）
3. **合理命名**：为中间结果提供有意义的名称，提高代码可读性
4. **类型一致性**：确保参与运算的操作数类型匹配

## 小结

本章我们深入探讨了llvm.mbt中整数和浮点数的基础运算操作。我们学习了：

1. **核心组件**：Context、Module、IRBuilder的深层含义和作用
2. **整数运算**：从简单的加法开始，掌握了完整的整数运算体系
3. **类型系统**：了解了llvm.mbt的整数类型设计理念
4. **布尔类型**：掌握了特殊的Int1Type及其应用
5. **浮点运算**：学习了浮点数运算的特殊性和重要注意事项

这些基础知识为我们后续学习更复杂的LLVM概念打下了坚实的基础。在下一章中，我们将探讨变量操作，进一步扩展我们的LLVM编程技能。

要查看完整的LLVM IR输出，您可以将任何测试代码放入main函数中，调用`mod.dump()`，然后通过以下命令运行：

```bash
moon run main --target native
```