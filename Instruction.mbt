// =======================================================
// AllocaInst
// =======================================================

///|
pub type AllocaInst ValueRef

///|
pub impl Value for AllocaInst with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for AllocaInst with asValueEnum(self) -> ValueEnum {
  AllocaInst(self)
}

///|
pub impl Instruction for AllocaInst with asInstEnum(self) -> InstructionEnum {
  AllocaInst(self)
}

///|
pub impl Show for AllocaInst with output(self, logger) {
  self.inner().output(logger)
}

// =======================================================
// LoadInst
// =======================================================

///|
pub type LoadInst ValueRef

///|
pub impl Value for LoadInst with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for LoadInst with asValueEnum(self) -> ValueEnum {
  LoadInst(self)
}

///|
pub impl Instruction for LoadInst with asInstEnum(self) -> InstructionEnum {
  LoadInst(self)
}

///|
pub impl Show for LoadInst with output(self, logger) {
  self.inner().output(logger)
}

// =======================================================
// StoreInst
// =======================================================

///|
pub type StoreInst ValueRef

///|
pub impl Value for StoreInst with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for StoreInst with asValueEnum(self) -> ValueEnum {
  StoreInst(self)
}

///|
pub impl Instruction for StoreInst with asInstEnum(self) -> InstructionEnum {
  StoreInst(self)
}

///|
pub impl Show for StoreInst with output(self, logger) {
  self.inner().output(logger)
}

// =======================================================
// CastInst
// =======================================================

///|
pub type CastInst ValueRef

///|
pub impl Value for CastInst with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for CastInst with asValueEnum(self) -> ValueEnum {
  CastInst(self)
}

///|
pub impl Instruction for CastInst with asInstEnum(self) -> InstructionEnum {
  CastInst(self)
}

///|
pub impl Show for CastInst with output(self, logger) {
  self.inner().output(logger)
}

// =======================================================
// UnaryInst
// =======================================================

pub type UnaryInst ValueRef

pub impl Value for UnaryInst with getValueRef(self) -> ValueRef {
  self.inner()
}

pub impl Value for UnaryInst with asValueEnum(self) -> ValueEnum {
  UnaryInst(self)
}

pub impl Instruction for UnaryInst with asInstEnum(self) -> InstructionEnum {
  UnaryInst(self)
}

pub impl Show for UnaryInst with output(self, logger) {
  self.inner().output(logger)
}

// =======================================================
// BinaryInst
// =======================================================

///|
pub type BinaryInst ValueRef

///|
pub impl Value for BinaryInst with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for BinaryInst with asValueEnum(self) -> ValueEnum {
  BinaryInst(self)
}

///|
pub impl Instruction for BinaryInst with asInstEnum(self) -> InstructionEnum {
  BinaryInst(self)
}

///|
pub impl Show for BinaryInst with output(self, logger) {
  self.inner().output(logger)
}

pub(all) enum FastMathFlags {
  AllowReassoc
  NoNaNs
  NoInfs
  NoSignedZeros
  AllowReciprocal
  AllowContract
  ApproxFunc
}

pub fn FastMathFlags::to_llvm(self: FastMathFlags) -> @unsafe.LLVMFastMathFlags {
  match self {
    AllowReassoc => @unsafe.LLVMFastMathFlags::AllowReassoc
    NoNaNs => @unsafe.LLVMFastMathFlags::NoNaNs
    NoInfs => @unsafe.LLVMFastMathFlags::NoInfs
    NoSignedZeros => @unsafe.LLVMFastMathFlags::NoSignedZeros
    AllowReciprocal => @unsafe.LLVMFastMathFlags::AllowReciprocal
    AllowContract => @unsafe.LLVMFastMathFlags::AllowContract
    ApproxFunc => @unsafe.LLVMFastMathFlags::ApproxFunc
  }
}

// =======================================================
// CmpInst
// =======================================================

///|
pub(all) enum IntPredicate {
  EQ
  NE
  SGT
  SGE
  SLT
  SLE
  UGT
  UGE
  ULT
  ULE
}

///|
fn IntPredicate::to_llvm_int_predicate(self : Self) -> @unsafe.LLVMIntPredicate {
  match self {
    EQ => LLVMIntEQ
    NE => LLVMIntNE
    SGT => LLVMIntSGT
    SGE => LLVMIntSGE
    SLT => LLVMIntSLT
    SLE => LLVMIntSLE
    UGT => LLVMIntUGT
    UGE => LLVMIntUGE
    ULT => LLVMIntULT
    ULE => LLVMIntULE
  }
}

///|
pub(all) enum FloatPredicate {
  OEQ
  OGT
  OGE
  OLT
  OLE
  ONE
  ORD
  UEQ
  UGT
  UGE
  ULT
  ULE
  UNE
}

///|
fn FloatPredicate::to_llvm_float_predicate(
  self : Self
) -> @unsafe.LLVMRealPredicate {
  match self {
    OEQ => LLVMRealOEQ
    OGT => LLVMRealOGT
    OGE => LLVMRealOGE
    OLT => LLVMRealOLT
    OLE => LLVMRealOLE
    ONE => LLVMRealONE
    ORD => LLVMRealORD
    UEQ => LLVMRealUEQ
    UGT => LLVMRealUGT
    UGE => LLVMRealUGE
    ULT => LLVMRealULT
    ULE => LLVMRealULE
    UNE => LLVMRealUNE
  }
}

///|
pub type CmpInst ValueRef

