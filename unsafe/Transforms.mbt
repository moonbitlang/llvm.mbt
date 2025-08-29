// ===================================
// PassBuilder
// ===================================

///|
/// Construct and run a set of passes over a module
/// 
/// This function takes a string with the passes that should be used. The format
/// of this string is the same as opt's -passes argument for the new pass
/// manager. Individual passes may be specified, separated by commas. Full
/// pipelines may also be invoked using `default<O3>` and friends. See opt for
/// full reference of the Passes format.
pub fn llvm_run_passes(
  m : LLVMModuleRef,
  passes : String,
  tm : LLVMTargetMachineRef,
  options : LLVMPassBuilderOptionsRef,
) -> LLVMErrorRef {
  let passes = CStr::from(passes)
  __llvm_run_passes(m, passes, tm, options)
}

///|
extern "C" fn __llvm_run_passes(
  m : LLVMModuleRef,
  passes : CStr,
  tm : LLVMTargetMachineRef,
  options : LLVMPassBuilderOptionsRef,
) -> LLVMErrorRef = "LLVMRunPasses"

///|
/// Create a new set of options for a PassBuilder
/// 
/// Ownership of the returned instance is given to the client, and they are
/// responsible for it. The client should call LLVMDisposePassBuilderOptions
/// to free the pass builder options.
pub extern "C" fn llvm_create_pass_builder_options() -> LLVMPassBuilderOptionsRef = "LLVMCreatePassBuilderOptions"

///|
/// Toggle adding the VerifierPass for the PassBuilder, ensuring all functions
/// inside the module is valid.
pub fn llvm_pass_builder_options_set_verify_each(
  options : LLVMPassBuilderOptionsRef,
  verify_each : Bool,
) -> Unit {
  __llvm_pass_builder_options_set_verify_each(
    options,
    to_llvm_bool(verify_each),
  )
}

///|
extern "C" fn __llvm_pass_builder_options_set_verify_each(
  options : LLVMPassBuilderOptionsRef,
  verify_each : LLVMBool,
) = "LLVMPassBuilderOptionsSetVerifyEach"

///|
/// Toggle debug logging when running the PassBuilder
pub fn llvm_pass_builder_options_set_debug_logging(
  options : LLVMPassBuilderOptionsRef,
  debug_logging : Bool,
) -> Unit {
  __llvm_pass_builder_options_set_debug_logging(
    options,
    to_llvm_bool(debug_logging),
  )
}

///|
extern "C" fn __llvm_pass_builder_options_set_debug_logging(
  options : LLVMPassBuilderOptionsRef,
  debug_logging : LLVMBool,
) = "LLVMPassBuilderOptionsSetDebugLogging"

///|
pub fn llvm_pass_builder_options_set_loop_interleaving(
  options : LLVMPassBuilderOptionsRef,
  loop_interleaving : Bool,
) -> Unit {
  __llvm_pass_builder_options_set_loop_interleaving(
    options,
    to_llvm_bool(loop_interleaving),
  )
}

///|
extern "C" fn __llvm_pass_builder_options_set_loop_interleaving(
  options : LLVMPassBuilderOptionsRef,
  loop_interleaving : LLVMBool,
) = "LLVMPassBuilderOptionsSetLoopInterleaving"

///|
pub fn llvm_pass_builder_options_set_loop_vectorization(
  options : LLVMPassBuilderOptionsRef,
  loop_vectorization : Bool,
) -> Unit {
  __llvm_pass_builder_options_set_loop_vectorization(
    options,
    to_llvm_bool(loop_vectorization),
  )
}

///|
extern "C" fn __llvm_pass_builder_options_set_loop_vectorization(
  options : LLVMPassBuilderOptionsRef,
  loop_vectorization : LLVMBool,
) = "LLVMPassBuilderOptionsSetLoopVectorization"

