
（标题：第一章：整数与浮点数的基础运算）

- 手动硬编码一些简单的llvm程序，利用llvm.mbt编写llvm程序，只需要展示llvm ir，不需要再链接了。

- 只展示基本操作，加减乘除，取余，位运算等等。

## 起手

```moonbit
let ctx = Context::new()
let mod = ctx.addModule("demo")
let builder = ctx.createBuilder()
```

解释一下Context，Module，IRBuilder都是什么。

Context用于存放类型信息，常量信息等，Module是具体的程序信息，存放函数等，IRBuilder是一个IR工厂。

## 整数

用硬编码来解释，

```c
int add42(int a, int b) {
  return a+b+42;
}
```

要用到的函数`getInt32Ty`，`createAdd`, `createRet`

然后指出，支持加减乘除，取余，位移运算，位运算。支持`int8`，`int16`，`int32`, `int64`，列出接口即可，不必过多展示代码。

- 需要指出的是，原版llvm支持任意宽度的整数类型，例如可以定义46位的整数，但是在llvm.mbt里，刻意地没有使用这个特性，取而代之的是明确地使用了`Int8Type`，`Int16Type`，`Int32Type`，`Int64Type`，这是因为前端语言很少出现除了这些整数类型之外的整数类型，为了让llvm.mbt更好用，就没有加这个特性。除非以后有明确的需求。

## 特殊的Int1Type

额外地介绍一下Int1Type，它有两种，true和false，可以使用`getInt1Ty`得到类型，可以使用`getConstTrue`和`getConstFalse`来得到常量值。

## 浮点数

仍然用硬编码解释：

```c
double add1(double a, double b) {
  return a+b+1.0;
}
```

要用到的函数：`getDoubleTy`, `getConstDouble`, `createFAdd`

> 明确指出`createAdd`不可以用来浮点数加法。

指出，支持浮点数的加减乘除，取余,等操作，列出接口即可，不需要展示代码。

