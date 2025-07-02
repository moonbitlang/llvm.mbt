
pub trait Value {
  base(Self) -> ValueRef;
  inner(Self) -> @unsafe.LLVMValueRef = _
  dump(Self) -> Unit = _;
  print_to_stderr(Self) -> Unit = _;
  as_value_enum(Self) -> ValueEnum;
}

impl Value with inner(self) {
  self.base().inner()
}

impl Value with print_to_stderr(self) {
  self.base().print_to_stderr()
}

impl Value with dump(self) {
  self.base().dump()
}

pub enum ValueEnum {
  IntValue(IntValue)
  FloatValue(FloatValue)
  PointerValue(PointerValue)
  StructValue(StructValue)
  FunctionValue(FunctionValue)
  VectorValue(VectorValue)
  PhiValue(PhiValue)
  ScalableVectorValue(ScalableVectorValue)
  MetadataValue(MetadataValue)
  CallSiteValue(CallSiteValue)
  GlobalValue(GlobalValue)
  InstructionValue(InstructionValue)
}
