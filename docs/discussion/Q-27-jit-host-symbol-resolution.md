# Q-27. JIT 代码应如何访问宿主函数和动态库符号 已解决

> 最后更新日期：2026-08-13
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 问题描述

Kaleidoscope 的外部函数会调用 `sin`、`cos` 等系统数学函数，教程还经常用 C 实现 `printd` 和 `putchard`。需要明确现代 LLJIT 的默认 process-symbol 行为，决定是否允许配置宿主符号可见范围，以及首期是否支持显式注册宿主函数或回调 MoonBit closure。

## 问题引发模型

### 问题复现

使用 LLVM 22.1 的 `LLVMOrcCreateDynamicLibrarySearchGeneratorForProcess` 和 LLJIT 的 global prefix，在当前 macOS ARM64 环境进行了临时 C 探针：JIT Module 声明并调用进程中的一个 C 函数，该函数将参数乘以二，JIT 顶层入口实际返回 `42.0`。

该结果证明当前静态 LLVM 产物包含并能运行当前进程符号生成器，也验证了 macOS global prefix 路径。Linux CI 上，自定义可执行文件符号可能还受链接器的 symbol export/`-rdynamic` 配置影响，需要单独验证；libm 等动态库符号不等同于可执行文件自定义符号。

### 问题分析

LLVM 22.1 的 C++ `LLJITBuilder` 已经将 `LinkProcessSymbolsByDefault` 默认为 `true`：默认创建 process-symbols JITDylib，并把它加入 main JITDylib 的 link order。LLVM-C 的默认 LLJIT builder 继承该行为，但没有公开与 C++ `setLinkProcessSymbolsByDefault` 对应的 setter。官方 Kaleidoscope 手工安装当前进程 generator，是因为该示例自行组装较底层的 ORC layers，不能据此推断现代 LLJIT 默认不解析进程符号。

ORC 的当前进程 generator 与 absolute symbols 解决的是不同规模的问题：前者适合 libc、libm 等数量较多或由环境决定的符号，并可通过 predicate 建立 allowlist；后者适合 `printd`、`putchard` 或语言 runtime 等少量、固定、明确授权的入口。二者应当正交，而不是互相替代。

直接把任意 MoonBit closure 注册为机器码可调用函数，还涉及 MoonBit runtime、GC root、线程进入和 callback 生命周期，不能从“C 函数地址可解析”推导为安全。首期可以用稳定 C stub 提供 `printd/putchard`，暂不承诺 MoonBit callback。

## 关联问题

1. [Q-22. ORC LLJIT 首期应覆盖哪些能力](Q-22-orc-lljit-initial-scope.md)（范围关系：Kaleidoscope 外部函数决定宿主解析是否属于最小闭环）
2. [Q-23. JIT 应采用什么公开层次和初始化模型](Q-23-jit-public-layer-and-initialization.md)（构造关系：生成器可以由 host convenience 默认安装或由用户显式启用）
3. [Q-26. 符号查找和本地函数调用应公开成什么模型](Q-26-jit-symbol-lookup-and-invocation.md)（方向区别：本问题讨论 JIT 调宿主，Q-26 讨论宿主调用 JIT）
4. [Q-29. JIT 应建立怎样的测试闭环，何时可以开始 Kaleidoscope](Q-29-jit-test-and-kaleidoscope-entry.md)（跨平台验证：macOS 与 Linux 都需覆盖宿主符号解析）

## 建议的解决方案

### A1. 不默认解析宿主符号

#### 方案描述

`LLJIT::host()` 只创建 JIT。需要外部函数的用户显式调用方法安装当前进程 generator，或者以后通过 absolute symbols 注册单个地址。

#### 优点

- 默认 JITDylib 的可见宿主符号最少。
- 当前进程解析的全局副作用在调用点明确可见。

#### 缺点

- Kaleidoscope 的标准外部函数用法需要额外设置。
- 用户必须正确取得 global prefix 并理解 generator 所有权。
- 遗漏配置只会在第一次编译或 lookup 外部调用时暴露。

### A2. host LLJIT 默认安装当前进程生成器

#### 方案描述

`LLJIT::host()` 使用自身 DataLayout 的 global prefix 创建当前进程动态库搜索生成器，并立即把生成器所有权转交给 main JITDylib。首期不过滤符号，也不公开 generator handle。

