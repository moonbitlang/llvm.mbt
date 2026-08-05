///|
// Verifies that Module::getContext reuses the exact ContextOwner instead of
// creating a second owner for the same borrowed LLVMContextRef. This does not
// test native disposal.
test "Module returns its original Context owner" {
  let context = Context::new()
  let mod = context.addModule("owner_identity")
  let module_context = mod.getContext()
  inspect(
    physical_equal(context.get_owner(), module_context.get_owner()),
    content="true",
  )
  @unsafe.llvm_dispose_module(mod.get_unsafe_ref())
  context.drop()
}

///|
// Exercises the real temporary-Context path as a liveness smoke test. Because
// native finalizers are still inactive, this does not prove exact reference
// counts, exact-once disposal, or native destruction order.
test "Module retains a temporary Context owner" {
  let mod = Context::new().addModule("owner_lifetime")
  let context = mod.getContext()
  inspect(context.getInt32Ty(), content="i32")
  @unsafe.llvm_dispose_module(mod.get_unsafe_ref())
  context.drop()
}
