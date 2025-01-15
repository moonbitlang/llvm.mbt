// Context
struct Context {
  context: LLVMContextRef
}

pub fn Context::create() -> Context {
  Context :: {
    context: llvm_context_create()
  }
}

pub fn i32_type(self: Context) -> IntType {
  let type_ref = llvm_int32_type_in_context(self.context)
  IntType::new(type_ref)
}

