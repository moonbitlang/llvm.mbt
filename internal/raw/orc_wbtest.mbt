///|
test "raw LLJIT create query lookup error and dispose" {
  inspect(llvm_initialize_native_target(), content="false")
  inspect(llvm_initialize_native_asm_printer(), content="false")
  let (jit, create_message, create_failed) = llvm_orc_create_lljit()
  inspect(create_failed, content="false")
  inspect(create_message, content="")
  inspect(llvm_orc_lljit_get_triple_string(jit).length() > 0, content="true")
  inspect(llvm_orc_lljit_get_data_layout_str(jit).length() > 0, content="true")
  inspect(llvm_orc_lljit_get_global_prefix(jit) >= 0, content="true")
  llvm_orc_lljit_get_main_jit_dylib(jit) |> ignore
  let (_, lookup_message, lookup_failed) = llvm_orc_lljit_lookup(
    jit, "__llvm_mbt_missing_symbol__",
  )
  inspect(lookup_failed, content="true")
  inspect(lookup_message.length() > 0, content="true")
  let (dispose_message, dispose_failed) = llvm_orc_dispose_lljit(jit)
  inspect(dispose_failed, content="false")
  inspect(dispose_message, content="")
}

///|
test "raw LLVM errors are consumed into diagnostics" {
  let error = llvm_create_string_error("raw ORC diagnostic")
  inspect(llvm_take_error_message(error), content="raw ORC diagnostic")
}

///|
test "raw LLJIT supports repeated sessions" {
  for _ in 0..<3 {
    let (jit, _, create_failed) = llvm_orc_create_lljit()
    assert_false(create_failed)
    let (_, dispose_failed) = llvm_orc_dispose_lljit(jit)
    assert_false(dispose_failed)
  }
}

///|
fn raw_empty_module_bitcode(name : String) -> Bytes raise CStringError {
  let context = llvm_context_create()
  let mod = llvm_module_create_with_name_in_context(name, context)
  let bitcode = llvm_write_bitcode_to_bytes(mod)
  llvm_dispose_module(mod)
  llvm_context_dispose(context)
  bitcode
}

///|
test "raw ThreadSafeContext and untransferred module dispose" {
  let context = llvm_orc_create_new_thread_safe_context()
  llvm_orc_dispose_thread_safe_context(context)
  let (thread_safe_module, message, failed) = llvm_orc_create_thread_safe_module_from_bitcode(
    raw_empty_module_bitcode("untransferred"),
  )
  inspect(failed, content="false")
  inspect(message, content="")
  llvm_orc_dispose_thread_safe_module(thread_safe_module)
}

///|
test "raw default and explicit resource trackers own submitted modules" {
  let (jit, _, create_failed) = llvm_orc_create_lljit()
  assert_false(create_failed)
  let (permanent, _, snapshot_failed) = llvm_orc_create_thread_safe_module_from_bitcode(
    raw_empty_module_bitcode("permanent"),
  )
  assert_false(snapshot_failed)
  let (_, permanent_failed) = llvm_orc_lljit_add_llvm_ir_module(jit, permanent)
  assert_false(permanent_failed)

  let jit_dylib = llvm_orc_lljit_get_main_jit_dylib(jit)
  let first = llvm_orc_jit_dylib_create_resource_tracker(jit_dylib)
  let second = llvm_orc_jit_dylib_create_resource_tracker(jit_dylib)
  let (temporary, _, second_snapshot_failed) = llvm_orc_create_thread_safe_module_from_bitcode(
    raw_empty_module_bitcode("temporary"),
  )
  assert_false(second_snapshot_failed)
  let (_, add_failed) = llvm_orc_lljit_add_llvm_ir_module_with_rt(
    jit, first, temporary,
  )
  assert_false(add_failed)
  llvm_orc_resource_tracker_transfer_to(first, second)
  llvm_orc_release_resource_tracker(first)
  let (remove_message, remove_failed) = llvm_orc_resource_tracker_remove(second)
  inspect(remove_failed, content="false")
  inspect(remove_message, content="")
  llvm_orc_release_resource_tracker(second)
  let (_, dispose_failed) = llvm_orc_dispose_lljit(jit)
  assert_false(dispose_failed)
}

///|
test "raw default LLJIT exposes current process symbols" {
  assert_false(llvm_initialize_native_target())
  assert_false(llvm_initialize_native_asm_printer())
  let (jit, _, create_failed) = llvm_orc_create_lljit()
  assert_false(create_failed)
  let (_, message, lookup_failed) = llvm_orc_lljit_lookup(jit, "sin")
  inspect(lookup_failed, content="false")
  inspect(message, content="")
  let (_, dispose_failed) = llvm_orc_dispose_lljit(jit)
  assert_false(dispose_failed)
}
