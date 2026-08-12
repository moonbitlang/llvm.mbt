# 公开 API 文档注释改造的 commit 划分

> 状态：计划中
> 日期：2026-08-12

本轮按照已经提交的 [代码风格指南](../style-guide.md) 中“公开 API 的文档注释”规则，为 `IR` 安全层与 `unsafe` 原始绑定补齐和改造用户可见文档。工作按契约域拆成多个可独立审核的 commit；每一批结束后暂停，由人工检查公开类型、函数语义、生命周期、安全边界和 LLVM-C 映射，再进入下一批。

计划制定时的只读盘点结果：

- `IR/*.mbt` 中以 `pub` 开头的顶层声明约 667 处，`moon check IR --target native --warn-list '+missing_doc'` 报告 703 条 `missing_doc`；
- `unsafe/*.mbt` 中以 `pub` 开头的顶层声明约 1596 处，`moon check unsafe --target native --warn-list '+missing_doc'` 报告 722 条 `missing_doc`；
- `missing_doc` 会把 trait method、enum constructor 等子项分别计入，因此它的数量不等于顶层 `pub` 行数；它只能证明文档存在，不能证明契约正确；
- `IR/IRBuilder.mbt` 已有较多早期文档和 doc test，本轮仍逐项按新规范审核，不能因已经存在 `///` 就跳过；
- `unsafe/Core.mbt` 单文件包含约 1252 个顶层公开声明，必须按 LLVM-C 功能族拆分，禁止在一个 commit 中整体机械补注释。

## 本轮范围与不变量

- 只修改文档注释以及本 worklog 的勾选状态，不修改公开签名、可见性、实现逻辑、FFI symbol、native stub、普通测试或 CI。
- 文档正文延续仓库现状使用英文；worklog 和审核说明使用中文。LLVM 名词、MoonBit 标识符和 C symbol 使用反引号。
- 所有公开声明至少有一句摘要；公开 enum/error constructor、公开 struct field 和 trait method 分别补文档。简单 getter 或常规 impl 不机械复制完整模板。
- 安全 `IR` 层重点说明用户语义、错误、调用顺序和生命周期，不用 LLVM-C symbol 淹没高层文档；`unsafe` 层直接 binding 原则上注明对应 LLVM API，并明确 nullability、ownership、allocator/disposer、`LLVMBool` 约定、字符串边界和可能的 assertion/UB。
- Example 按“功能族至少一个”补充，不要求每个声明一个示例。优先复用和整理已有 doc test；新增 `mbt check` 必须只使用公开 API、保持短小且确定，不调用 linker、外部进程或网络。
- `IR/pkg.generated.mbti`、`IR/IR.mbti`、`unsafe/pkg.generated.mbti` 和 `unsafe/unsafe.mbti` 只用于盘点与核对，禁止手工编辑。`moon info` 后公开 API shape 必须不变。
- `IR/BitCode.mbt` 以及 `unsafe/ErrorHandling.mbt`、`unsafe/Object.mbt`、`unsafe/Support.mbt` 当前没有 active public declaration，本轮不为注释掉的 LLVM 头文件草稿补文档；若实施时新增了公开声明，必须另行调整计划。

## 交付批次与 review 停点

每个 commit 都必须能独立 review 和通过验收。实际执行时再按下表组成交付批次；一个批次完成并提交后必须暂停，等待用户 review 和明确继续，不能自动进入下一批。

| 批次 | commit | 人工 review 重点 |
| --- | --- | --- |
| A | 2—3 | Context 根 owner、type/constant factory、共享错误 |
| B | 4—6 | Type trait contract、分类 enum、concrete/composite Type 生命周期 |
| C | 7—8 | Value hierarchy、Module/Function/GlobalValue ownership、DataLayout |
| D | 9—11 | BasicBlock/Instruction mutation、Q-09 风险、TargetMachine/emission |
| E | 12—14 | IRBuilder insertion state、类型前置条件和 Example 质量 |
| F | 15—17 | raw handle 表示、null sentinel、LLVM 19 enum 映射 |
| G | 18—19 | unsafe Context/Module/Type 的 allocator、disposer 与 borrowed result |
| H | 20—21 | raw Value/ISA/use/operand 与 Constant API 的失效和类型契约 |
| I | 22—23 | GlobalValue/Function/metadata、BasicBlock/Instruction/Builder 生命周期 |
| J | 24—25 | raw builder flags、memory/atomic/cast/call 与 legacy pass manager |
| K | 26 | verifier、parser、bitcode、Comdat、Target 和 emission |
| L | 27 | ErrorRef、ExecutionEngine、ORC、LLJIT、Linker ownership transfer |
| M | 28 | DebugInfo、PassBuilder、全局初始化与最终 `missing_doc` 审计 |

