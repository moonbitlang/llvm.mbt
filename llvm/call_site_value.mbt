// ============================================
// CallSiteValue
// ============================================

///| A value resulting from a function call. It may have function attributes applied to it.
// This struct may be removed in the future in favor of an `InstructionValue<CallSite>` type.
pub struct CallSiteValue {
  value : ValueRef
}

///| Creates a new `CallSiteValue` from an `@unsafe.LLVMValueRef`.
pub fn CallSiteValue::new(value_ref : @unsafe.LLVMValueRef) -> CallSiteValue {
  guard value_ref.is_not_null()
  CallSiteValue::{ value: ValueRef::new(value_ref) }
}


pub impl Value for CallSiteValue with base(self) {
  self.value
}

pub impl Value for CallSiteValue with as_value_enum(self) {
  CallSiteValue(self)
}

///| Sets whether or not this call is a tail call.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let entry_bb = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_bb);
///
/// let call_site_value = builder.build_call(fn_value, []);
/// call_site_value.set_tail_call(true);
/// assert_true(call_site_value.is_tail_call());
/// ```
pub fn CallSiteValue::set_tail_call(
  self : CallSiteValue,
  tail_call : Bool
) -> Unit {
  self.inner().set_tail_call(tail_call)
}

///| Determines whether or not this call is a tail call.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let entry_bb = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_bb);
///
/// let call_site_value = builder.build_call(fn_value, []);
///
/// call_site_value.set_tail_call(true);
///
/// assert_true(call_site_value.is_tail_call());
/// ```
pub fn CallSiteValue::is_tail_call(self : CallSiteValue) -> Bool {
  self.inner().is_tail_call()
}

///| Returns tail, musttail, and notail attributes.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let entry_bb = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_bb);
///
/// let call_site = builder.build_call(fn_value, []);
///
/// assert_true(call_site.get_tail_call_kind() == @unsafe.LLVMTailCallKindNone);
/// ```
// TODO: use `TailCallKind` instead of `@unsafe.LLVMTailCallKind`
pub fn CallSiteValue::get_tail_call_kind(
  self : CallSiteValue
) -> @unsafe.LLVMTailCallKind {
  self.inner().get_tail_call_kind()
}

///| Sets tail, musttail, and notail attributes.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let entry_bb = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_bb);
///
/// let call_site = builder.build_call(fn_value, []);
///
/// call_site.set_tail_call_kind(@unsafe.LLVMTailCallKindTail);
/// assert_true(call_site.get_tail_call_kind() == @unsafe.LLVMTailCallKindTail);
/// ```
pub fn CallSiteValue::set_tail_call_kind(
  self : CallSiteValue,
  kind : @unsafe.LLVMTailCallKind
) -> Unit {
  self.inner().set_tail_call_kind(kind)
}

///| Try to convert this `CallSiteValue` to a `BasicValueEnum` if not a void return type.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let entry_bb = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_bb);
///
/// let call_site_value = builder.build_call(fn_value, []);
/// assert_true(call_site_value.try_as_basic_value().is_right());
/// ```
pub fn CallSiteValue::try_as_basic_value(
  self : CallSiteValue
) -> Either[BasicValueEnum, InstructionValue] {
  let kind = @unsafe.llvm_get_type_kind(
    @unsafe.llvm_type_of(self.inner()),
  )
  match kind {
    @unsafe.LLVMTypeKind::LLVMVoidTypeKind =>
      Right(InstructionValue::new(self.inner()))
    _ => Left(BasicValueEnum::init(self.inner()))
  }
}

///| Adds an `Attribute` to this `CallSiteValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
/// let enum_attribute = context.create_enum_attribute(1, 1);
/// let entry_bb = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_bb);
///
/// let call_site_value = builder.build_call(fn_value, []);
///
/// call_site_value.add_attribute(AttributeLoc::Return, string_attribute);
/// call_site_value.add_attribute(AttributeLoc::Return, enum_attribute);
/// ```
pub fn CallSiteValue::add_attribute(
  self : CallSiteValue,
  loc : AttributeLoc,
  attribute : Attribute
) -> Unit {
  @unsafe.llvm_add_call_site_attribute(
    self.inner(),
    loc.get_index(),
    attribute.attribute,
  )
}

