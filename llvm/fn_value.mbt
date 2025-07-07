// ============================================
// FunctionValue
// ============================================

///| A `FunctionValue` is a value that represents a function.
pub struct FunctionValue {
  value : ValueRef
}

///| Creates a new `FunctionValue` from an `@unsafe.LLVMValueRef`.
pub fn FunctionValue::new(value_ref : @unsafe.LLVMValueRef) -> FunctionValue? {
  @option.unless(value_ref.is_null(), fn() {
    FunctionValue::{ value: ValueRef::new(value_ref) }
  })
}

///|
pub impl Value for FunctionValue with base(self) {
  self.value
}

///|
pub impl Value for FunctionValue with as_value_enum(self) {
  FunctionValue(self)
}

///| Get the linkage of the function.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let void_ty = context.void_type();
/// let fn_type = void_ty.fn_type([i32_ty]);
/// let fn_value = lmodule.add_function("foo", fn_type);
///
/// inspect(fn_value.get_linkage(), content="External")
/// ```
pub fn FunctionValue::get_linkage(self : FunctionValue) -> Linkage {
  let link = @unsafe.llvm_get_linkage(self.inner())
  Linkage::from(link)
}

///| Set the linkage of the function.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let void_ty = context.void_type();
/// let fn_type = void_ty.fn_type([i32_ty]);
/// let fn_value = lmodule.add_function(
///   "foo", fn_type,
///   linkage=Some(@llvm.Linkage::Common)
/// );
///
/// inspect(fn_value.get_linkage(), content="Common")
/// fn_value.set_linkage(Private);
/// inspect(fn_value.get_linkage(), content="Private")
/// ```
pub fn FunctionValue::set_linkage(
  self : FunctionValue,
  linkage : Linkage
) -> Unit {
  @unsafe.llvm_set_linkage(self.inner(), linkage.into())
}

///| Determines whether or not this `FunctionValue` is null.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let void_ty = context.void_type();
/// let fn_type = void_ty.fn_type([i32_ty]);
/// let fn_value = lmodule.add_function("foo", fn_type);
///
/// assert_false(fn_value.is_null());
/// ```
pub fn FunctionValue::is_null(self : FunctionValue) -> Bool {
  self.value.is_null()
}

///| Determines whether or not this `FunctionValue` is undefined.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let void_ty = context.void_type();
/// let fn_type = void_ty.fn_type([i32_ty]);
/// let fn_value = lmodule.add_function("foo", fn_type);
///
/// assert_false(fn_value.is_undef());
/// ```
pub fn FunctionValue::is_undef(self : FunctionValue) -> Bool {
  self.value.is_undef()
}

// pub fn FunctionValue::verify(self: FunctionValue, print: Bool) -> Bool {
//   let action = if print {
//       @unsafe.LLVMVerifierFailureAction::@unsafe.LLVMPrintMessageAction
//   } else {
//       @unsafe.LLVMVerifierFailureAction::@unsafe.LLVMReturnStatusAction
//   }
//
//   let code = @unsafe.llvm_verify_function(self.inner(), action)
//
//   code != 1
// }

///| Get the next function in the llvm_module.
pub fn FunctionValue::get_next_function(self : FunctionValue) -> FunctionValue? {
  FunctionValue::new(@unsafe.llvm_get_next_function(self.inner()))
}

///| Get the previous function in the llvm_module.
pub fn FunctionValue::get_previous_function(
  self : FunctionValue
) -> FunctionValue? {
  FunctionValue::new(@unsafe.llvm_get_previous_function(self.inner()))
}

///| Get the first parameter of the function.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let f64_ty = context.f64_type();
/// let void_ty = context.void_type();
/// let fn_type = void_ty.fn_type([i32_ty, f64_ty]);
/// let fn_value = lmodule.add_function("foo", fn_type);
///
/// inspect(fn_value.get_first_param(), content="Some(i32 %0)")
/// ```
pub fn FunctionValue::get_first_param(self : FunctionValue) -> &BasicValue? {
  let param = @unsafe.llvm_get_first_param(self.inner())
  if param.is_null() {
    None
  } else {
    Some(BasicValueEnum::init(param).as_basic_value_class())
  }
}

///| Get the last parameter of the function.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let f64_ty = context.f64_type();
/// let void_ty = context.void_type();
/// let fn_type = void_ty.fn_type([i32_ty, f64_ty]);
/// let fn_value = lmodule.add_function("foo", fn_type);
///
/// inspect(fn_value.get_last_param(), content="Some(double %1)")
/// ```
pub fn FunctionValue::get_last_param(self : FunctionValue) -> &BasicValue? {
  let param = @unsafe.llvm_get_last_param(self.inner())
  if param.is_null() {
    None
  } else {
    Some(BasicValueEnum::init(param).as_basic_value_class())
  }
}