## Commit 1：提交文档注释规范与实施计划

涉及文件和对象：

| 文件 | 对象 |
| --- | --- |
| `docs/worklog/C-07-public-api-documentation-commit-plan.md` | 本任务的范围、commit 边界、审核检查点和验收要求 |

- [x] 提交本文档；`docs/style-guide.md` 的规则已经在前一个 commit 中落地，本 commit 不重复包含它。
- [x] 记录 `IR`/`unsafe` 的 `missing_doc` 基线和不计入本轮的空壳文件。
- [x] 确认后续每个 commit 的文件及公开对象边界足以独立 review。
- [x] 不包含 `.mbt`、测试、生成接口或 CI 改动。

建议提交信息：`docs: plan public API documentation batches`

## 第一阶段：安全 IR 的根对象与类型系统

### Commit 2：记录 Context 根对象与类型 factory 契约

| 文件 | 公开对象 |
| --- | --- |
| `IR/Context.mbt` | `Context`、`Eq for Context`、`Context::new`、`addModule`、`createBuilder`；全部 primitive/abstract type getter；`getPtrTy`、`getFunctionType`、`getStructType`、`getOpaqueStructType`、`getStructTypeByName`、`getArrayType`、`getFixedVectorType`、`getScalableVectorType` |

- [x] 说明 `Context` 是 native LLVM context 的 managed owner，以及 Module、Builder、Type 与 Constant 从 Context 派生时的 owner anchor。
- [x] 说明 Context 相等性比较的含义、named/opaque/literal struct 的差异、同一 Context 前置条件和各 type factory 的关键参数。
- [x] 在主要构造路径保留或补充一个代表性黑盒 doc test，不为每个 primitive getter 复制示例。

建议提交信息：`docs(IR): document context and type factories`

### Commit 3：记录 Context constant factory 与共享错误契约

| 文件 | 公开对象 |
| --- | --- |
| `IR/Context.mbt` | `getConstTrue`、`getConstFalse`、全部有符号/无符号整数 constant factory、浮点 constant factory、`getConstArray`、`getConstVector`、`getConstStruct`、`getUndef`、`getPoision`、`getConstPointerNull` |
| `IR/StringError.mbt` | `StringError` 及 `ContainsNul`、`MalformedUtf8` |
| `IR/Errors.mbt` | `IndexOutOfBounds` 及其 payload |

- [x] 说明整数截断/扩展、浮点输入、aggregate 元素类型和 Context 一致性等非显然语义。
- [x] 明确 Constant 由 Context 保活，不归属于某个 Module。
- [x] 对每个公开 error constructor 说明触发条件和 payload 含义。

建议提交信息：`docs(IR): document constant factories and shared errors`

### Commit 4：记录 Type 抽象层、分类 enum 与 trait contract

| 文件 | 公开对象 |
| --- | --- |
| `IR/Type.mbt` | `TypeEnum`/`asTypeClass`；`Type` 及全部 trait method/default method；`InValidTypeError`；`IntegerType`/`IntegerTypeEnum`；`FPType`/`FPTypeEnum`；`PrimitiveType`/`PrimitiveTypeEnum`；`AggregateType`/`AggregateTypeEnum`；`AbstractType`/`AbstractTypeEnum`；这些 trait object 的 public extend；`AddressSpace`/`AddressSpace::new` |

