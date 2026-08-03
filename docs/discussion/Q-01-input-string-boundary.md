# Q-01. MoonBit String 到 C 输入字符串的表示与生命周期 已解决

> 最后更新日期：2026-08-03
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

当前 `moonbit_str_to_c_str` 同时承担字符编码和临时内存分配，但调用它的 MoonBit wrapper 通常只把返回的 `CStr` 传给一次 LLVM 调用，没有在调用结束后释放。需要为 NUL-terminated 输入和 pointer + length 输入建立可审核的表示与生命周期规则。本问题只讨论输入边界，不讨论 LLVM operation error 或输出 ownership。

## 问题引发模型

### 问题复现

当前 MoonBit wrapper 的典型形状是：

```moonbit
pub fn llvm_module_create_with_name(module_id : String) -> LLVMModuleRef {
  let cstr = moonbit_str_to_c_str(module_id)
  __llvm_module_create_with_name(cstr)
}
```

当前 C 转换的核心逻辑是：

```c
char *ptr = malloc(len + 1);
for (int i = 0; i < len; i++) {
  if (ms[i] < 0x80) {
    ptr[i] = ms[i];
  } else {
    ptr[i] = '?';
  }
}
```

因此 `"月"` 会传成 `"?"`，而分配得到的 `ptr` 在 LLVM 调用返回后仍未释放。

### 最小例子

当前 native runtime 对 `String` 和 `Bytes` 的正常构造都会在逻辑长度之外保留一个元素，并写入终止零：

```c
moonbit_bytes_t moonbit_make_bytes_raw(int32_t len) {
  moonbit_bytes_t result = moonbit_malloc_array(..., len);
  result[len] = 0;
  return result;
}
```

core 标准库的非 Windows `OsString` 也直接使用 `@utf8.encode(str)` 得到的 `Bytes`，再通过 native FFI 传给要求 NUL-terminated 输入的环境变量 C API，没有额外追加终止零。

另外在 `/tmp` 创建 native 最小项目，通过 C stub 读取 `value[Moonbit_array_length(value)]`。空和非空的字面量、`Bytes::make`、`Bytes::makei`、`@utf8.encode` 以及 `String` 的测试结果全部为 `0`。因此当前 native ABI 下，`Bytes.length()` 不包含终止零，但底层存储在该位置提供零。

### 问题分析

输入边界包含两个相互独立但必须同时满足的条件：

1. MoonBit UTF-16 `String` 必须按 UTF-8 编码，而不是逐个 code unit 截断或替换。
2. 只供一次同步 C 调用使用的输入数据，在该调用返回后不应继续占有手工分配的内存。

把输入限制为 ASCII 只能暂时隐藏编码损坏，不能消除泄漏。只在现有 wrapper 后补 `free` 可以消除部分泄漏，但仍保留错误编码和语义模糊的通用 `CStr`。NUL-terminated API 与 pointer + length API 还需要区分：前者必须处理 embedded NUL，后者的长度必须是 UTF-8 byte length。

## 关联问题

1. [Q-02. C 输出字符串的复制与释放责任](Q-02-output-string-boundary.md)（一般关联：共同替代语义模糊的通用 `CStr`）
2. [Q-03. 字符串边界重构的改动与审核范围](Q-03-incremental-review-scope.md)（约束：本问题的实现必须独立、可分步审核）

## 建议的解决方案

### A1. 私有 TempUtf8Z/TempUtf8Span 与手写 C codec

#### 方案描述

沿用被撤销方案的输入结构：用 package-private `TempUtf8Z` 和 `TempUtf8Span` 区分 NUL-terminated 输入与 pointer + length 输入；在 C shim 中严格验证 UTF-16、编码 UTF-8并分配临时 buffer；MoonBit 通过 `with_temp_utf8_z/span` 和 `defer` 保证释放。

#### 优点

- 能精确报告 invalid surrogate 的位置、长度溢出和分配失败。
- `TempUtf8Z` 与 `TempUtf8Span` 明确表达不同的 embedded NUL 和长度规则。
- 不依赖 MoonBit 标准库 UTF-8 API的具体错误语义。

#### 缺点

- binding 自己维护完整 UTF-16 到 UTF-8 codec、状态码和测试。
- 输入仍是手工分配资源，需要 `defer` 和内部纪律防止逃逸或重复释放。
- 代码量较大，需要单独逐行审核 codec 的正确性。

### A2. 标准库 UTF-8 与 MoonBit-managed Bytes 【建议采纳】

#### 方案描述

使用 `@encoding/utf8.encode` 得到 UTF-8 `Bytes`。当前 native runtime 已在 `Bytes` 的逻辑末尾提供额外的零，因此 NUL-terminated 输入由私有 `Utf8Z(Bytes)` 表示并直接持有编码结果，不再复制一次来追加终止零。构造时仍必须显式拒绝 embedded NUL。pointer + length 输入由私有 `Utf8Span` 保存同类 `Bytes` 和 `Bytes.length()` 对应的 UTF-8 byte length。extern 参数使用 `#borrow`，输入内存由 MoonBit RC 管理，不使用通用 `CStr`、`malloc` 或 `CStr::free`。

概念形状为：

```moonbit
priv struct Utf8Z(Bytes)

fn Utf8Z::from_string(text : String) -> Utf8Z raise CStringError {
  guard !text.contains_code_unit(0) else {
    raise EmbeddedNul
  }
  Utf8Z(@utf8.encode(text))
}
```

#### 优点

- 字符编码由 MoonBit 标准库负责，binding 不维护重复 codec。
- 输入 buffer 是普通 MoonBit 值，没有单独的 libc 释放路径。
- 直接复用 `@utf8.encode` 的结果，不需要为了结尾 NUL 再分配和复制一次。
- private `Utf8Z`/`Utf8Span` 仍保留旧方案中正确的边界分类。
- 代码较少，便于逐行审核。

#### 缺点

- 当前 `@utf8.encode` 遇到 invalid surrogate 会 panic，而不是返回 binding 自定义 typed error。
- 尾随零是当前 native runtime 和 core 自身依赖的 ABI 行为，但 `Bytes` 的普通 API 文档没有把它描述成跨 backend 的语言级契约；本项目应保留一个 native FFI 回归测试。

## 最终采用方案

A2. 标准库 UTF-8 与 MoonBit-managed Bytes