///| Gets the `FunctionValue` this `CallSiteValue` is based on.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let _ = context.create_string_attribute("my_key", "my_val");
/// let _ = context.create_enum_attribute(1, 1);
/// let entry_bb = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_bb);
///
/// let call_site_value = builder.build_call(fn_value, []);
///
/// assert_eq(call_site_value.get_called_fn_value(), fn_value);
/// ```
pub fn CallSiteValue::get_called_fn_value(
  self : CallSiteValue
) -> FunctionValue {
  FunctionValue::new(@unsafe.llvm_get_called_value(self.inner())).unwrap()
}

///| Counts the number of `Attribute`s on this `CallSiteValue` at an index.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
/// let enum_attribute = context.create_enum_attribute(1, 1);
/// let entry_bb = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_bb);
///
/// let call_site_value = builder.build_call(fn_value, []);
///
/// call_site_value.add_attribute(AttributeLoc::Return, string_attribute);
/// call_site_value.add_attribute(AttributeLoc::Return, enum_attribute);
///
/// assert_eq(call_site_value.count_attributes(AttributeLoc::Return), 2);
/// ```
pub fn CallSiteValue::count_attributes(
  self : CallSiteValue,
  loc : AttributeLoc
) -> UInt {
  @unsafe.llvm_get_call_site_attribute_count(
    self.inner(),
    loc.get_index(),
  )
}

///| Get all `Attribute`s on this `CallSiteValue` at an index.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip
/// let context = Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
/// let enum_attribute = context.create_enum_attribute(1, 1);
/// let entry_bb = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_bb);
///
/// let call_site_value = builder.build_call(fn_value, []);
/// let ret_attr = AttributeLoc::Return;
/// call_site_value.add_attribute(ret_attr, string_attribute);
/// call_site_value.add_attribute(ret_attr, enum_attribute);
///
/// assert_eq(call_site_value.attributes(ret_attr), [string_attribute, enum_attribute]);
/// ```
// REVIEW: Possibly need to check attr_refs is null or not
//pub fn CallSiteValue::attributes(
//  self : CallSiteValue,
//  loc : AttributeLoc
//) -> Array[Attribute] {
//  let attr_refs = @unsafe.llvm_get_call_site_attributes(
//    self.inner(),
//    loc.get_index(),
//  )
//  attr_refs.map(fn(r) { Attribute::new(r) })
//}

///| Gets an enum `Attribute` on this `CallSiteValue` at an index and kind id.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
/// let enum_attribute = context.create_enum_attribute(1, 1);
/// let entry_bb = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_bb);
///
/// let call_site_value = builder.build_call(fn_value, []);
/// let ret_attr = AttributeLoc::Return;
/// call_site_value.add_attribute(ret_attr, string_attribute);
/// call_site_value.add_attribute(ret_attr, enum_attribute);
///
/// assert_eq(call_site_value.get_enum_attribute(ret_attr, 1).unwrap(), enum_attribute);
/// ```
// REVIEW: Possibly need to check attr_ref is null or not
pub fn CallSiteValue::get_enum_attribute(
  self : CallSiteValue,
  loc : AttributeLoc,
  kind_id : UInt
) -> Attribute? {
  let attr_ref = @unsafe.llvm_get_call_site_enum_attribute(
    self.inner(),
    loc.get_index(),
    kind_id,
  )
  Some(Attribute::new(attr_ref))
}

///| Gets a string `Attribute` on this `CallSiteValue` at an index and key.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
/// let enum_attribute = context.create_enum_attribute(1, 1);
/// let entry_bb = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_bb);
///
/// let call_site_value = builder.build_call(fn_value, []);
/// let ret_attr = AttributeLoc::Return;
/// call_site_value.add_attribute(ret_attr, string_attribute);
/// call_site_value.add_attribute(ret_attr, enum_attribute);
///
/// assert_eq(call_site_value.get_string_attribute(ret_attr, "my_key").unwrap(), string_attribute);
/// ```
// REVIEW: Possibly need to check attr_ref is null or not
pub fn CallSiteValue::get_string_attribute(
  self : CallSiteValue,
  loc : AttributeLoc,
  key : String
) -> Attribute? {
  let attr_ref = @unsafe.llvm_get_call_site_string_attribute(
    self.inner(),
    loc.get_index(),
    key,
  )
  Some(Attribute::new(attr_ref))
}

