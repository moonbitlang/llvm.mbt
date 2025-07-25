# llvm.mbt

**llvm.mbt** 🚀 是一个为 [MoonBit](https://www.moonbitlang.com/) 语言设计的全面 LLVM 绑定库，提供了**C++ 风格的 API** 和增强的类型安全性。基于 LLVM-C 绑定构建，它提供了与原版 LLVM C++ 相似的开发体验，同时利用 MoonBit 的强大类型系统来防止常见的编程错误。

## MGPIC竞赛须知

2025年MGPIC编译赛道允许输出LLVM IR，但编译器本体使用wasm-gc后端编译，因此编译到native后端的`llvm.mbt`不能用于提交，你可以使用[MoonLLVM](https://github.com/moonbitlang/MoonLLVM.git)，这是官方提供的一个llvm IR生成器，接口与`llvm.mbt`非常接近，二者切换起来非常容易。

1. `MoonLLVM`与`llvm.mbt`的差别，`llvm.mbt`是真llvm的moonbit语言binding，需要链接到llvm库，并保证llvm版本在llvm-19以上，只能使用native后端，可以使用llvm的一些高级功能，但缺少一些直接操控内部数据结构的手段。`MoonLLVM`是moonbit语言的llvm简单复刻，不需要链接到llvm库，可以输出到所有moonbit支持的后端，可以直接操控一些数据结构，但缺少一些高级功能。

2. `MoonLLVM`与`llvm.mbt`的接口类型，尽管有一定的差别，但开发者切换二者的成本很低。

3. 竞赛期间MoonLLVM仍然保持更新，但从8月10日起到比赛结束，进入暂时的稳定状态，对breaking change将保持克制，使用deprecated warning来进行提示，并且其中的warning信息将可能与比赛相关。比赛结束后，MoonLLVM将会恢复到不稳定的状态。

## ✨ 核心特性

- 🎯 **C++ 风格 API**：与 LLVM C++ API 高度相似的接口设计
- 🔒 **增强类型安全**：MoonBit 类型系统防止空指针解引用和类型不匹配
- 🛡️ **内存安全**：自动内存管理，必要时提供手动控制
- 📦 **完整覆盖**：对 LLVM 核心功能的全面绑定
- 🔧 **开发友好**：直观的 API 设计和清晰的错误信息

## 🏗️ 架构设计

**llvm.mbt** 采用两层结构设计：

1. **🔧 底层 LLVM-C 绑定** (`unsafe` 模块)
   - 直接绑定到 LLVM-C APIs
   - 零成本的 C 函数抽象
   - 为性能关键代码提供原始指针处理

2. **🛡️ 高层安全 API** (主模块)
   - C++ 风格的面向对象接口
   - LLVM 概念的类型安全包装
   - 自动资源管理
   - 增强的错误处理

## 📋 系统要求

- **LLVM**：19 或更高版本
- **MoonBit**：最新版本
- **C 编译器**：GCC 或 Clang
- **平台**：Linux、macOS（Windows 通过 WSL2）

## 🚀 快速开始

### 1. 安装 LLVM

#### 🍎 macOS
```bash
brew install llvm@19
```

#### 🐧 Ubuntu/Debian
```bash
sudo apt install llvm-19-dev -y
```

#### 🐧 Linux（从源码构建）
```bash
# 下载 LLVM 源码
git clone --depth 1 https://github.com/llvm/llvm-project.git -b llvmorg-19.0.0

# 构建和安装
cd llvm-project && mkdir build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE="Release" ../llvm
ninja && sudo ninja install
```

### 2. 验证安装
```bash
# 检查命令是否可用
llc --version
llvm-config --version

# 测试配置生成
llvm-config --cflags --ldflags --libs all
```

### 3. 添加 llvm.mbt 到您的项目

```bash
moon update
moon add Kaida-Amethyst/llvm
```

### 4. 配置构建环境

```bash
# 设置环境变量
export CC_FLAGS="$(llvm-config --cflags)"
export CC_LINK_FLAGS="$(llvm-config --ldflags --libs all) -lpthread -ldl -lm -lstdc++"
export C_INCLUDE_PATH="$(llvm-config --includedir):$C_INCLUDE_PATH"
```

### 5. 更新 moon.pkg.json

```json
{
  "import": [
    "Kaida-Amethyst/llvm"
  ],
  "link": {
    "native": {
      "cc-flags": "$CC_FLAGS",
      "cc-link-flags": "$CC_LINK_FLAGS"
    }
  }
}
```

## 💡 使用示例

以下是一个完整的示例，展示如何使用 **llvm.mbt** 生成 LLVM IR：

```moonbit
fn main {
  // 创建 LLVM 上下文 - 所有 LLVM 操作的根
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()

  // 使用 C++ 风格 API 定义类型
  let i32_ty = ctx.getInt32Ty()
  let func_ty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])

  // 使用 C++ 风格的方法调用创建函数
  let add_func = mod.addFunction(func_ty, "add")
  let entry_bb = add_func.appendBasicBlock(name="entry")
  
  // 安全地获取函数参数
  let arg1 = add_func.getArg(0).unwrap()
  let arg2 = add_func.getArg(1).unwrap()

  // 使用熟悉的 C++ 模式构建 IR
  builder.setInsertPoint(entry_bb)
  let sum = builder.createAdd(arg1, arg2, name="sum")
  builder.createRet(sum)

  // 打印生成的函数
  println(add_func)
}
```

**输出：**
```llvm
define i32 @add(i32 %0, i32 %1) {
entry:
  %sum = add i32 %0, %1
  ret i32 %sum
}
```

## 🤝 贡献指南

我们欢迎贡献！请：

1. **🍴 Fork** 仓库
2. **🌿 创建** 功能分支
3. **✅ 为新功能** 添加测试
4. **📝 提交** Pull Request

访问我们的 [GitHub 仓库](https://github.com/moonbitlang/llvm.mbt) 开始贡献。

## 📄 许可证

**llvm.mbt** 采用 **Apache-2.0 许可证**。详情请参阅 [LICENSE](LICENSE) 文件。

# llvm.mbt

[🇨🇳 中文版](#llvmmbt-1)

**llvm.mbt** 🚀 is a comprehensive LLVM binding for the [MoonBit](https://www.moonbitlang.com/) language that provides a **C++-style API** with enhanced type safety. Built on top of LLVM-C bindings, it offers a familiar development experience similar to original LLVM C++ while leveraging MoonBit's powerful type system to prevent common programming errors.

## ✨ Key Features

- 🎯 **C++-Style API**: Familiar interface design closely mirroring LLVM C++ API
- 🔒 **Enhanced Type Safety**: MoonBit's type system prevents null pointer dereferences and type mismatches
- 🛡️ **Memory Safety**: Automatic memory management with manual control when needed
- 📦 **Complete Coverage**: Comprehensive bindings for LLVM core functionality
- 🔧 **Developer Friendly**: Intuitive API design with clear error messages

## 🏗️ Architecture

**llvm.mbt** is structured with two main layers:

1. **🔧 Low-level LLVM-C Bindings** (`unsafe` module)
   - Direct bindings to LLVM-C APIs
   - Zero-cost abstractions over C functions
   - Raw pointer handling for performance-critical code

2. **🛡️ High-level Safe API** (main module)
   - C++-style object-oriented interface
   - Type-safe wrappers around LLVM concepts
   - Automatic resource management
   - Enhanced error handling

## 📋 Requirements

- **LLVM**: Version 19 or higher
- **MoonBit**: Latest version
- **C Compiler**: GCC or Clang
- **Platform**: Linux, macOS (Windows via WSL2)

## 🚀 Quick Start

### 1. Install LLVM

#### 🍎 macOS
```bash
brew install llvm@19
```

#### 🐧 Ubuntu/Debian
```bash
sudo apt install llvm-19-dev -y
```

#### 🐧 Linux (from source)
```bash
# Download LLVM source
git clone --depth 1 https://github.com/llvm/llvm-project.git -b llvmorg-19.0.0

# Build and install
cd llvm-project && mkdir build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE="Release" ../llvm
ninja && sudo ninja install
```

### 2. Verify Installation
```bash
# Check if commands are available
llc --version
llvm-config --version

# Test configuration generation
llvm-config --cflags --ldflags --libs all
```

### 3. Add llvm.mbt to Your Project

```bash
moon update
moon add Kaida-Amethyst/llvm
```

### 4. Configure Build Environment

```bash
# Set environment variables
export CC_FLAGS="$(llvm-config --cflags)"
export CC_LINK_FLAGS="$(llvm-config --ldflags --libs all) -lpthread -ldl -lm -lstdc++"
export C_INCLUDE_PATH="$(llvm-config --includedir):$C_INCLUDE_PATH"
```

### 5. Update moon.pkg.json

```json
{
  "import": [
    "Kaida-Amethyst/llvm"
  ],
  "link": {
    "native": {
      "cc-flags": "$CC_FLAGS",
      "cc-link-flags": "$CC_LINK_FLAGS"
    }
  }
}
```

## 💡 Usage Example

Here's a complete example showing how to use **llvm.mbt** to generate LLVM IR:

```moonbit
fn main {
  // Create LLVM context - the root of all LLVM operations
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()

  // Define types using C++-style API
  let i32_ty = ctx.getInt32Ty()
  let func_ty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])

  // Create function with C++-style method calls
  let add_func = mod.addFunction(func_ty, "add")
  let entry_bb = add_func.appendBasicBlock(name="entry")
  
  // Get function arguments safely
  let arg1 = add_func.getArg(0).unwrap()
  let arg2 = add_func.getArg(1).unwrap()

  // Build IR using familiar C++ patterns
  builder.setInsertPoint(entry_bb)
  let sum = builder.createAdd(arg1, arg2, name="sum")
  builder.createRet(sum)

  // Print the generated function
  println(add_func)
}
```

**Output:**
```llvm
define i32 @add(i32 %0, i32 %1) {
entry:
  %sum = add i32 %0, %1
  ret i32 %sum
}
```


## 🤝 Contributing

We welcome contributions! Please:

1. **🍴 Fork** the repository
2. **🌿 Create** a feature branch
3. **✅ Add** tests for new functionality
4. **📝 Submit** a pull request

Visit our [GitHub repository](https://github.com/moonbitlang/llvm.mbt) to get started.

## 📄 License

**llvm.mbt** is licensed under the **Apache-2.0 License**. See [LICENSE](LICENSE) for details.

---

