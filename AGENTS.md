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

# Project Agents.md Guide

This is a [MoonBit](https://docs.moonbitlang.com) project.

## Project Structure

- MoonBit packages are organized per directory, for each directory, there is a
  `moon.pkg.json` file listing its dependencies. Each package has its files and
  blackbox test files (common, ending in `_test.mbt`) and whitebox test files
  (ending in `_wbtest.mbt`).

- In the toplevel directory, this is a `moon.mod.json` file listing about the
  module and some meta information.

## Coding convention

- MoonBit code is organized in block style, each block is separated by `///|`,
  the order of each block is irrelevant. In some refactorings, you can process
  block by block independently.

- Try to keep deprecated blocks in file called `deprecated.mbt` in each
  directory.

## Tooling

- `moon fmt` is used to format your code properly.

- `moon info` is used to update the generated interface of the package, each
  package has a generated interface file `.mbti`, it is a brief formal
  description of the package. If nothing in `.mbti` changes, this means your
  change does not bring the visible changes to the external package users, it is
  typically a safe refactoring.

- In the last step, run `moon info && moon fmt` to update the interface and
  format the code. Check the diffs of `.mbti` file to see if the changes are
  expected.

- Run `moon test` to check the test is passed. MoonBit supports snapshot
  testing, so when your changes indeed change the behavior of the code, you
  should run `moon test --update` to update the snapshot.

- You can run `moon check` to check the code is linted correctly.

- When writing tests, you are encouraged to use `inspect` and run
  `moon test --update` to update the snapshots, only use assertions like
  `assert_eq` when you are in some loops where each snapshot may vary. You can
  use `moon coverage analyze > uncovered.log` to see which parts of your code
  are not covered by tests.

- agent-todo.md has some small tasks that are easy for AI to pick up, agent is
  welcome to finish the tasks and check the box when you are done
