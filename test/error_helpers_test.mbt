///|
fn[T] assert_builder_error(
  f : () -> T raise,
  pred : (Error) -> Bool,
) -> Unit raise {
  try f() catch {
    err => assert_true(pred(err))
  } noraise {
    _ => fail("expected BuilderError")
  }
}

///|
fn[T] assert_switch_inst_error(
  f : () -> T raise,
  pred : (Error) -> Bool,
) -> Unit raise {
  try f() catch {
    err => assert_true(pred(err))
  } noraise {
    _ => fail("expected SwitchInstError")
  }
}
