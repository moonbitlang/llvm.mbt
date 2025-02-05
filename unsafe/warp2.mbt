// =======================================================
// Comdat.h
// =======================================================

///| Return the Comdat in the module with the specified name.
///
/// Return the Comdat in the module with the specified name. It is created
/// if it didn't already exist.
/// 
/// - see llvm::Module::getOrInsertComdat()
extern "C" fn __llvm_get_or_insert_comdat(m: LLVMModuleRef, name: CStr) -> LLVMComdatRef = "__llvm_get_or_insert_comdat"
pub fn llvm_get_or_insert_comdat(m: LLVMModuleRef, name: String) -> LLVMComdatRef {
  let name = moonbit_str_to_c_str(name)
  __llvm_get_or_insert_comdat(m, name)
}
pub fn LLVMModuleRef::get_or_insert_comdat(self: LLVMModuleRef, name: String) -> LLVMComdatRef {
  let name = moonbit_str_to_c_str(name)
  __llvm_get_or_insert_comdat(self, name)
}

///| Get the Comdat assigned to the given global object.
/// 
/// - see llvm::GlobalObject::getComdat()
pub extern "C" fn llvm_get_comdat(v: LLVMValueRef) -> LLVMComdatRef = "__llvm_get_comdat"

///| Assign the Comdat to the given global object.
/// 
/// - see llvm::GlobalObject::setComdat()
pub extern "C" fn llvm_set_comdat(v: LLVMValueRef, c: LLVMComdatRef) = "__llvm_set_comdat"

///| Get the conflict resolution selection kind for the Comdat.
/// 
/// - see llvm::Comdat::getSelectionKind()
extern "C" fn __llvm_get_comdat_selection_kind(c: LLVMComdatRef) -> Int = "__llvm_get_comdat_selection_kind"
pub fn llvm_get_comdat_selection_kind(c: LLVMComdatRef) -> LLVMComdatSelectionKind {
  let kind = __llvm_get_comdat_selection_kind(c)
  let kind = LLVMComdatSelectionKind::from_int(kind)

  kind
}

///| Set the conflict resolution selection kind for the Comdat.
/// 
/// - see llvm::Comdat::setSelectionKind()
extern "C" fn __llvm_set_comdat_selection_kind(c: LLVMComdatRef, kind: Int) = "__llvm_set_comdat_selection_kind"
pub fn llvm_set_comdat_selection_kind(c: LLVMComdatRef, kind: LLVMComdatSelectionKind) -> Unit {
  let i = kind.to_int()
  __llvm_set_comdat_selection_kind(c, i)
}

// =======================================================
// Linker.h
// =======================================================

///| Links the source module into the destination module.
/// 
/// Links the source module into the destination module. The source 
/// module is destroyed.
/// The return value is true if an error occurred, false otherwise.
/// Use the diagnostic handler to get any diagnostic message.
extern "C" fn __llvm_link_modules2(dest: LLVMModuleRef, src: LLVMModuleRef) -> LLVMBool = "__llvm_link_modules2"
pub fn llvm_link_modules(dest: LLVMModuleRef, src: LLVMModuleRef) -> Bool {
  __llvm_link_modules2(dest, src).to_moonbit_bool()
}

// =======================================================
// TargetMachine.h
// =======================================================

///| Returns the first llvm::Target in the registered targets list.
pub extern "C" fn llvm_get_first_target() -> LLVMTargetRef = "__llvm_get_first_target"

///| Returns the next llvm::Target given a previous one (or null if there's none)
pub extern "C" fn llvm_get_next_target(t: LLVMTargetRef) -> LLVMTargetRef = "__llvm_get_next_target"

///|  Finds the target corresponding to the given name.
extern "C" fn __llvm_get_target_from_name(name: CStr) -> LLVMTargetRef = "__llvm_get_target_from_name"
pub fn llvm_get_target_from_name(name: String) -> LLVMTargetRef {
  let name = moonbit_str_to_c_str(name)
  __llvm_get_target_from_name(name)
}

/// Finds the target corresponding to the given triple and stores it in `T`.
/// Returns 0 on success. Optionally returns any error in ErrorMessage.
/// Use LLVMDisposeMessage to dispose the message.
// TODO: check if this is correct
extern "C" fn __llvm_get_target_from_triple(triple: CStr) -> (LLVMTargetRef, CStr, LLVMBool) = "__llvm_get_target_from_triple"

/// Finds the target corresponding to the given triple and stores it in `T`.
/// Returns 0 on success. Optionally returns any error in ErrorMessage.
/// Use LLVMDisposeMessage to dispose the message.
pub fn llvm_get_target_from_triple(triple: String) -> (LLVMTargetRef, String, Bool) {
  let triple = moonbit_str_to_c_str(triple)
  let (target, cstr, is_ok) = __llvm_get_target_from_triple(triple)
  let is_ok = is_ok.to_moonbit_bool()
  if is_ok {
    (target, c_str_to_moonbit_str(cstr), is_ok)
  } else {
    (target, "", is_ok)
  }
}

///| Returns the name of a target. See llvm::Target::getName
extern "C" fn __llvm_get_target_name(t: LLVMTargetRef) -> CStr = "__llvm_get_target_name"
pub fn llvm_get_target_name(t: LLVMTargetRef) -> String {
  c_str_to_moonbit_str(__llvm_get_target_name(t))
}

///| Returns the description  of a target. See llvm::Target::getDescription.
extern "C" fn __llvm_get_target_description(t: LLVMTargetRef) -> CStr = "__llvm_get_target_description"
pub fn llvm_get_target_description(t: LLVMTargetRef) -> String {
  c_str_to_moonbit_str(__llvm_get_target_description(t))
}

///| Returns if the target has a JIT.
pub extern "C" fn llvm_target_has_jit(t: LLVMTargetRef) -> LLVMBool = "__llvm_target_has_jit"


///| Returns if the target has a TargetMachine associated.
extern "C" fn __llvm_target_has_target_machine(t: LLVMTargetRef) -> LLVMBool = "__llvm_target_has_target_machine"
pub fn llvm_target_has_target_machine(t: LLVMTargetRef) -> Bool {
  __llvm_target_has_target_machine(t).to_moonbit_bool()
}


///| Returns if the target as an ASM backend (required for emitting output).
extern "C" fn __llvm_target_has_asm_backend(t: LLVMTargetRef) -> LLVMBool = "__llvm_target_has_asm_backend"
pub fn llvm_target_has_asm_backend(t: LLVMTargetRef) -> Bool {
  __llvm_target_has_asm_backend(t).to_moonbit_bool()
}

///| Create a new set of options for an llvm::TargetMachine.
/// 
/// The returned option structure must be released with
/// LLVMDisposeTargetMachineOptions() after the call to
/// LLVMCreateTargetMachineWithOptions().
pub extern "C" fn llvm_create_target_machine_options() -> LLVMTargetMachineOptionsRef = "__llvm_create_target_machine_options"

///| Dispose of an LLVMTargetMachineOptionsRef instance.
pub extern "C" fn llvm_dispose_target_machine_options(options: LLVMTargetMachineOptionsRef) = "__llvm_dispose_target_machine_options"

extern "C" fn __llvm_target_machine_options_set_cpu(options: LLVMTargetMachineOptionsRef, cpu: CStr) = "__llvm_target_machine_options_set_cpu" 
pub fn llvm_target_machine_options_set_cpu(options: LLVMTargetMachineOptionsRef, cpu: String) -> Unit {
  let cpu = moonbit_str_to_c_str(cpu)
  __llvm_target_machine_options_set_cpu(options, cpu)
}

///| Set the list of features for the target machine.
/// 
/// - param Features a comma-separated list of features.
extern "C" fn __llvm_target_machine_options_set_features(options: LLVMTargetMachineOptionsRef, features: CStr) = "__llvm_target_machine_options_set_features"
pub fn llvm_target_machine_options_set_features(options: LLVMTargetMachineOptionsRef, features: String) -> Unit {
  let features = moonbit_str_to_c_str(features)
  __llvm_target_machine_options_set_features(options, features)
}

extern "C" fn __llvm_target_machine_options_set_abi(options: LLVMTargetMachineOptionsRef, abi: CStr) = "__llvm_target_machine_options_set_abi"
pub fn llvm_target_machine_options_set_abi(options: LLVMTargetMachineOptionsRef, abi: String) -> Unit {
  let abi = moonbit_str_to_c_str(abi)
  __llvm_target_machine_options_set_abi(options, abi)
}

pub extern "C" fn llvm_target_machine_options_set_codegen_opt_level(options: LLVMTargetMachineOptionsRef, level: LLVMCodeGenOptLevel) = "__llvm_target_machine_options_set_codegen_opt_level"

pub extern "C" fn llvm_target_machine_options_set_reloc_mode(options: LLVMTargetMachineOptionsRef, reloc: LLVMRelocMode) = "__llvm_target_machine_options_set_reloc_mode"

pub extern "C" fn llvm_target_machine_options_set_code_model(options: LLVMTargetMachineOptionsRef, code_model: LLVMCodeModel) = "__llvm_target_machine_options_set_code_model"

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
extern "C" fn __llvm_create_target_machine_with_options(t: LLVMTargetRef, triple: CStr, options: LLVMTargetMachineOptionsRef) -> LLVMTargetMachineRef = "__llvm_create_target_machine_with_options"
pub fn llvm_create_target_machine_with_options(t: LLVMTargetRef, triple: String, options: LLVMTargetMachineOptionsRef) -> LLVMTargetMachineRef {
  let triple = moonbit_str_to_c_str(triple)
  __llvm_create_target_machine_with_options(t, triple, options)
}

///| Creates a new llvm::TargetMachine. See llvm::Target::createTargetMachine.
extern "C" fn __llvm_create_target_machine(t: LLVMTargetRef, triple: CStr, cpu: CStr, features: CStr, level: LLVMCodeGenOptLevel, reloc: LLVMRelocMode, code_model: LLVMCodeModel) -> LLVMTargetMachineRef = "__llvm_create_target_machine"
pub fn llvm_create_target_machine(t: LLVMTargetRef, triple: String, cpu: String, features: String, level: LLVMCodeGenOptLevel, reloc: LLVMRelocMode, code_model: LLVMCodeModel) -> LLVMTargetMachineRef {
  let triple = moonbit_str_to_c_str(triple)
  let cpu = moonbit_str_to_c_str(cpu)
  let features = moonbit_str_to_c_str(features)
  __llvm_create_target_machine(t, triple, cpu, features, level, reloc, code_model)
}


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

