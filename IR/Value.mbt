// =======================================================
// ValueRef
// =======================================================

///|
pub type ValueRef = @unsafe.LLVMValueRef

// =======================================================
// Value
// =======================================================

///|
pub enum ValueEnum {
  Function(Function)
  GlobalVariable(GlobalVariable)
  GlobalConstant(GlobalConstant)
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
  ICmpInst(ICmpInst)
  FCmpInst(FCmpInst)
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
  fn getValueRef(Self) -> ValueRef
  fn asValueEnum(Self) -> ValueEnum

  // All values are typed, get the type of this value.
  fn getType(Self) -> &Type = _

  // All values hold a context through their type.
  fn getContext(Self) -> Context = _
  fn getValueName(Self) -> String? = _
  fn setValueName(Self, String) -> Unit = _

  //
  fn replaceAllUsesWith(Self, other : &Value) -> Unit = _
  fn tryAsConstant(Self) -> &Constant? = _
  fn tryAsConstantEnum(Self) -> ConstantEnum? = _
}

///|
impl Value with fn getType(self) {
  let typeref = @unsafe.llvm_type_of(self.getValueRef())
  initAbstractType(typeref)
}

///|
impl Value with fn getContext(self) {
  self.getType().getContext()
}

///|
impl Value with fn getValueName(self) {
  let name = @unsafe.llvm_get_value_name(self.getValueRef())
  unless(name.is_empty(), () => name)
}

///|
impl Value with fn setValueName(self, name : String) {
  @unsafe.llvm_set_value_name(self.getValueRef(), name)
}

///|
impl Value with fn replaceAllUsesWith(self, other : &Value) {
  @unsafe.llvm_replace_all_uses_with(self.getValueRef(), other.getValueRef())
}

///|
impl Value with fn tryAsConstant(self) {
  match self.asValueEnum() {
    ConstantInt(c) => Some(c as &Constant)
    ConstantFP(c) => Some(c)
    ConstantPointerNull(c) => Some(c)
    ConstantArray(c) => Some(c)
    ConstantStruct(c) => Some(c)
    ConstantVector(c) => Some(c)
    UndefValue(c) => Some(c)
    PoisonValue(c) => Some(c)
    _ => None
  }
}

///|
impl Value with fn tryAsConstantEnum(self) {
  match self.asValueEnum() {
    ConstantInt(c) => Some(ConstantEnum::ConstantInt(c))
    ConstantFP(c) => Some(ConstantEnum::ConstantFP(c))
    ConstantPointerNull(c) => Some(ConstantEnum::ConstantPointerNull(c))
    ConstantArray(c) => Some(ConstantEnum::ConstantArray(c))
    ConstantStruct(c) => Some(ConstantEnum::ConstantStruct(c))
    ConstantVector(c) => Some(ConstantEnum::ConstantVector(c))
    UndefValue(c) => Some(ConstantEnum::UndefValue(c))
    PoisonValue(c) => Some(ConstantEnum::PoisonValue(c))
    _ => None
  }
}

// ==================================================
// Constant
// ==================================================

///|
pub trait Constant: Value {
  fn asConstantEnum(Self) -> ConstantEnum
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
  fn asInstEnum(Self) -> InstructionEnum
  fn getParentBasicBlock(Self) -> BasicBlock? = _
  fn getNextInst(Self) -> &Instruction? = _
  fn getPrevInst(Self) -> &Instruction? = _
  fn removeFromParent(Self) -> Unit = _
  fn eraseFromParent(Self) -> Unit = _
  fn getNumArgOperands(Self) -> Int = _
}

///|
impl Instruction with fn getParentBasicBlock(self) {
  let valuref = self.getValueRef()
  let bb_ref = @unsafe.llvm_get_instruction_parent(valuref)
  match @unsafe.llvm_bb_is_null(bb_ref) {
    true => None
    false => Some(BasicBlock(bb_ref))
  }
}

