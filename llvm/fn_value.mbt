// ============================================
// FunctionValue
// ============================================
///| A `FunctionValue` is a value that represents a function.
pub struct FunctionValue {
  value: Value
}

///| Creates a new `FunctionValue` from an `@unsafe.LLVMValueRef`.
pub fn FunctionValue::new(value_ref: @unsafe.LLVMValueRef) -> FunctionValue? {
  if value_ref.is_null() {
    return None
  }

  let fv = FunctionValue::{
    value: Value::new(value_ref)
  }
  Some(fv)
}

///| Returns the `@unsafe.LLVMValueRef` that this `FunctionValue` wraps.
pub fn FunctionValue::as_value_ref(self: FunctionValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

///| Get the linkage of the function.
pub fn FunctionValue::get_linkage(self: FunctionValue) -> Linkage {
  let link = @unsafe.llvm_get_linkage(self.as_value_ref())
  Linkage::from(link)
}

///| Set the linkage of the function.
pub fn FunctionValue::set_linkage(self: FunctionValue, linkage: Linkage) -> Unit {
  @unsafe.llvm_set_linkage(self.as_value_ref(), linkage.into())
}

///| Determines whether or not this `FunctionValue` is null.
pub fn FunctionValue::is_null(self: FunctionValue) -> Bool {
  self.value.is_null()
}

///| Determines whether or not this `FunctionValue` is undefined.
pub fn FunctionValue::is_undef(self: FunctionValue) -> Bool {
  self.value.is_undef()
}

// pub fn FunctionValue::verify(self: FunctionValue, print: Bool) -> Bool {
//   let action = if print {
//       @unsafe.LLVMVerifierFailureAction::@unsafe.LLVMPrintMessageAction
//   } else {
//       @unsafe.LLVMVerifierFailureAction::@unsafe.LLVMReturnStatusAction
//   }
//
//   let code = @unsafe.llvm_verify_function(self.as_value_ref(), action)
//
//   code != 1
// }

///| Get the next function in the module.
pub fn FunctionValue::get_next_function(self: FunctionValue) -> FunctionValue? {
  FunctionValue::new(@unsafe.llvm_get_next_function(self.as_value_ref()))
}

///| Get the previous function in the module.
pub fn FunctionValue::get_previous_function(self: FunctionValue) -> FunctionValue? {
  FunctionValue::new(@unsafe.llvm_get_previous_function(self.as_value_ref()))
}

///| Get the first parameter of the function.
pub fn FunctionValue::get_first_param(self: FunctionValue) -> BasicValueEnum?{
  let param = @unsafe.llvm_get_first_param(self.as_value_ref())

  if param.is_null() {
    None
  } else {
    Some(BasicValueEnum::new(param))
  }
}

///| Get the last parameter of the function.
pub fn FunctionValue::get_last_param(self: FunctionValue) -> BasicValueEnum? {
  let param = @unsafe.llvm_get_last_param(self.as_value_ref())

  if param.is_null() {
    None
  } else {
    Some(BasicValueEnum::new(param))
  }
}

///| Get the first basic block of the function.
pub fn FunctionValue::get_first_basic_block(self: FunctionValue) -> BasicBlock? {
  let bb = @unsafe.llvm_get_first_basic_block(self.as_value_ref())

  BasicBlock::new(bb)
}

///| Get the last basic block of the function.
pub fn FunctionValue::get_last_basic_block(self: FunctionValue) -> BasicBlock? {
  let bb = @unsafe.llvm_get_last_basic_block(self.as_value_ref())

  BasicBlock::new(bb)
}

///| Get the n-th parameter of the function.
pub fn FunctionValue::get_nth_param(self: FunctionValue, nth: UInt) -> BasicValueEnum? {
  let cnt = self.count_params()

  if nth >= cnt {
    None
  } else {
    Some(BasicValueEnum::new(@unsafe.llvm_get_param(self.as_value_ref(), nth)))
  }
}

///| Returns the number of parameters this `FunctionValue` has.
pub fn FunctionValue::count_params(self: FunctionValue) -> UInt {
  @unsafe.llvm_count_params(self.as_value_ref())
}

///| Get basic blocks of the function.
pub fn FunctionValue::get_basic_blocks(self: FunctionValue) -> Array[BasicBlock] {
  let bb_refs : Array[@unsafe.LLVMBasicBlockRef] = @unsafe.llvm_get_basic_blocks(self.as_value_ref())
  bb_refs.map(fn (bb_ref) { BasicBlock::new(bb_ref).unwrap() })
}

///| Get parameters of the function.
pub fn FunctionValue::get_params(self: FunctionValue) -> Array[BasicValueEnum] {
  let param_refs : Array[@unsafe.LLVMValueRef] = @unsafe.llvm_get_params(self.as_value_ref())
  param_refs.map(fn (param_ref) { BasicValueEnum::new(param_ref) })
}

///| Get the name of the function.
pub fn FunctionValue::get_name(self: FunctionValue) -> String {
  self.value.get_name()
}

// pub fn FunctionValue::view_function_cfg(self: FunctionValue) -> Unit {
//   @unsafe.llvm_view_function_cfg(self.as_value_ref())
// }
//
// pub fn FunctionValue::view_function_cfg_only(self: FunctionValue) -> Unit {
//   @unsafe.llvm_view_function_cfg_only(self.as_value_ref())
// }

///| Free the function.
pub fn FunctionValue::delete(self: FunctionValue) -> Unit {
  @unsafe.llvm_delete_function(self.as_value_ref())
}

// NOTE: `inkwell` does not provide this function
// pub fn FunctionValue::set_name(self: FunctionValue, name: String) -> Unit {
//   self.value.set_name(name)
// }

///| Get the type of the function.
pub fn FunctionValue::get_type(self: FunctionValue) -> FunctionType {
  FunctionType::new(self.value.get_type().as_type_ref())
}

pub fn FunctionValue::has_personality_function(self: FunctionValue) -> Bool {
  @unsafe.llvm_has_personality_fn(self.as_value_ref())
}

pub fn FunctionValue::get_personality_function(self: FunctionValue) -> FunctionValue? {
  if not(self.has_personality_function()) {
    return None
  }

  FunctionValue::new(@unsafe.llvm_get_personality_fn(self.as_value_ref()))
}

pub fn FunctionValue::set_personality_function(self: FunctionValue, personality_fn: FunctionValue) -> Unit {
  @unsafe.llvm_set_personality_fn(self.as_value_ref(), personality_fn.as_value_ref())
}

pub fn FunctionValue::get_intrinsic_id(self: FunctionValue) -> UInt {
  @unsafe.llvm_get_intrinsic_id(self.as_value_ref())
}

// REVIEW: Possibly we need to use `CallConv` enum, rather than `UInt`
pub fn FunctionValue::get_call_convention(self: FunctionValue) -> UInt {
  @unsafe.llvm_get_function_call_conv(self.as_value_ref())
}

// REVIEW: Possibly we need to use `CallConv` enum, rather than `UInt`
pub fn FunctionValue::set_call_convention(self: FunctionValue, call_conv: UInt) -> Unit {
  @unsafe.llvm_set_function_call_conv(self.as_value_ref(), call_conv)
}

pub fn FunctionValue::get_gc(self: FunctionValue) -> String {
  @unsafe.llvm_get_gc(self.as_value_ref())
}

///| Replace all uses of a `FunctionValue` with another `FunctionValue`.
pub fn FunctionValue::replace_all_uses_with(
  self: FunctionValue, new_value: FunctionValue
) -> Unit {
  self.value.replace_all_uses_with(new_value.value)
}

///| Adds an `Attribute` to a particular location in this `FunctionValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let fn_value = module.add_function("my_fn", fn_type, None);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
/// let enum_attribute = context.create_enum_attribute(1, 1);
///
/// fn_value.add_attribute(AttributeLoc::Return, string_attribute);
/// fn_value.add_attribute(AttributeLoc::Return, enum_attribute);
/// ```
pub fn FunctionValue::add_attribute(
  self: FunctionValue, loc: AttributeLoc, attribute: Attribute
) -> Unit {
  @unsafe.llvm_add_attribute_at_index(self.as_value_ref(), loc.get_index(), attribute.attribute)
}

///| Counts the number of `Attribute`s belonging to the specified location in this `FunctionValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let fn_value = module.add_function("my_fn", fn_type, None);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
/// let enum_attribute = context.create_enum_attribute(1, 1);
///
/// fn_value.add_attribute(AttributeLoc::Return, string_attribute);
/// fn_value.add_attribute(AttributeLoc::Return, enum_attribute);
///
/// assert_eq!(fn_value.count_attributes(AttributeLoc::Return), 2);
/// ```
pub fn FunctionValue::count_attributes(self: FunctionValue, loc: AttributeLoc) -> UInt {
  @unsafe.llvm_get_attribute_count_at_index(self.as_value_ref(), loc.get_index())
}

///| Get all `Attribute`s belonging to the specified location in this `FunctionValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let fn_value = module.add_function("my_fn", fn_type, None);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
/// let enum_attribute = context.create_enum_attribute(1, 1);
///
/// fn_value.add_attribute(AttributeLoc::Return, string_attribute);
/// fn_value.add_attribute(AttributeLoc::Return, enum_attribute);
///
/// assert_eq!(fn_value.attributes(AttributeLoc::Return), [string_attribute, enum_attribute]);
/// ```
pub fn FunctionValue::attributes(
  self: FunctionValue, loc: AttributeLoc
) -> Array[Attribute] {
  let attr_refs = @unsafe.llvm_get_attributes_at_index(self.as_value_ref(), loc.get_index())

  attr_refs.map(fn (attr_ref) { Attribute::new(attr_ref) })
}


///| Removes a string `Attribute` belonging to the specified location in this `FunctionValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let fn_value = module.add_function("my_fn", fn_type, None);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
///
/// fn_value.add_attribute(AttributeLoc::Return, string_attribute);
/// fn_value.remove_string_attribute(AttributeLoc::Return, "my_key");
/// ```
pub fn FunctionValue::remove_string_attribute(
  self: FunctionValue, loc: AttributeLoc, key: String
) -> Unit {
  @unsafe.llvm_remove_string_attribute_at_index(self.as_value_ref(), loc.get_index(), key)
}

///| Removes an enum `Attribute` belonging to the specified location in this `FunctionValue`.
///
/// # Example (Not Tested)
///
/// ```no_run
/// let context = Context::create();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let fn_value = module.add_function("my_fn", fn_type, None);
/// let enum_attribute = context.create_enum_attribute(1, 1);
///
/// fn_value.add_attribute(AttributeLoc::Return, enum_attribute);
/// fn_value.remove_enum_attribute(AttributeLoc::Return, 1);
/// ```
pub fn FunctionValue::remove_enum_attribute(
  self: FunctionValue, loc: AttributeLoc, kind_id: UInt
) -> Unit {
  @unsafe.llvm_remove_enum_attribute_at_index(self.as_value_ref(), loc.get_index(), kind_id)
}

///| Gets an enum `Attribute` belonging to the specified location in this `FunctionValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let fn_value = module.add_function("my_fn", fn_type, None);
/// let enum_attribute = context.create_enum_attribute(1, 1);
///
/// fn_value.add_attribute(AttributeLoc::Return, enum_attribute);
///
/// assert_eq!(fn_value.get_enum_attribute(AttributeLoc::Return, 1), Some(enum_attribute));
/// ```
pub fn FunctionValue::get_enum_attribute(self: FunctionValue, loc: AttributeLoc, kind_id: UInt) -> Attribute? {
  let attr_ref = @unsafe.llvm_get_enum_attribute_at_index(self.as_value_ref(), loc.get_index(), kind_id)

  if attr_ref.is_null() {
    None
  } else {
    Some(Attribute::new(attr_ref))
  }
}

///| Gets a string `Attribute` belonging to the specified location in this `FunctionValue`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let fn_value = module.add_function("my_fn", fn_type, None);
/// let string_attribute = context.create_string_attribute("my_key", "my_val");
///
/// fn_value.add_attribute(AttributeLoc::Return, string_attribute);
///
/// assert_eq!(fn_value.get_string_attribute(AttributeLoc::Return, "my_key"), Some(string_attribute));
/// ```
pub fn FunctionValue::get_string_attribute(self: FunctionValue, loc: AttributeLoc, key: String) -> Attribute? {
  let attr_ref = @unsafe.llvm_get_string_attribute_at_index(self.as_value_ref(), loc.get_index(), key)

  if attr_ref.is_null() {
    None
  } else {
    Some(Attribute::new(attr_ref))
  }
}

///| Sets the alignment of a parameter at a given index.
pub fn FunctionValue::set_param_alignment(
  self: FunctionValue, param_index: UInt, alignment: UInt
) -> Unit {
  match self.get_nth_param(param_index) {
    Some(param) => {
      @unsafe.llvm_set_param_alignment(param.as_value_ref(), alignment)
    }
    _ => ()
  }
}

///| Gets the `GlobalValue` version of this `FunctionValue`.
/// This allows you to further inspect its global properties or even
/// convert it to a `PointerValue`.
pub fn FunctionValue::as_global_value(self: FunctionValue) -> GlobalValue {
  GlobalValue::new(self.as_value_ref())
}

// pub fn FunctionValue::set_subprogram(self: FunctionValue, subprogram: DISubprogram) -> Unit {
//   @unsafe.llvm_set_subprogram(self.as_value_ref(), subprogram.as_metadata_ref())
// }

// pub fn FunctionValue::get_subprogram(self: FunctionValue) -> DISubprogram? {
//   let subprogram = @unsafe.llvm_get_subprogram(self.as_value_ref())
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

///| Dumps the `FunctionValue` to stderr.
///
/// It's equivalent to `FunctionValue::dump`.
pub fn FunctionValue::print_to_stderr(self: FunctionValue) -> Unit {
  self.value.print_to_stderr()
}

///| Dumps the `FunctionValue` to a string.
///
/// It's equivalent to `FunctionValue::print_to_string`.
pub fn FunctionValue::print_to_string(self: FunctionValue) -> String {
  self.value.print_to_string()
}

///| Dumps the `FunctionValue` to a string.
///
/// It's equivalent to `FunctionValue::print_to_string`.
pub fn FunctionValue::to_string(self: FunctionValue) -> String {
  self.value.to_string()
}

///| Dumps the `FunctionValue` to stderr.
///
/// It's equivalent to `FunctionValue::print_to_stderr`.
pub fn FunctionValue::dump(self: FunctionValue) -> Unit {
  self.value.dump()
}

pub impl Show for FunctionValue with output(self: FunctionValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for FunctionValue with to_string(self: FunctionValue) -> String {
  self.to_string()
}


