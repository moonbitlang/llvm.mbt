# llvm.mbt – MoonBit Bindings to LLVM 19

[中文说明 / Chinese Version](#llvmbt--moonbit-到-llvm-19-的官方绑定)

`llvm.mbt` provides MoonBit bindings to **upstream LLVM 19**, using the C API (`llvm-c`).  
It lets you call **real LLVM** from MoonBit, giving you access to:

- Upstream optimizations and passes
- Full platform and target support provided by LLVM
- The mature LLVM toolchain ecosystem

If you need a **tiny, fast, highly‑readable “mini LLVM” in pure MoonBit** (including Wasm/JS), check out [MoonLLVM](https://github.com/moonbitlang/MoonLLVM).  
The two projects are designed to be **complementary**, not competitors.

---

## Project Goals

- Provide idiomatic MoonBit bindings to LLVM 19 via `llvm-c`.
- Stay as close as reasonable to the original LLVM C++ API design.
- Serve as the “official bridge” between MoonBit code and the LLVM ecosystem.
- Work well together with [MoonLLVM](https://github.com/moonbitlang/MoonLLVM), a pure‑MoonBit “Tiny LLVM” implementation.

With `llvm.mbt`, you are using the **real LLVM implementation**:

- Same optimization passes
- Same codegen
- Same bitcode format
- Same platform coverage

---

## Installation (MoonBit)

`llvm.mbt` currently works with the **MoonBit native backend only**.

1. Add the dependency to your project:

   ```bash
   moon update
   moon add Kaida-Amethyst/llvm
   ```

2. In your project’s `moon.mod.json`, make sure the preferred target is set to `native`:

   ```jsonc
   {
     // ...
     "preferred-target": "native"
   }
   ```

   `llvm.mbt` relies on the native LLVM library, so it cannot run on non‑native targets (such as Wasm/JS) at the moment.

---

## Relationship to MoonLLVM

[MoonLLVM](https://github.com/moonbitlang/MoonLLVM) is a separate project that:

- Re‑implements a subset of LLVM’s data structures and IR‑building APIs in pure MoonBit.
- Can be compiled to Native, Wasm, and JavaScript.
- Is intentionally **smaller, faster to start, and easier to read** than full LLVM.

The two projects are complementary:

- Use **`llvm.mbt`** when you need full upstream LLVM power in MoonBit.
- Use **MoonLLVM** when you want:
  - a lightweight, highly‑readable LLVM‑style implementation,
  - or to run LLVM‑style IR tooling in the browser / embedded environments,
  - or to study LLVM’s internal ideas in a cleaner, MoonBit‑friendly codebase.

---

## When to Use Which?

- **Use `llvm.mbt` when:**
  - You need full upstream LLVM power (all targets, all optimizations).
  - You want to integrate with existing LLVM‑based toolchains and environments.
  - You care about matching upstream LLVM behavior as closely as possible for production use.

- **Use [MoonLLVM](https://github.com/moonbitlang/MoonLLVM) when:**
  - You want a lightweight, pure‑MoonBit implementation for IR experiments.
  - You need to run in environments where full LLVM is too heavy (e.g., browser / Wasm / tiny embedded systems).
  - You prioritize readability, teaching, and research of LLVM’s concepts.

---

## Features

- **LLVM 19 support via `llvm-c`**
- **MoonBit‑style APIs** that still closely resemble LLVM C++/C APIs
- **Native backend only:**  
  Because `llvm.mbt` calls directly into the native LLVM library, it currently works with MoonBit’s native backend (not Wasm/JS).

---

## Setup and Usage

> Note: The project assumes you have LLVM 19 (with `llvm-c`) available in your environment.

### Environment

First, configure your environment variables:

```bash
source env.sh
```

This script sets up the paths and variables needed to locate LLVM and related libraries.

---

## Special Files

- `env.sh`  
  Environment configuration script.  
  You must run `source env.sh` in your shell before building/running the project for the first time.

- `*.mbti`  
  Files ending with `.mbti` contain function signature information available to the project.

---

## Learning & Ecosystem

If you want to explore LLVM from MoonBit:

- Use **`llvm.mbt`** when you need real LLVM 19 capabilities and full toolchain integration.
- And if you ever need to:
  - run LLVM‑style tooling in the browser or embedded environments, or  
  - learn LLVM’s internal ideas in a smaller, well‑documented codebase,  

  then definitely take a look at **[MoonLLVM](https://github.com/moonbitlang/MoonLLVM)** — a tiny, friendly LLVM companion written in pure MoonBit (●'◡'●)

---

# llvm.mbt – MoonBit 到 LLVM 19 的官方绑定

> [Back to English](#llvmbt--moonbit-bindings-to-llvm-19)

`llvm.mbt` 为 **LLVM 19** 提供了 MoonBit 语言的 binding，底层通过 `llvm-c` 接口调用真 LLVM。  
这意味着：

- 你在 MoonBit 中使用的是**官方 LLVM 本体**；
- 可以直接享受 LLVM 提供的各种优化、Pass、目标平台支持；
- 与现有 LLVM 工具链（`opt`, `llc`, `clang` 等）天然兼容。

如果你需要一个**纯 MoonBit 实现、轻量级、易读易改的「迷你 LLVM」**，可以看看 [MoonLLVM](https://github.com/moonbitlang/MoonLLVM)（支持 Native / Wasm / JS）。  
这两个项目是**互补关系**，不是互相取代。

---

## 项目目标

- 通过 `llvm-c` 提供对 LLVM 19 的 MoonBit 绑定；
- 在保持 MoonBit 习惯用法的同时，尽量贴近原版 LLVM C++ API 的设计；
- 成为 MoonBit 与 LLVM 生态之间的「官方桥梁」；
- 与 [MoonLLVM](https://github.com/moonbitlang/MoonLLVM)（纯 MoonBit Tiny LLVM）良好协作。

使用 `llvm.mbt`，本质上就是在使用 **真·LLVM**：

- 同样的优化 Pass；
- 同样的后端代码生成；
- 同样的 bitcode 格式和平台支持。

---

## 安装（MoonBit）

`llvm.mbt` 目前**只能**在 MoonBit 的 **native 后端** 上使用。

1. 在项目中添加依赖：

   ```bash
   moon update
   moon add Kaida-Amethyst/llvm
   ```

2. 在项目根目录的 `moon.mod.json` 中，确保设置：

   ```jsonc
   {
     // ...
     "preferred-target": "native"
   }
   ```

   由于 `llvm.mbt` 依赖本地 LLVM 库，因此目前无法在非 native 目标（如 Wasm / JS）上运行。

---

## 与 MoonLLVM 的关系

[MoonLLVM](https://github.com/moonbitlang/MoonLLVM) 是一个独立项目，它：

- 用 MoonBit 重写了 LLVM 的部分数据结构和 IR 构造流程；
- 可以被编译到 Native / Wasm / JavaScript；
- 刻意做得**更小、更快、更易读**，适合教学与实验。

两者是互补关系：

- 需要真 LLVM 的全部能力时，用 **`llvm.mbt`**；
- 当你希望：
  - 在浏览器 / 嵌入式环境中运行 LLVM 风格的 IR 工具，
  - 或者在更小、更易读的代码库中研究 LLVM 的内部设计，

  那么不妨看看 **[MoonLLVM](https://github.com/moonbitlang/MoonLLVM)**，一个用纯 MoonBit 写成的轻量 LLVM 小伙伴 (๑>◡<๑)

---

## 什么时候用哪个？

- **推荐使用 `llvm.mbt` 的场景：**
  - 需要 LLVM 提供的完整优化能力；
  - 需要广泛的平台/目标支持；
  - 需要和已有的 LLVM 工具链深度集成；
  - 面向生产环境，希望最大程度贴近 upstream LLVM 行为。

- **推荐使用 [MoonLLVM](https://github.com/moonbitlang/MoonLLVM) 的场景：**
  - 需要一个体积小、启动快、可读性高的 IR 实验平台；
  - 需要在浏览器 / Wasm / 小型嵌入式环境中运行；
  - 用于教学、研究或快速原型开发，希望更容易读懂源代码。

---

## 特性概览

- **基于 `llvm-c` 的 LLVM 19 支持**
- **MoonBit 风格 API**，但整体结构尽量贴近 LLVM C/C++ API
- **仅支持 MoonBit 的 Native 后端：**  
  因为 `llvm.mbt` 依赖本地 LLVM 库，所以目前使用场景聚焦在 native 环境。

---

## 环境配置与命令

> 提示：请确保你的系统已经安装好了 LLVM 19，并可通过 `llvm-c` 头文件和库访问。

### 环境配置

首次使用时，请先执行：

```bash
source env.sh
```

该脚本会设置必要的环境变量，确保编译和运行时可以找到 LLVM 及相关库。

---

## 特殊文件说明

- `env.sh`  
  环境变量配置脚本。终端中首次运行项目前，请务必执行：

  ```bash
  source env.sh
  ```

- `*.mbti`  
  所有以 `.mbti` 结尾的文件存放了可用的函数签名信息。

---

## 学习与生态

如果你希望在 MoonBit 中更轻松地学习和探索 LLVM：

- 当你需要真 LLVM 的全部能力和工具链时，用 **`llvm.mbt`**；
- 当你希望在浏览器、嵌入式环境中运行 LLVM 风格 IR，或者在一个更小、更易懂的代码库里研究 LLVM 内部原理时，欢迎看看 **[MoonLLVM](https://github.com/moonbitlang/MoonLLVM)** —— 一个轻量、亲切的 LLVM 小伙伴 (●'◡'●)

也欢迎你在 issue / PR 里分享你的使用体验和建议。
