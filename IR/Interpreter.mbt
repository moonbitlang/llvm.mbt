///|
typealias @unsafe.LLVMExecutionEngineRef as ExecutionEngineRef

///|
pub type GenericValue @unsafe.LLVMGenericValueRef

///|
pub suberror InterpreterError {
  CreateInterpreterFailed(String)
} derive(Show)

///|
pub struct Interpreter {
  engine : ExecutionEngineRef
  mod : Module
  ctx : Context
}

///|
pub fn Interpreter::inner(self : Self) -> ExecutionEngineRef {
  self.engine
}

///|
fn Interpreter::construct(
  engine : ExecutionEngineRef,
  mod : Module,
  ctx : Context
) -> Interpreter {
  Interpreter::{ engine, mod, ctx }
}

///|
pub fn Interpreter::createGenericValueInt(
  self : Self,
  value : Int
) -> GenericValue {
  let typeref = self.ctx.getInt32Ty().getTypeRef()
  @unsafe.llvm_create_generic_value_of_int(typeref, value.to_uint64(), true)
}

///|
pub fn Interpreter::createGenericValueUInt(
  self : Self,
  value : UInt
) -> GenericValue {
  let typeref = self.ctx.getInt32Ty().getTypeRef()
  @unsafe.llvm_create_generic_value_of_int(typeref, value.to_uint64(), false)
}

///|
pub fn Interpreter::createGenericValueInt64(
  self : Self,
  value : Int64
) -> GenericValue {
  let typeref = self.ctx.getInt64Ty().getTypeRef()
  @unsafe.llvm_create_generic_value_of_int(
    typeref,
    value.reinterpret_as_uint64(),
    true,
  )
}

///|
pub fn Interpreter::createGenericValueUInt64(
  self : Self,
  value : UInt64
) -> GenericValue {
  let typeref = self.ctx.getInt64Ty().getTypeRef()
  @unsafe.llvm_create_generic_value_of_int(typeref, value, true)
}

///|
pub fn Interpreter::createGenericValueFloat(
  self : Self,
  value : Float
) -> GenericValue {
  let typeref = self.ctx.getFloatTy().getTypeRef()
  @unsafe.llvm_create_generic_value_of_float(typeref, value.to_double())
}

///|
pub fn Interpreter::createGenericValueDouble(
  self : Self,
  value : Double
) -> GenericValue {
  let typeref = self.ctx.getDoubleTy().getTypeRef()
  @unsafe.llvm_create_generic_value_of_float(typeref, value)
}

///|
pub fn Interpreter::runFunction(
  self : Self,
  func : Function,
  args : Array[GenericValue]
) -> GenericValue {
  let args_ref = args.map(arg => arg.inner())
  @unsafe.llvm_run_function(self.inner(), func.inner(), args_ref)
}

// ====================================================
// GenericValue
// ====================================================

///|
pub fn GenericValue::toInt(self : GenericValue) -> Int {
  @unsafe.llvm_generic_value_to_int(self.inner(), true).to_int()
}

///|
pub fn GenericValue::toUInt(self : GenericValue) -> UInt {
  @unsafe.llvm_generic_value_to_int(self.inner(), false).to_uint()
}

///|
pub fn GenericValue::toInt64(self : GenericValue) -> Int64 {
  @unsafe.llvm_generic_value_to_int(self.inner(), true).reinterpret_as_int64()
}

///|
pub fn GenericValue::toUInt64(self : GenericValue) -> UInt64 {
  @unsafe.llvm_generic_value_to_int(self.inner(), false)
}
