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

///|
fn make_host_target_machine() -> (LLVMTargetMachineRef, String) raise {
  assert_false(llvm_initialize_native_target())
  assert_false(llvm_initialize_native_asm_printer())
  let triple = llvm_get_default_target_triple()
  let (target, message, failed) = llvm_get_target_from_triple(triple)
  assert_false(failed)
  assert_true(message.is_empty())
  let options = llvm_create_target_machine_options()
  let machine = llvm_create_target_machine_with_options(target, triple, options)
  llvm_dispose_target_machine_options(options)
  assert_false(machine.is_null())
  (machine, triple)
}

///|
test "target machine configures module target and data layout" {
  let (machine, triple) = make_host_target_machine()
  let context = llvm_context_create()
  let mod_ref = llvm_module_create_with_name_in_context("configured", context)
  assert_true(llvm_get_target(mod_ref).is_empty())
  assert_true(llvm_get_data_layout_str(mod_ref).is_empty())
  llvm_set_target(mod_ref, triple)
  llvm_target_machine_set_module_data_layout(machine, mod_ref)
  assert_eq(llvm_get_target(mod_ref), triple)
  assert_false(llvm_get_data_layout_str(mod_ref).is_empty())
  llvm_dispose_module(mod_ref)
  llvm_context_dispose(context)
  llvm_dispose_target_machine(machine)
}

///|
test "module verification reports valid and invalid modules" {
  let context = llvm_context_create()
  let valid = llvm_module_create_with_name_in_context("valid", context)
  let (valid_failed, valid_message) = llvm_verify_module(valid)
  assert_false(valid_failed)
  assert_true(valid_message.is_empty())
  let invalid = llvm_module_create_with_name_in_context("invalid", context)
  let function_type = llvm_function_type(
    llvm_int32_type_in_context(context),
    [],
    false,
  )
  let function = llvm_add_function(invalid, "missing_terminator", function_type)
  ignore(llvm_append_basic_block_in_context(context, function, "entry"))
  let (invalid_failed, invalid_message) = llvm_verify_module(invalid)
  assert_true(invalid_failed)
  assert_false(invalid_message.is_empty())
  llvm_dispose_module(valid)
  llvm_dispose_module(invalid)
  llvm_context_dispose(context)
}

///|
extern "C" fn __target_machine_test_temp_path() -> Bytes = "llvm_mbt_target_machine_test_temp_path"

///|
#borrow(path)
extern "C" fn __target_machine_test_remove_file(path : Utf8Z) -> Bool = "llvm_mbt_target_machine_test_remove_file"

///|
fn target_machine_test_remove_file(path : String) -> Bool raise CStringError {
  __target_machine_test_remove_file(Utf8Z::from_string(path))
}

///|
test "target machine emits an object and reports an unwritable path" {
  let (machine, triple) = make_host_target_machine()
  let context = llvm_context_create()
  let mod_ref = llvm_module_create_with_name_in_context("object", context)
  llvm_set_target(mod_ref, triple)
  llvm_target_machine_set_module_data_layout(machine, mod_ref)
  let object_path = __target_machine_test_temp_path() |> @utf8.decode
  assert_false(object_path.is_empty())
  let (emit_failed, emit_message) = llvm_target_machine_emit_object_to_file(
    machine, mod_ref, object_path,
  )
  assert_false(emit_failed)
  assert_true(emit_message.is_empty())
  assert_true(target_machine_test_remove_file(object_path))
  let (bad_path_failed, bad_path_message) = llvm_target_machine_emit_object_to_file(
    machine, mod_ref, "/dev/null/llvm-mbt-object.o",
  )
  assert_true(bad_path_failed)
  assert_false(bad_path_message.is_empty())
  llvm_dispose_module(mod_ref)
  llvm_context_dispose(context)
  llvm_dispose_target_machine(machine)
}
