

// fn main {
//   let context = @llvm.Context::create()
//   let i32_ty = context.i32_type()
//   let val42 = i32_ty.const_int(42, false)
//   val42.set_name("forty-two")
//   val42.dump()
//   println("")
//   println(val42.to_string())
// }

fn main {
  let context = @llvm.Context::create()
  let llvm_module = context.create_module("demo")
  let builder = context.create_builder()
  let i32_ty = context.i32_type()
  let fn_ty = i32_ty.fn_type([i32_ty.as_type_ref(), i32_ty.as_type_ref()], false)
  let func = llvm_module.add_function("main", fn_ty)
  let bb = context.append_basic_block(func, "entry")
  builder.position_at_end(bb)
  let ret_val = i32_ty.const_int(42, false)
  let _ = builder.build_return?(val=Some(ret_val))
  let s = llvm_module.to_string()
  println(s)
  // llvm_module.dump()
}
