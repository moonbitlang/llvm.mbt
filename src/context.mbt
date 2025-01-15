// Context
struct Context {
  ctx_ref: LLVMContextRef
}

fn as_context_ref(self: Context) -> LLVMContextRef {
  self.ctx_ref
}

pub fn Context::create() -> Context {
  Context :: {
    ctx_ref: llvm_context_create()
  }
}

pub fn i32_type(self: Context) -> IntType {
  let type_ref = llvm_int32_type_in_context(self.as_context_ref())
  IntType::new(type_ref)
}

pub fn create_module(self: Context, name: String) -> Module {
  let cname = moonbit_str_to_c_str(name)
  let ctx_ref = self.as_context_ref()
  Module::new(llvm_module_create_with_name_in_context(cname, ctx_ref))
}

pub fn create_builder(self: Context) -> Builder {
  Builder::new(llvm_create_builder_in_context(self.as_context_ref()))
}

pub fn append_basic_block(
  self: Context, function: FunctionValue, name: String
) -> BasicBlock {
  let ctx_ref = self.as_context_ref()
  let fn_val_ref = function.as_value_ref()
  let cname = moonbit_str_to_c_str(name)
  
  let bb_ref = llvm_append_basic_block_in_context(ctx_ref, fn_val_ref, cname)
  BasicBlock::new(bb_ref)
}
