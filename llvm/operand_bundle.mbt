pub struct OperandBundle {
  bundle: @unsafe.LLVMOperandBundleRef
}

pub fn OperandBundle::new(bundle_ref: @unsafe.LLVMOperandBundleRef) -> OperandBundle {
  OperandBundle::{
    bundle: bundle_ref
  }
}

pub fn OperandBundle::as_bundle_ref(self: OperandBundle) -> @unsafe.LLVMOperandBundleRef {
  self.bundle
}

pub fn OperandBundle::create(tag: String, args: Array[AnyValueEnum]) -> OperandBundle {
  let args_ref = args.map(fn (arg) { arg.as_value_ref()})

  let bundle = @unsafe.llvm_create_operand_bundle(tag, args_ref)

  OperandBundle::new(bundle)
}

pub fn OperandBundle::get_tag(self: OperandBundle) -> String {
  @unsafe.llvm_get_operand_bundle_tag(self.bundle)
}

pub fn OperandBundle::dispose(self: OperandBundle) -> Unit {
  @unsafe.llvm_dispose_operand_bundle(self.bundle)
}

// TODO: Need to check if the return type is correct
// REVIEW: The following is different with `inkwell`
pub fn OperandBundle::get_args(self: OperandBundle) -> Array[BasicValueEnum] {
  let cnt = @unsafe.llvm_get_num_operand_bundle_args(self.as_bundle_ref()).reinterpret_as_int()
  let args : Array[BasicValueEnum] = Array::default()
  
  for i in 0..<cnt {
    let arg = @unsafe.llvm_get_operand_bundle_arg_at_index(self.as_bundle_ref(), i.reinterpret_as_uint())
    args.push(BasicValueEnum::new(arg))
  }

  args
}
