// ====------------------------------------=====
// Types
// ====------------------------------------=====

///|
pub trait Type {
  base(Self) -> TypeRef
  as_type_enum(Self) -> TypeEnum
  try_as_basic_type_enum(Self) -> BasicTypeEnum? = _
  inner(Self) -> @unsafe.LLVMTypeRef = _
  dump(Self) -> Unit = _
  is_sized(Self) -> Bool = _
  type_name(Self) -> String = _
  get_context(Self) -> Context = _
  ptr_type(Self, AddressSpace) -> PointerType = _
  vec_type(Self, UInt) -> VectorType = _
  scalable_vec_type(Self, UInt) -> ScalableVectorType = _
  array_type(Self, UInt) -> ArrayType = _
  fn_type(Self, Array[&BasicType]) -> FunctionType = _
  size_of(Self) -> IntValue? = _
  get_undef(Self) -> &Value = _
  get_poison(Self) -> &Value = _
  get_alignment(Self) -> IntValue = _
  into_void_type(Self) -> VoidType raise MoonllvmError = _
  into_int_type(Self) -> IntType raise MoonllvmError = _
  into_float_type(Self) -> FloatType raise MoonllvmError = _
  into_pointer_type(Self) -> PointerType raise MoonllvmError = _
  into_struct_type(Self) -> StructType raise MoonllvmError = _
  into_function_type(Self) -> FunctionType raise MoonllvmError = _
  into_array_type(Self) -> ArrayType raise MoonllvmError = _
  into_vector_type(Self) -> VectorType raise MoonllvmError = _
  into_scalable_vector_type(Self) -> ScalableVectorType raise MoonllvmError = _
  into_metadata_type(Self) -> MetadataType raise MoonllvmError = _
  try_as_basic_type(Self) -> &BasicType? = _
  into_basic_type(Self) -> &BasicType raise MoonllvmError = _
}

///|
impl Type with try_as_basic_type_enum(self) {
  match self.as_type_enum() {
    VoidType(_) => None
    IntType(v) => Some(BasicTypeEnum::IntType(v))
    FloatType(v) => Some(BasicTypeEnum::FloatType(v))
    PointerType(v) => Some(BasicTypeEnum::PointerType(v))
    StructType(v) => Some(BasicTypeEnum::StructType(v))
    FunctionType(_) => None // Function types are not basic types
    ArrayType(v) => Some(BasicTypeEnum::ArrayType(v))
    VectorType(v) => Some(BasicTypeEnum::VectorType(v))
    ScalableVectorType(v) => Some(BasicTypeEnum::ScalableVectorType(v))
    MetadataType(_) => None // Metadata types are not basic types
  }
}

///|
impl Type with inner(self) {
  self.base().inner()
}

///|
impl Type with dump(self) {
  self.base().dump()
}

///|
impl Type with is_sized(self) {
  self.base().is_sized()
}

///|
impl Type with type_name(self) {
  self.base().to_string()
}

///|
impl Type with get_context(self) {
  self.base().get_context()
}

///| Creates a `PointerType` with this `Type` for its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let address_space = AddressSpace::default();
/// let i32_type = context.i32_type();
/// let f64_type = context.f64_type();
/// let void_type = context.void_type();
/// let struct_type = context.struct_type([i32_type, f64_type]);
/// let ptr_type = i32_type.ptr_type(address_space);
/// let fn_type = i32_type.fn_type([i32_type]);
/// let array_type = i32_type.array_type(8);
/// let vector_type = i32_type.vec_type(8);
/// let scalable_vector_type = i32_type.scalable_vec_type(8);
/// let md_type = context.metadata_type();
/// inspect(i32_type.ptr_type(address_space), content="ptr")
/// inspect(f64_type.ptr_type(address_space), content="ptr")
/// inspect(void_type.ptr_type(address_space), content="ptr")
/// inspect(struct_type.ptr_type(address_space), content="ptr")
/// inspect(ptr_type.ptr_type(address_space), content="ptr")
/// inspect(fn_type.ptr_type(address_space), content="ptr")
/// inspect(array_type.ptr_type(address_space), content="ptr")
/// inspect(vector_type.ptr_type(address_space), content="ptr")
/// inspect(scalable_vector_type.ptr_type(address_space), content="ptr")
/// inspect(md_type.ptr_type(address_space), content="ptr")
/// ```
impl Type with ptr_type(self, address_space) {
  self.base().ptr_type(address_space)
}

