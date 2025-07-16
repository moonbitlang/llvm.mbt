// =======================================================
// IRBuilder
// =======================================================

///|
enum PositionState {
  NotSet
  Set
} derive(Show, Eq)

///|
pub suberror BuilderError {
  UnsetPosition
  ValueTypeError(String)
  InValidInsertPoint(String)
  BitwidthError(String)
  InValidArgument(String)
  UnImplemented(String)
}

///|
trait InsertPoint {
  asInsertPtEnum(Self) -> InsertPointEnum
}

///|
priv enum InsertPointEnum {
  BasicBlock(BasicBlock)
  Instruction(&Instruction)
}

///|
pub impl InsertPoint for BasicBlock with asInsertPtEnum(self) {
  BasicBlock(self)
}

///| IRBuilder
pub struct IRBuilder {
  builder_ref : @unsafe.LLVMBuilderRef
  priv mut positioned : PositionState
}

///|
pub fn IRBuilder::inner(self : Self) -> @unsafe.LLVMBuilderRef {
  self.builder_ref
}

///|
pub fn IRBuilder::getInsertBlock(self : Self) -> BasicBlock? {
  let bb_ref = @unsafe.llvm_get_insert_block(self.builder_ref)
  unless(@unsafe.llvm_bb_is_null(bb_ref), () => BasicBlock(bb_ref))
}

///|
pub fn[T : InsertPoint] IRBuilder::setInsertPoint(
  self : Self,
  insertPt : T
) -> Unit raise {
  self.positioned = Set
  match insertPt.asInsertPtEnum() {
    BasicBlock(bb) =>
      @unsafe.llvm_position_builder_at_end(self.builder_ref, bb.inner())
    Instruction(inst) => {
      let bb = match inst.getParentBasicBlock() {
        Some(bb) => bb
        None =>
          raise InValidInsertPoint(
            "Instruction as Insert Point, does not have a parent basic block",
          )
      }
      @unsafe.llvm_position_builder(
        self.builder_ref,
        bb.inner(),
        inst.getValueRef(),
      )
    }
  }
}

///| Create a Return Instruction
///
/// **Note:**
/// 
/// `IRBuilder::createRet` could not return void. use `IRBuilder::createRetVoid` for that purpose.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty])
///
/// let fval = mod.addFunction(fty, "direct_ret")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(bb)
/// let ret = builder.createRet(arg)
///
/// inspect(ret, content = "  ret i32 %0")
/// ```
pub fn IRBuilder::createRet(self : Self, value : &Value) -> ReturnInst raise {
  guard self.positioned is Set else { raise UnsetPosition }
  ReturnInst(@unsafe.llvm_build_ret(self.builder_ref, value.getValueRef()))
}

///| Create a Return Instruction with no return value (void)
///
/// **Note:**
///
/// If you want to return a value, use `IRBuilder::createRet` instead.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let void_ty = ctx.getVoidTy()
/// let fty = ctx.getFunctionType(void_ty, [])
///
/// let fval = mod.addFunction(fty, "direct_ret")
/// let bb = fval.addBasicBlock(name="entry")
///
/// builder.setInsertPoint(bb)
/// let ret = builder.createRetVoid()
///
/// inspect(ret, content = "  ret void")
/// ```
pub fn IRBuilder::createRetVoid(self : Self) -> ReturnInst raise {
  guard self.positioned is Set else { raise UnsetPosition }
  ReturnInst(@unsafe.llvm_build_ret_void(self.builder_ref))
}

///| Create an Alloca Instruction
///
/// **Note:**
/// 
/// This allocates memory on the stack for a value of the specified type.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(ctx.getVoidTy(), [])
///
/// let fval = mod.addFunction(fty, "alloca_demo")
/// let bb = fval.addBasicBlock(name="entry")
///
/// builder.setInsertPoint(bb)
/// let alloca = builder.createAlloca(i32_ty, name="temp")
///
/// inspect(alloca, content = "  %temp = alloca i32, align 4")
/// ```
pub fn IRBuilder::createAlloca(
  self : Self,
  data_ty : &Type,
  name~ : String = ""
) -> AllocaInst raise {
  guard self.positioned is Set else { raise UnsetPosition }
  AllocaInst(
    @unsafe.llvm_build_alloca(self.builder_ref, data_ty.getTypeRef(), name),
  )
}

///| Create a Load Instruction
///
/// **Note:**
/// 
/// This loads a value from memory at the specified pointer.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(ctx.getVoidTy(), [])
///
/// let fval = mod.addFunction(fty, "load_demo")
/// let bb = fval.addBasicBlock(name="entry")
///
/// builder.setInsertPoint(bb)
/// let alloca = builder.createAlloca(i32_ty, name="temp")
/// let load = builder.createLoad(i32_ty, alloca, name="val")
///
/// inspect(load, content = "  %val = load i32, ptr %temp, align 4")
/// ```
pub fn IRBuilder::createLoad(
  self : Self,
  load_ty : &Type,
  ptr : &Value,
  name~ : String = ""
) -> LoadInst raise {
  guard self.positioned is Set else { raise UnsetPosition }
  LoadInst(
    @unsafe.llvm_build_load2(
      self.builder_ref,
      load_ty.getTypeRef(),
      ptr.getValueRef(),
      name,
    ),
  )
}

