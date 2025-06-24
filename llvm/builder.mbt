///|
enum PositionState {
  NotSet
  Set
} derive(Show, Eq)

///|
pub suberror BuilderError {
  UnsetPosition
  // Builder position is not set
  // Alignment error
  AlignmentError(String)
  // Aggregate extract index out of range
  ExtractOutOfRange
  // Bitwidth of a value is incorrect
  BitwidthError(String)
  // Pointee type does not match the value's type
  PointeeTypeMismatch(String)
  // Values do not have the same type
  ValueTypeMismatch(String)
  // Ordering error or mismatch
  OrderingError(String)
  // GEP pointee is not a struct
  GEPPointee
  // GEP index out of range
  GEPIndex
}

// FIXME: Dummy function, just for stopping warning eliminate when all done

///|
pub fn raise_builder_error(i : Int) -> Int raise BuilderError {
  match i {
    0 => raise UnsetPosition
    1 => raise AlignmentError("Alignment error")
    2 => raise ExtractOutOfRange
    3 => raise BitwidthError("Bitwidth of a value is incorrect")
    4 =>
      raise PointeeTypeMismatch("Pointee type does not match the value's type")
    5 => raise ValueTypeMismatch("Values do not have the same type")
    6 => raise OrderingError("Ordering error or mismatch")
    7 => raise GEPPointee
    8 => raise GEPIndex
    _ => return i
  }
}

///| IR Builder
pub struct Builder {
  builder_ref : @unsafe.LLVMBuilderRef
  mut positioned : PositionState
}

///| Create an IR builder given `@unsafe.LLVMBuilderRef`
pub fn Builder::new(builder_ref : @unsafe.LLVMBuilderRef) -> Builder {
  Builder::{ builder_ref, positioned: NotSet }
}

///| Return the `@unsafe.LLVMBuilderRef` that this builder wraps.
fn Builder::as_builder_ref(self : Builder) -> @unsafe.LLVMBuilderRef {
  self.builder_ref
}

///|
fn Builder::get_positioned(self : Builder) -> PositionState {
  self.positioned
}

///|
pub fn Builder::get_insert_block(
  self : Builder
) -> BasicBlock raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let block_ref = @unsafe.llvm_get_insert_block(self.as_builder_ref())
  BasicBlock::new(block_ref)
}

///| Builds a function return instruction.
/// It should be provided with `None` if the return type
/// is void otherwise `Some(value)` should be provided.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ret");
/// let builder = context.create_builder();
/// let i32_type = context.i32_type();
/// let arg_types = [i32_type];
/// let fn_type = i32_type.fn_type(arg_types);
/// let fn_value = module.add_function("ret", fn_type);
/// let entry = context.append_basic_block(fn_value, name="entry");
/// let i32_arg = fn_value.get_first_param().unwrap();
///
/// builder.position_at_end(entry);
/// let _ = builder.build_return(i32_arg);
/// ```
pub fn[T : BasicValue] Builder::build_return(
  self : Builder,
  val : T
) -> InstructionValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let builder_ref = self.as_builder_ref()
  let val_ref = val.as_value_ref()
  let inst = @unsafe.llvm_build_ret(builder_ref, val_ref)
  InstructionValue::new(inst)
}

///|
pub fn Builder::build_return_void(
  self : Builder
) -> InstructionValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let builder_ref = self.as_builder_ref()
  let inst = @unsafe.llvm_build_ret_void(builder_ref)
  InstructionValue::new(inst)
}

///| Builds a function return instruction for a return type which is an aggregate type (ie structs and arrays).
/// It is not necessary to use this over `build_return` but may be more convenient to use.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ret");
/// let builder = context.create_builder();
/// let i32_type = context.i32_type();
/// let i32_three = i32_type.const_int(3);
/// let i32_seven = i32_type.const_int(7);
/// let struct_type = context.struct_type([i32_type, i32_type]);
/// let fn_type = struct_type.fn_type([]);
/// let fn_value = module.add_function("ret", fn_type);
/// let entry = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry);
/// let _ = builder.build_aggregate_return([i32_three, i32_seven]);
/// ```
pub fn Builder::build_aggregate_return(
  self : Builder,
  values : Array[&BasicValue]
) -> InstructionValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let builder_ref = self.as_builder_ref()
  let args = values.map(fn(v) { v.as_value_ref() })
  let ret_v = @unsafe.llvm_build_aggregate_ret(builder_ref, args)
  InstructionValue::new(ret_v)
}

///| Builds a function call instruction.
/// `FunctionValue`s can be implicitly converted into a `CallableValue`.
/// See `CallableValue` for details on calling a `PointerValue` that points to a function.
///
/// `FunctionValue`: crate::values::FunctionValue
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ret");
/// let builder = context.create_builder();
/// let i32_type = context.i32_type();
/// let fn_type = i32_type.fn_type([i32_type]);
/// let fn_value = module.add_function("ret", fn_type);
/// let entry = context.append_basic_block(fn_value, name="entry");
/// let i32_arg = fn_value.get_first_param().unwrap();
/// let md_string = context.metadata_string("a metadata");
///
/// builder.position_at_end(entry);
///
/// let ret_val = builder.build_call(fn_value, [i32_arg, md_string], name="call")
///     .unwrap()
///     .try_as_basic_value()
///     .left()
///     .unwrap();
///
/// builder.build_return(Some(&ret_val));
/// ```
pub fn Builder::build_call(
  self : Builder,
  func : FunctionValue,
  args : Array[&BasicValue],
  name~ : String = ""
) -> CallSiteValue raise BuilderError {
  self.build_direct_call(func, args, name~)
}

///| Builds a function call instruction. The function being called is known at compile time. If
/// you want to call a function pointer, see [Builder::build_indirect_call].
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ret");
/// let builder = context.create_builder();
/// let i32_type = context.i32_type();
/// let fn_type = i32_type.fn_type([i32_type]);
/// let fn_value = module.add_function("ret", fn_type);
/// let entry = context.append_basic_block(fn_value, name="entry");
/// let i32_arg = fn_value.get_first_param().unwrap();
/// let md_string = context.metadata_string("a metadata");
///
/// builder.position_at_end(entry);
///
/// let ret_val = builder.build_call(fn_value, [i32_arg, md_string], name="call")
///     .unwrap()
///     .try_as_basic_value()
///     .left()
///     .unwrap();
///
/// builder.build_return(ret_val);
/// ```
pub fn Builder::build_direct_call(
  self : Builder,
  func : FunctionValue,
  args : Array[&BasicValue],
  name~ : String = ""
) -> CallSiteValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let fty = func.get_type()
  let fn_val = func.value
  self.build_call_help(fty, fn_val, args, name~)
}

///| Build a function call instruction, with attached operand bundles.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("call_with_op_bundles");
/// let builder = context.create_builder();
/// let i32_type = context.i32_type();
///
/// // declare i32 @func(i32)
/// let fn_type = i32_type.fn_type([i32_type]);
/// let fn_value = module.add_function("func", fn_type);
///
/// let basic_block = context.append_basic_block(fn_value, name="entry");
/// builder.position_at_end(basic_block);
///
/// // %func_ret = call i32 @func(i32 0) [ "tag"(i32 0) ]
/// let ret_val = builder.build_direct_call_with_operand_bundles(
///     fn_value,
///     [i32_type.const_zero()],
///     [OperandBundle::create("tag", [i32_type.const_zero()])],
///     "func_ret"
/// )
///     .unwrap()
///     .try_as_basic_value()
///     .unwrap_left();
/// builder.build_return(Some(ret_val));
/// ```
pub fn Builder::build_direct_call_with_operand_bundles(
  self : Builder,
  func : FunctionValue,
  args : Array[&BasicMetadataValue],
  operand_bundles : Array[OperandBundle],
  name~ : String = ""
) -> CallSiteValue raise BuilderError {
  let fty = func.get_type()
  let fn_val = func.value
  self.build_call_with_operand_bundles_help(
    fty,
    fn_val,
    args.map(v => v.as_basic_metadata_value_enum()),
    operand_bundles,
    name~,
  )
}

///| Call a function pointer. Because a pointer does not carry a type, the type of the function
/// must be specified explicitly.
///
/// See [Context::create_inline_asm] for a practical example. Basic usage looks like this:
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ret");
/// let builder = context.create_builder();
/// let i32_type = context.i32_type();
/// let fn_type = i32_type.fn_type([i32_type]);
/// let fn_value = module.add_function("ret", fn_type);
/// let entry = context.append_basic_block(fn_value, name="entry");
/// let i32_arg = fn_value.get_first_param().unwrap();
/// let md_string = context.metadata_string("a metadata");
///
/// builder.position_at_end(entry);
///
/// let function_pointer = fn_value.as_global_value().as_pointer_value();
/// let ret_val = builder.build_indirect_call(
///   fn_value.get_type(),
///   function_pointer,
///   [i32_arg, md_string],
///   "call")
///     .unwrap()
///     .try_as_basic_value()
///     .left()
///     .unwrap();
///
/// builder.build_return(Some(ret_val));
/// ```
///
pub fn Builder::build_indirect_call(
  self : Builder,
  fn_type : FunctionType,
  fn_ptr : PointerValue,
  args : Array[&BasicValue],
  name~ : String = ""
) -> CallSiteValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  self.build_call_help(fn_type, fn_ptr.value, args, name~)
}

