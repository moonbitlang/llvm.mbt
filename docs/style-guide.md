# 代码风格指南

## `raise` 必须尽量标明错误类型

函数只向上传递一种错误类型时，必须在 `raise` 后写明该类型；同一 `suberror` 的不同构造器仍算一种错误类型。只有函数会向上传递两种及以上不同的错误类型，并且这些错误都需要保留时，才可以省略错误类型写成开放的 `raise`。已经在函数内部捕获或转换的错误不计入对外传播的错误类型。

## C 文件注释与 MoonBit FFI 标记

每个 C 文件都应在文件开头简要说明其用途、所属的 MoonBit native stub 边界，以及主要处理的 ABI 或所有权问题。本仓库实现且被 MoonBit `extern "C"` 引用的每个 C 入口，都必须在定义前使用固定格式标明对应的 MoonBit 声明；白盒测试入口应明确写成 `MoonBit wbtest extern`。直接绑定上游 LLVM 符号、并非由本仓库 C 文件实现的接口不适用此要求。

```c
/* MoonBit extern: ContextOwner::raw (IR/resource_owner.mbt). */
```

如果接口涉及所有权转移、borrowed pointer、引用计数、finalizer、分配与释放配对、pointer+length、NUL、编码、`NULL`、错误处理、全局状态或线程安全，注释还必须写明 MoonBit 类型签名无法表达的边界契约，而不能只复述函数名和参数。finalizer、managed external object 的 control block 及其父子资源释放顺序必须注释。

普通 `static` helper 不要求机械地逐个注释；只有存在非显然的不变量、调用顺序、兼容性处理或刻意延后的边界问题时才需要解释。非 `static` 函数如果不是 MoonBit FFI 入口，应明确说明其跨 C 文件用途，否则应考虑收紧为 `static`。测试 C 文件及测试入口必须明确标记为测试设施，并说明是否持有被观察对象以及并发限制。

## 公开 API 的文档注释

除下文明确排除的 `unsafe` package 外，所有会成为公开接口的声明都必须有文档注释，包括公开的 type、struct、enum、error、trait、fn、method、impl、字段、枚举构造器及常量。每个公开声明至少要有一句能够脱离函数名和类型签名单独理解的摘要；trait 的公开方法、enum 和 error 的公开构造器、struct 的公开字段也必须分别说明，不能只依赖外层类型的总说明。

文档注释采用“摘要必填、其余章节按契约条件必填”的方式。没有内容的章节必须整体省略，禁止为了满足模板而保留空标题或复述签名。简单 getter 或语义完全常规的 impl 可以只有一句摘要；涉及 native resource、borrowed view、FFI 安全边界或调用顺序的接口必须完整说明相应契约。

摘要不设置 `Description` 标题。函数和方法的摘要应直接说明实际效果，例如使用 `Creates`、`Returns`、`Sets` 或 `Verifies`，而不是仅仅展开函数名。后续无标题段落可以补充语义以及它与相似接口的区别。

### 标准章节及顺序

需要使用章节时，按以下顺序排列，并使用表中的固定标题：