///|
pub fn llvm_pass_builder_options_set_slp_vectorization(
  options : LLVMPassBuilderOptionsRef,
  slp_vectorization : Bool,
) -> Unit {
  __llvm_pass_builder_options_set_slp_vectorization(
    options,
    to_llvm_bool(slp_vectorization),
  )
}

///|
extern "C" fn __llvm_pass_builder_options_set_slp_vectorization(
  options : LLVMPassBuilderOptionsRef,
  slp_vectorization : LLVMBool,
) = "LLVMPassBuilderOptionsSetSLPVectorization"

// void LLVMPassBuilderOptionsSetLoopUnrolling(LLVMPassBuilderOptionsRef Options,
//                                             LLVMBool LoopUnrolling);

///|
pub fn llvm_pass_builder_options_set_loop_unrolling(
  options : LLVMPassBuilderOptionsRef,
  loop_unrolling : Bool,
) -> Unit {
  __llvm_pass_builder_options_set_loop_unrolling(
    options,
    to_llvm_bool(loop_unrolling),
  )
}

///|
extern "C" fn __llvm_pass_builder_options_set_loop_unrolling(
  options : LLVMPassBuilderOptionsRef,
  loop_unrolling : LLVMBool,
) = "LLVMPassBuilderOptionsSetLoopUnrolling"

///|
pub fn llvm_pass_builder_options_set_forget_all_scev_in_loop_unroll(
  options : LLVMPassBuilderOptionsRef,
  forget_all_scev_in_loop_unroll : Bool,
) -> Unit {
  __llvm_pass_builder_options_set_forget_all_scev_in_loop_unroll(
    options,
    to_llvm_bool(forget_all_scev_in_loop_unroll),
  )
}

///|
extern "C" fn __llvm_pass_builder_options_set_forget_all_scev_in_loop_unroll(
  options : LLVMPassBuilderOptionsRef,
  forget_all_scev_in_loop_unroll : LLVMBool,
) = "LLVMPassBuilderOptionsSetForgetAllSCEVInLoopUnroll"

///|
pub extern "C" fn llvm_pass_builder_options_set_licm_mssa_opt_cap(
  options : LLVMPassBuilderOptionsRef,
  licm_mssa_opt_cap : UInt,
) = "LLVMPassBuilderOptionsSetLicmMssaOptCap"

///|
pub extern "C" fn llvm_pass_builder_options_set_licm_mssa_no_acc_for_promotion_cap(
  options : LLVMPassBuilderOptionsRef,
  licm_mssa_no_acc_for_promotion_cap : UInt,
) = "LLVMPassBuilderOptionsSetLicmMssaNoAccForPromotionCap"

///|
pub fn llvm_pass_builder_options_set_call_graph_profile(
  options : LLVMPassBuilderOptionsRef,
  call_graph_profile : Bool,
) -> Unit {
  __llvm_pass_builder_options_set_call_graph_profile(
    options,
    to_llvm_bool(call_graph_profile),
  )
}

///|
extern "C" fn __llvm_pass_builder_options_set_call_graph_profile(
  options : LLVMPassBuilderOptionsRef,
  call_graph_profile : LLVMBool,
) = "LLVMPassBuilderOptionsSetCallGraphProfile"

// void LLVMPassBuilderOptionsSetMergeFunctions(LLVMPassBuilderOptionsRef Options,
//                                              LLVMBool MergeFunctions);

///|
pub fn llvm_pass_builder_options_set_merge_functions(
  options : LLVMPassBuilderOptionsRef,
  merge_functions : Bool,
) -> Unit {
  __llvm_pass_builder_options_set_merge_functions(
    options,
    to_llvm_bool(merge_functions),
  )
}

///|
extern "C" fn __llvm_pass_builder_options_set_merge_functions(
  options : LLVMPassBuilderOptionsRef,
  merge_functions : LLVMBool,
) = "LLVMPassBuilderOptionsSetMergeFunctions"

