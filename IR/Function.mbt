///|
/// Module-owned LLVM function declaration or definition.
///
/// A function begins as a declaration and becomes a definition as basic blocks
/// are added. Its signature is context-owned; arguments and blocks are anchored
/// to the same module as the function.
///
/// **Lifecycle:** The wrapper retains its owning module. Unsafe removal or
/// deletion of the function can still invalidate this and derived wrappers.
pub struct Function {
  priv value : ModuleAnchoredValue
}

///|
fn Function::from_raw(value_ref : ValueRef, owner_module : Module) -> Function {
  Function::{ value: ModuleAnchoredValue::new(value_ref, owner_module) }
}

///|
fn Function::get_module(self : Function) -> Module {
  self.value.get_module()
}

///|
/// Exposes the borrowed LLVM value handle.
pub impl Value for Function with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::Function`.
pub impl Value for Function with fn asValueEnum(self) {
  Function(self)
}

///|
/// Classifies this wrapper as `GlobalEnum::Function`.
pub impl GlobalValue for Function with fn asGlobalEnum(self) {
  Function(self)
}

///|
fn Function::getNextFunction(self : Self) -> Function? {
  let valueref = @unsafe.llvm_get_next_function(self.getValueRef())
  unless(@unsafe.llvm_value_ref_is_null(valueref), () => {
    Function::from_raw(valueref, self.get_module())
  })
}

//fn Function::getPreviousFunction(self: Self) -> Function? {
//  let valueref = @unsafe.llvm_get_previous_function(self.getValueRef())
//  @option.unless(
//    @unsafe.llvm_value_ref_is_null(valueref),
//    () => Function(valueref)
//  )
//}

///|
/// Returns the optional function name.
///
/// **Errors:** Raises `StringError::MalformedUtf8` if LLVM returns invalid
/// UTF-8.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///
///   let i32_ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32_ty, [i32_ty])
///
///   let fval = mod.addFunction(fty, "plus1")
///   assert_eq(fval.getName(), Some("plus1"))
/// }
/// ```
pub fn Function::getName(self : Self) -> String? raise StringError {
  self.getValueName()
}

///|
/// Sets the function name.
///
/// **Errors:** Raises `StringError::ContainsNul` for an embedded NUL byte.
///
/// **Side Effects:** Changes symbol lookup and the name printed in LLVM IR.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///
///   let i32_ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32_ty, [i32_ty])
///
///   let fval = mod.addFunction(fty, "plus1")
///   assert_eq(fval.getName(), Some("plus1"))
///
///   fval.setName("increment")
///   assert_eq(fval.getName(), Some("increment"))
/// }
/// ```
pub fn Function::setName(self : Self, name : String) -> Unit raise StringError {
  self.setValueName(name)
}

///|
/// Returns this function's signature type.
///
/// **Lifecycle:** The returned type is owned by the module's context.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///
///   let i32_ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32_ty, [i32_ty])
///
///   let fval = mod.addFunction(fty, "plus1")
///   inspect(fval.getType(), content="i32 (i32)")
/// }
/// ```
pub fn Function::getType(self : Self) -> FunctionType {
  let typeref = @unsafe.llvm_global_get_value_type(self.getValueRef())
  FunctionType::from_raw(typeref, self.get_module().getContext())
}

///|
/// Returns the number of fixed function arguments.
///
/// Variadic arguments at call sites are not part of a function definition's
/// argument list.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///
///   let f32_ty = ctx.getFloatTy()
///   let fmul_ty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty])
///   let fma_ty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty, f32_ty])
///
///   let fmul = mod.addFunction(fmul_ty, "fmul")
///   let fma = mod.addFunction(fma_ty, "fma")
///
///   assert_eq(fmul.getNumArgs(), 2)
///   assert_eq(fma.getNumArgs(), 3)
/// }
/// ```
pub fn Function::getNumArgs(self : Self) -> Int {
  @unsafe.llvm_count_params(self.getValueRef()).reinterpret_as_int()
}

