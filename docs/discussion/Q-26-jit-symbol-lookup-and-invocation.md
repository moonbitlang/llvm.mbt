# Q-26. 符号查找和本地函数调用应公开成什么模型 已解决

> 最后更新日期：2026-08-13
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

`LLVMOrcLLJITLookup` 只返回一个 executor address，并不知道该地址对应的函数签名。早期测试草稿用 `%identity` 把地址直接转换为任意 `FuncRef[T]`，但错误的参数类型、参数数量、返回类型或 calling convention 都会造成未定义行为。需要确定安全层是公开地址、公开带签名的调用对象，还是只提供 Kaleidoscope 所需的受限调用方法。

## 问题引发模型

### 最小复现例子

JIT 内实际定义：

```c
double answer(void);
```

若用户把同一地址声明为 `(Int, Int) -> Int` 再调用，LLVM lookup 仍然成功，因为 lookup 只检查符号名称。错误只能在进入机器码后表现为错误结果或崩溃，安全层无法从 executor address 自动恢复真实 ABI。

### 问题分析

LLVM C++ 的 `LLJIT::lookup` 同样只返回 `Expected<ExecutorAddr>`。官方 Kaleidoscope 随后调用 `ExecutorAddr::toPtr<double (*)()>()`，按调用者声明的函数类型做进程内地址转换；LLVM 不会验证该类型是否与 JIT 符号的真实 ABI 一致。因此，安全层无法通过枚举一组有限签名消除根本风险，最多只能改变风险出现的位置。

MoonBit 与 C++ 的额外差异在生命周期：C++ 用户通常以作用域显式保持 `LLJIT` 存活；MoonBit 的 `LLJIT` 由 GC 管理。如果 lookup 结果只是裸整数，JIT 可能在地址仍被使用时回收。公开地址对象可以保留 LLJIT owner，防止这种非显式销毁；但 ResourceTracker 的显式 remove 仍会使地址失效，且转换后的普通 `FuncRef` 本身无法继续携带 owner。

## 关联问题

1. [Q-25. LLJIT、已提交 Module 与 ResourceTracker 如何管理生命周期](Q-25-jit-resource-lifecycle.md)（生命周期约束：任何可保存的 lookup 结果都必须保留代码 owner）
2. [Q-28. ORC 错误应如何映射到安全层](Q-28-orc-error-model.md)（错误关系：未知符号和不支持签名不能压成同一种结果）
3. [Q-29. JIT 应建立怎样的测试闭环，何时可以开始 Kaleidoscope](Q-29-jit-test-and-kaleidoscope-entry.md)（验收关系：测试必须实际进入机器码并核对返回值）

## 建议的解决方案

### A1. 公开锚定 LLJIT 的 JITAddress 和 unsafe FuncRef 转换 【已采纳】

#### 方案描述

`lookup(name)` 返回公开的 `JITAddress`。该对象内部保存 executor address 并锚定产生它的 LLJIT owner，不直接公开 `%identity` 等编译器内建细节。

`JITAddress` 提供泛型 `unsafeToFuncRef[T]()` 转换。该操作明确要求调用者保证：

- `T` 与 JIT 符号的参数、返回值、calling convention 和平台 ABI 完全一致；
- 只用于当前进程 JIT；
- 调用期间对应的 LLJIT 与 `JITAddress` 仍然可达；
- 管理该符号的 ResourceTracker 尚未 remove。

转换得到的普通 `FuncRef[T]` 不拥有 `JITAddress`，因此不能单独延长 JIT 代码生命周期。地址转换与后续调用都属于显式 unsafe 契约；lookup 本身仍以 typed error 报告符号解析或 materialization 失败。

这一形态对应 LLVM C++ 的使用方式：

```cpp
auto address = cantFail(jit.lookup("__anon_expr"));
auto function = address.toPtr<double (*)()>();
double result = function();
```

MoonBit 侧的等价形态为：

```moonbit
let address = jit.lookup("__anon_expr")
let function : FuncRef[() -> Double] = address.unsafeToFuncRef()
let result = function()
```

#### 优点

- API 通用，不需要枚举参数和返回值的有限组合。
- 与 LLVM C++ 的 `ExecutorAddr::toPtr<T>()` 模型一致。
- JITAddress 锚定 LLJIT，可以防止 GC 在地址仍被持有时隐式销毁整个 JIT。
- lookup 错误与不安全的 ABI 类型断言保持为两个独立步骤。

#### 缺点

- 泛型类型参数不能证明真实机器码签名，错误转换产生未定义行为。
- ResourceTracker remove 后既有地址仍会悬空，JITAddress 无法阻止显式卸载。
- 转换后的 FuncRef 不能自动锚定 owner，调用者必须额外遵守可达性约束。
- 用户必须理解 C ABI、calling convention 和平台数据模型，接口不能宣称为安全调用抽象。

### A2. 公开若干带固定签名的可调用对象

#### 方案描述

提供 `lookupF64_0`、`lookupF64_1` 等方法，返回分别代表 `double ()`、`double (double)` 的 wrapper。wrapper 保留 LLJIT/JITModule owner，并通过对应 C trampoline 调用。

#### 优点

- 比裸地址安全，生命周期可以随 wrapper 锚定。
- 能逐步覆盖更多宿主直接调用场景。

#### 缺点

- lookup 时仍无法从 LLVM 自动验证符号真实签名，只是让调用者选择一个声明。
- 签名组合会快速膨胀，首期大部分并非 Kaleidoscope 必需。
- 需要决定 remove 与存活 wrapper 之间谁阻止谁。

### A3. 首期合并 lookup 与固定 double() 调用

#### 方案描述

安全层首期只提供与 Kaleidoscope 顶层表达式对应的同步方法，例如 `evaluateF64(name)`。该方法在一次调用中 lookup 符号，通过 C trampoline 按 `double (*)(void)` 调用，并返回 `Double`；executor address 不进入公开 API，也不在调用结束后保存。

其他参数签名在出现真实需求后，以新的显式 API 单独讨论。内部 raw 层仍可以保留 executor address 以实现安全方法，但 package 外不可见。

#### 优点

- 满足 Kaleidoscope 首期需求，同时把 ABI 风险限制在一个可测试的固定签名内。
- 地址不会逃逸，remove 和 LLJIT 生命周期更容易保证。
- 不会因追求表面通用而提前设计大量调用 wrapper。

#### 缺点

- 不能从 MoonBit 宿主直接调用带参数的 JIT 函数。
- 方法名称和文档必须明确它依赖 C ABI `double ()`，LLVM 仍不会验证符号定义。
- 后续扩展调用签名时仍需新增公开接口。

## 最终采用方案

A1. 公开锚定 LLJIT 的 JITAddress 和 unsafe FuncRef 转换
