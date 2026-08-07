# safe IR 核心对象测试补全的 commit 划分

> 状态：计划中
> 日期：2026-08-07

本轮按照 [Q-10](../discussion/Q-10-layered-coverage-metrics.md) 与 [Q-11](../discussion/Q-11-test-expansion-order.md) 已采用的方案实施 M2，依次补充 `Value`、`Type`、`Instruction` 与 `DataLayout` 的黑盒测试。coverage 仍只用于本地分析和增量记录；本轮不修改 CI，不设置覆盖率门槛，也不提前进入 M3 的 raw 文件与工具链互操作测试。

M1 与 M2 前置类型修复完成后的基线：

- 全部测试：196/196 通过；
- 全部 MoonBit 覆盖点：2563/6109；
- `IR` 包覆盖点：2230/3283；
- `IR/Value.mbt`：100/251；
- `IR/Type.mbt`：320/689；
- `IR/Instruction.mbt`：211/388；
- `IR/DataLayout.mbt`：12/22。

本轮计划新增 `test/value_test.mbt`、`test/instruction_test.mbt` 与 `test/data_layout_test.mbt`，并继续扩充已有最小回归的 `test/type_test.mbt`。测试只通过 `@IR` 的公开安全 API 观察行为，不依赖 private raw handle、C 测试入口或 `@unsafe` 包。

## 现有测试与本轮职责

- 现有 binary、cast、memory、branch 与 PHI 测试已经广泛覆盖 `IRBuilder` 的构造和类型错误。本轮复用这些 fixture，但不为抬高数量重复同一种 builder happy path。
- `IR/resource_owner_wbtest.mbt` 已验证 Value、Type、Instruction 与 DataLayout 的 owner anchor。本轮只检查公开对象在根绑定离开作用域后仍可用的外部行为，不重复检查 private owner identity。
- `test/global_value_test.mbt` 已覆盖 GlobalValue 名称的空值、embedded NUL、默认属性与 linkage；本轮 Value 测试补充 Unicode 名称和其他 Value kind，不重复 M1 的枚举矩阵。
- `test/type_test.mbt` 已包含整数 Primitive downcast，以及 LLVM Aggregate 只包含 Struct/Array 的最小回归；M2 在此基础上补齐完整 Type matrix。
- `test/rauw_uaf_test.mbt` 保持独立且不在本轮扩展。M2 只新增不会删除 source Value 的正常 RAUW 场景；已知的 native handle 失效问题继续由 [Q-09](../discussion/Q-09-native-ir-handle-invalidation.md) 决定。

Q-11 列出的正向、nullable、错误参数、名称编码、类型不匹配和 getter/setter round-trip 按 API 是否具备相应语义逐项应用，不机械要求没有名称或错误通道的 `DataLayout` 伪造对应测试。

## 测试矩阵

| family | 主要行为 | 正向与 round-trip | nullable / 错误与边界 |
|---|---|---|---|
| `Value` | 类型、Context、名称、constant downcast、RAUW | 覆盖各类 owner 来源；Unicode 名称读写；同类型 Argument RAUW 后检查 IR | 无名称返回 `None`；非 Constant 返回 `None`；embedded NUL 精确匹配 `StringError::ContainsNul` |
| `Type` 分类 | 20 个 `TypeEnum` 构造器及 Integer/FP/Primitive/Aggregate/Abstract 子类 | enum/class 往返、Context、Eq、Show、bit width、mantissa width | 每类至少一个 negative downcast；不支持的 raw type kind 不通过 private 入口伪造 |
| `Type` 派生行为 | predicate、scalar、size、Function、Struct、Array、Vector、Pointer | 参数、元素、packed/opaque、address space、`sizeOf` 与 `getScalarType` | 负数和越界索引返回 `None`；非 opaque struct 重复 `setBody` 匹配具体错误；unsized type 的 `sizeOf` 返回 `None` |
| `Instruction` 遍历 | 17 个 `InstructionEnum` 构造器、parent/next/prev | 从 BasicBlock 公开迭代入口恢复具体 wrapper，检查顺序、分类、类型和正常 Show | 首条的 prev 与末条的 next 返回 `None`；不使用 detach 制造无 parent 指令 |
| `Instruction` 属性 | alloca、cmp、GEP、branch、switch、call | predicate、inbounds、successor、tail-call kind 的 getter/setter round-trip | 非条件 branch 的 `setCondition`、successor 越界和既有类型错误匹配具体错误类型 |
| `DataLayout` | bits、store size、alloc size、ABI alignment | 固定显式 layout 下检查整数、数组、packed/unpacked struct | 不对 unsized/无效 type 调用可能触发 LLVM assertion 的原始查询 |