///| Create a Store Instruction
///
/// **Note:**
/// 
/// This stores a value into memory at the specified pointer.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(ctx.getVoidTy(), [])
///
/// let fval = mod.addFunction(fty, "store_demo")
/// let bb = fval.addBasicBlock(name="entry")
///
/// builder.setInsertPoint(bb)
/// let alloca = builder.createAlloca(i32_ty, name="temp")
/// let const_val = ctx.getConstInt32(42)
/// let store = builder.createStore(const_val, alloca)
///
/// inspect(store, content = "  store i32 42, ptr %temp, align 4")
/// ```
pub fn IRBuilder::createStore(
  self : Self,
  value : &Value,
  ptr : &Value,
  loc~ : SourceLoc = _
) -> StoreInst raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard ptr.getType().asTypeEnum() is PointerType(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createStore`, pointer value's type is not a pointer type
      ),
    )
  }
  StoreInst(
    @unsafe.llvm_build_store(
      self.builder_ref,
      value.getValueRef(),
      ptr.getValueRef(),
    ),
  )
}

///|
fn type_check_during_create_int_binary(
  lhs : &Value,
  rhs : &Value,
  fname : String,
  loc : SourceLoc
) -> Unit raise {
  guard lhs.getType().tryAsIntType() is Some(lhs_ty) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        $| Misuse IRBuilder::\{fname}, left hand side value's type is not an integer type
      ),
    )
  }
  guard rhs.getType().tryAsIntType() is Some(rhs_ty) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        $| Misuse IRBuilder::\{fname}, right hand side value's type is not an integer type
      ),
    )
  }
  guard lhs_ty.getBitWidth() == rhs_ty.getBitWidth() else {
    raise BitwidthError(
      (
        $| loc: \{loc}:
        $| Misuse IRBuilder::\{fname}, left hand side and right hand side values' bitwidths do not match
      ),
    )
  }
}

///|
fn type_check_during_create_float_binary(
  lhs : &Value,
  rhs : &Value,
  fname : String,
  loc : SourceLoc
) -> Unit raise {
  guard lhs.getType().tryAsFPType() is Some(lhs_ty) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        $| Misuse IRBuilder::\{fname}, left hand side value's type is not an integer type",
      ),
    )
  }
  guard rhs.getType().tryAsFPType() is Some(rhs_ty) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        $| Misuse IRBuilder::\{fname}, right hand side value's type is not an integer type",
      ),
    )
  }
  guard lhs_ty.getBitWidth() == rhs_ty.getBitWidth() else {
    raise BitwidthError(
      (
        $| loc: \{loc}:
        $| Misuse IRBuilder::\{fname}, left hand side and right hand side values' bitwidths do not match",
      ),
    )
  }
}

///| Create an Add Instruction
///
/// **Note:**
/// 
/// This creates an integer addition instruction. Both operands must be integer types with the same bitwidth.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "add_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let add = builder.createAdd(arg1, arg2, name="sum")
/// inspect(add, content = "  %sum = add i32 %0, %1")
/// assert_true(add.asValueEnum() is BinaryInst(_))
///
/// let one = ctx.getConstInt32(1)
/// let two = ctx.getConstInt32(2)
/// let three = builder.createAdd(one, two)
/// inspect(three, content = "i32 3")
/// assert_true(three.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createAdd(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createAdd", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_add(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  //if @unsafe.llvm_is_constant(res_valueref) {
  //  ConstantInt::ConstantInt(res_valueref) as &Value
  //} else {
  //  BinaryInst::BinaryInst(res_valueref)
  //}
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an NSW Add Instruction
///
/// **Note:**
/// 
/// This creates an integer addition instruction with No Signed Wrap (NSW) flag. If signed overflow occurs, the result is undefined.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "nsw_add_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let add = builder.createNSWAdd(arg1, arg2, name="sum")
/// inspect(add, content = "  %sum = add nsw i32 %0, %1")
/// assert_true(add.asValueEnum() is BinaryInst(_))
///
/// let one = ctx.getConstInt32(1)
/// let two = ctx.getConstInt32(2)
/// let three = builder.createNSWAdd(one, two)
/// inspect(three, content = "i32 3")
/// assert_true(three.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createNSWAdd(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createNSWAdd", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_nsw_add(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an NUW Add Instruction
///
/// **Note:**
/// 
/// This creates an integer addition instruction with No Unsigned Wrap (NUW) flag. If unsigned overflow occurs, the result is undefined.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "nuw_add_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let add = builder.createNUWAdd(arg1, arg2, name="sum")
/// inspect(add, content = "  %sum = add nuw i32 %0, %1")
/// assert_true(add.asValueEnum() is BinaryInst(_))
///
/// let one = ctx.getConstInt32(1)
/// let two = ctx.getConstInt32(2)
/// let three = builder.createNUWAdd(one, two)
/// inspect(three, content = "i32 3")
/// assert_true(three.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createNUWAdd(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createNUWAdd", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_nuw_add(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create a Sub Instruction
///
/// **Note:**
/// 
/// This creates an integer subtraction instruction. Both operands must be integer types with the same bitwidth.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "sub_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let sub = builder.createSub(arg1, arg2, name="diff")
/// inspect(sub, content = "  %diff = sub i32 %0, %1")
/// assert_true(sub.asValueEnum() is BinaryInst(_))
///
/// let five = ctx.getConstInt32(5)
/// let two = ctx.getConstInt32(2)
/// let three = builder.createSub(five, two)
/// inspect(three, content = "i32 3")
/// assert_true(three.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createSub(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createSub", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_sub(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an NSW Sub Instruction
///
/// **Note:**
/// 
/// This creates an integer subtraction instruction with No Signed Wrap (NSW) flag. If signed overflow occurs, the result is undefined.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "nsw_sub_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let sub = builder.createNSWSub(arg1, arg2, name="diff")
/// inspect(sub, content = "  %diff = sub nsw i32 %0, %1")
/// assert_true(sub.asValueEnum() is BinaryInst(_))
///
/// let five = ctx.getConstInt32(5)
/// let two = ctx.getConstInt32(2)
/// let three = builder.createNSWSub(five, two)
/// inspect(three, content = "i32 3")
/// assert_true(three.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createNSWSub(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createNSWSub", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_nsw_sub(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an NUW Sub Instruction
///
/// **Note:**
/// 
/// This creates an integer subtraction instruction with No Unsigned Wrap (NUW) flag. If unsigned overflow occurs, the result is undefined.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "nuw_sub_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let sub = builder.createNUWSub(arg1, arg2, name="diff")
/// inspect(sub, content = "  %diff = sub nuw i32 %0, %1")
/// assert_true(sub.asValueEnum() is BinaryInst(_))
///
/// let five = ctx.getConstInt32(5)
/// let two = ctx.getConstInt32(2)
/// let three = builder.createNUWSub(five, two)
/// inspect(three, content = "i32 3")
/// assert_true(three.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createNUWSub(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createNUWSub", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_nuw_sub(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create a Mul Instruction
///
/// **Note:**
/// 
/// This creates an integer multiplication instruction. Both operands must be integer types with the same bitwidth.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "mul_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let mul = builder.createMul(arg1, arg2, name="product")
/// inspect(mul, content = "  %product = mul i32 %0, %1")
/// assert_true(mul.asValueEnum() is BinaryInst(_))
///
/// let three = ctx.getConstInt32(3)
/// let four = ctx.getConstInt32(4)
/// let twelve = builder.createMul(three, four)
/// inspect(twelve, content = "i32 12")
/// assert_true(twelve.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createMul(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createMul", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_mul(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an NSW Mul Instruction
///
/// **Note:**
/// 
/// This creates an integer multiplication instruction with No Signed Wrap (NSW) flag. If signed overflow occurs, the result is undefined.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "nsw_mul_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let mul = builder.createNSWMul(arg1, arg2, name="product")
/// inspect(mul, content = "  %product = mul nsw i32 %0, %1")
/// assert_true(mul.asValueEnum() is BinaryInst(_))
///
/// let three = ctx.getConstInt32(3)
/// let four = ctx.getConstInt32(4)
/// let twelve = builder.createNSWMul(three, four)
/// inspect(twelve, content = "i32 12")
/// assert_true(twelve.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createNSWMul(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createNSWMul", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_nsw_mul(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an NUW Mul Instruction
///
/// **Note:**
/// 
/// This creates an integer multiplication instruction with No Unsigned Wrap (NUW) flag. If unsigned overflow occurs, the result is undefined.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "nuw_mul_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let mul = builder.createNUWMul(arg1, arg2, name="product")
/// inspect(mul, content = "  %product = mul nuw i32 %0, %1")
/// assert_true(mul.asValueEnum() is BinaryInst(_))
///
/// let three = ctx.getConstInt32(3)
/// let four = ctx.getConstInt32(4)
/// let twelve = builder.createNUWMul(three, four)
/// inspect(twelve, content = "i32 12")
/// assert_true(twelve.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createNUWMul(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createNUWMul", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_nuw_mul(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create a UDiv Instruction
///
/// **Note:**
/// 
/// This creates an unsigned integer division instruction. 
/// Both operands must be integer types with the same bitwidth.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "udiv_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let div = builder.createUDiv(arg1, arg2, name="quotient")
/// inspect(div, content = "  %quotient = udiv i32 %0, %1")
/// assert_true(div.asValueEnum() is BinaryInst(_))
///
/// let twelve = ctx.getConstInt32(12)
/// let three = ctx.getConstInt32(3)
/// let four = builder.createUDiv(twelve, three)
/// inspect(four, content = "i32 4")
/// assert_true(four.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createUDiv(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createUDiv", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_u_div(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an SDiv Instruction
///
/// **Note:**
/// 
/// This creates a signed integer division instruction.
/// Both operands must be integer types with the same bitwidth.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "sdiv_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let div = builder.createSDiv(arg1, arg2, name="quotient")
/// inspect(div, content = "  %quotient = sdiv i32 %0, %1")
/// assert_true(div.asValueEnum() is BinaryInst(_))
///
/// let twelve = ctx.getConstInt32(12)
/// let three = ctx.getConstInt32(3)
/// let four = builder.createSDiv(twelve, three)
/// inspect(four, content = "i32 4")
/// assert_true(four.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createSDiv(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createSDiv", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_s_div(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an Exact UDiv Instruction
///
/// **Note:**
/// 
/// This creates an exact unsigned integer division instruction.
/// Both operands must be integer types with the same bitwidth.
/// The exact flag indicates that the division is expected to be exact (no remainder).
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "exact_udiv_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let div = builder.createExactUDiv(arg1, arg2, name="quotient")
/// inspect(div, content = "  %quotient = udiv exact i32 %0, %1")
/// assert_true(div.asValueEnum() is BinaryInst(_))
///
/// let twelve = ctx.getConstInt32(12)
/// let three = ctx.getConstInt32(3)
/// let four = builder.createExactUDiv(twelve, three)
/// inspect(four, content = "i32 4")
/// assert_true(four.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createExactUDiv(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createExactUDiv", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_exact_u_div(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an Exact SDiv Instruction
///
/// **Note:**
/// 
/// This creates an exact signed integer division instruction. Both operands must be integer types with the same bitwidth.
/// The exact flag indicates that the division is expected to be exact (no remainder).
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "exact_sdiv_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let div = builder.createExactSDiv(arg1, arg2, name="quotient")
/// inspect(div, content = "  %quotient = sdiv exact i32 %0, %1")
/// assert_true(div.asValueEnum() is BinaryInst(_))
///
/// let twelve = ctx.getConstInt32(12)
/// let three = ctx.getConstInt32(3)
/// let four = builder.createExactSDiv(twelve, three)
/// inspect(four, content = "i32 4")
/// assert_true(four.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createExactSDiv(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createExactSDiv", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_exact_s_div(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create a URem Instruction
///
/// **Note:**
/// 
/// This creates an unsigned integer remainder instruction. Both operands must be integer types with the same bitwidth.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "urem_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let rem = builder.createURem(arg1, arg2, name="remainder")
/// inspect(rem, content = "  %remainder = urem i32 %0, %1")
/// assert_true(rem.asValueEnum() is BinaryInst(_))
///
/// let thirteen = ctx.getConstInt32(13)
/// let five = ctx.getConstInt32(5)
/// let three = builder.createURem(thirteen, five)
/// inspect(three, content = "i32 3")
/// assert_true(three.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createURem(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createURem", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_u_rem(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an SRem Instruction
///
/// **Note:**
/// 
/// This creates a signed integer remainder instruction. Both operands must be integer types with the same bitwidth.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "srem_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let rem = builder.createSRem(arg1, arg2, name="remainder")
/// inspect(rem, content = "  %remainder = srem i32 %0, %1")
/// assert_true(rem.asValueEnum() is BinaryInst(_))
///
/// let thirteen = ctx.getConstInt32(13)
/// let five = ctx.getConstInt32(5)
/// let three = builder.createSRem(thirteen, five)
/// inspect(three, content = "i32 3")
/// assert_true(three.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createSRem(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createSRem", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_s_rem(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an FAdd Instruction
///
/// **Note:**
/// 
/// This creates a floating-point addition instruction.
/// Both operands must be floating-point types with the same bitwidth.
///
/// **Fast Math Flags:**
///
/// Allowed Fast Math Flags:
/// 1. `AllowReassoc`
/// 2. `AllowContract`
/// 3. `NoNaNs`
/// 4. `NoInfs`
/// 5. `NoSignedZeros`
/// 6. `AllowReciprocal`
/// 7. `ApproxFunc`
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let f32_ty = ctx.getFloatTy()
/// let fty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty])
///
/// let fval = mod.addFunction(fty, "fadd_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let fadd = builder.createFAdd(arg1, arg2, name="sum")
/// inspect(fadd, content = "  %sum = fadd float %0, %1")
/// assert_true(fadd.asValueEnum() is BinaryInst(_))
///
/// let one = ctx.getConstFloat(1.0)
/// let two = ctx.getConstFloat(2.0)
/// let three = builder.createFAdd(one, two)
/// inspect(three, content = "float 3.000000e+00")
/// assert_true(three.asValueEnum() is ConstantFP(_))
///
/// let nnan_fadd = builder.createFAdd(arg1, arg2, name="sum_nnan", fast_math=[NoNaNs])
/// inspect(nnan_fadd, content = "  %sum_nnan = fadd nnan float %0, %1")
///
/// let ninf_fadd = builder.createFAdd(arg1, arg2, name="sum_ninf", fast_math=[NoInfs])
/// inspect(ninf_fadd, content = "  %sum_ninf = fadd ninf float %0, %1")
///
/// let nnan_ninf_fadd = builder.createFAdd(
///   arg1, arg2, name="sum_nnan_ninf", fast_math=[NoNaNs, NoInfs]
/// )
/// inspect(nnan_ninf_fadd, content = "  %sum_nnan_ninf = fadd nnan ninf float %0, %1")
/// ```
pub fn IRBuilder::createFAdd(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  fast_math~ : Array[FastMathFlags] = [],
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_float_binary(lhs, rhs, "createFAdd", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_f_add(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantFP::ConstantFP(res_valueref) as &Value
    false => {
      let inst = BinaryInst::BinaryInst(res_valueref)
      match fast_math {
        [] => ()
        flags =>
          flags.each(f => @unsafe.llvm_set_fast_math_flags(
            inst.inner(),
            f.to_llvm(),
          ))
      }
      inst
    }
  }
}

///| Create an FSub Instruction
///
/// **Note:**
/// 
/// This creates a floating-point subtraction instruction. Both operands must be floating-point types with the same bitwidth.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let f32_ty = ctx.getFloatTy()
/// let fty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty])
///
/// let fval = mod.addFunction(fty, "fsub_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let fsub = builder.createFSub(arg1, arg2, name="diff")
/// inspect(fsub, content = "  %diff = fsub float %0, %1")
/// assert_true(fsub.asValueEnum() is BinaryInst(_))
///
/// let five = ctx.getConstFloat(5.0)
/// let two = ctx.getConstFloat(2.0)
/// let three = builder.createFSub(five, two)
/// inspect(three, content = "float 3.000000e+00")
/// assert_true(three.asValueEnum() is ConstantFP(_))
/// ```
pub fn IRBuilder::createFSub(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_float_binary(lhs, rhs, "createFSub", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_f_sub(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantFP::ConstantFP(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an FMul Instruction
///
/// **Note:**
/// 
/// This creates a floating-point multiplication instruction. Both operands must be floating-point types with the same bitwidth.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let f32_ty = ctx.getFloatTy()
/// let fty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty])
///
/// let fval = mod.addFunction(fty, "fmul_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let fmul = builder.createFMul(arg1, arg2, name="product")
/// inspect(fmul, content = "  %product = fmul float %0, %1")
/// assert_true(fmul.asValueEnum() is BinaryInst(_))
///
/// let three = ctx.getConstFloat(3.0)
/// let four = ctx.getConstFloat(4.0)
/// let twelve = builder.createFMul(three, four)
/// inspect(twelve, content = "float 1.200000e+01")
/// assert_true(twelve.asValueEnum() is ConstantFP(_))
/// ```
pub fn IRBuilder::createFMul(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_float_binary(lhs, rhs, "createFMul", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_f_mul(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantFP::ConstantFP(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an FDiv Instruction
///
/// **Note:**
/// 
/// This creates a floating-point division instruction. Both operands must be floating-point types with the same bitwidth.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let f32_ty = ctx.getFloatTy()
/// let fty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty])
///
/// let fval = mod.addFunction(fty, "fdiv_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let fdiv = builder.createFDiv(arg1, arg2, name="quotient")
/// inspect(fdiv, content = "  %quotient = fdiv float %0, %1")
/// assert_true(fdiv.asValueEnum() is BinaryInst(_))
///
/// let eight = ctx.getConstFloat(8.0)
/// let two = ctx.getConstFloat(2.0)
/// let four = builder.createFDiv(eight, two)
/// inspect(four, content = "float 4.000000e+00")
/// assert_true(four.asValueEnum() is ConstantFP(_))
/// ```
pub fn IRBuilder::createFDiv(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_float_binary(lhs, rhs, "createFDiv", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_f_div(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantFP::ConstantFP(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an FRem Instruction
///
/// **Note:**
/// 
/// This creates a floating-point remainder instruction. Both operands must be floating-point types with the same bitwidth.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let f32_ty = ctx.getFloatTy()
/// let fty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty])
///
/// let fval = mod.addFunction(fty, "frem_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let frem = builder.createFRem(arg1, arg2, name="remainder")
/// inspect(frem, content = "  %remainder = frem float %0, %1")
/// assert_true(frem.asValueEnum() is BinaryInst(_))
///
/// let five_and_half = ctx.getConstFloat(5.5)
/// let two = ctx.getConstFloat(2.0)
/// let one_and_half = builder.createFRem(five_and_half, two)
/// inspect(one_and_half, content = "float 1.500000e+00")
/// assert_true(one_and_half.asValueEnum() is ConstantFP(_))
/// ```
pub fn IRBuilder::createFRem(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_float_binary(lhs, rhs, "createFRem", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_f_rem(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantFP::ConstantFP(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an FNeg Instruction
///
/// **Note:**
/// 
/// This creates a floating-point negation instruction that negates a floating-point value.
/// The input value must be a floating-point type.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let f32_ty = ctx.getFloatTy()
/// let fty = ctx.getFunctionType(f32_ty, [f32_ty])
///
/// let fval = mod.addFunction(fty, "fneg_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(bb)
/// let fneg = builder.createFNeg(arg, name="negated")
/// inspect(fneg, content = "  %negated = fneg float %0")
/// assert_true(fneg.asValueEnum() is UnaryInst(_))
///
/// let pos_val = ctx.getConstFloat(3.14)
/// let neg_val = builder.createFNeg(pos_val)
/// assert_true(neg_val.asValueEnum() is ConstantFP(_))
/// ```
pub fn IRBuilder::createFNeg(
  self : Self,
  value : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard value.getType().tryAsFPType() is Some(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}
        #| Misuse `IRBuilder::createFNeg`, value is not a floating-point type, it is \{value.getType()}"
      ),
    )
  }
  let value_ref = value.getValueRef()
  let res_valueref = @unsafe.llvm_build_f_neg(self.builder_ref, value_ref, name)
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantFP::ConstantFP(res_valueref) as &Value
    false => UnaryInst::UnaryInst(res_valueref)
  }
}

///| Create an And Instruction
///
/// **Note:**
/// 
/// This creates a bitwise AND instruction. Both operands must be integer types with the same bitwidth.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "and_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let and_result = builder.createAnd(arg1, arg2, name="result")
/// inspect(and_result, content = "  %result = and i32 %0, %1")
/// assert_true(and_result.asValueEnum() is BinaryInst(_))
///
/// let val1 = ctx.getConstInt32(12)  // 1100 in binary
/// let val2 = ctx.getConstInt32(10)  // 1010 in binary
/// let result = builder.createAnd(val1, val2)  // 1000 in binary = 8
/// inspect(result, content = "i32 8")
/// assert_true(result.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createAnd(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createAnd", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_and(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an Or Instruction
///
/// **Note:**
/// 
/// This creates a bitwise OR instruction. Both operands must be integer types with the same bitwidth.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "or_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let or_result = builder.createOr(arg1, arg2, name="result")
/// inspect(or_result, content = "  %result = or i32 %0, %1")
/// assert_true(or_result.asValueEnum() is BinaryInst(_))
///
/// let val1 = ctx.getConstInt32(12)  // 1100 in binary
/// let val2 = ctx.getConstInt32(10)  // 1010 in binary
/// let result = builder.createOr(val1, val2)  // 1110 in binary = 14
/// inspect(result, content = "i32 14")
/// assert_true(result.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createOr(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createOr", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_or(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an Xor Instruction
///
/// **Note:**
/// 
/// This creates a bitwise XOR instruction. Both operands must be integer types with the same bitwidth.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "xor_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let xor_result = builder.createXor(arg1, arg2, name="result")
/// inspect(xor_result, content = "  %result = xor i32 %0, %1")
/// assert_true(xor_result.asValueEnum() is BinaryInst(_))
///
/// let val1 = ctx.getConstInt32(12)  // 1100 in binary
/// let val2 = ctx.getConstInt32(10)  // 1010 in binary
/// let result = builder.createXor(val1, val2)  // 0110 in binary = 6
/// inspect(result, content = "i32 6")
/// assert_true(result.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createXor(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createXor", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_xor(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create a Not Instruction
///
/// **Note:**
/// 
/// This creates a bitwise NOT instruction that performs bitwise negation on an integer value.
/// The input value must be an integer type. LLVM implements NOT as `xor val, -1`.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty])
///
/// let fval = mod.addFunction(fty, "not_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(bb)
/// let not_result = builder.createNot(arg, name="inverted")
/// inspect(not_result, content = "  %inverted = xor i32 %0, -1")
/// assert_true(not_result.asValueEnum() is BinaryInst(_))
///
/// let val = ctx.getConstInt32(12)  // 1100 in binary
/// let result = builder.createNot(val)  // ...11110011 (inverted)
/// inspect(result, content = "i32 -13")
/// assert_true(result.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createNot(
  self : Self,
  value : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard value.getType().tryAsIntType() is Some(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createNot`, value is not an integer type, it is \{value.getType()}
      ),
    )
  }
  let value_ref = value.getValueRef()
  let res_valueref = @unsafe.llvm_build_not(self.builder_ref, value_ref, name)
  // Note: It is correct, llvm has no `not` instruction,
  // it will actually generate a `xor`, use `xor val, -1`
  // to represent a bitwise NOT operation.
  // so it is BinaryInst, not UnaryInst.
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create a Shl Instruction
///
/// **Note:**
/// 
/// This creates a left shift instruction. Both operands must be integer types with the same bitwidth.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "shl_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let shl_result = builder.createShl(arg1, arg2, name="result")
/// inspect(shl_result, content = "  %result = shl i32 %0, %1")
/// assert_true(shl_result.asValueEnum() is BinaryInst(_))
///
/// let val = ctx.getConstInt32(5)   // 101 in binary
/// let shift = ctx.getConstInt32(2) // shift left by 2
/// let result = builder.createShl(val, shift)  // 10100 in binary = 20
/// inspect(result, content = "i32 20")
/// assert_true(result.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createShl(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createShl", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_shl(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an LShr Instruction
///
/// **Note:**
/// 
/// This creates a logical right shift instruction. Both operands must be integer types with the same bitwidth.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "lshr_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let lshr_result = builder.createLShr(arg1, arg2, name="result")
/// inspect(lshr_result, content = "  %result = lshr i32 %0, %1")
/// assert_true(lshr_result.asValueEnum() is BinaryInst(_))
///
/// let twenty = ctx.getConstInt32(20)   // 10100 in binary
/// let two = ctx.getConstInt32(2)       // shift right by 2
/// let five = builder.createLShr(twenty, two)  // 101 in binary = 5
/// inspect(five, content = "i32 5")
/// assert_true(five.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createLShr(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createLShr", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_l_shr(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create an AShr Instruction
///
/// **Note:**
/// 
/// This creates an arithmetic right shift instruction. Both operands must be integer types with the same bitwidth.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "ashr_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg1 = fval.getArg(0).unwrap()
/// let arg2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let ashr_result = builder.createAShr(arg1, arg2, name="result")
/// inspect(ashr_result, content = "  %result = ashr i32 %0, %1")
/// assert_true(ashr_result.asValueEnum() is BinaryInst(_))
///
/// let twenty = ctx.getConstInt32(20)   // 10100 in binary
/// let two = ctx.getConstInt32(2)       // shift right by 2
/// let five = builder.createAShr(twenty, two)  // 101 in binary = 5
/// inspect(five, content = "i32 5")
/// assert_true(five.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createAShr(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createAShr", loc)
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_a_shr(
    self.builder_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => BinaryInst::BinaryInst(res_valueref)
  }
}

///| Create a PtrDiff Instruction
///
/// **Note:**
/// 
/// This creates a pointer difference instruction that calculates the difference between two pointers
/// in terms of elements of the specified type. Both operands must be pointer types.
/// The result is the number of elements of type elemTy between the two pointers.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let ptr_ty = ctx.getPtrTy()
/// let fty = ctx.getFunctionType(i32_ty, [ptr_ty, ptr_ty])
///
/// let fval = mod.addFunction(fty, "ptrdiff_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let ptr1 = fval.getArg(0).unwrap()
/// let ptr2 = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let diff = builder.createPtrDiff(i32_ty, ptr1, ptr2, name="diff")
///
/// inspect(diff, content = "  %diff = sdiv exact i64 %4, ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i64)")
/// ```
pub fn IRBuilder::createPtrDiff(
  self : Self,
  elemTy : &Type,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard lhs.getType().asTypeEnum() is PointerType(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createPtrDiff`, lhs is not a pointer type, it is \{lhs.getType()}
      ),
    )
  }
  guard rhs.getType().asTypeEnum() is PointerType(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createPtrDiff`, rhs is not a pointer type, it is \{rhs.getType()}
      ),
    )
  }
  let elem_ty_ref = elemTy.getTypeRef()
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_ptr_diff2(
    self.builder_ref,
    elem_ty_ref,
    lhs_ref,
    rhs_ref,
    name,
  )
  BinaryInst::BinaryInst(res_valueref)
}

///| Create an Integer Compare Instruction.
///
/// **Note:**
///
/// 1. `lhs` and `rhs` must be integer types with the same bitwidth.
/// 2. Allowed predicates: EQ, NE, SGT, SGE, SLT, SLE, UGT, UGE, ULT, ULE.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
/// let fval = mod.addFunction(fty, "icmp_demo")
///
/// let bb = fval.addBasicBlock(name="entry")
/// let arg0 = fval.getArg(0).unwrap()
/// let arg1 = fval.getArg(1).unwrap()
/// builder.setInsertPoint(bb)
///
/// let eq_cmp = builder.createICmp(IntPredicate::EQ, arg0, arg1, name="eq_cmp")
/// inspect(eq_cmp, content = "  %eq_cmp = icmp eq i32 %0, %1")
/// assert_true(eq_cmp.asValueEnum() is ICmpInst(_))
///
/// let val1 = ctx.getConstInt32(5)
/// let val2 = ctx.getConstInt32(5)
/// let result = builder.createICmpEQ(val1, val2)
/// inspect(result, content = "i1 true")
/// assert_true(result.asValueEnum() is ConstantInt(_))
///
/// let ne_cmp = builder.createICmpNE(arg0, arg1, name="ne_cmp")
/// inspect(ne_cmp, content = "  %ne_cmp = icmp ne i32 %0, %1")
///
/// let sgt_cmp = builder.createICmpSGT(arg0, arg1, name="sgt_cmp")
/// inspect(sgt_cmp, content = "  %sgt_cmp = icmp sgt i32 %0, %1")
///
/// let sge_cmp = builder.createICmpSGE(arg0, arg1, name="sge_cmp")
/// inspect(sge_cmp, content = "  %sge_cmp = icmp sge i32 %0, %1")
///
/// let slt_cmp = builder.createICmpSLT(arg0, arg1, name="slt_cmp")
/// inspect(slt_cmp, content = "  %slt_cmp = icmp slt i32 %0, %1")
///
/// let sle_cmp = builder.createICmpSLE(arg0, arg1, name="sle_cmp")
/// inspect(sle_cmp, content = "  %sle_cmp = icmp sle i32 %0, %1")
///
/// let ugt_cmp = builder.createICmpUGT(arg0, arg1, name="ugt_cmp")
/// inspect(ugt_cmp, content = "  %ugt_cmp = icmp ugt i32 %0, %1")
///
/// let uge_cmp = builder.createICmpUGE(arg0, arg1, name="uge_cmp")
/// inspect(uge_cmp, content = "  %uge_cmp = icmp uge i32 %0, %1")
///
/// let ult_cmp = builder.createICmpULT(arg0, arg1, name="ult_cmp")
/// inspect(ult_cmp, content = "  %ult_cmp = icmp ult i32 %0, %1")
///
/// let ule_cmp = builder.createICmpULE(arg0, arg1, name="ule_cmp")
/// inspect(ule_cmp, content = "  %ule_cmp = icmp ule i32 %0, %1")
/// ```
pub fn IRBuilder::createICmp(
  self : Self,
  pred : IntPredicate,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_int_binary(lhs, rhs, "createICmp", loc)
  let pred = pred.to_llvm_int_predicate()
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_icmp(
    self.builder_ref,
    pred,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => ICmpInst::ICmpInst(res_valueref)
  }
}

///| Create an Integer Compare for Equality Instruction.
///
/// It's equivalent to `IRBuilder::createICmp(EQ, lhs, rhs)`
pub fn IRBuilder::createICmpEQ(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createICmp(EQ, lhs, rhs, name~, loc~)
}

///| Create an Integer Compare for Non-Equality Instruction.
///
/// It's equivalent to `IRBuilder::createICmp(NE, lhs, rhs)`
pub fn IRBuilder::createICmpNE(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createICmp(NE, lhs, rhs, name~, loc~)
}

///| Create an Integer Compare for Signed Greater Than Instruction.
///
/// It's equivalent to `IRBuilder::createICmp(SGT, lhs, rhs)`
pub fn IRBuilder::createICmpSGT(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createICmp(SGT, lhs, rhs, name~, loc~)
}

///| Create an Integer Compare for Signed Greater Than or Equal Instruction.
///
/// It's equivalent to `IRBuilder::createICmp(SGE, lhs, rhs)`
pub fn IRBuilder::createICmpSGE(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createICmp(SGE, lhs, rhs, name~, loc~)
}

///| Create an Integer Compare for Signed Less Than Instruction.
///
/// It's equivalent to `IRBuilder::createICmp(SLT, lhs, rhs)`
pub fn IRBuilder::createICmpSLT(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createICmp(SLT, lhs, rhs, name~, loc~)
}

///| Create an Integer Compare for Signed Less Than or Equal Instruction.
///
/// It's equivalent to `IRBuilder::createICmp(SLE, lhs, rhs)`
pub fn IRBuilder::createICmpSLE(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createICmp(SLE, lhs, rhs, name~, loc~)
}

///| Create an Integer Compare for Unsigned Greater Than Instruction.
///
/// It's equivalent to `IRBuilder::createICmp(UGT, lhs, rhs)`
pub fn IRBuilder::createICmpUGT(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createICmp(UGT, lhs, rhs, name~, loc~)
}

///| Create an Integer Compare for Unsigned Greater Than or Equal Instruction.
///
/// It's equivalent to `IRBuilder::createICmp(UGE, lhs, rhs)`
pub fn IRBuilder::createICmpUGE(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createICmp(UGE, lhs, rhs, name~, loc~)
}

///| Create an Integer Compare for Unsigned Less Than Instruction.
///
/// It's equivalent to `IRBuilder::createICmp(ULT, lhs, rhs)`
pub fn IRBuilder::createICmpULT(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createICmp(ULT, lhs, rhs, name~, loc~)
}

///| Create an Integer Compare for Unsigned Less Than or Equal Instruction.
///
/// It's equivalent to `IRBuilder::createICmp(ULE, lhs, rhs)`
pub fn IRBuilder::createICmpULE(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createICmp(ULE, lhs, rhs, name~, loc~)
}

///| Create a Float Compare Instruction.
///
/// **Note:**
///
/// 1. `lhs` and `rhs` must be floating-point types with the same bitwidth.
/// 2. Allowed predicates: OEQ, OGT, OGE, OLT, OLE, ONE, ORD, UEQ, UGT, UGE, ULT, ULE, UNE.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let f32_ty = ctx.getFloatTy()
/// let fty = ctx.getFunctionType(f32_ty, [f32_ty, f32_ty])
/// let fval = mod.addFunction(fty, "fcmp_demo")
///
/// let bb = fval.addBasicBlock(name="entry")
/// let arg0 = fval.getArg(0).unwrap()
/// let arg1 = fval.getArg(1).unwrap()
/// builder.setInsertPoint(bb)
///
/// let oeq_cmp = builder.createFCmp(FloatPredicate::OEQ, arg0, arg1, name="oeq_cmp")
/// inspect(oeq_cmp, content = "  %oeq_cmp = fcmp oeq float %0, %1")
/// assert_true(oeq_cmp.asValueEnum() is FCmpInst(_))
///
/// let val1 = ctx.getConstFloat(3.14)
/// let val2 = ctx.getConstFloat(3.14)
/// let result = builder.createFCmpOEQ(val1, val2)
/// inspect(result, content = "i1 true")
/// assert_true(result.asValueEnum() is ConstantInt(_))
///
/// let ogt_cmp = builder.createFCmpOGT(arg0, arg1, name="ogt_cmp")
/// inspect(ogt_cmp, content = "  %ogt_cmp = fcmp ogt float %0, %1")
///
/// let oge_cmp = builder.createFCmpOGE(arg0, arg1, name="oge_cmp")
/// inspect(oge_cmp, content = "  %oge_cmp = fcmp oge float %0, %1")
///
/// let olt_cmp = builder.createFCmpOLT(arg0, arg1, name="olt_cmp")
/// inspect(olt_cmp, content = "  %olt_cmp = fcmp olt float %0, %1")
///
/// let ole_cmp = builder.createFCmpOLE(arg0, arg1, name="ole_cmp")
/// inspect(ole_cmp, content = "  %ole_cmp = fcmp ole float %0, %1")
///
/// let one_cmp = builder.createFCmpONE(arg0, arg1, name="one_cmp")
/// inspect(one_cmp, content = "  %one_cmp = fcmp one float %0, %1")
///
/// let ord_cmp = builder.createFCmpORD(arg0, arg1, name="ord_cmp")
/// inspect(ord_cmp, content = "  %ord_cmp = fcmp ord float %0, %1")
///
/// let ueq_cmp = builder.createFCmpUEQ(arg0, arg1, name="ueq_cmp")
/// inspect(ueq_cmp, content = "  %ueq_cmp = fcmp ueq float %0, %1")
///
/// let ugt_cmp = builder.createFCmpUGT(arg0, arg1, name="ugt_cmp")
/// inspect(ugt_cmp, content = "  %ugt_cmp = fcmp ugt float %0, %1")
///
/// let uge_cmp = builder.createFCmpUGE(arg0, arg1, name="uge_cmp")
/// inspect(uge_cmp, content = "  %uge_cmp = fcmp uge float %0, %1")
///
/// let ult_cmp = builder.createFCmpULT(arg0, arg1, name="ult_cmp")
/// inspect(ult_cmp, content = "  %ult_cmp = fcmp ult float %0, %1")
///
/// let ule_cmp = builder.createFCmpULE(arg0, arg1, name="ule_cmp")
/// inspect(ule_cmp, content = "  %ule_cmp = fcmp ule float %0, %1")
///
/// let une_cmp = builder.createFCmpUNE(arg0, arg1, name="une_cmp")
/// inspect(une_cmp, content = "  %une_cmp = fcmp une float %0, %1")
/// ```
pub fn IRBuilder::createFCmp(
  self : Self,
  pred : FloatPredicate,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  type_check_during_create_float_binary(lhs, rhs, "createFCmp", loc)
  let pred = pred.to_llvm_float_predicate()
  let lhs_ref = lhs.getValueRef()
  let rhs_ref = rhs.getValueRef()
  let res_valueref = @unsafe.llvm_build_fcmp(
    self.builder_ref,
    pred,
    lhs_ref,
    rhs_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => FCmpInst::FCmpInst(res_valueref)
  }
}

///| Create a Float Compare for Equality Instruction.
///
/// It's equivalent to `IRBuilder::createFCmp(OEQ, lhs, rhs)`
pub fn IRBuilder::createFCmpOEQ(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createFCmp(OEQ, lhs, rhs, name~, loc~)
}

///| Create a Float Compare for Greater Than Instruction.
///
/// It's equivalent to `IRBuilder::createFCmp(OGT, lhs, rhs)`
pub fn IRBuilder::createFCmpOGT(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createFCmp(OGT, lhs, rhs, name~, loc~)
}

///| Create a Float Compare for Greater Than or Equal Instruction.
///
/// It's equivalent to `IRBuilder::createFCmp(OGE, lhs, rhs)`
pub fn IRBuilder::createFCmpOGE(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createFCmp(OGE, lhs, rhs, name~, loc~)
}

///| Create a Float Compare for Less Than Instruction.
///
/// It's equivalent to `IRBuilder::createFCmp(OLT, lhs, rhs)`
pub fn IRBuilder::createFCmpOLT(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createFCmp(OLT, lhs, rhs, name~, loc~)
}

///| Create a Float Compare for Less Than or Equal Instruction.
///
/// It's equivalent to `IRBuilder::createFCmp(OLE, lhs, rhs)`
pub fn IRBuilder::createFCmpOLE(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createFCmp(OLE, lhs, rhs, name~, loc~)
}

///| Create a Float Compare for Non-Equality Instruction.
///
/// It's equivalent to `IRBuilder::createFCmp(ONE, lhs, rhs)`
pub fn IRBuilder::createFCmpONE(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createFCmp(ONE, lhs, rhs, name~, loc~)
}

///| Create a Float Compare for Ordered Instruction.
///
/// It's equivalent to `IRBuilder::createFCmp(ORD, lhs, rhs)`
pub fn IRBuilder::createFCmpORD(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createFCmp(ORD, lhs, rhs, name~, loc~)
}

///| Create a Float Compare for Unordered Equals Instruction.
///
/// It's equivalent to `IRBuilder::createFCmp(UEQ, lhs, rhs)`
pub fn IRBuilder::createFCmpUEQ(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createFCmp(UEQ, lhs, rhs, name~, loc~)
}

///| Create a Float Compare for Unsigned Greater Than Instruction.
///
/// It's equivalent to `IRBuilder::createFCmp(UGT, lhs, rhs)`
pub fn IRBuilder::createFCmpUGT(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createFCmp(UGT, lhs, rhs, name~, loc~)
}

///| Create a Float Compare for Unsigned Greater Than or Equal Instruction.
///
/// It's equivalent to `IRBuilder::createFCmp(UGE, lhs, rhs)`
pub fn IRBuilder::createFCmpUGE(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createFCmp(UGE, lhs, rhs, name~, loc~)
}

///| Create a Float Compare for Unsigned Less Than Instruction.
///
/// It's equivalent to `IRBuilder::createFCmp(ULT, lhs, rhs)`
pub fn IRBuilder::createFCmpULT(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createFCmp(ULT, lhs, rhs, name~, loc~)
}

///| Create a Float Compare for Unsigned Less Than or Equal Instruction.
///
/// It's equivalent to `IRBuilder::createFCmp(ULE, lhs, rhs)`
pub fn IRBuilder::createFCmpULE(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createFCmp(ULE, lhs, rhs, name~, loc~)
}

///| Create a Float Compare for Unordered Not Equal Instruction.
///
/// It's equivalent to `IRBuilder::createFCmp(UNE, lhs, rhs)`
pub fn IRBuilder::createFCmpUNE(
  self : Self,
  lhs : &Value,
  rhs : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  self.createFCmp(UNE, lhs, rhs, name~, loc~)
}

// REVIEW: What will happened if `from` type is equal to `to` type?

///| Create a Trunc Instruction
///
/// **Note:**
/// 
/// This creates a truncation instruction that truncates an integer value to a smaller integer type.
/// The input value must be an integer type, and the target type must be a smaller integer type.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i64_ty = ctx.getInt64Ty()
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i64_ty])
///
/// let fval = mod.addFunction(fty, "trunc_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(bb)
/// let trunc = builder.createTrunc(arg, i32_ty, name="truncated")
/// inspect(trunc, content = "  %truncated = trunc i64 %0 to i32")
/// assert_true(trunc.asValueEnum() is CastInst(_))
///
/// let big_val = ctx.getConstInt64(0x123456789L)
/// let small_val = builder.createTrunc(big_val, i32_ty)
/// inspect(small_val, content = "i32 591751049")
/// assert_true(small_val.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createTrunc(
  self : Self,
  from : &Value,
  to : &IntegerType,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard from.getType().tryAsIntType() is Some(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createTrunc`, from must be an integer type
      ),
    )
  }
  let from_ref = from.getValueRef()
  let to_ref = to.getTypeRef()
  let res_valueref = @unsafe.llvm_build_trunc(
    self.builder_ref,
    from_ref,
    to_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => CastInst::CastInst(res_valueref)
  }
}

///| Create a ZExt Instruction
///
/// **Note:**
/// 
/// This creates a zero extension instruction that extends an integer value to a larger integer type by padding with zeros.
/// The input value must be an integer type, and the target type must be a larger integer type.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let i64_ty = ctx.getInt64Ty()
/// let fty = ctx.getFunctionType(i64_ty, [i32_ty])
///
/// let fval = mod.addFunction(fty, "zext_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(bb)
/// let zext = builder.createZExt(arg, i64_ty, name="extended")
/// inspect(zext, content = "  %extended = zext i32 %0 to i64")
/// assert_true(zext.asValueEnum() is CastInst(_))
///
/// let small_val = ctx.getConstInt32(42)
/// let big_val = builder.createZExt(small_val, i64_ty)
/// inspect(big_val, content = "i64 42")
/// assert_true(big_val.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createZExt(
  self : Self,
  from : &Value,
  to : &IntegerType,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard from.getType().tryAsIntType() is Some(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createZExt`, from must be an integer type
      ),
    )
  }
  let from_ref = from.getValueRef()
  let to_ref = to.getTypeRef()
  let res_valueref = @unsafe.llvm_build_z_ext(
    self.builder_ref,
    from_ref,
    to_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => CastInst::CastInst(res_valueref)
  }
}

///| Create a SExt Instruction
///
/// **Note:**
/// 
/// This creates a sign extension instruction that extends an integer value to a larger integer type by replicating the sign bit.
/// The input value must be an integer type, and the target type must be a larger integer type.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let i64_ty = ctx.getInt64Ty()
/// let fty = ctx.getFunctionType(i64_ty, [i32_ty])
///
/// let fval = mod.addFunction(fty, "sext_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(bb)
/// let sext = builder.createSExt(arg, i64_ty, name="extended")
/// inspect(sext, content = "  %extended = sext i32 %0 to i64")
/// assert_true(sext.asValueEnum() is CastInst(_))
///
/// let small_val = ctx.getConstInt32(-42)
/// let big_val = builder.createSExt(small_val, i64_ty)
/// inspect(big_val, content = "i64 -42")
/// assert_true(big_val.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createSExt(
  self : Self,
  from : &Value,
  to : &IntegerType,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard from.getType().tryAsIntType() is Some(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createSExt`, from must be an integer type
      ),
    )
  }
  let from_ref = from.getValueRef()
  let to_ref = to.getTypeRef()
  let res_valueref = @unsafe.llvm_build_s_ext(
    self.builder_ref,
    from_ref,
    to_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => CastInst::CastInst(res_valueref)
  }
}

///| Create a FPTrunc Instruction
///
/// **Note:**
/// 
/// This creates a floating-point truncation instruction that truncates a floating-point value to a smaller floating-point type.
/// The input value must be a floating-point type, and the target type must be a smaller floating-point type.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let f64_ty = ctx.getDoubleTy()
/// let f32_ty = ctx.getFloatTy()
/// let fty = ctx.getFunctionType(f32_ty, [f64_ty])
///
/// let fval = mod.addFunction(fty, "fptrunc_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(bb)
/// let fptrunc = builder.createFPTrunc(arg, f32_ty, name="truncated")
/// inspect(fptrunc, content = "  %truncated = fptrunc double %0 to float")
/// assert_true(fptrunc.asValueEnum() is CastInst(_))
///
/// let big_val = ctx.getConstDouble(3.14159)
/// let small_val = builder.createFPTrunc(big_val, f32_ty)
/// assert_true(small_val.asValueEnum() is ConstantFP(_))
/// ```
pub fn IRBuilder::createFPTrunc(
  self : Self,
  from : &Value,
  to : &FPType,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard from.getType().tryAsFPType() is Some(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createFPTrunc`: 'from' must be a floating-point type"
      ),
    )
  }
  let from_ref = from.getValueRef()
  let to_ref = to.getTypeRef()
  let res_valueref = @unsafe.llvm_build_fp_trunc(
    self.builder_ref,
    from_ref,
    to_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantFP::ConstantFP(res_valueref) as &Value
    false => CastInst::CastInst(res_valueref)
  }
}

///| Create a FPExt Instruction
///
/// **Note:**
/// 
/// This creates a floating-point extension instruction that extends a floating-point value to a larger floating-point type.
/// The input value must be a floating-point type, and the target type must be a larger floating-point type.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let f32_ty = ctx.getFloatTy()
/// let f64_ty = ctx.getDoubleTy()
/// let fty = ctx.getFunctionType(f64_ty, [f32_ty])
///
/// let fval = mod.addFunction(fty, "fpext_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(bb)
/// let fpext = builder.createFPExt(arg, f64_ty, name="extended")
///
/// inspect(fpext, content = "  %extended = fpext float %0 to double")
/// ```
pub fn IRBuilder::createFPExt(
  self : Self,
  from : &Value,
  to : &FPType,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard from.getType().tryAsFPType() is Some(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createFPExt`: 'from' must be a floating-point type"
      ),
    )
  }
  let from_ref = from.getValueRef()
  let to_ref = to.getTypeRef()
  let res_valueref = @unsafe.llvm_build_fp_ext(
    self.builder_ref,
    from_ref,
    to_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantFP::ConstantFP(res_valueref) as &Value
    false => CastInst::CastInst(res_valueref)
  }
}

///| Create a FPToSI Instruction
///
/// **Note:**
/// 
/// This creates a floating-point to signed integer conversion instruction that converts a floating-point value to a signed integer.
/// The input value must be a floating-point type, and the target type must be an integer type.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let f32_ty = ctx.getFloatTy()
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [f32_ty])
///
/// let fval = mod.addFunction(fty, "fptosi_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(bb)
/// let fptosi = builder.createFPToSI(arg, i32_ty, name="converted")
///
/// inspect(fptosi, content = "  %converted = fptosi float %0 to i32")
/// ```
pub fn IRBuilder::createFPToSI(
  self : Self,
  from : &Value,
  to : &IntegerType,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard from.getType().tryAsFPType() is Some(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createFPToSI`: 'from' must be a floating-point type"
      ),
    )
  }
  let from_ref = from.getValueRef()
  let to_ref = to.getTypeRef()
  let res_valueref = @unsafe.llvm_build_fp_to_si(
    self.builder_ref,
    from_ref,
    to_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => CastInst::CastInst(res_valueref)
  }
}

///| Create a FPToUI Instruction
///
/// **Note:**
/// 
/// This creates a floating-point to unsigned integer conversion instruction that converts a floating-point value to an unsigned integer.
/// The input value must be a floating-point type, and the target type must be an integer type.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let f32_ty = ctx.getFloatTy()
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [f32_ty])
///
/// let fval = mod.addFunction(fty, "fptoui_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(bb)
/// let fptoui = builder.createFPToUI(arg, i32_ty, name="converted")
/// inspect(fptoui, content = "  %converted = fptoui float %0 to i32")
/// assert_true(fptoui.asValueEnum() is CastInst(_))
///
/// let float_val = ctx.getConstFloat(3.14)
/// let int_val = builder.createFPToUI(float_val, i32_ty)
/// inspect(int_val, content = "i32 3")
/// assert_true(int_val.asValueEnum() is ConstantInt(_))
/// ```
pub fn IRBuilder::createFPToUI(
  self : Self,
  from : &Value,
  to : &IntegerType,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard from.getType().tryAsFPType() is Some(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createFPToUI`: 'from' must be a floating-point type"
      ),
    )
  }
  let from_ref = from.getValueRef()
  let to_ref = to.getTypeRef()
  let res_valueref = @unsafe.llvm_build_fp_to_ui(
    self.builder_ref,
    from_ref,
    to_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantInt::ConstantInt(res_valueref) as &Value
    false => CastInst::CastInst(res_valueref)
  }
}

///| Create a SIToFP Instruction
///
/// **Note:**
/// 
/// This creates a signed integer to floating-point conversion instruction that converts a signed integer value to a floating-point value.
/// The input value must be an integer type, and the target type must be a floating-point type.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let f32_ty = ctx.getFloatTy()
/// let fty = ctx.getFunctionType(f32_ty, [i32_ty])
///
/// let fval = mod.addFunction(fty, "sitofp_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(bb)
/// let sitofp = builder.createSIToFP(arg, f32_ty, name="converted")
///
/// inspect(sitofp, content = "  %converted = sitofp i32 %0 to float")
/// ```
pub fn IRBuilder::createSIToFP(
  self : Self,
  from : &Value,
  to : &FPType,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard from.getType().tryAsIntType() is Some(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createSIToFP`: 'from' must be a integer type"
      ),
    )
  }
  let from_ref = from.getValueRef()
  let to_ref = to.getTypeRef()
  let res_valueref = @unsafe.llvm_build_si_to_fp(
    self.builder_ref,
    from_ref,
    to_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantFP::ConstantFP(res_valueref) as &Value
    false => CastInst::CastInst(res_valueref)
  }
}

///| Create a UIToFP Instruction
///
/// **Note:**
/// 
/// This creates an unsigned integer to floating-point conversion instruction that converts an unsigned integer value to a floating-point value.
/// The input value must be an integer type, and the target type must be a floating-point type.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let f32_ty = ctx.getFloatTy()
/// let fty = ctx.getFunctionType(f32_ty, [i32_ty])
///
/// let fval = mod.addFunction(fty, "uitofp_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(bb)
/// let uitofp = builder.createUIToFP(arg, f32_ty, name="converted")
/// inspect(uitofp, content = "  %converted = uitofp i32 %0 to float")
/// assert_true(uitofp.asValueEnum() is CastInst(_))
///
/// let int_val = ctx.getConstInt32(42)
/// let float_val = builder.createUIToFP(int_val, f32_ty)
/// assert_true(float_val.asValueEnum() is ConstantFP(_))
/// ```
pub fn IRBuilder::createUIToFP(
  self : Self,
  from : &Value,
  to : &FPType,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard from.getType().tryAsIntType() is Some(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createUIToFP`: 'from' must be a integer type"
      ),
    )
  }
  let from_ref = from.getValueRef()
  let to_ref = to.getTypeRef()
  let res_valueref = @unsafe.llvm_build_ui_to_fp(
    self.builder_ref,
    from_ref,
    to_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true => ConstantFP::ConstantFP(res_valueref) as &Value
    false => CastInst::CastInst(res_valueref)
  }
}

///| Create a BitCast Instruction
///
/// **Note:**
/// 
/// This creates a bitcast instruction that converts a value from one type to another without changing the bit representation.
/// The source and destination types must have the same bit width.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let f32_ty = ctx.getFloatTy()
/// let fty = ctx.getFunctionType(f32_ty, [i32_ty])
///
/// let fval = mod.addFunction(fty, "bitcast_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(bb)
/// let bitcast = builder.createBitCast(arg, f32_ty, name="bits")
///
/// inspect(bitcast, content = "  %bits = bitcast i32 %0 to float")
/// ```
pub fn IRBuilder::createBitCast(
  self : Self,
  from : &Value,
  to : &Type,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  let from_ref = from.getValueRef()
  let to_ref = to.getTypeRef()
  let res_valueref = @unsafe.llvm_build_bit_cast(
    self.builder_ref,
    from_ref,
    to_ref,
    name,
  )
  //CastInst::CastInst(res_valueref)
  match @unsafe.llvm_is_constant(res_valueref) {
    true =>
      match to.asTypeEnum() {
        Int1Type(_)
        | Int8Type(_)
        | Int16Type(_)
        | Int32Type(_)
        | Int64Type(_) => ConstantInt::ConstantInt(res_valueref) as &Value
        HalfType(_) | BFloatType(_) | FloatType(_) | DoubleType(_) =>
          ConstantFP::ConstantFP(res_valueref)
        StructType(_) => ConstantStruct::ConstantStruct(res_valueref)
        _ =>
          raise ValueTypeError(
            (
              $| loc: \{loc}:
              $| Unanticipated cosntant type in `createBitCast`, the to type is \{to}
            ),
          )
      }
    false => CastInst::CastInst(res_valueref)
  }
}

///| Create an IntToPtr Instruction
///
/// **Note:**
/// 
/// This creates an integer to pointer conversion instruction that converts an integer value to a pointer.
/// The input value must be an integer type, and the target type must be a pointer type.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i64_ty = ctx.getInt64Ty()
/// let ptr_ty = ctx.getPtrTy()
/// let fty = ctx.getFunctionType(ptr_ty, [i64_ty])
///
/// let fval = mod.addFunction(fty, "inttoptr_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(bb)
/// let inttoptr = builder.createIntToPtr(arg, ptr_ty, name="ptr")
///
/// inspect(inttoptr, content = "  %ptr = inttoptr i64 %0 to ptr")
/// ```
pub fn IRBuilder::createIntToPtr(
  self : Self,
  from : &Value,
  to : PointerType,
  name~ : String = ""
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard from.getType().tryAsIntType() is Some(_) else {
    raise ValueTypeError(
      "Misuse `IRBuilder::createIntToPtr`, from must be an integer type",
    )
  }
  let from_ref = from.getValueRef()
  let to_ref = to.getTypeRef()
  let res_valueref = @unsafe.llvm_build_int_to_ptr(
    self.builder_ref,
    from_ref,
    to_ref,
    name,
  )
  CastInst::CastInst(res_valueref)
}

///| Create a PtrToInt Instruction
///
/// **Note:**
/// 
/// This creates a pointer to integer conversion instruction that converts a pointer value to an integer.
/// The input value must be a pointer type, and the target type must be an integer type.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i64_ty = ctx.getInt64Ty()
/// let ptr_ty = ctx.getPtrTy()
/// let fty = ctx.getFunctionType(i64_ty, [ptr_ty])
///
/// let fval = mod.addFunction(fty, "ptrtoint_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(bb)
/// let ptrtoint = builder.createPtrToInt(arg, i64_ty, name="int_val")
///
/// inspect(ptrtoint, content = "  %int_val = ptrtoint ptr %0 to i64")
/// ```
pub fn IRBuilder::createPtrToInt(
  self : Self,
  from : &Value,
  to : &IntegerType,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard from.getType().asTypeEnum() is PointerType(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createPtrToInt`, from must be a pointer type",
      ),
    )
  }
  let from_ref = from.getValueRef()
  let to_ref = to.getTypeRef()
  let res_valueref = @unsafe.llvm_build_ptr_to_int(
    self.builder_ref,
    from_ref,
    to_ref,
    name,
  )
  CastInst::CastInst(res_valueref)
}

///| Create a GetElementPtr Instruction
///
/// **Note:**
/// 
/// This creates a getelementptr instruction that calculates the address of a sub-element of an aggregate object.
/// The pointer must be a pointer type, and all indices must be integer values.
/// When inbounds is true, the result is undefined if the computed address is outside the bounds of the allocated object.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let array_ty = ctx.getArrayType(i32_ty, 10)
/// let ptr_ty = ctx.getPtrTy()
/// let fty = ctx.getFunctionType(ctx.getPtrTy(), [ptr_ty])
///
/// let fval = mod.addFunction(fty, "gep_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let arg = fval.getArg(0).unwrap()
/// let zero = ctx.getConstInt32(0)
/// let two = ctx.getConstInt32(2)
///
/// builder.setInsertPoint(bb)
/// let gep = builder.createGEP(arg, array_ty, [zero, two], name="elem_ptr", inbounds=true)
///
/// inspect(gep, content = "  %elem_ptr = getelementptr inbounds [10 x i32], ptr %0, i32 0, i32 2")
/// ```
pub fn IRBuilder::createGEP(
  self : Self,
  ptr : &Value,
  pointeeType : &Type,
  indices : Array[&Value],
  name~ : String = "",
  inbounds~ : Bool = false,
  loc~ : SourceLoc = _
) -> GetElementPtrInst raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard ptr.getType().asTypeEnum() is PointerType(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createGEP`, ptr must be a pointer type"
      ),
    )
  }
  let ptr_ref = ptr.getValueRef()
  let pointee_ref = pointeeType.getTypeRef()
  indices.each(v => {
    guard v.getType().tryAsIntType() is Some(_) else {
      raise ValueTypeError(
        "Misuse `IRBuilder::createGEP`, All indices must be integer types",
      )
    }
  })
  let indices_refs = indices.map(v => v.getValueRef())
  let res_valueref = if inbounds {
    @unsafe.llvm_build_in_bounds_gep2(
      self.builder_ref,
      pointee_ref,
      ptr_ref,
      indices_refs,
      name,
    )
  } else {
    @unsafe.llvm_build_gep2(
      self.builder_ref,
      pointee_ref,
      ptr_ref,
      indices_refs,
      name,
    )
  }
  GetElementPtrInst(res_valueref)
}

///| Create an Unconditional Branch Instruction
///
/// **Note:**
/// 
/// This creates an unconditional branch instruction that transfers control to the specified basic block.
/// The destination must be a valid basic block.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let void_ty = ctx.getVoidTy()
/// let fty = ctx.getFunctionType(void_ty, [])
///
/// let fval = mod.addFunction(fty, "br_demo")
/// let entry_bb = fval.addBasicBlock(name="entry")
/// let target_bb = fval.addBasicBlock(name="target")
///
/// builder.setInsertPoint(entry_bb)
/// let br = builder.createBr(target_bb)
///
/// inspect(br, content = "  br label %target")
/// ```
pub fn IRBuilder::createBr(self : Self, dest : BasicBlock) -> BranchInst raise {
  guard self.positioned is Set else { raise UnsetPosition }
  let dest_ref = dest.inner()
  let res_valueref = @unsafe.llvm_build_br(self.builder_ref, dest_ref)
  BranchInst(res_valueref)
}

///| Create a Conditional Branch Instruction
///
/// **Note:**
/// 
/// This creates a conditional branch instruction that transfers control to one of two basic blocks based on a boolean condition.
/// The condition must be an i1 (boolean) type, and both destinations must be valid basic blocks.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i1_ty = ctx.getInt1Ty()
/// let void_ty = ctx.getVoidTy()
/// let fty = ctx.getFunctionType(void_ty, [i1_ty])
///
/// let fval = mod.addFunction(fty, "cond_br_demo")
/// let entry_bb = fval.addBasicBlock(name="entry")
/// let true_bb = fval.addBasicBlock(name="true_branch")
/// let false_bb = fval.addBasicBlock(name="false_branch")
/// let cond = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(entry_bb)
/// let cond_br = builder.createCondBr(cond, true_bb, false_bb)
///
/// inspect(cond_br, content = "  br i1 %0, label %true_branch, label %false_branch")
/// ```
pub fn IRBuilder::createCondBr(
  self : Self,
  cond : &Value,
  trueDest : BasicBlock,
  falseDest : BasicBlock,
  loc~ : SourceLoc = _
) -> BranchInst raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard cond.getType().tryAsIntTypeEnum() is Some(Int1Type(_)) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createCondBr`, cond must be i1 type
      ),
    )
  }
  let cond_ref = cond.getValueRef()
  let true_dest_ref = trueDest.inner()
  let false_dest_ref = falseDest.inner()
  let res_valueref = @unsafe.llvm_build_cond_br(
    self.builder_ref,
    cond_ref,
    true_dest_ref,
    false_dest_ref,
  )
  BranchInst(res_valueref)
}

///| Create a Select Instruction
///
/// **Note:**
/// 
/// This creates a select instruction that chooses between two values based on a boolean condition.
/// The condition must be an i1 (boolean) type, and both values must have the same type.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i1_ty = ctx.getInt1Ty()
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [i1_ty, i32_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "select_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let cond = fval.getArg(0).unwrap()
/// let true_val = fval.getArg(1).unwrap()
/// let false_val = fval.getArg(2).unwrap()
///
/// builder.setInsertPoint(bb)
/// let select = builder.createSelect(cond, true_val, false_val, name="result")
///
/// inspect(select, content = "  %result = select i1 %0, i32 %1, i32 %2")
/// ```
pub fn IRBuilder::createSelect(
  self : Self,
  cond : &Value,
  trueVal : &Value,
  falseVal : &Value,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard cond.getType().tryAsIntTypeEnum() is Some(Int1Type(_)) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createSelect`, cond must be i1 type",
      ),
    )
  }
  let cond_ref = cond.getValueRef()
  let true_val_ref = trueVal.getValueRef()
  let false_val_ref = falseVal.getValueRef()
  let res_valueref = @unsafe.llvm_build_select(
    self.builder_ref,
    cond_ref,
    true_val_ref,
    false_val_ref,
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true =>
      match trueVal.getType().asTypeEnum() {
        Int1Type(_)
        | Int8Type(_)
        | Int16Type(_)
        | Int32Type(_)
        | Int64Type(_) => ConstantInt::ConstantInt(res_valueref) as &Value
        HalfType(_) | BFloatType(_) | FloatType(_) | DoubleType(_) =>
          ConstantFP::ConstantFP(res_valueref)
        StructType(_) => ConstantStruct::ConstantStruct(res_valueref)
        ArrayType(_) => ConstantArray::ConstantArray(res_valueref)
        VectorType(_) => ConstantVector::ConstantVector(res_valueref)
        _ =>
          raise ValueTypeError(
            "Unanticipated constant type in `createSelect`, the trueVal type is \{trueVal.getType()}",
          )
      }
    false => SelectInst::SelectInst(res_valueref)
  }
}

///| Create a Switch Instruction
///
/// **Note:**
/// 
/// This creates a switch instruction that transfers control to one of many basic blocks based on an integer value.
/// The value must be an integer type, and numCases specifies the expected number of cases.
/// Use `SwitchInst::addCase` to add individual cases after creation.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let void_ty = ctx.getVoidTy()
/// let fty = ctx.getFunctionType(void_ty, [i32_ty])
///
/// let fval = mod.addFunction(fty, "switch_demo")
/// let entry_bb = fval.addBasicBlock(name="entry")
/// let case1_bb = fval.addBasicBlock(name="case1")
/// let default_bb = fval.addBasicBlock(name="default")
/// let value = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(entry_bb)
/// let switch = builder.createSwitch(value, default_bb)
/// let case_val = ctx.getConstInt32(42)
/// switch.addCase(case_val, case1_bb)
///
/// let expect = 
///   #|  switch i32 %0, label %default [
///   #|    i32 42, label %case1
///   #|  ]
///
/// inspect(switch, content = expect)
/// ```
pub fn IRBuilder::createSwitch(
  self : Self,
  value : &Value,
  defaultDest : BasicBlock,
  loc~ : SourceLoc = _
) -> SwitchInst raise {
  // use `SwitchInst::addCase` to add cases.
  guard self.positioned is Set else { raise UnsetPosition }
  guard value.getType().tryAsIntType() is Some(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createSwitch`, value must be an integer type",
      ),
    )
  }
  let value_ref = value.getValueRef()
  let default_dest_ref = defaultDest.inner()
  let res_valueref = @unsafe.llvm_build_switch(
    self.builder_ref,
    value_ref,
    default_dest_ref,
    0,
  )
  SwitchInst(res_valueref)
}

///| Create a PHI Instruction
///
/// **Note:**
/// 
/// This creates a PHI node instruction that selects a value based on the predecessor basic block.
/// The type specifies the type of the PHI node's result value.
/// Use `PHINode::addIncoming` to add incoming values and their corresponding basic blocks.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let fty = ctx.getFunctionType(i32_ty, [])
///
/// let fval = mod.addFunction(fty, "phi_demo")
/// let entry_bb = fval.addBasicBlock(name="entry")
/// let block_bb = fval.addBasicBlock(name="block")
/// let merge_bb = fval.addBasicBlock(name="merge")
/// let val1 = ctx.getConstInt32(10)
/// let val2 = ctx.getConstInt32(20)
///
/// builder.setInsertPoint(merge_bb)
/// let phi = builder.createPHI(i32_ty, name="result")
/// phi.addIncoming(val1, entry_bb)
/// phi.addIncoming(val2, block_bb)
///
/// inspect(phi, content = "  %result = phi i32 [ 10, %entry ], [ 20, %block ]")
/// ```
pub fn IRBuilder::createPHI(
  self : Self,
  type_ : &Type,
  name~ : String = ""
) -> PHINode raise {
  // use `PHINode::addIncoming` to add incoming values.
  guard self.positioned is Set else { raise UnsetPosition }
  let type_ref = type_.getTypeRef()
  let res_valueref = @unsafe.llvm_build_phi(self.builder_ref, type_ref, name)
  PHINode(res_valueref)
}

///| Create a Call Instruction
///
/// **Note:**
/// 
/// This creates a call instruction that invokes a function with the specified arguments.
/// The function must be a valid Function object, and the arguments must match the function's parameter types.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let add_fty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
/// let main_fty = ctx.getFunctionType(i32_ty, [])
///
/// let add_func = mod.addFunction(add_fty, "add")
/// let main_func = mod.addFunction(main_fty, "main")
/// let bb = main_func.addBasicBlock(name="entry")
/// let arg1 = ctx.getConstInt32(10)
/// let arg2 = ctx.getConstInt32(20)
///
/// builder.setInsertPoint(bb)
/// let call = builder.createCall(add_func, [arg1, arg2], name="sum")
///
/// inspect(call, content = "  %sum = call i32 @add(i32 10, i32 20)")
/// ```
pub fn IRBuilder::createCall(
  self : Self,
  func : Function,
  args : Array[&Value],
  name~ : String = "",
  loc~ : SourceLoc = _
) -> CallInst raise {
  guard self.positioned is Set else { raise UnsetPosition }
  let func_ty = func.getType()
  let param_tys = func_ty.getParamTypes()
  let arg_tys = args.map(v => v.getType())
  guard param_tys == arg_tys else {
    raise InValidArgument(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createCall`, arguments must match function parameter types
        $|    param_tys: \{param_tys}
        $|    arg_tys: \{arg_tys}
      ),
    )
  }
  let func_type_ref = func_ty.getTypeRef()
  let func_ref = func.getValueRef()
  let args_refs = args.map(v => v.getValueRef())
  let res_valueref = @unsafe.llvm_build_call2(
    self.builder_ref,
    func_type_ref,
    func_ref,
    args_refs,
    name,
  )
  CallInst(res_valueref)
}

///| Create a Call Instruction via Function Pointer
///
/// **Note:**
/// 
/// This creates a call instruction that invokes a function through a function pointer.
/// The function pointer must be a pointer type, and the function type must match the pointed-to function's signature.
/// The arguments must match the function's parameter types.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let func_ty = ctx.getFunctionType(i32_ty, [i32_ty, i32_ty])
/// let func_ptr_ty = ctx.getPtrTy()
/// let main_fty = ctx.getFunctionType(i32_ty, [func_ptr_ty])
///
/// let main_func = mod.addFunction(main_fty, "main")
/// let bb = main_func.addBasicBlock(name="entry")
/// let func_ptr = main_func.getArg(0).unwrap()
/// let arg1 = ctx.getConstInt32(10)
/// let arg2 = ctx.getConstInt32(20)
///
/// builder.setInsertPoint(bb)
/// let call = builder.createCallPtr(func_ptr, func_ty, [arg1, arg2], name="result")
///
/// inspect(call, content = "  %result = call i32 %0(i32 10, i32 20)")
/// ```
pub fn IRBuilder::createCallPtr(
  self : Self,
  funcPtr : &Value,
  funcType : FunctionType,
  args : Array[&Value],
  name~ : String = "",
  loc~ : SourceLoc = _
) -> CallInst raise {
  // REVIEW: Check if it is correct.
  guard self.positioned is Set else { raise UnsetPosition }
  guard funcPtr.getType().asTypeEnum() is PointerType(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createCallPtr`, funcPtr must be a pointer type
      ),
    )
  }
  let func_type_ref = funcType.getTypeRef()
  let func_ptr_ref = funcPtr.getValueRef()
  let args_refs = args.map(v => v.getValueRef())
  let res_valueref = @unsafe.llvm_build_call2(
    self.builder_ref,
    func_type_ref,
    func_ptr_ref,
    args_refs,
    name,
  )
  CallInst(res_valueref)
}

///| Create an InsertValue Instruction
///
/// **Note:**
/// 
/// This creates an insertvalue instruction that inserts a value into an aggregate (struct or array) at the specified index.
/// The aggregate must be an aggregate type, and the value type must match the element type at the given index.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let struct_ty = ctx.getStructType([i32_ty, i32_ty])
/// let fty = ctx.getFunctionType(struct_ty, [struct_ty, i32_ty])
///
/// let fval = mod.addFunction(fty, "insertvalue_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let aggregate = fval.getArg(0).unwrap()
/// let new_value = fval.getArg(1).unwrap()
///
/// builder.setInsertPoint(bb)
/// let insert = builder.createInsertValue(aggregate, new_value, 1, name="updated")
///
/// inspect(insert, content = "  %updated = insertvalue { i32, i32 } %0, i32 %1, 1")
/// ```
pub fn IRBuilder::createInsertValue(
  self : Self,
  aggregate : &Value,
  value : &Value,
  index : Int,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard aggregate.getType().tryAsAggregateType() is Some(aggre_ty) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createInsertValue`, aggregate must be an aggregate type
      ),
    )
  }
  guard aggre_ty.getElementType(index) is Some(aggre_elem_ty) else {
    raise InValidArgument(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createInsertValue`, index out of bounds for aggregate type
      ),
    )
  }
  guard aggre_elem_ty == value.getType() else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createInsertValue`, value type must match the aggregate element type at index
      ),
    )
  }
  let aggregate_ref = aggregate.getValueRef()
  let value_ref = value.getValueRef()
  let res_valueref = @unsafe.llvm_build_insert_value(
    self.builder_ref,
    aggregate_ref,
    value_ref,
    index.reinterpret_as_uint(),
    name,
  )
  match @unsafe.llvm_is_constant(res_valueref) {
    true =>
      match aggregate.getType().asTypeEnum() {
        StructType(_) => ConstantStruct::ConstantStruct(res_valueref) as &Value
        ArrayType(_) => ConstantArray::ConstantArray(res_valueref)
        VectorType(_) => ConstantVector::ConstantVector(res_valueref)
        _ =>
          raise ValueTypeError(
            "Unanticipated constant type in `createInsertValue`, the aggregate type is \{aggregate.getType()}",
          )
      }
    false => InsertValueInst::InsertValueInst(res_valueref)
  }
}

///| Create an ExtractValue Instruction
///
/// **Note:**
/// 
/// This creates an extractvalue instruction that extracts a value from an aggregate (struct or array) at the specified index.
/// The aggregate must be an aggregate type, and the index must be valid for the aggregate type.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let struct_ty = ctx.getStructType([i32_ty, i32_ty])
/// let fty = ctx.getFunctionType(i32_ty, [struct_ty])
///
/// let fval = mod.addFunction(fty, "extractvalue_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let aggregate = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(bb)
/// let extract = builder.createExtractValue(aggregate, 0, name="field")
///
/// inspect(extract, content = "  %field = extractvalue { i32, i32 } %0, 0")
/// ```
pub fn IRBuilder::createExtractValue(
  self : Self,
  aggregate : &Value,
  index : Int,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> &Value raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard aggregate.getType().tryAsAggregateType() is Some(aggre_ty) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createExtractValue`, aggregate must be an aggregate type",
      ),
    )
  }
  match aggre_ty.asAggregateTypeEnum() {
    StructType(sty) => {
      guard index >= 0 && index < sty.numOfElements() else {
        raise InValidArgument(
          (
            $| loc: \{loc}:
            #| Misuse `IRBuilder::createExtractValue`, index out of bounds for struct type",
          ),
        )
      }
    }
    ArrayType(aty) => {
      guard index >= 0 && index < aty.getElementCount() else {
        raise InValidArgument(
          (
            $| loc: \{loc}:
            #| Misuse `IRBuilder::createExtractValue`, index out of bounds for array type",
          ),
        )
      }
    }
    VectorType(vty) => {
      guard index >= 0 && index < vty.getElementCount() else {
        raise InValidArgument(
          (
            $| loc: \{loc}:
            #| Misuse `IRBuilder::createExtractValue`, index out of bounds for vector type",
          ),
        )
      }
    }
    ScalableVectorType(_) =>
      raise UnImplemented(
        "Misuse `IRBuilder::createExtractValue`, cannot extract from scalable vector types",
      )
  }
  let aggregate_ref = aggregate.getValueRef()
  let res_valueref = @unsafe.llvm_build_extract_value(
    self.builder_ref,
    aggregate_ref,
    index.reinterpret_as_uint(),
    name,
  )
  //ExtractValueInst::ExtractValueInst(res_valueref)
  match @unsafe.llvm_is_constant(res_valueref) {
    true =>
      match aggregate.getType().asTypeEnum() {
        Int1Type(_)
        | Int8Type(_)
        | Int16Type(_)
        | Int32Type(_)
        | Int64Type(_) => ConstantInt::ConstantInt(res_valueref) as &Value
        HalfType(_) | BFloatType(_) | FloatType(_) | DoubleType(_) =>
          ConstantFP::ConstantFP(res_valueref)
        StructType(_) => ConstantStruct::ConstantStruct(res_valueref) as &Value
        ArrayType(_) => ConstantArray::ConstantArray(res_valueref)
        VectorType(_) => ConstantVector::ConstantVector(res_valueref)
        _ =>
          raise ValueTypeError(
            "Unanticipated constant type in `createExtractValue`, the aggregate type is \{aggregate.getType()}",
          )
      }
    false => ExtractValueInst::ExtractValueInst(res_valueref)
  }
}

///| Create a Malloc Instruction
///
/// **Note:**
/// 
/// This creates a malloc instruction that allocates memory for a single instance of the specified type.
/// The type must not be an abstract type. The result is a pointer to the allocated memory.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let i32_ty = ctx.getInt32Ty()
/// let ptr_ty = ctx.getPtrTy()
/// let fty = ctx.getFunctionType(ptr_ty, [])
///
/// let fval = mod.addFunction(fty, "malloc_demo")
/// let bb = fval.addBasicBlock(name="entry")
///
/// builder.setInsertPoint(bb)
/// let malloc = builder.createMalloc(i32_ty, name="ptr")
///
/// inspect(malloc, content = "  %ptr = tail call ptr @malloc(i32 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i32))")
/// ```
pub fn IRBuilder::createMalloc(
  self : Self,
  ty : &Type,
  name~ : String = "",
  loc~ : SourceLoc = _
) -> CallInst raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard not(ty.tryAsAbstractType() is Some(_)) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        $| Misuse `IRBuilder::createMalloc`, ty must not be an abstract type, type is \{ty}
      ),
    )
  }
  let typeref = ty.getTypeRef()
  let res_valueref = @unsafe.llvm_build_malloc(self.builder_ref, typeref, name)
  CallInst(res_valueref)
}

///| Create a Free Instruction
///
/// **Note:**
/// 
/// This creates a free instruction that deallocates memory previously allocated by malloc.
/// The pointer must be a pointer type and should point to memory allocated by malloc.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let void_ty = ctx.getVoidTy()
/// let ptr_ty = ctx.getPtrTy()
/// let fty = ctx.getFunctionType(void_ty, [ptr_ty])
///
/// let fval = mod.addFunction(fty, "free_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let ptr_arg = fval.getArg(0).unwrap()
///
/// builder.setInsertPoint(bb)
/// let free = builder.createFree(ptr_arg)
///
/// inspect(free, content = "  tail call void @free(ptr %0)")
/// ```
pub fn IRBuilder::createFree(
  self : Self,
  ptr : &Value,
  loc~ : SourceLoc = _
) -> CallInst raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard ptr.getType().asTypeEnum() is PointerType(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}
        #| Misuse `IRBuilder::createFree`, ptr must be a pointer type",
      ),
    )
  }
  let ptr_ref = ptr.getValueRef()
  let res_valueref = @unsafe.llvm_build_free(self.builder_ref, ptr_ref)
  CallInst(res_valueref)
}

///| Create a Memory Copy Instruction
///
/// **Note:**
/// 
/// This creates a memcpy instruction that copies bytes from source to destination.
/// Both dst and src must be pointer types, and size must be an integer type.
/// The dst_align and src_align parameters specify the alignment requirements.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let void_ty = ctx.getVoidTy()
/// let ptr_ty = ctx.getPtrTy()
/// let i64_ty = ctx.getInt64Ty()
/// let fty = ctx.getFunctionType(void_ty, [ptr_ty, ptr_ty, i64_ty])
///
/// let fval = mod.addFunction(fty, "memcpy_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let dst = fval.getArg(0).unwrap()
/// let src = fval.getArg(1).unwrap()
/// let size = fval.getArg(2).unwrap()
///
/// builder.setInsertPoint(bb)
/// let memcpy = builder.createMemCpy(dst, 4, src, 4, size)
///
/// inspect(memcpy, content = "  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %0, ptr align 4 %1, i64 %2, i1 false)")
/// ```
pub fn IRBuilder::createMemCpy(
  self : Self,
  dst : &Value,
  dst_align : Int,
  src : &Value,
  src_align : Int,
  size : &Value,
  loc~ : SourceLoc = _
) -> CallInst raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard dst.getType().asTypeEnum() is PointerType(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createMemcpy`, dst must be a pointer type",
      ),
    )
  }
  guard src.getType().asTypeEnum() is PointerType(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createMemcpy`, src must be a pointer type",
      ),
    )
  }
  guard size.getType().tryAsIntType() is Some(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createMemcpy`, size must be an integer type",
      ),
    )
  }
  let dst_ref = dst.getValueRef()
  let dst_align = dst_align.reinterpret_as_uint()
  let src_ref = src.getValueRef()
  let src_align = src_align.reinterpret_as_uint()
  let size_ref = size.getValueRef()
  let res_valueref = @unsafe.llvm_build_mem_cpy(
    self.builder_ref,
    dst_ref,
    dst_align,
    src_ref,
    src_align,
    size_ref,
  )
  CallInst(res_valueref)
}

///| Create a Memory Set Instruction
///
/// **Note:**
/// 
/// This creates a memset instruction that sets bytes in memory to a specific value.
/// The dst must be a pointer type, value must be an integer type (typically i8), 
/// and size must be an integer type. The align parameter specifies the alignment.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let void_ty = ctx.getVoidTy()
/// let ptr_ty = ctx.getPtrTy()
/// let i8_ty = ctx.getInt8Ty()
/// let i64_ty = ctx.getInt64Ty()
/// let fty = ctx.getFunctionType(void_ty, [ptr_ty, i8_ty, i64_ty])
///
/// let fval = mod.addFunction(fty, "memset_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let dst = fval.getArg(0).unwrap()
/// let value = fval.getArg(1).unwrap()
/// let size = fval.getArg(2).unwrap()
///
/// builder.setInsertPoint(bb)
/// let memset = builder.createMemSet(dst, value, size, 4)
///
/// inspect(memset, content = "  call void @llvm.memset.p0.i64(ptr align 4 %0, i8 %1, i64 %2, i1 false)")
/// ```
pub fn IRBuilder::createMemSet(
  self : Self,
  dst : &Value,
  value : &Value,
  size : &Value,
  align : Int,
  loc~ : SourceLoc = _
) -> CallInst raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard dst.getType().asTypeEnum() is PointerType(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createMemSet`, dst must be a pointer type",
      ),
    )
  }
  guard value.getType().tryAsIntType() is Some(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createMemSet`, value must be an integer type",
      ),
    )
  }
  guard size.getType().tryAsIntType() is Some(_) else {
    raise ValueTypeError(
      (
        $| loc: \{loc}:
        #| Misuse `IRBuilder::createMemSet`, size must be an integer type",
      ),
    )
  }
  let dst_ref = dst.getValueRef()
  let value_ref = value.getValueRef()
  let size_ref = size.getValueRef()
  let align = align.reinterpret_as_uint()
  let res_valueref = @unsafe.llvm_build_mem_set(
    self.builder_ref,
    dst_ref,
    value_ref,
    size_ref,
    align,
  )
  CallInst(res_valueref)
}

///| Create a Memory Move Instruction
///
/// **Note:**
/// 
/// This creates a memmove instruction that copies bytes from source to destination.
/// Unlike memcpy, memmove handles overlapping memory regions correctly.
/// Both dst and src must be pointer types, and size must be an integer type.
/// The dst_align and src_align parameters specify the alignment requirements.
///
/// ```moonbit
/// let ctx = Context::new()
/// let mod = ctx.addModule("demo")
/// let builder = ctx.createBuilder()
///
/// let void_ty = ctx.getVoidTy()
/// let ptr_ty = ctx.getPtrTy()
/// let i64_ty = ctx.getInt64Ty()
/// let fty = ctx.getFunctionType(void_ty, [ptr_ty, ptr_ty, i64_ty])
///
/// let fval = mod.addFunction(fty, "memmove_demo")
/// let bb = fval.addBasicBlock(name="entry")
/// let dst = fval.getArg(0).unwrap()
/// let src = fval.getArg(1).unwrap()
/// let size = fval.getArg(2).unwrap()
///
/// builder.setInsertPoint(bb)
/// let memmove = builder.createMemMove(dst, 4, src, 4, size)
///
/// inspect(memmove, content = "  call void @llvm.memmove.p0.p0.i64(ptr align 4 %0, ptr align 4 %1, i64 %2, i1 false)")
/// ```
pub fn IRBuilder::createMemMove(
  self : Self,
  dst : &Value,
  dst_align : Int,
  src : &Value,
  src_align : Int,
  size : &Value,
  loc~ : SourceLoc = _
) -> CallInst raise {
  guard self.positioned is Set else { raise UnsetPosition }
  guard dst.getType().asTypeEnum() is PointerType(_) else {
    raise ValueTypeError(
      (
        $| loc \{loc}:
        #| Misuse `IRBuilder::createMemMove`, dst must be a pointer type
      ),
    )
  }
  guard src.getType().asTypeEnum() is PointerType(_) else {
    raise ValueTypeError(
      (
        $| loc \{loc}:
        #| Misuse `IRBuilder::createMemMove`, src must be a pointer type
      ),
    )
  }
  guard size.getType().tryAsIntType() is Some(_) else {
    raise ValueTypeError(
      (
        $| loc \{loc}:
        #| Misuse `IRBuilder::createMemMove`, size must be an integer type
      ),
    )
  }
  let dst_ref = dst.getValueRef()
  let dst_align = dst_align.reinterpret_as_uint()
  let src_ref = src.getValueRef()
  let src_align = src_align.reinterpret_as_uint()
  let size_ref = size.getValueRef()
  let res_valueref = @unsafe.llvm_build_mem_move(
    self.builder_ref,
    dst_ref,
    dst_align,
    src_ref,
    src_align,
    size_ref,
  )
  CallInst(res_valueref)
}
