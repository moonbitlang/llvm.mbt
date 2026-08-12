# Native object emission 的 commit 划分

> 状态：计划中
> 日期：2026-08-12

本轮按照 [Q-16](../discussion/Q-16-native-object-emission-scope.md) 至 [Q-21](../discussion/Q-21-native-object-execution-test.md) 已采用的方案，建立第一条 host-only native object emission 闭环：初始化宿主 backend，构造 TargetMachine，显式配置并验证 Module，输出 object，再由系统 `cc` 链接并运行。

范围以 Q-16 的最小闭环为准。本轮不绑定 all-target 初始化、asm parser、disassembler、assembly 或 memory-buffer emission、PassBuilder、linker、JIT，也不修改 CI workflow 或增加 coverage 门槛。Q-17/Q-18 决定的是长期公开骨架；本轮会公开通用 `Target` 与 TargetMachine 构造路径，但只提供 native backend 初始化并验证 host triple，不承诺尚未注册的 cross-target backend 可用。

## 拟冻结的公开契约

| API 层 | 本轮契约 |
|---|---|
| `TargetTriple` | 纯 MoonBit 值；可从字符串构造，也可取得 host triple。输入在进入 LLVM 前拒绝 embedded NUL。 |
| `TargetRegistry` | `initializeNativeCodegen()` 幂等地初始化 native TargetInfo、Target、TargetMC 与 asm printer；`lookupTarget(triple)` 返回 registry-owned borrowed `Target`。本轮不公开 `initializeAllCodegen()`。 |
| `Target` | 只保存 borrowed `LLVMTargetRef`，不提供 disposer；公开名称、描述和 `createTargetMachine`。 |
| `TargetMachineOptions` | 纯 MoonBit 配置值，不向用户暴露 `LLVMTargetMachineOptionsRef`。CPU、features 和 ABI 可选，optimization level、relocation mode 与 code model 使用安全层 enum。构造期间临时创建并释放 raw options。 |
| `TargetMachine` | 唯一新增的长期 native owner，由 managed external object 最终调用 `LLVMDisposeTargetMachine`；不持有 Module，Module 也不反向持有 TargetMachine。 |
| host 默认值 | `TargetMachine::host(options)` 自动确保 native 初始化并取得 host triple；未指定的 CPU/features 使用 host 值。通用 `Target::createTargetMachine` 对未指定 CPU/features 使用 `generic`/空 features，显式值始终优先。 |
| Module target 状态 | 新 Module 的 triple 与 DataLayout 都保持未指定；删除误导性的 `setDefaultDataLayout()`，保留调用者显式设置 layout 的能力。 |
| emission 阶段 | `TargetMachine::configureModule`、`Module::verify`、`TargetMachine::emitObjectToFile` 是三个独立调用。emit 不隐式修改 Module，也不隐式运行 verifier。 |
| 错误 | native 初始化、target lookup、TargetMachine 创建、verification 与 emission 都使用安全层 typed error；LLVM 的诊断文本复制到 MoonBit 后立即释放原 message。字符串边界继续映射到现有 `StringError`。 |

高层标准路径固定为：

```moonbit
let machine = TargetMachine::host(TargetMachineOptions::default())
machine.configureModule(program)
program.verify()
machine.emitObjectToFile(program, object_path)
```

## Commit 1：提交 native emission 决议与实施计划

- [x] 将 Q-16～Q-21 的建议方案标记为已采纳，并填写各自最终采用方案。
- [x] 同步 T-06 中六个问题的状态与更新日期。
- [x] 提交本文档，固定首期范围、公开契约和后续 commit 边界。
- [x] 不包含代码、测试、依赖或生成接口改动。

建议提交信息：`docs: adopt native object emission plan`

## Commit 2：让新 Module 保持 target 未指定

- [x] 从 `Context::addModule` 删除隐式 `setDefaultDataLayout()` 调用。
- [x] 删除公开 `Module::setDefaultDataLayout()`；保留 `Module::setDataLayout()`，并补充读取 target triple 与 DataLayout string 所需的安全 accessor。
- [x] 增加测试，确认新 Module 的 triple/layout 为空，显式 `setDataLayout` 仍能 round-trip。
- [x] 更新 Chapter 4～7 中依赖硬编码 x86 layout 的 doc-test 快照；只移除不再存在的 `target datalayout` 行，不改写教程 IR 的其他内容。
- [x] 检查 `.mbti` 只包含上述公开删除和 accessor 增加。

