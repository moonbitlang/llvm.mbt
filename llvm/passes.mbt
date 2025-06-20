///|
pub struct PassBuilderOptions {
  options_ref : @unsafe.LLVMPassBuilderOptionsRef
}

///|
pub fn PassBuilderOptions::new() -> PassBuilderOptions {
  PassBuilderOptions::{
    options_ref: @unsafe.llvm_create_pass_builder_options(),
  }
}

///|
pub fn PassBuilderOptions::as_options_ref(
  self : PassBuilderOptions
) -> @unsafe.LLVMPassBuilderOptionsRef {
  self.options_ref
}

///|
pub fn PassBuilderOptions::set_verify_each(
  self : PassBuilderOptions,
  value : Bool
) -> Unit {
  @unsafe.llvm_pass_builder_options_set_verify_each(self.options_ref, value)
}

///|Toggle debug logging when running the PassBuilder.
pub fn PassBuilderOptions::set_debug_logging(
  self : PassBuilderOptions,
  value : Bool
) -> Unit {
  @unsafe.llvm_pass_builder_options_set_debug_logging(self.options_ref, value)
}

///|
pub fn PassBuilderOptions::set_loop_interleaving(
  self : PassBuilderOptions,
  value : Bool
) -> Unit {
  @unsafe.llvm_pass_builder_options_set_loop_interleaving(
    self.options_ref,
    value,
  )
}

///|
pub fn PassBuilderOptions::set_loop_vectorization(
  self : PassBuilderOptions,
  value : Bool
) -> Unit {
  @unsafe.llvm_pass_builder_options_set_loop_vectorization(
    self.options_ref,
    value,
  )
}

///|
pub fn PassBuilderOptions::set_loop_slp_vectorization(
  self : PassBuilderOptions,
  value : Bool
) -> Unit {
  @unsafe.llvm_pass_builder_options_set_slp_vectorization(
    self.options_ref,
    value,
  )
}

///|
pub fn PassBuilderOptions::set_loop_unrolling(
  self : PassBuilderOptions,
  value : Bool
) -> Unit {
  @unsafe.llvm_pass_builder_options_set_loop_unrolling(self.options_ref, value)
}

///|
pub fn PassBuilderOptions::set_forget_all_scev_in_loop_unroll(
  self : PassBuilderOptions,
  value : Bool
) -> Unit {
  @unsafe.llvm_pass_builder_options_set_forget_all_scev_in_loop_unroll(
    self.options_ref,
    value,
  )
}

///|
pub fn PassBuilderOptions::set_licm_mssa_opt_cap(
  self : PassBuilderOptions,
  value : UInt
) -> Unit {
  @unsafe.llvm_pass_builder_options_set_licm_mssa_opt_cap(
    self.options_ref,
    value,
  )
}

///|
pub fn PassBuilderOptions::set_licm_mssa_no_acc_for_promotion_cap(
  self : PassBuilderOptions,
  value : UInt
) -> Unit {
  @unsafe.llvm_pass_builder_options_set_licm_mssa_no_acc_for_promotion_cap(
    self.options_ref,
    value,
  )
}

///|
pub fn PassBuilderOptions::set_call_graph_profile(
  self : PassBuilderOptions,
  value : Bool
) -> Unit {
  @unsafe.llvm_pass_builder_options_set_call_graph_profile(
    self.options_ref,
    value,
  )
}

///|
pub fn PassBuilderOptions::set_merge_functions(
  self : PassBuilderOptions,
  value : Bool
) -> Unit {
  @unsafe.llvm_pass_builder_options_set_merge_functions(self.options_ref, value)
}
