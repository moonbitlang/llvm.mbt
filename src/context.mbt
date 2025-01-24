// Context
struct Context {
  ctx_ref: LLVMContextRef
}

pub fn Context::new(ctx_ref: LLVMContextRef) -> Context {
  Context :: {
    ctx_ref: ctx_ref
  }
}

// NOTE: currently need free memory by hand to avoid memory leak
pub fn Context::drop(self: Context) -> Unit {
  llvm_context_dispose(self.as_context_ref())
}

fn as_context_ref(self: Context) -> LLVMContextRef {
  self.ctx_ref
}

pub fn Context::create() -> Context {
  Context::new(llvm_context_create())
}

pub fn bool_type(self: Context) -> IntType {
  let type_ref = llvm_int1_type_in_context(self.as_context_ref())
  IntType::new(type_ref)
}

pub fn i8_type(self: Context) -> IntType {
  let type_ref = llvm_int8_type_in_context(self.as_context_ref())
  IntType::new(type_ref)
}

pub fn i16_type(self: Context) -> IntType {
  let type_ref = llvm_int16_type_in_context(self.as_context_ref())
  IntType::new(type_ref)
}

pub fn i32_type(self: Context) -> IntType {
  let type_ref = llvm_int32_type_in_context(self.as_context_ref())
  IntType::new(type_ref)
}

pub fn i64_type(self: Context) -> IntType {
  let type_ref = llvm_int64_type_in_context(self.as_context_ref())
  IntType::new(type_ref)
}

pub fn i128_type(self: Context) -> IntType {
  let type_ref = llvm_int128_type_in_context(self.as_context_ref())
  IntType::new(type_ref)
}

pub fn void_type(self: Context) -> VoidType {
  let type_ref = llvm_void_type_in_context(self.as_context_ref())
  VoidType::new(type_ref)
}

pub fn custom_width_int_type(self: Context, bits: UInt) -> IntType {
  let type_ref = llvm_int_type_in_context(self.as_context_ref(), bits)
  IntType::new(type_ref)
}

// pub fn metadata_type(self: Context) -> MetadataType {
//   let mref = llvm_metadata_type_in_context(self.as_context_ref())
//   MetadataType::new(mref)
// }

// pub fn ptr_sized_int_type()

pub fn Context::f16_type(self: Context) -> FloatType {
  let ctx_ref = self.as_context_ref()
  let type_ref = llvm_half_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

pub fn Context::f32_type(self: Context) -> FloatType {
  let ctx_ref = self.as_context_ref()
  let type_ref = llvm_float_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

pub fn Context::f64_type(self: Context) -> FloatType {
  let ctx_ref = self.as_context_ref()
  let type_ref = llvm_double_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

// pub fn Context::x86_f80_type(self: Context) -> FloatType {
//   let ctx_ref = self.as_context_ref()
//   let type_ref = llvm_x86fp80_type_in_context(ctx_ref)
//   FloatType::new(type_ref)
// }

// pub fn Context::f128_type(self: Context) -> FloatType {
//   let ctx_ref = self.as_context_ref()
//   let type_ref = llvm_fp128_type_in_context(ctx_ref)
//   FloatType::new(type_ref)
// }

// pub fn Context::ppc_f128_type(self: Context) -> FloatType {
//   let ctx_ref = self.as_context_ref()
//   let type_ref = llvm_ppcfp128_type_in_context(ctx_ref)
//   FloatType::new(type_ref)
// }

// pub fn ptr_type(self: Context, addr_space: AddressSpace) -> PointerType {
//   let ctx_ref = self.as_context_ref()
//   let ptr_ty_ref = llvm_pointer_type_in_context(ctx_ref, addr_space.0)
//   PointerType::new(ptr_ty_ref)
// }


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
  BasicBlock::new(bb_ref).unwrap()
}
