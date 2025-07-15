///|
typealias @llvm.Context

///|
typealias @llvm.BuilderError

///|
test "Binary Int Add Test" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()
  let i32_ty = ctx.getInt32Ty()
  let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
  let fval = mod.addFunction(fty, "i32add")
  let bb = fval.addBasicBlock(name="entry")
  let arg0 = fval.getArg(0).unwrap()
  let arg1 = fval.getArg(1).unwrap()
  builder.setInsertPoint(bb)
  let add = builder.createAdd(arg0, arg1)
  let nsw_add = builder.createNSWAdd(add, add)
  let nuw_add = builder.createNUWAdd(nsw_add, nsw_add)
  let _ = builder.createRet(nuw_add)
  let expect =
    #|define i32 @i32add(i32 %0, i32 %1) {
    #|entry:
    #|  %2 = add i32 %0, %1
    #|  %3 = add nsw i32 %2, %2
    #|  %4 = add nuw i32 %3, %3
    #|  ret i32 %4
    #|}
    #|
  inspect(fval, content=expect)
  let f32_one = ctx.getConstFloat(1.0)
  assert_true(
    (try? builder.createAdd(arg0, f32_one))
    is Err(BuilderError::ValueTypeError(_)),
  )
  let i64_one = ctx.getConstInt64(1)
  assert_true(
    (try? builder.createAdd(arg0, i64_one))
    is Err(BuilderError::BitwidthError(_)),
  )
}

