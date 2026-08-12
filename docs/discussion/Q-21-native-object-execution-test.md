# Q-21. Native object 应如何建立 link-and-run 端到端测试 已解决

> 最后更新日期：2026-08-12
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

只检查 LLVM 文本或 object 文件存在，不能证明机器码、object format、ABI 和 linker 互操作正确。需要决定 native object emission 是否要在 MoonBit 测试中调用系统 C compiler driver 链接 object，并实际启动结果程序。

## 问题引发模型

### 最小复现例子

第一个语义用例可以让 LLVM Module 导出：

```c
double average(double x, double y);
```

仓库内的小型 C harness 调用 `average(3.0, 4.0)`，打印 `3.5` 并以比较结果决定 exit code。测试闭环为：

```text
MoonBit 构造 IR
  -> verify
  -> emit average.o
  -> cc harness.c average.o -o average-test
  -> run average-test
  -> 检查 linker/executable exit code、stdout 和 stderr
```

### 问题分析

`moonbitlang/async/process` 已提供 `run`、`collect_output` 和子进程取消；`async/fs` 提供原子创建的临时目录。使用该库时，只有最外层端到端测试需要写成 `async test`，Parser、IR、TargetMachine 与 object emission API 仍然保持同步。

## 关联问题

1. [Q-11. 测试补全应按什么顺序推进](Q-11-test-expansion-order.md)（具体实例：对应 M3 中的 emit object 端到端互操作测试）
2. [Q-16. Native object emission 首期应绑定哪些 LLVM-C API](Q-16-native-object-emission-scope.md)（依赖：必须先有可用的 host object emission）

## 建议的解决方案

### A1. 只验证 verifier、IR 文本和 object 文件 【不建议】

#### 方案描述

验证 Module 合法、IR 文本符合预期，并检查 emission 成功产生非空 object 文件，不在 MoonBit 测试中运行 linker 和生成物。

#### 优点

- 测试不需要额外 MoonBit async/process 依赖。
- 不依赖系统 C compiler driver 的可用性和平台链接行为。

#### 缺点

- 无法检查 object format、符号命名、calling convention、linker 兼容性与实际机器码语义。
- 仍然只是结构或文件层验证，不能支撑 Kaleidoscope 的语义闭环。

### A2. 用 async/process 建立 host-only link-and-run 测试 【已采纳】

#### 方案描述

在专用 native emission 端到端测试包中，以 test-only 依赖引入 `moonbitlang/async/process` 和 `async/fs`。每个用例使用独立临时目录，直接以 argv 调用 `cc`，不经由 shell；链接和运行均收集 stdout/stderr、检查 exit code 并设置超时。

`IR` 与 TargetMachine 正式包不依赖 async，也不提供 `emitExecutable` 或子进程 API。链接与执行只是测试/工具最外层的宿主编排。

#### 优点

- 同时验证 IR、codegen、object、ABI、系统 linker 和真实执行结果。
- structured concurrency 可以在测试取消或超时时清理子进程。
- async 依赖不会污染 LLVM 绑定的同步公开 API。

#### 缺点

- 测试环境必须提供可用的 `cc` 和宿主 linker。
- 这类用例是 host-only 工具链集成测试，不能代表 cross-target object 可以在当前宿主执行。
- 需要确保临时文件、并行测试命名和超时清理稳定。

## 最终采用方案

A2. 用 async/process 建立 host-only link-and-run 测试
