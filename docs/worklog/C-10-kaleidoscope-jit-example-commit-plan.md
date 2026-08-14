# Kaleidoscope JIT 示例的 commit 划分

> 状态：待实施
> 日期：2026-08-14

本轮在 `examples/kaleidoscope/` 中实现一个 host-only Kaleidoscope。它的目的不是逐行翻译 LLVM 官方教程，而是作为独立下游模块，只使用 llvm.mbt 已公开的安全 `IR` 和 `JIT` 能力，验证以下完整链路：

```text
readline input
  -> lexer
  -> parser + AST
  -> LLVM IR generation + verification
  -> LLJIT submission
  -> symbol lookup + native execution
  -> unload anonymous expression
```

首轮完成后，用户可以在同步 REPL 中定义函数、声明当前进程中的外部函数并求值表达式；语言继续覆盖条件分支、循环、用户自定义运算符和可变变量。示例不会为了追求官方教程的章节完整度直接导入 `internal/raw`，也不会反向修改 `IR` 或 `JIT` 来绕过尚未公开的能力。

## 本轮范围

纳入本轮：

- 独立的 `Kaida-Amethyst/llvm-kaleidoscope` module，以及连接根 llvm.mbt module 的 `moon.work`；
- 数字、标识符、注释、关键字、运算符和标点的 lexer；
- prototype、函数定义、`extern` 和顶层表达式的 AST/parser；
- 唯一运行时值类型 `Double`，以及变量、函数调用、`+`、`-`、`*`、`<`；
- 每个定义或顶层表达式在独立 `Context`/`Module` 中生成和验证 IR；
- 持久函数定义、当前进程外部符号、匿名表达式的 JIT 求值与显式卸载；
- `if/then/else`、`for/in`、用户定义 unary/binary operator、`var/in` 和赋值；
- 使用 `Kaida-Amethyst/readline` 的同步 REPL、History、EOF/Ctrl-C 恢复和基本命令；
- lexer/parser/codegen 黑盒测试，以及实际执行机器码的 Session 集成测试。

明确不纳入本轮：

- PassBuilder、FunctionPassManager、InstCombine、GVN 或其他优化管线；
- DIBuilder、源码级调试位置、DWARF 或调试器集成；
- absolute symbol 注册、任意 MoonBit closure callback，以及官方示例中的 `putchard`/`printd` 宿主注入方式；
- 自定义 JITDylib、同名定义的热重载/遮蔽、lazy compilation、object cache 或并发 JIT；
- cross-target JIT、sandbox、隔离进程或异步执行；
- 字符串、数组、struct、enum、GC 或 Kaleidoscope 之外的语言扩展；
- 多行编辑、语法高亮、完整语义补全或把 readline 封装成 llvm.mbt API；
- 将官方教程第 8 章的 object-file driver 再实现一遍。llvm.mbt 的 native emission 已由 MiniMoonBit 示例和独立测试覆盖；本示例优先验证 JIT 特有的增量生命周期。

如果实现过程中发现某个语义必须依赖新的 llvm.mbt 公开 API，应停止对应 commit 并单独讨论。不得让 Kaleidoscope 直接导入 `Kaida-Amethyst/llvm/internal/raw`，也不得用 C shim 在示例内部复制一套本应属于 llvm.mbt 的通用能力。

## 与 LLVM 官方教程的能力边界

| 官方部分 | 本轮状态 | 边界 |
| --- | --- | --- |
| Lexer、Parser、AST | 实现 | 按 MoonBit 惯用结构编写，不逐行翻译 C++。 |
| 基础 LLVM IR codegen | 实现 | 只使用公开 `IR` package，并对每个提交单元显式 verify。 |
| JIT | 实现 | 使用公开 `LLJIT`、`ResourceTracker` 和 `JITAddress`。 |
| 优化器 | 不实现 | 当前没有公开的安全 PassBuilder/PassManager 抽象。 |
| 控制流 | 实现 | 使用 BasicBlock、conditional branch 和 PHI。 |
| 用户运算符 | 实现 | prototype、precedence 和函数调用都在示例层管理。 |
| 可变变量 | 实现 | 使用 entry-block alloca、load/store 和 lexical scope。 |
| Object emission | 本轮不重复 | llvm.mbt 已支持，但不是本 JIT 示例的验证重点。 |
| Debug information | 不实现 | 当前没有公开的安全 DIBuilder 抽象。 |