///| Creates a `VectorType` with this `Type` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let f32_type = context.f32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// inspect(i32_type.vec_type(16), content="<16 x i32>")
/// inspect(f32_type.vec_type(16), content="<16 x float>")
/// inspect(ptr_type.vec_type(16), content="<16 x ptr>")
/// ```
impl Type with vec_type(self, num_elements) {
  self.base().vec_type(num_elements)
}

///| Creates a `ScalableVectorType` with this `Type` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let f32_type = context.f32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// inspect(i32_type.scalable_vec_type(16), content="<vscale x 16 x i32>")
/// inspect(f32_type.scalable_vec_type(16), content="<vscale x 16 x float>")
/// inspect(ptr_type.scalable_vec_type(16), content="<vscale x 16 x ptr>")
/// ```
impl Type with scalable_vec_type(self, num_elements) {
  self.base().scalable_vec_type(num_elements)
}

///| Creates an `ArrayType` with this `Type` as its element type.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let f32_type = context.f32_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// inspect(i32_type.array_type(16), content="[16 x i32]")
/// inspect(f32_type.array_type(16), content="[16 x float]")
/// inspect(ptr_type.array_type(16), content="[16 x ptr]")
/// ```
impl Type with array_type(self, num_elements) {
  self.base().array_type(num_elements)
}

///|
impl Type with fn_type(self, param_types) {
  self.base().fn_type(param_types)
}

///| Gets the size of this `Type`. Value may vary depending on the target architecture.
///
/// ## Example
///
/// ```moonbit
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let f64_type = context.f64_type();
/// let ptr_type = i32_type.ptr_type(AddressSpace::default());
/// let i32_sz = i32_type.size_of().unwrap();
/// let f64_sz = f64_type.size_of().unwrap();
/// let ptr_sz = ptr_type.size_of().unwrap();
/// let expect_i32 = "i64 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i64)";
/// let expect_f64 = "i64 ptrtoint (ptr getelementptr (double, ptr null, i32 1) to i64)";
/// let expect_ptr = "i64 ptrtoint (ptr getelementptr (ptr, ptr null, i32 1) to i64)";
/// inspect(i32_sz, content=expect_i32)
/// inspect(f64_sz, content=expect_f64)
/// inspect(ptr_sz, content=expect_ptr)
/// ```
impl Type with size_of(self) {
  self.base().size_of()
}

///|
impl Type with get_undef(self) {
  let e = self.base().get_undef() |> ValueEnum::init
  e.as_value_class()
}

///|
impl Type with get_poison(self) {
  let e = self.base().get_poison() |> ValueEnum::init
  e.as_value_class()
}

///|
impl Type with get_alignment(self) {
  self.base().get_alignment()
}

///|
impl Type with into_void_type(self) {
  guard self.as_type_enum() is VoidType(v) else {
    raise IntoTypeError("Expected `void`, got `\{self.type_name()}`")
  }
  v
}

///|
impl Type with into_int_type(self) {
  guard self.as_type_enum() is IntType(v) else {
    raise IntoTypeError("Expected `int`, got `\{self.type_name()}`")
  }
  v
}

///|
impl Type with into_float_type(self) {
  guard self.as_type_enum() is FloatType(v) else {
    raise IntoTypeError("Expected `float`, got `\{self.type_name()}`")
  }
  v
}

///|
impl Type with into_pointer_type(self) {
  guard self.as_type_enum() is PointerType(v) else {
    raise IntoTypeError("Expected `pointer`, got `\{self.type_name()}`")
  }
  v
}

///|
impl Type with into_struct_type(self) {
  guard self.as_type_enum() is StructType(v) else {
    raise IntoTypeError("Expected `struct`, got `\{self.type_name()}`")
  }
  v
}

