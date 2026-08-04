///|
/// Raw input retained only by the deferred MemoryBuffer boundary.
///
/// `LLVMCreateMemoryBufferWithMemoryRange` keeps its input pointer after the
/// call, so call-scoped MoonBit-managed UTF-8 bytes cannot be used here.
#external
priv type DeferredMemoryBufferInput

///|
/// Raw borrowed bytes retained only by the deferred non-text output boundary.
#external
priv type DeferredBorrowedBytes

///|
#borrow(s)
extern "C" fn DeferredMemoryBufferInput::from_string(
  s : String,
) -> DeferredMemoryBufferInput = "llvm_mbt_deferred_memory_buffer_input"

///|
extern "C" fn DeferredBorrowedBytes::to_string(
  self : DeferredBorrowedBytes,
) -> String = "llvm_mbt_deferred_borrowed_bytes_to_string"

///|
extern "C" fn DeferredBorrowedBytes::to_string_with_length(
  self : DeferredBorrowedBytes,
  length : UInt,
) -> String = "llvm_mbt_deferred_borrowed_bytes_to_string_with_length"

// extern "C" fn llvm_new_null_type_ref() -> LLVMTypeRef = "__llvm_new_null_type_ref"
//
// extern "C" fn llvm_new_null_value_ref() -> LLVMValueRef = "__llvm_new_null_value_ref"
//
// extern "C" fn llvm_new_null_module_ref() -> LLVMModuleRef = "__llvm_new_null_module_ref"

// fn LLVMTypeRef::null() -> LLVMTypeRef {
//   llvm_new_null_type_ref()
// }
//
// fn LLVMValueRef::null() -> LLVMValueRef {
//   llvm_new_null_value_ref()
// }
//
// fn LLVMModuleRef::null() -> LLVMModuleRef {
//   llvm_new_null_module_ref()
// }

///|
extern "C" fn LLVMTypeRef::null() -> LLVMTypeRef = "__llvm_new_null"

///|
extern "C" fn LLVMValueRef::null() -> LLVMValueRef = "__llvm_new_null"

///|
extern "C" fn LLVMModuleRef::null() -> LLVMModuleRef = "__llvm_new_null"

///|
extern "C" fn LLVMBasicBlockRef::null() -> LLVMBasicBlockRef = "__llvm_new_null"

///|
extern "C" fn LLVMTargetRef::null() -> LLVMTargetRef = "__llvm_new_null"

///|
extern "C" fn llvm_same_type_ref(
  ty1 : LLVMTypeRef,
  ty2 : LLVMTypeRef,
) -> LLVMBool = "__llvm_same_type_ref"

///|
fn LLVMTypeRef::is_equal(self : LLVMTypeRef, other : LLVMTypeRef) -> Bool {
  llvm_same_type_ref(self, other).to_moonbit_bool()
}

///|
extern "C" fn llvm_same_value_ref(
  val1 : LLVMValueRef,
  val2 : LLVMValueRef,
) -> LLVMBool = "__llvm_same_value_ref"

///|
fn LLVMValueRef::is_equal(self : LLVMValueRef, other : LLVMValueRef) -> Bool {
  llvm_same_value_ref(self, other).to_moonbit_bool()
}

///|
extern "C" fn llvm_same_ctx_ref(
  ctx1 : LLVMContextRef,
  ctx2 : LLVMContextRef,
) -> LLVMBool = "__llvm_same_ctx_ref"

///|
fn LLVMContextRef::is_equal(
  self : LLVMContextRef,
  other : LLVMContextRef,
) -> Bool {
  llvm_same_ctx_ref(self, other).to_moonbit_bool()
}

///|
extern "C" fn llvm_same_attr_ref(
  attr1 : LLVMAttributeRef,
  attr2 : LLVMAttributeRef,
) -> LLVMBool = "__llvm_same_attr_ref"

///|
fn LLVMAttributeRef::is_equal(
  self : LLVMAttributeRef,
  other : LLVMAttributeRef,
) -> Bool {
  llvm_same_attr_ref(self, other).to_moonbit_bool()
}

///|
extern "C" fn llvm_same_bb_ref(
  bb1 : LLVMBasicBlockRef,
  bb2 : LLVMBasicBlockRef,
) -> LLVMBool = "__llvm_same_bb_ref"

