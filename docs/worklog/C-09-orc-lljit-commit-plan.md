# ORC LLJIT host 执行闭环的 commit 划分

> 状态：计划中
> 日期：2026-08-13

本轮按照 [T-07](../discussion/T-07-orc-lljit-kaleidoscope-execution.md) 与
[Q-22](../discussion/Q-22-orc-lljit-initial-scope.md) 至
[Q-31](../discussion/Q-31-lljit-explicit-close.md) 已采用的方案，重建仓库中早期的 ORC 草稿，形成一条 host-only LLJIT 闭环：从安全 `IR::Module` 建立独立 bitcode 快照，提交给当前进程内的 LLJIT，查找并调用符号，并通过可选 `ResourceTracker` 显式卸载临时代码。

旧 `internal/raw/LLJIT.mbt`、`internal/raw/Orc.mbt` 和 `test/jit_test.mbt` 只是未完成草稿，不构成兼容契约。本轮可以删除错误或未使用的旧声明，按 LLVM 22.1 的真实 ownership 和 error 语义重新建立最小 binding。

## 本轮范围

纳入本轮：

- `IR::Module::writeBitCodeToBytes()` 中性内存快照接口；
- host LLJIT 创建、target triple、DataLayout、main JITDylib 和销毁；
- ThreadSafeContext、ThreadSafeModule 和 ResourceTracker 的最小 raw binding；
- 独立公开的根目录 `JIT` package；
- 默认 tracker 与显式 tracker 两种 Module 提交路径；
- main JITDylib symbol lookup、`JITAddress` 和泛型 unsafe `FuncRef` 转换；
- LLVM Error 的集中消费、typed `JITError` 和显式 `close()`；
- LLVM 22.1 默认 `CurrentProcess` 符号行为，以及 `sin` 等宿主动态库符号的实际执行测试；
- macOS ARM64 与 Linux x86_64 上由现有 CI 运行的同步 JIT 测试。

明确不纳入本轮：

- cross-target JIT、自定义 `LLJITBuilder`、自定义 TargetMachine；
- 公开 `ProcessSymbolPolicy`、`AllowList`、`Disabled` 或对应 C++ shim；
- absolute symbol 注册、任意 MoonBit closure callback、自定义 JITDylib；
- object-file 提交、lazy compilation、并发编译、object cache 和 PassBuilder 优化；
- Kaleidoscope lexer、parser、AST、codegen 或 REPL；
- async、子进程、系统 linker 或 CI workflow/coverage 门槛改动。

`CurrentProcess` 首期直接使用 LLVM 22.1 默认 LLJIT builder 的行为，不重复安装 process-symbol generator。Q-27 的长期策略只体现在 owner/构造路径不封死扩展位置；本轮不会公开一个实际上只有单一可用取值的配置 enum。

## package 边界

```text
IR  ───────────────> internal/raw
JIT ───────────────> internal/raw
JIT ───────────────> IR
test ──────────────> IR + JIT
```

- `JIT` 位于仓库根目录，公开 package 路径为 `Kaida-Amethyst/llvm/JIT`。
- 根目录 package 可以导入本模块的 `internal/raw`，不需要让 raw handle 出现在 `IR` 或 `JIT` 的 `.mbti` 中。
- `IR` 不依赖 `JIT`；它只增加通用的 bitcode bytes 快照能力。
- `JIT` 只通过 `IR::Module::writeBitCodeToBytes()` 读取 Module，不访问 `IR` 私有 owner 或 raw ref。
- `moonbitlang/async` 不进入 `JIT`；创建、提交、lookup、调用和 remove 都是当前进程内的同步操作。

## 拟冻结的公开契约

