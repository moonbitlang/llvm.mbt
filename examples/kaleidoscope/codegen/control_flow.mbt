///|
fn CodegenContext::codegenIf(
  self : CodegenContext,
  condition : @ast.Expr,
  then_expression : @ast.Expr,
  else_expression : @ast.Expr,
  catalog : PrototypeCatalog,
) -> &@IR.Value raise CodegenError {
  let condition = self.codegenExpr(condition, catalog)
  let condition = backend(() => {
    self.builder.createFCmpONE(
      condition,
      self.context.getConstDouble(0.0),
      name="ifcond",
    )
  })
  let function = self.currentFunction()
  let then_block = backend(() => function.addBasicBlock(name="then"))
  let else_block = backend(() => function.addBasicBlock(name="else"))
  let merge_block = backend(() => function.addBasicBlock(name="ifcont"))
  backend(() => self.builder.createCondBr(condition, then_block, else_block))
  |> ignore

  backend(() => self.builder.setInsertPoint(then_block))
  let then_value = self.codegenExpr(then_expression, catalog)
  backend(() => self.builder.createBr(merge_block)) |> ignore
  let then_end = self.currentBlock()

  backend(() => self.builder.setInsertPoint(else_block))
  let else_value = self.codegenExpr(else_expression, catalog)
  backend(() => self.builder.createBr(merge_block)) |> ignore
  let else_end = self.currentBlock()

  backend(() => self.builder.setInsertPoint(merge_block))
  let phi = backend(() => {
    self.builder.createPHI(self.context.getDoubleTy(), name="iftmp")
  })
  phi.addIncoming(then_value, then_end)
  phi.addIncoming(else_value, else_end)
  (phi : &@IR.Value)
}

///|
fn CodegenContext::codegenFor(
  self : CodegenContext,
  variable : String,
  start : @ast.Expr,
  end : @ast.Expr,
  step : @ast.Expr?,
  body : @ast.Expr,
  catalog : PrototypeCatalog,
) -> &@IR.Value raise CodegenError {
  let start_value = self.codegenExpr(start, catalog)
  let storage = backend(() => {
    self.builder.createAlloca(self.context.getDoubleTy(), name=variable)
  })
  let storage : &@IR.Value = storage
  backend(() => self.builder.createStore(start_value, storage)) |> ignore
  let function = self.currentFunction()
  let loop_block = backend(() => function.addBasicBlock(name="loop"))
  backend(() => self.builder.createBr(loop_block)) |> ignore
  backend(() => self.builder.setInsertPoint(loop_block))
  self.withVariable(variable, storage, () => {
    self.codegenExpr(body, catalog) |> ignore
    let step_value = match step {
      Some(step) => self.codegenExpr(step, catalog)
      None => (self.context.getConstDouble(1.0) : &@IR.Value)
    }
    let current = backend(() => {
      self.builder.createLoad(
        self.context.getDoubleTy(),
        storage,
        name="\{variable}.current",
      )
    })
    let next = backend(() => {
      self.builder.createFAdd(current, step_value, name="\{variable}.next")
    })
    backend(() => self.builder.createStore(next, storage)) |> ignore
    let end_condition = self.codegenExpr(end, catalog)
    let end_condition = backend(() => {
      self.builder.createFCmpONE(
        end_condition,
        self.context.getConstDouble(0.0),
        name="loopcond",
      )
    })
    let loop_end = self.currentBlock()
    let after_block = backend(() => function.addBasicBlock(name="afterloop"))
    backend(() => self.builder.setInsertPoint(loop_end))
    backend(() => {
      self.builder.createCondBr(end_condition, loop_block, after_block)
    })
    |> ignore
    backend(() => self.builder.setInsertPoint(after_block))
  })
  self.context.getConstDouble(0.0)
}
