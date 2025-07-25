// /*===----------- llvm-c/LLJIT.h - OrcV2 LLJIT C bindings ----------*- C -*-===*\
// |*                                                                            *|
// |* Part of the LLVM Project, under the Apache License v2.0 with LLVM *|
// |* Exceptions. *|
// |* See https://llvm.org/LICENSE.txt for license information. *|
// |* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception *|
// |* *|
// |*===----------------------------------------------------------------------===*|
// |* *|
// |* This header declares the C interface to the LLJIT class in *|
// |* libLLVMOrcJIT.a, which provides a simple MCJIT-like ORC JIT. *|
// |* *|
// |* Many exotic languages can interoperate with C code but have a harder time
// *|
// |* with C++ due to name mangling. So in addition to C, this interface enables
// *|
// |* tools written in such languages. *|
// |* *|
// |* Note: This interface is experimental. It is *NOT* stable, and may be *|
// |*       changed without warning. Only C API usage documentation is *|
// |*       provided. See the C++ documentation for all higher level ORC API *|
// |*       details. *|
// |* *|
// \*===----------------------------------------------------------------------===*/
//
// /**
//  * @defgroup LLVMCExecutionEngineLLJIT LLJIT
//  * @ingroup LLVMCExecutionEngine
//  *
//  * @{
//  */
//
// /**
//  * A function for constructing an ObjectLinkingLayer instance to be used
//  * by an LLJIT instance.
//  *
//  * Clients can call LLVMOrcLLJITBuilderSetObjectLinkingLayerCreator to
//  * set the creator function to use when constructing an LLJIT instance.
//  * This can be used to override the default linking layer implementation
//  * that would otherwise be chosen by LLJITBuilder.
//  *
//  * Object linking layers returned by this function will become owned by the
//  * LLJIT instance. The client is not responsible for managing their lifetimes
//  * after the function returns.
//  */
// typedef LLVMOrcObjectLayerRef (
//     *LLVMOrcLLJITBuilderObjectLinkingLayerCreatorFunction)(
//     void *Ctx, LLVMOrcExecutionSessionRef ES, const char *Triple);
//
// /**
//  * A reference to an orc::LLJITBuilder instance.
//  */
// typedef struct LLVMOrcOpaqueLLJITBuilder *LLVMOrcLLJITBuilderRef;

///|
#external
pub type LLVMOrcJITDylibRef

///|
#external
pub type LLVMOrcLLJITBuilderRef

//
// /**
//  * A reference to an orc::LLJIT instance.
//  */
// typedef struct LLVMOrcOpaqueLLJIT *LLVMOrcLLJITRef;

///|
#external
pub type LLVMOrcLLJITRef

///|
extern "C" fn llvm_new_null_orc_lljit() -> LLVMOrcLLJITRef = "__llvm_new_null"

//
// /**
//  * Create an LLVMOrcLLJITBuilder.
//  *
//  * The client owns the resulting LLJITBuilder and should dispose of it using
//  * LLVMOrcDisposeLLJITBuilder once they are done with it.
//  */
// LLVMOrcLLJITBuilderRef LLVMOrcCreateLLJITBuilder(void);

///|
pub extern "C" fn llvm_orc_create_lljit_builder() -> LLVMOrcLLJITBuilderRef = "LLVMOrcCreateLLJITBuilder"

//
// /**
//  * Dispose of an LLVMOrcLLJITBuilderRef. This should only be called if
//  ownership
//  * has not been passed to LLVMOrcCreateLLJIT (e.g. because some error
//  prevented
//  * that function from being called).
//  */
// void LLVMOrcDisposeLLJITBuilder(LLVMOrcLLJITBuilderRef Builder);

///|
pub extern "C" fn llvm_orc_dispose_lljit_builder(
  builder : LLVMOrcLLJITBuilderRef
) = "LLVMOrcDisposeLLJITBuilder"

