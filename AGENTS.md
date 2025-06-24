## 运行工具与LLVM

需要C编译器，需要`gcc`命令可用。需要`llvm-config`命令可用，初始化环境时，已经使用`sudo apt install llvm-19-dev -y`命令安装了llvm。运行项目之前，需要使用`source agent_env.sh`命令来启动环境变量。否则会出现头文件找不到的问题。


## Moonbit提供的工具

- `moon check`: 对代码进行静态分析，注意这是一个编译到原生代码的项目，因此必须使用`moon check --target native`，否则将会出现大量无关的错误。

- `moon test`: 运行代码中的测试，务必注意使用`moon test --target native`。否则将会出现大量无关错误。注意这一命令也会运行注释文档内的测试，只要这个注释内的文档的代码标记是`moonbit`或者`mbt`，注意只能是这两种，如果代码标记有其它说明，例如`moonbit skip`，`moon test`将不会运行这段代码。

## 常见问题

1. `#include <llvm-c/Analysis.h>` no such file or directory.

这个是llvm头文件没有找到，尝试运行命令`source agent_env.sh`。
