// =======================================================
// AllocaInst
// =======================================================

///|
/// Module-anchored stack-allocation instruction.
///
/// The allocation produces a pointer in the target's alloca address space and
/// is valid only while its enclosing function invocation is active.
///
/// **Lifecycle:** The wrapper retains its module but becomes dangling if the
/// instruction or containing block is erased.
pub struct AllocaInst {
  priv value : ModuleAnchoredValue
}

///|
fn AllocaInst::from_raw(
  value_ref : ValueRef,
  owner_module : Module,
) -> AllocaInst {
  AllocaInst::{ value: ModuleAnchoredValue::new(value_ref, owner_module) }
}

///|
fn AllocaInst::get_module(self : AllocaInst) -> Module {
  self.value.get_module()
}

///|
/// Returns the type of each allocated element.
///
/// **Lifecycle:** The returned type is owned by the module's context.
pub fn AllocaInst::getAllocatedType(self : AllocaInst) -> &Type {
  let typeref = @unsafe.llvm_get_allocated_type(self.getValueRef())
  initAbstractType(typeref, self.get_module().getContext())
}

///|
/// Exposes the borrowed LLVM value handle.
pub impl Value for AllocaInst with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::AllocaInst`.
pub impl Value for AllocaInst with fn asValueEnum(self) -> ValueEnum {
  AllocaInst(self)
}

///|
/// Classifies this wrapper as `InstructionEnum::AllocaInst`.
pub impl Instruction for AllocaInst with fn asInstEnum(self) -> InstructionEnum {
  AllocaInst(self)
}

///|
/// Allows insertion immediately before this instruction.
pub impl InsertPoint for AllocaInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
/// Writes this allocation instruction using LLVM syntax.
pub impl Show for AllocaInst with fn output(self, logger) {
  self.getValueRef().output(logger)
}

// =======================================================
// LoadInst
// =======================================================

///|
/// Module-anchored instruction that reads a typed value from memory.
///
/// Volatility, atomic ordering, and alignment are properties of the underlying
/// instruction; this wrapper currently exposes only common instruction APIs.
///
/// **Lifecycle:** Erasing the instruction or its block invalidates the wrapper.
pub struct LoadInst {
  priv value : ModuleAnchoredValue
}

///|
fn LoadInst::from_raw(value_ref : ValueRef, owner_module : Module) -> LoadInst {
  LoadInst::{ value: ModuleAnchoredValue::new(value_ref, owner_module) }
}

///|
fn LoadInst::get_module(self : LoadInst) -> Module {
  self.value.get_module()
}

///|
/// Exposes the borrowed LLVM value handle.
pub impl Value for LoadInst with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::LoadInst`.
pub impl Value for LoadInst with fn asValueEnum(self) -> ValueEnum {
  LoadInst(self)
}

///|
/// Classifies this wrapper as `InstructionEnum::LoadInst`.
pub impl Instruction for LoadInst with fn asInstEnum(self) -> InstructionEnum {
  LoadInst(self)
}

///|
/// Allows insertion immediately before this instruction.
pub impl InsertPoint for LoadInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
/// Writes this load instruction using LLVM syntax.
pub impl Show for LoadInst with fn output(self, logger) {
  self.getValueRef().output(logger)
}

// =======================================================
// StoreInst
// =======================================================

///|
/// Module-anchored instruction that writes a typed value to memory.
///
/// Store instructions have LLVM `void` type and produce no SSA result.
///
/// **Lifecycle:** Erasing the instruction or its block invalidates the wrapper.
pub struct StoreInst {
  priv value : ModuleAnchoredValue
}

///|
fn StoreInst::from_raw(
  value_ref : ValueRef,
  owner_module : Module,
) -> StoreInst {
  StoreInst::{ value: ModuleAnchoredValue::new(value_ref, owner_module) }
}

///|
fn StoreInst::get_module(self : StoreInst) -> Module {
  self.value.get_module()
}

