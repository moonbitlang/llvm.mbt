# 第八章：编译器后端实践

在前面七章中，我们学习了如何使用 llvm.mbt 构建各种 LLVM IR 指令。本章将把这些知识整合起来，展示如何在实际编译器中进行代码生成。我们将设计一个简单的编程语言，并实现其后端代码生成器。

## 8.1 编译器架构概述

完整的编译器通常包含前端和后端两个主要部分：

**前端处理流程：**
1. **词法分析（Lexical Analysis）**：将源代码文本转换为词素（tokens）序列
2. **语法分析（Syntactic Analysis）**：根据语法规则将词素序列构建成抽象语法树（AST）
3. **语义分析（Semantic Analysis）**：类型检查、作用域分析、语义验证

**后端处理流程：**
1. **中间代码生成**：将 AST 转换为中间表示（本章重点）
2. **代码优化**：对中间代码进行各种优化
3. **目标代码生成**：生成最终的机器代码

本章**将会假设前端已经完成了语法和语义分析。**，直接展示后端的中间代码生成阶段。

## 8.2 目标语言设计

我们设计一个简单的编程语言，具有以下特性：

- **基本类型**：`Int`（32位整数）和 `Double`（64位浮点数）
- **变量声明**：`let` 声明不可变变量，`let mut` 声明可变变量
- **基本运算**：算术运算、比较运算
- **控制流**：`if`/`else` 条件语句、`while` 循环
- **函数**：函数定义和调用

示例程序：

```moonbit skip
///|
fn calculate_area(radius : Double) -> Double {
  let pi : Double = 3.14159
  let area : Double = pi * radius * radius
  return area
}

///|
fn main {
  let mut result : Double = 0.0
  let r : Double = 5.0
  result = calculate_area(r)
  println_double(result)
}
```

## 8.3 Knf

经过前端处理后，我们得到一个 AST ，为了进一步简化代码生成的过程，我们通常会把AST简化成KNF形式，将复杂的嵌套表达式转换为简单的三地址码形式：

**原始表达式：**

```moonbit skip
///|
let x = 1.0

///|
let y = 2.0

///|
let z = sin(x) * cos(y) + sin(y) * cos(x)
```

**KNF 转换后：**

```moonbit skip
///|
let x = 1.0

///|
let y = 2.0

///|
let tmp1 : Double = sin(x)

///|
let tmp2 : Double = cos(y)

///|
let tmp3 : Double = tmp1 * tmp2

///|
let tmp4 : Double = sin(y)

///|
let tmp5 : Double = cos(x)

///|
let tmp6 : Double = tmp4 * tmp5

///|
let z : Double = tmp3 + tmp6
```

表达式 ADT 定义：

```moonbit skip
///|
enum Expr {
  // 整数运算
  Neg(String) // -operand
  Add(String, String) // lhs + rhs
  Sub(String, String) // lhs - rhs
  Mul(String, String) // lhs * rhs
  Div(String, String) // lhs / rhs

  // 整数比较
  IEQ(String, String) // lhs == rhs
  INE(String, String) // lhs != rhs
  IGE(String, String) // lhs >= rhs
  IGT(String, String) // lhs > rhs
  ILE(String, String) // lhs <= rhs
  ILT(String, String) // lhs < rhs

  // 浮点运算
  FNeg(String) // -operand
  FAdd(String, String) // lhs + rhs
  FSub(String, String) // lhs - rhs
  FMul(String, String) // lhs * rhs
  FDiv(String, String) // lhs / rhs

  // 浮点比较
  FEQ(String, String) // lhs == rhs
  FNE(String, String) // lhs != rhs
  FGE(String, String) // lhs >= rhs
  FGT(String, String) // lhs > rhs
  FLE(String, String) // lhs <= rhs
  FLT(String, String) // lhs < rhs

  // 函数调用
  Call(String, Array[String]) // function_name(args...)
}
```

### 8.3.1 类型定义

