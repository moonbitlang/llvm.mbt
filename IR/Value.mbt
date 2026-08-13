// =======================================================
// ValueRef
// =======================================================

///|
/// Raw borrowed LLVM value handle used only inside the IR implementation.
type ValueRef = @raw.LLVMValueRef

// =======================================================
// Value
// =======================================================

///|
/// Closed dynamic classification of values supported by the safe API.
pub enum ValueEnum {
  /// Module-owned function definition or declaration.
  Function(Function)
  /// Module-owned mutable global variable.
  GlobalVariable(GlobalVariable)
  /// Module-owned constant global definition.
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
  /// Context-owned floating-point constant.
  ConstantFP(ConstantFP)
  /// Context-owned null pointer constant.
  ConstantPointerNull(ConstantPointerNull)
  /// Context-owned array aggregate constant.
  ConstantArray(ConstantArray)
  /// Context-owned vector constant.
  ConstantVector(ConstantVector)
  /// Context-owned struct aggregate constant.
  ConstantStruct(ConstantStruct)
  /// Context-owned LLVM constant expression.
  ConstantExpr(ConstantExpr)
  /// Context-owned undefined-value constant.
  UndefValue(UndefValue)
  /// Context-owned poison-value constant.
  PoisonValue(PoisonValue)
  //
  //BlockAddress(BlockAddress)

  /// Module-anchored function argument.
  Argument(Argument)
  /// Module-anchored basic block.
  BasicBlock(BasicBlock)
  //
  /// Stack-allocation instruction.
  AllocaInst(AllocaInst)
  /// Memory-load instruction.
  LoadInst(LoadInst)
  /// Memory-store instruction.
  StoreInst(StoreInst)
  /// Value-conversion instruction.
  CastInst(CastInst)
  /// Unary arithmetic instruction.
  UnaryInst(UnaryInst)
  /// Binary arithmetic or bitwise instruction.
  BinaryInst(BinaryInst)
  /// Integer comparison instruction.
  ICmpInst(ICmpInst)
  /// Floating-point comparison instruction.
  FCmpInst(FCmpInst)
  /// Get-element-pointer instruction.
  GetElementPtrInst(GetElementPtrInst)
  /// Conditional value-selection instruction.
  SelectInst(SelectInst)
  /// Aggregate element-extraction instruction.
  ExtractValueInst(ExtractValueInst)
  /// Aggregate element-insertion instruction.
  InsertValueInst(InsertValueInst)
  /// Static single-assignment phi node.
  PHINode(PHINode)
  /// Function-return terminator.
  ReturnInst(ReturnInst)
  /// Conditional or unconditional branch terminator.
  BranchInst(BranchInst)
  /// Multi-way switch terminator.
  SwitchInst(SwitchInst)
  /// Function-call instruction.
  CallInst(CallInst)
}

///|
/// Common interface for LLVM values represented by the safe API.
///
/// **Implementor contract:** `asValueEnum`, `getType`, and `getContext` must all
/// describe the same live LLVM value. Implementations must preserve the correct
/// context or module ownership anchor.
///
/// **Lifecycle:** Constants are anchored directly to a context. Functions,
/// globals, arguments, basic blocks, and instructions are anchored to a module.
/// Mutation APIs that erase IR can invalidate wrappers before their anchor is
/// disposed.
pub trait Value: Show {
  /// Returns the concrete dynamic classification of this value.
  fn asValueEnum(Self) -> ValueEnum

  /// Returns this value's context-owned LLVM type.
  fn getType(Self) -> &Type = _

  /// Returns the context associated with this value or its owning module.
  fn getContext(Self) -> Context = _

  /// Returns the optional LLVM value name.
  ///
  /// **Errors:** Raises `StringError::MalformedUtf8` if LLVM returns a name that
  /// is not valid UTF-8.
  fn getValueName(Self) -> String? raise StringError = _

  /// Sets the LLVM value name.
  ///
  /// **Errors:** Raises `StringError::ContainsNul` when the name contains an
  /// embedded NUL byte.
  ///
  /// **Side Effects:** Mutates the name observed by all wrappers of this value
  /// and by textual IR output.
  fn setValueName(Self, String) -> Unit raise StringError = _

