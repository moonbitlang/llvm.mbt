///|
/// Closed classification of the LLVM types supported by the safe API.
///
/// Each case carries the corresponding concrete wrapper. Use
/// `asTypeClass` when an operation only needs the common `Type` interface.
pub enum TypeEnum {
  /// IEEE 754 binary16 floating-point type.
  HalfType(HalfType)
  /// BFloat16 floating-point type.
  BFloatType(BFloatType)
  /// IEEE 754 binary32 floating-point type.
  FloatType(FloatType)
  /// IEEE 754 binary64 floating-point type.
  DoubleType(DoubleType)
  /// IEEE 754 binary128 floating-point type.
  FP128Type(FP128Type)
  /// One-bit integer type.
  Int1Type(Int1Type)
  /// Eight-bit integer type.
  Int8Type(Int8Type)
  /// Sixteen-bit integer type.
  Int16Type(Int16Type)
  /// Thirty-two-bit integer type.
  Int32Type(Int32Type)
  /// Sixty-four-bit integer type.
  Int64Type(Int64Type)
  /// Type of functions that do not return a value.
  VoidType(VoidType)
  /// Basic-block label type.
  LabelType(LabelType)
  /// LLVM metadata type.
  MetadataType(MetadataType)
  /// LLVM token type.
  TokenType(TokenType)
  /// Function signature type.
  FunctionType(FunctionType)
  /// Structure aggregate type.
  StructType(StructType)
  /// Fixed-length array aggregate type.
  ArrayType(ArrayType)
  /// Fixed-width vector type.
  VectorType(VectorType)
  /// Scalable-width vector type.
  ScalableVectorType(ScalableVectorType)
  /// Opaque pointer type.
  PointerType(PointerType)
} derive(Eq)

