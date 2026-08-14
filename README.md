# llvm.mbt

[中文说明](#中文说明)

MoonBit bindings for LLVM 22.1.0. The public API follows LLVM's C++ concepts
and naming where practical, and currently supports building LLVM IR, emitting
native object files, and running code with ORC LLJIT.

Current release: **0.5.0** · MoonBit native backend · macOS ARM64 and Linux
x86_64

## Installation

Add the module:

```bash
moon add Kaida-Amethyst/llvm
```

Import the IR package in `moon.pkg`:

```moonbit
import {
  "Kaida-Amethyst/llvm/IR" @llvm,
}
```

Select the native backend in `moon.mod`:

```moonbit
preferred_target = "native"
```

No `LLVM_HOME` or system LLVM installation is required. If installation fails,
see the [installation guide](https://github.com/moonbitlang/llvm.mbt/blob/master/docs/installation.md)
for artifact, cache, and troubleshooting details.

## Example

This example builds and verifies an LLVM function equivalent to
`fn add(lhs, rhs) { lhs + rhs }`:

```mbt check
///|
test "build an integer addition function" {
  let ctx = @llvm.Context::new()
  let mod = ctx.addModule("example")
  let builder = ctx.createBuilder()
  let i32_ty = ctx.getInt32Ty()
  let function_ty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
  let function = mod.addFunction(function_ty, "add")
  let entry = function.addBasicBlock(name="entry")
  guard function.getArg(0) is Some(lhs) else {
    fail("missing lhs")
  }
  guard function.getArg(1) is Some(rhs) else {
    fail("missing rhs")
  }
  builder.setInsertPoint(entry)
  let sum = builder.createAdd(lhs, rhs, name="sum")
  builder.createRet(sum) |> ignore
  mod.verify()
  inspect(
    function,
    content=(
      #|define i32 @add(i32 %0, i32 %1) {
      #|entry:
      #|  %sum = add i32 %0, %1
      #|  ret i32 %sum
      #|}
      #|
    ),
  )
}
```

## Packages

- `Kaida-Amethyst/llvm/IR` provides types, values, modules, IR construction,
  verification, bitcode output, target machines, and native object emission.
- `Kaida-Amethyst/llvm/JIT` provides host-only ORC LLJIT. Its address conversion
  and unload rules are documented in [JIT/README.md](JIT/README.md).
- `internal/raw` contains the direct LLVM-C bindings used to implement the
  public API. It cannot be imported by downstream modules.

MoonBit objects own the corresponding LLVM resources. Operations that remove
IR or unload JIT code have additional lifetime requirements documented on the
relevant APIs.

## Examples

- [MiniMoonBit](examples/minimoonbit/README.md) is a larger compiler example.
  Its test suite compiles 124 programs to native objects, links them, runs them,
  and checks their output.
- [Kaleidoscope](examples/kaleidoscope/README.md) implements the LLVM tutorial
  language with a lexer, parser, code generator, ORC JIT, and readline REPL.

Both examples are independent MoonBit modules, so their `async`, `either`, and
`readline` dependencies are not dependencies of `Kaida-Amethyst/llvm`.

## Requirements

`llvm.mbt` supports the MoonBit native backend on these hosts:

| Host | Minimum version |
| --- | --- |
| macOS ARM64 | macOS 11 |
| Linux x86_64 | glibc 2.31 |

Node.js and a native C/C++ toolchain available as `cc` must be in `PATH`.
`build.js` downloads and verifies the LLVM artifact selected for the host, then
caches it under `$MOON_HOME/cache/lib/Kaida-Amethyst/llvm.mbt`. See the
[installation guide](https://github.com/moonbitlang/llvm.mbt/blob/master/docs/installation.md)
for details.

## Project status

Version 0.5.0 focuses on IR construction, native object emission, and host JIT.
Optimization passes and debug information are not exposed yet; PassBuilder and
DIBuilder are the next two major areas. Other LLVM APIs will be added as
compiler projects require them.

## Development

```bash
moon info
moon fmt
moon check --target native
moon test --target native
```

llvm.mbt is licensed under the Apache License 2.0.

---

# 中文说明

[English](#llvmbt)

llvm.mbt 是 LLVM 22.1.0 的 MoonBit binding。公开 API 在适合的地方沿用 LLVM
C++ 的概念和命名，目前支持构造 LLVM IR、生成 native object，以及通过 ORC
LLJIT 运行生成的代码。

当前版本：**0.5.0** · MoonBit native backend · macOS ARM64 和 Linux x86_64

## 安装

添加模块：

```bash
moon add Kaida-Amethyst/llvm
```

在 `moon.pkg` 中导入 IR package：

```moonbit
import {
  "Kaida-Amethyst/llvm/IR" @llvm,
}
```

在 `moon.mod` 中选择 native backend：

```moonbit
preferred_target = "native"
```

不需要设置 `LLVM_HOME`，也不需要安装系统 LLVM。如果安装失败，可以查看
[安装说明](https://github.com/moonbitlang/llvm.mbt/blob/master/docs/installation.md)，
其中包含 LLVM 产物、缓存和排障信息。

## 示例

下面的例子构造并验证一个等价于 `fn add(lhs, rhs) { lhs + rhs }` 的 LLVM
函数：

```mbt check
///|
test "构造整数加法函数" {
  let ctx = @llvm.Context::new()
  let mod = ctx.addModule("example")
  let builder = ctx.createBuilder()
  let i32_ty = ctx.getInt32Ty()
  let function_ty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
  let function = mod.addFunction(function_ty, "add")
  let entry = function.addBasicBlock(name="entry")
  guard function.getArg(0) is Some(lhs) else {
    fail("缺少 lhs")
  }
  guard function.getArg(1) is Some(rhs) else {
    fail("缺少 rhs")
  }
  builder.setInsertPoint(entry)
  let sum = builder.createAdd(lhs, rhs, name="sum")
  builder.createRet(sum) |> ignore
  mod.verify()
  inspect(
    function,
    content=(
      #|define i32 @add(i32 %0, i32 %1) {
      #|entry:
      #|  %sum = add i32 %0, %1
      #|  ret i32 %sum
      #|}
      #|
    ),
  )
}
```

## Packages

- `Kaida-Amethyst/llvm/IR` 提供类型、值、Module、IR 构造、验证、bitcode 输出、
  TargetMachine 和 native object emission。
- `Kaida-Amethyst/llvm/JIT` 提供 host-only ORC LLJIT。地址转换和卸载规则见
  [JIT/README.md](JIT/README.md)。
- `internal/raw` 存放实现公开 API 所使用的直接 LLVM-C binding，下游模块不能
  导入它。

MoonBit 对象拥有对应的 LLVM 资源。删除 IR 或卸载 JIT 代码的操作还有额外的
生命周期要求，相关 API 文档会明确说明这些要求。

## 示例项目

- [Kaleidoscope](examples/kaleidoscope/README.md) 实现了 LLVM 教程语言，包含
  lexer、parser、codegen、ORC JIT 和 readline REPL。
- [MiniMoonBit](examples/minimoonbit/README.md) 实现了一个MoonBit语言子集，包含函数定义，闭包，结构体，枚举类型等等，可以编译有一定复杂程度的程序，例如svd分解，光线追踪等等。

## 环境要求

llvm.mbt 在以下宿主平台支持 MoonBit native backend：

| 宿主平台 | 最低版本 |
| --- | --- |
| macOS ARM64 | macOS 11 |
| Linux x86_64 | glibc 2.31 |

`PATH` 中需要存在 Node.js 和可通过 `cc` 调用的 native C/C++ 工具链。
`build.js` 会下载并验证当前宿主平台对应的 LLVM 产物，然后将其缓存在
`$MOON_HOME/cache/lib/Kaida-Amethyst/llvm.mbt`。详细过程见
[安装说明](https://github.com/moonbitlang/llvm.mbt/blob/master/docs/installation.md)。

## 项目状态

0.5.0 主要覆盖 IR 构造、native object emission 和 host JIT。目前还没有公开
优化 pass 和调试信息接口；PassBuilder 与 DIBuilder 是接下来的两个主要方向。
其他 LLVM API 会根据实际编译器项目的需要逐步补充。

## 开发

```bash
moon info
moon fmt
moon check --target native
moon test --target native
```

llvm.mbt 使用 Apache License 2.0。
