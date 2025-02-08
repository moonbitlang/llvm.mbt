
// ===================================
// PassBuilder
// ===================================
// /**
//  * A set of options passed which are attached to the Pass Manager upon run.
//  *
//  * This corresponds to an llvm::LLVMPassBuilderOptions instance
//  *
//  * The details for how the different properties of this structure are used can
//  * be found in the source for LLVMRunPasses
//  */
// typedef struct LLVMOpaquePassBuilderOptions *LLVMPassBuilderOptionsRef;
//
// /**
//  * Construct and run a set of passes over a module
//  *
//  * This function takes a string with the passes that should be used. The format
//  * of this string is the same as opt's -passes argument for the new pass
//  * manager. Individual passes may be specified, separated by commas. Full
//  * pipelines may also be invoked using `default<O3>` and friends. See opt for
//  * full reference of the Passes format.
//  */
// LLVMErrorRef LLVMRunPasses(LLVMModuleRef M, const char *Passes,
//                            LLVMTargetMachineRef TM,
//                            LLVMPassBuilderOptionsRef Options);
//
// /**
//  * Create a new set of options for a PassBuilder
//  *
//  * Ownership of the returned instance is given to the client, and they are
//  * responsible for it. The client should call LLVMDisposePassBuilderOptions
//  * to free the pass builder options.
//  */
// LLVMPassBuilderOptionsRef LLVMCreatePassBuilderOptions(void);
//
// /**
//  * Toggle adding the VerifierPass for the PassBuilder, ensuring all functions
//  * inside the module is valid.
//  */
// void LLVMPassBuilderOptionsSetVerifyEach(LLVMPassBuilderOptionsRef Options,
//                                          LLVMBool VerifyEach);
//
// /**
//  * Toggle debug logging when running the PassBuilder
//  */
// void LLVMPassBuilderOptionsSetDebugLogging(LLVMPassBuilderOptionsRef Options,
//                                            LLVMBool DebugLogging);
//
// void LLVMPassBuilderOptionsSetLoopInterleaving(
//     LLVMPassBuilderOptionsRef Options, LLVMBool LoopInterleaving);
//
// void LLVMPassBuilderOptionsSetLoopVectorization(
//     LLVMPassBuilderOptionsRef Options, LLVMBool LoopVectorization);
//
// void LLVMPassBuilderOptionsSetSLPVectorization(
//     LLVMPassBuilderOptionsRef Options, LLVMBool SLPVectorization);
//
// void LLVMPassBuilderOptionsSetLoopUnrolling(LLVMPassBuilderOptionsRef Options,
//                                             LLVMBool LoopUnrolling);
//
// void LLVMPassBuilderOptionsSetForgetAllSCEVInLoopUnroll(
//     LLVMPassBuilderOptionsRef Options, LLVMBool ForgetAllSCEVInLoopUnroll);
//
// void LLVMPassBuilderOptionsSetLicmMssaOptCap(LLVMPassBuilderOptionsRef Options,
//                                              unsigned LicmMssaOptCap);
//
// void LLVMPassBuilderOptionsSetLicmMssaNoAccForPromotionCap(
//     LLVMPassBuilderOptionsRef Options, unsigned LicmMssaNoAccForPromotionCap);
//
// void LLVMPassBuilderOptionsSetCallGraphProfile(
//     LLVMPassBuilderOptionsRef Options, LLVMBool CallGraphProfile);
//
// void LLVMPassBuilderOptionsSetMergeFunctions(LLVMPassBuilderOptionsRef Options,
//                                              LLVMBool MergeFunctions);
//
// void LLVMPassBuilderOptionsSetInlinerThreshold(
//     LLVMPassBuilderOptionsRef Options, int Threshold);
//
// /**
//  * Dispose of a heap-allocated PassBuilderOptions instance
//  */
// void LLVMDisposePassBuilderOptions(LLVMPassBuilderOptionsRef Options);

// ===================================
// PassManagerBuilder
// ===================================
// /** See llvm::PassManagerBuilder. */
// LLVMPassManagerBuilderRef LLVMPassManagerBuilderCreate(void);
// void LLVMPassManagerBuilderDispose(LLVMPassManagerBuilderRef PMB);
//
// /** See llvm::PassManagerBuilder::OptLevel. */
// void
// LLVMPassManagerBuilderSetOptLevel(LLVMPassManagerBuilderRef PMB,
//                                   unsigned OptLevel);
//
// /** See llvm::PassManagerBuilder::SizeLevel. */
// void
// LLVMPassManagerBuilderSetSizeLevel(LLVMPassManagerBuilderRef PMB,
//                                    unsigned SizeLevel);
//
// /** See llvm::PassManagerBuilder::DisableUnitAtATime. */
// void
// LLVMPassManagerBuilderSetDisableUnitAtATime(LLVMPassManagerBuilderRef PMB,
//                                             LLVMBool Value);
//
// /** See llvm::PassManagerBuilder::DisableUnrollLoops. */
// void
// LLVMPassManagerBuilderSetDisableUnrollLoops(LLVMPassManagerBuilderRef PMB,
//                                             LLVMBool Value);
//
// /** See llvm::PassManagerBuilder::DisableSimplifyLibCalls */
// void
// LLVMPassManagerBuilderSetDisableSimplifyLibCalls(LLVMPassManagerBuilderRef PMB,
//                                                  LLVMBool Value);
//
// /** See llvm::PassManagerBuilder::Inliner. */
// void
// LLVMPassManagerBuilderUseInlinerWithThreshold(LLVMPassManagerBuilderRef PMB,
//                                               unsigned Threshold);
//
// /** See llvm::PassManagerBuilder::populateFunctionPassManager. */
// void
// LLVMPassManagerBuilderPopulateFunctionPassManager(LLVMPassManagerBuilderRef PMB,
//                                                   LLVMPassManagerRef PM);
//
// /** See llvm::PassManagerBuilder::populateModulePassManager. */
// void
// LLVMPassManagerBuilderPopulateModulePassManager(LLVMPassManagerBuilderRef PMB,

