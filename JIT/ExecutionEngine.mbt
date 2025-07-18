//
//typealias @IR.(Function, ConstantInt)
//
//
//typealias @unsafe.LLVMExecutionEngineRef as ExecutionEngineRef 
//
//pub type ExecutionEngine ExecutionEngineRef
//
//pub suberror ExecutionEngineCreateError String derive(Show)
//
//pub fn ExecutionEngine::create(mod: Module) -> ExecutionEngine raise {
//  let (engref, err) = @unsafe.llvm_create_interpreter_for_module(mod.inner())
//  let engref = match engref {
//    Some(e) => e
//    None => raise ExecutionEngineCreateError(err)
//  }
//  ExecutionEngine(engref)
//}
