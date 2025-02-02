
// Eliminate it when `Array::make` compiler bug fixed
fn LLVMTypeRef::make(cnt: Int, ty_ref: LLVMTypeRef) -> Array[LLVMTypeRef] {
  match cnt {
    0 => []
    1 => [ty_ref]
    2 => [ty_ref, ty_ref]
    3 => [ty_ref, ty_ref, ty_ref]
    4 => [ty_ref, ty_ref, ty_ref, ty_ref]
    5 => [ty_ref, ty_ref, ty_ref, ty_ref, ty_ref]
    6 => [ty_ref, ty_ref, ty_ref, ty_ref, ty_ref, ty_ref]
    7 => [ty_ref, ty_ref, ty_ref, ty_ref, ty_ref, ty_ref, ty_ref]
    8 => [ty_ref, ty_ref, ty_ref, ty_ref, ty_ref, ty_ref, ty_ref, ty_ref]
    9 => [ty_ref, ty_ref, ty_ref, ty_ref, ty_ref, ty_ref, ty_ref, ty_ref, ty_ref]
    10 => [ty_ref, ty_ref, ty_ref, ty_ref, ty_ref, ty_ref, ty_ref, ty_ref, ty_ref, ty_ref]
    _ => {
      println("Over 10 elemnts of LLVMTypeRef is not supported currently.")
      println("Need to wait Compiler bug fixed.")
      panic()
    }
      
  }
}

extern "C" fn llvm_new_null_type_ref() -> LLVMTypeRef = "__llvm_new_null_type_ref"

extern "C" fn llvm_same_type_ref(ty1: LLVMTypeRef, ty2: LLVMTypeRef) -> LLVMBool = "__llvm_same_type_ref"
fn LLVMTypeRef::is_equal(self: LLVMTypeRef, other: LLVMTypeRef) -> Bool {
  llvm_same_type_ref(self, other).to_moonbit_bool()
}

extern "C" fn llvm_same_value_ref(val1: LLVMValueRef, val2: LLVMValueRef) -> LLVMBool = "__llvm_same_value_ref"
fn LLVMValueRef::is_equal(self: LLVMValueRef, other: LLVMValueRef) -> Bool {
  llvm_same_value_ref(self, other).to_moonbit_bool()
}

extern "C" fn llvm_same_ctx_ref(ctx1: LLVMContextRef, ctx2: LLVMContextRef) -> LLVMBool = "__llvm_same_ctx_ref"
fn LLVMContextRef::is_equal(self: LLVMContextRef, other: LLVMContextRef) -> Bool {
  llvm_same_ctx_ref(self, other).to_moonbit_bool()
}

// extern "C" fn llvm_new_null_value_ref() -> LLVMValueRef = "__llvm_new_null_value_ref"

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
/// - see `LLVMContext::shouldDiscardValueNames()`
pub extern "C" fn llvm_context_should_discard_value_names(context: LLVMContextRef) -> LLVMBool = "__llvm_context_should_discard_value_names"
pub fn LLVMContextRef::should_discard_value_names(self: LLVMContextRef) -> Bool {
  llvm_context_should_discard_value_names(self).to_moonbit_bool()
}

///| Set whether the given context discards all value names.
/// 
/// If true, only the names of GlobalValue objects will be available in the IR.
/// This can be used to save memory and runtime, especially in release mode.
/// 
/// - see `LLVMContext::setDiscardValueNames()`
extern "C" fn __llvm_context_set_discard_value_names(context: LLVMContextRef, discard: LLVMBool) = "__llvm_context_set_discard_value_names"

///| Set whether the given context discards all value names.
/// 
/// If true, only the names of GlobalValue objects will be available in the IR.
/// This can be used to save memory and runtime, especially in release mode.
/// 
/// - see `LLVMContext::setDiscardValueNames()`
pub fn llvm_context_set_discard_value_names(context: LLVMContextRef, discard: Bool) -> Unit {
  __llvm_context_set_discard_value_names(context, to_llvm_bool(discard))
}

///| Set whether the given context discards all value names.
/// 
/// If true, only the names of GlobalValue objects will be available in the IR.
/// This can be used to save memory and runtime, especially in release mode.
/// 
/// - see `LLVMContext::setDiscardValueNames()`
pub fn LLVMContextRef::set_discard_value_names(self: LLVMContextRef, discard: Bool) -> Unit {
  __llvm_context_set_discard_value_names(self, to_llvm_bool(discard))
}

///| Destroy a context instance.
/// 
/// This should be called for every call to `llvm_context_create()` or memory
/// will be leaked.
pub extern "C" fn llvm_context_dispose(context: LLVMContextRef) = "__llvm_context_dispose"

///| Destroy a context instance.
/// 
/// This should be called for every call to `llvm_context_create()` or memory
/// will be leaked.
pub fn LLVMContextRef::dispose(self: LLVMContextRef) -> Unit {
  llvm_context_dispose(self)
}


///| Return a string representation of the DiagnosticInfo. Use `llvm_dispose_message` to free the string.
/// 
/// - see `DiagnosticInfo::print()`
/// 
extern "C" fn __llvm_get_diag_info_description(di: LLVMDiagnosticInfoRef) -> CStr = "__llvm_get_diag_info_description"

///| Return a string representation of the DiagnosticInfo. Use `llvm_dispose_message` to free the string.
/// 
/// - see `DiagnosticInfo::print()`
/// 
pub fn llvm_get_diag_info_description(di: LLVMDiagnosticInfoRef) -> String {
  let cstr = __llvm_get_diag_info_description(di)
  c_str_to_moonbit_str(cstr)
}


///| Return an enum llvm_diagnostic_severity.
/// 
/// - see `DiagnosticInfo::getSeverity()`
/// 
pub extern "C" fn llvm_get_diag_info_severity(di: LLVMDiagnosticInfoRef) -> Int = "__llvm_get_diag_info_severity"

///| Return an enum llvm_diagnostic_severity.
/// 
/// - see `DiagnosticInfo::getSeverity()`
/// 
pub fn LLVMDiagnosticInfoRef::get_severity(self: LLVMDiagnosticInfoRef) -> LLVMDiagnosticSeverity {
  LLVMDiagnosticSeverity::from_int(llvm_get_diag_info_severity(self))
}

// TODO: Warp it
extern "C" fn __llvm_get_md_kind_id_in_context(context: LLVMContextRef, name: CStr, s_len: UInt) -> UInt = "__llvm_get_md_kind_id_in_context"
pub fn llvm_get_md_kind_id_in_context(context: LLVMContextRef, name: String) -> UInt {
  let cstr = moonbit_str_to_c_str(name)
  let s_len = name.length().reinterpret_as_uint()
  __llvm_get_md_kind_id_in_context(context, cstr, s_len)
}

extern "C" fn __llvm_get_md_kind_id(name: CStr, s_len: UInt) -> UInt = "__llvm_get_md_kind_id"
pub fn llvm_get_md_kind_id(name: String) -> UInt {
  let cstr = moonbit_str_to_c_str(name)
  let s_len = name.length().reinterpret_as_uint()
  __llvm_get_md_kind_id(cstr, s_len)
}

extern "C" fn __llvm_get_enum_attribute_kind_for_name(name: CStr, s_len: UInt64) -> UInt = "__llvm_get_enum_attribute_kind_for_name"
pub fn llvm_get_enum_attribute_kind_for_name(name: String) -> UInt {
  let cstr = moonbit_str_to_c_str(name)
  let s_len = name.length().to_uint64()
  __llvm_get_enum_attribute_kind_for_name(cstr, s_len)
}

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

///| Get the enum attribute's value. 0 is returned if none exists.
pub fn LLVMAttributeRef::get_enum_attribute_value(self: LLVMAttributeRef) -> UInt64 {
  llvm_get_enum_attribute_value(self)
}

///| Create a type attribute
pub extern "C" fn llvm_create_type_attribute(context: LLVMContextRef, kind_id: UInt, type_ref: LLVMTypeRef) -> LLVMAttributeRef = "__llvm_create_type_attribute"

///| Get the type attribute's value.
pub extern "C" fn llvm_get_type_attribute_value(a: LLVMAttributeRef) -> LLVMTypeRef = "__llvm_get_type_attribute_value"

///| Get the type attribute's value.
pub fn LLVMAttributeRef::get_type_attribute_value(self: LLVMAttributeRef) -> LLVMTypeRef {
  llvm_get_type_attribute_value(self)
}

///| Create a string attribute.
extern "C" fn __llvm_create_string_attribute(ctx: LLVMContextRef, k: CStr, k_len: UInt, v: CStr, v_len: UInt) -> LLVMAttributeRef = "__llvm_create_string_attribute"

///| Create a string attribute.
pub fn llvm_create_string_attribute(ctx: LLVMContextRef, k: String, v: String) -> LLVMAttributeRef {
  let k_cstr = moonbit_str_to_c_str(k)
  let v_cstr = moonbit_str_to_c_str(v)
  let k_len = k.length().reinterpret_as_uint()
  let v_len = v.length().reinterpret_as_uint()
  __llvm_create_string_attribute(ctx, k_cstr, k_len, v_cstr, v_len)
}


extern "C" fn __llvm_get_string_attribute_kind(a: LLVMAttributeRef) -> (CStr, UInt) = "__llvm_get_string_attribute_kind"
pub fn llvm_get_string_attribute_kind(a: LLVMAttributeRef) -> String {
  let (cstr, len) = __llvm_get_string_attribute_kind(a)
  c_str_to_moonbit_str_with_length(cstr, len)
}

extern "C" fn __llvm_get_string_attribute_value(a: LLVMAttributeRef) -> (CStr, UInt) = "__llvm_get_string_attribute_value"
pub fn llvm_get_string_attribute_value(a: LLVMAttributeRef) -> String {
  let (cstr, len) = __llvm_get_string_attribute_value(a)
  c_str_to_moonbit_str_with_length(cstr, len)
}

///| Check if the attribute is an enum attribute.
extern "C" fn __llvm_is_enum_attribute(a: LLVMAttributeRef) -> LLVMBool = "__llvm_is_enum_attribute"

///| Check if the attribute is an enum attribute.
pub fn llvm_is_enum_attribute(a: LLVMAttributeRef) -> Bool {
  __llvm_is_enum_attribute(a).to_moonbit_bool()
}

///| Check if the attribute is an enum attribute.
pub fn LLVMAttributeRef::is_enum_attribute(self: LLVMAttributeRef) -> Bool {
  __llvm_is_enum_attribute(self).to_moonbit_bool()
}

///| Check if the attribute is a string attribute.
extern "C" fn __llvm_is_string_attribute(a: LLVMAttributeRef) -> LLVMBool = "__llvm_is_string_attribute"

///| Check if the attribute is a string attribute.
pub fn llvm_is_string_attribute(a: LLVMAttributeRef) -> Bool {
  __llvm_is_string_attribute(a).to_moonbit_bool()
}

///| Check if the attribute is a string attribute.
pub fn LLVMAttributeRef::is_string_attribute(self: LLVMAttributeRef) -> Bool {
  __llvm_is_string_attribute(self).to_moonbit_bool()
}

///| Check if the attribute is a type attribute.
extern "C" fn __llvm_is_type_attribute(a: LLVMAttributeRef) -> LLVMBool = "__llvm_is_type_attribute"

///| Check if the attribute is a type attribute.
pub fn llvm_is_type_attribute(a: LLVMAttributeRef) -> Bool {
  __llvm_is_type_attribute(a).to_moonbit_bool()
}

///| Check if the attribute is a type attribute.
pub fn LLVMAttributeRef::is_type_attribute(self: LLVMAttributeRef) -> Bool {
  __llvm_is_type_attribute(self).to_moonbit_bool()
}

///| Obtain a Type from a context by its registered name.
extern "C" fn __llvm_get_type_by_name(context: LLVMContextRef, name: CStr) -> LLVMTypeRef = "__llvm_get_type_by_name"

///| Obtain a Type from a context by its registered name.
pub fn llvm_get_type_by_name(context: LLVMContextRef, name: String) -> LLVMTypeRef {
  let cstr = moonbit_str_to_c_str(name)
  __llvm_get_type_by_name(context, cstr)
}

///| Obtain a Type from a context by its registered name.
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

///| Create a new, empty module in the global context.
/// 
/// This is equivalent to calling `LLVMModuleCreateWithNameInContext` with
/// `LLVMGetGlobalContext()` as the context parameter.
/// 
/// Every invocation should be paired with `LLVMDisposeModule()` or memory
/// will be leaked.
/// 
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

/// Create a new, empty module in the global context.
/// 
/// This is equivalent to calling LLVMModuleCreateWithNameInContext with
/// LLVMGetGlobalContext() as the context parameter.
/// 
/// Every invocation should be paired with LLVMDisposeModule() or memory
/// will be leaked.
/// 
pub fn llvm_module_create_with_name_in_context(module_id: String, context: LLVMContextRef) -> LLVMModuleRef {
  let cstr = moonbit_str_to_c_str(module_id)
  __llvm_module_create_with_name_in_context(cstr, context)
}

/// Create a new, empty module in the global context.
/// 
/// This is equivalent to calling LLVMModuleCreateWithNameInContext with
/// LLVMGetGlobalContext() as the context parameter.
/// 
/// Every invocation should be paired with LLVMDisposeModule() or memory
/// will be leaked.
/// 
pub fn LLVMContextRef::module_create_with_name(self: LLVMContextRef, module_id: String) -> LLVMModuleRef {
  llvm_module_create_with_name_in_context(module_id, self)
}

///| Return an exact copy of the specified module.
pub extern "C" fn llvm_clone_module(m: LLVMModuleRef) -> LLVMModuleRef = "__llvm_clone_module"

///| Return an exact copy of the specified module.
pub fn LLVMModuleRef::clone(self: LLVMModuleRef) -> LLVMModuleRef {
  llvm_clone_module(self)
}

///| Destroy a module instance.
/// 
/// This must be called for every created module or memory will be
/// leaked.
/// 
pub extern "C" fn llvm_dispose_module(m: LLVMModuleRef) = "__llvm_dispose_module"

///| Destroy a module instance.
/// 
/// This must be called for every created module or memory will be
/// leaked.
/// 
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

extern "C" fn __llvm_get_module_identifier(m: LLVMModuleRef) -> (CStr, UInt64) = "__llvm_get_module_identifier"
pub fn llvm_get_module_identifier(m: LLVMModuleRef) -> String {
  let (cstr, len) = __llvm_get_module_identifier(m)
  c_str_to_moonbit_str_with_length(cstr, len.to_uint())
}

extern "C" fn __llvm_set_module_identifier(m: LLVMModuleRef, ident: CStr, len: UInt64) = "__llvm_set_module_identifier"
pub fn llvm_set_module_identifier(m: LLVMModuleRef, ident: String) -> Unit {
  let cstr = moonbit_str_to_c_str(ident)
  let len = ident.length().to_uint64()
  __llvm_set_module_identifier(m, cstr, len)
}

///| Obtain the module's original source file name.
/// 
/// @param M Module to obtain the name of
/// @param Len Out parameter which holds the length of the returned string
/// @return The original source file name of M
///
/// - see Module::getSourceFileName()
extern "C" fn __llvm_get_source_file_name(m: LLVMModuleRef) -> (CStr, UInt64) = "__llvm_get_source_file_name"

///| Obtain the module's original source file name.
/// 
/// @param M Module to obtain the name of
/// @param Len Out parameter which holds the length of the returned string
/// @return The original source file name of M
///
/// - see Module::getSourceFileName()
pub fn llvm_get_source_file_name(m: LLVMModuleRef) -> String {
  let (cstr, len) = __llvm_get_source_file_name(m)
  c_str_to_moonbit_str_with_length(cstr, len.to_uint())
}

///| Set the original source file name of a module to a string Name with length.
/// 
/// @param M The module to set the source file name of
/// @param Name The string to set M's source file name to
/// @param Len Length of Name
///
/// - see Module::setSourceFileName()
extern "C" fn __llvm_set_source_file_name(m: LLVMModuleRef, name: CStr, len: UInt64) = "__llvm_set_source_file_name"
pub fn llvm_set_source_file_name(m: LLVMModuleRef, name: String) -> Unit {
  let cstr = moonbit_str_to_c_str(name)
  let len = name.length().to_uint64()
  __llvm_set_source_file_name(m, cstr, len)
}


///| Obtain the data layout for a module.
/// 
/// - see Module::getDataLayoutStr()
/// 
/// LLVMGetDataLayout is DEPRECATED, as the name is not only incorrect,
/// but match the name of another method on the module. Prefer the use
/// of LLVMGetDataLayoutStr, which is not ambiguous.
/// 
extern "C" fn __llvm_get_data_layout_str(m: LLVMModuleRef) -> CStr = "__llvm_get_data_layout_str"

///| Obtain the data layout for a module.
/// 
/// - see Module::getDataLayoutStr()
/// 
/// LLVMGetDataLayout is DEPRECATED, as the name is not only incorrect,
/// but match the name of another method on the module. Prefer the use
/// of LLVMGetDataLayoutStr, which is not ambiguous.
/// 
pub fn llvm_get_data_layout_str(m: LLVMModuleRef) -> String {
  let cstr = __llvm_get_data_layout_str(m)
  c_str_to_moonbit_str(cstr)
}

///| Obtain the data layout for a module.
/// 
/// - see Module::getDataLayoutStr()
/// 
/// LLVMGetDataLayout is DEPRECATED, as the name is not only incorrect,
/// but match the name of another method on the module. Prefer the use
/// of LLVMGetDataLayoutStr, which is not ambiguous.
/// 
pub fn LLVMModuleRef::get_data_layout_str(self: LLVMModuleRef) -> String {
  llvm_get_data_layout_str(self)
}

///| Get the data layout for a module.
extern "C" fn __llvm_get_data_layout(m: LLVMModuleRef) -> CStr = "__llvm_get_data_layout"

///| Get the data layout for a module.
pub fn llvm_get_data_layout(m: LLVMModuleRef) -> String {
  let cstr = __llvm_get_data_layout(m)
  c_str_to_moonbit_str(cstr)
}

///| Get the data layout for a module.
pub fn LLVMModuleRef::get_data_layout(self: LLVMModuleRef) -> String {
  llvm_get_data_layout(self)
}

///| Set the data layout for a module.
/// 
/// - see Module::setDataLayout()
/// 
extern "C" fn __llvm_set_data_layout(m: LLVMModuleRef, data_layout_str: CStr) = "__llvm_set_data_layout"

///| Set the data layout for a module.
/// 
/// - see Module::setDataLayout()
/// 
pub fn llvm_set_data_layout(m: LLVMModuleRef, data_layout_str: String) -> Unit {
  let cstr = moonbit_str_to_c_str(data_layout_str)
  __llvm_set_data_layout(m, cstr)
}

///| Set the data layout for a module.
/// 
/// - see Module::setDataLayout()
/// 
pub fn LLVMModuleRef::set_data_layout(self: LLVMModuleRef, data_layout_str: String) -> Unit {
  llvm_set_data_layout(self, data_layout_str)
}

///| Obtain the target triple for a module.
/// 
/// - see Module::getTargetTriple()
/// 
extern "C" fn __llvm_get_target(m: LLVMModuleRef) -> CStr = "__llvm_get_target"

///| Obtain the target triple for a module.
/// 
/// - see Module::getTargetTriple()
/// 
pub fn llvm_get_target(m: LLVMModuleRef) -> String {
  let cstr = __llvm_get_target(m)
  c_str_to_moonbit_str(cstr)
}

///| Obtain the target triple for a module.
/// 
/// - see Module::getTargetTriple()
/// 
pub fn LLVMModuleRef::get_target(self: LLVMModuleRef) -> String {
  llvm_get_target(self)
}


///| Set the target triple for a module.
/// 
/// - see Module::setTargetTriple()
/// 
extern "C" fn __llvm_set_target(m: LLVMModuleRef, triple: CStr) = "__llvm_set_target"

///| Set the target triple for a module.
/// 
/// - see Module::setTargetTriple()
/// 
pub fn llvm_set_target(m: LLVMModuleRef, triple: String) -> Unit {
  let cstr = moonbit_str_to_c_str(triple)
  __llvm_set_target(m, cstr)
}

///| Set the target triple for a module.
/// 
/// - see Module::setTargetTriple()
/// 
pub fn LLVMModuleRef::set_target(self: LLVMModuleRef, triple: String) -> Unit {
  llvm_set_target(self, triple)
}

// 
// Returns the module flags as an array of flag-key-value triples.  The caller
// is responsible for freeing this array by calling
// \c LLVMDisposeModuleFlagsMetadata.
// 
// - see Module::getModuleFlagsMetadata()
// 
// pub extern "C" fn llvm_copy_module_flags_metadata(m: LLVMModuleRef, len: Ptr[UInt64]) -> Ptr[LLVMModuleFlagEntry] = "__llvm_copy_module_flags_metadata"


// /**
//  * Destroys module flags metadata entries.
//  */
// pub extern "C" fn llvm_dispose_module_flags_metadata(entries: Ptr[LLVMModuleFlagEntry]) = "__llvm_dispose_module_flags_metadata"


// 
// Returns the flag behavior for a module flag entry at a specific index.
// 
// - see Module::ModuleFlagEntry::Behavior
// 
// pub extern "C" fn llvm_module_flag_entries_get_flag_behavior(entries: Ptr[LLVMModuleFlagEntry], index: UInt) -> LLVMModuleFlagBehavior = "__llvm_module_flag_entries_get_flag_behavior"


// 
// Returns the key for a module flag entry at a specific index.
// 
// - see Module::ModuleFlagEntry::Key
// 
// pub extern "C" fn llvm_module_flag_entries_get_key(entries: Ptr[LLVMModuleFlagEntry], index: UInt, len: Ptr[UInt64]) -> CStr = "__llvm_module_flag_entries_get_key"


// 
// Returns the metadata for a module flag entry at a specific index.
// 
// - see Module::ModuleFlagEntry::Val
// 
// pub extern "C" fn llvm_module_flag_entries_get_metadata(entries: Ptr[LLVMModuleFlagEntry], index: UInt) -> LLVMMetadataRef = "__llvm_module_flag_entries_get_metadata"


/// Add a module-level flag to the module-level flags metadata if it doesn't already exist.
/// 
/// - see Module::getModuleFlag()
pub extern "C" fn llvm_get_module_flag(m: LLVMModuleRef, key: CStr, key_len: UInt64) -> LLVMMetadataRef = "__llvm_get_module_flag"


/// Add a module-level flag to the module-level flags metadata if it doesn't already exist.
/// 
/// - see Module::addModuleFlag()
/// 
pub extern "C" fn llvm_add_module_flag(m: LLVMModuleRef, behavior: LLVMModuleFlagBehavior, key: CStr, key_len: UInt64, val: LLVMMetadataRef) = "__llvm_add_module_flag"


///| Dump a representation of a module to stderr.
/// 
/// - see Module::dump()
pub extern "C" fn llvm_dump_module(m: LLVMModuleRef) = "__llvm_dump_module"
pub fn LLVMModuleRef::dump(self: LLVMModuleRef) -> Unit {
  llvm_dump_module(self)
}

// Print a representation of a module to a file. The ErrorMessage needs to be
// disposed with LLVMDisposeMessage. Returns 0 on success, 1 otherwise.
// 
// - see Module::print()
// 
// pub extern "C" fn llvm_print_module_to_file(m: LLVMModuleRef, filename: CStr, error_message: Ptr[CStr]) -> LLVMBool = "__llvm_print_module_to_file"

///| Return a string representation of the module.
///
/// Return a string representation of the module. Use
/// LLVMDisposeMessage to free the string.
/// 
/// - see Module::print()
extern "C" fn __llvm_print_module_to_string(m: LLVMModuleRef) -> CStr = "__llvm_print_module_to_string"

///| Return a string representation of the module.
///
/// Return a string representation of the module. Use
/// LLVMDisposeMessage to free the string.
/// 
/// - see Module::print()
pub fn llvm_print_module_to_string(m: LLVMModuleRef) -> String {
  let cstr = __llvm_print_module_to_string(m)
  c_str_to_moonbit_str(cstr)
}

///| Return a string representation of the module.
///
/// Return a string representation of the module. Use
/// LLVMDisposeMessage to free the string.
/// 
/// - see Module::print()
pub fn LLVMModuleRef::print_to_string(self: LLVMModuleRef) -> String {
  llvm_print_module_to_string(self)
}

///| Return a string representation of the module.
///
/// Return a string representation of the module. Use
/// LLVMDisposeMessage to free the string.
/// 
/// - see Module::print()
pub fn LLVMModuleRef::to_string(self: LLVMModuleRef) -> String {
  llvm_print_module_to_string(self)
}

///| Get inline assembly for a module.
/// 
/// - see Module::getModuleInlineAsm()
extern "C" fn __llvm_get_module_inline_asm(m: LLVMModuleRef) -> (CStr, UInt64) = "__llvm_get_module_inline_asm"

///| Get inline assembly for a module.
/// 
/// - see Module::getModuleInlineAsm()
pub fn llvm_get_module_inline_asm(m: LLVMModuleRef) -> String {
  let (cstr, len) = __llvm_get_module_inline_asm(m)
  c_str_to_moonbit_str_with_length(cstr, len.to_uint())
}

///| Set inline assembly for a module.
/// 
/// - see Module::setModuleInlineAsm()
extern "C" fn __llvm_set_module_inline_asm(m: LLVMModuleRef, _asm: CStr, len: UInt64) = "__llvm_set_module_inline_asm"

///| Set inline assembly for a module.
/// 
/// - see Module::setModuleInlineAsm()
pub fn llvm_set_module_inline_asm(m: LLVMModuleRef, _asm: String) -> Unit {
  let cstr = moonbit_str_to_c_str(_asm)
  __llvm_set_module_inline_asm(m, cstr, _asm.length().to_uint64())
}

///| Append inline assembly to a module.
/// 
/// - see Module::appendModuleInlineAsm()
pub extern "C" fn llvm_append_module_inline_asm(m: LLVMModuleRef, _asm: CStr, len: UInt64) = "__llvm_append_module_inline_asm"


// Create the specified uniqued inline asm string.
// 
// - see InlineAsm::get()
// 
// pub extern "C" fn llvm_get_inline_asm(ty: LLVMTypeRef, asm_string: CStr, asm_string_size: UInt64, constraints: CStr, constraints_size: UInt64, has_side_effects: LLVMBool, is_align_stack: LLVMBool, dialect: LLVMInlineAsmDialect, can_throw: LLVMBool) -> LLVMValueRef = "__llvm_get_inline_asm"

// Get the template string used for an inline assembly snippet
// pub extern "C" fn llvm_get_inline_asm_asm_string(inline_asm_val: LLVMValueRef, len: Ptr[UInt64]) -> CStr = "__llvm_get_inline_asm_asm_string"

// Get the raw constraint string for an inline assembly snippet
// pub extern "C" fn llvm_get_inline_asm_constraint_string(inline_asm_val: LLVMValueRef, len: Ptr[UInt64]) -> CStr = "__llvm_get_inline_asm_constraint_string"


///| Get the dialect used by the inline asm snippet
pub extern "C" fn llvm_get_inline_asm_dialect(inline_asm_val: LLVMValueRef) -> LLVMInlineAsmDialect = "__llvm_get_inline_asm_dialect"

///| Get the dialect used by the inline asm snippet
pub fn LLVMValueRef::get_inline_asm_dialect(self: LLVMValueRef) -> LLVMInlineAsmDialect {
  llvm_get_inline_asm_dialect(self)
}


///| Get the function type of the inline assembly snippet.
///
/// Get the function type of the inline assembly snippet. The same type that
/// was passed into LLVMGetInlineAsm originally
/// 
/// - see LLVMGetInlineAsm
pub extern "C" fn llvm_get_inline_asm_function_type(inline_asm_val: LLVMValueRef) -> LLVMTypeRef = "__llvm_get_inline_asm_function_type"

///| Get the function type of the inline assembly snippet.
///
/// Get the function type of the inline assembly snippet. The same type that
/// was passed into LLVMGetInlineAsm originally
/// 
/// - see LLVMGetInlineAsm
pub fn LLVMValueRef::get_inline_asm_function_type(self: LLVMValueRef) -> LLVMTypeRef {
  llvm_get_inline_asm_function_type(self)
}

///| Get if the inline asm snippet has side effects
extern "C" fn __llvm_get_inline_asm_has_side_effects(inline_asm_val: LLVMValueRef) -> LLVMBool = "__llvm_get_inline_asm_has_side_effects"

///| Get if the inline asm snippet has side effects
pub fn llvm_get_inline_asm_has_side_effects(inline_asm_val: LLVMValueRef) -> Bool {
  __llvm_get_inline_asm_has_side_effects(inline_asm_val).to_moonbit_bool()
}

///| Get if the inline asm snippet has side effects
pub fn LLVMValueRef::get_inline_asm_has_side_effects(self: LLVMValueRef) -> Bool {
  __llvm_get_inline_asm_has_side_effects(self).to_moonbit_bool()
}

///| Get if the inline asm snippet needs an aligned stack
extern "C" fn __llvm_get_inline_asm_needs_aligned_stack(inline_asm_val: LLVMValueRef) -> LLVMBool = "__llvm_get_inline_asm_needs_aligned_stack"

///| Get if the inline asm snippet needs an aligned stack
pub fn llvm_get_inline_asm_needs_aligned_stack(inline_asm_val: LLVMValueRef) -> Bool {
  __llvm_get_inline_asm_needs_aligned_stack(inline_asm_val).to_moonbit_bool()
}

///| Get if the inline asm snippet needs an aligned stack
pub fn LLVMValueRef::get_inline_asm_needs_aligned_stack(self: LLVMValueRef) -> Bool {
  __llvm_get_inline_asm_needs_aligned_stack(self).to_moonbit_bool()
}

///| Get if the inline asm snippet may unwind the stack
extern "C" fn __llvm_get_inline_asm_can_unwind(inline_asm_val: LLVMValueRef) -> LLVMBool = "__llvm_get_inline_asm_can_unwind"

///| Get if the inline asm snippet may unwind the stack
pub fn llvm_get_inline_asm_can_unwind(inline_asm_val: LLVMValueRef) -> Bool {
  __llvm_get_inline_asm_can_unwind(inline_asm_val).to_moonbit_bool()
}

///| Get if the inline asm snippet may unwind the stack
pub fn LLVMValueRef::get_inline_asm_can_unwind(self: LLVMValueRef) -> Bool {
  __llvm_get_inline_asm_can_unwind(self).to_moonbit_bool()
}

///| Obtain the context to which this module is associated.
/// 
/// - see Module::getContext()
pub extern "C" fn llvm_get_module_context(m: LLVMModuleRef) -> LLVMContextRef = "__llvm_get_module_context"

///| Obtain the context to which this module is associated.
/// 
/// - see Module::getContext()
pub fn LLVMModuleRef::get_context(self: LLVMModuleRef) -> LLVMContextRef {
  llvm_get_module_context(self)
}

extern "C" fn __llvm_get_type_by_name_in_module(m: LLVMModuleRef, name: CStr) -> LLVMTypeRef = "__llvm_get_type_by_name_in_module"
pub fn llvm_get_type_by_name_in_module(m: LLVMModuleRef, name: String) -> LLVMTypeRef {
  let cstr = moonbit_str_to_c_str(name)
  __llvm_get_type_by_name_in_module(m, cstr)
}
pub fn LLVMModuleRef::get_type_by_name(self: LLVMModuleRef, name: String) -> LLVMTypeRef {
  llvm_get_type_by_name_in_module(self, name)
}

///| Obtain an iterator to the first NamedMDNode in a Module.
/// 
/// - see llvm::Module::named_metadata_begin()
pub extern "C" fn llvm_get_first_named_metadata(m: LLVMModuleRef) -> LLVMNamedMDNodeRef = "__llvm_get_first_named_metadata"

///| Obtain an iterator to the last NamedMDNode in a Module.
/// 
/// - see llvm::Module::named_metadata_end()
/// 
pub extern "C" fn llvm_get_last_named_metadata(m: LLVMModuleRef) -> LLVMNamedMDNodeRef = "__llvm_get_last_named_metadata"

///| Advance a NamedMDNode iterator to the next NamedMDNode.
/// 
/// Returns NULL if the iterator was already at the end and there are no more
/// named metadata nodes.
pub extern "C" fn llvm_get_next_named_metadata(named_md_node: LLVMNamedMDNodeRef) -> LLVMNamedMDNodeRef = "__llvm_get_next_named_metadata"


///| Decrement a NamedMDNode iterator to the previous NamedMDNode.
/// 
/// Returns NULL if the iterator was already at the beginning and there are
/// no previous named metadata nodes.
/// 
pub extern "C" fn llvm_get_previous_named_metadata(named_md_node: LLVMNamedMDNodeRef) -> LLVMNamedMDNodeRef = "__llvm_get_previous_named_metadata"


///| Retrieve a NamedMDNode with the given name.
///
/// Retrieve a NamedMDNode with the given name, returning NULL if no such
/// node exists.
/// 
/// - see llvm::Module::getNamedMetadata()
pub extern "C" fn llvm_get_named_metadata(m: LLVMModuleRef, name: CStr, name_len: UInt64) -> LLVMNamedMDNodeRef = "__llvm_get_named_metadata"

///| Retrieve a NamedMDNode with the given name, creating a new node if no such node exists.
/// 
/// - see llvm::Module::getOrInsertNamedMetadata()
pub extern "C" fn llvm_get_or_insert_named_metadata(m: LLVMModuleRef, name: CStr, name_len: UInt64) -> LLVMNamedMDNodeRef = "__llvm_get_or_insert_named_metadata"

// pub extern "C" fn llvm_get_named_metadata_name(named_md: LLVMNamedMDNodeRef, name_len: Ptr[UInt64]) -> CStr = "__llvm_get_named_metadata_name"

///| Retrieve the name of a NamedMDNode.
/// 
/// - see llvm::NamedMDNode::getName()
/// 
extern "C" fn __llvm_get_named_metadata_num_operands(m: LLVMModuleRef, name: CStr) -> UInt = "__llvm_get_named_metadata_num_operands"

///| Retrieve the name of a NamedMDNode.
/// 
/// - see llvm::NamedMDNode::getName()
/// 
pub fn llvm_get_named_metadata_num_operands(m: LLVMModuleRef, name: String) -> UInt {
  let cstr = moonbit_str_to_c_str(name)
  __llvm_get_named_metadata_num_operands(m, cstr)
}

///| Retrieve the name of a NamedMDNode.
/// 
/// - see llvm::NamedMDNode::getName()
/// 
pub fn LLVMModuleRef::get_named_metadata_num_operands(self: LLVMModuleRef, name: String) -> UInt {
  llvm_get_named_metadata_num_operands(self, name)
}

///| Obtain the number of operands for named metadata in a module.
/// 
/// - see llvm::Module::getNamedMetadata()
extern "C" fn __llvm_get_named_metadata_operands(m: LLVMModuleRef, name: CStr) -> Array[LLVMValueRef] = "__llvm_get_named_metadata_operands"

///| Obtain the number of operands for named metadata in a module.
/// 
/// - see llvm::Module::getNamedMetadata()
pub fn llvm_get_named_metadata_operands(m: LLVMModuleRef, name: String) -> Array[LLVMValueRef] {
  let cstr = moonbit_str_to_c_str(name)
  __llvm_get_named_metadata_operands(m, cstr)
}

///| Obtain the number of operands for named metadata in a module.
/// 
/// - see llvm::Module::getNamedMetadata()
pub fn LLVMModuleRef::get_named_metadata(self: LLVMModuleRef, name: String) -> Array[LLVMValueRef] {
  llvm_get_named_metadata_operands(self, name)
}


///| Add an operand to named metadata.
/// 
/// - see llvm::Module::getNamedMetadata()
/// - see llvm::MDNode::addOperand()
extern "C" fn __llvm_add_named_metadata_operand(m: LLVMModuleRef, name: CStr, val: LLVMValueRef) = "__llvm_add_named_metadata_operand"

///| Add an operand to named metadata.
/// 
/// - see llvm::Module::getNamedMetadata()
/// - see llvm::MDNode::addOperand()
pub fn llvm_add_named_metadata_operand(m: LLVMModuleRef, name: String, val: LLVMValueRef) -> Unit {
  let cstr = moonbit_str_to_c_str(name)
  __llvm_add_named_metadata_operand(m, cstr, val)
}

///| Add an operand to named metadata.
/// 
/// - see llvm::Module::getNamedMetadata()
/// - see llvm::MDNode::addOperand()
pub fn LLVMModuleRef::add_named_metadata_operand(self: LLVMModuleRef, name: String, val: LLVMValueRef) -> Unit {
  llvm_add_named_metadata_operand(self, name, val)
}

///| Return the directory of the debug location for this value.
///
/// Return the directory of the debug location for this value, which must be
/// an llvm::Instruction, llvm::GlobalVariable, or llvm::Function.
/// 
/// - see llvm::Instruction::getDebugLoc()
/// - see llvm::GlobalVariable::getDebugInfo()
/// - see llvm::Function::getSubprogram()
/// 
extern "C" fn __llvm_get_debug_loc_directory(val: LLVMValueRef) -> (CStr, UInt) = "__llvm_get_debug_loc_directory"

///| Return the directory of the debug location for this value.
///
/// Return the directory of the debug location for this value, which must be
/// an llvm::Instruction, llvm::GlobalVariable, or llvm::Function.
/// 
/// - see llvm::Instruction::getDebugLoc()
/// - see llvm::GlobalVariable::getDebugInfo()
/// - see llvm::Function::getSubprogram()
/// 
pub fn llvm_get_debug_loc_directory(val: LLVMValueRef) -> String {
  let (cstr, len) = __llvm_get_debug_loc_directory(val)
  c_str_to_moonbit_str_with_length(cstr, len)
}


///| Return the filename of the debug location for this value.
/// 
/// Return the filename of the debug location for this value, which must be
/// an llvm::Instruction, llvm::GlobalVariable, or llvm::Function.
/// 
/// - see llvm::Instruction::getDebugLoc()
/// - see llvm::GlobalVariable::getDebugInfo()
/// - see llvm::Function::getSubprogram()
/// 
pub extern "C" fn llvm_get_debug_loc_filename(val: LLVMValueRef) -> (CStr, UInt) = "__llvm_get_debug_loc_filename"

///| Return the filename of the debug location for this value.
/// 
/// Return the filename of the debug location for this value, which must be
/// an llvm::Instruction, llvm::GlobalVariable, or llvm::Function.
/// 
/// - see llvm::Instruction::getDebugLoc()
/// - see llvm::GlobalVariable::getDebugInfo()
/// - see llvm::Function::getSubprogram()
/// 
pub fn LLVMValueRef::get_debug_loc_filename(self: LLVMValueRef) -> String {
  let (cstr, len) = llvm_get_debug_loc_filename(self)
  c_str_to_moonbit_str_with_length(cstr, len)
}

///| Return the line number of the debug location for this value.
///
/// Return the line number of the debug location for this value, which must be
/// an llvm::Instruction, llvm::GlobalVariable, or llvm::Function.
/// 
/// - see llvm::Instruction::getDebugLoc()
/// - see llvm::GlobalVariable::getDebugInfo()
/// - see llvm::Function::getSubprogram()
pub extern "C" fn llvm_get_debug_loc_line(val: LLVMValueRef) -> UInt = "__llvm_get_debug_loc_line"

///| Return the line number of the debug location for this value.
///
/// Return the line number of the debug location for this value, which must be
/// an llvm::Instruction, llvm::GlobalVariable, or llvm::Function.
/// 
/// - see llvm::Instruction::getDebugLoc()
/// - see llvm::GlobalVariable::getDebugInfo()
/// - see llvm::Function::getSubprogram()
pub fn LLVMValueRef::get_debug_loc_line(self: LLVMValueRef) -> UInt {
  llvm_get_debug_loc_line(self)
}

///| Return the column number of the debug location for this value
///
/// Return the column number of the debug location for this value, which must be
/// an llvm::Instruction.
/// 
/// - see llvm::Instruction::getDebugLoc()
/// 
pub extern "C" fn llvm_get_debug_loc_column(val: LLVMValueRef) -> UInt = "__llvm_get_debug_loc_column"

///| Return the column number of the debug location for this value
///
/// Return the column number of the debug location for this value, which must be
/// an llvm::Instruction.
/// 
/// - see llvm::Instruction::getDebugLoc()
/// 
pub fn LLVMValueRef::get_debug_loc_column(self: LLVMValueRef) -> UInt {
  llvm_get_debug_loc_column(self)
}

///| Add a function to a module under a specified name.
/// 
/// - see llvm::Function::Create()
/// 
extern "C" fn __llvm_add_function(m: LLVMModuleRef, name: CStr, function_ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_add_function"
pub fn llvm_add_function(m: LLVMModuleRef, name: String, function_ty: LLVMTypeRef) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(name)
  __llvm_add_function(m, cstr, function_ty)
}

///| Add a function to a module under a specified name.
/// 
/// - see llvm::Function::Create()
/// 
pub fn LLVMModuleRef::add_function(self: LLVMModuleRef, name: String, function_ty: LLVMTypeRef) -> LLVMValueRef {
  llvm_add_function(self, name, function_ty)
}


///| Obtain a Function value from a Module by its name.
/// 
/// The returned value corresponds to a llvm::Function value.
/// 
/// - see llvm::Module::getFunction()
extern "C" fn __llvm_get_named_function(m: LLVMModuleRef, name: CStr) -> LLVMValueRef = "__llvm_get_named_function"

///| Obtain a Function value from a Module by its name.
/// 
/// The returned value corresponds to a llvm::Function value.
/// 
/// - see llvm::Module::getFunction()
pub fn llvm_get_named_function(m: LLVMModuleRef, name: String) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(name)
  __llvm_get_named_function(m, cstr)
}

///| Obtain a Function value from a Module by its name.
/// 
/// The returned value corresponds to a llvm::Function value.
/// 
/// - see llvm::Module::getFunction()
pub fn LLVMModuleRef::get_named_function(self: LLVMModuleRef, name: String) -> LLVMValueRef {
  llvm_get_named_function(self, name)
}

///| Obtain an iterator to the first Function in a Module.
/// 
/// - see llvm::Module::begin()
pub extern "C" fn llvm_get_first_function(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_first_function"
pub fn LLVMModuleRef::get_first_function(self: LLVMModuleRef) -> LLVMValueRef {
  llvm_get_first_function(self)
}


///| Obtain an iterator to the last Function in a Module.
/// 
/// - see llvm::Module::end()
/// 
pub extern "C" fn llvm_get_last_function(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_last_function"

///| Obtain an iterator to the last Function in a Module.
/// 
/// - see llvm::Module::end()
/// 
pub fn LLVMModuleRef::get_last_function(self: LLVMModuleRef) -> LLVMValueRef {
  llvm_get_last_function(self)
}

///| Advance a Function iterator to the next Function.
/// 
/// Returns NULL if the iterator was already at the end and there are no more
/// functions.
/// 
pub extern "C" fn llvm_get_next_function(func: LLVMValueRef) -> LLVMValueRef = "__llvm_get_next_function"

///| Advance a Function iterator to the next Function.
/// 
/// Returns NULL if the iterator was already at the end and there are no more
/// functions.
/// 
pub fn LLVMValueRef::get_next_function(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_next_function(self)
}


///| Decrement a Function iterator to the previous Function.
/// 
/// Returns NULL if the iterator was already at the beginning and there are
/// no previous functions.
/// 
pub extern "C" fn llvm_get_previous_function(func: LLVMValueRef) -> LLVMValueRef = "__llvm_get_previous_function"

///| Decrement a Function iterator to the previous Function.
/// 
/// Returns NULL if the iterator was already at the beginning and there are
/// no previous functions.
/// 
pub fn LLVMValueRef::get_previous_function(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_previous_function(self)
}


///| Obtain the enumerated type of a Type instance.
/// 
/// - see llvm::Type:getTypeID()
extern "C" fn __llvm_get_type_kind(ty: LLVMTypeRef) -> Int = "__llvm_get_type_kind"

///| Decrement a Function iterator to the previous Function.
/// 
/// Returns NULL if the iterator was already at the beginning and there are
/// no previous functions.
/// 
pub fn llvm_get_type_kind(ty: LLVMTypeRef) -> LLVMTypeKind {
  let idx = __llvm_get_type_kind(ty);
  LLVMTypeKind::from_int(idx)
}


///| Whether the type has a known size.
/// 
/// Things that don't have a size are abstract types, labels, and void.a
/// 
/// - see llvm::Type::isSized()
/// 
pub extern "C" fn llvm_type_is_sized(ty: LLVMTypeRef) -> LLVMBool = "__llvm_type_is_sized"

///| Whether the type has a known size.
/// 
/// Things that don't have a size are abstract types, labels, and void.a
/// 
/// - see llvm::Type::isSized()
/// 
pub fn LLVMTypeRef::is_sized(self: LLVMTypeRef) -> LLVMBool {
  llvm_type_is_sized(self)
}


///| Obtain the context to which this type instance is associated.
/// 
/// - see llvm::Type::getContext()
/// 
pub extern "C" fn llvm_get_type_context(ty: LLVMTypeRef) -> LLVMContextRef = "__llvm_get_type_context"

///| Obtain the context to which this type instance is associated.
/// 
/// - see llvm::Type::getContext()
/// 
pub fn LLVMTypeRef::get_context(self: LLVMTypeRef) -> LLVMContextRef {
  llvm_get_type_context(self)
}

///| Dump a representation of a type to stderr.
/// 
/// - see llvm::Type::dump()
/// 
pub extern "C" fn llvm_dump_type(val: LLVMTypeRef) = "__llvm_dump_type"

///| Dump a representation of a type to stderr.
/// 
/// - see llvm::Type::dump()
/// 
pub fn LLVMTypeRef::dump(self: LLVMTypeRef) -> Unit {
  llvm_dump_type(self)
}


///| Return a string representation of the type.
///
/// Return a string representation of the type. Use
/// LLVMDisposeMessage to free the string.
/// 
/// - see llvm::Type::print()
/// 
extern "C" fn __llvm_print_type_to_string(val: LLVMTypeRef) -> CStr = "__llvm_print_type_to_string"
pub fn llvm_print_type_to_string(val: LLVMTypeRef) -> String {
  let cstr = __llvm_print_type_to_string(val)
  c_str_to_moonbit_str(cstr)
}

///| Return a string representation of the type.
///
/// Return a string representation of the type. Use
/// LLVMDisposeMessage to free the string.
/// 
/// - see llvm::Type::print()
/// 
pub fn LLVMTypeRef::print_to_string(self: LLVMTypeRef) -> String {
  llvm_print_type_to_string(self)
}

///| Return a string representation of the type.
///
/// Return a string representation of the type. Use
/// LLVMDisposeMessage to free the string.
/// 
/// - see llvm::Type::print()
/// 
pub fn LLVMTypeRef::to_string(self: LLVMTypeRef) -> String {
  llvm_print_type_to_string(self)
}

///| Obtain an interger type with 1 bit.
pub extern "C" fn llvm_int1_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int1_type_in_context"

///| Obtain an interger type with 1 bit.
pub fn LLVMContextRef::int1_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_int1_type_in_context(self)
}

///| Obtain an interger type with 8 bits.
pub extern "C" fn llvm_int8_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int8_type_in_context"

///| Obtain an interger type with 8 bits.
pub fn LLVMContextRef::int8_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_int8_type_in_context(self)
}

///| Obtain an interger type with 16 bits.
pub extern "C" fn llvm_int16_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int16_type_in_context"

///| Obtain an interger type with 16 bits.
pub fn LLVMContextRef::int16_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_int16_type_in_context(self)
}

///| Obtain an interger type with 32 bits.
pub extern "C" fn llvm_int32_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int32_type_in_context"

///| Obtain an interger type with 32 bits.
pub fn LLVMContextRef::int32_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_int32_type_in_context(self)
}

///| Obtain an interger type with 64 bits.
pub extern "C" fn llvm_int64_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int64_type_in_context"

///| Obtain an interger type with 64 bits.
pub fn LLVMContextRef::int64_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_int64_type_in_context(self)
}

///| Obtain an interger type with 128 bits.
pub extern "C" fn llvm_int128_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int128_type_in_context"

///| Obtain an interger type with 128 bits.
pub fn LLVMContextRef::int128_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_int128_type_in_context(self)
}

///| Obtain an interger type with the specified number of bits.
pub extern "C" fn llvm_int_type_in_context(context: LLVMContextRef, num_bits: UInt) -> LLVMTypeRef = "__llvm_int_type_in_context"

///| Obtain an interger type with the specified number of bits.
pub fn LLVMContextRef::int_type(self: LLVMContextRef, num_bits: UInt) -> LLVMTypeRef {
  llvm_int_type_in_context(self, num_bits)
}

///| Obtain an integer type from the global context with 1 bit.
pub extern "C" fn llvm_int1_type() -> LLVMTypeRef = "__llvm_int1_type"

///| Obtain an integer type from the global context with 1 bit.
pub fn LLVMTypeRef::int1_type() -> LLVMTypeRef {
  llvm_int1_type()
}

///| Obtain an integer type from the global context with 8 bits.
pub extern "C" fn llvm_int8_type() -> LLVMTypeRef = "__llvm_int8_type"

///| Obtain an integer type from the global context with 8 bits.
pub fn LLVMTypeRef::int8_type() -> LLVMTypeRef {
  llvm_int8_type()
}

///| Obtain an integer type from the global context with 16 bits.
pub extern "C" fn llvm_int16_type() -> LLVMTypeRef = "__llvm_int16_type"

///| Obtain an integer type from the global context with 16 bits.
pub fn LLVMTypeRef::int16_type() -> LLVMTypeRef {
  llvm_int16_type()
}

///| Obtain an integer type from the global context with 32 bits.
pub extern "C" fn llvm_int32_type() -> LLVMTypeRef = "__llvm_int32_type"

///| Obtain an integer type from the global context with 32 bits.
pub fn LLVMTypeRef::int32_type() -> LLVMTypeRef {
  llvm_int32_type()
}

///| Obtain an integer type from the global context with 64 bits.
pub extern "C" fn llvm_int64_type() -> LLVMTypeRef = "__llvm_int64_type"

///| Obtain an integer type from the global context with 64 bits.
pub fn LLVMTypeRef::int64_type() -> LLVMTypeRef {
  llvm_int64_type()
}

///| Obtain an integer type from the global context with 128 bits.
pub extern "C" fn llvm_int128_type() -> LLVMTypeRef = "__llvm_int128_type"

///| Obtain an integer type from the global context with 128 bits.
pub fn LLVMTypeRef::int128_type() -> LLVMTypeRef {
  llvm_int128_type()
}

///| Obtain an integer type from the global context with the specified number of bits.
pub extern "C" fn llvm_int_type(num_bits: UInt) -> LLVMTypeRef = "__llvm_int_type"

///| Obtain an integer type from the global context with the specified number of bits.
pub fn LLVMTypeRef::int_type(num_bits: UInt) -> LLVMTypeRef {
  llvm_int_type(num_bits)
}

///| Return the number of bits in an integer type.
pub extern "C" fn llvm_get_int_type_width(integer_ty: LLVMTypeRef) -> UInt = "__llvm_get_int_type_width"

///| Return the number of bits in an integer type.
pub fn LLVMTypeRef::get_int_type_width(self: LLVMTypeRef) -> UInt {
  llvm_get_int_type_width(self)
}

///| Obtain a 16-bit floating point type from a context.
pub extern "C" fn llvm_half_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_half_type_in_context"

///| Obtain a 16-bit floating point type from a context.
pub fn LLVMContextRef::half_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_half_type_in_context(self)
}

///| Obtain a 16-bit brain floating point type from a context.
pub extern "C" fn llvm_bfloat_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_bfloat_type_in_context"

///| Obtain a 16-bit brain floating point type from a context.
pub fn LLVMContextRef::bfloat_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_bfloat_type_in_context(self)
}

///| Obtain a 32-bit floating point type from a context.
pub extern "C" fn llvm_float_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_float_type_in_context"

///| Obtain a 32-bit floating point type from a context.
pub fn LLVMContextRef::float_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_float_type_in_context(self)
}

///| Obtain a 64-bit floating point type from a context.
pub extern "C" fn llvm_double_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_double_type_in_context"

///| Obtain a 64-bit floating point type from a context.
pub fn LLVMContextRef::double_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_double_type_in_context(self)
}

///| Obtain a 80-bit floating point type (X87) from a context.
pub extern "C" fn llvm_x86_fp80_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_x86_fp80_type_in_context"

///| Obtain a 80-bit floating point type (X87) from a context.
pub fn LLVMContextRef::x86_fp80_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_x86_fp80_type_in_context(self)
}

///| Obtain a 128-bit floating point type (112-bit mantissa) from a context.
pub extern "C" fn llvm_fp128_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_fp128_type_in_context"

///| Obtain a 128-bit floating point type (112-bit mantissa) from a context.
pub fn LLVMContextRef::fp128_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_fp128_type_in_context(self)
}

///| Obtain a 128-bit floating point type (two 64-bits) from a context.
pub extern "C" fn llvm_ppc_fp128_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_ppc_fp128_type_in_context"

///| Obtain a 128-bit floating point type (two 64-bits) from a context.
pub fn LLVMContextRef::ppc_fp128_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_ppc_fp128_type_in_context(self)
}

///| Obtain a 16-bit floating point type from global context.
pub extern "C" fn llvm_half_type() -> LLVMTypeRef = "__llvm_half_type"

///| Obtain a 16-bit floating point type from global context.
pub fn LLVMTypeRef::half_type() -> LLVMTypeRef {
  llvm_half_type()
}

///| Obtain a 16-bit brain floating point type from global context.
pub extern "C" fn llvm_bfloat_type() -> LLVMTypeRef = "__llvm_bfloat_type"

///| Obtain a 16-bit brain floating point type from global context.
pub fn LLVMTypeRef::bfloat_type() -> LLVMTypeRef {
  llvm_bfloat_type()
}

///| Obtain a 32-bit floating point type from global context.
pub extern "C" fn llvm_float_type() -> LLVMTypeRef = "__llvm_float_type"

///| Obtain a 32-bit floating point type from global context.
pub fn LLVMTypeRef::float_type() -> LLVMTypeRef {
  llvm_float_type()
}

///| Obtain a 64-bit floating point type from global context.
pub extern "C" fn llvm_double_type() -> LLVMTypeRef = "__llvm_double_type"

///| Obtain a 64-bit floating point type from global context.
pub fn LLVMTypeRef::double_type() -> LLVMTypeRef {
  llvm_double_type()
}

///| Obtain a 80-bit floating point type (X87) from global context.
pub extern "C" fn llvm_x86_fp80_type() -> LLVMTypeRef = "__llvm_x86_fp80_type"

///| Obtain a 80-bit floating point type (X87) from global context.
pub fn LLVMTypeRef::x86_fp80_type() -> LLVMTypeRef {
  llvm_x86_fp80_type()
}

///| Obtain a 128-bit floating point type (112-bit mantissa) from global context.
pub extern "C" fn llvm_fp128_type() -> LLVMTypeRef = "__llvm_fp128_type"

///| Obtain a 128-bit floating point type (112-bit mantissa) from global context.
pub fn LLVMTypeRef::fp128_type() -> LLVMTypeRef {
  llvm_fp128_type()
}

///| Obtain a 128-bit floating point type (two 64-bits) from global context.
pub extern "C" fn llvm_ppc_fp128_type() -> LLVMTypeRef = "__llvm_ppc_fp128_type"

///| Obtain a 128-bit floating point type (two 64-bits) from global context.
pub fn LLVMTypeRef::ppc_fp128_type() -> LLVMTypeRef {
  llvm_ppc_fp128_type()
}

///| Obtain a function type consisting of a specified signature.
/// 
/// The function is defined as a tuple of a return Type, a list of
/// parameter types, and whether the function is variadic.
/// 
extern "C" fn __llvm_function_type(return_type: LLVMTypeRef, param_types: Array[LLVMTypeRef], is_var_arg: LLVMBool) -> LLVMTypeRef = "__llvm_function_type"

///| Obtain a function type consisting of a specified signature.
/// 
/// The function is defined as a tuple of a return Type, a list of
/// parameter types, and whether the function is variadic.
/// 
pub fn llvm_function_type(return_type: LLVMTypeRef, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> LLVMTypeRef {
  __llvm_function_type(return_type, param_types, to_llvm_bool(is_var_arg))
}

///| Obtain a function type consisting of a specified signature.
/// 
/// The function is defined as a tuple of a return Type, a list of
/// parameter types, and whether the function is variadic.
/// 
pub fn LLVMTypeRef::function_type(self: LLVMTypeRef, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> LLVMTypeRef {
  __llvm_function_type(self, param_types, to_llvm_bool(is_var_arg))
}

///| Returns whether a function type is variadic.
extern "C" fn __llvm_is_function_var_arg(function_ty: LLVMTypeRef) -> LLVMBool = "__llvm_is_function_var_arg"

///| Returns whether a function type is variadic.
pub fn llvm_is_function_var_arg(function_ty: LLVMTypeRef) -> Bool {
  __llvm_is_function_var_arg(function_ty).to_moonbit_bool()
}

///| Returns whether a function type is variadic.
pub fn LLVMTypeRef::is_function_var_arg(self: LLVMTypeRef) -> Bool {
  __llvm_is_function_var_arg(self).to_moonbit_bool()
}

///| Obtain the Type this function Type returns.
pub extern "C" fn llvm_get_return_type(function_ty: LLVMTypeRef) -> LLVMTypeRef = "__llvm_get_return_type"

///| Obtain the Type this function Type returns.
pub fn LLVMTypeRef::get_return_type(self: LLVMTypeRef) -> LLVMTypeRef {
  llvm_get_return_type(self)
}

///| Obtain the number of parameters this function accepts.
pub extern "C" fn llvm_count_param_types(function_ty: LLVMTypeRef) -> UInt = "__llvm_count_param_types"

///| Obtain the number of parameters this function accepts.
pub fn LLVMTypeRef::count_param_types(self: LLVMTypeRef) -> UInt {
  llvm_count_param_types(self)
}

///| Obtain the types of a function's parameters.
/// 
/// The Dest parameter should point to a pre-allocated array of
/// LLVMTypeRef at least LLVMCountParamTypes() large. On return, the
/// first LLVMCountParamTypes() entries in the array will be populated
/// with LLVMTypeRef instances.
/// 
/// - param FunctionTy The function type to operate on.
/// - param Dest Memory address of an array to be filled with result.
pub extern "C" fn llvm_get_param_types(function_ty: LLVMTypeRef) -> Array[LLVMTypeRef] = "__llvm_get_param_types"


///| Create a new structure type in a context.
/// 
/// A structure is specified by a list of inner elements/types and
/// whether these can be packed together.
/// 
/// - see llvm::StructType::create()
/// 
extern "C" fn __llvm_struct_type_in_context(context: LLVMContextRef, element_types: Array[LLVMTypeRef], packed: LLVMBool) -> LLVMTypeRef = "__llvm_struct_type_in_context"

///| Create a new structure type in a context.
/// 
/// A structure is specified by a list of inner elements/types and
/// whether these can be packed together.
/// 
/// - see llvm::StructType::create()
/// 
pub fn llvm_struct_type_in_context(context: LLVMContextRef, element_types: Array[LLVMTypeRef], packed: Bool) -> LLVMTypeRef {
  __llvm_struct_type_in_context(context, element_types, to_llvm_bool(packed))
}

///| Create a new structure type in a context.
/// 
/// A structure is specified by a list of inner elements/types and
/// whether these can be packed together.
/// 
/// - see llvm::StructType::create()
/// 
pub fn LLVMContextRef::struct_type(self: LLVMContextRef, element_types: Array[LLVMTypeRef], packed: Bool) -> LLVMTypeRef {
  __llvm_struct_type_in_context(self, element_types, to_llvm_bool(packed))
}

///| Create a new structure type in the global context.
/// 
/// - see llvm::StructType::create()
extern "C" fn __llvm_struct_type(element_types: Array[LLVMTypeRef], packed: LLVMBool) -> LLVMTypeRef = "__llvm_struct_type"

///| Create a new structure type in the global context.
/// 
/// - see llvm::StructType::create()
pub fn llvm_struct_type(element_types: Array[LLVMTypeRef], packed: Bool) -> LLVMTypeRef {
  __llvm_struct_type(element_types, to_llvm_bool(packed))
}

///| Create a new structure type in the global context.
/// 
/// - see llvm::StructType::create()
pub fn LLVMTypeRef::struct_type(element_types: Array[LLVMTypeRef], packed: Bool) -> LLVMTypeRef {
  __llvm_struct_type(element_types, to_llvm_bool(packed))
}

///| Create an empty structure in a context having a specified name.
/// 
/// - see llvm::StructType::create()
/// 
extern "C" fn __llvm_struct_create_named(context: LLVMContextRef, name: CStr) -> LLVMTypeRef = "__llvm_struct_create_named"

///| Create an empty structure in a context having a specified name.
/// 
/// - see llvm::StructType::create()
/// 
pub fn llvm_struct_create_named(context: LLVMContextRef, name: String) -> LLVMTypeRef {
  let cstr = moonbit_str_to_c_str(name)
  __llvm_struct_create_named(context, cstr)
}

///| Create an empty structure in a context having a specified name.
/// 
/// - see llvm::StructType::create()
/// 
pub fn LLVMContextRef::struct_create_named(self: LLVMContextRef, name: String) -> LLVMTypeRef {
  llvm_struct_create_named(self, name)
}

///| Obtain the name of a structure.
/// 
/// - see llvm::StructType::getName()
extern "C" fn __llvm_get_struct_name(ty: LLVMTypeRef) -> CStr = "__llvm_get_struct_name"

///| Obtain the name of a structure.
/// 
/// - see llvm::StructType::getName()
pub fn llvm_get_struct_name(ty: LLVMTypeRef) -> String {
  let cstr = __llvm_get_struct_name(ty)
  c_str_to_moonbit_str(cstr)
}

///| Obtain the name of a structure.
/// 
/// - see llvm::StructType::getName()
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

///| Get the number of elements defined inside the structure.
/// 
/// - see llvm::StructType::getNumElements()
/// 
pub extern "C" fn llvm_count_struct_element_types(struct_ty: LLVMTypeRef) -> UInt = "__llvm_count_struct_element_types"

///| Get the number of elements defined inside the structure.
/// 
/// - see llvm::StructType::getNumElements()
/// 
pub fn LLVMTypeRef::count_struct_element_types(self: LLVMTypeRef) -> UInt {
  llvm_count_struct_element_types(self)
}

///| Get the elements within a structure.
/// 
/// The function is passed the address of a pre-allocated array of
/// LLVMTypeRef at least LLVMCountStructElementTypes() long. After
/// invocation, this array will be populated with the structure's
/// elements. The objects in the destination array will have a lifetime
/// of the structure type itself, which is the lifetime of the context it
/// is contained in.
extern "C" fn __llvm_get_struct_element_types(
  struct_ty: LLVMTypeRef,
  num_fields: UInt,
  fields: Array[LLVMTypeRef]
)-> Array[LLVMTypeRef] = "__llvm_get_struct_element_types"

///| Get the elements within a structure.
/// 
/// The function is passed the address of a pre-allocated array of
/// LLVMTypeRef at least LLVMCountStructElementTypes() long. After
/// invocation, this array will be populated with the structure's
/// elements. The objects in the destination array will have a lifetime
/// of the structure type itself, which is the lifetime of the context it
/// is contained in.
pub fn llvm_get_struct_element_types(struct_ty: LLVMTypeRef)-> Array[LLVMTypeRef] {
  let field_count = llvm_count_struct_element_types(struct_ty)
  let null_ref = llvm_new_null_type_ref()
  // FIXME: Use `Array::make` once compiler bug is fixed
  let null_refs = LLVMTypeRef::make(field_count.reinterpret_as_int(), null_ref)
  __llvm_get_struct_element_types(struct_ty, field_count, null_refs)
}

///| Get the elements within a structure.
/// 
/// The function is passed the address of a pre-allocated array of
/// LLVMTypeRef at least LLVMCountStructElementTypes() long. After
/// invocation, this array will be populated with the structure's
/// elements. The objects in the destination array will have a lifetime
/// of the structure type itself, which is the lifetime of the context it
/// is contained in.
pub fn LLVMTypeRef::get_struct_element_types(self: LLVMTypeRef) -> Array[LLVMTypeRef] {
  llvm_get_struct_element_types(self)
}

///| Get the type of the element at a given index in the structure.
/// 
/// - see llvm::StructType::getTypeAtIndex()
/// 
pub extern "C" fn llvm_struct_get_type_at_index(struct_ty: LLVMTypeRef, i: UInt) -> LLVMTypeRef = "__llvm_struct_get_type_at_index"

///| Get the type of the element at a given index in the structure.
/// 
/// - see llvm::StructType::getTypeAtIndex()
/// 
pub fn LLVMTypeRef::get_type_at_index(self: LLVMTypeRef, i: UInt) -> LLVMTypeRef {
  llvm_struct_get_type_at_index(self, i)
}

///| Determine whether a structure is packed.
/// 
/// - see llvm::StructType::isPacked()
extern "C" fn __llvm_is_packed_struct(struct_ty: LLVMTypeRef) -> LLVMBool = "__llvm_is_packed_struct"

///| Determine whether a structure is packed.
/// 
/// - see llvm::StructType::isPacked()
pub fn llvm_is_packed_struct(struct_ty: LLVMTypeRef) -> Bool {
  __llvm_is_packed_struct(struct_ty).to_moonbit_bool()
}

///| Determine whether a structure is packed.
/// 
/// - see llvm::StructType::isPacked()
pub fn LLVMTypeRef::is_packed(self: LLVMTypeRef) -> Bool {
  __llvm_is_packed_struct(self).to_moonbit_bool()
}

///| Determine whether a structure is opaque.
/// 
/// - see llvm::StructType::isOpaque()
/// 
extern "C" fn __llvm_is_opaque_struct(struct_ty: LLVMTypeRef) -> LLVMBool = "__llvm_is_opaque_struct"

///| Determine whether a structure is opaque.
/// 
/// - see llvm::StructType::isOpaque()
/// 
pub fn llvm_is_opaque_struct(struct_ty: LLVMTypeRef) -> Bool {
  __llvm_is_opaque_struct(struct_ty).to_moonbit_bool()
}

///| Determine whether a structure is opaque.
/// 
/// - see llvm::StructType::isOpaque()
/// 
pub fn LLVMTypeRef::is_opaque_struct(self: LLVMTypeRef) -> Bool {
  __llvm_is_opaque_struct(self).to_moonbit_bool()
}

///| Determine whether a structure is literal.
/// 
/// - see llvm::StructType::isLiteral()
/// 
extern "C" fn __llvm_is_literal_struct(struct_ty: LLVMTypeRef) -> LLVMBool = "__llvm_is_literal_struct"

///| Determine whether a structure is literal.
/// 
/// - see llvm::StructType::isLiteral()
/// 
pub fn llvm_is_literal_struct(struct_ty: LLVMTypeRef) -> Bool {
  __llvm_is_literal_struct(struct_ty).to_moonbit_bool()
}

///| Determine whether a structure is literal.
/// 
/// - see llvm::StructType::isLiteral()
/// 
pub fn LLVMTypeRef::is_literal_struct(self: LLVMTypeRef) -> Bool {
  __llvm_is_literal_struct(self).to_moonbit_bool()
}

///| Obtain the element type of an array or vector type.
/// 
/// - see llvm::SequentialType::getElementType()
/// 
pub extern "C" fn llvm_get_element_type(ty: LLVMTypeRef) -> LLVMTypeRef = "__llvm_get_element_type"

///| Obtain the element type of an array or vector type.
/// 
/// - see llvm::SequentialType::getElementType()
/// 
pub fn LLVMTypeRef::get_element_type(self: LLVMTypeRef) -> LLVMTypeRef {
  llvm_get_element_type(self)
}

///| Returns type's subtypes
/// 
/// - see llvm::Type::subtypes()
// FIXME: Not implemented
pub extern "C" fn llvm_get_subtypes(tp: LLVMTypeRef) -> Array[LLVMTypeRef] = "__llvm_get_subtypes"

///| Returns type's subtypes
/// 
/// - see llvm::Type::subtypes()
pub fn LLVMTypeRef::get_subtypes(self: LLVMTypeRef) -> Array[LLVMTypeRef] {
  llvm_get_subtypes(self)
}

////| Return the number of types in the derived type.
/// 
/// - see llvm::Type::getNumContainedTypes()
/// 
pub extern "C" fn llvm_get_num_contained_types(tp: LLVMTypeRef) -> UInt = "__llvm_get_num_contained_types"

////| Return the number of types in the derived type.
/// 
/// - see llvm::Type::getNumContainedTypes()
/// 
pub fn LLVMTypeRef::get_num_contained_types(self: LLVMTypeRef) -> UInt {
  llvm_get_num_contained_types(self)
}

// TODO: soon to be removed
///| Create a fixed size array type that refers to a specific type.
/// 
/// The created type will exist in the context that its element type
/// exists in.
/// 
/// @deprecated LLVMArrayType is deprecated in favor of the API accurate
/// LLVMArrayType2
/// - see llvm::ArrayType::get()
/// 
pub extern "C" fn llvm_array_type(element_type: LLVMTypeRef, element_count: UInt) -> LLVMTypeRef = "__llvm_array_type"

///| Create a fixed size array type that refers to a specific type.
/// 
/// The created type will exist in the context that its element type
/// exists in.
/// 
/// @deprecated LLVMArrayType is deprecated in favor of the API accurate
/// LLVMArrayType2
/// - see llvm::ArrayType::get()
/// 
pub fn LLVMTypeRef::array_type(self: LLVMTypeRef, element_count: UInt) -> LLVMTypeRef {
  llvm_array_type(self, element_count)
}


///| Create a fixed size array type that refers to a specific type.
/// 
/// The created type will exist in the context that its element type
/// exists in.
/// 
/// - see llvm::ArrayType::get()
pub extern "C" fn llvm_array_type2(element_type: LLVMTypeRef, element_count: UInt64) -> LLVMTypeRef = "__llvm_array_type2"

///| Create a fixed size array type that refers to a specific type.
/// 
/// The created type will exist in the context that its element type
/// exists in.
/// 
/// - see llvm::ArrayType::get()
pub fn LLVMTypeRef::array_type2(self: LLVMTypeRef, element_count: UInt64) -> LLVMTypeRef {
  llvm_array_type2(self, element_count)
}

///| Obtain the length of an array type.
/// 
/// This only works on types that represent arrays.
/// 
/// @deprecated LLVMGetArrayLength is deprecated in favor of the API accurate
/// LLVMGetArrayLength2
/// - see llvm::ArrayType::getNumElements()
/// 
pub extern "C" fn llvm_get_array_length(array_ty: LLVMTypeRef) -> UInt = "__llvm_get_array_length"

///| Obtain the length of an array type.
/// 
/// This only works on types that represent arrays.
/// 
/// @deprecated LLVMGetArrayLength is deprecated in favor of the API accurate
/// LLVMGetArrayLength2
/// - see llvm::ArrayType::getNumElements()
/// 
pub fn LLVMTypeRef::get_array_length(self: LLVMTypeRef) -> UInt {
  llvm_get_array_length(self)
}

///| Obtain the length of an array type.
/// 
/// This only works on types that represent arrays.
/// 
/// - see llvm::ArrayType::getNumElements()
/// 
pub extern "C" fn llvm_get_array_length2(array_ty: LLVMTypeRef) -> UInt64 = "__llvm_get_array_length2"

///| Obtain the length of an array type.
/// 
/// This only works on types that represent arrays.
/// 
/// - see llvm::ArrayType::getNumElements()
/// 
pub fn LLVMTypeRef::get_array_length2(self: LLVMTypeRef) -> UInt64 {
  llvm_get_array_length2(self)
}


///| Create a pointer type that points to a defined type.
/// 
/// The created type will exist in the context that its pointee type
/// exists in.
/// 
/// - see llvm::PointerType::get()
/// 
pub extern "C" fn llvm_pointer_type(element_type: LLVMTypeRef, address_space: AddressSpace) -> LLVMTypeRef = "__llvm_pointer_type"

///| Create a pointer type that points to a defined type.
/// 
/// The created type will exist in the context that its pointee type
/// exists in.
/// 
/// - see llvm::PointerType::get()
/// 
pub fn LLVMTypeRef::pointer_type(self: LLVMTypeRef, address_space: AddressSpace) -> LLVMTypeRef {
  llvm_pointer_type(self, address_space)
}

///| Determine whether a pointer is opaque.
/// 
/// True if this is an instance of an opaque PointerType.
/// 
/// - see llvm::Type::isOpaquePointerTy()
/// 
extern "C" fn __llvm_pointer_type_is_opaque(ty: LLVMTypeRef) -> LLVMBool = "__llvm_pointer_type_is_opaque"

///| Determine whether a pointer is opaque.
/// 
/// True if this is an instance of an opaque PointerType.
/// 
/// - see llvm::Type::isOpaquePointerTy()
/// 
pub fn llvm_pointer_type_is_opaque(ty: LLVMTypeRef) -> Bool {
  __llvm_pointer_type_is_opaque(ty).to_moonbit_bool()
}

///| Determine whether a pointer is opaque.
/// 
/// True if this is an instance of an opaque PointerType.
/// 
/// - see llvm::Type::isOpaquePointerTy()
/// 
pub fn LLVMTypeRef::is_opaque_pointer(self: LLVMTypeRef) -> Bool {
  __llvm_pointer_type_is_opaque(self).to_moonbit_bool()
}

///| Create an opaque pointer type in a context.
/// 
/// - see llvm::PointerType::get()
/// 
pub extern "C" fn llvm_pointer_type_in_context(context: LLVMContextRef, address_space: AddressSpace) -> LLVMTypeRef = "__llvm_pointer_type_in_context"

///| Create an opaque pointer type in a context.
/// 
/// - see llvm::PointerType::get()
/// 
pub fn LLVMContextRef::pointer_type(self: LLVMContextRef, address_space: AddressSpace) -> LLVMTypeRef {
  llvm_pointer_type_in_context(self, address_space)
}

///| Obtain the address space of a pointer type.
/// 
/// This only works on types that represent pointers.
/// 
/// - see llvm::PointerType::getAddressSpace()
/// 
pub extern "C" fn llvm_get_pointer_address_space(pointer_ty: LLVMTypeRef) -> UInt = "__llvm_get_pointer_address_space"

///| Obtain the address space of a pointer type.
/// 
/// This only works on types that represent pointers.
/// 
/// - see llvm::PointerType::getAddressSpace()
/// 
pub fn LLVMTypeRef::get_pointer_address_space(self: LLVMTypeRef) -> UInt {
  llvm_get_pointer_address_space(self)
}


///| Create a vector type that contains a defined type and has a specific number of elements.
/// 
/// The created type will exist in the context thats its element type
/// exists in.
/// 
/// - see llvm::VectorType::get()
/// 
pub extern "C" fn llvm_vector_type(element_type: LLVMTypeRef, element_count: UInt) -> LLVMTypeRef = "__llvm_vector_type"

///| Create a vector type that contains a defined type and has a specific number of elements.
/// 
/// The created type will exist in the context thats its element type
/// exists in.
/// 
/// - see llvm::VectorType::get()
/// 
pub fn LLVMTypeRef::vector_type(self: LLVMTypeRef, element_count: UInt) -> LLVMTypeRef {
  llvm_vector_type(self, element_count)
}



///| Create a vector type that contains a defined type and has a scalable number of elements.
/// 
/// The created type will exist in the context thats its element type
/// exists in.
/// 
/// - see llvm::ScalableVectorType::get()
pub extern "C" fn llvm_scalable_vector_type(element_type: LLVMTypeRef, element_count: UInt) -> LLVMTypeRef = "__llvm_scalable_vector_type"

///| Create a vector type that contains a defined type and has a scalable number of elements.
/// 
/// The created type will exist in the context thats its element type
/// exists in.
/// 
/// - see llvm::ScalableVectorType::get()
pub fn LLVMTypeRef::scalable_vector_type(self: LLVMTypeRef, element_count: UInt) -> LLVMTypeRef {
  llvm_scalable_vector_type(self, element_count)
}


///| Obtain the (possibly scalable) number of elements in a vector type.
/// 
/// This only works on types that represent vectors (fixed or scalable).
/// 
/// - see llvm::VectorType::getNumElements()
pub extern "C" fn llvm_get_vector_size(vector_ty: LLVMTypeRef) -> UInt = "__llvm_get_vector_size"

///| Obtain the (possibly scalable) number of elements in a vector type.
/// 
/// This only works on types that represent vectors (fixed or scalable).
/// 
/// - see llvm::VectorType::getNumElements()
pub fn LLVMTypeRef::get_vector_size(self: LLVMTypeRef) -> UInt {
  llvm_get_vector_size(self)
}

///| Create a void type in a context.
pub extern "C" fn llvm_void_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_void_type_in_context"

///| Create a void type in a context.
pub fn LLVMContextRef::void_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_void_type_in_context(self)
}

///| Create a label type in a context.
pub extern "C" fn llvm_label_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_label_type_in_context"

///| Create a label type in a context.
pub fn LLVMContextRef::label_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_label_type_in_context(self)
}

///| Create an X86 AMX type in a context.
pub extern "C" fn llvm_x86_mmx_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_x86_mmx_type_in_context"

///| Create an X86 AMX type in a context.
pub fn LLVMContextRef::x86_mmx_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_x86_mmx_type_in_context(self)
}

///| Create an X86 AMX type in a context.
pub extern "C" fn llvm_x86_amx_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_x86_amx_type_in_context"

///| Create an X86 AMX type in a context.
pub fn LLVMContextRef::x86_amx_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_x86_amx_type_in_context(self)
}

///| Create a token type in a context.
pub extern "C" fn llvm_token_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_token_type_in_context"

///| Create a token type in a context.
pub fn LLVMContextRef::token_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_token_type_in_context(self)
}

///| Create a metadata type in a context.
pub extern "C" fn llvm_metadata_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_metadata_type_in_context"

///| Create a metadata type in a context.
pub fn LLVMContextRef::metadata_type(self: LLVMContextRef) -> LLVMTypeRef {
  llvm_metadata_type_in_context(self)
}

///| Create a void type in the global context.
pub extern "C" fn llvm_void_type() -> LLVMTypeRef = "__llvm_void_type"

///| Create a void type in the global context.
pub fn LLVMTypeRef::void_type() -> LLVMTypeRef {
  llvm_void_type()
}

///| Create a label type in the global context.
pub extern "C" fn llvm_label_type() -> LLVMTypeRef = "__llvm_label_type"

///| Create a label type in the global context.
pub fn LLVMTypeRef::label_type() -> LLVMTypeRef {
  llvm_label_type()
}

///| Create an X86 AMX type in the global context.
pub extern "C" fn llvm_x86_mmx_type() -> LLVMTypeRef = "__llvm_x86_mmx_type"

///| Create an X86 AMX type in the global context.
pub fn LLVMTypeRef::x86_mmx_type() -> LLVMTypeRef {
  llvm_x86_mmx_type()
}

///| Create an X86 AMX type in the global context.
pub extern "C" fn llvm_x86_amx_type() -> LLVMTypeRef = "__llvm_x86_amx_type"

///| Create an X86 AMX type in the global context.
pub fn LLVMTypeRef::x86_amx_type() -> LLVMTypeRef {
  llvm_x86_amx_type()
}

// Create a target extension type in LLVM context.
// LLVMTypeRef LLVMTargetExtTypeInContext(LLVMContextRef C, const char *Name,
//                                        LLVMTypeRef *TypeParams,
//                                        unsigned TypeParamCount,
//                                        unsigned *IntParams,
//                                        unsigned IntParamCount);

///| Obtain the name for this target extension type.
/// 
/// - see llvm::TargetExtType::getName()
/// 
extern "C" fn __llvm_get_target_ext_type_name(target_ext_ty: LLVMTypeRef) -> CStr = "__llvm_get_target_ext_type_name"

///| Obtain the name for this target extension type.
/// 
/// - see llvm::TargetExtType::getName()
/// 
pub fn llvm_get_target_ext_type_name(target_ext_ty: LLVMTypeRef) -> String {
  let cstr = __llvm_get_target_ext_type_name(target_ext_ty)
  c_str_to_moonbit_str(cstr)
}

///| Obtain the name for this target extension type.
/// 
/// - see llvm::TargetExtType::getName()
/// 
pub fn LLVMTypeRef::get_target_ext_type_name(self: LLVMTypeRef) -> String {
  llvm_get_target_ext_type_name(self)
}


///| Obtain the number of type parameters for this target extension type.
/// 
/// - see llvm::TargetExtType::getNumTypeParameters()
/// 
pub extern "C" fn llvm_get_target_ext_type_num_type_params(target_ext_ty: LLVMTypeRef) -> UInt = "__llvm_get_target_ext_type_num_type_params"

///| Obtain the number of type parameters for this target extension type.
/// 
/// - see llvm::TargetExtType::getNumTypeParameters()
/// 
pub fn LLVMTypeRef::get_target_ext_type_num_type_params(self: LLVMTypeRef) -> UInt {
  llvm_get_target_ext_type_num_type_params(self)
}


///| Get the type parameter at the given index for the target extension type.
/// 
/// - see llvm::TargetExtType::getTypeParameter()
/// 
pub extern "C" fn llvm_get_target_ext_type_type_param(target_ext_ty: LLVMTypeRef, idx: UInt) -> LLVMTypeRef = "__llvm_get_target_ext_type_type_param"

///| Get the type parameter at the given index for the target extension type.
/// 
/// - see llvm::TargetExtType::getTypeParameter()
/// 
pub fn LLVMTypeRef::get_target_ext_type_type_param(self: LLVMTypeRef, idx: UInt) -> LLVMTypeRef {
  llvm_get_target_ext_type_type_param(self, idx)
}

///| Obtain the number of int parameters for this target extension type.
/// 
/// - see llvm::TargetExtType::getNumIntParameters()
/// 
pub extern "C" fn llvm_get_target_ext_type_num_int_params(target_ext_ty: LLVMTypeRef) -> UInt = "__llvm_get_target_ext_type_num_int_params"

///| Obtain the number of int parameters for this target extension type.
/// 
/// - see llvm::TargetExtType::getNumIntParameters()
/// 
pub fn LLVMTypeRef::get_target_ext_type_num_int_params(self: LLVMTypeRef) -> UInt {
  llvm_get_target_ext_type_num_int_params(self)
}


///| Get the int parameter at the given index for the target extension type.
/// 
/// - see llvm::TargetExtType::getIntParameter()
/// 
pub extern "C" fn llvm_get_target_ext_type_int_param(target_ext_ty: LLVMTypeRef, idx: UInt) -> UInt = "__llvm_get_target_ext_type_int_param"

///| Get the int parameter at the given index for the target extension type.
/// 
/// - see llvm::TargetExtType::getIntParameter()
/// 
pub fn LLVMTypeRef::get_target_ext_type_int_param(self: LLVMTypeRef, idx: UInt) -> UInt {
  llvm_get_target_ext_type_int_param(self, idx)
}

///| Obtain the type of a value.
/// 
/// - see llvm::Value::getType()
pub extern "C" fn llvm_type_of(val: LLVMValueRef) -> LLVMTypeRef = "__llvm_type_of"

///| Obtain the type of a value.
/// 
/// - see llvm::Value::getType()
pub fn LLVMValueRef::get_type(self: LLVMValueRef) -> LLVMTypeRef {
  llvm_type_of(self)
}

/// Obtain the enumerated type of a Value instance.
/// 
/// - see llvm::Value::getValueID()
pub extern "C" fn llvm_get_value_kind(val: LLVMValueRef) -> LLVMValueKind = "__llvm_get_value_kind"

/// Obtain the enumerated type of a Value instance.
/// 
/// - see llvm::Value::getValueID()
pub fn LLVMValueRef::get_value_kind(self: LLVMValueRef) -> LLVMValueKind {
  llvm_get_value_kind(self)
}

///| Obtain the string name of a value.
/// 
/// - see llvm::Value::getName()
extern "C" fn __llvm_get_value_name2(val: LLVMValueRef) -> (CStr, UInt64) = "__llvm_get_value_name2"

///| Obtain the string name of a value.
/// 
/// - see llvm::Value::getName()
pub fn llvm_get_value_name(val: LLVMValueRef) -> String {
  let (cstr, len) = __llvm_get_value_name2(val)
  c_str_to_moonbit_str_with_length(cstr, len.to_uint())
}

///| Obtain the string name of a value.
/// 
///
pub fn LLVMValueRef::get_name(self: LLVMValueRef) -> String {
  llvm_get_value_name(self)
}

/// Set the string name of a value.
/// 
/// - see llvm::Value::setName()
extern "C" fn __llvm_set_value_name(val: LLVMValueRef, name: CStr, name_len: Int) = "__llvm_set_value_name2"

/// Set the string name of a value.
/// 
/// - see llvm::Value::setName()
pub fn llvm_set_value_name(val: LLVMValueRef, name: String) -> Unit {
  let cstr = moonbit_str_to_c_str(name)
  let len = name.length()
  __llvm_set_value_name(val, cstr, len)
}

/// Set the string name of a value.
/// 
/// - see llvm::Value::setName()
pub fn LLVMValueRef::set_name(self: LLVMValueRef, name: String) -> Unit {
  llvm_set_value_name(self, name)
}

///| Dump a representation of a value to stderr.
/// 
/// - see llvm::Value::dump()
pub extern "C" fn llvm_dump_value(val: LLVMValueRef) = "__llvm_dump_value"

///| Dump a representation of a value to stderr.
/// 
/// - see llvm::Value::dump()
pub fn LLVMValueRef::dump(self: LLVMValueRef) -> Unit {
  llvm_dump_value(self)
}

/// Return a string representation of the value. Use
/// LLVMDisposeMessage to free the string.
/// 
/// - see llvm::Value::print()
extern "C" fn __llvm_print_value_to_string(val: LLVMValueRef) -> CStr = "__llvm_print_value_to_string"

/// Return a string representation of the value. Use
/// LLVMDisposeMessage to free the string.
/// 
/// - see llvm::Value::print()
pub fn llvm_print_value_to_string(val: LLVMValueRef) -> String {
  let cstr = __llvm_print_value_to_string(val)
  c_str_to_moonbit_str(cstr)
}

/// Return a string representation of the value. Use
/// LLVMDisposeMessage to free the string.
/// 
/// - see llvm::Value::print()
pub fn LLVMValueRef::print(self: LLVMValueRef) -> String {
  llvm_print_value_to_string(self)
}

/// Return a string representation of the value. Use
/// LLVMDisposeMessage to free the string.
/// 
/// - see llvm::Value::print()
pub fn LLVMValueRef::to_string(self: LLVMValueRef) -> String {
  llvm_print_value_to_string(self)
}

///| Return a string representation of the DbgRecord. Use
/// LLVMDisposeMessage to free the string.
/// 
/// - see llvm::DbgRecord::print()
/// 
extern "C" fn __llvm_print_dbg_record_to_string(record: LLVMDbgRecordRef) -> CStr = "__llvm_print_dbg_record_to_string"

///| Return a string representation of the DbgRecord. Use
/// LLVMDisposeMessage to free the string.
/// 
/// - see llvm::DbgRecord::print()
/// 
pub fn llvm_print_dbg_record_to_string(record: LLVMDbgRecordRef) -> String {
  let cstr = __llvm_print_dbg_record_to_string(record)
  c_str_to_moonbit_str(cstr)
}

///| Return a string representation of the DbgRecord. Use
/// LLVMDisposeMessage to free the string.
/// 
/// - see llvm::DbgRecord::print()
/// 
pub fn LLVMDbgRecordRef::print(self: LLVMDbgRecordRef) -> String {
  llvm_print_dbg_record_to_string(self)
}

///| Return a string representation of the DbgRecord. Use
/// LLVMDisposeMessage to free the string.
/// 
/// - see llvm::DbgRecord::print()
/// 
pub fn LLVMDbgRecordRef::to_string(self: LLVMDbgRecordRef) -> String {
  llvm_print_dbg_record_to_string(self)
}


///| Replace all uses of a value with another one.
/// 
/// - see llvm::Value::replaceAllUsesWith()
/// 
pub extern "C" fn llvm_replace_all_uses_with(old_val: LLVMValueRef, new_val: LLVMValueRef) = "__llvm_replace_all_uses_with"

///| Replace all uses of a value with another one.
/// 
/// - see llvm::Value::replaceAllUsesWith()
/// 
pub fn LLVMValueRef::replace_all_uses_with(self: LLVMValueRef, new_val: LLVMValueRef) -> Unit {
  llvm_replace_all_uses_with(self, new_val)
}

///| Determine whether the specified value instance is constant.
extern "C" fn __llvm_is_constant(val: LLVMValueRef) -> LLVMBool = "__llvm_is_constant"

pub fn llvm_is_constant(val: LLVMValueRef) -> Bool {
  __llvm_is_constant(val).to_moonbit_bool()
}

///| Determine whether the specified value instance is constant.
pub fn LLVMValueRef::is_constant(self: LLVMValueRef) -> Bool {
  __llvm_is_constant(self).to_moonbit_bool()
}

///| Determine whether a value instance is undefined.
extern "C" fn __llvm_is_undef(val: LLVMValueRef) -> LLVMBool = "__llvm_is_undef"

///| Determine whether a value instance is undefined.
pub fn llvm_is_undef(val: LLVMValueRef) -> Bool {
  __llvm_is_undef(val).to_moonbit_bool()
}

///| Determine whether a value instance is undefined.
pub fn LLVMValueRef::is_undef(self: LLVMValueRef) -> Bool {
  __llvm_is_undef(self).to_moonbit_bool()
}

///| Determine whether a value instance is poisonous.
pub extern "C" fn llvm_is_poison(val: LLVMValueRef) -> LLVMBool = "__llvm_is_poison"

///| Determine whether a value instance is poisonous.
pub fn LLVMValueRef::is_poison(self: LLVMValueRef) -> LLVMBool {
  llvm_is_poison(self)
}

///| Convert value to argument, equivalent to `llvm::dyn_cast_or_null<Argument>`
pub extern "C" fn llvm_isa_argument(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_argument"

///| Convert value to argument, equivalent to `llvm::dyn_cast_or_null<Argument>`
pub fn LLVMValueRef::isa_argument(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_argument(self)
}

///| Convert value to basic block, equivalent to `llvm::dyn_cast_or_null<BasicBlock>`
pub extern "C" fn llvm_isa_basic_block(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_basic_block"

///| Convert value to basic block, equivalent to `llvm::dyn_cast_or_null<BasicBlock>`
pub fn LLVMValueRef::isa_basic_block(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_basic_block(self)
}

///| Convert value to inline asm, equivalent to `llvm::dyn_cast_or_null<InlineAsm>`
pub extern "C" fn llvm_isa_inline_asm(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_inline_asm"

///| Convert value to inline asm, equivalent to `llvm::dyn_cast_or_null<InlineAsm>`
pub fn LLVMValueRef::isa_inline_asm(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_inline_asm(self)
}

///| Convert value to user, equivalent to `llvm::dyn_cast_or_null<User>`
pub extern "C" fn llvm_isa_user(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_user"

///| Convert value to user, equivalent to `llvm::dyn_cast_or_null<User>`
pub fn LLVMValueRef::isa_user(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_user(self)
}

///| Convert value to constant, equivalent to `llvm::dyn_cast_or_null<Constant>`
pub extern "C" fn llvm_isa_constant(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant"

///| Convert value to constant, equivalent to `llvm::dyn_cast_or_null<Constant>`
pub fn LLVMValueRef::isa_constant(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant(self)
}

///| Convert value to block address, equivalent to `llvm::dyn_cast_or_null<BlockAddress>`
pub extern "C" fn llvm_isa_block_address(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_block_address"

///| Convert value to block address, equivalent to `llvm::dyn_cast_or_null<BlockAddress>`
pub fn LLVMValueRef::isa_block_address(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_block_address(self)
}

///| Convert value to constant aggregate zero, equivalent to `llvm::dyn_cast_or_null<ConstantAggregateZero>`
pub extern "C" fn llvm_isa_constant_aggregate_zero(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_aggregate_zero"

///| Convert value to constant aggregate zero, equivalent to `llvm::dyn_cast_or_null<ConstantAggregateZero>`
pub fn LLVMValueRef::isa_constant_aggregate_zero(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_aggregate_zero(self)
}

///| Convert value to constant array, equivalent to `llvm::dyn_cast_or_null<ConstantArray>`
pub extern "C" fn llvm_isa_constant_array(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_array"

///| Convert value to constant array, equivalent to `llvm::dyn_cast_or_null<ConstantArray>`
pub fn LLVMValueRef::isa_constant_array(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_array(self)
}

///| Convert value to constant data sequential, equivalent to `llvm::dyn_cast_or_null<ConstantDataSequential>`
pub extern "C" fn llvm_isa_constant_data_sequential(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_data_sequential"

///| Convert value to constant data sequential, equivalent to `llvm::dyn_cast_or_null<ConstantDataSequential>`
pub fn LLVMValueRef::isa_constant_data_sequential(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_data_sequential(self)
}

///| Convert value to constant data array, equivalent to `llvm::dyn_cast_or_null<ConstantDataArray>`
pub extern "C" fn llvm_isa_constant_data_array(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_data_array"

///| Convert value to constant data array, equivalent to `llvm::dyn_cast_or_null<ConstantDataArray>`
pub fn LLVMValueRef::isa_constant_data_array(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_data_array(self)
}

///| Convert value to constant data vector, equivalent to `llvm::dyn_cast_or_null<ConstantDataVector>`
pub extern "C" fn llvm_isa_constant_data_vector(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_data_vector"

///| Convert value to constant data vector, equivalent to `llvm::dyn_cast_or_null<ConstantDataVector>`
pub fn LLVMValueRef::isa_constant_data_vector(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_data_vector(self)
}

///| Convert value to constant expr, equivalent to `llvm::dyn_cast_or_null<ConstantExpr>`
pub extern "C" fn llvm_isa_constant_expr(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_expr"

///| Convert value to constant expr, equivalent to `llvm::dyn_cast_or_null<ConstantExpr>`
pub fn LLVMValueRef::isa_constant_expr(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_expr(self)
}

///| Convert value to constant fp, equivalent to `llvm::dyn_cast_or_null<ConstantFP>`
pub extern "C" fn llvm_isa_constant_fp(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_fp"

///| Convert value to constant fp, equivalent to `llvm::dyn_cast_or_null<ConstantFP>`
pub fn LLVMValueRef::isa_constant_fp(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_fp(self)
}

///| Convert value to constant int, equivalent to `llvm::dyn_cast_or_null<ConstantInt>`
pub extern "C" fn llvm_isa_constant_int(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_int"

///| Convert value to constant int, equivalent to `llvm::dyn_cast_or_null<ConstantInt>`
pub fn LLVMValueRef::isa_constant_int(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_int(self)
}

///| Convert value to constant pointer null, equivalent to `llvm::dyn_cast_or_null<ConstantPointerNull>`
pub extern "C" fn llvm_isa_constant_pointer_null(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_pointer_null"

///| Convert value to constant pointer null, equivalent to `llvm::dyn_cast_or_null<ConstantPointerNull>`
pub fn LLVMValueRef::isa_constant_pointer_null(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_pointer_null(self)
}


///| Convert value to constant struct, equivalent to `llvm::dyn_cast_or_null<ConstantStruct>`
pub extern "C" fn llvm_isa_constant_struct(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_struct"

///| Convert value to constant struct, equivalent to `llvm::dyn_cast_or_null<ConstantStruct>`
pub fn LLVMValueRef::isa_constant_struct(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_struct(self)
}

///| Convert value to constant token none, equivalent to `llvm::dyn_cast_or_null<ConstantTokenNone>`
pub extern "C" fn llvm_isa_constant_token_none(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_token_none"

///| Convert value to constant token none, equivalent to `llvm::dyn_cast_or_null<ConstantTokenNone>`
pub fn LLVMValueRef::isa_constant_token_none(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_token_none(self)
}


///| Convert value to constant vector, equivalent to `llvm::dyn_cast_or_null<ConstantVector>`
pub extern "C" fn llvm_isa_constant_vector(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_vector"

///| Convert value to constant vector, equivalent to `llvm::dyn_cast_or_null<ConstantVector>`
pub fn LLVMValueRef::isa_constant_vector(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_constant_vector(self)
}

///| Convert value to constant data, equivalent to `llvm::dyn_cast_or_null<ConstantData>`
pub extern "C" fn llvm_isa_global_value(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_value"

///| Convert value to constant data, equivalent to `llvm::dyn_cast_or_null<ConstantData>`
pub fn LLVMValueRef::isa_global_value(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_global_value(self)
}

///| Convert value to global alias, equivalent to `llvm::dyn_cast_or_null<GlobalAlias>`
pub extern "C" fn llvm_isa_global_alias(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_alias"

///| Convert value to global alias, equivalent to `llvm::dyn_cast_or_null<GlobalAlias>`
pub fn LLVMValueRef::isa_global_alias(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_global_alias(self)
}

///| Convert value to global object, equivalent to `llvm::dyn_cast_or_null<GlobalObject>`
pub extern "C" fn llvm_isa_global_object(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_object"

///| Convert value to global object, equivalent to `llvm::dyn_cast_or_null<GlobalObject>`
pub fn LLVMValueRef::isa_global_object(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_global_object(self)
}

///| Convert value to global variable, equivalent to `llvm::dyn_cast_or_null<GlobalVariable>`
pub extern "C" fn llvm_isa_function(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_function"

///| Convert value to global variable, equivalent to `llvm::dyn_cast_or_null<GlobalVariable>`
pub fn LLVMValueRef::isa_function(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_function(self)
}

///| Convert value to global variable, equivalent to `llvm::dyn_cast_or_null<GlobalVariable>`
pub extern "C" fn llvm_isa_global_variable(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_variable"

///| Convert value to global variable, equivalent to `llvm::dyn_cast_or_null<GlobalVariable>`
pub fn LLVMValueRef::isa_global_variable(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_global_variable(self)
}

///| Convert value to global ifunc, equivalent to `llvm::dyn_cast_or_null<GlobalIFunc>`
pub extern "C" fn llvm_isa_global_ifunc(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_ifunc"

///| Convert value to global ifunc, equivalent to `llvm::dyn_cast_or_null<GlobalIFunc>`
pub fn LLVMValueRef::isa_global_ifunc(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_global_ifunc(self)
}

///| Convert value to undef value, equivalent to `llvm::dyn_cast_or_null<UndefValue>`
pub extern "C" fn llvm_isa_undef_value(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_undef_value"

///| Convert value to undef value, equivalent to `llvm::dyn_cast_or_null<UndefValue>`
pub fn LLVMValueRef::isa_undef_value(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_undef_value(self)
}

///| Convert value to poison value, equivalent to `llvm::dyn_cast_or_null<PoisonValue>`
pub extern "C" fn llvm_isa_poison_value(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_poison_value"

///| Convert value to poison value, equivalent to `llvm::dyn_cast_or_null<PoisonValue>`
pub fn LLVMValueRef::isa_poison_value(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_poison_value(self)
}

///| Convert value to instruction, equivalent to `llvm::dyn_cast_or_null<Instruction>`
pub extern "C" fn llvm_isa_instruction(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_instruction"

///| Convert value to instruction, equivalent to `llvm::dyn_cast_or_null<Instruction>`
pub fn LLVMValueRef::isa_instruction(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_instruction(self)
}

///| Convert value to unary operator, equivalent to `llvm::dyn_cast_or_null<UnaryOperator>`
pub extern "C" fn llvm_isa_unary_operator(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_unary_operator"

///| Convert value to unary operator, equivalent to `llvm::dyn_cast_or_null<UnaryOperator>`
pub fn LLVMValueRef::isa_unary_operator(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_unary_operator(self)
}

///| Convert value to binary operator, equivalent to `llvm::dyn_cast_or_null<BinaryOperator>`
pub extern "C" fn llvm_isa_binary_operator(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_binary_operator"

///| Convert value to binary operator, equivalent to `llvm::dyn_cast_or_null<BinaryOperator>`
pub fn LLVMValueRef::isa_binary_operator(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_binary_operator(self)
}

///| Convert value to cast instruction, equivalent to `llvm::dyn_cast_or_null<CastInst>`
pub extern "C" fn llvm_isa_call_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_call_inst"

///| Convert value to cast instruction, equivalent to `llvm::dyn_cast_or_null<CastInst>`
pub fn LLVMValueRef::isa_call_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_call_inst(self)
}

///| Convert value to intrinsic instruction, equivalent to `llvm::dyn_cast_or_null<IntrinsicInst>`
pub extern "C" fn llvm_isa_intrinsic_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_intrinsic_inst"

///| Convert value to intrinsic instruction, equivalent to `llvm::dyn_cast_or_null<IntrinsicInst>`
pub fn LLVMValueRef::isa_intrinsic_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_intrinsic_inst(self)
}

///| Convert value to debug info intrinsic, equivalent to `llvm::dyn_cast_or_null<DbgInfoIntrinsic>`
pub extern "C" fn llvm_isa_dbg_info_intrinsic(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_dbg_info_intrinsic"

///| Convert value to debug info intrinsic, equivalent to `llvm::dyn_cast_or_null<DbgInfoIntrinsic>`
pub fn LLVMValueRef::isa_dbg_info_intrinsic(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_dbg_info_intrinsic(self)
}

///| Convert value to debug variable intrinsic, equivalent to `llvm::dyn_cast_or_null<DbgVariableIntrinsic>`
pub extern "C" fn llvm_isa_dbg_variable_intrinsic(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_dbg_variable_intrinsic"

///| Convert value to debug variable intrinsic, equivalent to `llvm::dyn_cast_or_null<DbgVariableIntrinsic>`
pub fn LLVMValueRef::isa_dbg_variable_intrinsic(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_dbg_variable_intrinsic(self)
}

///| Convert value to dbg declare inst, equivalent to `llvm::dyn_cast_or_null<DbgDeclareInst>`
pub extern "C" fn llvm_isa_dbg_declare_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_dbg_declare_inst"

///| Convert value to dbg declare inst, equivalent to `llvm::dyn_cast_or_null<DbgDeclareInst>`
pub fn LLVMValueRef::isa_dbg_declare_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_dbg_declare_inst(self)
}

///| Convert value to dbg label inst, equivalent to `llvm::dyn_cast_or_null<DbgLabelInst>`
pub extern "C" fn llvm_isa_dbg_label_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_dbg_label_inst"

///| Convert value to dbg label inst, equivalent to `llvm::dyn_cast_or_null<DbgLabelInst>`
pub fn LLVMValueRef::isa_dbg_label_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_dbg_label_inst(self)
}

///| Convert value to memory intrinsic, equivalent to `llvm::dyn_cast_or_null<MemIntrinsic>`
pub extern "C" fn llvm_isa_mem_intrinsic(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_mem_intrinsic"

///| Convert value to memory intrinsic, equivalent to `llvm::dyn_cast_or_null<MemIntrinsic>`
pub fn LLVMValueRef::isa_mem_intrinsic(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_mem_intrinsic(self)
}

///| Convert value to memory copy inst, equivalent to `llvm::dyn_cast_or_null<MemCpyInst>`
pub extern "C" fn llvm_isa_mem_cpy_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_mem_cpy_inst"

///| Convert value to memory copy inst, equivalent to `llvm::dyn_cast_or_null<MemCpyInst>`
pub fn LLVMValueRef::isa_mem_cpy_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_mem_cpy_inst(self)
}

///| Convert value to memory move inst, equivalent to `llvm::dyn_cast_or_null<MemMoveInst>`
pub extern "C" fn llvm_isa_mem_move_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_mem_move_inst"

///| Convert value to memory move inst, equivalent to `llvm::dyn_cast_or_null<MemMoveInst>`
pub fn LLVMValueRef::isa_mem_move_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_mem_move_inst(self)
}

///| Convert value to memory set inst, equivalent to `llvm::dyn_cast_or_null<MemSetInst>`
pub extern "C" fn llvm_isa_mem_set_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_mem_set_inst"

///| Convert value to memory set inst, equivalent to `llvm::dyn_cast_or_null<MemSetInst>`
pub fn LLVMValueRef::isa_mem_set_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_mem_set_inst(self)
}

///| Convert value to compare instruction, equivalent to `llvm::dyn_cast_or_null<CmpInst>`
pub extern "C" fn llvm_isa_cmp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_cmp_inst"

///| Convert value to compare instruction, equivalent to `llvm::dyn_cast_or_null<CmpInst>`
pub fn LLVMValueRef::isa_cmp_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_cmp_inst(self)
}

///| Convert value to float compare instruction, equivalent to `llvm::dyn_cast_or_null<FCmpInst>`
pub extern "C" fn llvm_isa_f_cmp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_f_cmp_inst"

///| Convert value to float compare instruction, equivalent to `llvm::dyn_cast_or_null<FCmpInst>`
pub fn LLVMValueRef::isa_f_cmp_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_f_cmp_inst(self)
}

///| Convert value to integer compare instruction, equivalent to `llvm::dyn_cast_or_null<ICmpInst>`
pub extern "C" fn llvm_isa_i_cmp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_i_cmp_inst"

///| Convert value to integer compare instruction, equivalent to `llvm::dyn_cast_or_null<ICmpInst>`
pub fn LLVMValueRef::isa_i_cmp_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_i_cmp_inst(self)
}

///| Convert value to extract element inst, equivalent to `llvm::dyn_cast_or_null<ExtractElementInst>`
pub extern "C" fn llvm_isa_extract_element_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_extract_element_inst"

///| Convert value to extract element inst, equivalent to `llvm::dyn_cast_or_null<ExtractElementInst>`
pub fn LLVMValueRef::isa_extract_element_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_extract_element_inst(self)
}

///| Convert value to extract value inst, equivalent to `llvm::dyn_cast_or_null<ExtractValueInst>`
pub extern "C" fn llvm_isa_get_element_ptr_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_get_element_ptr_inst"

///| Convert value to extract value inst, equivalent to `llvm::dyn_cast_or_null<ExtractValueInst>`
pub fn LLVMValueRef::isa_get_element_ptr_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_get_element_ptr_inst(self)
}

///| Convert value to insert element inst, equivalent to `llvm::dyn_cast_or_null<InsertElementInst>`
pub extern "C" fn llvm_isa_insert_element_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_insert_element_inst"

///| Convert value to insert element inst, equivalent to `llvm::dyn_cast_or_null<InsertElementInst>`
pub fn LLVMValueRef::isa_insert_element_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_insert_element_inst(self)
}

///| Convert value to insert value inst, equivalent to `llvm::dyn_cast_or_null<InsertValueInst>`
pub extern "C" fn llvm_isa_insert_value_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_insert_value_inst"

///| Convert value to insert value inst, equivalent to `llvm::dyn_cast_or_null<InsertValueInst>`
pub fn LLVMValueRef::isa_insert_value_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_insert_value_inst(self)
}

///| Convert value to landing pad inst, equivalent to `llvm::dyn_cast_or_null<LandingPadInst>`
pub extern "C" fn llvm_isa_landing_pad_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_landing_pad_inst"

///| Convert value to landing pad inst, equivalent to `llvm::dyn_cast_or_null<LandingPadInst>`
pub fn LLVMValueRef::isa_landing_pad_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_landing_pad_inst(self)
}

///| Convert value to phi node, equivalent to `llvm::dyn_cast_or_null<PHINode>`
pub extern "C" fn llvm_isa_phi_node(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_phi_node"

///| Convert value to phi node, equivalent to `llvm::dyn_cast_or_null<PHINode>`
pub fn LLVMValueRef::isa_phi_node(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_phi_node(self)
}

///| Convert value to select inst, equivalent to `llvm::dyn_cast_or_null<SelectInst>`
pub extern "C" fn llvm_isa_select_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_select_inst"

///| Convert value to select inst, equivalent to `llvm::dyn_cast_or_null<SelectInst>`
pub fn LLVMValueRef::isa_select_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_select_inst(self)
}

///| Convert value to shuffle vector inst, equivalent to `llvm::dyn_cast_or_null<ShuffleVectorInst>`
pub extern "C" fn llvm_isa_shuffle_vector_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_shuffle_vector_inst"

///| Convert value to shuffle vector inst, equivalent to `llvm::dyn_cast_or_null<ShuffleVectorInst>`
pub fn LLVMValueRef::isa_shuffle_vector_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_shuffle_vector_inst(self)
}

///| Convert value to store inst, equivalent to `llvm::dyn_cast_or_null<StoreInst>`
pub extern "C" fn llvm_isa_store_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_store_inst"

///| Convert value to store inst, equivalent to `llvm::dyn_cast_or_null<StoreInst>`
pub fn LLVMValueRef::isa_store_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_store_inst(self)
}

///| Convert value to branch inst, equivalent to `llvm::dyn_cast_or_null<BranchInst>`
pub extern "C" fn llvm_isa_branch_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_branch_inst"

///| Convert value to branch inst, equivalent to `llvm::dyn_cast_or_null<BranchInst>`
pub fn LLVMValueRef::isa_branch_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_branch_inst(self)
}

///| Convert value to indirect branch inst, equivalent to `llvm::dyn_cast_or_null<IndirectBrInst>`
pub extern "C" fn llvm_isa_indirect_br_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_indirect_br_inst"

///| Convert value to indirect branch inst, equivalent to `llvm::dyn_cast_or_null<IndirectBrInst>`
pub fn LLVMValueRef::isa_indirect_br_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_indirect_br_inst(self)
}

///| Convert value to invoke inst, equivalent to `llvm::dyn_cast_or_null<InvokeInst>`
pub extern "C" fn llvm_isa_invoke_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_invoke_inst"

///| Convert value to invoke inst, equivalent to `llvm::dyn_cast_or_null<InvokeInst>`
pub fn LLVMValueRef::isa_invoke_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_invoke_inst(self)
}

///| Convert value to return inst, equivalent to `llvm::dyn_cast_or_null<ReturnInst>`
pub extern "C" fn llvm_isa_return_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_return_inst"

///| Convert value to return inst, equivalent to `llvm::dyn_cast_or_null<ReturnInst>`
pub fn LLVMValueRef::isa_return_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_return_inst(self)
}

///| Convert value to switch inst, equivalent to `llvm::dyn_cast_or_null<SwitchInst>`
pub extern "C" fn llvm_isa_switch_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_switch_inst"

///| Convert value to switch inst, equivalent to `llvm::dyn_cast_or_null<SwitchInst>`
pub fn LLVMValueRef::isa_switch_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_switch_inst(self)
}

///| Convert value to unreachable inst, equivalent to `llvm::dyn_cast_or_null<UnreachableInst>`
pub extern "C" fn llvm_isa_unreachable_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_unreachable_inst"

///| Convert value to unreachable inst, equivalent to `llvm::dyn_cast_or_null<UnreachableInst>`
pub fn LLVMValueRef::isa_unreachable_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_unreachable_inst(self)
}

///| Convert value to resume inst, equivalent to `llvm::dyn_cast_or_null<ResumeInst>`
pub extern "C" fn llvm_isa_resume_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_resume_inst"

///| Convert value to resume inst, equivalent to `llvm::dyn_cast_or_null<ResumeInst>`
pub fn LLVMValueRef::isa_resume_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_resume_inst(self)
}

///| Convert value to cleanup return inst, equivalent to `llvm::dyn_cast_or_null<CleanupReturnInst>`
pub extern "C" fn llvm_isa_cleanup_return_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_cleanup_return_inst"

///| Convert value to cleanup return inst, equivalent to `llvm::dyn_cast_or_null<CleanupReturnInst>`
pub fn LLVMValueRef::isa_cleanup_return_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_cleanup_return_inst(self)
}

///| Convert value to catch return inst, equivalent to `llvm::dyn_cast_or_null<CatchReturnInst>`
pub extern "C" fn llvm_isa_catch_return_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_catch_return_inst"

///| Convert value to catch return inst, equivalent to `llvm::dyn_cast_or_null<CatchReturnInst>`
pub fn LLVMValueRef::isa_catch_return_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_catch_return_inst(self)
}

///| Convert value to catch switch inst, equivalent to `llvm::dyn_cast_or_null<CatchSwitchInst>`
pub extern "C" fn llvm_isa_catch_switch_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_catch_switch_inst"

///| Convert value to catch switch inst, equivalent to `llvm::dyn_cast_or_null<CatchSwitchInst>`
pub fn LLVMValueRef::isa_catch_switch_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_catch_switch_inst(self)
}

///| Convert value to call br inst, equivalent to `llvm::dyn_cast_or_null<CallBrInst>`
pub extern "C" fn llvm_isa_call_br_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_call_br_inst"

///| Convert value to call br inst, equivalent to `llvm::dyn_cast_or_null<CallBrInst>`
pub fn LLVMValueRef::isa_call_br_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_call_br_inst(self)
}

///| Convert value to funclet pad inst, equivalent to `llvm::dyn_cast_or_null<FuncletPadInst>`
pub extern "C" fn llvm_isa_funclet_pad_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_funclet_pad_inst"

///| Convert value to funclet pad inst, equivalent to `llvm::dyn_cast_or_null<FuncletPadInst>`
pub fn LLVMValueRef::isa_funclet_pad_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_funclet_pad_inst(self)
}

///| Convert value to catch pad inst, equivalent to `llvm::dyn_cast_or_null<CatchPadInst>`
pub extern "C" fn llvm_isa_catch_pad_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_catch_pad_inst"

///| Convert value to catch pad inst, equivalent to `llvm::dyn_cast_or_null<CatchPadInst>`
pub fn LLVMValueRef::isa_catch_pad_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_catch_pad_inst(self)
}

///| Convert value to cleanup pad inst, equivalent to `llvm::dyn_cast_or_null<CleanupPadInst>`
pub extern "C" fn llvm_isa_cleanup_pad_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_cleanup_pad_inst"

///| Convert value to cleanup pad inst, equivalent to `llvm::dyn_cast_or_null<CleanupPadInst>`
pub fn LLVMValueRef::isa_cleanup_pad_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_cleanup_pad_inst(self)
}

///| Convert value to unary instruction, equivalent to `llvm::dyn_cast_or_null<UnaryInstruction>`
pub extern "C" fn llvm_isa_unary_instruction(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_unary_instruction"

///| Convert value to unary instruction, equivalent to `llvm::dyn_cast_or_null<UnaryInstruction>`
pub fn LLVMValueRef::isa_unary_instruction(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_unary_instruction(self)
}

///| Convert value to alloca inst, equivalent to `llvm::dyn_cast_or_null<AllocaInst>`
pub extern "C" fn llvm_isa_alloca_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_alloca_inst"

///| Convert value to alloca inst, equivalent to `llvm::dyn_cast_or_null<AllocaInst>`
pub fn LLVMValueRef::isa_alloca_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_alloca_inst(self)
}

///| Convert value to cast inst, equivalent to `llvm::dyn_cast_or_null<CastInst>`
pub extern "C" fn llvm_isa_cast_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_cast_inst"

///| Convert value to cast inst, equivalent to `llvm::dyn_cast_or_null<CastInst>`
pub fn LLVMValueRef::isa_cast_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_cast_inst(self)
}

///| Convert value to addr space cast inst, equivalent to `llvm::dyn_cast_or_null<AddrSpaceCastInst>`
pub extern "C" fn llvm_isa_addr_space_cast_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_addr_space_cast_inst"

///| Convert value to addr space cast inst, equivalent to `llvm::dyn_cast_or_null<AddrSpaceCastInst>`
pub fn LLVMValueRef::isa_addr_space_cast_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_addr_space_cast_inst(self)
}

///| Convert value to bit cast inst, equivalent to `llvm::dyn_cast_or_null<BitCastInst>`
pub extern "C" fn llvm_isa_bit_cast_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_bit_cast_inst"

///| Convert value to bit cast inst, equivalent to `llvm::dyn_cast_or_null<BitCastInst>`
pub fn LLVMValueRef::isa_bit_cast_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_bit_cast_inst(self)
}

///| Convert value to fp ext inst, equivalent to `llvm::dyn_cast_or_null<FPExtInst>`
pub extern "C" fn llvm_isa_fp_ext_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fp_ext_inst"

///| Convert value to fp ext inst, equivalent to `llvm::dyn_cast_or_null<FPExtInst>`
pub fn LLVMValueRef::isa_fp_ext_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_fp_ext_inst(self)
}

///| Convert value to fp to si inst, equivalent to `llvm::dyn_cast_or_null<FPToSIInst>`
pub extern "C" fn llvm_isa_fp_to_si_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fp_to_si_inst"

///| Convert value to fp to si inst, equivalent to `llvm::dyn_cast_or_null<FPToSIInst>`
pub fn LLVMValueRef::isa_fp_to_si_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_fp_to_si_inst(self)
}

///| Convert value to fp to ui inst, equivalent to `llvm::dyn_cast_or_null<FPToUIInst>`
pub extern "C" fn llvm_isa_fp_to_ui_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fp_to_ui_inst"

///| Convert value to fp to ui inst, equivalent to `llvm::dyn_cast_or_null<FPToUIInst>`
pub fn LLVMValueRef::isa_fp_to_ui_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_fp_to_ui_inst(self)
}

///| Convert value to fp trunc inst, equivalent to `llvm::dyn_cast_or_null<FPTruncInst>`
pub extern "C" fn llvm_isa_fp_trunc_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fp_trunc_inst"

///| Convert value to fp trunc inst, equivalent to `llvm::dyn_cast_or_null<FPTruncInst>`
pub fn LLVMValueRef::isa_fp_trunc_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_fp_trunc_inst(self)
}

///| Convert value to int to ptr inst, equivalent to `llvm::dyn_cast_or_null<IntToPtrInst>`
pub extern "C" fn llvm_isa_int_to_ptr_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_int_to_ptr_inst"

///| Convert value to int to ptr inst, equivalent to `llvm::dyn_cast_or_null<IntToPtrInst>`
pub fn LLVMValueRef::isa_int_to_ptr_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_int_to_ptr_inst(self)
}

///| Convert value to ptr to int inst, equivalent to `llvm::dyn_cast_or_null<PtrToIntInst>`
pub extern "C" fn llvm_isa_ptr_to_int_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_ptr_to_int_inst"

///| Convert value to ptr to int inst, equivalent to `llvm::dyn_cast_or_null<PtrToIntInst>`
pub fn LLVMValueRef::isa_ptr_to_int_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_ptr_to_int_inst(self)
}

///| Convert value to sext inst, equivalent to `llvm::dyn_cast_or_null<SExtInst>`
pub extern "C" fn llvm_isa_sext_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_sext_inst"

///| Convert value to sext inst, equivalent to `llvm::dyn_cast_or_null<SExtInst>`
pub fn LLVMValueRef::isa_sext_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_sext_inst(self)
}

///| Convert value to si to fp inst, equivalent to `llvm::dyn_cast_or_null<SIToFPInst>`
pub extern "C" fn llvm_isa_si_to_fp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_si_to_fp_inst"

///| Convert value to si to fp inst, equivalent to `llvm::dyn_cast_or_null<SIToFPInst>`
pub fn LLVMValueRef::isa_si_to_fp_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_si_to_fp_inst(self)
}

///| Convert value to trunc inst, equivalent to `llvm::dyn_cast_or_null<TruncInst>`
pub extern "C" fn llvm_isa_trunc_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_trunc_inst"

///| Convert value to trunc inst, equivalent to `llvm::dyn_cast_or_null<TruncInst>`
pub fn LLVMValueRef::isa_trunc_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_trunc_inst(self)
}

///| Convert value to ui to fp inst, equivalent to `llvm::dyn_cast_or_null<UIToFPInst>`
pub extern "C" fn llvm_isa_ui_to_fp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_ui_to_fp_inst"

///| Convert value to ui to fp inst, equivalent to `llvm::dyn_cast_or_null<UIToFPInst>`
pub fn LLVMValueRef::isa_ui_to_fp_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_ui_to_fp_inst(self)
}

///| Convert value to z ext inst, equivalent to `llvm::dyn_cast_or_null<ZExtInst>`
pub extern "C" fn llvm_isa_z_ext_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_z_ext_inst"

///| Convert value to z ext inst, equivalent to `llvm::dyn_cast_or_null<ZExtInst>`
pub fn LLVMValueRef::isa_z_ext_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_z_ext_inst(self)
}

///| Convert value to extract value inst, equivalent to `llvm::dyn_cast_or_null<ExtractValueInst>`
pub extern "C" fn llvm_isa_extract_value_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_extract_value_inst"

///| Convert value to extract value inst, equivalent to `llvm::dyn_cast_or_null<ExtractValueInst>`
pub fn LLVMValueRef::isa_extract_value_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_extract_value_inst(self)
}

///| Convert value to load inst, equivalent to `llvm::dyn_cast_or_null<LoadInst>`
pub extern "C" fn llvm_isa_load_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_load_inst"

///| Convert value to load inst, equivalent to `llvm::dyn_cast_or_null<LoadInst>`
pub fn LLVMValueRef::isa_load_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_load_inst(self)
}

///| Convert value to va arg inst, equivalent to `llvm::dyn_cast_or_null<VAArgInst>`
pub extern "C" fn llvm_isa_va_arg_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_va_arg_inst"

///| Convert value to va arg inst, equivalent to `llvm::dyn_cast_or_null<VAArgInst>`
pub fn LLVMValueRef::isa_va_arg_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_va_arg_inst(self)
}

///| Convert value to freeze inst, equivalent to `llvm::dyn_cast_or_null<FreezeInst>`
pub extern "C" fn llvm_isa_freeze_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_freeze_inst"

///| Convert value to freeze inst, equivalent to `llvm::dyn_cast_or_null<FreezeInst>`
pub fn LLVMValueRef::isa_freeze_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_freeze_inst(self)
}

///| Convert value to atomic cmp xchg inst, equivalent to `llvm::dyn_cast_or_null<AtomicCmpXchgInst>`
pub extern "C" fn llvm_isa_atomic_cmp_xchg_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_atomic_cmp_xchg_inst"

///| Convert value to atomic cmp xchg inst, equivalent to `llvm::dyn_cast_or_null<AtomicCmpXchgInst>`
pub fn LLVMValueRef::isa_atomic_cmp_xchg_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_atomic_cmp_xchg_inst(self)
}

///| Convert value to atomic rmw inst, equivalent to `llvm::dyn_cast_or_null<AtomicRMWInst>`
pub extern "C" fn llvm_isa_atomic_rmw_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_atomic_rmw_inst"

///| Convert value to atomic rmw inst, equivalent to `llvm::dyn_cast_or_null<AtomicRMWInst>`
pub fn LLVMValueRef::isa_atomic_rmw_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_atomic_rmw_inst(self)
}

///| Convert value to fence inst, equivalent to `llvm::dyn_cast_or_null<FenceInst>`
pub extern "C" fn llvm_isa_fence_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fence_inst"

///| Convert value to fence inst, equivalent to `llvm::dyn_cast_or_null<FenceInst>`
pub fn LLVMValueRef::isa_fence_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_fence_inst(self)
}

///| Convert value to md node, equivalent to `llvm::dyn_cast_or_null<MDNode>`
pub extern "C" fn llvm_isa_md_node(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_md_node"

///| Convert value to md node, equivalent to `llvm::dyn_cast_or_null<MDNode>`
pub fn LLVMValueRef::isa_md_node(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_md_node(self)
}

///| Convert value to metadata, equivalent to `llvm::dyn_cast_or_null<Metadata>`
pub extern "C" fn llvm_isa_value_as_metadata(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_value_as_metadata"

///| Convert value to metadata, equivalent to `llvm::dyn_cast_or_null<Metadata>`
pub fn LLVMValueRef::isa_value_as_metadata(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_value_as_metadata(self)
}

///| Convert value to md string, equivalent to `llvm::dyn_cast_or_null<MDString>`
pub extern "C" fn llvm_isa_md_string(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_md_string"

///| Convert value to md string, equivalent to `llvm::dyn_cast_or_null<MDString>`
pub fn LLVMValueRef::isa_md_string(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_md_string(self)
}

//| Obtain the string name of a value.
// 
// - see llvm::Value::getName()
// pub extern "C" fn llvm_get_value_name(val: LLVMValueRef) -> CStr = "__llvm_get_value_name"
// pub fn LLVMValueRef::get_value_name(self: LLVMValueRef) -> String {
//   let cstr = llvm_get_value_name(self)
//   c_str_to_moonbit_str(cstr)
// }

// deprecated
// pub extern "C" fn llvm_set_value_name(val: LLVMValueRef, name: CStr) = "__llvm_set_value_name"

///| Obtain the first use of a value.
/// 
/// Uses are obtained in an iterator fashion. First, call this function
/// to obtain a reference to the first use. Then, call LLVMGetNextUse()
/// on that instance and all subsequently obtained instances until
/// LLVMGetNextUse() returns NULL.
/// 
/// - see llvm::Value::use_begin()
pub extern "C" fn llvm_get_first_use(val: LLVMValueRef) -> LLVMUseRef = "__llvm_get_first_use"

///| Obtain the first use of a value.
/// 
/// Uses are obtained in an iterator fashion. First, call this function
/// to obtain a reference to the first use. Then, call LLVMGetNextUse()
/// on that instance and all subsequently obtained instances until
/// LLVMGetNextUse() returns NULL.
/// 
/// - see llvm::Value::use_begin()
pub fn LLVMValueRef::get_first_use(self: LLVMValueRef) -> LLVMUseRef {
  llvm_get_first_use(self)
}

///| Obtain the next use of a value.
/// 
/// This effectively advances the iterator. It returns NULL if you are on
/// the final use and no more are available.
/// 
pub extern "C" fn llvm_get_next_use(u: LLVMUseRef) -> LLVMUseRef = "__llvm_get_next_use"

///| Obtain the next use of a value.
/// 
/// This effectively advances the iterator. It returns NULL if you are on
/// the final use and no more are available.
/// 
pub fn LLVMUseRef::get_next_use(self: LLVMUseRef) -> LLVMUseRef {
  llvm_get_next_use(self)
}

///| Obtain the user value for a user.
/// 
/// The returned value corresponds to a llvm::User type.
/// 
/// - see llvm::Use::getUser()
/// 
pub extern "C" fn llvm_get_user(u: LLVMUseRef) -> LLVMValueRef = "__llvm_get_user"

///| Obtain the user value for a user.
/// 
/// The returned value corresponds to a llvm::User type.
/// 
/// - see llvm::Use::getUser()
/// 
pub fn LLVMUseRef::get_user(self: LLVMUseRef) -> LLVMValueRef {
  llvm_get_user(self)
}

///| Obtain the value this use corresponds to.
/// 
/// - see llvm::Use::get().
pub extern "C" fn llvm_get_used_value(u: LLVMUseRef) -> LLVMValueRef = "__llvm_get_used_value"

///| Obtain the value this use corresponds to.
/// 
/// - see llvm::Use::get().
pub fn LLVMUseRef::get_used_value(self: LLVMUseRef) -> LLVMValueRef {
  llvm_get_used_value(self)
}

///| Obtain an operand at a specific index in a llvm::User value.
/// 
/// - see llvm::User::getOperand()
/// 
pub extern "C" fn llvm_get_operand(val: LLVMValueRef, index: UInt) -> LLVMValueRef = "__llvm_get_operand"

///| Obtain an operand at a specific index in a llvm::User value.
/// 
/// - see llvm::User::getOperand()
/// 
pub fn LLVMValueRef::get_operand(self: LLVMValueRef, index: UInt) -> LLVMValueRef {
  llvm_get_operand(self, index)
}

///| Obtain the use of an operand at a specific index in a llvm::User value.
/// 
/// - see llvm::User::getOperandUse()
pub extern "C" fn llvm_get_operand_use(val: LLVMValueRef, index: UInt) -> LLVMUseRef = "__llvm_get_operand_use"

///| Obtain the use of an operand at a specific index in a llvm::User value.
/// 
/// - see llvm::User::getOperandUse()
pub fn LLVMValueRef::get_operand_use(self: LLVMValueRef, index: UInt) -> LLVMUseRef {
  llvm_get_operand_use(self, index)
}

///| Set an operand at a specific index in a llvm::User value.
/// 
/// - see llvm::User::setOperand()
/// 
pub extern "C" fn llvm_set_operand(user: LLVMValueRef, index: UInt, val: LLVMValueRef) = "__llvm_set_operand"

///| Set an operand at a specific index in a llvm::User value.
/// 
/// - see llvm::User::setOperand()
/// 
pub fn LLVMValueRef::set_operand(self: LLVMValueRef, index: UInt, val: LLVMValueRef) -> Unit {
  llvm_set_operand(self, index, val)
}

///| Obtain the number of operands in a llvm::User value.
/// 
/// - see llvm::User::getNumOperands()
pub extern "C" fn llvm_get_num_operands(val: LLVMValueRef) -> Int = "__llvm_get_num_operands"

///| Obtain the number of operands in a llvm::User value.
/// 
/// - see llvm::User::getNumOperands()
pub fn LLVMValueRef::get_num_operands(self: LLVMValueRef) -> Int {
  llvm_get_num_operands(self)
}

///| Obtain a constant value referring to the null instance of a type.
/// 
/// - see llvm::Constant::getNullValue()
/// 
pub extern "C" fn llvm_const_null(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_null"

///| Obtain a constant value referring to the null instance of a type.
/// 
/// - see llvm::Constant::getNullValue()
/// 
pub fn LLVMTypeRef::const_null(self: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_null(self)
}

///| Obtain a constant value referring to the instance of a type consisting of all ones.
/// 
/// This is only valid for integer types.
/// 
/// - see llvm::Constant::getAllOnesValue()
pub extern "C" fn llvm_const_all_ones(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_all_ones"

///| Obtain a constant value referring to the instance of a type consisting of all ones.
/// 
/// This is only valid for integer types.
/// 
/// - see llvm::Constant::getAllOnesValue()
pub fn LLVMTypeRef::const_all_ones(self: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_all_ones(self)
}

///| Obtain a constant value referring to an undefined value of a type.
/// 
/// - see llvm::UndefValue::get()
/// 
pub extern "C" fn llvm_get_undef(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_get_undef"

///| Obtain a constant value referring to an undefined value of a type.
/// 
/// - see llvm::UndefValue::get()
/// 
pub fn LLVMTypeRef::get_undef(self: LLVMTypeRef) -> LLVMValueRef {
  llvm_get_undef(self)
}

///| Obtain a constant value referring to a poison value of a type.
/// 
/// - see llvm::PoisonValue::get()
pub extern "C" fn llvm_get_poison(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_get_poison"

///| Obtain a constant value referring to a poison value of a type.
/// 
/// - see llvm::PoisonValue::get()
pub fn LLVMTypeRef::get_poison(self: LLVMTypeRef) -> LLVMValueRef {
  llvm_get_poison(self)
}

///| Determine whether a value instance is null.
/// 
/// - see llvm::Constant::isNullValue()
/// 
pub extern "C" fn llvm_is_null(val: LLVMValueRef) -> LLVMBool = "__llvm_is_null"


///| Obtain a constant that is a constant pointer pointing to NULL for a specified type.
pub extern "C" fn llvm_const_pointer_null(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_pointer_null"

///| Obtain a constant that is a constant pointer pointing to NULL for a specified type.
pub fn LLVMTypeRef::const_pointer_null(self: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_pointer_null(self)
}


///| Obtain a constant value for an integer type.
/// 
/// The returned value corresponds to a llvm::ConstantInt.
/// 
/// - see llvm::ConstantInt::get()
/// 
/// - @param IntTy Integer type to obtain value of.
/// - @param N The value the returned instance should refer to.
/// - @param SignExtend Whether to sign extend the produced value.
extern "C" fn __llvm_const_int(int_ty: LLVMTypeRef, n: UInt64, sign_extend: LLVMBool) -> LLVMValueRef = "__llvm_const_int"

///| Obtain a constant value for an integer type.
/// 
/// The returned value corresponds to a llvm::ConstantInt.
/// 
/// - see llvm::ConstantInt::get()
/// 
/// - @param IntTy Integer type to obtain value of.
/// - @param N The value the returned instance should refer to.
/// - @param SignExtend Whether to sign extend the produced value.
pub fn llvm_const_int(int_ty: LLVMTypeRef, n: UInt64, sign_extend: Bool) -> LLVMValueRef {
  __llvm_const_int(int_ty, n, to_llvm_bool(sign_extend))
}

///| Obtain a constant value for an integer type.
/// 
/// The returned value corresponds to a llvm::ConstantInt.
/// 
/// - see llvm::ConstantInt::get()
/// 
/// - @param IntTy Integer type to obtain value of.
/// - @param N The value the returned instance should refer to.
/// - @param SignExtend Whether to sign extend the produced value.
pub fn LLVMTypeRef::const_int(self: LLVMTypeRef, n: UInt64, sign_extend: Bool) -> LLVMValueRef {
  __llvm_const_int(self, n, to_llvm_bool(sign_extend))
}

///| Obtain a constant value for an integer of arbitrary precision.
/// 
/// - see llvm::ConstantInt::get()
pub extern "C" fn llvm_const_int_of_arbitrary_precision(int_ty: LLVMTypeRef, words: Array[UInt64]) -> LLVMValueRef = "__llvm_const_int_of_arbitrary_precision"


///| Obtain a constant value for an integer parsed from a string.
/// 
/// A similar API, LLVMConstIntOfStringAndSize is also available. If the
/// string's length is available, it is preferred to call that function
/// instead.
/// 
/// - see llvm::ConstantInt::get()
extern "C" fn __llvm_const_int_of_string(int_ty: LLVMTypeRef, text: CStr, radix: Int) -> LLVMValueRef = "__llvm_const_int_of_string"

///| Obtain a constant value for an integer parsed from a string.
/// 
/// A similar API, LLVMConstIntOfStringAndSize is also available. If the
/// string's length is available, it is preferred to call that function
/// instead.
/// 
/// - see llvm::ConstantInt::get()
// TODO: use llvm_const_int_of_string_and_size instead
pub fn llvm_const_int_of_string(int_ty: LLVMTypeRef, text: String, radix: Int) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(text);
  __llvm_const_int_of_string(int_ty, cstr, radix)
}

///| Obtain a constant value for an integer parsed from a string.
/// 
/// A similar API, LLVMConstIntOfStringAndSize is also available. If the
/// string's length is available, it is preferred to call that function
/// instead.
/// 
/// - see llvm::ConstantInt::get()
pub fn LLVMTypeRef::const_int_of_string(self: LLVMTypeRef, text: String, radix: Int) -> LLVMValueRef {
  llvm_const_int_of_string(self, text, radix)
}

extern "C" fn __llvm_const_int_of_string_and_size(int_ty: LLVMTypeRef, text: CStr, s_len: Int, radix: Int) -> LLVMValueRef = "__llvm_const_int_of_string_and_size"
pub fn llvm_const_int_of_string_and_size(int_ty: LLVMTypeRef, text: String, radix: Int) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(text);
  let s_len = text.length()
  __llvm_const_int_of_string_and_size(int_ty, cstr, s_len, radix)
}

///| Obtain a constant value referring to a double floating point value.
pub extern "C" fn llvm_const_real(real_ty: LLVMTypeRef, n: Double) -> LLVMValueRef = "__llvm_const_real"

///| Obtain a constant value referring to a double floating point value.
pub fn LLVMTypeRef::const_real(self: LLVMTypeRef, n: Double) -> LLVMValueRef {
  llvm_const_real(self, n)
}

///| Obtain a constant for a floating point value parsed from a string.
/// 
/// A similar API, LLVMConstRealOfStringAndSize is also available. It
/// should be used if the input string's length is known.
// TODO: use llvm_const_real_of_string_and_size instead
extern "C" fn __llvm_const_real_of_string(real_ty: LLVMTypeRef, text: CStr) -> LLVMValueRef = "__llvm_const_real_of_string"
pub fn llvm_const_real_of_string(real_ty: LLVMTypeRef, text: String) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(text);
  __llvm_const_real_of_string(real_ty, cstr)
}

///| Obtain a constant for a floating point value parsed from a string.
/// 
/// A similar API, LLVMConstRealOfStringAndSize is also available. It
/// should be used if the input string's length is known.
pub fn LLVMTypeRef::const_real_of_string(self: LLVMTypeRef, text: String) -> LLVMValueRef {
  llvm_const_real_of_string(self, text)
}

///| Obtain a constant for a floating point value parsed from a string.
extern "C" fn __llvm_const_real_of_string_and_size(real_ty: LLVMTypeRef, text: CStr, s_len: UInt) -> LLVMValueRef = "__llvm_const_real_of_string_and_size"

///| Obtain a constant for a floating point value parsed from a string.
pub fn llvm_const_real_of_string_and_size(real_ty: LLVMTypeRef, text: String) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(text);
  let s_len = text.length().reinterpret_as_uint()
  __llvm_const_real_of_string_and_size(real_ty, cstr, s_len)
}

///| Obtain the zero extended value for an integer constant value.
/// 
/// - see llvm::ConstantInt::getZExtValue()
pub extern "C" fn llvm_const_int_get_z_ext_value(constant_val: LLVMValueRef) -> UInt64 = "__llvm_const_int_get_z_ext_value"

///| Obtain the zero extended value for an integer constant value.
/// 
/// - see llvm::ConstantInt::getZExtValue()
pub fn LLVMValueRef::const_int_get_z_ext_value(self: LLVMValueRef) -> UInt64 {
  llvm_const_int_get_z_ext_value(self)
}

///| Obtain the sign extended value for an integer constant value.
/// 
/// - see llvm::ConstantInt::getSExtValue()
pub extern "C" fn llvm_const_int_get_s_ext_value(constant_val: LLVMValueRef) -> Int64 = "__llvm_const_int_get_s_ext_value"
pub fn LLVMValueRef::const_int_get_s_ext_value(self: LLVMValueRef) -> Int64 {
  llvm_const_int_get_s_ext_value(self)
}

///| Obtain the double value for an floating point constant value.
///
/// losesInfo indicates if some precision was lost in the conversion.
/// 
/// - see llvm::ConstantFP::getDoubleValue
extern "C" fn __llvm_const_real_get_double(constant_val: LLVMValueRef) -> (Double, LLVMBool) = "__llvm_const_real_get_double"

///| Obtain the double value for an floating point constant value.
///
/// losesInfo indicates if some precision was lost in the conversion.
/// 
/// - see llvm::ConstantFP::getDoubleValue
pub fn llvm_const_real_get_double(constant_val: LLVMValueRef) -> (Double, Bool) {
  let (v, loses_info) = __llvm_const_real_get_double(constant_val)
  (v, loses_info.to_moonbit_bool())
}

///| Create a ConstantDataSequential and initialize it with a string.
/// 
/// @deprecated LLVMConstStringInContext is deprecated in favor of the API
/// accurate LLVMConstStringInContext2
/// - see llvm::ConstantDataArray::getString()
/// 
// TODO: use llvm_const_string_in_context2 instead
extern "C" fn __llvm_const_string_in_context(context: LLVMContextRef, str: CStr, length: UInt, dont_null_terminate: LLVMBool) -> LLVMValueRef = "__llvm_const_string_in_context"

///| Create a ConstantDataSequential and initialize it with a string.
/// 
/// @deprecated LLVMConstStringInContext is deprecated in favor of the API
/// accurate LLVMConstStringInContext2
/// - see llvm::ConstantDataArray::getString()
/// 
pub fn llvm_const_string_in_context(context: LLVMContextRef, str: String, dont_null_terminate: Bool) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(str);
  let length = str.length().reinterpret_as_uint()
  let dont_null_terminate = to_llvm_bool(dont_null_terminate);
  __llvm_const_string_in_context(context, cstr, length, dont_null_terminate)
}

///| Create a ConstantDataSequential and initialize it with a string.
/// 
/// @deprecated LLVMConstStringInContext is deprecated in favor of the API
/// accurate LLVMConstStringInContext2
/// - see llvm::ConstantDataArray::getString()
/// 
pub fn LLVMContextRef::const_string(self: LLVMContextRef, str: String, dont_null_terminate: Bool) -> LLVMValueRef {
  llvm_const_string_in_context(self, str, dont_null_terminate)
}

///| Create a ConstantDataSequential and initialize it with a string.
/// 
/// - see llvm::ConstantDataArray::getString()
extern "C" fn __llvm_const_string_in_context2(context: LLVMContextRef, str: CStr, length: UInt64, dont_null_terminate: LLVMBool) -> LLVMValueRef = "__llvm_const_string_in_context2"

///| Create a ConstantDataSequential and initialize it with a string.
/// 
/// - see llvm::ConstantDataArray::getString()
pub fn llvm_const_string_in_context2(context: LLVMContextRef, str: String, dont_null_terminate: Bool) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(str);
  let length = str.length().to_uint64()
  let dont_null_terminate = to_llvm_bool(dont_null_terminate);
  __llvm_const_string_in_context2(context, cstr, length, dont_null_terminate)
}

///| Create a ConstantDataSequential and initialize it with a string.
/// 
/// - see llvm::ConstantDataArray::getString()
pub fn LLVMContextRef::const_string2(self: LLVMContextRef, str: String, dont_null_terminate: Bool) -> LLVMValueRef {
  llvm_const_string_in_context2(self, str, dont_null_terminate)
}

///| Create a ConstantDataSequential with string content in the global context.
/// 
/// This is the same as LLVMConstStringInContext except it operates on the
/// global context.
/// 
/// - see LLVMConstStringInContext()
/// - see llvm::ConstantDataArray::getString()
pub extern "C" fn llvm_const_string(str: CStr, length: UInt, dont_null_terminate: LLVMBool) -> LLVMValueRef = "__llvm_const_string"

extern "C" fn __llvm_is_constant_string(c: LLVMValueRef) -> LLVMBool = "__llvm_is_constant_string"
pub fn llvm_is_constant_string(c: LLVMValueRef) -> Bool {
  __llvm_is_constant_string(c).to_moonbit_bool()
}
pub fn LLVMValueRef::is_constant_string(self: LLVMValueRef) -> Bool {
  __llvm_is_constant_string(self).to_moonbit_bool()
}

/// Get the given constant data sequential as a string.
/// 
/// - see ConstantDataSequential::getAsString()
extern "C" fn __llvm_get_as_string(c: LLVMValueRef) -> (CStr, UInt) = "__llvm_get_as_string"

/// Get the given constant data sequential as a string.
/// 
/// - see ConstantDataSequential::getAsString()
pub fn llvm_get_as_string(c: LLVMValueRef) -> String {
  let (cstr, length) = __llvm_get_as_string(c);
  c_str_to_moonbit_str_with_length(cstr, length)
}

///| Create an anonymous ConstantStruct with the specified values.
/// 
/// - see llvm::ConstantStruct::getAnon()
extern "C" fn __llvm_const_struct_in_context(context: LLVMContextRef, constant_vals: Array[LLVMValueRef], packed: LLVMBool) -> LLVMValueRef = "__llvm_const_struct_in_context"

///| Create an anonymous ConstantStruct with the specified values.
/// 
/// - see llvm::ConstantStruct::getAnon()
pub fn llvm_const_struct_in_context(context: LLVMContextRef, constant_vals: Array[LLVMValueRef], packed: Bool) -> LLVMValueRef {
  __llvm_const_struct_in_context(context, constant_vals, to_llvm_bool(packed))
}

///| Create an anonymous ConstantStruct with the specified values.
/// 
/// - see llvm::ConstantStruct::getAnon()
pub fn LLVMContextRef::const_struct(self: LLVMContextRef, constant_vals: Array[LLVMValueRef], packed: Bool) -> LLVMValueRef {
  __llvm_const_struct_in_context(self, constant_vals, to_llvm_bool(packed))
}

///| Create a ConstantStruct in the global Context.
/// 
/// This is the same as LLVMConstStructInContext except it operates on the
/// global Context.
/// 
/// - see LLVMConstStructInContext()
extern "C" fn __llvm_const_struct(constant_vals: Array[LLVMValueRef], packed: LLVMBool) -> LLVMValueRef = "__llvm_const_struct"

///| Create a ConstantStruct in the global Context.
/// 
/// This is the same as LLVMConstStructInContext except it operates on the
/// global Context.
/// 
/// - see LLVMConstStructInContext()
pub fn llvm_const_struct(constant_vals: Array[LLVMValueRef], packed: Bool) -> LLVMValueRef {
  __llvm_const_struct(constant_vals, to_llvm_bool(packed))
}

///| Create a ConstantStruct in the global Context.
/// 
/// This is the same as LLVMConstStructInContext except it operates on the
/// global Context.
/// 
/// - see LLVMConstStructInContext()
pub fn LLVMValueRef::const_struct(constant_vals: Array[LLVMValueRef], packed: Bool) -> LLVMValueRef {
  __llvm_const_struct(constant_vals, to_llvm_bool(packed))
}

///| Create a ConstantArray from values.
/// 
/// @deprecated LLVMConstArray is deprecated in favor of the API accurate
/// LLVMConstArray2
///
/// - see llvm::ConstantArray::get()
extern "C" fn llvm_const_array(element_ty: LLVMTypeRef, constant_vals: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_array"

///| Create a ConstantArray from values.
/// 
/// @deprecated LLVMConstArray is deprecated in favor of the API accurate
/// LLVMConstArray2
///
/// - see llvm::ConstantArray::get()
pub fn LLVMValueRef::const_array(self: LLVMTypeRef, constant_vals: Array[LLVMValueRef]) -> LLVMValueRef {
  llvm_const_array(self, constant_vals)
}

///| Create a ConstantArray from values.
/// 
/// - see llvm::ConstantArray::get()
pub extern "C" fn llvm_const_array2(element_ty: LLVMTypeRef, constant_vals: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_array2"

///| Create a ConstantArray from values.
/// 
/// - see llvm::ConstantArray::get()
pub fn LLVMValueRef::const_array2(self: LLVMTypeRef, constant_vals: Array[LLVMValueRef]) -> LLVMValueRef {
  llvm_const_array2(self, constant_vals)
}

///| Create a non-anonymous ConstantStruct from values.
/// 
/// - see llvm::ConstantStruct::get()
pub extern "C" fn llvm_const_named_struct(struct_ty: LLVMTypeRef, constant_vals: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_named_struct"

///| Create a non-anonymous ConstantStruct from values.
/// 
/// - see llvm::ConstantStruct::get()
pub fn LLVMValueRef::const_named_struct(self: LLVMTypeRef, constant_vals: Array[LLVMValueRef]) -> LLVMValueRef {
  llvm_const_named_struct(self, constant_vals)
}

///| Get element of a constant aggregate (struct, array or vector) at the specified index.
///
/// Get element of a constant aggregate (struct, array or vector) at the
/// specified index. Returns null if the index is out of range, or it's not
/// possible to determine the element (e.g., because the constant is a
/// constant expression.)
/// 
/// - see llvm::Constant::getAggregateElement()
pub extern "C" fn llvm_get_aggregate_element(c: LLVMValueRef, idx: UInt) -> LLVMValueRef = "__llvm_get_aggregate_element"

///| Get element of a constant aggregate (struct, array or vector) at the specified index.
///
/// Get element of a constant aggregate (struct, array or vector) at the
/// specified index. Returns null if the index is out of range, or it's not
/// possible to determine the element (e.g., because the constant is a
/// constant expression.)
/// 
/// - see llvm::Constant::getAggregateElement()
pub fn LLVMValueRef::get_aggregate_element(self: LLVMValueRef, idx: UInt) -> LLVMValueRef {
  llvm_get_aggregate_element(self, idx)
}

///| Create a ConstantVector from values.
/// 
/// - see llvm::ConstantVector::get()
pub extern "C" fn llvm_const_vector(scalar_constant_vals: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_vector"

///| Create a ConstantVector from values.
/// 
/// - see llvm::ConstantVector::get()
pub fn LLVMValueRef::const_vector(self: Array[LLVMValueRef]) -> LLVMValueRef {
  llvm_const_vector(self)
}

///| Get const opcode of a constant value.
extern "C" fn __llvm_get_const_opcode(constant_val: LLVMValueRef) -> Int = "__llvm_get_const_opcode"

///| Get const opcode of a constant value.
pub fn llvm_get_const_opcode(constant_val: LLVMValueRef) -> LLVMOpcode {
  let opcode = __llvm_get_const_opcode(constant_val);
  LLVMOpcode::from_int(opcode)
}

///| Get alignment of a constant value.
pub extern "C" fn llvm_align_of(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_align_of"

///| Get alignment of a constant value.
pub fn LLVMTypeRef::align_of(self: LLVMTypeRef) -> LLVMValueRef {
  llvm_align_of(self)
}

///| Get size of a constant value.
pub extern "C" fn llvm_size_of(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_size_of"

///| Get size of a constant value.
pub fn LLVMTypeRef::size_of(self: LLVMTypeRef) -> LLVMValueRef {
  llvm_size_of(self)
}

///| Return negative value of a constant value.
pub extern "C" fn llvm_const_neg(constant_val: LLVMValueRef) -> LLVMValueRef = "__llvm_const_neg"

///| Return negative value of a constant value.
pub fn LLVMValueRef::const_neg(self: LLVMValueRef) -> LLVMValueRef {
  llvm_const_neg(self)
}

///| Return negative value of a constant value with NSW flag.
pub extern "C" fn llvm_const_nsw_neg(constant_val: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nsw_neg"

///| Return negative value of a constant value with NSW flag.
pub fn LLVMValueRef::const_nsw_neg(self: LLVMValueRef) -> LLVMValueRef {
  llvm_const_nsw_neg(self)
}

///| Return not value of a constant value.
pub extern "C" fn llvm_const_not(constant_val: LLVMValueRef) -> LLVMValueRef = "__llvm_const_not"

///| Return not value of a constant value.
pub fn LLVMValueRef::const_not(self: LLVMValueRef) -> LLVMValueRef {
  llvm_const_not(self)
}

///| Return add of two constant values.
pub extern "C" fn llvm_const_add(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_add"

///| Return add of two constant values.
pub fn LLVMValueRef::const_add(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_add(self, rhs_constant)
}

///| Return add of two constant values with NSW flag.
pub extern "C" fn llvm_const_nsw_add(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nsw_add"

///| Return add of two constant values with NSW flag.
pub fn LLVMValueRef::const_nsw_add(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_nsw_add(self, rhs_constant)
}

///| Return add of two constant values with NUW flag.
pub extern "C" fn llvm_const_nuw_add(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nuw_add"

///| Return add of two constant values with NUW flag.
pub fn LLVMValueRef::const_nuw_add(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_nuw_add(self, rhs_constant)
}

///| Return sub of two constant values.
pub extern "C" fn llvm_const_sub(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_sub"

///| Return sub of two constant values.
pub fn LLVMValueRef::const_sub(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_sub(self, rhs_constant)
}

///| Return sub of two constant values with NSW flag.
pub extern "C" fn llvm_const_nsw_sub(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nsw_sub"

///| Return sub of two constant values with NSW flag.
pub fn LLVMValueRef::const_nsw_sub(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_nsw_sub(self, rhs_constant)
}

///| Return sub of two constant values with NUW flag.
pub extern "C" fn llvm_const_nuw_sub(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nuw_sub"

///| Return sub of two constant values with NUW flag.
pub fn LLVMValueRef::const_nuw_sub(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_nuw_sub(self, rhs_constant)
}

///| Return mul of two constant values.
pub extern "C" fn llvm_const_mul(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_mul"

///| Return mul of two constant values.
pub fn LLVMValueRef::const_mul(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_mul(self, rhs_constant)
}

///| Return mul of two constant values with NSW flag.
pub extern "C" fn llvm_const_nsw_mul(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nsw_mul"

///| Return mul of two constant values with NSW flag.
pub fn LLVMValueRef::const_nsw_mul(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_nsw_mul(self, rhs_constant)
}

///| Return mul of two constant values with NUW flag.
pub extern "C" fn llvm_const_nuw_mul(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nuw_mul"

///| Return mul of two constant values with NUW flag.
pub fn LLVMValueRef::const_nuw_mul(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_nuw_mul(self, rhs_constant)
}

///| Return xor of two constant values.
pub extern "C" fn llvm_const_xor(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_xor"

///| Return xor of two constant values.
pub fn LLVMValueRef::const_xor(self: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_xor(self, rhs_constant)
}

///| Return getelementptr of a constant value.
pub extern "C" fn llvm_const_gep2(ty: LLVMTypeRef, constant_val: LLVMValueRef, constant_indices: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_gep2"

///| Return getelementptr of a constant value.
pub fn LLVMTypeRef::const_gep2(self: LLVMTypeRef, constant_val: LLVMValueRef, constant_indices: Array[LLVMValueRef]) -> LLVMValueRef {
  llvm_const_gep2(self, constant_val, constant_indices)
}

///| Return inbounds getelementptr of a constant value.
pub extern "C" fn llvm_const_in_bounds_gep2(ty: LLVMTypeRef, constant_val: LLVMValueRef, constant_indices: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_in_bounds_gep2"

///| Return inbounds getelementptr of a constant value.
pub fn LLVMTypeRef::const_in_bounds_gep2(self: LLVMTypeRef, constant_val: LLVMValueRef, constant_indices: Array[LLVMValueRef]) -> LLVMValueRef {
  llvm_const_in_bounds_gep2(self, constant_val, constant_indices)
}

///| Return trunc of a constant value.
pub extern "C" fn llvm_const_trunc(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_trunc"

///| Return trunc of a constant value.
pub fn LLVMValueRef::const_trunc(self: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_trunc(self, to_type)
}

///| Return ptr to int of a constant value.
pub extern "C" fn llvm_const_ptr_to_int(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_ptr_to_int"

///| Return ptr to int of a constant value.
pub fn LLVMValueRef::const_ptr_to_int(self: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_ptr_to_int(self, to_type)
}

///| Return int to ptr of a constant value.
pub extern "C" fn llvm_const_int_to_ptr(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_int_to_ptr"

///| Return int to ptr of a constant value.
pub fn LLVMValueRef::const_int_to_ptr(self: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_int_to_ptr(self, to_type)
}

///| Return bit cast of a constant value.
pub extern "C" fn llvm_const_bit_cast(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_bit_cast"

///| Return bit cast of a constant value.
pub fn LLVMValueRef::const_bit_cast(self: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_bit_cast(self, to_type)
}

///| Return addr space cast of a constant value.
pub extern "C" fn llvm_const_addr_space_cast(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_addr_space_cast"

///| Return addr space cast of a constant value.
pub fn LLVMValueRef::const_addr_space_cast(self: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_addr_space_cast(self, to_type)
}

///| Return trunc or bit cast of a constant value.
pub extern "C" fn llvm_const_trunc_or_bit_cast(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_trunc_or_bit_cast"

///| Return trunc or bit cast of a constant value.
pub fn LLVMValueRef::const_trunc_or_bit_cast(self: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_trunc_or_bit_cast(self, to_type)
}

///| Return pointer cast of a constant value.
pub extern "C" fn llvm_const_pointer_cast(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_pointer_cast"

///| Return pointer cast of a constant value.
pub fn LLVMValueRef::const_pointer_cast(self: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef {
  llvm_const_pointer_cast(self, to_type)
}

///| Return extract element of a constant value.
pub extern "C" fn llvm_const_extract_element(vector_constant: LLVMValueRef, index_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_extract_element"

///| Return extract element of a constant value.
pub fn LLVMValueRef::const_extract_element(self: LLVMValueRef, index_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_extract_element(self, index_constant)
}

///| Return insert element of a constant value.
pub extern "C" fn llvm_const_insert_element(vector_constant: LLVMValueRef, element_value_constant: LLVMValueRef, index_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_insert_element"

///| Return insert element of a constant value.
pub fn LLVMValueRef::const_insert_element(self: LLVMValueRef, element_value_constant: LLVMValueRef, index_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_insert_element(self, element_value_constant, index_constant)
}

///| Return shuffle vector of two constant values.
pub extern "C" fn llvm_const_shuffle_vector(vector_a_constant: LLVMValueRef, vector_b_constant: LLVMValueRef, mask_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_shuffle_vector"

///| Return shuffle vector of two constant values.
pub fn LLVMValueRef::const_shuffle_vector(self: LLVMValueRef, vector_b_constant: LLVMValueRef, mask_constant: LLVMValueRef) -> LLVMValueRef {
  llvm_const_shuffle_vector(self, vector_b_constant, mask_constant)
}

///| Return block address of a constant value.
pub extern "C" fn llvm_block_address(f: LLVMValueRef, bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_block_address"

///| Return block address of a constant value.
pub fn LLVMValueRef::block_address(self: LLVMValueRef, bb: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_block_address(self, bb)
}

///| Return global address of a constant value.
pub extern "C" fn llvm_get_block_address_function(block_addr: LLVMValueRef) -> LLVMValueRef = "__llvm_get_block_address_function"

///| Return global address of a constant value.
pub fn LLVMValueRef::get_block_address_function(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_block_address_function(self)
}

///| Return basic block of a constant value.
pub extern "C" fn llvm_get_block_address_basic_block(block_addr: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_block_address_basic_block"

///| Return basic block of a constant value.
pub fn LLVMValueRef::get_block_address_basic_block(self: LLVMValueRef) -> LLVMBasicBlockRef {
  llvm_get_block_address_basic_block(self)
}

///| Return inlined asm of a constant value.
extern "C" fn __llvm_const_inline_asm(ty: LLVMTypeRef, asm_string: CStr, constraints: CStr, has_side_effects: LLVMBool, is_align_stack: LLVMBool) -> LLVMValueRef = "__llvm_const_inline_asm"

///| Return inlined asm of a constant value.
pub fn llvm_const_inline_asm(ty: LLVMTypeRef, asm_string: String, constraints: String, has_side_effects: Bool, is_align_stack: Bool) -> LLVMValueRef {
  let asm_str = moonbit_str_to_c_str(asm_string);
  let constraints_str = moonbit_str_to_c_str(constraints);
  __llvm_const_inline_asm(ty, asm_str, constraints_str, to_llvm_bool(has_side_effects), to_llvm_bool(is_align_stack))
}

///| Return inlined asm of a constant value.
pub fn LLVMTypeRef::const_inline_asm(self: LLVMTypeRef, asm_string: String, constraints: String, has_side_effects: Bool, is_align_stack: Bool) -> LLVMValueRef {
  llvm_const_inline_asm(self, asm_string, constraints, has_side_effects, is_align_stack)
}

///| Get global parent of a constant value.
pub extern "C" fn llvm_get_global_parent(global: LLVMValueRef) -> LLVMModuleRef = "__llvm_get_global_parent"

///| Get global parent of a constant value.
pub fn LLVMValueRef::get_global_parent(self: LLVMValueRef) -> LLVMModuleRef {
  llvm_get_global_parent(self)
}

///| Check if a global value is a declaration.
extern "C" fn __llvm_is_declaration(global: LLVMValueRef) -> LLVMBool = "__llvm_is_declaration"

///| Check if a global value is a declaration.
pub fn llvm_is_declaration(global: LLVMValueRef) -> Bool {
  __llvm_is_declaration(global).to_moonbit_bool()
}

///| Check if a global value is a declaration.
pub fn LLVMValueRef::is_declaration(self: LLVMValueRef) -> Bool {
  __llvm_is_declaration(self).to_moonbit_bool()
}

///| Get linkage for value.
pub extern "C" fn llvm_get_linkage(global: LLVMValueRef) -> LLVMLinkage = "__llvm_get_linkage"

///| Get linkage for value.
pub fn LLVMValueRef::get_linkage(self: LLVMValueRef) -> LLVMLinkage {
  llvm_get_linkage(self)
}

///| Set linkage for value.
pub extern "C" fn llvm_set_linkage(global: LLVMValueRef, linkage: LLVMLinkage) = "__llvm_set_linkage"

///| Set linkage for value.
pub fn LLVMValueRef::set_linkage(self: LLVMValueRef, linkage: LLVMLinkage) -> Unit {
  llvm_set_linkage(self, linkage)
}

///| Get section for value.
extern "C" fn __llvm_get_section(global: LLVMValueRef) -> CStr = "__llvm_get_section"

///| Get section for value.
pub fn llvm_get_section(global: LLVMValueRef) -> String {
  let cstr = __llvm_get_section(global);
  c_str_to_moonbit_str(cstr)
}

///| Get section for value.
pub fn LLVMValueRef::get_section(self: LLVMValueRef) -> String {
  llvm_get_section(self)
}

///| Set section for global value.
extern "C" fn __llvm_set_section(global: LLVMValueRef, section: CStr) = "__llvm_set_section"

///| Set section for global value.
pub fn llvm_set_section(global: LLVMValueRef, section: String) -> Unit {
  let cstr = moonbit_str_to_c_str(section);
  __llvm_set_section(global, cstr)
}

///| Set section for global value.
pub fn LLVMValueRef::set_section(self: LLVMValueRef, section: String) -> Unit {
  llvm_set_section(self, section)
}

///| Get visibility for value.
pub extern "C" fn llvm_get_visibility(global: LLVMValueRef) -> LLVMVisibility = "__llvm_get_visibility"

///| Get visibility for value.
pub fn LLVMValueRef::get_visibility(self: LLVMValueRef) -> LLVMVisibility {
  llvm_get_visibility(self)
}

///| Set visibility for value.
pub extern "C" fn llvm_set_visibility(global: LLVMValueRef, viz: LLVMVisibility) = "__llvm_set_visibility"

///| Set visibility for value.
pub fn LLVMValueRef::set_visibility(self: LLVMValueRef, viz: LLVMVisibility) -> Unit {
  llvm_set_visibility(self, viz)
}

///| Get DLL storage class for value.
pub extern "C" fn llvm_get_dll_storage_class(global: LLVMValueRef) -> LLVMDLLStorageClass = "__llvm_get_dll_storage_class"

///| Get DLL storage class for value.
pub fn LLVMValueRef::get_dll_storage_class(self: LLVMValueRef) -> LLVMDLLStorageClass {
  llvm_get_dll_storage_class(self)
}

///| Get unnamed address for value.
pub extern "C" fn llvm_get_unnamed_address(global: LLVMValueRef) -> LLVMUnnamedAddr = "__llvm_get_unnamed_address"

///| Get unnamed address for value.
pub fn LLVMValueRef::get_unnamed_address(self: LLVMValueRef) -> LLVMUnnamedAddr {
  llvm_get_unnamed_address(self)
}

///| Set unnamed address for value.
pub extern "C" fn llvm_set_unnamed_address(global: LLVMValueRef, unnamed_addr: LLVMUnnamedAddr) = "__llvm_set_unnamed_address"

///| Set unnamed address for value.
pub fn LLVMValueRef::set_unnamed_address(self: LLVMValueRef, unnamed_addr: LLVMUnnamedAddr) -> Unit {
  llvm_set_unnamed_address(self, unnamed_addr)
}

///| Get value type in global context.
pub extern "C" fn llvm_global_get_value_type(global: LLVMValueRef) -> LLVMTypeRef = "__llvm_global_get_value_type"

///| Get value type in global context.
pub fn LLVMValueRef::global_get_value_type(self: LLVMValueRef) -> LLVMTypeRef {
  llvm_global_get_value_type(self)
}

///| Check if a global value has unnamed address.
extern "C" fn __llvm_has_unnamed_addr(global: LLVMValueRef) -> LLVMBool = "__llvm_has_unnamed_addr"

///| Check if a global value has unnamed address.
pub fn llvm_has_unnamed_addr(global: LLVMValueRef) -> Bool {
  __llvm_has_unnamed_addr(global).to_moonbit_bool()
}

///| Check if a global value has unnamed address.
pub fn LLVMValueRef::has_unnamed_addr(self: LLVMValueRef) -> Bool {
  __llvm_has_unnamed_addr(self).to_moonbit_bool()
}

///| Set unnamed address for value.
extern "C" fn __llvm_set_unnamed_addr(global: LLVMValueRef, has_unnamed_addr: LLVMBool) = "__llvm_set_unnamed_addr"

///| Set unnamed address for value.
pub fn llvm_set_unnamed_addr(global: LLVMValueRef, has_unnamed_addr: Bool) -> Unit {
  __llvm_set_unnamed_addr(global, to_llvm_bool(has_unnamed_addr))
}

///| Set unnamed address for value.
pub fn LLVMValueRef::set_unnamed_addr(self: LLVMValueRef, has_unnamed_addr: Bool) -> Unit {
  __llvm_set_unnamed_addr(self, to_llvm_bool(has_unnamed_addr))
}

///| Obtain the preferred alignment of the value.
///
/// - see llvm::AllocaInst::getAlignment()
/// - see llvm::LoadInst::getAlignment()
/// - see llvm::StoreInst::getAlignment()
/// - see llvm::AtomicRMWInst::setAlignment()
/// - see llvm::AtomicCmpXchgInst::setAlignment()
/// - see llvm::GlobalValue::getAlignment()
pub extern "C" fn llvm_get_alignment(v: LLVMValueRef) -> UInt = "__llvm_get_alignment"

///| Obtain the preferred alignment of the value.
///
/// - see llvm::AllocaInst::getAlignment()
/// - see llvm::LoadInst::getAlignment()
/// - see llvm::StoreInst::getAlignment()
/// - see llvm::AtomicRMWInst::setAlignment()
/// - see llvm::AtomicCmpXchgInst::setAlignment()
/// - see llvm::GlobalValue::getAlignment()
pub fn LLVMValueRef::get_alignment(self: LLVMValueRef) -> UInt {
  llvm_get_alignment(self)
}

/// Set the preferred alignment of the value.
///
/// - see llvm::AllocaInst::setAlignment()
/// - see llvm::LoadInst::setAlignment()
/// - see llvm::StoreInst::setAlignment()
/// - see llvm::AtomicRMWInst::setAlignment()
/// - see llvm::AtomicCmpXchgInst::setAlignment()
/// - see llvm::GlobalValue::setAlignment()
pub extern "C" fn llvm_set_alignment(v: LLVMValueRef, bytes: UInt) = "__llvm_set_alignment"

/// Set the preferred alignment of the value.
///
/// - see llvm::AllocaInst::setAlignment()
/// - see llvm::LoadInst::setAlignment()
/// - see llvm::StoreInst::setAlignment()
/// - see llvm::AtomicRMWInst::setAlignment()
/// - see llvm::AtomicCmpXchgInst::setAlignment()
/// - see llvm::GlobalValue::setAlignment()
pub fn LLVMValueRef::set_alignment(self: LLVMValueRef, bytes: UInt) -> Unit {
  llvm_set_alignment(self, bytes)
}

///| Sets a metadata attachment.
///
/// Sets a metadata attachment, erasing the existing metadata attachment if
/// it already exists for the given kind.
/// 
/// - see llvm::GlobalObject::setMetadata()
pub extern "C" fn llvm_global_set_metadata(global: LLVMValueRef, kind: UInt, md: LLVMMetadataRef) = "__llvm_global_set_metadata"

///| Sets a metadata attachment.
///
/// Sets a metadata attachment, erasing the existing metadata attachment if
/// it already exists for the given kind.
/// 
/// - see llvm::GlobalObject::setMetadata()
pub fn LLVMValueRef::global_set_metadata(self: LLVMValueRef, kind: UInt, md: LLVMMetadataRef) -> Unit {
  llvm_global_set_metadata(self, kind, md)
}

///| Erases a metadata attachment of the given kind if it exists.
/// 
/// - see llvm::GlobalObject::eraseMetadata()
pub extern "C" fn llvm_global_erase_metadata(global: LLVMValueRef, kind: UInt) = "__llvm_global_erase_metadata"

///| Erases a metadata attachment of the given kind if it exists.
/// 
/// - see llvm::GlobalObject::eraseMetadata()
pub fn LLVMValueRef::global_erase_metadata(self: LLVMValueRef, kind: UInt) -> Unit {
  llvm_global_erase_metadata(self, kind)
}

///| Removes all metadata attachments from this value.
/// 
/// - see llvm::GlobalObject::clearMetadata()
pub extern "C" fn llvm_global_clear_metadata(global: LLVMValueRef) = "__llvm_global_clear_metadata"

///| Removes all metadata attachments from this value.
/// 
/// - see llvm::GlobalObject::clearMetadata()
pub fn LLVMValueRef::global_clear_metadata(self: LLVMValueRef) -> Unit {
  llvm_global_clear_metadata(self)
}

// pub extern "C" fn llvm_global_copy_all_metadata(value: LLVMValueRef) -> Array[LLVMValueMetadataEntry] = "__llvm_global_copy_all_metadata"

// pub extern "C" fn llvm_dispose_value_metadata_entries(entries: Array[LLVMValueMetadataEntry]) = "__llvm_dispose_value_metadata_entries"

// pub extern "C" fn llvm_value_metadata_entries_get_kind(entries: Array[LLVMValueMetadataEntry], index: UInt) -> UInt = "__llvm_value_metadata_entries_get_kind"

// pub extern "C" fn llvm_value_metadata_entries_get_metadata(entries: Array[LLVMValueMetadataEntry], index: UInt) -> LLVMMetadataRef = "__llvm_value_metadata_entries_get_metadata"

extern "C" fn __llvm_add_global(m: LLVMModuleRef, ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_add_global"
pub fn llvm_add_global(m: LLVMModuleRef, ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(name);
  __llvm_add_global(m, ty, cstr)
}

extern "C" fn __llvm_add_global_in_address_space(m: LLVMModuleRef, ty: LLVMTypeRef, name: CStr, address_space: AddressSpace) -> LLVMValueRef = "__llvm_add_global_in_address_space"
pub fn llvm_add_global_in_address_space(m: LLVMModuleRef, ty: LLVMTypeRef, name: String, address_space: AddressSpace) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(name);
  __llvm_add_global_in_address_space(m, ty, cstr, address_space)
}

extern "C" fn __llvm_get_named_global(m: LLVMModuleRef, name: CStr) -> LLVMValueRef = "__llvm_get_named_global"
pub fn llvm_get_named_global(m: LLVMModuleRef, name: String) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(name);
  __llvm_get_named_global(m, cstr)
}

pub extern "C" fn llvm_get_first_global(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_first_global"

pub extern "C" fn llvm_get_last_global(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_last_global"

pub extern "C" fn llvm_get_next_global(global_var: LLVMValueRef) -> LLVMValueRef = "__llvm_get_next_global"

pub extern "C" fn llvm_get_previous_global(global_var: LLVMValueRef) -> LLVMValueRef = "__llvm_get_previous_global"

pub extern "C" fn llvm_delete_global(global_var: LLVMValueRef) = "__llvm_delete_global"

pub extern "C" fn llvm_get_initializer(global_var: LLVMValueRef) -> LLVMValueRef = "__llvm_get_initializer"

pub extern "C" fn llvm_set_initializer(global_var: LLVMValueRef, constant_val: LLVMValueRef) = "__llvm_set_initializer"

extern "C" fn __llvm_is_thread_local(global_var: LLVMValueRef) -> LLVMBool = "__llvm_is_thread_local"
pub fn llvm_is_thread_local(global_var: LLVMValueRef) -> Bool {
  __llvm_is_thread_local(global_var).to_moonbit_bool()
}

extern "C" fn __llvm_set_thread_local(global_var: LLVMValueRef, is_thread_local: LLVMBool) = "__llvm_set_thread_local"
pub fn llvm_set_thread_local(global_var: LLVMValueRef, is_thread_local: Bool) -> Unit {
  __llvm_set_thread_local(global_var, to_llvm_bool(is_thread_local))
}

extern "C" fn __llvm_is_global_constant(global_var: LLVMValueRef) -> LLVMBool = "__llvm_is_global_constant"
pub fn llvm_is_global_constant(global_var: LLVMValueRef) -> Bool {
  __llvm_is_global_constant(global_var).to_moonbit_bool()
}

extern "C" fn __llvm_set_global_constant(global_var: LLVMValueRef, is_constant: LLVMBool) = "__llvm_set_global_constant"
pub fn llvm_set_global_constant(global_var: LLVMValueRef, is_constant: Bool) -> Unit {
  __llvm_set_global_constant(global_var, to_llvm_bool(is_constant))
}

pub extern "C" fn llvm_get_thread_local_mode(global_var: LLVMValueRef) -> LLVMThreadLocalMode = "__llvm_get_thread_local_mode"

pub extern "C" fn llvm_set_thread_local_mode(global_var: LLVMValueRef, mode: LLVMThreadLocalMode) = "__llvm_set_thread_local_mode"

extern "C" fn __llvm_is_externally_initialized(global_var: LLVMValueRef) -> LLVMBool = "__llvm_is_externally_initialized"
pub fn llvm_is_externally_initialized(global_var: LLVMValueRef) -> Bool {
  __llvm_is_externally_initialized(global_var).to_moonbit_bool()
}

extern "C" fn __llvm_set_externally_initialized(global_var: LLVMValueRef, is_ext_init: LLVMBool) = "__llvm_set_externally_initialized"
pub fn llvm_set_externally_initialized(global_var: LLVMValueRef, is_ext_init: Bool) -> Unit {
  __llvm_set_externally_initialized(global_var, to_llvm_bool(is_ext_init))
}


/// Add a GlobalAlias with the given value type, address space and aliasee.
/// 
/// - see llvm::GlobalAlias::create()
extern "C" fn __llvm_add_alias2(m: LLVMModuleRef, value_ty: LLVMTypeRef, addr_space: UInt, aliasee: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_add_alias2"

/// Add a GlobalAlias with the given value type, address space and aliasee.
/// 
/// - see llvm::GlobalAlias::create()
pub fn llvm_add_alias2(m: LLVMModuleRef, value_ty: LLVMTypeRef, addr_space: UInt, aliasee: LLVMValueRef, name: String) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(name);
  __llvm_add_alias2(m, value_ty, addr_space, aliasee, cstr)
}


///| Obtain a GlobalAlias value from a Module by its name.
/// 
/// The returned value corresponds to a llvm::GlobalAlias value.
/// 
/// - see llvm::Module::getNamedAlias()
extern "C" fn __llvm_get_named_global_alias(m: LLVMModuleRef, name: CStr, name_len: UInt64) -> LLVMValueRef = "__llvm_get_named_global_alias"

///| Obtain a GlobalAlias value from a Module by its name.
/// 
/// The returned value corresponds to a llvm::GlobalAlias value.
/// 
/// - see llvm::Module::getNamedAlias()
pub fn llvm_get_named_global_alias(m: LLVMModuleRef, name: String) -> LLVMValueRef {
  let len = name.length().to_uint64();
  let name = moonbit_str_to_c_str(name);
  __llvm_get_named_global_alias(m, name, len)
}

///| Obtain a GlobalAlias value from a Module by its name.
/// 
/// The returned value corresponds to a llvm::GlobalAlias value.
/// 
/// - see llvm::Module::getNamedAlias()
pub fn LLVMModuleRef::get_named_alias(self: LLVMModuleRef, name: String) -> LLVMValueRef {
  llvm_get_named_global_alias(self, name)
}


///| Obtain an iterator to the first GlobalAlias in a Module.
/// 
/// - see llvm::Module::alias_begin()
pub extern "C" fn llvm_get_first_global_alias(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_first_global_alias"

///| Obtain an iterator to the first GlobalAlias in a Module.
/// 
/// - see llvm::Module::alias_begin()
pub fn LLVMModuleRef::get_first_global_alias(self: LLVMModuleRef) -> LLVMValueRef {
  llvm_get_first_global_alias(self)
}


///| Obtain an iterator to the last GlobalAlias in a Module.
/// 
/// - see llvm::Module::alias_end()
pub extern "C" fn llvm_get_last_global_alias(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_last_global_alias"

///| Obtain an iterator to the last GlobalAlias in a Module.
/// 
/// - see llvm::Module::alias_end()
pub fn LLVMModuleRef::get_last_global_alias(self: LLVMModuleRef) -> LLVMValueRef {
  llvm_get_last_global_alias(self)
}


///| Advance a GlobalAlias iterator to the next GlobalAlias.
/// 
/// Returns NULL if the iterator was already at the end and there are no more
/// global aliases.
pub extern "C" fn llvm_get_next_global_alias(ga: LLVMValueRef) -> LLVMValueRef = "__llvm_get_next_global_alias"

///| Advance a GlobalAlias iterator to the next GlobalAlias.
/// 
/// Returns NULL if the iterator was already at the end and there are no more
/// global aliases.
pub fn LLVMValueRef::get_next_global_alias(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_next_global_alias(self)
}

///| Decrement a GlobalAlias iterator to the previous GlobalAlias.
/// 
/// Returns NULL if the iterator was already at the beginning and there are
/// no previous global aliases.
pub extern "C" fn llvm_get_previous_global_alias(ga: LLVMValueRef) -> LLVMValueRef = "__llvm_get_previous_global_alias"

///| Retrieve the target value of an alias.
pub extern "C" fn llvm_alias_get_aliasee(alias_ref: LLVMValueRef) -> LLVMValueRef = "__llvm_alias_get_aliasee"


///| Set the target value of an alias.
pub extern "C" fn llvm_alias_set_aliasee(alias_ref: LLVMValueRef, aliasee: LLVMValueRef) = "__llvm_alias_set_aliasee"


///| Remove a function from its containing module and deletes it.
/// 
/// - see llvm::Function::eraseFromParent()
pub extern "C" fn llvm_delete_function(func: LLVMValueRef) = "__llvm_delete_function"

///| Check whether the given function has a personality function.
/// 
/// - see llvm::Function::hasPersonalityFn()
extern "C" fn __llvm_has_personality_fn(func: LLVMValueRef) -> LLVMBool = "__llvm_has_personality_fn"

///| Check whether the given function has a personality function.
/// 
/// - see llvm::Function::hasPersonalityFn()
pub fn llvm_has_personality_fn(func: LLVMValueRef) -> Bool {
  __llvm_has_personality_fn(func).to_moonbit_bool()
}

///| Obtain the personality function attached to the function.
/// 
/// - see llvm::Function::getPersonalityFn()
pub extern "C" fn llvm_get_personality_fn(func: LLVMValueRef) -> LLVMValueRef = "__llvm_get_personality_fn"


///| Set the personality function attached to the function.
/// 
/// - see llvm::Function::setPersonalityFn()
pub extern "C" fn llvm_set_personality_fn(func: LLVMValueRef, personality_fn: LLVMValueRef) = "__llvm_set_personality_fn"

///| Obtain the intrinsic ID number which matches the given function name.
/// 
/// - see llvm::Intrinsic::lookupIntrinsicID()
extern "C" fn __llvm_lookup_intrinsic_id(name: CStr, name_len: UInt64) -> UInt = "__llvm_lookup_intrinsic_id"
pub fn llvm_lookup_intrinsic_id(name: String) -> UInt {
  let len = name.length().to_uint64();
  let name = moonbit_str_to_c_str(name);
  __llvm_lookup_intrinsic_id(name, len)
}


///| Obtain the ID number from a function instance.
/// 
/// - see llvm::Function::getIntrinsicID()
pub extern "C" fn llvm_get_intrinsic_id(func: LLVMValueRef) -> UInt = "__llvm_get_intrinsic_id"


///| Get or insert the declaration of an intrinsic.
///
/// Get or insert the declaration of an intrinsic.  For overloaded intrinsics,
/// parameter types must be provided to uniquely identify an overload.
/// 
/// - see llvm::Intrinsic::getOrInsertDeclaration()
pub extern "C" fn llvm_get_intrinsic_declaration(mod: LLVMModuleRef, id: UInt, param_types: Array[LLVMTypeRef]) -> LLVMValueRef = "__llvm_get_intrinsic_declaration"

///| Retrieves the type of an intrinsic.
///
/// Retrieves the type of an intrinsic.  For overloaded intrinsics, parameter
/// types must be provided to uniquely identify an overload.
/// 
/// - see llvm::Intrinsic::getType()
pub extern "C" fn llvm_intrinsic_get_type(ctx: LLVMContextRef, id: UInt, param_types: Array[LLVMTypeRef]) -> LLVMTypeRef = "__llvm_intrinsic_get_type"

///| Retrieves the type of an intrinsic.
///
/// Retrieves the type of an intrinsic.  For overloaded intrinsics, parameter
/// types must be provided to uniquely identify an overload.
/// 
/// - see llvm::Intrinsic::getType()
pub fn LLVMContextRef::intrinsic_get_type(self: LLVMContextRef, id: UInt, param_types: Array[LLVMTypeRef]) -> LLVMTypeRef {
  llvm_intrinsic_get_type(self, id, param_types)
}

///| Retrieves the name of an intrinsic.
/// 
/// - see llvm::Intrinsic::getName()
extern "C" fn __llvm_intrinsic_get_name(id: UInt) -> (CStr, UInt64) = "__llvm_intrinsic_get_name"

///| Retrieves the name of an intrinsic.
/// 
/// - see llvm::Intrinsic::getName()
pub fn llvm_intrinsic_get_name(id: UInt) -> String {
  let (cstr, len) = __llvm_intrinsic_get_name(id)
  let len = len.to_uint();
  c_str_to_moonbit_str_with_length(cstr, len)
}

// Deprecated: Use LLVMIntrinsicCopyOverloadedName2 instead. 
extern "C" fn __llvm_intrinsic_copy_overloaded_name(id: UInt, param_types: Array[LLVMTypeRef]) -> CStr = "__llvm_intrinsic_copy_overloaded_name"
pub fn llvm_intrinsic_copy_overloaded_name(id: UInt, param_types: Array[LLVMTypeRef]) -> String {
  let cstr = __llvm_intrinsic_copy_overloaded_name(id, param_types);
  c_str_to_moonbit_str(cstr)
}

/// Copies the name of an overloaded intrinsic identified by a given list of parameter types.
/// 
/// Unlike LLVMIntrinsicGetName, the caller is responsible for freeing the
/// returned string.
/// 
/// This version also supports unnamed types.
/// 
/// - see llvm::Intrinsic::getName()
extern "C" fn __llvm_intrinsic_copy_overloaded_name2(mod: LLVMModuleRef, id: UInt, param_types: Array[LLVMTypeRef]) -> CStr = "__llvm_intrinsic_copy_overloaded_name2"

/// Copies the name of an overloaded intrinsic identified by a given list of parameter types.
/// 
/// Unlike LLVMIntrinsicGetName, the caller is responsible for freeing the
/// returned string.
/// 
/// This version also supports unnamed types.
/// 
/// - see llvm::Intrinsic::getName()
pub fn llvm_intrinsic_copy_overloaded_name2(mod: LLVMModuleRef, id: UInt, param_types: Array[LLVMTypeRef]) -> String {
  let cstr = __llvm_intrinsic_copy_overloaded_name2(mod, id, param_types);
  c_str_to_moonbit_str(cstr)
}


///| Obtain if the intrinsic identified by the given ID is overloaded.
/// 
/// - see llvm::Intrinsic::isOverloaded()
extern "C" fn __llvm_intrinsic_is_overloaded(id: UInt) -> LLVMBool = "__llvm_intrinsic_is_overloaded"

///| Obtain if the intrinsic identified by the given ID is overloaded.
/// 
/// - see llvm::Intrinsic::isOverloaded()
pub fn llvm_intrinsic_is_overloaded(id: UInt) -> Bool {
  __llvm_intrinsic_is_overloaded(id).to_moonbit_bool()
}


///| Obtain the calling function of a function.
/// 
/// The returned value corresponds to the LLVMCallConv enumeration.
/// 
/// - see llvm::Function::getCallingConv()
pub extern "C" fn llvm_get_function_call_conv(func: LLVMValueRef) -> UInt = "__llvm_get_function_call_conv"

///| Set the calling convention of a function.
/// 
/// - see llvm::Function::setCallingConv()
/// 
/// - param Fn Function to operate on
/// - param CC LLVMCallConv to set calling convention to
pub extern "C" fn llvm_set_function_call_conv(func: LLVMValueRef, cc: UInt) = "__llvm_set_function_call_conv"


///| Obtain the name of the garbage collector to use during code generation.
/// 
/// - see llvm::Function::getGC()
extern "C" fn __llvm_get_gc(func: LLVMValueRef) -> CStr = "__llvm_get_gc"
pub fn llvm_get_gc(func: LLVMValueRef) -> String {
  let cstr = __llvm_get_gc(func);
  c_str_to_moonbit_str(cstr)
}

///| Define the garbage collector to use during code generation.
/// 
/// - see llvm::Function::setGC()
extern "C" fn __llvm_set_gc(func: LLVMValueRef, name: CStr) = "__llvm_set_gc"
pub fn llvm_set_gc(func: LLVMValueRef, name: String) -> Unit {
  let cstr = moonbit_str_to_c_str(name);
  __llvm_set_gc(func, cstr)
}

///| Gets the prefix data associated with a function.
///
/// Gets the prefix data associated with a function. Only valid on functions, and
/// only if LLVMHasPrefixData returns true.
/// - see https://llvm.org/docs/LangRef.html#prefix-data
pub extern "C" fn llvm_get_prefix_data(func: LLVMValueRef) -> LLVMValueRef = "__llvm_get_prefix_data"

///| Check if a given function has prefix data.
///
/// Check if a given function has prefix data. Only valid on functions.
/// - see https://llvm.org/docs/LangRef.html#prefix-data
extern "C" fn __llvm_has_prefix_data(func: LLVMValueRef) -> LLVMBool = "__llvm_has_prefix_data"
pub fn llvm_has_prefix_data(func: LLVMValueRef) -> Bool {
  __llvm_has_prefix_data(func).to_moonbit_bool()
}

///| Sets the prefix data for the function.
///
/// Sets the prefix data for the function. Only valid on functions.
/// - see https://llvm.org/docs/LangRef.html#prefix-data
pub extern "C" fn llvm_set_prefix_data(func: LLVMValueRef, prefix_data: LLVMValueRef) = "__llvm_set_prefix_data"


///| Gets the prologue data associated with a function.
/// 
/// Gets the prologue data associated with a function. Only valid on functions,
/// and only if LLVMHasPrologueData returns true.
///
/// - see https://llvm.org/docs/LangRef.html#prologue-data
pub extern "C" fn llvm_get_prologue_data(func: LLVMValueRef) -> LLVMValueRef = "__llvm_get_prologue_data"

///| Check if a given function has prologue data.
/// 
/// Check if a given function has prologue data. Only valid on functions.
///
/// - see https://llvm.org/docs/LangRef.html#prologue-data
extern "C" fn __llvm_has_prologue_data(func: LLVMValueRef) -> LLVMBool = "__llvm_has_prologue_data"
pub fn llvm_has_prologue_data(func: LLVMValueRef) -> Bool {
  __llvm_has_prologue_data(func).to_moonbit_bool()
}

///| Sets the prologue data for the function.
///
/// Sets the prologue data for the function. Only valid on functions.
///
/// - see https://llvm.org/docs/LangRef.html#prologue-data
pub extern "C" fn llvm_set_prologue_data(func: LLVMValueRef, prologue_data: LLVMValueRef) = "__llvm_set_prologue_data"

///| Add an attribute to a function.
/// 
/// - see llvm::Function::addAttribute()
pub extern "C" fn llvm_add_attribute_at_index(f: LLVMValueRef, idx: LLVMAttributeIndex, a: LLVMAttributeRef) = "__llvm_add_attribute_at_index"

pub extern "C" fn llvm_get_attribute_count_at_index(f: LLVMValueRef, idx: LLVMAttributeIndex) -> UInt = "__llvm_get_attribute_count_at_index"

pub extern "C" fn llvm_get_attributes_at_index(f: LLVMValueRef, idx: LLVMAttributeIndex) -> Array[LLVMAttributeRef] = "__llvm_get_attributes_at_index"

pub extern "C" fn llvm_get_enum_attribute_at_index(f: LLVMValueRef, idx: LLVMAttributeIndex, kind_id: UInt) -> LLVMAttributeRef = "__llvm_get_enum_attribute_at_index"

extern "C" fn __llvm_get_string_attribute_at_index(f: LLVMValueRef, idx: LLVMAttributeIndex, k: CStr, k_len: UInt) -> LLVMAttributeRef = "__llvm_get_string_attribute_at_index"
pub fn llvm_get_string_attribute_at_index(f: LLVMValueRef, idx: LLVMAttributeIndex, k: String) -> LLVMAttributeRef {
  let cstr = moonbit_str_to_c_str(k);
  let len = k.length().reinterpret_as_uint();
  __llvm_get_string_attribute_at_index(f, idx, cstr, len)
}

pub extern "C" fn llvm_remove_enum_attribute_at_index(f: LLVMValueRef, idx: LLVMAttributeIndex, kind_id: UInt) = "__llvm_remove_enum_attribute_at_index"

extern "C" fn __llvm_remove_string_attribute_at_index(f: LLVMValueRef, idx: LLVMAttributeIndex, k: CStr, k_len: UInt) = "__llvm_remove_string_attribute_at_index"
pub fn llvm_remove_string_attribute_at_index(f: LLVMValueRef, idx: LLVMAttributeIndex, k: String) -> Unit {
  let cstr = moonbit_str_to_c_str(k);
  let len = k.length().reinterpret_as_uint();
  __llvm_remove_string_attribute_at_index(f, idx, cstr, len)
}


///| Add a target-dependent attribute to a function
///
/// - see llvm::AttrBuilder::addAttribute()
extern "C" fn __llvm_add_target_dependent_function_attr(func: LLVMValueRef, a: CStr, v: CStr) = "__llvm_add_target_dependent_function_attr"

///| Add a target-dependent attribute to a function
///
/// - see llvm::AttrBuilder::addAttribute()
pub fn llvm_add_target_dependent_function_attr(func: LLVMValueRef, a: String, v: String) -> Unit {
  let attr = moonbit_str_to_c_str(a);
  let val = moonbit_str_to_c_str(v);
  __llvm_add_target_dependent_function_attr(func, attr, val)
}

///| Obtain the number of parameters in a function.
/// 
/// - see llvm::Function::arg_size()
pub extern "C" fn llvm_count_params(func: LLVMValueRef) -> UInt = "__llvm_count_params"


///| Obtain the parameters in a function.
/// 
/// The takes a pointer to a pre-allocated array of LLVMValueRef that is
/// at least LLVMCountParams() long. This array will be filled with
/// LLVMValueRef instances which correspond to the parameters the
/// function receives. Each LLVMValueRef corresponds to a llvm::Argument
/// instance.
/// 
/// - see llvm::Function::arg_begin()
/// 
// FIXME: Not implemented
pub extern "C" fn llvm_get_params(func: LLVMValueRef) -> Array[LLVMValueRef] = "__llvm_get_params"
pub fn LLVMValueRef::get_params(self: LLVMValueRef) -> Array[LLVMValueRef] {
  llvm_get_params(self)
}

// FIXME: Check doc if it is correct
///| Obtain the parameter at the specified index.
/// 
/// Parameters are indexed from 0.
/// 
/// - see llvm::Function::arg_begin()
pub extern "C" fn llvm_get_param(func: LLVMValueRef, index: UInt) -> LLVMValueRef = "__llvm_get_param"
pub fn LLVMValueRef::get_param(self: LLVMValueRef, index: UInt) -> LLVMValueRef {
  llvm_get_param(self, index)
}

///| Obtain the function to which this argument belongs.
/// 
/// Unlike other functions in this group, this one takes an LLVMValueRef
/// that corresponds to a llvm::Attribute.
/// 
/// The returned LLVMValueRef is the llvm::Function to which this
/// argument belongs.
pub extern "C" fn llvm_get_param_parent(inst: LLVMValueRef) -> LLVMValueRef = "__llvm_get_param_parent"

///| Obtain the function to which this argument belongs.
/// 
/// Unlike other functions in this group, this one takes an LLVMValueRef
/// that corresponds to a llvm::Attribute.
/// 
/// The returned LLVMValueRef is the llvm::Function to which this
/// argument belongs.
pub fn LLVMValueRef::get_param_parent(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_param_parent(self)
}

///| Obtain the first parameter to a function.
/// 
/// - see llvm::Function::arg_begin()
pub extern "C" fn llvm_get_first_param(func: LLVMValueRef) -> LLVMValueRef = "__llvm_get_first_param"

///| Obtain the first parameter to a function.
/// 
/// - see llvm::Function::arg_begin()
pub fn LLVMValueRef::get_first_param(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_first_param(self)
}


///| Obtain the last parameter to a function.
/// 
/// - see llvm::Function::arg_end()
pub extern "C" fn llvm_get_last_param(func: LLVMValueRef) -> LLVMValueRef = "__llvm_get_last_param"

///| Obtain the last parameter to a function.
/// 
/// - see llvm::Function::arg_end()
pub fn LLVMValueRef::get_last_param(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_last_param(self)
}


///| Obtain the next parameter to a function.
/// 
/// This takes an LLVMValueRef obtained from LLVMGetFirstParam() (which is
/// actually a wrapped iterator) and obtains the next parameter from the
/// underlying iterator.
pub extern "C" fn llvm_get_next_param(arg: LLVMValueRef) -> LLVMValueRef = "__llvm_get_next_param"

///| Obtain the next parameter to a function.
/// 
/// This takes an LLVMValueRef obtained from LLVMGetFirstParam() (which is
/// actually a wrapped iterator) and obtains the next parameter from the
/// underlying iterator.
pub fn LLVMValueRef::get_next_param(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_next_param(self)
}

///| Obtain the previous parameter to a function.
/// 
/// This is the opposite of LLVMGetNextParam().
pub extern "C" fn llvm_get_previous_param(arg: LLVMValueRef) -> LLVMValueRef = "__llvm_get_previous_param"

///| Obtain the previous parameter to a function.
/// 
/// This is the opposite of LLVMGetNextParam().
pub fn LLVMValueRef::get_previous_param(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_previous_param(self)
}

///| Set the alignment for a function parameter.
/// 
/// - see llvm::Argument::addAttr()
/// - see llvm::AttrBuilder::addAlignmentAttr()
/// 
pub extern "C" fn llvm_set_param_alignment(arg: LLVMValueRef, align: UInt) = "__llvm_set_param_alignment"

///| Set the alignment for a function parameter.
/// 
/// - see llvm::Argument::addAttr()
/// - see llvm::AttrBuilder::addAlignmentAttr()
/// 
pub fn LLVMValueRef::set_param_alignment(self: LLVMValueRef, align: UInt) -> Unit {
  llvm_set_param_alignment(self, align)
}

///| Add a global indirect function to a module under a specified name.
/// 
/// - see llvm::GlobalIFunc::create()
extern "C" fn __llvm_add_global_ifunc(m: LLVMModuleRef, name: CStr, name_len: UInt64, ty: LLVMTypeRef, addr_space: UInt, resolver: LLVMValueRef) -> LLVMValueRef = "__llvm_add_global_ifunc"

///| Add a global indirect function to a module under a specified name.
/// 
/// - see llvm::GlobalIFunc::create()
pub fn llvm_add_global_ifunc(m: LLVMModuleRef, name: String, ty: LLVMTypeRef, addr_space: UInt, resolver: LLVMValueRef) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(name);
  __llvm_add_global_ifunc(m, cstr, name.length().to_uint64(), ty, addr_space, resolver)
}

///| Add a global indirect function to a module under a specified name.
/// 
/// - see llvm::GlobalIFunc::create()
pub fn LLVMModuleRef::add_global_ifunc(self: LLVMModuleRef, name: String, ty: LLVMTypeRef, addr_space: UInt, resolver: LLVMValueRef) -> LLVMValueRef {
  llvm_add_global_ifunc(self, name, ty, addr_space, resolver)
}

///| Obtain a GlobalIFunc value from a Module by its name.
extern "C" fn __llvm_get_named_global_ifunc(m: LLVMModuleRef, name: CStr, name_len: UInt64) -> LLVMValueRef = "__llvm_get_named_global_ifunc"

///| Obtain a GlobalIFunc value from a Module by its name.
pub fn llvm_get_named_global_ifunc(m: LLVMModuleRef, name: String) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(name);
  __llvm_get_named_global_ifunc(m, cstr, name.length().to_uint64())
}

///| Obtain a GlobalIFunc value from a Module by its name.
pub fn LLVMModuleRef::get_named_global_ifunc(self: LLVMModuleRef, name: String) -> LLVMValueRef {
  llvm_get_named_global_ifunc(self, name)
}

///| Obtain an iterator to the first GlobalIFunc in a Module.
pub extern "C" fn llvm_get_first_global_ifunc(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_first_global_ifunc"

///| Obtain an iterator to the first GlobalIFunc in a Module.
pub fn LLVMModuleRef::get_first_global_ifunc(self: LLVMModuleRef) -> LLVMValueRef {
  llvm_get_first_global_ifunc(self)
}

///| Obtain an iterator to the last GlobalIFunc in a Module.
pub extern "C" fn llvm_get_last_global_ifunc(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_last_global_ifunc"

///| Obtain an iterator to the last GlobalIFunc in a Module.
pub fn LLVMModuleRef::get_last_global_ifunc(self: LLVMModuleRef) -> LLVMValueRef {
  llvm_get_last_global_ifunc(self)
}

///| Advance a GlobalIFunc iterator to the next GlobalIFunc.
pub extern "C" fn llvm_get_next_global_ifunc(ifunc: LLVMValueRef) -> LLVMValueRef = "__llvm_get_next_global_ifunc"

///| Advance a GlobalIFunc iterator to the next GlobalIFunc.
pub fn LLVMValueRef::get_next_global_ifunc(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_next_global_ifunc(self)
}

///| Decrement a GlobalIFunc iterator to the previous GlobalIFunc.
pub extern "C" fn llvm_get_previous_global_ifunc(ifunc: LLVMValueRef) -> LLVMValueRef = "__llvm_get_previous_global_ifunc"

///| Decrement a GlobalIFunc iterator to the previous GlobalIFunc.
pub fn LLVMValueRef::get_previous_global_ifunc(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_previous_global_ifunc(self)
}

///| Get the resolver for a GlobalIFunc value.
pub extern "C" fn llvm_get_global_ifunc_resolver(ifunc: LLVMValueRef) -> LLVMValueRef = "__llvm_get_global_ifunc_resolver"

///| Get the resolver for a GlobalIFunc value.
pub fn LLVMValueRef::get_global_ifunc_resolver(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_global_ifunc_resolver(self)
}

///| Set the resolver for a GlobalIFunc value.
pub extern "C" fn llvm_set_global_ifunc_resolver(ifunc: LLVMValueRef, resolver: LLVMValueRef) = "__llvm_set_global_ifunc_resolver"

///| Set the resolver for a GlobalIFunc value.
pub fn LLVMValueRef::set_global_ifunc_resolver(self: LLVMValueRef, resolver: LLVMValueRef) -> Unit {
  llvm_set_global_ifunc_resolver(self, resolver)
}

///| Erase a GlobalIFunc value from a Module.
pub extern "C" fn llvm_erase_global_ifunc(ifunc: LLVMValueRef) = "__llvm_erase_global_ifunc"

///| Erase a GlobalIFunc value from a Module.
pub fn LLVMValueRef::erase_global_ifunc(self: LLVMValueRef) -> Unit {
  llvm_erase_global_ifunc(self)
}

///| Remove a GlobalIFunc value from a Module.
pub extern "C" fn llvm_remove_global_ifunc(ifunc: LLVMValueRef) = "__llvm_remove_global_ifunc"

///| Remove a GlobalIFunc value from a Module.
pub fn LLVMValueRef::remove_global_ifunc(self: LLVMValueRef) -> Unit {
  llvm_remove_global_ifunc(self)
}

extern "C" fn __llvm_md_string_in_context2(context: LLVMContextRef, str: CStr, s_len: UInt64) -> LLVMMetadataRef = "__llvm_md_string_in_context2"
pub fn llvm_md_string_in_context2(context: LLVMContextRef, str: String) -> LLVMMetadataRef {
  let cstr = moonbit_str_to_c_str(str);
  __llvm_md_string_in_context2(context, cstr, str.length().to_uint64())
}
pub fn LLVMContextRef::md_string_in_context2(self: LLVMContextRef, str: String) -> LLVMMetadataRef {
  llvm_md_string_in_context2(self, str)
}

pub extern "C" fn llvm_md_node_in_context2(context: LLVMContextRef, mds: Array[LLVMMetadataRef]) -> LLVMMetadataRef = "__llvm_md_node_in_context2"
pub fn LLVMContextRef::md_node_in_context2(self: LLVMContextRef, mds: Array[LLVMMetadataRef]) -> LLVMMetadataRef {
  llvm_md_node_in_context2(self, mds)
}

pub extern "C" fn llvm_metadata_as_value(context: LLVMContextRef, md: LLVMMetadataRef) -> LLVMValueRef = "__llvm_metadata_as_value"

pub extern "C" fn llvm_value_as_metadata(val: LLVMValueRef) -> LLVMMetadataRef = "__llvm_value_as_metadata"
pub fn LLVMValueRef::as_metadata(self: LLVMValueRef) -> LLVMMetadataRef {
  llvm_value_as_metadata(self)
}

// FIXME: Not implemented
extern "C" fn __llvm_get_md_string(v: LLVMValueRef) -> (CStr, UInt) = "__llvm_get_md_string"
pub fn llvm_get_md_string(v: LLVMValueRef) -> String {
  let (cstr, len) = __llvm_get_md_string(v);
  c_str_to_moonbit_str_with_length(cstr, len)
}
pub fn LLVMValueRef::get_md_string(self: LLVMValueRef) -> String {
  llvm_get_md_string(self)
}

pub extern "C" fn llvm_get_md_node_num_operands(v: LLVMValueRef) -> UInt = "__llvm_get_md_node_num_operands"
pub fn LLVMValueRef::get_md_node_num_operands(self: LLVMValueRef) -> UInt {
  llvm_get_md_node_num_operands(self)
}

// FIXME: Not implemented
pub extern "C" fn llvm_get_md_node_operands(v: LLVMValueRef) -> Array[LLVMValueRef] = "__llvm_get_md_node_operands" 
pub fn LLVMValueRef::get_md_node_operands(self: LLVMValueRef) -> Array[LLVMValueRef] {
  llvm_get_md_node_operands(self)
}

pub extern "C" fn llvm_replace_md_node_operand_with(v: LLVMValueRef, index: UInt, replacement: LLVMMetadataRef) = "__llvm_replace_md_node_operand_with"
pub fn LLVMValueRef::replace_md_node_operand_with(self: LLVMValueRef, index: UInt, replacement: LLVMMetadataRef) -> Unit {
  llvm_replace_md_node_operand_with(self, index, replacement)
}

extern "C" fn __llvm_md_string_in_context(context: LLVMContextRef, str: CStr, s_len: UInt) -> LLVMValueRef = "__llvm_md_string_in_context"
pub fn llvm_md_string_in_context(context: LLVMContextRef, str: String) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(str);
  __llvm_md_string_in_context(context, cstr, str.length().reinterpret_as_uint())
}
pub fn LLVMContextRef::md_string_in_context(self: LLVMContextRef, str: String) -> LLVMValueRef {
  llvm_md_string_in_context(self, str)
}

extern "C" fn __llvm_md_string(str: CStr, s_len: UInt) -> LLVMValueRef = "__llvm_md_string"
pub fn llvm_md_string(str: String) -> LLVMValueRef {
  let cstr = moonbit_str_to_c_str(str);
  __llvm_md_string(cstr, str.length().reinterpret_as_uint())
}
pub fn LLVMValueRef::md_string(self: String) -> LLVMValueRef {
  llvm_md_string(self)
}

pub extern "C" fn llvm_md_node_in_context(context: LLVMContextRef, vals: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_md_node_in_context"
pub fn LLVMContextRef::md_node_in_context(self: LLVMContextRef, vals: Array[LLVMValueRef]) -> LLVMValueRef {
  llvm_md_node_in_context(self, vals)
}

pub extern "C" fn llvm_md_node(vals: Array[LLVMValueRef], count: UInt) -> LLVMValueRef = "__llvm_md_node"
pub fn LLVMValueRef::md_node(self: Array[LLVMValueRef], count: UInt) -> LLVMValueRef {
  llvm_md_node(self, count)
}

///| Create operand bundle.
extern "C" fn __llvm_create_operand_bundle(tag: CStr, tag_len: UInt64, args: Array[LLVMValueRef]) -> LLVMOperandBundleRef = "__llvm_create_operand_bundle"

///| Create operand bundle.
pub fn llvm_create_operand_bundle(tag: String, args: Array[LLVMValueRef]) -> LLVMOperandBundleRef {
  let cstr = moonbit_str_to_c_str(tag);
  __llvm_create_operand_bundle(cstr, tag.length().to_uint64(), args)
}

///| Dispose operand bundle.
pub extern "C" fn llvm_dispose_operand_bundle(bundle: LLVMOperandBundleRef) = "__llvm_dispose_operand_bundle"

///| Dispose operand bundle.
pub fn LLVMOperandBundleRef::dispose(self: LLVMOperandBundleRef) -> Unit {
  llvm_dispose_operand_bundle(self)
}

///| Get the tag of an operand bundle.
// FIXME: Not implemented
extern "C" fn __llvm_get_operand_bundle_tag(bundle: LLVMOperandBundleRef) -> (CStr, UInt64) = "__llvm_get_operand_bundle_tag"

///| Get the tag of an operand bundle.
pub fn llvm_get_operand_bundle_tag(bundle: LLVMOperandBundleRef) -> String {
  let (cstr, len) = __llvm_get_operand_bundle_tag(bundle);
  c_str_to_moonbit_str_with_length(cstr, len.to_uint())
}

///| Get the number of arguments in an operand bundle.
pub extern "C" fn llvm_get_num_operand_bundle_args(bundle: LLVMOperandBundleRef) -> UInt = "__llvm_get_num_operand_bundle_args"

///| Get the number of arguments in an operand bundle.
pub fn LLVMOperandBundleRef::get_num_args(self: LLVMOperandBundleRef) -> UInt {
  llvm_get_num_operand_bundle_args(self)
}

///| Get the argument at the specified index in an operand bundle.
pub extern "C" fn llvm_get_operand_bundle_arg_at_index(bundle: LLVMOperandBundleRef, index: UInt) -> LLVMValueRef = "__llvm_get_operand_bundle_arg_at_index"

///| Get the argument at the specified index in an operand bundle.
pub fn LLVMOperandBundleRef::get_arg(self: LLVMOperandBundleRef, index: UInt) -> LLVMValueRef {
  llvm_get_operand_bundle_arg_at_index(self, index)
}

///| Cast BasicBlock to Value.
pub extern "C" fn llvm_basic_block_as_value(bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_basic_block_as_value"

///| Cast BasicBlock to Value.
pub fn LLVMBasicBlockRef::as_value_ref(self: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_basic_block_as_value(self)
}

///| Check if a value is a basic block.
extern "C" fn __llvm_value_is_basic_block(val: LLVMValueRef) -> LLVMBool = "__llvm_value_is_basic_block"

///| Check if a value is a basic block.
pub fn llvm_value_is_basic_block(val: LLVMValueRef) -> Bool {
  __llvm_value_is_basic_block(val).to_moonbit_bool()
}

///| Check if a value is a basic block.
pub fn LLVMValueRef::is_basic_block(self: LLVMValueRef) -> Bool {
  llvm_value_is_basic_block(self)
}

///| Convert a Value to a BasicBlock.
pub extern "C" fn llvm_value_as_basic_block(val: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_value_as_basic_block"

///| Convert a Value to a BasicBlock.
pub fn LLVMValueRef::as_basic_block(self: LLVMValueRef) -> LLVMBasicBlockRef {
  llvm_value_as_basic_block(self)
}

///| Get the name of a basic block.
extern "C" fn __llvm_get_basic_block_name(bb: LLVMBasicBlockRef) -> CStr = "__llvm_get_basic_block_name"

///| Get the name of a basic block.
pub fn llvm_get_basic_block_name(bb: LLVMBasicBlockRef) -> String {
  let name = __llvm_get_basic_block_name(bb);
  c_str_to_moonbit_str(name)
}

///| Get the name of a basic block.
pub fn LLVMBasicBlockRef::get_name(self: LLVMBasicBlockRef) -> String {
  llvm_get_basic_block_name(self)
}

///| Get the parent function of a basic block.
pub extern "C" fn llvm_get_basic_block_parent(bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_get_basic_block_parent"

///| Get the parent function of a basic block.
pub fn LLVMBasicBlockRef::get_parent(self: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_get_basic_block_parent(self)
}

///| Get the terminator instruction of a basic block.
pub extern "C" fn llvm_get_basic_block_terminator(bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_get_basic_block_terminator"

///| Get the terminator instruction of a basic block.
pub fn LLVMBasicBlockRef::get_terminator(self: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_get_basic_block_terminator(self)
}

///| Get the first instruction in a basic block.
pub extern "C" fn llvm_count_basic_blocks(func: LLVMValueRef) -> UInt = "__llvm_count_basic_blocks"

///| Get the first instruction in a basic block.
pub fn LLVMValueRef::count_basic_blocks(self: LLVMValueRef) -> UInt {
  llvm_count_basic_blocks(self)
}

///| Get all basic blocks in a function.
pub extern "C" fn llvm_get_basic_blocks(func: LLVMValueRef) -> Array[LLVMBasicBlockRef] = "__llvm_get_basic_blocks"

///| Get all basic blocks in a function.
pub fn LLVMValueRef::get_basic_blocks(self: LLVMValueRef) -> Array[LLVMBasicBlockRef] {
  llvm_get_basic_blocks(self)
}

///| Get the first basic block in a function.
pub extern "C" fn llvm_get_first_basic_block(func: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_first_basic_block"

///| Get the first basic block in a function.
pub fn LLVMValueRef::get_first_basic_block(self: LLVMValueRef) -> LLVMBasicBlockRef {
  llvm_get_first_basic_block(self)
}

///| Get the last basic block in a function.
pub extern "C" fn llvm_get_last_basic_block(func: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_last_basic_block"

///| Get the last basic block in a function.
pub fn LLVMValueRef::get_last_basic_block(self: LLVMValueRef) -> LLVMBasicBlockRef {
  llvm_get_last_basic_block(self)
}

///| Get the next basic block in a function.
pub extern "C" fn llvm_get_next_basic_block(bb: LLVMBasicBlockRef) -> LLVMBasicBlockRef = "__llvm_get_next_basic_block"

///| Get the next basic block in a function.
pub fn LLVMBasicBlockRef::get_next_basic_block(self: LLVMBasicBlockRef) -> LLVMBasicBlockRef {
  llvm_get_next_basic_block(self)
}

///| Get the previous basic block in a function.
pub extern "C" fn llvm_get_previous_basic_block(bb: LLVMBasicBlockRef) -> LLVMBasicBlockRef = "__llvm_get_previous_basic_block"

///| Get the previous basic block in a function.
pub fn LLVMBasicBlockRef::get_previous_basic_block(self: LLVMBasicBlockRef) -> LLVMBasicBlockRef {
  llvm_get_previous_basic_block(self)
}

///| Get the entry basic block of a function.
pub extern "C" fn llvm_get_entry_basic_block(func: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_entry_basic_block"

///| Get the entry basic block of a function.
pub fn LLVMValueRef::get_entry_basic_block(self: LLVMValueRef) -> LLVMBasicBlockRef {
  llvm_get_entry_basic_block(self)
}

///| Insert a basic block before another basic block.
pub extern "C" fn llvm_insert_existing_basic_block_after_insert_block(builder: LLVMBuilderRef, bb: LLVMBasicBlockRef) = "__llvm_insert_existing_basic_block_after_insert_block"

///| Insert a basic block before another basic block.
pub fn LLVMBuilderRef::insert_existing_basic_block_after_insert_block(self: LLVMBuilderRef, bb: LLVMBasicBlockRef) -> Unit {
  llvm_insert_existing_basic_block_after_insert_block(self, bb)
}

///| Append a basic block to a function.
pub extern "C" fn llvm_append_existing_basic_block(func: LLVMValueRef, bb: LLVMBasicBlockRef) = "__llvm_append_existing_basic_block"

///| Append a basic block to a function.
pub fn LLVMValueRef::append_existing_basic_block(self: LLVMValueRef, bb: LLVMBasicBlockRef) -> Unit {
  llvm_append_existing_basic_block(self, bb)
}

///| Create a basic block in a context.
extern "C" fn __llvm_create_basic_block_in_context(context: LLVMContextRef, name: CStr) -> LLVMBasicBlockRef = "__llvm_create_basic_block_in_context"

///| Create a basic block in a context.
pub fn llvm_create_basic_block_in_context(context: LLVMContextRef, name: String) -> LLVMBasicBlockRef {
  let cstr = moonbit_str_to_c_str(name);
  __llvm_create_basic_block_in_context(context, cstr)
}

///| Append a basic block to a function.
extern "C" fn __llvm_append_basic_block_in_context(context: LLVMContextRef, func: LLVMValueRef, name: CStr) -> LLVMBasicBlockRef = "__llvm_append_basic_block_in_context"

///| Append a basic block to a function.
pub fn llvm_append_basic_block_in_context(context: LLVMContextRef, func: LLVMValueRef, name: String) -> LLVMBasicBlockRef {
  let cstr = moonbit_str_to_c_str(name);
  __llvm_append_basic_block_in_context(context, func, cstr)
}

///| Append a basic block to a function.
extern "C" fn __llvm_append_basic_block(func: LLVMValueRef, name: CStr) -> LLVMBasicBlockRef = "__llvm_append_basic_block"

///| Append a basic block to a function.
pub fn llvm_append_basic_block(func: LLVMValueRef, name: String) -> LLVMBasicBlockRef {
  let cstr = moonbit_str_to_c_str(name);
  __llvm_append_basic_block(func, cstr)
}

///| Insert a basic block after another basic block in context.
extern "C" fn __llvm_insert_basic_block_in_context(context: LLVMContextRef, bb: LLVMBasicBlockRef, name: CStr) -> LLVMBasicBlockRef = "__llvm_insert_basic_block_in_context"

///| Insert a basic block after another basic block in context.
pub fn llvm_insert_basic_block_in_context(context: LLVMContextRef, bb: LLVMBasicBlockRef, name: String) -> LLVMBasicBlockRef {
  let cstr = moonbit_str_to_c_str(name);
  __llvm_insert_basic_block_in_context(context, bb, cstr)
}

///| Insert a basic block after another basic block.
extern "C" fn __llvm_insert_basic_block(insert_before_bb: LLVMBasicBlockRef, name: CStr) -> LLVMBasicBlockRef = "__llvm_insert_basic_block"

///| Insert a basic block after another basic block.
pub fn llvm_insert_basic_block(insert_before_bb: LLVMBasicBlockRef, name: String) -> LLVMBasicBlockRef {
  let cstr = moonbit_str_to_c_str(name);
  __llvm_insert_basic_block(insert_before_bb, cstr)
}

///| Delete a basic block.
pub extern "C" fn llvm_delete_basic_block(bb: LLVMBasicBlockRef) = "__llvm_delete_basic_block"

///| Delete a basic block.
pub fn LLVMBasicBlockRef::delete(self: LLVMBasicBlockRef) -> Unit {
  llvm_delete_basic_block(self)
}

///| Remove a basic block from a function.
pub extern "C" fn llvm_remove_basic_block_from_parent(bb: LLVMBasicBlockRef) = "__llvm_remove_basic_block_from_parent"

///| Remove a basic block from a function.
pub fn LLVMBasicBlockRef::remove_from_parent(self: LLVMBasicBlockRef) -> Unit {
  llvm_remove_basic_block_from_parent(self)
}

///| Move a basic block to before another basic block.
pub extern "C" fn llvm_move_basic_block_before(bb: LLVMBasicBlockRef, move_pos: LLVMBasicBlockRef) = "__llvm_move_basic_block_before"

///| Move a basic block to before another basic block.
pub fn LLVMBasicBlockRef::move_before(self: LLVMBasicBlockRef, move_pos: LLVMBasicBlockRef) -> Unit {
  llvm_move_basic_block_before(self, move_pos)
}

///| Move a basic block to after another basic block.
pub extern "C" fn llvm_move_basic_block_after(bb: LLVMBasicBlockRef, move_pos: LLVMBasicBlockRef) = "__llvm_move_basic_block_after"

///| Move a basic block to after another basic block.
pub fn LLVMBasicBlockRef::move_after(self: LLVMBasicBlockRef, move_pos: LLVMBasicBlockRef) -> Unit {
  llvm_move_basic_block_after(self, move_pos)
}

///| Get the first instruction in a basic block.
pub extern "C" fn llvm_get_first_instruction(bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_get_first_instruction"

///| Get the first instruction in a basic block.
pub fn LLVMBasicBlockRef::get_first_instruction(self: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_get_first_instruction(self)
}

///| Get the last instruction in a basic block.
pub extern "C" fn llvm_get_last_instruction(bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_get_last_instruction"

///| Get the last instruction in a basic block.
pub fn LLVMBasicBlockRef::get_last_instruction(self: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_get_last_instruction(self)
}

/// Check if the value has metadata attached.
extern "C" fn __llvm_has_metadata(val: LLVMValueRef) -> LLVMBool = "__llvm_has_metadata"

/// Check if the value has metadata attached.
pub fn llvm_has_metadata(val: LLVMValueRef) -> Bool {
  __llvm_has_metadata(val).to_moonbit_bool()
}

/// Check if the value has metadata attached.
pub fn LLVMValueRef::has_metadata(self: LLVMValueRef) -> Bool {
  __llvm_has_metadata(self).to_moonbit_bool()
}

///| Get the metadata of a value.
pub extern "C" fn llvm_get_metadata(val: LLVMValueRef, kind_id: UInt) -> LLVMValueRef = "__llvm_get_metadata"

///| Get the metadata of a value.
pub fn LLVMValueRef::get_metadata(self: LLVMValueRef, kind_id: UInt) -> LLVMValueRef {
  llvm_get_metadata(self, kind_id)
}

///| Set the metadata of a value.
pub extern "C" fn llvm_set_metadata(val: LLVMValueRef, kind_id: UInt, node: LLVMValueRef) = "__llvm_set_metadata"

///| Set the metadata of a value.
pub fn LLVMValueRef::set_metadata(self: LLVMValueRef, kind_id: UInt, node: LLVMValueRef) -> Unit {
  llvm_set_metadata(self, kind_id, node)
}

// pub extern "C" fn llvm_instruction_get_all_metadata_other_than_debug_loc(instr: LLVMValueRef, num_entries: Ptr[UInt64]) -> Ptr[LLVMValueMetadataEntry] = "__llvm_instruction_get_all_metadata_other_than_debug_loc"

///| Get the basic block of an instruction.
pub extern "C" fn llvm_get_instruction_parent(inst: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_instruction_parent"

///| Get the basic block of an instruction.
pub fn LLVMValueRef::get_instruction_parent(self: LLVMValueRef) -> LLVMBasicBlockRef {
  llvm_get_instruction_parent(self)
}

///| Get the next instruction of the given instruction.
pub extern "C" fn llvm_get_next_instruction(inst: LLVMValueRef) -> LLVMValueRef = "__llvm_get_next_instruction"

///| Get the next instruction of the given instruction.
pub fn LLVMValueRef::get_next_instruction(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_next_instruction(self)
}

///| Get the previous instruction of the given instruction.
pub extern "C" fn llvm_get_previous_instruction(inst: LLVMValueRef) -> LLVMValueRef = "__llvm_get_previous_instruction"

///| Get the previous instruction of the given instruction.
pub fn LLVMValueRef::get_previous_instruction(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_previous_instruction(self)
}

///| Remove an instruction from its containing basic block and delete it.
pub extern "C" fn llvm_instruction_remove_from_parent(inst: LLVMValueRef) = "__llvm_instruction_remove_from_parent"

///| Remove an instruction from its containing basic block and delete it.
pub fn LLVMValueRef::instruction_remove_from_parent(self: LLVMValueRef) -> Unit {
  llvm_instruction_remove_from_parent(self)
}

///| Remove an instruction from its containing basic block and delete it.
pub extern "C" fn llvm_instruction_erase_from_parent(inst: LLVMValueRef) = "__llvm_instruction_erase_from_parent"

///| Remove an instruction from its containing basic block and delete it.
pub fn LLVMValueRef::instruction_erase_from_parent(self: LLVMValueRef) -> Unit {
  llvm_instruction_erase_from_parent(self)
}

///| Remove an instruction from its containing basic block and delete it.
pub extern "C" fn llvm_delete_instruction(inst: LLVMValueRef) = "__llvm_delete_instruction"

///| Remove an instruction from its containing basic block and delete it.
pub fn LLVMValueRef::delete_instruction(self: LLVMValueRef) -> Unit {
  llvm_delete_instruction(self)
}

///| Obtain the code opcode for an individual instruction.
/// 
/// - see llvm::Instruction::getOpCode()
extern "C" fn __llvm_get_instruction_opcode(inst: LLVMValueRef) -> Int = "__llvm_get_instruction_opcode"
pub fn llvm_get_instruction_opcode(inst: LLVMValueRef) -> LLVMOpcode {
  let opcode = __llvm_get_instruction_opcode(inst);
  LLVMOpcode::from_int(opcode)
}


///| Obtain the predicate of an instruction.
/// 
/// This is only valid for instructions that correspond to llvm::ICmpInst.
/// 
/// - see llvm::ICmpInst::getPredicate()
extern "C" fn __llvm_get_icmp_predicate(inst: LLVMValueRef) -> Int = "__llvm_get_icmp_predicate"

///| Obtain the predicate of an instruction.
/// 
/// This is only valid for instructions that correspond to llvm::ICmpInst.
/// 
/// - see llvm::ICmpInst::getPredicate()
pub fn llvm_get_icmp_predicate(inst: LLVMValueRef) -> LLVMIntPredicate {
  let predicate = __llvm_get_icmp_predicate(inst);
  LLVMIntPredicate::from_int(predicate)
}

///| Obtain the predicate of an instruction.
/// 
/// This is only valid for instructions that correspond to llvm::ICmpInst.
/// 
/// - see llvm::ICmpInst::getPredicate()
pub fn LLVMValueRef::get_icmp_predicate(self: LLVMValueRef) -> LLVMIntPredicate {
  llvm_get_icmp_predicate(self)
}


///| Obtain the float predicate of an instruction.
/// 
/// This is only valid for instructions that correspond to llvm::FCmpInst.
/// 
/// - see llvm::FCmpInst::getPredicate()
extern "C" fn __llvm_get_fcmp_predicate(inst: LLVMValueRef) -> Int = "__llvm_get_fcmp_predicate"
pub fn llvm_get_fcmp_predicate(inst: LLVMValueRef) -> LLVMRealPredicate {
  let predicate = __llvm_get_fcmp_predicate(inst);
  LLVMRealPredicate::from_int(predicate)
}

///| Create a copy of 'this' instruction that is identical in all ways
/// except the following:
///   * The instruction has no parent
///   * The instruction has no name
/// 
/// - see llvm::Instruction::clone()
pub extern "C" fn llvm_instruction_clone(inst: LLVMValueRef) -> LLVMValueRef = "__llvm_instruction_clone"

///| Create a copy of 'this' instruction that is identical in all ways
/// except the following:
///   * The instruction has no parent
///   * The instruction has no name
/// 
/// - see llvm::Instruction::clone()
pub fn LLVMValueRef::instruction_clone(self: LLVMValueRef) -> LLVMValueRef {
  llvm_instruction_clone(self)
}

///| Determine whether an instruction is a terminator.
///
/// Determine whether an instruction is a terminator. This routine is named to
/// be compatible with historical functions that did this by querying the
/// underlying C++ type.
/// 
/// - see llvm::Instruction::isTerminator()
pub extern "C" fn llvm_isa_terminator_inst(inst: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_terminator_inst"

///| Determine whether an instruction is a terminator.
///
/// Determine whether an instruction is a terminator. This routine is named to
/// be compatible with historical functions that did this by querying the
/// underlying C++ type.
/// 
/// - see llvm::Instruction::isTerminator()
pub fn LLVMValueRef::isa_terminator_inst(self: LLVMValueRef) -> LLVMValueRef {
  llvm_isa_terminator_inst(self)
}

///| Obtain the first debug record attached to an instruction.
/// 
/// Use LLVMGetNextDbgRecord() and LLVMGetPreviousDbgRecord() to traverse the
/// sequence of DbgRecords.
/// 
/// Return the first DbgRecord attached to Inst or NULL if there are none.
/// 
/// - see llvm::Instruction::getDbgRecordRange()
pub extern "C" fn llvm_get_first_dbg_record(inst: LLVMValueRef) -> LLVMDbgRecordRef = "__llvm_get_first_dbg_record"

///| Obtain the first debug record attached to an instruction.
/// 
/// Use LLVMGetNextDbgRecord() and LLVMGetPreviousDbgRecord() to traverse the
/// sequence of DbgRecords.
/// 
/// Return the first DbgRecord attached to Inst or NULL if there are none.
/// 
/// - see llvm::Instruction::getDbgRecordRange()
pub fn LLVMValueRef::get_first_dbg_record(self: LLVMValueRef) -> LLVMDbgRecordRef {
  llvm_get_first_dbg_record(self)
}

///| Obtain the last debug record attached to an instruction.
/// 
/// Return the last DbgRecord attached to Inst or NULL if there are none.
/// 
/// - see llvm::Instruction::getDbgRecordRange()
pub extern "C" fn llvm_get_last_dbg_record(inst: LLVMValueRef) -> LLVMDbgRecordRef = "__llvm_get_last_dbg_record"

///| Obtain the last debug record attached to an instruction.
/// 
/// Return the last DbgRecord attached to Inst or NULL if there are none.
/// 
/// - see llvm::Instruction::getDbgRecordRange()
pub fn LLVMValueRef::get_last_dbg_record(self: LLVMValueRef) -> LLVMDbgRecordRef {
  llvm_get_last_dbg_record(self)
}

///| Obtain the next DbgRecord in the sequence or NULL if there are no more.
/// 
/// - see llvm::Instruction::getDbgRecordRange()
pub extern "C" fn llvm_get_next_dbg_record(dbr: LLVMDbgRecordRef) -> LLVMDbgRecordRef = "__llvm_get_next_dbg_record"

///| Obtain the next DbgRecord in the sequence or NULL if there are no more.
/// 
/// - see llvm::Instruction::getDbgRecordRange()
pub fn LLVMDbgRecordRef::get_next_dbg_record(self: LLVMDbgRecordRef) -> LLVMDbgRecordRef {
  llvm_get_next_dbg_record(self)
}

///| Obtain the previous DbgRecord in the sequence or NULL if there are no more.
/// 
/// - see llvm::Instruction::getDbgRecordRange()
pub extern "C" fn llvm_get_previous_dbg_record(dbr: LLVMDbgRecordRef) -> LLVMDbgRecordRef = "__llvm_get_previous_dbg_record"

///| Obtain the previous DbgRecord in the sequence or NULL if there are no more.
/// 
/// - see llvm::Instruction::getDbgRecordRange()
pub fn LLVMDbgRecordRef::get_previous_dbg_record(self: LLVMDbgRecordRef) -> LLVMDbgRecordRef {
  llvm_get_previous_dbg_record(self)
}


///| Obtain the argument count for a call instruction.
/// 
/// This expects an LLVMValueRef that corresponds to a llvm::CallInst,
/// llvm::InvokeInst, or llvm:FuncletPadInst.
/// 
/// - see llvm::CallInst::getNumArgOperands()
/// - see llvm::InvokeInst::getNumArgOperands()
/// - see llvm::FuncletPadInst::getNumArgOperands()
pub extern "C" fn llvm_get_num_arg_operands(instr: LLVMValueRef) -> UInt = "__llvm_get_num_arg_operands"

///| Obtain the argument count for a call instruction.
/// 
/// This expects an LLVMValueRef that corresponds to a llvm::CallInst,
/// llvm::InvokeInst, or llvm:FuncletPadInst.
/// 
/// - see llvm::CallInst::getNumArgOperands()
/// - see llvm::InvokeInst::getNumArgOperands()
/// - see llvm::FuncletPadInst::getNumArgOperands()
pub fn LLVMValueRef::get_num_arg_operands(self: LLVMValueRef) -> UInt {
  llvm_get_num_arg_operands(self)
}


///| Set the calling convention for a call instruction.
/// 
/// This expects an LLVMValueRef that corresponds to a llvm::CallInst or
/// llvm::InvokeInst.
/// 
/// - see llvm::CallInst::setCallingConv()
/// - see llvm::InvokeInst::setCallingConv()
/// 
pub extern "C" fn llvm_set_instruction_call_conv(instr: LLVMValueRef, cc: UInt) = "__llvm_set_instruction_call_conv"

///| Set the calling convention for a call instruction.
/// 
/// This expects an LLVMValueRef that corresponds to a llvm::CallInst or
/// llvm::InvokeInst.
/// 
/// - see llvm::CallInst::setCallingConv()
/// - see llvm::InvokeInst::setCallingConv()
/// 
pub fn LLVMValueRef::set_instruction_call_conv(self: LLVMValueRef, cc: UInt) -> Unit {
  llvm_set_instruction_call_conv(self, cc)
}

///| Obtain the calling convention for a call instruction.
/// 
/// This is the opposite of LLVMSetInstructionCallConv(). Reads its
/// usage.
/// 
/// - see LLVMSetInstructionCallConv()
pub extern "C" fn llvm_get_instruction_call_conv(instr: LLVMValueRef) -> UInt = "__llvm_get_instruction_call_conv"

///| Obtain the calling convention for a call instruction.
/// 
/// This is the opposite of LLVMSetInstructionCallConv(). Reads its
/// usage.
/// 
/// - see LLVMSetInstructionCallConv()
pub fn LLVMValueRef::get_instruction_call_conv(self: LLVMValueRef) -> UInt {
  llvm_get_instruction_call_conv(self)
}

pub extern "C" fn llvm_set_instr_param_alignment(instr: LLVMValueRef, idx: LLVMAttributeIndex, align: UInt) = "__llvm_set_instr_param_alignment"
pub fn LLVMValueRef::set_instr_param_alignment(self: LLVMValueRef, idx: LLVMAttributeIndex, align: UInt) -> Unit {
  llvm_set_instr_param_alignment(self, idx, align)
}

pub extern "C" fn llvm_add_call_site_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, a: LLVMAttributeRef) = "__llvm_add_call_site_attribute"

pub extern "C" fn llvm_get_call_site_attribute_count(c: LLVMValueRef, idx: LLVMAttributeIndex) -> UInt = "__llvm_get_call_site_attribute_count"

pub extern "C" fn llvm_get_call_site_attributes(c: LLVMValueRef, idx: LLVMAttributeIndex) -> Array[LLVMAttributeRef] = "__llvm_get_call_site_attributes"

pub extern "C" fn llvm_get_call_site_enum_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, kind_id: UInt) -> LLVMAttributeRef = "__llvm_get_call_site_enum_attribute"

extern "C" fn __llvm_get_call_site_string_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, k: CStr, k_len: UInt) -> LLVMAttributeRef = "__llvm_get_call_site_string_attribute"
pub fn llvm_get_call_site_string_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, k: String) -> LLVMAttributeRef {
  let cstr = moonbit_str_to_c_str(k);
  __llvm_get_call_site_string_attribute(c, idx, cstr, k.length().reinterpret_as_uint())
}

pub extern "C" fn llvm_remove_call_site_enum_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, kind_id: UInt) = "__llvm_remove_call_site_enum_attribute"

extern "C" fn __llvm_remove_call_site_string_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, k: CStr, k_len: UInt) = "__llvm_remove_call_site_string_attribute"
pub fn llvm_remove_call_site_string_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, k: String) -> Unit {
  let cstr = moonbit_str_to_c_str(k);
  __llvm_remove_call_site_string_attribute(c, idx, cstr, k.length().reinterpret_as_uint())
}

///| Obtain the function type called by this instruction.
/// 
/// - see llvm::CallBase::getFunctionType()
pub extern "C" fn llvm_get_called_function_type(c: LLVMValueRef) -> LLVMTypeRef = "__llvm_get_called_function_type"

///| Obtain the function type called by this instruction.
/// 
/// - see llvm::CallBase::getFunctionType()
pub fn LLVMValueRef::get_called_function_type(self: LLVMValueRef) -> LLVMTypeRef {
  llvm_get_called_function_type(self)
}

///| Obtain the pointer to the function invoked by this instruction.
/// 
/// This expects an LLVMValueRef that corresponds to a llvm::CallInst or
/// llvm::InvokeInst.
/// 
/// - see llvm::CallInst::getCalledOperand()
/// - see llvm::InvokeInst::getCalledOperand()
pub extern "C" fn llvm_get_called_value(instr: LLVMValueRef) -> LLVMValueRef = "__llvm_get_called_value"

///| Obtain the pointer to the function invoked by this instruction.
/// 
/// This expects an LLVMValueRef that corresponds to a llvm::CallInst or
/// llvm::InvokeInst.
/// 
/// - see llvm::CallInst::getCalledOperand()
/// - see llvm::InvokeInst::getCalledOperand()
pub fn LLVMValueRef::get_called_value(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_called_value(self)
}

///| Obtain the number of operand bundles attached to this instruction.
/// 
/// This only works on llvm::CallInst and llvm::InvokeInst instructions.
/// 
/// - see llvm::CallBase::getNumOperandBundles()
pub extern "C" fn llvm_get_num_operand_bundles(c: LLVMValueRef) -> UInt = "__llvm_get_num_operand_bundles"

///| Obtain the number of operand bundles attached to this instruction.
/// 
/// This only works on llvm::CallInst and llvm::InvokeInst instructions.
/// 
/// - see llvm::CallBase::getNumOperandBundles()
pub fn LLVMValueRef::get_num_operand_bundles(self: LLVMValueRef) -> UInt {
  llvm_get_num_operand_bundles(self)
}

///| Obtain the operand bundle attached to this instruction at the given index.
///
/// Use LLVMDisposeOperandBundle to free the operand bundle.
/// 
/// This only works on llvm::CallInst and llvm::InvokeInst instructions.
pub extern "C" fn llvm_get_operand_bundle_at_index(c: LLVMValueRef, index: UInt) -> LLVMOperandBundleRef = "__llvm_get_operand_bundle_at_index"

///| Obtain the operand bundle attached to this instruction at the given index.
///
/// Use LLVMDisposeOperandBundle to free the operand bundle.
/// 
/// This only works on llvm::CallInst and llvm::InvokeInst instructions.
pub fn LLVMValueRef::get_operand_bundle_at_index(self: LLVMValueRef, index: UInt) -> LLVMOperandBundleRef {
  llvm_get_operand_bundle_at_index(self, index)
}


///| Obtain whether a call instruction is a tail call.
/// 
/// This only works on llvm::CallInst instructions.
/// 
/// - see llvm::CallInst::isTailCall()
extern "C" fn __llvm_is_tail_call(call_inst: LLVMValueRef) -> LLVMBool = "__llvm_is_tail_call"

///| Obtain whether a call instruction is a tail call.
/// 
/// This only works on llvm::CallInst instructions.
/// 
/// - see llvm::CallInst::isTailCall()
pub fn llvm_is_tail_call(call_inst: LLVMValueRef) -> Bool {
  __llvm_is_tail_call(call_inst).to_moonbit_bool()
}

///| Obtain whether a call instruction is a tail call.
/// 
/// This only works on llvm::CallInst instructions.
/// 
/// - see llvm::CallInst::isTailCall()
pub fn LLVMValueRef::is_tail_call(self: LLVMValueRef) -> Bool {
  __llvm_is_tail_call(self).to_moonbit_bool()
}

///| Set whether a call instruction is a tail call.
/// 
/// This only works on llvm::CallInst instructions.
/// 
/// - see llvm::CallInst::setTailCall()
extern "C" fn __llvm_set_tail_call(call_inst: LLVMValueRef, is_tail_call: LLVMBool) = "__llvm_set_tail_call"

///| Set whether a call instruction is a tail call.
/// 
/// This only works on llvm::CallInst instructions.
/// 
/// - see llvm::CallInst::setTailCall()
pub fn llvm_set_tail_call(call_inst: LLVMValueRef, is_tail_call: Bool) -> Unit {
  __llvm_set_tail_call(call_inst, to_llvm_bool(is_tail_call))
}

///| Set whether a call instruction is a tail call.
/// 
/// This only works on llvm::CallInst instructions.
/// 
/// - see llvm::CallInst::setTailCall()
pub fn LLVMValueRef::set_tail_call(self: LLVMValueRef, is_tail_call: Bool) -> Unit {
  __llvm_set_tail_call(self, to_llvm_bool(is_tail_call))
}


///| Obtain a tail call kind of the call instruction.
/// 
/// - see llvm::CallInst::setTailCallKind()
extern "C" fn __llvm_get_tail_call_kind(call_inst: LLVMValueRef) -> Int = "__llvm_get_tail_call_kind"

///| Obtain a tail call kind of the call instruction.
/// 
/// - see llvm::CallInst::setTailCallKind()
pub fn llvm_get_tail_call_kind(call_inst: LLVMValueRef) -> LLVMTailCallKind {
  LLVMTailCallKind::from_int(__llvm_get_tail_call_kind(call_inst))
}

///| Obtain a tail call kind of the call instruction.
/// 
/// - see llvm::CallInst::setTailCallKind()
pub fn LLVMValueRef::get_tail_call_kind(self: LLVMValueRef) -> LLVMTailCallKind {
  LLVMTailCallKind::from_int(__llvm_get_tail_call_kind(self))
}

///| Set the call kind of the call instruction.
/// 
/// - see llvm::CallInst::getTailCallKind()
extern "C" fn __llvm_set_tail_call_kind(call_inst: LLVMValueRef, kind: Int) = "__llvm_set_tail_call_kind"

///| Set the call kind of the call instruction.
/// 
/// - see llvm::CallInst::getTailCallKind()
pub fn llvm_set_tail_call_kind(call_inst: LLVMValueRef, kind: LLVMTailCallKind) -> Unit {
  __llvm_set_tail_call_kind(call_inst, kind.to_int())
}
pub fn LLVMValueRef::set_tail_call_kind(self: LLVMValueRef, kind: LLVMTailCallKind) -> Unit {
  __llvm_set_tail_call_kind(self, kind.to_int())
}

///| Return the normal destination basic block.
/// 
/// This only works on llvm::InvokeInst instructions.
/// 
/// - see llvm::InvokeInst::getNormalDest()
pub extern "C" fn llvm_get_normal_dest(invoke_inst: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_normal_dest"

///| Return the normal destination basic block.
/// 
/// This only works on llvm::InvokeInst instructions.
/// 
/// - see llvm::InvokeInst::getNormalDest()
pub fn LLVMValueRef::get_normal_dest(self: LLVMValueRef) -> LLVMBasicBlockRef {
  llvm_get_normal_dest(self)
}


///| Return the unwind destination basic block.
/// 
/// Works on llvm::InvokeInst, llvm::CleanupReturnInst, and
/// llvm::CatchSwitchInst instructions.
/// 
/// - see llvm::InvokeInst::getUnwindDest()
/// - see llvm::CleanupReturnInst::getUnwindDest()
/// - see llvm::CatchSwitchInst::getUnwindDest()
pub extern "C" fn llvm_get_unwind_dest(invoke_inst: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_unwind_dest"

///| Return the unwind destination basic block.
/// 
/// Works on llvm::InvokeInst, llvm::CleanupReturnInst, and
/// llvm::CatchSwitchInst instructions.
/// 
/// - see llvm::InvokeInst::getUnwindDest()
/// - see llvm::CleanupReturnInst::getUnwindDest()
/// - see llvm::CatchSwitchInst::getUnwindDest()
pub fn LLVMValueRef::get_unwind_dest(self: LLVMValueRef) -> LLVMBasicBlockRef {
  llvm_get_unwind_dest(self)
}

///| Set the normal destination basic block.
/// 
/// This only works on llvm::InvokeInst instructions.
/// 
/// - see llvm::InvokeInst::setNormalDest()
pub extern "C" fn llvm_set_normal_dest(invoke_inst: LLVMValueRef, b: LLVMBasicBlockRef) = "__llvm_set_normal_dest"

///| Set the normal destination basic block.
/// 
/// This only works on llvm::InvokeInst instructions.
/// 
/// - see llvm::InvokeInst::setNormalDest()
pub fn LLVMValueRef::set_normal_dest(self: LLVMValueRef, b: LLVMBasicBlockRef) -> Unit {
  llvm_set_normal_dest(self, b)
}

///| Set the unwind destination basic block.
/// 
/// Works on llvm::InvokeInst, llvm::CleanupReturnInst, and
/// llvm::CatchSwitchInst instructions.
/// 
/// - see llvm::InvokeInst::setUnwindDest()
/// - see llvm::CleanupReturnInst::setUnwindDest()
/// - see llvm::CatchSwitchInst::setUnwindDest()
pub extern "C" fn llvm_set_unwind_dest(invoke_inst: LLVMValueRef, b: LLVMBasicBlockRef) = "__llvm_set_unwind_dest"

///| Set the unwind destination basic block.
/// 
/// Works on llvm::InvokeInst, llvm::CleanupReturnInst, and
/// llvm::CatchSwitchInst instructions.
/// 
/// - see llvm::InvokeInst::setUnwindDest()
/// - see llvm::CleanupReturnInst::setUnwindDest()
/// - see llvm::CatchSwitchInst::setUnwindDest()
pub fn LLVMValueRef::set_unwind_dest(self: LLVMValueRef, b: LLVMBasicBlockRef) -> Unit {
  llvm_set_unwind_dest(self, b)
}

///| Get the default destination of a CallBr instruction.
/// 
/// - see llvm::CallBrInst::getDefaultDest()
pub extern "C" fn llvm_get_call_br_default_dest(call_br: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_call_br_default_dest"

///| Get the default destination of a CallBr instruction.
/// 
/// - see llvm::CallBrInst::getDefaultDest()
pub fn LLVMValueRef::get_call_br_default_dest(self: LLVMValueRef) -> LLVMBasicBlockRef {
  llvm_get_call_br_default_dest(self)
}

///| Get the number of indirect destinations of a CallBr instruction.
/// 
/// - see llvm::CallBrInst::getNumIndirectDests()
pub extern "C" fn llvm_get_call_br_num_indirect_dests(call_br: LLVMValueRef) -> UInt = "__llvm_get_call_br_num_indirect_dests"

///| Get the number of indirect destinations of a CallBr instruction.
/// 
/// - see llvm::CallBrInst::getNumIndirectDests()
pub fn LLVMValueRef::get_call_br_num_indirect_dests(self: LLVMValueRef) -> UInt {
  llvm_get_call_br_num_indirect_dests(self)
}

///| Get the indirect destination of a CallBr instruction at the given index.
/// 
/// - see llvm::CallBrInst::getIndirectDest()
pub extern "C" fn llvm_get_call_br_indirect_dest(call_br: LLVMValueRef, idx: UInt) -> LLVMBasicBlockRef = "__llvm_get_call_br_indirect_dest"

///| Get the indirect destination of a CallBr instruction at the given index.
/// 
/// - see llvm::CallBrInst::getIndirectDest()
pub fn LLVMValueRef::get_call_br_indirect_dest(self: LLVMValueRef, idx: UInt) -> LLVMBasicBlockRef {
  llvm_get_call_br_indirect_dest(self, idx)
}


///| Return the number of successors that this terminator has.
/// 
/// - see llvm::Instruction::getNumSuccessors
pub extern "C" fn llvm_get_num_successors(term: LLVMValueRef) -> UInt = "__llvm_get_num_successors"

///| Return the number of successors that this terminator has.
/// 
/// - see llvm::Instruction::getNumSuccessors
pub fn LLVMValueRef::get_num_successors(self: LLVMValueRef) -> UInt {
  llvm_get_num_successors(self)
}

///| Return the specified successor.
/// 
/// - see llvm::Instruction::getSuccessor
pub extern "C" fn llvm_get_successor(term: LLVMValueRef, i: UInt) -> LLVMBasicBlockRef = "__llvm_get_successor"

///| Return the specified successor.
/// 
/// - see llvm::Instruction::getSuccessor
pub fn LLVMValueRef::get_successor(self: LLVMValueRef, i: UInt) -> LLVMBasicBlockRef {
  llvm_get_successor(self, i)
}

///| Update the specified successor to point at the provided block.
/// 
/// - see llvm::Instruction::setSuccessor
pub extern "C" fn llvm_set_successor(term: LLVMValueRef, i: UInt, block: LLVMBasicBlockRef) = "__llvm_set_successor"

///| Update the specified successor to point at the provided block.
/// 
/// - see llvm::Instruction::setSuccessor
pub fn LLVMValueRef::set_successor(self: LLVMValueRef, i: UInt, block: LLVMBasicBlockRef) -> Unit {
  llvm_set_successor(self, i, block)
}

///| Return if a branch is conditional.
/// 
/// This only works on llvm::BranchInst instructions.
/// 
/// - see llvm::BranchInst::isConditional
extern "C" fn __llvm_is_conditional(branch: LLVMValueRef) -> LLVMBool = "__llvm_is_conditional"

///| Return if a branch is conditional.
/// 
/// This only works on llvm::BranchInst instructions.
/// 
/// - see llvm::BranchInst::isConditional
pub fn llvm_is_conditional(branch: LLVMValueRef) -> Bool {
  __llvm_is_conditional(branch).to_moonbit_bool()
}

///| Return if a branch is conditional.
/// 
/// This only works on llvm::BranchInst instructions.
/// 
/// - see llvm::BranchInst::isConditional
pub fn LLVMValueRef::is_conditional(self: LLVMValueRef) -> Bool {
  __llvm_is_conditional(self).to_moonbit_bool()
}

///| Return the condition of a branch instruction.
/// 
/// This only works on llvm::BranchInst instructions.
/// 
/// - see llvm::BranchInst::getCondition
pub extern "C" fn llvm_get_condition(branch: LLVMValueRef) -> LLVMValueRef = "__llvm_get_condition"

///| Return the condition of a branch instruction.
/// 
/// This only works on llvm::BranchInst instructions.
/// 
/// - see llvm::BranchInst::getCondition
pub fn LLVMValueRef::get_condition(self: LLVMValueRef) -> LLVMValueRef {
  llvm_get_condition(self)
}

///| Set the condition of a branch instruction.
/// 
/// This only works on llvm::BranchInst instructions.
/// 
/// - see llvm::BranchInst::setCondition
pub extern "C" fn llvm_set_condition(branch: LLVMValueRef, cond: LLVMValueRef) = "__llvm_set_condition"

///| Set the condition of a branch instruction.
/// 
/// This only works on llvm::BranchInst instructions.
/// 
/// - see llvm::BranchInst::setCondition
pub fn LLVMValueRef::set_condition(self: LLVMValueRef, cond: LLVMValueRef) -> Unit {
  llvm_set_condition(self, cond)
}

///| Obtain the default destination basic block of a switch instruction.
/// 
/// This only works on llvm::SwitchInst instructions.
/// 
/// - see llvm::SwitchInst::getDefaultDest()
pub extern "C" fn llvm_get_switch_default_dest(switch_instr: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_switch_default_dest"

///| Obtain the default destination basic block of a switch instruction.
/// 
/// This only works on llvm::SwitchInst instructions.
/// 
/// - see llvm::SwitchInst::getDefaultDest()
pub fn LLVMValueRef::get_switch_default_dest(self: LLVMValueRef) -> LLVMBasicBlockRef {
  llvm_get_switch_default_dest(self)
}

///| Obtain the type that is being allocated by the alloca instruction.
pub extern "C" fn llvm_get_allocated_type(alloca: LLVMValueRef) -> LLVMTypeRef = "__llvm_get_allocated_type"

///| Obtain the type that is being allocated by the alloca instruction.
pub fn LLVMValueRef::get_allocated_type(self: LLVMValueRef) -> LLVMTypeRef {
  llvm_get_allocated_type(self)
}

///| Check whether the given GEP operator is inbounds.
extern "C" fn __llvm_is_in_bounds(gep: LLVMValueRef) -> LLVMBool = "__llvm_is_in_bounds"

///| Check whether the given GEP operator is inbounds.
pub fn llvm_is_in_bounds(gep: LLVMValueRef) -> Bool {
  __llvm_is_in_bounds(gep).to_moonbit_bool()
}

///| Set the given GEP instruction to be inbounds or not.
pub extern "C" fn llvm_set_is_in_bounds(gep: LLVMValueRef, in_bounds: LLVMBool) = "__llvm_set_is_in_bounds"

///| Set the given GEP instruction to be inbounds or not.
pub fn LLVMValueRef::set_is_in_bounds(self: LLVMValueRef, in_bounds: Bool) -> Unit {
  llvm_set_is_in_bounds(self, to_llvm_bool(in_bounds))
}

///| Get the source element type of the given GEP operator.
pub extern "C" fn llvm_get_gep_source_element_type(gep: LLVMValueRef) -> LLVMTypeRef = "__llvm_get_gep_source_element_type"

///| Get the source element type of the given GEP operator.
pub fn LLVMValueRef::get_gep_source_element_type(self: LLVMValueRef) -> LLVMTypeRef {
  llvm_get_gep_source_element_type(self)
}

// /**
//  * Get the no-wrap related flags for the given GEP instruction.
//  *
//  * @- see llvm::GetElementPtrInst::getNoWrapFlags
//  */
// LLVMGEPNoWrapFlags LLVMGEPGetNoWrapFlags(LLVMValueRef GEP);
//
// /**
//  * Set the no-wrap related flags for the given GEP instruction.
//  *
//  * @- see llvm::GetElementPtrInst::setNoWrapFlags
//  */
// void LLVMGEPSetNoWrapFlags(LLVMValueRef GEP, LLVMGEPNoWrapFlags NoWrapFlags);


///| Add an incoming value to the end of a PHI list.
pub extern "C" fn llvm_add_incoming(phi_node: LLVMValueRef, incoming_values: Array[LLVMValueRef], incoming_blocks: Array[LLVMBasicBlockRef], count: UInt) = "__llvm_add_incoming"

///| Obtain the number of incoming basic blocks to a PHI node.
pub extern "C" fn llvm_count_incoming(phi_node: LLVMValueRef) -> UInt = "__llvm_count_incoming"

///| Obtain the number of incoming basic blocks to a PHI node.
pub fn LLVMValueRef::count_incoming(self: LLVMValueRef) -> UInt {
  llvm_count_incoming(self)
}

///| Obtain an incoming value to a PHI node as an LLVMValueRef.
pub extern "C" fn llvm_get_incoming_value(phi_node: LLVMValueRef, index: UInt) -> LLVMValueRef = "__llvm_get_incoming_value"

///| Obtain an incoming value to a PHI node as an LLVMValueRef.
pub fn LLVMValueRef::get_incoming_value(self: LLVMValueRef, index: UInt) -> LLVMValueRef {
  llvm_get_incoming_value(self, index)
}

///| Obtain an incoming value to a PHI node as an LLVMBasicBlockRef.
pub extern "C" fn llvm_get_incoming_block(phi_node: LLVMValueRef, index: UInt) -> LLVMBasicBlockRef = "__llvm_get_incoming_block"

///| Obtain an incoming value to a PHI node as an LLVMBasicBlockRef.
pub fn LLVMValueRef::get_incoming_block(self: LLVMValueRef, index: UInt) -> LLVMBasicBlockRef {
  llvm_get_incoming_block(self, index)
}

///| Obtain the number of indices.
///
/// NB: This also works on GEP operators.
pub extern "C" fn llvm_get_num_indices(inst: LLVMValueRef) -> UInt = "__llvm_get_num_indices"

///| Obtain the number of indices.
///
/// NB: This also works on GEP operators.
pub fn LLVMValueRef::get_num_indices(self: LLVMValueRef) -> UInt {
  llvm_get_num_indices(self)
}

///| Obtain the indices as an array.
// FIXME: Not implemented
pub extern "C" fn llvm_get_indices(inst: LLVMValueRef) -> Array[UInt] = "__llvm_get_indices"

///| Obtain the indices as an array.
pub fn LLVMValueRef::get_indices(self: LLVMValueRef) -> Array[UInt] {
  llvm_get_indices(self)
}

///| Create a new IR builder in context.
pub extern "C" fn llvm_create_builder_in_context(context: LLVMContextRef) -> LLVMBuilderRef = "__llvm_create_builder_in_context"
pub fn LLVMContextRef::create_builder(self: LLVMContextRef) -> LLVMBuilderRef {
  llvm_create_builder_in_context(self)
}


///| Read LLVM IR from a memory buffer and convert it into an in-memory Module object.
///
/// Read LLVM IR from a memory buffer and convert it into an in-memory Module
/// object. Returns 0 on success.
/// Optionally returns a human-readable description of any errors that
/// occurred during parsing IR. OutMessage must be disposed with
/// LLVMDisposeMessage.
/// 
/// - see llvm::ParseIR()
/// 
extern "C" fn __llvm_parse_ir_in_context(
  ctx: LLVMContextRef, membuf: LLVMMemoryBufferRef
) -> (LLVMModuleRef, CStr, LLVMBool) = "__llvm_parse_ir_in_context"

///| Read LLVM IR from a memory buffer and convert it into an in-memory Module object.
///
/// Read LLVM IR from a memory buffer and convert it into an in-memory Module
/// object. Returns 0 on success.
/// Optionally returns a human-readable description of any errors that
/// occurred during parsing IR. OutMessage must be disposed with
/// LLVMDisposeMessage.
/// 
/// - see llvm::ParseIR()
/// 
pub fn LLVMContextRef::parse_ir(self: LLVMContextRef, membuf: LLVMMemoryBufferRef) -> (LLVMModuleRef, String, Bool) {
  let (mod, err, failed) = __llvm_parse_ir_in_context(self, membuf);
  (mod, c_str_to_moonbit_str(err), failed.to_moonbit_bool())
}


///| Create a new IR builder in the global context.
pub extern "C" fn llvm_create_builder() -> LLVMBuilderRef = "__llvm_create_builder"

///| Create a new IR builder in the global context.
pub fn LLVMBuilderRef::create() -> LLVMBuilderRef {
  llvm_create_builder()
}

/// Set the builder position before Instr but after any attached debug records,
/// or if Instr is null set the position to the end of Block.
pub extern "C" fn llvm_position_builder(builder: LLVMBuilderRef, block: LLVMBasicBlockRef, instr: LLVMValueRef) = "__llvm_position_builder"

/// Set the builder position before Instr but after any attached debug records,
/// or if Instr is null set the position to the end of Block.
pub fn LLVMBuilderRef::position(self: LLVMBuilderRef, block: LLVMBasicBlockRef, instr: LLVMValueRef) -> Unit {
  llvm_position_builder(self, block, instr)
}

/// Set the builder position before Instr and any attached debug records,
/// or if Instr is null set the position to the end of Block.
pub extern "C" fn llvm_position_builder_before_dbg_records(builder: LLVMBuilderRef, block: LLVMBasicBlockRef, inst: LLVMValueRef) = "__llvm_position_builder_before_dbg_records"

/// Set the builder position before Instr and any attached debug records,
/// or if Instr is null set the position to the end of Block.
pub fn LLVMBuilderRef::position_before_dbg_records(self: LLVMBuilderRef, block: LLVMBasicBlockRef, inst: LLVMValueRef) -> Unit {
  llvm_position_builder_before_dbg_records(self, block, inst)
}

///| Set the builder position before Instr but after any attached debug records.
pub extern "C" fn llvm_position_builder_before(builder: LLVMBuilderRef, instr: LLVMValueRef) = "__llvm_position_builder_before"

///| Set the builder position before Instr but after any attached debug records.
pub fn LLVMBuilderRef::position_before(self: LLVMBuilderRef, instr: LLVMValueRef) -> Unit {
  llvm_position_builder_before(self, instr)
}

///| Set the builder position before Instr and any attached debug records.
pub extern "C" fn llvm_position_builder_before_instr_and_dbg_records(builder: LLVMBuilderRef, instr: LLVMValueRef) = "__llvm_position_builder_before_instr_and_dbg_records"

///| Set the builder position before Instr and any attached debug records.
pub fn LLVMBuilderRef::position_before_instr_and_dbg_records(self: LLVMBuilderRef, instr: LLVMValueRef) -> Unit {
  llvm_position_builder_before_instr_and_dbg_records(self, instr)
}

///| Position the builder at the end of the basic block.
pub extern "C" fn llvm_position_builder_at_end(builder: LLVMBuilderRef, block: LLVMBasicBlockRef) = "__llvm_position_builder_at_end"

///| Position the builder at the end of the basic block.
pub fn LLVMBuilderRef::position_at_end(self: LLVMBuilderRef, block: LLVMBasicBlockRef) -> Unit {
  llvm_position_builder_at_end(self, block)
}

///| Get the current insertion point of the builder.
pub extern "C" fn llvm_get_insert_block(builder: LLVMBuilderRef) -> LLVMBasicBlockRef = "__llvm_get_insert_block"

///| Get the current insertion point of the builder.
pub fn LLVMBuilderRef::get_insert_block(self: LLVMBuilderRef) -> LLVMBasicBlockRef {
  llvm_get_insert_block(self)
}

///| Clear the insertion position from the builder.
pub extern "C" fn llvm_clear_insertion_position(builder: LLVMBuilderRef) = "__llvm_clear_insertion_position"

///| Clear the insertion position from the builder.
pub fn LLVMBuilderRef::clear_insertion_position(self: LLVMBuilderRef) -> Unit {
  llvm_clear_insertion_position(self)
}

///| Insert instruction at the current insertion point.
pub extern "C" fn llvm_insert_into_builder(builder: LLVMBuilderRef, instr: LLVMValueRef) = "__llvm_insert_into_builder"

///| Insert instruction at the current insertion point.
pub fn LLVMBuilderRef::insert(self: LLVMBuilderRef, instr: LLVMValueRef) -> Unit {
  llvm_insert_into_builder(self, instr)
}

///| Insert instruction at the current insertion point with a name.
extern "C" fn __llvm_insert_into_builder_with_name(builder: LLVMBuilderRef, instr: LLVMValueRef, name: CStr) = "__llvm_insert_into_builder_with_name"

///| Insert instruction at the current insertion point with a name.
pub fn llvm_insert_into_builder_with_name(builder: LLVMBuilderRef, instr: LLVMValueRef, name: String) -> Unit {
  __llvm_insert_into_builder_with_name(builder, instr, moonbit_str_to_c_str(name))
}

///| Free the resources used by the builder.
pub extern "C" fn llvm_dispose_builder(builder: LLVMBuilderRef) = "__llvm_dispose_builder"

///| Free the resources used by the builder.
pub fn LLVMBuilderRef::dispose(self: LLVMBuilderRef) -> Unit {
  llvm_dispose_builder(self)
}

///| Get location information used by debugging information.
/// 
/// - see llvm::IRBuilder::getCurrentDebugLocation()
pub extern "C" fn llvm_get_current_debug_location2(builder: LLVMBuilderRef) -> LLVMMetadataRef = "__llvm_get_current_debug_location2"

///| Get location information used by debugging information.
/// 
/// - see llvm::IRBuilder::getCurrentDebugLocation()
pub fn LLVMBuilderRef::get_current_debug_location2(self: LLVMBuilderRef) -> LLVMMetadataRef {
  llvm_get_current_debug_location2(self)
}


///| Set location information used by debugging information.
/// 
/// To clear the location metadata of the given instruction, pass NULL to \p Loc.
/// 
/// - see llvm::IRBuilder::SetCurrentDebugLocation()
pub extern "C" fn llvm_set_current_debug_location2(builder: LLVMBuilderRef, loc: LLVMMetadataRef) = "__llvm_set_current_debug_location2"

///| Set location information used by debugging information.
/// 
/// To clear the location metadata of the given instruction, pass NULL to \p Loc.
/// 
/// - see llvm::IRBuilder::SetCurrentDebugLocation()
pub fn LLVMBuilderRef::set_current_debug_location2(self: LLVMBuilderRef, loc: LLVMMetadataRef) -> Unit {
  llvm_set_current_debug_location2(self, loc)
}

/// Attempts to set the debug location for the given instruction using the
/// current debug location for the given builder.  If the builder has no current
/// debug location, this function is a no-op.
/// 
/// @deprecated LLVMSetInstDebugLocation is deprecated in favor of the more general
///             LLVMAddMetadataToInst.
/// 
/// - see llvm::IRBuilder::SetInstDebugLocation()
/// 
pub extern "C" fn llvm_set_inst_debug_location(builder: LLVMBuilderRef, inst: LLVMValueRef) = "__llvm_set_inst_debug_location"

/// Attempts to set the debug location for the given instruction using the
/// current debug location for the given builder.  If the builder has no current
/// debug location, this function is a no-op.
/// 
/// @deprecated LLVMSetInstDebugLocation is deprecated in favor of the more general
///             LLVMAddMetadataToInst.
/// 
/// - see llvm::IRBuilder::SetInstDebugLocation()
/// 
pub fn LLVMBuilderRef::set_inst_debug_location(self: LLVMBuilderRef, inst: LLVMValueRef) -> Unit {
  llvm_set_inst_debug_location(self, inst)
}


///| Adds the metadata registered with the given builder to the given instruction.
/// 
/// - see llvm::IRBuilder::AddMetadataToInst()
pub extern "C" fn llvm_add_metadata_to_inst(builder: LLVMBuilderRef, inst: LLVMValueRef) = "__llvm_add_metadata_to_inst"

///| Adds the metadata registered with the given builder to the given instruction.
/// 
/// - see llvm::IRBuilder::AddMetadataToInst()
pub fn LLVMBuilderRef::add_metadata_to_inst(self: LLVMBuilderRef, inst: LLVMValueRef) -> Unit {
  llvm_add_metadata_to_inst(self, inst)
}

///| Get the dafult floating-point math metadata for a given builder.
/// 
/// - see llvm::IRBuilder::getDefaultFPMathTag()
pub extern "C" fn llvm_builder_get_default_fp_math_tag(builder: LLVMBuilderRef) -> LLVMMetadataRef = "__llvm_builder_get_default_fp_math_tag"

///| Get the dafult floating-point math metadata for a given builder.
/// 
/// - see llvm::IRBuilder::getDefaultFPMathTag()
pub fn LLVMBuilderRef::get_default_fp_math_tag(self: LLVMBuilderRef) -> LLVMMetadataRef {
  llvm_builder_get_default_fp_math_tag(self)
}

///| Set the default floating-point math metadata for the given builder.
/// 
/// To clear the metadata, pass NULL to \p FPMathTag.
/// 
/// - see llvm::IRBuilder::setDefaultFPMathTag()
pub extern "C" fn llvm_builder_set_default_fp_math_tag(builder: LLVMBuilderRef, fp_math_tag: LLVMMetadataRef) = "__llvm_builder_set_default_fp_math_tag"

///| Set the default floating-point math metadata for the given builder.
/// 
/// To clear the metadata, pass NULL to \p FPMathTag.
/// 
/// - see llvm::IRBuilder::setDefaultFPMathTag()
pub fn LLVMBuilderRef::set_default_fp_math_tag(self: LLVMBuilderRef, fp_math_tag: LLVMMetadataRef) -> Unit {
  llvm_builder_set_default_fp_math_tag(self, fp_math_tag)
}

// Deprecated
// pub extern "C" fn llvm_set_current_debug_location(builder: LLVMBuilderRef, l: LLVMValueRef) = "__llvm_set_current_debug_location"
// pub fn LLVMBuilderRef::set_current_debug_location(self: LLVMBuilderRef, l: LLVMValueRef) -> Unit {
//   llvm_set_current_debug_location(self, l)
// }

// Deprecated
// pub extern "C" fn llvm_get_current_debug_location(builder: LLVMBuilderRef) -> LLVMValueRef = "__llvm_get_current_debug_location"
// pub fn LLVMBuilderRef::get_current_debug_location(self: LLVMBuilderRef) -> LLVMValueRef {
//   llvm_get_current_debug_location(self)
// }

///| Build a return void instruction.
pub extern "C" fn llvm_build_ret_void(builder: LLVMBuilderRef) -> LLVMValueRef = "__llvm_build_ret_void"

///| Build a return void instruction.
pub fn LLVMBuilderRef::build_ret_void(self: LLVMBuilderRef) -> LLVMValueRef {
  llvm_build_ret_void(self)
}

///| Build a return instruction.
pub extern "C" fn llvm_build_ret(builder: LLVMBuilderRef, v: LLVMValueRef) -> LLVMValueRef = "__llvm_build_ret"

///| Build a return instruction.
pub fn LLVMBuilderRef::build_ret(self: LLVMBuilderRef, v: LLVMValueRef) -> LLVMValueRef {
  llvm_build_ret(self, v)
}

///| Build an aggregate return instruction.
pub extern "C" fn llvm_build_aggregate_ret(builder: LLVMBuilderRef, ret_vals: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_build_aggregate_ret"

///| Build an aggregate return instruction.
pub fn LLVMBuilderRef::build_aggregate_ret(self: LLVMBuilderRef, ret_vals: Array[LLVMValueRef]) -> LLVMValueRef {
  llvm_build_aggregate_ret(self, ret_vals)
}

///| Build a branch instruction.
pub extern "C" fn llvm_build_br(builder: LLVMBuilderRef, dest: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_build_br"

///| Build a branch instruction.
pub fn LLVMBuilderRef::build_br(self: LLVMBuilderRef, dest: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_build_br(self, dest)
}

///| Build a conditional branch instruction.
pub extern "C" fn llvm_build_cond_br(builder: LLVMBuilderRef, if_block: LLVMValueRef, then: LLVMBasicBlockRef, else_block: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_build_cond_br"

///| Build a conditional branch instruction.
pub fn LLVMBuilderRef::build_cond_br(self: LLVMBuilderRef, if_block: LLVMValueRef, then: LLVMBasicBlockRef, else_block: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_build_cond_br(self, if_block, then, else_block)
}

///| Build a switch instruction.
pub extern "C" fn llvm_build_switch(builder: LLVMBuilderRef, v: LLVMValueRef, else_block: LLVMBasicBlockRef, num_cases: UInt) -> LLVMValueRef = "__llvm_build_switch"

///| Build a switch instruction.
pub fn LLVMBuilderRef::build_switch(self: LLVMBuilderRef, v: LLVMValueRef, else_block: LLVMBasicBlockRef, num_cases: UInt) -> LLVMValueRef {
  llvm_build_switch(self, v, else_block, num_cases)
}

///| Build an indirect branch instruction.
pub extern "C" fn llvm_build_indirect_br(builder: LLVMBuilderRef, addr: LLVMValueRef, num_dests: UInt) -> LLVMValueRef = "__llvm_build_indirect_br"

///| Build an indirect branch instruction.
pub fn LLVMBuilderRef::build_indirect_br(self: LLVMBuilderRef, addr: LLVMValueRef, num_dests: UInt) -> LLVMValueRef {
  llvm_build_indirect_br(self, addr, num_dests)
}

///| Build a call branch instruction.
extern "C" fn __llvm_build_call_br(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, default_dest: LLVMBasicBlockRef, indirect_dests: Array[LLVMBasicBlockRef], args: Array[LLVMValueRef], bundles: Array[LLVMOperandBundleRef], name: CStr) -> LLVMValueRef = "__llvm_build_call_br"

///| Build a call branch instruction.
pub fn llvm_build_call_br(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, default_dest: LLVMBasicBlockRef, indirect_dests: Array[LLVMBasicBlockRef], args: Array[LLVMValueRef], bundles: Array[LLVMOperandBundleRef], name: String) -> LLVMValueRef {
  __llvm_build_call_br(builder, ty, func, default_dest, indirect_dests, args, bundles, moonbit_str_to_c_str(name))
}

///| Build a call branch instruction.
pub fn LLVMBuilderRef::build_call_br(self: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, default_dest: LLVMBasicBlockRef, indirect_dests: Array[LLVMBasicBlockRef], args: Array[LLVMValueRef], bundles: Array[LLVMOperandBundleRef], name: String) -> LLVMValueRef {
  llvm_build_call_br(self, ty, func, default_dest, indirect_dests, args, bundles, name)
}

///| Build an invoke instruction.
extern "C" fn __llvm_build_invoke2(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], then: LLVMBasicBlockRef, catch_block: LLVMBasicBlockRef, name: CStr) -> LLVMValueRef = "__llvm_build_invoke2"

///| Build an invoke instruction.
pub fn llvm_build_invoke2(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], then: LLVMBasicBlockRef, catch_block: LLVMBasicBlockRef, name: String) -> LLVMValueRef {
  __llvm_build_invoke2(builder, ty, func, args, then, catch_block, moonbit_str_to_c_str(name))
}

///| Build an invoke instruction.
pub fn LLVMBuilderRef::build_invoke2(self: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], then: LLVMBasicBlockRef, catch_block: LLVMBasicBlockRef, name: String) -> LLVMValueRef {
  llvm_build_invoke2(self, ty, func, args, then, catch_block, name)
}

///| Build an invoke instruction with operand bundles.
extern "C" fn __llvm_build_invoke_with_operand_bundles(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], then: LLVMBasicBlockRef, catch_block: LLVMBasicBlockRef, bundles: Array[LLVMOperandBundleRef], name: CStr) -> LLVMValueRef = "__llvm_build_invoke_with_operand_bundles"

///| Build an invoke instruction with operand bundles.
pub fn llvm_build_invoke_with_operand_bundles(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], then: LLVMBasicBlockRef, catch_block: LLVMBasicBlockRef, bundles: Array[LLVMOperandBundleRef], name: String) -> LLVMValueRef {
  __llvm_build_invoke_with_operand_bundles(builder, ty, func, args, then, catch_block, bundles, moonbit_str_to_c_str(name))
}

///| Build an invoke instruction with operand bundles.
pub fn LLVMBuilderRef::build_invoke_with_operand_bundles(self: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], then: LLVMBasicBlockRef, catch_block: LLVMBasicBlockRef, bundles: Array[LLVMOperandBundleRef], name: String) -> LLVMValueRef {
  llvm_build_invoke_with_operand_bundles(self, ty, func, args, then, catch_block, bundles, name)
}

///| Build an unreachable instruction.
pub extern "C" fn llvm_build_unreachable(builder: LLVMBuilderRef) -> LLVMValueRef = "__llvm_build_unreachable"

///| Build an unreachable instruction.
pub fn LLVMBuilderRef::build_unreachable(self: LLVMBuilderRef) -> LLVMValueRef {
  llvm_build_unreachable(self)
}

///| Build a resume instruction.
pub extern "C" fn llvm_build_resume(builder: LLVMBuilderRef, exn: LLVMValueRef) -> LLVMValueRef = "__llvm_build_resume"

///| Build a resume instruction.
pub fn LLVMBuilderRef::build_resume(self: LLVMBuilderRef, exn: LLVMValueRef) -> LLVMValueRef {
  llvm_build_resume(self, exn)
}

///| Build a landing pad instruction.
extern "C" fn __llvm_build_landing_pad(builder: LLVMBuilderRef, ty: LLVMTypeRef, pers_fn: LLVMValueRef, num_clauses: UInt, name: CStr) -> LLVMValueRef = "__llvm_build_landing_pad"

///| Build a landing pad instruction.
pub fn llvm_build_landing_pad(builder: LLVMBuilderRef, ty: LLVMTypeRef, pers_fn: LLVMValueRef, num_clauses: UInt, name: String) -> LLVMValueRef {
  __llvm_build_landing_pad(builder, ty, pers_fn, num_clauses, moonbit_str_to_c_str(name))
}

///| Build a landing pad instruction.
pub fn LLVMBuilderRef::build_landing_pad(self: LLVMBuilderRef, ty: LLVMTypeRef, pers_fn: LLVMValueRef, num_clauses: UInt, name: String) -> LLVMValueRef {
  llvm_build_landing_pad(self, ty, pers_fn, num_clauses, name)
}

///| Build a cleanup pad instruction.
pub extern "C" fn llvm_build_cleanup_ret(builder: LLVMBuilderRef, catch_pad: LLVMValueRef, bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_build_cleanup_ret"

///| Build a cleanup pad instruction.
pub fn LLVMBuilderRef::build_cleanup_ret(self: LLVMBuilderRef, catch_pad: LLVMValueRef, bb: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_build_cleanup_ret(self, catch_pad, bb)
}

///| Build a catch pad instruction.
pub extern "C" fn llvm_build_catch_ret(builder: LLVMBuilderRef, catch_pad: LLVMValueRef, bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_build_catch_ret"

///| Build a catch pad instruction.
pub fn LLVMBuilderRef::build_catch_ret(self: LLVMBuilderRef, catch_pad: LLVMValueRef, bb: LLVMBasicBlockRef) -> LLVMValueRef {
  llvm_build_catch_ret(self, catch_pad, bb)
}

///| Build a catch pad instruction.
extern "C" fn __llvm_build_catch_pad(builder: LLVMBuilderRef, parent_pad: LLVMValueRef, args: Array[LLVMValueRef], name: CStr) -> LLVMValueRef = "__llvm_build_catch_pad"

///| Build a catch pad instruction.
pub fn llvm_build_catch_pad(builder: LLVMBuilderRef, parent_pad: LLVMValueRef, args: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  __llvm_build_catch_pad(builder, parent_pad, args, moonbit_str_to_c_str(name))
}

///| Build a catch pad instruction.
pub fn LLVMBuilderRef::build_catch_pad(self: LLVMBuilderRef, parent_pad: LLVMValueRef, args: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  llvm_build_catch_pad(self, parent_pad, args, name)
}

///| Build a cleanup pad instruction.
extern "C" fn __llvm_build_cleanup_pad(builder: LLVMBuilderRef, parent_pad: LLVMValueRef, args: Array[LLVMValueRef], name: CStr) -> LLVMValueRef = "__llvm_build_cleanup_pad"

///| Build a cleanup pad instruction.
pub fn llvm_build_cleanup_pad(builder: LLVMBuilderRef, parent_pad: LLVMValueRef, args: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  __llvm_build_cleanup_pad(builder, parent_pad, args, moonbit_str_to_c_str(name))
}

///| Build a cleanup pad instruction.
pub fn LLVMBuilderRef::build_cleanup_pad(self: LLVMBuilderRef, parent_pad: LLVMValueRef, args: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  llvm_build_cleanup_pad(self, parent_pad, args, name)
}

///| Build a catch switch instruction.
extern "C" fn __llvm_build_catch_switch(builder: LLVMBuilderRef, parent_pad: LLVMValueRef, unwind_bb: LLVMBasicBlockRef, num_handlers: UInt, name: CStr) -> LLVMValueRef = "__llvm_build_catch_switch"

///| Build a catch switch instruction.
pub fn llvm_build_catch_switch(builder: LLVMBuilderRef, parent_pad: LLVMValueRef, unwind_bb: LLVMBasicBlockRef, num_handlers: UInt, name: String) -> LLVMValueRef {
  __llvm_build_catch_switch(builder, parent_pad, unwind_bb, num_handlers, moonbit_str_to_c_str(name))
}

///| Build a catch switch instruction.
pub fn LLVMBuilderRef::build_catch_switch(self: LLVMBuilderRef, parent_pad: LLVMValueRef, unwind_bb: LLVMBasicBlockRef, num_handlers: UInt, name: String) -> LLVMValueRef {
  llvm_build_catch_switch(self, parent_pad, unwind_bb, num_handlers, name)
}

///| Add a case to the switch instruction.
pub extern "C" fn llvm_add_case(_switch: LLVMValueRef, on_val: LLVMValueRef, dest: LLVMBasicBlockRef) = "__llvm_add_case"

///| Add a case to the switch instruction.
pub fn LLVMValueRef::add_case(self: LLVMValueRef, on_val: LLVMValueRef, dest: LLVMBasicBlockRef) -> Unit {
  llvm_add_case(self, on_val, dest)
}

///| Add a destination to the indirectbr instruction.
pub extern "C" fn llvm_add_destination(indirect_br: LLVMValueRef, dest: LLVMBasicBlockRef) = "__llvm_add_destination"

///| Add a destination to the indirectbr instruction.
pub fn LLVMValueRef::add_destination(self: LLVMValueRef, dest: LLVMBasicBlockRef) -> Unit {
  llvm_add_destination(self, dest)
}

///| Get the number of clauses on the landingpad instruction.
pub extern "C" fn llvm_get_num_clauses(landing_pad: LLVMValueRef) -> UInt = "__llvm_get_num_clauses"

///| Get the number of clauses on the landingpad instruction.
pub fn LLVMValueRef::get_num_clauses(self: LLVMValueRef) -> UInt {
  llvm_get_num_clauses(self)
}

///| Get the value of the clause at index Idx on the landingpad instruction.
pub extern "C" fn llvm_get_clause(landing_pad: LLVMValueRef, idx: UInt) -> LLVMValueRef = "__llvm_get_clause"

///| Get the value of the clause at index Idx on the landingpad instruction.
pub fn LLVMValueRef::get_clause(self: LLVMValueRef, idx: UInt) -> LLVMValueRef {
  llvm_get_clause(self, idx)
}

///| Add a catch or filter clause to the landingpad instruction.
pub extern "C" fn llvm_add_clause(landing_pad: LLVMValueRef, clause_val: LLVMValueRef) = "__llvm_add_clause"

///| Add a catch or filter clause to the landingpad instruction.
pub fn LLVMValueRef::add_clause(self: LLVMValueRef, clause_val: LLVMValueRef) -> Unit {
  llvm_add_clause(self, clause_val)
}

///| Get the 'cleanup' flag in the landingpad instruction.
extern "C" fn __llvm_is_cleanup(landing_pad: LLVMValueRef) -> LLVMBool = "__llvm_is_cleanup"

///| Get the 'cleanup' flag in the landingpad instruction.
pub fn llvm_is_cleanup(landing_pad: LLVMValueRef) -> Bool {
  __llvm_is_cleanup(landing_pad).to_moonbit_bool()
}

///| Set the 'cleanup' flag in the landingpad instruction.
extern "C" fn __llvm_set_cleanup(landing_pad: LLVMValueRef, val: LLVMBool) = "__llvm_set_cleanup"

///| Set the 'cleanup' flag in the landingpad instruction.
pub fn llvm_set_cleanup(landing_pad: LLVMValueRef, val: Bool) -> Unit {
  __llvm_set_cleanup(landing_pad, to_llvm_bool(val))
}

///| Add a destination to the catchswitch instruction.
pub extern "C" fn llvm_add_handler(catch_switch: LLVMValueRef, dest: LLVMBasicBlockRef) = "__llvm_add_handler"

///| Get the number of handlers on the catchswitch instruction.
pub extern "C" fn llvm_get_num_handlers(catch_switch: LLVMValueRef) -> UInt = "__llvm_get_num_handlers"

///| Obtain the basic blocks acting as handlers for a catchswitch instruction.
/// 
/// The Handlers parameter should point to a pre-allocated array of
/// LLVMBasicBlockRefs at least LLVMGetNumHandlers() large. On return, the
/// first LLVMGetNumHandlers() entries in the array will be populated
/// with LLVMBasicBlockRef instances.
/// 
/// @param CatchSwitch The catchswitch instruction to operate on.
/// @param Handlers Memory address of an array to be filled with basic blocks.
/// 
pub extern "C" fn llvm_get_handlers(catch_switch: LLVMValueRef) -> Array[LLVMBasicBlockRef] = "__llvm_get_handlers"

///| Get the number of funcletpad arguments.
pub extern "C" fn llvm_get_arg_operand(funclet: LLVMValueRef, i: UInt) -> LLVMValueRef = "__llvm_get_arg_operand"

///| Set a funcletpad argument at the given index.
pub extern "C" fn llvm_set_arg_operand(funclet: LLVMValueRef, i: UInt, value: LLVMValueRef) = "__llvm_set_arg_operand"


/// Get the parent catchswitch instruction of a catchpad instruction.
/// 
/// This only works on llvm::CatchPadInst instructions.
/// 
/// - see llvm::CatchPadInst::getCatchSwitch()
pub extern "C" fn llvm_get_parent_catch_switch(catch_pad: LLVMValueRef) -> LLVMValueRef = "__llvm_get_parent_catch_switch"


///| Set the parent catchswitch instruction of a catchpad instruction.
/// 
/// This only works on llvm::CatchPadInst instructions.
/// 
/// - see llvm::CatchPadInst::setCatchSwitch()
pub extern "C" fn llvm_set_parent_catch_switch(catch_pad: LLVMValueRef, catch_switch: LLVMValueRef) = "__llvm_set_parent_catch_switch"

///| Build add instruction.
extern "C" fn __llvm_build_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_add"

///| Build add instruction.
pub fn llvm_build_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_add(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build add instruction with nsw flag.
extern "C" fn __llvm_build_nsw_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nsw_add"

///| Build add instruction with nsw flag.
pub fn llvm_build_nsw_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_nsw_add(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build add instruction with nuw flag.
extern "C" fn __llvm_build_nuw_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nuw_add"

///| Build add instruction with nuw flag.
pub fn llvm_build_nuw_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_nuw_add(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build floating-point add instruction.
extern "C" fn __llvm_build_f_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_add"

///| Build floating-point add instruction.
pub fn llvm_build_f_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_f_add(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build subtract instruction.
extern "C" fn __llvm_build_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_sub"

///| Build subtract instruction.
pub fn llvm_build_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_sub(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build subtract instruction with nsw flag.
extern "C" fn __llvm_build_nsw_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nsw_sub"

///| Build subtract instruction with nsw flag.
pub fn llvm_build_nsw_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_nsw_sub(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build subtract instruction with nuw flag.
extern "C" fn __llvm_build_nuw_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nuw_sub"

///| Build subtract instruction with nuw flag.
pub fn llvm_build_nuw_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_nuw_sub(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build floating-point subtract instruction.
extern "C" fn __llvm_build_f_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_sub"

///| Build floating-point subtract instruction.
pub fn llvm_build_f_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_f_sub(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build multiply instruction.
extern "C" fn __llvm_build_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_mul"

///| Build multiply instruction.
pub fn llvm_build_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_mul(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build multiply instruction with nsw flag.
extern "C" fn __llvm_build_nsw_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nsw_mul"

///| Build multiply instruction with nsw flag.
pub fn llvm_build_nsw_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_nsw_mul(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build multiply instruction with nuw flag.
extern "C" fn __llvm_build_nuw_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nuw_mul"

///| Build multiply instruction with nuw flag.
pub fn llvm_build_nuw_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_nuw_mul(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build floating-point multiply instruction.
extern "C" fn __llvm_build_f_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_mul"

///| Build floating-point multiply instruction.
pub fn llvm_build_f_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_f_mul(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build unsigned division instruction.
extern "C" fn __llvm_build_u_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_u_div"

///| Build unsigned division instruction.
pub fn llvm_build_u_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_u_div(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build exact unsigned division instruction.
extern "C" fn __llvm_build_exact_u_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_exact_u_div"

///| Build exact unsigned division instruction.
pub fn llvm_build_exact_u_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_exact_u_div(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build signed division instruction.
extern "C" fn __llvm_build_s_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_s_div"

///| Build signed division instruction.
pub fn llvm_build_s_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_s_div(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build exact signed division instruction.
extern "C" fn __llvm_build_exact_s_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_exact_s_div"

///| Build exact signed division instruction.
pub fn llvm_build_exact_s_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_exact_s_div(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build floating-point division instruction.
extern "C" fn __llvm_build_f_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_div"

///| Build floating-point division instruction.
pub fn llvm_build_f_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_f_div(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build unsigned remainder instruction.
extern "C" fn __llvm_build_u_rem(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_u_rem"

///| Build unsigned remainder instruction.
pub fn llvm_build_u_rem(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_u_rem(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build signed remainder instruction.
extern "C" fn __llvm_build_s_rem(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_s_rem"

///| Build signed remainder instruction.
pub fn llvm_build_s_rem(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_s_rem(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build floating-point remainder instruction.
extern "C" fn __llvm_build_f_rem(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_rem"

///| Build floating-point remainder instruction.
pub fn llvm_build_f_rem(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_f_rem(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build bitwise shift left instruction.
extern "C" fn __llvm_build_shl(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_shl"

///| Build bitwise shift left instruction.
pub fn llvm_build_shl(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_shl(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build bitwise logical shift right instruction.
extern "C" fn __llvm_build_l_shr(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_l_shr"

///| Build bitwise logical shift right instruction.
pub fn llvm_build_l_shr(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_l_shr(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build bitwise arithmetic shift right instruction.
extern "C" fn __llvm_build_a_shr(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_a_shr"

///| Build bitwise arithmetic shift right instruction.
pub fn llvm_build_a_shr(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_a_shr(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build bitwise and instruction.
extern "C" fn __llvm_build_and(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_and"

///| Build bitwise and instruction.
pub fn llvm_build_and(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_and(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build bitwise or instruction.
extern "C" fn __llvm_build_or(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_or"

///| Build bitwise or instruction.
pub fn llvm_build_or(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_or(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build bitwise xor instruction.
extern "C" fn __llvm_build_xor(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_xor"

///| Build bitwise xor instruction.
pub fn llvm_build_xor(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_xor(builder, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build Binary Operator instruction with a given opcode.
extern "C" fn __llvm_build_bin_op(builder: LLVMBuilderRef, op: Int, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_bin_op"

///| Build Binary Operator instruction with a given opcode.
pub fn llvm_build_bin_op(builder: LLVMBuilderRef, op: LLVMOpcode, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  let code = op.to_int()
  let name = moonbit_str_to_c_str(name)
  __llvm_build_bin_op(builder, code, lhs, rhs, name)
}

///| Build negation instruction.
extern "C" fn __llvm_build_neg(builder: LLVMBuilderRef, v: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_neg"

pub fn llvm_build_neg(builder: LLVMBuilderRef, v: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_neg(builder, v, moonbit_str_to_c_str(name))
}

///| Build negation instruction.
pub fn LLVMBuilderRef::build_neg(self: LLVMBuilderRef, v: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_neg(self, v, moonbit_str_to_c_str(name))
}

///| Build negation instruction with nsw flag.
extern "C" fn __llvm_build_nsw_neg(builder: LLVMBuilderRef, v: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nsw_neg"

///| Build negation instruction with nsw flag.
pub fn llvm_build_nsw_neg(builder: LLVMBuilderRef, v: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_nsw_neg(builder, v, moonbit_str_to_c_str(name))
}

///| Build negation instruction with nsw flag.
pub fn LLVMBuilderRef::build_nsw_neg(self: LLVMBuilderRef, v: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_nsw_neg(self, v, name)
}

///| Build negation instruction with nuw flag.
extern "C" fn __llvm_build_nuw_neg(builder: LLVMBuilderRef, v: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nuw_neg"

///| Build negation instruction with nuw flag.
pub fn llvm_build_nuw_neg(builder: LLVMBuilderRef, v: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_nuw_neg(builder, v, moonbit_str_to_c_str(name))
}

///| Build negation instruction with nuw flag.
pub fn LLVMBuilderRef::build_nuw_neg(self: LLVMBuilderRef, v: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_nuw_neg(self, v, name)
}


///| Build floating-point negation instruction.
extern "C" fn __llvm_build_f_neg(builder: LLVMBuilderRef, v: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_neg"

///| Build floating-point negation instruction.
pub fn llvm_build_f_neg(builder: LLVMBuilderRef, v: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_f_neg(builder, v, moonbit_str_to_c_str(name))
}

///| Build floating-point negation instruction.
pub fn LLVMBuilderRef::build_f_neg(self: LLVMBuilderRef, v: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_f_neg(self, v, name)
}

///| Build not instruction.
extern "C" fn __llvm_build_not(builder: LLVMBuilderRef, v: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_not"

///| Build not instruction.
pub fn llvm_build_not(builder: LLVMBuilderRef, v: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_not(builder, v, moonbit_str_to_c_str(name))
}

///| Build not instruction.
pub fn LLVMBuilderRef::build_not(self: LLVMBuilderRef, v: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_not(self, v, name)
}

///| Check if the instruction has the nuw flag set.
extern "C" fn __llvm_get_nuw(arith_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_nuw"

///| Check if the instruction has the nuw flag set.
pub fn LLVMValueRef::get_nuw(self: LLVMValueRef) -> Bool {
  let has_nuw = __llvm_get_nuw(self);
  to_moonbit_bool(has_nuw)
}

///| Check if the instruction has the nuw flag set.
pub fn llvm_get_nuw(arith_inst: LLVMValueRef) -> Bool {
  LLVMValueRef::get_nuw(arith_inst)
}

///| Set the nuw flag for the instruction.
extern "C" fn __llvm_set_nuw(arith_inst: LLVMValueRef, has_nuw: LLVMBool) = "__llvm_set_nuw"

///| Set the nuw flag for the instruction.
pub fn llvm_set_nuw(arith_inst: LLVMValueRef, has_nuw: Bool) -> Unit {
  __llvm_set_nuw(arith_inst, to_llvm_bool(has_nuw))
}

///| Set the nuw flag for the instruction.
pub fn LLVMValueRef::set_nuw(self: LLVMValueRef, has_nuw: Bool) -> Unit {
  llvm_set_nuw(self, has_nuw)
}

///| Check if the instruction has the nsw flag set.
extern "C" fn __llvm_get_nsw(arith_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_nsw"

///| Check if the instruction has the nsw flag set.
pub fn LLVMValueRef::get_nsw(self: LLVMValueRef) -> Bool {
  let has_nsw = __llvm_get_nsw(self);
  to_moonbit_bool(has_nsw)
}

///| Check if the instruction has the nsw flag set.
pub fn llvm_get_nsw(arith_inst: LLVMValueRef) -> Bool {
  LLVMValueRef::get_nsw(arith_inst)
}

///| Set the nsw flag for the instruction.
extern "C" fn __llvm_set_nsw(arith_inst: LLVMValueRef, has_nsw: LLVMBool) = "__llvm_set_nsw"

///| Set the nsw flag for the instruction.
pub fn llvm_set_nsw(arith_inst: LLVMValueRef, has_nsw: Bool) -> Unit {
  __llvm_set_nsw(arith_inst, to_llvm_bool(has_nsw))
}

///| Set the nsw flag for the instruction.
pub fn LLVMValueRef::set_nsw(self: LLVMValueRef, has_nsw: Bool) -> Unit {
  llvm_set_nsw(self, has_nsw)
}

///| Check if the instruction has the exact flag set.
extern "C" fn __llvm_get_exact(div_or_shr_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_exact"

///| Check if the instruction has the exact flag set.
pub fn LLVMValueRef::get_exact(self: LLVMValueRef) -> Bool {
  let is_exact = __llvm_get_exact(self);
  to_moonbit_bool(is_exact)
}

///| Check if the instruction has the exact flag set.
pub fn llvm_get_exact(div_or_shr_inst: LLVMValueRef) -> Bool {
  LLVMValueRef::get_exact(div_or_shr_inst)
}

///| Set the exact flag for the instruction.
extern "C" fn __llvm_set_exact(div_or_shr_inst: LLVMValueRef, is_exact: LLVMBool) = "__llvm_set_exact"

///| Set the exact flag for the instruction.
pub fn llvm_set_exact(div_or_shr_inst: LLVMValueRef, is_exact: Bool) -> Unit {
  __llvm_set_exact(div_or_shr_inst, to_llvm_bool(is_exact))
}

///| Set the exact flag for the instruction.
pub fn LLVMValueRef::set_exact(self: LLVMValueRef, is_exact: Bool) -> Unit {
  llvm_set_exact(self, is_exact)
}

///| Gets if the instruction has the non-negative flag set.
///
/// Only valid for zext instructions.
extern "C" fn __llvm_get_n_neg(non_neg_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_n_neg"

///| Gets if the instruction has the non-negative flag set.
///
/// Only valid for zext instructions.
pub fn llvm_get_n_neg(non_neg_inst: LLVMValueRef) -> Bool {
  let is_non_neg = __llvm_get_n_neg(non_neg_inst);
  to_moonbit_bool(is_non_neg)
}

///| Gets if the instruction has the non-negative flag set.
///
/// Only valid for zext instructions.
pub fn LLVMValueRef::get_n_neg(self: LLVMValueRef) -> Bool {
  let is_non_neg = __llvm_get_n_neg(self);
  to_moonbit_bool(is_non_neg)
}

///| Sets the non-negative flag for the instruction.
///
/// Only valid for zext instructions.
extern "C" fn __llvm_set_n_neg(non_neg_inst: LLVMValueRef, is_non_neg: LLVMBool) = "__llvm_set_n_neg"

///| Sets the non-negative flag for the instruction.
///
/// Only valid for zext instructions.
pub fn llvm_set_n_neg(non_neg_inst: LLVMValueRef, is_non_neg: Bool) -> Unit {
  __llvm_set_n_neg(non_neg_inst, to_llvm_bool(is_non_neg))
}

///| Sets the non-negative flag for the instruction.
///
/// Only valid for zext instructions.
pub fn LLVMValueRef::set_n_neg(self: LLVMValueRef, is_non_neg: Bool) -> Unit {
  llvm_set_n_neg(self, is_non_neg)
}

///| Get the flags for which fast-math-style optimizations are allowed for this value.
/// 
/// Only valid on floating point instructions.
/// - see LLVMCanValueUseFastMathFlags
extern "C" fn llvm_get_fast_math_flags(fp_math_inst: LLVMValueRef) -> LLVMFastMathFlags = "__llvm_get_fast_math_flags"

///| Get the flags for which fast-math-style optimizations are allowed for this value.
/// 
/// Only valid on floating point instructions.
/// - see LLVMCanValueUseFastMathFlags
pub fn LLVMValueRef::get_fast_math_flags(self: LLVMValueRef) -> LLVMFastMathFlags {
  llvm_get_fast_math_flags(self)
}

///| Sets the flags for which fast-math-style optimizations are allowed for this value.
/// 
/// Only valid on floating point instructions.
///
/// - see LLVMCanValueUseFastMathFlags
extern "C" fn llvm_set_fast_math_flags(fp_math_inst: LLVMValueRef, fmf: LLVMFastMathFlags) = "__llvm_set_fast_math_flags"

///| Sets the flags for which fast-math-style optimizations are allowed for this value.
/// 
/// Only valid on floating point instructions.
///
/// - see LLVMCanValueUseFastMathFlags
pub fn LLVMValueRef::set_fast_math_flags(self: LLVMValueRef, fmf: LLVMFastMathFlags) -> Unit {
  llvm_set_fast_math_flags(self, fmf)
}

///| Check if a given value can potentially have fast math flags.
/// 
/// Will return true for floating point arithmetic instructions, and for select,
/// phi, and call instructions whose type is a floating point type, or a vector
/// or array thereof. - see https://llvm.org/docs/LangRef.html#fast-math-flags
extern "C" fn __llvm_can_value_use_fast_math_flags(inst: LLVMValueRef) -> LLVMBool = "__llvm_can_value_use_fast_math_flags"

///| Check if a given value can potentially have fast math flags.
/// 
/// Will return true for floating point arithmetic instructions, and for select,
/// phi, and call instructions whose type is a floating point type, or a vector
/// or array thereof. - see https://llvm.org/docs/LangRef.html#fast-math-flags
pub fn llvm_can_value_use_fast_math_flags(inst: LLVMValueRef) -> Bool {
  let can_use = __llvm_can_value_use_fast_math_flags(inst);
  to_moonbit_bool(can_use)
}

///| Check if a given value can potentially have fast math flags.
/// 
/// Will return true for floating point arithmetic instructions, and for select,
/// phi, and call instructions whose type is a floating point type, or a vector
/// or array thereof. - see https://llvm.org/docs/LangRef.html#fast-math-flags
pub fn LLVMValueRef::can_use_fast_math_flags(self: LLVMValueRef) -> Bool {
  llvm_can_value_use_fast_math_flags(self)
}

///| Gets whether the instruction has the disjoint flag set.
/// 
/// Only valid for or instructions.
extern "C" fn __llvm_get_is_disjoint(inst: LLVMValueRef) -> LLVMBool = "__llvm_get_is_disjoint"

///| Gets whether the instruction has the disjoint flag set.
/// 
/// Only valid for or instructions.
pub fn LLVMValueRef::get_is_disjoint(self: LLVMValueRef) -> Bool {
  let is_disjoint = __llvm_get_is_disjoint(self);
  to_moonbit_bool(is_disjoint)
}

///| Sets the disjoint flag for the instruction.
/// 
/// Only valid for or instructions.
extern "C" fn __llvm_set_is_disjoint(inst: LLVMValueRef, is_disjoint: LLVMBool) = "__llvm_set_is_disjoint"

///| Sets the disjoint flag for the instruction.
/// 
/// Only valid for or instructions.
pub fn llvm_set_is_disjoint(inst: LLVMValueRef, is_disjoint: Bool) -> Unit {
  __llvm_set_is_disjoint(inst, to_llvm_bool(is_disjoint))
}

///| Sets the disjoint flag for the instruction.
/// 
/// Only valid for or instructions.
pub fn LLVMValueRef::set_is_disjoint(self: LLVMValueRef, is_disjoint: Bool) -> Unit {
  llvm_set_is_disjoint(self, is_disjoint)
}

///| Build a malloc instruction.
extern "C" fn __llvm_build_malloc(builder: LLVMBuilderRef, ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_malloc"

///| Build a malloc instruction.
pub fn llvm_build_malloc(builder: LLVMBuilderRef, ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_malloc(builder, ty, moonbit_str_to_c_str(name))
}

///| Build a malloc instruction.
pub fn LLVMBuilderRef::build_malloc(self: LLVMBuilderRef, ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_malloc(self, ty, name)
}

///| Build an array malloc instruction.
extern "C" fn __llvm_build_array_malloc(builder: LLVMBuilderRef, ty: LLVMTypeRef, val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_array_malloc"

///| Build an array malloc instruction.
pub fn llvm_build_array_malloc(builder: LLVMBuilderRef, ty: LLVMTypeRef, val: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_array_malloc(builder, ty, val, moonbit_str_to_c_str(name))
}

///| Creates and inserts a memset to the specified pointer and the specified value.
/// 
/// - see llvm::IRRBuilder::CreateMemSet()
pub extern "C" fn llvm_build_mem_set(builder: LLVMBuilderRef, ptr: LLVMValueRef, val: LLVMValueRef, len: LLVMValueRef, align: UInt) -> LLVMValueRef = "__llvm_build_mem_set"

///| Creates and inserts a memset to the specified pointer and the specified value.
/// 
/// - see llvm::IRRBuilder::CreateMemSet()
pub fn LLVMBuilderRef::build_mem_set(self: LLVMBuilderRef, ptr: LLVMValueRef, val: LLVMValueRef, len: LLVMValueRef, align: UInt) -> LLVMValueRef {
  llvm_build_mem_set(self, ptr, val, len, align)
}

///| Creates and inserts a memcpy between the specified pointers.
/// 
/// - see llvm::IRRBuilder::CreateMemCpy()
pub extern "C" fn llvm_build_mem_cpy(builder: LLVMBuilderRef, dst: LLVMValueRef, dst_align: UInt, src: LLVMValueRef, src_align: UInt, size: LLVMValueRef) -> LLVMValueRef = "__llvm_build_mem_cpy"

///| Creates and inserts a memcpy between the specified pointers.
/// 
/// - see llvm::IRRBuilder::CreateMemCpy()
pub fn LLVMBuilderRef::build_mem_cpy(self: LLVMBuilderRef, dst: LLVMValueRef, dst_align: UInt, src: LLVMValueRef, src_align: UInt, size: LLVMValueRef) -> LLVMValueRef {
  llvm_build_mem_cpy(self, dst, dst_align, src, src_align, size)
}

///| Creates and inserts a memmove between the specified pointers.
/// 
/// - see llvm::IRRBuilder::CreateMemMove()
pub extern "C" fn llvm_build_mem_move(builder: LLVMBuilderRef, dst: LLVMValueRef, dst_align: UInt, src: LLVMValueRef, src_align: UInt, size: LLVMValueRef) -> LLVMValueRef = "__llvm_build_mem_move"

///| Creates and inserts a memmove between the specified pointers.
/// 
/// - see llvm::IRRBuilder::CreateMemMove()
pub fn LLVMBuilderRef::build_mem_move(self: LLVMBuilderRef, dst: LLVMValueRef, dst_align: UInt, src: LLVMValueRef, src_align: UInt, size: LLVMValueRef) -> LLVMValueRef {
  llvm_build_mem_move(self, dst, dst_align, src, src_align, size)
}

///| Build an alloca instruction.
extern "C" fn __llvm_build_alloca(builder: LLVMBuilderRef, ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_alloca"

///| Build an alloca instruction.
pub fn llvm_build_alloca(builder: LLVMBuilderRef, ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_alloca(builder, ty, moonbit_str_to_c_str(name))
}

///| Build an alloca instruction.
pub fn LLVMBuilderRef::build_alloca(self: LLVMBuilderRef, ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_alloca(self, ty, name)
}

///| Build an array alloca instruction.
extern "C" fn __llvm_build_array_alloca(builder: LLVMBuilderRef, ty: LLVMTypeRef, val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_array_alloca"

///| Build an array alloca instruction.
pub fn llvm_build_array_alloca(builder: LLVMBuilderRef, ty: LLVMTypeRef, val: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_array_alloca(builder, ty, val, moonbit_str_to_c_str(name))
}

///| Build an array alloca instruction.
pub fn LLVMBuilderRef::build_array_alloca(self: LLVMBuilderRef, ty: LLVMTypeRef, val: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_array_alloca(self, ty, val, name)
}

///| Build a free instruction.
pub extern "C" fn llvm_build_free(builder: LLVMBuilderRef, pointer_val: LLVMValueRef) -> LLVMValueRef = "__llvm_build_free"

///| Build a free instruction.
pub fn LLVMBuilderRef::build_free(self: LLVMBuilderRef, pointer_val: LLVMValueRef) -> LLVMValueRef {
  llvm_build_free(self, pointer_val)
}

///| Build a load instruction.
extern "C" fn __llvm_build_load2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer_val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_load2"

///| Build a load instruction.
pub fn llvm_build_load2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer_val: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_load2(builder, ty, pointer_val, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_load2(self: LLVMBuilderRef, ty: LLVMTypeRef, pointer_val: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_load2(self, ty, pointer_val, name)
}

///| Build a store instruction.
pub extern "C" fn llvm_build_store(builder: LLVMBuilderRef, val: LLVMValueRef, ptr: LLVMValueRef) -> LLVMValueRef = "__llvm_build_store"

///| Build a store instruction.
pub fn LLVMBuilderRef::build_store(self: LLVMBuilderRef, val: LLVMValueRef, ptr: LLVMValueRef) -> LLVMValueRef {
  llvm_build_store(self, val, ptr)
}

///| Build a getelementptr instruction.
extern "C" fn __llvm_build_gep2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, indices: Array[LLVMValueRef], name: CStr) -> LLVMValueRef = "__llvm_build_gep2"

///| Build a getelementptr instruction.
pub fn llvm_build_gep2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, indices: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  __llvm_build_gep2(builder, ty, pointer, indices, moonbit_str_to_c_str(name))
}
pub fn LLVMBuilderRef::build_gep2(self: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, indices: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  llvm_build_gep2(self, ty, pointer, indices, name)
}

///| Build a getelementptr instruction with inbounds flag.
extern "C" fn __llvm_build_in_bounds_gep2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, indices: Array[LLVMValueRef], name: CStr) -> LLVMValueRef = "__llvm_build_in_bounds_gep2"

///| Build a getelementptr instruction with inbounds flag.
pub fn llvm_build_in_bounds_gep2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, indices: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  __llvm_build_in_bounds_gep2(builder, ty, pointer, indices, moonbit_str_to_c_str(name))
}

///| Build a getelementptr instruction with inbounds flag.
pub fn LLVMBuilderRef::build_in_bounds_gep2(self: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, indices: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  llvm_build_in_bounds_gep2(self, ty, pointer, indices, name)
}

// /**
//  * Creates a GetElementPtr instruction. Similar to LLVMBuildGEP2, but allows
//  * specifying the no-wrap flags.
//  *
//  * @- see llvm::IRBuilder::CreateGEP()
//  */
// LLVMValueRef LLVMBuildGEPWithNoWrapFlags(LLVMBuilderRef B, LLVMTypeRef Ty,
//                                          LLVMValueRef Pointer,
//                                          LLVMValueRef *Indices,
//                                          unsigned NumIndices, const char *Name,
//                                          LLVMGEPNoWrapFlags NoWrapFlags);

///| Build a struct getelementptr instruction.
extern "C" fn __llvm_build_struct_gep2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, idx: UInt, name: CStr) -> LLVMValueRef = "__llvm_build_struct_gep2"

///| Build a struct getelementptr instruction.
pub fn llvm_build_struct_gep2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, idx: UInt, name: String) -> LLVMValueRef {
  __llvm_build_struct_gep2(builder, ty, pointer, idx, moonbit_str_to_c_str(name))
}

///| Build a struct getelementptr instruction.
pub fn LLVMBuilderRef::build_struct_gep2(self: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, idx: UInt, name: String) -> LLVMValueRef {
  llvm_build_struct_gep2(self, ty, pointer, idx, name)
}

///| Build a global string.
extern "C" fn __llvm_build_global_string(builder: LLVMBuilderRef, str: CStr, name: CStr) -> LLVMValueRef = "__llvm_build_global_string"

///| Build a global string.
pub fn llvm_build_global_string(builder: LLVMBuilderRef, str: String, name: String) -> LLVMValueRef {
  __llvm_build_global_string(builder, moonbit_str_to_c_str(str), moonbit_str_to_c_str(name))
}

///| Build a global string.
pub fn LLVMBuilderRef::build_global_string(self: LLVMBuilderRef, str: String, name: String) -> LLVMValueRef {
  llvm_build_global_string(self, str, name)
}

///| Build a global string pointer.
extern "C" fn __llvm_build_global_string_ptr(builder: LLVMBuilderRef, str: CStr, name: CStr) -> LLVMValueRef = "__llvm_build_global_string_ptr"

///| Build a global string pointer.
pub fn llvm_build_global_string_ptr(builder: LLVMBuilderRef, str: String, name: String) -> LLVMValueRef {
  __llvm_build_global_string_ptr(builder, moonbit_str_to_c_str(str), moonbit_str_to_c_str(name))
}

///| Build a global string pointer.
pub fn LLVMBuilderRef::build_global_string_ptr(self: LLVMBuilderRef, str: String, name: String) -> LLVMValueRef {
  llvm_build_global_string_ptr(self, str, name)
}

///| Check if memory access instruction is volatile.
extern "C" fn __llvm_get_volatile(memory_access_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_volatile"

///| Check if memory access instruction is volatile.
pub fn llvm_get_volatile(memory_access_inst: LLVMValueRef) -> Bool {
  let is_volatile = __llvm_get_volatile(memory_access_inst);
  to_moonbit_bool(is_volatile)
}

///| Check if memory access instruction is volatile.
pub fn LLVMValueRef::get_volatile(self: LLVMValueRef) -> Bool {
  llvm_get_volatile(self)
}

///| Set memory access instruction as volatile.
extern "C" fn __llvm_set_volatile(memory_access_inst: LLVMValueRef, is_volatile: LLVMBool) = "__llvm_set_volatile"

///| Set memory access instruction as volatile.
pub fn llvm_set_volatile(memory_access_inst: LLVMValueRef, is_volatile: Bool) -> Unit {
  __llvm_set_volatile(memory_access_inst, to_llvm_bool(is_volatile))
}
pub fn LLVMValueRef::set_volatile(self: LLVMValueRef, is_volatile: Bool) -> Unit {
  llvm_set_volatile(self, is_volatile)
}

///| Check if cmpxchg instruction is weak.
extern "C" fn __llvm_get_weak(cmp_xchg_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_weak"

///| Check if cmpxchg instruction is weak.
pub fn llvm_get_weak(cmp_xchg_inst: LLVMValueRef) -> Bool {
  let is_weak = __llvm_get_weak(cmp_xchg_inst);
  to_moonbit_bool(is_weak)
}
pub fn LLVMValueRef::get_weak(self: LLVMValueRef) -> Bool {
  llvm_get_weak(self)
}

///| Set cmpxchg instruction as weak.
extern "C" fn __llvm_set_weak(cmp_xchg_inst: LLVMValueRef, is_weak: LLVMBool) = "__llvm_set_weak"

///| Set cmpxchg instruction as weak.
pub fn llvm_set_weak(cmp_xchg_inst: LLVMValueRef, is_weak: Bool) -> Unit {
  __llvm_set_weak(cmp_xchg_inst, to_llvm_bool(is_weak))
}
pub fn LLVMValueRef::set_weak(self: LLVMValueRef, is_weak: Bool) -> Unit {
  llvm_set_weak(self, is_weak)
}

///| Get the atomic ordering for a memory access instruction.
extern "C" fn __llvm_get_ordering(memory_access_inst: LLVMValueRef) -> Int = "__llvm_get_ordering"

///| Get the atomic ordering for a memory access instruction.
pub fn llvm_get_ordering(memory_access_inst: LLVMValueRef) -> LLVMAtomicOrdering {
  LLVMAtomicOrdering::from_int(__llvm_get_ordering(memory_access_inst))
}

///| Set the atomic ordering for a memory access instruction.
extern "C" fn __llvm_set_ordering(memory_access_inst: LLVMValueRef, ordering: Int) = "__llvm_set_ordering"
pub fn llvm_set_ordering(memory_access_inst: LLVMValueRef, ordering: LLVMAtomicOrdering) -> Unit {
  __llvm_set_ordering(memory_access_inst, ordering.to_int())
}
pub fn LLVMValueRef::set_ordering(self: LLVMValueRef, ordering: LLVMAtomicOrdering) -> Unit {
  llvm_set_ordering(self, ordering)
}

///| Get the atomic rmw operation for an atomic rmw instruction.
extern "C" fn __llvm_get_atomic_rmw_bin_op(atomic_rmw_inst: LLVMValueRef) -> Int = "__llvm_get_atomic_rmw_bin_op"
pub fn llvm_get_atomic_rmw_bin_op(atomic_rmw_inst: LLVMValueRef) -> LLVMAtomicRMWBinOp {
  LLVMAtomicRMWBinOp::from_int(__llvm_get_atomic_rmw_bin_op(atomic_rmw_inst))
}

///| Get the atomic rmw operation for an atomic rmw instruction.
pub fn LLVMValueRef::get_atomic_rmw_bin_op(self: LLVMValueRef) -> LLVMAtomicRMWBinOp {
  llvm_get_atomic_rmw_bin_op(self)
}

///| Set the atomic rmw operation for an atomic rmw instruction.
extern "C" fn __llvm_set_atomic_rmw_bin_op(atomic_rmw_inst: LLVMValueRef, bin_op: Int) = "__llvm_set_atomic_rmw_bin_op"

///| Set the atomic rmw operation for an atomic rmw instruction.
pub fn llvm_set_atomic_rmw_bin_op(atomic_rmw_inst: LLVMValueRef, bin_op: LLVMAtomicRMWBinOp) -> Unit {
  __llvm_set_atomic_rmw_bin_op(atomic_rmw_inst, bin_op.to_int())
}

///| Set the atomic rmw operation for an atomic rmw instruction.
pub fn LLVMValueRef::set_atomic_rmw_bin_op(self: LLVMValueRef, bin_op: LLVMAtomicRMWBinOp) -> Unit {
  llvm_set_atomic_rmw_bin_op(self, bin_op)
}

///| Build a trunc instruction.
extern "C" fn __llvm_build_trunc(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_trunc"

///| Build a trunc instruction.
pub fn llvm_build_trunc(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_trunc(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build a trunc instruction.
pub fn LLVMBuilderRef::build_trunc(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_trunc(self, val, dest_ty, name)
}

///| Build a zext instruction.
extern "C" fn __llvm_build_z_ext(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_z_ext"

///| Build a zext instruction.
pub fn llvm_build_z_ext(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_z_ext(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build a zext instruction.
pub fn LLVMBuilderRef::build_z_ext(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_z_ext(self, val, dest_ty, name)
}

///| Build a sext instruction.
extern "C" fn __llvm_build_s_ext(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_s_ext"

///| Build a sext instruction.
pub fn llvm_build_s_ext(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_s_ext(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build a sext instruction.
pub fn LLVMBuilderRef::build_s_ext(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_s_ext(self, val, dest_ty, name)
}

///| Build a float to unsigned int instruction.
extern "C" fn __llvm_build_fp_to_ui(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_fp_to_ui"

///| Build a float to unsigned int instruction.
pub fn llvm_build_fp_to_ui(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_fp_to_ui(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build a float to unsigned int instruction.
pub fn LLVMBuilderRef::build_fp_to_ui(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_fp_to_ui(self, val, dest_ty, name)
}

///| Build a float to signed int instruction.
extern "C" fn __llvm_build_fp_to_si(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_fp_to_si"

///| Build a float to signed int instruction.
pub fn llvm_build_fp_to_si(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_fp_to_si(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build a float to signed int instruction.
pub fn LLVMBuilderRef::build_fp_to_si(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_fp_to_si(self, val, dest_ty, name)
}

///| Build an unsigned int to float instruction.
extern "C" fn __llvm_build_ui_to_fp(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_ui_to_fp"

///| Build an unsigned int to float instruction.
pub fn llvm_build_ui_to_fp(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_ui_to_fp(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build an unsigned int to float instruction.
pub fn LLVMBuilderRef::build_ui_to_fp(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_ui_to_fp(self, val, dest_ty, name)
}

///| Build a signed int to float instruction.
extern "C" fn __llvm_build_si_to_fp(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_si_to_fp"

///| Build a signed int to float instruction.
pub fn llvm_build_si_to_fp(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_si_to_fp(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build a signed int to float instruction.
pub fn LLVMBuilderRef::build_si_to_fp(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_si_to_fp(self, val, dest_ty, name)
}

///| Build a float truncation instruction.
extern "C" fn __llvm_build_fp_trunc(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_fp_trunc"

///| Build a float truncation instruction.
pub fn llvm_build_fp_trunc(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_fp_trunc(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build a float truncation instruction.
pub fn LLVMBuilderRef::build_fp_trunc(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_fp_trunc(self, val, dest_ty, name)
}

///| Build a float extension instruction.
extern "C" fn __llvm_build_fp_ext(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_fp_ext"

///| Build a float extension instruction.
pub fn llvm_build_fp_ext(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_fp_ext(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build a float extension instruction.
pub fn LLVMBuilderRef::build_fp_ext(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_fp_ext(self, val, dest_ty, name)
}

///| Build a ptr to int instruction.
extern "C" fn __llvm_build_ptr_to_int(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_ptr_to_int"

///| Build a ptr to int instruction.
pub fn llvm_build_ptr_to_int(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_ptr_to_int(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build a ptr to int instruction.
pub fn LLVMBuilderRef::build_ptr_to_int(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_ptr_to_int(self, val, dest_ty, name)
}

///| Build a int to ptr instruction.
extern "C" fn __llvm_build_int_to_ptr(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_int_to_ptr"

///| Build a int to ptr instruction.
pub fn llvm_build_int_to_ptr(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_int_to_ptr(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build a int to ptr instruction.
pub fn LLVMBuilderRef::build_int_to_ptr(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_int_to_ptr(self, val, dest_ty, name)
}

///| Build a bit cast instruction.
extern "C" fn __llvm_build_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_bit_cast"

///| Build a bit cast instruction.
pub fn llvm_build_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_bit_cast(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build a bit cast instruction.
pub fn LLVMBuilderRef::build_bit_cast(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_bit_cast(self, val, dest_ty, name)
}

///| Build address space cast instruction.
extern "C" fn __llvm_build_addr_space_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_addr_space_cast"

///| Build address space cast instruction.
pub fn llvm_build_addr_space_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_addr_space_cast(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build address space cast instruction.
pub fn LLVMBuilderRef::build_addr_space_cast(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_addr_space_cast(self, val, dest_ty, name)
}

///| Build z ext or bit cast instruction.
extern "C" fn __llvm_build_z_ext_or_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_z_ext_or_bit_cast"

///| Build z ext or bit cast instruction.
pub fn llvm_build_z_ext_or_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_z_ext_or_bit_cast(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build z ext or bit cast instruction.
pub fn LLVMBuilderRef::build_z_ext_or_bit_cast(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_z_ext_or_bit_cast(self, val, dest_ty, name)
}

///| Build s ext or bit cast instruction.
extern "C" fn __llvm_build_s_ext_or_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_s_ext_or_bit_cast"

///| Build s ext or bit cast instruction.
pub fn llvm_build_s_ext_or_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_s_ext_or_bit_cast(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build s ext or bit cast instruction.
pub fn LLVMBuilderRef::build_s_ext_or_bit_cast(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_s_ext_or_bit_cast(self, val, dest_ty, name)
}

///| Build trunc or bit cast instruction.
extern "C" fn __llvm_build_trunc_or_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_trunc_or_bit_cast"

///| Build trunc or bit cast instruction.
pub fn llvm_build_trunc_or_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_trunc_or_bit_cast(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build trunc or bit cast instruction.
pub fn LLVMBuilderRef::build_trunc_or_bit_cast(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_trunc_or_bit_cast(self, val, dest_ty, name)
}

///| Build cast instruction with given opcode.
extern "C" fn __llvm_build_cast(builder: LLVMBuilderRef, op: Int, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_cast"

///| Build cast instruction with given opcode.
pub fn llvm_build_cast(builder: LLVMBuilderRef, op: LLVMOpcode, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  let code = op.to_int()
  let name = moonbit_str_to_c_str(name)
  __llvm_build_cast(builder, code, val, dest_ty, name)
}

///| Build cast instruction with given opcode.
pub fn LLVMBuilderRef::build_cast(self: LLVMBuilderRef, op: LLVMOpcode, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_cast(self, op, val, dest_ty, name)
}

///| Build pointer cast instruction.
extern "C" fn __llvm_build_pointer_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_pointer_cast"

///| Build pointer cast instruction.
pub fn llvm_build_pointer_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_pointer_cast(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build pointer cast instruction.
pub fn LLVMBuilderRef::build_pointer_cast(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_pointer_cast(self, val, dest_ty, name)
}

///| Build int cast instruction.
extern "C" fn __llvm_build_int_cast2(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, is_signed: LLVMBool, name: CStr) -> LLVMValueRef = "__llvm_build_int_cast2"

///| Build int cast instruction.
pub fn llvm_build_int_cast2(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, is_signed: Bool, name: String) -> LLVMValueRef {
  __llvm_build_int_cast2(builder, val, dest_ty, to_llvm_bool(is_signed), moonbit_str_to_c_str(name))
}

///| Build int cast instruction.
pub fn LLVMBuilderRef::build_int_cast2(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, is_signed: Bool, name: String) -> LLVMValueRef {
  llvm_build_int_cast2(self, val, dest_ty, is_signed, name)
}

///| Build floating point cast instruction.
extern "C" fn __llvm_build_fp_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_fp_cast"

///| Build floating point cast instruction.
pub fn llvm_build_fp_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_fp_cast(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build floating point cast instruction.
pub fn LLVMBuilderRef::build_fp_cast(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_fp_cast(self, val, dest_ty, name)
}

///| Build int cast instruction.
extern "C" fn __llvm_build_int_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_int_cast"

///| Build int cast instruction.
pub fn llvm_build_int_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_int_cast(builder, val, dest_ty, moonbit_str_to_c_str(name))
}

///| Build int cast instruction.
pub fn LLVMBuilderRef::build_int_cast(self: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_int_cast(self, val, dest_ty, name)
}

///| Get the opcode for a cast instruction.
extern "C" fn __llvm_get_cast_opcode(src: LLVMValueRef, src_is_signed: LLVMBool, dest_ty: LLVMTypeRef, dest_is_signed: LLVMBool) -> Int = "__llvm_get_cast_opcode"

///| Get the opcode for a cast instruction.
pub fn llvm_get_cast_opcode(src: LLVMValueRef, src_is_signed: Bool, dest_ty: LLVMTypeRef, dest_is_signed: Bool) -> LLVMOpcode {
  let src_is_signed = to_llvm_bool(src_is_signed)
  let dest_is_signed = to_llvm_bool(dest_is_signed)
  let code = __llvm_get_cast_opcode(src, src_is_signed, dest_ty, dest_is_signed)
  LLVMOpcode::from_int(code)
}

///| Get the opcode for a cast instruction.
pub fn LLVMValueRef::get_cast_opcode(self: LLVMValueRef, src_is_signed: Bool, dest_ty: LLVMTypeRef, dest_is_signed: Bool) -> LLVMOpcode {
  llvm_get_cast_opcode(self, src_is_signed, dest_ty, dest_is_signed)
}

///| Build a icmp instruction.
extern "C" fn __llvm_build_icmp(builder: LLVMBuilderRef, op: Int, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_icmp"

///| Build a icmp instruction.
pub fn llvm_build_icmp(builder: LLVMBuilderRef, op: LLVMIntPredicate, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  let code = op.to_int()
  let name = moonbit_str_to_c_str(name)
  __llvm_build_icmp(builder, code, lhs, rhs, name)
}

///| Build a icmp instruction.
pub fn LLVMBuilderRef::build_icmp(self: LLVMBuilderRef, op: LLVMIntPredicate, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_icmp(self, op, lhs, rhs, name)
}


///| Build a floating point comparison instruction.
extern "C" fn __llvm_build_fcmp(builder: LLVMBuilderRef, op: Int, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_fcmp"

///| Build a floating point comparison instruction.
pub fn llvm_build_fcmp(builder: LLVMBuilderRef, op: LLVMRealPredicate, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  let code = op.to_int()
  let name = moonbit_str_to_c_str(name)
  __llvm_build_fcmp(builder, code, lhs, rhs, name)
}

///| Build a floating point comparison instruction.
pub fn LLVMBuilderRef::build_fcmp(self: LLVMBuilderRef, op: LLVMRealPredicate, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_fcmp(self, op, lhs, rhs, name)
}

///| Build a phi node.
extern "C" fn __llvm_build_phi(builder: LLVMBuilderRef, ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_phi"

///| Build a phi node.
pub fn llvm_build_phi(builder: LLVMBuilderRef, ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_phi(builder, ty, moonbit_str_to_c_str(name))
}

///| Build a phi node.
pub fn LLVMBuilderRef::build_phi(self: LLVMBuilderRef, ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_phi(self, ty, name)
}

///| Build a call instruction.
extern "C" fn __llvm_build_call2(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], name: CStr) -> LLVMValueRef = "__llvm_build_call2"

///| Build a call instruction.
pub fn llvm_build_call2(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  __llvm_build_call2(builder, ty, func, args, moonbit_str_to_c_str(name))
}

///| Build a call instruction.
pub fn LLVMBuilderRef::build_call2(self: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], name: String) -> LLVMValueRef {
  llvm_build_call2(self, ty, func, args, name)
}

///| Build a call instruction with operand bundles.
extern "C" fn __llvm_build_call_with_operand_bundles(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], bundles: Array[LLVMOperandBundleRef], name: CStr) -> LLVMValueRef = "__llvm_build_call_with_operand_bundles"

///| Build a call instruction with operand bundles.
pub fn llvm_build_call_with_operand_bundles(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], bundles: Array[LLVMOperandBundleRef], name: String) -> LLVMValueRef {
  __llvm_build_call_with_operand_bundles(builder, ty, func, args, bundles, moonbit_str_to_c_str(name))
}

///| Build a call instruction with operand bundles.
pub fn LLVMBuilderRef::build_call_with_operand_bundles(self: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], bundles: Array[LLVMOperandBundleRef], name: String) -> LLVMValueRef {
  llvm_build_call_with_operand_bundles(self, ty, func, args, bundles, name)
}

///| Build a select instruction.
extern "C" fn __llvm_build_select(builder: LLVMBuilderRef, if_block: LLVMValueRef, then: LLVMValueRef, else_block: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_select"

///| Build a select instruction.
pub fn llvm_build_select(builder: LLVMBuilderRef, if_block: LLVMValueRef, then: LLVMValueRef, else_block: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_select(builder, if_block, then, else_block, moonbit_str_to_c_str(name))
}

///| Build a select instruction.
pub fn LLVMBuilderRef::build_select(self: LLVMBuilderRef, if_block: LLVMValueRef, then: LLVMValueRef, else_block: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_select(self, if_block, then, else_block, name)
}

///| Build a variadic argument instruction.
extern "C" fn __llvm_build_va_arg(builder: LLVMBuilderRef, list: LLVMValueRef, ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_va_arg"

///| Build a variadic argument instruction.
pub fn llvm_build_va_arg(builder: LLVMBuilderRef, list: LLVMValueRef, ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  __llvm_build_va_arg(builder, list, ty, moonbit_str_to_c_str(name))
}

///| Build a variadic argument instruction.
pub fn LLVMBuilderRef::build_va_arg(self: LLVMBuilderRef, list: LLVMValueRef, ty: LLVMTypeRef, name: String) -> LLVMValueRef {
  llvm_build_va_arg(self, list, ty, name)
}

///| Build extract element instruction.
extern "C" fn __llvm_build_extract_element(builder: LLVMBuilderRef, vec_val: LLVMValueRef, index: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_extract_element"

///| Build extract element instruction.
pub fn llvm_build_extract_element(builder: LLVMBuilderRef, vec_val: LLVMValueRef, index: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_extract_element(builder, vec_val, index, moonbit_str_to_c_str(name))
}

///| Build extract element instruction.
pub fn LLVMBuilderRef::build_extract_element(self: LLVMBuilderRef, vec_val: LLVMValueRef, index: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_extract_element(self, vec_val, index, name)
}

///| Build insert element instruction.
extern "C" fn __llvm_build_insert_element(builder: LLVMBuilderRef, vec_val: LLVMValueRef, elt_val: LLVMValueRef, index: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_insert_element"

///| Build insert element instruction.
pub fn llvm_build_insert_element(builder: LLVMBuilderRef, vec_val: LLVMValueRef, elt_val: LLVMValueRef, index: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_insert_element(builder, vec_val, elt_val, index, moonbit_str_to_c_str(name))
}

///| Build insert element instruction.
pub fn LLVMBuilderRef::build_insert_element(self: LLVMBuilderRef, vec_val: LLVMValueRef, elt_val: LLVMValueRef, index: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_insert_element(self, vec_val, elt_val, index, name)
}

///| Build shuffle vector instruction.
extern "C" fn __llvm_build_shuffle_vector(builder: LLVMBuilderRef, v1: LLVMValueRef, v2: LLVMValueRef, mask: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_shuffle_vector"

///| Build shuffle vector instruction.
pub fn llvm_build_shuffle_vector(builder: LLVMBuilderRef, v1: LLVMValueRef, v2: LLVMValueRef, mask: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_shuffle_vector(builder, v1, v2, mask, moonbit_str_to_c_str(name))
}

///| Build shuffle vector instruction.
pub fn LLVMBuilderRef::build_shuffle_vector(self: LLVMBuilderRef, v1: LLVMValueRef, v2: LLVMValueRef, mask: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_shuffle_vector(self, v1, v2, mask, name)
}

///| Build extract value instruction.
extern "C" fn __llvm_build_extract_value(builder: LLVMBuilderRef, agg_val: LLVMValueRef, index: UInt, name: CStr) -> LLVMValueRef = "__llvm_build_extract_value"

///| Build extract value instruction.
pub fn llvm_build_extract_value(builder: LLVMBuilderRef, agg_val: LLVMValueRef, index: UInt, name: String) -> LLVMValueRef {
  __llvm_build_extract_value(builder, agg_val, index, moonbit_str_to_c_str(name))
}

///| Build extract value instruction.
pub fn LLVMBuilderRef::build_extract_value(self: LLVMBuilderRef, agg_val: LLVMValueRef, index: UInt, name: String) -> LLVMValueRef {
  llvm_build_extract_value(self, agg_val, index, name)
}

///| Build insert value instruction.
extern "C" fn __llvm_build_insert_value(builder: LLVMBuilderRef, agg_val: LLVMValueRef, elt_val: LLVMValueRef, index: UInt, name: CStr) -> LLVMValueRef = "__llvm_build_insert_value"

///| Build insert value instruction.
pub fn llvm_build_insert_value(builder: LLVMBuilderRef, agg_val: LLVMValueRef, elt_val: LLVMValueRef, index: UInt, name: String) -> LLVMValueRef {
  __llvm_build_insert_value(builder, agg_val, elt_val, index, moonbit_str_to_c_str(name))
}

///| Build insert value instruction.
pub fn LLVMBuilderRef::build_insert_value(self: LLVMBuilderRef, agg_val: LLVMValueRef, elt_val: LLVMValueRef, index: UInt, name: String) -> LLVMValueRef {
  llvm_build_insert_value(self, agg_val, elt_val, index, name)
}

///| Build freeze instruction.
extern "C" fn __llvm_build_freeze(builder: LLVMBuilderRef, val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_freeze"

///| Build freeze instruction.
pub fn llvm_build_freeze(builder: LLVMBuilderRef, val: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_freeze(builder, val, moonbit_str_to_c_str(name))
}

///| Build freeze instruction.
pub fn LLVMBuilderRef::build_freeze(self: LLVMBuilderRef, val: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_freeze(self, val, name)
}

///| Build is null instruction.
extern "C" fn __llvm_build_is_null(builder: LLVMBuilderRef, val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_is_null"

///| Build is null instruction.
pub fn llvm_build_is_null(builder: LLVMBuilderRef, val: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_is_null(builder, val, moonbit_str_to_c_str(name))
}

///| Build is null instruction.
pub fn LLVMBuilderRef::build_is_null(self: LLVMBuilderRef, val: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_is_null(self, val, name)
}

///| Build is not null instruction.
extern "C" fn __llvm_build_is_not_null(builder: LLVMBuilderRef, val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_is_not_null"

///| Build is not null instruction.
pub fn llvm_build_is_not_null(builder: LLVMBuilderRef, val: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_is_not_null(builder, val, moonbit_str_to_c_str(name))
}

///| Build is not null instruction.
pub fn LLVMBuilderRef::build_is_not_null(self: LLVMBuilderRef, val: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_is_not_null(self, val, name)
}

///| Build ptr diff instruction.
extern "C" fn __llvm_build_ptr_diff2(builder: LLVMBuilderRef, elem_ty: LLVMTypeRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_ptr_diff2"

///| Build ptr diff instruction.
pub fn llvm_build_ptr_diff2(builder: LLVMBuilderRef, elem_ty: LLVMTypeRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  __llvm_build_ptr_diff2(builder, elem_ty, lhs, rhs, moonbit_str_to_c_str(name))
}

///| Build ptr diff instruction.
pub fn LLVMBuilderRef::build_ptr_diff2(self: LLVMBuilderRef, elem_ty: LLVMTypeRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: String) -> LLVMValueRef {
  llvm_build_ptr_diff2(self, elem_ty, lhs, rhs, name)
}

///| Build fence instruction.
extern "C" fn __llvm_build_fence(builder: LLVMBuilderRef, ordering: Int, single_thread: LLVMBool, name: CStr) -> LLVMValueRef = "__llvm_build_fence"

///| Build fence instruction.
pub fn llvm_build_fence(builder: LLVMBuilderRef, ordering: LLVMAtomicOrdering, single_thread: Bool, name: String) -> LLVMValueRef {
  let code = ordering.to_int()
  let name = moonbit_str_to_c_str(name)
  let single_thread = to_llvm_bool(single_thread)
  __llvm_build_fence(builder, code, single_thread, name)
}

///| Build atomic rmw instruction.
extern "C" fn __llvm_build_atomic_rmw(builder: LLVMBuilderRef, op: Int, ptr: LLVMValueRef, val: LLVMValueRef, ordering: Int, single_thread: LLVMBool) -> LLVMValueRef = "__llvm_build_atomic_rmw"

///| Build atomic rmw instruction.
pub fn llvm_build_atomic_rmw(builder: LLVMBuilderRef, op: LLVMAtomicRMWBinOp, ptr: LLVMValueRef, val: LLVMValueRef, ordering: LLVMAtomicOrdering, single_thread: LLVMBool) -> LLVMValueRef {
  let op = op.to_int()
  let ordering = ordering.to_int()
  __llvm_build_atomic_rmw(builder, op, ptr, val, ordering, single_thread)
}

///| Build atomic rmw instruction.
pub fn LLVMBuilderRef::build_atomic_rmw(self: LLVMBuilderRef, op: LLVMAtomicRMWBinOp, ptr: LLVMValueRef, val: LLVMValueRef, ordering: LLVMAtomicOrdering, single_thread: LLVMBool) -> LLVMValueRef {
  llvm_build_atomic_rmw(self, op, ptr, val, ordering, single_thread)
}

///| Build atomic cmp xchg instruction.
extern "C" fn __llvm_build_atomic_cmp_xchg(builder: LLVMBuilderRef, ptr: LLVMValueRef, cmp: LLVMValueRef, _new: LLVMValueRef, success_ordering: Int, failure_ordering: Int, single_thread: LLVMBool) -> LLVMValueRef = "__llvm_build_atomic_cmp_xchg"

///| Build atomic cmp xchg instruction.
pub fn llvm_build_atomic_cmp_xchg(builder: LLVMBuilderRef, ptr: LLVMValueRef, cmp: LLVMValueRef, _new: LLVMValueRef, success_ordering: LLVMAtomicOrdering, failure_ordering: LLVMAtomicOrdering, single_thread: LLVMBool) -> LLVMValueRef {
  let success_ordering = success_ordering.to_int()
  let failure_ordering = failure_ordering.to_int()
  __llvm_build_atomic_cmp_xchg(builder, ptr, cmp, _new, success_ordering, failure_ordering, single_thread)
}

///| Get the number of elements in the mask of a ShuffleVector instruction.
pub extern "C" fn llvm_get_num_mask_elements(shuffle_vector_inst: LLVMValueRef) -> UInt = "__llvm_get_num_mask_elements"
pub fn LLVMValueRef::get_num_mask_elements(self: LLVMValueRef) -> UInt {
  llvm_get_num_mask_elements(self)
}


// 
// returns a constant that specifies that the result of a ShuffleVectorInst
// is undefined.
// 
pub extern "C" fn llvm_get_undef_mask_elem() -> Int = "__llvm_get_undef_mask_elem"


///| Get the mask value at position Elt in the mask of a ShuffleVector instruction.
/// 
/// Returns the result of LLVMGetUndefMaskElem() if the mask value is
/// poison at that position.
pub extern "C" fn llvm_get_mask_value(shuffle_vector_inst: LLVMValueRef, elt: UInt) -> Int = "__llvm_get_mask_value"

///| Get the mask value at position Elt in the mask of a ShuffleVector instruction.
/// 
/// Returns the result of LLVMGetUndefMaskElem() if the mask value is
/// poison at that position.
pub fn LLVMValueRef::get_mask_value(self: LLVMValueRef, elt: UInt) -> Int {
  llvm_get_mask_value(self, elt)
}

///| Returns whether an instruction is an atomic instruction.
///
/// Returns whether an instruction is an atomic instruction, e.g., atomicrmw,
/// cmpxchg, fence, or loads and stores with atomic ordering.
extern "C" fn __llvm_is_atomic(inst: LLVMValueRef) -> LLVMBool = "__llvm_is_atomic"

///| Returns whether an instruction is an atomic instruction.
///
/// Returns whether an instruction is an atomic instruction, e.g., atomicrmw,
/// cmpxchg, fence, or loads and stores with atomic ordering.
pub fn llvm_is_atomic(inst: LLVMValueRef) -> Bool {
  __llvm_is_atomic(inst).to_moonbit_bool()
}


///| Check if the atomic instruction is single-thread.
pub extern "C" fn llvm_is_atomic_single_thread(atomic_inst: LLVMValueRef) -> LLVMBool = "__llvm_is_atomic_single_thread"

///| Check if the atomic instruction is single-thread.
pub fn LLVMValueRef::is_atomic_single_thread(self: LLVMValueRef) -> Bool {
  llvm_is_atomic_single_thread(self).to_moonbit_bool()
}

///| Set the atomic instruction to be single-thread.
extern "C" fn __llvm_set_atomic_single_thread(atomic_inst: LLVMValueRef, single_thread: LLVMBool) = "__llvm_set_atomic_single_thread"

///| Set the atomic instruction to be single-thread.
pub fn llvm_set_atomic_single_thread(atomic_inst: LLVMValueRef, single_thread: Bool) -> Unit {
  let single_thread = to_llvm_bool(single_thread)
  __llvm_set_atomic_single_thread(atomic_inst, single_thread)
}

///| Set the atomic instruction to be single-thread.
pub fn LLVMValueRef::set_atomic_single_thread(self: LLVMValueRef, single_thread: Bool) -> Unit {
  llvm_set_atomic_single_thread(self, single_thread)
}

///| Get the atomic ordering of an atomic instruction.
extern "C" fn __llvm_get_cmp_xchg_success_ordering(cmp_xchg_inst: LLVMValueRef) -> Int = "__llvm_get_cmp_xchg_success_ordering"

///| Get the atomic ordering of an atomic instruction.
pub fn llvm_get_cmp_xchg_success_ordering(cmp_xchg_inst: LLVMValueRef) -> LLVMAtomicOrdering {
  let idx = __llvm_get_cmp_xchg_success_ordering(cmp_xchg_inst)
  LLVMAtomicOrdering::from_int(idx)
}

extern "C" fn __llvm_set_cmp_xchg_success_ordering(cmp_xchg_inst: LLVMValueRef, ordering: Int) = "__llvm_set_cmp_xchg_success_ordering"
pub fn llvm_set_cmp_xchg_success_ordering(cmp_xchg_inst: LLVMValueRef, ordering: LLVMAtomicOrdering) -> Unit {
  let idx = ordering.to_int()
  __llvm_set_cmp_xchg_success_ordering(cmp_xchg_inst, idx)
}

///| Get the atomic ordering of an atomic instruction.
extern "C" fn __llvm_get_cmp_xchg_failure_ordering(cmp_xchg_inst: LLVMValueRef) -> Int = "__llvm_get_cmp_xchg_failure_ordering"

///| Get the atomic ordering of an atomic instruction.
pub fn llvm_get_cmp_xchg_failure_ordering(cmp_xchg_inst: LLVMValueRef) -> LLVMAtomicOrdering {
  let idx = __llvm_get_cmp_xchg_failure_ordering(cmp_xchg_inst)
  LLVMAtomicOrdering::from_int(idx)
}

///| Set the atomic ordering of an atomic instruction.
extern "C" fn __llvm_set_cmp_xchg_failure_ordering(cmp_xchg_inst: LLVMValueRef, ordering: Int) = "__llvm_set_cmp_xchg_failure_ordering"

///| Set the atomic ordering of an atomic instruction.
pub fn llvm_set_cmp_xchg_failure_ordering(cmp_xchg_inst: LLVMValueRef, ordering: LLVMAtomicOrdering) -> Unit {
  let idx = ordering.to_int()
  __llvm_set_cmp_xchg_failure_ordering(cmp_xchg_inst, idx)
}

/// Changes the type of M so it can be passed to FunctionPassManagers and the
/// JIT.  They take ModuleProviders for historical reasons.
pub extern "C" fn llvm_create_module_provider_for_existing_module(m: LLVMModuleRef) -> LLVMModuleProviderRef = "__llvm_create_module_provider_for_existing_module"


///| Destroys the module M.
pub extern "C" fn llvm_dispose_module_provider(m: LLVMModuleProviderRef) = "__llvm_dispose_module_provider"

///| Create a new memory buffer with the contents of a file.
// FIXME: Not implemented
extern "C" fn __llvm_create_memory_buffer_with_contents_of_file(path: CStr) -> (LLVMMemoryBufferRef, CStr, LLVMBool) = "__llvm_create_memory_buffer_with_contents_of_file"

///| Create a new memory buffer with the contents of a file.
///
/// Return the memory buffer, the error message and a boolean indicating if the operation was successful.
pub fn llvm_create_memory_buffer_with_contents_of_file(path: String) -> (LLVMMemoryBufferRef, String, Bool) {
  let cpath = moonbit_str_to_c_str(path)
  let (mbuf, cstr, is_ok) = __llvm_create_memory_buffer_with_contents_of_file(cpath)
  let is_ok = is_ok.to_moonbit_bool()
  if is_ok {
    (mbuf, c_str_to_moonbit_str(cstr), is_ok)
  } else {
    (mbuf, "", is_ok)
  }
}

///| Create a memory buffer with stdin as input.
// FIXME: Not implemented
extern "C" fn __llvm_create_memory_buffer_with_stdin() -> (LLVMMemoryBufferRef, CStr, LLVMBool) = "__llvm_create_memory_buffer_with_stdin"

///| Create a memory buffer with stdin as input.
pub fn llvm_create_memory_buffer_with_stdin() -> (LLVMMemoryBufferRef, String, Bool) {
  let (mbuf, cstr, is_ok) = __llvm_create_memory_buffer_with_stdin()
  let is_ok = is_ok.to_moonbit_bool()
  if is_ok {
    (mbuf, c_str_to_moonbit_str(cstr), is_ok)
  } else {
    (mbuf, "", is_ok)
  }
}

///| Create a new memory buffer with the contents of a memory range.
extern "C" fn __llvm_create_memory_buffer_with_memory_range(input_data: CStr, input_data_length: Int, buffer_name: CStr, requires_null_terminator: LLVMBool) -> LLVMMemoryBufferRef = "__llvm_create_memory_buffer_with_memory_range"

///| Create a new memory buffer with the contents of a memory range.
pub fn llvm_create_memory_buffer_with_memory_range(input_data: String, input_data_length: Int, buffer_name: String, requires_null_terminator: Bool) -> LLVMMemoryBufferRef {
  let input_data = moonbit_str_to_c_str(input_data)
  let buffer_name = moonbit_str_to_c_str(buffer_name)
  let requires_null_terminator = to_llvm_bool(requires_null_terminator)
  __llvm_create_memory_buffer_with_memory_range(input_data, input_data_length, buffer_name, requires_null_terminator)
}

///| Create a new memory buffer with the contents of a memory range.
extern "C" fn __llvm_create_memory_buffer_with_memory_range_copy(input_data: CStr, input_data_length: Int, buffer_name: CStr) -> LLVMMemoryBufferRef = "__llvm_create_memory_buffer_with_memory_range_copy"

///| Create a new memory buffer with the contents of a memory range.
pub fn llvm_create_memory_buffer_with_memory_range_copy(input_data: String, input_data_length: Int, buffer_name: String) -> LLVMMemoryBufferRef {
  let input_data = moonbit_str_to_c_str(input_data)
  let buffer_name = moonbit_str_to_c_str(buffer_name)
  __llvm_create_memory_buffer_with_memory_range_copy(input_data, input_data_length, buffer_name)
}

// TODO: Need to check if this is correct
extern "C" fn __llvm_get_buffer_start(mem_buf: LLVMMemoryBufferRef) -> CStr = "__llvm_get_buffer_start"
pub fn llvm_get_buffer_start(mem_buf: LLVMMemoryBufferRef) -> String {
  c_str_to_moonbit_str(__llvm_get_buffer_start(mem_buf))
}
pub fn LLVMMemoryBufferRef::get_buffer_start(self: LLVMMemoryBufferRef) -> String {
  llvm_get_buffer_start(self)
}

///| Get buffer size
pub extern "C" fn llvm_get_buffer_size(mem_buf: LLVMMemoryBufferRef) -> Int = "__llvm_get_buffer_size"

///| Get buffer size
pub fn LLVMMemoryBufferRef::get_buffer_size(self: LLVMMemoryBufferRef) -> Int {
  llvm_get_buffer_size(self)
}

///| Frees the memory buffer.
pub extern "C" fn llvm_dispose_memory_buffer(mem_buf: LLVMMemoryBufferRef) = "__llvm_dispose_memory_buffer"

///| Frees the memory buffer.
pub fn LLVMMemoryBufferRef::dispose_memory_buffer(self: LLVMMemoryBufferRef) -> Unit {
  llvm_dispose_memory_buffer(self)
}

///| Constructs a new whole-module pass pipeline.
///
/// This type of pipeline is suitable for link-time optimization
/// and whole-module transformations.
///
/// - see llvm::PassManager::PassManager
pub extern "C" fn llvm_create_pass_manager() -> LLVMPassManagerRef = "__llvm_create_pass_manager"

///| Constructs a new whole-module pass pipeline.
///
/// This type of pipeline is suitable for link-time optimization
/// and whole-module transformations.
///
/// - see llvm::PassManager::PassManager
pub fn LLVMPassManagerRef::create() -> LLVMPassManagerRef {
  llvm_create_pass_manager()
}

///| Constructs a new function-by-function pass pipeline over the module
///
/// Constructs a new function-by-function pass pipeline over the module
/// provider. It does not take ownership of the module provider. This type of
/// pipeline is suitable for code generation and JIT compilation tasks.
///
/// - see llvm::FunctionPassManager::FunctionPassManager
pub extern "C" fn llvm_create_function_pass_manager_for_module(m: LLVMModuleRef) -> LLVMPassManagerRef = "__llvm_create_function_pass_manager_for_module"

///| Constructs a new function-by-function pass pipeline over the module
///
/// Constructs a new function-by-function pass pipeline over the module
/// provider. It does not take ownership of the module provider. This type of
/// pipeline is suitable for code generation and JIT compilation tasks.
///
/// - see llvm::FunctionPassManager::FunctionPassManager
pub fn LLVMModuleRef::create_function_pass_manager(self: LLVMModuleRef) -> LLVMPassManagerRef {
  llvm_create_function_pass_manager_for_module(self)
}

// Deprecated
// pub extern "C" fn llvm_create_function_pass_manager(mp: LLVMModuleProviderRef) -> LLVMPassManagerRef = "__llvm_create_function_pass_manager"
// pub fn LLVMModuleProviderRef::create_function_pass_manager(self: LLVMModuleProviderRef) -> LLVMPassManagerRef {
//   llvm_create_function_pass_manager(self)
// }

///| Run the pass manager.
///
/// Initializes, executes on the provided module, and finalizes all of the
/// passes scheduled in the pass manager. Returns 1 if any of the passes
/// modified the module, 0 otherwise.
///
/// - see llvm::PassManager::run(Module&)
pub extern "C" fn llvm_run_pass_manager(pm: LLVMPassManagerRef, m: LLVMModuleRef) -> LLVMBool = "__llvm_run_pass_manager"

///| Run the pass manager.
///
/// Initializes, executes on the provided module, and finalizes all of the
/// passes scheduled in the pass manager. Returns 1 if any of the passes
/// modified the module, 0 otherwise.
///
/// - see llvm::PassManager::run(Module&)
pub fn LLVMPassManagerRef::run(self: LLVMPassManagerRef, m: LLVMModuleRef) -> Bool {
  llvm_run_pass_manager(self, m).to_moonbit_bool()
}

///| Initialize a function pass manager.
///
///  Initializes all of the function passes scheduled in the function pass
///  manager. Returns 1 if any of the passes modified the module, 0 otherwise.
///
///  - see llvm::FunctionPassManager::doInitialization.
pub extern "C" fn llvm_initialize_function_pass_manager(fpm: LLVMPassManagerRef) -> LLVMBool = "__llvm_initialize_function_pass_manager"

///| Initialize a function pass manager.
///
///  Initializes all of the function passes scheduled in the function pass
///  manager. Returns 1 if any of the passes modified the module, 0 otherwise.
///
///  - see llvm::FunctionPassManager::doInitialization.
pub fn LLVMPassManagerRef::initialize_function_pass_manager(self: LLVMPassManagerRef) -> Bool {
  llvm_initialize_function_pass_manager(self).to_moonbit_bool()
}

///| Run the function pass manager on a given function.
///
/// Executes all of the function passes scheduled in the function pass manager
/// on the provided function. Returns 1 if any of the passes modified the
/// function, false otherwise.
///
/// - see llvm::FunctionPassManager::run(Function&)
pub extern "C" fn llvm_run_function_pass_manager(fpm: LLVMPassManagerRef, f: LLVMValueRef) -> LLVMBool = "__llvm_run_function_pass_manager"

///| Run the function pass manager on a given function.
///
/// Executes all of the function passes scheduled in the function pass manager
/// on the provided function. Returns 1 if any of the passes modified the
/// function, false otherwise.
///
/// - see llvm::FunctionPassManager::run(Function&)
pub fn LLVMPassManagerRef::run_function_pass_manager(self: LLVMPassManagerRef, f: LLVMValueRef) -> Bool {
  llvm_run_function_pass_manager(self, f).to_moonbit_bool()
}

///| Finalizes all of the function passes scheduled in the function pass manager.
///
/// Returns 1 if any of the passes modified the module, 0 otherwise.
///
/// - see llvm::FunctionPassManager::doFinalization.
pub extern "C" fn llvm_finalize_function_pass_manager(fpm: LLVMPassManagerRef) -> LLVMBool = "__llvm_finalize_function_pass_manager"

///| Finalizes all of the function passes scheduled in the function pass manager.
///
/// Returns 1 if any of the passes modified the module, 0 otherwise.
///
/// - see llvm::FunctionPassManager::doFinalization.
pub fn LLVMPassManagerRef::finalize_function_pass_manager(self: LLVMPassManagerRef) -> Bool {
  llvm_finalize_function_pass_manager(self).to_moonbit_bool()
}


///| Frees the memory of a pass pipeline.
///
/// Frees the memory of a pass pipeline. For function pipelines, does not free
/// the module provider.
///
/// - see llvm::PassManagerBase::~PassManagerBase.
pub extern "C" fn llvm_dispose_pass_manager(pm: LLVMPassManagerRef) = "__llvm_dispose_pass_manager"
pub fn LLVMPassManagerRef::dispose_pass_manager(self: LLVMPassManagerRef) -> Unit {
  llvm_dispose_pass_manager(self)
}

// Deprecated
// extern "C" fn __llvm_start_multithreaded() -> LLVMBool = "__llvm_start_multithreaded"
// pub fn llvm_start_multithreaded() -> Bool {
//   __llvm_start_multithreaded().to_moonbit_bool()
// }

// Deprecated
// pub extern "C" fn llvm_stop_multithreaded() = "__llvm_stop_multithreaded"

///| Check whether LLVM is executing in thread-safe mode or not.
///
/// - see llvm::llvm_is_multithreaded.
extern "C" fn __llvm_is_multithreaded() -> LLVMBool = "__llvm_is_multithreaded"
pub fn llvm_is_multithreaded() -> Bool {
  __llvm_is_multithreaded().to_moonbit_bool()
}

// =======================================================
// Comdat.h
// =======================================================

///| Return the Comdat in the module with the specified name.
///
/// Return the Comdat in the module with the specified name. It is created
/// if it didn't already exist.
/// 
/// - see llvm::Module::getOrInsertComdat()
extern "C" fn __llvm_get_or_insert_comdat(m: LLVMModuleRef, name: CStr) -> LLVMComdatRef = "__llvm_get_or_insert_comdat"
pub fn llvm_get_or_insert_comdat(m: LLVMModuleRef, name: String) -> LLVMComdatRef {
  let name = moonbit_str_to_c_str(name)
  __llvm_get_or_insert_comdat(m, name)
}
pub fn LLVMModuleRef::get_or_insert_comdat(self: LLVMModuleRef, name: String) -> LLVMComdatRef {
  let name = moonbit_str_to_c_str(name)
  __llvm_get_or_insert_comdat(self, name)
}

///| Get the Comdat assigned to the given global object.
/// 
/// - see llvm::GlobalObject::getComdat()
pub extern "C" fn llvm_get_comdat(v: LLVMValueRef) -> LLVMComdatRef = "__llvm_get_comdat"

///| Assign the Comdat to the given global object.
/// 
/// - see llvm::GlobalObject::setComdat()
pub extern "C" fn llvm_set_comdat(v: LLVMValueRef, c: LLVMComdatRef) = "__llvm_set_comdat"

///| Get the conflict resolution selection kind for the Comdat.
/// 
/// - see llvm::Comdat::getSelectionKind()
extern "C" fn __llvm_get_comdat_selection_kind(c: LLVMComdatRef) -> Int = "__llvm_get_comdat_selection_kind"
pub fn llvm_get_comdat_selection_kind(c: LLVMComdatRef) -> LLVMComdatSelectionKind {
  let kind = __llvm_get_comdat_selection_kind(c)
  let kind = LLVMComdatSelectionKind::from_int(kind)

  kind
}

///| Set the conflict resolution selection kind for the Comdat.
/// 
/// - see llvm::Comdat::setSelectionKind()
extern "C" fn __llvm_set_comdat_selection_kind(c: LLVMComdatRef, kind: Int) = "__llvm_set_comdat_selection_kind"
pub fn llvm_set_comdat_selection_kind(c: LLVMComdatRef, kind: LLVMComdatSelectionKind) -> Unit {
  let i = kind.to_int()
  __llvm_set_comdat_selection_kind(c, i)
}

// =======================================================
// Linker.h
// =======================================================

///| Links the source module into the destination module.
/// 
/// Links the source module into the destination module. The source 
/// module is destroyed.
/// The return value is true if an error occurred, false otherwise.
/// Use the diagnostic handler to get any diagnostic message.
extern "C" fn __llvm_link_modules2(dest: LLVMModuleRef, src: LLVMModuleRef) -> LLVMBool = "__llvm_link_modules2"
pub fn llvm_link_modules(dest: LLVMModuleRef, src: LLVMModuleRef) -> Bool {
  __llvm_link_modules2(dest, src).to_moonbit_bool()
}

// =======================================================
// TargetMachine.h
// =======================================================

///| Returns the first llvm::Target in the registered targets list.
pub extern "C" fn llvm_get_first_target() -> LLVMTargetRef = "__llvm_get_first_target"

///| Returns the next llvm::Target given a previous one (or null if there's none)
pub extern "C" fn llvm_get_next_target(t: LLVMTargetRef) -> LLVMTargetRef = "__llvm_get_next_target"

///|  Finds the target corresponding to the given name.
extern "C" fn __llvm_get_target_from_name(name: CStr) -> LLVMTargetRef = "__llvm_get_target_from_name"
pub fn llvm_get_target_from_name(name: String) -> LLVMTargetRef {
  let name = moonbit_str_to_c_str(name)
  __llvm_get_target_from_name(name)
}

/// Finds the target corresponding to the given triple and stores it in `T`.
/// Returns 0 on success. Optionally returns any error in ErrorMessage.
/// Use LLVMDisposeMessage to dispose the message.
// TODO: check if this is correct
extern "C" fn __llvm_get_target_from_triple(triple: CStr) -> (LLVMTargetRef, CStr, LLVMBool) = "__llvm_get_target_from_triple"

/// Finds the target corresponding to the given triple and stores it in `T`.
/// Returns 0 on success. Optionally returns any error in ErrorMessage.
/// Use LLVMDisposeMessage to dispose the message.
pub fn llvm_get_target_from_triple(triple: String) -> (LLVMTargetRef, String, Bool) {
  let triple = moonbit_str_to_c_str(triple)
  let (target, cstr, is_ok) = __llvm_get_target_from_triple(triple)
  let is_ok = is_ok.to_moonbit_bool()
  if is_ok {
    (target, c_str_to_moonbit_str(cstr), is_ok)
  } else {
    (target, "", is_ok)
  }
}

///| Returns the name of a target. See llvm::Target::getName
extern "C" fn __llvm_get_target_name(t: LLVMTargetRef) -> CStr = "__llvm_get_target_name"
pub fn llvm_get_target_name(t: LLVMTargetRef) -> String {
  c_str_to_moonbit_str(__llvm_get_target_name(t))
}

///| Returns the description  of a target. See llvm::Target::getDescription.
extern "C" fn __llvm_get_target_description(t: LLVMTargetRef) -> CStr = "__llvm_get_target_description"
pub fn llvm_get_target_description(t: LLVMTargetRef) -> String {
  c_str_to_moonbit_str(__llvm_get_target_description(t))
}

///| Returns if the target has a JIT.
pub extern "C" fn llvm_target_has_jit(t: LLVMTargetRef) -> LLVMBool = "__llvm_target_has_jit"


///| Returns if the target has a TargetMachine associated.
extern "C" fn __llvm_target_has_target_machine(t: LLVMTargetRef) -> LLVMBool = "__llvm_target_has_target_machine"
pub fn llvm_target_has_target_machine(t: LLVMTargetRef) -> Bool {
  __llvm_target_has_target_machine(t).to_moonbit_bool()
}


///| Returns if the target as an ASM backend (required for emitting output).
extern "C" fn __llvm_target_has_asm_backend(t: LLVMTargetRef) -> LLVMBool = "__llvm_target_has_asm_backend"
pub fn llvm_target_has_asm_backend(t: LLVMTargetRef) -> Bool {
  __llvm_target_has_asm_backend(t).to_moonbit_bool()
}

///| Create a new set of options for an llvm::TargetMachine.
/// 
/// The returned option structure must be released with
/// LLVMDisposeTargetMachineOptions() after the call to
/// LLVMCreateTargetMachineWithOptions().
pub extern "C" fn llvm_create_target_machine_options() -> LLVMTargetMachineOptionsRef = "__llvm_create_target_machine_options"

///| Dispose of an LLVMTargetMachineOptionsRef instance.
pub extern "C" fn llvm_dispose_target_machine_options(options: LLVMTargetMachineOptionsRef) = "__llvm_dispose_target_machine_options"

extern "C" fn __llvm_target_machine_options_set_cpu(options: LLVMTargetMachineOptionsRef, cpu: CStr) = "__llvm_target_machine_options_set_cpu" 
pub fn llvm_target_machine_options_set_cpu(options: LLVMTargetMachineOptionsRef, cpu: String) -> Unit {
  let cpu = moonbit_str_to_c_str(cpu)
  __llvm_target_machine_options_set_cpu(options, cpu)
}

///| Set the list of features for the target machine.
/// 
/// - param Features a comma-separated list of features.
extern "C" fn __llvm_target_machine_options_set_features(options: LLVMTargetMachineOptionsRef, features: CStr) = "__llvm_target_machine_options_set_features"
pub fn llvm_target_machine_options_set_features(options: LLVMTargetMachineOptionsRef, features: String) -> Unit {
  let features = moonbit_str_to_c_str(features)
  __llvm_target_machine_options_set_features(options, features)
}

extern "C" fn __llvm_target_machine_options_set_abi(options: LLVMTargetMachineOptionsRef, abi: CStr) = "__llvm_target_machine_options_set_abi"
pub fn llvm_target_machine_options_set_abi(options: LLVMTargetMachineOptionsRef, abi: String) -> Unit {
  let abi = moonbit_str_to_c_str(abi)
  __llvm_target_machine_options_set_abi(options, abi)
}

pub extern "C" fn llvm_target_machine_options_set_codegen_opt_level(options: LLVMTargetMachineOptionsRef, level: LLVMCodeGenOptLevel) = "__llvm_target_machine_options_set_codegen_opt_level"

pub extern "C" fn llvm_target_machine_options_set_reloc_mode(options: LLVMTargetMachineOptionsRef, reloc: LLVMRelocMode) = "__llvm_target_machine_options_set_reloc_mode"

pub extern "C" fn llvm_target_machine_options_set_code_model(options: LLVMTargetMachineOptionsRef, code_model: LLVMCodeModel) = "__llvm_target_machine_options_set_code_model"

//
// /**
//  * Create a new llvm::TargetMachine.
//  *
//  * \param T the target to create a machine for.
//  * \param Triple a triple describing the target machine.
//  * \param Options additional configuration (see
//  *                LLVMCreateTargetMachineOptions()).
//  */
// LLVMTargetMachineRef
// LLVMCreateTargetMachineWithOptions(LLVMTargetRef T, const char *Triple,
//                                    LLVMTargetMachineOptionsRef Options);
extern "C" fn __llvm_create_target_machine_with_options(t: LLVMTargetRef, triple: CStr, options: LLVMTargetMachineOptionsRef) -> LLVMTargetMachineRef = "__llvm_create_target_machine_with_options"
pub fn llvm_create_target_machine_with_options(t: LLVMTargetRef, triple: String, options: LLVMTargetMachineOptionsRef) -> LLVMTargetMachineRef {
  let triple = moonbit_str_to_c_str(triple)
  __llvm_create_target_machine_with_options(t, triple, options)
}

///| Creates a new llvm::TargetMachine. See llvm::Target::createTargetMachine.
extern "C" fn __llvm_create_target_machine(t: LLVMTargetRef, triple: CStr, cpu: CStr, features: CStr, level: LLVMCodeGenOptLevel, reloc: LLVMRelocMode, code_model: LLVMCodeModel) -> LLVMTargetMachineRef = "__llvm_create_target_machine"
pub fn llvm_create_target_machine(t: LLVMTargetRef, triple: String, cpu: String, features: String, level: LLVMCodeGenOptLevel, reloc: LLVMRelocMode, code_model: LLVMCodeModel) -> LLVMTargetMachineRef {
  let triple = moonbit_str_to_c_str(triple)
  let cpu = moonbit_str_to_c_str(cpu)
  let features = moonbit_str_to_c_str(features)
  __llvm_create_target_machine(t, triple, cpu, features, level, reloc, code_model)
}


// /** Dispose the LLVMTargetMachineRef instance generated by
//   LLVMCreateTargetMachine. */
// void LLVMDisposeTargetMachine(LLVMTargetMachineRef T);
//
// /** Returns the Target used in a TargetMachine */
// LLVMTargetRef LLVMGetTargetMachineTarget(LLVMTargetMachineRef T);
//
// /** Returns the triple used creating this target machine. See
//   llvm::TargetMachine::getTriple. The result needs to be disposed with
//   LLVMDisposeMessage. */
// char *LLVMGetTargetMachineTriple(LLVMTargetMachineRef T);
//
// /** Returns the cpu used creating this target machine. See
//   llvm::TargetMachine::getCPU. The result needs to be disposed with
//   LLVMDisposeMessage. */
// char *LLVMGetTargetMachineCPU(LLVMTargetMachineRef T);
//
// /** Returns the feature string used creating this target machine. See
//   llvm::TargetMachine::getFeatureString. The result needs to be disposed with
//   LLVMDisposeMessage. */
// char *LLVMGetTargetMachineFeatureString(LLVMTargetMachineRef T);
//
// /** Create a DataLayout based on the targetMachine. */
// LLVMTargetDataRef LLVMCreateTargetDataLayout(LLVMTargetMachineRef T);
//
// /** Set the target machine's ASM verbosity. */
// void LLVMSetTargetMachineAsmVerbosity(LLVMTargetMachineRef T,
//                                       LLVMBool VerboseAsm);
//
// /** Enable fast-path instruction selection. */
// void LLVMSetTargetMachineFastISel(LLVMTargetMachineRef T, LLVMBool Enable);
//
// /** Enable global instruction selection. */
// void LLVMSetTargetMachineGlobalISel(LLVMTargetMachineRef T, LLVMBool Enable);
//
// /** Set abort behaviour when global instruction selection fails to lower/select
//  * an instruction. */
// void LLVMSetTargetMachineGlobalISelAbort(LLVMTargetMachineRef T,
//                                          LLVMGlobalISelAbortMode Mode);
//
// /** Enable the MachineOutliner pass. */
// void LLVMSetTargetMachineMachineOutliner(LLVMTargetMachineRef T,
//                                          LLVMBool Enable);
//
// /** Emits an asm or object file for the given module to the filename. This
//   wraps several c++ only classes (among them a file stream). Returns any
//   error in ErrorMessage. Use LLVMDisposeMessage to dispose the message. */
// LLVMBool LLVMTargetMachineEmitToFile(LLVMTargetMachineRef T, LLVMModuleRef M,
//                                      const char *Filename,
//                                      LLVMCodeGenFileType codegen,
//                                      char **ErrorMessage);
//
// /** Compile the LLVM IR stored in \p M and store the result in \p OutMemBuf. */
// LLVMBool LLVMTargetMachineEmitToMemoryBuffer(LLVMTargetMachineRef T, LLVMModuleRef M,
//   LLVMCodeGenFileType codegen, char** ErrorMessage, LLVMMemoryBufferRef *OutMemBuf);
//
// /*===-- Triple ------------------------------------------------------------===*/
// /** Get a triple for the host machine as a string. The result needs to be
//   disposed with LLVMDisposeMessage. */
// char* LLVMGetDefaultTargetTriple(void);
//
// /** Normalize a target triple. The result needs to be disposed with
//   LLVMDisposeMessage. */
// char* LLVMNormalizeTargetTriple(const char* triple);
//
// /** Get the host CPU as a string. The result needs to be disposed with
//   LLVMDisposeMessage. */
// char* LLVMGetHostCPUName(void);
//
// /** Get the host CPU's features as a string. The result needs to be disposed
//   with LLVMDisposeMessage. */
// char* LLVMGetHostCPUFeatures(void);
//
// /** Adds the target-specific analysis passes to the pass manager. */
// void LLVMAddAnalysisPasses(LLVMTargetMachineRef T, LLVMPassManagerRef PM);

// =======================================================
// BitReader.h
// =======================================================

// /* Builds a module from the bitcode in the specified memory buffer, returning a
//    reference to the module via the OutModule parameter. Returns 0 on success.
//    Optionally returns a human-readable error message via OutMessage.
//
//    This is deprecated. Use LLVMParseBitcode2. */
// LLVMBool LLVMParseBitcode(LLVMMemoryBufferRef MemBuf, LLVMModuleRef *OutModule,
//                           char **OutMessage);
//
// /* Builds a module from the bitcode in the specified memory buffer, returning a
//    reference to the module via the OutModule parameter. Returns 0 on success. */
// LLVMBool LLVMParseBitcode2(LLVMMemoryBufferRef MemBuf,
//                            LLVMModuleRef *OutModule);
//
// /* This is deprecated. Use LLVMParseBitcodeInContext2. */
// LLVMBool LLVMParseBitcodeInContext(LLVMContextRef ContextRef,
//                                    LLVMMemoryBufferRef MemBuf,
//                                    LLVMModuleRef *OutModule, char **OutMessage);
//
// LLVMBool LLVMParseBitcodeInContext2(LLVMContextRef ContextRef,
//                                     LLVMMemoryBufferRef MemBuf,
//                                     LLVMModuleRef *OutModule);
//
// /** Reads a module from the specified path, returning via the OutMP parameter
//     a module provider which performs lazy deserialization. Returns 0 on success.
//     Optionally returns a human-readable error message via OutMessage.
//     This is deprecated. Use LLVMGetBitcodeModuleInContext2. */
// LLVMBool LLVMGetBitcodeModuleInContext(LLVMContextRef ContextRef,
//                                        LLVMMemoryBufferRef MemBuf,
//                                        LLVMModuleRef *OutM, char **OutMessage);
//
// /** Reads a module from the given memory buffer, returning via the OutMP
//  * parameter a module provider which performs lazy deserialization.
//  *
//  * Returns 0 on success.
//  *
//  * Takes ownership of \p MemBuf if (and only if) the module was read
//  * successfully. */
// LLVMBool LLVMGetBitcodeModuleInContext2(LLVMContextRef ContextRef,
//                                         LLVMMemoryBufferRef MemBuf,
//                                         LLVMModuleRef *OutM);
//
// /* This is deprecated. Use LLVMGetBitcodeModule2. */
// LLVMBool LLVMGetBitcodeModule(LLVMMemoryBufferRef MemBuf, LLVMModuleRef *OutM,
//                               char **OutMessage);
//
// LLVMBool LLVMGetBitcodeModule2(LLVMMemoryBufferRef MemBuf, LLVMModuleRef *OutM);


// =======================================================
// BitWriter.h
// =======================================================

// /** Writes a module to the specified path. Returns 0 on success. */
// int LLVMWriteBitcodeToFile(LLVMModuleRef M, const char *Path);
//
// /** Writes a module to an open file descriptor. Returns 0 on success. */
// int LLVMWriteBitcodeToFD(LLVMModuleRef M, int FD, int ShouldClose,
//                          int Unbuffered);
//
// /** Deprecated for LLVMWriteBitcodeToFD. Writes a module to an open file
//     descriptor. Returns 0 on success. Closes the Handle. */
// int LLVMWriteBitcodeToFileHandle(LLVMModuleRef M, int Handle);
//
// /** Writes a module to a new memory buffer and returns it. */
// LLVMMemoryBufferRef LLVMWriteBitcodeToMemoryBuffer(LLVMModuleRef M);

// =======================================================
// Object.h
// =======================================================

// /**
//  * Create a binary file from the given memory buffer.
//  *
//  * The exact type of the binary file will be inferred automatically, and the
//  * appropriate implementation selected.  The context may be NULL except if
//  * the resulting file is an LLVM IR file.
//  *
//  * The memory buffer is not consumed by this function.  It is the responsibilty
//  * of the caller to free it with \c LLVMDisposeMemoryBuffer.
//  *
//  * If NULL is returned, the \p ErrorMessage parameter is populated with the
//  * error's description.  It is then the caller's responsibility to free this
//  * message by calling \c LLVMDisposeMessage.
//  *
//  * @see llvm::object::createBinary
//  */
// LLVMBinaryRef LLVMCreateBinary(LLVMMemoryBufferRef MemBuf,
//                                LLVMContextRef Context,
//                                char **ErrorMessage);
//
// /**
//  * Dispose of a binary file.
//  *
//  * The binary file does not own its backing buffer.  It is the responsibilty
//  * of the caller to free it with \c LLVMDisposeMemoryBuffer.
//  */
// void LLVMDisposeBinary(LLVMBinaryRef BR);
//
// /**
//  * Retrieves a copy of the memory buffer associated with this object file.
//  *
//  * The returned buffer is merely a shallow copy and does not own the actual
//  * backing buffer of the binary. Nevertheless, it is the responsibility of the
//  * caller to free it with \c LLVMDisposeMemoryBuffer.
//  *
//  * @see llvm::object::getMemoryBufferRef
//  */
// LLVMMemoryBufferRef LLVMBinaryCopyMemoryBuffer(LLVMBinaryRef BR);
//
// /**
//  * Retrieve the specific type of a binary.
//  *
//  * @see llvm::object::Binary::getType
//  */
// LLVMBinaryType LLVMBinaryGetType(LLVMBinaryRef BR);
//
// /*
//  * For a Mach-O universal binary file, retrieves the object file corresponding
//  * to the given architecture if it is present as a slice.
//  *
//  * If NULL is returned, the \p ErrorMessage parameter is populated with the
//  * error's description.  It is then the caller's responsibility to free this
//  * message by calling \c LLVMDisposeMessage.
//  *
//  * It is the responsiblity of the caller to free the returned object file by
//  * calling \c LLVMDisposeBinary.
//  */
// LLVMBinaryRef LLVMMachOUniversalBinaryCopyObjectForArch(LLVMBinaryRef BR,
//                                                         const char *Arch,
//                                                         size_t ArchLen,
//                                                         char **ErrorMessage);
//
// /**
//  * Retrieve a copy of the section iterator for this object file.
//  *
//  * If there are no sections, the result is NULL.
//  *
//  * The returned iterator is merely a shallow copy. Nevertheless, it is
//  * the responsibility of the caller to free it with
//  * \c LLVMDisposeSectionIterator.
//  *
//  * @see llvm::object::sections()
//  */
// LLVMSectionIteratorRef LLVMObjectFileCopySectionIterator(LLVMBinaryRef BR);
//
// /**
//  * Returns whether the given section iterator is at the end.
//  *
//  * @see llvm::object::section_end
//  */
// LLVMBool LLVMObjectFileIsSectionIteratorAtEnd(LLVMBinaryRef BR,
//                                               LLVMSectionIteratorRef SI);
//
// /**
//  * Retrieve a copy of the symbol iterator for this object file.
//  *
//  * If there are no symbols, the result is NULL.
//  *
//  * The returned iterator is merely a shallow copy. Nevertheless, it is
//  * the responsibility of the caller to free it with
//  * \c LLVMDisposeSymbolIterator.
//  *
//  * @see llvm::object::symbols()
//  */
// LLVMSymbolIteratorRef LLVMObjectFileCopySymbolIterator(LLVMBinaryRef BR);
//
// /**
//  * Returns whether the given symbol iterator is at the end.
//  *
//  * @see llvm::object::symbol_end
//  */
// LLVMBool LLVMObjectFileIsSymbolIteratorAtEnd(LLVMBinaryRef BR,
//                                              LLVMSymbolIteratorRef SI);
//
// void LLVMDisposeSectionIterator(LLVMSectionIteratorRef SI);
//
// void LLVMMoveToNextSection(LLVMSectionIteratorRef SI);
// void LLVMMoveToContainingSection(LLVMSectionIteratorRef Sect,
//                                  LLVMSymbolIteratorRef Sym);
//
// // ObjectFile Symbol iterators
// void LLVMDisposeSymbolIterator(LLVMSymbolIteratorRef SI);
// void LLVMMoveToNextSymbol(LLVMSymbolIteratorRef SI);
//
// // SectionRef accessors
// const char *LLVMGetSectionName(LLVMSectionIteratorRef SI);
// uint64_t LLVMGetSectionSize(LLVMSectionIteratorRef SI);
// const char *LLVMGetSectionContents(LLVMSectionIteratorRef SI);
// uint64_t LLVMGetSectionAddress(LLVMSectionIteratorRef SI);
// LLVMBool LLVMGetSectionContainsSymbol(LLVMSectionIteratorRef SI,
//                                  LLVMSymbolIteratorRef Sym);
//
// // Section Relocation iterators
// LLVMRelocationIteratorRef LLVMGetRelocations(LLVMSectionIteratorRef Section);
// void LLVMDisposeRelocationIterator(LLVMRelocationIteratorRef RI);
// LLVMBool LLVMIsRelocationIteratorAtEnd(LLVMSectionIteratorRef Section,
//                                        LLVMRelocationIteratorRef RI);
// void LLVMMoveToNextRelocation(LLVMRelocationIteratorRef RI);
//
//
// // SymbolRef accessors
// const char *LLVMGetSymbolName(LLVMSymbolIteratorRef SI);
// uint64_t LLVMGetSymbolAddress(LLVMSymbolIteratorRef SI);
// uint64_t LLVMGetSymbolSize(LLVMSymbolIteratorRef SI);
//
// // RelocationRef accessors
// uint64_t LLVMGetRelocationOffset(LLVMRelocationIteratorRef RI);
// LLVMSymbolIteratorRef LLVMGetRelocationSymbol(LLVMRelocationIteratorRef RI);
// uint64_t LLVMGetRelocationType(LLVMRelocationIteratorRef RI);
// // NOTE: Caller takes ownership of returned string of the two
// // following functions.
// const char *LLVMGetRelocationTypeName(LLVMRelocationIteratorRef RI);
// const char *LLVMGetRelocationValueString(LLVMRelocationIteratorRef RI);
//
// /** Deprecated: Use LLVMBinaryRef instead. */
// typedef struct LLVMOpaqueObjectFile *LLVMObjectFileRef;
//
// /** Deprecated: Use LLVMCreateBinary instead. */
// LLVMObjectFileRef LLVMCreateObjectFile(LLVMMemoryBufferRef MemBuf);
//
// /** Deprecated: Use LLVMDisposeBinary instead. */
// void LLVMDisposeObjectFile(LLVMObjectFileRef ObjectFile);
//
// /** Deprecated: Use LLVMObjectFileCopySectionIterator instead. */
// LLVMSectionIteratorRef LLVMGetSections(LLVMObjectFileRef ObjectFile);
//
// /** Deprecated: Use LLVMObjectFileIsSectionIteratorAtEnd instead. */
// LLVMBool LLVMIsSectionIteratorAtEnd(LLVMObjectFileRef ObjectFile,
//                                     LLVMSectionIteratorRef SI);
//
// /** Deprecated: Use LLVMObjectFileCopySymbolIterator instead. */
// LLVMSymbolIteratorRef LLVMGetSymbols(LLVMObjectFileRef ObjectFile);
//
// /** Deprecated: Use LLVMObjectFileIsSymbolIteratorAtEnd instead. */
// LLVMBool LLVMIsSymbolIteratorAtEnd(LLVMObjectFileRef ObjectFile,
//                                    LLVMSymbolIteratorRef SI);

// =======================================================
// ExecutionEngine.h
// =======================================================

// void LLVMLinkInMCJIT(void);
// void LLVMLinkInInterpreter(void);
//
// struct LLVMMCJITCompilerOptions {
//   unsigned OptLevel;
//   LLVMCodeModel CodeModel;
//   LLVMBool NoFramePointerElim;
//   LLVMBool EnableFastISel;
//   LLVMMCJITMemoryManagerRef MCJMM;
// };
//
// /*===-- Operations on generic values --------------------------------------===*/
//
// LLVMGenericValueRef LLVMCreateGenericValueOfInt(LLVMTypeRef Ty,
//                                                 unsigned long long N,
//                                                 LLVMBool IsSigned);
//
// LLVMGenericValueRef LLVMCreateGenericValueOfPointer(void *P);
//
// LLVMGenericValueRef LLVMCreateGenericValueOfFloat(LLVMTypeRef Ty, double N);
//
// unsigned LLVMGenericValueIntWidth(LLVMGenericValueRef GenValRef);
//
// unsigned long long LLVMGenericValueToInt(LLVMGenericValueRef GenVal,
//                                          LLVMBool IsSigned);
//
// void *LLVMGenericValueToPointer(LLVMGenericValueRef GenVal);
//
// double LLVMGenericValueToFloat(LLVMTypeRef TyRef, LLVMGenericValueRef GenVal);
//
// void LLVMDisposeGenericValue(LLVMGenericValueRef GenVal);
//
// /*===-- Operations on execution engines -----------------------------------===*/
//
// LLVMBool LLVMCreateExecutionEngineForModule(LLVMExecutionEngineRef *OutEE,
//                                             LLVMModuleRef M,
//                                             char **OutError);
//
// LLVMBool LLVMCreateInterpreterForModule(LLVMExecutionEngineRef *OutInterp,
//                                         LLVMModuleRef M,
//                                         char **OutError);
//
// LLVMBool LLVMCreateJITCompilerForModule(LLVMExecutionEngineRef *OutJIT,
//                                         LLVMModuleRef M,
//                                         unsigned OptLevel,
//                                         char **OutError);
//
// void LLVMInitializeMCJITCompilerOptions(
//   struct LLVMMCJITCompilerOptions *Options, size_t SizeOfOptions);
//
// /**
//  * Create an MCJIT execution engine for a module, with the given options. It is
//  * the responsibility of the caller to ensure that all fields in Options up to
//  * the given SizeOfOptions are initialized. It is correct to pass a smaller
//  * value of SizeOfOptions that omits some fields. The canonical way of using
//  * this is:
//  *
//  * LLVMMCJITCompilerOptions options;
//  * LLVMInitializeMCJITCompilerOptions(&options, sizeof(options));
//  * ... fill in those options you care about
//  * LLVMCreateMCJITCompilerForModule(&jit, mod, &options, sizeof(options),
//  *                                  &error);
//  *
//  * Note that this is also correct, though possibly suboptimal:
//  *
//  * LLVMCreateMCJITCompilerForModule(&jit, mod, 0, 0, &error);
//  */
// LLVMBool LLVMCreateMCJITCompilerForModule(
//   LLVMExecutionEngineRef *OutJIT, LLVMModuleRef M,
//   struct LLVMMCJITCompilerOptions *Options, size_t SizeOfOptions,
//   char **OutError);
//
// void LLVMDisposeExecutionEngine(LLVMExecutionEngineRef EE);
//
// void LLVMRunStaticConstructors(LLVMExecutionEngineRef EE);
//
// void LLVMRunStaticDestructors(LLVMExecutionEngineRef EE);
//
// int LLVMRunFunctionAsMain(LLVMExecutionEngineRef EE, LLVMValueRef F,
//                           unsigned ArgC, const char * const *ArgV,
//                           const char * const *EnvP);
//
// LLVMGenericValueRef LLVMRunFunction(LLVMExecutionEngineRef EE, LLVMValueRef F,
//                                     unsigned NumArgs,
//                                     LLVMGenericValueRef *Args);
//
// void LLVMFreeMachineCodeForFunction(LLVMExecutionEngineRef EE, LLVMValueRef F);
//
// void LLVMAddModule(LLVMExecutionEngineRef EE, LLVMModuleRef M);
//
// LLVMBool LLVMRemoveModule(LLVMExecutionEngineRef EE, LLVMModuleRef M,
//                           LLVMModuleRef *OutMod, char **OutError);
//
// LLVMBool LLVMFindFunction(LLVMExecutionEngineRef EE, const char *Name,
//                           LLVMValueRef *OutFn);
//
// void *LLVMRecompileAndRelinkFunction(LLVMExecutionEngineRef EE,
//                                      LLVMValueRef Fn);
//
// LLVMTargetDataRef LLVMGetExecutionEngineTargetData(LLVMExecutionEngineRef EE);
// LLVMTargetMachineRef
// LLVMGetExecutionEngineTargetMachine(LLVMExecutionEngineRef EE);
//
// void LLVMAddGlobalMapping(LLVMExecutionEngineRef EE, LLVMValueRef Global,
//                           void* Addr);
//
// void *LLVMGetPointerToGlobal(LLVMExecutionEngineRef EE, LLVMValueRef Global);
//
// uint64_t LLVMGetGlobalValueAddress(LLVMExecutionEngineRef EE, const char *Name);
//
// uint64_t LLVMGetFunctionAddress(LLVMExecutionEngineRef EE, const char *Name);
//
// /// Returns true on error, false on success. If true is returned then the error
// /// message is copied to OutStr and cleared in the ExecutionEngine instance.
// LLVMBool LLVMExecutionEngineGetErrMsg(LLVMExecutionEngineRef EE,
//                                       char **OutError);
//
// /*===-- Operations on memory managers -------------------------------------===*/
//
// typedef uint8_t *(*LLVMMemoryManagerAllocateCodeSectionCallback)(
//   void *Opaque, uintptr_t Size, unsigned Alignment, unsigned SectionID,
//   const char *SectionName);
// typedef uint8_t *(*LLVMMemoryManagerAllocateDataSectionCallback)(
//   void *Opaque, uintptr_t Size, unsigned Alignment, unsigned SectionID,
//   const char *SectionName, LLVMBool IsReadOnly);
// typedef LLVMBool (*LLVMMemoryManagerFinalizeMemoryCallback)(
//   void *Opaque, char **ErrMsg);
// typedef void (*LLVMMemoryManagerDestroyCallback)(void *Opaque);
//
// /**
//  * Create a simple custom MCJIT memory manager. This memory manager can
//  * intercept allocations in a module-oblivious way. This will return NULL
//  * if any of the passed functions are NULL.
//  *
//  * @param Opaque An opaque client object to pass back to the callbacks.
//  * @param AllocateCodeSection Allocate a block of memory for executable code.
//  * @param AllocateDataSection Allocate a block of memory for data.
//  * @param FinalizeMemory Set page permissions and flush cache. Return 0 on
//  *   success, 1 on error.
//  */
// LLVMMCJITMemoryManagerRef LLVMCreateSimpleMCJITMemoryManager(
//   void *Opaque,
//   LLVMMemoryManagerAllocateCodeSectionCallback AllocateCodeSection,
//   LLVMMemoryManagerAllocateDataSectionCallback AllocateDataSection,
//   LLVMMemoryManagerFinalizeMemoryCallback FinalizeMemory,
//   LLVMMemoryManagerDestroyCallback Destroy);
//
// void LLVMDisposeMCJITMemoryManager(LLVMMCJITMemoryManagerRef MM);
//
// /*===-- JIT Event Listener functions -------------------------------------===*/
//
// LLVMJITEventListenerRef LLVMCreateGDBRegistrationListener(void);
// LLVMJITEventListenerRef LLVMCreateIntelJITEventListener(void);
// LLVMJITEventListenerRef LLVMCreateOProfileJITEventListener(void);
// LLVMJITEventListenerRef LLVMCreatePerfJITEventListener(void);

// =======================================================
// DebugInfo.h
// =======================================================

// /**
//  * The current debug metadata version number.
//  */
// unsigned LLVMDebugMetadataVersion(void);
//
// /**
//  * The version of debug metadata that's present in the provided \c Module.
//  */
// unsigned LLVMGetModuleDebugMetadataVersion(LLVMModuleRef Module);
//
// /**
//  * Strip debug info in the module if it exists.
//  * To do this, we remove all calls to the debugger intrinsics and any named
//  * metadata for debugging. We also remove debug locations for instructions.
//  * Return true if module is modified.
//  */
// LLVMBool LLVMStripModuleDebugInfo(LLVMModuleRef Module);
//
// /**
//  * Construct a builder for a module, and do not allow for unresolved nodes
//  * attached to the module.
//  */
// LLVMDIBuilderRef LLVMCreateDIBuilderDisallowUnresolved(LLVMModuleRef M);
//
// /**
//  * Construct a builder for a module and collect unresolved nodes attached
//  * to the module in order to resolve cycles during a call to
//  * \c LLVMDIBuilderFinalize.
//  */
// LLVMDIBuilderRef LLVMCreateDIBuilder(LLVMModuleRef M);
//
// /**
//  * Deallocates the \c DIBuilder and everything it owns.
//  * @note You must call \c LLVMDIBuilderFinalize before this
//  */
// void LLVMDisposeDIBuilder(LLVMDIBuilderRef Builder);
//
// /**
//  * Construct any deferred debug info descriptors.
//  */
// void LLVMDIBuilderFinalize(LLVMDIBuilderRef Builder);
//
// /**
//  * Finalize a specific subprogram.
//  * No new variables may be added to this subprogram afterwards.
//  */
// void LLVMDIBuilderFinalizeSubprogram(LLVMDIBuilderRef Builder,
//                                      LLVMMetadataRef Subprogram);
//
// /**
//  * A CompileUnit provides an anchor for all debugging
//  * information generated during this instance of compilation.
//  * \param Lang          Source programming language, eg.
//  *                      \c LLVMDWARFSourceLanguageC99
//  * \param FileRef       File info.
//  * \param Producer      Identify the producer of debugging information
//  *                      and code.  Usually this is a compiler
//  *                      version string.
//  * \param ProducerLen   The length of the C string passed to \c Producer.
//  * \param isOptimized   A boolean flag which indicates whether optimization
//  *                      is enabled or not.
//  * \param Flags         This string lists command line options. This
//  *                      string is directly embedded in debug info
//  *                      output which may be used by a tool
//  *                      analyzing generated debugging information.
//  * \param FlagsLen      The length of the C string passed to \c Flags.
//  * \param RuntimeVer    This indicates runtime version for languages like
//  *                      Objective-C.
//  * \param SplitName     The name of the file that we'll split debug info
//  *                      out into.
//  * \param SplitNameLen  The length of the C string passed to \c SplitName.
//  * \param Kind          The kind of debug information to generate.
//  * \param DWOId         The DWOId if this is a split skeleton compile unit.
//  * \param SplitDebugInlining    Whether to emit inline debug info.
//  * \param DebugInfoForProfiling Whether to emit extra debug info for
//  *                              profile collection.
//  * \param SysRoot         The Clang system root (value of -isysroot).
//  * \param SysRootLen      The length of the C string passed to \c SysRoot.
//  * \param SDK           The SDK. On Darwin, the last component of the sysroot.
//  * \param SDKLen        The length of the C string passed to \c SDK.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateCompileUnit(
//     LLVMDIBuilderRef Builder, LLVMDWARFSourceLanguage Lang,
//     LLVMMetadataRef FileRef, const char *Producer, size_t ProducerLen,
//     LLVMBool isOptimized, const char *Flags, size_t FlagsLen,
//     unsigned RuntimeVer, const char *SplitName, size_t SplitNameLen,
//     LLVMDWARFEmissionKind Kind, unsigned DWOId, LLVMBool SplitDebugInlining,
//     LLVMBool DebugInfoForProfiling, const char *SysRoot, size_t SysRootLen,
//     const char *SDK, size_t SDKLen);
//
// /**
//  * Create a file descriptor to hold debugging information for a file.
//  * \param Builder      The \c DIBuilder.
//  * \param Filename     File name.
//  * \param FilenameLen  The length of the C string passed to \c Filename.
//  * \param Directory    Directory.
//  * \param DirectoryLen The length of the C string passed to \c Directory.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateFile(LLVMDIBuilderRef Builder, const char *Filename,
//                         size_t FilenameLen, const char *Directory,
//                         size_t DirectoryLen);
//
// /**
//  * Creates a new descriptor for a module with the specified parent scope.
//  * \param Builder         The \c DIBuilder.
//  * \param ParentScope     The parent scope containing this module declaration.
//  * \param Name            Module name.
//  * \param NameLen         The length of the C string passed to \c Name.
//  * \param ConfigMacros    A space-separated shell-quoted list of -D macro
//                           definitions as they would appear on a command line.
//  * \param ConfigMacrosLen The length of the C string passed to \c ConfigMacros.
//  * \param IncludePath     The path to the module map file.
//  * \param IncludePathLen  The length of the C string passed to \c IncludePath.
//  * \param APINotesFile    The path to an API notes file for the module.
//  * \param APINotesFileLen The length of the C string passed to \c APINotestFile.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateModule(LLVMDIBuilderRef Builder, LLVMMetadataRef ParentScope,
//                           const char *Name, size_t NameLen,
//                           const char *ConfigMacros, size_t ConfigMacrosLen,
//                           const char *IncludePath, size_t IncludePathLen,
//                           const char *APINotesFile, size_t APINotesFileLen);
//
// /**
//  * Creates a new descriptor for a namespace with the specified parent scope.
//  * \param Builder          The \c DIBuilder.
//  * \param ParentScope      The parent scope containing this module declaration.
//  * \param Name             NameSpace name.
//  * \param NameLen          The length of the C string passed to \c Name.
//  * \param ExportSymbols    Whether or not the namespace exports symbols, e.g.
//  *                         this is true of C++ inline namespaces.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateNameSpace(LLVMDIBuilderRef Builder,
//                              LLVMMetadataRef ParentScope,
//                              const char *Name, size_t NameLen,
//                              LLVMBool ExportSymbols);
//
// /**
//  * Create a new descriptor for the specified subprogram.
//  * \param Builder         The \c DIBuilder.
//  * \param Scope           Function scope.
//  * \param Name            Function name.
//  * \param NameLen         Length of enumeration name.
//  * \param LinkageName     Mangled function name.
//  * \param LinkageNameLen  Length of linkage name.
//  * \param File            File where this variable is defined.
//  * \param LineNo          Line number.
//  * \param Ty              Function type.
//  * \param IsLocalToUnit   True if this function is not externally visible.
//  * \param IsDefinition    True if this is a function definition.
//  * \param ScopeLine       Set to the beginning of the scope this starts
//  * \param Flags           E.g.: \c LLVMDIFlagLValueReference. These flags are
//  *                        used to emit dwarf attributes.
//  * \param IsOptimized     True if optimization is ON.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateFunction(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, const char *LinkageName, size_t LinkageNameLen,
//     LLVMMetadataRef File, unsigned LineNo, LLVMMetadataRef Ty,
//     LLVMBool IsLocalToUnit, LLVMBool IsDefinition,
//     unsigned ScopeLine, LLVMDIFlags Flags, LLVMBool IsOptimized);
//
// /**
//  * Create a descriptor for a lexical block with the specified parent context.
//  * \param Builder      The \c DIBuilder.
//  * \param Scope        Parent lexical block.
//  * \param File         Source file.
//  * \param Line         The line in the source file.
//  * \param Column       The column in the source file.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateLexicalBlock(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope,
//     LLVMMetadataRef File, unsigned Line, unsigned Column);
//
// /**
//  * Create a descriptor for a lexical block with a new file attached.
//  * \param Builder        The \c DIBuilder.
//  * \param Scope          Lexical block.
//  * \param File           Source file.
//  * \param Discriminator  DWARF path discriminator value.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateLexicalBlockFile(LLVMDIBuilderRef Builder,
//                                     LLVMMetadataRef Scope,
//                                     LLVMMetadataRef File,
//                                     unsigned Discriminator);
//
// /**
//  * Create a descriptor for an imported namespace. Suitable for e.g. C++
//  * using declarations.
//  * \param Builder    The \c DIBuilder.
//  * \param Scope      The scope this module is imported into
//  * \param File       File where the declaration is located.
//  * \param Line       Line number of the declaration.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateImportedModuleFromNamespace(LLVMDIBuilderRef Builder,
//                                                LLVMMetadataRef Scope,
//                                                LLVMMetadataRef NS,
//                                                LLVMMetadataRef File,
//                                                unsigned Line);
//
// /**
//  * Create a descriptor for an imported module that aliases another
//  * imported entity descriptor.
//  * \param Builder        The \c DIBuilder.
//  * \param Scope          The scope this module is imported into
//  * \param ImportedEntity Previous imported entity to alias.
//  * \param File           File where the declaration is located.
//  * \param Line           Line number of the declaration.
//  * \param Elements       Renamed elements.
//  * \param NumElements    Number of renamed elements.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateImportedModuleFromAlias(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope,
//     LLVMMetadataRef ImportedEntity, LLVMMetadataRef File, unsigned Line,
//     LLVMMetadataRef *Elements, unsigned NumElements);
//
// /**
//  * Create a descriptor for an imported module.
//  * \param Builder        The \c DIBuilder.
//  * \param Scope          The scope this module is imported into
//  * \param M              The module being imported here
//  * \param File           File where the declaration is located.
//  * \param Line           Line number of the declaration.
//  * \param Elements       Renamed elements.
//  * \param NumElements    Number of renamed elements.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateImportedModuleFromModule(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, LLVMMetadataRef M,
//     LLVMMetadataRef File, unsigned Line, LLVMMetadataRef *Elements,
//     unsigned NumElements);
//
// /**
//  * Create a descriptor for an imported function, type, or variable.  Suitable
//  * for e.g. FORTRAN-style USE declarations.
//  * \param Builder        The DIBuilder.
//  * \param Scope          The scope this module is imported into.
//  * \param Decl           The declaration (or definition) of a function, type,
//                          or variable.
//  * \param File           File where the declaration is located.
//  * \param Line           Line number of the declaration.
//  * \param Name           A name that uniquely identifies this imported
//  declaration.
//  * \param NameLen        The length of the C string passed to \c Name.
//  * \param Elements       Renamed elements.
//  * \param NumElements    Number of renamed elements.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateImportedDeclaration(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, LLVMMetadataRef Decl,
//     LLVMMetadataRef File, unsigned Line, const char *Name, size_t NameLen,
//     LLVMMetadataRef *Elements, unsigned NumElements);
//
// /**
//  * Creates a new DebugLocation that describes a source location.
//  * \param Line The line in the source file.
//  * \param Column The column in the source file.
//  * \param Scope The scope in which the location resides.
//  * \param InlinedAt The scope where this location was inlined, if at all.
//  *                  (optional).
//  * \note If the item to which this location is attached cannot be
//  *       attributed to a source line, pass 0 for the line and column.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateDebugLocation(LLVMContextRef Ctx, unsigned Line,
//                                  unsigned Column, LLVMMetadataRef Scope,
//                                  LLVMMetadataRef InlinedAt);
//
// /**
//  * Get the line number of this debug location.
//  * \param Location     The debug location.
//  *
//  * @see DILocation::getLine()
//  */
// unsigned LLVMDILocationGetLine(LLVMMetadataRef Location);
//
// /**
//  * Get the column number of this debug location.
//  * \param Location     The debug location.
//  *
//  * @see DILocation::getColumn()
//  */
// unsigned LLVMDILocationGetColumn(LLVMMetadataRef Location);
//
// /**
//  * Get the local scope associated with this debug location.
//  * \param Location     The debug location.
//  *
//  * @see DILocation::getScope()
//  */
// LLVMMetadataRef LLVMDILocationGetScope(LLVMMetadataRef Location);
//
// /**
//  * Get the "inline at" location associated with this debug location.
//  * \param Location     The debug location.
//  *
//  * @see DILocation::getInlinedAt()
//  */
// LLVMMetadataRef LLVMDILocationGetInlinedAt(LLVMMetadataRef Location);
//
// /**
//  * Get the metadata of the file associated with a given scope.
//  * \param Scope     The scope object.
//  *
//  * @see DIScope::getFile()
//  */
// LLVMMetadataRef LLVMDIScopeGetFile(LLVMMetadataRef Scope);
//
// /**
//  * Get the directory of a given file.
//  * \param File     The file object.
//  * \param Len      The length of the returned string.
//  *
//  * @see DIFile::getDirectory()
//  */
// const char *LLVMDIFileGetDirectory(LLVMMetadataRef File, unsigned *Len);
//
// /**
//  * Get the name of a given file.
//  * \param File     The file object.
//  * \param Len      The length of the returned string.
//  *
//  * @see DIFile::getFilename()
//  */
// const char *LLVMDIFileGetFilename(LLVMMetadataRef File, unsigned *Len);
//
// /**
//  * Get the source of a given file.
//  * \param File     The file object.
//  * \param Len      The length of the returned string.
//  *
//  * @see DIFile::getSource()
//  */
// const char *LLVMDIFileGetSource(LLVMMetadataRef File, unsigned *Len);
//
// /**
//  * Create a type array.
//  * \param Builder        The DIBuilder.
//  * \param Data           The type elements.
//  * \param NumElements    Number of type elements.
//  */
// LLVMMetadataRef LLVMDIBuilderGetOrCreateTypeArray(LLVMDIBuilderRef Builder,
//                                                   LLVMMetadataRef *Data,
//                                                   size_t NumElements);
//
// /**
//  * Create subroutine type.
//  * \param Builder        The DIBuilder.
//  * \param File            The file in which the subroutine resides.
//  * \param ParameterTypes  An array of subroutine parameter types. This
//  *                        includes return type at 0th index.
//  * \param NumParameterTypes The number of parameter types in \c ParameterTypes
//  * \param Flags           E.g.: \c LLVMDIFlagLValueReference.
//  *                        These flags are used to emit dwarf attributes.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateSubroutineType(LLVMDIBuilderRef Builder,
//                                   LLVMMetadataRef File,
//                                   LLVMMetadataRef *ParameterTypes,
//                                   unsigned NumParameterTypes,
//                                   LLVMDIFlags Flags);
//
// /**
//  * Create debugging information entry for a macro.
//  * @param Builder         The DIBuilder.
//  * @param ParentMacroFile Macro parent (could be NULL).
//  * @param Line            Source line number where the macro is defined.
//  * @param RecordType      DW_MACINFO_define or DW_MACINFO_undef.
//  * @param Name            Macro name.
//  * @param NameLen         Macro name length.
//  * @param Value           Macro value.
//  * @param ValueLen        Macro value length.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateMacro(LLVMDIBuilderRef Builder,
//                                          LLVMMetadataRef ParentMacroFile,
//                                          unsigned Line,
//                                          LLVMDWARFMacinfoRecordType RecordType,
//                                          const char *Name, size_t NameLen,
//                                          const char *Value, size_t ValueLen);
//
// /**
//  * Create debugging information temporary entry for a macro file.
//  * List of macro node direct children will be calculated by DIBuilder,
//  * using the \p ParentMacroFile relationship.
//  * @param Builder         The DIBuilder.
//  * @param ParentMacroFile Macro parent (could be NULL).
//  * @param Line            Source line number where the macro file is included.
//  * @param File            File descriptor containing the name of the macro file.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateTempMacroFile(LLVMDIBuilderRef Builder,
//                                  LLVMMetadataRef ParentMacroFile, unsigned Line,
//                                  LLVMMetadataRef File);
//
// /**
//  * Create debugging information entry for an enumerator.
//  * @param Builder        The DIBuilder.
//  * @param Name           Enumerator name.
//  * @param NameLen        Length of enumerator name.
//  * @param Value          Enumerator value.
//  * @param IsUnsigned     True if the value is unsigned.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateEnumerator(LLVMDIBuilderRef Builder,
//                                               const char *Name, size_t NameLen,
//                                               int64_t Value,
//                                               LLVMBool IsUnsigned);
//
// /**
//  * Create debugging information entry for an enumeration.
//  * \param Builder        The DIBuilder.
//  * \param Scope          Scope in which this enumeration is defined.
//  * \param Name           Enumeration name.
//  * \param NameLen        Length of enumeration name.
//  * \param File           File where this member is defined.
//  * \param LineNumber     Line number.
//  * \param SizeInBits     Member size.
//  * \param AlignInBits    Member alignment.
//  * \param Elements       Enumeration elements.
//  * \param NumElements    Number of enumeration elements.
//  * \param ClassTy        Underlying type of a C++11/ObjC fixed enum.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateEnumerationType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNumber,
//     uint64_t SizeInBits, uint32_t AlignInBits, LLVMMetadataRef *Elements,
//     unsigned NumElements, LLVMMetadataRef ClassTy);
//
// /**
//  * Create debugging information entry for a union.
//  * \param Builder      The DIBuilder.
//  * \param Scope        Scope in which this union is defined.
//  * \param Name         Union name.
//  * \param NameLen      Length of union name.
//  * \param File         File where this member is defined.
//  * \param LineNumber   Line number.
//  * \param SizeInBits   Member size.
//  * \param AlignInBits  Member alignment.
//  * \param Flags        Flags to encode member attribute, e.g. private
//  * \param Elements     Union elements.
//  * \param NumElements  Number of union elements.
//  * \param RunTimeLang  Optional parameter, Objective-C runtime version.
//  * \param UniqueId     A unique identifier for the union.
//  * \param UniqueIdLen  Length of unique identifier.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateUnionType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNumber,
//     uint64_t SizeInBits, uint32_t AlignInBits, LLVMDIFlags Flags,
//     LLVMMetadataRef *Elements, unsigned NumElements, unsigned RunTimeLang,
//     const char *UniqueId, size_t UniqueIdLen);
//
//
// /**
//  * Create debugging information entry for an array.
//  * \param Builder      The DIBuilder.
//  * \param Size         Array size.
//  * \param AlignInBits  Alignment.
//  * \param Ty           Element type.
//  * \param Subscripts   Subscripts.
//  * \param NumSubscripts Number of subscripts.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateArrayType(LLVMDIBuilderRef Builder, uint64_t Size,
//                              uint32_t AlignInBits, LLVMMetadataRef Ty,
//                              LLVMMetadataRef *Subscripts,
//                              unsigned NumSubscripts);
//
// /**
//  * Create debugging information entry for a vector type.
//  * \param Builder      The DIBuilder.
//  * \param Size         Vector size.
//  * \param AlignInBits  Alignment.
//  * \param Ty           Element type.
//  * \param Subscripts   Subscripts.
//  * \param NumSubscripts Number of subscripts.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateVectorType(LLVMDIBuilderRef Builder, uint64_t Size,
//                               uint32_t AlignInBits, LLVMMetadataRef Ty,
//                               LLVMMetadataRef *Subscripts,
//                               unsigned NumSubscripts);
//
// /**
//  * Create a DWARF unspecified type.
//  * \param Builder   The DIBuilder.
//  * \param Name      The unspecified type's name.
//  * \param NameLen   Length of type name.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateUnspecifiedType(LLVMDIBuilderRef Builder, const char *Name,
//                                    size_t NameLen);
//
// /**
//  * Create debugging information entry for a basic
//  * type.
//  * \param Builder     The DIBuilder.
//  * \param Name        Type name.
//  * \param NameLen     Length of type name.
//  * \param SizeInBits  Size of the type.
//  * \param Encoding    DWARF encoding code, e.g. \c LLVMDWARFTypeEncoding_float.
//  * \param Flags       Flags to encode optional attribute like endianity
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateBasicType(LLVMDIBuilderRef Builder, const char *Name,
//                              size_t NameLen, uint64_t SizeInBits,
//                              LLVMDWARFTypeEncoding Encoding,
//                              LLVMDIFlags Flags);
//
// /**
//  * Create debugging information entry for a pointer.
//  * \param Builder     The DIBuilder.
//  * \param PointeeTy         Type pointed by this pointer.
//  * \param SizeInBits        Size.
//  * \param AlignInBits       Alignment. (optional, pass 0 to ignore)
//  * \param AddressSpace      DWARF address space. (optional, pass 0 to ignore)
//  * \param Name              Pointer type name. (optional)
//  * \param NameLen           Length of pointer type name. (optional)
//  */
// LLVMMetadataRef LLVMDIBuilderCreatePointerType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef PointeeTy,
//     uint64_t SizeInBits, uint32_t AlignInBits, unsigned AddressSpace,
//     const char *Name, size_t NameLen);
//
// /**
//  * Create debugging information entry for a struct.
//  * \param Builder     The DIBuilder.
//  * \param Scope        Scope in which this struct is defined.
//  * \param Name         Struct name.
//  * \param NameLen      Struct name length.
//  * \param File         File where this member is defined.
//  * \param LineNumber   Line number.
//  * \param SizeInBits   Member size.
//  * \param AlignInBits  Member alignment.
//  * \param Flags        Flags to encode member attribute, e.g. private
//  * \param Elements     Struct elements.
//  * \param NumElements  Number of struct elements.
//  * \param RunTimeLang  Optional parameter, Objective-C runtime version.
//  * \param VTableHolder The object containing the vtable for the struct.
//  * \param UniqueId     A unique identifier for the struct.
//  * \param UniqueIdLen  Length of the unique identifier for the struct.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateStructType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNumber,
//     uint64_t SizeInBits, uint32_t AlignInBits, LLVMDIFlags Flags,
//     LLVMMetadataRef DerivedFrom, LLVMMetadataRef *Elements,
//     unsigned NumElements, unsigned RunTimeLang, LLVMMetadataRef VTableHolder,
//     const char *UniqueId, size_t UniqueIdLen);
//
// /**
//  * Create debugging information entry for a member.
//  * \param Builder      The DIBuilder.
//  * \param Scope        Member scope.
//  * \param Name         Member name.
//  * \param NameLen      Length of member name.
//  * \param File         File where this member is defined.
//  * \param LineNo       Line number.
//  * \param SizeInBits   Member size.
//  * \param AlignInBits  Member alignment.
//  * \param OffsetInBits Member offset.
//  * \param Flags        Flags to encode member attribute, e.g. private
//  * \param Ty           Parent type.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateMemberType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNo,
//     uint64_t SizeInBits, uint32_t AlignInBits, uint64_t OffsetInBits,
//     LLVMDIFlags Flags, LLVMMetadataRef Ty);
//
// /**
//  * Create debugging information entry for a
//  * C++ static data member.
//  * \param Builder      The DIBuilder.
//  * \param Scope        Member scope.
//  * \param Name         Member name.
//  * \param NameLen      Length of member name.
//  * \param File         File where this member is declared.
//  * \param LineNumber   Line number.
//  * \param Type         Type of the static member.
//  * \param Flags        Flags to encode member attribute, e.g. private.
//  * \param ConstantVal  Const initializer of the member.
//  * \param AlignInBits  Member alignment.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateStaticMemberType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNumber,
//     LLVMMetadataRef Type, LLVMDIFlags Flags, LLVMValueRef ConstantVal,
//     uint32_t AlignInBits);
//
// /**
//  * Create debugging information entry for a pointer to member.
//  * \param Builder      The DIBuilder.
//  * \param PointeeType  Type pointed to by this pointer.
//  * \param ClassType    Type for which this pointer points to members of.
//  * \param SizeInBits   Size.
//  * \param AlignInBits  Alignment.
//  * \param Flags        Flags.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateMemberPointerType(LLVMDIBuilderRef Builder,
//                                      LLVMMetadataRef PointeeType,
//                                      LLVMMetadataRef ClassType,
//                                      uint64_t SizeInBits,
//                                      uint32_t AlignInBits,
//                                      LLVMDIFlags Flags);
// /**
//  * Create debugging information entry for Objective-C instance variable.
//  * \param Builder      The DIBuilder.
//  * \param Name         Member name.
//  * \param NameLen      The length of the C string passed to \c Name.
//  * \param File         File where this member is defined.
//  * \param LineNo       Line number.
//  * \param SizeInBits   Member size.
//  * \param AlignInBits  Member alignment.
//  * \param OffsetInBits Member offset.
//  * \param Flags        Flags to encode member attribute, e.g. private
//  * \param Ty           Parent type.
//  * \param PropertyNode Property associated with this ivar.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateObjCIVar(LLVMDIBuilderRef Builder,
//                             const char *Name, size_t NameLen,
//                             LLVMMetadataRef File, unsigned LineNo,
//                             uint64_t SizeInBits, uint32_t AlignInBits,
//                             uint64_t OffsetInBits, LLVMDIFlags Flags,
//                             LLVMMetadataRef Ty, LLVMMetadataRef PropertyNode);
//
// /**
//  * Create debugging information entry for Objective-C property.
//  * \param Builder            The DIBuilder.
//  * \param Name               Property name.
//  * \param NameLen            The length of the C string passed to \c Name.
//  * \param File               File where this property is defined.
//  * \param LineNo             Line number.
//  * \param GetterName         Name of the Objective C property getter selector.
//  * \param GetterNameLen      The length of the C string passed to \c GetterName.
//  * \param SetterName         Name of the Objective C property setter selector.
//  * \param SetterNameLen      The length of the C string passed to \c SetterName.
//  * \param PropertyAttributes Objective C property attributes.
//  * \param Ty                 Type.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateObjCProperty(LLVMDIBuilderRef Builder,
//                                 const char *Name, size_t NameLen,
//                                 LLVMMetadataRef File, unsigned LineNo,
//                                 const char *GetterName, size_t GetterNameLen,
//                                 const char *SetterName, size_t SetterNameLen,
//                                 unsigned PropertyAttributes,
//                                 LLVMMetadataRef Ty);
//
// /**
//  * Create a uniqued DIType* clone with FlagObjectPointer and FlagArtificial set.
//  * \param Builder   The DIBuilder.
//  * \param Type      The underlying type to which this pointer points.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateObjectPointerType(LLVMDIBuilderRef Builder,
//                                      LLVMMetadataRef Type);
//
// /**
//  * Create debugging information entry for a qualified
//  * type, e.g. 'const int'.
//  * \param Builder     The DIBuilder.
//  * \param Tag         Tag identifying type,
//  *                    e.g. LLVMDWARFTypeQualifier_volatile_type
//  * \param Type        Base Type.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateQualifiedType(LLVMDIBuilderRef Builder, unsigned Tag,
//                                  LLVMMetadataRef Type);
//
// /**
//  * Create debugging information entry for a c++
//  * style reference or rvalue reference type.
//  * \param Builder   The DIBuilder.
//  * \param Tag       Tag identifying type,
//  * \param Type      Base Type.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateReferenceType(LLVMDIBuilderRef Builder, unsigned Tag,
//                                  LLVMMetadataRef Type);
//
// /**
//  * Create C++11 nullptr type.
//  * \param Builder   The DIBuilder.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateNullPtrType(LLVMDIBuilderRef Builder);
//
// /**
//  * Create debugging information entry for a typedef.
//  * \param Builder    The DIBuilder.
//  * \param Type       Original type.
//  * \param Name       Typedef name.
//  * \param File       File where this type is defined.
//  * \param LineNo     Line number.
//  * \param Scope      The surrounding context for the typedef.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateTypedef(LLVMDIBuilderRef Builder, LLVMMetadataRef Type,
//                            const char *Name, size_t NameLen,
//                            LLVMMetadataRef File, unsigned LineNo,
//                            LLVMMetadataRef Scope, uint32_t AlignInBits);
//
// /**
//  * Create debugging information entry to establish inheritance relationship
//  * between two types.
//  * \param Builder       The DIBuilder.
//  * \param Ty            Original type.
//  * \param BaseTy        Base type. Ty is inherits from base.
//  * \param BaseOffset    Base offset.
//  * \param VBPtrOffset  Virtual base pointer offset.
//  * \param Flags         Flags to describe inheritance attribute, e.g. private
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateInheritance(LLVMDIBuilderRef Builder,
//                                LLVMMetadataRef Ty, LLVMMetadataRef BaseTy,
//                                uint64_t BaseOffset, uint32_t VBPtrOffset,
//                                LLVMDIFlags Flags);
//
// /**
//  * Create a permanent forward-declared type.
//  * \param Builder             The DIBuilder.
//  * \param Tag                 A unique tag for this type.
//  * \param Name                Type name.
//  * \param NameLen             Length of type name.
//  * \param Scope               Type scope.
//  * \param File                File where this type is defined.
//  * \param Line                Line number where this type is defined.
//  * \param RuntimeLang         Indicates runtime version for languages like
//  *                            Objective-C.
//  * \param SizeInBits          Member size.
//  * \param AlignInBits         Member alignment.
//  * \param UniqueIdentifier    A unique identifier for the type.
//  * \param UniqueIdentifierLen Length of the unique identifier.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateForwardDecl(
//     LLVMDIBuilderRef Builder, unsigned Tag, const char *Name,
//     size_t NameLen, LLVMMetadataRef Scope, LLVMMetadataRef File, unsigned Line,
//     unsigned RuntimeLang, uint64_t SizeInBits, uint32_t AlignInBits,
//     const char *UniqueIdentifier, size_t UniqueIdentifierLen);
//
// /**
//  * Create a temporary forward-declared type.
//  * \param Builder             The DIBuilder.
//  * \param Tag                 A unique tag for this type.
//  * \param Name                Type name.
//  * \param NameLen             Length of type name.
//  * \param Scope               Type scope.
//  * \param File                File where this type is defined.
//  * \param Line                Line number where this type is defined.
//  * \param RuntimeLang         Indicates runtime version for languages like
//  *                            Objective-C.
//  * \param SizeInBits          Member size.
//  * \param AlignInBits         Member alignment.
//  * \param Flags               Flags.
//  * \param UniqueIdentifier    A unique identifier for the type.
//  * \param UniqueIdentifierLen Length of the unique identifier.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateReplaceableCompositeType(
//     LLVMDIBuilderRef Builder, unsigned Tag, const char *Name,
//     size_t NameLen, LLVMMetadataRef Scope, LLVMMetadataRef File, unsigned Line,
//     unsigned RuntimeLang, uint64_t SizeInBits, uint32_t AlignInBits,
//     LLVMDIFlags Flags, const char *UniqueIdentifier,
//     size_t UniqueIdentifierLen);
//
// /**
//  * Create debugging information entry for a bit field member.
//  * \param Builder             The DIBuilder.
//  * \param Scope               Member scope.
//  * \param Name                Member name.
//  * \param NameLen             Length of member name.
//  * \param File                File where this member is defined.
//  * \param LineNumber          Line number.
//  * \param SizeInBits          Member size.
//  * \param OffsetInBits        Member offset.
//  * \param StorageOffsetInBits Member storage offset.
//  * \param Flags               Flags to encode member attribute.
//  * \param Type                Parent type.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateBitFieldMemberType(LLVMDIBuilderRef Builder,
//                                       LLVMMetadataRef Scope,
//                                       const char *Name, size_t NameLen,
//                                       LLVMMetadataRef File, unsigned LineNumber,
//                                       uint64_t SizeInBits,
//                                       uint64_t OffsetInBits,
//                                       uint64_t StorageOffsetInBits,
//                                       LLVMDIFlags Flags, LLVMMetadataRef Type);
//
// /**
//  * Create debugging information entry for a class.
//  * \param Scope               Scope in which this class is defined.
//  * \param Name                Class name.
//  * \param NameLen             The length of the C string passed to \c Name.
//  * \param File                File where this member is defined.
//  * \param LineNumber          Line number.
//  * \param SizeInBits          Member size.
//  * \param AlignInBits         Member alignment.
//  * \param OffsetInBits        Member offset.
//  * \param Flags               Flags to encode member attribute, e.g. private.
//  * \param DerivedFrom         Debug info of the base class of this type.
//  * \param Elements            Class members.
//  * \param NumElements         Number of class elements.
//  * \param VTableHolder        Debug info of the base class that contains vtable
//  *                            for this type. This is used in
//  *                            DW_AT_containing_type. See DWARF documentation
//  *                            for more info.
//  * \param TemplateParamsNode  Template type parameters.
//  * \param UniqueIdentifier    A unique identifier for the type.
//  * \param UniqueIdentifierLen Length of the unique identifier.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateClassType(LLVMDIBuilderRef Builder,
//     LLVMMetadataRef Scope, const char *Name, size_t NameLen,
//     LLVMMetadataRef File, unsigned LineNumber, uint64_t SizeInBits,
//     uint32_t AlignInBits, uint64_t OffsetInBits, LLVMDIFlags Flags,
//     LLVMMetadataRef DerivedFrom,
//     LLVMMetadataRef *Elements, unsigned NumElements,
//     LLVMMetadataRef VTableHolder, LLVMMetadataRef TemplateParamsNode,
//     const char *UniqueIdentifier, size_t UniqueIdentifierLen);
//
// /**
//  * Create a uniqued DIType* clone with FlagArtificial set.
//  * \param Builder     The DIBuilder.
//  * \param Type        The underlying type.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateArtificialType(LLVMDIBuilderRef Builder,
//                                   LLVMMetadataRef Type);
//
// /**
//  * Get the name of this DIType.
//  * \param DType     The DIType.
//  * \param Length    The length of the returned string.
//  *
//  * @see DIType::getName()
//  */
// const char *LLVMDITypeGetName(LLVMMetadataRef DType, size_t *Length);
//
// /**
//  * Get the size of this DIType in bits.
//  * \param DType     The DIType.
//  *
//  * @see DIType::getSizeInBits()
//  */
// uint64_t LLVMDITypeGetSizeInBits(LLVMMetadataRef DType);
//
// /**
//  * Get the offset of this DIType in bits.
//  * \param DType     The DIType.
//  *
//  * @see DIType::getOffsetInBits()
//  */
// uint64_t LLVMDITypeGetOffsetInBits(LLVMMetadataRef DType);
//
// /**
//  * Get the alignment of this DIType in bits.
//  * \param DType     The DIType.
//  *
//  * @see DIType::getAlignInBits()
//  */
// uint32_t LLVMDITypeGetAlignInBits(LLVMMetadataRef DType);
//
// /**
//  * Get the source line where this DIType is declared.
//  * \param DType     The DIType.
//  *
//  * @see DIType::getLine()
//  */
// unsigned LLVMDITypeGetLine(LLVMMetadataRef DType);
//
// /**
//  * Get the flags associated with this DIType.
//  * \param DType     The DIType.
//  *
//  * @see DIType::getFlags()
//  */
// LLVMDIFlags LLVMDITypeGetFlags(LLVMMetadataRef DType);
//
// /**
//  * Create a descriptor for a value range.
//  * \param Builder    The DIBuilder.
//  * \param LowerBound Lower bound of the subrange, e.g. 0 for C, 1 for Fortran.
//  * \param Count      Count of elements in the subrange.
//  */
// LLVMMetadataRef LLVMDIBuilderGetOrCreateSubrange(LLVMDIBuilderRef Builder,
//                                                  int64_t LowerBound,
//                                                  int64_t Count);
//
// /**
//  * Create an array of DI Nodes.
//  * \param Builder        The DIBuilder.
//  * \param Data           The DI Node elements.
//  * \param NumElements    Number of DI Node elements.
//  */
// LLVMMetadataRef LLVMDIBuilderGetOrCreateArray(LLVMDIBuilderRef Builder,
//                                               LLVMMetadataRef *Data,
//                                               size_t NumElements);
//
// /**
//  * Create a new descriptor for the specified variable which has a complex
//  * address expression for its address.
//  * \param Builder     The DIBuilder.
//  * \param Addr        An array of complex address operations.
//  * \param Length      Length of the address operation array.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateExpression(LLVMDIBuilderRef Builder,
//                                               uint64_t *Addr, size_t Length);
//
// /**
//  * Create a new descriptor for the specified variable that does not have an
//  * address, but does have a constant value.
//  * \param Builder     The DIBuilder.
//  * \param Value       The constant value.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateConstantValueExpression(LLVMDIBuilderRef Builder,
//                                            uint64_t Value);
//
// /**
//  * Create a new descriptor for the specified variable.
//  * \param Scope       Variable scope.
//  * \param Name        Name of the variable.
//  * \param NameLen     The length of the C string passed to \c Name.
//  * \param Linkage     Mangled  name of the variable.
//  * \param LinkLen     The length of the C string passed to \c Linkage.
//  * \param File        File where this variable is defined.
//  * \param LineNo      Line number.
//  * \param Ty          Variable Type.
//  * \param LocalToUnit Boolean flag indicate whether this variable is
//  *                    externally visible or not.
//  * \param Expr        The location of the global relative to the attached
//  *                    GlobalVariable.
//  * \param Decl        Reference to the corresponding declaration.
//  *                    variables.
//  * \param AlignInBits Variable alignment(or 0 if no alignment attr was
//  *                    specified)
//  */
// LLVMMetadataRef LLVMDIBuilderCreateGlobalVariableExpression(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, const char *Linkage, size_t LinkLen, LLVMMetadataRef File,
//     unsigned LineNo, LLVMMetadataRef Ty, LLVMBool LocalToUnit,
//     LLVMMetadataRef Expr, LLVMMetadataRef Decl, uint32_t AlignInBits);
//
//
// /**
//  * Get the dwarf::Tag of a DINode
//  */
// uint16_t LLVMGetDINodeTag(LLVMMetadataRef MD);
//
// /**
//  * Retrieves the \c DIVariable associated with this global variable expression.
//  * \param GVE    The global variable expression.
//  *
//  * @see llvm::DIGlobalVariableExpression::getVariable()
//  */
// LLVMMetadataRef LLVMDIGlobalVariableExpressionGetVariable(LLVMMetadataRef GVE);
//
// /**
//  * Retrieves the \c DIExpression associated with this global variable expression.
//  * \param GVE    The global variable expression.
//  *
//  * @see llvm::DIGlobalVariableExpression::getExpression()
//  */
// LLVMMetadataRef LLVMDIGlobalVariableExpressionGetExpression(
//     LLVMMetadataRef GVE);
//
// /**
//  * Get the metadata of the file associated with a given variable.
//  * \param Var     The variable object.
//  *
//  * @see DIVariable::getFile()
//  */
// LLVMMetadataRef LLVMDIVariableGetFile(LLVMMetadataRef Var);
//
// /**
//  * Get the metadata of the scope associated with a given variable.
//  * \param Var     The variable object.
//  *
//  * @see DIVariable::getScope()
//  */
// LLVMMetadataRef LLVMDIVariableGetScope(LLVMMetadataRef Var);
//
// /**
//  * Get the source line where this \c DIVariable is declared.
//  * \param Var     The DIVariable.
//  *
//  * @see DIVariable::getLine()
//  */
// unsigned LLVMDIVariableGetLine(LLVMMetadataRef Var);
//
// /**
//  * Create a new temporary \c MDNode.  Suitable for use in constructing cyclic
//  * \c MDNode structures. A temporary \c MDNode is not uniqued, may be RAUW'd,
//  * and must be manually deleted with \c LLVMDisposeTemporaryMDNode.
//  * \param Ctx            The context in which to construct the temporary node.
//  * \param Data           The metadata elements.
//  * \param NumElements    Number of metadata elements.
//  */
// LLVMMetadataRef LLVMTemporaryMDNode(LLVMContextRef Ctx, LLVMMetadataRef *Data,
//                                     size_t NumElements);
//
// /**
//  * Deallocate a temporary node.
//  *
//  * Calls \c replaceAllUsesWith(nullptr) before deleting, so any remaining
//  * references will be reset.
//  * \param TempNode    The temporary metadata node.
//  */
// void LLVMDisposeTemporaryMDNode(LLVMMetadataRef TempNode);
//
// /**
//  * Replace all uses of temporary metadata.
//  * \param TempTargetMetadata    The temporary metadata node.
//  * \param Replacement           The replacement metadata node.
//  */
// void LLVMMetadataReplaceAllUsesWith(LLVMMetadataRef TempTargetMetadata,
//                                     LLVMMetadataRef Replacement);
//
// /**
//  * Create a new descriptor for the specified global variable that is temporary
//  * and meant to be RAUWed.
//  * \param Scope       Variable scope.
//  * \param Name        Name of the variable.
//  * \param NameLen     The length of the C string passed to \c Name.
//  * \param Linkage     Mangled  name of the variable.
//  * \param LnkLen      The length of the C string passed to \c Linkage.
//  * \param File        File where this variable is defined.
//  * \param LineNo      Line number.
//  * \param Ty          Variable Type.
//  * \param LocalToUnit Boolean flag indicate whether this variable is
//  *                    externally visible or not.
//  * \param Decl        Reference to the corresponding declaration.
//  * \param AlignInBits Variable alignment(or 0 if no alignment attr was
//  *                    specified)
//  */
// LLVMMetadataRef LLVMDIBuilderCreateTempGlobalVariableFwdDecl(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, const char *Linkage, size_t LnkLen, LLVMMetadataRef File,
//     unsigned LineNo, LLVMMetadataRef Ty, LLVMBool LocalToUnit,
//     LLVMMetadataRef Decl, uint32_t AlignInBits);
//
// /**
//  * Only use in "new debug format" (LLVMIsNewDbgInfoFormat() is true).
//  * See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
//  *
//  * The debug format can be switched later after inserting the records using
//  * LLVMSetIsNewDbgInfoFormat, if needed for legacy or transitionary reasons.
//  *
//  * Insert a Declare DbgRecord before the given instruction.
//  * \param Builder     The DIBuilder.
//  * \param Storage     The storage of the variable to declare.
//  * \param VarInfo     The variable's debug info descriptor.
//  * \param Expr        A complex location expression for the variable.
//  * \param DebugLoc    Debug info location.
//  * \param Instr       Instruction acting as a location for the new record.
//  */
// LLVMDbgRecordRef LLVMDIBuilderInsertDeclareRecordBefore(
//     LLVMDIBuilderRef Builder, LLVMValueRef Storage, LLVMMetadataRef VarInfo,
//     LLVMMetadataRef Expr, LLVMMetadataRef DebugLoc, LLVMValueRef Instr);
//
// /**
//  * Only use in "new debug format" (LLVMIsNewDbgInfoFormat() is true).
//  * See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
//  *
//  * The debug format can be switched later after inserting the records using
//  * LLVMSetIsNewDbgInfoFormat, if needed for legacy or transitionary reasons.
//  *
//  * Insert a Declare DbgRecord at the end of the given basic block. If the basic
//  * block has a terminator instruction, the record is inserted before that
//  * terminator instruction.
//  * \param Builder     The DIBuilder.
//  * \param Storage     The storage of the variable to declare.
//  * \param VarInfo     The variable's debug info descriptor.
//  * \param Expr        A complex location expression for the variable.
//  * \param DebugLoc    Debug info location.
//  * \param Block       Basic block acting as a location for the new record.
//  */
// LLVMDbgRecordRef LLVMDIBuilderInsertDeclareRecordAtEnd(
//     LLVMDIBuilderRef Builder, LLVMValueRef Storage, LLVMMetadataRef VarInfo,
//     LLVMMetadataRef Expr, LLVMMetadataRef DebugLoc, LLVMBasicBlockRef Block);
//
// /**
//  * Only use in "new debug format" (LLVMIsNewDbgInfoFormat() is true).
//  * See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
//  *
//  * The debug format can be switched later after inserting the records using
//  * LLVMSetIsNewDbgInfoFormat, if needed for legacy or transitionary reasons.
//  *
//  * Insert a new debug record before the given instruction.
//  * \param Builder     The DIBuilder.
//  * \param Val         The value of the variable.
//  * \param VarInfo     The variable's debug info descriptor.
//  * \param Expr        A complex location expression for the variable.
//  * \param DebugLoc    Debug info location.
//  * \param Instr       Instruction acting as a location for the new record.
//  */
// LLVMDbgRecordRef LLVMDIBuilderInsertDbgValueRecordBefore(
//     LLVMDIBuilderRef Builder, LLVMValueRef Val, LLVMMetadataRef VarInfo,
//     LLVMMetadataRef Expr, LLVMMetadataRef DebugLoc, LLVMValueRef Instr);
//
// /**
//  * Only use in "new debug format" (LLVMIsNewDbgInfoFormat() is true).
//  * See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
//  *
//  * The debug format can be switched later after inserting the records using
//  * LLVMSetIsNewDbgInfoFormat, if needed for legacy or transitionary reasons.
//  *
//  * Insert a new debug record at the end of the given basic block. If the
//  * basic block has a terminator instruction, the record is inserted before
//  * that terminator instruction.
//  * \param Builder     The DIBuilder.
//  * \param Val         The value of the variable.
//  * \param VarInfo     The variable's debug info descriptor.
//  * \param Expr        A complex location expression for the variable.
//  * \param DebugLoc    Debug info location.
//  * \param Block       Basic block acting as a location for the new record.
//  */
// LLVMDbgRecordRef LLVMDIBuilderInsertDbgValueRecordAtEnd(
//     LLVMDIBuilderRef Builder, LLVMValueRef Val, LLVMMetadataRef VarInfo,
//     LLVMMetadataRef Expr, LLVMMetadataRef DebugLoc, LLVMBasicBlockRef Block);
//
// /**
//  * Create a new descriptor for a local auto variable.
//  * \param Builder         The DIBuilder.
//  * \param Scope           The local scope the variable is declared in.
//  * \param Name            Variable name.
//  * \param NameLen         Length of variable name.
//  * \param File            File where this variable is defined.
//  * \param LineNo          Line number.
//  * \param Ty              Metadata describing the type of the variable.
//  * \param AlwaysPreserve  If true, this descriptor will survive optimizations.
//  * \param Flags           Flags.
//  * \param AlignInBits     Variable alignment.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateAutoVariable(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNo, LLVMMetadataRef Ty,
//     LLVMBool AlwaysPreserve, LLVMDIFlags Flags, uint32_t AlignInBits);
//
// /**
//  * Create a new descriptor for a function parameter variable.
//  * \param Builder         The DIBuilder.
//  * \param Scope           The local scope the variable is declared in.
//  * \param Name            Variable name.
//  * \param NameLen         Length of variable name.
//  * \param ArgNo           Unique argument number for this variable; starts at 1.
//  * \param File            File where this variable is defined.
//  * \param LineNo          Line number.
//  * \param Ty              Metadata describing the type of the variable.
//  * \param AlwaysPreserve  If true, this descriptor will survive optimizations.
//  * \param Flags           Flags.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateParameterVariable(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, unsigned ArgNo, LLVMMetadataRef File, unsigned LineNo,
//     LLVMMetadataRef Ty, LLVMBool AlwaysPreserve, LLVMDIFlags Flags);
//
// /**
//  * Get the metadata of the subprogram attached to a function.
//  *
//  * @see llvm::Function::getSubprogram()
//  */
// LLVMMetadataRef LLVMGetSubprogram(LLVMValueRef Func);
//
// /**
//  * Set the subprogram attached to a function.
//  *
//  * @see llvm::Function::setSubprogram()
//  */
// void LLVMSetSubprogram(LLVMValueRef Func, LLVMMetadataRef SP);
//
// /**
//  * Get the line associated with a given subprogram.
//  * \param Subprogram     The subprogram object.
//  *
//  * @see DISubprogram::getLine()
//  */
// unsigned LLVMDISubprogramGetLine(LLVMMetadataRef Subprogram);
//
// /**
//  * Get the debug location for the given instruction.
//  *
//  * @see llvm::Instruction::getDebugLoc()
//  */
// LLVMMetadataRef LLVMInstructionGetDebugLoc(LLVMValueRef Inst);
//
// /**
//  * Set the debug location for the given instruction.
//  *
//  * To clear the location metadata of the given instruction, pass NULL to \p Loc.
//  *
//  * @see llvm::Instruction::setDebugLoc()
//  */
// void LLVMInstructionSetDebugLoc(LLVMValueRef Inst, LLVMMetadataRef Loc);
//
// /**
//  * Create a new descriptor for a label
//  *
//  * \param Builder         The DIBuilder.
//  * \param Scope           The scope to create the label in.
//  * \param Name            Variable name.
//  * \param NameLen         Length of variable name.
//  * \param File            The file to create the label in.
//  * \param LineNo          Line Number.
//  * \param AlwaysPreserve  Preserve the label regardless of optimization.
//  *
//  * @see llvm::DIBuilder::createLabel()
//  */
// LLVMMetadataRef LLVMDIBuilderCreateLabel(
//     LLVMDIBuilderRef Builder,
//     LLVMMetadataRef Context, const char *Name, size_t NameLen,
//     LLVMMetadataRef File, unsigned LineNo, LLVMBool AlwaysPreserve);
//
// /**
//  * Insert a new llvm.dbg.label intrinsic call
//  *
//  * \param Builder         The DIBuilder.
//  * \param LabelInfo       The Label's debug info descriptor
//  * \param Location        The debug info location
//  * \param InsertBefore    Location for the new intrinsic.
//  *
//  * @see llvm::DIBuilder::insertLabel()
//  */
// LLVMDbgRecordRef LLVMDIBuilderInsertLabelBefore(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef LabelInfo,
//     LLVMMetadataRef Location, LLVMValueRef InsertBefore);
//
// /**
//  * Insert a new llvm.dbg.label intrinsic call
//  *
//  * \param Builder         The DIBuilder.
//  * \param LabelInfo       The Label's debug info descriptor
//  * \param Location        The debug info location
//  * \param InsertAtEnd     Location for the new intrinsic.
//  *
//  * @see llvm::DIBuilder::insertLabel()
//  */
// LLVMDbgRecordRef LLVMDIBuilderInsertLabelAtEnd(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef LabelInfo,
//     LLVMMetadataRef Location, LLVMBasicBlockRef InsertAtEnd);
//
// /**
//  * Obtain the enumerated type of a Metadata instance.
//  *
//  * @see llvm::Metadata::getMetadataID()
//  */
// LLVMMetadataKind LLVMGetMetadataKind(LLVMMetadataRef Metadata);