///|
/// Exposes the borrowed LLVM value handle.
pub impl Value for StoreInst with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::StoreInst`.
pub impl Value for StoreInst with fn asValueEnum(self) -> ValueEnum {
  StoreInst(self)
}

///|
/// Classifies this wrapper as `InstructionEnum::StoreInst`.
pub impl Instruction for StoreInst with fn asInstEnum(self) -> InstructionEnum {
  StoreInst(self)
}

///|
/// Allows insertion immediately before this instruction.
pub impl InsertPoint for StoreInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
/// Writes this store instruction using LLVM syntax.
pub impl Show for StoreInst with fn output(self, logger) {
  self.getValueRef().output(logger)
}

// =======================================================
// CastInst
// =======================================================

///|
/// Module-anchored instruction that converts a value between LLVM types.
///
/// The concrete opcode determines whether the conversion changes width,
/// signed interpretation, floating representation, or pointer/integer form.
pub struct CastInst {
  priv value : ModuleAnchoredValue
}

///|
fn CastInst::from_raw(value_ref : ValueRef, owner_module : Module) -> CastInst {
  CastInst::{ value: ModuleAnchoredValue::new(value_ref, owner_module) }
}

///|
fn CastInst::get_module(self : CastInst) -> Module {
  self.value.get_module()
}

///|
/// Exposes the borrowed LLVM value handle.
pub impl Value for CastInst with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::CastInst`.
pub impl Value for CastInst with fn asValueEnum(self) -> ValueEnum {
  CastInst(self)
}

///|
/// Classifies this wrapper as `InstructionEnum::CastInst`.
pub impl Instruction for CastInst with fn asInstEnum(self) -> InstructionEnum {
  CastInst(self)
}

///|
/// Allows insertion immediately before this instruction.
pub impl InsertPoint for CastInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
/// Writes this conversion instruction using LLVM syntax.
pub impl Show for CastInst with fn output(self, logger) {
  self.getValueRef().output(logger)
}

// =======================================================
// UnaryInst
// =======================================================

///|
/// Module-anchored unary arithmetic instruction.
///
/// This safe hierarchy currently uses it for floating-point negation.
pub struct UnaryInst {
  priv value : ModuleAnchoredValue
}

///|
fn UnaryInst::from_raw(
  value_ref : ValueRef,
  owner_module : Module,
) -> UnaryInst {
  UnaryInst::{ value: ModuleAnchoredValue::new(value_ref, owner_module) }
}

///|
fn UnaryInst::get_module(self : UnaryInst) -> Module {
  self.value.get_module()
}

///|
/// Exposes the borrowed LLVM value handle.
pub impl Value for UnaryInst with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::UnaryInst`.
pub impl Value for UnaryInst with fn asValueEnum(self) -> ValueEnum {
  UnaryInst(self)
}

///|
/// Classifies this wrapper as `InstructionEnum::UnaryInst`.
pub impl Instruction for UnaryInst with fn asInstEnum(self) -> InstructionEnum {
  UnaryInst(self)
}

///|
/// Allows insertion immediately before this instruction.
pub impl InsertPoint for UnaryInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
/// Writes this unary instruction using LLVM syntax.
pub impl Show for UnaryInst with fn output(self, logger) {
  self.getValueRef().output(logger)
}

// =======================================================
// BinaryInst
// =======================================================

///|
/// Module-anchored binary arithmetic or bitwise instruction.
///
/// Integer overflow/exactness and floating fast-math flags are semantic
/// promises, not merely optimization preferences.
pub struct BinaryInst {
  priv value : ModuleAnchoredValue
}

///|
fn BinaryInst::from_raw(
  value_ref : ValueRef,
  owner_module : Module,
) -> BinaryInst {
  BinaryInst::{ value: ModuleAnchoredValue::new(value_ref, owner_module) }
}

///|
fn BinaryInst::get_module(self : BinaryInst) -> Module {
  self.value.get_module()
}

///|
/// Exposes the borrowed LLVM value handle.
pub impl Value for BinaryInst with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::BinaryInst`.
pub impl Value for BinaryInst with fn asValueEnum(self) -> ValueEnum {
  BinaryInst(self)
}

///|
/// Classifies this wrapper as `InstructionEnum::BinaryInst`.
pub impl Instruction for BinaryInst with fn asInstEnum(self) -> InstructionEnum {
  BinaryInst(self)
}

///|
/// Allows insertion immediately before this instruction.
pub impl InsertPoint for BinaryInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
/// Writes this binary instruction using LLVM syntax.
pub impl Show for BinaryInst with fn output(self, logger) {
  self.getValueRef().output(logger)
}

