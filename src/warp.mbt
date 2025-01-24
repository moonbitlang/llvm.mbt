// Utils
extern "C" fn moonbit_str_to_c_str(
  s: String
) -> CStr = "moonbit_str_to_c_str"
extern "C" fn c_str_to_moonbit_str(
  s: CStr
) -> String = "c_str_to_moonbit_str"
extern "C" fn llvm_type_is_null(ty: LLVMTypeRef) -> LLVMBool = "__llvm_type_is_null"
fn LLVMTypeRef::is_null(self: LLVMTypeRef) -> Bool {
  llvm_type_is_null(self).to_moonbit_bool()
}

extern "C" fn llvm_value_is_null(ty: LLVMValueRef) -> LLVMBool = "__llvm_value_is_null"
fn LLVMValueRef::is_null(self: LLVMValueRef) -> Bool {
  llvm_value_is_null(self).to_moonbit_bool()
}

extern "C" fn llvm_use_is_null(self: LLVMUseRef) -> LLVMBool = "__llvm_use_is_null"
fn LLVMUseRef::is_null(self: LLVMUseRef) -> Bool {
  llvm_use_is_null(self).to_moonbit_bool()
}

pub extern "C" fn llvm_shutdown() = "__llvm_shutdown"

// FIXME: Not implemented
pub extern "C" fn llvm_get_version() -> (UInt, UInt, UInt) = "__llvm_get_version"

pub extern "C" fn llvm_create_message(message: CStr) -> CStr = "__llvm_create_message"

pub extern "C" fn llvm_dispose_message(message: CStr) = "__llvm_dispose_message"

pub extern "C" fn llvm_context_create() -> LLVMContextRef = "__llvm_context_create"

pub extern "C" fn llvm_get_global_context() -> LLVMContextRef = "__llvm_get_global_context"

// pub extern "C" fn llvm_context_set_diagnostic_handler(context: LLVMContextRef, handler: LLVMDiagnosticHandler, diagnostic_context: Ptr[Void]) = "__llvm_context_set_diagnostic_handler"

// pub extern "C" fn llvm_context_get_diagnostic_context(context: LLVMContextRef) -> Ptr[Void] = "__llvm_context_get_diagnostic_context"

// pub extern "C" fn llvm_context_set_yield_callback(context: LLVMContextRef, callback: LLVMYieldCallback, opaque_handle: Ptr[Void]) = "__llvm_context_set_yield_callback"

pub extern "C" fn llvm_context_should_discard_value_names(context: LLVMContextRef) -> LLVMBool = "__llvm_context_should_discard_value_names"

pub extern "C" fn llvm_context_set_discard_value_names(context: LLVMContextRef, discard: LLVMBool) = "__llvm_context_set_discard_value_names"

pub extern "C" fn llvm_context_dispose(context: LLVMContextRef) = "__llvm_context_dispose"

pub extern "C" fn llvm_get_diag_info_description(di: LLVMDiagnosticInfoRef) -> CStr = "__llvm_get_diag_info_description"

pub extern "C" fn llvm_get_diag_info_severity(di: LLVMDiagnosticInfoRef) -> LLVMDiagnosticSeverity = "__llvm_get_diag_info_severity"

pub extern "C" fn llvm_get_md_kind_id_in_context(context: LLVMContextRef, name: CStr, s_len: UInt) -> UInt = "__llvm_get_md_kind_id_in_context"

pub extern "C" fn llvm_get_md_kind_id(name: CStr, s_len: UInt) -> UInt = "__llvm_get_md_kind_id"

pub extern "C" fn llvm_get_enum_attribute_kind_for_name(name: CStr, s_len: UInt64) -> UInt = "__llvm_get_enum_attribute_kind_for_name"

pub extern "C" fn llvm_get_last_enum_attribute_kind() -> UInt = "__llvm_get_last_enum_attribute_kind"

pub extern "C" fn llvm_create_enum_attribute(context: LLVMContextRef, kind_id: UInt, val: UInt64) -> LLVMAttributeRef = "__llvm_create_enum_attribute"

pub extern "C" fn llvm_get_enum_attribute_kind(a: LLVMAttributeRef) -> UInt = "__llvm_get_enum_attribute_kind"

pub extern "C" fn llvm_get_enum_attribute_value(a: LLVMAttributeRef) -> UInt64 = "__llvm_get_enum_attribute_value"

pub extern "C" fn llvm_create_type_attribute(context: LLVMContextRef, kind_id: UInt, type_ref: LLVMTypeRef) -> LLVMAttributeRef = "__llvm_create_type_attribute"

pub extern "C" fn llvm_get_type_attribute_value(a: LLVMAttributeRef) -> LLVMTypeRef = "__llvm_get_type_attribute_value"

// pub extern "C" fn llvm_get_string_attribute_kind(a: LLVMAttributeRef, length: Ptr[UInt]) -> CStr = "__llvm_get_string_attribute_kind"
//
// pub extern "C" fn llvm_get_string_attribute_value(a: LLVMAttributeRef, length: Ptr[UInt]) -> CStr = "__llvm_get_string_attribute_value"

pub extern "C" fn llvm_is_enum_attribute(a: LLVMAttributeRef) -> LLVMBool = "__llvm_is_enum_attribute"

pub extern "C" fn llvm_is_string_attribute(a: LLVMAttributeRef) -> LLVMBool = "__llvm_is_string_attribute"

pub extern "C" fn llvm_is_type_attribute(a: LLVMAttributeRef) -> LLVMBool = "__llvm_is_type_attribute"

pub extern "C" fn llvm_get_type_by_name(context: LLVMContextRef, name: CStr) -> LLVMTypeRef = "__llvm_get_type_by_name"

pub extern "C" fn llvm_module_create_with_name(module_id: CStr) -> LLVMModuleRef = "__llvm_module_create_with_name"

pub extern "C" fn llvm_module_create_with_name_in_context(module_id: CStr, context: LLVMContextRef) -> LLVMModuleRef = "__llvm_module_create_with_name_in_context"

pub extern "C" fn llvm_clone_module(m: LLVMModuleRef) -> LLVMModuleRef = "__llvm_clone_module"

pub extern "C" fn llvm_dispose_module(m: LLVMModuleRef) = "__llvm_dispose_module"

pub extern "C" fn llvm_is_new_dbg_info_format(m: LLVMModuleRef) -> LLVMBool = "__llvm_is_new_dbg_info_format"

pub extern "C" fn llvm_set_is_new_dbg_info_format(m: LLVMModuleRef, use_new_format: LLVMBool) = "__llvm_set_is_new_dbg_info_format"

// pub extern "C" fn llvm_get_module_identifier(m: LLVMModuleRef, len: Ptr[UInt64]) -> CStr = "__llvm_get_module_identifier"

pub extern "C" fn llvm_set_module_identifier(m: LLVMModuleRef, ident: CStr, len: UInt64) = "__llvm_set_module_identifier"

// pub extern "C" fn llvm_get_source_file_name(m: LLVMModuleRef, len: Ptr[UInt64]) -> CStr = "__llvm_get_source_file_name"

pub extern "C" fn llvm_set_source_file_name(m: LLVMModuleRef, name: CStr, len: UInt64) = "__llvm_set_source_file_name"

pub extern "C" fn llvm_get_data_layout_str(m: LLVMModuleRef) -> CStr = "__llvm_get_data_layout_str"

pub extern "C" fn llvm_get_data_layout(m: LLVMModuleRef) -> CStr = "__llvm_get_data_layout"

pub extern "C" fn llvm_set_data_layout(m: LLVMModuleRef, data_layout_str: CStr) = "__llvm_set_data_layout"

pub extern "C" fn llvm_get_target(m: LLVMModuleRef) -> CStr = "__llvm_get_target"

pub extern "C" fn llvm_set_target(m: LLVMModuleRef, triple: CStr) = "__llvm_set_target"

// pub extern "C" fn llvm_copy_module_flags_metadata(m: LLVMModuleRef, len: Ptr[UInt64]) -> Ptr[LLVMModuleFlagEntry] = "__llvm_copy_module_flags_metadata"

// pub extern "C" fn llvm_dispose_module_flags_metadata(entries: Ptr[LLVMModuleFlagEntry]) = "__llvm_dispose_module_flags_metadata"

// pub extern "C" fn llvm_module_flag_entries_get_flag_behavior(entries: Ptr[LLVMModuleFlagEntry], index: UInt) -> LLVMModuleFlagBehavior = "__llvm_module_flag_entries_get_flag_behavior"

// pub extern "C" fn llvm_module_flag_entries_get_key(entries: Ptr[LLVMModuleFlagEntry], index: UInt, len: Ptr[UInt64]) -> CStr = "__llvm_module_flag_entries_get_key"

// pub extern "C" fn llvm_module_flag_entries_get_metadata(entries: Ptr[LLVMModuleFlagEntry], index: UInt) -> LLVMMetadataRef = "__llvm_module_flag_entries_get_metadata"

pub extern "C" fn llvm_get_module_flag(m: LLVMModuleRef, key: CStr, key_len: UInt64) -> LLVMMetadataRef = "__llvm_get_module_flag"

pub extern "C" fn llvm_add_module_flag(m: LLVMModuleRef, behavior: LLVMModuleFlagBehavior, key: CStr, key_len: UInt64, val: LLVMMetadataRef) = "__llvm_add_module_flag"

pub extern "C" fn llvm_dump_module(m: LLVMModuleRef) = "__llvm_dump_module"

// pub extern "C" fn llvm_print_module_to_file(m: LLVMModuleRef, filename: CStr, error_message: Ptr[CStr]) -> LLVMBool = "__llvm_print_module_to_file"

extern "C" fn __llvm_print_module_to_string(m: LLVMModuleRef) -> CStr = "__llvm_print_module_to_string"
pub fn llvm_print_module_to_string(m: LLVMModuleRef) -> String {
  let cstr = __llvm_print_module_to_string(m)
  c_str_to_moonbit_str(cstr)
}

// pub extern "C" fn llvm_get_module_inline_asm(m: LLVMModuleRef, len: Ptr[UInt64]) -> CStr = "__llvm_get_module_inline_asm"

pub extern "C" fn llvm_set_module_inline_asm(m: LLVMModuleRef, _asm: CStr, len: UInt64) = "__llvm_set_module_inline_asm"

pub extern "C" fn llvm_append_module_inline_asm(m: LLVMModuleRef, _asm: CStr, len: UInt64) = "__llvm_append_module_inline_asm"

