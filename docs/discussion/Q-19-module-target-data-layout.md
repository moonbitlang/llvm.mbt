# Q-19. Module 初始 triple 与 DataLayout 应采用什么语义 已解决

> 最后更新日期：2026-08-12
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

`Context::addModule()` 当前会自动调用 `Module::setDefaultDataLayout()`，但该方法使用一个硬编码 layout，既不是通用默认值，也不能代表当前 macOS ARM64 宿主。Native object emission 需要决定新 Module 是否应带有预设 target layout。

## 问题引发模型

### 问题复现

当前创建 Module 后会得到：

```text
e-m:e-i64:64-f80:128-n8:16:32:64-S128
```

该 layout 包含 x86 `f80` 等假设，但项目当前同时支持 macOS ARM64 artifact 和 CI。在由 AArch64 TargetMachine 输出 object 时，Module 的初始 layout 与真实 target 冲突。

### 问题分析

Target triple 和 DataLayout 属于 code-generation target，不属于 Context 或通用 Module 的属性。只有 TargetMachine 或调用者的明确 target 配置能给出可靠 layout。

即使后续 `configureModule` 会覆盖硬编码值，用户仍可能在配置前调用 DataLayout query 并获得错误结果。因此这不只是 emission 内部覆盖顺序问题，而是新 Module 的公开契约问题。

## 关联问题

1. [Q-18. Target、TargetMachine 与 TargetData 应如何建立高层资源模型](Q-18-target-machine-resource-model.md)（依赖：TargetMachine 负责为 Module 提供真实 DataLayout）

## 建议的解决方案

### A1. 保留硬编码 default layout，emission 前再覆盖 【不建议】

#### 方案描述

保留 `Context::addModule()` 当前行为，规定 native emission 必须在输出前用 TargetMachine 重新设置 triple 和 DataLayout。

#### 优点

- 不改变现有 Module 创建行为和依赖该 layout 的测试。
- 只要 emission 路径每次正确覆盖，最终 object 可以使用真实 layout。

#### 缺点

- 新 Module 在配置前已携带错误的 target 事实。
- ARM 宿主上的 layout query 可能在 emission 之前返回 x86 结果。
- `setDefaultDataLayout` 这个名称仍然误导调用者。

### A2. 新 Module 保持 target 未指定，由 TargetMachine 显式配置 【已采纳】

#### 方案描述

`Context::addModule()` 不再调用 `setDefaultDataLayout()`，新 Module 的 target triple 和 DataLayout 保持 LLVM 的未指定状态。进入 target-specific codegen 前，由 `TargetMachine::configureModule()` 同时设置 triple 和来自 TargetMachine 的 DataLayout。

`setDefaultDataLayout()` 应删除或废弃；如果保留字符串形式的 `Module::setDataLayout()`，其语义仍是由调用者显式指定，不能再作为宿主默认值。

#### 优点

- 新 Module 不会携带与实际 target 矛盾的预设事实。
- 符合 triple/DataLayout 应来自具体 TargetMachine 的语义。
- macOS ARM64 和 Linux x86_64 使用同一条配置路径。

#### 缺点

- 依赖当前隐式 layout 的文档和测试必须改为显式配置。
- 在 target 配置之前进行 layout-dependent query 时，调用者需要理解 Module 尚未具有有效 target layout。

## 最终采用方案

A2. 新 Module 保持 target 未指定，由 TargetMachine 显式配置
