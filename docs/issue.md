# Runa LLVM lowering 所需接口

本文记录 Runa 接入 llvm.mbt 时需要补齐的公开能力，供独立实现会话使用。核对基线为 `Kaida-Amethyst/llvm@0.5.1`；Runa 一侧的设计见相邻仓库 `../Runa/llvm/draft.mbt.md`。这里是需求与接口建议，不表示代码已经实现或发布。

Runa 从带 block parameter 的 SSA 生成 LLVM IR，首版包含标量、直接调用、分支、循环、局部 slot、global、struct 和有限 C FFI。GC 已决定采用非移动 mark-sweep 与编译器生成的显式根栈，不依赖 statepoint 才能开始实现。

## 1. 风格与交付约定

- 遵守本仓库 [style-guide.md](style-guide.md)，公开接口沿用现有的 C++ 风格 camelCase，例如 `createUnreachable`、`getElementOffset`；不要引入 Runa 的 snake_case 或业务类型。
- 优先扩充现有 `IRBuilder`、`DataLayout`、`Function`、`CallInst` 和属性枚举。需要新增指令 wrapper 时，接入现有 Value/Instruction/InsertPoint 的分类、转换、trait 扩展和 module owner 机制，不暴露 raw handle 给下游。
- 本文代码块是签名草图，不是 doc test。最终错误类型遵守本库规则：只传播一种错误时写明 `raise ErrorType`；确实传播多种错误才使用开放的 `raise`。沿用已有错误类别，只有不能准确表达时才新增。
- 文档说明 context/module 一致性、索引单位、owner 生命周期和失效条件；可检测的错误先拒绝，不能把 LLVM assertion 当成可恢复的检查。
- 更新 `.mbti`，补公开接口示例及对应正反向测试；运行本仓库规定的 native 检查。Runa 将通过已发布依赖使用这些接口，不直接导入 `internal/raw`。

## 2. 首版需要补齐

### 2.1 Unreachable 指令

**用途：** Runa 的 `Never` 调用和 SSA `Unreachable` 需要真正的 LLVM terminator。`unreachable` 本身不执行 panic，不能用它替换原本的终止调用。

**现状：** `internal/raw/Core.mbt` 已绑定 `LLVMBuildUnreachable`，`IR` 尚未提供对应 builder 方法和具体指令 wrapper。

建议接口：

```moonbit
pub struct UnreachableInst {
  // 与 ReturnInst 相同的 module-anchored ownership。
  ...
}

pub fn IRBuilder::createUnreachable(
  self : Self,
) -> UnreachableInst raise BuilderError {
  ...
}
```

没有插入点时抛出 `BuilderError::UnsetPosition`。说明合法 terminator 插入位置的约束，不插入 LLVM 无效指令序列。新 wrapper 的分类与通用指令操作必须完整接通，不只让打印出的 IR 看起来正确。

验收重点：`call void @panic()` 后接 `unreachable`，module 验证通过；未定位 builder 的错误；指令枚举及父 block 查询；不额外产生 return。

### 2.2 函数属性与调用点属性

**用途：** 正确表达 `Never`，以及 C `_Bool` 等目标 ABI 需要的参数和结果扩展。函数声明与调用点需要一致处理，不能只修饰声明。

现有枚举建议增加：

| 类型 | 新构造器 | LLVM 属性 |
| --- | --- | --- |
| `FnAttr` | `NoReturn` | `noreturn` |
| `ParamAttr` | `SExt`、`ZExt` | `signext`、`zeroext` |
| `RetAttr` | `SExt`、`ZExt` | `signext`、`zeroext` |

`Function::addFnAttr`、`Function::addRetAttr` 和 `Argument::addAttr` 已有，扩充它们所接收的枚举即可。对 `CallInst` 增加对应能力：

```moonbit
pub fn CallInst::addFnAttr(self : Self, attr : FnAttr) -> Unit {
  ...
}

pub fn CallInst::addRetAttr(self : Self, attr : RetAttr) -> Unit {
  ...
}

pub fn CallInst::addParamAttr(
  self : Self,
  index : Int,
  attr : ParamAttr,
) -> Unit raise IndexOutOfBounds {
  ...
}
```

