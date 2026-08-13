// ==================================================
// ConstantInt
// ==================================================

///|
/// Context-owned arbitrary-bit-pattern integer constant.
///
/// The safe API currently constructs the supported `i1`, `i8`, `i16`, `i32`,
/// and `i64` widths. Signedness is not part of an LLVM integer type; it is
/// selected by the accessor used to interpret the stored bits.
///
/// **Lifecycle:** The constant is uniqued and owned by its `Context`, not by a
/// module, and must not outlive that context.
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let value = ctx.getConstInt8(-1)
///   inspect(value.getValueAsInt64(), content="-1")
///   inspect(value.getValueAsUInt64(), content="255")
///   guard! value.asValueEnum() is ConstantInt(_)
///   guard! value.asConstantEnum() is ConstantInt(_)
/// }
/// ```
pub struct ConstantInt {
  priv value : ContextAnchoredValue
}

///|
fn ConstantInt::from_raw(
  value_ref : ValueRef,
  context : Context,
) -> ConstantInt {
  ConstantInt::{ value: ContextAnchoredValue::new(value_ref, context) }
}

///|
/// Interprets the stored bits as a sign-extended host `Int`.
///
/// **Notes:** Conversion from LLVM's 64-bit result to `Int` follows MoonBit's
/// host integer conversion semantics. Prefer `getValueAsInt64` when the exact
/// 64-bit result matters.
pub fn ConstantInt::to_int(self : Self) -> Int {
  let val = @raw.llvm_const_int_get_s_ext_value(self.get_raw_value_ref())
  val.to_int()
}

///|
/// Returns the stored integer after sign extension to `Int64`.
pub fn ConstantInt::getValueAsInt64(self : Self) -> Int64 {
  let val = @raw.llvm_const_int_get_s_ext_value(self.get_raw_value_ref())
  val
}

///|
/// Returns the stored integer after zero extension to `UInt64`.
///
/// **Notes:** LLVM integers have no intrinsic signedness. For example, an `i8`
/// bit pattern of all ones is `255` through this accessor and `-1` through
/// `getValueAsInt64`.
pub fn ConstantInt::getValueAsUInt64(self : Self) -> UInt64 {
  let val = @raw.llvm_const_int_get_z_ext_value(self.get_raw_value_ref())
  val
}

///|
/// Interprets the stored bits as a zero-extended host `UInt`.
///
/// **Notes:** Prefer `getValueAsUInt64` when the exact 64-bit result matters.
pub fn ConstantInt::to_uint(self : Self) -> UInt {
  let val = @raw.llvm_const_int_get_z_ext_value(self.get_raw_value_ref())
  val.to_uint()
}