因此本轮的语言语义大体覆盖官方教程第 1～7 章，但第四章只覆盖 JIT，不覆盖优化器；第 8 章已有其他示例承担，第 9 章超出当前安全 API。

## module、package 与依赖边界

目标目录：

```text
moon.work
examples/kaleidoscope/
  moon.mod
  README.md
  lexer/
  ast/
  parser/
  codegen/
  session/
  main/
  integration_test/
```

依赖保持单向：

```text
lexer       ast
   \         /
      parser
        |
ast + llvm/IR -> codegen
parser + codegen + llvm/JIT -> session
session + readline -> main
session -> integration_test
```

- 根 `Kaida-Amethyst/llvm` 的 `moon.mod` 保持不依赖 readline；`examples/kaleidoscope/moon.mod` 是独立发布单元，单独声明 llvm.mbt 与 readline。
- 已提交的 `moon.work` 只包含 `.` 和 `./examples/kaleidoscope`。因此 Kaleidoscope 的 `Kaida-Amethyst/llvm@0.4.0` 在本仓库内解析到当前工作区源码。
- readline 默认固定到 Mooncakes 已发布的 `Kaida-Amethyst/readline@0.1.0`，保证普通 clone 和 CI 可复现。联调开发版时可以临时把 `../readline.mbt` 加为第三个 workspace member，但不得提交该机器相关路径。
- 只有 `main/moon.pkg` 导入 readline package。lexer、parser、codegen、session 和自动测试都不依赖终端状态。
- Kaleidoscope package 中为了跨 package 使用而公开的声明仍需遵守 `docs/style-guide.md`；示例 API 不承诺成为 llvm.mbt 的稳定 API。

## 首轮语言契约

首轮沿用 Kaleidoscope 的核心语法，但错误模型、数据结构和 package API 按 MoonBit 重新组织。所有表达式的类型和结果都是 `Double`：

```text
def add(x y) x + y;
extern sin(x);
sin(add(1, 2));

if x < 1 then 1 else x;
for i = 1, i < 5, 1 in i;

def unary!(v) if v then 0 else 1;
def binary% 40 (lhs rhs) lhs * rhs;

var x = 1, y = 2 in (x = x + y) * x;
```

固定语义：

- 数值只使用 `Double`，没有隐式的整数类型；条件值以 `0.0` 为 false，非零为 true。
- 内建 `+`、`-`、`*` 和 `<` 直接生成 LLVM 指令；`<` 的布尔结果转换回 `Double` 的 `0.0`/`1.0`。
- 普通调用必须在 prototype catalog 中存在并精确匹配参数数量；未知函数和 ABI 不匹配在提交前报告 `CodegenError`。
- `extern` 只登记 prototype，不保证符号存在。实际 lookup/materialization 错误在调用该符号的表达式求值时报告；首轮以 `sin` 等 CurrentProcess 可见符号验证。
- 已成功提交的普通函数在 Session 关闭前持续存在；同名再次定义首轮明确报错，不模拟官方自定义 JIT layer 的 newest-first shadowing。
- 顶层表达式生成唯一的零参数匿名函数，绑定独立 `ResourceTracker`；调用成功或失败后都应尝试 remove，不把匿名符号留在 Session 中。
- parser/operator table 与 prototype catalog 采用事务式更新：解析、codegen、verify 或 JIT submission 失败时，不保留半完成的定义、precedence 或 extern 状态。
- 可变变量使用 entry-block alloca；词法 scope 退出时恢复被遮蔽的旧绑定。赋值只允许左侧为已绑定变量。

## JIT 生命周期与失败恢复

每个顶层输入都建立新的 `Context`、`Module` 和 `IRBuilder`，避免复用跨 Module 的 `Value`/`Type`，也不需要调用存在生命周期风险的 `eraseFromParent`。

普通定义：

```text
parse
  -> build fresh module
  -> verify
  -> addModule(default tracker)
  -> commit prototype/operator state
```

