# MiniMoonBit 前端移植的 commit 划分

> 状态：计划中
> 日期：2026-08-12
> 上游源码：`~/Projects/Moonbit/MiniMoonbit`

本轮把 MiniMoonBit 中 codegen 之前的实现移入本仓库，建立一条可独立测试的前端链路：

```text
source
  -> lexer
  -> parser AST
  -> typed AST
  -> KNF
```

代码放在 `examples/minimoonbit/` 下，继续沿用原项目的 package 边界。目标是尽可能直接移植已有实现，只进行当前 MoonBit 工具链、package 路径和仓库规范所要求的适配；本轮不重新设计语言、AST、类型检查或 KNF。

## 本轮范围

纳入本轮：

- `color`：诊断文本着色与去色辅助；
- `lexer`：token、操作符、关键字、源码位置和词法错误；
- `parser`：parser AST 与完整语法解析；
- `typecheck`：类型表示、typed AST、环境和类型检查；
- `knf`：命名、闭包捕获和 KNF lowering；
- 上述四个主要阶段原有的 91 个测试，以及一组新增的全前端集成测试。

明确不纳入本轮：

- `main/`、命令行参数、文件读取、输出路径管理和其他 driver 行为；
- `codegen/`、`runtime.c`、MoonLLVM/llvm.mbt API 替换、object emission、链接与运行；
- 原项目 `examples/`、`bench/` 和仓库根目录的零散试验程序；
- `Yoorkin/ArgParser`、`moonbitlang/x`、MoonLLVM 等仅由 main/codegen 使用的依赖；
- 为迁移方便而大规模重写 AST、错误模型、测试风格或 package 划分。

因此，本轮完成后能验证“源码可以稳定走到 KNF”，但还不能证明 MiniMoonBit 程序可以生成 object 或执行。codegen 及 native link-and-run 应在后续 worklog 中单独规划。

## 目标目录与依赖

```text
examples/minimoonbit/
  README.md
  color/
  lexer/
  parser/
  typecheck/
  knf/
  frontend_test/
```

package 依赖保持单向：

```text
color <- lexer <- parser <- typecheck <- knf
                    ^          ^        ^
                    +----------+--------+-- either

frontend_test -> lexer + parser + typecheck + knf
```

- package 名从 `Kaida-Amethyst/MiniMoonBit/...` 改为 `Kaida-Amethyst/llvm/examples/minimoonbit/...`。
- 保留原实现使用的 `Kaida-Amethyst/either@0.1.0`，在根 `moon.mod` 中显式加入该依赖；本轮不为了消除一个依赖而改写 `Either` 数据模型。
- 各 package manifest 改用本仓库当前的 `moon.pkg` 格式，不复制旧 `moon.pkg.json`。
- 不复制原项目生成的 `.mbti`；每批通过 `moon info` 重新生成并审核新的 `pkg.generated.mbti`。
- 不照搬旧 manifest 中的宽泛 warning suppression。若当前工具链仍需 suppression，应缩小范围并在对应 commit 中说明原因。

`frontend_test` 只承载黑盒集成测试，不公开新的 frontend facade。它直接组合 `tokenize -> parse -> typecheck -> knf_transform`，避免为了测试先创造一套尚未确定的 driver API。

## 直接移植的边界

允许的机械适配：

- 修改 package import 路径和 manifest 语法；
- 按当前 MoonBit 语法修复已废弃写法、标准库 API 名称和格式化结果；
- 为仍然公开的声明补充符合 `docs/style-guide.md` 的简洁文档注释；
- 对当前工具链要求的错误传播、label 参数或 collection API 做等价替换；
- 在不改变意图的前提下修复测试 harness 和 snapshot 表示。

不应混入移植 commit 的变化：

- 重构 parser/typechecker/KNF 算法；
- 为了缩小 `.mbti` 而批量改变原实现的 `pub`/`pub(all)` 可见性；
- 修改语言语法、类型兼容规则、闭包捕获或 KNF 形状；
- 遇到失败测试后直接改 expected，使现有行为变化被掩盖；
- 修改 `IR`、`unsafe` 或 native emission API。

