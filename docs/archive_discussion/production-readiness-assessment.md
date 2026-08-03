# llvm.mbt 生产可用性诊断与讨论议程

日期：2026-07-20

状态：讨论草案。本文用于逐项讨论、记录决定和形成后续工作计划，不代表已经确定的兼容性承诺，也不直接要求立即实现文中的全部建议。

## 1. 文档目的

本项目希望提供基于 LLVM C API 的 MoonBit LLVM binding，目前目标版本为 LLVM 19。把它推进到生产可用，不只是补齐一个库，也是在真实、复杂的 C binding 中检验 MoonBit 的 FFI、资源管理、测试、文档和 native 构建能力。

本文记录第一轮只读审计的结果，并提出一份可讨论的“生产可用”定义。后续讨论应逐项记录：

- 最终决定；
- 被否决方案及理由；
- 库侧需要完成的工作；
- MoonBit 语言或工具链需要补充的能力；
- 可机器验证的验收标准。

本轮审计没有修改项目源代码。

## 2. “生产可用”的初步定义

建议先采用如下定义作为讨论起点：

> 在明确声明的 LLVM 版本、宿主平台和 API 范围内，普通用户仅使用 stable、非 `unsafe` 接口时，可以从全新环境安装、编译并长期运行；在遵守公开契约的前提下，不会因正常控制流产生内存泄漏、double-free、use-after-free 或 ABI 错配；每个公开接口都真实可编译、可链接、可调用，错误可诊断，文档示例可持续执行。

这个定义包含几个重要边界：

1. “生产可用”不自动等于第一版覆盖全部 LLVM API。
2. 本项目基于 `llvm-c`，因此所谓接口完整性首先只能相对于指定 LLVM 版本的 C API 定义，而不是 LLVM C++ API。
3. 可以存在 `unsafe` 或 experimental 接口，但它们必须与 stable safe API 清楚分层，不能让未实现接口看起来已经可用。
4. 编译通过和少量测试通过不是充分条件；资源安全、ABI、发布安装和长期运行也必须有独立证据。

建议把项目分为两层：

- `unsafe`：尽量机械、ABI 精确的 LLVM C API 层。每个已经导出的声明必须真实存在，签名正确，并清楚记录 ownership、nullable、长度、allocator 和线程约束。
- `IR`：面向普通 MoonBit 用户的安全层。它可以只覆盖明确承诺的生产场景，但默认路径应隐藏裸指针和手工释放责任。

未完成的功能应标为 experimental/unsupported，或者暂不导出。

## 3. 审计基线

本轮执行了以下只读检查：

```text
moon check --target native
moon test --target native
moon coverage analyze
moon coverage report -f summary
```

结果为：

- `moon check --target native` 通过；
- `moon test --target native` 共 19 个测试，19 个通过；
- MoonBit 可插桩代码行覆盖率为 `1108/5187`，约 `21.4%`；
- `unsafe/wrap.c` 不在这份 MoonBit coverage 中；
- 仓库有 979 个 `extern "C"` 声明；
- 文档和教程中共有 162 个 `moonbit nocheck` 代码块。

需要特别注意：当前本机测试环境存在 LLVM header/library 版本混用，见 D01。因此上述“19 个测试通过”不能视为 LLVM 19 兼容性证明。

## 4. 诊断议题

### D01：LLVM 版本和 native 构建不可复现

#### 观察

- README、CI 和项目目标声称使用 LLVM 19。
- 当前四个 `moon.pkg` 的 native link 配置硬编码了本机 Homebrew LLVM 18.1.8 路径。
- `env.sh` 又主要假设 Linux `/usr/lib/llvm-19`。
- CI 通过 `.github/update_moon_link_config.py` 在运行期间改写所有 `moon.pkg`，普通包用户不会自然执行这一步。
- 本机 `moon test --dry-run` 显示，`wrap.c` 编译命令没有带 `moon.pkg` 中声明的 LLVM include 路径；编译器最终从 `/usr/local/include` 找到了 LLVM 20 headers，而链接阶段使用 LLVM 18 library。

因此当前本机测试实际上是：

```text
LLVM 20 headers + LLVM 18 library
```

而不是项目声称的 LLVM 19。

#### 诊断

当前缺少一个对开发者、CI 和包用户一致生效的 native dependency contract。即使测试通过，也无法证明编译和链接使用了同一套 LLVM。

#### 建议

1. 首先决定只支持 LLVM 19，还是支持整个 `19.x`。
2. 构建时从同一个 `llvm-config-19` 获取 include、link flags 和版本。
3. 构建或测试时调用 `LLVMGetVersion`，拒绝不符合契约的动态库。
4. 不在发布包中提交开发者机器的绝对 Homebrew Cellar 路径。
5. 增加“全新 consumer 项目安装并构建”的 CI，而不只测试仓库自身。
6. 明确宿主平台与架构范围。LLVM 能生成哪些 target，和这个 binding 能在哪些 host 上构建，是两件不同的事。

#### MoonBit 反馈

MoonBit 需要更稳定的 native dependency 配置机制，例如受支持的 `pkg-config`、`llvm-config` 或 build-script 接口，并保证 C stub 编译和最终链接读取同一份配置。工具还应能直接展示最终生效的 C 编译命令和依赖版本。

#### 待讨论

1. 是否把 LLVM 19 固定为第一个稳定大版本？
2. 是否承诺所有 `19.x`，还是只承诺 CI 验证过的 patch 版本？
3. 第一版支持哪些 host OS/architecture？

### D02：公开接口不等于真实可链接接口

#### 观察

仓库中共有 979 个 `extern "C"` 声明。对 active extern target 做名称和目标符号审计后：

- 有 877 个唯一 extern target；
- 在当前实际链接的 LLVM 18 library 与 `wrap.o` 中，共有 114 个目标符号不存在；
- 有 119 个 active `__llvm_*` 自定义 wrapper target，其中 77 个没有出现在实际 `wrap.o` 中。

这里一部分直接 LLVM 符号缺失来自版本错配，但 77 个缺失的项目自定义 wrapper 不会因为换成 LLVM 19 自动出现。

例如 `unsafe/IRReader.mbt` 声明并调用 `__llvm_parse_ir_in_context`，但 `wrap.c` 没有对应实现。因为现有测试没有引用该函数，dead-code elimination 使最终链接仍然成功。

还发现了明显的目标符号拼写问题：

```text
LLMVOrcDisposeThreadSafeContext
LLVMIIsACallBrInst
LLVMIIsAFreezeInst
LLVMIsAPhiNode
```

源码中还有约 422 处被注释掉的 C/extern 声明，以及 14 处 `Wrong implementation`、`Incorrect implementation`、`Not implemented` 或 `UnImplemented` 标记。

#### 诊断

`moon check` 只验证 MoonBit 类型；普通测试只会链接可达的 extern。因此大量公开 API 可以长期保持“声明存在，但一调用就链接失败”的状态。

#### 建议

1. 从目标 LLVM 19 headers 生成权威 API manifest。
2. 每个 API 明确标记为 stable、experimental、unsupported 或 deprecated。
3. 为全部公开 extern 生成强制引用的 link-smoke test。
4. 对项目自定义 `__llvm_*` wrapper 做“声明与 object symbol 一一对应”检查。
5. raw 层的完整性按 header/API family 统计，不再用源码行数或声明总数衡量。
6. safe 层按用户场景定义覆盖范围，不要求和 raw 层一比一。

#### MoonBit 反馈

值得增加 `moon ffi check` 一类能力，至少可以：

- 检查 extern 目标符号是否存在；
- 强制链接包的所有 public extern；
- 检查 C prototype 与 MoonBit FFI signature 的 ABI 兼容性；
- 将 symbol、header version 和 ownership metadata 纳入可审计报告。

#### 待讨论

1. 第一个 stable 版本是否要求 raw 层覆盖 LLVM 19 全部 C API？
2. 如果不要求，第一版必须覆盖哪些 API family？
3. 未完成声明是删除、隐藏，还是放入显式 experimental package？

### D03：资源所有权问题已经进入公开类型签名

#### 观察

`IR/Context.mbt` 中 `Context` 是普通值，`Context::drop()` 是可以重复调用的普通公开方法：

```moonbit
pub struct Context(@unsafe.LLVMContextRef) derive(Eq)

pub fn Context::drop(self : Context) -> Unit {
  @unsafe.llvm_context_dispose(self.0)
}
```

同时，`Module::getContext()` 把 borrowed context 也包装成同一个 `Context` 类型：

```moonbit
pub fn Module::getContext(self : Self) -> Context
```

这意味着类型系统无法区分：

- `Context::new()` 返回的 owner；
- `Module::getContext()` 返回的 borrowed view。

当前 API 因而允许：

- owner 被复制后重复释放；
- borrowed context 被误释放；
- owner 释放后仍继续使用子对象；
- Module、IRBuilder、Interpreter、GenericValue 等高层对象默认泄漏；
- 将来简单补 destructor 后，ownership transfer 场景又产生 double-free。

LLVM 中至少存在以下关系：

| 对象 | 主要语义 | 典型关系 |
|---|---|---|
| Context | owner | Module、Type、Builder 依赖它 |
| Module | owner，同时依赖 Context | Function、Value、BasicBlock 是其内部 view |
| IRBuilder | owner，同时依赖 Context | 插入点依赖 BasicBlock/Instruction |
| MemoryBuffer | owner 或被条件消费 | parser/bitcode API 可能接管它 |
| ExecutionEngine | owner | 创建时可能接管 Module |
| TargetMachine | owner | DataLayout 等对象可能依赖它 |
| DIBuilder | owner | 依赖 Module，并有 finalize/dispose 顺序 |
| GenericValue | owner | 由 ExecutionEngine API 创建和消费 |
| LLVMErrorRef/message | affine owner | 不同结果使用不同 consume/dispose 函数 |
| ORC/LLJIT 对象 | owner/shared/retained 混合 | 含引用计数、回调和线程约束 |

#### 诊断

这不是“补几个 dispose”可以解决的问题。ownership、borrow、transfer 和 parent-child lifetime 必须进入 safe API 的类型设计，否则释放函数越完整，double-free 和悬垂引用风险反而越大。

#### 建议

1. 建立一份 LLVM C API ownership ledger，逐个记录：
   - 谁创建 owner；
   - 谁负责销毁；
   - 返回值是 owned、borrowed 还是 retained；
   - 参数是否 transfer；
   - transfer 是无条件还是依赖返回状态；
   - child 依赖哪个 parent；
   - 销毁顺序和线程约束。
2. safe 层默认不暴露可以任意重复调用的裸 `dispose`。
3. 普通调用只借用 resource；显式 close 使用 `consume self`；作用域出口执行不可失败的最低限度 Drop。
4. borrowed view 不得伪装成 owning wrapper。
5. 在设计稳定前，不要为所有 raw handle 机械添加自动 destructor。

#### MoonBit 反馈

这部分直接对应 `~/Devlopment/ideas7/discussion/resource-semantics-phase1.md` 和 `lifetime-semantics-discussion.md`：

- Phase 1 affine resource、`consume` 和确定性 Drop；
- P1-T10 adopt/disarm；
- P1-T11 parent-child resource return；
- 后续 parent-bound borrow 或 RC owner token；
- conditional consume/resource-aware result。

LLVM 是很好的分层压力测试：简单 owner 可以验证 Phase 1；Context/Module/View 会检验 parent-bound borrow；ExecutionEngine、bitcode 和 ORC 会检验 transfer、conditional consume、shared handle 和 callback。

#### 待讨论

1. safe API 是否以“普通用户不能手工 dispose”为原则？
2. Context/Module 的父子关系先使用 RC owner token，还是等待 parent-bound borrow？
3. Phase 1 无法表达的接口应进入集中 `unsafe` 边界，还是暂不提供 safe wrapper？

### D04：`CStr` 同时丢失 ownership、allocator 和编码信息

#### 观察

`unsafe/wrap.c` 中 `moonbit_str_to_c_str` 每次调用都会 `malloc`。MoonBit 源码中约有 170 处该转换的声明或使用，但没有看到与每次分配成对的释放调用。

反方向的 `c_str_to_moonbit_str` 不释放指针。这是因为 LLVM 返回的字符串可能分别属于：

- borrowed `const char *`，不得释放；
- 使用 `LLVMDisposeMessage` 释放；
- 使用 `LLVMDisposeErrorMessage` 释放；
- 使用普通 `free` 释放；
- 由某个父对象控制生命周期。

当前这些指针全部表示成同一个 `CStr`，allocator provenance 已经丢失。一个通用 `CStr::free` 不能安全解决所有情况。

当前字符串转换还有功能正确性问题：MoonBit 到 C 的转换把所有非 ASCII 字符替换为 `?`，C 到 MoonBit 也不是 UTF-8 解码。文件名、symbol name、section name、IR metadata 等包含 Unicode 时会静默损坏。

`LLVMPrintModuleToString`、`LLVMPrintTypeToString`、`LLVMPrintValueToString` 和 error message 等 owned return 在转成 MoonBit String 后也没有调用对应 disposer。

#### 诊断

`CStr` 不应同时表示临时输入 buffer、borrowed output、LLVM message owner 和 libc-owned buffer。当前问题既是泄漏，也是潜在 invalid free 和数据损坏问题。

#### 建议

1. 区分至少以下概念：
   - scoped UTF-8 input；
   - borrowed C string view；
   - LLVM message owner；
   - LLVM error message owner；
   - libc-owned buffer。
2. 输入字符串转换应使用作用域受控的临时 buffer，调用结束立即释放。
3. owned output 应在复制为 MoonBit String 后由同一个 wrapper 立即调用正确 disposer。
4. 明确 embedded NUL 的行为：拒绝、转义，或者只允许 length-based API。
5. 统一使用 UTF-8，增加 ASCII、中文、emoji、embedded NUL 和大字符串测试。

#### MoonBit 反馈

MoonBit native FFI 需要标准、低样板的 scoped UTF-8 bridge，以及能表达“本次调用借用”“返回值由指定函数释放”的 ownership metadata。否则每个 binding 都会重复实现一套容易出错的 C string wrapper。

#### 待讨论

1. String 到 C 的标准 ABI 是否统一为 UTF-8？
2. 是否需要编译器或标准库提供 `with_c_string` 一类 scoped bridge？
3. allocator/disposer 是否进入 FFI 声明 metadata？

### D05：C wrapper 和 ABI 质量不足

#### 观察

在本机 LLVM 20 headers 下，对 `unsafe/wrap.c` 开启常规严格警告后得到 9 个警告，主要包括：

- signed/unsigned 转换；
- `size_t` 截断到 `int32_t`；
- UTF-16 code unit 截断到 `char`；
- 老式无 prototype 函数声明；
- enum 到 `int` 的隐式转换。

使用 LLVM 18 headers 编译时还会因为 LLVM 19/20 新 enum 成员产生错误。当前 package flags 使用 `-w`，把这些信号全部隐藏。

`wrap.c` 还存在以下结构性问题：

- 手工维护大量 enum 映射，版本漂移时容易错位；
- 部分非 void 函数不是所有路径都有返回值；
- 错误时调用自定义 `panic()`，其行为是打印到 stdout 后 `exit(1)`；
- 多个 wrapper 被注释并标记为错误实现；
- `size_t`、`unsigned`、`UInt`、`UInt64` 的映射不统一；
- callbacks、out-params、数组和结构体 ABI 缺少系统验证。

#### 诊断

生产库不能在输入错误、版本偏差或未知 enum 时直接终止宿主进程。C wrapper 也不能依赖关闭警告来保持“干净”。

#### 建议

1. C wrapper 使用 `-Wall -Wextra -Wpedantic`，项目自身代码逐步达到 `-Werror`。
2. 移除全局 `-w`，必要时只对第三方 header 定向 suppress。
3. 尽量直接绑定 ABI 相同的 enum；确需转换时由 LLVM 19 header manifest 生成映射和 exhaustive tests。
4. 为 `size_t`、pointer-width integer、enum size、Bool、callback 和 struct layout 建立统一 FFI 类型。
5. 不在库代码中调用 `exit`；预期错误返回 typed error，内部 invariant 失败使用明确的 MoonBit panic/abort 边界。
6. 用 C compile-time assertions 和小型 ABI harness 检查类型大小、对齐和 prototype。

#### MoonBit 反馈

需要更完善的 ABI 基础类型、header-driven bindgen、C prototype checker，以及 callbacks、out-params 和 slice/array 的标准表达方式。

#### 待讨论

1. `unsafe/wrap.c` 长期应手写、生成，还是生成基础层后只手写少量适配器？
2. MoonBit FFI 是否需要原生 `size_t`/`uintptr_t` 等类型？
3. 未知 LLVM enum 应返回 error、保留 raw integer，还是视作经过版本检查后的 unreachable？

### D06：错误模型、nullable 和 ownership 没有统一表达

#### 观察

当前 API 混合使用：

- `Bool`/`LLVMBool` 状态码；
- nullable raw ref；
- `Option`；
- `(value?, String)` tuple；
- typed `raise`；
- `println` 后 `panic()`；
- C 侧 `exit(1)`。

LLVM C API 中常见的“0 表示成功”“失败时填写 out-message”“返回 ErrorRef 后必须 consume”等模式，需要同时处理状态、输出值和资源责任。当前多个 wrapper 只完成了值转换，没有完成 error message 的释放。

#### 诊断

如果错误模型不统一，调用者难以判断失败后哪些输入仍有效、哪些输出需要释放、错误字符串由谁管理。它也会阻碍 Phase 1 对 conditional consume 的实验。

#### 建议

1. safe 层统一使用 typed error/`raise`，不把 LLVM status convention 泄漏给普通用户。
2. raw 层保留 LLVM 原始 status，但把 ownership contract 写入声明和文档。
3. 每个 fallible wrapper 在同一个函数内完成 out-param 解包、message 复制和资源释放。
4. 对“失败后 owner 是否仍有效”逐 API 记录，不假设所有 consume 都是无条件的。
5. nullable 与错误是不同概念，不用一个 null 同时表达“没有值”“失败”和“已经关闭”。

#### 待讨论

1. safe 层错误类型按 API family 拆分，还是统一为带 LLVM message 的错误族？
2. conditional consume 在 Phase 1 之前如何暴露？
3. 哪些 LLVM fatal-error API 可以进入 stable safe 层？

### D07：测试数量和覆盖率不能支撑当前公开面积

#### 观察

当前 19 个测试主要覆盖 IRBuilder 的算术、cast、branch、memory、PHI 和 attribute。以下区域大量为 0%：

- BasicBlock；
- GlobalValue；
- Interpreter/JIT；
- BitReader/BitWriter；
- Target/TargetMachine；
- DebugInfo；
- LLJIT/ORC；
- Object/Remarks/Support；
- 多数资源释放和错误路径。

部分测试文件为空或只包含注释。现有 coverage 只覆盖 MoonBit 插桩点，不能说明 `wrap.c` 的分支、UB 和泄漏情况。

#### 诊断

一个统一的全局 line coverage 百分比并不能代表 binding 质量。资源和 ABI adapter 即使代码很短，也比大量纯 enum conversion 更关键。

#### 建议

建立分层测试策略：

1. **符号测试**：每个公开 extern 都可编译并链接。
2. **ABI 测试**：C prototype、类型大小、数组/out-param、callback。
3. **资源测试**：正常返回、`raise`、早退、失败注入、重复 close、parent 先释放。
4. **sanitizer 测试**：Linux CI 使用 ASan、LSan、UBSan，必要时补 Valgrind。
5. **功能测试**：按 API family 覆盖正向、边界和反向输入。
6. **差分/round-trip 测试**：与 `llvm-as`、`llvm-dis`、`opt`、`llc` 互操作。
7. **长时间测试**：循环创建/销毁 Context、Module、Builder、Message，检测稳定 RSS 和资源计数。
8. **compile-fail 测试**：未来 resource 语义的 use-after-move、double consume、borrow escape 和非法跨 `await`。

覆盖率门槛建议按风险设置：

- ownership、error 和 allocator adapter 的所有分支必须覆盖；
- safe 层设置较高 line/branch coverage 门槛；
- raw generated layer采用 manifest completeness 和 smoke test，不强求无意义的逐行快照；
- C 层单独报告 coverage；
- CI 阻止覆盖率下降，并维护显式 uncovered allowlist。

#### MoonBit 反馈

MoonBit 需要更方便的 native sanitizer 集成、C coverage 汇总、compile-fail/diagnostic snapshot test，以及把 MoonBit 和 native stub coverage 合并展示的工具。

#### 待讨论

1. stable safe 层的 line/branch coverage 门槛是多少？
2. raw 层采用 coverage 指标还是 manifest/smoke completeness？
3. sanitizer 应覆盖哪些平台和构建模式？

### D08：doc test 已整体失效

#### 观察

当前有：

- 138 个位于 `.mbt` API 文档中的 `moonbit nocheck`；
- 24 个位于 tutorial 中的 `moonbit nocheck`；
- 0 个 active `moonbit check`。

在临时副本中把它们全部切换为 `moonbit check` 后，首轮产生 482 条错误：

- 135 个 4190 错误：代码块需要包装为当前 doctest 接受的 `test {}`；
- 323 个 3002 语法错误：多数是上一问题引起的级联顶层语句错误；
- 24 个 4020 错误：tutorial package 没有加载 `IR` 依赖。

即使先修复 `test {}` 和 import，后面仍可能暴露 API 重命名、错误处理和 snapshot 变化，因此 482 不是最终问题总数。

#### 诊断

文档目前不是可执行契约。大量 `nocheck` 让 API 漂移和语言语法迁移长期不可见。

#### 建议

1. 分批恢复 doctest，先从 Context/Module/IRBuilder 的最小使用路径开始。
2. 所有新 stable API 必须带可执行的最小示例。
3. tutorial package 显式声明依赖，不依靠隐式可见性。
4. doc test 只展示基本用法；复杂反向和强度测试仍放在 `test` 包。
5. CI 禁止新增无理由的 `nocheck`，现有 `nocheck` 使用可递减计数或 allowlist。

#### MoonBit 反馈

建议提供 legacy doctest migration/fix 工具，并把诊断按代码块聚合。还可以区分“完整 top-level declarations”和“自动包装为 test body 的示例片段”，减少文档为了测试而增加的噪声。

#### 待讨论

1. doctest 是否要求 stable API 达到 100% 可检查？
2. MoonBit 是否需要新的 snippet fence mode，而不是所有示例手写 `test {}`？
3. `nocheck` 是否必须附 issue/reason？

### D09：接口文件和发布 API 缺少单一权威来源

#### 观察

当前每个 package 同时存在旧命名 `.mbti` 和 `pkg.generated.mbti`，且内容并不一致：

- `unsafe/unsafe.mbti` 与 `unsafe/pkg.generated.mbti` 有大规模差异；
- `IR/IR.mbti` 与 `IR/pkg.generated.mbti` 也有大规模差异。

差异中可能包含格式和当前工具链生成规则变化，但对用户来说仍然意味着“哪个文件代表真实 API”不明确。

README 同时使用“官方绑定”“完整 LLVM 能力”“全平台支持”等较强表述，而实际 safe API、host 构建和 JIT/DebugInfo/Object 支持尚不完整。

#### 诊断

生产库需要一个可追踪的 public API surface 和与之匹配的文档口径。否则 semver、deprecation 和升级审查都无法可靠执行。

#### 建议

1. 只保留一种权威 interface generation 流程。
2. CI 运行 `moon info` 并检查无未提交 diff。
3. 对 stable API 生成 machine-readable API diff。
4. 明确命名风格：raw 层贴近 LLVM C API，safe 层采用稳定一致的 MoonBit 风格。
5. README 的能力声明与 stable profile、host matrix 和测试证据保持一致。

#### 待讨论

1. 哪一套 `.mbti` 文件是今后的权威来源？
2. safe 层是否继续“贴近 C++ 风格”，还是逐步形成更 MoonBit-native 的 API？
3. 何时开始 semver compatibility gate？

### D10：CI 目前验证的是仓库 happy path，不是发布质量

#### 观察

CI 当前覆盖 Ubuntu/macOS 和 MoonBit latest/nightly，但：

- Windows 被注释掉；
- native 配置依赖 CI 内部脚本改写；
- `moon info` 和 format diff 检查被注释；
- doctest 暂时禁用；
- 没有 sanitizer、C warnings、ABI、symbol completeness、package install 和 consumer test；
- 没有验证动态库实际版本与 header 版本一致。

#### 建议

把 CI 分为：

1. source quality：fmt、info diff、lint、C warnings；
2. exact LLVM 19 build matrix；
3. unit/negative/doctest；
4. symbol/ABI audit；
5. sanitizer/resource tests；
6. fresh consumer install；
7. release smoke：生成 IR、bitcode 和 object，并用 LLVM 工具链验证。

nightly MoonBit failure 可以帮助发现语言兼容问题，但 production release 还应固定一套已验证的 MoonBit compiler/runtime 版本范围。

#### 待讨论

1. MoonBit minimum version 如何声明和测试？
2. nightly failure 是 blocking 还是提前预警？
3. Windows 是第一版目标、后续目标，还是明确不支持？

## 5. 建议的第一个 stable profile

不建议在第一阶段同时修复所有 API family。一个可能的纵向 stable profile 是：

1. Context；
2. Module；
3. 常用 Type/Value/Constant；
4. Function/BasicBlock；
5. IRBuilder；
6. module verification；
7. IR parsing/printing；
8. bitcode read/write；
9. PassBuilder；
10. TargetMachine 和 object emission。

这条路径足以支持“构造 IR → verify → optimize → 生成 bitcode/object”的真实编译器场景。

以下模块可先作为 experimental，直到资源和测试模型成熟：

- ExecutionEngine/MCJIT；
- ORC/LLJIT；
- DebugInfo；
- Object iterators；
- Remarks；
- callbacks 和长期保存的 MoonBit closure。

这里不是最终决定。需要讨论的是：第一个稳定版本要解决哪个真实用户故事，而不是先追求声明数量最大化。

## 6. llvm.mbt 作为 MoonBit resource 实验

建议按复杂度逐层实验，而不是一次性把全部 raw handle 改成 resource。

### R1：独立 affine owner

候选对象：LLVM owned message、error message、TargetMachine、MemoryBuffer、GenericValue。

检验：

- 自动 Drop；
- 显式 `close(consume self)`；
- normal/raise/temporary cleanup；
- 正确 disposer；
- use-after-move 和 double consume 诊断。

### R2：parent-bound owner

候选关系：

```text
Context → Module
Context → IRBuilder
Module → DIBuilder
```

检验：

- Phase 1 P1-T11 压力；
- unsafe independent-return assertion 的数量；
- RC owner token 的运行时成本；
- 窄化 parent-bound borrow 是否足够。

### R3：borrowed view

候选关系：

```text
Context/Module → Type
Module → Function/Value/BasicBlock
Function/BasicBlock → Instruction/Argument
```

检验：

- borrowed return 的规模；
- view 是否需要保存；
- 单 parent 和多 parent 关系比例；
- 完整 lifetime parameter 是否真的必要。

### R4：ownership transfer 和 conditional consume

候选 API：ExecutionEngine 创建、bitcode parser、Linker、部分 ORC API。

检验：

- 无条件 `consume` 能覆盖多少；
- 失败后归还 owner 的 API 数量；
- resource-aware result 或 conditional consume 的必要性；
- wrapper 中 closed/null 状态机和 unsafe 数量。

### R5：shared、callback、thread-bound

候选 API：ORC/LLJIT、symbol string pool、diagnostic handler、fatal error handler。

这部分超出同步 affine Phase 1，应单独记录：

- retain/release；
- MoonBit closure root/unroot；
- callback 生命周期；
- 线程亲和；
- shutdown 顺序；
- C 与 MoonBit runtime 之间的引用环。

每一层都应统计：

- unsafe assertion 数量；
- adopt/disarm 数量；
- forced copy 数量；
- RC owner token 数量；
- closed/null 状态字段数量；
- 无法表达的 API 数量；
- 普通用户 API 的可读性；
- 诊断是否能说明 owner、move 和 borrow 来源。

这些数据应反向决定 MoonBit resource 和 lifetime 设计，而不是预先假设完整 Rust 模型或纯 RC 模型一定正确。

## 7. 建议的发布门槛

一个版本只有同时满足以下条件，才可以称为 stable production release：

### 构建与版本

- 从全新环境可安装；
- header、library 和 runtime LLVM version 一致；
- 支持平台全部在 CI 中验证；
- 不依赖开发者本机绝对路径或发布后改写源码。

### 接口

- stable manifest 中没有缺失符号；
- C/MoonBit ABI signature 已审计；
- unsupported API 不以可调用 stable 接口出现；
- public API diff 经过审查。

### 安全

- safe profile 在 normal/raise 路径没有已知 leak、double-free、UAF；
- CStr、message 和 ErrorRef 使用正确 allocator/disposer；
- nullable、borrow、transfer 和 parent relation 有明确契约；
- 库不会因预期错误调用 `exit(1)`。

### 测试

- stable profile 具有功能、错误、边界和资源测试；
- 所有 stable 文档示例可检查；
- sanitizer CI 通过；
- C 层和 MoonBit 层分别有可解释的 coverage；
- 与 LLVM 工具链的 round-trip 测试通过。

### 维护

- 明确 LLVM 与 MoonBit 版本支持策略；
- 有 deprecation 和 semver 规则；
- 新 LLVM major 可以自动生成 API/ABI 差异报告；
- 有最小真实项目作为持续集成 consumer。

## 8. 建议的讨论顺序

为了避免同时修改过多变量，建议按以下顺序逐项拍板：

1. **P01：LLVM 版本契约**——固定 LLVM 19 还是支持 `19.x`。
2. **P02：宿主平台范围**——Linux、macOS、Windows 和架构。
3. **P03：第一个 stable profile**——完整 raw C API，还是先交付纵向编译器路径。
4. **P04：safe/unsafe/experimental 分层**——什么可以公开承诺。
5. **P05：C string 与 message ownership**——先解决最普遍的泄漏与编码问题。
6. **P06：Context/Module/IRBuilder resource 模型**——验证 Phase 1。
7. **P07：parent-bound view 策略**——RC token、窄化 borrow 或完整 lifetime 的评估顺序。
8. **P08：conditional consume**——ExecutionEngine、bitcode、Linker 的处理方式。
9. **P09：接口和 ABI 审计工具**——库内脚本还是 MoonBit 工具链能力。
10. **P10：测试与发布门槛**——coverage、sanitizer、doctest、consumer CI。

后续每讨论完一项，应在本文追加：

```text
状态：已决定 / 暂定 / 推迟
决定：
理由：
库侧行动：
MoonBit 侧行动：
验收测试：
```

## 9. 当前总体判断

当前项目已经有相当大的 raw binding 面积和一段可用的 IRBuilder safe facade，但仍属于“可以演示和继续开发”，尚未达到生产可用。主要阻断点按优先级是：

1. LLVM 版本与构建不可复现；
2. 大量公开 extern 无法真实链接；
3. safe API 无法表达 owner、borrow 和 transfer；
4. CStr 和 LLVM owned message 存在系统性泄漏与编码问题；
5. C wrapper、ABI 和错误模型缺少严格验证；
6. 测试、sanitizer、doctest 和发布安装证据不足。

“接口是否全部完成”反而不应是第一个问题。首先需要保证：凡是项目声称支持的接口，确实使用指定 LLVM 版本编译和链接，ownership 契约明确，并能在真实长时间工作负载中可靠运行。在这个基础上扩大 API 覆盖，才不会把不可审计的风险面一起扩大。

## 10. 专题讨论：MoonBit 1.0 的原生依赖与构建模型

状态：讨论中，以下是针对 `llvm.mbt` 的暂定诊断，不是已经确定的 MoonBit 1.0 方案。

### 10.1 问题不是“能不能运行 llvm-config”这么简单

