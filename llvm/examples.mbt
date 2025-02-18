// TODO: enable it when finish all
// fn simple_ret_42() -> String {
//   let context = @llvm.Context::create()
//   let @unsafe.llvm_module = context.create_module("demo")
//   let builder = context.create_builder()
//   let i32_ty = context.i32_type()
//   let fn_ty = i32_ty.fn_type([])
//   let func = @unsafe.llvm_module.add_function("main", fn_ty)
//   let bb = context.append_basic_block(func, "entry")
//   builder.position_at_end(bb)
//   let ret_val = i32_ty.const_int(42)
//   builder.build_return(val=Some(ret_val))
//   @unsafe.llvm_module.to_string()
// }
