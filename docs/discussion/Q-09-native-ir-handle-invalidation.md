# Q-09. Native IR 节点删除后的派生句柄失效模型 待讨论

> 最后更新日期：2026-08-06
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

Q-08 已通过 owner anchor 保证 Module-owned handle 不会活得比 `Module` 更久，但 safe `IR` 包仍允许主动删除 native IR 节点。需要确定同一节点的其他 wrapper、被级联删除的 child wrapper，以及仍指向被删节点的 `IRBuilder` 应如何失效；同时需要决定 safe 层是否应提供比 LLVM C++ raw pointer 更强的动态安全保证。

本问题只讨论 native IR 节点失效，不重新讨论 `Context`、`Module` 的回收，也不在此决定 Context-owned constant 的全部失效规则。

## 问题引发模型

### 问题复现

`BasicBlock::getFirstInst` 等 getter 每次都可以为同一个 `LLVMValueRef` 构造新的 MoonBit wrapper。`Instruction::eraseFromParent` 随后调用 `LLVMInstructionEraseFromParent` 删除 native instruction，但另一个 wrapper 中仍保存原来的 raw pointer。

### 最小复现例子

```moonbit
let first = block.getFirstInst().unwrap()
let alias = block.getFirstInst().unwrap()

first.eraseFromParent()
alias.getType() // alias 内部的 LLVMValueRef 已经悬空
```

如果去掉 `eraseFromParent`，Q-08 建立的 `Instruction -> Module -> Context` anchor 可以保证 raw pointer 的 lifetime owner 存活；加入节点删除后，`Module` 仍然存活却不再拥有这个 instruction，因此 parent anchor 无法阻止 `alias` 成为悬空句柄。

### 问题分析

当前问题包含三种相关但不同的失效：

1. `Instruction::eraseFromParent` 立即删除 instruction，同一 raw pointer 的其他 wrapper 随即悬空。
2. `BasicBlock::eraseFromParent` 删除 BasicBlock 及其中的 instructions，已有的 block、child instruction wrapper 和 Builder insertion point 都可能失效。
3. `removeFromParent` 不立即删除节点，而是把它变成 detached object。当前 wrapper 只有 parent anchor，没有负责最终删除 detached node 的独立 owner，因此还存在释放责任不闭合的问题。

LLVM C++ 的普通 `Instruction*`、`BasicBlock*` 也具有同样的危险。它要求调用者在 `eraseFromParent` 后停止使用旧 raw pointer，同时提供可选的 `WeakVH`、`WeakTrackingVH`、`AssertingVH` 和 `TrackingVH`。这些 `ValueHandle` 不是 raw pointer 的默认表示，LLVM C API 也没有直接暴露它们。

其他 binding 的现状不能提供一个可以直接照搬的完整答案：

- 当前 Inkwell 将 `BasicBlock::delete`、`FunctionValue::delete` 和 Global 删除标为 `unsafe`，但 `InstructionValue::erase_from_basic_block` 仍是 safe 方法，而 `InstructionValue` 实现了 `Copy`；其源码还保留了该方法可能不安全的 REVIEW。使用 Inkwell 0.10.0 与 LLVM 19 的最小实验中，删除前 opcode 为 `Return`，从复制的旧句柄读取时变成了无关的 `CatchSwitch`。另一个 safe Rust 实验允许 `FunctionValue` 活过 owning Module，Module 析构后读取到空函数名。这说明 Inkwell 的 Context lifetime 和部分 `unsafe` 标记没有普遍解决 Module child 与 mutation invalidation。
- llvmlite 的常用 `ir` 层采用纯 Python IR 对象；`IRBuilder.remove` 只从 Python list 移除 instruction，旧 Python 别名仍是存活对象，因此规避了 native use-after-free。它的 `binding.ValueRef` 只保活 parent，并没有节点删除通知。使用 llvmlite 0.48.0 与 LLVM 22.1 的实验中，DCE 删除 instruction 后，旧 `ValueRef` 的部分属性返回空值或错误类型，格式化旧值的独立进程以 segmentation fault 退出。

