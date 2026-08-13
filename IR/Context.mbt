///|
/// Owns an LLVM context and the uniqued types and constants created in it.
///
/// Values derived from a `Context` retain the same managed context owner, so
/// they remain usable after the original `Context` binding leaves scope.
///
/// **Lifecycle:**
///
/// The underlying LLVM context is released automatically after the context and
/// every dependent Module, Builder, Type, and Constant become unreachable.
pub struct Context {
  priv owner : ContextOwner
}

///|
fn Context::from_owner(owner : ContextOwner) -> Context {
  Context::{ owner, }
}

///|
fn Context::from_raw(raw : @raw.LLVMContextRef) -> Context {
  Context::from_owner(ContextOwner::new(raw))
}

///|
fn Context::get_owner(self : Context) -> ContextOwner {
  self.owner
}

///|
fn Context::get_raw_ref(self : Context) -> @raw.LLVMContextRef {
  self.owner.raw()
}

///|
/// Compares whether two values refer to the same underlying LLVM context.
pub impl Eq for Context with fn equal(self, other) {
  self.get_raw_ref() == other.get_raw_ref()
}

///|
/// Creates an independent managed LLVM context.
///
/// **Lifecycle:**
///
/// The context is released automatically after its last dependent object becomes
/// unreachable; callers do not dispose it explicitly.
pub fn Context::new() -> Context {
  Context::from_raw(@raw.llvm_context_create())
}

///|
/// Creates an empty Module owned by this context.
///
/// **Parameters:**
///
/// - `name`: The module identifier. It may be empty but must not contain an
///   embedded NUL byte.
///
/// **Errors:**
///
/// - `StringError::ContainsNul` if `name` contains an embedded NUL byte.
///
/// **Lifecycle:**
///
/// The returned Module retains this context and manages its own native module.
pub fn Context::addModule(
  self : Self,
  name : String,
) -> Module raise StringError {
  let module_ref = @raw.llvm_module_create_with_name_in_context(
    name,
    self.get_raw_ref(),
  ) catch {
    @raw.EmbeddedNul => raise ContainsNul
  }
  Module::from_raw(module_ref, self)
}

///|
/// Creates an IRBuilder associated with this context and with no insertion point.
///
/// **Lifecycle:**
///
/// The builder retains this context. After an insertion point is set, it also
/// retains the Module containing that point.
///
/// **Notes:**
///
/// Instruction creation fails with `BuilderError::UnsetPosition` until an
/// insertion point is selected.
pub fn Context::createBuilder(self : Self) -> IRBuilder {
  IRBuilder::{
    owner: BuilderOwner::new(
      @raw.llvm_create_builder_in_context(self.get_raw_ref()),
      self.get_owner(),
    ),
    positioned: NotSet,
  }
}

///|
/// Returns the IEEE 754 binary16 type uniqued in this context.
///
/// - See LLVM: `Type::getHalfTy`.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let half_ty = ctx.getHalfTy()
///   inspect(half_ty, content="half")
/// }
/// ```
pub fn Context::getHalfTy(self : Context) -> HalfType {
  let typeref = @raw.llvm_half_type_in_context(self.get_raw_ref())
  HalfType::from_raw(typeref, self)
}

///|
/// Returns the 16-bit brain floating-point type uniqued in this context.
///
/// - See LLVM: `Type::getBFloatTy`.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let bfloat_ty = ctx.getBFloatTy()
///   inspect(bfloat_ty, content="bfloat")
/// }
/// ```
pub fn Context::getBFloatTy(self : Context) -> BFloatType {
  let typeref = @raw.llvm_bfloat_type_in_context(self.get_raw_ref())
  BFloatType::from_raw(typeref, self)
}

///|
/// Returns the IEEE 754 binary32 type uniqued in this context.
///
/// - See LLVM: `Type::getFloatTy`.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let f32ty = ctx.getFloatTy()
///   inspect(f32ty, content="float")
/// }
/// ```
pub fn Context::getFloatTy(self : Context) -> FloatType {
  let typeref = @raw.llvm_float_type_in_context(self.get_raw_ref())
  FloatType::from_raw(typeref, self)
}

///|
/// Returns the IEEE 754 binary64 type uniqued in this context.
///
/// - See LLVM: `Type::getDoubleTy`.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let doubletype = ctx.getDoubleTy()
///   inspect(doubletype, content="double")
/// }
/// ```
pub fn Context::getDoubleTy(self : Context) -> DoubleType {
  let typeref = @raw.llvm_double_type_in_context(self.get_raw_ref())
  DoubleType::from_raw(typeref, self)
}

///|
/// Returns the IEEE 754 binary128 type uniqued in this context.
///
/// - See LLVM: `Type::getFP128Ty`.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let fp128ty = ctx.getFP128Ty()
///   inspect(fp128ty, content="fp128")
/// }
/// ```
pub fn Context::getFP128Ty(self : Context) -> FP128Type {
  let typeref = @raw.llvm_fp128_type_in_context(self.get_raw_ref())
  FP128Type::from_raw(typeref, self)
}