```moonbit skip
///|
enum ParserType {
  Int
  Double
  Unit
}

///|
fn ParserType::to_llvm(self, ctx : Context) -> &Type {
  match self {
    Int => ctx.getInt32Ty() as &Type
    Double => ctx.getDoubleTy()
    Unit => ctx.getVoidTy()
  }
}
```

### 8.3.2 语句定义

```moonbit skip
///|
enum Stmt {
  Let(String, ParserType, Expr) // let var: type = expr;
  LetMut(String, ParserType, Expr) // let mut var: type = expr;
  Assign(String, Expr) // var = expr;
  If(Expr, Array[Stmt], Array[Stmt]) // if cond { stmts } else { stmts }
  While(Expr, Array[Stmt]) // while cond { stmts }
  Return(Expr?) // return expr?;
  ExprStmt(Expr) // expr;
}
```

### 8.3.3 函数定义

```moonbit skip
///|
struct FunctionDef {
  name : String
  params : Array[(String, ParserType)] // [(param_name, param_type), ...]
  ret_ty : ParserType
  body : Array[Stmt]
}

///|
struct Program {
  functions : Array[FunctionDef]
}
```

## 8.4 代码生成器实现

### 8.4.1 代码生成器结构

```moonbit skip
///|
struct CodeGen {
  ctx : Context
  mod : Module
  builder : IRBuilder
  symbol_table : Map[String, &Value]

  // 控制流管理
  current_function : Function?
  break_blocks : Array[BasicBlock] // 用于 break 语句
  continue_blocks : Array[BasicBlock] // 用于 continue 语句
}

///|
fn CodeGen::new(ctx : Context, mod_name : String) -> Self {
  let mod = ctx.addModule(mod_name)
  let builder = ctx.createBuilder()
  CodeGen::{
    ctx,
    mod,
    builder,
    symbol_table: Map::new(),
    current_function: None,
    break_blocks: [],
    continue_blocks: [],
  }
}
```

### 8.4.2 表达式代码生成

表达式代码生成的核心是从符号表获取操作数，然后生成相应的 LLVM 指令：