///|
fn initInstruction(valueref : ValueRef) -> &Instruction {
  fn is_binary_opcode(opcode : @unsafe.LLVMOpcode) -> Bool {
    match opcode {
      LLVMAdd
      | LLVMSub
      | LLVMMul
      | LLVMSDiv
      | LLVMSRem
      | LLVMUDiv
      | LLVMURem
      | LLVMShl
      | LLVMLShr
      | LLVMAShr
      | LLVMAnd
      | LLVMOr
      | LLVMXor => true
      _ => false
    }
  }

  fn is_cast_opcode(opcode : @unsafe.LLVMOpcode) -> Bool {
    match opcode {
      LLVMBitCast
      | LLVMAddrSpaceCast
      | LLVMTrunc
      | LLVMZExt
      | LLVMSExt
      | LLVMFPToUI
      | LLVMFPToSI
      | LLVMUIToFP
      | LLVMSIToFP
      | LLVMPtrToInt
      | LLVMIntToPtr => true
      _ => false
    }
  }

  let opcode = @unsafe.llvm_get_instruction_opcode(valueref)
  match opcode {
    LLVMAlloca => AllocaInst::AllocaInst(valueref) as &Instruction
    LLVMLoad => LoadInst::LoadInst(valueref)
    LLVMStore => StoreInst::StoreInst(valueref)
    LLVMGetElementPtr => GetElementPtrInst::GetElementPtrInst(valueref)
    LLVMFNeg => UnaryInst::UnaryInst(valueref)
    LLVMICmp => ICmpInst::ICmpInst(valueref)
    LLVMFCmp => FCmpInst::FCmpInst(valueref)
    LLVMSelect => SelectInst::SelectInst(valueref)
    LLVMExtractValue => ExtractValueInst::ExtractValueInst(valueref)
    LLVMInsertValue => InsertValueInst::InsertValueInst(valueref)
    LLVMPHI => PHINode::PHINode(valueref)
    LLVMRet => ReturnInst::ReturnInst(valueref)
    LLVMBr => BranchInst::BranchInst(valueref)
    LLVMSwitch => SwitchInst::SwitchInst(valueref)
    LLVMCall => CallInst::CallInst(valueref)
    opcode if is_binary_opcode(opcode) => BinaryInst::BinaryInst(valueref)
    opcode if is_cast_opcode(opcode) => CastInst::CastInst(valueref)
    _ => {
      println(
        "ICE: `initInstruction` get unknown instruction opcode: \{opcode}",
      )
      panic()
    }
  }
}

///|
impl Instruction with fn getNextInst(self) {
  let valueref = self.getValueRef()
  let next_ref = @unsafe.llvm_get_next_instruction(valueref)
  unless(@unsafe.llvm_value_ref_is_null(next_ref), () => {
    initInstruction(next_ref)
  })
}

///|
impl Instruction with fn getPrevInst(self) {
  let valueref = self.getValueRef()
  let prev_ref = @unsafe.llvm_get_previous_instruction(valueref)
  unless(@unsafe.llvm_value_ref_is_null(prev_ref), () => {
    initInstruction(prev_ref)
  })
}

///|
///
/// After `remove` the instruction is no longer in the parent basic block.
/// But it is still in the module, so it can be reused.
impl Instruction with fn removeFromParent(self) {
  @unsafe.llvm_instruction_remove_from_parent(self.getValueRef())
}

///|
impl Instruction with fn eraseFromParent(self) {
  @unsafe.llvm_instruction_erase_from_parent(self.getValueRef())
}

///|
impl Instruction with fn getNumArgOperands(self) {
  @unsafe.llvm_get_num_arg_operands(self.getValueRef()).reinterpret_as_int()
}

///|
pub enum InstructionEnum {
  AllocaInst(AllocaInst)
  LoadInst(LoadInst)
  StoreInst(StoreInst)
  CastInst(CastInst)
  UnaryInst(UnaryInst)
  BinaryInst(BinaryInst)
  ICmpInst(ICmpInst)
  FCmpInst(FCmpInst)
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

// =======================================================
// GlobalValue
// =======================================================

///|
pub trait GlobalValue: Value {
  fn asGlobalEnum(Self) -> GlobalEnum
  fn getLinkage(Self) -> Linkage = _
  fn setLinkage(Self, Linkage) -> Unit = _
  fn getUnnamedAddr(Self) -> UnnamedAddr = _
  fn setUnnamedAddr(Self, UnnamedAddr) -> Unit = _
  fn removeUnnamedAddr(Self) -> Unit = _
}

///|
pub enum GlobalEnum {
  Function(Function)
  GlobalVariable(GlobalVariable)
  GlobalConstant(GlobalConstant)
}

///|
impl GlobalValue with fn getLinkage(self) {
  let linkage = @unsafe.llvm_get_linkage(self.getValueRef())
  Linkage::from_llvm_linkage(linkage)
}

///|
impl GlobalValue with fn setLinkage(self, linkage : Linkage) {
  let llvm_linkage = linkage.to_llvm_linkage()
  @unsafe.llvm_set_linkage(self.getValueRef(), llvm_linkage)
}

///|
impl GlobalValue with fn getUnnamedAddr(self) {
  let ua = @unsafe.llvm_get_unnamed_address(self.getValueRef())
  UnnamedAddr::from_llvm_unnamed_addr(ua)
}

///|
impl GlobalValue with fn setUnnamedAddr(self, ua : UnnamedAddr) {
  let llvm_ua = ua.to_llvm_unnamed_addr()
  @unsafe.llvm_set_unnamed_address(self.getValueRef(), llvm_ua)
}

///|
impl GlobalValue with fn removeUnnamedAddr(self) {
  @unsafe.llvm_set_unnamed_address(
    self.getValueRef(),
    @unsafe.LLVMNoUnnamedAddr,
  )
}