///| Get the first basic block of the function.
pub fn FunctionValue::get_first_basic_block(
  self : FunctionValue
) -> BasicBlock? {
  let bb = @unsafe.llvm_get_first_basic_block(self.inner())
  @option.when(bb.is_not_null(), fn() { BasicBlock::new(bb) })
}

///| Get the last basic block of the function.
pub fn FunctionValue::get_last_basic_block(self : FunctionValue) -> BasicBlock? {
  let bb = @unsafe.llvm_get_last_basic_block(self.inner())
  @option.when(bb.is_not_null(), fn() { BasicBlock::new(bb) })
}

///| Get the n-th parameter of the function.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let f64_ty = context.f64_type();
/// let void_ty = context.void_type();
/// let fn_type = void_ty.fn_type([i32_ty, f64_ty]);
/// let fn_value = lmodule.add_function("foo", fn_type);
///
/// inspect(fn_value.get_nth_param(0), content="Some(i32 %0)")
/// inspect(fn_value.get_nth_param(1), content="Some(double %1)")
/// ```
pub fn FunctionValue::get_nth_param(
  self : FunctionValue,
  nth : UInt
) -> &BasicValue? {
  @option.when(nth < self.count_params(), fn() {
    BasicValueEnum::init(@unsafe.llvm_get_param(self.inner(), nth)).as_basic_value_class()
  })
}

///| Returns the number of parameters this `FunctionValue` has.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let f64_ty = context.f64_type();
/// let void_ty = context.void_type();
/// let fn_type = void_ty.fn_type([i32_ty, f64_ty]);
/// let fn_value = lmodule.add_function("foo", fn_type);
///
/// assert_eq(fn_value.count_params(), 2)
/// ```
pub fn FunctionValue::count_params(self : FunctionValue) -> UInt {
  @unsafe.llvm_count_params(self.inner())
}

///|
pub fn FunctionValue::count_basic_blocks(self : FunctionValue) -> UInt {
  @unsafe.llvm_count_basic_blocks(self.inner())
}

///| Get basic blocks of the function.
pub fn FunctionValue::get_basic_blocks(
  self : FunctionValue
) -> Array[BasicBlock] {
  let bb_refs : Array[@unsafe.LLVMBasicBlockRef] = @unsafe.llvm_get_basic_blocks(
    self.inner(),
  )
  bb_refs.map(fn(bb_ref) { BasicBlock::new(bb_ref) })
}

///| Get parameters of the function.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let f64_ty = context.f64_type();
/// let void_ty = context.void_type();
/// let fn_type = void_ty.fn_type([f64_ty, i32_ty]);
/// let fn_value = lmodule.add_function("foo", fn_type);
///
/// inspect(fn_value.get_params(), content="[double %0, i32 %1]")
/// ```
pub fn FunctionValue::get_params(self : FunctionValue) -> Array[&BasicValue] {
  let param_refs : Array[@unsafe.LLVMValueRef] = @unsafe.llvm_get_params(
    self.inner(),
  )
  param_refs.map(fn(param_ref) {
    BasicValueEnum::init(param_ref).as_basic_value_class()
  })
}

///| Get the name of the function.
///
/// ## Example
///
/// ```moonbit
/// let context = @llvm.Context::create();
/// let lmodule = context.create_module("demo");
/// let i32_ty = context.i32_type();
/// let f64_ty = context.f64_type();
/// let void_ty = context.void_type();
/// let fn_type = void_ty.fn_type([i32_ty, f64_ty]);
/// let fn_value = lmodule.add_function("foo", fn_type);
///
/// inspect(fn_value.get_name(), content="foo")
/// ```
pub fn FunctionValue::get_name(self : FunctionValue) -> String {
  self.value.get_name()
}

// pub fn FunctionValue::view_function_cfg(self: FunctionValue) -> Unit {
//   @unsafe.llvm_view_function_cfg(self.inner())
// }
//
// pub fn FunctionValue::view_function_cfg_only(self: FunctionValue) -> Unit {
//   @unsafe.llvm_view_function_cfg_only(self.inner())
// }

///| Free the function.
///
/// It's equivalent to `FunctionValue::drop`.
pub fn FunctionValue::delete(self : FunctionValue) -> Unit {
  @unsafe.llvm_delete_function(self.inner())
}

///| Free the function.
///
/// It's equivalent to `FunctionValue::delete`.
pub fn FunctionValue::drop(self : FunctionValue) -> Unit {
  @unsafe.llvm_delete_function(self.inner())
}