- [x] 为每个公开 enum constructor 说明它代表的具体 LLVM type category。
- [x] 为各 trait 写清 implementor contract、分类转换、borrowed raw ref 与 Context 生命周期。
- [x] 区分 `isSized`、`isSingleValueType`、`isAggregateType` 等容易混淆的 predicate，不只把方法名改写成句子。
- [x] 说明 downcast/enum conversion 的 `None` 语义，以及 `sizeOf` 等结果的所有权和不可用条件。

建议提交信息：`docs(IR): document type hierarchy contracts`

### Commit 5：记录 primitive 与 abstract concrete Type

| 文件 | 公开对象 |
| --- | --- |
| `IR/Type.mbt` | `HalfType`、`BFloatType`、`FloatType`、`DoubleType`、`FP128Type`；`Int1Type`、`Int8Type`、`Int16Type`、`Int32Type`、`Int64Type`；`VoidType`、`LabelType`、`MetadataType`、`TokenType`；每类的 `Show`、`Type`、`FPType`/`IntegerType`/`PrimitiveType`/`AbstractType` impl 与 public extend |

- [x] 说明每个 wrapper 的 LLVM 语义、固定宽度、Context ownership 和各分类转换。
- [x] 常规 trait impl 使用简短摘要，不为同类固定宽度类型复制大段生命周期说明。
- [x] 用一个 representative scalar-type 示例覆盖获取、分类和打印，其余同族类型通过 `See also` 或简短说明关联。

建议提交信息：`docs(IR): document concrete scalar types`

### Commit 6：记录 composite Type 与可变 Struct 契约

| 文件 | 公开对象 |
| --- | --- |
| `IR/Type.mbt` | `FunctionType` 及参数/返回值查询；`StructType`、`SetBodyForNonOpaqueStruct`、`setBody` 与状态/元素查询；`ArrayType`；`VectorType`；`ScalableVectorType`；`PointerType` 及 AddressSpace/可加载性查询；上述类型的 `Show`、`Type`、`AggregateType`、`AbstractType` impl 与 public extend |

- [x] 明确 FunctionType 参数索引、vararg 与返回 borrowed Type 的生命周期。
- [x] 区分 literal、named、opaque、empty-body 和 packed Struct，并明确 `setBody` 的前置条件、副作用及错误。
- [x] 区分 fixed/scalable vector 的 element count 语义，说明 opaque pointer 与 AddressSpace。
- [x] 为 opaque struct 的“创建后再 set body”工作流提供本阶段的主要 doc test。

建议提交信息：`docs(IR): document composite type contracts`

## 检查点一：审核根 owner 与 Type 契约

完成 Commit 2—6 后暂停，重点检查：

- `Context` 是否被准确描述为 owner，Type/Constant 是否只锚定 Context，Module/Builder 是否没有被误写成 Context-owned value。
- safe API 的同 Context 要求、borrowed Type 返回值和 opaque Struct 状态机是否清晰。
- enum constructor 与 trait method 是否逐项说明，常规 impl 是否避免无意义模板膨胀。
- 文档是否没有把当前实现细节或 raw LLVM-C symbol 错当成安全层用户契约。

## 第二阶段：安全 IR 的 Value、Module 与 Instruction

### Commit 7：记录 Value hierarchy 与 Constant wrappers

| 文件 | 公开对象 |
| --- | --- |
| `IR/Value.mbt` | `ValueRef`、`ValueEnum`、`Value`；`Constant`/`ConstantEnum`；`Instruction`/`InstructionEnum`；`GlobalValue`/`GlobalEnum`；全部 trait method、enum constructor 和 public extend |
| `IR/Constants.mbt` | `ConstantInt`、`ConstantFP`、`ConstantPointerNull`、`ConstantArray`、`ConstantStruct`、`ConstantVector`、`ConstantExpr`、`UndefValue`、`PoisonValue`；整数读取方法及全部 `Value`/`Constant`/`Show` impl |

- [x] 说明各 Value category、dynamic classification、trait-object conversion 与 raw `ValueRef` 的危险边界。
- [x] 明确 `replaceAllUsesWith` 的 mutation、类型前置条件，以及 `removeFromParent`/`eraseFromParent` 的生命周期风险；不得掩盖 Q-09 已知问题。
- [x] 区分 ConstantInt 的 signed/unsigned 读取语义，并说明各种 Constant 的 Context anchor。
- [x] 使用一个 representative Value/Constant 分类示例，不给每个 wrapper 重复相同示例。

