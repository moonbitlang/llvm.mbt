# Moonbit-llvm

[中文版](#Moonbit-llvm-1)

[AI-Assistant](https://www.coze.cn/store/agent/7472944227773956147?bot_id=true&bid=6fda0p1hg501m)
[AI助手看这里](https://www.coze.cn/store/agent/7472944227773956147?bot_id=true&bid=6fda0p1hg501m)

Moonbit-LLVM provides Moonbit bindings for LLVM-C and further encapsulates its functionality using Moonbit's features, enabling developers to leverage the power of LLVM in Moonbit for projects such as compiler backends.

This project offers two types of interfaces:
1. **Unsafe LLVM-C Bindings**: Similar to Rust's `llvm-sys`, directly interacting with the LLVM-C API.
2. **Safe LLVM Interface**: Similar to Rust's `inkwell`, providing a safer and more user-friendly API, inspired by the design of `inkwell`.

## Notes

Due to the ongoing development of the Moonbit language and its build system, this project is still under testing phase, using this project may currently involve some complexity, and issues such as linking errors or memory leaks may occur. We are actively addressing these issues and improving the experience as the Moonbit compiler evolves. We look forward to delivering an exceptional LLVM development experience with future versions of Moonbit and Moonbit-LLVM.

## Quick Start

### Installing LLVM

First, you need to install LLVM locally. Moonbit-LLVM requires LLVM version 19 or higher.

#### macOS

Install LLVM using Homebrew:

```shell
brew install llvm@19
```

#### Ubuntu

Install LLVM using apt:

```bash 
sudo apt install llvm-19-dev -y
```


#### Linux

It is recommended to install LLVM from source to ensure the correct version.

1. Download the LLVM source code:

   ```shell
   git clone --depth 1 https://github.com/llvm/llvm-project.git -b llvmorg-19.0.0
   ```

2. Build LLVM:

   ```shell
   cd llvm-project && mkdir build && cd build
   cmake -G Ninja -DCMAKE_BUILD_TYPE="Release" ../llvm
   ninja
   ```

3. Install LLVM:

   ```shell
   sudo ninja install
   ```

#### Windows

Moonbit-LLVM is currently not supported on Windows. It is recommended to use a virtual machine or WSL2 and follow the Linux installation steps.

After installation, ensure that the commands `llc --version` and `llvm-config` are available.

Try to use `llvm-config` to generate compilation and linking flags:

```shell
llvm-config --cflags --ldflags --libs all
```


### Using Moonbit-LLVM

1. Add Moonbit-LLVM as a dependency in your Moonbit project:

   ```shell
   moon add Kaida-Amethyst/llvm
   ```

2. Use `llvm-config` to generate compilation and linking flags, and set environment variables. 

   ```shell
   export CC_FLAGS=$(llvm-config --cflags)
   export CC_LINK_FLAGS=$(llvm-config --ldflags --libs all) -lpthread -ldl -lm -lstdc++
   export C_INCLUDE_PATH=$(llvm-config --includedir):$C_INCLUDE_PATH
   ```

3. Add the dependency and linking flags to `moon.pkg.json`:

   ```json
   {
     "import": [
       "Kaida-Amethyst/llvm/llvm"
     ],
     "link": {
       "native": {
         "cc-flags" : "$CC_FLAGS",
         "cc-link-flags": "$CC_LINK_FLAGS"
       }
     }
   }
   ```

4. Now, you can use LLVM in your Moonbit project.

### Example Program

Below is a simple Moonbit program demonstrating how to use Moonbit-LLVM to generate LLVM IR:

```moonbit
fn main {
  let context = @llvm.Context::create()
  let llvm_module = context.create_module("add_demo")

  let builder = context.create_builder()

  let i32_ty = context.i32_type()
  let fn_ty = i32_ty.fn_type([i32_ty, i32_ty])
  let f = llvm_module.add_function("add", fn_ty)

  let param_a = f.get_nth_param(0).unwrap()
  let param_b = f.get_nth_param(1).unwrap()

  let bb = context.append_basic_block(f, "entry")
  builder.position_at_end(bb)

  let sum = builder.build_add(param_a, param_b, "sum")
  let _ = builder.build_return?(Some(sum))

  println(llvm_module)
}
```

After running the program, you will see the following LLVM IR output:

```llvm
define i32 @add(i32 %0, i32 %1) {
entry:
  %sum = add i32 %0, %1
  ret i32 %sum
}
```

## Contributing and Feedback

Contributions, issues, and suggestions are welcome! Please visit the [GitHub repository](https://github.com/Kaida-Amethyst/moonbit-llvm) to get involved.

## License

Moonbit-LLVM is licensed under the Apache-2.0 License. See the [LICENSE](LICENSE) file for details.

--------------------------

# Moonbit-llvm

Moonbit-llvm 提供了 llvm-c 的 Moonbit 语言绑定，并利用 Moonbit 的特性进行了进一步封装，使开发者能够在 Moonbit 中使用 LLVM 的强大功能，从而更便捷地开发编译器后端等项目。

本项目提供了两种接口：
1. **Unsafe LLVM-C 绑定**：类似于 Rust 的 `llvm-sys`，直接与 LLVM-C API 交互。
2. **Safe LLVM 接口**：类似于 Rust 的 `inkwell`，提供了更安全、易用的 API，参考了 `inkwell` 的设计。

## 注意事项

由于 Moonbit 语言及其构建系统仍在发展中，本项目目前仍处于**测试**阶段，使用方式可能较为复杂，且可能会遇到链接错误、内存泄漏等问题。我们正在积极解决这些问题，并随着 Moonbit 编译器的发展逐步优化使用体验。我们期待未来的 Moonbit 和 Moonbit-LLVM 能为您的 LLVM 开发带来极致体验。

## 快速开始

### 安装 LLVM

首先，您需要在本地安装 LLVM。Moonbit-LLVM 要求 LLVM 版本为 19 或更高。

#### macOS

使用 Homebrew 安装 LLVM：

```shell
brew install llvm@19
```

#### Ubuntu

使用 apt 安装 LLVM:

```bash 
sudo apt install llvm-19-dev -y
```

#### Linux

建议从源码安装 LLVM，以确保版本符合要求。

1. 下载 LLVM 源码：

   ```shell
   git clone --depth 1 https://github.com/llvm/llvm-project.git -b llvmorg-19.0.0
   ```

2. 构建 LLVM：

   ```shell
   cd llvm-project && mkdir build && cd build
   cmake -G Ninja -DCMAKE_BUILD_TYPE="Release" ../llvm
   ninja
   ```

3. 安装 LLVM：

   ```shell
   sudo ninja install
   ```

#### Windows

目前 Moonbit-LLVM 暂不支持 Windows 平台。建议使用虚拟机或 WSL2，并按照 Linux 的安装步骤进行操作。

---------

安装完成后，请确保 `llc --version` 和 `llvm-config` 命令可用。

尝试使用`llvm-config`来生成编译和链接标志。

```shell
llvm-config --cflags --ldflags --libs all
```

### 使用 Moonbit-LLVM

1. 在您的 Moonbit 项目中添加 Moonbit-LLVM 依赖：

   ```shell
   moon add Kaida-Amethyst/llvm
   ```

2. 使用 `llvm-config` 生成编译和链接标志，并设置环境变量。

   ```shell
   export CC_FLAGS=$(llvm-config --cflags)
   export CC_LINK_FLAGS=$(llvm-config --ldflags --libs all)  -lpthread -ldl -lm -lstdc++
   export C_INCLUDE_PATH=$(llvm-config --includedir):$C_INCLUDE_PATH
   ```

3. 在 `moon.pkg.json` 中添加依赖和链接标志：

   ```json
   {
     "import": [
       "Kaida-Amethyst/llvm/llvm"
     ],
     "link": {
       "native": {
         "cc-flags" : "$CC_FLAGS",
         "cc-link-flags": "$CC_LINK_FLAGS"
       }
     }
   }
   ```

4. 现在，您可以在 Moonbit 项目中使用 LLVM 了。

### 示例程序

以下是一个简单的 Moonbit 程序示例，展示了如何使用 Moonbit-LLVM 生成 LLVM IR：

```moonbit
fn main {
  let context = @llvm.Context::create()
  let llvm_module = context.create_module("add_demo")

  let builder = context.create_builder()

  let i32_ty = context.i32_type()
  let fn_ty = i32_ty.fn_type([i32_ty, i32_ty])
  let f = llvm_module.add_function("add", fn_ty)

  let param_a = f.get_nth_param(0).unwrap()
  let param_b = f.get_nth_param(1).unwrap()

  let bb = context.append_basic_block(f, "entry")
  builder.position_at_end(bb)

  let sum = builder.build_add(param_a, param_b, "sum")
  let _ = builder.build_return?(Some(sum))

  println(llvm_module)
}
```

运行该程序后，您将看到以下 LLVM IR 输出：

```llvm
define i32 @add(i32 %0, i32 %1) {
entry:
  %sum = add i32 %0, %1
  ret i32 %sum
}
```

## 贡献与反馈

欢迎贡献代码、提交问题或提出建议！请访问 [GitHub 仓库](https://github.com/Kaida-Amethyst/llvm.mbt) 参与项目。

## 许可证

Moonbit-llvm 采用 Apache-2.0许可证。详情请参阅 [LICENSE](LICENSE) 文件。
