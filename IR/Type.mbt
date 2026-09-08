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
/// **Implementor contract:** `asTypeEnum` and `getContext` must describe the
/// same live LLVM type and owning context.
///
/// **Lifecycle:** LLVM types are owned by their `Context`. Every borrowed view
/// returned through this trait is valid only while that context remains alive.
pub trait Type: Show {
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
fn &Type::get_raw_type_ref(self : &Type) -> @raw.LLVMTypeRef {
  match self.asTypeEnum() {
    HalfType(ty) => ty.get_raw_type_ref()
    BFloatType(ty) => ty.get_raw_type_ref()
    FloatType(ty) => ty.get_raw_type_ref()
    DoubleType(ty) => ty.get_raw_type_ref()
    FP128Type(ty) => ty.get_raw_type_ref()
    Int1Type(ty) => ty.get_raw_type_ref()
    Int8Type(ty) => ty.get_raw_type_ref()
    Int16Type(ty) => ty.get_raw_type_ref()
    Int32Type(ty) => ty.get_raw_type_ref()
    Int64Type(ty) => ty.get_raw_type_ref()
    VoidType(ty) => ty.get_raw_type_ref()
    LabelType(ty) => ty.get_raw_type_ref()
    MetadataType(ty) => ty.get_raw_type_ref()
    TokenType(ty) => ty.get_raw_type_ref()
    FunctionType(ty) => ty.get_raw_type_ref()
    StructType(ty) => ty.get_raw_type_ref()
    ArrayType(ty) => ty.get_raw_type_ref()
    VectorType(ty) => ty.get_raw_type_ref()
    ScalableVectorType(ty) => ty.get_raw_type_ref()
    PointerType(ty) => ty.get_raw_type_ref()
  }
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
  typeref : @raw.LLVMTypeRef,
  context : Context,
) -> &Type raise InValidTypeError {
  let kind = @raw.llvm_get_type_kind(typeref)
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
      let bitwidth = @raw.llvm_get_int_type_width(typeref)
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
fn initAbstractType(typeref : @raw.LLVMTypeRef, context : Context) -> &Type {
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
  @raw.llvm_type_is_sized((self : &Type).get_raw_type_ref())
}

///|
impl Type with fn sizeOf(self) -> &Value? {
  guard self.isSized() else { return None }
  let valueref = @raw.llvm_size_of((self : &Type).get_raw_type_ref())
  if @raw.llvm_value_ref_is_null(valueref) {
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
/// `asIntegerTypeEnum` must carry the same underlying LLVM type.
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
//  @raw.llvm_get_int_type_width((self : &Type).get_raw_type_ref())
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
      @raw.llvm_get_int_type_width((self : &Type).get_raw_type_ref()).reinterpret_as_int()
    Int8Type(_) =>
      @raw.llvm_get_int_type_width((self : &Type).get_raw_type_ref()).reinterpret_as_int()
    Int16Type(_) =>
      @raw.llvm_get_int_type_width((self : &Type).get_raw_type_ref()).reinterpret_as_int()
    Int32Type(_) =>
      @raw.llvm_get_int_type_width((self : &Type).get_raw_type_ref()).reinterpret_as_int()
    Int64Type(_) =>
      @raw.llvm_get_int_type_width((self : &Type).get_raw_type_ref()).reinterpret_as_int()
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
/// Context-owned wrapper for LLVM's 16-bit IEEE `half` type.
///
/// **Lifecycle:** The wrapper borrows an interned type from its `Context` and
/// must not outlive that context.
pub struct HalfType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn HalfType::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> HalfType {
  HalfType::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn HalfType::get_context(self : HalfType) -> Context {
  self.value.get_context()
}

///|
/// Writes `half` using LLVM's textual type syntax.
pub impl Show for HalfType with fn output(self, logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::HalfType`.
pub impl Type for HalfType with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::HalfType(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn HalfType::get_raw_type_ref(self : HalfType) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend HalfType with Type::{asTypeEnum}

///|
/// Classifies this wrapper as `FPTypeEnum::HalfType`.
pub impl FPType for HalfType with fn asFPTypeEnum(self) -> FPTypeEnum {
  FPTypeEnum::HalfType(self)
}

///|
/// Exposes floating-point classification on `HalfType`.
pub extend HalfType with FPType::{asFPTypeEnum}

///|
/// Classifies this wrapper as `PrimitiveTypeEnum::HalfType`.
pub impl PrimitiveType for HalfType with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  PrimitiveTypeEnum::HalfType(self)
}

///|
/// Exposes primitive-type classification on `HalfType`.
pub extend HalfType with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// BFloatType
// ====================================================================

///|
/// Context-owned wrapper for LLVM's 16-bit `bfloat` type.
///
/// **Lifecycle:** The wrapper borrows an interned type from its `Context` and
/// must not outlive that context.
pub struct BFloatType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn BFloatType::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> BFloatType {
  BFloatType::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn BFloatType::get_context(self : BFloatType) -> Context {
  self.value.get_context()
}

///|
/// Writes `bfloat` using LLVM's textual type syntax.
pub impl Show for BFloatType with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::BFloatType`.
pub impl Type for BFloatType with fn asTypeEnum(self) -> TypeEnum {
  BFloatType(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn BFloatType::get_raw_type_ref(self : BFloatType) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend BFloatType with Type::{asTypeEnum}

///|
/// Classifies this wrapper as `FPTypeEnum::BFloatType`.
pub impl FPType for BFloatType with fn asFPTypeEnum(self) -> FPTypeEnum {
  BFloatType(self)
}

///|
/// Exposes floating-point classification on `BFloatType`.
pub extend BFloatType with FPType::{asFPTypeEnum}

///|
/// Classifies this wrapper as `PrimitiveTypeEnum::BFloatType`.
pub impl PrimitiveType for BFloatType with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  BFloatType(self)
}

///|
/// Exposes primitive-type classification on `BFloatType`.
pub extend BFloatType with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// FloatType
// ====================================================================

///|
/// Context-owned wrapper for LLVM's 32-bit IEEE `float` type.
///
/// **Lifecycle:** The wrapper borrows an interned type from its `Context` and
/// must not outlive that context.
pub struct FloatType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn FloatType::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> FloatType {
  FloatType::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn FloatType::get_context(self : FloatType) -> Context {
  self.value.get_context()
}

///|
/// Writes `float` using LLVM's textual type syntax.
pub impl Show for FloatType with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::FloatType`.
pub impl Type for FloatType with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::FloatType(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn FloatType::get_raw_type_ref(self : FloatType) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend FloatType with Type::{asTypeEnum}

///|
/// Classifies this wrapper as `FPTypeEnum::FloatType`.
pub impl FPType for FloatType with fn asFPTypeEnum(self) -> FPTypeEnum {
  FloatType(self)
}

///|
/// Exposes floating-point classification on `FloatType`.
pub extend FloatType with FPType::{asFPTypeEnum}

///|
/// Classifies this wrapper as `PrimitiveTypeEnum::FloatType`.
pub impl PrimitiveType for FloatType with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  FloatType(self)
}

///|
/// Exposes primitive-type classification on `FloatType`.
pub extend FloatType with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// DoubleType
// ====================================================================

///|
/// Context-owned wrapper for LLVM's 64-bit IEEE `double` type.
///
/// **Lifecycle:** The wrapper borrows an interned type from its `Context` and
/// must not outlive that context.
pub struct DoubleType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn DoubleType::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> DoubleType {
  DoubleType::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn DoubleType::get_context(self : DoubleType) -> Context {
  self.value.get_context()
}

///| Create a DoubleType
//fn DoubleType::new(typeref : @raw.LLVMTypeRef) -> DoubleType {
//  DoubleType::{ typeref, }
//}

///|
/// Writes `double` using LLVM's textual type syntax.
pub impl Show for DoubleType with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::DoubleType`.
pub impl Type for DoubleType with fn asTypeEnum(self) -> TypeEnum {
  DoubleType(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn DoubleType::get_raw_type_ref(self : DoubleType) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend DoubleType with Type::{asTypeEnum}

///|
/// Classifies this wrapper as `FPTypeEnum::DoubleType`.
pub impl FPType for DoubleType with fn asFPTypeEnum(self) -> FPTypeEnum {
  DoubleType(self)
}

///|
/// Exposes floating-point classification on `DoubleType`.
pub extend DoubleType with FPType::{asFPTypeEnum}

///|
/// Classifies this wrapper as `PrimitiveTypeEnum::DoubleType`.
pub impl PrimitiveType for DoubleType with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  DoubleType(self)
}

///|
/// Exposes primitive-type classification on `DoubleType`.
pub extend DoubleType with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// FP128Type
// ====================================================================

///|
/// Context-owned wrapper for LLVM's 128-bit IEEE `fp128` type.
///
/// **Lifecycle:** The wrapper borrows an interned type from its `Context` and
/// must not outlive that context.
pub struct FP128Type {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn FP128Type::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> FP128Type {
  FP128Type::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn FP128Type::get_context(self : FP128Type) -> Context {
  self.value.get_context()
}
//pub struct FP128Type {
//  priv typeref : @raw.LLVMTypeRef
//} derive(Eq)

///| Create a FP128Ty.
//fn FP128Type::new(typeref : @raw.LLVMTypeRef) -> FP128Type {
//  FP128Type::{ typeref, }
//}

///|
/// Writes `fp128` using LLVM's textual type syntax.
pub impl Show for FP128Type with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::FP128Type`.
pub impl Type for FP128Type with fn asTypeEnum(self) -> TypeEnum {
  FP128Type(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn FP128Type::get_raw_type_ref(self : FP128Type) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend FP128Type with Type::{asTypeEnum}

///|
/// Classifies this wrapper as `FPTypeEnum::FP128Type`.
pub impl FPType for FP128Type with fn asFPTypeEnum(self) -> FPTypeEnum {
  FP128Type(self)
}

///|
/// Exposes floating-point classification on `FP128Type`.
pub extend FP128Type with FPType::{asFPTypeEnum}

///|
/// Classifies this wrapper as `PrimitiveTypeEnum::FP128Type`.
pub impl PrimitiveType for FP128Type with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  FP128Type(self)
}

///|
/// Exposes primitive-type classification on `FP128Type`.
pub extend FP128Type with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// Int1Type
// ====================================================================

///|
/// Context-owned wrapper for LLVM's one-bit integer type, conventionally used
/// for boolean values.
///
/// **Lifecycle:** The wrapper borrows an interned type from its `Context` and
/// must not outlive that context.
pub struct Int1Type {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn Int1Type::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> Int1Type {
  Int1Type::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn Int1Type::get_context(self : Int1Type) -> Context {
  self.value.get_context()
}

///|
/// Writes `i1` using LLVM's textual type syntax.
pub impl Show for Int1Type with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::Int1Type`.
pub impl Type for Int1Type with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::Int1Type(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn Int1Type::get_raw_type_ref(self : Int1Type) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend Int1Type with Type::{asTypeEnum}

///|
/// Classifies this wrapper as `IntegerTypeEnum::Int1Type`.
pub impl IntegerType for Int1Type with fn asIntegerTypeEnum(self) -> IntegerTypeEnum {
  Int1Type(self)
}

///|
/// Exposes integer-type classification on `Int1Type`.
pub extend Int1Type with IntegerType::{asIntegerTypeEnum}

///|
/// Classifies this wrapper as `PrimitiveTypeEnum::Int1Type`.
pub impl PrimitiveType for Int1Type with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  Int1Type(self)
}

///|
/// Exposes primitive-type classification on `Int1Type`.
pub extend Int1Type with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// Int8Type
// ====================================================================

///|
/// Context-owned wrapper for LLVM's eight-bit integer type.
///
/// **Lifecycle:** The wrapper borrows an interned type from its `Context` and
/// must not outlive that context.
pub struct Int8Type {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn Int8Type::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> Int8Type {
  Int8Type::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn Int8Type::get_context(self : Int8Type) -> Context {
  self.value.get_context()
}

///|
/// Writes `i8` using LLVM's textual type syntax.
pub impl Show for Int8Type with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::Int8Type`.
pub impl Type for Int8Type with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::Int8Type(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn Int8Type::get_raw_type_ref(self : Int8Type) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend Int8Type with Type::{asTypeEnum}

///|
/// Classifies this wrapper as `IntegerTypeEnum::Int8Type`.
pub impl IntegerType for Int8Type with fn asIntegerTypeEnum(self) -> IntegerTypeEnum {
  Int8Type(self)
}

///|
/// Exposes integer-type classification on `Int8Type`.
pub extend Int8Type with IntegerType::{asIntegerTypeEnum}

///|
/// Classifies this wrapper as `PrimitiveTypeEnum::Int8Type`.
pub impl PrimitiveType for Int8Type with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  Int8Type(self)
}

///|
/// Exposes primitive-type classification on `Int8Type`.
pub extend Int8Type with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// Int16Type
// ====================================================================

///|
/// Context-owned wrapper for LLVM's 16-bit integer type.
///
/// **Lifecycle:** The wrapper borrows an interned type from its `Context` and
/// must not outlive that context.
pub struct Int16Type {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn Int16Type::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> Int16Type {
  Int16Type::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn Int16Type::get_context(self : Int16Type) -> Context {
  self.value.get_context()
}

///|
/// Writes `i16` using LLVM's textual type syntax.
pub impl Show for Int16Type with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::Int16Type`.
pub impl Type for Int16Type with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::Int16Type(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn Int16Type::get_raw_type_ref(self : Int16Type) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend Int16Type with Type::{asTypeEnum}

///|
/// Classifies this wrapper as `IntegerTypeEnum::Int16Type`.
pub impl IntegerType for Int16Type with fn asIntegerTypeEnum(self) -> IntegerTypeEnum {
  Int16Type(self)
}

///|
/// Exposes integer-type classification on `Int16Type`.
pub extend Int16Type with IntegerType::{asIntegerTypeEnum}

///|
/// Classifies this wrapper as `PrimitiveTypeEnum::Int16Type`.
pub impl PrimitiveType for Int16Type with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  Int16Type(self)
}

///|
/// Exposes primitive-type classification on `Int16Type`.
pub extend Int16Type with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// Int32Type
// ====================================================================

///|
/// Context-owned wrapper for LLVM's 32-bit integer type.
///
/// **Lifecycle:** The wrapper borrows an interned type from its `Context` and
/// must not outlive that context.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let i32ty = ctx.getInt32Ty()
///   inspect(i32ty, content="i32")
///   inspect(i32ty.getBitWidth(), content="32")
///   guard! i32ty.asIntegerTypeEnum() is Int32Type(_)
/// }
/// ```
pub struct Int32Type {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn Int32Type::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> Int32Type {
  Int32Type::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn Int32Type::get_context(self : Int32Type) -> Context {
  self.value.get_context()
}

///|
/// Writes `i32` using LLVM's textual type syntax.
pub impl Show for Int32Type with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::Int32Type`.
pub impl Type for Int32Type with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::Int32Type(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn Int32Type::get_raw_type_ref(self : Int32Type) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend Int32Type with Type::{asTypeEnum}

///|
/// Classifies this wrapper as `IntegerTypeEnum::Int32Type`.
pub impl IntegerType for Int32Type with fn asIntegerTypeEnum(self) -> IntegerTypeEnum {
  Int32Type(self)
}

///|
/// Exposes integer-type classification on `Int32Type`.
pub extend Int32Type with IntegerType::{asIntegerTypeEnum}

///|
/// Classifies this wrapper as `PrimitiveTypeEnum::Int32Type`.
pub impl PrimitiveType for Int32Type with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  Int32Type(self)
}

///|
/// Exposes primitive-type classification on `Int32Type`.
pub extend Int32Type with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// Int64Type
// ====================================================================

///|
/// Context-owned wrapper for LLVM's 64-bit integer type.
///
/// **Lifecycle:** The wrapper borrows an interned type from its `Context` and
/// must not outlive that context.
pub struct Int64Type {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn Int64Type::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> Int64Type {
  Int64Type::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn Int64Type::get_context(self : Int64Type) -> Context {
  self.value.get_context()
}

///|
/// Writes `i64` using LLVM's textual type syntax.
pub impl Show for Int64Type with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::Int64Type`.
pub impl Type for Int64Type with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::Int64Type(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn Int64Type::get_raw_type_ref(self : Int64Type) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend Int64Type with Type::{asTypeEnum}

///|
/// Classifies this wrapper as `IntegerTypeEnum::Int64Type`.
pub impl IntegerType for Int64Type with fn asIntegerTypeEnum(self) -> IntegerTypeEnum {
  Int64Type(self)
}

///|
/// Exposes integer-type classification on `Int64Type`.
pub extend Int64Type with IntegerType::{asIntegerTypeEnum}

///|
/// Classifies this wrapper as `PrimitiveTypeEnum::Int64Type`.
pub impl PrimitiveType for Int64Type with fn asPrimitiveTypeEnum(self) -> PrimitiveTypeEnum {
  Int64Type(self)
}

///|
/// Exposes primitive-type classification on `Int64Type`.
pub extend Int64Type with PrimitiveType::{asPrimitiveTypeEnum}

// ====================================================================
// VoidType
// ====================================================================

///|
/// Context-owned wrapper for LLVM's `void` type.
///
/// `void` is valid as a function return type but is not a first-class value
/// type and is not sized.
///
/// **Lifecycle:** The wrapper must not outlive its owning context.
pub struct VoidType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn VoidType::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> VoidType {
  VoidType::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn VoidType::get_context(self : VoidType) -> Context {
  self.value.get_context()
}

///|
/// Writes `void` using LLVM's textual type syntax.
pub impl Show for VoidType with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn VoidType::get_raw_type_ref(self : VoidType) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Classifies this wrapper as `TypeEnum::VoidType`.
pub impl Type for VoidType with fn asTypeEnum(self) -> TypeEnum {
  VoidType(self)
}

///|
/// Exposes common type classification on this concrete type.
pub extend VoidType with Type::{asTypeEnum}

///|
/// Classifies this wrapper as `AbstractTypeEnum::VoidType`.
pub impl AbstractType for VoidType with fn asAbstractTypeEnum(self) -> AbstractTypeEnum {
  VoidType(self)
}

///|
/// Exposes abstract-type classification on `VoidType`.
pub extend VoidType with AbstractType::{asAbstractTypeEnum}

// ====================================================================
// LabelType
// ====================================================================

///|
/// Context-owned wrapper for LLVM's basic-block `label` type.
///
/// **Lifecycle:** The wrapper must not outlive its owning context.
pub struct LabelType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn LabelType::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> LabelType {
  LabelType::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn LabelType::get_context(self : LabelType) -> Context {
  self.value.get_context()
}

///|
/// Writes `label` using LLVM's textual type syntax.
pub impl Show for LabelType with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::LabelType`.
pub impl Type for LabelType with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::LabelType(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn LabelType::get_raw_type_ref(self : LabelType) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend LabelType with Type::{asTypeEnum}

///|
/// Classifies this wrapper as `AbstractTypeEnum::LabelType`.
pub impl AbstractType for LabelType with fn asAbstractTypeEnum(self) -> AbstractTypeEnum {
  LabelType(self)
}

///|
/// Exposes abstract-type classification on `LabelType`.
pub extend LabelType with AbstractType::{asAbstractTypeEnum}

// ====================================================================
// MetadataType
// ====================================================================

///|
/// Context-owned wrapper for LLVM's special `metadata` type.
///
/// This is the type of metadata values accepted by metadata-specific LLVM
/// operations; it is not an ordinary data value type.
///
/// **Lifecycle:** The wrapper must not outlive its owning context.
pub struct MetadataType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn MetadataType::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> MetadataType {
  MetadataType::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn MetadataType::get_context(self : MetadataType) -> Context {
  self.value.get_context()
}

///|
/// Writes `metadata` using LLVM's textual type syntax.
pub impl Show for MetadataType with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::MetadataType`.
pub impl Type for MetadataType with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::MetadataType(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn MetadataType::get_raw_type_ref(self : MetadataType) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend MetadataType with Type::{asTypeEnum}

///|
/// Classifies this wrapper as `AbstractTypeEnum::MetadataType`.
pub impl AbstractType for MetadataType with fn asAbstractTypeEnum(self) -> AbstractTypeEnum {
  MetadataType(self)
}

///|
/// Exposes abstract-type classification on `MetadataType`.
pub extend MetadataType with AbstractType::{asAbstractTypeEnum}

// ====================================================================
// TokenTy
// ====================================================================

///|
/// Context-owned wrapper for LLVM's special `token` type.
///
/// Tokens model ordering or dependency values for selected LLVM intrinsics and
/// are not ordinary loadable data.
///
/// **Lifecycle:** The wrapper must not outlive its owning context.
pub struct TokenType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn TokenType::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> TokenType {
  TokenType::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn TokenType::get_context(self : TokenType) -> Context {
  self.value.get_context()
}

///|
/// Writes `token` using LLVM's textual type syntax.
pub impl Show for TokenType with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::TokenType`.
pub impl Type for TokenType with fn asTypeEnum(self) -> TypeEnum {
  TokenType(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn TokenType::get_raw_type_ref(self : TokenType) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend TokenType with Type::{asTypeEnum}

///|
/// Classifies this wrapper as `AbstractTypeEnum::TokenType`.
pub impl AbstractType for TokenType with fn asAbstractTypeEnum(self) -> AbstractTypeEnum {
  TokenType(self)
}

///|
/// Exposes abstract-type classification on `TokenType`.
pub extend TokenType with AbstractType::{asAbstractTypeEnum}

// ====================================================================
// FunctionType
// ====================================================================

///|
/// Context-owned wrapper for an LLVM function signature.
///
/// A function type records a return type, its fixed parameter types, and
/// whether additional variadic arguments are accepted. It is a type, not a
/// function value.
///
/// **Lifecycle:** The wrapper and all type views returned from it must not
/// outlive the context that created the signature.
pub struct FunctionType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn FunctionType::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> FunctionType {
  FunctionType::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn FunctionType::get_context(self : FunctionType) -> Context {
  self.value.get_context()
}

///|
/// Returns whether calls using this signature may supply variadic arguments
/// after the fixed parameters.
pub fn FunctionType::isVarArg(self : FunctionType) -> Bool {
  @raw.llvm_is_function_var_arg((self : &Type).get_raw_type_ref())
}

///|
/// Returns the function signature's result type.
///
/// **Lifecycle:** The returned view is owned by the same context as this
/// function type.
pub fn FunctionType::getReturnType(self : FunctionType) -> &Type {
  let typeref = @raw.llvm_get_return_type((self : &Type).get_raw_type_ref())
  initAbstractType(typeref, self.get_context())
}

///|
/// Returns the number of fixed parameters in this signature.
///
/// **Notes:** This is an alias of `getNumParams`; variadic arguments are not
/// included.
pub fn FunctionType::numOfParams(self : FunctionType) -> Int {
  @raw.llvm_count_param_types((self : &Type).get_raw_type_ref()).reinterpret_as_int()
}

///|
/// Returns the fixed parameter types in source order.
///
/// **Lifecycle:** Array elements are context-owned borrowed type views.
///
/// **Notes:** This is an alias of `getParamTypes`.
pub fn FunctionType::params(self : FunctionType) -> Array[&Type] {
  let param_types = @raw.llvm_get_param_types((self : &Type).get_raw_type_ref())
  param_types.map(typeref => initAbstractType(typeref, self.get_context()))
}

///|
/// Returns the fixed parameter types in source order.
///
/// **Lifecycle:** Array elements are context-owned borrowed type views.
///
/// **Notes:** This is an alias of `params`.
pub fn FunctionType::getParamTypes(self : FunctionType) -> Array[&Type] {
  let param_types = @raw.llvm_get_param_types((self : &Type).get_raw_type_ref())
  param_types.map(typeref => initAbstractType(typeref, self.get_context()))
}

///|
/// Returns the number of fixed parameters in this signature.
///
/// **Notes:** Variadic arguments are not included. This is an alias of
/// `numOfParams`.
pub fn FunctionType::getNumParams(self : FunctionType) -> Int {
  @raw.llvm_count_param_types((self : &Type).get_raw_type_ref()).reinterpret_as_int()
}

///|
/// Returns the fixed parameter type at a zero-based index.
///
/// **Parameters:**
///
/// - `idx`: Zero-based position among fixed parameters.
///
/// **Returns:** `None` for a negative or out-of-range index, or if the raw LLVM
/// type cannot be represented by this package's safe type hierarchy.
///
/// **Lifecycle:** A returned type is owned by the same context as this function
/// type.
pub fn FunctionType::getParamType(self : FunctionType, idx : Int) -> &Type? {
  let param_types = @raw.llvm_get_param_types((self : &Type).get_raw_type_ref())
  guard idx >= 0 && idx < param_types.length() else { return None }
  let typeref = param_types[idx]
  try initAbstractType_err(typeref, self.get_context()) catch {
    _ => None
  } noraise {
    ty => Some(ty)
  }
}

///|
/// Writes the LLVM textual function-signature syntax.
pub impl Show for FunctionType with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::FunctionType`.
pub impl Type for FunctionType with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::FunctionType(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn FunctionType::get_raw_type_ref(self : FunctionType) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend FunctionType with Type::{asTypeEnum}

///|
/// Classifies this wrapper as `AbstractTypeEnum::FunctionType`.
pub impl AbstractType for FunctionType with fn asAbstractTypeEnum(self) -> AbstractTypeEnum {
  AbstractTypeEnum::FunctionType(self)
}

///|
/// Exposes abstract-type classification on `FunctionType`.
pub extend FunctionType with AbstractType::{asAbstractTypeEnum}

// ====================================================================
// StructType
// ====================================================================

///|
/// Context-owned wrapper for an LLVM struct type.
///
/// A struct may be literal (unnamed with a complete body), identified with a
/// complete body, or identified and opaque until `setBody` is called. A
/// complete zero-field body is an empty struct and is distinct from opaque.
/// Packed structs omit ABI padding between their fields.
///
/// **Lifecycle:** The wrapper and all element views returned from it must not
/// outlive the context that owns the struct type.
pub struct StructType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn StructType::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> StructType {
  StructType::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn StructType::get_context(self : StructType) -> Context {
  self.value.get_context()
}

///|
/// Returns whether the struct is unnamed and identified structurally by its
/// body.
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
  @raw.llvm_is_literal_struct((self : &Type).get_raw_type_ref())
}

///|
/// Returns whether this is an identified struct whose body has not been set.
///
/// An opaque struct prints with an `opaque` body. It becomes non-opaque after
/// one successful call to `setBody`, including when that body has zero fields.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let i32ty = ctx.getInt32Ty()
///   let node = ctx.getOpaqueStructType("Node")
///   assert_true(node.isOpaque())
///   inspect(node, content="%Node = type opaque")
///   node.setBody([i32ty])
///   assert_false(node.isOpaque())
///   inspect(node, content="%Node = type { i32 }")
/// }
/// ```
pub fn StructType::isOpaque(self : StructType) -> Bool {
  @raw.llvm_is_opaque_struct((self : &Type).get_raw_type_ref())
}

///|
/// Returns whether the struct body is packed without ABI padding between
/// fields.
pub fn StructType::isPacked(self : StructType) -> Bool {
  @raw.llvm_is_packed_struct((self : &Type).get_raw_type_ref())
}

///|
/// Returns whether LLVM can form a size expression for this struct.
///
/// Opaque structs and structs containing unsized elements are not sized.
pub fn StructType::isSized(self : StructType) -> Bool {
  @raw.llvm_type_is_sized((self : &Type).get_raw_type_ref())
}

///|
/// Returns the number of fields in the current body.
///
/// **Notes:** Use `isOpaque` to distinguish an absent body from a complete
/// zero-field body.
pub fn StructType::numOfElements(self : StructType) -> Int {
  @raw.llvm_count_struct_element_types((self : &Type).get_raw_type_ref()).reinterpret_as_int()
}

///|
/// Returns a field type by zero-based index.
///
/// **Returns:** `None` for a negative or out-of-range index, or if the raw field
/// type cannot be represented by the safe type hierarchy.
///
/// **Lifecycle:** A returned type is owned by the same context as this struct.
pub fn StructType::getElementType(self : StructType, idx : Int) -> &Type? {
  guard idx >= 0 && idx < self.numOfElements() else { return None }
  let typeref = @raw.llvm_struct_get_type_at_index(
    (self : &Type).get_raw_type_ref(),
    idx.reinterpret_as_uint(),
  )
  try initAbstractType_err(typeref, self.get_context()) catch {
    _ => None
  } noraise {
    ty => Some(ty)
  }
}

///|
/// Returns all field types in layout order.
///
/// **Lifecycle:** Array elements are context-owned borrowed type views.
///
/// **Notes:** Use `isOpaque` before relying on this array to distinguish an
/// opaque struct from a complete zero-field struct.
pub fn StructType::elements(self : StructType) -> Array[&Type] {
  let elements : Array[&Type] = []
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
/// Error raised when attempting to replace a struct body that is already
/// complete.
pub suberror SetBodyForNonOpaqueStruct {
  /// Contains a diagnostic explaining that only opaque structs accept a body.
  SetBodyForNonOpaqueStruct(String)
}

///|
/// Completes an opaque identified struct with a field body.
///
/// **Parameters:**
///
/// - `elements`: Field types in layout order; an empty array creates a complete
///   empty struct.
/// - `isPacked`: Whether LLVM may omit ABI padding between fields.
///
/// **Preconditions:** Every element type must belong to the same context as
/// this struct and must be valid as an LLVM struct element.
///
/// **Errors:** Raises `SetBodyForNonOpaqueStruct` unless `isOpaque` is `true`.
///
/// **Side Effects:** Mutates the identified LLVM type in place. All existing
/// wrappers and uses of this named type observe the completed body.
///
/// **Lifecycle:** The struct remains owned by its context. A successful call
/// does not create a separately owned type.
pub fn StructType::setBody(
  self : StructType,
  elements : Array[&Type],
  isPacked? : Bool = false,
) -> Unit raise {
  // only opaque struct can be set body.
  guard self.isOpaque() else {
    raise SetBodyForNonOpaqueStruct("Cannot set body for non-opaque struct")
  }
  let field_types = elements.map(t => t.get_raw_type_ref())
  @raw.llvm_struct_set_body(
    (self : &Type).get_raw_type_ref(),
    field_types,
    isPacked,
  )
}

///|
/// Writes the struct declaration or literal body using LLVM syntax.
pub impl Show for StructType with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::StructType`.
pub impl Type for StructType with fn asTypeEnum(self) -> TypeEnum {
  StructType(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn StructType::get_raw_type_ref(self : StructType) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend StructType with Type::{asTypeEnum}

///|
/// Classifies this wrapper as `AggregateTypeEnum::StructType`.
pub impl AggregateType for StructType with fn asAggregateTypeEnum(self) -> AggregateTypeEnum {
  StructType(self)
}

///|
/// Exposes aggregate-type classification on `StructType`.
pub extend StructType with AggregateType::{asAggregateTypeEnum}

// ====================================================================
// ArrayType
// ====================================================================

///|
/// Context-owned wrapper for a fixed-length LLVM array type.
///
/// Arrays are aggregates containing one repeated element type and a fixed
/// element count, including zero.
///
/// **Lifecycle:** The wrapper and its element-type view must not outlive the
/// owning context.
pub struct ArrayType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn ArrayType::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> ArrayType {
  ArrayType::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn ArrayType::get_context(self : ArrayType) -> Context {
  self.value.get_context()
}

///|
/// Returns the fixed number of array elements.
pub fn ArrayType::getElementCount(self : ArrayType) -> Int {
  @raw.llvm_get_array_length((self : &Type).get_raw_type_ref()).reinterpret_as_int()
}

///|
/// Returns the repeated array element type.
///
/// **Lifecycle:** The returned view is owned by the same context as this array.
pub fn ArrayType::getElementType(self : ArrayType) -> &Type {
  let typeref = @raw.llvm_get_element_type((self : &Type).get_raw_type_ref())
  initAbstractType(typeref, self.get_context())
}

///|
/// Writes the array using LLVM textual type syntax.
pub impl Show for ArrayType with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::ArrayType`.
pub impl Type for ArrayType with fn asTypeEnum(self) -> TypeEnum {
  ArrayType(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn ArrayType::get_raw_type_ref(self : ArrayType) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend ArrayType with Type::{asTypeEnum}

///|
/// Classifies this wrapper as `AggregateTypeEnum::ArrayType`.
pub impl AggregateType for ArrayType with fn asAggregateTypeEnum(self) -> AggregateTypeEnum {
  ArrayType(self)
}

///|
/// Exposes aggregate-type classification on `ArrayType`.
pub extend ArrayType with AggregateType::{asAggregateTypeEnum}

// ====================================================================
// VectorType
// ====================================================================

///|
/// Context-owned wrapper for a fixed-width LLVM vector type.
///
/// Its element count is the exact number of lanes represented at runtime.
///
/// **Lifecycle:** The wrapper and its element-type view must not outlive the
/// owning context.
pub struct VectorType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn VectorType::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> VectorType {
  VectorType::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn VectorType::get_context(self : VectorType) -> Context {
  self.value.get_context()
}

///|
/// Returns the type shared by every vector lane.
///
/// **Lifecycle:** The returned view is owned by the same context as this
/// vector.
pub fn VectorType::getElementType(self : VectorType) -> &Type {
  let typeref = @raw.llvm_get_element_type((self : &Type).get_raw_type_ref())
  initAbstractType(typeref, self.get_context())
}

///|
/// Returns the vector's exact runtime lane count.
pub fn VectorType::getElementCount(self : VectorType) -> Int {
  @raw.llvm_get_vector_size((self : &Type).get_raw_type_ref()).reinterpret_as_int()
}

///|
/// Writes the fixed-width vector using LLVM textual type syntax.
pub impl Show for VectorType with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::VectorType`.
pub impl Type for VectorType with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::VectorType(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn VectorType::get_raw_type_ref(self : VectorType) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend VectorType with Type::{asTypeEnum}

// ====================================================================
// ScalableVectorType
// ====================================================================

///|
/// Context-owned wrapper for a scalable LLVM vector type.
///
/// Its element count is the known minimum lane count. The actual runtime lane
/// count is `vscale` multiplied by this value and is target-dependent.
///
/// **Lifecycle:** The wrapper and its element-type view must not outlive the
/// owning context.
pub struct ScalableVectorType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn ScalableVectorType::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> ScalableVectorType {
  ScalableVectorType::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn ScalableVectorType::get_context(self : ScalableVectorType) -> Context {
  self.value.get_context()
}

///|
/// Returns the type shared by every vector lane.
///
/// **Lifecycle:** The returned view is owned by the same context as this
/// vector.
pub fn ScalableVectorType::getElementType(self : ScalableVectorType) -> &Type {
  let typeref = @raw.llvm_get_element_type((self : &Type).get_raw_type_ref())
  initAbstractType(typeref, self.get_context())
}

///|
/// Returns the known minimum lane count.
///
/// **Notes:** Unlike `VectorType::getElementCount`, this is not necessarily the
/// exact runtime lane count. The actual count is this value multiplied by
/// target-dependent `vscale`.
pub fn ScalableVectorType::getElementCount(self : ScalableVectorType) -> Int {
  @raw.llvm_get_vector_size((self : &Type).get_raw_type_ref()).reinterpret_as_int()
}

///|
/// Writes the scalable vector using LLVM textual type syntax.
pub impl Show for ScalableVectorType with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::ScalableVectorType`.
pub impl Type for ScalableVectorType with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::ScalableVectorType(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn ScalableVectorType::get_raw_type_ref(
  self : ScalableVectorType,
) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend ScalableVectorType with Type::{asTypeEnum}

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
/// Context-owned wrapper for an LLVM 19 opaque pointer type.
///
/// The pointer records only its address space; it does not carry a pointee type.
/// Address-space zero is the target's default generic address space.
///
/// **Lifecycle:** The wrapper borrows an interned type from its `Context` and
/// must not outlive that context.
pub struct PointerType {
  priv value : ContextAnchoredType
} derive(Eq)

///|
fn PointerType::from_raw(
  type_ref : @raw.LLVMTypeRef,
  context : Context,
) -> PointerType {
  PointerType::{ value: ContextAnchoredType::new(type_ref, context), }
}

///|
fn PointerType::get_context(self : PointerType) -> Context {
  self.value.get_context()
}

///|
/// Returns the pointer's target-defined address-space identifier.
pub fn PointerType::getAddressSpace(self : PointerType) -> AddressSpace {
  let addr_space = @raw.llvm_get_pointer_address_space(
    (self : &Type).get_raw_type_ref(),
  )
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
/// Returns whether `eleTy` may represent memory loaded from or stored through a
/// pointer.
///
/// Function, void, label, metadata, and token types are rejected. This
/// predicate checks type category only; it does not validate a particular
/// instruction, target, alignment, or address space.
pub fn PointerType::isLoadableOrStorableType(eleTy : &Type) -> Bool {
  match eleTy.asTypeEnum() {
    FunctionType(_) => false
    _ => PointerType::isValidElementType(eleTy)
  }
}

///|
/// Writes the opaque pointer and any nonzero address space using LLVM syntax.
pub impl Show for PointerType with fn output(self, logger : &Logger) {
  (self : &Type).get_raw_type_ref().output(logger)
}

///|
/// Classifies this wrapper as `TypeEnum::PointerType`.
pub impl Type for PointerType with fn asTypeEnum(self) -> TypeEnum {
  TypeEnum::PointerType(self)
}

///|
/// Returns the internal borrowed LLVM type handle.
fn PointerType::get_raw_type_ref(self : PointerType) -> @raw.LLVMTypeRef {
  self.value.get_raw_ref()
}

///|
/// Exposes common type classification on this concrete type.
pub extend PointerType with Type::{asTypeEnum}
