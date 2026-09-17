///|
// Verifies that Module::getContext reuses the exact ContextOwner instead of
// creating a second owner for the same borrowed LLVMContextRef.
test "Module returns its original Context owner" {
  let context = Context::new()
  let mod = context.addModule("owner_identity")
  let module_context = mod.getContext()
  inspect(
    physical_equal(context.get_owner(), module_context.get_owner()),
    content="true",
  )
}

///|
// Exercises the real temporary-Context path after native finalizers are active.
test "Module retains a temporary Context owner" {
  let mod = Context::new().addModule("owner_lifetime")
  let context = mod.getContext()
  inspect(context.getInt32Ty(), content="i32")
}

///|
fn same_context_owner(left : Context, right : Context) -> Bool {
  physical_equal(left.get_owner(), right.get_owner())
}

///|
fn same_module_owner(left : Module, right : Module) -> Bool {
  physical_equal(left.get_owner(), right.get_owner())
}

///|
// Checks both direct factories and dynamic getter/iterator paths. Every true
// entry means that the derived wrapper retained the original provenance owner.
test "derived IR wrappers retain their provenance owners" {
  let context = Context::new()
  let mod = context.addModule("derived_owner_identity")
  let builder = context.createBuilder()
  let i32_type = context.getInt32Ty()
  let constant = context.getConstInt32(7)
  let function_type = context.getFunctionType(i32_type, [i32_type])
  let function = mod.addFunction(function_type, "identity")
  guard function.getArg(0) is Some(argument) else {
    fail("expected one function argument")
  }
  let block = function.addBasicBlock(name="entry")
  builder.setInsertPoint(block)
  let folded = builder.createAdd(constant, constant)
  let instruction = builder.createRet(argument)
  let global_variable = mod.addGlobalVariable(i32_type, "global")
  let global_constant = mod.addGlobalConstant(i32_type, "constant", constant)
  let data_layout = mod.getDataLayout()
  guard mod.getFunctions() is [iterated_function, ..] else {
    fail("expected one module function")
  }
  guard function.getBasicBlocks() is [iterated_block, ..] else {
    fail("expected one function basic block")
  }
  guard block.getFirstInst() is Some(iterated_instruction) else {
    fail("expected one basic-block instruction")
  }
  debug_inspect(
    [
      ("Module -> Context", same_context_owner(context, mod.getContext())),
      ("Builder -> Context", same_context_owner(context, builder.get_context())),
      (
        "Int32Type -> Context",
        same_context_owner(context, i32_type.get_context()),
      ),
      (
        "FunctionType -> Context",
        same_context_owner(context, function_type.get_context()),
      ),
      (
        "FunctionType return -> Context",
        same_context_owner(context, function_type.getReturnType().getContext()),
      ),
      (
        "Constant -> Context",
        same_context_owner(context, constant.getContext()),
      ),
      (
        "folded Constant -> Context",
        same_context_owner(context, folded.getContext()),
      ),
      (
        "Argument Type -> Context",
        same_context_owner(context, argument.getType().getContext()),
      ),
      ("Function -> Module", same_module_owner(mod, function.get_module())),
      ("Argument -> Module", same_module_owner(mod, argument.get_module())),
      ("BasicBlock -> Module", same_module_owner(mod, block.get_module())),
      ("ReturnInst -> Module", same_module_owner(mod, instruction.get_module())),
      (
        "GlobalVariable -> Module",
        same_module_owner(mod, global_variable.get_module()),
      ),
      (
        "GlobalConstant -> Module",
        same_module_owner(mod, global_constant.get_module()),
      ),
      ("DataLayout -> Module", same_module_owner(mod, data_layout.owner_module)),
      (
        "Builder insertion -> Module",
        same_module_owner(mod, builder.get_insert_module()),
      ),
      (
        "Module iterator Function -> Module",
        same_module_owner(mod, iterated_function.get_module()),
      ),
      (
        "Function iterator BasicBlock -> Module",
        same_module_owner(mod, iterated_block.get_module()),
      ),
      (
        "BasicBlock iterator Instruction -> Module",
        same_module_owner(mod, get_instruction_module(iterated_instruction)),
      ),
    ],
    content=(
      #|[
      #|  ("Module -> Context", true),
      #|  ("Builder -> Context", true),
      #|  ("Int32Type -> Context", true),
      #|  ("FunctionType -> Context", true),
      #|  ("FunctionType return -> Context", true),
      #|  ("Constant -> Context", true),
      #|  ("folded Constant -> Context", true),
      #|  ("Argument Type -> Context", true),
      #|  ("Function -> Module", true),
      #|  ("Argument -> Module", true),
      #|  ("BasicBlock -> Module", true),
      #|  ("ReturnInst -> Module", true),
      #|  ("GlobalVariable -> Module", true),
      #|  ("GlobalConstant -> Module", true),
      #|  ("DataLayout -> Module", true),
      #|  ("Builder insertion -> Module", true),
      #|  ("Module iterator Function -> Module", true),
      #|  ("Function iterator BasicBlock -> Module", true),
      #|  ("BasicBlock iterator Instruction -> Module", true),
      #|]
    ),
  )
}