如果当前 MoonBit 语义迫使我们改变某项语言行为，或者 `Kaida-Amethyst/either` 已无法按原契约使用，应暂停当前 commit，先单独讨论，而不是静默重写。

## 测试基线

只读盘点得到的原项目测试数如下：

| 阶段 | 原测试文件 | active `test` 数量 | 本轮要求 |
| --- | --- | ---: | --- |
| lexer | `lexer/tokenize_test.mbt` | 17 | 全部移植并通过 |
| parser | `parser/parse_test.mbt` | 32 | 全部移植并通过 |
| typecheck | `typecheck/typecheck_test.mbt` | 23 | 全部移植并通过 |
| KNF | `knf/knf_test.mbt` | 19 | 全部移植并通过 |
| 合计 | 4 个测试文件 | 91 | 不减少、不静默跳过 |

原测试本身也是需要保真的迁移对象：兼容时保留已有断言和 snapshot，不为追求统一风格而机械重写全部测试。新增测试遵循仓库测试规范，优先 `inspect` 稳定的结构化结果；循环中的逐项检查等不适合 snapshot 的场景再使用 assertion。

## 交付批次与 review 停点

| 批次 | commit | 人工 review 重点 |
| --- | --- | --- |
| A | 2—4 | 目录、依赖是否克制；token/source span/诊断是否保持原语义 |
| B | 5—6 | parser AST 的公开 shape、优先级和错误位置是否保持一致 |
| C | 7—8 | 类型表示、scope、类型兼容和错误传播是否保持一致 |
| D | 9—11 | KNF 名字生成、闭包捕获、控制流 lowering 和全链路是否可靠 |

每一批完成并提交后暂停，等待人工 review 后再进入下一批。

## Commit 1：提交前端移植计划

涉及文件和对象：

| 文件 | 对象 |
| --- | --- |
| `docs/worklog/C-08-minimoonbit-frontend-port-commit-plan.md` | 范围、目录、依赖、commit 边界、测试基线和审核停点 |

- [x] 提交本文档，固定本轮只做到 KNF，不包含 main 或 codegen。
- [x] 记录原项目 91 个 active test 的基线。
- [x] 不包含 MoonBit 源码、依赖、生成接口或测试改动。

建议提交信息：`docs: plan MiniMoonBit frontend port`

## Commit 2：建立示例骨架并移植 color

涉及文件和对象：

| 文件 | 公开对象或职责 |
| --- | --- |
| `moon.mod` | 增加 `Kaida-Amethyst/either@0.1.0` |
| `examples/minimoonbit/README.md` | 项目来源、当前只到 KNF、package 图和暂不提供 CLI 的说明 |
| `examples/minimoonbit/color/moon.pkg` | color package 定义 |
| `examples/minimoonbit/color/print.mbt` | `Color`、`taint`、`strip_color`、`strip_object_color` |
| `examples/minimoonbit/color/pkg.generated.mbti` | 由 `moon info` 生成的新接口 |

- [x] 保留原有颜色语义，不把终端探测、全局开关或 IO 引入 color package。
- [x] 为公开 enum、constructor 和函数补充简洁文档；示例内部 package 仍须遵守公开 API 文档规则。
- [x] README 明确这些 package 用于示范和集成测试，当前公开 shape 不承诺成为 llvm.mbt 的稳定核心 API。
- [x] 确认本 commit 不引入 ArgParser、`moonbitlang/x`、MoonLLVM 或新的 async/fs 依赖。

建议提交信息：`examples: scaffold MiniMoonBit frontend port`

## Commit 3：移植 lexer 实现

涉及文件和对象：

| 文件 | 公开对象或职责 |
| --- | --- |
| `examples/minimoonbit/lexer/moon.pkg` | 依赖本地 `color` |
| `examples/minimoonbit/lexer/lexer.mbt` | `TokenizeError`、`Keyword`、`BinaryOp`、`AssignOp`、`Token`、`TokenKind`、`tokenize` 及相关 `Show`/constructor |
| `examples/minimoonbit/lexer/throw.mbt` | `ThrowLevel`、`throw_` 和源码诊断格式化 |
| `examples/minimoonbit/lexer/pkg.generated.mbti` | 由 `moon info` 生成的新接口 |

