///|
/// Demonstrates the stale native handle described by Q-09.
///
/// LLVM constants are uniqued. Replacing `one` with `two` makes `a` equivalent
/// to the already existing constant `b`, so LLVM replaces native uses of `a`
/// with `b` and deletes `a`. The MoonBit wrapper `a` still contains the deleted
/// native pointer. `getType` therefore performs a UAF access even if the freed
/// memory happens to retain enough data for that shallow read to succeed.
///
/// TODO: This is actually problematic. But we have to stop because Codex's cybersecurity checkers are complaining about this test. We should fix the underlying issue and re-enable this test.
test "RAUW can invalidate a uniqued Constant wrapper" {
  let ctx = Context::new()
  let one = ctx.getConstInt32(1)
  let two = ctx.getConstInt32(2)
  let a = ctx.getConstStruct([one])
  let b = ctx.getConstStruct([two])

  inspect(a, content="{ i32 } { i32 1 }")
  inspect(b, content="{ i32 } { i32 2 }")

  one.replaceAllUsesWith(two)

  inspect(b, content="{ i32 } { i32 2 }")
  inspect(a.getType(), content="{ i32 }")

  // If `a` tracked RAUW, it would now denote the same constant as `b`. Instead,
  // this reads the deleted native object and may fail, crash, or show stale data.
  //
  // NOTE: Actually it's problematic.
  inspect(a, content="{ i32 } { i32 1 }")
}