///|
pub extern "C" fn llvm_pass_builder_options_set_inliner_threshold(
  options : LLVMPassBuilderOptionsRef,
  threshold : Int,
) = "LLVMPassBuilderOptionsSetInlinerThreshold"

///|
/// Dispose of a heap-allocated PassBuilderOptions instance
pub extern "C" fn llvm_dispose_pass_builder_options(
  options : LLVMPassBuilderOptionsRef,
) -> Unit = "LLVMDisposePassBuilderOptions"

// ===================================
// PassManagerBuilder
// ===================================
// /** See llvm::PassManagerBuilder. */
//pub extern "C" fn llvm_pass_manager_builder_create() -> LLVMPassManagerBuilderRef = "LLVMPassManagerBuilderCreate"

//pub extern "C" fn llvm_pass_manager_builder_dispose(pmb: LLVMPassManagerBuilderRef) -> Unit = "LLVMPassManagerBuilderDispose"

// /** See llvm::PassManagerBuilder::OptLevel. */
// void
// LLVMPassManagerBuilderSetOptLevel(LLVMPassManagerBuilderRef PMB,
//                                   unsigned OptLevel);
//pub extern "C" fn llvm_pass_manager_builder_set_opt_level(pmb: LLVMPassManagerBuilderRef, opt_level: UInt) -> Unit = "LLVMPassManagerBuilderSetOptLevel"
//
// /** See llvm::PassManagerBuilder::SizeLevel. */
//pub extern "C" fn llvm_pass_manager_builder_set_size_level(pmb: LLVMPassManagerBuilderRef, size_level: UInt) -> Unit = "LLVMPassManagerBuilderSetSizeLevel"
//
// /** See llvm::PassManagerBuilder::DisableUnitAtATime. */
// void
// LLVMPassManagerBuilderSetDisableUnitAtATime(LLVMPassManagerBuilderRef PMB,
//                                             LLVMBool Value);
//pub fn llvm_pass_manager_builder_set_disable_unit_at_a_time(pmb: LLVMPassManagerBuilderRef, value: Bool) -> Unit {
//   __llvm_pass_manager_builder_set_disable_unit_at_a_time(pmb, to_llvm_bool(value))
// }
// extern "C" fn __llvm_pass_manager_builder_set_disable_unit_at_a_time(pmb: LLVMPassManagerBuilderRef, value: LLVMBool) = "LLVMPassManagerBuilderSetDisableUnitAtATime"

//pub fn llvm_pass_manager_builder_set_disable_unroll_loops(
//   pmb: LLVMPassManagerBuilderRef, 
//   value: Bool
// ) -> Unit {
//   __llvm_pass_manager_builder_set_disable_unroll_loops(pmb, to_llvm_bool(value))
// }
// extern "C" fn __llvm_pass_manager_builder_set_disable_unroll_loops(pmb: LLVMPassManagerBuilderRef, value: LLVMBool) = "LLVMPassManagerBuilderSetDisableUnrollLoops"

// /** See llvm::PassManagerBuilder::DisableSimplifyLibCalls */
// void
// LLVMPassManagerBuilderSetDisableSimplifyLibCalls(LLVMPassManagerBuilderRef PMB,
//                                                  LLVMBool Value);
//pub fn llvm_pass_manager_builder_set_disable_simplify_lib_calls(
//   pmb: LLVMPassManagerBuilderRef, 
//   value: Bool
// ) -> Unit {
//   __llvm_pass_manager_builder_set_disable_simplify_lib_calls(pmb, to_llvm_bool(value))
// }
// extern "C" fn __llvm_pass_manager_builder_set_disable_simplify_lib_calls(pmb: LLVMPassManagerBuilderRef, value: LLVMBool) = "LLVMPassManagerBuilderSetDisableSimplifyLibCalls"

