///|
using @IR {
  type BasicBlock,
  type FloatPredicate,
  type InValidOperation,
  type IndexOutOfBounds,
  type InstructionEnum,
  type IntPredicate,
  type TailCallKind,
  trait Instruction,
}

///|
fn int_predicate_name(predicate : IntPredicate) -> String {
  match predicate {
    EQ => "EQ"
    NE => "NE"
    SGT => "SGT"
    SGE => "SGE"
    SLT => "SLT"
    SLE => "SLE"
    UGT => "UGT"
    UGE => "UGE"
    ULT => "ULT"
    ULE => "ULE"
  }
}

///|
fn float_predicate_name(predicate : FloatPredicate) -> String {
  match predicate {
    OEQ => "OEQ"
    OGT => "OGT"
    OGE => "OGE"
    OLT => "OLT"
    OLE => "OLE"
    ONE => "ONE"
    ORD => "ORD"
    UEQ => "UEQ"
    UGT => "UGT"
    UGE => "UGE"
    ULT => "ULT"
    ULE => "ULE"
    UNE => "UNE"
    UNO => "UNO"
    True => "True"
    False => "False"
  }
}

///|
fn tail_call_kind_name(kind : TailCallKind) -> String {
  match kind {
    None => "None"
    Tail => "Tail"
    MustTail => "MustTail"
    NoTail => "NoTail"
  }
}

///|
fn successor_name(block : BasicBlock?) -> String? raise {
  match block {
    Some(block) => block.getValueName()
    None => None
  }
}

///|
fn[T] assert_instruction_error(
  action : () -> T raise,
  matches : (Error) -> Bool,
) -> Unit raise {
  try action() catch {
    error => assert_true(matches(error))
  } noraise {
    _ => fail("expected instruction error")
  }
}

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

///|
test "Alloca and GEP properties round trip" {
  let context = Context::new()
  let mod = context.addModule("instruction_memory_properties")
  let builder = context.createBuilder()
  let i32_type = context.getInt32Ty()
  let function_type = context.getFunctionType(context.getVoidTy(), [])
  let function = mod.addFunction(function_type, "memory_properties")
  let block = function.addBasicBlock(name="entry")
  builder.setInsertPoint(block)
  let slot = builder.createAlloca(i32_type, name="slot")
  let gep = builder.createGEP(
    slot,
    i32_type,
    [context.getConstInt32(0)],
    name="element",
  )
  assert_eq(slot.getAllocatedType().to_string(), "i32")
  assert_eq(gep.getSourceElementType().to_string(), "i32")
  assert_false(gep.isInBounds())
  gep.setInBounds()
  assert_true(gep.isInBounds())
  gep.removeInBounds()
  assert_false(gep.isInBounds())
  builder.createRetVoid() |> ignore
}

///|
test "integer comparison predicates round trip" {
  let context = Context::new()
  let mod = context.addModule("integer_predicates")
  let builder = context.createBuilder()
  let i32_type = context.getInt32Ty()
  let function_type = context.getFunctionType(context.getVoidTy(), [
    i32_type, i32_type,
  ])
  let function = mod.addFunction(function_type, "compare")
  guard function.getArg(0) is Some(lhs) else { fail("expected lhs") }
  guard function.getArg(1) is Some(rhs) else { fail("expected rhs") }
  let block = function.addBasicBlock(name="entry")
  builder.setInsertPoint(block)
  let predicates : Array[IntPredicate] = [
    EQ,
    NE,
    SGT,
    SGE,
    SLT,
    SLE,
    UGT,
    UGE,
    ULT,
    ULE,
  ]
  for index, predicate in predicates {
    let comparison = builder.createICmp(
      predicate,
      lhs,
      rhs,
      name="icmp_\{index}",
    )
    guard comparison.asValueEnum() is ICmpInst(instruction) else {
      fail("expected ICmpInst")
    }
    assert_eq(
      int_predicate_name(instruction.getPredicate()),
      int_predicate_name(predicate),
    )
  }
  builder.createRetVoid() |> ignore
}

///|
test "floating comparison predicates round trip" {
  let context = Context::new()
  let mod = context.addModule("floating_predicates")
  let builder = context.createBuilder()
  let float_type = context.getFloatTy()
  let function_type = context.getFunctionType(context.getVoidTy(), [
    float_type, float_type,
  ])
  let function = mod.addFunction(function_type, "compare")
  guard function.getArg(0) is Some(lhs) else { fail("expected lhs") }
  guard function.getArg(1) is Some(rhs) else { fail("expected rhs") }
  let block = function.addBasicBlock(name="entry")
  builder.setInsertPoint(block)
  let predicates : Array[FloatPredicate] = [
    OEQ,
    OGT,
    OGE,
    OLT,
    OLE,
    ONE,
    ORD,
    UEQ,
    UGT,
    UGE,
    ULT,
    ULE,
    UNE,
    UNO,
    True,
    False,
  ]
  for index, predicate in predicates {
    let comparison = builder.createFCmp(
      predicate,
      lhs,
      rhs,
      name="fcmp_\{index}",
    )
    guard comparison.asValueEnum() is FCmpInst(instruction) else {
      fail("expected FCmpInst")
    }
    assert_eq(
      float_predicate_name(instruction.getPredicate()),
      float_predicate_name(predicate),
    )
  }
  builder.createRetVoid() |> ignore
}