///| Build a call instruction to a function pointer, with attached operand bundles.
///
/// See [Builder::build_direct_call_with_operand_bundles] for a usage example
/// with operand bundles.
pub fn Builder::build_indirect_call_with_operand_bundles(
  self : Builder,
  fn_type : FunctionType,
  fn_ptr : PointerValue,
  args : Array[&BasicMetadataValue],
  operand_bundles : Array[OperandBundle],
  name~ : String = ""
) -> CallSiteValue raise BuilderError {
  self.build_call_with_operand_bundles_help(
    fn_type,
    fn_ptr.value,
    args.map(v => v.as_basic_metadata_value_enum()),
    operand_bundles,
    name~,
  )
}

///|
fn Builder::build_call_help(
  self : Builder,
  fn_ty : FunctionType,
  fn_val : Value, // FunctionValue Or PointerValue
  args : Array[&BasicValue],
  name~ : String = ""
) -> CallSiteValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let builder_ref = self.as_builder_ref()
  let fty_ref = fn_ty.as_type_ref()
  let fval_ref = fn_val.as_value_ref()
  let args = args.map(fn(v) { v.as_value_ref() })
  let r = @unsafe.llvm_build_call2(builder_ref, fty_ref, fval_ref, args, name)
  CallSiteValue::new(r)
}

///|
fn Builder::build_call_with_operand_bundles_help(
  self : Builder,
  fty : FunctionType,
  fn_val : Value, // FunctionValue Or PointerValue
  args : Array[BasicMetadataValueEnum],
  operand_bundles : Array[OperandBundle],
  name~ : String = ""
) -> CallSiteValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let builder_ref = self.as_builder_ref()
  let fty_ref = fty.as_type_ref()
  let fval_ref = fn_val.as_value_ref()
  let args = args.map(fn(v) { v.as_value_ref() })
  let operand_bundles = operand_bundles.map(fn(ob) { ob.as_bundle_ref() })
  let r = @unsafe.llvm_build_call_with_operand_bundles(
    builder_ref, fty_ref, fval_ref, args, operand_bundles, name,
  )
  CallSiteValue::new(r)
}

///| An invoke is similar to a normal function call, but used to
/// call functions that may throw an exception, and then respond to the exception.
///
/// When the called function returns normally, the `then` block is evaluated next. If instead
/// the function threw an exception, the `catch` block is entered. The first non-phi
/// instruction of the catch block must be a `landingpad` instruction. See also
/// [`Builder::build_landing_pad`].
///
/// The [`add_prune_eh_pass`] turns an invoke into a call when the called function is
/// guaranteed to never throw an exception.
///
/// [`add_prune_eh_pass`]: crate::passes::PassManager::add_prune_eh_pass
///
/// This example catches C++ exceptions of type `int`, and returns `0` if an exceptions is thrown.
/// For usage of a cleanup landing pad and the `resume` instruction, see [`Builder::build_resume`]
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("sum");
/// let builder = context.create_builder();
///
/// let f32_type = context.f32_type();
/// let fn_type = f32_type.fn_type([]);
///
/// // we will pretend this function can throw an exception
/// let function = module.add_function("bomb", fn_type);
/// let basic_block = context.append_basic_block(function, name="entry");
///
/// builder.position_at_end(basic_block);
///
/// let pi = f32_type.const_float(@math.PI);
///
/// let _ = builder.build_return(pi);
///
/// let function2 = module.add_function("wrapper", fn_type);
/// let basic_block2 = context.append_basic_block(function2, name="entry");
///
/// builder.position_at_end(basic_block2);
///
/// let then_block = context.append_basic_block(function2, name="then_block");
/// let catch_block = context.append_basic_block(function2, name="catch_block");
///
/// let call_site = builder.build_invoke(
///   function, [], then_block, catch_block).unwrap();
///
/// {
///     builder.position_at_end(then_block);
///
///     // in the then_block, the `call_site` value is defined and can be used
///     let result = call_site.try_as_basic_value().left().unwrap();
///
///     let _ = builder.build_return(result);
/// }
///
/// {
///     builder.position_at_end(catch_block);
///
///     // the personality function used by C++
///     let personality_function = {
///         let name = "__gxx_personality_v0";
///         let linkage = Some(Linkage::External);
///
///         module.add_function(name, context.i64_type().fn_type([]), linkage~)
///     };
///
///     // type of an exception in C++
///     let ptr_type = context.ptr_type(AddressSpace::default());
///     let i32_type = context.i32_type();
///     let exception_type = context.struct_type([ptr_type, i32_type]);
///
///     let null = ptr_type.const_zero();
///     let res = builder.build_landing_pad(exception_type, personality_function, [null], false, name="res");
///
///     // we handle the exception by returning a default value
///     builder.build_return(val=Some(f32_type.const_zero()));
/// }
/// ```
pub fn Builder::build_invoke(
  self : Builder,
  func : FunctionValue,
  args : Array[BasicValueEnum],
  then_block : BasicBlock,
  catch_block : BasicBlock,
  name~ : String = ""
) -> CallSiteValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  self.build_direct_invoke(func, args, then_block, catch_block, name~)
}

///| Build a direct invoke instruction.
pub fn Builder::build_direct_invoke(
  self : Builder,
  func : FunctionValue,
  args : Array[BasicValueEnum],
  then_block : BasicBlock,
  catch_block : BasicBlock,
  name~ : String = ""
) -> CallSiteValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let fty = func.get_type()
  let fn_val = func.value
  self.build_invoke_help(fty, fn_val, args, then_block, catch_block, name~)
}

///| Build an indirect invoke instruction.
pub fn Builder::build_indirect_invoke(
  self : Builder,
  fn_ty : FunctionType,
  fn_ptr : PointerValue,
  args : Array[BasicValueEnum],
  then_block : BasicBlock,
  catch_block : BasicBlock,
  name~ : String = ""
) -> CallSiteValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  self.build_invoke_help(
    fn_ty,
    fn_ptr.value,
    args,
    then_block,
    catch_block,
    name~,
  )
}

///|
fn Builder::build_invoke_help(
  self : Builder,
  fn_ty : FunctionType,
  fn_val : Value,
  args : Array[BasicValueEnum],
  then_block : BasicBlock,
  catch_block : BasicBlock,
  name~ : String = ""
) -> CallSiteValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let fn_ty_ref = fn_ty.as_type_ref()
  let fn_val_ref = fn_val.as_value_ref()
  let name = match fn_ty.get_return_type() {
    None => ""
    Some(_) => name
  }
  let args = args.map(fn(val) { val.as_value_ref() })
  let value = @unsafe.llvm_build_invoke2(
    self.as_builder_ref(),
    fn_ty_ref,
    fn_val_ref,
    args,
    then_block.as_bb_ref(),
    catch_block.as_bb_ref(),
    name,
  )
  CallSiteValue::new(value)
}