///|
/// Returns a fixed argument by zero-based index.
///
/// **Returns:** `None` for a negative or out-of-range index.
///
/// **Lifecycle:** A returned argument retains this function's module.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///
///   let f32_ty = ctx.getFloatTy()
///   let fmul_ty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty])
///
///   let fmul = mod.addFunction(fmul_ty, "fmul")
///
///   inspect(fmul.getArg(0).unwrap(), content="float %0")
///   inspect(fmul.getArg(1).unwrap(), content="float %1")
///   assert_true(fmul.getArg(2) is None)
/// }
/// ```
pub fn Function::getArg(self : Self, idx : Int) -> Argument? {
  when(idx >= 0 && idx < self.getNumArgs(), () => {
    let valueref = @unsafe.llvm_get_param(
      self.getValueRef(),
      idx.reinterpret_as_uint(),
    )
    Argument::construct(valueref, idx, self.get_module())
  })
}

///|
/// Returns all fixed arguments in signature order.
///
/// **Lifecycle:** Each returned argument retains this function's module.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///
///   let f32_ty = ctx.getFloatTy()
///   let fmul_ty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty])
///
///   let fmul = mod.addFunction(fmul_ty, "fmul")
///
///   let args = fmul.getArgs()
///
///   inspect(args[0], content="float %0")
///   inspect(args[1], content="float %1")
/// }
/// ```
pub fn Function::getArgs(self : Self) -> Array[Argument] {
  @unsafe.llvm_get_params(self.getValueRef()).mapi((r, i) => {
    Argument::construct(i, r, self.get_module())
  })
}

///|
/// Adds a basic block to this function.
///
/// **Parameters:**
///
/// - `name`: Optional block name.
/// - `before`: When present, inserts immediately before that block; otherwise
///   appends to the function.
///
/// **Preconditions:** `before` must belong to this function and module. The
/// implementation does not validate this relationship before calling LLVM.
///
/// **Errors:** Raises `StringError::ContainsNul` if `name` contains an embedded
/// NUL byte.
///
/// **Side Effects:** Mutates the function's block list.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///
///   let void_ty = ctx.getVoidTy()
///   let fty = ctx.getFunctionType(void_ty, [])
///
///   let fval = mod.addFunction(fty, "foo")
///
///   let _ = fval.addBasicBlock(name="entry")
///   let _ = fval.addBasicBlock()
///   let _ = fval.addBasicBlock()
///
///   assert_eq(fval.getNumBasicBlocks(), 3)
/// }
/// ```
pub fn Function::addBasicBlock(
  self : Self,
  name? : String = "",
  before? : BasicBlock? = None,
) -> BasicBlock raise StringError {
  let blockref = match before {
    None =>
      @unsafe.llvm_append_basic_block(self.getValueRef(), name) catch {
        @unsafe.EmbeddedNul => raise ContainsNul
      }
    Some(bb) =>
      @unsafe.llvm_insert_basic_block(bb.get_unsafe_ref(), name) catch {
        @unsafe.EmbeddedNul => raise ContainsNul
      }
  }
  BasicBlock::from_raw(blockref, self.get_module())
}

///|
/// Returns the number of basic blocks currently attached to the function.
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
/// let entry = fval.addBasicBlock(name="entry")
/// let block1 = fval.addBasicBlock()
/// let block2 = fval.addBasicBlock()
///
/// assert_eq(fval.getNumBasicBlocks(), 3)
/// ```
pub fn Function::getNumBasicBlocks(self : Self) -> Int {
  @unsafe.llvm_count_basic_blocks(self.getValueRef()).reinterpret_as_int()
}

///|
/// Returns all currently attached basic blocks in function order.
///
/// **Lifecycle:** Each returned block retains this function's module.
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
/// let _ = fval.addBasicBlock(name="entry")
/// let _ = fval.addBasicBlock()
/// let _ = fval.addBasicBlock()
///
/// assert_eq(fval.getBasicBlocks().length(), 3)
/// ```
pub fn Function::getBasicBlocks(self : Self) -> Array[BasicBlock] {
  @unsafe.llvm_get_basic_blocks(self.getValueRef()).map(r => {
    BasicBlock::from_raw(r, self.get_module())
  })
}