///|
impl Type with into_function_type(self) {
  guard self.as_type_enum() is FunctionType(v) else {
    raise IntoTypeError("Expected `function`, got `\{self.type_name()}`")
  }
  v
}

///|
impl Type with into_array_type(self) {
  guard self.as_type_enum() is ArrayType(v) else {
    raise IntoTypeError("Expected `array`, got `\{self.type_name()}`")
  }
  v
}

///|
impl Type with into_vector_type(self) {
  guard self.as_type_enum() is VectorType(v) else {
    raise IntoTypeError("Expected `vector`, got `\{self.type_name()}`")
  }
  v
}

///|
impl Type with into_scalable_vector_type(self) {
  guard self.as_type_enum() is ScalableVectorType(v) else {
    raise IntoTypeError("Expected `scalable vector`, got `\{self.type_name()}`")
  }
  v
}

///|
impl Type with into_metadata_type(self) {
  guard self.as_type_enum() is MetadataType(v) else {
    raise IntoTypeError("Expected `metadata`, got `\{self.type_name()}`")
  }
  v
}

///|
impl Type with try_as_basic_type(self) {
  if self.try_as_basic_type_enum() is Some(basic_type) {
    Some(basic_type.as_basic_type_class())
  } else {
    None
  }
}

///|
impl Type with into_basic_type(self) {
  guard self.try_as_basic_type_enum() is Some(basic_type) else {
    raise IntoTypeError("Expected a basic type, got `\{self.type_name()}`")
  }
  basic_type.as_basic_type_class()
}

///|
pub impl Show for &Type with output(self, logger) {
  let s = match self.as_type_enum() {
    VoidType(v) => v.to_string()
    IntType(v) => v.to_string()
    FloatType(v) => v.to_string()
    PointerType(v) => v.to_string()
    StructType(v) => v.to_string()
    FunctionType(v) => v.to_string()
    ArrayType(v) => v.to_string()
    VectorType(v) => v.to_string()
    ScalableVectorType(v) => v.to_string()
    MetadataType(v) => v.to_string()
  }
  logger.write_string(s)
}

///|
pub impl Eq for &Type with op_equal(self, other) {
  self.base() == other.base()
}

///|
pub enum TypeEnum {
  VoidType(VoidType)
  IntType(IntType)
  FloatType(FloatType)
  PointerType(PointerType)
  StructType(StructType)
  FunctionType(FunctionType)
  ArrayType(ArrayType)
  VectorType(VectorType)
  ScalableVectorType(ScalableVectorType)
  MetadataType(MetadataType)
}

///|
pub fn TypeEnum::as_type_class(self : Self) -> &Type {
  match self {
    VoidType(v) => {
      v as &Type
    }
    IntType(v) => v
    FloatType(v) => v
    PointerType(v) => v
    StructType(v) => v
    FunctionType(v) => v
    ArrayType(v) => v
    VectorType(v) => v
    ScalableVectorType(v) => v
    MetadataType(v) => v
  }
}

///|
pub fn TypeEnum::init(type_ref : @unsafe.LLVMTypeRef) -> TypeEnum {
  let kind : @unsafe.LLVMTypeKind = @unsafe.llvm_get_type_kind(type_ref)
  match kind {
    @unsafe.LLVMVoidTypeKind => VoidType(VoidType::new(type_ref))
    @unsafe.LLVMHalfTypeKind
    | @unsafe.LLVMFloatTypeKind
    | @unsafe.LLVMDoubleTypeKind
    | @unsafe.LLVMX86_FP80TypeKind
    | @unsafe.LLVMFP128TypeKind
    | @unsafe.LLVMPPC_FP128TypeKind => FloatType(FloatType::new(type_ref))
    @unsafe.LLVMIntegerTypeKind => IntType(IntType::new(type_ref))
    @unsafe.LLVMFunctionTypeKind => FunctionType(FunctionType::new(type_ref))
    @unsafe.LLVMStructTypeKind => StructType(StructType::new(type_ref))
    @unsafe.LLVMArrayTypeKind => ArrayType(ArrayType::new(type_ref))
    @unsafe.LLVMVectorTypeKind => VectorType(VectorType::new(type_ref))
    @unsafe.LLVMScalableVectorTypeKind =>
      ScalableVectorType(ScalableVectorType::new(type_ref))
    @unsafe.LLVMPointerTypeKind => PointerType(PointerType::new(type_ref))
    _ => abort("Unsupported type kind \{kind}")
  }
}

