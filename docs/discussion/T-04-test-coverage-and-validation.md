# T-04. 测试覆盖与验证策略

> 最后更新日期：2026-08-07
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 主题描述

讨论 llvm.mbt 应如何度量当前测试覆盖、如何区分 safe IR、raw extern 与 C stub 的验证责任，以及后续应按什么顺序补充功能、错误、边界和资源测试。本主题只制定测试与覆盖计划，不在此修改接口语义或实现资源模型。

## 关联问题

- [Q-10](Q-10-layered-coverage-metrics.md) 〔已解决〕：测试覆盖率应如何分层度量与设置门槛
- [Q-11](Q-11-test-expansion-order.md) 〔已解决〕：测试补全应按什么顺序推进