///|
/// Adds or replaces a supported function attribute.
///
/// **Preconditions:** The attribute must be valid for this signature and target
/// ABI; complete validation is deferred to LLVM's verifier.
///
/// **Side Effects:** Mutates function attributes and may affect optimization or
/// code generation.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///   let builder = ctx.createBuilder()
///
///   let i32_ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
///   let fval = mod.addFunction(fty, "add_demo")
///   let bb = fval.addBasicBlock(name="entry")
///   let arg1 = fval.getArg(0).unwrap()
///   let arg2 = fval.getArg(1).unwrap()
///
///   builder.setInsertPoint(bb)
///   let add = builder.createAdd(arg1, arg2, name="sum")
///   let _ = builder.createRet(add)
///
///   fval.addFnAttr(NoInline)
///
///   let expect =
///     #|; Function Attrs: noinline
///     #|define i32 @add_demo(i32 %0, i32 %1) #0 {
///     #|entry:
///     #|  %sum = add i32 %0, %1
///     #|  ret i32 %sum
///     #|}
///     #|
///
///   inspect(fval, content=expect)
/// }
/// ```
pub fn Function::addFnAttr(self : Self, attr : FnAttr) -> Unit {
  let fn_attr = attr.to_llvm_attr(self.getContext())
  @unsafe.llvm_add_attribute_at_index(
    self.getValueRef(),
    @uint.MAX_VALUE,
    fn_attr.0,
  )
}

///|
/// Removes the selected function-attribute kind if present.
///
/// **Side Effects:** Mutates function attributes.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///   let builder = ctx.createBuilder()
///
///   let i32_ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
///   let fval = mod.addFunction(fty, "add_demo")
///   let bb = fval.addBasicBlock(name="entry")
///   let arg1 = fval.getArg(0).unwrap()
///   let arg2 = fval.getArg(1).unwrap()
///
///   builder.setInsertPoint(bb)
///   let add = builder.createAdd(arg1, arg2, name="sum")
///   let _ = builder.createRet(add)
///
///   fval.addFnAttr(NoInline)
///
///   let expect =
///     #|; Function Attrs: noinline
///     #|define i32 @add_demo(i32 %0, i32 %1) #0 {
///     #|entry:
///     #|  %sum = add i32 %0, %1
///     #|  ret i32 %sum
///     #|}
///     #|
///
///   inspect(fval, content=expect)
///
///   fval.removeFnAttr(NoInline)
///   let expect =
///     #|define i32 @add_demo(i32 %0, i32 %1) {
///     #|entry:
///     #|  %sum = add i32 %0, %1
///     #|  ret i32 %sum
///     #|}
///     #|
///
///   inspect(fval, content=expect)
/// }
/// ```
pub fn Function::removeFnAttr(self : Self, fn_attr : FnAttr) -> Unit {
  let kind_n = @unsafe.llvm_get_enum_attribute_kind_for_name(
    fn_attr.attr_name(),
  )
  @unsafe.llvm_remove_enum_attribute_at_index(
    self.getValueRef(),
    @uint.MAX_VALUE,
    kind_n,
  )
}

///|
/// Returns the number of function-level attributes currently attached.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///   let builder = ctx.createBuilder()
///
///   let i32_ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
///   let fval = mod.addFunction(fty, "add_demo")
///   let bb = fval.addBasicBlock(name="entry")
///   let arg1 = fval.getArg(0).unwrap()
///   let arg2 = fval.getArg(1).unwrap()
///
///   builder.setInsertPoint(bb)
///   let add = builder.createAdd(arg1, arg2, name="sum")
///   let _ = builder.createRet(add)
///
///   fval.addFnAttr(NoInline)
///   assert_eq(fval.countFnAttrs(), 1)
///
///   fval.addFnAttr(AlwaysInline)
///   assert_eq(fval.countFnAttrs(), 2)
///
///   fval.removeFnAttr(NoInline)
///   assert_eq(fval.countFnAttrs(), 1)
/// }
/// ```
pub fn Function::countFnAttrs(self : Self) -> Int {
  @unsafe.llvm_get_attribute_count_at_index(self.getValueRef(), @uint.MAX_VALUE).reinterpret_as_int()
}