///|
/// Returns the void type uniqued in this context.
///
/// - See LLVM: `Type::getVoidTy`.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let voidty = ctx.getVoidTy()
///   inspect(voidty, content="void")
/// }
/// ```
pub fn Context::getVoidTy(self : Context) -> VoidType {
  let typeref = @raw.llvm_void_type_in_context(self.get_raw_ref())
  VoidType::from_raw(typeref, self)
}

///|
/// Returns the basic-block label type uniqued in this context.
pub fn Context::getLabelTy(self : Context) -> LabelType {
  let typeref = @raw.llvm_label_type_in_context(self.get_raw_ref())
  LabelType::from_raw(typeref, self)
}

///|
/// Returns the metadata type uniqued in this context.
pub fn Context::getMetadataTy(self : Context) -> MetadataType {
  let typeref = @raw.llvm_metadata_type_in_context(self.get_raw_ref())
  MetadataType::from_raw(typeref, self)
}

///|
/// Returns the token type uniqued in this context.
///
/// - See LLVM: `Type::getTokenTy`.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let tokenty = ctx.getTokenTy()
///   inspect(tokenty, content="token")
/// }
/// ```
pub fn Context::getTokenTy(self : Context) -> TokenType {
  let typeref = @raw.llvm_token_type_in_context(self.get_raw_ref())
  TokenType::from_raw(typeref, self)
}

///|
/// Returns the one-bit integer type uniqued in this context.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///
///   let i1ty = ctx.getInt1Ty()
///   assert_eq(i1ty.getBitWidth(), 1)
///   inspect(i1ty, content="i1")
/// }
/// ```
pub fn Context::getInt1Ty(self : Context) -> Int1Type {
  let typeref = @raw.llvm_int1_type_in_context(self.get_raw_ref())
  Int1Type::from_raw(typeref, self)
}

///|
/// Returns the eight-bit integer type uniqued in this context.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///
///   let i8ty = ctx.getInt8Ty()
///   assert_eq(i8ty.getBitWidth(), 8)
///   inspect(i8ty, content="i8")
/// }
/// ```
pub fn Context::getInt8Ty(self : Context) -> Int8Type {
  let typeref = @raw.llvm_int8_type_in_context(self.get_raw_ref())
  Int8Type::from_raw(typeref, self)
}

///|
/// Returns the 16-bit integer type uniqued in this context.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///
///   let i16ty = ctx.getInt16Ty()
///   assert_eq(i16ty.getBitWidth(), 16)
///   inspect(i16ty, content="i16")
/// }
/// ```
pub fn Context::getInt16Ty(self : Context) -> Int16Type {
  let typeref = @raw.llvm_int16_type_in_context(self.get_raw_ref())
  Int16Type::from_raw(typeref, self)
}

///|
/// Returns the 32-bit integer type uniqued in this context.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///
///   let i32ty = ctx.getInt32Ty()
///   assert_eq(i32ty.getBitWidth(), 32)
///   inspect(i32ty, content="i32")
/// }
/// ```
pub fn Context::getInt32Ty(self : Context) -> Int32Type {
  let typeref = @raw.llvm_int32_type_in_context(self.get_raw_ref())
  Int32Type::from_raw(typeref, self)
}

///|
/// Returns the 64-bit integer type uniqued in this context.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///
///   let i64ty = ctx.getInt64Ty()
///   assert_eq(i64ty.getBitWidth(), 64)
///   inspect(i64ty, content="i64")
/// }
/// ```
pub fn Context::getInt64Ty(self : Context) -> Int64Type {
  let typeref = @raw.llvm_int64_type_in_context(self.get_raw_ref())
  Int64Type::from_raw(typeref, self)
}

///|
/// Returns an opaque pointer type in this context.
///
/// **Parameters:**
///
/// - `addressSpace`: The target-specific address-space number. The default is
///   address space zero.
///
/// **Lifecycle:**
///
/// The returned type retains this context.
///
/// **Notes:**
///
/// LLVM 19 uses opaque pointers, so this API does not accept or preserve a
/// pointee type.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///
///   inspect(ctx.getPtrTy(), content="ptr")
///
///   let addressSpace = AddressSpace::new(1)
///   inspect(ctx.getPtrTy(addressSpace~), content="ptr addrspace(1)")
/// }
/// ```
pub fn Context::getPtrTy(
  self : Context,
  addressSpace? : AddressSpace = AddressSpace::default(),
) -> PointerType {
  let typeref = @raw.llvm_pointer_type_in_context(
    self.get_raw_ref(),
    addressSpace.0,
  )
  PointerType::from_raw(typeref, self)
}

