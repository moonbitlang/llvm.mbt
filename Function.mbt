///|
pub type Function ValueRef

///|
pub impl Value for Function with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for Function with asValueEnum(self) {
  Function(self)
}

///|
fn Function::getNextFunction(self : Self) -> Function? {
  let valueref = @unsafe.llvm_get_next_function(self.getValueRef())
  unless(@unsafe.llvm_value_ref_is_null(valueref), () => Function(valueref))
}

//fn Function::getPreviousFunction(self: Self) -> Function? {
//  let valueref = @unsafe.llvm_get_previous_function(self.getValueRef())
//  @option.unless(
//    @unsafe.llvm_value_ref_is_null(valueref),
//    () => Function(valueref)
//  )
//}

///| Get Function Name.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// 
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty])
///
/// let fval = mod.addFunction(fty, "plus1")
/// assert_eq(fval.getName(), "plus1")
/// ```
pub fn Function::getName(self : Self) -> String {
  @unsafe.llvm_get_value_name(self.getValueRef())
}

///| Get Function Type.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// 
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty])
///
/// let fval = mod.addFunction(fty, "plus1")
/// inspect(fval.getType(), content="i32 (i32)")
/// ```
pub fn Function::getType(self : Self) -> FunctionType {
  let typeref = @unsafe.llvm_global_get_value_type(self.getValueRef())
  FunctionType(typeref)
}

///| Get Number of Function Arguments.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// 
/// let f32_ty = ctx.getFloatTy()
/// let fmul_ty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty])
/// let fma_ty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty, f32_ty])
///
/// let fmul = mod.addFunction(fmul_ty, "fmul")
/// let fma = mod.addFunction(fma_ty, "fma")
///
/// assert_eq(fmul.getNumArgs(), 2)
/// assert_eq(fma.getNumArgs(), 3)
/// ```
pub fn Function::getNumArgs(self : Self) -> Int {
  @unsafe.llvm_count_params(self.getValueRef()).reinterpret_as_int()
}

///| Get Function Parameter.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// 
/// let f32_ty = ctx.getFloatTy()
/// let fmul_ty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty])
///
/// let fmul = mod.addFunction(fmul_ty, "fmul")
///
/// inspect(fmul.getArg(0).unwrap(), content="float %0")
/// inspect(fmul.getArg(1).unwrap(), content="float %1")
/// assert_true(fmul.getArg(2) is None)
/// ```
pub fn Function::getArg(self : Self, idx : Int) -> Argument? {
  when(idx >= 0 && idx < self.getNumArgs(), () => {
    let valueref = @unsafe.llvm_get_param(
      self.getValueRef(),
      idx.reinterpret_as_uint(),
    )
    Argument::construct(valueref, idx)
  })
}

///| Get Function Parameters.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// 
/// let f32_ty = ctx.getFloatTy()
/// let fmul_ty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty])
///
/// let fmul = mod.addFunction(fmul_ty, "fmul")
///
/// let args = fmul.getArgs()
///
/// inspect(args[0], content="float %0")
/// inspect(args[1], content="float %1")
/// ```
pub fn Function::getArgs(self : Self) -> Array[Argument] {
  @unsafe.llvm_get_params(self.getValueRef()).mapi((r, i) => Argument::construct(
    i, r,
  ))
}

///| Add a Basic Block to the Function.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
///
/// let void_ty = ctx.getVoidTy()
/// let fty = ctx.getFunctionType(void_ty, [])
///
/// let fval = mod.addFunction(fty, "foo")
///
/// let _ = fval.appendBasicBlock(name="entry")
/// let _ = fval.appendBasicBlock()
/// let _ = fval.appendBasicBlock()
///
/// assert_eq(fval.getNumBasicBlocks(), 3)
/// ```
pub fn Function::appendBasicBlock(
  self : Self,
  name~ : String = ""
) -> BasicBlock {
  let blockref = @unsafe.llvm_append_basic_block(self.getValueRef(), name)
  BasicBlock(blockref)
}

///| Get number of Basic Blocks in the Function.
///
/// ```moonbit skip for duplicate test.
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
///
/// let void_ty = ctx.getVoidTy()
/// let fty = ctx.getFunctionType(void_ty, [])
///
/// let fval = mod.addFunction(fty, "foo")
///
/// let entry = fval.appendBasicBlock(name="entry")
/// let block1 = fval.appendBasicBlock()
/// let block2 = fval.appendBasicBlock()
///
/// assert_eq(fval.getNumBasicBlocks(), 3)
/// ```
pub fn Function::getNumBasicBlocks(self : Self) -> Int {
  @unsafe.llvm_count_basic_blocks(self.getValueRef()).reinterpret_as_int()
}

