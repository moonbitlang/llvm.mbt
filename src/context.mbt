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
  llvm_context_dispose(self.as_ctx_ref())
}

fn Context::as_ctx_ref(self: Context) -> LLVMContextRef {
  self.ctx_ref
}

pub fn Context::create() -> Context {
  Context::new(llvm_context_create())
}

pub fn Context::bool_type(self: Context) -> IntType {
  let type_ref = llvm_int1_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

pub fn Context::i8_type(self: Context) -> IntType {
  let type_ref = llvm_int8_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

pub fn Context::i16_type(self: Context) -> IntType {
  let type_ref = llvm_int16_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

pub fn Context::i32_type(self: Context) -> IntType {
  let type_ref = llvm_int32_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

pub fn Context::i64_type(self: Context) -> IntType {
  let type_ref = llvm_int64_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

pub fn Context::i128_type(self: Context) -> IntType {
  let type_ref = llvm_int128_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

pub fn Context::void_type(self: Context) -> VoidType {
  let type_ref = llvm_void_type_in_context(self.as_ctx_ref())
  VoidType::new(type_ref)
}

pub fn Context::custom_width_int_type(self: Context, bits: UInt) -> IntType {
  let type_ref = llvm_int_type_in_context(self.as_ctx_ref(), bits)
  IntType::new(type_ref)
}

pub fn Context::metadata_type(self: Context) -> MetadataType {
  let mref = llvm_metadata_type_in_context(self.as_ctx_ref())
  MetadataType::new(mref)
}

// pub fn Context::fptr_sized_int_type(self: Context, target_data: )

pub fn Context::f16_type(self: Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = llvm_half_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

pub fn Context::f32_type(self: Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = llvm_float_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

pub fn Context::f64_type(self: Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = llvm_double_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

pub fn Context::x86_f80_type(self: Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = llvm_x86_fp80_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

pub fn Context::f128_type(self: Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = llvm_fp128_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

pub fn Context::ppc_f128_type(self: Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = llvm_ppc_fp128_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

pub fn Context::ptr_type(self: Context, addr_space: AddressSpace) -> PointerType {
  let ctx_ref = self.as_ctx_ref()
  let ptr_ty_ref = llvm_pointer_type_in_context(ctx_ref, addr_space)
  PointerType::new(ptr_ty_ref)
}

pub fn Context::struct_type(self: Context, field_types: Array[BasicTypeEnum], packed: Bool) -> StructType {
  let field_types = field_types.map(fn (v) {v.as_type_ref()})

  let val_ref = llvm_struct_type_in_context(self.as_ctx_ref(), field_types, packed)

  StructType::new(val_ref)
} 

pub fn Context::get_struct_type(self: Context, name: String) -> StructType? {
  let ty = llvm_get_type_by_name(self.as_ctx_ref(), name)
  if ty.is_null() {
    return None
  }

  Some(StructType::new(ty))
}

pub fn Context::const_struct(
  self: Context, values: Array[BasicValueEnum], packed: Bool
) -> StructValue {
  let args = values.map(fn (v) {v.as_value_ref()})

  let val_ref = llvm_const_struct_in_context(self.as_ctx_ref(), args, packed)
  StructValue::new(val_ref)
}

pub fn Context::opaque_struct_type(self: Context, name: String) -> StructType {
  let val_ref = llvm_struct_create_named(self.as_ctx_ref(), name)
  StructType::new(val_ref)
}

pub fn Context::append_basic_block(
  self: Context, function: FunctionValue, name: String
) -> BasicBlock {
  let ctx_ref = self.as_ctx_ref()
  let fn_val_ref = function.as_value_ref()
  
  let bb_ref = llvm_append_basic_block_in_context(ctx_ref, fn_val_ref, name)
  BasicBlock::new(bb_ref).unwrap()
}

// pub fn Context::insert_basic_block_after(
//   self: Context, basic_block: BasicBlock, name: String
// ) -> BasicBlock {
// }

pub fn Context::prepend_basic_block(
  self: Context, basic_block: BasicBlock, name: String
) -> BasicBlock {
  let val_ref = llvm_insert_basic_block_in_context(self.as_ctx_ref(), basic_block.as_bb_ref(), name)

  BasicBlock::new(val_ref).unwrap()
}

// pub fn get_kind_id
// pub fn create_enum_attribute
// pub fn create_string_attribute
// pub fn create_type_attribute
// pub fn const_string
// pub fn set_diagnostic_handler

pub fn Context::create_module(self: Context, name: String) -> Module {
  let ctx_ref = self.as_ctx_ref()
  Module::new(ctx_ref.module_create_with_name(name))
}

pub fn Context::create_builder(self: Context) -> Builder {
  Builder::new(llvm_create_builder_in_context(self.as_ctx_ref()))
}

// pub fn create_module_from_ir
// pub fn create_inline_asm