建议提交信息：`IR: leave new modules target-unspecified`

## Commit 3：接通 native registry 与 TargetMachine 构造的 raw 边界

- [x] 为 `LLVMInitializeNativeTarget` 和 `LLVMInitializeNativeAsmPrinter` 增加可链接的 C adapter；不初始化 asm parser 或 disassembler。
- [x] 接通 `LLVMGetDefaultTargetTriple`、`LLVMGetHostCPUName` 与 `LLVMGetHostCPUFeatures`，在 C 边界复制结果并配对 `LLVMDisposeMessage`。
- [x] 整理 `LLVMGetTargetFromTriple` 的返回模型，保留 lookup 诊断并明确成功/失败，不向 MoonBit 暴露 `char **`。
- [x] 接通 TargetMachine options、`LLVMCreateTargetMachineWithOptions` 与 `LLVMDisposeTargetMachine`；NULL 创建结果必须转为可观察失败。
- [x] 增加 unsafe 白盒测试，覆盖重复 native 初始化、host 信息非空、host target lookup、options 构造/释放、TargetMachine 创建/释放与无效 triple 诊断。
- [x] C adapter 按 `docs/style-guide.md` 标注对应 MoonBit extern、消息所有权、NULL 和全局初始化契约。

建议提交信息：`unsafe: bind native target machine construction`

## Commit 4：接通 configure、verify 与 object emission 的 raw 边界

- [x] 接通 `LLVMCreateTargetDataLayout`、`LLVMSetModuleDataLayout` 与 `LLVMDisposeTargetData`，保证临时 TargetData 只在配置调用内存活。
- [x] 为 `LLVMVerifyModule` 增加 adapter，固定使用 `LLVMReturnStatusAction`；复制并释放成功或失败时可能返回的 message。
- [x] 为 `LLVMTargetMachineEmitToFile` 增加 adapter，固定使用 `LLVMObjectFile`；filename 使用现有 `Utf8Z` 输入边界，错误 message 在同一次 C 调用中复制并释放。
- [x] 删除 `unsafe/Analysis.mbt` 中指向不存在 `__llvm_verify_module` 的悬空声明，改用真实 adapter。
- [x] 增加 unsafe 白盒测试，分别覆盖 Module target/layout 配置、合法与非法 Module verification、object emission 成功和不可写路径的错误诊断。
- [x] 测试产生的 object 使用隔离路径并在测试结束时清理；本 commit 不调用 linker 或运行生成物。

建议提交信息：`unsafe: bind module verification and object emission`

## Commit 5：建立安全 Target 与 TargetMachine 资源模型

- [x] 在 `IR` 包增加 `TargetTriple`、`TargetRegistry`、borrowed `Target`、安全层 codegen enum、`TargetMachineOptions` 和 managed `TargetMachine`。
- [x] `TargetRegistry::initializeNativeCodegen()` 与 `TargetMachine::host()` 复用同一个幂等实现；显式初始化后再次调用 host 路径仍然成功。
- [x] `TargetRegistry::lookupTarget` 暴露长期通用查找原语；`Target::createTargetMachine` 实现 generic/空 features 默认值，`TargetMachine::host` 只为缺省项补 host CPU/features。
- [x] TargetMachine owner 的 C payload 只拥有一个 `LLVMTargetMachineRef`，不保存 Module/Context parent；finalizer 通过 take-and-dispose 路径精确调用一次 disposer。
- [x] 增加 owner 白盒测试和公开 API 测试，验证 Target 无 disposer、TargetMachine alias 只释放一次、显式/自动初始化可组合，以及 host/generic options 默认值与显式覆盖。
- [x] `.mbti` 不公开 raw ref、raw options handle、owner control block 或 `close/drop`。

建议提交信息：`IR: add managed target machine APIs`

## 检查点一：审核长期 API 与所有权

完成 Commit 2～5 后暂停，重点检查：