///|
priv struct TemporaryOwnerViews {
  function : Function
  instruction : ReturnInst
  value_type : Int32Type
  constant : ConstantInt
  data_layout : DataLayout
}

///|
fn make_temporary_owner_views() -> TemporaryOwnerViews raise {
  let context = Context::new()
  let mod = context.addModule("temporary_owner_views")
  let builder = context.createBuilder()
  let value_type = context.getInt32Ty()
  let constant = context.getConstInt32(7)
  let function_type = context.getFunctionType(value_type, [value_type])
  let function = mod.addFunction(function_type, "identity")
  guard function.getArg(0) is Some(argument) else {
    fail("expected one function argument")
  }
  let block = function.addBasicBlock(name="entry")
  builder.setInsertPoint(block)
  let instruction = builder.createRet(argument)
  let data_layout = mod.getDataLayout()
  { function, instruction, value_type, constant, data_layout, }
}

///|
// The returned views are the only references that keep their native roots alive.
test "derived views remain usable after root bindings leave scope" {
  let views = make_temporary_owner_views()
  debug_inspect(
    views.function.getName(),
    content=(
      #|Some("identity")
    ),
  )
  inspect(
    views.instruction,
    content=(
      #|  ret i32 %0
    ),
  )
  inspect(
    views.value_type,
    content=(
      #|i32
    ),
  )
  inspect(
    views.constant,
    content=(
      #|i32 7
    ),
  )
  inspect(
    views.data_layout.getTypeStoreSize(views.value_type),
    content=(
      #|4
    ),
  )
}

///|
#borrow(context, mod, builder)
extern "C" fn owner_test_watch(
  context : ContextOwner,
  mod : ModuleOwner,
  builder : BuilderOwner,
) = "llvm_mbt_ir_owner_test_watch"

///|
extern "C" fn owner_test_take_trace() -> UInt64 = "llvm_mbt_ir_owner_test_take_trace"

///|
fn exercise_owner_finalizers() -> Unit raise {
  let context = Context::new()
  let mod = context.addModule("owner_finalizer_trace")
  let builder = context.createBuilder()
  owner_test_watch(context.get_owner(), mod.get_owner(), builder.owner)
  let value_type = context.getInt32Ty()
  let constant = context.getConstInt32(7)
  let function_type = context.getFunctionType(value_type, [value_type])
  let function = mod.addFunction(function_type, "identity")
  guard function.getArg(0) is Some(argument) else {
    fail("expected one function argument")
  }
  let block = function.addBasicBlock(name="entry")
  let data_layout = mod.getDataLayout()
  builder.setInsertPoint(block)
  let instruction = builder.createRet(argument)
  inspect(
    instruction,
    content=(
      #|  ret i32 %0
    ),
  )
  inspect(data_layout.getTypeStoreSize(value_type), content="4")
  inspect(
    constant,
    content=(
      #|i32 7
    ),
  )
}

