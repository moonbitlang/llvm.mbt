# Q-12. ScalableVectorType 是否应完整遵循 LLVM vector 分类语义 已解决

> 最后更新日期：2026-08-11
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

Q-11 的 M2 Type predicate 补测显示，当前实现只在部分分类中把 fixed vector 视为 vector，遗漏了 ScalableVectorType。本问题只讨论 ScalableVectorType 的 single-value、scalar 和由 scalar 派生的复合 predicate 语义。

## 问题引发模型

### 问题复现

对 `Context::getScalableVectorType(context.getInt32Ty(), 4)` 的结果调用公开 Type API，当前可观察到：

- `isSingleValueType()` 返回 `false`；
- `getScalarType()` 返回 scalable vector 自身，而不是 `i32`；
- `isIntOrIntVectorTy()` 因依赖 `getScalarType()` 而返回 `false`。

同一遗漏还会影响浮点和 pointer scalable vector 的 `isFPOrFPVectorTy()` 与 `isPtrOrPtrVectorTy()`。

### 最小复现例子

```moonbit
test {
  let context = Context::new()
  let vector = context.getScalableVectorType(context.getInt32Ty(), 4)
  assert_true(vector.isSingleValueType())
  inspect(vector.getScalarType(), content="i32")
  assert_true(vector.isIntOrIntVectorTy())
}
```

将 ScalableVectorType 换成相同 element type 和 count 的 fixed VectorType 后，当前实现能够通过上述检查，说明问题来自两种 vector 分支处理不一致。

### 问题分析

LLVM 19 的 `Type::isVectorTy()` 同时包含 fixed 和 scalable vector，`isSingleValueType()` 与 `getScalarType()` 都建立在这一统一分类上。当前 `Type::isSingleValueType` 只匹配 `VectorType`，`Type::getScalarType` 也只展开 `VectorType`，因此后续依赖 scalar type 的 predicate 连带失真。

## 关联问题

1. [Q-11. 测试补全应按什么顺序推进](Q-11-test-expansion-order.md)（来源：M2 Type predicate 测试暴露本问题）

## 建议的解决方案

### A1. 在基础分类中统一处理 fixed 和 scalable vector 【已采纳】

#### 方案描述

让 `isSingleValueType` 同时接受 `VectorType` 与 `ScalableVectorType`，并让 `getScalarType` 对两者都返回 element type。继续由 `isIntOrIntVectorTy`、`isFPOrFPVectorTy` 和 `isPtrOrPtrVectorTy` 复用 `getScalarType`，不在每个复合 predicate 中重复特判。

#### 优点

- 与 LLVM 的统一 vector 分类一致。
- 一处修复即可恢复三个派生 predicate。
- 保留当前 TypeEnum 将两种 vector 分开的公开建模。

#### 缺点

- 需要系统检查其他只匹配 `VectorType` 的公开 Type 行为，确认是否存在同类遗漏。

## 最终采用方案

A1. 在基础分类中统一处理 fixed 和 scalable vector
