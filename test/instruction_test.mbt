///|
using @IR {type BasicBlock, type InstructionEnum, trait Instruction}

///|
fn instruction_kind_name(instruction : InstructionEnum) -> String {
  match instruction {
    AllocaInst(_) => "AllocaInst"
    LoadInst(_) => "LoadInst"
    StoreInst(_) => "StoreInst"
    CastInst(_) => "CastInst"
    UnaryInst(_) => "UnaryInst"
    BinaryInst(_) => "BinaryInst"
    ICmpInst(_) => "ICmpInst"
    FCmpInst(_) => "FCmpInst"
    GetElementPtrInst(_) => "GetElementPtrInst"
    SelectInst(_) => "SelectInst"
    ExtractValueInst(_) => "ExtractValueInst"
    InsertValueInst(_) => "InsertValueInst"
    PHINode(_) => "PHINode"
    ReturnInst(_) => "ReturnInst"
    BranchInst(_) => "BranchInst"
    SwitchInst(_) => "SwitchInst"
    CallInst(_) => "CallInst"
  }
}

///|
fn instruction_value_kind_matches(instruction : &Instruction) -> Bool {
  match instruction.asInstEnum() {
    AllocaInst(_) => Value::asValueEnum(instruction) is AllocaInst(_)
    LoadInst(_) => Value::asValueEnum(instruction) is LoadInst(_)
    StoreInst(_) => Value::asValueEnum(instruction) is StoreInst(_)
    CastInst(_) => Value::asValueEnum(instruction) is CastInst(_)
    UnaryInst(_) => Value::asValueEnum(instruction) is UnaryInst(_)
    BinaryInst(_) => Value::asValueEnum(instruction) is BinaryInst(_)
    ICmpInst(_) => Value::asValueEnum(instruction) is ICmpInst(_)
    FCmpInst(_) => Value::asValueEnum(instruction) is FCmpInst(_)
    GetElementPtrInst(_) =>
      Value::asValueEnum(instruction) is GetElementPtrInst(_)
    SelectInst(_) => Value::asValueEnum(instruction) is SelectInst(_)
    ExtractValueInst(_) =>
      Value::asValueEnum(instruction) is ExtractValueInst(_)
    InsertValueInst(_) => Value::asValueEnum(instruction) is InsertValueInst(_)
    PHINode(_) => Value::asValueEnum(instruction) is PHINode(_)
    ReturnInst(_) => Value::asValueEnum(instruction) is ReturnInst(_)
    BranchInst(_) => Value::asValueEnum(instruction) is BranchInst(_)
    SwitchInst(_) => Value::asValueEnum(instruction) is SwitchInst(_)
    CallInst(_) => Value::asValueEnum(instruction) is CallInst(_)
  }
}

///|
fn assert_instruction_sequence(
  block : BasicBlock,
  expected_kinds : Array[String],
  expected_types : Array[String],
) -> Unit raise {
  assert_eq(expected_kinds.length(), expected_types.length())
  guard block.getFirstInst() is Some(first) else {
    fail("expected first instruction")
  }
  assert_true(first.getPrevInst() is None)
  let mut current : &Instruction? = Some(first)
  for index in 0..<expected_kinds.length() {
    guard current is Some(instruction) else {
      fail("instruction sequence ended early")
    }
    assert_eq(
      instruction_kind_name(instruction.asInstEnum()),
      expected_kinds[index],
    )
    assert_eq(Value::getType(instruction).to_string(), expected_types[index])
    assert_true(instruction_value_kind_matches(instruction))
    guard instruction.getParentBasicBlock() is Some(parent) else {
      fail("expected parent basic block")
    }
    assert_eq(parent.getValueName(), block.getValueName())
    assert_false(Show::to_string(instruction).is_empty())
    current = instruction.getNextInst()
  }
  assert_true(current is None)
  guard block.getLastInst() is Some(last) else {
    fail("expected last instruction")
  }
  assert_true(last.getNextInst() is None)
  assert_eq(
    instruction_kind_name(last.asInstEnum()),
    expected_kinds[expected_kinds.length() - 1],
  )
  current = Some(last)
  for step in 0..<expected_kinds.length() {
    guard current is Some(instruction) else {
      fail("reverse instruction sequence ended early")
    }
    let index = expected_kinds.length() - step - 1
    assert_eq(
      instruction_kind_name(instruction.asInstEnum()),
      expected_kinds[index],
    )
    current = instruction.getPrevInst()
  }
  assert_true(current is None)
}