///| Landing pads are places where control flow jumps to if a [`Builder::build_invoke`] triggered an exception.
/// The landing pad will match the exception against its *clauses*. Depending on the clause
/// that is matched, the exception can then be handled, or resumed after some optional cleanup,
/// causing the exception to bubble up.
///
/// Exceptions in @unsafe.LLVM are designed based on the needs of a C++ compiler, but can be used more generally.
/// Here are some specific examples of landing pads. For a full example of handling an exception, see [`Builder::build_invoke`].
///
/// * **cleanup**: a cleanup landing pad is always visited when unwinding the stack.
///   A cleanup is extra code that needs to be run when unwinding a scope. C++ destructors are a typical example.
///   In a language with reference counting, the cleanup block can decrement the refcount of values in scope.
///   The [`Builder::build_resume`] function has a full example using a cleanup lading pad.
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("sum");
/// let builder = context.create_builder();
///
/// // type of an exception in C++
/// let i8_ptr_type = context.i8_type().ptr_type(AddressSpace::default());
/// let i32_type = context.i32_type();
/// let exception_type = context.struct_type([i8_ptr_type, i32_type]);
///
/// // the personality function used by C++
/// let personality_function = {
///     let name = "__gxx_personality_v0";
///     let linkage = Some(Linkage::External);
///
///     module.add_function(name, context.i64_type().fn_type([]), linkage~)
/// };
///
/// // make the cleanup landing pad
/// let res = builder.build_landing_pad( exception_type, personality_function, [], true, name="res");
/// ```
///
/// * **catch all**: An implementation of the C++ `catch(...)`, which catches all exceptions.
/// A catch clause with a NULL pointer value will match anything.
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("sum");
/// let builder = context.create_builder();
///
/// // type of an exception in C++
/// let i8_ptr_type = context.i8_type().ptr_type(AddressSpace::default());
/// let i32_type = context.i32_type();
/// let exception_type = context.struct_type([i8_ptr_type, i32_type]);
///
/// // the personality function used by C++
/// let personality_function = {
///     let name = "__gxx_personality_v0";
///     let linkage = Some(Linkage::External);
///
///     module.add_function(name, context.i64_type().fn_type([]), linkage~)
/// };
///
/// // make a null pointer of type i8
/// let null = i8_ptr_type.const_zero();
///
/// // make the catch all landing pad
/// let res = builder.build_landing_pad(exception_type, personality_function, [null], false, name="res");
/// ```
///
/// * **catch a type of exception**: Catch a specific type of exception. The example uses C++'s type info.
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("sum");
/// let builder = context.create_builder();
///
/// // type of an exception in C++
/// let i8_ptr_type = context.i8_type().ptr_type(AddressSpace::default());
/// let i32_type = context.i32_type();
/// let exception_type = context.struct_type([i8_ptr_type, i32_type]);
///
/// // the personality function used by C++
/// let personality_function = {
///     let name = "__gxx_personality_v0";
///     let linkage = Some(Linkage::External);
///
///     module.add_function(name, context.i64_type().fn_type([]), linkage~)
/// };
///
/// // link in the C++ type info for the `int` type
/// let type_info_int = module.add_global(i8_ptr_type, Some(AddressSpace::default()), "_ZTIi");
/// type_info_int.set_linkage(Linkage::External);
///
/// // make the catch landing pad
/// let clause = type_info_int.as_basic_value_enum();
/// let res = builder.build_landing_pad(exception_type, personality_function, [clause], false, name="res");
/// ```
///
/// * **filter**: A filter clause encodes that only some types of exceptions are valid at this
/// point. A filter clause is made by constructing a clause from a constant array.
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("sum");
/// let builder = context.create_builder();
///
/// // type of an exception in C++
/// let i8_ptr_type = context.i8_type().ptr_type(AddressSpace::default());
/// let i32_type = context.i32_type();
/// let exception_type = context.struct_type([i8_ptr_type, i32_type]);
///
/// // the personality function used by C++
/// let personality_function = {
///     let name = "__gxx_personality_v0";
///     let linkage = Some(Linkage::External);
///
///     module.add_function(name, context.i64_type().fn_type([]), linkage~)
/// };
///
/// // link in the C++ type info for the `int` type
/// let type_info_int = module.add_global(i8_ptr_type, Some(AddressSpace::default()), "_ZTIi");
/// type_info_int.set_linkage(Linkage::External);
///
/// // make the filter landing pad
/// let filter_pattern = i8_ptr_type.const_array([type_info_int.as_any_value_enum().into_pointer_value()]);
/// let res = builder.build_landing_pad(exception_type, personality_function, [filter_pattern], false, name="res");
/// ```
pub fn Builder::build_landing_pad(
  self : Builder,
  exception_type : &BasicType,
  personality_function : FunctionValue,
  clauses : Array[BasicValueEnum],
  is_cleanup : Bool,
  name~ : String = ""
) -> BasicValueEnum raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let num_clauses = clauses.length().reinterpret_as_uint()
  let value = @unsafe.llvm_build_landing_pad(
    self.as_builder_ref(),
    exception_type.as_type_ref(),
    personality_function.as_value_ref(),
    num_clauses,
    name,
  )
  for clause in clauses {
    @unsafe.llvm_add_clause(value, clause.as_value_ref())
  }
  @unsafe.llvm_set_cleanup(value, is_cleanup)
  BasicValueEnum::new(value)
}

///| Resume propagation of an existing (in-flight) exception whose unwinding was interrupted with a landingpad instruction.
///
/// This example uses a cleanup landing pad. A cleanup is extra code that needs to be run when
/// unwinding a scope. C++ destructors are a typical example. In a language with reference counting,
/// the cleanup block can decrement the refcount of values in scope.
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("sum");
/// let builder = context.create_builder();
///
/// let f32_type = context.f32_type();
/// let fn_type = f32_type.fn_type([]);
///
/// // we will pretend this function can throw an exception
/// let function = module.add_function("bomb", fn_type);
/// let basic_block = context.append_basic_block(function, name="entry");
///
/// builder.position_at_end(basic_block);
///
/// let pi = f32_type.const_float(@math.PI);
///
/// builder.build_return(val=Some(pi));
///
/// let function2 = module.add_function("wrapper", fn_type);
/// let basic_block2 = context.append_basic_block(function2, name="entry");
///
/// builder.position_at_end(basic_block2);
///
/// let then_block = context.append_basic_block(function2, name="then_block");
/// let catch_block = context.append_basic_block(function2, name="catch_block");
///
/// let call_site = builder.build_invoke(function, [], then_block, catch_block, name = "get_pi");
///
/// {
///     builder.position_at_end(then_block);
///
///     // in the then_block, the `call_site` value is defined and can be used
///     let result = call_site.try_as_basic_value().left().unwrap();
///
///     builder.build_return(val=Some(result));
/// }
///
/// {
///     builder.position_at_end(catch_block);
///
///     // the personality function used by C++
///     let personality_function = {
///         let name = "__gxx_personality_v0";
///         let linkage = Some(Linkage::External);
///
///         module.add_function(name, context.i64_type().fn_type([]), linkage~)
///     };
///
///     // type of an exception in C++
///     let i8_ptr_type = context.i8_type().ptr_type(AddressSpace::default());
///     let i32_type = context.i32_type();
///     let exception_type = context.struct_type([i8_ptr_type, i32_type]);
///
///     // make the landing pad; must give a concrete type to the slice
///     let res = builder.build_landing_pad(exception_type, personality_function, [], true, name="res");
///
///     // do cleanup ...
///
///     let _ = builder.build_resume(res);
/// }
/// ```
pub fn Builder::build_resume(
  self : Builder,
  value : &BasicValue
) -> InstructionValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value_ref = value.as_value_ref()
  let inst = @unsafe.llvm_build_resume(self.as_builder_ref(), value_ref)
  InstructionValue::new(inst)
}

///| Build a `getelementptr` instruction.
pub fn[T : BasicType] Builder::build_gep(
  self : Builder,
  pointee_ty : T,
  ptr : PointerValue,
  ordered_indices : Array[IntValue],
  name~ : String = ""
) -> PointerValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let ptr_ref = ptr.as_value_ref()
  let indices = ordered_indices.map(fn(v) { v.as_value_ref() })
  let value = @unsafe.llvm_build_gep2(
    self.as_builder_ref(),
    pointee_ty.as_type_ref(),
    ptr_ref,
    indices,
    name,
  )
  PointerValue::new(value)
}

///| Build a `getelementptr` instruction with inbounds flag.
pub fn Builder::build_in_bounds_gep(
  self : Builder,
  pointee_ty : &BasicType,
  ptr : PointerValue,
  ordered_indices : Array[IntValue],
  name~ : String = ""
) -> PointerValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let ptr_ref = ptr.as_value_ref()
  let indices = ordered_indices.map(fn(v) { v.as_value_ref() })
  let value = @unsafe.llvm_build_in_bounds_gep2(
    self.as_builder_ref(),
    pointee_ty.as_type_ref(),
    ptr_ref,
    indices,
    name,
  )
  PointerValue::new(value)
}

///| Builds a GEP instruction on a struct pointer. Returns `Err` `BuilderError::GEPPointee` or `BuilderError::GEPIndex` if input `PointerValue` doesn't
/// point to a struct or if index is out of bounds.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let builder = context.create_builder();
/// let module = context.create_module("struct_gep");
/// let void_type = context.void_type();
/// let i32_ty = context.i32_type();
/// let i32_ptr_ty = i32_ty.ptr_type(AddressSpace::default());
/// let field_types = [i32_ty, i32_ty];
/// let struct_ty = context.struct_type(field_types);
/// let struct_ptr_ty = struct_ty.ptr_type(AddressSpace::default());
/// let fn_type = void_type.fn_type([i32_ptr_ty, struct_ptr_ty]);
/// let fn_value = module.add_function("tmp_func", fn_type);
/// let entry = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry);
///
/// let i32_ptr = fn_value.get_first_param().unwrap().into_pointer_value();
/// let struct_ptr = fn_value.get_last_param().unwrap().into_pointer_value();
///
/// assert_true((try? builder.build_struct_gep(i32_ty, i32_ptr, 0)) is Err(_));
/// assert_true((try? builder.build_struct_gep(i32_ty, i32_ptr, 10)) is Err(_));
/// assert_true((try? builder.build_struct_gep(struct_ty, struct_ptr, 0)) is Ok(_));
/// assert_true((try? builder.build_struct_gep(struct_ty, struct_ptr, 1)) is Ok(_));
/// assert_true((try? builder.build_struct_gep(struct_ty, struct_ptr, 2)) is Err(_));
/// ```
pub fn[T : BasicType] Builder::build_struct_gep(
  self : Builder,
  pointee_ty : T,
  ptr : PointerValue,
  index : UInt,
  name~ : String = ""
) -> PointerValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let pointee_ty = pointee_ty.as_any_type_enum()
  if not(pointee_ty.is_struct_type()) {
    raise GEPPointee
  }
  let struct_ty = pointee_ty.into_struct_type()
  if index >= struct_ty.count_fields() {
    raise GEPIndex
  }
  let ptr_ref = ptr.as_value_ref()
  let value = @unsafe.llvm_build_struct_gep2(
    self.as_builder_ref(),
    pointee_ty.as_type_ref(),
    ptr_ref,
    index,
    name,
  )
  PointerValue::new(value)
}