///|
/// Individual LLVM fast-math promises for floating-point operations.
///
/// Violating a selected promise can permit transformations that change program
/// results. These flags are stronger than ordinary optimization hints.
pub(all) enum FastMathFlags {
  /// Permits reassociation of floating-point expressions.
  AllowReassoc
  /// Promises operands and results are never NaN.
  NoNaNs
  /// Promises operands and results are never positive or negative infinity.
  NoInfs
  /// Permits treating positive and negative zero as interchangeable.
  NoSignedZeros
  /// Permits reciprocal-based transformations that may reduce precision.
  AllowReciprocal
  /// Permits contraction such as forming a fused multiply-add.
  AllowContract
  /// Permits substituting approximate implementations of math functions.
  ApproxFunc
}

///|
/// Converts a safe fast-math flag to the corresponding LLVM-C bit flag.
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
/// Integer comparison predicates.
///
/// Equality predicates ignore signedness. Relational predicates explicitly use
/// signed (`S*`) or unsigned (`U*`) integer interpretation.
pub(all) enum IntPredicate {
  /// Equal bit patterns.
  EQ
  /// Unequal bit patterns.
  NE
  /// Signed greater than.
  SGT
  /// Signed greater than or equal.
  SGE
  /// Signed less than.
  SLT
  /// Signed less than or equal.
  SLE
  /// Unsigned greater than.
  UGT
  /// Unsigned greater than or equal.
  UGE
  /// Unsigned less than.
  ULT
  /// Unsigned less than or equal.
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
/// Module-anchored integer comparison instruction producing `i1` or an `i1`
/// vector.
pub struct ICmpInst {
  priv value : ModuleAnchoredValue
}

///|
fn ICmpInst::from_raw(value_ref : ValueRef, owner_module : Module) -> ICmpInst {
  ICmpInst::{ value: ModuleAnchoredValue::new(value_ref, owner_module) }
}

///|
fn ICmpInst::get_module(self : ICmpInst) -> Module {
  self.value.get_module()
}

///|
/// Returns the comparison's signed, unsigned, or equality predicate.
pub fn ICmpInst::getPredicate(self : Self) -> IntPredicate {
  @unsafe.llvm_get_icmp_predicate(self.getValueRef())
  |> IntPredicate::from_llvm_int_predicate
}

///|
/// Exposes the borrowed LLVM value handle.
pub impl Value for ICmpInst with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::ICmpInst`.
pub impl Value for ICmpInst with fn asValueEnum(self) -> ValueEnum {
  ICmpInst(self)
}

///|
/// Classifies this wrapper as `InstructionEnum::ICmpInst`.
pub impl Instruction for ICmpInst with fn asInstEnum(self) -> InstructionEnum {
  ICmpInst(self)
}

///|
/// Allows insertion immediately before this instruction.
pub impl InsertPoint for ICmpInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
/// Writes this integer comparison using LLVM syntax.
pub impl Show for ICmpInst with fn output(self, logger) {
  self.getValueRef().output(logger)
}

// =======================================================
// FCmpInst
// =======================================================

///|
/// Floating-point comparison predicates with explicit NaN behavior.
///
/// Ordered predicates (`O*`) are false if either operand is NaN. Unordered
/// predicates (`U*`) are true if either operand is NaN.
pub(all) enum FloatPredicate {
  /// Ordered and equal.
  OEQ
  /// Ordered and greater than.
  OGT
  /// Ordered and greater than or equal.
  OGE
  /// Ordered and less than.
  OLT
  /// Ordered and less than or equal.
  OLE
  /// Ordered and not equal.
  ONE
  /// Ordered: neither operand is NaN.
  ORD
  /// Unordered or equal.
  UEQ
  /// Unordered or greater than.
  UGT
  /// Unordered or greater than or equal.
  UGE
  /// Unordered or less than.
  ULT
  /// Unordered or less than or equal.
  ULE
  /// Unordered or not equal.
  UNE
  /// Unordered: at least one operand is NaN.
  UNO
  /// Always true, including for NaN operands.
  True
  /// Always false, including for NaN operands.
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
/// Module-anchored floating comparison instruction producing `i1` or an `i1`
/// vector.
pub struct FCmpInst {
  priv value : ModuleAnchoredValue
}

///|
fn FCmpInst::from_raw(value_ref : ValueRef, owner_module : Module) -> FCmpInst {
  FCmpInst::{ value: ModuleAnchoredValue::new(value_ref, owner_module) }
}

///|
fn FCmpInst::get_module(self : FCmpInst) -> Module {
  self.value.get_module()
}

///|
/// Returns the predicate, including its ordered/unordered NaN behavior.
pub fn FCmpInst::getPredicate(self : Self) -> FloatPredicate {
  @unsafe.llvm_get_fcmp_predicate(self.getValueRef())
  |> FloatPredicate::from_llvm_float_predicate
}

///|
/// Exposes the borrowed LLVM value handle.
pub impl Value for FCmpInst with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::FCmpInst`.
pub impl Value for FCmpInst with fn asValueEnum(self) -> ValueEnum {
  FCmpInst(self)
}

///|
/// Classifies this wrapper as `InstructionEnum::FCmpInst`.
pub impl Instruction for FCmpInst with fn asInstEnum(self) -> InstructionEnum {
  FCmpInst(self)
}

///|
/// Allows insertion immediately before this instruction.
pub impl InsertPoint for FCmpInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
/// Writes this floating comparison using LLVM syntax.
pub impl Show for FCmpInst with fn output(self, logger) {
  self.getValueRef().output(logger)
}

// =======================================================
// GetElementPtrInst
// =======================================================

///|
/// Module-anchored get-element-pointer instruction.
///
/// GEP computes an address by traversing a source element type; it does not
/// access memory. LLVM 19 pointers remain opaque, so the source element type is
/// stored on the instruction rather than recovered from the pointer type.
pub struct GetElementPtrInst {
  priv value : ModuleAnchoredValue
}

///|
fn GetElementPtrInst::from_raw(
  value_ref : ValueRef,
  owner_module : Module,
) -> GetElementPtrInst {
  GetElementPtrInst::{
    value: ModuleAnchoredValue::new(value_ref, owner_module),
  }
}

///|
fn GetElementPtrInst::get_module(self : GetElementPtrInst) -> Module {
  self.value.get_module()
}

///|
/// Returns whether this GEP carries LLVM's `inbounds` promise.
pub fn GetElementPtrInst::isInBounds(self : GetElementPtrInst) -> Bool {
  @unsafe.llvm_is_in_bounds(self.getValueRef())
}

///|
/// Adds LLVM's `inbounds` promise to this GEP.
///
/// **Preconditions:** The pointer arithmetic must satisfy LLVM's complete
/// `inbounds` rules for every execution. Violations can produce poison and lead
/// to undefined behavior; this is not merely an optimization hint.
///
/// **Side Effects:** Mutates the instruction's semantic flags.
pub fn GetElementPtrInst::setInBounds(self : GetElementPtrInst) -> Unit {
  @unsafe.llvm_set_is_in_bounds(self.getValueRef(), true)
}

///|
/// Removes the `inbounds` promise from this GEP.
///
/// **Side Effects:** Mutates the instruction and prevents optimizations from
/// assuming the stronger in-bounds contract.
pub fn GetElementPtrInst::removeInBounds(self : GetElementPtrInst) -> Unit {
  @unsafe.llvm_set_is_in_bounds(self.getValueRef(), false)
}

///|
/// Returns the explicit source element type traversed by this GEP.
///
/// **Lifecycle:** The returned type is owned by the module's context.
pub fn GetElementPtrInst::getSourceElementType(
  self : GetElementPtrInst,
) -> &Type {
  let typeref = @unsafe.llvm_get_gep_source_element_type(self.getValueRef())
  initAbstractType(typeref, self.get_module().getContext())
}

///|
/// Exposes the borrowed LLVM value handle.
pub impl Value for GetElementPtrInst with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
}

