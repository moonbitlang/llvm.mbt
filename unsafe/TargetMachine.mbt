// =======================================================
// TargetMachine.h
// =======================================================

///|
/// Returns the first llvm::Target in the registered targets list.
// pub extern "C" fn llvm_get_first_target() -> LLVMTargetRef = "__llvm_get_first_target"
pub extern "C" fn llvm_get_first_target() -> LLVMTargetRef = "LLVMGetFirstTarget"

///|
/// Returns the next llvm::Target given a previous one (or null if there's none)
pub extern "C" fn llvm_get_next_target(t : LLVMTargetRef) -> LLVMTargetRef = "LLVMGetNextTarget"

///|
///  Finds the target corresponding to the given name.
extern "C" fn __llvm_get_target_from_name(name : CStr) -> LLVMTargetRef = "LLVMGetTargetFromName"

///|
pub fn llvm_get_target_from_name(name : String) -> LLVMTargetRef {
  let name = moonbit_str_to_c_str(name)
  __llvm_get_target_from_name(name)
}

///|
/// Finds the target corresponding to the given triple and stores it in `T`.
/// Returns 0 on success. Optionally returns any error in ErrorMessage.
/// Use LLVMDisposeMessage to dispose the message.
// TODO: check if this is correct
extern "C" fn __llvm_get_target_from_triple(
  triple : CStr,
) -> (LLVMTargetRef, CStr, LLVMBool) = "__llvm_get_target_from_triple"

///|
/// Finds the target corresponding to the given triple and stores it in `T`.
/// Returns 0 on success. Optionally returns any error in ErrorMessage.
/// Use LLVMDisposeMessage to dispose the message.
pub fn llvm_get_target_from_triple(
  triple : String,
) -> (LLVMTargetRef, String, Bool) {
  let triple = moonbit_str_to_c_str(triple)
  let (target, cstr, is_ok) = __llvm_get_target_from_triple(triple)
  let is_ok = is_ok.to_moonbit_bool()
  if is_ok {
    (target, c_str_to_moonbit_str(cstr), is_ok)
  } else {
    (target, "", is_ok)
  }
}

///|
/// Returns the name of a target. See llvm::Target::getName
extern "C" fn __llvm_get_target_name(t : LLVMTargetRef) -> CStr = "LLVMGetTargetName"

///|
pub fn llvm_get_target_name(t : LLVMTargetRef) -> String {
  c_str_to_moonbit_str(__llvm_get_target_name(t))
}

///|
/// Returns the description  of a target. See llvm::Target::getDescription.
extern "C" fn __llvm_get_target_description(t : LLVMTargetRef) -> CStr = "LLVMGetTargetDescription"

///|
pub fn llvm_get_target_description(t : LLVMTargetRef) -> String {
  c_str_to_moonbit_str(__llvm_get_target_description(t))
}

///|
/// Returns if the target has a JIT.
pub extern "C" fn llvm_target_has_jit(t : LLVMTargetRef) -> LLVMBool = "LLVMTargetHasJIT"

///|
/// Returns if the target has a TargetMachine associated.
extern "C" fn __llvm_target_has_target_machine(t : LLVMTargetRef) -> LLVMBool = "LLVMTargetHasTargetMachine"

///|
pub fn llvm_target_has_target_machine(t : LLVMTargetRef) -> Bool {
  __llvm_target_has_target_machine(t).to_moonbit_bool()
}

///|
/// Returns if the target as an ASM backend (required for emitting output).
extern "C" fn __llvm_target_has_asm_backend(t : LLVMTargetRef) -> LLVMBool = "LLVMTargetHasAsmBackend"

///|
pub fn llvm_target_has_asm_backend(t : LLVMTargetRef) -> Bool {
  __llvm_target_has_asm_backend(t).to_moonbit_bool()
}

///|
/// Create a new set of options for an llvm::TargetMachine.
/// 
/// The returned option structure must be released with
/// LLVMDisposeTargetMachineOptions() after the call to
/// LLVMCreateTargetMachineWithOptions().
pub extern "C" fn llvm_create_target_machine_options() -> LLVMTargetMachineOptionsRef = "LLVMCreateTargetMachineOptions"

