///|
pub enum TypeEnum {
  HalfType(HalfType)
  BFloatType(BFloatType)
  FloatType(FloatType)
  DoubleType(DoubleType)
  FP128Type(FP128Type)
  IntType(IntType)
  VoidType(VoidType)
  LabelType(LabelType)
  MetadataType(MetadataType)
  TokenType(TokenType)
  FunctionType(FunctionType)
  StructType(StructType)
  ArrayType(ArrayType)
  VectorType(VectorType)
  ScalableVectorType(ScalableVectorType)
  PointerType(PointerType)
} derive(Eq, Show)

///|
pub fn TypeEnum::asTypeClass(self : TypeEnum) -> &Type {
  match self {
    HalfType(t) => (t : &Type)
    BFloatType(t) => t
    FloatType(t) => t
    DoubleType(t) => t
    FP128Type(t) => t
    IntType(t) => t
    VoidType(t) => t
    LabelType(t) => t
    MetadataType(t) => t
    TokenType(t) => t
    FunctionType(t) => t
    StructType(t) => t
    ArrayType(t) => t
    VectorType(t) => t
    ScalableVectorType(t) => t
    PointerType(t) => t
  }
}

///|
pub trait Type: Show {
  getTypeRef(Self) -> @unsafe.LLVMTypeRef
  asTypeEnum(Self) -> TypeEnum
  getContext(Self) -> Context = _
  //print(Self, logger: &Logger, isForDebug~ = false, noDetails~ = false)
  //dump(Self)

  /// Return true if this is a 16-bit float type.
  is16bitFPTy(Self) -> Bool = _

  /// Return true if this is a well-behaved IEEE-like type, which has a IEEE
  /// compatible layout, and does not have non-IEEE values, such as x86_fp80's
  /// unnormal values.
  isIEEELikeFPTy(Self) -> Bool = _

  /// Return true if this is one of the floating-point types
  isFloatingPointTy(Self) -> Bool = _

  /// Return true if this is a target extension type with a scalable layout.
  isScalableTargetExtTy(Self) -> Bool = _

  /// Return true if this is a type whose size is a known multiple of vscale.
  // REVIEW: cpp has another `isScalableTy` function
  isScalableTy(Self) -> Bool = _

  /// Return true if this type is or contains a target extension type that
  /// disallows being used as a global.
  // REVIEW: cpp has another `containsNonGlobalTargetExtType` function
  //bool containsNonGlobalTargetExtType() const;

  /// Return true if this type is or contains a target extension type that
  /// disallows being used as a local.
  // REVIEW: cpp has another `containsNonLocalTargetExtType` function
  //bool containsNonLocalTargetExtType() const;

  /// Return true if this is a FP type or a vector of FP.
  isFPOrFPVectorTy(Self) -> Bool = _

  /// Return true if this is an integer type or a vector of integer types.
  // REVIEW: cpp has another `isIntOrIntVectorTy` function
  isIntOrIntVectorTy(Self) -> Bool = _

  /// Return true if this is an integer type or a pointer type.
  isIntOrPtrTy(Self) -> Bool = _

  /// Return true if this is a pointer type or a vector of pointer types.
  isPtrOrPtrVectorTy(Self) -> Bool = _

  /// Return true if this type is empty, that is, it has no elements or all of
  /// its elements are empty.
  isEmptyTy(Self) -> Bool = _

  /// Return true if the type is "first class", meaning it is a valid type for a
  /// Value.
  isFirstClassType(Self) -> Bool = _

  /// Return true if the type is a valid type for a register in codegen. This
  /// includes all first-class types except struct and array types.
  isSingleValueType(Self) -> Bool = _

  /// Return true if the type is an aggregate type. This means it is valid as
  /// the first operand of an insertvalue or extractvalue instruction. This
  /// includes struct and array types, but does not include vector types.
  isAggregateType(Self) -> Bool = _

  /// Return true if it makes sense to take the size of this type. To get the
  /// actual size for a particular target, it is reasonable to use the
  /// DataLayout subsystem to do this.
  isSized(Self) -> Bool = _

  /// Return true if this type is a valid type for a GEP instruction.
  isValidGEPType(Self) -> Bool = _

