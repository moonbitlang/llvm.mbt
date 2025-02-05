
fn main {
  let context = @llvm.Context::create()
  let i32_ty = context.i32_type()
  let one = i32_ty.const_int(1)

  one.set_name("one")
  println(one.get_name())
  println("here")
}