// ====------------------------------------=====
// Basic Types
// ====------------------------------------=====

///|
pub trait BasicType: Type {
  as_basic_type_enum(Self) -> BasicTypeEnum
}

///|
pub(all) enum BasicTypeEnum {
  ArrayType(ArrayType)
  FloatType(FloatType)
  IntType(IntType)
  PointerType(PointerType)
  StructType(StructType)
  VectorType(VectorType)
  ScalableVectorType(ScalableVectorType)
}

///|
pub fn BasicTypeEnum::as_basic_type_class(self : Self) -> &BasicType {
  match self {
    ArrayType(v) => {
      v as &BasicType
    }
    FloatType(v) => v
    IntType(v) => v
    PointerType(v) => v
    StructType(v) => v
    VectorType(v) => v
    ScalableVectorType(v) => v
  }
}

///|
pub fn BasicTypeEnum::init(type_ref : @unsafe.LLVMTypeRef) -> BasicTypeEnum {
  let kind : @unsafe.LLVMTypeKind = @unsafe.llvm_get_type_kind(type_ref)
  match kind {
    @unsafe.LLVMHalfTypeKind
    | @unsafe.LLVMFloatTypeKind
    | @unsafe.LLVMDoubleTypeKind
    | @unsafe.LLVMX86_FP80TypeKind
    | @unsafe.LLVMFP128TypeKind
    | @unsafe.LLVMPPC_FP128TypeKind =>
      BasicTypeEnum::FloatType(FloatType::new(type_ref))
    @unsafe.LLVMIntegerTypeKind =>
      BasicTypeEnum::IntType(IntType::new(type_ref))
    @unsafe.LLVMArrayTypeKind =>
      BasicTypeEnum::ArrayType(ArrayType::new(type_ref))
    @unsafe.LLVMVectorTypeKind =>
      BasicTypeEnum::VectorType(VectorType::new(type_ref))
    @unsafe.LLVMPointerTypeKind =>
      BasicTypeEnum::PointerType(PointerType::new(type_ref))
    @unsafe.LLVMStructTypeKind =>
      BasicTypeEnum::StructType(StructType::new(type_ref))
    _ => abort("Unsupported type kind")
  }
}

///|
pub impl Show for &BasicType with output(self, logger) {
  let s = match self.as_basic_type_enum() {
    IntType(v) => v.to_string()
    FloatType(v) => v.to_string()
    PointerType(v) => v.to_string()
    StructType(v) => v.to_string()
    ArrayType(v) => v.to_string()
    VectorType(v) => v.to_string()
    ScalableVectorType(v) => v.to_string()
  }
  logger.write_string(s)
}

///|
pub impl Eq for &BasicType with op_equal(self, other) {
  self.inner() == other.inner()
}

// ====------------------------------------=====
// Values
// ====------------------------------------=====

///|
pub trait Value {
  base(Self) -> ValueRef
  as_value_enum(Self) -> ValueEnum
  inner(Self) -> @unsafe.LLVMValueRef = _
  dump(Self) -> Unit = _
  get_type(Self) -> &Type = _
  is_instruction(Self) -> Bool = _
  as_instruction(Self) -> InstructionValue? = _
  is_const(Self) -> Bool = _
  get_name(Self) -> String = _
  set_name(Self, String) -> Unit = _
  is_undef(Self) -> Bool = _
  into_int_value(Self) -> IntValue raise MoonllvmError = _
  into_float_value(Self) -> FloatValue raise MoonllvmError = _
  into_pointer_value(Self) -> PointerValue raise MoonllvmError = _
  into_struct_value(Self) -> StructValue raise MoonllvmError = _
  into_function_value(Self) -> FunctionValue raise MoonllvmError = _
  into_array_value(Self) -> ArrayValue raise MoonllvmError = _
  into_vector_value(Self) -> VectorValue raise MoonllvmError = _
  into_phi_value(Self) -> PhiValue raise MoonllvmError = _
  into_scalable_vector_value(Self) -> ScalableVectorValue raise MoonllvmError = _
  into_metadata_value(Self) -> MetadataValue raise MoonllvmError = _
  into_call_site_value(Self) -> CallSiteValue raise MoonllvmError = _
  into_global_value(Self) -> GlobalValue raise MoonllvmError = _
  into_instruction_value(Self) -> InstructionValue raise MoonllvmError = _
  try_as_basic_value_enum(Self) -> BasicValueEnum? = _
  try_as_basic_value(Self) -> &BasicValue? = _
  into_basic_value(Self) -> &BasicValue raise MoonllvmError = _
}