| 公开对象 | 本轮契约 |
| --- | --- |
| `IR::Module::writeBitCodeToBytes()` | 借用 Module，返回独立 `Bytes`；不修改 Module，也不把 memory-buffer owner 暴露给用户。 |
| `JITError` | 按创建、快照/解析、提交、lookup/materialization、tracker remove、close 六个 LLVM 阶段保存诊断，并为 closed、tracker removed 和 owner mismatch 提供独立生命周期错误。 |
| `LLJIT` | host-only managed owner；`host()` 自动复用 `TargetRegistry::initializeNativeCodegen()`，默认使用 LLVM 22.1 的 `CurrentProcess` 行为。 |
| `LLJIT::getTargetTriple()` | 返回 LLJIT 的 host target triple；LLVM 返回非法 UTF-8 时沿用 `IR::StringError`。 |
| `LLJIT::getDataLayoutStr()` | 返回 LLJIT DataLayout string；不向用户暴露 borrowed C string。 |
| `LLJIT::createResourceTracker()` | 为 main JITDylib 创建显式 tracker，并使 tracker 锚定同一个 LLJIT owner。 |
| `LLJIT::addModule(module, tracker?)` | 借用原 Module 并提交独立 bitcode 快照。缺省 tracker 时资源持续到 LLJIT 销毁；显式 tracker 可以归组多次提交。 |
| `LLJIT::lookup(name)` | 在 main JITDylib 查找，成功返回锚定 LLJIT owner 的 `JITAddress`；unknown symbol 和 materialization failure 都是带诊断的错误，不返回 `None`。 |
| `JITAddress` | 保存当前进程 executor address 和 LLJIT owner，不公开 raw ORC type，也不声称能够证明符号 ABI。 |
| `JITAddress::unsafeToFuncRef[T]()` | 只做显式 unsafe 地址转换；调用者负责证明 `T`、calling convention、平台 ABI 和代码生命周期全部匹配。 |
| `ResourceTracker::remove()` | 一次性显式卸载该 tracker 的全部资源；不依赖 GC 自动 remove。 |
| `LLJIT::close()` | 确定性结束 session 并返回 dispose 诊断；成功或失败后都保持 closed，finalizer 只作未 close 时的 fallback。 |

计划公开的 `JITError` 构造器固定为：

```moonbit
pub suberror JITError {
  CreationFailed(String)
  SnapshotFailed(String)
  SubmissionFailed(String)
  LookupFailed(String)
  ResourceRemovalFailed(String)
  CloseFailed(String)
  Closed
  ResourceTrackerRemoved
  ResourceTrackerOwnerMismatch
}
```

LLVM 诊断在 raw 边界复制为 MoonBit `String` 后立即释放原 error message。`lookup` 名称中的 embedded NUL 不伪装成 ORC lookup failure，继续抛出 `IR::StringError::ContainsNul`；因此该方法会公开传播 `JITError` 与 `IR::StringError` 两类错误。

计划公开的方法形状为：

```moonbit
pub fn LLJIT::host() -> LLJIT raise JITError
pub fn LLJIT::getTargetTriple(Self) -> String raise
pub fn LLJIT::getDataLayoutStr(Self) -> String raise
pub fn LLJIT::createResourceTracker(Self) -> ResourceTracker raise JITError
pub fn LLJIT::addModule(Self, @IR.Module, tracker? : ResourceTracker) -> Unit raise JITError
pub fn LLJIT::lookup(Self, String) -> JITAddress raise
pub fn LLJIT::close(Self) -> Unit raise JITError
pub fn ResourceTracker::remove(Self) -> Unit raise JITError
pub fn[T] JITAddress::unsafeToFuncRef(Self) -> FuncRef[T] raise JITError
```

实现时按仓库 C++ 风格补回参数名和文档，不把上面的简写原样复制为源码。两个 getter 会同时传播 `JITError::Closed` 与 `IR::StringError::MalformedUtf8`，`lookup` 会同时传播生命周期/LLVM lookup 错误与 `IR::StringError::ContainsNul`，因此三者使用开放 `raise`；其余函数应按 `docs/style-guide.md` 标出精确错误类型。

## Module 提交与 target 契约

`addModule` 固定按以下顺序工作：