  /// If this is a vector type, return the getPrimitiveSizeInBits value for the
  /// element type. Otherwise return the getPrimitiveSizeInBits value for this
  /// type.
  getScalarType(Self) -> &Type = _
  tryAsFPType(Self) -> &FPType? = _
  tryAsFPTypeEnum(Self) -> FPTypeEnum? = _
  tryAsPrimitiveType(Self) -> &PrimitiveType? = _
  tryAsPrimitiveTypeEnum(Self) -> PrimitiveTypeEnum? = _
  tryAsAggregateType(Self) -> &AggregateType? = _
  tryAsAggregateTypeEnum(Self) -> AggregateTypeEnum? = _
  tryAsAbstractType(Self) -> &AbstractType? = _
  tryAsAbstractTypeEnum(Self) -> AbstractTypeEnum? = _
}

///|
pub suberror InValidTypeError String derive(Show)

///|
fn initAbstractType_err(
  typeref : @unsafe.LLVMTypeRef
) -> &Type raise InValidTypeError {
  let kind = @unsafe.llvm_get_type_kind(typeref)
  match kind {
    LLVMVoidTypeKind => {
      VoidType::VoidType(typeref) as &Type
    }
    LLVMHalfTypeKind => HalfType::HalfType(typeref)
    LLVMBFloatTypeKind => BFloatType::BFloatType(typeref)
    LLVMFloatTypeKind => FloatType::FloatType(typeref)
    LLVMDoubleTypeKind => DoubleType::DoubleType(typeref)
    LLVMFP128TypeKind => FP128Type::FP128Type(typeref)
    LLVMPointerTypeKind => PointerType::PointerType(typeref)
    LLVMStructTypeKind => StructType::StructType(typeref)
    LLVMArrayTypeKind => ArrayType::ArrayType(typeref)
    LLVMVectorTypeKind => VectorType::VectorType(typeref)
    LLVMScalableVectorTypeKind =>
      ScalableVectorType::ScalableVectorType(typeref)
    LLVMIntegerTypeKind => IntType::IntType(typeref)
    LLVMLabelTypeKind => LabelType::LabelType(typeref)
    LLVMMetadataTypeKind => MetadataType::MetadataType(typeref)
    LLVMTokenTypeKind => TokenType::TokenType(typeref)
    LLVMFunctionTypeKind => FunctionType::FunctionType(typeref)
    LLVMPPC_FP128TypeKind =>
      raise InValidTypeError("PPC FP128 type is not supported")
    LLVMX86_FP80TypeKind =>
      raise InValidTypeError("X86 FP80 type is not supported")
    _ => raise InValidTypeError("Invalid type kind: \{kind}")
  }
}

///|
fn initAbstractType(typeref : @unsafe.LLVMTypeRef) -> &Type {
  match (try? initAbstractType_err(typeref)) {
    Ok(ty) => ty
    Err(_) => {
      println("ICE: Invalid Type kind")
      panic()
    }
  }
}

///|
impl Eq for &Type with op_equal(self, other) {
  self.asTypeEnum() == other.asTypeEnum()
}

///|
impl Type with getContext(self) -> Context {
  Context(@unsafe.llvm_get_type_context(self.getTypeRef()))
}

///|
impl Type with is16bitFPTy(self) -> Bool {
  self.asTypeEnum() is (HalfType(_) | BFloatType(_))
}

///|
impl Type with isIEEELikeFPTy(self) -> Bool {
  self.tryAsFPTypeEnum() is Some(_)
}

///|
impl Type with isFloatingPointTy(self) -> Bool {
  self.tryAsFPTypeEnum() is Some(_)
}

///|
#internal(unsafe, "This functions is not fully implemented yet")
impl Type with isScalableTargetExtTy(_) {
  false
}

///|
#internal(unsafe, "This functions is not fully implemented yet")
impl Type with isScalableTy(_) -> Bool {
  false
}

///|
impl Type with isIntOrIntVectorTy(self) -> Bool {
  self.getScalarType().asTypeEnum() is IntType(_)
}

///|
impl Type with isFPOrFPVectorTy(self) -> Bool {
  self.getScalarType().isFloatingPointTy()
}

//impl Type with isRISCVectorTupleTy(self) -> Bool

///|
impl Type with isIntOrPtrTy(self) -> Bool {
  self.asTypeEnum() is (IntType(_) | PointerType(_))
}

///|
impl Type with isPtrOrPtrVectorTy(self) -> Bool {
  self.getScalarType().asTypeEnum() is PointerType(_)
}

