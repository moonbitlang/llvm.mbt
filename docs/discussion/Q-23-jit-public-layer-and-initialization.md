# Q-23. JIT 应采用什么公开层次和初始化模型 已解决

> 最后更新日期：2026-08-13
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

ORC raw handle 已经位于模块内部的 `internal/raw` package，正式能力还需要一个不会暴露 LLVM-C 所有权细节的安全层。需要决定 LLJIT 类型放在现有 `IR` package 还是独立公开 package，以及 host 初始化、target 配置和当前进程符号生成器由谁完成。

## 问题引发模型

### 问题分析

根目录下的 `JIT` package 与 `IR` package 一样，可以直接导入模块内部的 `internal/raw`，因此建立独立 JIT package 本身不需要新增 raw package 的可见性机制。真正的边界在于：JIT 可以使用 `IR` 的公开 API，但不能访问 `Module::get_raw_ref` 等 `IR` package 私有成员。

Q-24 采用 bitcode 快照后，JIT 不需要取得 `LLVMModuleRef`。`IR` 只需提供与 JIT 无关的内存 bitcode 快照能力，例如 `Module::writeBitCodeToBytes()`；JIT 再使用 `internal/raw` 在独立 Context 中解析该快照。这个窄接口不会让 `IR` 依赖 JIT，也不会公开 raw handle。

另一方面，JIT 在概念上并不属于 IR 构造本身。长期把所有 ORC 对象放入 `IR` 会扩大该 package 的职责。需要在首期实现成本和长期包边界之间作出选择。

host JIT 与现有 `TargetMachine::host()` 类似，都需要 native target 和 asm printer 初始化。Q-17 已采用“公开显式初始化，同时让 host convenience 自动确保前置条件”的分层模式，JIT 不宜再建立另一套全局初始化语义。

## 关联问题

1. [Q-17. Native target 初始化应显式调用还是由 host TargetMachine 自动完成](Q-17-native-target-initialization.md)（契约复用：JIT host convenience 应沿用已采用的分层初始化模型）
2. [Q-22. ORC LLJIT 首期应覆盖哪些能力](Q-22-orc-lljit-initial-scope.md)（前置依赖：首期范围决定安全层对象数量）
3. [Q-24. Module 应如何安全提交给 JIT](Q-24-module-submission-ownership.md)（实现依赖：package 边界必须允许安全地访问 Module）
4. [Q-27. JIT 代码应如何访问宿主函数和动态库符号](Q-27-jit-host-symbol-resolution.md)（契约关系：是否默认安装当前进程生成器属于 host 构造语义）

## 建议的解决方案

### A1. 首期建立独立公开 JIT package

#### 方案描述

新建公开 `JIT` package，将 `LLJIT`、提交句柄和错误类型放入其中；同时为 `IR` 增加受控的跨 package 内部桥接，使 JIT 可以读取 Module 或生成提交快照，而不向模块外用户暴露 raw handle。

#### 优点

- package 职责清楚，IR 构造与执行引擎相互独立。
- 以后扩展多个 JIT 实现或高级 ORC 类型时不继续扩大 `IR` package。

#### 缺点

- 当前没有现成的跨 package 私有桥接，需要先解决 MoonBit 可见性和内部 API 形状。
- 若为了尽快实现而把 raw ref 公开到 `.mbti`，会破坏安全层边界。
- 首期工作会同时包含 JIT 设计和 package 架构重构。

### A2. 首期将安全 LLJIT 放在 IR package

#### 方案描述

把 `LLJIT`、`JITModule` 和 `JITError` 先放在现有 `IR` package 内，直接复用私有 Module/Context owner 边界。`LLJIT::host()` 自动调用与 `TargetRegistry::initializeNativeCodegen()` 相同的幂等初始化路径；高级用户仍可显式提前初始化。

`LLJIT::host()` 是否默认安装当前进程符号生成器由 Q-27 决定。首期不公开 LLJITBuilder 或 cross-target 构造；未来需要独立 package 时，再以稳定的安全层数据流为依据拆分。

#### 优点

- 不需要公开 raw handle，也不需要先发明跨 package 私有桥接。
- 能直接复用现有 `Module::verify`、target 配置和 owner 测试设施。
- host convenience 与已经采用的 TargetMachine 初始化模式一致。

#### 缺点

- `IR` package 同时承担构造与执行职责。
- 若未来拆成独立 `JIT` package，可能发生一次公开 API 路径迁移。

### A3. 先设计模块内部桥接，再建立独立 JIT package

#### 方案描述

不公开 raw handle，也不把 JIT 放入 `IR`；先增加只允许本模块内部 package 使用的 IR bridge，由它负责从 Module 生成不透明提交载荷，独立 `JIT` package 只消费该载荷。

#### 优点

- 从第一版起保持独立 package，同时保住 `internal/raw` 边界。
- bridge 可以成为以后其他内部工具消费 IR 的通用边界。

#### 缺点

- 需要先确认 MoonBit 当前版本对模块内部可见性的精确支持和 `.mbti` 行为。
- 不透明载荷本身也有生命周期和失败契约，可能只是把 Q-24 向另一层移动。
- 当前只有 JIT 一个消费者，抽象是否稳定缺少实现证据。

### A4. 独立 JIT package 使用 IR 的中性 bitcode 快照接口 【已采纳】

#### 方案描述

在仓库根目录新建公开 `JIT` package。该 package 直接导入 `internal/raw`，不需要额外的 raw 可见性桥接，也不访问 `IR` 的私有 owner 或 raw ref。

`IR` 增加与 JIT 无关的公开内存 bitcode 快照能力，例如 `Module::writeBitCodeToBytes()`。`JIT::addModule` 只借用 `IR::Module` 并取得这份快照，然后通过 `internal/raw` 在独立 Context 中解析并提交给 LLJIT。host 初始化继续复用 `TargetRegistry::initializeNativeCodegen()` 已建立的幂等语义。

#### 优点

- 从第一版起保持 IR 与 JIT 的 package 职责分离。
- 根目录 JIT 可以直接访问 `internal/raw`，不需要新增模块内部可见性机制。
- IR 不依赖 JIT，也不向 `.mbti` 暴露 `LLVMModuleRef` 或 owner control block。
- 内存 bitcode 快照本身是通用 IR 能力，不只服务于 JIT。

#### 缺点

- 仍需给 IR 增加一个很窄的公开快照 API。
- bitcode 快照涉及一次内存复制，并延续 Q-24 中的序列化和解析成本。
- 若未来增加 consuming 的零复制提交路径，JIT 与 IR 之间还需要新的受控接口。

## 最终采用方案

A4. 独立 JIT package 使用 IR 的中性 bitcode 快照接口