```moonbit skip
///|
fn Expr::compile(self, gen : CodeGen) -> &Value raise {
  match self {
    // 整数取负：使用 0 - operand
    Neg(operand) => {
      let operand_val = self.get_value(gen, operand)
      let zero = gen.ctx.getConstInt32(0)
      gen.builder.createSub(zero, operand_val)
    }

    // 整数加法
    Add(lhs, rhs) => {
      let lhs_val = self.get_value(gen, lhs)
      let rhs_val = self.get_value(gen, rhs)
      gen.builder.createAdd(lhs_val, rhs_val)
    }

    // 整数减法
    Sub(lhs, rhs) => {
      let lhs_val = self.get_value(gen, lhs)
      let rhs_val = self.get_value(gen, rhs)
      gen.builder.createSub(lhs_val, rhs_val)
    }

    // 整数乘法
    Mul(lhs, rhs) => {
      let lhs_val = self.get_value(gen, lhs)
      let rhs_val = self.get_value(gen, rhs)
      gen.builder.createMul(lhs_val, rhs_val)
    }

    // 整数除法
    Div(lhs, rhs) => {
      let lhs_val = self.get_value(gen, lhs)
      let rhs_val = self.get_value(gen, rhs)
      gen.builder.createSDiv(lhs_val, rhs_val)
    }

    // 整数比较
    IEQ(lhs, rhs) => {
      let lhs_val = self.get_value(gen, lhs)
      let rhs_val = self.get_value(gen, rhs)
      gen.builder.createICmpEQ(lhs_val, rhs_val)
    }
    INE(lhs, rhs) => {
      let lhs_val = self.get_value(gen, lhs)
      let rhs_val = self.get_value(gen, rhs)
      gen.builder.createICmpNE(lhs_val, rhs_val)
    }
    IGE(lhs, rhs) => {
      let lhs_val = self.get_value(gen, lhs)
      let rhs_val = self.get_value(gen, rhs)
      gen.builder.createICmpSGE(lhs_val, rhs_val)
    }
    IGT(lhs, rhs) => {
      let lhs_val = self.get_value(gen, lhs)
      let rhs_val = self.get_value(gen, rhs)
      gen.builder.createICmpSGT(lhs_val, rhs_val)
    }
    ILE(lhs, rhs) => {
      let lhs_val = self.get_value(gen, lhs)
      let rhs_val = self.get_value(gen, rhs)
      gen.builder.createICmpSLE(lhs_val, rhs_val)
    }
    ILT(lhs, rhs) => {
      let lhs_val = self.get_value(gen, lhs)
      let rhs_val = self.get_value(gen, rhs)
      gen.builder.createICmpSLT(lhs_val, rhs_val)
    }

    // 浮点取负：使用专用的 FNeg 指令
    FNeg(operand) => {
      let operand_val = self.get_float_value(gen, operand)
      gen.builder.createFNeg(operand_val)
    }

    // 浮点运算
    FAdd(lhs, rhs) => {
      let lhs_val = self.get_float_value(gen, lhs)
      let rhs_val = self.get_float_value(gen, rhs)
      gen.builder.createFAdd(lhs_val, rhs_val)
    }
    FSub(lhs, rhs) => {
      let lhs_val = self.get_float_value(gen, lhs)
      let rhs_val = self.get_float_value(gen, rhs)
      gen.builder.createFSub(lhs_val, rhs_val)
    }
    FMul(lhs, rhs) => {
      let lhs_val = self.get_float_value(gen, lhs)
      let rhs_val = self.get_float_value(gen, rhs)
      gen.builder.createFMul(lhs_val, rhs_val)
    }
    FDiv(lhs, rhs) => {
      let lhs_val = self.get_float_value(gen, lhs)
      let rhs_val = self.get_float_value(gen, rhs)
      gen.builder.createFDiv(lhs_val, rhs_val)
    }

    // 浮点比较
    FEQ(lhs, rhs) => {
      let lhs_val = self.get_float_value(gen, lhs)
      let rhs_val = self.get_float_value(gen, rhs)
      gen.builder.createFCmpOEQ(lhs_val, rhs_val)
    }
    FNE(lhs, rhs) => {
      let lhs_val = self.get_float_value(gen, lhs)
      let rhs_val = self.get_float_value(gen, rhs)
      gen.builder.createFCmpONE(lhs_val, rhs_val)
    }
    FGE(lhs, rhs) => {
      let lhs_val = self.get_float_value(gen, lhs)
      let rhs_val = self.get_float_value(gen, rhs)
      gen.builder.createFCmpOGE(lhs_val, rhs_val)
    }
    FGT(lhs, rhs) => {
      let lhs_val = self.get_float_value(gen, lhs)
      let rhs_val = self.get_float_value(gen, rhs)
      gen.builder.createFCmpOGT(lhs_val, rhs_val)
    }
    FLE(lhs, rhs) => {
      let lhs_val = self.get_float_value(gen, lhs)
      let rhs_val = self.get_float_value(gen, rhs)
      gen.builder.createFCmpOLE(lhs_val, rhs_val)
    }
    FLT(lhs, rhs) => {
      let lhs_val = self.get_float_value(gen, lhs)
      let rhs_val = self.get_float_value(gen, rhs)
      gen.builder.createFCmpOLT(lhs_val, rhs_val)
    }

    // 函数调用
    Call(fname, args) => {
      let func = gen.symbol_table.get(fname).unwrap()
      guard func.asValueEnum() is Function(fval) else {
        raise ValueError("Expected function, got \{func}")
      }
      let arg_vals = args.map(arg => {
        let val = gen.symbol_table.get(arg).unwrap()
        // 如果是指针，需要加载值
        match val.getType().asTypeEnum() {
          PointerType(_) => {
            let load_ty = match fval.getType().getParamType(i) {
              Some(ty) => ty
              None => raise ValueError("Parameter type not found")
            }
            gen.builder.createLoad(load_ty, val)
          }
          _ => val
        }
      })
      gen.builder.createCall(fval, arg_vals)
    }
  }
}

// 辅助方法：获取整数值

///|
fn Expr::get_value(self : Expr, gen : CodeGen, name : String) -> &Value raise {
  let val = gen.symbol_table.get(name).unwrap()
  match val.getType().asTypeEnum() {
    PointerType(_) => gen.builder.createLoad(gen.ctx.getInt32Ty(), val)
    Int32Type(_) => val
    _ => raise ValueError("Expected integer value")
  }
}

// 辅助方法：获取浮点值

///|
fn Expr::get_float_value(
  self : Expr,
  gen : CodeGen,
  name : String,
) -> &Value raise {
  let val = gen.symbol_table.get(name).unwrap()
  match val.getType().asTypeEnum() {
    PointerType(_) => gen.builder.createLoad(gen.ctx.getDoubleTy(), val)
    DoubleType(_) => val
    _ => raise ValueError("Expected double value")
  }
}
```

