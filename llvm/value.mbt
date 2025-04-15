// ===================================
// Values
// ===================================
struct Value {
  value_ref: @unsafe.LLVMValueRef
}

fn Value::new(value_ref: @unsafe.LLVMValueRef) -> Value {
  if value_ref.is_null() {
    println("Value is null")
    panic()
  }

  Value::{
    value_ref
  }
}

fn Value::as_value_ref(self: Value) -> @unsafe.LLVMValueRef {
  self.value_ref
}

fn Value::is_instruction(self: Value) -> Bool {
  @unsafe.llvm_isa_instruction(self.as_value_ref()).is_null() |> not
}

fn Value::as_instruction(self: Value) -> InstructionValue? {
  if not(self.is_instruction()) {
    return None
  }

  Some(InstructionValue::new(self.as_value_ref()))
}

fn Value::is_null(self: Value) -> Bool {
  self.as_value_ref().is_null()
}

fn Value::is_const(self: Value) -> Bool {
  @unsafe.llvm_is_constant(self.as_value_ref())
}

fn Value::is_poison(self: Value) -> Bool {
  @unsafe.llvm_is_poison(self.as_value_ref())
}

fn Value::set_name(self: Value, name: String) -> Unit {
  let value_ref = self.as_value_ref()
  @unsafe.llvm_set_value_name(value_ref, name)
}

// TODO: This API use `@unsafe.LLVMGetValueName2` possibly problematic
fn Value::get_name(self: Value) -> String {
  self.as_value_ref().get_name()

}

fn Value::is_undef(self: Value) -> Bool {
  self.as_value_ref().is_undef()
}

fn Value::get_type(self: Value) -> Type {
  let type_ref = @unsafe.llvm_type_of(self.as_value_ref())
  Type::new(type_ref)
}

fn Value::replace_all_uses_with(self: Value, new_value: Value) -> Unit {
  @unsafe.llvm_replace_all_uses_with(self.as_value_ref(), new_value.as_value_ref())
}

fn Value::get_first_use(self: Value) -> BasicValueUse? {
  let use_ = @unsafe.llvm_get_first_use(self.as_value_ref())

  if use_.is_null() {
    None
  } else {
    Some(BasicValueUse::new(use_))
  }
}

// pub fn get_section(self: Value) -> String?
// pub fn set_section(self: Value) -> String?

fn Value::print_to_stderr(self: Value) -> Unit {
  @unsafe.llvm_dump_value(self.as_value_ref())
}

fn Value::print_to_string(self: Value) -> String {
  @unsafe.llvm_print_value_to_string(self.as_value_ref())
}

fn Value::to_string(self: Value) -> String {
  @unsafe.llvm_print_value_to_string(self.as_value_ref())
}

fn Value::dump(self: Value) -> Unit {
  @unsafe.llvm_dump_value(self.as_value_ref())
}

pub impl Show for Value with output(self: Value, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

pub impl Eq for Value with op_equal(self: Value, other: Value) -> Bool {
  self.as_value_ref() == other.as_value_ref()
}
// ============================================
// CallableValue
// ============================================
pub struct CallableValue {
  either_value: Either[FunctionValue, PointerValue]
}

pub fn CallableValue::as_value_ref(self: CallableValue) -> @unsafe.LLVMValueRef {
  match self.either_value {
    Left(f) => f.as_value_ref()
    Right(p) => p.as_value_ref()
  }
}

pub fn CallableValue::fromf(f: FunctionValue) -> CallableValue {
  CallableValue::{
    either_value: Left(f)
  }
}

pub fn CallableValue::fromp(p: PointerValue) -> CallableValue {
  CallableValue::{
    either_value: Right(p)
  }
}

pub impl AsValueRef for CallableValue with as_value_ref(self: CallableValue) -> @unsafe.LLVMValueRef {
  self.as_value_ref()
}