// ===================================
// Scalar
// ===================================
// /** See llvm::createAggressiveDCEPass function. */
// void LLVMAddAggressiveDCEPass(LLVMPassManagerRef PM);
//
// /** See llvm::createDeadCodeEliminationPass function. */
// void LLVMAddDCEPass(LLVMPassManagerRef PM);
//
// /** See llvm::createBitTrackingDCEPass function. */
// void LLVMAddBitTrackingDCEPass(LLVMPassManagerRef PM);
//
// /** See llvm::createAlignmentFromAssumptionsPass function. */
// void LLVMAddAlignmentFromAssumptionsPass(LLVMPassManagerRef PM);
//
// /** See llvm::createCFGSimplificationPass function. */
// void LLVMAddCFGSimplificationPass(LLVMPassManagerRef PM);
//
// /** See llvm::createDeadStoreEliminationPass function. */
// void LLVMAddDeadStoreEliminationPass(LLVMPassManagerRef PM);
//
// /** See llvm::createScalarizerPass function. */
// void LLVMAddScalarizerPass(LLVMPassManagerRef PM);
//
// /** See llvm::createMergedLoadStoreMotionPass function. */
// void LLVMAddMergedLoadStoreMotionPass(LLVMPassManagerRef PM);
//
// /** See llvm::createGVNPass function. */
// void LLVMAddGVNPass(LLVMPassManagerRef PM);
//
// /** See llvm::createGVNPass function. */
// void LLVMAddNewGVNPass(LLVMPassManagerRef PM);
//
// /** See llvm::createIndVarSimplifyPass function. */
// void LLVMAddIndVarSimplifyPass(LLVMPassManagerRef PM);
//
// /** See llvm::createInstructionCombiningPass function. */
// void LLVMAddInstructionCombiningPass(LLVMPassManagerRef PM);
//
// /** See llvm::createInstSimplifyLegacyPass function. */
// void LLVMAddInstructionSimplifyPass(LLVMPassManagerRef PM);
//
// /** See llvm::createJumpThreadingPass function. */
// void LLVMAddJumpThreadingPass(LLVMPassManagerRef PM);
//
// /** See llvm::createLICMPass function. */
// void LLVMAddLICMPass(LLVMPassManagerRef PM);
//
// /** See llvm::createLoopDeletionPass function. */
// void LLVMAddLoopDeletionPass(LLVMPassManagerRef PM);
//
// /** See llvm::createLoopIdiomPass function */
// void LLVMAddLoopIdiomPass(LLVMPassManagerRef PM);
//
// /** See llvm::createLoopRotatePass function. */
// void LLVMAddLoopRotatePass(LLVMPassManagerRef PM);
//
// /** See llvm::createLoopRerollPass function. */
// void LLVMAddLoopRerollPass(LLVMPassManagerRef PM);
//
// /** See llvm::createLoopUnrollPass function. */
// void LLVMAddLoopUnrollPass(LLVMPassManagerRef PM);
//
// /** See llvm::createLoopUnrollAndJamPass function. */
// void LLVMAddLoopUnrollAndJamPass(LLVMPassManagerRef PM);
//
// /** See llvm::createLowerAtomicPass function. */
// void LLVMAddLowerAtomicPass(LLVMPassManagerRef PM);
//
// /** See llvm::createMemCpyOptPass function. */
// void LLVMAddMemCpyOptPass(LLVMPassManagerRef PM);
//
// /** See llvm::createPartiallyInlineLibCallsPass function. */
// void LLVMAddPartiallyInlineLibCallsPass(LLVMPassManagerRef PM);
//
// /** See llvm::createReassociatePass function. */
// void LLVMAddReassociatePass(LLVMPassManagerRef PM);
//
// /** See llvm::createSCCPPass function. */
// void LLVMAddSCCPPass(LLVMPassManagerRef PM);
//
// /** See llvm::createSROAPass function. */
// void LLVMAddScalarReplAggregatesPass(LLVMPassManagerRef PM);
//
// /** See llvm::createSROAPass function. */
// void LLVMAddScalarReplAggregatesPassSSA(LLVMPassManagerRef PM);
//
// /** See llvm::createSROAPass function. */
// void LLVMAddScalarReplAggregatesPassWithThreshold(LLVMPassManagerRef PM,
//                                                   int Threshold);
//
// /** See llvm::createSimplifyLibCallsPass function. */
// void LLVMAddSimplifyLibCallsPass(LLVMPassManagerRef PM);
//
// /** See llvm::createTailCallEliminationPass function. */
// void LLVMAddTailCallEliminationPass(LLVMPassManagerRef PM);
//
// /** See llvm::demotePromoteMemoryToRegisterPass function. */
// void LLVMAddDemoteMemoryToRegisterPass(LLVMPassManagerRef PM);
//
// /** See llvm::createVerifierPass function. */
// void LLVMAddVerifierPass(LLVMPassManagerRef PM);
//
// /** See llvm::createCorrelatedValuePropagationPass function */
// void LLVMAddCorrelatedValuePropagationPass(LLVMPassManagerRef PM);
//
// /** See llvm::createEarlyCSEPass function */
// void LLVMAddEarlyCSEPass(LLVMPassManagerRef PM);
//
// /** See llvm::createEarlyCSEPass function */
// void LLVMAddEarlyCSEMemSSAPass(LLVMPassManagerRef PM);
//
// /** See llvm::createLowerExpectIntrinsicPass function */
// void LLVMAddLowerExpectIntrinsicPass(LLVMPassManagerRef PM);
//
// /** See llvm::createLowerConstantIntrinsicsPass function */
// void LLVMAddLowerConstantIntrinsicsPass(LLVMPassManagerRef PM);
//
// /** See llvm::createTypeBasedAliasAnalysisPass function */
// void LLVMAddTypeBasedAliasAnalysisPass(LLVMPassManagerRef PM);
//
// /** See llvm::createScopedNoAliasAAPass function */
// void LLVMAddScopedNoAliasAAPass(LLVMPassManagerRef PM);
//
// /** See llvm::createBasicAliasAnalysisPass function */
// void LLVMAddBasicAliasAnalysisPass(LLVMPassManagerRef PM);
//
// /** See llvm::createUnifyFunctionExitNodesPass function */
// void LLVMAddUnifyFunctionExitNodesPass(LLVMPassManagerRef PM);


