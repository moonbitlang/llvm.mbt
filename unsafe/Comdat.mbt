// =======================================================
// Comdat.h
// =======================================================

///| Return the Comdat in the module with the specified name.
///
/// Return the Comdat in the module with the specified name. It is created
/// if it didn't already exist.
/// 
/// - see llvm::Module::getOrInsertComdat()
extern "C" fn __llvm_get_or_insert_comdat(
  m : LLVMModuleRef,
  name : CStr
) -> LLVMComdatRef = "__llvm_get_or_insert_comdat"

///|
pub fn llvm_get_or_insert_comdat(
  m : LLVMModuleRef,
  name : String
) -> LLVMComdatRef {
  let name = moonbit_str_to_c_str(name)
  __llvm_get_or_insert_comdat(m, name)
}

///|
pub fn LLVMModuleRef::get_or_insert_comdat(
  self : LLVMModuleRef,
  name : String
) -> LLVMComdatRef {
  let name = moonbit_str_to_c_str(name)
  __llvm_get_or_insert_comdat(self, name)
}

///| Get the Comdat assigned to the given global object.
/// 
/// - see llvm::GlobalObject::getComdat()
pub extern "C" fn llvm_get_comdat(v : LLVMValueRef) -> LLVMComdatRef = "__llvm_get_comdat"

///| Assign the Comdat to the given global object.
/// 
/// - see llvm::GlobalObject::setComdat()
pub extern "C" fn llvm_set_comdat(v : LLVMValueRef, c : LLVMComdatRef) = "__llvm_set_comdat"

///| Get the conflict resolution selection kind for the Comdat.
/// 
/// - see llvm::Comdat::getSelectionKind()
extern "C" fn __llvm_get_comdat_selection_kind(c : LLVMComdatRef) -> Int = "__llvm_get_comdat_selection_kind"

///|
pub fn llvm_get_comdat_selection_kind(
  c : LLVMComdatRef
) -> LLVMComdatSelectionKind {
  let kind = __llvm_get_comdat_selection_kind(c)
  let kind = LLVMComdatSelectionKind::from_int(kind)
  kind
}

///| Set the conflict resolution selection kind for the Comdat.
/// 
/// - see llvm::Comdat::setSelectionKind()
extern "C" fn __llvm_set_comdat_selection_kind(c : LLVMComdatRef, kind : Int) = "__llvm_set_comdat_selection_kind"

///|
pub fn llvm_set_comdat_selection_kind(
  c : LLVMComdatRef,
  kind : LLVMComdatSelectionKind
) -> Unit {
  let i = kind.to_int()
  __llvm_set_comdat_selection_kind(c, i)
}
