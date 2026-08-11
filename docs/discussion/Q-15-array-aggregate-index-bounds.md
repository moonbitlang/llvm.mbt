# Q-15. Array 的 Aggregate element 查询应如何处理越界索引 已解决

> 最后更新日期：2026-08-11
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

`AggregateType::getElementType` 的返回类型是 `&Type?`，Struct 分支会检查索引，Array 分支却完全忽略索引。该行为还会绕过 `IRBuilder::createInsertValue` 对 aggregate index 的安全检查。本问题讨论 Array aggregate 查询应采用的边界契约。

## 问题引发模型

### 问题复现

对长度为 3 的 ArrayType 取得 `&AggregateType` 后，当前 `getElementType(-1)`、`getElementType(3)` 和更大的索引都会返回相同的 `Some(elementType)`。Array 分支只是无条件包装 `arr.getElementType()`，没有使用传入的 idx。

### 最小复现例子

```moonbit
test {
  let context = Context::new()
  let array = context.getArrayType(context.getInt32Ty(), 3)
  guard array.tryAsAggregateType() is Some(aggregate) else {
    fail("expected AggregateType")
  }
  assert_true(aggregate.getElementType(-1) is None)
  assert_true(aggregate.getElementType(3) is None)
}
```

将 ArrayType 换成具有三个 elements 的 StructType 后，当前实现会正确返回 `None`，说明问题来自 AggregateType 的 Array 分支。

### 问题分析

Array 虽然所有元素类型相同，但 insertvalue/extractvalue 的索引仍必须落在数组长度内。`IRBuilder::createInsertValue` 依赖 `AggregateType::getElementType(index)` 返回 `None` 来报告 `InValidArgument`；当前遗漏会让非法 Array 索引穿过检查，负数还会在传给 LLVM 前被重新解释为 UInt。`createExtractValue` 已单独检查 Array 边界，因此两个 builder API 目前不对称。

## 关联问题

1. [Q-11. 测试补全应按什么顺序推进](Q-11-test-expansion-order.md)（来源：M2 AggregateType 边界测试暴露本问题）

## 建议的解决方案

### A1. Array 分支按 element count 返回 Some 或 None 【已采纳】

#### 方案描述

在 `AggregateType::getElementType` 的 Array 分支检查 `0 <= idx < arr.getElementCount()`；合法索引返回 element type，负数和越界索引返回 `None`。随后补充 getter 边界测试，以及 `createInsertValue` 对非法 Array index 的具体错误测试。

#### 优点

- 与 Option 签名和 Struct 分支一致。
- 恢复 `createInsertValue` 的 safe validation，避免非法索引进入 LLVM。
- 与已经显式检查边界的 `createExtractValue` 对齐。

#### 缺点

- 依赖“任意索引都返回 Array element type”这一当前行为的调用者需要改用 `ArrayType::getElementType()`。

## 最终采用方案

A1. Array 分支按 element count 返回 Some 或 None