`llvm.mbt` 最早把 LLVM include 和 link flags 写入 `moon.pkg.json`，在当时是可以理解的临时方案：构建清单不能运行 `llvm-config`，包管理器也不能只下载当前平台需要的 LLVM SDK。若把所有平台二进制塞进同一个源码包，体积又不可接受。

但在 MoonBit 接近 1.0 时，这已经暴露出一个需要明确回答的产品问题：

> `moon add` 的契约是否只覆盖 MoonBit 源码依赖，还是也覆盖一个 native package 所需的原生 SDK、版本、平台选择、校验和链接接口？

如果 MoonBit 1.0 只承诺前者，那么 `llvm.mbt` 可以正式声明“用户必须在外部安装 LLVM 19 SDK”，这不是构建系统 bug，而是一个明确限制。但如果 MoonBit 希望 native FFI 包也能获得接近纯 MoonBit 包的安装体验，那么当前构建与包管理模型确实缺少生产级能力。

这里至少有三个彼此独立的层次：

1. **发现**：运行 `llvm-config`、`pkg-config` 或读取 `LLVMConfig.cmake`，找到已经存在的 SDK。
2. **解析与获取**：根据 target triple、版本和构建变体，选择并下载一个 native artifact。
3. **使用需求传播**：把 include、define、library、link order、runtime search path 等信息正确传播给 C stub 和最终消费者。

只增加一个可以执行 shell 的 build script，最多主要解决第一层。

### 10.2 当前 Moon 构建系统已经具备的能力

当前 `/Volumes/Lexar/Devlopment/moon` 中已经存在 module-level experimental pre-build configuration script，目标正是辅助 native target 编程。它允许 Python/JavaScript 脚本：

- 读取 Moon 进程环境；
- 输出 `${build.*}` 变量；
- 为包输出 link flags、link libraries 和 search paths；
- 让 link configuration 传播到依赖该包的最终目标。

因此，今天已经可以写一个脚本运行 `llvm-config`，再把结果注入 `moon.pkg`。这比修改仓库中的多个 `moon.pkg` 明显更接近正确方向。

另外，Moon 已经把 native compiler/linker 选择、C stub 构建、最终链接放入正式 build plan；`mooncake` 也已经有源码包下载、checksum 和缓存。这些都是继续设计 native dependency 的基础，不必重新发明整个构建系统。

### 10.3 当前 experimental pre-build 还不能成为 1.0 答案

从当前实现看，它仍然明确属于 POC：

- `run_prebuild_config` 会遍历解析图中的所有 module，并执行其中声明的脚本；依赖包因此可以在构建时执行任意 Python/JavaScript。
- 实现注释说明脚本目前总是重新运行；`rerun_if` 已定义但没有效果。
- 传给脚本的 `out_dir` 仍是 `TODO`。
- `BuildInfo`、host、target、architecture、OS、ABI 和 target triple 虽然已经有类型草图，但当前没有实际传给脚本。
- 整份进程环境会传给脚本。它既扩大秘密泄露面，也让“哪些环境变量属于构建输入”无法审计。
- link config 只有少量字段，仍包含单个 `link_flags` 字符串；没有完整表达 include directories、defines、静态/动态库类型、framework、link group、whole-archive、runtime path 和参数顺序。
- `${build.*}` 本质仍是字符串替换，缺少参数边界和类型，路径中的空格及 shell quoting 仍可能出错。
- build script 解决不了 LLVM SDK 从哪里下载，也没有 target-specific artifact manifest。
- `moon add` 下载 registry 包后目前会自动运行 `postadd`。这使“安装依赖”和“执行依赖提供的代码”绑定在一起，是需要在 1.0 前重新审视的供应链边界。
- Moon 的 native conditional compilation 当前主要知道 backend，尚不能在 manifest 层稳定表达 OS、architecture、ABI 和 libc 等 native artifact 选择条件。

这并不说明 build script 不该存在。它适合作为 escape hatch 和 provider 实现机制，但不应成为 native dependency 的唯一模型。

### 10.4 建议区分 requirement 与 provider

binding 本身应该声明**它需要什么**，而不是直接决定用户必须从哪里取得 LLVM。例如，`llvm.mbt` 的需求可以抽象为：

```text
native requirement: LLVM
version: >= 19.1, < 20
link identity: llvm
required components/targets: 项目明确承诺的集合
```

根项目或 workspace 再决定**由谁满足这个需求**：

```text
provider A: system
  通过显式 llvm-config 或 LLVM prefix 发现

provider B: artifact
  从 Moon registry/CDN 获取当前 target 对应的 LLVM SDK

provider C: source build
  从源码构建 LLVM，作为后续扩展而不是 1.0 的首要目标
```

这样做有几个重要性质：

1. 官方 CI 可以强制使用锁定 artifact，获得可复现构建。
2. Linux distribution packager 可以强制使用 system LLVM，遵循系统打包政策。
3. 企业用户可以在 workspace 层替换为内部镜像或内部 SDK。
4. binding 不需要内置平台下载逻辑，也不需要修改发布后的源码。
5. provider 决策属于最终构建者；传递依赖不能悄悄改变全局 native toolchain。

这里还需要类似 native link identity 的概念。两个依赖若分别携带 LLVM 18 和 LLVM 19，不应该在最终链接时默默合并。构建系统至少应能报告同一 `link identity` 存在多个不兼容 provider，而不是等 duplicate symbol 或运行时崩溃。

### 10.5 native artifact 不应塞进源码包

Moon registry 可以把“小型声明包”和“大型平台 artifact blob”分开存储。artifact manifest 至少按下列维度选择：

- target triple；
- OS、architecture、ABI/libc；
- LLVM 版本；
- static/shared；
- 必要时包括 C++ runtime、RTTI、assertions 和 LLVM targets 等构建变体。

每个 artifact 应独立具有 URL、size、checksum，最好还有签名或 provenance。`moon add` 或第一次 native build 只下载当前选择所需要的一份，而不是把所有平台 LLVM 都装进 `.mooncakes`。

下载后的 SDK 应进入全局 content-addressed cache，同一台机器上的多个项目共享；项目 lock/config 记录 digest 和逻辑身份，不记录开发者机器上的绝对路径。真正传给 compiler/linker 的绝对路径只存在于本地 build plan 和 cache key 中。

因此，“LLVM 太大”不是反对 artifact 支持的理由，反而说明 artifact 必须与源码包解耦、按平台延迟下载并全局去重。

### 10.6 原生使用需求必须结构化

生产级构建系统不应只接受两段不透明字符串：

```text
cc-flags = "..."
cc-link-flags = "..."
```

至少应有结构化字段：

```text
compile.include_dirs
compile.system_include_dirs
compile.defines
compile.args
link.search_dirs
link.libs(name, static/shared/framework, modifiers)
link.args
link.runtime_search_dirs
```

还要明确传播范围：

- LLVM headers 只用于编译 `llvm.mbt` 的 C stub；
- LLVM libraries 和 system libraries 需要传播到最终 executable/test；
- 某些 link args 对本包私有，某些属于 public native interface；
- 参数顺序必须保留，尤其是静态链接和 link group。

`llvm-config` 可以作为 provider 的输入，但其输出应被转换为结构化 argv/usage requirements，再进入 build plan；不能把原始 shell 字符串永久写回 manifest。

### 10.7 build configuration script 的合理边界

建议保留配置脚本，但把它从“任意前置命令”收窄成有协议的构建阶段，并与源码生成、安装 hook 使用不同名称。稳定前至少需要：

1. 明确输入 host triple 与 target triple，二者不能混淆。
2. 提供真实、隔离、可缓存的 `out_dir`。
3. 让 `rerun-if-file`、`rerun-if-env` 和 tool fingerprint 真正进入增量构建键。
4. 默认不传递完整环境；由脚本声明或显式请求所需环境变量。
5. 输出使用数组和结构化字段，不使用需要 shell 再解析的 flag 字符串。
6. 记录脚本路径、hash、执行工具版本、stdout protocol version 和最终配置，支持 `moon explain`。
7. 对 registry dependency 的脚本建立明确权限策略；`moon add` 不应在没有告知或授权的情况下自动执行第三方代码。
8. 允许 root workspace 覆盖某 native provider，从而完全跳过依赖包脚本。

完整跨平台 sandbox 很难成为 1.0 的硬前提，但“默认不静默执行”“输出目录隔离”“显式信任/override”“构建记录可审计”应当是最低边界。

### 10.8 对 MoonBit 1.0 的建议范围

不建议 MoonBit 1.0 试图内建 CMake、vcpkg、Conan、Homebrew、apt 和所有 C/C++ source build 模型。更可控的最小闭环是：

1. 稳定 native requirement/link identity 声明。
2. 稳定 system provider：显式工具或 prefix、版本检查、结构化 usage requirements。
3. 通用 target-specific binary artifact：独立 blob、checksum、cache、override。
4. 完成 build configuration protocol：target 信息、out dir、增量依赖、结构化输出。
5. 明确第三方 build/install script 的安全与授权策略。
6. 提供诊断命令，显示每个 native requirement 最终由哪个 provider 满足、版本和路径是什么，以及这些信息为何被选择。

“从源码构建任意 C/C++ 项目”可以后续由 build script/plugin 生态承担。对 1.0 而言，能可靠发现一个系统 SDK，或者可靠下载一个预构建 SDK，已经可以覆盖大部分 binding 发布场景。

### 10.9 用 llvm.mbt 作为验收测试

`llvm.mbt` 很适合作为 MoonBit native dependency 的纵向测试。建议最终用全新 consumer 项目验证：

1. `moon add Kaida-Amethyst/llvm` 不修改依赖源码，也不自动执行未授权安装脚本。
2. system 模式能选择显式 LLVM 19 prefix；找不到、版本错误或 headers/libs 不一致时立即给出清楚错误。
3. artifact 模式只下载当前 target 的 LLVM SDK，并验证 checksum。
4. 第二个项目复用同一个 content-addressed LLVM artifact。
5. C stub include 和最终 link libraries 来自同一个 provider。
6. 修改 `LLVM_CONFIG` 或 provider 选择会使相关 build configuration 和 native objects 正确失效。
7. `moon explain native-deps` 一类命令能显示 LLVM 版本、provider、target、link mode 和最终 usage requirements。
8. 最终 consumer 能完成“生成 IR、verify、优化并输出 object”的真实工作流。

### 10.10 暂定判断

当前问题可以定性为：

> MoonBit 已经有 native compilation pipeline，也有一个可以继续演进的 build-config POC；但 native dependency 仍没有成为包解析图中的一等公民。对准备进入 1.0、并希望支持生产级 native FFI 生态的语言来说，这是一个真实的构建系统缺口。

这个缺口不要求 `moon` 自己理解 LLVM，但要求它理解“一个版本化、平台相关、可由 system 或 artifact 满足、会向最终目标传播编译和链接需求的 native dependency”。`llvm.mbt` 应当用来验证这个通用抽象，而不是让 Moon 构建系统增加 LLVM 专用分支。

### 10.11 构建脚本应优先使用 build.mbtx

针对当前 experimental pre-build 只能运行 JavaScript/Python 的问题，暂定建议是：MoonBit 1.0 的正式构建配置脚本应优先采用 MoonBit 自己编写，并由 Moon 工具链负责编译和执行。

主要理由不是“语言统一”这种表面一致性，而是工具链闭包：

- 能运行 `moon build` 的机器必然已经有 `moon`、`moonc` 和 Moon runtime；
- 不应再要求 native binding 用户安装 Node.js 或 Python；
- build API 可以与 Moon 版本一起发布、类型检查和演进；
- 同一份脚本可以被编译为 host-independent Wasm，而不必为每个 host 先构建 native executable；
- 构建脚本本身可以进入 Moon 的诊断、格式化、测试和缓存体系。

在 `build.mbt` 和 `build.mbtx` 之间，更倾向以 `build.mbtx` 作为第一版入口。当前 `.mbtx` 已经具有“无需 module/package 配置即可编译执行”的语义，且默认 backend 是 WasmGC。这正适合作为独立 bootstrap unit。

普通 `build.mbt` 如果被当作项目中的普通 package 处理，会立刻引入循环问题：构建脚本可能 import 项目依赖；解析这些依赖可能又需要运行它们的构建脚本。Rust 为此维护单独的 host build-dependency graph。MoonBit 第一版可以避免这部分复杂性，只允许 `build.mbtx` import 工具链随附、预编译的 `moonbitlang/build` 和必要 core API。

以后如果真实项目证明单文件不够，再增加独立 `build-deps` 图，而不是让 build script 隐式复用 target package 的普通依赖图。

### 10.12 编译成 Wasm 不自动等于安全

Wasm 提供内存隔离，但构建脚本的实际权限取决于 host imports。只要 runtime 向脚本开放了不受限制的 filesystem、environment、network 和 process spawn，一个恶意 Wasm build script 仍然可以：

- 读取 SSH key、token 和其他项目文件；
- 修改工作区或用户目录；
- 访问网络并上传数据；
- 启动 shell 或其他拥有完整宿主权限的子进程；
- 消耗无限 CPU、内存或输出。

当前 `moonrun` 已经有 experimental policy：一旦指定 policy，filesystem、network、environment 和 process 可以进入 deny-by-default 模式。这是很好的基础，但还不是 build-script sandbox 的完整证明：

- 当前 policy 文档明确说明 WASI surface 没有覆盖；
- `process.spawn = true` 后，子进程获得宿主用户的 ambient filesystem/network/process 权限，其他 policy 不会继续约束子进程；
- build script 需要更细的“允许执行哪些 program”，而不只是一个 process spawn 布尔值；
- 还需要 fuel/time/memory/output 限制和可取消性。

因此，建议专门为 build script 提供 capability-oriented host API，而不是直接暴露通用 async OS API。

### 10.13 建议的 capability 模型

`build.mbtx` 默认只拥有一个由 Moon 注入的 `BuildContext`。所有影响宿主的操作都通过它完成：

```text
ctx.host() / ctx.target()
ctx.read_package_file(path)
ctx.write_output(path, bytes)
ctx.env(name)
ctx.find_program(name)
ctx.run(program, argv)
ctx.rerun_if_changed(path)
ctx.rerun_if_env_changed(name)
ctx.emit_native_usage(package, usage)
```

这些 API 应满足：

1. 文件读取默认限制在当前 module 和声明输入；写入限制在 `OUT_DIR`。
2. 环境变量逐个声明，未声明变量不可见，也不进入 build cache key。
3. process 使用 argv 数组，不经过 shell。
4. script 声明需要运行的 program identity，例如 `llvm-config` 或 `pkg-config`；root policy 决定是否允许。
5. network 默认关闭。artifact 下载由 Moon 自己根据 URL/checksum 完成，而不是让脚本调用 curl。
6. 所有读取、执行和输出形成可审计 trace，并进入缓存或失效判断。
7. registry dependency 的 capability grant 与 script hash 绑定；包升级或权限扩大时重新授权。
8. CI 非交互模式下，未授权 capability 直接失败，不能自动接受。

对于 `llvm.mbt`，一个 system provider 实际需要的权限很小：读取 `LLVM_CONFIG`/`PATH`，执行选定的 `llvm-config`，读取它报告的 include/lib 路径，向 Moon 返回结构化 native usage。它不需要网络，也不需要写工作区。

需要注意，允许执行 `llvm-config` 仍意味着运行一个宿主 executable；Wasm 只是隔离 build script 自身，不能隔离该子进程。若未来需要更强保证，Moon 可以内建 `pkg-config` 解析或读取 provider manifest，尽量减少子进程调用。

### 10.14 不建议照搬 Rust build.rs

Rust `build.rs` 证明了“使用本语言编写构建脚本”在 bootstrap 和生态上是可行的，但也带来一些 MoonBit 可以避免的问题：

- build script 是拥有用户完整权限的 host native executable；
- package dependency 可以在构建时执行任意代码；
- host graph 与 target graph 分离增加了依赖解析和编译成本；
- stdout 文本协议及大量 environment variables 使 API 较弱类型化；
- build script 容易成为不可复现构建的入口。

MoonBit 可以吸收其中成熟的部分：独立 host phase、`OUT_DIR`、`rerun-if-*`、结构化 link directives、native `links` identity、root override；但借助 Wasm 和 typed build API，把 ambient authority 收窄。

### 10.15 build.zig 的启发与边界

Zig 的 `build.zig` 不只是配置探测脚本，而是使用 `std.Build` 构造完整 build DAG。它擅长表达 target、optimize、C/C++ compilation、system library、generated file 和 run step，而且 Zig 工具链本身不需要额外脚本解释器。

这个方向的优点是表达力和组合性强。但 Moon 当前已经有 Rupes Recta 负责构造、验证和 lowering build graph。如果 `build.mbtx` 也能任意定义整个 DAG，会出现两个 build graph authority：

- 哪些节点由 manifest/Rupes Recta 生成，哪些由脚本生成；
- 动态图如何进入 dry-run、watch、IDE 和 remote cache；
- 脚本直接做 I/O，还是只能声明 action；
- 第三方脚本能否改变整个 workspace 的步骤。

因此第一版不建议直接复制 Zig 的完整 programmable build graph。更稳妥的边界是：

> Rupes Recta 仍是唯一 build graph authority；`build.mbtx` 只能返回受 schema 约束的 configuration、native usage requirements 和有限 generated actions，由 Moon 验证后加入图中。

未来若要支持完整自定义 build DAG，可以单独设计稳定的 `std.Build` 类 API；不应与解决 `llvm-config` 的需求一起仓促进入 1.0。

### 10.16 建议的执行阶段

一个避免 bootstrap cycle 的初步流程是：

```text
1. 解析 moon.mod/moon.pkg 的静态部分和 Moon source dependency graph
2. 确定 host triple、target triple、profile 和 root native-provider policy
3. 使用工具链随附的 core/build API，把每个 build.mbtx 编译为 WasmGC
4. 在 deny-by-default capability policy 下执行 build scripts
5. 验证并规范化脚本输出，形成 NativeUsage/GeneratedAction
6. 解析或下载 target-specific native artifacts
7. 把规范化结果加入 Rupes Recta build graph
8. 构建普通 package、C stubs 和最终 artifacts
```

第 3 步不能依赖第 7 步即将构建的普通项目 package；否则重新产生循环。build script 的编译缓存键至少包含：

- `build.mbtx` 内容；
- build API/compiler version；
- build-only imports；
- host execution ABI。

build script 的执行结果缓存键还要包含：

- host/target/profile；
- 被声明读取的环境变量；
- 被声明读取的文件；
- 被执行工具的路径、版本或 fingerprint；
- provider policy；
- capability grant。

### 10.17 build.mbtx 仍不能替代 native artifact 模型

即使正式支持 `build.mbtx`，仍然需要上一节讨论的 native requirement/provider/artifact 抽象。原因包括：

- build script 不应自行决定下载 URL 并绕过 registry checksum；
- cross compilation 时，target SDK 中的 `llvm-config` 可能根本不能在 host 上执行；
- 多个 binding 对同一 native library 的版本冲突需要 resolver 全局处理；
- artifact cache、镜像和 lock 需要包管理器统一管理；
- root project 应能覆盖或禁用依赖包脚本。

因此二者的关系应是：

```text
native dependency model：声明与解析的主干
build.mbtx：system discovery、少量配置探测和生成任务的受控扩展点
```

### 10.18 针对 MoonBit 1.0 的暂定建议

1. 用 `build.mbtx` 替代正式方案中的 `build.js`/`build.py`，避免额外解释器依赖。
2. build script 固定编译到 WasmGC，由随工具链发布的 `moonrun` 执行。
3. 第一版只允许 toolchain-shipped build API/imports，避免 build-dependency cycle。
4. 默认 deny network、ambient env、workspace write 和 process spawn。
5. 使用 capability grant 开放必要的文件、变量和特定 program。
6. script 只返回结构化配置/actions，Rupes Recta 仍拥有最终 build graph。
7. native artifact 下载始终由 Moon 完成，不交给 build script。
8. 等这一模型稳定后，再评估独立 build-dependencies 和 Zig 风格 programmable DAG。

### 10.19 build.mbtx 不使所有 manifest 多余

直接结论是：

- `moon.mod` 所代表的静态 module identity/dependency metadata 不应完全消失，但可以显著缩小职责。
- `moon.pkg` 当前的大部分职责值得重新评估；它可以变成可选、可推导，或者被 source declaration 与 `build.mbtx` 分担。
- `build.mbtx` 不应成为 registry 在下载 package 之前就必须执行的唯一元数据来源。

核心区别不是“配置文件还是代码”，而是**数据**和**计算**：

```text
静态事实：名字、版本、license、MoonBit 版本要求、source dependencies、checksum
动态计算：target 条件、探测系统 SDK、生成文件、构造特殊 build actions
```

静态事实需要在不执行第三方代码的情况下被 registry、resolver、IDE、审计工具和 `moon add` 读取。动态计算才适合交给 `build.mbtx`。

如果所有信息都只存在于 `build.mbtx` 中，Moon 为了回答“这个 module 叫什么、依赖谁、有哪些 package”就必须先编译和执行不受信任的代码。这会把 dependency resolution、registry indexing、license audit 和 IDE discovery 全部变成 code execution，并重新引入 bootstrap cycle。

### 10.20 当前 moon.mod/moon.pkg 分层的合理部分

当前 Moon 的概念分层本身不是没有理由：

- module 是版本、发布和下载单位，类似 Go module；
- package 是编译、namespace 和 package dependency 单位，类似 Go package；
- 一个 module 可以包含多个 package。

因此 module-level 和 package-level 信息在逻辑上确实不同。`moon.mod` 管理 module name/version/dependencies，`moon.pkg` 管理具体 compilation unit/imports/tests/link options。

这个模型对大型代码库也有一个优点：package 配置跟随目录，不需要所有人修改根部一个巨大的 package table。它更接近 Dune/Bazel 的 distributed build description，而不是 Cargo 的“一份 Cargo.toml 对应一个 crate”。

所以问题不是简单地“两个文件一定比一个文件差”，而是 package 级别究竟有多少信息必须由独立 manifest 声明。

### 10.21 当前设计的可疑之处

当前 `.mod`/`.pkg` 新格式采用一套 assignment/apply/import 的小型 DSL，看起来接近 MoonBit，但它不是真正的 MoonBit：

- 不能定义函数或抽象重复配置；
- 不能自然表达复杂 target/host 条件；
- 不能组合可复用构建逻辑；
- 许多字段仍通过 `options(...)` 搬运旧 JSON schema；
- build system、formatter、LSP 和 schema 需要维护另一套 parser/semantics。

这形成一个尴尬中间态：

```text
不再是简单、通用、诚实的 JSON/TOML 数据文件
但又没有真正可编程 build language 的表达力
```

如果正式引入 `build.mbtx`，就更没有必要继续把复杂动态能力塞入 `.mod/.pkg` 的专用 DSL。更清晰的边界是：manifest 保持静态、规范、机器可改写；动态逻辑使用真正的 MoonBit。

### 10.22 moon.pkg 比 moon.mod 更值得怀疑

`moon.mod` 至少有一些很难从源码推导的稳定事实：

- module canonical name；
- version；
- direct source dependencies 与版本范围；
- minimum MoonBit/toolchain version；
- license/repository/publish metadata；
- build script path 与 native requirements；
- include/exclude/publish policy。

这些信息适合保留在一个小型静态 manifest 中。

`moon.pkg` 中则混合了多类不同信息：

1. 可以从目录和源码推导的事实：package name、sources、许多 imports。
2. 语言语义信息：package alias、test imports、virtual/implementation。
3. 输出产品信息：library/executable/foreign library。
4. backend 构建参数：JS format、Wasm exports、native compiler/linker flags。
5. 开发工具设置：formatter ignore、warnings、test concurrency。
6. build actions：native stubs、pre-build/dev_build。

这些东西不一定应该永久放在同一文件、同一抽象层。

特别是 imports：Moon 当前把 package import graph 放在 `moon.pkg`，而不是普通 source 中。这使 `moon.pkg` 成为每个 compilation package 几乎不可缺少的语义文件。Go 则从 source imports 和目录结构推导 package graph，所以一个 module 只需要根部 `go.mod`。

如果 MoonBit 长期希望降低 package 配置负担，可以考虑把 imports 逐步移入 source-level package declaration，例如：

```text
每个文件具有 file-local imports
或每个目录有一个属于 MoonBit 语言的 package.mbt/imports.mbt
```

这样 alias、test-only import 和实际使用位置更接近，unused dependency 也更容易由 compiler 判断。代价是这是语言和 compiler package model 的变化，不只是 MoonBuild 重构。

### 10.23 三种可能的总体模型

#### 模型 A：保留 moon.mod + moon.pkg + build.mbtx

这是兼容性最强的路线：

```text
moon.mod   module metadata/dependencies
moon.pkg   package/import/backend config
build.mbtx dynamic discovery/actions
```

优点是迁移成本低、静态可分析。缺点是配置面继续分散，而且开发者需要判断一个选项到底属于三个文件中的哪一个。若不主动缩减 `moon.pkg`，`build.mbtx` 很可能只是增加第四套概念，而不是解决复杂性。

#### 模型 B：最小 moon.mod + 可推导 package + 可选 build.mbtx

这是当前更推荐的长期方向：

```text
moon.mod
  只保存发布/解析所需静态事实

source tree
  目录形成 package；imports 尽量由 source/package declaration 提供

moon.pkg
  可选，只保留不能推导的 package override；长期可能重命名或合并

build.mbtx
  只在需要动态 target、native discovery 或 generated action 时出现
```

普通纯 MoonBit 项目可能只有：

```text
moon.mod
src/**/*.mbt
```

`llvm.mbt` 这类复杂 native module 才需要：

```text
moon.mod
build.mbtx
unsafe/wrap.c
src/**/*.mbt
```

这相当于采用 Go 的 package inference、Cargo 的静态发布 manifest，以及受控的 MoonBit build extension。

#### 模型 C：moon.mod 只保存 registry metadata，build.mbtx 定义完整 package/build graph

这是最接近 Zig 的路线：

```text
moon.mod    name/version/dependency source/checksum
build.mbtx  packages、targets、imports、actions、artifacts、install steps
```

表达力最高，能自然支持非标准目录、多 artifact 和复杂生成流程。代价是：IDE/package discovery 必须执行 build program，graph 可能随 host/environment 变化，安全、缓存和 deterministic query 都更难。

如果采用该路线，应要求 `build.mbtx` 在 graph declaration 阶段是近似纯函数：只读取 Moon 提供的 target/options，返回 DAG；真正 filesystem/process/network 操作只能作为声明的 action 节点，不能在 graph construction 时直接发生。

### 10.24 建议区分 graph declaration 与 configuration execution

即使使用同一个 `build.mbtx` 文件，也可以把 API 分成两个语义阶段：

```text
Graph declaration
  声明 package、target、artifact、source set 和 action dependency
  不允许 ambient I/O
  可被 IDE、moon query、dry-run 稳定执行

Configuration/action execution
  探测 llvm-config、读取显式 env、生成文件
  需要 capability
  结果进入 cache key
```

Zig 的重要经验不是“所有事情都在脚本里立即做”，而是 build program 构造 DAG，实际 command 作为 step 延后执行。若 Moon 未来允许 `build.mbtx` 定义更完整图，也应坚持这个区分。

### 10.25 对 1.0 的实际建议

1. 不在 1.0 前直接删除 `moon.mod` 或 `moon.pkg`，避免把 native dependency 议题扩大成一次全面项目模型重写。
2. 把 `moon.mod` 明确定义为不执行代码即可读取的 module/package-distribution manifest，并逐步缩小动态构建字段。
3. 将 `build.mbtx` 作为真正的可编程扩展，不再继续扩张 `.mod/.pkg` 专用 DSL 的动态能力。
4. 让没有特殊配置的目录能够自动成为 package，逐步增加省略空 `moon.pkg` 的能力。
5. 单独研究 package imports 是否能进入 MoonBit source/package declaration，这是决定 `moon.pkg` 能否最终消失的关键。
6. 先让 `moon.pkg` 从“package 存在的标记”变成“package 的可选 override”，再评估是否合并到 root manifest 或 `build.mbtx`。
7. `llvm.mbt` 可以先验证“最小静态 manifest + build.mbtx + native requirement”，但不应要求这一个项目立即决定所有普通 MoonBit package 的最终布局。

暂定判断：`build.mbtx` 不应完全替代 manifest，但它使当前两层 manifest 中动态、backend-specific 和 action-oriented 的部分显得更加不合理。MoonBit 1.0 应至少明确未来方向是“静态事实留在 manifest，计算交给 MoonBit”，而不是继续扩展一个看似 MoonBit、实际不可编程的配置 DSL。

### 10.26 暂定采用三层职责模型

当前讨论提出的折中方案是：保留 `moon.mod`、削弱后的 `moon.pkg` 和可选 `build.mbtx`，分别承担 module、package semantics 和动态构建配置。这是目前最适合作为 MoonBit 1.0 演进方向的方案。

建议的职责矩阵如下：

| 文件 | 权威职责 | 不应负责 |
|---|---|---|
| `moon.mod` | module identity、版本、source dependency、发布元数据、最低工具链版本、build script 声明、静态 native requirement | host 路径、SDK 探测、具体编译/链接命令 |
| `moon.pkg` | package imports/alias、package kind、virtual/override、静态 source/stub membership、test package 关系、稳定 package 属性 | 运行命令、读取环境、探测 SDK、生成绝对 link flags |
| `build.mbtx` | host/target 探测、system provider、生成任务、动态 native usage、显式环境和工具依赖 | 改变 module dependency graph、改变 package identity/kind、增加未声明 package import、修改 manifest |

这里的核心约束是：三者不通过覆盖优先级争夺同一字段。如果 `moon.pkg` 和 `build.mbtx` 都能设置 `is-main`、imports 或 package name，就会产生两个事实来源。更好的做法是让 build output schema 根本没有这些字段，脚本尝试改变稳定 package graph 时直接报错。

`is-main` 本身可以逐步由更清楚的 package kind 替代，例如 library、executable、foreign library。它属于 package 的稳定语义，应保留在 `moon.pkg`，因为 IDE、`moon run`、测试发现和发布工具都需要在不执行脚本时知道 package 产出类型。

### 10.27 不应把所有 link 信息都强制移入 build.mbtx

需要进一步区分静态声明和动态发现：

```text
静态声明：这个 package 需要链接系统库 m/z/Cocoa
动态发现：LLVM 实际 include/lib 路径、版本、system libs、static/shared mode
```

若简单的 `-lm` 也必须创建 `build.mbtx`，会让普通 FFI package 变得更重。因此可以保留结构化、可移植的静态 native usage declaration，例如：

```text
native.libs = [ "m" ]
native.frameworks = [ "Cocoa" ]
native.link_identity = "llvm"
native.version_requirement = ">=19.1,<20"
```

应移出 `moon.pkg` 的主要是：

- `/opt/homebrew/...` 绝对路径；
- `llvm-config`/`pkg-config` 探测结果；
- 依赖环境变量拼接的 flags；
- shell command；
- 动态生成的 include/search paths；
- provider-specific system libraries 和 link mode。

简单、封闭、可静态验证的 target condition 仍可保留为 declarative condition，例如 target OS/arch/backend；“执行程序后才知道”的 open-world condition 才进入 `build.mbtx`。

### 10.28 moon.pkg 建议保留的内容

第一阶段建议保留：

- package import path 与 alias；
- `for test`、`for wbtest` 等 test package imports；
- package kind；
- virtual package/override 等语言语义；
- supported backend/target 的静态约束；
- 静态 source set 与 `native-stub` membership；
- package-local warning/test policy；
- 简单结构化 native library requirement。

其中 formatter ignore、warning policy、test concurrency 是否长期属于 `moon.pkg`，可以以后单独整理；它们至少不应该进入 `build.mbtx`，因为这些不是动态构建计算。

`native-stub` 也不应完全移入脚本。一个仓库中已经存在的 `wrap.c` 是 package 的静态组成部分，IDE、watch 和 publish 都应提前知道。只有真正由 action 生成的 C source 才由 `build.mbtx` 声明其 generator、input 和 output。

