# Doc test 恢复的 commit 划分

> 状态：计划中
> 日期：2026-08-04

本轮将仓库中现有的 162 个 `moonbit nocheck` 示例逐步恢复为可检查、可执行的 `mbt check`。其中 138 个位于 `IR/*.mbt` 的 doc string，24 个位于 `tutorial/*.mbt.md`。IR doc string 中的语句片段需要包进匿名 `test { ... }`；tutorial 中的示例已经是完整测试块，主要修改 fence 和测试依赖。

原有 `moonbit skip`、普通展示代码块和讨论文档中的示意代码不在本轮范围内。每个 commit 只处理一个可独立审核的文件或功能区段，并在提交前勾选对应任务项。

## Commit 1：恢复 DataLayout doc test

- [x] 将 `IR/DataLayout.mbt` 中的 2 个 `moonbit nocheck` 改为 `mbt check`。
- [x] 将两个语句片段分别包进匿名 `test { ... }`。
- [x] 不修改 DataLayout 的实现。

建议提交信息：`docs(IR): check DataLayout examples`

## Commit 2：恢复 Module doc test

- [x] 将 `IR/Module.mbt` 中的 4 个 `moonbit nocheck` 改为 `mbt check`。
- [x] 将每个语句片段包进独立的匿名测试。
- [x] 只做示例语法和格式所需的调整，不修改 Module 行为。

建议提交信息：`docs(IR): check Module examples`

## Commit 3：恢复 Type doc test

- [x] 将 `IR/Type.mbt` 中的 3 个 `moonbit nocheck` 改为 `mbt check`。
- [x] 将每个语句片段包进独立的匿名测试。
- [x] 将用于断言类型分支的 `guard` 改为明确表示必定匹配的 `guard!`，避免新增 lint warning。

建议提交信息：`docs(IR): check Type examples`

## 检查点一：审核 doc test 的基本格式

完成 Commit 1—3 后暂停，重点检查：

- `mbt check` 与匿名 `test { ... }` 的结构是否清楚。
- `moon fmt` 对 doc string 的缩进结果是否便于阅读。
- 示例恢复是否没有混入公开 API 或实现改动。

## Commit 4：恢复 Function doc test

- [x] 将 `IR/Function.mbt` 中的 15 个 `moonbit nocheck` 改为 `mbt check`。
- [x] 将每个语句片段包进独立的匿名测试。
- [x] 保留该文件原有的 3 个 `moonbit skip`，不在本 commit 扩大范围。

建议提交信息：`docs(IR): check Function examples`

## Commit 5：恢复 BasicBlock doc test

- [x] 将 `IR/BasicBlock.mbt` 中的 12 个 `moonbit nocheck` 改为 `mbt check`。
- [x] 将每个语句片段包进独立的匿名测试。
- [x] 只修正启用检查后发现的示例问题，不修改 BasicBlock 行为。

建议提交信息：`docs(IR): check BasicBlock examples`

## Commit 6：修复 Float 负零常量并启用对应 doc test

- [x] 修复 `Context::getConstZeroFloat(isNegative=true)`：将 `UInt` 位模式通过 `Float::reinterpret_from_uint` 重解释为 `Float`，再转换为传给 LLVM 的 `Double`。
- [x] 只将 `getConstZeroFloat` 的示例改为 `mbt check` 并包进匿名测试，用它验证正零和负零。
- [x] 不在本 commit 顺便恢复其他 Context 示例。
- [x] 单独审核这一实际行为修复，不把失败快照直接更新为当前错误结果。

建议提交信息：`IR: fix negative zero float constant`

## Commit 7：恢复其余 Context doc test

- [ ] 将 `IR/Context.mbt` 中剩余的 38 个 `moonbit nocheck` 改为 `mbt check`。
- [ ] 将每个语句片段包进独立的匿名测试。
- [ ] 不再混入其他 Context 实现改动。

建议提交信息：`docs(IR): check Context examples`

## 检查点二：审核非 Builder 的 doc test

完成 Commit 4—7 后暂停，重点检查：

- Function、BasicBlock、Context 示例是否与当前公开 API 一致。
- `getConstZeroFloat` 的修复是否确实生成负零，而不是把错误输出写入快照。
- 原有 `moonbit skip` 是否保持不变。

## Commit 8：恢复 IRBuilder 的基础、内存与整数运算示例

- [ ] 处理 return、alloca、load、store 等基础和内存入口。
- [ ] 处理整数 add、sub、mul、div、rem 各族示例。
- [ ] 共恢复该区段的 20 个 doc test，不跨入浮点运算区段。

建议提交信息：`docs(IRBuilder): check integer operation examples`

## Commit 9：恢复 IRBuilder 的浮点、位运算与比较示例

- [ ] 处理浮点 add、sub、mul、div、rem、neg 示例。
- [ ] 处理 and、or、xor、not、shift、ptrdiff 示例。
- [ ] 处理 ICmp、FCmp 基础入口示例。
- [ ] 共恢复该区段的 16 个 doc test。

建议提交信息：`docs(IRBuilder): check floating and comparison examples`

## Commit 10：恢复 IRBuilder 的 cast 与 GEP 示例

- [ ] 处理整数、浮点、指针相关的各种 cast 示例。
- [ ] 处理 GEP 示例。
- [ ] 共恢复该区段的 13 个 doc test，不跨入控制流区段。

建议提交信息：`docs(IRBuilder): check cast and GEP examples`

## Commit 11：恢复 IRBuilder 的其余示例