建议提交信息：`docs(IR): document values and constants`

### Commit 8：记录 Module、Function、GlobalValue、Attribute 与 DataLayout

| 文件 | 公开对象 |
| --- | --- |
| `IR/Module.mbt` | `Module`；Function/global 创建与查询；名称、source filename、triple、data layout getter/setter；`VerificationError`/`verify`；`WriteBitCodeToFileFailed`/`writeBitCodeToFile`；`dump`、`Show` |
| `IR/Function.mbt` | `Function`、`Argument`；全部名称、类型、参数、BasicBlock、attribute 方法及 `Value`/`GlobalValue`/`Show` impl |
| `IR/GlobalValue.mbt` | `GlobalVariable`、`GlobalConstant`、`Linkage`、`UnnamedAddr`；全部 enum constructor 和 `Value`/`GlobalValue`/`Show` impl |
| `IR/Attributes.mbt` | `Attribute`、`FnAttr`、`ParamAttr`、`RetAttr` 及全部公开 constructor |
| `IR/DataLayout.mbt` | `DataLayout` 及 size/store/alloc/alignment 查询 |

- [x] 说明 `Module` 的 managed ownership、派生对象保活关系、verify/emission 前的 target 状态，以及 dump/bitcode 文件副作用。
- [x] 说明 Function/Argument/GlobalValue 对 Module 的 anchor，nullable 查询与 mutation 的可观察结果。
- [x] 为所有 Linkage、UnnamedAddr 和 attribute constructor 说明 LLVM 语义及 target/ABI 相关限制。
- [x] 明确 DataLayout 是 Module-borrowed view，并区分 bit size、store size、alloc size 与 ABI alignment。

建议提交信息：`docs(IR): document modules and global values`

### Commit 9：记录 BasicBlock 与非控制流 Instruction wrappers

| 文件 | 公开对象 |
| --- | --- |
| `IR/BasicBlock.mbt` | `BasicBlock`、`BasicBlockHasNoParentError`；parent/previous/next、instruction/terminator 查询；`moveBefore`、`moveAfter`、`removeFromParent`、`eraseFromParent`、Context/name 方法；`Value`/`Show` impl |
| `IR/Instruction.mbt` | `AllocaInst`、`LoadInst`、`StoreInst`、`CastInst`、`UnaryInst`、`BinaryInst`；`FastMathFlags`/`to_llvm`；`IntPredicate`/`ICmpInst`；`FloatPredicate`/`FCmpInst`；`GetElementPtrInst`；相应 getter、flag mutation 和全部 `Value`/`Instruction`/`InsertPoint`/`Show` impl |

- [x] 明确 BasicBlock 的 Module anchor、parent nullable 语义、移动/摘除/删除的副作用和 handle 失效风险。
- [x] 为全部 predicate/flag constructor 写准确语义，说明 GEP `inbounds` 不是普通性能提示。
- [x] 常规 wrapper impl 简述分类与打印行为；生命周期说明集中放在 wrapper 与 mutation API，避免重复。

建议提交信息：`docs(IR): document blocks and data instructions`

### Commit 10：记录 aggregate、control-flow 与 call Instruction

| 文件 | 公开对象 |
| --- | --- |
| `IR/Instruction.mbt` | `SelectInst`、`ExtractValueInst`、`InsertValueInst`、`PHINode`；`ReturnInst`；`BranchInst`、`InValidOperation` 及 condition/successor API；`SwitchInst`、`SwitchInstError` 及 case/successor API；`TailCallKind`、`CallInst` 及 tail-call API；全部相关 `Value`/`Instruction`/`InsertPoint`/`Show` impl |

- [x] 为 PHI incoming、aggregate index、branch/switch successor 等索引与类型条件写明 `None`、error 和 precondition 的区别。
- [x] 说明 CFG mutation、副作用、BasicBlock/Module 一致性和已有 wrapper 的生命周期。
- [x] 为 TailCallKind 每个 constructor 说明 LLVM 语义，避免把 `musttail`、`tail`、`notail` 写成同义状态。