### 10.29 build.mbtx 建议输出的内容

脚本输出应绑定到 `moon.pkg` 已经声明的 package ID，例如：

```text
BuildOutput
  rerun_if
  generated_actions
  package_configs: PackageId -> DynamicBuildConfig

DynamicBuildConfig
  compile.include_dirs
  compile.system_include_dirs
  compile.defines
  compile.args
  link.search_dirs
  link.items
  link.runtime_search_dirs
```

脚本只能配置自己 module 中已经存在的 package。它不能创建新的 source dependency，也不能给 package 增加未在 `moon.pkg` 声明的 MoonBit import。

动态结果不写回 `moon.pkg`。Moon 将其规范化后存入 `_build` 内部状态，并通过 `moon explain`/dry-run 展示。这样 working tree 不会因为不同机器上的 LLVM 路径而发生变化。

### 10.30 建议的解析与构建顺序

```text
1. 只读取 moon.mod，解析 module dependency graph
2. 读取所有 moon.pkg，得到稳定 package/import graph
3. 确定 host、target、profile 和 provider policy
4. 编译并执行各 module 的 build.mbtx
5. 验证脚本只返回允许的 DynamicBuildConfig/GeneratedAction
6. 解析或下载 native provider/artifact
7. 合并静态 package facts 与动态 native usage
8. 交给 Rupes Recta 构造和执行最终 graph
```

这个顺序有一个明显优势：执行任何第三方 build script 之前，Moon 已经知道完整的 Moon source/package graph。build script 无法通过动态增加依赖改变 resolver 的输入，因此 bootstrap 和安全模型都更简单。

合并时应尽量避免“脚本覆盖 manifest”。稳定字段只来自 manifest；动态字段只来自 build output。对于 link items 这种确实需要组合的序列，应设计明确、保序的结构化合并规则，而不是拼接两段字符串。

### 10.31 llvm.mbt 在该模型中的形态

```text
moon.mod
  module name/version/dependencies
  build = "build.mbtx"
  native requirement: LLVM >=19.1,<20

unsafe/moon.pkg
  MoonBit imports
  package kind = library
  native-stub = [ "wrap.c" ]

build.mbtx
  选择 system/artifact provider
  检查 llvm-config/version
  得到 include dirs、link dirs、libs、system libs
  向 unsafe package 输出 DynamicBuildConfig
```

其他 `IR`、`test`、`tutorial` package 的 imports 和 package kind 仍然静态可见。不同开发者机器上的 LLVM prefix 只存在于 build result，不进入任何 source manifest。

### 10.32 对这一方案的暂定评价

这个方案保留了 Moon 当前 package-level import 模型，因此不要求在 1.0 前同时修改 MoonBit source import 语义；又把当前最危险、最不灵活的 native path/flag 计算移入真正的 MoonBit build program。相较于完全 Zig 化，它对 resolver、IDE 和安全边界更友好；相较于只增加一个任意 prebuild hook，它又有足够的类型化和扩展空间。

主要风险是三份文件带来的认知负担。因此文档和 API 必须能用一句话解释：

> `moon.mod` 说明有哪些 module，`moon.pkg` 说明有哪些 package 以及它们 import 什么，`build.mbtx` 说明这些 package 在当前 host/target 上怎样获得额外构建输入。

只要某项配置无法按这句话唯一归类，就说明职责边界仍然需要调整。

### 10.33 build.mbtx 是动态配置贡献，不是文本追加

可以把 `build.mbtx` 理解为在语义上“补充 `moon.pkg`”，但实现不应把它的输出转换成文本后追加或重写 `moon.pkg`。建议的内部模型是：

```text
moon.pkg
  -> StaticPackageConfig

build.mbtx
  -> DynamicPackageContribution

validate_and_merge(static, dynamic)
  -> ResolvedPackageConfig

ResolvedPackageConfig
  -> Rupes Recta build plan/graph
```

`ResolvedPackageConfig` 只存在于内存和 `_build` 缓存中，不写回 source tree。这样可以：

- 保留每个值的来源；
- 针对 host/target/profile 分别缓存；
- 在 `moon explain` 中展示合并过程；
- 避免不同机器把不同绝对路径写进 manifest；
- 让 watch/IDE/build 共用相同规范化结果。

### 10.34 冲突应终止构建，但不建议交互式暂停

若存在不可合并冲突，应当立即使本次构建失败，并给出确定性诊断。不要在构建过程中等待用户交互选择，因为 CI、watch、IDE background check 和 remote build 都需要非交互行为。

理想诊断应包含：

```text
package
field/native identity
moon.pkg 提供的值和位置
build.mbtx 提供的值和调用位置
host/target/profile
为什么不能合并
可采用的修复或 override 位置
```

root workspace 的 provider override 应在运行 build script 前就确定，而不是发生冲突后临时询问用户。

### 10.35 不同字段需要不同 merge algebra

“追加”不能作为所有字段的统一规则。每类字段需要明确的合并语义：

1. **禁止动态修改**：package name、kind、imports、virtual identity、source dependency。`DynamicPackageContribution` 的类型中最好根本没有这些字段。
2. **单值唯一**：compiler family、native provider、static/shared mode 等。只有一方可提供；两方值不同则报错。
3. **keyed map**：defines、generated logical names。相同 key/相同 value 可以接受，相同 key/不同 value 报错。
4. **有序序列**：include dirs、library search dirs、link items。必须保序，不能简单 set union；header 搜索顺序和静态链接顺序会改变结果。
5. **集合型声明**：某些 capability、rerun inputs 可以去重合并。
6. **唯一输出**：两个 generated action 产生同一个 output path 必须报错，除非它们是完全相同、可证明等价的 action。

特别是链接配置，建议使用有序 `LinkItem`，而不是多个来源最后拼接字符串：

```text
LinkItem
  SearchPath(path)
  Library(name, kind, modifiers)
  Framework(name)
  Object(path)
  GroupStart/GroupEnd
  RawArg(arg)   // 最后的 escape hatch
```

raw args 无法被可靠地做语义冲突检查，因此应尽量缩小使用范围，同时保留 provenance 和明确插入位置。

### 10.36 对 llvm.mbt 的具体合并示例

```text
unsafe/moon.pkg -> StaticPackageConfig
  kind = library
  imports = [...]
  native_stubs = ["wrap.c"]
  native_requirement = LLVM >=19.1,<20

build.mbtx -> DynamicPackageContribution
  include_dirs = [resolved LLVM include]
  defines = [LLVM/C API required defines]
  link_search_dirs = [resolved LLVM lib]
  link_items = llvm-config 产生的有序 libraries/system libraries
  rerun_if_env = [LLVM_CONFIG, PATH]
  tool_fingerprint = resolved llvm-config/version

merge -> ResolvedPackageConfig
  保留全部静态 package 语义
  注入当前 target 的 LLVM usage
```

以下情况应失败：

- `moon.pkg` 要求 LLVM 19，脚本发现 LLVM 18/20；
- root policy 选择 artifact provider，脚本又尝试注入 system provider；
- 同一个 define 被配置为不同值；
- 两个 provider 同时声明 `link_identity = llvm`；
- 生成任务覆盖 `wrap.c` 或其他 source 文件；
- 脚本试图配置不存在或不属于当前 module 的 package。

重复 include path 或同值 define 未必是冲突，可以在规范化阶段去重；但去重必须尊重原有顺序和语义。

### 10.37 暂定术语

为了避免把实现理解成修改 manifest，建议使用以下术语：

```text
StaticPackageConfig       moon.pkg 的解析结果
BuildContribution         build.mbtx 的输出
ResolvedPackageConfig     校验、解析 provider 并合并后的最终配置
```

因此更准确的原则是：

> `build.mbtx` 不追加 `moon.pkg` 文件；它向已经由 `moon.pkg` 定义的 package 提交动态构建贡献。Moon 验证并合并贡献，冲突则以确定性错误终止，成功后由合并结果驱动构建图。

## 11. LLVM 接口对齐：先建立可判定的反馈系统

### 11.1 问题不只是“接口没有写完”

MoonBit 类型检查通过，只能说明 MoonBit 一侧的声明和调用彼此一致。它不能证明以下几件事：

1. extern 指向的 C symbol 在目标 LLVM 版本中存在；
2. MoonBit 声明经过 native backend lowering 后与 C ABI 一致；
3. C wrapper 调用了正确的 LLVM API，并正确转换了参数、返回值和 out parameter；
4. LLVM API 的成功/失败约定、nullability 和 ownership 被正确解释；
5. 未被当前程序使用的 extern 也仍然有效。

普通构建中的 DCE 本身不是错误。编译器没有必要为了未使用的 extern 产生 relocation。但 binding 项目不能把普通应用构建当成完整性验证：这会使未使用声明永久处于“既没证明正确，也没证明错误”的状态。

因此这里需要的第一个工程不是继续补接口，而是建立一个 **binding conformance harness**。它给人和 AI 提供外部 oracle，使接口错误能够变成确定的、可复现的失败。

### 11.2 当前代码中的三个不同层次的反例

本机 `llvm-config` 当前解析到 LLVM 18.1.8。其头文件明确给出：

```c
typedef int LLVMBool;

/* Returns 0 on success. */
LLVMBool LLVMParseBitcode2(LLVMMemoryBufferRef MemBuf,
                           LLVMModuleRef *OutModule);
```

而 `unsafe/BitReader.mbt` 当前是：

```moonbit
extern "C" fn __llvm_parse_bitcode2(
  membuf : LLVMMemoryBufferRef,
  out_mod : Ref[LLVMModuleRef],
) -> Bool = "LLVMParseBitcode2"

match result {
  true => Some(out_mod.val)
  false => None
}
```

这里至少存在两个需要分别验证的问题：

- MoonBit `Bool` 与 C `int` 在当前 native backend 上是否具有受支持的 FFI ABI 对应关系；
- 即使 ABI 恰好可调用，代码也把非零失败解释为成功，语义已经反转。

`unsafe/IRReader.mbt` 的问题又不同。它把接口绑定为自定义 symbol `__llvm_parse_ir_in_context`，但当前 `unsafe/wrap.c` 中没有这个定义。只有某条可达路径引用它时，最终链接才会失败；DCE 会在其他构建中隐藏这个缺失。

`unsafe/Types.mbt` 还明确记录了：

```text
LLVMJITSymbolTargetFlags 在 LLVM 中是 uint8_t，当前 MoonBit 包装使用 UInt
```

这属于类型宽度/表示问题。它可能在按值传参、struct layout 或 callback 中造成真实 ABI 错误，也可能在某个 ABI 上暂时“看起来能工作”。不能靠运行一个 happy-path 测试来证明它正确。

此外，`env.sh` 当前给 C 编译参数加入了 `-w`。这会关闭 C 编译器本来能够提供的一部分接口反馈，与生产级 binding 的目标相反。

这几个例子说明“binding 正确”至少分为四层：

```text
symbol 存在
  -> ABI 一致
    -> 适配语义正确
      -> ownership/lifetime 正确
```

上一层通过，不能推出下一层通过。

### 11.3 LLVM 18 头文件应成为版本化 source of truth

对当前阶段，source of truth 不应是仓库里的注释、AI 对 LLVM API 的记忆，或者某个在线最新版本文档，而应是这次构建实际选择的 LLVM 18 SDK：

```text
llvm-config --version
llvm-config --includedir
目标 triple
头文件内容或 SDK fingerprint
```

应使用 Clang AST/libclang 读取 `llvm-c/*.h`，而不是用正则表达式解析 C。需要抽取的至少包括：

- function name 和 canonical function type；
- typedef 展开后的整数宽度和 signedness；
- opaque pointer、普通 pointer、pointer-to-pointer；
- enum 常量和值；
- callback function type 和 calling convention；
- struct/union layout；
- 所属 header、deprecated 标记和可用条件。

LLVM C API 相较于 C++ API 已经相当适合做这件事。困难不在“能否解析头文件”，而在于如何把 C ABI 信息与 MoonBit compiler 实际 lowering 后的 ABI 信息对齐。

### 11.4 不要求所有 LLVM 接口都暴露，但要求每个接口都被分类

“生产可用”不一定等于 LLVM 18 所有 C API 在第一版中都有 MoonBit 高层封装。平台专属、deprecated、实验性或本项目暂不支持的接口可以不绑定。但不能让它们处于无记录的缺失状态。

建议维护一个机器生成、人工补充语义的 binding manifest。每项至少记录：

```text
LLVM header / version
C symbol
canonical C signature
MoonBit extern name 和 link name
MoonBit lowered FFI signature
binding kind: direct | shim | unsupported | deprecated
failure convention
nullability
ownership / borrowed / consumed
对应的 link test、semantic test 和 lifetime test
```

可以把需要对账的集合粗略表示为：

```text
H = LLVM 18 头文件中选择范围内的 API
M = MoonBit extern 的 link targets
W = 本项目 C shim 导出的 symbols
L = 被全量链接检查覆盖的 extern
S = 被语义测试覆盖的 public binding
```

审计器至少应报告：

- `H` 中没有被绑定或明确标成 unsupported/deprecated 的接口；
- `M` 中既不属于 LLVM 18、也不存在于 `W` 的错误 link name；
- `W` 中没有任何 MoonBit consumer 的废弃或未完成 wrapper；
- `M - L`：会被 DCE 隐藏、尚未经过强制链接检查的 extern；
- public API 中缺少 semantic/ownership test 的接口。

因此，“C 里声明了但是 MoonBit 没调用”不应一律算 bug。它可能是未支持的 LLVM API，也可能是已经废弃的项目 shim。真正的问题是它现在没有明确分类，工具无法区分“有意不支持”和“遗漏”。

### 11.5 raw FFI 与 MoonBit 友好 API 应分层

建议把接口明确拆成两层：

```text
LLVM 18 C ABI
  -> raw FFI：精确、机械、尽量可生成
    -> safe/idiomatic MoonBit API：Option/Result/String/对象方法/生命周期策略
```

raw FFI 层的目标不是好用，而是能与 C header 一一核对。它不应为了 MoonBit 便利直接把多个 out parameter 猜测成 tuple，也不应把 `LLVMBool` 无条件写成 MoonBit `Bool`。例如 `LLVMParseBitcode2` 的 raw 层应保留“C int status + out module”的形态，高层再把 `status == 0` 转成成功结果。

需要 C shim 的典型情况包括：

- MoonBit FFI 不能直接安全表示的 out parameter 或多返回值；
- callback、userdata 和生命周期桥接；
- `char **`、owned message 和 destructor 配对；
- by-value struct/union 或平台相关整数；
- 需要把 LLVM 的 0-success 统一规范化为显式 result 的接口；
- C API 本身缺失、必须调用 LLVM C++ API 的扩展。

有两种合理策略：

1. 所有 extern 都只绑定项目自有的 `mbt_llvm_*` shim。边界统一、最容易验证，但 wrapper 数量更多；
2. ABI 完全平凡的接口直接绑定 LLVM，只有高风险接口使用 shim。代码少，但分类器和审计器必须足够可靠。

对 llvm.mbt 更实际的方案是第二种，但 direct/shim 必须由 manifest 明确决定，不能由开发者或 AI 临时猜测。LLVM 操作通常足够重，薄 shim 的调用开销不是主要风险；真正的风险是大量手写 shim 自身发生漂移。因此 shim 最好从同一个 schema 生成，或至少由生成的 header 约束。

### 11.6 C compiler 能检查 shim，但前提是不给它蒙眼

项目自有 wrapper 应有一份生成或严格维护的 `wrap.h`。`wrap.c` 必须 include 它，并直接 include 自己所使用 API 的 LLVM header。建议单独建立严格检查配置：

```text
-Wall
-Wextra
-Werror
-Wmissing-prototypes
-Wstrict-prototypes
-Wconversion（可以分阶段启用）
```

这样 C wrapper 定义和声明不一致、隐式声明、错误参数类型等问题会在编译期出现。正常第三方 header 的告警可以通过 `-isystem` 或有针对性的诊断控制隔离，不应全局使用 `-w`。

但 C compiler 只能比较 `wrap.c` 与 C header。它仍然看不到 MoonBit extern 最终如何 lowering。因此 raw FFI 的 MoonBit 端和 C header 最好来自同一份 IR/schema；退一步，也必须让 Moon compiler 导出可供比较的 ABI metadata。

### 11.7 必须有独立于 DCE 的全量 link audit

不能通过“真的调用所有 LLVM 函数”来迫使它们参与链接：很多函数需要复杂有效状态，随便调用会崩溃或破坏资源。这应该拆成两种测试：

1. **address/link test**：只为每个 extern 产生保留的 symbol relocation，不执行函数；
2. **behavior test**：用合法输入执行接口并验证结果。

短期内，可以由 manifest 生成 C anchor object：为每个函数生成正确类型、带 `used`/`retain` 属性的 function pointer，使链接器必须解析每个 symbol。再将 LLVM library 和 `wrap.o` 以禁止 unresolved symbol 的方式做一次专用链接。

更理想的 MoonBit 能力是：

```text
moon ffi check --all-externs --target native
```

它直接读取编译器掌握的所有 extern，而不是只读取优化后的可达调用，并生成用于审计的 undefined references。这样 release DCE 的语义完全不需要改变，但 binding author 获得一条不会被 DCE 绕过的验证路径。

只用 `nm` 检查名字仍然不够，因为 symbol table 不携带完整 C function prototype。全量 link audit 负责发现“没有这个 symbol”；Clang AST 与 Moon ABI metadata 的比较负责发现“名字存在但签名错了”。

### 11.8 运行测试需要不同的 oracle

自动验证可以按成本和证明能力分层：

| 层级 | 检查 | 能发现的问题 |
|---|---|---|
| 0 | inventory diff | 漏接口、旧接口、版本漂移、未分类接口 |
| 1 | ABI/schema check | 宽度、指针层级、返回方式、callback/struct ABI |
| 2 | all-symbol link audit | 拼写错误、缺失 shim、错误 LLVM 版本 |
| 3 | minimal behavior test | 成功/失败约定、out parameter、基本转换错误 |
| 4 | semantic/round-trip test | wrapper 组合后是否保持 LLVM 语义 |
| 5 | ASan/LSan/UBSan test | 泄漏、double free、use-after-free、越界和部分 ABI 错误 |

高价值的语义 oracle 不必全是手写 expected value。可以使用：

- C reference program 与 MoonBit binding 对同一输入的差分测试；
- IR `parse -> print -> parse -> verify`；
- bitcode `write -> parse -> verify`；
- target machine `emit -> LLVM/toolchain 再读取`；
- 对失败输入验证 message、status、null output 和释放行为；
- 对 transfer ownership 的接口验证成功与失败两条路径。

snapshot 适合验证稳定文本结果，但指针地址、目标平台输出或诊断全文不一定适合直接 snapshot。这里更重要的是不变量和资源状态。

### 11.9 如何给 AI 建立有效反馈

如果只给 AI 一份 `LLVM-C.h` 和一批 MoonBit 文件，让它“补全 binding”，它很可能会生成表面相似但无法证实的代码，尤其容易错在：

- 拼错 symbol 或绑定到另一 LLVM 版本；
- 把 `LLVMBool` 当语言 `Bool`；
- 猜错 unsigned/size_t/enum 宽度；
- 把 out parameter 猜成不兼容的 tuple ABI；
- 忽略 ownership 或把 0-success 理解反；
- 只让当前测试使用到的路径链接成功。

有效的 AI 工作单元应类似：

```text
API family: BitReader
exact LLVM header and version: ...
generated canonical C signature: ...
current Moon lowered signature: ...
failure: ABI mismatch / missing shim / unresolved symbol / semantic test
ownership note: ...
one deterministic verification command: ...
```

AI 每次处理一个 API family，完成后必须重新生成 manifest/diff 并通过相应层级的检查。AI 的价值在于机械扩展声明、wrapper、测试和文档，以及根据具体失败迭代；正确性来源于 compiler、Clang、linker、sanitizer 和语义 oracle，而不是模型自信。

### 11.10 对 MoonBit 自身的直接反馈

不现实也没有必要让 MoonBit 类型系统“理解全部 C”。更合适的方向是让 MoonBit 提供一个可机器检查的 FFI contract。

编译器或标准工具链应优先提供：

1. **lowered ABI metadata**：导出每个 extern 的 link name、calling convention、参数/返回值的 size、alignment、signedness、pointer depth 和 pass mode，例如 `moon info --ffi-json`；
2. **header conformance check**：用 Clang 解析 C header，并与 compiler lowering 后的 ABI 比较，而不是只比较 MoonBit 源码表面类型；
3. **all-extern link mode**：不受 reachability/DCE 影响地验证所有选定 extern symbol；
4. **明确的 C ABI 类型**：例如 C `int`、`unsigned`、`size_t`、`uint8_t`、opaque pointer、C callback 等，不让用户依赖 `Int`/`UInt`/`Bool` 的偶然表示；
5. **可表达的 FFI 属性**：nullable、borrowed、owned、consumed、out、callback userdata 和对应 destructor。这些属性第一阶段可以用于 lint、文档和代码生成，不必立即进入完整的静态生命周期证明；
6. **sanitizer 与 native test 集成**：让 ASan/LSan/UBSan 成为 `moon test` 的稳定 profile，而不是项目各自拼 flags；
7. **生成任务依赖追踪**：把 LLVM header、版本和 target 作为生成 manifest 的输入，与前面讨论的 `build.mbtx`/构建缓存模型衔接。

其中第 1、3、4 项必须由 compiler/toolchain 定义，因为只有编译器知道 MoonBit 类型最终怎样传给 native ABI。Clang AST 解析、LLVM-specific ownership annotation 和高层 wrapper 生成则可以先在项目工具中实现，成熟后再考虑标准化。

MoonBit 还应把以下两件事明确区分：

```text
普通应用构建：只要求 reachable extern 能链接，允许 DCE
FFI conformance build：要求选定 scope 内所有 extern 都能通过 ABI 和链接审计
```

这比为 binding 特殊关闭 DCE 更干净，也适用于数据库、GUI、系统库等其他 native bindings。

### 11.11 对 llvm.mbt 的建议落地顺序

在假定 LLVM 版本固定为 18 后，建议按以下顺序推进，而不是立即补全 API：

1. 冻结 LLVM 18.1.x header/source fingerprint，生成第一份 API inventory；
2. 让所有现有 extern 进入不受 DCE 影响的 symbol audit，先清掉拼写和缺失 shim；
3. 定义 MoonBit native FFI ABI mapping，并从 compiler 取得或补充可比较的 lowering metadata；
4. 对现有 extern 做全量 signature diff，优先处理整数宽度、Bool、out parameter、tuple、callback 和 by-value struct；
5. 建立 raw FFI / idiomatic API 分层，修复成功状态、nullability 和 ownership；
6. 按 LLVM API family 增加 behavior、round-trip 和 sanitizer tests；
7. 最后才按 manifest 中的 unsupported 清单逐批扩充接口覆盖面。

这一阶段可以采用以下生产门槛：

- 范围内每个 LLVM 18 C API 都已绑定或有明确 unsupported/deprecated 记录；
- 每个 extern 的 link name 都经过不受 DCE 影响的验证；
- 每个 raw FFI signature 都由机器与 C header 核对，或由同一 schema 生成；
- 每个非平凡 adapter 都有成功、失败和 ownership 测试；
- C wrapper 在严格 warning 配置下通过；
- native sanitizer suite 没有已知泄漏或内存错误。

核心判断是：

> 接口完整性不是靠“代码看起来像 LLVM header”保证的，而是靠一条可重复的证据链保证的。先让工具能够可靠地说出 binding 错在哪里，之后人和 AI 才有条件规模化地把它补全。

## 12. `moon ffi check` 的详细设计

### 12.1 先限定它承诺证明什么

`moon ffi check` 应是一个不执行 foreign function 的静态/链接一致性检查命令。它的核心承诺可以限定为：

1. 当前 target 下所有选中范围内的 `extern "C"` 都使用了 MoonBit 支持的 FFI carrier；
2. MoonBit 声明的 C-boundary contract 与指定 C header 中的声明兼容；
3. C stub 中项目自有 wrapper 的定义与 MoonBit 所期待的声明兼容；
4. 所有 extern link name 在最终链接环境中都能解析，而且该检查不受 DCE 影响。

它不应宣称自动证明：

- `0` 或非零哪个表示成功；
- 返回的 pointer 是否 nullable；
- 谁负责 free，应该调用哪个 destructor；
- C 是否在调用返回后继续保存某个 borrowed pointer；
- 函数虽然签名相同，内部是否调用了正确 API；
- callback 的重入、线程和异步 lifetime 是否正确。

后面这些属于 semantic/ownership contract，需要注解、binding schema 和运行测试。把命令边界说清楚很重要，否则 `ffi check passed` 容易被误解成“binding 已经正确”。

### 12.2 当前编译器已经具备大部分 MoonBit 侧信息

检查当前 `ideas7` compiler 源码后，可以看到 native pipeline 已经有以下结构：

- `machine_of_clam_lower.ml` 的 `logical_func_sig_of_stub_external` 从 extern 的参数和返回类型构造 `Machine.logical_func_sig`；
- 同一文件的 boundary-plan construction 为 `extern "C"` 注册 external symbol 和 external signature；
- `machine_legalize.ml` 调用 `Machine_abi_classify.classify_external_sig`，按 target ABI 分类 extern signature；
- `machine_value_layout.ml` 已经知道 MoonBit value 的 size、alignment、scalar/aggregate shape；
- `Core_DCE` 会根据可达性删除未使用的 private stub。

因此，不应让 `moon` 自己重新解析 `.mbt` 并猜测 MoonBit 类型。合理的分工是：

```text
moonc
  负责：源类型、extern symbol、ownership attrs、value layout、target ABI lowering

moon
  负责：package scope、build configuration、C toolchain、header、stub、library、缓存和诊断聚合

C compiler / linker
  负责：C 类型兼容性、目标平台 C ABI 和 symbol resolution
```

用户命令叫 `moon ffi check`，但底层需要一个类似 `moonc --emit-ffi-contract` 的内部接口。

### 12.3 必须同时导出 source contract 和 lowered ABI

当前 MachineIR 会把多种源类型归约到相同物理形状，例如：

```text
Bool -> W32
Int  -> W32
UInt -> W32
#external type -> Ptr
```

如果只导出 lowered ABI，那么下面这些声明可能都只显示为 `(i32) -> i32` 或 `(ptr) -> ptr`：

```text
C int           vs C unsigned
C int           vs MoonBit Bool
LLVMModuleRef   vs LLVMContextRef
```

它们可能具有相同的寄存器/栈传递形状，但 source-level contract 并不相同。错误的 opaque handle 类型尤其危险：ABI 完全相同，调用时却会把 context 当作 module。

因此报告至少需要三层表示：

```text
Moon source type
  Bool / UInt / LLVMModuleRef / Ref[LLVMModuleRef]

foreign contract type
  CBool / CUInt / c_type("LLVMModuleRef") / pointer-to(c_type(...))

target ABI shape
  i32 / ptr / aggregate(size, align, fields) / indirect / sret / calling convention
```

检查结果也应区分：

1. **exact contract match**：C 类型和 ABI 都匹配；
2. **ABI-compatible but contract-different**：物理上可能工作，但 signedness、Bool value domain、opaque type 或 qualifier 不同；
3. **ABI-incompatible**：宽度、pointer depth、aggregate layout、return convention 或 calling convention 不同。

生产级 raw binding 默认应要求第 1 类。第 2 类即使允许，也必须有显式 escape hatch 和理由；更推荐使用 shim 消除差异。

### 12.4 `moonc` 应输出怎样的 FFI contract

以下 JSON 只用于说明信息模型，不代表最终序列化格式：

```json
{
  "schema_version": 1,
  "compiler_version": "...",
  "backend": "native",
  "target_triple": "arm64-apple-darwin",
  "data_layout": "...",
  "package": ".../unsafe",
  "externs": [
    {
      "moon_name": "__llvm_parse_bitcode2",
      "link_name": "LLVMParseBitcode2",
      "source": "unsafe/BitReader.mbt:25",
      "visibility": "private",
      "active_cfg": true,
      "params": [
        {
          "moon_type": "LLVMMemoryBufferRef",
          "foreign_type": "LLVMOpaqueMemoryBuffer*",
          "abi": { "kind": "pointer", "size": 8, "align": 8 }
        },
        {
          "moon_type": "Ref[LLVMModuleRef]",
          "foreign_type": "LLVMOpaqueModule**",
          "abi": { "kind": "pointer", "size": 8, "align": 8 }
        }
      ],
      "return": {
        "moon_type": "Bool",
        "foreign_type": "int32_t (current generated-C mapping)",
        "abi": { "kind": "i32" }
      },
      "attrs": {
        "borrow": ["out_mod"]
      }
    }
  ]
}
```

关键要求是：extern inventory 必须在 target-specific cfg 和类型检查之后、DCE 之前收集。这样：

- 不会把其他 backend 的 extern 错算进来；
- private、从未调用的 extern 仍会进入报告；
- 不需要通过关闭所有优化来间接保留它们；
- 报告可以保留精确 source location。

ABI 部分仍应调用 production code path 中真实的 layout/lowering/classifier，而不是在 exporter 中复制一套规则。否则 checker 和 compiler 可能一起漂移。

### 12.5 checker 怎样知道对应哪个 C header/type

当前 `extern "C"` 只提供 link name，`#external type` 也没有记录它对应哪个 C typedef。这足够链接，但不足以检查 nominal C contract。

长期需要两类声明性 metadata：

```moonbit
// 仅为设计示意，不是确定语法
#external(c_type = "LLVMModuleRef")
pub type LLVMModuleRef

#ffi(header = "llvm-c/BitReader.h")
extern "C" fn ... = "LLVMParseBitcode2"
```

header 也可以按 package 声明一个集合，只有 symbol 重名或需要特殊 header 时才逐函数标注。建议的职责划分是：

- source declaration 记录稳定的 nominal mapping，例如 Moon type 对应哪个 C typedef；
- `moon.pkg` 或其他静态 package 描述只记录需要纳入检查的 header 名称；
- `build.mbtx` 提供当前 target 的 include dirs、defines、sysroot 和 C compiler；
- 不在源码或 manifest 中写宿主机绝对路径。

不建议再创建一份手工重复所有函数签名的大型 sidecar 文件。否则 `.mbt`、sidecar 和 C header 会变成三个可能漂移的事实来源。

对于 binding generator，生成 `.mbt` 和必要 metadata 是合理的；生成结果仍由 `moon ffi check` 独立验证。

### 12.6 通用 checker 不一定必须依赖 libclang

“枚举 LLVM 18 全部 API”需要 Clang AST，因为它要主动读取和理解整个 header surface。但“验证某个已知 symbol 的 MoonBit 声明”可以有更轻的实现。

`moonc` 可以为每个 extern 生成一个 C witness：

```c
#include <llvm-c/BitReader.h>

typedef int32_t (*mbt_expected_LLVMParseBitcode2)(
  LLVMMemoryBufferRef,
  LLVMModuleRef *
);

static mbt_expected_LLVMParseBitcode2 const mbt_check_LLVMParseBitcode2 =
  &LLVMParseBitcode2;
```

在严格诊断模式下：

- header 没声明这个 identifier，会编译失败；
- function pointer type 不兼容，会编译失败；
- calling convention 不兼容，会编译失败；
- mapped opaque type 或 pointer depth 不一致，会编译失败。

对于 mapped struct/value type，还可以生成：

```c
_Static_assert(sizeof(SomeCType) == MOON_EXPECTED_SIZE, "size mismatch");
_Static_assert(_Alignof(SomeCType) == MOON_EXPECTED_ALIGN, "align mismatch");
_Static_assert(offsetof(SomeCType, field) == MOON_EXPECTED_OFFSET, "offset mismatch");
```

