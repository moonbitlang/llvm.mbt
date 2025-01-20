# moonbit llvm-binding

This project provides Moonbit bindings for LLVM-C, enabling you to harness the power of LLVM within the Moonbit ecosystem. The API design is inspired by Rust's inkwell library, offering a familiar and intuitive interface for LLVM operations.

Please note: Due to current compiler limitations, this project is temporarily unavailable. However, we are actively working on resolving these issues and expect to have a functional version available soon.

本项目提供了对 LLVM-C 的 Moonbit 绑定，旨在让您能够在 Moonbit 生态中使用 LLVM 的强大功能。API 设计参考了 Rust 的 inkwell 库，提供了熟悉且直观的 LLVM 操作接口。

请注意：由于当前编译器的一些限制，本项目暂时不可用（或者可能以比较麻烦的方式使用）。但我们正在积极解决这些问题，预计很快会推出可用的版本，并提供丰富详实的文档，以供参考。

## What we expect

我们期待moonbit-llvm会得到下面的效果：

```moonbit
fn main {
  let context = @llvm.Context::create()

  let llvm_module = context.create_module("add_demo")

  let builder = context.create_builder()

  let i32_ty = context.i32_type()
  let fn_ty = i32_ty.fn_type([i32_ty, i32_ty], false)
  let f = llvm_module.add_function("add", fn_ty)

  let param_a = f.get_nth_param(0)
  let param_b = f.get_nth_param(1)

  let bb = context.append_basic_block(f, "entry")
  builder.position_at_end(bb)

  let sum = builder.build_add(param_a, param_b, "sum")
  builder.build_return(val=Some(sum))

  println(llvm_module)
}
```

运行`moon run main/main.mbt --target native`，得到

```llvm
define i32 @add(i32 %0, i32 %1) {
entry:
  %sum = add i32 %0, %1
  ret i32 %sum
}
```
