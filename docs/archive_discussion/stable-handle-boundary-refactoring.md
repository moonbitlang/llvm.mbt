# llvm.mbt stable handle 边界重构

状态：Batch 0、Batch 1 与 Batch 1.5 已完成，等待 review

目标 LLVM 版本：LLVM 22.1.0

适用范围：`IR` stable package、`unsafe` raw package、生成接口与 native 测试

## 1. 问题定义

`IR` package 目前大量使用以下形式包装 LLVM raw handle：

```moonbit
pub struct Module(@unsafe.LLVMModuleRef)
pub struct Context(@unsafe.LLVMContextRef)
pub struct Int32Type(@unsafe.LLVMTypeRef)
```

MoonBit 的 public tuple struct 会公开 positional field。用户可以通过 `.0` 取出 raw
handle；public constructor、public field、public raw accessor 和 public trait method 还会
绕过 stable wrapper 的状态检查。

这不是安全沙箱问题：主动依赖 `unsafe` package 的用户始终可以选择承担 LLVM-C 的
ownership 责任。这里要建立的边界是：只使用 `IR` stable API 的普通用户不能意外获得
raw handle，也不能绕过 `Closed`、`Moved` 和 parent-liveness 检查。

生产可靠性的目标是不让正常 stable API 控制流产生：

- double-free；
- use-after-free；
- owned handle 泄漏；
- parent 已失效后继续使用 borrowed handle；
- mutation 已使对象失效后继续使用 stale handle；
- stable interface 偶然依赖 `unsafe` package 的 ABI 类型。

## 2. Batch 0 基线清单

以 `moon info` 生成的 `IR/pkg.generated.mbti` 为 public surface 的唯一权威来源。

当前基线：

| 指标 | 数量 |
|---|---:|
| 源码中直接匹配 `pub struct.*@unsafe` | 26 |
| 生成接口中直接携带 `@unsafe` 的 public struct | 55 |
| 生成接口中包含 `@unsafe` 的总行数 | 84 |

源码计数更小，是因为下面的 alias 会在生成接口中展开：

```moonbit
pub type ValueRef = @unsafe.LLVMValueRef
pub struct Function(ValueRef)
```

### 2.1 暴露渠道

| 渠道 | 例子 | 风险 |
|---|---|---|
| public tuple field | `Module(@unsafe.LLVMModuleRef)` | `.0` 直接取出 raw handle |
| public record field | `IRBuilder.builder_ref` | 字段直接取出 raw handle |
| public type alias | `ValueRef` | 所有二次 wrapper 一起泄漏 |
| public raw accessor | `IRBuilder::inner` | 绕过 wrapper 状态机 |
| public trait method | `Type::getTypeRef` | trait object 直接返回 raw handle |
| public constructor | public tuple constructor | 可以伪造 wrapper 或包装错误 handle |

### 2.2 Ownership 分类

| 类别 | 当前代表类型 | 主要不变量 |
|---|---|---|
| owned | `Context`、`Module`、`IRBuilder`、`GenericValue`、execution engine | exactly-once dispose；alias 共享状态 |
| borrowed from Context | `Type` family、部分 constant/metadata | parent 存活；不能 dispose |
| borrowed from Module | `Function`、global、instruction、basic block | module 存活；mutation 后不能 stale-use |
| module-borrowed view | `DataLayout` | module 存活；不能按独立 owner 释放 |
| immortal/global | `Target` | 不释放；仍不向 stable API 泄漏 raw capability |
| ownership transfer | execution engine、lazy bitcode、ORC | consume 成功/失败规则；旧 owner 进入 `Moved` |

### 2.3 Batch 0 gate

`scripts/stable-handle-boundary.allowlist` 保存当前 84 行生成接口基线。

`scripts/audit-stable-handle-boundary.sh` 使用 multiset 比较：

- 当前接口可以删除 allowlist 中的泄漏；
- 不要求继续保留已经删除的旧泄漏；
- 新增 raw 类型、raw field、raw method 或重复新增同一签名都会失败；
- 最终目标是当前接口中的 `@unsafe` 数量归零，然后删除 allowlist。

这是一条迁移 gate，不代表基线中的 84 行已经安全。

## 3. Batch 1：纵向架构原型

