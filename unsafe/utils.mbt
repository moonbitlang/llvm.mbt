type CStr

extern "C" fn moonbit_str_to_c_str(
  s: String
) -> CStr = "moonbit_str_to_c_str"
extern "C" fn c_str_to_moonbit_str(
  s: CStr
) -> String = "c_str_to_moonbit_str"
extern "C" fn c_str_to_moonbit_str_with_length(
  s: CStr,
  len: UInt
) -> String = "c_str_to_moonbit_str_with_length"

extern "C" fn CStr::new() -> CStr = "new_null_cstr"

extern "C" fn CStr::create_null() -> CStr = "new_null_cstr"

extern "C" fn CStr::free(self: CStr) = "free_cstr"

fn CStr::from(s: String) -> CStr {
  moonbit_str_to_c_str(s)
}

fn CStr::to_string(self: CStr, length~ : UInt? = None) -> String {
  match length {
    Some(l) => c_str_to_moonbit_str_with_length(self, l)
    None => c_str_to_moonbit_str(self)
  }
}

extern "C" fn llvm_new_null_type_ref() -> LLVMTypeRef = "__llvm_new_null_type_ref"

extern "C" fn llvm_new_null_value_ref() -> LLVMValueRef = "__llvm_new_null_value_ref"

extern "C" fn llvm_new_null_module_ref() -> LLVMModuleRef = "__llvm_new_null_module_ref"

fn LLVMTypeRef::null() -> LLVMTypeRef {
  llvm_new_null_type_ref()
}

fn LLVMValueRef::null() -> LLVMValueRef {
  llvm_new_null_value_ref()
}

fn LLVMModuleRef::null() -> LLVMModuleRef {
  llvm_new_null_module_ref()
}


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

extern "C" fn llvm_same_attr_ref(attr1: LLVMAttributeRef, attr2: LLVMAttributeRef) -> LLVMBool = "__llvm_same_attr_ref"
fn LLVMAttributeRef::is_equal(self: LLVMAttributeRef, other: LLVMAttributeRef) -> Bool {
  llvm_same_attr_ref(self, other).to_moonbit_bool()
}

pub extern "C" fn llvm_type_is_null(ty: LLVMTypeRef) -> LLVMBool = "__llvm_type_is_null"
pub fn LLVMTypeRef::is_null(self: LLVMTypeRef) -> Bool {
  llvm_type_is_null(self).to_moonbit_bool()
}

pub extern "C" fn llvm_value_is_null(ty: LLVMValueRef) -> LLVMBool = "__llvm_value_is_null"
pub fn LLVMValueRef::is_null(self: LLVMValueRef) -> Bool {
  llvm_value_is_null(self).to_moonbit_bool()
}

pub extern "C" fn llvm_use_is_null(u: LLVMUseRef) -> LLVMBool = "__llvm_use_is_null"
pub fn LLVMUseRef::is_null(self: LLVMUseRef) -> Bool {
  llvm_use_is_null(self).to_moonbit_bool()
}

pub extern "C" fn llvm_bb_is_null(bb: LLVMBasicBlockRef) -> LLVMBool = "__llvm_bb_is_null"
pub fn LLVMBasicBlockRef::is_null(self: LLVMBasicBlockRef) -> Bool {
  llvm_bb_is_null(self).to_moonbit_bool()
}

pub extern "C" fn llvm_attr_is_null(attr: LLVMAttributeRef) -> LLVMBool = "__llvm_attr_is_null"
pub fn LLVMAttributeRef::is_null(self: LLVMAttributeRef) -> Bool {
  llvm_attr_is_null(self).to_moonbit_bool()
}

pub extern "C" fn llvm_comdat_is_null(comdat: LLVMComdatRef) -> LLVMBool = "__llvm_comdat_is_null"
pub fn LLVMComdatRef::is_null(self: LLVMComdatRef) -> Bool {
  llvm_comdat_is_null(self).to_moonbit_bool()
}

fn LLVMBool::into(self: LLVMBool) -> Bool {
  self.to_moonbit_bool()
}

fn to_moonbit_bool(self: LLVMBool) -> Bool {
  self != 0
}

fn to_llvm_bool(b: Bool) -> LLVMBool {
  b.to_int()
}

