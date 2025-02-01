// Context
struct Context {
  ctx_ref: LLVMContextRef
} derive(Eq)

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

///| Create `i1` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let bool_ty = context.bool_type()
/// inspect!(bool_ty, "i1")
/// ```
pub fn Context::bool_type(self: Context) -> IntType {
  let type_ref = llvm_int1_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

///| Create `i8` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let i8_ty = context.i8_type()
/// inspect!(i8_ty, "i8")
/// ```
pub fn Context::i8_type(self: Context) -> IntType {
  let type_ref = llvm_int8_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

///| Create `i16` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let i16_ty = context.i16_type()
/// inspect!(i16_ty, "i16")
/// ```
pub fn Context::i16_type(self: Context) -> IntType {
  let type_ref = llvm_int16_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

///| Create `i32` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let i32_ty = context.i32_type()
/// inspect!(i32_ty, "i32")
/// ```
pub fn Context::i32_type(self: Context) -> IntType {
  let type_ref = llvm_int32_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

///| Create `i64` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let i64_ty = context.i64_type()
/// inspect!(i64_ty, "i64")
/// ```
pub fn Context::i64_type(self: Context) -> IntType {
  let type_ref = llvm_int64_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

///| Create `i128` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let i128_ty = context.i128_type()
/// inspect!(i128_ty, "i128")
/// ```
pub fn Context::i128_type(self: Context) -> IntType {
  let type_ref = llvm_int128_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

///| Create `void` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let void_ty = context.void_type()
/// inspect!(void_ty, "void")
/// ```
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

///| Create `half` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let half_ty = context.f16_type()
/// inspect!(half_ty, "half")
/// ```
pub fn Context::f16_type(self: Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = llvm_half_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

///| Create `float` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let f32_ty = context.f32_type()
/// inspect!(f32_ty, "float")
/// ```
pub fn Context::f32_type(self: Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = llvm_float_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

///| Create `double` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let f64_ty = context.f64_type()
/// inspect!(f64_ty, "double")
/// ```
pub fn Context::f64_type(self: Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = llvm_double_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

///| Create `x86_fp80` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let f80_ty = context.x86_f80_type()
/// inspect!(f80_ty, "x86_fp80")
/// ```
pub fn Context::x86_f80_type(self: Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = llvm_x86_fp80_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

///| Create `fp128` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let f128_ty = context.f128_type()
/// inspect!(f128_ty, "fp128")
/// ```
pub fn Context::f128_type(self: Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = llvm_fp128_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

///| Create `ppc_fp128` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let ppc_f128_ty = context.ppc_f128_type()
/// inspect!(ppc_f128_ty, "ppc_fp128")
/// ```
pub fn Context::ppc_f128_type(self: Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = llvm_ppc_fp128_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

///| Create a pointer type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let ptr_ty = context.ptr_type(@llvm::AddressSpace::default())
/// inspect!(ptr_ty, "ptr")
/// ```
pub fn Context::ptr_type(self: Context, addr_space: AddressSpace) -> PointerType {
  let ctx_ref = self.as_ctx_ref()
  let ptr_ty_ref = llvm_pointer_type_in_context(ctx_ref, addr_space)
  PointerType::new(ptr_ty_ref)
}

///| Create a struct type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let i32_ty = context.i32_type()
/// let i64_ty = context.i64_type()
/// let struct_ty = context.struct_type([i32_ty, i64_ty], false)
/// inspect!(struct_ty, "{ i32, i64 }")
/// ```
/// @alert CompilerBug "This function is not working due to a bug in the compiler."
pub fn Context::struct_type(self: Context, field_types: Array[&BasicType], packed~: Bool = false) -> StructType {
  let field_types = field_types.map(fn (v) {v.as_type_ref()})

  let val_ref = llvm_struct_type_in_context(self.as_ctx_ref(), field_types, packed)

  StructType::new(val_ref)
} 

///| Create a struct type in the context (unsafe).
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let i32_ty = context.i32_type().as_type_ref()
/// let i64_ty = context.i64_type().as_type_ref()
/// let struct_ty = context.struct_type_unsafe([i32_ty, i64_ty], false)
/// inspect!(struct_ty, "{ i32, i64 }")
/// ```
// @alert WillRemove "This function will be removed once the bug in the compiler is fixed."
pub fn Context::struct_type_unsafe(self: Context, field_types: Array[LLVMTypeRef], packed~: Bool = false) -> StructType {
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

///| Create an opaque struct type in the context, with the given name.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let opaque_struct_ty = context.opaque_struct_type("opaque_struct")
/// inspect!(opaque_struct_ty, "%opaque_struct = type opaque")
/// assert_true(opaque_struct_ty.is_opaque())
/// ```
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

pub fn Context::get_kind_id(self: Context, key: String) -> UInt {
  llvm_get_md_kind_id_in_context(self.as_ctx_ref(), key)
}

pub fn Context::create_enum_attribute(self: Context, kind_id: UInt, val: UInt64) -> Attribute {
  let attr_ref = llvm_create_enum_attribute(self.as_ctx_ref(), kind_id, val)
  Attribute::new(attr_ref)
}

pub fn Context::create_string_attribute(self: Context, key: String, val: String) -> Attribute {
  let attr_ref = llvm_create_string_attribute(self.as_ctx_ref(), key, val)
  Attribute::new(attr_ref)
}

pub fn Context::create_type_attribute(
  self: Context, kind_id: UInt, ty: AnyTypeEnum
) -> Attribute {
  let attr = llvm_create_type_attribute(self.as_ctx_ref(), kind_id, ty.as_type_ref())
  Attribute::new(attr)
}

pub fn Context::const_string(self: Context, s: String, null_terminated: Bool) -> ArrayValue {
  let val_ref = llvm_const_string_in_context(self.as_ctx_ref(), s, null_terminated)
  ArrayValue::new(val_ref)
}

// pub fn Context::set_diagnostic_handler

pub fn Context::create_module(self: Context, name: String) -> Module {
  let ctx_ref = self.as_ctx_ref()
  Module::new(ctx_ref.module_create_with_name(name))
}

pub fn Context::create_builder(self: Context) -> Builder {
  Builder::new(llvm_create_builder_in_context(self.as_ctx_ref()))
}

// pub fn create_module_from_ir
// pub fn create_inline_asm