///| Builds an instruction which calculates the difference of two pointers.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ret");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let i32_type = context.i32_type();
/// let i32_ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let fn_type = void_type.fn_type([i32_ptr_type, i32_ptr_type]);
/// let fn_value = module.add_function("ret", fn_type);
/// let entry = context.append_basic_block(fn_value, name="entry");
/// let i32_ptr_param1 = fn_value.get_first_param().unwrap().into_pointer_value();
/// let i32_ptr_param2 = fn_value.get_nth_param(1).unwrap().into_pointer_value();
///
/// builder.position_at_end(entry);
/// builder.build_ptr_diff(i32_ptr_type, i32_ptr_param1, i32_ptr_param2);
/// builder.build_return();
/// ```
pub fn Builder::build_ptr_diff(
  self : Builder,
  pointee_ty : &BasicType,
  lhs_ptr : PointerValue,
  rhs_ptr : PointerValue,
  name~ : String = ""
) -> IntValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ptr_ref = lhs_ptr.as_value_ref()
  let rhs_ptr_ref = rhs_ptr.as_value_ref()
  let value = @unsafe.llvm_build_ptr_diff2(
    self.as_builder_ref(),
    pointee_ty.as_type_ref(),
    lhs_ptr_ref,
    rhs_ptr_ref,
    name,
  )
  IntValue::new(value)
}

///| Builds a `phi` node.
pub fn[T : BasicType] Builder::build_phi(
  self : Builder,
  ty : T,
  name~ : String = ""
) -> PhiValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_phi(
    self.as_builder_ref(),
    ty.as_type_ref(),
    name,
  )
  PhiValue::new(value)
}

///| Builds a store instruction. It allows you to store a value of type `T` in a pointer to a type `T`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("ret");
/// let builder = context.create_builder();
/// let void_type = context.void_type();
/// let i32_type = context.i32_type();
/// let i32_ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let i32_seven = i32_type.const_int(7, false);
/// let fn_type = void_type.fn_type([i32_ptr_type]);
/// let fn_value = module.add_function("ret", fn_type);
/// let entry = context.append_basic_block(fn_value, name="entry");
/// let i32_ptr_param = fn_value.get_first_param().unwrap().into_pointer_value();
///
/// builder.position_at_end(entry);
/// builder.build_store(i32_ptr_param, i32_seven);
/// builder.build_return_void();
/// ```
pub fn Builder::build_store(
  self : Builder,
  ptr : PointerValue,
  val : &BasicValue
) -> InstructionValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let val_ref = val.as_value_ref()
  let ptr_ref = ptr.as_value_ref()
  let inst = @unsafe.llvm_build_store(self.as_builder_ref(), val_ref, ptr_ref)
  InstructionValue::new(inst)
}

// REVIEW: May be we need a `StorableValue` trait?

///|
pub fn Builder::build_store_func(
  self : Builder,
  ptr : PointerValue,
  func : FunctionValue
) -> InstructionValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let func_ref = func.as_value_ref()
  let ptr_ref = ptr.as_value_ref()
  let inst = @unsafe.llvm_build_store(self.as_builder_ref(), func_ref, ptr_ref)
  InstructionValue::new(inst)
}

///| Builds a load2 instruction. It allows you to retrieve a value of type `T` from a pointer to a type `T`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let lmodule = context.create_module("demo");
/// let builder = context.create_builder();
/// let i32_type = context.i32_type();
/// let i32_ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let fn_type = i32_type.fn_type([i32_ptr_type]);
/// let fn_value = module.add_function("ret", fn_type);
/// let entry = context.append_basic_block(fn_value, name="entry");
/// let i32_ptr_param = fn_value.get_first_param().unwrap().into_pointer_value();
///
/// builder.position_at_end(entry);
///
/// let pointee = builder.build_load(i32_type, i32_ptr_param).into_int_value();
///
/// let _ = builder.build_return(pointee);
/// ```
pub fn[T : BasicType] Builder::build_load(
  self : Builder,
  pointee_ty : T,
  ptr : PointerValue,
  name~ : String = ""
) -> BasicValueEnum raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let ptr_ref = ptr.as_value_ref()
  let value = @unsafe.llvm_build_load2(
    self.as_builder_ref(),
    pointee_ty.as_type_ref(),
    ptr_ref,
    name,
  )
  BasicValueEnum::new(value)
}

///| Build an `alloca` instruction, allocating memory on the stack.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("demo");
/// let builder = context.create_builder();
/// let i32_type = context.i32_type();
/// let fty = i32_type.fn_type([]);
/// let fn_value = module.add_function("foo", fty);
/// let entry = context.append_basic_block(fn_value, name="entry");
/// builder.position_at_end(entry);
///
/// let forty_two = i32_type.const_int(42);
/// let alloca = builder.build_alloca(i32_type, name="a");
/// let _ = builder.build_store(alloca, forty_two);
/// let load = builder.build_load(i32_type, alloca, name="b");
///
/// let _ = builder.build_return(load);
/// ```
pub fn[T : BasicType] Builder::build_alloca(
  self : Builder,
  ty : T,
  name~ : String = ""
) -> PointerValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_alloca(
    self.as_builder_ref(),
    ty.as_type_ref(),
    name,
  )
  PointerValue::new(value)
}

///| Build an `alloca` instruction, allocating memory on the stack.
pub fn[T : BasicType, V : BasicValue] Builder::build_array_alloca(
  self : Builder,
  ty : T,
  size : V,
  name~ : String = ""
) -> PointerValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let size_ref = size.as_value_ref()
  let value = @unsafe.llvm_build_array_alloca(
    self.as_builder_ref(),
    ty.as_type_ref(),
    size_ref,
    name,
  )
  PointerValue::new(value)
}

///| Build a [memcpy](https://llvm.org/docs/LangRef.html#llvm-memcpy-intrinsic) instruction.
///
/// Alignment arguments are specified in bytes, and should always be
/// both a power of 2 and under 2^64.
///
/// The final argument should be a pointer-sized integer.
///
/// Returns an `Err(BuilderError::AlignmentError)` if the source or destination alignments are not a power of 2.
pub fn Builder::build_memcpy(
  self : Builder,
  dest : PointerValue,
  dst_align : UInt,
  src : PointerValue,
  src_align : UInt,
  size : IntValue
) -> PointerValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  if not(is_alignment_ok(dst_align)) {
    raise AlignmentError(
      "The dest_align_bytes argument to build_memcpy was not a power of 2.",
    )
  }
  if not(is_alignment_ok(src_align)) {
    raise AlignmentError(
      "The src_align_bytes argument to build_memcpy was not a power of 2.",
    )
  }
  let dest_ref = dest.as_value_ref()
  let src_ref = src.as_value_ref()
  let value = @unsafe.llvm_build_mem_cpy(
    self.as_builder_ref(),
    dest_ref,
    dst_align,
    src_ref,
    src_align,
    size.as_value_ref(),
  )
  PointerValue::new(value)
}

///| Build a [memmove](http://llvm.org/docs/LangRef.html#llvm-memmove-intrinsic) instruction.
///
/// Alignment arguments are specified in bytes, and should always be
/// both a power of 2 and under 2^64.
///
/// The final argument should be a pointer-sized integer.
///
/// Returns an `Err(BuilderError::AlignmentError)` if the source or destination alignments are not a power of 2 under 2^64.
pub fn Builder::build_memmove(
  self : Builder,
  dest : PointerValue,
  dst_align : UInt,
  src : PointerValue,
  src_align : UInt,
  size : IntValue
) -> PointerValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  if not(is_alignment_ok(dst_align)) {
    raise AlignmentError(
      "The dest_align_bytes argument to build_memmove was not a power of 2.",
    )
  }
  if not(is_alignment_ok(src_align)) {
    raise AlignmentError(
      "The src_align_bytes argument to build_memmove was not a power of 2.",
    )
  }
  let value = @unsafe.llvm_build_mem_move(
    self.as_builder_ref(),
    dest.as_value_ref(),
    dst_align,
    src.as_value_ref(),
    src_align,
    size.as_value_ref(),
  )
  PointerValue::new(value)
}

