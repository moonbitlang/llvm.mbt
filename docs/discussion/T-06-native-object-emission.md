# T-06. Native object emission

> 最后更新日期：2026-08-12
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 主题描述

讨论 llvm.mbt 在推进 Kaleidoscope 前应如何建立第一条 host-only native object emission 闭环，包括 LLVM-C 绑定范围、native target 初始化、TargetMachine 与 DataLayout 所有权、Module 配置和验证语义，以及 object 链接后实际运行的端到端测试。本主题不同时扩展 cross-target、JIT 或完整优化 pipeline。

## 关联问题

- [Q-16](Q-16-native-object-emission-scope.md) 〔已解决〕：Native object emission 首期应绑定哪些 LLVM-C API
- [Q-17](Q-17-native-target-initialization.md) 〔已解决〕：Native target 初始化应显式调用还是由 host TargetMachine 自动完成
- [Q-18](Q-18-target-machine-resource-model.md) 〔已解决〕：Target、TargetMachine 与 TargetData 应如何建立高层资源模型
- [Q-19](Q-19-module-target-data-layout.md) 〔已解决〕：Module 初始 triple 与 DataLayout 应采用什么语义
- [Q-20](Q-20-configure-verify-emit-sequencing.md) 〔已解决〕：Configure、verify 与 emit 应显式分阶段还是由 emit 隐式完成
- [Q-21](Q-21-native-object-execution-test.md) 〔已解决〕：Native object 应如何建立 link-and-run 端到端测试