Batch 1 先在 `_wbtest.mbt` 中实现 test-only 原型，不立即替换 production public
`Context`/`Module` 等类型。原型中的 `pub` wrapper/trait 只用于让编译器检查真实 public
visibility 规则，不会进入 `IR/pkg.generated.mbti`。原因是 production public 表示一旦变更
便是大规模 source compatibility break；在确认状态机和 trait 方案前，不应让生产 API
处于半迁移状态。

原型使用真实 LLVM handle，覆盖以下链路：

```text
PrototypeContext
  ├── PrototypeModule
  │     └── PrototypeFunction
  ├── PrototypeInt32Type / PrototypeFunctionType
  └── PrototypeBuilder
```

必须验证：

1. wrapper 字段、raw constructor 和 raw accessor 均为 package-private；
2. wrapper alias 共享 `Open/Closing/Closed` 状态；
3. `Context::close` 遇到仍存活的 owned child 时先进入逻辑关闭状态；
4. parent 逻辑关闭后 child operation 返回 typed `ClosedHandle`，不进入 LLVM；
5. child `close` 仍可在 native parent 存活期间安全释放 native handle；
6. 最后一个 owned child 关闭后才真正 dispose context；
7. Module 关闭后 Function operation 返回 typed `ClosedHandle`；
8. Type 在 Context 关闭后返回 typed `ClosedHandle`；
9. Module、Builder 与 Context 的重复 `close` 都幂等；
10. 正常路径能够真实构造函数、生成 return instruction 并通过 verifier；
11. 不同 Context 的 Type/Value 在进入 LLVM 前被 stable typed error 拒绝；
12. public sealed trait 只返回 closed enum，raw extraction 留在 package-private helper。

### 3.1 Context 状态机

```text
Open(raw, owned_children=0)
  ├── close, children=0 ────────────────> Closed（dispose raw）
  ├── close, children>0 ────────────────> Closing(raw, children)
  └── create child ─────────────────────> Open(raw, children+1)

Closing(raw, children)
  ├── ordinary operation ───────────────> ClosedHandle
  ├── child close, children>1 ──────────> Closing(raw, children-1)
  └── last child close ─────────────────> Closed（dispose raw）
```

borrowed child 不参与 owned child 计数。它保存 parent anchor，并在每次 operation 前检查
parent state。这样 Context 可以逻辑关闭；borrowed view 立即不可用，但 native context 会
等到 Module/Builder 等 owned child 安全释放后再销毁。

### 3.2 Batch 1 不解决的事项

- 不修改现有 public `Type`/`Value` trait；
- 不处理所有 LLVM handle；
- 不提供 finalizer；
- 不处理 instruction/basic-block mutation generation；
- 不处理 execution-engine ownership transfer；
- 不承诺原型类型的 API compatibility。

这些限制是刻意的。Batch 1 的结果用于 review 动态状态机是否值得成为 public 实现，
而不是伪装成完整迁移。

### 3.3 Batch 1 实验结果

实现文件：`IR/handle_boundary_prototype_wbtest.mbt`

原型使用真实 LLVM 22.1.0 C API，而不是 mock：

- 创建 Context、Module、Int32Type、FunctionType、Function 与 IRBuilder；
- 构造返回 `i32 42` 的函数；
- 调用真实 LLVM verifier；
- 关闭 Module 后 Function operation 得到 `ClosedHandle`；
- 关闭 Context 后 Type operation 得到 `ClosedHandle`；
- Context 在两个 owned child 存活时从 `Open` 进入 `Closing`；
- Module 关闭后 native Context 仍存活；
- Builder 作为最后一个 owned child 关闭时才真正 dispose Context；
- alias 重复关闭后，Module/Builder/Context disposer 计数均保持为 1；
- cross-context FunctionType/Module 组合在进入 LLVM 前得到
  `ForeignBoundaryFailure`。

trait 实验得到一个重要结论：当前 MoonBit 已经可以实现“不公开 raw method 的 public
sealed trait”，不需要为了第一版迁移立即修改编译器：

```moonbit
pub trait PrototypeType {
  fn asPrototypeTypeEnum(Self) -> PrototypeTypeEnum
}

fn prototypeTypeRaw(
  ty : &PrototypeType,
  api : String,
) -> @unsafe.LLVMTypeRef raise {
  match ty.asPrototypeTypeEnum() {
    Int32(ty) => ty.raw(api)
    Function(ty) => ty.raw(api)
  }
}
```

