// ==========================================
// Types
// ==========================================
struct Type {
  type_ref: LLVMTypeRef
}

fn Type::new(type_ref: LLVMTypeRef) -> Type {
  if type_ref.is_null() {
    println("Type is null")
    panic()
  }

  Type::{
    type_ref
  }
}

fn Type::as_type_ref(self: Type) -> LLVMTypeRef {
  self.type_ref
}

// FIXME: link error
fn Type::const_zero(self: Type) -> LLVMValueRef {
  let val_ref = self.type_ref
  let k = llvm_get_type_kind(val_ref)

  match k {
    LLVMMetadataTypeKind => llvm_const_pointer_null(val_ref)
    _ => {
      llvm_const_null(val_ref)
    }
  }
}

fn ptr_type(self: Type, address_space: AddressSpace) -> PointerType {
  PointerType::new(llvm_pointer_type(self.as_type_ref(), address_space))
}

fn vec_type(self: Type, size: UInt) -> VectorType {
  if size == 0 {
    abort("Vector size must be greater than 0")
  }

  // let r = llvm_vector_type(self.as_type_ref(), size)
  let r = self.as_type_ref().vector_type(size)
  VectorType::new(r)
}

fn scalable_vec_type(self: Type, size : UInt) -> ScalableVectorType {
  if size == 0 {
    abort("Vector size must be greater than 0")
  }

  // let r = llvm_scalable_vector_type(self.as_type_ref(), size)
  let r = self.as_type_ref().scalable_vector_type(size)
  ScalableVectorType::new(r)

}

// TODO: use `prarm_types: Array[&TyepRef]` after compiler bug fixed
fn Type::fn_type(
  self: Type,
  param_types: Array[LLVMTypeRef],
  is_var_arg: Bool
) -> FunctionType {
  let ret_ty = self.as_type_ref()
  // let type_refs = param_types.map(fn (t) {t.as_type_ref()})
  let type_refs = param_types
  let fty_ref = llvm_function_type(ret_ty, type_refs, is_var_arg)
  FunctionType::new(fty_ref)
}

// REVIEW: Why not check size is zero?
fn array_type(self: Type, size: UInt) -> ArrayType {
  let r = llvm_array_type(self.as_type_ref(), size)
  ArrayType::new(r)
}

fn Type::get_undef(self: Type) -> LLVMValueRef {
  llvm_get_undef(self.as_type_ref())
}

fn Type::get_poison(self: Type) -> LLVMValueRef {
  llvm_get_poison(self.as_type_ref())
}

fn Type::get_alignment(self: Type) -> IntValue {
  IntValue::new(llvm_align_of(self.as_type_ref()))
}

fn Type::get_context(self: Type) -> Context {
  let context_ref = self.as_type_ref().get_context()
  Context::new(context_ref)
}

fn Type::is_sized(self: Type) -> Bool {
  self.as_type_ref().is_sized().to_moonbit_bool()
}

fn Type::size_of(self: Type) -> IntValue? {
  if not(self.is_sized()) {
    return None
  }

  let v = IntValue::new(llvm_size_of(self.as_type_ref()))
  Some(v)
}

fn Type::get_element_type(self: Type) -> AnyTypeEnum {
  let element_type_ref = self.as_type_ref().get_element_type()
  AnyTypeEnum::new(element_type_ref)
}

fn Type::print_to_stderr(self: Type) -> Unit {
  llvm_dump_type(self.as_type_ref())
}

fn Type::print_to_string(self: Type) -> String {
  llvm_print_type_to_string(self.as_type_ref())
}

fn Type::to_string(self: Type) -> String {
  llvm_print_type_to_string(self.as_type_ref())
}

fn Type::dump(self: Type) -> Unit {
  llvm_dump_type(self.as_type_ref())
}

