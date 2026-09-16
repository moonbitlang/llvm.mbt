///|
/// Reports a failure to parse or run an LLVM pass pipeline.
pub suberror PassError {
  /// Contains LLVM's pipeline diagnostic, including invalid names or embedded NUL.
  PipelineFailed(String)
}

///|
/// Runs an LLVM pass pipeline on a clone and returns the optimized module.
///
/// **Parameters:** `pipeline` uses LLVM's `opt -passes` syntax, for example
/// `function(instcombine,simplifycfg)` or `default<O2>`. `targetMachine` supplies
/// target analyses and must match the module's configured triple and layout.
///
/// **Returns:** A new module retaining the original context, verified before
/// return. Look up optimized functions and globals in this returned module.
///
/// **Errors:** Raises `VerificationError` if the input or result fails LLVM
/// verification, or `PassError::PipelineFailed` for a rejected pipeline.
/// A failed operation leaves the input unchanged.
///
/// **Preconditions:** The pipeline and target must support the input IR.
/// Passes are LLVM built-ins; this API does not load pass plugins.
///
/// **Lifecycle:** The input module and all its borrowed values remain valid.
/// Transformations can erase IR, so they run on an independent module clone;
/// no borrowed instruction or builder is exposed until the passes complete.
/// Temporary pass options are disposed on both success and reported failure.
///
/// **Side effects:** Mutates only the clone. Diagnostic/output passes can also
/// write files or emit output according to the requested pipeline.
///
/// **Thread safety:** Do not concurrently mutate modules sharing this context.
///
/// **LLVM API:** `LLVMCloneModule` and `LLVMRunPasses` (new pass manager).
///
/// **Examples:**
///
/// ```mbt check
/// test {
///   let ctx = Context::new()
///   let mod = ctx.addModule("optimize")
///   let machine = TargetMachine::host(TargetMachineOptions::new())
///   machine.configureModule(mod)
///   let optimized = mod.runPasses("default<O2>", targetMachine=machine)
///   optimized.verify()
/// }
/// ```
pub fn Module::runPasses(
  self : Self,
  pipeline : String,
  targetMachine~ : TargetMachine,
) -> Module raise {
  self.verify()
  let optimized = Module::from_raw(
    @raw.llvm_clone_module(self.get_raw_ref()),
    self.getContext(),
  )
  let options = @raw.llvm_create_pass_builder_options()
  let error = @raw.llvm_run_passes(
    optimized.get_raw_ref(),
    pipeline,
    targetMachine.get_raw_ref(),
    options,
  )
  @raw.llvm_dispose_pass_builder_options(options)
  guard @raw.llvm_error_is_success(error) else {
    raise PipelineFailed(@raw.llvm_take_error_message(error))
  }
  optimized.verify()
  optimized
}