// pub extern "C" fn llvm_get_inline_asm(ty: LLVMTypeRef, asm_string: CStr, asm_string_size: UInt64, constraints: CStr, constraints_size: UInt64, has_side_effects: LLVMBool, is_align_stack: LLVMBool, dialect: LLVMInlineAsmDialect, can_throw: LLVMBool) -> LLVMValueRef = "__llvm_get_inline_asm"

// pub extern "C" fn llvm_get_inline_asm_asm_string(inline_asm_val: LLVMValueRef, len: Ptr[UInt64]) -> CStr = "__llvm_get_inline_asm_asm_string"

// pub extern "C" fn llvm_get_inline_asm_constraint_string(inline_asm_val: LLVMValueRef, len: Ptr[UInt64]) -> CStr = "__llvm_get_inline_asm_constraint_string"

pub extern "C" fn llvm_get_inline_asm_dialect(inline_asm_val: LLVMValueRef) -> LLVMInlineAsmDialect = "__llvm_get_inline_asm_dialect"

pub extern "C" fn llvm_get_inline_asm_function_type(inline_asm_val: LLVMValueRef) -> LLVMTypeRef = "__llvm_get_inline_asm_function_type"

pub extern "C" fn llvm_get_inline_asm_has_side_effects(inline_asm_val: LLVMValueRef) -> LLVMBool = "__llvm_get_inline_asm_has_side_effects"

pub extern "C" fn llvm_get_inline_asm_needs_aligned_stack(inline_asm_val: LLVMValueRef) -> LLVMBool = "__llvm_get_inline_asm_needs_aligned_stack"

pub extern "C" fn llvm_get_inline_asm_can_unwind(inline_asm_val: LLVMValueRef) -> LLVMBool = "__llvm_get_inline_asm_can_unwind"

pub extern "C" fn llvm_get_module_context(m: LLVMModuleRef) -> LLVMContextRef = "__llvm_get_module_context"

pub extern "C" fn llvm_get_type_by_name_in_module(m: LLVMModuleRef, name: CStr) -> LLVMTypeRef = "__llvm_get_type_by_name_in_module"

pub extern "C" fn llvm_get_first_named_metadata(m: LLVMModuleRef) -> LLVMNamedMDNodeRef = "__llvm_get_first_named_metadata"

pub extern "C" fn llvm_get_last_named_metadata(m: LLVMModuleRef) -> LLVMNamedMDNodeRef = "__llvm_get_last_named_metadata"

pub extern "C" fn llvm_get_next_named_metadata(named_md_node: LLVMNamedMDNodeRef) -> LLVMNamedMDNodeRef = "__llvm_get_next_named_metadata"

pub extern "C" fn llvm_get_previous_named_metadata(named_md_node: LLVMNamedMDNodeRef) -> LLVMNamedMDNodeRef = "__llvm_get_previous_named_metadata"

pub extern "C" fn llvm_get_named_metadata(m: LLVMModuleRef, name: CStr, name_len: UInt64) -> LLVMNamedMDNodeRef = "__llvm_get_named_metadata"

pub extern "C" fn llvm_get_or_insert_named_metadata(m: LLVMModuleRef, name: CStr, name_len: UInt64) -> LLVMNamedMDNodeRef = "__llvm_get_or_insert_named_metadata"

// pub extern "C" fn llvm_get_named_metadata_name(named_md: LLVMNamedMDNodeRef, name_len: Ptr[UInt64]) -> CStr = "__llvm_get_named_metadata_name"

pub extern "C" fn llvm_get_named_metadata_num_operands(m: LLVMModuleRef, name: CStr) -> UInt = "__llvm_get_named_metadata_num_operands"

// pub extern "C" fn llvm_get_named_metadata_operands(m: LLVMModuleRef, name: CStr, dest: Ptr[LLVMValueRef]) = "__llvm_get_named_metadata_operands"

pub extern "C" fn llvm_add_named_metadata_operand(m: LLVMModuleRef, name: CStr, val: LLVMValueRef) = "__llvm_add_named_metadata_operand"
//
// pub extern "C" fn llvm_get_debug_loc_directory(val: LLVMValueRef, length: Ptr[UInt]) -> CStr = "__llvm_get_debug_loc_directory"

// pub extern "C" fn llvm_get_debug_loc_filename(val: LLVMValueRef, length: Ptr[UInt]) -> CStr = "__llvm_get_debug_loc_filename"

pub extern "C" fn llvm_get_debug_loc_line(val: LLVMValueRef) -> UInt = "__llvm_get_debug_loc_line"

pub extern "C" fn llvm_get_debug_loc_column(val: LLVMValueRef) -> UInt = "__llvm_get_debug_loc_column"