///|
test "Instruction traversal recovers every linear instruction wrapper" {
  let context = Context::new()
  let mod = context.addModule("instruction_linear")
  let builder = context.createBuilder()
  let i1_type = context.getInt1Ty()
  let i32_type = context.getInt32Ty()
  let i64_type = context.getInt64Ty()
  let float_type = context.getFloatTy()
  let struct_type = context.getStructType([i32_type, i32_type])
  let callee_type = context.getFunctionType(context.getVoidTy(), [])
  let callee = mod.addFunction(callee_type, "callee")
  let function_type = context.getFunctionType(context.getVoidTy(), [
    i1_type, i32_type, float_type, struct_type,
  ])
  let function = mod.addFunction(function_type, "linear")
  guard function.getArg(0) is Some(condition) else {
    fail("expected condition argument")
  }
  guard function.getArg(1) is Some(integer) else {
    fail("expected integer argument")
  }
  guard function.getArg(2) is Some(float) else {
    fail("expected float argument")
  }
  guard function.getArg(3) is Some(aggregate) else {
    fail("expected aggregate argument")
  }
  let block = function.addBasicBlock(name="entry")
  builder.setInsertPoint(block)
  let slot = builder.createAlloca(i32_type, name="slot")
  builder.createStore(integer, slot) |> ignore
  let loaded = builder.createLoad(i32_type, slot, name="loaded")
  builder.createZExt(loaded, i64_type, name="wide") |> ignore
  builder.createFNeg(float, name="negated") |> ignore
  let sum = builder.createAdd(integer, loaded, name="sum")
  builder.createICmp(EQ, integer, loaded, name="integer_cmp") |> ignore
  builder.createFCmp(OEQ, float, float, name="float_cmp") |> ignore
  builder.createGEP(slot, i32_type, [context.getConstInt32(0)], name="element")
  |> ignore
  builder.createSelect(condition, sum, loaded, name="chosen") |> ignore
  let inserted = builder.createInsertValue(aggregate, sum, 0, name="inserted")
  builder.createExtractValue(inserted, 1, name="extracted") |> ignore
  builder.createCall(callee, []) |> ignore
  builder.createRetVoid() |> ignore
  assert_instruction_sequence(
    block,
    [
      "AllocaInst", "StoreInst", "LoadInst", "CastInst", "UnaryInst", "BinaryInst",
      "ICmpInst", "FCmpInst", "GetElementPtrInst", "SelectInst", "InsertValueInst",
      "ExtractValueInst", "CallInst", "ReturnInst",
    ],
    [
      "ptr", "void", "i32", "i64", "float", "i32", "i1", "i1", "ptr", "i32", "{ i32, i32 }",
      "i32", "void", "void",
    ],
  )
  inspect(
    function,
    content=(
      #|define void @linear(i1 %0, i32 %1, float %2, { i32, i32 } %3) {
      #|entry:
      #|  %slot = alloca i32, align 4
      #|  store i32 %1, ptr %slot, align 4
      #|  %loaded = load i32, ptr %slot, align 4
      #|  %wide = zext i32 %loaded to i64
      #|  %negated = fneg float %2
      #|  %sum = add i32 %1, %loaded
      #|  %integer_cmp = icmp eq i32 %1, %loaded
      #|  %float_cmp = fcmp oeq float %2, %2
      #|  %element = getelementptr i32, ptr %slot, i32 0
      #|  %chosen = select i1 %0, i32 %sum, i32 %loaded
      #|  %inserted = insertvalue { i32, i32 } %3, i32 %sum, 0
      #|  %extracted = extractvalue { i32, i32 } %inserted, 1
      #|  call void @callee()
      #|  ret void
      #|}
      #|
    ),
  )
  let empty_function = mod.addFunction(callee_type, "empty_probe")
  let empty_block = empty_function.addBasicBlock(name="empty")
  assert_true(empty_block.getFirstInst() is None)
  assert_true(empty_block.getLastInst() is None)
}