public trait 只返回 safe closed enum；enum payload 的 wrapper 使用 private raw field；
同 package helper 可以 pattern match 后调用 private `raw`。`PrototypeValue` 使用同一模式。

`moon info` 后 production `IR/pkg.generated.mbti` 没有出现任何 Prototype 类型，Batch 0
gate 仍报告 `current raw lines=84, baseline=84`。

原型同时确认了 deferred disposal 的代价：如果用户调用 Context `close` 后遗失某个尚未
关闭的 owned child，Context 会永远停在 `Closing`，native handle 也不会释放。在没有
finalizer 的显式 close 模型中，这是用“可检测的 leak 风险”换掉 use-after-free。是否接受
这个取舍，是进入 production 迁移前必须 review 的核心决策。

## 4. Batch 1.5：finalizable owner control block 原型

Batch 1 证明了动态状态机能够阻止 double-free、use-after-close 和父对象过早销毁，但仍
要求用户显式调用每一个 owned child 的 `close`。Batch 1.5 在独立的
`IR_experimental` package 中验证 automatic finalizer fallback，不修改现有 `IR` 或
`unsafe` public API。

实现文件：

- `IR_experimental/owner_control_block.c`；
- `IR_experimental/owner_control_block_impl_wbtest.mbt`；
- `IR_experimental/owner_control_block_wbtest.mbt`。

MoonBit owner 使用 `type T` 抽象类型接收 `moonbit_make_external_object` 创建的引用计数
对象。raw LLVM handle 和 owner state 全部保存在 C payload 中：

```c
struct llvm_mbt_prototype_module_owner {
  LLVMModuleRef raw;
  struct llvm_mbt_prototype_context_owner *parent;
  enum llvm_mbt_prototype_owner_state state;
};
```

Module 和 Builder owner 创建时显式 `moonbit_incref(parent)`。它们的显式 `close` 与 C
finalizer 调用同一个 `dispose_once`：

```text
Module/Builder dispose_once
  1. Open -> Closed，先清空 raw 和 parent field
  2. dispose LLVM child
  3. Context owned_children--
  4. moonbit_decref(parent)
```

这个顺序保证 child native handle 先于 Context native handle 销毁，不依赖 MoonBit record
字段当前的 drop 顺序。Context 的状态仍然是：

```text
Open(raw, children=0)
  close/finalizer -> Closed，dispose raw

Open(raw, children>0)
  close -> Closing(raw, children)

Closing(raw, children)
  child close/finalizer -> children--
  last child -> Closed，dispose raw
```

普通 Module operation 同时检查 Module owner 和 Context parent state。因此 Context 进入
`Closing` 后，Module raw 仍然保留以便安全销毁，但 verifier 等普通 operation 返回 typed
`PrototypeParentClosed`，不进入 LLVM。

borrowed wrapper 继续只保存 owner anchor，不参与 owned child count：

```text
PrototypeFunction -> PrototypeModule -> ModuleOwner -> ContextOwner
PrototypeInt32Type -> PrototypeContext -> ContextOwner
```

Module owner 对 Context owner 的引用由 C payload 显式维护；Function 对 Module 的引用、
Type 对 Context 的引用由 MoonBit reference counting 维护。整个 binding ownership graph
保持 child-to-parent 单向关系，不主动建立环。

### 4.1 Batch 1.5 实验结果

原型调用真实 LLVM 22.1.0 C API 创建 Context、Module、Builder、`i32` Type 和 Function，
并运行真实 verifier。六个 native 测试验证：

1. 用户完全不调用 Module `close` 时，最后一个 alias 消失后 finalizer 自动运行，Module
   disposer 恰好调用一次；
2. alias 显式重复 `close` 后，external object finalizer 仍会运行，但 disposer 总数保持为
   一次；
3. Context 已进入 `Closing` 且用户忘记关闭 Module 和 Builder 时，两个 child finalizer
   都会运行，最后一个 child 触发 Context native disposal；
4. 记录的 disposal event order 中，Context 始终晚于 Module 和 Builder；
5. 原局部 Module binding 消失后，borrowed Function 仍能读取真实 LLVM function name，
   证明 Function anchor 保持 Module owner 存活；
