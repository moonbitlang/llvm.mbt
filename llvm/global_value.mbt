// ============================================
// GlobalValue
// ============================================

///| A `GlobalValue` is a value that represents a global variable.
pub struct GlobalValue {
  value : ValueRef
}

///| Creates a new `GlobalValue` from an `@unsafe.LLVMValueRef`.
pub fn GlobalValue::new(value_ref : @unsafe.LLVMValueRef) -> GlobalValue {
  guard value_ref.is_not_null()
  GlobalValue::{ value: ValueRef::new(value_ref) }
}

pub impl Value for GlobalValue with base(self) {
  self.value
}

pub impl Value for GlobalValue with as_value_enum(self) {
  GlobalValue(self)
}

///| Get the name of the `GlobalValue`.
pub fn GlobalValue::get_name(self : GlobalValue) -> String {
  self.value.get_name()
}

///| Set name of the `GlobalValue`.
pub fn GlobalValue::set_name(self : GlobalValue, name : String) -> Unit {
  self.value.set_name(name)
}

///| Get the previous global value in the module.
pub fn GlobalValue::get_previous_global(self : GlobalValue) -> GlobalValue? {
  let value_ref = @unsafe.llvm_get_previous_global(self.inner())
  if value_ref.is_null() {
    None
  } else {
    Some(GlobalValue::new(value_ref))
  }
}

///| Get the next global value in the module.
pub fn GlobalValue::get_next_global(self : GlobalValue) -> GlobalValue? {
  let value_ref = @unsafe.llvm_get_next_global(self.inner())
  if value_ref.is_null() {
    None
  } else {
    Some(GlobalValue::new(value_ref))
  }
}

///|
pub fn GlobalValue::get_dll_storage_class(
  self : GlobalValue
) -> DLLStorageClass {
  let dc = @unsafe.llvm_get_dll_storage_class(self.inner())
  DLLStorageClass::from(dc)
}

// TODO: enable it when `@unsafe.llvm_set_dll_storage_class` is available
// pub fn GlobalValue::set_dll_storage_class(self: GlobalValue, storage_class: DLLStorageClass) -> Unit {
//   @unsafe.llvm_set_dll_storage_class(self.inner(), storage_class)
// }

///|
pub fn GlobalValue::get_initializer(self : GlobalValue) -> &BasicValue? {
  let value_ref = @unsafe.llvm_get_initializer(self.inner())
  if value_ref.is_null() {
    None
  } else {
    Some(BasicValueEnum::init(value_ref).as_basic_value_class())
  }
}

///|
pub fn GlobalValue::set_initializer(
  self : GlobalValue,
  value : &BasicValue
) -> Unit {
  @unsafe.llvm_set_initializer(self.inner(), value.inner())
}

///|
pub fn GlobalValue::is_thread_local(self : GlobalValue) -> Bool {
  @unsafe.llvm_is_thread_local(self.inner())
}

///|
pub fn GlobalValue::set_thread_local(
  self : GlobalValue,
  is_thread_local : Bool
) -> Unit {
  @unsafe.llvm_set_thread_local(self.inner(), is_thread_local)
}

///|
pub fn GlobalValue::get_thread_local_mode(
  self : GlobalValue
) -> ThreadLocalMode {
  let t = @unsafe.llvm_get_thread_local_mode(self.inner())
  ThreadLocalMode::from(t)
}

///|
pub fn GlobalValue::set_thread_local_mode(
  self : GlobalValue,
  thread_local_mode : ThreadLocalMode
) -> Unit {
  @unsafe.llvm_set_thread_local_mode(
    self.inner(),
    thread_local_mode.into(),
  )
}

///| Determines whether or not a `GlobalValue` is a declaration or a definition.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip skip (function not implement as_global_value yet)
/// let context = Context::create();
/// let builder = context.create_builder();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = module.add_function("my_func", fn_type);
///
/// assert_true(fn_value.as_global_value().is_declaration());
///
/// let _ = context.append_basic_block(fn_value, name="entry");
///
/// assert_false(fn_value.as_global_value().is_declaration());
/// ```
pub fn GlobalValue::is_declaration(self : GlobalValue) -> Bool {
  @unsafe.llvm_is_declaration(self.inner())
}

///|
pub fn GlobalValue::has_unnamed_addr(self : GlobalValue) -> Bool {
  @unsafe.llvm_get_unnamed_address(self.inner()) ==
  @unsafe.LLVMUnnamedAddr::LLVMGlobalUnnamedAddr
}

// REVIEW: Would use `UnnamedAddr` instead of `@unsafe.LLVMUnnamedAddr` be better?