建议提交信息：`docs(IR): document control-flow instructions`

### Commit 11：记录 TargetMachine 与 native object emission 契约

| 文件 | 公开对象 |
| --- | --- |
| `IR/TargetMachine.mbt` | `TargetTriple`、`TargetRegistryError`、`TargetRegistry`、`Target`；`CodeGenOptimizationLevel`、`RelocationMode`、`CodeModel`；`TargetMachineOptions`/`Default`；`TargetMachineError`、`TargetMachine`；lookup、host/create、配置、查询与 object emission 全部公开方法 |

- [x] 把 C-06 已冻结的 process-global registry、registry-owned Target 和 managed TargetMachine ownership 写成正式 Lifecycle/Thread safety 契约。
- [x] 说明显式 native 初始化与 host convenience、generic CPU/features 默认值、host-only 与 cross-target 边界。
- [x] 逐项说明 codegen enum constructor，并明确 `configureModule -> verify -> emitObjectToFile` 三阶段及各自副作用和错误。
- [x] 标准 doc test 展示安全层最小配置/emission 调用；链接和执行继续只存在于 `native_emission_test`，不进入 doc test。

建议提交信息：`docs(IR): document native code generation APIs`

## 检查点二：审核安全 IR 对象与生命周期

完成 Commit 7—11 后暂停，重点检查：

- Module-owned 与 Context-owned wrapper 是否没有混淆；`DataLayout`、`Target`、`TargetMachine` 的 ownership 是否准确。
- `removeFromParent`、`eraseFromParent`、RAUW、CFG mutation 是否诚实描述了当前风险，而没有暗示已解决 Q-09。
- error constructor、nullable getter、index 边界和 typed error 是否与实现一致。
- native emission 的初始化、配置、验证、输出步骤是否与 C-06 的已采用契约一致。

## 第三阶段：安全 IRBuilder

### Commit 12：记录 Builder 状态、返回/内存与算术构造器

| 文件 | 公开对象 |
| --- | --- |
| `IR/IRBuilder.mbt` | `BuilderError`、`InsertPoint for BasicBlock`、`IRBuilder`、`getInsertBlock`、`setInsertPoint`；`createRet`、`createRetVoid`、`createAlloca`、`createLoad`、`createStore`；整数/浮点 add/sub/mul/div/rem；`createFNeg`；bitwise and/or/xor/not、shift、`createPtrDiff` |

- [x] 统一已有早期文档格式，说明 insertion point 状态、Module anchor 和 `BuilderError` 各 constructor。
- [x] 对 arithmetic flags（NSW/NUW/exact）、shift、load/store alignment/type 等非显然约束写 Parameters/Preconditions。
- [x] 每个 builder family 保留一个代表性 Example，不重复相同的 Context/Module/Function setup。

建议提交信息：`docs(IR): document builder arithmetic and memory APIs`

### Commit 13：记录比较、转换与 GEP 构造器

| 文件 | 公开对象 |
| --- | --- |
| `IR/IRBuilder.mbt` | `createICmp` 及全部 ICmp convenience；`createFCmp` 及全部 FCmp convenience；`createTrunc`、`createZExt`、`createSExt`、`createFPTrunc`、`createFPExt`、FP/int 双向转换、`createBitCast`、`createIntToPtr`、`createPtrToInt`；`createGEP` |

- [x] 说明 signed/unsigned、ordered/unordered predicate 的差异；convenience 方法引用共同契约而不复制大段文字。
- [x] 对 cast 的 source/destination type 约束和 GEP source element type、indices、inbounds 语义写明错误与前置条件。
- [x] 审核已有 Example 是否真正验证所描述的 instruction，而不是只检查一段无关 Module 文本。

建议提交信息：`docs(IR): document builder comparisons and casts`

### Commit 14：记录控制流、call、aggregate 与 runtime memory 构造器

| 文件 | 公开对象 |
| --- | --- |
| `IR/IRBuilder.mbt` | `createBr`、`createCondBr`、`createSelect`、`createSwitch`、`createPHI`；`createCall`、`createCallPtr`；`createInsertValue`、`createExtractValue`；`createMalloc`、`createFree`、`createMemCpy`、`createMemSet`、`createMemMove`、`createGlobalString` |

