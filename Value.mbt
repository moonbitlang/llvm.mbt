// =======================================================
// ValueRef
// =======================================================

///|
pub typealias @unsafe.LLVMValueRef as ValueRef

// =======================================================
// Value
// =======================================================

///|
pub enum ValueEnum {
  Function(Function)
  /// Base class for constants with no operands.
  ///
  /// These constants have no operands; they represent their data directly.
  /// Since they can be in use by unrelated modules (and are never based on
  /// GlobalValues), it never makes sense to RAUW them.
  ///
  /// These do not have use lists. It is illegal to inspect the uses. These behave
  /// as if they have no uses (i.e. use_empty() is always true).
  ConstantInt(ConstantInt)
  ConstantFP(ConstantFP)
  ConstantPointerNull(ConstantPointerNull)
  ConstantArray(ConstantArray)
  ConstantVector(ConstantVector)
  ConstantStruct(ConstantStruct)
  UndefValue(UndefValue)
  PoisonValue(PoisonValue)
  //
  //BlockAddress(BlockAddress)

  Argument(Argument)
  BasicBlock(BasicBlock)
  //
  AllocaInst(AllocaInst)
  LoadInst(LoadInst)
  StoreInst(StoreInst)
  CastInst(CastInst)
  UnaryInst(UnaryInst)
  BinaryInst(BinaryInst)
  CmpInst(CmpInst)
  GetElementPtrInst(GetElementPtrInst)
  SelectInst(SelectInst)
  ExtractValueInst(ExtractValueInst)
  InsertValueInst(InsertValueInst)
  PHINode(PHINode)
  ReturnInst(ReturnInst)
  BranchInst(BranchInst)
  SwitchInst(SwitchInst)
  CallInst(CallInst)
}

///|
pub trait Value: Show {
  getValueRef(Self) -> ValueRef
  asValueEnum(Self) -> ValueEnum

  // All values are typed, get the type of this value.
  getType(Self) -> &Type = _

  // All values hold a context through their type.
  getContext(Self) -> Context = _
  getValueName(Self) -> String? = _
  setValueName(Self, String) -> Unit = _

  //
  replaceAllUsesWith(Self, other : &Value) -> Unit = _
}

///|
impl Value with getType(self) {
  let typeref = @unsafe.llvm_type_of(self.getValueRef())
  initAbstractType(typeref)
}

///|
impl Value with getContext(self) {
  self.getType().getContext()
}

///|
impl Value with getValueName(self) {
  let name = @unsafe.llvm_get_value_name(self.getValueRef())
  unless(name.is_empty(), () => name)
}

///|
impl Value with setValueName(self, name : String) {
  @unsafe.llvm_set_value_name(self.getValueRef(), name)
}

///|
impl Value with replaceAllUsesWith(self, other : &Value) {
  @unsafe.llvm_replace_all_uses_with(self.getValueRef(), other.getValueRef())
}

// ==================================================
// Constant
// ==================================================

///|
pub trait Constant: Value {
  asConstEnum(Self) -> ConstantEnum
}

///|
pub enum ConstantEnum {
  ConstantInt(ConstantInt)
  ConstantFP(ConstantFP)
  ConstantPointerNull(ConstantPointerNull)
  ConstantArray(ConstantArray)
  ConstantStruct(ConstantStruct)
  ConstantVector(ConstantVector)
  UndefValue(UndefValue)
  PoisonValue(PoisonValue)
}

// =======================================================
// Instruction
// =======================================================

///|
pub trait Instruction: Value {
  asInstEnum(Self) -> InstructionEnum
  getParentBasicBlock(Self) -> BasicBlock? = _
}

///|
impl Instruction with getParentBasicBlock(self) {
  let valuref = self.getValueRef()
  let bb_ref = @unsafe.llvm_get_instruction_parent(valuref)
  match @unsafe.llvm_bb_is_null(bb_ref) {
    true => None
    false => Some(BasicBlock(bb_ref))
  }
}

///|
pub enum InstructionEnum {
  AllocaInst(AllocaInst)
  LoadInst(LoadInst)
  StoreInst(StoreInst)
  CastInst(CastInst)
  UnaryInst(UnaryInst)
  BinaryInst(BinaryInst)
  CmpInst(CmpInst)
  GetElementPtrInst(GetElementPtrInst)
  SelectInst(SelectInst)
  ExtractValueInst(ExtractValueInst)
  InsertValueInst(InsertValueInst)
  PHINode(PHINode)
  ReturnInst(ReturnInst)
  BranchInst(BranchInst)
  SwitchInst(SwitchInst)
  CallInst(CallInst)
}
