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
pub impl Value for AllocaInst with fn getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for AllocaInst with fn asValueEnum(self) -> ValueEnum {
  AllocaInst(self)
}

///|
pub impl Instruction for AllocaInst with fn asInstEnum(self) -> InstructionEnum {
  AllocaInst(self)
}

///|
pub impl InsertPoint for AllocaInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for AllocaInst with fn output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// LoadInst
// =======================================================

///|
pub struct LoadInst(ValueRef)

///|
pub impl Value for LoadInst with fn getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for LoadInst with fn asValueEnum(self) -> ValueEnum {
  LoadInst(self)
}

///|
pub impl Instruction for LoadInst with fn asInstEnum(self) -> InstructionEnum {
  LoadInst(self)
}

///|
pub impl InsertPoint for LoadInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for LoadInst with fn output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// StoreInst
// =======================================================

///|
pub struct StoreInst(ValueRef)

///|
pub impl Value for StoreInst with fn getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for StoreInst with fn asValueEnum(self) -> ValueEnum {
  StoreInst(self)
}

///|
pub impl Instruction for StoreInst with fn asInstEnum(self) -> InstructionEnum {
  StoreInst(self)
}

///|
pub impl InsertPoint for StoreInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for StoreInst with fn output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// CastInst
// =======================================================

///|
pub struct CastInst(ValueRef)

///|
pub impl Value for CastInst with fn getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for CastInst with fn asValueEnum(self) -> ValueEnum {
  CastInst(self)
}

///|
pub impl Instruction for CastInst with fn asInstEnum(self) -> InstructionEnum {
  CastInst(self)
}

///|
pub impl InsertPoint for CastInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for CastInst with fn output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// UnaryInst
// =======================================================

///|
pub struct UnaryInst(ValueRef)

///|
pub impl Value for UnaryInst with fn getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for UnaryInst with fn asValueEnum(self) -> ValueEnum {
  UnaryInst(self)
}

///|
pub impl Instruction for UnaryInst with fn asInstEnum(self) -> InstructionEnum {
  UnaryInst(self)
}

///|
pub impl InsertPoint for UnaryInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for UnaryInst with fn output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// BinaryInst
// =======================================================

///|
pub struct BinaryInst(ValueRef)

///|
pub impl Value for BinaryInst with fn getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for BinaryInst with fn asValueEnum(self) -> ValueEnum {
  BinaryInst(self)
}

///|
pub impl Instruction for BinaryInst with fn asInstEnum(self) -> InstructionEnum {
  BinaryInst(self)
}