impl Show for Type with output(self: Type, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

impl Show for Type with to_string(self: Type) -> String {
  self.to_string()
}

// ===============================================
// IntType
// ===============================================
pub struct IntType {
  ty: Type
}

///| Create `IntType` from `LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not int type.
pub fn IntType::new(type_ref: LLVMTypeRef) -> IntType {
  assert_type_ref(type_ref)

  IntType::{
    ty: Type::new(type_ref)
  }
}

///| Return `LLVMTypeRef` of `IntType`
pub fn IntType::as_type_ref(self: IntType) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

///| Creates an `IntValue` representing a constant value of this `IntType`. It will be automatically assigned this `IntType`'s `Context`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create()
/// let i32_type = IntType::i32_type(context)
/// let i32_val = i32_type.const_int(42, false)
/// inspect!(i32_val, "i32 42")
/// ```
// TODO: Maybe better explain signextension
pub fn IntType::const_int(self: IntType, val: UInt64, sign_extend: Bool) -> IntValue {
  let llvm_val_ref = llvm_const_int(self.as_type_ref(), val, sign_extend)
  IntValue::new(llvm_val_ref)
}

// pub fn IntType::const_int_from_string(self: IntType, slice: String, radix: StringRaidx) -> IntValue? {
//
// }

///| Create a constant `IntValue` of arbitrary precision.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create()
/// let i64_type = context.i64_type();
/// let i64_val = i64_type.const_int_arbitrary_precision([1, 2]);
/// ```
pub fn IntType::const_int_arbitrary_precision(self: IntType, words: Array[UInt64]) -> IntValue {
  let llvm_val_ref = llvm_const_int_of_arbitrary_precision(self.as_type_ref(), words)
  IntValue::new(llvm_val_ref)
}

///| Creates an `IntValue` representing a constant value of all one bits of this `IntType`. It will be automatically assigned this `IntType`'s `Context`.
///
/// ## Example
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i32_ptr_value = i32_type.const_all_ones();
/// inspect!(i32_ptr_value, "i32 -1")
/// ```
pub fn IntType::const_all_ones(self: IntType) -> IntValue {
  let llvm_val_ref = llvm_const_all_ones(self.as_type_ref())
  IntValue::new(llvm_val_ref)
}

///| Creates a constant zero value of this `IntType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i8_type = context.i8_type();
/// let i8_zero = i8_type.const_zero();
/// inspect!(i8_zero, "i8 0")
/// ```
/// @alert bug "This function will cause `ValueRef is Null` error."
pub fn IntType::const_zero(self: IntType) -> IntValue {
  IntValue::new(self.ty.const_zero())
}

///| Creates a `FunctionType` with this `IntType` for its return type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let fn_type = i32_type.fn_type([], false);
/// inspect!(fn_type, "i32 ()")
/// ```
pub fn IntType::fn_type(self: IntType, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg)
}

///| Creates an `ArrayType` with this `IntType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let array_type = i32_type.array_type(16);
/// inspect!(array_type, "[16 x i32]")
/// ```
pub fn IntType::array_type(self: IntType, size: UInt) -> ArrayType {
  self.ty.array_type(size)
}

///| Creates a `VectorType` with this `IntType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let vector_type = i32_type.vec_type(16);
/// inspect!(vector_type, "<16 x i32>")
/// ```
pub fn IntType::vec_type(self: IntType, size: UInt) -> VectorType {
  self.ty.vec_type(size)
}

///| Creates a `ScalableVectorType` with this `IntType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let vscale_type = i32_type.scalable_vec_type(16);
/// inspect!(vscale_type, "<vscale x 16 x i32>")
/// ```
pub fn IntType::scalable_vec_type(self: IntType, size: UInt) -> ScalableVectorType {
  self.ty.scalable_vec_type(size)
}


///| Gets a reference to the `Context` this `IntType` was created in.
pub fn IntType::get_context(self: IntType) -> Context {
  self.ty.get_context()
}

///| Gets the size of this `IntType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i32_sz = i32_type.size_of();
/// let expect = "i64 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i64)";
/// inspect!(i32_sz, content=expect)
/// ```
pub fn IntType::size_of(self: IntType) -> IntValue {
  self.ty.size_of().unwrap()
}

///| Returns whether this `IntType` is sized. **Always returns `true`.**
pub fn IntType::is_sized(self: IntType) -> Bool {
  self.ty.is_sized()
}


///| Gets the alignment of this `IntType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i32_align = i32_type.get_alignment();
/// let expect = "i64 ptrtoint (ptr getelementptr ({ i1, i32 }, ptr null, i64 0, i32 1) to i64)"
/// inspect!(i32_align, content=expect)
/// ```
pub fn IntType::get_alignment(self: IntType) -> IntValue {
  self.ty.get_alignment()
}

///| Creates a `PointerType` with this `IntType` for its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// inspect!(ptr_type, "ptr")
/// ```
pub fn IntType::ptr_type(self: IntType, address_space: AddressSpace) -> PointerType {
  PointerType::new(llvm_pointer_type(self.as_type_ref(), address_space))
}

///| Gets the bit width of an `IntType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i32_width = i32_type.get_bit_width();
/// inspect!(i32_width, "32")
/// ```
pub fn IntType::get_bit_width(self: IntType) -> UInt {
  llvm_get_int_type_width(self.as_type_ref())
}

///| Creates an undefined instance of an `IntType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i32_undef = i32_type.get_undef();
/// inspect!(i32_undef, "i32 undef")
/// ```
pub fn IntType::get_undef(self: IntType) -> IntValue {
  IntValue::new(self.ty.get_undef())
}

///| Creates a poison instance of an `IntType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let i32_poison = i32_type.get_poison();
/// inspect!(i32_poison, "i32 poison")
/// ```
pub fn IntType::get_poison(self: IntType) -> IntValue {
  IntValue::new(self.ty.get_poison())
}

// pub fn IntType::create_generic_value(self: IntType, value: UInt64, is_signed: Bool) -> GenericValue {
//   let gv = llvm_create_generic_value_of_int(self.as_type_ref(), value, is_signed)
//   GenericValue::new(gv)
// }

