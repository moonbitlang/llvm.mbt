# Q-25. LLJIT、已提交 Module 与 ResourceTracker 如何管理生命周期 已解决

> 最后更新日期：2026-08-13
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

LLJIT 会持有所有已提交 Module 和生成的机器码；ResourceTracker 可以提前移除某一次提交产生的符号与代码。Kaleidoscope 需要永久保留函数定义，同时在顶层匿名表达式求值后立即卸载该表达式。需要确定公开 owner、显式 remove、GC finalizer 和查找结果之间的生命周期关系。

## 问题引发模型

### 最小复现例子

Kaleidoscope 中两种提交具有不同生命周期：

```text
def foo(x) x * 2       ──> 在 JIT 会话内持续可用
foo(21)                ──> __anon_expr 求值后即可卸载
```

如果所有 Module 都使用 main JITDylib 的默认 ResourceTracker，匿名表达式只能等整个 LLJIT 销毁时回收。如果 `JITModule` 的 finalizer 自动 remove，GC 又可能在用户仍持有查找结果或期望永久函数存在时卸载代码。

### 问题分析

LLVM 的 ResourceTracker 使用引用计数：创建后客户端持有一个引用；`remove` 负责从 JITDylib 移除关联资源；`release` 只释放客户端引用。二者不是同一个操作。

已查找的函数地址在代码被 remove 或 LLJIT 被销毁后会悬空。Q-26 已决定让 JITAddress 锚定 LLJIT owner，避免 GC 隐式销毁整个 JIT；但 ResourceTracker 的显式 remove 仍会使地址失效，转换后的普通 FuncRef 也不能继续携带 owner。

## 关联问题

1. [Q-24. Module 应如何安全提交给 JIT](Q-24-module-submission-ownership.md)（前置依赖：提交产物归谁所有决定句柄包含哪些 owner）
2. [Q-26. 符号查找和本地函数调用应公开成什么模型](Q-26-jit-symbol-lookup-and-invocation.md)（相互约束：调用对象是否逃逸决定必须锚定哪些资源）
3. [Q-29. JIT 应建立怎样的测试闭环，何时可以开始 Kaleidoscope](Q-29-jit-test-and-kaleidoscope-entry.md)（验收关系：必须覆盖销毁顺序、重复卸载和悬空预防）
4. [Q-31. LLJIT 销毁错误是否需要显式 close](Q-31-lljit-explicit-close.md)（后续依赖：决定整个 JIT 的确定性销毁和派生对象失效语义）

## 建议的解决方案

### A1. 所有提交都使用默认 ResourceTracker

#### 方案描述

`addModule` 直接加入 main JITDylib 的默认 ResourceTracker，不公开提交句柄，也不支持单次卸载；全部代码在 LLJIT 销毁时统一释放。

#### 优点

- API 最小，owner 数量少。
- 不会因用户提前 remove 而使查找结果悬空。

#### 缺点

- Kaleidoscope 的匿名表达式无法及时回收。
- 长时间 REPL 会持续积累代码和符号。
- 无法为未来重定义或临时模块建立资源边界。

### A2. JITModule finalizer 自动 remove

#### 方案描述

每次 `addModule` 创建独立 ResourceTracker 并返回 `JITModule`。该对象不可达时，finalizer 自动调用 `LLVMOrcResourceTrackerRemove` 并释放 tracker。

#### 优点

- 使用者不必手动管理匿名表达式资源。
- 临时提交可以随 MoonBit 对象自动回收。

#### 缺点

- GC 时机不可预测，符号可能在调用者没有显式动作时消失。
- finalizer 无法可靠地向用户报告 `remove` 返回的 LLVM Error。
- 若函数地址或其他依赖对象没有正确锚定 JITModule，会产生悬空机器码地址。

### A3. 可选 ResourceTracker 加显式 remove 【已采纳】

#### 方案描述

参考 LLVM C++ 的原生模型，公开独立的 `ResourceTracker`，但不为每次提交强制创建 tracker，也不额外引入 `JITModule`。`LLJIT::addModule` 保持为一个接口，并接受可选的 tracker：

- 未传入 tracker 时，Module 加入 main JITDylib 的默认 ResourceTracker，资源持续存在至整个 LLJIT 销毁，适合普通函数定义；
- 传入 tracker 时，Module 加入该 tracker。一个 tracker 可以管理一次或多次提交，并通过一次显式 `ResourceTracker::remove()` 卸载整组资源，适合顶层匿名表达式。

`ResourceTracker::remove()` 是一次性的显式生命周期操作，并报告 typed error；成功 remove 后 tracker 进入已移除状态，重复 remove 或继续向其提交 Module 时由安全层报告生命周期错误。ResourceTracker 内部保留 LLJIT owner，确保 tracker 不会比所属 JIT 活得更久。

ResourceTracker 的 finalizer 不自动 remove，只释放客户端持有的 tracker 引用。若用户没有显式 remove，LLVM 会把仍然存活的资源转移到 JITDylib 的默认 tracker，因此这些资源仍由 LLJIT 管理，直至 LLJIT 销毁。

LLVM C++ 的 `LLJIT` 同时提供使用默认 tracker 与显式 tracker 的 `addIRModule` 重载，其核心形态可以简化为：

```cpp
Error addIRModule(ThreadSafeModule module);
Error addIRModule(ResourceTrackerSP tracker, ThreadSafeModule module);
```

官方 Kaleidoscope 又在其包装层中把两种形态合并为一个带可选 tracker 的 `addModule`：未提供 tracker 时选用默认 tracker；顶层表达式则显式创建 tracker，并在求值后调用 `remove`。等价的简化流程如下：

```cpp
auto tracker = jit.createResourceTracker();
jit.addModule(std::move(module), tracker);
auto expression = jit.lookup("__anon_expr");
auto value = expression.toPtr<double (*)()>()();
tracker->remove();
```

llvm.mbt 建议保留相同的结构，而不是拆成 `addModule` 与 `addTrackedModule` 两套接口：

```moonbit
// 普通定义使用默认 tracker，在 JIT 会话内持续存在。
jit.addModule(function_module)

// 顶层表达式使用独立 tracker，求值后显式卸载。
let tracker = jit.createResourceTracker()
jit.addModule(expression_module, tracker=tracker)
// 在这里完成 Q-26 决定的 lookup 与调用。
tracker.remove()
```

上述 MoonBit 代码只固定资源管理和提交接口；符号 lookup 与调用的公开形式仍由 Q-26 决定。

#### 优点

- 资源消失只发生在显式操作或整个 JIT 销毁时，行为可预测。
- `remove` 错误可以正常映射到安全层。
- 同时支持永久函数和求值后卸载的匿名表达式。
- 一个 tracker 可以自然地管理一组互相关联的 Module，符合 ORC 的资源分组语义。
- 单一 `addModule` 加可选 tracker 的形态贴近 LLVM C++ 与官方 Kaleidoscope，避免创造不必要的 `JITModule` 抽象。
- ResourceTracker 锚定 LLJIT，可避免先销毁 JIT 再操作 tracker。

#### 缺点

- 使用者需要记得对临时提交调用 `remove()`。
- 没有 remove 的提交会持续占用资源，直到 LLJIT 销毁。
- 同一 tracker 管理多次提交时，`remove()` 会整体卸载，不能只移除其中某一个 Module。
- ResourceTracker remove 后无法使已经转换出的 FuncRef 自动失效，调用者仍需遵守 Q-26 的 unsafe 生命周期契约。

## 最终采用方案

A3. 可选 ResourceTracker 加显式 remove
