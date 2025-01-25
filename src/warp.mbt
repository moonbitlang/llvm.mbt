// Utils
extern "C" fn moonbit_str_to_c_str(
  s: String
) -> CStr = "moonbit_str_to_c_str"
extern "C" fn c_str_to_moonbit_str(
  s: CStr
) -> String = "c_str_to_moonbit_str"
extern "C" fn llvm_type_is_null(ty: LLVMTypeRef) -> LLVMBool = "__llvm_type_is_null"
pub fn LLVMTypeRef::is_null(self: LLVMTypeRef) -> Bool {
  llvm_type_is_null(self).to_moonbit_bool()
}

extern "C" fn llvm_value_is_null(ty: LLVMValueRef) -> LLVMBool = "__llvm_value_is_null"
pub fn LLVMValueRef::is_null(self: LLVMValueRef) -> Bool {
  llvm_value_is_null(self).to_moonbit_bool()
}

extern "C" fn llvm_use_is_null(u: LLVMUseRef) -> LLVMBool = "__llvm_use_is_null"
pub fn LLVMUseRef::is_null(self: LLVMUseRef) -> Bool {
  llvm_use_is_null(self).to_moonbit_bool()
}

extern "C" fn llvm_bb_is_null(bb: LLVMBasicBlockRef) -> LLVMBool = "__llvm_bb_is_null"
pub fn LLVMBasicBlockRef::is_null(self: LLVMBasicBlockRef) -> Bool {
  llvm_bb_is_null(self).to_moonbit_bool()
}

pub extern "C" fn llvm_shutdown() = "__llvm_shutdown"

// FIXME: Not implemented
// 
// Return the major, minor, and patch version of LLVM
// 
// The version components are returned via the function's three output
// parameters or skipped if a NULL pointer was supplied.
// 
pub extern "C" fn llvm_get_version() -> (UInt, UInt, UInt) = "__llvm_get_version"

pub extern "C" fn llvm_create_message(message: CStr) -> CStr = "__llvm_create_message"

pub extern "C" fn llvm_dispose_message(message: CStr) = "__llvm_dispose_message"

///| Create a new context.
/// 
/// Every call to this function should be paired with a call to
/// `llvm_context_dispose()` or the context will leak memory.
pub extern "C" fn llvm_context_create() -> LLVMContextRef = "__llvm_context_create"

///| Obtain the global context instance.
/// 
pub extern "C" fn llvm_get_global_context() -> LLVMContextRef = "__llvm_get_global_context"

// pub extern "C" fn llvm_context_set_diagnostic_handler(context: LLVMContextRef, handler: LLVMDiagnosticHandler, diagnostic_context: Ptr[Void]) = "__llvm_context_set_diagnostic_handler"

// pub extern "C" fn llvm_context_get_diagnostic_context(context: LLVMContextRef) -> Ptr[Void] = "__llvm_context_get_diagnostic_context"

// pub extern "C" fn llvm_context_set_yield_callback(context: LLVMContextRef, callback: LLVMYieldCallback, opaque_handle: Ptr[Void]) = "__llvm_context_set_yield_callback"


///| Retrieve whether the given context is set to discard all value names.
///
/// see `LLVMContext::shouldDiscardValueNames()`
pub extern "C" fn llvm_context_should_discard_value_names(context: LLVMContextRef) -> LLVMBool = "__llvm_context_should_discard_value_names"
pub fn LLVMContextRef::should_discard_value_names(self: LLVMContextRef) -> Bool {
  llvm_context_should_discard_value_names(self).to_moonbit_bool()
}

///| Set whether the given context discards all value names.
/// 
/// If true, only the names of GlobalValue objects will be available in the IR.
/// This can be used to save memory and runtime, especially in release mode.
/// 
/// see `LLVMContext::setDiscardValueNames()`
extern "C" fn __llvm_context_set_discard_value_names(context: LLVMContextRef, discard: LLVMBool) = "__llvm_context_set_discard_value_names"
pub fn llvm_context_set_discard_value_names(context: LLVMContextRef, discard: Bool) -> Unit {
  __llvm_context_set_discard_value_names(context, to_llvm_bool(discard))
}
pub fn LLVMContextRef::set_discard_value_names(self: LLVMContextRef, discard: Bool) -> Unit {
  __llvm_context_set_discard_value_names(self, to_llvm_bool(discard))
}

///| Destroy a context instance.
/// 
/// This should be called for every call to `llvm_context_create()` or memory
/// will be leaked.
pub extern "C" fn llvm_context_dispose(context: LLVMContextRef) = "__llvm_context_dispose"
pub fn LLVMContextRef::dispose(self: LLVMContextRef) -> Unit {
  llvm_context_dispose(self)
}


///| Return a string representation of the DiagnosticInfo. Use `llvm_dispose_message` to free the string.
/// 
/// see `DiagnosticInfo::print()`
/// 
extern "C" fn __llvm_get_diag_info_description(di: LLVMDiagnosticInfoRef) -> CStr = "__llvm_get_diag_info_description"
pub fn llvm_get_diag_info_description(di: LLVMDiagnosticInfoRef) -> String {
  let cstr = __llvm_get_diag_info_description(di)
  c_str_to_moonbit_str(cstr)
}


///| Return an enum llvm_diagnostic_severity.
/// 
/// see `DiagnosticInfo::getSeverity()`
/// 
pub extern "C" fn llvm_get_diag_info_severity(di: LLVMDiagnosticInfoRef) -> Int = "__llvm_get_diag_info_severity"
pub fn LLVMDiagnosticInfoRef::get_severity(self: LLVMDiagnosticInfoRef) -> LLVMDiagnosticSeverity {
  LLVMDiagnosticSeverity::from_int(llvm_get_diag_info_severity(self))
}

// TODO: Warp it
pub extern "C" fn llvm_get_md_kind_id_in_context(context: LLVMContextRef, name: CStr, s_len: UInt) -> UInt = "__llvm_get_md_kind_id_in_context"

pub extern "C" fn llvm_get_md_kind_id(name: CStr, s_len: UInt) -> UInt = "__llvm_get_md_kind_id"

pub extern "C" fn llvm_get_enum_attribute_kind_for_name(name: CStr, s_len: UInt64) -> UInt = "__llvm_get_enum_attribute_kind_for_name"

pub extern "C" fn llvm_get_last_enum_attribute_kind() -> UInt = "__llvm_get_last_enum_attribute_kind"

// Create an enum attribute.
pub extern "C" fn llvm_create_enum_attribute(context: LLVMContextRef, kind_id: UInt, val: UInt64) -> LLVMAttributeRef = "__llvm_create_enum_attribute"

///| Get the unique id corresponding to the enum attribute passed as argument.
pub extern "C" fn llvm_get_enum_attribute_kind(a: LLVMAttributeRef) -> UInt = "__llvm_get_enum_attribute_kind"
pub fn LLVMAttributeRef::get_enum_attribute_kind(self: LLVMAttributeRef) -> UInt {
  llvm_get_enum_attribute_kind(self)
}

///| Get the enum attribute's value. 0 is returned if none exists.
pub extern "C" fn llvm_get_enum_attribute_value(a: LLVMAttributeRef) -> UInt64 = "__llvm_get_enum_attribute_value"
pub fn LLVMAttributeRef::get_enum_attribute_value(self: LLVMAttributeRef) -> UInt64 {
  llvm_get_enum_attribute_value(self)
}

///| Create a type attribute
pub extern "C" fn llvm_create_type_attribute(context: LLVMContextRef, kind_id: UInt, type_ref: LLVMTypeRef) -> LLVMAttributeRef = "__llvm_create_type_attribute"

///| Get the type attribute's value.
pub extern "C" fn llvm_get_type_attribute_value(a: LLVMAttributeRef) -> LLVMTypeRef = "__llvm_get_type_attribute_value"
pub fn LLVMAttributeRef::get_type_attribute_value(self: LLVMAttributeRef) -> LLVMTypeRef {
  llvm_get_type_attribute_value(self)
}

// pub extern "C" fn llvm_get_string_attribute_kind(a: LLVMAttributeRef, length: Ptr[UInt]) -> CStr = "__llvm_get_string_attribute_kind"
//
// pub extern "C" fn llvm_get_string_attribute_value(a: LLVMAttributeRef, length: Ptr[UInt]) -> CStr = "__llvm_get_string_attribute_value"

///| Check if the attribute is an enum attribute.
extern "C" fn __llvm_is_enum_attribute(a: LLVMAttributeRef) -> LLVMBool = "__llvm_is_enum_attribute"
pub fn llvm_is_enum_attribute(a: LLVMAttributeRef) -> Bool {
  __llvm_is_enum_attribute(a).to_moonbit_bool()
}
pub fn LLVMAttributeRef::is_enum_attribute(self: LLVMAttributeRef) -> Bool {
  __llvm_is_enum_attribute(self).to_moonbit_bool()
}

///| Check if the attribute is a string attribute.
extern "C" fn __llvm_is_string_attribute(a: LLVMAttributeRef) -> LLVMBool = "__llvm_is_string_attribute"
pub fn llvm_is_string_attribute(a: LLVMAttributeRef) -> Bool {
  __llvm_is_string_attribute(a).to_moonbit_bool()
}
pub fn LLVMAttributeRef::is_string_attribute(self: LLVMAttributeRef) -> Bool {
  __llvm_is_string_attribute(self).to_moonbit_bool()
}

///| Check if the attribute is a type attribute.
extern "C" fn __llvm_is_type_attribute(a: LLVMAttributeRef) -> LLVMBool = "__llvm_is_type_attribute"
pub fn llvm_is_type_attribute(a: LLVMAttributeRef) -> Bool {
  __llvm_is_type_attribute(a).to_moonbit_bool()
}
pub fn LLVMAttributeRef::is_type_attribute(self: LLVMAttributeRef) -> Bool {
  __llvm_is_type_attribute(self).to_moonbit_bool()
}

///| Obtain a Type from a context by its registered name.
extern "C" fn __llvm_get_type_by_name(context: LLVMContextRef, name: CStr) -> LLVMTypeRef = "__llvm_get_type_by_name"
pub fn llvm_get_type_by_name(context: LLVMContextRef, name: String) -> LLVMTypeRef {
  let cstr = moonbit_str_to_c_str(name)
  __llvm_get_type_by_name(context, cstr)
}
pub fn LLVMContextRef::get_type_by_name(self: LLVMContextRef, name: String) -> LLVMTypeRef {
  llvm_get_type_by_name(self, name)
}

///| Create a new, empty module in the global context.
/// 
/// This is equivalent to calling `LLVMModuleCreateWithNameInContext` with
/// `LLVMGetGlobalContext()` as the context parameter.
/// 
/// Every invocation should be paired with `LLVMDisposeModule()` or memory
/// will be leaked.
/// 
extern "C" fn __llvm_module_create_with_name(module_id: CStr) -> LLVMModuleRef = "__llvm_module_create_with_name"
pub fn llvm_module_create_with_name(module_id: String) -> LLVMModuleRef {
  let cstr = moonbit_str_to_c_str(module_id)
  __llvm_module_create_with_name(cstr)
}

/// Create a new, empty module in the global context.
/// 
/// This is equivalent to calling LLVMModuleCreateWithNameInContext with
/// LLVMGetGlobalContext() as the context parameter.
/// 
/// Every invocation should be paired with LLVMDisposeModule() or memory
/// will be leaked.
/// 
extern "C" fn __llvm_module_create_with_name_in_context(module_id: CStr, context: LLVMContextRef) -> LLVMModuleRef = "__llvm_module_create_with_name_in_context"
pub fn llvm_module_create_with_name_in_context(module_id: String, context: LLVMContextRef) -> LLVMModuleRef {
  let cstr = moonbit_str_to_c_str(module_id)
  __llvm_module_create_with_name_in_context(cstr, context)
}
pub fn LLVMContextRef::module_create_with_name(self: LLVMContextRef, module_id: String) -> LLVMModuleRef {
  llvm_module_create_with_name_in_context(module_id, self)
}

///| Return an exact copy of the specified module.
pub extern "C" fn llvm_clone_module(m: LLVMModuleRef) -> LLVMModuleRef = "__llvm_clone_module"
pub fn LLVMModuleRef::clone(self: LLVMModuleRef) -> LLVMModuleRef {
  llvm_clone_module(self)
}

///| Destroy a module instance.
/// 
/// This must be called for every created module or memory will be
/// leaked.
/// 
pub extern "C" fn llvm_dispose_module(m: LLVMModuleRef) = "__llvm_dispose_module"
pub fn LLVMModuleRef::dispose(self: LLVMModuleRef) -> Unit {
  llvm_dispose_module(self)
}

// Note: Soon to be deprecated
extern "C" fn __llvm_is_new_dbg_info_format(m: LLVMModuleRef) -> LLVMBool = "__llvm_is_new_dbg_info_format"
pub fn llvm_is_new_dbg_info_format(m: LLVMModuleRef) -> Bool {
  __llvm_is_new_dbg_info_format(m).to_moonbit_bool()
}
pub fn LLVMModuleRef::is_new_dbg_info_format(self: LLVMModuleRef) -> Bool {
  __llvm_is_new_dbg_info_format(self).to_moonbit_bool()
}

// Note: Soon to be deprecated
extern "C" fn __llvm_set_is_new_dbg_info_format(m: LLVMModuleRef, use_new_format: LLVMBool) = "__llvm_set_is_new_dbg_info_format"
pub fn llvm_set_is_new_dbg_info_format(m: LLVMModuleRef, use_new_format: Bool) -> Unit {
  __llvm_set_is_new_dbg_info_format(m, to_llvm_bool(use_new_format))
}

// pub extern "C" fn llvm_get_module_identifier(m: LLVMModuleRef, len: Ptr[UInt64]) -> CStr = "__llvm_get_module_identifier"

pub extern "C" fn llvm_set_module_identifier(m: LLVMModuleRef, ident: CStr, len: UInt64) = "__llvm_set_module_identifier"

// /**
//  * Obtain the module's original source file name.
//  *
//  * @param M Module to obtain the name of
//  * @param Len Out parameter which holds the length of the returned string
//  * @return The original source file name of M
//  * @see Module::getSourceFileName()
//  */
// pub extern "C" fn llvm_get_source_file_name(m: LLVMModuleRef, len: Ptr[UInt64]) -> CStr = "__llvm_get_source_file_name"

// 
// Set the original source file name of a module to a string Name with length
// Len.
// 
// @param M The module to set the source file name of
// @param Name The string to set M's source file name to
// @param Len Length of Name
// @see Module::setSourceFileName()
// 
pub extern "C" fn llvm_set_source_file_name(m: LLVMModuleRef, name: CStr, len: UInt64) = "__llvm_set_source_file_name"


///| Obtain the data layout for a module.
/// 
/// see Module::getDataLayoutStr()
/// 
/// LLVMGetDataLayout is DEPRECATED, as the name is not only incorrect,
/// but match the name of another method on the module. Prefer the use
/// of LLVMGetDataLayoutStr, which is not ambiguous.
/// 
extern "C" fn __llvm_get_data_layout_str(m: LLVMModuleRef) -> CStr = "__llvm_get_data_layout_str"
pub fn llvm_get_data_layout_str(m: LLVMModuleRef) -> String {
  let cstr = __llvm_get_data_layout_str(m)
  c_str_to_moonbit_str(cstr)
}
pub fn LLVMModuleRef::get_data_layout_str(self: LLVMModuleRef) -> String {
  llvm_get_data_layout_str(self)
}

extern "C" fn __llvm_get_data_layout(m: LLVMModuleRef) -> CStr = "__llvm_get_data_layout"
pub fn llvm_get_data_layout(m: LLVMModuleRef) -> String {
  let cstr = __llvm_get_data_layout(m)
  c_str_to_moonbit_str(cstr)
}
pub fn LLVMModuleRef::get_data_layout(self: LLVMModuleRef) -> String {
  llvm_get_data_layout(self)
}

///| Set the data layout for a module.
/// 
/// see Module::setDataLayout()
/// 
extern "C" fn __llvm_set_data_layout(m: LLVMModuleRef, data_layout_str: CStr) = "__llvm_set_data_layout"
pub fn llvm_set_data_layout(m: LLVMModuleRef, data_layout_str: String) -> Unit {
  let cstr = moonbit_str_to_c_str(data_layout_str)
  __llvm_set_data_layout(m, cstr)
}
pub fn LLVMModuleRef::set_data_layout(self: LLVMModuleRef, data_layout_str: String) -> Unit {
  llvm_set_data_layout(self, data_layout_str)
}
// 
// Obtain the target triple for a module.
// 
// @see Module::getTargetTriple()
// 
extern "C" fn __llvm_get_target(m: LLVMModuleRef) -> CStr = "__llvm_get_target"
pub fn llvm_get_target(m: LLVMModuleRef) -> String {
  let cstr = __llvm_get_target(m)
  c_str_to_moonbit_str(cstr)
}
pub fn LLVMModuleRef::get_target(self: LLVMModuleRef) -> String {
  llvm_get_target(self)
}


// /**
//  * Set the target triple for a module.
//  *
//  * @see Module::setTargetTriple()
//  */
extern "C" fn __llvm_set_target(m: LLVMModuleRef, triple: CStr) = "__llvm_set_target"
pub fn llvm_set_target(m: LLVMModuleRef, triple: String) -> Unit {
  let cstr = moonbit_str_to_c_str(triple)
  __llvm_set_target(m, cstr)
}
pub fn LLVMModuleRef::set_target(self: LLVMModuleRef, triple: String) -> Unit {
  llvm_set_target(self, triple)
}

// /**
//  * Returns the module flags as an array of flag-key-value triples.  The caller
//  * is responsible for freeing this array by calling
//  * \c LLVMDisposeModuleFlagsMetadata.
//  *
//  * @see Module::getModuleFlagsMetadata()
//  */
// pub extern "C" fn llvm_copy_module_flags_metadata(m: LLVMModuleRef, len: Ptr[UInt64]) -> Ptr[LLVMModuleFlagEntry] = "__llvm_copy_module_flags_metadata"


// /**
//  * Destroys module flags metadata entries.
//  */
// pub extern "C" fn llvm_dispose_module_flags_metadata(entries: Ptr[LLVMModuleFlagEntry]) = "__llvm_dispose_module_flags_metadata"


// /**
//  * Returns the flag behavior for a module flag entry at a specific index.
//  *
//  * @see Module::ModuleFlagEntry::Behavior
//  */
// pub extern "C" fn llvm_module_flag_entries_get_flag_behavior(entries: Ptr[LLVMModuleFlagEntry], index: UInt) -> LLVMModuleFlagBehavior = "__llvm_module_flag_entries_get_flag_behavior"


// /**
//  * Returns the key for a module flag entry at a specific index.
//  *
//  * @see Module::ModuleFlagEntry::Key
//  */
// pub extern "C" fn llvm_module_flag_entries_get_key(entries: Ptr[LLVMModuleFlagEntry], index: UInt, len: Ptr[UInt64]) -> CStr = "__llvm_module_flag_entries_get_key"


// /**
//  * Returns the metadata for a module flag entry at a specific index.
//  *
//  * @see Module::ModuleFlagEntry::Val
//  */
// pub extern "C" fn llvm_module_flag_entries_get_metadata(entries: Ptr[LLVMModuleFlagEntry], index: UInt) -> LLVMMetadataRef = "__llvm_module_flag_entries_get_metadata"


// /**
//  * Add a module-level flag to the module-level flags metadata if it doesn't
//  * already exist.
//  *
//  * @see Module::getModuleFlag()
//  */
pub extern "C" fn llvm_get_module_flag(m: LLVMModuleRef, key: CStr, key_len: UInt64) -> LLVMMetadataRef = "__llvm_get_module_flag"


// /**
//  * Add a module-level flag to the module-level flags metadata if it doesn't
//  * already exist.
//  *
//  * @see Module::addModuleFlag()
//  */
pub extern "C" fn llvm_add_module_flag(m: LLVMModuleRef, behavior: LLVMModuleFlagBehavior, key: CStr, key_len: UInt64, val: LLVMMetadataRef) = "__llvm_add_module_flag"


// /**
//  * Dump a representation of a module to stderr.
//  *
//  * @see Module::dump()
//  */
pub extern "C" fn llvm_dump_module(m: LLVMModuleRef) = "__llvm_dump_module"
pub fn LLVMModuleRef::dump(self: LLVMModuleRef) -> Unit {
  llvm_dump_module(self)
}

// /**
//  * Print a representation of a module to a file. The ErrorMessage needs to be
//  * disposed with LLVMDisposeMessage. Returns 0 on success, 1 otherwise.
//  *
//  * @see Module::print()
//  */
// pub extern "C" fn llvm_print_module_to_file(m: LLVMModuleRef, filename: CStr, error_message: Ptr[CStr]) -> LLVMBool = "__llvm_print_module_to_file"

// /**
//  * Return a string representation of the module. Use
//  * LLVMDisposeMessage to free the string.
//  *
//  * @see Module::print()
//  */
extern "C" fn __llvm_print_module_to_string(m: LLVMModuleRef) -> CStr = "__llvm_print_module_to_string"
pub fn llvm_print_module_to_string(m: LLVMModuleRef) -> String {
  let cstr = __llvm_print_module_to_string(m)
  c_str_to_moonbit_str(cstr)
}
pub fn LLVMModuleRef::print_to_string(self: LLVMModuleRef) -> String {
  llvm_print_module_to_string(self)
}
pub fn LLVMModuleRef::to_string(self: LLVMModuleRef) -> String {
  llvm_print_module_to_string(self)
}

// /**
//  * Get inline assembly for a module.
//  *
//  * @see Module::getModuleInlineAsm()
//  */
// pub extern "C" fn llvm_get_module_inline_asm(m: LLVMModuleRef, len: Ptr[UInt64]) -> CStr = "__llvm_get_module_inline_asm"


// /**
//  * Set inline assembly for a module.
//  *
//  * @see Module::setModuleInlineAsm()
//  */
pub extern "C" fn llvm_set_module_inline_asm(m: LLVMModuleRef, _asm: CStr, len: UInt64) = "__llvm_set_module_inline_asm"

// /**
//  * Append inline assembly to a module.
//  *
//  * @see Module::appendModuleInlineAsm()
//  */
pub extern "C" fn llvm_append_module_inline_asm(m: LLVMModuleRef, _asm: CStr, len: UInt64) = "__llvm_append_module_inline_asm"


// /**
//  * Create the specified uniqued inline asm string.
//  *
//  * @see InlineAsm::get()
//  */
// pub extern "C" fn llvm_get_inline_asm(ty: LLVMTypeRef, asm_string: CStr, asm_string_size: UInt64, constraints: CStr, constraints_size: UInt64, has_side_effects: LLVMBool, is_align_stack: LLVMBool, dialect: LLVMInlineAsmDialect, can_throw: LLVMBool) -> LLVMValueRef = "__llvm_get_inline_asm"

// /**
//  * Get the template string used for an inline assembly snippet
//  *
//  */
// pub extern "C" fn llvm_get_inline_asm_asm_string(inline_asm_val: LLVMValueRef, len: Ptr[UInt64]) -> CStr = "__llvm_get_inline_asm_asm_string"

// /**
//  * Get the raw constraint string for an inline assembly snippet
//  *
//  */
// pub extern "C" fn llvm_get_inline_asm_constraint_string(inline_asm_val: LLVMValueRef, len: Ptr[UInt64]) -> CStr = "__llvm_get_inline_asm_constraint_string"


// /**
//  * Get the dialect used by the inline asm snippet
//  *
//  */
pub extern "C" fn llvm_get_inline_asm_dialect(inline_asm_val: LLVMValueRef) -> LLVMInlineAsmDialect = "__llvm_get_inline_asm_dialect"
pub fn LLVMValueRef::get_inline_asm_dialect(self: LLVMValueRef) -> LLVMInlineAsmDialect {
  llvm_get_inline_asm_dialect(self)
}


// /**
//  * Get the function type of the inline assembly snippet. The same type that
//  * was passed into LLVMGetInlineAsm originally
//  *
//  * @see LLVMGetInlineAsm
//  *
//  */
pub extern "C" fn llvm_get_inline_asm_function_type(inline_asm_val: LLVMValueRef) -> LLVMTypeRef = "__llvm_get_inline_asm_function_type"
pub fn LLVMValueRef::get_inline_asm_function_type(self: LLVMValueRef) -> LLVMTypeRef {
  llvm_get_inline_asm_function_type(self)
}

// /**
//  * Get if the inline asm snippet has side effects
//  *
//  */
extern "C" fn __llvm_get_inline_asm_has_side_effects(inline_asm_val: LLVMValueRef) -> LLVMBool = "__llvm_get_inline_asm_has_side_effects"
pub fn llvm_get_inline_asm_has_side_effects(inline_asm_val: LLVMValueRef) -> Bool {
  __llvm_get_inline_asm_has_side_effects(inline_asm_val).to_moonbit_bool()
}
pub fn LLVMValueRef::get_inline_asm_has_side_effects(self: LLVMValueRef) -> Bool {
  __llvm_get_inline_asm_has_side_effects(self).to_moonbit_bool()
}

