///|
pub extern "C" fn llvm_initialize_core(r : LLVMPassRegistryRef) = "LLVMInitializeCore"

///|
pub extern "C" fn llvm_initialize_transform_utils(r : LLVMPassRegistryRef) = "LLVMInitializeTransformUtils"

///|
pub extern "C" fn llvm_initialize_scalar_opts(r : LLVMPassRegistryRef) = "LLVMInitializeScalarOpts"

///|
pub extern "C" fn llvm_initialize_vectorization(r : LLVMPassRegistryRef) = "LLVMInitializeVectorization"

///|
pub extern "C" fn llvm_initialize_inst_combine(r : LLVMPassRegistryRef) = "LLVMInitializeInstCombine"

///|
pub extern "C" fn llvm_initialize_ipo(r : LLVMPassRegistryRef) = "LLVMInitializeIPO"

///|
pub extern "C" fn llvm_initialize_analysis(r : LLVMPassRegistryRef) = "LLVMInitializeAnalysis"

///|
pub extern "C" fn llvm_initialize_ipa(r : LLVMPassRegistryRef) = "LLVMInitializeIPA"

///|
pub extern "C" fn llvm_initialize_codegen(r : LLVMPassRegistryRef) = "LLVMInitializeCodeGen"

///|
pub extern "C" fn llvm_initialize_target(r : LLVMPassRegistryRef) = "LLVMInitializeTarget"