///|
/// Classifies this wrapper as `ValueEnum::GetElementPtrInst`.
pub impl Value for GetElementPtrInst with fn asValueEnum(self) -> ValueEnum {
  GetElementPtrInst(self)
}

///|
/// Classifies this wrapper as `InstructionEnum::GetElementPtrInst`.
pub impl Instruction for GetElementPtrInst with fn asInstEnum(self) -> InstructionEnum {
  GetElementPtrInst(self)
}

///|
/// Allows insertion immediately before this instruction.
pub impl InsertPoint for GetElementPtrInst with fn asInsertPtEnum(self) {
  Instruction(self as &Instruction)
}

///|
/// Writes this GEP instruction using LLVM syntax.
pub impl Show for GetElementPtrInst with fn output(self, logger) {
  self.getValueRef().output(logger)
}

// =======================================================
// SelectInst
// =======================================================

///|
pub struct SelectInst {
  priv value : ModuleAnchoredValue
}

///|
fn SelectInst::from_raw(
  value_ref : ValueRef,
  owner_module : Module,
) -> SelectInst {
  SelectInst::{ value: ModuleAnchoredValue::new(value_ref, owner_module) }
}

///|
fn SelectInst::get_module(self : SelectInst) -> Module {
  self.value.get_module()
}

///|
pub impl Value for SelectInst with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
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
  self.getValueRef().output(logger)
}

