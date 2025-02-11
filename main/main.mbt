
fn main {
  let context = @llvm.Context::create();
  // let lmodule = context.create_module("demo");
  let i32_ty = context.i32_type();
  let f32_ty = context.f32_type();
  let f64_ty = context.f64_type();
  let bool_ty = context.bool_type();
  let void_ty = context.void_type();
  let fty = void_ty.fn_type([i32_ty, f32_ty, f64_ty, bool_ty]);
  // fty.dump()
  println(fty)
}
