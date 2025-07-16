# 第4章：函数调用

在前面的章节中，我们学习了如何构建单个函数的内部逻辑，包括基本运算、变量操作和控制流。然而，现实中的程序很少只包含一个函数。函数调用是程序模块化设计的基础，它允许我们将复杂的问题分解为更小、更易管理的部分。

本章将介绍LLVM中函数调用的实现方法，包括函数声明、直接调用以及通过函数指针的间接调用。虽然函数调用的概念相对简单，但它是构建大型程序的关键机制。

## 函数声明与定义

在LLVM中，我们需要区分函数的声明和定义：

- **函数声明**：只指定函数的签名（名称、参数类型、返回类型），不提供实现
- **函数定义**：包含函数的完整实现，包括函数体

让我们通过一个经典的例子来理解这个概念：

```c
int print_int(int);  // 函数声明

int add(int a, int b) {  // 函数定义
  return a + b;
}

int main() {  // 函数定义
  int a = 42;
  int b = 33;
  int res = add(a, b);
  print_int(res);
  return 0;
}
```

在这个例子中，`print_int`只有声明而没有定义，这意味着它的实现将在链接时提供。让我们用llvm.mbt来实现这个程序：

```moonbit
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("function_call_demo")
  let builder = ctx.createBuilder()

  let i32_ty = ctx.getInt32Ty()

  // 声明外部函数 print_int
  let print_int_ty = ctx.getFunctionType(i32_ty, [i32_ty])
  let print_int_func = mod.addFunction(print_int_ty, "print_int")

  // 定义 add 函数
  let add_ty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
  let add_func = mod.addFunction(add_ty, "add")
  let add_bb = add_func.addBasicBlock(name="entry")
  let add_a = add_func.getArg(0).unwrap()
  let add_b = add_func.getArg(1).unwrap()

  builder.setInsertPoint(add_bb)
  let sum = builder.createAdd(add_a, add_b, name="sum")
  let _ = builder.createRet(sum)

  // 定义 main 函数
  let main_ty = ctx.getFunctionType(i32_ty, [])
  let main_func = mod.addFunction(main_ty, "main")
  let main_bb = main_func.addBasicBlock(name="entry")

  builder.setInsertPoint(main_bb)
  let const_42 = ctx.getConstInt32(42)
  let const_33 = ctx.getConstInt32(33)
  let const_0 = ctx.getConstInt32(0)

  // 调用 add 函数
  let res = builder.createCall(add_func, [const_42, const_33], name="res")
  
  // 调用 print_int 函数
  let _ = builder.createCall(print_int_func, [res])
  
  let _ = builder.createRet(const_0)

  let expect = 
    #|; ModuleID = 'function_call_demo'
    #|source_filename = "function_call_demo"
    #|target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
    #|
    #|declare i32 @print_int(i32)
    #|
    #|define i32 @add(i32 %0, i32 %1) {
    #|entry:
    #|  %sum = add i32 %0, %1
    #|  ret i32 %sum
    #|}
    #|
    #|define i32 @main() {
    #|entry:
    #|  %res = call i32 @add(i32 42, i32 33)
    #|  %0 = call i32 @print_int(i32 %res)
    #|  ret i32 0
    #|}
    #|

  inspect(mod, content=expect)
}
```

### 关键API详解

#### 1. addFunction - 函数声明与定义

`addFunction`方法用于在模块中添加函数。它接受函数类型和函数名，返回一个函数对象：

```moonbit skip
let func = mod.addFunction(function_type, "function_name")
```

- 如果不为函数添加基本块，它就是一个声明
- 如果添加了基本块和指令，它就是一个定义

#### 2. createCall - 函数调用

`createCall`方法用于生成函数调用指令：

```moonbit skip
let result = builder.createCall(function, arguments, name="result")
```

- `function`：要调用的函数对象
- `arguments`：参数数组，必须与函数签名匹配
- 返回值：如果函数有返回值，则返回调用结果

## 外部函数链接

在上面的例子中，`print_int`函数只有声明而没有定义。在实际应用中，我们可以提供一个C语言实现：

```c
#include <stdio.h>

int print_int(int n) {
    printf("%d\n", n);
    return 0;
}
```

把上述代码放到main函数里，然后通过命令行输出流输出LLVM IR文本，再编译链接：

