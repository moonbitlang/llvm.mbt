# 第0章：初识llvm.mbt

## 前言

在当今快速发展的编程语言生态系统中，编译器基础设施的重要性日益凸显。LLVM（Low Level Virtual Machine）作为现代编译器设计的基石，为无数编程语言提供了强大的代码生成和优化能力。而MoonBit，作为一门新兴的AI原生编程语言，正在为开发者带来全新的编程体验。

本教程将引导您深入了解llvm.mbt——一个专为MoonBit语言设计的LLVM绑定库，它将LLVM的强大功能与MoonBit的类型安全特性完美结合，为您提供一个既安全又高效的编译器开发平台。

## 什么是MoonBit？

MoonBit是一门于2022年诞生的现代编程语言，由ReScript的创始人张宏波领导开发。作为一门"AI原生"的编程语言，MoonBit从设计之初就充分考虑了与人工智能协作编程的场景，为现代软件开发的新模式提供了语言层面的支持。

MoonBit具有以下核心特性：

- **强类型系统**：提供编译时类型安全保证，有效减少运行时错误
- **函数式编程范式**：支持函数式编程的各种特性，如模式匹配、不可变数据结构等
- **AI协作友好**：语言设计充分考虑了与AI工具的协作场景
- **现代语法**：简洁而富有表现力的语法设计