循环中的 enum、predicate、index 和 tail-call kind 每轮期望值不同，使用 assertion 或模式检查；稳定的 IR 与 Show 输出使用 `inspect`。不得用 `moon test --update` 接受与公开契约冲突的结果。

## Commit 1：提交 M2 测试计划

- [x] 提交本文档，并确认基线来自已完成的 M1 与前置类型修复 coverage。
- [x] 固定新增测试文件、7 个 commit 的边界与最终验收命令。
- [x] 明确不修改 CI、生产实现、公开 API 或现有 RAUW/UAF 回归。

建议提交信息：`docs: plan safe IR core tests`

## Commit 2：覆盖 Value 的分类、名称与正常 RAUW

- [x] 新增 `test/value_test.mbt`。
- [x] 对 Function、GlobalValue、Constant、Argument、BasicBlock 和代表性 Instruction 检查 `getType`、`getContext` 与 `asValueEnum`；不同 owner 来源至少各有一个实例。
- [x] 构造全部 9 个 `ConstantEnum` 变体，验证 `tryAsConstant` 与 `tryAsConstantEnum` 的 positive 分支；用 Function、Argument 或 Instruction 验证 negative 分支返回 `None`。
- [x] 验证未命名 Value 返回 `None`、Unicode 名称读写 round-trip，以及 embedded NUL 精确报告 `StringError::ContainsNul`。
- [x] 使用同类型 Function Argument 验证 `replaceAllUsesWith` 更新全部 uses 和稳定 IR；source Argument 仍由 Function 持有，不构造会触发 uniqued Constant 删除的场景。
- [x] 不执行不同类型 RAUW：当前接口没有错误通道，LLVM assertion 不能作为进程内反向测试。若需要支持该错误，另行收敛 API 契约。

建议提交信息：`test(IR): cover core value behavior`

## Commit 3：覆盖 Type 枚举与子类分类

- [x] 在已有最小回归上扩充 `test/type_test.mbt`。
- [x] 通过 Context 公开 factory 构造全部 20 个 `TypeEnum` 变体，验证 `asTypeEnum`、`TypeEnum::asTypeClass`、Eq、Context 与稳定 Show 输出。
- [x] 遍历 5 个 `IntegerTypeEnum`，检查 enum/class 往返、1/8/16/32/64 bit width 与 `getExtendedType` 的 Some/None 边界。
- [x] 遍历 5 个 `FPTypeEnum`，检查 enum/class 往返、primitive bit width 与 11/8/24/53/113 mantissa width。
- [x] 验证 Primitive、Aggregate、Abstract 的 positive/negative downcast 及 enum 转换，覆盖所有公开构造器，而不是只抽样一个成功分支。

建议提交信息：`test(IR): cover type classification`

## Commit 4：覆盖 Type predicate、复合类型与边界

- [ ] 用整数、浮点、pointer、fixed vector、scalable vector、array、literal/opaque struct、function 与 void 建立 predicate 表，覆盖 first-class、single-value、aggregate、sized、empty、GEP-valid 和 scalar 分类的 true/false 分支。
- [ ] 验证 sized type 的 `sizeOf` 返回可观察的 ConstantExpr，unsized type 返回 `None`。
- [ ] 验证 FunctionType 的 return type、vararg、参数数组、参数数量，以及首尾、负数和越界参数查询。
- [ ] 验证 literal、named opaque、packed/unpacked StructType 的状态、elements 与 `setBody`；重复设置非 opaque body 时匹配具体错误。
- [ ] 验证 Array、Vector、ScalableVector 的具体 element/count API，以及只包含 Struct/Array 的 AggregateType 合法和越界 element 查询。
- [ ] 验证 PointerType 默认和非默认 AddressSpace，以及 `isLoadableOrStorableType` 的典型 true/false 分支。

建议提交信息：`test(IR): cover composite type behavior`

## Commit 5：覆盖 Instruction 分类、parent 与相邻遍历

