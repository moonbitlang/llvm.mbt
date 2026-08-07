# T-03. IR 资源所有权与回收

> 最后更新日期：2026-08-06
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 主题描述

讨论安全 `IR` 包中的 LLVM 资源应如何随 MoonBit 对象回收，从 `Context`、`Module` 派生出的 borrowed handle 应如何保持其真正的 native owner 存活，以及 native IR 节点被删除或批量改写后旧 handle 应如何失效。本主题目前只处理 `Context`、`Module` 及其派生对象，不扩展到 execution engine 等具有 ownership transfer 的 API。

## 关联问题

- [Q-07](Q-07-context-module-reclamation.md) 〔已解决〕：Context 与 Module 的回收策略
- [Q-08](Q-08-derived-handle-owner-anchors.md) 〔已解决〕：派生 IR 对象的 owner 持有关系与迁移顺序
- [Q-09](Q-09-native-ir-handle-invalidation.md) 〔待讨论〕：Native IR 节点删除后的派生句柄失效模型
