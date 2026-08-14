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
  }
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
