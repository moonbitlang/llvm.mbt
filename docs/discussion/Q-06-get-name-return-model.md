# Q-06. Value 派生对象与 Module 的 getName 返回模型 待讨论

> 最后更新日期：2026-08-04
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

当前 `Value::getValueName` 返回 `String? raise`，而 Function、Argument、BasicBlock 和 Module 的专用 `getName` 返回 `String raise`。需要决定这些 API 是否应统一，并区分“没有名字”“名称不是合法 UTF-8”和 Module Identifier 三种不同语义。本问题不决定底层 C 字符串复制方式。

## 问题引发模型

### 问题复现

当前接口存在两种返回模型：

```moonbit
pub trait Value: Show {
  fn getValueName(Self) -> String? raise = _
}

pub fn Function::getName(self : Self) -> String raise
pub fn Argument::getName(self : Self) -> String raise
pub fn BasicBlock::getName(self : Self) -> String raise
pub fn Module::getName(self : Self) -> String raise
```

`Value::getValueName` 先严格解码，然后把空字符串变成 `None`；三个 Value 派生对象的专用 getter 直接返回解码后的字符串。于是未命名对象在不同入口分别表现为 `None` 和 `""`，UTF-8 解码失败又都会向上传递异常。

### 最小复现例子

Function、Argument 和 BasicBlock 的 LLVM 构造器都允许名称为空，因此它们可能处于未命名状态：

```moonbit
let arg = function.getArg(0).unwrap()
// LLVM 中该 Argument 可以没有名字。
```

Module 的 `getName` 则不是同一种可选 Value 名称；它返回 Module Identifier。Module 构造时具有该属性，SourceFileName 也默认从 Module Identifier 初始化，所以不能仅为了函数名相同就把它解释为 `String?`。

### 问题分析

Option 应优先表示名称是否存在，UTF-8 解码失败则是“存在一段名称字节，但 MoonBit `String` 无法表示”。把两者都转换成 `None` 可以得到简单的无异常 API，但会丢失这个区别。

返回 `"<invalid>"` 也不能保留区别，因为它本身可以是合法 LLVM 名称；名称比较、查找或重新设置时，调用者无法判断拿到的是实际名称还是占位符。占位字符串和 lossy UTF-8 更适合 `Show`、日志等展示路径，不适合作为语义 getter 的结果。

统一范围应首先限定为 Value 名称：[`Value::getValueName`](../../IR/Value.mbt)、[`Function::getName` 与 `Argument::getName`](../../IR/Function.mbt)、[`BasicBlock::getName`](../../IR/BasicBlock.mbt) 应共享同一语义。[`Module::getName`](../../IR/Module.mbt) 应作为 Module Identifier 单独设计，后续可以考虑改名或补充 `getIdentifier`，避免名称相同造成误解。

## 关联问题

1. [Q-05. IR 对外 StringError 的建立与 LLVM 名称解码](Q-05-ir-string-error.md)（依赖：严格 getter 需要使用 IR 层字符串错误）

## 建议的解决方案

### A1. Value 名称统一返回 String?，解码失败也返回 None 【建议采纳】

#### 方案描述

`Value::getValueName`、`Function::getName`、`Argument::getName` 和 `BasicBlock::getName` 都返回 `String?` 且不 `raise`。未命名和 UTF-8 解码失败都返回 `None`。Module Identifier 与 SourceFileName 保持独立的 `String` 模型，不参加这项统一。

#### 优点

- 接口简单，符合此前提出的“Value getter 不应 raise”的方向。
- 所有 Value 名称入口对未命名对象表现一致。
- 改动范围比引入新的名称类型小。

#### 缺点

- 无法区分真正未命名和存在非 UTF-8 名称字节。
- 调用者不能诊断或无损处理非法 UTF-8 名称。

### A2. Value 名称返回 String? raise StringError

#### 方案描述

`None` 只表示 LLVM `hasName()` 为假或名称为空；名称存在但不能解码为 UTF-8 时，抛出 `StringError::MalformedUtf8`。Function、Argument 和 BasicBlock 的专用 getter 统一采用该模型。

#### 优点

- 严格区分未命名和编码错误。
- 不需要额外的公开名称枚举。

#### 缺点

- 常用 getter 仍然需要错误处理。
- 不符合此前倾向的“Value getter 不应 raise”。

### A3. 使用无异常的专用 ValueName 类型

#### 方案描述

为 Value 名称建立完整状态类型：

```moonbit
pub enum ValueName {
  Unnamed
  Utf8(String)
  InvalidUtf8(Bytes)
}
```

所有 Value 名称 getter 返回 `ValueName`，不抛出 UTF-8 解码错误。

#### 优点

- 无异常且不丢失未命名、合法 UTF-8 和非法 UTF-8之间的区别。
- 调用者可以无损诊断名称字节。

#### 缺点

- 为常见操作引入新的公开类型和模式匹配负担。
- 相比当前逐步重构目标，API 和实现改动较大。

### A4. 所有 getter 返回 String，失败时使用占位符 【不建议】

#### 方案描述

保留或统一为 `String` 返回值；未命名使用空字符串，UTF-8 解码失败使用 `"<invalid>"` 或 lossy decode 的结果。

#### 优点

- 调用端最简单，不需要 `Option`、异常或专用类型。
- 适合只做日志和界面展示的路径。

#### 缺点

- 占位符可能与真实 LLVM 名称冲突。
- lossy decode 会改变原始名称字节。
- 语义 getter 会静默隐藏边界错误，不适合名称比较和查找。

## 最终采用方案

待定
