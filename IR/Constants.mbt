// ==================================================
// ConstantInt
// ==================================================

///|
pub struct ConstantInt {
  priv value : ContextOwnedValue
}

///|
fn ConstantInt::from_raw(
  value_ref : ValueRef,
  context : Context,
) -> ConstantInt {
  ConstantInt::{ value: ContextOwnedValue::new(value_ref, context) }
}

///|
pub fn ConstantInt::to_int(self : Self) -> Int {
  let val = @unsafe.llvm_const_int_get_s_ext_value(self.getValueRef())
  val.to_int()
}

///|
pub fn ConstantInt::getValueAsInt64(self : Self) -> Int64 {
  let val = @unsafe.llvm_const_int_get_s_ext_value(self.getValueRef())
  val
}

///|
pub fn ConstantInt::getValueAsUInt64(self : Self) -> UInt64 {
  let val = @unsafe.llvm_const_int_get_z_ext_value(self.getValueRef())
  val
}

///|
pub fn ConstantInt::to_uint(self : Self) -> UInt {
  let val = @unsafe.llvm_const_int_get_z_ext_value(self.getValueRef())
  val.to_uint()
}

///|
pub impl Value for ConstantInt with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
pub impl Value for ConstantInt with fn asValueEnum(self) {
  ConstantInt(self)
}

///|
pub impl Value for ConstantInt with fn getContext(self) {
  self.value.get_context()
}

///|
pub impl Constant for ConstantInt with fn asConstantEnum(self) {
  ConstantInt(self)
}

///|
pub impl Show for ConstantInt with fn output(self, logger) {
  self.getValueRef().output(logger)
}

// ==================================================
// ConstantFP
// ==================================================

///|
pub struct ConstantFP {
  priv value : ContextOwnedValue
}

///|
fn ConstantFP::from_raw(value_ref : ValueRef, context : Context) -> ConstantFP {
  ConstantFP::{ value: ContextOwnedValue::new(value_ref, context) }
}

///|
pub impl Value for ConstantFP with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
pub impl Value for ConstantFP with fn asValueEnum(self) {
  ConstantFP(self)
}

///|
pub impl Value for ConstantFP with fn getContext(self) {
  self.value.get_context()
}

///|
pub impl Constant for ConstantFP with fn asConstantEnum(self) {
  ConstantFP(self)
}

///|
pub impl Show for ConstantFP with fn output(self, logger) {
  self.getValueRef().output(logger)
}

// ==================================================
// ConstantPointerNull
// ==================================================

///|
pub struct ConstantPointerNull {
  priv value : ContextOwnedValue
}

///|
fn ConstantPointerNull::from_raw(
  value_ref : ValueRef,
  context : Context,
) -> ConstantPointerNull {
  ConstantPointerNull::{ value: ContextOwnedValue::new(value_ref, context) }
}

///|
pub impl Value for ConstantPointerNull with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
pub impl Value for ConstantPointerNull with fn asValueEnum(self) {
  ConstantPointerNull(self)
}

///|
pub impl Value for ConstantPointerNull with fn getContext(self) {
  self.value.get_context()
}

///|
pub impl Constant for ConstantPointerNull with fn asConstantEnum(self) {
  ConstantPointerNull(self)
}

///|
pub impl Show for ConstantPointerNull with fn output(self, logger) {
  self.getValueRef().output(logger)
}

// ==================================================
// ConstantArray
// ==================================================

///|
pub struct ConstantArray {
  priv value : ContextOwnedValue
}

///|
fn ConstantArray::from_raw(
  value_ref : ValueRef,
  context : Context,
) -> ConstantArray {
  ConstantArray::{ value: ContextOwnedValue::new(value_ref, context) }
}

///|
pub impl Value for ConstantArray with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
pub impl Value for ConstantArray with fn asValueEnum(self) {
  ConstantArray(self)
}

///|
pub impl Value for ConstantArray with fn getContext(self) {
  self.value.get_context()
}

///|
pub impl Constant for ConstantArray with fn asConstantEnum(self) {
  ConstantArray(self)
}

///|
pub impl Show for ConstantArray with fn output(self, logger) {
  self.getValueRef().output(logger)
}

