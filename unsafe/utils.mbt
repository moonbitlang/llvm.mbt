type CStr

extern "C" fn CStr::new() -> CStr = "new_null_cstr"

extern "C" fn CStr::create_null() -> CStr = "new_null_cstr"

extern "C" fn CStr::free(self: CStr) = "free_cstr"

fn CStr::to_string(self: CStr) -> String {
  c_str_to_moonbit_str(self)
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

fn LLVMBool::into(self: LLVMBool) -> Bool {
  self.to_moonbit_bool()
}

fn to_moonbit_bool(self: LLVMBool) -> Bool {
  self != 0
}

fn to_llvm_bool(b: Bool) -> LLVMBool {
  b.to_int()
}