// =======================================================
// BitReader.h
// =======================================================

// /* Builds a module from the bitcode in the specified memory buffer, returning a
//    reference to the module via the OutModule parameter. Returns 0 on success.
//    Optionally returns a human-readable error message via OutMessage.
//
//    This is deprecated. Use LLVMParseBitcode2. */
// LLVMBool LLVMParseBitcode(LLVMMemoryBufferRef MemBuf, LLVMModuleRef *OutModule,
//                           char **OutMessage);
//
// /* Builds a module from the bitcode in the specified memory buffer, returning a
//    reference to the module via the OutModule parameter. Returns 0 on success. */
// LLVMBool LLVMParseBitcode2(LLVMMemoryBufferRef MemBuf,
//                            LLVMModuleRef *OutModule);
//
// /* This is deprecated. Use LLVMParseBitcodeInContext2. */
// LLVMBool LLVMParseBitcodeInContext(LLVMContextRef ContextRef,
//                                    LLVMMemoryBufferRef MemBuf,
//                                    LLVMModuleRef *OutModule, char **OutMessage);
//
// LLVMBool LLVMParseBitcodeInContext2(LLVMContextRef ContextRef,
//                                     LLVMMemoryBufferRef MemBuf,
//                                     LLVMModuleRef *OutModule);
//
// /** Reads a module from the specified path, returning via the OutMP parameter
//     a module provider which performs lazy deserialization. Returns 0 on success.
//     Optionally returns a human-readable error message via OutMessage.
//     This is deprecated. Use LLVMGetBitcodeModuleInContext2. */
// LLVMBool LLVMGetBitcodeModuleInContext(LLVMContextRef ContextRef,
//                                        LLVMMemoryBufferRef MemBuf,
//                                        LLVMModuleRef *OutM, char **OutMessage);
//
// /** Reads a module from the given memory buffer, returning via the OutMP
//  * parameter a module provider which performs lazy deserialization.
//  *
//  * Returns 0 on success.
//  *
//  * Takes ownership of \p MemBuf if (and only if) the module was read
//  * successfully. */
// LLVMBool LLVMGetBitcodeModuleInContext2(LLVMContextRef ContextRef,
//                                         LLVMMemoryBufferRef MemBuf,
//                                         LLVMModuleRef *OutM);
//
// /* This is deprecated. Use LLVMGetBitcodeModule2. */
// LLVMBool LLVMGetBitcodeModule(LLVMMemoryBufferRef MemBuf, LLVMModuleRef *OutM,
//                               char **OutMessage);
//
// LLVMBool LLVMGetBitcodeModule2(LLVMMemoryBufferRef MemBuf, LLVMModuleRef *OutM);


// =======================================================
// BitWriter.h
// =======================================================

// /** Writes a module to the specified path. Returns 0 on success. */
// int LLVMWriteBitcodeToFile(LLVMModuleRef M, const char *Path);
//
// /** Writes a module to an open file descriptor. Returns 0 on success. */
// int LLVMWriteBitcodeToFD(LLVMModuleRef M, int FD, int ShouldClose,
//                          int Unbuffered);
//
// /** Deprecated for LLVMWriteBitcodeToFD. Writes a module to an open file
//     descriptor. Returns 0 on success. Closes the Handle. */
// int LLVMWriteBitcodeToFileHandle(LLVMModuleRef M, int Handle);
//
// /** Writes a module to a new memory buffer and returns it. */
// LLVMMemoryBufferRef LLVMWriteBitcodeToMemoryBuffer(LLVMModuleRef M);

// =======================================================
// Object.h
// =======================================================

// /**
//  * Create a binary file from the given memory buffer.
//  *
//  * The exact type of the binary file will be inferred automatically, and the
//  * appropriate implementation selected.  The context may be NULL except if
//  * the resulting file is an LLVM IR file.
//  *
//  * The memory buffer is not consumed by this function.  It is the responsibilty
//  * of the caller to free it with \c LLVMDisposeMemoryBuffer.
//  *
//  * If NULL is returned, the \p ErrorMessage parameter is populated with the
//  * error's description.  It is then the caller's responsibility to free this
//  * message by calling \c LLVMDisposeMessage.
//  *
//  * @see llvm::object::createBinary
//  */
// LLVMBinaryRef LLVMCreateBinary(LLVMMemoryBufferRef MemBuf,
//                                LLVMContextRef Context,
//                                char **ErrorMessage);
//
// /**
//  * Dispose of a binary file.
//  *
//  * The binary file does not own its backing buffer.  It is the responsibilty
//  * of the caller to free it with \c LLVMDisposeMemoryBuffer.
//  */
// void LLVMDisposeBinary(LLVMBinaryRef BR);
//
// /**
//  * Retrieves a copy of the memory buffer associated with this object file.
//  *
//  * The returned buffer is merely a shallow copy and does not own the actual
//  * backing buffer of the binary. Nevertheless, it is the responsibility of the
//  * caller to free it with \c LLVMDisposeMemoryBuffer.
//  *
//  * @see llvm::object::getMemoryBufferRef
//  */
// LLVMMemoryBufferRef LLVMBinaryCopyMemoryBuffer(LLVMBinaryRef BR);
//
// /**
//  * Retrieve the specific type of a binary.
//  *
//  * @see llvm::object::Binary::getType
//  */
// LLVMBinaryType LLVMBinaryGetType(LLVMBinaryRef BR);
//
// /*
//  * For a Mach-O universal binary file, retrieves the object file corresponding
//  * to the given architecture if it is present as a slice.
//  *
//  * If NULL is returned, the \p ErrorMessage parameter is populated with the
//  * error's description.  It is then the caller's responsibility to free this
//  * message by calling \c LLVMDisposeMessage.
//  *
//  * It is the responsiblity of the caller to free the returned object file by
//  * calling \c LLVMDisposeBinary.
//  */
// LLVMBinaryRef LLVMMachOUniversalBinaryCopyObjectForArch(LLVMBinaryRef BR,
//                                                         const char *Arch,
//                                                         size_t ArchLen,
//                                                         char **ErrorMessage);
//
// /**
//  * Retrieve a copy of the section iterator for this object file.
//  *
//  * If there are no sections, the result is NULL.
//  *
//  * The returned iterator is merely a shallow copy. Nevertheless, it is
//  * the responsibility of the caller to free it with
//  * \c LLVMDisposeSectionIterator.
//  *
//  * @see llvm::object::sections()
//  */
// LLVMSectionIteratorRef LLVMObjectFileCopySectionIterator(LLVMBinaryRef BR);
//
// /**
//  * Returns whether the given section iterator is at the end.
//  *
//  * @see llvm::object::section_end
//  */
// LLVMBool LLVMObjectFileIsSectionIteratorAtEnd(LLVMBinaryRef BR,
//                                               LLVMSectionIteratorRef SI);
//
// /**
//  * Retrieve a copy of the symbol iterator for this object file.
//  *
//  * If there are no symbols, the result is NULL.
//  *
//  * The returned iterator is merely a shallow copy. Nevertheless, it is
//  * the responsibility of the caller to free it with
//  * \c LLVMDisposeSymbolIterator.
//  *
//  * @see llvm::object::symbols()
//  */
// LLVMSymbolIteratorRef LLVMObjectFileCopySymbolIterator(LLVMBinaryRef BR);
//
// /**
//  * Returns whether the given symbol iterator is at the end.
//  *
//  * @see llvm::object::symbol_end
//  */
// LLVMBool LLVMObjectFileIsSymbolIteratorAtEnd(LLVMBinaryRef BR,
//                                              LLVMSymbolIteratorRef SI);
//
// void LLVMDisposeSectionIterator(LLVMSectionIteratorRef SI);
//
// void LLVMMoveToNextSection(LLVMSectionIteratorRef SI);
// void LLVMMoveToContainingSection(LLVMSectionIteratorRef Sect,
//                                  LLVMSymbolIteratorRef Sym);
//
// // ObjectFile Symbol iterators
// void LLVMDisposeSymbolIterator(LLVMSymbolIteratorRef SI);
// void LLVMMoveToNextSymbol(LLVMSymbolIteratorRef SI);
//
// // SectionRef accessors
// const char *LLVMGetSectionName(LLVMSectionIteratorRef SI);
// uint64_t LLVMGetSectionSize(LLVMSectionIteratorRef SI);
// const char *LLVMGetSectionContents(LLVMSectionIteratorRef SI);
// uint64_t LLVMGetSectionAddress(LLVMSectionIteratorRef SI);
// LLVMBool LLVMGetSectionContainsSymbol(LLVMSectionIteratorRef SI,
//                                  LLVMSymbolIteratorRef Sym);
//
// // Section Relocation iterators
// LLVMRelocationIteratorRef LLVMGetRelocations(LLVMSectionIteratorRef Section);
// void LLVMDisposeRelocationIterator(LLVMRelocationIteratorRef RI);
// LLVMBool LLVMIsRelocationIteratorAtEnd(LLVMSectionIteratorRef Section,
//                                        LLVMRelocationIteratorRef RI);
// void LLVMMoveToNextRelocation(LLVMRelocationIteratorRef RI);
//
//
// // SymbolRef accessors
// const char *LLVMGetSymbolName(LLVMSymbolIteratorRef SI);
// uint64_t LLVMGetSymbolAddress(LLVMSymbolIteratorRef SI);
// uint64_t LLVMGetSymbolSize(LLVMSymbolIteratorRef SI);
//
// // RelocationRef accessors
// uint64_t LLVMGetRelocationOffset(LLVMRelocationIteratorRef RI);
// LLVMSymbolIteratorRef LLVMGetRelocationSymbol(LLVMRelocationIteratorRef RI);
// uint64_t LLVMGetRelocationType(LLVMRelocationIteratorRef RI);
// // NOTE: Caller takes ownership of returned string of the two
// // following functions.
// const char *LLVMGetRelocationTypeName(LLVMRelocationIteratorRef RI);
// const char *LLVMGetRelocationValueString(LLVMRelocationIteratorRef RI);
//
// /** Deprecated: Use LLVMBinaryRef instead. */
// typedef struct LLVMOpaqueObjectFile *LLVMObjectFileRef;
//
// /** Deprecated: Use LLVMCreateBinary instead. */
// LLVMObjectFileRef LLVMCreateObjectFile(LLVMMemoryBufferRef MemBuf);
//
// /** Deprecated: Use LLVMDisposeBinary instead. */
// void LLVMDisposeObjectFile(LLVMObjectFileRef ObjectFile);
//
// /** Deprecated: Use LLVMObjectFileCopySectionIterator instead. */
// LLVMSectionIteratorRef LLVMGetSections(LLVMObjectFileRef ObjectFile);
//
// /** Deprecated: Use LLVMObjectFileIsSectionIteratorAtEnd instead. */
// LLVMBool LLVMIsSectionIteratorAtEnd(LLVMObjectFileRef ObjectFile,
//                                     LLVMSectionIteratorRef SI);
//
// /** Deprecated: Use LLVMObjectFileCopySymbolIterator instead. */
// LLVMSymbolIteratorRef LLVMGetSymbols(LLVMObjectFileRef ObjectFile);
//
// /** Deprecated: Use LLVMObjectFileIsSymbolIteratorAtEnd instead. */
// LLVMBool LLVMIsSymbolIteratorAtEnd(LLVMObjectFileRef ObjectFile,
//                                    LLVMSymbolIteratorRef SI);

