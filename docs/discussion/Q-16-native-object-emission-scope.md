# Q-16. Native object emission 首期应绑定哪些 LLVM-C API 已解决

> 最后更新日期：2026-08-12
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

为了在 Kaleidoscope 之前建立可执行的 AOT 纵向闭环，需要确定第一批 Target/TargetMachine/Analysis 绑定的精确范围。本问题只决定产生当前宿主机 object file 所需的 raw LLVM-C 能力，不决定高层所有权或测试 API。

## 问题引发模型

### 最小复现例子

最小 host object emission 路径为：

```text
initialize native target + asm printer
  -> get host triple / CPU / features
  -> lookup Target
  -> create TargetMachine
  -> configure Module triple / DataLayout
  -> verify Module
  -> emit object file
```

### 问题分析

当前 `unsafe/TargetMachine.mbt` 已有 `LLVMGetTargetFromTriple`、`LLVMCreateTargetMachine`、`LLVMCreateTargetMachineWithOptions` 及相关 enum 的部分绑定，但 TargetMachine disposer、host triple/CPU/features、TargetMachine DataLayout 和 emit-to-file 仍处于注释状态。`unsafe/Analysis.mbt` 中的 module verifier 则指向尚未实现的自定义符号。

第一条闭环需要接通：

1. `LLVMInitializeNativeTarget` 与 `LLVMInitializeNativeAsmPrinter`。两者是头文件 `static inline`，需要本仓库 C adapter 提供可链接符号。
2. `LLVMGetDefaultTargetTriple`、`LLVMGetHostCPUName`、`LLVMGetHostCPUFeatures`，返回字符串均由 `LLVMDisposeMessage` 释放。
3. 现有 `LLVMGetTargetFromTriple` 与 `LLVMCreateTargetMachine`，并补充 NULL 创建失败处理。
4. 现有 `LLVMSetTarget`，以及待补充的 `LLVMDisposeTargetMachine`、`LLVMCreateTargetDataLayout`、`LLVMSetModuleDataLayout`、`LLVMDisposeTargetData`。
5. `LLVMVerifyModule`，使用 `LLVMReturnStatusAction` 取回诊断。
6. `LLVMTargetMachineEmitToFile`，使用 `LLVMObjectFile` 并处理 `char **ErrorMessage`。

字符串和 `char **` 错误消息应由 C adapter 在同一次调用中复制为 MoonBit `Bytes` 并释放 LLVM message，不向 MoonBit 暴露裸 `char *`。

## 关联问题

1. [Q-01. MoonBit String 到 C 输入字符串的表示与生命周期](Q-01-input-string-boundary.md)（依赖：输入 triple、CPU、features 和 filename 必须沿用已采纳的 `Utf8Z` 边界）
2. [Q-02. C 输出字符串的复制与释放责任](Q-02-output-string-boundary.md)（依赖：LLVM owned message 必须配对释放）
3. [Q-11. 测试补全应按什么顺序推进](Q-11-test-expansion-order.md)（实现关系：本闭环落在 Q-11 的 M3 raw 工具链互操作范围）

## 建议的解决方案

### A1. 一次绑定完整 TargetMachine 与全 target 能力 【不建议】

#### 方案描述

同时接入 all-target 初始化、cross-target 选择、TargetMachineOptions 全部字段、assembly 输出、memory-buffer 输出、target accessor 及其他 codegen 开关。

#### 优点

- 能一次得到接近 LLVM-C TargetMachine.h 的完整表面。
- 以后开发 cross-target 或 assembly 输出时无需再扩展 raw 绑定。

#### 缺点

- 将所有权、错误、跨平台配置和测试范围同时扩大。
- 很多 API 不参与第一条 object-link-run 闭环，无法通过当前用例充分验证。

### A2. 只绑定 host-only object emission 最小闭环 【已采纳】

#### 方案描述

只接通上述 native 初始化、host 描述、Target 查找、TargetMachine 创建/释放、Module DataLayout 配置、module verification 和 object-file emission。首期不绑定 asm parser、disassembler、all-target 初始化、memory-buffer emission、PassBuilder 或 linker。

#### 优点

- 每个新绑定都可以被同一条实际执行闭环覆盖。
- 不需要提前固化 cross-target 的公开类型与初始化策略。
- 与当前 macOS ARM64 和 Linux x86_64 宿主 CI 范围一致。

#### 缺点

- 首期不能用同一高层 API 生成其他 target 的 object。
- assembly 和 in-memory object 输出仍需后续扩展。

## 最终采用方案

A2. 只绑定 host-only object emission 最小闭环