1. 检查 LLJIT 仍 open；若传入 tracker，先检查它属于同一 LLJIT 且尚未 remove。
2. 调用 `Module::writeBitCodeToBytes()`，得到与原 Module 生命周期独立的 bytes。
3. 在新的 `LLVMContextRef` 中解析 bitcode，再从该 context/module 建立 ThreadSafeContext 和 ThreadSafeModule。
4. 在每个失败分支释放尚未转移的 memory buffer、context、module、ThreadSafeContext 或 ThreadSafeModule。
5. 调用 `LLVMOrcLLJITAddLLVMIRModule` 或 `LLVMOrcLLJITAddLLVMIRModuleWithRT`；一旦进入该调用，ThreadSafeModule 按 LLVM-C 契约被消费，成功或失败后都不得再次 dispose。

提交不隐式调用 `Module::verify()`，文档和示例仍推荐用户先显式 verify。LLJIT 只在独立快照上应用 LLVM C++ `LLJIT::applyDataLayout` 的原生规则：

- 默认 DataLayout 自动补成 JIT DataLayout；
- 非默认且不兼容的 DataLayout 返回 `SubmissionFailed`；
- target triple 不被安全层强制覆盖；
- 原 Module 的 triple、DataLayout、IR 内容和 owner 状态始终不变。

## owner 与失效模型

```text
LLJITOwner(open)
  ├── LLJIT aliases
  ├── ResourceTrackerOwner(active) ──owns client RT ref
  └── JITAddress ──stores executor address

close()
  ├── invalidate/release every live client RT ref exactly once
  ├── take LLJIT raw handle and mark owner closed
  └── dispose LLJIT and consume its LLVMErrorRef
```

- 所有 `LLJIT` alias 共享一个 control block；任一 alias close 后，其他 alias 观察到同一 closed 状态。
- `ResourceTracker` finalizer 只 `LLVMOrcReleaseResourceTracker`，不调用 remove。未显式 remove 的资源仍由默认 tracker/LLJIT 管理至 session 结束。
- 显式 close 允许在 `ResourceTracker` wrapper 仍存活时发生。因此 LLJIT owner 必须登记 live tracker control block，在 dispose LLJIT 前集中使其失效并释放客户端引用；之后 tracker finalizer 不得再次 release。
- `ResourceTracker::remove()` 成功后进入 removed 状态；重复 remove、使用 removed tracker 提交，或把另一个 LLJIT 的 tracker 传入 `addModule`，都在进入 LLVM 前报告生命周期错误。
- `JITAddress` 锚定 LLJIT，可阻止 GC 隐式销毁 session；显式 close 或对应 tracker remove 后，地址仍可能数值存在但已失效。
- `unsafeToFuncRef` 在转换前检查 LLJIT 未 close，但普通 `FuncRef` 无法继续持有 owner，也无法在调用时检测 tracker 是否已 remove。文档必须要求调用期间保持 `JITAddress` 可达，并禁止在 remove/close 后调用既有 `FuncRef`。
- 本轮不承诺同一 session 上并发 add/lookup/remove/close；公开文档要求对这些状态操作串行调用或由用户提供外部同步。

## Commit 1：提交 ORC LLJIT 实施计划

涉及文件和对象：

| 文件 | 对象 |
| --- | --- |
| `docs/worklog/C-09-orc-lljit-commit-plan.md` | 本轮范围、公开契约、owner 状态、commit 边界、测试门槛和人工审核点 |

- [x] 提交本文档；T-07 与 Q-22～Q-31 已由前一个 discussion commit 独立提交。
- [x] 不包含 MoonBit、C、manifest、测试、生成接口或构建脚本改动。
- [x] 确认本轮没有把 Kaleidoscope 本身或 Q-27 的后续策略能力混入计划。

建议提交信息：`docs: plan ORC LLJIT implementation`

## Commit 2：增加中性的内存 bitcode 快照

涉及文件和对象：