匿名表达式：

```text
parse
  -> create ResourceTracker
  -> build and verify fresh module
  -> addModule(tracker)
  -> lookup unique symbol
  -> unsafeToFuncRef[() -> Double]
  -> call while JITAddress and tracker remain reachable
  -> remove tracker
```

- `unsafeToFuncRef` 只集中出现在 `session` package 的私有执行边界。lexer/parser/codegen 和 REPL 都不得接触 `JITAddress` 或 `FuncRef`。
- Session 必须显式 `close()`；REPL 的正常退出和错误退出都要关闭 LLJIT。GC finalizer 只作为 llvm.mbt 自身提供的 fallback，不成为示例的推荐流程。
- 若匿名表达式在 add 之前失败，直接丢弃新 Module；add 成功后无论 lookup 或调用前检查是否失败，都要 remove tracker。
- tracker remove 或 Session close 的错误不能静默吞掉。若主求值已经失败，应保留主错误并把清理失败作为明确的 Session 诊断，而不是假装成功。
- 首轮 Session 只允许串行调用，不在 readline callback 或其他线程中并发 mutate JIT/prototype/operator 状态。

## 测试策略

| 层级 | 测试方式 | 重点 |
| --- | --- | --- |
| lexer | package 黑盒 snapshot | token kind、number、identifier、comment、非法字符和位置。 |
| parser/AST | package 黑盒 snapshot | precedence、prototype、definition、extern、错误位置和完整消费。 |
| codegen | 公开 IR 文本 snapshot + `Module::verify` | 指令、基本块、PHI、alloca/load/store、调用和错误回滚。 |
| session | 实际 JIT 调用 | 返回数值、跨 Module 定义、`sin`、匿名卸载、重复求值和 close。 |
| REPL | 非交互逻辑测试 + 人工 smoke test | 输出格式、EOF、Ctrl-C、History 和 `:quit`；不在 CI 伪造 libedit PTY。 |
| 全链路 | `integration_test` 黑盒测试 | 多轮定义/调用、控制流、运算符、可变变量和失败后继续使用。 |

测试不以“IR 中包含某段字符串”代替真正执行；数值结果应通过 JIT machine code 验证。IR snapshot 只用于定位 codegen 结构变化。REPL 的行读取、编辑和终端恢复由 readline.mbt 自身测试，本仓库只验证 Kaleidoscope 对结果和错误的处理。

## 交付批次与人工 review 停点

| 批次 | commit | 人工 review 重点 |
| --- | --- | --- |
| A | 2～4 | module 隔离、依赖方向、token/AST 公开 shape、precedence 与错误位置。 |
| B | 5～7 | Codegen API、跨 Context 边界、JIT owner/tracker/unsafe 调用和 REPL 依赖隔离。 |
| C | 8～10 | PHI/loop、operator table 事务、alloca scope 和赋值语义。 |
| D | 11 | 失败恢复、资源清理、全链路测试和最终 README。 |

## Commit 1：提交 Kaleidoscope 实施计划

涉及文件和对象：

| 文件 | 对象 |
| --- | --- |
| `docs/worklog/C-10-kaleidoscope-jit-example-commit-plan.md` | 范围、目录、语言契约、JIT 生命周期、commit 边界和测试门槛 |

- [x] 提交本文档；不包含 workspace、module、MoonBit 源码、依赖下载或生成接口。
- [x] 确认本轮以现有安全 API 为上限，不把优化器、debug info 或 absolute symbols 混入计划。
- [x] 确认 object emission 继续由现有 MiniMoonBit 示例承担，不扩大本 JIT 示例的 driver 范围。

建议提交信息：`docs: plan the Kaleidoscope JIT example`

## Commit 2：建立独立 module 与 workspace 骨架

涉及文件和对象：

| 文件 | 对象或职责 |
| --- | --- |
| `moon.work` | 将根 llvm.mbt 与 Kaleidoscope module 纳入同一工作区 |
| `examples/kaleidoscope/moon.mod` | 仅由示例承担 llvm.mbt/readline module 依赖 |
| `examples/kaleidoscope/README.md` | 示例目的、当前状态、运行入口和非目标 |
| `examples/kaleidoscope/{lexer,ast,parser,codegen,session,main,integration_test}/` | package 目录骨架 |

