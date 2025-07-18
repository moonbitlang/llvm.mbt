//
//fn[T] ptr_to_func_ptr(ptr: @unsafe.LLVMOrcExecutorAddress) -> FuncRef[T] = "%identity"
//test {
//  let ctx = @IR.Context::new()
//  let mod = ctx.addModule("demo")
//  let builder = ctx.createBuilder()
//
//  let i32_ty = ctx.getInt32Ty()
//  let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
//  let fval = mod.addFunction(fty, "add")
//
//  let arg0 = fval.getArg(0).unwrap()
//  let arg1 = fval.getArg(1).unwrap()
//
//  let entry = fval.addBasicBlock(name="entry")
//  builder.setInsertPoint(entry)
//
//  let sum = builder.createAdd(arg0, arg1, name = "sum")
//  let _ = builder.createRet(sum)
//
//  //mod.dump()
//  let jit = @unsafe.llvm_orc_create_lljit()
//  let tsctx = @unsafe.llvm_orc_create_new_thread_safe_context()
//  let tsm = @unsafe.llvm_orc_create_new_thread_safe_module(mod.inner(), tsctx)
//
//  let main_jd = @unsafe.llvm_orc_lljit_get_main_jit_dylib(jit)
//
//  let _ = @unsafe.llvm_orc_lljit_add_llvm_ir_module(jit, main_jd, tsm)
//
//  @unsafe.llvm_orc_dispose_thread_safe_context(tsctx)
//  let addr = @unsafe.llvm_orc_lljit_lookup(jit, "add")
//  let func = match addr {
//    Some(a) => {
//      let fptr : FuncRef[(Int, Int) -> Int] = ptr_to_func_ptr(a)
//      fptr
//    }
//    None => {
//      println("Function 'add' not found in JIT.")
//      panic()
//    }
//  }
//
//  //let func : (Int, Int) -> Int = func
//  let _ = func(5, 7)
//}
