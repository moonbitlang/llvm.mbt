// ===================================
// Values
// ===================================

///|
type ValueRef @unsafe.LLVMValueRef

///|
fn ValueRef::new(value_ref : @unsafe.LLVMValueRef) -> ValueRef {
  if value_ref.is_null() {
    println("ValueRef is null")
    panic()
  }
  ValueRef(value_ref)
}

///|
fn ValueRef::is_instruction(self : ValueRef) -> Bool {
  @unsafe.llvm_isa_instruction(self.inner()).is_null() |> not
}

///|
fn ValueRef::as_instruction(self : ValueRef) -> InstructionValue? {
  if not(self.is_instruction()) {
    return None
  }
  Some(InstructionValue::new(self.inner()))
}

///|
fn ValueRef::is_null(self : ValueRef) -> Bool {
  self.inner().is_null()
}

///|
fn ValueRef::is_const(self : ValueRef) -> Bool {
  @unsafe.llvm_is_constant(self.inner())
}

///|
//fn ValueRef::is_poison(self : ValueRef) -> Bool {
//  @unsafe.llvm_is_poison(self.inner())
//}

///|
fn ValueRef::set_name(self : ValueRef, name : String) -> Unit {
  let value_ref = self.inner()
  @unsafe.llvm_set_value_name(value_ref, name)
}

// TODO: This API use `@unsafe.LLVMGetValueName2` possibly problematic

///|
fn ValueRef::get_name(self : ValueRef) -> String {
  self.inner().get_name()
}

///|
fn ValueRef::is_undef(self : ValueRef) -> Bool {
  self.inner().is_undef()
}

///|
fn ValueRef::get_type(self : ValueRef) -> TypeRef {
  let type_ref = @unsafe.llvm_type_of(self.inner())
  TypeRef(type_ref)
}

///|
fn ValueRef::replace_all_uses_with(
  self : ValueRef,
  new_value : ValueRef
) -> Unit {
  @unsafe.llvm_replace_all_uses_with(self.inner(), new_value.inner())
}

///|
fn ValueRef::get_first_use(self : ValueRef) -> BasicValueUse? {
  let use_ = @unsafe.llvm_get_first_use(self.inner())
  if use_.is_null() {
    None
  } else {
    Some(BasicValueUse::new(use_))
  }
}

// pub fn get_section(self: ValueRef) -> String?
// pub fn set_section(self: ValueRef) -> String?

///|
fn ValueRef::dump(self : ValueRef) -> Unit {
  @unsafe.llvm_dump_value(self.inner())
}

///|
pub impl Show for ValueRef with output(self : ValueRef, logger : &Logger) -> Unit {
  let s = @unsafe.llvm_print_value_to_string(self.inner())
  logger.write_string(s)
}

///|
pub impl Eq for ValueRef with op_equal(self : ValueRef, other : ValueRef) -> Bool {
  self.inner() == other.inner()
}
// ============================================
// CallableValue
// ============================================

///|
pub struct CallableValue {
  either_value : Either[FunctionValue, PointerValue]
}

///|
pub fn CallableValue::inner(self : CallableValue) -> @unsafe.LLVMValueRef {
  match self.either_value {
    Left(f) => f.inner()
    Right(p) => p.inner()
  }
}

///|
pub fn CallableValue::fromf(f : FunctionValue) -> CallableValue {
  CallableValue::{ either_value: Left(f) }
}

///|
pub fn CallableValue::fromp(p : PointerValue) -> CallableValue {
  CallableValue::{ either_value: Right(p) }
}