///|
/// Returns a function type with the given signature.
///
/// **Parameters:**
///
/// - `returnType`: The function result type.
/// - `paramTypes`: The fixed parameters in source order.
/// - `isVarArg`: Whether calls may supply additional variadic arguments.
///
/// **Preconditions:**
///
/// `returnType` and every member of `paramTypes` must belong to this context and
/// must be valid in an LLVM function signature.
///
/// **Lifecycle:**
///
/// The returned type retains this context.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let voidty = ctx.getVoidTy()
///   let i32ty = ctx.getInt32Ty()
///   let f64ty = ctx.getDoubleTy()
///
///   let fty = ctx.getFunctionType(voidty, [i32ty, f64ty])
///   inspect(fty, content="void (i32, double)")
/// }
/// ```
pub fn Context::getFunctionType(
  self : Context,
  returnType : &Type,
  paramTypes : Array[&Type],
  isVarArg? : Bool = false,
) -> FunctionType {
  let ret_ty = returnType.get_raw_type_ref()
  let param_tyrefs = paramTypes.map(v => v.get_raw_type_ref())
  let fty_ref = @raw.llvm_function_type(ret_ty, param_tyrefs, isVarArg)
  FunctionType::from_raw(fty_ref, self)
}

///|
/// Creates a struct type with a complete body in this context.
///
/// An empty body is distinct from an opaque struct. Use
/// `Context::getOpaqueStructType` when the body will be defined later.
///
/// **Parameters:**
///
/// - `elements`: Field types in layout order.
/// - `isPacked`: Whether LLVM may omit ABI padding between fields.
/// - `name`: An optional identified-struct name. An unnamed struct is literal.
///
/// **Errors:**
///
/// - `StringError::ContainsNul` if `name` contains an embedded NUL byte.
///
/// **Preconditions:**
///
/// Every element type must belong to this context. An unnamed empty struct is
/// not accepted by this API; give it a name or use an opaque struct.
///
/// **Panics:**
///
/// Panics when both `name` and `elements` are empty.
///
/// **Lifecycle:**
///
/// The returned type retains this context.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let i32ty = ctx.getInt32Ty()
///   let f32ty = ctx.getFloatTy()
///   let f64ty = ctx.getDoubleTy()
///
///   let sty = ctx.getStructType([i32ty, f32ty, f64ty], name="foo")
///   inspect(sty, content="%foo = type { i32, float, double }")
/// }
/// ```
pub fn Context::getStructType(
  self : Context,
  elements : Array[&Type],
  isPacked? : Bool = false,
  name? : String = "",
) -> StructType raise StringError {
  guard !(name.is_empty() && elements.is_empty()) else {
    println(
      "Error: Misuse `Context::getStructType`:  Empty struct type must have a name.",
    )
    panic()
  }
  let field_types = elements.map(v => v.get_raw_type_ref())
  let typeref = match name {
    "" =>
      @raw.llvm_struct_type_in_context(
        self.get_raw_ref(),
        field_types,
        isPacked,
      )
    _ as name => {
      let typeref = @raw.llvm_struct_create_named(self.get_raw_ref(), name) catch {
        @raw.EmbeddedNul => raise ContainsNul
      }
      @raw.llvm_struct_set_body(typeref, field_types, isPacked)
      typeref
    }
  }
  StructType::from_raw(typeref, self)
}

///|
/// Create an opaque named struct type in the context.
///
/// The body can be defined later with `StructType::setBody`.
/// An empty struct created by `Context::getStructType([], name=...)` is not
/// opaque: it has a known body containing zero elements.
///
/// **Parameters:**
///
/// - `name`: The identified-struct name. It must not contain an embedded NUL
///   byte.
///
/// **Errors:**
///
/// - `StringError::ContainsNul` if `name` contains an embedded NUL byte.
///
/// **Lifecycle:**
///
/// The returned type retains this context.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let opaque_type = ctx.getOpaqueStructType("Node")
///   assert_true(opaque_type.isOpaque())
///   inspect(opaque_type, content="%Node = type opaque")
/// }
/// ```
pub fn Context::getOpaqueStructType(
  self : Context,
  name : String,
) -> StructType raise StringError {
  let typeref = @raw.llvm_struct_create_named(self.get_raw_ref(), name) catch {
    @raw.EmbeddedNul => raise ContainsNul
  }
  StructType::from_raw(typeref, self)
}

///|
/// Finds an identified struct type registered in this context.
///
/// **Returns:**
///
/// The context-owned struct type, or `None` if no type with that name is
/// registered. A name containing an embedded NUL also produces `None` because
/// this nullable lookup has no error channel.
///
/// **Lifecycle:**
///
/// A returned type retains this context.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let i32ty = ctx.getInt32Ty()
///   let f32ty = ctx.getFloatTy()
///
///   let _ = ctx.getStructType([i32ty, f32ty], name="foo")
///
///   match ctx.getStructTypeByName("foo") {
///     Some(sty) => inspect(sty, content="%foo = type { i32, float }")
///     None => fail("expected the named struct type")
///   }
/// }
/// ```
pub fn Context::getStructTypeByName(self : Self, name : String) -> StructType? {
  let typeref = @raw.llvm_get_type_by_name(self.get_raw_ref(), name)
  unless(typeref.is_null(), () => StructType::from_raw(typeref, self))
}

