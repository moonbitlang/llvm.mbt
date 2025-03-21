// ==========================================
// Types
// ==========================================
struct Type {
  type_ref: @unsafe.LLVMTypeRef
}

fn Type::new(type_ref: @unsafe.LLVMTypeRef) -> Type {
  if type_ref.is_null() {
    println("Type is null")
    panic()
  }

  Type::{
    type_ref
  }
}

fn Type::as_type_ref(self: Type) -> @unsafe.LLVMTypeRef {
  self.type_ref
}

// FIXME: link error
fn Type::const_zero(self: Type) -> @unsafe.LLVMValueRef {
  let val_ref = self.type_ref
  let k = @unsafe.llvm_get_type_kind(val_ref)

  match k {
    @unsafe.LLVMMetadataTypeKind => @unsafe.llvm_const_pointer_null(val_ref)
    _ => {
      @unsafe.llvm_const_null(val_ref)
    }
  }
}

fn ptr_type(self: Type, address_space: AddressSpace) -> PointerType {
  PointerType::new(@unsafe.llvm_pointer_type(self.as_type_ref(), address_space.into()))
}

fn vec_type(self: Type, size: UInt) -> VectorType {
  if size == 0 {
    abort("Vector size must be greater than 0")
  }

  // let r = @unsafe.llvm_vector_type(self.as_type_ref(), size)
  let r = self.as_type_ref().vector_type(size)
  VectorType::new(r)
}

fn scalable_vec_type(self: Type, size : UInt) -> ScalableVectorType {
  if size == 0 {
    abort("Vector size must be greater than 0")
  }

  // let r = @unsafe.llvm_scalable_vector_type(self.as_type_ref(), size)
  let r = self.as_type_ref().scalable_vector_type(size)
  ScalableVectorType::new(r)

}

// TODO: use `prarm_types: Array[&TypeRef]` after compiler bug fixed
fn Type::fn_type(
  self: Type,
  param_types: Array[&BasicMetadataType],
  is_var_arg~: Bool = false
) -> FunctionType {
  let ret_ty = self.as_type_ref()
  let type_refs = param_types.map(fn (t) {t.as_type_ref()})
  let fty_ref = @unsafe.llvm_function_type(ret_ty, type_refs, is_var_arg)
  FunctionType::new(fty_ref)
}

// REVIEW: Why not check size is zero?
fn array_type(self: Type, size: UInt) -> ArrayType {
  let r = @unsafe.llvm_array_type(self.as_type_ref(), size)
  ArrayType::new(r)
}

fn Type::get_undef(self: Type) -> @unsafe.LLVMValueRef {
  @unsafe.llvm_get_undef(self.as_type_ref())
}

fn Type::get_poison(self: Type) -> @unsafe.LLVMValueRef {
  @unsafe.llvm_get_poison(self.as_type_ref())
}

fn Type::get_alignment(self: Type) -> IntValue {
  IntValue::new(@unsafe.llvm_align_of(self.as_type_ref()))
}

fn Type::get_context(self: Type) -> Context {
  let context_ref = self.as_type_ref().get_context()
  Context::new(context_ref)
}

fn Type::is_sized(self: Type) -> Bool {
  self.as_type_ref().is_sized()
}

fn Type::size_of(self: Type) -> IntValue? {
  if not(self.is_sized()) {
    return None
  }

  let v = IntValue::new(@unsafe.llvm_size_of(self.as_type_ref()))
  Some(v)
}

fn Type::get_element_type(self: Type) -> AnyTypeEnum {
  let element_type_ref = self.as_type_ref().get_element_type()
  AnyTypeEnum::new(element_type_ref)
}

fn Type::print_to_stderr(self: Type) -> Unit {
  @unsafe.llvm_dump_type(self.as_type_ref())
}

fn Type::print_to_string(self: Type) -> String {
  @unsafe.llvm_print_type_to_string(self.as_type_ref())
}

fn Type::to_string(self: Type) -> String {
  @unsafe.llvm_print_type_to_string(self.as_type_ref())
}

fn Type::dump(self: Type) -> Unit {
  @unsafe.llvm_dump_type(self.as_type_ref())
}

impl Show for Type with output(self: Type, logger: &Logger) -> Unit {
  logger.write_string(self.to_string())
}

impl Show for Type with to_string(self: Type) -> String {
  self.to_string()
}
