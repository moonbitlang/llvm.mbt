# Q-07. Context 与 Module 的回收策略 已解决

> 最后更新日期：2026-08-05
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

当前安全 `IR` 包直接用 raw handle 表示 `Context` 和 `Module`。`Context` 暴露可重复调用的 `drop`，`Module` 没有释放入口，而 `Module::getContext` 又把 borrowed `LLVMContextRef` 包装成同一种可释放 `Context`。需要确定二者的稳定回收模型。本问题只决定回收策略；派生对象如何保持 owner 存活由 Q-08 讨论。

## 问题引发模型

### 问题复现

当前表示和接口的核心形态是：

```moonbit
pub struct Context(@unsafe.LLVMContextRef)

pub fn Context::drop(self : Context) -> Unit {
  @unsafe.llvm_context_dispose(self.0)
}

pub struct Module(@unsafe.LLVMModuleRef)

pub fn Module::getContext(self : Module) -> Context {
  Context(@unsafe.llvm_get_module_context(self.0))
}
```

`drop` 不消费 `Context`，也不改变所有 alias 共享的状态。因此，同一个 handle 可以被释放两次，释放后仍可继续调用。通过 `Module::getContext` 得到的只是 borrowed context，却也可以调用同一个 `drop`。另一方面，`Module` 当前没有调用 `LLVMDisposeModule` 的路径。

### 最小复现例子

下面的调用在类型层面都被允许，但会让后续操作面对已经释放的 native context：

```moonbit
let ctx = Context::new()
let mod = ctx.addModule("demo")
let borrowed_ctx = mod.getContext()
borrowed_ctx.drop()
mod.getName()
```

如果只给 `Context` 和 `Module` 添加 finalizer，而 `Function` 等派生对象仍只保存 raw handle，也会出现另一条悬空路径：局部 `Module` 在最后一次直接使用后被回收，但仍存活的 `Function` 随后继续访问该 Module 内的 LLVM 对象。去掉派生对象的 raw-only 表示、让它持有 owner 后，这条路径才会消失。

### 问题分析

公开 `close`/`drop` 与 finalizer 解决的是两个不同问题。closed 标志可以让显式关闭幂等，却不能自动保证 `Module` 先于 `Context` 析构，也不能让 `Function` 等 borrowed handle 保持 `Module` 存活。无论是否公开 `close`，都仍需建立 Q-08 中的 child-to-parent 强引用。

本项目中的 `Context` 和 `Module` 适合由 MoonBit 引用计数管理的 opaque external object 表示。`Module` owner 在 C payload 中持有 `Context` owner；由于 C payload 不会被 MoonBit 自动扫描，这条引用要显式维护引用计数。`Module` finalizer 先调用 `LLVMDisposeModule`，再释放对 `Context` owner 的引用，从结构上保证析构顺序。

不能采用“发现 Context 已析构就跳过 Module 析构”的补救逻辑。正确的 parent anchor 应使这种顺序不可能发生；跳过 `LLVMDisposeModule` 只会把错误隐藏为泄漏，也无法修复 Context 已经提前释放所造成的 use-after-free。

## 关联问题

1. [Q-08. 派生 IR 对象的 owner 持有关系与迁移顺序](Q-08-derived-handle-owner-anchors.md)（依赖：启用 finalizer 前必须先补全 owner anchor）

## 建议的解决方案

### A1. 只使用 finalizer，但不改变派生 handle 的表示 【不建议】

#### 方案描述

删除公开 `close`/`drop`，让 `Context` 和 `Module` 在引用计数归零时由 finalizer 释放；遇到 parent 已经析构的情况时，由 C wrapper 跳过 child 析构。

#### 优点

- 用户不需要手动管理 LLVM 资源。
- 不再存在用户重复调用 `drop` 的入口。

#### 缺点

- raw-only 的派生对象不会延长 owner 生命周期，last-use 回收会使它们悬空。
- 跳过 child 析构会泄漏，并不能建立正确的析构顺序。

### A2. 公开 close/drop，并在 C owner 中保存 closed 标志

#### 方案描述

`Context` 和 `Module` 的 C payload 保存 raw handle 与状态。公开的 `close`/`drop` 先检查状态，只在第一次调用时释放 native handle，并由 finalizer 兜底。

#### 优点

- 可以确定地提前释放资源。
- alias 共享同一 owner 时，可以把显式关闭做成幂等操作。

#### 缺点

- 所有操作和 borrowed child 都必须传播并检查 closed 状态。
- 仍需单独处理 parent anchor 和 Context/Module 的析构顺序。
- 对当前主要依赖引用计数的安全 `IR` API 增加了手动生命周期状态。

### A3. finalizer-only 的稳定 API，并以 owner anchor 保证析构顺序 【已采纳】

#### 方案描述

安全 `IR` 包不公开 `Context::close`、`Context::drop` 或 `Module::close`。`Context` 和 `Module` 改为 MoonBit 管理的 opaque external owner，由 C finalizer 调用相应的 LLVM disposer。

`Module` owner 强持有 `Context` owner；所有 borrowed handle 再按 Q-08 持有其真正的 owner。内部所有权边只从 child 指向 parent，不主动构造环。这样，派生对象存活时会自然延长 native owner 的生命周期，用户不需要在作用域末尾写 `mod |> ignore`。

#### 优点

- 普通用户不需要手动关闭 GC/RC 语言中的对象。
- 没有公开的重复关闭和 use-after-close 状态。
- owner 引用关系直接保证 Module 先于 Context 析构，不依赖字段析构顺序。

#### 缺点

- 释放时点取决于 MoonBit 引用计数和 finalizer 调度，不适合要求即时释放的资源。
- 必须先完整迁移派生 handle；只迁移 Context/Module 会把当前泄漏变成提前释放风险。
- C payload 中的 parent 引用需要正确配对 `incref`/`decref`。

## 最终采用方案

A3. finalizer-only 的稳定 API，并以 owner anchor 保证析构顺序