///|
/// Returns a fixed-length array type in this context.
///
/// **Parameters:**
///
/// - `elementType`: The repeated element type.
/// - `numElements`: The fixed number of elements.
///
/// **Preconditions:**
///
/// `elementType` must belong to this context and `numElements` must be
/// non-negative. This API does not currently validate the count before passing
/// it to LLVM.
///
/// **Lifecycle:**
///
/// The returned type retains this context.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let i32ty = ctx.getInt32Ty()
///
///   let arrty = ctx.getArrayType(i32ty, 16)
///   inspect(arrty, content="[16 x i32]")
///   inspect(arrty.getElementType(), content="i32")
///
///   assert_eq(arrty.getElementCount(), 16)
/// }
/// ```
pub fn Context::getArrayType(
  self : Context,
  elementType : &Type,
  numElements : Int,
) -> ArrayType {
  let typeref = @raw.llvm_array_type(
    (elementType : &Type).get_raw_type_ref(),
    numElements.reinterpret_as_uint(),
  )
  ArrayType::from_raw(typeref, self)
}

///|
/// Returns a fixed-length vector type in this context.
///
/// **Parameters:**
///
/// - `elementType`: A type valid as an LLVM vector element.
/// - `elementQuantity`: The exact lane count.
///
/// **Preconditions:**
///
/// `elementType` must belong to this context and `elementQuantity` must be a
/// positive count accepted by LLVM. This API does not currently validate it.
///
/// **Lifecycle:**
///
/// The returned type retains this context.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let i32ty = ctx.getInt32Ty()
///
///   let fixedVecTy = ctx.getFixedVectorType(i32ty, 32)
///   inspect(fixedVecTy, content="<32 x i32>")
/// }
/// ```
/// TODO: add elementQuantity check.
pub fn[T : Type] Context::getFixedVectorType(
  self : Context,
  elementType : T,
  elementQuantity : Int,
) -> VectorType {
  //if elementQuantity <= 1 {}
  let typeref = @raw.llvm_vector_type(
    (elementType : &Type).get_raw_type_ref(),
    elementQuantity.reinterpret_as_uint(),
  )
  VectorType::from_raw(typeref, self)
}

///|
/// Returns a scalable vector type in this context.
///
/// Its runtime lane count is a target-dependent multiple of
/// `elementQuantity`, written by LLVM as `vscale x elementQuantity`.
///
/// **Parameters:**
///
/// - `elementType`: A type valid as an LLVM vector element.
/// - `elementQuantity`: The known minimum lane count.
///
/// **Preconditions:**
///
/// `elementType` must belong to this context and `elementQuantity` must be a
/// positive count accepted by LLVM. This API does not currently validate it.
///
/// **Lifecycle:**
///
/// The returned type retains this context.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let i32ty = ctx.getInt32Ty()
///
///   let scalableVecTy = ctx.getScalableVectorType(i32ty, 16)
///   inspect(scalableVecTy, content="<vscale x 16 x i32>")
/// }
/// ```
/// TODO: add elementQuantity check.
pub fn Context::getScalableVectorType(
  self : Context,
  elementType : &Type,
  elementQuantity : UInt,
) -> ScalableVectorType {
  let typeref = @raw.llvm_scalable_vector_type(
    (elementType : &Type).get_raw_type_ref(),
    elementQuantity,
  )
  ScalableVectorType::from_raw(typeref, self)
}

///|
/// Returns the `i1 true` constant owned by this context.
///
/// **Lifecycle:**
///
/// The returned constant retains this context and is not owned by a Module.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("const_true")
///   let builder = ctx.createBuilder()
///
///   let i1ty = ctx.getInt1Ty()
///   let fty = ctx.getFunctionType(i1ty, [])
///   let fval = mod.addFunction(fty, "const_true")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let const_true1 = ctx.getConstTrue()
///   let const_true2 = ctx.getConstTrue()
///
///   let const_xor = builder.createXor(const_true1, const_true2)
///
///   inspect(const_true1, content="i1 true")
///   inspect(const_true2, content="i1 true")
///   inspect(const_xor, content="i1 false")
/// }
/// ```
pub fn Context::getConstTrue(self : Self) -> ConstantInt {
  let valueref = @raw.llvm_const_int(
    self.getInt1Ty().get_raw_type_ref(),
    1,
    true,
  )
  ConstantInt::from_raw(valueref, self)
}

///|
/// Returns the `i1 false` constant owned by this context.
///
/// **Lifecycle:**
///
/// The returned constant retains this context and is not owned by a Module.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("const_false")
///   let builder = ctx.createBuilder()
///
///   let i1ty = ctx.getInt1Ty()
///   let fty = ctx.getFunctionType(i1ty, [])
///   let fval = mod.addFunction(fty, "const_false")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let const_false = ctx.getConstFalse()
///   let const_true = ctx.getConstTrue()
///   let const_or = builder.createOr(const_false, const_true)
///
///   inspect(const_false, content="i1 false")
///   inspect(const_or, content="i1 true")
/// }
/// ```
pub fn Context::getConstFalse(self : Self) -> ConstantInt {
  let valueref = @raw.llvm_const_int(
    self.getInt1Ty().get_raw_type_ref(),
    0,
    true,
  )
  ConstantInt::from_raw(valueref, self)
}