///|
/// Dispose of an LLVMTargetMachineOptionsRef instance.
pub extern "C" fn llvm_dispose_target_machine_options(
  options : LLVMTargetMachineOptionsRef,
) = "LLVMDisposeTargetMachineOptions"

///|
extern "C" fn __llvm_target_machine_options_set_cpu(
  options : LLVMTargetMachineOptionsRef,
  cpu : CStr,
) = "LLVMTargetMachineOptionsSetCPU"

///|
pub fn llvm_target_machine_options_set_cpu(
  options : LLVMTargetMachineOptionsRef,
  cpu : String,
) -> Unit {
  let cpu = moonbit_str_to_c_str(cpu)
  __llvm_target_machine_options_set_cpu(options, cpu)
}

///|
/// Set the list of features for the target machine.
/// 
/// - param Features a comma-separated list of features.
extern "C" fn __llvm_target_machine_options_set_features(
  options : LLVMTargetMachineOptionsRef,
  features : CStr,
) = "LLVMTargetMachineOptionsSetFeatures"

///|
pub fn llvm_target_machine_options_set_features(
  options : LLVMTargetMachineOptionsRef,
  features : String,
) -> Unit {
  let features = moonbit_str_to_c_str(features)
  __llvm_target_machine_options_set_features(options, features)
}

///|
extern "C" fn __llvm_target_machine_options_set_abi(
  options : LLVMTargetMachineOptionsRef,
  abi : CStr,
) = "LLVMTargetMachineOptionsSetABI"

///|
pub fn llvm_target_machine_options_set_abi(
  options : LLVMTargetMachineOptionsRef,
  abi : String,
) -> Unit {
  let abi = moonbit_str_to_c_str(abi)
  __llvm_target_machine_options_set_abi(options, abi)
}

///|
pub extern "C" fn llvm_target_machine_options_set_codegen_opt_level(
  options : LLVMTargetMachineOptionsRef,
  level : LLVMCodeGenOptLevel,
) = "LLVMTargetMachineOptionsSetCodeGenOptLevel"

///|
pub extern "C" fn llvm_target_machine_options_set_reloc_mode(
  options : LLVMTargetMachineOptionsRef,
  reloc : LLVMRelocMode,
) = "LLVMTargetMachineOptionsSetRelocMode"

///|
pub extern "C" fn llvm_target_machine_options_set_code_model(
  options : LLVMTargetMachineOptionsRef,
  code_model : LLVMCodeModel,
) = "LLVMTargetMachineOptionsSetCodeModel"

//
// /**
//  * Create a new llvm::TargetMachine.
//  *
//  * \param T the target to create a machine for.
//  * \param Triple a triple describing the target machine.
//  * \param Options additional configuration (see
//  *                LLVMCreateTargetMachineOptions()).
//  */
// LLVMTargetMachineRef
// LLVMCreateTargetMachineWithOptions(LLVMTargetRef T, const char *Triple,
//                                    LLVMTargetMachineOptionsRef Options);

///|
extern "C" fn __llvm_create_target_machine_with_options(
  t : LLVMTargetRef,
  triple : CStr,
  options : LLVMTargetMachineOptionsRef,
) -> LLVMTargetMachineRef = "LLVMCreateTargetMachineWithOptions"

///|
pub fn llvm_create_target_machine_with_options(
  t : LLVMTargetRef,
  triple : String,
  options : LLVMTargetMachineOptionsRef,
) -> LLVMTargetMachineRef {
  let triple = moonbit_str_to_c_str(triple)
  __llvm_create_target_machine_with_options(t, triple, options)
}

///|
/// Creates a new llvm::TargetMachine. See llvm::Target::createTargetMachine.
pub fn llvm_create_target_machine(
  t : LLVMTargetRef,
  triple : String,
  cpu : String,
  features : String,
  level : LLVMCodeGenOptLevel,
  reloc : LLVMRelocMode,
  code_model : LLVMCodeModel,
) -> LLVMTargetMachineRef {
  let triple = moonbit_str_to_c_str(triple)
  let cpu = moonbit_str_to_c_str(cpu)
  let features = moonbit_str_to_c_str(features)
  __llvm_create_target_machine(
    t, triple, cpu, features, level, reloc, code_model,
  )
}