// /**
//  * Get if the inline asm snippet needs an aligned stack
//  *
//  */
extern "C" fn __llvm_get_inline_asm_needs_aligned_stack(inline_asm_val: LLVMValueRef) -> LLVMBool = "__llvm_get_inline_asm_needs_aligned_stack"
pub fn llvm_get_inline_asm_needs_aligned_stack(inline_asm_val: LLVMValueRef) -> Bool {
  __llvm_get_inline_asm_needs_aligned_stack(inline_asm_val).to_moonbit_bool()
}
pub fn LLVMValueRef::get_inline_asm_needs_aligned_stack(self: LLVMValueRef) -> Bool {
  __llvm_get_inline_asm_needs_aligned_stack(self).to_moonbit_bool()
}

// /**
//  * Get if the inline asm snippet may unwind the stack
//  *
//  */
extern "C" fn __llvm_get_inline_asm_can_unwind(inline_asm_val: LLVMValueRef) -> LLVMBool = "__llvm_get_inline_asm_can_unwind"
pub fn llvm_get_inline_asm_can_unwind(inline_asm_val: LLVMValueRef) -> Bool {
  __llvm_get_inline_asm_can_unwind(inline_asm_val).to_moonbit_bool()
}
pub fn LLVMValueRef::get_inline_asm_can_unwind(self: LLVMValueRef) -> Bool {
  __llvm_get_inline_asm_can_unwind(self).to_moonbit_bool()
}
// /**
//  * Obtain the context to which this module is associated.
//  *
//  * @see Module::getContext()
pub extern "C" fn llvm_get_module_context(m: LLVMModuleRef) -> LLVMContextRef = "__llvm_get_module_context"

extern "C" fn __llvm_get_type_by_name_in_module(m: LLVMModuleRef, name: CStr) -> LLVMTypeRef = "__llvm_get_type_by_name_in_module"
pub fn llvm_get_type_by_name_in_module(m: LLVMModuleRef, name: String) -> LLVMTypeRef {
  let cstr = moonbit_str_to_c_str(name)
  __llvm_get_type_by_name_in_module(m, cstr)
}
pub fn LLVMModuleRef::get_type_by_name(self: LLVMModuleRef, name: String) -> LLVMTypeRef {
  llvm_get_type_by_name_in_module(self, name)
}

// /**
//  * Obtain an iterator to the first NamedMDNode in a Module.
//  *
//  * @see llvm::Module::named_metadata_begin()
//  */
pub extern "C" fn llvm_get_first_named_metadata(m: LLVMModuleRef) -> LLVMNamedMDNodeRef = "__llvm_get_first_named_metadata"

// /**
//  * Obtain an iterator to the last NamedMDNode in a Module.
//  *
//  * @see llvm::Module::named_metadata_end()
//  */
pub extern "C" fn llvm_get_last_named_metadata(m: LLVMModuleRef) -> LLVMNamedMDNodeRef = "__llvm_get_last_named_metadata"

// /**
//  * Advance a NamedMDNode iterator to the next NamedMDNode.
//  *
//  * Returns NULL if the iterator was already at the end and there are no more
//  * named metadata nodes.
//  */
pub extern "C" fn llvm_get_next_named_metadata(named_md_node: LLVMNamedMDNodeRef) -> LLVMNamedMDNodeRef = "__llvm_get_next_named_metadata"


// /**
//  * Decrement a NamedMDNode iterator to the previous NamedMDNode.
//  *
//  * Returns NULL if the iterator was already at the beginning and there are
//  * no previous named metadata nodes.
//  */
pub extern "C" fn llvm_get_previous_named_metadata(named_md_node: LLVMNamedMDNodeRef) -> LLVMNamedMDNodeRef = "__llvm_get_previous_named_metadata"


// 
// Retrieve a NamedMDNode with the given name, returning NULL if no such
// node exists.
// 
// @see llvm::Module::getNamedMetadata()
// 
pub extern "C" fn llvm_get_named_metadata(m: LLVMModuleRef, name: CStr, name_len: UInt64) -> LLVMNamedMDNodeRef = "__llvm_get_named_metadata"

// /**
//  * Retrieve a NamedMDNode with the given name, creating a new node if no such
//  * node exists.
//  *
//  * @see llvm::Module::getOrInsertNamedMetadata()
//  */
pub extern "C" fn llvm_get_or_insert_named_metadata(m: LLVMModuleRef, name: CStr, name_len: UInt64) -> LLVMNamedMDNodeRef = "__llvm_get_or_insert_named_metadata"

// pub extern "C" fn llvm_get_named_metadata_name(named_md: LLVMNamedMDNodeRef, name_len: Ptr[UInt64]) -> CStr = "__llvm_get_named_metadata_name"

extern "C" fn __llvm_get_named_metadata_num_operands(m: LLVMModuleRef, name: CStr) -> UInt = "__llvm_get_named_metadata_num_operands"
pub fn llvm_get_named_metadata_num_operands(m: LLVMModuleRef, name: String) -> UInt {
  let cstr = moonbit_str_to_c_str(name)
  __llvm_get_named_metadata_num_operands(m, cstr)
}
pub fn LLVMModuleRef::get_named_metadata_num_operands(self: LLVMModuleRef, name: String) -> UInt {
  llvm_get_named_metadata_num_operands(self, name)
}

// pub extern "C" fn llvm_get_named_metadata_operands(m: LLVMModuleRef, name: CStr, dest: Ptr[LLVMValueRef]) = "__llvm_get_named_metadata_operands"

extern "C" fn __llvm_add_named_metadata_operand(m: LLVMModuleRef, name: CStr, val: LLVMValueRef) = "__llvm_add_named_metadata_operand"
pub fn llvm_add_named_metadata_operand(m: LLVMModuleRef, name: String, val: LLVMValueRef) -> Unit {
  let cstr = moonbit_str_to_c_str(name)
  __llvm_add_named_metadata_operand(m, cstr, val)
}
pub fn LLVMModuleRef::add_named_metadata_operand(self: LLVMModuleRef, name: String, val: LLVMValueRef) -> Unit {
  llvm_add_named_metadata_operand(self, name, val)
}

// pub extern "C" fn llvm_get_debug_loc_directory(val: LLVMValueRef, length: Ptr[UInt]) -> CStr = "__llvm_get_debug_loc_directory"

// pub extern "C" fn llvm_get_debug_loc_filename(val: LLVMValueRef, length: Ptr[UInt]) -> CStr = "__llvm_get_debug_loc_filename"

pub extern "C" fn llvm_get_debug_loc_line(val: LLVMValueRef) -> UInt = "__llvm_get_debug_loc_line"
pub fn LLVMValueRef::get_debug_loc_line(self: LLVMValueRef) -> UInt {
  llvm_get_debug_loc_line(self)
}

pub extern "C" fn llvm_get_debug_loc_column(val: LLVMValueRef) -> UInt = "__llvm_get_debug_loc_column"
pub fn LLVMValueRef::get_debug_loc_column(self: LLVMValueRef) -> UInt {
  llvm_get_debug_loc_column(self)
}

extern "C" fn __llvm_add_function(m: LLVMModuleRef, name: CStr, function_ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_add_function"
pub fn llvm_add_function(m: LLVMModuleRef, name: String, function_ty: LLVMTypeRef) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(name)
  __llvm_add_function(m, cstr, function_ty)
}
pub fn LLVMModuleRef::add_function(self: LLVMModuleRef, name: String, function_ty: LLVMTypeRef) -> LLVMValueRef {
  llvm_add_function(self, name, function_ty)
}

extern "C" fn __llvm_get_named_function(m: LLVMModuleRef, name: CStr) -> LLVMValueRef = "__llvm_get_named_function"
pub fn llvm_get_named_function(m: LLVMModuleRef, name: String) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(name)
  __llvm_get_named_function(m, cstr)
}
pub fn LLVMModuleRef::get_named_function(self: LLVMModuleRef, name: String) -> LLVMValueRef {
  llvm_get_named_function(self, name)
}

pub extern "C" fn llvm_get_first_function(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_first_function"
pub fn LLVMModuleRef::get_first_function(self: LLVMModuleRef) -> LLVMValueRef {
  llvm_get_first_function(self)
}

pub extern "C" fn llvm_get_last_function(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_last_function"
pub fn LLVMModuleRef::get_last_function(self: LLVMModuleRef) -> LLVMValueRef {
  llvm_get_last_function(self)
}

pub extern "C" fn llvm_get_next_function(func: LLVMValueRef) -> LLVMValueRef = "__llvm_get_next_function"
pub fn LLVMValueRef::get_next_function(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_next_function(self)
}

pub extern "C" fn llvm_get_previous_function(func: LLVMValueRef) -> LLVMValueRef = "__llvm_get_previous_function"
pub fn LLVMValueRef::get_previous_function(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_previous_function(self)
}

extern "C" fn __llvm_get_type_kind(ty: LLVMTypeRef) -> Int = "__llvm_get_type_kind"
pub fn llvm_get_type_kind(ty: LLVMTypeRef) -> LLVMTypeKind {
  let idx = __llvm_get_type_kind(ty);
  LLVMTypeKind::from_int(idx)
}

pub extern "C" fn llvm_type_is_sized(ty: LLVMTypeRef) -> LLVMBool = "__llvm_type_is_sized"
pub fn LLVMTypeRef::is_sized(self: LLVMTypeRef) -> LLVMBool {
  llvm_type_is_sized(self)
}

pub extern "C" fn llvm_get_type_context(ty: LLVMTypeRef) -> LLVMContextRef = "__llvm_get_type_context"
pub fn LLVMTypeRef::get_context(self: LLVMTypeRef) -> LLVMContextRef {
  llvm_get_type_context(self)
}

pub extern "C" fn llvm_dump_type(val: LLVMTypeRef) = "__llvm_dump_type"
pub fn LLVMTypeRef::dump(self: LLVMTypeRef) -> Unit {
  llvm_dump_type(self)
}

extern "C" fn __llvm_print_type_to_string(val: LLVMTypeRef) -> CStr = "__llvm_print_type_to_string"
pub fn llvm_print_type_to_string(val: LLVMTypeRef) -> String {
  let cstr = __llvm_print_type_to_string(val)
  c_str_to_moonbit_str(cstr)
}
pub fn LLVMTypeRef::print_to_string(self: LLVMTypeRef) -> String {
  llvm_print_type_to_string(self)
}
pub fn LLVMTypeRef::to_string(self: LLVMTypeRef) -> String {
  llvm_print_type_to_string(self)
}

pub extern "C" fn llvm_int1_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int1_type_in_context"
pub fn LLVMContextRef::int1_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_int1_type_in_context(self)
}

pub extern "C" fn llvm_int8_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int8_type_in_context"
pub fn LLVMContextRef::int8_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_int8_type_in_context(self)
}

pub extern "C" fn llvm_int16_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int16_type_in_context"
pub fn LLVMContextRef::int16_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_int16_type_in_context(self)
}

pub extern "C" fn llvm_int32_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int32_type_in_context"
pub fn LLVMContextRef::int32_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_int32_type_in_context(self)
}

pub extern "C" fn llvm_int64_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int64_type_in_context"
pub fn LLVMContextRef::int64_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_int64_type_in_context(self)
}

pub extern "C" fn llvm_int128_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int128_type_in_context"
pub fn LLVMContextRef::int128_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_int128_type_in_context(self)
}

pub extern "C" fn llvm_int_type_in_context(context: LLVMContextRef, num_bits: UInt) -> LLVMTypeRef = "__llvm_int_type_in_context"
pub fn LLVMContextRef::int_type(self: LLVMContextRef, num_bits: UInt) -> LLVMTypeRef {
  llvm_int_type_in_context(self, num_bits)
}

pub extern "C" fn llvm_int1_type() -> LLVMTypeRef = "__llvm_int1_type"
pub fn LLVMTypeRef::int1_type() -> LLVMTypeRef {
  llvm_int1_type()
}

pub extern "C" fn llvm_int8_type() -> LLVMTypeRef = "__llvm_int8_type"
pub fn LLVMTypeRef::int8_type() -> LLVMTypeRef {
  llvm_int8_type()
}

pub extern "C" fn llvm_int16_type() -> LLVMTypeRef = "__llvm_int16_type"
pub fn LLVMTypeRef::int16_type() -> LLVMTypeRef {
  llvm_int16_type()
}

pub extern "C" fn llvm_int32_type() -> LLVMTypeRef = "__llvm_int32_type"
pub fn LLVMTypeRef::int32_type() -> LLVMTypeRef {
  llvm_int32_type()
}

pub extern "C" fn llvm_int64_type() -> LLVMTypeRef = "__llvm_int64_type"
pub fn LLVMTypeRef::int64_type() -> LLVMTypeRef {
  llvm_int64_type()
}

pub extern "C" fn llvm_int128_type() -> LLVMTypeRef = "__llvm_int128_type"
pub fn LLVMTypeRef::int128_type() -> LLVMTypeRef {
  llvm_int128_type()
}

pub extern "C" fn llvm_int_type(num_bits: UInt) -> LLVMTypeRef = "__llvm_int_type"
pub fn LLVMTypeRef::int_type(num_bits: UInt) -> LLVMTypeRef {
  llvm_int_type(num_bits)
}

pub extern "C" fn llvm_get_int_type_width(integer_ty: LLVMTypeRef) -> UInt = "__llvm_get_int_type_width"
pub fn LLVMTypeRef::get_int_type_width(self: LLVMTypeRef) -> UInt {
  llvm_get_int_type_width(self)
}

pub extern "C" fn llvm_half_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_half_type_in_context"
pub fn LLVMContextRef::half_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_half_type_in_context(self)
}

pub extern "C" fn llvm_bfloat_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_bfloat_type_in_context"
pub fn LLVMContextRef::bfloat_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_bfloat_type_in_context(self)
}

pub extern "C" fn llvm_float_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_float_type_in_context"
pub fn LLVMContextRef::float_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_float_type_in_context(self)
}

pub extern "C" fn llvm_double_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_double_type_in_context"
pub fn LLVMContextRef::double_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_double_type_in_context(self)
}

pub extern "C" fn llvm_x86_fp80_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_x86_fp80_type_in_context"
pub fn LLVMContextRef::x86_fp80_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_x86_fp80_type_in_context(self)
}

pub extern "C" fn llvm_fp128_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_fp128_type_in_context"
pub fn LLVMContextRef::fp128_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_fp128_type_in_context(self)
}

pub extern "C" fn llvm_ppc_fp128_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_ppc_fp128_type_in_context"
pub fn LLVMContextRef::ppc_fp128_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_ppc_fp128_type_in_context(self)
}

pub extern "C" fn llvm_half_type() -> LLVMTypeRef = "__llvm_half_type"
pub fn LLVMTypeRef::half_type() -> LLVMTypeRef {
  llvm_half_type()
}

pub extern "C" fn llvm_bfloat_type() -> LLVMTypeRef = "__llvm_bfloat_type"
pub fn LLVMTypeRef::bfloat_type() -> LLVMTypeRef {
  llvm_bfloat_type()
}

pub extern "C" fn llvm_float_type() -> LLVMTypeRef = "__llvm_float_type"
pub fn LLVMTypeRef::float_type() -> LLVMTypeRef {
  llvm_float_type()
}

pub extern "C" fn llvm_double_type() -> LLVMTypeRef = "__llvm_double_type"
pub fn LLVMTypeRef::double_type() -> LLVMTypeRef {
  llvm_double_type()
}

pub extern "C" fn llvm_x86_fp80_type() -> LLVMTypeRef = "__llvm_x86_fp80_type"
pub fn LLVMTypeRef::x86_fp80_type() -> LLVMTypeRef {
  llvm_x86_fp80_type()
}

pub extern "C" fn llvm_fp128_type() -> LLVMTypeRef = "__llvm_fp128_type"
pub fn LLVMTypeRef::fp128_type() -> LLVMTypeRef {
  llvm_fp128_type()
}

pub extern "C" fn llvm_ppc_fp128_type() -> LLVMTypeRef = "__llvm_ppc_fp128_type"
pub fn LLVMTypeRef::ppc_fp128_type() -> LLVMTypeRef {
  llvm_ppc_fp128_type()
}

extern "C" fn __llvm_function_type(return_type: LLVMTypeRef, param_types: Array[LLVMTypeRef], is_var_arg: LLVMBool) -> LLVMTypeRef = "__llvm_function_type"
pub fn llvm_function_type(return_type: LLVMTypeRef, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> LLVMTypeRef {
  __llvm_function_type(return_type, param_types, to_llvm_bool(is_var_arg))
}
pub fn LLVMTypeRef::function_type(self: LLVMTypeRef, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> LLVMTypeRef {
  __llvm_function_type(self, param_types, to_llvm_bool(is_var_arg))
}

pub extern "C" fn llvm_is_function_var_arg(function_ty: LLVMTypeRef) -> LLVMBool = "__llvm_is_function_var_arg"
pub fn LLVMTypeRef::is_function_var_arg(self: LLVMTypeRef) -> LLVMBool {
  llvm_is_function_var_arg(self)
}

pub extern "C" fn llvm_get_return_type(function_ty: LLVMTypeRef) -> LLVMTypeRef = "__llvm_get_return_type"
pub fn LLVMTypeRef::get_return_type(self: LLVMTypeRef) -> LLVMTypeRef {
  llvm_get_return_type(self)
}

pub extern "C" fn llvm_count_param_types(function_ty: LLVMTypeRef) -> UInt = "__llvm_count_param_types"
pub fn LLVMTypeRef::count_param_types(self: LLVMTypeRef) -> UInt {
  llvm_count_param_types(self)
}

// pub extern "C" fn llvm_get_param_types(function_ty: LLVMTypeRef, dest: Ptr[LLVMTypeRef]) = "__llvm_get_param_types"

extern "C" fn __llvm_struct_type_in_context(context: LLVMContextRef, element_types: Array[LLVMTypeRef], packed: LLVMBool) -> LLVMTypeRef = "__llvm_struct_type_in_context"
pub fn llvm_struct_type_in_context(context: LLVMContextRef, element_types: Array[LLVMTypeRef], packed: Bool) -> LLVMTypeRef {
  __llvm_struct_type_in_context(context, element_types, to_llvm_bool(packed))
}
pub fn LLVMContextRef::struct_type(self: LLVMContextRef, element_types: Array[LLVMTypeRef], packed: Bool) -> LLVMTypeRef {
  __llvm_struct_type_in_context(self, element_types, to_llvm_bool(packed))
}

extern "C" fn __llvm_struct_type(element_types: Array[LLVMTypeRef], packed: LLVMBool) -> LLVMTypeRef = "__llvm_struct_type"
pub fn llvm_struct_type(element_types: Array[LLVMTypeRef], packed: Bool) -> LLVMTypeRef {
  __llvm_struct_type(element_types, to_llvm_bool(packed))
}
pub fn LLVMTypeRef::struct_type(element_types: Array[LLVMTypeRef], packed: Bool) -> LLVMTypeRef {
  __llvm_struct_type(element_types, to_llvm_bool(packed))
}

extern "C" fn __llvm_struct_create_named(context: LLVMContextRef, name: CStr) -> LLVMTypeRef = "__llvm_struct_create_named"
pub fn llvm_struct_create_named(context: LLVMContextRef, name: String) -> LLVMTypeRef {
  let cstr = moonbit_str_to_c_str(name)
  __llvm_struct_create_named(context, cstr)
}
pub fn LLVMContextRef::struct_create_named(self: LLVMContextRef, name: String) -> LLVMTypeRef {
  llvm_struct_create_named(self, name)
}

extern "C" fn __llvm_get_struct_name(ty: LLVMTypeRef) -> CStr = "__llvm_get_struct_name"
pub fn llvm_get_struct_name(ty: LLVMTypeRef) -> String {
  let cstr = __llvm_get_struct_name(ty)
  c_str_to_moonbit_str(cstr)
}
pub fn LLVMTypeRef::get_struct_name(self: LLVMTypeRef) -> String {
  llvm_get_struct_name(self)
}

extern "C" fn __llvm_struct_set_body(struct_ty: LLVMTypeRef, element_types: Array[LLVMTypeRef], packed: LLVMBool) = "__llvm_struct_set_body"
pub fn llvm_struct_set_body(struct_ty: LLVMTypeRef, element_types: Array[LLVMTypeRef], packed: Bool) -> Unit {
  __llvm_struct_set_body(struct_ty, element_types, to_llvm_bool(packed))
}
pub fn LLVMTypeRef::set_body(self: LLVMTypeRef, element_types: Array[LLVMTypeRef], packed: Bool) -> Unit {
  llvm_struct_set_body(self, element_types, packed)
}

pub extern "C" fn llvm_count_struct_element_types(struct_ty: LLVMTypeRef) -> UInt = "__llvm_count_struct_element_types"
pub fn LLVMTypeRef::count_struct_element_types(self: LLVMTypeRef) -> UInt {
  llvm_count_struct_element_types(self)
}

// pub extern "C" fn llvm_get_struct_element_types(struct_ty: LLVMTypeRef, dest: Ptr[LLVMTypeRef]) = "__llvm_get_struct_element_types"

pub extern "C" fn llvm_struct_get_type_at_index(struct_ty: LLVMTypeRef, i: UInt) -> LLVMTypeRef = "__llvm_struct_get_type_at_index"
pub fn LLVMTypeRef::get_type_at_index(self: LLVMTypeRef, i: UInt) -> LLVMTypeRef {
  llvm_struct_get_type_at_index(self, i)
}

pub extern "C" fn __llvm_is_packed_struct(struct_ty: LLVMTypeRef) -> LLVMBool = "__llvm_is_packed_struct"
pub fn LLVMTypeRef::is_packed(self: LLVMTypeRef) -> LLVMBool {
  __llvm_is_packed_struct(self)
}

extern "C" fn __llvm_is_opaque_struct(struct_ty: LLVMTypeRef) -> LLVMBool = "__llvm_is_opaque_struct"
pub fn llvm_is_opaque_struct(struct_ty: LLVMTypeRef) -> Bool {
  __llvm_is_opaque_struct(struct_ty).to_moonbit_bool()
}
pub fn LLVMTypeRef::is_opaque_struct(self: LLVMTypeRef) -> Bool {
  __llvm_is_opaque_struct(self).to_moonbit_bool()
}

extern "C" fn __llvm_is_literal_struct(struct_ty: LLVMTypeRef) -> LLVMBool = "__llvm_is_literal_struct"
pub fn llvm_is_literal_struct(struct_ty: LLVMTypeRef) -> Bool {
  __llvm_is_literal_struct(struct_ty).to_moonbit_bool()
}
pub fn LLVMTypeRef::is_literal_struct(self: LLVMTypeRef) -> Bool {
  __llvm_is_literal_struct(self).to_moonbit_bool()
}

pub extern "C" fn llvm_get_element_type(ty: LLVMTypeRef) -> LLVMTypeRef = "__llvm_get_element_type"
pub fn LLVMTypeRef::get_element_type(self: LLVMTypeRef) -> LLVMTypeRef {
  llvm_get_element_type(self)
}

// FIXME: Not implemented
pub extern "C" fn llvm_get_subtypes(tp: LLVMTypeRef) -> Array[LLVMTypeRef] = "__llvm_get_subtypes"
pub fn LLVMTypeRef::get_subtypes(self: LLVMTypeRef) -> Array[LLVMTypeRef] {
  llvm_get_subtypes(self)
}

pub extern "C" fn llvm_get_num_contained_types(tp: LLVMTypeRef) -> UInt = "__llvm_get_num_contained_types"
pub fn LLVMTypeRef::get_num_contained_types(self: LLVMTypeRef) -> UInt {
  llvm_get_num_contained_types(self)
}

pub extern "C" fn llvm_array_type(element_type: LLVMTypeRef, element_count: UInt) -> LLVMTypeRef = "__llvm_array_type"
pub fn LLVMTypeRef::array_type(self: LLVMTypeRef, element_count: UInt) -> LLVMTypeRef {
  llvm_array_type(self, element_count)
}

pub extern "C" fn llvm_array_type2(element_type: LLVMTypeRef, element_count: UInt64) -> LLVMTypeRef = "__llvm_array_type2"

pub extern "C" fn llvm_get_array_length(array_ty: LLVMTypeRef) -> UInt = "__llvm_get_array_length"
pub fn LLVMTypeRef::get_array_length(self: LLVMTypeRef) -> UInt {
  llvm_get_array_length(self)
}

pub extern "C" fn llvm_get_array_length2(array_ty: LLVMTypeRef) -> UInt64 = "__llvm_get_array_length2"
pub fn LLVMTypeRef::get_array_length2(self: LLVMTypeRef) -> UInt64 {
  llvm_get_array_length2(self)
}

pub extern "C" fn llvm_pointer_type(element_type: LLVMTypeRef, address_space: AddressSpace) -> LLVMTypeRef = "__llvm_pointer_type"
pub fn LLVMTypeRef::pointer_type(self: LLVMTypeRef, address_space: AddressSpace) -> LLVMTypeRef {
  llvm_pointer_type(self, address_space)
}

extern "C" fn __llvm_pointer_type_is_opaque(ty: LLVMTypeRef) -> LLVMBool = "__llvm_pointer_type_is_opaque"
pub fn llvm_pointer_type_is_opaque(ty: LLVMTypeRef) -> Bool {
  __llvm_pointer_type_is_opaque(ty).to_moonbit_bool()
}
pub fn LLVMTypeRef::pointer_type_is_opaque(self: LLVMTypeRef) -> Bool {
  __llvm_pointer_type_is_opaque(self).to_moonbit_bool()
}

pub extern "C" fn llvm_pointer_type_in_context(context: LLVMContextRef, address_space: AddressSpace) -> LLVMTypeRef = "__llvm_pointer_type_in_context"
pub fn LLVMContextRef::pointer_type(self: LLVMContextRef, address_space: AddressSpace) -> LLVMTypeRef {
  llvm_pointer_type_in_context(self, address_space)
}

pub extern "C" fn llvm_get_pointer_address_space(pointer_ty: LLVMTypeRef) -> UInt = "__llvm_get_pointer_address_space"
pub fn LLVMTypeRef::get_pointer_address_space(self: LLVMTypeRef) -> UInt {
  llvm_get_pointer_address_space(self)
}

pub extern "C" fn llvm_vector_type(element_type: LLVMTypeRef, element_count: UInt) -> LLVMTypeRef = "__llvm_vector_type"
pub fn LLVMTypeRef::vector_type(self: LLVMTypeRef, element_count: UInt) -> LLVMTypeRef {
  llvm_vector_type(self, element_count)
}

pub extern "C" fn llvm_scalable_vector_type(element_type: LLVMTypeRef, element_count: UInt) -> LLVMTypeRef = "__llvm_scalable_vector_type"
pub fn LLVMTypeRef::scalable_vector_type(self: LLVMTypeRef, element_count: UInt) -> LLVMTypeRef {
  llvm_scalable_vector_type(self, element_count)
}

pub extern "C" fn llvm_get_vector_size(vector_ty: LLVMTypeRef) -> UInt = "__llvm_get_vector_size"
pub fn LLVMTypeRef::get_vector_size(self: LLVMTypeRef) -> UInt {
  llvm_get_vector_size(self)
}

pub extern "C" fn llvm_void_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_void_type_in_context"
pub fn LLVMContextRef::void_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_void_type_in_context(self)
}

pub extern "C" fn llvm_label_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_label_type_in_context"
pub fn LLVMContextRef::label_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_label_type_in_context(self)
}

