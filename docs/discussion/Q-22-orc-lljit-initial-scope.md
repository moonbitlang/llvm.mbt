# Q-22. ORC LLJIT 首期应覆盖哪些能力 已解决

> 最后更新日期：2026-08-13
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

llvm.mbt 已经具备 host native object emission，下一步希望为 Kaleidoscope 建立进程内执行能力。仓库中虽然存在很早期的 LLJIT、ORC 和 ExecutionEngine 草稿，但这些绑定没有兼容负担，可以废弃。需要先确定新的 JIT 首期边界，避免把 ORC 的完整能力面一次性带入公开 API。

## 问题引发模型

### 问题复现

使用仓库当前缓存的 LLVM 22.1.0 头文件和 `libLLVM-mbt.a`，已经在临时 C 探针中验证：

1. 创建 LLVM IR Module；
2. 创建默认 host LLJIT；
3. 设置 LLJIT 的 target triple 与 DataLayout；
4. 提交 ThreadSafeModule；
5. lookup 并调用一个 `double ()` 函数。

探针实际返回 `42.0`。静态库也已确认包含 LLJIT 创建、Module 提交、lookup、ResourceTracker 和当前进程符号生成器所需符号，因此首期不需要重新制作 LLVM 构建产物。

### 问题分析

Kaleidoscope 的第一条执行闭环只要求同步地提交 IR、查找入口并在当前进程调用。cross-target JIT、lazy compilation、并发编译、object cache、自定义 JITDylib 和完整优化 pipeline 都可以独立演进，不应成为第一条闭环的前置条件。

旧的 ExecutionEngine/MCJIT 接口无法代表 LLVM 当前推荐的 ORC 模型，现有草稿又没有建立可靠的错误和所有权契约。继续修补旧草稿会把临时函数形状带入安全层，因此需要按 LLVM 22.1 的 ORC LLJIT 契约重新建立绑定。

## 关联问题

1. [Q-16. Native object emission 首期应绑定哪些 LLVM-C API](Q-16-native-object-emission-scope.md)（前置经验：继续采用由可执行闭环反推最小绑定范围的方法）
2. [Q-23. JIT 应采用什么公开层次和初始化模型](Q-23-jit-public-layer-and-initialization.md)（后续依赖：首期范围决定需要公开的类型和构造路径）
3. [Q-29. JIT 应建立怎样的测试闭环，何时可以开始 Kaleidoscope](Q-29-jit-test-and-kaleidoscope-entry.md)（验收关系：测试应完整覆盖本问题采用的能力范围）

## 建议的解决方案

### A1. 一次接入较完整的 ORC 能力面 【不建议】

#### 方案描述

除基本 LLJIT 闭环外，同时接入自定义 LLJITBuilder、JITTargetMachineBuilder、多个 JITDylib、通用 ExecutionSession lookup、absolute symbols、object file 提交、lazy compilation、并发编译和 object cache，并为这些能力设计公开高层对象。

#### 优点

- 更接近 LLVM-C ORC API 的完整表面。
- 后续高级 JIT 用例不必反复扩展 raw 绑定。

#### 缺点

- 同时引入多种所有权转移、回调和异步 lookup 契约，首期难以充分验证。
- Kaleidoscope 不需要其中大部分能力，公开 API 容易被未经使用的 LLVM-C 形状主导。
- 会把 Module 所有权、函数调用 ABI 和资源卸载三个核心问题淹没在外围能力中。

### A2. 建立 host-only ORC LLJIT 最小闭环 【已采纳】

#### 方案描述

废弃现有早期草稿的函数形状，首期只接通：

- host LLJIT 创建与销毁；
- LLJIT target triple、DataLayout 和 main JITDylib；
- IR Module 安全提交；
- ResourceTracker 创建、卸载和释放；
- main JITDylib 中的符号查找；
- executor address lookup 与显式 unsafe FuncRef 转换；
- 当前进程宿主符号解析；
- LLVM Error 的完整转换和消费。

首期不接入 cross-target JIT、lazy compilation、并发编译、object cache、自定义 JITDylib、通用回调或完整 PassBuilder 优化。

#### 优点

- 每项新绑定都能被同一条实际执行链覆盖。
- 足以支持 Kaleidoscope 的函数定义、顶层表达式和外部数学函数。
- 保留以后按真实用例扩展 ORC 的空间，不提前冻结外围公开类型。

#### 缺点

- 首期不是通用 JIT 框架，不能表达任意 ORC 配置。
- 后续高级需求仍需增加新的 raw 绑定和安全层抽象。

## 最终采用方案

A2. 建立 host-only ORC LLJIT 最小闭环
