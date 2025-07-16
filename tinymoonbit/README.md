# TinyMoonbit

TinyMoonbit 是一种语法类似 Moonbit 的微型编程语言，其层级与 C 语言相近。它作为教学项目，旨在为 [llvm.mbt](https://github.com/moonbitlang/llvm.mbt) (Moonbit 官方的 LLVM binding) 以及 [Aether](https://github.com/Kaida-Amethyst/Aether) (一个使用 Moonbit 编写的类 LLVM 编译后端框架) 提供支持。

本项目主要演示真`llvm`的代码生成。

尽管 TinyMoonbit 在语法上借鉴了 Moonbit，但为了更贴近底层并与 LLVM 交互，它引入了一些原生 Moonbit 所不具备的特性，例如指针。该项目的主要目的是演示如何将一种高级语言逐步编译为 LLVM IR，为编译器前端开发提供一个清晰、简洁的范例。

## 核心语言特性

### 类型，变量与 `let` 语句

TinyMoonbit 包含以下基本数据类型：`Int`, `Int64`, `UInt`, `UInt64`, `Double`, `Float`。

使用 `let` 来声明或初始化变量。与 Moonbit 不同，TinyMoonbit 不支持类型推导，因此在声明变量时必须显式指定类型，并且初始值的类型必须与声明的类型完全匹配。

```moonbit
let x: Int = 1;
let y: Double = 1.0;
let z: Float = 1.0f;
```

TinyMoonbit 不允许变量遮蔽 (Shadowing)，重复定义同名变量将导致编译错误。

```moonbit
let x: Int = 1;
let x: Int = 2; // 编译错误！
```

允许声明未初始化的变量，但使用未初始化的变量会产生未定义行为。

```moonbit
let x: Int;
println(x); // 结果是未定义的
```

### 表达式与类型转换

支持常规的算术运算、函数调用和数组索引。类型系统非常严格，不会进行隐式类型转换。

```moonbit
let x: Int = 1 + 2;
let y: Double = 1.0 + 2.0;

// 以下代码会编译报错，因为 Int 和 Double 不能直接相加
// let z: Int = 1 + 2.0;

// 必须使用 `as` 进行强制类型转换
let z: Int = 1 + (2.0 as Int);
```

### 赋值

可以对已声明的变量进行赋值。这与 Moonbit 不同，在 Moonbit 中，变量默认是不可变的，需要 `mut` 关键字才能使其可变。

```moonbit
let x: Int = 1;
x = 2; // 合法
```

### 分支与循环

支持 `if-else` 条件分支和 `while` 循环。

```moonbit
let x: Int = 1;
let y: Int = 0;
if x > 0 {
  y = x;
} else {
  y = -x;
}

let count: Int = 0;
while y > 0 {
  count = count + 1;
  y = y - 1;
}
```

### 数组

支持在栈上分配的静态数组。声明数组时必须提供初始值，因为编译器需要根据初始值来确定数组的大小。

```moonbit
let ns: Array[Int] = [1, 2, 3, 4];
println(ns[1]); // 输出 2
```

`let ns: Array[Int];` 这样的声明是不合法的。

### 指针

使用 `ref` 关键字获取变量的地址，产生一个 `Ptr[Type]` 类型的指针。使用 `[]` 对指针进行解引用。

```moonbit
let x: Int = 1;
let xptr: Ptr[Int] = ref x;
let xval: Int = xptr[0];
println(xval); // 输出 1

xptr[0] = 42;
println(x);     // x 的值仍然是 1
println(xval);  // xval 的值仍然是 1
println(xptr[0]); // 输出 42
```

### 强制类型转换

`as` 关键字用于在不同类型之间进行转换。指针类型之间的转换总是允许的，但需要开发者自行确保类型安全。

```moonbit
let x: Int = 1065353216; // 浮点数 1.0 的 IEEE 754 表示
let y: Ptr[Float] = (ref x) as Ptr[Float];
println(y[0]); // 输出 1.0
```

### 动态内存

TinyMoonbit 没有内置的动态数组或垃圾回收机制。可以通过 `malloc` 和 `free` 函数手动管理堆内存，这与 C 语言非常相似。

```moonbit
// 分配可以容纳两个整数的内存
let ns: Ptr[Int] = malloc(8) as Ptr[Int];
ns[0] = 1;
ns[1] = 2;

free(ns);
```

### `sizeof`

`sizeof` 关键字可以获取一个类型或值所占用的字节数。

```moonbit
let sz_int: Int = sizeof(Int);
println(sz_int); // 在 32位系统上通常输出 4

let sz_double: Int = sizeof(3.0);
println(sz_double); // 通常输出 8
```

### 结构体

支持定义结构体。结构体的实例化需要先声明，然后对成员逐一赋值。

```moonbit
struct Point {
  x: Double;
  y: Double
}

// 在栈上分配
let p: Point;
p.x = 1.0;
p.y = 2.0;

// 在堆上分配
let p_ptr: Ptr[Point] = malloc(sizeof(Point)) as Ptr[Point];
p_ptr[0].x = 1.0;
p_ptr[0].y = 2.0;
```

### 函数

函数的定义和调用语法与其他主流语言类似。

```moonbit
fn add(x: Int, y: Int) -> Int {
  return x + y;
}

fn main {
  let z: Int = add(1, 2);
  println(z); // 输出 3
}
```

为了简化实现，`println` 和 `free` 是两个特殊的内置函数，它们在类型检查上会有所放宽。

## 代码生成与 LLVM IR

TinyMoonbit 的核心目标之一是展示如何将高级语言特性映射到 LLVM IR。下面是一些示例，说明 TinyMoonbit 代码是如何被编译的。

### 示例 1: 变量和算术运算

**TinyMoonbit 代码:**
```moonbit
fn foo() -> Unit {
  let x: Int = 10;
  let y: Int = 20;
  let z: Int = x + y;
}
```

**生成的 LLVM IR:**
在 LLVM 中，局部变量通常通过 `alloca`指令在栈上分配内存。`let` 语句的初始化则对应 `store` 指令。算术运算则直接映射到 LLVM 的二元运算指令。

```llvm
define void @foo() {
entry:
  %z = alloca i32, align 4
  %y = alloca i32, align 4
  %x = alloca i32, align 4
  store i32 10, ptr %x, align 4
  store i32 20, ptr %y, align 4
  %0 = load i32, ptr %x, align 4
  %1 = load i32, ptr %y, align 4
  %add = add nsw i32 %0, %1
  store i32 %add, ptr %z, align 4
  ret void
}
```

### 示例 2: 条件分支

**TinyMoonbit 代码:**
```moonbit
fn foo() -> Int {
  let x: Int = 10;
  if x > 5 {
    return 1;
  } else {
    return 0;
  }
}
```

**生成的 LLVM IR:**
`if-else` 语句被编译成由基本块（basic block）和条件跳转指令（`br`）构成的控制流图。`icmp` 指令用于执行比较，其结果（`i1` 类型）被 `br` 指令用来决定跳转到 `then` 块还是 `else` 块。

```llvm
define i32 @foo() {
entry:
  %x = alloca i32, align 4
  store i32 10, ptr %x, align 4
  %0 = load i32, ptr %x, align 4
  %cmp = icmp sgt i32 %0, 5
  br i1 %cmp, label %then, label %else

then:
  ret i32 1

else:
  ret i32 0
}
```

### 示例 3: 函数调用

**TinyMoonbit 代码:**
```moonbit
fn add(a: Int, b: Int) -> Int {
  return a + b;
}

fn main {
  let result: Int = add(3, 4);
  println(result)
}
```

**生成的 LLVM IR:**
函数定义直接映射为 LLVM 的 `define`。函数调用则使用 `call` 指令。参数通过 LLVM 函数参数传递，返回值通过 `ret` 指令返回。

```llvm
define i32 @add(i32 %a, i32 %b) {
entry:
  %add = add nsw i32 %a, %b
  ret i32 %add
}

define i32 @main() {
entry:
  %result = alloca i32, align 4
  %call = call i32 @add(i32 3, i32 4)
  store i32 %call, ptr %result, align 4
  %0 = load i32, ptr %result, align 4
  ret i32 %0
}
```

