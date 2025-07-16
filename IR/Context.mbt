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
  Module(@unsafe.llvm_module_create_with_name_in_context(name, self.inner()))
}

///|
pub fn Context::createBuilder(self : Self) -> IRBuilder {
  IRBuilder::{
    builder_ref: @unsafe.llvm_create_builder_in_context(self.inner()),
    positioned: NotSet,
  }
}

//pub fn Context::createBuilder(self: Self) -> IRBuilder {
//  IRBuilder(@unsafe.llvm_create_builder_in_context(self.inner()))
//}

//pub fn Context::createModule(self: Self, name: String) -> Module {
//  Module(@unsafe.llvm_module_create_with_name(name))
//}

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
pub fn Context::getInt1Ty(self : Context) -> IntType {
  let typeref = @unsafe.llvm_int1_type_in_context(self.inner())
  IntType(typeref)
}

///| Get the integer type with 8 bits from context.
pub fn Context::getInt8Ty(self : Context) -> IntType {
  let typeref = @unsafe.llvm_int8_type_in_context(self.inner())
  IntType(typeref)
}

///| Get the integer type with 16 bits from context.
pub fn Context::getInt16Ty(self : Context) -> IntType {
  let typeref = @unsafe.llvm_int16_type_in_context(self.inner())
  IntType(typeref)
}

///| Get the integer type with 32 bits from context.
pub fn Context::getInt32Ty(self : Context) -> IntType {
  let typeref = @unsafe.llvm_int32_type_in_context(self.inner())
  IntType(typeref)
}

///| Get the integer type with 64 bits from context.
pub fn Context::getInt64Ty(self : Context) -> IntType {
  let typeref = @unsafe.llvm_int64_type_in_context(self.inner())
  IntType(typeref)
}

///|
pub fn Context::getInt128Ty(self : Context) -> IntType {
  let typeref = @unsafe.llvm_int128_type_in_context(self.inner())
  IntType(typeref)
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
  addressSpace~ : AddressSpace = AddressSpace::default()
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
  isVarArg~ : Bool = false
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
  name~ : String = ""
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
  numElements : Int
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
  elementQuantity : Int
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
  elementQuantity : UInt
) -> ScalableVectorType {
  ignore(self)
  let typeref = @unsafe.llvm_scalable_vector_type(
    elementType.getTypeRef(),
    elementQuantity,
  )
  ScalableVectorType(typeref)
}

///|
pub fn Context::getConstTrue(self : Self) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(self.getInt1Ty().getTypeRef(), 1, true)
  ConstantInt(valueref)
}

///|
pub fn Context::getConstFalse(self : Self) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(self.getInt1Ty().getTypeRef(), 0, true)
  ConstantInt(valueref)
}

///|
pub fn Context::getConstInt8(self : Self, val : Int) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(
    self.getInt8Ty().getTypeRef(),
    val.to_uint64(),
    true,
  )
  ConstantInt(valueref)
}

///|
pub fn Context::getConstUInt8(self : Self, val : Int) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(
    self.getInt8Ty().getTypeRef(),
    val.to_uint64(),
    false,
  )
  ConstantInt(valueref)
}

///|
pub fn Context::getConstInt16(self : Self, val : Int) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(
    self.getInt16Ty().getTypeRef(),
    val.to_uint64(),
    true,
  )
  ConstantInt(valueref)
}

///|
pub fn Context::getConstUInt16(self : Self, val : UInt16) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(
    self.getInt16Ty().getTypeRef(),
    val.to_uint64(),
    false,
  )
  ConstantInt(valueref)
}

///|
pub fn Context::getConstInt32(self : Self, val : Int) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(
    self.getInt32Ty().getTypeRef(),
    val.to_uint64(),
    true,
  )
  ConstantInt(valueref)
}

///|
pub fn Context::getConstUInt32(self : Self, val : UInt) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(
    self.getInt32Ty().getTypeRef(),
    val.to_uint64(),
    false,
  )
  ConstantInt(valueref)
}

///|
pub fn Context::getConstInt64(self : Self, val : Int64) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(
    self.getInt64Ty().getTypeRef(),
    val.reinterpret_as_uint64(),
    true,
  )
  ConstantInt(valueref)
}

///|
pub fn Context::getConstUInt64(self : Self, val : UInt64) -> ConstantInt {
  let valueref = @unsafe.llvm_const_int(
    self.getInt64Ty().getTypeRef(),
    val,
    false,
  )
  ConstantInt(valueref)
}

///|
pub fn Context::getConstFloat(self : Self, val : Float) -> ConstantFP {
  let valueref = @unsafe.llvm_const_real(
    self.getFloatTy().getTypeRef(),
    val.to_double(),
  )
  ConstantFP(valueref)
}

///|
pub fn Context::getConstDouble(self : Self, val : Double) -> ConstantFP {
  let valueref = @unsafe.llvm_const_real(self.getDoubleTy().getTypeRef(), val)
  ConstantFP(valueref)
}

///|
pub fn Context::getConstArray(
  self : Self,
  elementType : &Type,
  elements : Array[&Constant]
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

///|
pub fn Context::getConstVector(
  self : Self,
  scalar_constant_vals : Array[&Constant]
) -> ConstantVector {
  ignore(self)
  let scalar_refs = scalar_constant_vals.map(v => v.getValueRef())
  let valueref = @unsafe.llvm_const_vector(scalar_refs)
  ConstantVector(valueref)
}

///|
///
/// See LLVM: `ConstantStruct::get`.
pub fn Context::getConstStruct(
  self : Self,
  elements : Array[&Constant],
  isPacked~ : Bool = false
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

///|
///
/// See LLVM: `UndefValue::get`.
pub fn Context::getUndef(self : Self, ty : &Type) -> UndefValue {
  ignore(self)
  let valueref = @unsafe.llvm_get_undef(ty.getTypeRef())
  UndefValue(valueref)
}

///|
///
/// See LLVM: `PoisonValue::get`.
pub fn Context::getPoision(self : Self, ty : &Type) -> PoisonValue {
  ignore(self)
  let valueref = @unsafe.llvm_get_poison(ty.getTypeRef())
  PoisonValue(valueref)
}

///|
///
/// See LLVM: `ConstantPointerNull::get`.
pub fn Context::getConstPointerNull(
  self : Self,
  ty : &Type
) -> ConstantPointerNull {
  ignore(self)
  let valueref = @unsafe.llvm_const_pointer_null(ty.getTypeRef())
  ConstantPointerNull(valueref)
}
