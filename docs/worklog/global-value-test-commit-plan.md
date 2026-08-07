# GlobalValue 测试补全的 commit 划分

> 状态：计划中
> 日期：2026-08-07

本轮按照 [Q-10](../discussion/Q-10-layered-coverage-metrics.md) 与 [Q-11](../discussion/Q-11-test-expansion-order.md) 已采用的方案实施 M1，只补充 `GlobalValue` 相关黑盒测试。coverage 仅作为本地分析和增量记录工具；本轮不修改 CI，不设置自动覆盖率门槛，也不提前进入 M2 的 `Value`、`Type`、`Instruction` 与 `DataLayout` 系统性补测。

当前基线：

- 全部测试：187/187 通过；
- 全部 MoonBit 覆盖点：2433/6123；
- `IR` 包覆盖点：2118/3297；
- `IR/GlobalValue.mbt`：8/74。

计划新增 `test/global_value_test.mbt`。测试必须只通过 `@IR` 的公开 API 观察行为，不依赖 private raw handle、C 测试入口或实现细节。

## 测试矩阵

| 行为 | 主要对象 | 验证方式 |
|---|---|---|
| 创建全局变量并设置 initializer | `Module::addGlobalVariable` | `inspect` 全局变量或 Module 的稳定 IR 文本 |
| 创建全局常量 | `Module::addGlobalConstant` | `inspect` 常量 IR，确认 `constant`、类型、名称和值 |
| 具体 wrapper 的 trait 分类 | `GlobalVariable`、`GlobalConstant` | 匹配 `asValueEnum` 与 `asGlobalEnum` 的对应构造器 |
| 默认属性 | 两类 GlobalValue | 检查默认 linkage、unnamed address 和名称 |
| Linkage 往返 | 全部 17 个 `Linkage` 构造器 | 循环执行 `setLinkage`/`getLinkage`，使用 assertion |
| UnnamedAddr 往返与移除 | `NoUnnamedAddr`、`Local`、`Global` | 循环检查 set/get，并验证 `removeUnnamedAddr` 恢复默认值 |
| 名称读写 | GlobalValue 的 `Value` 行为 | 检查 `getValueName`/`setValueName` 往返和无名称结果 |
| embedded NUL | 两个 Module 构造入口及一个名称 setter | 明确捕获 `StringError::ContainsNul`，不得只检查“发生了错误” |
| Show 输出 | 两类具体 wrapper | 使用 `inspect` 固定正常输出；不伪造当前无法从公开 API 稳定触发的打印失败分支 |

Linkage 与 UnnamedAddr 的多组输入位于循环中，每轮期望值不同，应使用 `assert_eq` 或模式检查，不使用会在循环内重复占用同一快照位置的 `inspect`。稳定 IR 文本仍优先使用 `inspect`。

## Commit 1：提交测试策略决议与 M1 计划

- [x] 提交 T-04、Q-10、Q-11 的新增记录和已采用状态。
- [x] 提交本文档。
- [x] 确认 Q-10 最终采用 A2，Q-11 最终采用不含 M0 的 A3。
- [x] 不包含测试、实现或 CI 改动。

建议提交信息：`docs: adopt layered test coverage plan`

## Commit 2：覆盖 GlobalVariable 与 GlobalConstant 的基本行为

- [ ] 新增 `test/global_value_test.mbt`。
- [ ] 使用一个最小 Context、Module 和整数常量 fixture 构造 GlobalVariable 与 GlobalConstant；helper 只消除 setup 重复，不隐藏被验证行为。
- [ ] 验证 initializer、global constant 标记和稳定 IR 文本。
- [ ] 验证 `asValueEnum` 与 `asGlobalEnum` 返回正确的具体分类。
- [ ] 验证两类对象的名称、默认 linkage、默认 unnamed address 和正常 Show 输出。
- [ ] 不在本 commit 枚举全部 linkage/unnamed-address 分支。

建议提交信息：`test(IR): cover global value construction`

## Commit 3：覆盖 GlobalValue 属性往返和名称错误

- [ ] 在同一测试文件中遍历全部 17 个 `Linkage` 构造器，验证 `setLinkage`/`getLinkage` 往返。
- [ ] 遍历 3 个 `UnnamedAddr` 构造器，验证 set/get，并单独验证 `removeUnnamedAddr`。
- [ ] 验证 `setValueName`/`getValueName` 的正常往返。
- [ ] 分别验证 `addGlobalVariable`、`addGlobalConstant` 和一个 GlobalValue 名称 setter 对 embedded NUL 报告 `StringError::ContainsNul`。
- [ ] 如果 LLVM 对某个属性进行规范化，不把当前输出直接写成错误快照；先确认上游契约，再决定是调整测试还是单独记录实现问题。

建议提交信息：`test(IR): cover global value properties`

## 完成验收

- [ ] 运行 `moon fmt`。
- [ ] 运行 `moon info`；本轮只新增黑盒测试，预期所有 `.mbti` 均无变化。
- [ ] 运行 `moon check --target native`。
- [ ] 运行 `moon test --target native -p test`。
- [ ] 运行 `moon test --target native`。
- [ ] 运行 `moon coverage analyze -- -f summary`。
- [ ] 运行 `moon coverage report -p Kaida-Amethyst/llvm/IR -f summary`。
- [ ] 在本文档的“实际结果”中记录测试数量、全仓、`IR` 包和 `IR/GlobalValue.mbt` 的新覆盖点；不修改 CI。
- [ ] 使用 caret 或 HTML 报告检查 `IR/GlobalValue.mbt` 的剩余未覆盖点，并逐项说明是公共正常路径、错误路径还是当前公开 API 无法稳定触发的分支，不以追求 100% 为由伪造测试。

## 发现实现问题时的边界

- 测试 commit 不混入生产实现修复或公开 API 变更。
- 如果新测试暴露崩溃、错误分类、LLVM 行为差异或资源问题，先保留最小复现并单独记录；需要修复时另建独立任务和 commit。
- 不通过 `moon test --update` 接受明显错误的当前行为。只有确认快照就是契约后才更新。
- 不顺带补 Function 的 GlobalValue 行为；它与 `Value`、`Instruction` 等剩余范围一起留给后续批次。

## 实际结果

待实施后填写。
