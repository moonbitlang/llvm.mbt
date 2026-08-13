///|
fn make_lifecycle_module(
  context : @IR.Context,
  name : String,
  symbol : String,
  value : Double,
) -> @IR.Module raise {
  let mod = context.addModule(name)
  let function_type = context.getFunctionType(context.getDoubleTy(), [])
  let function = mod.addFunction(function_type, symbol)
  let entry = function.addBasicBlock(name="entry")
  let builder = context.createBuilder()
  builder.setInsertPoint(entry)
  builder.createRet(context.getConstDouble(value)) |> ignore
  mod.verify()
  mod
}

///|
test "JIT aliases share close state across public operations" {
  let jit = @JIT.LLJIT::host()
  let other = jit
  let context = @IR.Context::new()
  let mod = make_lifecycle_module(
    context, "closed_operations", "jit_closed_operations", 1.0,
  )
  let tracker = jit.createResourceTracker()
  jit.addModule(mod, tracker~)
  let address = jit.lookup("jit_closed_operations")
  jit.close()

  let close_closed = try {
    other.close()
    false
  } catch {
    @JIT.Closed => true
    _ => false
  }
  let lookup_closed = try {
    other.lookup("jit_closed_operations") |> ignore
    false
  } catch {
    @JIT.Closed => true
    _ => false
  }
  let add_closed = try {
    other.addModule(mod)
    false
  } catch {
    @JIT.Closed => true
    _ => false
  }
  let tracker_closed = try {
    other.createResourceTracker() |> ignore
    false
  } catch {
    @JIT.Closed => true
    _ => false
  }
  let conversion_closed = try {
    let _function : FuncRef[() -> Double] = address.unsafeToFuncRef()
    false
  } catch {
    @JIT.Closed => true
    _ => false
  }
  let remove_closed = try {
    tracker.remove()
    false
  } catch {
    @JIT.Closed => true
    _ => false
  }
  inspect(
    close_closed &&
    lookup_closed &&
    add_closed &&
    tracker_closed &&
    conversion_closed &&
    remove_closed,
    content="true",
  )
}

///|
test "JIT address retains an otherwise scoped session" {
  fn create_address() -> @JIT.JITAddress raise {
    let jit = @JIT.LLJIT::host()
    let context = @IR.Context::new()
    let mod = make_lifecycle_module(
      context, "address_owner", "jit_address_owner", 23.0,
    )
    jit.addModule(mod)
    jit.lookup("jit_address_owner")
  }

  let address = create_address()
  let call : FuncRef[() -> Double] = address.unsafeToFuncRef()
  let result = call()
  // Use the address after the native call so the optimizer cannot end its
  // owner lifetime before the call returns.
  let _still_live : FuncRef[() -> Double] = address.unsafeToFuncRef()
  inspect(result, content="23")
}

///|
test "dropping a tracker wrapper does not remove its code" {
  fn create_jit() -> @JIT.LLJIT raise {
    let jit = @JIT.LLJIT::host()
    let tracker = jit.createResourceTracker()
    let context = @IR.Context::new()
    let mod = make_lifecycle_module(
      context, "dropped_tracker", "jit_dropped_tracker", 29.0,
    )
    jit.addModule(mod, tracker~)
    jit
  }

  let jit = create_jit()
  let address = jit.lookup("jit_dropped_tracker")
  let call : FuncRef[() -> Double] = address.unsafeToFuncRef()
  inspect(call(), content="29")
  jit.close()
}

///|
test "JIT rejects removed and foreign tracker operations repeatedly" {
  let first = @JIT.LLJIT::host()
  let second = @JIT.LLJIT::host()
  let first_tracker = first.createResourceTracker()
  let foreign_tracker = second.createResourceTracker()
  let context = @IR.Context::new()
  let mod = make_lifecycle_module(
    context, "tracker_lifecycle", "jit_tracker_lifecycle", 2.0,
  )
  first.addModule(mod, tracker=first_tracker)
  first_tracker.remove()

  let repeat_remove = try {
    first_tracker.remove()
    false
  } catch {
    @JIT.ResourceTrackerRemoved => true
    _ => false
  }
  let add_removed = try {
    first.addModule(mod, tracker=first_tracker)
    false
  } catch {
    @JIT.ResourceTrackerRemoved => true
    _ => false
  }
  let add_foreign = try {
    first.addModule(mod, tracker=foreign_tracker)
    false
  } catch {
    @JIT.ResourceTrackerOwnerMismatch => true
    _ => false
  }
  inspect(repeat_remove && add_removed && add_foreign, content="true")
  first.close()
  second.close()
}

///|
test "JIT supports repeated session execution and teardown" {
  for index = 0; index < 12; index = index + 1 {
    let jit = @JIT.LLJIT::host()
    let tracker = jit.createResourceTracker()
    let context = @IR.Context::new()
    let symbol = "jit_repeated_session_\{index}"
    let mod = make_lifecycle_module(
      context,
      "repeated_session_\{index}",
      symbol,
      Double::from_int(index),
    )
    jit.addModule(mod, tracker~)
    let address = jit.lookup(symbol)
    let call : FuncRef[() -> Double] = address.unsafeToFuncRef()
    assert_eq(call(), Double::from_int(index))
    tracker.remove()
    jit.close()
  }
}