这种方案复用构建时已经选定的 C compiler，不要求所有用户额外安装 Node、Python 或 libclang。GCC、Clang、MSVC 的 witness 细节可以由 toolchain abstraction 处理。

不过，libclang/Clang AST 仍然适合以下增强功能：

- 生成完整 API inventory；
- 显示 canonical C type diff，而不只转发 compiler diagnostic；
- 提取 enum value、deprecated、availability 和 source location；
- 生成 binding skeleton；
- 检查 C wrapper 内部调用了哪个 LLVM function。

因此建议分层：

```text
通用 moon ffi check：compiler metadata + C witness + linker
llvm.mbt inventory/audit：Clang AST + LLVM-specific schema
```

MoonBit 不必因为核心 checker 而立即捆绑一整套 Clang frontend。

### 12.7 项目自有 C shim 怎样检查

对于 `__llvm_*` 这类项目自有 symbol，系统 header 中不会有声明。checker 可以根据 MoonBit contract 生成：

```text
_build/.../ffi/moon_ffi_expected.h
```

然后在专用检查构建中强制让 `wrap.c` include 该 header。只要 wrapper 的定义签名与 MoonBit 期待值不同，C compiler 就会诊断 conflicting types。

理想情况下项目仍然维护或生成正常的 `wrap.h`，让 `wrap.c` 自己 include；generated expected header 再检查 `wrap.h`。但即使旧项目没有 header，forced include 也能成为迁移手段。

检查 C stub 时应使用严格 flags，而不是继承当前 `env.sh` 的 `-w`：

```text
warnings as errors
missing prototype
strict prototype
incompatible function pointer
implicit declaration
return type / parameter conversion
```

`static` C helper 不属于 MoonBit binding surface；非 `static` 且没有 consumer 的定义可以作为 `unbound C export` warning，帮助清理 `wrap.c`，但不应默认把所有内部 helper 当成错误。

### 12.8 怎样绕过 DCE 做全量 symbol 检查

`ffi check` 应让 `moonc` 额外生成一个 anchor object。概念上，它为每个 extern 保存一个不会被优化器或链接器删除的、正确类型的函数地址引用：

```c
__attribute__((used))
static expected_fn_type const anchor = &foreign_symbol;
```

实际实现可以直接在 native object/MachineIR 中生成 relocation，不必真的生成 C。关键是：

- inventory 来自 DCE 前；
- anchor 产生真实 undefined symbol reference；
- anchor 永远不执行函数；
- 专用 link action 使用与实际项目相同的 libraries、search paths、frameworks、CRT 和 target；
- unresolved symbol 必须导致失败。

这样 `__llvm_parse_ir_in_context` 会在 `ffi check` 中稳定失败，而不依赖测试是否碰巧调用它。

不能简单使用 `nm` 代替：`nm` 能确认名字存在，却不能确认 function prototype。也不能靠关闭 DCE 后执行程序：未调用的函数仍可能不产生所需 relocation，而且强行调用 foreign API 不安全。

### 12.9 对 archive、动态库和交叉编译的处理

link audit 必须复用 `ResolvedPackageConfig`，而不是另起一套 link flags。否则检查通过的环境可能与实际构建不同。

需要考虑：

- static archive 只有被引用的 member 才会被拉入；anchor 正好提供所需引用；
- macOS/Linux/Windows 对 unresolved symbol 和 import library 的规则不同，应由 toolchain 实现；
- cross compilation 时可以做 header、layout 和 target link check，但不能默认运行 behavior test；
- `size_t`、`long`、enum layout 和 calling convention 必须按 target triple/sysroot 解析，不能按 host；
- weak/optional/dlsym symbol 不能假装成普通 `extern "C"`，未来应有不同 resolver kind 或显式 metadata；
- SDK version、header fingerprint、defines 和 target 必须进入缓存 key。

所以 `ffi check` 是 build graph 的一组专用 actions，而不是运行一个与构建系统无关的脚本。

### 12.10 建议的 build graph 节点

在 Rupes Recta 模型中，可以概念性增加：

```text
EmitFfiContract(package, target)
  输入：typed package、target、compiler ABI version
  输出：package.ffi-contract

GenerateFfiWitness(package, target)
  输入：ffi-contract、header mapping、ResolvedPackageConfig
  输出：ffi_witness.c / expected_stub.h / ffi_anchor.o plan

CompileFfiWitness(package, target)
  输入：witness、headers、include dirs、defines、sysroot
  输出：witness.o 或结构化诊断

CheckCStubContract(package, target)
  输入：C stubs、expected_stub.h、严格 C flags
  输出：checked stub objects

LinkFfiAnchor(scope, target)
  输入：anchor、checked stubs、实际 link items
  输出：link success 或 unresolved symbols

WriteFfiReport(scope, target)
  输出：human diagnostics + JSON/SARIF
```

这些节点都有明确输入输出，适合缓存、watch mode 和 IDE 调用。`moon explain` 也应该能展示某个 header/include/link item 是从哪里进入 checker 的。

### 12.11 命令行体验

第一版可以很小：

```text
moon ffi check --target native
moon ffi check --target native -p unsafe
moon ffi check --target native --emit-report _build/ffi/report.json
```

建议的默认行为：

- 只检查 workspace/local module 中当前 target 激活的 extern；
- 包含 private 和 unused extern；
- 做 declaration/witness check、C stub contract check 和 link audit；
- 不运行 foreign function；
- dependency 是否递归审计由 `--deps` 显式开启；
- 没有 header mapping 的 direct extern 至少做 carrier validation 和 link audit，并提示 `header contract unchecked`；
- 有 ABI-compatible-but-not-exact 项时默认失败或至少在 strict mode 失败。

可以提供检查层级，但不建议让用户记很多独立命令：

```text
--declarations-only
--no-link
--strict
--deps
--format human|json|sarif
```

普通 `moon check` 不应立即隐式运行完整 FFI audit，因为它会引入 C SDK、header 和 linker 成本。项目可以在 CI 中显式执行 `moon ffi check`；未来对配置过 FFI contract 的 package，`moon check` 可以运行便宜的 carrier validation。

### 12.12 诊断应该展示两个世界

以 `LLVMParseBitcode2` 为例，当前 C backend 会把 function position 中的 `Bool` 与其他 `I32` 一样生成成 `int32_t`。在 `int32_t` canonical 为 C `int` 的 target 上，它与 `LLVMBool` 的物理 ABI 可以完全兼容。因此好的报告不应错误地宣称这里存在 binary ABI mismatch，而应区分 ABI 与值域语义：

```text
note[ffi-semantic-contract-unchecked]: C integer result is exposed as MoonBit Bool
  --> unsafe/BitReader.mbt:25

  MoonBit declaration:  Bool
  generated-C carrier:  int32_t
  direct-native shape:  i32 on arm64-apple-darwin
  C declaration:        LLVMBool, canonical type int (i32)

  ABI check: passed on this target
  value-domain contract: C may return any int; Moon API presents Bool
  status convention: unknown to the generic checker

  help: bind the raw result as CInt/LLVMBool and convert `status == 0`
```

`moon ffi check` 不能从函数类型知道“0 表示成功”，也不能只因两个值都按 i32 传递就宣称高层包装正确。这里的 help 可以来自 LLVM-specific schema；通用 checker 最多指出 C integer 与 language Bool 的值域不同，或者在 strict raw-FFI policy 下禁止这种直接映射。

缺失 shim 的诊断则应是：

```text
error[ffi-unresolved-symbol]: `__llvm_parse_ir_in_context` cannot be resolved
  declared at unsafe/IRReader.mbt:23
  selected target: arm64-apple-darwin
  searched inputs: libLLVM..., unsafe/wrap.o, ...
  note: declaration was included by all-extern audit even though it is unreachable
```

这种诊断正是 AI 所需的反馈：准确位置、实际 lowering、C 端事实和一条确定的失败原因。

### 12.13 FFI carrier 应成为有规范的语言表面

当前允许普通 MoonBit 类型出现在 `extern "C"` 中，会让“语言内部表示”和“稳定 foreign contract”混在一起。长期建议定义一组 compiler-known C ABI carrier，例如概念上的：

```text
CInt / CUInt
CLong / CULong
CSize / CPtrDiff
CInt8 / CUInt8 / ...
CPtr[T] / CNullablePtr[T]
CFunction[Sig, CallingConvention]
C opaque typedef mapping
```

这不等于要求用户高层 API 使用这些类型。它们主要存在于 raw FFI 层：

```text
LLVM raw: CInt status
Moon API: Result[Module, ParseError]
```

`Int`、`UInt`、`Bool` 是否允许直接用作 extern carrier，应由 MoonBit FFI spec 明确，而不是由当前 backend 表示偶然决定。尤其需要回答：

- `Bool` 对应 C `_Bool`、`uint8_t`、`int32_t`，还是只保证某种调用 ABI；
- `Int` 是否固定等于 `int32_t`，是否允许对应 C `int`；
- `#external` 是否只表示 `void *` ABI，怎样记录 nominal C typedef；
- `Ref[T]` 在什么条件下可被解释为 `T *`，它是否暴露 Moon heap layout；
- by-value struct/enum 是否属于稳定 C ABI surface；
- closure/FuncRef 需要什么 thunk 和 userdata contract。

`moon ffi check` 会迫使这些原本隐含的问题变成规范，因为 checker 不可能验证一个没有定义的 contract。

### 12.14 ownership metadata 与 `ffi check` 的关系

MoonBit 当前的 `#borrow`/`#owned` 主要用于控制 MoonBit value 穿过 extern call 时的引用计数行为。LLVM 文档中的 ownership transfer 则描述 foreign resource 本身，例如 memory buffer 在成功时被 module 接管。这是两个相关但不相同的层次。

第一版 `ffi check` 可以做到：

- 验证 `#borrow/#owned/consume` 只用于适合的 carrier；
- 把这些属性写入 contract/report；
- 若 LLVM-specific schema 有 `takes_ownership_on_success` 等信息，检查 raw declaration 是否有相应适配策略；
- 提示缺少 destructor/ownership annotation。

但它不能仅从普通 C header 自动推断 ownership。LLVM header comment 可以帮助生成候选 metadata，最终仍需 binding maintainer 确认，并通过成功/失败两条路径测试。

这也说明 `moon ffi check` 与前面讨论的 affine resource 是互补关系：

```text
ffi check 证明“调用边界形状正确”
affine/Drop 证明“进入 MoonBit 后资源责任不会随意复制或遗失”
semantic/sanitizer tests 证明“实际适配策略符合 LLVM 行为”
```

### 12.15 分阶段实现建议

不建议第一版就实现完整 Clang importer。可以分为：

#### Phase 0：compiler visibility

- 在 DCE 前枚举当前 target 的所有 extern；
- 导出 source location、Moon type、link name 和现有 ownership attrs；
- 暴露 compiler 实际的 logical/layout/ABI 信息；
- 先用 llvm.mbt 检查报告是否足够解释现有问题。

#### Phase 1：all-symbol audit

- 生成 anchor object；
- 复用实际 `ResolvedPackageConfig` 链接；
- 发现拼写错误、缺失 shim、错误 library/version；
- 这一阶段已经能解决 DCE 隐藏问题，价值最高且实现相对独立。

#### Phase 2：C witness

- 定义第一批稳定 FFI carriers；
- 支持 header set 和 opaque C type mapping；
- 生成 function-pointer witness、layout assertions 和 expected stub header；
- 对 scalar、opaque pointer、pointer-to-pointer、简单 callback 做 exact check。

#### Phase 3：复杂 ABI 与 diagnostics

- by-value aggregate、enum、calling convention、callback thunk；
- exact/ABI-compatible/incompatible 分类；
- JSON/SARIF、IDE integration；
- compiler ABI differential tests，以 Clang 作为 target ABI oracle。

#### Phase 4：binding schema integration

- ownership/nullability/status metadata；
- generator 和 audit 共用 schema；
- LLVM API inventory diff；
- AI 可消费的结构化 task/report。

这里最值得先做的是 Phase 0 + Phase 1。即使还没有任何 C type mapping，它们也能让全部 extern 可见，并把当前大量被 DCE 隐藏的 missing symbol 变成稳定错误。随后再逐步提高“签名正确”的证明强度。

### 12.16 暂定结论

`moon ffi check` 不应该是“扫描 `.mbt`，然后拿 `nm` 看一下名字”的外围脚本。它应建立在 compiler 自己的 FFI lowering 信息上，并进入 Moon build graph，使用同一 target、同一 C toolchain 和同一 link configuration。

同时，它也不应承担 LLVM binding generator 的全部职责。合理边界是：

> MoonBit toolchain 证明一个已经声明的 extern 在当前 target 上具有明确、可核对、可链接的 foreign contract；llvm.mbt 的专用工具证明 LLVM 18 API surface 是否完整，并补充 LLVM 特有的状态、ownership 和行为语义。

这样既能解决当前 llvm.mbt 的反馈缺失，也能把能力推广到 SQLite、libuv、GUI toolkit 等所有 native bindings。

## 13. C backend 对 `moon ffi check` 设计的影响

### 13.1 结论：显著简化，但不能单独作为最终 oracle

MoonBit 已有 C backend，使上一节的设计可以更直接：编译器不必重新发明一套“Moon type 到 C type”的打印逻辑。当前 C backend 已经会：

- 从 extern 的 `params_ty`/`return_ty` 收集 foreign imports；
- 将 `I32` 家族生成成 `int32_t`，`U32` 生成成 `uint32_t`；
- 将 `#external` 生成成 `void *`；
- 生成 callback function pointer、Moon runtime pointer/value type；
- 为收集到的 C symbol 输出 prototype；
- 对 Moon `Unit` 等边界差异生成 adapter wrapper。

因此 C backend 本身已经包含一份事实上的 Moon-to-C boundary mapping。`moon ffi check` 的 C witness 最初完全可以从这条路径生成，而不是另写一份类型转换器。

但“用 C backend 把项目编译一次，能过就算 FFI 正确”仍然不成立。它最多证明 generated-C realization 的 C 输出能与 C compiler 协作，不能自动证明 direct native/LLVM backend 使用了同一 ABI，也不能解决 DCE、分离 translation unit 和语义/ownership 问题。

### 13.2 当前 C backend 已经生成 extern prototype

在当前 compiler 中，C backend 对 `Fn_stub` 的处理会把 C symbol 和 `(params_ty, return_ty)` 放入 `global_ctx.imports`，最后生成类似：

```c
extern int32_t LLVMParseBitcode2(void *arg0, void *arg1);
```

真实输出会根据 Moon type translation 决定具体 C type。这里有两个可直接复用的能力：

1. generated prototype 可以成为 `--emit-ffi-header` 的原型；
2. generated C translation unit 可以通过 forced include 引入第三方 header，使 C compiler 对重复声明做兼容性检查。

例如在检查构建中加入：

```c
#include <llvm-c/BitReader.h>
// 后面是 C backend 生成的 LLVMParseBitcode2 declaration/call
```

如果 return、参数个数、pointer depth 或 calling convention 不兼容，C compiler 会直接报告 conflicting declaration 或 incompatible function pointer。

不过当前 `#external` 只被生成成 `void *`，已经丢失 `LLVMModuleRef`/`LLVMContextRef` 的 nominal 区别。若直接把 `void *` prototype 与 LLVM opaque struct pointer prototype 做 C type exact comparison，会产生大量“ABI 兼容但 C nominal type 不同”的结果。因此上一节提出的 `c_type = "LLVMModuleRef"` mapping 仍然必要；C backend 的存在不能凭空恢复已经擦除的信息。

### 13.3 更好的编译器内部结构：共享 `Foreign_sig`

不建议把 C backend 实现本身永久指定为其他 backend 的规范。更稳妥的重构是把 foreign boundary 抽成 backend-independent IR：

```text
Typed extern declaration
  -> Foreign_sig
       source types
       foreign carriers
       ownership attrs
       calling convention
       nominal C type mapping
       logical return convention
          │
          ├── C backend: print C prototype/call/wrapper
          ├── direct native: target ABI classification + call lowering
          ├── LLVM backend: LLVM function type + ABI attrs
          └── ffi check: header witness + expected-stub header + report
```

这样 source of truth 是共享的 `Foreign_sig`，而不是：

```text
C backend 自己解释一次 Ltype
Machine backend 再解释一次 Ltype
LLVM backend 再解释一次 Ltype
ffi checker 第四次解释 Ltype
```

当前 C backend 的 `Transl_type_c.transl_type` 可以作为建立 `Foreign_sig -> C type` 的起点；Machine backend 已有的 logical/storage/ABI signature 则用于 `Foreign_sig -> target ABI`。两条路径应共享前半部分，并在 compiler tests 中做一致性验证。

### 13.4 generated C 可以承担两种角色

#### 角色一：可读的 foreign contract

`moonc --emit-ffi-header` 可以直接复用 C backend 的 declarator/printer，产生：

```c
// generated, target-specific
extern int32_t some_symbol(...);
```

这比只给 JSON 中的 `i32/ptr` 更容易让 C maintainer 审查，也可以被 C stub、IDE 和外部 build system 使用。

#### 角色二：C compiler witness

checker 可以生成一个不包含 MoonBit 业务代码的最小 C translation unit，只包含：

- 第三方 headers；
- MoonBit 期待的 foreign types；
- function pointer compatibility assignments；
- `sizeof/_Alignof/offsetof` assertions；
- symbol address anchors。

这比把完整 generated-C program 当 witness 更稳定：完整程序会受 DCE、runtime implementation 和普通代码生成变化干扰；最小 witness 只表达 FFI contract。

### 13.5 为什么不能只运行 generated-C build

至少有五个缺口：

1. **DCE**：当前 C backend 只会为最终保留下来的 `Fn_stub` 收集 import。未使用 private extern 仍不会出现，必须在 DCE 前单独收集。
2. **分离 translation unit**：generated C 和 `wrap.c` 分别编译时，C compiler 不会跨 translation unit 比较 prototype 与 definition；仍需 generated expected header/forced include。
3. **linker 不检查类型**：即使两个 translation unit 对同一 symbol 使用不同 prototype，链接器通常只看 symbol name。
4. **direct backend 可能漂移**：generated C 把平台 ABI 委托给 C compiler，direct backend 自己做 ABI classification；前者通过不能证明后者正确。
5. **语义仍然不可见**：C 编译成功无法发现 `LLVMParseBitcode2` 的 0-success 被反向解释。

因此 C backend 改善的是“怎样表达和验证 C contract”，没有取消 all-extern audit、backend parity test 和 semantic test。

### 13.6 当前 `native` surface 下存在多个 realization

当前 `moon` 源码中，用户可见的 `--target native` 内部可能选择：

```text
GeneratedC
TccRun
DirectObject(AArch64/X86_64/...)
```

在当前 arm64 macOS debug 路径中，环境条件允许时会默认选择 direct-object；其他 profile/host 可能回退 generated C 或 TCC。也就是说，同一个 package 的 `target="native"` 源文件可能由不同 backend realization 执行。

这对 MoonBit 1.0 的 FFI contract 是一个重要问题：

> `extern "C"` 的 ABI 必须由 target/toolchain contract 定义，而不能由当前碰巧选择的 native realization 定义。

否则可能出现：

```text
debug/direct-object 失败
release/generated-C 成功
或反过来
```

短期内，`moon ffi check` 的报告必须显示：

```text
surface target
native realization
target triple
C compiler/toolchain family
ABI contract version
```

CI 可以有内部选项分别验证 generated-C 和 direct-object。长期更理想的是 compiler 保证所有 native realization 实现同一个 `Foreign_sig` contract，普通用户不需要知道它们的差异。

### 13.7 C backend 是 direct backend 的差分 oracle

C compiler 已经实现了 AAPCS64、SysV AMD64、Windows x64 等复杂 ABI。generated-C backend 将 struct 参数、return、callback 等交给 C compiler，是非常有价值的参考实现。

compiler test suite 可以自动生成大量 FFI signature：

```text
scalar widths/signedness
opaque pointers/pointer-to-pointer
small/large structs
mixed int/float aggregates
HFA
register exhaustion + stack parameters
sret/byval
callbacks
```

同一组 C probe 分别与：

- generated-C backend；
- direct native backend；
- LLVM backend；

互调并比较参数与返回值。host target 可以实际运行；cross target 可以比较 generated ABI descriptors、object relocation 和 Clang lowering。这样 llvm.mbt 中发现的问题能够沉淀为 compiler-wide ABI conformance tests，而不是只在一个 binding 中修补。

这类差分测试比项目级 `ffi check` 更适合发现“Moon direct backend 的 ABI classifier 自身实现错了”。项目级 checker通常应信任 compiler；compiler CI 负责证明各 backend 满足共同 FFI contract。

### 13.8 对上一节方案的修正

C backend 的存在使推荐实现顺序调整为：

1. 从 DCE 前的 typed extern 建立共享 `Foreign_sig`；
2. 从现有 C backend 类型转换抽出 `Foreign_sig -> C prototype/header`；
3. 生成包含全部 extern 的 target-specific FFI header，而不是依赖完整程序 C 输出；
4. 用第三方 header + function pointer witness 验证已有声明；
5. 用 expected header 严格编译 C stubs；
6. 生成 anchor object 做全量 link audit；
7. 在 compiler CI 中用 C backend/C compiler 差分验证 direct native 和 LLVM backend；
8. 由 LLVM-specific schema/tests补齐 status、ownership 和行为语义。

因此，C backend 不只是“对讨论有影响”，它实际上给了 `moon ffi check` 一个很好的 bootstrap 路径。最需要避免的是把它误用成唯一 oracle：

> C backend 应帮助定义和打印共享 foreign contract，并作为 direct backend 的参考实现；`ffi check` 最终验证的仍应是用户实际选择 target 下的共同 FFI contract，而不是“某次 generated-C build 恰好能编译”。

## 14. 暂无完整资源类型时，llvm.mbt 的最低资源管理标准

### 14.1 基本判断：可以先达到“可信 C binding”，不必等待完整 ownership system

MoonBit 短期没有 affine/linear resource、lifetime 或完整 borrow checking，不代表 llvm.mbt 必须停止生产化。C API 本身也没有这些静态保证；大量生产 C/C++ 代码依靠明确约定、结构化 wrapper、作用域清理和 sanitizer 运行。

但需要诚实区分两种承诺：

```text
unsafe/raw 层
  C-like safety：用户必须遵守 ownership contract；误用可以泄漏、double-free 或 UAF

推荐高层层
  leak-resistant / dynamically checked：普通使用不泄漏，重复 close 和 moved handle 可检测
  但不宣称具有静态 lifetime/ownership safety
```

因此当前阶段的生产目标不应写成“MoonBit 类型系统证明所有 LLVM 资源安全”，而应写成：

> binding 自身不产生已知泄漏；所有资源责任都有可审计契约；推荐 API 在正常用法和错误路径上释放正确；raw 层的危险被清楚隔离；常见 double-free、use-after-close 和 conditional transfer 至少有动态防线。

### 14.2 当前 runtime finalizer 的真实能力

当前 `~/.moon/lib/runtime.c` 中，`moonbit_make_external_object(finalize, payload_size)` 会：

1. 分配一个参与 MoonBit RC 的普通对象；
2. 让返回指针直接指向不透明 payload；
3. 把 C finalizer function pointer 存在 payload 之后；
4. RC drop 路径识别 external object；
5. 调用 `finalize(payload)`，然后释放外层对象。

需要特别注意：

- payload 不参与 MoonBit child-reference scanning，不能在其中隐藏 MoonBit `Context`、closure 或其他需要 RC 的值；
- finalizer 必须写在 C 中，当前不能自然携带 MoonBit closure；
- finalizer 不应释放 external-object 容器本身，runtime 会负责；
- raw LLVM `#external` type 在 native backend 中是非 RC scalar，不能直接得到 external-object finalization；
- 要使用这套能力，应创建一个普通 opaque MoonBit type，例如概念上的 `type NativeOwner`，其 C 表示由 `moonbit_make_external_object` 分配，而不是把 `#external LLVMModuleRef` 本身变成 finalizable。

当前实现通常会在 RC 归零路径调用 finalizer，但库层不应依赖确切时机和顺序：引用环、程序异常终止、未来 runtime 改动都可能使 finalization 延迟或不发生。finalizer 应被视为泄漏兜底，而不是业务所依赖的确定性 `Drop`。

### 14.3 当前代码说明仅靠“让用户 defer”还不够

目前 `unsafe/wrap.c` 的 `moonbit_str_to_c_str` 每次 `malloc`，而仓库中约有 170 处调用。`c_str_to_moonbit_str*` 中的 `free(ptr)` 被注释掉；与此同时，部分输入字符串需要 `free`，部分 LLVM 输出必须使用 `LLVMDisposeMessage`，还有部分字符串只是 borrowed、根本不能释放。

例如：

- `llvm_module_create_with_name` 创建 input C string 后没有释放；
- `llvm_print_module_to_string` 把 LLVM-owned message 复制成 Moon String 后没有调用 `LLVMDisposeMessage`；
- `llvm_get_diag_info_description` 文档写明需要 dispose，但实现只复制字符串；
- `CStr::free` 固定调用 libc `free`，无法表达 `LLVMDisposeMessage`、`LLVMDisposeErrorMessage` 或 borrowed pointer 的区别。

高层 `IR` package 目前也只有 `Context::drop` 这类零散的手动释放入口；`Module`、`IRBuilder`、`Interpreter`、`GenericValue` 等没有形成一致策略。`Module::getContext` 还会把 borrowed context raw ref 包装成与 owning `Context::new()` 相同的类型，调用者无法知道该不该 dispose。

这些属于 binding 自身的内部泄漏/所有权混淆，不能归咎于用户没有写 `defer`。生产门槛应先要求 library wrapper 自己把临时资源清理干净。

### 14.4 第一项非协商要求：建立 ownership ledger

在没有语言类型支持时，先维护一份机器可读或至少结构化的 ownership ledger。每个 raw API 的每个资源参数/返回值必须属于下列之一：

```text
Owned(disposer)
Borrowed(parent)
Immortal/Global
ConsumedAlways
ConsumedOnSuccess(success_predicate)
OwnedBuffer(disposer, length_rule)
BorrowedBuffer(parent, length_rule)
ErrorObject(consume/get-message protocol)
```

例如：

```text
LLVMModuleCreateWithNameInContext
  context: Borrowed
  return: Owned(LLVMDisposeModule)

LLVMGetModuleContext
  module: Borrowed
  return: Borrowed(module/context lifetime), never dispose independently

LLVMGetBitcodeModuleInContext2
  membuf: ConsumedOnSuccess(status == 0)
  out module: Owned on success

LLVMGetErrorMessage
  error: ConsumedAlways
  return: OwnedBuffer(LLVMDisposeErrorMessage)
```

ledger 初期可以人工维护，因为 LLVM ownership 大量存在于 header comments，而不在 C type 中。以后它可以成为 binding generator、文档、lint 和测试生成器的输入。

接口没被正确分类时，不应进入推荐高层 API；可以暂时只留在 `unsafe` 或标成 unsupported/experimental。

### 14.5 raw 层的最低标准

`unsafe` package 可以继续暴露 C-like raw handle 和显式 disposer，但至少必须满足：

1. 每个返回 owned handle 的接口都有可用且测试过的对应 dispose/consume 路径；
2. 每个 raw API 文档明确写 `Owned`、`Borrowed from X`、`Consumes X always/on success`；
3. raw 层不做会隐藏 ownership 的便利转换，例如把所有 `char *` 都折叠成同一种 `CStr`；
4. binding 内部创建的临时 buffer/string 在 wrapper 返回前清理；
5. error path 与 success path 都释放各自应释放的对象；
6. deprecated/ownership 不明确的接口不进入高层层；
7. 示例统一使用 `defer`，而不是只在注释里说“记得 dispose”。

这能达到与设计良好的 C binding 类似的可信度：库不替用户保证所有权，但不误导用户，也不在便利 API 内部泄漏。

### 14.6 推荐高层层：C-backed dynamic owner box

对常用、真正 owned、destructor 简单的 LLVM handle，可以在 C 中实现一个小型 owner box：

```c
struct mbt_llvm_owner {
  void *handle;
  void (*dispose_adapter)(void *handle);
  enum { OPEN, CLOSED, MOVED } state;
};
```

该 struct 作为 `moonbit_make_external_object` 的 payload。`dispose_adapter` 必须是真正签名为 `void(void *)` 的项目 shim，再由 shim 强类型调用 LLVM disposer；不应直接通过不兼容函数指针类型调用 LLVM API。

C 层提供概念上的操作：

```text
owner_new(handle, disposer)
owner_borrow_checked() -> raw handle or closed/moved error
owner_close()          -> dispose once, set handle = null, state = CLOSED
owner_take()           -> return raw handle, set handle = null, state = MOVED
owner_finalize()       -> if OPEN, dispose; otherwise no-op
```

MoonBit 侧用普通 opaque managed type保存 box：

```moonbit
// 仅为形状示意
type NativeOwner

priv struct Module {
  owner : NativeOwner
  context : Context
}
```

这样即使 `Module` 或 `Context` 被复制/别名化，所有别名仍共享同一个 owner state：

- 第一次 `close()` 真正释放；
- 第二次 `close()` 返回 AlreadyClosed 或安全 no-op；
- finalizer 看到 CLOSED/MOVED 不再释放；
- transfer 成功后所有旧别名都看到 MOVED；
- 方法在取 raw handle 时能把 use-after-close 变成明确诊断，而不是访问悬垂指针。

这不是静态 ownership，也不是 `unique_ptr`；它更接近“带 tombstone 的共享 control block”。但在缺少 affine type 时，它能以较小实现成本消除最危险的一批 double-free/UAF。

高频 builder 操作可能担心每次 checked unwrap 的开销。可以先测量，再决定某些内部 hot path 是否使用受作用域保护的 raw borrow；不应在没有数据时用潜在 UAF 换微小优化。

### 14.7 parent lifetime 用 MoonBit 字段保活，不放进 C payload

derived/borrowed LLVM refs 的 owner 通常是 Context、Module、ExecutionEngine 或 ORC session。推荐 wrapper 应沿 child-to-parent 方向保存 keepalive：

```text
Type / context-owned metadata -> Context owner
Module                        -> Context owner
Value / Function / Block      -> Module owner（或按真实 LLVM 规则保守选择 owner）
Builder                       -> Context owner
ExecutionEngine               -> Context owner + 自己的 owner box
```

parent wrapper 必须放在普通 MoonBit struct 字段中，使 MoonBit RC 看得见。C external-object payload 只保存 C handle、状态和 C function pointer。

依赖方向应保持单向 DAG：child 持有 parent，parent 不缓存 child。这样 library 自身不会建立引用环，最后一个 child 消失后 parent 才有机会 finalization。

显式 `parent.close()` 仍可能在 child 存活时被调用；没有 affine/lifetime 类型无法静态禁止。动态 owner state 至少使 child 的下一次操作报告 parent closed，而不是静默 UAF。推荐 API 文档仍应规定 close 前必须结束 derived handles 的使用。

### 14.8 conditional ownership transfer 必须集中处理

LLVM 中最危险的不是普通 create/dispose，而是：

```text
调用成功则消费参数
调用失败则调用者仍拥有参数
```

例如 LLVM 18 的 `LLVMGetBitcodeModuleInContext2` 明确只在成功时接管 memory buffer；ORC 中也有大量 builder/module 只在某些调用成功后转移所有权的接口。

这种状态不能只写在文档中，然后期待每个调用者手工决定是否 dispose。推荐高层 wrapper 应把 foreign call 与 owner state transition 放在同一个 C shim/受控函数里：

```text
读取 OPEN handle
调用 LLVM
若 success：把输入 owner 标为 MOVED
若 failure：输入 owner 保持 OPEN
构造输出 owner 或 Error
```

旧 alias 虽然仍存在，但共享 control block 已变为 MOVED，不能再次 dispose 或调用。这是一种动态 move，可以作为未来语言级 `consume` 的过渡实现和行为参考。