//
// /**
//  * Set the JITTargetMachineBuilder to be used when constructing the LLJIT
//  * instance. Calling this function is optional: if it is not called then the
//  * LLJITBuilder will use JITTargeTMachineBuilder::detectHost to construct a
//  * JITTargetMachineBuilder.
//  *
//  * This function takes ownership of the JTMB argument: clients should not
//  * dispose of the JITTargetMachineBuilder after calling this function.
//  */
// void LLVMOrcLLJITBuilderSetJITTargetMachineBuilder(
//     LLVMOrcLLJITBuilderRef Builder, LLVMOrcJITTargetMachineBuilderRef JTMB);
//
// /**
//  * Set an ObjectLinkingLayer creator function for this LLJIT instance.
//  */
// void LLVMOrcLLJITBuilderSetObjectLinkingLayerCreator(
//     LLVMOrcLLJITBuilderRef Builder,
//     LLVMOrcLLJITBuilderObjectLinkingLayerCreatorFunction F, void *Ctx);
//
// /**
//  * Create an LLJIT instance from an LLJITBuilder.
//  *
//  * This operation takes ownership of the Builder argument: clients should not
//  * dispose of the builder after calling this function (even if the function
//  * returns an error). If a null Builder argument is provided then a
//  * default-constructed LLJITBuilder will be used.
//  *
//  * On success the resulting LLJIT instance is uniquely owned by the client
//  and
//  * automatically manages the memory of all JIT'd code and all modules that
//  are
//  * transferred to it (e.g. via LLVMOrcLLJITAddLLVMIRModule). Disposing of the
//  * LLJIT instance will free all memory managed by the JIT, including JIT'd
//  code
//  * and not-yet compiled modules.
//  */
// LLVMErrorRef LLVMOrcCreateLLJIT(LLVMOrcLLJITRef *Result,
//                                 LLVMOrcLLJITBuilderRef Builder);

///|
extern "C" fn llvm_new_null_orc_lljit_builder() -> LLVMOrcLLJITBuilderRef = "__llvm_new_null"

///|
pub fn llvm_orc_create_lljit() -> LLVMOrcLLJITRef {
  let builder = llvm_new_null_orc_lljit_builder()
  let result : Ref[LLVMOrcLLJITRef] = Ref::new(llvm_new_null_orc_lljit())
  let err = __llvm_orc_create_lljit(result, builder)
  if llvm_error_is_null(err) {
    result.val
  } else {
    println("Failed to create lljit")
    panic()
  }
}

///|
extern "C" fn __llvm_orc_create_lljit(
  result : Ref[LLVMOrcLLJITRef],
  builder : LLVMOrcLLJITBuilderRef
) -> LLVMErrorRef = "LLVMOrcCreateLLJIT"
//
// /**
//  * Dispose of an LLJIT instance.
//  */
// LLVMErrorRef LLVMOrcDisposeLLJIT(LLVMOrcLLJITRef J);

///|
pub extern "C" fn llvm_orc_dispose_lljit(j : LLVMOrcLLJITRef) -> LLVMErrorRef = "LLVMOrcDisposeLLJIT"

//
// /**
//  * Get a reference to the ExecutionSession for this LLJIT instance.
//  *
//  * The ExecutionSession is owned by the LLJIT instance. The client is not
//  * responsible for managing its memory.
//  */
// LLVMOrcExecutionSessionRef LLVMOrcLLJITGetExecutionSession(LLVMOrcLLJITRef
// J);
//
// /**
//  * Return a reference to the Main JITDylib.
//  *
//  * The JITDylib is owned by the LLJIT instance. The client is not responsible
//  * for managing its memory.
//  */
// LLVMOrcJITDylibRef LLVMOrcLLJITGetMainJITDylib(LLVMOrcLLJITRef J);

///|
pub extern "C" fn llvm_orc_lljit_get_main_jit_dylib(
  j : LLVMOrcLLJITRef
) -> LLVMOrcJITDylibRef = "LLVMOrcLLJITGetMainJITDylib"

//
// /**
//  * Return the target triple for this LLJIT instance. This string is owned by
//  * the LLJIT instance and should not be freed by the client.
//  */
// const char *LLVMOrcLLJITGetTripleString(LLVMOrcLLJITRef J);
//
// /**
//  * Returns the global prefix character according to the LLJIT's DataLayout.
//  */
// char LLVMOrcLLJITGetGlobalPrefix(LLVMOrcLLJITRef J);
//
// /**
//  * Mangles the given string according to the LLJIT instance's DataLayout,
//  then
//  * interns the result in the SymbolStringPool and returns a reference to the
//  * pool entry. Clients should call LLVMOrcReleaseSymbolStringPoolEntry to
//  * decrement the ref-count on the pool entry once they are finished with this
//  * value.
//  */
// LLVMOrcSymbolStringPoolEntryRef
// LLVMOrcLLJITMangleAndIntern(LLVMOrcLLJITRef J, const char *UnmangledName);
//
// /**
//  * Add a buffer representing an object file to the given JITDylib in the
//  given
//  * LLJIT instance. This operation transfers ownership of the buffer to the
//  * LLJIT instance. The buffer should not be disposed of or referenced once
//  this
//  * function returns.
//  *
//  * Resources associated with the given object will be tracked by the given
//  * JITDylib's default resource tracker.
//  */
// LLVMErrorRef LLVMOrcLLJITAddObjectFile(LLVMOrcLLJITRef J, LLVMOrcJITDylibRef
// JD,
//                                        LLVMMemoryBufferRef ObjBuffer);
//
// /**
//  * Add a buffer representing an object file to the given ResourceTracker's
//  * JITDylib in the given LLJIT instance. This operation transfers ownership
//  of
//  * the buffer to the LLJIT instance. The buffer should not be disposed of or
//  * referenced once this function returns.
//  *
//  * Resources associated with the given object will be tracked by
//  ResourceTracker
//  * RT.
//  */
// LLVMErrorRef LLVMOrcLLJITAddObjectFileWithRT(LLVMOrcLLJITRef J,
//                                              LLVMOrcResourceTrackerRef RT,
//                                              LLVMMemoryBufferRef ObjBuffer);
//
// /**
//  * Add an IR module to the given JITDylib in the given LLJIT instance. This
//  * operation transfers ownership of the TSM argument to the LLJIT instance.
//  * The TSM argument should not be disposed of or referenced once this
//  * function returns.
//  *
//  * Resources associated with the given Module will be tracked by the given
//  * JITDylib's default resource tracker.
//  */
// LLVMErrorRef LLVMOrcLLJITAddLLVMIRModule(LLVMOrcLLJITRef J,
//                                          LLVMOrcJITDylibRef JD,
//                                          LLVMOrcThreadSafeModuleRef TSM);
//

