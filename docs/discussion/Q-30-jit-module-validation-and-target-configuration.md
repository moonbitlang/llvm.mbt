# Q-30. JIT 提交应如何处理 Module 验证和 target 配置 已解决

> 最后更新日期：2026-08-13
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

Q-24 已决定通过 bitcode 建立独立 JIT 快照，但尚未固定 `LLJIT::addModule` 是否隐式运行 verifier，以及快照中的 target triple 和 DataLayout 应由调用者预先配置、由 JIT 覆盖，还是遵循 LLVM C++ LLJIT 的兼容性规则。这会直接影响 `addModule` 的副作用、错误阶段和与 Q-20 的一致性。

## 问题引发模型

### 问题分析

LLVM 22.1 C++ `LLJIT::addIRModule` 不隐式运行 Module verifier。它在内部调用 `applyDataLayout`：若 Module 的 DataLayout 为默认值，则在被提交的 Module 上设置 LLJIT DataLayout；若已经设置但与 LLJIT 不同，则返回 incompatible data layouts 错误。它不强制覆盖 Module target triple。

llvm.mbt 的 `addModule` 提交的是独立 bitcode 快照，因此即使 LLJIT 给快照补充 DataLayout，也不会修改用户原始 Module。Q-20 已采用显式 configure、verify、emit 的阶段划分，但该结论原本针对 native object emission；这里需要确认 JIT 是否沿用相同的显式验证原则，并决定是否完整遵循 LLJIT 的 DataLayout 行为。

## 关联问题

1. [Q-20. Configure、verify 与 emit 应显式分阶段还是由 emit 隐式完成](Q-20-configure-verify-emit-sequencing.md)（既有原则：native emission 不隐式 verify 或修改 Module）
2. [Q-24. Module 应如何安全提交给 JIT](Q-24-module-submission-ownership.md)（来源：bitcode 快照使 target 配置只作用于 JIT 内部副本）
3. [Q-28. ORC 错误应如何映射到安全层](Q-28-orc-error-model.md)（错误关系：DataLayout 不兼容和 bitcode 解析失败需要保留阶段诊断）

## 建议的解决方案

### A1. 要求调用者预先 configure 和 verify

#### 方案描述

`addModule` 不修改快照，也不运行 verifier；调用者必须先把原 Module 配置成 host target 并显式 verify。缺少或不兼容的 target 信息由安全层在提交前拒绝。

#### 优点

- 所有阶段都由公开调用点显式表达。
- JIT 与 native object emission 使用完全相同的推荐顺序。

#### 缺点

- 比 LLVM C++ LLJIT 更严格，默认 DataLayout 的普通 Module 不能直接提交。
- 用户容易遗漏 configure 或误用另一个 TargetMachine 的配置。
- 需要安全层自行定义 triple 和 DataLayout 的兼容检查。

### A2. 遵循 LLVM C++ LLJIT，并保持 verify 显式 【已采纳】

#### 方案描述

`addModule` 不隐式运行 verifier，用户仍应在提交前显式调用 `Module::verify()`。提交 bitcode 快照后，由 LLVM LLJIT 按原生规则处理快照的 DataLayout：默认值自动补为 JIT DataLayout，非默认且不兼容时返回带诊断的 `JITError`；target triple 不被安全层强制覆盖。

文档把显式 verify 写入推荐路径，但不把“已经 verify”建立为无法证明的运行时状态。原始 Module 不会因提交而发生 target mutation。

#### 优点

- 与 LLVM C++ `LLJIT::addIRModule` 的实际契约一致。
- 延续 Q-20 的显式 verifier 原则，同时允许普通未配置 Module 直接交给 host JIT。
- target mutation 只发生在独立快照中，不污染用户持有的 IR。
- 不重复实现 LLVM 已有的 DataLayout 兼容检查。

#### 缺点

- 用户仍可能遗漏 verify，并把结构非法的 IR 交给 ORC。
- Module triple 不会被强制规范成 host triple，需要在文档中说明它不构成额外兼容保证。
- native emission 与 JIT 的 configure 前置要求并不完全相同。

### A3. JIT 快照阶段总是覆盖 target 并隐式 verify

#### 方案描述

`addModule` 在独立快照上强制写入 LLJIT triple 和 DataLayout，然后运行 verifier；验证成功后才提交给 ORC。

#### 优点

- 一次调用完成 host target 规范化与合法性检查。
- 用户不会因为遗漏 verify 而直接进入 JIT 编译。

#### 缺点

- 偏离 LLVM C++ LLJIT 的 DataLayout 兼容性语义，会静默覆盖原本不兼容的配置。
- `addModule` 隐含多个阶段，错误来源和执行成本不再显式。
- 与 Q-20 已采用的阶段划分不一致。

## 最终采用方案

A2. 遵循 LLVM C++ LLJIT，并保持 verify 显式。