///|
impl Value with inner(self) {
  self.base().inner()
}

///|
impl Value with dump(self) {
  self.base().dump()
}

///|
impl Value with get_type(self) {
  let type_ref = self.base().get_type()
  TypeEnum::init(type_ref.inner()).as_type_class()
}

///|
impl Value with is_instruction(self) {
  self.base().is_instruction()
}

///|
impl Value with as_instruction(self) {
  self.base().as_instruction()
}

///|
impl Value with is_const(self) {
  self.base().is_const()
}

///|
impl Value with get_name(self) {
  self.base().get_name()
}

///|
impl Value with set_name(self, name) {
  self.base().set_name(name)
}

///|
impl Value with is_undef(self) {
  self.base().is_undef()
}

///|
impl Value with into_int_value(self) {
  guard self.try_as_basic_value_enum() is Some(IntValue(v)) else {
    raise IntoValueError("Expected an `int`, got `\{self.get_type()}`")
  }
  v
}

///|
impl Value with into_float_value(self) {
  guard self.try_as_basic_value_enum() is Some(FloatValue(v)) else {
    raise IntoValueError("Expected a `float`, got `\{self.get_type()}`")
  }
  v
}

///|
impl Value with into_pointer_value(self) {
  guard self.try_as_basic_value_enum() is Some(PointerValue(v)) else {
    raise IntoValueError("Expected a `pointer`, got `\{self.get_type()}`")
  }
  v
}

///|
impl Value with into_struct_value(self) {
  guard self.as_value_enum() is StructValue(v) else {
    raise IntoValueError("Expected a `struct`, got `\{self.get_type()}`")
  }
  v
}

///|
impl Value with into_function_value(self) {
  guard self.as_value_enum() is FunctionValue(v) else {
    raise IntoValueError("Expected a `function`, got `\{self.get_type()}`")
  }
  v
}

///|
impl Value with into_array_value(self) {
  guard self.as_value_enum() is ArrayValue(v) else {
    raise IntoValueError("Expected an `array`, got `\{self.get_type()}`")
  }
  v
}

///|
impl Value with into_vector_value(self) {
  guard self.as_value_enum() is VectorValue(v) else {
    raise IntoValueError("Expected a `vector`, got `\{self.get_type()}`")
  }
  v
}

///|
impl Value with into_phi_value(self) {
  guard self.as_value_enum() is PhiValue(v) else {
    raise IntoValueError("Expected a `phi`, got `\{self.get_type()}`")
  }
  v
}

///|
impl Value with into_scalable_vector_value(self) {
  guard self.as_value_enum() is ScalableVectorValue(v) else {
    raise IntoValueError(
      "Expected a `scalable vector`, got `\{self.get_type()}`",
    )
  }
  v
}

///|
impl Value with into_metadata_value(self) {
  guard self.as_value_enum() is MetadataValue(v) else {
    raise IntoValueError("Expected `metadata`, got `\{self.get_type()}`")
  }
  v
}

///|
impl Value with into_call_site_value(self) {
  guard self.as_value_enum() is CallSiteValue(v) else {
    raise IntoValueError("Expected a `call site`, got `\{self.get_type()}`")
  }
  v
}

///|
impl Value with into_global_value(self) {
  guard self.as_value_enum() is GlobalValue(v) else {
    raise IntoValueError("Expected a `global`, got `\{self.get_type()}`")
  }
  v
}

