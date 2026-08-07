# Q-11. 测试补全应按什么顺序推进 已解决

> 最后更新日期：2026-08-07
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

当前共有 187 个测试，但其中 162 个是 IR API 文档或 tutorial doctest，承担错误、边界、强度和资源验证的黑盒及白盒测试只有 25 个。safe IR 的不同文件覆盖差异很大，raw 层还有多个完整 API family 为零覆盖。本问题讨论如何把补测工作拆成可独立完成、可度量的小批次，不在此决定具体 API 的语义修改。最终决定按风险和覆盖缺口分阶段推进，但暂不让 CI 检测 coverage，因此从功能补测批次直接开始。

## 问题引发模型

### 问题复现

当前 coverage summary 显示，safe IR 中覆盖最低的主要文件为：

| 文件 | 覆盖点 |
|---|---:|
| `IR/GlobalValue.mbt` | 8/74，10.8% |
| `IR/Value.mbt` | 81/251，32.3% |
| `IR/Type.mbt` | 289/694，41.6% |
| `IR/Instruction.mbt` | 211/388，54.4% |
| `IR/DataLayout.mbt` | 12/22，54.5% |

BitReader、BitWriter、Comdat、DebugInfo、Error、ExecutionEngine、IRReader、LLJIT、Linker、Remarks、Target、TargetMachine 和 Transforms 等 13 个 `unsafe` 文件的 MoonBit wrapper 覆盖为零。`test/jit_test.mbt` 当前只有被注释掉的草稿，没有活动测试。

### 问题分析

测试数量不能直接代表验证强度：一个 test block 可以包含多个正向和反向检查，一个端到端测试也会触达许多接口。相反，仅为每个函数增加一个 happy-path test 仍可能遗漏 allocator、错误消息、ownership transfer 和 handle invalidation。

补测顺序应同时考虑：

1. 生产风险：ownership、error、allocator、失效和 transfer 高于机械 enum conversion。
2. 当前缺口：safe 层低覆盖文件和完整零覆盖 API family 应优先获得基本证据。
3. 可交付粒度：每一批应能独立通过 `moon test`、产生可解释的 coverage 增量，并避免同时修改接口设计。
4. 测试职责：doctest 只展示基本用法；复杂正反例放在黑盒测试，内部 owner/liveness 不变量放在白盒测试，native 内存问题由 sanitizer 验证。

## 关联问题

1. [Q-10. 测试覆盖率应如何分层度量与设置门槛](Q-10-layered-coverage-metrics.md)（依赖：本计划需要 Q-10 的分层指标验证进展）
2. [Q-09. Native IR 节点删除后的派生句柄失效模型](Q-09-native-ir-handle-invalidation.md)（一般关联：失效模型尚待决定，但现有 RAUW/UAF 回归和将来的 stale-handle 行为都需要专门测试）

## 建议的解决方案

### A1. 以测试总数为目标，逐接口平均补齐 【不建议】

#### 方案描述

先为尚无独立 test 的公开函数各增加一个 happy-path test，以测试数量或“每接口一个测试”作为主要进度指标。

#### 优点

- 任务容易机械拆分。
- 能快速提高测试数量和接口触达面。

#### 缺点

- 一个接口可能需要多个失败、边界和资源路径，而多个接口也可能更适合由同一场景测试。
- 容易把精力集中在低风险 getter 和 enum conversion。
- 无法处理 direct extern、C stub、ownership transfer 和 sanitizer 等不能由测试数量表达的问题。

### A2. 按风险和覆盖缺口分阶段补测

#### 方案描述

按以下批次推进；每批完成后运行完整 native 测试和 coverage，记录新增测试覆盖的行为与覆盖点增量。

