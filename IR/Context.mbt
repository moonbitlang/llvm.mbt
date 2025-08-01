///|
pub type Context @unsafe.LLVMContextRef derive(Eq)

///|
pub fn Context::drop(self : Context) -> Unit {
  @unsafe.llvm_context_dispose(self.inner())
}

///|
pub fn Context::new() -> Context {
  Context(@unsafe.llvm_context_create())
}

///|
pub fn Context::addModule(self : Self, name : String) -> Module {
  let mod = Module(
    @unsafe.llvm_module_create_with_name_in_context(name, self.inner()),
  )
  mod.setDefaultDataLayout()
  mod
}

///|
pub fn Context::createBuilder(self : Self) -> IRBuilder {
  IRBuilder::{
    builder_ref: @unsafe.llvm_create_builder_in_context(self.inner()),
    positioned: NotSet,
  }
}

///| Get the half type from context.
///
/// - See LLVM: `Type::getHalfTy`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let half_ty = ctx.getHalfTy()
/// inspect(half_ty, content="half")
/// ```
pub fn Context::getHalfTy(self : Context) -> HalfType {
  let typeref = @unsafe.llvm_half_type_in_context(self.inner())
  HalfType(typeref)
}

///| Get the bfloat type from context.
///
/// - See LLVM: `Type::getBFloatTy`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let bfloat_ty = ctx.getBFloatTy()
/// inspect(bfloat_ty, content="bfloat")
/// ```
pub fn Context::getBFloatTy(self : Context) -> BFloatType {
  let typeref = @unsafe.llvm_bfloat_type_in_context(self.inner())
  BFloatType(typeref)
}

///| Get the float type from context.
///
/// - See LLVM: `Type::getFloatTy`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let f32ty = ctx.getFloatTy()
/// inspect(f32ty, content="float")
/// ```
pub fn Context::getFloatTy(self : Context) -> FloatType {
  let typeref = @unsafe.llvm_float_type_in_context(self.inner())
  FloatType(typeref)
}

///| Get the double type from context.
///
/// - See LLVM: `Type::getDoubleTy`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let doubletype = ctx.getDoubleTy()
/// inspect(doubletype, content="double")
/// ```
pub fn Context::getDoubleTy(self : Context) -> DoubleType {
  let typeref = @unsafe.llvm_double_type_in_context(self.inner())
  DoubleType(typeref)
}

///| Get the fp128 type from context.
///
/// - See LLVM: `Type::getFP128Ty`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let fp128ty = ctx.getFP128Ty()
/// inspect(fp128ty, content="fp128")
/// ```
pub fn Context::getFP128Ty(self : Context) -> FP128Type {
  let typeref = @unsafe.llvm_fp128_type_in_context(self.inner())
  FP128Type(typeref)
}

///| Get the void type from context.
///
/// - See LLVM: `Type::getVoidTy`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let voidty = ctx.getVoidTy()
/// inspect(voidty, content="void")
/// ```
pub fn Context::getVoidTy(self : Context) -> VoidType {
  let typeref = @unsafe.llvm_void_type_in_context(self.inner())
  VoidType(typeref)
}

///| Get the label type from context.
pub fn Context::getLabelTy(self : Context) -> LabelType {
  let typeref = @unsafe.llvm_label_type_in_context(self.inner())
  LabelType(typeref)
}

///| Get the metadata type from context.
pub fn Context::getMetadataTy(self : Context) -> MetadataType {
  let typeref = @unsafe.llvm_metadata_type_in_context(self.inner())
  MetadataType(typeref)
}

///| Get the token type from context.
///
/// - See LLVM: `Type::getTokenTy`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let tokenty = ctx.getTokenTy()
/// inspect(tokenty, content="token")
/// ```
pub fn Context::getTokenTy(self : Context) -> TokenType {
  let typeref = @unsafe.llvm_token_type_in_context(self.inner())
  TokenType(typeref)
}

///| Get the integer type with 1 bit from context.
///
/// ```moonbit
/// let ctx = Context::new()
///
/// let i1ty = ctx.getInt1Ty()
/// assert_eq(i1ty.getBitWidth(), 1)
/// inspect(i1ty, content="i1")
/// ```
pub fn Context::getInt1Ty(self : Context) -> Int1Type {
  let typeref = @unsafe.llvm_int1_type_in_context(self.inner())
  Int1Type(typeref)
}