///|
impl Type with isEmptyTy(self) -> Bool {
  match self.asTypeEnum() {
    ArrayType(arr) if arr.getElementCount() == 0 => true
    ArrayType(arr) => arr.getElementType().isEmptyTy()
    StructType(sty) if sty.isOpaque() => true
    StructType(sty) => sty.elements().iter().all(ty => ty.isEmptyTy())
    _ => false
  }
}

///|
///
/// Only FunctionType, VoidType, Opaque Struct is not first class type.
impl Type with isFirstClassType(self) {
  match self.asTypeEnum() {
    StructType(sty) => not(sty.isOpaque())
    FunctionType(_) | VoidType(_) => false
    _ => true
  }
}

// REVIEW: Maybe we could use math-cases

///|
impl Type with isSingleValueType(self) -> Bool {
  match self.asTypeEnum() {
    HalfType(_) | BFloatType(_) | FloatType(_) | DoubleType(_) | FP128Type(_) =>
      true
    IntType(_) => true
    PointerType(_) => true
    VectorType(_) => true
    _ => false
  }
}

///|
impl Type with isAggregateType(self) -> Bool {
  match self.asTypeEnum() {
    StructType(_) | ArrayType(_) => true
    VectorType(_) | ScalableVectorType(_) => true
    _ => false
  }
}

///|
impl Type with isSized(self) -> Bool {
  @unsafe.llvm_type_is_sized(self.getTypeRef())
}

///|
impl Type with isValidGEPType(self) -> Bool {
  self.tryAsAbstractTypeEnum() is None
}

///|
impl Type with getScalarType(self) {
  if self.asTypeEnum() is VectorType(vec) {
    vec.getElementType()
  } else {
    self
  }
}

///|
impl Type with tryAsFPType(self) -> &FPType? {
  match self.asTypeEnum() {
    HalfType(h) => Some(h)
    BFloatType(b) => Some(b)
    FloatType(f) => Some(f)
    DoubleType(d) => Some(d)
    FP128Type(fp) => Some(fp)
    _ => None
  }
}

///|
impl Type with tryAsFPTypeEnum(self) -> FPTypeEnum? {
  match self.asTypeEnum() {
    HalfType(half) => Some(HalfType(half))
    BFloatType(bfloat) => Some(BFloatType(bfloat))
    FloatType(float) => Some(FloatType(float))
    DoubleType(double) => Some(DoubleType(double))
    FP128Type(fp128) => Some(FP128Type(fp128))
    _ => None
  }
}

///|
impl Type with tryAsPrimitiveType(self) -> &PrimitiveType? {
  match self.asTypeEnum() {
    HalfType(half) => Some(half)
    BFloatType(bfloat) => Some(bfloat)
    FloatType(float) => Some(float)
    DoubleType(double) => Some(double)
    FP128Type(fp128) => Some(fp128)
    IntType(int1) => Some(int1)
    _ => None
  }
}

///|
impl Type with tryAsPrimitiveTypeEnum(self) -> PrimitiveTypeEnum? {
  match self.asTypeEnum() {
    HalfType(half) => Some(HalfType(half))
    BFloatType(bfloat) => Some(BFloatType(bfloat))
    FloatType(float) => Some(FloatType(float))
    DoubleType(double) => Some(DoubleType(double))
    FP128Type(fp128) => Some(FP128Type(fp128))
    IntType(int1) => Some(IntType(int1))
    _ => None
  }
}

///|
impl Type with tryAsAggregateType(self) -> &AggregateType? {
  match self.asTypeEnum() {
    StructType(sty) => Some(sty)
    ArrayType(arr) => Some(arr)
    VectorType(vec) => Some(vec)
    ScalableVectorType(vec) => Some(vec)
    _ => None
  }
}

///|
impl Type with tryAsAggregateTypeEnum(self) -> AggregateTypeEnum? {
  match self.asTypeEnum() {
    StructType(sty) => Some(StructType(sty))
    ArrayType(arr) => Some(ArrayType(arr))
    VectorType(vec) => Some(VectorType(vec))
    ScalableVectorType(vec) => Some(ScalableVectorType(vec))
    _ => None
  }
}

///|
impl Type with tryAsAbstractType(self) -> &AbstractType? {
  match self.asTypeEnum() {
    VoidType(v) => Some(v)
    LabelType(label) => Some(label)
    MetadataType(metadata) => Some(metadata)
    TokenType(token) => Some(token)
    FunctionType(func) => Some(func)
    _ => None
  }
}