- [x] 根 `moon.mod` 和 llvm.mbt 发布依赖保持不变。
- [x] workspace 默认使用本地 llvm.mbt，但使用 Mooncakes 的 readline；不得提交 `../readline.mbt` 路径。
- [x] 示例 module 固定 `preferred_target = "native"`；后续只有 `main` 成为 executable package。
- [x] 骨架阶段不加入占位 public API、空实现或 warning suppression。
- [x] 从 workspace 根运行 `moon check --target native`，确认双 module 解析成功。

建议提交信息：`examples(kaleidoscope): scaffold the workspace module`

## Commit 3：实现 lexer 与词法测试

涉及文件和公开对象：

| 文件 | 公开对象或职责 |
| --- | --- |
| `lexer/moon.pkg` | lexer package 与 native target |
| `lexer/token.mbt` | `SourcePos`、`Token`、`TokenKind` 及展示语义 |
| `lexer/error.mbt` | `LexError` 与非法输入诊断 |
| `lexer/lexer.mbt` | `tokenize` |
| `lexer/lexer_test.mbt` | 成功与失败的黑盒词法测试 |
| `lexer/pkg.generated.mbti` | 由 `moon info` 生成并审核 |

- [x] 覆盖 identifier、floating-point number、comment、关键字、operator/punctuation 与 EOF。
- [x] `Token` 保留足够的 offset/line/column，以便 parser 错误指向输入位置；不加入完整 source manager。
- [x] 非法字符、畸形数字和 embedded NUL 产生 typed `LexError`，不 panic 或静默截断。
- [x] lexer 无全局 mutable state；所有测试可并行、可重复。
- [x] 公开 type、field、constructor、fn 和 impl 具有符合 style guide 的文档。

建议提交信息：`examples(kaleidoscope): implement the lexer`

## Commit 4：建立基础 AST、parser 与 precedence

涉及文件和公开对象：

| 文件 | 公开对象或职责 |
| --- | --- |
| `ast/moon.pkg`、`ast/expr.mbt` | `Expr` 的 number、variable、binary、call 形态 |
| `ast/prototype.mbt`、`ast/top_level.mbt` | `Prototype`、`TopLevel` definition/extern/expression |
| `parser/moon.pkg`、`parser/error.mbt` | `ParseError` 与 package 依赖 |
| `parser/parser.mbt`、`parser/precedence.mbt` | `Parser`、`OperatorTable`、`parseTopLevel` |
| `parser/parser_test.mbt` | AST snapshot、precedence、trailing input 和错误测试 |
| `ast/pkg.generated.mbti`、`parser/pkg.generated.mbti` | 由 `moon info` 生成并审核 |

- [x] 支持 number、parentheses、variable、call、内建 binary expression、prototype、`def`、`extern` 和顶层表达式。
- [x] parser 从显式 `OperatorTable` 读取 precedence，不依赖进程全局表，为后续用户运算符保留事务边界。
- [x] 输入必须完整消费到分号或 EOF；多余 token 不被悄悄忽略。
- [x] duplicate parameter、非法 prototype、缺失 delimiter 和未知 token 给出带位置的 `ParseError`。
- [x] 本 commit 不预先加入未实现的 if/for/operator/var AST constructor。

建议提交信息：`examples(kaleidoscope): parse the core language`

## Commit 5：实现基础 LLVM IR codegen

涉及文件和公开对象：

| 文件 | 公开对象或职责 |
| --- | --- |
| `codegen/moon.pkg`、`codegen/error.mbt` | `CodegenError` 与 llvm/IR 依赖 |
| `codegen/prototypes.mbt` | opaque `PrototypeCatalog` 及查询/事务辅助 |
| `codegen/context.mbt` | 单 Module 的 `CodegenContext`、Context/Module/Builder owner 组合 |
| `codegen/expr.mbt` | number、variable、binary、call lowering |
| `codegen/function.mbt` | prototype、definition 和 anonymous wrapper lowering |
| `codegen/codegen_test.mbt` | IR snapshot、verify 和反向测试 |
| `codegen/pkg.generated.mbti` | 由 `moon info` 生成并审核 |