// =======================================================
// ExtractValueInst
// =======================================================

///|
pub struct ExtractValueInst {
  priv value : ModuleAnchoredValue
}

///|
fn ExtractValueInst::from_raw(
  value_ref : ValueRef,
  owner_module : Module,
) -> ExtractValueInst {
  ExtractValueInst::{ value: ModuleAnchoredValue::new(value_ref, owner_module) }
}

///|
fn ExtractValueInst::get_module(self : ExtractValueInst) -> Module {
  self.value.get_module()
}

///|
pub impl Value for ExtractValueInst with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
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
  self.getValueRef().output(logger)
}

// =======================================================
// InsertValueInst
// =======================================================

///|
pub struct InsertValueInst {
  priv value : ModuleAnchoredValue
}

///|
fn InsertValueInst::from_raw(
  value_ref : ValueRef,
  owner_module : Module,
) -> InsertValueInst {
  InsertValueInst::{ value: ModuleAnchoredValue::new(value_ref, owner_module) }
}

///|
fn InsertValueInst::get_module(self : InsertValueInst) -> Module {
  self.value.get_module()
}

///|
pub impl Value for InsertValueInst with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
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
  self.getValueRef().output(logger)
}

// =======================================================
// PHINode
// =======================================================

///|
pub struct PHINode {
  priv value : ModuleAnchoredValue
}

///|
fn PHINode::from_raw(value_ref : ValueRef, owner_module : Module) -> PHINode {
  PHINode::{ value: ModuleAnchoredValue::new(value_ref, owner_module) }
}

///|
fn PHINode::get_module(self : PHINode) -> Module {
  self.value.get_module()
}

///|
pub fn PHINode::addIncoming(
  self : PHINode,
  value : &Value,
  block : BasicBlock,
) -> Unit {
  @unsafe.llvm_add_incoming(self.getValueRef(), [value.getValueRef()], [
    block.get_unsafe_ref(),
  ])
}

///|
pub fn PHINode::countIncoming(self : PHINode) -> Int {
  @unsafe.llvm_count_incoming(self.getValueRef()).reinterpret_as_int()
}

// TODO:
//pub fn PHINOde::getIncomingValue(
//  self : PHINode,
//  idx : Int
//) -> &Value? {
//  when(
//    idx >= 0 && idx < self.countIncoming(),
//    () => { @unsafe.llvm_get_incoming_value(self.getValueRef(), idx.reinterpret_as_uint())) }
//  )
//}

///|
pub fn PHINode::getIncomingBlock(self : PHINode, idx : Int) -> BasicBlock? {
  when(idx >= 0 && idx < self.countIncoming(), () => {
    BasicBlock::from_raw(
      @unsafe.llvm_get_incoming_block(
        self.getValueRef(),
        idx.reinterpret_as_uint(),
      ),
      self.get_module(),
    )
  })
}

///|
pub impl Value for PHINode with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
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
  self.getValueRef().output(logger)
}

// =======================================================
// ReturnInst
// =======================================================

///|
pub struct ReturnInst {
  priv value : ModuleAnchoredValue
}

///|
fn ReturnInst::from_raw(
  value_ref : ValueRef,
  owner_module : Module,
) -> ReturnInst {
  ReturnInst::{ value: ModuleAnchoredValue::new(value_ref, owner_module) }
}

///|
fn ReturnInst::get_module(self : ReturnInst) -> Module {
  self.value.get_module()
}

///|
pub impl Value for ReturnInst with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
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
  self.getValueRef().output(logger)
}

// =======================================================
// BranchInst
// =======================================================

///|
pub struct BranchInst {
  priv value : ModuleAnchoredValue
}

///|
fn BranchInst::from_raw(
  value_ref : ValueRef,
  owner_module : Module,
) -> BranchInst {
  BranchInst::{ value: ModuleAnchoredValue::new(value_ref, owner_module) }
}

///|
fn BranchInst::get_module(self : BranchInst) -> Module {
  self.value.get_module()
}

///|
pub fn BranchInst::isConditional(self : BranchInst) -> Bool {
  @unsafe.llvm_is_conditional(self.getValueRef())
}

