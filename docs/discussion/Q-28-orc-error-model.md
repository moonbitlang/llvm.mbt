# Q-28. ORC 错误应如何映射到安全层 已解决

> 最后更新日期：2026-08-13
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

ORC 多数失败通过 owning `LLVMErrorRef` 返回。该对象必须被 `LLVMGetErrorMessage` 或 `LLVMConsumeError` 精确消费一次。现有早期 LLJIT 草稿在创建失败时直接打印并 panic，lookup 则把失败压成 `None`，且没有完整消费错误对象。既然旧 binding 可以废弃，需要为新的安全层统一设计 typed error、诊断文本和 finalizer 错误策略。

## 问题引发模型

### 最小复现例子

`LLVMOrcLLJITLookup` 的两种结果不能只建模为地址是否存在：

```text
success                    -> executor address
failure: unknown symbol    -> LLVMErrorRef("Symbols not found: ...")
failure: materialization   -> LLVMErrorRef(编译或链接诊断)
```

把所有 failure 转成 `None` 会丢失 unknown symbol 与编译失败的区别；读取诊断后若不调用正确的 consuming API，又会泄漏 LLVM Error。

### 问题分析

仓库已经在 native object emission 中采用 typed error，并在边界复制 LLVM 诊断后释放原始 message。ORC 应沿用相同原则，但还要处理 `LLVMOrcDisposeLLJIT` 和 ResourceTracker remove 也可能返回 Error 的情况。

普通公开方法可以抛出 typed error；GC finalizer 不能抛出异常，因此不能把所有清理都只放在 finalizer 中。显式 remove 可以报告错误，而 LLJIT 最终销毁若失败，需要决定是仅消费错误、记录诊断，还是提供显式 close 入口。

## 关联问题

1. [Q-05. 安全 IR 层应如何表达字符串边界错误](Q-05-ir-string-error.md)（既有错误：embedded NUL 应继续使用 StringError 而非混入 JITError）
2. [Q-20. Configure、verify、emit 应显式分阶段还是由 emit 隐式完成](Q-20-configure-verify-emit-sequencing.md)（一致性：JIT 配置、验证和提交错误应保持可区分）
3. [Q-25. LLJIT、已提交 Module 与 ResourceTracker 如何管理生命周期](Q-25-jit-resource-lifecycle.md)（清理关系：显式与 finalizer 路径决定哪些错误能向用户报告）
4. [Q-26. 符号查找和本地函数调用应公开成什么模型](Q-26-jit-symbol-lookup-and-invocation.md)（lookup 关系：未知符号需要保留 LLVM 诊断）
5. [Q-31. LLJIT 销毁错误是否需要显式 close](Q-31-lljit-explicit-close.md)（后续依赖：决定 dispose error 是否能由普通调用返回）

## 建议的解决方案

### A1. 失败统一 panic 或返回 None 【不建议】

#### 方案描述

创建、提交或调用失败时打印 LLVM 信息并 panic；lookup 找不到符号时返回 `None`。清理路径直接忽略 LLVMErrorRef。

#### 优点

- wrapper 实现短，接近现有早期草稿。
- 调用者不需要处理多个错误变体。

#### 缺点

- library 内部 panic，调用者无法恢复或展示 REPL 诊断。
- `None` 丢失 unknown symbol、编译失败和链接失败之间的区别。
- 忽略 owning LLVMErrorRef 会泄漏或违反精确消费契约。
- 无法测试错误阶段和原始 LLVM 诊断是否保留。

### A2. 统一建立带诊断的 JITError 【已采纳】

#### 方案描述

所有 ORC adapter 在同一内部边界判断 `LLVMErrorRef` 是否为空；失败时调用 `LLVMGetErrorMessage` 消费 error，把 message 复制为 MoonBit String，并精确释放 LLVM error message。

安全层用 `JITError` 区分至少以下阶段：

- LLJIT 创建失败；
- Module 快照或解析失败；
- Module 提交失败；
- symbol lookup/materialization 失败；
- ResourceTracker remove 失败；
- 可显式观察的 JIT 销毁失败。

embedded NUL 继续映射到现有 `StringError::ContainsNul`。lookup 未找到符号作为带 LLVM 诊断的错误，而不是 `None`。

对 finalizer 无法上抛的销毁错误，内部仍必须消费 error；是否同时提供显式 close，由 Q-31 决定。

#### 优点

- 调用者可以区分失败阶段并保留 LLVM 原始诊断。
- 每个 LLVMErrorRef 的消费责任集中、可测试。
- 与现有 verification 和 object emission 的安全层风格一致。

#### 缺点

- 需要为每个 consuming C API 精确记录成功、失败与所有权转移顺序。
- finalizer 错误仍无法像普通调用错误一样可靠返回给用户。
- 错误 enum 需要控制粒度，避免把所有 LLVM 内部类别照搬到公开层。

## 最终采用方案

A2. 统一建立带诊断的 JITError