///| Get the integer type with 8 bits from context.
///
/// ```moonbit
/// let ctx = Context::new()
///
/// let i8ty = ctx.getInt8Ty()
/// assert_eq(i8ty.getBitWidth(), 8)
/// inspect(i8ty, content="i8")
/// ```
pub fn Context::getInt8Ty(self : Context) -> Int8Type {
  let typeref = @unsafe.llvm_int8_type_in_context(self.inner())
  Int8Type(typeref)
}

///| Get the integer type with 16 bits from context.
///
/// ```moonbit
/// let ctx = Context::new()
///
/// let i16ty = ctx.getInt16Ty()
/// assert_eq(i16ty.getBitWidth(), 16)
/// inspect(i16ty, content="i16")
/// ```
pub fn Context::getInt16Ty(self : Context) -> Int16Type {
  let typeref = @unsafe.llvm_int16_type_in_context(self.inner())
  Int16Type(typeref)
}

///| Get the integer type with 32 bits from context.
///
/// ```moonbit
/// let ctx = Context::new()
///
/// let i32ty = ctx.getInt32Ty()
/// assert_eq(i32ty.getBitWidth(), 32)
/// inspect(i32ty, content="i32")
/// ```
pub fn Context::getInt32Ty(self : Context) -> Int32Type {
  let typeref = @unsafe.llvm_int32_type_in_context(self.inner())
  Int32Type(typeref)
}

///| Get the integer type with 64 bits from context.
///
/// ```moonbit
/// let ctx = Context::new()
///
/// let i64ty = ctx.getInt64Ty()
/// assert_eq(i64ty.getBitWidth(), 64)
/// inspect(i64ty, content="i64")
/// ```
pub fn Context::getInt64Ty(self : Context) -> Int64Type {
  let typeref = @unsafe.llvm_int64_type_in_context(self.inner())
  Int64Type(typeref)
}

///| Get the Pointer type from context.
///
/// - See LLVM: `PointerType::get`.
///
/// **Note**:
/// 
///   After LLVM17, typed pointer has been deprecated. Therefore in 
///   Moonbit Aether framework, all pointer type is opaque.
///
/// ```moonbit
/// let ctx = Context::new()
///
/// inspect(ctx.getPtrTy(), content="ptr")
/// 
/// let addressSpace = AddressSpace::new(1)
/// inspect(ctx.getPtrTy(addressSpace~), content="ptr addrspace(1)")
/// ```
pub fn Context::getPtrTy(
  self : Context,
  addressSpace~ : AddressSpace = AddressSpace::default(),
) -> PointerType {
  let typeref = @unsafe.llvm_pointer_type_in_context(
    self.inner(),
    addressSpace.inner(),
  )
  PointerType(typeref)
}

///| Create a function type.
///
/// This is different with the method of creating function type in LLVM.
/// In LLVM, usually use `FunctionType::get` to create a function type.
///
/// In Moonbit Aether framework, we use `Context::getFunctionType` to create a function type.
///
/// - See LLVM: `FunctionType::get`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let voidty = ctx.getVoidTy()
/// let i32ty = ctx.getInt32Ty()
/// let f64ty = ctx.getDoubleTy()
///
/// let fty = ctx.getFunctionType(voidty, [i32ty, f64ty])
/// inspect(fty, content="void (i32, double)")
/// ```
pub fn Context::getFunctionType(
  self : Context,
  returnType : &Type,
  paramTypes : Array[&Type],
  isVarArg~ : Bool = false,
) -> FunctionType {
  ignore(self)
  let ret_ty = returnType.getTypeRef()
  let param_tyrefs = paramTypes.map(v => v.getTypeRef())
  let fty_ref = @unsafe.llvm_function_type(ret_ty, param_tyrefs, isVarArg)
  FunctionType(fty_ref)
}

