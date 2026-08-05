# Q-08. 派生 IR 对象的 owner 持有关系与迁移顺序 已解决

> 最后更新日期：2026-08-05
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

采用 Q-07 的 finalizer-only 模型后，需要确定从 `Context` 和 `Module` 派生出的 `Type`、`Value`、`BasicBlock`、`DataLayout` 与 `IRBuilder` 是否也要持有 owner，以及如何在不制造中间悬空状态的前提下完成迁移。

## 问题引发模型

### 问题复现

当前多数派生 wrapper 只保存 LLVM raw handle。例如 `Function`、各种 Instruction 和 Type wrapper 最终都只含一个 `LLVMValueRef` 或 `LLVMTypeRef`。`Value::getType`、`initAbstractType`、`initInstruction` 以及各种 iterator/getter 也只用新取得的 raw handle 构造返回值，没有传播 owner。

### 最小复现例子

```moonbit
fn make_function() -> Function raise StringError {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let fty = ctx.getFunctionType(ctx.getVoidTy(), [])
  mod.addFunction(fty, "f")
}

let f = make_function()
f.getName()
```

如果 `Function` 只保存 raw value，`make_function` 返回后 `Module` 可以在最后一次直接使用处回收，`f` 随即悬空。若 `Function` 强持有 `Module`，而 `Module` 又强持有 `Context`，则 `f` 存活期间两级 owner 都不能析构，不需要人为延长局部变量的最后使用位置。

### 问题分析

不是所有派生对象都应统一持有 `Module`；应当持有 LLVM 实际 lifetime owner：

- `Module` 持有 `Context`。
- Function、GlobalVariable、GlobalConstant、Argument、BasicBlock 和各种 Instruction 属于 Module，持有 `Module`。
- Type family 和当前 context-owned constant wrapper 持有 `Context`。
- 从 Module 取得的 `DataLayout` 是 Module-borrowed view，持有 `Module`。
- `IRBuilder` 自身由 Context 创建，至少持有 `Context`；设置 insertion point 后还引用 Module 内的 BasicBlock/Instruction，因此迁移时必须让相应 Module 在该 insertion point 有效期间存活。具体字段表示可在实现该批次时单独收敛。

返回值的 owner 应按返回对象本身的 provenance 决定，而不是机械继承调用者。例如从 `Function` 得到的 `Type` 最终应直接持有 `Context`，不必为了这个 Type 继续保留整个 `Module`。

可以用少量 package-private handle 统一传播规则，例如：

```moonbit
priv struct ContextAnchoredValue {
  raw : @unsafe.LLVMValueRef
  context : Context
}

priv struct ModuleAnchoredValue {
  raw : @unsafe.LLVMValueRef
  module : Module
}

priv struct ContextAnchoredType {
  raw : @unsafe.LLVMTypeRef
  context : Context
}
```

具体 wrapper 可以包含这些 handle，而不必在每个类型中重新实现生命周期逻辑。公共 API 是否保持源码兼容要在迁移 commit 中检查；公开 tuple constructor、raw field 或 raw accessor 本身不应成为必须保留的兼容目标。

## 关联问题

1. [Q-07. Context 与 Module 的回收策略](Q-07-context-module-reclamation.md)（依赖：本问题为 finalizer-only 回收提供必要的存活保证）

## 建议的解决方案

### A1. 派生对象继续只保存 raw handle，由用户手动延长 owner 生命周期 【不建议】

#### 方案描述

只给 `Context` 和 `Module` 添加 finalizer。文档要求用户在所有派生对象使用完之后再次使用或 `ignore` 相应 owner，阻止 last-use 提前回收。

#### 优点

- wrapper 表示和构造路径的改动最小。

#### 缺点

- 安全性依赖调用者理解编译器的 last-use 行为。
- 遗漏一次人工保活就会产生 use-after-free，安全 `IR` 包无法通过类型结构保证正确性。

### A2. 所有 Type 和 Value 都直接持有 Module

#### 方案描述

统一让所有 Type 和 Value wrapper 保存 `Module`，通过 Module 间接保持 Context 存活。

#### 优点

- 传播规则表面上统一。
- Module 派生的对象可以保持正确的 parent 存活。

#### 缺点

- Context 创建的 Type 和 Constant 未必存在 Module。
- Type 不应仅因曾从某个 Module 内的对象取得，就无谓延长整个 Module 的生命周期。
- 无法准确表达 `DataLayout`、Builder 等不同 provenance。

### A3. 按 provenance 建立 child-to-parent 强引用，并分阶段迁移 【已采纳】

#### 方案描述

每个 borrowed wrapper 持有真正控制其 native lifetime 的 owner：Module-owned 对象持有 `Module`，Context-owned 对象持有 `Context`，`Module` 再持有 `Context`。所有 factory、getter、iterator 和动态包装函数在构造返回值时显式传播相应 owner。

迁移按以下顺序进行：

1. 保持 finalizer 未启用，先引入 private handle/owner 字段和 package-private raw extraction，逐类迁移 Type family、context-owned constants、Module-owned Value family、BasicBlock、DataLayout 与 IRBuilder。
2. 检查所有构造路径，重点包括 `initAbstractType`、`initInstruction`、`Value::getType`、parent/next/previous getter、Module iterator 以及 IRBuilder 创建的 Instruction，确保没有重新生成 raw-only wrapper。
3. 让 `getContext` 等 API 返回已经保存的 owner，而不是把 borrowed raw pointer 重新包装成新的 owning `Context`。
4. 每个迁移批次运行 `moon info`、`moon fmt`、`moon check --target native` 和 `moon test --target native`，检查公开接口变化和行为回归。
5. 只有上述路径全部完成并经过审核后，才为 `Module` 和 `Context` 接入 C finalizer，并删除公开的 `Context::drop`。不得在中途提前启用 finalizer。

#### 优点

- 生命周期由类型表示保证，不依赖用户手动保活。
- 不会为了保留 Type 而无谓保留整个 Module。
- 大部分改动是可按类型族和构造路径机械检查的，适合拆成小 commit 审核。

#### 缺点

- 改动会覆盖大量 wrapper 和构造路径，源码 diff 较大。
- 漏迁任意一条返回 raw-only wrapper 的路径，都可能在 finalizer 启用后成为悬空引用。
- IRBuilder insertion point 的 owner 表示还需要在对应实现批次中进一步确定。

## 最终采用方案

A3. 按 provenance 建立 child-to-parent 强引用，并分阶段迁移