6. 原局部 Context binding 消失后，borrowed Type 仍能调用真实 LLVM type operation；
7. Context 逻辑关闭后 Module verifier 返回 typed parent-closed error，而不是进入 LLVM；
8. 所有路径的 parent/child counter invariant violation 均为零。

`IR_experimental` 的 MoonBit 实现和测试都放在 `_wbtest.mbt`，因此实验不会产生 public
`.mbti` surface。C stub 独立于 `unsafe/wrap.c`，避免正式 shim 携带实验状态和测试
counter。

### 4.2 尚未证明的事项

- owner state 当前不是 atomic；原型只验证单线程 lifecycle。production 需要明确 handle
  是否 thread-confined，或者用 atomic exchange/lock 串行化 `close` 与 finalizer；
- 没有实现 `Moved` ownership transfer；execution engine、linker 和 ORC 仍需单独建模；
- 没有验证 MoonBit reference cycle 中的 external owner 回收；当前设计自身只建立有向
  child-to-parent edge，但用户仍可能把 wrapper 放入自己的循环数据结构；
- 没有迁移 MemoryBuffer、TargetMachine 或现有 public Context/Module；
- C control block 的通用化、错误映射和最终文件位置尚未确定。

Batch 1.5 的结论是：finalizer fallback 可以和显式 `close`、alias 共享状态、Context
deferred disposal 组合，而且不需要依赖 MoonBit record 的字段 drop 顺序。production
owner 不应继续采用“只显式 close、没有 finalizer”的模型。

## 5. 后续批次

### Batch 2：简单独立 handle

- 复核 `MemoryBuffer`、`TargetMachine`；
- 迁移 `Target`、`GenericValue` 和其他简单 owner/non-owner；
- private raw field、private constructor、private accessor；
- owned wrapper 使用共享状态。

### Batch 3：Context 与 Type family

- 将验证后的 Context 状态机用于 public `Context`；
- Type wrapper 保存 Context anchor；
- public `Type` trait 不再返回 `@unsafe.LLVMTypeRef`；
- 设计 package-private raw extraction；
- Context 关闭后所有 Type operation 返回 typed error。

### Batch 4：Module 与 Value family

- public `Module` 采用 owner state；
- 删除 public raw `ValueRef` alias；
- public `Value` trait 不再返回 `@unsafe.LLVMValueRef`；
- Function/global/constant/instruction 保存合适的 parent anchor；
- 按 Constant、Global、Instruction 分成独立 commit。

### Batch 5：BasicBlock 与 mutation invalidation

- `eraseFromParent`、delete、remove、replace 等 mutation 传播失效状态；
- 评估 per-object token、generation 或 module-level conservative invalidation；
- stale operation 返回 typed error，不进入 LLVM。

### Batch 6：IRBuilder

- 删除 public `IRBuilder::inner` 和 public `builder_ref`；
- shared close state 与 Context anchor；
- 区分 closed builder、closed context 和 unset insertion point。

### Batch 7：Interpreter、ExecutionEngine 与 transfer

- Module consume/move；
- execution engine、GenericValue 和 Context 的释放顺序；
- 条件 consume 的成功/失败 contract；
- 设计未成熟的接口继续留在 experimental/unsafe。

### Batch 8：归零、文档与 CI

- `IR/pkg.generated.mbti` 中 `@unsafe` 为零；
- 删除迁移 allowlist，gate 改成 zero-tolerance；
- README canonical workflow 不出现 `.0`、`inner`、raw disposer；
- 黑盒测试只使用 stable API；
- `moon info && moon fmt`、native check/test 全部通过。

## 6. 需要 review 的决策点

Batch 1 完成后需要决定：

1. 是否接受 `Open/Closing/Closed + owned child count` 作为 Context 动态模型；
2. public owner 是否采用“finalizer fallback + 可选显式 `close`”；Batch 1.5 已证明单线程
   原型可行；
3. public `Type`/`Value` trait 使用 closed enum helper 提取 raw，还是需要 MoonBit 增加
   package-private trait method/sealed capability；
4. 是否允许 parent `close` 进入 deferred native disposal，还是在存在 child 时直接报错；
5. 迁移是否接受 breaking change，还是需要一个明确版本周期。