```bash
# 生成LLVM IR
moon run main --target native > output.ll

# 编译为目标文件
llc -filetype=obj output.ll -o output.o

# 编译C辅助函数
gcc -c print_helper.c -o print_helper.o

# 链接生成可执行文件
gcc output.o print_helper.o -o final_program

# 运行程序
./final_program  # 输出: 75
```

这种模式在实际开发中非常常见，特别是当我们需要调用系统库函数或已有的C库时。

## 函数指针与间接调用

除了直接调用函数外，LLVM还支持通过函数指针进行间接调用。这在实现回调函数、虚函数表等高级特性时非常有用。

```moonbit
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("function_pointer_demo")
  let builder = ctx.createBuilder()

  let i32_ty = ctx.getInt32Ty()
  let ptr_ty = ctx.getPtrTy()

  // 定义一个简单的函数
  let double_ty = ctx.getFunctionType(i32_ty, [i32_ty])
  let double_func = mod.addFunction(double_ty, "double_value")
  let double_bb = double_func.addBasicBlock(name="entry")
  let double_arg = double_func.getArg(0).unwrap()

  builder.setInsertPoint(double_bb)
  let doubled = builder.createMul(double_arg, ctx.getConstInt32(2), name="doubled")
  let _ = builder.createRet(doubled)

  // 定义一个接受函数指针的函数
  let caller_ty = ctx.getFunctionType(i32_ty, [ptr_ty, i32_ty])
  let caller_func = mod.addFunction(caller_ty, "call_function")
  let caller_bb = caller_func.addBasicBlock(name="entry")
  let func_ptr = caller_func.getArg(0).unwrap()
  let value = caller_func.getArg(1).unwrap()

  builder.setInsertPoint(caller_bb)
  // 通过函数指针调用函数
  let result = builder.createCallPtr(func_ptr, double_ty, [value], name="result")
  let _ = builder.createRet(result)

  let expect = 
    #|; ModuleID = 'function_pointer_demo'
    #|source_filename = "function_pointer_demo"
    #|target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
    #|
    #|define i32 @double_value(i32 %0) {
    #|entry:
    #|  %doubled = mul i32 %0, 2
    #|  ret i32 %doubled
    #|}
    #|
    #|define i32 @call_function(ptr %0, i32 %1) {
    #|entry:
    #|  %result = call i32 %0(i32 %1)
    #|  ret i32 %result
    #|}
    #|

  inspect(mod, content=expect)
}
```

### createCallPtr详解

`createCallPtr`方法用于通过函数指针进行间接调用：

```moonbit skip
let result = builder.createCallPtr(func_pointer, function_type, arguments)
```

- `func_pointer`：指向函数的指针值
- `function_type`：函数的类型签名
- `arguments`：参数数组

这种间接调用机制是实现多态、回调函数和动态分发的基础。

## 函数调用的类型安全

llvm.mbt在设计时特别注重类型安全。`createCall`方法会在编译时检查：

1. **参数数量匹配**：传递的参数数量必须与函数签名一致
2. **参数类型匹配**：每个参数的类型必须与对应的形参类型一致
3. **返回值类型**：调用结果的类型与函数的返回类型一致

这种严格的类型检查有助于在编译时发现错误，避免运行时的类型不匹配问题。

## 最佳实践

在使用函数调用时，建议遵循以下最佳实践：

### 1. 清晰的函数命名
使用描述性的函数名，清楚地表达函数的功能和用途。

### 2. 合理的参数顺序
将最重要或最常用的参数放在前面，保持参数顺序的一致性。

### 3. 适当的函数分解
将复杂的功能分解为多个简单的函数，提高代码的可读性和可维护性。

### 4. 外部函数的文档化
对于只有声明而没有定义的外部函数，应该清楚地文档化其行为和要求。

## 结语

函数调用虽然是一个相对简单的概念，但它是构建模块化程序的基础。通过本章的学习，您已经掌握了：

- 如何声明和定义函数
- 如何使用`createCall`进行直接函数调用
- 如何使用`createCallPtr`进行间接函数调用
- 如何与外部函数进行链接

这些技能将为您在后续章节中学习更复杂的程序结构打下坚实的基础。函数调用机制的掌握是从简单程序向复杂系统过渡的重要一步。
