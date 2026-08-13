# T-07. ORC LLJIT 与 Kaleidoscope 执行闭环

> 最后更新日期：2026-08-13
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 主题描述

讨论 llvm.mbt 如何建立 host-only、进程内的 ORC LLJIT 能力，使 MoonBit 构造的 LLVM Module 能够被编译、查找、调用和卸载，并为后续 Kaleidoscope 示例提供执行基础。本主题包括首期范围、公开层次、Module 提交与资源所有权、符号调用、宿主符号、错误模型和测试闭环；不同时扩展 cross-target JIT、完整优化 pipeline、并发编译或 object cache。

## 关联问题

- [Q-22](Q-22-orc-lljit-initial-scope.md) 〔已解决〕：ORC LLJIT 首期应覆盖哪些能力
- [Q-23](Q-23-jit-public-layer-and-initialization.md) 〔已解决〕：JIT 应采用什么公开层次和初始化模型
- [Q-24](Q-24-module-submission-ownership.md) 〔已解决〕：Module 应如何安全提交给 JIT
- [Q-25](Q-25-jit-resource-lifecycle.md) 〔已解决〕：LLJIT、已提交 Module 与 ResourceTracker 如何管理生命周期
- [Q-26](Q-26-jit-symbol-lookup-and-invocation.md) 〔已解决〕：符号查找和本地函数调用应公开成什么模型
- [Q-27](Q-27-jit-host-symbol-resolution.md) 〔已解决〕：JIT 代码应如何访问宿主函数和动态库符号
- [Q-28](Q-28-orc-error-model.md) 〔已解决〕：ORC 错误应如何映射到安全层
- [Q-29](Q-29-jit-test-and-kaleidoscope-entry.md) 〔已解决〕：JIT 应建立怎样的测试闭环，何时可以开始 Kaleidoscope
- [Q-30](Q-30-jit-module-validation-and-target-configuration.md) 〔已解决〕：JIT 提交应如何处理 Module 验证和 target 配置
- [Q-31](Q-31-lljit-explicit-close.md) 〔已解决〕：LLJIT 销毁错误是否需要显式 close