对 Module 被 ExecutionEngine/ORC 接管之类的操作，可以保守规定：transfer 后所有旧 Module/Value wrapper 均失效。即使 LLVM 实际上允许某些引用继续使用，保守失效也比无法证明的悬垂引用安全。

### 14.9 `CStr` 应优先拆掉，而不是给它加一个模糊 finalizer

单一 `CStr` 无法表达至少四种完全不同的资源：

```text
TempCString
  Moon String 转换而来，调用结束后 libc free

OwnedLLVMMessage
  LLVM 返回，复制后 LLVMDisposeMessage

OwnedLLVMErrorMessage
  LLVMGetErrorMessage 返回，复制后 LLVMDisposeErrorMessage

BorrowedCString/BorrowedBytes
  由 Context/Module/Remark 等 owner 持有，复制但绝不能 free
```

最低标准是不要让 public/high-level API 暴露这些临时 pointer。建议提供小而明确的内部 helper：

```text
with_temp_c_string(String, fn(CStr) -> T)
copy_and_dispose_llvm_message(CStr) -> String
copy_and_dispose_error_message(CStr) -> String
copy_borrowed_c_string(CStr, length?) -> String
```

`with_temp_c_string` 内部使用 `defer free`；owned-output helper 在复制完成后立即调用正确 disposer。更稳妥时可把“复制 + 对应 dispose”整个放在 C shim 中，使 raw pointer 根本不进入 MoonBit 用户代码。

不能把 `free`、`LLVMDisposeMessage` 和 `LLVMDisposeErrorMessage` 当作可互换实现，即使某一 LLVM 版本内部碰巧都落到 libc allocator。binding 必须遵守 API contract，而不是依赖实现细节。

修复字符串是资源管理第一优先级：它们数量大、生命周期短、释放规则清楚，并且当前每次普通建 IR/打印 IR 都可能泄漏。

### 14.10 哪些资源适合 finalizer

可以按 destructor 特征分类：

| 类型 | 显式 close | finalizer 兜底 |
|---|---|---|
| destructor 为 `void`、同步、无 thread affinity | 必须提供 | 推荐 |
| destructor 返回 error，例如 `LLVMOrcDisposeLLJIT` | 必须返回/处理 error | 可 best-effort，但必须 consume 产生的 error，不能再泄漏 |
| 必须在特定线程/事件循环释放 | 必须 | 暂不直接 finalizer；需要清理队列后再支持 |
| borrowed handle | 禁止 | 禁止 |
| immortal/global handle | 禁止 | 禁止 |
| conditional-transfer input | 由受控 transfer 更新状态 | owner state 为 MOVED 后 no-op |

finalizer 中不应：

- 调用可能 raise/await 的 MoonBit 逻辑；
- 访问已经死亡的 MoonBit parent；
- 依赖执行顺序；
- 把释放失败静默转换成另一个未消费的 `LLVMErrorRef`；
- 做长时间阻塞或线程敏感操作。

ORC/callback/JIT 类资源比 Context/Module/Builder 复杂得多，可以先只保留在 explicit/unsafe 层，等清理队列和 callback lifetime 有设计后再进入 managed API。

### 14.11 `defer` 是确定性主路径，finalizer 是后备路径

推荐文档和 doctest 应统一展示：

```moonbit
let ctx = Context::new()
defer ctx.close()

let mod = ctx.create_module("demo")
defer mod.close()
```

同时可以提供 scope helper：

```text
with_context(fn(Context) -> T) -> T
with_module(Context, String, fn(Module) -> T) -> T
```

helper 内部始终 `defer close`，减少用户忘记清理的概率。由于 closure 仍可能保存/返回 wrapper，它不能提供静态 non-escape 保证；文档必须如实说明。但对于普通直线型构建 IR 代码，它能显著改善 ergonomics 和异常路径清理。

推荐的优先级是：

```text
显式 close/defer：确定性、能报告错误
scope helper：封装常见 defer pattern
finalizer：用户忘记 close 时的泄漏兜底
```

不要把 finalizer 当作鼓励用户省略 close 的理由，尤其是 JIT、large Module、MemoryBuffer 等可能占用大量资源的对象。

### 14.12 测试不只依赖 LSan

建议在 test-only C shim 中为 owner wrapper 增加 live counters：

```text
contexts_created / contexts_disposed
modules_created / modules_disposed / modules_moved
messages_created / messages_disposed
buffers_created / buffers_disposed / buffers_moved
```

每个 API family 至少测试：

- 正常 close 后 live count 归零；
- 重复 close 不会二次 dispose；
- 忘记 close 的简单无环对象最终可由 finalizer 兜底（不把精确时机写进公共契约）；
- parent 的局部变量消失但 child 仍存活时，parent 不会提前 dispose；
- parent 被显式 close 后，child 操作产生确定诊断而不是崩溃；
- conditional transfer 成功时 source 变 MOVED；
- conditional transfer 失败时 source 仍 OPEN；
- error/message 的每一条分支都消费并释放；
- 大量 String 输入和 IR print 循环没有线性增长。

然后在 Linux CI 上运行 ASan/LSan/UBSan。live counters 能指出逻辑上是哪类对象漏了；sanitizer 能发现 wrapper 未覆盖的真实 heap 错误，两者互补。

finalizer 测试不能替代显式清理测试。进程结束、引用环或仍在 root 中的对象可能使 finalizer 不运行；生产测试应首先证明所有推荐示例在显式 close 路径上零泄漏。

### 14.13 分阶段落地

#### M0：可信 raw C binding，生产化的最低底线

- 完成 ownership ledger；
- 补齐所有已支持 owned handle 的 disposer/consumer；
- 拆分 C string/message/buffer 的不同释放协议；
- wrapper 自己创建的临时资源全部用 `defer` 或 C shim 清理；
- success/failure/conditional-transfer 都有测试；
- `unsafe` 文档明确 manual ownership；
- sanitizer 下常规测试零已知 leak/UAF/double-free。

这一级别可以诚实地称为生产可用的 unsafe C binding，类似不使用 smart pointer 的 C/C++ API。

#### M1：常用 API 的 managed facade

- 为 Context、Module、Builder、MemoryBuffer、TargetData/TargetMachine、PassManager 等简单 owner 建 C external-object owner box；
- 提供幂等或返回状态的 `close()`；
- finalizer 作为兜底；
- derived refs 持有 parent owner；
- 方法统一 checked unwrap；
- 提供 `with_*` scope helpers；
- conditional transfer 使用动态 MOVED state。

这一级别可作为普通用户的推荐入口，但应描述为 dynamically managed，而不是静态 memory-safe。

#### M2：复杂资源延后

- ORC/JIT error-returning disposal；
- callback root/unroot；
- async/thread-bound cleanup；
- parent-bound borrow 的静态表达；
- affine resource/consume/Drop。

M2 不应阻塞 M0/M1。复杂接口可以继续留在 `unsafe` 或 experimental surface。

### 14.14 当前阶段的生产判定

在没有语言级 resource type 的前提下，llvm.mbt 至少应满足：

- 推荐 API 的普通示例在显式 `defer close` 下没有已知泄漏；
- binding 内部临时 C string、LLVM message 和 error object 永不要求用户替库擦屁股；
- raw API 的每个 owned/borrowed/consumed 关系都有明确记录；
- owning 与 borrowed wrapper 不再使用相同、容易误 dispose 的高层类型；
- 所有 ownership-transfer 接口有成功/失败状态测试；
- 常用 owner 有 idempotent/dynamically checked close，最好有 finalizer fallback；
- derived wrapper 保活 parent，library 自身不创建 wrapper RC cycle；
- sanitizer suite 零已知 leak、double-free、UAF；
- 暂时无法可靠管理的 ORC/callback API 不伪装成安全高层接口。

这是一条现实的中间线：它达不到 Rust ownership 或 C++ smart pointer 的静态保证，但明显高于“裸 pointer + 注释 + 希望用户记得 free”，也能为 MoonBit 后续 affine resource 设计提供真实迁移样本。

## 15. 允许用 MoonBit 编写 finalizer：收益、边界与 runtime 代价

### 15.1 先区分确定性 `Drop` 与不确定性 finalizer

“析构函数”在当前讨论中容易指向两种语义，必须分开命名：

- `Drop`：编译器依据 affine resource 的所有权数据流，在正常返回、`raise`、`break`、`continue` 等受管理控制流出口确定性插入；
- finalizer：对象因 RC 归零或未来 GC 判定不可达后，由 runtime 尝试调用的兜底回调。

前者不依赖宿主 GC 发出对象回收通知，原则上可以由所有后端实现；后者依赖 runtime/宿主能否观察对象回收。finalizer 的公共契约应刻意保持很弱：

```text
不保证调用时机；
不保证调用顺序；
甚至不保证一定调用；
若调用，则对该 registration 至多调用一次，且 payload 在调用期间有效。
```

因此 WasmGC 无法获得回收信号，并不从逻辑上否定 finalizer API；若契约允许 `maybe never`，该后端永不调用也没有违反语义。但这会造成真实的平台相关泄漏风险，不能只从形式上的语义一致性判断产品设计。

对于 llvm.mbt 这类本来就只在 Native 使用的 C binding，建议第一步提供 target-gated 的 Native 能力，而不是把它伪装成所有后端都能可靠工作的通用析构语义：

```text
#cfg(target="native")
Finalizable[T]
```

不支持的后端直接报告 capability 不可用，比允许编译后仅给一个容易被忽略的 warning 更清楚。未来 JS 可以评估映射到 `FinalizationRegistry` 的弱语义实现；WasmGC 在没有宿主回收通知时可以继续不提供。若将来确实需要一个跨后端、允许 no-op 的弱 finalization API，应使用与确定性 resource cleanup 明显不同的名字和文档。

### 15.2 对 llvm.mbt 的直接收益

允许 MoonBit closure 执行 finalization，会显著降低 binding 的工程复杂度。目前要实现 managed owner，C 侧需要承担：

- external-object payload 布局；
- `OPEN` / `CLOSED` / `MOVED` 状态转换；
- 每种 LLVM disposer 的 C adapter；
- 显式 close、checked borrow、transfer 和 finalizer 的配套入口；
- debug counter 与诊断。

若 runtime 提供一次通用的 `Finalizable[T]` 地基，大部分策略可以回到 MoonBit：

```moonbit
// 概念 API，不是当前语法承诺。
let owner = Finalizable::new(
  OwnerState::open(raw_context),
  fn(state) {
    match state.take_if_open() {
      Some(raw) => LLVMContextDispose(raw)
      None => ()
    }
  },
)
```

显式 `close` 与 finalizer 操作同一个 `OwnerState`，从而保证只有一条路径取得实际 handle 并执行释放。这样可以：

- 减少 `unsafe/wrap.c` 中按类型重复的 finalizer 和状态机代码；
- 让 disposer 选择、错误消费、debug 日志和 live counter 留在 MoonBit；
- 让 binding generator 更容易生成 owner wrapper；
- 让 cleanup 逻辑出现在 MoonBit 类型检查、文档和测试可见的范围内；
- 让 `moon ffi check` 更容易把资源的创建、转移与释放联系起来。

这是一项实质性的 ergonomics 改善，不只是把同样数量的代码从 C 翻译到 MoonBit。但它改善的是“怎样实现已经决定好的清理协议”，并不会自动回答：

- 一个 LLVM 返回值究竟是 owned 还是 borrowed；
- disposer 应是 `free`、`LLVMDisposeMessage` 还是其他函数；
- ownership 是否只在调用成功后转移；
- Module、Value、Builder 对 Context/Module 的 lifetime 依赖；
- mutation 后哪些 view 已经失效；
- callback、线程和 runtime shutdown 协议。

ownership ledger、FFI checker、sanitizer 和人工审计仍然是必要条件。

### 15.3 `FuncRef` 使第一版实现简单很多

MoonBit 现有 `FuncRef[T]` 不是普通 closure。编译器要求其函数体 capture-free，并在 Native C/LLVM lowering 中把它表示为匹配签名的原始函数指针。`FuncRef[(...) -> Unit]` 的 Native 返回 ABI 也是 `void`，现有 Native FFI 测试已经支持把它传给 C，再由 C 直接回调。

这意味着第一版 MoonBit-written finalizer 不一定需要保存可扫描 closure environment。可以把 finalizer 限定为：

```moonbit
FuncRef[(FinalizerPayload) -> Unit]
```

只要参数和返回的 Native ABI 与 runtime 的 `void (*)(void *)` 精确匹配，当前 external object尾部保存的就仍然是一个普通函数指针。由此可以直接消除：

- closure environment 的扫描与 root/unroot；
- per-instance capture 的额外分配；
- closure 捕获 wrapper 形成的直接 RC 环；
- finalizer closure 在 pending queue中的环境保活问题。

2026-07-20 的最小 Native 实验已经验证：C shim把 MoonBit `FuncRef[(ExternalObject) -> Unit]` 原样传给 `moonbit_make_external_object`，RC 归零后当前 runtime可以直接进入 MoonBit函数；该函数还能读取 external payload并调用 `println`。因此“用 MoonBit写一个 capture-free finalizer”在当前 Native ABI上已经基本可行，不必先实现通用 closure finalization。

实验同时暴露了执行时机问题。没有显式 keep-alive 时：

```text
MoonBit finalizer: 42
MoonBit body: 42
after scope
```

源码中的 body 行使用 `object.content()` 构造插值字符串。RC last-use在取得 content 后立刻释放 object，于是 finalizer在外层 `println` 尚未执行时重入。加入后续 `object |> ignore` 后，输出变成：

```text
MoonBit body: 42
MoonBit finalizer: 42
after scope
```

这说明 `FuncRef` 已经解决“runtime怎样跳进 MoonBit函数”，但没有解决“任意 last release 点是否适合执行 MoonBit用户代码”。safe-point queue、重入契约和显式 keep-alive/borrow边界仍然需要设计。

`FuncRef` 路线也仍有约束：

- finalizer不能捕获每个实例的 MoonBit环境，所需状态必须进入 payload、全局表或其他显式参数；
- 当前 external payload仍是不扫描 MoonBit引用的不透明字节，因此 payload不能未经 root协议保存普通 MoonBit对象；
- `FuncRef` 函数虽然 capture-free，函数体仍可访问全局、分配、调用其他 MoonBit函数、panic或重入 C；
- function pointer签名必须与 runtime callback ABI严格一致，泛型 `T` 不能不经 layout/ABI约束随意传入；
- finalizer function通过 registration value进入程序时通常对 DCE可见，但编译器和 linker测试仍应保证间接调用目标不会被删除。

因此建议把最小实现分成两步：先支持 Native-only、capture-free、固定 payload ABI 的 `FuncRef` finalizer；只有真实 binding证明需要 per-instance capture后，再设计普通 closure的扫描、rooting和队列保活。

### 15.4 当前 external object 不能直接保存普通 MoonBit closure

当前 Native runtime 的 external object：

1. payload 是不透明字节；
2. finalizer C function pointer 存放在 payload 尾部；
3. RC 释放路径识别 external object 后直接调用 C finalizer；
4. payload 不进入普通 MoonBit child-reference 扫描。

因此不能简单地在现有 payload 中写入 MoonBit closure、parent wrapper 或其他 MoonBit 引用。runtime 看不到这些引用，它们可能在 external object仍需要它们时已经被回收。

若未来要从 `FuncRef` 扩展到可捕获的普通 MoonBit closure，至少需要以下实现之一：

- 新增一种包含可扫描 closure/payload 字段的对象 layout；
- 或由 C trampoline 显式 root/unroot closure 与 payload；
- 或将普通可扫描 MoonBit holder 与纯 C external payload 分离，并由稳定 registration token关联。

无论采用哪种表示，进入 pending-finalizer queue 后，queue 都必须继续保活 closure 和 payload，直到回调执行或 runtime明确放弃它们。

### 15.5 不应在任意 `decref` 点同步运行普通 MoonBit 代码

当前 C finalizer 在 RC 释放路径中同步执行。若直接把它换成任意 MoonBit closure，就会把用户代码重入点插入每一个可能的 last release：

```text
编译器插入 decref
→ RC 归零
→ 用户 finalizer
→ 分配、decref、LLVM 调用、锁、callback、panic
→ 返回原来的释放过程
```

可能的问题包括：

- finalizer 分配对象并触发更多级联 finalization；
- finalizer 重入尚未完成的数据结构更新；
- 在持有 runtime、allocator 或用户锁时再次获取同一把锁；
- 最后一次 release 发生在 worker thread，却在那里执行 UI/线程亲和清理；
- finalizer 调用 C 后同步触发 callback，再进入正在销毁的 wrapper；
- finalizer panic 后，后续对象和字段的清理责任不明确；
- runtime shutdown 期间调用已经失效的动态库函数表。

较稳妥的模型是把 finalizer 队列化：RC/GC 只把一个分离后的 finalize job 放入 pending queue，在受控 safe point 排空。候选 safe point包括函数边界、分配点、事件循环 tick 或显式 `run_pending_finalizers()`。这会进一步弱化实际调用时机，但与 finalizer 本来就不确定的契约一致，并避免把任意 MoonBit 用户代码变成隐式的 `decref` 重入点。

### 15.6 finalizer 不应获得正在死亡的 `self`

不建议提供以下形态：

```moonbit
fn Object::finalize(self) {
  // 可访问完整对象
}
```

把 dying object 本身交给用户 finalizer，会引出对象复活、访问已经部分销毁的字段、重新注册自身、销毁顺序不一致以及跨对象环等经典问题。

更安全的 API 应采用分离 payload：

```moonbit
// 概念 API。
Finalizable::new(
  payload,
  fn(payload) -> Unit { ... }, // no raise, no async
)
```

finalizer 只能看到 registration 时提供的 payload，永远拿不到原 wrapper。runtime 在 wrapper 不可达时把 closure 与 payload 分离成 job，再释放 wrapper；从结构上阻止对象复活。

API还应防止 finalize closure 捕获原 wrapper，否则会形成：

```text
wrapper → finalize closure → wrapper
```

这样的环会使 registration 永远不可达不到“可 finalization”的状态。仅靠文档禁止 capture 不够理想；构造 API和内部表示应尽量让 closure 只能接收独立 payload，而不是在 wrapper 构造完成后捕获 `self`。

### 15.7 effect、错误和阻塞的限制

MoonBit finalizer 应至少要求：

- 不得 `raise`；
- 不得 `async`；
- 不应依赖返回值；
- 不得把错误留成未消费的外部 error object；
- 不应执行可能无限阻塞的协议关闭；
- 默认不承诺运行线程。

显式 `close` / `close_async` 才负责可能失败或需要等待的协议操作。finalizer 只执行不可失败的最低限度释放，或者把线程/事件循环相关清理提交到专用队列。

例如返回 `LLVMErrorRef` 的 ORC disposer：显式 close 应把错误转换并报告给用户；finalizer 只能 best-effort 调用，并确保返回的 error 被 consume，不能试图从 finalizer 向任意用户控制流传播错误。

### 15.8 raw borrow 的保活与 last-use 优化

即使有 `Finalizable[T]`，以下 API仍然危险：

```moonbit
let raw = owner.borrow()
LLVMDoSomething(raw)
```

如果 RC insertion/last-use 优化认为 `owner` 在 `borrow()` 后已经没有用途，可能提前 release owner并安排 finalizer；裸 handle 随后成为悬垂指针。若 C 在调用返回后继续保存 raw，问题更加严重。

因此不能把 `borrow() -> RawHandle` 当成可以任意逃逸的普通 getter。需要一种或多种保证：

- binding 方法把 owner receiver 保活到整个 extern 调用返回；
- compiler/runtime 提供明确的 `keep_alive(owner)` 边界；
- 使用 non-escaping lexical borrow；
- 使用 `with_payload(owner, fn(raw) { ... })` 一类 scope API；
- 对 C 会保存的参数使用 retain/root/consume 协议，而不是普通 borrow。

这与 finalizer 本身无关，却会直接决定 MoonBit-written finalizer wrapper 是否真的避免 UAF。

### 15.9 与 affine `#resource` 必须分车道

同一个 native handle 不应同时由确定性 `Drop` 与不确定 finalizer负责，否则会重新引入 double-free 或需要一套不必要的共享幂等状态机。

推荐分层：

```text
affine resource：
  编译器追踪唯一 owner，确定性 Drop；同一 handle 不注册 finalizer。

普通 RC managed wrapper：
  动态 owner state + 显式 close；finalizer只做遗忘 close 的兜底。
```

未来 `Shared[T]` 若承诺“最后一个 shared handle消失时确定性 release”，也不应建立在 `maybe never` 的 finalizer 上。每个 shared handle应有确定性的 release 语义，内部引用计数归零时释放底层资源；finalizer仍是另一条弱保证车道。

### 15.10 仍需决定的 runtime 语义

在实现 MoonBit-written finalizer 前，至少要明确：

1. finalizer registration 的对象布局以及 closure/payload 如何被扫描；
2. finalizer 是同步执行还是进入 pending queue；
3. 哪些 safe point负责排空，以及 shutdown 是否尝试排空；
4. finalizer panic 的行为是 abort、记录后继续，还是终止本轮排空；
5. finalizer 是否允许分配和注册新的 finalizer；
6. 多线程下由哪个线程执行，是否提供 thread-bound cleanup queue；
7. closure/payload形成环时是否完全放弃调用；
8. RC 优化器能否移动最后一次 release，以及 finalizer 是否构成可观察时序；
9. JS/WasmGC 后端是拒绝 capability、提供弱实现，还是合法 no-op；
10. debug runtime如何报告由 finalizer兜底的资源以及长期未执行的 pending job。

建议把契约设计成允许 queueing、delay、reordering 和 omission，从而不给当前 RC 的近即时行为制造 Hyrum-law 兼容负担。测试模式可随机延迟、乱序、批量排空 finalizer，主动发现依赖当前 RC 时机的代码。

### 15.11 对 llvm.mbt 生产化路线的判断

MoonBit-written finalizer值得作为通用 Native FFI 基础设施探索。它会让 llvm.mbt、SQLite、SDL 等 binding 的 managed facade更容易编写和生成，也会把更多 cleanup 逻辑从不可见的 C shim带回 MoonBit 类型、文档和测试范围。

但 llvm.mbt 不应等待它才修复当前泄漏。近期仍应：

- 修复 wrapper 自己产生的临时字符串、message 和 error泄漏；
- 完成 ownership ledger；
- 用 `defer close` 提供确定性主路径；
- 需要时先用一个受审计的通用 C owner box实现 finalizer fallback。

如果语言/runtime能力落地，再把通用 C owner box逐步替换为 MoonBit `Finalizable[T]`。迁移时 ownership 分类和测试可以保留，变化的主要是 cleanup 策略的实现位置。

## 16. Godot GDExtension 压力测试：现有 MoonBit 能否支撑复杂 C binding

本节不计划实现 Godot binding，而是用 Godot 4.6 的 GDExtension 接口检验前文提出的动态资源管理方案是否具有通用性。Godot 比 LLVM 更复杂的地方在于：它不只有 extension-owned handle，还同时存在引擎拥有的对象图、Godot 自身的引用计数、内部借用指针、长期 callback、worker thread 和动态库热重载。

### 16.1 暂定判断

当前 MoonBit 已经足以实现一套“普通用户通常不需要手工管理资源”的 Godot 高层 binding，合理目标可以表述为：

> 主线程优先、第一版不支持热重载、raw pointer 不公开，以动态 liveness/management 检查替代静态 ownership 证明；常用 Object、RefCounted、builtin value 和 callback 的清理由 binding 自动完成。

但当前能力还不足以承诺“完整 Godot API 在所有线程、热重载和低层 Server/RID 场景下都完全自动且具有强内存安全保证”。特别地，普通 `Object`/`Node` 的释放责任本来就会在用户、SceneTree 和引擎之间变化；这个事实不能靠给所有句柄统一套一个 `NativeOwner` 消失。

因此更准确的定位是“动态检查版的成熟 Godot binding”，而不是“给裸 C API 增加 MoonBit 模式匹配”。

### 16.2 最小 ABI 实验已经打通真实 Godot 加载

2026-07-22 在 `/tmp` 建立了独立探针，使用本机 Moon、MoonBit C backend 和 Godot `4.6.stable` 验证以下能力：

- `#export_name` 导出的 MoonBit 函数可被 C 调用；
- `FuncRef` 可以接收和调用 C 函数指针表；
- C `void *userdata` 可以作为 `#external` 进入 MoonBit callback；
- 显式数值 enum 和 `#valtype` struct 可以在本机 arm64 C ABI 上按值往返；
- 手工链接出的 `.dylib` 可以被真实 Godot headless 加载；
- Godot 依次进入了 MoonBit 编写的 Core、Servers、Scene、Editor initialize callback，并按相反顺序进入 deinitialize callback。

mock ABI 检查全部通过，Godot 退出码为 0。这证明“GDExtension 能否进入 MoonBit”不是根本阻碍。

实验也暴露出几个确定的工具链问题：

1. 当前 C backend 为返回 `Unit` 的 `#export_name` wrapper 生成 `int32_t` 返回值，不能直接充当 Godot 的 `void` callback，仍需严格的 C adapter。这里要区分普通 `FuncRef[(...) -> Unit]` 的函数指针表示与 `#export_name` 额外生成的 C wrapper ABI。
2. 当前 FFI checker 会把部分 `#valtype` 参数误判为 boxed pointer，需要无语义必要的 `#borrow` 才能通过。
3. Godot 的 `get_proc_address` 返回无类型函数指针，正式 binding 仍应由生成的 C API table 完成类型化，不应让 MoonBit 任意把 `void *` 强转成 `FuncRef`。
4. `moon build` 尚不能直接输出包含完整 runtime 依赖的 GDExtension `.dylib/.so/.dll`。实验需要手工链接 runtime object、simdutf 和 libbacktrace；库作者不应依赖这些私有细节。

### 16.3 Godot 已提供机器可读 source of truth，但不提供完整 ownership 真相

Godot 4.6 可以同时导出：

- `gdextension_interface.json`：145 个底层类型与 176 个动态接口函数，带 `since`、deprecated、参数和回调结构信息；
- `extension_api.json`：1023 个 Object class、38 个 builtin class、方法 hash、继承关系、`is_refcounted`、builtin size 和 `has_destructor`。

正式 binding 应从这两份 JSON 生成 C API table、MoonBit raw 层、safe wrapper 和 ABI witness，不能手写维护整份头文件。Godot 官方也把 `gdextension_interface.json` 定义为 C API 的 source of truth。

这些元数据足以自动区分大量表示，但仍没有完整表达：

- 一个 Object 返回值是 owned、borrowed、singleton 还是仅在 callback 内有效；
- 一个 RID 是新建并需要释放，还是由其他 Godot 对象拥有的观察值；
- 内部 pointer 会因 resize、COW detach 或 rehash 在何时失效；
- 哪些 API 只允许在主线程调用。

因此仍需要 binding 自己维护版本化 ownership/thread/lifetime override。`moon ffi check` 可以证明 ABI 兼容，不能从 C 类型自动证明语义所有权。

### 16.4 资源不能统一成一种 NativeOwner

| Godot 类别 | 建议的 MoonBit 表示 | 用户是否需要 `close` |
|---|---|---|
| `Vector2`、`Color` 等无析构 POD | 经 size/alignment/offset 验证的 `#valtype` | 否 |
| `Variant`、`String`、`StringName`、`Array`、`Dictionary`、PackedArray | 正确构造、复制、析构的 `NativeValue[T]`；临时值尽量在 C glue 栈上配对清理 | 否 |
| `RefCounted` / `Resource` | wrapper 持有一份 Godot strong ref，MoonBit wrapper finalizer 做 unref | 否 |
| 普通 `Object` / `Node` | ObjectID、缓存 pointer、共享 liveness/management cell | 通常交给 SceneTree；高级场景仍需 `queue_free`/`free` |
| 新创建但尚未交给引擎的 Object | `OwnedManual[T]`，丢弃时可兜底释放，交给引擎后只改变 management | 高层常用路径可隐藏 |
| Server 创建的 RID | `OwnedRid[ServerKind]` 与 `RidView`，disposer 必须匹配创建它的 Server | 高层可自动，raw 层不可混淆 |
| custom Callable、signal closure、method userdata | `ForeignRoot`/RootId、静态 trampoline、Godot `free_func` | 否 |
| Array/Dictionary/PackedArray 内部地址 | 不公开，或只提供不能逃逸的 scoped view | 否 |

`NativeOwner { handle, dispose, state }` 仍适合 extension-owned RID、buffer 和独占 native handle，但 Godot Object 至少需要把两个状态维度分开：

```text
Liveness:
  Alive / PendingFree / Dead

Management:
  ExtensionOwned / EngineManaged / Borrowed / Singleton / RefCounted
```

例如 `add_child` 后 Node 仍然 `Alive`、用户仍可调用它，只是释放责任从 `ExtensionOwned` 变成 `EngineManaged`。这不是 safe_in_mbt 中“Moved 后旧句柄不可再访问”的语义。因此一个通用的 `Open/Closed/Moved` enum 不足以表达 Godot 对象。

### 16.5 普通 Object 可以动态消除 UAF，但不能抹掉 Godot 自身的所有权概念

Godot 官方明确区分两类 Object：`RefCounted` 由引用计数管理，其他 Object 手工管理；当调用方不是唯一 owner 时，官方建议长期保存 ObjectID 而不是裸 pointer。GDExtension 又提供 instance binding 的 create/free/reference callback，以及 ObjectID 与 pointer 的双向查询。

binding 可以据此实现共享 liveness cell：

1. 包装对象时记录 ObjectID，并可缓存 pointer；
2. Godot 销毁对象时，instance binding free callback 把 cell 标成 `Dead`；
3. 每次公开方法调用先检查 cell；
4. 一个别名执行 `free` 或 Godot 从别处销毁对象后，其他别名再次使用会得到明确错误，而不是访问悬空 pointer；
5. debug 模式可以改为每次通过 ObjectID 重新查询，release 模式使用 callback-invalidated cache。

这可以有效处理 double-free 和 UAF。无法完全自动处理的是“忘记把手工创建的 Node 交给 SceneTree，也没有显式释放”以及“GDScript 在 binding 之外改变树关系后产生孤儿 Node”。即使具有 affine type 的 godot-rust，也仍用不同构造函数和显式 `free`/`queue_free` 暴露这一区别。

MoonBit 高层 API 可以让常用路径最省事：新 Node 在交给 parent 前由 `OwnedManual` 兜底，`add_child` 成功后动态改变 management；高级 raw API 则明确使用 `new_alloc` 一类醒目命名。未来 affine type 可以静态检查“释放或交给引擎”，但不能单独处理引擎从外部销毁、reparent 和 callback invalidation。

### 16.6 Callback 需要 ForeignRoot，而不仅是 FuncRef

GDExtension custom Callable 提供 `callable_userdata`、静态 callback 和 `free_func`，非常适合下面的结构：

```text
Godot
  -> 静态 C/MoonBit trampoline
  -> userdata 中的 RootId
  -> MoonBit registry 中的对象或捕获 closure
```

当前 MoonBit 可以由库作者自己维护全局 registry：注册时保存 closure，Godot 只持有整数 RootId，`free_func` 或 `free_instance` 再删除 registry entry。这使主线程版本可以工作，不必把普通 MoonBit pointer 塞进不扫描引用的 external payload。

但是每个 binding 自己实现 root table 很容易在错误路径、循环引用、extension unload 和异步 callback 中出错。runtime 应提供正式的 `ForeignRoot[T]`/`StableRef[T]` API，定义 retain、lookup、release、shutdown drain 与线程规则。

### 16.7 第一版应明确限制线程和热重载

Godot 头文件直接提供 worker thread pool callback，而当前 MoonBit native runtime 的 `moonbit_incref`/`moonbit_decref` 是普通非原子 RC 写操作，也没有找到外部线程 attach/detach 协议。于是第一版较可信的边界是：

