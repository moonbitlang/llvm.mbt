///|
#borrow(context, mod, di_builder)
extern "C" fn di_builder_owner_test_watch(
  context : ContextOwner,
  mod : ModuleOwner,
  di_builder : DIBuilderOwner,
) = "llvm_mbt_ir_di_builder_owner_test_watch"

///|
fn exercise_di_builder_finalizer(finalize : Bool) -> Unit raise {
  let context = Context::new()
  let mod = context.addModule("di_builder_owner_trace")
  let dib = DIBuilder::new(mod)
  di_builder_owner_test_watch(context.get_owner(), mod.get_owner(), dib.owner)
  let file = dib.createFile("trace.runa", "/tmp")
  dib.createCompileUnit(C11, file, "runa", emissionKind=LineTablesOnly)
  |> ignore
  let sp = dib.createFunction(
    file,
    "f",
    "f",
    file,
    1,
    dib.createSubroutineType(file, []),
  )
  let location = context.createDebugLocation(2, 3, sp)
  inspect(location.getLine(), content="2")
  if finalize {
    dib.finalize()
  }
}

///|
// 5, 2, 1 mean DIBuilder, Module, Context: the DIBuilder is disposed exactly
// once and before the module it writes into, whether or not it was finalized.
test "DIBuilder owner finalizes before its module and context" {
  for finalize in [true, false] {
    exercise_di_builder_finalizer(finalize)
    inspect(owner_test_take_trace(), content="521")
  }
}

///|
fn exercise_di_builder_retains_module() -> Unit raise {
  let dib = DIBuilder::new(Context::new().addModule("retained_by_di_builder"))
  let mod = dib.getModule()
  di_builder_owner_test_watch(
    mod.getContext().get_owner(),
    mod.get_owner(),
    dib.owner,
  )
  // Module and context stay alive through the DIBuilder alone.
  inspect(owner_test_peek_trace(), content="0")
  assert_true(physical_equal(mod.get_owner(), dib.owner.module_owner()))
  dib.createFile("retained.runa", "") |> ignore
  dib.finalize()
}

///|
test "DIBuilder retains its module owner" {
  exercise_di_builder_retains_module()
  inspect(owner_test_take_trace(), content="521")
}