///| Collect all Basic Blocks in the Function.
///
/// ```moonbit skip for duplicate test.
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
///
/// let void_ty = ctx.getVoidTy()
/// let fty = ctx.getFunctionType(void_ty, [])
///
/// let fval = mod.addFunction(fty, "foo")
///
/// let _ = fval.appendBasicBlock(name="entry")
/// let _ = fval.appendBasicBlock()
/// let _ = fval.appendBasicBlock()
///
/// assert_eq(fval.getBasicBlocks().length(), 3)
/// ```
pub fn Function::getBasicBlocks(self : Self) -> Array[BasicBlock] {
  @unsafe.llvm_get_basic_blocks(self.getValueRef()).map(r => BasicBlock(r))
}

///| Add Function Attribute.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
/// 
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
/// 
/// let fval = mod.addFunction(fty, "add_demo")
/// let bb = fval.appendBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
/// 
/// builder.setInsertPoint(bb)
/// let add = builder.createAdd(arg1, arg2, name="sum")
/// let _ = builder.createRet(add)
/// 
/// fval.addFnAttr(NoInline)
///
/// let expect = 
///   #|; Function Attrs: noinline
///   #|define i32 @add_demo(i32 %0, i32 %1) #0 {
///   #|entry:
///   #|  %sum = add i32 %0, %1
///   #|  ret i32 %sum
///   #|}
///   #|
///
///   inspect(fval, content=expect)
/// ```
pub fn Function::addFnAttr(self : Self, attr : FnAttr) -> Unit {
  let fn_attr = attr.to_llvm_attr(self.getContext())
  @unsafe.llvm_add_attribute_at_index(
    self.getValueRef(),
    @uint.max_value,
    fn_attr.inner(),
  )
}

///| Remove Function Attribute.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
/// 
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
/// 
/// let fval = mod.addFunction(fty, "add_demo")
/// let bb = fval.appendBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
/// 
/// builder.setInsertPoint(bb)
/// let add = builder.createAdd(arg1, arg2, name="sum")
/// let _ = builder.createRet(add)
/// 
/// fval.addFnAttr(NoInline)
///
/// let expect = 
///   #|; Function Attrs: noinline
///   #|define i32 @add_demo(i32 %0, i32 %1) #0 {
///   #|entry:
///   #|  %sum = add i32 %0, %1
///   #|  ret i32 %sum
///   #|}
///   #|
///
/// inspect(fval, content=expect)
///
/// fval.removeFnAttr(NoInline)
/// let expect =
///   #|define i32 @add_demo(i32 %0, i32 %1) {
///   #|entry:
///   #|  %sum = add i32 %0, %1
///   #|  ret i32 %sum
///   #|}
///   #|
///
/// inspect(fval, content=expect)
/// ```
pub fn Function::removeFnAttr(self : Self, fn_attr : FnAttr) -> Unit {
  let kind_n = @unsafe.llvm_get_enum_attribute_kind_for_name(
    fn_attr.attr_name(),
  )
  @unsafe.llvm_remove_enum_attribute_at_index(
    self.getValueRef(),
    @uint.max_value,
    kind_n,
  )
}

///| Count Function Attributes.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
/// 
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
/// 
/// let fval = mod.addFunction(fty, "add_demo")
/// let bb = fval.appendBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
/// 
/// builder.setInsertPoint(bb)
/// let add = builder.createAdd(arg1, arg2, name="sum")
/// let _ = builder.createRet(add)
/// 
/// fval.addFnAttr(NoInline)
/// assert_eq(fval.countFnAttrs(), 1)
///
/// fval.addFnAttr(AlwaysInline)
/// assert_eq(fval.countFnAttrs(), 2)
///
/// fval.removeFnAttr(NoInline)
/// assert_eq(fval.countFnAttrs(), 1)
/// ```
pub fn Function::countFnAttrs(self : Self) -> Int {
  @unsafe.llvm_get_attribute_count_at_index(self.getValueRef(), @uint.max_value).reinterpret_as_int()
}

///| Add an Attribute for the Return Value of the Function.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
/// 
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
/// 
/// let fval = mod.addFunction(fty, "add_demo")
/// let bb = fval.appendBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
/// 
/// builder.setInsertPoint(bb)
/// let add = builder.createAdd(arg1, arg2, name="sum")
/// let _ = builder.createRet(add)
/// 
/// fval.addRetAttr(InReg)
///
/// let expect = 
///   #|define inreg i32 @add_demo(i32 %0, i32 %1) {
///   #|entry:
///   #|  %sum = add i32 %0, %1
///   #|  ret i32 %sum
///   #|}
///   #|
///
/// inspect(fval, content=expect)
/// ```
pub fn Function::addRetAttr(self : Self, attr : RetAttr) -> Unit {
  let fn_attr = attr.to_llvm_attr(self.getContext())
  @unsafe.llvm_add_attribute_at_index(self.getValueRef(), 0, fn_attr.inner())
}

