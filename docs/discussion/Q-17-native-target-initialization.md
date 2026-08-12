# Q-17. Native target 初始化应显式调用还是由 host TargetMachine 自动完成 已解决

> 最后更新日期：2026-08-12
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

LLVM 在查找宿主 Target 和生成 object 前需要初始化 native target 与 native asm printer。需要决定安全高层 API 是否要把这个全局调用顺序暴露给用户。本问题不讨论 all-target 或 cross-target 初始化。

## 问题引发模型

### 问题分析

LLVM-C 中的 `LLVMInitializeNativeTarget` 会初始化 native TargetInfo、Target 和 TargetMC；`LLVMInitializeNativeAsmPrinter` 则注册对应的 asm printer。它们是 `static inline`，因此 raw 层必须先经由 C adapter 转成真实外部符号。

如果高层要求显式初始化，用户必须遵守：

```text
initializeNative
  -> get host triple
  -> TargetMachine::host/create
```

如果初始化由 `TargetMachine::host()` 内部完成，则该构造器可以自身建立所有前置条件，但与 LLVM C++ 中显式 target selection 的写法不完全一致。

## 关联问题

1. [Q-16. Native object emission 首期应绑定哪些 LLVM-C API](Q-16-native-object-emission-scope.md)（依赖：两种高层方案都需要 Q-16 中的 C adapter）

## 建议的解决方案

### A1. 公开显式 Target::initializeNative 【不建议】

#### 方案描述

高层 API 直接要求用户先调用 native target 与 asm printer 初始化，随后才能构造 host TargetMachine。

#### 优点

- 更接近 LLVM C++ 的显式初始化步骤。
- 初始化时机由应用程序控制。

#### 缺点

- 构造 host TargetMachine 的前置条件无法由类型表达，遗漏调用可能只在 target lookup 时暴露。
- 用户还需正确区分 target、asm printer、asm parser 与 disassembler 初始化。

### A2. TargetMachine::host 自动确保 native 初始化 【不建议】

#### 方案描述

raw `unsafe` 层保留独立初始化函数；安全高层 `TargetMachine::host()` 在查找 Target 前自动调用 native target 和 native asm printer 初始化，并将任一失败映射为 typed error。

#### 优点

- `TargetMachine::host()` 自身建立所有 host codegen 前置条件。
- 不向使用者暴露全局初始化顺序。
- raw 层仍保留与 LLVM-C 对应的显式能力。

#### 缺点

- 构造 TargetMachine 时包含了一次不明显的全局 registry 初始化。
- 以后引入 cross-target 时，仍需要单独设计 all-target 或指定 target 初始化接口。

### A3. 公开分层初始化，并让 host convenience 自动确保前置条件 【已采纳】

#### 方案描述

同时保留显式与自动两条路径，但让二者共用同一个初始化实现：

1. raw `unsafe` 层保留与 LLVM-C 对应的 native target 和 native asm printer C adapter。LLVM C++ 中对应的是 namespace 函数 `llvm::InitializeNativeTarget()` 与 `llvm::InitializeNativeTargetAsmPrinter()`，而不是 `Target` 方法。
2. 安全高层公开一个类似 `TargetRegistry::initializeNativeCodegen()` 的幂等操作，一次建立 host object emission 所需的 TargetInfo、Target、TargetMC 和 asm printer。是否同时初始化 asm parser 由 Q-16 根据 inline asm 支持边界决定。
3. `TargetMachine::host()` 内部调用同一 `initializeNativeCodegen()`，因此普通用户不必手动初始化。调用者即使已经显式初始化，重复调用也不改变结果。
4. 后续 cross-target 不改变 `host()` 语义，而是在 `TargetRegistry` 层并列增加 `initializeAllCodegen()` 或按 target 初始化的能力。

普通 host 路径可以只写：

```moonbit
let machine = TargetMachine::host(options)
```

需要显式控制时则可写：

```moonbit
TargetRegistry::initializeNativeCodegen()
let triple = TargetTriple::host()
let target = TargetRegistry::lookupTarget(triple)
let machine = target.createTargetMachine(triple, options)
```

#### 优点

- 保留与 LLVM C++ 显式 registry 初始化和 Target lookup 相对应的完整路径。
- `TargetMachine::host()` 仍能自行建立前置条件，遗漏初始化不会变成延迟的 runtime 错误。
- 对 AI 生成的代码更宽容：省略显式初始化时 `host()` 仍可工作，重复写出初始化时也不会失败。
- cross-target 以后在同一 `TargetRegistry` 抽象下扩展，不需要重新定义 host 构造器。

#### 缺点

- 同一初始化能力同时存在显式与自动入口，文档需要区分标准 host 用法和高级组合用法。
- `TargetMachine::host()` 仍然包含全局 registry 副作用，只是该副作用被定义为稳定便利接口的契约。
- all-target 与按 target 初始化的链接体积、可用 backend 集合和错误契约仍需要在引入 cross-target 时明确。

## 最终采用方案

A3. 公开分层初始化，并让 host convenience 自动确保前置条件
