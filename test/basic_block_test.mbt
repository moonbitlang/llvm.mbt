

test "Basic Block Test" {
  let context = @llvm.Context::create();
  let lmodule = context.create_module("my_module");
  let void_ty = context.void_type();
  let fn_type = void_ty.fn_type([]);
  let func = lmodule.add_function("do_something", fn_type);

  let bb = context.append_basic_block(func, name="entry");

  // get_parent
  assert_eq!(bb.get_parent().unwrap(), func);
  bb.remove_from_function!();
  assert_true!(bb.get_parent() is None);

  // get_previous_basic_block
  let bb1 = context.append_basic_block(func, name="entry");
  assert_true!(bb1.get_previous_basic_block() is None);
  let bb2 = context.append_basic_block(func, name="next");
  assert_true!(bb2.get_previous_basic_block().unwrap() == bb1);

  // get_next_basic_block
  assert_true!(bb1.get_next_basic_block().unwrap() == bb2);

  // move_before
  bb2.move_before!(bb1);
  assert_true!(bb1.get_next_basic_block() is None);
  assert_true!(bb2.get_next_basic_block().unwrap() == bb1);

  // move_after
  bb2.move_after!(bb1);
  assert_true!(bb1.get_next_basic_block().unwrap() == bb2);
  assert_true!(bb2.get_next_basic_block() is None);

  let builder = context.create_builder();
  builder.position_at_end(bb1);

  // TODO: eliminate redundant code when compiler bug fixed.
  let _ = builder.build_return!((None:@llvm.IntValue?));

  // get_first_instruction
  let opcode = bb1.get_first_instruction().unwrap().get_opcode();
  assert_eq!(opcode, @llvm.InstructionOpcode::Return);

  // get_last_instruction
  let opcode = bb1.get_last_instruction().unwrap().get_opcode();
  assert_eq!(opcode, @llvm.InstructionOpcode::Return);

  // get_terminator
  let opcode = bb1.get_terminator().unwrap().get_opcode();
  assert_eq!(opcode, @llvm.InstructionOpcode::Return);

  // get_context
  assert_true!(context == bb1.get_context());

  // get_name
  inspect!(bb1.get_name(), content="entry");

  // set_name
  bb1.set_name("renamed_entry");
  inspect!(bb1.get_name(), content="renamed_entry");

  lmodule.drop()
  context.drop()
}