### 8.4.3 语句代码生成

语句代码生成处理控制流和变量管理：

```moonbit skip
///|
fn Stmt::compile(self : Stmt, gen : CodeGen) -> Unit raise {
  match self {
    // 不可变变量声明
    Let(vname, ptype, expr) => {
      let expr_val = expr.compile(gen)
      gen.symbol_table.set(vname, expr_val)
    }

    // 可变变量声明
    LetMut(vname, ptype, expr) => {
      let expr_val = expr.compile(gen)
      let llvm_type = ptype.to_llvm(gen.ctx)
      let ptr = gen.builder.createAlloca(llvm_type, name=vname)
      let _ = gen.builder.createStore(expr_val, ptr)
      gen.symbol_table.set(vname, ptr)
    }

    // 变量赋值
    Assign(vname, expr) => {
      let expr_val = expr.compile(gen)
      let ptr = gen.symbol_table.get(vname).unwrap()
      guard ptr.getType().asTypeEnum() is PointerType(_) else {
        raise ValueError("Cannot assign to immutable variable")
      }
      let _ = gen.builder.createStore(expr_val, ptr)

    }

    // 条件语句
    If(cond_expr, then_stmts, else_stmts) => {
      let cond_val = cond_expr.compile(gen)
      let current_func = gen.current_function.unwrap()
      let then_bb = current_func.addBasicBlock(name="if.then")
      let else_bb = current_func.addBasicBlock(name="if.else")
      let merge_bb = current_func.addBasicBlock(name="if.end")

      // 生成条件跳转
      let _ = gen.builder.createCondBr(cond_val, then_bb, else_bb)

      // 生成 then 分支
      gen.builder.setInsertPoint(then_bb)
      then_stmts.each(stmt => stmt.compile(gen))
      // 如果 then 分支没有 return，跳转到 merge
      if gen.builder.getInsertBlock().getTerminator() is None {
        let _ = gen.builder.createBr(merge_bb)

      }

      // 生成 else 分支
      gen.builder.setInsertPoint(else_bb)
      else_stmts.each(stmt => stmt.compile(gen))
      // 如果 else 分支没有 return，跳转到 merge
      if gen.builder.getInsertBlock().getTerminator() is None {
        let _ = gen.builder.createBr(merge_bb)

      }

      // 设置插入点到 merge 块
      gen.builder.setInsertPoint(merge_bb)
    }

    // 循环语句
    While(cond_expr, body_stmts) => {
      let current_func = gen.current_function.unwrap()
      let loop_cond_bb = current_func.addBasicBlock(name="while.cond")
      let loop_body_bb = current_func.addBasicBlock(name="while.body")
      let loop_end_bb = current_func.addBasicBlock(name="while.end")

      // 跳转到条件检查
      let _ = gen.builder.createBr(loop_cond_bb)

      // 生成条件检查
      gen.builder.setInsertPoint(loop_cond_bb)
      let cond_val = cond_expr.compile(gen)
      let _ = gen.builder.createCondBr(cond_val, loop_body_bb, loop_end_bb)

      // 生成循环体
      gen.builder.setInsertPoint(loop_body_bb)

      // 保存当前的 break/continue 目标
      let old_break = gen.break_blocks
      let old_continue = gen.continue_blocks
      gen.break_blocks = gen.break_blocks.push(loop_end_bb)
      gen.continue_blocks = gen.continue_blocks.push(loop_cond_bb)
      body_stmts.each(stmt => stmt.compile(gen))

      // 恢复 break/continue 目标
      gen.break_blocks = old_break
      gen.continue_blocks = old_continue

      // 循环体结束，跳回条件检查
      if gen.builder.getInsertBlock().getTerminator() is None {
        let _ = gen.builder.createBr(loop_cond_bb)

      }

      // 设置插入点到循环结束
      gen.builder.setInsertPoint(loop_end_bb)
    }

    // 返回语句
    Return(expr_opt) =>
      match expr_opt {
        Some(expr) => {
          let ret_val = expr.compile(gen)
          let _ = gen.builder.createRet(ret_val)

        }
        None => {
          let _ = gen.builder.createRetVoid()

        }
      }

    // 表达式语句
    ExprStmt(expr) => {
      let _ = expr.compile(gen)

    }
  }
}
```