| 章节 | 使用条件 | 内容 |
| --- | --- | --- |
| 摘要 | 必填 | 一句话说明声明是什么或做什么 |
| 详细说明 | 可选，无标题 | 补充语义、适用范围及与相似接口的区别 |
| `**Construction:**` | opaque type 或不能直接构造的类型 | 说明应从哪些公开 API 获得实例 |
| `**Parameters:**` | 参数语义无法从名称和类型直接判断 | 说明参数含义、约束、默认值和特殊值；方法的 `self` 仅在其状态或生命周期约束不明显时列出 |
| `**Returns:**` | 返回值语义并非显然 | 说明结果含义、ownership、borrowing、特殊值和布尔约定；普通 `Unit` 或明显 getter 可以省略 |
| `**Errors:**` | 可能 `raise` 或以返回值报告失败 | 逐项说明公开错误及其准确触发条件；诊断信息的含义也应说明 |
| `**Preconditions:**` | 存在类型系统无法表达的调用者义务 | 说明调用前必须成立的状态、同一 Context/Module 等关系或调用顺序 |
| `**Panics:**` | 合法的公开调用仍可能 panic 或 abort | 说明触发条件；安全层 API 应尽量避免这种契约 |
| `**Safety:**` | 违反约束可能导致崩溃、悬空引用、LLVM assertion 或未定义行为 | 说明避免破坏 native 状态所必须遵守的规则，`unsafe` 层存在此类风险时必须填写 |
| `**Lifecycle:**` | 涉及 native handle、owner、borrowed view、parent/child 或显式释放 | 说明所有者、借用关系、有效期、失效条件、释放责任及别名影响 |
| `**Side effects:**` | 操作并非纯查询 | 说明被修改的 IR、LLVM 全局状态、文件系统、诊断输出等可观察状态 |
| `**Thread safety:**` | 涉及共享对象、LLVM 全局状态或并发限制 | 说明可否并发调用、可否跨线程使用及外部同步要求 |
| `**Platform support:**` | 行为受 host、target 或平台能力限制 | 说明 native-only、host-only、cross-target 等限制 |
| `**LLVM API:**` | 直接 LLVM-C binding，或上游映射有助于理解 | 给出对应 LLVM-C 符号，并说明 MoonBit 包装对参数、返回值或错误模型做出的差异；为 `unsafe` 接口编写文档时按需使用 |
| `**Notes:**` | 可选 | 记录性能、兼容性等非核心补充信息；关键契约不得只放在这里 |
| `**See also:**` | 可选 | 列出相关构造器、反向操作或推荐的后续 API |
| `**Examples:**` | 符合下文示例标准 | 给出最小、可运行且只使用公开 API 的示例 |

标题中的冒号必须位于粗体标记内，例如 `**Parameters:**`。统一使用复数形式 `Side effects`，不使用 `Side Effect`。

`Errors` 表示调用者能够观察并处理的失败；`Preconditions` 表示接口不负责建立、必须由调用者提前保证的条件；如果违反条件还可能破坏 native 状态，则同时在 `Safety` 中说明后果和约束。

`Lifecycle` 至少应回答与该接口相关的以下问题：谁拥有底层 LLVM 对象；返回值是 owned handle 还是 borrowed view；它在什么期间有效；owner 销毁或变更后是否失效；哪些操作会使已有引用失效；用户是否负责显式释放。不得用笼统的“由 GC 管理”代替这些公开契约。

不要在公开文档中设置 `Dev Notes`。仅与当前实现有关的信息应写成普通 `//` 注释或放入开发文档；如果某项实现信息会限制用户的调用方式，则应提升为 `Preconditions`、`Lifecycle`、`Safety` 或其他对应的公开契约。

### `unsafe` package 例外

`unsafe` package 是安全 `IR` 层的低层实现基础，强烈不建议库用户直接使用。该 package 中的公开声明不适用“每个公开声明都必须有文档注释”的要求；机械性的 LLVM-C binding、raw enum constructor、整数转换和常规 impl 可以不提供文档，也不以消除 `missing_doc` 为目标。

本例外不要求删除已经存在的注释。现有注释仅描述 raw binding，不表示接口安全、稳定或受到推荐。是否为 `unsafe` 中的特定接口强制记录 ownership、nullability、释放配对及其他 FFI 契约，应通过单独的设计讨论确定；在该策略确定前，本指南不强制逐接口补齐。

如果选择为某个 `unsafe` 接口编写文档，内容仍必须准确，并按本节的标准章节表达适用的 `Safety`、`Lifecycle`、`LLVM API` 等契约。此例外只放宽 MoonBit 公开声明的文档覆盖要求，不放宽前文对 C 文件、FFI 入口和非显然实现边界注释的要求，也不允许安全 `IR` 层把自身契约留给 `unsafe` 层或 LLVM 上游文档解释。

### 不同声明的补充要求

