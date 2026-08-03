# Q-02. C 输出字符串的复制与释放责任 已解决

> 最后更新日期：2026-08-03
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

当前所有 C 字符串输出都表示为同一个 `CStr`，而 `c_str_to_moonbit_str*` 只复制内容、不释放源指针。它无法判断源指针是 borrowed、LLVM message，还是 LLVM error message。需要在输出边界中保留 ownership/disposer 信息，并确保复制后执行准确的释放操作。本问题暂不处理 nullable、二进制 buffer 或 LLVM operation error 的映射。

## 问题引发模型

### 问题复现

三个 ABI 形状相似的 LLVM 返回值具有不同规则：

```text
LLVMGetTargetName           -> borrowed const char *，不得释放
LLVMPrintModuleToString     -> char *，用 LLVMDisposeMessage
LLVMGetErrorMessage        -> char *，用 LLVMDisposeErrorMessage
```

当前 `LLVMPrintModuleToString` 的 wrapper 只执行：

```moonbit
let cstr = __llvm_print_module_to_string(m)
c_str_to_moonbit_str(cstr)
```

复制完成后 LLVM message 泄漏。`LLVMGetErrorMessage` 也只复制字符串；由于原指针没有返回给调用者，调用者无法再补上正确的 disposer。

### 最小复现例子

如果把 `LLVMPrintModuleToString` 的返回值直接声明为：

```moonbit
#external
priv type LLVMMessage
```

那么 MoonBit 侧得到的仍是可自由复制的裸指针。`priv` 只限制包外访问，不会让它参与 RC，也不会自动运行 disposer。

`../cstr_in_moonbit` 展示了另一种表示：MoonBit 侧声明普通 opaque `type CString`，C 侧用 `moonbit_make_external_object` 分配受 RC 管理的 external object，payload 内保存真实 `char *`，最后一个引用释放时由 runtime 调用注册的 finalizer。

### 问题分析

问题不是 `c_str_to_moonbit_str` 忘记统一调用 `free`，而是不存在一个对所有 `CStr` 都正确的统一释放函数：

- 给 borrowed pointer 调用任何 disposer 都是 invalid free。
- 给 LLVM message 调 libc `free` 不符合 LLVM API contract。
- `LLVMDisposeMessage` 与 `LLVMDisposeErrorMessage` 也不能互换。

因此转换 helper 必须知道来源；去掉这一来源信息，问题就无法在 helper 内正确解决。

## 关联问题

1. [Q-01. MoonBit String 到 C 输入字符串的表示与生命周期](Q-01-input-string-boundary.md)（一般关联：共同替代语义模糊的通用 `CStr`）
2. [Q-03. 字符串边界重构的改动与审核范围](Q-03-incremental-review-scope.md)（约束：输出边界应先以少量代表性接口验证）

## 建议的解决方案

### A1. 每个 LLVM 输出 API 使用专用 C wrapper

#### 方案描述

沿用被撤销第二版方案的强边界：LLVM 返回的字符串 pointer 不作为 MoonBit extern 返回值。每个输出 API 的 C wrapper 在同一次调用中取得 pointer、复制/解码为 MoonBit 值，并立即调用准确的 disposer；MoonBit 只收到 `String`。

#### 优点

- LLVM pointer 在结构上不能被 MoonBit 保存、重复转换或重复释放。
- 忘记 dispose、使用错误 disposer 和 decode error 跳过 dispose 都能由 wrapper 结构避免。
- public/private MoonBit API 都不需要表示 owned C pointer。

#### 缺点

- 需要为大量 LLVM 输出 API 编写或生成专用 C wrapper。
- nullable、长度和 operation status 容易在同一批 wrapper 中继续扩大改动范围。
- C shim 代码量较大，审核时需要在 MoonBit 声明、wrapper 和 LLVM contract 之间来回对应。

### A2. 私有裸 provenance 类型与集中 take helper

#### 方案描述

让 raw LLVM extern 返回 package-private、按来源区分的 nominal type，例如：

```moonbit
#external priv type BorrowedCString
#external priv type LLVMMessage
#external priv type LLVMErrorMessage
```

不为这些类型提供通用 `free`。`BorrowedCString` 只能交给 copy helper；`LLVMMessage` 只能交给在 C 中执行“复制为 Bytes + LLVMDisposeMessage”的 take helper；`LLVMErrorMessage` 使用对应的 error-message take helper。helper 返回 `Bytes` 后，再由 MoonBit `@utf8.decode` 转成 `String`。

模块打印的概念形状为：

```moonbit
extern "C" fn __llvm_print_module_to_string(
  module : LLVMModuleRef,
) -> LLVMMessage = "LLVMPrintModuleToString"

extern "C" fn __take_llvm_message(
  message : LLVMMessage,
) -> Bytes = "llvm_mbt_take_llvm_message"

fn LLVMMessage::into_string(self : LLVMMessage) -> String raise {
  __take_llvm_message(self) |> @utf8.decode
}
```

