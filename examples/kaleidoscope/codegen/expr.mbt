///|
fn CodegenContext::codegenExpr(
  self : CodegenContext,
  expression : @ast.Expr,
  catalog : PrototypeCatalog,
) -> &@IR.Value raise CodegenError {
  match expression {
    Number(value) => (self.context.getConstDouble(value) : &@IR.Value)
    Variable(name) =>
      match self.variables.get(name) {
        Some(storage) => {
          let loaded = backend(() => {
            self.builder.createLoad(self.context.getDoubleTy(), storage, name~)
          })
          (loaded : &@IR.Value)
        }
        None => raise UnknownVariable(name)
      }
    Binary(operator, left, right) =>
      match operator {
        '+' => {
          let left = self.codegenExpr(left, catalog)
          let right = self.codegenExpr(right, catalog)
          backend(() => self.builder.createFAdd(left, right, name="addtmp"))
        }
        '-' => {
          let left = self.codegenExpr(left, catalog)
          let right = self.codegenExpr(right, catalog)
          backend(() => self.builder.createFSub(left, right, name="subtmp"))
        }
        '*' => {
          let left = self.codegenExpr(left, catalog)
          let right = self.codegenExpr(right, catalog)
          backend(() => self.builder.createFMul(left, right, name="multmp"))
        }
        '<' => {
          let left = self.codegenExpr(left, catalog)
          let right = self.codegenExpr(right, catalog)
          let comparison = backend(() => {
            self.builder.createFCmpOLT(left, right, name="cmptmp")
          })
          backend(() => {
            self.builder.createUIToFP(
              comparison,
              self.context.getDoubleTy(),
              name="booltmp",
            )
          })
        }
        _ => self.codegenCall("binary\{operator}", [left, right], catalog)
      }
    Unary(operator, operand) =>
      self.codegenCall("unary\{operator}", [operand], catalog)
    Call(name, arguments) => self.codegenCall(name, arguments, catalog)
    If(condition, then_expression, else_expression) =>
      self.codegenIf(condition, then_expression, else_expression, catalog)
    For(variable, start, end, step, body) =>
      self.codegenFor(variable, start, end, step, body, catalog)
    Var(bindings, body) => self.codegenVar(bindings, body, catalog)
    Assign(name, value) => self.codegenAssign(name, value, catalog)
  }
}

///|
fn CodegenContext::codegenAssign(
  self : CodegenContext,
  name : String,
  expression : @ast.Expr,
  catalog : PrototypeCatalog,
) -> &@IR.Value raise CodegenError {
  guard self.variables.get(name) is Some(storage) else {
    raise UnknownVariable(name)
  }
  let value = self.codegenExpr(expression, catalog)
  backend(() => self.builder.createStore(value, storage)) |> ignore
  value
}

///|
fn CodegenContext::codegenVarBindings(
  self : CodegenContext,
  bindings : Array[@ast.VarBinding],
  index : Int,
  body : @ast.Expr,
  catalog : PrototypeCatalog,
) -> &@IR.Value raise CodegenError {
  if index == bindings.length() {
    return self.codegenExpr(body, catalog)
  }
  let binding = bindings[index]
  let initial_value = match binding.initializer {
    Some(initializer) => self.codegenExpr(initializer, catalog)
    None => (self.context.getConstDouble(0.0) : &@IR.Value)
  }
  let storage = self.createEntryAlloca(binding.name)
  backend(() => self.builder.createStore(initial_value, storage)) |> ignore
  self.withVariable(binding.name, storage, () => {
    self.codegenVarBindings(bindings, index + 1, body, catalog)
  })
}

///|
fn CodegenContext::codegenVar(
  self : CodegenContext,
  bindings : Array[@ast.VarBinding],
  body : @ast.Expr,
  catalog : PrototypeCatalog,
) -> &@IR.Value raise CodegenError {
  let names : Map[String, Bool] = Map([])
  for binding in bindings {
    guard binding.name != "" else {
      raise InvalidVariableBinding("variable name must not be empty")
    }
    guard names.get(binding.name) is None else {
      raise InvalidVariableBinding(
        "variable list repeats binding `\{binding.name}`",
      )
    }
    names.set(binding.name, true)
  }
  guard bindings.length() > 0 else {
    raise InvalidVariableBinding("variable list must not be empty")
  }
  self.codegenVarBindings(bindings, 0, body, catalog)
}

///|
fn CodegenContext::codegenCall(
  self : CodegenContext,
  name : String,
  arguments : Array[@ast.Expr],
  catalog : PrototypeCatalog,
) -> &@IR.Value raise CodegenError {
  let function = self.resolveFunction(catalog, name)
  guard function.getNumArgs() == arguments.length() else {
    raise ArgumentCountMismatch(name, function.getNumArgs(), arguments.length())
  }
  let values : Array[&@IR.Value] = []
  for argument in arguments {
    values.push(self.codegenExpr(argument, catalog))
  }
  let call = backend(() => {
    self.builder.createCall(function, values, name="calltmp")
  })
  (call : &@IR.Value)
}
