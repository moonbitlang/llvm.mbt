///|
test "native target initialization is repeatable" {
  assert_false(llvm_initialize_native_target())
  assert_false(llvm_initialize_native_asm_printer())
  assert_false(llvm_initialize_native_target())
  assert_false(llvm_initialize_native_asm_printer())
}

///|
test "host target information constructs a TargetMachine" {
  assert_false(llvm_initialize_native_target())
  assert_false(llvm_initialize_native_asm_printer())
  let triple = llvm_get_default_target_triple()
  let cpu = llvm_get_host_cpu_name()
  let features = llvm_get_host_cpu_features()
  assert_false(triple.is_empty())
  assert_false(cpu.is_empty())
  let (target, message, failed) = llvm_get_target_from_triple(triple)
  assert_false(failed)
  assert_true(message.is_empty())
  assert_false(target.is_null())
  assert_false(llvm_get_target_name(target).is_empty())
  assert_true(llvm_target_has_target_machine(target))
  assert_true(llvm_target_has_asm_backend(target))
  let options = llvm_create_target_machine_options()
  assert_false(options.is_null())
  llvm_target_machine_options_set_cpu(options, cpu)
  llvm_target_machine_options_set_features(options, features)
  let machine = llvm_create_target_machine_with_options(target, triple, options)
  llvm_dispose_target_machine_options(options)
  assert_false(machine.is_null())
  llvm_dispose_target_machine(machine)
}

///|
test "invalid target triple returns a diagnostic" {
  let (target, message, failed) = llvm_get_target_from_triple(
    "not-a-real-target-triple",
  )
  assert_true(failed)
  assert_true(target.is_null())
  assert_false(message.is_empty())
}