///|
impl Type with tryAsAbstractTypeEnum(self) -> AbstractTypeEnum? {
  match self.asTypeEnum() {
    VoidType(v) => Some(VoidType(v))
    LabelType(label) => Some(LabelType(label))
    MetadataType(metadata) => Some(MetadataType(metadata))
    TokenType(token) => Some(TokenType(token))
    FunctionType(func) => Some(FunctionType(func))
    _ => None
  }
}

// pub Type with print(self, logger: &Logger, isForDebug~ = false, noDetails~ = false)
// pub Type with dump(self)

// ====================================================================
// FPType && FPTypeEnum
// ====================================================================

///|
pub trait FPType: Type {
  asFPTypeEnum(Self) -> FPTypeEnum

  /// Return the width of the mantissa of this type. 
  getFPMantissaWidth(Self) -> UInt = _
  getBitWidth(Self) -> UInt = _
}

///|
pub enum FPTypeEnum {
  HalfType(HalfType)
  BFloatType(BFloatType)
  FloatType(FloatType)
  DoubleType(DoubleType)
  FP128Type(FP128Type)
} derive(Eq, Show)

///|
pub fn FPTypeEnum::asTypeClass(self : FPTypeEnum) -> &Type {
  match self {
    HalfType(t) => (t : &Type)
    BFloatType(t) => t
    FloatType(t) => t
    DoubleType(t) => t
    FP128Type(t) => t
  }
}

///|
pub fn FPTypeEnum::getBitWidth(self : FPTypeEnum) -> UInt {
  match self {
    HalfType(_) => 16
    BFloatType(_) => 16
    FloatType(_) => 32
    DoubleType(_) => 64
    FP128Type(_) => 128
  }
}

///|
pub fn FPTypeEnum::getFPMantissaWidth(self : FPTypeEnum) -> UInt {
  match self {
    HalfType(_) => 11
    BFloatType(_) => 8
    FloatType(_) => 24
    DoubleType(_) => 53
    FP128Type(_) => 113
  }
}

///|
impl FPType with getFPMantissaWidth(self) {
  self.asFPTypeEnum().getFPMantissaWidth()
}

///|
impl FPType with getBitWidth(self) -> UInt {
  self.asFPTypeEnum().getBitWidth()
}

// ====================================================================
// Primitive Types, PrimitiveType && PrimitiveTypeEnum
// ====================================================================

///|
pub trait PrimitiveType: Type {
  asPrimitiveTypeEnum(Self) -> PrimitiveTypeEnum
  getBitWidth(Self) -> UInt = _
}

///|
impl PrimitiveType with getBitWidth(self) -> UInt {
  self.asPrimitiveTypeEnum().getBitWidth()
}

///|
pub enum PrimitiveTypeEnum {
  HalfType(HalfType)
  BFloatType(BFloatType)
  FloatType(FloatType)
  DoubleType(DoubleType)
  FP128Type(FP128Type)
  IntType(IntType)
} derive(Eq, Show)

///|
pub fn PrimitiveTypeEnum::getBitWidth(self : PrimitiveTypeEnum) -> UInt {
  match self {
    HalfType(_) => 16
    BFloatType(_) => 16
    FloatType(_) => 32
    DoubleType(_) => 64
    FP128Type(_) => 128
    IntType(i) => i.getBitWidth()
  }
}

// ====================================================================
// Aggregate Types, AggregateType && AggregateTypeEnum
// ====================================================================

///|
pub trait AggregateType: Type {
  asAggregateTypeEnum(Self) -> AggregateTypeEnum
  getElementType(Self, Int) -> &Type? = _
}

///|
impl AggregateType with getElementType(self, idx : Int) -> &Type? {
  match self.asAggregateTypeEnum() {
    StructType(sty) => sty.getElementType(idx)
    ArrayType(arr) => arr.getElementType() |> Some
    VectorType(vec) => vec.getElementType() |> Some
    ScalableVectorType(vec) => vec.getElementType() |> Some
  }
}

///|
pub enum AggregateTypeEnum {
  StructType(StructType)
  ArrayType(ArrayType)
  VectorType(VectorType)
  ScalableVectorType(ScalableVectorType)
} derive(Eq, Show)

///|
pub fn AggregateTypeEnum::toTypeEnum(self : AggregateTypeEnum) -> TypeEnum {
  match self {
    StructType(sty) => StructType(sty)
    ArrayType(arr) => ArrayType(arr)
    VectorType(vec) => VectorType(vec)
    ScalableVectorType(vec) => ScalableVectorType(vec)
  }
}