  /// Replaces every use of this value with `other`.
  ///
  /// **Preconditions:** Both values must have exactly the same LLVM type and
  /// belong to a compatible context/module. The safe layer does not validate
  /// these conditions before calling LLVM.
  ///
  /// **Side Effects:** Mutates every current use site; it does not erase this
  /// value itself.
  fn replaceAllUsesWith(Self, other : &Value) -> Unit = _

  /// Downcasts to the constant trait, returning `None` for non-constants.
  fn tryAsConstant(Self) -> &Constant? = _

  /// Returns a concrete constant classification, or `None` for non-constants.
  fn tryAsConstantEnum(Self) -> ConstantEnum? = _
}

///|
fn &Value::get_raw_value_ref(self : &Value) -> ValueRef {
  match self.asValueEnum() {
    Function(value) => value.get_raw_value_ref()
    GlobalVariable(value) => value.get_raw_value_ref()
    GlobalConstant(value) => value.get_raw_value_ref()
    ConstantInt(value) => value.get_raw_value_ref()
    ConstantFP(value) => value.get_raw_value_ref()
    ConstantPointerNull(value) => value.get_raw_value_ref()
    ConstantArray(value) => value.get_raw_value_ref()
    ConstantVector(value) => value.get_raw_value_ref()
    ConstantStruct(value) => value.get_raw_value_ref()
    ConstantExpr(value) => value.get_raw_value_ref()
    UndefValue(value) => value.get_raw_value_ref()
    PoisonValue(value) => value.get_raw_value_ref()
    Argument(value) => value.get_raw_value_ref()
    BasicBlock(value) => value.get_raw_value_ref()
    AllocaInst(value) => value.get_raw_value_ref()
    LoadInst(value) => value.get_raw_value_ref()
    StoreInst(value) => value.get_raw_value_ref()
    CastInst(value) => value.get_raw_value_ref()
    UnaryInst(value) => value.get_raw_value_ref()
    BinaryInst(value) => value.get_raw_value_ref()
    ICmpInst(value) => value.get_raw_value_ref()
    FCmpInst(value) => value.get_raw_value_ref()
    GetElementPtrInst(value) => value.get_raw_value_ref()
    SelectInst(value) => value.get_raw_value_ref()
    ExtractValueInst(value) => value.get_raw_value_ref()
    InsertValueInst(value) => value.get_raw_value_ref()
    PHINode(value) => value.get_raw_value_ref()
    ReturnInst(value) => value.get_raw_value_ref()
    BranchInst(value) => value.get_raw_value_ref()
    SwitchInst(value) => value.get_raw_value_ref()
    CallInst(value) => value.get_raw_value_ref()
  }
}

///|
impl Value with fn getType(self) {
  let typeref = @raw.llvm_type_of((self : &Value).get_raw_value_ref())
  initAbstractType(typeref, self.getContext())
}

///|
impl Value with fn getContext(self) {
  match self.asValueEnum() {
    Function(value) => value.get_module().getContext()
    GlobalVariable(value) => value.get_module().getContext()
    GlobalConstant(value) => value.get_module().getContext()
    ConstantInt(value) => value.getContext()
    ConstantFP(value) => value.getContext()
    ConstantPointerNull(value) => value.getContext()
    ConstantArray(value) => value.getContext()
    ConstantVector(value) => value.getContext()
    ConstantStruct(value) => value.getContext()
    ConstantExpr(value) => value.getContext()
    UndefValue(value) => value.getContext()
    PoisonValue(value) => value.getContext()
    Argument(value) => value.get_module().getContext()
    BasicBlock(value) => value.get_module().getContext()
    AllocaInst(value) => value.get_module().getContext()
    LoadInst(value) => value.get_module().getContext()
    StoreInst(value) => value.get_module().getContext()
    CastInst(value) => value.get_module().getContext()
    UnaryInst(value) => value.get_module().getContext()
    BinaryInst(value) => value.get_module().getContext()
    ICmpInst(value) => value.get_module().getContext()
    FCmpInst(value) => value.get_module().getContext()
    GetElementPtrInst(value) => value.get_module().getContext()
    SelectInst(value) => value.get_module().getContext()
    ExtractValueInst(value) => value.get_module().getContext()
    InsertValueInst(value) => value.get_module().getContext()
    PHINode(value) => value.get_module().getContext()
    ReturnInst(value) => value.get_module().getContext()
    BranchInst(value) => value.get_module().getContext()
    SwitchInst(value) => value.get_module().getContext()
    CallInst(value) => value.get_module().getContext()
  }
}