///|
pub fn GlobalValue::set_unnamed_addr(
  self : GlobalValue,
  has_unnamed_addr : Bool
) -> Unit {
  // @unsafe.llvm_set_unnamed_addr(self.inner(), has_unnamed_addr)
  if has_unnamed_addr {
    @unsafe.llvm_set_unnamed_address(
      self.inner(),
      @unsafe.LLVMUnnamedAddr::LLVMGlobalUnnamedAddr,
    )
  } else {
    @unsafe.llvm_set_unnamed_address(
      self.inner(),
      @unsafe.LLVMUnnamedAddr::LLVMNoUnnamedAddr,
    )
  }
}

///|
pub fn GlobalValue::is_constant(self : GlobalValue) -> Bool {
  @unsafe.llvm_is_global_constant(self.inner())
}

///|
pub fn GlobalValue::set_constant(
  self : GlobalValue,
  is_constant : Bool
) -> Unit {
  @unsafe.llvm_set_global_constant(self.inner(), is_constant)
}

///|
pub fn GlobalValue::is_externally_initialized(self : GlobalValue) -> Bool {
  @unsafe.llvm_is_externally_initialized(self.inner())
}

///|
pub fn GlobalValue::set_externally_initialized(
  self : GlobalValue,
  is_externally_initialized : Bool
) -> Unit {
  @unsafe.llvm_set_externally_initialized(
    self.inner(),
    is_externally_initialized,
  )
}

///|
pub fn GlobalValue::set_visibility(
  self : GlobalValue,
  visibility : GlobalVisibility
) -> Unit {
  @unsafe.llvm_set_visibility(self.inner(), visibility.into())
}

///|
pub fn GlobalVisibility::get_visibility(self : GlobalValue) -> GlobalVisibility {
  let v = @unsafe.llvm_get_visibility(self.inner())
  GlobalVisibility::from(v)
}

///|
pub fn GlobalValue::get_section(self : GlobalValue) -> String {
  @unsafe.llvm_get_section(self.inner())
}

///|
pub fn GlobalValue::set_section(self : GlobalValue, section : String) -> Unit {
  @unsafe.llvm_set_section(self.inner(), section)
}

///|
pub fn GlobalValue::delete(self : GlobalValue) -> Unit {
  @unsafe.llvm_delete_global(self.inner())
}

///| Attempt to convert this `GlobalValue` to a `PointerValue`, if possible.
pub fn GlobalValue::as_pointer_value(self : GlobalValue) -> PointerValue {
  PointerValue::new(self.inner())
}

///|
pub fn GlobalValue::get_alignment(self : GlobalValue) -> UInt {
  @unsafe.llvm_get_alignment(self.inner())
}

///|
pub fn GlobalValue::set_alignment(self : GlobalValue, alignment : UInt) -> Unit {
  @unsafe.llvm_set_alignment(self.inner(), alignment)
}

///|
pub fn GlobalValue::set_metadata(
  self : GlobalValue,
  metadata : MetadataValue,
  kind_id : UInt
) -> Unit {
  @unsafe.llvm_global_set_metadata(
    self.inner(),
    kind_id,
    metadata.as_metadata_ref(),
  )
}

// TODO: enable it when `@unsafe.llvm_get_metadata` is available

///|
pub fn GlobalValue::get_comdat(self : GlobalValue) -> Comdat? {
  let comdat_ref = @unsafe.llvm_get_comdat(self.inner())
  if comdat_ref.is_null() {
    None
  } else {
    Some(Comdat::new(comdat_ref))
  }
}

///|
pub fn GlobalValue::set_unnamed_address(
  self : GlobalValue,
  unnamed_address : UnnamedAddress
) -> Unit {
  @unsafe.llvm_set_unnamed_address(self.inner(), unnamed_address.into())
}

///| Get the linkage of the `GlobalValue`.
pub fn GlobalValue::get_linkage(self : GlobalValue) -> Linkage {
  let linkage = @unsafe.llvm_get_linkage(self.inner())
  Linkage::from(linkage)
}

///| Set the linkage of the `GlobalValue`.
pub fn GlobalValue::set_linkage(self : GlobalValue, linkage : Linkage) -> Unit {
  @unsafe.llvm_set_linkage(self.inner(), linkage.into())
}

///| Get the type of the `GlobalValue`.
pub fn GlobalValue::get_value_type(self : GlobalValue) -> &Type {
  let ty = @unsafe.llvm_global_get_value_type(self.inner())
  TypeEnum::init(ty).as_type_class()
}

///|
pub impl Show for GlobalValue with output(self : GlobalValue, logger : &Logger) -> Unit {
  logger.write_string(self.value.to_string())
}

///|
pub impl Eq for GlobalValue with op_equal(
  self : GlobalValue,
  other : GlobalValue
) -> Bool {
  self.inner() == other.inner()
}