///|
/// Adds or replaces a supported return-value attribute.
///
/// **Preconditions:** The attribute must be valid for the return type and target
/// ABI; complete validation is deferred to LLVM's verifier.
///
/// **Side Effects:** Mutates return attributes.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///   let builder = ctx.createBuilder()
///
///   let i32_ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
///   let fval = mod.addFunction(fty, "add_demo")
///   let bb = fval.addBasicBlock(name="entry")
///   let arg1 = fval.getArg(0).unwrap()
///   let arg2 = fval.getArg(1).unwrap()
///
///   builder.setInsertPoint(bb)
///   let add = builder.createAdd(arg1, arg2, name="sum")
///   let _ = builder.createRet(add)
///
///   fval.addRetAttr(InReg)
///
///   let expect =
///     #|define inreg i32 @add_demo(i32 %0, i32 %1) {
///     #|entry:
///     #|  %sum = add i32 %0, %1
///     #|  ret i32 %sum
///     #|}
///     #|
///
///   inspect(fval, content=expect)
/// }
/// ```
pub fn Function::addRetAttr(self : Self, attr : RetAttr) -> Unit {
  let fn_attr = attr.to_llvm_attr(self.getContext())
  @unsafe.llvm_add_attribute_at_index(self.getValueRef(), 0, fn_attr.0)
}

///|
/// Removes the selected return-attribute kind if present.
///
/// **Side Effects:** Mutates return attributes.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///   let builder = ctx.createBuilder()
///
///   let i32_ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
///   let fval = mod.addFunction(fty, "add_demo")
///   let bb = fval.addBasicBlock(name="entry")
///   let arg1 = fval.getArg(0).unwrap()
///   let arg2 = fval.getArg(1).unwrap()
///
///   builder.setInsertPoint(bb)
///   let add = builder.createAdd(arg1, arg2, name="sum")
///   let _ = builder.createRet(add)
///
///   fval.addRetAttr(InReg)
///
///   let expect =
///     #|define inreg i32 @add_demo(i32 %0, i32 %1) {
///     #|entry:
///     #|  %sum = add i32 %0, %1
///     #|  ret i32 %sum
///     #|}
///     #|
///
///   inspect(fval, content=expect)
///
///   fval.removeRetAttr(InReg)
///
///   let expect =
///     #|define i32 @add_demo(i32 %0, i32 %1) {
///     #|entry:
///     #|  %sum = add i32 %0, %1
///     #|  ret i32 %sum
///     #|}
///     #|
///
///   inspect(fval, content=expect)
/// }
/// ```
pub fn Function::removeRetAttr(self : Self, ret_attr : RetAttr) -> Unit {
  let kind_n = @unsafe.llvm_get_enum_attribute_kind_for_name(
    ret_attr.attr_name(),
  )
  @unsafe.llvm_remove_enum_attribute_at_index(self.getValueRef(), 0, kind_n)
}

///|
/// Writes the complete LLVM function declaration or definition.
pub impl Show for Function with fn output(self, logger) {
  let s = @unsafe.llvm_print_value_to_string(self.getValueRef()) catch {
    error => "<LLVM function text unavailable: \{error}>"
  }
  logger.write_string(s)
}

// ==================================================
// Argument
// ==================================================

///|
/// Module-anchored view of one fixed function argument.
///
/// The wrapper records the argument's zero-based index for attribute APIs.
///
/// **Lifecycle:** It retains the function's module. If the function is erased
/// through an unsafe API, this wrapper becomes invalid.
pub struct Argument {
  priv value_ref : ValueRef
  priv idx : Int
  priv owner_module : Module
}

///|
fn Argument::construct(
  value_ref : ValueRef,
  idx : Int,
  owner_module : Module,
) -> Self {
  Argument::{ value_ref, idx, owner_module }
}

///|
fn Argument::inner(self : Self) -> ValueRef {
  self.value_ref
}

///|
fn Argument::get_module(self : Argument) -> Module {
  self.owner_module
}

///|
/// Exposes the borrowed LLVM value handle.
pub impl Value for Argument with fn getValueRef(self) -> ValueRef {
  self.inner()
}

///|
/// Classifies this wrapper as `ValueEnum::Argument`.
pub impl Value for Argument with fn asValueEnum(self) {
  Argument(self)
}

///|
/// Returns the optional argument name.
///
/// **Errors:** Raises `StringError::MalformedUtf8` if LLVM returns invalid
/// UTF-8.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///
///   let f32_ty = ctx.getFloatTy()
///   let fmul_ty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty])
///
///   let fmul = mod.addFunction(fmul_ty, "fmul")
///
///   let arg0 = fmul.getArg(0).unwrap()
///   assert_eq(arg0.getName(), None)
///   arg0.setName("a")
///   assert_eq(arg0.getName(), Some("a"))
/// }
/// ```
pub fn Argument::getName(self : Self) -> String? raise StringError {
  self.getValueName()
}

