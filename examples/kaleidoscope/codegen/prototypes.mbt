///|
fn copy_prototype(prototype : @ast.Prototype) -> @ast.Prototype {
  { name: prototype.name, parameters: prototype.parameters.copy() }
}

///|
fn validate_prototype(prototype : @ast.Prototype) -> Unit raise CodegenError {
  guard prototype.name != "" else {
    raise InvalidPrototype("function name must not be empty")
  }
  let seen : Map[String, Bool] = Map([])
  for parameter in prototype.parameters {
    guard parameter != "" else {
      raise InvalidPrototype(
        "function `\{prototype.name}` has an empty parameter name",
      )
    }
    guard seen.get(parameter) is None else {
      raise InvalidPrototype(
        "function `\{prototype.name}` repeats parameter `\{parameter}`",
      )
    }
    seen.set(parameter, true)
  }
}

///|
fn validate_compatible(
  existing : @ast.Prototype,
  incoming : @ast.Prototype,
) -> Unit raise CodegenError {
  guard existing.parameters.length() == incoming.parameters.length() else {
    raise ConflictingPrototype(
      incoming.name,
      existing.parameters.length(),
      incoming.parameters.length(),
    )
  }
}

///|
/// Stores function prototypes and definition state without retaining LLVM
/// handles from any generated module.
///
/// Catalog updates are explicit. Code generation only reads the catalog, so a
/// caller can commit an extern or definition after verification and JIT
/// submission have succeeded.
///
/// **Construction:** Use `PrototypeCatalog::new` for an empty language session.
pub struct PrototypeCatalog {
  prototypes : Map[String, @ast.Prototype]
  definitions : Map[String, Bool]
}

///|
/// Creates an empty prototype catalog.
pub fn PrototypeCatalog::new() -> PrototypeCatalog {
  { prototypes: Map([]), definitions: Map([]) }
}

///|
/// Returns an independent copy of the prototype registered under `name`.
pub fn PrototypeCatalog::get(
  self : PrototypeCatalog,
  name : String,
) -> @ast.Prototype? {
  self.prototypes.get(name).map(copy_prototype)
}

///|
/// Returns whether `name` already has a successfully submitted definition.
pub fn PrototypeCatalog::isDefined(
  self : PrototypeCatalog,
  name : String,
) -> Bool {
  self.definitions.get(name).unwrap_or(false)
}

///|
/// Checks whether a definition can be compiled without modifying the catalog.
///
/// **Errors:** Raises `DuplicateDefinition`, `ConflictingPrototype`, or
/// `InvalidPrototype` when the candidate cannot be committed later.
pub fn PrototypeCatalog::validateDefinition(
  self : PrototypeCatalog,
  prototype : @ast.Prototype,
) -> Unit raise CodegenError {
  validate_prototype(prototype)
  guard !self.isDefined(prototype.name) else {
    raise DuplicateDefinition(prototype.name)
  }
  match self.prototypes.get(prototype.name) {
    Some(existing) => validate_compatible(existing, prototype)
    None => ()
  }
}

///|
/// Commits an extern prototype after its surrounding operation succeeds.
///
/// A repeated declaration with the same arity is idempotent. An existing
/// definition is preserved.
pub fn PrototypeCatalog::commitExtern(
  self : PrototypeCatalog,
  prototype : @ast.Prototype,
) -> Unit raise CodegenError {
  validate_prototype(prototype)
  match self.prototypes.get(prototype.name) {
    Some(existing) => validate_compatible(existing, prototype)
    None => {
      self.prototypes.set(prototype.name, copy_prototype(prototype))
      self.definitions.set(prototype.name, false)
    }
  }
}

///|
/// Commits a successfully verified and submitted function definition.
///
/// **Preconditions:** Call this only after `compileDefinition` succeeds and,
/// when applicable, after the resulting module is accepted by the JIT.
pub fn PrototypeCatalog::commitDefinition(
  self : PrototypeCatalog,
  prototype : @ast.Prototype,
) -> Unit raise CodegenError {
  self.validateDefinition(prototype)
  self.prototypes.set(prototype.name, copy_prototype(prototype))
  self.definitions.set(prototype.name, true)
}
