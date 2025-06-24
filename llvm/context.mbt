// Context

///| A `Context` is a container for all @unsafe.LLVM entities including `Module`s.
struct Context {
  ctx_ref : @unsafe.LLVMContextRef
} derive(Eq)

///| Creates a new `Context` from [`@unsafe.LLVMContextRef`].
///
/// **unsafe**: This function is exposed only for interoperability
/// with other @unsafe.LLVM IR libraries. It's not intended to be used by
/// most users, hence marked as unsafe.
pub fn Context::new(ctx_ref : @unsafe.LLVMContextRef) -> Context {
  Context::{ ctx_ref, }
}

// NOTE: currently need free memory by hand to avoid memory leak

///| Drops the `Context` and frees the memory.
///
/// Currently, for big projects, users need to free memory by hand
/// to avoid memory leaks, until the compiler supports automatic
/// memory management.
pub fn Context::drop(self : Context) -> Unit {
  @unsafe.llvm_context_dispose(self.as_ctx_ref())
}

///| Returns the inner `@unsafe.LLVMContextRef`.
fn Context::as_ctx_ref(self : Context) -> @unsafe.LLVMContextRef {
  self.ctx_ref
}

///| Creates a new `Context`.
///
/// ## Example
///
/// ```moonbit skip(count_basic_blocks)
/// let context = Context::create();
/// context.drop();
/// ```
pub fn Context::create() -> Context {
  Context::new(@unsafe.llvm_context_create())
}

///|
pub fn Context::create_builder(self : Context) -> Builder {
  Builder::new(@unsafe.llvm_create_builder_in_context(self.as_ctx_ref()))
}

///|
pub fn Context::create_module(self : Context, name : String) -> Module {
  let ctx_ref = self.as_ctx_ref()
  Module::new(ctx_ref.module_create_with_name(name))
}

// pub fn create_module_from_ir
// pub fn create_inline_asm

///| Create `void` type in the context.
///
/// ## Example
///
/// ```moonbit skip(count_basic_blocks)
/// let context = Context::create()
/// let void_ty = context.void_type()
/// inspect(void_ty, content="void")
/// ```
pub fn Context::void_type(self : Context) -> VoidType {
  let type_ref = @unsafe.llvm_void_type_in_context(self.as_ctx_ref())
  VoidType::new(type_ref)
}

