///|
// Wrapper provenance alone is insufficient: the native block's label type and
// its branch instruction must also belong to the function's LLVMContext.
test "appended and inserted basic blocks use the native function context" {
  for _ in 0..<2 {
    let context = Context::new()
    let mod = context.addModule("block_context")
    let function = mod.addFunction(
      context.getFunctionType(context.getVoidTy(), []),
      "branch",
    )
    let tail = function.addBasicBlock(name="tail")
    let head = function.addBasicBlock(name="head", before=Some(tail))
    for block in [head, tail] {
      let native_type = @raw.llvm_type_of(
        @raw.llvm_basic_block_as_value(block.get_raw_ref()),
      )
      assert_true(
        @raw.llvm_get_type_context(native_type) == context.get_raw_ref(),
        msg="native basic block belongs to a foreign context",
      )
    }
    let builder = context.createBuilder()
    builder.setInsertPoint(head)
    let branch = builder.createBr(tail)
    let native_type = @raw.llvm_type_of(branch.get_raw_value_ref())
    assert_true(
      @raw.llvm_get_type_context(native_type) == context.get_raw_ref(),
      msg="branch belongs to a foreign context",
    )
    builder.setInsertPoint(tail)
    builder.createRetVoid() |> ignore
    mod.verify()
  }
}
