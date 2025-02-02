// ===================================
// Values
// ===================================
pub struct Value {
  value_ref: LLVMValueRef
}

pub fn Value::new(value_ref: LLVMValueRef) -> Value {
  if llvm_is_null(value_ref) == 1 {
    println("Value is null")
    panic()
  }

  Value::{
    value_ref
  }
}

pub fn Value::as_value_ref(self: Value) -> LLVMValueRef {
  self.value_ref
}

pub fn Value::is_instruction(self: Value) -> Bool {
  llvm_isa_instruction(self.as_value_ref()).is_null()
}

pub fn Value::as_instruction(self: Value) -> InstructionValue? {
  if not(self.is_instruction()) {
    return None
  }

  Some(InstructionValue::new(self.as_value_ref()))
}

pub fn Value::is_null(self: Value) -> Bool {
  llvm_is_null(self.as_value_ref()) == 1
}

pub fn Value::is_const(self: Value) -> Bool {
  llvm_is_constant(self.as_value_ref())
}

pub fn Value::set_name(self: Value, name: String) -> Unit {
  let value_ref = self.as_value_ref()
  llvm_set_value_name(value_ref, name)
}

// TODO: This API use `LLVMGetValueName2` possibly problematic
pub fn Value::get_name(self: Value) -> String {
  self.as_value_ref().get_name()

}

fn Value::is_undef(self: Value) -> Bool {
  self.as_value_ref().is_undef()
}

fn Value::get_type(self: Value) -> Type {
  let type_ref = llvm_type_of(self.as_value_ref())
  Type::new(type_ref)
}

fn Value::replace_all_uses_with(self: Value, new_value: Value) -> Unit {
  llvm_replace_all_uses_with(self.as_value_ref(), new_value.as_value_ref())
}

pub fn Value::get_first_use(self: Value) -> BasicValueUse? {
  let use_ = llvm_get_first_use(self.as_value_ref())

  if use_.is_null() {
    None
  } else {
    Some(BasicValueUse::new(use_))
  }
}

// pub fn get_section(self: Value) -> String?
// pub fn set_section(self: Value) -> String?

pub fn Value::print_to_stderr(self: Value) -> Unit {
  llvm_dump_value(self.as_value_ref())
}

pub fn Value::print_to_string(self: Value) -> String {
  llvm_print_value_to_string(self.as_value_ref())
}

pub fn Value::to_string(self: Value) -> String {
  llvm_print_value_to_string(self.as_value_ref())
}

pub fn Value::dump(self: Value) -> Unit {
  llvm_dump_value(self.as_value_ref())
}

pub impl Show for Value with output(self: Value, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}


// ============================================
// CallableValue
// ============================================
// pub struct CallableValue {
//   either_value: Either[FunctionValue, PointerValue]
// }
//
// pub impl AsValueRef for CallableValue with as_value_ref(self: CallableValue) -> LLVMValueRef {
//   match self.either_value {
//     Left(f) => f.as_value_ref()
//     Right(p) => p.as_value_ref()
//   }
// }