// /** See llvm::PassManagerBuilder::Inliner. */
// void
// LLVMPassManagerBuilderUseInlinerWithThreshold(LLVMPassManagerBuilderRef PMB,
//                                               unsigned Threshold);
//pub extern "C" fn llvm_pass_manager_builder_use_inliner_with_threshold(pmb: LLVMPassManagerBuilderRef, threshold: UInt) = "LLVMPassManagerBuilderUseInlinerWithThreshold"
//
// /** See llvm::PassManagerBuilder::populateFunctionPassManager. */
// void
// LLVMPassManagerBuilderPopulateFunctionPassManager(LLVMPassManagerBuilderRef PMB,
//                                                   LLVMPassManagerRef PM);
//pub extern "C" fn llvm_pass_manager_builder_populate_function_pass_manager(pmb: LLVMPassManagerBuilderRef, pm: LLVMPassManagerRef) = "LLVMPassManagerBuilderPopulateFunctionPassManager"
//
// /** See llvm::PassManagerBuilder::populateModulePassManager. */
// void
// LLVMPassManagerBuilderPopulateModulePassManager(LLVMPassManagerBuilderRef PMB,

// ===================================
// Scalar
// ===================================
// /** See llvm::createAggressiveDCEPass function. */
// void LLVMAddAggressiveDCEPass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_aggressive_dce_pass(pm: LLVMPassManagerRef) = "LLVMAddAggressiveDCEPass"
//
// /** See llvm::createDeadCodeEliminationPass function. */
// void LLVMAddDCEPass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_dce_pass(pm: LLVMPassManagerRef) = "LLVMAddDCEPass"
//
// /** See llvm::createBitTrackingDCEPass function. */
// void LLVMAddBitTrackingDCEPass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_bit_tracking_dce_pass(pm: LLVMPassManagerRef) = "LLVMAddBitTrackingDCEPass"
//
// /** See llvm::createAlignmentFromAssumptionsPass function. */
// void LLVMAddAlignmentFromAssumptionsPass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_alignment_from_assumptions_pass(pm: LLVMPassManagerRef) = "LLVMAddAlignmentFromAssumptionsPass"
//
// /** See llvm::createCFGSimplificationPass function. */
// void LLVMAddCFGSimplificationPass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_cfg_simplification_pass(pm: LLVMPassManagerRef) = "LLVMAddCFGSimplificationPass"
//
// /** See llvm::createDeadStoreEliminationPass function. */
// void LLVMAddDeadStoreEliminationPass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_dead_store_elimination_pass(pm: LLVMPassManagerRef) = "LLVMAddDeadStoreEliminationPass"
//
// /** See llvm::createScalarizerPass function. */
// void LLVMAddScalarizerPass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_scalarizer_pass(pm: LLVMPassManagerRef) = "LLVMAddScalarizerPass"
//
// /** See llvm::createMergedLoadStoreMotionPass function. */
// void LLVMAddMergedLoadStoreMotionPass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_merged_load_store_motion_pass(pm: LLVMPassManagerRef) = "LLVMAddMergedLoadStoreMotionPass"
//
// /** See llvm::createGVNPass function. */
// void LLVMAddGVNPass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_gvn_pass(pm: LLVMPassManagerRef) = "LLVMAddGVNPass"

// /** See llvm::createGVNPass function. */
// void LLVMAddNewGVNPass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_new_gvn_pass(pm: LLVMPassManagerRef) = "LLVMAddNewGVNPass"

// /** See llvm::createIndVarSimplifyPass function. */
// void LLVMAddIndVarSimplifyPass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_ind_var_simplify_pass(pm: LLVMPassManagerRef) = "LLVMAddIndVarSimplifyPass"