///| Create a struct type in the context.
///
/// This is different with the method of creating struct type in LLVM.
/// In LLVM, usually use `StructType::create` to create a struct type.
///
/// In Moonbit Aether framework, we use `Context::getStructType` to create a struct type.
///
/// - See LLVM: `StructType::create`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let i32ty = ctx.getInt32Ty()
/// let f32ty = ctx.getFloatTy()
/// let f64ty = ctx.getDoubleTy()
///
/// let sty = ctx.getStructType([i32ty, f32ty, f64ty], name="foo")
/// inspect(sty, content="%foo = type { i32, float, double }")
/// ```
pub fn Context::getStructType(
  self : Context,
  elements : Array[&Type],
  isPacked~ : Bool = false,
  name~ : String = "",
) -> StructType {
  guard not(name.is_empty() && elements.is_empty()) else {
    println(
      "Error: Misuse `Context::getStructType`:  Empty struct type must have a name.",
    )
    panic()
  }
  let field_types = elements.map(v => v.getTypeRef())
  let typeref = match name {
    "" =>
      @unsafe.llvm_struct_type_in_context(self.inner(), field_types, isPacked)
    _ as name => {
      let typeref = @unsafe.llvm_struct_create_named(self.inner(), name)
      @unsafe.llvm_struct_set_body(typeref, field_types, isPacked)
      typeref
    }
  }
  StructType(typeref)
}

///| Search a named struct type in the context.
///
/// LLVM Cpp version has no this method, since llvm-cpp allow duplicated struct type names.
///
/// ```moonbit
/// let ctx = Context::new()
/// let i32ty = ctx.getInt32Ty()
/// let f32ty = ctx.getFloatTy()
///
/// let _ = ctx.getStructType([i32ty, f32ty], name="foo")
///
/// let sty = ctx.getStructTypeByName("foo").unwrap()
///
/// inspect(sty, content="%foo = type { i32, float }")
/// ```
pub fn Context::getStructTypeByName(self : Self, name : String) -> StructType? {
  let typeref = @unsafe.llvm_get_type_by_name(self.inner(), name)
  unless(typeref.is_null(), () => StructType(typeref))
}

///| Create an array type in the context.
///
/// This is different with the method of creating array type in LLVM.
/// In LLVM, usually use `ArrayType::get` to create an array type.
///
/// In Moonbit Aether framework, we use `Context::getArrayType` to create an array type.
///
/// - See LLVM: `ArrayType::get`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let i32ty = ctx.getInt32Ty()
///
/// let arrty = ctx.getArrayType(i32ty, 16)
/// inspect(arrty, content="[16 x i32]")
/// inspect(arrty.getElementType(), content="i32")
///
/// assert_eq(arrty.getElementCount(), 16)
/// ```
pub fn Context::getArrayType(
  self : Context,
  elementType : &Type,
  numElements : Int,
) -> ArrayType {
  ignore(self)
  let typeref = @unsafe.llvm_array_type(
    elementType.getTypeRef(),
    numElements.reinterpret_as_uint(),
  )
  ArrayType(typeref)
}

///| Create a fixed length vector type in the context.
///
/// - See LLVM: `FixedVectorType::get`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let i32ty = ctx.getInt32Ty()
///
/// let fixedVecTy = ctx.getFixedVectorType(i32ty, 32)
/// inspect(fixedVecTy, content="<32 x i32>")
/// ```
/// TODO: add elementQuantity check.
pub fn[T : Type] Context::getFixedVectorType(
  self : Context,
  elementType : T,
  elementQuantity : Int,
) -> VectorType {
  //if elementQuantity <= 1 {}
  ignore(self)
  let typeref = @unsafe.llvm_vector_type(
    elementType.getTypeRef(),
    elementQuantity.reinterpret_as_uint(),
  )
  VectorType(typeref)
}

///| Create a scalable vector type in the context.
///
/// - See LLVM: `ScalableVectorType::get`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let i32ty = ctx.getInt32Ty()
///
/// let scalableVecTy = ctx.getScalableVectorType(i32ty, 16)
/// inspect(scalableVecTy, content="<vscale x 16 x i32>")
/// ```
/// TODO: add elementQuantity check.
pub fn Context::getScalableVectorType(
  self : Context,
  elementType : &Type,
  elementQuantity : UInt,
) -> ScalableVectorType {
  ignore(self)
  let typeref = @unsafe.llvm_scalable_vector_type(
    elementType.getTypeRef(),
    elementQuantity,
  )
  ScalableVectorType(typeref)
}