- `pub struct` 和 opaque `pub type` 必须说明其代表的 LLVM 概念、构造入口，以及它是 owner、borrowed view 还是纯 MoonBit 值。存在 native 生命周期时，还必须说明能否长期保存以及 owner 失效后的行为。公开字段需要逐字段注释，私有字段不在公开文档中逐项解释。
- `pub enum` 必须说明整组取值控制的语义，每个公开构造器都要单独说明。`Default` 由谁决定、取值是否完整映射 LLVM、未知上游值如何处理、是否存在 target 限制等非显然行为必须写明。
- `pub suberror` 必须说明它代表的失败领域，每个构造器都要说明准确触发条件及 payload 含义。错误处理示例通常放在产生该错误的函数上。
- `pub trait` 必须说明其抽象能力、预期实现者和实现者必须维持的语义约束。面向第三方实现且存在非显然约束时，增加 `**Implementor contract:**`；每个公开 trait method 仍需独立文档。
- `pub fn` 和公开方法必须说明实际动作。参数名或返回类型不足以表达 ownership、借用、特殊布尔值、错误状态及 mutation 时，必须使用对应章节补充。
- `pub impl` 至少要有一句行为摘要。常规 impl 不需要重复 trait 的全部说明；非显然的相等性、哈希或格式化语义必须说明，例如比较的是句柄身份还是结构内容，以及 `Show` 输出的是完整 IR 还是调试摘要。
- 为 `pub extern \"C\"` 或其他 `unsafe` 层接口编写文档时，应特别检查 nullability、`LLVMBool` 约定、字符串编码和释放方式、handle ownership、parent 生命周期、调用顺序、LLVM assertion、全局状态与线程安全；是否要求该接口必须具有文档，遵循上面的 `unsafe` package 例外。
- 公开常量必须说明单位、特殊值、有效范围以及它与 LLVM 上游常量的对应关系；名称和类型已经完整表达语义时，一句摘要即可。

### Example 标准

不要求每个公开声明都有 Example。目标是每个公开功能族至少有一个可运行示例，而不是为 getter、enum variant、机械性的 trait impl 或同族重载重复相同代码。

以下情况原则上必须提供 Example：

- 公开类型的主要构造入口；
- 有状态或有调用顺序的工作流入口；
- 参数之间存在非显然关系的接口；
- 生命周期容易误用的接口；
- 修改结果无法从名称直接推断的 API；
- 错误处理本身是主要使用场景的 API。

明显的 getter、单个 enum 或 error 构造器、普通 `Eq`/`Show` impl、已被同族主示例完整覆盖的辅助方法，以及不推荐直接使用的机械性 raw binding 可以省略 Example。`unsafe` package 的文档覆盖范围遵循上面的例外。

示例必须满足以下要求：

- 使用 `mbt check`，并能通过 `moon check` 和 `moon test`；不能执行的伪代码不得放入 `mbt check` 代码块；
- doc test 按黑盒测试编写，只使用公开 API，不依赖同包私有实现；
- 示例独立且具有确定性，不依赖测试执行顺序、网络、随机数、当前时间或不必要的外部进程；
- 优先展示最短的成功路径，验证稳定的可观察结果时优先使用 `inspect`；
- 不把随意调用 `.unwrap()` 作为推荐用法；错误处理属于示例重点时使用 `match`；
- 单个示例通常控制在约 20 行以内。编译、链接、运行 object file 等依赖外部工具的重型流程放入 `test` 包，长篇完整程序放入教程或 `.mbt.md`；
- 不为每个重载复制示例；在代表性接口中给出一个完整示例，并通过 `See also` 指向同族 API。

### 参考模板

以下模板列出所有可能的章节，仅用于选择，不允许把不适用的空章节复制到实际文档中：

````moonbit
///|
/// <One-sentence summary.>
///
/// <Optional details and semantic distinctions.>
///
/// **Parameters:**
///
/// - `parameter`: <Meaning, constraints, defaults, and special values.>
///
/// **Returns:**
///
/// <Meaning, ownership, borrowing, and special cases.>
///
/// **Errors:**
///
/// - `<Error>` when <condition>.
///
/// **Preconditions:**
///
/// - <Condition the caller must establish.>
///
/// **Panics:**
///
/// <Conditions that can cause a panic or abort.>
///
/// **Safety:**
///
/// <Rules needed to avoid invalid native state or undefined behavior.>
///
/// **Lifecycle:**
///
/// <Owner, borrowing relationship, validity period, and invalidation rules.>
///
/// **Side effects:**
///
/// <State, IR objects, files, or global registries modified by the call.>
///
/// **Thread safety:**
///
/// <Concurrency guarantees and restrictions.>
///
/// **Platform support:**
///
/// <Target or host restrictions.>
///
/// **LLVM API:**
///
/// <Corresponding LLVM-C API and relevant differences.>
///
/// **Notes:**
///
/// <Non-contractual supplementary information.>
///
/// **See also:**
///
/// - `<Related API>`
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   ...
/// }
/// ```
````
