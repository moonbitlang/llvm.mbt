///|
fn define_double_constant(
  context : @IR.Context,
  mod : @IR.Module,
  name : String,
  value : Double,
) -> Unit raise {
  let function_type = context.getFunctionType(context.getDoubleTy(), [])
  let function = mod.addFunction(function_type, name)
  let entry = function.addBasicBlock(name="entry")
  let builder = context.createBuilder()
  builder.setInsertPoint(entry)
  builder.createRet(context.getConstDouble(value)) |> ignore
}

///|
test "JIT resolves definitions across submitted modules" {
  let jit = @JIT.LLJIT::host()
  let definition_context = @IR.Context::new()
  let definition_module = definition_context.addModule("permanent_definition")
  define_double_constant(
    definition_context, definition_module, "jit_permanent_value", 21.0,
  )
  definition_module.verify()
  jit.addModule(definition_module)

  let caller_context = @IR.Context::new()
  let caller_module = caller_context.addModule("cross_module_caller")
  let function_type = caller_context.getFunctionType(
    caller_context.getDoubleTy(),
    [],
  )
  let declaration = caller_module.addFunction(
    function_type, "jit_permanent_value",
  )
  let caller = caller_module.addFunction(function_type, "jit_cross_module_call")
  let entry = caller.addBasicBlock(name="entry")
  let builder = caller_context.createBuilder()
  builder.setInsertPoint(entry)
  let value = builder.createCall(declaration, [], name="value")
  let doubled = builder.createFAdd(value, value, name="doubled")
  builder.createRet(doubled) |> ignore
  caller_module.verify()
  jit.addModule(caller_module)

  let address = jit.lookup("jit_cross_module_call")
  let call : FuncRef[() -> Double] = address.unsafeToFuncRef()
  inspect(call(), content="42")
  jit.close()
}

///|
test "JIT resolves the host sin symbol" {
  let context = @IR.Context::new()
  let mod = context.addModule("host_sin")
  let function_type = context.getFunctionType(context.getDoubleTy(), [
    context.getDoubleTy(),
  ])
  let sin = mod.addFunction(function_type, "sin")
  let wrapper = mod.addFunction(function_type, "jit_call_host_sin")
  guard wrapper.getArg(0) is Some(argument) else {
    fail("expected the wrapper argument")
  }
  let entry = wrapper.addBasicBlock(name="entry")
  let builder = context.createBuilder()
  builder.setInsertPoint(entry)
  let result = builder.createCall(sin, [argument], name="result")
  builder.createRet(result) |> ignore
  mod.verify()
  let jit = @JIT.LLJIT::host()
  jit.addModule(mod)

  let address = jit.lookup("jit_call_host_sin")
  let call : FuncRef[(Double) -> Double] = address.unsafeToFuncRef()
  inspect(call(0.0), content="0")
  jit.close()
}

///|
fn create_jit_from_scoped_module() -> @JIT.LLJIT raise {
  let context = @IR.Context::new()
  let mod = context.addModule("scoped_snapshot")
  define_double_constant(context, mod, "jit_scoped_snapshot", 17.0)
  mod.verify()
  let jit = @JIT.LLJIT::host()
  jit.addModule(mod)
  jit
}

///|
test "JIT snapshot outlives its source context" {
  let jit = create_jit_from_scoped_module()
  let address = jit.lookup("jit_scoped_snapshot")
  let call : FuncRef[() -> Double] = address.unsafeToFuncRef()
  inspect(call(), content="17")
  jit.close()
}

///|
test "JIT snapshot is isolated from later source mutation" {
  let context = @IR.Context::new()
  let mod = context.addModule("mutable_source")
  define_double_constant(context, mod, "jit_snapshot_original", 9.0)
  mod.verify()
  let jit = @JIT.LLJIT::host()
  jit.addModule(mod)

  define_double_constant(context, mod, "jit_added_after_snapshot", 99.0)
  mod.verify()
  let absent = try {
    jit.lookup("jit_added_after_snapshot") |> ignore
    false
  } catch {
    @JIT.LookupFailed(_) => true
    _ => false
  }
  inspect(absent, content="true")
  let address = jit.lookup("jit_snapshot_original")
  let call : FuncRef[() -> Double] = address.unsafeToFuncRef()
  inspect(call(), content="9")
  jit.close()
}

///|
test "JIT applies layout only to its private snapshot" {
  let context = @IR.Context::new()
  let mod = context.addModule("default_layout")
  define_double_constant(context, mod, "jit_default_layout", 5.0)
  mod.verify()
  inspect(mod.getDataLayoutStr(), content="")
  let jit = @JIT.LLJIT::host()
  jit.addModule(mod)
  inspect(mod.getDataLayoutStr(), content="")
  let address = jit.lookup("jit_default_layout")
  let call : FuncRef[() -> Double] = address.unsafeToFuncRef()
  inspect(call(), content="5")

  let incompatible_context = @IR.Context::new()
  let incompatible = incompatible_context.addModule("incompatible_layout")
  incompatible.setDataLayout("e-p:32:32")
  define_double_constant(
    incompatible_context, incompatible, "jit_incompatible_layout", 1.0,
  )
  incompatible.verify()
  let rejected = try {
    jit.addModule(incompatible)
    false
  } catch {
    @JIT.SubmissionFailed(message) => message.length() > 0
    _ => false
  }
  inspect(rejected, content="true")
  inspect(incompatible.getDataLayoutStr(), content="e-p:32:32")
  jit.close()
}

///|
test "JIT resource tracker removes all grouped submissions" {
  let jit = @JIT.LLJIT::host()
  let permanent_context = @IR.Context::new()
  let permanent = permanent_context.addModule("tracker_permanent")
  define_double_constant(
    permanent_context, permanent, "jit_tracker_permanent", 30.0,
  )
  permanent.verify()
  jit.addModule(permanent)

  let tracker = jit.createResourceTracker()
  let first_context = @IR.Context::new()
  let first = first_context.addModule("tracker_first")
  define_double_constant(first_context, first, "jit_tracker_first", 1.0)
  first.verify()
  jit.addModule(first, tracker~)
  let second_context = @IR.Context::new()
  let second = second_context.addModule("tracker_second")
  define_double_constant(second_context, second, "jit_tracker_second", 2.0)
  second.verify()
  jit.addModule(second, tracker~)

  let first_address = jit.lookup("jit_tracker_first")
  let first_call : FuncRef[() -> Double] = first_address.unsafeToFuncRef()
  let second_address = jit.lookup("jit_tracker_second")
  let second_call : FuncRef[() -> Double] = second_address.unsafeToFuncRef()
  inspect(first_call() + second_call(), content="3")
  tracker.remove()

  let first_removed = try {
    jit.lookup("jit_tracker_first") |> ignore
    false
  } catch {
    @JIT.LookupFailed(_) => true
    _ => false
  }
  let second_removed = try {
    jit.lookup("jit_tracker_second") |> ignore
    false
  } catch {
    @JIT.LookupFailed(_) => true
    _ => false
  }
  inspect(first_removed && second_removed, content="true")
  let permanent_address = jit.lookup("jit_tracker_permanent")
  let permanent_call : FuncRef[() -> Double] = permanent_address.unsafeToFuncRef()
  inspect(permanent_call(), content="30")
  jit.close()
}