///|
test "Instruction traversal recovers PHI branch and switch wrappers" {
  let context = Context::new()
  let mod = context.addModule("instruction_control_flow")
  let builder = context.createBuilder()
  let i1_type = context.getInt1Ty()
  let i32_type = context.getInt32Ty()
  let void_type = context.getVoidTy()
  let branch_type = context.getFunctionType(void_type, [i1_type])
  let branch_function = mod.addFunction(branch_type, "branch_phi")
  guard branch_function.getArg(0) is Some(condition) else {
    fail("expected branch condition")
  }
  let entry = branch_function.addBasicBlock(name="entry")
  let left = branch_function.addBasicBlock(name="left")
  let right = branch_function.addBasicBlock(name="right")
  let merge = branch_function.addBasicBlock(name="merge")
  builder.setInsertPoint(entry)
  builder.createCondBr(condition, left, right) |> ignore
  builder.setInsertPoint(left)
  builder.createBr(merge) |> ignore
  builder.setInsertPoint(right)
  builder.createBr(merge) |> ignore
  builder.setInsertPoint(merge)
  let phi = builder.createPHI(i32_type, name="choice")
  phi.addIncoming(context.getConstInt32(1), left)
  phi.addIncoming(context.getConstInt32(2), right)
  builder.createRetVoid() |> ignore
  assert_instruction_sequence(entry, ["BranchInst"], ["void"])
  assert_instruction_sequence(left, ["BranchInst"], ["void"])
  assert_instruction_sequence(right, ["BranchInst"], ["void"])
  assert_instruction_sequence(merge, ["PHINode", "ReturnInst"], ["i32", "void"])
  let switch_type = context.getFunctionType(void_type, [i32_type])
  let switch_function = mod.addFunction(switch_type, "switch_flow")
  guard switch_function.getArg(0) is Some(discriminant) else {
    fail("expected switch discriminant")
  }
  let switch_entry = switch_function.addBasicBlock(name="entry")
  let case_block = switch_function.addBasicBlock(name="case")
  let default_block = switch_function.addBasicBlock(name="default")
  builder.setInsertPoint(switch_entry)
  let switch = builder.createSwitch(discriminant, default_block)
  switch.addCase(context.getConstInt32(1), case_block)
  builder.setInsertPoint(case_block)
  builder.createRetVoid() |> ignore
  builder.setInsertPoint(default_block)
  builder.createRetVoid() |> ignore
  assert_instruction_sequence(switch_entry, ["SwitchInst"], ["void"])
  inspect(
    branch_function,
    content=(
      #|define void @branch_phi(i1 %0) {
      #|entry:
      #|  br i1 %0, label %left, label %right
      #|
      #|left:                                             ; preds = %entry
      #|  br label %merge
      #|
      #|right:                                            ; preds = %entry
      #|  br label %merge
      #|
      #|merge:                                            ; preds = %right, %left
      #|  %choice = phi i32 [ 1, %left ], [ 2, %right ]
      #|  ret void
      #|}
      #|
    ),
  )
  inspect(
    switch_function,
    content=(
      #|define void @switch_flow(i32 %0) {
      #|entry:
      #|  switch i32 %0, label %default [
      #|    i32 1, label %case
      #|  ]
      #|
      #|case:                                             ; preds = %entry
      #|  ret void
      #|
      #|default:                                          ; preds = %entry
      #|  ret void
      #|}
      #|
    ),
  )
}