///|
// The watched objects come from the real public construction path. The trace
// records events after native disposal, so 321 means Builder, then Module, then
// Context, exactly once each despite all aliases created above.
test "native owners finalize exactly once in child-first order" {
  exercise_owner_finalizers()
  inspect(owner_test_take_trace(), content="321")
}

///|
extern "C" fn owner_test_peek_trace() -> UInt64 = "llvm_mbt_ir_owner_test_peek_trace"

///|
fn scoped_address_constant(kind : Int) -> &Value raise {
  let ctx = Context::new()
  let mod = ctx.addModule("constant_owner_trace")
  let builder = ctx.createBuilder()
  owner_test_watch(ctx.get_owner(), mod.get_owner(), builder.owner)
  let root = mod.addGlobalVariable(ctx.getInt32Ty(), "root")
  let array = ctx.getConstArray(ctx.getPtrTy(), [root])
  if kind == 0 {
    return ctx.getConstStruct([array])
  }
  if kind == 1 {
    return ctx.getConstVector([root])
  }
  let function = mod.addFunction(ctx.getFunctionType(ctx.getVoidTy(), []), "f")
  builder.setInsertPoint(function.addBasicBlock())
  let result = match kind {
    2 => builder.createPtrToInt(root, ctx.getInt64Ty())
    3 => builder.createExtractValue(ctx.getConstStruct([array]), 0)
    4 => builder.createInsertValue(ctx.getUndef(array.getType()), root, 0)
    5 => builder.createSelect(ctx.getConstTrue(), array, array)
    6 =>
      builder.createExtractValue(
        ctx.getConstStruct([root, ctx.getConstInt32(7)]),
        1,
      )
    _ => builder.createExtractValue(array, 0)
  }
  builder.createRetVoid() |> ignore
  mod.verify()
  result
}

///|
fn exercise_constant_dependency(kind : Int) -> Unit raise {
  let value = scoped_address_constant(kind)
  // The builder is gone, but the constant must keep its referenced module.
  assert_eq(owner_test_peek_trace(), 3UL)
  assert_true(value_module(value) is Some(_))
  assert_true(Show::to_string(value).contains("root"))
}

///|
test "aggregate expression and folded wrappers retain module until their last use" {
  for kind in [0, 1, 2, 3, 4, 5, 7] {
    exercise_constant_dependency(kind)
    assert_eq(owner_test_take_trace(), 321UL)
  }
}

///|
fn exercise_folded_scalar_owner() -> Unit raise {
  let value = scoped_address_constant(6)
  // Extracting a scalar drops the dependency absent from the result.
  inspect(owner_test_peek_trace(), content="32")
  inspect(value_module(value) is None, content="true")
  inspect(value, content="i32 7")
}

///|
test "folded scalar does not retain an unrelated module" {
  exercise_folded_scalar_owner()
  inspect(owner_test_take_trace(), content="321")
}

///|
fn exercise_initializer_owner_cycle() -> Unit raise {
  let ctx = Context::new()
  let mod = ctx.addModule("no_constant_owner_cycle")
  let builder = ctx.createBuilder()
  owner_test_watch(ctx.get_owner(), mod.get_owner(), builder.owner)
  let root = mod.addGlobalVariable(ctx.getInt32Ty(), "root")
  let addresses = ctx.getConstArray(ctx.getPtrTy(), [root])
  mod.addGlobalConstant(addresses.getType(), "addresses", addresses) |> ignore
  mod.verify()
}

///|
test "installing a module dependent initializer creates no owner cycle" {
  exercise_initializer_owner_cycle()
  let trace = owner_test_take_trace()
  // Independent builder may be released before or after the module.
  inspect(trace == 321UL || trace == 231UL, content="true")
}
