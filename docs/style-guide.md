# 代码风格指南

## `raise` 必须尽量标明错误类型

函数只向上传递一种错误类型时，必须在 `raise` 后写明该类型；同一 `suberror` 的不同构造器仍算一种错误类型。只有函数会向上传递两种及以上不同的错误类型，并且这些错误都需要保留时，才可以省略错误类型写成开放的 `raise`。已经在函数内部捕获或转换的错误不计入对外传播的错误类型。

## C 文件注释与 MoonBit FFI 标记

每个 C 文件都应在文件开头简要说明其用途、所属的 MoonBit native stub 边界，以及主要处理的 ABI 或所有权问题。本仓库实现且被 MoonBit `extern "C"` 引用的每个 C 入口，都必须在定义前使用固定格式标明对应的 MoonBit 声明；白盒测试入口应明确写成 `MoonBit wbtest extern`。直接绑定上游 LLVM 符号、并非由本仓库 C 文件实现的接口不适用此要求。

```c
/* MoonBit extern: ContextOwner::raw (IR/resource_owner.mbt). */
```

如果接口涉及所有权转移、borrowed pointer、引用计数、finalizer、分配与释放配对、pointer+length、NUL、编码、`NULL`、错误处理、全局状态或线程安全，注释还必须写明 MoonBit 类型签名无法表达的边界契约，而不能只复述函数名和参数。finalizer、managed external object 的 control block 及其父子资源释放顺序必须注释。

普通 `static` helper 不要求机械地逐个注释；只有存在非显然的不变量、调用顺序、兼容性处理或刻意延后的边界问题时才需要解释。非 `static` 函数如果不是 MoonBit FFI 入口，应明确说明其跨 C 文件用途，否则应考虑收紧为 `static`。测试 C 文件及测试入口必须明确标记为测试设施，并说明是否持有被观察对象以及并发限制。
