///| A `StructType` is the type of a heterogeneous container of types.
pub struct StructType {
  ty : TypeRef
}

///| Create `StructType` from `@unsafe.LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not struct type.
pub fn StructType::new(type_ref : @unsafe.LLVMTypeRef) -> StructType {
  guard type_ref.is_not_null()
  StructType::{ ty: TypeRef::new(type_ref) }
}

///|
pub impl Type for StructType with base(self) {
  self.ty
}

///|
pub impl Type for StructType with as_type_enum(self) {
  StructType(self)
}

///|
pub impl BasicType for StructType with as_basic_type_enum(self) {
  StructType(self)
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
/// inspect(field_type.unwrap(), content="i64")
/// ```
pub fn StructType::get_field_type_at_index(
  self : StructType,
  index : UInt
) -> &BasicType? {
  // TODO: need to think about how to handle this when `opaque` is true
  if self.is_opaque() {
    return None
  }
  if index >= self.count_fields() {
    return None
  }
  let t = @unsafe.llvm_struct_get_type_at_index(self.inner(), index)
  let t = BasicTypeEnum::init(t).as_basic_type_class()
  Some(t)
}

///| Creates a `StructValue` based on this `StructType`'s definition.
pub fn StructType::const_named_struct(
  self : StructType,
  values : Array[&BasicValue]
) -> StructValue {
  let args = values.map(v => v.inner())
  let vref = @unsafe.llvm_const_named_struct(self.inner(), args)
  StructValue::new(vref)
}

///|
pub fn StructType::const_zero(self : StructType) -> StructValue {
  StructValue::new(self.ty.const_zero())
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
/// inspect(struct_type.is_sized(), content="true")
/// inspect(opaque_struct.is_sized(), content="true")
/// ```
pub fn StructType::is_sized(self : StructType) -> Bool {
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
/// inspect(struct_align, content=expect)
/// ```
pub fn StructType::get_alignment(self : StructType) -> IntValue {
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
/// assert_true(context == struct_ctx);
/// ```
pub fn StructType::get_context(self : StructType) -> Context {
  self.ty.get_context()
}

// NOTE: It's different with `inkwell`, need to check if it is correct for anonymous struct

///| Gets this `StructType`'s name.
pub fn StructType::get_name(self : StructType) -> String {
  @unsafe.llvm_get_struct_name(self.inner())
}

///| Creates a `FunctionType` with this `StructType` for its return type.
///
/// ## Example
///
/// ```moonbit skip (test failed)
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i64_type = context.i64_type();
/// let struct_type = context.struct_type([i32_type, i64_type]);
/// let fn_type = struct_type.fn_type([i32_type, i64_type]);
/// inspect(fn_type, content="<{ i32, i64 }> (i32, i64)")
/// ```
pub fn StructType::fn_type(
  self : StructType,
  param_types : Array[&BasicType],
  is_var_arg~ : Bool = false
) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg~)
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
/// assert_true(struct_type.is_packed())
/// ```
pub fn StructType::is_packed(self : StructType) -> Bool {
  @unsafe.llvm_is_packed_struct(self.inner())
}

///| Determines whether or not a `StructType` is opaque.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let struct_ty = context.opaque_struct_type("opaque_struct");
/// assert_true(struct_ty.is_opaque())
/// ```
pub fn StructType::is_opaque(self : StructType) -> Bool {
  @unsafe.llvm_is_opaque_struct(self.inner())
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
/// assert_eq(field_count, 2)
/// ```
pub fn StructType::count_fields(self : StructType) -> UInt {
  @unsafe.llvm_count_struct_element_types(self.inner())
}

///| Gets this `StructType`'s field types.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i64_type = context.i64_type();
/// let struct_type = context.struct_type([i32_type, i64_type]);
/// let field_types = struct_type.get_field_types();
/// inspect(field_types, content="[i32, i64]")
/// ```
pub fn StructType::get_field_types(self : StructType) -> Array[&BasicType] {
  let ele_tys = @unsafe.llvm_get_struct_element_types(self.inner())
  let ele_tys = ele_tys.map(t => BasicTypeEnum::init(t).as_basic_type_class())
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
/// inspect(struct_undef, content="{ i32, i64 } undef")
/// ```
pub fn StructType::get_undef(self : StructType) -> StructValue {
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
/// inspect(struct_poison, content="{ i32, i64 } poison")
/// ```
pub fn StructType::get_poison(self : StructType) -> StructValue {
  StructValue::new(@unsafe.llvm_get_poison(self.inner()))
}

///| Defines the body of a `StructType`.
///
/// If the struct is an opaque type, it will no longer be after this call.
///
/// Resetting the `packed` state of a non-opaque struct type may not work.
///
/// ## Example
///
/// ```moonbit skip (test failed)
/// let context = Context::create();
/// let opaque_struct = context.opaque_struct_type("opaque_struct");
/// assert_true(opaque_struct.is_opaque())
///
/// let i32_type = context.i32_type();
/// let f64_type = context.f64_type();
/// opaque_struct.set_body([i32_type, f64_type], is_packed=true);
/// assert_false(opaque_struct.is_opaque())
/// inspect(opaque_struct, content="{ i32, double }")
/// ```
pub fn StructType::set_body(
  self : StructType,
  field_types : Array[&BasicType],
  is_packed~ : Bool = false
) -> Unit raise MoonllvmError {
  guard self.is_opaque() else { raise SetBodyForNonOpaqueStruct }
  let field_types = field_types.map(fn(t) { t.inner() })
  @unsafe.llvm_struct_set_body(self.inner(), field_types, is_packed)
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
/// assert_true(struct_arr.is_const())
/// ```
pub fn StructType::const_array(
  self : StructType,
  values : Array[StructValue]
) -> ArrayValue {
  let values = values.map(v => v as &Value)
  ArrayValue::new_const_array(self, values)
}

///|
pub impl Show for StructType with output(self : StructType, logger : &Logger) -> Unit {
  logger.write_string(self.ty.to_string())
}