///|
/// Returns an `i8` constant from the low eight bits of `val`.
///
/// Values outside the signed eight-bit range are truncated modulo 2^8. The
/// signed designation controls sign extension of the input to LLVM, not the
/// bit pattern stored in the constant.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("const_int8")
///   let builder = ctx.createBuilder()
///
///   let i8ty = ctx.getInt8Ty()
///   let fty = ctx.getFunctionType(i8ty, [])
///   let fval = mod.addFunction(fty, "const_int8")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let const_42 = ctx.getConstInt8(42)
///   let const_neg1 = ctx.getConstInt8(-1)
///   let const_add = builder.createAdd(const_42, const_neg1)
///
///   inspect(const_42, content="i8 42")
///   inspect(const_neg1, content="i8 -1")
///   inspect(const_add, content="i8 41")
/// }
/// ```
pub fn Context::getConstInt8(self : Self, val : Int) -> ConstantInt {
  let valueref = @raw.llvm_const_int(
    self.getInt8Ty().get_raw_type_ref(),
    val.to_uint64(),
    true,
  )
  ConstantInt::from_raw(valueref, self)
}

///|
/// Returns an `i8` constant from the low eight bits of `val`.
///
/// Values outside the unsigned eight-bit range are truncated modulo 2^8. LLVM
/// integers are signless; “unsigned” describes how the input is interpreted.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("const_uint8")
///   let builder = ctx.createBuilder()
///
///   let i8ty = ctx.getInt8Ty()
///   let fty = ctx.getFunctionType(i8ty, [])
///   let fval = mod.addFunction(fty, "const_uint8")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let const_255 = ctx.getConstUInt8(255)
///   let const_1 = ctx.getConstUInt8(1)
///   let const_add = builder.createAdd(const_255, const_1)
///
///   inspect(const_255, content="i8 -1")
///   inspect(const_1, content="i8 1")
///   inspect(const_add, content="i8 0")
/// }
/// ```
pub fn Context::getConstUInt8(self : Self, val : Int) -> ConstantInt {
  let valueref = @raw.llvm_const_int(
    self.getInt8Ty().get_raw_type_ref(),
    val.to_uint64(),
    false,
  )
  ConstantInt::from_raw(valueref, self)
}

///|
/// Returns an `i16` constant from the low 16 bits of `val`.
///
/// Values outside the signed 16-bit range are truncated modulo 2^16. The
/// signed designation controls sign extension of the input to LLVM.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("const_int16")
///   let builder = ctx.createBuilder()
///
///   let i16ty = ctx.getInt16Ty()
///   let fty = ctx.getFunctionType(i16ty, [])
///   let fval = mod.addFunction(fty, "const_int16")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let const_1000 = ctx.getConstInt16(1000)
///   let const_neg500 = ctx.getConstInt16(-500)
///   let const_sub = builder.createSub(const_1000, const_neg500)
///
///   inspect(const_1000, content="i16 1000")
///   inspect(const_neg500, content="i16 -500")
///   inspect(const_sub, content="i16 1500")
/// }
/// ```
pub fn Context::getConstInt16(self : Self, val : Int) -> ConstantInt {
  let valueref = @raw.llvm_const_int(
    self.getInt16Ty().get_raw_type_ref(),
    val.to_uint64(),
    true,
  )
  ConstantInt::from_raw(valueref, self)
}

///|
/// Returns an `i16` constant with the bit pattern of `val`.
///
/// LLVM integers are signless; “unsigned” describes how the input is
/// interpreted by this constructor.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("const_uint16")
///   let builder = ctx.createBuilder()
///
///   let i16ty = ctx.getInt16Ty()
///   let fty = ctx.getFunctionType(i16ty, [])
///   let fval = mod.addFunction(fty, "const_uint16")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let const_65535 = ctx.getConstUInt16(65535)
///   let const_1 = ctx.getConstUInt16(1)
///   let const_add = builder.createAdd(const_65535, const_1)
///
///   inspect(const_65535, content="i16 -1")
///   inspect(const_1, content="i16 1")
///   inspect(const_add, content="i16 0")
/// }
/// ```
pub fn Context::getConstUInt16(self : Self, val : UInt16) -> ConstantInt {
  let valueref = @raw.llvm_const_int(
    self.getInt16Ty().get_raw_type_ref(),
    val.to_uint64(),
    false,
  )
  ConstantInt::from_raw(valueref, self)
}

///|
/// Returns an `i32` constant with the 32-bit two's-complement pattern of `val`.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("const_int32")
///   let builder = ctx.createBuilder()
///
///   let i32ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32ty, [])
///   let fval = mod.addFunction(fty, "const_int32")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let const_123456 = ctx.getConstInt32(123456)
///   let const_neg789 = ctx.getConstInt32(-789)
///   let const_mul = builder.createMul(const_123456, const_neg789)
///
///   inspect(const_123456, content="i32 123456")
///   inspect(const_neg789, content="i32 -789")
///   inspect(const_mul, content="i32 -97406784")
/// }
/// ```
pub fn Context::getConstInt32(self : Self, val : Int) -> ConstantInt {
  let valueref = @raw.llvm_const_int(
    self.getInt32Ty().get_raw_type_ref(),
    val.to_uint64(),
    true,
  )
  ConstantInt::from_raw(valueref, self)
}