// /** See llvm::createInstructionCombiningPass function. */
// void LLVMAddInstructionCombiningPass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_instruction_combining_pass(pm: LLVMPassManagerRef) = "LLVMAddInstructionCombiningPass"
//
// /** See llvm::createInstSimplifyLegacyPass function. */
// void LLVMAddInstructionSimplifyPass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_instruction_simplify_pass(pm: LLVMPassManagerRef) = "LLVMAddInstructionSimplifyPass"
//
// /** See llvm::createJumpThreadingPass function. */
// void LLVMAddJumpThreadingPass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_jump_threading_pass(pm: LLVMPassManagerRef) = "LLVMAddJumpThreadingPass"
//
// /** See llvm::createLICMPass function. */
// void LLVMAddLICMPass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_licm_pass(pm: LLVMPassManagerRef) = "LLVMAddLICMPass"
//
// /** See llvm::createLoopDeletionPass function. */
// void LLVMAddLoopDeletionPass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_loop_deletion_pass(pm: LLVMPassManagerRef) = "LLVMAddLoopDeletionPass"
//
// /** See llvm::createLoopIdiomPass function */
// void LLVMAddLoopIdiomPass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_loop_idiom_pass(pm: LLVMPassManagerRef) = "LLVMAddLoopIdiomPass"
//
// /** See llvm::createLoopRotatePass function. */
// void LLVMAddLoopRotatePass(LLVMPassManagerRef PM);
//pub extern "C" fn llvm_add_loop_rotate_pass(pm: LLVMPassManagerRef) = "LLVMAddLoopRotatePass"
//
// /** See llvm::createLoopRerollPass function. */
// void LLVMAddLoopRerollPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_loop_reroll_pass(pm: LLVMPassManagerRef) = "LLVMAddLoopRerollPass"
//
// /** See llvm::createLoopUnrollPass function. */
// void LLVMAddLoopUnrollPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_loop_unroll_pass(pm: LLVMPassManagerRef) = "LLVMAddLoopUnrollPass";
//
// /** See llvm::createLoopUnrollAndJamPass function. */
// void LLVMAddLoopUnrollAndJamPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_loop_unroll_and_jam_pass(pm: LLVMPassManagerRef) = "LLVMAddLoopUnrollAndJamPass";
//
// /** See llvm::createLowerAtomicPass function. */
// void LLVMAddLowerAtomicPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_lower_atomic_pass(pm: LLVMPassManagerRef) = "LLVMAddLowerAtomicPass";
//
// /** See llvm::createMemCpyOptPass function. */
// void LLVMAddMemCpyOptPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_mem_cpy_opt_pass(pm: LLVMPassManagerRef) = "LLVMAddMemCpyOptPass";
//
// /** See llvm::createPartiallyInlineLibCallsPass function. */
// void LLVMAddPartiallyInlineLibCallsPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_partially_inline_lib_calls_pass(pm: LLVMPassManagerRef) = "LLVMAddPartiallyInlineLibCallsPass";
//
// /** See llvm::createReassociatePass function. */
// void LLVMAddReassociatePass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_reassociate_pass(pm: LLVMPassManagerRef) = "LLVMAddReassociatePass";
//
// /** See llvm::createSCCPPass function. */
// void LLVMAddSCCPPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_sccp_pass(pm: LLVMPassManagerRef) = "LLVMAddSCCPPass";
//
// /** See llvm::createSROAPass function. */
// void LLVMAddScalarReplAggregatesPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_scalar_repl_aggregates_pass(pm: LLVMPassManagerRef) = "LLVMAddScalarReplAggregatesPass";
//
// /** See llvm::createSROAPass function. */
// void LLVMAddScalarReplAggregatesPassSSA(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_scalar_repl_aggregates_pass_ssa(pm: LLVMPassManagerRef) = "LLVMAddScalarReplAggregatesPassSSA";
//
// /** See llvm::createSROAPass function. */
// void LLVMAddScalarReplAggregatesPassWithThreshold(LLVMPassManagerRef PM,
//                                                   int Threshold);
// pub extern "C" fn llvm_add_scalar_repl_aggregates_pass_with_threshold(pm: LLVMPassManagerRef, threshold: Int) = "LLVMAddScalarReplAggregatesPassWithThreshold";
//
// /** See llvm::createSimplifyLibCallsPass function. */
// void LLVMAddSimplifyLibCallsPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_simplify_lib_calls_pass(pm: LLVMPassManagerRef) = "LLVMAddSimplifyLibCallsPass";
//
// /** See llvm::createTailCallEliminationPass function. */
// void LLVMAddTailCallEliminationPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_tail_call_elimination_pass(pm: LLVMPassManagerRef) = "LLVMAddTailCallEliminationPass";
//
// /** See llvm::demotePromoteMemoryToRegisterPass function. */
// void LLVMAddDemoteMemoryToRegisterPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_demote_memory_to_register_pass(pm: LLVMPassManagerRef) = "LLVMAddDemoteMemoryToRegisterPass";
//
// /** See llvm::createVerifierPass function. */
// void LLVMAddVerifierPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_verifier_pass(pm: LLVMPassManagerRef) = "LLVMAddVerifierPass";
//
// /** See llvm::createCorrelatedValuePropagationPass function */
// void LLVMAddCorrelatedValuePropagationPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_correlated_value_propagation_pass(pm: LLVMPassManagerRef) = "LLVMAddCorrelatedValuePropagationPass";
//
// /** See llvm::createEarlyCSEPass function */
// void LLVMAddEarlyCSEPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_early_cse_pass(pm: LLVMPassManagerRef) = "LLVMAddEarlyCSEPass";
//
// /** See llvm::createEarlyCSEPass function */
// void LLVMAddEarlyCSEMemSSAPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_early_cse_mem_ssa_pass(pm: LLVMPassManagerRef) = "LLVMAddEarlyCSEMemSSAPass";
//
// /** See llvm::createLowerExpectIntrinsicPass function */
// void LLVMAddLowerExpectIntrinsicPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_lower_expect_intrinsic_pass(pm: LLVMPassManagerRef) = "LLVMAddLowerExpectIntrinsicPass";
//
// /** See llvm::createLowerConstantIntrinsicsPass function */
// void LLVMAddLowerConstantIntrinsicsPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_lower_constant_intrinsics_pass(pm: LLVMPassManagerRef) = "LLVMAddLowerConstantIntrinsicsPass";
//
// /** See llvm::createTypeBasedAliasAnalysisPass function */
// void LLVMAddTypeBasedAliasAnalysisPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_type_based_alias_analysis_pass(pm: LLVMPassManagerRef) = "LLVMAddTypeBasedAliasAnalysisPass";
//
// /** See llvm::createScopedNoAliasAAPass function */
// void LLVMAddScopedNoAliasAAPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_scoped_no_alias_aa_pass(pm: LLVMPassManagerRef) = "LLVMAddScopedNoAliasAAPass";
//
// /** See llvm::createBasicAliasAnalysisPass function */
// void LLVMAddBasicAliasAnalysisPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_basic_alias_analysis_pass(pm: LLVMPassManagerRef) = "LLVMAddBasicAliasAnalysisPass"
//
// /** See llvm::createUnifyFunctionExitNodesPass function */
// void LLVMAddUnifyFunctionExitNodesPass(LLVMPassManagerRef PM);

