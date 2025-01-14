fn main {
  let context = @llvm.Context::create()
  let i32_ty = context.i32_type()
  let val42 = i32_ty.const_int(42, false)
  val42.set_name("forty-two")
  val42.dump()
  println("")
  println(val42.to_string())
}