///|
/// Returns an `i32` constant with the bit pattern of `val`.
///
/// LLVM integers are signless; “unsigned” describes how the input is
/// interpreted by this constructor.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("const_uint32")
///   let builder = ctx.createBuilder()
///
///   let i32ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32ty, [])
///   let fval = mod.addFunction(fty, "const_uint32")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let const_4294967295 = ctx.getConstUInt32(4294967295U)
///   let const_1 = ctx.getConstUInt32(1U)
///   let const_add = builder.createAdd(const_4294967295, const_1)
///
///   inspect(const_4294967295, content="i32 -1")
///   inspect(const_1, content="i32 1")
///   inspect(const_add, content="i32 0")
/// }
/// ```
pub fn Context::getConstUInt32(self : Self, val : UInt) -> ConstantInt {
  let valueref = @raw.llvm_const_int(
    self.getInt32Ty().get_raw_type_ref(),
    val.to_uint64(),
    false,
  )
  ConstantInt::from_raw(valueref, self)
}

///|
/// Returns an `i64` constant with the 64-bit two's-complement pattern of `val`.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("const_int64")
///   let builder = ctx.createBuilder()
///
///   let i64ty = ctx.getInt64Ty()
///   let fty = ctx.getFunctionType(i64ty, [])
///   let fval = mod.addFunction(fty, "const_int64")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let const_big = ctx.getConstInt64(9223372036854775807L)
///   let const_1 = ctx.getConstInt64(1L)
///   let const_add = builder.createAdd(const_big, const_1)
///
///   inspect(const_big, content="i64 9223372036854775807")
///   inspect(const_1, content="i64 1")
///   inspect(const_add, content="i64 -9223372036854775808")
/// }
/// ```
pub fn Context::getConstInt64(self : Self, val : Int64) -> ConstantInt {
  let valueref = @raw.llvm_const_int(
    self.getInt64Ty().get_raw_type_ref(),
    val.reinterpret_as_uint64(),
    true,
  )
  ConstantInt::from_raw(valueref, self)
}

///|
/// Returns an `i64` constant with the bit pattern of `val`.
///
/// LLVM integers are signless; “unsigned” describes how the input is
/// interpreted by this constructor.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("const_uint64")
///   let builder = ctx.createBuilder()
///
///   let i64ty = ctx.getInt64Ty()
///   let fty = ctx.getFunctionType(i64ty, [])
///   let fval = mod.addFunction(fty, "const_uint64")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let const_max = ctx.getConstUInt64(18446744073709551615UL)
///   let const_1 = ctx.getConstUInt64(1UL)
///   let const_add = builder.createAdd(const_max, const_1)
///
///   inspect(const_max, content="i64 -1")
///   inspect(const_1, content="i64 1")
///   inspect(const_add, content="i64 0")
/// }
/// ```
pub fn Context::getConstUInt64(self : Self, val : UInt64) -> ConstantInt {
  let valueref = @raw.llvm_const_int(
    self.getInt64Ty().get_raw_type_ref(),
    val,
    false,
  )
  ConstantInt::from_raw(valueref, self)
}

///|
/// Returns a binary32 floating-point constant from `val`.
///
/// The MoonBit `Float` value is converted to `Double` only for the LLVM-C call;
/// LLVM rounds the result to the destination binary32 semantics.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("const_float")
///   let builder = ctx.createBuilder()
///
///   let f32ty = ctx.getFloatTy()
///   let fty = ctx.getFunctionType(f32ty, [])
///   let fval = mod.addFunction(fty, "const_float")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let const_pi = ctx.getConstFloat(3.14159)
///   let const_2 = ctx.getConstFloat(2.0)
///   let const_mul = builder.createFMul(const_pi, const_2)
///
///   inspect(const_pi, content="float 0x400921FA00000000")
///   inspect(const_2, content="float 2.000000e+00")
///   inspect(const_mul, content="float 0x401921FA00000000")
/// }
/// ```
pub fn Context::getConstFloat(self : Self, val : Float) -> ConstantFP {
  let valueref = @raw.llvm_const_real(
    self.getFloatTy().get_raw_type_ref(),
    val.to_double(),
  )
  ConstantFP::from_raw(valueref, self)
}

///|
/// Returns positive or negative zero with binary32 type.
///
/// **Parameters:**
///
/// - `isNegative`: Whether to set the IEEE 754 sign bit.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///
///   let zero = ctx.getConstZeroFloat(isNegative=false)
///   let neg_zero = ctx.getConstZeroFloat(isNegative=true)
///
///   inspect(zero, content="float 0.000000e+00")
///   inspect(neg_zero, content="float -0.000000e+00")
/// }
/// ```
pub fn Context::getConstZeroFloat(
  self : Self,
  isNegative~ : Bool,
) -> ConstantFP {
  let val = if isNegative { 0x8000_0000U } else { 0x0000_0000U }
  let val = Float::reinterpret_from_uint(val)
  let valueref = @raw.llvm_const_real(
    self.getFloatTy().get_raw_type_ref(),
    val.to_double(),
  )
  ConstantFP::from_raw(valueref, self)
}