///| Create `i1` type in the context.
///
/// ## Example
///
/// ```moonbit skip(count_basic_blocks)
/// let context = Context::create()
/// let bool_ty = context.bool_type()
/// inspect(bool_ty, content="i1")
/// ```
pub fn Context::bool_type(self : Context) -> IntType {
  let type_ref = @unsafe.llvm_int1_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

///| Create `i8` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let i8_ty = context.i8_type()
/// inspect(i8_ty, content="i8")
/// ```
pub fn Context::i8_type(self : Context) -> IntType {
  let type_ref = @unsafe.llvm_int8_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

///| Create `i16` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let i16_ty = context.i16_type()
/// inspect(i16_ty, content="i16")
/// ```
pub fn Context::i16_type(self : Context) -> IntType {
  let type_ref = @unsafe.llvm_int16_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

///| Create `i32` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let i32_ty = context.i32_type()
/// inspect(i32_ty, content="i32")
/// ```
pub fn Context::i32_type(self : Context) -> IntType {
  let type_ref = @unsafe.llvm_int32_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

///| Create `i64` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let i64_ty = context.i64_type()
/// inspect(i64_ty, content="i64")
/// ```
pub fn Context::i64_type(self : Context) -> IntType {
  let type_ref = @unsafe.llvm_int64_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

///| Create `i128` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let i128_ty = context.i128_type()
/// inspect(i128_ty, content="i128")
/// ```
pub fn Context::i128_type(self : Context) -> IntType {
  let type_ref = @unsafe.llvm_int128_type_in_context(self.as_ctx_ref())
  IntType::new(type_ref)
}

///| Gets the `IntType` representing a custom bit width. It will be assigned the current context.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i48_type = context.custom_width_int_type(48);
///
/// assert_eq(i42_type.get_bit_width(), 42);
/// ```
pub fn Context::custom_width_int_type(self : Context, bits : UInt) -> IntType {
  let type_ref = @unsafe.llvm_int_type_in_context(self.as_ctx_ref(), bits)
  IntType::new(type_ref)
}

///| Gets the `MetadataType` representing 128 bit width. It will be assigned the current context.
///
/// ## Example (Not Tested)
///
/// ```
/// let context = Context::create();
/// let md_type = context.metadata_type();
///
/// assert_true(md_type.get_context() == context);
/// ```
pub fn Context::metadata_type(self : Context) -> MetadataType {
  let mref = @unsafe.llvm_metadata_type_in_context(self.as_ctx_ref())
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
/// inspect(half_ty, content="half")
/// ```
pub fn Context::f16_type(self : Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = @unsafe.llvm_half_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

///| Create `float` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let f32_ty = context.f32_type()
/// inspect(f32_ty, content="float")
/// ```
pub fn Context::f32_type(self : Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = @unsafe.llvm_float_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

///| Create `double` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let f64_ty = context.f64_type()
/// inspect(f64_ty, content="double")
/// ```
pub fn Context::f64_type(self : Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = @unsafe.llvm_double_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

///| Create `x86_fp80` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let f80_ty = context.x86_f80_type()
/// inspect(f80_ty, content="x86_fp80")
/// ```
pub fn Context::x86_f80_type(self : Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = @unsafe.llvm_x86_fp80_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

///| Create `fp128` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let f128_ty = context.f128_type()
/// inspect(f128_ty, content="fp128")
/// ```
pub fn Context::f128_type(self : Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = @unsafe.llvm_fp128_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

///| Create `ppc_fp128` type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let ppc_f128_ty = context.ppc_f128_type()
/// inspect(ppc_f128_ty, content="ppc_fp128")
/// ```
pub fn Context::ppc_f128_type(self : Context) -> FloatType {
  let ctx_ref = self.as_ctx_ref()
  let type_ref = @unsafe.llvm_ppc_fp128_type_in_context(ctx_ref)
  FloatType::new(type_ref)
}

///| Create a pointer type in the context.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let ptr_ty = context.ptr_type(AddressSpace::default())
/// inspect(ptr_ty, content="ptr")
/// ```
pub fn Context::ptr_type(
  self : Context,
  addr_space : AddressSpace
) -> PointerType {
  let ctx_ref = self.as_ctx_ref()
  let ptr_ty_ref = @unsafe.llvm_pointer_type_in_context(
    ctx_ref,
    addr_space.into(),
  )
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
/// let struct_ty = context.struct_type([i32_ty, i64_ty])
/// inspect(struct_ty, content="{ i32, i64 }")
/// ```
pub fn Context::struct_type(
  self : Context,
  field_types : Array[&BasicType],
  is_packed~ : Bool = false
) -> StructType {
  let field_types = field_types.map(fn(v) { v.as_type_ref() })
  let val_ref = @unsafe.llvm_struct_type_in_context(
    self.as_ctx_ref(),
    field_types,
    is_packed,
  )
  StructType::new(val_ref)
}

///| Gets a named `StructType` from this `Context`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// inspect(context.get_struct_type("foo"), content="None");
/// let opaque = context.opaque_struct_type("foo");
/// inspect(context.get_struct_type("foo").unwrap(), content="%foo = type opaque");
/// ```
pub fn Context::get_struct_type(self : Context, name : String) -> StructType? {
  let ty = @unsafe.llvm_get_type_by_name(self.as_ctx_ref(), name)
  if ty.is_null() {
    return None
  }
  Some(StructType::new(ty))
}

///| Creates a constant `StructValue` from constant values.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let f32_type = context.f32_type();
/// let i16_type = context.i16_type();
/// let f32_one = f32_type.const_float(1.);
/// let i16_two = i16_type.const_int(2, sign_extend=false);
/// let const_struct = context.const_struct([i16_two, f32_one], false);
///
/// assert_eq(const_struct.get_type().get_field_types(), [i16_type, f32_type]);
/// ```
pub fn Context::const_struct(
  self : Context,
  values : Array[&BasicValue],
  packed~ : Bool = false
) -> StructValue {
  let args = values.map(fn(v) { v.as_value_ref() })
  let val_ref = @unsafe.llvm_const_struct_in_context(
    self.as_ctx_ref(),
    args,
    packed,
  )
  StructValue::new(val_ref)
}

///| Create an opaque struct type in the context, with the given name.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let opaque_struct_ty = context.opaque_struct_type("opaque_struct")
/// inspect(opaque_struct_ty, content="%opaque_struct = type opaque")
/// assert_true(opaque_struct_ty.is_opaque())
/// ```
pub fn Context::opaque_struct_type(self : Context, name : String) -> StructType {
  let val_ref = @unsafe.llvm_struct_create_named(self.as_ctx_ref(), name)
  StructType::new(val_ref)
}

///| Append a named `BasicBlock` at the end of the referenced `FunctionValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip(count_basic_blocks)
/// let context = Context::create();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = module.add_function("my_fn", fn_type);
/// let entry_basic_block = context.append_basic_block(fn_value, name="entry");
///
/// assert_eq(fn_value.count_basic_blocks(), 1);
///
/// let last_basic_block = context.append_basic_block(fn_value, name="last");
///
/// assert_eq(fn_value.count_basic_blocks(), 2);
/// assert_eq(fn_value.get_first_basic_block().unwrap(), entry_basic_block);
/// assert_eq(fn_value.get_last_basic_block().unwrap(), last_basic_block);
/// ```
pub fn Context::append_basic_block(
  self : Context,
  function : FunctionValue,
  name~ : String = ""
) -> BasicBlock {
  let ctx_ref = self.as_ctx_ref()
  let fn_val_ref = function.as_value_ref()
  let bb_ref = @unsafe.llvm_append_basic_block_in_context(
    ctx_ref, fn_val_ref, name,
  )
  BasicBlock::new(bb_ref)
}

///| Append a named `BasicBlock` after the referenced `BasicBlock`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = module.add_function("my_fn", fn_type);
/// let entry_basic_block = context.append_basic_block(fn_value, name="entry");
///
/// assert_eq(fn_value.count_basic_blocks(), 1);
///
/// let last_basic_block = context.insert_basic_block_after(entry_basic_block, "last");
///
/// assert_eq(fn_value.count_basic_blocks(), 2);
/// assert_eq(fn_value.get_first_basic_block().unwrap(), entry_basic_block);
/// assert_eq(fn_value.get_last_basic_block().unwrap(), last_basic_block);
/// ```
pub fn Context::insert_basic_block_after(
  self : Context,
  basic_block : BasicBlock,
  name~ : String = ""
) -> BasicBlock {
  match basic_block.get_next_basic_block() {
    Some(next_bb) => self.prepend_basic_block(next_bb, name)
    None => {
      let parent_fn = basic_block.get_parent().unwrap()
      self.append_basic_block(parent_fn, name~)
    }
  }
}

///| Prepend a named `BasicBlock` before the referenced `BasicBlock`.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip(count_basic_blocks)
/// let context = Context::create();
/// let module = context.create_module("my_mod");
/// let void_type = context.void_type();
/// let fn_type = void_type.fn_type([]);
/// let fn_value = module.add_function("my_fn", fn_type);
/// let entry_basic_block = context.append_basic_block(fn_value, name="entry");
///
/// assert_eq(fn_value.count_basic_blocks(), 1);
///
/// let first_basic_block = context.prepend_basic_block(entry_basic_block, "first");
///
/// assert_eq(fn_value.count_basic_blocks(), 2);
/// assert_eq(fn_value.get_first_basic_block().unwrap(), first_basic_block);
/// assert_eq(fn_value.get_last_basic_block().unwrap(), entry_basic_block);
/// ```
pub fn Context::prepend_basic_block(
  self : Context,
  basic_block : BasicBlock,
  name : String
) -> BasicBlock {
  let val_ref = @unsafe.llvm_insert_basic_block_in_context(
    self.as_ctx_ref(),
    basic_block.as_bb_ref(),
    name,
  )
  BasicBlock::new(val_ref)
}

///| Creates a `MetadataValue` tuple of heterogeneous types (a "Node") for the current context. It can be assigned to a value.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i8_type = context.i8_type();
/// let i8_two = i8_type.const_int(2, sign_extend=false);
/// let f32_type = context.f32_type();
/// let f32_zero = f32_type.const_float(0.);
/// let md_node = context.metadata_node([i8_two, f32_zero]);
/// let f32_one = f32_type.const_float(1.);
/// let void_type = context.void_type();
///
/// let builder = context.create_builder();
/// let module = context.create_module("my_mod");
/// let fn_type = void_type.fn_type([f32_type]);
/// let fn_value = module.add_function("my_func", fn_type);
/// let entry_block = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_block);
///
/// let _ = builder.build_return_void();
///
/// assert_true(md_node.is_node());
///
/// ret_instr.set_metadata(md_node, 0);
/// ```
pub fn Context::metadata_node(
  self : Context,
  values : Array[&BasicMetadataValue]
) -> MetadataValue {
  let values = values.map(fn(v) { v.as_value_ref() })
  let val_ref = @unsafe.llvm_md_node_in_context(self.as_ctx_ref(), values)
  MetadataValue::new(val_ref)
}

///| Creates a `MetadataValue` string for the current context. It can be assigned to a value.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let md_string = context.metadata_string("Floats are awesome!");
/// let f32_type = context.f32_type();
/// let f32_one = f32_type.const_float(1.);
/// let void_type = context.void_type();
///
/// let builder = context.create_builder();
/// let module = context.create_module("my_mod");
/// let fn_type = void_type.fn_type([f32_type]);
/// let fn_value = module.add_function("my_func", fn_type);
/// let entry_block = context.append_basic_block(fn_value, name="entry");
///
/// builder.position_at_end(entry_block);
///
/// let _ = builder.build_return_void();
///
/// assert_true(md_string.is_string());
///
/// ret_instr.set_metadata(md_string, 0);
/// ```
pub fn Context::metadata_string(self : Context, s : String) -> MetadataValue {
  let val_ref = @unsafe.llvm_md_string_in_context(self.as_ctx_ref(), s)
  MetadataValue::new(val_ref)
}

///| Obtains the index of a metadata kind id. If the string doesn't exist, @unsafe.LLVM will add it at index `FIRST_CUSTOM_METADATA_KIND_ID` onward.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip (not implemenbt FIRST_CUSTOM_METADATA_KIND_ID)
/// let context = Context::create();
///
/// assert_eq(context.get_kind_id("dbg"), 0);
/// assert_eq(context.get_kind_id("tbaa"), 1);
/// assert_eq(context.get_kind_id("prof"), 2);
///
/// // Custom kind id doesn't exist in @unsafe.LLVM until now:
/// assert_eq(context.get_kind_id("foo"), FIRST_CUSTOM_METADATA_KIND_ID);
/// ```
pub fn Context::get_kind_id(self : Context, key : String) -> UInt {
  @unsafe.llvm_get_md_kind_id_in_context(self.as_ctx_ref(), key)
}

///| Creates an enum `Attribute` in this `Context`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let enum_attribute = context.create_enum_attribute(0, 10);
///
/// assert_true(enum_attribute.is_enum());
/// ```
pub fn Context::create_enum_attribute(
  self : Context,
  kind_id : UInt,
  val : UInt64
) -> Attribute {
  let attr_ref = @unsafe.llvm_create_enum_attribute(
    self.as_ctx_ref(),
    kind_id,
    val,
  )
  Attribute::new(attr_ref)
}

///| Creates a string `Attribute` in this `Context`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let string_attribute = context.create_string_attribute("my_key_123", "my_val");
///
/// assert_true(string_attribute.is_string());
/// ```
pub fn Context::create_string_attribute(
  self : Context,
  key : String,
  val : String
) -> Attribute {
  let attr_ref = @unsafe.llvm_create_string_attribute(
    self.as_ctx_ref(),
    key,
    val,
  )
  Attribute::new(attr_ref)
}

///| Create an enum `Attribute` with an `AnyTypeEnum` attached to it.
///
/// ## Example (Not Tested)
///
/// ```moonbit skip (not implement op_equal)
/// let context = Context::create();
/// let kind_id = Attribute::get_named_enum_kind_id("sret");
/// let any_type = context.i32_type().as_any_type_enum();
/// let type_attribute = context.create_type_attribute(
///     kind_id,
///     any_type,
/// );
///
/// assert_true(type_attribute.is_type());
/// assert_eq(type_attribute.get_type_value(), any_type);
/// assert_ne(type_attribute.get_type_value(), context.i64_type().as_any_type_enum());
/// ```
pub fn Context::create_type_attribute(
  self : Context,
  kind_id : UInt,
  ty : AnyTypeEnum
) -> Attribute {
  let attr = @unsafe.llvm_create_type_attribute(
    self.as_ctx_ref(),
    kind_id,
    ty.as_type_ref(),
  )
  Attribute::new(attr)
}

///| Creates a const string which may be null terminated.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let s = context.const_string("my_string", false);
///
/// inspect(s, content="[9 x i8] my_string");
/// ```
pub fn Context::const_string(
  self : Context,
  s : String,
  null_terminated : Bool
) -> ArrayValue {
  let val_ref = @unsafe.llvm_const_string_in_context(
    self.as_ctx_ref(),
    s,
    null_terminated,
  )
  ArrayValue::new(val_ref)
}

// pub fn Context::set_diagnostic_handler