- [x] 每次编译建立 fresh LLVM Context/Module/IRBuilder，不缓存或跨 Module 复用 `Type`、`Value`、`Function` 或 BasicBlock。
- [x] 支持 `Double` constant、FAdd/FSub/FMul、ordered `<` comparison、UIToFP 和普通 call。
- [x] 函数参数从首期起进入 entry-block alloca 并通过 load 读取，为可变变量阶段预留一致模型；不得到 Commit 10 再大规模改写参数语义。
- [x] prototype catalog 只保存纯 MoonBit AST/ABI 信息，不保存某个 Module 的 `Function` handle。
- [x] unknown variable/function、duplicate definition、argument count mismatch 和 builder/LLVM 错误映射到稳定 `CodegenError`。
- [x] 每个成功 Module 都由调用方显式 verify；失败时丢弃整个 Module，不调用 `eraseFromParent` 回收半成品。
- [x] codegen package 不导入 JIT、readline、async 或 `internal/raw`。

建议提交信息：`examples(kaleidoscope): generate verified core IR`

## Commit 6：建立增量 JIT Session 与真实求值测试

涉及文件和公开对象：

| 文件 | 公开对象或职责 |
| --- | --- |
| `session/moon.pkg`、`session/error.mbt` | `SessionError` 及 parser/codegen/JIT 依赖 |
| `session/outcome.mbt` | `EvalOutcome` 的 defined/extern/value 结果 |
| `session/session.mbt` | opaque `Session`、`new`、`evaluate`、`close` |
| `session/session_test.mbt` | 实际机器码执行、跨 Module、`sin`、失败恢复和 close 测试 |
| `session/pkg.generated.mbti` | 由 `moon info` 生成并审核 |

- [x] 普通 definition 使用 LLJIT default tracker 持久保存；extern 只在 codegen state 中登记 prototype。
- [x] 顶层 expression 使用唯一符号名和独立 ResourceTracker，lookup 后转换为 `() -> Double` 并真实调用。
- [x] `JITAddress` 和 tracker 在 FuncRef 调用期间保持可达；remove/close 后绝不再次调用既有 FuncRef。
- [x] anonymous tracker 在成功、lookup 失败和可恢复错误路径都按计划 remove；清理错误不能静默丢失。
- [x] definition/extern 只有在 parse、codegen、verify 和必要的 JIT add 全部成功后才提交 catalog 状态。
- [x] 测试覆盖 `1 + 2 * 3`、定义后跨 Module 调用、CurrentProcess `sin`、unknown symbol、重复定义、错误后继续求值、重复 Session 和显式 close。
- [x] unsafe address conversion 只出现在 session 私有实现，公开 `.mbti` 不暴露 JITAddress/FuncRef。

建议提交信息：`examples(kaleidoscope): evaluate expressions with LLJIT`

## Commit 7：接入 readline REPL

涉及文件和对象：

| 文件 | 对象或职责 |
| --- | --- |
| `main/moon.pkg` | 唯一导入 readline 的 executable package |
| `main/main.mbt` | editor/history 创建、同步读取循环、输出和显式 Session close |
| `main/command.mbt` | `:help`、`:quit` 等不进入语言 parser 的本地命令 |
| `main/command_wbtest.mbt` | 命令识别和结果格式化测试 |
| `examples/kaleidoscope/README.md` | 首个可运行命令、示例会话和依赖说明 |

- [x] `Some(line)` 才交给 Session；EOF 正常退出，Ctrl-C 丢弃当前输入并继续使用同一个 editor/Session。
- [x] 明确空输入、本地命令和求值失败输入的 History 策略；该策略由 REPL 层负责，不影响 Session 状态。
- [x] 正常退出、readline error 和未预期 Session error 都经过统一 cleanup，显式调用 `Session::close()`。
- [x] REPL 不自行生成 IR，不持有 Module、ResourceTracker、JITAddress 或 FuncRef。
- [x] 自动测试不伪造 PTY；完成后人工运行一次基本定义、调用、错误恢复、Ctrl-C 和 EOF smoke test。