### 8.4.4 函数代码生成

```moonbit skip
///|
fn FunctionDef::compile(self, gen : CodeGen) -> Function raise {
  // 构建函数类型
  let param_types = self.params.map(param => param.1.to_llvm(gen.ctx))
  let ret_type = self.ret_ty.to_llvm(gen.ctx)
  let func_type = gen.ctx.getFunctionType(ret_type, param_types)

  // 创建函数
  let func = gen.mod.addFunction(func_type, self.name)
  gen.symbol_table.set(self.name, func)
  gen.current_function = Some(func)

  // 创建入口基本块
  let entry_bb = func.addBasicBlock(name="entry")
  gen.builder.setInsertPoint(entry_bb)

  // 处理函数参数
  self.params.mapi((param, i) => {
    let arg = func.getArg(i).unwrap()
    arg.setName(param.0)
    gen.symbol_table.set(param.0, arg)
  })

  // 生成函数体
  self.body.each(stmt => stmt.compile(gen))

  // 如果函数没有显式返回，添加默认返回
  if gen.builder.getInsertBlock().getTerminator() is None {
    match self.ret_ty {
      Unit => gen.builder.createRetVoid()
      Int => {
        let zero = gen.ctx.getConstInt32(0)
        gen.builder.createRet(zero)
      }
      Double => {
        let zero = gen.ctx.getConstDouble(0.0)
        gen.builder.createRet(zero)
      }
    }
  }
  func
}
```

### 8.4.5 程序代码生成

```moonbit skip
///|
fn Program::compile(self, gen : CodeGen) -> Module raise {
  // 编译所有函数
  self.functions.each(func => {
    let _ = func.compile(gen)

  })
  gen.mod
}
```

## 8.5 完整示例

让我们用一个完整的示例来演示整个代码生成过程：

### 8.5.1 源程序

```moonbit skip
///|
fn factorial(n : Int) -> Int {
  let mut result : Int = 1
  let mut i : Int = 1
  while i <= n {
    result = result * i
    i = i + 1
  }
  return result
}

///|
fn main() -> Int {
  let n : Int = 5
  let fact : Int = factorial(n)
  return fact
}
```

### 8.5.2 对应的 AST