///|
impl Value with fn getValueName(self) raise StringError {
  let name = @raw.llvm_get_value_name((self : &Value).get_raw_value_ref()) catch {
    @utf8.Malformed(bytes) => raise MalformedUtf8(bytes.to_owned())
  }
  unless(name.is_empty(), () => name)
}

///|
impl Value with fn setValueName(self, name : String) raise StringError {
  guard !name.contains_code_unit(0) else { raise ContainsNul }
  @raw.llvm_set_value_name((self : &Value).get_raw_value_ref(), name)
}

///|
impl Value with fn replaceAllUsesWith(self, other : &Value) {
  @raw.llvm_replace_all_uses_with(
    (self : &Value).get_raw_value_ref(),
    other.get_raw_value_ref(),
  )
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
    ConstantExpr(c) => Some(c)
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
    ConstantExpr(c) => Some(ConstantEnum::ConstantExpr(c))
    UndefValue(c) => Some(ConstantEnum::UndefValue(c))
    PoisonValue(c) => Some(ConstantEnum::PoisonValue(c))
    _ => None
  }
}

// ==================================================
// Constant
// ==================================================

///|
/// Common interface for LLVM constants supported by the safe API.
///
/// **Implementor contract:** `asConstantEnum` must classify the same value as
/// the inherited `Value` methods.
pub trait Constant: Value {
  /// Returns the concrete constant classification.
  fn asConstantEnum(Self) -> ConstantEnum
}

///|
/// Closed classification of constants supported by the safe API.
pub enum ConstantEnum {
  /// Integer constant.
  ConstantInt(ConstantInt)
  /// Floating-point constant.
  ConstantFP(ConstantFP)
  /// Null pointer constant.
  ConstantPointerNull(ConstantPointerNull)
  /// Array aggregate constant.
  ConstantArray(ConstantArray)
  /// Struct aggregate constant.
  ConstantStruct(ConstantStruct)
  /// Vector constant.
  ConstantVector(ConstantVector)
  /// LLVM constant expression.
  ConstantExpr(ConstantExpr)
  /// Undefined-value constant.
  UndefValue(UndefValue)
  /// Poison-value constant.
  PoisonValue(PoisonValue)
}

// =======================================================
// Instruction
// =======================================================

///|
/// Common interface for module-owned LLVM instructions supported by this API.
///
/// **Implementor contract:** `asInstEnum` must classify the same instruction as
/// the inherited `Value` methods, and the wrapper must retain its owning module.
///
/// **Lifecycle:** `removeFromParent` detaches an instruction without destroying
/// it. `eraseFromParent` destroys the underlying LLVM instruction immediately;
/// the current safe layer cannot invalidate copied wrappers, so all aliases must
/// be treated as dangling after erasure.
pub trait Instruction: Value {
  /// Returns the concrete instruction classification.
  fn asInstEnum(Self) -> InstructionEnum

  /// Returns the current parent block, or `None` when detached.
  fn getParentBasicBlock(Self) -> BasicBlock? = _

  /// Returns the following instruction in the parent block, or `None` at the
  /// end or when detached.
  fn getNextInst(Self) -> &Instruction? = _

  /// Returns the preceding instruction in the parent block, or `None` at the
  /// beginning or when detached.
  fn getPrevInst(Self) -> &Instruction? = _

  /// Detaches this instruction from its parent block without destroying it.
  ///
  /// **Side Effects:** The block's instruction list and CFG may change. The
  /// instruction has no parent afterward.
  ///
  /// **Lifecycle:** Existing wrappers remain usable only for operations LLVM
  /// permits on detached instructions; the module anchor keeps the module alive
  /// but does not reinsert the instruction.
  fn removeFromParent(Self) -> Unit = _

  /// Removes and destroys this instruction.
  ///
  /// **Side Effects:** Mutates the parent block and destroys the native LLVM
  /// instruction.
  ///
  /// **Lifecycle:** This wrapper and every alias become dangling immediately.
  /// They must not be used again. The type system cannot currently enforce this
  /// restriction; see the Q-09 lifecycle limitation.
  fn eraseFromParent(Self) -> Unit = _

