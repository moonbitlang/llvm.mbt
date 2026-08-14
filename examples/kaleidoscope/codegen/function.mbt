///|
fn CodegenContext::codegenDefinition(
  self : CodegenContext,
  prototype : @ast.Prototype,
  body : @ast.Expr,
  catalog : PrototypeCatalog,
) -> Unit raise CodegenError {
  catalog.validateDefinition(prototype)
  let function = self.declarePrototype(prototype)
  let entry = backend(() => function.addBasicBlock(name="entry"))
  backend(() => self.builder.setInsertPoint(entry))
  let storage : Array[&@IR.Value] = []
  for parameter in prototype.parameters {
    let alloca = backend(() => {
      self.builder.createAlloca(self.context.getDoubleTy(), name=parameter)
    })
    let value : &@IR.Value = alloca
    storage.push(value)
    self.variables.set(parameter, value)
  }
  for index, parameter in prototype.parameters {
    guard function.getArg(index) is Some(argument) else {
      raise BackendFailure(
        "LLVM omitted parameter `\{parameter}` from function `\{prototype.name}`",
      )
    }
    backend(() => argument.setName(parameter))
    backend(() => self.builder.createStore(argument, storage[index])) |> ignore
  }
  let value = self.codegenExpr(body, catalog)
  backend(() => self.builder.createRet(value)) |> ignore
}

///|
fn CodegenContext::codegenExpression(
  self : CodegenContext,
  symbol_name : String,
  expression : @ast.Expr,
  catalog : PrototypeCatalog,
) -> Unit raise CodegenError {
  let prototype : @ast.Prototype = {
    name: symbol_name,
    parameters: [],
    kind: @ast.Normal,
  }
  let function = self.declarePrototype(prototype)
  let entry = backend(() => function.addBasicBlock(name="entry"))
  backend(() => self.builder.setInsertPoint(entry))
  let value = self.codegenExpr(expression, catalog)
  backend(() => self.builder.createRet(value)) |> ignore
}

///|
/// Generates and verifies one function definition in a fresh LLVM module.
///
/// The catalog is read-only during this operation. Call
/// `PrototypeCatalog::commitDefinition` only after any later JIT submission also
/// succeeds.
pub fn compileDefinition(
  catalog : PrototypeCatalog,
  prototype : @ast.Prototype,
  body : @ast.Expr,
  module_name~ : String,
) -> @IR.Module raise CodegenError {
  let operation = CodegenContext::new(module_name~)
  operation.codegenDefinition(prototype, body, catalog)
  operation.verify()
  operation.getModule()
}

///|
/// Generates and verifies a zero-argument wrapper for one expression in a fresh
/// LLVM module.
///
/// **Parameters:**
///
/// - `catalog`: Prototypes visible to calls in the expression.
/// - `expression`: Expression lowered as the wrapper body.
/// - `module_name`: Diagnostic LLVM module name.
/// - `symbol_name`: Unique wrapper symbol used for later lookup.
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let catalog = @codegen.PrototypeCatalog::new()
///   let mod = @codegen.compileExpression(
///     catalog,
///     @ast.Binary('+', @ast.Number(1.0), @ast.Number(2.0)),
///     module_name="example",
///     symbol_name="example_expression",
///   )
///   mod.verify()
/// }
/// ```
pub fn compileExpression(
  catalog : PrototypeCatalog,
  expression : @ast.Expr,
  module_name~ : String,
  symbol_name~ : String,
) -> @IR.Module raise CodegenError {
  let operation = CodegenContext::new(module_name~)
  operation.codegenExpression(symbol_name, expression, catalog)
  operation.verify()
  operation.getModule()
}