///|
pub fn AggregateTypeEnum::asTypeClass(self : Self) -> &Type {
  match self {
    StructType(sty) => (sty : &Type)
    ArrayType(arr) => arr
    VectorType(vec) => vec
    ScalableVectorType(vec) => vec
  }
}

// ====================================================================
// Abstract Types, AbstractType && AbstractTypeEnum
// ====================================================================

///|
pub trait AbstractType: Type {
  asAbstractTypeEnum(Self) -> AbstractTypeEnum
}

///|
pub enum AbstractTypeEnum {
  VoidType(VoidType)
  LabelType(LabelType)
  MetadataType(MetadataType)
  TokenType(TokenType)
  FunctionType(FunctionType)
} derive(Show)

// ====================================================================
// HalfType
// ====================================================================

///|
pub type HalfType @unsafe.LLVMTypeRef derive(Eq)

///|
pub impl Show for HalfType with output(self, logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for HalfType with asTypeEnum(self) -> TypeEnum {
  TypeEnum::HalfType(self)
}

///|
pub impl Type for HalfType with getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.inner()
}

///|
pub impl FPType for HalfType with asFPTypeEnum(self) -> FPTypeEnum {
  FPTypeEnum::HalfType(self)
}

///|
pub impl PrimitiveType for HalfType with asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  PrimitiveTypeEnum::HalfType(self)
}

// ====================================================================
// BFloatType
// ====================================================================

///| BFloatType
pub type BFloatType @unsafe.LLVMTypeRef derive(Eq)

///|
pub impl Show for BFloatType with output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for BFloatType with asTypeEnum(self) -> TypeEnum {
  BFloatType(self)
}

///|
pub impl Type for BFloatType with getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.inner()
}

///|
pub impl FPType for BFloatType with asFPTypeEnum(self) -> FPTypeEnum {
  BFloatType(self)
}

///|
pub impl PrimitiveType for BFloatType with asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  BFloatType(self)
}

// ====================================================================
// FloatType
// ====================================================================

///| FloatType
pub type FloatType @unsafe.LLVMTypeRef derive(Eq)

///|
pub impl Show for FloatType with output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for FloatType with asTypeEnum(self) -> TypeEnum {
  TypeEnum::FloatType(self)
}

///|
pub impl Type for FloatType with getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.inner()
}

///|
pub impl FPType for FloatType with asFPTypeEnum(self) -> FPTypeEnum {
  FloatType(self)
}

///|
pub impl PrimitiveType for FloatType with asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  FloatType(self)
}

// ====================================================================
// DoubleType
// ====================================================================

///| DoubleType
pub type DoubleType @unsafe.LLVMTypeRef derive(Eq)

///| Create a DoubleType
//fn DoubleType::new(typeref : @unsafe.LLVMTypeRef) -> DoubleType {
//  DoubleType::{ typeref, }
//}

///|
pub impl Show for DoubleType with output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for DoubleType with asTypeEnum(self) -> TypeEnum {
  DoubleType(self)
}

///|
pub impl Type for DoubleType with getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.inner()
}

///|
pub impl FPType for DoubleType with asFPTypeEnum(self) -> FPTypeEnum {
  DoubleType(self)
}

///|
pub impl PrimitiveType for DoubleType with asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  DoubleType(self)
}

// ====================================================================
// FP128Type
// ====================================================================

///| FP128Ty
pub type FP128Type @unsafe.LLVMTypeRef derive(Eq)
//pub struct FP128Type {
//  priv typeref : @unsafe.LLVMTypeRef
//} derive(Eq)

///| Create a FP128Ty.
//fn FP128Type::new(typeref : @unsafe.LLVMTypeRef) -> FP128Type {
//  FP128Type::{ typeref, }
//}

///|
pub impl Show for FP128Type with output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for FP128Type with asTypeEnum(self) -> TypeEnum {
  FP128Type(self)
}

///|
pub impl Type for FP128Type with getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.inner()
}

///|
pub impl FPType for FP128Type with asFPTypeEnum(self) -> FPTypeEnum {
  FP128Type(self)
}

///|
pub impl PrimitiveType for FP128Type with asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  FP128Type(self)
}

// ====================================================================
// IntType
// ====================================================================

///|
pub type IntType @unsafe.LLVMTypeRef derive(Eq)