| 文件 | 公开对象或职责 |
| --- | --- |
| `internal/raw/BitWriter.mbt` | `LLVMWriteBitcodeToMemoryBuffer` 与精确 bytes copy 的 raw 入口 |
| `internal/raw/bitcode.c` | 复制 pointer+length，并在返回前 dispose `LLVMMemoryBufferRef` |
| `internal/raw/moon.pkg` | 注册 bitcode native stub |
| `IR/Module.mbt` | `pub fn Module::writeBitCodeToBytes` 及文档 |
| `test/bitcode_test.mbt` | 仅使用公开 IR API 的快照黑盒测试 |
| `IR/pkg.generated.mbti`、`internal/raw/pkg.generated.mbti` | 由 `moon info` 生成并审核 |

- [x] 返回的 `Bytes` 与 Module/memory buffer 完全独立，并保留 bitcode 中的任意二进制字节和 embedded NUL。
- [x] C adapter 使用 `LLVMGetBufferStart` + `LLVMGetBufferSize`，不把 bitcode 临时转成 `String`。
- [x] `LLVMWriteBitcodeToMemoryBuffer` 产生的 buffer 在同一调用内精确 dispose 一次。
- [x] 测试确认 bytes 非空、重复快照稳定、操作前后 Module 文本及 target 配置不变。
- [x] `.mbti` 只增加一个中性的 `Module` 方法，不暴露 `LLVMMemoryBufferRef`。

建议提交信息：`IR: add in-memory bitcode snapshots`

## Commit 3：重建 LLJIT 创建、查询、lookup 和 Error raw 边界

涉及文件和对象：

| 文件 | 公开对象或职责 |
| --- | --- |
| `internal/raw/Error.mbt` | non-null `LLVMErrorRef` 的集中 consuming adapter |
| `internal/raw/LLJIT.mbt` | default builder 创建、dispose、triple/layout/global-prefix/main-JD、lookup |
| `internal/raw/Types.mbt` | 仅保留本轮需要且 ABI 正确的 ORC address/ref 表示 |
| `internal/raw/orc.c` | out-parameter、NULL、LLVM Error message copy/dispose 等 C 适配 |
| `internal/raw/orc_wbtest.mbt` | 创建/查询/lookup/error 消费白盒测试 |
| `internal/raw/moon.pkg`、`internal/raw/pkg.generated.mbti` | native stub 与生成接口 |

- [x] 删除旧草稿中打印后 panic、把 lookup error 压成 `None`、拼错 C symbol 或不完整的 helper。
- [x] `LLVMOrcCreateLLJIT` 的 builder ownership、out result 与 error 三者在成功/失败路径都准确。
- [x] target triple、DataLayout 和 global prefix 在 owner 有效期间复制，不向上层返回 borrowed C pointer。
- [x] lookup 保留完整 executor address；非空 error 由单一 adapter 调用 `LLVMGetErrorMessage` 消费，再配对 `LLVMDisposeErrorMessage`。
- [x] raw 测试覆盖 host LLJIT 创建/销毁、查询值、未知符号诊断、`StringError` 人工 error 的一次性消费和重复 session。
- [x] 本 commit 仍不增加安全 `JIT` package。

建议提交信息：`raw: rebuild LLJIT and ORC error bindings`

## Commit 4：接通 ThreadSafeModule 与 ResourceTracker raw ownership

涉及文件和对象：

| 文件 | 公开对象或职责 |
| --- | --- |
| `internal/raw/Orc.mbt` | ThreadSafeContext/Module、ResourceTracker 创建/transfer/remove/release |
| `internal/raw/LLJIT.mbt` | 默认 JD 与显式 RT 的两种 IR Module add 入口 |
| `internal/raw/orc.c` | bytes -> independent context/module/TSM 的失败清理 adapter |
| `internal/raw/orc_wbtest.mbt` | TSC/TSM 转移与 tracker 引用计数白盒测试 |
| `internal/raw/pkg.generated.mbti` | 由 `moon info` 生成并审核 |

