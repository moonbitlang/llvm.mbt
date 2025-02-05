type CStr

extern "C" fn CStr::new() -> CStr = "new_null_cstr"

extern "C" fn CStr::free(self: CStr) = "free_cstr"

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

extern "C" fn llvm_same_attr_ref(attr1: LLVMAttributeRef, attr2: LLVMAttributeRef) -> LLVMBool = "__llvm_same_attr_ref"
fn LLVMAttributeRef::is_equal(self: LLVMAttributeRef, other: LLVMAttributeRef) -> Bool {
  llvm_same_attr_ref(self, other).to_moonbit_bool()
}

fn to_moonbit_bool(self: LLVMBool) -> Bool {
  if self == 0 {
    false
  } else {
    true
  }
}

fn to_llvm_bool(b: Bool) -> LLVMBool {
  if b {
    1
  } else {
    0
  }
}

