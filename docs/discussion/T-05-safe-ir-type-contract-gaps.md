# T-05. Safe IR Type 契约缺口

> 最后更新日期：2026-08-11
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 主题描述

记录 M2 safe IR 核心对象补测过程中暴露的 Type 分类、类型大小、opaque struct 构造和 Aggregate 索引边界问题。四个问题可以独立修复和验收，现已分别确定修复方案。

## 关联问题

- [Q-12](Q-12-scalable-vector-type-classification.md) 〔已解决〕：ScalableVectorType 是否应完整遵循 LLVM vector 分类语义
- [Q-13](Q-13-unsized-type-sizeof-contract.md) 〔已解决〕：unsized Type 的 sizeOf 应如何表达无有效大小
- [Q-14](Q-14-opaque-struct-construction.md) 〔已解决〕：安全 API 应如何创建和完成 opaque named struct
- [Q-15](Q-15-array-aggregate-index-bounds.md) 〔已解决〕：Array 的 Aggregate element 查询应如何处理越界索引