///| Remove the Attribute for the Return Value of the Function.
///
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
/// 
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
/// 
/// let fval = mod.addFunction(fty, "add_demo")
/// let bb = fval.appendBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
/// 
/// builder.setInsertPoint(bb)
/// let add = builder.createAdd(arg1, arg2, name="sum")
/// let _ = builder.createRet(add)
/// 
/// fval.addRetAttr(InReg)
///
/// let expect = 
///   #|define inreg i32 @add_demo(i32 %0, i32 %1) {
///   #|entry:
///   #|  %sum = add i32 %0, %1
///   #|  ret i32 %sum
///   #|}
///   #|
///
/// inspect(fval, content=expect)
///
/// fval.removeRetAttr(InReg)
///
/// let expect =
///   #|define i32 @add_demo(i32 %0, i32 %1) {
///   #|entry:
///   #|  %sum = add i32 %0, %1
///   #|  ret i32 %sum
///   #|}
///   #|
///
/// inspect(fval, content=expect)
/// ```
pub fn Function::removeRetAttr(self : Self, ret_attr : RetAttr) -> Unit {
  let kind_n = @unsafe.llvm_get_enum_attribute_kind_for_name(
    ret_attr.attr_name(),
  )
  @unsafe.llvm_remove_enum_attribute_at_index(self.getValueRef(), 0, kind_n)
}

///|
pub impl Show for Function with output(self, logger) {
  let s = @unsafe.llvm_print_value_to_string(self.getValueRef())
  logger.write_string(s)
}

// ==================================================
// Argument
// ==================================================

///|
pub struct Argument {
  value_ref : ValueRef
  idx : Int
}

///|
fn Argument::construct(value_ref : ValueRef, idx : Int) -> Self {
  Argument::{ value_ref, idx }
}

///|
fn Argument::inner(self : Self) -> ValueRef {
  self.value_ref
}

///|
pub impl Value for Argument with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for Argument with asValueEnum(self) {
  Argument(self)
}

///| Get Argument Name.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// 
/// let f32_ty = ctx.getFloatTy()
/// let fmul_ty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty])
///
/// let fmul = mod.addFunction(fmul_ty, "fmul")
///
/// let arg0 = fmul.getArg(0).unwrap()
/// inspect(arg0.getName(), content="")
/// arg0.setName("a")
/// inspect(arg0.getName(), content="a")
/// ```
pub fn Argument::getName(self : Self) -> String {
  @unsafe.llvm_get_value_name(self.getValueRef())
}

///| Set Argument Name.
///
/// ```moonbit skip due to duplicate test.
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// 
/// let f32_ty = ctx.getFloatTy()
/// let fmul_ty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty])
///
/// let fmul = mod.addFunction(fmul_ty, "fmul")
///
/// let arg0 = fmul.getArg(0).unwrap()
/// inspect(arg0.getName(), content="")
/// arg0.setName("a")
/// inspect(arg0.getName(), content="a")
/// ```
pub fn Argument::setName(self : Self, name : String) -> Unit {
  @unsafe.llvm_set_value_name(self.getValueRef(), name)
}

///|
pub fn Argument::getFunction(self : Self) -> Function {
  let func_ref = @unsafe.llvm_get_param_parent(self.getValueRef())
  Function(func_ref)
}

///| Add an Attribute to the Argument.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "add_demo")
/// let bb = fval.appendBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
//
///| builder.setInsertPoint(bb)
/// let add = builder.createAdd(arg1, arg2, name="sum")
/// let _ = builder.createRet(add)
///
/// arg1.addAttr(NonNull)
/// arg2.addAttr(InReg)
///
/// let expect =
///   #|define i32 @add_demo(i32 nonnull %0, i32 inreg %1) {
///   #|entry:
///   #|  %sum = add i32 %0, %1
///   #|  ret i32 %sum
///   #|}
///   #|
///
/// inspect(fval, content=expect)
/// ```
pub fn Argument::addAttr(self : Self, attr : ParamAttr) -> Unit {
  let param_attr = attr.to_llvm_attr(self.getContext())
  @unsafe.llvm_add_attribute_at_index(
    self.getFunction().getValueRef(),
    self.idx.reinterpret_as_uint() + 1,
    param_attr.inner(),
  )
}

///|
pub fn Argument::removeAttr(self : Self, attr : ParamAttr) -> Unit {
  let kind_n = @unsafe.llvm_get_enum_attribute_kind_for_name(attr.attr_name())
  @unsafe.llvm_remove_enum_attribute_at_index(
    self.getFunction().getValueRef(),
    self.idx.reinterpret_as_uint() + 1,
    kind_n,
  )
}

///|
pub impl Show for Argument with output(self, logger) {
  let s = @unsafe.llvm_print_value_to_string(self.getValueRef())
  logger.write_string(s)
}