- 新 Module 是否不再伪装成特定 x86 target，教程快照是否只发生必要变化。
- `TargetRegistry` 显式初始化与 `TargetMachine::host` 自动初始化是否真正共用幂等路径。
- generic 构造是否已经成为 host convenience 的底层原语，而不是另一套平行实现。
- host 与 generic 路径对缺省 CPU/features 的差异是否清晰；本轮是否确实没有偷渡 all-target 初始化。
- TargetMachine 是否是唯一新增 owner，Target 与临时 TargetData 是否没有错误的释放责任或 owner anchor。

## Commit 6：公开显式 configure、verify、emit 三阶段

- [ ] 实现 `TargetMachine::configureModule`，同时写入 machine 的 triple 与临时 TargetData；调用结束后 Module 不依赖 TargetMachine 或 TargetData 存活。
- [ ] 实现 `Module::verify`，固定返回状态模式并把 LLVM verifier message 映射为带诊断文本的 `VerificationError`。
- [ ] 实现 `TargetMachine::emitObjectToFile`，只 borrow machine 与 Module，不调用 configure 或 verify；embedded NUL 与 LLVM emission failure 保持可区分。
- [ ] 增加测试确认 configure 前后 triple/layout 的变化、TargetMachine 离开作用域后 Module 配置仍有效、合法 Module verify 成功、非法 Module 得到 typed error，以及 emission 错误保留 LLVM 诊断。
- [ ] 文档示例始终展示 `configure -> verify -> emit` 标准顺序；不新增隐式一键 emission API。

建议提交信息：`IR: expose explicit object emission stages`

## Commit 7：建立 host-only link-and-run 端到端测试

- [ ] 在 `moon.mod` 增加 `moonbitlang/async` 依赖，并新建专用 native emission 测试包；正式 `IR` 与 `unsafe` 包不依赖 async。
- [ ] 用公开 `IR` API 构造导出 `double average(double, double)` 的最小 Module，依次 configure、verify 并输出 object。
- [ ] 通过 `@fs.tmpdir` 为每个用例创建独立目录，并在受取消保护的 defer 中递归清理；C harness、object 和 executable 都只写入该目录。
- [ ] 使用 `@process.collect_output` 以 argv 直接调用 `cc` 链接，不经 shell；检查 linker exit code、stdout 和 stderr。
- [ ] 直接运行生成的 executable，检查 exit code 为 0、stdout 为预期 `3.5`、stderr 为空，并用 `@async.with_timeout` 覆盖 link 与 run 两阶段。
- [ ] 缺少 `cc` 或宿主 linker 时明确失败并保留诊断，不静默跳过；本测试只证明当前 host object 的 ABI 与执行语义。

建议提交信息：`test: link and run native object output`

## 检查点二：审核完整闭环

完成 Commit 6～7 后暂停，重点检查：

- emit 是否没有隐式修改或验证 Module，三阶段错误是否能分别定位。
- LLVM owned message、TargetMachine 和临时 TargetData 是否全部配对释放。
- async 是否只存在于测试最外层，取消与超时是否会终止子进程并清理临时目录。
- 端到端测试是否真实经过系统 linker 和生成的 executable，而不是只检查 IR 文本或 object 文件存在。
- macOS ARM64 与 Linux x86_64 是否都走同一个 host-only 测试路径。

## 每个 commit 的验收要求

Commit 1 仅修改文档：

- [x] `git diff --check` 通过。
- [x] 六个 Q 的标题状态、`【已采纳】` 标记、最终方案及 T-06 索引保持一致。
- [x] 不包含代码、测试、依赖或生成接口改动。

Commit 2～7 每次提交前：

- [ ] 运行 `moon info && moon fmt`，检查 `.mbti` 变化只来自当前公开 API。
- [ ] 运行 `moon check --target native`。
- [ ] 运行当前 commit 对应的最小测试包，再运行 `moon test --target native`。
- [ ] 运行 `git diff --check`，确认无临时 object、executable 或测试目录留在工作区。
- [ ] 检查 C adapter 的 extern 注释、NULL、borrow、全局状态及 allocator/disposer 契约。
- [ ] coverage 只作为本地增量观察；不修改 CI，不设置百分比门槛。

如果实现中发现需要改变上述公开契约、把 async 引入正式包、启用 all-target/cross-target，或无法让某个 commit 独立通过 check/test，应先停止该 commit 并回到 discussion，而不是把范围变化混入实现。
