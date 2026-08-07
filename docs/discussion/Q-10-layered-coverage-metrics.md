# Q-10. 测试覆盖率应如何分层度量与设置门槛 已解决

> 最后更新日期：2026-08-07
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

[生产可用性评估的 D07](../archive_discussion/production-readiness-assessment.md#d07测试数量和覆盖率不能支撑当前公开面积) 已指出测试数量和覆盖率不足。当前测试已经从评估时的 19 个增加到 187 个，但 safe IR、raw extern 与 C stub 的可观测方式不同，单一总覆盖率无法回答“哪些公开接口已经获得可信验证”。本问题只讨论覆盖指标和门槛；具体补测顺序由 Q-11 讨论。

## 问题引发模型

### 问题复现

在 2026-08-03 nightly 工具链上执行：

```text
moon test --target native --outline
moon test --target native
moon coverage analyze -- -f summary
moon coverage report -p Kaida-Amethyst/llvm/IR -f summary
moon coverage report -p Kaida-Amethyst/llvm/unsafe -f summary
```

得到以下基线：

| 范围 | 结果 |
|---|---:|
| 全部测试 | 187/187 通过 |
| IR doctest | 138 |
| tutorial doctest | 24 |
| `test` 黑盒测试 | 20 |
| IR 白盒测试 | 5 |
| 全部 MoonBit 覆盖点 | 2433/6123，39.7% |
| `IR` 包覆盖点 | 2118/3297，64.2% |
| `unsafe` 包覆盖点 | 315/2826，11.1% |

单独运行 20 个 `test` 包黑盒测试时覆盖 1501/6123 个覆盖点，说明当前总覆盖中有相当部分来自 doctest。Doctest 适合验证基本用法，但不替代错误、边界和强度测试。

### 问题分析

MoonBit 当前 coverage 基于分支覆盖；summary 中的分子和分母是 covered points 与 total coverage points，不应称为物理代码行覆盖率。

`IR` 包的普通 MoonBit 控制流适合用 coverage point 衡量，但 raw 层存在额外边界：

1. `unsafe` 接口文件合计暴露 1488 个公开可调用函数，其中约 524 个是直接 `pub extern "C"`。直接 extern 声明本身没有 MoonBit 分支，coverage 无法说明它是否被引用、能否链接或 ABI 是否正确。
2. `unsafe/wrap.c`、`unsafe/string_boundary.c`、`IR/resource_owner.c` 等 C stub 不进入 MoonBit coverage，39.7% 不能解释为整个 binding 的覆盖率。
3. raw enum conversion 等机械代码会产生大量覆盖点，但其风险与 ownership、allocator、error adapter 的少量分支不同。提高一个全局百分比可能优先奖励低风险代码。
4. coverage 只能说明某个分支曾被执行，不能证明断言充分、资源正确释放或行为与 LLVM 契约一致。

因此需要先定义每一层要回答的问题，再决定 CI 门槛。

## 关联问题

1. [Q-11. 测试补全应按什么顺序推进](Q-11-test-expansion-order.md)（依赖：Q-10 定义度量方式，Q-11 决定如何提高这些指标）

## 建议的解决方案

### A1. 使用单一全仓覆盖率作为主要门槛 【不建议】

#### 方案描述

直接以 `moon coverage analyze -- -f summary` 的总百分比作为 CI 门槛，并要求逐步提高到统一目标。

#### 优点

- 配置简单，容易观察趋势。
- 可以阻止明显的覆盖率整体下降。

#### 缺点

- 直接 extern 和 C stub 不在指标内。
- raw 层的大量机械转换会稀释 safe 层和高风险 adapter 的信号。
- 可能通过补大量低风险分支提高数字，却仍未验证链接、ABI、资源释放和错误路径。

### A2. 按 safe IR、raw binding 与 C stub 分层度量 【已采纳】

#### 方案描述

建立三类独立证据：

1. safe `IR`：使用 MoonBit coverage point，先以当前 2118/3297（64.2%）建立不得下降的基线；对新增或修改文件要求不引入无理由的未覆盖分支。后续随 Q-11 的分批补测逐步提高，而不是立即设置脱离现状的绝对门槛。
2. raw `unsafe`：coverage 只用于检查有 MoonBit 逻辑的 wrapper，接口完整性另用公开 API manifest、强制引用的 link-smoke 和按 API family 的语义测试衡量。直接 extern 不以逐行覆盖为目标。
3. C stub：单独使用 C coverage 与 ASan/LSan/UBSan；ownership、allocator、error adapter 的成功和失败分支必须获得测试，不与 MoonBit 数字合并成一个百分比。

当前先把分层指标用于本地评估和每批补测后的增量记录，不立即接入 CI。将来接入 CI 时，初期只执行“不下降”和生成可审查报告；绝对阈值应在第一轮补测完成后，依据 stable profile 的实际覆盖范围再决定。

#### 优点

- 每个指标对应明确风险，不把“执行过 MoonBit 分支”误当成 ABI 或资源安全证明。
- 能从当前状态开始启用 CI，而不需要先一次性补齐全部测试。
- raw generated layer 可以追求 manifest completeness，避免无意义的覆盖率填充。
- 便于把 ownership、error、allocator 等高风险适配器设置为更严格的局部门槛。

#### 缺点

- 需要维护多份报告和一份 raw API manifest。
- 初期没有一个可以概括全部质量的单一数字。
- C coverage、sanitizer 和 link-smoke 需要额外构建工作。

## 最终采用方案

A2. 按 safe IR、raw binding 与 C stub 分层度量
