# Q-29. JIT 应建立怎样的测试闭环，何时可以开始 Kaleidoscope 已解决

> 最后更新日期：2026-08-13
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

只检查 JIT 对象能够创建或 lookup 返回非零地址，不能证明 Module 所有权、ABI 调用、跨 Module 符号解析、宿主函数解析和资源卸载正确。需要定义一组进入 Kaleidoscope 移植前必须通过的测试，并决定测试放置、raw 与安全层覆盖，以及是否需要 async。

## 问题引发模型

### 最小复现例子

第一条公开 API 测试可以构造：

```llvm
define double @answer() {
entry:
  ret double 4.200000e+01
}
```

测试必须实际经过 Module 配置、验证、提交、lookup 和 C ABI 调用，并检查返回值为 `42.0`。仅 inspect LLVM 文本无法覆盖 LLJIT 编译、object linking layer 和机器码调用。

### 问题分析

JIT 创建、提交、lookup 和本地调用都是当前进程内的同步 API，不需要 `moonbitlang/async/process`。async 在以后实现交互式 REPL 输入时可能有用，但不属于 JIT binding 的测试依赖。公开测试按照 Q-26 已采用的契约，把 JITAddress 以测试中已知的正确 C ABI 转换为 FuncRef 并实际调用；测试不会把这项 unsafe 类型断言误写成可由 LLVM 验证的安全操作。

测试需要分层：raw 白盒测试验证每个 LLVM-C handle 的所有权转移和 Error 消费；公开 API 测试验证用户可观察的 target 配置、快照隔离、调用与卸载语义。最终还要在 macOS ARM64 与 Linux x86_64 CI 上实际运行，以覆盖 JIT linker 和宿主 symbol visibility 的平台差异。

## 关联问题

1. [Q-11. 测试补全应按什么顺序推进](Q-11-test-expansion-order.md)（测试规划：JIT 属于新的工具链互操作闭环）
2. [Q-21. Native object 应如何建立 link-and-run 端到端测试](Q-21-native-object-execution-test.md)（方法对照：二者都必须实际执行机器码，但 JIT 不需要子进程）
3. [Q-24. Module 应如何安全提交给 JIT](Q-24-module-submission-ownership.md)（必须验证：原 Module 与提交快照彼此独立）
4. [Q-25. LLJIT、已提交 Module 与 ResourceTracker 如何管理生命周期](Q-25-jit-resource-lifecycle.md)（必须验证：remove 和 owner 销毁顺序）
5. [Q-27. JIT 代码应如何访问宿主函数和动态库符号](Q-27-jit-host-symbol-resolution.md)（必须验证：跨平台宿主符号解析）

## 建议的解决方案

### A1. 只做 raw smoke test 和地址检查 【不建议】

#### 方案描述

测试 LLJIT 能创建、Module 能提交、lookup 返回非零 executor address；不实际调用机器码，不覆盖跨 Module、宿主符号和 remove。

#### 优点

- 用例少，失败定位直接落在 raw binding。
- 不需要 C 调用 trampoline。

#### 缺点

- 无法验证函数 ABI、机器码语义和地址调用是否正确。
- 不会暴露原 Module 与 ThreadSafeModule 双重所有权问题。
- 无法证明接口足以支撑 Kaleidoscope。

### A2. 建立分层的实际执行与生命周期闭环 【已采纳】

#### 方案描述

raw 白盒测试覆盖：

- LLJIT、ThreadSafeContext、ThreadSafeModule 和 ResourceTracker 的创建、转移、释放；
- 每个 `LLVMErrorRef` 的成功和失败消费；
- target triple、DataLayout 和 global prefix；
- 默认 process-symbols JITDylib 的创建与宿主符号可见性。

公开安全层测试至少覆盖：

1. 执行 `double () { return 42.0; }`；
2. 一个 Module 定义永久函数，另一个 Module 的顶层表达式调用它；
3. JIT 代码调用 `sin` 等 libm 宿主符号；
4. unknown symbol 返回带诊断的 typed error；
5. 原 Module 在提交后仍可使用和销毁；
6. 提交后修改原 Module，不影响已经提交的快照；
7. 临时 Module remove 后符号不再可查找；
8. alias、重复卸载和不同 owner 销毁顺序不造成双重释放；
9. 同一进程反复创建、执行和卸载多个 JIT 会话；
10. macOS ARM64 与 Linux x86_64 CI 都实际执行上述关键路径。

这些测试通过后，即认为 JIT binding 已经足以开始 `examples/kaleidoscope`。首个 Kaleidoscope 阶段仍可以从 lexer/parser/codegen 开始逐章移植；完整 REPL、PassBuilder 优化和高级 ORC 能力另行规划。

#### 优点

- 直接证明 JIT 能执行真实机器码，而不只是返回 handle。
- 所有权、错误、ABI 和跨平台符号解析都有对应回归测试。
- 形成明确的 Kaleidoscope 开工门槛。

#### 缺点

- 测试数量和 native owner 测试设施明显多于 smoke test。
- Linux 当前进程自定义符号可能需要额外 linker 配置和专门用例。
- 失败可能横跨 IR、ORC、JIT linker 和宿主 ABI，需要分层测试辅助定位。

## 最终采用方案

A2. 建立分层的实际执行与生命周期闭环
