

test "Basic Block Test" {
  let context = @llvm.Context::create();
  let lmodule = context.create_module("my_module");
  let void_ty = context.void_type();
  let fn_type = void_ty.fn_type([]);
  let func = lmodule.add_function("do_something", fn_type);

  let bb = context.append_basic_block(func, "entry");
  // let builder = context.create_builder();

  // get_parent
  assert_eq!(bb.get_parent().unwrap(), func);
  bb.remove_from_function!();
  assert_true!(bb.get_parent() is None);

  // get_previous_basic_block
  let bb1 = context.append_basic_block(func, "entry");
  assert_true!(bb1.get_previous_basic_block() is None);
  let bb2 = context.append_basic_block(func, "next");
  assert_true!(bb2.get_previous_basic_block().unwrap() == bb1);

  // get_next_basic_block
  assert_true!(bb1.get_next_basic_block().unwrap() == bb2);

  lmodule.drop()
  context.drop()
}