///| Create a constant integer `true`, the type is `i1`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("const_true")
/// let builder = ctx.createBuilder()
///
/// let i1ty = ctx.getInt1Ty()
/// let fty = ctx.getFunctionType(i1ty, [])
/// let fval = mod.addFunction(fty, "const_true")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let const_true1 = ctx.getConstTrue()
/// let const_true2 = ctx.getConstTrue()
///
/// let const_xor = builder.createXor(const_true1, const_true2)
///
/// inspect(const_true1, content="i1 true")
/// inspect(const_true2, content="i1 true")
/// inspect(const_xor, content="i1 false")
/// ```
pub fn Context::getConstTrue(self : Self) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(self.getInt1Ty().getTypeRef(), 1, true)
  ConstantInt(valueref)
}

///| Create a constant integer `false`, the type is `i1`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("const_false")
/// let builder = ctx.createBuilder()
///
/// let i1ty = ctx.getInt1Ty()
/// let fty = ctx.getFunctionType(i1ty, [])
/// let fval = mod.addFunction(fty, "const_false")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let const_false = ctx.getConstFalse()
/// let const_true = ctx.getConstTrue()
/// let const_or = builder.createOr(const_false, const_true)
///
/// inspect(const_false, content="i1 false")
/// inspect(const_or, content="i1 true")
/// ```
pub fn Context::getConstFalse(self : Self) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(self.getInt1Ty().getTypeRef(), 0, true)
  ConstantInt(valueref)
}

///| Create a constant signed 8-bit integer value.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("const_int8")
/// let builder = ctx.createBuilder()
///
/// let i8ty = ctx.getInt8Ty()
/// let fty = ctx.getFunctionType(i8ty, [])
/// let fval = mod.addFunction(fty, "const_int8")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let const_42 = ctx.getConstInt8(42)
/// let const_neg1 = ctx.getConstInt8(-1)
/// let const_add = builder.createAdd(const_42, const_neg1)
///
/// inspect(const_42, content="i8 42")
/// inspect(const_neg1, content="i8 -1") 
/// inspect(const_add, content="i8 41")
/// ```
pub fn Context::getConstInt8(self : Self, val : Int) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(
    self.getInt8Ty().getTypeRef(),
    val.to_uint64(),
    true,
  )
  ConstantInt(valueref)
}

///| Create a constant unsigned 8-bit integer value.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("const_uint8")
/// let builder = ctx.createBuilder()
///
/// let i8ty = ctx.getInt8Ty()
/// let fty = ctx.getFunctionType(i8ty, [])
/// let fval = mod.addFunction(fty, "const_uint8")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let const_255 = ctx.getConstUInt8(255)
/// let const_1 = ctx.getConstUInt8(1)
/// let const_add = builder.createAdd(const_255, const_1)
///
/// inspect(const_255, content="i8 -1")
/// inspect(const_1, content="i8 1")
/// inspect(const_add, content="i8 0")
/// ```
pub fn Context::getConstUInt8(self : Self, val : Int) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(
    self.getInt8Ty().getTypeRef(),
    val.to_uint64(),
    false,
  )
  ConstantInt(valueref)
}

///| Create a constant signed 16-bit integer value.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("const_int16")
/// let builder = ctx.createBuilder()
///
/// let i16ty = ctx.getInt16Ty()
/// let fty = ctx.getFunctionType(i16ty, [])
/// let fval = mod.addFunction(fty, "const_int16")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let const_1000 = ctx.getConstInt16(1000)
/// let const_neg500 = ctx.getConstInt16(-500)
/// let const_sub = builder.createSub(const_1000, const_neg500)
///
/// inspect(const_1000, content="i16 1000")
/// inspect(const_neg500, content="i16 -500")
/// inspect(const_sub, content="i16 1500")
/// ```
pub fn Context::getConstInt16(self : Self, val : Int) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(
    self.getInt16Ty().getTypeRef(),
    val.to_uint64(),
    true,
  )
  ConstantInt(valueref)
}