- [ ] 只保留首期真正使用的 ORC-C 表面；大段未实现的上游 header 注释和错误旧声明不继续作为伪 binding 保留。
- [ ] bitcode 在独立 `LLVMContextRef` 中解析，不复用或消费安全 IR 的 context/module。
- [ ] 明确记录 `LLVMOrcCreateNewThreadSafeContextFromLLVMContext`、`LLVMOrcCreateNewThreadSafeModule` 与 add 调用的 ownership 转移点。
- [ ] 在 add 前失败时释放 TSC/TSM；进入 add 后按 LLVM-C 契约视为已消费，错误路径不重复 dispose。
- [ ] raw 测试覆盖 default tracker、显式 tracker、多次提交、transfer、remove、release 和不同销毁顺序。
- [ ] 验证 LLVM 22.1 默认 builder 已能 lookup `sin` 等当前进程符号，不重复安装 generator。

建议提交信息：`raw: bind ORC module and resource ownership`

## 检查点一：审核 raw FFI 与快照边界

完成 Commit 2～4 后暂停，人工重点检查：

- `writeBitCodeToBytes` 是否真是中性 IR 能力，是否没有 JIT 类型或 raw handle 泄漏到 `IR.mbti`。
- bytes、memory buffer、context、module、TSC、TSM、tracker 和 `LLVMErrorRef` 的每条成功/失败路径是否都有唯一 owner。
- TSM 是否在进入 add 后无条件视为 consumed，错误处理是否可能 double-dispose。
- LLVM Error message 是否在同一边界完成 copy + dispose，是否仍有打印/panic/`None` 丢诊断的旧路径。
- 当前进程符号是否依赖 LLVM 22.1 default builder，而不是被重复 generator 掩盖。
- 删除旧 `Orc.mbt` 草稿时，是否只删除未完成绑定，没有误伤已被其他 package 使用的 raw API。

## Commit 5：建立公开 JIT package、JITError 与 LLJIT owner

涉及文件和对象：

| 文件 | 公开对象或职责 |
| --- | --- |
| `JIT/moon.pkg` | 导入 `IR` 与 `internal/raw`，配置 native stub/link flags |
| `JIT/Error.mbt` | `pub suberror JITError` 及全部构造器文档 |
| `JIT/LLJIT.mbt` | `pub struct LLJIT`、`host`、triple/layout getter、`close` |
| `JIT/resource_owner.mbt`、`JIT/resource_owner.c` | open/closed control block、finalizer fallback 和 take-once dispose |
| `JIT/resource_owner_test.c`、`JIT/resource_owner_wbtest.mbt` | alias、显式 close 和 finalizer trace |
| `JIT/pkg.generated.mbti` | 由 `moon info` 生成并审核 |

- [ ] `LLJIT::host()` 复用 `IR::TargetRegistry::initializeNativeCodegen()`，把初始化失败转换为 `CreationFailed` 的稳定诊断，再创建 LLVM 22.1 default host LLJIT。
- [ ] `JITError` 精确采用本计划列出的阶段与生命周期构造器，不公开 raw error/category id。
- [ ] 所有 LLJIT alias 共享一个 owner；首次 close 在调用 LLVM 前先 take raw 并标记 closed。
- [ ] dispose 成功或失败后均保持 closed；重复 close 返回 `JITError::Closed`，不第二次进入 LLVM。
- [ ] finalizer 只清理仍 open 的 owner，并消费无法上抛的 dispose error；已 close owner 不再 dispose。
- [ ] getter 在 close 后返回 `Closed`，并在复制 LLVM 字符串后映射非法 UTF-8。
- [ ] 所有 `.mbti` 中的 pub type、suberror、constructor 和 fn 都有符合 style guide 的文档；本 commit 不出现 ResourceTracker/JITAddress 半成品。

建议提交信息：`JIT: add managed host LLJIT sessions`

## Commit 6：建立 ResourceTracker owner 与显式 remove

涉及文件和对象：