// NOTE: `inkwell` does not provide this function
// pub fn FunctionValue::set_name(self: FunctionValue, name: String) -> Unit {
//   self.value.set_name(name)
// }

///| Get the type of the function.
pub fn FunctionValue::get_type(self : FunctionValue) -> FunctionType {
  //FunctionType::new(self.value.get_type().as_type_ref())
  //FunctionType::new(self.value.inner())
  self.value.inner() |> @unsafe.llvm_global_get_value_type |> FunctionType::new
}

///|
pub fn FunctionValue::has_personality_function(self : FunctionValue) -> Bool {
  @unsafe.llvm_has_personality_fn(self.inner())
}

///|
pub fn FunctionValue::get_personality_function(
  self : FunctionValue
) -> FunctionValue? {
  if not(self.has_personality_function()) {
    return None
  }
  FunctionValue::new(@unsafe.llvm_get_personality_fn(self.inner()))
}

///|
pub fn FunctionValue::set_personality_function(
  self : FunctionValue,
  personality_fn : FunctionValue
) -> Unit {
  @unsafe.llvm_set_personality_fn(self.inner(), personality_fn.inner())
}

///|
pub fn FunctionValue::get_intrinsic_id(self : FunctionValue) -> UInt {
  @unsafe.llvm_get_intrinsic_id(self.inner())
}

// REVIEW: Possibly we need to use `CallConv` enum, rather than `UInt`

///|
pub fn FunctionValue::get_call_convention(self : FunctionValue) -> UInt {
  @unsafe.llvm_get_function_call_conv(self.inner())
}

// REVIEW: Possibly we need to use `CallConv` enum, rather than `UInt`

///|
pub fn FunctionValue::set_call_convention(
  self : FunctionValue,
  call_conv : UInt
) -> Unit {
  @unsafe.llvm_set_function_call_conv(self.inner(), call_conv)
}

///|
pub fn FunctionValue::get_gc(self : FunctionValue) -> String {
  @unsafe.llvm_get_gc(self.inner())
}

///|
pub fn FunctionValue::set_gc(self : FunctionValue, gc : String) -> Unit {
  @unsafe.llvm_set_gc(self.inner(), gc)
}

///| Replace all uses of a `FunctionValue` with another `FunctionValue`.
pub fn FunctionValue::replace_all_uses_with(
  self : FunctionValue,
  new_value : FunctionValue
) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///| Adds an `Attribute` to a particular location in this `FunctionValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
/// let enum_attribute = context.create_enum_attribute(1, 1);
///
/// fn_value.add_attribute(Return, string_attribute);
/// fn_value.add_attribute(Return, enum_attribute);
/// ```
pub fn FunctionValue::add_attribute(
  self : FunctionValue,
  loc : AttributeLoc,
  attribute : Attribute
) -> Unit {
  @unsafe.llvm_add_attribute_at_index(
    self.inner(),
    loc.get_index(),
    attribute.attribute,
  )
}

///| Counts the number of `Attribute`s belonging to the specified location in this `FunctionValue`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
/// let enum_attribute = context.create_enum_attribute(1, 1);
///
/// fn_value.add_attribute(Return, string_attribute);
/// fn_value.add_attribute(Return, enum_attribute);
///
/// assert_eq(fn_value.count_attributes(AttributeLoc::Return), 2);
/// ```
pub fn FunctionValue::count_attributes(
  self : FunctionValue,
  loc : AttributeLoc
) -> UInt {
  @unsafe.llvm_get_attribute_count_at_index(self.inner(), loc.get_index())
}

///| Get all `Attribute`s belonging to the specified location in this `FunctionValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip (not implement attribute op_equal)
/// let context = Context::create();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
/// let enum_attribute = context.create_enum_attribute(1, 1);
///
/// fn_value.add_attribute(AttributeLoc::Return, string_attribute);
/// fn_value.add_attribute(AttributeLoc::Return, enum_attribute);
///
/// assert_eq(fn_value.attributes(AttributeLoc::Return), [string_attribute, enum_attribute]);
/// ```
///
/// @alert Bug "This Function will cause link error. To be Fixed."
pub fn FunctionValue::attributes(
  self : FunctionValue,
  loc : AttributeLoc
) -> Array[Attribute] {
  let attr_refs = @unsafe.llvm_get_attributes_at_index(
    self.inner(),
    loc.get_index(),
  )
  attr_refs.map(fn(attr_ref) { Attribute::new(attr_ref) })
}

