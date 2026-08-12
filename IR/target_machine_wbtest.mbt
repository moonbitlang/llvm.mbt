///|
#borrow(owner)
extern "C" fn target_machine_owner_test_watch(owner : TargetMachineOwner) = "llvm_mbt_ir_target_machine_owner_test_watch"

///|
fn exercise_target_machine_owner_aliases() -> Unit raise {
  let machine = TargetMachine::host(TargetMachineOptions::default())
  target_machine_owner_test_watch(machine.owner)
  let first = machine
  let second = machine
  assert_eq(first.getTriple(), second.getTriple())
  ignore(first.getCPU())
  ignore(second.getFeatures())
}

///|
test "TargetMachine aliases finalize their owner exactly once" {
  exercise_target_machine_owner_aliases()
  inspect(owner_test_take_trace(), content="4")
}

///|
test "explicit and automatic native initialization compose" {
  TargetRegistry::initializeNativeCodegen()
  let machine = TargetMachine::host(TargetMachineOptions::default())
  assert_false(machine.getTriple().toString().is_empty())
  assert_false(machine.getCPU().is_empty())
}

///|
test "generic and host constructors apply distinct defaults" {
  TargetRegistry::initializeNativeCodegen()
  let triple = TargetTriple::host()
  let target = TargetRegistry::lookupTarget(triple)
  let generic = target.createTargetMachine(
    triple,
    TargetMachineOptions::default(),
  )
  assert_eq(generic.getCPU(), "generic")
  assert_true(generic.getFeatures().is_empty())
  let explicit_options = TargetMachineOptions::new(
    cpu="generic",
    features="",
    abi="",
    optimizationLevel=Aggressive,
    relocationMode=Pic,
    codeModel=Small,
  )
  let explicit = TargetMachine::host(explicit_options)
  assert_eq(explicit.getCPU(), "generic")
  assert_true(explicit.getFeatures().is_empty())
  assert_eq(explicit.getABI(), Some(""))
}

///|
fn configure_with_watched_temporary_machine(mod : Module) -> Unit raise {
  let machine = TargetMachine::host(TargetMachineOptions::default())
  target_machine_owner_test_watch(machine.owner)
  machine.configureModule(mod)
}

///|
test "configured module outlives its TargetMachine" {
  let context = Context::new()
  let mod = context.addModule("configured_owner_independence")
  configure_with_watched_temporary_machine(mod)
  inspect(owner_test_take_trace(), content="4")
  assert_false(mod.getTargetTriple().is_empty())
  assert_false(mod.getDataLayoutStr().is_empty())
  mod.verify()
}
