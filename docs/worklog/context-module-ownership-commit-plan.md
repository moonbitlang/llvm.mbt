# Context、Module 与派生对象所有权迁移的 commit 划分

> 状态：计划中
> 日期：2026-08-05

本轮按照 [Q-07](../discussion/Q-07-context-module-reclamation.md) 和 [Q-08](../discussion/Q-08-derived-handle-owner-anchors.md) 已采用的方案实施：安全 `IR` API 不公开 `close/drop`，最终由 C finalizer 回收 `Context`、`Module` 和 `IRBuilder`；borrowed wrapper 按 provenance 强持有真正的 owner。

迁移期间必须先建立完整的 owner graph，最后才能启用 LLVM disposer。前面的 commit 即使已经使用 managed owner，finalizer 也暂时不调用 `LLVMContextDispose`、`LLVMDisposeModule` 或 `LLVMDisposeBuilder`，因此中间版本最多维持当前的泄漏，不会因为局部迁移而新增提前释放。每个实现 commit 都必须保持可编译、可测试，不接受依赖后续 commit 才能恢复的红色中间状态。

## Commit 1：提交讨论结论与迁移计划

- [x] 提交 T-03、Q-07、Q-08 和本文档。
- [x] 确认 Q-07、Q-08 都指向已采用的 A3，T-03 中的状态与 Q 文档一致。
- [x] 不包含任何代码或生成接口改动。

建议提交信息：`docs: record IR resource ownership plan`

## Commit 2：建立暂不释放 LLVM 资源的 owner 基础设施

- [x] 在 `IR` 包中增加 Context、Module 和 Builder 所需的 private managed external owner 类型及 C control block。
- [x] 提供 package-private 的创建和 raw-handle borrow 入口，不向公开接口暴露新的 raw capability。
- [x] Module owner 在 C payload 中显式持有 Context owner；Builder owner 至少持有 Context owner。C payload 内的 parent 引用使用配对的 `moonbit_incref`/`moonbit_decref`。
- [x] 本 commit 的 finalizer 只维护 control block 的 MoonBit 引用，不调用三个 LLVM disposer；不得提前改变 native 资源释放行为。
- [x] 增加最小白盒检查，确认 alias 指向同一个 owner，Module owner 能保持 Context owner 存活。

建议提交信息：`IR: add inactive native owner controls`

## Commit 3：让 Context 使用 managed owner

- [x] 将公开 `Context` 的内部表示改为 private owner，不再直接保存公开的 `LLVMContextRef` positional field。
- [x] `Context::new` 创建 Context owner；IR 包内部统一通过 package-private borrow helper 取得 raw handle。
- [x] 更新 Context 自身以及其他文件中直接读取 `ctx.0` 的调用点。
- [x] 暂时保留现有 `Context::drop`，其行为仍直接调用 LLVM disposer；本 commit 不声称已经解决重复释放。
- [x] finalizer 仍不释放 native Context。

建议提交信息：`IR: wrap Context in a managed owner`

## Commit 4：让 Module 使用 managed owner 并持有 Context

- [x] 将公开 `Module` 的内部表示改为 private Module owner。
- [x] `Context::addModule` 使用当前 Context 创建 Module owner，并建立 `Module -> Context` 强引用。
- [x] `Module::getContext` 返回 owner 中保存的同一个 Context，不再把 `LLVMGetModuleContext` 的 borrowed raw pointer 包装成新的 owning Context。
- [x] IR 包内部统一通过 package-private helper 借用 `LLVMModuleRef`，更新 Module 的直接调用点。
- [x] finalizer 仍不调用 `LLVMDisposeModule`；现有派生 wrapper 暂时仍可保持 raw-only 表示。

建议提交信息：`IR: anchor Module to Context`

## 检查点一：审核 root owner 表示

完成 Commit 1—4 后暂停，重点检查：

- Context 和 Module 的 raw handle、构造器及 owner 字段是否已经保持 private。
- `Module::getContext` 是否返回原有 owner，而不是制造第二个释放责任。
- C payload 的 parent 引用是否严格配对 incref/decref。
- LLVM disposer 是否确实尚未接入 finalizer。
- 每个 commit 是否分别通过全量 native check/test。