| 文件 | 公开对象或职责 |
| --- | --- |
| `JIT/ResourceTracker.mbt` | `pub struct ResourceTracker`、`LLJIT::createResourceTracker`、`remove` |
| `JIT/resource_owner.mbt`、`JIT/resource_owner.c` | live tracker 登记、active/removed/closed 状态与 release-once |
| `JIT/resource_owner_test.c`、`JIT/resource_owner_wbtest.mbt` | tracker alias、remove、release 和 close 顺序测试 |
| `JIT/pkg.generated.mbti` | 由 `moon info` 生成并审核 |

- [ ] tracker control block 持有 LLJIT owner，并登记到 session 的 live tracker 集合。
- [ ] tracker finalizer 只 release 客户端引用且不 remove；有资源但未 remove 时仍由 LLJIT 管理。
- [ ] remove 成功后统一使 aliases 观察到 removed；重复 remove 在进入 LLVM 前返回 `ResourceTrackerRemoved`。
- [ ] close 先集中使所有 live tracker 失效并 release 一次，再 dispose LLJIT；之后的 tracker finalizer 不重复 release。
- [ ] close 后 create/remove 返回 `Closed`；finalizer 路径不向 stdout/stderr 打印普通诊断。
- [ ] 测试设施只观察事件，不取得或延长生产 owner 生命周期。

建议提交信息：`JIT: add managed resource trackers`

## Commit 7：公开 bitcode 快照提交

涉及文件和对象：

| 文件 | 公开对象或职责 |
| --- | --- |
| `JIT/Module.mbt` | `pub fn LLJIT::addModule` 与提交阶段文档 |
| `JIT/resource_owner.mbt`、`JIT/resource_owner.c` | 原子取得 session/tracker raw handle 的状态检查 |
| `JIT/module_wbtest.mbt` | snapshot parse、提交转移和错误注入白盒测试 |
| `test/jit_test.mbt`、`test/moon.pkg` | 只用公开 IR/JIT API 的提交黑盒测试 |
| `JIT/pkg.generated.mbti`、`test/pkg.generated.mbti` | 由 `moon info` 生成并审核 |

- [ ] `addModule` 先验证 session、tracker state 与 owner identity，再建立 bitcode 快照。
- [ ] 缺省 tracker 走 main JITDylib；显式 tracker 走 `AddLLVMIRModuleWithRT`，一个 tracker 可承载多次提交。
- [ ] 另一个 session 的 tracker 返回 `ResourceTrackerOwnerMismatch`，removed tracker 返回 `ResourceTrackerRemoved`，两者都不进入 LLVM。
- [ ] snapshot parse、DataLayout 不兼容和 ORC add error 分别映射到 `SnapshotFailed`/`SubmissionFailed`，并保留可用诊断。
- [ ] `addModule` 不调用 verifier、不覆盖 triple；默认 DataLayout 只在 JIT 快照内部由 LLJIT 补齐。
- [ ] 测试确认提交后原 Module、Function 和 Context 仍可使用，原 Module 的 IR/triple/layout 没有改变。

建议提交信息：`JIT: submit independent IR module snapshots`

## 检查点二：审核公开 API 与生命周期

完成 Commit 5～7 后暂停，人工重点检查：

- `JITError` 的公开构造器和各方法错误类型是否足够稳定，是否把 LLVM 内部类别泄漏成公开 API。
- `LLJIT`、`ResourceTracker` 是否都是 opaque managed wrapper；`.mbti` 是否没有 raw ref、owner control block 或 public builder。
- explicit close 与 finalizer fallback 是否共享 take-once 逻辑；close error 后是否仍然 closed。
- close、tracker finalizer、remove 和 alias 的任意顺序是否最多 dispose/release 一次。
- `addModule` 的 optional tracker 形状是否保持 Q-25 的单一接口，而没有额外 `JITModule` 或 `addTrackedModule`。
- 原 IR Module 是否完全独立；是否没有为了提交引入 moved/invalid 状态或跨 package 私有 raw 桥接。
- Q-30 的显式 verify 和原生 DataLayout 兼容规则是否在文档、实现、测试三处一致。