///|
pub suberror InValidOperation {
  InValidOperation(String)
}

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
      $| Misuse `BranchInst::setCondition`, Instruction is not conditional.
    raise InValidOperation(msg)
  }
  @unsafe.llvm_set_condition(self.getValueRef(), cond.getValueRef())
}

///|
pub fn BranchInst::getNumSuccessors(self : BranchInst) -> Int {
  @unsafe.llvm_get_num_successors(self.getValueRef()).reinterpret_as_int()
}

///|
pub fn BranchInst::getSuccessor(self : BranchInst, idx : Int) -> BasicBlock? {
  when(idx >= 0 && idx < self.getNumSuccessors(), () => {
    BasicBlock::from_raw(
      @unsafe.llvm_get_successor(self.getValueRef(), idx.reinterpret_as_uint()),
      self.get_module(),
    )
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
      $| Misuse `BranchInst::setSuccessor`, Index out of bounds.
    raise IndexOutOfBounds(msg)
  }
  @unsafe.llvm_set_successor(
    self.getValueRef(),
    idx.reinterpret_as_uint(),
    block.get_unsafe_ref(),
  )
}

///|
pub impl Value for BranchInst with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
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
  self.getValueRef().output(logger)
}

// =======================================================
// SwitchInst
// =======================================================

///|
pub suberror SwitchInstError {
  InValidSwitchCaseValue(String)
}

///|
pub struct SwitchInst {
  priv value : ModuleAnchoredValue
}

///|
fn SwitchInst::from_raw(
  value_ref : ValueRef,
  owner_module : Module,
) -> SwitchInst {
  SwitchInst::{ value: ModuleAnchoredValue::new(value_ref, owner_module) }
}

///|
fn SwitchInst::get_module(self : SwitchInst) -> Module {
  self.value.get_module()
}

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
  @unsafe.llvm_add_case(
    self.getValueRef(),
    on_val.getValueRef(),
    dest.get_unsafe_ref(),
  )
}

///|
pub fn SwitchInst::getNumSuccessors(self : Self) -> Int {
  @unsafe.llvm_get_num_successors(self.getValueRef()).reinterpret_as_int()
}

///|
pub fn SwitchInst::getSuccessor(self : Self, idx : Int) -> BasicBlock? {
  when(idx >= 0 && idx < self.getNumSuccessors(), () => {
    BasicBlock::from_raw(
      @unsafe.llvm_get_successor(self.getValueRef(), idx.reinterpret_as_uint()),
      self.get_module(),
    )
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
      $| Misuse `BranchInst::setSuccessor`, Index out of bounds.
    raise IndexOutOfBounds(msg)
  }
  @unsafe.llvm_set_successor(
    self.getValueRef(),
    idx.reinterpret_as_uint(),
    block.get_unsafe_ref(),
  )
}

///|
pub impl Value for SwitchInst with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
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
  self.getValueRef().output(logger)
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
}

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
pub struct CallInst {
  priv value : ModuleAnchoredValue
}

///|
fn CallInst::from_raw(value_ref : ValueRef, owner_module : Module) -> CallInst {
  CallInst::{ value: ModuleAnchoredValue::new(value_ref, owner_module) }
}

///|
fn CallInst::get_module(self : CallInst) -> Module {
  self.value.get_module()
}

///|
pub fn CallInst::isTailCall(self : CallInst) -> Bool {
  @unsafe.llvm_is_tail_call(self.getValueRef())
}

///|
pub fn CallInst::setTailCall(self : CallInst) -> Unit {
  @unsafe.llvm_set_tail_call(self.getValueRef(), true)
}

///|
pub fn CallInst::removeTailCall(self : CallInst) -> Unit {
  @unsafe.llvm_set_tail_call(self.getValueRef(), false)
}

///|
pub fn CallInst::getTailCallKind(self : CallInst) -> TailCallKind {
  @unsafe.llvm_get_tail_call_kind(self.getValueRef()) |> TailCallKind::from_llvm
}

///|
pub fn CallInst::setTailCallKind(self : CallInst, kind : TailCallKind) -> Unit {
  @unsafe.llvm_set_tail_call_kind(self.getValueRef(), kind.to_llvm())
}

///|
pub impl Value for CallInst with fn getValueRef(self) -> ValueRef {
  self.value.get_unsafe_ref()
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
  self.getValueRef().output(logger)
}
