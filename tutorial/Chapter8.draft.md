
（标题：第八章：编译器后端实践）

(本章所有的Moonbit代码块需要标记成moonbit skip)

- 完整的编译器包含前端和后端两个部分，前端部分包含词法分析，语法分析和语义检查三个阶段。解析语法是一项比较复杂的工作，较为完整的编译器实现可以找到教程的末尾，但是在本教程的当下阶段，还不打算讲述这块内容。

(假想的语言只有int和double两种类型，简单的语句，没有结构体，数组和指针，可以通过let语句声明变量，支持赋值，可以函数调用)

```moonbit fake

fn foo() -> Unit {
  let v: Double = 3.14;
  println(sin(v));
}

fn main() -> Unit {
  foo();
}

```

- 当下，假设我们已经完成了语法解析的部分，我们已经得到了语法树，然后通过knf转换，将复杂的复合形式拆分成简单形式（表达式不会嵌套表达式了，而是规约成一个符号）

- knf 形式

```moonbit skip
let x = 1.0;
let y = 2.0;
let z = sin(x) * cos(y) + sin(y) * cos(x) ;
```

knf会是简单形式，会变成下面：

```moonbit skip
let x : Double = 1.0;
let y : Double = 2.0;

let tmp1: Double = sin(x);
let tmp2: Double = cos(y);
let tmp3: Double = tmp1 * tmp2;

let tmp4: Double = sin(y);
let tmp5: Double = cos(x);
let tmp6: Double = tmp4 * tmp5;
```


## 表达式的生成

先来探讨一下，下面的ADT的代码生成

```moonbit skip
enum Expr {
  Neg(String)
  Add(String, String)
  Sub(String, String)
  Mul(String, String)
  Div(String, String)
  IEQ(String, String)
  INE(String, String)
  IGE(String, String)
  IGT(String, String)
  ILE(String, String)
  ILT(String, String)
  FNeg(String)
  FAdd(String, String)
  FSub(String, String)
  FMul(String, String)
  FDiv(String, String)
  FEQ(String, String)
  FNE(String, String)
  FGE(String, String)
  FGT(String, String)
  FLE(String, String)
  FLT(String, String)
  Call(String, Array[String])
}
```

假设我们已经解析完毕，并且通过了类型检查，程序其它的部分我们得到了一个符号表(Symbol Table)，是`String-> &Value`的Map

```moonbit skip
traitalias @IR.Value

let symbol_table: Map[String, &Value] = ...
```

- 对于`&Value`注意，这是一个Trait Object，llvm里面的Value可能有多种方式得到，可能是常量，也可能是指令的结果，也可能是函数的参数，无论它们的来源是什么，它们都实现了`Value`的Trait，总是可以通过`&Value` 来获取。

对于一个具体的Expr，应该怎么进行代码生成?

