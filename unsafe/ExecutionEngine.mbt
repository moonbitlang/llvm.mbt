// =======================================================
// ExecutionEngine.h
// =======================================================

// void LLVMLinkInMCJIT(void);
// void LLVMLinkInInterpreter(void);

///|
#external
pub type LLVMExecutionEngineRef

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

///|
pub extern "C" fn llvm_create_generic_value_of_int(
  ty : LLVMTypeRef,
  n : UInt64,
  is_signed : Bool
) -> LLVMGenericValueRef = "LLVMCreateGenericValueOfInt"

//
// LLVMGenericValueRef LLVMCreateGenericValueOfPointer(void *P);
//
// LLVMGenericValueRef LLVMCreateGenericValueOfFloat(LLVMTypeRef Ty, double N);

///|
pub extern "C" fn llvm_create_generic_value_of_float(
  ty : LLVMTypeRef,
  n : Double
) -> LLVMGenericValueRef = "LLVMCreateGenericValueOfFloat"

//
// unsigned LLVMGenericValueIntWidth(LLVMGenericValueRef GenValRef);

///|
pub extern "C" fn llvm_generic_value_int_width(
  gen_val_ref : LLVMGenericValueRef
) -> UInt = "LLVMGenericValueIntWidth"

//
// unsigned long long LLVMGenericValueToInt(LLVMGenericValueRef GenVal,
//                                          LLVMBool IsSigned);
//

///|
pub extern "C" fn llvm_generic_value_to_int(
  gen_val : LLVMGenericValueRef,
  is_signed : Bool
) -> UInt64 = "LLVMGenericValueToInt"

//
// void *LLVMGenericValueToPointer(LLVMGenericValueRef GenVal);
//
// double LLVMGenericValueToFloat(LLVMTypeRef TyRef, LLVMGenericValueRef GenVal);

///|
pub extern "C" fn llvm_generic_value_to_float(
  ty_ref : LLVMTypeRef,
  gen_val : LLVMGenericValueRef
) -> Double = "LLVMGenericValueToFloat"

// void LLVMDisposeGenericValue(LLVMGenericValueRef GenVal);
//
// /*===-- Operations on execution engines -----------------------------------===*/
//
// LLVMBool LLVMCreateExecutionEngineForModule(LLVMExecutionEngineRef *OutEE,
//                                             LLVMModuleRef M,
//                                             char **OutError);

///|
extern "C" fn __llvm_new_execution_engine() -> LLVMExecutionEngineRef = "llvm_new_execution_engine"

///|
extern "C" fn __llvm_create_execution_engine_for_module(
  out_ee : Ref[LLVMExecutionEngineRef],
  m : LLVMModuleRef,
  out_error : Ref[CStr]
) -> Bool = "LLVMCreateExecutionEngineForModule"

///|
pub fn llvm_create_execution_engine_for_module(
  m : LLVMModuleRef
) -> (LLVMExecutionEngineRef?, String) {
  let execution_engine = Ref::new(__llvm_new_execution_engine())
  let err_msg = Ref::new(CStr::new())
  let res = __llvm_create_execution_engine_for_module(
    execution_engine, m, err_msg,
  )
  match res {
    true => (None, c_str_to_moonbit_str(err_msg.val))
    false => (Some(execution_engine.val), "")
  }
}

// LLVMBool LLVMCreateInterpreterForModule(LLVMExecutionEngineRef *OutInterp,
//                                         LLVMModuleRef M,
//                                         char **OutError);
//

///|
extern "C" fn __llvm_create_interpreter_for_module(
  out_interp : Ref[LLVMExecutionEngineRef],
  m : LLVMModuleRef,
  out_error : Ref[CStr]
) -> Bool = "LLVMCreateInterpreterForModule"

///|
pub fn llvm_create_interpreter_for_module(
  m : LLVMModuleRef
) -> (LLVMExecutionEngineRef?, String) {
  let interpreter = Ref::new(__llvm_new_execution_engine())
  let err_msg = Ref::new(CStr::new())
  let res = __llvm_create_interpreter_for_module(interpreter, m, err_msg)
  match res {
    true => (None, c_str_to_moonbit_str(err_msg.val))
    false => (Some(interpreter.val), "")
  }
}

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

///|
extern "C" fn __llvm_run_function(
  ee : LLVMExecutionEngineRef,
  f : LLVMValueRef,
  num_args : UInt,
  args : FixedArray[LLVMGenericValueRef]
) -> LLVMGenericValueRef = "LLVMRunFunction"

///|
pub fn llvm_run_function(
  ee : LLVMExecutionEngineRef,
  f : LLVMValueRef,
  args : Array[LLVMGenericValueRef]
) -> LLVMGenericValueRef {
  let num_args = args.length().reinterpret_as_uint()
  let args_fixed = FixedArray::from_array(args)
  __llvm_run_function(ee, f, num_args, args_fixed)
}

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

///|
pub fn llvm_get_function_address(
  ee : LLVMExecutionEngineRef,
  name : String
) -> UInt64 {
  let name = moonbit_str_to_c_str(name)
  __llvm_get_function_address(ee, name)
}

///|
extern "C" fn __llvm_get_function_address(
  ee : LLVMExecutionEngineRef,
  name : CStr
) -> UInt64 = "LLVMGetFunctionAddress"

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
