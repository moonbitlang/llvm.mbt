///|
fn[T] backend(action : () -> T raise) -> T raise CodegenError {
  action() catch {
    error => raise BackendFailure(error.to_string())
  }
}

///|
/// Owns the fresh LLVM context, module, builder, and lexical values used for one
/// code-generation operation.
///
/// A `CodegenContext` is never reused across submitted modules. Its variable
/// bindings contain only values owned by its own module.
///
/// **Lifecycle:** The returned Module retains its LLVM Context after this
/// wrapper becomes unreachable. No explicit disposal is required.
pub struct CodegenContext {
  context : @IR.Context
  mod : @IR.Module
  builder : @IR.IRBuilder
  variables : Map[String, &@IR.Value]
}

///|
/// Creates an empty code-generation operation with no builder insertion point.
///
/// **Parameters:**
///
/// - `module_name`: Diagnostic module identifier written into generated IR.
pub fn CodegenContext::new(
  module_name~ : String,
) -> CodegenContext raise CodegenError {
  let context = @IR.Context::new()
  let mod = backend(() => context.addModule(module_name))
  { context, mod, builder: context.createBuilder(), variables: Map([]) }
}

///|
/// Returns the module owned by this code-generation operation.
pub fn CodegenContext::getModule(self : CodegenContext) -> @IR.Module {
  self.mod
}

///|
/// Verifies the complete module and maps the LLVM diagnostic to `CodegenError`.
pub fn CodegenContext::verify(self : CodegenContext) -> Unit raise CodegenError {
  self.mod.verify() catch {
    @IR.VerificationError::VerificationError(message) =>
      raise VerificationFailed(message)
  }
}

///|
fn CodegenContext::doubleFunctionType(
  self : CodegenContext,
  arity : Int,
) -> @IR.FunctionType {
  let double_type = self.context.getDoubleTy()
  let parameters : Array[&@IR.Type] = []
  for _ in 0..<arity {
    parameters.push(double_type)
  }
  self.context.getFunctionType(double_type, parameters)
}

///|
fn CodegenContext::declarePrototype(
  self : CodegenContext,
  prototype : @ast.Prototype,
) -> @IR.Function raise CodegenError {
  match self.mod.getFunction(prototype.name) {
    Some(function) => {
      guard function.getNumArgs() == prototype.parameters.length() else {
        raise ConflictingPrototype(
          prototype.name,
          function.getNumArgs(),
          prototype.parameters.length(),
        )
      }
      function
    }
    None =>
      backend(() => {
        self.mod.addFunction(
          self.doubleFunctionType(prototype.parameters.length()),
          prototype.name,
        )
      })
  }
}

///|
fn CodegenContext::resolveFunction(
  self : CodegenContext,
  catalog : PrototypeCatalog,
  name : String,
) -> @IR.Function raise CodegenError {
  match self.mod.getFunction(name) {
    Some(function) => function
    None =>
      match catalog.get(name) {
        Some(prototype) => self.declarePrototype(prototype)
        None => raise UnknownFunction(name)
      }
  }
}
