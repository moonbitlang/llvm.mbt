# Q-05. IR 对外 StringError 的建立与 LLVM 名称解码 已解决

> 最后更新日期：2026-08-04
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

`IR` 的公开 API 目前会直接暴露 `@unsafe.CStringError` 或向上传递 `@utf8.Malformed`。需要判断是否建立由 `IR` 包拥有的统一 `StringError`，并明确底层错误如何转换、哪些 API 应传播该错误。本问题同时记录 LLVM 的 `getName` 是否会失败，因为名称 getter 的异常来源决定了 `StringError` 的边界。

## 问题引发模型

### 问题复现

当前输入和输出字符串分别可能把底层包的错误带入 `IR`：

```moonbit
pub fn Module::addFunction(
  self : Self,
  fty : FunctionType,
  name : String,
) -> Function raise @unsafe.CStringError

pub fn Function::getName(self : Self) -> String raise {
  @unsafe.llvm_get_value_name(self.getValueRef())
}
```

前者把 C NUL-terminated 输入校验错误公开为 `@unsafe` 类型；后者的 LLVM 调用本身没有 operation failure，但把名称字节严格解码为 MoonBit `String` 时可能产生 `@utf8.Malformed`。

### 最小复现例子

LLVM 文本名称可以用 `\xx` 写入任意非零字节。例如名称字节 `0xff` 对 LLVM 是可保存和转义输出的名称，但不能严格解码成 UTF-8：

```llvm
@"\FF" = global i32 0
```

若名称只通过 MoonBit `String` 和当前安全 setter 写入，编码结果会是合法 UTF-8；但 IR/bitcode parser、`unsafe` API 和外部 native 代码都可以绕过这条路径，因此当前 `IR` 类型没有建立“名称一定是 UTF-8”的全局不变量。

### 问题分析

#### LLVM 的 `getName` 到底会不会失败

LLVM 的 [`Value::getName()`](https://github.com/llvm/llvm-project/blob/llvmorg-19.1.7/llvm/lib/IR/Value.cpp#L309-L316) 本身不会失败。它返回 `StringRef`；没有名字时返回长度为零的引用，是否有名字由 [`hasName()`](https://github.com/llvm/llvm-project/blob/llvmorg-19.1.7/llvm/include/llvm/IR/Value.h#L261-L284) 表示。`StringRef` 只是指针加长度，不提供 UTF-8 保证。

LLVM parser 会把名称中的 `\xx` 转回单个字节，并且对变量名称只拒绝 NUL，不校验 UTF-8。因此这里的失败发生在 binding 的 `Bytes -> String` 解码阶段，而不是 LLVM 的 getter 阶段。LLVM 的 [`LLVMGetValueName2`](https://github.com/llvm/llvm-project/blob/llvmorg-19.1.7/llvm/lib/IR/Core.cpp#L1019-L1027) 也只是返回名称指针和长度。

#### IR 错误边界

`CStringError` 描述的是 unsafe 层的 C ABI 条件，`@utf8.Malformed` 描述的是标准库解码细节；两者都不适合作为 `IR` 的稳定公开词汇。`IR` 应在 wrapper 边界显式捕获并转换，而不是只在签名上更名。已经有状态码、`Option` 或 `LLVMErrorRef` 等自然失败通道的 API，应保留原有错误模型，不必为了统一而一律 `raise StringError`。

本 binding 的安全 `IR` 层采用 UTF-8 作为 MoonBit `String` 与 LLVM 字节串之间的文本编码约定；`unsafe` 层仍保留 LLVM 原始字节语义。因此非 UTF-8 名称是安全层可明确报告的边界错误，不能被解释成 LLVM getter 自身失败，也不应通过占位字符串或 lossy decode 静默隐藏。

NUL 也不能只按“C string”统一判断：pointer + length API 不应自动拒绝 NUL，但 LLVM `Value::setName` 虽然接收长度，内部仍明确断言 Value 名称不得含 NUL。是否产生字符串错误应由目标 API 的实际约束决定。

## 关联问题

1. [Q-01. MoonBit String 到 C 输入字符串的表示与生命周期](Q-01-input-string-boundary.md)（来源：提供 `CStringError` 的底层输入边界）
2. [Q-02. C 输出字符串的复制与释放责任](Q-02-output-string-boundary.md)（来源：输出先复制为 `Bytes`，再发生 UTF-8 解码）
3. [Q-06. Value 派生对象与 Module 的 getName 返回模型](Q-06-get-name-return-model.md)（依赖：getter 是否传播 `StringError` 取决于返回模型）

## 建议的解决方案

### A1. IR 继续直接暴露底层错误 【不建议】

#### 方案描述

输入 API 继续公开 `@unsafe.CStringError`，输出解码失败继续传播 `@utf8.Malformed`；只按照实际错误数量补全或省略 `raise` 类型。

#### 优点

- 不需要新增错误类型或逐层转换。
- 调用者可以看到最接近失败来源的底层错误。

#### 缺点

- `IR` 的公开接口依赖 `unsafe` 和 UTF-8 标准库的实现细节。
- 同一种 IR 层字符串问题会出现不同错误类型。
- 以后替换底层字符串实现会影响 `IR` 用户。

### A2. 建立 IR.StringError 并在 wrapper 边界转换 【已采纳】

#### 方案描述

在 `IR` 包定义公开错误类型，初步形状为：

```moonbit
pub suberror StringError {
  ContainsNul
  MalformedUtf8(Bytes)
}
```

`ContainsNul` 表示目标 LLVM API 不接受输入中的 NUL，不把原因限定为 C 字符串截断；`MalformedUtf8` 表示 LLVM 返回的字节不能转换为 MoonBit `String`，错误路径复制一份 owned `Bytes`。`unsafe` 层继续保留精确的 `CStringError` 和 `@utf8.Malformed`，`IR` wrapper 在跨包边界时显式捕获并映射。

若函数只传播这一种错误，签名写明 `raise StringError`；若还必须传播另一种领域错误，才使用开放的 `raise`。具有自然失败通道的 API 根据原有模型消化错误，不强制抛出 `StringError`。

#### 优点

- `IR` 用户不依赖 `@unsafe` 类型和标准库解码错误结构。
- 输入 NUL 与输出 UTF-8 失败归入同一个 IR 层错误词汇，同时保留具体原因。
- 与已确定的 `raise` 类型标注规范一致。

#### 缺点

- 每个公开 wrapper 都需要显式转换，不能只修改类型声明。
- `ContainsNul` 是否适用于某个 pointer + length API，仍需逐个核对 LLVM 语义。
- getter 若选择 `Option` 或专用名称类型消化解码失败，不会统一表现为 `StringError`。

## 最终采用方案

A2. 建立 IR.StringError 并在 wrapper 边界转换