// ==================================================
// ConstantStruct
// ==================================================

///|
pub struct ConstantStruct {
  priv value : ContextOwnedValue
}

///|
fn ConstantStruct::from_raw(
  value_ref : ValueRef,
  context : Context,
) -> ConstantStruct {
  ConstantStruct::{ value: ContextOwnedValue::new(value_ref, context) }
}

///|
pub impl Value for ConstantStruct with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
pub impl Value for ConstantStruct with fn asValueEnum(self) {
  ConstantStruct(self)
}

///|
pub impl Value for ConstantStruct with fn getContext(self) {
  self.value.get_context()
}

///|
pub impl Constant for ConstantStruct with fn asConstantEnum(self) {
  ConstantStruct(self)
}

///|
pub impl Show for ConstantStruct with fn output(self, logger) {
  self.getValueRef().output(logger)
}

// ==================================================
// ConstantVector
// ==================================================

///|
pub struct ConstantVector {
  priv value : ContextOwnedValue
}

///|
fn ConstantVector::from_raw(
  value_ref : ValueRef,
  context : Context,
) -> ConstantVector {
  ConstantVector::{ value: ContextOwnedValue::new(value_ref, context) }
}

///|
pub impl Value for ConstantVector with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
pub impl Value for ConstantVector with fn asValueEnum(self) {
  ConstantVector(self)
}

///|
pub impl Value for ConstantVector with fn getContext(self) {
  self.value.get_context()
}

///|
pub impl Constant for ConstantVector with fn asConstantEnum(self) {
  ConstantVector(self)
}

///|
pub impl Show for ConstantVector with fn output(self, logger) {
  self.getValueRef().output(logger)
}

// ==================================================
// UndefValue
// ==================================================

///|
pub struct UndefValue {
  priv value : ContextOwnedValue
}

///|
fn UndefValue::from_raw(value_ref : ValueRef, context : Context) -> UndefValue {
  UndefValue::{ value: ContextOwnedValue::new(value_ref, context) }
}

///|
pub impl Value for UndefValue with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
pub impl Value for UndefValue with fn asValueEnum(self) {
  UndefValue(self)
}

///|
pub impl Value for UndefValue with fn getContext(self) {
  self.value.get_context()
}

///|
pub impl Constant for UndefValue with fn asConstantEnum(self) {
  UndefValue(self)
}

///|
pub impl Show for UndefValue with fn output(self, logger) {
  self.getValueRef().output(logger)
}

// ==================================================
// PoisonValue
// ==================================================

///|
pub struct PoisonValue {
  priv value : ContextOwnedValue
}

///|
fn PoisonValue::from_raw(
  value_ref : ValueRef,
  context : Context,
) -> PoisonValue {
  PoisonValue::{ value: ContextOwnedValue::new(value_ref, context) }
}

///|
pub impl Constant for PoisonValue with fn asConstantEnum(self) {
  PoisonValue(self)
}

///|
pub impl Value for PoisonValue with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
pub impl Value for PoisonValue with fn asValueEnum(self) {
  PoisonValue(self)
}

///|
pub impl Value for PoisonValue with fn getContext(self) {
  self.value.get_context()
}

///|
pub impl Show for PoisonValue with fn output(self, logger) {
  self.getValueRef().output(logger)
}

// ==================================================
// ConstantExpr
// ==================================================

///|
/// An LLVM constant expression.
pub struct ConstantExpr {
  priv value : ContextOwnedValue
}

///|
fn ConstantExpr::from_raw(
  value_ref : ValueRef,
  context : Context,
) -> ConstantExpr {
  ConstantExpr::{ value: ContextOwnedValue::new(value_ref, context) }
}

///|
pub impl Value for ConstantExpr with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
pub impl Value for ConstantExpr with fn asValueEnum(self) {
  ConstantExpr(self)
}

///|
pub impl Value for ConstantExpr with fn getContext(self) {
  self.value.get_context()
}

///|
pub impl Constant for ConstantExpr with fn asConstantEnum(self) {
  ConstantExpr(self)
}

///|
pub impl Show for ConstantExpr with fn output(self, logger) {
  self.getValueRef().output(logger)
}