///| Build a [memset](http://llvm.org/docs/LangRef.html#llvm-memset-intrinsics) instruction.
///
/// Alignment arguments are specified in bytes, and should always be
/// both a power of 2 and under 2^64.
///
/// The final argument should be a pointer-sized integer.
///
/// Returns an `Err(BuilderError::AlignmentError)` if the source alignment is not a power of 2 under 2^64.
pub fn Builder::build_memset(
  self : Builder,
  dest : PointerValue,
  dest_align : UInt,
  val : IntValue,
  size : IntValue
) -> PointerValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  if not(is_alignment_ok(dest_align)) {
    raise AlignmentError(
      "The dest_align_bytes argument to build_memset was not a power of 2.",
    )
  }
  let value = @unsafe.llvm_build_mem_set(
    self.as_builder_ref(),
    dest.as_value_ref(),
    val.as_value_ref(),
    size.as_value_ref(),
    dest_align,
  )
  PointerValue::new(value)
}

///| Build a malloc instruction. Allocates memory on the heap.
pub fn[T : BasicType] Builder::build_malloc(
  self : Builder,
  ty : T,
  name~ : String = ""
) -> PointerValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  if not(ty.as_type().is_sized()) {
    raise AlignmentError("Cannot build malloc call for an unsized type")
  }
  let value = @unsafe.llvm_build_malloc(
    self.as_builder_ref(),
    ty.as_type_ref(),
    name,
  )
  PointerValue::new(value)
}

///| Build a malloc instruction. Allocates memory on the heap.
pub fn Builder::build_array_malloc(
  self : Builder,
  ty : &BasicType,
  size : IntValue,
  name~ : String = ""
) -> PointerValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  if not(ty.as_type().is_sized()) {
    raise AlignmentError("Cannot build array malloc call for an unsized type")
  }
  let value = @unsafe.llvm_build_array_malloc(
    self.as_builder_ref(),
    ty.as_type_ref(),
    size.as_value_ref(),
    name,
  )
  PointerValue::new(value)
}

///| Build a free instruction. Frees memory allocated by malloc.
pub fn Builder::build_free(
  self : Builder,
  ptr : PointerValue
) -> InstructionValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_free(self.as_builder_ref(), ptr.as_value_ref())
  InstructionValue::new(value)
}

///| Insert an instruction after the given instruction.
pub fn Builder::insert_instruction(
  self : Builder,
  inst : InstructionValue,
  name : String?
) -> Unit {
  match name {
    Some(name) =>
      @unsafe.llvm_insert_into_builder_with_name(
        self.as_builder_ref(),
        inst.as_value_ref(),
        name,
      )
    None =>
      @unsafe.llvm_insert_into_builder(
        self.as_builder_ref(),
        inst.as_value_ref(),
      )
  }
}

///| Build an unsigned integer division instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("udiv", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_nth_param(0).unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_int_unsigned_div(lhs, rhs, name="res");
/// inspect(res, content="  %res = udiv i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_int_unsigned_div(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_u_div(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

///| Build a signed integer division instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("sdiv", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_nth_param(0).unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_int_signed_div(lhs, rhs, name="res");
/// inspect(res, content="  %res = sdiv i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_int_signed_div(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_s_div(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

///| Build an signed integer division instruction with `exact` flag.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("sdiv", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_nth_param(0).unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_int_exact_signed_div(
///   lhs, rhs, name="res");
/// inspect(res, content="  %res = sdiv exact i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_int_exact_signed_div(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_exact_s_div(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

///| Build an unsigned integer rem instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("urem", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_nth_param(0).unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_int_unsigned_rem(lhs, rhs, name="res");
/// inspect(res, content="  %res = urem i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_int_unsigned_rem(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_u_rem(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

///| Build a signed integer rem instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("srem", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_nth_param(0).unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_int_signed_rem(lhs, rhs, name="res");
/// inspect(res, content="  %res = srem i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_int_signed_rem(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_s_rem(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

// 2025.1.29, moonbit didn't not support type in trait, hence need to think
// how to implement this
// pub fn Builder::build_int_s_extend[T: IntMathValue] (
//   self: Builder,
//   int_value: T,
//   int_type: 
// )

///|
pub fn Builder::build_address_space_cast(
  self : Builder,
  ptr_val : PointerValue,
  ptr_type : PointerType,
  name~ : String = ""
) -> PointerValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let ptr_val_ref = ptr_val.as_value_ref()
  let ptr_type_ref = ptr_type.as_type_ref()
  let value = @unsafe.llvm_build_addr_space_cast(
    self.as_builder_ref(),
    ptr_val_ref,
    ptr_type_ref,
    name,
  )
  PointerValue::new(value)
}

///| Build BitCast instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let f32_ty = context.f32_type();
/// let fty = i32_ty.fn_type([f32_ty]);
/// let fval = lmodule.add_function("bit_cast", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let operand = fval.get_first_param().unwrap().into_int_value();
///
/// let res = builder.build_bit_cast(operand, f32_ty, name="res");
/// inspect(res, content="  %res = bitcast i32 %0 to float");
/// ```
// REVIEW: Do we need to check bitwidth?
pub fn[BV : BasicValue, BT : BasicType] Builder::build_bit_cast(
  self : Builder,
  val : BV,
  ty : BT,
  name~ : String = ""
) -> BasicValueEnum raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let builder_ref = self.as_builder_ref()
  let val_ref = val.as_value_ref()
  let ty_ref = ty.as_type_ref()
  let value = @unsafe.llvm_build_bit_cast(builder_ref, val_ref, ty_ref, name)
  BasicValueEnum::new(value)
}

// pub fn build_int_s_extend_or_bit_cast<T: IntMathValue<'ctx>>(
// pub fn build_int_z_extend<T: IntMathValue<'ctx>>(
// pub fn build_int_z_extend_or_bit_cast<T: IntMathValue<'ctx>>(
// pub fn build_int_truncate<T: IntMathValue<'ctx>>(
// pub fn build_int_truncate_or_bit_cast<T: IntMathValue<'ctx>>(