`index` 是调用实参的零基下标；wrapper 内部转换到 LLVM 的 attribute index，不能让下游自行处理 return/function 特殊下标。底层 `LLVMAddCallSiteAttribute` 已有绑定。

如按现有 API 对称性提供 remove 方法，应共用同一套索引与属性转换。属性是否适用于完整签名与目标 ABI，需要明确文档契约；不能把所有 `FnAttr` 都宣称为任意 call site 合法。

验收重点：声明和 call site 的 return/parameter 属性位置正确；负数和越界索引被拒绝；`noreturn` 不等于自动插入 `unreachable`；属性输出和 LLVM verifier 检查。C ABI 的实际选择由 Runa 的目标 profile 负责，本库不把所有平台的 Bool 固定成同一种扩展方式。

### 2.3 显式调用约定

**用途：** Runa 要把函数声明与调用点的 convention 作为 ABI 契约记录，而非依赖 LLVM 当前的默认值。首版使用 C convention，并为未来内部 convention 保留入口。

raw 层已有 `LLVMGet/SetFunctionCallConv` 和 `LLVMGet/SetInstructionCallConv`，尚无对应的 IR 公开接口。

建议新增 `CallingConv`，至少能命名 C convention；采用枚举加未知数值分支，或其他与本库现有 raw enum wrapper 一致的表示。读取 LLVM 中已有的其他 convention 时应能保留数值，不应错误地回退为 C。

```moonbit
pub fn Function::getCallingConv(self : Self) -> CallingConv { ... }
pub fn Function::setCallingConv(self : Self, convention : CallingConv) -> Unit { ... }
pub fn CallInst::getCallingConv(self : Self) -> CallingConv { ... }
pub fn CallInst::setCallingConv(self : Self, convention : CallingConv) -> Unit { ... }
```

验收重点：声明与调用一致、非默认约定的往返、未知值的表示契约。wrapper 不负责保证任意 convention 都可用于任意目标平台。

### 2.4 Struct 字段字节偏移

**用途：** Runa 的对象描述符记录需要扫描的引用字段偏移，必须来自目标 data layout，不能自己计算 padding。

**现状：** `DataLayout` 已提供 allocation size 和 ABI alignment；`internal/raw/Target.mbt` 中的 `LLVMOffsetOfElement` 还只是注释，并未绑定。

建议接口：

```moonbit
pub fn DataLayout::getElementOffset(
  self : Self,
  ty : StructType,
  index : Int,
) -> Int raise {
  ...
}
```

这里沿用现有 size 查询的 `Int` 返回风格。实现需要明确 UInt64 到 Int 的表示范围，不能静默截断；若决定统一改进 size API，应单独说明兼容性，而非仅让本接口的单位或表示与同族方法不一致。

`index` 是 LLVM struct 的物理字段下标，结果是从 struct 起始地址算起的字节偏移。检查负数、越界、opaque/unsized struct；类型必须与 layout 的 owning module context 相容。错误分别复用索引和类型类错误，必要时补充范围错误。

验收重点：有 padding 的 struct、packed struct、嵌套 struct、显式目标 layout、非法索引和未定 body 的 struct。保持 `DataLayout` 现有的 module-owned view 生命周期，不缓存成脱离 module 的永久快照。

## 3. 希望提供，但不阻塞最小闭环

### 3.1 LLVM intrinsic 声明

Runa 的 Int 加减乘需要溢出检查，期望方便取得 `llvm.sadd.with.overflow`、`llvm.ssub.with.overflow`、`llvm.smul.with.overflow` 的 i32 声明。可以先只覆盖这一使用路径，再扩展通用 intrinsic API。

建议 `Module::getIntrinsicDeclaration(name, overloadTypes)` 返回该 module 中的 `Function`，由库完成 intrinsic ID 查询与 overload 声明；沿用 camelCase，数组元素使用现有 `&Type`。raw 已有 intrinsic lookup/declaration binding。

未知名称、错误的 overload 数量/种类和跨 context 类型需要有准确契约。若通用 LLVM API 无法安全验证所有组合，应明确 caller preconditions，不宣称所有错误都会被 wrapper 捕获；Runa 首版需要的三种整数 intrinsic 应有针对性的验证和示例。

