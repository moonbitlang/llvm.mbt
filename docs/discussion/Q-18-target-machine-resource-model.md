# Q-18. Target、TargetMachine 与 TargetData 应如何建立高层资源模型 已解决

> 最后更新日期：2026-08-12
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

Native object emission 会同时接触 registry-owned `LLVMTargetRef`、独立 owner `LLVMTargetMachineRef` 和可临时创建的 `LLVMTargetDataRef`。需要决定首期应向安全 `IR` 包公开哪些对象，以及它们是否形成长期 owner anchor。

## 问题引发模型

### 问题分析

三种 handle 的 LLVM 所有权不同：

| Handle | 来源 | 释放责任 | 与 Module 的关系 |
|---|---|---|---|
| `LLVMTargetRef` | LLVM TargetRegistry | 无，是进程级 borrowed entry | Module 不持有 |
| `LLVMTargetMachineRef` | `LLVMCreateTargetMachine` | `LLVMDisposeTargetMachine` | emit 调用期间 borrow Module |
| `LLVMTargetDataRef` | `LLVMCreateTargetDataLayout` | `LLVMDisposeTargetData` | `LLVMSetModuleDataLayout` 把 layout 值复制进 Module |

因此 TargetMachine 可以使用一个不带 parent 的 managed external owner，finalizer 只调用 `LLVMDisposeTargetMachine`。Module 配置后不需要强持有 TargetMachine，也不需要使现有 module-owned `IR::DataLayout` 变成 TargetMachine-owned view。

## 关联问题

1. [Q-07. Context 与 Module 的回收策略](Q-07-context-module-reclamation.md)（类比与约束：TargetMachine 也需要 finalizer-only owner，但不存在 Context/Module parent 关系）
2. [Q-16. Native object emission 首期应绑定哪些 LLVM-C API](Q-16-native-object-emission-scope.md)（依赖：owner 与临时 layout 需要 disposer 绑定）

## 建议的解决方案

### A1. 首期公开 Target、TargetMachineOptions 与 owned TargetData

#### 方案描述

按 LLVM-C 建模公开 `Target`、`TargetMachineOptions`、`TargetMachine` 和独立 owned `TargetData`，由用户手动组合 triple lookup、options、machine 和 Module DataLayout。

#### 优点

- 接近 LLVM-C 的可组合能力，也为 cross-target 提前建立类型。
- 独立 TargetData 可以在不创建 Module 时执行 layout query。

#### 缺点

- 需要同时冻结多个公开 owner 和构造顺序。
- 现有 `IR::DataLayout` 是 Module-anchored view，引入同名独立 owner 后需要重新设计表示与命名。
- 对 host-only object emission 而言，Target 和 TargetData 都只是构造过程中的中间对象。

### A2. 首期只公开 managed TargetMachine 【不建议】

#### 方案描述

公开 `TargetMachine::host(...)` 返回由 managed external object 持有的 `TargetMachine`。Target lookup 使用的 `LLVMTargetRef` 保持内部 borrowed；`configureModule` 临时创建 TargetData，设置 Module 后立即释放。

`TargetMachine` 可同时保存构造时的 triple、CPU 和 features 的 MoonBit `String`，用于稳定 accessor 和 Module 配置，不需要重复从 LLVM 取回 owned message。

#### 优点

- 只新增一个长期 native owner，资源图简单。
- Module 配置完成后不依赖 TargetMachine 存活。
- 不需要改变现有 `IR::DataLayout` 的 Module owner anchor。

#### 缺点

- 首期不能直接表达任意 triple 的 Target 查找与独立 TargetData 查询。
- 以后支持 cross-target 时还需要增加更底层的构造 API。

### A3. 公开长期可组合模型，并保留 host convenience 【已采纳】

#### 方案描述

把 LLVM 全局 registry、Target descriptor、TargetMachine 配置与 TargetMachine owner 分成不同层，而不让普通 host 用户手动组合所有 LLVM-C handle：

1. `TargetRegistry` 提供 Q-17 中的全局初始化和 `lookupTarget(triple)`。
2. 公开 `Target` 作为 registry-owned、进程生命期内有效的 borrowed descriptor，不为它建立 disposer 或独立 owner。
3. 公开 `TargetMachineOptions` 作为纯 MoonBit 配置值，表达 CPU、features、ABI、optimization level、relocation mode 与 code model。高层不直接暴露需要释放的 `LLVMTargetMachineOptionsRef`；构造 TargetMachine 时由内部临时创建并释放 raw options。
4. `Target::createTargetMachine(triple, options)` 是通用构造路径，返回由 managed external object 持有的 `TargetMachine`；其 finalizer 只调用 `LLVMDisposeTargetMachine`。
5. `TargetMachine::host(options)` 是建立在上述通用原语上的便利接口：初始化 native codegen、获取 host triple、查找 Target，然后使用 host CPU/features 创建 TargetMachine。
6. cross-target 使用同一 `Target` 和 `TargetMachine` 模型，但不默认继承 host CPU/features；未指定时应使用 target 的 `generic` CPU 与空 features，或要求调用者显式配置。

高层典型路径分别为：

```moonbit
// Host convenience
let machine = TargetMachine::host(options)

// 通用或 cross-target 路径
TargetRegistry::initializeAllCodegen()
let target = TargetRegistry::lookupTarget(triple)
let machine = target.createTargetMachine(triple, options)
```

TargetMachine 与 Module 的所有权关系沿用 A2 中可长期保留的部分：emission 期间 TargetMachine 只 borrow Module，Module 配置后不强持有 TargetMachine。

独立 TargetData/DataLayout 的公开表示不在本方案中直接照搬 LLVM-C owner。首期 `configureModule` 可在内部临时创建 TargetData，将 layout 复制进 Module 后立即释放；未来如果要支持脱离 Module 的 layout query，需要在现有 Module-owned `DataLayout` view 与独立 owned value 之间另行确定类型契约。

#### 优点

- `Target`、通用 TargetMachine 构造与 registry 初始化从一开始就形成可扩展到 cross-target 的长期骨架。
- `TargetMachine::host()` 只是稳定简写，而不是与通用模型竞争的另一套设计。
- 所有权模型仍然只需要一个长期 native owner：`TargetMachine`。
- 高层 options 使用 MoonBit 值而不是 C handle，避免把 LLVM-C 的资源管理形状泄漏到用户 API。
- 不在 native emission 工作中匆忙冻结 owned TargetData 与现有 `DataLayout` view 的关系。

#### 缺点

- 首期公开类型和构造路径多于 A2，需要为 host 与 generic target 的 CPU/features 默认值制定明确契约。
- `TargetRegistry::initializeAllCodegen()` 的 backend 集合、静态链接体积和按 target 初始化策略仍需要单独实现证据。
- 脱离 Module 的 owned DataLayout/TargetData 仍是一个后续公开类型决策。

## 最终采用方案

A3. 公开长期可组合模型，并保留 host convenience
