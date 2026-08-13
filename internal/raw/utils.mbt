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
extern "C" fn LLVMOrcLLJITRef::null() -> LLVMOrcLLJITRef = "__llvm_new_null"

///|
extern "C" fn LLVMOrcThreadSafeModuleRef::null() -> LLVMOrcThreadSafeModuleRef = "__llvm_new_null"

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
/// Tests whether `ty` is the null pointer sentinel.
///
/// **LLVM API:** Binding helper `__llvm_type_is_null`; returns nonzero for a
/// null raw handle. It does not validate the lifetime of a non-null handle.
pub extern "C" fn llvm_type_is_null(ty : LLVMTypeRef) -> LLVMBool = "__llvm_type_is_null"

///|
/// Returns true when this raw type handle is the null pointer sentinel.
pub fn LLVMTypeRef::is_null(self : LLVMTypeRef) -> Bool {
  llvm_type_is_null(self).to_moonbit_bool()
}

///|
/// Returns true when this raw type handle is not the null pointer sentinel.
pub fn LLVMTypeRef::is_not_null(self : LLVMTypeRef) -> Bool {
  !llvm_type_is_null(self).to_moonbit_bool()
}

///|
/// Tests whether `ty` is an LLVM null constant, not whether the handle is null.
///
/// **LLVM API:** Direct binding to `LLVMIsNull`. Passing a null or invalid handle
/// is outside the LLVM-C contract; use `llvm_value_ref_is_null` for pointer
/// nullness.
pub extern "C" fn llvm_value_is_null(ty : LLVMValueRef) -> LLVMBool = "LLVMIsNull"

///|
/// Tests whether `ty` is the null pointer sentinel.
///
/// **LLVM API:** Binding helper `__llvm_value_ref_is_null`. This is distinct
/// from `LLVMIsNull`, which inspects a valid LLVM value.
pub extern "C" fn llvm_value_ref_is_null(ty : LLVMValueRef) -> Bool = "__llvm_value_ref_is_null"

///|
/// Returns true when this raw value handle is the null pointer sentinel.
pub fn LLVMValueRef::is_null(self : LLVMValueRef) -> Bool {
  llvm_value_ref_is_null(self)
}

///|
/// Returns true when this raw value handle is not the null pointer sentinel.
pub fn LLVMValueRef::is_not_null(self : LLVMValueRef) -> Bool {
  !llvm_value_ref_is_null(self)
}

///|
/// Tests whether `u` is the null pointer sentinel.
///
/// **LLVM API:** Binding helper `__llvm_use_is_null`; it does not validate a
/// non-null use or extend the lifetime of its parent IR.
pub extern "C" fn llvm_use_is_null(u : LLVMUseRef) -> LLVMBool = "__llvm_use_is_null"

///|
/// Returns true when this raw use handle is the null pointer sentinel.
pub fn LLVMUseRef::is_null(self : LLVMUseRef) -> Bool {
  llvm_use_is_null(self).to_moonbit_bool()
}

///|
/// Returns true when this raw use handle is not the null pointer sentinel.
pub fn LLVMUseRef::is_not_null(self : LLVMUseRef) -> Bool {
  !llvm_use_is_null(self).to_moonbit_bool()
}

///|
/// Tests whether `bb` is the null pointer sentinel.
///
/// **LLVM API:** Binding helper `__llvm_bb_is_null`; it does not validate the
/// lifetime or parent of a non-null basic block.
pub extern "C" fn llvm_bb_is_null(bb : LLVMBasicBlockRef) -> Bool = "__llvm_bb_is_null"

///|
/// Returns true when this raw basic-block handle is the null pointer sentinel.
pub fn LLVMBasicBlockRef::is_null(self : LLVMBasicBlockRef) -> Bool {
  llvm_bb_is_null(self)
}

///|
/// Returns true when this raw basic-block handle is not the null pointer sentinel.
pub fn LLVMBasicBlockRef::is_not_null(self : LLVMBasicBlockRef) -> Bool {
  !llvm_bb_is_null(self)
}

///|
/// Tests whether `attr` is the null pointer sentinel.
///
/// **LLVM API:** Binding helper `__llvm_attr_is_null`; it does not validate a
/// non-null attribute or retain its Context.
pub extern "C" fn llvm_attr_is_null(attr : LLVMAttributeRef) -> LLVMBool = "__llvm_attr_is_null"

///|
/// Returns true when this raw attribute handle is the null pointer sentinel.
pub fn LLVMAttributeRef::is_null(self : LLVMAttributeRef) -> Bool {
  llvm_attr_is_null(self).to_moonbit_bool()
}

///|
/// Returns true when this raw attribute handle is not the null pointer sentinel.
pub fn LLVMAttributeRef::is_not_null(self : LLVMAttributeRef) -> Bool {
  !llvm_attr_is_null(self).to_moonbit_bool()
}

///|
/// Tests whether `comdat` is the null pointer sentinel.
///
/// **LLVM API:** Binding helper `__llvm_comdat_is_null`; it does not validate a
/// non-null COMDAT or retain its Module.
pub extern "C" fn llvm_comdat_is_null(comdat : LLVMComdatRef) -> LLVMBool = "__llvm_comdat_is_null"

///|
/// Returns true when this raw COMDAT handle is the null pointer sentinel.
pub fn LLVMComdatRef::is_null(self : LLVMComdatRef) -> Bool {
  llvm_comdat_is_null(self).to_moonbit_bool()
}

///|
/// Returns true when this raw COMDAT handle is not the null pointer sentinel.
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
/// Prints LLVM's textual spelling of the referenced type.
///
/// This dereferences the handle; null, dangling, or otherwise invalid handles
/// are outside the LLVM-C contract. Printing failure produces a diagnostic
/// placeholder rather than raising.
pub impl Show for LLVMTypeRef with fn output(self, logger) {
  let s = llvm_print_type_to_string(self) catch {
    error => "<LLVM type text unavailable: \{error}>"
  }
  logger.write_string(s)
}

///|
/// Prints LLVM's textual spelling of the referenced value or IR object.
///
/// This dereferences the handle; null, dangling, or otherwise invalid handles
/// are outside the LLVM-C contract. Printing failure produces a diagnostic
/// placeholder rather than raising.
pub impl Show for LLVMValueRef with fn output(self, logger) {
  let s = llvm_print_value_to_string(self) catch {
    error => "<LLVM value text unavailable: \{error}>"
  }
  logger.write_string(s)
}