```moonbit skip
typealias @IR.(Context, Module, IRBuilder)
traitalias @IR.Value

struct Codegen {
  ctx: Context
  mod: Module
  builder: IRBuilder
  symbol_table: Map[String, &Value]
}

fn Expr::compile(self: Expr, gen:Codegen) -> &Value {
  match self {
    Neg(operand) => {
      let operand = gen.symbol_table.get(operand).unwrap()
      let zero = gen.ctx.getConstInt(0)
      let operand = match operand.getType().asTypeEnum() {
        PointerType(_) => builder.createLoad(ctx.getInt32Ty())
        Int32Type(_) => operand
        _ => panic()
      }
      builder.createSub(zero, operand)
    }
    Add(lhs, rhs) => {
      let lhs = symbol_table.get(lhs).unwrap()
      let rhs = symbol_table.get(rhs).unwrap()
      let lhs = match lhs.getType().asTypeEnum() {
        PointerType(_) => builder.createLoad(ctx.getInt32Ty())
        Int32Type(_) => operand
        _ => panic()
      }
      let rhs = match rhs.getType().asTypeEnum() {
        PointerType(_) => builder.createLoad(ctx.getInt32Ty())
        Int32Type(_) => operand
        _ => panic()
      }
      builder.createAdd(lhs, rhs)
    }
    // 补全代码
    FNeg(operand) => {
      let operand = gen.symbol_table.get(operand).unwrap()
      let operand = match operand.getType().asTypeEnum() {
        PointerType(_) => builder.createLoad(ctx.getFloatTy())
        FloatType(_) => operand
        _ => panic()
      }
      builder.createFNeg(operand)
    }
    FAdd(lhs, rhs) => {
      let lhs = symbol_table.get(lhs).unwrap()
      let rhs = symbol_table.get(rhs).unwrap()
      let lhs = match lhs.getType().asTypeEnum() {
        PointerType(_) => builder.createLoad(ctx.getFloatTy())
        FloatType(_) => operand
        _ => panic()
      }
      let rhs = match rhs.getType().asTypeEnum() {
        PointerType(_) => builder.createLoad(ctx.getFloatTy())
        FloatType(_) => operand
        _ => panic()
      }
      builder.createFAdd(lhs, rhs)
    }
    // 补全代码
    Call(fname, args) => {
      guard gen.symbol_table.get(fname).asValueEnum() is Function(fval)
      let args = args.map(a => gen.symbol_table.get(a).unwrap())
      builder.createCall(fval, args)
    }
  }
}
```

- 首先从symbol_table里面获取值，再调用create指令。

- （已经经过了类型检查，所以不必担心createAdd等函数会出现类型错误）

- 可能是Ptr也可能是Int或者Double类型，注意前提是已经通过了类型检查，如果是Ptr，说明是内存上的变量，调用load。

- 整数的Neg要通过被0减得到，而浮点数的Neg要通过createFNeg，这是因为浮点数的特性决定的，浮点数有两种0，正0和负0，而用0减取负数的做法可能无法得到想要的。

- `Expr::compile`除了发射指令，记得要返回一个Value，因为Expr的结果通常要被用到:

## 语句的生成

对于语句，我们通常的ADT是这样：

```moonbit skip
enum Stmt {
  Let(String, ParserType, Expr)
  LetMut(String, ParserType, Expr)
  Assign(String, Expr)
  If(Expr, Array[Stmt], Array[Stmt])
  While(Expr, Array[Stmt])
  Return(Expr?)
}

enum ParserType {
  Int
  Double
  Unit
}
```

对Stmt做代码生成：

```moonbit skip
fn Stmt::compile (self: Stmt, gen: CodeGen) -> Unit {
  match self {
    Let(vname, ptype, expr) => {
      let expr_val = expr.compile(gen)
      let llvm_type = ptype.to_llvm()
      gen.symbol_table.set(vname, expr_val)
    }
    LetMut(vname, ptype, expr) => {
      let expr_val = expr.compile(gen)
      let llvm_type = ptype.to_llvm()
      let ptr = gen.builder.createAlloca(llvm_type)
      let _ = gen.builder.createStore(ptr, expr_val)
      gen.symbol_table.set(vname, ptr)
    }
    Assign(vname, expr) => {
      let expr_val = expr.compile(gen)
      let ptr = gen.symbol_table.get(vname).unwrap()
      let _ = gen.builder.createStore(ptr, expr_val)
    }
    If(..) => ...
    While(...) => ...
  }
}
```

- 注意返回类型是Unit，它没有返回值

- 注意这里有let和let mut，let定义的变量没有可变性，直接用即可，let mut有可变性，需要在内存里面。

- 需要单独解释Stmt的每种可能.

## 函数

```moonbit skip
struct Function {
  name: String
  params: Array[ParserType]
  ret_ty: ParserType
  body: Array[Stmt]
}
```

对Function做代码生成：

```
fn Function::compile(self: Function, gen:Codegen) -> Unit {
}
```
