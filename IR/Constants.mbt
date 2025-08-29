// ==================================================
// ConstantInt
// ==================================================

///|
pub struct ConstantInt(ValueRef)

///|
pub fn ConstantInt::to_int(self : Self) -> Int {
  let val = @unsafe.llvm_const_int_get_s_ext_value(self.getValueRef())
  val.to_int()
}

///|
pub fn ConstantInt::to_uint(self : Self) -> UInt {
  let val = @unsafe.llvm_const_int_get_z_ext_value(self.getValueRef())
  val.to_uint()
}

///|
pub impl Value for ConstantInt with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for ConstantInt with asValueEnum(self) {
  ConstantInt(self)
}

///|
pub impl Constant for ConstantInt with asConstEnum(self) {
  ConstantInt(self)
}

///|
pub impl Show for ConstantInt with output(self, logger) {
  self.inner().output(logger)
}

// ==================================================
// ConstantFP
// ==================================================

///|
pub struct ConstantFP(ValueRef)

///|
pub impl Value for ConstantFP with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for ConstantFP with asValueEnum(self) {
  ConstantFP(self)
}

///|
pub impl Constant for ConstantFP with asConstEnum(self) {
  ConstantFP(self)
}

///|
pub impl Show for ConstantFP with output(self, logger) {
  self.inner().output(logger)
}

// ==================================================
// ConstantPointerNull
// ==================================================

///|
pub struct ConstantPointerNull(ValueRef)

///|
pub impl Value for ConstantPointerNull with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for ConstantPointerNull with asValueEnum(self) {
  ConstantPointerNull(self)
}

///|
pub impl Constant for ConstantPointerNull with asConstEnum(self) {
  ConstantPointerNull(self)
}

///|
pub impl Show for ConstantPointerNull with output(self, logger) {
  self.inner().output(logger)
}

// ==================================================
// ConstantArray
// ==================================================

///|
pub struct ConstantArray(ValueRef)

///|
pub impl Value for ConstantArray with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for ConstantArray with asValueEnum(self) {
  ConstantArray(self)
}

///|
pub impl Constant for ConstantArray with asConstEnum(self) {
  ConstantArray(self)
}

///|
pub impl Show for ConstantArray with output(self, logger) {
  self.inner().output(logger)
}

// ==================================================
// ConstantStruct
// ==================================================

///|
pub struct ConstantStruct(ValueRef)

///|
pub impl Value for ConstantStruct with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for ConstantStruct with asValueEnum(self) {
  ConstantStruct(self)
}

///|
pub impl Constant for ConstantStruct with asConstEnum(self) {
  ConstantStruct(self)
}

///|
pub impl Show for ConstantStruct with output(self, logger) {
  self.inner().output(logger)
}

// ==================================================
// ConstantVector
// ==================================================

///|
pub struct ConstantVector(ValueRef)

///|
pub impl Value for ConstantVector with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for ConstantVector with asValueEnum(self) {
  ConstantVector(self)
}

///|
pub impl Constant for ConstantVector with asConstEnum(self) {
  ConstantVector(self)
}

///|
pub impl Show for ConstantVector with output(self, logger) {
  self.inner().output(logger)
}

// ==================================================
// UndefValue
// ==================================================

///|
pub struct UndefValue(ValueRef)

///|
pub impl Value for UndefValue with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for UndefValue with asValueEnum(self) {
  UndefValue(self)
}

///|
pub impl Constant for UndefValue with asConstEnum(self) {
  UndefValue(self)
}

///|
pub impl Show for UndefValue with output(self, logger) {
  self.inner().output(logger)
}

// ==================================================
// PoisonValue
// ==================================================

///|
pub struct PoisonValue(ValueRef)

///|
pub impl Constant for PoisonValue with asConstEnum(self) {
  PoisonValue(self)
}

///|
pub impl Value for PoisonValue with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for PoisonValue with asValueEnum(self) {
  PoisonValue(self)
}

///|
pub impl Show for PoisonValue with output(self, logger) {
  self.inner().output(logger)
}
