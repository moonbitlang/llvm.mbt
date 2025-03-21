///| A `StructType` is the type of a heterogeneous container of types.
pub struct StructType {
  ty: Type
}

///| Create `StructType` from `@unsafe.LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not struct type.
pub fn StructType::new(type_ref: @unsafe.LLVMTypeRef) -> StructType {
  assert_type_ref(type_ref)

  StructType::{
    ty: Type::new(type_ref)
  }
}

pub fn StructType::as_type_ref(self: StructType) -> @unsafe.LLVMTypeRef {
  self.ty.as_type_ref()
}

///| Gets the type of a field belonging to this `StructType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i64_type = context.i64_type();
/// let struct_type = context.struct_type([i32_type, i64_type]);
/// let field_type = struct_type.get_field_type_at_index(1);
/// inspect!(field_type.unwrap(), "i64")
/// ```
pub fn StructType::get_field_type_at_index(self: StructType, index: UInt) -> BasicTypeEnum? {
  // TODO: need to think about how to handle this when `opaque` is true
  if self.is_opaque() {
    return None
  }

  if index >= self.count_fields() {
    return None
  }

  let t = @unsafe.llvm_struct_get_type_at_index(self.as_type_ref(), index)
  let t = BasicTypeEnum::new(t)
  Some(t)
}

///| Creates a `StructValue` based on this `StructType`'s definition.
pub fn StructType::const_named_struct(self: StructType, values: Array[BasicValueEnum]) -> StructValue {
  let args = values.map(fn (v) {v.as_value_ref()})
  let vref = @unsafe.llvm_const_named_struct(self.as_type_ref(), args)
  StructValue::new(vref)
}

///|
pub fn StructType::const_zero(self: StructType) -> StructValue {
  StructValue::new(self.ty.const_zero())
}

///| Gets the size of this `StructType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i64_type = context.i64_type();
/// let struct_type = context.struct_type([i32_type, i64_type]);
/// let struct_sz = struct_type.size_of().unwrap();
/// let expect = "i64 ptrtoint (ptr getelementptr ({ i32, i64 }, ptr null, i32 1) to i64)"
/// inspect!(struct_sz, content=expect)
/// ```
pub fn StructType::size_of(self: StructType) -> IntValue? {
  self.ty.size_of()
}

///| Returns whether this `StructType` is sized. **Always returns `true`.**
///
/// ## Note
///
/// This function always returns `true` even the struct is opaque.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i64_type = context.i64_type();
/// let struct_type = context.struct_type([i32_type, i64_type]);
/// let opaque_struct = context.struct_type([]);
/// inspect!(struct_type.is_sized(), content="true")
/// inspect!(opaque_struct.is_sized(), content="true")
/// ```
pub fn StructType::is_sized(self: StructType) -> Bool {
  self.ty.is_sized()
}

///| Returns the alignment of this `StructType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i64_type = context.i64_type();
/// let struct_type = context.struct_type([i32_type, i64_type]);
/// let struct_align = struct_type.get_alignment();
/// let expect = "i64 ptrtoint (ptr getelementptr ({ i1, { i32, i64 } }, ptr null, i64 0, i32 1) to i64)"
/// inspect!(struct_align, content=expect)
/// ```
pub fn StructType::get_alignment(self: StructType) -> IntValue {
  self.ty.get_alignment()
}

///| Gets a reference to the `Context` this `StructType` was created in.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i64_type = context.i64_type();
/// let struct_type = context.struct_type([i32_type, i64_type]);
/// let struct_ctx = struct_type.get_context();
/// assert_eq!(context, struct_ctx);
/// ```
pub fn StructType::get_context(self: StructType) -> Context {
  self.ty.get_context()
}

// NOTE: It's different with `inkwell`, need to check if it is correct for anonymous struct
///| Gets this `StructType`'s name.
pub fn StructType::get_name(self: StructType) -> String {
  @unsafe.llvm_get_struct_name(self.as_type_ref())
}

///| Creates a `FunctionType` with this `StructType` for its return type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i64_type = context.i64_type();
/// let struct_type = context.struct_type([i32_type, i64_type]);
/// let fn_type = struct_type.fn_type([i32_type, i64_type]);
/// inspect!(fn_type, "<{ i32, i64 }> (i32, i64)")
/// ```
pub fn StructType::fn_type(self: StructType, param_types: Array[&BasicMetadataType], is_var_arg~: Bool=false) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg=is_var_arg)
}

///| Creates an `ArrayType` with this `StructType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i64_type = context.i64_type();
/// let struct_type = context.struct_type([i32_type, i64_type]);
/// let array_type = struct_type.array_type(8);
/// inspect!(array_type, "[8 x { i32, i64 }]")
/// ```
pub fn StructType::array_type(self: StructType, size: UInt) -> ArrayType {
  self.ty.array_type(size)
}

