///|
test "Cast Test" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()

  // 测试整数转换
  let i64_ty = ctx.getInt64Ty()
  let i32_ty = ctx.getInt32Ty()
  let i16_ty = ctx.getInt16Ty()
  let i8_ty = ctx.getInt8Ty()

  // 测试浮点转换  
  let f64_ty = ctx.getDoubleTy()
  let f32_ty = ctx.getFloatTy()

  // 测试指针转换
  let ptr_ty = ctx.getPtrTy()

  // 创建测试函数
  let fty = ctx.getFunctionType(ctx.getVoidTy(), [i64_ty, f64_ty, ptr_ty])
  let fval = mod.addFunction(fty, "cast_test")
  let bb = fval.addBasicBlock(name="entry")
  let i64_arg = fval.getArg(0).unwrap()
  let f64_arg = fval.getArg(1).unwrap()
  let ptr_arg = fval.getArg(2).unwrap()
  builder.setInsertPoint(bb)

  // 测试整数转换
  let trunc_i32 = builder.createTrunc(i64_arg, i32_ty, name="trunc_i32")
  let trunc_i16 = builder.createTrunc(trunc_i32, i16_ty, name="trunc_i16")
  let trunc_i8 = builder.createTrunc(trunc_i16, i8_ty, name="trunc_i8")
  let zext_i16 = builder.createZExt(trunc_i8, i16_ty, name="zext_i16")
  let zext_i32 = builder.createZExt(zext_i16, i32_ty, name="zext_i32")
  let _ = builder.createZExt(zext_i32, i64_ty, name="zext_i64")
  let sext_i16 = builder.createSExt(trunc_i8, i16_ty, name="sext_i16")
  let sext_i32 = builder.createSExt(sext_i16, i32_ty, name="sext_i32")
  let _ = builder.createSExt(sext_i32, i64_ty, name="sext_i64")

  // 测试浮点转换
  let fptrunc_f32 = builder.createFPTrunc(f64_arg, f32_ty, name="fptrunc_f32")
  let fpext_f64 = builder.createFPExt(fptrunc_f32, f64_ty, name="fpext_f64")

  // 测试浮点整数转换
  let fptosi_i32 = builder.createFPToSI(fpext_f64, i32_ty, name="fptosi_i32")
  let fptoui_i32 = builder.createFPToUI(fpext_f64, i32_ty, name="fptoui_i32")
  let sitofp_f32 = builder.createSIToFP(fptosi_i32, f32_ty, name="sitofp_f32")
  let _ = builder.createUIToFP(fptoui_i32, f32_ty, name="uitofp_f32")

  // 测试位转换
  let bitcast_i32 = builder.createBitCast(
    sitofp_f32,
    i32_ty,
    name="bitcast_i32",
  )
  let _ = builder.createBitCast(bitcast_i32, f32_ty, name="bitcast_f32")

  // 测试指针转换
  let ptrtoint_i64 = builder.createPtrToInt(
    ptr_arg,
    i64_ty,
    name="ptrtoint_i64",
  )
  let _ = builder.createIntToPtr(ptrtoint_i64, ptr_ty, name="inttoptr_ptr")

  // 创建返回指令
  let _ = builder.createRetVoid()

  // 检查生成的IR
  let expect =
    #|define void @cast_test(i64 %0, double %1, ptr %2) {
    #|entry:
    #|  %trunc_i32 = trunc i64 %0 to i32
    #|  %trunc_i16 = trunc i32 %trunc_i32 to i16
    #|  %trunc_i8 = trunc i16 %trunc_i16 to i8
    #|  %zext_i16 = zext i8 %trunc_i8 to i16
    #|  %zext_i32 = zext i16 %zext_i16 to i32
    #|  %zext_i64 = zext i32 %zext_i32 to i64
    #|  %sext_i16 = sext i8 %trunc_i8 to i16
    #|  %sext_i32 = sext i16 %sext_i16 to i32
    #|  %sext_i64 = sext i32 %sext_i32 to i64
    #|  %fptrunc_f32 = fptrunc double %1 to float
    #|  %fpext_f64 = fpext float %fptrunc_f32 to double
    #|  %fptosi_i32 = fptosi double %fpext_f64 to i32
    #|  %fptoui_i32 = fptoui double %fpext_f64 to i32
    #|  %sitofp_f32 = sitofp i32 %fptosi_i32 to float
    #|  %uitofp_f32 = uitofp i32 %fptoui_i32 to float
    #|  %bitcast_i32 = bitcast float %sitofp_f32 to i32
    #|  %bitcast_f32 = bitcast i32 %bitcast_i32 to float
    #|  %ptrtoint_i64 = ptrtoint ptr %2 to i64
    #|  %inttoptr_ptr = inttoptr i64 %ptrtoint_i64 to ptr
    #|  ret void
    #|}
    #|
  inspect(fval, content=expect)

  // 错误测试 - createTrunc 类型不匹配
  assert_true(
    (try? builder.createTrunc(f64_arg, i32_ty))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // 错误测试 - createZExt 类型不匹配
  let f32_val = ctx.getConstFloat(1.0)
  assert_true(
    (try? builder.createZExt(f32_val, i32_ty))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // 错误测试 - createSExt 类型不匹配
  assert_true(
    (try? builder.createSExt(f64_arg, i32_ty))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // 错误测试 - createFPTrunc 类型不匹配
  assert_true(
    (try? builder.createFPTrunc(i64_arg, f32_ty))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // 错误测试 - createFPExt 类型不匹配
  let i32_val = ctx.getConstInt32(1)
  assert_true(
    (try? builder.createFPExt(i32_val, f64_ty))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // 错误测试 - createFPToSI 类型不匹配
  assert_true(
    (try? builder.createFPToSI(i64_arg, i32_ty))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // 错误测试 - createFPToUI 类型不匹配
  assert_true(
    (try? builder.createFPToUI(i32_val, i32_ty))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // 错误测试 - createSIToFP 类型不匹配
  assert_true(
    (try? builder.createSIToFP(f64_arg, f32_ty))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // 错误测试 - createUIToFP 类型不匹配
  assert_true(
    (try? builder.createUIToFP(f32_val, f32_ty))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // 错误测试 - createIntToPtr 类型不匹配
  assert_true(
    (try? builder.createIntToPtr(f64_arg, ptr_ty))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // 错误测试 - createPtrToInt 类型不匹配
  assert_true(
    (try? builder.createPtrToInt(i64_arg, i32_ty))
    is Err(BuilderError::ValueTypeError(_)),
  )
}
