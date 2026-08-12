///|
using @IR {
  type TargetMachine,
  type TargetMachineOptions,
  type TargetRegistry,
  type TargetTriple,
}

///|
test "public target registry and host target machine APIs" {
  TargetRegistry::initializeNativeCodegen()
  let triple = TargetTriple::host()
  let same_triple = TargetTriple::new(triple.toString())
  assert_eq(triple, same_triple)
  let target = TargetRegistry::lookupTarget(triple)
  assert_false(target.getName().is_empty())
  assert_false(target.getDescription().is_empty())
  let generic = target.createTargetMachine(
    triple,
    TargetMachineOptions::default(),
  )
  assert_eq(generic.getCPU(), "generic")
  assert_true(generic.getFeatures().is_empty())
  let host = TargetMachine::host(TargetMachineOptions::default())
  assert_eq(host.getTriple(), triple)
  assert_false(host.getCPU().is_empty())
  let explicit = TargetMachine::host(
    TargetMachineOptions::new(
      cpu="generic",
      features="",
      abi="",
      optimizationLevel=@IR.Aggressive,
      relocationMode=@IR.Pic,
      codeModel=@IR.Small,
    ),
  )
  assert_eq(explicit.getCPU(), "generic")
  assert_true(explicit.getFeatures().is_empty())
  assert_eq(explicit.getABI(), Some(""))
}

///|
test "target APIs reject embedded NUL input" {
  try TargetTriple::new("bad\u0000triple") catch {
    @IR.ContainsNul => ()
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected ContainsNul")
  }
  try TargetMachineOptions::new(cpu="bad\u0000cpu") catch {
    @IR.ContainsNul => ()
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected ContainsNul")
  }
}
