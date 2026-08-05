///|
extern "C" fn owner_test_reset() = "llvm_mbt_ir_owner_test_reset"

///|
extern "C" fn owner_test_context_new() -> ContextOwner = "llvm_mbt_ir_owner_test_context_new"

///|
#borrow(context)
extern "C" fn owner_test_module_new(context : ContextOwner) -> ModuleOwner = "llvm_mbt_ir_owner_test_module_new"

///|
extern "C" fn owner_test_context_finalize_count() -> Int = "llvm_mbt_ir_owner_test_context_finalize_count"

///|
extern "C" fn owner_test_module_finalize_count() -> Int = "llvm_mbt_ir_owner_test_module_finalize_count"

///|
test "owner aliases share one managed object" {
  owner_test_reset()
  let owner = owner_test_context_new()
  let owner_copy = owner
  inspect(owner.same(owner_copy), content="true")
  inspect(owner_test_context_finalize_count(), content="0")
  owner |> ignore
  owner_copy |> ignore
  inspect(owner_test_context_finalize_count(), content="1")
}

///|
test "module owner retains its context owner" {
  owner_test_reset()
  let context = owner_test_context_new()
  let mod = owner_test_module_new(context)
  context |> ignore
  inspect(owner_test_context_finalize_count(), content="0")
  mod |> ignore
  inspect(owner_test_module_finalize_count(), content="1")
  inspect(owner_test_context_finalize_count(), content="1")
}