因此，“其他 binding 也存在同类问题”只能说明这是 LLVM binding 的共同难点，不能决定 llvm.mbt 的 safe 层是否应继续采用 raw-pointer discipline。

## 关联问题

1. [Q-08. 派生 IR 对象的 owner 持有关系与迁移顺序](Q-08-derived-handle-owner-anchors.md)（来源与扩展：Q-08 解决 parent lifetime，本问题处理 parent 仍存活时的节点级失效）

## 建议的解决方案

### A1. 保留 LLVM C++ raw-pointer discipline 【不建议】

#### 方案描述

继续在 safe `IR` 包公开 `eraseFromParent` 和 `removeFromParent`，通过文档规定删除、detached 或 pass mutation 后哪些 wrapper 不得继续使用。用户负责停止使用所有旧别名。

#### 优点

- 最贴近 LLVM C++ 与 LLVM C API。
- 不需要修改大量 getter 的返回类型和错误 effect。
- 没有额外的 liveness check 成本。

#### 缺点

- MoonBit 类型检查通过的普通代码仍可产生 use-after-free。
- getter 和 iterator 可以重复构造同一 raw pointer 的 wrapper，调用者很难穷尽所有别名。
- 将来的 pass 可以在 binding 内部批量删除节点，失效范围不再由用户直接控制。
- safe `IR` 包只能被描述为较易用的 raw wrapper，不能承诺动态内存安全。

### A2. Safe IR 暂不提供节点删除和 detach

#### 方案描述

从 safe `IR` 隐藏 `Instruction` 与 `BasicBlock` 的 `eraseFromParent`、`removeFromParent`；相应能力继续保留在 `unsafe`。safe 层近期只公开不会销毁 native node 的构造、查询和局部修改操作。

#### 优点

- 能立即闭合当前 safe API 的主要节点生命周期边界。
- 不要求所有 `Value` 方法立刻增加 `StaleHandle` 错误。
- 不影响主要的 IR construction 用例。

#### 缺点

- safe 层暂时不能实现需要删除节点的 native IR transform。
- 引入 optimization pass 后，LLVM 仍可能在内部删除节点，因此这只能作为近期边界，不能独立成为最终模型。

### A3. 以 Module revision 实现保守的动态失效

#### 方案描述

在 `ModuleOwner` 中维护单调递增的 revision。每个 `ModuleAnchoredValue` 保存创建时的 revision；所有内部 raw extraction 先比较 handle revision 与 Module 当前 revision，不一致时报告 `StaleHandle`，不得调用 LLVM。

任何可能删除或整体改写节点的操作在进入 LLVM 前增加 Module revision，包括 instruction/basic block/function/global 删除、link 和 optimization/pass pipeline。旧 revision 的全部 Module-owned Value 都保守失效，用户从仍然有效的 `Module` 根对象重新查询新 wrapper。

`IRBuilder` 的 insertion state 同时保存定位时的 Module revision；revision 改变后 Builder 清除插入点或报告 `StaleInsertPoint`。safe `IR` 还必须收回公开的 `ValueRef` 与 `Value::getValueRef` raw pointer 出口，否则用户可以绕过检查。

`removeFromParent` 不能继续返回 `Unit`。它需要返回带 finalizer 和 `OPEN/MOVED` 状态的 `DetachedInstruction` 或 `DetachedBasicBlock` owner：未重新插入时负责删除，重新插入时转移所有权并返回当前 revision 的新 wrapper。

#### 优点

- 只依赖 LLVM C API，不引入 LLVM C++ ABI。
- 一个 revision barrier 可以覆盖 pass 内部无法预先枚举的任意节点删除。
- BasicBlock 删除对子 instruction 的级联失效，以及 Builder insertion point 失效，都可以通过同一个 Module revision 保守覆盖。
- 不需要按 raw pointer 建立全局 registry。

#### 缺点