///|
impl Value with into_instruction_value(self) {
  guard self.as_value_enum() is InstructionValue(v) else {
    raise IntoValueError("Expected an `instruction`, got `\{self.get_type()}`")
  }
  v
}

///|
impl Value with try_as_basic_value_enum(self) {
  match self.try_as_basic_value() {
    Some(basic_value) => Some(basic_value.as_basic_value_enum())
    None => None
  }
}

///|
impl Value with try_as_basic_value(self) {
  match self.as_value_enum() {
    IntValue(v) => Some((v : &BasicValue))
    FloatValue(v) => Some(v)
    PointerValue(v) => Some(v)
    StructValue(v) => Some(v)
    ArrayValue(v) => Some(v)
    VectorValue(v) => Some(v)
    CallSiteValue(v) =>
      match v.try_as_basic_value() {
        Left(basic_value) => Some(basic_value)
        Right(_) => None
      }
    PhiValue(phi) => Some(phi.as_basic_value())
    FunctionValue(_) => None // Function values are not basic values
    ScalableVectorValue(_) => None
    MetadataValue(_) => None // Metadata values are not basic values
    GlobalValue(_) => None // Global values are not basic values
    InstructionValue(_) => None // Instruction values are not basic values
  }
}

///|
impl Value with into_basic_value(self) {
  guard self.try_as_basic_value() is Some(basic_value) else {
    raise IntoValueError("Expected a basic value, got `\{self.get_type()}`")
  }
  basic_value
}

///|
pub impl Show for &Value with output(self, logger) {
  let s = match self.as_value_enum() {
    IntValue(v) => v.to_string()
    FloatValue(v) => v.to_string()
    PointerValue(v) => v.to_string()
    StructValue(v) => v.to_string()
    FunctionValue(v) => v.to_string()
    ArrayValue(v) => v.to_string()
    VectorValue(v) => v.to_string()
    PhiValue(v) => v.to_string()
    ScalableVectorValue(v) => v.to_string()
    MetadataValue(v) => v.to_string()
    CallSiteValue(v) => v.to_string()
    GlobalValue(v) => v.to_string()
    InstructionValue(v) => v.to_string()
  }
  logger.write_string(s)
}

///|
pub impl Eq for &Value with op_equal(self, other) {
  self.inner() == other.inner()
}

///|
pub enum ValueEnum {
  IntValue(IntValue)
  FloatValue(FloatValue)
  PointerValue(PointerValue)
  StructValue(StructValue)
  FunctionValue(FunctionValue)
  ArrayValue(ArrayValue)
  VectorValue(VectorValue)
  PhiValue(PhiValue)
  ScalableVectorValue(ScalableVectorValue)
  MetadataValue(MetadataValue)
  CallSiteValue(CallSiteValue)
  GlobalValue(GlobalValue)
  InstructionValue(InstructionValue)
} derive(Show)

///|
pub fn ValueEnum::as_value_class(self : Self) -> &Value {
  match self {
    IntValue(v) => {
      v as &Value
    }
    FloatValue(v) => v
    PointerValue(v) => v
    StructValue(v) => v
    FunctionValue(v) => v
    ArrayValue(v) => v
    VectorValue(v) => v
    PhiValue(v) => v
    ScalableVectorValue(v) => v
    MetadataValue(v) => v
    CallSiteValue(v) => v
    GlobalValue(v) => v
    InstructionValue(v) => v
  }
}