- [x] 保持 token 分类、操作符映射、关键字集合、注释和字面量扫描行为。
- [x] 重点核对 offset/line/column、EOF、错误 token 和诊断片段，不因语法适配改变 source span。
- [x] 保持 `tokenize` 的输入/文件名参数和错误契约；不在本轮重做 lexer API。
- [x] 为所有仍公开的 type、constructor、field、function 和 public impl 补充必要文档。
- [x] 本 commit 只要求实现 package 能 check；原测试在下一个 commit 单独迁入。

建议提交信息：`examples(minimoonbit): port the lexer`

## Commit 4：移植 lexer 的 17 个测试

涉及文件和对象：

| 文件 | 测试范围 |
| --- | --- |
| `examples/minimoonbit/lexer/tokenize_test.mbt` | 原项目全部 17 个词法测试 |

- [ ] 保留全部 17 个 active test，不合并、不注释、不以“工具链差异”为由跳过。
- [ ] 覆盖标识符/关键字、数字与字符串字面量、操作符、标点、注释、源码位置和错误输入。
- [ ] snapshot 若因无关的格式化或颜色转义变化需要调整，必须先确认 token 与 span 语义没有变化。
- [ ] 单独运行 lexer package 测试，再运行全仓库测试。

建议提交信息：`test(minimoonbit): port lexer coverage`

## Commit 5：移植 parser 实现和 AST

涉及文件和对象：

| 文件组 | 公开对象或职责 |
| --- | --- |
| `parser/moon.pkg`、`parser/parser.mbt`、`parser/utils.mbt` | `Program`、`ParseError`、`parse`、公共解析辅助和诊断 |
| `parser/typedef.mbt`、`parser/struct_def.mbt`、`parser/enum_def.mbt`、`parser/extern.mbt`、`parser/top_function.mbt`、`parser/top_let.mbt` | type/struct/enum/extern/top-level AST 与 parser |
| `parser/stmt.mbt`、`parser/let_stmt.mbt`、`parser/let_mut_stmt.mbt`、`parser/assign_stmt.mbt`、`parser/while_stmt.mbt`、`parser/for_stmt.mbt`、`parser/local_function.mbt`、`parser/pattern.mbt` | statement、left value、pattern 与 local function AST/parser |
| `parser/expr.mbt`、`parser/atom_expr.mbt`、`parser/apply_expr.mbt`、`parser/block_expr.mbt`、`parser/if_expr.mbt`、`parser/match_expr.mbt`、`parser/struct_construct_expr.mbt` | expression AST、operator precedence 和各 expression parser |
| `parser/left_value.mbt` | left-value AST 与 parser |
| `parser/pkg.generated.mbti` | 由 `moon info` 生成的新接口 |

以上路径均位于 `examples/minimoonbit/`。

- [ ] 保持原 parser AST 的 struct/enum shape、`to_string(color?)` 与 `Show` 行为。
- [ ] 保持操作符优先级和结合性、token consumption、剩余 `ArrayView` 与错误定位。
- [ ] 保持 `Either` 在 AST 中的原有表示，不在移植时替换成新的本地 enum。
- [ ] 为公开 AST type、constructor/field、parse function 和 public impl 补齐文档，但不借机重命名或收窄 visibility。
- [ ] 本 commit 不加入 `parse_test.mbt`，以便把 AST/解析实现与测试迁移分开审核。

建议提交信息：`examples(minimoonbit): port the parser`

## Commit 6：移植 parser 的 32 个测试

涉及文件和对象：

| 文件 | 测试范围 |
| --- | --- |
| `examples/minimoonbit/parser/parse_test.mbt` | 原项目全部 32 个 parser 测试 |

- [ ] 保留全部 32 个 active test，覆盖 top-level、type、statement、expression、pattern、struct/enum 和错误输入。
- [ ] 优先保留原 source snippet 与 expected AST 文本，以便对照原项目，而不是重新设计 fixtures。
- [ ] 所有 snapshot 更新都要能由 package/import/格式化适配解释；语法或 AST 行为变化应先暂停讨论。
- [ ] 单独运行 parser package 测试，再运行 lexer+parser 和全仓库测试。

建议提交信息：`test(minimoonbit): port parser coverage`

## Commit 7：移植 typecheck 实现和 typed AST