// ===================================
// Vectorize
// ===================================
// /** See llvm::createLoopVectorizePass function. */
// void LLVMAddLoopVectorizePass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_loop_vectorize_pass(pm: LLVMPassManagerRef) = "LLVMAddLoopVectorizePass"
//
// /** See llvm::createSLPVectorizerPass function. */
// void LLVMAddSLPVectorizePass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_slp_vectorize_pass(pm: LLVMPassManagerRef) = "LLVMAddSLPVectorizePass"

// ===================================
// IPO
// ===================================

// /** See llvm::createConstantMergePass function. */
// void LLVMAddConstantMergePass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_constant_merge_pass(pm: LLVMPassManagerRef) = "LLVMAddConstantMergePass";

// /** See llvm::createMergeFunctionsPass function. */
// void LLVMAddMergeFunctionsPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_merge_functions_pass(pm: LLVMPassManagerRef) = "LLVMAddMergeFunctionsPass";

// /** See llvm::createCalledValuePropagationPass function. */
// void LLVMAddCalledValuePropagationPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_called_value_propagation_pass(pm: LLVMPassManagerRef) = "LLVMAddCalledValuePropagationPass";

// /** See llvm::createDeadArgEliminationPass function. */
// void LLVMAddDeadArgEliminationPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_dead_arg_elimination_pass(pm: LLVMPassManagerRef) = "LLVMAddDeadArgEliminationPass";

