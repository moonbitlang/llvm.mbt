# JIT

`Kaida-Amethyst/llvm/JIT` 提供当前进程内、仅限 host target 的 ORC LLJIT
执行闭环。它适合运行已由 `IR` package 构造的函数，也为后续 Kaleidoscope
示例提供 JIT 基础设施。

基本流程是：显式验证 IR，创建 `LLJIT`，提交 Module 的独立 bitcode 快照，
查找符号，把地址按调用者证明的 ABI 转成 `FuncRef`，最后显式关闭 session。

```moonbit
let jit = @JIT.LLJIT::host()
mod.verify()
jit.addModule(mod)
let address = jit.lookup("answer")
let answer : FuncRef[() -> Double] = address.unsafeToFuncRef()
let result = answer()
jit.close()
```

`unsafeToFuncRef[T]` 不是类型检查。调用者必须保证 `T` 与 LLVM 函数签名、
calling convention 和当前平台 C ABI 完全一致。调用期间必须保持
`JITAddress` 和 `LLJIT` 可达；普通 `FuncRef` 不会替你保活 owner。

需要卸载临时代码时，用同一 `ResourceTracker` 提交一组 Module，并在不再执行
其中任何函数后调用 `remove()`。tracker removal 或 `LLJIT::close()` 之后，
对应的地址和既有 `FuncRef` 都会悬空，不能继续调用。

本 package 不提供 sandbox、cross-target JIT、任意 MoonBit closure callback，
也不承诺并发调用 `addModule`、`lookup`、`remove` 和 `close`。这些状态操作应由
调用者串行执行或在外部同步。
