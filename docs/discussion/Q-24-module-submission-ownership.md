# Q-24. Module 应如何安全提交给 JIT 已解决

> 最后更新日期：2026-08-13
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

`LLVMOrcCreateNewThreadSafeModule` 会取得 `LLVMModuleRef` 所有权，随后 LLJIT 又会取得 ThreadSafeModule 所有权。llvm.mbt 的安全 `Module` 以及由它派生的 Function、BasicBlock、Instruction 可以存在多个别名，当前 owner 会在最后一个别名释放时自动销毁底层 Module。需要确定如何提交 Module，才能避免双重释放、悬空 handle 或大范围 invalidation 改造。

## 问题引发模型

### 问题复现

LLVM 22.1 的 C API 只提供从既有 `LLVMContextRef` 创建 ThreadSafeContext 的 consuming 操作，该操作会取得 Context 所有权；没有从 ThreadSafeContext 取回底层 Context 的 C API。

已经通过临时 C 探针验证另一条路径可行：将原 Module 写入内存 bitcode，在新 LLVMContext 中解析为独立 Module，把新 Context 和新 Module 交给 ORC。原 Module 随后被销毁，JIT 中的函数仍然返回 `42.0`。

### 最小复现例子

若直接把普通 Module 的 raw ref 交给 ORC：

```text
ModuleOwner ──owns──> LLVMModuleRef <──takes ownership── ThreadSafeModule
     │
     └── retained by Function / BasicBlock / Instruction aliases
```

ORC 与 ModuleOwner 将同时认为自己负责销毁同一个 Module。若清空 ModuleOwner 的 raw 字段，所有已有派生 wrapper 又会立即失效；MoonBit 参数传递本身不能证明这些别名不存在。

### 问题分析

`LLVMCloneModule` 不能单独解决问题，因为 clone 仍属于原 LLVMContext；它不能与一个无关的新 ThreadSafeContext 配对。直接把现有 Context 提升为 ThreadSafeContext 虽可实现，但会改变 ContextOwner 的 disposer，并影响该 Context 下所有 Module、Type 和 Constant 的生命周期。

独立 bitcode 快照增加一次序列化与解析，但使 JIT 获得一棵完全独立的 Context/Module 对象图。对于 Kaleidoscope 的小型增量 Module，这一成本预计较低，也不要求修改现有 IR wrapper 的有效性模型。

## 关联问题

1. [Q-08. 派生 IR handle 应如何锚定原生 owner](Q-08-derived-handle-owner-anchors.md)（现有约束：派生对象会保留 ModuleOwner，因此提交不能假设 Module 无别名）
2. [Q-09. 原生 IR handle 失效后安全层应采用什么策略](Q-09-native-ir-handle-invalidation.md)（相关风险：直接消费 Module 会把 moved 状态扩散到整个对象图）
3. [Q-19. Module 初始 triple 与 DataLayout 应采用什么语义](Q-19-module-target-data-layout.md)（配置关系：JIT 提交前需要明确 target 状态由谁写入）
4. [Q-25. LLJIT、已提交 Module 与 ResourceTracker 如何管理生命周期](Q-25-jit-resource-lifecycle.md)（后续依赖：提交产物的所有权模型决定资源句柄设计）
5. [Q-30. JIT 提交应如何处理 Module 验证和 target 配置](Q-30-jit-module-validation-and-target-configuration.md)（后续依赖：决定快照提交时的 verifier 与 DataLayout 契约）

## 建议的解决方案

### A1. 直接消费原 Module，并引入 moved/invalid 状态

#### 方案描述

`addModule` 从 ModuleOwner 取走 raw handle并将其清空。所有 Module 及派生 wrapper 在后续访问时检查 owner 是否已经 moved，并返回错误或终止。

#### 优点

- 不需要复制 IR，最接近 LLVM C++ 移动 `unique_ptr<Module>` 的模型。
- 大型 Module 提交时没有 bitcode round-trip 成本。

#### 缺点

- 必须为几乎所有 IR accessor 和 mutator 建立统一的失效检查。
- MoonBit 的普通值传递无法阻止用户保留 Module 或派生对象别名。
- 公开 API 会新增大量原本只由 eraseFromParent 引发的 invalidation 状态。

### A2. 把现有 ContextOwner 提升为 ThreadSafeContext owner

#### 方案描述

首次 JIT 提交时，将普通 ContextOwner 持有的 LLVMContext 转交给 `LLVMOrcCreateNewThreadSafeContextFromLLVMContext`，随后 ContextOwner 改为通过 ThreadSafeContext 管理底层 Context；提交时再 clone 或移动 Module。

#### 优点

- 可以避免 bitcode 序列化，并让同一 Context 下的 Module 满足 ORC 配对要求。
- 为未来真正的 ThreadSafeContext API 留下基础。

#### 缺点

- 普通 IR Context 的 disposer 和内部状态因一次 JIT 提交永久改变。
- 仍需解决 Module 自身是 clone 还是 move；clone 共享 Context，move 仍有别名失效问题。
- Context 下可能同时存在多个未提交 Module，线程安全语义也不能仅靠换 owner 自动成立。

### A3. 通过 bitcode 建立独立 JIT 快照 【已采纳】

#### 方案描述

`addModule` 借用原 Module，将它序列化到内存 bitcode；内部创建新的 LLVMContext，并在其中解析出独立 Module。只把这份新 Context 和 Module 包装成 ThreadSafeContext/ThreadSafeModule 并交给 LLJIT。

快照提交时如何处理 target triple、DataLayout 和 verifier，由 Q-30 在 Q-20 的显式阶段原则与 LLVM C++ LLJIT 原生行为之间进一步决定。

#### 优点

- 原 Module、Function、BasicBlock 和 Instruction 的所有权及有效性完全不变。
- 提交后修改或销毁原 Module，不影响已经提交的代码。
- 不需要给现有 owner 和全部 IR API 增加 moved 状态。
- JIT 内部对象图的释放责任完全归 ORC，边界清晰。

#### 缺点

- 每次提交增加 bitcode 序列化、内存分配和解析成本。
- bitcode 解析失败需要新增明确的错误路径和临时资源清理测试。
- 不适合以后追求极低延迟的大型 Module 提交，可能仍需补充 consuming 高性能接口。

### A4. 公开专用 JIT Context

#### 方案描述

由 LLJIT 创建并拥有专用 Context，用户必须通过该 Context 构造要提交的 Module。安全层从一开始就以 ThreadSafeContext 为底层 owner，再提供 consuming 提交操作。

#### 优点

- 最接近 ORC 的原生数据模型，可以避免 bitcode round-trip。
- JIT Module 从构造开始就满足 Context 配对要求。

#### 缺点

- 用户不能把任意现有 Module 直接提交，降低与当前 IR API 的可组合性。
- 仍需解决提交后 Module 及派生别名如何失效。
- 会引入第二种 Context 构造和生命周期语义，首期公开面更大。

## 最终采用方案

A3. 通过 bitcode 建立独立 JIT 快照
