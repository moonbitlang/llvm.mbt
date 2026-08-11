# Q-14. 安全 API 应如何创建和完成 opaque named struct 已解决

> 最后更新日期：2026-08-11
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

当前公开了 `StructType::isOpaque` 和只允许 opaque struct 调用的 `StructType::setBody`，但没有公开 factory 能创建保持 opaque 状态的 named struct。本问题讨论如何补全“先声明、后设置 body”的安全构造闭环。

## 问题引发模型

### 问题复现

`Context::getStructType` 在传入 name 时先调用 `llvm_struct_create_named`，随后无条件调用 `llvm_struct_set_body`。因此即使 elements 为空，得到的也是 `%Name = type {}`，而不是 `%Name = type opaque`。通过当前安全 API 创建的 struct 调用 `setBody` 只会进入 `SetBodyForNonOpaqueStruct` 错误分支。

### 最小复现例子

```moonbit
test {
  let context = Context::new()
  let named = context.getStructType([], name="Node")
  assert_true(named.isOpaque())
  named.setBody([context.getInt32Ty(), context.getPtrTy()])
}
```

当前第一条 assertion 即失败。若绕过安全 API，直接只创建 named struct 而暂不设置 body，则后续 `setBody` 能表达预期流程，说明缺失的是公开构造入口。

### 问题分析

LLVM C++ 明确区分 body 已设置但 elements 为空的 empty struct，与 body 尚未设置的 opaque struct。现有 `getStructType([], name="Empty")` 应继续表示 `%Empty = type {}`，不应把空数组重解释为 opaque。当前 API 能创建 literal struct 和已经定义 body 的 named struct，也能拒绝对 non-opaque struct 重复设置 body，但无法从安全层到达 `setBody` 的正常分支。这使 forward-declared named struct 和分阶段完成类型定义的 LLVM 工作流无法闭环。

## 关联问题

1. [Q-11. 测试补全应按什么顺序推进](Q-11-test-expansion-order.md)（来源：M2 StructType 状态与 setBody 测试暴露本问题）

## 建议的解决方案

### A1. 增加 Context::getOpaqueStructType 【已采纳】

#### 方案描述

在 Context 上增加只调用 `llvm_struct_create_named`、不设置 body 的公开 `Context::getOpaqueStructType(name)`。沿用现有 StringError/NUL 边界；创建后由 `StructType::setBody` 一次性完成 elements 和 packed 状态。保留 `getStructType([], name)` 创建 empty named struct 的现有语义。

#### 优点

- 不改变现有 `getStructType` 的行为和调用方式。
- 使 `isOpaque` 与 `setBody` 的公开正常路径真正可达。
- 接近 LLVM named struct 的两阶段构造模型。

#### 缺点

- 增加一个公开 API，需要确定命名、重复名称和文档契约。

## 最终采用方案

A1. 增加 Context::getOpaqueStructType