///|
pub impl Value for CmpInst with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for CmpInst with asValueEnum(self) -> ValueEnum {
  CmpInst(self)
}

///|
pub impl Instruction for CmpInst with asInstEnum(self) -> InstructionEnum {
  CmpInst(self)
}

///|
pub impl Show for CmpInst with output(self, logger) {
  self.inner().output(logger)
}

// =======================================================
// GetElementPtrInst
// =======================================================

///|
pub type GetElementPtrInst ValueRef

///|
pub impl Value for GetElementPtrInst with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for GetElementPtrInst with asValueEnum(self) -> ValueEnum {
  GetElementPtrInst(self)
}

///|
pub impl Instruction for GetElementPtrInst with asInstEnum(self) -> InstructionEnum {
  GetElementPtrInst(self)
}

///|
pub impl Show for GetElementPtrInst with output(self, logger) {
  self.inner().output(logger)
}

// =======================================================
// SelectInst
// =======================================================

///|
pub type SelectInst ValueRef

///|
pub impl Value for SelectInst with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for SelectInst with asValueEnum(self) -> ValueEnum {
  SelectInst(self)
}

///|
pub impl Instruction for SelectInst with asInstEnum(self) -> InstructionEnum {
  SelectInst(self)
}

///|
pub impl Show for SelectInst with output(self, logger) {
  self.inner().output(logger)
}

// =======================================================
// ExtractValueInst
// =======================================================

///|
pub type ExtractValueInst ValueRef

///|
pub impl Value for ExtractValueInst with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for ExtractValueInst with asValueEnum(self) -> ValueEnum {
  ExtractValueInst(self)
}

///|
pub impl Instruction for ExtractValueInst with asInstEnum(self) -> InstructionEnum {
  ExtractValueInst(self)
}

///|
pub impl Show for ExtractValueInst with output(self, logger) {
  self.inner().output(logger)
}

// =======================================================
// InsertValueInst
// =======================================================

///|
pub type InsertValueInst ValueRef

///|
pub impl Value for InsertValueInst with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for InsertValueInst with asValueEnum(self) -> ValueEnum {
  InsertValueInst(self)
}

///|
pub impl Instruction for InsertValueInst with asInstEnum(self) -> InstructionEnum {
  InsertValueInst(self)
}

///|
pub impl Show for InsertValueInst with output(self, logger) {
  self.inner().output(logger)
}

// =======================================================
// PHINode
// =======================================================

///|
pub type PHINode ValueRef

///|
pub fn PHINode::addIncoming(
  self : PHINode,
  value : &Value,
  block : BasicBlock
) -> Unit {
  @unsafe.llvm_add_incoming(self.inner(), [value.getValueRef()], [block.inner()])
}

///|
pub impl Value for PHINode with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for PHINode with asValueEnum(self) -> ValueEnum {
  PHINode(self)
}

///|
pub impl Instruction for PHINode with asInstEnum(self) -> InstructionEnum {
  PHINode(self)
}

///|
pub impl Show for PHINode with output(self, logger) {
  self.inner().output(logger)
}

// =======================================================
// ReturnInst
// =======================================================

///|
pub type ReturnInst ValueRef

///|
pub impl Value for ReturnInst with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for ReturnInst with asValueEnum(self) -> ValueEnum {
  ReturnInst(self)
}

///|
pub impl Instruction for ReturnInst with asInstEnum(self) -> InstructionEnum {
  ReturnInst(self)
}

///|
pub impl Show for ReturnInst with output(self, logger) {
  self.inner().output(logger)
}

// =======================================================
// BranchInst
// =======================================================

///|
pub type BranchInst ValueRef

///|
pub impl Value for BranchInst with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for BranchInst with asValueEnum(self) -> ValueEnum {
  BranchInst(self)
}

///|
pub impl Instruction for BranchInst with asInstEnum(self) -> InstructionEnum {
  BranchInst(self)
}

///|
pub impl Show for BranchInst with output(self, logger) {
  self.inner().output(logger)
}

// =======================================================
// SwitchInst
// =======================================================

///|
pub suberror SwitchInstError {
  InValidSwitchCaseValue(String)
}

///|
pub type SwitchInst ValueRef

///|
pub fn SwitchInst::addCase(
  self : SwitchInst,
  on_val : &Value,
  dest : BasicBlock
) -> Unit raise {
  guard on_val.getType().asTypeEnum() is IntType(_) else {
    raise InValidSwitchCaseValue(
      "Misuse `SwitchInst::addCase`: Expected an integer type for case value, got: \{on_val.getType()}",
    )
  }
  @unsafe.llvm_add_case(self.inner(), on_val.getValueRef(), dest.inner())
}

///|
pub impl Value for SwitchInst with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for SwitchInst with asValueEnum(self) -> ValueEnum {
  SwitchInst(self)
}

///|
pub impl Instruction for SwitchInst with asInstEnum(self) -> InstructionEnum {
  SwitchInst(self)
}

///|
pub impl Show for SwitchInst with output(self, logger) {
  self.inner().output(logger)
}

// =======================================================
// CallInst
// =======================================================

///|
pub type CallInst ValueRef

///|
pub impl Value for CallInst with getValueRef(self) -> ValueRef {
  self.inner()
}

///|
pub impl Value for CallInst with asValueEnum(self) -> ValueEnum {
  CallInst(self)
}

///|
pub impl Instruction for CallInst with asInstEnum(self) -> InstructionEnum {
  CallInst(self)
}

///|
pub impl Show for CallInst with output(self, logger) {
  self.inner().output(logger)
}