建议提交信息：`examples(kaleidoscope): add the readline REPL`

## Commit 8：增加条件表达式与循环

涉及文件和公开对象：

| 文件 | 公开对象或职责 |
| --- | --- |
| `ast/expr.mbt` | `If`、`For` expression constructor |
| `parser/parser.mbt` | `if/then/else` 与 `for/in` grammar |
| `codegen/expr.mbt`、`codegen/control_flow.mbt` | conditional branch、PHI 和 loop lowering |
| `parser/parser_test.mbt`、`codegen/codegen_test.mbt` | AST/IR 成功与错误测试 |
| `session/session_test.mbt` | 条件、嵌套分支、默认/显式 step 和 loop 的真实执行 |
| 相关 `pkg.generated.mbti` | 由 `moon info` 生成并审核 |

- [x] `if` 两个分支都产生 Double，并在 merge block 用 PHI 合流；condition 与 `0.0` 比较。
- [x] `for` 保持 loop variable 的 lexical shadowing，支持可选 step，并在 loop 后恢复旧绑定。
- [x] 每次 branch/body codegen 后重新读取 builder insert block，PHI incoming 不使用陈旧 BasicBlock。
- [x] 失败时丢弃整 Module，不尝试 erase 已插入的 block/instruction。
- [x] 测试真实执行 nested if、零/非零 condition、有限循环和函数内部循环。

建议提交信息：`examples(kaleidoscope): add control-flow expressions`

## Commit 9：增加用户自定义 unary/binary operator

涉及文件和公开对象：

| 文件 | 公开对象或职责 |
| --- | --- |
| `ast/expr.mbt`、`ast/prototype.mbt` | `Unary` expression、operator prototype kind/precedence |
| `parser/parser.mbt`、`parser/precedence.mbt` | unary parsing 与动态 binary precedence |
| `codegen/expr.mbt`、`codegen/function.mbt` | `unaryX`/`binaryX` 函数调用和定义 |
| `session/session.mbt` | operator table/prototype/JIT 的事务式提交与失败回滚 |
| parser/codegen/session 测试 | precedence、关联、调用、失败回滚和真实执行 |
| 相关 `pkg.generated.mbti` | 由 `moon info` 生成并审核 |

- [ ] unary/binary prototype 只接受合法 operator 字符和参数数量；binary precedence 限制在已记录的有效范围。
- [ ] parsing 一个 binary definition 的 body 时临时启用其 precedence；parse/codegen/verify/add 任一失败都恢复旧 operator table。
- [ ] 内建运算符继续直接生成指令；非内建运算符 lowering 为普通函数调用。
- [ ] 首轮拒绝覆盖已成功定义的 operator/function，不提供 newest-first shadowing。
- [ ] 测试证明自定义 precedence 会改变 AST，并通过 JIT 验证 unary 和 binary 结果。

建议提交信息：`examples(kaleidoscope): add user-defined operators`

## Commit 10：增加可变变量与赋值

涉及文件和公开对象：

| 文件 | 公开对象或职责 |
| --- | --- |
| `ast/expr.mbt` | `Var`、assignment 表达式及 binding 表示 |
| `parser/parser.mbt`、`parser/precedence.mbt` | `var/in` grammar 和右结合赋值 |
| `codegen/context.mbt`、`codegen/expr.mbt` | entry alloca、load/store、scope shadow/restore |
| parser/codegen/session 测试 | 初始化、遮蔽、赋值、循环 mutation 和反向测试 |
| 相关 `pkg.generated.mbti` | 由 `moon info` 生成并审核 |

- [ ] 未提供 initializer 的变量默认为 `0.0`；initializer 在新 binding 进入 scope 前求值。
- [ ] 所有变量读取统一 load alloca，赋值返回被写入的 Double 值。
- [ ] entry-block alloca 插入不破坏当前 builder insertion point；空 entry block 和已有 instruction 两条路径都覆盖测试。
- [ ] scope 正常退出和 codegen error 时都恢复被遮蔽的绑定，不污染后续表达式。
- [ ] 赋值左侧不是变量、引用未知变量或重复 binding 时产生明确错误，不触发 LLVM assertion。
- [ ] 通过 JIT 测试局部 mutation、shadowing 和 loop body 更新变量。