- [ ] 处理 branch、select、switch 和 PHI 示例。
- [ ] 处理 Call、CallPtr、InsertValue、ExtractValue 示例。
- [ ] 处理 Malloc、Free、MemCpy、MemSet、MemMove、GlobalString 等剩余示例。
- [ ] 共恢复最后 14 个 doc test，确认 `IR/IRBuilder.mbt` 不再包含 `moonbit nocheck`。

建议提交信息：`docs(IRBuilder): check control flow and aggregate examples`

## 检查点三：审核 IRBuilder doc test

完成 Commit 8—11 后暂停，重点检查：

- 63 个 IRBuilder 示例是否按功能区段形成可审核的提交。
- 示例中的类型检查、错误传播和 LLVM IR 快照是否仍反映当前行为。
- convenience API 与基础入口的示例是否没有因为批量恢复而混淆。

## Commit 12：建立 tutorial doc test 依赖并恢复 Chapter0

- [ ] 在 `tutorial/moon.pkg` 中为测试导入 `Kaida-Amethyst/llvm/IR`，别名为 `@IR`。
- [ ] 使用 `for "test"` 限定导入，避免给 tutorial package 增加未使用依赖 warning。
- [ ] 将 `tutorial/Chapter0.mbt.md` 中的 2 个 `moonbit nocheck` 改为 `mbt check`。
- [ ] 保留示例中已有的完整测试块，不增加多余的嵌套 `test`。

建议提交信息：`docs(tutorial): check Chapter0 examples`

## Commit 13：恢复 tutorial Chapter1

- [ ] 将 `tutorial/Chapter1.mbt.md` 中的 3 个 `moonbit nocheck` 改为 `mbt check`。
- [ ] 保留该章原有的 `moonbit skip`。

建议提交信息：`docs(tutorial): check Chapter1 examples`

## Commit 14：恢复 tutorial Chapter2

- [ ] 将 `tutorial/Chapter2.mbt.md` 中的 4 个 `moonbit nocheck` 改为 `mbt check`。
- [ ] 保留该章原有的 `moonbit skip`。

建议提交信息：`docs(tutorial): check Chapter2 examples`

## Commit 15：恢复 tutorial Chapter3

- [ ] 将 `tutorial/Chapter3.mbt.md` 中的 4 个 `moonbit nocheck` 改为 `mbt check`。
- [ ] 不修改该章的教程结构和非 MoonBit 展示代码。

建议提交信息：`docs(tutorial): check Chapter3 examples`

## Commit 16：恢复 tutorial Chapter4

- [ ] 将 `tutorial/Chapter4.mbt.md` 中的 2 个 `moonbit nocheck` 改为 `mbt check`。
- [ ] 保留该章原有的 `moonbit skip`。

建议提交信息：`docs(tutorial): check Chapter4 examples`

## Commit 17：恢复 tutorial Chapter5

- [ ] 将 `tutorial/Chapter5.mbt.md` 中的 1 个 `moonbit nocheck` 改为 `mbt check`。
- [ ] 保留该章原有的 `moonbit skip`。

建议提交信息：`docs(tutorial): check Chapter5 examples`

## Commit 18：恢复 tutorial Chapter6

- [ ] 将 `tutorial/Chapter6.mbt.md` 中的 3 个 `moonbit nocheck` 改为 `mbt check`。
- [ ] 保留该章原有的 `moonbit skip`。

建议提交信息：`docs(tutorial): check Chapter6 examples`

## Commit 19：恢复 tutorial Chapter7 并完成全量检查

- [ ] 将 `tutorial/Chapter7.mbt.md` 中的 5 个 `moonbit nocheck` 改为 `mbt check`。
- [ ] 保留 Chapter7 和 Chapter8 原有的 `moonbit skip`；Chapter8 没有 `moonbit nocheck`，不做机械改动。
- [ ] 确认 `IR` 和 `tutorial` 中不再存在 `moonbit nocheck`。
- [ ] 运行最终全量检查，预期 181 个测试全部通过。

建议提交信息：`docs(tutorial): check Chapter7 examples`

## 检查点四：审核 tutorial 与最终状态

完成 Commit 12—19 后暂停，重点检查：

- tutorial 的测试依赖是否只在测试环境生效。
- 每章的代码块是否仍适合作为连续教程阅读。
- `moonbit skip` 是否只保留在尚不具备独立执行上下文的示意片段中。
- 最终测试数量和结果是否符合预期。

## 每个代码 commit 的检查要求

- [ ] 运行 `moon fmt`，检查 doc string 和 Markdown 代码块的格式化结果。
- [ ] 运行 `moon info`，确认 `.mbti` 没有非预期变化。
- [ ] 在配置 `env.sh` 后运行 `moon check --target native`。
- [ ] 运行 `moon test --target native`，确认新启用的 doc test 实际执行并通过。
- [ ] 遇到快照差异时先判断是实现错误还是预期过期，不直接使用 `moon test --update` 掩盖行为问题。
- [ ] 检查本 commit 之外的 `moonbit nocheck` 和所有 `moonbit skip` 没有被批量改动。
- [ ] 不混入字符串边界、UTF-16、其他错误模型或无关重构。

全量临时验证已经确认：完成上述转换、修复 Float 负零并增加 tutorial 测试导入后，`moon check --target native` 为 0 error，`moon test --target native` 为 181/181 passed；仅保留 `unsafe/Types.mbt` 中原有的 6 条 deprecated warning。
