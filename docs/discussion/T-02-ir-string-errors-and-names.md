# T-02. IR 字符串错误与名称 API

> 最后更新日期：2026-08-04
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 主题描述

讨论 `IR` 包应如何把底层 C 字符串和 UTF-8 解码错误转换为稳定的公开错误类型，以及 Value 派生对象与 Module 的名称 getter 应采用什么返回模型。本主题建立在 C 字符串边界已经保留字节和 ownership 信息的基础上，不重新讨论底层输入表示与 finalizer。

## 关联问题

- [Q-05](Q-05-ir-string-error.md) 〔待讨论〕：IR 对外 StringError 的建立与 LLVM 名称解码
- [Q-06](Q-06-get-name-return-model.md) 〔待讨论〕：Value 派生对象与 Module 的 getName 返回模型