///|
//fn IntType::new(typeref : @unsafe.LLVMTypeRef) -> IntType {
//  IntType::{ typeref, }
//}

///| Gets the bit width of an `IntType`.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::new();
/// let i32_type = context.getInt32Ty();
/// let i32_width = i32_type.getBitWidth();
/// inspect(i32_width, content="32")
/// ```
pub fn IntType::getBitWidth(self : IntType) -> UInt {
  @unsafe.llvm_get_int_type_width(self.getTypeRef())
}

///|
pub impl Show for IntType with output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for IntType with asTypeEnum(self) -> TypeEnum {
  TypeEnum::IntType(self)
}

///|
pub impl Type for IntType with getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.inner()
}

///|
pub impl PrimitiveType for IntType with asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  IntType(self)
}

// ====================================================================
// VoidType
// ====================================================================

///|
pub type VoidType @unsafe.LLVMTypeRef derive(Eq)

///|
pub impl Show for VoidType with output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for VoidType with getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.inner()
}

///|
pub impl Type for VoidType with asTypeEnum(self) -> TypeEnum {
  VoidType(self)
}

///|
pub impl AbstractType for VoidType with asAbstractTypeEnum(self) -> AbstractTypeEnum {
  VoidType(self)
}

// ====================================================================
// LabelType
// ====================================================================

///| LabelTy
pub type LabelType @unsafe.LLVMTypeRef derive(Eq)

///|
pub impl Show for LabelType with output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for LabelType with asTypeEnum(self) -> TypeEnum {
  TypeEnum::LabelType(self)
}

///|
pub impl Type for LabelType with getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.inner()
}

///|
pub impl AbstractType for LabelType with asAbstractTypeEnum(self) -> AbstractTypeEnum {
  LabelType(self)
}

// ====================================================================
// MetadataType
// ====================================================================

///|
pub type MetadataType @unsafe.LLVMTypeRef derive(Eq)

///|
pub impl Show for MetadataType with output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for MetadataType with asTypeEnum(self) -> TypeEnum {
  TypeEnum::MetadataType(self)
}

///|
pub impl Type for MetadataType with getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.inner()
}

///|
pub impl AbstractType for MetadataType with asAbstractTypeEnum(self) -> AbstractTypeEnum {
  MetadataType(self)
}

// ====================================================================
// TokenTy
// ====================================================================

///| TokenTy
pub type TokenType @unsafe.LLVMTypeRef derive(Eq)

///|
pub impl Show for TokenType with output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for TokenType with asTypeEnum(self) -> TypeEnum {
  TokenType(self)
}

///|
pub impl Type for TokenType with getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.inner()
}

///|
pub impl AbstractType for TokenType with asAbstractTypeEnum(self) -> AbstractTypeEnum {
  TokenType(self)
}

// ====================================================================
// FunctionType
// ====================================================================

///|
pub type FunctionType @unsafe.LLVMTypeRef derive(Eq)

///|
pub fn FunctionType::isVarArg(self : FunctionType) -> Bool {
  @unsafe.llvm_is_function_var_arg(self.getTypeRef())
}

///| Get the return type of the function.
pub fn FunctionType::getReturnType(self : FunctionType) -> &Type {
  let typeref = @unsafe.llvm_get_return_type(self.getTypeRef())
  initAbstractType(typeref)
}

///|
pub fn FunctionType::numOfParams(self : FunctionType) -> Int {
  @unsafe.llvm_count_param_types(self.getTypeRef()).reinterpret_as_int()
}

///| Get the params of the function.
///
/// - See LLVM: `FunctionType::params`.
pub fn FunctionType::params(self : FunctionType) -> Array[&Type] {
  let param_types = @unsafe.llvm_get_param_types(self.getTypeRef())
  param_types.map(typeref => initAbstractType(typeref))
}

///| Get the params of the function.
///
/// - See LLVM: `FunctionType::params`.
pub fn FunctionType::getParamTypes(self : FunctionType) -> Array[&Type] {
  let param_types = @unsafe.llvm_get_param_types(self.getTypeRef())
  param_types.map(typeref => initAbstractType(typeref))
}

///| Return the number of fixed parameters this function type requires.
/// This does not consider varargs.
///
/// - See LLVM: `FunctionType::getNumParams`.
pub fn FunctionType::getNumParams(self : FunctionType) -> Int {
  @unsafe.llvm_count_param_types(self.getTypeRef()).reinterpret_as_int()
}