- [x] 说明 CFG target、PHI incoming 后续步骤、callee/function type 匹配和 pointer-call 契约。
- [x] 说明 aggregate indices、memory intrinsic length/alignment/overlap、malloc/free 和 global string 对 Module 的副作用。
- [x] 以一个最小函数构造示例覆盖 builder 标准工作流；长程序继续留在 tutorial。

建议提交信息：`docs(IR): document builder control-flow and runtime APIs`

## 检查点三：审核 IRBuilder 用户体验

完成 Commit 12—14 后暂停，重点检查：

- 同族 builder 方法是否共享一致术语，但每个方法仍能仅凭自身文档理解关键差异。
- `BuilderError`、类型关系、insertion point 和 Module/Context 关系是否准确。
- Example 是否足够代表主要工作流，又没有复制几十份 setup 或使用 `.unwrap()` 教坏用户。
- 本阶段是否只整理文档，没有顺手修正签名、错误类型或实现行为。

## 第四阶段：unsafe 公共类型与 enum

### Commit 15：记录 raw handle、数值 wrapper 与 null helper

| 文件 | 公开对象 |
| --- | --- |
| `unsafe/Types.mbt` | `LLVMAttributeIndex`、`LLVMDWARFTypeEncoding`、`LLVMMetadataKind`；全部 opaque `*Ref` type（Context、Module、Value、Type、Builder、Metadata、Target、TargetMachine、ORC、Error 等）；ORC address/symbol flag 数值 wrapper；上述 wrapper 的 new/into、Eq、Show impl |
| `unsafe/utils.mbt` | Type/Value/Use/BasicBlock/Attribute/Comdat raw ref 的 `is_null`/`is_not_null` 与 `Show` impl，以及对应 public helper extern |
| `unsafe/string_boundary.mbt` | `CStringError::EmbeddedNul` |

- [x] 每个 raw handle 说明它是 opaque pointer identity，不单独暗示 ownership；具体 allocator/disposer 责任留给产生和消费它的函数。
- [x] 明确 null sentinel、pointer identity Eq、Show 输出用途，以及 address/flag wrapper 的单位和转换语义。
- [x] raw handle 文档不提供鼓励绕过安全 `IR` 层的 Example。

建议提交信息：`docs(unsafe): document raw handles and helpers`

### Commit 16：记录 Core IR enum 与整数映射

| 文件 | 公开对象 |
| --- | --- |
| `unsafe/Types.mbt` | `LLVMFastMathFlags`；`LLVMOpcode`、`LLVMTypeKind`、`LLVMLinkage`、`LLVMVisibility`、`LLVMUnnamedAddr`、`LLVMDLLStorageClass`、`LLVMCallConv`、`LLVMValueKind`、`LLVMIntPredicate`、`LLVMRealPredicate`、`LLVMLandingPadClauseTy`、`LLVMThreadLocalMode`、`LLVMAtomicOrdering`、`LLVMAtomicRMWBinOp`；全部 constructor、`to_int`/`from_int` 与相关 Show impl |

- [x] 按 LLVM 19 语义逐项说明 enum constructor，保留 deprecated/compatibility value 的状态。
- [x] 说明 `from_int` 对未知值的行为，不把内部 `unreachable` 或默认映射包装成安全解析保证。
- [x] 将大量机械转换方法保持简短，但不得省略 enum 本身和 constructor 的含义。

建议提交信息：`docs(unsafe): document core LLVM enums`

### Commit 17：记录 toolchain、debug、target 与 ORC enum

| 文件 | 公开对象 |
| --- | --- |
| `unsafe/Types.mbt` | `LLVMDiagnosticSeverity`、`LLVMInlineAsmDialect`、`LLVMModuleFlagBehavior`、`LLVMTailCallKind`、`LLVMComdatSelectionKind`、`LLVMLinkerMode`、`LLVMCodeGenOptLevel`、`LLVMRelocMode`、`LLVMCodeModel`、`LLVMCodeGenFileType`、`LLVMGlobalISelAbortMode`、`LLVMBinaryType`、`LLVMDIFlags`、`LLVMDWARFSourceLanguage`、`LLVMDWARFEmissionKind`、`LLVMMDNodeKind`、`LLVMVerifierFailureAction`、`LLVMRemarkType`、`LLVMJITSymbolGenericFlags`；全部 constructor、整数转换与 Show impl |

