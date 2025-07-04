///| One of an instruction's operand bundles.
pub struct OperandBundle {
  bundle : @unsafe.LLVMOperandBundleRef
}

///| Get an operand bundle from a [LLVMOperandBundleRef].
pub fn OperandBundle::new(
  bundle_ref : @unsafe.LLVMOperandBundleRef
) -> OperandBundle {
  OperandBundle::{ bundle: bundle_ref }
}

///|
pub fn OperandBundle::as_bundle_ref(
  self : OperandBundle
) -> @unsafe.LLVMOperandBundleRef {
  self.bundle
}

///| Create a new operand bundle.
///
/// ## Example
///
/// ```moonbit skip skip (Array.nth not implemented)
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let op_bundle = OperandBundle::create("tag", [i32_type.const_zero()]);
/// inspect(op_bundle.get_tag(), content="tag");
/// let arg = op_bundle.get_args().nth(0).unwrap().into_int_value();
/// assert_true(arg.is_const());
/// assert_eq(arg.get_zero_extended_constant().unwrap(), 0);
/// ```
pub fn OperandBundle::create(
  tag : String,
  args : Array[&Value]
) -> OperandBundle {
  let args_ref = args.map(arg => arg.inner())
  let bundle = @unsafe.llvm_create_operand_bundle(tag, args_ref)
  OperandBundle::new(bundle)
}

///| Get this operand bundle's tag.
///
/// ## Example
///
/// ```
/// let op_bundle = OperandBundle::create("tag", []);
/// inspect(op_bundle.get_tag(), content="tag");
/// ```
pub fn OperandBundle::get_tag(self : OperandBundle) -> String {
  @unsafe.llvm_get_operand_bundle_tag(self.bundle)
}

// TODO: Need to check if the return type is correct
// REVIEW: The following is different with `inkwell`

///| Get this operand bundle's arguments.
///
/// ## Example
///
/// ```moonbit skip
/// let context = Context::create();
/// let i32_type = context.i32_type();
/// let f32_type = context.f32_type();
///
/// let op_bundle = OperandBundle::create(
///   "tag", 
///   [i32_type.const_zero(),
///    f32_type.const_float(1.23)]
/// );
/// assert_eq(op_bundle.get_args().length(), 2);
/// ```
pub fn OperandBundle::get_args(self : OperandBundle) -> Array[&BasicValue] {
  let cnt = @unsafe.llvm_get_num_operand_bundle_args(self.as_bundle_ref()).reinterpret_as_int()
  let args : Array[&BasicValue] = Array::new()
  for i in 0..<cnt {
    let arg = @unsafe.llvm_get_operand_bundle_arg_at_index(
      self.as_bundle_ref(),
      i.reinterpret_as_uint(),
    )
    args.push(BasicValueEnum::init(arg).as_basic_value_class())
  }
  args
}

///|
pub fn OperandBundle::drop(self : OperandBundle) -> Unit {
  @unsafe.llvm_dispose_operand_bundle(self.bundle)
}