///|
/// Returns a binary64 floating-point constant with value `val`.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("const_double")
///   let builder = ctx.createBuilder()
///
///   let f64ty = ctx.getDoubleTy()
///   let fty = ctx.getFunctionType(f64ty, [])
///   let fval = mod.addFunction(fty, "const_double")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let const_e = ctx.getConstDouble(2.718281828)
///   let const_10 = ctx.getConstDouble(10.0)
///   let const_div = builder.createFDiv(const_10, const_e)
///
///   inspect(const_e, content="double 0x4005BF0A8B04919B")
///   inspect(const_10, content="double 1.000000e+01")
///   inspect(const_div, content="double 0x400D6E2BC3CD8399")
/// }
/// ```
pub fn Context::getConstDouble(self : Self, val : Double) -> ConstantFP {
  let valueref = @raw.llvm_const_real(
    self.getDoubleTy().get_raw_type_ref(),
    val,
  )
  ConstantFP::from_raw(valueref, self)
}

///|
/// Returns positive or negative zero with binary64 type.
///
/// **Parameters:**
///
/// - `isNegative`: Whether to set the IEEE 754 sign bit.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///
///   let zero = ctx.getConstZeroDouble(isNegative=false)
///   let neg_zero = ctx.getConstZeroDouble(isNegative=true)
///
///   inspect(zero, content="double 0.000000e+00")
///   inspect(neg_zero, content="double -0.000000e+00")
/// }
/// ```
pub fn Context::getConstZeroDouble(
  self : Self,
  isNegative~ : Bool,
) -> ConstantFP {
  let val = if isNegative {
    0x8000_0000_0000_0000UL
  } else {
    0x0000_0000_0000_0000UL
  }
  let val = val.reinterpret_as_double()
  let valueref = @raw.llvm_const_real(
    self.getDoubleTy().get_raw_type_ref(),
    val,
  )
  ConstantFP::from_raw(valueref, self)
}

///|
/// Returns an array constant containing `elements` in source order.
///
/// **Parameters:**
///
/// - `elementType`: The declared element type of the resulting array.
/// - `elements`: The constant elements in source order; the array length is
///   inferred from this collection.
///
/// **Preconditions:**
///
/// `elementType` and every element must belong to this context, and every
/// element must have `elementType`. Violating these conditions may trigger an
/// LLVM assertion.
///
/// **Lifecycle:**
///
/// The returned constant retains this context and is not owned by a Module.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("const_array")
///   let builder = ctx.createBuilder()
///
///   let i32ty = ctx.getInt32Ty()
///   let arr_ty = ctx.getArrayType(i32ty, 3)
///   let fty = ctx.getFunctionType(arr_ty, [])
///   let fval = mod.addFunction(fty, "const_array")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let const_1 = ctx.getConstInt32(1)
///   let const_2 = ctx.getConstInt32(2)
///   let const_3 = ctx.getConstInt32(3)
///   let const_array = ctx.getConstArray(i32ty, [const_1, const_2, const_3])
///
///   inspect(const_array, content="[3 x i32] [i32 1, i32 2, i32 3]")
/// }
/// ```
pub fn Context::getConstArray(
  self : Self,
  elementType : &Type,
  elements : Array[&Constant],
) -> ConstantArray {
  let element_refs = elements.map(v => (v : &Value).get_raw_value_ref())
  let valueref = @raw.llvm_const_array2(
    (elementType : &Type).get_raw_type_ref(),
    element_refs,
  )
  ConstantArray::from_raw(valueref, self)
}

///|
/// Returns a fixed-vector constant containing the supplied scalar values.
///
/// **Parameters:**
///
/// - `scalar_constant_vals`: The lanes in source order. Their common type and
///   the array length determine the resulting vector type.
///
/// **Preconditions:**
///
/// The array must be non-empty. Every lane must be a constant of the same valid
/// vector-element type and must belong to this context. Violating these
/// conditions may trigger an LLVM assertion.
///
/// **Lifecycle:**
///
/// The returned constant retains this context and is not owned by a Module.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("const_vector")
///   let builder = ctx.createBuilder()
///
///   let i32ty = ctx.getInt32Ty()
///   let vec_ty = ctx.getFixedVectorType(i32ty, 4)
///   let fty = ctx.getFunctionType(vec_ty, [])
///   let fval = mod.addFunction(fty, "const_vector")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let const_1 = ctx.getConstInt32(1)
///   let const_2 = ctx.getConstInt32(2)
///   let const_3 = ctx.getConstInt32(3)
///   let const_4 = ctx.getConstInt32(4)
///   let const_vector = ctx.getConstVector([const_1, const_2, const_3, const_4])
///
///   inspect(const_vector, content="<4 x i32> <i32 1, i32 2, i32 3, i32 4>")
/// }
/// ```
pub fn Context::getConstVector(
  self : Self,
  scalar_constant_vals : Array[&Constant],
) -> ConstantVector {
  let scalar_refs = scalar_constant_vals.map(v => {
    (v : &Value).get_raw_value_ref()
  })
  let valueref = @raw.llvm_const_vector(scalar_refs)
  ConstantVector::from_raw(valueref, self)
}