建议提交信息：`examples(kaleidoscope): add mutable variables`

## Commit 11：补齐全链路强度测试并收尾文档

涉及文件和对象：

| 文件 | 对象或测试范围 |
| --- | --- |
| `integration_test/moon.pkg` | 仅测试依赖 session，不导入 readline/raw |
| `integration_test/integration_test.mbt` | 多轮 REPL 等价输入的黑盒 JIT 测试 |
| 各 package 测试 | 针对实现中发现的错误恢复和边界分支补强 |
| `examples/kaleidoscope/README.md` | 语言语法、运行方式、示例会话、能力矩阵和非目标 |

- [ ] 组合测试覆盖 definition、cross-module call、extern `sin`、if、for、operator、var/assignment 和匿名表达式卸载。
- [ ] 连续执行大量匿名表达式后，同名匿名符号不会冲突，持久定义仍可调用。
- [ ] lex/parse/codegen/verify/lookup/materialization 错误后 Session 仍可继续使用，半完成状态没有提交。
- [ ] close 前后行为、重复 close 和清理失败映射与 llvm.mbt 的 JIT 生命周期契约一致。
- [ ] README 明确只有 session 私有边界做 unsafe FuncRef 转换，示例不构成 sandbox，也不支持任意宿主回调。
- [ ] README 明确优化、debug info、object driver 和热重定义为何未纳入，而不是把它们误写成 Kaleidoscope 已完成能力。
- [ ] 从干净 workspace 按 README 命令运行 REPL，并在 macOS ARM64/Linux x86_64 CI 上运行非交互测试。

建议提交信息：`test(kaleidoscope): harden the JIT language example`

## 每个 commit 的验收要求

Commit 1：

- [x] 只提交本文档，`git diff --check` 通过。

Commit 2：

- [x] `moon check --target native` 能从 workspace 根解析两个 module。
- [x] 根 `moon.mod`、`IR`、`JIT` 和 llvm.mbt `.mbti` 无变化。
- [x] 没有提交外部 sibling path、下载缓存或 `_build`。

Commit 3～11 每次提交前：

- [ ] 在 workspace 根运行 `moon info && moon fmt`，生成文件不手工修改。
- [ ] 审核当前 commit 涉及 package 的 `.mbti`，只出现计划中的公开对象变化。
- [ ] 运行当前 package 的最小 `moon check --target native` 和测试。
- [ ] 运行 workspace 根 `moon check --target native` 与 `moon test --target native`。
- [ ] 运行 `git diff --check`，确认没有 cache、object、临时 IR、history 文件或可执行文件进入提交。
- [ ] 新增公开 type、field、constructor、error、fn 和 impl 都有符合 style guide 的文档；每个主要功能族至少有一个简短 doc example 或 README 示例。
- [ ] 测试优先使用 `inspect` snapshot；循环内逐项变化等不适用 snapshot 的场景再使用 assertion。
- [ ] Kaleidoscope package 不导入 `internal/raw`；根 llvm.mbt 的公开 `.mbti` 不应因示例实现发生变化。

最终验收：

- [ ] `moon info && moon fmt`。
- [ ] `moon check --target native`。
- [ ] `moon test --target native`。
- [ ] `moon -C examples/kaleidoscope run main --target native` 完成 definition、call、error recovery、Ctrl-C 和 EOF 人工 smoke test。
- [ ] macOS ARM64 与 Linux x86_64 CI 都实际执行 Session JIT 测试。

以下情况必须暂停并回到 discussion：现有安全 API 无法在不悬空引用的前提下表达某个 codegen/JIT 生命周期；需要把 raw handle 或 FuncRef 暴露到 session 外部；CurrentProcess 在支持平台无法解析计划使用的系统符号；动态 operator state 无法在失败后可靠回滚；或者实现必须改变 llvm.mbt 已采用的公开契约。普通 MoonBit API 适配、package 私有结构和不影响上述边界的实现选择可以在 commit 内自行决定。
