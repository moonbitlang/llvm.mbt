///|
fn copy_prototype(prototype : @ast.Prototype) -> @ast.Prototype {
  {
    name: prototype.name,
    parameters: prototype.parameters.copy(),
    kind: prototype.kind,
  }
}

///|
fn is_operator_character(operator : Char) -> Bool {
  [
    '!', '$', '%', '&', '*', '+', '.', '/', ':', '<', '=', '>', '?', '@', '^', '|',
    '~', '-',
  ].contains(operator)
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
  match prototype.kind {
    @ast.Normal => ()
    @ast.Unary(operator) => {
      guard is_operator_character(operator) &&
        operator != '=' &&
        prototype.name == "unary\{operator}" else {
        raise InvalidPrototype("invalid unary operator prototype")
      }
      guard prototype.parameters.length() == 1 else {
        raise InvalidPrototype("unary operator must have one parameter")
      }
    }
    @ast.Binary(operator, precedence) => {
      guard is_operator_character(operator) &&
        operator != '=' &&
        !['<', '+', '-', '*'].contains(operator) &&
        prototype.name == "binary\{operator}" else {
        raise InvalidPrototype("invalid or reserved binary operator prototype")
      }
      guard prototype.parameters.length() == 2 else {
        raise InvalidPrototype("binary operator must have two parameters")
      }
      guard precedence >= 1 && precedence <= 100 else {
        raise InvalidPrototype("binary precedence must be between 1 and 100")
      }
    }
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
  guard existing.kind == incoming.kind else {
    raise InvalidPrototype(
      "function `\{incoming.name}` conflicts with an existing prototype kind",
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
  priv prototypes : Map[String, @ast.Prototype]
  priv definitions : Map[String, Bool]
}

///|
/// Creates an empty prototype catalog.
pub fn PrototypeCatalog::new() -> PrototypeCatalog {
  { prototypes: Map([]), definitions: Map([]), }
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
