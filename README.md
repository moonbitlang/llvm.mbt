# llvm.mbt: LLVM 22 bindings for MoonBit

[中文说明](#中文说明)

`llvm.mbt` provides MoonBit bindings to upstream LLVM through the LLVM C API
(`llvm-c`). It offers both a MoonBit-friendly IR construction API and direct
access to lower-level LLVM C interfaces when needed.

The current release is built from unmodified upstream **LLVM 22.1.0** sources
and pinned to an exact artifact. It does not
link against an arbitrary LLVM installation from the user's system.

## Features

- A typed IR-building API for contexts, modules, types, values, functions,
  basic blocks, instructions, attributes, data layouts, bitcode, and the LLVM
  interpreter.
- A managed, host-only ORC LLJIT API that snapshots IR modules, resolves host
  symbols, executes generated code, and explicitly unloads resource groups.
- Module-private low-level bindings for broader `llvm-c` functionality,
  including analysis, bitcode and IR readers/writers, execution engines,
  linking, targets, target machines, and transforms.
- Upstream LLVM code generation targets bundled into each distributed
  artifact.
- A reproducible native dependency: the archive URL, file size, and SHA-256
  digests are fixed in `build.js`.
- A shared cache under `$MOON_HOME/cache/lib/Kaida-Amethyst/llvm.mbt`, so
  MoonBit projects using the same artifact do not download separate LLVM
  copies.

## Requirements and supported hosts

`llvm.mbt` supports the MoonBit **native backend only**.

| Host | Minimum version | Artifact |
| --- | --- | --- |
| macOS ARM64 | macOS 11 | `llvm-22.1.0-r1-macos-arm64` |
| Linux x86_64 | glibc 2.31 | `llvm-22.1.0-r1-linux-x86_64` |

Every native build requires:

- Node.js available in `PATH`, because Moon runs `build.js` with Node.js;
- a normal native C/C++ toolchain available as `cc`.

Filling the cache for the first time additionally requires:

- `tar` with XZ support;
- HTTPS access to the project's GitHub Release.

Other hosts fail with an explicit unsupported-platform error. The build does
not silently fall back to a system LLVM.

## Installation

Add the module dependency:

```bash
moon add Kaida-Amethyst/llvm
```

Import the high-level IR package from the `moon.pkg` of the package that uses
it:

```moonbit
import {
  "Kaida-Amethyst/llvm/IR" @llvm,
}
```

Set the module's preferred target in `moon.mod`:

```moonbit
preferred_target = "native"
```

Then build or test for the native target:

```bash
moon check --target native
moon test --target native
```

No `source env.sh`, `LLVM_HOME`, or system LLVM installation is required.

## How the LLVM dependency is installed

Before a native build, Moon runs this module's `build.js`. The script:

1. selects the artifact matching the host;
2. checks
   `$MOON_HOME/cache/lib/Kaida-Amethyst/llvm.mbt/22.1.0-r1/<platform>/`
   `sha256-<digest>`;
3. downloads the archive from the
   [LLVM 22.1.0 Release](https://github.com/moonbitlang/llvm.mbt/releases/tag/llvm-22.1.0)
   when the cache is absent;
4. verifies the archive SHA-256, extracts it atomically, and verifies the
   manifest and `libLLVM-mbt.a` SHA-256;
5. supplies the include and linker flags to Moon's native build.

If `MOON_HOME` is unset, Moon's usual `~/.moon` directory is used. The
download is approximately 29.3 MiB on macOS ARM64 and 41.2 MiB on Linux
x86_64. The static library occupies approximately 198.8 MiB and 320.4 MiB,
respectively.

## Quick start

The following example builds a function equivalent to
`fn add(lhs, rhs) { lhs + rhs }` and checks the generated LLVM IR:

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

Use `Kaida-Amethyst/llvm/IR` as the supported public API. The direct LLVM-C
bindings live in the module-private `internal/raw` package and cannot be
imported by downstream modules.

## JIT execution

Import `Kaida-Amethyst/llvm/JIT` to run generated code in the current process.
The host-only flow supports independent Module snapshots, cross-Module symbol
resolution, current-process symbols such as `sin`, and explicit resource-group
unloading. See [JIT/README.md](JIT/README.md) for the usage and unsafe calling
contract.

The JIT execution, lookup, ownership, and unload tests establish the runtime
foundation needed to start an `examples/kaleidoscope` implementation. The
example itself, its parser, codegen, and REPL remain separate follow-up work.

## Developing llvm.mbt

```bash
moon check --target native
moon test --target native
moon info
moon fmt
```

- `IR/` contains the higher-level MoonBit API.
- `internal/raw/` contains the module-private LLVM-C bindings and native
  wrapper.
- `build.js` manages the pinned LLVM artifact and shared cache.
- Generated `.mbti` files describe each package's public interface.

This project is licensed under the Apache License 2.0.

---

# 中文说明

[Back to English](#llvmbt-llvm-22-bindings-for-moonbit)

`llvm.mbt` 通过 LLVM C API（`llvm-c`）为 MoonBit 提供上游 LLVM
绑定。它既提供更符合 MoonBit 使用习惯的 IR 构造 API，也允许在需要时直接访问
较底层的 LLVM C 接口。

当前版本使用未经修改的上游 **LLVM 22.1.0** 源码构建，并固定到确定的产物。
它不使用 `llvm-config`，也不会链接用户系统中版本不确定的 LLVM。

## 功能

- 提供带类型的 IR 构造 API，覆盖上下文、模块、类型、值、函数、基本块、指令、
  属性、数据布局、bitcode 和 LLVM 解释器。
- 提供受管理的 host-only ORC LLJIT API，支持 Module 快照、宿主符号解析、
  生成代码执行和资源组显式卸载。
- 模块私有的底层 `llvm-c` binding 覆盖分析、bitcode 与 IR 读写、执行引擎、
  链接、Target、TargetMachine 和变换接口。
- 每个平台的分发产物都包含上游 LLVM 代码生成目标。
- 原生依赖可复现：`build.js` 中固定了压缩包 URL、文件大小和 SHA-256。
- 使用 `$MOON_HOME/cache/lib/Kaida-Amethyst/llvm.mbt` 作为共享缓存；同一台
  机器上的多个 MoonBit 项目不需要分别下载同一份 LLVM。

## 环境要求与支持平台

`llvm.mbt` 目前仅支持 MoonBit 的 **native 后端**。

| 宿主平台 | 最低版本 | 产物 |
| --- | --- | --- |
| macOS ARM64 | macOS 11 | `llvm-22.1.0-r1-macos-arm64` |
| Linux x86_64 | glibc 2.31 | `llvm-22.1.0-r1-linux-x86_64` |

每次 native 构建都需要：

- `PATH` 中存在 Node.js，因为 Moon 使用 Node.js 运行 `build.js`；
- 可通过 `cc` 调用的常规原生 C/C++ 工具链。

第一次填充缓存时还需要：

- 支持 XZ 的 `tar`；
- 能够通过 HTTPS 访问本项目的 GitHub Release。

其他宿主平台会得到明确的不支持错误。构建过程不会静默回退到系统 LLVM。

## 安装

添加模块依赖：

```bash
moon add Kaida-Amethyst/llvm
```

在使用它的 package 对应的 `moon.pkg` 中导入高层 IR package：

```moonbit
import {
  "Kaida-Amethyst/llvm/IR" @llvm,
}
```

在模块的 `moon.mod` 中设置默认目标：

```moonbit
preferred_target = "native"
```

然后使用 native 目标构建或测试：

```bash
moon check --target native
moon test --target native
```

不需要执行 `source env.sh`，也不需要设置 `LLVM_HOME` 或安装系统 LLVM。

## LLVM 依赖如何安装

native 构建开始前，Moon 会运行本模块的 `build.js`。该脚本会：

1. 根据宿主平台选择对应产物；
2. 检查
   `$MOON_HOME/cache/lib/Kaida-Amethyst/llvm.mbt/22.1.0-r1/<platform>/`
   `sha256-<digest>`；
3. 缓存不存在时，从
   [LLVM 22.1.0 Release](https://github.com/moonbitlang/llvm.mbt/releases/tag/llvm-22.1.0)
   下载压缩包；
4. 校验压缩包 SHA-256，原子化解压，并校验清单和
   `libLLVM-mbt.a` 的 SHA-256；
5. 把 include 与链接参数交给 Moon 的 native 构建流程。

如果没有设置 `MOON_HOME`，则使用 Moon 常规的 `~/.moon` 目录。macOS
ARM64 的下载约为 29.3 MiB，Linux x86_64 约为 41.2 MiB；对应静态库分别约占
198.8 MiB 和 320.4 MiB。

## 快速开始

下面的例子构造一个等价于 `fn add(lhs, rhs) { lhs + rhs }` 的函数，并检查
生成的 LLVM IR：

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

`Kaida-Amethyst/llvm/IR` 是受支持的公开 API。直接 LLVM-C binding 位于模块
私有的 `internal/raw` package，下游模块无法导入。

## JIT 执行

导入 `Kaida-Amethyst/llvm/JIT` 可以在当前进程内运行生成的代码。首期
host-only 闭环支持独立 Module 快照、跨 Module 符号解析、`sin` 等当前进程
符号，以及资源组显式卸载。使用流程和 unsafe 调用契约见
[JIT/README.md](JIT/README.md)。

JIT 的执行、lookup、owner 和卸载测试已经建立了开始
`examples/kaleidoscope` 所需的运行时基础；示例本身及其 parser、codegen 和
REPL 留待后续任务实现。

## 开发 llvm.mbt

```bash
moon check --target native
moon test --target native
moon info
moon fmt
```

- `IR/` 存放较高层的 MoonBit API。
- `internal/raw/` 存放模块私有的 LLVM-C binding 与 native wrapper。
- `build.js` 管理固定版本的 LLVM 产物和共享缓存。
- 自动生成的 `.mbti` 文件描述每个 package 的公开接口。

本项目使用 Apache License 2.0。
