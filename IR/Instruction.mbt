// =======================================================
// AllocaInst
// =======================================================

///|
pub struct AllocaInst(ValueRef)

///|
pub fn AllocaInst::getAllocatedType(self : AllocaInst) -> &Type {
  let typeref = @unsafe.llvm_get_allocated_type(self.0)
  initAbstractType(typeref)
}

///|
pub impl Value for AllocaInst with getValueRef(self) -> ValueRef {
  self.0
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
pub impl InsertPoint for AllocaInst with asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for AllocaInst with output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// LoadInst
// =======================================================

///|
pub struct LoadInst(ValueRef)

///|
pub impl Value for LoadInst with getValueRef(self) -> ValueRef {
  self.0
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
pub impl InsertPoint for LoadInst with asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for LoadInst with output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// StoreInst
// =======================================================

///|
pub struct StoreInst(ValueRef)

///|
pub impl Value for StoreInst with getValueRef(self) -> ValueRef {
  self.0
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
pub impl InsertPoint for StoreInst with asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for StoreInst with output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// CastInst
// =======================================================

///|
pub struct CastInst(ValueRef)

///|
pub impl Value for CastInst with getValueRef(self) -> ValueRef {
  self.0
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
pub impl InsertPoint for CastInst with asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for CastInst with output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// UnaryInst
// =======================================================

///|
pub struct UnaryInst(ValueRef)

///|
pub impl Value for UnaryInst with getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for UnaryInst with asValueEnum(self) -> ValueEnum {
  UnaryInst(self)
}

///|
pub impl Instruction for UnaryInst with asInstEnum(self) -> InstructionEnum {
  UnaryInst(self)
}

///|
pub impl InsertPoint for UnaryInst with asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for UnaryInst with output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// BinaryInst
// =======================================================

///|
pub struct BinaryInst(ValueRef)

///|
pub impl Value for BinaryInst with getValueRef(self) -> ValueRef {
  self.0
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
pub impl InsertPoint for BinaryInst with asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for BinaryInst with output(self, logger) {
  self.0.output(logger)
}

///|
pub(all) enum FastMathFlags {
  AllowReassoc
  NoNaNs
  NoInfs
  NoSignedZeros
  AllowReciprocal
  AllowContract
  ApproxFunc
}

///|
pub fn FastMathFlags::to_llvm(
  self : FastMathFlags,
) -> @unsafe.LLVMFastMathFlags {
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
// ICmpInst
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
fn IntPredicate::from_llvm_int_predicate(
  pred : @unsafe.LLVMIntPredicate,
) -> IntPredicate {
  match pred {
    LLVMIntEQ => EQ
    LLVMIntNE => NE
    LLVMIntSGT => SGT
    LLVMIntSGE => SGE
    LLVMIntSLT => SLT
    LLVMIntSLE => SLE
    LLVMIntUGT => UGT
    LLVMIntUGE => UGE
    LLVMIntULT => ULT
    LLVMIntULE => ULE
  }
}

///|
pub struct ICmpInst(ValueRef)

///|
pub fn ICmpInst::getPredicate(self : Self) -> IntPredicate {
  @unsafe.llvm_get_icmp_predicate(self.0)
  |> IntPredicate::from_llvm_int_predicate
}

///|
pub impl Value for ICmpInst with getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for ICmpInst with asValueEnum(self) -> ValueEnum {
  ICmpInst(self)
}

///|
pub impl Instruction for ICmpInst with asInstEnum(self) -> InstructionEnum {
  ICmpInst(self)
}

///|
pub impl InsertPoint for ICmpInst with asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for ICmpInst with output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// FCmpInst
// =======================================================

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
  UNO
  True
  False
}

///|
fn FloatPredicate::to_llvm_float_predicate(
  self : Self,
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
    UNO => LLVMRealUNO
    True => LLVMRealPredicateTrue
    False => LLVMRealPredicateFalse
  }
}

///|
fn FloatPredicate::from_llvm_float_predicate(
  pred : @unsafe.LLVMRealPredicate,
) -> FloatPredicate {
  match pred {
    LLVMRealOEQ => OEQ
    LLVMRealOGT => OGT
    LLVMRealOGE => OGE
    LLVMRealOLT => OLT
    LLVMRealOLE => OLE
    LLVMRealONE => ONE
    LLVMRealORD => ORD
    LLVMRealUEQ => UEQ
    LLVMRealUGT => UGT
    LLVMRealUGE => UGE
    LLVMRealULT => ULT
    LLVMRealULE => ULE
    LLVMRealUNE => UNE
    LLVMRealUNO => UNO
    LLVMRealPredicateTrue => True
    LLVMRealPredicateFalse => False
  }
}

///|
pub struct FCmpInst(ValueRef)

///|
pub fn FCmpInst::getPredicate(self : Self) -> FloatPredicate {
  @unsafe.llvm_get_fcmp_predicate(self.0)
  |> FloatPredicate::from_llvm_float_predicate
}

///|
pub impl Value for FCmpInst with getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for FCmpInst with asValueEnum(self) -> ValueEnum {
  FCmpInst(self)
}

///|
pub impl Instruction for FCmpInst with asInstEnum(self) -> InstructionEnum {
  FCmpInst(self)
}

///|
pub impl InsertPoint for FCmpInst with asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for FCmpInst with output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// GetElementPtrInst
// =======================================================

///|
pub struct GetElementPtrInst(ValueRef)

///|
pub fn GetElementPtrInst::isInBounds(self : GetElementPtrInst) -> Bool {
  @unsafe.llvm_is_in_bounds(self.0)
}

///|
pub fn GetElementPtrInst::setInBounds(self : GetElementPtrInst) -> Unit {
  @unsafe.llvm_set_is_in_bounds(self.0, true)
}

///|
pub fn GetElementPtrInst::removeInBounds(self : GetElementPtrInst) -> Unit {
  @unsafe.llvm_set_is_in_bounds(self.0, false)
}

///|
pub fn GetElementPtrInst::getSourceElementType(
  self : GetElementPtrInst,
) -> &Type {
  let typeref = @unsafe.llvm_get_gep_source_element_type(self.0)
  initAbstractType(typeref)
}

///|
pub impl Value for GetElementPtrInst with getValueRef(self) -> ValueRef {
  self.0
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
pub impl InsertPoint for GetElementPtrInst with asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for GetElementPtrInst with output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// SelectInst
// =======================================================

///|
pub struct SelectInst(ValueRef)

///|
pub impl Value for SelectInst with getValueRef(self) -> ValueRef {
  self.0
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
  self.0.output(logger)
}

// =======================================================
// ExtractValueInst
// =======================================================

///|
pub struct ExtractValueInst(ValueRef)

///|
pub impl Value for ExtractValueInst with getValueRef(self) -> ValueRef {
  self.0
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
pub impl InsertPoint for SelectInst with asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl InsertPoint for ExtractValueInst with asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for ExtractValueInst with output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// InsertValueInst
// =======================================================

///|
pub struct InsertValueInst(ValueRef)

///|
pub impl Value for InsertValueInst with getValueRef(self) -> ValueRef {
  self.0
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
pub impl InsertPoint for InsertValueInst with asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for InsertValueInst with output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// PHINode
// =======================================================

///|
pub struct PHINode(ValueRef)

///|
pub fn PHINode::addIncoming(
  self : PHINode,
  value : &Value,
  block : BasicBlock,
) -> Unit {
  @unsafe.llvm_add_incoming(self.0, [value.getValueRef()], [block.0])
}

///|
pub fn PHINode::countIncoming(self : PHINode) -> Int {
  @unsafe.llvm_count_incoming(self.0).reinterpret_as_int()
}

// TODO:
//pub fn PHINOde::getIncomingValue(
//  self : PHINode,
//  idx : Int
//) -> &Value? {
//  when(
//    idx >= 0 && idx < self.countIncoming(),
//    () => { @unsafe.llvm_get_incoming_value(self.0, idx.reinterpret_as_uint())) }
//  )
//}

///|
pub fn PHINode::getIncomingBlock(self : PHINode, idx : Int) -> BasicBlock? {
  when(idx >= 0 && idx < self.countIncoming(), () => BasicBlock(
    @unsafe.llvm_get_incoming_block(self.0, idx.reinterpret_as_uint()),
  ))
}

///|
pub impl Value for PHINode with getValueRef(self) -> ValueRef {
  self.0
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
pub impl InsertPoint for PHINode with asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for PHINode with output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// ReturnInst
// =======================================================

///|
pub struct ReturnInst(ValueRef)

///|
pub impl Value for ReturnInst with getValueRef(self) -> ValueRef {
  self.0
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
pub impl InsertPoint for ReturnInst with asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for ReturnInst with output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// BranchInst
// =======================================================

///|
pub struct BranchInst(ValueRef)

///|
pub fn BranchInst::isConditional(self : BranchInst) -> Bool {
  @unsafe.llvm_is_conditional(self.0)
}

///|
pub suberror InValidOperation String derive(Show)

///|
#callsite(autofill(loc))
pub fn BranchInst::setCondition(
  self : BranchInst,
  cond : &Value,
  loc~ : SourceLoc,
) -> Unit raise {
  guard self.isConditional() else {
    let msg =
      $| loc: \{loc}:
      #| Misuse `BranchInst::setCondition`, Instruction is not conditional.
    raise InValidOperation(msg)
  }
  @unsafe.llvm_set_condition(self.0, cond.getValueRef())
}

///|
pub fn BranchInst::getNumSuccessors(self : BranchInst) -> Int {
  @unsafe.llvm_get_num_successors(self.0).reinterpret_as_int()
}

///|
pub fn BranchInst::getSuccessor(self : BranchInst, idx : Int) -> BasicBlock? {
  when(idx >= 0 && idx < self.getNumSuccessors(), () => BasicBlock(
    @unsafe.llvm_get_successor(self.0, idx.reinterpret_as_uint()),
  ))
}

///|
#callsite(autofill(loc))
pub fn BranchInst::setSuccessor(
  self : BranchInst,
  idx : Int,
  block : BasicBlock,
  loc~ : SourceLoc,
) -> Unit raise {
  guard idx >= 0 && idx < self.getNumSuccessors() else {
    let msg =
      $| loc: \{loc}:
      #| Misuse `BranchInst::setSuccessor`, Index out of bounds.
    raise IndexOutOfBounds(msg)
  }
  @unsafe.llvm_set_successor(
    self.0,
    idx.reinterpret_as_uint(),
    block.0,
  )
}

///|
pub impl Value for BranchInst with getValueRef(self) -> ValueRef {
  self.0
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
pub impl InsertPoint for BranchInst with asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for BranchInst with output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// SwitchInst
// =======================================================

///|
pub suberror SwitchInstError {
  InValidSwitchCaseValue(String)
}

///|
pub struct SwitchInst(ValueRef)

///|
pub fn SwitchInst::addCase(
  self : Self,
  on_val : &Value,
  dest : BasicBlock,
) -> Unit raise {
  guard on_val.getType().tryAsIntType() is Some(_) else {
    raise InValidSwitchCaseValue(
      "Misuse `SwitchInst::addCase`: Expected an integer type for case value, got: \{on_val.getType()}",
    )
  }
  @unsafe.llvm_add_case(self.0, on_val.getValueRef(), dest.0)
}

///|
pub fn SwitchInst::getNumSuccessors(self : Self) -> Int {
  @unsafe.llvm_get_num_successors(self.0).reinterpret_as_int()
}

///|
pub fn SwitchInst::getSuccessor(self : Self, idx : Int) -> BasicBlock? {
  when(idx >= 0 && idx < self.getNumSuccessors(), () => BasicBlock(
    @unsafe.llvm_get_successor(self.0, idx.reinterpret_as_uint()),
  ))
}

///|
#callsite(autofill(loc))
pub fn SwitchInst::setSuccessor(
  self : Self,
  idx : Int,
  block : BasicBlock,
  loc~ : SourceLoc,
) -> Unit raise {
  guard idx >= 0 && idx < self.getNumSuccessors() else {
    let msg =
      $| loc: \{loc}:
      #| Misuse `BranchInst::setSuccessor`, Index out of bounds.
    raise IndexOutOfBounds(msg)
  }
  @unsafe.llvm_set_successor(
    self.0,
    idx.reinterpret_as_uint(),
    block.0,
  )
}

///|
pub impl Value for SwitchInst with getValueRef(self) -> ValueRef {
  self.0
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
pub impl InsertPoint for SwitchInst with asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for SwitchInst with output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// CallInst
// =======================================================

///|
pub(all) enum TailCallKind {
  None
  Tail
  MustTail
  NoTail
} derive(Show)

///|
fn TailCallKind::to_llvm(self : TailCallKind) -> @unsafe.LLVMTailCallKind {
  match self {
    None => LLVMTailCallKindNone
    Tail => LLVMTailCallKindTail
    MustTail => LLVMTailCallKindMustTail
    NoTail => LLVMTailCallKindNoTail
  }
}

///|
fn TailCallKind::from_llvm(kind : @unsafe.LLVMTailCallKind) -> TailCallKind {
  match kind {
    LLVMTailCallKindNone => None
    LLVMTailCallKindTail => Tail
    LLVMTailCallKindMustTail => MustTail
    LLVMTailCallKindNoTail => NoTail
  }
}

///|
pub struct CallInst(ValueRef)

///|
pub fn CallInst::isTailCall(self : CallInst) -> Bool {
  @unsafe.llvm_is_tail_call(self.0)
}

///|
pub fn CallInst::setTailCall(self : CallInst) -> Unit {
  @unsafe.llvm_set_tail_call(self.0, true)
}

///|
pub fn CallInst::removeTailCall(self : CallInst) -> Unit {
  @unsafe.llvm_set_tail_call(self.0, false)
}

///|
pub fn CallInst::getTailCallKind(self : CallInst) -> TailCallKind {
  @unsafe.llvm_get_tail_call_kind(self.0) |> TailCallKind::from_llvm
}

///|
pub fn CallInst::setTailCallKind(self : CallInst, kind : TailCallKind) -> Unit {
  @unsafe.llvm_set_tail_call_kind(self.0, kind.to_llvm())
}

///|
pub impl Value for CallInst with getValueRef(self) -> ValueRef {
  self.0
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
pub impl InsertPoint for CallInst with asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for CallInst with output(self, logger) {
  self.0.output(logger)
}