1. **M0：固定基线与回归规则。** 在 CI 生成 full、`IR`、`unsafe` 三份 MoonBit coverage summary；先执行不得下降，不立即设置 80% 等绝对门槛。保留 187/187 和 Q-10 中的覆盖点作为首个基线。
2. **M1：GlobalValue 小批次。** 新增 `test/global_value_test.mbt`，覆盖 GlobalVariable、GlobalConstant、`Value`/`GlobalValue` trait 行为，遍历全部 `Linkage` 与 `UnnamedAddr` 的 set/get 往返，验证名称、打印结果、默认值和 embedded NUL 错误。循环中的多组值使用 assertion，稳定结构输出使用 `inspect`。这一批以把 `IR/GlobalValue.mbt` 从 8/74 的明显缺口提升到可解释水平为目标。
3. **M2：safe IR 核心对象。** 依次处理 `Value`、`Type`、`Instruction` 和 `DataLayout`。每个 family 至少包含典型正向构造、nullable/不存在结果、错误参数、名称编码、类型不匹配，以及 getter/setter round-trip；已知 RAUW/UAF 行为保留独立最小回归测试。
4. **M3：raw 文件与工具链互操作。** 按可形成闭环的场景覆盖 IRReader/BitReader、BitWriter、Linker、Target/TargetMachine、Transforms 和 Error。优先采用 parse/print、bitcode round-trip、link、verify、run passes、emit object 等端到端或差分测试，同时补失败消息和资源释放路径。Comdat、Remarks、DebugInfo 等随后按 stable profile 决定优先级。
5. **M4：资源和执行引擎。** 为 Context、Module、Builder、MemoryBuffer、Error/Message、ExecutionEngine 和 LLJIT 建立 success、failure、early-return、重复 close、parent-child、conditional transfer 和循环压力测试。ExecutionEngine/LLJIT 在 ownership transfer 契约明确前不以简单 happy-path 调用冒充完整覆盖。
6. **M5：native 验证。** 为公开 raw extern 生成 link-smoke；为 C adapter 增加 coverage 和 ASan/LSan/UBSan；对 allocator、error 和 ownership adapter 要求所有已声明分支有对应测试。最后再依据 stable profile 设置绝对门槛和显式 uncovered allowlist。

每一批新增测试遵守仓库约定：doc test 只放最小使用示例；外部可见行为放 `*_test.mbt`；内部 owner 和失效不变量放 `*_wbtest.mbt`；快照默认用 `inspect`，循环中使用 assertion。

#### 优点

- 第一批很小，可以快速验证流程和 coverage 增量是否可用。
- 先覆盖 safe 层明显缺口，再进入需要额外工具的 raw/C/resource 问题。
- 测试按行为和风险组织，不被公开函数数量牵着走。
- 与生产可用性评估中的符号、ABI、资源、sanitizer、功能和 round-trip 分层一致。

#### 缺点

- 不能在短期内得到“所有接口都有独立测试”的简单结论。
- M3 至 M5 需要 LLVM 工具、sanitizer、测试 C shim 和 API manifest 等额外设施。
- Q-09 等尚未决定的接口语义会影响部分反向测试的最终预期。

### A3. 不接入 CI coverage，直接从功能补测开始 【已采纳】

#### 方案描述

保留 A2 的风险排序、测试职责和 M1 至 M5，不执行其中的 M0：

- 当前不修改 CI，也不设置 coverage 自动门槛。
- `moon coverage` 继续作为本地分析工具；每批测试完成后运行并记录增量，用于选择下一批缺口。
- 正式实施从 M1 的 GlobalValue 黑盒测试开始，随后按 M2 至 M5 推进。
- 是否把分层 coverage 接入 CI 留到第一轮补测完成后再讨论。

#### 优点

- 可以立即进入实际测试添加，不先扩展 CI 工作范围。
- 保留可比较的 coverage 基线和风险导向的实施顺序。
- 将 CI 门槛推迟到已有一轮真实增量数据之后，届时更容易设置合理规则。

#### 缺点

- coverage 下降暂时只能通过本地检查发现，不能自动阻止合入。
- 每批工作的完成者需要主动记录 coverage 结果。
- 后续仍需重新决定何时以及如何把分层指标接入 CI。

## 最终采用方案

A3. 不接入 CI coverage，直接从功能补测开始
