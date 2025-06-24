## 运行工具

需要C编译器，需要`gcc`命令可用。

## LLVM

本项目需要在有llvm的环境下运行，需要`llvm-config`命令是可用状态，初始化环境时，已经使用`sudo apt install llvm-19-dev -y`命令安装了llvm。如果出现`llvm-config`命令不可用，尝试使用`export PATH="/usr/lib/llvm-19/bin:$PATH"`来添加环境变量，或者将需要用到`llvm-config`的地方，尝试换用`llvm-config-19`，或者其它办法（重装llvm，或者搜索系统下的llvm位置）。

## Moonbit提供的工具

- `moon check`: 对代码进行静态分析，注意这是一个编译到原生代码的项目，因此必须使用`moon check --target native`，否则将会出现大量无关的错误。

- `moon test`: 运行代码中的测试，务必注意使用`moon test --target native`。否则将会出现大量无关错误。注意这一命令也会运行注释文档内的测试，只要这个注释内的文档的代码标记是`moonbit`或者`mbt`，注意只能是这两种，如果代码标记有其它说明，例如`moonbit skip`，`moon test`将不会运行这段代码。