// /** See llvm::createFunctionAttrsPass function. */
// void LLVMAddFunctionAttrsPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_function_attrs_pass(pm: LLVMPassManagerRef) = "LLVMAddFunctionAttrsPass";

// /** See llvm::createFunctionInliningPass function. */
// void LLVMAddFunctionInliningPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_function_inlining_pass(pm: LLVMPassManagerRef) = "LLVMAddFunctionInliningPass";

// /** See llvm::createAlwaysInlinerPass function. */
// void LLVMAddAlwaysInlinerPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_always_inliner_pass(pm: LLVMPassManagerRef) = "LLVMAddAlwaysInlinerPass";

// /** See llvm::createGlobalDCEPass function. */
// void LLVMAddGlobalDCEPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_global_dce_pass(pm: LLVMPassManagerRef) = "LLVMAddGlobalDCEPass";

// /** See llvm::createGlobalOptimizerPass function. */
// void LLVMAddGlobalOptimizerPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_global_optimizer_pass(pm: LLVMPassManagerRef) = "LLVMAddGlobalOptimizerPass";

// /** See llvm::createIPSCCPPass function. */
// void LLVMAddIPSCCPPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_ipsccp_pass(pm: LLVMPassManagerRef) = "LLVMAddIPSCCPPass";

// /** See llvm::createInternalizePass function. */
// void LLVMAddInternalizePass(LLVMPassManagerRef, unsigned AllButMain);
// pub extern "C" fn llvm_add_internalize_pass(pm: LLVMPassManagerRef, all_but_main:UInt) = "LLVMAddInternalizePass";//
// /**
//  * Create and add the internalize pass to the given pass manager with the
//  * provided preservation callback.
//  *
//  * The context parameter is forwarded to the callback on each invocation.
//  * As such, it is the responsibility of the caller to extend its lifetime
//  * until execution of this pass has finished.
//  *
//  * @see llvm::createInternalizePass function.
//  */
// void LLVMAddInternalizePassWithMustPreservePredicate(
//     LLVMPassManagerRef PM,
//     void *Context,
//     LLVMBool (*MustPreserve)(LLVMValueRef, void *));
//
// /** See llvm::createStripDeadPrototypesPass function. */
// void LLVMAddStripDeadPrototypesPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_strip_dead_prototypes_pass(pm: LLVMPassManagerRef) = "LLVMAddStripDeadPrototypesPass";
//
// /** See llvm::createStripSymbolsPass function. */
// void LLVMAddStripSymbolsPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_strip_symbols_pass(pm: LLVMPassManagerRef) = "LLVMAddStripSymbolsPass";

// ===================================
// Utils
// ===================================
// /** See llvm::createLowerSwitchPass function. */
// void LLVMAddLowerSwitchPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_lower_switch_pass(pm: LLVMPassManagerRef) = "LLVMAddLowerSwitchPass";
//
// /** See llvm::createPromoteMemoryToRegisterPass function. */
// void LLVMAddPromoteMemoryToRegisterPass(LLVMPassManagerRef PM);
// pub extern "C" fn llvm_add_promote_memory_to_register_pass(pm: LLVMPassManagerRef) = "LLVMAddPromoteMemoryToRegisterPass";
//
// /** See llvm::createAddDiscriminatorsPass function. */
// void LLVMAddAddDiscriminatorsPass(LLVMPassManagerRef PM);