///|
test "Branch successors conditions and errors are bounded" {
  let context = Context::new()
  let mod = context.addModule("branch_properties")
  let builder = context.createBuilder()
  let i1_type = context.getInt1Ty()
  let function_type = context.getFunctionType(context.getVoidTy(), [
    i1_type, i1_type,
  ])
  let function = mod.addFunction(function_type, "branch")
  guard function.getArg(0) is Some(first_condition) else {
    fail("expected first condition")
  }
  guard function.getArg(1) is Some(second_condition) else {
    fail("expected second condition")
  }
  let entry = function.addBasicBlock(name="entry")
  let first = function.addBasicBlock(name="first")
  let second = function.addBasicBlock(name="second")
  let replacement = function.addBasicBlock(name="replacement")
  builder.setInsertPoint(entry)
  let conditional = builder.createCondBr(first_condition, first, second)
  assert_true(conditional.isConditional())
  assert_eq(conditional.getNumSuccessors(), 2)
  assert_true(conditional.getSuccessor(-1) is None)
  assert_eq(successor_name(conditional.getSuccessor(0)), Some("first"))
  assert_eq(successor_name(conditional.getSuccessor(1)), Some("second"))
  assert_true(conditional.getSuccessor(2) is None)
  conditional.setCondition(second_condition)
  conditional.setSuccessor(0, replacement)
  assert_eq(successor_name(conditional.getSuccessor(0)), Some("replacement"))
  assert_instruction_error(() => conditional.setSuccessor(2, replacement), error => {
    error is IndexOutOfBounds::IndexOutOfBounds(_)
  })
  builder.setInsertPoint(first)
  let unconditional = builder.createBr(second)
  assert_false(unconditional.isConditional())
  assert_eq(unconditional.getNumSuccessors(), 1)
  assert_instruction_error(() => unconditional.setCondition(first_condition), error => {
    error is InValidOperation::InValidOperation(_)
  })
  builder.setInsertPoint(second)
  builder.createRetVoid() |> ignore
  builder.setInsertPoint(replacement)
  builder.createRetVoid() |> ignore
  inspect(conditional, content="  br i1 %1, label %replacement, label %second")
}

///|
test "Switch successors preserve default and case order" {
  let context = Context::new()
  let mod = context.addModule("switch_properties")
  let builder = context.createBuilder()
  let i32_type = context.getInt32Ty()
  let function_type = context.getFunctionType(context.getVoidTy(), [i32_type])
  let function = mod.addFunction(function_type, "switch")
  guard function.getArg(0) is Some(discriminant) else {
    fail("expected discriminant")
  }
  let entry = function.addBasicBlock(name="entry")
  let default_block = function.addBasicBlock(name="default")
  let first_case = function.addBasicBlock(name="first_case")
  let second_case = function.addBasicBlock(name="second_case")
  let replacement = function.addBasicBlock(name="replacement")
  builder.setInsertPoint(entry)
  let switch = builder.createSwitch(discriminant, default_block)
  switch.addCase(context.getConstInt32(1), first_case)
  switch.addCase(context.getConstInt32(2), second_case)
  assert_eq(switch.getNumSuccessors(), 3)
  assert_true(switch.getSuccessor(-1) is None)
  assert_eq(successor_name(switch.getSuccessor(0)), Some("default"))
  assert_eq(successor_name(switch.getSuccessor(1)), Some("first_case"))
  assert_eq(successor_name(switch.getSuccessor(2)), Some("second_case"))
  assert_true(switch.getSuccessor(3) is None)
  switch.setSuccessor(1, replacement)
  assert_eq(successor_name(switch.getSuccessor(1)), Some("replacement"))
  assert_instruction_error(() => switch.setSuccessor(3, replacement), error => {
    error is IndexOutOfBounds::IndexOutOfBounds(_)
  })
  for block in [default_block, first_case, second_case, replacement] {
    builder.setInsertPoint(block)
    builder.createRetVoid() |> ignore
  }
}

///|
test "Call tail kinds and argument count round trip" {
  let context = Context::new()
  let mod = context.addModule("call_properties")
  let builder = context.createBuilder()
  let i32_type = context.getInt32Ty()
  let callee_type = context.getFunctionType(i32_type, [i32_type, i32_type])
  let callee = mod.addFunction(callee_type, "callee")
  let caller_type = context.getFunctionType(i32_type, [i32_type, i32_type])
  let caller = mod.addFunction(caller_type, "caller")
  guard caller.getArg(0) is Some(first) else { fail("expected first argument") }
  guard caller.getArg(1) is Some(second) else {
    fail("expected second argument")
  }
  let block = caller.addBasicBlock(name="entry")
  builder.setInsertPoint(block)
  let call = builder.createCall(callee, [first, second], name="result")
  assert_eq(call.getNumArgOperands(), 2)
  let kinds : Array[TailCallKind] = [None, Tail, MustTail, NoTail]
  for kind in kinds {
    call.setTailCallKind(kind)
    assert_eq(
      tail_call_kind_name(call.getTailCallKind()),
      tail_call_kind_name(kind),
    )
  }
  call.setTailCall()
  assert_true(call.isTailCall())
  call.removeTailCall()
  assert_false(call.isTailCall())
  builder.createRet(call) |> ignore
}