///|
extern "C" fn __llvm_create_target_machine(
  t : LLVMTargetRef,
  triple : CStr,
  cpu : CStr,
  features : CStr,
  level : LLVMCodeGenOptLevel,
  reloc : LLVMRelocMode,
  code_model : LLVMCodeModel,
) -> LLVMTargetMachineRef = "LLVMCreateTargetMachine"

// /** Dispose the LLVMTargetMachineRef instance generated by
//   LLVMCreateTargetMachine. */
// void LLVMDisposeTargetMachine(LLVMTargetMachineRef T);
//
// /** Returns the Target used in a TargetMachine */
// LLVMTargetRef LLVMGetTargetMachineTarget(LLVMTargetMachineRef T);
//
// /** Returns the triple used creating this target machine. See
//   llvm::TargetMachine::getTriple. The result needs to be disposed with
//   LLVMDisposeMessage. */
// char *LLVMGetTargetMachineTriple(LLVMTargetMachineRef T);
//
// /** Returns the cpu used creating this target machine. See
//   llvm::TargetMachine::getCPU. The result needs to be disposed with
//   LLVMDisposeMessage. */
// char *LLVMGetTargetMachineCPU(LLVMTargetMachineRef T);
//
// /** Returns the feature string used creating this target machine. See
//   llvm::TargetMachine::getFeatureString. The result needs to be disposed with
//   LLVMDisposeMessage. */
// char *LLVMGetTargetMachineFeatureString(LLVMTargetMachineRef T);
//
// /** Create a DataLayout based on the targetMachine. */
// LLVMTargetDataRef LLVMCreateTargetDataLayout(LLVMTargetMachineRef T);
//
// /** Set the target machine's ASM verbosity. */
// void LLVMSetTargetMachineAsmVerbosity(LLVMTargetMachineRef T,
//                                       LLVMBool VerboseAsm);
//
// /** Enable fast-path instruction selection. */
// void LLVMSetTargetMachineFastISel(LLVMTargetMachineRef T, LLVMBool Enable);
//
// /** Enable global instruction selection. */
// void LLVMSetTargetMachineGlobalISel(LLVMTargetMachineRef T, LLVMBool Enable);
//
// /** Set abort behaviour when global instruction selection fails to lower/select
//  * an instruction. */
// void LLVMSetTargetMachineGlobalISelAbort(LLVMTargetMachineRef T,
//                                          LLVMGlobalISelAbortMode Mode);
//
// /** Enable the MachineOutliner pass. */
// void LLVMSetTargetMachineMachineOutliner(LLVMTargetMachineRef T,
//                                          LLVMBool Enable);
//
// /** Emits an asm or object file for the given module to the filename. This
//   wraps several c++ only classes (among them a file stream). Returns any
//   error in ErrorMessage. Use LLVMDisposeMessage to dispose the message. */
// LLVMBool LLVMTargetMachineEmitToFile(LLVMTargetMachineRef T, LLVMModuleRef M,
//                                      const char *Filename,
//                                      LLVMCodeGenFileType codegen,
//                                      char **ErrorMessage);
//
// /** Compile the LLVM IR stored in \p M and store the result in \p OutMemBuf. */
// LLVMBool LLVMTargetMachineEmitToMemoryBuffer(LLVMTargetMachineRef T, LLVMModuleRef M,
//   LLVMCodeGenFileType codegen, char** ErrorMessage, LLVMMemoryBufferRef *OutMemBuf);
//
// /*===-- Triple ------------------------------------------------------------===*/
// /** Get a triple for the host machine as a string. The result needs to be
//   disposed with LLVMDisposeMessage. */
// char* LLVMGetDefaultTargetTriple(void);
//
// /** Normalize a target triple. The result needs to be disposed with
//   LLVMDisposeMessage. */
// char* LLVMNormalizeTargetTriple(const char* triple);
//
// /** Get the host CPU as a string. The result needs to be disposed with
//   LLVMDisposeMessage. */
// char* LLVMGetHostCPUName(void);
//
// /** Get the host CPU's features as a string. The result needs to be disposed
//   with LLVMDisposeMessage. */
// char* LLVMGetHostCPUFeatures(void);
//
// /** Adds the target-specific analysis passes to the pass manager. */
// void LLVMAddAnalysisPasses(LLVMTargetMachineRef T, LLVMPassManagerRef PM);
