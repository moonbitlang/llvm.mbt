///|
/// Enumerates the KNF forms represented by `Type`.
pub(all) enum Type {
  /// Represents the `Unit` KNF form.
  Unit
  /// Represents the `Int` KNF form.
  Int
  /// Represents the `Int64` KNF form.
  Int64
  /// Represents the `UInt` KNF form.
  UInt
  /// Represents the `UInt64` KNF form.
  UInt64
  /// Represents the `Bool` KNF form.
  Bool
  /// Represents the `Double` KNF form.
  Double
  /// Represents the `Float` KNF form.
  Float
  /// Represents the `Char` KNF form.
  Char
  /// Represents the `String` KNF form.
  String
  /// Represents the `Array` KNF form.
  Array(Type)
  /// Represents the `Struct` KNF form.
  Struct(String)
  /// Represents the `Union` KNF form.
  Union(String)
  /// Represents the `Tuple` KNF form.
  Tuple(Array[Type])
  /// Represents the `Function` KNF form.
  Function(Array[Type], Type)
}

///|
/// Formats `Type` using MiniMoonBit KNF notation.
pub impl Show for Type with fn output(self, logger) {
  let s = match self {
    Unit => "Unit"
    Int => "Int"
    Int64 => "Int64"
    UInt => "UInt"
    UInt64 => "UInt64"
    Bool => "Bool"
    Double => "Double"
    Float => "Float"
    Char => "Char"
    String => "String"
    Array(elem_type) => "Array[\{elem_type}]"
    Struct(name) => "\{name}"
    Union(name) => "\{name}"
    Tuple(elem_types) => {
      let elem_strs = elem_types.map(et => "\{et}").join(", ")
      "(\{elem_strs})"
    }
    Function(param_types, ret_type) => {
      let param_strs = param_types.map(pt => "\{pt}").join(", ")
      "(\{param_strs}) -> \{ret_type}"
    }
  }
  logger.write_string(s)
}

///|
/// Performs the `typekind_to_knf` KNF lowering operation.
pub fn Context::typekind_to_knf(
  self : Context,
  tk : @typecheck.TypeKind,
) -> Type raise KnfTransformError {
  match tk {
    Unit => Unit
    Int => Int
    Int64 => Int64
    UInt => UInt
    UInt64 => UInt64
    Bool => Bool
    Double => Double
    Float => Float
    Char => Char
    String => String
    Array(elem_tk) => Array(self.typekind_to_knf(elem_tk))
    Struct(name) => Struct(name)
    Enum(name) => Union(name)
    Tuple(elem_tks) => {
      let elem_types = elem_tks.map(etk => self.typekind_to_knf(etk))
      Tuple(elem_types)
    }
    Function(param_tks, ret_tk) => {
      let param_types = param_tks.map(ptk => self.typekind_to_knf(ptk))
      let ret_type = self.typekind_to_knf(ret_tk)
      Function(param_types, ret_type)
    }
    Any => Unit
    TypeVar(_) =>
      raise KnfTransformError(
        "Unexpected TypeVar in KNF transformation: loc: typekind_to_knf",
      )
  }
}

///|
/// Performs the `type_to_knf` KNF lowering operation.
pub fn Context::type_to_knf(
  self : Context,
  t : @typecheck.Type,
) -> Type raise KnfTransformError {
  self.typekind_to_knf(t.kind)
}