///| Builder floating point rem instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let f32_ty = context.f32_type();
/// let fty = f32_ty.fn_type([f32_ty, f32_ty]);
/// let fval = lmodule.add_function("rem", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_nth_param(0).unwrap().into_float_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_float_value();
///
/// let res = builder.build_float_rem(lhs, rhs, name="res");
/// inspect(res, content="  %res = frem float %0, %1");
/// ```
pub fn[T : FloatMathValue] Builder::build_float_rem(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_f_rem(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

// pub fn build_float_to_unsigned_int<T: FloatMathValue<'ctx>>(
// pub fn build_float_to_signed_int<T: FloatMathValue<'ctx>>(
// pub fn build_unsigned_int_to_float<T: IntMathValue<'ctx>>(
// pub fn build_signed_int_to_float<T: IntMathValue<'ctx>>(
// pub fn build_float_trunc<T: FloatMathValue<'ctx>>(
// pub fn build_float_ext<T: FloatMathValue<'ctx>>(
// pub fn build_float_cast<T: FloatMathValue<'ctx>>(
// pub fn build_int_cast<T: IntMathValue<'ctx>>(
// pub fn build_int_cast_sign_flag<T: IntMathValue<'ctx>>(

///| Builder floating point division instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let f32_ty = context.f32_type();
/// let fty = f32_ty.fn_type([f32_ty, f32_ty]);
/// let fval = lmodule.add_function("div", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_nth_param(0).unwrap().into_float_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_float_value();
///
/// let res = builder.build_float_div(lhs, rhs, name="res");
/// inspect(res, content="  %res = fdiv float %0, %1");
/// ```
pub fn Builder::build_float_div(
  self : Builder,
  lhs : FloatValue,
  rhs : FloatValue,
  name~ : String = ""
) -> FloatValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_f_div(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  FloatValue::new(value)
}

///| Build integer addition instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("add", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_first_param().unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_int_add(lhs, rhs, name="res");
/// inspect(res, content="  %res = add i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_int_add(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_add(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

///| Build integer add instruction with NSW flag.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("add", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_first_param().unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_int_nsw_add(lhs, rhs, name="res");
/// inspect(res, content="  %res = add nsw i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_int_nsw_add(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_nsw_add(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

///| Build integer add instruction with NUW flag.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("add", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_first_param().unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_int_nuw_add(lhs, rhs, name="res");
/// inspect(res, content="  %res = add nuw i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_int_nuw_add(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_nuw_add(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

///| Builder floating point addition instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let f32_ty = context.f32_type();
/// let fty = f32_ty.fn_type([f32_ty, f32_ty]);
/// let fval = lmodule.add_function("add", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_nth_param(0).unwrap().into_float_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_float_value();
///
/// let res = builder.build_float_add(lhs, rhs, name="res");
/// inspect(res, content="  %res = fadd float %0, %1");
/// ```
pub fn[T : FloatMathValue] Builder::build_float_add(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_f_add(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

///| Build integer XOR instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("add", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_first_param().unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_int_xor(lhs, rhs, name="res");
/// inspect(res, content="  %res = xor i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_xor(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_xor(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

///| Build integer AND instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("add", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_first_param().unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_int_and(lhs, rhs, name="res");
/// inspect(res, content="  %res = and i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_and(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_and(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

///| Build integer OR instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("add", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_first_param().unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_int_or(lhs, rhs, name="res");
/// inspect(res, content="  %res = or i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_or(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_or(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

///| Build integer Logical Left Shift instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("add", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_first_param().unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_left_shift(lhs, rhs, name="res");
/// inspect(res, content = "  %res = shl i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_left_shift(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_shl(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

///| Build integer Logical Left Shift instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("add", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_first_param().unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let lshr = builder.build_right_shift(
///     lhs, rhs, sign_extend=false, name="lshr");
/// inspect(lshr, content = "  %lshr = lshr i32 %0, %1");
/// let ashr = builder.build_right_shift(
///     lhs, rhs, sign_extend=true, name="ashr");
/// inspect(ashr, content = "  %ashr = ashr i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_right_shift(
  self : Builder,
  lhs : T,
  rhs : T,
  sign_extend~ : Bool = true,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let val = if sign_extend {
    @unsafe.llvm_build_a_shr(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  } else {
    @unsafe.llvm_build_l_shr(self.as_builder_ref(), lhs_ref, rhs_ref, name)
  }
  T::new(val)
}

///| Build integer sub instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("add", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_first_param().unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_int_sub(lhs, rhs, name="res");
/// inspect(res, content="  %res = sub i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_int_sub(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_sub(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

///| Build integer sub instruction with NSW flag.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("add", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_first_param().unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_int_nsw_sub(lhs, rhs, name="res");
/// inspect(res, content="  %res = sub nsw i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_int_nsw_sub(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_nsw_sub(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

///| Build integer sub instruction with NUW flag.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("add", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_first_param().unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_int_nuw_sub(lhs, rhs, name="res");
/// inspect(res, content="  %res = sub nuw i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_int_nuw_sub(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_nuw_sub(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

///| Builder floating point sub instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let f32_ty = context.f32_type();
/// let fty = f32_ty.fn_type([f32_ty, f32_ty]);
/// let fval = lmodule.add_function("sub", fval);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_nth_param(0).unwrap().into_float_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_float_value();
///
/// let res = builder.build_float_sub(lhs, rhs, name="res");
/// inspect(res, content="  %res = fsub float %0, %1");
/// ```
pub fn[T : FloatMathValue] Builder::build_float_sub(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_f_sub(
    self.as_builder_ref(),
    lhs_ref,
    rhs_ref,
    name,
  )
  T::new(value)
}

///| Build integer multiplication instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("add", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_first_param().unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_int_mul(lhs, rhs, name="res");
/// inspect(res, content="  %res = mul i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_int_mul(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs = lhs.as_value_ref()
  let rhs = rhs.as_value_ref()
  let value = @unsafe.llvm_build_mul(self.as_builder_ref(), lhs, rhs, name)
  T::new(value)
}

///| Build integer multiplication instruction with NSW flag.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("add", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_first_param().unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_int_nsw_mul(lhs, rhs, name="res");
/// inspect(res, content="  %res = mul nsw i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_int_nsw_mul(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs = lhs.as_value_ref()
  let rhs = rhs.as_value_ref()
  let value = @unsafe.llvm_build_nsw_mul(self.as_builder_ref(), lhs, rhs, name)
  T::new(value)
}

///| Build integer multiplication instruction with NUW flag.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("add", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_first_param().unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let res = builder.build_int_nuw_mul(lhs, rhs, name="res");
/// inspect(res, content="  %res = mul nuw i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_int_nuw_mul(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs = lhs.as_value_ref()
  let rhs = rhs.as_value_ref()
  let value = @unsafe.llvm_build_nuw_mul(self.as_builder_ref(), lhs, rhs, name)
  T::new(value)
}

///| Builder floating point multiplication instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let f32_ty = context.f32_type();
/// let fty = f32_ty.fn_type([f32_ty, f32_ty]);
/// let fval = lmodule.add_function("mul", fval);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_nth_param(0).unwrap().into_float_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_float_value();
///
/// let res = builder.build_float_mul(lhs, rhs, name="res");
/// inspect(res, content="  %res = fmul float %0, %1");
/// ```
pub fn[T : FloatMathValue] Builder::build_float_mul(
  self : Builder,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs = lhs.as_value_ref()
  let rhs = rhs.as_value_ref()
  let value = @unsafe.llvm_build_f_mul(self.as_builder_ref(), lhs, rhs, name)
  T::new(value)
}

///|
pub fn[T : BasicValue] Builder::build_binop(
  self : Builder,
  op : InstructionOpcode,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> BasicValueEnum raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let lhs_ref = lhs.as_value_ref()
  let rhs_ref = rhs.as_value_ref()
  let value = @unsafe.llvm_build_bin_op(
    self.as_builder_ref(),
    op.into(),
    lhs_ref,
    rhs_ref,
    name,
  )
  BasicValueEnum::new(value)
}

///|
pub fn[T : BasicType, V : BasicValue] Builder::build_cast(
  self : Builder,
  op : InstructionOpcode,
  from_value : V,
  to_type : T,
  name~ : String = ""
) -> BasicValueEnum raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let val = @unsafe.llvm_build_cast(
    self.as_builder_ref(),
    op.into(),
    from_value.as_value_ref(),
    to_type.as_type_ref(),
    name,
  )
  BasicValueEnum::new(val)
}

// pub fn Builder::build_pointer_cast[T: PointerMathValue](
//   self: Builder, from: T, to:T::BaseType, name~: String = ""
// ) -> T!BuilderError {
//   guard self.get_positioned() is Set else {
//     raise UnsetPosition
//   }
//
//   let from_ref = from.as_value_ref()
//   let to_ref = to.as_type_ref()
//   let value = @unsafe.llvm_build_pointer_cast(self.as_builder_ref(), from_ref, to_ref, name)
//   T::new(value)
// }

///| Build integer comparison instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty, i32_ty]);
/// let fval = lmodule.add_function("add", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_nth_param(0).unwrap().into_int_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_int_value();
///
/// let pred_eq = @llvm.IntPredicate::EQ;
/// let res = builder.build_int_compare(pred_eq, lhs, rhs, name="res");
/// inspect(res, content="  %res = icmp eq i32 %0, %1");
/// ```
pub fn[T : IntMathValue] Builder::build_int_compare(
  self : Builder,
  op : IntPredicate,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let val_ref = @unsafe.llvm_build_icmp(
    self.as_builder_ref(),
    op.into(),
    lhs.as_value_ref(),
    rhs.as_value_ref(),
    name,
  )
  T::new(val_ref)
}

///|
pub fn Builder::build_ptr_compare(
  self : Builder,
  op : IntPredicate,
  lhs : PointerValue,
  rhs : PointerValue,
  name~ : String = ""
) -> IntValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let val_ref = @unsafe.llvm_build_icmp(
    self.as_builder_ref(),
    op.into(),
    lhs.as_value_ref(),
    rhs.as_value_ref(),
    name,
  )
  IntValue::new(val_ref)
}

///| Build integer comparison instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let f32_ty = context.f32_type();
/// let fty = i32_ty.fn_type([f32_ty, f32_ty]);
/// let fval = lmodule.add_function("add", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let lhs = fval.get_nth_param(0).unwrap().into_float_value();
/// let rhs = fval.get_nth_param(1).unwrap().into_float_value();
///
/// let pred_oeq = @llvm.FloatPredicate::OEQ;
/// let res = builder.build_int_compare(pred_oeq, lhs, rhs, name="res");
/// inspect(res, content="  %res = fcmp oeq float %0, %1");
/// ```
pub fn[T : FloatMathValue] Builder::build_float_compare(
  self : Builder,
  op : FloatPredicate,
  lhs : T,
  rhs : T,
  name~ : String = ""
) -> IntValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let val_ref = @unsafe.llvm_build_fcmp(
    self.as_builder_ref(),
    op.into(),
    lhs.as_value_ref(),
    rhs.as_value_ref(),
    name,
  )
  IntValue::new(val_ref)
}