pub extern "C" fn llvm_x86_mmx_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_x86_mmx_type_in_context"
pub fn LLVMContextRef::x86_mmx_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_x86_mmx_type_in_context(self)
}

pub extern "C" fn llvm_x86_amx_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_x86_amx_type_in_context"
pub fn LLVMContextRef::x86_amx_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_x86_amx_type_in_context(self)
}

pub extern "C" fn llvm_token_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_token_type_in_context"
pub fn LLVMContextRef::token_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_token_type_in_context(self)
}

pub extern "C" fn llvm_metadata_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_metadata_type_in_context"
pub fn LLVMContextRef::metadata_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_metadata_type_in_context(self)
}

pub extern "C" fn llvm_void_type() -> LLVMTypeRef = "__llvm_void_type"
pub fn LLVMTypeRef::void_type() -> LLVMTypeRef {
  llvm_void_type()
}

pub extern "C" fn llvm_label_type() -> LLVMTypeRef = "__llvm_label_type"
pub fn LLVMTypeRef::label_type() -> LLVMTypeRef {
  llvm_label_type()
}

pub extern "C" fn llvm_x86_mmx_type() -> LLVMTypeRef = "__llvm_x86_mmx_type"
pub fn LLVMTypeRef::x86_mmx_type() -> LLVMTypeRef {
  llvm_x86_mmx_type()
}

pub extern "C" fn llvm_x86_amx_type() -> LLVMTypeRef = "__llvm_x86_amx_type"
pub fn LLVMTypeRef::x86_amx_type() -> LLVMTypeRef {
  llvm_x86_amx_type()
}

extern "C" fn __llvm_get_target_ext_type_name(target_ext_ty: LLVMTypeRef) -> CStr = "__llvm_get_target_ext_type_name"
pub fn llvm_get_target_ext_type_name(target_ext_ty: LLVMTypeRef) -> String {
  let cstr = __llvm_get_target_ext_type_name(target_ext_ty)
  c_str_to_moonbit_str(cstr)
}
pub fn LLVMTypeRef::get_target_ext_type_name(self: LLVMTypeRef) -> String {
  llvm_get_target_ext_type_name(self)
}

pub extern "C" fn llvm_get_target_ext_type_num_type_params(target_ext_ty: LLVMTypeRef) -> UInt = "__llvm_get_target_ext_type_num_type_params"
pub fn LLVMTypeRef::get_target_ext_type_num_type_params(self: LLVMTypeRef) -> UInt {
  llvm_get_target_ext_type_num_type_params(self)
}

pub extern "C" fn llvm_get_target_ext_type_type_param(target_ext_ty: LLVMTypeRef, idx: UInt) -> LLVMTypeRef = "__llvm_get_target_ext_type_type_param"
pub fn LLVMTypeRef::get_target_ext_type_type_param(self: LLVMTypeRef, idx: UInt) -> LLVMTypeRef {
  llvm_get_target_ext_type_type_param(self, idx)
}

pub extern "C" fn llvm_get_target_ext_type_num_int_params(target_ext_ty: LLVMTypeRef) -> UInt = "__llvm_get_target_ext_type_num_int_params"
pub fn LLVMTypeRef::get_target_ext_type_num_int_params(self: LLVMTypeRef) -> UInt {
  llvm_get_target_ext_type_num_int_params(self)
}

pub extern "C" fn llvm_get_target_ext_type_int_param(target_ext_ty: LLVMTypeRef, idx: UInt) -> UInt = "__llvm_get_target_ext_type_int_param"
pub fn LLVMTypeRef::get_target_ext_type_int_param(self: LLVMTypeRef, idx: UInt) -> UInt {
  llvm_get_target_ext_type_int_param(self, idx)
}

pub extern "C" fn llvm_type_of(val: LLVMValueRef) -> LLVMTypeRef = "__llvm_type_of"
pub fn LLVMValueRef::type_of(self: LLVMValueRef) -> LLVMTypeRef {
  llvm_type_of(self)
}

pub extern "C" fn llvm_get_value_kind(val: LLVMValueRef) -> LLVMValueKind = "__llvm_get_value_kind"
pub fn LLVMValueRef::get_value_kind(self: LLVMValueRef) -> LLVMValueKind {
  llvm_get_value_kind(self)
}

// pub extern "C" fn llvm_get_value_name2(val: LLVMValueRef, length: Ptr[UInt64]) -> CStr = "__llvm_get_value_name2"

extern "C" fn __llvm_set_value_name(val: LLVMValueRef, name: CStr, name_len: Int) = "__llvm_set_value_name2"
pub fn llvm_set_value_name(val: LLVMValueRef, name: String) -> Unit {
  let cstr = moonbit_str_to_c_str(name)
  let len = name.length()
  __llvm_set_value_name(val, cstr, len)
}
pub fn LLVMValueRef::set_name(self: LLVMValueRef, name: String) -> Unit {
  llvm_set_value_name(self, name)
}

pub extern "C" fn llvm_dump_value(val: LLVMValueRef) = "__llvm_dump_value"

extern "C" fn __llvm_print_value_to_string(val: LLVMValueRef) -> CStr = "__llvm_print_value_to_string"
pub fn llvm_print_value_to_string(val: LLVMValueRef) -> String {
  let cstr = __llvm_print_value_to_string(val)
  c_str_to_moonbit_str(cstr)
}

extern "C" fn __llvm_print_dbg_record_to_string(record: LLVMDbgRecordRef) -> CStr = "__llvm_print_dbg_record_to_string"
pub fn llvm_print_dbg_record_to_string(record: LLVMDbgRecordRef) -> String {
  let cstr = __llvm_print_dbg_record_to_string(record)
  c_str_to_moonbit_str(cstr)
}

pub extern "C" fn llvm_replace_all_uses_with(old_val: LLVMValueRef, new_val: LLVMValueRef) = "__llvm_replace_all_uses_with"
pub fn LLVMValueRef::replace_all_uses_with(self: LLVMValueRef, new_val: LLVMValueRef) -> Unit {
  llvm_replace_all_uses_with(self, new_val)
}

pub extern "C" fn llvm_is_constant(val: LLVMValueRef) -> LLVMBool = "__llvm_is_constant"
pub fn LLVMValueRef::is_constant(self: LLVMValueRef) -> LLVMBool {
  llvm_is_constant(self)
}

extern "C" fn __llvm_is_undef(val: LLVMValueRef) -> LLVMBool = "__llvm_is_undef"
pub fn llvm_is_undef(val: LLVMValueRef) -> Bool {
  __llvm_is_undef(val).to_moonbit_bool()
}
pub fn LLVMValueRef::is_undef(self: LLVMValueRef) -> Bool {
  __llvm_is_undef(self).to_moonbit_bool()
}

pub extern "C" fn llvm_is_poison(val: LLVMValueRef) -> LLVMBool = "__llvm_is_poison"
pub fn LLVMValueRef::is_poison(self: LLVMValueRef) -> LLVMBool {
  llvm_is_poison(self)
}

pub extern "C" fn llvm_isa_argument(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_argument"
pub fn LLVMValueRef::isa_argument(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_argument(self)
}

pub extern "C" fn llvm_isa_basic_block(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_basic_block"
pub fn LLVMValueRef::isa_basic_block(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_basic_block(self)
}

pub extern "C" fn llvm_isa_inline_asm(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_inline_asm"
pub fn LLVMValueRef::isa_inline_asm(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_inline_asm(self)
}

pub extern "C" fn llvm_isa_user(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_user"
pub fn LLVMValueRef::isa_user(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_user(self)
}

pub extern "C" fn llvm_isa_constant(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant"
pub fn LLVMValueRef::isa_constant(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant(self)
}

pub extern "C" fn llvm_isa_block_address(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_block_address"
pub fn LLVMValueRef::isa_block_address(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_block_address(self)
}

pub extern "C" fn llvm_isa_constant_aggregate_zero(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_aggregate_zero"
pub fn LLVMValueRef::isa_constant_aggregate_zero(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_aggregate_zero(self)
}

pub extern "C" fn llvm_isa_constant_array(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_array"
pub fn LLVMValueRef::isa_constant_array(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_array(self)
}

pub extern "C" fn llvm_isa_constant_data_sequential(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_data_sequential"
pub fn LLVMValueRef::isa_constant_data_sequential(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_data_sequential(self)
}

pub extern "C" fn llvm_isa_constant_data_array(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_data_array"
pub fn LLVMValueRef::isa_constant_data_array(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_data_array(self)
}

pub extern "C" fn llvm_isa_constant_data_vector(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_data_vector"
pub fn LLVMValueRef::isa_constant_data_vector(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_data_vector(self)
}

pub extern "C" fn llvm_isa_constant_expr(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_expr"
pub fn LLVMValueRef::isa_constant_expr(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_expr(self)
}

pub extern "C" fn llvm_isa_constant_fp(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_fp"
pub fn LLVMValueRef::isa_constant_fp(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_fp(self)
}

pub extern "C" fn llvm_isa_constant_int(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_int"
pub fn LLVMValueRef::isa_constant_int(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_int(self)
}

pub extern "C" fn llvm_isa_constant_pointer_null(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_pointer_null"
pub fn LLVMValueRef::isa_constant_pointer_null(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_pointer_null(self)
}


pub extern "C" fn llvm_isa_constant_struct(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_struct"
pub fn LLVMValueRef::isa_constant_struct(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_struct(self)
}

pub extern "C" fn llvm_isa_constant_token_none(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_token_none"
pub fn LLVMValueRef::isa_constant_token_none(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_token_none(self)
}


pub extern "C" fn llvm_isa_constant_vector(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_vector"
pub fn LLVMValueRef::isa_constant_vector(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_vector(self)
}

pub extern "C" fn llvm_isa_global_value(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_value"
pub fn LLVMValueRef::isa_global_value(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_global_value(self)
}


pub extern "C" fn llvm_isa_global_alias(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_alias"
pub fn LLVMValueRef::isa_global_alias(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_global_alias(self)
}

pub extern "C" fn llvm_isa_global_object(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_object"
pub fn LLVMValueRef::isa_global_object(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_global_object(self)
}

pub extern "C" fn llvm_isa_function(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_function"
pub fn LLVMValueRef::isa_function(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_function(self)
}

pub extern "C" fn llvm_isa_global_variable(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_variable"
pub fn LLVMValueRef::isa_global_variable(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_global_variable(self)
}

pub extern "C" fn llvm_isa_global_ifunc(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_ifunc"
pub fn LLVMValueRef::isa_global_ifunc(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_global_ifunc(self)
}

pub extern "C" fn llvm_isa_undef_value(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_undef_value"
pub fn LLVMValueRef::isa_undef_value(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_undef_value(self)
}

pub extern "C" fn llvm_isa_poison_value(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_poison_value"
pub fn LLVMValueRef::isa_poison_value(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_poison_value(self)
}

pub extern "C" fn llvm_isa_instruction(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_instruction"
pub fn LLVMValueRef::isa_instruction(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_instruction(self)
}

pub extern "C" fn llvm_isa_unary_operator(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_unary_operator"
pub fn LLVMValueRef::isa_unary_operator(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_unary_operator(self)
}

pub extern "C" fn llvm_isa_binary_operator(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_binary_operator"
pub fn LLVMValueRef::isa_binary_operator(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_binary_operator(self)
}

pub extern "C" fn llvm_isa_call_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_call_inst"
pub fn LLVMValueRef::isa_call_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_call_inst(self)
}

pub extern "C" fn llvm_isa_intrinsic_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_intrinsic_inst"
pub fn LLVMValueRef::isa_intrinsic_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_intrinsic_inst(self)
}

pub extern "C" fn llvm_isa_dbg_info_intrinsic(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_dbg_info_intrinsic"
pub fn LLVMValueRef::isa_dbg_info_intrinsic(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_dbg_info_intrinsic(self)
}

pub extern "C" fn llvm_isa_dbg_variable_intrinsic(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_dbg_variable_intrinsic"
pub fn LLVMValueRef::isa_dbg_variable_intrinsic(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_dbg_variable_intrinsic(self)
}

pub extern "C" fn llvm_isa_dbg_declare_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_dbg_declare_inst"
pub fn LLVMValueRef::isa_dbg_declare_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_dbg_declare_inst(self)
}

pub extern "C" fn llvm_isa_dbg_label_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_dbg_label_inst"
pub fn LLVMValueRef::isa_dbg_label_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_dbg_label_inst(self)
}

pub extern "C" fn llvm_isa_mem_intrinsic(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_mem_intrinsic"
pub fn LLVMValueRef::isa_mem_intrinsic(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_mem_intrinsic(self)
}

pub extern "C" fn llvm_isa_mem_cpy_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_mem_cpy_inst"
pub fn LLVMValueRef::isa_mem_cpy_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_mem_cpy_inst(self)
}

pub extern "C" fn llvm_isa_mem_move_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_mem_move_inst"
pub fn LLVMValueRef::isa_mem_move_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_mem_move_inst(self)
}

pub extern "C" fn llvm_isa_mem_set_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_mem_set_inst"
pub fn LLVMValueRef::isa_mem_set_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_mem_set_inst(self)
}

pub extern "C" fn llvm_isa_cmp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_cmp_inst"
pub fn LLVMValueRef::isa_cmp_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_cmp_inst(self)
}

pub extern "C" fn llvm_isa_f_cmp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_f_cmp_inst"
pub fn LLVMValueRef::isa_f_cmp_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_f_cmp_inst(self)
}

pub extern "C" fn llvm_isa_i_cmp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_i_cmp_inst"
pub fn LLVMValueRef::isa_i_cmp_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_i_cmp_inst(self)
}

pub extern "C" fn llvm_isa_extract_element_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_extract_element_inst"
pub fn LLVMValueRef::isa_extract_element_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_extract_element_inst(self)
}

pub extern "C" fn llvm_isa_get_element_ptr_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_get_element_ptr_inst"
pub fn LLVMValueRef::isa_get_element_ptr_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_get_element_ptr_inst(self)
}

pub extern "C" fn llvm_isa_insert_element_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_insert_element_inst"
pub fn LLVMValueRef::isa_insert_element_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_insert_element_inst(self)
}

pub extern "C" fn llvm_isa_insert_value_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_insert_value_inst"
pub fn LLVMValueRef::isa_insert_value_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_insert_value_inst(self)
}

pub extern "C" fn llvm_isa_landing_pad_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_landing_pad_inst"
pub fn LLVMValueRef::isa_landing_pad_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_landing_pad_inst(self)
}

pub extern "C" fn llvm_isa_phi_node(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_phi_node"
pub fn LLVMValueRef::isa_phi_node(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_phi_node(self)
}

pub extern "C" fn llvm_isa_select_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_select_inst"
pub fn LLVMValueRef::isa_select_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_select_inst(self)
}

pub extern "C" fn llvm_isa_shuffle_vector_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_shuffle_vector_inst"
pub fn LLVMValueRef::isa_shuffle_vector_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_shuffle_vector_inst(self)
}

pub extern "C" fn llvm_isa_store_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_store_inst"
pub fn LLVMValueRef::isa_store_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_store_inst(self)
}

pub extern "C" fn llvm_isa_branch_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_branch_inst"
pub fn LLVMValueRef::isa_branch_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_branch_inst(self)
}

pub extern "C" fn llvm_isa_indirect_br_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_indirect_br_inst"
pub fn LLVMValueRef::isa_indirect_br_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_indirect_br_inst(self)
}

pub extern "C" fn llvm_isa_invoke_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_invoke_inst"
pub fn LLVMValueRef::isa_invoke_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_invoke_inst(self)
}

pub extern "C" fn llvm_isa_return_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_return_inst"
pub fn LLVMValueRef::isa_return_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_return_inst(self)
}

pub extern "C" fn llvm_isa_switch_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_switch_inst"
pub fn LLVMValueRef::isa_switch_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_switch_inst(self)
}

pub extern "C" fn llvm_isa_unreachable_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_unreachable_inst"
pub fn LLVMValueRef::isa_unreachable_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_unreachable_inst(self)
}

pub extern "C" fn llvm_isa_resume_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_resume_inst"
pub fn LLVMValueRef::isa_resume_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_resume_inst(self)
}

pub extern "C" fn llvm_isa_cleanup_return_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_cleanup_return_inst"
pub fn LLVMValueRef::isa_cleanup_return_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_cleanup_return_inst(self)
}

pub extern "C" fn llvm_isa_catch_return_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_catch_return_inst"
pub fn LLVMValueRef::isa_catch_return_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_catch_return_inst(self)
}

pub extern "C" fn llvm_isa_catch_switch_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_catch_switch_inst"
pub fn LLVMValueRef::isa_catch_switch_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_catch_switch_inst(self)
}

pub extern "C" fn llvm_isa_call_br_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_call_br_inst"
pub fn LLVMValueRef::isa_call_br_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_call_br_inst(self)
}

pub extern "C" fn llvm_isa_funclet_pad_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_funclet_pad_inst"
pub fn LLVMValueRef::isa_funclet_pad_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_funclet_pad_inst(self)
}

pub extern "C" fn llvm_isa_catch_pad_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_catch_pad_inst"
pub fn LLVMValueRef::isa_catch_pad_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_catch_pad_inst(self)
}

pub extern "C" fn llvm_isa_cleanup_pad_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_cleanup_pad_inst"
pub fn LLVMValueRef::isa_cleanup_pad_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_cleanup_pad_inst(self)
}

pub extern "C" fn llvm_isa_unary_instruction(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_unary_instruction"
pub fn LLVMValueRef::isa_unary_instruction(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_unary_instruction(self)
}

pub extern "C" fn llvm_isa_alloca_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_alloca_inst"
pub fn LLVMValueRef::isa_alloca_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_alloca_inst(self)
}

pub extern "C" fn llvm_isa_cast_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_cast_inst"
pub fn LLVMValueRef::isa_cast_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_cast_inst(self)
}

pub extern "C" fn llvm_isa_addr_space_cast_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_addr_space_cast_inst"
pub fn LLVMValueRef::isa_addr_space_cast_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_addr_space_cast_inst(self)
}

pub extern "C" fn llvm_isa_bit_cast_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_bit_cast_inst"
pub fn LLVMValueRef::isa_bit_cast_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_bit_cast_inst(self)
}

pub extern "C" fn llvm_isa_fp_ext_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fp_ext_inst"
pub fn LLVMValueRef::isa_fp_ext_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_fp_ext_inst(self)
}

pub extern "C" fn llvm_isa_fp_to_si_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fp_to_si_inst"
pub fn LLVMValueRef::isa_fp_to_si_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_fp_to_si_inst(self)
}

pub extern "C" fn llvm_isa_fp_to_ui_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fp_to_ui_inst"
pub fn LLVMValueRef::isa_fp_to_ui_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_fp_to_ui_inst(self)
}

pub extern "C" fn llvm_isa_fp_trunc_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fp_trunc_inst"
pub fn LLVMValueRef::isa_fp_trunc_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_fp_trunc_inst(self)
}

pub extern "C" fn llvm_isa_int_to_ptr_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_int_to_ptr_inst"
pub fn LLVMValueRef::isa_int_to_ptr_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_int_to_ptr_inst(self)
}

pub extern "C" fn llvm_isa_ptr_to_int_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_ptr_to_int_inst"
pub fn LLVMValueRef::isa_ptr_to_int_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_ptr_to_int_inst(self)
}

pub extern "C" fn llvm_isa_sext_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_sext_inst"
pub fn LLVMValueRef::isa_sext_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_sext_inst(self)
}

pub extern "C" fn llvm_isa_si_to_fp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_si_to_fp_inst"
pub fn LLVMValueRef::isa_si_to_fp_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_si_to_fp_inst(self)
}

pub extern "C" fn llvm_isa_trunc_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_trunc_inst"
pub fn LLVMValueRef::isa_trunc_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_trunc_inst(self)
}

pub extern "C" fn llvm_isa_ui_to_fp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_ui_to_fp_inst"
pub fn LLVMValueRef::isa_ui_to_fp_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_ui_to_fp_inst(self)
}

pub extern "C" fn llvm_isa_z_ext_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_z_ext_inst"
pub fn LLVMValueRef::isa_z_ext_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_z_ext_inst(self)
}

pub extern "C" fn llvm_isa_extract_value_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_extract_value_inst"
pub fn LLVMValueRef::isa_extract_value_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_extract_value_inst(self)
}

pub extern "C" fn llvm_isa_load_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_load_inst"
pub fn LLVMValueRef::isa_load_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_load_inst(self)
}

pub extern "C" fn llvm_isa_va_arg_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_va_arg_inst"
pub fn LLVMValueRef::isa_va_arg_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_va_arg_inst(self)
}

pub extern "C" fn llvm_isa_freeze_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_freeze_inst"
pub fn LLVMValueRef::isa_freeze_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_freeze_inst(self)
}

pub extern "C" fn llvm_isa_atomic_cmp_xchg_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_atomic_cmp_xchg_inst"
pub fn LLVMValueRef::isa_atomic_cmp_xchg_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_atomic_cmp_xchg_inst(self)
}

pub extern "C" fn llvm_isa_atomic_rmw_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_atomic_rmw_inst"
pub fn LLVMValueRef::isa_atomic_rmw_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_atomic_rmw_inst(self)
}

pub extern "C" fn llvm_isa_fence_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fence_inst"
pub fn LLVMValueRef::isa_fence_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_fence_inst(self)
}