C helper 在返回 `Bytes` 前已经 dispose message，因此后续 UTF-8 decode 失败不会泄漏原指针。

#### 优点

- nominal type 保留 disposer provenance，borrowed pointer 没有 dispose 能力。
- copy/take helper 可被同类 LLVM API 复用，不必为每个 getter 编写完整 C wrapper。
- 通用 `CStr` 和通用 `CStr::free` 可以删除。
- UTF-8 解码由 MoonBit 标准库负责，核心 helper 较小，便于审核。

#### 缺点

- pointer 会短暂进入 package-private MoonBit 代码，不具有 A1 的完全结构性隔离。
- MoonBit 当前没有 affine ownership；包内代码若复制同一个 private pointer 并重复 take，类型系统不能完全阻止。
- “先复制为 Bytes，再解码为 String”比 C 中直接构造 MoonBit String 多一个临时对象和一次复制。

### A3. Managed owned output 与立即复制的 borrowed output 【建议采纳】

#### 方案描述

输出字符串先按 ownership 分为 owned 和 borrowed，两类使用不同的边界表示。

对于 `LLVMPrintModuleToString`、`LLVMGetErrorMessage` 这类 owned output，MoonBit 侧使用普通 opaque type，不标记 `#external`：

```moonbit
priv type LLVMMessage

extern "C" fn __llvm_print_module_to_string(
  module : LLVMModuleRef,
) -> LLVMMessage = "llvm_mbt_print_module_to_string"

#borrow(message)
extern "C" fn __llvm_message_copy_bytes(
  message : LLVMMessage,
) -> Bytes = "llvm_mbt_llvm_message_copy_bytes"

fn llvm_print_module_to_string(module : LLVMModuleRef) -> String raise {
  let message = __llvm_print_module_to_string(module)
  __llvm_message_copy_bytes(message) |> @utf8.decode
}
```

对应的 C wrapper 不把 LLVM 返回的裸 `char *` 直接交给 MoonBit，而是创建 managed external object。payload 保存真实 pointer，C finalizer 固定调用该类型对应的 LLVM disposer：

```c
struct llvm_mbt_llvm_message {
  char *ptr;
};

static void llvm_mbt_finalize_llvm_message(void *payload) {
  struct llvm_mbt_llvm_message *message = payload;
  if (message->ptr != NULL) {
    LLVMDisposeMessage(message->ptr);
    message->ptr = NULL;
  }
}

void *llvm_mbt_print_module_to_string(LLVMModuleRef module) {
  struct llvm_mbt_llvm_message *message = moonbit_make_external_object(
    llvm_mbt_finalize_llvm_message,
    sizeof(struct llvm_mbt_llvm_message)
  );
  message->ptr = LLVMPrintModuleToString(module);
  return message;
}
```

`LLVMErrorMessage` 使用另一个 opaque type、payload 和固定调用 `LLVMDisposeErrorMessage` 的 C finalizer，不与 `LLVMMessage` 共用可互换的裸指针类型。owned wrapper 只提供借用式 `copy_bytes`/`to_string` 操作，不提供显式 `dispose`：MoonBit 没有 affine ownership，同一 owner 若存在别名，任一别名提前 dispose 都会使其他别名失效。最后一个引用释放时运行 finalizer，别名共同持有同一个 owner；UTF-8 decode 失败或调用路径提前返回也不会遗漏底层字符串的释放。

对于 `LLVMGetTargetName` 这类 borrowed output，不创建 owner，也不注册 finalizer，因为 binding 不拥有 pointer，managed box 也不能延长 LLVM parent 的生命周期。C wrapper 在调用 LLVM getter 后立即把内容复制为 MoonBit `Bytes`，MoonBit 只接收复制结果，再用 `@utf8.decode` 转成 `String`；borrowed pointer 不作为可保存的值进入 MoonBit。

#### 优点

- owned C pointer 不再是 MoonBit 的非 RC scalar，别名共同持有同一个 owner。
- 不要求每条 MoonBit error path 手工调用 disposer，遗漏时由 finalizer 兜底。
- 不提供通用 `CStr::free`；每种 owner 在构造时固定正确 disposer。
- borrowed output 通过立即复制避免悬垂 pointer，finalizer 不被错误用于非 owner。

#### 缺点

- 每个 owned C string 需要额外分配一个 external-object owner box。
- 为了让 raw pointer 不进入 MoonBit，产生 owned string 的 LLVM API 仍需要 C wrapper 负责创建 owner box。
- 释放时机由最后一个引用何时释放决定；有长生命周期别名时，底层 message 会相应延迟释放。
- managed owner 和 borrowed copy 需要两种 C wrapper，不能再用一个通用输出 helper 覆盖所有来源。

## 最终采用方案

A3. Managed owned output 与立即复制的 borrowed output