// ===================================
// Vectorize
// ===================================
// /** See llvm::createLoopVectorizePass function. */
// void LLVMAddLoopVectorizePass(LLVMPassManagerRef PM);
//
// /** See llvm::createSLPVectorizerPass function. */
// void LLVMAddSLPVectorizePass(LLVMPassManagerRef PM);

// ===================================
// IPO
// ===================================

// /** See llvm::createConstantMergePass function. */
// void LLVMAddConstantMergePass(LLVMPassManagerRef PM);
//
// /** See llvm::createMergeFunctionsPass function. */
// void LLVMAddMergeFunctionsPass(LLVMPassManagerRef PM);
//
// /** See llvm::createCalledValuePropagationPass function. */
// void LLVMAddCalledValuePropagationPass(LLVMPassManagerRef PM);
//
// /** See llvm::createDeadArgEliminationPass function. */
// void LLVMAddDeadArgEliminationPass(LLVMPassManagerRef PM);
//
// /** See llvm::createFunctionAttrsPass function. */
// void LLVMAddFunctionAttrsPass(LLVMPassManagerRef PM);
//
// /** See llvm::createFunctionInliningPass function. */
// void LLVMAddFunctionInliningPass(LLVMPassManagerRef PM);
//
// /** See llvm::createAlwaysInlinerPass function. */
// void LLVMAddAlwaysInlinerPass(LLVMPassManagerRef PM);
//
// /** See llvm::createGlobalDCEPass function. */
// void LLVMAddGlobalDCEPass(LLVMPassManagerRef PM);
//
// /** See llvm::createGlobalOptimizerPass function. */
// void LLVMAddGlobalOptimizerPass(LLVMPassManagerRef PM);
//
// /** See llvm::createIPSCCPPass function. */
// void LLVMAddIPSCCPPass(LLVMPassManagerRef PM);
//
// /** See llvm::createInternalizePass function. */
// void LLVMAddInternalizePass(LLVMPassManagerRef, unsigned AllButMain);
//
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
//
// /** See llvm::createStripSymbolsPass function. */
// void LLVMAddStripSymbolsPass(LLVMPassManagerRef PM);

// ===================================
// InstCombine
// ===================================
// void LLVMAddInstructionCombiningPass(LLVMPassManagerRef PM);


// ===================================
// Utils
// ===================================
// /** See llvm::createLowerSwitchPass function. */
// void LLVMAddLowerSwitchPass(LLVMPassManagerRef PM);
//
// /** See llvm::createPromoteMemoryToRegisterPass function. */
// void LLVMAddPromoteMemoryToRegisterPass(LLVMPassManagerRef PM);
//
// /** See llvm::createAddDiscriminatorsPass function. */
// void LLVMAddAddDiscriminatorsPass(LLVMPassManagerRef PM);
