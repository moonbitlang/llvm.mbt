
// a simple llvm
// moudle name: demo
// func name: main
// body: ret 42

fn main {
  let context = @llvm.Context::create()
  let llvm_module = context.create_module("demo")
  let builder = context.create_builder()

  let i32_ty = context.i32_type()

  let fn_ty = i32_ty.fn_type([], false)

  let func = llvm_module.add_func("main", fn_ty)
  let bb = context.append_basic_block(func, "entry")

  builder.position_at_end(bb)
  let ret_val = i32_ty.const_int(42, false)
  builder.build_ret(ret_val)

  llvm_module.print_to_stdout()
}
