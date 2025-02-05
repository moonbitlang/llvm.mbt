// ============================================
// GlobalValue
// ============================================
///| A `GlobalValue` is a value that represents a global variable.
pub struct GlobalValue {
  value: Value
}

///| Creates a new `GlobalValue` from an `@unsafe.LLVMValueRef`.
pub fn GlobalValue::new(value_ref: @unsafe.LLVMValueRef) -> GlobalValue {
  assert_val_ref(value_ref)

  GlobalValue::{
    value: Value::new(value_ref)
  }
}

///| Returns the `@unsafe.LLVMValueRef` that this `GlobalValue` wraps.
pub fn GlobalValue::as_value_ref(self: GlobalValue) -> @unsafe.LLVMValueRef {
  self.value.as_value_ref()
}

///| Get the name of the `GlobalValue`.
pub fn GlobalValue::get_name(self: GlobalValue) -> String {
  self.value.get_name()
}

////| Set name of the `GlobalValue`.
pub fn GlobalValue::set_name(self: GlobalValue, name: String) -> Unit {
  self.value.set_name(name)
}

///| Get the previous global value in the module.
pub fn GlobalValue::get_previous_global(self: GlobalValue) -> GlobalValue? {
  let value_ref = @unsafe.llvm_get_previous_global(self.as_value_ref())
  
  if value_ref.is_null() {
    None
  } else {
    Some(GlobalValue::new(value_ref))
  }
}

///| Get the next global value in the module.
pub fn GlobalValue::get_next_global(self: GlobalValue) -> GlobalValue? {
  let value_ref = @unsafe.llvm_get_next_global(self.as_value_ref())
  
  if value_ref.is_null() {
    None
  } else {
    Some(GlobalValue::new(value_ref))
  }
}

pub fn GlobalValue::get_dll_storge_class(self: GlobalValue) -> DLLStorageClass {
  let dc = @unsafe.llvm_get_dll_storage_class(self.as_value_ref())
  DLLStorageClass::from(dc)
}

// TODO: enable it when `@unsafe.llvm_set_dll_storage_class` is available
// pub fn GlobalValue::set_dll_storage_class(self: GlobalValue, storage_class: DLLStorageClass) -> Unit {
//   @unsafe.llvm_set_dll_storage_class(self.as_value_ref(), storage_class)
// }

pub fn GlobalValue::get_initializer(self: GlobalValue) -> Option[BasicValueEnum] {
  let value_ref = @unsafe.llvm_get_initializer(self.as_value_ref())

  if value_ref.is_null() {
    None
  } else {
    Some(BasicValueEnum::new(value_ref))
  }
}

pub fn GlobalValue::set_initializer(self: GlobalValue, value: BasicValueEnum) -> Unit {
  @unsafe.llvm_set_initializer(self.as_value_ref(), value.as_value_ref())
}

pub fn GlobalValue::is_thread_local(self: GlobalValue) -> Bool {
  @unsafe.llvm_is_thread_local(self.as_value_ref())
}

pub fn GlobalValue::set_thread_local(self: GlobalValue, is_thread_local: Bool) -> Unit {
  @unsafe.llvm_set_thread_local(self.as_value_ref(), is_thread_local)
}

pub fn GlobalValue::get_thread_local_mode(self: GlobalValue) -> ThreadLocalMode {
  let t = @unsafe.llvm_get_thread_local_mode(self.as_value_ref())
  ThreadLocalMode::from(t)
}

pub fn GlobalValue::set_thread_local_mode(
  self: GlobalValue,
  thread_local_mode: ThreadLocalMode
) -> Unit {
  @unsafe.llvm_set_thread_local_mode(self.as_value_ref(), thread_local_mode.into())
}

///| Determines whether or not a `GlobalValue` is a declaration or a definition.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let builder = context.create_builder();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([], false);
/// let fn_value = module.add_function("my_func", fn_type, None);
///
/// assert!(fn_value.as_global_value().is_declaration());
///
/// context.append_basic_block(fn_value, "entry");
///
/// assert_true!(!fn_value.as_global_value().is_declaration());
/// ```
pub fn GlobalValue::is_declaration(self: GlobalValue) -> Bool {
  @unsafe.llvm_is_declaration(self.as_value_ref())
}

pub fn GlobalValue::has_unnamed_addr(self: GlobalValue) -> Bool {
  @unsafe.llvm_get_unnamed_address(self.as_value_ref()) == @unsafe.LLVMUnnamedAddr::LLVMGlobalUnnamedAddr
}

// REVIEW: Would use `UnnamedAddr` instead of `@unsafe.LLVMUnnamedAddr` be better?
pub fn GlobalValue::set_unnamed_addr(self: GlobalValue, has_unnamed_addr: Bool) -> Unit {
  // @unsafe.llvm_set_unnamed_addr(self.as_value_ref(), has_unnamed_addr)
  if has_unnamed_addr {
    @unsafe.llvm_set_unnamed_address(self.as_value_ref(), @unsafe.LLVMUnnamedAddr::LLVMGlobalUnnamedAddr)
  } else {
    @unsafe.llvm_set_unnamed_address(self.as_value_ref(), @unsafe.LLVMUnnamedAddr::LLVMNoUnnamedAddr)
  }
}

