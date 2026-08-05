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

## Commit 5：迁移 Module-owned Value、BasicBlock 与 IRBuilder

- [ ] 让 Function、Argument、GlobalVariable、GlobalConstant、BasicBlock 和全部 Instruction wrapper 强持有 Module。
- [ ] 更新 Module/Function/BasicBlock 的 factory、iterator、parent/next/previous getter 以及 `initInstruction`，构造返回值时传播同一个 Module owner。
- [ ] 让 IRBuilder 使用 managed Builder owner 并保持 Context 存活；设置 insertion point 后，还必须在 builder native handle 释放前保持对应 Module 存活。
- [ ] 更新所有 IRBuilder build 路径，使新建 Instruction 和 GlobalConstant 获得当前 insertion Module，而不是返回 raw-only wrapper。
- [ ] `IRBuilder::getInsertBlock` 以及从 Instruction 返回 BasicBlock 的路径必须传播 owner。
- [ ] 这组对象形成相互依赖的构造闭包，因此放在同一个 commit；按文件和 factory 分段审核，不拆出无法编译的中间表示。
- [ ] Builder finalizer 仍不调用 `LLVMDisposeBuilder`。

建议提交信息：`IR: anchor module-owned values and builders`

## Commit 6：迁移 Context-owned Constant

- [ ] 让 ConstantInt、ConstantFP、ConstantPointerNull、ConstantArray、ConstantStruct、ConstantVector、UndefValue 和 PoisonValue 持有 Context。
- [ ] 更新 Context 中全部 constant factory，使返回值传播调用者的 Context owner。
- [ ] 更新 IRBuilder 中可能返回 constant wrapper 的折叠或 convenience 路径，使用 builder 保存的 Context，而不是只包装 raw value。
- [ ] 不把 context-owned Constant 错误地绑定到某个 Module。

建议提交信息：`IR: anchor constants to Context`

## Commit 7：迁移 Type family

- [ ] 让所有具体 Type wrapper 持有 Context，包括 primitive、FunctionType、StructType、ArrayType、VectorType、ScalableVectorType 和 PointerType。
- [ ] 修改 `initAbstractType`/`initAbstractType_err`，要求调用者显式提供 Context owner。
- [ ] 更新 Context factory、Type 派生 getter、`Value::getType`、Function/Instruction 的专用 type getter，保证动态包装时传播已有 owner。
- [ ] `Type::getContext` 返回保存的 Context，不再通过 `LLVMGetTypeContext` 构造新的 owner。
- [ ] 从 Function 等 Module-owned Value 得到 Type 时，只保留其 Context，不无谓延长整个 Module 生命周期。

建议提交信息：`IR: anchor types to Context`

## Commit 8：迁移 DataLayout 与其余安全 borrowed view

- [ ] 让 `Module::getDataLayout` 返回的 DataLayout 持有 Module，因为该指针是 Module-borrowed view。
- [ ] 检查 Attribute 及 `IR` 包中其他由 Context/Module 返回的 raw-only view；对安全 API 实际能够创建和持有的对象补充正确 owner。
- [ ] 不扩大到用户主动通过 `@unsafe` raw constructor 伪造 wrapper 的场景，也不在本 commit 清理全部 unsafe public surface。
- [ ] 不处理 execution engine 的 Module ownership transfer；该问题留到检查点三。

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

- [ ] 增加 package-private/白盒测试，检查 Context、Module、Function、BasicBlock、Instruction、Type、Constant 和 DataLayout 之间保存的是预期 owner。
- [ ] 覆盖原始局部 Context/Module binding 已离开最后使用位置、但派生对象仍可通过保存的 owner 继续工作的场景。
- [ ] 审计所有具体 wrapper constructor、factory、getter、iterator 和动态初始化函数，清除安全 IR 路径中的 raw-only 临时构造入口。
- [ ] 增加可重复运行的静态审计方式，防止后续代码重新引入不带 owner 的安全 wrapper 构造路径；审计范围只覆盖本轮对象。
- [ ] 此时测试主要验证 owner 身份和传播；exact-once disposal 与析构顺序留到 finalizer commit 验证。

建议提交信息：`test(IR): audit resource owner propagation`

## 检查点三：先解决 Interpreter 的 ownership transfer

在启用 Module finalizer 前必须暂停讨论 `Module::createInterpreter`：`LLVMCreateInterpreterForModule` 会把 Module 的释放责任交给 execution engine，而当前 `Interpreter` 本身也没有可靠的 disposer。若 Module owner 仍认为自己拥有 `LLVMModuleRef`，它与 execution engine 会重复释放；若只是跳过 Module finalizer，又会留下 Interpreter 和转移后 alias 的生命周期问题。

这里不在计划中预设 `Moved` 状态、共享 owner 改为持有 execution engine，或调整公开 API 中的任一方案。开始 Commit 10 前，应在 `docs/discussion` 新建独立 Q，明确：

- 创建成功和失败时，Module ownership 分别属于谁；
- 已存在的 Module/Function alias 在成功后是否仍可使用；
- execution engine 由谁以及何时调用 `LLVMDisposeExecutionEngine`；
- 该决定是否需要公开的 moved/invalid 错误模型。

## Commit 10：实现已采用的 Interpreter transfer 方案

- [ ] 本 commit 的具体代码范围在检查点三的 Q 得出结论后回填，未回填前不得开始实现。
- [ ] 创建失败必须保留 Module 原有 ownership；创建成功必须只留下一个 native disposer 责任方。
- [ ] Interpreter、Module 及既有派生 alias 的存活关系必须符合采用方案，不允许依靠用户手动 `ignore` 保活。
- [ ] 为 execution engine 的释放责任增加对应 native 测试。

建议提交信息：在检查点三确定方案后填写。

## Commit 11：启用 Context、Module 与 Builder finalizer

- [ ] 将此前 inactive 的 C finalizer 接入 `LLVMContextDispose`、`LLVMDisposeModule` 和 `LLVMDisposeBuilder`；若 Module ownership 已转移，则遵守 Commit 10 确定的唯一 disposer 规则。
- [ ] 删除公开 `Context::drop`，不新增公开 `close/drop` 替代入口。
- [ ] 增加最小 C 测试探针和白盒测试，验证 alias 只触发一次 native disposal。
- [ ] 验证仅保留 Function/Instruction/DataLayout 时 Module 不会提前析构，仅保留 Type/Constant 时 Context 不会提前析构。
- [ ] 验证 Builder、Module 和 execution engine 等 child 的 native resource 先于 Context 析构。
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

- Module transfer 与普通 Module finalizer 是否严格只有一个 disposer。
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