///|
/// Returns a literal struct constant whose fields are inferred from `elements`.
///
/// **Parameters:**
///
/// - `elements`: Field constants in layout order.
/// - `isPacked`: Whether the inferred literal struct type omits ABI padding
///   between fields.
///
/// **Preconditions:**
///
/// Every element must belong to this context. This function creates a literal
/// struct constant; it does not construct a value of an existing named struct
/// type.
///
/// **Lifecycle:**
///
/// The returned constant retains this context and is not owned by a Module.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("const_struct")
///   let builder = ctx.createBuilder()
///
///   let i32ty = ctx.getInt32Ty()
///   let f32ty = ctx.getFloatTy()
///   let struct_ty = ctx.getStructType([i32ty, f32ty])
///   let fty = ctx.getFunctionType(struct_ty, [])
///   let fval = mod.addFunction(fty, "const_struct")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let const_42 = ctx.getConstInt32(42)
///   let const_pi = ctx.getConstFloat(3.14)
///   let const_struct = ctx.getConstStruct([const_42, const_pi])
///
///   inspect(
///     const_struct,
///     content="{ i32, float } { i32 42, float 0x40091EB860000000 }",
///   )
/// }
/// ```
pub fn Context::getConstStruct(
  self : Self,
  elements : Array[&Constant],
  isPacked? : Bool = false,
) -> ConstantStruct {
  let element_refs = elements.map(v => (v : &Value).get_raw_value_ref())
  let valueref = @raw.llvm_const_struct_in_context(
    self.get_raw_ref(),
    element_refs,
    isPacked,
  )
  ConstantStruct::from_raw(valueref, self)
}

///|
/// Returns the LLVM `undef` constant for `ty`.
///
/// Each use of `undef` may independently observe an arbitrary value of `ty`;
/// it must not be treated as a stable but unknown value.
///
/// **Preconditions:**
///
/// `ty` must belong to this context.
///
/// **Lifecycle:**
///
/// The returned constant retains this context and is not owned by a Module.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("undef_test")
///   let builder = ctx.createBuilder()
///
///   let i32ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32ty, [])
///   let fval = mod.addFunction(fty, "undef_test")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let undef_val = ctx.getUndef(i32ty)
///   let const_10 = ctx.getConstInt32(10)
///   let result = builder.createAdd(undef_val, const_10)
///
///   inspect(undef_val, content="i32 undef")
///   inspect(result, content="i32 undef")
/// }
/// ```
pub fn Context::getUndef(self : Self, ty : &Type) -> UndefValue {
  let valueref = @raw.llvm_get_undef(ty.get_raw_type_ref())
  UndefValue::from_raw(valueref, self)
}

///|
/// Returns the LLVM `poison` constant for `ty`.
///
/// Poison generally propagates through instructions until it reaches an
/// operation for which poison is immediately undefined behavior; `freeze` and
/// instruction-specific rules may stop or alter that propagation.
///
/// **Preconditions:**
///
/// `ty` must belong to this context.
///
/// **Lifecycle:**
///
/// The returned constant retains this context and is not owned by a Module.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("poison_test")
///   let builder = ctx.createBuilder()
///
///   let i32ty = ctx.getInt32Ty()
///   let fty = ctx.getFunctionType(i32ty, [])
///   let fval = mod.addFunction(fty, "poison_test")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let poison_val = ctx.getPoision(i32ty)
///   let const_5 = ctx.getConstInt32(5)
///   let result = builder.createMul(poison_val, const_5)
///
///   inspect(poison_val, content="i32 poison")
///   inspect(result, content="i32 poison")
/// }
/// ```
pub fn Context::getPoision(self : Self, ty : &Type) -> PoisonValue {
  let valueref = @raw.llvm_get_poison(ty.get_raw_type_ref())
  PoisonValue::from_raw(valueref, self)
}

///|
/// Returns the null pointer constant of pointer type `ty`.
///
/// **Preconditions:**
///
/// `ty` must be a PointerType belonging to this context. This API accepts the
/// broader `&Type` trait and does not validate the kind before calling LLVM.
///
/// **Lifecycle:**
///
/// The returned constant retains this context and is not owned by a Module.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("null_ptr_test")
///   let builder = ctx.createBuilder()
///
///   let ptr_ty = ctx.getPtrTy()
///   let fty = ctx.getFunctionType(ptr_ty, [])
///   let fval = mod.addFunction(fty, "null_ptr_test")
///   let entry = fval.addBasicBlock(name="entry")
///   builder.setInsertPoint(entry)
///
///   let null_ptr = ctx.getConstPointerNull(ptr_ty)
///   inspect(null_ptr, content="ptr null")
/// }
/// ```
pub fn Context::getConstPointerNull(
  self : Self,
  ty : &Type,
) -> ConstantPointerNull {
  let valueref = @raw.llvm_const_pointer_null(ty.get_raw_type_ref())
  ConstantPointerNull::from_raw(valueref, self)
}