///| Get the param type by given index.
pub fn FunctionType::getParamType(self : FunctionType, idx : Int) -> &Type? {
  let param_types = @unsafe.llvm_get_param_types(self.getTypeRef())
  guard idx >= 0 && idx < param_types.length() else { return None }
  let typeref = param_types[idx]
  match (try? initAbstractType_err(typeref)) {
    Ok(ty) => Some(ty)
    Err(_) => None
  }
}

///|
pub impl Show for FunctionType with output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for FunctionType with asTypeEnum(self) -> TypeEnum {
  TypeEnum::FunctionType(self)
}

///|
pub impl Type for FunctionType with getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.inner()
}

///|
pub impl AbstractType for FunctionType with asAbstractTypeEnum(self) -> AbstractTypeEnum {
  AbstractTypeEnum::FunctionType(self)
}

// ====================================================================
// StructType
// ====================================================================

///|
pub type StructType @unsafe.LLVMTypeRef derive(Eq)

///| Check struct is a literal type.
///
/// literal type means the struct only has body but has no name.
///
/// - See LLVM: `StructType::isLiteral`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let i32ty = ctx.getInt32Ty()
/// let f32ty = ctx.getFloatTy()
///
/// let foo = ctx.getStructType([i32ty, f32ty])
/// let bar = ctx.getStructType([i32ty, f32ty], name="bar")
///
/// assert_true(foo.isLiteral())
/// assert_false(bar.isLiteral())
/// ```
pub fn StructType::isLiteral(self : StructType) -> Bool {
  @unsafe.llvm_is_literal_struct(self.getTypeRef())
}

///| Check struct is a opaque type.
/// Return true if this is a type with an identity that has no body specified
/// yet. These prints as 'opaque' in .ll files.
///
/// - See LLVM: `StructType::isOpaque`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let i32ty = ctx.getInt32Ty()
/// let f32ty = ctx.getFloatTy()
///
/// let bar = ctx.getStructType([i32ty, f32ty], name="bar")
/// assert_false(bar.isOpaque())
/// ```
pub fn StructType::isOpaque(self : StructType) -> Bool {
  @unsafe.llvm_is_opaque_struct(self.getTypeRef())
}

///| Check if this is a packed struct type.
///
/// - See LLVM: `StructType::isPacked`.
///
/// Packed struct means the struct has no padding between its elements.
pub fn StructType::isPacked(self : StructType) -> Bool {
  @unsafe.llvm_is_packed_struct(self.getTypeRef())
}

///|
pub fn StructType::isSized(self : StructType) -> Bool {
  @unsafe.llvm_type_is_sized(self.getTypeRef())
}

///|
pub fn StructType::numOfElements(self : StructType) -> Int {
  @unsafe.llvm_count_struct_element_types(self.getTypeRef()).reinterpret_as_int()
}

///|
pub fn StructType::getElementType(self : StructType, idx : Int) -> &Type? {
  guard idx >= 0 && idx < self.numOfElements() else { return None }
  let typeref = @unsafe.llvm_struct_get_type_at_index(
    self.getTypeRef(),
    idx.reinterpret_as_uint(),
  )
  match (try? initAbstractType_err(typeref)) {
    Ok(ty) => Some(ty)
    Err(_) => None
  }
}

///| Get the elements of the struct.
///
/// - See LLVM: `StructType::elements`.
pub fn StructType::elements(self : StructType) -> Array[&Type] {
  let elements : Array[&Type] = Array::new()
  for i in 0..<self.numOfElements() {
    elements.push(
      self
      .getElementType(i)
      .unwrap_or_else(() => {
        println("Unknown Error happened during StructType::elements")
        panic()
      }),
    )
  }
  elements
}

///|
pub suberror SetBodyForNonOpaqueStruct String derive(Show)

///| Set the body of the struct.
///
/// Only Opaque struct can be set body.
///
/// - See LLVM: `StructType::setBody`.
pub fn StructType::setBody(
  self : StructType,
  elements : Array[&Type],
  isPacked~ : Bool = false
) -> Unit raise {
  // only opaque struct can be set body.
  guard self.isOpaque() else {
    raise SetBodyForNonOpaqueStruct("Cannot set body for non-opaque struct")
  }
  let field_types = elements.map(t => t.getTypeRef())
  @unsafe.llvm_struct_set_body(self.getTypeRef(), field_types, isPacked)
}