// =======================================================
// ExecutionEngine.h
// =======================================================

// void LLVMLinkInMCJIT(void);
// void LLVMLinkInInterpreter(void);
//
// struct LLVMMCJITCompilerOptions {
//   unsigned OptLevel;
//   LLVMCodeModel CodeModel;
//   LLVMBool NoFramePointerElim;
//   LLVMBool EnableFastISel;
//   LLVMMCJITMemoryManagerRef MCJMM;
// };
//
// /*===-- Operations on generic values --------------------------------------===*/
//
// LLVMGenericValueRef LLVMCreateGenericValueOfInt(LLVMTypeRef Ty,
//                                                 unsigned long long N,
//                                                 LLVMBool IsSigned);
//
// LLVMGenericValueRef LLVMCreateGenericValueOfPointer(void *P);
//
// LLVMGenericValueRef LLVMCreateGenericValueOfFloat(LLVMTypeRef Ty, double N);
//
// unsigned LLVMGenericValueIntWidth(LLVMGenericValueRef GenValRef);
//
// unsigned long long LLVMGenericValueToInt(LLVMGenericValueRef GenVal,
//                                          LLVMBool IsSigned);
//
// void *LLVMGenericValueToPointer(LLVMGenericValueRef GenVal);
//
// double LLVMGenericValueToFloat(LLVMTypeRef TyRef, LLVMGenericValueRef GenVal);
//
// void LLVMDisposeGenericValue(LLVMGenericValueRef GenVal);
//
// /*===-- Operations on execution engines -----------------------------------===*/
//
// LLVMBool LLVMCreateExecutionEngineForModule(LLVMExecutionEngineRef *OutEE,
//                                             LLVMModuleRef M,
//                                             char **OutError);
//
// LLVMBool LLVMCreateInterpreterForModule(LLVMExecutionEngineRef *OutInterp,
//                                         LLVMModuleRef M,
//                                         char **OutError);
//
// LLVMBool LLVMCreateJITCompilerForModule(LLVMExecutionEngineRef *OutJIT,
//                                         LLVMModuleRef M,
//                                         unsigned OptLevel,
//                                         char **OutError);
//
// void LLVMInitializeMCJITCompilerOptions(
//   struct LLVMMCJITCompilerOptions *Options, size_t SizeOfOptions);
//
// /**
//  * Create an MCJIT execution engine for a module, with the given options. It is
//  * the responsibility of the caller to ensure that all fields in Options up to
//  * the given SizeOfOptions are initialized. It is correct to pass a smaller
//  * value of SizeOfOptions that omits some fields. The canonical way of using
//  * this is:
//  *
//  * LLVMMCJITCompilerOptions options;
//  * LLVMInitializeMCJITCompilerOptions(&options, sizeof(options));
//  * ... fill in those options you care about
//  * LLVMCreateMCJITCompilerForModule(&jit, mod, &options, sizeof(options),
//  *                                  &error);
//  *
//  * Note that this is also correct, though possibly suboptimal:
//  *
//  * LLVMCreateMCJITCompilerForModule(&jit, mod, 0, 0, &error);
//  */
// LLVMBool LLVMCreateMCJITCompilerForModule(
//   LLVMExecutionEngineRef *OutJIT, LLVMModuleRef M,
//   struct LLVMMCJITCompilerOptions *Options, size_t SizeOfOptions,
//   char **OutError);
//
// void LLVMDisposeExecutionEngine(LLVMExecutionEngineRef EE);
//
// void LLVMRunStaticConstructors(LLVMExecutionEngineRef EE);
//
// void LLVMRunStaticDestructors(LLVMExecutionEngineRef EE);
//
// int LLVMRunFunctionAsMain(LLVMExecutionEngineRef EE, LLVMValueRef F,
//                           unsigned ArgC, const char * const *ArgV,
//                           const char * const *EnvP);
//
// LLVMGenericValueRef LLVMRunFunction(LLVMExecutionEngineRef EE, LLVMValueRef F,
//                                     unsigned NumArgs,
//                                     LLVMGenericValueRef *Args);
//
// void LLVMFreeMachineCodeForFunction(LLVMExecutionEngineRef EE, LLVMValueRef F);
//
// void LLVMAddModule(LLVMExecutionEngineRef EE, LLVMModuleRef M);
//
// LLVMBool LLVMRemoveModule(LLVMExecutionEngineRef EE, LLVMModuleRef M,
//                           LLVMModuleRef *OutMod, char **OutError);
//
// LLVMBool LLVMFindFunction(LLVMExecutionEngineRef EE, const char *Name,
//                           LLVMValueRef *OutFn);
//
// void *LLVMRecompileAndRelinkFunction(LLVMExecutionEngineRef EE,
//                                      LLVMValueRef Fn);
//
// LLVMTargetDataRef LLVMGetExecutionEngineTargetData(LLVMExecutionEngineRef EE);
// LLVMTargetMachineRef
// LLVMGetExecutionEngineTargetMachine(LLVMExecutionEngineRef EE);
//
// void LLVMAddGlobalMapping(LLVMExecutionEngineRef EE, LLVMValueRef Global,
//                           void* Addr);
//
// void *LLVMGetPointerToGlobal(LLVMExecutionEngineRef EE, LLVMValueRef Global);
//
// uint64_t LLVMGetGlobalValueAddress(LLVMExecutionEngineRef EE, const char *Name);
//
// uint64_t LLVMGetFunctionAddress(LLVMExecutionEngineRef EE, const char *Name);
//
// /// Returns true on error, false on success. If true is returned then the error
// /// message is copied to OutStr and cleared in the ExecutionEngine instance.
// LLVMBool LLVMExecutionEngineGetErrMsg(LLVMExecutionEngineRef EE,
//                                       char **OutError);
//
// /*===-- Operations on memory managers -------------------------------------===*/
//
// typedef uint8_t *(*LLVMMemoryManagerAllocateCodeSectionCallback)(
//   void *Opaque, uintptr_t Size, unsigned Alignment, unsigned SectionID,
//   const char *SectionName);
// typedef uint8_t *(*LLVMMemoryManagerAllocateDataSectionCallback)(
//   void *Opaque, uintptr_t Size, unsigned Alignment, unsigned SectionID,
//   const char *SectionName, LLVMBool IsReadOnly);
// typedef LLVMBool (*LLVMMemoryManagerFinalizeMemoryCallback)(
//   void *Opaque, char **ErrMsg);
// typedef void (*LLVMMemoryManagerDestroyCallback)(void *Opaque);
//
// /**
//  * Create a simple custom MCJIT memory manager. This memory manager can
//  * intercept allocations in a module-oblivious way. This will return NULL
//  * if any of the passed functions are NULL.
//  *
//  * @param Opaque An opaque client object to pass back to the callbacks.
//  * @param AllocateCodeSection Allocate a block of memory for executable code.
//  * @param AllocateDataSection Allocate a block of memory for data.
//  * @param FinalizeMemory Set page permissions and flush cache. Return 0 on
//  *   success, 1 on error.
//  */
// LLVMMCJITMemoryManagerRef LLVMCreateSimpleMCJITMemoryManager(
//   void *Opaque,
//   LLVMMemoryManagerAllocateCodeSectionCallback AllocateCodeSection,
//   LLVMMemoryManagerAllocateDataSectionCallback AllocateDataSection,
//   LLVMMemoryManagerFinalizeMemoryCallback FinalizeMemory,
//   LLVMMemoryManagerDestroyCallback Destroy);
//
// void LLVMDisposeMCJITMemoryManager(LLVMMCJITMemoryManagerRef MM);
//
// /*===-- JIT Event Listener functions -------------------------------------===*/
//
// LLVMJITEventListenerRef LLVMCreateGDBRegistrationListener(void);
// LLVMJITEventListenerRef LLVMCreateIntelJITEventListener(void);
// LLVMJITEventListenerRef LLVMCreateOProfileJITEventListener(void);
// LLVMJITEventListenerRef LLVMCreatePerfJITEventListener(void);

// =======================================================
// DebugInfo.h
// =======================================================