///|
pub fn Builder::build_unconditional_branch(
  self : Builder,
  destination_block : BasicBlock
) -> InstructionValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_br(
    self.as_builder_ref(),
    destination_block.bb_ref,
  )
  InstructionValue::new(value)
}

///|
pub fn Builder::build_conditional_branch(
  self : Builder,
  comparison : IntValue,
  then_block : BasicBlock,
  else_block : BasicBlock
) -> InstructionValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_cond_br(
    self.as_builder_ref(),
    comparison.as_value_ref(),
    then_block.bb_ref,
    else_block.bb_ref,
  )
  InstructionValue::new(value)
}

///|
pub fn Builder::build_indirect_branch(
  self : Builder,
  address : BasicValueEnum,
  destinations : Array[BasicBlock]
) -> InstructionValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_indirect_br(
    self.as_builder_ref(),
    address.as_value_ref(),
    destinations.length().reinterpret_as_uint(),
  )
  for destination in destinations {
    @unsafe.llvm_add_destination(value, destination.as_bb_ref())
  }
  InstructionValue::new(value)
}

///| Build integer sub instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty]);
/// let fval = lmodule.add_function("neg", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let operand = fval.get_first_param().unwrap().into_int_value();
///
/// let res = builder.build_int_neg(operand, name="res");
/// inspect(res, content="  %res = sub i32 0, %0");
/// ```
pub fn[T : IntMathValue] Builder::build_int_neg(
  self : Builder,
  value : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_neg(
    self.as_builder_ref(),
    value.as_value_ref(),
    name,
  )
  T::new(value)
}

///| Build integer sub instruction with NSW flag.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty]);
/// let fval = lmodule.add_function("neg", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let operand = fval.get_first_param().unwrap().into_int_value();
///
/// let res = builder.build_int_nsw_neg(operand, name="res");
/// inspect(res, content="  %res = sub nsw i32 0, %0");
/// ```
pub fn[T : IntMathValue] Builder::build_int_nsw_neg(
  self : Builder,
  value : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_nsw_neg(
    self.as_builder_ref(),
    value.as_value_ref(),
    name,
  )
  T::new(value)
}

///|
/// @alert LLVMDeprecated "LLVM deprecated build_nuw_neg"
pub fn[T : IntMathValue] Builder::build_int_nuw_neg(
  self : Builder,
  value : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_nuw_neg(
    self.as_builder_ref(),
    value.as_value_ref(),
    name,
  )
  T::new(value)
}

///| Build a floating point negation instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let f32_ty = context.f32_type();
/// let fty = f32_ty.fn_type([f32_ty]);
/// let fval = lmodule.add_function("neg", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let operand = fval.get_first_param().unwrap().into_float_value();
///
/// let res = builder.build_float_neg(operand, name="res");
/// inspect(res, content="  %res = fsub float 0.0, %0");
/// ```
pub fn[T : FloatMathValue] Builder::build_float_neg(
  self : Builder,
  value : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_f_neg(
    self.as_builder_ref(),
    value.as_value_ref(),
    name,
  )
  T::new(value)
}

///| Build integer NOT instruction.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let fty = i32_ty.fn_type([i32_ty]);
/// let fval = lmodule.add_function("not", fty);
/// let entry_bb = context.append_basic_block(fval, name="entry");
/// let builder = context.create_builder();
/// builder.position_at_end(entry_bb);
///
/// let operand = fval.get_first_param().unwrap().into_int_value();
///
/// let res = builder.build_not(operand, name="res");
/// inspect(res, content="  %res = xor i32 %0, -1");
/// ```
pub fn[T : IntMathValue] Builder::build_not(
  self : Builder,
  value : T,
  name~ : String = ""
) -> T raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_not(
    self.as_builder_ref(),
    value.as_value_ref(),
    name,
  )
  T::new(value)
}

///|
pub fn Builder::position_at(
  self : Builder,
  basic_block : BasicBlock,
  instruction : InstructionValue
) -> Unit {
  let builder_ref = self.as_builder_ref()
  let bb_ref = basic_block.as_bb_ref()
  let inst_ref = instruction.as_value_ref()
  @unsafe.llvm_position_builder(builder_ref, bb_ref, inst_ref)
}

///|
pub fn Builder::position_before(
  self : Builder,
  instruction : InstructionValue
) -> Unit {
  let builder_ref = self.as_builder_ref()
  let inst_ref = instruction.as_value_ref()
  @unsafe.llvm_position_builder_before(builder_ref, inst_ref)
}

///|
pub fn Builder::position_at_end(self : Builder, bb : BasicBlock) -> Unit {
  let builder_ref = self.builder_ref
  let bb_ref = bb.bb_ref
  self.positioned = PositionState::Set
  @unsafe.llvm_position_builder_at_end(builder_ref, bb_ref)
}

///| Builds an extract value instruction which extracts a `BasicValueEnum` from a struct or array.
///
/// Raise `Err(BuilderError::ExtractOutOfRange)` if the provided index is out of bounds of the aggregate value length.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("av");
/// let void_type = context.void_type();
/// let f32_type = context.f32_type();
/// let i32_type = context.i32_type();
/// let struct_type = context.struct_type([i32_type, f32_type]);
/// let array_type = i32_type.array_type(3);
/// let fn_type = void_type.fn_type([]);
/// let fn_value = module.add_function("av_fn", fn_type);
/// let builder = context.create_builder();
/// let entry = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry);
///
/// let array_alloca = builder.build_alloca(array_type);
///
/// let array = builder.build_load(i32_type, array_alloca).into_array_value();
///
/// let const_int1 = i32_type.const_int(2, false);
/// let const_int2 = i32_type.const_int(5, false);
/// let const_int3 = i32_type.const_int(6, false);
///
/// let _ = builder.build_insert_value(array, const_int1, 0);
/// let _ = builder.build_insert_value(array, const_int2, 1);
/// let _ = builder.build_insert_value(array, const_int3, 2);
/// // builder.build_insert_value(array, const_int3, 3);
///
/// assert_true(builder.build_extract_value(array, 0).is_int_value());
/// assert_true(builder.build_extract_value(array, 1).is_int_value());
/// assert_true(builder.build_extract_value(array, 2).is_int_value());
/// // builder.build_extract_value(array, 3);
/// ```
pub fn[AV : AggregateValue] Builder::build_extract_value(
  self : Builder,
  agg : AV,
  index : UInt,
  name~ : String = ""
) -> BasicValueEnum raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let size = match agg.as_aggregate_value_enum() {
    AggregateValueEnum::ArrayValue(av) => av.get_type().length()
    AggregateValueEnum::StructValue(sv) => sv.get_type().count_fields()
  }
  if index >= size {
    raise ExtractOutOfRange
  }
  let value = @unsafe.llvm_build_extract_value(
    self.as_builder_ref(),
    agg.as_value_ref(),
    index,
    name,
  )
  BasicValueEnum::new(value)
}

///| Builds an insert value instruction which inserts a `BasicValue` into a struct
/// or array and returns the resulting aggregate value.
///
/// Returns `Err(BuilderError::ExtractOutOfRange)` if the provided index is out of bounds of the aggregate value length.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("av");
/// let void_type = context.void_type();
/// let f32_type = context.f32_type();
/// let i32_type = context.i32_type();
/// let struct_type = context.struct_type([i32_type, f32_type]);
/// let array_type = i32_type.array_type(3);
/// let fn_type = void_type.fn_type([]);
/// let fn_value = module.add_function("av_fn", fn_type);
/// let builder = context.create_builder();
/// let entry = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry);
///
/// let array_alloca = builder.build_alloca(array_type, name="array_alloca");
/// let array = builder.build_load(i32_type, array_alloca, name="array_load").into_array_value();
///
/// let const_int1 = i32_type.const_int(2, false);
/// let const_int2 = i32_type.const_int(5, false);
/// let const_int3 = i32_type.const_int(6, false);
///
/// let _ = builder.build_insert_value(array, const_int1, 0);
/// let _ = builder.build_insert_value(array, const_int2, 1);
/// let _ = builder.build_insert_value(array, const_int3, 2);
/// let _ = builder.build_insert_value(array, const_int3, 3);
/// ```
pub fn[AV : AggregateValue, BV : BasicValue] Builder::build_insert_value(
  self : Builder,
  agg : AV,
  value : BV,
  index : UInt,
  name~ : String = ""
) -> AggregateValueEnum raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let size = match agg.as_aggregate_value_enum() {
    AggregateValueEnum::ArrayValue(av) => av.get_type().length()
    AggregateValueEnum::StructValue(sv) => sv.get_type().count_fields()
  }
  if index >= size {
    raise ExtractOutOfRange
  }
  let value = @unsafe.llvm_build_insert_value(
    self.as_builder_ref(),
    agg.as_value_ref(),
    value.as_value_ref(),
    index,
    name,
  )
  AggregateValueEnum::new(value)
}