涉及文件和对象：

| 文件组 | 公开对象或职责 |
| --- | --- |
| `typecheck/moon.pkg`、`typecheck/program.mbt`、`typecheck/typechecker.mbt`、`typecheck/utils.mbt` | `Context`、scope/environment、`Program`、类型检查入口和错误辅助 |
| `typecheck/typedef.mbt`、`typecheck/struct_def.mbt`、`typecheck/enum_def.mbt`、`typecheck/extern.mbt`、`typecheck/top_function.mbt`、`typecheck/top_let.mbt` | `Type`/`TypeKind`、定义收集、top-level typed AST 与检查逻辑 |
| `typecheck/stmt.mbt`、`typecheck/let_stmt.mbt`、`typecheck/let_mut_stmt.mbt`、`typecheck/assign_stmt.mbt`、`typecheck/while_stmt.mbt`、`typecheck/for_stmt.mbt`、`typecheck/local_function.mbt`、`typecheck/left_value.mbt` | typed statement/pattern/left value 与 scope mutation |
| `typecheck/expr.mbt`、`typecheck/atom_expr.mbt`、`typecheck/apply_expr.mbt`、`typecheck/block_expr.mbt`、`typecheck/if_expr.mbt`、`typecheck/match_expr.mbt`、`typecheck/struct_construct_expr.mbt`、`typecheck/enum_construct_expr.mbt` | typed expression、类型兼容和构造检查 |
| `typecheck/pkg.generated.mbti` | 由 `moon info` 生成的新接口 |

以上路径均位于 `examples/minimoonbit/`。

- [ ] 保持 typed AST shape、类型变量生成、scope push/pop、名称查找和 top-level 收集顺序。
- [ ] 保持函数/闭包、tuple/array、struct/enum、pattern match、loop 和赋值的类型规则。
- [ ] 重点核对 `is_type_compatible`、推导结果、错误传播与 source token，不用新的默认值掩盖失败。
- [ ] 为所有公开 typed AST、type enum、Context method、field/constructor 和 public impl 补齐文档。
- [ ] 本 commit 不加入 `typecheck_test.mbt`，避免实现审查被大段 expected 输出淹没。

建议提交信息：`examples(minimoonbit): port the type checker`

## Commit 8：移植 typecheck 的 23 个测试

涉及文件和对象：

| 文件 | 测试范围 |
| --- | --- |
| `examples/minimoonbit/typecheck/typecheck_test.mbt` | 原项目全部 23 个 typecheck 测试 |

- [ ] 保留全部 23 个 active test，包含成功与失败的类型检查路径。
- [ ] 保留原 source snippet 和 typed AST/error expected，确认没有将 parser 失败误归为 typecheck 通过。
- [ ] 对错误消息的必要格式适配与类型规则变化分开判断；后者不得作为普通 snapshot update 混入。
- [ ] 单独运行 typecheck package 测试，再运行前三级和全仓库测试。

建议提交信息：`test(minimoonbit): port type checker coverage`

## Commit 9：移植 KNF 实现

涉及文件和对象：

| 文件组 | 公开对象或职责 |
| --- | --- |
| `knf/moon.pkg`、`knf/context.mbt`、`knf/name.mbt` | `KnfTransformError`、`Name`、`Env`、`Context`、名字和 scope 管理 |
| `knf/knf.mbt`、`knf/type.mbt`、`knf/block.mbt`、`knf/stmt.mbt`、`knf/expr.mbt` | `KnfProgram`、`Type`、`KnfBlock`、`KnfStmt`、`KnfExpr` 与转换入口 |
| `knf/function.mbt`、`knf/closure.mbt`、`knf/extern.mbt`、`knf/top_let.mbt`、`knf/struct_def.mbt`、`knf/union.mbt` | top-level/function/closure/data-definition KNF |
| `knf/atom_expr.mbt`、`knf/apply_expr.mbt`、`knf/assign_stmt.mbt`、`knf/let_stmt.mbt`、`knf/let_mut_stmt.mbt`、`knf/if_expr.mbt`、`knf/match_expr.mbt`、`knf/while_stmt.mbt` | expression、statement、branch/match/loop lowering |
| `knf/pkg.generated.mbti` | 由 `moon info` 生成的新接口 |

