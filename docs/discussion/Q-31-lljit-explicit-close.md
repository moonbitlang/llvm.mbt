# Q-31. LLJIT 销毁错误是否需要显式 close 已解决

> 最后更新日期：2026-08-13
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

`LLVMOrcDisposeLLJIT` 返回 owning `LLVMErrorRef`，但 MoonBit external object finalizer 不能向用户抛出异常。Q-28 已决定所有 ORC error 都必须精确消费，并尽可能映射为带诊断的 `JITError`；尚未决定 LLJIT 是否需要公开显式 `close()`，让正常路径能够观察 session shutdown 失败。

## 问题引发模型

### 问题分析

LLVM C++ `LLJIT` 析构时调用 `ExecutionSession::endSession()`，若失败则交给 session error reporter，并不从析构函数返回错误。LLVM-C 则把同一清理操作通过 `LLVMOrcDisposeLLJIT` 的返回值暴露给调用者。

在 MoonBit 中，若只有 GC finalizer，binding 仍能消费并释放 error，但无法把诊断交还给原调用者。若增加 `close()`，LLJIT owner 必须具有 open/closed 状态；任意 alias 调用 close 后，其他 LLJIT、ResourceTracker 和 JITAddress wrapper 都必须识别已关闭状态，避免再次进入 LLVM。

## 关联问题

1. [Q-25. LLJIT、已提交 Module 与 ResourceTracker 如何管理生命周期](Q-25-jit-resource-lifecycle.md)（生命周期依赖：ResourceTracker 和 JITAddress 都锚定同一个 LLJIT owner）
2. [Q-26. 符号查找和本地函数调用应公开成什么模型](Q-26-jit-symbol-lookup-and-invocation.md)（失效关系：close 会使既有 executor address 立即失效）
3. [Q-28. ORC 错误应如何映射到安全层](Q-28-orc-error-model.md)（来源：finalizer 无法返回 dispose 产生的 JITError）
4. [Q-29. JIT 应建立怎样的测试闭环，何时可以开始 Kaleidoscope](Q-29-jit-test-and-kaleidoscope-entry.md)（验收关系：需要覆盖 alias、重复 close 和 finalizer fallback）

## 建议的解决方案

### A1. 只由 finalizer 销毁 LLJIT

#### 方案描述

LLJIT 不公开 `close()`。最后一个 owner 引用被回收时，finalizer 调用 `LLVMOrcDisposeLLJIT`；成功或失败都精确消费返回的 error，失败诊断只能交给内部 error reporter 或丢弃。

#### 优点

- 公开 API 和 owner 状态最简单。
- 不会因为用户显式 close 而使仍被持有的 JITAddress 意外失效。
- 使用体验接近依赖 RAII 析构的 C++ LLJIT。

#### 缺点

- 正常程序无法观察或处理 JIT session shutdown 失败。
- 销毁时机由 GC 决定，资源释放不确定。
- 与 LLVM-C 特意返回 `LLVMErrorRef` 的能力不完全对应。

### A2. 提供显式 close，并保留 finalizer fallback 【已采纳】

#### 方案描述

公开 `LLJIT::close() -> Unit raise JITError`。首次 close 取得 owner 中的 raw handle、将 owner 标记为 closed，再调用 `LLVMOrcDisposeLLJIT` 并返回可能的销毁诊断。成功或失败后均保持 closed，避免对可能已部分结束的 session 重试。

finalizer 只在 owner 仍为 open 时执行同一清理，并精确消费无法上抛的错误；若已经 close 则不再调用 LLVM。close 后的 LLJIT、ResourceTracker 和 JITAddress 操作统一返回或触发生命周期错误。文档明确 close 前必须停止使用由该 JIT 产生的 FuncRef。

#### 优点

- 正常路径可以确定性释放 JIT 资源并观察 shutdown 错误。
- finalizer 仍能防止忘记 close 时泄漏整个 JIT。
- owner 状态集中管理 aliases，可以验证只销毁一次。

#### 缺点

- 为所有派生 wrapper 引入 open/closed 检查和失效语义。
- 普通 FuncRef 无法携带 owner 或动态检查 close，错误顺序仍可产生悬空调用。
- API 比 C++ RAII 多一个显式操作，用户需要理解 close 与 ResourceTracker remove 的区别。

## 最终采用方案

A2. 提供显式 close，并保留 finalizer fallback。
