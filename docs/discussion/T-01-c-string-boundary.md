# T-01. C 字符串边界

> 最后更新日期：2026-08-03
> 仓库：github.com/moonbitlang/llvm.mbt
> 记录者：Codex-GPT-5

## 主题描述

讨论 MoonBit `String` 与 LLVM C API 的 `char *`/`const char *` 之间如何转换，输入临时数据如何保活，以及不同来源的输出指针如何复制和释放。本主题暂不扩展到 LLVM operation error、nullable、MemoryBuffer、enum 或高层 LLVM 资源管理。

## 关联问题

- [Q-01](Q-01-input-string-boundary.md) 〔已解决〕：MoonBit String 到 C 输入字符串的表示与生命周期
- [Q-02](Q-02-output-string-boundary.md) 〔已解决〕：C 输出字符串的复制与释放责任
- [Q-03](Q-03-incremental-review-scope.md) 〔已解决〕：字符串边界重构的改动与审核范围
- [Q-04](Q-04-cstring-finalizer-location.md) 〔已解决〕：Owned CString 的 finalizer 应写在 MoonBit 还是 C
