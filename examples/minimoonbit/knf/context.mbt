///|
/// Reports a MiniMoonBit KNF lowering failure through `KnfTransformError`.
pub(all) suberror KnfTransformError {
  /// Represents the `KnfTransformError` KNF form.
  KnfTransformError(String)
} derive(Debug)

///|
/// Represents the MiniMoonBit KNF value or lowering context `Name`.
pub(all) struct Name {
  /// Stores the `id` component of this KNF value.
  id : String
  /// Stores the `slot` component of this KNF value.
  slot : Int
} derive(Hash, Eq)

///|
/// Performs the `wildcard` operation on `Name`.
pub fn Name::wildcard() -> Name {
  Name::{ id: "_", slot: 0, }
}

///|
/// Formats `Name` using MiniMoonBit KNF notation.
pub impl Show for Name with fn output(self, logger) {
  logger.write_string(self.id)
  if self.slot > 0 {
    logger.write_string("$\{self.slot}")
  }
}

///|
/// Represents the MiniMoonBit KNF value or lowering context `Env`.
pub(all) struct Env {
  /// Stores the `local_` component of this KNF value.
  local_ : Map[String, (Name, Type, Bool)] // defined in this scope, Bool is mutable flag
  /// Stores the `capture` component of this KNF value.
  capture : Map[Name, (Type, Bool)] // captured from outer scopes, Bool is mutable flag
  /// Stores the `parent` component of this KNF value.
  parent : Env?
}

///|
/// Creates a new `Env` lowering value.
pub fn Env::new(parent? : Env? = None) -> Env {
  Env::{ local_: Map([]), capture: Map([]), parent, }
}

///|
/// Performs the `get_and_capture` operation on `Env`.
pub fn Env::get_and_capture(self : Env, name : String) -> (Name, Type, Bool)? {
  if self.local_.get(name) is Some(n) {
    return Some(n)
  }
  // In This Case, it is top function
  guard self.parent is Some(p) else { return None }
  // In This Case, it is local function, search parent
  match p.get_and_capture(name) {
    Some((n, ty, is_mut)) => {
      self.capture.set(n, (ty, is_mut))
      Some((n, ty, is_mut))
    }
    None => None
  }
}

///|
/// Performs the `get_name_type` operation on `Env`.
pub fn Env::get_name_type(self : Env, name : Name) -> Type? {
  let { id, .. } = name
  match self.local_.get(id) {
    Some((_, t, _)) => Some(t)
    None =>
      match self.parent {
        Some(p) => p.get_name_type(name)
        None => None
      }
  }
}

///|
/// Performs the `get` operation on `Env`.
pub fn Env::get(self : Env, name : String) -> Name? {
  match self.local_.get(name) {
    Some((n, _, _)) => Some(n)
    None =>
      match self.parent {
        Some(p) => p.get(name)
        None => None
      }
  }
}

///|
/// Performs the `set` operation on `Env`.
pub fn Env::set(
  self : Env,
  s : String,
  name : Name,
  ty : Type,
  is_mut : Bool,
) -> Unit {
  self.local_.set(s, (name, ty, is_mut))
}

///|
/// Represents the MiniMoonBit KNF value or lowering context `Context`.
pub(all) struct Context {
  /// Stores the `name_env` component of this KNF value.
  mut name_env : Env
  /// Stores the `capture` component of this KNF value.
  capture : Array[Name]
  /// Stores the `global_stmts` component of this KNF value.
  global_stmts : Array[KnfStmt]
  /// Stores the `globals` component of this KNF value.
  globals : Map[String, Type]
  /// Stores the `unions` component of this KNF value.
  unions : Map[String, Array[String]] // union name to variant names
  /// Stores the `struct_defs` component of this KNF value.
  struct_defs : Map[String, KnfStructDef] // struct definitions
}

///|
/// Creates a new `Context` lowering value.
pub fn Context::new() -> Context {
  Context::{
    name_env: Env::new(),
    capture: Array::new(),
    global_stmts: Array::new(),
    globals: Map([]),
    unions: Map([]),
    struct_defs: Map([]),
  }
}

///|
/// Performs the `lookup_name` KNF lowering operation.
pub fn Context::lookup_name(self : Context, s : String) -> (Name, Type)? {
  match self.name_env.get_and_capture(s) {
    Some((n, ty, _)) => Some((n, ty))
    None =>
      match self.globals.get(s) {
        Some(t) => {
          let name = Name::{ id: s, slot: 0, }
          Some((name, t))
        }
        None => None
      }
  }
}

///|
/// Performs the `enter_scope` KNF lowering operation.
pub fn Context::enter_scope(self : Context) -> Unit {
  let sub_env = Env::new(parent=Some(self.name_env))
  self.name_env = sub_env
}

///|
/// Performs the `exit_scope` KNF lowering operation.
pub fn Context::exit_scope(self : Context) -> Unit {
  self.name_env = match self.name_env.parent {
    Some(p) => p
    None => self.name_env
  }
}

///|
/// Performs the `add_new_name` KNF lowering operation.
pub fn Context::add_new_name(
  self : Context,
  s : String,
  ty : Type,
  mutable? : Bool = false,
) -> Name {
  match self.name_env.get(s) {
    Some({ id, slot, }) => {
      let name = Name::{ id, slot: slot + 1, }
      self.name_env.set(s, name, ty, mutable)
      name
    }
    None => {
      let name = Name::{ id: s, slot: 0, }
      self.name_env.set(s, name, ty, mutable)
      name
    }
  }
}

///|
/// Performs the `add_temp` KNF lowering operation.
pub fn Context::add_temp(self : Context, ty : Type) -> Name {
  let temp_id = "tmp"
  self.add_new_name(temp_id, ty)
}