pub extern "C" fn llvm_add_function(m: LLVMModuleRef, name: CStr, function_ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_add_function"

pub extern "C" fn llvm_get_named_function(m: LLVMModuleRef, name: CStr) -> LLVMValueRef = "__llvm_get_named_function"

pub extern "C" fn llvm_get_first_function(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_first_function"

pub extern "C" fn llvm_get_last_function(m: LLVMModuleRef) -> LLVMValueRef = "__llvm_get_last_function"

pub extern "C" fn llvm_get_next_function(func: LLVMValueRef) -> LLVMValueRef = "__llvm_get_next_function"
//
pub extern "C" fn llvm_get_previous_function(func: LLVMValueRef) -> LLVMValueRef = "__llvm_get_previous_function"

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

extern "C" fn __llvm_print_type_to_string(val: LLVMTypeRef) -> CStr = "__llvm_print_type_to_string"
pub fn llvm_print_type_to_string(val: LLVMTypeRef) -> String {
  let cstr = __llvm_print_type_to_string(val)
  c_str_to_moonbit_str(cstr)
}

pub extern "C" fn llvm_int1_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int1_type_in_context"

pub extern "C" fn llvm_int8_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int8_type_in_context"

pub extern "C" fn llvm_int16_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int16_type_in_context"

pub extern "C" fn llvm_int32_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int32_type_in_context"

pub extern "C" fn llvm_int64_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int64_type_in_context"

pub extern "C" fn llvm_int128_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_int128_type_in_context"

pub extern "C" fn llvm_int_type_in_context(context: LLVMContextRef, num_bits: UInt) -> LLVMTypeRef = "__llvm_int_type_in_context"

pub extern "C" fn llvm_int1_type() -> LLVMTypeRef = "__llvm_int1_type"

pub extern "C" fn llvm_int8_type() -> LLVMTypeRef = "__llvm_int8_type"

pub extern "C" fn llvm_int16_type() -> LLVMTypeRef = "__llvm_int16_type"

pub extern "C" fn llvm_int32_type() -> LLVMTypeRef = "__llvm_int32_type"

pub extern "C" fn llvm_int64_type() -> LLVMTypeRef = "__llvm_int64_type"

pub extern "C" fn llvm_int128_type() -> LLVMTypeRef = "__llvm_int128_type"

pub extern "C" fn llvm_int_type(num_bits: UInt) -> LLVMTypeRef = "__llvm_int_type"

pub extern "C" fn llvm_get_int_type_width(integer_ty: LLVMTypeRef) -> UInt = "__llvm_get_int_type_width"

pub extern "C" fn llvm_half_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_half_type_in_context"

pub extern "C" fn llvm_bfloat_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_bfloat_type_in_context"

pub extern "C" fn llvm_float_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_float_type_in_context"

pub extern "C" fn llvm_double_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_double_type_in_context"

pub extern "C" fn llvm_x86_fp80_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_x86_fp80_type_in_context"

pub extern "C" fn llvm_fp128_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_fp128_type_in_context"

pub extern "C" fn llvm_ppc_fp128_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_ppc_fp128_type_in_context"

pub extern "C" fn llvm_half_type() -> LLVMTypeRef = "__llvm_half_type"

pub extern "C" fn llvm_bfloat_type() -> LLVMTypeRef = "__llvm_bfloat_type"

pub extern "C" fn llvm_float_type() -> LLVMTypeRef = "__llvm_float_type"

pub extern "C" fn llvm_double_type() -> LLVMTypeRef = "__llvm_double_type"

pub extern "C" fn llvm_x86_fp80_type() -> LLVMTypeRef = "__llvm_x86_fp80_type"

pub extern "C" fn llvm_fp128_type() -> LLVMTypeRef = "__llvm_fp128_type"

pub extern "C" fn llvm_ppc_fp128_type() -> LLVMTypeRef = "__llvm_ppc_fp128_type"

pub extern "C" fn llvm_function_type(return_type: LLVMTypeRef, param_types: Array[LLVMTypeRef], is_var_arg: LLVMBool) -> LLVMTypeRef = "__llvm_function_type"

pub extern "C" fn llvm_is_function_var_arg(function_ty: LLVMTypeRef) -> LLVMBool = "__llvm_is_function_var_arg"

pub extern "C" fn llvm_get_return_type(function_ty: LLVMTypeRef) -> LLVMTypeRef = "__llvm_get_return_type"

pub extern "C" fn llvm_count_param_types(function_ty: LLVMTypeRef) -> UInt = "__llvm_count_param_types"

// pub extern "C" fn llvm_get_param_types(function_ty: LLVMTypeRef, dest: Ptr[LLVMTypeRef]) = "__llvm_get_param_types"

pub extern "C" fn llvm_struct_type_in_context(context: LLVMContextRef, element_types: Array[LLVMTypeRef], packed: LLVMBool) -> LLVMTypeRef = "__llvm_struct_type_in_context"

pub extern "C" fn llvm_struct_type(element_types: Array[LLVMTypeRef], packed: LLVMBool) -> LLVMTypeRef = "__llvm_struct_type"

pub extern "C" fn llvm_struct_create_named(context: LLVMContextRef, name: CStr) -> LLVMTypeRef = "__llvm_struct_create_named"

pub extern "C" fn llvm_get_struct_name(ty: LLVMTypeRef) -> CStr = "__llvm_get_struct_name"

pub extern "C" fn llvm_struct_set_body(struct_ty: LLVMTypeRef, element_types: Array[LLVMTypeRef], packed: LLVMBool) = "__llvm_struct_set_body"

pub extern "C" fn llvm_count_struct_element_types(struct_ty: LLVMTypeRef) -> UInt = "__llvm_count_struct_element_types"

// pub extern "C" fn llvm_get_struct_element_types(struct_ty: LLVMTypeRef, dest: Ptr[LLVMTypeRef]) = "__llvm_get_struct_element_types"

pub extern "C" fn llvm_struct_get_type_at_index(struct_ty: LLVMTypeRef, i: UInt) -> LLVMTypeRef = "__llvm_struct_get_type_at_index"

pub extern "C" fn llvm_is_packed_struct(struct_ty: LLVMTypeRef) -> LLVMBool = "__llvm_is_packed_struct"

pub extern "C" fn llvm_is_opaque_struct(struct_ty: LLVMTypeRef) -> LLVMBool = "__llvm_is_opaque_struct"

pub extern "C" fn llvm_is_literal_struct(struct_ty: LLVMTypeRef) -> LLVMBool = "__llvm_is_literal_struct"

pub extern "C" fn llvm_get_element_type(ty: LLVMTypeRef) -> LLVMTypeRef = "__llvm_get_element_type"

// FIXME: Not implemented
pub extern "C" fn llvm_get_subtypes(tp: LLVMTypeRef) -> Array[LLVMTypeRef] = "__llvm_get_subtypes"

pub extern "C" fn llvm_get_num_contained_types(tp: LLVMTypeRef) -> UInt = "__llvm_get_num_contained_types"

pub extern "C" fn llvm_array_type(element_type: LLVMTypeRef, element_count: UInt) -> LLVMTypeRef = "__llvm_array_type"

pub extern "C" fn llvm_array_type2(element_type: LLVMTypeRef, element_count: UInt64) -> LLVMTypeRef = "__llvm_array_type2"

pub extern "C" fn llvm_get_array_length(array_ty: LLVMTypeRef) -> UInt = "__llvm_get_array_length"

pub extern "C" fn llvm_get_array_length2(array_ty: LLVMTypeRef) -> UInt64 = "__llvm_get_array_length2"

pub extern "C" fn llvm_pointer_type(element_type: LLVMTypeRef, address_space: AddressSpace) -> LLVMTypeRef = "__llvm_pointer_type"

pub extern "C" fn llvm_pointer_type_is_opaque(ty: LLVMTypeRef) -> LLVMBool = "__llvm_pointer_type_is_opaque"

pub extern "C" fn llvm_pointer_type_in_context(context: LLVMContextRef, address_space: AddressSpace) -> LLVMTypeRef = "__llvm_pointer_type_in_context"

pub extern "C" fn llvm_get_pointer_address_space(pointer_ty: LLVMTypeRef) -> UInt = "__llvm_get_pointer_address_space"

pub extern "C" fn llvm_vector_type(element_type: LLVMTypeRef, element_count: UInt) -> LLVMTypeRef = "__llvm_vector_type"

pub extern "C" fn llvm_scalable_vector_type(element_type: LLVMTypeRef, element_count: UInt) -> LLVMTypeRef = "__llvm_scalable_vector_type"

pub extern "C" fn llvm_get_vector_size(vector_ty: LLVMTypeRef) -> UInt = "__llvm_get_vector_size"

pub extern "C" fn llvm_void_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_void_type_in_context"

pub extern "C" fn llvm_label_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_label_type_in_context"

pub extern "C" fn llvm_x86_mmx_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_x86_mmx_type_in_context"

pub extern "C" fn llvm_x86_amx_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_x86_amx_type_in_context"

pub extern "C" fn llvm_token_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_token_type_in_context"

pub extern "C" fn llvm_metadata_type_in_context(context: LLVMContextRef) -> LLVMTypeRef = "__llvm_metadata_type_in_context"

pub extern "C" fn llvm_void_type() -> LLVMTypeRef = "__llvm_void_type"

pub extern "C" fn llvm_label_type() -> LLVMTypeRef = "__llvm_label_type"

pub extern "C" fn llvm_x86_mmx_type() -> LLVMTypeRef = "__llvm_x86_mmx_type"

pub extern "C" fn llvm_x86_amx_type() -> LLVMTypeRef = "__llvm_x86_amx_type"

pub extern "C" fn llvm_get_target_ext_type_name(target_ext_ty: LLVMTypeRef) -> CStr = "__llvm_get_target_ext_type_name"

pub extern "C" fn llvm_get_target_ext_type_num_type_params(target_ext_ty: LLVMTypeRef) -> UInt = "__llvm_get_target_ext_type_num_type_params"

pub extern "C" fn llvm_get_target_ext_type_type_param(target_ext_ty: LLVMTypeRef, idx: UInt) -> LLVMTypeRef = "__llvm_get_target_ext_type_type_param"

pub extern "C" fn llvm_get_target_ext_type_num_int_params(target_ext_ty: LLVMTypeRef) -> UInt = "__llvm_get_target_ext_type_num_int_params"

pub extern "C" fn llvm_get_target_ext_type_int_param(target_ext_ty: LLVMTypeRef, idx: UInt) -> UInt = "__llvm_get_target_ext_type_int_param"

pub extern "C" fn llvm_type_of(val: LLVMValueRef) -> LLVMTypeRef = "__llvm_type_of"

pub extern "C" fn llvm_get_value_kind(val: LLVMValueRef) -> LLVMValueKind = "__llvm_get_value_kind"

// pub extern "C" fn llvm_get_value_name2(val: LLVMValueRef, length: Ptr[UInt64]) -> CStr = "__llvm_get_value_name2"

extern "C" fn __llvm_set_value_name(val: LLVMValueRef, name: CStr, name_len: Int) = "__llvm_set_value_name2"
pub fn llvm_set_value_name(val: LLVMValueRef, name: String) -> Unit {
  let cstr = moonbit_str_to_c_str(name)
  let len = name.length()
  __llvm_set_value_name(val, cstr, len)
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

pub extern "C" fn llvm_is_constant(val: LLVMValueRef) -> LLVMBool = "__llvm_is_constant"

pub extern "C" fn llvm_is_undef(val: LLVMValueRef) -> LLVMBool = "__llvm_is_undef"

pub extern "C" fn llvm_is_poison(val: LLVMValueRef) -> LLVMBool = "__llvm_is_poison"

pub extern "C" fn llvm_isa_argument(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_argument"

pub extern "C" fn llvm_isa_basic_block(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_basic_block"

pub extern "C" fn llvm_isa_inline_asm(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_inline_asm"

pub extern "C" fn llvm_isa_user(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_user"

pub extern "C" fn llvm_isa_constant(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant"

pub extern "C" fn llvm_isa_block_address(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_block_address"

pub extern "C" fn llvm_isa_constant_aggregate_zero(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_aggregate_zero"

pub extern "C" fn llvm_isa_constant_array(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_array"

pub extern "C" fn llvm_isa_constant_data_sequential(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_data_sequential"

pub extern "C" fn llvm_isa_constant_data_array(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_data_array"

pub extern "C" fn llvm_isa_constant_data_vector(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_data_vector"

pub extern "C" fn llvm_isa_constant_expr(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_expr"

pub extern "C" fn llvm_isa_constant_fp(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_fp"

pub extern "C" fn llvm_isa_constant_int(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_int"

pub extern "C" fn llvm_isa_constant_pointer_null(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_pointer_null"

pub extern "C" fn llvm_isa_constant_struct(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_struct"

pub extern "C" fn llvm_isa_constant_token_none(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_token_none"

pub extern "C" fn llvm_isa_constant_vector(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_constant_vector"

pub extern "C" fn llvm_isa_global_value(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_value"

pub extern "C" fn llvm_isa_global_alias(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_alias"

pub extern "C" fn llvm_isa_global_object(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_object"

pub extern "C" fn llvm_isa_function(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_function"

pub extern "C" fn llvm_isa_global_variable(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_variable"

pub extern "C" fn llvm_isa_global_ifunc(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_global_ifunc"

pub extern "C" fn llvm_isa_undef_value(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_undef_value"

pub extern "C" fn llvm_isa_poison_value(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_poison_value"

pub extern "C" fn llvm_isa_instruction(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_instruction"

pub extern "C" fn llvm_isa_unary_operator(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_unary_operator"

pub extern "C" fn llvm_isa_binary_operator(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_binary_operator"

pub extern "C" fn llvm_isa_call_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_call_inst"

pub extern "C" fn llvm_isa_intrinsic_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_intrinsic_inst"

pub extern "C" fn llvm_isa_dbg_info_intrinsic(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_dbg_info_intrinsic"

pub extern "C" fn llvm_isa_dbg_variable_intrinsic(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_dbg_variable_intrinsic"

pub extern "C" fn llvm_isa_dbg_declare_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_dbg_declare_inst"

pub extern "C" fn llvm_isa_dbg_label_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_dbg_label_inst"

pub extern "C" fn llvm_isa_mem_intrinsic(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_mem_intrinsic"

pub extern "C" fn llvm_isa_mem_cpy_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_mem_cpy_inst"

pub extern "C" fn llvm_isa_mem_move_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_mem_move_inst"

pub extern "C" fn llvm_isa_mem_set_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_mem_set_inst"

pub extern "C" fn llvm_isa_cmp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_cmp_inst"

pub extern "C" fn llvm_isa_f_cmp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_f_cmp_inst"

pub extern "C" fn llvm_isa_i_cmp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_i_cmp_inst"

pub extern "C" fn llvm_isa_extract_element_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_extract_element_inst"

pub extern "C" fn llvm_isa_get_element_ptr_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_get_element_ptr_inst"

pub extern "C" fn llvm_isa_insert_element_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_insert_element_inst"

pub extern "C" fn llvm_isa_insert_value_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_insert_value_inst"

pub extern "C" fn llvm_isa_landing_pad_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_landing_pad_inst"

pub extern "C" fn llvm_isa_phi_node(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_phi_node"

pub extern "C" fn llvm_isa_select_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_select_inst"

pub extern "C" fn llvm_isa_shuffle_vector_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_shuffle_vector_inst"

pub extern "C" fn llvm_isa_store_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_store_inst"

pub extern "C" fn llvm_isa_branch_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_branch_inst"

pub extern "C" fn llvm_isa_indirect_br_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_indirect_br_inst"

pub extern "C" fn llvm_isa_invoke_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_invoke_inst"

pub extern "C" fn llvm_isa_return_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_return_inst"

pub extern "C" fn llvm_isa_switch_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_switch_inst"

pub extern "C" fn llvm_isa_unreachable_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_unreachable_inst"

pub extern "C" fn llvm_isa_resume_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_resume_inst"

pub extern "C" fn llvm_isa_cleanup_return_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_cleanup_return_inst"

pub extern "C" fn llvm_isa_catch_return_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_catch_return_inst"

pub extern "C" fn llvm_isa_catch_switch_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_catch_switch_inst"

pub extern "C" fn llvm_isa_call_br_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_call_br_inst"

pub extern "C" fn llvm_isa_funclet_pad_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_funclet_pad_inst"

pub extern "C" fn llvm_isa_catch_pad_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_catch_pad_inst"

pub extern "C" fn llvm_isa_cleanup_pad_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_cleanup_pad_inst"

pub extern "C" fn llvm_isa_unary_instruction(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_unary_instruction"

pub extern "C" fn llvm_isa_alloca_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_alloca_inst"

pub extern "C" fn llvm_isa_cast_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_cast_inst"

pub extern "C" fn llvm_isa_addr_space_cast_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_addr_space_cast_inst"

pub extern "C" fn llvm_isa_bit_cast_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_bit_cast_inst"

pub extern "C" fn llvm_isa_fp_ext_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fp_ext_inst"

pub extern "C" fn llvm_isa_fp_to_si_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fp_to_si_inst"

pub extern "C" fn llvm_isa_fp_to_ui_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fp_to_ui_inst"

pub extern "C" fn llvm_isa_fp_trunc_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fp_trunc_inst"

pub extern "C" fn llvm_isa_int_to_ptr_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_int_to_ptr_inst"

pub extern "C" fn llvm_isa_ptr_to_int_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_ptr_to_int_inst"

pub extern "C" fn llvm_isa_sext_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_sext_inst"

pub extern "C" fn llvm_isa_si_to_fp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_si_to_fp_inst"

pub extern "C" fn llvm_isa_trunc_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_trunc_inst"

pub extern "C" fn llvm_isa_ui_to_fp_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_ui_to_fp_inst"

pub extern "C" fn llvm_isa_z_ext_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_z_ext_inst"

pub extern "C" fn llvm_isa_extract_value_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_extract_value_inst"

pub extern "C" fn llvm_isa_load_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_load_inst"

pub extern "C" fn llvm_isa_va_arg_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_va_arg_inst"

pub extern "C" fn llvm_isa_freeze_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_freeze_inst"

pub extern "C" fn llvm_isa_atomic_cmp_xchg_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_atomic_cmp_xchg_inst"

pub extern "C" fn llvm_isa_atomic_rmw_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_atomic_rmw_inst"

pub extern "C" fn llvm_isa_fence_inst(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_fence_inst"

pub extern "C" fn llvm_isa_md_node(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_md_node"

pub extern "C" fn llvm_isa_value_as_metadata(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_value_as_metadata"

pub extern "C" fn llvm_isa_md_string(val: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_md_string"

pub extern "C" fn llvm_get_value_name(val: LLVMValueRef) -> CStr = "__llvm_get_value_name"

// deprecated
// pub extern "C" fn llvm_set_value_name(val: LLVMValueRef, name: CStr) = "__llvm_set_value_name"

pub extern "C" fn llvm_get_first_use(val: LLVMValueRef) -> LLVMUseRef = "__llvm_get_first_use"

pub extern "C" fn llvm_get_next_use(u: LLVMUseRef) -> LLVMUseRef = "__llvm_get_next_use"

pub extern "C" fn llvm_get_user(u: LLVMUseRef) -> LLVMValueRef = "__llvm_get_user"

pub extern "C" fn llvm_get_used_value(u: LLVMUseRef) -> LLVMValueRef = "__llvm_get_used_value"

pub extern "C" fn llvm_get_operand(val: LLVMValueRef, index: UInt) -> LLVMValueRef = "__llvm_get_operand"

pub extern "C" fn llvm_get_operand_use(val: LLVMValueRef, index: UInt) -> LLVMUseRef = "__llvm_get_operand_use"

pub extern "C" fn llvm_set_operand(user: LLVMValueRef, index: UInt, val: LLVMValueRef) = "__llvm_set_operand"

pub extern "C" fn llvm_get_num_operands(val: LLVMValueRef) -> Int = "__llvm_get_num_operands"

pub extern "C" fn llvm_const_null(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_null"

pub extern "C" fn llvm_const_all_ones(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_all_ones"

pub extern "C" fn llvm_get_undef(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_get_undef"

pub extern "C" fn llvm_get_poison(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_get_poison"

pub extern "C" fn llvm_is_null(val: LLVMValueRef) -> LLVMBool = "__llvm_is_null"

pub extern "C" fn llvm_const_pointer_null(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_pointer_null"

pub extern "C" fn llvm_const_int(int_ty: LLVMTypeRef, n: UInt64, sign_extend: LLVMBool) -> LLVMValueRef = "__llvm_const_int"

// pub extern "C" fn llvm_const_int_of_string(int_ty: LLVMTypeRef, text: CStr, radix: UInt8) -> LLVMValueRef = "__llvm_const_int_of_string"

// pub extern "C" fn llvm_const_int_of_string_and_size(int_ty: LLVMTypeRef, text: CStr, s_len: UInt, radix: UInt8) -> LLVMValueRef = "__llvm_const_int_of_string_and_size"

pub extern "C" fn llvm_const_real(real_ty: LLVMTypeRef, n: Double) -> LLVMValueRef = "__llvm_const_real"

pub extern "C" fn llvm_const_real_of_string(real_ty: LLVMTypeRef, text: CStr) -> LLVMValueRef = "__llvm_const_real_of_string"

pub extern "C" fn llvm_const_real_of_string_and_size(real_ty: LLVMTypeRef, text: CStr, s_len: UInt) -> LLVMValueRef = "__llvm_const_real_of_string_and_size"

pub extern "C" fn llvm_const_int_get_z_ext_value(constant_val: LLVMValueRef) -> UInt64 = "__llvm_const_int_get_z_ext_value"

pub extern "C" fn llvm_const_int_get_s_ext_value(constant_val: LLVMValueRef) -> Int64 = "__llvm_const_int_get_s_ext_value"

// pub extern "C" fn llvm_const_real_get_double(constant_val: LLVMValueRef, loses_info: Ptr[LLVMBool]) -> Double = "__llvm_const_real_get_double"

pub extern "C" fn llvm_const_string_in_context(context: LLVMContextRef, str: CStr, length: UInt, dont_null_terminate: LLVMBool) -> LLVMValueRef = "__llvm_const_string_in_context"

pub extern "C" fn llvm_const_string_in_context2(context: LLVMContextRef, str: CStr, length: UInt64, dont_null_terminate: LLVMBool) -> LLVMValueRef = "__llvm_const_string_in_context2"

pub extern "C" fn llvm_const_string(str: CStr, length: UInt, dont_null_terminate: LLVMBool) -> LLVMValueRef = "__llvm_const_string"

pub extern "C" fn llvm_is_constant_string(c: LLVMValueRef) -> LLVMBool = "__llvm_is_constant_string"

// pub extern "C" fn llvm_get_as_string(c: LLVMValueRef, length: Ptr[UInt64]) -> CStr = "__llvm_get_as_string"

pub extern "C" fn llvm_const_struct_in_context(context: LLVMContextRef, constant_vals: Array[LLVMValueRef], packed: LLVMBool) -> LLVMValueRef = "__llvm_const_struct_in_context"

pub extern "C" fn llvm_const_struct(constant_vals: Array[LLVMValueRef], packed: LLVMBool) -> LLVMValueRef = "__llvm_const_struct"

pub extern "C" fn llvm_const_array(element_ty: LLVMTypeRef, constant_vals: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_array"

pub extern "C" fn llvm_const_array2(element_ty: LLVMTypeRef, constant_vals: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_array2"

pub extern "C" fn llvm_const_named_struct(struct_ty: LLVMTypeRef, constant_vals: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_named_struct"

pub extern "C" fn llvm_get_aggregate_element(c: LLVMValueRef, idx: UInt) -> LLVMValueRef = "__llvm_get_aggregate_element"

pub extern "C" fn llvm_const_vector(scalar_constant_vals: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_vector"

extern "C" fn __llvm_get_const_opcode(constant_val: LLVMValueRef) -> Int = "__llvm_get_const_opcode"
pub fn llvm_get_const_opcode(constant_val: LLVMValueRef) -> LLVMOpcode {
  let opcode = __llvm_get_const_opcode(constant_val);
  LLVMOpcode::from_int(opcode)
}

pub extern "C" fn llvm_align_of(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_align_of"

pub extern "C" fn llvm_size_of(ty: LLVMTypeRef) -> LLVMValueRef = "__llvm_size_of"

pub extern "C" fn llvm_const_neg(constant_val: LLVMValueRef) -> LLVMValueRef = "__llvm_const_neg"

pub extern "C" fn llvm_const_nsw_neg(constant_val: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nsw_neg"

pub extern "C" fn llvm_const_not(constant_val: LLVMValueRef) -> LLVMValueRef = "__llvm_const_not"

pub extern "C" fn llvm_const_add(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_add"

pub extern "C" fn llvm_const_nsw_add(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nsw_add"

pub extern "C" fn llvm_const_nuw_add(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nuw_add"

pub extern "C" fn llvm_const_sub(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_sub"

pub extern "C" fn llvm_const_nsw_sub(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nsw_sub"

pub extern "C" fn llvm_const_nuw_sub(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nuw_sub"

pub extern "C" fn llvm_const_mul(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_mul"

pub extern "C" fn llvm_const_nsw_mul(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nsw_mul"

pub extern "C" fn llvm_const_nuw_mul(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_nuw_mul"

pub extern "C" fn llvm_const_xor(lhs_constant: LLVMValueRef, rhs_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_xor"

pub extern "C" fn llvm_const_gep2(ty: LLVMTypeRef, constant_val: LLVMValueRef, constant_indices: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_gep2"

pub extern "C" fn llvm_const_in_bounds_gep2(ty: LLVMTypeRef, constant_val: LLVMValueRef, constant_indices: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_const_in_bounds_gep2"

pub extern "C" fn llvm_const_trunc(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_trunc"

pub extern "C" fn llvm_const_ptr_to_int(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_ptr_to_int"

pub extern "C" fn llvm_const_int_to_ptr(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_int_to_ptr"

pub extern "C" fn llvm_const_bit_cast(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_bit_cast"

pub extern "C" fn llvm_const_addr_space_cast(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_addr_space_cast"

pub extern "C" fn llvm_const_trunc_or_bit_cast(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_trunc_or_bit_cast"

pub extern "C" fn llvm_const_pointer_cast(constant_val: LLVMValueRef, to_type: LLVMTypeRef) -> LLVMValueRef = "__llvm_const_pointer_cast"

pub extern "C" fn llvm_const_extract_element(vector_constant: LLVMValueRef, index_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_extract_element"

pub extern "C" fn llvm_const_insert_element(vector_constant: LLVMValueRef, element_value_constant: LLVMValueRef, index_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_insert_element"

pub extern "C" fn llvm_const_shuffle_vector(vector_a_constant: LLVMValueRef, vector_b_constant: LLVMValueRef, mask_constant: LLVMValueRef) -> LLVMValueRef = "__llvm_const_shuffle_vector"

pub extern "C" fn llvm_block_address(f: LLVMValueRef, bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_block_address"

pub extern "C" fn llvm_get_block_address_function(block_addr: LLVMValueRef) -> LLVMValueRef = "__llvm_get_block_address_function"

pub extern "C" fn llvm_get_block_address_basic_block(block_addr: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_block_address_basic_block"

pub extern "C" fn llvm_const_inline_asm(ty: LLVMTypeRef, asm_string: CStr, constraints: CStr, has_side_effects: LLVMBool, is_align_stack: LLVMBool) -> LLVMValueRef = "__llvm_const_inline_asm"

pub extern "C" fn llvm_get_global_parent(global: LLVMValueRef) -> LLVMModuleRef = "__llvm_get_global_parent"

pub extern "C" fn llvm_is_declaration(global: LLVMValueRef) -> LLVMBool = "__llvm_is_declaration"

pub extern "C" fn llvm_get_linkage(global: LLVMValueRef) -> LLVMLinkage = "__llvm_get_linkage"

pub extern "C" fn llvm_set_linkage(global: LLVMValueRef, linkage: LLVMLinkage) = "__llvm_set_linkage"

pub extern "C" fn llvm_get_section(global: LLVMValueRef) -> CStr = "__llvm_get_section"

pub extern "C" fn llvm_set_section(global: LLVMValueRef, section: CStr) = "__llvm_set_section"

pub extern "C" fn llvm_get_visibility(global: LLVMValueRef) -> LLVMVisibility = "__llvm_get_visibility"

pub extern "C" fn llvm_set_visibility(global: LLVMValueRef, viz: LLVMVisibility) = "__llvm_set_visibility"

pub extern "C" fn llvm_get_dll_storage_class(global: LLVMValueRef) -> LLVMDLLStorageClass = "__llvm_get_dll_storage_class"

pub extern "C" fn llvm_get_unnamed_address(global: LLVMValueRef) -> LLVMUnnamedAddr = "__llvm_get_unnamed_address"

pub extern "C" fn llvm_set_unnamed_address(global: LLVMValueRef, unnamed_addr: LLVMUnnamedAddr) = "__llvm_set_unnamed_address"

pub extern "C" fn llvm_global_get_value_type(global: LLVMValueRef) -> LLVMTypeRef = "__llvm_global_get_value_type"

pub extern "C" fn llvm_has_unnamed_addr(global: LLVMValueRef) -> LLVMBool = "__llvm_has_unnamed_addr"

pub extern "C" fn llvm_set_unnamed_addr(global: LLVMValueRef, has_unnamed_addr: LLVMBool) = "__llvm_set_unnamed_addr"

pub extern "C" fn llvm_get_alignment(v: LLVMValueRef) -> UInt = "__llvm_get_alignment"

pub extern "C" fn llvm_set_alignment(v: LLVMValueRef, bytes: UInt) = "__llvm_set_alignment"

pub extern "C" fn llvm_global_set_metadata(global: LLVMValueRef, kind: UInt, md: LLVMMetadataRef) = "__llvm_global_set_metadata"

pub extern "C" fn llvm_global_erase_metadata(global: LLVMValueRef, kind: UInt) = "__llvm_global_erase_metadata"

pub extern "C" fn llvm_global_clear_metadata(global: LLVMValueRef) = "__llvm_global_clear_metadata"

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

pub extern "C" fn llvm_value_is_basic_block(val: LLVMValueRef) -> LLVMBool = "__llvm_value_is_basic_block"

pub extern "C" fn llvm_value_as_basic_block(val: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_value_as_basic_block"

pub extern "C" fn llvm_get_basic_block_name(bb: LLVMBasicBlockRef) -> CStr = "__llvm_get_basic_block_name"

pub extern "C" fn llvm_get_basic_block_parent(bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_get_basic_block_parent"

pub extern "C" fn llvm_get_basic_block_terminator(bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_get_basic_block_terminator"

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

pub extern "C" fn llvm_isa_terminator_inst(inst: LLVMValueRef) -> LLVMValueRef = "__llvm_isa_terminator_inst"

pub extern "C" fn llvm_get_num_arg_operands(instr: LLVMValueRef) -> UInt = "__llvm_get_num_arg_operands"

pub extern "C" fn llvm_set_instruction_call_conv(instr: LLVMValueRef, cc: UInt) = "__llvm_set_instruction_call_conv"

pub extern "C" fn llvm_get_instruction_call_conv(instr: LLVMValueRef) -> UInt = "__llvm_get_instruction_call_conv"

pub extern "C" fn llvm_set_instr_param_alignment(instr: LLVMValueRef, idx: LLVMAttributeIndex, align: UInt) = "__llvm_set_instr_param_alignment"

pub extern "C" fn llvm_add_call_site_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, a: LLVMAttributeRef) = "__llvm_add_call_site_attribute"

pub extern "C" fn llvm_get_call_site_attribute_count(c: LLVMValueRef, idx: LLVMAttributeIndex) -> UInt = "__llvm_get_call_site_attribute_count"

// pub extern "C" fn llvm_get_call_site_attributes(c: LLVMValueRef, idx: LLVMAttributeIndex, attrs: Ptr[LLVMAttributeRef]) = "__llvm_get_call_site_attributes"

pub extern "C" fn llvm_get_call_site_enum_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, kind_id: UInt) -> LLVMAttributeRef = "__llvm_get_call_site_enum_attribute"

pub extern "C" fn llvm_get_call_site_string_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, k: CStr, k_len: UInt) -> LLVMAttributeRef = "__llvm_get_call_site_string_attribute"

pub extern "C" fn llvm_remove_call_site_enum_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, kind_id: UInt) = "__llvm_remove_call_site_enum_attribute"

pub extern "C" fn llvm_remove_call_site_string_attribute(c: LLVMValueRef, idx: LLVMAttributeIndex, k: CStr, k_len: UInt) = "__llvm_remove_call_site_string_attribute"

pub extern "C" fn llvm_get_called_function_type(c: LLVMValueRef) -> LLVMTypeRef = "__llvm_get_called_function_type"

pub extern "C" fn llvm_get_called_value(instr: LLVMValueRef) -> LLVMValueRef = "__llvm_get_called_value"

pub extern "C" fn llvm_get_num_operand_bundles(c: LLVMValueRef) -> UInt = "__llvm_get_num_operand_bundles"

pub extern "C" fn llvm_get_operand_bundle_at_index(c: LLVMValueRef, index: UInt) -> LLVMOperandBundleRef = "__llvm_get_operand_bundle_at_index"

pub extern "C" fn llvm_is_tail_call(call_inst: LLVMValueRef) -> LLVMBool = "__llvm_is_tail_call"

pub extern "C" fn llvm_set_tail_call(call_inst: LLVMValueRef, is_tail_call: LLVMBool) = "__llvm_set_tail_call"

pub extern "C" fn llvm_get_tail_call_kind(call_inst: LLVMValueRef) -> LLVMTailCallKind = "__llvm_get_tail_call_kind"

pub extern "C" fn llvm_set_tail_call_kind(call_inst: LLVMValueRef, kind: LLVMTailCallKind) = "__llvm_set_tail_call_kind"

pub extern "C" fn llvm_get_normal_dest(invoke_inst: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_normal_dest"

pub extern "C" fn llvm_get_unwind_dest(invoke_inst: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_unwind_dest"

pub extern "C" fn llvm_set_normal_dest(invoke_inst: LLVMValueRef, b: LLVMBasicBlockRef) = "__llvm_set_normal_dest"

pub extern "C" fn llvm_set_unwind_dest(invoke_inst: LLVMValueRef, b: LLVMBasicBlockRef) = "__llvm_set_unwind_dest"

pub extern "C" fn llvm_get_call_br_default_dest(call_br: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_call_br_default_dest"

pub extern "C" fn llvm_get_call_br_num_indirect_dests(call_br: LLVMValueRef) -> UInt = "__llvm_get_call_br_num_indirect_dests"

pub extern "C" fn llvm_get_call_br_indirect_dest(call_br: LLVMValueRef, idx: UInt) -> LLVMBasicBlockRef = "__llvm_get_call_br_indirect_dest"

pub extern "C" fn llvm_get_num_successors(term: LLVMValueRef) -> UInt = "__llvm_get_num_successors"

pub extern "C" fn llvm_get_successor(term: LLVMValueRef, i: UInt) -> LLVMBasicBlockRef = "__llvm_get_successor"

pub extern "C" fn llvm_set_successor(term: LLVMValueRef, i: UInt, block: LLVMBasicBlockRef) = "__llvm_set_successor"

pub extern "C" fn llvm_is_conditional(branch: LLVMValueRef) -> LLVMBool = "__llvm_is_conditional"

pub extern "C" fn llvm_get_condition(branch: LLVMValueRef) -> LLVMValueRef = "__llvm_get_condition"

pub extern "C" fn llvm_set_condition(branch: LLVMValueRef, cond: LLVMValueRef) = "__llvm_set_condition"

pub extern "C" fn llvm_get_switch_default_dest(switch_instr: LLVMValueRef) -> LLVMBasicBlockRef = "__llvm_get_switch_default_dest"

pub extern "C" fn llvm_get_allocated_type(alloca: LLVMValueRef) -> LLVMTypeRef = "__llvm_get_allocated_type"

pub extern "C" fn llvm_is_in_bounds(gep: LLVMValueRef) -> LLVMBool = "__llvm_is_in_bounds"

pub extern "C" fn llvm_set_is_in_bounds(gep: LLVMValueRef, in_bounds: LLVMBool) = "__llvm_set_is_in_bounds"

pub extern "C" fn llvm_get_gep_source_element_type(gep: LLVMValueRef) -> LLVMTypeRef = "__llvm_get_gep_source_element_type"

pub extern "C" fn llvm_add_incoming(phi_node: LLVMValueRef, incoming_values: Array[LLVMValueRef], incoming_blocks: Array[LLVMBasicBlockRef], count: UInt) = "__llvm_add_incoming"

pub extern "C" fn llvm_count_incoming(phi_node: LLVMValueRef) -> UInt = "__llvm_count_incoming"

pub extern "C" fn llvm_get_incoming_value(phi_node: LLVMValueRef, index: UInt) -> LLVMValueRef = "__llvm_get_incoming_value"

pub extern "C" fn llvm_get_incoming_block(phi_node: LLVMValueRef, index: UInt) -> LLVMBasicBlockRef = "__llvm_get_incoming_block"

pub extern "C" fn llvm_get_num_indices(inst: LLVMValueRef) -> UInt = "__llvm_get_num_indices"

// FIXME: Not implemented
pub extern "C" fn llvm_get_indices(inst: LLVMValueRef) -> Array[UInt] = "__llvm_get_indices"

pub extern "C" fn llvm_create_builder_in_context(context: LLVMContextRef) -> LLVMBuilderRef = "__llvm_create_builder_in_context"

pub extern "C" fn llvm_create_builder() -> LLVMBuilderRef = "__llvm_create_builder"

pub extern "C" fn llvm_position_builder(builder: LLVMBuilderRef, block: LLVMBasicBlockRef, instr: LLVMValueRef) = "__llvm_position_builder"

pub extern "C" fn llvm_position_builder_before_dbg_records(builder: LLVMBuilderRef, block: LLVMBasicBlockRef, inst: LLVMValueRef) = "__llvm_position_builder_before_dbg_records"

pub extern "C" fn llvm_position_builder_before(builder: LLVMBuilderRef, instr: LLVMValueRef) = "__llvm_position_builder_before"

pub extern "C" fn llvm_position_builder_before_instr_and_dbg_records(builder: LLVMBuilderRef, instr: LLVMValueRef) = "__llvm_position_builder_before_instr_and_dbg_records"

pub extern "C" fn llvm_position_builder_at_end(builder: LLVMBuilderRef, block: LLVMBasicBlockRef) = "__llvm_position_builder_at_end"

pub extern "C" fn llvm_get_insert_block(builder: LLVMBuilderRef) -> LLVMBasicBlockRef = "__llvm_get_insert_block"

pub extern "C" fn llvm_clear_insertion_position(builder: LLVMBuilderRef) = "__llvm_clear_insertion_position"

pub extern "C" fn llvm_insert_into_builder(builder: LLVMBuilderRef, instr: LLVMValueRef) = "__llvm_insert_into_builder"

pub extern "C" fn llvm_insert_into_builder_with_name(builder: LLVMBuilderRef, instr: LLVMValueRef, name: CStr) = "__llvm_insert_into_builder_with_name"

pub extern "C" fn llvm_dispose_builder(builder: LLVMBuilderRef) = "__llvm_dispose_builder"

pub extern "C" fn llvm_get_current_debug_location2(builder: LLVMBuilderRef) -> LLVMMetadataRef = "__llvm_get_current_debug_location2"

pub extern "C" fn llvm_set_current_debug_location2(builder: LLVMBuilderRef, loc: LLVMMetadataRef) = "__llvm_set_current_debug_location2"

pub extern "C" fn llvm_set_inst_debug_location(builder: LLVMBuilderRef, inst: LLVMValueRef) = "__llvm_set_inst_debug_location"

pub extern "C" fn llvm_add_metadata_to_inst(builder: LLVMBuilderRef, inst: LLVMValueRef) = "__llvm_add_metadata_to_inst"

pub extern "C" fn llvm_builder_get_default_fp_math_tag(builder: LLVMBuilderRef) -> LLVMMetadataRef = "__llvm_builder_get_default_fp_math_tag"

pub extern "C" fn llvm_builder_set_default_fp_math_tag(builder: LLVMBuilderRef, fp_math_tag: LLVMMetadataRef) = "__llvm_builder_set_default_fp_math_tag"

pub extern "C" fn llvm_set_current_debug_location(builder: LLVMBuilderRef, l: LLVMValueRef) = "__llvm_set_current_debug_location"

pub extern "C" fn llvm_get_current_debug_location(builder: LLVMBuilderRef) -> LLVMValueRef = "__llvm_get_current_debug_location"

pub extern "C" fn llvm_build_ret_void(builder: LLVMBuilderRef) -> LLVMValueRef = "__llvm_build_ret_void"

pub extern "C" fn llvm_build_ret(builder: LLVMBuilderRef, v: LLVMValueRef) -> LLVMValueRef = "__llvm_build_ret"

pub extern "C" fn llvm_build_aggregate_ret(builder: LLVMBuilderRef, ret_vals: Array[LLVMValueRef]) -> LLVMValueRef = "__llvm_build_aggregate_ret"

pub extern "C" fn llvm_build_br(builder: LLVMBuilderRef, dest: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_build_br"

pub extern "C" fn llvm_build_cond_br(builder: LLVMBuilderRef, if_block: LLVMValueRef, then: LLVMBasicBlockRef, else_block: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_build_cond_br"

pub extern "C" fn llvm_build_switch(builder: LLVMBuilderRef, v: LLVMValueRef, else_block: LLVMBasicBlockRef, num_cases: UInt) -> LLVMValueRef = "__llvm_build_switch"

pub extern "C" fn llvm_build_indirect_br(builder: LLVMBuilderRef, addr: LLVMValueRef, num_dests: UInt) -> LLVMValueRef = "__llvm_build_indirect_br"

pub extern "C" fn llvm_build_call_br(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, default_dest: LLVMBasicBlockRef, indirect_dests: Array[LLVMBasicBlockRef], args: Array[LLVMValueRef], bundles: Array[LLVMOperandBundleRef], name: CStr) -> LLVMValueRef = "__llvm_build_call_br"

pub extern "C" fn llvm_build_invoke2(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], then: LLVMBasicBlockRef, catch_block: LLVMBasicBlockRef, name: CStr) -> LLVMValueRef = "__llvm_build_invoke2"

pub extern "C" fn llvm_build_invoke_with_operand_bundles(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], then: LLVMBasicBlockRef, catch_block: LLVMBasicBlockRef, bundles: Array[LLVMOperandBundleRef], name: CStr) -> LLVMValueRef = "__llvm_build_invoke_with_operand_bundles"

pub extern "C" fn llvm_build_unreachable(builder: LLVMBuilderRef) -> LLVMValueRef = "__llvm_build_unreachable"

pub extern "C" fn llvm_build_resume(builder: LLVMBuilderRef, exn: LLVMValueRef) -> LLVMValueRef = "__llvm_build_resume"

pub extern "C" fn llvm_build_landing_pad(builder: LLVMBuilderRef, ty: LLVMTypeRef, pers_fn: LLVMValueRef, num_clauses: UInt, name: CStr) -> LLVMValueRef = "__llvm_build_landing_pad"

pub extern "C" fn llvm_build_cleanup_ret(builder: LLVMBuilderRef, catch_pad: LLVMValueRef, bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_build_cleanup_ret"

pub extern "C" fn llvm_build_catch_ret(builder: LLVMBuilderRef, catch_pad: LLVMValueRef, bb: LLVMBasicBlockRef) -> LLVMValueRef = "__llvm_build_catch_ret"

pub extern "C" fn llvm_build_catch_pad(builder: LLVMBuilderRef, parent_pad: LLVMValueRef, args: Array[LLVMValueRef], name: CStr) -> LLVMValueRef = "__llvm_build_catch_pad"

pub extern "C" fn llvm_build_cleanup_pad(builder: LLVMBuilderRef, parent_pad: LLVMValueRef, args: Array[LLVMValueRef], name: CStr) -> LLVMValueRef = "__llvm_build_cleanup_pad"

pub extern "C" fn llvm_build_catch_switch(builder: LLVMBuilderRef, parent_pad: LLVMValueRef, unwind_bb: LLVMBasicBlockRef, num_handlers: UInt, name: CStr) -> LLVMValueRef = "__llvm_build_catch_switch"

pub extern "C" fn llvm_add_case(_switch: LLVMValueRef, on_val: LLVMValueRef, dest: LLVMBasicBlockRef) = "__llvm_add_case"

pub extern "C" fn llvm_add_destination(indirect_br: LLVMValueRef, dest: LLVMBasicBlockRef) = "__llvm_add_destination"

pub extern "C" fn llvm_get_num_clauses(landing_pad: LLVMValueRef) -> UInt = "__llvm_get_num_clauses"

pub extern "C" fn llvm_get_clause(landing_pad: LLVMValueRef, idx: UInt) -> LLVMValueRef = "__llvm_get_clause"

pub extern "C" fn llvm_add_clause(landing_pad: LLVMValueRef, clause_val: LLVMValueRef) = "__llvm_add_clause"

pub extern "C" fn llvm_is_cleanup(landing_pad: LLVMValueRef) -> LLVMBool = "__llvm_is_cleanup"

pub extern "C" fn llvm_set_cleanup(landing_pad: LLVMValueRef, val: LLVMBool) = "__llvm_set_cleanup"

pub extern "C" fn llvm_add_handler(catch_switch: LLVMValueRef, dest: LLVMBasicBlockRef) = "__llvm_add_handler"

pub extern "C" fn llvm_get_num_handlers(catch_switch: LLVMValueRef) -> UInt = "__llvm_get_num_handlers"

pub extern "C" fn llvm_get_handlers(catch_switch: LLVMValueRef) -> Array[LLVMBasicBlockRef] = "__llvm_get_handlers"

pub extern "C" fn llvm_get_arg_operand(funclet: LLVMValueRef, i: UInt) -> LLVMValueRef = "__llvm_get_arg_operand"

pub extern "C" fn llvm_set_arg_operand(funclet: LLVMValueRef, i: UInt, value: LLVMValueRef) = "__llvm_set_arg_operand"

pub extern "C" fn llvm_get_parent_catch_switch(catch_pad: LLVMValueRef) -> LLVMValueRef = "__llvm_get_parent_catch_switch"

pub extern "C" fn llvm_set_parent_catch_switch(catch_pad: LLVMValueRef, catch_switch: LLVMValueRef) = "__llvm_set_parent_catch_switch"

pub extern "C" fn llvm_build_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_add"

pub extern "C" fn llvm_build_nsw_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nsw_add"

pub extern "C" fn llvm_build_nuw_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nuw_add"

pub extern "C" fn llvm_build_f_add(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_add"

pub extern "C" fn llvm_build_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_sub"

pub extern "C" fn llvm_build_nsw_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nsw_sub"

pub extern "C" fn llvm_build_nuw_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nuw_sub"

pub extern "C" fn llvm_build_f_sub(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_sub"

pub extern "C" fn llvm_build_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_mul"

pub extern "C" fn llvm_build_nsw_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nsw_mul"

pub extern "C" fn llvm_build_nuw_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nuw_mul"

pub extern "C" fn llvm_build_f_mul(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_mul"

pub extern "C" fn llvm_build_u_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_u_div"

pub extern "C" fn llvm_build_exact_u_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_exact_u_div"

pub extern "C" fn llvm_build_s_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_s_div"

pub extern "C" fn llvm_build_exact_s_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_exact_s_div"

pub extern "C" fn llvm_build_f_div(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_div"

pub extern "C" fn llvm_build_u_rem(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_u_rem"

pub extern "C" fn llvm_build_s_rem(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_s_rem"

pub extern "C" fn llvm_build_f_rem(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_rem"

pub extern "C" fn llvm_build_shl(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_shl"

pub extern "C" fn llvm_build_l_shr(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_l_shr"

pub extern "C" fn llvm_build_a_shr(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_a_shr"

pub extern "C" fn llvm_build_and(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_and"

pub extern "C" fn llvm_build_or(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_or"

pub extern "C" fn llvm_build_xor(builder: LLVMBuilderRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_xor"

extern "C" fn __llvm_build_bin_op(builder: LLVMBuilderRef, op: Int, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_bin_op"
pub fn llvm_build_bin_op(builder: LLVMBuilderRef, op: LLVMOpcode, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef {
  let code = op.to_int()
  __llvm_build_bin_op(builder, code, lhs, rhs, name)
}

pub extern "C" fn llvm_build_neg(builder: LLVMBuilderRef, v: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_neg"

pub extern "C" fn llvm_build_nsw_neg(builder: LLVMBuilderRef, v: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_nsw_neg"

pub extern "C" fn llvm_build_f_neg(builder: LLVMBuilderRef, v: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_f_neg"

pub extern "C" fn llvm_build_not(builder: LLVMBuilderRef, v: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_not"

pub extern "C" fn llvm_get_nuw(arith_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_nuw"

pub extern "C" fn llvm_set_nuw(arith_inst: LLVMValueRef, has_nuw: LLVMBool) = "__llvm_set_nuw"

pub extern "C" fn llvm_get_nsw(arith_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_nsw"

pub extern "C" fn llvm_set_nsw(arith_inst: LLVMValueRef, has_nsw: LLVMBool) = "__llvm_set_nsw"

pub extern "C" fn llvm_get_exact(div_or_shr_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_exact"

pub extern "C" fn llvm_set_exact(div_or_shr_inst: LLVMValueRef, is_exact: LLVMBool) = "__llvm_set_exact"

pub extern "C" fn llvm_get_n_neg(non_neg_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_n_neg"

pub extern "C" fn llvm_set_n_neg(non_neg_inst: LLVMValueRef, is_non_neg: LLVMBool) = "__llvm_set_n_neg"

pub extern "C" fn llvm_get_fast_math_flags(fp_math_inst: LLVMValueRef) -> LLVMFastMathFlags = "__llvm_get_fast_math_flags"

pub extern "C" fn llvm_set_fast_math_flags(fp_math_inst: LLVMValueRef, fmf: LLVMFastMathFlags) = "__llvm_set_fast_math_flags"

pub extern "C" fn llvm_can_value_use_fast_math_flags(inst: LLVMValueRef) -> LLVMBool = "__llvm_can_value_use_fast_math_flags"

pub extern "C" fn llvm_get_is_disjoint(inst: LLVMValueRef) -> LLVMBool = "__llvm_get_is_disjoint"
pub fn LLVMValueRef::get_is_disjoint(self: LLVMValueRef) -> Bool {
  let is_disjoint = llvm_get_is_disjoint(self);
  to_moonbit_bool(is_disjoint)
}

extern "C" fn __llvm_set_is_disjoint(inst: LLVMValueRef, is_disjoint: LLVMBool) = "__llvm_set_is_disjoint"
pub fn llvm_set_is_disjoint(inst: LLVMValueRef, is_disjoint: Bool) -> Unit {
  __llvm_set_is_disjoint(inst, to_llvm_bool(is_disjoint))
}
pub fn LLVMValueRef::set_is_disjoint(self: LLVMValueRef, is_disjoint: Bool) -> Unit {
  llvm_set_is_disjoint(self, is_disjoint)
}

pub extern "C" fn llvm_build_malloc(builder: LLVMBuilderRef, ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_malloc"

pub extern "C" fn llvm_build_array_malloc(builder: LLVMBuilderRef, ty: LLVMTypeRef, val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_array_malloc"

pub extern "C" fn llvm_build_mem_set(builder: LLVMBuilderRef, ptr: LLVMValueRef, val: LLVMValueRef, len: LLVMValueRef, align: UInt) -> LLVMValueRef = "__llvm_build_mem_set"

pub extern "C" fn llvm_build_mem_cpy(builder: LLVMBuilderRef, dst: LLVMValueRef, dst_align: UInt, src: LLVMValueRef, src_align: UInt, size: LLVMValueRef) -> LLVMValueRef = "__llvm_build_mem_cpy"

pub extern "C" fn llvm_build_mem_move(builder: LLVMBuilderRef, dst: LLVMValueRef, dst_align: UInt, src: LLVMValueRef, src_align: UInt, size: LLVMValueRef) -> LLVMValueRef = "__llvm_build_mem_move"

pub extern "C" fn llvm_build_alloca(builder: LLVMBuilderRef, ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_alloca"

pub extern "C" fn llvm_build_array_alloca(builder: LLVMBuilderRef, ty: LLVMTypeRef, val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_array_alloca"

pub extern "C" fn llvm_build_free(builder: LLVMBuilderRef, pointer_val: LLVMValueRef) -> LLVMValueRef = "__llvm_build_free"

pub extern "C" fn llvm_build_load2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer_val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_load2"

pub extern "C" fn llvm_build_store(builder: LLVMBuilderRef, val: LLVMValueRef, ptr: LLVMValueRef) -> LLVMValueRef = "__llvm_build_store"

pub extern "C" fn llvm_build_gep2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, indices: Array[LLVMValueRef], name: CStr) -> LLVMValueRef = "__llvm_build_gep2"

pub extern "C" fn llvm_build_in_bounds_gep2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, indices: Array[LLVMValueRef], name: CStr) -> LLVMValueRef = "__llvm_build_in_bounds_gep2"

pub extern "C" fn llvm_build_struct_gep2(builder: LLVMBuilderRef, ty: LLVMTypeRef, pointer: LLVMValueRef, idx: UInt, name: CStr) -> LLVMValueRef = "__llvm_build_struct_gep2"

pub extern "C" fn llvm_build_global_string(builder: LLVMBuilderRef, str: CStr, name: CStr) -> LLVMValueRef = "__llvm_build_global_string"

pub extern "C" fn llvm_build_global_string_ptr(builder: LLVMBuilderRef, str: CStr, name: CStr) -> LLVMValueRef = "__llvm_build_global_string_ptr"

pub extern "C" fn llvm_get_volatile(memory_access_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_volatile"

extern "C" fn __llvm_set_volatile(memory_access_inst: LLVMValueRef, is_volatile: LLVMBool) = "__llvm_set_volatile"
pub fn llvm_set_volatile(memory_access_inst: LLVMValueRef, is_volatile: Bool) -> Unit {
  __llvm_set_volatile(memory_access_inst, to_llvm_bool(is_volatile))
}
pub fn LLVMValueRef::set_volatile(self: LLVMValueRef, is_volatile: Bool) -> Unit {
  llvm_set_volatile(self, is_volatile)
}


pub extern "C" fn llvm_get_weak(cmp_xchg_inst: LLVMValueRef) -> LLVMBool = "__llvm_get_weak"

pub extern "C" fn llvm_set_weak(cmp_xchg_inst: LLVMValueRef, is_weak: LLVMBool) = "__llvm_set_weak"

pub extern "C" fn llvm_get_ordering(memory_access_inst: LLVMValueRef) -> LLVMAtomicOrdering = "__llvm_get_ordering"

pub extern "C" fn llvm_set_ordering(memory_access_inst: LLVMValueRef, ordering: LLVMAtomicOrdering) = "__llvm_set_ordering"

pub extern "C" fn llvm_get_atomic_rmw_bin_op(atomic_rmw_inst: LLVMValueRef) -> LLVMAtomicRMWBinOp = "__llvm_get_atomic_rmw_bin_op"

pub extern "C" fn llvm_set_atomic_rmw_bin_op(atomic_rmw_inst: LLVMValueRef, bin_op: LLVMAtomicRMWBinOp) = "__llvm_set_atomic_rmw_bin_op"

pub extern "C" fn llvm_build_trunc(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_trunc"

pub extern "C" fn llvm_build_z_ext(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_z_ext"

pub extern "C" fn llvm_build_s_ext(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_s_ext"

pub extern "C" fn llvm_build_fp_to_ui(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_fp_to_ui"

pub extern "C" fn llvm_build_fp_to_si(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_fp_to_si"

pub extern "C" fn llvm_build_ui_to_fp(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_ui_to_fp"

pub extern "C" fn llvm_build_si_to_fp(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_si_to_fp"

pub extern "C" fn llvm_build_fp_trunc(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_fp_trunc"

pub extern "C" fn llvm_build_fp_ext(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_fp_ext"

pub extern "C" fn llvm_build_ptr_to_int(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_ptr_to_int"

pub extern "C" fn llvm_build_int_to_ptr(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_int_to_ptr"

pub extern "C" fn llvm_build_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_bit_cast"

pub extern "C" fn llvm_build_addr_space_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_addr_space_cast"

pub extern "C" fn llvm_build_z_ext_or_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_z_ext_or_bit_cast"

pub extern "C" fn llvm_build_s_ext_or_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_s_ext_or_bit_cast"

pub extern "C" fn llvm_build_trunc_or_bit_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_trunc_or_bit_cast"

extern "C" fn __llvm_build_cast(builder: LLVMBuilderRef, op: Int, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_cast"
pub fn llvm_build_cast(builder: LLVMBuilderRef, op: LLVMOpcode, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef {
  let code = op.to_int()
  __llvm_build_cast(builder, code, val, dest_ty, name)
}


pub extern "C" fn llvm_build_pointer_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_pointer_cast"

pub extern "C" fn llvm_build_int_cast2(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, is_signed: LLVMBool, name: CStr) -> LLVMValueRef = "__llvm_build_int_cast2"

pub extern "C" fn llvm_build_fp_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_fp_cast"

pub extern "C" fn llvm_build_int_cast(builder: LLVMBuilderRef, val: LLVMValueRef, dest_ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_int_cast"

extern "C" fn __llvm_get_cast_opcode(src: LLVMValueRef, src_is_signed: LLVMBool, dest_ty: LLVMTypeRef, dest_is_signed: LLVMBool) -> Int = "__llvm_get_cast_opcode"
pub fn llvm_get_cast_opcode(src: LLVMValueRef, src_is_signed: LLVMBool, dest_ty: LLVMTypeRef, dest_is_signed: LLVMBool) -> LLVMOpcode {
  let code = __llvm_get_cast_opcode(src, src_is_signed, dest_ty, dest_is_signed)
  LLVMOpcode::from_int(code)
}

extern "C" fn __llvm_build_icmp(builder: LLVMBuilderRef, op: Int, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_icmp"
pub fn llvm_build_icmp(builder: LLVMBuilderRef, op: LLVMIntPredicate, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef {
  let code = op.to_int()
  __llvm_build_icmp(builder, code, lhs, rhs, name)
}


extern "C" fn __llvm_build_fcmp(builder: LLVMBuilderRef, op: Int, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_fcmp"
pub fn llvm_build_fcmp(builder: LLVMBuilderRef, op: LLVMRealPredicate, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef {
  let code = op.to_int()
  __llvm_build_fcmp(builder, code, lhs, rhs, name)
}

pub extern "C" fn llvm_build_phi(builder: LLVMBuilderRef, ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_phi"

pub extern "C" fn llvm_build_call2(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], name: CStr) -> LLVMValueRef = "__llvm_build_call2"

pub extern "C" fn llvm_build_call_with_operand_bundles(builder: LLVMBuilderRef, ty: LLVMTypeRef, func: LLVMValueRef, args: Array[LLVMValueRef], bundles: Array[LLVMOperandBundleRef], name: CStr) -> LLVMValueRef = "__llvm_build_call_with_operand_bundles"

pub extern "C" fn llvm_build_select(builder: LLVMBuilderRef, if_block: LLVMValueRef, then: LLVMValueRef, else_block: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_select"

pub extern "C" fn llvm_build_va_arg(builder: LLVMBuilderRef, list: LLVMValueRef, ty: LLVMTypeRef, name: CStr) -> LLVMValueRef = "__llvm_build_va_arg"

pub extern "C" fn llvm_build_extract_element(builder: LLVMBuilderRef, vec_val: LLVMValueRef, index: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_extract_element"

pub extern "C" fn llvm_build_insert_element(builder: LLVMBuilderRef, vec_val: LLVMValueRef, elt_val: LLVMValueRef, index: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_insert_element"

pub extern "C" fn llvm_build_shuffle_vector(builder: LLVMBuilderRef, v1: LLVMValueRef, v2: LLVMValueRef, mask: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_shuffle_vector"

pub extern "C" fn llvm_build_extract_value(builder: LLVMBuilderRef, agg_val: LLVMValueRef, index: UInt, name: CStr) -> LLVMValueRef = "__llvm_build_extract_value"

pub extern "C" fn llvm_build_insert_value(builder: LLVMBuilderRef, agg_val: LLVMValueRef, elt_val: LLVMValueRef, index: UInt, name: CStr) -> LLVMValueRef = "__llvm_build_insert_value"

pub extern "C" fn llvm_build_freeze(builder: LLVMBuilderRef, val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_freeze"

pub extern "C" fn llvm_build_is_null(builder: LLVMBuilderRef, val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_is_null"

pub extern "C" fn llvm_build_is_not_null(builder: LLVMBuilderRef, val: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_is_not_null"

pub extern "C" fn llvm_build_ptr_diff2(builder: LLVMBuilderRef, elem_ty: LLVMTypeRef, lhs: LLVMValueRef, rhs: LLVMValueRef, name: CStr) -> LLVMValueRef = "__llvm_build_ptr_diff2"

extern "C" fn __llvm_build_fence(builder: LLVMBuilderRef, ordering: Int, single_thread: LLVMBool, name: CStr) -> LLVMValueRef = "__llvm_build_fence"
pub fn llvm_build_fence(builder: LLVMBuilderRef, ordering: LLVMAtomicOrdering, single_thread: LLVMBool, name: CStr) -> LLVMValueRef {
  let code = ordering.to_int()
  __llvm_build_fence(builder, code, single_thread, name)
}

extern "C" fn __llvm_build_atomic_rmw(builder: LLVMBuilderRef, op: Int, ptr: LLVMValueRef, val: LLVMValueRef, ordering: Int, single_thread: LLVMBool) -> LLVMValueRef = "__llvm_build_atomic_rmw"
pub fn llvm_build_atomic_rmw(builder: LLVMBuilderRef, op: LLVMAtomicRMWBinOp, ptr: LLVMValueRef, val: LLVMValueRef, ordering: LLVMAtomicOrdering, single_thread: LLVMBool) -> LLVMValueRef {
  let op = op.to_int()
  let ordering = ordering.to_int()
  __llvm_build_atomic_rmw(builder, op, ptr, val, ordering, single_thread)
}

extern "C" fn __llvm_build_atomic_cmp_xchg(builder: LLVMBuilderRef, ptr: LLVMValueRef, cmp: LLVMValueRef, _new: LLVMValueRef, success_ordering: Int, failure_ordering: Int, single_thread: LLVMBool) -> LLVMValueRef = "__llvm_build_atomic_cmp_xchg"
pub fn llvm_build_atomic_cmp_xchg(builder: LLVMBuilderRef, ptr: LLVMValueRef, cmp: LLVMValueRef, _new: LLVMValueRef, success_ordering: LLVMAtomicOrdering, failure_ordering: LLVMAtomicOrdering, single_thread: LLVMBool) -> LLVMValueRef {
  let success_ordering = success_ordering.to_int()
  let failure_ordering = failure_ordering.to_int()
  __llvm_build_atomic_cmp_xchg(builder, ptr, cmp, _new, success_ordering, failure_ordering, single_thread)
}

pub extern "C" fn llvm_get_num_mask_elements(shuffle_vector_inst: LLVMValueRef) -> UInt = "__llvm_get_num_mask_elements"

pub extern "C" fn llvm_get_undef_mask_elem() -> Int = "__llvm_get_undef_mask_elem"

pub extern "C" fn llvm_get_mask_value(shuffle_vector_inst: LLVMValueRef, elt: UInt) -> Int = "__llvm_get_mask_value"

pub extern "C" fn llvm_is_atomic_single_thread(atomic_inst: LLVMValueRef) -> LLVMBool = "__llvm_is_atomic_single_thread"

pub extern "C" fn llvm_set_atomic_single_thread(atomic_inst: LLVMValueRef, single_thread: LLVMBool) = "__llvm_set_atomic_single_thread"

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

pub extern "C" fn llvm_create_memory_buffer_with_contents_of_file(path: CStr, out_mem_buf: LLVMMemoryBufferRef, out_message: CStr) -> LLVMBool = "__llvm_create_memory_buffer_with_contents_of_file"

pub extern "C" fn llvm_create_memory_buffer_with_stdin(out_mem_buf: LLVMMemoryBufferRef, out_message: CStr) -> LLVMBool = "__llvm_create_memory_buffer_with_stdin"

pub extern "C" fn llvm_create_memory_buffer_with_memory_range(input_data: CStr, input_data_length: Int, buffer_name: CStr, requires_null_terminator: LLVMBool) -> LLVMMemoryBufferRef = "__llvm_create_memory_buffer_with_memory_range"

pub extern "C" fn llvm_create_memory_buffer_with_memory_range_copy(input_data: CStr, input_data_length: Int, buffer_name: CStr) -> LLVMMemoryBufferRef = "__llvm_create_memory_buffer_with_memory_range_copy"

pub extern "C" fn llvm_get_buffer_start(mem_buf: LLVMMemoryBufferRef) -> CStr = "__llvm_get_buffer_start"

pub extern "C" fn llvm_get_buffer_size(mem_buf: LLVMMemoryBufferRef) -> Int = "__llvm_get_buffer_size"

pub extern "C" fn llvm_dispose_memory_buffer(mem_buf: LLVMMemoryBufferRef) = "__llvm_dispose_memory_buffer"

pub extern "C" fn llvm_create_pass_manager() -> LLVMPassManagerRef = "__llvm_create_pass_manager"

pub extern "C" fn llvm_create_function_pass_manager_for_module(m: LLVMModuleRef) -> LLVMPassManagerRef = "__llvm_create_function_pass_manager_for_module"

pub extern "C" fn llvm_create_function_pass_manager(mp: LLVMModuleProviderRef) -> LLVMPassManagerRef = "__llvm_create_function_pass_manager"

pub extern "C" fn llvm_run_pass_manager(pm: LLVMPassManagerRef, m: LLVMModuleRef) -> LLVMBool = "__llvm_run_pass_manager"

pub extern "C" fn llvm_initialize_function_pass_manager(fpm: LLVMPassManagerRef) -> LLVMBool = "__llvm_initialize_function_pass_manager"

pub extern "C" fn llvm_run_function_pass_manager(fpm: LLVMPassManagerRef, f: LLVMValueRef) -> LLVMBool = "__llvm_run_function_pass_manager"

pub extern "C" fn llvm_finalize_function_pass_manager(fpm: LLVMPassManagerRef) -> LLVMBool = "__llvm_finalize_function_pass_manager"

pub extern "C" fn llvm_dispose_pass_manager(pm: LLVMPassManagerRef) = "__llvm_dispose_pass_manager"

pub extern "C" fn llvm_start_multithreaded() -> LLVMBool = "__llvm_start_multithreaded"

pub extern "C" fn llvm_stop_multithreaded() = "__llvm_stop_multithreaded"

pub extern "C" fn llvm_is_multithreaded() -> LLVMBool = "__llvm_is_multithreaded"