///|
pub fn ValueEnum::init(val_ref : @unsafe.LLVMValueRef) -> ValueEnum {
  let ty = val_ref.get_type()
  let kind = @unsafe.llvm_get_type_kind(ty)
  match kind {
    @unsafe.LLVMFloatTypeKind
    | @unsafe.LLVMFP128TypeKind
    | @unsafe.LLVMDoubleTypeKind
    | @unsafe.LLVMHalfTypeKind
    | @unsafe.LLVMX86_FP80TypeKind
    | @unsafe.LLVMPPC_FP128TypeKind => FloatValue(FloatValue::new(val_ref))
    @unsafe.LLVMIntegerTypeKind => IntValue(IntValue::new(val_ref))
    @unsafe.LLVMStructTypeKind => StructValue(StructValue::new(val_ref))
    @unsafe.LLVMPointerTypeKind =>
      match @unsafe.llvm_get_value_kind(val_ref) {
        @unsafe.LLVMFunctionValueKind =>
          FunctionValue(FunctionValue::new(val_ref).unwrap())
        _ => PointerValue(PointerValue::new(val_ref))
      }
    @unsafe.LLVMArrayTypeKind => ArrayValue(ArrayValue::new(val_ref))
    @unsafe.LLVMVectorTypeKind => VectorValue(VectorValue::new(val_ref))
    @unsafe.LLVMFunctionTypeKind =>
      FunctionValue(FunctionValue::new(val_ref).unwrap())
    @unsafe.LLVMVoidTypeKind => {
      if val_ref.isa_instruction().is_null() {
        abort("Void value must be an instruction")
      }
      InstructionValue(InstructionValue::new(val_ref))
    }
    @unsafe.LLVMMetadataTypeKind => MetadataValue(MetadataValue::new(val_ref))
    _ => abort("Unsupported value kind")
  }
}

// ====------------------------------------=====
// Basic Values
// ====------------------------------------=====

///|
pub trait BasicValue: Value {
  as_basic_value_enum(Self) -> BasicValueEnum
}

///|
pub(all) enum BasicValueEnum {
  ArrayValue(ArrayValue)
  IntValue(IntValue)
  FloatValue(FloatValue)
  PointerValue(PointerValue)
  StructValue(StructValue)
  VectorValue(VectorValue)
  ScalableVectorValue(ScalableVectorValue)
} derive(Show)

///|
pub fn BasicValueEnum::as_basic_value_class(self : Self) -> &BasicValue {
  match self {
    ArrayValue(v) => {
      v as &BasicValue
    }
    IntValue(v) => v
    FloatValue(v) => v
    PointerValue(v) => v
    StructValue(v) => v
    VectorValue(v) => v
    ScalableVectorValue(v) => v
  }
}

///|
pub fn BasicValueEnum::init(val_ref : @unsafe.LLVMValueRef) -> BasicValueEnum {
  let ty = val_ref.get_type()
  let kind = @unsafe.llvm_get_type_kind(ty)
  match kind {
    @unsafe.LLVMFloatTypeKind
    | @unsafe.LLVMFP128TypeKind
    | @unsafe.LLVMDoubleTypeKind
    | @unsafe.LLVMHalfTypeKind
    | @unsafe.LLVMX86_FP80TypeKind
    | @unsafe.LLVMPPC_FP128TypeKind => FloatValue(FloatValue::new(val_ref))
    @unsafe.LLVMIntegerTypeKind => IntValue(IntValue::new(val_ref))
    @unsafe.LLVMStructTypeKind => StructValue(StructValue::new(val_ref))
    @unsafe.LLVMPointerTypeKind => PointerValue(PointerValue::new(val_ref))
    @unsafe.LLVMArrayTypeKind => ArrayValue(ArrayValue::new(val_ref))
    @unsafe.LLVMVectorTypeKind => VectorValue(VectorValue::new(val_ref))
    _ => abort("Unsupported basic value kind")
  }
}

///|
pub impl Show for &BasicValue with output(self, logger) {
  let s = match self.as_basic_value_enum() {
    IntValue(v) => v.to_string()
    FloatValue(v) => v.to_string()
    PointerValue(v) => v.to_string()
    StructValue(v) => v.to_string()
    ArrayValue(v) => v.to_string()
    VectorValue(v) => v.to_string()
    ScalableVectorValue(v) => v.to_string()
  }
  logger.write_string(s)
}

///|
pub impl Eq for &BasicValue with op_equal(self, other) {
  self.inner() == other.inner()
}

// ====------------------------------------=====
// Aggregate Values
// ====------------------------------------=====

///|
pub trait AggregateValue: Value {
  as_aggregate_value_enum(Self) -> AggregateValueEnum
}

///|
pub enum AggregateValueEnum {
  StructValue(StructValue)
  ArrayValue(ArrayValue)
  VectorValue(VectorValue)
  ScalableVectorValue(ScalableVectorValue)
}