## 追加 Commit 4A：移除生产 payload 中的测试专用状态

- [x] 从 Context、Module 和 Builder 的 C owner payload 中删除 `tracked_for_test`；生产对象不为测试保存额外字段或执行测试计数分支。
- [x] 删除依赖 `owner_test_context_new`、`owner_test_module_new` 等假对象 factory 的测试入口、仅由这些入口使用的析构计数器，以及只为测试提供的 C `ContextOwner::same` helper。
- [x] 改用 `Context::new`、`Context::addModule` 和 `Module::getContext` 等真实用户路径验证 owner 身份与父 owner 保活关系；owner 对象身份直接用 MoonBit 的 `physical_equal` 检查，并明确这些测试验证的是 owner graph，而不是 exact-once native disposal。
- [x] 将 package-private 的 `Context::owner`、`Module::owner` 分别改名为 `Context::get_owner`、`Module::get_owner`，并更新全部调用点。
- [x] 将 package-private 的 `Context::inner`、`Module::inner` 分别改名为 `Context::get_unsafe_ref`、`Module::get_unsafe_ref`，明确返回值是只能在内部谨慎借用的 unsafe LLVM raw reference；重命名使用 `moon ide rename` 完成。
- [x] 在迁移期 helper `Context::from_borrowed_raw` 上方增加 TODO，明确其调用点完成 owner 传播后必须删除；本 commit 不把 borrowed raw 包装提升为正式 API。
- [x] 本 commit 继续保持 inactive finalizer，不调用 LLVM disposer，也不提前加入重复析构的 fail-fast 分支。
- [x] 将重复释放的 fail-fast 实现明确延后至 Commit 11；本 commit 只移除测试状态，不提前引入尚无真实 disposer 可保护的分支。
- [x] 明确不把上述 fail-fast 当作唯一 owner 的保证：两个不同 owner 包装同一个 LLVM raw pointer 无法由各自的 disposed 状态发现，仍须依靠 private 构造入口、owner 传播和 Commit 9 的构造路径审计来排除。

建议提交信息：`IR: simplify owner controls and clarify internal accessors`

## Commit 5：迁移 Module-owned Value、BasicBlock 与 IRBuilder

- [x] 让 Function、Argument、GlobalVariable、GlobalConstant、BasicBlock 和全部 Instruction wrapper 强持有 Module。
- [x] 更新 Module/Function/BasicBlock 的 factory、iterator、parent/next/previous getter 以及 `initInstruction`，构造返回值时传播同一个 Module owner。
- [x] 让 IRBuilder 使用 managed Builder owner 并保持 Context 存活；设置 insertion point 后，还必须在 builder native handle 释放前保持对应 Module 存活。
- [x] 更新所有 IRBuilder build 路径，使新建 Instruction 和 GlobalConstant 获得当前 insertion Module，而不是返回 raw-only wrapper。
- [x] `IRBuilder::getInsertBlock` 以及从 Instruction 返回 BasicBlock 的路径必须传播 owner。
- [x] 修正 `Type::sizeOf` 将 LLVM constant expression 误包装成 `CastInst` 的原有分类错误，引入 `ConstantExpr`；它与其他 context-owned Constant 一起在 Commit 6 建立 Context anchor。
- [x] 这组对象形成相互依赖的构造闭包，因此放在同一个 commit；按文件和 factory 分段审核，不拆出无法编译的中间表示。
- [x] Builder finalizer 仍不调用 `LLVMDisposeBuilder`。

建议提交信息：`IR: anchor module-owned values and builders`

## Commit 6：迁移 Context-owned Constant

- [x] 让 ConstantInt、ConstantFP、ConstantPointerNull、ConstantArray、ConstantStruct、ConstantVector、ConstantExpr、UndefValue 和 PoisonValue 持有 Context；`Type::sizeOf` 返回的 LLVM constant expression 不再误包装为 Module-owned `CastInst`。
- [x] 更新 Context 中全部 constant factory，使返回值传播调用者的 Context owner。
- [x] 更新 IRBuilder 中可能返回 constant wrapper 的折叠或 convenience 路径，使用 builder 保存的 Context，而不是只包装 raw value。
- [x] 不把 context-owned Constant 错误地绑定到某个 Module。