- [x] 标明 target/platform 限制、bitflag 与普通 enum 的区别、LLVM 19 对应值和 deprecated constructor。
- [x] 对 verifier action、linker mode、codegen file type 等有副作用含义的取值写出调用者可观察后果。

建议提交信息：`docs(unsafe): document LLVM subsystem enums`

## 检查点四：审核 raw type 表示

完成 Commit 15—17 后暂停，重点检查：

- raw handle 文档是否没有制造虚假的 ownership 或自动释放承诺。
- enum constructor 是否遵循 LLVM 19，而不是只依据名称猜测。
- deprecated value、未知整数、bitflag 与普通 enum 的边界是否清楚。
- `unsafe` 文档是否明确其风险，同时没有把所有函数笼统描述为“unsafe”。

## 每个实现 commit 的验收要求

Commit 2—28 每次提交前：

- [ ] 运行 `moon fmt`。
- [ ] 运行 `moon info`，检查所有 `.mbti` 的公开 API shape 不变；生成文件不得手工编辑。
- [ ] 运行 `moon check --target native`。
- [ ] 若当前 commit 改动 `IR`，额外运行 `moon check IR --target native --warn-list '+missing_doc'`，确认 warning 只减少且当前声明范围已清零。
- [ ] 若当前 commit 改动 `unsafe`，额外运行 `moon check unsafe --target native --warn-list '+missing_doc'`，确认 warning 只减少且当前声明范围已清零。
- [ ] 运行 `moon test --target native`，保证新增和既有 doc test 全部通过。
- [ ] 运行 `git diff --check`，确认只包含当前 commit 列出的源码文档和 C-07 勾选状态。
- [ ] 审核 diff 中的 `pub struct`、`pub enum`、`pub trait`、`pub fn`、`pub impl`、trait method、公开字段和 enum/error constructor，没有仅添加空 `///|`。
- [ ] 对照本机 LLVM 19 header 或现有已验证行为检查 `unsafe` 契约；不得依据名称猜测 ownership、返回码或线程安全。

最终完成时：

- [ ] `moon check IR --target native --warn-list '+missing_doc'` 为 0 条 `missing_doc`。
- [ ] `moon check unsafe --target native --warn-list '+missing_doc'` 为 0 条 `missing_doc`。
- [ ] 对已有文档进行人工抽查，确认不是只消除了 warning，且没有空泛的“Gets X”“Sets X”或整段模板复制。
- [ ] 所有 `.mbti` 的公开签名、可见性与类型 shape 相对 Commit 1 无变化。
- [ ] `moon check --target native` 与 `moon test --target native` 通过；不修改 CI 或 coverage 门槛。

## 发现契约或实现问题时的边界

- 文档任务不顺手修改 API。若无法在不撒谎的前提下描述某个公开接口，例如存在悬空 extern、反向 `LLVMBool` 被包装错误、ownership transfer 未建模、可能稳定触发 UAF，立即停止当前 commit，记录到 `docs/discussion` 并由用户决定。
- 已有文档与 LLVM 19 不一致时，本 commit 可以修正文档；已有实现与 LLVM 19 不一致时不能仅修改文档迎合实现，也不能在文档 commit 中修实现。
- 新增 doc test 暴露行为错误时，不用错误快照把问题固化为契约；保留最小证据并转入 discussion。
- 只与实现维护有关的信息使用普通 `//` 注释，不加入公开 `Dev Notes`；会影响用户调用的实现约束必须进入正式的 Lifecycle、Preconditions、Safety 或 Side effects。
- 同一文件跨多个 commit 时严格按本文列出的对象族修改；若一次格式化会改动尚未进入当前批次的大量既有代码，应先缩小改动或调整 commit 边界，不把无关格式 diff 混入文档审核。
