// ==========================================
// Types
// ==========================================

///|
type TypeRef @unsafe.LLVMTypeRef

///|
fn TypeRef::new(type_ref : @unsafe.LLVMTypeRef) -> TypeRef {
  if type_ref.is_null() {
    println("TypeRef is null")
    panic()
  }
  TypeRef(type_ref)
}

///|
fn TypeRef::const_zero(self : TypeRef) -> @unsafe.LLVMValueRef {
  let val_ref = self.inner()
  let k = @unsafe.llvm_get_type_kind(val_ref)
  match k {
    @unsafe.LLVMMetadataTypeKind => @unsafe.llvm_const_pointer_null(val_ref)
    _ => @unsafe.llvm_const_null(val_ref)
  }
}

///|
fn ptr_type(self : TypeRef, address_space : AddressSpace) -> PointerType {
  PointerType::new(
    @unsafe.llvm_pointer_type(self.inner(), address_space.into()),
  )
}

///|
fn vec_type(self : TypeRef, size : UInt) -> VectorType {
  if size == 0 {
    abort("Vector size must be greater than 0")
  }

  // let r = @unsafe.llvm_vector_type(self.inner(), size)
  let r = self.inner().vector_type(size)
  VectorType::new(r)
}

///|
fn scalable_vec_type(self : TypeRef, size : UInt) -> ScalableVectorType {
  if size == 0 {
    abort("Vector size must be greater than 0")
  }

  // let r = @unsafe.llvm_scalable_vector_type(self.inner(), size)
  let r = self.inner().scalable_vector_type(size)
  ScalableVectorType::new(r)
}

///|
pub fn TypeRef::fn_type(
  self : TypeRef,
  param_types : Array[&BasicType],
  is_var_arg~ : Bool = false
) -> FunctionType {
  let ret_ty = self.inner()
  let type_refs = param_types.map(fn(t) { t.inner() })
  let fty_ref = @unsafe.llvm_function_type(ret_ty, type_refs, is_var_arg)
  FunctionType::new(fty_ref)
}

// REVIEW: Why not check size is zero?

///|
fn array_type(self : TypeRef, size : UInt) -> ArrayType {
  let r = @unsafe.llvm_array_type(self.inner(), size)
  ArrayType::new(r)
}

///|
fn TypeRef::get_undef(self : TypeRef) -> @unsafe.LLVMValueRef {
  @unsafe.llvm_get_undef(self.inner())
}

///|
fn TypeRef::get_poison(self : TypeRef) -> @unsafe.LLVMValueRef {
  @unsafe.llvm_get_poison(self.inner())
}

///|
fn TypeRef::get_alignment(self : TypeRef) -> IntValue {
  IntValue::new(@unsafe.llvm_align_of(self.inner()))
}

///|
fn TypeRef::get_context(self : TypeRef) -> Context {
  let context_ref = self.inner().get_context()
  Context::new(context_ref)
}

///|
fn TypeRef::is_sized(self : TypeRef) -> Bool {
  self.inner().is_sized()
}

///|
fn TypeRef::size_of(self : TypeRef) -> IntValue? {
  if not(self.is_sized()) {
    return None
  }
  let v = IntValue::new(@unsafe.llvm_size_of(self.inner()))
  Some(v)
}

///|
fn TypeRef::get_element_type(self : TypeRef) -> &Type {
  let element_type_ref = self.inner().get_element_type()
  TypeEnum::init(element_type_ref).as_type_class()
}

///|
fn TypeRef::dump(self : TypeRef) -> Unit {
  @unsafe.llvm_dump_type(self.inner())
}

///|
impl Show for TypeRef with output(self : TypeRef, logger : &Logger) -> Unit {
  let s = @unsafe.llvm_print_type_to_string(self.inner())
  logger.write_string(s)
}