///|
pub fn AggregateValueEnum::as_aggregate_value_class(
  self : Self
) -> &AggregateValue {
  match self {
    StructValue(v) => {
      v as &AggregateValue
    }
    ArrayValue(v) => v
    VectorValue(v) => v
    ScalableVectorValue(v) => v
  }
}

///|
pub fn AggregateValueEnum::init(
  val_ref : @unsafe.LLVMValueRef
) -> AggregateValueEnum {
  let ty = val_ref.get_type()
  let kind = @unsafe.llvm_get_type_kind(ty)
  match kind {
    @unsafe.LLVMStructTypeKind => StructValue(StructValue::new(val_ref))
    @unsafe.LLVMArrayTypeKind => ArrayValue(ArrayValue::new(val_ref))
    @unsafe.LLVMVectorTypeKind => VectorValue(VectorValue::new(val_ref))
    @unsafe.LLVMPointerTypeKind =>
      ScalableVectorValue(ScalableVectorValue::new(val_ref))
    _ => abort("Unsupported aggregate value kind")
  }
}

// ====------------------------------------=====
// Basic Metadata Values
// ====------------------------------------=====

//=========================================================
// IntMathValue
//=========================================================

///|
pub trait IntMathValue: BasicValue {
  new(@unsafe.LLVMValueRef) -> Self
}

///|
pub impl IntMathValue for IntValue with new(val_ref : @unsafe.LLVMValueRef) -> IntValue {
  IntValue::new(val_ref)
}

// This is different with `inkwell`
// pub impl IntMathValue for PointerValue with new(val_ref: @unsafe.LLVMValueRef) -> PointerValue {
//   PointerValue::new(val_ref)
// }

///|
pub impl IntMathValue for VectorValue with new(val_ref : @unsafe.LLVMValueRef) -> VectorValue {
  VectorValue::new(val_ref)
}

///|
pub impl IntMathValue for ScalableVectorValue with new(
  val_ref : @unsafe.LLVMValueRef
) -> ScalableVectorValue {
  ScalableVectorValue::new(val_ref)
}

//=========================================================
// FloatMathValue
//=========================================================

///|
pub trait FloatMathValue: BasicValue {
  new(@unsafe.LLVMValueRef) -> Self
}

///|
pub impl FloatMathValue for FloatValue with new(val_ref : @unsafe.LLVMValueRef) -> FloatValue {
  FloatValue::new(val_ref)
}

///|
pub impl FloatMathValue for VectorValue with new(val_ref : @unsafe.LLVMValueRef) -> VectorValue {
  VectorValue::new(val_ref)
}

///|
pub impl FloatMathValue for ScalableVectorValue with new(
  val_ref : @unsafe.LLVMValueRef
) -> ScalableVectorValue {
  ScalableVectorValue::new(val_ref)
}

//=========================================================
// PointerMathValue
//=========================================================

///|
pub trait PointerMathValue: BasicValue {
  new(@unsafe.LLVMValueRef) -> Self
}

///|
pub impl PointerMathValue for PointerValue with new(
  val_ref : @unsafe.LLVMValueRef
) -> PointerValue {
  PointerValue::new(val_ref)
}

///|
pub impl PointerMathValue for VectorValue with new(
  val_ref : @unsafe.LLVMValueRef
) -> VectorValue {
  VectorValue::new(val_ref)
}

///|
pub impl PointerMathValue for ScalableVectorValue with new(
  val_ref : @unsafe.LLVMValueRef
) -> ScalableVectorValue {
  ScalableVectorValue::new(val_ref)
}

//=========================================================
// VectorBaseValue
//=========================================================

///|
pub trait VectorBaseValue: BasicValue {
  new(@unsafe.LLVMValueRef) -> Self
}

///|
pub impl VectorBaseValue for VectorValue with new(
  val_ref : @unsafe.LLVMValueRef
) -> VectorValue {
  VectorValue::new(val_ref)
}

///|
pub impl VectorBaseValue for ScalableVectorValue with new(
  val_ref : @unsafe.LLVMValueRef
) -> ScalableVectorValue {
  ScalableVectorValue::new(val_ref)
}