## Commit 8：公开 lookup、JITAddress 与 unsafe FuncRef 转换

涉及文件和对象：

| 文件 | 公开对象或职责 |
| --- | --- |
| `JIT/Address.mbt` | `pub struct JITAddress`、`unsafeToFuncRef[T]` 及完整 Safety/Lifecycle 文档 |
| `JIT/LLJIT.mbt` | `pub fn LLJIT::lookup` |
| `test/jit_test.mbt` | `double () -> 42.0` 的真实机器码调用与 unknown symbol 测试 |
| `JIT/pkg.generated.mbti` | 由 `moon info` 生成并审核 |

- [ ] lookup 在进入 C 前拒绝 embedded NUL，并保留为 `IR::StringError::ContainsNul`。
- [ ] unknown symbol 与 materialization failure 返回 `LookupFailed(String)`，不转换成 `None`。
- [ ] `JITAddress` 只保存 executor address 与 LLJIT owner；它没有 disposer，也不声称锚定具体 tracker。
- [ ] 泛型转换只在 session open 时进行，并明确使用当前 host 的 64-bit function-pointer ABI；不新增固定签名 trampoline 集合。
- [ ] 文档逐项说明签名/calling convention/platform ABI、owner 可达性、remove/close 后失效和普通 FuncRef 不保活。
- [ ] 若当前 MoonBit 编译器无法把 `UInt64` executor address 泛型转换为 `FuncRef[T]`，停止本 commit 回到 discussion；不得静默改成 Q-26 已否决的固定签名 API。
- [ ] 黑盒测试实际调用 JIT 生成的 `double ()` 机器码并得到 `42.0`，而不是只检查非零地址或 IR 文本。

建议提交信息：`JIT: look up and invoke JIT symbols`

## Commit 9：补齐跨 Module、宿主符号与快照隔离测试

涉及文件和对象：

| 文件 | 测试范围 |
| --- | --- |
| `test/jit_execution_test.mbt` | 跨 Module 调用、`sin` 宿主符号、默认/显式 tracker 和快照隔离 |
| `JIT/README.md` | host-only 使用流程、显式 verify、unsafe 调用与 unload 顺序 |

- [ ] 一个默认-tracker Module 定义永久函数，另一个 Module 调用它并实际返回预期结果。
- [ ] JIT IR 声明并调用 `sin`，证明 LLVM 22.1 默认 `CurrentProcess` 在 macOS ARM64/Linux x86_64 可用。
- [ ] 提交后修改原 Module 不影响既有 JIT 快照；销毁原 Module/Context 也不影响 JIT 代码。
- [ ] 未显式配置 DataLayout 的普通 Module 可提交，原 Module 仍保持默认 layout；显式不兼容 layout 得到提交错误。
- [ ] 一个 tracker 管理多次提交并整体 remove；默认 tracker 的函数在其他临时 tracker remove 后仍可查找。
- [ ] tracker remove 后相关符号 lookup 失败；测试不会在 remove 后调用旧 FuncRef。
- [ ] README 不把 unsafe conversion 描述为类型安全调用，也不承诺 sandbox 或 arbitrary callback。

建议提交信息：`test: cover JIT execution and snapshot isolation`

## Commit 10：补齐错误与生命周期强度测试并收尾

涉及文件和对象：

| 文件 | 测试或文档范围 |
| --- | --- |
| `JIT/resource_owner_test.c`、`JIT/resource_owner_wbtest.mbt` | take-once、finalizer fallback、close/remove/release trace |
| `JIT/module_wbtest.mbt` | snapshot/add/remove/close 失败分支与资源清理 |
| `test/jit_lifecycle_test.mbt` | public alias、重复操作、wrong owner、重复 session |
| `README.md` | 增加 JIT package 入口与 Kaleidoscope 前置能力说明 |