建议提交信息：`IR: anchor constants to Context`

## Commit 7：迁移 Type family

- [x] 让所有具体 Type wrapper 持有 Context，包括 primitive、FunctionType、StructType、ArrayType、VectorType、ScalableVectorType 和 PointerType。
- [x] 修改 `initAbstractType`/`initAbstractType_err`，要求调用者显式提供 Context owner。
- [x] 更新 Context factory、Type 派生 getter、`Value::getType`、Function/Instruction 的专用 type getter，保证动态包装时传播已有 owner。
- [x] `Type::getContext` 返回保存的 Context，不再通过 `LLVMGetTypeContext` 构造新的 owner。
- [x] 从 Function 等 Module-owned Value 得到 Type 时，只保留其 Context，不无谓延长整个 Module 生命周期。

建议提交信息：`IR: anchor types to Context`

## Commit 8：迁移 DataLayout 与其余安全 borrowed view

- [x] 让 `Module::getDataLayout` 返回的 DataLayout 持有 Module，因为该指针是 Module-borrowed view。
- [x] 检查 Attribute 及 `IR` 包中其他由 Context/Module 返回的 raw-only view；对安全 API 实际能够创建和持有的对象补充正确 owner。
- [x] 不扩大到用户主动通过 `@unsafe` raw constructor 伪造 wrapper 的场景，也不在本 commit 清理全部 unsafe public surface。
- [x] 不处理 execution engine 的 Module ownership transfer；该问题留到检查点三。

建议提交信息：`IR: anchor remaining borrowed views`

## 检查点二：审核完整的 borrowed owner graph

完成 Commit 5—8 后暂停，重点检查：

- 所有 Module-owned Value 是否都直接或间接保留 `Module -> Context`。
- 所有 Type 和 context-owned Constant 是否只保留 Context。
- DataLayout 是否保留 Module。
- Builder 设置 insertion point 后是否保留 Module，且不依赖 MoonBit record 字段未承诺的析构顺序。
- `Value::getType`、`initAbstractType`、`initInstruction` 和各类 iterator 是否没有遗漏 owner 参数。
- finalizer 是否仍未释放任何 LLVM Context、Module 或 Builder。

## Commit 9：增加 owner 传播审计与迁移期回归测试

- [x] 增加 package-private/白盒测试，检查 Context、Module、Function、BasicBlock、Instruction、Type、Constant 和 DataLayout 之间保存的是预期 owner。
- [x] 覆盖原始局部 Context/Module binding 已离开最后使用位置、但派生对象仍可通过保存的 owner 继续工作的场景。
- [x] 审计所有具体 wrapper constructor、factory、getter、iterator 和动态初始化函数，清除安全 IR 路径中的 raw-only 临时构造入口。
- [x] 增加可重复运行的静态审计方式，防止后续代码重新引入不带 owner 的安全 wrapper 构造路径；审计范围只覆盖本轮对象。
- [x] 此时测试主要验证 owner 身份和传播；exact-once disposal 与析构顺序留到 finalizer commit 验证。

建议提交信息：`test(IR): audit resource owner propagation`

## 检查点三：暂缓 Interpreter ownership transfer

当前安全 `IR` 包已经公开 `Module::createInterpreter`、`Interpreter` 和 `GenericValue`，但这组 binding 尚未形成完整的 ownership 模型：`LLVMCreateInterpreterForModule` 会接管传入的 Module，`Interpreter` 和 `GenericValue` 又都没有可靠的 managed owner 与 disposer。若直接启用 Module finalizer，会在 execution engine 与 Module owner 之间产生重复释放风险。

本轮不为尚未完成的 Interpreter binding 引入 transferred/moved/invalid 状态，也不扩大 Context/Module 回收任务的范围。检查点三采用的范围决策是：先从安全 `IR` 包删除这组未完成接口，使本轮安全 API 中不再存在转移 Module ownership 的路径；`unsafe` 包中的原始 LLVM binding 保留。未来重新实现 Interpreter 时，另行讨论 execution engine owner、Module transfer、失败语义、既有 alias 和 GenericValue disposer。

## Commit 10：删除未完成的 Interpreter 安全接口