// TODO: enable this after `new_const_array` is implemented
// pub fn IntType::const_array(self: IntType, values: Arrayp[IntValue]) -> ArrayValue {
//   ArrayValue::new_const_array(self, values)
// }

pub fn IntType::print_to_stderr(self: IntType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn IntType::print_to_string(self: IntType) -> String {
  self.ty.print_to_string()
}

pub fn IntType::to_string(self: IntType) -> String {
  self.ty.to_string()
}

pub fn IntType::dump(self: IntType) -> Unit {
  self.ty.dump()
}

pub impl Show for IntType with output(self: IntType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for IntType with to_string(self: IntType) -> String {
  self.to_string()
}

// ==============================================
// FloatType
// ==============================================
pub struct FloatType {
  ty: Type
}

///| Create `FloatType` from `LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not float type.
pub fn FloatType::new(type_ref: LLVMTypeRef) -> FloatType {
  assert_type_ref(type_ref)

  FloatType::{
    ty: Type::new(type_ref)
  }
}

// use get_kind to check if it is float type
// pub fn FloatType::safe_new(type_ref: LLVMTypeRef) -> Option[FloatType];

///| Return `LLVMTypeRef` of `FloatType`
pub fn FloatType::as_type_ref(self: FloatType) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

///| Creates a constant `FloatValue` of this `FloatType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f32_type = context.f32_type();
/// let i32_type = context.i32_type();
/// let fn_val = f32_type.fn_type([i32_type.as_type_ref()], false);
/// inspect!(fn_val, "float (i32)")
/// ```
// TODO: use `prarm_types: Array[&TyepRef]` after compiler bug fixed
pub fn FloatType::fn_type(self: FloatType, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg)
}

///| Creates an `ArrayType` with this `FloatType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f32_type = context.f32_type();
/// let array_type = f32_type.array_type(16);
/// inspect!(array_type, "[16 x float]")
/// ```
pub fn FloatType::array_type(self: FloatType, size: UInt) -> ArrayType {
  self.ty.array_type(size)
}

///| Creates a `VectorType` with this `FloatType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f32_type = context.f32_type();
/// let vector_type = f32_type.vec_type(16);
/// inspect!(vector_type, "<16 x float>")
/// ```
pub fn FloatType::vec_type(self: FloatType, size: UInt) -> VectorType {
  self.ty.vec_type(size)
}

///| Creates a `ScalableVectorType` with this `FloatType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f32_type = context.f32_type();
/// let vscale_type = f32_type.scalable_vec_type(16);
/// inspect!(vscale_type, "<vscale x 16 x float>")
/// ```
pub fn FloatType::scalable_vec_type(self: FloatType, size: UInt) -> ScalableVectorType {
  self.ty.scalable_vec_type(size)
}

///| Creates a `FloatValue` representing a constant value of this `FloatType`.
/// It will be automatically assigned this `FloatType`'s `Context`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let pi = f64_type.const_float(3.1415926);
/// inspect!(pi, "double 0x400921FB4D12D84A")
/// ```
pub fn FloatType::const_float(self: FloatType, val: Double) -> FloatValue {
  let llvm_val_ref = llvm_const_real(self.as_type_ref(), val)
  FloatValue::new(llvm_val_ref)
}

// FIXME: untested
pub fn FloatType::const_float_from_string(self: FloatType, slice: String) -> FloatValue {
  if slice.is_empty() {
    abort("Float string is empty")
  }

  // TODO: use `llvm_const_real_of_string` instead
  let r = llvm_const_real_of_string_and_size(self.as_type_ref(), slice)
  FloatValue::new(r)
}

///| Creates a constant zero value of this `FloatType`.
///
/// **Note: This API is problematic**
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let f64_zero = f64_type.const_zero();
/// inspect!(f64_zero, "double 0.0")
/// ```
/// @alert bug "This function will cause `ValueRef is Null` error."
pub fn FloatType::const_zero(self: FloatType) -> FloatValue {
  FloatValue::new(self.ty.const_zero())
}

///| Gets the size of this `FloatType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let f64_sz = f64_type.size_of();
/// let expect = "i64 ptrtoint (ptr getelementptr (double, ptr null, i32 1) to i64)";
/// inspect!(f64_sz, content=expect)
/// ```
pub fn FloatType::size_of(self: FloatType) -> IntValue {
  self.ty.size_of().unwrap()
}

///| Returns whether this `FloatType` is sized. **Always returns `true`.**
pub fn FloatType::is_sized(self: FloatType) -> Bool {
  self.ty.is_sized()
}

///| Gets the alignment of this `FloatType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let f64_align = f64_type.get_alignment();
/// let expect = "i64 ptrtoint (ptr getelementptr ({ i1, double }, ptr null, i64 0, i32 1) to i64)"
/// inspect!(f64_align, content=expect)
/// ```
pub fn FloatType::get_alignment(self: FloatType) -> IntValue {
  self.ty.get_alignment()
}

///| Gets a reference to the `Context` this `FloatType` was created in.
pub fn FloatType::get_context(self: FloatType) -> Context {
  self.ty.get_context()
}

///| Creates a `PointerType` with this `FloatType` for its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let ptr_type = f64_type.ptr_type(AddressSpace::default());
/// inspect!(ptr_type, "ptr")
/// ```
pub fn FloatType::ptr_type(self: FloatType, address_space: AddressSpace) -> PointerType {
  PointerType::new(llvm_pointer_type(self.as_type_ref(), address_space))
}

///| Creates an undefined instance of a `FloatType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let f64_undef = f64_type.get_undef();
/// inspect!(f64_undef, "double undef")
/// ```
pub fn get_undef(self: FloatType) -> FloatValue {
  FloatValue::new(self.ty.get_undef())
}

///| Creates a poison instance of a `FloatType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let f64_type = context.f64_type();
/// let f64_poison = f64_type.get_poison();
/// inspect!(f64_poison, "double poison")
/// ```
pub fn get_poison(self: FloatType) -> FloatValue {
  FloatValue::new(self.ty.get_poison())
}

// pub fn FloatType::create_generic_value(self: FloatType, value: Double) -> GenericValue {
//   let gv = llvm_create_generic_value_of_float(self.as_type_ref(), value)
//   GenericValue::new(gv)
// }

// TODO: enable this after `new_const_array` is implemented
// pub fn FloatType::const_array(self: FloatType, values: Array[FloatValue]) -> ArrayValue {
//   ArrayValue::new_const_array(self, values)
// }

pub fn FloatType::print_to_stderr(self: FloatType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn FloatType::print_to_string(self: FloatType) -> String {
  self.ty.print_to_string()
}

pub fn FloatType::to_string(self: FloatType) -> String {
  self.ty.to_string()
}

pub fn FloatType::dump(self: FloatType) -> Unit {
  self.ty.dump()
}

pub impl Show for FloatType with output(self: FloatType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for FloatType with to_string(self: FloatType) -> String {
  self.to_string()
}

// ==============================================
// VoidType
// ==============================================
pub struct VoidType {
  ty : Type
}

///| Create `VoidType` from `LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not void type.
pub fn VoidType::new(type_ref: LLVMTypeRef) -> VoidType {
  assert_type_ref(type_ref)

  VoidType::{
    ty: Type::new(type_ref)
  }
}

pub fn VoidType::as_type_ref(self: VoidType) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

///| Return whether this `VoidType` is sized. **Always returns `false`.**
pub fn VoidType::is_sized(self: VoidType) -> Bool {
  self.ty.is_sized()
}

///| Gets a reference to the `Context` this `VoidType` was created in.
pub fn VoidType::get_context(self: VoidType) -> Context {
  self.ty.get_context()
}

///| Creates a `FunctionType` with this `VoidType` for its return type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let void_type = context.void_type();
/// let i32_type = context.i32_type();
/// let fn_type = void_type.fn_type([i32_type.as_type_ref()], false);
/// inspect!(fn_type, "void (i32)")
/// ```
pub fn VoidType::fn_type(self: VoidType, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg)
}

///| Gets the alignment of this `VoidType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let void_type = context.void_type();
/// let void_align = void_type.get_alignment();
/// let expect = "i64 ptrtoint (ptr getelementptr ({ i1, void }, ptr null, i64 0, i32 1) to i64)"
/// inspect!(void_align, content=expect)
/// ```
pub fn VoidType::get_alignment(self: VoidType) -> IntValue {
  self.ty.get_alignment()
}

pub fn VoidType::print_to_stderr(self: VoidType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn VoidType::print_to_string(self: VoidType) -> String {
  self.ty.print_to_string()
}

pub fn VoidType::to_string(self: VoidType) -> String {
  self.ty.to_string()
}

pub fn VoidType::dump(self: VoidType) -> Unit {
  self.ty.dump()
}

pub impl Show for VoidType with output(self: VoidType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for VoidType with to_string(self: VoidType) -> String {
  self.to_string()
}

// ===========================================
// PointerType
// ===========================================
pub struct PointerType {
  ty: Type
}

///| Create `PointerType` from `LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not pointer type.
pub fn PointerType::new(type_ref: LLVMTypeRef) -> PointerType {
  assert_type_ref(type_ref)

  PointerType::{
    ty: Type::new(type_ref)
  }
}

pub fn PointerType::as_type_ref(self: PointerType) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

///| Gets the size of this `PointerType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let ptr_sz = ptr_type.size_of();
/// let expect = "i64 ptrtoint (ptr getelementptr (ptr, ptr null, i32 1) to i64)";
/// inspect!(ptr_sz, content=expect)
/// ```
pub fn PointerType::size_of(self: PointerType) -> IntValue {
  self.ty.size_of().unwrap()
}

///| Returns whether this `PointerType` is sized. **Always returns `true`.**
pub fn PointerType::is_sized(self: PointerType) -> Bool {
  self.ty.is_sized()
}

///| Gets the alignment of this `PointerType`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let ptr_align = ptr_type.get_alignment();
/// let expect = "i64 ptrtoint (ptr getelementptr ({ i1, ptr }, ptr null, i64 0, i32 1) to i64)";
/// inspect!(ptr_align, content=expect)
/// ```
pub fn PointerType::get_alignment(self: PointerType) -> IntValue {
  self.ty.get_alignment()
}

///| Creates a `PointerType` with this `PointerType` for its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let ptr_ptr_type = ptr_type.ptr_type(AddressSpace::default());
/// inspect!(ptr_ptr_type, "ptr")
/// ```
pub fn PointerType::ptr_type(self: PointerType, address_space: AddressSpace) -> PointerType {
  PointerType::new(llvm_pointer_type(self.as_type_ref(), address_space))
}

///| Gets a reference to the `Context` this `PointerType` was created in.
pub fn PointerType::get_context(self: PointerType) -> Context {
  self.ty.get_context()
}

///| Creates a `FunctionType` with this `PointerType` for its return type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let fn_type = ptr_type.fn_type([i32_type.as_type_ref()], false);
/// inspect!(fn_type, "ptr (i32)")
/// ```
pub fn PointerType::fn_type(self: PointerType, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg)
}

///| Creates an `ArrayType` with this `PointerType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let array_type = ptr_type.array_type(16);
/// inspect!(array_type, "[16 x ptr]")
/// ```
pub fn PointerType::array_type(self: PointerType, size: UInt) -> ArrayType {
  self.ty.array_type(size)
}

///| Gets the `AddressSpace` a `PointerType` was created with.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let addr_space = ptr_type.get_address_space();
/// inspect!(addr_space, "AddressSpace(0)")
/// ```
pub fn PointerType::get_address_space(self: PointerType) -> AddressSpace {
  let addr_space = llvm_get_pointer_address_space(self.as_type_ref())

  AddressSpace(addr_space)
}

///| Creates a null `PointerValue` of this `PointerType`.
/// It will be automatically assigned this `PointerType`'s `Context`.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let null_ptr = ptr_type.const_null();
/// inspect!(null_ptr, "")
/// ```
///
/// @alert bug "This function will cause `ValueRef is Null` error."
pub fn PointerType::const_null(self: PointerType) -> PointerValue {
  PointerValue::new(llvm_const_null(self.as_type_ref()))
}

///| Creates a constant null value of this `PointerType`.
/// This is practically the same as calling `const_null` for this particular type and
/// so this function may be removed in the future.
///
/// ## Example (Not Tested)
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let null_ptr = ptr_type.const_null();
/// inspect!(null_ptr, "")
/// ```
///
/// @alert bug "This function will cause `ValueRef is Null` error."
pub fn PointerType::const_zero(self: PointerType) -> PointerValue {
  PointerValue::new(self.ty.const_zero())
}

///| Creates an undefined instance of a `PointerType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let ptr_undef = ptr_type.get_undef();
/// inspect!(ptr_undef, "ptr undef")
/// ```
pub fn PointerType::get_undef(self: PointerType) -> PointerValue {
  PointerValue::new(llvm_get_undef(self.as_type_ref()))
}

///| Creates a poison instance of a `PointerType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let ptr_poison = ptr_type.get_poison();
/// inspect!(ptr_poison, "ptr poison")
/// ```
pub fn PointerType::get_poison(self: PointerType) -> PointerValue {
  PointerValue::new(llvm_get_poison(self.as_type_ref()))
}

///| Creates a `VectorType` with this `PointerType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let vector_type = ptr_type.vec_type(16);
/// inspect!(vector_type, "<16 x ptr>")
/// ```
pub fn PointerType::vec_type(self: PointerType, size: UInt) -> VectorType {
  self.ty.vec_type(size)
}

///| Creates a `ScalableVectorType` with this `PointerType` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let vscale_type = ptr_type.scalable_vec_type(16);
/// inspect!(vscale_type, "<vscale x 16 x ptr>")
/// ```
pub fn PointerType::scalable_vec_type(self: PointerType, size: UInt) -> ScalableVectorType {
  self.ty.scalable_vec_type(size)
}

// Note: Check if `llvm_get_element_type` is unavailable in llvm-19
// pub fn PointerType::get_element_type(self: PointerType) -> ...

// TODO: enable this after `new_const_array` is implemented
// pub fn PointerType::const_array(self: PointerType, values: Array[PointerValue]) -> ArrayValue {
//   ArrayValue::new_const_array(self, values)
// }


// NOTE: above llvm-15
///| Determine whether this pointer is opaque.
pub fn PointerType::is_opaque(self: PointerType) -> Bool {
  llvm_pointer_type_is_opaque(self.as_type_ref())
}

pub fn PointerType::print_to_stderr(self: PointerType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn PointerType::print_to_string(self: PointerType) -> String {
  self.ty.print_to_string()
}

pub fn PointerType::to_string(self: PointerType) -> String {
  self.ty.to_string()
}

pub fn PointerType::dump(self: PointerType) -> Unit {
  self.ty.dump()
}

pub impl Show for PointerType with output(self: PointerType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for PointerType with to_string(self: PointerType) -> String {
  self.to_string()
}

// ===========================================
// StructType
// ===========================================
pub struct StructType {
  ty: Type
}

///| Create `StructType` from `LLVMTypeRef`
///
/// **Unsafe**: Undefined behavior if `type_ref` is not struct type.
pub fn StructType::new(type_ref: LLVMTypeRef) -> StructType {
  assert_type_ref(type_ref)

  StructType::{
    ty: Type::new(type_ref)
  }
}

pub fn StructType::as_type_ref(self: StructType) -> LLVMTypeRef {
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

  let t = llvm_struct_get_type_at_index(self.as_type_ref(), index)
  let t = BasicTypeEnum::new(t)
  Some(t)
}

pub fn StructType::const_named_struct(self: StructType, values: Array[BasicValueEnum]) -> StructValue {
  let args = values.map(fn (v) {v.as_value_ref()})
  let vref = llvm_const_named_struct(self.as_type_ref(), args)
  StructValue::new(vref)
}

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

pub fn StructType::get_context(self: StructType) -> Context {
  self.ty.get_context()
}

// NOTE: It's different with `inkwell`, need to check if it is corrent for anonymous struct
pub fn StructType::get_name(self: StructType) -> String {
  llvm_get_struct_name(self.as_type_ref())
}

pub fn StructType::fn_type(self: StructType, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg)
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
  PointerType::new(llvm_pointer_type(self.as_type_ref(), address_space))
}

pub fn StructType::is_packed(self: StructType) -> Bool {
  llvm_is_packed_struct(self.as_type_ref())
}

pub fn StructType::is_opaque(self: StructType) -> Bool {
  llvm_is_opaque_struct(self.as_type_ref())
}

pub fn StructType::count_fields(self: StructType) -> UInt {
  llvm_count_struct_element_types(self.as_type_ref())
}

// REVIEW: Possible unsafe
pub fn StructType::get_field_types(self: StructType) -> Array[BasicTypeEnum] {
  let ele_tys = llvm_get_struct_element_types(self.as_type_ref())

  let ele_tys = ele_tys.map(fn (t) {
    BasicTypeEnum::new(t)
  })

  ele_tys
}

pub fn StructType::get_undef(self: StructType) -> StructValue {
  StructValue::new(self.ty.get_undef())
}

pub fn StructType::get_poison(self: StructType) -> StructValue {
  StructValue::new(llvm_get_poison(self.as_type_ref()))
}

pub fn StructType::set_body(self: StructType, field_types: Array[BasicTypeEnum], packed: Bool) -> Bool {
  let is_opaque = self.is_opaque()
  let field_types =  field_types.map(fn (t) {t.as_type_ref()})

  llvm_struct_set_body(self.as_type_ref(), field_types, packed)

  is_opaque
}

// TODO: enable this after `new_const_array` is implemented
// pub fn StructType::const_array(self: StructType, values: Array[StructValue]) -> ArrayValue {
//   ArrayValue::new_const_array(self, values)
// }

pub fn StructType::print_to_stderr(self: StructType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn StructType::print_to_string(self: StructType) -> String {
  self.ty.print_to_string()
}

pub fn StructType::to_string(self: StructType) -> String {
  self.ty.to_string()
}

pub fn StructType::dump(self: StructType) -> Unit {
  self.ty.dump()
}

pub impl Show for StructType with output(self: StructType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for StructType with to_string(self: StructType) -> String {
  self.to_string()
}

// ===========================================
// FunctionType
// ===========================================
pub struct FunctionType {
  ty: Type
}

pub fn FunctionType::new(type_ref: LLVMTypeRef) -> FunctionType {
  assert_type_ref(type_ref)

  FunctionType::{
    ty: Type::new(type_ref)
  }
}

pub fn FunctionType::as_type_ref(self: FunctionType) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

pub fn FunctionType::ptr_type(self: FunctionType, address_space: AddressSpace) -> PointerType {
  self.ty.ptr_type(address_space)
}

pub fn FunctionType::is_var_arg(self: FunctionType) -> Bool {
  llvm_is_function_var_arg(self.as_type_ref())
}

pub fn FunctionType::get_param_types(self: FunctionType) -> Array[BasicTypeEnum] {
  // let cnt = llvm_count_param_types(self.as_type_ref())

  let param_types = llvm_get_param_types(self.as_type_ref())

  param_types.map(fn (t) {BasicTypeEnum::new(t)})
}

pub fn FunctionType::count_param_types(self: FunctionType) -> UInt {
  llvm_count_param_types(self.as_type_ref())
}

pub fn FunctionType::is_sized(self: FunctionType) -> Bool {
  self.ty.is_sized()
}

pub fn FunctionType::get_context(self: FunctionType) -> Context {
  self.ty.get_context()
}

pub fn FunctionType::get_return_type(self: FunctionType) -> BasicTypeEnum? {
  let ty = llvm_get_return_type(self.as_type_ref())
  let kind = llvm_get_type_kind(ty)
  match kind {
    LLVMVoidTypeKind => None
    _ => Some(BasicTypeEnum::new(ty))
  }
}

pub fn FunctionType::print_to_stderr(self: FunctionType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn FunctionType::print_to_string(self: FunctionType) -> String {
  self.ty.print_to_string()
}

pub fn FunctionType::to_string(self: FunctionType) -> String {
  self.ty.to_string()
}

pub fn FunctionType::dump(self: FunctionType) -> Unit {
  self.ty.dump()
}

pub impl Show for FunctionType with output(self: FunctionType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for FunctionType with to_string(self: FunctionType) -> String {
  self.to_string()
}
// ===========================================
// ArrayType
// ===========================================
pub struct ArrayType {
  ty: Type
}

pub fn ArrayType::new(type_ref: LLVMTypeRef) -> ArrayType {
  assert_type_ref(type_ref)

  ArrayType::{
    ty: Type::new(type_ref)
  }
}

pub fn ArrayType::as_type_ref(self: ArrayType) -> LLVMTypeRef {
  self.ty.as_type_ref()
}


pub fn ArrayType::size_of(self: ArrayType) -> IntValue? {
  self.ty.size_of()
}

pub fn ArrayType::is_sized(self: ArrayType) -> Bool {
  self.ty.is_sized()
}


pub fn ArrayType::fn_type(self: ArrayType, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg)
}


pub fn ArrayType::array_type(self: ArrayType, size: UInt) -> ArrayType {
  self.ty.array_type(size)
}


pub fn ArrayType::get_alignment(self: ArrayType) -> IntValue {
  self.ty.get_alignment()
}

// pub fn ArrayType::const_array(self: ArrayType, values: Array[BasicValueEnum]) -> ArrayValue {
//   ArrayValue::new_const_array(self, values)
// }

pub fn ArrayType::const_zero(self: ArrayType) -> ArrayValue {
  ArrayValue::new(self.ty.const_zero())
}

pub fn ArrayType::length(self: ArrayType) -> UInt {
  llvm_get_array_length(self.as_type_ref())
}

pub fn ArrayType::is_empty(self: ArrayType) -> Bool {
  self.length() == 0
}

pub fn ArrayType::get_undef(self: ArrayType) -> ArrayValue {
  ArrayValue::new(self.ty.get_undef())
}

pub fn ArrayType::get_poison(self: ArrayType) -> ArrayValue {
  ArrayValue::new(llvm_get_poison(self.as_type_ref()))
}

// pub fn ArrayType::get_element_type(self: ArrayType) -> BasicTypeEnum {
//   self.ty.get_element_type().as_basic_type_enum()
// }

pub fn ArrayType::get_context(self: ArrayType) -> Context {
  self.ty.get_context()
}

pub fn ArrayType::print_to_stderr(self: ArrayType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn ArrayType::print_to_string(self: ArrayType) -> String {
  self.ty.print_to_string()
}

pub fn ArrayType::to_string(self: ArrayType) -> String {
  self.ty.to_string()
}

pub fn ArrayType::dump(self: ArrayType) -> Unit {
  self.ty.dump()
}

pub impl Show for ArrayType with output(self: ArrayType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for ArrayType with to_string(self: ArrayType) -> String {
  self.to_string()
}
// ===========================================
// VectorType
// ===========================================
pub struct VectorType {
  ty: Type
}

pub fn VectorType::new(type_ref: LLVMTypeRef) -> VectorType {
  assert_type_ref(type_ref)

  VectorType::{
    ty: Type::new(type_ref)
  }
}

pub fn VectorType::as_type_ref(self: VectorType) -> LLVMTypeRef {
  self.ty.as_type_ref()
}



pub impl BasicMetadataType for VectorType with as_basic_metadata_type_enum(self: VectorType) -> BasicMetadataTypeEnum {
  BasicMetadataTypeEnum::VectorType(self)
}

pub fn VectorType::size_of(self: VectorType) -> IntValue? {
  self.ty.size_of()
}

pub fn VectorType::is_sized(self: VectorType) -> Bool {
  self.ty.is_sized()
}


pub fn VectorType::get_alignment(self: VectorType) -> IntValue {
  self.ty.get_alignment()
}

pub fn VectorType::get_size(self: VectorType) -> UInt {
  llvm_get_vector_size(self.as_type_ref())
}

pub fn VectorType::fn_type(self: VectorType, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg)
}

pub fn VectorType::array_type(self: VectorType, size: UInt) -> ArrayType {
  self.ty.array_type(size)
}

pub fn VectorType::ptr_type(self: VectorType, address_space: AddressSpace) -> PointerType {
  PointerType::new(llvm_pointer_type(self.as_type_ref(), address_space))
}


// pub fn VectorType::const_vector

// pub fn VectorType::const_zero(self: VectorType) -> VectorValue {
//   VectorValue::new(llvm_const_zero(self.as_type_ref()))
// }

pub fn VectorType::get_context(self: VectorType) -> Context {
  self.ty.get_context()
}

pub fn VectorType::print_to_stderr(self: VectorType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn VectorType::print_to_string(self: VectorType) -> String {
  self.ty.print_to_string()
}

pub fn VectorType::to_string(self: VectorType) -> String {
  self.ty.to_string()
}

pub fn VectorType::dump(self: VectorType) -> Unit {
  self.ty.dump()
}

pub impl Show for VectorType with output(self: VectorType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for VectorType with to_string(self: VectorType) -> String {
  self.to_string()
}

// ===========================================
// ScalableVectorType
// ===========================================
pub struct ScalableVectorType {
  ty: Type
}

pub fn ScalableVectorType::new(type_ref: LLVMTypeRef) -> ScalableVectorType {
  assert_type_ref(type_ref)

  ScalableVectorType::{
    ty: Type::new(type_ref)
  }
}

pub fn ScalableVectorType::as_type_ref(self: ScalableVectorType) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

pub fn ScalableVectorType::size_of(self: ScalableVectorType) -> IntValue? {
  self.ty.size_of()
}

pub fn ScalableVectorType::is_sized(self: ScalableVectorType) -> Bool {
  self.ty.is_sized()
}


pub fn ScalableVectorType::get_alignment(self: ScalableVectorType) -> IntValue {
  self.ty.get_alignment()
}

pub fn ScalableVectorType::get_size(self: ScalableVectorType) -> UInt {
  llvm_get_vector_size(self.as_type_ref())
}

pub fn ScalableVectorType::const_zero(self: ScalableVectorType) -> ScalableVectorValue {
 ScalableVectorValue::new(self.ty.const_zero())
}

pub fn ScalableVectorType::get_undef(self: ScalableVectorType) -> ScalableVectorValue {
  ScalableVectorValue::new(self.ty.get_undef())
}

pub fn ScalableVectorType::get_poison(self: ScalableVectorType) -> ScalableVectorValue {
  ScalableVectorValue::new(self.ty.get_poison())
}

// pub fn ScalableVectorType::get_element_type(self: ScalableVectorType) -> BasicTypeEnum {
//   self.ty.get_element_type().as_basic_type_enum()
// }

// TODO: use `prarm_types: Array[&TyepRef]` after compiler bug fixed
pub fn ScalableVectorType::fn_type(self: ScalableVectorType, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg)
}

pub fn ScalableVectorType::array_type(self: ScalableVectorType, size: UInt) -> ArrayType {
  self.array_type(size)
}

pub fn ScalableVectorType::ptr_type(self: ScalableVectorType, address_space: AddressSpace) -> PointerType {
  PointerType::new(llvm_pointer_type(self.as_type_ref(), address_space))
}

// TODO: enable this after `new_const_array` is implemented
// pub fn ScalableVectorType::const_array(self: ScalableVectorType, values: Array[ScalableVectorValue]) -> ArrayValue {
//   ArrayValue::new_const_array(self, values)
// }

pub fn ScalableVectorType::get_context(self: ScalableVectorType) -> Context {
  self.ty.get_context()
}

pub fn ScalableVectorType::print_to_stderr(self: ScalableVectorType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn ScalableVectorType::print_to_string(self: ScalableVectorType) -> String {
  self.ty.print_to_string()
}

pub fn ScalableVectorType::to_string(self: ScalableVectorType) -> String {
  self.ty.to_string()
}

pub fn ScalableVectorType::dump(self: ScalableVectorType) -> Unit {
  self.ty.dump()
}

pub impl Show for ScalableVectorType with output(self: ScalableVectorType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for ScalableVectorType with to_string(self: ScalableVectorType) -> String {
  self.to_string()
}

// ===========================================
// MeteadataType
// ===========================================
pub struct MetadataType {
  ty: Type
}

pub fn MetadataType::new(type_ref: LLVMTypeRef) -> MetadataType {
  assert_type_ref(type_ref)

  MetadataType::{
    ty: Type::new(type_ref)
  }
}

pub fn MetadataType::as_type_ref(self: MetadataType) -> LLVMTypeRef {
  self.ty.as_type_ref()
}

pub fn MetadataType::fn_type(self: MetadataType, param_types: Array[LLVMTypeRef], is_var_arg: Bool) -> FunctionType {
  self.ty.fn_type(param_types, is_var_arg)
}

pub fn MetadataType::get_context(self: MetadataType) -> Context {
  self.ty.get_context()
}

pub fn MetadataType::print_to_stderr(self: MetadataType) -> Unit {
  self.ty.print_to_stderr()
}

pub fn MetadataType::print_to_string(self: MetadataType) -> String {
  self.ty.print_to_string()
}

pub fn MetadataType::to_string(self: MetadataType) -> String {
  self.ty.to_string()
}

pub fn MetadataType::dump(self: MetadataType) -> Unit {
  self.ty.dump()
}

pub impl Show for MetadataType with output(self: MetadataType, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Show for MetadataType with to_string(self: MetadataType) -> String {
  self.to_string()
}
