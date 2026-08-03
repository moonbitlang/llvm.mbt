# Q-04. Owned CString 的 finalizer 应写在 MoonBit 还是 C 已解决

> 最后更新日期：2026-08-03
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

Q-02 的 managed external object 方案需要为 owned C string 注册 finalizer。当前 MoonBit runtime 既接受普通 C function pointer，也能通过 `FuncRef` 注册 capture-free MoonBit 函数。本问题只决定 finalizer 的实现位置，不重新讨论 output ownership 分类。

## 问题引发模型

### 问题复现

`../cstr_in_moonbit` 使用以下 MoonBit finalizer：

```moonbit
type CString

extern "C" fn make_cstring(
  finalizer : FuncRef[(CString) -> Unit],
) -> CString = "make_cstring_in_mbt"

let cstring_finalizer : FuncRef[(CString) -> Unit] = fn(s) {
  release_cstring_in_c(s)
}
```

C 构造函数调用：

```c
moonbit_make_external_object(finalize, sizeof(struct CString));
```

最小项目以 native target 运行后，普通业务输出结束时确实执行了 MoonBit finalizer。runtime 的 drop 路径会取出 external object payload 后保存的 finalizer pointer，并在释放容器前调用它。

### 问题分析

两种实现最终都必须调用 LLVM 的 C disposer。差别主要在 finalizer 是否先进入 MoonBit：MoonBit finalizer 让策略在 MoonBit 源码中可见，但要求 callback 是适合 runtime drop 路径的静态 `FuncRef`；C finalizer 则可以直接读取 payload 并调用对应 disposer，不需要回到 MoonBit。

无论选择哪种实现，finalizer 都只能释放 payload 持有的底层资源，不能释放 external-object 容器本身；容器由 runtime 负责。

## 关联问题

1. [Q-02. C 输出字符串的复制与释放责任](Q-02-output-string-boundary.md)（依赖：仅在 Q-02 采用 managed external object 时需要决定）
2. [Q-03. 字符串边界重构的改动与审核范围](Q-03-incremental-review-scope.md)（约束：两种 finalizer 应通过独立最小实现比较）

## 建议的解决方案

### A1. MoonBit FuncRef finalizer

#### 方案描述

像 `cstr_in_moonbit` 一样，把 capture-free MoonBit 函数作为 `FuncRef[(CString) -> Unit]` 传给 C constructor，由 `moonbit_make_external_object` 注册。finalizer 再调用一个 C extern 释放 payload 中的字符串。

#### 优点

- finalization 策略及类型对应关系在 MoonBit 源码中可见。
- 已有 native 最小项目证明当前工具链能够执行这一模式。
- 将来若 finalizer 需要少量 MoonBit 侧 bookkeeping，不必把逻辑全部放进 C。

#### 缺点

- 实际 LLVM disposer 仍是 C API，因此会多一次 MoonBit callback 到 C extern 的跳转。
- runtime drop 路径会进入 MoonBit 代码；finalizer 必须保持 capture-free、不可失败且足够简单。
- finalizer 若 panic、阻塞或执行复杂分配，会使资源释放路径更难推理。

### A2. C finalizer 【建议采纳】

#### 方案描述

C constructor 直接把一个 `void (*)(void *)` finalizer 交给 `moonbit_make_external_object`。payload 保存底层 `char *`，finalizer 调用固定的 LLVM disposer；也可以由 payload 中的 disposer tag/function pointer 选择正确的释放函数。为了让第一步容易审核，先为 `LLVMMessage` 使用一个固定调用 `LLVMDisposeMessage` 的小 finalizer，不在同一步引入通用 disposer function pointer；`LLVMErrorMessage` 留到后续单独处理。

#### 优点

- finalizer 直接调用 LLVM C disposer，不进入 MoonBit 代码。
- finalizer 可以保持不可失败、无分配、幂等的很小函数。
- 与 runtime 公开的 `moonbit_make_external_object` C contract 直接对应，审核路径较短。

#### 缺点

- ownership/disposer 映射有一部分位于 C shim，需要确保 MoonBit constructor 与 C payload 类型一致。
- 如果为每类 string owner 编写独立 finalizer，会增加少量 C adapter；使用通用 disposer function pointer 则需要额外审核函数指针签名。

## 最终采用方案

A2. C finalizer