- [x] 删除 `Module::createInterpreter`，使安全 `Module` API 不再触发 execution engine ownership transfer。
- [x] 删除安全 `IR` 包中的 `InterpreterError`、`Interpreter`、`GenericValue` 及其相关方法；同步更新生成接口。
- [x] 保留 `unsafe` 包中的 execution engine 和 GenericValue 原始 binding，不在本 commit 清理 unsafe public surface。
- [x] 确认安全 `IR` 包中不再调用 `llvm_create_interpreter_for_module`，也不再公开 `LLVMExecutionEngineRef` 或 `LLVMGenericValueRef`。
- [x] 将完整 Interpreter binding 明确留给后续独立任务；本 commit 不预设未来采用 transfer、clone 或其他 API 方案。

建议提交信息：`IR: defer unfinished Interpreter bindings`

## Commit 11：启用 Context、Module 与 Builder finalizer

- [ ] 将此前 inactive 的 C finalizer 接入 `LLVMContextDispose`、`LLVMDisposeModule` 和 `LLVMDisposeBuilder`；安全 `IR` 包此时不存在转移 Module ownership 的路径。
- [ ] 让 owner 的 native disposal 统一经过内部 `take_raw`/`dispose_once` 路径；若同一个仍存活的 owner 已交出 raw reference，则向 `stderr` 输出醒目的错误信息并调用 `abort()`，不得继续第二次析构。
- [ ] 删除公开 `Context::drop`，不新增公开 `close/drop` 替代入口。
- [ ] 增加最小 C 测试探针和白盒测试，验证 alias 只触发一次 native disposal。
- [ ] 验证仅保留 Function/Instruction/DataLayout 时 Module 不会提前析构，仅保留 Type/Constant 时 Context 不会提前析构。
- [ ] 验证 Builder 和 Module 等 child 的 native resource 先于 Context 析构。
- [ ] 测试探针不得成为公开 `IR` API，也不得改变 release 路径的正常语义。

建议提交信息：`IR: finalize managed LLVM resources`

## Commit 12：清理迁移设施并完成生产检查

- [ ] 删除只为 inactive-finalizer 迁移期保留的 helper、分支和注释。
- [ ] 检查 doc test 和教程中不再调用 `Context::drop`，并更新受公开表示变化影响的说明。
- [ ] 运行 owner 构造路径审计，确认安全 IR 路径没有重新包装 borrowed Context/Module raw pointer。
- [ ] 检查生成 `.mbti`：预期不再公开 Context/Module/Builder 的 raw positional field 和 `Context::drop`，不混入本轮以外的 API 清理。
- [ ] 运行最终全量 native check/test，并记录测试数量与结果。

建议提交信息：`IR: complete resource ownership migration`

## 检查点四：审核 finalizer 与最终状态

完成 Commit 10—12 后暂停，重点检查：

- 安全 `IR` 包是否已经不存在 Module ownership transfer 路径。
- Module 和 Builder 是否都能阻止 Context 提前析构。
- derived wrapper 是否既不会制造资源环，也不需要用户手动保活 root binding。
- `Context::drop` 是否已经从源码、文档和生成接口中消失。
- exact-once、析构顺序、last-use 场景及全量既有测试是否全部通过。

## 每个 commit 的检查要求

Commit 1 仅修改文档，要求：

- [x] 运行 `git diff --check`。
- [x] 确认没有代码、测试或生成接口改动。

Commit 2—12 每次提交前都要求：

- [ ] 运行 `moon info`，检查 `.mbti` 变化只来自当前 commit。
- [ ] 运行 `moon fmt`。
- [ ] 运行 `moon check --target native`。
- [ ] 运行 `moon test --target native`。
- [ ] 运行 `git diff --check`。
- [ ] 检查本 commit 声明的 owner 边已经建立，未迁移对象仍维持此前行为。
- [ ] Commit 11 之前确认 inactive finalizer 没有调用 LLVM disposer。
- [ ] 不混入字符串边界、UTF-16、悬空 extern、mutation 后 stale handle 或其他资源类型的清理。

如果某个实现步骤无法单独通过上述检查，应调整 commit 边界或增加 private 迁移层；不得提交依赖后续 commit 才能重新通过 check/test 的中间状态。