libc/libm 等系统符号属于首期保证范围。教程自定义 `printd/putchard` 先由 native C stub 提供，并在 macOS、Linux CI 验证链接可见性；若 Linux 需要额外 export 选项，再把它作为构建契约明确记录。

首期不支持任意 MoonBit closure 作为 JIT callback。

#### 优点

- 与官方 Kaleidoscope 的默认行为一致，外部数学函数开箱可用。
- global prefix 和 generator 所有权都封装在 LLJIT 构造内部。
- 对普通用户和 AI 生成代码更不容易遗漏前置配置。

#### 缺点

- JIT 代码默认可以解析当前进程中较广泛的可见符号。
- 自定义可执行文件符号的可见性具有平台和 linker 差异。
- 以后需要沙箱或最小权限 JIT 时，还需增加显式关闭或过滤能力。

### A3. 首期只支持显式注册宿主符号

#### 方案描述

不使用当前进程 generator；安全层提供按名称注册固定 C ABI 函数的接口，底层通过 ORC absolute symbols 定义地址。Kaleidoscope 显式注册数学函数和打印函数。

#### 优点

- JIT 只看到明确授权的符号，边界精确。
- 避免依赖可执行文件 export-dynamic 行为。

#### 缺点

- 需要额外绑定 symbol interning、flags map、MaterializationUnit 和 define 的所有权链。
- 仍需安全地取得宿主函数地址，MoonBit callback 问题没有自动解决。
- 为首期 Kaleidoscope 引入的 ORC 表面明显大于当前进程 generator。

### A4. 构造期配置进程符号策略，并独立支持 absolute symbols 【已采纳】

#### 方案描述

长期将宿主符号解析建模为 LLJIT 的构造期策略，概念上包含：

- `CurrentProcess`：解析当前进程可见符号，作为 `LLJIT::host()` 的默认值；
- `AllowList(Array[String])`：仍使用当前进程 generator，但只反射明确允许的符号；
- `Disabled`：不把当前进程符号加入 JIT 的默认 link order。

显式 absolute symbol 注册作为与该策略正交的能力：无论进程符号策略为何，用户都可以把少量固定 C ABI 地址按名称加入 JIT。首期不把任意 MoonBit closure 注册为 JIT callback；该能力必须单独处理 MoonBit runtime、GC root、线程进入和回调生命周期。

实现分阶段进行：首期提供 `CurrentProcess` 行为，使 Kaleidoscope 的 libc/libm 调用开箱可用；同时在 owner 和构造路径中保留策略扩展边界。absolute symbols、`AllowList` 和 `Disabled` 在出现实际需求后加入，其中严格关闭或过滤 process-symbols JITDylib 需要一个很薄的 C++ LLJITBuilder shim，因为 LLVM-C 22.1 没有公开相应 builder setter。

实施 C-09 时又对仓库实际发布的 LLVM 22.1.0 静态产物进行了 raw 测试：仅使用 LLVM-C default LLJIT builder 时，main JITDylib 无法 lookup `sin`、`cos`、`malloc` 或 `puts`。因此首期 host 构造器必须显式创建一次无过滤的 `LLVMOrcCreateDynamicLibrarySearchGeneratorForProcess`，并把它转交给 main JITDylib；这仍实现同一个 `CurrentProcess` 公开策略，但不能依赖 default builder 自动安装 generator。该修正不会公开 generator handle，也不改变后续 `AllowList`、`Disabled` 和 absolute symbols 的分阶段边界。

#### 优点

- 默认行为与现代 LLVM 22.1 LLJIT 和 Kaleidoscope 的实际需求一致。
- 当前进程搜索与少量固定 runtime symbol 注册各自使用适合的 ORC 机制。
- 以后可以在便利默认值、allowlist 和完全显式授权之间切换，不必重做 LLJIT 公开模型。
- 首期不为尚未使用的策略立即扩大 C++ shim 和 callback 生命周期范围。

#### 缺点

- 首期只有 `CurrentProcess` 可用，完整策略配置不是第一批实现的一部分。
- `CurrentProcess` 会让 JIT 代码看到较广泛的宿主导出符号，不能充当沙箱边界。
- `AllowList` 和 `Disabled` 需要维护额外的 C++ shim，不能只依赖现有 LLVM-C LLJITBuilder。
- absolute symbol 注册仍要求调用者保证地址、名称和 C ABI 声明一致。

## 最终采用方案

A4. 构造期配置进程符号策略，并独立支持 absolute symbols