///|
/// Views a closed type-classification case through the common `Type` trait.
///
/// **Lifecycle:** The returned view borrows the same context-owned LLVM type as
/// the enum payload. It must not outlive that context.
pub fn TypeEnum::asTypeClass(self : TypeEnum) -> &Type {
  match self {
    HalfType(t) => (t : &Type)
    BFloatType(t) => t
    FloatType(t) => t
    DoubleType(t) => t
    FP128Type(t) => t
    Int1Type(t) => t
    Int8Type(t) => t
    Int16Type(t) => t
    Int32Type(t) => t
    Int64Type(t) => t
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
/// Common interface implemented by every LLVM type wrapper in the safe API.
///
/// **Implementor contract:** `getTypeRef`, `asTypeEnum`, and `getContext` must
/// all describe the same live LLVM type. Implementations must not fabricate a
/// raw handle or associate a type with a different context.
///
/// **Lifecycle:** LLVM types are owned by their `Context`. Every borrowed view
/// returned through this trait is valid only while that context remains alive.
pub trait Type: Show {
  /// Returns the borrowed raw LLVM type handle represented by this wrapper.
  ///
  /// **Lifecycle:** The handle is context-owned and must not be disposed by the
  /// caller.
  fn getTypeRef(Self) -> @unsafe.LLVMTypeRef

  /// Returns the concrete safe classification of this type.
  fn asTypeEnum(Self) -> TypeEnum

  /// Returns the context that owns this LLVM type.
  fn getContext(Self) -> Context = _
  //print(Self, logger: &Logger, isForDebug~ = false, noDetails~ = false)
  //dump(Self)

  /// Returns `true` for `half` and `bfloat` types.
  fn is16bitFPTy(Self) -> Bool = _

  /// Returns `true` for the IEEE-like floating-point types supported by this
  /// package.
  fn isIEEELikeFPTy(Self) -> Bool = _

  /// Returns `true` for a scalar floating-point type.
  fn isFloatingPointTy(Self) -> Bool = _

  /// Reports whether this is a target-extension type with scalable layout.
  ///
  /// **Notes:** Target-extension types are not currently represented by the
  /// safe type hierarchy, so built-in implementations return `false`.
  fn isScalableTargetExtTy(Self) -> Bool = _

  /// Reports whether this type has a size expressed as a multiple of `vscale`.
  ///
  /// **Dev Notes:** This predicate is not fully implemented yet and currently
  /// returns `false` for built-in wrappers, including `ScalableVectorType`.
  fn isScalableTy(Self) -> Bool = _

  /// Return true if this type is or contains a target extension type that
  /// disallows being used as a global.
  // REVIEW: cpp has another `containsNonGlobalTargetExtType` function
  //bool containsNonGlobalTargetExtType() const;

  /// Return true if this type is or contains a target extension type that
  /// disallows being used as a local.
  // REVIEW: cpp has another `containsNonLocalTargetExtType` function
  //bool containsNonLocalTargetExtType() const;

  /// Returns `true` for a floating-point type or a vector of floating-point
  /// elements.
  fn isFPOrFPVectorTy(Self) -> Bool = _

  /// Returns `true` for an integer type or a vector of integer elements.
  fn isIntOrIntVectorTy(Self) -> Bool = _

  /// Returns `true` for a scalar integer or pointer type.
  ///
  /// **Notes:** Unlike the vector-aware predicates, this does not inspect vector
  /// element types.
  fn isIntOrPtrTy(Self) -> Bool = _

  /// Returns `true` for a pointer type or a vector of pointer elements.
  fn isPtrOrPtrVectorTy(Self) -> Bool = _

  /// Returns `true` when the type has no storage-bearing aggregate elements.
  fn isEmptyTy(Self) -> Bool = _

  /// Returns `true` when values of this type may be represented as LLVM values.
  fn isFirstClassType(Self) -> Bool = _

  /// Returns `true` for scalar, pointer, and vector types that form a single
  /// code-generation value.
  ///
  /// **Notes:** Structs and arrays are excluded even when `isFirstClassType`
  /// returns `true` for them.
  fn isSingleValueType(Self) -> Bool = _

  /// Returns `true` for struct and array aggregate types.
  ///
  /// **Notes:** Vector types are single values, not aggregates for this
  /// predicate.
  fn isAggregateType(Self) -> Bool = _

  /// Returns whether LLVM permits a size expression to be formed for this type.
  ///
  /// **Notes:** This does not compute a target-specific byte count.
  fn isSized(Self) -> Bool = _

  /// Creates LLVM's constant `sizeof` expression for this type.
  ///
  /// **Returns:** `Some(value)` for a sized type; `None` when `isSized` is
  /// `false` or LLVM does not produce an expression.
  ///
  /// **Lifecycle:** The returned value is owned by the same context as this
  /// type and must not outlive it.
  ///
  /// **Notes:** The result is an LLVM constant expression, not a host-side byte
  /// count. Its numeric interpretation depends on the target data layout.
  fn sizeOf(Self) -> &Value? = _

  /// Returns whether the type may be used as the source element type of GEP.
  fn isValidGEPType(Self) -> Bool = _

  /// Returns a vector's element type, or this type itself for non-vectors.
  ///
  /// **Lifecycle:** The returned view is owned by the same context as this
  /// type.
  fn getScalarType(Self) -> &Type = _

  /// Downcasts to an integer type, returning `None` for all other types.
  fn tryAsIntType(Self) -> &IntegerType? = _

  /// Returns the concrete integer case, or `None` for all other types.
  fn tryAsIntTypeEnum(Self) -> IntegerTypeEnum? = _

  /// Downcasts to a floating-point type, returning `None` otherwise.
  fn tryAsFPType(Self) -> &FPType? = _

  /// Returns the concrete floating-point case, or `None` otherwise.
  fn tryAsFPTypeEnum(Self) -> FPTypeEnum? = _

  /// Downcasts to an integer or floating-point primitive, returning `None`
  /// otherwise.
  fn tryAsPrimitiveType(Self) -> &PrimitiveType? = _

  /// Returns the concrete primitive case, or `None` otherwise.
  fn tryAsPrimitiveTypeEnum(Self) -> PrimitiveTypeEnum? = _

  /// Downcasts to a struct or array aggregate, returning `None` otherwise.
  fn tryAsAggregateType(Self) -> &AggregateType? = _

  /// Returns the concrete aggregate case, or `None` otherwise.
  fn tryAsAggregateTypeEnum(Self) -> AggregateTypeEnum? = _

  /// Downcasts to an abstract LLVM type, returning `None` otherwise.
  fn tryAsAbstractType(Self) -> &AbstractType? = _

  /// Returns the concrete abstract-type case, or `None` otherwise.
  fn tryAsAbstractTypeEnum(Self) -> AbstractTypeEnum? = _
}

///|
/// Formats any `Type` trait object using LLVM's textual type syntax.
pub extend &Type with Show::{to_string}

///|
/// Error raised when a raw LLVM type cannot be represented by the safe type
/// hierarchy.
pub suberror InValidTypeError {
  /// Contains the unsupported type kind or invalid integer-width detail.
  InValidTypeError(String)
}

///|
fn initAbstractType_err(
  typeref : @unsafe.LLVMTypeRef,
  context : Context,
) -> &Type raise InValidTypeError {
  let kind = @unsafe.llvm_get_type_kind(typeref)
  match kind {
    LLVMVoidTypeKind => VoidType::from_raw(typeref, context) as &Type
    LLVMHalfTypeKind => HalfType::from_raw(typeref, context)
    LLVMBFloatTypeKind => BFloatType::from_raw(typeref, context)
    LLVMFloatTypeKind => FloatType::from_raw(typeref, context)
    LLVMDoubleTypeKind => DoubleType::from_raw(typeref, context)
    LLVMFP128TypeKind => FP128Type::from_raw(typeref, context)
    LLVMPointerTypeKind => PointerType::from_raw(typeref, context)
    LLVMStructTypeKind => StructType::from_raw(typeref, context)
    LLVMArrayTypeKind => ArrayType::from_raw(typeref, context)
    LLVMVectorTypeKind => VectorType::from_raw(typeref, context)
    LLVMScalableVectorTypeKind => ScalableVectorType::from_raw(typeref, context)
    LLVMIntegerTypeKind => {
      let bitwidth = @unsafe.llvm_get_int_type_width(typeref)
      match bitwidth {
        1 => Int1Type::from_raw(typeref, context) as &Type
        8 => Int8Type::from_raw(typeref, context)
        16 => Int16Type::from_raw(typeref, context)
        32 => Int32Type::from_raw(typeref, context)
        64 => Int64Type::from_raw(typeref, context)
        _ =>
          raise InValidTypeError(
            "Invalid integer type with bitwidth: \{bitwidth}",
          )
      }
    }
    LLVMLabelTypeKind => LabelType::from_raw(typeref, context)
    LLVMMetadataTypeKind => MetadataType::from_raw(typeref, context)
    LLVMTokenTypeKind => TokenType::from_raw(typeref, context)
    LLVMFunctionTypeKind => FunctionType::from_raw(typeref, context)
    LLVMPPC_FP128TypeKind =>
      raise InValidTypeError("PPC FP128 type is not supported")
    LLVMX86_FP80TypeKind =>
      raise InValidTypeError("X86 FP80 type is not supported")
    _ => raise InValidTypeError("Invalid type kind: \{kind}")
  }
}

///|
fn initAbstractType(typeref : @unsafe.LLVMTypeRef, context : Context) -> &Type {
  initAbstractType_err(typeref, context) catch {
    _ => {
      println("ICE: Invalid Type kind")
      panic()
    }
  }
}

///|
impl Eq for &Type with fn equal(self, other) {
  self.asTypeEnum() == other.asTypeEnum()
}

///|
impl Type with fn getContext(self) -> Context {
  match self.asTypeEnum() {
    HalfType(ty) => ty.get_context()
    BFloatType(ty) => ty.get_context()
    FloatType(ty) => ty.get_context()
    DoubleType(ty) => ty.get_context()
    FP128Type(ty) => ty.get_context()
    Int1Type(ty) => ty.get_context()
    Int8Type(ty) => ty.get_context()
    Int16Type(ty) => ty.get_context()
    Int32Type(ty) => ty.get_context()
    Int64Type(ty) => ty.get_context()
    VoidType(ty) => ty.get_context()
    LabelType(ty) => ty.get_context()
    MetadataType(ty) => ty.get_context()
    TokenType(ty) => ty.get_context()
    FunctionType(ty) => ty.get_context()
    StructType(ty) => ty.get_context()
    ArrayType(ty) => ty.get_context()
    VectorType(ty) => ty.get_context()
    ScalableVectorType(ty) => ty.get_context()
    PointerType(ty) => ty.get_context()
  }
}

///|
impl Type with fn is16bitFPTy(self) -> Bool {
  self.asTypeEnum() is (HalfType(_) | BFloatType(_))
}

///|
impl Type with fn isIEEELikeFPTy(self) -> Bool {
  self.tryAsFPTypeEnum() is Some(_)
}

///|
impl Type with fn isFloatingPointTy(self) -> Bool {
  self.tryAsFPTypeEnum() is Some(_)
}

///|
#internal(unsafe, "This functions is not fully implemented yet")
impl Type with fn isScalableTargetExtTy(_) {
  false
}

///|
#internal(unsafe, "This functions is not fully implemented yet")
impl Type with fn isScalableTy(_) -> Bool {
  false
}

///|
impl Type with fn isIntOrIntVectorTy(self) -> Bool {
  self.getScalarType().asTypeEnum()
  is (Int1Type(_) | Int8Type(_) | Int16Type(_) | Int32Type(_) | Int64Type(_))
}

///|
impl Type with fn isFPOrFPVectorTy(self) -> Bool {
  self.getScalarType().isFloatingPointTy()
}

//impl Type with isRISCVectorTupleTy(self) -> Bool

///|
impl Type with fn isIntOrPtrTy(self) -> Bool {
  self.asTypeEnum()
  is (Int1Type(_)
  | Int8Type(_)
  | Int16Type(_)
  | Int32Type(_)
  | Int64Type(_)
  | PointerType(_))
}

///|
impl Type with fn isPtrOrPtrVectorTy(self) -> Bool {
  self.getScalarType().asTypeEnum() is PointerType(_)
}

///|
impl Type with fn isEmptyTy(self) -> Bool {
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
impl Type with fn isFirstClassType(self) {
  match self.asTypeEnum() {
    StructType(sty) => !sty.isOpaque()
    FunctionType(_) | VoidType(_) => false
    _ => true
  }
}

// REVIEW: Maybe we could use math-cases

///|
impl Type with fn isSingleValueType(self) -> Bool {
  match self.asTypeEnum() {
    HalfType(_) | BFloatType(_) | FloatType(_) | DoubleType(_) | FP128Type(_) =>
      true
    Int1Type(_) | Int8Type(_) | Int16Type(_) | Int32Type(_) | Int64Type(_) =>
      true
    PointerType(_) => true
    VectorType(_) | ScalableVectorType(_) => true
    _ => false
  }
}

///|
impl Type with fn isAggregateType(self) -> Bool {
  match self.asTypeEnum() {
    StructType(_) | ArrayType(_) => true
    _ => false
  }
}

///|
impl Type with fn isSized(self) -> Bool {
  @unsafe.llvm_type_is_sized(self.getTypeRef())
}

///|
impl Type with fn sizeOf(self) -> &Value? {
  guard self.isSized() else { return None }
  let valueref = @unsafe.llvm_size_of(self.getTypeRef())
  if @unsafe.llvm_value_ref_is_null(valueref) {
    None
  } else {
    let value = ConstantExpr::from_raw(valueref, self.getContext())
    Some(value)
  }
}

///|
impl Type with fn isValidGEPType(self) -> Bool {
  self.tryAsAbstractTypeEnum() is None
}

///|
impl Type with fn getScalarType(self) {
  match self.asTypeEnum() {
    VectorType(vec) => vec.getElementType()
    ScalableVectorType(vec) => vec.getElementType()
    _ => self
  }
}

///|
impl Type with fn tryAsIntType(self) -> &IntegerType? {
  match self.asTypeEnum() {
    Int1Type(i) => Some(i)
    Int8Type(i) => Some(i)
    Int16Type(i) => Some(i)
    Int32Type(i) => Some(i)
    Int64Type(i) => Some(i)
    _ => None
  }
}

///|
impl Type with fn tryAsIntTypeEnum(self) -> IntegerTypeEnum? {
  match self.asTypeEnum() {
    Int1Type(i) => Some(Int1Type(i))
    Int8Type(i) => Some(Int8Type(i))
    Int16Type(i) => Some(Int16Type(i))
    Int32Type(i) => Some(Int32Type(i))
    Int64Type(i) => Some(Int64Type(i))
    _ => None
  }
}

///|
impl Type with fn tryAsFPType(self) -> &FPType? {
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
impl Type with fn tryAsFPTypeEnum(self) -> FPTypeEnum? {
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
impl Type with fn tryAsPrimitiveType(self) -> &PrimitiveType? {
  match self.asTypeEnum() {
    HalfType(half) => Some(half)
    BFloatType(bfloat) => Some(bfloat)
    FloatType(float) => Some(float)
    DoubleType(double) => Some(double)
    FP128Type(fp128) => Some(fp128)
    Int1Type(int1) => Some(int1)
    Int8Type(int8) => Some(int8)
    Int16Type(int16) => Some(int16)
    Int32Type(int32) => Some(int32)
    Int64Type(int64) => Some(int64)
    _ => None
  }
}

///|
impl Type with fn tryAsPrimitiveTypeEnum(self) -> PrimitiveTypeEnum? {
  match self.asTypeEnum() {
    HalfType(half) => Some(HalfType(half))
    BFloatType(bfloat) => Some(BFloatType(bfloat))
    FloatType(float) => Some(FloatType(float))
    DoubleType(double) => Some(DoubleType(double))
    FP128Type(fp128) => Some(FP128Type(fp128))
    Int1Type(int1) => Some(Int1Type(int1))
    Int8Type(int8) => Some(Int8Type(int8))
    Int16Type(int16) => Some(Int16Type(int16))
    Int32Type(int32) => Some(Int32Type(int32))
    Int64Type(int64) => Some(Int64Type(int64))
    _ => None
  }
}

///|
impl Type with fn tryAsAggregateType(self) -> &AggregateType? {
  match self.asTypeEnum() {
    StructType(sty) => Some(sty)
    ArrayType(arr) => Some(arr)
    _ => None
  }
}

///|
impl Type with fn tryAsAggregateTypeEnum(self) -> AggregateTypeEnum? {
  match self.asTypeEnum() {
    StructType(sty) => Some(StructType(sty))
    ArrayType(arr) => Some(ArrayType(arr))
    _ => None
  }
}

///|
impl Type with fn tryAsAbstractType(self) -> &AbstractType? {
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
impl Type with fn tryAsAbstractTypeEnum(self) -> AbstractTypeEnum? {
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
// IntegerType & IntegerTypeEnum
// ====================================================================

///|
/// Common interface for the supported fixed-width integer types.
///
/// **Implementor contract:** The classification returned by
/// `asIntegerTypeEnum` must carry the same LLVM type as `getTypeRef`.
///
/// **Lifecycle:** Integer types are owned by their context.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let i8ty : &IntegerType = ctx.getInt8Ty()
///   assert_eq(i8ty.getBitWidth(), 8)
///   match i8ty.getExtendedType() {
///     Some(i16ty) => inspect(i16ty, content="i16")
///     None => fail("i8 must have an extended integer type")
///   }
/// }
/// ```
pub trait IntegerType: PrimitiveType {
  /// Returns the concrete fixed-width integer classification.
  fn asIntegerTypeEnum(Self) -> IntegerTypeEnum

  /// Returns the next supported wider integer type.
  ///
  /// **Returns:** `i16` for `i8`, `i32` for `i16`, and `i64` for `i32`;
  /// returns `None` for `i1` and `i64`.
  ///
  /// **Lifecycle:** A returned type is owned by the same context as this type.
  fn getExtendedType(Self) -> &IntegerType? = _
}

/////|
//impl IntegerType with getBitWidth(self) -> UInt {
//  @unsafe.llvm_get_int_type_width(self.getTypeRef())
//}

///|
impl IntegerType with fn getExtendedType(self) -> &IntegerType? {
  let ctx = Type::getContext(self)
  match self.asIntegerTypeEnum() {
    Int8Type(_) => ctx.getInt16Ty() |> Some
    Int16Type(_) => ctx.getInt32Ty() |> Some
    Int32Type(_) => ctx.getInt64Ty() |> Some
    Int64Type(_) => None
    Int1Type(_) => None
  }
}

///|
/// Exposes primitive bit-width operations on an integer trait object.
pub extend &IntegerType with PrimitiveType::{getBitWidth}

///|
/// Exposes the borrowed raw LLVM handle on an integer trait object.
pub extend &IntegerType with Type::{getTypeRef}

///|
/// Closed classification of the supported fixed-width integer types.
pub enum IntegerTypeEnum {
  /// One-bit integer type.
  Int1Type(Int1Type)
  /// Eight-bit integer type.
  Int8Type(Int8Type)
  /// Sixteen-bit integer type.
  Int16Type(Int16Type)
  /// Thirty-two-bit integer type.
  Int32Type(Int32Type)
  /// Sixty-four-bit integer type.
  Int64Type(Int64Type)
} derive(Eq)

///|
/// Views an integer classification through the common `Type` trait.
///
/// **Lifecycle:** The returned view remains owned by the original context.
pub fn IntegerTypeEnum::asTypeClass(self : IntegerTypeEnum) -> &Type {
  match self {
    Int1Type(t) => (t : &Type)
    Int8Type(t) => t
    Int16Type(t) => t
    Int32Type(t) => t
    Int64Type(t) => t
  }
}

///|
/// Returns the integer width in bits.
pub fn IntegerTypeEnum::getBitWidth(self : IntegerTypeEnum) -> UInt {
  match self {
    Int1Type(_) => 1
    Int8Type(_) => 8
    Int16Type(_) => 16
    Int32Type(_) => 32
    Int64Type(_) => 64
  }
}

// ====================================================================
// FPType && FPTypeEnum
// ====================================================================

///|
/// Common interface for the floating-point types supported by the safe API.
///
/// **Implementor contract:** `asFPTypeEnum` must classify the same LLVM type as
/// the inherited `Type` methods.
pub trait FPType: PrimitiveType {
  /// Returns the concrete floating-point classification.
  fn asFPTypeEnum(Self) -> FPTypeEnum

  /// Returns the significand precision in bits, including the implicit leading
  /// bit where the format has one.
  fn getFPMantissaWidth(Self) -> UInt = _
}

///|
/// Exposes primitive bit-width operations on a floating-point trait object.
pub extend &FPType with PrimitiveType::{getBitWidth}

///|
/// Exposes the borrowed raw LLVM handle on a floating-point trait object.
pub extend &FPType with Type::{getTypeRef}

///|
/// Closed classification of the supported floating-point types.
pub enum FPTypeEnum {
  /// IEEE 754 binary16 floating-point type.
  HalfType(HalfType)
  /// BFloat16 floating-point type.
  BFloatType(BFloatType)
  /// IEEE 754 binary32 floating-point type.
  FloatType(FloatType)
  /// IEEE 754 binary64 floating-point type.
  DoubleType(DoubleType)
  /// IEEE 754 binary128 floating-point type.
  FP128Type(FP128Type)
} derive(Eq)

///|
/// Views a floating-point classification through the common `Type` trait.
///
/// **Lifecycle:** The returned view remains owned by the original context.
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
/// Returns the significand precision of the represented floating-point format.
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
impl FPType with fn getFPMantissaWidth(self) {
  self.asFPTypeEnum().getFPMantissaWidth()
}

// ====================================================================
// Primitive Types, PrimitiveType && PrimitiveTypeEnum
// ====================================================================

///|
/// Common interface for scalar integer and floating-point primitive types.
///
/// **Implementor contract:** `asPrimitiveTypeEnum` must classify the same LLVM
/// type as the inherited `Type` methods.
pub trait PrimitiveType: Type {
  /// Returns the concrete primitive-type classification.
  fn asPrimitiveTypeEnum(Self) -> PrimitiveTypeEnum

  /// Returns the primitive representation width in bits.
  fn getBitWidth(Self) -> Int = _
}

///|
impl PrimitiveType with fn getBitWidth(self) -> Int {
  match self.asPrimitiveTypeEnum() {
    HalfType(_) => 16
    BFloatType(_) => 16
    FloatType(_) => 32
    DoubleType(_) => 64
    FP128Type(_) => 128
    Int1Type(_) =>
      @unsafe.llvm_get_int_type_width(Type::getTypeRef(self)).reinterpret_as_int()
    Int8Type(_) =>
      @unsafe.llvm_get_int_type_width(Type::getTypeRef(self)).reinterpret_as_int()
    Int16Type(_) =>
      @unsafe.llvm_get_int_type_width(Type::getTypeRef(self)).reinterpret_as_int()
    Int32Type(_) =>
      @unsafe.llvm_get_int_type_width(Type::getTypeRef(self)).reinterpret_as_int()
    Int64Type(_) =>
      @unsafe.llvm_get_int_type_width(Type::getTypeRef(self)).reinterpret_as_int()
  }
}

///|
/// Closed classification of scalar integer and floating-point primitive types.
pub enum PrimitiveTypeEnum {
  /// IEEE 754 binary16 floating-point type.
  HalfType(HalfType)
  /// BFloat16 floating-point type.
  BFloatType(BFloatType)
  /// IEEE 754 binary32 floating-point type.
  FloatType(FloatType)
  /// IEEE 754 binary64 floating-point type.
  DoubleType(DoubleType)
  /// IEEE 754 binary128 floating-point type.
  FP128Type(FP128Type)
  /// One-bit integer type.
  Int1Type(Int1Type)
  /// Eight-bit integer type.
  Int8Type(Int8Type)
  /// Sixteen-bit integer type.
  Int16Type(Int16Type)
  /// Thirty-two-bit integer type.
  Int32Type(Int32Type)
  /// Sixty-four-bit integer type.
  Int64Type(Int64Type)
} derive(Eq)

// ====================================================================
// Aggregate Types, AggregateType && AggregateTypeEnum
// ====================================================================

///|
/// Common interface for struct and array aggregate types.
///
/// **Implementor contract:** `asAggregateTypeEnum` must classify the same LLVM
/// type as the inherited `Type` methods.
pub trait AggregateType: Type {
  /// Returns the concrete aggregate classification.
  fn asAggregateTypeEnum(Self) -> AggregateTypeEnum

  /// Returns the element at `idx`, or `None` when the index is out of range.
  ///
  /// **Notes:** Arrays have one repeated element type; any index in the array's
  /// logical bounds returns that type.
  ///
  /// **Lifecycle:** A returned type is owned by the same context as the
  /// aggregate.
  fn getElementType(Self, Int) -> &Type? = _
}

///|
impl AggregateType with fn getElementType(self, idx : Int) -> &Type? {
  match self.asAggregateTypeEnum() {
    StructType(sty) => sty.getElementType(idx)
    ArrayType(arr) => {
      guard idx >= 0 && idx < arr.getElementCount() else { return None }
      Some(arr.getElementType())
    }
  }
}

///|
/// Closed classification of aggregate types.
pub enum AggregateTypeEnum {
  /// Structure aggregate type.
  StructType(StructType)
  /// Fixed-length array aggregate type.
  ArrayType(ArrayType)
} derive(Eq)

///|
/// Converts an aggregate classification to the general `TypeEnum`.
pub fn AggregateTypeEnum::toTypeEnum(self : AggregateTypeEnum) -> TypeEnum {
  match self {
    StructType(sty) => StructType(sty)
    ArrayType(arr) => ArrayType(arr)
  }
}

///|
/// Views an aggregate classification through the common `Type` trait.
///
/// **Lifecycle:** The returned view remains owned by the original context.
pub fn AggregateTypeEnum::asTypeClass(self : Self) -> &Type {
  match self {
    StructType(sty) => (sty : &Type)
    ArrayType(arr) => arr
  }
}

// ====================================================================
// Abstract Types, AbstractType && AbstractTypeEnum
// ====================================================================

///|
/// Common interface for LLVM types that do not represent ordinary scalar or
/// aggregate data.
///
/// **Implementor contract:** `asAbstractTypeEnum` must classify the same LLVM
/// type as the inherited `Type` methods.
pub trait AbstractType: Type {
  /// Returns the concrete abstract-type classification.
  fn asAbstractTypeEnum(Self) -> AbstractTypeEnum
}

///|
/// Closed classification of abstract LLVM types supported by the safe API.
pub enum AbstractTypeEnum {
  /// Type of functions that do not return a value.
  VoidType(VoidType)
  /// Basic-block label type.
  LabelType(LabelType)
  /// LLVM metadata type.
  MetadataType(MetadataType)
  /// LLVM token type.
  TokenType(TokenType)
  /// Function signature type.
  FunctionType(FunctionType)
}

// ====================================================================
// HalfType
// ====================================================================

///|
pub struct HalfType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn HalfType::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> HalfType {
  HalfType::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn HalfType::get_context(self : HalfType) -> Context {
  self.value.get_context()
}

///|
pub impl Show for HalfType with fn output(self, logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for HalfType with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::HalfType(self)
}

///|
pub impl Type for HalfType with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend HalfType with Type::{asTypeEnum, getTypeRef}

///|
pub impl FPType for HalfType with fn asFPTypeEnum(self) -> FPTypeEnum {
  FPTypeEnum::HalfType(self)
}

///|
pub extend HalfType with FPType::{asFPTypeEnum}

///|
pub impl PrimitiveType for HalfType with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  PrimitiveTypeEnum::HalfType(self)
}

///|
pub extend HalfType with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// BFloatType
// ====================================================================

///|
/// BFloatType
pub struct BFloatType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn BFloatType::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> BFloatType {
  BFloatType::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn BFloatType::get_context(self : BFloatType) -> Context {
  self.value.get_context()
}

///|
pub impl Show for BFloatType with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for BFloatType with fn asTypeEnum(self) -> TypeEnum {
  BFloatType(self)
}

///|
pub impl Type for BFloatType with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend BFloatType with Type::{asTypeEnum, getTypeRef}

///|
pub impl FPType for BFloatType with fn asFPTypeEnum(self) -> FPTypeEnum {
  BFloatType(self)
}

///|
pub extend BFloatType with FPType::{asFPTypeEnum}

///|
pub impl PrimitiveType for BFloatType with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  BFloatType(self)
}

///|
pub extend BFloatType with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// FloatType
// ====================================================================

///|
/// FloatType
pub struct FloatType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn FloatType::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> FloatType {
  FloatType::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn FloatType::get_context(self : FloatType) -> Context {
  self.value.get_context()
}

///|
pub impl Show for FloatType with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for FloatType with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::FloatType(self)
}

///|
pub impl Type for FloatType with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend FloatType with Type::{asTypeEnum, getTypeRef}

///|
pub impl FPType for FloatType with fn asFPTypeEnum(self) -> FPTypeEnum {
  FloatType(self)
}

///|
pub extend FloatType with FPType::{asFPTypeEnum}

///|
pub impl PrimitiveType for FloatType with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  FloatType(self)
}

///|
pub extend FloatType with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// DoubleType
// ====================================================================

///|
/// DoubleType
pub struct DoubleType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn DoubleType::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> DoubleType {
  DoubleType::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn DoubleType::get_context(self : DoubleType) -> Context {
  self.value.get_context()
}

///| Create a DoubleType
//fn DoubleType::new(typeref : @unsafe.LLVMTypeRef) -> DoubleType {
//  DoubleType::{ typeref, }
//}

///|
pub impl Show for DoubleType with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for DoubleType with fn asTypeEnum(self) -> TypeEnum {
  DoubleType(self)
}

///|
pub impl Type for DoubleType with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend DoubleType with Type::{asTypeEnum, getTypeRef}

///|
pub impl FPType for DoubleType with fn asFPTypeEnum(self) -> FPTypeEnum {
  DoubleType(self)
}

///|
pub extend DoubleType with FPType::{asFPTypeEnum}

///|
pub impl PrimitiveType for DoubleType with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  DoubleType(self)
}

///|
pub extend DoubleType with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// FP128Type
// ====================================================================

///|
/// FP128Ty
pub struct FP128Type {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn FP128Type::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> FP128Type {
  FP128Type::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn FP128Type::get_context(self : FP128Type) -> Context {
  self.value.get_context()
}
//pub struct FP128Type {
//  priv typeref : @unsafe.LLVMTypeRef
//} derive(Eq)

///| Create a FP128Ty.
//fn FP128Type::new(typeref : @unsafe.LLVMTypeRef) -> FP128Type {
//  FP128Type::{ typeref, }
//}

///|
pub impl Show for FP128Type with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for FP128Type with fn asTypeEnum(self) -> TypeEnum {
  FP128Type(self)
}

///|
pub impl Type for FP128Type with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend FP128Type with Type::{asTypeEnum, getTypeRef}

///|
pub impl FPType for FP128Type with fn asFPTypeEnum(self) -> FPTypeEnum {
  FP128Type(self)
}

///|
pub extend FP128Type with FPType::{asFPTypeEnum}

///|
pub impl PrimitiveType for FP128Type with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  FP128Type(self)
}

///|
pub extend FP128Type with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// Int1Type
// ====================================================================

///|
pub struct Int1Type {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn Int1Type::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> Int1Type {
  Int1Type::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn Int1Type::get_context(self : Int1Type) -> Context {
  self.value.get_context()
}

///|
pub impl Show for Int1Type with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for Int1Type with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::Int1Type(self)
}

///|
pub impl Type for Int1Type with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend Int1Type with Type::{asTypeEnum, getTypeRef}

///|
pub impl IntegerType for Int1Type with fn asIntegerTypeEnum(self) -> IntegerTypeEnum {
  Int1Type(self)
}

///|
pub extend Int1Type with IntegerType::{asIntegerTypeEnum}

///|
pub impl PrimitiveType for Int1Type with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  Int1Type(self)
}

///|
pub extend Int1Type with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// Int8Type
// ====================================================================

///|
pub struct Int8Type {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn Int8Type::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> Int8Type {
  Int8Type::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn Int8Type::get_context(self : Int8Type) -> Context {
  self.value.get_context()
}

///|
pub impl Show for Int8Type with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for Int8Type with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::Int8Type(self)
}

///|
pub impl Type for Int8Type with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend Int8Type with Type::{asTypeEnum, getTypeRef}

///|
pub impl IntegerType for Int8Type with fn asIntegerTypeEnum(self) -> IntegerTypeEnum {
  Int8Type(self)
}

///|
pub extend Int8Type with IntegerType::{asIntegerTypeEnum}

///|
pub impl PrimitiveType for Int8Type with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  Int8Type(self)
}

///|
pub extend Int8Type with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// Int16Type
// ====================================================================

///|
pub struct Int16Type {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn Int16Type::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> Int16Type {
  Int16Type::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn Int16Type::get_context(self : Int16Type) -> Context {
  self.value.get_context()
}

///|
pub impl Show for Int16Type with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for Int16Type with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::Int16Type(self)
}

///|
pub impl Type for Int16Type with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend Int16Type with Type::{asTypeEnum, getTypeRef}

///|
pub impl IntegerType for Int16Type with fn asIntegerTypeEnum(self) -> IntegerTypeEnum {
  Int16Type(self)
}

///|
pub extend Int16Type with IntegerType::{asIntegerTypeEnum}

///|
pub impl PrimitiveType for Int16Type with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  Int16Type(self)
}

///|
pub extend Int16Type with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// Int32Type
// ====================================================================

///|
pub struct Int32Type {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn Int32Type::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> Int32Type {
  Int32Type::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn Int32Type::get_context(self : Int32Type) -> Context {
  self.value.get_context()
}

///|
pub impl Show for Int32Type with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for Int32Type with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::Int32Type(self)
}

///|
pub impl Type for Int32Type with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend Int32Type with Type::{asTypeEnum, getTypeRef}

///|
pub impl IntegerType for Int32Type with fn asIntegerTypeEnum(self) -> IntegerTypeEnum {
  Int32Type(self)
}

///|
pub extend Int32Type with IntegerType::{asIntegerTypeEnum}

///|
pub impl PrimitiveType for Int32Type with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  Int32Type(self)
}

///|
pub extend Int32Type with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// Int64Type
// ====================================================================

///|
pub struct Int64Type {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn Int64Type::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> Int64Type {
  Int64Type::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn Int64Type::get_context(self : Int64Type) -> Context {
  self.value.get_context()
}

///|
pub impl Show for Int64Type with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for Int64Type with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::Int64Type(self)
}

///|
pub impl Type for Int64Type with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend Int64Type with Type::{asTypeEnum, getTypeRef}

///|
pub impl IntegerType for Int64Type with fn asIntegerTypeEnum(self) -> IntegerTypeEnum {
  Int64Type(self)
}

///|
pub extend Int64Type with IntegerType::{asIntegerTypeEnum}

///|
pub impl PrimitiveType for Int64Type with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  Int64Type(self)
}

///|
pub extend Int64Type with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// VoidType
// ====================================================================

///|
pub struct VoidType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn VoidType::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> VoidType {
  VoidType::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn VoidType::get_context(self : VoidType) -> Context {
  self.value.get_context()
}

///|
pub impl Show for VoidType with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for VoidType with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub impl Type for VoidType with fn asTypeEnum(self) -> TypeEnum {
  VoidType(self)
}

///|
pub extend VoidType with Type::{asTypeEnum, getTypeRef}

///|
pub impl AbstractType for VoidType with fn asAbstractTypeEnum(self) -> AbstractTypeEnum {
  VoidType(self)
}

///|
pub extend VoidType with AbstractType::{asAbstractTypeEnum}

// ====================================================================
// LabelType
// ====================================================================

///|
/// LabelTy
pub struct LabelType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn LabelType::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> LabelType {
  LabelType::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn LabelType::get_context(self : LabelType) -> Context {
  self.value.get_context()
}

///|
pub impl Show for LabelType with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for LabelType with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::LabelType(self)
}

///|
pub impl Type for LabelType with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend LabelType with Type::{asTypeEnum, getTypeRef}

///|
pub impl AbstractType for LabelType with fn asAbstractTypeEnum(self) -> AbstractTypeEnum {
  LabelType(self)
}

///|
pub extend LabelType with AbstractType::{asAbstractTypeEnum}

// ====================================================================
// MetadataType
// ====================================================================

///|
pub struct MetadataType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn MetadataType::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> MetadataType {
  MetadataType::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn MetadataType::get_context(self : MetadataType) -> Context {
  self.value.get_context()
}

///|
pub impl Show for MetadataType with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for MetadataType with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::MetadataType(self)
}

///|
pub impl Type for MetadataType with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend MetadataType with Type::{asTypeEnum, getTypeRef}

///|
pub impl AbstractType for MetadataType with fn asAbstractTypeEnum(self) -> AbstractTypeEnum {
  MetadataType(self)
}

///|
pub extend MetadataType with AbstractType::{asAbstractTypeEnum}

// ====================================================================
// TokenTy
// ====================================================================

///|
/// TokenTy
pub struct TokenType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn TokenType::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> TokenType {
  TokenType::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn TokenType::get_context(self : TokenType) -> Context {
  self.value.get_context()
}

///|
pub impl Show for TokenType with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for TokenType with fn asTypeEnum(self) -> TypeEnum {
  TokenType(self)
}

///|
pub impl Type for TokenType with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend TokenType with Type::{asTypeEnum, getTypeRef}

///|
pub impl AbstractType for TokenType with fn asAbstractTypeEnum(self) -> AbstractTypeEnum {
  TokenType(self)
}

///|
pub extend TokenType with AbstractType::{asAbstractTypeEnum}

// ====================================================================
// FunctionType
// ====================================================================

///|
pub struct FunctionType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn FunctionType::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> FunctionType {
  FunctionType::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn FunctionType::get_context(self : FunctionType) -> Context {
  self.value.get_context()
}

///|
pub fn FunctionType::isVarArg(self : FunctionType) -> Bool {
  @unsafe.llvm_is_function_var_arg(self.getTypeRef())
}

///|
/// Get the return type of the function.
pub fn FunctionType::getReturnType(self : FunctionType) -> &Type {
  let typeref = @unsafe.llvm_get_return_type(self.getTypeRef())
  initAbstractType(typeref, self.get_context())
}

///|
pub fn FunctionType::numOfParams(self : FunctionType) -> Int {
  @unsafe.llvm_count_param_types(self.getTypeRef()).reinterpret_as_int()
}

///|
/// Get the params of the function.
///
/// - See LLVM: `FunctionType::params`.
pub fn FunctionType::params(self : FunctionType) -> Array[&Type] {
  let param_types = @unsafe.llvm_get_param_types(self.getTypeRef())
  param_types.map(typeref => initAbstractType(typeref, self.get_context()))
}

///|
/// Get the params of the function.
///
/// - See LLVM: `FunctionType::params`.
pub fn FunctionType::getParamTypes(self : FunctionType) -> Array[&Type] {
  let param_types = @unsafe.llvm_get_param_types(self.getTypeRef())
  param_types.map(typeref => initAbstractType(typeref, self.get_context()))
}

///|
/// Return the number of fixed parameters this function type requires.
/// This does not consider varargs.
///
/// - See LLVM: `FunctionType::getNumParams`.
pub fn FunctionType::getNumParams(self : FunctionType) -> Int {
  @unsafe.llvm_count_param_types(self.getTypeRef()).reinterpret_as_int()
}

///|
/// Get the param type by given index.
pub fn FunctionType::getParamType(self : FunctionType, idx : Int) -> &Type? {
  let param_types = @unsafe.llvm_get_param_types(self.getTypeRef())
  guard idx >= 0 && idx < param_types.length() else { return None }
  let typeref = param_types[idx]
  try initAbstractType_err(typeref, self.get_context()) catch {
    _ => None
  } noraise {
    ty => Some(ty)
  }
}

///|
pub impl Show for FunctionType with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for FunctionType with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::FunctionType(self)
}

///|
pub impl Type for FunctionType with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend FunctionType with Type::{asTypeEnum, getTypeRef}

///|
pub impl AbstractType for FunctionType with fn asAbstractTypeEnum(self) -> AbstractTypeEnum {
  AbstractTypeEnum::FunctionType(self)
}

///|
pub extend FunctionType with AbstractType::{asAbstractTypeEnum}

// ====================================================================
// StructType
// ====================================================================

///|
pub struct StructType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn StructType::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> StructType {
  StructType::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn StructType::get_context(self : StructType) -> Context {
  self.value.get_context()
}

///|
/// Check struct is a literal type.
///
/// literal type means the struct only has body but has no name.
///
/// - See LLVM: `StructType::isLiteral`.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let i32ty = ctx.getInt32Ty()
///   let f32ty = ctx.getFloatTy()
///
///   let foo = ctx.getStructType([i32ty, f32ty])
///   let bar = ctx.getStructType([i32ty, f32ty], name="bar")
///
///   assert_true(foo.isLiteral())
///   assert_false(bar.isLiteral())
/// }
/// ```
pub fn StructType::isLiteral(self : StructType) -> Bool {
  @unsafe.llvm_is_literal_struct(self.getTypeRef())
}

///|
/// Check struct is a opaque type.
/// Return true if this is a type with an identity that has no body specified
/// yet. These prints as 'opaque' in .ll files.
///
/// - See LLVM: `StructType::isOpaque`.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let i32ty = ctx.getInt32Ty()
///   let f32ty = ctx.getFloatTy()
///
///   let bar = ctx.getStructType([i32ty, f32ty], name="bar")
///   assert_false(bar.isOpaque())
/// }
/// ```
pub fn StructType::isOpaque(self : StructType) -> Bool {
  @unsafe.llvm_is_opaque_struct(self.getTypeRef())
}

///|
/// Check if this is a packed struct type.
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
  try initAbstractType_err(typeref, self.get_context()) catch {
    _ => None
  } noraise {
    ty => Some(ty)
  }
}

///|
/// Get the elements of the struct.
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
pub suberror SetBodyForNonOpaqueStruct {
  SetBodyForNonOpaqueStruct(String)
}

///|
/// Set the body of the struct.
///
/// Only Opaque struct can be set body.
///
/// - See LLVM: `StructType::setBody`.
pub fn StructType::setBody(
  self : StructType,
  elements : Array[&Type],
  isPacked? : Bool = false,
) -> Unit raise {
  // only opaque struct can be set body.
  guard self.isOpaque() else {
    raise SetBodyForNonOpaqueStruct("Cannot set body for non-opaque struct")
  }
  let field_types = elements.map(t => t.getTypeRef())
  @unsafe.llvm_struct_set_body(self.getTypeRef(), field_types, isPacked)
}

///|
pub impl Show for StructType with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for StructType with fn asTypeEnum(self) -> TypeEnum {
  StructType(self)
}

///|
pub impl Type for StructType with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend StructType with Type::{asTypeEnum, getTypeRef}

///|
pub impl AggregateType for StructType with fn asAggregateTypeEnum(self) -> AggregateTypeEnum {
  StructType(self)
}

///|
pub extend StructType with AggregateType::{asAggregateTypeEnum}

// ====================================================================
// ArrayType
// ====================================================================

///|
pub struct ArrayType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn ArrayType::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> ArrayType {
  ArrayType::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn ArrayType::get_context(self : ArrayType) -> Context {
  self.value.get_context()
}

///|
pub fn ArrayType::getElementCount(self : ArrayType) -> Int {
  @unsafe.llvm_get_array_length(self.getTypeRef()).reinterpret_as_int()
}

///|
pub fn ArrayType::getElementType(self : ArrayType) -> &Type {
  let typeref = @unsafe.llvm_get_element_type(self.getTypeRef())
  initAbstractType(typeref, self.get_context())
}

///|
pub impl Show for ArrayType with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for ArrayType with fn asTypeEnum(self) -> TypeEnum {
  ArrayType(self)
}

///|
pub impl Type for ArrayType with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend ArrayType with Type::{asTypeEnum, getTypeRef}

///|
pub impl AggregateType for ArrayType with fn asAggregateTypeEnum(self) -> AggregateTypeEnum {
  ArrayType(self)
}

///|
pub extend ArrayType with AggregateType::{asAggregateTypeEnum}

// ====================================================================
// VectorType
// ====================================================================

///|
pub struct VectorType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn VectorType::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> VectorType {
  VectorType::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn VectorType::get_context(self : VectorType) -> Context {
  self.value.get_context()
}

///|
/// Get the element type of the vector.
pub fn VectorType::getElementType(self : VectorType) -> &Type {
  let typeref = @unsafe.llvm_get_element_type(self.getTypeRef())
  initAbstractType(typeref, self.get_context())
}

///|
/// Get the number of elements in the vector.
pub fn VectorType::getElementCount(self : VectorType) -> Int {
  @unsafe.llvm_get_vector_size(self.getTypeRef()).reinterpret_as_int()
}

///|
pub impl Show for VectorType with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for VectorType with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::VectorType(self)
}

///|
pub impl Type for VectorType with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend VectorType with Type::{asTypeEnum, getTypeRef}

// ====================================================================
// ScalableVectorType
// ====================================================================

///|
pub struct ScalableVectorType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn ScalableVectorType::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> ScalableVectorType {
  ScalableVectorType::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn ScalableVectorType::get_context(self : ScalableVectorType) -> Context {
  self.value.get_context()
}

///|
/// Get the element type of the vector.
pub fn ScalableVectorType::getElementType(self : ScalableVectorType) -> &Type {
  let typeref = @unsafe.llvm_get_element_type(self.getTypeRef())
  initAbstractType(typeref, self.get_context())
}

///|
/// Get the number of elements in the vector.
pub fn ScalableVectorType::getElementCount(self : ScalableVectorType) -> Int {
  @unsafe.llvm_get_vector_size(self.getTypeRef()).reinterpret_as_int()
}

///|
pub impl Show for ScalableVectorType with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for ScalableVectorType with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::ScalableVectorType(self)
}

///|
pub impl Type for ScalableVectorType with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend ScalableVectorType with Type::{asTypeEnum, getTypeRef}

// ====================================================================
// PointerType
// ====================================================================

///|
/// Numeric LLVM address-space identifier used by pointer types.
///
/// Address space `0` is LLVM's default address space. Other values are
/// target-defined and must be interpreted using the target's data layout.
pub struct AddressSpace(UInt) derive(Hash, Eq, Default)

///|
/// Creates an address-space identifier from its raw numeric value.
///
/// **Parameters:**
///
/// - `v`: Target-defined address-space number.
///
/// **Notes:** This constructor does not validate whether the selected target
/// recognizes the address space.
pub fn AddressSpace::new(v : UInt) -> AddressSpace {
  AddressSpace(v)
}

///|
pub struct PointerType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn PointerType::from_raw(
  type_ref : @unsafe.LLVMTypeRef,
  context : Context,
) -> PointerType {
  PointerType::{ value: ContextAnchoredType::new(type_ref, context) }
}

///|
fn PointerType::get_context(self : PointerType) -> Context {
  self.value.get_context()
}

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
pub impl Show for PointerType with fn output(self, logger : &Logger) {
  self.getTypeRef().output(logger)
}

///|
pub impl Type for PointerType with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::PointerType(self)
}

///|
pub impl Type for PointerType with fn getTypeRef(self) -> @unsafe.LLVMTypeRef {
  self.value.get_unsafe_ref()
}

///|
pub extend PointerType with Type::{asTypeEnum, getTypeRef}