您可以访问MoonBit官方网站 [https://moonbitlang.com](https://moonbitlang.com) 获取更多详细信息。

## 什么是LLVM？

LLVM（Low Level Virtual Machine）是一个开源的编译器基础设施项目，为编程语言的设计和实现提供了一套完整的工具链。LLVM的核心是一个低级虚拟机，它定义了一种名为LLVM IR（Intermediate Representation）的中间表示语言。

LLVM的主要优势包括：

- **模块化设计**：LLVM采用模块化的架构，允许开发者只使用所需的组件
- **强大的优化能力**：内置大量的代码优化算法，能够生成高效的机器代码
- **多平台支持**：支持众多硬件架构和操作系统
- **语言无关性**：为多种编程语言提供统一的后端支持

## llvm.mbt：类型安全的LLVM绑定

llvm.mbt是专为MoonBit语言设计的LLVM绑定库，它将LLVM的强大功能包装在MoonBit的类型安全框架中。与其他语言的LLVM绑定（如Rust的inkwell库或Python的llvmlite库）相比，llvm.mbt具有以下独特优势：

### 类型安全保证

MoonBit的强类型系统为llvm.mbt提供了一定的编译时类型安全保证，有效防止了常见的编程错误：

### C++风格的API设计

llvm.mbt的内部结构对原生C++ LLVM API进行了精心还原，使得有C++背景的开发者能够快速上手：

```moonbit
test {
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("demo")

  let i32_ty = ctx.getInt32Ty()
  let func_ty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
  let _ = mod.addFunction(func_ty, "add")
}
// llvm.mbt (MoonBit风格)
```

对比C++ LLVM API：

```cpp
// C++ LLVM API
LLVMContext ctx;
Module* mod = new Module("demo", ctx);

Type* i32_ty = Type::getInt32Ty(ctx);
FunctionType* func_ty = FunctionType::get(i32_ty, {i32_ty, i32_ty}, false);
Function* add_func = Function::Create(func_ty, Function::ExternalLinkage, "add", mod);
```

可以看出，llvm.mbt在保持API结构相似性的同时，还提供了更加简洁和安全的语法。

### 自动内存管理

与C++需要手动管理内存不同，llvm.mbt利用MoonBit的自动内存管理机制，极大简化了开发过程。

## 环境配置

### 安装MoonBit

根据您的操作系统选择相应的安装方式：

**Linux/macOS:**
```bash
curl -fsSL https://cli.moonbitlang.cn/install/unix.sh | bash
```

**Windows:**
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser; irm https://cli.moonbitlang.cn/install/powershell.ps1 | iex
```

您也可以通过Visual Studio Code插件市场搜索"MoonBit"来安装官方插件，获得完整的IDE支持。

### 安装LLVM

llvm.mbt要求LLVM版本19或更高。

**macOS:**
```bash
brew install llvm@19
```

**Ubuntu/Debian:**
```bash
sudo apt install llvm-19-dev -y
```

**从源码构建（Linux）:**
```bash
git clone --depth 1 https://github.com/llvm/llvm-project.git -b llvmorg-19.0.0
cd llvm-project && mkdir build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE="Release" ../llvm
ninja && sudo ninja install
```

### 验证安装

确认LLVM工具链已正确安装：

```bash
llc --version
llvm-config --version
llvm-config --cflags --ldflags --libs all
```

### 创建MoonBit项目

使用MoonBit命令行工具创建新项目：

```bash
moon new llvm_tutorial
cd llvm_tutorial
```

### 配置项目使用llvm.mbt

首先更新依赖：

```bash
moon update
moon add Kaida-Amethyst/llvm
```

配置构建环境变量：

```bash
export CC_FLAGS="$(llvm-config --cflags)"
export CC_LINK_FLAGS="$(llvm-config --ldflags --libs all) -lpthread -ldl -lm -lstdc++"
export C_INCLUDE_PATH="$(llvm-config --includedir):$C_INCLUDE_PATH"
```

更新项目的`moon.pkg.json`文件：

```json
{
  "import": [
    "Kaida-Amethyst/llvm"
  ],
  "link": {
    "native": {
      "cc-flags": "$CC_FLAGS",
      "cc-link-flags": "$CC_LINK_FLAGS"
    }
  }
}
```

## 第一个LLVM程序

现在，让我们通过一个完整的示例来展示llvm.mbt的使用方法。我们将创建一个简单的LLVM程序，生成以下C函数的等价代码：

```c
int foo() {
  return 42;
}
```

### 编写MoonBit程序

创建文件`main.mbt`：

```moonbit
test {
  // 创建LLVM上下文 - 所有LLVM操作的根
  let ctx = @IR.Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()

  // 定义类型
  let i32_ty = ctx.getInt32Ty()
  let func_ty = ctx.getFunctionType(i32_ty, [])

  // 创建函数
  let foo_func = mod.addFunction(func_ty, "foo")
  let entry_bb = foo_func.addBasicBlock(name="entry")
  
  // 构建函数体
  builder.setInsertPoint(entry_bb)
  let const_42 = ctx.getConstInt32(42)
  let _ = builder.createRet(const_42)

  // 期望的llvm ir
  let expect = 
    #|define i32 @foo() {
    #|entry:
    #|  ret i32 42
    #|}
    #|

  inspect(foo_func, content=expect)
}
```

### 运行程序

将上述的代码copy到moonbit的main函数中，调用`mod.dump()`函数，然后编译并运行MoonBit程序：

```bash
moon run main --target native
```

您将看到如下输出的LLVM IR：

```llvm
; ModuleID = 'demo'
source_filename = "demo"

define i32 @foo() {
entry:
  ret i32 42
}
```

### 编译为汇编代码

将生成的IR保存到文件并编译为汇编，然后使用LLVM工具链编译：

```bash
moon run main --target native > output.ll
llc -filetype=obj output.ll -o output.o
```

### 链接并测试

创建一个C语言的main函数来测试我们生成的代码：

```c
// test_main.c
#include <stdio.h>

int foo();  // 声明我们通过LLVM生成的函数

int main() {
    int result = foo();
    printf("result from llvm.mbt: %d\n", result);
    return 0;
}
```

编译并链接：

```bash
gcc test_main.c output.o -o test_program
./test_program
```

输出结果：

```
result from llvm.mbt: 42
```

## 小结

通过这个简单的示例，我们展示了使用llvm.mbt进行LLVM程序开发的基本流程：

1. **环境准备**：安装MoonBit和LLVM，配置项目依赖
2. **代码生成**：使用llvm.mbt的API创建LLVM IR
3. **编译链接**：使用LLVM工具链生成可执行程序

llvm.mbt为MoonBit开发者提供了一个强大而安全的编译器开发平台。其类型安全的设计、C++风格的API以及自动内存管理特性，使得编写编译器后端变得更加简单和可靠。

在接下来的章节中，我们将深入探讨llvm.mbt的各个方面，包括类型系统、指令生成、控制流构建等高级特性，帮助您掌握现代编译器开发的精髓。