pub extern "C" fn llvm_isa_md_node(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_md_node"
pub fn LLVMValueRef::isa_md_node(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_md_node(self)
}

pub extern "C" fn llvm_isa_value_as_metadata(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_value_as_metadata"
pub fn LLVMValueRef::isa_value_as_metadata(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_value_as_metadata(self)
}

pub extern "C" fn llvm_isa_md_string(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_md_string"
pub fn LLVMValueRef::isa_md_string(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_md_string(self)
}

pub extern "C" fn llvm_get_value_name(val: LLVMValueRef) -> CStr = "__llvm_get_value_name"
pub fn LLVMValueRef::get_value_name(self: LLVMValueRef) -> String {
  let cstr = llvm_get_value_name(self)
  c_str_to_moonbit_str(cstr)
}

// deprecated
// pub extern "C" fn llvm_set_value_name(val: LLVMValueRef, name: CStr) = "__llvm_set_value_name"

pub extern "C" fn llvm_get_first_use(val: LLVMValueRef) -> LLVMUseRef = "__llvm_get_first_use"
pub fn LLVMValueRef::get_first_use(self: LLVMValueRef) -> LLVMUseRef {
  llvm_get_first_use(self)
}

pub extern "C" fn llvm_get_next_use(u: LLVMUseRef) -> LLVMUseRef = "__llvm_get_next_use"
pub fn LLVMUseRef::get_next_use(self: LLVMUseRef) -> LLVMUseRef {
  llvm_get_next_use(self)
}

pub extern "C" fn llvm_get_user(u: LLVMUseRef) -> LLVMValueRef = "__llvm_get_user"
pub fn LLVMUseRef::get_user(self: LLVMUseRef) -> LLVMValueRef {
  llvm_get_user(self)
}

pub extern "C" fn llvm_get_used_value(u: LLVMUseRef) -> LLVMValueRef = "__llvm_get_used_value"
pub fn LLVMUseRef::get_used_value(self: LLVMUseRef) -> LLVMValueRef {
  llvm_get_used_value(self)
}

pub extern "C" fn llvm_get_operand(val: LLVMValueRef, index: UInt) -> LLVMValueRef = "__llvm_get_operand"
pub fn LLVMValueRef::get_operand(self: LLVMValueRef, index: UInt) -> LLVMValueRef {
  llvm_get_operand(self, index)
}

pub extern "C" fn llvm_get_operand_use(val: LLVMValueRef, index: UInt) -> LLVMUseRef = "__llvm_get_operand_use"
pub fn LLVMValueRef::get_operand_use(self: LLVMValueRef, index: UInt) -> LLVMUseRef {
  llvm_get_operand_use(self, index)
}

pub extern "C" fn llvm_set_operand(user: LLVMValueRef, index: UInt, val: LLVMValueRef) = "__llvm_set_operand"
pub fn LLVMValueRef::set_operand(self: LLVMValueRef, index: UInt, val: LLVMValueRef) -> Unit {
  llvm_set_operand(self, index, val)
}

pub extern "C" fn llvm_get_num_operands(val: LLVMValueRef) -> Int = "__llvm_get_num_operands"
pub fn LLVMValueRef::get_num_operands(self: LLVMValueRef) -> Int {
  llvm_get_num_operands(self)
}

pub extern "C" fn llvm_const_null(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_null"
pub fn LLVMTypeRef::const_null(self: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_null(self)
}

pub extern "C" fn llvm_const_all_ones(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_all_ones"
pub fn LLVMTypeRef::const_all_ones(self: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_all_ones(self)
}

pub extern "C" fn llvm_get_undef(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_get_undef"
pub fn LLVMTypeRef::get_undef(self: LLVMTypeRef) -> LLVMValueRef {
  llvm_get_undef(self)
}

pub extern "C" fn llvm_get_poison(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_get_poison"
pub fn LLVMTypeRef::get_poison(self: LLVMTypeRef) -> LLVMValueRef {
  llvm_get_poison(self)
}

pub extern "C" fn llvm_is_null(val: LLVMValueRef) -> LLVMBool = "__llvm_is_null"

pub extern "C" fn llvm_const_pointer_null(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_pointer_null"
pub fn LLVMTypeRef::const_pointer_null(self: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_pointer_null(self)
}

extern "C" fn __llvm_const_int(int_ty: LLVMTypeRef, n: UInt64, sign_extend: LLVMBool) -> LLVMValueRef = "__llvm_const_int"
pub fn llvm_const_int(int_ty: LLVMTypeRef, n: UInt64, sign_extend: Bool) -> LLVMValueRef {
  __llvm_const_int(int_ty, n, to_llvm_bool(sign_extend))
}
pub fn LLVMTypeRef::const_int(self: LLVMTypeRef, n: UInt64, sign_extend: Bool) -> LLVMValueRef {
  __llvm_const_int(self, n, to_llvm_bool(sign_extend))
}

// pub extern "C" fn llvm_const_int_of_string(int_ty: LLVMTypeRef, text: CStr, radix: UInt8) -> LLVMValueRef = "__llvm_const_int_of_string"

// pub extern "C" fn llvm_const_int_of_string_and_size(int_ty: LLVMTypeRef, text: CStr, s_len: UInt, radix: UInt8) -> LLVMValueRef = "__llvm_const_int_of_string_and_size"

pub extern "C" fn llvm_const_real(real_ty: LLVMTypeRef, n: Double) -> LLVMValueRef = "__llvm_const_real"
pub fn LLVMTypeRef::const_real(self: LLVMTypeRef, n: Double) -> LLVMValueRef {
  llvm_const_real(self, n)
}

extern "C" fn __llvm_const_real_of_string(real_ty: LLVMTypeRef, text: CStr) -> LLVMValueRef = "__llvm_const_real_of_string"
pub fn llvm_const_real_of_string(real_ty: LLVMTypeRef, text: String) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(text);
  __llvm_const_real_of_string(real_ty, cstr)
}
pub fn LLVMTypeRef::const_real_of_string(self: LLVMTypeRef, text: String) -> LLVMValueRef {
  llvm_const_real_of_string(self, text)
}

pub extern "C" fn llvm_const_real_of_string_and_size(real_ty: LLVMTypeRef, text: CStr, s_len: UInt) -> LLVMValueRef = "__llvm_const_real_of_string_and_size"

pub extern "C" fn llvm_const_int_get_z_ext_value(constant_val: LLVMValueRef) -> UInt64 = "__llvm_const_int_get_z_ext_value"
pub fn LLVMValueRef::const_int_get_z_ext_value(self: LLVMValueRef) -> UInt64 {
  llvm_const_int_get_z_ext_value(self)
}

pub extern "C" fn llvm_const_int_get_s_ext_value(constant_val: LLVMValueRef) -> Int64 = "__llvm_const_int_get_s_ext_value"
pub fn LLVMValueRef::const_int_get_s_ext_value(self: LLVMValueRef) -> Int64 {
  llvm_const_int_get_s_ext_value(self)
}

// pub extern "C" fn llvm_const_real_get_double(constant_val: LLVMValueRef, loses_info: Ptr[LLVMBool]) -> Double = "__llvm_const_real_get_double"

pub extern "C" fn llvm_const_string_in_context(context: LLVMContextRef, str: CStr, length: UInt, dont_null_terminate: LLVMBool) -> LLVMValueRef = "__llvm_const_string_in_context"

pub extern "C" fn llvm_const_string_in_context2(context: LLVMContextRef, str: CStr, length: UInt64, dont_null_terminate: LLVMBool) -> LLVMValueRef = "__llvm_const_string_in_context2"

pub extern "C" fn llvm_const_string(str: CStr, length: UInt, dont_null_terminate: LLVMBool) -> LLVMValueRef = "__llvm_const_string"

extern "C" fn __llvm_is_constant_string(c: LLVMValueRef) -> LLVMBool = "__llvm_is_constant_string"
pub fn llvm_is_constant_string(c: LLVMValueRef) -> Bool {
  __llvm_is_constant_string(c).to_moonbit_bool()
}
pub fn LLVMValueRef::is_constant_string(self: LLVMValueRef) -> Bool {
  __llvm_is_constant_string(self).to_moonbit_bool()
}

// pub extern "C" fn llvm_get_as_string(c: LLVMValueRef, length: Ptr[UInt64]) -> CStr = "__llvm_get_as_string"

extern "C" fn __llvm_const_struct_in_context(context: LLVMContextRef, constant_vals: Array[LLVMValueRef], packed: LLVMBool) -> LLVMValueRef = "__llvm_const_struct_in_context"
pub fn llvm_const_struct_in_context(context: LLVMContextRef, constant_vals: Array[LLVMValueRef], packed: Bool) -> LLVMValueRef {
  __llvm_const_struct_in_context(context, constant_vals, to_llvm_bool(packed))
}
pub fn LLVMContextRef::const_struct(self: LLVMContextRef, constant_vals: Array[LLVMValueRef], packed: Bool) -> LLVMValueRef {
  __llvm_const_struct_in_context(self, constant_vals, to_llvm_bool(packed))
}

extern "C" fn __llvm_const_struct(constant_vals: Array[LLVMValueRef], packed: LLVMBool) -> LLVMValueRef = "__llvm_const_struct"
pub fn llvm_const_struct(constant_vals: Array[LLVMValueRef], packed: Bool) -> LLVMValueRef {
  __llvm_const_struct(constant_vals, to_llvm_bool(packed))
}
pub fn LLVMValueRef::const_struct(constant_vals: Array[LLVMValueRef], packed: Bool) -> LLVMValueRef {
  __llvm_const_struct(constant_vals, to_llvm_bool(packed))
}

extern "C" fn llvm_const_array(element_ty: LLVMTypeRef, constant_vals: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_array"
pub fn LLVMValueRef::const_array(self: LLVMTypeRef, constant_vals: Array[LLVMValueRef]) -> LLVMValueRef {
  llvm_const_array(self, constant_vals)
}

pub extern "C" fn llvm_const_array2(element_ty: LLVMTypeRef, constant_vals: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_array2"
pub fn LLVMValueRef::const_array2(self: LLVMTypeRef, constant_vals: Array[LLVMValueRef]) -> LLVMValueRef {
  llvm_const_array2(self, constant_vals)
}

pub extern "C" fn llvm_const_named_struct(struct_ty: LLVMTypeRef, constant_vals: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_named_struct"
pub fn LLVMValueRef::const_named_struct(self: LLVMTypeRef, constant_vals: Array[LLVMValueRef]) -> LLVMValueRef {
  llvm_const_named_struct(self, constant_vals)
}

pub extern "C" fn llvm_get_aggregate_element(c: LLVMValueRef, idx: UInt) -> LLVMValueRef = "__llvm_get_aggregate_element"
pub fn LLVMValueRef::get_aggregate_element(self: LLVMValueRef, idx: UInt) -> LLVMValueRef {
  llvm_get_aggregate_element(self, idx)
}

pub extern "C" fn llvm_const_vector(scalar_constant_vals: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_vector"
pub fn LLVMValueRef::const_vector(self: Array[LLVMValueRef]) -> LLVMValueRef {
  llvm_const_vector(self)
}

extern "C" fn __llvm_get_const_opcode(constant_val: LLVMValueRef) -> Int = "__llvm_get_const_opcode"
pub fn llvm_get_const_opcode(constant_val: LLVMValueRef) -> LLVMOpcode {
  let opcode = __llvm_get_const_opcode(constant_val);
  LLVMOpcode::from_int(opcode)
}

pub extern "C" fn llvm_align_of(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_align_of"
pub fn LLVMTypeRef::align_of(self: LLVMTypeRef) -> LLVMValueRef {
  llvm_align_of(self)
}

pub extern "C" fn llvm_size_of(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_size_of"
pub fn LLVMTypeRef::size_of(self: LLVMTypeRef) -> LLVMValueRef {
  llvm_size_of(self)
}

pub extern "C" fn llvm_const_neg(constant_val: LLVMValueRef) -> LLVMValueRef = "__llvm_const_neg"
pub fn LLVMValueRef::const_neg(self: LLVMValueRef) -> LLVMValueRef {
  llvm_const_neg(self)
}

pub extern "C" fn llvm_const_nsw_neg(constant_val: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nsw_neg"
pub fn LLVMValueRef::const_nsw_neg(self: LLVMValueRef) -> LLVMValueRef {
  llvm_const_nsw_neg(self)
}

pub extern "C" fn llvm_const_not(constant_val: LLVMValueRef) -> LLVMValueRef = "__llvm_const_not"
pub fn LLVMValueRef::const_not(self: LLVMValueRef) -> LLVMValueRef {
  llvm_const_not(self)
}

pub extern "C" fn llvm_const_add(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_add"
pub fn LLVMValueRef::const_add(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_add(self, rhs_constant)
}

pub extern "C" fn llvm_const_nsw_add(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nsw_add"
pub fn LLVMValueRef::const_nsw_add(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_nsw_add(self, rhs_constant)
}

pub extern "C" fn llvm_const_nuw_add(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nuw_add"
pub fn LLVMValueRef::const_nuw_add(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_nuw_add(self, rhs_constant)
}

pub extern "C" fn llvm_const_sub(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_sub"
pub fn LLVMValueRef::const_sub(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_sub(self, rhs_constant)
}

pub extern "C" fn llvm_const_nsw_sub(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nsw_sub"
pub fn LLVMValueRef::const_nsw_sub(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_nsw_sub(self, rhs_constant)
}

pub extern "C" fn llvm_const_nuw_sub(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nuw_sub"
pub fn LLVMValueRef::const_nuw_sub(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_nuw_sub(self, rhs_constant)
}

pub extern "C" fn llvm_const_mul(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_mul"
pub fn LLVMValueRef::const_mul(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_mul(self, rhs_constant)
}

pub extern "C" fn llvm_const_nsw_mul(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nsw_mul"
pub fn LLVMValueRef::const_nsw_mul(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_nsw_mul(self, rhs_constant)
}

pub extern "C" fn llvm_const_nuw_mul(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nuw_mul"
pub fn LLVMValueRef::const_nuw_mul(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_nuw_mul(self, rhs_constant)
}

pub extern "C" fn llvm_const_xor(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_xor"
pub fn LLVMValueRef::const_xor(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_xor(self, rhs_constant)
}

pub extern "C" fn llvm_const_gep2(ty: LLVMTypeRef, constant_val: LLVMValueRef, constant_indices: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_gep2"
pub fn LLVMTypeRef::const_gep2(self: LLVMTypeRef, constant_val: LLVMValueRef, constant_indices: Array[LLVMValueRef]) -> LLVMValueRef {
  llvm_const_gep2(self, constant_val, constant_indices)
}

pub extern "C" fn llvm_const_in_bounds_gep2(ty: LLVMTypeRef, constant_val: LLVMValueRef, constant_indices: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_in_bounds_gep2"
pub fn LLVMTypeRef::const_in_bounds_gep2(self: LLVMTypeRef, constant_val: LLVMValueRef, constant_indices: Array[LLVMValueRef]) -> LLVMValueRef {
  llvm_const_in_bounds_gep2(self, constant_val, constant_indices)
}

pub extern "C" fn llvm_const_trunc(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_trunc"
pub fn LLVMValueRef::const_trunc(self: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_trunc(self, to_type)
}

pub extern "C" fn llvm_const_ptr_to_int(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_ptr_to_int"
pub fn LLVMValueRef::const_ptr_to_int(self: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_ptr_to_int(self, to_type)
}

pub extern "C" fn llvm_const_int_to_ptr(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_int_to_ptr"
pub fn LLVMValueRef::const_int_to_ptr(self: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_int_to_ptr(self, to_type)
}

pub extern "C" fn llvm_const_bit_cast(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_bit_cast"
pub fn LLVMValueRef::const_bit_cast(self: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_bit_cast(self, to_type)
}

pub extern "C" fn llvm_const_addr_space_cast(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_addr_space_cast"
pub fn LLVMValueRef::const_addr_space_cast(self: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_addr_space_cast(self, to_type)
}

pub extern "C" fn llvm_const_trunc_or_bit_cast(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_trunc_or_bit_cast"
pub fn LLVMValueRef::const_trunc_or_bit_cast(self: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_trunc_or_bit_cast(self, to_type)
}

pub extern "C" fn llvm_const_pointer_cast(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_pointer_cast"
pub fn LLVMValueRef::const_pointer_cast(self: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_pointer_cast(self, to_type)
}

pub extern "C" fn llvm_const_extract_element(vector_constant: LLVMValueRef, index_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_extract_element"
pub fn LLVMValueRef::const_extract_element(self: LLVMValueRef, index_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_extract_element(self, index_constant)
}

pub extern "C" fn llvm_const_insert_element(vector_constant: LLVMValueRef, element_value_constant: LLVMValueRef, index_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_insert_element"
pub fn LLVMValueRef::const_insert_element(self: LLVMValueRef, element_value_constant: LLVMValueRef, index_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_insert_element(self, element_value_constant, index_constant)
}

pub extern "C" fn llvm_const_shuffle_vector(vector_a_constant: LLVMValueRef, vector_b_constant: LLVMValueRef, mask_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_shuffle_vector"
pub fn LLVMValueRef::const_shuffle_vector(self: LLVMValueRef, vector_b_constant: LLVMValueRef, mask_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_shuffle_vector(self, vector_b_constant, mask_constant)
}

pub extern "C" fn llvm_block_address(f: LLVMValueRef, bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_block_address"
pub fn LLVMValueRef::block_address(self: LLVMValueRef, bb: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_block_address(self, bb)
}

pub extern "C" fn llvm_get_block_address_function(block_addr: LLVMValueRef) -> LLVMValueRef = "__llvm_get_block_address_function"
pub fn LLVMValueRef::get_block_address_function(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_block_address_function(self)
}

pub extern "C" fn llvm_get_block_address_basic_block(block_addr: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_block_address_basic_block"
pub fn LLVMValueRef::get_block_address_basic_block(self: LLVMValueRef) -> LLVMBasicBlockRef {
  llvm_get_block_address_basic_block(self)
}

extern "C" fn __llvm_const_inline_asm(ty: LLVMTypeRef, asm_string: CStr, constraints: CStr, has_side_effects: LLVMBool, is_align_stack: LLVMBool) -> LLVMValueRef = "__llvm_const_inline_asm"
pub fn llvm_const_inline_asm(ty: LLVMTypeRef, asm_string: String, constraints: String, has_side_effects: Bool, is_align_stack: Bool) -> LLVMValueRef {
  let asm_str = moonbit_str_to_c_str(asm_string);
  let constraints_str = moonbit_str_to_c_str(constraints);
  __llvm_const_inline_asm(ty, asm_str, constraints_str, to_llvm_bool(has_side_effects), to_llvm_bool(is_align_stack))
}
pub fn LLVMTypeRef::const_inline_asm(self: LLVMTypeRef, asm_string: String, constraints: String, has_side_effects: Bool, is_align_stack: Bool) -> LLVMValueRef {
  llvm_const_inline_asm(self, asm_string, constraints, has_side_effects, is_align_stack)
}

pub extern "C" fn llvm_get_global_parent(global: LLVMValueRef) -> LLVMModuleRef = "__llvm_get_global_parent"
pub fn LLVMValueRef::get_global_parent(self: LLVMValueRef) -> LLVMModuleRef {
  llvm_get_global_parent(self)
}

extern "C" fn __llvm_is_declaration(global: LLVMValueRef) -> LLVMBool = "__llvm_is_declaration"
pub fn llvm_is_declaration(global: LLVMValueRef) -> Bool {
  __llvm_is_declaration(global).to_moonbit_bool()
}
pub fn LLVMValueRef::is_declaration(self: LLVMValueRef) -> Bool {
  __llvm_is_declaration(self).to_moonbit_bool()
}

pub extern "C" fn llvm_get_linkage(global: LLVMValueRef) -> LLVMLinkage = "__llvm_get_linkage"

pub extern "C" fn llvm_set_linkage(global: LLVMValueRef, linkage: LLVMLinkage) = "__llvm_set_linkage"

extern "C" fn __llvm_get_section(global: LLVMValueRef) -> CStr = "__llvm_get_section"
pub fn llvm_get_section(global: LLVMValueRef) -> String {
  let cstr = __llvm_get_section(global);
  c_str_to_moonbit_str(cstr)
}
pub fn LLVMValueRef::get_section(self: LLVMValueRef) -> String {
  llvm_get_section(self)
}

extern "C" fn __llvm_set_section(global: LLVMValueRef, section: CStr) = "__llvm_set_section"
pub fn llvm_set_section(global: LLVMValueRef, section: String) -> Unit {
  let cstr = moonbit_str_to_c_str(section);
  __llvm_set_section(global, cstr)
}
pub fn LLVMValueRef::set_section(self: LLVMValueRef, section: String) -> Unit {
  llvm_set_section(self, section)
}

pub extern "C" fn llvm_get_visibility(global: LLVMValueRef) -> LLVMVisibility = "__llvm_get_visibility"

pub extern "C" fn llvm_set_visibility(global: LLVMValueRef, viz: LLVMVisibility) = "__llvm_set_visibility"

pub extern "C" fn llvm_get_dll_storage_class(global: LLVMValueRef) -> LLVMDLLStorageClass = "__llvm_get_dll_storage_class"

pub extern "C" fn llvm_get_unnamed_address(global: LLVMValueRef) -> LLVMUnnamedAddr = "__llvm_get_unnamed_address"

pub extern "C" fn llvm_set_unnamed_address(global: LLVMValueRef, unnamed_addr: LLVMUnnamedAddr) = "__llvm_set_unnamed_address"

pub extern "C" fn llvm_global_get_value_type(global: LLVMValueRef) -> LLVMTypeRef = "__llvm_global_get_value_type"
pub fn LLVMValueRef::global_get_value_type(self: LLVMValueRef) -> LLVMTypeRef {
  llvm_global_get_value_type(self)
}

extern "C" fn __llvm_has_unnamed_addr(global: LLVMValueRef) -> LLVMBool = "__llvm_has_unnamed_addr"
pub fn llvm_has_unnamed_addr(global: LLVMValueRef) -> Bool {
  __llvm_has_unnamed_addr(global).to_moonbit_bool()
}
pub fn LLVMValueRef::has_unnamed_addr(self: LLVMValueRef) -> Bool {
  __llvm_has_unnamed_addr(self).to_moonbit_bool()
}

extern "C" fn __llvm_set_unnamed_addr(global: LLVMValueRef, has_unnamed_addr: LLVMBool) = "__llvm_set_unnamed_addr"
pub fn llvm_set_unnamed_addr(global: LLVMValueRef, has_unnamed_addr: Bool) -> Unit {
  __llvm_set_unnamed_addr(global, to_llvm_bool(has_unnamed_addr))
}
pub fn LLVMValueRef::set_unnamed_addr(self: LLVMValueRef, has_unnamed_addr: Bool) -> Unit {
  __llvm_set_unnamed_addr(self, to_llvm_bool(has_unnamed_addr))
}

pub extern "C" fn llvm_get_alignment(v: LLVMValueRef) -> UInt = "__llvm_get_alignment"
pub fn LLVMValueRef::get_alignment(self: LLVMValueRef) -> UInt {
  llvm_get_alignment(self)
}

pub extern "C" fn llvm_set_alignment(v: LLVMValueRef, bytes: UInt) = "__llvm_set_alignment"
pub fn LLVMValueRef::set_alignment(self: LLVMValueRef, bytes: UInt) -> Unit {
  llvm_set_alignment(self, bytes)
}

pub extern "C" fn llvm_global_set_metadata(global: LLVMValueRef, kind: UInt, md: LLVMMetadataRef) = "__llvm_global_set_metadata"
pub fn LLVMValueRef::global_set_metadata(self: LLVMValueRef, kind: UInt, md: LLVMMetadataRef) -> Unit {
  llvm_global_set_metadata(self, kind, md)
}

pub extern "C" fn llvm_global_erase_metadata(global: LLVMValueRef, kind: UInt) = "__llvm_global_erase_metadata"
pub fn LLVMValueRef::global_erase_metadata(self: LLVMValueRef, kind: UInt) -> Unit {
  llvm_global_erase_metadata(self, kind)
}

pub extern "C" fn llvm_global_clear_metadata(global: LLVMValueRef) = "__llvm_global_clear_metadata"
pub fn LLVMValueRef::global_clear_metadata(self: LLVMValueRef) -> Unit {
  llvm_global_clear_metadata(self)
}

// pub extern "C" fn llvm_global_copy_all_metadata(value: LLVMValueRef, num_entries: Ptr[UInt64]) -> Ptr[LLVMValueMetadataEntry] = "__llvm_global_copy_all_metadata"

// pub extern "C" fn llvm_dispose_value_metadata_entries(entries: Ptr[LLVMValueMetadataEntry]) = "__llvm_dispose_value_metadata_entries"

// pub extern "C" fn llvm_value_metadata_entries_get_kind(entries: Ptr[LLVMValueMetadataEntry], index: UInt) -> UInt = "__llvm_value_metadata_entries_get_kind"

// pub extern "C" fn llvm_value_metadata_entries_get_metadata(entries: Ptr[LLVMValueMetadataEntry], index: UInt) -> LLVMMetadataRef = "__llvm_value_metadata_entries_get_metadata"

pub extern "C" fn llvm_add_global(m: LLVMModuleRef, ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_add_global"

pub extern "C" fn llvm_add_global_in_address_space(m: LLVMModuleRef, ty: LLVMTypeRef, name: CStr, address_space: AddressSpace) -> LLVMValueRef = "__llvm_add_global_in_address_space"

pub extern "C" fn llvm_get_named_global(m: LLVMModuleRef, name: CStr) -> LLVMValueRef = "__llvm_get_named_global"

pub extern "C" fn llvm_get_first_global(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_first_global"

pub extern "C" fn llvm_get_last_global(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_last_global"

pub extern "C" fn llvm_get_next_global(global_var: LLVMValueRef) -> LLVMValueRef = "__llvm_get_next_global"

pub extern "C" fn llvm_get_previous_global(global_var: LLVMValueRef) -> LLVMValueRef = "__llvm_get_previous_global"

pub extern "C" fn llvm_delete_global(global_var: LLVMValueRef) = "__llvm_delete_global"

pub extern "C" fn llvm_get_initializer(global_var: LLVMValueRef) -> LLVMValueRef = "__llvm_get_initializer"

pub extern "C" fn llvm_set_initializer(global_var: LLVMValueRef, constant_val: LLVMValueRef) = "__llvm_set_initializer"

pub extern "C" fn llvm_is_thread_local(global_var: LLVMValueRef) -> LLVMBool = "__llvm_is_thread_local"

pub extern "C" fn llvm_set_thread_local(global_var: LLVMValueRef, is_thread_local: LLVMBool) = "__llvm_set_thread_local"

pub extern "C" fn llvm_is_global_constant(global_var: LLVMValueRef) -> LLVMBool = "__llvm_is_global_constant"

pub extern "C" fn llvm_set_global_constant(global_var: LLVMValueRef, is_constant: LLVMBool) = "__llvm_set_global_constant"

pub extern "C" fn llvm_get_thread_local_mode(global_var: LLVMValueRef) -> LLVMThreadLocalMode = "__llvm_get_thread_local_mode"

pub extern "C" fn llvm_set_thread_local_mode(global_var: LLVMValueRef, mode: LLVMThreadLocalMode) = "__llvm_set_thread_local_mode"

pub extern "C" fn llvm_is_externally_initialized(global_var: LLVMValueRef) -> LLVMBool = "__llvm_is_externally_initialized"

pub extern "C" fn llvm_set_externally_initialized(global_var: LLVMValueRef, is_ext_init: LLVMBool) = "__llvm_set_externally_initialized"

pub extern "C" fn llvm_add_alias2(m: LLVMModuleRef, value_ty: LLVMTypeRef, addr_space: UInt, aliasee: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_add_alias2"

pub extern "C" fn llvm_get_named_global_alias(m: LLVMModuleRef, name: CStr, name_len: UInt64) -> LLVMValueRef = "__llvm_get_named_global_alias"

pub extern "C" fn llvm_get_first_global_alias(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_first_global_alias"

pub extern "C" fn llvm_get_last_global_alias(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_last_global_alias"

pub extern "C" fn llvm_get_next_global_alias(ga: LLVMValueRef) -> LLVMValueRef = "__llvm_get_next_global_alias"

pub extern "C" fn llvm_get_previous_global_alias(ga: LLVMValueRef) -> LLVMValueRef = "__llvm_get_previous_global_alias"

pub extern "C" fn llvm_alias_get_aliasee(alias_ref: LLVMValueRef) -> LLVMValueRef = "__llvm_alias_get_aliasee"

pub extern "C" fn llvm_alias_set_aliasee(alias_ref: LLVMValueRef, aliasee: LLVMValueRef) = "__llvm_alias_set_aliasee"

pub extern "C" fn llvm_delete_function(func: LLVMValueRef) = "__llvm_delete_function"
//
pub extern "C" fn llvm_has_personality_fn(func: LLVMValueRef) -> LLVMBool = "__llvm_has_personality_fn"
//
pub extern "C" fn llvm_get_personality_fn(func: LLVMValueRef) -> LLVMValueRef = "__llvm_get_personality_fn"
//
pub extern "C" fn llvm_set_personality_fn(func: LLVMValueRef, personality_fn: LLVMValueRef) = "__llvm_set_personality_fn"
//
pub extern "C" fn llvm_lookup_intrinsic_id(name: CStr, name_len: UInt64) -> UInt = "__llvm_lookup_intrinsic_id"
//
pub extern "C" fn llvm_get_intrinsic_id(func: LLVMValueRef) -> UInt = "__llvm_get_intrinsic_id"

pub extern "C" fn llvm_get_intrinsic_declaration(mod: LLVMModuleRef, id: UInt, param_types: Array[LLVMTypeRef]) -> LLVMValueRef = "__llvm_get_intrinsic_declaration"

pub extern "C" fn llvm_intrinsic_get_type(ctx: LLVMContextRef, id: UInt, param_types: Array[LLVMTypeRef]) -> LLVMTypeRef = "__llvm_intrinsic_get_type"

// pub extern "C" fn llvm_intrinsic_get_name(id: UInt, name_length: Ptr[UInt64]) -> CStr = "__llvm_intrinsic_get_name"

pub extern "C" fn llvm_intrinsic_copy_overloaded_name(id: UInt, param_types: Array[LLVMTypeRef]) -> CStr = "__llvm_intrinsic_copy_overloaded_name"

pub extern "C" fn llvm_intrinsic_copy_overloaded_name2(mod: LLVMModuleRef, id: UInt, param_types: Array[LLVMTypeRef]) -> CStr = "__llvm_intrinsic_copy_overloaded_name2"

pub extern "C" fn llvm_intrinsic_is_overloaded(id: UInt) -> LLVMBool = "__llvm_intrinsic_is_overloaded"

pub extern "C" fn llvm_get_function_call_conv(func: LLVMValueRef) -> UInt = "__llvm_get_function_call_conv"

pub extern "C" fn llvm_set_function_call_conv(func: LLVMValueRef, cc: UInt) = "__llvm_set_function_call_conv"

pub extern "C" fn llvm_get_gc(func: LLVMValueRef) -> CStr = "__llvm_get_gc"

pub extern "C" fn llvm_set_gc(func: LLVMValueRef, name: CStr) = "__llvm_set_gc"

pub extern "C" fn llvm_get_prefix_data(func: LLVMValueRef) -> LLVMValueRef = "__llvm_get_prefix_data"

pub extern "C" fn llvm_has_prefix_data(func: LLVMValueRef) -> LLVMBool = "__llvm_has_prefix_data"

pub extern "C" fn llvm_set_prefix_data(func: LLVMValueRef, prefix_data: LLVMValueRef) = "__llvm_set_prefix_data"

pub extern "C" fn llvm_get_prologue_data(func: LLVMValueRef) -> LLVMValueRef = "__llvm_get_prologue_data"

pub extern "C" fn llvm_has_prologue_data(func: LLVMValueRef) -> LLVMBool = "__llvm_has_prologue_data"

pub extern "C" fn llvm_set_prologue_data(func: LLVMValueRef, prologue_data: LLVMValueRef) = "__llvm_set_prologue_data"

pub extern "C" fn llvm_add_attribute_at_index(f: LLVMValueRef, idx: LLVMAttributeIndex, a: LLVMAttributeRef) = "__llvm_add_attribute_at_index"

pub extern "C" fn llvm_get_attribute_count_at_index(f: LLVMValueRef, idx: LLVMAttributeIndex) -> UInt = "__llvm_get_attribute_count_at_index"

// pub extern "C" fn llvm_get_attributes_at_index(f: LLVMValueRef, idx: LLVMAttributeIndex, attrs: Ptr[LLVMAttributeRef]) = "__llvm_get_attributes_at_index"

pub extern "C" fn llvm_get_enum_attribute_at_index(f: LLVMValueRef, idx: LLVMAttributeIndex, kind_id: UInt) -> LLVMAttributeRef = "__llvm_get_enum_attribute_at_index"

pub extern "C" fn llvm_get_string_attribute_at_index(f: LLVMValueRef, idx: LLVMAttributeIndex, k: CStr, k_len: UInt) -> LLVMAttributeRef = "__llvm_get_string_attribute_at_index"

pub extern "C" fn llvm_remove_enum_attribute_at_index(f: LLVMValueRef, idx: LLVMAttributeIndex, kind_id: UInt) = "__llvm_remove_enum_attribute_at_index"

pub extern "C" fn llvm_remove_string_attribute_at_index(f: LLVMValueRef, idx: LLVMAttributeIndex, k: CStr, k_len: UInt) = "__llvm_remove_string_attribute_at_index"

pub extern "C" fn llvm_add_target_dependent_function_attr(func: LLVMValueRef, a: CStr, v: CStr) = "__llvm_add_target_dependent_function_attr"

pub extern "C" fn llvm_count_params(func: LLVMValueRef) -> UInt = "__llvm_count_params"

// FIXME: Not implemented
pub extern "C" fn llvm_get_params(func: LLVMValueRef) -> Array[LLVMValueRef] = "__llvm_get_params"

pub extern "C" fn llvm_get_param(func: LLVMValueRef, index: UInt) -> LLVMValueRef = "__llvm_get_param"

pub extern "C" fn llvm_get_param_parent(inst: LLVMValueRef) -> LLVMValueRef = "__llvm_get_param_parent"

pub extern "C" fn llvm_get_first_param(func: LLVMValueRef) -> LLVMValueRef = "__llvm_get_first_param"

pub extern "C" fn llvm_get_last_param(func: LLVMValueRef) -> LLVMValueRef = "__llvm_get_last_param"

pub extern "C" fn llvm_get_next_param(arg: LLVMValueRef) -> LLVMValueRef = "__llvm_get_next_param"

pub extern "C" fn llvm_get_previous_param(arg: LLVMValueRef) -> LLVMValueRef = "__llvm_get_previous_param"

pub extern "C" fn llvm_set_param_alignment(arg: LLVMValueRef, align: UInt) = "__llvm_set_param_alignment"

pub extern "C" fn llvm_add_global_ifunc(m: LLVMModuleRef, name: CStr, name_len: UInt64, ty: LLVMTypeRef, addr_space: UInt, resolver: LLVMValueRef) -> LLVMValueRef = "__llvm_add_global_ifunc"

pub extern "C" fn llvm_get_named_global_ifunc(m: LLVMModuleRef, name: CStr, name_len: UInt64) -> LLVMValueRef = "__llvm_get_named_global_ifunc"

pub extern "C" fn llvm_get_first_global_ifunc(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_first_global_ifunc"

pub extern "C" fn llvm_get_last_global_ifunc(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_last_global_ifunc"

pub extern "C" fn llvm_get_next_global_ifunc(ifunc: LLVMValueRef) -> LLVMValueRef = "__llvm_get_next_global_ifunc"

pub extern "C" fn llvm_get_previous_global_ifunc(ifunc: LLVMValueRef) -> LLVMValueRef = "__llvm_get_previous_global_ifunc"

pub extern "C" fn llvm_get_global_ifunc_resolver(ifunc: LLVMValueRef) -> LLVMValueRef = "__llvm_get_global_ifunc_resolver"

pub extern "C" fn llvm_set_global_ifunc_resolver(ifunc: LLVMValueRef, resolver: LLVMValueRef) = "__llvm_set_global_ifunc_resolver"

pub extern "C" fn llvm_erase_global_ifunc(ifunc: LLVMValueRef) = "__llvm_erase_global_ifunc"

pub extern "C" fn llvm_remove_global_ifunc(ifunc: LLVMValueRef) = "__llvm_remove_global_ifunc"

pub extern "C" fn llvm_md_string_in_context2(context: LLVMContextRef, str: CStr, s_len: UInt64) -> LLVMMetadataRef = "__llvm_md_string_in_context2"

pub extern "C" fn llvm_md_node_in_context2(context: LLVMContextRef, mds: Array[LLVMMetadataRef]) -> LLVMMetadataRef = "__llvm_md_node_in_context2"

pub extern "C" fn llvm_metadata_as_value(context: LLVMContextRef, md: LLVMMetadataRef) -> LLVMValueRef = "__llvm_metadata_as_value"

pub extern "C" fn llvm_value_as_metadata(val: LLVMValueRef) -> LLVMMetadataRef = "__llvm_value_as_metadata"

// pub extern "C" fn llvm_get_md_string(v: LLVMValueRef, length: Ptr[UInt]) -> CStr = "__llvm_get_md_string"

pub extern "C" fn llvm_get_md_node_num_operands(v: LLVMValueRef) -> UInt = "__llvm_get_md_node_num_operands"

// FIXME: Not implemented
pub extern "C" fn llvm_get_md_node_operands(v: LLVMValueRef) -> Array[LLVMValueRef] = "__llvm_get_md_node_operands" 

pub extern "C" fn llvm_replace_md_node_operand_with(v: LLVMValueRef, index: UInt, replacement: LLVMMetadataRef) = "__llvm_replace_md_node_operand_with"

pub extern "C" fn llvm_md_string_in_context(context: LLVMContextRef, str: CStr, s_len: UInt) -> LLVMValueRef = "__llvm_md_string_in_context"

pub extern "C" fn llvm_md_string(str: CStr, s_len: UInt) -> LLVMValueRef = "__llvm_md_string"

pub extern "C" fn llvm_md_node_in_context(context: LLVMContextRef, vals: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_md_node_in_context"

pub extern "C" fn llvm_md_node(vals: Array[LLVMValueRef], count: UInt) -> LLVMValueRef = "__llvm_md_node"

pub extern "C" fn llvm_create_operand_bundle(tag: CStr, tag_len: UInt64, args: Array[LLVMValueRef]) -> LLVMOperandBundleRef = "__llvm_create_operand_bundle"

pub extern "C" fn llvm_dispose_operand_bundle(bundle: LLVMOperandBundleRef) = "__llvm_dispose_operand_bundle"

// pub extern "C" fn llvm_get_operand_bundle_tag(bundle: LLVMOperandBundleRef, len: Ptr[UInt64]) -> CStr = "__llvm_get_operand_bundle_tag"

pub extern "C" fn llvm_get_num_operand_bundle_args(bundle: LLVMOperandBundleRef) -> UInt = "__llvm_get_num_operand_bundle_args"

pub extern "C" fn llvm_get_operand_bundle_arg_at_index(bundle: LLVMOperandBundleRef, index: UInt) -> LLVMValueRef = "__llvm_get_operand_bundle_arg_at_index"

pub extern "C" fn llvm_basic_block_as_value(bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_basic_block_as_value"
pub fn LLVMBasicBlockRef::as_value_ref(self: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_basic_block_as_value(self)
}

pub extern "C" fn llvm_value_is_basic_block(val: LLVMValueRef) -> LLVMBool = "__llvm_value_is_basic_block"

pub extern "C" fn llvm_value_as_basic_block(val: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_value_as_basic_block"

extern "C" fn __llvm_get_basic_block_name(bb: LLVMBasicBlockRef) -> CStr = "__llvm_get_basic_block_name"
pub fn llvm_get_basic_block_name(bb: LLVMBasicBlockRef) -> String {
  let name = __llvm_get_basic_block_name(bb);
  c_str_to_moonbit_str(name)
}
pub fn LLVMBasicBlockRef::get_name(self: LLVMBasicBlockRef) -> String {
  llvm_get_basic_block_name(self)
}

pub extern "C" fn llvm_get_basic_block_parent(bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_get_basic_block_parent"
pub fn LLVMBasicBlockRef::get_parent(self: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_get_basic_block_parent(self)
}

pub extern "C" fn llvm_get_basic_block_terminator(bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_get_basic_block_terminator"
pub fn LLVMBasicBlockRef::get_terminator(self: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_get_basic_block_terminator(self)
}

pub extern "C" fn llvm_count_basic_blocks(func: LLVMValueRef) -> UInt = "__llvm_count_basic_blocks"

pub extern "C" fn llvm_get_basic_blocks(func: LLVMValueRef) -> Array[BasicBlock] = "__llvm_get_basic_blocks"

pub extern "C" fn llvm_get_first_basic_block(func: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_first_basic_block"

pub extern "C" fn llvm_get_last_basic_block(func: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_last_basic_block"

pub extern "C" fn llvm_get_next_basic_block(bb: LLVMBasicBlockRef) -> LLVMBasicBlockRef = "__llvm_get_next_basic_block"

pub extern "C" fn llvm_get_previous_basic_block(bb: LLVMBasicBlockRef) -> LLVMBasicBlockRef = "__llvm_get_previous_basic_block"

pub extern "C" fn llvm_get_entry_basic_block(func: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_entry_basic_block"

pub extern "C" fn llvm_insert_existing_basic_block_after_insert_block(builder: LLVMBuilderRef, bb: LLVMBasicBlockRef) = "__llvm_insert_existing_basic_block_after_insert_block"

pub extern "C" fn llvm_append_existing_basic_block(func: LLVMValueRef, bb: LLVMBasicBlockRef) = "__llvm_append_existing_basic_block"

pub extern "C" fn llvm_create_basic_block_in_context(context: LLVMContextRef, name: CStr) -> LLVMBasicBlockRef = "__llvm_create_basic_block_in_context"

pub extern "C" fn llvm_append_basic_block_in_context(context: LLVMContextRef, func: LLVMValueRef, name: CStr) -> LLVMBasicBlockRef = "__llvm_append_basic_block_in_context"

pub extern "C" fn llvm_append_basic_block(func: LLVMValueRef, name: CStr) -> LLVMBasicBlockRef = "__llvm_append_basic_block"

pub extern "C" fn llvm_insert_basic_block_in_context(context: LLVMContextRef, bb: LLVMBasicBlockRef, name: CStr) -> LLVMBasicBlockRef = "__llvm_insert_basic_block_in_context"

pub extern "C" fn llvm_insert_basic_block(insert_before_bb: LLVMBasicBlockRef, name: CStr) -> LLVMBasicBlockRef = "__llvm_insert_basic_block"

pub extern "C" fn llvm_delete_basic_block(bb: LLVMBasicBlockRef) = "__llvm_delete_basic_block"

pub extern "C" fn llvm_remove_basic_block_from_parent(bb: LLVMBasicBlockRef) = "__llvm_remove_basic_block_from_parent"

pub extern "C" fn llvm_move_basic_block_before(bb: LLVMBasicBlockRef, move_pos: LLVMBasicBlockRef) = "__llvm_move_basic_block_before"

pub extern "C" fn llvm_move_basic_block_after(bb: LLVMBasicBlockRef, move_pos: LLVMBasicBlockRef) = "__llvm_move_basic_block_after"

pub extern "C" fn llvm_get_first_instruction(bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_get_first_instruction"

pub extern "C" fn llvm_get_last_instruction(bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_get_last_instruction"

pub extern "C" fn llvm_has_metadata(val: LLVMValueRef) -> Int = "__llvm_has_metadata"

pub extern "C" fn llvm_get_metadata(val: LLVMValueRef, kind_id: UInt) -> LLVMValueRef = "__llvm_get_metadata"

pub extern "C" fn llvm_set_metadata(val: LLVMValueRef, kind_id: UInt, node: LLVMValueRef) = "__llvm_set_metadata"

// pub extern "C" fn llvm_instruction_get_all_metadata_other_than_debug_loc(instr: LLVMValueRef, num_entries: Ptr[UInt64]) -> Ptr[LLVMValueMetadataEntry] = "__llvm_instruction_get_all_metadata_other_than_debug_loc"

pub extern "C" fn llvm_get_instruction_parent(inst: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_instruction_parent"

pub extern "C" fn llvm_get_next_instruction(inst: LLVMValueRef) -> LLVMValueRef = "__llvm_get_next_instruction"

pub extern "C" fn llvm_get_previous_instruction(inst: LLVMValueRef) -> LLVMValueRef = "__llvm_get_previous_instruction"

pub extern "C" fn llvm_instruction_remove_from_parent(inst: LLVMValueRef) = "__llvm_instruction_remove_from_parent"

pub extern "C" fn llvm_instruction_erase_from_parent(inst: LLVMValueRef) = "__llvm_instruction_erase_from_parent"

pub extern "C" fn llvm_delete_instruction(inst: LLVMValueRef) = "__llvm_delete_instruction"

extern "C" fn __llvm_get_instruction_opcode(inst: LLVMValueRef) -> Int = "__llvm_get_instruction_opcode"
pub fn llvm_get_instruction_opcode(inst: LLVMValueRef) -> LLVMOpcode {
  let opcode = __llvm_get_instruction_opcode(inst);
  LLVMOpcode::from_int(opcode)
}

extern "C" fn __llvm_get_icmp_predicate(inst: LLVMValueRef) -> Int = "__llvm_get_icmp_predicate"
pub fn llvm_get_icmp_predicate(inst: LLVMValueRef) -> LLVMIntPredicate {
  let predicate = __llvm_get_icmp_predicate(inst);
  LLVMIntPredicate::from_int(predicate)
}

extern "C" fn __llvm_get_fcmp_predicate(inst: LLVMValueRef) -> Int = "__llvm_get_fcmp_predicate"
pub fn llvm_get_fcmp_predicate(inst: LLVMValueRef) -> LLVMRealPredicate {
  let predicate = __llvm_get_fcmp_predicate(inst);
  LLVMRealPredicate::from_int(predicate)
}

pub extern "C" fn llvm_instruction_clone(inst: LLVMValueRef) -> LLVMValueRef = "__llvm_instruction_clone"
pub fn LLVMValueRef::instruction_clone(self: LLVMValueRef) -> LLVMValueRef {
  llvm_instruction_clone(self)
}

pub extern "C" fn llvm_isa_terminator_inst(inst: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_terminator_inst"
pub fn LLVMValueRef::isa_terminator_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_terminator_inst(self)
}

pub extern "C" fn llvm_get_num_arg_operands(instr: LLVMValueRef) -> UInt = "__llvm_get_num_arg_operands"
pub fn LLVMValueRef::get_num_arg_operands(self: LLVMValueRef) -> UInt {
  llvm_get_num_arg_operands(self)
}

pub extern "C" fn llvm_set_instruction_call_conv(instr: LLVMValueRef, cc: UInt) = "__llvm_set_instruction_call_conv"
pub fn LLVMValueRef::set_instruction_call_conv(self: LLVMValueRef, cc: UInt) -> Unit {
  llvm_set_instruction_call_conv(self, cc)
}

pub extern "C" fn llvm_get_instruction_call_conv(instr: LLVMValueRef) -> UInt = "__llvm_get_instruction_call_conv"
pub fn LLVMValueRef::get_instruction_call_conv(self: LLVMValueRef) -> UInt {
  llvm_get_instruction_call_conv(self)
}

pub extern "C" fn llvm_set_instr_param_alignment(instr: LLVMValueRef, idx: LLVMAttributeIndex, align: UInt) = "__llvm_set_instr_param_alignment"
pub fn LLVMValueRef::set_instr_param_alignment(self: LLVMValueRef, idx: LLVMAttributeIndex, align: UInt) -> Unit {
  llvm_set_instr_param_alignment(self, idx, align)
}

pub extern "C" fn llvm_add_call_site_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, a: LLVMAttributeRef) = "__llvm_add_call_site_attribute"

pub extern "C" fn llvm_get_call_site_attribute_count(c: LLVMValueRef, idx: LLVMAttributeIndex) -> UInt = "__llvm_get_call_site_attribute_count"

// pub extern "C" fn llvm_get_call_site_attributes(c: LLVMValueRef, idx: LLVMAttributeIndex, attrs: Ptr[LLVMAttributeRef]) = "__llvm_get_call_site_attributes"

pub extern "C" fn llvm_get_call_site_enum_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, kind_id: UInt) -> LLVMAttributeRef = "__llvm_get_call_site_enum_attribute"

pub extern "C" fn llvm_get_call_site_string_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, k: CStr, k_len: UInt) -> LLVMAttributeRef = "__llvm_get_call_site_string_attribute"

pub extern "C" fn llvm_remove_call_site_enum_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, kind_id: UInt) = "__llvm_remove_call_site_enum_attribute"

pub extern "C" fn llvm_remove_call_site_string_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, k: CStr, k_len: UInt) = "__llvm_remove_call_site_string_attribute"

pub extern "C" fn llvm_get_called_function_type(c: LLVMValueRef) -> LLVMTypeRef = "__llvm_get_called_function_type"
pub fn LLVMValueRef::get_called_function_type(self: LLVMValueRef) -> LLVMTypeRef {
  llvm_get_called_function_type(self)
}

pub extern "C" fn llvm_get_called_value(instr: LLVMValueRef) -> LLVMValueRef = "__llvm_get_called_value"
pub fn LLVMValueRef::get_called_value(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_called_value(self)
}

pub extern "C" fn llvm_get_num_operand_bundles(c: LLVMValueRef) -> UInt = "__llvm_get_num_operand_bundles"
pub fn LLVMValueRef::get_num_operand_bundles(self: LLVMValueRef) -> UInt {
  llvm_get_num_operand_bundles(self)
}

pub extern "C" fn llvm_get_operand_bundle_at_index(c: LLVMValueRef, index: UInt) -> LLVMOperandBundleRef = "__llvm_get_operand_bundle_at_index"
pub fn LLVMValueRef::get_operand_bundle_at_index(self: LLVMValueRef, index: UInt) -> LLVMOperandBundleRef {
  llvm_get_operand_bundle_at_index(self, index)
}

extern "C" fn __llvm_is_tail_call(call_inst: LLVMValueRef) -> LLVMBool = "__llvm_is_tail_call"
pub fn llvm_is_tail_call(call_inst: LLVMValueRef) -> Bool {
  __llvm_is_tail_call(call_inst).to_moonbit_bool()
}
pub fn LLVMValueRef::is_tail_call(self: LLVMValueRef) -> Bool {
  __llvm_is_tail_call(self).to_moonbit_bool()
}

extern "C" fn __llvm_set_tail_call(call_inst: LLVMValueRef, is_tail_call: LLVMBool) = "__llvm_set_tail_call"
pub fn llvm_set_tail_call(call_inst: LLVMValueRef, is_tail_call: Bool) -> Unit {
  __llvm_set_tail_call(call_inst, to_llvm_bool(is_tail_call))
}
pub fn LLVMValueRef::set_tail_call(self: LLVMValueRef, is_tail_call: Bool) -> Unit {
  __llvm_set_tail_call(self, to_llvm_bool(is_tail_call))
}

extern "C" fn __llvm_get_tail_call_kind(call_inst: LLVMValueRef) -> Int = "__llvm_get_tail_call_kind"
pub fn llvm_get_tail_call_kind(call_inst: LLVMValueRef) -> LLVMTailCallKind {
  LLVMTailCallKind::from_int(__llvm_get_tail_call_kind(call_inst))
}

extern "C" fn __llvm_set_tail_call_kind(call_inst: LLVMValueRef, kind: Int) = "__llvm_set_tail_call_kind"
pub fn llvm_set_tail_call_kind(call_inst: LLVMValueRef, kind: LLVMTailCallKind) -> Unit {
  __llvm_set_tail_call_kind(call_inst, kind.to_int())
}
pub fn LLVMValueRef::set_tail_call_kind(self: LLVMValueRef, kind: LLVMTailCallKind) -> Unit {
  __llvm_set_tail_call_kind(self, kind.to_int())
}

pub extern "C" fn llvm_get_normal_dest(invoke_inst: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_normal_dest"
pub fn LLVMValueRef::get_normal_dest(self: LLVMValueRef) -> LLVMBasicBlockRef {
  llvm_get_normal_dest(self)
}

pub extern "C" fn llvm_get_unwind_dest(invoke_inst: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_unwind_dest"
pub fn LLVMValueRef::get_unwind_dest(self: LLVMValueRef) -> LLVMBasicBlockRef {
  llvm_get_unwind_dest(self)
}

pub extern "C" fn llvm_set_normal_dest(invoke_inst: LLVMValueRef, b: LLVMBasicBlockRef) = "__llvm_set_normal_dest"
pub fn LLVMValueRef::set_normal_dest(self: LLVMValueRef, b: LLVMBasicBlockRef) -> Unit {
  llvm_set_normal_dest(self, b)
}

pub extern "C" fn llvm_set_unwind_dest(invoke_inst: LLVMValueRef, b: LLVMBasicBlockRef) = "__llvm_set_unwind_dest"
pub fn LLVMValueRef::set_unwind_dest(self: LLVMValueRef, b: LLVMBasicBlockRef) -> Unit {
  llvm_set_unwind_dest(self, b)
}

pub extern "C" fn llvm_get_call_br_default_dest(call_br: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_call_br_default_dest"
pub fn LLVMValueRef::get_call_br_default_dest(self: LLVMValueRef) -> LLVMBasicBlockRef {
  llvm_get_call_br_default_dest(self)
}

pub extern "C" fn llvm_get_call_br_num_indirect_dests(call_br: LLVMValueRef) -> UInt = "__llvm_get_call_br_num_indirect_dests"
pub fn LLVMValueRef::get_call_br_num_indirect_dests(self: LLVMValueRef) -> UInt {
  llvm_get_call_br_num_indirect_dests(self)
}

pub extern "C" fn llvm_get_call_br_indirect_dest(call_br: LLVMValueRef, idx: UInt) -> LLVMBasicBlockRef = "__llvm_get_call_br_indirect_dest"
pub fn LLVMValueRef::get_call_br_indirect_dest(self: LLVMValueRef, idx: UInt) -> LLVMBasicBlockRef {
  llvm_get_call_br_indirect_dest(self, idx)
}

pub extern "C" fn llvm_get_num_successors(term: LLVMValueRef) -> UInt = "__llvm_get_num_successors"
pub fn LLVMValueRef::get_num_successors(self: LLVMValueRef) -> UInt {
  llvm_get_num_successors(self)
}

pub extern "C" fn llvm_get_successor(term: LLVMValueRef, i: UInt) -> LLVMBasicBlockRef = "__llvm_get_successor"
pub fn LLVMValueRef::get_successor(self: LLVMValueRef, i: UInt) -> LLVMBasicBlockRef {
  llvm_get_successor(self, i)
}

pub extern "C" fn llvm_set_successor(term: LLVMValueRef, i: UInt, block: LLVMBasicBlockRef) = "__llvm_set_successor"
pub fn LLVMValueRef::set_successor(self: LLVMValueRef, i: UInt, block: LLVMBasicBlockRef) -> Unit {
  llvm_set_successor(self, i, block)
}

pub extern "C" fn llvm_is_conditional(branch: LLVMValueRef) -> LLVMBool = "__llvm_is_conditional"
pub fn LLVMValueRef::is_conditional(self: LLVMValueRef) -> Bool {
  llvm_is_conditional(self).to_moonbit_bool()
}

pub extern "C" fn llvm_get_condition(branch: LLVMValueRef) -> LLVMValueRef = "__llvm_get_condition"
pub fn LLVMValueRef::get_condition(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_condition(self)
}

pub extern "C" fn llvm_set_condition(branch: LLVMValueRef, cond: LLVMValueRef) = "__llvm_set_condition"
pub fn LLVMValueRef::set_condition(self: LLVMValueRef, cond: LLVMValueRef) -> Unit {
  llvm_set_condition(self, cond)
}

pub extern "C" fn llvm_get_switch_default_dest(switch_instr: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_switch_default_dest"
pub fn LLVMValueRef::get_switch_default_dest(self: LLVMValueRef) -> LLVMBasicBlockRef {
  llvm_get_switch_default_dest(self)
}

pub extern "C" fn llvm_get_allocated_type(alloca: LLVMValueRef) -> LLVMTypeRef = "__llvm_get_allocated_type"
pub fn LLVMValueRef::get_allocated_type(self: LLVMValueRef) -> LLVMTypeRef {
  llvm_get_allocated_type(self)
}

extern "C" fn __llvm_is_in_bounds(gep: LLVMValueRef) -> LLVMBool = "__llvm_is_in_bounds"
pub fn llvm_is_in_bounds(gep: LLVMValueRef) -> Bool {
  __llvm_is_in_bounds(gep).to_moonbit_bool()
}

pub extern "C" fn llvm_set_is_in_bounds(gep: LLVMValueRef, in_bounds: LLVMBool) = "__llvm_set_is_in_bounds"
pub fn LLVMValueRef::set_is_in_bounds(self: LLVMValueRef, in_bounds: Bool) -> Unit {
  llvm_set_is_in_bounds(self, to_llvm_bool(in_bounds))
}

pub extern "C" fn llvm_get_gep_source_element_type(gep: LLVMValueRef) -> LLVMTypeRef = "__llvm_get_gep_source_element_type"
pub fn LLVMValueRef::get_gep_source_element_type(self: LLVMValueRef) -> LLVMTypeRef {
  llvm_get_gep_source_element_type(self)
}

pub extern "C" fn llvm_add_incoming(phi_node: LLVMValueRef, incoming_values: Array[LLVMValueRef], incoming_blocks: Array[LLVMBasicBlockRef], count: UInt) = "__llvm_add_incoming"

pub extern "C" fn llvm_count_incoming(phi_node: LLVMValueRef) -> UInt = "__llvm_count_incoming"
pub fn LLVMValueRef::count_incoming(self: LLVMValueRef) -> UInt {
  llvm_count_incoming(self)
}

pub extern "C" fn llvm_get_incoming_value(phi_node: LLVMValueRef, index: UInt) -> LLVMValueRef = "__llvm_get_incoming_value"
pub fn LLVMValueRef::get_incoming_value(self: LLVMValueRef, index: UInt) -> LLVMValueRef {
  llvm_get_incoming_value(self, index)
}

pub extern "C" fn llvm_get_incoming_block(phi_node: LLVMValueRef, index: UInt) -> LLVMBasicBlockRef = "__llvm_get_incoming_block"
pub fn LLVMValueRef::get_incoming_block(self: LLVMValueRef, index: UInt) -> LLVMBasicBlockRef {
  llvm_get_incoming_block(self, index)
}

pub extern "C" fn llvm_get_num_indices(inst: LLVMValueRef) -> UInt = "__llvm_get_num_indices"
pub fn LLVMValueRef::get_num_indices(self: LLVMValueRef) -> UInt {
  llvm_get_num_indices(self)
}

// FIXME: Not implemented
pub extern "C" fn llvm_get_indices(inst: LLVMValueRef) -> Array[UInt] = "__llvm_get_indices"
pub fn LLVMValueRef::get_indices(self: LLVMValueRef) -> Array[UInt] {
  llvm_get_indices(self)
}

pub extern "C" fn llvm_create_builder_in_context(context: LLVMContextRef) -> LLVMBuilderRef = "__llvm_create_builder_in_context"
pub fn LLVMContextRef::create_builder(self: LLVMContextRef) -> LLVMBuilderRef {
  llvm_create_builder_in_context(self)
}

pub extern "C" fn llvm_create_builder() -> LLVMBuilderRef = "__llvm_create_builder"
pub fn LLVMBuilderRef::create() -> LLVMBuilderRef {
  llvm_create_builder()
}

pub extern "C" fn llvm_position_builder(builder: LLVMBuilderRef, block: LLVMBasicBlockRef, instr: LLVMValueRef) = "__llvm_position_builder"
pub fn LLVMBuilderRef::position(self: LLVMBuilderRef, block: LLVMBasicBlockRef, instr: LLVMValueRef) -> Unit {
  llvm_position_builder(self, block, instr)
}

pub extern "C" fn llvm_position_builder_before_dbg_records(builder: LLVMBuilderRef, block: LLVMBasicBlockRef, inst: LLVMValueRef) = "__llvm_position_builder_before_dbg_records"
pub fn LLVMBuilderRef::position_before_dbg_records(self: LLVMBuilderRef, block: LLVMBasicBlockRef, inst: LLVMValueRef) -> Unit {
  llvm_position_builder_before_dbg_records(self, block, inst)
}

pub extern "C" fn llvm_position_builder_before(builder: LLVMBuilderRef, instr: LLVMValueRef) = "__llvm_position_builder_before"
pub fn LLVMBuilderRef::position_before(self: LLVMBuilderRef, instr: LLVMValueRef) -> Unit {
  llvm_position_builder_before(self, instr)
}

pub extern "C" fn llvm_position_builder_before_instr_and_dbg_records(builder: LLVMBuilderRef, instr: LLVMValueRef) = "__llvm_position_builder_before_instr_and_dbg_records"
pub fn LLVMBuilderRef::position_before_instr_and_dbg_records(self: LLVMBuilderRef, instr: LLVMValueRef) -> Unit {
  llvm_position_builder_before_instr_and_dbg_records(self, instr)
}

pub extern "C" fn llvm_position_builder_at_end(builder: LLVMBuilderRef, block: LLVMBasicBlockRef) = "__llvm_position_builder_at_end"
pub fn LLVMBuilderRef::position_at_end(self: LLVMBuilderRef, block: LLVMBasicBlockRef) -> Unit {
  llvm_position_builder_at_end(self, block)
}

pub extern "C" fn llvm_get_insert_block(builder: LLVMBuilderRef) -> LLVMBasicBlockRef = "__llvm_get_insert_block"
pub fn LLVMBuilderRef::get_insert_block(self: LLVMBuilderRef) -> LLVMBasicBlockRef {
  llvm_get_insert_block(self)
}

pub extern "C" fn llvm_clear_insertion_position(builder: LLVMBuilderRef) = "__llvm_clear_insertion_position"
pub fn LLVMBuilderRef::clear_insertion_position(self: LLVMBuilderRef) -> Unit {
  llvm_clear_insertion_position(self)
}

pub extern "C" fn llvm_insert_into_builder(builder: LLVMBuilderRef, instr: LLVMValueRef) = "__llvm_insert_into_builder"
pub fn LLVMBuilderRef::insert(self: LLVMBuilderRef, instr: LLVMValueRef) -> Unit {
  llvm_insert_into_builder(self, instr)
}

extern "C" fn __llvm_insert_into_builder_with_name(builder: LLVMBuilderRef, instr: LLVMValueRef, name: CStr) = "__llvm_insert_into_builder_with_name"
pub fn llvm_insert_into_builder_with_name(builder: LLVMBuilderRef, instr: LLVMValueRef, name: String) -> Unit {
  __llvm_insert_into_builder_with_name(builder, instr, moonbit_str_to_c_str(name))
}


pub extern "C" fn llvm_dispose_builder(builder: LLVMBuilderRef) = "__llvm_dispose_builder"
pub fn LLVMBuilderRef::dispose(self: LLVMBuilderRef) -> Unit {
  llvm_dispose_builder(self)
}

pub extern "C" fn llvm_get_current_debug_location2(builder: LLVMBuilderRef) -> LLVMMetadataRef = "__llvm_get_current_debug_location2"
pub fn LLVMBuilderRef::get_current_debug_location2(self: LLVMBuilderRef) -> LLVMMetadataRef {
  llvm_get_current_debug_location2(self)
}

pub extern "C" fn llvm_set_current_debug_location2(builder: LLVMBuilderRef, loc: LLVMMetadataRef) = "__llvm_set_current_debug_location2"
pub fn LLVMBuilderRef::set_current_debug_location2(self: LLVMBuilderRef, loc: LLVMMetadataRef) -> Unit {
  llvm_set_current_debug_location2(self, loc)
}

pub extern "C" fn llvm_set_inst_debug_location(builder: LLVMBuilderRef, inst: LLVMValueRef) = "__llvm_set_inst_debug_location"
pub fn LLVMBuilderRef::set_inst_debug_location(self: LLVMBuilderRef, inst: LLVMValueRef) -> Unit {
  llvm_set_inst_debug_location(self, inst)
}

pub extern "C" fn llvm_add_metadata_to_inst(builder: LLVMBuilderRef, inst: LLVMValueRef) = "__llvm_add_metadata_to_inst"
pub fn LLVMBuilderRef::add_metadata_to_inst(self: LLVMBuilderRef, inst: LLVMValueRef) -> Unit {
  llvm_add_metadata_to_inst(self, inst)
}

pub extern "C" fn llvm_builder_get_default_fp_math_tag(builder: LLVMBuilderRef) -> LLVMMetadataRef = "__llvm_builder_get_default_fp_math_tag"
pub fn LLVMBuilderRef::get_default_fp_math_tag(self: LLVMBuilderRef) -> LLVMMetadataRef {
  llvm_builder_get_default_fp_math_tag(self)
}

pub extern "C" fn llvm_builder_set_default_fp_math_tag(builder: LLVMBuilderRef, fp_math_tag: LLVMMetadataRef) = "__llvm_builder_set_default_fp_math_tag"
pub fn LLVMBuilderRef::set_default_fp_math_tag(self: LLVMBuilderRef, fp_math_tag: LLVMMetadataRef) -> Unit {
  llvm_builder_set_default_fp_math_tag(self, fp_math_tag)
}

pub extern "C" fn llvm_set_current_debug_location(builder: LLVMBuilderRef, l: LLVMValueRef) = "__llvm_set_current_debug_location"
pub fn LLVMBuilderRef::set_current_debug_location(self: LLVMBuilderRef, l: LLVMValueRef) -> Unit {
  llvm_set_current_debug_location(self, l)
}

pub extern "C" fn llvm_get_current_debug_location(builder: LLVMBuilderRef) -> LLVMValueRef = "__llvm_get_current_debug_location"
pub fn LLVMBuilderRef::get_current_debug_location(self: LLVMBuilderRef) -> LLVMValueRef {
  llvm_get_current_debug_location(self)
}

pub extern "C" fn llvm_build_ret_void(builder: LLVMBuilderRef) -> LLVMValueRef = "__llvm_build_ret_void"
pub fn LLVMBuilderRef::build_ret_void(self: LLVMBuilderRef) -> LLVMValueRef {
  llvm_build_ret_void(self)
}

pub extern "C" fn llvm_build_ret(builder: LLVMBuilderRef, v: LLVMValueRef) -> LLVMValueRef = "__llvm_build_ret"
pub fn LLVMBuilderRef::build_ret(self: LLVMBuilderRef, v: LLVMValueRef) -> LLVMValueRef {
  llvm_build_ret(self, v)
}

pub extern "C" fn llvm_build_aggregate_ret(builder: LLVMBuilderRef, ret_vals: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_build_aggregate_ret"
pub fn LLVMBuilderRef::build_aggregate_ret(self: LLVMBuilderRef, ret_vals: Array[LLVMValueRef]) -> LLVMValueRef {
  llvm_build_aggregate_ret(self, ret_vals)
}

pub extern "C" fn llvm_build_br(builder: LLVMBuilderRef, dest: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_build_br"
pub fn LLVMBuilderRef::build_br(self: LLVMBuilderRef, dest: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_build_br(self, dest)
}

pub extern "C" fn llvm_build_cond_br(builder: LLVMBuilderRef, if_block: LLVMValueRef, then: LLVMBasicBlockRef, else_block: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_build_cond_br"
pub fn LLVMBuilderRef::build_cond_br(self: LLVMBuilderRef, if_block: LLVMValueRef, then: LLVMBasicBlockRef, else_block: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_build_cond_br(self, if_block, then, else_block)
}

pub extern "C" fn llvm_build_switch(builder: LLVMBuilderRef, v: LLVMValueRef, else_block: LLVMBasicBlockRef, num_cases: UInt) -> LLVMValueRef = "__llvm_build_switch"
pub fn LLVMBuilderRef::build_switch(self: LLVMBuilderRef, v: LLVMValueRef, else_block: LLVMBasicBlockRef, num_cases: UInt) -> LLVMValueRef {
  llvm_build_switch(self, v, else_block, num_cases)
}

pub extern "C" fn llvm_build_indirect_br(builder: LLVMBuilderRef, addr: LLVMValueRef, num_dests: UInt) -> LLVMValueRef = "__llvm_build_indirect_br"
pub fn LLVMBuilderRef::build_indirect_br(self: LLVMBuilderRef, addr: LLVMValueRef, num_dests: UInt) -> LLVMValueRef {
  llvm_build_indirect_br(self, addr, num_dests)
}

extern "C" fn __llvm_build_call_br(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, default_dest: LLVMBasicBlockRef, indirect_dests: Array[LLVMBasicBlockRef], args: Array[LLVMValueRef], bundles: Array[LLVMOperandBundleRef], name: CStr) -> LLVMValueRef = "__llvm_build_call_br"
pub fn llvm_build_call_br(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, default_dest: LLVMBasicBlockRef, indirect_dests: Array[LLVMBasicBlockRef], args: Array[LLVMValueRef], bundles: Array[LLVMOperandBundleRef], name: String) -> LLVMValueRef {
  __llvm_build_call_br(builder, ty, func, default_dest, indirect_dests, args, bundles, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_call_br(self: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, default_dest: LLVMBasicBlockRef, indirect_dests: Array[LLVMBasicBlockRef], args: Array[LLVMValueRef], bundles: Array[LLVMOperandBundleRef], name: String) -> LLVMValueRef {
  llvm_build_call_br(self, ty, func, default_dest, indirect_dests, args, bundles, name)
}


extern "C" fn __llvm_build_invoke2(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], then: LLVMBasicBlockRef, catch_block: LLVMBasicBlockRef, name: CStr) -> LLVMValueRef = "__llvm_build_invoke2"
pub fn llvm_build_invoke2(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], then: LLVMBasicBlockRef, catch_block: LLVMBasicBlockRef, name: String) -> LLVMValueRef {
  __llvm_build_invoke2(builder, ty, func, args, then, catch_block, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_invoke2(self: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], then: LLVMBasicBlockRef, catch_block: LLVMBasicBlockRef, name: String) -> LLVMValueRef {
  llvm_build_invoke2(self, ty, func, args, then, catch_block, name)
}

extern "C" fn __llvm_build_invoke_with_operand_bundles(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], then: LLVMBasicBlockRef, catch_block: LLVMBasicBlockRef, bundles: Array[LLVMOperandBundleRef], name: CStr) -> LLVMValueRef = "__llvm_build_invoke_with_operand_bundles"
pub fn llvm_build_invoke_with_operand_bundles(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], then: LLVMBasicBlockRef, catch_block: LLVMBasicBlockRef, bundles: Array[LLVMOperandBundleRef], name: String) -> LLVMValueRef {
  __llvm_build_invoke_with_operand_bundles(builder, ty, func, args, then, catch_block, bundles, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_invoke_with_operand_bundles(self: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], then: LLVMBasicBlockRef, catch_block: LLVMBasicBlockRef, bundles: Array[LLVMOperandBundleRef], name: String) -> LLVMValueRef {
  llvm_build_invoke_with_operand_bundles(self, ty, func, args, then, catch_block, bundles, name)
}

pub extern "C" fn llvm_build_unreachable(builder: LLVMBuilderRef) -> LLVMValueRef = "__llvm_build_unreachable"
pub fn LLVMBuilderRef::build_unreachable(self: LLVMBuilderRef) -> LLVMValueRef {
  llvm_build_unreachable(self)
}

pub extern "C" fn llvm_build_resume(builder: LLVMBuilderRef, exn: LLVMValueRef) -> LLVMValueRef = "__llvm_build_resume"
pub fn LLVMBuilderRef::build_resume(self: LLVMBuilderRef, exn: LLVMValueRef) -> LLVMValueRef {
  llvm_build_resume(self, exn)
}

extern "C" fn __llvm_build_landing_pad(builder: LLVMBuilderRef, ty: LLVMTypeRef, pers_fn: LLVMValueRef, num_clauses: UInt, name: CStr) -> LLVMValueRef = "__llvm_build_landing_pad"
pub fn llvm_build_landing_pad(builder: LLVMBuilderRef, ty: LLVMTypeRef, pers_fn: LLVMValueRef, num_clauses: UInt, name: String) -> LLVMValueRef {
  __llvm_build_landing_pad(builder, ty, pers_fn, num_clauses, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_landing_pad(self: LLVMBuilderRef, ty: LLVMTypeRef, pers_fn: LLVMValueRef, num_clauses: UInt, name: String) -> LLVMValueRef {
  llvm_build_landing_pad(self, ty, pers_fn, num_clauses, name)
}

pub extern "C" fn llvm_build_cleanup_ret(builder: LLVMBuilderRef, catch_pad: LLVMValueRef, bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_build_cleanup_ret"
pub fn LLVMBuilderRef::build_cleanup_ret(self: LLVMBuilderRef, catch_pad: LLVMValueRef, bb: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_build_cleanup_ret(self, catch_pad, bb)
}

pub extern "C" fn llvm_build_catch_ret(builder: LLVMBuilderRef, catch_pad: LLVMValueRef, bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_build_catch_ret"
pub fn LLVMBuilderRef::build_catch_ret(self: LLVMBuilderRef, catch_pad: LLVMValueRef, bb: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_build_catch_ret(self, catch_pad, bb)
}

extern "C" fn __llvm_build_catch_pad(builder: LLVMBuilderRef, parent_pad: LLVMValueRef, args: Array[LLVMValueRef], name: CStr) -> LLVMValueRef = "__llvm_build_catch_pad"
pub fn llvm_build_catch_pad(builder: LLVMBuilderRef, parent_pad: LLVMValueRef, args: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  __llvm_build_catch_pad(builder, parent_pad, args, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_catch_pad(self: LLVMBuilderRef, parent_pad: LLVMValueRef, args: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  llvm_build_catch_pad(self, parent_pad, args, name)
}

extern "C" fn __llvm_build_cleanup_pad(builder: LLVMBuilderRef, parent_pad: LLVMValueRef, args: Array[LLVMValueRef], name: CStr) -> LLVMValueRef = "__llvm_build_cleanup_pad"
pub fn llvm_build_cleanup_pad(builder: LLVMBuilderRef, parent_pad: LLVMValueRef, args: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  __llvm_build_cleanup_pad(builder, parent_pad, args, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_cleanup_pad(self: LLVMBuilderRef, parent_pad: LLVMValueRef, args: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  llvm_build_cleanup_pad(self, parent_pad, args, name)
}

extern "C" fn __llvm_build_catch_switch(builder: LLVMBuilderRef, parent_pad: LLVMValueRef, unwind_bb: LLVMBasicBlockRef, num_handlers: UInt, name: CStr) -> LLVMValueRef = "__llvm_build_catch_switch"
pub fn llvm_build_catch_switch(builder: LLVMBuilderRef, parent_pad: LLVMValueRef, unwind_bb: LLVMBasicBlockRef, num_handlers: UInt, name: String) -> LLVMValueRef {
  __llvm_build_catch_switch(builder, parent_pad, unwind_bb, num_handlers, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_catch_switch(self: LLVMBuilderRef, parent_pad: LLVMValueRef, unwind_bb: LLVMBasicBlockRef, num_handlers: UInt, name: String) -> LLVMValueRef {
  llvm_build_catch_switch(self, parent_pad, unwind_bb, num_handlers, name)
}

pub extern "C" fn llvm_add_case(_switch: LLVMValueRef, on_val: LLVMValueRef, dest: LLVMBasicBlockRef) = "__llvm_add_case"
pub fn LLVMValueRef::add_case(self: LLVMValueRef, on_val: LLVMValueRef, dest: LLVMBasicBlockRef) -> Unit {
  llvm_add_case(self, on_val, dest)
}

pub extern "C" fn llvm_add_destination(indirect_br: LLVMValueRef, dest: LLVMBasicBlockRef) = "__llvm_add_destination"
pub fn LLVMValueRef::add_destination(self: LLVMValueRef, dest: LLVMBasicBlockRef) -> Unit {
  llvm_add_destination(self, dest)
}

pub extern "C" fn llvm_get_num_clauses(landing_pad: LLVMValueRef) -> UInt = "__llvm_get_num_clauses"
pub fn LLVMValueRef::get_num_clauses(self: LLVMValueRef) -> UInt {
  llvm_get_num_clauses(self)
}

pub extern "C" fn llvm_get_clause(landing_pad: LLVMValueRef, idx: UInt) -> LLVMValueRef = "__llvm_get_clause"
pub fn LLVMValueRef::get_clause(self: LLVMValueRef, idx: UInt) -> LLVMValueRef {
  llvm_get_clause(self, idx)
}

pub extern "C" fn llvm_add_clause(landing_pad: LLVMValueRef, clause_val: LLVMValueRef) = "__llvm_add_clause"
pub fn LLVMValueRef::add_clause(self: LLVMValueRef, clause_val: LLVMValueRef) -> Unit {
  llvm_add_clause(self, clause_val)
}

extern "C" fn __llvm_is_cleanup(landing_pad: LLVMValueRef) -> LLVMBool = "__llvm_is_cleanup"

extern "C" fn __llvm_set_cleanup(landing_pad: LLVMValueRef, val: LLVMBool) = "__llvm_set_cleanup"

pub extern "C" fn llvm_add_handler(catch_switch: LLVMValueRef, dest: LLVMBasicBlockRef) = "__llvm_add_handler"

pub extern "C" fn llvm_get_num_handlers(catch_switch: LLVMValueRef) -> UInt = "__llvm_get_num_handlers"

pub extern "C" fn llvm_get_handlers(catch_switch: LLVMValueRef) -> Array[LLVMBasicBlockRef] = "__llvm_get_handlers"

pub extern "C" fn llvm_get_arg_operand(funclet: LLVMValueRef, i: UInt) -> LLVMValueRef = "__llvm_get_arg_operand"

pub extern "C" fn llvm_set_arg_operand(funclet: LLVMValueRef, i: UInt, value: LLVMValueRef) = "__llvm_set_arg_operand"

pub extern "C" fn llvm_get_parent_catch_switch(catch_pad: LLVMValueRef) -> LLVMValueRef = "__llvm_get_parent_catch_switch"

pub extern "C" fn llvm_set_parent_catch_switch(catch_pad: LLVMValueRef, catch_switch: LLVMValueRef) = "__llvm_set_parent_catch_switch"

extern "C" fn __llvm_build_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_add"
pub fn llvm_build_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_add(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_nsw_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nsw_add"
pub fn llvm_build_nsw_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_nsw_add(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_nuw_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nuw_add"
pub fn llvm_build_nuw_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_nuw_add(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_f_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_add"
pub fn llvm_build_f_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_f_add(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_sub"
pub fn llvm_build_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_sub(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_nsw_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nsw_sub"
pub fn llvm_build_nsw_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_nsw_sub(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_nuw_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nuw_sub"
pub fn llvm_build_nuw_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_nuw_sub(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_f_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_sub"
pub fn llvm_build_f_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_f_sub(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_mul"
pub fn llvm_build_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_mul(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_nsw_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nsw_mul"
pub fn llvm_build_nsw_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_nsw_mul(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_nuw_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nuw_mul"
pub fn llvm_build_nuw_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_nuw_mul(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_f_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_mul"
pub fn llvm_build_f_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_f_mul(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_u_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_u_div"
pub fn llvm_build_u_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_u_div(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_exact_u_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_exact_u_div"
pub fn llvm_build_exact_u_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_exact_u_div(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_s_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_s_div"
pub fn llvm_build_s_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_s_div(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_exact_s_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_exact_s_div"
pub fn llvm_build_exact_s_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_exact_s_div(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_f_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_div"
pub fn llvm_build_f_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_f_div(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_u_rem(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_u_rem"
pub fn llvm_build_u_rem(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_u_rem(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_s_rem(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_s_rem"
pub fn llvm_build_s_rem(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_s_rem(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_f_rem(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_rem"
pub fn llvm_build_f_rem(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_f_rem(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_shl(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_shl"
pub fn llvm_build_shl(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_shl(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_l_shr(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_l_shr"
pub fn llvm_build_l_shr(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_l_shr(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_a_shr(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_a_shr"
pub fn llvm_build_a_shr(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_a_shr(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_and(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_and"
pub fn llvm_build_and(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_and(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_or(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_or"
pub fn llvm_build_or(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_or(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_xor(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_xor"
pub fn llvm_build_xor(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_xor(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_bin_op(builder: LLVMBuilderRef, op: Int, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_bin_op"
pub fn llvm_build_bin_op(builder: LLVMBuilderRef, op: LLVMOpcode, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  let code = op.to_int()
  let name = moonbit_str_to_c_str(name)
  __llvm_build_bin_op(builder, code, lhs, rhs, name)
}

extern "C" fn llvm_build_neg(builder: LLVMBuilderRef, v: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_neg"
pub fn LLVMBuilderRef::build_neg(self: LLVMBuilderRef, v: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_neg(self, v, moonbit_str_to_c_str(name))
}

extern "C" fn __llvm_build_nsw_neg(builder: LLVMBuilderRef, v: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nsw_neg"
pub fn llvm_build_nsw_neg(builder: LLVMBuilderRef, v: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_nsw_neg(builder, v, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_nsw_neg(self: LLVMBuilderRef, v: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_nsw_neg(self, v, name)
}

extern "C" fn __llvm_build_f_neg(builder: LLVMBuilderRef, v: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_neg"
pub fn llvm_build_f_neg(builder: LLVMBuilderRef, v: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_f_neg(builder, v, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_f_neg(self: LLVMBuilderRef, v: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_f_neg(self, v, name)
}

extern "C" fn __llvm_build_not(builder: LLVMBuilderRef, v: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_not"
pub fn llvm_build_not(builder: LLVMBuilderRef, v: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_not(builder, v, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_not(self: LLVMBuilderRef, v: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_not(self, v, name)
}

extern "C" fn __llvm_get_nuw(arith_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_nuw"
pub fn LLVMValueRef::get_nuw(self: LLVMValueRef) -> Bool {
  let has_nuw = __llvm_get_nuw(self);
  to_moonbit_bool(has_nuw)
}
pub fn llvm_get_nuw(arith_inst: LLVMValueRef) -> Bool {
  LLVMValueRef::get_nuw(arith_inst)
}

extern "C" fn __llvm_set_nuw(arith_inst: LLVMValueRef, has_nuw: LLVMBool) = "__llvm_set_nuw"
pub fn llvm_set_nuw(arith_inst: LLVMValueRef, has_nuw: Bool) -> Unit {
  __llvm_set_nuw(arith_inst, to_llvm_bool(has_nuw))
}
pub fn LLVMValueRef::set_nuw(self: LLVMValueRef, has_nuw: Bool) -> Unit {
  llvm_set_nuw(self, has_nuw)
}

extern "C" fn __llvm_get_nsw(arith_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_nsw"
pub fn LLVMValueRef::get_nsw(self: LLVMValueRef) -> Bool {
  let has_nsw = __llvm_get_nsw(self);
  to_moonbit_bool(has_nsw)
}
pub fn llvm_get_nsw(arith_inst: LLVMValueRef) -> Bool {
  LLVMValueRef::get_nsw(arith_inst)
}

extern "C" fn __llvm_set_nsw(arith_inst: LLVMValueRef, has_nsw: LLVMBool) = "__llvm_set_nsw"
pub fn llvm_set_nsw(arith_inst: LLVMValueRef, has_nsw: Bool) -> Unit {
  __llvm_set_nsw(arith_inst, to_llvm_bool(has_nsw))
}
pub fn LLVMValueRef::set_nsw(self: LLVMValueRef, has_nsw: Bool) -> Unit {
  llvm_set_nsw(self, has_nsw)
}

extern "C" fn __llvm_get_exact(div_or_shr_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_exact"
pub fn LLVMValueRef::get_exact(self: LLVMValueRef) -> Bool {
  let is_exact = __llvm_get_exact(self);
  to_moonbit_bool(is_exact)
}
pub fn llvm_get_exact(div_or_shr_inst: LLVMValueRef) -> Bool {
  LLVMValueRef::get_exact(div_or_shr_inst)
}

extern "C" fn __llvm_set_exact(div_or_shr_inst: LLVMValueRef, is_exact: LLVMBool) = "__llvm_set_exact"
pub fn llvm_set_exact(div_or_shr_inst: LLVMValueRef, is_exact: Bool) -> Unit {
  __llvm_set_exact(div_or_shr_inst, to_llvm_bool(is_exact))
}
pub fn LLVMValueRef::set_exact(self: LLVMValueRef, is_exact: Bool) -> Unit {
  llvm_set_exact(self, is_exact)
}

extern "C" fn __llvm_get_n_neg(non_neg_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_n_neg"
pub fn llvm_get_n_neg(non_neg_inst: LLVMValueRef) -> Bool {
  let is_non_neg = __llvm_get_n_neg(non_neg_inst);
  to_moonbit_bool(is_non_neg)
}
pub fn LLVMValueRef::get_n_neg(self: LLVMValueRef) -> Bool {
  let is_non_neg = __llvm_get_n_neg(self);
  to_moonbit_bool(is_non_neg)
}

extern "C" fn __llvm_set_n_neg(non_neg_inst: LLVMValueRef, is_non_neg: LLVMBool) = "__llvm_set_n_neg"
pub fn llvm_set_n_neg(non_neg_inst: LLVMValueRef, is_non_neg: Bool) -> Unit {
  __llvm_set_n_neg(non_neg_inst, to_llvm_bool(is_non_neg))
}
pub fn LLVMValueRef::set_n_neg(self: LLVMValueRef, is_non_neg: Bool) -> Unit {
  llvm_set_n_neg(self, is_non_neg)
}

extern "C" fn llvm_get_fast_math_flags(fp_math_inst: LLVMValueRef) -> LLVMFastMathFlags = "__llvm_get_fast_math_flags"
pub fn LLVMValueRef::get_fast_math_flags(self: LLVMValueRef) -> LLVMFastMathFlags {
  llvm_get_fast_math_flags(self)
}

extern "C" fn llvm_set_fast_math_flags(fp_math_inst: LLVMValueRef, fmf: LLVMFastMathFlags) = "__llvm_set_fast_math_flags"
pub fn LLVMValueRef::set_fast_math_flags(self: LLVMValueRef, fmf: LLVMFastMathFlags) -> Unit {
  llvm_set_fast_math_flags(self, fmf)
}

extern "C" fn __llvm_can_value_use_fast_math_flags(inst: LLVMValueRef) -> LLVMBool = "__llvm_can_value_use_fast_math_flags"
pub fn llvm_can_value_use_fast_math_flags(inst: LLVMValueRef) -> Bool {
  let can_use = __llvm_can_value_use_fast_math_flags(inst);
  to_moonbit_bool(can_use)
}
pub fn LLVMValueRef::can_use_fast_math_flags(self: LLVMValueRef) -> Bool {
  llvm_can_value_use_fast_math_flags(self)
}

extern "C" fn __llvm_get_is_disjoint(inst: LLVMValueRef) -> LLVMBool = "__llvm_get_is_disjoint"
pub fn LLVMValueRef::get_is_disjoint(self: LLVMValueRef) -> Bool {
  let is_disjoint = __llvm_get_is_disjoint(self);
  to_moonbit_bool(is_disjoint)
}

extern "C" fn __llvm_set_is_disjoint(inst: LLVMValueRef, is_disjoint: LLVMBool) = "__llvm_set_is_disjoint"
pub fn llvm_set_is_disjoint(inst: LLVMValueRef, is_disjoint: Bool) -> Unit {
  __llvm_set_is_disjoint(inst, to_llvm_bool(is_disjoint))
}
pub fn LLVMValueRef::set_is_disjoint(self: LLVMValueRef, is_disjoint: Bool) -> Unit {
  llvm_set_is_disjoint(self, is_disjoint)
}

extern "C" fn __llvm_build_malloc(builder: LLVMBuilderRef, ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_malloc"
pub fn llvm_build_malloc(builder: LLVMBuilderRef, ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_malloc(builder, ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_malloc(self: LLVMBuilderRef, ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_malloc(self, ty, name)
}

extern "C" fn __llvm_build_array_malloc(builder: LLVMBuilderRef, ty: LLVMTypeRef, val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_array_malloc"

pub extern "C" fn llvm_build_mem_set(builder: LLVMBuilderRef, ptr: LLVMValueRef, val: LLVMValueRef, len: LLVMValueRef, align: UInt) -> LLVMValueRef = "__llvm_build_mem_set"
pub fn LLVMBuilderRef::build_mem_set(self: LLVMBuilderRef, ptr: LLVMValueRef, val: LLVMValueRef, len: LLVMValueRef, align: UInt) -> LLVMValueRef {
  llvm_build_mem_set(self, ptr, val, len, align)
}

pub extern "C" fn llvm_build_mem_cpy(builder: LLVMBuilderRef, dst: LLVMValueRef, dst_align: UInt, src: LLVMValueRef, src_align: UInt, size: LLVMValueRef) -> LLVMValueRef = "__llvm_build_mem_cpy"
pub fn LLVMBuilderRef::build_mem_cpy(self: LLVMBuilderRef, dst: LLVMValueRef, dst_align: UInt, src: LLVMValueRef, src_align: UInt, size: LLVMValueRef) -> LLVMValueRef {
  llvm_build_mem_cpy(self, dst, dst_align, src, src_align, size)
}

pub extern "C" fn llvm_build_mem_move(builder: LLVMBuilderRef, dst: LLVMValueRef, dst_align: UInt, src: LLVMValueRef, src_align: UInt, size: LLVMValueRef) -> LLVMValueRef = "__llvm_build_mem_move"
pub fn LLVMBuilderRef::build_mem_move(self: LLVMBuilderRef, dst: LLVMValueRef, dst_align: UInt, src: LLVMValueRef, src_align: UInt, size: LLVMValueRef) -> LLVMValueRef {
  llvm_build_mem_move(self, dst, dst_align, src, src_align, size)
}

extern "C" fn __llvm_build_alloca(builder: LLVMBuilderRef, ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_alloca"
pub fn llvm_build_alloca(builder: LLVMBuilderRef, ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_alloca(builder, ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_alloca(self: LLVMBuilderRef, ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_alloca(self, ty, name)
}

extern "C" fn __llvm_build_array_alloca(builder: LLVMBuilderRef, ty: LLVMTypeRef, val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_array_alloca"
pub fn llvm_build_array_alloca(builder: LLVMBuilderRef, ty: LLVMTypeRef, val: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_array_alloca(builder, ty, val, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_array_alloca(self: LLVMBuilderRef, ty: LLVMTypeRef, val: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_array_alloca(self, ty, val, name)
}

pub extern "C" fn llvm_build_free(builder: LLVMBuilderRef, pointer_val: LLVMValueRef) -> LLVMValueRef = "__llvm_build_free"
pub fn LLVMBuilderRef::build_free(self: LLVMBuilderRef, pointer_val: LLVMValueRef) -> LLVMValueRef {
  llvm_build_free(self, pointer_val)
}

extern "C" fn __llvm_build_load2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer_val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_load2"
pub fn llvm_build_load2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer_val: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_load2(builder, ty, pointer_val, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_load2(self: LLVMBuilderRef, ty: LLVMTypeRef, pointer_val: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_load2(self, ty, pointer_val, name)
}

pub extern "C" fn llvm_build_store(builder: LLVMBuilderRef, val: LLVMValueRef, ptr: LLVMValueRef) -> LLVMValueRef = "__llvm_build_store"
pub fn LLVMBuilderRef::build_store(self: LLVMBuilderRef, val: LLVMValueRef, ptr: LLVMValueRef) -> LLVMValueRef {
  llvm_build_store(self, val, ptr)
}

extern "C" fn __llvm_build_gep2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, indices: Array[LLVMValueRef], name: CStr) -> LLVMValueRef = "__llvm_build_gep2"
pub fn llvm_build_gep2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, indices: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  __llvm_build_gep2(builder, ty, pointer, indices, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_gep2(self: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, indices: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  llvm_build_gep2(self, ty, pointer, indices, name)
}

extern "C" fn __llvm_build_in_bounds_gep2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, indices: Array[LLVMValueRef], name: CStr) -> LLVMValueRef = "__llvm_build_in_bounds_gep2"
pub fn llvm_build_in_bounds_gep2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, indices: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  __llvm_build_in_bounds_gep2(builder, ty, pointer, indices, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_in_bounds_gep2(self: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, indices: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  llvm_build_in_bounds_gep2(self, ty, pointer, indices, name)
}

extern "C" fn __llvm_build_struct_gep2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, idx: UInt, name: CStr) -> LLVMValueRef = "__llvm_build_struct_gep2"
pub fn llvm_build_struct_gep2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, idx: UInt, name: String) -> LLVMValueRef {
  __llvm_build_struct_gep2(builder, ty, pointer, idx, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_struct_gep2(self: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, idx: UInt, name: String) -> LLVMValueRef {
  llvm_build_struct_gep2(self, ty, pointer, idx, name)
}

extern "C" fn __llvm_build_global_string(builder: LLVMBuilderRef, str: CStr, name: CStr) -> LLVMValueRef = "__llvm_build_global_string"
pub fn llvm_build_global_string(builder: LLVMBuilderRef, str: String, name: String) -> LLVMValueRef {
  __llvm_build_global_string(builder, moonbit_str_to_c_str(str), moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_global_string(self: LLVMBuilderRef, str: String, name: String) -> LLVMValueRef {
  llvm_build_global_string(self, str, name)
}

extern "C" fn __llvm_build_global_string_ptr(builder: LLVMBuilderRef, str: CStr, name: CStr) -> LLVMValueRef = "__llvm_build_global_string_ptr"
pub fn llvm_build_global_string_ptr(builder: LLVMBuilderRef, str: String, name: String) -> LLVMValueRef {
  __llvm_build_global_string_ptr(builder, moonbit_str_to_c_str(str), moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_global_string_ptr(self: LLVMBuilderRef, str: String, name: String) -> LLVMValueRef {
  llvm_build_global_string_ptr(self, str, name)
}

extern "C" fn __llvm_get_volatile(memory_access_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_volatile"
pub fn llvm_get_volatile(memory_access_inst: LLVMValueRef) -> Bool {
  let is_volatile = __llvm_get_volatile(memory_access_inst);
  to_moonbit_bool(is_volatile)
}
pub fn LLVMValueRef::get_volatile(self: LLVMValueRef) -> Bool {
  llvm_get_volatile(self)
}

extern "C" fn __llvm_set_volatile(memory_access_inst: LLVMValueRef, is_volatile: LLVMBool) = "__llvm_set_volatile"
pub fn llvm_set_volatile(memory_access_inst: LLVMValueRef, is_volatile: Bool) -> Unit {
  __llvm_set_volatile(memory_access_inst, to_llvm_bool(is_volatile))
}
pub fn LLVMValueRef::set_volatile(self: LLVMValueRef, is_volatile: Bool) -> Unit {
  llvm_set_volatile(self, is_volatile)
}


extern "C" fn __llvm_get_weak(cmp_xchg_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_weak"
pub fn llvm_get_weak(cmp_xchg_inst: LLVMValueRef) -> Bool {
  let is_weak = __llvm_get_weak(cmp_xchg_inst);
  to_moonbit_bool(is_weak)
}
pub fn LLVMValueRef::get_weak(self: LLVMValueRef) -> Bool {
  llvm_get_weak(self)
}

extern "C" fn __llvm_set_weak(cmp_xchg_inst: LLVMValueRef, is_weak: LLVMBool) = "__llvm_set_weak"
pub fn llvm_set_weak(cmp_xchg_inst: LLVMValueRef, is_weak: Bool) -> Unit {
  __llvm_set_weak(cmp_xchg_inst, to_llvm_bool(is_weak))
}
pub fn LLVMValueRef::set_weak(self: LLVMValueRef, is_weak: Bool) -> Unit {
  llvm_set_weak(self, is_weak)
}

extern "C" fn __llvm_get_ordering(memory_access_inst: LLVMValueRef) -> Int = "__llvm_get_ordering"
pub fn llvm_get_ordering(memory_access_inst: LLVMValueRef) -> LLVMAtomicOrdering {
  LLVMAtomicOrdering::from_int(__llvm_get_ordering(memory_access_inst))
}

extern "C" fn __llvm_set_ordering(memory_access_inst: LLVMValueRef, ordering: Int) = "__llvm_set_ordering"
pub fn llvm_set_ordering(memory_access_inst: LLVMValueRef, ordering: LLVMAtomicOrdering) -> Unit {
  __llvm_set_ordering(memory_access_inst, ordering.to_int())
}
pub fn LLVMValueRef::set_ordering(self: LLVMValueRef, ordering: LLVMAtomicOrdering) -> Unit {
  llvm_set_ordering(self, ordering)
}

extern "C" fn __llvm_get_atomic_rmw_bin_op(atomic_rmw_inst: LLVMValueRef) -> Int = "__llvm_get_atomic_rmw_bin_op"
pub fn llvm_get_atomic_rmw_bin_op(atomic_rmw_inst: LLVMValueRef) -> LLVMAtomicRMWBinOp {
  LLVMAtomicRMWBinOp::from_int(__llvm_get_atomic_rmw_bin_op(atomic_rmw_inst))
}
pub fn LLVMValueRef::get_atomic_rmw_bin_op(self: LLVMValueRef) -> LLVMAtomicRMWBinOp {
  llvm_get_atomic_rmw_bin_op(self)
}

extern "C" fn __llvm_set_atomic_rmw_bin_op(atomic_rmw_inst: LLVMValueRef, bin_op: Int) = "__llvm_set_atomic_rmw_bin_op"
pub fn llvm_set_atomic_rmw_bin_op(atomic_rmw_inst: LLVMValueRef, bin_op: LLVMAtomicRMWBinOp) -> Unit {
  __llvm_set_atomic_rmw_bin_op(atomic_rmw_inst, bin_op.to_int())
}
pub fn LLVMValueRef::set_atomic_rmw_bin_op(self: LLVMValueRef, bin_op: LLVMAtomicRMWBinOp) -> Unit {
  llvm_set_atomic_rmw_bin_op(self, bin_op)
}

extern "C" fn __llvm_build_trunc(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_trunc"
pub fn llvm_build_trunc(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_trunc(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_trunc(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_trunc(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_z_ext(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_z_ext"
pub fn llvm_build_z_ext(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_z_ext(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_z_ext(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_z_ext(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_s_ext(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_s_ext"
pub fn llvm_build_s_ext(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_s_ext(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_s_ext(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_s_ext(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_fp_to_ui(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_fp_to_ui"
pub fn llvm_build_fp_to_ui(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_fp_to_ui(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_fp_to_ui(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_fp_to_ui(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_fp_to_si(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_fp_to_si"
pub fn llvm_build_fp_to_si(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_fp_to_si(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_fp_to_si(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_fp_to_si(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_ui_to_fp(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_ui_to_fp"
pub fn llvm_build_ui_to_fp(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_ui_to_fp(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_ui_to_fp(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_ui_to_fp(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_si_to_fp(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_si_to_fp"
pub fn llvm_build_si_to_fp(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_si_to_fp(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_si_to_fp(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_si_to_fp(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_fp_trunc(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_fp_trunc"
pub fn llvm_build_fp_trunc(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_fp_trunc(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_fp_trunc(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_fp_trunc(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_fp_ext(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_fp_ext"
pub fn llvm_build_fp_ext(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_fp_ext(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_fp_ext(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_fp_ext(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_ptr_to_int(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_ptr_to_int"
pub fn llvm_build_ptr_to_int(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_ptr_to_int(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_ptr_to_int(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_ptr_to_int(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_int_to_ptr(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_int_to_ptr"
pub fn llvm_build_int_to_ptr(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_int_to_ptr(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_int_to_ptr(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_int_to_ptr(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_bit_cast"
pub fn llvm_build_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_bit_cast(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_bit_cast(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_bit_cast(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_addr_space_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_addr_space_cast"
pub fn llvm_build_addr_space_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_addr_space_cast(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_addr_space_cast(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_addr_space_cast(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_z_ext_or_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_z_ext_or_bit_cast"
pub fn llvm_build_z_ext_or_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_z_ext_or_bit_cast(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_z_ext_or_bit_cast(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_z_ext_or_bit_cast(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_s_ext_or_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_s_ext_or_bit_cast"
pub fn llvm_build_s_ext_or_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_s_ext_or_bit_cast(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_s_ext_or_bit_cast(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_s_ext_or_bit_cast(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_trunc_or_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_trunc_or_bit_cast"
pub fn llvm_build_trunc_or_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_trunc_or_bit_cast(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_trunc_or_bit_cast(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_trunc_or_bit_cast(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_cast(builder: LLVMBuilderRef, op: Int, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_cast"
pub fn llvm_build_cast(builder: LLVMBuilderRef, op: LLVMOpcode, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  let code = op.to_int()
  let name = moonbit_str_to_c_str(name)
  __llvm_build_cast(builder, code, val, dest_ty, name)
}
pub fn LLVMBuilderRef::build_cast(self: LLVMBuilderRef, op: LLVMOpcode, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_cast(self, op, val, dest_ty, name)
}

extern "C" fn __llvm_build_pointer_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_pointer_cast"
pub fn llvm_build_pointer_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_pointer_cast(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_pointer_cast(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_pointer_cast(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_int_cast2(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, is_signed: LLVMBool, name: CStr) -> LLVMValueRef = "__llvm_build_int_cast2"
pub fn llvm_build_int_cast2(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, is_signed: Bool, name: String) -> LLVMValueRef {
  __llvm_build_int_cast2(builder, val, dest_ty, to_llvm_bool(is_signed), moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_int_cast2(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, is_signed: Bool, name: String) -> LLVMValueRef {
  llvm_build_int_cast2(self, val, dest_ty, is_signed, name)
}

extern "C" fn __llvm_build_fp_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_fp_cast"
pub fn llvm_build_fp_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_fp_cast(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_fp_cast(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_fp_cast(self, val, dest_ty, name)
}

extern "C" fn __llvm_build_int_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_int_cast"
pub fn llvm_build_int_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_int_cast(builder, val, dest_ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_int_cast(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_int_cast(self, val, dest_ty, name)
}

extern "C" fn __llvm_get_cast_opcode(src: LLVMValueRef, src_is_signed: LLVMBool, dest_ty: LLVMTypeRef, dest_is_signed: LLVMBool) -> Int = "__llvm_get_cast_opcode"
pub fn llvm_get_cast_opcode(src: LLVMValueRef, src_is_signed: Bool, dest_ty: LLVMTypeRef, dest_is_signed: Bool) -> LLVMOpcode {
  let src_is_signed = to_llvm_bool(src_is_signed)
  let dest_is_signed = to_llvm_bool(dest_is_signed)
  let code = __llvm_get_cast_opcode(src, src_is_signed, dest_ty, dest_is_signed)
  LLVMOpcode::from_int(code)
}
pub fn LLVMValueRef::get_cast_opcode(self: LLVMValueRef, src_is_signed: Bool, dest_ty: LLVMTypeRef, dest_is_signed: Bool) -> LLVMOpcode {
  llvm_get_cast_opcode(self, src_is_signed, dest_ty, dest_is_signed)
}

extern "C" fn __llvm_build_icmp(builder: LLVMBuilderRef, op: Int, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_icmp"
pub fn llvm_build_icmp(builder: LLVMBuilderRef, op: LLVMIntPredicate, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  let code = op.to_int()
  let name = moonbit_str_to_c_str(name)
  __llvm_build_icmp(builder, code, lhs, rhs, name)
}
pub fn LLVMBuilderRef::build_icmp(self: LLVMBuilderRef, op: LLVMIntPredicate, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_icmp(self, op, lhs, rhs, name)
}


extern "C" fn __llvm_build_fcmp(builder: LLVMBuilderRef, op: Int, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_fcmp"
pub fn llvm_build_fcmp(builder: LLVMBuilderRef, op: LLVMRealPredicate, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  let code = op.to_int()
  let name = moonbit_str_to_c_str(name)
  __llvm_build_fcmp(builder, code, lhs, rhs, name)
}
pub fn LLVMBuilderRef::build_fcmp(self: LLVMBuilderRef, op: LLVMRealPredicate, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_fcmp(self, op, lhs, rhs, name)
}

extern "C" fn __llvm_build_phi(builder: LLVMBuilderRef, ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_phi"
pub fn llvm_build_phi(builder: LLVMBuilderRef, ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_phi(builder, ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_phi(self: LLVMBuilderRef, ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_phi(self, ty, name)
}

extern "C" fn __llvm_build_call2(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], name: CStr) -> LLVMValueRef = "__llvm_build_call2"
pub fn llvm_build_call2(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  __llvm_build_call2(builder, ty, func, args, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_call2(self: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  llvm_build_call2(self, ty, func, args, name)
}

extern "C" fn __llvm_build_call_with_operand_bundles(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], bundles: Array[LLVMOperandBundleRef], name: CStr) -> LLVMValueRef = "__llvm_build_call_with_operand_bundles"
pub fn llvm_build_call_with_operand_bundles(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], bundles: Array[LLVMOperandBundleRef], name: String) -> LLVMValueRef {
  __llvm_build_call_with_operand_bundles(builder, ty, func, args, bundles, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_call_with_operand_bundles(self: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], bundles: Array[LLVMOperandBundleRef], name: String) -> LLVMValueRef {
  llvm_build_call_with_operand_bundles(self, ty, func, args, bundles, name)
}

extern "C" fn __llvm_build_select(builder: LLVMBuilderRef, if_block: LLVMValueRef, then: LLVMValueRef, else_block: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_select"
pub fn llvm_build_select(builder: LLVMBuilderRef, if_block: LLVMValueRef, then: LLVMValueRef, else_block: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_select(builder, if_block, then, else_block, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_select(self: LLVMBuilderRef, if_block: LLVMValueRef, then: LLVMValueRef, else_block: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_select(self, if_block, then, else_block, name)
}

extern "C" fn __llvm_build_va_arg(builder: LLVMBuilderRef, list: LLVMValueRef, ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_va_arg"
pub fn llvm_build_va_arg(builder: LLVMBuilderRef, list: LLVMValueRef, ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_va_arg(builder, list, ty, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_va_arg(self: LLVMBuilderRef, list: LLVMValueRef, ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_va_arg(self, list, ty, name)
}

extern "C" fn __llvm_build_extract_element(builder: LLVMBuilderRef, vec_val: LLVMValueRef, index: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_extract_element"
pub fn llvm_build_extract_element(builder: LLVMBuilderRef, vec_val: LLVMValueRef, index: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_extract_element(builder, vec_val, index, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_extract_element(self: LLVMBuilderRef, vec_val: LLVMValueRef, index: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_extract_element(self, vec_val, index, name)
}

extern "C" fn __llvm_build_insert_element(builder: LLVMBuilderRef, vec_val: LLVMValueRef, elt_val: LLVMValueRef, index: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_insert_element"
pub fn llvm_build_insert_element(builder: LLVMBuilderRef, vec_val: LLVMValueRef, elt_val: LLVMValueRef, index: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_insert_element(builder, vec_val, elt_val, index, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_insert_element(self: LLVMBuilderRef, vec_val: LLVMValueRef, elt_val: LLVMValueRef, index: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_insert_element(self, vec_val, elt_val, index, name)
}

extern "C" fn __llvm_build_shuffle_vector(builder: LLVMBuilderRef, v1: LLVMValueRef, v2: LLVMValueRef, mask: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_shuffle_vector"
pub fn llvm_build_shuffle_vector(builder: LLVMBuilderRef, v1: LLVMValueRef, v2: LLVMValueRef, mask: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_shuffle_vector(builder, v1, v2, mask, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_shuffle_vector(self: LLVMBuilderRef, v1: LLVMValueRef, v2: LLVMValueRef, mask: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_shuffle_vector(self, v1, v2, mask, name)
}

extern "C" fn __llvm_build_extract_value(builder: LLVMBuilderRef, agg_val: LLVMValueRef, index: UInt, name: CStr) -> LLVMValueRef = "__llvm_build_extract_value"
pub fn llvm_build_extract_value(builder: LLVMBuilderRef, agg_val: LLVMValueRef, index: UInt, name: String) -> LLVMValueRef {
  __llvm_build_extract_value(builder, agg_val, index, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_extract_value(self: LLVMBuilderRef, agg_val: LLVMValueRef, index: UInt, name: String) -> LLVMValueRef {
  llvm_build_extract_value(self, agg_val, index, name)
}

extern "C" fn __llvm_build_insert_value(builder: LLVMBuilderRef, agg_val: LLVMValueRef, elt_val: LLVMValueRef, index: UInt, name: CStr) -> LLVMValueRef = "__llvm_build_insert_value"
pub fn llvm_build_insert_value(builder: LLVMBuilderRef, agg_val: LLVMValueRef, elt_val: LLVMValueRef, index: UInt, name: String) -> LLVMValueRef {
  __llvm_build_insert_value(builder, agg_val, elt_val, index, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_insert_value(self: LLVMBuilderRef, agg_val: LLVMValueRef, elt_val: LLVMValueRef, index: UInt, name: String) -> LLVMValueRef {
  llvm_build_insert_value(self, agg_val, elt_val, index, name)
}

extern "C" fn __llvm_build_freeze(builder: LLVMBuilderRef, val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_freeze"
pub fn llvm_build_freeze(builder: LLVMBuilderRef, val: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_freeze(builder, val, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_freeze(self: LLVMBuilderRef, val: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_freeze(self, val, name)
}

extern "C" fn __llvm_build_is_null(builder: LLVMBuilderRef, val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_is_null"
pub fn llvm_build_is_null(builder: LLVMBuilderRef, val: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_is_null(builder, val, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_is_null(self: LLVMBuilderRef, val: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_is_null(self, val, name)
}

extern "C" fn __llvm_build_is_not_null(builder: LLVMBuilderRef, val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_is_not_null"
pub fn llvm_build_is_not_null(builder: LLVMBuilderRef, val: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_is_not_null(builder, val, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_is_not_null(self: LLVMBuilderRef, val: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_is_not_null(self, val, name)
}

extern "C" fn __llvm_build_ptr_diff2(builder: LLVMBuilderRef, elem_ty: LLVMTypeRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_ptr_diff2"
pub fn llvm_build_ptr_diff2(builder: LLVMBuilderRef, elem_ty: LLVMTypeRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_ptr_diff2(builder, elem_ty, lhs, rhs, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_ptr_diff2(self: LLVMBuilderRef, elem_ty: LLVMTypeRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_ptr_diff2(self, elem_ty, lhs, rhs, name)
}

extern "C" fn __llvm_build_fence(builder: LLVMBuilderRef, ordering: Int, single_thread: LLVMBool, name: CStr) -> LLVMValueRef = "__llvm_build_fence"
pub fn llvm_build_fence(builder: LLVMBuilderRef, ordering: LLVMAtomicOrdering, single_thread: Bool, name: String) -> LLVMValueRef {
  let code = ordering.to_int()
  let name = moonbit_str_to_c_str(name)
  let single_thread = to_llvm_bool(single_thread)
  __llvm_build_fence(builder, code, single_thread, name)
}

extern "C" fn __llvm_build_atomic_rmw(builder: LLVMBuilderRef, op: Int, ptr: LLVMValueRef, val: LLVMValueRef, ordering: Int, single_thread: LLVMBool) -> LLVMValueRef = "__llvm_build_atomic_rmw"
pub fn llvm_build_atomic_rmw(builder: LLVMBuilderRef, op: LLVMAtomicRMWBinOp, ptr: LLVMValueRef, val: LLVMValueRef, ordering: LLVMAtomicOrdering, single_thread: LLVMBool) -> LLVMValueRef {
  let op = op.to_int()
  let ordering = ordering.to_int()
  __llvm_build_atomic_rmw(builder, op, ptr, val, ordering, single_thread)
}
pub fn LLVMBuilderRef::build_atomic_rmw(self: LLVMBuilderRef, op: LLVMAtomicRMWBinOp, ptr: LLVMValueRef, val: LLVMValueRef, ordering: LLVMAtomicOrdering, single_thread: LLVMBool) -> LLVMValueRef {
  llvm_build_atomic_rmw(self, op, ptr, val, ordering, single_thread)
}

extern "C" fn __llvm_build_atomic_cmp_xchg(builder: LLVMBuilderRef, ptr: LLVMValueRef, cmp: LLVMValueRef, _new: LLVMValueRef, success_ordering: Int, failure_ordering: Int, single_thread: LLVMBool) -> LLVMValueRef = "__llvm_build_atomic_cmp_xchg"
pub fn llvm_build_atomic_cmp_xchg(builder: LLVMBuilderRef, ptr: LLVMValueRef, cmp: LLVMValueRef, _new: LLVMValueRef, success_ordering: LLVMAtomicOrdering, failure_ordering: LLVMAtomicOrdering, single_thread: LLVMBool) -> LLVMValueRef {
  let success_ordering = success_ordering.to_int()
  let failure_ordering = failure_ordering.to_int()
  __llvm_build_atomic_cmp_xchg(builder, ptr, cmp, _new, success_ordering, failure_ordering, single_thread)
}

pub extern "C" fn llvm_get_num_mask_elements(shuffle_vector_inst: LLVMValueRef) -> UInt = "__llvm_get_num_mask_elements"
pub fn LLVMValueRef::get_num_mask_elements(self: LLVMValueRef) -> UInt {
  llvm_get_num_mask_elements(self)
}

// TODO: check if this is correct
pub extern "C" fn llvm_get_undef_mask_elem() -> Int = "__llvm_get_undef_mask_elem"

pub extern "C" fn llvm_get_mask_value(shuffle_vector_inst: LLVMValueRef, elt: UInt) -> Int = "__llvm_get_mask_value"
pub fn LLVMValueRef::get_mask_value(self: LLVMValueRef, elt: UInt) -> Int {
  llvm_get_mask_value(self, elt)
}

pub extern "C" fn llvm_is_atomic_single_thread(atomic_inst: LLVMValueRef) -> LLVMBool = "__llvm_is_atomic_single_thread"
pub fn LLVMValueRef::is_atomic_single_thread(self: LLVMValueRef) -> Bool {
  llvm_is_atomic_single_thread(self).to_moonbit_bool()
}

extern "C" fn __llvm_set_atomic_single_thread(atomic_inst: LLVMValueRef, single_thread: LLVMBool) = "__llvm_set_atomic_single_thread"
pub fn llvm_set_atomic_single_thread(atomic_inst: LLVMValueRef, single_thread: Bool) -> Unit {
  let single_thread = to_llvm_bool(single_thread)
  __llvm_set_atomic_single_thread(atomic_inst, single_thread)
}
pub fn LLVMValueRef::set_atomic_single_thread(self: LLVMValueRef, single_thread: Bool) -> Unit {
  llvm_set_atomic_single_thread(self, single_thread)
}


extern "C" fn __llvm_get_cmp_xchg_success_ordering(cmp_xchg_inst: LLVMValueRef) -> Int = "__llvm_get_cmp_xchg_success_ordering"
pub fn llvm_get_cmp_xchg_success_ordering(cmp_xchg_inst: LLVMValueRef) -> LLVMAtomicOrdering {
  let idx = __llvm_get_cmp_xchg_success_ordering(cmp_xchg_inst)
  LLVMAtomicOrdering::from_int(idx)
}

// pub extern "C" fn llvm_set_cmp_xchg_success_ordering(cmp_xchg_inst: LLVMValueRef, ordering: LLVMAtomicOrdering) = "__llvm_set_cmp_xchg_success_ordering"
extern "C" fn __llvm_set_cmp_xchg_success_ordering(cmp_xchg_inst: LLVMValueRef, ordering: Int) = "__llvm_set_cmp_xchg_success_ordering"
pub fn llvm_set_cmp_xchg_success_ordering(cmp_xchg_inst: LLVMValueRef, ordering: LLVMAtomicOrdering) -> Unit {
  let idx = ordering.to_int()
  __llvm_set_cmp_xchg_success_ordering(cmp_xchg_inst, idx)
}

extern "C" fn __llvm_get_cmp_xchg_failure_ordering(cmp_xchg_inst: LLVMValueRef) -> Int = "__llvm_get_cmp_xchg_failure_ordering"
pub fn llvm_get_cmp_xchg_failure_ordering(cmp_xchg_inst: LLVMValueRef) -> LLVMAtomicOrdering {
  let idx = __llvm_get_cmp_xchg_failure_ordering(cmp_xchg_inst)
  LLVMAtomicOrdering::from_int(idx)
}

extern "C" fn __llvm_set_cmp_xchg_failure_ordering(cmp_xchg_inst: LLVMValueRef, ordering: Int) = "__llvm_set_cmp_xchg_failure_ordering"
pub fn llvm_set_cmp_xchg_failure_ordering(cmp_xchg_inst: LLVMValueRef, ordering: LLVMAtomicOrdering) -> Unit {
  let idx = ordering.to_int()
  __llvm_set_cmp_xchg_failure_ordering(cmp_xchg_inst, idx)
}

pub extern "C" fn llvm_create_module_provider_for_existing_module(m: LLVMModuleRef) -> LLVMModuleProviderRef = "__llvm_create_module_provider_for_existing_module"

pub extern "C" fn llvm_dispose_module_provider(m: LLVMModuleProviderRef) = "__llvm_dispose_module_provider"

extern "C" fn __llvm_create_memory_buffer_with_contents_of_file(path: CStr, out_mem_buf: LLVMMemoryBufferRef, out_message: CStr) -> LLVMBool = "__llvm_create_memory_buffer_with_contents_of_file"
pub fn llvm_create_memory_buffer_with_contents_of_file(path: String, out_mem_buf: LLVMMemoryBufferRef, out_message: String) -> LLVMBool {
  let path = moonbit_str_to_c_str(path)
  let out_message = moonbit_str_to_c_str(out_message)
  __llvm_create_memory_buffer_with_contents_of_file(path, out_mem_buf, out_message)
}

extern "C" fn __llvm_create_memory_buffer_with_stdin(out_mem_buf: LLVMMemoryBufferRef, out_message: CStr) -> LLVMBool = "__llvm_create_memory_buffer_with_stdin"
pub fn llvm_create_memory_buffer_with_stdin(out_mem_buf: LLVMMemoryBufferRef, out_message: String) -> LLVMBool {
  let out_message = moonbit_str_to_c_str(out_message)
  __llvm_create_memory_buffer_with_stdin(out_mem_buf, out_message)
}

pub extern "C" fn llvm_create_memory_buffer_with_memory_range(input_data: CStr, input_data_length: Int, buffer_name: CStr, requires_null_terminator: LLVMBool) -> LLVMMemoryBufferRef = "__llvm_create_memory_buffer_with_memory_range"

pub extern "C" fn llvm_create_memory_buffer_with_memory_range_copy(input_data: CStr, input_data_length: Int, buffer_name: CStr) -> LLVMMemoryBufferRef = "__llvm_create_memory_buffer_with_memory_range_copy"

extern "C" fn __llvm_get_buffer_start(mem_buf: LLVMMemoryBufferRef) -> CStr = "__llvm_get_buffer_start"
pub fn llvm_get_buffer_start(mem_buf: LLVMMemoryBufferRef) -> String {
  c_str_to_moonbit_str(__llvm_get_buffer_start(mem_buf))
}
pub fn LLVMMemoryBufferRef::get_buffer_start(self: LLVMMemoryBufferRef) -> String {
  llvm_get_buffer_start(self)
}

pub extern "C" fn llvm_get_buffer_size(mem_buf: LLVMMemoryBufferRef) -> Int = "__llvm_get_buffer_size"
pub fn LLVMMemoryBufferRef::get_buffer_size(self: LLVMMemoryBufferRef) -> Int {
  llvm_get_buffer_size(self)
}

pub extern "C" fn llvm_dispose_memory_buffer(mem_buf: LLVMMemoryBufferRef) = "__llvm_dispose_memory_buffer"
pub fn LLVMMemoryBufferRef::dispose_memory_buffer(self: LLVMMemoryBufferRef) -> Unit {
  llvm_dispose_memory_buffer(self)
}

pub extern "C" fn llvm_create_pass_manager() -> LLVMPassManagerRef = "__llvm_create_pass_manager"
pub fn LLVMPassManagerRef::create() -> LLVMPassManagerRef {
  llvm_create_pass_manager()
}

pub extern "C" fn llvm_create_function_pass_manager_for_module(m: LLVMModuleRef) -> LLVMPassManagerRef = "__llvm_create_function_pass_manager_for_module"
pub fn LLVMModuleRef::create_function_pass_manager(self: LLVMModuleRef) -> LLVMPassManagerRef {
  llvm_create_function_pass_manager_for_module(self)
}

pub extern "C" fn llvm_create_function_pass_manager(mp: LLVMModuleProviderRef) -> LLVMPassManagerRef = "__llvm_create_function_pass_manager"
pub fn LLVMModuleProviderRef::create_function_pass_manager(self: LLVMModuleProviderRef) -> LLVMPassManagerRef {
  llvm_create_function_pass_manager(self)
}

pub extern "C" fn llvm_run_pass_manager(pm: LLVMPassManagerRef, m: LLVMModuleRef) -> LLVMBool = "__llvm_run_pass_manager"
pub fn LLVMPassManagerRef::run(self: LLVMPassManagerRef, m: LLVMModuleRef) -> Bool {
  llvm_run_pass_manager(self, m).to_moonbit_bool()
}

pub extern "C" fn llvm_initialize_function_pass_manager(fpm: LLVMPassManagerRef) -> LLVMBool = "__llvm_initialize_function_pass_manager"
pub fn LLVMPassManagerRef::initialize_function_pass_manager(self: LLVMPassManagerRef) -> Bool {
  llvm_initialize_function_pass_manager(self).to_moonbit_bool()
}

pub extern "C" fn llvm_run_function_pass_manager(fpm: LLVMPassManagerRef, f: LLVMValueRef) -> LLVMBool = "__llvm_run_function_pass_manager"
pub fn LLVMPassManagerRef::run_function_pass_manager(self: LLVMPassManagerRef, f: LLVMValueRef) -> Bool {
  llvm_run_function_pass_manager(self, f).to_moonbit_bool()
}

pub extern "C" fn llvm_finalize_function_pass_manager(fpm: LLVMPassManagerRef) -> LLVMBool = "__llvm_finalize_function_pass_manager"
pub fn LLVMPassManagerRef::finalize_function_pass_manager(self: LLVMPassManagerRef) -> Bool {
  llvm_finalize_function_pass_manager(self).to_moonbit_bool()
}

pub extern "C" fn llvm_dispose_pass_manager(pm: LLVMPassManagerRef) = "__llvm_dispose_pass_manager"
pub fn LLVMPassManagerRef::dispose_pass_manager(self: LLVMPassManagerRef) -> Unit {
  llvm_dispose_pass_manager(self)
}

extern "C" fn __llvm_start_multithreaded() -> LLVMBool = "__llvm_start_multithreaded"
pub fn llvm_start_multithreaded() -> Bool {
  __llvm_start_multithreaded().to_moonbit_bool()
}

pub extern "C" fn llvm_stop_multithreaded() = "__llvm_stop_multithreaded"

extern "C" fn __llvm_is_multithreaded() -> LLVMBool = "__llvm_is_multithreaded"
pub fn llvm_is_multithreaded() -> Bool {
  __llvm_is_multithreaded().to_moonbit_bool()
}

