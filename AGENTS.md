# 本项目的用途

llvm的moonbit语言binding，使用llvm-19。

# moonbit语言命令

- `moon check --target native` 运行静态分析。

- `moon test --target native` 运行所有测试，包括文档内的测试。

- `moon test --target native -p test` 仅运行test目录下的测试。

注意，首次运行，需要使用`source env.sh`来配置环境变量。

# 特殊文件

- `env.sh` 环境变量配置文件，终端里首次运行项目需要使用`source env.sh`

- `.mbti` 以mbti为结尾的文件存放了所有可用的函数签名信息。

# 关于测试

- `doc test`: 是指函数实现前面的，以`///` 开头的，用`moobit`代码块包裹的测试，doc test只测基本功能，展示用法，不做复杂的强度测试，Bug测试等。

- `test` 目录下的测试目的是保证代码强度，有正向测试，反向测试（故意使用错误的代码），以及其他的强度测试等。