///| Create a constant unsigned 16-bit integer value.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("const_uint16")
/// let builder = ctx.createBuilder()
///
/// let i16ty = ctx.getInt16Ty()
/// let fty = ctx.getFunctionType(i16ty, [])
/// let fval = mod.addFunction(fty, "const_uint16")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let const_65535 = ctx.getConstUInt16(65535) 
/// let const_1 = ctx.getConstUInt16(1)
/// let const_add = builder.createAdd(const_65535, const_1)
///
/// inspect(const_65535, content="i16 -1")
/// inspect(const_1, content="i16 1")
/// inspect(const_add, content="i16 0")
/// ```
pub fn Context::getConstUInt16(self : Self, val : UInt16) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(
    self.getInt16Ty().getTypeRef(),
    val.to_uint64(),
    false,
  )
  ConstantInt(valueref)
}

///| Create a constant signed 32-bit integer value.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("const_int32")
/// let builder = ctx.createBuilder()
///
/// let i32ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32ty, [])
/// let fval = mod.addFunction(fty, "const_int32")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let const_123456 = ctx.getConstInt32(123456)
/// let const_neg789 = ctx.getConstInt32(-789)
/// let const_mul = builder.createMul(const_123456, const_neg789)
///
/// inspect(const_123456, content="i32 123456")
/// inspect(const_neg789, content="i32 -789")
/// inspect(const_mul, content="i32 -97406784")
/// ```
pub fn Context::getConstInt32(self : Self, val : Int) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(
    self.getInt32Ty().getTypeRef(),
    val.to_uint64(),
    true,
  )
  ConstantInt(valueref)
}

///| Create a constant unsigned 32-bit integer value.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("const_uint32")
/// let builder = ctx.createBuilder()
///
/// let i32ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32ty, [])
/// let fval = mod.addFunction(fty, "const_uint32")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let const_4294967295 = ctx.getConstUInt32(4294967295U)
/// let const_1 = ctx.getConstUInt32(1U)
/// let const_add = builder.createAdd(const_4294967295, const_1)
///
/// inspect(const_4294967295, content="i32 -1")
/// inspect(const_1, content="i32 1")
/// inspect(const_add, content="i32 0")
/// ```
pub fn Context::getConstUInt32(self : Self, val : UInt) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(
    self.getInt32Ty().getTypeRef(),
    val.to_uint64(),
    false,
  )
  ConstantInt(valueref)
}

///| Create a constant signed 64-bit integer value.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("const_int64")
/// let builder = ctx.createBuilder()
///
/// let i64ty = ctx.getInt64Ty()
/// let fty = ctx.getFunctionType(i64ty, [])
/// let fval = mod.addFunction(fty, "const_int64")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let const_big = ctx.getConstInt64(9223372036854775807L)
/// let const_1 = ctx.getConstInt64(1L)
/// let const_add = builder.createAdd(const_big, const_1)
///
/// inspect(const_big, content="i64 9223372036854775807")
/// inspect(const_1, content="i64 1")
/// inspect(const_add, content="i64 -9223372036854775808")
/// ```
pub fn Context::getConstInt64(self : Self, val : Int64) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(
    self.getInt64Ty().getTypeRef(),
    val.reinterpret_as_uint64(),
    true,
  )
  ConstantInt(valueref)
}

///| Create a constant unsigned 64-bit integer value.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("const_uint64")
/// let builder = ctx.createBuilder()
///
/// let i64ty = ctx.getInt64Ty()
/// let fty = ctx.getFunctionType(i64ty, [])
/// let fval = mod.addFunction(fty, "const_uint64")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let const_max = ctx.getConstUInt64(18446744073709551615UL)
/// let const_1 = ctx.getConstUInt64(1UL)
/// let const_add = builder.createAdd(const_max, const_1)
///
/// inspect(const_max, content="i64 -1")
/// inspect(const_1, content="i64 1")
/// inspect(const_add, content="i64 0")
/// ```
pub fn Context::getConstUInt64(self : Self, val : UInt64) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(
    self.getInt64Ty().getTypeRef(),
    val,
    false,
  )
  ConstantInt(valueref)
}