  /// Returns the number of call-argument operands for call-like instructions.
  ///
  /// **Preconditions:** LLVM defines this query only for applicable instruction
  /// kinds; the safe layer does not validate the dynamic kind.
  fn getNumArgOperands(Self) -> Int = _
}

///|
impl Instruction with fn getParentBasicBlock(self) {
  let valuref = (self : &Value).get_raw_value_ref()
  let bb_ref = @raw.llvm_get_instruction_parent(valuref)
  match @raw.llvm_bb_is_null(bb_ref) {
    true => None
    false => Some(BasicBlock::from_raw(bb_ref, get_instruction_module(self)))
  }
}

///|
fn initInstruction(valueref : ValueRef, owner_module : Module) -> &Instruction {
  fn is_binary_opcode(opcode : @raw.LLVMOpcode) -> Bool {
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

  fn is_cast_opcode(opcode : @raw.LLVMOpcode) -> Bool {
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

  let opcode = @raw.llvm_get_instruction_opcode(valueref)
  match opcode {
    LLVMAlloca => AllocaInst::from_raw(valueref, owner_module) as &Instruction
    LLVMLoad => LoadInst::from_raw(valueref, owner_module)
    LLVMStore => StoreInst::from_raw(valueref, owner_module)
    LLVMGetElementPtr => GetElementPtrInst::from_raw(valueref, owner_module)
    LLVMFNeg => UnaryInst::from_raw(valueref, owner_module)
    LLVMICmp => ICmpInst::from_raw(valueref, owner_module)
    LLVMFCmp => FCmpInst::from_raw(valueref, owner_module)
    LLVMSelect => SelectInst::from_raw(valueref, owner_module)
    LLVMExtractValue => ExtractValueInst::from_raw(valueref, owner_module)
    LLVMInsertValue => InsertValueInst::from_raw(valueref, owner_module)
    LLVMPHI => PHINode::from_raw(valueref, owner_module)
    LLVMRet => ReturnInst::from_raw(valueref, owner_module)
    LLVMBr => BranchInst::from_raw(valueref, owner_module)
    LLVMSwitch => SwitchInst::from_raw(valueref, owner_module)
    LLVMCall => CallInst::from_raw(valueref, owner_module)
    opcode if is_binary_opcode(opcode) =>
      BinaryInst::from_raw(valueref, owner_module)
    opcode if is_cast_opcode(opcode) =>
      CastInst::from_raw(valueref, owner_module)
    _ => {
      println(
        "ICE: `initInstruction` get unknown instruction opcode: \{opcode}",
      )
      panic()
    }
  }
}

///|
fn get_instruction_module(inst : &Instruction) -> Module {
  match inst.asInstEnum() {
    AllocaInst(inst) => inst.get_module()
    LoadInst(inst) => inst.get_module()
    StoreInst(inst) => inst.get_module()
    CastInst(inst) => inst.get_module()
    UnaryInst(inst) => inst.get_module()
    BinaryInst(inst) => inst.get_module()
    ICmpInst(inst) => inst.get_module()
    FCmpInst(inst) => inst.get_module()
    GetElementPtrInst(inst) => inst.get_module()
    SelectInst(inst) => inst.get_module()
    ExtractValueInst(inst) => inst.get_module()
    InsertValueInst(inst) => inst.get_module()
    PHINode(inst) => inst.get_module()
    ReturnInst(inst) => inst.get_module()
    BranchInst(inst) => inst.get_module()
    SwitchInst(inst) => inst.get_module()
    CallInst(inst) => inst.get_module()
  }
}

///|
impl Instruction with fn getNextInst(self) {
  let valueref = (self : &Value).get_raw_value_ref()
  let next_ref = @raw.llvm_get_next_instruction(valueref)
  unless(@raw.llvm_value_ref_is_null(next_ref), () => {
    initInstruction(next_ref, get_instruction_module(self))
  })
}

///|
impl Instruction with fn getPrevInst(self) {
  let valueref = (self : &Value).get_raw_value_ref()
  let prev_ref = @raw.llvm_get_previous_instruction(valueref)
  unless(@raw.llvm_value_ref_is_null(prev_ref), () => {
    initInstruction(prev_ref, get_instruction_module(self))
  })
}

///|
impl Instruction with fn removeFromParent(self) {
  @raw.llvm_instruction_remove_from_parent((self : &Value).get_raw_value_ref())
}

///|
impl Instruction with fn eraseFromParent(self) {
  @raw.llvm_instruction_erase_from_parent((self : &Value).get_raw_value_ref())
}

///|
impl Instruction with fn getNumArgOperands(self) {
  @raw.llvm_get_num_arg_operands((self : &Value).get_raw_value_ref()).reinterpret_as_int()
}

///|
/// Closed dynamic classification of supported LLVM instructions.
pub enum InstructionEnum {
  /// Stack-allocation instruction.
  AllocaInst(AllocaInst)
  /// Memory-load instruction.
  LoadInst(LoadInst)
  /// Memory-store instruction.
  StoreInst(StoreInst)
  /// Value-conversion instruction.
  CastInst(CastInst)
  /// Unary arithmetic instruction.
  UnaryInst(UnaryInst)
  /// Binary arithmetic or bitwise instruction.
  BinaryInst(BinaryInst)
  /// Integer comparison instruction.
  ICmpInst(ICmpInst)
  /// Floating-point comparison instruction.
  FCmpInst(FCmpInst)
  /// Get-element-pointer instruction.
  GetElementPtrInst(GetElementPtrInst)
  /// Conditional value-selection instruction.
  SelectInst(SelectInst)
  /// Aggregate extraction instruction.
  ExtractValueInst(ExtractValueInst)
  /// Aggregate insertion instruction.
  InsertValueInst(InsertValueInst)
  /// Static single-assignment phi node.
  PHINode(PHINode)
  /// Function-return terminator.
  ReturnInst(ReturnInst)
  /// Conditional or unconditional branch terminator.
  BranchInst(BranchInst)
  /// Multi-way switch terminator.
  SwitchInst(SwitchInst)
  /// Function-call instruction.
  CallInst(CallInst)
}

// =======================================================
// GlobalValue
// =======================================================

///|
/// Common interface for module-level functions and global definitions.
///
/// **Implementor contract:** `asGlobalEnum` must classify the same value as the
/// inherited `Value` methods, and the wrapper must retain its owning module.
pub trait GlobalValue: Value {
  /// Returns the concrete global-value classification.
  fn asGlobalEnum(Self) -> GlobalEnum

  /// Returns this definition's LLVM linkage.
  fn getLinkage(Self) -> Linkage = _

  /// Sets this definition's LLVM linkage.
  ///
  /// **Side Effects:** Changes symbol visibility and linker resolution
  /// semantics in emitted IR or object files.
  fn setLinkage(Self, Linkage) -> Unit = _

  /// Returns the current unnamed-address guarantee.
  fn getUnnamedAddr(Self) -> UnnamedAddr = _

  /// Sets an unnamed-address guarantee used by LLVM optimization.
  fn setUnnamedAddr(Self, UnnamedAddr) -> Unit = _

  /// Clears the unnamed-address guarantee.
  fn removeUnnamedAddr(Self) -> Unit = _
}

///|
/// Closed classification of module-level global values.
pub enum GlobalEnum {
  /// Function definition or declaration.
  Function(Function)
  /// Mutable global variable.
  GlobalVariable(GlobalVariable)
  /// Constant global definition.
  GlobalConstant(GlobalConstant)
}

///|
impl GlobalValue with fn getLinkage(self) {
  let linkage = @raw.llvm_get_linkage((self : &Value).get_raw_value_ref())
  Linkage::from_llvm_linkage(linkage)
}

///|
impl GlobalValue with fn setLinkage(self, linkage : Linkage) {
  let llvm_linkage = linkage.to_llvm_linkage()
  @raw.llvm_set_linkage((self : &Value).get_raw_value_ref(), llvm_linkage)
}

///|
impl GlobalValue with fn getUnnamedAddr(self) {
  let ua = @raw.llvm_get_unnamed_address((self : &Value).get_raw_value_ref())
  UnnamedAddr::from_llvm_unnamed_addr(ua)
}

///|
impl GlobalValue with fn setUnnamedAddr(self, ua : UnnamedAddr) {
  let llvm_ua = ua.to_llvm_unnamed_addr()
  @raw.llvm_set_unnamed_address((self : &Value).get_raw_value_ref(), llvm_ua)
}

///|
impl GlobalValue with fn removeUnnamedAddr(self) {
  @raw.llvm_set_unnamed_address(
    (self : &Value).get_raw_value_ref(),
    @raw.LLVMNoUnnamedAddr,
  )
}