Runa 可以暂用扩大位宽再检查范围的实现，因此此项不阻塞。`createNSWAdd` 等不能替代该需求：LLVM poison 不是语言要求的 panic。

### 3.2 长度明确的字节常量

`createGlobalString` 当前禁止输入内嵌 NUL。Runa 的字符串按 UTF-8 字节和长度表示，不能受 C-string 边界限制。

现有 `getConstInt8`/`getConstArray` 配合 `addGlobalConstant` 已可构造完整字节序列，因此无需阻塞；希望后续提供接收 `Bytes` 的常量构造便利接口，明确是否追加 NUL、长度单位、复制语义及 owner。不要悄悄改变现有 `createGlobalString` 的契约。

### 3.3 优化 pass 入口

希望后续通过公开接口配置并运行 LLVM pass pipeline，复用 raw 的 pass manager binding。此项与 object emission 分开，不要求为了开始 lowering 就建立完整优化配置系统。

## 4. 暂不要求实现的 GC 接口

`Function::setGC`、statepoint/relocate、operand bundle、stack map 等可留待后续。Runa 首版使用普通 load/store/call 构造显式根栈，collector 由 Runa runtime 实现，不要求 llvm.mbt 提供 collector，也不使用 LLVM 内置 shadow-stack 策略作为前置条件。

将来选择移动 GC 或基于 stack map 的根定位时，再单独设计这些 API 的 owner、重定位和 pass 契约。不要在本轮仅为预留名字新增一组不能可靠使用的接口。

## 5. 当前工作区实现状态（2026-09-16）

第 2 节四项必需能力已实现，公开接口见 `IR/pkg.generated.mbti`，示例在相应 API 的 doc test 中；正反向测试见 `test/runa_lowering_test.mbt`。当前构建使用仓库固定的 LLVM 22.1.0 产物，尚未发布新版本。

与签名草图相比，需要下游注意：

- `createUnreachable` 要求 builder 位于尚无 terminator 的 block 末尾；非法位置抛出 `BuilderError::InValidInsertPoint`。
- `CallInst` 同时提供三类属性的 add/remove 方法，参数下标是零基实参下标，包含可变参数。
- `CallingConv` 提供 `C`、`Fast`、`Cold`、`Other(UInt)`；读取 0/8/9 会归一为对应命名构造器。两个 `setCallingConv` 都可能抛出 `CallingConvError::InvalidID`，拒绝超过 LLVM 可表示范围 1023 的数值，其余值原样保留，不保证目标支持。
- `getElementOffset` 返回字节偏移，拒绝不相容 context、未定大小或 scalable 字段；超过 2147483647 时抛出 `DataLayoutError::OffsetOutOfRange(UInt64)`，保留原始偏移。现有 size API 的签名和转换行为未改动。

第 3 节也提供了可用的首版入口：

- `Module::getIntrinsicDeclaration(name, overloadTypes)` 当前只支持三种 signed overflow intrinsic 的无后缀名称和一个 scalar integer overload 类型；拒绝未知/未支持名称、错误 overload、跨 context 类型及冲突符号。JIT 测试覆盖正常运算、边界溢出、回绕结果和溢出标志。
- `Context::getConstBytes(bytes, nullTerminate=false)` 返回 context-owned `[N x i8]` 常量，复制输入字节，支持空输入、内嵌 NUL 和非 UTF-8 数据；传入 `nullTerminate=true` 时额外追加一个 NUL。`createGlobalString` 契约不变。
- `Module::runPasses(pipeline, targetMachine=machine)` 支持 LLVM 新 pass manager 的 pipeline 字符串，要求先用匹配的 target machine 配置 module。它返回优化后的 module 副本，原 module 和已有指令 wrapper 保持有效；在副本上运行 pass 前后执行 verifier，报告 pipeline 错误并释放临时 options。后续查询和 object emission 应使用返回的 module。

GC 接口仍按第 4 节留待后续。新增 enum 构造器会要求下游补充穷尽 `match` 分支。