///|
pub extern "C" fn llvm_orc_lljit_add_llvm_ir_module(
  j : LLVMOrcLLJITRef,
  jd : LLVMOrcJITDylibRef,
  tsm : LLVMOrcThreadSafeModuleRef
) -> LLVMErrorRef = "LLVMOrcLLJITAddLLVMIRModule"

// /**
//  * Add an IR module to the given ResourceTracker's JITDylib in the given
//  LLJIT
//  * instance. This operation transfers ownership of the TSM argument to the
//  LLJIT
//  * instance. The TSM argument should not be disposed of or referenced once
//  this
//  * function returns.
//  *
//  * Resources associated with the given Module will be tracked by
//  ResourceTracker
//  * RT.
//  */
// LLVMErrorRef LLVMOrcLLJITAddLLVMIRModuleWithRT(LLVMOrcLLJITRef J,
//                                                LLVMOrcResourceTrackerRef JD,
//                                                LLVMOrcThreadSafeModuleRef
//                                                TSM);
//
// /**
//  * Look up the given symbol in the main JITDylib of the given LLJIT instance.
//  *
//  * This operation does not take ownership of the Name argument.
//  */
// LLVMErrorRef LLVMOrcLLJITLookup(LLVMOrcLLJITRef J,
//                                 LLVMOrcExecutorAddress *Result,
//                                 const char *Name);
//

///|
pub fn llvm_orc_lljit_lookup(
  j : LLVMOrcLLJITRef,
  name : String
) -> LLVMOrcExecutorAddress? {
  let addr : Ref[LLVMOrcExecutorAddress] = Ref::new(
    LLVMOrcExecutorAddress::default(),
  )
  let err = __llvm_orc_lljit_lookup(j, addr, moonbit_str_to_c_str(name))
  if llvm_error_is_null(err) {
    Some(addr.val)
  } else {
    None
  }
}

///|
extern "C" fn __llvm_orc_lljit_lookup(
  j : LLVMOrcLLJITRef,
  result : Ref[LLVMOrcExecutorAddress],
  name : CStr
) -> LLVMErrorRef = "LLVMOrcLLJITLookup"

// /**
//  * Returns a non-owning reference to the LLJIT instance's object linking
//  layer.
//  */
// LLVMOrcObjectLayerRef LLVMOrcLLJITGetObjLinkingLayer(LLVMOrcLLJITRef J);
//
// /**
//  * Returns a non-owning reference to the LLJIT instance's object linking
//  layer.
//  */
// LLVMOrcObjectTransformLayerRef
// LLVMOrcLLJITGetObjTransformLayer(LLVMOrcLLJITRef J);
//
// /**
//  * Returns a non-owning reference to the LLJIT instance's IR transform layer.
//  */
// LLVMOrcIRTransformLayerRef LLVMOrcLLJITGetIRTransformLayer(LLVMOrcLLJITRef
// J);
//
// /**
//  * Get the LLJIT instance's default data layout string.
//  *
//  * This string is owned by the LLJIT instance and does not need to be freed
//  * by the caller.
//  */
// const char *LLVMOrcLLJITGetDataLayoutStr(LLVMOrcLLJITRef J);

// /**
//  * Install the plugin that submits debug objects to the executor. Executors must
//  * expose the llvm_orc_registerJITLoaderGDBWrapper symbol.
//  */
// LLVMErrorRef LLVMOrcLLJITEnableDebugSupport(LLVMOrcLLJITRef J);