///| Removes a string `Attribute` belonging to the specified location in this `FunctionValue`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
///
/// fn_value.add_attribute(AttributeLoc::Return, string_attribute);
/// fn_value.remove_string_attribute(AttributeLoc::Return, "my_key");
/// ```
pub fn FunctionValue::remove_string_attribute(
  self : FunctionValue,
  loc : AttributeLoc,
  key : String
) -> Unit {
  @unsafe.llvm_remove_string_attribute_at_index(
    self.inner(),
    loc.get_index(),
    key,
  )
}

///| Removes an enum `Attribute` belonging to the specified location in this `FunctionValue`.
///
/// # Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let enum_attribute = context.create_enum_attribute(1, 1);
///
/// fn_value.add_attribute(AttributeLoc::Return, enum_attribute);
/// fn_value.remove_enum_attribute(AttributeLoc::Return, 1);
/// ```
pub fn FunctionValue::remove_enum_attribute(
  self : FunctionValue,
  loc : AttributeLoc,
  kind_id : UInt
) -> Unit {
  @unsafe.llvm_remove_enum_attribute_at_index(
    self.inner(),
    loc.get_index(),
    kind_id,
  )
}

///| Gets an enum `Attribute` belonging to the specified location in this `FunctionValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip (not implement attribute op_equal)
/// let context = Context::create();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let enum_attribute = context.create_enum_attribute(1, 1);
///
/// fn_value.add_attribute(AttributeLoc::Return, enum_attribute);
///
/// assert_eq(fn_value.get_enum_attribute(AttributeLoc::Return, 1), Some(enum_attribute));
/// ```
pub fn FunctionValue::get_enum_attribute(
  self : FunctionValue,
  loc : AttributeLoc,
  kind_id : UInt
) -> Attribute? {
  let attr_ref = @unsafe.llvm_get_enum_attribute_at_index(
    self.inner(),
    loc.get_index(),
    kind_id,
  )
  @option.unless(attr_ref.is_null(), fn() { Attribute::new(attr_ref) })
}

///| Gets a string `Attribute` belonging to the specified location in this `FunctionValue`.
///
/// ## Example
///
/// ```moonbit skip skip (not implement attribute op_equal)
/// let context = Context::create();
/// let llvm_module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = llvm_module.add_function("my_fn", fn_type);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
///
/// fn_value.add_attribute(AttributeLoc::Return, string_attribute);
///
/// assert_eq(fn_value.get_string_attribute(AttributeLoc::Return, "my_key"), Some(string_attribute));
/// ```
pub fn FunctionValue::get_string_attribute(
  self : FunctionValue,
  loc : AttributeLoc,
  key : String
) -> Attribute? {
  let attr_ref = @unsafe.llvm_get_string_attribute_at_index(
    self.inner(),
    loc.get_index(),
    key,
  )
  @option.unless(attr_ref.is_null(), fn() { Attribute::new(attr_ref) })
}

///| Sets the alignment of a parameter at a given index.
pub fn FunctionValue::set_param_alignment(
  self : FunctionValue,
  param_index : UInt,
  alignment : UInt
) -> Unit {
  if self.get_nth_param(param_index) is Some(param) {
    @unsafe.llvm_set_param_alignment(param.inner(), alignment)
  }
}

///| Gets the `GlobalValue` version of this `FunctionValue`.
/// This allows you to further inspect its global properties or even
/// convert it to a `PointerValue`.
pub fn FunctionValue::as_global_value(self : FunctionValue) -> GlobalValue {
  GlobalValue::new(self.inner())
}

// pub fn FunctionValue::set_subprogram(self: FunctionValue, subprogram: DISubprogram) -> Unit {
//   @unsafe.llvm_set_subprogram(self.inner(), subprogram.as_metadata_ref())
// }

// pub fn FunctionValue::get_subprogram(self: FunctionValue) -> DISubprogram? {
//   let subprogram = @unsafe.llvm_get_subprogram(self.inner())
//
//   if subprogram.is_null() {
//     None
//   } else {
//     Some(DISubprogram::new(subprogram))
//   }
// }

// Get the section to which this function belongs
// pub fn FunctionValue::get_section(self: FunctionValue) -> String {
//   self.value.get_section()
// }
//
// Set the section to which this function should belong
// pub fn FunctionValue::set_section(self: FunctionValue, section: String) -> Unit {
//   self.value.set_section(section)
// }

///|
pub impl Show for FunctionValue with output(
  self : FunctionValue,
  logger : &Logger
) -> Unit {
  logger.write_string(self.value.to_string())
}

///|
pub impl Eq for FunctionValue with op_equal(
  self : FunctionValue,
  other : FunctionValue
) -> Bool {
  self.inner() == other.inner()
}