///| Create a constant 32-bit floating-point value.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("const_float")
/// let builder = ctx.createBuilder()
///
/// let f32ty = ctx.getFloatTy()
/// let fty = ctx.getFunctionType(f32ty, [])
/// let fval = mod.addFunction(fty, "const_float")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let const_pi = ctx.getConstFloat(3.14159)
/// let const_2 = ctx.getConstFloat(2.0)
/// let const_mul = builder.createFMul(const_pi, const_2)
///
/// inspect(const_pi, content="float 0x400921FA00000000")
/// inspect(const_2, content="float 2.000000e+00")
/// inspect(const_mul, content="float 0x401921FA00000000")
/// ```
pub fn Context::getConstFloat(self : Self, val : Float) -> ConstantFP {
  let valueref = @unsafe.llvm_const_real(
    self.getFloatTy().getTypeRef(),
    val.to_double(),
  )
  ConstantFP(valueref)
}

///| Create a constant 64-bit floating-point value.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("const_double")
/// let builder = ctx.createBuilder()
///
/// let f64ty = ctx.getDoubleTy()
/// let fty = ctx.getFunctionType(f64ty, [])
/// let fval = mod.addFunction(fty, "const_double")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let const_e = ctx.getConstDouble(2.718281828)
/// let const_10 = ctx.getConstDouble(10.0)
/// let const_div = builder.createFDiv(const_10, const_e)
///
/// inspect(const_e, content="double 0x4005BF0A8B04919B")
/// inspect(const_10, content="double 1.000000e+01")
/// inspect(const_div, content="double 0x400D6E2BC3CD8399")
/// ```
pub fn Context::getConstDouble(self : Self, val : Double) -> ConstantFP {
  let valueref = @unsafe.llvm_const_real(self.getDoubleTy().getTypeRef(), val)
  ConstantFP(valueref)
}

///| Create a constant array from an array of constant elements.
///
/// **Note:** 
/// All elements must be of the same type and must be constant values.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("const_array")
/// let builder = ctx.createBuilder()
///
/// let i32ty = ctx.getInt32Ty()
/// let arr_ty = ctx.getArrayType(i32ty, 3)
/// let fty = ctx.getFunctionType(arr_ty, [])
/// let fval = mod.addFunction(fty, "const_array")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let const_1 = ctx.getConstInt32(1)
/// let const_2 = ctx.getConstInt32(2) 
/// let const_3 = ctx.getConstInt32(3)
/// let const_array = ctx.getConstArray(i32ty, [const_1, const_2, const_3])
///
/// inspect(const_array, content="[3 x i32] [i32 1, i32 2, i32 3]")
/// ```
pub fn Context::getConstArray(
  self : Self,
  elementType : &Type,
  elements : Array[&Constant],
) -> ConstantArray {
  ignore(self)
  let element_refs = elements.map(v => v.getValueRef())
  let valueref = @unsafe.llvm_const_array2(
    elementType.getTypeRef(),
    element_refs,
  )
  ConstantArray(valueref)
}

// REVIEW: Check if this is correct.

///| Create a constant vector from an array of scalar constant values.
///
/// **Note:** 
/// All scalar values must be of the same type and must be constant values.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("const_vector")
/// let builder = ctx.createBuilder()
///
/// let i32ty = ctx.getInt32Ty()
/// let vec_ty = ctx.getFixedVectorType(i32ty, 4)
/// let fty = ctx.getFunctionType(vec_ty, [])
/// let fval = mod.addFunction(fty, "const_vector")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let const_1 = ctx.getConstInt32(1)
/// let const_2 = ctx.getConstInt32(2)
/// let const_3 = ctx.getConstInt32(3)
/// let const_4 = ctx.getConstInt32(4)
/// let const_vector = ctx.getConstVector([const_1, const_2, const_3, const_4])
///
/// inspect(const_vector, content="<4 x i32> <i32 1, i32 2, i32 3, i32 4>")
/// ```
pub fn Context::getConstVector(
  self : Self,
  scalar_constant_vals : Array[&Constant],
) -> ConstantVector {
  ignore(self)
  let scalar_refs = scalar_constant_vals.map(v => v.getValueRef())
  let valueref = @unsafe.llvm_const_vector(scalar_refs)
  ConstantVector(valueref)
}