///| Builds an extract element instruction which extracts a `BasicValueEnum` from a vector.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("av");
/// let i32_type = context.i32_type();
/// let i32_zero = i32_type.const_int(0, false);
/// let vec_type = i32_type.vec_type(2);
/// let fn_type = i32_type.fn_type([vec_type]);
/// let fn_value = module.add_function("vec_fn", fn_type);
/// let builder = context.create_builder();
/// let entry = context.append_basic_block(fn_value, name="entry");
/// let vector_param = fn_value.get_first_param().unwrap().into_vector_value();
///
/// builder.position_at_end(entry);
///
/// let extracted = builder.build_extract_element(vector_param, i32_zero, name="insert");
///
/// let _ = builder.build_return(extracted);
/// ```
pub fn Builder::build_extract_element(
  self : Builder,
  vector : VectorValue,
  index : IntValue,
  name~ : String = ""
) -> BasicValueEnum raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_extract_element(
    self.as_builder_ref(),
    vector.as_value_ref(),
    index.as_value_ref(),
    name,
  )
  BasicValueEnum::new(value)
}

///| Builds an insert element instruction which inserts a `BasicValue` into a vector and returns the resulting vector.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("av");
/// let void_type = context.void_type();
/// let i32_type = context.i32_type();
/// let i32_zero = i32_type.const_int(0);
/// let i32_seven = i32_type.const_int(7);
/// let vec_type = i32_type.vec_type(2);
/// let fn_type = void_type.fn_type([vec_type]);
/// let fn_value = module.add_function("vec_fn", fn_type);
/// let builder = context.create_builder();
/// let entry = context.append_basic_block(fn_value, name="entry");
/// let vector_param = fn_value.get_first_param().unwrap().into_vector_value();
///
/// builder.position_at_end(entry);
/// builder.build_insert_element(vector_param, i32_seven, i32_zero, name="insert");
/// let _ = builder.build_return_void();
/// ```
pub fn[V : BasicValue, W : VectorBaseValue] Builder::build_insert_element(
  self : Builder,
  vector : W,
  element : V,
  index : IntValue,
  name~ : String = ""
) -> W raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_insert_element(
    self.as_builder_ref(),
    vector.as_value_ref(),
    element.as_value_ref(),
    index.as_value_ref(),
    name,
  )
  W::new(value)
}

///|
pub fn Builder::build_unreachable(
  self : Builder
) -> InstructionValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_unreachable(self.as_builder_ref())
  InstructionValue::new(value)
}

///|
pub fn Builder::build_fence(
  self : Builder,
  atomic_ordering : AtomicOrdering,
  single_thread : Bool,
  name~ : String = ""
) -> InstructionValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_fence(
    self.as_builder_ref(),
    atomic_ordering.into(),
    single_thread,
    name,
  )
  InstructionValue::new(value)
}

///|
pub fn[T : PointerMathValue] Builder::build_is_null(
  self : Builder,
  ptr : T,
  name~ : String = ""
) -> IntValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_is_null(
    self.as_builder_ref(),
    ptr.as_value_ref(),
    name,
  )
  IntValue::new(value)
}

// // SubType: <I, P>(&self, int: &IntValue<I>, ptr_type: &PointerType<P>, name) -> PointerValue<P> {
// pub fn build_int_to_ptr<T: IntMathValue<'ctx>>(
//     &self,
//     int: T,
//     ptr_type: <T::BaseType as IntMathType<'ctx>>::PtrConvType,
//     name: &str,
// ) -> Result<<<T::BaseType as IntMathType<'ctx>>::PtrConvType as PointerMathType<'ctx>>::ValueType, BuilderError>
// {
//     if self.positioned.get() != PositionState::Set {
//         return Err(BuilderError::UnsetPosition);
//     }
//     let c_string = to_c_str(name);
//
//     let value =
//         @unsafe.LLVMBuildIntToPtr(
//             self.builder,
//             int.as_value_ref(),
//             ptr_type.as_type_ref(),
//             c_string.as_ptr(),
//         )
//     ;
//
//     unsafe { Ok(<<T::BaseType as IntMathType>::PtrConvType as PointerMathType>::ValueType::new(value)) }
// }

// // SubType: <I, P>(&self, ptr: &PointerValue<P>, int_type: &IntType<I>, name) -> IntValue<I> {
// pub fn build_ptr_to_int<T: PointerMathValue<'ctx>>(
//     &self,
//     ptr: T,
//     int_type: <T::BaseType as PointerMathType<'ctx>>::PtrConvType,
//     name: &str,
// ) -> Result<<<T::BaseType as PointerMathType<'ctx>>::PtrConvType as IntMathType<'ctx>>::ValueType, BuilderError>
// {
//     if self.positioned.get() != PositionState::Set {
//         return Err(BuilderError::UnsetPosition);
//     }
//     let c_string = to_c_str(name);
//
//     let value =
//         @unsafe.LLVMBuildPtrToInt(
//             self.builder,
//             ptr.as_value_ref(),
//             int_type.as_type_ref(),
//             c_string.as_ptr(),
//         )
//     ;
//
//     Ok(<<T::BaseType as PointerMathType>::PtrConvType as IntMathType>::ValueType::new(value))
// }

///|
pub fn Builder::clear_insertion_position(self : Builder) -> Unit {
  self.positioned = PositionState::NotSet
  @unsafe.llvm_clear_insertion_position(self.builder_ref)
}

///|
pub fn Builder::build_switch(
  self : Builder,
  value : IntValue,
  else_block : BasicBlock,
  cases : Array[(IntValue, BasicBlock)]
) -> InstructionValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_switch(
    self.as_builder_ref(),
    value.as_value_ref(),
    else_block.as_bb_ref(),
    cases.length().reinterpret_as_uint(),
  )
  cases.each(fn(pair) {
    let (case_value, case_block) = pair
    @unsafe.llvm_add_case(
      value,
      case_value.as_value_ref(),
      case_block.as_bb_ref(),
    )
  })
  InstructionValue::new(value)
}

///|
pub fn[BV : BasicValue, IMV : IntMathValue] Builder::build_select(
  self : Builder,
  condition : IMV,
  then : BV,
  else_ : BV,
  name~ : String = ""
) -> BasicValueEnum raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_select(
    self.as_builder_ref(),
    condition.as_value_ref(),
    then.as_value_ref(),
    else_.as_value_ref(),
    name,
  )
  BasicValueEnum::new(value)
}

///|
pub fn Builder::build_global_string(
  self : Builder,
  value : String,
  name~ : String = ""
) -> GlobalValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_global_string(
    self.as_builder_ref(),
    value,
    name,
  )
  GlobalValue::new(value)
}

///|
pub fn Builder::build_global_string_ptr(
  self : Builder,
  value : String,
  name~ : String = ""
) -> GlobalValue raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_global_string_ptr(
    self.as_builder_ref(),
    value,
    name,
  )
  GlobalValue::new(value)
}

///|
pub fn[V : VectorBaseValue] Builder::build_shuffle_vector(
  self : Builder,
  left : V,
  right : V,
  mask : V,
  name~ : String = ""
) -> V raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_shuffle_vector(
    self.as_builder_ref(),
    left.as_value_ref(),
    right.as_value_ref(),
    mask.as_value_ref(),
    name,
  )
  V::new(value)
}

///|
pub fn[T : BasicType] Builder::build_va_arg(
  self : Builder,
  list : PointerValue,
  ty : T,
  name~ : String = ""
) -> BasicValueEnum raise BuilderError {
  guard self.get_positioned() is Set else { raise UnsetPosition }
  let value = @unsafe.llvm_build_va_arg(
    self.as_builder_ref(),
    list.as_value_ref(),
    ty.as_type_ref(),
    name,
  )
  BasicValueEnum::new(value)
}

// pub fn build_atomicrmw(
// pub fn build_cmpxchg<V: BasicValue<'ctx>>(

// pub fn Builder::set_current_debug_location(self: Builder, location: DILocation) -> Unit {
//   @unsafe.llvm_set_current_debug_location2(self.builder_ref, location.metadata_ref)
// }

// pub fn Builder::get_current_debug_location(self: Builder) -> Option[DILocation] {
//   let metadata_ref = @unsafe.llvm_get_current_debug_location(self.builder_ref)
//   if metadata_ref.is_null() {
//     return None
//   }
//
//   Some(DILocation::new(metadata_ref))
// }

// pub fn unset_current_debug_location(&self) {
//     use @unsafe.llvm_sys::core::@unsafe.LLVMSetCurrentDebugLocation2;
//     unsafe {
//         @unsafe.LLVMSetCurrentDebugLocation2(self.builder, std::ptr::null_mut());
//     }
// }

// pub fn Builder::unset_current_debug_location(self: Builder) -> Unit {
//   @unsafe.llvm_unset_current_debug_location2(self.builder_ref)
// }