- Object、Node、extension class 和用户 callback 默认只允许主线程；
- debug 构建检查 thread affinity；
- worker callback 先留在 unsafe/unsupported，或只在 C 中完成工作后把结果投递回主线程；
- finalizer 不负责在未知线程上调用要求主线程的 Godot API。

热重载是另一条独立边界。旧动态库卸载后，遗留的 FuncRef、finalizer、Callable trampoline、MethodBind cache、TLS 和 registry entry 都会成为旧代码地址。第一版应设置 `reloadable=false`，并在普通 deinitialize 中同步注销 class、断开 callback、清空 root、停止任务。完整热重载还需要 generation registry、unload barrier 和 runtime shutdown/drain 协议。

### 16.8 建议的 binding 分层

```text
godot/raw
  由两份 JSON 生成的 C API table、严格 C ABI adapter、完全不公开

godot/builtin
  POD #valtype、NativeValue[Variant/String/Array/...]

godot/object
  RefObject[T]、ManualObject[T]、OwnedManual[T]、BorrowedObject[T]

godot/server
  OwnedRid[ServerKind]、RidView、线程和 disposer metadata

godot/callback
  ForeignRoot[T]、CallableBox、MethodDescriptor、静态 trampoline

godot/extension
  init/deinit level、class registry、generation、unload drain
```

用户层不应看到 `NativeOwner`、raw pointer、Godot constructor/destructor 或 callback userdata。性能上也不能统一 heap-box：数学 POD 和生成的 ptrcall 应走按值快路径，短命 `Variant/String` 应在 C glue 中构造后立即析构，只有持久非平凡值才使用 external object。

### 16.9 对 MoonBit 近期工作的反馈

Godot 探针显示，1.0 前后最有价值的工作不一定是立刻引入完整 affine type，而是先补齐嵌入式 native runtime 与可靠 FFI 的基础协议：

1. 修正 `#export_name` 的 `Unit` C ABI，并修正 `#valtype` ownership checker 误报。
2. 让 `pkgtype(kind: "foreign_library")` 由 Moon 直接产出包含 runtime 私有依赖的 `.dylib/.so/.dll`，支持导出符号与宿主加载测试。
3. 提供正式 `ForeignRoot[T]`，避免 C-retained callback 依赖库作者手写 root table。
4. 定义 C callback 的 panic/error barrier，禁止异常穿过 C ABI，并保证失败路径初始化所有 out parameter。
5. 提供带 size、alignment、constructor、copy 和 destructor 的非平凡 native value primitive，或受支持的 scoped native temporary。
6. 提供外部线程 attach/detach、RC 线程语义和 thread-affinity assertion；在此之前允许 package 声明 main-thread-only。
7. 提供 extension unload hook、root/callback drain 和可选 runtime shutdown 协议。
8. 让 build codegen 能消费 Godot JSON，并让 `moon ffi check` 验证 size/alignment/offset、callback 签名、全量函数表、initialized/uninitialized out parameter 和版本 capability。
9. ownership、thread 和 lifetime 语义必须允许 generator 加人工 override，不能假设 header/JSON 已表达全部事实。

长期 affine type 对 `OwnedManual[T]` 和 `OwnedRid[T]` 很有价值：它可以静态提示资源必须释放或转移给引擎。但它不会替代 ObjectID invalidation、RefCounted 桥接、内部 view 失效、callback rooting、线程 attach 或热重载 barrier。

### 16.10 待讨论

1. 是否接受“第一版 main-thread-only、`reloadable=false`”作为可发布 profile？
2. 普通 `Node::new` 是否采用动态 `OwnedManual -> EngineManaged` 兜底，还是像 godot-rust 一样用显眼的 `new_alloc` 要求用户理解手工管理？
3. `ForeignRoot` 应首先作为 native runtime C API、MoonBit 标准库类型，还是两者共同提供？
4. 非平凡 builtin value 应优先由通用 aligned external object 表达，还是先由生成的 C stack glue 覆盖热路径？
5. Godot case study 是否适合作为 MoonBit `foreign_library`、FFI checker 和 build codegen 的联合验收项目？

## 17. Godot binding 的体验目标与专用构建驱动

### 17.1 诚实的体验判断

以 MoonBit 目前的语言、runtime、构建系统和编辑器集成状态，只做一套 Godot API binding，不可能在“普通 Godot 用户从创建项目、编写逻辑、查看 Inspector、调试到导出游戏”的整体体验上超过 GDScript，现阶段也不能笼统声称超过官方 C#。

GDScript 的优势不只是语法简单，而是它和 Godot 的对象模型及编辑器是同一个产品：内置补全和文档、场景与脚本关联、`@export`、signal、Inspector、断点、调试栈、profiler、脚本资源、重载和导出流程全部已经贯通。C# 的内建代码编辑体验不如 GDScript，通常依赖外部 IDE，并且需要 .NET SDK 和 .NET 版编辑器；但它已经有成熟的 `[Export]`、`[Signal]`、`[GlobalClass]`、Inspector、Build 按钮、调试和平台导出协议。

MoonBit 可以形成局部优势，但这些目前更多是产品机会，不是已经兑现的结论：

| 维度 | 当前较诚实的判断 |
|---|---|
| Godot 零配置和编辑器内循环 | GDScript 明显领先，C# 也领先 MoonBit |
| 类型表达力 | MoonBit 的 ADT、模式匹配和穷尽检查可以明显优于 GDScript，并形成区别于 C# 的风格 |
| 纯计算性能 | MoonBit native 有潜力明显超过 GDScript；相对 C# 必须实测，不能把“编译成本地代码”直接等同于全面更快 |
| Godot API 调用性能 | 会受到 ptrcall、Variant、对象存活检查和 ABI 边界影响，很多真实游戏并不由语言纯计算主导 |
| 部署 | MoonBit 有机会做到无 .NET runtime、更小的原生产物，并覆盖 C# 当前受限的平台；但需要先完成可靠的多平台 shared-library/Wasm 构建和导出 |
| 调试、profiler、热重载 | 当前还没有能与 GDScript/C# 比较的完整链路 |
| native 资源安全 | 可以通过生成的 safe facade、liveness cell 和 ForeignRoot 做得远好于裸 C++ GDExtension，但仍需大量 binding 工程和 runtime 支持 |

因此第一阶段更合理的定位不是“比 GDScript 更好的 Godot 语言”，而是：

> 比手写 C++ GDExtension 更安全、更高层；在类型表达力、原生部署和 Web 等特定维度上，有机会比 C# 更有吸引力的 Godot 原生扩展 SDK。

只有当专用工具链、Inspector、调试、导出和重载全部成熟后，才能讨论它是否在某类用户群体中整体胜过 C#。追平 GDScript 则还需要更深一层的 ScriptLanguage 集成。

### 17.2 “GDExtension SDK”和“一等脚本语言”是两个产品

Godot 官方明确把 GDExtension 定义为 native shared library，而不是一种 scripting language。于是应把目标拆成两档。

第一档是 MoonBit GDExtension SDK：

- 一个 MoonBit 项目整体编译成一个 `.dylib`、`.so`、`.dll` 或 Wasm side module；
- MoonBit 类型注册为 Godot native class；
- 用户可在 Add Node、Inspector 和 signal 系统中使用这些 class；
- 开发者主要在 MoonBit IDE/LSP 中编写代码，由 Godot EditorPlugin 触发构建、显示诊断并请求安全重载；
- 用户不是给每个 Node attach 一个 `.mbt` Script resource。

这一档可以落地，也可能做成很好用的原生扩展语言，但体验模型更接近 godot-cpp、godot-rust，而不是 GDScript。

第二档是 MoonBit ScriptLanguage：

- `.mbt` 成为 Godot 认识的 Script resource，可以直接 attach 到 Node；
- 实现 `ScriptExtension`、`ScriptLanguageExtension` 和 ScriptInstance；
- 接通 validate、completion、模板、reload、调试栈、断点、profiling、序列化和线程协议；
- 解决 MoonBit package/module 语义与 Godot 每个脚本资源、场景资源之间的映射。

这已经不是 binding 项目，而是完整的 Godot 语言后端。第一版不应把它作为隐藏前提；应先把第一档做好，再用真实用户需求决定是否进入第二档。

### 17.3 Godot binding 确实“以 export 为核心”，但不等于每个方法都是导出符号

普通 C binding 主要是 MoonBit 调用宿主库。Godot GDExtension 至少同时需要三类反向描述：

1. 动态库向 Godot 暴露的 entry symbol；
2. Godot 以后反向调用的 class、method、property、notification 和 Callable trampoline；
3. 注册到 ClassDB、Inspector、signal 系统中的 class/property/method/signal 元数据。

每新增或修改一个 Godot class，都可能改变注册表、callback userdata、生成的 ABI glue 和热重载状态，所以源码分析或编译期元数据生成是核心能力。这一点和普通“为 C header 写 extern 声明”的 binding 很不一样。

但不应该要求用户给每个普通 MoonBit method 手写 `#export_name`。GDExtension method registration 可以保存 `method_userdata`，再进入少量固定的 call/ptrcall trampoline；平台真正需要导出的符号可以只有 entry 和少量稳定桥接函数。生成器负责把 Godot method id、签名和 MoonBit 实现连接起来。

理想的用户层应接近声明 class、property、signal 和 virtual method，构建阶段从 MoonBit 的语义信息生成注册表。MoonBit 已经有供外部工具消费的 namespaced user-defined attribute，可以直接表达 `#godot.class`、`#godot.export`、`#godot.signal` 等声明；当前缺少的主要是 typed annotation processor/custom derive，以及把这些 attribute 连同 resolved type information 稳定交给生成器的接口。短期可以复用正式 parser 做两阶段 codegen，或使用强类型 registration DSL；长期不宜让外部工具脆弱地正则解析 `.mbt` 源码，也不宜把所有注册细节推给用户。

### 17.4 需要 Godot 专用 driver，但长期不应直接复制一套 Moon

需要一个 `godot-moon` 或 `moon-godot` 专用工具，这个判断是对的。它应负责 Godot 特有的工作：

- 识别 Godot 版本、real precision、目标平台和 extension capability；
- 获取、缓存并校验 `gdextension_interface.json` 与 `extension_api.json`；
- 生成 raw binding、typed ptrcall、class registration glue 和 `.gdextension` 文件；
- 扫描或消费 MoonBit 编译器给出的 Godot export metadata；
- 驱动 debug/release、目标架构、Web 和多平台动态库构建；
- 原子替换产物，协调 deinitialize、callback drain 和安全 reload；
- 把编译诊断映射回 `.mbt` 文件，并接入 Godot 的 Build/Run/Export 生命周期。

但是，长期让它绕过 Moon CLI、直接把 `moonc` 当完整构建系统使用并不合适。`moonc` 负责 package 编译和 codegen；一个可用项目还需要 package graph、依赖解析、core/package interface、增量调度、生成代码依赖、C stub 编译、MoonBit runtime 对象、平台 C toolchain、link flags、缓存、测试以及多目标产物布局。专用工具一旦把这些全部接管，就会逐渐成为第二套 Moon，而且会强耦合 `moonc` 的内部命令行和 runtime 私有文件。

前面的真实 Godot 探针已经验证了这个风险：`moonc` 生成 C 以后，还必须手工链接 `runtime.o`、C stub、simdutf 和 libbacktrace 才能得到可加载的 `.dylib`。这些依赖不应由 Godot plugin 复制维护。Moon 当前 schema 也明确写着 native/LLVM backend 尚不支持完整 `foreign_library`，native lowering 仍有“支持 library”的 TODO；这是应该补齐的通用构建能力，而不是 Godot 项目永远绕开的缺口。

较合理的长期分层是：

```text
Godot Editor / Export
        |
        v
godot-moon                 Godot 专用 orchestration
  - export metadata/codegen
  - ClassDB registration glue
  - .gdextension 与 reload
  - Godot target/package mapping
        |
        v
Moon 稳定构建 API / daemon / machine CLI
  - package graph 与依赖
  - incremental build 与 cache
  - foreign_library artifact
  - C stub/runtime/toolchain/link
        |
        v
moonc + C compiler + platform linker
```

这里“从 Godot 编辑器发起构建”和“绕过 Moon 的构建语义”不是一回事。Godot EditorPlugin 可以只看见 `godot-moon build --json`；`godot-moon` 内部再调用 Moon 的稳定机器接口。类似地，Rust 的 Godot binding 仍以 Cargo 而不是裸 `rustc` 为底座，C# 集成仍以 .NET/MSBuild 而不是裸 C# compiler 为底座。

如果为了验证最小闭环，短期原型直接调用 `moonc`、C compiler 和 linker 是合理的；但应明确它是一次性实验路径。正式架构至少需要 Moon 提供：

- native/LLVM 的 `foreign_library` output type；
- 指定 entry/exported symbol、runtime linkage 和 target triple 的稳定配置；
- build-time codegen 的依赖边和输出声明；
- 机器可读诊断和 artifact manifest；
- 可嵌入的 build API/daemon，或者语义稳定的 machine CLI；
- Godot editor build 与命令行/CI/export 使用完全相同的构建图。

### 17.5 建议的开发阶段

第一阶段只实现一个诚实而完整的 profile：main-thread-only、`reloadable=false`、一个项目一个 GDExtension、外部 MoonBit IDE、Godot 中可见的 native class/property/signal，以及可重复的桌面平台构建。先证明用户不接触 raw pointer、注册表和手工 linker。

第二阶段增加 EditorPlugin 的 Build 按钮、watch mode、结构化诊断、Inspector metadata、跨平台导出和受控 reload。热重载必须先有 extension generation、callback/root drain 和卸载屏障，不能只替换动态库文件。

第三阶段再决定是否投入 ScriptLanguage。若大多数用户只需要高性能系统、Godot 原生 class 和可复用插件，GDExtension SDK 可能已经是正确产品；若目标是取代 GDScript/C# 作为逐节点 gameplay scripting，才值得承担完整 ScriptLanguage、debugger 和资源系统集成的成本。

### 17.6 暂定结论

1. MoonBit 现阶段不能把“整体体验超过 GDScript/C#”作为可信承诺。
2. 先超过裸 C++ GDExtension 的安全性和工程体验，是可实现且有价值的目标。
3. Godot 专用构建/编辑器适配层是必要产品组件，不应被当作普通 binding 的附属脚本。
4. 专用层负责 Godot 语义，Moon 负责通用构建图，`moonc` 负责语言编译；不要把三者全部压进一个直接调用 `moonc` 的编辑器脚本。
5. 如果 Moon 不能自然产出宿主可加载的 shared library，这正是 MoonBit 1.0 前后应修复的通用能力，而不是建议每个大型 binding 各自维护私有 linker recipe。

相关官方文档：