///|
pub impl Show for StructType with output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for StructType with asTypeEnum(self) -> TypeEnum {
  StructType(self)
}

///|
pub impl Type for StructType with getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.inner()
}

///|
pub impl AggregateType for StructType with asAggregateTypeEnum(self) -> AggregateTypeEnum {
  StructType(self)
}

// ====================================================================
// ArrayType
// ====================================================================

///|
pub type ArrayType @unsafe.LLVMTypeRef derive(Eq)

///|
pub fn ArrayType::getElementCount(self : ArrayType) -> Int {
  @unsafe.llvm_get_array_length(self.getTypeRef()).reinterpret_as_int()
}

///|
pub fn ArrayType::getElementType(self : ArrayType) -> &Type {
  let typeref = @unsafe.llvm_get_element_type(self.getTypeRef())
  initAbstractType(typeref)
}

///|
pub impl Show for ArrayType with output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for ArrayType with asTypeEnum(self) -> TypeEnum {
  ArrayType(self)
}

///|
pub impl Type for ArrayType with getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.inner()
}

///|
pub impl AggregateType for ArrayType with asAggregateTypeEnum(self) -> AggregateTypeEnum {
  ArrayType(self)
}

// ====================================================================
// VectorType
// ====================================================================

///|
pub type VectorType @unsafe.LLVMTypeRef derive(Eq)

///| Get the element type of the vector.
pub fn VectorType::getElementType(self : VectorType) -> &Type {
  let typeref = @unsafe.llvm_get_element_type(self.getTypeRef())
  initAbstractType(typeref)
}

///| Get the number of elements in the vector.
pub fn VectorType::getElementCount(self : VectorType) -> Int {
  @unsafe.llvm_get_vector_size(self.getTypeRef()).reinterpret_as_int()
}

///|
pub impl Show for VectorType with output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for VectorType with asTypeEnum(self) -> TypeEnum {
  TypeEnum::VectorType(self)
}

///|
pub impl Type for VectorType with getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.inner()
}

///|
pub impl AggregateType for VectorType with asAggregateTypeEnum(self) -> AggregateTypeEnum {
  VectorType(self)
}

// ====================================================================
// ScalableVectorType
// ====================================================================

///|
pub type ScalableVectorType @unsafe.LLVMTypeRef derive(Eq)

///| Get the element type of the vector.
pub fn ScalableVectorType::getElementType(self : ScalableVectorType) -> &Type {
  let typeref = @unsafe.llvm_get_element_type(self.getTypeRef())
  initAbstractType(typeref)
}

///| Get the number of elements in the vector.
pub fn ScalableVectorType::getElementCount(self : ScalableVectorType) -> Int {
  @unsafe.llvm_get_vector_size(self.getTypeRef()).reinterpret_as_int()
}

///|
pub impl Show for ScalableVectorType with output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for ScalableVectorType with asTypeEnum(self) -> TypeEnum {
  TypeEnum::ScalableVectorType(self)
}

///|
pub impl Type for ScalableVectorType with getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.inner()
}

///|
pub impl AggregateType for ScalableVectorType with asAggregateTypeEnum(self) -> AggregateTypeEnum {
  ScalableVectorType(self)
}

// ====================================================================
// PointerType
// ====================================================================

///| Memory address space of a pointer type.
pub type AddressSpace UInt derive(Hash, Show, Eq, Default)

///|
pub fn AddressSpace::new(v : UInt) -> AddressSpace {
  AddressSpace(v)
}

///|
pub type PointerType @unsafe.LLVMTypeRef derive(Eq)

///|
pub fn PointerType::getAddressSpace(self : PointerType) -> AddressSpace {
  let addr_space = @unsafe.llvm_get_pointer_address_space(self.getTypeRef())
  AddressSpace(addr_space)
}

///|
fn PointerType::isValidElementType(eleTy : &Type) -> Bool {
  match eleTy.asTypeEnum() {
    VoidType(_) | LabelType(_) | MetadataType(_) | TokenType(_) => false
    _ => true
  }
}

///|
pub fn PointerType::isLoadableOrStorableType(eleTy : &Type) -> Bool {
  match eleTy.asTypeEnum() {
    FunctionType(_) => false
    _ => PointerType::isValidElementType(eleTy)
  }
}

///|
pub impl Show for PointerType with output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for PointerType with asTypeEnum(self) -> TypeEnum {
  TypeEnum::PointerType(self)
}

///|
pub impl Type for PointerType with getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.inner()
}
