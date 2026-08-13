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