pub fn GlobalValue::is_constant(self: GlobalValue) -> Bool {
  @unsafe.llvm_is_global_constant(self.as_value_ref())
}

pub fn GlobalValue::set_constant(self: GlobalValue, is_constant: Bool) -> Unit {
  @unsafe.llvm_set_global_constant(self.as_value_ref(), is_constant)
}

pub fn GlobalValue::is_externally_initialized(self: GlobalValue) -> Bool {
  @unsafe.llvm_is_externally_initialized(self.as_value_ref())
}

pub fn GlobalValue::set_externally_initialized(self: GlobalValue, is_externally_initialized: Bool) -> Unit {
  @unsafe.llvm_set_externally_initialized(self.as_value_ref(), is_externally_initialized)
}

pub fn GlobalValue::set_visibility(self: GlobalValue, visibility: GlobalVisibility) -> Unit {
  @unsafe.llvm_set_visibility(self.as_value_ref(), visibility.into())
}

pub fn GlobalVisibility::get_visibility(self: GlobalValue) -> GlobalVisibility {
  let v = @unsafe.llvm_get_visibility(self.as_value_ref())
  GlobalVisibility::from(v)
}

pub fn GlobalValue::get_section(self: GlobalValue) -> String {
  @unsafe.llvm_get_section(self.as_value_ref())
}

pub fn GlobalValue::set_section(self: GlobalValue, section: String) -> Unit {
  @unsafe.llvm_set_section(self.as_value_ref(), section)
}

pub fn GlobalValue::delete(self: GlobalValue) -> Unit {
  @unsafe.llvm_delete_global(self.as_value_ref())
}

///| Attempt to convert this `GlobalValue` to a `PointerValue`, if possible.
pub fn GlobalValue::as_pointer_value(self: GlobalValue) -> PointerValue {
  PointerValue::new(self.as_value_ref())
}

pub fn GlobalValue::get_alignment(self: GlobalValue) -> UInt {
  @unsafe.llvm_get_alignment(self.as_value_ref())
}

pub fn GlobalValue::set_alignment(self: GlobalValue, alignment: UInt) -> Unit {
  @unsafe.llvm_set_alignment(self.as_value_ref(), alignment)
}

pub fn GlobalValue::set_metadata(
  self: GlobalValue, metadata: MetadataValue, kind_id: UInt
) -> Unit {
  @unsafe.llvm_global_set_metadata(self.as_value_ref(), kind_id, metadata.as_metadata_ref())
}

// TODO: enable it when `@unsafe.llvm_get_metadata` is available
pub fn GlobalValue::get_comdat(self: GlobalValue) -> Comdat? {
  let comdat_ref = @unsafe.llvm_get_comdat(self.as_value_ref())

  if comdat_ref.is_null() {
    None
  } else {
    Some(Comdat::new(comdat_ref))
  }
}

pub fn GlobalValue::set_unnamed_address(
  self: GlobalValue, unnamed_address: UnnamedAddress
) -> Unit {
  @unsafe.llvm_set_unnamed_address(self.as_value_ref(), unnamed_address.into())
}

///| Get the linkage of the `GlobalValue`.
pub fn GlobalValue::get_linkage(self: GlobalValue) -> Linkage {
  let linkage = @unsafe.llvm_get_linkage(self.as_value_ref())
  Linkage::from(linkage)
}

///| Set the linkage of the `GlobalValue`.
pub fn GlobalValue::set_linkage(self: GlobalValue, linkage: Linkage) -> Unit {
  @unsafe.llvm_set_linkage(self.as_value_ref(), linkage.into())
}

///| Get the type of the `GlobalValue`.
pub fn GlobalValue::get_value_type(self: GlobalValue) -> AnyTypeEnum {
  let ty = @unsafe.llvm_global_get_value_type(self.as_value_ref())
  AnyTypeEnum::new(ty)
}

///| Dumps the `GlobalValue` to stderr.
///
/// It's equivalent to `GlobalValue::dump`.
pub fn GlobalValue::print_to_stderr(self: GlobalValue) -> Unit {
  self.value.print_to_stderr()
}

///| Dumps the `GlobalValue` to a string.
///
/// It's equivalent to `GlobalValue::to_string`.
pub fn GlobalValue::print_to_string(self: GlobalValue) -> String {
  self.value.print_to_string()
}

///| Dumps the `GlobalValue` to a string.
///
/// It's equivalent to `GlobalValue::print_to_string`.
pub fn GlobalValue::to_string(self: GlobalValue) -> String {
  self.value.to_string()
}

///| Dumps the `GlobalValue` to stderr.
///
/// It's equivalent to `GlobalValue::print_to_stderr`.
pub fn GlobalValue::dump(self: GlobalValue) -> Unit {
  self.value.dump()
}

pub impl Show for GlobalValue with output(self: GlobalValue, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for GlobalValue with to_string(self: GlobalValue) -> String {
  self.to_string()
}