///|
/// Returns the internal borrowed LLVM value handle.
fn ConstantInt::get_raw_value_ref(self : ConstantInt) -> ValueRef {
  self.value.get_raw_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::ConstantInt`.
pub impl Value for ConstantInt with fn asValueEnum(self) {
  ConstantInt(self)
}

///|
/// Returns the context that owns this constant.
pub impl Value for ConstantInt with fn getContext(self) {
  self.value.get_context()
}

///|
/// Classifies this wrapper as `ConstantEnum::ConstantInt`.
pub impl Constant for ConstantInt with fn asConstantEnum(self) {
  ConstantInt(self)
}

///|
/// Writes the typed integer constant using LLVM syntax.
pub impl Show for ConstantInt with fn output(self, logger) {
  self.get_raw_value_ref().output(logger)
}

// ==================================================
// ConstantFP
// ==================================================

///|
/// Context-owned LLVM floating-point constant.
///
/// Its precise semantics and printed form follow the constant's LLVM floating
/// type rather than MoonBit host formatting.
///
/// **Lifecycle:** The constant is owned by its `Context`, not by a module.
pub struct ConstantFP {
  priv value : ContextAnchoredValue
}

///|
fn ConstantFP::from_raw(value_ref : ValueRef, context : Context) -> ConstantFP {
  ConstantFP::{ value: ContextAnchoredValue::new(value_ref, context) }
}

///|
/// Returns the internal borrowed LLVM value handle.
fn ConstantFP::get_raw_value_ref(self : ConstantFP) -> ValueRef {
  self.value.get_raw_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::ConstantFP`.
pub impl Value for ConstantFP with fn asValueEnum(self) {
  ConstantFP(self)
}

///|
/// Returns the context that owns this constant.
pub impl Value for ConstantFP with fn getContext(self) {
  self.value.get_context()
}

///|
/// Classifies this wrapper as `ConstantEnum::ConstantFP`.
pub impl Constant for ConstantFP with fn asConstantEnum(self) {
  ConstantFP(self)
}

///|
/// Writes the typed floating-point constant using LLVM syntax.
pub impl Show for ConstantFP with fn output(self, logger) {
  self.get_raw_value_ref().output(logger)
}

// ==================================================
// ConstantPointerNull
// ==================================================

///|
/// Context-owned null constant for an opaque LLVM pointer type.
///
/// The pointer type, including its address space, is preserved by the constant.
///
/// **Lifecycle:** The constant is owned by its `Context`, not by a module.
pub struct ConstantPointerNull {
  priv value : ContextAnchoredValue
}

///|
fn ConstantPointerNull::from_raw(
  value_ref : ValueRef,
  context : Context,
) -> ConstantPointerNull {
  ConstantPointerNull::{ value: ContextAnchoredValue::new(value_ref, context) }
}

///|
/// Returns the internal borrowed LLVM value handle.
fn ConstantPointerNull::get_raw_value_ref(
  self : ConstantPointerNull,
) -> ValueRef {
  self.value.get_raw_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::ConstantPointerNull`.
pub impl Value for ConstantPointerNull with fn asValueEnum(self) {
  ConstantPointerNull(self)
}

///|
/// Returns the context that owns this constant.
pub impl Value for ConstantPointerNull with fn getContext(self) {
  self.value.get_context()
}

///|
/// Classifies this wrapper as `ConstantEnum::ConstantPointerNull`.
pub impl Constant for ConstantPointerNull with fn asConstantEnum(self) {
  ConstantPointerNull(self)
}

///|
/// Writes the typed null pointer using LLVM syntax.
pub impl Show for ConstantPointerNull with fn output(self, logger) {
  self.get_raw_value_ref().output(logger)
}

// ==================================================
// ConstantArray
// ==================================================

///|
/// Context-owned LLVM array aggregate constant.
///
/// Every element has the array element type and belongs to the same context.
///
/// **Lifecycle:** The constant is owned by its `Context`, not by a module.
pub struct ConstantArray {
  priv value : ContextAnchoredValue
}

///|
fn ConstantArray::from_raw(
  value_ref : ValueRef,
  context : Context,
) -> ConstantArray {
  ConstantArray::{ value: ContextAnchoredValue::new(value_ref, context) }
}

///|
/// Returns the internal borrowed LLVM value handle.
fn ConstantArray::get_raw_value_ref(self : ConstantArray) -> ValueRef {
  self.value.get_raw_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::ConstantArray`.
pub impl Value for ConstantArray with fn asValueEnum(self) {
  ConstantArray(self)
}

///|
/// Returns the context that owns this constant.
pub impl Value for ConstantArray with fn getContext(self) {
  self.value.get_context()
}

///|
/// Classifies this wrapper as `ConstantEnum::ConstantArray`.
pub impl Constant for ConstantArray with fn asConstantEnum(self) {
  ConstantArray(self)
}

///|
/// Writes the typed array constant using LLVM syntax.
pub impl Show for ConstantArray with fn output(self, logger) {
  self.get_raw_value_ref().output(logger)
}

// ==================================================
// ConstantStruct
// ==================================================

///|
/// Context-owned LLVM struct aggregate constant.
///
/// The constant may use an explicitly supplied struct type or the literal type
/// inferred by its context factory.
///
/// **Lifecycle:** The constant is owned by its `Context`, not by a module.
pub struct ConstantStruct {
  priv value : ContextAnchoredValue
}

///|
fn ConstantStruct::from_raw(
  value_ref : ValueRef,
  context : Context,
) -> ConstantStruct {
  ConstantStruct::{ value: ContextAnchoredValue::new(value_ref, context) }
}

///|
/// Returns the internal borrowed LLVM value handle.
fn ConstantStruct::get_raw_value_ref(self : ConstantStruct) -> ValueRef {
  self.value.get_raw_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::ConstantStruct`.
pub impl Value for ConstantStruct with fn asValueEnum(self) {
  ConstantStruct(self)
}

///|
/// Returns the context that owns this constant.
pub impl Value for ConstantStruct with fn getContext(self) {
  self.value.get_context()
}

///|
/// Classifies this wrapper as `ConstantEnum::ConstantStruct`.
pub impl Constant for ConstantStruct with fn asConstantEnum(self) {
  ConstantStruct(self)
}

///|
/// Writes the typed struct constant using LLVM syntax.
pub impl Show for ConstantStruct with fn output(self, logger) {
  self.get_raw_value_ref().output(logger)
}

// ==================================================
// ConstantVector
// ==================================================

///|
/// Context-owned LLVM vector constant.
///
/// Its elements must share one type and context; the lane count is determined
/// by the number of elements passed to the context factory.
///
/// **Lifecycle:** The constant is owned by its `Context`, not by a module.
pub struct ConstantVector {
  priv value : ContextAnchoredValue
}

///|
fn ConstantVector::from_raw(
  value_ref : ValueRef,
  context : Context,
) -> ConstantVector {
  ConstantVector::{ value: ContextAnchoredValue::new(value_ref, context) }
}

///|
/// Returns the internal borrowed LLVM value handle.
fn ConstantVector::get_raw_value_ref(self : ConstantVector) -> ValueRef {
  self.value.get_raw_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::ConstantVector`.
pub impl Value for ConstantVector with fn asValueEnum(self) {
  ConstantVector(self)
}

///|
/// Returns the context that owns this constant.
pub impl Value for ConstantVector with fn getContext(self) {
  self.value.get_context()
}

///|
/// Classifies this wrapper as `ConstantEnum::ConstantVector`.
pub impl Constant for ConstantVector with fn asConstantEnum(self) {
  ConstantVector(self)
}

///|
/// Writes the typed vector constant using LLVM syntax.
pub impl Show for ConstantVector with fn output(self, logger) {
  self.get_raw_value_ref().output(logger)
}

// ==================================================
// UndefValue
// ==================================================

///|
/// Context-owned LLVM `undef` constant of a selected type.
///
/// Each use may observe an arbitrary value of that type. `undef` is distinct
/// from poison and should not be treated as a stable unknown value.
///
/// **Lifecycle:** The constant is owned by its `Context`, not by a module.
pub struct UndefValue {
  priv value : ContextAnchoredValue
}

///|
fn UndefValue::from_raw(value_ref : ValueRef, context : Context) -> UndefValue {
  UndefValue::{ value: ContextAnchoredValue::new(value_ref, context) }
}

///|
/// Returns the internal borrowed LLVM value handle.
fn UndefValue::get_raw_value_ref(self : UndefValue) -> ValueRef {
  self.value.get_raw_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::UndefValue`.
pub impl Value for UndefValue with fn asValueEnum(self) {
  UndefValue(self)
}

///|
/// Returns the context that owns this constant.
pub impl Value for UndefValue with fn getContext(self) {
  self.value.get_context()
}

///|
/// Classifies this wrapper as `ConstantEnum::UndefValue`.
pub impl Constant for UndefValue with fn asConstantEnum(self) {
  UndefValue(self)
}

///|
/// Writes the typed `undef` constant using LLVM syntax.
pub impl Show for UndefValue with fn output(self, logger) {
  self.get_raw_value_ref().output(logger)
}

// ==================================================
// PoisonValue
// ==================================================

///|
/// Context-owned LLVM `poison` constant of a selected type.
///
/// Poison propagates through most operations and can make later observable
/// behavior undefined. It is semantically stronger than `undef`.
///
/// **Lifecycle:** The constant is owned by its `Context`, not by a module.
pub struct PoisonValue {
  priv value : ContextAnchoredValue
}

///|
fn PoisonValue::from_raw(
  value_ref : ValueRef,
  context : Context,
) -> PoisonValue {
  PoisonValue::{ value: ContextAnchoredValue::new(value_ref, context) }
}

///|
/// Classifies this wrapper as `ConstantEnum::PoisonValue`.
pub impl Constant for PoisonValue with fn asConstantEnum(self) {
  PoisonValue(self)
}

///|
/// Returns the internal borrowed LLVM value handle.
fn PoisonValue::get_raw_value_ref(self : PoisonValue) -> ValueRef {
  self.value.get_raw_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::PoisonValue`.
pub impl Value for PoisonValue with fn asValueEnum(self) {
  PoisonValue(self)
}

///|
/// Returns the context that owns this constant.
pub impl Value for PoisonValue with fn getContext(self) {
  self.value.get_context()
}

///|
/// Writes the typed `poison` constant using LLVM syntax.
pub impl Show for PoisonValue with fn output(self, logger) {
  self.get_raw_value_ref().output(logger)
}

// ==================================================
// ConstantExpr
// ==================================================

///|
/// Context-owned LLVM constant expression.
///
/// Constant expressions are immutable computations accepted where LLVM permits
/// a constant operand. `Type::sizeOf` is one source of this wrapper.
///
/// **Lifecycle:** The expression is owned by its `Context`, not by a module.
pub struct ConstantExpr {
  priv value : ContextAnchoredValue
}

///|
fn ConstantExpr::from_raw(
  value_ref : ValueRef,
  context : Context,
) -> ConstantExpr {
  ConstantExpr::{ value: ContextAnchoredValue::new(value_ref, context) }
}

///|
/// Returns the internal borrowed LLVM value handle.
fn ConstantExpr::get_raw_value_ref(self : ConstantExpr) -> ValueRef {
  self.value.get_raw_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::ConstantExpr`.
pub impl Value for ConstantExpr with fn asValueEnum(self) {
  ConstantExpr(self)
}

///|
/// Returns the context that owns this constant expression.
pub impl Value for ConstantExpr with fn getContext(self) {
  self.value.get_context()
}

///|
/// Classifies this wrapper as `ConstantEnum::ConstantExpr`.
pub impl Constant for ConstantExpr with fn asConstantEnum(self) {
  ConstantExpr(self)
}

///|
/// Writes the typed constant expression using LLVM syntax.
pub impl Show for ConstantExpr with fn output(self, logger) {
  self.get_raw_value_ref().output(logger)
}
