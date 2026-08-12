///|
using @IR {
  type Module,
  type TargetMachineError,
  type TargetMachine,
  type TargetMachineOptions,
  type TargetRegistry,
  type TargetTriple,
}

///|
fn make_invalid_module() -> Module raise {
  let context = Context::new()
  let mod = context.addModule("invalid_target_machine_module")
  let function_type = context.getFunctionType(context.getInt32Ty(), [])
  let function = mod.addFunction(function_type, "missing_terminator")
  ignore(function.addBasicBlock(name="entry"))
  mod
}

///|
fn configure_temporary_machine(mod : Module) -> Unit raise {
  let machine = TargetMachine::host(TargetMachineOptions::default())
  machine.configureModule(mod)
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

///|
test "configure, verify, and emit remain explicit stages" {
  let context = Context::new()
  let mod = context.addModule("explicit_emission_stages")
  let machine = TargetMachine::host(TargetMachineOptions::default())
  inspect(mod.getTargetTriple(), content="")
  inspect(mod.getDataLayoutStr(), content="")
  machine.configureModule(mod)
  assert_eq(mod.getTargetTriple(), machine.getTriple().toString())
  assert_false(mod.getDataLayoutStr().is_empty())
  mod.verify()
  let configured_triple = mod.getTargetTriple()
  let configured_layout = mod.getDataLayoutStr()
  try machine.emitObjectToFile(mod, "/dev/null/llvm-mbt-object.o") catch {
    TargetMachineError::ObjectEmissionFailed(message) =>
      assert_false(message.is_empty())
    _ => fail("unexpected emission error")
  } noraise {
    _ => fail("expected object emission failure")
  }
  assert_eq(mod.getTargetTriple(), configured_triple)
  assert_eq(mod.getDataLayoutStr(), configured_layout)
}

///|
test "configured module does not retain its target machine" {
  let context = Context::new()
  let mod = context.addModule("copied_target_configuration")
  configure_temporary_machine(mod)
  assert_false(mod.getTargetTriple().is_empty())
  assert_false(mod.getDataLayoutStr().is_empty())
  mod.verify()
}

///|
test "module verification returns a typed diagnostic" {
  let mod = make_invalid_module()
  try mod.verify() catch {
    @IR.VerificationError(message) => assert_false(message.is_empty())
  } noraise {
    _ => fail("expected VerificationError")
  }
}

///|
test "object emission distinguishes embedded NUL" {
  let context = Context::new()
  let mod = context.addModule("embedded_nul_output")
  let machine = TargetMachine::host(TargetMachineOptions::default())
  machine.configureModule(mod)
  mod.verify()
  try machine.emitObjectToFile(mod, "bad\u0000object.o") catch {
    @IR.ContainsNul => ()
    _ => fail("unexpected emission error")
  } noraise {
    _ => fail("expected ContainsNul")
  }
}
