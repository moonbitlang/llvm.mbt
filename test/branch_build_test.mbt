///|
typealias @llvm.SwitchInstError

///|
test "Simple Branch Test" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()

  // 创建测试函数 - 使用函数参数避免常量传播
  let i1_ty = ctx.getInt1Ty()
  let i32_ty = ctx.getInt32Ty()
  let void_ty = ctx.getVoidTy()
  let fty = ctx.getFunctionType(void_ty, [i1_ty, i32_ty])
  let fval = mod.addFunction(fty, "branch_test")
  let entry_bb = fval.appendBasicBlock(name="entry")
  let true_bb = fval.appendBasicBlock(name="true_branch")
  let false_bb = fval.appendBasicBlock(name="false_branch")
  let switch_bb = fval.appendBasicBlock(name="switch_branch")
  let case1_bb = fval.appendBasicBlock(name="case1")
  let case2_bb = fval.appendBasicBlock(name="case2")
  let default_bb = fval.appendBasicBlock(name="default")
  let end_bb = fval.appendBasicBlock(name="end")
  let cond = fval.getArg(0).unwrap() // i1 条件参数
  let switch_val = fval.getArg(1).unwrap() // i32 switch 值参数

  // 测试条件分支
  builder.setInsertPoint(entry_bb)
  let cond_br = builder.createCondBr(cond, true_bb, false_bb)

  // true 分支 - 测试无条件分支
  builder.setInsertPoint(true_bb)
  let unconditional_br = builder.createBr(switch_bb)

  // false 分支
  builder.setInsertPoint(false_bb)
  let _ = builder.createBr(switch_bb)

  // switch 分支 - 测试 switch 指令
  builder.setInsertPoint(switch_bb)
  let switch_inst = builder.createSwitch(switch_val, default_bb)
  let case1_val = ctx.getConstInt32(1)
  let case2_val = ctx.getConstInt32(2)
  switch_inst.addCase(case1_val, case1_bb)
  switch_inst.addCase(case2_val, case2_bb)

  // case1 分支
  builder.setInsertPoint(case1_bb)
  let _ = builder.createBr(end_bb)

  // case2 分支
  builder.setInsertPoint(case2_bb)
  let _ = builder.createBr(end_bb)

  // default 分支
  builder.setInsertPoint(default_bb)
  let _ = builder.createBr(end_bb)

  // end 分支
  builder.setInsertPoint(end_bb)
  let _ = builder.createRetVoid()

  // 验证生成的指令
  inspect(
    cond_br,
    content="  br i1 %0, label %true_branch, label %false_branch",
  )
  inspect(unconditional_br, content="  br label %switch_branch")

  // 检查 switch 指令的输出格式
  let expected_switch =
    #|  switch i32 %1, label %default [
    #|    i32 1, label %case1
    #|    i32 2, label %case2
    #|  ]
  inspect(switch_inst, content=expected_switch)

  // 错误测试 - createCondBr 条件必须是 i1 类型
  assert_true(
    (try? builder.createCondBr(switch_val, true_bb, false_bb))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // 错误测试 - createSwitch 值必须是整数类型
  let f32_val = ctx.getConstFloat(1.0)
  assert_true(
    (try? builder.createSwitch(f32_val, default_bb))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // 错误测试 - switch addCase 值必须是整数类型
  let another_switch = builder.createSwitch(switch_val, default_bb)
  assert_true(
    (try? another_switch.addCase(f32_val, case1_bb))
    is Err(SwitchInstError::InValidSwitchCaseValue(_)),
  )
}

///|
test "PHI Test" {
  let ctx = Context::new()
  let mod = ctx.addModule("demo")
  let builder = ctx.createBuilder()

  // 创建测试函数 - 模拟带 PHI 节点的控制流
  let i1_ty = ctx.getInt1Ty()
  let i32_ty = ctx.getInt32Ty()
  let fty = ctx.getFunctionType(i32_ty, [i1_ty, i32_ty, i32_ty])
  let fval = mod.addFunction(fty, "phi_test")
  let entry_bb = fval.appendBasicBlock(name="entry")
  let true_bb = fval.appendBasicBlock(name="true_branch")
  let false_bb = fval.appendBasicBlock(name="false_branch")
  let switch_bb = fval.appendBasicBlock(name="switch_test")
  let case1_bb = fval.appendBasicBlock(name="case1")
  let case2_bb = fval.appendBasicBlock(name="case2")
  let default_bb = fval.appendBasicBlock(name="default")
  let merge_bb = fval.appendBasicBlock(name="merge")
  let cond = fval.getArg(0).unwrap() // i1 条件参数
  let true_val = fval.getArg(1).unwrap() // i32 true 分支的值
  let false_val = fval.getArg(2).unwrap() // i32 false 分支的值

  // entry: 条件分支
  builder.setInsertPoint(entry_bb)
  let _ = builder.createCondBr(cond, true_bb, false_bb)

  // true 分支: 对输入值进行运算，避免常量传播
  builder.setInsertPoint(true_bb)
  let true_result = builder.createAdd(
    true_val,
    ctx.getConstInt32(10),
    name="true_add",
  )
  let _ = builder.createBr(switch_bb)

  // false 分支: 对输入值进行运算，避免常量传播
  builder.setInsertPoint(false_bb)
  let false_result = builder.createMul(
    false_val,
    ctx.getConstInt32(2),
    name="false_mul",
  )
  let _ = builder.createBr(switch_bb)

  // switch 分支: 使用 PHI 来合并两个分支的值，然后基于结果选择路径
  builder.setInsertPoint(switch_bb)
  // 创建 PHI 节点来合并来自两个分支的值
  let switch_phi = builder.createPHI(i32_ty, name="switch_phi")
  switch_phi.addIncoming(true_result, true_bb)
  switch_phi.addIncoming(false_result, false_bb)
  // 使用 PHI 的结果作为 switch 条件
  let switch_cond = builder.createAnd(
    switch_phi,
    ctx.getConstInt32(3),
    name="switch_cond",
  )
  let switch_inst = builder.createSwitch(switch_cond, default_bb)
  let case0_val = ctx.getConstInt32(0)
  let case1_val = ctx.getConstInt32(1)
  switch_inst.addCase(case0_val, case1_bb)
  switch_inst.addCase(case1_val, case2_bb)

  // case1: 返回一个计算值
  builder.setInsertPoint(case1_bb)
  let case1_result = builder.createSub(
    switch_phi,
    ctx.getConstInt32(5),
    name="case1_sub",
  )
  let _ = builder.createBr(merge_bb)

  // case2: 返回另一个计算值
  builder.setInsertPoint(case2_bb)
  let case2_result = builder.createAdd(
    switch_phi,
    ctx.getConstInt32(20),
    name="case2_add",
  )
  let _ = builder.createBr(merge_bb)

  // default: 返回默认值
  builder.setInsertPoint(default_bb)
  let default_result = builder.createMul(
    switch_phi,
    ctx.getConstInt32(3),
    name="default_mul",
  )
  let _ = builder.createBr(merge_bb)

  // merge 分支: 使用 PHI 节点合并来自不同分支的值
  builder.setInsertPoint(merge_bb)
  let phi = builder.createPHI(i32_ty, name="result")
  phi.addIncoming(case1_result, case1_bb)
  phi.addIncoming(case2_result, case2_bb)
  phi.addIncoming(default_result, default_bb)

  // 测试 select 指令 - 作为简单条件选择的替代
  let select_result = builder.createSelect(
    cond,
    true_val,
    false_val,
    name="select_result",
  )

  // 最终结果合并 PHI 和 select 的结果
  let final_result = builder.createAdd(phi, select_result, name="final")

  // 返回最终结果
  let _ = builder.createRet(final_result)

  // 验证生成的指令
  inspect(
    phi,
    content="  %result = phi i32 [ %case1_sub, %case1 ], [ %case2_add, %case2 ], [ %default_mul, %default ]",
  )
  inspect(
    select_result,
    content="  %select_result = select i1 %0, i32 %1, i32 %2",
  )

  // 检查完整的函数生成
  let expect =
    #|define i32 @phi_test(i1 %0, i32 %1, i32 %2) {
    #|entry:
    #|  br i1 %0, label %true_branch, label %false_branch
    #|
    #|true_branch:                                      ; preds = %entry
    #|  %true_add = add i32 %1, 10
    #|  br label %switch_test
    #|
    #|false_branch:                                     ; preds = %entry
    #|  %false_mul = mul i32 %2, 2
    #|  br label %switch_test
    #|
    #|switch_test:                                      ; preds = %false_branch, %true_branch
    #|  %switch_phi = phi i32 [ %true_add, %true_branch ], [ %false_mul, %false_branch ]
    #|  %switch_cond = and i32 %switch_phi, 3
    #|  switch i32 %switch_cond, label %default [
    #|    i32 0, label %case1
    #|    i32 1, label %case2
    #|  ]
    #|
    #|case1:                                            ; preds = %switch_test
    #|  %case1_sub = sub i32 %switch_phi, 5
    #|  br label %merge
    #|
    #|case2:                                            ; preds = %switch_test
    #|  %case2_add = add i32 %switch_phi, 20
    #|  br label %merge
    #|
    #|default:                                          ; preds = %switch_test
    #|  %default_mul = mul i32 %switch_phi, 3
    #|  br label %merge
    #|
    #|merge:                                            ; preds = %default, %case2, %case1
    #|  %result = phi i32 [ %case1_sub, %case1 ], [ %case2_add, %case2 ], [ %default_mul, %default ]
    #|  %select_result = select i1 %0, i32 %1, i32 %2
    #|  %final = add i32 %result, %select_result
    #|  ret i32 %final
    #|}
    #|
  inspect(fval, content=expect)

  // 错误测试 - createSelect 条件必须是 i1 类型
  assert_true(
    (try? builder.createSelect(true_val, true_val, false_val))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // 错误测试 - createCondBr 条件类型错误
  assert_true(
    (try? builder.createCondBr(true_val, true_bb, false_bb))
    is Err(BuilderError::ValueTypeError(_)),
  )

  // 错误测试 - createSwitch 值类型错误
  let f64_val = ctx.getConstDouble(1.0)
  assert_true(
    (try? builder.createSwitch(f64_val, default_bb))
    is Err(BuilderError::ValueTypeError(_)),
  )
}