///| Removes an enum `Attribute` on this `CallSiteValue` at an index and kind id.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip (test failed)
/// let context = @llvm.Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
/// let enum_attribute = context.create_enum_attribute(1, 1);
/// let entry_bb = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_bb);
///
/// let call_site_value = builder.build_call(fn_value, []);
///
/// call_site_value.add_attribute(AttributeLoc::Return, string_attribute);
/// call_site_value.add_attribute(AttributeLoc::Return, enum_attribute);
/// call_site_value.remove_enum_attribute(AttributeLoc::Return, 1);
///
/// assert_eq(call_site_value.get_enum_attribute(AttributeLoc::Return, 1), None);
/// ```
pub fn CallSiteValue::remove_enum_attribute(
  self : CallSiteValue,
  loc : AttributeLoc,
  kind_id : UInt
) -> Unit {
  @unsafe.llvm_remove_call_site_enum_attribute(
    self.inner(),
    loc.get_index(),
    kind_id,
  )
}

///| Removes a string `Attribute` on this `CallSiteValue` at an index and key.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip (test failed)
/// let context = @llvm.Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
/// let enum_attribute = context.create_enum_attribute(1, 1);
/// let entry_bb = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_bb);
///
/// let call_site_value = builder.build_call(fn_value, []);
///
/// call_site_value.add_attribute(AttributeLoc::Return, string_attribute);
/// call_site_value.add_attribute(AttributeLoc::Return, enum_attribute);
/// call_site_value.remove_string_attribute(AttributeLoc::Return, "my_key");
///
/// assert_eq(call_site_value.get_string_attribute(AttributeLoc::Return, "my_key"), None);
/// ```
pub fn CallSiteValue::remove_string_attribute(
  self : CallSiteValue,
  loc : AttributeLoc,
  key : String
) -> Unit {
  @unsafe.llvm_remove_call_site_string_attribute(
    self.inner(),
    loc.get_index(),
    key,
  )
}

///| Counts the number of arguments this `CallSiteValue` was called with.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let _ = context.create_string_attribute("my_key", "my_val");
/// let _ = context.create_enum_attribute(1, 1);
/// let entry_bb = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_bb);
///
/// let call_site_value = builder.build_call(fn_value, []);
///
/// assert_eq(call_site_value.count_arguments(), 0);
/// ```
pub fn CallSiteValue::count_arguments(self : CallSiteValue) -> UInt {
  @unsafe.llvm_get_num_arg_operands(self.inner())
}

///| Gets the calling convention for this `CallSiteValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let entry_bb = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_bb);
///
/// let call_site_value = builder.build_call(fn_value, []);
///
/// assert_eq(call_site_value.get_call_convention(), 0);
/// ```
pub fn CallSiteValue::get_call_convention(self : CallSiteValue) -> UInt {
  @unsafe.llvm_get_instruction_call_conv(self.inner())
}

///| Sets the calling convention for this `CallSiteValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let entry_bb = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_bb);
///
/// let call_site_value = builder.build_call(fn_value, []);
///
/// call_site_value.set_call_convention(2);
///
/// assert_eq(call_site_value.get_call_convention(), 2);
/// ```
pub fn CallSiteValue::set_call_convention(
  self : CallSiteValue,
  call_conv : UInt
) -> Unit {
  @unsafe.llvm_set_instruction_call_conv(self.inner(), call_conv)
}

///| Shortcut for setting the alignment `Attribute` for this `CallSiteValue`.
///
/// ## Panics
///
/// When the alignment is not a power of 2.
///
/// ## Example (Not Tested)
///
/// ```no_run
/// let context = @llvm.Context::create();
/// let builder = context.create_builder();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let entry_bb = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_bb);
///
/// let call_site_value = builder.build_call(fn_value, []);
///
/// call_site_value.set_alignment_attribute(AttributeLoc::Param(0), 2);
/// ```
pub fn CallSiteValue::set_alignment_attribute(
  self : CallSiteValue,
  loc : AttributeLoc,
  alignment : UInt
) -> Unit {
  // assert alignment.count_ones()
  if not(is_power_of_two(alignment)) {
    println("Alignment must be a power of 2")
    panic()
  }
  @unsafe.llvm_set_instr_param_alignment(
    self.inner(),
    loc.get_index(),
    alignment,
  )
}

// pub fn CallSiteValue::get_operand_bundles(self: CallSiteValue) -> Array[OperandBundle] {
//   let bundle_refs = @unsafe.llvm_get_instruction_operand_bundles(self.inner())
//   bundle_refs.map(fn (r) {OperandBundle::new(r)})
// }

///|
pub impl Show for CallSiteValue with output(
  self : CallSiteValue,
  logger : &Logger
) -> Unit {
  logger.write_string(self.value.to_string())
}