///|
/// Sets the argument name.
///
/// **Errors:** Raises `StringError::ContainsNul` for an embedded NUL byte.
///
/// **Side Effects:** Changes the name printed in the containing function.
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
/// assert_eq(arg0.getName(), None)
/// arg0.setName("a")
/// assert_eq(arg0.getName(), Some("a"))
/// ```
pub fn Argument::setName(self : Self, name : String) -> Unit raise StringError {
  self.setValueName(name)
}

///|
/// Returns the function that owns this argument.
///
/// **Lifecycle:** The returned wrapper retains the same module.
pub fn Argument::getFunction(self : Self) -> Function {
  let func_ref = @unsafe.llvm_get_param_parent(self.getValueRef())
  Function::from_raw(func_ref, self.get_module())
}

///|
/// Adds or replaces a supported parameter attribute.
///
/// **Preconditions:** The attribute must be valid for this argument's type and
/// target ABI; complete validation is deferred to LLVM's verifier.
///
/// **Side Effects:** Mutates the corresponding function parameter attributes.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///   let builder = ctx.createBuilder()
///
///   let i32_ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
///   let fval = mod.addFunction(fty, "add_demo")
///   let bb = fval.addBasicBlock(name="entry")
///   let arg1 = fval.getArg(0).unwrap()
///   let arg2 = fval.getArg(1).unwrap()
///
///   builder.setInsertPoint(bb)
///   let add = builder.createAdd(arg1, arg2, name="sum")
///   let _ = builder.createRet(add)
///
///   arg1.addAttr(NonNull)
///   arg2.addAttr(InReg)
///
///   let expect =
///     #|define i32 @add_demo(i32 nonnull %0, i32 inreg %1) {
///     #|entry:
///     #|  %sum = add i32 %0, %1
///     #|  ret i32 %sum
///     #|}
///     #|
///
///   inspect(fval, content=expect)
/// }
/// ```
pub fn Argument::addAttr(self : Self, attr : ParamAttr) -> Unit {
  let param_attr = attr.to_llvm_attr(self.getContext())
  @unsafe.llvm_add_attribute_at_index(
    self.getFunction().getValueRef(),
    self.idx.reinterpret_as_uint() + 1,
    param_attr.0,
  )
}

///|
/// Removes the selected parameter-attribute kind if present.
///
/// **Side Effects:** Mutates the corresponding function parameter attributes.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("demo")
///   let builder = ctx.createBuilder()
///
///   let i32_ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
///   let fval = mod.addFunction(fty, "add_demo")
///   let bb = fval.addBasicBlock(name="entry")
///   let arg1 = fval.getArg(0).unwrap()
///   let arg2 = fval.getArg(1).unwrap()
///
///   builder.setInsertPoint(bb)
///   let add = builder.createAdd(arg1, arg2, name="sum")
///   let _ = builder.createRet(add)
///
///   arg1.addAttr(NonNull)
///   arg1.addAttr(InReg)
///   arg2.addAttr(InReg)
///
///   let expect =
///     #|define i32 @add_demo(i32 inreg nonnull %0, i32 inreg %1) {
///     #|entry:
///     #|  %sum = add i32 %0, %1
///     #|  ret i32 %sum
///     #|}
///     #|
///
///   inspect(fval, content=expect)
///
///   arg1.removeAttr(NonNull)
///
///   let expect =
///     #|define i32 @add_demo(i32 inreg %0, i32 inreg %1) {
///     #|entry:
///     #|  %sum = add i32 %0, %1
///     #|  ret i32 %sum
///     #|}
///     #|
///
///   inspect(fval, content=expect)
/// }
/// ```
pub fn Argument::removeAttr(self : Self, attr : ParamAttr) -> Unit {
  let kind_n = @unsafe.llvm_get_enum_attribute_kind_for_name(attr.attr_name())
  @unsafe.llvm_remove_enum_attribute_at_index(
    self.getFunction().getValueRef(),
    self.idx.reinterpret_as_uint() + 1,
    kind_n,
  )
}

///|
/// Writes this typed argument using LLVM syntax.
pub impl Show for Argument with fn output(self, logger) {
  let s = @unsafe.llvm_print_value_to_string(self.getValueRef()) catch {
    error => "<LLVM argument text unavailable: \{error}>"
  }
  logger.write_string(s)
}