///|
test "Binary Int Sub Test" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()
  let i32_ty = ctx.getInt32Ty()
  let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
  let fval = mod.addFunction(fty, "i32sub")
  let bb = fval.addBasicBlock(name="entry")
  let arg0 = fval.getArg(0).unwrap()
  let arg1 = fval.getArg(1).unwrap()
  builder.setInsertPoint(bb)
  let sub = builder.createSub(arg0, arg1)
  let nsw_sub = builder.createNSWSub(sub, arg1)
  let nuw_sub = builder.createNUWSub(nsw_sub, arg0)
  let _ = builder.createRet(nuw_sub)
  let expect =
    #|define i32 @i32sub(i32 %0, i32 %1) {
    #|entry:
    #|  %2 = sub i32 %0, %1
    #|  %3 = sub nsw i32 %2, %1
    #|  %4 = sub nuw i32 %3, %0
    #|  ret i32 %4
    #|}
    #|
  inspect(fval, content=expect)
  // 错误测试：类型不匹配
  let f32_one = ctx.getConstFloat(1.0)
  assert_true(
    (try? builder.createSub(arg0, f32_one))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：位宽不匹配
  let i64_one = ctx.getConstInt64(1)
  assert_true(
    (try? builder.createSub(arg0, i64_one))
    is Err(BuilderError::BitwidthError(_)),
  )
  // 错误测试：NSW Sub 类型不匹配
  assert_true(
    (try? builder.createNSWSub(f32_one, arg0))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：NUW Sub 位宽不匹配
  assert_true(
    (try? builder.createNUWSub(arg0, i64_one))
    is Err(BuilderError::BitwidthError(_)),
  )
}

///|
test "Binary Int Mul Test" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()
  let i32_ty = ctx.getInt32Ty()
  let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
  let fval = mod.addFunction(fty, "i32mul")
  let bb = fval.addBasicBlock(name="entry")
  let arg0 = fval.getArg(0).unwrap()
  let arg1 = fval.getArg(1).unwrap()
  builder.setInsertPoint(bb)
  let mul = builder.createMul(arg0, arg1)
  let nsw_mul = builder.createNSWMul(mul, arg1)
  let nuw_mul = builder.createNUWMul(nsw_mul, arg0)
  let _ = builder.createRet(nuw_mul)
  let expect =
    #|define i32 @i32mul(i32 %0, i32 %1) {
    #|entry:
    #|  %2 = mul i32 %0, %1
    #|  %3 = mul nsw i32 %2, %1
    #|  %4 = mul nuw i32 %3, %0
    #|  ret i32 %4
    #|}
    #|
  inspect(fval, content=expect)
  // 错误测试：类型不匹配
  let f64_one = ctx.getConstDouble(1.0)
  assert_true(
    (try? builder.createMul(arg0, f64_one))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：位宽不匹配
  let i16_one = ctx.getConstInt16(1)
  assert_true(
    (try? builder.createMul(arg0, i16_one))
    is Err(BuilderError::BitwidthError(_)),
  )
  // 错误测试：NSW Mul 类型不匹配
  assert_true(
    (try? builder.createNSWMul(f64_one, arg0))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：NUW Mul 位宽不匹配
  assert_true(
    (try? builder.createNUWMul(arg0, i16_one))
    is Err(BuilderError::BitwidthError(_)),
  )
}

///|
test "Binary Int Div Test" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()
  let i32_ty = ctx.getInt32Ty()
  let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
  let fval = mod.addFunction(fty, "i32div")
  let bb = fval.addBasicBlock(name="entry")
  let arg0 = fval.getArg(0).unwrap()
  let arg1 = fval.getArg(1).unwrap()
  builder.setInsertPoint(bb)
  // 测试 SDiv 和 UDiv
  let sdiv = builder.createSDiv(arg0, arg1)
  let udiv = builder.createUDiv(sdiv, arg1)
  // 测试 Exact 版本
  let exact_sdiv = builder.createExactSDiv(udiv, arg0)
  let exact_udiv = builder.createExactUDiv(exact_sdiv, arg1)
  let _ = builder.createRet(exact_udiv)
  let expect =
    #|define i32 @i32div(i32 %0, i32 %1) {
    #|entry:
    #|  %2 = sdiv i32 %0, %1
    #|  %3 = udiv i32 %2, %1
    #|  %4 = sdiv exact i32 %3, %0
    #|  %5 = udiv exact i32 %4, %1
    #|  ret i32 %5
    #|}
    #|
  inspect(fval, content=expect)
  // 错误测试：SDiv 类型不匹配
  let f32_one = ctx.getConstFloat(1.0)
  assert_true(
    (try? builder.createSDiv(arg0, f32_one))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：UDiv 位宽不匹配
  let i64_one = ctx.getConstInt64(1)
  assert_true(
    (try? builder.createUDiv(arg0, i64_one))
    is Err(BuilderError::BitwidthError(_)),
  )
  // 错误测试：ExactSDiv 类型不匹配
  assert_true(
    (try? builder.createExactSDiv(f32_one, arg0))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：ExactUDiv 位宽不匹配
  let i8_one = ctx.getConstInt8(1)
  assert_true(
    (try? builder.createExactUDiv(arg0, i8_one))
    is Err(BuilderError::BitwidthError(_)),
  )
  // 错误测试：左操作数类型不匹配
  assert_true(
    (try? builder.createSDiv(f32_one, arg0))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：右操作数类型不匹配
  assert_true(
    (try? builder.createUDiv(arg0, f32_one))
    is Err(BuilderError::ValueTypeError(_)),
  )
}

///|
test "Binary Int Rem Test" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()
  let i32_ty = ctx.getInt32Ty()
  let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
  let fval = mod.addFunction(fty, "i32rem")
  let bb = fval.addBasicBlock(name="entry")
  let arg0 = fval.getArg(0).unwrap()
  let arg1 = fval.getArg(1).unwrap()
  builder.setInsertPoint(bb)
  // 测试 SRem 和 URem
  let srem = builder.createSRem(arg0, arg1)
  let urem = builder.createURem(srem, arg1)
  let _ = builder.createRet(urem)
  let expect =
    #|define i32 @i32rem(i32 %0, i32 %1) {
    #|entry:
    #|  %2 = srem i32 %0, %1
    #|  %3 = urem i32 %2, %1
    #|  ret i32 %3
    #|}
    #|
  inspect(fval, content=expect)
  // 错误测试：SRem 类型不匹配
  let f32_one = ctx.getConstFloat(1.0)
  assert_true(
    (try? builder.createSRem(arg0, f32_one))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：URem 位宽不匹配
  let i64_one = ctx.getConstInt64(1)
  assert_true(
    (try? builder.createURem(arg0, i64_one))
    is Err(BuilderError::BitwidthError(_)),
  )
  // 错误测试：左操作数类型不匹配
  assert_true(
    (try? builder.createSRem(f32_one, arg0))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：右操作数类型不匹配
  assert_true(
    (try? builder.createURem(arg0, f32_one))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：URem 位宽不匹配（更多情况）
  let i16_one = ctx.getConstInt16(1)
  assert_true(
    (try? builder.createURem(arg0, i16_one))
    is Err(BuilderError::BitwidthError(_)),
  )
}

///|
test "Binary Float Test" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()
  let f32_ty = ctx.getFloatTy()
  let fty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty])
  let fval = mod.addFunction(fty, "f32ops")
  let bb = fval.addBasicBlock(name="entry")
  let arg0 = fval.getArg(0).unwrap()
  let arg1 = fval.getArg(1).unwrap()
  builder.setInsertPoint(bb)
  // 测试所有浮点二进制运算
  let fadd = builder.createFAdd(arg0, arg1)
  let fsub = builder.createFSub(fadd, arg1)
  let fmul = builder.createFMul(fsub, arg0)
  let fdiv = builder.createFDiv(fmul, arg1)
  let frem = builder.createFRem(fdiv, arg0)
  let _ = builder.createRet(frem)
  let expect =
    #|define float @f32ops(float %0, float %1) {
    #|entry:
    #|  %2 = fadd float %0, %1
    #|  %3 = fsub float %2, %1
    #|  %4 = fmul float %3, %0
    #|  %5 = fdiv float %4, %1
    #|  %6 = frem float %5, %0
    #|  ret float %6
    #|}
    #|
  inspect(fval, content=expect)
  // 错误测试：FAdd 类型不匹配
  let i32_one = ctx.getConstInt32(1)
  assert_true(
    (try? builder.createFAdd(arg0, i32_one))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：FSub 位宽不匹配
  let f64_one = ctx.getConstDouble(1.0)
  assert_true(
    (try? builder.createFSub(arg0, f64_one))
    is Err(BuilderError::BitwidthError(_)),
  )
  // 错误测试：FMul 类型不匹配
  assert_true(
    (try? builder.createFMul(i32_one, arg0))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：FDiv 位宽不匹配
  assert_true(
    (try? builder.createFDiv(arg0, f64_one))
    is Err(BuilderError::BitwidthError(_)),
  )
  // 错误测试：FRem 类型不匹配
  assert_true(
    (try? builder.createFRem(arg0, i32_one))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：左操作数类型不匹配
  assert_true(
    (try? builder.createFAdd(i32_one, arg0))
    is Err(BuilderError::ValueTypeError(_)),
  )
}

///|
test "Integer Compare Test" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()
  let i32_ty = ctx.getInt32Ty()
  let i1_ty = ctx.getInt1Ty()
  let fty = ctx.getFunctionType(i1_ty, [i32_ty, i32_ty])
  let fval = mod.addFunction(fty, "i32cmp")
  let bb = fval.addBasicBlock(name="entry")
  let arg0 = fval.getArg(0).unwrap()
  let arg1 = fval.getArg(1).unwrap()
  builder.setInsertPoint(bb)
  // 测试各种整数比较谓词
  let eq_cmp = builder.createICmp(EQ, arg0, arg1, name="eq")
  let _ = builder.createICmp(NE, arg0, arg1, name="ne")
  let _ = builder.createICmp(SGT, arg0, arg1, name="sgt")
  let _ = builder.createICmp(SGE, arg0, arg1, name="sge")
  let _ = builder.createICmp(SLT, arg0, arg1, name="slt")
  let _ = builder.createICmp(SLE, arg0, arg1, name="sle")
  let _ = builder.createICmp(UGT, arg0, arg1, name="ugt")
  let _ = builder.createICmp(UGE, arg0, arg1, name="uge")
  let _ = builder.createICmp(ULT, arg0, arg1, name="ult")
  let _ = builder.createICmp(ULE, arg0, arg1, name="ule")
  // 用一个结果来结束函数
  let _ = builder.createRet(eq_cmp)
  let expect =
    #|define i1 @i32cmp(i32 %0, i32 %1) {
    #|entry:
    #|  %eq = icmp eq i32 %0, %1
    #|  %ne = icmp ne i32 %0, %1
    #|  %sgt = icmp sgt i32 %0, %1
    #|  %sge = icmp sge i32 %0, %1
    #|  %slt = icmp slt i32 %0, %1
    #|  %sle = icmp sle i32 %0, %1
    #|  %ugt = icmp ugt i32 %0, %1
    #|  %uge = icmp uge i32 %0, %1
    #|  %ult = icmp ult i32 %0, %1
    #|  %ule = icmp ule i32 %0, %1
    #|  ret i1 %eq
    #|}
    #|
  inspect(fval, content=expect)
  // 错误测试：类型不匹配
  let f32_one = ctx.getConstFloat(1.0)
  assert_true(
    (try? builder.createICmp(EQ, arg0, f32_one))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：位宽不匹配
  let i64_one = ctx.getConstInt64(1)
  assert_true(
    (try? builder.createICmp(NE, arg0, i64_one))
    is Err(BuilderError::BitwidthError(_)),
  )
  // 错误测试：左操作数类型不匹配
  assert_true(
    (try? builder.createICmp(SGT, f32_one, arg0))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：右操作数类型不匹配
  assert_true(
    (try? builder.createICmp(SLT, arg0, f32_one))
    is Err(BuilderError::ValueTypeError(_)),
  )
}

///|
test "Float Compare Test" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()
  let f32_ty = ctx.getFloatTy()
  let i1_ty = ctx.getInt1Ty()
  let fty = ctx.getFunctionType(i1_ty, [f32_ty, f32_ty])
  let fval = mod.addFunction(fty, "f32cmp")
  let bb = fval.addBasicBlock(name="entry")
  let arg0 = fval.getArg(0).unwrap()
  let arg1 = fval.getArg(1).unwrap()
  builder.setInsertPoint(bb)
  // 测试各种浮点比较谓词
  let oeq_cmp = builder.createFCmp(OEQ, arg0, arg1, name="oeq")
  let _ = builder.createFCmp(OGT, arg0, arg1, name="ogt")
  let _ = builder.createFCmp(OGE, arg0, arg1, name="oge")
  let _ = builder.createFCmp(OLT, arg0, arg1, name="olt")
  let _ = builder.createFCmp(OLE, arg0, arg1, name="ole")
  let _ = builder.createFCmp(ONE, arg0, arg1, name="one")
  let _ = builder.createFCmp(ORD, arg0, arg1, name="ord")
  let _ = builder.createFCmp(UEQ, arg0, arg1, name="ueq")
  let _ = builder.createFCmp(UGT, arg0, arg1, name="ugt")
  let _ = builder.createFCmp(UGE, arg0, arg1, name="uge")
  let _ = builder.createFCmp(ULT, arg0, arg1, name="ult")
  let _ = builder.createFCmp(ULE, arg0, arg1, name="ule")
  let _ = builder.createFCmp(UNE, arg0, arg1, name="une")
  // 用一个结果来结束函数
  let _ = builder.createRet(oeq_cmp)
  let expect =
    #|define i1 @f32cmp(float %0, float %1) {
    #|entry:
    #|  %oeq = fcmp oeq float %0, %1
    #|  %ogt = fcmp ogt float %0, %1
    #|  %oge = fcmp oge float %0, %1
    #|  %olt = fcmp olt float %0, %1
    #|  %ole = fcmp ole float %0, %1
    #|  %one = fcmp one float %0, %1
    #|  %ord = fcmp ord float %0, %1
    #|  %ueq = fcmp ueq float %0, %1
    #|  %ugt = fcmp ugt float %0, %1
    #|  %uge = fcmp uge float %0, %1
    #|  %ult = fcmp ult float %0, %1
    #|  %ule = fcmp ule float %0, %1
    #|  %une = fcmp une float %0, %1
    #|  ret i1 %oeq
    #|}
    #|
  inspect(fval, content=expect)
  // 错误测试：类型不匹配
  let i32_one = ctx.getConstInt32(1)
  assert_true(
    (try? builder.createFCmp(OEQ, arg0, i32_one))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：位宽不匹配
  let f64_one = ctx.getConstDouble(1.0)
  assert_true(
    (try? builder.createFCmp(OGT, arg0, f64_one))
    is Err(BuilderError::BitwidthError(_)),
  )
  // 错误测试：左操作数类型不匹配
  assert_true(
    (try? builder.createFCmp(OGE, i32_one, arg0))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：右操作数类型不匹配
  assert_true(
    (try? builder.createFCmp(OLT, arg0, i32_one))
    is Err(BuilderError::ValueTypeError(_)),
  )
  // 错误测试：位宽不匹配（更多情况）
  assert_true(
    (try? builder.createFCmp(ONE, arg0, f64_one))
    is Err(BuilderError::BitwidthError(_)),
  )
}