- [ ] 新增 `test/instruction_test.mbt`，构造包含全部 17 个 `InstructionEnum` 变体的最小函数集合；fixture 可以按内存、算术、控制流分组，不要求把不相容的指令硬塞进一个 BasicBlock。
- [ ] 从 `BasicBlock::getFirstInst`、`getLastInst` 及 Instruction 的 `getNextInst`、`getPrevInst` 公开入口遍历，验证恢复的具体 wrapper 分类与顺序。
- [ ] 对每个具体 wrapper 检查 `asValueEnum`、`asInstEnum`、`getType`、`getParentBasicBlock` 和正常 Show；避免只验证 builder 的静态返回类型。
- [ ] 验证空 BasicBlock、首条 prev、末条 next 和越界/不存在结果返回 `None`。
- [ ] 不调用 `removeFromParent` 或 `eraseFromParent` 制造 detached/stale handle，也不扩展 `test/rauw_uaf_test.mbt`。

建议提交信息：`test(IR): cover instruction traversal`

## Commit 6：覆盖 Instruction 专用属性和错误路径

- [ ] 验证 Alloca allocated type 与 GEP source element type；对 GEP 的 inbounds 执行 set/get/remove round-trip。
- [ ] 遍历全部 10 个 `IntPredicate` 与 16 个 `FloatPredicate`，创建比较指令并验证 getter 返回相同构造器。
- [ ] 验证 conditional/unconditional Branch 的分类、successor 数量、首尾/越界 getter，以及 `setCondition`、`setSuccessor` 的正常和具体错误分支。
- [ ] 验证 Switch 默认与 case successor 的数量、顺序、替换和越界错误；复用现有非整数 case 错误证据，不重复 builder 测试。
- [ ] 遍历 4 个 `TailCallKind`，验证 Call getter/setter round-trip，并单独验证 `setTailCall`/`removeTailCall`。
- [ ] 对普通 Call 与非 Call 指令验证 `getNumArgOperands` 的适用行为；若 LLVM C API 对非 Call 有 assertion 前置条件，则只测试 Call 并在实际结果中记录限制。

建议提交信息：`test(IR): cover instruction properties`

## Commit 7：覆盖 DataLayout 并记录 M2 增量

- [ ] 新增 `test/data_layout_test.mbt`，为 Module 设置固定且显式的 data-layout string。
- [ ] 对整数、数组、packed struct 和带 padding 的 unpacked struct 检查 size-in-bits、store size、alloc size 与 ABI alignment，确保至少一个样例能区分 store/alloc 或 packed/unpacked 行为。
- [ ] 复用已有 owner 白盒证据，不为访问 private target-data ref 增加测试入口。
- [ ] 完成全部验收命令，并在本文档“实际结果”中记录测试数量、全仓、`IR` 包及四个目标文件的 coverage 新值和增量。
- [ ] 使用 caret 报告逐项归类四个目标文件的剩余未覆盖点；说明公共正常路径、错误路径、LLVM assertion 前置条件、private/raw-only 分支和 Q-09 暂缓分支。

建议提交信息：`test(IR): cover data layout queries`

## 完成验收

- [ ] 每个测试 commit 至少运行 `moon fmt`、`moon check --target native` 与 `moon test --target native -p test`。
- [ ] 最终运行 `moon info`；本轮只新增黑盒测试，预期所有 `.mbti` 均无变化。
- [ ] 最终运行 `moon test --target native`。
- [ ] 最终运行 `moon coverage analyze -- -f summary`。
- [ ] 最终运行 `moon coverage report -p Kaida-Amethyst/llvm/IR -f summary`。
- [ ] 分别使用 caret 报告检查 `IR/Value.mbt`、`IR/Type.mbt`、`IR/Instruction.mbt` 与 `IR/DataLayout.mbt`。
- [ ] 不修改 CI，不用单一百分比或测试数量代替行为与剩余分支说明。
- [ ] `git diff --check` 通过，工作区只包含计划内文件；每个 commit 可独立通过测试和 review。

## 发现实现问题时的边界

- 测试 commit 不混入生产实现修复、接口设计或 generated `.mbti` 变化。
- 新测试暴露错误分类、LLVM assertion、崩溃或文档/实现冲突时，保留最小安全复现并单独记录；不能安全运行的复现不加入默认测试进程。
- 不通过 raw handle 注入 unsupported type、malformed UTF-8、detached instruction 或 stale Value 来追求分支覆盖。
- 不进入 M3 的 parser、bitcode、linker、target、pass 或 Error 资源测试，也不进入 M4/M5 的执行引擎和 sanitizer 工作。

## 实际结果

待实施后填写。