// /**
//  * The current debug metadata version number.
//  */
// unsigned LLVMDebugMetadataVersion(void);
//
// /**
//  * The version of debug metadata that's present in the provided \c Module.
//  */
// unsigned LLVMGetModuleDebugMetadataVersion(LLVMModuleRef Module);
//
// /**
//  * Strip debug info in the module if it exists.
//  * To do this, we remove all calls to the debugger intrinsics and any named
//  * metadata for debugging. We also remove debug locations for instructions.
//  * Return true if module is modified.
//  */
// LLVMBool LLVMStripModuleDebugInfo(LLVMModuleRef Module);
//
// /**
//  * Construct a builder for a module, and do not allow for unresolved nodes
//  * attached to the module.
//  */
// LLVMDIBuilderRef LLVMCreateDIBuilderDisallowUnresolved(LLVMModuleRef M);
//
// /**
//  * Construct a builder for a module and collect unresolved nodes attached
//  * to the module in order to resolve cycles during a call to
//  * \c LLVMDIBuilderFinalize.
//  */
// LLVMDIBuilderRef LLVMCreateDIBuilder(LLVMModuleRef M);
//
// /**
//  * Deallocates the \c DIBuilder and everything it owns.
//  * @note You must call \c LLVMDIBuilderFinalize before this
//  */
// void LLVMDisposeDIBuilder(LLVMDIBuilderRef Builder);
//
// /**
//  * Construct any deferred debug info descriptors.
//  */
// void LLVMDIBuilderFinalize(LLVMDIBuilderRef Builder);
//
// /**
//  * Finalize a specific subprogram.
//  * No new variables may be added to this subprogram afterwards.
//  */
// void LLVMDIBuilderFinalizeSubprogram(LLVMDIBuilderRef Builder,
//                                      LLVMMetadataRef Subprogram);
//
// /**
//  * A CompileUnit provides an anchor for all debugging
//  * information generated during this instance of compilation.
//  * \param Lang          Source programming language, eg.
//  *                      \c LLVMDWARFSourceLanguageC99
//  * \param FileRef       File info.
//  * \param Producer      Identify the producer of debugging information
//  *                      and code.  Usually this is a compiler
//  *                      version string.
//  * \param ProducerLen   The length of the C string passed to \c Producer.
//  * \param isOptimized   A boolean flag which indicates whether optimization
//  *                      is enabled or not.
//  * \param Flags         This string lists command line options. This
//  *                      string is directly embedded in debug info
//  *                      output which may be used by a tool
//  *                      analyzing generated debugging information.
//  * \param FlagsLen      The length of the C string passed to \c Flags.
//  * \param RuntimeVer    This indicates runtime version for languages like
//  *                      Objective-C.
//  * \param SplitName     The name of the file that we'll split debug info
//  *                      out into.
//  * \param SplitNameLen  The length of the C string passed to \c SplitName.
//  * \param Kind          The kind of debug information to generate.
//  * \param DWOId         The DWOId if this is a split skeleton compile unit.
//  * \param SplitDebugInlining    Whether to emit inline debug info.
//  * \param DebugInfoForProfiling Whether to emit extra debug info for
//  *                              profile collection.
//  * \param SysRoot         The Clang system root (value of -isysroot).
//  * \param SysRootLen      The length of the C string passed to \c SysRoot.
//  * \param SDK           The SDK. On Darwin, the last component of the sysroot.
//  * \param SDKLen        The length of the C string passed to \c SDK.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateCompileUnit(
//     LLVMDIBuilderRef Builder, LLVMDWARFSourceLanguage Lang,
//     LLVMMetadataRef FileRef, const char *Producer, size_t ProducerLen,
//     LLVMBool isOptimized, const char *Flags, size_t FlagsLen,
//     unsigned RuntimeVer, const char *SplitName, size_t SplitNameLen,
//     LLVMDWARFEmissionKind Kind, unsigned DWOId, LLVMBool SplitDebugInlining,
//     LLVMBool DebugInfoForProfiling, const char *SysRoot, size_t SysRootLen,
//     const char *SDK, size_t SDKLen);
//
// /**
//  * Create a file descriptor to hold debugging information for a file.
//  * \param Builder      The \c DIBuilder.
//  * \param Filename     File name.
//  * \param FilenameLen  The length of the C string passed to \c Filename.
//  * \param Directory    Directory.
//  * \param DirectoryLen The length of the C string passed to \c Directory.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateFile(LLVMDIBuilderRef Builder, const char *Filename,
//                         size_t FilenameLen, const char *Directory,
//                         size_t DirectoryLen);
//
// /**
//  * Creates a new descriptor for a module with the specified parent scope.
//  * \param Builder         The \c DIBuilder.
//  * \param ParentScope     The parent scope containing this module declaration.
//  * \param Name            Module name.
//  * \param NameLen         The length of the C string passed to \c Name.
//  * \param ConfigMacros    A space-separated shell-quoted list of -D macro
//                           definitions as they would appear on a command line.
//  * \param ConfigMacrosLen The length of the C string passed to \c ConfigMacros.
//  * \param IncludePath     The path to the module map file.
//  * \param IncludePathLen  The length of the C string passed to \c IncludePath.
//  * \param APINotesFile    The path to an API notes file for the module.
//  * \param APINotesFileLen The length of the C string passed to \c APINotestFile.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateModule(LLVMDIBuilderRef Builder, LLVMMetadataRef ParentScope,
//                           const char *Name, size_t NameLen,
//                           const char *ConfigMacros, size_t ConfigMacrosLen,
//                           const char *IncludePath, size_t IncludePathLen,
//                           const char *APINotesFile, size_t APINotesFileLen);
//
// /**
//  * Creates a new descriptor for a namespace with the specified parent scope.
//  * \param Builder          The \c DIBuilder.
//  * \param ParentScope      The parent scope containing this module declaration.
//  * \param Name             NameSpace name.
//  * \param NameLen          The length of the C string passed to \c Name.
//  * \param ExportSymbols    Whether or not the namespace exports symbols, e.g.
//  *                         this is true of C++ inline namespaces.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateNameSpace(LLVMDIBuilderRef Builder,
//                              LLVMMetadataRef ParentScope,
//                              const char *Name, size_t NameLen,
//                              LLVMBool ExportSymbols);
//
// /**
//  * Create a new descriptor for the specified subprogram.
//  * \param Builder         The \c DIBuilder.
//  * \param Scope           Function scope.
//  * \param Name            Function name.
//  * \param NameLen         Length of enumeration name.
//  * \param LinkageName     Mangled function name.
//  * \param LinkageNameLen  Length of linkage name.
//  * \param File            File where this variable is defined.
//  * \param LineNo          Line number.
//  * \param Ty              Function type.
//  * \param IsLocalToUnit   True if this function is not externally visible.
//  * \param IsDefinition    True if this is a function definition.
//  * \param ScopeLine       Set to the beginning of the scope this starts
//  * \param Flags           E.g.: \c LLVMDIFlagLValueReference. These flags are
//  *                        used to emit dwarf attributes.
//  * \param IsOptimized     True if optimization is ON.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateFunction(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, const char *LinkageName, size_t LinkageNameLen,
//     LLVMMetadataRef File, unsigned LineNo, LLVMMetadataRef Ty,
//     LLVMBool IsLocalToUnit, LLVMBool IsDefinition,
//     unsigned ScopeLine, LLVMDIFlags Flags, LLVMBool IsOptimized);
//
// /**
//  * Create a descriptor for a lexical block with the specified parent context.
//  * \param Builder      The \c DIBuilder.
//  * \param Scope        Parent lexical block.
//  * \param File         Source file.
//  * \param Line         The line in the source file.
//  * \param Column       The column in the source file.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateLexicalBlock(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope,
//     LLVMMetadataRef File, unsigned Line, unsigned Column);
//
// /**
//  * Create a descriptor for a lexical block with a new file attached.
//  * \param Builder        The \c DIBuilder.
//  * \param Scope          Lexical block.
//  * \param File           Source file.
//  * \param Discriminator  DWARF path discriminator value.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateLexicalBlockFile(LLVMDIBuilderRef Builder,
//                                     LLVMMetadataRef Scope,
//                                     LLVMMetadataRef File,
//                                     unsigned Discriminator);
//
// /**
//  * Create a descriptor for an imported namespace. Suitable for e.g. C++
//  * using declarations.
//  * \param Builder    The \c DIBuilder.
//  * \param Scope      The scope this module is imported into
//  * \param File       File where the declaration is located.
//  * \param Line       Line number of the declaration.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateImportedModuleFromNamespace(LLVMDIBuilderRef Builder,
//                                                LLVMMetadataRef Scope,
//                                                LLVMMetadataRef NS,
//                                                LLVMMetadataRef File,
//                                                unsigned Line);
//
// /**
//  * Create a descriptor for an imported module that aliases another
//  * imported entity descriptor.
//  * \param Builder        The \c DIBuilder.
//  * \param Scope          The scope this module is imported into
//  * \param ImportedEntity Previous imported entity to alias.
//  * \param File           File where the declaration is located.
//  * \param Line           Line number of the declaration.
//  * \param Elements       Renamed elements.
//  * \param NumElements    Number of renamed elements.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateImportedModuleFromAlias(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope,
//     LLVMMetadataRef ImportedEntity, LLVMMetadataRef File, unsigned Line,
//     LLVMMetadataRef *Elements, unsigned NumElements);
//
// /**
//  * Create a descriptor for an imported module.
//  * \param Builder        The \c DIBuilder.
//  * \param Scope          The scope this module is imported into
//  * \param M              The module being imported here
//  * \param File           File where the declaration is located.
//  * \param Line           Line number of the declaration.
//  * \param Elements       Renamed elements.
//  * \param NumElements    Number of renamed elements.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateImportedModuleFromModule(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, LLVMMetadataRef M,
//     LLVMMetadataRef File, unsigned Line, LLVMMetadataRef *Elements,
//     unsigned NumElements);
//
// /**
//  * Create a descriptor for an imported function, type, or variable.  Suitable
//  * for e.g. FORTRAN-style USE declarations.
//  * \param Builder        The DIBuilder.
//  * \param Scope          The scope this module is imported into.
//  * \param Decl           The declaration (or definition) of a function, type,
//                          or variable.
//  * \param File           File where the declaration is located.
//  * \param Line           Line number of the declaration.
//  * \param Name           A name that uniquely identifies this imported
//  declaration.
//  * \param NameLen        The length of the C string passed to \c Name.
//  * \param Elements       Renamed elements.
//  * \param NumElements    Number of renamed elements.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateImportedDeclaration(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, LLVMMetadataRef Decl,
//     LLVMMetadataRef File, unsigned Line, const char *Name, size_t NameLen,
//     LLVMMetadataRef *Elements, unsigned NumElements);
//
// /**
//  * Creates a new DebugLocation that describes a source location.
//  * \param Line The line in the source file.
//  * \param Column The column in the source file.
//  * \param Scope The scope in which the location resides.
//  * \param InlinedAt The scope where this location was inlined, if at all.
//  *                  (optional).
//  * \note If the item to which this location is attached cannot be
//  *       attributed to a source line, pass 0 for the line and column.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateDebugLocation(LLVMContextRef Ctx, unsigned Line,
//                                  unsigned Column, LLVMMetadataRef Scope,
//                                  LLVMMetadataRef InlinedAt);
//
// /**
//  * Get the line number of this debug location.
//  * \param Location     The debug location.
//  *
//  * @see DILocation::getLine()
//  */
// unsigned LLVMDILocationGetLine(LLVMMetadataRef Location);
//
// /**
//  * Get the column number of this debug location.
//  * \param Location     The debug location.
//  *
//  * @see DILocation::getColumn()
//  */
// unsigned LLVMDILocationGetColumn(LLVMMetadataRef Location);
//
// /**
//  * Get the local scope associated with this debug location.
//  * \param Location     The debug location.
//  *
//  * @see DILocation::getScope()
//  */
// LLVMMetadataRef LLVMDILocationGetScope(LLVMMetadataRef Location);
//
// /**
//  * Get the "inline at" location associated with this debug location.
//  * \param Location     The debug location.
//  *
//  * @see DILocation::getInlinedAt()
//  */
// LLVMMetadataRef LLVMDILocationGetInlinedAt(LLVMMetadataRef Location);
//
// /**
//  * Get the metadata of the file associated with a given scope.
//  * \param Scope     The scope object.
//  *
//  * @see DIScope::getFile()
//  */
// LLVMMetadataRef LLVMDIScopeGetFile(LLVMMetadataRef Scope);
//
// /**
//  * Get the directory of a given file.
//  * \param File     The file object.
//  * \param Len      The length of the returned string.
//  *
//  * @see DIFile::getDirectory()
//  */
// const char *LLVMDIFileGetDirectory(LLVMMetadataRef File, unsigned *Len);
//
// /**
//  * Get the name of a given file.
//  * \param File     The file object.
//  * \param Len      The length of the returned string.
//  *
//  * @see DIFile::getFilename()
//  */
// const char *LLVMDIFileGetFilename(LLVMMetadataRef File, unsigned *Len);
//
// /**
//  * Get the source of a given file.
//  * \param File     The file object.
//  * \param Len      The length of the returned string.
//  *
//  * @see DIFile::getSource()
//  */
// const char *LLVMDIFileGetSource(LLVMMetadataRef File, unsigned *Len);
//
// /**
//  * Create a type array.
//  * \param Builder        The DIBuilder.
//  * \param Data           The type elements.
//  * \param NumElements    Number of type elements.
//  */
// LLVMMetadataRef LLVMDIBuilderGetOrCreateTypeArray(LLVMDIBuilderRef Builder,
//                                                   LLVMMetadataRef *Data,
//                                                   size_t NumElements);
//
// /**
//  * Create subroutine type.
//  * \param Builder        The DIBuilder.
//  * \param File            The file in which the subroutine resides.
//  * \param ParameterTypes  An array of subroutine parameter types. This
//  *                        includes return type at 0th index.
//  * \param NumParameterTypes The number of parameter types in \c ParameterTypes
//  * \param Flags           E.g.: \c LLVMDIFlagLValueReference.
//  *                        These flags are used to emit dwarf attributes.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateSubroutineType(LLVMDIBuilderRef Builder,
//                                   LLVMMetadataRef File,
//                                   LLVMMetadataRef *ParameterTypes,
//                                   unsigned NumParameterTypes,
//                                   LLVMDIFlags Flags);
//
// /**
//  * Create debugging information entry for a macro.
//  * @param Builder         The DIBuilder.
//  * @param ParentMacroFile Macro parent (could be NULL).
//  * @param Line            Source line number where the macro is defined.
//  * @param RecordType      DW_MACINFO_define or DW_MACINFO_undef.
//  * @param Name            Macro name.
//  * @param NameLen         Macro name length.
//  * @param Value           Macro value.
//  * @param ValueLen        Macro value length.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateMacro(LLVMDIBuilderRef Builder,
//                                          LLVMMetadataRef ParentMacroFile,
//                                          unsigned Line,
//                                          LLVMDWARFMacinfoRecordType RecordType,
//                                          const char *Name, size_t NameLen,
//                                          const char *Value, size_t ValueLen);
//
// /**
//  * Create debugging information temporary entry for a macro file.
//  * List of macro node direct children will be calculated by DIBuilder,
//  * using the \p ParentMacroFile relationship.
//  * @param Builder         The DIBuilder.
//  * @param ParentMacroFile Macro parent (could be NULL).
//  * @param Line            Source line number where the macro file is included.
//  * @param File            File descriptor containing the name of the macro file.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateTempMacroFile(LLVMDIBuilderRef Builder,
//                                  LLVMMetadataRef ParentMacroFile, unsigned Line,
//                                  LLVMMetadataRef File);
//
// /**
//  * Create debugging information entry for an enumerator.
//  * @param Builder        The DIBuilder.
//  * @param Name           Enumerator name.
//  * @param NameLen        Length of enumerator name.
//  * @param Value          Enumerator value.
//  * @param IsUnsigned     True if the value is unsigned.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateEnumerator(LLVMDIBuilderRef Builder,
//                                               const char *Name, size_t NameLen,
//                                               int64_t Value,
//                                               LLVMBool IsUnsigned);
//
// /**
//  * Create debugging information entry for an enumeration.
//  * \param Builder        The DIBuilder.
//  * \param Scope          Scope in which this enumeration is defined.
//  * \param Name           Enumeration name.
//  * \param NameLen        Length of enumeration name.
//  * \param File           File where this member is defined.
//  * \param LineNumber     Line number.
//  * \param SizeInBits     Member size.
//  * \param AlignInBits    Member alignment.
//  * \param Elements       Enumeration elements.
//  * \param NumElements    Number of enumeration elements.
//  * \param ClassTy        Underlying type of a C++11/ObjC fixed enum.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateEnumerationType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNumber,
//     uint64_t SizeInBits, uint32_t AlignInBits, LLVMMetadataRef *Elements,
//     unsigned NumElements, LLVMMetadataRef ClassTy);
//
// /**
//  * Create debugging information entry for a union.
//  * \param Builder      The DIBuilder.
//  * \param Scope        Scope in which this union is defined.
//  * \param Name         Union name.
//  * \param NameLen      Length of union name.
//  * \param File         File where this member is defined.
//  * \param LineNumber   Line number.
//  * \param SizeInBits   Member size.
//  * \param AlignInBits  Member alignment.
//  * \param Flags        Flags to encode member attribute, e.g. private
//  * \param Elements     Union elements.
//  * \param NumElements  Number of union elements.
//  * \param RunTimeLang  Optional parameter, Objective-C runtime version.
//  * \param UniqueId     A unique identifier for the union.
//  * \param UniqueIdLen  Length of unique identifier.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateUnionType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNumber,
//     uint64_t SizeInBits, uint32_t AlignInBits, LLVMDIFlags Flags,
//     LLVMMetadataRef *Elements, unsigned NumElements, unsigned RunTimeLang,
//     const char *UniqueId, size_t UniqueIdLen);
//
//
// /**
//  * Create debugging information entry for an array.
//  * \param Builder      The DIBuilder.
//  * \param Size         Array size.
//  * \param AlignInBits  Alignment.
//  * \param Ty           Element type.
//  * \param Subscripts   Subscripts.
//  * \param NumSubscripts Number of subscripts.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateArrayType(LLVMDIBuilderRef Builder, uint64_t Size,
//                              uint32_t AlignInBits, LLVMMetadataRef Ty,
//                              LLVMMetadataRef *Subscripts,
//                              unsigned NumSubscripts);
//
// /**
//  * Create debugging information entry for a vector type.
//  * \param Builder      The DIBuilder.
//  * \param Size         Vector size.
//  * \param AlignInBits  Alignment.
//  * \param Ty           Element type.
//  * \param Subscripts   Subscripts.
//  * \param NumSubscripts Number of subscripts.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateVectorType(LLVMDIBuilderRef Builder, uint64_t Size,
//                               uint32_t AlignInBits, LLVMMetadataRef Ty,
//                               LLVMMetadataRef *Subscripts,
//                               unsigned NumSubscripts);
//
// /**
//  * Create a DWARF unspecified type.
//  * \param Builder   The DIBuilder.
//  * \param Name      The unspecified type's name.
//  * \param NameLen   Length of type name.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateUnspecifiedType(LLVMDIBuilderRef Builder, const char *Name,
//                                    size_t NameLen);
//
// /**
//  * Create debugging information entry for a basic
//  * type.
//  * \param Builder     The DIBuilder.
//  * \param Name        Type name.
//  * \param NameLen     Length of type name.
//  * \param SizeInBits  Size of the type.
//  * \param Encoding    DWARF encoding code, e.g. \c LLVMDWARFTypeEncoding_float.
//  * \param Flags       Flags to encode optional attribute like endianity
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateBasicType(LLVMDIBuilderRef Builder, const char *Name,
//                              size_t NameLen, uint64_t SizeInBits,
//                              LLVMDWARFTypeEncoding Encoding,
//                              LLVMDIFlags Flags);
//
// /**
//  * Create debugging information entry for a pointer.
//  * \param Builder     The DIBuilder.
//  * \param PointeeTy         Type pointed by this pointer.
//  * \param SizeInBits        Size.
//  * \param AlignInBits       Alignment. (optional, pass 0 to ignore)
//  * \param AddressSpace      DWARF address space. (optional, pass 0 to ignore)
//  * \param Name              Pointer type name. (optional)
//  * \param NameLen           Length of pointer type name. (optional)
//  */
// LLVMMetadataRef LLVMDIBuilderCreatePointerType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef PointeeTy,
//     uint64_t SizeInBits, uint32_t AlignInBits, unsigned AddressSpace,
//     const char *Name, size_t NameLen);
//
// /**
//  * Create debugging information entry for a struct.
//  * \param Builder     The DIBuilder.
//  * \param Scope        Scope in which this struct is defined.
//  * \param Name         Struct name.
//  * \param NameLen      Struct name length.
//  * \param File         File where this member is defined.
//  * \param LineNumber   Line number.
//  * \param SizeInBits   Member size.
//  * \param AlignInBits  Member alignment.
//  * \param Flags        Flags to encode member attribute, e.g. private
//  * \param Elements     Struct elements.
//  * \param NumElements  Number of struct elements.
//  * \param RunTimeLang  Optional parameter, Objective-C runtime version.
//  * \param VTableHolder The object containing the vtable for the struct.
//  * \param UniqueId     A unique identifier for the struct.
//  * \param UniqueIdLen  Length of the unique identifier for the struct.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateStructType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNumber,
//     uint64_t SizeInBits, uint32_t AlignInBits, LLVMDIFlags Flags,
//     LLVMMetadataRef DerivedFrom, LLVMMetadataRef *Elements,
//     unsigned NumElements, unsigned RunTimeLang, LLVMMetadataRef VTableHolder,
//     const char *UniqueId, size_t UniqueIdLen);
//
// /**
//  * Create debugging information entry for a member.
//  * \param Builder      The DIBuilder.
//  * \param Scope        Member scope.
//  * \param Name         Member name.
//  * \param NameLen      Length of member name.
//  * \param File         File where this member is defined.
//  * \param LineNo       Line number.
//  * \param SizeInBits   Member size.
//  * \param AlignInBits  Member alignment.
//  * \param OffsetInBits Member offset.
//  * \param Flags        Flags to encode member attribute, e.g. private
//  * \param Ty           Parent type.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateMemberType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNo,
//     uint64_t SizeInBits, uint32_t AlignInBits, uint64_t OffsetInBits,
//     LLVMDIFlags Flags, LLVMMetadataRef Ty);
//
// /**
//  * Create debugging information entry for a
//  * C++ static data member.
//  * \param Builder      The DIBuilder.
//  * \param Scope        Member scope.
//  * \param Name         Member name.
//  * \param NameLen      Length of member name.
//  * \param File         File where this member is declared.
//  * \param LineNumber   Line number.
//  * \param Type         Type of the static member.
//  * \param Flags        Flags to encode member attribute, e.g. private.
//  * \param ConstantVal  Const initializer of the member.
//  * \param AlignInBits  Member alignment.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateStaticMemberType(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNumber,
//     LLVMMetadataRef Type, LLVMDIFlags Flags, LLVMValueRef ConstantVal,
//     uint32_t AlignInBits);
//
// /**
//  * Create debugging information entry for a pointer to member.
//  * \param Builder      The DIBuilder.
//  * \param PointeeType  Type pointed to by this pointer.
//  * \param ClassType    Type for which this pointer points to members of.
//  * \param SizeInBits   Size.
//  * \param AlignInBits  Alignment.
//  * \param Flags        Flags.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateMemberPointerType(LLVMDIBuilderRef Builder,
//                                      LLVMMetadataRef PointeeType,
//                                      LLVMMetadataRef ClassType,
//                                      uint64_t SizeInBits,
//                                      uint32_t AlignInBits,
//                                      LLVMDIFlags Flags);
// /**
//  * Create debugging information entry for Objective-C instance variable.
//  * \param Builder      The DIBuilder.
//  * \param Name         Member name.
//  * \param NameLen      The length of the C string passed to \c Name.
//  * \param File         File where this member is defined.
//  * \param LineNo       Line number.
//  * \param SizeInBits   Member size.
//  * \param AlignInBits  Member alignment.
//  * \param OffsetInBits Member offset.
//  * \param Flags        Flags to encode member attribute, e.g. private
//  * \param Ty           Parent type.
//  * \param PropertyNode Property associated with this ivar.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateObjCIVar(LLVMDIBuilderRef Builder,
//                             const char *Name, size_t NameLen,
//                             LLVMMetadataRef File, unsigned LineNo,
//                             uint64_t SizeInBits, uint32_t AlignInBits,
//                             uint64_t OffsetInBits, LLVMDIFlags Flags,
//                             LLVMMetadataRef Ty, LLVMMetadataRef PropertyNode);
//
// /**
//  * Create debugging information entry for Objective-C property.
//  * \param Builder            The DIBuilder.
//  * \param Name               Property name.
//  * \param NameLen            The length of the C string passed to \c Name.
//  * \param File               File where this property is defined.
//  * \param LineNo             Line number.
//  * \param GetterName         Name of the Objective C property getter selector.
//  * \param GetterNameLen      The length of the C string passed to \c GetterName.
//  * \param SetterName         Name of the Objective C property setter selector.
//  * \param SetterNameLen      The length of the C string passed to \c SetterName.
//  * \param PropertyAttributes Objective C property attributes.
//  * \param Ty                 Type.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateObjCProperty(LLVMDIBuilderRef Builder,
//                                 const char *Name, size_t NameLen,
//                                 LLVMMetadataRef File, unsigned LineNo,
//                                 const char *GetterName, size_t GetterNameLen,
//                                 const char *SetterName, size_t SetterNameLen,
//                                 unsigned PropertyAttributes,
//                                 LLVMMetadataRef Ty);
//
// /**
//  * Create a uniqued DIType* clone with FlagObjectPointer and FlagArtificial set.
//  * \param Builder   The DIBuilder.
//  * \param Type      The underlying type to which this pointer points.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateObjectPointerType(LLVMDIBuilderRef Builder,
//                                      LLVMMetadataRef Type);
//
// /**
//  * Create debugging information entry for a qualified
//  * type, e.g. 'const int'.
//  * \param Builder     The DIBuilder.
//  * \param Tag         Tag identifying type,
//  *                    e.g. LLVMDWARFTypeQualifier_volatile_type
//  * \param Type        Base Type.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateQualifiedType(LLVMDIBuilderRef Builder, unsigned Tag,
//                                  LLVMMetadataRef Type);
//
// /**
//  * Create debugging information entry for a c++
//  * style reference or rvalue reference type.
//  * \param Builder   The DIBuilder.
//  * \param Tag       Tag identifying type,
//  * \param Type      Base Type.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateReferenceType(LLVMDIBuilderRef Builder, unsigned Tag,
//                                  LLVMMetadataRef Type);
//
// /**
//  * Create C++11 nullptr type.
//  * \param Builder   The DIBuilder.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateNullPtrType(LLVMDIBuilderRef Builder);
//
// /**
//  * Create debugging information entry for a typedef.
//  * \param Builder    The DIBuilder.
//  * \param Type       Original type.
//  * \param Name       Typedef name.
//  * \param File       File where this type is defined.
//  * \param LineNo     Line number.
//  * \param Scope      The surrounding context for the typedef.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateTypedef(LLVMDIBuilderRef Builder, LLVMMetadataRef Type,
//                            const char *Name, size_t NameLen,
//                            LLVMMetadataRef File, unsigned LineNo,
//                            LLVMMetadataRef Scope, uint32_t AlignInBits);
//
// /**
//  * Create debugging information entry to establish inheritance relationship
//  * between two types.
//  * \param Builder       The DIBuilder.
//  * \param Ty            Original type.
//  * \param BaseTy        Base type. Ty is inherits from base.
//  * \param BaseOffset    Base offset.
//  * \param VBPtrOffset  Virtual base pointer offset.
//  * \param Flags         Flags to describe inheritance attribute, e.g. private
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateInheritance(LLVMDIBuilderRef Builder,
//                                LLVMMetadataRef Ty, LLVMMetadataRef BaseTy,
//                                uint64_t BaseOffset, uint32_t VBPtrOffset,
//                                LLVMDIFlags Flags);
//
// /**
//  * Create a permanent forward-declared type.
//  * \param Builder             The DIBuilder.
//  * \param Tag                 A unique tag for this type.
//  * \param Name                Type name.
//  * \param NameLen             Length of type name.
//  * \param Scope               Type scope.
//  * \param File                File where this type is defined.
//  * \param Line                Line number where this type is defined.
//  * \param RuntimeLang         Indicates runtime version for languages like
//  *                            Objective-C.
//  * \param SizeInBits          Member size.
//  * \param AlignInBits         Member alignment.
//  * \param UniqueIdentifier    A unique identifier for the type.
//  * \param UniqueIdentifierLen Length of the unique identifier.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateForwardDecl(
//     LLVMDIBuilderRef Builder, unsigned Tag, const char *Name,
//     size_t NameLen, LLVMMetadataRef Scope, LLVMMetadataRef File, unsigned Line,
//     unsigned RuntimeLang, uint64_t SizeInBits, uint32_t AlignInBits,
//     const char *UniqueIdentifier, size_t UniqueIdentifierLen);
//
// /**
//  * Create a temporary forward-declared type.
//  * \param Builder             The DIBuilder.
//  * \param Tag                 A unique tag for this type.
//  * \param Name                Type name.
//  * \param NameLen             Length of type name.
//  * \param Scope               Type scope.
//  * \param File                File where this type is defined.
//  * \param Line                Line number where this type is defined.
//  * \param RuntimeLang         Indicates runtime version for languages like
//  *                            Objective-C.
//  * \param SizeInBits          Member size.
//  * \param AlignInBits         Member alignment.
//  * \param Flags               Flags.
//  * \param UniqueIdentifier    A unique identifier for the type.
//  * \param UniqueIdentifierLen Length of the unique identifier.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateReplaceableCompositeType(
//     LLVMDIBuilderRef Builder, unsigned Tag, const char *Name,
//     size_t NameLen, LLVMMetadataRef Scope, LLVMMetadataRef File, unsigned Line,
//     unsigned RuntimeLang, uint64_t SizeInBits, uint32_t AlignInBits,
//     LLVMDIFlags Flags, const char *UniqueIdentifier,
//     size_t UniqueIdentifierLen);
//
// /**
//  * Create debugging information entry for a bit field member.
//  * \param Builder             The DIBuilder.
//  * \param Scope               Member scope.
//  * \param Name                Member name.
//  * \param NameLen             Length of member name.
//  * \param File                File where this member is defined.
//  * \param LineNumber          Line number.
//  * \param SizeInBits          Member size.
//  * \param OffsetInBits        Member offset.
//  * \param StorageOffsetInBits Member storage offset.
//  * \param Flags               Flags to encode member attribute.
//  * \param Type                Parent type.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateBitFieldMemberType(LLVMDIBuilderRef Builder,
//                                       LLVMMetadataRef Scope,
//                                       const char *Name, size_t NameLen,
//                                       LLVMMetadataRef File, unsigned LineNumber,
//                                       uint64_t SizeInBits,
//                                       uint64_t OffsetInBits,
//                                       uint64_t StorageOffsetInBits,
//                                       LLVMDIFlags Flags, LLVMMetadataRef Type);
//
// /**
//  * Create debugging information entry for a class.
//  * \param Scope               Scope in which this class is defined.
//  * \param Name                Class name.
//  * \param NameLen             The length of the C string passed to \c Name.
//  * \param File                File where this member is defined.
//  * \param LineNumber          Line number.
//  * \param SizeInBits          Member size.
//  * \param AlignInBits         Member alignment.
//  * \param OffsetInBits        Member offset.
//  * \param Flags               Flags to encode member attribute, e.g. private.
//  * \param DerivedFrom         Debug info of the base class of this type.
//  * \param Elements            Class members.
//  * \param NumElements         Number of class elements.
//  * \param VTableHolder        Debug info of the base class that contains vtable
//  *                            for this type. This is used in
//  *                            DW_AT_containing_type. See DWARF documentation
//  *                            for more info.
//  * \param TemplateParamsNode  Template type parameters.
//  * \param UniqueIdentifier    A unique identifier for the type.
//  * \param UniqueIdentifierLen Length of the unique identifier.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateClassType(LLVMDIBuilderRef Builder,
//     LLVMMetadataRef Scope, const char *Name, size_t NameLen,
//     LLVMMetadataRef File, unsigned LineNumber, uint64_t SizeInBits,
//     uint32_t AlignInBits, uint64_t OffsetInBits, LLVMDIFlags Flags,
//     LLVMMetadataRef DerivedFrom,
//     LLVMMetadataRef *Elements, unsigned NumElements,
//     LLVMMetadataRef VTableHolder, LLVMMetadataRef TemplateParamsNode,
//     const char *UniqueIdentifier, size_t UniqueIdentifierLen);
//
// /**
//  * Create a uniqued DIType* clone with FlagArtificial set.
//  * \param Builder     The DIBuilder.
//  * \param Type        The underlying type.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateArtificialType(LLVMDIBuilderRef Builder,
//                                   LLVMMetadataRef Type);
//
// /**
//  * Get the name of this DIType.
//  * \param DType     The DIType.
//  * \param Length    The length of the returned string.
//  *
//  * @see DIType::getName()
//  */
// const char *LLVMDITypeGetName(LLVMMetadataRef DType, size_t *Length);
//
// /**
//  * Get the size of this DIType in bits.
//  * \param DType     The DIType.
//  *
//  * @see DIType::getSizeInBits()
//  */
// uint64_t LLVMDITypeGetSizeInBits(LLVMMetadataRef DType);
//
// /**
//  * Get the offset of this DIType in bits.
//  * \param DType     The DIType.
//  *
//  * @see DIType::getOffsetInBits()
//  */
// uint64_t LLVMDITypeGetOffsetInBits(LLVMMetadataRef DType);
//
// /**
//  * Get the alignment of this DIType in bits.
//  * \param DType     The DIType.
//  *
//  * @see DIType::getAlignInBits()
//  */
// uint32_t LLVMDITypeGetAlignInBits(LLVMMetadataRef DType);
//
// /**
//  * Get the source line where this DIType is declared.
//  * \param DType     The DIType.
//  *
//  * @see DIType::getLine()
//  */
// unsigned LLVMDITypeGetLine(LLVMMetadataRef DType);
//
// /**
//  * Get the flags associated with this DIType.
//  * \param DType     The DIType.
//  *
//  * @see DIType::getFlags()
//  */
// LLVMDIFlags LLVMDITypeGetFlags(LLVMMetadataRef DType);
//
// /**
//  * Create a descriptor for a value range.
//  * \param Builder    The DIBuilder.
//  * \param LowerBound Lower bound of the subrange, e.g. 0 for C, 1 for Fortran.
//  * \param Count      Count of elements in the subrange.
//  */
// LLVMMetadataRef LLVMDIBuilderGetOrCreateSubrange(LLVMDIBuilderRef Builder,
//                                                  int64_t LowerBound,
//                                                  int64_t Count);
//
// /**
//  * Create an array of DI Nodes.
//  * \param Builder        The DIBuilder.
//  * \param Data           The DI Node elements.
//  * \param NumElements    Number of DI Node elements.
//  */
// LLVMMetadataRef LLVMDIBuilderGetOrCreateArray(LLVMDIBuilderRef Builder,
//                                               LLVMMetadataRef *Data,
//                                               size_t NumElements);
//
// /**
//  * Create a new descriptor for the specified variable which has a complex
//  * address expression for its address.
//  * \param Builder     The DIBuilder.
//  * \param Addr        An array of complex address operations.
//  * \param Length      Length of the address operation array.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateExpression(LLVMDIBuilderRef Builder,
//                                               uint64_t *Addr, size_t Length);
//
// /**
//  * Create a new descriptor for the specified variable that does not have an
//  * address, but does have a constant value.
//  * \param Builder     The DIBuilder.
//  * \param Value       The constant value.
//  */
// LLVMMetadataRef
// LLVMDIBuilderCreateConstantValueExpression(LLVMDIBuilderRef Builder,
//                                            uint64_t Value);
//
// /**
//  * Create a new descriptor for the specified variable.
//  * \param Scope       Variable scope.
//  * \param Name        Name of the variable.
//  * \param NameLen     The length of the C string passed to \c Name.
//  * \param Linkage     Mangled  name of the variable.
//  * \param LinkLen     The length of the C string passed to \c Linkage.
//  * \param File        File where this variable is defined.
//  * \param LineNo      Line number.
//  * \param Ty          Variable Type.
//  * \param LocalToUnit Boolean flag indicate whether this variable is
//  *                    externally visible or not.
//  * \param Expr        The location of the global relative to the attached
//  *                    GlobalVariable.
//  * \param Decl        Reference to the corresponding declaration.
//  *                    variables.
//  * \param AlignInBits Variable alignment(or 0 if no alignment attr was
//  *                    specified)
//  */
// LLVMMetadataRef LLVMDIBuilderCreateGlobalVariableExpression(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, const char *Linkage, size_t LinkLen, LLVMMetadataRef File,
//     unsigned LineNo, LLVMMetadataRef Ty, LLVMBool LocalToUnit,
//     LLVMMetadataRef Expr, LLVMMetadataRef Decl, uint32_t AlignInBits);
//
//
// /**
//  * Get the dwarf::Tag of a DINode
//  */
// uint16_t LLVMGetDINodeTag(LLVMMetadataRef MD);
//
// /**
//  * Retrieves the \c DIVariable associated with this global variable expression.
//  * \param GVE    The global variable expression.
//  *
//  * @see llvm::DIGlobalVariableExpression::getVariable()
//  */
// LLVMMetadataRef LLVMDIGlobalVariableExpressionGetVariable(LLVMMetadataRef GVE);
//
// /**
//  * Retrieves the \c DIExpression associated with this global variable expression.
//  * \param GVE    The global variable expression.
//  *
//  * @see llvm::DIGlobalVariableExpression::getExpression()
//  */
// LLVMMetadataRef LLVMDIGlobalVariableExpressionGetExpression(
//     LLVMMetadataRef GVE);
//
// /**
//  * Get the metadata of the file associated with a given variable.
//  * \param Var     The variable object.
//  *
//  * @see DIVariable::getFile()
//  */
// LLVMMetadataRef LLVMDIVariableGetFile(LLVMMetadataRef Var);
//
// /**
//  * Get the metadata of the scope associated with a given variable.
//  * \param Var     The variable object.
//  *
//  * @see DIVariable::getScope()
//  */
// LLVMMetadataRef LLVMDIVariableGetScope(LLVMMetadataRef Var);
//
// /**
//  * Get the source line where this \c DIVariable is declared.
//  * \param Var     The DIVariable.
//  *
//  * @see DIVariable::getLine()
//  */
// unsigned LLVMDIVariableGetLine(LLVMMetadataRef Var);
//
// /**
//  * Create a new temporary \c MDNode.  Suitable for use in constructing cyclic
//  * \c MDNode structures. A temporary \c MDNode is not uniqued, may be RAUW'd,
//  * and must be manually deleted with \c LLVMDisposeTemporaryMDNode.
//  * \param Ctx            The context in which to construct the temporary node.
//  * \param Data           The metadata elements.
//  * \param NumElements    Number of metadata elements.
//  */
// LLVMMetadataRef LLVMTemporaryMDNode(LLVMContextRef Ctx, LLVMMetadataRef *Data,
//                                     size_t NumElements);
//
// /**
//  * Deallocate a temporary node.
//  *
//  * Calls \c replaceAllUsesWith(nullptr) before deleting, so any remaining
//  * references will be reset.
//  * \param TempNode    The temporary metadata node.
//  */
// void LLVMDisposeTemporaryMDNode(LLVMMetadataRef TempNode);
//
// /**
//  * Replace all uses of temporary metadata.
//  * \param TempTargetMetadata    The temporary metadata node.
//  * \param Replacement           The replacement metadata node.
//  */
// void LLVMMetadataReplaceAllUsesWith(LLVMMetadataRef TempTargetMetadata,
//                                     LLVMMetadataRef Replacement);
//
// /**
//  * Create a new descriptor for the specified global variable that is temporary
//  * and meant to be RAUWed.
//  * \param Scope       Variable scope.
//  * \param Name        Name of the variable.
//  * \param NameLen     The length of the C string passed to \c Name.
//  * \param Linkage     Mangled  name of the variable.
//  * \param LnkLen      The length of the C string passed to \c Linkage.
//  * \param File        File where this variable is defined.
//  * \param LineNo      Line number.
//  * \param Ty          Variable Type.
//  * \param LocalToUnit Boolean flag indicate whether this variable is
//  *                    externally visible or not.
//  * \param Decl        Reference to the corresponding declaration.
//  * \param AlignInBits Variable alignment(or 0 if no alignment attr was
//  *                    specified)
//  */
// LLVMMetadataRef LLVMDIBuilderCreateTempGlobalVariableFwdDecl(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, const char *Linkage, size_t LnkLen, LLVMMetadataRef File,
//     unsigned LineNo, LLVMMetadataRef Ty, LLVMBool LocalToUnit,
//     LLVMMetadataRef Decl, uint32_t AlignInBits);
//
// /**
//  * Only use in "new debug format" (LLVMIsNewDbgInfoFormat() is true).
//  * See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
//  *
//  * The debug format can be switched later after inserting the records using
//  * LLVMSetIsNewDbgInfoFormat, if needed for legacy or transitionary reasons.
//  *
//  * Insert a Declare DbgRecord before the given instruction.
//  * \param Builder     The DIBuilder.
//  * \param Storage     The storage of the variable to declare.
//  * \param VarInfo     The variable's debug info descriptor.
//  * \param Expr        A complex location expression for the variable.
//  * \param DebugLoc    Debug info location.
//  * \param Instr       Instruction acting as a location for the new record.
//  */
// LLVMDbgRecordRef LLVMDIBuilderInsertDeclareRecordBefore(
//     LLVMDIBuilderRef Builder, LLVMValueRef Storage, LLVMMetadataRef VarInfo,
//     LLVMMetadataRef Expr, LLVMMetadataRef DebugLoc, LLVMValueRef Instr);
//
// /**
//  * Only use in "new debug format" (LLVMIsNewDbgInfoFormat() is true).
//  * See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
//  *
//  * The debug format can be switched later after inserting the records using
//  * LLVMSetIsNewDbgInfoFormat, if needed for legacy or transitionary reasons.
//  *
//  * Insert a Declare DbgRecord at the end of the given basic block. If the basic
//  * block has a terminator instruction, the record is inserted before that
//  * terminator instruction.
//  * \param Builder     The DIBuilder.
//  * \param Storage     The storage of the variable to declare.
//  * \param VarInfo     The variable's debug info descriptor.
//  * \param Expr        A complex location expression for the variable.
//  * \param DebugLoc    Debug info location.
//  * \param Block       Basic block acting as a location for the new record.
//  */
// LLVMDbgRecordRef LLVMDIBuilderInsertDeclareRecordAtEnd(
//     LLVMDIBuilderRef Builder, LLVMValueRef Storage, LLVMMetadataRef VarInfo,
//     LLVMMetadataRef Expr, LLVMMetadataRef DebugLoc, LLVMBasicBlockRef Block);
//
// /**
//  * Only use in "new debug format" (LLVMIsNewDbgInfoFormat() is true).
//  * See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
//  *
//  * The debug format can be switched later after inserting the records using
//  * LLVMSetIsNewDbgInfoFormat, if needed for legacy or transitionary reasons.
//  *
//  * Insert a new debug record before the given instruction.
//  * \param Builder     The DIBuilder.
//  * \param Val         The value of the variable.
//  * \param VarInfo     The variable's debug info descriptor.
//  * \param Expr        A complex location expression for the variable.
//  * \param DebugLoc    Debug info location.
//  * \param Instr       Instruction acting as a location for the new record.
//  */
// LLVMDbgRecordRef LLVMDIBuilderInsertDbgValueRecordBefore(
//     LLVMDIBuilderRef Builder, LLVMValueRef Val, LLVMMetadataRef VarInfo,
//     LLVMMetadataRef Expr, LLVMMetadataRef DebugLoc, LLVMValueRef Instr);
//
// /**
//  * Only use in "new debug format" (LLVMIsNewDbgInfoFormat() is true).
//  * See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
//  *
//  * The debug format can be switched later after inserting the records using
//  * LLVMSetIsNewDbgInfoFormat, if needed for legacy or transitionary reasons.
//  *
//  * Insert a new debug record at the end of the given basic block. If the
//  * basic block has a terminator instruction, the record is inserted before
//  * that terminator instruction.
//  * \param Builder     The DIBuilder.
//  * \param Val         The value of the variable.
//  * \param VarInfo     The variable's debug info descriptor.
//  * \param Expr        A complex location expression for the variable.
//  * \param DebugLoc    Debug info location.
//  * \param Block       Basic block acting as a location for the new record.
//  */
// LLVMDbgRecordRef LLVMDIBuilderInsertDbgValueRecordAtEnd(
//     LLVMDIBuilderRef Builder, LLVMValueRef Val, LLVMMetadataRef VarInfo,
//     LLVMMetadataRef Expr, LLVMMetadataRef DebugLoc, LLVMBasicBlockRef Block);
//
// /**
//  * Create a new descriptor for a local auto variable.
//  * \param Builder         The DIBuilder.
//  * \param Scope           The local scope the variable is declared in.
//  * \param Name            Variable name.
//  * \param NameLen         Length of variable name.
//  * \param File            File where this variable is defined.
//  * \param LineNo          Line number.
//  * \param Ty              Metadata describing the type of the variable.
//  * \param AlwaysPreserve  If true, this descriptor will survive optimizations.
//  * \param Flags           Flags.
//  * \param AlignInBits     Variable alignment.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateAutoVariable(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, LLVMMetadataRef File, unsigned LineNo, LLVMMetadataRef Ty,
//     LLVMBool AlwaysPreserve, LLVMDIFlags Flags, uint32_t AlignInBits);
//
// /**
//  * Create a new descriptor for a function parameter variable.
//  * \param Builder         The DIBuilder.
//  * \param Scope           The local scope the variable is declared in.
//  * \param Name            Variable name.
//  * \param NameLen         Length of variable name.
//  * \param ArgNo           Unique argument number for this variable; starts at 1.
//  * \param File            File where this variable is defined.
//  * \param LineNo          Line number.
//  * \param Ty              Metadata describing the type of the variable.
//  * \param AlwaysPreserve  If true, this descriptor will survive optimizations.
//  * \param Flags           Flags.
//  */
// LLVMMetadataRef LLVMDIBuilderCreateParameterVariable(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef Scope, const char *Name,
//     size_t NameLen, unsigned ArgNo, LLVMMetadataRef File, unsigned LineNo,
//     LLVMMetadataRef Ty, LLVMBool AlwaysPreserve, LLVMDIFlags Flags);
//
// /**
//  * Get the metadata of the subprogram attached to a function.
//  *
//  * @see llvm::Function::getSubprogram()
//  */
// LLVMMetadataRef LLVMGetSubprogram(LLVMValueRef Func);
//
// /**
//  * Set the subprogram attached to a function.
//  *
//  * @see llvm::Function::setSubprogram()
//  */
// void LLVMSetSubprogram(LLVMValueRef Func, LLVMMetadataRef SP);
//
// /**
//  * Get the line associated with a given subprogram.
//  * \param Subprogram     The subprogram object.
//  *
//  * @see DISubprogram::getLine()
//  */
// unsigned LLVMDISubprogramGetLine(LLVMMetadataRef Subprogram);
//
// /**
//  * Get the debug location for the given instruction.
//  *
//  * @see llvm::Instruction::getDebugLoc()
//  */
// LLVMMetadataRef LLVMInstructionGetDebugLoc(LLVMValueRef Inst);
//
// /**
//  * Set the debug location for the given instruction.
//  *
//  * To clear the location metadata of the given instruction, pass NULL to \p Loc.
//  *
//  * @see llvm::Instruction::setDebugLoc()
//  */
// void LLVMInstructionSetDebugLoc(LLVMValueRef Inst, LLVMMetadataRef Loc);
//
// /**
//  * Create a new descriptor for a label
//  *
//  * \param Builder         The DIBuilder.
//  * \param Scope           The scope to create the label in.
//  * \param Name            Variable name.
//  * \param NameLen         Length of variable name.
//  * \param File            The file to create the label in.
//  * \param LineNo          Line Number.
//  * \param AlwaysPreserve  Preserve the label regardless of optimization.
//  *
//  * @see llvm::DIBuilder::createLabel()
//  */
// LLVMMetadataRef LLVMDIBuilderCreateLabel(
//     LLVMDIBuilderRef Builder,
//     LLVMMetadataRef Context, const char *Name, size_t NameLen,
//     LLVMMetadataRef File, unsigned LineNo, LLVMBool AlwaysPreserve);
//
// /**
//  * Insert a new llvm.dbg.label intrinsic call
//  *
//  * \param Builder         The DIBuilder.
//  * \param LabelInfo       The Label's debug info descriptor
//  * \param Location        The debug info location
//  * \param InsertBefore    Location for the new intrinsic.
//  *
//  * @see llvm::DIBuilder::insertLabel()
//  */
// LLVMDbgRecordRef LLVMDIBuilderInsertLabelBefore(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef LabelInfo,
//     LLVMMetadataRef Location, LLVMValueRef InsertBefore);
//
// /**
//  * Insert a new llvm.dbg.label intrinsic call
//  *
//  * \param Builder         The DIBuilder.
//  * \param LabelInfo       The Label's debug info descriptor
//  * \param Location        The debug info location
//  * \param InsertAtEnd     Location for the new intrinsic.
//  *
//  * @see llvm::DIBuilder::insertLabel()
//  */
// LLVMDbgRecordRef LLVMDIBuilderInsertLabelAtEnd(
//     LLVMDIBuilderRef Builder, LLVMMetadataRef LabelInfo,
//     LLVMMetadataRef Location, LLVMBasicBlockRef InsertAtEnd);
//
// /**
//  * Obtain the enumerated type of a Metadata instance.
//  *
//  * @see llvm::Metadata::getMetadataID()
//  */
// LLVMMetadataKind LLVMGetMetadataKind(LLVMMetadataRef Metadata);
