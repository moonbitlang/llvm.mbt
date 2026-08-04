# StringError 与 getName 改动的 commit 划分

> 状态：计划中
> 日期：2026-08-04

本轮按照 [Q-05](../Q-05-ir-string-error.md) 和 [Q-06](../Q-06-get-name-return-model.md) 已采用的方案实施。每个 commit 只处理一个可独立审核的部分；相关 `.mbti` 与源码放在同一个 commit，不单独提交生成文件。

## Commit 1：记录已采用的讨论方案

- [x] 提交 Q-05、Q-06 的“已解决”状态和 A2 最终方案。
- [x] 同步 T-02 中两个问题的状态。
- [x] 不包含代码改动。

建议提交信息：`docs: adopt IR string error decisions`

## Commit 2：建立 IR.StringError 基础设施

- [x] 新增 `IR/StringError.mbt`。
- [x] 定义 `StringError::ContainsNul` 和 `StringError::MalformedUtf8(Bytes)`。
- [x] 增加私有的 `CStringError -> StringError` 和 `@utf8.Malformed -> StringError` 转换 helper；helper 保持直接、简短，不建立额外抽象框架。
- [x] 按需更新 `IR/moon.pkg` 和 `IR/pkg.generated.mbti`。
- [x] 不修改现有公开函数。

建议提交信息：`IR: introduce StringError`

## Commit 3：转换 Module 文本 getter 的错误

- [x] 处理 `Module::getName`。
- [x] 处理 `Module::getSourceFileName`。
- [x] 两个函数仍返回 `String`，只把 `@utf8.Malformed` 转换为 `StringError`。
- [x] 更新对应公开接口。

建议提交信息：`IR: map module text getters to StringError`

## Commit 4：统一 Value 名称 getter

- [x] 将 `Value::getValueName` 改为 `String? raise StringError`。
- [x] 将 `Function::getName`、`Argument::getName`、`BasicBlock::getName` 统一为相同返回模型。
- [x] `None` 只表示没有名字；非法 UTF-8 通过 `StringError::MalformedUtf8` 传播。
- [x] 尽量让专用 getter 复用 Value 名称的共同实现。
- [x] 更新相关 doc test、调用示例和 `.mbti`。

建议提交信息：`IR: unify Value name getters`

## 检查点一：审核错误类型和 getter API

完成 Commit 1—4 后暂停，重点检查：

- `StringError` 的构造器和 payload 是否合适。
- 底层错误到 IR 错误的转换是否直接可读。
- `String? raise StringError` 是否在 Value、Function、Argument、BasicBlock 中保持同一语义。
- Module Identifier 是否仍与可选 Value 名称明确区分。

## Commit 5：校验 Value 名称 setter

- [x] 处理 `Value::setValueName`。
- [x] 处理 `Function::setName`、`Argument::setName`、`BasicBlock::setName`。
- [x] 在调用 LLVM 前拒绝名称中的 NUL，并传播 `StringError::ContainsNul`。
- [x] 不改变 `Module::setName` 和 `Module::setSourceFileName`；它们使用 pointer + length API，不能仅因使用长度参数就自动拒绝 NUL。
- [x] 更新对应 `.mbti` 和文档示例。

建议提交信息：`IR: validate Value names on set`

## Commit 6：转换非 Builder 的命名构造 API

- [x] 处理 `Context::addModule`、`Context::getStructType`。
- [x] 处理 `Module::addFunction`、`Module::addGlobalVariable`、`Module::addGlobalConstant`、`Module::setDataLayout`。
- [x] 处理 `Function::addBasicBlock`。
- [x] 捕获 `@unsafe.CStringError` 并转换为 `IR.StringError`，公开接口不再暴露 `@unsafe.CStringError`。
- [x] 不顺便修改这些函数的其他错误模型。

建议提交信息：`IR: map named construction errors`

## 检查点二：审核普通 IR API 的字符串错误边界

完成 Commit 5—6 后暂停，重点检查：

- Value setter 对 NUL 的处理是否符合 LLVM 名称约束。
- 非 Builder 公开 API 是否已经不再暴露 `@unsafe.CStringError`。
- pointer + length API 与 NUL-terminated API 是否仍被分别处理。
- 每个函数是否保留原有的自然失败通道。

## Commit 7：转换 IRBuilder 的整数操作名称错误

- [x] 处理 allocation/load 等带名称的基础入口。
- [x] 处理整数 add、sub、mul、div、rem 各族的基础入口。
- [x] 只转换名称引发的 `CStringError`；不调整 `BuilderError` 和其他 `raise` 标注。

建议提交信息：`IRBuilder: map integer operation name errors`

## Commit 8：转换 IRBuilder 的浮点与位操作名称错误

- [x] 处理浮点 add、sub、mul、div、rem、neg。
- [x] 处理 and、or、xor、not、shift 和 ptrdiff。
- [x] 只修改直接调用 unsafe 字符串 API 的基础入口，派生 convenience API 继续复用基础入口。

建议提交信息：`IRBuilder: map floating and bitwise name errors`

## Commit 9：转换 IRBuilder 的比较与转换操作名称错误

- [x] 处理 ICmp、FCmp 的基础入口。
- [x] 处理各种 cast。
- [x] 处理 GEP 和 select 等相邻的带名称操作。
- [x] 不重复修改只委托给基础入口的 `createICmpEQ`、`createFCmpOEQ` 等 convenience API。

建议提交信息：`IRBuilder: map comparison and cast name errors`

## Commit 10：转换 IRBuilder 的聚合、调用及剩余名称错误

- [ ] 处理 PHI、Call、CallPtr。
- [ ] 处理 InsertValue、ExtractValue、Malloc、GlobalString。
- [ ] 检查并处理此前各组未覆盖的其余带字符串基础入口。
- [ ] 确认 IRBuilder 不再向上传递底层 `@unsafe.CStringError`。

建议提交信息：`IRBuilder: map aggregate and call name errors`

## 每个代码 commit 的检查要求

- [ ] 运行 `moon fmt`。
- [ ] 运行 `moon info`，检查 `.mbti` 变化是否只来自当前 commit。
- [ ] 在配置 `env.sh` 后运行 `moon check --target native`。
- [ ] 当前阶段不添加测试；测试问题继续延后。
- [ ] 不混入 UTF-16、raw bytes API、其他 `raise` 规范修复或无关重构。