///|
fn LLVMBasicBlockRef::is_equal(
  self : LLVMBasicBlockRef,
  other : LLVMBasicBlockRef,
) -> Bool {
  llvm_same_bb_ref(self, other).to_moonbit_bool()
}

///|
pub extern "C" fn llvm_type_is_null(ty : LLVMTypeRef) -> LLVMBool = "__llvm_type_is_null"

///|
pub fn LLVMTypeRef::is_null(self : LLVMTypeRef) -> Bool {
  llvm_type_is_null(self).to_moonbit_bool()
}

///|
pub fn LLVMTypeRef::is_not_null(self : LLVMTypeRef) -> Bool {
  !llvm_type_is_null(self).to_moonbit_bool()
}

///|
pub extern "C" fn llvm_value_is_null(ty : LLVMValueRef) -> LLVMBool = "LLVMIsNull"

///|
pub extern "C" fn llvm_value_ref_is_null(ty : LLVMValueRef) -> Bool = "__llvm_value_ref_is_null"

///|
extern "C" fn llvm_error_is_null(ty : LLVMErrorRef) -> Bool = "ref_is_null"

///|
pub fn LLVMValueRef::is_null(self : LLVMValueRef) -> Bool {
  llvm_value_ref_is_null(self)
}

///|
pub fn LLVMValueRef::is_not_null(self : LLVMValueRef) -> Bool {
  !llvm_value_ref_is_null(self)
}

///|
pub extern "C" fn llvm_use_is_null(u : LLVMUseRef) -> LLVMBool = "__llvm_use_is_null"

///|
pub fn LLVMUseRef::is_null(self : LLVMUseRef) -> Bool {
  llvm_use_is_null(self).to_moonbit_bool()
}

///|
pub fn LLVMUseRef::is_not_null(self : LLVMUseRef) -> Bool {
  !llvm_use_is_null(self).to_moonbit_bool()
}

///|
pub extern "C" fn llvm_bb_is_null(bb : LLVMBasicBlockRef) -> Bool = "__llvm_bb_is_null"

///|
pub fn LLVMBasicBlockRef::is_null(self : LLVMBasicBlockRef) -> Bool {
  llvm_bb_is_null(self)
}

///|
pub fn LLVMBasicBlockRef::is_not_null(self : LLVMBasicBlockRef) -> Bool {
  !llvm_bb_is_null(self)
}

///|
pub extern "C" fn llvm_attr_is_null(attr : LLVMAttributeRef) -> LLVMBool = "__llvm_attr_is_null"

///|
pub fn LLVMAttributeRef::is_null(self : LLVMAttributeRef) -> Bool {
  llvm_attr_is_null(self).to_moonbit_bool()
}

///|
pub fn LLVMAttributeRef::is_not_null(self : LLVMAttributeRef) -> Bool {
  !llvm_attr_is_null(self).to_moonbit_bool()
}

///|
pub extern "C" fn llvm_comdat_is_null(comdat : LLVMComdatRef) -> LLVMBool = "__llvm_comdat_is_null"

///|
pub fn LLVMComdatRef::is_null(self : LLVMComdatRef) -> Bool {
  llvm_comdat_is_null(self).to_moonbit_bool()
}

///|
pub fn LLVMComdatRef::is_not_null(self : LLVMComdatRef) -> Bool {
  !llvm_comdat_is_null(self).to_moonbit_bool()
}

///|
fn LLVMBool::into(self : LLVMBool) -> Bool {
  self.to_moonbit_bool()
}

///|
fn LLVMBool::to_moonbit_bool(self : LLVMBool) -> Bool {
  self != 0
}

///|
fn to_llvm_bool(b : Bool) -> LLVMBool {
  b.to_int()
}

///|
pub impl Show for LLVMTypeRef with fn output(self, logger) {
  let s = llvm_print_type_to_string(self) catch {
    error => "<LLVM type text unavailable: \{error}>"
  }
  logger.write_string(s)
}

///|
pub impl Show for LLVMValueRef with fn output(self, logger) {
  let s = llvm_print_value_to_string(self) catch {
    error => "<LLVM value text unavailable: \{error}>"
  }
  logger.write_string(s)
}