以上路径均位于 `examples/minimoonbit/`。

- [ ] 保持临时名字生成顺序、lexical scope、变量捕获集合和 closure 表示。
- [ ] 保持 tuple/array/struct/enum、apply、assignment、if/match/loop 的 KNF 形状。
- [ ] 保持 `knf_transform` 的输入、输出和错误模型；不在本轮为将来的 LLVM codegen 改造 KNF。
- [ ] 先保留原 manifest 的直接 `either` 依赖；只有编译与 `.mbti` 都证明不需要时，才可在本 commit 移除并说明。
- [ ] 为所有公开 KNF type、constructor/field、Context method、转换函数和 public impl 补齐文档。

建议提交信息：`examples(minimoonbit): port KNF lowering`

## Commit 10：移植 KNF 的 19 个测试

涉及文件和对象：

| 文件 | 测试范围 |
| --- | --- |
| `examples/minimoonbit/knf/knf_test.mbt` | 原项目全部 19 个 KNF 测试 |
| `examples/minimoonbit/knf/moon.pkg` | 增加 lexer/parser 的 test-only import |

- [ ] 保留全部 19 个 active test，沿用原来的完整前置路径生成 typed AST。
- [ ] 重点检查 deterministic naming、closure capture、branch/match 和 loop 输出；不得用宽松字符串包含测试代替原结构验证。
- [ ] 若格式化导致 snapshot 变化，先确认名字分配和语句顺序完全一致。
- [ ] 单独运行 KNF package 测试，再运行全部 MiniMoonBit package 和全仓库测试。

建议提交信息：`test(minimoonbit): port KNF coverage`

## Commit 11：增加全前端集成测试并收尾 README

涉及文件和对象：

| 文件 | 对象或测试范围 |
| --- | --- |
| `examples/minimoonbit/frontend_test/moon.pkg` | test-only 导入 lexer、parser、typecheck 和 KNF |
| `examples/minimoonbit/frontend_test/frontend_test.mbt` | 直接组合四阶段的黑盒集成测试 |
| `examples/minimoonbit/README.md` | 补充实际测试命令、已完成阶段和下一步 codegen 边界 |

- [ ] 使用内联的代表性 MiniMoonBit source 完成 `tokenize -> parse -> typecheck -> knf_transform`。
- [ ] source 至少经过函数、局部绑定和一种控制流；必要时再加入 closure 或 struct/enum，但保持单个测试足够短、失败易定位。
- [ ] 检查稳定的阶段结果或 KNF 结构，不读取外部 fixture，不引入 fs、process、async 或 CLI。
- [ ] 确认 91 个原测试仍全部存在并通过，另有至少 1 个新集成测试。
- [ ] README 明确下一轮才开始 port codegen；届时碰到 llvm.mbt 缺失 API，再按实际调用点逐项补齐。

建议提交信息：`test(minimoonbit): verify the frontend pipeline`

## 每个 commit 的验收要求

Commit 1 仅修改本文档：

- [ ] `git diff --check` 通过。
- [ ] 不包含代码、测试、依赖或生成接口改动。

Commit 2—11 每次提交前：

- [ ] 运行 `moon info && moon fmt`，生成文件不手工修改。
- [ ] 审核新 package 的 `.mbti`；现有 `IR`、`unsafe` 等 package 的公开接口不应变化。
- [ ] 运行 `moon check --target native`。
- [ ] 运行当前 commit 对应的最小 package 测试，再运行 `moon test --target native`。
- [ ] 运行 `git diff --check`，确认没有 `_build`、旧 `.mooncakes`、临时 snapshot 或原项目生成物进入提交。
- [ ] 对照原文件核查：除 package/toolchain/doc 适配外，不应出现无法解释的算法 diff。
- [ ] 新增或保留的公开声明符合 `docs/style-guide.md`；示例不要求每个声明都带 doc test。

如果某个 source commit 无法在不加临时 stub 的情况下独立通过 check，应调整该 commit 的文件边界，但不得提交占位实现。若测试发现原 MiniMoonBit 本身的缺陷，应先把“忠实迁移”和“行为修复”拆成两个 commit；行为修复是否纳入本轮由人工 review 决定。