```moonbit skip
///|
let program = Program({
  functions: [
    FunctionDef({
      name: "factorial",
      params: [("n", Int)],
      ret_ty: Int,
      body: [
        LetMut("result", Int, Call("const_int", ["1"])),
        LetMut("i", Int, Call("const_int", ["1"])),
        While(ILE("i", "n"), [
          Assign("result", Mul("result", "i")),
          Assign("i", Add("i", Call("const_int", ["1"]))),
        ]),
        Return(Some(Call("load", ["result"]))),
      ],
    }),
    FunctionDef({
      name: "main",
      params: [],
      ret_ty: Int,
      body: [
        Let("n", Int, Call("const_int", ["5"])),
        Let("fact", Int, Call("factorial", ["n"])),
        Return(Some(Call("load", ["fact"]))),
      ],
    }),
  ],
})
```

### 8.5.3 代码生成过程

```moonbit skip
test "compiler_backend_example" {
  let ctx = Context::new()
  let gen = CodeGen::new(ctx, "factorial_program")
  
  // 添加常量辅助函数到符号表
  gen.symbol_table.set("const_int", /* 常量创建函数 */)
  gen.symbol_table.set("load", /* 加载函数 */)
  
  // 编译程序
  let module = program.compile(gen)
  
  let expected_ir = 
    #|define i32 @factorial(i32 %n) {
    #|entry:
    #|  %result = alloca i32, align 4
    #|  store i32 1, ptr %result, align 4
    #|  %i = alloca i32, align 4
    #|  store i32 1, ptr %i, align 4
    #|  br label %while.cond
    #|
    #|while.cond:
    #|  %0 = load i32, ptr %i, align 4
    #|  %1 = icmp sle i32 %0, %n
    #|  br i1 %1, label %while.body, label %while.end
    #|
    #|while.body:
    #|  %2 = load i32, ptr %result, align 4
    #|  %3 = load i32, ptr %i, align 4
    #|  %4 = mul i32 %2, %3
    #|  store i32 %4, ptr %result, align 4
    #|  %5 = load i32, ptr %i, align 4
    #|  %6 = add i32 %5, 1
    #|  store i32 %6, ptr %i, align 4
    #|  br label %while.cond
    #|
    #|while.end:
    #|  %7 = load i32, ptr %result, align 4
    #|  ret i32 %7
    #|}
    #|
    #|define i32 @main() {
    #|entry:
    #|  %0 = call i32 @factorial(i32 5)
    #|  ret i32 %0
    #|}
    #|
  
  inspect(module, content=expected_ir)
}
```

## 8.6 错误处理和优化

### 8.6.1 错误处理

在实际的编译器实现中，需要处理各种错误情况：

```moonbit skip
///|
enum CodeGenError {
  UndefinedVariable(String)
  TypeMismatch(String, String) // expected, actual
  InvalidOperation(String)
  ControlFlowError(String)
}

// 在代码生成过程中进行错误检查

///|
fn check_variable_defined(gen : CodeGen, var_name : String) -> Unit raise {
  guard gen.symbol_table.contains_key(var_name) else {
    raise UndefinedVariable("Variable '\{var_name}' is not defined")
  }
}
```

## 8.8 本章总结

本章展示了如何将前面学到的 LLVM IR 构建知识应用到实际的编译器后端开发中。我们学习了：

1. **编译器架构**：理解前端和后端的职责分工
2. **AST 设计**：如何设计合理的抽象语法树结构
3. **KNF 转换**：简化表达式表示以便代码生成
4. **代码生成策略**：系统化地将 AST 转换为 LLVM IR
5. **符号表管理**：跟踪变量和函数的绑定关系
6. **控制流处理**：正确生成条件语句和循环的 IR
7. **错误处理**：在代码生成过程中进行适当的错误检查

通过本章的学习，您已经具备了构建简单编程语言编译器后端的基础知识。这些技能可以扩展到更复杂的语言特性，如面向对象、模块系统、异常处理等。

编译器后端是一个深度和广度并重的领域，本章只是一个起点。在实际项目中，您还需要考虑更多因素，如性能优化、调试信息生成、多目标平台支持等。但掌握了基本的代码生成原理，您就有了继续深入学习的坚实基础。