///| Create a constant struct from an array of constant element values.
///
/// **Note:** 
/// Element types and count must match the struct type being created.
/// When `isPacked` is true, struct fields are packed without padding.
///
/// - See LLVM: `ConstantStruct::get`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("const_struct")
/// let builder = ctx.createBuilder()
///
/// let i32ty = ctx.getInt32Ty()
/// let f32ty = ctx.getFloatTy()
/// let struct_ty = ctx.getStructType([i32ty, f32ty])
/// let fty = ctx.getFunctionType(struct_ty, [])
/// let fval = mod.addFunction(fty, "const_struct")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let const_42 = ctx.getConstInt32(42)
/// let const_pi = ctx.getConstFloat(3.14)
/// let const_struct = ctx.getConstStruct([const_42, const_pi])
///
/// inspect(const_struct, content="{ i32, float } { i32 42, float 0x40091EB860000000 }")
/// ```
pub fn Context::getConstStruct(
  self : Self,
  elements : Array[&Constant],
  isPacked~ : Bool = false,
) -> ConstantStruct {
  ignore(self)
  let element_refs = elements.map(v => v.getValueRef())
  let valueref = @unsafe.llvm_const_struct_in_context(
    self.inner(),
    element_refs,
    isPacked,
  )
  ConstantStruct(valueref)
}

///| Create an undefined value of the specified type.
///
/// **Note:**
/// Undefined values represent values that are not defined. They can be used
/// when the value is not important, and LLVM may optimize them in various ways.
///
/// - See LLVM: `UndefValue::get`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("undef_test")
/// let builder = ctx.createBuilder()
///
/// let i32ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32ty, [])
/// let fval = mod.addFunction(fty, "undef_test")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let undef_val = ctx.getUndef(i32ty)
/// let const_10 = ctx.getConstInt32(10)
/// let result = builder.createAdd(undef_val, const_10)
///
/// inspect(undef_val, content="i32 undef")
/// inspect(result, content="i32 undef")
/// ```
pub fn Context::getUndef(self : Self, ty : &Type) -> UndefValue {
  ignore(self)
  let valueref = @unsafe.llvm_get_undef(ty.getTypeRef())
  UndefValue(valueref)
}

///| Create a poison value of the specified type.
///
/// **Note:**
/// Poison values represent undefined behavior. Any operation on a poison value
/// produces poison, and using poison in a control-dependent manner causes
/// undefined behavior. They are more restrictive than undef values.
///
/// - See LLVM: `PoisonValue::get`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("poison_test")
/// let builder = ctx.createBuilder()
///
/// let i32ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32ty, [])
/// let fval = mod.addFunction(fty, "poison_test")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let poison_val = ctx.getPoision(i32ty)
/// let const_5 = ctx.getConstInt32(5)
/// let result = builder.createMul(poison_val, const_5)
///
/// inspect(poison_val, content="i32 poison")
/// inspect(result, content="i32 poison")
/// ```
pub fn Context::getPoision(self : Self, ty : &Type) -> PoisonValue {
  ignore(self)
  let valueref = @unsafe.llvm_get_poison(ty.getTypeRef())
  PoisonValue(valueref)
}

///| Create a constant null pointer of the specified pointer type.
///
/// **Note:**
/// The type must be a pointer type. The null pointer represents an invalid
/// memory address and is typically used to indicate the absence of a valid pointer.
///
/// - See LLVM: `ConstantPointerNull::get`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("null_ptr_test")
/// let builder = ctx.createBuilder()
///
/// let ptr_ty = ctx.getPtrTy()
/// let fty = ctx.getFunctionType(ptr_ty, [])
/// let fval = mod.addFunction(fty, "null_ptr_test")
/// let entry = fval.addBasicBlock(name="entry")
/// builder.setInsertPoint(entry)
///
/// let null_ptr = ctx.getConstPointerNull(ptr_ty)
/// inspect(null_ptr, content="ptr null")
/// ```
pub fn Context::getConstPointerNull(
  self : Self,
  ty : &Type,
) -> ConstantPointerNull {
  ignore(self)
  let valueref = @unsafe.llvm_const_pointer_null(ty.getTypeRef())
  ConstantPointerNull(valueref)
}
