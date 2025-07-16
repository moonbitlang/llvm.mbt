///|
test "Build PHI" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()
  
  // 创建测试函数 - 带有if-then-else控制流
  let i1_ty = ctx.getInt1Ty()
  let i32_ty = ctx.getInt32Ty()
  let fty = ctx.getFunctionType(i32_ty, [i1_ty, i32_ty, i32_ty])
  let fval = mod.addFunction(fty, "phi_test")
  let entry_bb = fval.addBasicBlock(name="entry")
  let true_bb = fval.addBasicBlock(name="true_branch")
  let false_bb = fval.addBasicBlock(name="false_branch")
  let merge_bb = fval.addBasicBlock(name="merge")
  
  let cond = fval.getArg(0).unwrap()      // i1 条件参数
  let true_val = fval.getArg(1).unwrap()  // i32 true分支的值
  let false_val = fval.getArg(2).unwrap() // i32 false分支的值
  
  // Entry块：条件分支
  builder.setInsertPoint(entry_bb)
  let _ = builder.createCondBr(cond, true_bb, false_bb)
  
  // True分支：计算一个值
  builder.setInsertPoint(true_bb)
  let true_result = builder.createAdd(true_val, ctx.getConstInt32(10), name="true_add")
  let _ = builder.createBr(merge_bb)
  
  // False分支：计算另一个值
  builder.setInsertPoint(false_bb)
  let false_result = builder.createMul(false_val, ctx.getConstInt32(2), name="false_mul")
  let _ = builder.createBr(merge_bb)
  
  // Merge块：使用PHI节点合并来自两个分支的值
  builder.setInsertPoint(merge_bb)
  let phi = builder.createPHI(i32_ty, name="result_phi")
  
  // 测试addIncoming方法
  phi.addIncoming(true_result, true_bb)
  phi.addIncoming(false_result, false_bb)
  
  // 测试countIncoming方法
  let incoming_count = phi.countIncoming()
  assert_eq(incoming_count, 2)
  
  // 测试getIncomingBlock方法
  let first_block = phi.getIncomingBlock(0)
  let second_block = phi.getIncomingBlock(1)
  assert_true(first_block is Some(_))
  assert_true(second_block is Some(_))
  
  // 测试越界访问
  let invalid_block = phi.getIncomingBlock(5)
  assert_true(invalid_block is None)
  let negative_block = phi.getIncomingBlock(-1)
  assert_true(negative_block is None)
  
  // 测试Value trait - 获取类型信息
  let phi_type = phi.getType()
  assert_eq(phi_type.tryAsIntType().unwrap().getBitWidth(), 32)
  
  // 返回PHI节点的结果
  let _ = builder.createRet(phi)
  
  // 验证生成的IR
  let expect = 
    #|define i32 @phi_test(i1 %0, i32 %1, i32 %2) {
    #|entry:
    #|  br i1 %0, label %true_branch, label %false_branch
    #|
    #|true_branch:                                      ; preds = %entry
    #|  %true_add = add i32 %1, 10
    #|  br label %merge
    #|
    #|false_branch:                                     ; preds = %entry
    #|  %false_mul = mul i32 %2, 2
    #|  br label %merge
    #|
    #|merge:                                            ; preds = %false_branch, %true_branch
    #|  %result_phi = phi i32 [ %true_add, %true_branch ], [ %false_mul, %false_branch ]
    #|  ret i32 %result_phi
    #|}
    #|
  inspect(fval, content=expect)
  inspect(phi, content="  %result_phi = phi i32 [ %true_add, %true_branch ], [ %false_mul, %false_branch ]")
  
  // 测试复杂的PHI节点（三个分支）
  let complex_fty = ctx.getFunctionType(i32_ty, [i32_ty])
  let complex_fval = mod.addFunction(complex_fty, "complex_phi")
  let c_entry = complex_fval.addBasicBlock(name="entry")
  let c_case1 = complex_fval.addBasicBlock(name="case1")
  let c_case2 = complex_fval.addBasicBlock(name="case2")
  let c_default = complex_fval.addBasicBlock(name="default")
  let c_merge = complex_fval.addBasicBlock(name="merge")
  
  let switch_val = complex_fval.getArg(0).unwrap()
  
  // Entry: switch语句
  builder.setInsertPoint(c_entry)
  let switch_inst = builder.createSwitch(switch_val, c_default)
  switch_inst.addCase(ctx.getConstInt32(1), c_case1)
  switch_inst.addCase(ctx.getConstInt32(2), c_case2)
  
  // Case1
  builder.setInsertPoint(c_case1)
  let case1_val = builder.createAdd(switch_val, ctx.getConstInt32(100), name="case1_add")
  let _ = builder.createBr(c_merge)
  
  // Case2  
  builder.setInsertPoint(c_case2)
  let case2_val = builder.createMul(switch_val, ctx.getConstInt32(5), name="case2_mul")
  let _ = builder.createBr(c_merge)
  
  // Default
  builder.setInsertPoint(c_default)
  let default_val = builder.createSub(switch_val, ctx.getConstInt32(1), name="default_sub")
  let _ = builder.createBr(c_merge)
  
  // Merge: 三路PHI节点
  builder.setInsertPoint(c_merge)
  let complex_phi = builder.createPHI(i32_ty, name="complex_result")
  complex_phi.addIncoming(case1_val, c_case1)
  complex_phi.addIncoming(case2_val, c_case2)
  complex_phi.addIncoming(default_val, c_default)
  
  // 测试三个传入值的PHI节点
  assert_eq(complex_phi.countIncoming(), 3)
  
  // 验证所有传入块都能正确获取
  for i = 0; i < 3; i = i + 1 {
    let block = complex_phi.getIncomingBlock(i)
    assert_true(block is Some(_))
  }
  
  let _ = builder.createRet(complex_phi)
  
  let complex_expect =
    #|define i32 @complex_phi(i32 %0) {
    #|entry:
    #|  switch i32 %0, label %default [
    #|    i32 1, label %case1
    #|    i32 2, label %case2
    #|  ]
    #|
    #|case1:                                            ; preds = %entry
    #|  %case1_add = add i32 %0, 100
    #|  br label %merge
    #|
    #|case2:                                            ; preds = %entry
    #|  %case2_mul = mul i32 %0, 5
    #|  br label %merge
    #|
    #|default:                                          ; preds = %entry
    #|  %default_sub = sub i32 %0, 1
    #|  br label %merge
    #|
    #|merge:                                            ; preds = %default, %case2, %case1
    #|  %complex_result = phi i32 [ %case1_add, %case1 ], [ %case2_mul, %case2 ], [ %default_sub, %default ]
    #|  ret i32 %complex_result
    #|}
    #|
  inspect(complex_fval, content=complex_expect)
  
  // 测试空的PHI节点
  let empty_phi = builder.createPHI(i32_ty, name="empty_phi")
  assert_eq(empty_phi.countIncoming(), 0)
  assert_true(empty_phi.getIncomingBlock(0) is None)
}
