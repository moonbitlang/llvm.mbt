///|
fn Context::block_contents_codegen(
  self : Self,
  block : @knf.KnfBlock,
) -> &@llvm.Value? raise {
  let stmts_count = block.stmts.length()
  if stmts_count == 0 {
    return None
  }
  for stmt in block.stmts[:stmts_count - 1] {
    if self.current_block().getTerminator() is None {
      self.stmt_codegen(stmt)
    }
  }
  if self.current_block().getTerminator() is Some(_) {
    return None
  }
  match block.stmts.last() {
    Some(ExprStmt(Unit)) => None
    Some(ExprStmt(expr)) => self.expr_codegen(expr)
    Some(stmt) => {
      self.stmt_codegen(stmt)
      None
    }
    None => None
  }
}

///|
fn Context::block_codegen(
  self : Self,
  block : @knf.KnfBlock,
) -> &@llvm.Value? raise {
  let current_func = self.current_function()
  let block_bb = current_func.addBasicBlock()
  let after_bb = current_func.addBasicBlock()
  let _ = self.builder.createBr(block_bb)
  self.builder.setInsertPoint(block_bb)
  let value = self.block_contents_codegen(block)
  if self.current_block().getTerminator() is Some(_) {
    after_bb.eraseFromParent()
    return None
  }
  let _ = self.builder.createBr(after_bb)
  self.builder.setInsertPoint(after_bb)
  if block.ty is Unit {
    None
  } else {
    value
  }
}