- [ ] 覆盖 LLJIT alias close、close-after-close、tracker alias remove、remove-after-remove、add-after-remove 和 add-with-foreign-tracker。
- [ ] 覆盖先丢 tracker、先 close LLJIT、地址仍存活、owner 以不同顺序离开作用域，确认无 double-free/use-after-free。
- [ ] 覆盖 close 后 lookup/add/create-tracker/unsafe conversion 都报告 `Closed`。
- [ ] 用仅测试可见的注入或 observer 覆盖 close/remove error 的消费和 typed mapping；生产 API 不增加测试开关。
- [ ] 同一进程反复创建、提交、执行、remove、close 多个 session，确认 process-global 初始化可重复组合。
- [ ] 非法或无法 materialize 的 Module 在正确阶段返回诊断，且每个 `LLVMErrorRef` 只消费一次。
- [ ] README 明确这些测试通过后可以开始 `examples/kaleidoscope`，但本 commit 不创建该示例。

建议提交信息：`test: harden JIT lifecycle and errors`

## 检查点三：审核 unsafe 调用与 Kaleidoscope 开工门槛

完成 Commit 8～10 后暂停，人工重点检查：

- `JITAddress` 与 `unsafeToFuncRef[T]` 是否准确对应 C++ `ExecutorAddr::toPtr<T>()`，是否没有暗示 LLVM 会验证 ABI。
- owner 可达性、tracker remove、LLJIT close 与普通 FuncRef 的悬空风险是否在 API 文档和 README 中足够醒目。
- 测试是否真实执行了 `42.0`、跨 Module 调用和 `sin`，而不是只验证 handle/address。
- unknown symbol、materialization、DataLayout、remove 和 close 是否能由错误构造器区分并保留诊断。
- macOS ARM64 与 Linux x86_64 是否都经过同一 public test；是否没有用平台 skip 掩盖 process-symbol 问题。
- 首期是否仍严格 host-only、同步且采用 LLVM 默认 CurrentProcess，没有偷渡 absolute symbols、callback、策略 enum 或高级 ORC 类型。

## 每个 commit 的验收要求

Commit 1 仅修改本文档：

- [x] `git diff --check` 通过。
- [x] 不包含代码、测试、依赖、生成接口或构建改动。

Commit 2～10 每次提交前：

- [ ] 运行 `moon info && moon fmt`，生成文件不手工修改。
- [ ] 审核所有 `.mbti`；只允许出现当前 commit 明确列出的公开对象变化。
- [ ] 运行 `moon check --target native`。
- [ ] 运行当前 commit 对应的最小 package 测试，再运行 `moon test --target native`。
- [ ] 运行 `git diff --check`，确认没有临时 bitcode、object、可执行文件、core dump 或测试目录进入提交。
- [ ] 检查每个 C FFI 入口的对应 MoonBit extern 注释，以及 NULL、borrow、take、ref-count、error 和 finalizer 契约。
- [ ] 检查所有 JIT public struct、suberror、constructor、fn 和 impl 都有文档；raw package 仍遵循 style-guide 例外。
- [ ] JIT 测试保持同步，不引入 async、process 或外部编译器。

最终验收：

- [ ] `moon info && moon fmt`。
- [ ] `moon check --target native`。
- [ ] `moon test --target native -p internal/raw`。
- [ ] `moon test --target native -p test`。
- [ ] `moon test --target native`。
- [ ] 现有 CI 在 macOS ARM64 与 Linux x86_64 上实际通过 JIT 执行测试。

如果实现中发现 LLVM 22.1 实际 ownership 与本文/Q 文档不一致、MoonBit 无法表达泛型 FuncRef 转换、close 无法在 live tracker 存在时安全失效，或 Linux 默认 CurrentProcess 无法解析 `sin`，应停止对应 commit 并回到 discussion。不得通过泄漏 raw handle、跳过平台测试、自动忽略 close/remove 错误或改成固定签名 API 来绕过契约。
