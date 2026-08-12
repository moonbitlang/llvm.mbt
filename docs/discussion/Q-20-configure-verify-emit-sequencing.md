# Q-20. Configure、verify 与 emit 应显式分阶段还是由 emit 隐式完成 已解决

> 最后更新日期：2026-08-12
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

在有了 host TargetMachine 后，还需要确定高层 `emitObjectToFile` 是否应自动配置 Module 和执行 verifier。这个决定同时影响 API 是否有隐式可观察修改、错误发生的阶段，以及与 LLVM C++ 用法的对应程度。

## 问题引发模型

### 问题分析

一条完整路径包含三个不同操作：

1. `configureModule` 修改 Module 的 target triple 和 DataLayout。
2. `Module::verify` 检查 IR 合法性，但不应修改 Module。
3. `emitObjectToFile` 使用 TargetMachine 将 Module 输出到文件。

验证时安全层应固定使用 `LLVMReturnStatusAction`，把 `LLVMVerifyModule` 的 message 转成 `VerificationError`。安全库不应选择会 `abort()` 的 `LLVMAbortProcessAction`，也不应用 `LLVMPrintMessageAction` 隐式写 stderr。

## 关联问题

1. [Q-19. Module 初始 triple 与 DataLayout 应采用什么语义](Q-19-module-target-data-layout.md)（依赖：configure 阶段的语义由 Q-19 决定）
2. [Q-16. Native object emission 首期应绑定哪些 LLVM-C API](Q-16-native-object-emission-scope.md)（依赖：verify 和 emit 的 raw adapter 由 Q-16 提供）

## 建议的解决方案

### A1. emitObjectToFile 自动 configure 并 verify

#### 方案描述

`emitObjectToFile(module, filename)` 先用当前 TargetMachine 覆盖 Module triple/DataLayout，随后执行 module verifier，最后输出 object。用户只需调用一个方法。

#### 优点

- 快速路径最短，不会因遗漏 configure 或 verify 而生成配置不完整的 object。
- 输出前总会获得一次 verifier 证据。

#### 缺点

- 方法名没有显示它会修改 Module 的 triple 和 DataLayout。
- 调用者无法选择验证时机，重复 emission 也会重复 verify。
- 与 LLVM 中显式配置、验证、codegen 的阶段划分不一致。

### A2. 显式 configure、verify、emit 三阶段 【已采纳】

#### 方案描述

分别提供 `TargetMachine::configureModule`、`Module::verify` 和 `TargetMachine::emitObjectToFile`。`emitObjectToFile` 只 borrow TargetMachine 和 Module 执行 emission，不隐式改变 Module，也不隐式运行 verifier。

推荐用法固定为：

```moonbit
let machine = TargetMachine::host(...)
machine.configureModule(program)
program.verify()
machine.emitObjectToFile(program, object_path)
```

#### 优点

- 每个阶段的 mutation 和错误边界明确。
- 调用者可以在 configure 后检查 triple/DataLayout，在 verify 后决定是否输出。
- 与 LLVM C++ 教程中的显式阶段分离更接近。

#### 缺点

- 调用者可能遗漏 configure 或 verify，高层文档和示例必须给出标准路径。
- 如果需要强制 module 与 TargetMachine 匹配，后续可能还要在 emit 前增加契约检查。

## 最终采用方案

A2. 显式 configure、verify、emit 三阶段
