# Q-13. unsized Type 的 sizeOf 应如何表达无有效大小 已解决

> 最后更新日期：2026-08-11
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

Q-11 的 M2 Type 测试原计划验证 sized type 返回 ConstantExpr、unsized type 返回 `None`。实际测试发现 `Type::sizeOf` 对 void 等 unsized type 也可能返回 `Some`。本问题讨论 safe IR 层是否应在调用 LLVM 前明确执行 sized 前置条件。

## 问题引发模型

### 问题复现

当前 `Type::sizeOf` 直接调用 `llvm_size_of`，只根据返回的 raw ValueRef 是否为 null 决定 `Some` 或 `None`。实际调用 `context.getVoidTy().sizeOf()` 时得到 `Some(ConstantExpr)`，没有进入 `None` 分支。

### 最小复现例子

```moonbit
test {
  let context = Context::new()
  assert_true(context.getVoidTy().sizeOf() is None)
}
```

将 void type 换成 i32 后，`Some(ConstantExpr)` 是有意义的正常结果；问题只在类型本身不满足 `isSized()` 时出现。

### 问题分析

公开签名 `sizeOf(Self) -> &Value?` 已经为“没有有效大小”保留了 `None`，仓库也提供了 `isSized()`。底层 `LLVMSizeOf` 的非 null 结果不能替代 safe wrapper 的语义前置条件，否则调用者可能把 unsized type 对应的表达式当成合法大小继续构造 IR。

## 关联问题

1. [Q-11. 测试补全应按什么顺序推进](Q-11-test-expansion-order.md)（来源：M2 Type sizeOf 边界测试暴露本问题）

## 建议的解决方案

### A1. 在调用 LLVMSizeOf 前以 isSized 拒绝 unsized type 【已采纳】

#### 方案描述

`Type::sizeOf` 先执行 `guard self.isSized() else { return None }`，仅对 sized type 调用 `llvm_size_of`。补充整数、复合 sized type 的 positive 测试，以及 void、function type 和可构造的其他 unsized type 的 `None` 测试。

#### 优点

- 使 Option 返回模型具有稳定、可解释的含义。
- 在 safe 层阻止无语义保证的 ConstantExpr 泄漏给调用者。
- 修复范围小，可独立验证。

#### 缺点

- 与当前可观察行为不兼容；依赖 unsized type 返回表达式的代码会改变结果。

## 最终采用方案

A1. 在调用 LLVMSizeOf 前以 isSized 拒绝 unsized type