///|
pub impl InsertPoint for BinaryInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for BinaryInst with fn output(self, logger) {
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
pub impl Value for ICmpInst with fn getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for ICmpInst with fn asValueEnum(self) -> ValueEnum {
  ICmpInst(self)
}

///|
pub impl Instruction for ICmpInst with fn asInstEnum(self) -> InstructionEnum {
  ICmpInst(self)
}

///|
pub impl InsertPoint for ICmpInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for ICmpInst with fn output(self, logger) {
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
pub impl Value for FCmpInst with fn getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for FCmpInst with fn asValueEnum(self) -> ValueEnum {
  FCmpInst(self)
}

///|
pub impl Instruction for FCmpInst with fn asInstEnum(self) -> InstructionEnum {
  FCmpInst(self)
}

///|
pub impl InsertPoint for FCmpInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for FCmpInst with fn output(self, logger) {
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
pub impl Value for GetElementPtrInst with fn getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for GetElementPtrInst with fn asValueEnum(self) -> ValueEnum {
  GetElementPtrInst(self)
}

///|
pub impl Instruction for GetElementPtrInst with fn asInstEnum(self) -> InstructionEnum {
  GetElementPtrInst(self)
}

///|
pub impl InsertPoint for GetElementPtrInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for GetElementPtrInst with fn output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// SelectInst
// =======================================================

///|
pub struct SelectInst(ValueRef)

///|
pub impl Value for SelectInst with fn getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for SelectInst with fn asValueEnum(self) -> ValueEnum {
  SelectInst(self)
}

///|
pub impl Instruction for SelectInst with fn asInstEnum(self) -> InstructionEnum {
  SelectInst(self)
}

///|
pub impl Show for SelectInst with fn output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// ExtractValueInst
// =======================================================

///|
pub struct ExtractValueInst(ValueRef)

///|
pub impl Value for ExtractValueInst with fn getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for ExtractValueInst with fn asValueEnum(self) -> ValueEnum {
  ExtractValueInst(self)
}

///|
pub impl Instruction for ExtractValueInst with fn asInstEnum(self) -> InstructionEnum {
  ExtractValueInst(self)
}

///|
pub impl InsertPoint for SelectInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl InsertPoint for ExtractValueInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for ExtractValueInst with fn output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// InsertValueInst
// =======================================================

///|
pub struct InsertValueInst(ValueRef)

///|
pub impl Value for InsertValueInst with fn getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for InsertValueInst with fn asValueEnum(self) -> ValueEnum {
  InsertValueInst(self)
}

///|
pub impl Instruction for InsertValueInst with fn asInstEnum(self) -> InstructionEnum {
  InsertValueInst(self)
}

///|
pub impl InsertPoint for InsertValueInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for InsertValueInst with fn output(self, logger) {
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
  when(idx >= 0 && idx < self.countIncoming(), () => {
    BasicBlock(
      @unsafe.llvm_get_incoming_block(self.0, idx.reinterpret_as_uint()),
    )
  })
}

///|
pub impl Value for PHINode with fn getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for PHINode with fn asValueEnum(self) -> ValueEnum {
  PHINode(self)
}

///|
pub impl Instruction for PHINode with fn asInstEnum(self) -> InstructionEnum {
  PHINode(self)
}

///|
pub impl InsertPoint for PHINode with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for PHINode with fn output(self, logger) {
  self.0.output(logger)
}

// =======================================================
// ReturnInst
// =======================================================

///|
pub struct ReturnInst(ValueRef)

///|
pub impl Value for ReturnInst with fn getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for ReturnInst with fn asValueEnum(self) -> ValueEnum {
  ReturnInst(self)
}

///|
pub impl Instruction for ReturnInst with fn asInstEnum(self) -> InstructionEnum {
  ReturnInst(self)
}

///|
pub impl InsertPoint for ReturnInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for ReturnInst with fn output(self, logger) {
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
pub suberror InValidOperation {
  InValidOperation(String)
} derive(Debug)

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
  when(idx >= 0 && idx < self.getNumSuccessors(), () => {
    BasicBlock(@unsafe.llvm_get_successor(self.0, idx.reinterpret_as_uint()))
  })
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
  @unsafe.llvm_set_successor(self.0, idx.reinterpret_as_uint(), block.0)
}

///|
pub impl Value for BranchInst with fn getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for BranchInst with fn asValueEnum(self) -> ValueEnum {
  BranchInst(self)
}

///|
pub impl Instruction for BranchInst with fn asInstEnum(self) -> InstructionEnum {
  BranchInst(self)
}

///|
pub impl InsertPoint for BranchInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for BranchInst with fn output(self, logger) {
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
  when(idx >= 0 && idx < self.getNumSuccessors(), () => {
    BasicBlock(@unsafe.llvm_get_successor(self.0, idx.reinterpret_as_uint()))
  })
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
  @unsafe.llvm_set_successor(self.0, idx.reinterpret_as_uint(), block.0)
}

///|
pub impl Value for SwitchInst with fn getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for SwitchInst with fn asValueEnum(self) -> ValueEnum {
  SwitchInst(self)
}

///|
pub impl Instruction for SwitchInst with fn asInstEnum(self) -> InstructionEnum {
  SwitchInst(self)
}

///|
pub impl InsertPoint for SwitchInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for SwitchInst with fn output(self, logger) {
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
} derive(Debug)

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
pub impl Value for CallInst with fn getValueRef(self) -> ValueRef {
  self.0
}

///|
pub impl Value for CallInst with fn asValueEnum(self) -> ValueEnum {
  CallInst(self)
}

///|
pub impl Instruction for CallInst with fn asInstEnum(self) -> InstructionEnum {
  CallInst(self)
}

///|
pub impl InsertPoint for CallInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
pub impl Show for CallInst with fn output(self, logger) {
  self.0.output(logger)
}