- 删除一个 instruction 会使同一 Module 中所有既有 Function、BasicBlock 和 Instruction wrapper 失效，粒度较粗。
- 每次 native access 都要执行 revision check。
- `getType` 等大量当前无错误的 API 可能需要增加 `StaleHandle`；`Show`、`Eq` 等无错误通道的 trait 还需单独定义 stale 行为。
- Context-owned constants 是否会因 pass 或 uniquing 被删除，需要另行审计；Module revision 本身不能覆盖所有 Context-owned Value。

### A4. 用 LLVM C++ `WeakVH` 实现精确节点跟踪

#### 方案描述

增加一个 C++ shim。每个 MoonBit Value wrapper 保存 managed `WeakVH` 和原有 parent anchor；LLVM 删除 Value 时自动把所有对应 `WeakVH` 置空，之后 raw extraction 报告 `StaleHandle`。

具体 wrapper 应使用不跟随 RAUW 的 `WeakVH`，而不是 `WeakTrackingVH`。否则一个 `BinaryInst` wrapper 可能在 RAUW 后指向不同 kind 的替代 Value，破坏 MoonBit 具体类型不变量。Builder insertion point 与 detached object ownership 仍需单独设计。

#### 优点

- 节点级失效精确；删除一个 instruction 不必使整个 Module 的其他 wrapper 失效。
- 能观察 optimization pass 和其他 LLVM 内部路径触发的 Value 删除。
- 同一 raw pointer 对应的多个独立 wrapper 都能收到删除通知，不需要 MoonBit 侧 interning。

#### 缺点

- 项目将从稳定的 LLVM C ABI 进入 LLVM C++ ABI，构建选项与 LLVM ABI 配置必须匹配。
- 每个 wrapper 都需要 ValueHandle 注册、管理和额外间接访问。
- 无法自动解决 Builder insertion point、detached owner、raw pointer escape 和 stale error effect。
- 实现和审核成本明显高于 Module revision。

### A5. 采用类似 llvmlite 的纯 MoonBit IR 层

#### 方案描述

在 MoonBit 中建立独立的 owned IR 数据模型，常用构造与局部变换只修改 MoonBit 对象；需要 verification、optimization 或 code generation 时，再整体 materialize 为 native LLVM Module。native binding 继续作为较窄的边界。

#### 优点

- MoonBit 对象的别名和删除由 GC/RC 管理，日常 IR mutation 不释放 native child pointer。
- 纯数据结构更适合 snapshot、property test 和非 native target。
- 可以显著缩小需要动态 native handle 检查的范围。

#### 缺点

- 需要维护第二套 IR 数据模型、验证和 lowering/round-trip 语义。
- 不适合近期直接补齐现有 native `IR` 包。
- 解析已有 Module 后进行原地 native transform 时仍需另一套失效模型。

### A6. 分阶段收窄并建立 revision barrier 【建议采纳】

#### 方案描述

近期先从 safe `IR` 隐藏节点删除和 detach，使当前 construction API 不产生节点级悬空句柄。引入 PassBuilder 或其他批量 native transform 前，再为 Module-owned Value 与 Builder 建立 Module revision 检查，收回 raw pointer 出口，并确定 `StaleHandle` 的错误表现。

如果以后出现明确需求，要求删除单个节点后其他旧 handle 仍保持可用，再根据实际性能与构建证据评估 C++ `WeakVH`。纯 MoonBit IR 可以作为独立的长期产品路线，不作为本问题近期修复的前置条件。

#### 优点

- 先以较小改动消除当前 safe 层明确暴露的 UAF 入口。
- 在真正加入 pass 前建立能够覆盖批量内部删除的动态边界。
- 不提前承担 C++ ABI 和精细 handle registry 的成本，同时保留以后提高失效精度的入口。

#### 缺点

- 中间阶段的 safe IR 不支持节点删除。
- Module revision 的 API 与错误传播问题仍需在引入 pass 前解决。
- 这是一条迁移路线，不代表最终一定不需要精细节点句柄。

## 最终采用方案

待定