- [Godot Script Editor](https://docs.godotengine.org/en/stable/tutorials/editor/script_editor.html)
- [C# basics](https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/c_sharp_basics.html)
- [GDExtension](https://docs.godotengine.org/en/4.6/classes/class_gdextension.html)
- [ScriptLanguageExtension](https://docs.godotengine.org/en/4.6/classes/class_scriptlanguageextension.html)
- [EditorPlugin](https://docs.godotengine.org/en/4.6/classes/class_editorplugin.html)

## 18. 只看语言与编译器：MoonBit 的现状是否构成 Godot 体验上限

### 18.1 修正问题边界

本节暂时假设 API 生成、编辑器插件、构建系统、调试 UI、文档和维护人力都可以投入足够资源，只考察以下问题：

> 在 MoonBit 核心语言、类型系统、native backend 和 runtime 大体维持现有设计的前提下，是否仍有希望做出一种在真实用户眼中比 GDScript 或 C# 更好的 Godot 编程语言？

结论需要分成两个层次：

1. MoonBit 的核心语言和类型系统没有阻止高质量 Godot binding 的致命缺陷。在大型、强类型、状态复杂的项目中，它完全有希望让一部分用户认为整体体验优于 GDScript，并在数据建模方面优于 C#。
2. 如果把当前 native runtime 的具体行为也完全冻结，则不能诚实地承诺整体优于 GDScript/C#。主要上限不是 ownership，而是当前 native backend 仍按“程序拥有整个进程”设计，缺少可靠的 embedded-runtime failure、thread 和 unload contract。

因此准确说法是：

> 不需要给 MoonBit 增加完整 affine type、类继承或运行时反射；但需要把 native backend 从 whole-program backend 补成可嵌入宿主进程的 backend。若“大体保持现状”允许这组定向增强，则答案是有希望；若一行 runtime/compiler 都不能改，则答案是否定的。

### 18.2 现有语言已经足够表达一个很好的 Godot 用户层

Godot 用户层需要表达的核心概念，都可以映射到 MoonBit 现有能力：

| Godot 概念 | MoonBit 可用表达 |
|---|---|
| nullable Object、动态 cast | `T?`、pattern matching、显式 checked cast |
| Variant | 生成的转换 trait，加动态 `Variant` wrapper；已知闭集可转为 ADT |
| signal/Callable | closure、typed signal wrapper、userdata registry |
| 等待 signal、timer、异步资源 | native 已有 async/CPS 与 `%async.suspend`，可把 callback API 变成 typed async API |
| virtual callback | trait method/default implementation，生成的 trampoline 检查签名 |
| class/property/signal metadata | 已有 namespaced user-defined attribute，加编译期 codegen |
| Godot builtin POD | `#valtype`、C-layout struct/enum、生成的 ptrcall |
| Godot 反向调用 | `#export_name`、`FuncRef`、固定 trampoline 加 userdata |
| 对象失效 | ObjectID、liveness cell、generation、`Result`/typed error |

MoonBit 的 user-defined attribute 语法已经允许：

```moonbit
#godot.class(base=CharacterBody2D)
struct Player {
  #godot.export(range(0.0, 1000.0))
  mut speed : Double
}
```

上例只是可能的 Godot 工具语法，不要求 runtime reflection。MoonBit 文档本身就把 namespaced attribute 定位为供外部工具解析，并偏好 compile-time codegen。当前 checker 会忽略这类 attribute，限制在于 compiler 没有提供 typed annotation processor：生成器能够看到源码语法，却不能通过稳定接口直接取得已经 resolve 的类型、trait implementation 和 attribute metadata。无限工程资源可以用正式 parser、两阶段生成和二次 typecheck 补偿；若希望真正成为通用能力，最小改进是把 opaque namespaced attribute 保留到 typed metadata/`.mi` 输出，而不是引入宏系统或运行时反射。

MoonBit 的 ADT、穷尽 pattern matching、`T?`、typed error effect、trait、closure 和 async，尤其适合游戏状态机、输入事件、资源加载状态和 typed signal。这里存在真实的语言竞争力，不只是“编译成本地代码”：

- 相比 GDScript，可以把大量运行时拼写错误、nullable 错误和未覆盖状态变成编译错误；
- 相比 C#，ADT 和穷尽匹配更自然，不必用 class hierarchy、nullable reference 和例外约定模拟状态和结果；
- signal 可以同时提供 callback 和 typed async 表面，避免 callback hell；
- Godot 的动态 `Variant` 可以保留为 escape hatch，而不是迫使所有业务状态都动态化。

因此“MoonBit 能不能形成比 GDScript/C# 更好的编程体验”的答案确实可以是肯定的，只是目标用户更可能是大型强类型项目，而不是追求最短原型代码的用户。

### 18.3 没有名义继承是体验取舍，不是 binding 阻塞

此前把“MoonBit 没有 class inheritance”近似成“MoonBit 很难提供自然的 Godot 子类型体验”，这个判断说重了。`llvm.mbt` 已经给出了相当完整的反例：

- `Type <- PrimitiveType <- IntegerType`、`Value <- Instruction/Constant/GlobalValue` 用 supertrait 表达行为子类型；
- 具体 wrapper 同时实现多层 trait 和其他 capability trait；
- `&IntegerType`、`&Instruction` 等 trait object 提供动态派发；
- `TypeEnum`、`ValueEnum` 配合 pattern matching/`tryAs...` 提供受控 downcast；
- `extend &IntegerType with Type::{...}` 把父接口方法暴露成自然的点调用；
- 接受 `&Type` 或 `&Value` 的 API 可以直接接收具体 wrapper，普通用户不需要不断手写转换。

这套模式可以直接映射 Godot：

```moonbit
trait Object { ... }
trait Node : Object { ... }
trait CanvasItem : Node { ... }
trait Node2D : CanvasItem { ... }
```

具体的 engine wrapper 或用户 `Player` 实现整条能力链；private struct 封装 Godot handle 和 binding state；virtual callback 由另一组 trait 表达；内建 Godot class 的闭集由生成的 enum 支持 checked downcast。由于 Godot 的“父类状态”本来就在 engine object 中，MoonBit wrapper 通常只是同一个 native handle 的不同静态视图，并不真正需要复制传统 OO 的字段布局继承。

因此，MoonBit 缺少的主要是：

1. 用户自定义类之间自动的字段与 concrete implementation 继承；
2. 原生 `super` 调用以及构造/析构链语法；
3. 对开放类集合原生的 `is/as` runtime protocol；closed enum 需要生成器、`extenum` 或 class-id registry 补充；
4. 某些容器协变和非 object-safe `Self` 签名需要适配。

这些差异会使 `class FastPlayer : Player` 一类代码不如 C# 直接，但并不会阻止封装、upcast、动态派发或一般 Godot virtual override。对于 Godot 这种句柄型 OOP，MoonBit 现有的 trait object + enum 模式基本够用，而且 ADT downcast 和多 capability trait 甚至可能比传统单继承更舒服。godot-rust 只能证明“没有 class inheritance 也能做”；`llvm.mbt` 进一步说明 MoonBit 自身的 trait object 使用体验不必照搬 Rust 的复杂度。

### 18.4 ownership/affine type 不是决定性缺口

GDScript 和 C# 都不能静态证明 Godot Object 尚未被 engine 销毁，也不能静态证明 Node 必须被加入 SceneTree 或释放。因此 MoonBit 暂时没有 affine/lifetime，并不会天然使它低一个安全等级。

MoonBit binding 可以让：

- nullable 返回值成为 `T?`；
- engine-destroyed Object 在调用时产生 typed stale-handle error；
- RefCounted 自动 retain/release；
- Node 的常用创建路径自动转移给 SceneTree；
- raw pointer、内部 borrowed view 和 disposer 完全不进入普通用户 API。

其上限是不能在编译期证明 handle 有效，也不能静态阻止用户把 borrowed view 保存到下一帧。但 GDScript/C# 在同一问题上也主要依赖动态检查。所以 affine type 会让 MoonBit 更强，却不是追平或超过它们的必要条件。

### 18.5 当前 native backend 的第一个硬上限：panic 会杀死宿主进程

MoonBit 的 typed `raise` 可以由生成的 Godot callback wrapper 捕获并转换成 Godot error/log，这是优势。但 `panic` 是另一套机制：当前 `moonbit_panic()` 最终只能 `exit(1)` 或 `abort()`。数组越界、`unwrap` 失败和若干标准库前置条件都会走这条路径。

在普通 executable 中，“panic 终止进程”是可以接受的设计选择；在 Godot extension 中，进程属于 Godot。一次用户数组越界可能直接杀死运行中的游戏，若 extension 以 tool mode 加载，还可能杀死 Godot editor。这和 GDScript 的可报告 runtime error、C# callback 边界捕获 exception 不是同一级体验。

C glue 不能用 `setjmp/longjmp` 可靠补偿，因为它会跳过编译器插入的 ARC cleanup，并可能留下半修改对象、锁和 foreign call 状态。要成为一等 embedded language，需要 compiler/runtime 明确定义一种方案，例如：

1. embeddable profile 把 panic lowering 成可在 foreign entry boundary 捕获的异常/effect，并生成完整 cleanup；或
2. panic 只终止当前 MoonBit runtime domain，由宿主收到结构化错误后销毁并重建该 domain，而不是终止 Godot 进程。

这是当前最值得 native backend 正视的理论缺口。如果完全不改，它单独就足以阻止“整体脚本体验优于 GDScript/C#”这一强承诺。

### 18.6 第二个硬边界：共享多线程没有安全语义

当前 native runtime 的 RC header 是普通 `int32_t`，`moonbit_incref/decref` 使用非原子读改写，也没有语言级 `Send/Sync`、actor/isolate 或共享对象内存模型。ARC 是非移动的，所以外部线程本身不需要 tracing-GC 式 attach 才能看到一个 pointer；真正的问题是多个线程同时操作同一 MoonBit object graph 会产生 data race，严重时成为 UAF。

binding 可以把所有 Godot -> MoonBit callback marshal 到主线程，或用一个全局锁串行进入 MoonBit。这已经覆盖大部分 GDScript-style gameplay，也不影响 cooperative async。但在 runtime 完全不变时，MoonBit 无法像 C# 一样自然地让用户在 WorkerThreadPool/Thread 中共享 managed graph 并保持内存安全。

这里不能只把 RC increment 改成 atomic：mutable reference slot 的并发读写、对象发布和语言 memory model 也必须定义。可选方向是线程安全 managed heap，或者更符合 MoonBit 的 isolate/message-passing profile。第一版 Godot SDK可以明确 main-thread-only；若目标是“所有维度超过 C#”，则必须补这层语义。

编译器团队已经倾向未来采用 isolate，而不是允许任意共享 MoonBit object graph。这个方向与 Godot 很匹配：主 isolate 独占 engine wrapper 和主线程回调；worker isolate 通过复制值、消息或稳定的 Godot ObjectID 交换结果，不跨 isolate 共享 MoonBit pointer。这样不需要把当前 RC 全面原子化，也能把线程亲和性变成清晰的系统边界。仍需补充的是 isolate 的宿主嵌入协议，而不仅是一个用户层并发库。

### 18.7 RC cycle、WeakRef 和 C# 的真实优势

当前 native/C backend 是不检测循环的 reference counting，也没有一般 `Weak[T]`。任意 MoonBit 对象或 closure 形成环后，binding 无法从外部发现并回收：

```text
MoonBit object -> closure/signal connection -> MoonBit object
```

Godot 对象部分可以用 ObjectID、PREDELETE/free callback 和主动 disconnect 打断；extension class 也可以在 Godot `free_instance` 中释放 root。因此常见 Godot 跨边界环可以由 binding 设计显著缓解。纯 MoonBit 用户对象形成的任意环则不能靠 Godot binding 修复。

这不一定使 MoonBit 比 GDScript 更差，因为 Godot RefCounted 自己也存在循环引用问题；但 C# 的 tracing GC 在 managed cycle 上确实更强。若要宣称内存管理整体优于 C#，至少需要公开 weak reference，或者 ORC/cycle collector 一类 runtime 能力。

值得修正前文的一点是：native ARC 下，强 `ForeignRoot` 不是不可实现的新 GC primitive。对象不移动，C registry 保存 pointer 并调用 `moonbit_incref/decref` 就能构成 stable strong root。真正缺的是官方稳定契约、weak root 和跨线程规则。

编译器团队正在推进 RC cycle collector，并预计下一个版本加入。这会消除“纯 MoonBit managed graph 的普通循环永久泄漏”这个现状性缺陷，所以不应再把它列作 Godot binding 的长期语言上限。不过 cycle collector 不会自动看懂 Godot/C 持有的 roots，也无法自行打断 `MoonBit object -> Godot Callable -> MoonBit userdata` 这样的跨语言环；foreign root 注册、weak root、signal disconnect 和 shutdown drain 仍需要正式协议。collector 的 buffer、root set 和 finalizer queue 最好归属于 isolate/runtime domain，才能支持插件卸载。

### 18.8 动态库卸载与 hot reload 暴露了 runtime domain 缺失

当前 runtime 没有完整 module/runtime shutdown：全局 layout table 在 init 中设置，编译器主要在普通 `main` 结束时处理 global drop；external object finalizer 和 `FuncRef` 又直接保存 DSO 内的代码地址。

如果旧 MoonBit 动态库卸载后仍有任意 object、global、finalizer、closure 或 callback 逃逸，它们都会引用已经卸载的代码。binding 可以通过稳定 C shim、统一 registry、禁止逃逸和 unload 前 drain 实现受限 reload；也可以每次修改后重启 game process。无法由 binding 完全补偿的是“任意 MoonBit global/heap 状态透明迁移，并保证旧 DSO 可以安全卸载”。这需要至少一项：

- compiler 生成 module deinit/global drop；
- runtime domain/context 与 root enumeration；
- 以 domain 为单位的停止、drain 和销毁协议。

这不是普通 gameplay 正确性的前提，却决定热重载能否达到一等脚本语言水平。

### 18.9 最小的语言/compiler/runtime建议

若目标只是做出很好的主线程 Godot SDK，不需要改变 MoonBit 核心语言。若目标是有资格在整体体验上挑战 GDScript/C#，建议优先级为：

1. **Recoverable foreign panic boundary**：宿主进程不能被 MoonBit user panic 直接终止，并且恢复路径必须正确清理 ARC。
2. **Embedded module lifecycle**：明确 init、entry、root、drain、deinit 和 DSO unload contract。
3. **Thread policy**：至少能声明并动态验证 single-threaded domain；长期选择 thread-safe shared heap 或 isolate/message passing。
4. **Weak reference/cycle strategy**：先提供 `Weak[T]`/weak foreign root，是否做 cycle collector可以另议。
5. **Typed codegen metadata**：把 user-defined attribute 与 resolved type/signature 以稳定形式给外部 generator；不必上 runtime reflection或通用宏。
6. **稳定 embedded C ABI**：修复 `Unit` export、`#valtype` checker 等具体问题，并把 retain/release、callback、error/panic contract 正式化。

其中 1、2、3 反映的是 native backend 从 standalone executable 到 embeddable component 的角色变化；4 改善 RC 的一般编程上限；5 主要决定 Godot authoring 表面能否和 C# source generator 一样自然。它们都不要求 MoonBit变成 Rust，也不要求引入传统 OO class hierarchy。

### 18.10 最终判断

如果“保持现状”指核心语言哲学、ADT/trait/async/error effect、GC 语言定位和总体编译架构保持不变，只允许增加少量 embedded-runtime contract，那么答案是：

> 有希望。MoonBit 可以做出一种在大型强类型 Godot 项目中比 GDScript 更可靠、在数据建模和 effect 表达上比 C# 更舒服的语言体验；用户也不必操心 native resource。

如果“保持现状”指当前 native runtime 行为逐字冻结，那么答案是：

> 没有希望做到全局更好。它仍可以是非常好的 GDExtension 语言，但 fatal panic、共享多线程、RC cycle 和安全 unload 会形成 binding 工程无法消除的体验上限。

因此 Godot case study 对 MoonBit native backend 最重要的反馈并不是“必须尽快上 affine ownership”，而是：

> MoonBit native 需要一个正式的 embeddable component profile。程序不是总能拥有进程；有时 MoonBit 只是 Godot、数据库、浏览器或游戏引擎中的一个可加载组件。

## 19. Godot 对 native runtime 的进一步反馈：domain、isolate 与热重载

### 19.1 已知路线图对判断的修正

编译器团队补充了两项未来计划：并发采用 isolate 模型；RC cycle collector 已在推进并预计下一个版本加入。这两项都与 Godot 很契合，也明显降低了上一节所述的长期上限：

- isolate 可以避免给任意共享 object graph 追加原子 RC 和完整共享内存模型；
- cycle collector 可以回收纯 MoonBit graph 中的普通强引用环；
- trait object + enum 已足以表达 Godot 的句柄型 OOP，名义 class inheritance 不是主要缺陷。

因此剩下最值得关注的不是“MoonBit 是否像 Rust 一样拥有 affine type”或“是否像 C# 一样拥有 class”，而是 native runtime 是否把自己定义为一个可以被宿主创建、调用、停止和销毁的组件。

### 19.2 runtime domain 到底是什么

这里的 runtime domain 并不必然表示一台 VM，也不要求给每次 `incref/decref` 都额外传一个用户可见的 context pointer。它首先是一个**生命周期与代码代际的所有权边界**：

> 凡是其数据布局、析构行为或控制流依赖某一代 MoonBit 动态库代码的东西，都属于同一个 domain；只有当这些东西全部停止并释放后，该代代码才可以卸载。

一个 Godot/MoonBit domain 至少概念性地拥有：

```text
Domain N
├── 该代 MoonBit DSO 及 compiler layout metadata
├── runtime globals、MoonBit globals 与 managed heap objects
├── Godot/C 持有的 MoonBit strong/weak roots
├── FuncRef、trait vtable、finalizer 和各类 callback userdata
├── 尚未完成的 async continuation、timer 与 worker task
├── 当前正在执行的 foreign-entry callback
└── 未来的 cycle collector buffer、finalizer queue 和 isolate scheduler state
```

当前 native runtime 的若干细节说明为什么这个边界需要被显式化：普通对象 header 只保存 layout index，drop 时通过全局 `moonbit_layout_table` 解释；external object 直接保存 finalizer function pointer；`FuncRef` 在 C backend 中也是代码指针；生成的 `moonbit_init` 设置全局 layout table，而 global drop 主要附着于 executable 的 `main` 退出路径。这些设计对“一个进程只运行一个完整 MoonBit 程序”很自然，但没有直接描述“同一进程中的多个插件”以及“旧 DSO 卸载后加载新 DSO”。

在可靠实现中，domain 最终应在 runtime ABI 中表现为显式的 `Domain`/`ModuleDescriptor`，但可以完全不出现在普通 MoonBit 源码里：生成的 foreign entry wrapper 负责 enter/leave，TLS 保存当前 domain，allocator page/side table 保存 allocation 归属，因而不必扩大每一个 object header。domain 的作用也不是自动迁移任意 MoonBit heap。热重载时，更现实的语义是销毁旧 domain、保留宿主拥有且被声明为可迁移的状态、建立新 domain，再从这些状态重建 MoonBit instance。

### 19.3 Godot 热重载为什么正好暴露这个边界

Godot 4.6 的 GDExtension reload 大致按以下顺序进行：

1. 在旧库仍可执行时保存现存 extension object 的 storage properties；
2. 执行 shutdown/deinitialize，并由 extension 反序注销 class；
3. 对存活的 Godot Object 调旧库的 `free_instance` 和 instance-binding free callback，清除旧 virtual callback；
4. 清理 Godot 自己追踪的 callback/binding，然后 `dlclose` 旧 DSO；
5. `dlopen` 新 DSO，重新 initialize 和注册 class/method；
6. 以原有 Godot Object 为宿主调用新库的 `recreate_instance`，恢复 storage properties。

上述时序依据 Godot 4.6 的 [`GDExtensionManager::reload_extension`](https://github.com/godotengine/godot/blob/4.6-stable/core/extension/gdextension_manager.cpp#L154-L205)、[`GDExtension::prepare_reload/finish_reload`](https://github.com/godotengine/godot/blob/4.6-stable/core/extension/gdextension.cpp#L914-L1073) 和 [`Object::clear_internal_extension/reset_internal_extension`](https://github.com/godotengine/godot/blob/4.6-stable/core/object/object.cpp#L2325-L2365)。这是 4.6 的实现证据，不应未经核对就当作所有未来 Godot 版本不变的 ABI 时序。

Godot 会处理它知道的 extension instance、ClassDB registration、virtual pointer 和一部分 instance binding；它不知道任意 MoonBit global、foreign root、async continuation，也无法普遍发现已经复制到别处的 custom Callable 或 worker userdata。若这些对象仍保存旧 DSO 的 raw function pointer，那么旧库卸载后的下一次调用乃至析构都会跳入已经失效的代码地址。

Godot 4.6 还有一个实现层时序问题：所有 GDExtension `deinitialize` callback 返回之后，manager 才执行 `clear_instance_bindings`，随后就关闭旧库，中间没有一个供 extension 执行“bindings 已清空，现在销毁 runtime”的正式 hook。因此不能天真地在最后一次 `deinitialize` 中先销毁 domain，因为稍后 Godot 还可能调用旧 instance-binding free callback。binding 可以主动提前枚举并清理这些 binding；更稳妥的长期结构仍是让 free trampoline 常驻于 stable shim，再由 shim 管理 generation userdata。

因此一个可靠 domain 至少需要以下状态机：

```text
ACTIVE
  -> QUIESCING   // 标记代际失效，拒绝新的外部入口
  -> DRAINING    // 等待正在执行的 callback，取消或 join async/worker task
  -> DETACHING   // 断开 signal/callable，注销 class，释放 Godot instance userdata
  -> DESTROYING  // 释放 foreign roots/globals，收环，按线程要求排空 finalizer
  -> DEAD        // 已无旧对象、旧代码指针或 TLS；现在才允许 dlclose
```

这里最容易遗漏的是重入：MoonBit callback 调 Godot，Godot 发 signal 后可能在同一线程再次进入 MoonBit。入口计数和 quiesce gate 必须支持这种嵌套调用，不能简单用一把不可重入的全局锁。

### 19.4 不必一步到位实现“完整 VM context”

第一阶段可以只在 Godot binding 中建立逻辑 domain：

```text
Godot
  -> 常驻、不参与 reload 的稳定 C shim
  -> generation gate + in-flight counter + userdata token
  -> 当前一代 MoonBit DSO 的 dispatch table
```

Godot 长期保存的是 shim 中的稳定 trampoline 和带 generation 的 token，而不是可卸载 DSO 中的 `FuncRef`。每一代 DSO 可以先携带一份 symbol hidden 的私有 runtime 和私有 layout table；编译器再补一个对称的 module deinit，binding registry 负责证明 root/task/callback 已经排空。这样就能完成受限但可靠的 reload，不必立即让每一个 MoonBit object 都携带 runtime pointer。

长期若要支持以下目标，再把 domain/isolate 做成 runtime 的一等 context 更合理：

- 同一进程同时运行多个 MoonBit 插件或多代代码；
- 一个共享 runtime 服务多个 module；
- panic 后销毁并重建单个 MoonBit 世界，而不是结束宿主进程；
- runtime 自己枚举 roots、tasks、collector buffer 和 finalizer；
- 明确定义 create、enter、quiesce、drain、destroy 的 embedding ABI。

因此“runtime domain”不是预先要求重写所有 RC ABI，而是要求先确定可卸载组件的资源归属。实现可以从 binding registry 演进到正式 runtime context。

### 19.5 isolate 是 domain 内的执行边界，而不是同一个概念

更准确的关系是：

- **domain** 属于一次 module/DSO generation，是代码、layout、globals、root table 和卸载的边界；
- **isolate** 是线程封闭的 mutable object graph、任务调度和执行边界；
- 一个 Godot domain 可以包含一个 main isolate 和若干 worker isolate；只有该 domain 下所有 isolate 都停止并排空后，旧 DSO 才可卸载。

若某种 profile 强制“一代 DSO 只有一个 isolate”，两者可以在实现中合并，但不宜把语义概念混为一谈。未来 isolate 不能只是一组 async/message API，它最好真正拥有：

- 自己的 MoonBit roots/object graph 与 cycle collector 状态；
- 自己的 task queue、timer、continuation 和 callback registry；
- create/start/quiesce/cancel/join/destroy 生命周期；
- panic/poison 状态和宿主可观察的失败结果；
- 不允许 raw MoonBit pointer 跨 isolate 共享的消息边界。

Godot 中可以让 main isolate 独占所有 engine Object wrapper 和需要主线程亲和性的 API。worker isolate 只接收复制/序列化的数据、不可变值或稳定的 Godot ObjectID，把结果通过消息送回 main isolate。这比“所有 RC 都变 atomic，然后允许任意共享 mutable graph”更容易给出可解释的安全语义。

isolate 也为 panic containment 提供了合适的最小单位：foreign callback 发生 fatal panic 后，至少将当前 isolate 标成 poisoned；如果它可能已经破坏 domain-shared global/native state，则必须进一步 poison 整个 domain。宿主可以销毁或重建它们，而不是杀死 Godot。但如果 panic 路径不能正确 unwind ARC cleanup，就不能假装从同一调用点恢复；要么 compiler 生成清理路径，要么 runtime 能安全地整域放弃并统一回收其资源。仅把 `moonbit_panic` 改成一个会返回的 hook 是不安全的。

如果未来同一个 module 允许多个 isolate，当前 C static/MoonBit global 也必须明确是 per-domain 还是 per-isolate；若它们仍被进程级共享，则 isolate 的内存隔离只完成了一半。

### 19.6 cycle collector 仍需要认识 foreign boundary

即将加入的 cycle collector 应尽量按 isolate/domain 组织。domain shutdown 可以采用：

1. 停止新入口和新 foreign root；
2. 取消或排空 task；
3. 释放 Godot registry、signal 和 MoonBit globals 持有的 roots；
4. 让 cycle collector 跑到不动点；
5. 在正确线程和 Godot initialization level 排空 finalizer，然后因 finalizer 可能释放新引用而再次收集；
6. 检查仍存活的 external object/root，并生成 leak report。

collector 只能识别纳入其图或 root protocol 的边。`MoonBit object -> Godot Callable -> MoonBit userdata` 这样的跨语言环仍需 foreign root metadata、weak handle 或显式 disconnect。对于 Godot，还不能在任意 worker isolate 的 finalizer 中直接调用 engine API；资源释放往往必须排队回 main thread，并且必须发生在相应 Godot subsystem deinitialize 之前。普通运行期可以允许受控 resurrection，但 domain teardown 阶段最好禁止 finalizer 创建新 host root/新 task，否则 `can_dlclose` 可能永远无法成立。

### 19.7 结合 Godot，native runtime 的改进优先级

如果只看语言与 compiler/runtime，而把 binding 生成和编辑器工程先放在一边，建议优先顺序如下。

**第一组：嵌入正确性的基础**

1. **可隔离的 panic boundary**：panic 不能直接终止宿主；必须选择完整 unwind，或 poison/销毁整个 isolate/domain。
2. **不可变 module descriptor 与对称 lifecycle**：编译器生成包含 runtime ABI、build/generation id、layout table、init/deinit、global drop table 和 export table 的 descriptor，并支持 `init -> quiesce -> drain -> deinit`，而不是把清理只接在 `main` 后。
3. **稳定且最小的 embedding ABI**：明确 retain/release/root/callback/error contract；默认隐藏内部 runtime symbols，只导出 GDExtension entry 与稳定 shim API。
4. **generation-aware root/callback handle**：宿主持有 `{generation, index, epoch}` 一类 token/handle，而非任意裸 MoonBit pointer 或可卸载 DSO 的 raw `FuncRef`；debug mode 检测 stale generation 与 cross-domain decref。
5. **domain-owned allocation/resource accounting**：至少能统计 live allocation、external resource、host root 和 pending finalizer，使 `can_dlclose` 成为可验证条件，而不是一种希望。
6. **可重入 foreign entry protocol**：记录 in-flight call，允许同线程嵌套进入，并能在 quiesce 时拒绝新入口、等待旧入口退出。

**第二组：把既定路线图变成可嵌入能力**

7. **isolate ownership 与宿主生命周期**：除了 spawn/send，还需 cancel/join/destroy、线程亲和性及外部线程进入规则。
8. **cycle collector 的 foreign-root/weak-root 协议**：否则只能解决纯 MoonBit 环，不能解决 signal/Callable 跨边界环。
9. **async/task enumeration 与 drain**：宿主卸载插件前必须能取消、等待并证明没有旧 continuation。
10. **带执行上下文的 finalizer queue**：支持 main-thread/initialization-level affinity，并定义 resurrection policy。

**第三组：可诊断性和多插件政策**

11. domain 级 outstanding root/task/external object/callback 统计和 shutdown leak report；
12. 明确同一进程多个 MoonBit DSO 是各自私有 runtime，还是共享版本化 runtime；若未设计跨 domain ABI，就禁止直接交换 MoonBit object；
13. 在 object header 或 debug side table 中记录 domain/generation，以尽早把错代释放从随机内存破坏变成确定性错误。

这些改进大多不是用户可见的新语言语法，而是 native backend 从 standalone executable 走向 embeddable component 的语义补全。

### 19.8 暂时结论

结合团队已经选择的 isolate 和即将加入的 RC cycle collector，MoonBit 核心语言并不存在一个阻止高质量 Godot 体验的明显理论缺陷。trait object + enum 足以承担 Godot 的主要 OOP 表面；isolate 甚至可能比任意共享内存更适合游戏引擎的主线程模型。

真正尚未闭合的是 runtime 的宿主关系：panic 属于谁、代码代际拥有何种 roots/callback/tasks、怎样停止它们、何时可以卸载代码。只要把这组问题做成正式的 embeddable runtime/isolate contract，MoonBit 在理论上完全可能形成一种比 GDScript 更强类型、比 C# 更适合 ADT/effect 建模，同时又不要求普通用户管理 native 资源的 Godot 体验。若 runtime 保持当前 whole-program 假设不变，则普通不可热重载的 GDExtension 仍可做好，但“编辑器中长期运行、错误可恢复、插件可安全重载”会持续成为体验上限。

## 20. 动态资源管理已经足够安全时，affine resource 还有没有必要

### 20.1 先区分三种“必要”

这个问题不能用一个简单的是或否回答：

1. **作为生产可用 C binding 的前置条件：不必要。** 完善的动态 owner、parent anchor、checked handle、finalizer/cleanup queue 和 ownership ledger，已经可以让 llvm.mbt、Godot binding 达到很高的实际安全水平。
2. **作为 Godot 普通用户 API 的主体：大多不必要，甚至不合适。** Godot 的主流对象本来就是共享或由 engine 驱动失效，强行 affine 化会降低体验而不增加相应程度的保证。
3. **作为 MoonBit 长期表达“唯一资源义务”的语言能力：仍然有价值。** 它能把一部分动态检查提前成编译错误，并为必须及时、按序、恰好一次转移的资源提供确定性语义。

因此需要修正的不是“affine 完全没有必要”，而是它的定位：

> affine resource 不再是可靠 binding 的地基或阻塞项，而是动态安全模型之上的 opt-in 静态强化；Godot 不是它最强的动机，SQLite、文件/socket、锁、GPU handle、注册 token 和 ownership transfer 才更能体现价值。

### 20.2 假设 runtime 完善，动态方案能做到什么

一个受支持的动态资源层可以把所有安全操作强制经过共享 control block：

```text
NativeOwner
  handle
  state = Open | Closing | Closed | Transferred
  disposer
  in_flight leases
  optional parent/liveness anchor
  thread/domain/generation metadata
```

配合 runtime finalizer、RC cycle collector、foreign root、main-thread cleanup queue 和 domain shutdown 后，它可以做到：

- 用户忘记 `close` 时，在最后一个 wrapper 消失后自动释放；
- 所有 alias 共享同一个状态，重复 `close` 不会 double-free；
- `close`/transfer 后通过 checked unwrap 把 UAF 变成明确的 runtime error；
- child wrapper 保活 parent，或在 parent 被外部销毁时观察同一个 dead cell；
- conditional transfer 在调用成功后原子地切换为 `Transferred`，失败时保持 `Open`；
- thread-bound resource 把清理投递到正确 executor；
- generation/domain 检查阻止跨热重载代际使用旧 handle。

在并发或可重入 FFI 中，安全操作不能只是“检查 `Open`，取出 pointer，然后调用 C”，否则检查完成后另一个线程或重入 callback 仍可能关闭资源。更完整的协议是：每次调用先取得一次 in-flight lease；`close` 原子地把 `Open` 变成 `Closing`、拒绝新 lease，并在已有 lease 归零后才真正调用 disposer。Godot callback 可以同步重入，所以即使主 gameplay 采用单 isolate，这个问题仍可能出现。

只要 safe facade 不泄露 raw pointer，这可以构成真正的动态 memory-safety boundary，而不只是“希望用户别写错”。它不能证明程序永远不会触发 `AlreadyClosed`/`StaleHandle`，但可以保证这种误用不会退化成任意内存破坏。

在这个完善模型下，普通用户也不应被要求把 `defer resource.close()` 当成 memory safety 的必要仪式。`close` 应主要用于提前释放稀缺资源、处理可失败/异步关闭或明确协议边界；单纯忘写 `defer` 仍由自动 last-reference release/finalizer 兜底。这正是动态模型相对“裸 C pointer”的用户体验跃迁。

动态方案仍然依赖 binding 作者正确标注 owned/borrowed/retained/consumed 和 disposer。Affine type 也不能从未经标注的 C header 中自动推导这些事实，因此两种方案都不能替代 ownership metadata 与 FFI 审计。

### 20.3 affine 真正新增的保证

首先需要明确：**单独的 affine type 只表示“最多消费一次”，它允许值完全不被使用。** 要解决忘记释放，实际需要的是一整组语义：

```text
affine usage
+ consume/move
+ compiler-inserted deterministic Drop
+ 至少调用期不可逃逸的 borrow
```

这组机制相对动态 owner 的新增价值主要是：

1. **静态排除 accidental alias owner。** 同一个释放责任不会无意中复制给两个变量、字段或 closure。
2. **静态排除 use-after-move。** ownership transfer 后继续使用旧 owner 是编译错误，而不是下一次调用时才看到 `Transferred`。
3. **编译器替用户处理“没有做什么”。** 用户不必记住 `defer resource.close()`；所有正常返回、提前返回和 typed error 路径都会由 drop elaboration 清理仍持有的资源。
4. **释放时间和顺序更容易定义。** 它不依赖“最后一个动态 alias 何时消失”，适合锁、事务 guard、文件描述符、GPU command/resource 和插件注册责任。
5. **ownership transfer 进入 API 类型。** `consume` 能直接说明 callee 接管责任，conditional consume 也能在 `Result` 中返还 owner；AI 和普通用户都能从 compiler diagnostic 得到反馈。
6. **减少热路径状态检查。** 对真正唯一且局部的 owner，可以不在每个方法前检查 shared tombstone；这通常不是第一动机，但在细粒度高频 FFI 中有价值。
7. **跨 backend 的确定性 cleanup 语义。** 它不依赖 JS/WasmGC 是否提供对象回收通知；compiler 可以在语言管理的控制流出口插入 Drop。

这不是把动态方案推翻。用户显式选择共享后，`Shared[Resource]` 仍然可以退回 last-reference release 和动态 state；affine 只是让“默认唯一责任”不必从一开始就付出共享 control block 的语义与成本。

### 20.4 affine 单独解决不了什么

很多经常被归到“ownership”的问题，其实需要其他轴：

- **parent-child validity**：affine owner 不能独自证明 borrowed child 不超过 parent，需要 lexical borrow、region/lifetime，或动态 anchor；
- **engine 外部失效**：Godot、GUI、数据库或别的 extension 可以在 MoonBit 之外销毁/改变对象，只能靠 liveness callback、ObjectID 或动态检查；
- **共享引用环**：合法共享 graph 中没有 double move，却仍可能形成跨 runtime 环，需要 weak root、disconnect 或 cycle protocol；
- **线程亲和性**：唯一 owner 不表示“允许在哪个线程调用或析构”，需要 isolate、thread token/effect 或 cleanup executor；
- **异步关闭和失败**：Drop 不应隐式 `await` 或吞掉错误，`close_async`、commit/flush 仍须显式；
- **callback 重入与 delayed free**：需要 in-flight counter、Closing/PendingFree 状态和延迟回收；
- **热重载**：affine registration token 能帮助 teardown，但不能发现所有已逃逸到宿主中的 callback 副本，仍需 domain/generation/shim；
- **C contract 写错**：错误 disposer、错误 transfer 条件或把 borrowed 标成 owned，静态系统只会更确定地执行错误契约。

因此“引入 affine”不等于“C binding 资源问题从此解决”。它只覆盖唯一 ownership obligation 这一条轴。

### 20.5 Godot 应采用动态为主、affine capability 为辅

Godot 的资源可以按以下方式分类：

| Godot 类别 | 更合适的 MoonBit 模型 | affine 的价值 |
|---|---|---|
| `Vector`、`Color` 等 POD | 普通 `#valtype` | 无 |
| `String`、`Variant`、`Array` 等 COW/值对象 | 可复制的 managed `NativeValue[T]` | 通常不应 affine |
| `RefCounted`、`Resource` | Godot retain/unref 对应的共享 `Ref[T]` | 共享是本义，不应强制唯一 |
| SceneTree、editor 或外部返回的 `Object/Node` | 可复制的 `Gd[T]` + ObjectID/liveness cell | affine 无法预测 engine 销毁 |
| extension instance、Callable、signal userdata | 动态 `ForeignRoot` + Godot free callback | 交接之前可 affine，交接后必须动态 |
| 新建、尚未交给 SceneTree 的 `Node` | `Owned[T]` 释放责任 + 可借用 `Gd[T]` | 很有价值，但 owner 与对象引用应分离 |
| class/method registration、worker join handle | affine token | 很有价值，适合一次 unregister/join/detach |
| placement-init 的 `Variant` storage、callback box | binding 内部 affine typestate | 很有价值，但不必暴露给普通用户 |
| temporary interior pointer/mutable buffer view | scoped non-escaping borrow 或复制 | 仅有 affine owner 不够 |

最值得注意的是“对象引用”和“释放责任”不必是同一个值：

```moonbit
let owned : Owned[Node2D] = Node2D::new()
owned.set_position(pos)            // 临时借用其中的 Gd[Node2D]
let node : Gd[Node2D] = root.add_child(consume owned)
```

`add_child` 消费的是“如果未托管就负责销毁”的 capability，而不是把 Node 变得永远不可访问。加入 SceneTree 后仍可通过普通、可共享、动态检查 liveness 的 `Gd[Node2D]` 使用它。如果它从未被 attach，`Owned` 的确定性 Drop 负责删除 orphan Node。

即使如此，后续 GDScript 仍可 `remove_child`、reparent 或 `queue_free`；其他 `Gd[T]` aliases 仍必须观察 `Alive -> PendingFree -> Dead` 的动态状态。这说明 affine 只能描述一次责任交接，不能静态复制整个 Godot 世界的生命周期。

### 20.6 不同 C 库给出的答案不同

| 库类型 | 推荐主体 |
|---|---|
| Godot、UI object graph、actor/game object | 动态 shared/foreign handle 为主，少量 affine capability |
| SQLite statement/transaction、文件、socket、锁 guard | affine owner + deterministic Drop 收益很大 |
| LLVM | 混合：Context/Module 的释放责任可 affine；Value/Type 等大量 view 仍需 anchor/borrow；transfer API 受益明显 |
| SDL window/renderer/texture | affine owner 很自然；若 wrapper 广泛共享则转 `Shared` |
| libuv、异步 I/O | 动态状态机和 event-loop affinity 为主，affine 只能表达 close request/registration responsibility |
| Vulkan/GPU API | affine、typestate 和明确 transfer 很有价值，但同步、parent dependency 仍是独立问题 |

Godot 能证明的是“成熟的动态资源系统足以让复杂 binding 生产可用”，不能证明所有 Native 生态都没有确定性 resource semantics 的需求。

### 20.7 对 MoonBit 语言路线的建议

基于已经验证的动态方案，建议把语言路线调整为“互补而非替换”：

通用 affine 不是一个很小的 `Moved` 检查：resource 进入普通 aggregate 后需要 usage-kind propagation；`Option/Result/Array/Map` 和泛型需要表达 element kind；closure capture 会影响 closure 的复制与调用能力；async state 必须在完成、取消和 shutdown 时 structural drop；pattern matching、partial move、typed error、trait object、跨包 `.mbti` 和所有 backend 还要共享稳定的 drop order。若一开始允许 affine value 任意进入 GC heap，几乎会同时触发整套问题。

1. **先把动态车道标准化。** `NativeOwner`、`ForeignHandle/Gd`、`ForeignRoot`、liveness/generation、cleanup queue 和 ownership-aware FFI，无论未来是否有 affine 都需要。
2. **先补低成本的编译器/工具反馈。** `#must_use` owner/result、safe API 裸 handle lint、debug runtime 的 acquire/close stack，以及测试时报告“本应显式关闭却最终由 finalizer 兜底”的资源；同时允许把 `RefCounted` 一类标为 `finalizer_expected`，避免无意义警告。
3. **affine 必须 opt-in。** 只允许明确声明的 `resource`/noncopy owner 进入 affine checking；普通 GC 值、Godot handle 和 shared object 完全不受影响。
4. **第一版只追求高收益闭集。** `consume`、scope Drop、所有控制流出口 cleanup、调用期 non-escaping borrow；暂不承诺完整 Rust lifetime calculus，也可先限制 resource 进入普通容器、closure、async 和 global。
5. **提供明确的动态出口。** `Shared[T]`、engine-owned `Foreign[T]`、weak handle 和显式 `detach/forget`，让库作者能够表达现实中的共享和 ownership handoff。
6. **把 ownership 与 validity/thread/protocol 分轴。** 不要试图让一个 `resource` bit 同时承担 parent lifetime、主线程、async close、typestate 和热重载。
7. **用真实 binding 决定是否继续扩张。** SQLite 检验唯一 owner/close error，llvm.mbt 检验 parent view/conditional transfer，Godot 检验 dynamic invalidation，libuv 检验异步与线程；只有数据证明需要时再引入公开 lifetime parameter。

这也改变了优先级：在 MoonBit 1.0 附近，affine resource 不必成为 Godot 或 llvm.mbt 生产化的前置依赖；但把内部 IR、kind propagation、drop elaboration 和 FFI metadata 设计成未来可承载 opt-in affine，仍然值得。还应注意，把一个已经公开的普通类型日后改成 `resource` 会是明显的 source-compatibility break，因此即使功能延后，也应尽早避免对外承诺错误的复制/ownership 语义。

### 20.8 暂定结论

在 compiler/runtime 已经完善、动态 owner 模式已经标准化的假设下，MoonBit **不需要 affine type 才能做出安全、好用的 Godot binding，也不需要等待 affine 才能建立生产级 Native 生态**。

但 affine resource 仍有独立价值：它让唯一释放责任、确定性 Drop 和 ownership transfer 成为编译器可见的契约，解决动态模型只能在运行期报告的一部分错误，并特别改善 SQLite、文件/socket、锁、GPU 和 registration/task token 一类资源。

最合适的定位不是“未来所有 C binding 都切换到 affine”，而是：

```text
普通 GC/共享/engine-owned 对象
    -> 动态 managed handle

真正唯一、必须确定性履行的资源责任
    -> opt-in affine resource

两者之间
    -> 显式 retain/share/transfer/borrow
```

因此 affine 的必要性从“没有它就无法安全”下降成了“没有它，MoonBit 就缺少一种很有价值但非普遍适用的静态资源抽象”。这仍值得做，但应由真实库驱动、渐进落地，而不是把它作为 GC 语言必须全面接受的一套新世界观。

## 21. llvm.mbt 的用户价值与产品体验边界

### 21.1 好的 binding 交付的不是函数，而是完整任务

用户通常并不想“调用 LLVM”，而是想完成下面某一种任务：

- 把自己语言或 DSL 的 AST 编译成 native object/executable；
- 读取、分析、改写并重新输出 LLVM IR/bitcode；
- 在进程内为表达式、查询或数值 kernel 做 JIT；
- 为编译器实现 debug info、instrumentation、optimization 和 cross compilation；
- 教学、研究或验证一种 code generation 思路。

因此，`llvm.mbt` 的产品单位不应是单个 `LLVMBuildAdd` 或“已经封装了上游接口的百分之多少”，而应是一个可以持续测试和明确承诺的 **usage profile**：用户能从输入一路走到目标产物，中间不必突然掉进裸指针、手写 C glue 或 LLVM CLI。

这也意味着三件事不能混为一谈：

1. **raw 层完整度**：与 LLVM 19 的 `llvm-c` API 机械对齐，给 binding 作者和高级用户 escape hatch；
2. **managed 层正确性**：资源、nullable、ownership transfer、错误和 parent-child validity 不含糊；
3. **workflow 层可用性**：对 AOT、IR tooling、JIT 等具体任务形成短小而完整的主路径。

raw 层可以很完整但非常不好用；safe 层也可以只覆盖一个经过选择的子集，却已经足以支撑生产项目。llvmlite 就明确只暴露经过 Numba/JIT 需求验证的一部分 LLVM binding，这说明“生产可用”完全可以按工作流而非上游函数数量定义。

### 21.2 用户为什么不直接写 C++

真正有说服力的动机不是“MoonBit 调 LLVM 的单个函数比 C++ 更短”。LLVM 的 canonical API、最新能力、文档和自定义扩展能力仍然首先服务 C++。MoonBit 的机会发生在 LLVM 调用的前后：

- parser、AST、typed IR、symbol table、错误树和各种 compiler graph 可以使用 GC、ADT、模式匹配和穷尽检查；
- frontend、middle-end glue 和 backend driver 可以留在同一种语言、同一套包管理和测试体系内；
- 用户不必为少量 backend 代码引入第二套 C++ build、template、ABI 和 ownership 心智模型；
- 相比 Python，最终工具可以是 native executable，具有静态类型，也不依赖 Python runtime 和 extension ABI；
- 相比 Rust，MoonBit 对高度共享、存在环、生命周期不天然呈树形的编译器数据结构可以少一些 lifetime/borrow ceremony；
- `.mbti`、typed error、snapshot test 和窄而清晰的 workflow API，也更容易给普通用户和 AI coding 形成可靠反馈。

MoonBit 官方博客中的 C compiler 实践已经给出了一个现实动机：作者希望用 MoonBit 的代数数据类型、模式匹配和函数式循环写 compiler frontend，同时借助 LLVM binding 获得 native backend。这类“前端天然适合 MoonBit，LLVM 只是最后的 backend service”的用户，才是最自然的首批用户。

这里必须诚实区分竞争边界：

- 若团队要修改 LLVM 本身、实现新 target/backend、使用大量 LLVM C++ internal API，C++ 仍然更合适；
- 若团队需要 Rust 编译期 lifetime/ownership 的最强保证，Inkwell 一类 Rust binding 目前更有优势；
- 若需求只是几行交互式数值原型，Python/llvmlite 的生态和启动体验仍可能更好；
- 若 `llvm.mbt` 仍要求用户理解全部 C ownership、频繁调用 `@unsafe`，再把 IR 写到文本后 shell out 到 `opt`/`llc`，它就只剩“项目碰巧已经使用 MoonBit”这一项动机。

因此 MoonBit 不需要在“接触 LLVM 本身”这件事上胜过 C++；它需要在“完成整个编译器项目”这件事上更舒服。

### 21.3 最值得优先服务的用户和作品

| 优先级 | 用户/作品 | 一条真正完成的旅程 |
|---|---|---|
| P0 | 小语言、DSL、查询或规则编译器作者 | AST → LLVM IR → verify → optimize → object/assembly → link/run |
| P0 | MoonBit 编译器团队和 compiler researcher | codegen 实验、差分测试、目标相关验证、真实 backend 压力测试 |
| P1 | LLVM IR/bitcode 工具作者 | parse `.ll/.bc` → traverse/transform → verify → link/write |
| P2 | JIT/REPL/runtime 作者 | lowering → ORC LLJIT → symbol resolution → typed call → module removal/shutdown |
| P2 | 教学用户 | 从表达式 AST 到真正可执行产物，而不只是在终端打印 IR |

第一类尤其适合作为 `llvm.mbt` 的首个产品定位。典型作品可以是：

- 一个有函数、闭包、结构体和控制流的小语言；
- 查询表达式或正则/规则 DSL 的 native compiler；
- 数值表达式、shader-like language 或模型计算 kernel generator；
- 一个使用 LLVM 做最终 codegen 的 MoonBit compiler frontend；
- 一个可以读取 bitcode、插桩并重新生成 object 的 command-line tool。

其中 compiler/DSL backend 是近期最好的 lighthouse。它同时使用 MoonBit 最有差异的语言能力，也能完整检验 LLVM binding 的类型、错误、资源、pass 和 target 支持。

### 21.4 当前仓库交付到哪里

当前高层 `IR` 包已经具有相当丰富的 IR construction 能力：Context、Module、IRBuilder、常见 Type/Value、basic block、算术、cast、memory、control flow、call、attribute 和 bitcode write 都已经有了基础。它可以支撑非平凡的教学编译器，或者先生成 IR/bitcode、再交给外部 LLVM 工具的原型。

但从用户旅程看，它目前更准确的定位仍是：

> 一个较丰富的 LLVM IRBuilder 原型，加上一套更大的 raw LLVM-C 工具箱。

造成这个判断的不是接口总数，而是主路径在终点前中断：

- high-level `Module` 还没有形成 `verify` 的结构化错误 API；
- PassBuilder/pipeline 没有成为 managed workflow；
- Target、TargetMachine、host/cross triple、CPU/features 和 DataLayout 没有形成正确的高层模型；
- assembly/object emission 没有成为高层一等能力；
- parse IR/bitcode、link module 尚未形成安全的 IR tooling 闭环；
- ORC/LLJIT 没有可运行、受测试且表达 ownership transfer 的高层接口；
- debug info 和生产编译器常见的部分 IR 能力仍缺失；
- `setDefaultDataLayout` 使用固定字符串，而不是由 TargetMachine 产生，这在非对应 target 上不能作为可靠默认值；
- 大量 doc/tutorial 代码仍为 `nocheck` 或 `skip`，JIT 测试也没有启用，因而用户看不到一个持续通过 CI 的完整作品。

所以此时继续增加几十个零散的 `createXxx`，不会显著改变第一次使用的体验。真正的断点是 `构造 → 验证 → 优化 → 目标代码` 没有连起来。

### 21.5 第一条 production profile：AOT compiler backend

建议第一条稳定承诺明确收窄为：

> 使用 MoonBit 编写小语言或 DSL，在一个进程内构造 LLVM IR，验证并优化它，为 host 或指定 target 生成 object/assembly；普通用户全程不接触 `@unsafe`、raw handle、CStr、disposer、手写 DataLayout 或外部 `llc`。

概念上的最小闭环是：

```text
MoonBit AST / typed IR
        ↓
Context + Module + IRBuilder
        ↓
module.verify()
        ↓
target_machine.configure(module)
        ↓
module.optimize(Default(O2), target_machine)
        ↓
target_machine.emit_object(module)
        ↓
system linker / application embedding
```

第一版并不一定要包装 linker/LLD；输出正确的 `.o` 后显式调用系统 linker 是合理边界。但它不应再要求用户输出 `.ll` 后自己调用 `opt` 或 `llc`，因为 verification、optimization 和 codegen 正是 LLVM library binding 应提供的核心价值。

这一 profile 至少需要：

1. 稳定、managed 的 Context/Module/Builder/MemoryBuffer/TargetMachine；
2. 足够表达真实小语言的 IR 子集，包括常用 aggregate、memory、function、control flow、phi 和 ABI 属性；
3. `module.verify()`，错误成为带 message/context 的 MoonBit typed error，而不是打印、abort 或 `(Bool, String)`；
4. host target 与显式 cross target，triple/DataLayout 必须来自 TargetMachine；
5. O0/O1/O2/O3/Os/Oz 等 preset，以及 textual pass pipeline 作为高级 escape hatch；
6. object/assembly 到 file 和 memory buffer 的输出；
7. success、typed error、early return 全路径的可靠资源清理；
8. 一个真实 mini-language fixture，最终链接并执行递归、分支、循环、struct/memory 和函数调用，而不是只 snapshot IR 文本。

LLVM 19 的 New Pass Manager 文档明确说明大部分 PassBuilder 工作流已有 C API，因此这条 AOT 闭环原则上不要求先大规模进入 LLVM C++ API。它主要是 binding 设计、资源契约和端到端验证的问题。

### 21.6 后续 profile 应各自形成闭环

#### IR tooling profile

第二条适合稳定化的旅程是：

```text
parse .ll/.bc
    → inspect/traverse
    → transform/instrument
    → verify
    → link/write .ll/.bc/.o
```

MoonBit 的 enum、pattern matching 和 native CLI 很适合做 IR analyzer、normalizer、instrumenter、reducer 和 build tool。这里需要特别处理 iterator/view、metadata、use-def traversal、parent anchor 和 mutation invalidation，而不只是增加 parser 函数。

#### JIT profile

JIT 长期可能是更有想象力的 showcase：query JIT、数值 DSL、表达式引擎、REPL 和 runtime specialization 都能受益。但它应在 AOT 主路径可靠后单独设计，因为 ORC 引入了更强的协议：

- ThreadSafeContext/ThreadSafeModule；
- `add_module` 的 consumed ownership；
- host symbol 注册与 callback root；
- executable address 到可调用函数的受控转换；
- ResourceTracker、module removal 和 shutdown 顺序；
- isolate/thread affinity、重入和 panic/exception boundary。

一个只有 `lookup` 加裸地址 cast 的示例不是 production JIT API。JIT profile 应有自己的资源模型、并发约束和长期压力测试。

#### Debug information

如果目标是“用户能写真正的编译器”，debug info 不能永远被当作锦上添花。它可以晚于第一个 AOT milestone，但应进入明确的稳定路线；否则用户生成的程序虽然能运行，却很难调试，也很难称为成熟 toolchain backend。

### 21.7 用户 API 应有 workflow 层，而不只是 C++ 对象模型翻译

现有 trait object + enum hierarchy 是合理的实现起点，也能表达 LLVM 的多态对象；但普通用户不应被迫逐项复刻 LLVM C++ 的偶然 plumbing。建议至少形成以下概念层次：

```text
llvm/raw       机械、广覆盖、明确 unsafe 的 LLVM-C 映射
    ↓
llvm/core      managed Context/Module/Value/TargetMachine 等基础对象
    ↓
llvm/pass      verifier 与 optimization pipeline
llvm/target    host/cross target、DataLayout、object/assembly emission
llvm/jit       ORC/LLJIT，单独的生命周期与线程协议
llvm/debug     debug info
    ↓
llvm/workflow  AOT compiler、IR tool、JIT 的窄入口和可靠默认值
```

概念上的用户代码可以接近下面这样；具体命名应经过 MoonBit API 设计，而不是照抄此处：

```moonbit skip
let target = TargetMachine::host(opt_level=O2)
CompilerSession::run(target~, fn(session) {
  let module = session.new_module(name="demo")
  // 从 typed AST lowering；普通代码只使用 managed IR API。
  lower_program(module, program)
  module.verify()
  module.optimize(level=O2)
  module.emit_object(path="demo.o")
})
```

好的主路径还应满足：

- 用户不需要显式 `defer context.close()` 才能获得基本安全；
- nullable 映射成 `Option`，LLVM failure 映射成 typed error；
- safe API 不公开 C allocator 管理的 string、裸 handle 或 disposer；
- ownership transfer 在方法上清楚可见，view 保持 parent anchor；
- `emit`/`optimize` 等边界默认或可配置地执行 verifier；
- builder 尽量用 scoped insertion point、结构化 block helper 消除 `UnsetPosition` 等可避免状态；
- 高频路径保留明确的 advanced/unchecked escape hatch，但不污染教程；
- 命名、label parameter、Option、error 和 iterator 使用 MoonBit 惯例，C++ 风格 API 可以留在 core compatibility 层。

这不是要隐藏所有 LLVM 概念。BasicBlock、phi、DataLayout、calling convention 和 pass pipeline 本来就是用户需要学习的语义；需要隐藏的是 C 字符串分配器、dispose 时机、opaque pointer cast 和初始化调用顺序等 binding 偶然复杂度。

### 21.8 纯 MoonBit IR 可以成为差异点，但不是第一条闭环的前置条件

llvmlite 和 llvm-hs 都提供了一个值得参考的方向：先用宿主语言中的纯 IR model 构造、比较和测试模块，再在边界处转成 native LLVM module，用于 verifier、optimization、JIT 和 codegen。

对 MoonBit 而言，这可以与 MoonLLVM 形成互补：

- 纯 MoonBit IR/AST 适合 snapshot、property test、离线 transform、Wasm/JS 后端和减少 native child handle；
- native LLVM Module 适合解析现有 bitcode、低延迟修改、优化、JIT 和 target codegen；
- 两者之间通过 textual IR、bitcode 或专门 lowering bridge 连接。

这可能成为 MoonBit binding 相比“逐函数 C wrapper”的重要差异点，尤其适合 compiler frontend。但它会带来独立的数据模型、round-trip fidelity 和版本维护成本，因此不应阻塞第一条 direct managed AOT workflow。短期可以先把桥的边界设计清楚，避免 `llvm.mbt` 与 MoonLLVM 互相重复且无法互操作。

### 21.9 明确说明做不到什么

LLVM C API 能支撑常规 IR construction、verification、PassBuilder pipeline、target codegen 和 ORC 的相当大部分常用工作流，但它不等于 LLVM C++ API 的全部能力。

特别是：

- 编写深度集成 AnalysisManager 的自定义 New-PM pass/plugin；
- 实现新的 target/backend、SelectionDAG/GlobalISel 或大量 MC/CodeGen internals；
- Clang AST、MLIR 等独立项目的完整能力；
- LLVM 新增但尚未进入稳定 C API 的内部特性；

这些场景可能需要一个很小、版本固定、经过审计的 C++ shim，或者直接建议用户使用 C++。`llvm.mbt` 应把这条边界公开写清，而不是用“完整 LLVM binding”制造无法兑现的预期。

反过来，只要声明的是“LLVM 19 AOT frontend SDK”或“LLVM 19 IR tooling profile”，即使 safe 层没有包装每个 obscure API，也完全可以是生产可用产品。

### 21.10 怎样判断用户体验已经成立

一个 profile 在宣布 stable 前，至少应该通过以下用户视角验收：

1. 从干净项目安装依赖后，官方首屏示例可以直接生成一个 object 或可执行程序；
2. canonical workflow 中没有 `@unsafe`、裸 handle、手写 CStr/free 或手写 LLVM 初始化顺序；
3. invalid IR、错误 target、错误 pass pipeline 和 emit failure 都产生可处理、可定位的 MoonBit error；
4. README、doc test 和教程代码全部真实 check/run，而不是 `nocheck`、`skip` 或伪代码；
5. mini-language 端到端测试验证的是最终程序行为，不只比较打印出来的 IR；
6. 支持的 LLVM major、平台、architecture、link mode 和 stable/experimental API family 有公开矩阵；
7. 推荐路径在 ASan/LSan 等工具下覆盖成功、失败和 early-return，资源问题不转嫁给普通用户；
8. ordinary user 不需要阅读 `unsafe/wrap.c` 或 LLVM C ownership 文档即可完成声明的 profile；
9. 至少有一个真实 MoonBit compiler/backend 长期使用这条路径，作为设计与回归的 lighthouse。

API 数量、raw 层行覆盖率和“能够链接到 libLLVM”都不能替代这些验收条件。

### 21.11 暂定产品路线

建议按以下顺序投入：

1. **补齐第一条 AOT 纵向闭环**：verify、TargetMachine/DataLayout、PassBuilder、object/assembly emission；
2. **把闭环中的资源和错误做对**：managed owner/view、typed diagnostic、ownership transfer、稳定 cleanup；
3. **用一个完整小语言证明它**：source → parse/typecheck → IR → O2 → object → link → run；
4. **修复 activation 和文档**：让首屏示例及所有教程进入 CI，普通用户不接触 raw 层；
5. **形成 IR tooling profile**：parse、traverse、transform、link、round-trip；
6. **再单独产品化 ORC JIT 和 debug info**；
7. **最后按真实项目需求扩大 safe API 面**，raw 层则持续以生成、ABI audit 和版本对齐追求完整。

最重要的取舍是：近期不要先把每个冷门 LLVM-C 函数都安全包装一遍，也不要把尚未形成资源/线程协议的 JIT 当作首个 marquee。先做成这一件事更能改变项目性质：

> 用户可以只用 MoonBit 写出一个完整的小语言编译器，并用一条受测试的库内路径生成经过优化、可链接和可运行的 native object。

做到这里，`llvm.mbt` 才不再只是“MoonBit 能调用 LLVM”的证明，而会变成“MoonBit 是一门适合实现编译器的语言”的证明。

### 21.12 参考项目与资料

- LLVM 19 Kaleidoscope tutorial（IR、JIT、object code、debug info 的典型用户旅程）：<https://releases.llvm.org/19.1.0/docs/tutorial/MyFirstLanguageFrontend/>
- LLVM 19 New Pass Manager：<https://releases.llvm.org/19.1.0/docs/NewPassManager.html>
- LLVM ORCv2 use cases 与 LLJIT：<https://llvm.org/docs/ORCv2.html>
- llvmlite 的纯 IR 层：<https://llvmlite.pydata.org/en/latest/user-guide/ir/index.html>
- llvmlite 的 native binding 范围：<https://llvmlite.pydata.org/en/stable/user-guide/binding/index.html>
- Inkwell：<https://github.com/TheDan64/inkwell>
- MoonBit C compiler 实践：<https://www.moonbitlang.com/blog/moonbit-c-compiler>

## 22. MoonBit 能否承载工业级 AOT 与 JIT 编译器

### 22.1 先把四个问题分开

这个问题不能用一个“能”或“不能”回答。比较准确的判断是：

| 问题 | 当前判断 |
|---|---|
| MoonBit 的语言表达力能否编写工业级 AOT compiler | **能，没有已知的语言硬阻碍** |
| 当前 checkout 的 `llvm.mbt` 是否已经能直接承担这个任务 | **不能，high-level AOT 闭环尚未完成** |
| MoonBit 能否驱动 module/DSL 级 ORC JIT | **能，LLVM-C 加少量 shim 足够形成核心闭环** |
| MoonBit 能否在当前 runtime 中 JIT 任意 MoonBit 代码并安全热装载/卸载 | **还不能，需要 runtime/module ABI 工作** |

所以推荐的战略并不是“MoonBit 或 C++ 二选一”，而是：

> 编译器主体使用 MoonBit；LLVM-C 是首选边界；真正缺失、过于不稳定或必须进入 LLVM internal 的部分，由一个固定 LLVM 19、导出窄 C ABI 的 C++ shim 承担。

“项目中存在 C++ shim”和“编译器最好直接使用 C++”是完全不同的两件事。

### 22.2 当前 MoonBit LLVM 后端已经证明了 AOT 的可行性

当前 `ideas7/lib/xml/llvm_backend` 本身就是最强的现实证据。它不是一个 Kaleidoscope demo，而是一套约 8.8k 行、正在服务 MoonBit 的 backend：

- 创建 Context、Module 和 TargetMachine；
- 支持 host 或显式 target triple；
- 从 TargetMachine 取得 DataLayout；
- 从 CLAM lowering 到 LLVM IR；
- 生成 debug metadata；
- 调用 verifier；
- 通过 PassBuilder 运行 `default<O0>` 至 `default<O3/Os/Oz>`；
- 输出 LLVM IR、bitcode、assembly 或 object；
- 最后释放 Module 和 Context。

这些关键步骤集中在：

- `ideas7/lib/xml/llvm_backend/llvm_backend.ml:15-107`；
- `ideas7/lib/xml/llvm_backend/llvm_of_clam.ml`；
- `ideas7/lib/xml/llvm_backend/llvm_gen_debuginfo.ml`。

它使用的是 LLVM 官方 OCaml binding。LLVM 19 的 `llvm_ocaml.c` 文件开头明确说明，该层主要是把 OCaml 接到 LLVM C interface，绝大多数函数是对应 C API 的透明 wrapper。当前 MoonBit 内部 LLVM fork 的说明也写着，没有修改 C/C++ API，改动主要在 OCaml binding：`ideas7/lib/xml/llvm_backend/readme.md:48`。

这意味着对 AOT 自举而言，我们不需要证明一个未知命题。真正的任务是：

> 把当前 OCaml backend 实际使用的 LLVM capability profile，在 `llvm.mbt` 中无歧义地重新表达并迁移。

同样的 IR、相同的 pass pipeline、相同的 TargetMachine 和 LLVM build，不会因为调用者是 OCaml、MoonBit、Rust 还是 C++ 而改变最终优化质量。宿主语言主要影响的是编译器实现体验、IR construction 开销、错误和资源可靠性，而不是 LLVM 最终生成机器码的能力。

### 22.3 其他语言的实际路线

成熟项目给出的答案高度一致：主编译器不必是 C++，但也几乎没有必要坚持“永远不写一行 C++ glue”。

| 项目 | LLVM 接入方式 | 说明 |
|---|---|---|
| LLVM 官方 OCaml binding | OCaml runtime glue + LLVM-C | 标准 IR/AOT、TargetMachine、PassBuilder、debug info 均可覆盖；当前 MoonBit backend 即为实例 |
| Crystal | 自举的 Crystal compiler + LLVM-C | LLVM 18 补齐上游 C API 后，Crystal 宣布不再需要原先的 `llvm_ext` wrapper；是“GC 语言自举工业 AOT”的直接先例 |
| Numba/llvmlite | 纯 Python IRBuilder + LLVM-C + 小型 C++ wrapper | 支撑长期使用的数值 JIT；官方明确说只包装 IR builder、optimizer 和 JIT 所需子集 |
| rustc | Rust 主体 + 较大的 `rustc_llvm/llvm-wrapper` | LTO、PGO、sanitizer、coverage、diagnostic 等缺口通过 C ABI wrapper 暴露，并未因此把 rustc 改写成 C++ |
| Zig | Zig 主体/bitcode builder + `zig_llvm.cpp` | shim 开头明确写着：集中所有 LLVM C++ 交互、提供 C interface、防止 C++ 扩散到其余项目 |
| Julia | 高层 compiler/runtime + 大量 LLVM C++ JIT 实现 | 说明 Julia/HotSpot 级 GC、ORC、ABI conversion 和 runtime integration 确实会深入 C++，但这是最复杂的 JIT 档位 |
| llvm-hs | 纯 Haskell IR + native binding/C++ 扩展 | 架构可行；版本停留也反向说明追随 LLVM 全表面的维护成本很真实 |

其中两个结论尤其重要：

1. Crystal 的经历说明，**标准自举 AOT 可以建立在 LLVM C API 上**，不要求 host compiler 使用 C++。
2. llvmlite 的经历说明，**即使 host 是动态 GC 语言，也可以驱动生产规模 JIT**；关键是选择工作流、限制 API 面，并对缺口写小型 shim。

参考：

- LLVM 19 OCaml glue：<https://github.com/llvm/llvm-project/blob/release/19.x/llvm/bindings/ocaml/llvm/llvm_ocaml.c>
- Crystal 1.11 / LLVM 18 C API：<https://crystal-lang.org/2024/01/08/1.11.0-released/>
- llvmlite 架构：<https://github.com/numba/llvmlite>
- rustc LLVM wrapper：<https://github.com/rust-lang/rust/tree/main/compiler/rustc_llvm/llvm-wrapper>
- Zig LLVM shim：<https://github.com/ziglang/zig/blob/master/src/zig_llvm.cpp>
- Julia JIT sources：<https://github.com/JuliaLang/julia/tree/master/src>

### 22.4 什么范围内 LLVM-C 足够

对大多数 language frontend，以下工作可以由 LLVM 19 C API 支撑：

- 构造和解析常规 LLVM IR；
- verifier；
- 默认或 textual New-PM PassBuilder pipeline；
- target discovery、triple、CPU/features、TargetMachine 和 DataLayout；
- object/assembly/bitcode emission；
- debug info 的常规构造；
- module linking、object/bitcode inspection；
- LLJIT 的基本创建、ThreadSafeModule、add module、lookup 和 ResourceTracker remove。

以下场景则很可能需要 C++ shim，或者直接把该子系统写成 C++：

- 编写新的 LLVM target/backend；
- SelectionDAG、GlobalISel、MC 和 CodeGen internal；
- 深度集成 AnalysisManager 的自定义 New-PM pass；
- 精细定制 LTO/PGO/sanitizer/coverage pipeline；
- 尚未进入 C API 的 ORC/JITLink layer、memory manager、platform plugin；
- 深度 Clang/MLIR 集成；
- 高频追随 LLVM trunk，而非固定 LLVM 19。

一个合理边界是：MoonBit 实现语言自己的 frontend、MIR 和 language-specific optimization；LLVM 负责标准优化和 machine code。若某项 LLVM internal 能力确实必要，只为它增加一个 coarse-grained C ABI，而不是让 LLVM C++ object graph 穿透整个 MoonBit compiler。

### 22.5 MoonBit 语言对 AOT 没有结构性短板

MoonBit 当前已有编译器实现所需的主体能力：

- enum/ADT、模式匹配、trait、泛型可以表示 AST、类型、IR 和 pass；
- GC/RC 很适合 symbol/type graph、共享 compiler metadata 和 cache；
- typed error 可以承载 parse/typecheck/codegen diagnostic；
- `extern "C"`、`#valtype`、`FuncRef`、C-compatible struct/enum 和 `#export_name` 足以建立 native ABI；
- native/C backend 可以把 compiler 本身编译成普通 host executable；
- LLVM owner 通常只有 Context、Module、Builder、DIBuilder、Pass options、TargetMachine 等少量根对象，大量 Type/Value/Block 是 parent-owned view，动态 owner/anchor 足以把推荐路径做安全。

缺少 affine type 不妨碍这条路径。AOT compilation session 的生命周期通常接近树形，并且边界清楚：创建 session，构造/验证/优化/输出，然后整体关闭。显式 session close 加 finalizer fallback 已经可以达到很高可靠性。

当前没有完整共享多线程也不是 AOT 的理论阻碍。编译可以先串行、按 module 使用进程并行，未来再把 compilation unit 放入 isolate；这影响吞吐量和架构选择，不影响能否正确生成工业代码。

### 22.6 但“JIT”至少有三个不同难度

| JIT 档位 | 例子 | MoonBit 当前判断 |
|---|---|---|
| J0：native/C ABI kernel JIT | 表达式、query、数值 kernel、另一门 DSL | 可以。JIT code 使用固定 C ABI 或自定义 Value ABI，不直接参与 MoonBit heap |
| J1：受控的 language runtime JIT | module 装载、symbol resolve、调用 host helper、按 generation 卸载 | 语言能力够；需要可靠 LLJIT facade、callback root、generation/liveness 和线程协议 |
| J2：任意 MoonBit code 的长期驻留/tiered JIT | closure、MoonBit heap、热替换、deopt/OSR、并发 runtime | 当前 runtime 尚不具备完整协议 |

因此，“用 MoonBit 写一个 JIT compiler”和“让 JIT 代码成为当前 MoonBit runtime 的动态组成部分”不是同一个命题。

J0/J1 的 entry point 不必是任意地址到任意 `FuncRef[T]` 的 cast。更稳妥的选择包括：

- JIT 函数公开固定、静态的 C ABI；
- 动态语言统一使用类似 `fn(RuntimeContext*, Value*, size_t) -> Status` 的 ABI；
- 由生成的 C trampoline 完成复杂 calling convention 适配；
- 对有限的签名集合提供 typed wrapper/code generation。

高层 JIT lookup 返回的也不应只是裸地址或裸 `FuncRef`，而应类似：

```text
JitFunction[T] {
  address
  session_anchor
  resource_tracker_anchor
  generation
}
```

调用和卸载协议必须保证：只要函数还可能被调用，对应 ResourceTracker/code generation 就不能被移除；移除后所有 handle 能观察到 closed/generation mismatch。这个问题可以用动态状态机解决，不以 affine type 为前提。

### 22.7 当前 MoonBit runtime 对 runtime-aware JIT 的真实缺口

#### 共享多线程

当前新的 Native Machine runtime 仍明确写着 RC 是 non-atomic：

- `ideas7/lib/xml/machine/machine_runtime_lower.ml:2478`。

因此不能把带 MoonBit heap reference 的 closure、callback context 或 AST 任意交给 ORC worker thread。短期可以让 ORC 内部线程只接触 LLVM/C++ owned data，把 callback marshal 回 owner thread；或者使用 worker process。未来 isolate 模型很适合以 module/compilation unit 为边界并行，但需要 attach/detach 和消息协议。

#### panic/ICE 隔离

当前 native runtime 的 `moonbit_panic` 最终 `abort()` 或 `exit()`：

- `~/.moon/lib/runtime.c:619-705`。

对命令行 AOT compiler，这通常可以接受：用户错误必须走 typed diagnostic，panic 代表 ICE，由构建系统观察子进程失败。对嵌入数据库、IDE 或应用进程的 JIT，则不能让一个 compiler callback 杀死宿主。

所有进入 C/ORC 的 callback 都应有 `noraise` 式契约：内部 MoonBit error 转为 status/`LLVMErrorRef`，任何 panic 都不得跨过 FFI 栈。即使 MoonBit 将来能 recover panic，LLVM assertion/fatal error 也未必能安全恢复，因此 worker process/domain 仍可能是工业服务的合理隔离边界。

#### Native backend 的 callback ABI

`ideas7/discussion/machine-native-export-followups.md` 记录了当前 Machine Native export 的实现限制：

- 可达类型中含 `FuncRef`、closure 或 trait object 的 export 仍会被拒绝；
- Unit、V128、aggregate、error carrier 的若干 C ABI thunk 尚未补全；
- C backend 仍能承担一部分现有路径。

这是 native backend 实现待补全，而不是 MoonBit 语法必须增加新抽象。现阶段复杂 ORC callback 可以使用 C backend 或固定 C trampoline；长期应定义稳定 FuncRef C ABI 和双向 thunk。

#### 动态 layout、root 与 module domain

这是“JIT 任意 MoonBit 代码”目前最实质的缺口。当前 native runtime 只有一个进程全局：

```c
const uint32_t *moonbit_layout_table;
```

普通完整 AOT 程序在初始化时把它设置为本程序的 `moonbit_layout_table_data`。对象 header 中存放的是这个 flattened table 的 22-bit word offset：

- `~/.moon/lib/runtime.c:86-99`；
- `ideas7/lib/xml/llvm_backend/llvm_of_clam.ml:392-459`；
- `ideas7/lib/xml/llvm_backend/llvm_of_clam.ml:3610-3635`。

独立 JIT module 若引入新的 heap layout，目前没有安全的动态注册协议。它不能简单替换全局 table，否则既有对象的 layout offset 会被按新 table 解释。类似问题还包括：

- JIT module 的 static root 如何注册和注销；
- initializer/teardown 的调用顺序；
- runtime helper/ABI 的版本兼容；
- callback context 如何 root/unroot；
- module 卸载前如何确认没有 stack frame、closure、function pointer 或 external-object finalizer 仍指向该 generation；
- foreign thread 如何进入和退出 MoonBit runtime。

特别地，如果 external object 的 finalizer 是 JIT code address，而 generation 先被卸载，对象以后 RC 归零就会跳入已释放代码。这不是 ORC ResourceTracker 单独能够解决的。

如果未来要 JIT 完整 MoonBit code，runtime 至少需要明确的 runtime domain/module ABI、动态 metadata/root 注册、generation quiescence 和安全卸载协议。这个缺口完全不影响普通 AOT 自举，也不影响只生成 C ABI kernel 的 JIT。

### 22.8 LLVM ORC C API 本身也需要隔离

LLVM 19 的 `llvm-c/Orc.h` 和 `llvm-c/LLJIT.h` 已经暴露 ThreadSafeContext/Module、ResourceTracker、definition generator、transform layer、add/lookup/remove 等相当多的能力；所以核心 LLJIT 并非只能从 C++ 使用。

但官方 header 同时明确标记这套 C API 为 experimental、not stable，并提示高级语义仍需阅读 C++ 文档。因此不建议直接把整个 ORC C object graph 原样变成面向用户的 MoonBit API。

更稳妥的产品层是项目自己维护一个 LLVM-19-specific JIT facade，例如只导出：

```text
create_engine(config)
add_module(module, resource_group)
define_host_symbols(...)
lookup_typed(...)
remove(resource_group)
shutdown()
```

facade 内部可以优先使用 LLVM-C；遇到 object layer、memory manager、debug/profiler plugin 或错误处理缺口时，再在同一层使用 C++。这样 ORC 版本变化、复杂 ownership transfer 和 callback 协议不会泄漏到普通 MoonBit 用户代码。

### 22.9 当前 llvm.mbt 与“语言可行”不是一回事

当前 `llvm.mbt` 还不能据此称为工业 compiler/JIT backend：

- AOT high-level 尚未接通 verifier、TargetMachine/DataLayout、PassBuilder 和 object emission；
- `LLVMTargetMachineEmitToFile/MemoryBuffer` 仍是注释；
- verifier 尚未完成；
- debug info 主要停留在 raw 层；
- ORC 的 ResourceTracker remove/transfer、ThreadSafeModule operation、WithRT add 等关键接口仍有多处仅保留注释；
- `LLVMOrcDisposeThreadSafeContext` 的绑定符号当前甚至拼成了 `LLMVOrcDisposeThreadSafeContext`：`unsafe/Orc.mbt:1056`；
- LLJIT lookup 把 `LLVMErrorRef` 压成 `None`，丢失工业诊断；
- 当前唯一 JIT test 整体被注释，并以 identity cast 把地址变成 `FuncRef`。

这些证据应得出的结论是“库尚未完成”，而不是“MoonBit 做不了”。

### 22.10 自举应把现有 OCaml backend 当成 executable specification

MoonBit 自举无需等待 runtime-aware JIT，也没有不可解的循环。一个正常 bootstrap 可以是：

```text
已发布的 stage0 moonc
    → 编译 MoonBit 编写的 stage1 compiler + llvm.mbt
    → stage1 使用 LLVM 19 编译 stage2 compiler
    → stage2 再编译 compiler 与完整测试集
```

LLVM SDK 仍是外部 host dependency，不需要跟着 MoonBit 自举。

建议不要先以“覆盖全部 LLVM 19”为自举门槛，而是从当前 OCaml backend 提取精确 capability manifest。当前 backend 大约出现两百余种 `Llvm*` module/function 组合，可以逐项建立：

```text
OCaml binding call
    → 对应 llvm-c symbol / 必要 glue
    → llvm.mbt raw binding
    → managed MoonBit API
    → backend call site
    → differential test
```

迁移时让同一份 CLAM/MIR fixture 分别经过 OCaml backend 和 MoonBit backend，比较：

- verifier 结果；
- canonicalized LLVM IR；
- object/link/run 行为；
- debug info 可用性；
- 不同 target 和 optimization level；
- compile time、peak memory、代码尺寸和运行性能。

stage1/stage2 首先要求语义和测试一致，不必一开始要求 object byte-for-byte 相同；LLVM 的 nondeterminism、路径、时间戳和并行因素需要单独规范化。

这会把“llvm.mbt 是否能支撑工业编译器”从抽象争论变成一份可以逐项关闭的迁移矩阵。

### 22.11 最终建议

如果 MoonBit compiler 的设计是：在 MoonBit MIR 中完成语言特定优化，然后把 LLVM 当作验证、通用优化和机器码生成后端，那么**没有理由为了工业级而把整个 compiler 改写成 C++**。当前 OCaml backend 和 Crystal 已经证明 AOT；llvmlite 证明了受控 JIT。

若目标升级为 Julia/HotSpot 级别的 tiered JIT、deopt/OSR、GC safepoint、复杂 ORC layer 和热卸载，那么需要的是：

- MoonBit runtime/module ABI 的建设；
- isolate/thread 与 panic/domain 隔离；
- 版本固定的 C++ JIT shim；
- 大量 compiler/runtime 工程。

这仍不意味着 parser、type checker、MIR optimizer 和整个 compiler driver 应该使用 C++。

最后可以把判断压缩成三句话：

1. **MoonBit 自举 AOT：能做，而且可以从当前 OCaml backend 直接迁移，不需要等待 affine type。**
2. **工业级 module/DSL JIT：语言能力够，但 `llvm.mbt` 当前实现还远远不够。**
3. **任意 MoonBit code 的 runtime-aware JIT：目前真正缺的是动态 runtime domain/metadata/ABI，而不是 LLVM binding 的函数数量。**