///| Creates a `PointerType` with this `StructType` for its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i64_type = context.i64_type();
/// let struct_type = context.struct_type([i32_type, i64_type]);
/// let ptr_ty = struct_type.ptr_type(AddressSpace::default());
/// inspect!(ptr_ty, "ptr")
/// ```
pub fn StructType::ptr_type(self: StructType, address_space: AddressSpace) -> PointerType {
  PointerType::new(@unsafe.llvm_pointer_type(self.as_type_ref(), address_space.into()))
}

///| Determines whether or not a `StructType` is packed.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i64_type = context.i64_type();
/// let struct_type = context.struct_type([i32_type, i64_type], is_packed=true);
/// assert_true!(struct_type.is_packed())
/// ```
pub fn StructType::is_packed(self: StructType) -> Bool {
  @unsafe.llvm_is_packed_struct(self.as_type_ref())
}

///| Determines whether or not a `StructType` is opaque.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let struct_ty = context.opaque_struct_type("opaque_struct");
/// assert_true!(struct_ty.is_opaque())
/// ```
pub fn StructType::is_opaque(self: StructType) -> Bool {
  @unsafe.llvm_is_opaque_struct(self.as_type_ref())
}

///| Counts the number of field types.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i64_type = context.i64_type();
/// let struct_type = context.struct_type([i32_type, i64_type]);
/// let field_count = struct_type.count_fields();
/// assert_eq!(field_count, 2)
/// ```
pub fn StructType::count_fields(self: StructType) -> UInt {
  @unsafe.llvm_count_struct_element_types(self.as_type_ref())
}

///| Gets this `StructType`'s field types.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i64_type = context.i64_type();
/// let struct_type = context.struct_type([i32_type, i64_type]);
/// let field_types = struct_type.get_field_types();
/// inspect!(field_types, "[i32, i64]")
/// ```
pub fn StructType::get_field_types(self: StructType) -> Array[BasicTypeEnum] {
  let ele_tys = @unsafe.llvm_get_struct_element_types(self.as_type_ref())

  let ele_tys = ele_tys.map(fn (t) {
    BasicTypeEnum::new(t)
  })

  ele_tys
}

///| Creates an undefined instance of a `StructType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i64_type = context.i64_type();
/// let struct_type = context.struct_type([i32_type, i64_type]);
/// let struct_undef = struct_type.get_undef();
/// inspect!(struct_undef, "{ i32, i64 } undef")
/// ```
pub fn StructType::get_undef(self: StructType) -> StructValue {
  StructValue::new(self.ty.get_undef())
}

///| Creates a poison instance of a `StructType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i64_type = context.i64_type();
/// let struct_type = context.struct_type([i32_type, i64_type]);
/// let struct_poison = struct_type.get_poison();
/// inspect!(struct_poison, "{ i32, i64 } poison")
/// ```
pub fn StructType::get_poison(self: StructType) -> StructValue {
  StructValue::new(@unsafe.llvm_get_poison(self.as_type_ref()))
}

///| Defines the body of a `StructType`.
///
/// If the struct is an opaque type, it will no longer be after this call.
///
/// Resetting the `packed` state of a non-opaque struct type may not work.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let opaque_struct = context.opaque_struct_type("opaque_struct");
/// assert_true!(opaque_struct.is_opaque())
///
/// let i32_type = context.i32_type();
/// let f64_type = context.f64_type();
/// opaque_struct.set_body([i32_type, f64_type], is_packed=true);
/// assert_false!(opaque_struct.is_opaque())
/// inspect!(opaque_struct, "{ i32, double }")
/// ```
pub fn StructType::set_body(
  self: StructType,
  field_types: Array[&BasicType],
  is_packed~: Bool=false
) -> Bool {
  let is_opaque = self.is_opaque()
  let field_types =  field_types.map(fn (t) {t.as_type_ref()})

  @unsafe.llvm_struct_set_body(self.as_type_ref(), field_types, is_packed)
  is_opaque
}

///| Creates a constant `ArrayValue`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let struct_type = context.struct_type([i32_type]);
/// let struct_val = struct_type.const_named_struct([])
/// let struct_arr = struct_type.const_array([struct_val, struct_val]);
/// assert_true!(struct_arr.is_const())
/// ```
pub fn StructType::const_array(self: StructType, values: Array[StructValue]) -> ArrayValue {
  ArrayValue::new_const_array(self, values)
}

///| Dumps the `StructType` to stderr.
///
/// It's equivalent to `StructType::dump()`.
pub fn StructType::print_to_stderr(self: StructType) -> Unit {
  self.ty.print_to_stderr()
}

///| Dumps the `StructType` to a string.
///
/// It's equivalent to `StructType::to_string()`.
pub fn StructType::print_to_string(self: StructType) -> String {
  self.ty.print_to_string()
}

///| Dumps the `StructType` to a string.
///
/// It's equivalent to `StructType::print_to_string()`.
pub fn StructType::to_string(self: StructType) -> String {
  self.ty.to_string()
}

///| Dumps the `StructType` to stderr.
///
/// It's equivalent to `StructType::print_to_stderr()`.
pub fn StructType::dump(self: StructType) -> Unit {
  self.ty.dump()
}

pub impl Show for StructType with output(self: StructType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for StructType with to_string(self: StructType) -> String {
  self.to_string()
}


